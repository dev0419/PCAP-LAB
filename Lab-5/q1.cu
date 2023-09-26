#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void vecAddKernel_1a(float* a, float* b, float* c, int n) {
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    if (idx < n)
        c[idx] = a[idx] + b[idx];
}

__global__ void vecAddKernel_1b(float* a, float* b, float* c, int n) {
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    if (idx < n)
        c[idx] = a[idx] + b[idx];
}

__global__ void vecAddKernel_1c(float* a, float* b, float* c, int n) {
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    if (idx < n)
        c[idx] = a[idx] + b[idx];
}

void printArray(float* a, int n) {
    for (int i = 0; i < n; i++)
        printf("%f ", a[i]);
    printf("\n");
}

void vecAdd(float* a, float* b, float* c, int n) {
    float* d_A, *d_B, *d_C;
    int size = n * sizeof(float);
    cudaMalloc((void**)&d_A, size);
    cudaMalloc((void**)&d_B, size);
    cudaMalloc((void**)&d_C, size);
    cudaMemcpy(d_A, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, b, size, cudaMemcpyHostToDevice);
    printf("Array A:\n");
    printArray(a, n);
    printf("Array B:\n");
    printArray(b, n);
    
    vecAddKernel_1a<<<n, 1>>>(d_A, d_B, d_C, n);
    cudaMemcpy(c, d_C, size, cudaMemcpyDeviceToHost);
    printf("A + B (n blocks):\n");
    printArray(c, n);

    vecAddKernel_1b<<<1, n>>>(d_A, d_B, d_C, n);
    cudaMemcpy(c, d_C, size, cudaMemcpyDeviceToHost);
    printf("A + B (n threads):\n");
    printArray(c, n);

    vecAddKernel_1c<<<ceil((float)n / 256), 256>>>(d_A, d_B, d_C, n);
    cudaMemcpy(c, d_C, size, cudaMemcpyDeviceToHost);
    printf("A + B (varying block size and 256 threads):\n");
    printArray(c, n);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
}

int main() {
    float* a, *b, *c;
    int n;
    printf("Enter the size of the array:\n");
    scanf("%d", &n);
    int size = n * sizeof(float);
    a = (float*)malloc(size);
    b = (float*)malloc(size);
    c = (float*)malloc(size);
    printf("Enter the elements in A:\n");
    for (int i = 0; i < n; i++)
        scanf("%f", &a[i]);
    printf("Enter the elements in B:\n");
    for (int i = 0; i < n; i++)
        scanf("%f", &b[i]);
    vecAdd(a, b, c, n);
    free(a); 
    free(b);
    free(c);

    return 0;
}
