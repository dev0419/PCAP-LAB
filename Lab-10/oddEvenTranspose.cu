#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void odd(int *a, int n) {
    int tid = threadIdx.x * 2;
    if (tid + 1 < n) {
        if (a[tid] > a[tid + 1]) {
            int temp = a[tid];
            a[tid] = a[tid + 1];
            a[tid + 1] = temp;
        }
    }
}

__global__ void even(int *a, int n) {
    int tid = threadIdx.x * 2 + 1;
    if (tid + 1 < n) {
        if (a[tid] > a[tid + 1]) {
            int temp = a[tid];
            a[tid] = a[tid + 1];
            a[tid + 1] = temp;
        }
    }
}

int main() {
    int *a, n, *d_a;
    printf("Enter the size of the array:\n");
    scanf("%d", &n);
    printf("Enter the array elements:\n");
    a = (int*)malloc(sizeof(int) * n);
    for (int i = 0; i < n; i++) {
        scanf("%d", &a[i]);
    }
    cudaMalloc((void**)&d_a, sizeof(int) * n);
    cudaMemcpy(d_a, a, sizeof(int) * n, cudaMemcpyHostToDevice);
    for (int i = 0; i < n / 2; i++) {
        odd<<<1, n / 2>>>(d_a, n);
        even<<<1, n / 2>>>(d_a, n);
    }
    cudaMemcpy(a, d_a, sizeof(int) * n, cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for (int i = 0; i < n; i++)
        printf("%d ", a[i]);
    cudaFree(d_a);
    free(a);
    return 0;
}
