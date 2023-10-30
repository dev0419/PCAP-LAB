#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#define MASK_SIZE 3

__constant__ int mask[MASK_SIZE];

__global__ void convolution(int* N,int* P,int width,int mask_width){
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    if(tid < width){
        int res = 0;
        int start = tid  - mask_width/2;
        for(int i = 0;i < mask_width;i++){
            if(start + i >= 0 && start + i < width){
                res += N[start + i]*mask[i];
            }
        }
        P[tid] = res;
    }
}

void performConvolution(int* N,int* M,int* P,int width,int mask_width){
    int* d_N,*d_P;
    int size = sizeof(int)*width;
    int mask_size = sizeof(int)*mask_width;
    cudaMalloc((void**)&d_N,size);
    cudaMalloc((void**)&d_P,size);
    cudaMemcpy(d_N,N,size,cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(mask,M,mask_size);
    int blockSize = 256;
    int gridSize = (width + blockSize - 1)/ blockSize;
    convolution<<<gridSize,blockSize>>>(d_N,d_P,width,mask_width);
    cudaMemcpy(P,d_P,size,cudaMemcpyDeviceToHost);
    cudaFree(d_N);
    cudaFree(d_P);
}

int main(){
    int* N,*M,*P,width,mask_width;
    printf("Enter the width:\n");
    scanf("%d",&width);
    printf("Enter the mask width:\n");
    scanf("%d",&mask_width);
    int size = sizeof(int)*width;
    int mask_size = sizeof(int)*mask_width;
    N = (int*)malloc(size);
    M = (int*)malloc(mask_size);
    P = (int*)malloc(size);
    printf("Enter the array elements:\n");
    for(int i = 0;i < width;i++)
        scanf("%d",&N[i]);
    printf("Enter the mask elements:\n");
    for(int i = 0; i < mask_width;i++)
        scanf("%d",&M[i]);
    performConvolution(N,M,P,width,mask_width);
    printf("Result:\n");
    for(int i = 0;i < width;i++)
        printf("%d ", P[i]);
    free(N);
    free(M);
    free(P);
    return 0;
}
