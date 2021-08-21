function OctMPI_Sleep
  if (isunix)
    pause(0.01);
  else
    pause(0.1);
  endif
  return;
endfunction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OctaveMPI
% Anibal Valdés Yáñez
% Pontificia Universidad Católica de Valparaíso
% anibalvy@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%