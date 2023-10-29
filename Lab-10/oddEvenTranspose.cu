#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
__global__ void odd(int* a, int n){
    int tid = threadIdx.x + blockIdx.x*blockDim.x;
    if(tid % 2 != 0 && tid + 1 < n){
        if(a[tid] > a[tid + 1]){
            int temp = a[tid];
            a[tid] = a[tid+1];
            a[tid + 1] = temp;
        }
    }
}

__global__ void even(int* a, int n){
    int tid = threadIdx.x + blockIdx.x*blockDim.x;
    if(tid % 2 == 0 && tid + 1 < n){
        if(a[tid] > a[tid + 1]){
            int temp = a[tid];
            a[tid] = a[tid+1];
            a[tid + 1] = temp;
        }
    }
}

int main(){
    int* a,*da,n;
    printf("Enter n:\n");
    scanf("%d",&n);
    a = (int*)malloc(sizeof(int)*n);
    printf("Enter the array elements:\n");
    for(int i = 0;i < n;i++)
        scanf("%d",&a[i]);
    cudaMalloc((void**)&da,n*sizeof(int));
    cudaMemcpy(da,a,n*sizeof(int),cudaMemcpyHostToDevice);
    for(int i = 0; i < n/2;i++){
        odd<<<1,n>>>(da,n);
        even<<<1,n>>>(da,n);
    }
    cudaMemcpy(a,da,sizeof(int)*n,cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for(int i = 0;i < n;i++)
        printf("%d ",a[i]);
    cudaFree(da);
    free(a);
    return 0;
}
