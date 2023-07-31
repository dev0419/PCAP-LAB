#include <stdio.h>
#include<string.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank;
    char str[] = "HELLO";

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    int index = rank % strlen(str);

    if (str[index] >= 'A' && str[index] <= 'Z') {
        str[index] = str[index] + 32; // Toggle the character to lowercase
    } else if (str[index] >= 'a' && str[index] <= 'z') {
        str[index] = str[index] - 32; // Toggle the character to uppercase
    }

    printf("Process %d: %s\n", rank, str);

    MPI_Finalize();
    return 0;
}
