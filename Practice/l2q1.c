#include<stdio.h>
#include<mpi.h>
#include<string.h>
int main(int argc, char *argv[]){
    int rank,size;
    char str1[10];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;
    if (rank == 0){
        fprintf(stdout,"Enter the string:\n");
        fflush(stdout);
        scanf("%s",str1);
        MPI_Ssend(&str1,sizeof(str1),MPI_CHAR,1,0,MPI_COMM_WORLD);
        fprintf(stdout,"Process (rank %d) send %s\n",rank,str1);
        fflush(stdout);
        MPI_Recv(&str1,sizeof(str1),MPI_CHAR,1,1,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process (rank %d) received the toggled word %s\n",rank,str1);
        fflush(stdout);
    }
    else{
        MPI_Recv(&str1,sizeof(str1),MPI_CHAR,0,0,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process(rank %d) received %s\n",str1);
        fflush(stdout);
        for (int i = 0; i < sizeof(str1); i++){
            if (str1[i] >= 'A' && str1[i] <= 'Z')
                str1[i] += 32;
            if (str1[i] >= 'a' && str1[i] <= 'z')
                str1[i] -= 32;
        }
        fprintf(stdout,"Toggled word %s\n",str1);
        fflush(stdout);
        MPI_Ssend(&str1,sizeof(str1),MPI_CHAR,0,1,MPI_COMM_WORLD);
        fprintf(stdout,"Process (rank %d) sending %s to root\n",rank,str1);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}

