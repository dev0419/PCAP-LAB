%%cuda --name prg3.cu

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

// Define the kernel to perform matrix multiplication row-wise
__global__ void multiply_rowWise(int* a, int* b, int* c, int wa, int wb) {
    int ridA = threadIdx.x;
    int sum;

    for (int cidB = 0; cidB < wb; cidB++) {
        sum = 0;

        for (int k = 0; k < wa; k++) {
            sum += (a[ridA * wa + k] * b[k * wb + cidB]);
        }

        c[ridA * wb + cidB] = sum;
    }
}

// Define the kernel to perform matrix multiplication column-wise
__global__ void multiply_Colwise(int* a, int* b, int* c, int ha, int wa) {
    int cidB = threadIdx.x;
    int wb = blockDim.x; // Corrected variable declaration

    for (int ridA = 0; ridA < ha; ridA++) {
        int sum = 0; // Initialize 'sum' to 0 for each column

        for (int k = 0; k < wa; k++) {
            sum += (a[ridA * wa + k] * b[k * wb + cidB]); // Perform element-wise multiplication and accumulate the result
        }

        c[ridA * wb + cidB] = sum; // Store the accumulated 'sum' in the corresponding position of matrix 'c'
    }
}

// Define the kernel to perform matrix multiplication
__global__ void multiplyKernel(int* a, int* b, int* c, int wa, int wb) {
    int ridA = threadIdx.y; // Use threadIdx.y for rows
    int cidB = threadIdx.x; // Use threadIdx.x for columns

    int sum = 0;

    for (int k = 0; k < wa; k++) {
        sum += (a[ridA * wa + k] * b[k * wb + cidB]);
    }

    c[ridA * wb + cidB] = sum;
}

// Function to perform matrix multiplication
void Multiply(int* a, int* b, int* c, int wa, int wb, int ha) {
    int* d_A, * d_B, * d_C; // Declare device memory pointers

    // Calculate the required memory size
    int size = ha * wb * sizeof(int);

    // Allocate device memory
    cudaMalloc((void**)&d_A, size);
    cudaMalloc((void**)&d_B, size);
    cudaMalloc((void**)&d_C, size);

    // Copy data from host to device
    cudaMemcpy(d_A, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, b, size, cudaMemcpyHostToDevice);

    // Launch the kernel to perform matrix multiplication row-wise
    multiply_rowWise<<<1, ha>>>(d_A, d_B, d_C, wa, wb);

    // Copy the result from device to host
    cudaMemcpy(c, d_C, size, cudaMemcpyDeviceToHost);

    printf("Result of row-wise matrix multiplication:\n");
    for (int i = 0; i < ha; i++) {
        for (int j = 0; j < wb; j++) {
            printf("%d ", c[i * wb + j]);
        }
        printf("\n");
    }

    // Launch the kernel to perform matrix multiplication column-wise
    multiply_Colwise<<<1, wb>>>(d_A, d_B, d_C, ha, wa);

    // Copy the result from device to host
    cudaMemcpy(c, d_C, size, cudaMemcpyDeviceToHost);

    printf("\nResult of column-wise matrix multiplication:\n");
    for (int i = 0; i < ha; i++) {
        for (int j = 0; j < wb; j++) {
            printf("%d ", c[i * wb + j]);
        }
        printf("\n");
    }

    // Launch the kernel to perform matrix multiplication
    dim3 blockSize(wb, ha);
    multiplyKernel<<<1, blockSize>>>(d_A, d_B, d_C, wa, wb);

    // Copy the result from device to host
    cudaMemcpy(c, d_C, size, cudaMemcpyDeviceToHost);

    printf("\nResult of matrix multiplication element-wise:\n");
    for (int i = 0; i < ha; i++) {
        for (int j = 0; j < wb; j++) {
            printf("%d ", c[i * wb + j]);
        }
        printf("\n");
    }

    // Free device memory
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
}

int main() {
    int* a, * b, * c;
    int wa, ha, wb, hb;

    printf("Enter the dimensions of matrix A (ha wa):\n");
    scanf("%d %d", &ha, &wa);
    printf("Enter the dimensions of matrix B (hb wb):\n");
    scanf("%d %d", &hb, &wb);

    // Check if matrix dimensions are compatible for multiplication
    if (wa != hb) {
        printf("Matrix dimensions are not compatible for multiplication.\n");
        return 1;
    }

    // Allocate memory for matrices a, b, and c
    a = (int*)malloc(ha * wa * sizeof(int));
    b = (int*)malloc(hb * wb * sizeof(int));
    c = (int*)malloc(ha * wb * sizeof(int));

    printf("Enter the elements of matrix A:\n");
    for (int i = 0; i < ha; i++) {
        for (int j = 0; j < wa; j++) {
            scanf("%d", &a[i * wa + j]);
        }
    }

    printf("Enter the elements of matrix B:\n");
    for (int i = 0; i < hb; i++) {
        for (int j = 0; j < wb; j++) {
            scanf("%d", &b[i * wb + j]);
        }
    }

    // Call the Multiply function to perform matrix multiplication
    Multiply(a, b, c, wa, wb, ha);

    // Free host memory
    free(a);
    free(b);
    free(c);

    return 0;
}
