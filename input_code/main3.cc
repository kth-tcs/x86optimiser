#include <cstdlib>
#include <stdint.h>

struct Node {
  int32_t val;
  Node* next;
};

Node* new_list(size_t size) {
  auto list = new Node{rand(),0};

  auto n = list;
  for (auto i = 1; i < size; ++i) {
    auto nn = new Node{rand(),0};
    n->next = nn;
    n = n->next;
  }

  return list;
}

extern void traverse(Node* head);

void free_list(Node* head) {
  while (head != 0) {
    auto n = head->next;
    delete head;
    head = n;
  }
}

int main(int argc, char** argv) {
  const auto itr = argc > 1 ? atoi(argv[1]) : 1024;
  const auto seed = argc > 2 ? atoi(argv[2]) : 0;

  srand(seed);

  auto head = new_list(itr);
  traverse(head);
  free_list(head);

  return 0;
}
