function machine_db_settings = OctMPI_Comm_settings()
%
% Function for setting values in the MPI Communicator.
% User can copy this script and put it in their
% path and edit these values to customize the internals
% OctaveMPI.
%

  % Set default type of remote machines to 'unix' or 'pc'.
  machine_db_settings.type = 'unix';     % [OK TO CHANGE.]

  % Set location of octave on unix systems.
  % Generic location.  
  octave_location = ' octave ';   % [OK TO CHANGE.]

  % If this is a unix system, we can
  % try and guess a better location of octave on remote
  % machines.  If wrong, then this needs to be hard coded (see below).
  if(isunix)
    %entrego direccion archivo ejecutable
     [wew,archivo] = unix('pwd' );
  endif
  if(isunix)
    %octave_location = strrep(which('pwd'),'toolbox/matlab/general/pwd.m','bin/matlab');
     [wew,octave_location] = unix('which octave' );
  endif
  % Hard code location of matlab on remote unix systems.
  % Lincoln cluster common.
  % matlab_location = ' /tools/matlab/bin/matlab';
  % Lincoln cluster local.
  % matlab_location = ' /wulf/local/matlabr13/bin/matlab';
  % LCS Cluster local.
  % matlab_location = ' /usr/local/bin/matlab';
  % Boston University.
  % matlab_location = ' /usr/local/IT/matlab-6.1/bin/matlab';
  % MHPCC local copy.
  % matlab_location = ' /scratch/tempest/users/kepner/matlab6/bin/matlab';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Anibal Valdés proyecto de titulacion en octave instalado por apt-get install octave koctave ....
  %  [wew,octave_location] = unix('which octave' )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Build unix octave launch command based. [DON'T CHANGE]
%  machine_db_settings.octave_command = [octave_location ' -display null -nojvm -nosplash '];
%                                                       mensaje nulo al xserver, sin maquina virtualjava, sin splash screen  
  %linea adherida por kanibal para lanzar octave 
  %temporal = [octave_location '-i -q '];
   %linea adherida por kanibal para lanzar octave --exec-path
 % temporal = [octave_location '-i -q --exec-path' ];
   archivox=[archivo];
  sarchivox=size(archivox);
  %temporal = [octave_location '-i -q ' ];
  temporal = [octave_location  ];
  %machine_db_settings.octave_command = [temporal(1,1:15) ' '  temporal(1,17:33) ' ' archivo(1,1:(sarchivox(1,2)-1)) ' ' ]
  %machine_db_settings.octave_command = [temporal(1,1:15) ' '  temporal(1,17:33) ' ' archivo 'test ' ]
       machine_db_settings.octave_command = [temporal(1,1:15)];% ' '  temporal(1,17:22) ' '];
    % machine_db_settings.octave_command = [temporal(1,1:15) ' '  ];
  % -i implica interactivo para trabajo con shell remota
  % Remote launch command.
  %  To use ssh, change ' rsh ' to ' ssh ' in line below.
  % machine_db_settings.remote_launch = ' rsh ';
  machine_db_settings.remote_launch = ' ssh ';

  % Remote launch flags.
  machine_db_settings.remote_flags = ' -n ';

  % PC to Unix directory mapping.
  if (isunix)
    machine_db_settings.pc_unix_dir_map = {'Z:' getenv('HOME')};
  endif
  if (ispc)
  %  machine_db_settings.pc_unix_dir_map = {'Z:' getenv('HOME')};
    machine_db_settings.pc_unix_dir_map = {'Z:' '/home/kepner'};
  endif

endfunction
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
