#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#define TILE_WIDTH 2
#define WIDTH 4

__global__ void matMul(int* a,int* b,int* c){
    __shared__ int MD[TILE_WIDTH][TILE_WIDTH];
    __shared__ int ND[TILE_WIDTH][TILE_WIDTH];
    int bx = blockIdx.x;
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int row = by*TILE_WIDTH + ty;
    int col = bx*TILE_WIDTH + tx;
    int pval = 0;
    int m;
    for(m = 0;m < WIDTH/TILE_WIDTH;m++){
        MD[tx][ty] = a[row*WIDTH + m*TILE_WIDTH + tx];
        ND[tx][ty] = b[m*TILE_WIDTH+ ty*WIDTH + col];
        __syncthreads();
    }
    for(int k = 0;k < TILE_WIDTH;k++){
        pval += MD[ty][k] * ND[k][tx];
    }
    __syncthreads();
    c[row*WIDTH + col] = pval;
}

int main(){
    int* a,*b,*c,*da,*db,*dc;
    a = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    b = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    c = (int*)malloc(sizeof(int)*WIDTH*WIDTH);
    printf("Enter the 4x4 matrix a:\n");
    for(int i = 0;i < WIDTH*WIDTH;i++)
        scanf("%d",&a[i]);
    printf("Enter the 4x4 matrix b:\n");
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
    for(int i = 0;i < WIDTH;i++){
        for(int j = 0;j < WIDTH;j++){
            printf("%d ",c[i*WIDTH + j]);
        }
        printf("\n");
    }
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
    free(a);
    free(b);
    free(c);
    return 0;
}
