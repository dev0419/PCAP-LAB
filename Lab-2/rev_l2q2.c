#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size,num;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;
    if (rank == 0){
        fprintf(stdout,"Enter a number:\n");
        fflush(stdout);
        scanf("%d",&num);
        MPI_Send(&num,1,MPI_INT,1,0,MPI_COMM_WORLD);
        fprintf(stdout,"Process(rank %d) send %d to Process(rank %d)\n",rank,num,rank+1);
        fflush(stdout);
    }
    else{
        MPI_Recv(&num,1,MPI_INT,0,0,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process (rank %d) received %d from Process (rank %d)\n",rank,num,rank-1);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
