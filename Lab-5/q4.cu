#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void sineAngle(float* angles, float* sineVal, int n) {
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    if (idx < n) {
        float angle = angles[idx];
        sineVal[idx] = sin(angle); // Assign the sine value to the output array
    }
}

void printArray(float* a, int n) {
    for (int i = 0; i < n; i++)
        printf("%f ", a[i]);
    printf("\n");
}

void sinAngle(float* angles, float* sineVal, int n) {
    float* d_Angle, *d_sinVal;
    int size = n * sizeof(float);
    cudaMalloc((void**)&d_Angle, size);
    cudaMalloc((void**)&d_sinVal, size);
    cudaMemcpy(d_Angle, angles, size, cudaMemcpyHostToDevice);
    printf("Angles:\n");
    printArray(angles, n);
    sineAngle<<<ceil((float)n / 256), 256>>>(d_Angle, d_sinVal, n);
    cudaMemcpy(sineVal, d_sinVal, size, cudaMemcpyDeviceToHost);
    printf("Sine Values are:\n");
    printArray(sineVal, n);
    cudaFree(d_Angle);
    cudaFree(d_sinVal);
}

int main() {
    float* angles, *sinVal;
    int n;
    printf("Enter the size of the angles array:\n");
    scanf("%d", &n);
    int size = n * sizeof(float);
    angles = (float*)malloc(size);
    sinVal = (float*)malloc(size);
    printf("Enter the angles in the array:\n");
    for (int i = 0; i < n; i++)
        scanf("%f", &angles[i]);
    sinAngle(angles, sinVal, n);
    free(angles);
    free(sinVal);
    return 0;
}
