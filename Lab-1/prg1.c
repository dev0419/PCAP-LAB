#include <stdio.h>
#include <mpi.h>
#include <math.h>

int main(int argc, char *argv[]) {
    int rank;
    int x = 2; // Replace '2' with your desired integer constant 'x'
    double result;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    result = pow(x, rank);

    printf("Process %d: %lf\n", rank, result);

    MPI_Finalize();
    return 0;
}
