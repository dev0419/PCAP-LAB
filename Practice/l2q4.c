#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;
    int num;
    if (rank == 0){
        fprintf(stdout,"Enter the number:\n");
        fflush(stdout);
        scanf("%d",&num);
        MPI_Send(&num,1,MPI_INT,1,0,MPI_COMM_WORLD);
        fprintf(stdout,"Process(rank %d) send %d\n",rank,num);
        fflush(stdout);
    }
    else{
        MPI_Recv(&num,1,MPI_INT,0,0,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process (rank %d) received %d\n",rank,num);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
