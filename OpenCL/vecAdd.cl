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
