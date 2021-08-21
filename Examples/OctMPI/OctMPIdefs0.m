global MPI_COMM_WORLD;
load 'OctMPI/MPI_COMM_WORLD.mat';
MPI_COMM_WORLD.rank = 0;
PruebaOctaveMPI;
save OctMPI/OctMPI_Variables;
