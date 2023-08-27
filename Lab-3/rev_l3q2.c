#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size, arr[10], recv[20],n;
    float avg = 0, sum = 0, tot_sum = 0, tot_avg = 0, ans[20];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        fprintf(stdout, "Enter n:\n");
        fflush(stdout);
        scanf("%d", &n);
        fprintf(stdout, "Enter %d array elements:\n", n * size);
        fflush(stdout);
        for (int i = 0; i < n * size; i++) {
            scanf("%d", &arr[i]);
        }
    }

    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Scatter(arr, n, MPI_INT, recv, n, MPI_INT, 0, MPI_COMM_WORLD);

    for (int i = 0; i < n; i++) {
        sum += recv[i];  // Use recv here instead of arr
    }
    avg = sum / n;
    
    fprintf(stdout, "Process (rank %d) has average %f\n", rank, avg);
    fflush(stdout);
    
    MPI_Gather(&avg, 1, MPI_FLOAT, ans, 1, MPI_FLOAT, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        for (int i = 0; i < size; i++) {  // Iterate over size, not n
            tot_sum += ans[i];
        }
        tot_avg = tot_sum / size;  // Calculate the total average
        fprintf(stdout, "Total average: %f\n", tot_avg);
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;
}
