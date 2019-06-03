#include <stdint.h>

struct Node {
  int32_t val;
  Node* next;
};

void traverse(Node* head) {
  while (head != 0) {
    head->val *= 2;
    head = head->next;
  }
}
