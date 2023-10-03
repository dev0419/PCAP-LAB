#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void spmv_Csr(int num_rows, float* data, int* col_index, int* row_ptr, float* x, float* y) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < num_rows) {
        float result = 0;
        int row_start = row_ptr[row];
        int row_end = row_ptr[row + 1];
        for (int ele = row_start; ele < row_end; ele++) {
            result += data[ele] * x[col_index[ele]];
        }
        y[row] = result;
    }
}

int main() {
    int n, m;
    printf("Enter dimensions of matrix: ");
    scanf("%d%d", &n, &m);
    float* h_matrix = (float*)malloc(n * m * sizeof(float));
    printf("Enter elements of matrix:\n");
    for (int i = 0; i < n * m; i++) {
        scanf("%f", h_matrix + i);
    }
    float* h_x = (float*)malloc(m * sizeof(float));
    printf("Enter %d elements of vector x: ", m);
    for (int i = 0; i < m; i++) {
        scanf("%f", h_x + i);
    }
    int* h_row_ptr = (int*)calloc(n + 1, sizeof(int));
    int non_zero_count = 0;
    for (int i = 0; i < n; i++) {
        h_row_ptr[i] = non_zero_count;
        for (int j = 0; j < m; j++) {
            int k = i * m + j;
            if (h_matrix[k] != 0) {
                non_zero_count++;
            }
        }
    }
    h_row_ptr[n] = non_zero_count;
    float* h_data = (float*)malloc(non_zero_count * sizeof(float));
    int* h_col_index = (int*)malloc(non_zero_count * sizeof(int));
    int id = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            int k = i * m + j;
            if (h_matrix[k] != 0) {
                h_data[id] = h_matrix[k];
                h_col_index[id] = j;
                id++;
            }
        }
    }

    float* h_y = (float*)malloc(n * sizeof(float));

    // Declare and allocate device memory
    float* d_data;
    int* d_col_index;
    int* d_row_ptr;
    float* d_x;
    float* d_y;

    cudaMalloc((void**)&d_data, non_zero_count * sizeof(float));
    cudaMalloc((void**)&d_col_index, non_zero_count * sizeof(int));
    cudaMalloc((void**)&d_row_ptr, (n + 1) * sizeof(int));
    cudaMalloc((void**)&d_x, m * sizeof(float));
    cudaMalloc((void**)&d_y, n * sizeof(float));

    // Copy data from host to device
    cudaMemcpy(d_data, h_data, non_zero_count * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_index, h_col_index, non_zero_count * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_row_ptr, h_row_ptr, (n + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, m * sizeof(float), cudaMemcpyHostToDevice);

    // Set grid and block dimensions
    int block_size = 256;
    int grid_size = (n + block_size - 1) / block_size;

    // Launch the kernel
    spmv_Csr<<<grid_size, block_size>>>(n, d_data, d_col_index, d_row_ptr, d_x, d_y);

    // Copy the result y from device to host
    cudaMemcpy(h_y, d_y, n * sizeof(float), cudaMemcpyDeviceToHost);

    // Print the result vector y
    printf("Result vector y:\n");
    for (int i = 0; i < n; i++) {
        printf("%.2f\n", h_y[i]);
    }

    // Free device memory
    cudaFree(d_data);
    cudaFree(d_col_index);
    cudaFree(d_row_ptr);
    cudaFree(d_x);
    cudaFree(d_y);

    // Free host memory
    free(h_matrix);
    free(h_x);
    free(h_row_ptr);
    free(h_data);
    free(h_col_index);
    free(h_y);

    return 0;
}
