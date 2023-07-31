#include <stdio.h>
#include <mpi.h>

int factorial(int n) {
    if (n == 0 || n == 1) {
        return 1;
    } else {
        return n * factorial(n - 1);
    }
}

int fibonacci(int n) {
    if (n == 0) {
        return 0;
    } else if (n == 1) {
        return 1;
    } else {
        return fibonacci(n - 1) + fibonacci(n - 2);
    }
}

int main(int argc, char *argv[]) {
    int rank, size;
    int result;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank % 2 == 0) {
        // Calculate factorial for even-ranked processes
        result = factorial(rank);
        printf("Process %d: Factorial of %d is %d\n", rank, rank, result);
    } else {
        // Calculate Fibonacci number for odd-ranked processes
        result = fibonacci(rank);
        printf("Process %d: Fibonacci number at position %d is %d\n", rank, rank, result);
    }

    MPI_Finalize();
    return 0;
}
