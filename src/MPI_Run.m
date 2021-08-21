function defscommands = MPI_Run( m_file, n_proc, machines )
% MPI_Run  -  Run m_file on multiple processors.
%
%  defscommands = MPI_Run( m_file, n_proc, machines )
%
%    Runs n_proc copies of m_file on machines, where
%
%    machines = {};
%      Run on a local processor.
%
%    machines = {'machine1' 'machine2'}) );
%      Run on a multi processors.
%
%    machines = {'machine1:dir1' 'machine2:dir2'}) );
%      Run on a multi processors and communicate using via dir1 and dir2,
%      which must be visible to both machines.
%
%
%    machines = {'machine1:type:dir1' 'machine2:type:dir2'}) );
%      Run on a multi processors of different type ('unix' or 'pc').
%      Default is 'unix' (can be overiden in OctMPI_Comm_settings.m)
%
%    Full syntax is: machine['&'][':unix'|':pc'][:dir]
%      & => all jobs launched on host should be run in background.
%
%    If machine1 is the local cpu, then defscommands will contain
%    the commands that need to be run locally, via eval(defscommands).
%
%  NOTE: m_file can be replaced with MPI_cc(m_file) and run
%  through the matlab mcc compiler.
%

  % Check if the directory 'OctMPI' exists
  if exist('./OctMPI', 'dir') ~= 0
     error('OctMPI directory already exists: rename or remove with OctMPI_Delete_all');
  endif

  % Create working directory.
  mkdir('OctMPI');
  
  % Create file for save and load variables.(kanibal)
  pathMPI_Run = which MPI_Run;
  spathsrc = size(pathMPI_Run);
  endsrc = spathsrc(2)-9;
  sourceOctMPI = pathMPI_Run(1:endsrc);
  unix(['cp ' sourceOctMPI 'OctMPI_Variables_save OctMPI/OctMPI_Variables &']);

  % Unix vs. Windows file seperator.
            dir_sep = '/';
  if (ispc)
      dir_sep = '\\';
  endif
            file_ext = '.sh';
  if (ispc)
      file_ext = '.bat';
  endif

  % Unix vs. Windows host name.
%  if (isunix) host = getenv('HOST');          end
  if (isunix) 
      [status, host] = unix('hostname');
      host = deblank(host);
  endif
  if (ispc)
      host = getenv('computername');
  endif

  % Get number of machines to launch on.
  n_machines = size(machines,2);

  % Create generic comm.
  MPI_COMM_WORLD = OctMPI_Comm_init(n_proc,machines);

  % Set paths.
  [pwd_pc pwd_unix] = OctMPI_dir_map(MPI_COMM_WORLD.machine_db,pwd);

  % Set newline string.
  nl = sprintf('\n');
  % Get single quote character.
  q = strrep(' '' ',' ','');
  qq = '"';

  % Initialize command launch on all the different machines.
  unix_launch = '';

  % Get number of machines.
  n_m = MPI_COMM_WORLD.machine_db.n_machine;

  % Loop backwards over each machine target machine
  % so that we hit the host machine last (if it is a target).
  for i_m=n_m:-1:1

    % Get number of processes to launch on this target machine.
    n_proc_i_m = MPI_COMM_WORLD.machine_db.n_proc(1,i_m);

    if (n_proc_i_m >= 1)

      % Get machine name, remote lauch command & flags, and type.
      machine = MPI_COMM_WORLD.machine_db.machine{1,i_m};
      remote_launch = MPI_COMM_WORLD.machine_db.remote_launch{1,i_m};
      remote_flags = MPI_COMM_WORLD.machine_db.remote_flags{1,i_m};
      type = MPI_COMM_WORLD.machine_db.type{1,i_m};

      % Set file extension of launch script to be run on
      % this target.
                             file_ext = '.sh';
      if (strcmp(type,'pc'))
          file_ext = '.bat'; 
      endif

      % Get starting and stopping rank for this machine.
      i_rank_start = MPI_COMM_WORLD.machine_db.id_start(1,i_m) - 1;
      i_rank_stop = MPI_COMM_WORLD.machine_db.id_stop(1,i_m) - 1;

      % Initialize command that will be run on each target node.
      unix_octave = '';

      % Loop backwards over number of processes.
      for i_rank=i_rank_stop:-1:i_rank_start

        % Build commands that lauch multiple octave on target nodes.
        % Aqui se construyen los comandos para abrir los todos procesos a
        % la salida de MPI_Run.
        [defscommands, unix_octave_i_rank] = OctMPI_Commands(m_file,i_rank,MPI_COMM_WORLD);
        unix_octave = [unix_octave unix_octave_i_rank];

      endfor

      % Create a file name to hold script that will be run on target.
      % Make sure to use the correct directory separator for Unix and DOS
      % unix_octave_file used when host machine is running Unix
      % dos_octave_file used when host machine is running Windows/DOS
      unix_octave_file = ['OctMPI/Unix_Commands.' machine '.' num2str(i_rank_start) file_ext];
      dos_octave_file = ['OctMPI\\Unix_Commands.' machine '.' num2str(i_rank_start) file_ext];

      if (strcmp(type,'pc')) 
        unix_octave_file = ['OctMPI/Dos_Commands.' machine '.' num2str(i_rank_start) file_ext];
        dos_octave_file = ['OctMPI\\Dos_Commands.' machine '.' num2str(i_rank_start) file_ext];
      endif

      % Put commands in a file.
      fid = fopen(unix_octave_file,'wt');
      fwrite(fid,unix_octave);
      fclose(fid);

      % Create host commands to launch this file.
      if (strcmp(machine,host)) 
          % Target is host.
         unix_launch_i_m = ['/bin/sh ./' unix_octave_file ' &' nl];

         if (strcmp(type,'pc'))  % Host is a pc.
            unix_launch_i_m = ['start /b ' dos_octave_file nl];

%            unix_launch_i_m = ['cd /d ' pwd_pc ' & start /b ' dos_octave_file nl];
         endif
      else  % Target is a remote machine.
         unix_launch_i_m = [remote_launch machine remote_flags q 'cd ' pwd_unix '; /bin/sh ./' unix_octave_file ' &' q ' &' nl];

         if (strcmp(type,'pc')) % Target is a pc.

            unix_launch_i_m = [remote_launch machine remote_flags qq 'cd /d ' pwd_pc ' & ' dos_octave_file qq nl];

% Using "start /b" does not work in WinXP            
%                               qq 'cd /d ' pwd_pc ' & start /b ' dos_octave_file qq nl];
         endif

         if (ispc) % Host is a pc.
            unix_launch_i_m = ['start /b ' remote_launch machine remote_flags qq 'cd ' pwd_unix '; /bin/sh ./' unix_octave_file ' &' qq nl];

            if (strcmp(type,'pc')) % Target is a pc.

               unix_launch_i_m = [remote_launch machine remote_flags qq 'cd /d ' pwd_pc ' & ' dos_octave_file qq nl];

% Using "start /b" does not work in WinXP            
%                                  qq 'cd /d ' pwd_pc ' & start /b ' dos_octave_file qq nl];
            endif
         endif
      endif

      % Append to variable that will be written to a file.
      unix_launch = [unix_launch unix_launch_i_m];
      %linea cambiada por kanibal para que lance el proceso local luego el
      % ssh en la maquina remota
      %unix_launch = [unix_launch_i_m unix_launch];
    endif
  endfor

  % Display launch command.
  unix_launch
  
  % Write launch commands to .sh or .bat text file
  % to fix octave's problem with very long commands sent to unix().
            launch_file = 'OctMPI/Unix_Commands.sh';
  if (ispc) 
      launch_file = 'OctMPI\\Dos_Commands.bat'; 
  endif
  fid = fopen(launch_file,'wt');
  fwrite(fid,unix_launch);
  fclose(fid);
  
 

  % Execute launch script.
  % Este es el comando que llama a los scripts bash que abren las demás 
  % instancias de octave esclavas (rank 1,2,3..), pero cuando la llamada
  % incluye un 'ssh maqRemota octave ..' se queda atascado aqui, y debe
  % pasar para que llame al script de rank 0 maestro (con "eval(defscommands)")
  % cuando termine MPI_Run.
  if (isunix)
      unix(['/bin/sh ' launch_file ' &']); 
  endif
  %if (ispc)
  %    dos([launch_file]);             
  %endif
   pause(1.0);
  defscommands = 'load  OctMPI/OctMPI_Variables';
  

%  delete(launch_file);

endfunction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OctaveMPI
% Anibal Valdés Yáñez
% Pontificia Universidad Católica de Valparaíso
% anibalvy@gmail.com      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatlabMPI
% Dr. Jeremy Kepner
% MIT Lincoln Laboratory
% kepner@ll.mit.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2002 Massachusetts Institute of Technology
% 
% Permission is herby granted, without payment, to copy, modify, display
% and distribute this software and its documentation, if any, for any
% purpose, provided that the above copyright notices and the following
% three paragraphs appear in all copies of this software.  Use of this
% software constitutes acceptance of these terms and conditions.
%
% IN NO EVENT SHALL MIT BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
% SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF
% THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF MIT HAS BEEN ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
% 
% MIT SPECIFICALLY DISCLAIMS ANY EXPRESS OR IMPLIED WARRANTIES INCLUDING,
% BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS
% FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
%
% THIS SOFTWARE IS PROVIDED "AS IS," MIT HAS NO OBLIGATION TO PROVIDE
% MAINTENANCE, SUPPORT, UPDATE, ENHANCEMENTS, OR MODIFICATIONS.

