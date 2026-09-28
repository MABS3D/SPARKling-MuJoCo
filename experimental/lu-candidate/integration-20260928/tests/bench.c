#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
int mju_factorLU(double*,int,int*);
void mju_solveLU(double*,const double*,const double*,const int*,int);
int mju_factorLUSparse(double*,int,int*,const int*,const int*,const int*,const int*);
void mju_solveLUSparse(double*,const double*,const double*,int,const int*,const int*,const int*,const int*,const int*);
static int connected(int i,int j){int a=i;for(;;){if(a==j)return 1;if(!a)break;a=(a-1)/2;}a=j;for(;;){if(a==i)return 1;if(!a)break;a=(a-1)/2;}return 0;}
int main(int argc,char**argv){int sparse=argv[1][0]=='S',n=atoi(argv[2]),loops=atoi(argv[3]),count=0;
 double *src=calloc(n*n,sizeof(double)),*a=calloc(n*n,sizeof(double)),*b=calloc(n,sizeof(double)),*x=calloc(n,sizeof(double));
 int *p=calloc(n,sizeof(int)),*diag=calloc(n,sizeof(int)),*row=calloc(n+1,sizeof(int)),*nnz=calloc(n,sizeof(int)),*col=calloc(n*n,sizeof(int));
 for(int i=0;i<n;i++){row[i]=count;b[i]=1;for(int j=0;j<n;j++)if(!sparse||connected(i,j)){if(i==j)diag[i]=count-row[i];src[count]=i==j?n+1:((i+3*j)%7-3)*.03125;col[count++]=j;}nnz[i]=count-row[i];}row[n]=count;
 struct timespec s,t;double sum=0;clock_gettime(CLOCK_MONOTONIC,&s);
 for(int r=1;r<=loops;r++){memcpy(a,src,count*sizeof(double));if(sparse){mju_factorLUSparse(a,n,p,nnz,row,col,0);mju_solveLUSparse(x,a,b,n,nnz,row,diag,col,0);}else{if(!mju_factorLU(a,n,p))return 2;mju_solveLU(x,a,b,p,n);}sum+=x[r%n];}
 clock_gettime(CLOCK_MONOTONIC,&t);printf("%.9f %.17g\n",(t.tv_sec-s.tv_sec)+(t.tv_nsec-s.tv_nsec)*1e-9,sum);
 free(src);free(a);free(b);free(x);free(p);free(diag);free(row);free(nnz);free(col);return 0;}
