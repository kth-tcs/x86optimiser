#include <cstdlib>
#include <stddef.h>
#include <stdint.h>

using namespace std;

size_t parity(uint64_t x) {
  size_t total = 0;
  total += ((x & 0x1) == 0x1);
  total += ((x & 0x2) == 0x2);
  total += ((x & 0x4) == 0x4);
  total += ((x & 0x8) == 0x8);
  total += ((x & 0x10) == 0x10);
  total += ((x & 0x20) == 0x20);
  total += ((x & 0x40) == 0x40);
  total += ((x & 0x80) == 0x80);
  return (total % 2);
}

int main(int argc, char** argv) {
  const auto itr = strtoull(argv[1], NULL, 10);

  auto ret = 0;
  for (auto i = 0; i < itr; ++i) {
    ret += parity(i);
  }

  return ret;
}
