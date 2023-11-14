#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include<cuda_runtime.h>
__device__ int co_rank(int k,int* a,int m,int* b,int n){
    int i = min(k,m);
    int j = min(k,n);
    int i_low = max(0,k-m);
    int j_low = max(0,k-n);
    int delta;
    bool flag = true;
    while(flag){
        if(i > 0 && j < n && a[i - 1] > b[j]){
            delta = ((i - i_low + 1) >> 1);
            j_low = j;
            j += delta;
            i -= delta;
        } else if(j > 0 && i < m &&  b[j] > a[i - 1]){
            delta = ((j - j_low + 1) >> 1);
            i_low = i;
            j -= delta;
            i += delta;
        } else{
            flag = false;
        }
    }
    return i;
}

__device__ void merge_sequential(int* a,int m,int* b,int n,int* c){
    int i = 0;
    int j = 0;
    int k = 0;
    while((i < m) && (j < n)){
        if(a[i] < b[j]){
            c[k++] = a[i++];
        } else{
            c[k++] = b[j++];
        }
    } while(i < m){
        c[k++] = a[i++];
    } while(j < n){
        c[k++] = b[j++];
    }
}

__global__ void merge_kernel(int* a,int m,int* b,int n,int* c){
    int tid  = blockIdx.x*blockDim.x + threadIdx.x;
    int total = m + n;
    int k_curr = tid*ceilf((float)total/(gridDim.x*blockDim.x));
    int k_next = min((int)((tid+1)*ceilf((float)total/(gridDim.x*blockDim.x))),total);
    int i_curr = co_rank(k_curr,a,m,b,n);
    int i_next = co_rank(k_next,a,m,b,n);
    int j_curr = k_curr - i_curr;
    int j_next = k_next - i_next; 
    if(tid < total){
        merge_sequential(a + i_curr,i_next - i_curr,b + j_curr,j_curr - j_next,c + k_curr);
    }
}

int main(){
    int m,n,*a,*b,*c,*da,*db,*dc;
    printf("Enter the size m and n:\n");
    scanf("%d %d",&m,&n);
    a = (int*)malloc(sizeof(int)*m);
    b = (int*)malloc(sizeof(int)*n);
    c = (int*)malloc(sizeof(int)*(m + n));
    printf("Enter the sorted array A:\n");
    for(int i = 0;i < m;i++){
        scanf("%d",&a[i]);
    }
    printf("Enter the sorted array B:\n");
    for(int i = 0;i < n;i++){
        scanf("%d",&b[i]);
    }
    cudaMalloc((void**)&da,sizeof(int)*m);
    cudaMalloc((void**)&db,sizeof(int)*n);
    cudaMalloc((void**)&dc,sizeof(int)*(m + n));
    cudaMemcpy(da,a,sizeof(int)*m,cudaMemcpyHostToDevice);
    cudaMemcpy(db,b,sizeof(int)*n,cudaMemcpyHostToDevice);
    int blockSize = 256;
    int gridSize = (int)ceil((m + n)/blockSize);
    merge_kernel<<<gridSize,blockSize>>>(da,m,db,n,dc);
    cudaMemcpy(c,dc,sizeof(int)*(m + n),cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for(int i = 0;i < (m + n);i++){
        printf("%d ",c[i]);
    }
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
    free(a);
    free(b);
    free(c);
    return 0;
}
