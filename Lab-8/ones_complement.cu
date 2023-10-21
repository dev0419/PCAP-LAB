#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
__global__ void complement(int* a,int* b,int m,int n){
    int i = threadIdx.y + blockDim.y*blockIdx.y;
    int j = threadIdx.x + blockDim.x*blockIdx.x;
    int num,binary_num=0,base=1,mask;
    if(i < m && j < n){
        if(i == 0||i == m - 1||j == 0||j == n - 1){
            b[i*n+j] = a[i*n+j];
        } else{
            num = a[i*n + j];
            binary_num = 0;
            mask = ~0; 
            while(num & mask){
                mask <<= 1;
            }
            num = ~num & ~mask;
            while(num > 0){
                binary_num += (num % 2) * base;
                num /= 2;
                base *= 10;
            }
            b[i*n+j] = binary_num;
        }
    }
}

int main(){
    int* a,*b,m,n;
    printf("Enter m,n:\n");
    scanf("%d %d",&m,&n);
    a = (int*)malloc(sizeof(int)*m*n);
    b = (int*)malloc(sizeof(int)*m*n);
    printf("Enter the matrix:\n");
    for(int i = 0;i < m;i ++){
        for(int j = 0;j < n;j++){
            scanf("%d",&a[i*n+j]);
        }
    }
    int* d_a,*d_b;
    cudaMalloc((void**)&d_a,sizeof(int)*m*n);
    cudaMalloc((void**)&d_b,sizeof(int)*m*n);
    cudaMemcpy(d_a,a,sizeof(int)*m*n,cudaMemcpyHostToDevice);
    dim3 block_size(16,16);
    dim3 num_blocks((n + block_size.x - 1)/block_size.x,(m + block_size.y - 1)/block_size.y);
    complement<<<num_blocks,block_size>>>(d_a,d_b,m,n);
    cudaMemcpy(b,d_b,sizeof(int)*m*n,cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for(int i = 0;i < m;i++){
        for(int j = 0;j < n;j++){
            printf("%d ",b[i*n + j]);
        }
        printf("\n");
    }
    cudaFree(d_a);
    cudaFree(d_b);
    free(a);
    free(b);
}
