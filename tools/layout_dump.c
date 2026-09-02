// Prints sizeof/offsetof of the fixed structs the .mjb loader must mirror.
// Usage: layout_dump <output-file>
#include <stdio.h>
#include <stddef.h>
#include <mujoco/mujoco.h>
#include <mujoco/mjxmacro.h>

int main(int argc, char** argv) {
  if (argc != 2) { fprintf(stderr, "usage: layout_dump <output>\n"); return 2; }
  FILE* out = fopen(argv[1], "wb");
  if (!out) { perror(argv[1]); return 1; }

  fprintf(out, "SIZEOF mjtBool %d\n", (int)sizeof(mjtBool));
  fprintf(out, "SIZEOF mjtSize %d\n", (int)sizeof(mjtSize));
  fprintf(out, "SIZEOF mjContact %d\n", (int)sizeof(mjContact));

  fprintf(out, "SIZEOF mjOption %d\n", (int)sizeof(mjOption));
#define X(type, name, n)    fprintf(out, "OFFSET mjOption %s %d\n", #name, (int)offsetof(mjOption, name));
#define XVEC(type, name, n) fprintf(out, "OFFSET mjOption %s %d\n", #name, (int)offsetof(mjOption, name));
  MJOPTION_FIELDS
#undef X
#undef XVEC

  fprintf(out, "SIZEOF mjStatistic %d\n", (int)sizeof(mjStatistic));
#define X(name, n)    fprintf(out, "OFFSET mjStatistic %s %d\n", #name, (int)offsetof(mjStatistic, name));
#define XVEC(name, n) fprintf(out, "OFFSET mjStatistic %s %d\n", #name, (int)offsetof(mjStatistic, name));
  MJSTATISTIC_FIELDS
#undef X
#undef XVEC

  fprintf(out, "SIZEOF mjVisual %d\n", (int)sizeof(mjVisual));
#define X(type, name, n)    fprintf(out, "OFFSET mjVisual global.%s %d\n", #name, (int)offsetof(mjVisual, global.name));
#define XVEC(type, name, n) fprintf(out, "OFFSET mjVisual global.%s %d\n", #name, (int)offsetof(mjVisual, global.name));
  MJVISUAL_GLOBAL_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "OFFSET mjVisual quality.%s %d\n", #name, (int)offsetof(mjVisual, quality.name));
#define XVEC(type, name, n) fprintf(out, "OFFSET mjVisual quality.%s %d\n", #name, (int)offsetof(mjVisual, quality.name));
  MJVISUAL_QUALITY_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "OFFSET mjVisual headlight.%s %d\n", #name, (int)offsetof(mjVisual, headlight.name));
#define XVEC(type, name, n) fprintf(out, "OFFSET mjVisual headlight.%s %d\n", #name, (int)offsetof(mjVisual, headlight.name));
  MJVISUAL_HEADLIGHT_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "OFFSET mjVisual map.%s %d\n", #name, (int)offsetof(mjVisual, map.name));
#define XVEC(type, name, n) fprintf(out, "OFFSET mjVisual map.%s %d\n", #name, (int)offsetof(mjVisual, map.name));
  MJVISUAL_MAP_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "OFFSET mjVisual scale.%s %d\n", #name, (int)offsetof(mjVisual, scale.name));
#define XVEC(type, name, n) fprintf(out, "OFFSET mjVisual scale.%s %d\n", #name, (int)offsetof(mjVisual, scale.name));
  MJVISUAL_SCALE_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "OFFSET mjVisual rgba.%s %d\n", #name, (int)offsetof(mjVisual, rgba.name));
#define XVEC(type, name, n) fprintf(out, "OFFSET mjVisual rgba.%s %d\n", #name, (int)offsetof(mjVisual, rgba.name));
  MJVISUAL_RGBA_FIELDS
#undef X
#undef XVEC

  fclose(out);
  return 0;
}
