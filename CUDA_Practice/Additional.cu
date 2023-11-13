#include <stdio.h>
#include <cuda_runtime.h>

_global_ void repeatCharacters(const char *A, const int *B, char *output, int elements, int *offsets) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < elements) {
        int repeats = B[idx];
        char character = A[idx];
        int outputPos = offsets[idx];

        for (int j = 0; j < repeats; ++j) {
            output[outputPos + j] = character;
        }
    }
}

int main() {
    int rows, cols;
    char *A;
    int *B;
    char *output;
    int totalSize, totalOutputSize = 0;

    // Ask user for matrix dimensions
    printf("Enter the number of rows and columns for matrices A and B: ");
    scanf("%d %d", &rows, &cols);

    totalSize = rows * cols;

    // Allocate host memory
    A = (char *)malloc(totalSize * sizeof(char));
    B = (int *)malloc(totalSize * sizeof(int));
    int *offsets = (int *)malloc(totalSize * sizeof(int));

    // Initialize host matrices A and B with user input
    printf("Enter the elements of matrix A:\n");
    for (int i = 0; i < totalSize; ++i) {
        scanf(" %c", &A[i]); // Note the space before %c to catch any previous whitespaces
    }

    printf("Enter the elements of matrix B:\n");
    for (int i = 0; i < totalSize; ++i) {
        scanf("%d", &B[i]);
        if (i == 0)
            offsets[i] = 0;
        else
            offsets[i] = offsets[i - 1] + B[i - 1];
        totalOutputSize += B[i];
    }

    // Allocate output string
    output = (char *)malloc((totalOutputSize + 1) * sizeof(char)); // +1 for the null-terminator
    output[totalOutputSize] = '\0'; // Null-terminate the string

    // Allocate device memory
    char *d_A;
    int *d_B, *d_offsets;
    char *d_output;
    cudaMalloc((void **)&d_A, totalSize * sizeof(char));
    cudaMalloc((void **)&d_B, totalSize * sizeof(int));
    cudaMalloc((void **)&d_output, totalOutputSize * sizeof(char));
    cudaMalloc((void **)&d_offsets, totalSize * sizeof(int));

    // Copy matrices A and B from host to device
    cudaMemcpy(d_A, A, totalSize * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, totalSize * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_offsets, offsets, totalSize * sizeof(int), cudaMemcpyHostToDevice);

    // Define block size and grid size
    dim3 threadsPerBlock(256);
    dim3 blocksPerGrid((totalSize + threadsPerBlock.x - 1) / threadsPerBlock.x);

    // Launch CUDA kernel
    repeatCharacters<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_output, totalSize, d_offsets);

    // Copy output string from device to host
    cudaMemcpy(output, d_output, totalOutputSize * sizeof(char), cudaMemcpyDeviceToHost);

    // Print the resulting output string
    printf("Output String: %s\n", output);

    // Cleanup
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_output); cudaFree(d_offsets);
    free(A); free(B); free(output); free(offsets);

    return 0;
}
