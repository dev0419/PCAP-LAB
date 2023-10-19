#include<cuda_runtime.h>
#include<stdio.h>
#include<stdlib.h>

__global__ void csr(int num_rows,int* data,int* col_index,int* row_ptr,int* x,int* y){
    int row = blockDim.x*blockIdx.x + threadIdx.x;
    if(row < num_rows){
        int res = 0;
        int row_start = row_ptr[row];
        int row_end = row_ptr[row+1];
        for(int i = row_start;i < row_end;i++){
            res += data[i]*x[col_index[i]]; 
        }
        y[row] = res;
    }
}

void csr(int n,int m,int non_zero_count,int* data,int* col_index,int* row_ptr,int* x, int* y){
    int* d_data,*d_col_index,*d_row_ptr,*d_x,*d_y;
    cudaMalloc((void**)&d_data,sizeof(int)*non_zero_count);
    cudaMalloc((void**)&d_x,sizeof(int)*m);
    cudaMalloc((void**)&d_y,sizeof(int)*n);
    cudaMalloc((void**)&d_row_ptr,sizeof(int)*(n+1));
    cudaMalloc((void**)&d_col_index,sizeof(int)*non_zero_count);
    cudaMemcpy(d_data,data,sizeof(int)*non_zero_count,cudaMemcpyHostToDevice);
    cudaMemcpy(d_x,x,sizeof(int)*m,cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_index,col_index,sizeof(int)*non_zero_count,cudaMemcpyHostToDevice);
    cudaMemcpy(d_row_ptr,row_ptr,sizeof(int)*(n + 1),cudaMemcpyHostToDevice);
    csr<<<1,n>>>(n,d_data,d_col_index,d_row_ptr,d_x,d_y);
    cudaMemcpy(y,d_y,sizeof(int)*m,cudaMemcpyDeviceToHost);
    printf("Result:\n");
    for(int i = 0; i < m;i++)
      printf("%d ",y[i]);
    printf("\n");
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_data);
    cudaFree(d_row_ptr);
    cudaFree(d_col_index);
}

int main(){
    int m,n,non_zero_count=0;
    printf("Enter the dimensions:\n");
    scanf("%d %d", &n,&m);
    int* mat = (int*)malloc(sizeof(int)*n*m);
    printf("Enter a sparse matrix:\n");
    for(int i = 0;i < n;i++){
        for(int j = 0; j < m; j++){
            int k = i*n+j;
            scanf("%d",&mat[k]);
            if(mat[k] != 0){
                non_zero_count += 1; 
            }
        }
    }
    int* x = (int*)malloc(sizeof(int)*m);
    int* y = (int*)malloc(sizeof(int)*n);
    int* row_ptr = (int*)calloc((m+1),sizeof(int));
    int* col_index = (int*)malloc(sizeof(int)*non_zero_count);
    int* data = (int*)malloc(sizeof(int)*non_zero_count); 
    printf("Enter the column vector:\n");
    for(int i = 0; i < m;i++){
        scanf("%d",&x[i]);
    }
    int id = 0; 
    for(int i = 0;i < n;i++){
        for(int j = 0;j < m;j++){
            int k = i*n + j;
            if(mat[k] != 0){
                data[id] = mat[k];
                col_index[id] = j;
                id += 1;
            }
            row_ptr[i + 1] = id; 
        }   
    }
    csr(n,m,non_zero_count,data,col_index,row_ptr,x,y);
    return 0;
}
