% eval( MPI_Run('PruebaOctaveMPI',4,{}) );
%  eval( MPI_Run('PruebaOctaveMPI',4,{'nodo10' 'nodo05'}) );
%  eval( MPI_Run('PruebaOctaveMPI',4,{}) );
% Initialize MPI.
MPI_Init;

% Create communicator.
comm = MPI_COMM_WORLD;

% Get size and rank.
comm_size = MPI_Comm_size(comm);
my_rank = MPI_Comm_rank(comm);

% Since the leader only manages, there must be at least 2 processes
if comm_size <= 1
    error('Cannot be run with only one process');
endif

% Print rank.
disp(['my_rank: ',num2str(my_rank)]);

% Wait momentarily.
pause(4.0);

% Set who is the leader
leader = 0;

% Create base message tags.
coefs_tag = 10000;
input_tag = 200000;
output_tag = 3000000;

% Set data sizes.
%N1 = 1024;
%N2 = 128;
A=ones(20,15)*1;
B=ones(15,10)*2;
sA=size(A)
sB=size(B)
N2=sA(1,1)*sB(1,2);

% Leader.
if (my_rank == leader)
    % Create coefficient data - simple impluse.
    %coefs = zeros(N1,1);
    %coefs(1) = 1;
    
    % Create input data.
    %input = ones(N1,N2);
    
    % Create output data array.
    %output = zeros(N1,N2);
    
    
    
    % Broadcast coefficients to everyone else.
    %MPI_Bcast( leader, coefs_tag, comm, coefs );
    
    % flag for being done with all processing
    done = 0;
    
    % Instead of using for loops, use counters
    sendCounter = 1;
    recvCounter = 1;
    
    i=1;
    j=1;
    while ~done
        % Deal input data to everyone else (excluding self-leader).
        if sendCounter <= N2 
            % Do not include leader in data dealing
            dest = mod((sendCounter - 1),(comm_size-1)) + 1;
            dest_tag = input_tag + sendCounter
            %dest_data = input(:,sendCounter);
            
            dest_data_A = A(i,:);
            dest_data_B = B(:,j);
            valPosE=[i j]
            j=j+1;
            if j > sB(1,2)
                j=1;
                i=i+1;
            endif
            MPI_Send(dest,dest_tag,comm,dest_data_A,dest_data_B,valPosE);
            disp(['enviado paquete de datos numero ' num2str(sendCounter)]);
            
            sendCounter = sendCounter + 1;
        endif
        
        % Leader receives all the results.
        if recvCounter <= N2 
            % Compute who sent this message.
            % Do not include leader in data dealing
            dest = mod((recvCounter - 1),(comm_size-1)) + 1;
            
            leader_tag = output_tag + recvCounter
            
            [message_ranks, message_tags] = MPI_Probe( dest, leader_tag, comm );
            message_ranks
             message_tags
            
            % if message_ranks is not empty then receive the message
            if ~isempty(message_ranks)
                % Receive output.
                %disp(['Waiting on unit ' num2str(recvCounter)]);
                %[output(:,recvCounter),valPos] =  MPI_Recv( dest, leader_tag, comm);
                [output,valPosRR] =  MPI_Recv( dest, leader_tag, comm);
                disp(['Received data packet number ' num2str(recvCounter)]);
                fil=valPosRR(1,1);
                col=valPosRR(1,2);
                C(fil,col)=output
            
				
                recvCounter = recvCounter + 1
            else % is ~empty
                %disp(['Waiting on data packet ' num2str(recvCounter)]);
            endif

        else    % recvCounter > N2
            done = 1;
        endif
    endwhile
endif


% Everyone but the leader receives the coefs.
if (my_rank ~= leader)
    pause(1.0);
    disp(['my_rank: ',num2str(my_rank)]);
    % Receive coefs.
    %coefs = MPI_Recv( leader, coefs_tag, comm );
    %disp('Received coefficients');
    
    % Everyone but leader receives the input data and processes the results.
    k=1;
    for k=1:N2
        % Compute who the destination is for this message.
        % Do not include leader in data dealing
        dest = mod((k - 1),(comm_size-1)) + 1;
        
        % Check if this destination is me.
        if (my_rank == dest)
            % Compute tags.
            dest_tag = input_tag + k;
            leader_tag = output_tag + k;
            
            % Receive input.
            [i_input_A, i_input_B, valPosR] =  MPI_Recv(leader,dest_tag,comm);
            
            %i_input = i_input + my_rank;
            
            % Do computation.
            %i_output = fft(coefs) .* i_input;
            i_output = i_input_A * i_input_B;
            
            
            % Send results back to the leader.
            MPI_Send(leader,leader_tag,comm,i_output,valPosR);
            
            %disp(['Procesando unidad de datos ' num2str(k)]);
            pause(0.1);
        endif
    endfor
endif


% Finalize Matlab MPI.
MPI_Finalize;
disp('SUCCESS');

% Don't exist if we are the host.
if (my_rank ~= OctMPI_Host_rank(comm))
  exit;
endif
