#include<stdio.h>
#include<string.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size;
    char str1[20],str2[20],str3[20];
    int len;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if (rank == 0){
        fprintf(stdout,"Enter the string 1:\n");
        fflush(stdout);
        scanf("%s",str1);
        fprintf(stdout,"Enter the string 2(same length as str1):\n");
        fflush(stdout);
        scanf("%s",str2);
        len = strlen(str1);
        len /= size;
    }
    MPI_Bcast(&len,1,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Scatter(str1,len,MPI_CHAR,str3,len,MPI_CHAR,0,MPI_COMM_WORLD);
    MPI_Scatter(str2,len,MPI_CHAR,str3+len,len,MPI_CHAR,0,MPI_COMM_WORLD);
    str3[2 * len] = '\0';
    char temp_str[40 * size];//temp str for storing concatened str
    MPI_Gather(str3,2*len,MPI_CHAR,temp_str,2*len,MPI_CHAR,0,MPI_COMM_WORLD);
    if (rank == 0){
        temp_str[2*len*size] = '\0';
        fprintf(stdout,"Process(rank %d) has concatenated string:%s\n",rank,temp_str);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
