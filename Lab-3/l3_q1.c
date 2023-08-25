#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size,n,arr[10],facts[10],fact,received;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    if (rank == 0){
        n = size;
        fprintf(stdout,"Enter array elements:\n");
        fflush(stdout);
        for (int i = 0; i < n; i++)
            scanf("%d",&arr[i]);
    }
    MPI_Scatter(arr,1,MPI_INT,&received,1,MPI_INT,0,MPI_COMM_WORLD);
    fprintf(stdout,"Process (rank %d) received %d\n",rank,received);
    fflush(stdout);
    fact = 1;  
    for (int i = 1; i <= n; i++){
        fact *= i;
    }
    MPI_Gather(&fact,1,MPI_INT,facts,1,MPI_INT,0,MPI_COMM_WORLD);

    if (rank == 0){
        int ans = 0;
        for (int i = 0; i < n; i++)
            ans += facts[i];
        fprintf(stdout,"The sum of all factorials:%d\n",ans);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
