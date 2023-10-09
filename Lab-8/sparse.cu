#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>

__global__ void csr(int num_rows, int* data, int* col_index, int* row_ptr, int* x, int* y) {
    int row = threadIdx.x + blockIdx.x * blockDim.x;
    if (row < num_rows) {
        int res = 0;
        int row_start = row_ptr[row];
        int row_end = row_ptr[row + 1];
        for (int i = row_start; i < row_end; i++) {
            res += data[i] * x[col_index[i]];
        }
        y[row] = res;
    }
}

int main() {
    int m, n;
    printf("Enter the dimensions of the matrix:\n");
    scanf("%d %d", &m, &n);
    printf("Enter the sparse matrix:\n");
    int *mat = (int*)malloc(sizeof(int) * m * n);
    int non_zero_count = 0;
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            scanf("%d", &mat[i * n + j]);
            if (mat[i * n + j] != 0) {
                non_zero_count++;
            }
        }
    }

    int* data = (int*)malloc(sizeof(int) * non_zero_count);
    int* col_index = (int*)malloc(sizeof(int) * non_zero_count);
    int* x = (int*)malloc(sizeof(int) * n);
    printf("Enter the elements of the vector x:\n");
    for (int i = 0; i < n; i++) {
        scanf("%d", &x[i]);
    }
    int* row_ptr = (int*)malloc(sizeof(int) * (m + 1));
    int* y = (int*)malloc(sizeof(int) * m);
    int id = 0;
    row_ptr[0] = 0;
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            int k = i * n + j;
            if (mat[k] != 0) {
                data[id] = mat[k];
                col_index[id] = j;
                id += 1;
            }
        }
        row_ptr[i + 1] = id;
    }
    int* d_data, *d_col_index, *d_row_ptr, *d_x, *d_y;
    cudaMalloc((void**)&d_data, non_zero_count * sizeof(int));
    cudaMalloc((void**)&d_col_index, non_zero_count * sizeof(int));
    cudaMalloc((void**)&d_row_ptr, (m + 1) * sizeof(int));
    cudaMalloc((void**)&d_x, n * sizeof(int));
    cudaMalloc((void**)&d_y, m * sizeof(int));
    cudaMemcpy(d_data, data, non_zero_count * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_index, col_index, non_zero_count * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_row_ptr, row_ptr, (m + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, x, n * sizeof(int), cudaMemcpyHostToDevice);
    csr<<<1, m>>>(m, d_data, d_col_index, d_row_ptr, d_x, d_y);
    cudaMemcpy(y, d_y, m * sizeof(int), cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for (int i = 0; i < m; i++) {
        printf("%d ", y[i]);
    }
    printf("\n");
    return 0;
}
