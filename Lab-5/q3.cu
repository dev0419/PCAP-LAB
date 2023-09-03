#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

__global__ void convolutionKernel(float *N, float *M, float *P, int width, int mask_width) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < width) {
        int half_mask_width = mask_width / 2;
        float sum = 0.0;

        for (int j = 0; j < mask_width; j++) {
            int idx = tid - half_mask_width + j;
            if (idx >= 0 && idx < width) {
                sum += N[idx] * M[j];
            }
        }

        P[tid] = sum;
    }
}

int main() {
    int width = 10;
    int mask_width = 3;

    float *h_N = (float *)malloc(width * sizeof(float));
    float *h_M = (float *)malloc(mask_width * sizeof(float));
    float *h_P = (float *)malloc(width * sizeof(float));

    for (int i = 0; i < width; i++) {
        h_N[i] = i + 1;
    }

    for (int i = 0; i < mask_width; i++) {
        h_M[i] = 0.5;
    }

    float *d_N, *d_M, *d_P;
    cudaMalloc((void **)&d_N, width * sizeof(float));
    cudaMalloc((void **)&d_M, mask_width * sizeof(float));
    cudaMalloc((void **)&d_P, width * sizeof(float));

    cudaMemcpy(d_N, h_N, width * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_M, h_M, mask_width * sizeof(float), cudaMemcpyHostToDevice);

    int blockSize = 256;
    int numBlocks = (width + blockSize - 1) / blockSize;

    convolutionKernel<<<numBlocks, blockSize>>>(d_N, d_M, d_P, width, mask_width);

    cudaMemcpy(h_P, d_P, width * sizeof(float), cudaMemcpyDeviceToHost);

    printf("Input Array (N): ");
    for (int i = 0; i < width; i++)
        printf("%.2f, ", h_N[i]);
    printf("\n");

    printf("Mask Array (M): ");
    for (int i = 0; i < mask_width; i++)
        printf("%.2f, ", h_M[i]);
    printf("\n");

    printf("Result Array (P) after Convolution: ");
    for (int i = 0; i < width; i++)
        printf("%.2f, ", h_P[i]);
    printf("\n");

    cudaFree(d_N);
    cudaFree(d_M);
    cudaFree(d_P);

    free(h_N);
    free(h_M);
    free(h_P);

    return 0;
}
