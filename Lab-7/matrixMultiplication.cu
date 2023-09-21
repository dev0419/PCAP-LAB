%%cuda --name prg8.cu
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void multiply_rowWise(int* a, int* b, int* c, int wa, int wb) {
    int ridA = threadIdx.x;
    int sum;
    for (int cidB = 0; cidB < wb; cidB++) {
        sum = 0;
        for (int k = 0; k < wa; k++) 
            sum += (a[ridA * wa + k] * b[k * wb + cidB]);
        c[ridA * wb + cidB] = sum;
    }
}

__global__ void multiply_Colwise(int* a, int* b, int* c, int ha, int wa) {
    int cidB = threadIdx.x;
    int wb = blockDim.x;

    for (int ridA = 0; ridA < ha; ridA++) {
        int sum = 0; 
        for (int k = 0; k < wa; k++) 
            sum += (a[ridA * wa + k] * b[k * wb + cidB]); 
        c[ridA * wb + cidB] = sum;
    }
}

__global__ void multiplyKernel(int* a, int* b, int* c, int wa, int wb) {
    int ridA = threadIdx.y; 
    int cidB = threadIdx.x; 
    int sum = 0;
    for (int k = 0; k < wa; k++) 
        sum += (a[ridA * wa + k] * b[k * wb + cidB]);
    c[ridA * wb + cidB] = sum;
}

void printMatrix(int* a,int row,int col){
    for(int i = 0;i < row;i++){
        for(int j = 0;j < col;j++){
          printf("%d ", a[i*col + j]);
        }
        printf("\n");
    }
}


void Multiply(int* a, int* b, int* c, int wa, int wb, int ha) {
    int* d_A, * d_B, * d_C; 
    int size = ha * wb * sizeof(int);
    cudaMalloc((void**)&d_A, size);
    cudaMalloc((void**)&d_B, size);
    cudaMalloc((void**)&d_C, size);
    cudaMemcpy(d_A, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, b, size, cudaMemcpyHostToDevice);

    multiply_rowWise<<<1, ha>>>(d_A, d_B, d_C, wa, wb);
    cudaMemcpy(c, d_C, size, cudaMemcpyDeviceToHost);

    printf("Result of row-wise matrix multiplication:\n");
    printMatrix(c,ha,wb);

    multiply_Colwise<<<1, wb>>>(d_A, d_B, d_C, ha, wa);
    cudaMemcpy(c, d_C, size, cudaMemcpyDeviceToHost);
    printf("\nResult of column-wise matrix multiplication:\n");
    printMatrix(c,ha,wb);

    dim3 blockSize(wb, ha);
    multiplyKernel<<<1, blockSize>>>(d_A, d_B, d_C, wa, wb);
    cudaMemcpy(c, d_C, size, cudaMemcpyDeviceToHost);

    printf("\nResult of matrix multiplication element-wise:\n");
    printMatrix(c,ha,wb);

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

    Multiply(a, b, c, wa, wb, ha);
    free(a);
    free(b);
    free(c);
    return 0;
}
