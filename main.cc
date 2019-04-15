#include <cstdlib>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

using namespace std;

size_t popcnt(uint64_t x) {
  int res = 0;
  for (; x > 0; x >>= 1) {
    res += x & 0x1ull;
  }
  return res;
}

int main(int argc, char** argv) {
  const auto itr = atoi(argv[1]);

  auto ret = 0;
  uint64_t j = 1;
  for (auto i = 0; i < itr; ++i) {
  
    j = (j*19 + 7 + (rand() % 5));
    i = (j*56 + 8 + (rand() % 6));
    ret += popcnt(j);
  }

  return ret;
}
       