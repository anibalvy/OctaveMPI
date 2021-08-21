function OctMPI_Delete_all()
% OctMPI_Delete_all  -  Deletes leftover OctaveMPI files.
% 
%  OctMPI_Delete_all()
%
%

  dir_sep = '/';
  if (ispc)
      dir_sep = '\\';
  endif

  % Check OctMPI directory exists.                                              
  if exist('./OctMPI', 'dir') == 0                                                
    disp('Nothing to delete.');                                                 
    return                                                                      
  endif                                                                           

  % Check MPI_COMM_WORLD exists.                                              
  if exist('./OctMPI/MPI_COMM_WORLD.mat') == 0
    disp('No MPI_COMM_WORLD, deleting anyway, files may be leftover.');
  else

    % First load MPI_COMM_WORLD.
    load './OctMPI/MPI_COMM_WORLD.mat';

    % Set newline string.
    nl = sprintf('\n');
    % Get single quote character.
    q = strrep(' '' ',' ','');

    % Get number of machines.
    n_m = MPI_COMM_WORLD.machine_db.n_machine;

    % Loop backwards over each machine.
    for i_m=n_m:-1:1

      % Get number of processes to launch on this machine.
      n_proc_i_m = MPI_COMM_WORLD.machine_db.n_proc(1,i_m);

      if (n_proc_i_m >= 1)

        % Get communication directory.
        comm_dir = MPI_COMM_WORLD.machine_db.dir{1,i_m};

        % Delete buffer and lock files in this directory.
        delete([comm_dir dir_sep 'p*_p*_t*_buffer.mat']);
        delete([comm_dir dir_sep 'p*_p*_t*_lock.mat']);
      endif
    endfor
  endif

  % Delete OctMPI directory.
 % rmdir(['.' dir_sep 'OctMPI' dir_sep '*']);
  %rmdir(['.' dir_sep 'OctMPI'],'s');
  % Agregado por kanibal 
  %file='OctMPI';
%	rmdir (file);
     unix(' rm -r OctMPI')
%  if (isunix)
%    delete(['.' dir_sep 'OctMPI']);
%  else
%    rmdir(['.' dir_sep 'OctMPI']);
%    delete(['.' dir_sep 'OctMPI']);
%    dos(['rmdir /S /Q .' dir_sep 'OctMPI']);
%  end


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

