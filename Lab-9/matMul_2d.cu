#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#define TILE_WIDTH 2
#define WIDTH 4

__global__ void matMul(int* a,int* b,int* c){
    int row = blockIdx.y*blockDim.y + threadIdx.y;
    int col = blockIdx.x*blockDim.x + threadIdx.x;
    int res = 0;
    if(row < WIDTH && col < WIDTH){
        for(int k = 0;k < WIDTH;k++){
            res = a[row*WIDTH + k]*b[k*WIDTH + col];
        }
        c[row*WIDTH + col] = res;
    }
}

int main(){
    int* a,*b,*c,*da,*db,*dc;
    a = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    b = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    c = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    printf("Enter 4x4 matrix a:\n");
    for(int i = 0;i < WIDTH*WIDTH;i++)
        scanf("%d",&a[i]);
    printf("Enter 4x4 matrix b:\n");
    for(int i = 0;i < WIDTH*WIDTH;i++)
        scanf("%d",&b[i]);
    cudaMalloc((void**)&da,sizeof(int)*WIDTH*WIDTH);
    cudaMalloc((void**)&db,sizeof(int)*WIDTH*WIDTH);
    cudaMalloc((void**)&dc,sizeof(int)*WIDTH*WIDTH);
    cudaMemcpy(da,a,sizeof(int)*WIDTH*WIDTH,cudaMemcpyHostToDevice);
    cudaMemcpy(db,b,sizeof(int)*WIDTH*WIDTH,cudaMemcpyHostToDevice);
    dim3 grid_conf(WIDTH/TILE_WIDTH,WIDTH/TILE_WIDTH);
    dim3 block_conf(TILE_WIDTH,TILE_WIDTH);
    matMul<<<grid_conf,block_conf>>>(da,db,dc);
    cudaMemcpy(c,dc,sizeof(int)*WIDTH*WIDTH,cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for(int i = 0; i < WIDTH;i++){
        for(int j = 0; j < WIDTH;j++){
            printf("%d ",c[i*WIDTH + j]);       
        }
        printf("\n");
    }
    return 0;
}
