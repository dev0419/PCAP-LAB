#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>

__global__ void convolution(int* N, int* M, int* P, int width, int mask_width) {
    int tid = threadIdx.x;
    int start = tid - mask_width/2;
    int pval = 0;

    for (int i = 0; i < mask_width; i++) {
        if (start + i >= 0 && start + i < width) {
            pval += N[start + i] * M[i];
        }
    }

    P[tid] = pval;
    __syncthreads();
}

void performConvolution(int* N, int* M, int* P,int width,int mask_width) {
    int* d_N, *d_M, *d_P;
    int size = width * sizeof(int);
    cudaMalloc((void**)&d_N, size);
    cudaMalloc((void**)&d_M, mask_width * sizeof(int));  
    cudaMalloc((void**)&d_P, size);
    cudaMemcpy(d_N, N, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_M, M, mask_width * sizeof(int),cudaMemcpyHostToDevice);  
    convolution<<<1,width>>>(d_N, d_M, d_P, width,mask_width);
    cudaMemcpy(P, d_P, size, cudaMemcpyDeviceToHost);
    cudaFree(d_N);
    cudaFree(d_M);
    cudaFree(d_P);
}

int main() {
    int width,mask_width;
    printf("Enter the width:\n");
    scanf("%d", &width);
    printf("Enter the mask width:\n");
    scanf("%d",&mask_width);
    int* N = (int*)malloc(sizeof(int) * width);
    int* M = (int*)malloc(sizeof(int) * mask_width);  
    int* P = (int*)malloc(sizeof(int) * width);
    printf("Enter the elements in the array:\n");
    for (int i = 0; i < width; i++)
        scanf("%d", &N[i]);
    printf("Enter the elements in the mask:\n");
    for (int i = 0; i < mask_width; i++)  
        scanf("%d", &M[i]);
    performConvolution(N, M, P, width,mask_width);
    printf("Result:\n");
    for (int i = 0; i < width; i++)
        printf("%d ", P[i]);
    free(M);
    free(N);
    free(P);
    return 0;
}


