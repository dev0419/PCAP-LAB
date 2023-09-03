#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size,n,fact=1,arr[10],facts[10],sum=0;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if (rank == 0){
        fprintf(stdout,"Enter the n:\n");
        fflush(stdout);
        scanf("%d",&n);
        fprintf(stdout,"Enter the array elements:\n");
        fflush(stdout);
        for (int i = 0; i < n; i++){
            scanf("%d",&arr[i]);
        }
    }
    MPI_Scatter(arr,1,MPI_INT,&fact,1,MPI_INT,0,MPI_COMM_WORLD);
    for (int i = 1; i <= n; i++){
        fact  = fact * i;
    }
    fprintf(stdout,"Process (rank %d): %d\n",rank,fact);
    fflush(stdout);
    MPI_Gather(&fact,1,MPI_INT,facts,1,MPI_INT,0,MPI_COMM_WORLD);
    if (rank == 0){
        for (int i = 0; i < n; i++){
            sum += facts[i];
        }
        fprintf(stdout,"Sum of all factorials at process (rank %d) has %d\n",rank,sum);  
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
