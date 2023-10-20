#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<cuda_runtime.h>
__global__ void replace(int m,int n,int* mat){
    int row = threadIdx.x + blockDim.x*blockIdx.x;
    if(row < m){
        for(int col = 0;col < n;col++){
            mat[row*n+col] = pow(mat[row*n + col], row + 1);
        }
    }
}

int main(){
    int m,n;
    printf("enter the dimensions:\n");
    scanf("%d %d",&m,&n);
    int* mat = (int*)malloc(sizeof(int)*m*n);
    printf("Enter the elements:\n");
    for(int i = 0;i < m*n;i++)
      scanf("%d",&mat[i]);
    int* d_mat;
    cudaMalloc((void**)&d_mat,sizeof(int)*m*n);
    cudaMemcpy(d_mat,mat,sizeof(int)*m*n,cudaMemcpyHostToDevice);
    replace<<<1,m>>>(m,n,d_mat);
    cudaMemcpy(mat,d_mat,sizeof(int)*m*n,cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for(int i = 0; i < m;i++){
        for(int j = 0;j < n;j++){
            printf("%d ", mat[i*n+j]);
        }
        printf("\n");
    }
    cudaFree(d_mat);
    free(mat);
}
