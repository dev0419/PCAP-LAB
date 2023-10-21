%%cuda --name prg1.cu 
#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#define TILE_WIDTH 2
#define WIDTH 4
__global__ void matMul(int* a,int* b,int* c){
    int row = threadIdx.y + blockDim.y*blockIdx.y;
    int col = threadIdx.x + blockDim.x*blockIdx.x;
    if(row < WIDTH && col < WIDTH){
        int sum = 0;
        for(int k = 0;k < WIDTH;k++){
            sum += a[row*WIDTH + k]*b[k*WIDTH + col];
        }
        c[row*WIDTH + col] = sum;
    }
}

int main(){
    int* matA,*matB,*matC,*da,*db,*dc;
    matA = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    matB = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    matC = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    printf("Enter the elements of matrix of A (4x4):\n");
    for(int i = 0;i < WIDTH;i++){
        for(int j = 0;j < WIDTH;j++){
            scanf("%d",&matA[i*WIDTH + j]);
        }
    }
    printf("Enter the elements of matrix of B (4x4):\n");
    for(int i = 0;i < WIDTH;i++){
        for(int j = 0;j < WIDTH;j++){
            scanf("%d",&matB[i*WIDTH + j]);
        }
    }
    cudaMalloc((void**)&da,WIDTH*WIDTH*sizeof(int));
    cudaMalloc((void**)&db,WIDTH*WIDTH*sizeof(int));
    cudaMalloc((void**)&dc,WIDTH*WIDTH*sizeof(int));
    cudaMemcpy(da,matA,sizeof(int)*WIDTH*WIDTH,cudaMemcpyHostToDevice);
    cudaMemcpy(db,matB,sizeof(int)*WIDTH*WIDTH,cudaMemcpyHostToDevice);
    dim3 grid_conf(WIDTH/TILE_WIDTH,WIDTH/TILE_WIDTH);
    dim3 block_conf(TILE_WIDTH,TILE_WIDTH);
    matMul<<<grid_conf,block_conf>>>(da,db,dc);
    cudaMemcpy(matC,dc,sizeof(int)*WIDTH*WIDTH,cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for(int i = 0;i < WIDTH;i++){
        for(int j = 0;j < WIDTH;j++){
            printf("%d ",matC[i*WIDTH+j]);
        }
        printf("\n");
    }
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
    free(matA);
    free(matB);
    free(matC);
    return 0;
}
