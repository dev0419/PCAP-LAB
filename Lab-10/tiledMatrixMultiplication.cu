#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#define BLOCK_WIDTH 2
#define TILE_WIDTH 2
#define WIDTH 4

__global__ void matMul(int* a,int* b,int* c){
    __shared__ int MD[TILE_WIDTH][TILE_WIDTH];
    __shared__  int ND[TILE_WIDTH][TILE_WIDTH];
    int m;
    int bx = blockIdx.x;
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int row = by*TILE_WIDTH + ty;
    int col = bx*TILE_WIDTH + tx;
    int pval = 0;
    for(m = 0;m < WIDTH/TILE_WIDTH;m++){
        MD[tx][ty] = a[row*WIDTH + m * TILE_WIDTH+tx];
        ND[tx][ty] = b[(m*TILE_WIDTH + ty)* WIDTH+col];
        __syncthreads();
        for(int k = 0;k < TILE_WIDTH;k++){
            pval += MD[ty][k]*ND[k][tx];
        }

        __syncthreads();
    }
    c[row*WIDTH + col] = pval;
}


int main(){
    int* matA,*matB,*matC,*d_a,*d_b,*d_c;
    matA = (int*)malloc(WIDTH*WIDTH*sizeof(int));
    printf("Enter the elements of 4x4 matA:\n");
    for(int i = 0;i < WIDTH*WIDTH;i++)
      scanf("%d",&matA[i]);
    matB = (int*)malloc(WIDTH*WIDTH*sizeof(int));
    printf("Enter the elements of 4x4 matB:\n");
    for(int i = 0;i < WIDTH*WIDTH;i++)
      scanf("%d",&matB[i]);
    matC = (int*)malloc(WIDTH*WIDTH*sizeof(int));
    cudaMalloc((void**)&d_a,sizeof(int)*WIDTH*WIDTH);
    cudaMalloc((void**)&d_b,sizeof(int)*WIDTH*WIDTH);
    cudaMalloc((void**)&d_c,sizeof(int)*WIDTH*WIDTH);
    cudaMemcpy(d_a,matA,sizeof(int)*WIDTH*WIDTH,cudaMemcpyHostToDevice);
    cudaMemcpy(d_b,matB,sizeof(int)*WIDTH*WIDTH,cudaMemcpyHostToDevice);
    dim3 grid_conf(WIDTH/TILE_WIDTH,WIDTH/TILE_WIDTH);
    dim3 block_conf(TILE_WIDTH,TILE_WIDTH);
    matMul<<<grid_conf,block_conf>>>(d_a,d_b,d_c);
    cudaMemcpy(matC,d_c,sizeof(int)*WIDTH*WIDTH,cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for(int i = 0;i < WIDTH;i++){
      for(int j = 0;j < WIDTH;j++){ 
        printf("%d ",matC[i*WIDTH + j]);
      }
      printf("\n");
    }
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(matA);
    free(matB);
    free(matC);
    return 0;
}
