#include<stdio.h>
#include<mpi.h>

int power(int x,int rank){
    int ans = 1;
    if (rank >=  0){
        for (int i = 0; i < rank; i++){
            ans *= x;
        }
    } else{
        for (int i = 0; i < rank; i++){
            ans /= x;
        }
    }
    return ans;
}

int main(int argc, char *argv[]){
    int rank,size;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    int num = 4;
    int ans = power(num, rank);
    printf("Process (rank %d) with power %d",rank,ans);
    MPI_Finalize();
    return 0;
}
