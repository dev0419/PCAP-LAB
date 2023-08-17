#include<stdio.h>
#include<mpi.h>

int fact(int n){
    if (n == 0)
        return 1;
    return n * fact(n-1);
}


int fibonacci(int n) {
    if (n <= 0) {
        return 0;
    } else if (n == 1) {
        return 1;
    } else {
        return fibonacci(n - 1) + fibonacci(n - 2);
    }
}

int main(int argc, char *argv[]){
    int rank,size;
    int ans;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if(rank % 2 == 0){
        ans = fact(rank);
        printf("Process(rank %d) factorial = %d\n",rank,ans);
    }
    else{
        ans = fibonacci(rank);
        printf("Process(rank %d) fibonacci number = %d\n",rank,ans);
    }
    MPI_Finalize();
    return 0;
}
