#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size;
    int num;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Status status;

    if (rank == 0) {
        printf("Enter the number:\n");
        fflush(stdout); // Flush the output buffer
        scanf("%d", &num);
        for (int i = 1; i < size; i++){
            MPI_Send(&num, 1, MPI_INT, i, 0, MPI_COMM_WORLD);
            printf("Process(rank %d) sending %d to Process(rank %d)\n", rank, num, i);
            fflush(stdout); // Flush the output buffer
        }
    }
    else {
        MPI_Recv(&num, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
        printf("Process(rank %d) received %d from root\n", rank, num);
        fflush(stdout); // Flush the output buffer
    }
    
    MPI_Finalize();
    return 0;
}
