#include<mpi.h>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
int main(int argc, char *argv[]){
    int rank,size,len,count=0,arr[50];
    char str[50],recv[50],ans[50];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if (rank == 0){
        fprintf(stdout,"Enter the string:\n");
        fflush(stdout);
        scanf("%s",str);
        len = strlen(str)/size;
    }
    MPI_Bcast(&len,1,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Scatter(str,len,MPI_CHAR,recv,len,MPI_CHAR,0,MPI_COMM_WORLD);
    for (int i = 0; i < len; i++){
        if (recv[i] != 'a'||recv[i] != 'e'||recv[i] != 'i'||recv[i] != 'o'||recv[i] != 'u'||recv[i] != 'A'||recv[i] != 'E'||recv[i] != 'I'||recv[i] != 'O'||recv[i] != 'U'){
            count += 1;
        }
    }
    fprintf(stdout,"Process (rank %d), no of non-vowels: %d\n",rank,count);
    fflush(stdout);
    MPI_Gather(&count,1,MPI_INT,arr,1,MPI_INT,0,MPI_COMM_WORLD);
    if (rank == 0){
        int total_count = 0;
        for (int i = 0; i < size; i++){
            total_count += arr[i];
        }
        fprintf(stdout,"Total number of non vowels: %d\n",total_count);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
