#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    //inarr is used to store a row of input mat that is being distrubuted to each process
    //outarrr stores the cumulative sum ressults for the input row 
    int rank,size,inmat[4][4],outmat[4][4],inarr[4],outarr[4];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if (rank == 0){
        fprintf(stdout,"Enter a 4x4  matrix:\n");
        fflush(stdout);
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                scanf("%d",&inmat[i][j]);
    }
        //Scattering rows of input mat to all processes
        MPI_Scatter(inmat,4,MPI_INT,inarr,4,MPI_INT,0,MPI_COMM_WORLD);
        //Calculating the cumulative sum for each row
        MPI_Scan(inarr,outarr,4,MPI_INT,MPI_SUM,MPI_COMM_WORLD);
        MPI_Gather(outarr,4,MPI_INT,outmat,4,MPI_INT,0,MPI_COMM_WORLD);
        fprintf(stdout,"The row sum of the input matrix:\n");
        fflush(stdout);
    if (rank == 0){
        for (int i = 0; i < 4; i++){
            for (int j = 0; j < 4; j++){
                fprintf(stdout," %d ", outmat[i][j]);
                fflush(stdout);
            }
            printf("\n");
        }    
    }
    MPI_Finalize();
    return 0;
}
