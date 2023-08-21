#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size,ele,count=0,total_count,mat[3][3];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if (rank == 0){
        fprintf(stdout,"Enter the elements in the matrix:\n");
        fflush(stdout);
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++)
                scanf("%d",&mat[i][j]);
        
        fprintf(stdout,"Enter the element to be searched:\n");
        fflush(stdout);
        scanf("%d",&ele);
    }
        //Broadcast all rows and elements to all processes 
        for (int i = 0; i < 3; i++)
            MPI_Bcast(mat[i],3,MPI_INT,0,MPI_COMM_WORLD);

        MPI_Bcast(&ele,1,MPI_INT,0,MPI_COMM_WORLD);
        
        for (int j = 0; j < 3; j++){
        //mat[rank][j] this checks if current processes row (rank) and colmn matches the rank
            if (mat[rank][j] == ele)
                count++;
        }
        MPI_Reduce(&count,&total_count,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);
        if (rank == 0){
            fprintf(stdout,"Count of element %d in the matrix has %d occurences\n",ele,total_count);
            fflush(stdout);
        }
        MPI_Finalize();
    return 0;
}
