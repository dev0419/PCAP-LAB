#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// CUDA kernel to count characters in parallel
__global__ void countCharacters(char* str, int* count, int length) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < length) {
        if (str[tid] != '\0') {
            atomicAdd(count, 1);
        }
    }
}

int main() {
    char hostStr[1000]; // Maximum string length is 1000 characters
    int count = 0;

    // Input: Read a string from the user
    printf("Enter a string: ");
    fgets(hostStr, sizeof(hostStr), stdin);
    hostStr[strlen(hostStr) - 1] = '\0'; // Remove the newline character

    int length = strlen(hostStr);

    // Device variables
    char* devStr;
    int* devCount;

    // Allocate memory on the GPU
    cudaMalloc((void**)&devStr, length * sizeof(char));
    cudaMalloc((void**)&devCount, sizeof(int));

    // Copy the string from host to device
    cudaMemcpy(devStr, hostStr, length * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(devCount, &count, sizeof(int), cudaMemcpyHostToDevice);

    // Define block size and grid size
    int blockSize = 256;
    int gridSize = (length + blockSize - 1) / blockSize;

    // Launch the kernel
    countCharacters<<<gridSize, blockSize>>>(devStr, devCount, length);

    // Copy the result back from the device
    cudaMemcpy(&count, devCount, sizeof(int), cudaMemcpyDeviceToHost);

    // Free device memory
    cudaFree(devStr);
    cudaFree(devCount);

    // Output the character count
    printf("Number of characters: %d\n", count);

    return 0;
}
