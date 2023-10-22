#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#define MASK_SIZE 3

__constant__ int mask[MASK_SIZE];

__global__ void convolution(int* input, int* output, int width) {
    int tid = threadIdx.x + blockDim.x * blockIdx.x;
    if (tid < width) {
        int res = 0;
        for (int i = 0; i < MASK_SIZE; i++) {
            int idx = tid - MASK_SIZE / 2 + i;
            if (idx >= 0 && idx < width) {
                res += input[idx] * mask[i];
            }
        }
        output[tid] = res;
    }
}

int main() {
    int width, *input, *output, *d_input, *d_output;
    printf("Enter the width:\n");
    scanf("%d", &width);
    input = (int*)malloc(sizeof(int) * width);
    output = (int*)malloc(sizeof(int) * width);

    printf("Enter the array elements:\n");
    for (int i = 0; i < width; i++)
        scanf("%d", &input[i]);

    printf("Enter the mask elements:\n");
    int maskElements[MASK_SIZE];
    for (int i = 0; i < MASK_SIZE; i++)
        scanf("%d", &maskElements[i]);

    // Copy the mask to constant memory
    cudaMemcpyToSymbol(mask, maskElements, MASK_SIZE * sizeof(int));

    cudaMalloc((void**)&d_input, sizeof(int) * width);
    cudaMalloc((void**)&d_output, sizeof(int) * width);
    cudaMemcpy(d_input, input, sizeof(int) * width, cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (width + blockSize - 1) / blockSize;
    convolution<<<gridSize, blockSize>>>(d_input, d_output, width);
    cudaMemcpy(output, d_output, sizeof(int) * width, cudaMemcpyDeviceToHost);

    printf("Result:\n");
    for (int i = 0; i < width; i++) {
        printf("%d ", output[i]);
    }

    cudaFree(d_input);
    cudaFree(d_output);
    free(input);
    free(output);

    return 0;
}
