#include<stdio.h>
#include<cuda_runtime.h>
#include<string.h>
#include<stdlib.h>
#include<string.h>
__global__ void rgbtogray(unsigned char* grayImg,unsigned char* rgbImg, int width, int height){
    int col = threadIdx.x + blockDim.x*blockIdx.x;
    int row = threadIdx.y + blockDim.y*blockIdx.y;
    if (row < height && col < width){
        int grayOffset =  row*width + col;
        int rgbOffset = grayOffset*3;
        unsigned char r = rgbImg[rgbOffset];
        unsigned char g = rgbImg[rgbOffset + 1];
        unsigned char b = rgbImg[rgbOffset + 2];
        grayImg[grayOffset] = 0.21f*r + 0.72f*g + 0.07f*b; 
    }
}

int main() {
    const int width = 3; 
    const int height = 3;
    unsigned char* rgb = (unsigned char*)malloc(3*height*width*sizeof(unsigned char));
    unsigned char* gray = (unsigned char*)malloc(height*width*sizeof(unsigned char));
    unsigned char* d_rgb,*d_gray;
    for(int i = 0; i < 3*width*height;i++)
        rgb[i] = (i%256);
    
    printf("Original RGB values:\n");
    for(int i = 0; i < height;i++){
        for(int j = 0; j < width; j++){
            int idx = 3*(i*width +j);
            printf("(%u, %u, %u) ",rgb[idx],rgb[idx+1],rgb[idx+2]);
        }
        printf("\n");
    }

    cudaMalloc((void**)&d_rgb,3*width*height*sizeof(unsigned char));
    cudaMalloc((void**)&d_gray,width*height*sizeof(unsigned char));
    cudaMemcpy(d_rgb,rgb,3*width*height*sizeof(unsigned char),cudaMemcpyHostToDevice);
    dim3 blockSize(32,32);
    dim3 gridSize(((width + blockSize.x - 1)/blockSize.x),((height + blockSize.y - 1)/blockSize.y));
    rgbtogray<<<gridSize,blockSize>>>(d_gray,d_rgb,width,height);
    cudaMemcpy(gray,d_gray,height*width*sizeof(unsigned char),cudaMemcpyDeviceToHost);
    printf("converted grayscale values:\n");
    for(int i = 0; i < height;i++){
        for(int j = 0; j < width; j++){
            int idx = i*width + j;
            printf("%u ", gray[idx]);
        }
        printf("\n");
    }
    free(rgb);
    free(gray);
    cudaFree(d_gray);
    cudaFree(d_rgb);
    return 0;
}
