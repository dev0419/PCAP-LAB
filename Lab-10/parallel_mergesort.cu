#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

__device__ int co_rank(int k, int* a, int m, int* b, int n){
    int i = min(k, m);
    int j = k - i;
    int i_low = max(0, k - n);
    int j_low = max(0, k - m);
    int delta;
    bool flag = true;
    while(flag){
        if(i > 0 && j < n && a[i - 1] > b[j]){
            delta = ((i - i_low + 1) >> 1);
            j_low = j;
            i -= delta;
            j += delta;
        } else if(j > 0 && i < m && b[j - 1] >= a[i]){
            delta = ((j - j_low + 1) >> 1);
            i_low = i;
            i += delta;
            j -= delta; 
        } else{
            flag = false;
        }
    }
    return i;
}

__device__ void merge_sequential(int* a, int a_count, int* b, int b_count, int* c){
    int i = 0, j = 0, k = 0;
    while(i < a_count && j < b_count){
        c[k++] = (a[i] <= b[j]) ? a[i++] : b[j++];
    }
    while(i < a_count){
        c[k++] = a[i++];
    }
    while(j < b_count){
        c[k++] = b[j++];
    }
}

__global__ void merge_kernel(int* a, int m, int* b, int n, int* c){
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int total = m + n;
    int k_curr = tid * ceilf((float)total / (blockDim.x * gridDim.x));
    int k_next = min((int)((tid + 1) * ceilf((float)total / (blockDim.x * gridDim.x))), total);
    int i_curr = co_rank(k_curr, a, m, b, n);
    int i_next = co_rank(k_next, a, m, b, n);
    int j_curr = k_curr - i_curr;
    int j_next = k_next - i_next;
    if(tid < total) {
        merge_sequential(a + i_curr, i_next - i_curr, b + j_curr, j_next - j_curr, c + k_curr);
    }
}

int main(){
    int m, n;
    int *a, *b, *c;
    int *da, *db, *dc;
    printf("Enter the size of array A (m) and array B (n):\n");
    scanf("%d %d", &m, &n);
    a = (int*)malloc(m * sizeof(int));
    b = (int*)malloc(n * sizeof(int));
    c = (int*)malloc((m + n) * sizeof(int));
    printf("Enter the sorted elements for array A:\n");
    for(int i = 0; i < m; i++)
        scanf("%d", &a[i]);
    printf("Enter the sorted elements for array B:\n");
    for(int i = 0; i < n; i++)
        scanf("%d", &b[i]);
  
    cudaMalloc((void**)&da, m * sizeof(int));
    cudaMalloc((void**)&db, n * sizeof(int));
    cudaMalloc((void**)&dc, (m + n) * sizeof(int));
    cudaMemcpy(da, a, m * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(db, b, n * sizeof(int), cudaMemcpyHostToDevice);
    int blockSize = 256;
    int gridSize = (int)ceil((float)(m + n) / blockSize);
    merge_kernel<<<gridSize, blockSize>>>(da, m, db, n, dc);
    cudaMemcpy(c, dc, (m + n) * sizeof(int), cudaMemcpyDeviceToHost);
    printf("Resulting merged array:\n");
    for(int i = 0; i < (m + n); i++)
        printf("%d ", c[i]);
    printf("\n");
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
    free(a);
    free(b);
    free(c);
    return 0;
}
