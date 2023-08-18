#include<stdio.h>
#include<string.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size;
    char word[20];
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Status status;
    if (rank == 0){
        printf("Enter a word:\n");
        scanf("%s",word);
        int len = strlen(word);
        printf("Process(rank %d) sending to word %s to Process(rank %d)\n",rank,word,rank+1);
        
        //when we use ssend we have to have a matching receive
        MPI_Ssend(&word,sizeof(word),MPI_CHAR,1,0,MPI_COMM_WORLD);
    }
    
    else if(rank == 1){
        MPI_Recv(&word,sizeof(word),MPI_CHAR,0,0,MPI_COMM_WORLD,&status);
        printf("Process(rank %d) received %s from Process(rank %d)\n",rank,word,rank-1);
        int len = strlen(word);
        for (int i = 0; i < len; i++){
            if (word[i] >= 'A' && word[i] <= 'Z'){
                word[i] += 32;
            }
            else if (word[i] >= 'a' && word[i] <= 'z'){
                word[i] -= 32;
            }          
        }
        printf("String after toggling each character: %s\n",word);
        printf("Sending %s to Process(rank%d)\n",word,rank);
        MPI_Ssend(&word,sizeof(word),MPI_CHAR,0,1,MPI_COMM_WORLD);
    }

    if(rank == 0){
        MPI_Recv(&word,sizeof(word),MPI_CHAR,1,1,MPI_COMM_WORLD,&status);
        printf("Process (rank %d) received %s from Process(rank %d)\n", rank, word, rank + 1);
    }
    MPI_Finalize();
    return 0;
}
