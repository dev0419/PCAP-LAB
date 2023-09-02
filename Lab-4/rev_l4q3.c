#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size,arr[4][4],ans[4][4],row[10],rowsum[10];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if (rank == 0){
        fprintf(stdout,"Enter (4x4) matrix:\n");
        fflush(stdout);
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                scanf("%d",&arr[i][j]);
    }
    MPI_Scatter(arr,4,MPI_INT,row,4,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Scan(row,rowsum,4,MPI_INT,MPI_SUM,MPI_COMM_WORLD);
    MPI_Gather(rowsum,4,MPI_INT,ans,4,MPI_INT,0,MPI_COMM_WORLD);
    if (rank == 0){
        fprintf(stdout,"Sum of all rows:\n");
        fflush(stdout);
        for (int i = 0; i < 4; i++){
            for (int j = 0; j < 4; j++){
                fprintf(stdout,"%d ",ans[i][j]);
                fflush(stdout);
            }
            printf("\n");
        }
    }
    MPI_Finalize();
    return 0;
}
