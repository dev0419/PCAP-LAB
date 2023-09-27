#include<mpi.h>
#include<stdio.h>
int main(int argc, char *argv[]){
    int rank,size,num;
    
	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Status status;

    if (rank ==  0){
        fprintf(stdout,"Enter a number:\n");
        fflush(stdout);
        scanf("%d",&num);
        MPI_Ssend(&num,1,MPI_INT,rank+1,rank,MPI_COMM_WORLD);
        fprintf(stdout,"Process (rank %d) sent %d to Process (rank %d)\n",rank,num,rank+1);
        fflush(stdout);
        MPI_Recv(&num,1,MPI_INT,size-1,size-1,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process (rank %d) received %d from Process (rank %d)\n",rank,num,size-1);
        fflush(stdout);
    }
    
    else{
        MPI_Recv(&num,1,MPI_INT,rank-1,rank-1,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process (rank %d) received %d from Process (rank %d)\n",rank,num,rank-1);
        fflush(stdout);
        num += 1;
        //(rank + 1) % size calculates the rank of the next process in a circular manner 
            /*For process with rank 0 (rank = 0):
    (0 + 1) % 4 = 1 % 4 = 1
    For process with rank 1 (rank = 1):
    (1 + 1) % 4 = 2 % 4 = 2
    For process with rank 2 (rank = 2):
    (2 + 1) % 4 = 3 % 4 = 3*/
        MPI_Ssend(&num,1,MPI_INT,(rank+1)%size,rank,MPI_COMM_WORLD);
        fprintf(stdout,"Process (rank %d) send %d to Process (rank %d)\n",rank,num,(rank+1)%size);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
