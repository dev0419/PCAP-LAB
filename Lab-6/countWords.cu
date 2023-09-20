#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cuda_runtime.h"

#define n 1024
#define nw 1024

__global__ void countWords(char* a, char* w, int* start_index, int* len_words, unsigned int l_w, unsigned int* d_count) {
    int id = threadIdx.x;
    if (len_words[id] < l_w) {
        return;
    }
    int start = start_index[id];
    for (int i = 0; i < l_w; i++) {
        if (a[start + i] != w[i])
            return;
    }
    atomicAdd(d_count, 1);
}

int main() {
    char a[n], w[n];
    char* d_A, * d_W;
    int start_index[nw], len_words[nw];
    int* d_start_index, * d_len_words;
    int len;
    unsigned int count = 0, * d_count, result;
    
    printf("Enter the string:\n");
    scanf(" %[^\n]s", a);

    printf("Enter the word to be searched:\n");
    scanf(" %[^\n]s", w);
    len = strlen(a);
    int i = 0, k = 0;
    
    while (i < len) {
        while (i < len && a[i] == ' ')
            i++;
        start_index[k] = i;
        while (i < len && a[i] != ' ')
            i++;
        len_words[k] = i - start_index[k];
        k++;
    }

    if (len_words[k - 1] == 0)
        k--;
    
    cudaMalloc((void**)&d_A, strlen(a) * sizeof(char));
    cudaMalloc((void**)&d_W, strlen(w) * sizeof(char));
    cudaMalloc((void**)&d_start_index, k * sizeof(int));
    cudaMalloc((void**)&d_len_words, k * sizeof(int));
    cudaMalloc((void**)&d_count, sizeof(unsigned int));
    
    cudaMemcpy(d_A, a, strlen(a) * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_W, w, strlen(w) * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_start_index, start_index, k * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_len_words, len_words, k * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_count, &count, sizeof(unsigned int), cudaMemcpyHostToDevice);
    
    countWords<<<1, k>>>(d_A, d_W, d_start_index, d_len_words, strlen(w), d_count);

    cudaMemcpy(&result, d_count, sizeof(unsigned int), cudaMemcpyDeviceToHost);
    
    printf("Total occurrences of %s: %u\n", w, result);
    
    cudaFree(d_A); cudaFree(d_W); cudaFree(d_start_index); cudaFree(d_len_words); cudaFree(d_count);

    return 0;
}
