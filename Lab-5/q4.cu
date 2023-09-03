#include <stdio.h>
#include <math.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

// CUDA kernel to calculate sine of angles
__global__ void calculateSine(float *angles, float *sineResults, int numAngles) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < numAngles) {
        sineResults[tid] = sinf(angles[tid]);
    }
}

int main() {
    int numAngles = 10; // Number of angles
    float h_angles[] = {0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5}; // Input angles
    float h_sineResults[numAngles]; // Resultant sine values

    // Device copies of variables angles and sineResults
    float *d_angles, *d_sineResults;

    int size = numAngles * sizeof(float); // Size of the arrays in bytes

    // Allocate space for device copies of angles and sineResults
    cudaMalloc((void **)&d_angles, size);
    cudaMalloc((void **)&d_sineResults, size);

    // Copy input angles from host to device
    cudaMemcpy(d_angles, h_angles, size, cudaMemcpyHostToDevice);

    int blockSize = 256;
    int numBlocks = (numAngles + blockSize - 1) / blockSize;

    // Launch the CUDA kernel to calculate sine values
    calculateSine<<<numBlocks, blockSize>>>(d_angles, d_sineResults, numAngles);

    // Copy the result back to the host
    cudaMemcpy(h_sineResults, d_sineResults, size, cudaMemcpyDeviceToHost);

    // Display the input angles and their corresponding sine values
    printf("Input Angles (in radians):\n");
    for (int i = 0; i < numAngles; i++) {
        printf("%.2f ", h_angles[i]);
    }
    printf("\n\nSine Results:\n");
    for (int i = 0; i < numAngles; i++) {
        printf("%.4f ", h_sineResults[i]);
    }
    printf("\n");

    // Cleanup: Free device memory
    cudaFree(d_angles);
    cudaFree(d_sineResults);

    return 0;
}
