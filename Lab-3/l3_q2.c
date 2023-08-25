#include<stdio.h>
#include<stdlib.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size,m,arr[10],ans[10];
    float avg = 0,sum=0;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    if (rank == 0){
        fprintf(stdout,"Enter m:\n");
        fflush(stdout);
        scanf("%d",&m);
        fprintf(stdout,"Enter %d elements:\n",size*m);
        fflush(stdout);
        for (int i = 0; i < size*m; i++)
            scanf("%d",&arr[i]);
    }
    
    MPI_Bcast(&m,1,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Scatter(arr, m, MPI_INT, ans, m, MPI_INT, 0, MPI_COMM_WORLD);
    for (int i = 0; i < m; i++)
        sum += ans[i];
    avg = sum/m;
    MPI_Gather(&avg, 1, MPI_FLOAT, ans, 1, MPI_FLOAT, 0, MPI_COMM_WORLD);
    if (rank == 0){
        float total_avg = 0;
        for (int i = 0; i < m; i++)
            total_avg += ans[i];
        total_avg = avg/m*size;
        fprintf(stdout,"The  average of all values %f\n",avg);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}