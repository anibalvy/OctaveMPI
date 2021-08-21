function varargout = MPI_Bcast( source, tag, comm, varargin )
% MPI_Bcast  -  broadcast variables to everyone.
%
%   [var1, var2, ...] = ...
%     MPI_Bcast( source, tag, comm, var1, var2, ... )
%
%   Broadcast variables to everyone in comm.
%
%   Sender blocks until all the messages are received,
%   unless OctMMPI_Save_messages(1) has been called.
%

  % Get processor rank.
  my_rank = MPI_Comm_rank(comm);
  comm_size = MPI_Comm_size(comm);

  % If not the source, then receive the data.
  if (my_rank ~= source)
    varargout = MPI_Recv( source, tag, comm );
  endif

  nl = sprintf('\n');
  qq = '"';

  % If the source, then send the data.
  if (my_rank == source)

    % Create data file.
    buffer_file = OctMPI_Buffer_file(my_rank,source,tag,comm);

    % Save varargin to file.
    save(buffer_file,'varargin');

    % Loop over everyone in comm and create link to data file.
    link_command = '';
    if (ispc)
      link_command = [link_command 'echo off' nl];
    endif
    for ii=0:comm_size-1
      % Don't do source.
      if (ii ~= source)

        % Create buffer link name.
        buffer_link = OctMPI_Buffer_file(my_rank,ii,tag,comm);

        if (isunix)
          % Append to link_command.
          link_command = [link_command 'ln -s ' buffer_file ' ' buffer_link '; '];
        endif
        if (ispc)
          % Append to link_command.
          link_command = [link_command 'copy ' qq buffer_file qq ' ' qq buffer_link qq nl];
        endif

      endif
    endfor


    % Write commands unix commands to .sh text file
    % to fix Octave's problem with very long commands sent to unix().
    link_script = ['OctMPI/Link_Commands_t' num2str(tag) '.sh'];
    if (ispc)
      link_script = ['OctMPI\\Link_Commands_t' num2str(tag) '.bat'];
    endif
    fid = fopen(link_script,'wt');
    fwrite(fid,link_command);
    fclose(fid);
    if (isunix)
      unix(['/bin/sh ' link_script]);
    endif
    if (ispc)
      dos([link_script]);
    endif
    delete(link_script);

    % Loop over everyone in comm and create lock file.
    for ii=0:comm_size-1
      % Don't do source.
      if (ii ~= source)
        % Get lock file name.
        lock_file = OctMPI_Lock_file(my_rank,ii,tag,comm);

        % Create lock file.
        fclose(fopen(lock_file,'w'));
      endif
    endfor
  
    % Check if the message is to be saved.  
    if (not(comm.save_message_flag))

      % Loop over lock files.
      % Delete buffer_file when lock files are gone.
      % Loop over everyone in comm and create lock file.
      for ii=0:comm_size-1
        % Don't do source.
        if (ii ~= source)
          % Get lock file name.
          lock_file = OctMPI_Lock_file(my_rank,ii,tag,comm);

          % Spin on lock file until it is deleted.
          loop = 0;
%          while exist(lock_file) ~= 0
%%            pause(0.01);
%            loop = loop + 1;
%          end
          temp_fid = fopen(lock_file,'r');
          while temp_fid ~= -1
            loop = loop + 1;
            fclose(temp_fid);
            OctMPI_Sleep;
%            if (ispc)
%              pause(0.1);
%            end
            temp_fid = fopen(lock_file,'r');
          endwhile


        endif
      endfor


      % Delete buffer file.
      if (not(comm.save_message_flag))
        delete(buffer_file);
      endif

    endif

  endif

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

