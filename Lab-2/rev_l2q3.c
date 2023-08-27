#include<stdio.h>
#include<stdlib.h>
#include<mpi.h>

int main(int argc, char *argv[]){
    int rank,size,n,arr[10];
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;
    if (rank == 0){
        n = size;
        fprintf(stdout,"Enter %d array elements:\n",size);
        fflush(stdout);
        for (int i = 0; i < n; i++){
            scanf("%d",&arr[i]);
        }
        int bSize = MPI_BSEND_OVERHEAD + sizeof(arr);
        int* buf = (int*)malloc(bSize);
        MPI_Buffer_attach(buf,bSize);
        for (int i = 1; i < size; i++){
            MPI_Bsend(&arr[i], 1, MPI_INT, i, 0, MPI_COMM_WORLD);
            fprintf(stdout, "Process (rank %d) sending %d to Process (rank %d)\n", rank, arr[i], i);
            fflush(stdout);
        }

        MPI_Buffer_detach(&buf,&bSize);
    }
    else{
            int num;//store the integer value received from process rank 0.
            MPI_Recv(&num,1,MPI_INT,0,0,MPI_COMM_WORLD,&status);
            if (rank % 2 == 0){
                int sqr_num = num*num;
                fprintf(stdout,"Process (rank %d) received %d from root after squaring\n",rank, num,sqr_num);
                fflush(stdout);
            }
            else{
                int cub_num = num*num*num;
                fprintf(stdout,"Process (rank %d) received %d from root after squaring\n",rank, num,cub_num);
                fflush(stdout);
            }
    }        
    MPI_Finalize();
    return 0;
}
    

