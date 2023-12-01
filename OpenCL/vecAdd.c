#include <stdio.h>
#include <stdlib.h>
#include <CL/cl.h>

// OpenCL kernel source code
const char* programSource =
  "__kernel \n"
  "void vecadd(__global int *A, \n"
  "            __global int *B, \n"
  "            __global int *C) \n"
  "{ \n"
  "  int idx = get_global_id(0); \n"
  "  C[idx] = A[idx] + B[idx]; \n"
  "} \n";

int main() {
  // Host data buffers
  int *A = NULL; // Input array
  int *B = NULL; // Input array
  int *C = NULL; // Output array

  // Elements in each array
  const int elements = 2048; // size of host data buffers

  // Compute the size of the data in bytes
  size_t datasize = sizeof(int) * elements;

  // Dynamically allocate space for input/output host data buffers
  A = (int*)malloc(datasize);
  B = (int*)malloc(datasize);
  C = (int*)malloc(datasize);

  // Initialize the input data
  for (int i = 0; i < elements; i++) {
    A[i] = i;
    B[i] = i;
  }

  // OpenCL variables
  cl_int status;

  // STEP 1: Discover and initialize the platforms
  cl_uint num_platforms = 0;
  cl_platform_id *platforms = NULL;
  status = clGetPlatformIDs(0, NULL, &num_platforms);
  platforms = (cl_platform_id*)malloc(num_platforms * sizeof(cl_platform_id));
  status = clGetPlatformIDs(num_platforms, platforms, NULL);

  // STEP 2: Discover and initialize the devices
  cl_uint num_devices = 0;
  cl_device_id *devices = NULL;
  status = clGetDeviceIDs(platforms[0], CL_DEVICE_TYPE_GPU, 0, NULL, &num_devices);
  devices = (cl_device_id*)malloc(num_devices * sizeof(cl_device_id));
  status = clGetDeviceIDs(platforms[0], CL_DEVICE_TYPE_GPU, num_devices, devices, NULL);

  // STEP 3: Create a context
  cl_context context = NULL;
  context = clCreateContext(NULL, num_devices, devices, NULL, NULL, &status);

  // STEP 4: Create a command queue
  cl_command_queue cmdQueue;
  cmdQueue = clCreateCommandQueue(context, devices[0], 0, &status);

  // STEP 5: Create device buffers
  cl_mem bufferA = clCreateBuffer(context, CL_MEM_READ_ONLY, datasize, NULL, &status);
  cl_mem bufferB = clCreateBuffer(context, CL_MEM_READ_ONLY, datasize, NULL, &status);
  cl_mem bufferC = clCreateBuffer(context, CL_MEM_WRITE_ONLY, datasize, NULL, &status);

  // STEP 6: Write host data to device buffers
  status = clEnqueueWriteBuffer(cmdQueue, bufferA, CL_FALSE, 0, datasize, A, 0, NULL, NULL);
  status = clEnqueueWriteBuffer(cmdQueue, bufferB, CL_FALSE, 0, datasize, B, 0, NULL, NULL);

  // STEP 7: Create and compile the program
  cl_program program = clCreateProgramWithSource(context, 1, (const char**)&programSource, NULL, &status);
  status = clBuildProgram(program, num_devices, devices, NULL, NULL, NULL);

  // STEP 8: Create the kernel
  cl_kernel kernel = clCreateKernel(program, "vecadd", &status);

  // STEP 9: Set the kernel arguments
  status = clSetKernelArg(kernel, 0, sizeof(cl_mem), &bufferA);
  status |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &bufferB);
  status |= clSetKernelArg(kernel, 2, sizeof(cl_mem), &bufferC);

  // STEP 10: Configure the work-item structure
  size_t globalWorkSize[1];
  globalWorkSize[0] = elements;

  // STEP 11: Enqueue the kernel for execution
  status = clEnqueueNDRangeKernel(cmdQueue, kernel, 1, NULL, globalWorkSize, NULL, 0, NULL, NULL);

  // STEP 12: Read the output buffer back to the host
  clEnqueueReadBuffer(cmdQueue, bufferC, CL_TRUE, 0, datasize, C, 0, NULL, NULL);

  // Verify the output
  bool result = true;
  for (int i = 0; i < elements; i++) {
    if (C[i] != i + i) {
      result = false;
      break;
    }
  }

  if (result)
    printf("Output is correct\n");
  else
    printf("Output is incorrect\n");

  // STEP 13: Release OpenCL resources
  clReleaseKernel(kernel);
  clReleaseProgram(program);
  clReleaseCommandQueue(cmdQueue);
  clReleaseMemObject(bufferA);
  clReleaseMemObject(bufferB);
  clReleaseMemObject(bufferC);
  clReleaseContext(context);

  // Free host resources
  free(A);
  free(B);
  free(C);
  free(platforms);
  free(devices);

  return 0;
}
