__global__ void merge_kernel(int* a, int m, int* b, int n, int* c){
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int total = m + n;
    int num_threads = blockDim.x * gridDim.x;

    int elements_per_thread = total / num_threads;
    int k_curr = tid * elements_per_thread;
    int k_next;

    if (tid == num_threads - 1) { // Check if this is the last thread
        // Last thread takes all remaining elements
        k_next = total;
    } else {
        // Otherwise, calculate the end index as usual
        k_next = (tid + 1) * elements_per_thread;
    }

    // ...rest of your merge_kernel function...
}
