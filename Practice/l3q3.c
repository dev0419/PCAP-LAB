#include<stdio.h>
#include<string.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size,len,arr[10];
    char str[10],str1[10];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if (rank == 0){
        fprintf(stdout,"Enter the string:\n");
        fflush(stdout);
        scanf("%s",str);
        len = strlen(str);
        len = len/size;
    }
    MPI_Bcast(&len,1,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Scatter(str,len,MPI_CHAR,str1,len,MPI_CHAR,0,MPI_COMM_WORLD);
    int count = 0,total_count=0;
    for (int i = 0; i < len; i++)
        if(str1[i] != 'A'&& str1[i] != 'E' && str1[i] != 'I' && str1[i] != 'O'&& str1[i] != 'U'&& str1[i] != 'a'&& str1[i] != 'e'&& str1[i] != 'i'&& str1[i] != 'o'&& str1[i] != 'u')
            count += 1;
    fprintf(stdout,"Process (rank %d) has %d non-vowels\n",rank,count);
    fflush(stdout);
    MPI_Gather(&count,1,MPI_INT,arr,1,MPI_INT,0,MPI_COMM_WORLD);
    if (rank == 0){
        for (int i = 0; i < size; i++){
            total_count += arr[i];
        }
        fprintf(stdout,"Process (rank %d) has %d non-vowels\n",rank,total_count);
        fflush(stdout);
    }
    MPI_Finalize();    
    return 0;
}
