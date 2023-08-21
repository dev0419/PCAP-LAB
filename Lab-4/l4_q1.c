#include<stdio.h>
#include<mpi.h>
int main(int argc, char *argv[]){
    int rank,size,fact=1,sum=0;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_set_errhandler(MPI_COMM_WORLD,MPI_ERRORS_RETURN);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    int error;
    error = MPI_Bcast(&fact,1,MPI_INT,0,MPI_COMM_WORLD);
    if (error != MPI_SUCCESS){
        char str[100];
        int len,class1;
        MPI_Error_string(error,str,&len);
        MPI_Error_class(error,&class1);
        fprintf(stderr,"Error description is %s\n",str);
        fflush(stderr);
        fprintf(stderr,"Error class is %d\n",class1);
        fflush(stderr);
    }
    for (int i = 1; i <= rank+1; i++){
        fact = fact*i;
    }
    MPI_Scan(&fact,&sum,1,MPI_INT,MPI_SUM,MPI_COMM_WORLD);
    if (rank == size - 1){
        fprintf(stdout,"Process (rank %d) sum of all factorials is %d\n",rank,sum);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
