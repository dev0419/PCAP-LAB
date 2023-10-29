#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#define TILE_WIDTH 2 
#define WIDTH 4
__global__ void matMul(int* a,int* b,int* c){
    int row = blockIdx.y*blockDim.y + threadIdx.y;
    int col = blockIdx.x*blockDim.x + threadIdx.x;
    int pval = 0;
    if(row < WIDTH && col < WIDTH){
        for(int k = 0;k < WIDTH;k++)
            pval += a[row*WIDTH + k]*b[k*WIDTH + col];
        c[row*WIDTH + col] = pval;
    }
}

void perform_matMul(int* a,int* b,int* c){
    int* da,*db,*dc,size;
    size = sizeof(int)*WIDTH*WIDTH;
    cudaMalloc((void**)&da,size);
    cudaMalloc((void**)&db,size);
    cudaMalloc((void**)&dc,size);
    cudaMemcpy(da,a,size,cudaMemcpyHostToDevice);
    cudaMemcpy(db,b,size,cudaMemcpyHostToDevice);
    dim3 grid_conf(WIDTH/TILE_WIDTH,WIDTH/TILE_WIDTH);
    dim3 block_conf(WIDTH,WIDTH);
    matMul<<<grid_conf,block_conf>>>(da,db,dc);
    cudaMemcpy(c,dc,size,cudaMemcpyDeviceToHost);
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
}

int main(){
    int* a,*b,*c;
    a = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    b = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    c = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    printf("Enter 4x4 matrix A:\n");
    for(int i = 0;i < WIDTH*WIDTH;i++)
        scanf("%d",&a[i]);
    printf("Enter 4x4 matrix B:\n");
    for(int i = 0;i < WIDTH*WIDTH;i++)
        scanf("%d",&b[i]);
    perform_matMul(a,b,c);
    printf("Result:\n");
    for(int i = 0;i < WIDTH;i++){
        for(int j = 0;j < WIDTH;j++){
            printf("%d ",c[i*WIDTH + j]);
        }
        printf("\n");
    }
    free(a);
    free(b);
    free(c);
    return 0;
}
