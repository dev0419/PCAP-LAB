#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define N 1024

__global__ void charCount(char* a, unsigned int* d_count) {
    int i = threadIdx.x;
    if (a[i] == 'a')
        atomicAdd(d_count, 1);
}

int main() {
    char a[N], *d_A;
    unsigned int count = 0, *d_count, result;
    
    printf("Enter string:\n");
    scanf("%[^\n]s", a); // Changed from "%[^/n]s" to "%[^\n]s" for correct input
    
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
    
    cudaMalloc((void**)&d_A, strlen(a) * sizeof(char)); // Changed "strlen(A)" to "strlen(a)"
    cudaMalloc((void**)&d_count, sizeof(unsigned int));
    cudaMemcpy(d_A, a, strlen(a) * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_count, &count, sizeof(unsigned int), cudaMemcpyHostToDevice);
    
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess)
        printf("Error 1: %s\n", cudaGetErrorString(err));
    
    charCount<<<1, strlen(a)>>>(d_A, d_count);
    
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop); "
    
    cudaMemcpy(&result, d_count, sizeof(unsigned int), cudaMemcpyDeviceToHost); 
    
    printf("Total occurrences of 'a': %u\n", result);
    printf("Time Taken: %f\n", elapsedTime);
    
    cudaFree(d_A);
    cudaFree(d_count);
    
    return 0;
}

