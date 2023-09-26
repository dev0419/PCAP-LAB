#include<stdio.h>
#include<mpi.h>
#include<string.h>

int main(int argc, char *argv[]) {
  int rank, size;
  char str[40];

  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  if (rank == 0) {
    fprintf(stdout, "Enter the string:\n");
    fflush(stdout);
    scanf("%s", str);

    int len = strlen(str);
    MPI_Ssend(str, len, MPI_CHAR, 1, 0, MPI_COMM_WORLD);
    fprintf(stdout, "Process (rank %d) send %s to Process(rank %d)\n", rank, str, rank + 1);
    fflush(stdout);
  } else {
    int len = sizeof(str);
    MPI_Recv(str, len, MPI_CHAR, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    fprintf(stdout, "Process (rank %d) receives %s from Process(rank %d)\n", rank, str, rank - 1);
    fflush(stdout);

    for (int i = 0; i < len; i++) {
      if (str[i] >= 'A' && str[i] <= 'Z') {
        str[i] += 32;
      } else if (str[i] >= 'a' && str[i] <= 'z') {
        str[i] -= 32;
      }
    }

    fprintf(stdout, "Toggled word is %s\n", str);
    fflush(stdout);

    MPI_Ssend(str, len, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
    fprintf(stdout, "Sending %s to root\n", str);
    fflush(stdout);
  }

  if (rank == 0) {
    int len = sizeof(str);
    MPI_Recv(str, len, MPI_CHAR, 1, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    fprintf(stdout, "received toggled word %s\n", str);
    fflush(stdout);
  }

  MPI_Finalize();

  return 0;
}
