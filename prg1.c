#include <stdio.h>
#include "mpi.h"

int main(int argc, char** argv) {
    int rank, size;
    int message;

    // Initialize MPI environment
    MPI_Init(&argc, &argv);

    // Get the rank (ID) of the current process
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    // Get the total number of processes
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        // Process 0 sends a message to process 1
        message = 42;
        MPI_Send(&message, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
        printf("Process %d sent %d\n", rank, message);
    } else if (rank == 1) {
        // Process 1 receives the message from process 0
        MPI_Recv(&message, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        printf("Process %d received %d\n", rank, message);
    }

    // Finalize MPI environment
    MPI_Finalize();

    return 0;
}
