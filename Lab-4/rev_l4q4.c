#include <stdio.h>
#include "mpi.h"

int main(int argc, char* argv[]) {
    int rank, size, intervals;
    double h, f, x, pi_partial, pi_total;

    // Initialize MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        // Prompt the user to enter the number of intervals
        printf("Enter the number of intervals: ");
        scanf("%d", &intervals);
    }

    // Broadcast the number of intervals to all processes
    MPI_Bcast(&intervals, 1, MPI_INT, 0, MPI_COMM_WORLD);

    // Calculate the width of each interval
    h = 1.0 / intervals;

    // Calculate the partial sum for each process
    pi_partial = 0.0;
    for (int i = rank + 1; i <= intervals; i += size) {
        x = h * ((double)i - 0.5);
        f = 4.0 / (1.0 + x * x);
        pi_partial += f;
    }

    // Reduce the partial sums from all processes to get the total pi
    MPI_Reduce(&pi_partial, &pi_total, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        // Calculate the final approximation of pi and display it
        double pi_approx = h * pi_total;
        printf("Value of pi approximated with %d intervals and %d processes = %lf\n", intervals, size, pi_approx);
    }

    // Finalize MPI
    MPI_Finalize();
    return 0;
}
