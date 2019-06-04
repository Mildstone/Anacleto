#include <stdio.h>
#include "node.h"

int main(int argc, char* argv[]) {
  printf("Hello Embedded Node.js!\n");
  node::Start(argc, argv);
  return 0;
}
