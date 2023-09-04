#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size, n;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        fprintf(stdout, "Enter the number:\n");
        fflush(stdout);
        scanf("%d", &n);
        MPI_Send(&n, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
        fprintf(stdout, "Process (rank %d) send %d\n", rank, n);
        fflush(stdout);
        MPI_Recv(&n, 1, MPI_INT, size - 1, size - 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        fprintf(stdout, "Process (rank %d) received final number: %d\n", rank, n);
        fflush(stdout);
    } else {
        MPI_Recv(&n, 1, MPI_INT, rank - 1, rank - 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        fprintf(stdout, "Process (rank %d) received %d\n", rank, n);
        fflush(stdout);

        n += 1;

        if (rank == size - 1) {
            MPI_Send(&n, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
        } else {
            MPI_Send(&n, 1, MPI_INT, rank + 1, rank, MPI_COMM_WORLD);
            fprintf(stdout, "Process (rank %d) send %d to Process (rank %d)\n", rank, n, rank + 1);
            fflush(stdout);
        }
    }

    MPI_Finalize();
    return 0;
}`
