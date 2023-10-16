#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define TILE_WIDTH 2
#define WIDTH 4
#define MASK_WIDTH 3

__global__ void convolution(int *input, int *mask, int *output) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

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

    printf("Enter the elements of (4x4) input matrix:\n");
    input = (int*)malloc(sizeof(int) * WIDTH * WIDTH);
    for (int i = 0; i < WIDTH * WIDTH; i++) {
        scanf("%d", &input[i]);
    }

    printf("Enter the elements of (3x3) mask matrix:\n");
    mask = (int*)malloc(sizeof(int) * MASK_WIDTH * MASK_WIDTH);
    for (int i = 0; i < MASK_WIDTH * MASK_WIDTH; i++) {
        scanf("%d", &mask[i]);
    }

    output = (int*)malloc(sizeof(int) * WIDTH * WIDTH);
    cudaMalloc((void**)&d_input, sizeof(int) * WIDTH * WIDTH);
    cudaMalloc((void**)&d_mask, sizeof(int) * MASK_WIDTH * MASK_WIDTH);
    cudaMalloc((void**)&d_output, sizeof(int) * WIDTH * WIDTH);

    cudaMemcpy(d_input, input, sizeof(int) * WIDTH * WIDTH, cudaMemcpyHostToDevice);
    cudaMemcpy(d_mask, mask, sizeof(int) * MASK_WIDTH * MASK_WIDTH, cudaMemcpyHostToDevice);

    dim3 grid_conf(WIDTH / TILE_WIDTH, WIDTH / TILE_WIDTH);
    dim3 block_conf(TILE_WIDTH, TILE_WIDTH);

    convolution<<<grid_conf, block_conf>>>(d_input, d_mask, d_output);

    cudaMemcpy(output, d_output, sizeof(int) * WIDTH * WIDTH, cudaMemcpyDeviceToHost);

    printf("Result of Convolution:\n");
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < WIDTH; j++) {
            printf("%6d ", output[i * WIDTH + j]);
        }
        printf("\n");
    }

    cudaFree(d_input);
    cudaFree(d_mask);
    cudaFree(d_output);
    free(input);
    free(mask);
    free(output);

    return 0;
}
