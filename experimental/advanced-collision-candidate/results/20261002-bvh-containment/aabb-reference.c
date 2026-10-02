#include <mujoco/mujoco.h>
static int filterBox(const mjtNum aabb1[6], const mjtNum aabb2[6], mjtNum margin) {
  if (aabb1[0]+aabb1[3]+margin < aabb2[0]-aabb2[3]) return 1;
  if (aabb1[1]+aabb1[4]+margin < aabb2[1]-aabb2[4]) return 1;
  if (aabb1[2]+aabb1[5]+margin < aabb2[2]-aabb2[5]) return 1;
  if (aabb2[0]+aabb2[3]+margin < aabb1[0]-aabb1[3]) return 1;
  if (aabb2[1]+aabb2[4]+margin < aabb1[1]-aabb1[4]) return 1;
  if (aabb2[2]+aabb2[5]+margin < aabb1[2]-aabb1[5]) return 1;
  return 0;
}
int ref_aabb(const double* a, const double* b, double margin) { return !filterBox(a, b, margin); }
