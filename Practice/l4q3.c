#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size,ele,arr[3][3],count=0,total_count=0;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if(rank == 0){
        fprintf(stdout,"Enter (3x3) matrix:\n");
        fflush(stdout);
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++)
                scanf("%d",&arr[i][j]);
        fprintf(stdout,"Enter the element to search:\n");
        fflush(stdout);
        scanf("%d",&ele);
    }
    for (int i = 0; i < 3; i++)
        MPI_Bcast(arr[i],3,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Bcast(&ele,1,MPI_INT,0,MPI_COMM_WORLD);
    for (int j = 0; j < 3; j++){
        if (arr[rank][j] == ele){
            count += 1;
        }
    }
    MPI_Reduce(&count,&total_count,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);
    if (rank == 0){
        fprintf(stdout,"Total no of occurences:%d\n",total_count);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
