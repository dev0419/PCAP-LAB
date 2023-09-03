#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

__global__ void vecAddKernel_1a(float *A, float *B, float *C, int n) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx < n)
        C[idx] = A[idx] + B[idx];
}

__global__ void vecAddKernel_1b(float *A, float *B, float *C, int n) {
    int idx = threadIdx.x;
    if (idx < n)
        C[idx] = A[idx] + B[idx];
}

int main() {
    int n = 5, size = n * sizeof(float);
    float *h_A = (float *)malloc(size);
    float *h_B = (float *)malloc(size);
    float *h_C = (float *)malloc(size);

    for (int i = 0; i < n; i++) {
        h_A[i] = (i + 1) * 10;
        h_B[i] = i + 1;
    }

    float *d_A, *d_B, *d_C;
    cudaMalloc((void **)&d_A, size);
    cudaMalloc((void **)&d_B, size);
    cudaMalloc((void **)&d_C, size);

    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    int blockSize = n;
    int numBlocks = 1;

    vecAddKernel_1a<<<numBlocks, blockSize>>>(d_A, d_B, d_C, n);
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    printf("A + B (from 1a kernel): ");
    for (int i = 0; i < n; i++)
        printf("%f, ", h_C[i]);
    printf("\n");

    vecAddKernel_1b<<<numBlocks, blockSize>>>(d_A, d_B, d_C, n);
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    printf("A + B (from 1b kernel): ");
    for (int i = 0; i < n; i++)
        printf("%f, ", h_C[i]);
    printf("\n");

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}
