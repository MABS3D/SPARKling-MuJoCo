/* Standalone native reference replay. No Ada or Python participates in dynamics. */
#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void read_values(FILE* input, mjtNum* values, int count) {
  for (int i = 0; i < count; ++i) {
    double value;
    if (fscanf(input, "%lf", &value) != 1) {
      fprintf(stderr, "incomplete replay input\n");
      exit(2);
    }
    values[i] = value;
  }
}

int main(int argc, char** argv) {
  if (argc != 3) {
    fprintf(stderr, "usage: native_replay model.xml-or-mjb input\n");
    return 2;
  }
  setvbuf(stdout, NULL, _IONBF, 0);
  char error[1024] = {0};
  mjModel* model = strstr(argv[1], ".xml")
      ? mj_loadXML(argv[1], NULL, error, sizeof(error))
      : mj_loadModel(argv[1], NULL);
  if (!model) { fprintf(stderr, "model: %s\n", error); return 3; }
  FILE* input = fopen(argv[2], "r");
  int samples, steps;
  if (!input || fscanf(input, "%d %d", &samples, &steps) != 2) return 4;
  printf("version %s samples %d steps %d\n", mj_versionString(), samples, steps);
  for (int sample = 0; sample < samples; ++sample) {
    mjData* data = mj_makeData(model);
    if (!data) return 5;
    read_values(input, &data->time, 1);
    read_values(input, data->qpos, model->nq);
    read_values(input, data->qvel, model->nv);
    read_values(input, data->qfrc_applied, model->nv);
    read_values(input, data->ctrl, model->nu);
    read_values(input, data->act, model->na);
    read_values(input, data->xfrc_applied, 6 * model->nbody);
    printf("sample %d before forward\n", sample);
    mj_forward(model, data);
    printf("sample %d after forward contacts %d rows %d\n", sample, data->ncon, data->nefc);
    for (int step = 0; step < steps; ++step) {
      mj_step(model, data);
      printf("sample %d step %d contacts %d rows %d\n", sample, step + 1, data->ncon, data->nefc);
    }
    mj_deleteData(data);
    printf("sample %d deleted\n", sample);
  }
  fclose(input);
  mj_deleteModel(model);
  puts("completed");
  return 0;
}
