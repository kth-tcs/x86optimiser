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

    // a few considerations: the multiplier (currently 19) should not be a
    // power of 2, lest this becomes a bit-shift and we only get *much* less
    // variety.  We don't want to just add rand() because that could be as high
    // as RAND_MAX.  We don't want to leave out rand because that would make
    // the testcases deterministic and all 7 modulo 19 (at least until it wraps
    // around the 64-bit limit).

    j = (j*19 + 7 + (rand() % 5));
    ret += popcnt(j);
  }

  return ret;
}
       
