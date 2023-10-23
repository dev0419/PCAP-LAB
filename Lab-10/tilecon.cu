#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define THREADS_PER_BLOCK 256
#define MASK_WIDTH 3
#define WIDTH 8

__global__ void conv1D(int* input, int* mask, int* output, int width) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int half_mask = MASK_WIDTH / 2;
    int value = 0;

    for (int i = -half_mask; i <= half_mask; i++) {
        int idx_shifted = idx + i;
        if (idx_shifted >= 0 && idx_shifted < width) {
            value += input[idx_shifted] * mask[i + half_mask];
        }
    }

    output[idx] = value;
}

int main() {
    int* input, * mask, * output, * d_input, * d_mask, * d_output;
    int input_size = WIDTH * sizeof(int);
    int mask_size = MASK_WIDTH * sizeof(int);

    // Allocate and initialize input and mask arrays
    input = (int*)malloc(input_size);
    mask = (int*)malloc(mask_size);

    printf("Enter %d values for the input array:\n", WIDTH);
    for (int i = 0; i < WIDTH; i++) {
        scanf("%d", &input[i]);
    }

    printf("Enter %d values for the mask:\n", MASK_WIDTH);
    for (int i = 0; i < MASK_WIDTH; i++) {
        scanf("%d", &mask[i]);
    }

    output = (int*)malloc(input_size);

    // Allocate device memory
    cudaMalloc((void**)&d_input, input_size);
    cudaMalloc((void**)&d_mask, mask_size);
    cudaMalloc((void**)&d_output, input_size);

    // Copy data from host to device
    cudaMemcpy(d_input, input, input_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_mask, mask, mask_size, cudaMemcpyHostToDevice);

    // Launch the convolution kernel
    int num_blocks = (WIDTH + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
    conv1D<<<num_blocks, THREADS_PER_BLOCK>>>(d_input, d_mask, d_output, WIDTH);

    // Copy the result back to the host
    cudaMemcpy(output, d_output, input_size, cudaMemcpyDeviceToHost);

    // Print the result
    printf("Result:\n");
    for (int i = 0; i < WIDTH; i++) {
        printf("%d ", output[i]);
    }
    printf("\n");

    // Free device and host memory
    cudaFree(d_input);
    cudaFree(d_mask);
    cudaFree(d_output);
    free(input);
    free(mask);
    free(output);

    return 0;
}
