#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#define TILE_WIDTH 2 
#define WIDTH 4
#define MASK_WIDTH 3

__global__ void convolution(int* input, int* mask, int* output) {
    int row = threadIdx.y + blockDim.y * blockIdx.y;
    int col = threadIdx.x + blockDim.x * blockIdx.x;
    int sum = 0;
    for (int i = 0; i < MASK_WIDTH; i++) {
        for (int j = 0; j < MASK_WIDTH; j++) {
            int inputRow = row + i - MASK_WIDTH / 2;
            int inputCol = col + j - MASK_WIDTH / 2;
            if (inputRow >= 0 && inputRow < WIDTH && inputCol >= 0 && inputCol < WIDTH) {
                sum += input[inputRow * WIDTH + inputCol] * mask[i * MASK_WIDTH + j];
            }
        }
    }
    output[row * WIDTH + col] = sum;
}

int main() {
    int *input, *mask, *output, *d_input, *d_mask, *d_output;
    input = (int*)malloc(sizeof(int) * WIDTH * WIDTH);
    output = (int*)malloc(sizeof(int) * WIDTH * WIDTH);
    mask = (int*)malloc(sizeof(int) * MASK_WIDTH * MASK_WIDTH);
    printf("Enter the (4x4) input matrix:\n");
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < WIDTH; j++) {
            scanf("%d", &input[i * WIDTH + j]);
        }
    }
    printf("Enter the (3x3) mask matrix:\n");
    for (int i = 0; i < MASK_WIDTH; i++) {
        for (int j = 0; j < MASK_WIDTH; j++) {
            scanf("%d", &mask[i * MASK_WIDTH + j]);
        }
    }
    cudaMalloc((void**)&d_input, WIDTH * WIDTH * sizeof(int));
    cudaMalloc((void**)&d_mask, MASK_WIDTH * MASK_WIDTH * sizeof(int));
    cudaMalloc((void**)&d_output, WIDTH * WIDTH * sizeof(int));
    cudaMemcpy(d_input, input, WIDTH * WIDTH * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_mask, mask, MASK_WIDTH * MASK_WIDTH * sizeof(int), cudaMemcpyHostToDevice);
    dim3 grid_conf(WIDTH / TILE_WIDTH, WIDTH / TILE_WIDTH);
    dim3 block_conf(TILE_WIDTH, TILE_WIDTH);
    convolution<<<grid_conf, block_conf>>>(d_input, d_mask, d_output);
    cudaMemcpy(output, d_output, WIDTH * WIDTH * sizeof(int), cudaMemcpyDeviceToHost);
    printf("After performing convolution:\n");
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < WIDTH; j++) {
            printf("%d ", output[i * WIDTH + j]);
        }
        printf("\n");
    }
    cudaFree(d_input);
    cudaFree(d_mask);
    cudaFree(d_output);
    free(input);
    free(output);
    free(mask);
}
