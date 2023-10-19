#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#define WIDTH 4
#define TILE_WIDTH 2

__global__ void matMul(int* a, int* b, int* c) {
    int row = blockDim.y * blockIdx.y + threadIdx.y;
    int col = blockDim.x * blockIdx.x + threadIdx.x;

    // Check if the thread is within the matrix dimensions
    if (row < WIDTH && col < WIDTH) {
        int sum = 0;
        for (int k = 0; k < WIDTH; k++) {
            sum += a[row * WIDTH + k] * b[k * WIDTH + col];
        }
        c[row * WIDTH + col] = sum;
    }
}

int main() {
    int* matA, *matB, *matC;
    int *da, *db, *dc;

    matA = (int*)malloc(sizeof(int) * WIDTH * WIDTH);
    printf("Enter the elements of the 4x4 matrix A:\n");
    for (int i = 0; i < WIDTH * WIDTH; i++)
        scanf("%d", &matA[i]);

    matB = (int*)malloc(sizeof(int) * WIDTH * WIDTH);
    printf("Enter the elements of the 4x4 matrix B:\n"); // Fixed the prompt
    for (int i = 0; i < WIDTH * WIDTH; i++)
        scanf("%d", &matB[i]);

    matC = (int*)malloc(sizeof(int) * WIDTH * WIDTH);

    cudaMalloc((void**)&da, sizeof(int) * WIDTH * WIDTH);
    cudaMalloc((void**)&db, sizeof(int) * WIDTH * WIDTH);
    cudaMalloc((void**)&dc, sizeof(int) * WIDTH * WIDTH);

    cudaMemcpy(da, matA, sizeof(int) * WIDTH * WIDTH, cudaMemcpyHostToDevice);
    cudaMemcpy(db, matB, sizeof(int) * WIDTH * WIDTH, cudaMemcpyHostToDevice);

    dim3 grid_conf(WIDTH / TILE_WIDTH, WIDTH / TILE_WIDTH);
    dim3 block_conf(TILE_WIDTH, TILE_WIDTH);

    matMul<<<grid_conf, block_conf>>>(da, db, dc);

    cudaMemcpy(matC, dc, sizeof(int) * WIDTH * WIDTH, cudaMemcpyDeviceToHost);

    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < WIDTH; j++) {
            printf("%d ", matC[i * WIDTH + j]);
        }
        printf("\n");
    }

    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);

    free(matA);
    free(matB);
    free(matC);

    return 0;
}
