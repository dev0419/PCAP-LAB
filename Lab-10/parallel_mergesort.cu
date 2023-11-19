#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>

__device__ int co_rank(int k,int* a,int m,int* b,int n){
    int i = min(k,m);
    int j = k - i;
    int i_low = max(0,k - n);
    int j_low = max(0,k - m);
    bool flag = true;
    int delta;
    while(flag){
        if(i > 0 && j < n && a[i - 1] > b[j]){
            delta = ((i - i_low + 1) >> 1);
            j_low = j;
            i -=  delta;
            j += delta;
        } else if(i < m && j > 0 && b[j - 1] >= a[i]){
            delta = ((j - j_low + 1) >> 1);
            i_low = i;
            j -= delta;
            i += delta;
        }
        else{
            flag = false;
        }
    }
    return i;
}

__device__ void merge_sequential(int* a,int m,int* b,int n,int* c){
    int i = 0;
    int j = 0;
    int k = 0;
    while(i < m && j < n){
        if(a[i] < b[j]){
            c[k++] = a[i++]; 
        } else if(b[j] < a[i]){
            c[k++] = b[j++];
        }
    } while(i < m){
        c[k++] = a[i++];
    } while(j < n){
        c[k++] = b[j++];
    }
}

__global__ void merge(int* a,int m,int* b,int n,int* c){
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    int total = m + n;
    int elementsPerThread = ceil((double)total/(gridDim.x*blockDim.x));
    int k_curr = tid*elementsPerThread;
    int k_next = min((int)(tid + 1)*elementsPerThread,total);
    int i_curr = co_rank(k_curr,a,m,b,n);
    int i_next = co_rank(k_next,a,m,b,n);
    int j_curr = k_curr - i_curr;
    int j_next = k_next - i_next;
    if(tid < total){
        merge_sequential(a + i_curr,i_next - i_curr,b + j_curr,j_next - j_curr,c + k_curr);
    }
}

int main(){
    int m,n,*a,*b,*c,*da,*db,*dc;
    printf("Enter size m,n:\n");
    scanf("%d %d",&m,&n);
    a = (int*)malloc(sizeof(int)*m);
    b = (int*)malloc(sizeof(int)*n);
    c = (int*)malloc(sizeof(int)*(m+n));
    printf("Enter the sorted array a:\n");
    for(int i = 0;i < m;i++)
        scanf("%d",&a[i]);
    printf("Enter the sorted array b:\n");
    for(int i = 0;i < n;i++)
        scanf("%d",&b[i]);
    cudaMalloc((void**)&da,sizeof(int)*m);
    cudaMalloc((void**)&db,sizeof(int)*n);
    cudaMalloc((void**)&dc,sizeof(int)*(m+n));
    cudaMemcpy(da,a,sizeof(int)*m,cudaMemcpyHostToDevice);
    cudaMemcpy(db,b,sizeof(int)*n,cudaMemcpyHostToDevice);
    int blockSize = 256;
    int gridSize = (int)ceil((double)(m + n)/blockSize);
    merge<<<gridSize,blockSize>>>(da,m,db,n,dc);
    cudaMemcpy(c,dc,sizeof(int)*(m+n),cudaMemcpyDeviceToHost);
    printf("Resulting array:\n");
    for(int i = 0;i < (m+n);i++)
        printf("%d ",c[i]);
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
    return 0;
}
