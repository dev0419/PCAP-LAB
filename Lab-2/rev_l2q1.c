#include<stdio.h>
#include<string.h>
#include "mpi.h"
int main(int argc, char *argv[]){
    int rank,size;
    char str[50];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);    
    MPI_Status status;
    if(rank == 0){
        fprintf(stdout,"Enter string:\n");
        fflush(stdout);
        scanf("%s",str);
        int len = strlen(str)+1;
        MPI_Ssend(str,len,MPI_CHAR,1,0,MPI_COMM_WORLD);
        fprintf(stdout,"Process %d send %s to Process %d\n",rank,str,rank+1);
        fflush(stdout);
    }
    else{
        int len = sizeof(str);
        MPI_Recv(str,len,MPI_CHAR,0,0,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process %d received %s from root\n",rank,str);
        fflush(stdout);
        for (int i = 0; i < len-1; i++){
            if(str[i] >= 'A' && str[i] <= 'Z')
                str[i] += 32;
            else if(str[i] >= 'a' && str[i] <= 'z')
                str[i] -= 32;
        }
        fprintf(stdout,"Toggled string is %s\n",str);
        fflush(stdout);
        MPI_Ssend(str,len,MPI_CHAR,0,1,MPI_COMM_WORLD);
        fprintf(stdout,"Sending the toggled string to root:%s\n",str);
        fflush(stdout);        
    }
    if(rank == 0){
        int len = sizeof(str);
        MPI_Recv(str,len,MPI_CHAR,1,1,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Root received the toggled string:%s\n",str);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
