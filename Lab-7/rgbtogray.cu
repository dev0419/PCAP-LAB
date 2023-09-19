
#include<cuda_runtime.h>
#include<stdio.h>
#include<stdlib.h>
__global__ void rgbtogray(unsigned char* grayImg,unsigned char* rgbImg,int height,int width){
    int col = threadIdx.x + blockDim.x*blockIdx.x;
    int row = threadIdx.y + blockDim.y*blockIdx.y;
    if (row < height && col < width){
        int grayOffset = row*width + col;
        int rbgOffset = grayOffset*3;
        unsigned char r = rgbImg[rbgOffset];
        unsigned char g = rgbImg[rbgOffset + 1];
        unsigned char b = rgbImg[rbgOffset + 2];
        grayImg[grayOffset] = 0.21f * r + 0.72f * g + 0.07f * b;
    }
}

void RgbtoGray(unsigned char* grayImg,unsigned char* rgbImg,int height,int width){
    int rgb_size = height*width*3*sizeof(unsigned char);
    int gray_size = height*width*sizeof(unsigned char);
    unsigned char* d_rgb, *d_gray;
    for (int i = 0; i < width*height*3; i++)
        rgbImg[i] = (i % 256);
    
    printf("Original values:\n");
    for (int i = 0; i < height; i++){
        for (int j = 0; j < width; j++){
            int idx = i*width + j;
            printf("(%u %u %u) ", rgbImg[idx], rgbImg[idx + 1],rgbImg[idx + 2]);   
        }
        printf("\n");
    }

    cudaMalloc((void**)&d_gray,gray_size);
    cudaMalloc((void**)&d_rgb,rgb_size);
    cudaMemcpy(d_rgb,rgbImg,rgb_size,cudaMemcpyHostToDevice);
    
    dim3 blockSize(32,32);
    dim3 gridSize((width + blockSize.x - 1)/blockSize.x,(height + blockSize.y - 1)/blockSize.y);
    rgbtogray<<<gridSize,blockSize>>>(d_gray,d_rgb,height,width);
    cudaMemcpy(grayImg,d_gray,gray_size,cudaMemcpyDeviceToHost);
    printf("Converted grayscale values:\n");
    for (int i = 0; i < height; i++){
        for (int j = 0; j < width; j++){
            int idx = i*width + j;
            printf("%u ",grayImg[idx]);
        }
        printf("\n");
    }
}

int main(){
    int height = 3, width = 3;
    unsigned char* gray = (unsigned char*)malloc(height*width*sizeof(unsigned char));
    unsigned char* rgb = (unsigned char*)malloc(height*width*3*sizeof(unsigned char));
    RgbtoGray(gray,rgb,height,width);
    return 0;
}
