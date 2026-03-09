#include <stdio.h>

typedef struct { float x, y, z; } vec3;

static inline vec3 smul(float s, vec3 v) {
    return (vec3){ s * v.x, s * v.y, s * v.z };
}

static inline void print_vec3(vec3 v) {
    printf("[%g,%g,%g]\n", v.x, v.y, v.z);
}
