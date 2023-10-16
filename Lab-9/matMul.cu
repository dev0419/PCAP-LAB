#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#define TILE_WIDTH 2
#define WIDTH 4

__device__ int getTid(){
    int blockRow = blockIdx.y;
    int blockCol = blockIdx.x;
    int rowInBlock = threadIdx.y;
    int colInBlock = threadIdx.x;
    int globalRow = blockRow * blockDim.y + rowInBlock;
    int globalCol = blockCol * blockDim.x + colInBlock;
    return (globalRow*WIDTH + globalCol);
}

__global__ void matMul(int* a,int* b, int* c){
    int row = blockIdx.y*blockDim.y + threadIdx.y;
    int col = blockIdx.x*blockDim.x + threadIdx.x;
    int sum = 0;
    for (int k = 0; k < WIDTH; k++)
        sum += a[row*WIDTH + k] * b[k*WIDTH + col];
    c[row*WIDTH + col] = sum;
} 

int main(){
    int* matA,*matB,*matC,*da,*db,*dc;
    printf("Enter the elements of (4x4) matrix A:\n");
    matA = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    for (int i = 0; i < WIDTH*WIDTH; i++)
        scanf("%d",&matA[i]);
    printf("Enter the elements of (4x4) matrix B:\n");
    matB = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    for (int i = 0; i < WIDTH*WIDTH; i++)
        scanf("%d",&matB[i]);
    matC = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    cudaMalloc((void**) &da,sizeof(int)*WIDTH*WIDTH);
    cudaMalloc((void**) &db,sizeof(int)*WIDTH*WIDTH);
    cudaMalloc((void**) &dc,sizeof(int)*WIDTH*WIDTH);
    cudaMemcpy(da,matA,sizeof(int)*WIDTH*WIDTH,cudaMemcpyHostToDevice);
    cudaMemcpy(db,matB,sizeof(int)*WIDTH*WIDTH,cudaMemcpyHostToDevice);
    dim3 grid_conf(WIDTH/TILE_WIDTH,WIDTH/TILE_WIDTH);
    dim3 block_conf(TILE_WIDTH,TILE_WIDTH);
    matMul<<<grid_conf,block_conf>>>(da,db,dc);
    cudaMemcpy(matC,dc,sizeof(int)*WIDTH*WIDTH,cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for (int i = 0; i < WIDTH; i++){
        for (int j = 0; j < WIDTH; j++){
            printf("%6d ",matC[i*WIDTH + j]);
        }
        printf("\n");
    }
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
    return 0;
}
