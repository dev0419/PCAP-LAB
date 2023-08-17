#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    char str[10] = "hello";
    //character toggling is to toggle all characters to covert Upper case to Lower case and vice versa
    if(str[rank] >= 'A' && str[rank] <= 'Z')
        str[rank] += 32;    
    else if(str[rank] >= 'a' && str[rank] <= 'z')
        str[rank] -= 32;
    printf("Process (rank %d): %s\n",rank,str);
    MPI_Finalize(); 
    return 0;
}
