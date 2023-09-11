#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <string.h>

__global__ void createRS(char* d_S, char* d_RS, int length) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    int start = (idx * (2 * length - idx + 1)) / 2;

    for (int i = 0; i < length - idx; i++) {
        d_RS[start + i] = d_S[i];
    }
}


int main() {
    char S[100];
    printf("Enter the string: ");
    scanf("%99s", S);

    int length = strlen(S);
    int totalLength = (length * (length + 1)) / 2;  // Sum of the first 'length' natural numbers
    char* RS = (char*)malloc(totalLength + 1);
    RS[totalLength] = '\0';

    char *d_S, *d_RS;

    cudaMalloc((void**)&d_S, length * sizeof(char));
    cudaMalloc((void**)&d_RS, totalLength * sizeof(char));

    cudaMemcpy(d_S, S, length * sizeof(char), cudaMemcpyHostToDevice);

    int blockSize = length;
    int gridSize = 1;
    createRS <<<gridSize, blockSize>>> (d_S, d_RS, length);

    cudaMemcpy(RS, d_RS, totalLength * sizeof(char), cudaMemcpyDeviceToHost);

    printf("Output string RS: %s\n", RS);

    free(RS);
    cudaFree(d_S);
    cudaFree(d_RS);

    return 0;
}