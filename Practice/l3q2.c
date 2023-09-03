#include<stdio.h>
#include<mpi.h>

int main(int argc, char *argv[]){
    int rank, size, n, arr[10], arr2[10], arr3[10];
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        fprintf(stdout, "Enter the n:\n");
        fflush(stdout);
        scanf("%d", &n);
        fprintf(stdout, "Enter %d elements:\n", size * n);
        fflush(stdout);
        for (int i = 0; i < n * size; i++) {
            scanf("%d", &arr[i]);
        }
    }

    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Scatter(arr, n, MPI_INT, arr2, n, MPI_INT, 0, MPI_COMM_WORLD);

    float loc_avg = 0, sum = 0;
    for (int i = 0; i < n; i++) {
        sum += arr2[i];
    }
    loc_avg = sum / n;
    fprintf(stdout, "Process(rank %d) has local avg: %f\n", rank, loc_avg);
    fflush(stdout);

    MPI_Gather(&loc_avg, 1, MPI_FLOAT, arr3, 1, MPI_FLOAT, 0, MPI_COMM_WORLD);

    float cum_avg = 0, cum_sum = 0;
    if (rank == 0) {
        for (int i = 0; i < size; i++) {
            cum_sum += arr3[i];
        }
        cum_avg = cum_sum / size; // Corrected calculation
        fprintf(stdout, "Process(rank %d) has cumulative average %f\n", rank, cum_avg);
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;
}
