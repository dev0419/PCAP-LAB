#include<stdio.h>
#include "mpi.h"
int main(int argc, char *argv[]){
    int rank,size;
    int ch,opr;
    int num1=20,num2=4;
    int ans;
    printf("num1:%d and num2: %d\n",num1,num2);
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    ans = num1 + num2;
    printf("Process(rank %d) after addition = %d\n",rank,ans);
    ans = num1 - num2;
    printf("Process(rank %d) after subtraction = %d\n",rank,ans);
    ans = num1 * num2;
    printf("Process(rank %d) after multiplication = %d\n",rank,ans);
    ans = num1/num2;
    printf("Process(rank %d) after division = %d\n",rank,ans);
    MPI_Finalize();
    return 0;
}