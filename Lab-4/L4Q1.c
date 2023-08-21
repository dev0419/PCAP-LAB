#include <mpi.h>
#include <string.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    int rank, size, n, fact = 1, sum = 0, ans[20], i = 0, k = 0;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Set the initial value of fact based on the rank
    for (int i = 1; i <= rank + 1; i++)
        fact = fact * i;

    // Broadcast the initial value of fact from rank 0
    int error;
    MPI_Errhandler_set(MPI_COMM_WORLD, MPI_ERRORS_RETURN);
    error = MPI_Bcast(&fact, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if (error != MPI_SUCCESS) {
        char s[100];
        int len, class1;
        MPI_Error_string(error, s, &len);
        MPI_Error_class(error, &class1);
        fprintf(stderr, "Error description is %s\n", s);
        fflush(stderr);
        fprintf(stderr, "Error class is %d\n", class1);
        fflush(stderr);
    }

    MPI_Scan(&fact, &k, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);

    if (rank == size - 1) {
        fprintf(stdout, "Sum of all factorials %d\n", k);
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;
}
