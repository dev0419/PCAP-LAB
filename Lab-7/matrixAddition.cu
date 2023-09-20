
#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>

__global__ void addRow(int* a,int* b,int* c,int wa,int wb){
    int ridA = threadIdx.x;
    for (int cidB = 0; cidB < wb; cidB++)
        c[ridA*wb + cidB] = a[ridA*wb + cidB] + b[ridA*wb + cidB];
}

__global__ void addCol(int* a,int* b,int* c, int ha,int hb){
    int cidB = threadIdx.x;
    for (int ridA = 0; ridA < ha; ridA++)
        c[ridA*hb + cidB] = a[ridA*hb + cidB] + b[ridA*hb + cidB]; 
}

__global__ void addElement(int* a, int* b, int* c,int wa,int wb){
    int row = threadIdx.y;
    int col = threadIdx.x;
    c[row*wb + col] = (a[row*wb + col] + b[row*wb + col]);
}

void printMatrix(int* a, int row, int col){
    for (int i = 0; i < row; i++){
        for (int j = 0; j < col; j++){
            printf("%d ",a[i*col + j]);
        }
        printf("\n");
    }
}

void addMat(int* a,int* b,int* c,int wa,int wb,int ha, int hb){
    int* d_A,*d_B,*d_C;
    int size = ha*wb*sizeof(int);
    cudaMalloc((void**)&d_A,size);
    cudaMalloc((void**)&d_B,size);
    cudaMalloc((void**)&d_C,size);
    cudaMemcpy(d_A,a,size,cudaMemcpyHostToDevice);
    cudaMemcpy(d_B,b,size,cudaMemcpyHostToDevice);
    addRow<<<1,ha>>>(d_A,d_B,d_C,wa,wb);
    cudaMemcpy(c,d_C,size,cudaMemcpyDeviceToHost);
    printf("Result after row-wise addition:\n");
    printMatrix(c,ha,wb);
    addCol<<<1,wb>>>(d_A,d_B,d_C,ha,hb);
    cudaMemcpy(c,d_C,size,cudaMemcpyDeviceToHost);
    printf("Result after column-wise addition:\n");
    printMatrix(c,ha,wb);
    addElement<<<1,wb>>>(d_A,d_B,d_C,wa,wb);
    printf("Result after element-wise addition:\n");
    printMatrix(c,ha,wb);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
}

int main(){
    int* a,*b,*c,m1,n1,m2,n2;
    printf("Enter the rows and columns of matrix a:\n");
    scanf("%d %d",&m1,&n1);
    a = (int*)malloc(m1*n1*sizeof(int));
    printf("Enter the elements of matrix A:\n");
    for (int i = 0; i < m1; i++)
        for (int j = 0; j < n1; j++)
            scanf("%d",&a[i*n1 + j]);
    printf("Enter the rows and columns of matrix b:\n");
    scanf("%d %d",&m2,&n2);
    b = (int*)malloc(m2*n2*sizeof(int));
    printf("Enter the elements of matrix b:\n");
    for (int i = 0; i < m2; i++)
        for (int j = 0; j < n2; j++)
            scanf("%d",&b[i*n2 + j]);
    c = (int*)malloc(m1*n2*sizeof(int));
    addMat(a,b,c,n1,n2,m1,m2);
    free(a);
    free(b);
    free(c);
    return 0;
}

