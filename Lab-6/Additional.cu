#include <stdio.h>
#include <cuda.h>
// Scenario (a): Every string is produced parallely
__global__ void copyStr_a(char* str, char* rstr, int len, int n) {
    int tid = threadIdx.x + blockIdx.x * blockDim.x;

    for (int i = 0; i < len; i++) {
        rstr[tid * len + i] = str[i];
    }
}

// Scenario (b): Every thread will generate the same character n no of times
__global__ void copyStr_b(char* str, char* rstr, int len, int n) {
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    int pos = tid * len;

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < len; j++) {
            rstr[pos + j] = str[j];
        }
        pos += len;
    }
}

int main() {
    char str[] = "hello";
    int n = 3;
    int len = strlen(str);
    char *d_str, *d_rstr;
    char rstr[len * n];

    cudaMalloc((void**)&d_str, len * sizeof(char));
    cudaMalloc((void**)&d_rstr, len * n * sizeof(char));

    cudaMemcpy(d_str, str, len * sizeof(char), cudaMemcpyHostToDevice);

    int blockSize = 256;
    int numBlocks = (len * n + blockSize - 1) / blockSize;

    int choice;
    printf("Choose scenario (a or b):\n");
    printf("a) Every string is produced parallely\n");
    printf("b) Every thread will generate the same character n no of times\n");
    scanf("%c", &choice);

    if (choice == 'a') {
        copyStr_a<<<numBlocks, blockSize>>>(d_str, d_rstr, len, n);
    } else if (choice == 'b') {
        copyStr_b<<<numBlocks, blockSize>>>(d_str, d_rstr, len, n);
    } else {
        printf("Invalid choice\n");
        return 1;
    }

    cudaMemcpy(rstr, d_rstr, len * n * sizeof(char), cudaMemcpyDeviceToHost);

    for (int i = 0; i < len * n; i++) {
        printf("%c", rstr[i]);
    }

    cudaFree(d_str);
    cudaFree(d_rstr);

    return 0;
}
