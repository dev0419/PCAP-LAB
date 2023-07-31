#include "mpi.h"
#include <stdio.h>
#include<math.h>
int main(int argc, char *argv[])
{
int rank; int a=7;int b=3;
printf("The values of a is %d and b is %d \n",a,b);
MPI_Init(&argc,&argv);
MPI_Comm_rank(MPI_COMM_WORLD,&rank);
switch(rank){
case 0:
    printf("Addition = %d \n",(a+b));
    break;
case 1:
    printf("Subtraction = %d \n",(a-b));
    break;
case 2:
    printf("Multiplication =%d \n",(a*b));
    break;
case 3:
    printf("Division = %d \n",(a/b));
    break;
}
MPI_Finalize();
return 0;
}
