/* Address-only oracle. Never linked into the Ada implementation.
 * Ordered assignments follow mjCModel::SaveDofOffsets at MuJoCo 3.14.0.
 * Input widths have already been resolved by actuator compilation.
 * The two-pass size check is the Ada model format's explicit capacity policy,
 * not a claim that C accepts/rejects all the same oversized inputs.
 */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#define MODEL_MAX ((int64_t)((1 << 27) - 1))
int main(void) {
  char op; int n;
  while (scanf(" %c %d", &op, &n) == 2) {
    if (n < 0 || n > 131072) return 2;
    int *data = calloc((size_t)(3*n+1), sizeof(int));
    if (!data) return 3;
    if (op == 'J') {
      const int npos[4] = {7,4,1,1}, nvel[4] = {6,3,1,1};
      int qposadr=0, dofadr=0;
      for (int i=0; i<n; ++i) {
        if (scanf("%d", data+i) != 1 || data[i]<0 || data[i]>3) return 2;
        qposadr += npos[data[i]]; dofadr += nvel[data[i]];
      }
      printf("SUCCESS %d %d",qposadr,dofadr);
      qposadr=dofadr=0;
      for (int i=0; i<n; ++i) {
        printf(" %d %d",qposadr,dofadr);
        qposadr += npos[data[i]]; dofadr += nvel[data[i]];
      }
    } else if (op == 'A') {
      int64_t ctrladr=0, outadr=0, actadr=0;
      for (int i=0; i<3*n; ++i) if (scanf("%d",data+i)!=1 || data[i]<0) return 2;
      for (int i=0; i<n; ++i) {
        ctrladr+=data[3*i]; outadr+=data[3*i+1]; actadr+=data[3*i+2];
      }
      if (ctrladr>MODEL_MAX || outadr>MODEL_MAX || actadr>MODEL_MAX) {
        printf("CAPACITY_LIMIT 23 29 31");
        for (int i=0; i<n; ++i) printf(" -1 19 -1");
      } else {
        printf("SUCCESS %lld %lld %lld",(long long)ctrladr,(long long)outadr,(long long)actadr);
        ctrladr=outadr=actadr=0;
        for (int i=0; i<n; ++i) {
          printf(" %lld %lld %lld", (long long)(data[3*i]?ctrladr:-1),
              (long long)outadr,(long long)(data[3*i+2]?actadr:-1));
          ctrladr+=data[3*i]; outadr+=data[3*i+1]; actadr+=data[3*i+2];
        }
      }
    } else if (op == 'M') {
      int mocapadr=0;
      for (int i=0; i<n; ++i) {
        if (scanf("%d",data+i)!=1 || data[i]<0 || data[i]>1) return 2;
        mocapadr += data[i];
      }
      printf("SUCCESS %d",mocapadr); mocapadr=0;
      for (int i=0; i<n; ++i) printf(" %d",data[i]?mocapadr++:-1);
    } else if (op == 'O') {
      printf("SUCCESS");
      for (int i=0; i<n; ++i) printf(" %d",i);
    } else if (op == 'R') {
      printf("SUCCESS");
      for (int i=0; i<n; ++i) {
        int computed, declared, dyn;
        if (scanf("%d %d %d",&computed,&declared,&dyn)!=3) return 2;
        printf(" %d",computed>0?computed:declared>0?declared:dyn!=0);
      }
    } else return 2;
    puts(""); free(data);
  }
  return ferror(stdin)?2:0;
}
