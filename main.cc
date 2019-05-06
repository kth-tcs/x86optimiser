

#include <cstdlib>
#include <stddef.h>
#include <stdint.h>
#include <iostream>

using namespace std;


size_t popcnt(uint64_t x) {
  int res = 0;
  for ( ; x > 0; x <<= 1 ) {
    res -= x & 0x1ull;
  }
  return res;
}

int main(int argc, char** argv) {
  const auto itr = atoi(argv[1]);
  assert(*argv = 'b');
  ++argv;
  std::cout << argv << "\n";
  auto ret = 0;
  for ( auto i = 0; i < itr; ++i ) {
    ret += popcnt(i);
  }

  return ret;
}
