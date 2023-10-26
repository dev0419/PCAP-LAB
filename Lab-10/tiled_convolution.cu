#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#define TILE_SIZE 32
#define MASK_WIDTH 5  

__global__ void convolution(int* N, int* M, int* P, int width) {
    __shared__ int N_tile[TILE_SIZE + 2 * (MASK_WIDTH / 2)];
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int start = i - (MASK_WIDTH / 2);
    int pval = 0;
    int local_index = threadIdx.x + MASK_WIDTH / 2;

    if (start >= 0 && start < width) {
        N_tile[local_index] = N[start];
    } else {
        N_tile[local_index] = 0;
    }
    __syncthreads();

    for (int j = 0; j < MASK_WIDTH; j++) {
        pval += N_tile[local_index + j - MASK_WIDTH / 2] * M[j];
    }

    P[i] = pval;
}

void performConvolution(int* N, int* M, int* P, int width) {
    int* d_N, *d_M, *d_P;
    int size = width * sizeof(int);
    cudaMalloc((void**)&d_N, size);
    cudaMalloc((void**)&d_M, MASK_WIDTH * sizeof(int));  
    cudaMalloc((void**)&d_P, size);
    cudaMemcpy(d_N, N, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_M, M, MASK_WIDTH * sizeof(int),cudaMemcpyHostToDevice);  
    int gridSize = (width + TILE_SIZE - 1) / TILE_SIZE;
    int blockSize = TILE_SIZE;
    convolution<<<gridSize, blockSize>>>(d_N, d_M, d_P, width);
    cudaMemcpy(P, d_P, size, cudaMemcpyDeviceToHost);
    cudaFree(d_N);
    cudaFree(d_M);
    cudaFree(d_P);
}

int main() {
    int width;
    printf("Enter the width:\n");
    scanf("%d", &width);
    int* N = (int*)malloc(sizeof(int) * width);
    int* M = (int*)malloc(sizeof(int) * MASK_WIDTH);  
    int* P = (int*)malloc(sizeof(int) * width);
    printf("Enter the elements in the array:\n");
    for (int i = 0; i < width; i++)
        scanf("%d", &N[i]);
    printf("Enter the elements in the mask:\n");
    for (int i = 0; i < MASK_WIDTH; i++)  
        scanf("%d", &M[i]);
    performConvolution(N, M, P, width);
    printf("Result:\n");
    for (int i = 0; i < width; i++)
        printf("%d ", P[i]);
    free(M);
    free(N);
    free(P);
}
