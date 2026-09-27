// Expands MuJoCo's X-macros with the C preprocessor and writes one line per
// field, so the Ada generator never parses C by hand.
// Usage: xmacro_dump <output-file>
#include <stdio.h>
#include <mujoco/mujoco.h>
#include <mujoco/mjxmacro.h>

// mjxmacro.h leaves XNV (fields not needed by mjvScene) for the user to define.
#define XNV X

static FILE* out;

int main(int argc, char** argv) {
  if (argc != 2) { fprintf(stderr, "usage: xmacro_dump <output>\n"); return 2; }
  out = fopen(argv[1], "wb");
  if (!out) { perror(argv[1]); return 1; }

  fprintf(out, "META version %d\n", mjVERSION_HEADER);
  fprintf(out, "META sizeof_mjtNum %d\n", (int)sizeof(mjtNum));
  fprintf(out, "META mjNREF %d\n", mjNREF);
  fprintf(out, "META mjNIMP %d\n", mjNIMP);
  fprintf(out, "META mjNPOLY %d\n", mjNPOLY);
  fprintf(out, "META mjNSENS %d\n", mjNSENS);
  fprintf(out, "META mjNGAIN %d\n", mjNGAIN);
  fprintf(out, "META mjNBIAS %d\n", mjNBIAS);
  fprintf(out, "META mjNDYN %d\n", mjNDYN);
  fprintf(out, "META mjNFLUID %d\n", mjNFLUID);
  fprintf(out, "META mjNEQDATA %d\n", mjNEQDATA);
  fprintf(out, "META mjNTEXROLE %d\n", mjNTEXROLE);
  fprintf(out, "META mjNGEOMTYPES %d\n", mjNGEOMTYPES);

  int nsize = 0;
#define X(name) fprintf(out, "SIZE %s\n", #name); nsize++;
  MJMODEL_SIZES
#undef X
  fprintf(out, "META nsize %d\n", nsize);

  int nptr = 0;
#define X(type, name, nr, nc) fprintf(out, "PTR ALL %s %s %s %s\n", #type, #name, #nr, #nc); nptr++;
  MJMODEL_POINTERS
#undef X
  fprintf(out, "META nptr %d\n", nptr);

#define X(type, name, nr, nc) fprintf(out, "PTR BODY %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_BODY
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR JOINT %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_JOINT
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR DOF %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_DOF
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR TREE %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_TREE
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR GEOM %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_GEOM
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR SITE %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_SITE
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR CAMERA %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_CAMERA
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR LIGHT %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_LIGHT
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR FLEX %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_FLEX
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR MESH %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_MESH
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR SKIN %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_SKIN
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR HFIELD %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_HFIELD
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR TEXTURE %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_TEXTURE
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR MATERIAL %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_MATERIAL
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR PAIR %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_PAIR
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR EXCLUDE %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_EXCLUDE
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR EQUALITY %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_EQUALITY
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR TENDON %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_TENDON
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR ACTUATOR %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_ACTUATOR
#undef X
#define X(type, name, nr, nc) fprintf(out, "PTR SENSOR %s %s %s %s\n", #type, #name, #nr, #nc);
  MJMODEL_POINTERS_SENSOR
#undef X

#define X(type, name, n)    fprintf(out, "OPT %s %s %d\n", #type, #name, (int)(n));
#define XVEC(type, name, n) fprintf(out, "OPTVEC %s %s %d\n", #type, #name, (int)(n));
  MJOPTION_FIELDS
#undef X
#undef XVEC

#define X(name, n)    fprintf(out, "STAT %s %d\n", #name, (int)(n));
#define XVEC(name, n) fprintf(out, "STATVEC %s %d\n", #name, (int)(n));
  MJSTATISTIC_FIELDS
#undef X
#undef XVEC

#define X(type, name, n)    fprintf(out, "VIS global %s %s %d\n", #type, #name, (int)(n));
#define XVEC(type, name, n) fprintf(out, "VISVEC global %s %s %d\n", #type, #name, (int)(n));
  MJVISUAL_GLOBAL_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "VIS quality %s %s %d\n", #type, #name, (int)(n));
#define XVEC(type, name, n) fprintf(out, "VISVEC quality %s %s %d\n", #type, #name, (int)(n));
  MJVISUAL_QUALITY_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "VIS headlight %s %s %d\n", #type, #name, (int)(n));
#define XVEC(type, name, n) fprintf(out, "VISVEC headlight %s %s %d\n", #type, #name, (int)(n));
  MJVISUAL_HEADLIGHT_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "VIS map %s %s %d\n", #type, #name, (int)(n));
#define XVEC(type, name, n) fprintf(out, "VISVEC map %s %s %d\n", #type, #name, (int)(n));
  MJVISUAL_MAP_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "VIS scale %s %s %d\n", #type, #name, (int)(n));
#define XVEC(type, name, n) fprintf(out, "VISVEC scale %s %s %d\n", #type, #name, (int)(n));
  MJVISUAL_SCALE_FIELDS
#undef X
#undef XVEC
#define X(type, name, n)    fprintf(out, "VIS rgba %s %s %d\n", #type, #name, (int)(n));
#define XVEC(type, name, n) fprintf(out, "VISVEC rgba %s %s %d\n", #type, #name, (int)(n));
  MJVISUAL_RGBA_FIELDS
#undef X
#undef XVEC

  fclose(out);
  return 0;
}
