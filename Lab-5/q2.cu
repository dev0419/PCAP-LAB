#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

__global__
void vecAddKernel_2(float * A, float * B, float * C, int n) {
  int idx = threadIdx.x + blockIdx.x * blockDim.x;
  if (idx < n) C[idx] = A[idx] + B[idx];
}

void vecAdd(float * A, float * B, float * C, int n) {
  int size = n * sizeof(float);
  float *d_A, *d_B, *d_C;
  cudaMalloc((void ** ) & d_A, size);
  cudaMalloc((void ** ) & d_B, size);
  cudaMalloc((void ** ) & d_C, size);
  
  cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);

  printf("A: ");
  for (int i = 0; i < n; i++)
    printf("%f, ", A[i]);
  printf("\n");

  printf("B: ");
  for (int i = 0; i < n; i++)
    printf("%f, ", B[i]);
  printf("\n\n");



  vecAddKernel_2<<<(n + 255) / 256, 256>>>(d_A, d_B, d_C, n);
  cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
  printf("A+B (from 2 kernel): ");

  for (int i = 0; i < n; i++)
    printf("%f, ", C[i]);
  printf("\n");

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);
}

int main() {
  float * h_A, * h_B, * h_C;
  int n = 5, size = n * sizeof(float);
  h_A = (float * ) malloc(size);
  h_B = (float * ) malloc(size);
  h_C = (float * ) malloc(size);

  for (int i = 0; i < n; i++) {
    h_A[i] = (i + 1) * 10;
    h_B[i] = i + 1;
  }
  vecAdd(h_A, h_B, h_C, n);
  return 0;
}