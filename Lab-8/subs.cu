#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <math.h>

__global__ void replaceRows(int m, int n, int* matrix) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < m) {
        for (int col = 0; col < n; col++) {
            matrix[row * n + col] = pow(matrix[row * n + col], row + 1);
        }
    }
}

int main() {
    int m, n;
    printf("Enter the dimensions of the matrix (MxN): ");
    scanf("%d %d", &m, &n);

    // Allocate and initialize the matrix on the host
    int* h_matrix = (int*)malloc(m * n * sizeof(int));
    printf("Enter the elements of the matrix:\n");
    for (int i = 0; i < m * n; i++) {
        scanf("%d", &h_matrix[i]);
    }

    // Allocate memory on the GPU
    int* d_matrix;
    cudaMalloc((void**)&d_matrix, m * n * sizeof(int));

    // Copy the matrix from host to device
    cudaMemcpy(d_matrix, h_matrix, m * n * sizeof(int), cudaMemcpyHostToDevice);

    // Define grid and block dimensions
    int blockSize = 256;
    int numBlocks = (m + blockSize - 1) / blockSize;

    // Launch the kernel to replace rows
    replaceRows<<<numBlocks, blockSize>>>(m, n, d_matrix);

    // Copy the modified matrix back to the host
    cudaMemcpy(h_matrix, d_matrix, m * n * sizeof(int), cudaMemcpyDeviceToHost);

    // Free device memory
    cudaFree(d_matrix);

    // Print the modified matrix
    printf("Modified Matrix:\n");
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            printf("%d ", h_matrix[i * n + j]);
        }
        printf("\n");
    }

    // Free host memory
    free(h_matrix);

    return 0;
}
