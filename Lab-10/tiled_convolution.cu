#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
__global__ void convolution(int* N,int* M,int* P,int width,int mask_width){
    __shared__ int value;
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    int start = tid - (mask_width/2);
    P[tid] = 0;
    for(int i = 0;i < mask_width;i++){
        if(tid == 0)
            value = M[i];
        __syncthreads();
        if(start + i >= 0 && start + i < width)
            P[tid] += N[start+i]*value;  
        __syncthreads();    
    }
}

void performConvolution(int* N,int* M,int* P,int width,int mask_width){
    int* d_N,*d_M,*d_P;
    int size = width*sizeof(int), mask_size = mask_width*sizeof(int);
    cudaMalloc((void**)&d_N,size);
    cudaMalloc((void**)&d_M,mask_size);
    cudaMalloc((void**)&d_P,size);
    cudaMemcpy(d_N,N,size,cudaMemcpyHostToDevice);
    cudaMemcpy(d_M,M,mask_size,cudaMemcpyHostToDevice);
    convolution<<<1,width>>>(d_N,d_M,d_P,width,mask_width);
    cudaMemcpy(P,d_P,size,cudaMemcpyDeviceToHost);
    cudaFree(d_P);
    cudaFree(d_M);
    cudaFree(d_N);
}

int main(){
    int* N,*M,*P,width,mask_width;
    printf("Enter the width:\n");
    scanf("%d",&width);
    printf("Enter the mask width:\n");
    scanf("%d",&mask_width);
    int size = width*sizeof(int), mask_size = mask_width*sizeof(int);
    N = (int*)malloc(size);
    M = (int*)malloc(mask_size);
    P = (int*)malloc(size);
    printf("Enter array elements:\n");
    for(int i = 0;i < width;i++)
        scanf("%d",&N[i]);
    printf("Enter the mask elements:\n");
    for(int i = 0;i < mask_width;i++)
        scanf("%d",&M[i]);
    performConvolution(N,M,P,width,mask_width);
    printf("Result:\n");
    for(int i = 0;i < width;i++)
        printf("%d ",P[i]);
    free(P);
    free(M);
    free(N);
    return 0;
}
