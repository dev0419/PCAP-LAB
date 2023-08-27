#include <stdio.h>
#include <mpi.h>
#include <string.h>

int main(int argc, char *argv[]) {
    int rank, size, len;
    char str1[20], str2[20], str3[40]; // Adjust size for larger strings
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        fprintf(stdout,"Enter the string 1:\n");
        fflush(stdout);
        scanf("%s", str1);
        fprintf(stdout,"Enter the string 2 (same length as str1):\n");
        fflush(stdout);
        scanf("%s", str2);
        len = strlen(str1) / size;
    }

    MPI_Bcast(&len, 1, MPI_INT, 0, MPI_COMM_WORLD);

    MPI_Scatter(str1, len, MPI_CHAR, str3, len, MPI_CHAR, 0, MPI_COMM_WORLD);
    MPI_Scatter(str2, len, MPI_CHAR, str3 + len, len, MPI_CHAR, 0, MPI_COMM_WORLD);

    str3[2 * len] = '\0';

    char gathered_str[40 * size]; // Temporary buffer for gathered strings

    MPI_Gather(str3, 2 * len, MPI_CHAR, gathered_str, 2 * len, MPI_CHAR, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        gathered_str[2 * len * size] = '\0';
        fprintf(stdout,"Concatenated string is %s\n", gathered_str);
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;
}
