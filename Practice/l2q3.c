#include<stdio.h>
#include<stdlib.h>
#include<mpi.h>
int main(int argc, char  *argv[]){
    int rank,size,n,arr[10];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;
    if (rank == 0){
        fprintf(stdout,"Enter n:\n");
        fflush(stdout);
        scanf("%d",&n);
        fprintf(stdout,"Enter the array elements:\n");
        fflush(stdout);
        for (int i = 0; i < n; i++)
            scanf("%d",&arr[i]);
        int bSize = MPI_BSEND_OVERHEAD + sizeof(arr);
        int* buf = (int*)malloc(bSize);
        MPI_Buffer_attach(buf,bSize);
        for (int i = 0; i < size - 1; i++)
            MPI_Bsend(&arr[i],1,MPI_INT,i+1,0,MPI_COMM_WORLD);
        MPI_Buffer_detach(&buf,&bSize);
    }
    else{
        int num; 
        MPI_Recv(&num,1,MPI_INT,0,0,MPI_COMM_WORLD,&status);
        fprintf(stdout,"Process(rank %d) received %d\n",rank,num);
        if (rank % 2 == 0)
            num = num*num;
        else
            num = num*num*num;
        fprintf(stdout,"Process (rank %d): %d\n",rank,num);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
