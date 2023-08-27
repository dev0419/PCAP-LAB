#include<stdio.h>
#include<string.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size;
    char str[50];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;
    if (rank == 0){
        fprintf(stdout,"Enter the word:\n");
        fflush(stdout);
        scanf("%s",str);
        MPI_Ssend(&str,sizeof(str),MPI_CHAR,1,0,MPI_COMM_WORLD);
        fprintf(stdout,"Process (rank %d) send %s to Process(rank %d)\n",rank,str,rank+1);
        fflush(stdout);
    }
    else{
        MPI_Recv(&str,sizeof(str),MPI_CHAR,0,0,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process(rank %d) received %s from Process (rank %d)\n",rank,str,rank-1);
        fflush(stdout);
        for (int i = 0; i < sizeof(str); i++){
            if(str[i] >= 'A' && str[i] <= 'Z')
                str[i] += 32;
            
            if(str[i] >= 'a' && str[i] <= 'z')
                str[i] -= 32;
        }
        fprintf(stdout,"Toggled word is %s\n",str);
        fflush(stdout);
        MPI_Ssend(&str,sizeof(str),MPI_CHAR,0,1,MPI_COMM_WORLD);
        fprintf(stdout,"Process (rank %d) sending %s to root\n",rank,str);
        fflush(stdout);
    }
    if (rank == 0){
        MPI_Recv(&str,sizeof(str),MPI_CHAR,1,1,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process(rank %d) received the toggled word %s",rank,str);
        fflush(stdout);
    }
    
    return 0;
}
