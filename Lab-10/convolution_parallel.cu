#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#define MASK_SIZE 3
__constant__ int mask[MASK_SIZE];

__global__ void convolution(int* n,int width,int* p,int mask_width){
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    int start = tid - (mask_width/2);
    int res = 0;
    if(tid < width){
        for(int i = 0;i < mask_width;i++){
            if(start + i < width){
                res += n[start + i]*mask[i];
            }
        }
        p[tid] = res;
    }
}

int main(){
    int width,mask_width,*n,*m,*p,*dn,*dp;
    printf("Enter the width:\n");
    scanf("%d",&width);
    printf("Enter the mask width:\n");
    scanf("%d",&mask_width);
    n = (int*)malloc(sizeof(int)*width);
    m = (int*)malloc(sizeof(int)*mask_width);
    p = (int*)malloc(sizeof(int)*width);
    printf("Enter the array n:\n");
    for(int i = 0;i < width;i++)
        scanf("%d",&n[i]);
    printf("Enter the mask:\n");
    for(int i = 0;i < mask_width;i++)
        scanf("%d",&m[i]);
    cudaMalloc((void**)&dn,sizeof(int)*width);
    cudaMalloc((void**)&dp,sizeof(int)*width);
    cudaMemcpy(dn,n,sizeof(int)*width,cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(mask,m,sizeof(int)*mask_width);
    int blockSize = 256;
    int gridSize = (width + blockSize - 1)/blockSize;
    convolution<<<gridSize,blockSize>>>(dn,width,dp,mask_width);
    cudaMemcpy(p,dp,sizeof(int)*width,cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for(int i = 0;i < width;i++)
        printf("%d ",p[i]);
    cudaFree(dn);
    cudaFree(dp);
    free(n);
    free(p);
    return 0;
}
