#include <stdio.h>
#include <stdlib.h>

// The definition of struct Node is as follows:
struct Node {
    int val;
    struct Node* left;
    struct Node* right;
};

struct Node* make_node(int val); // Returns a pointer to a struct with the given value and left and right pointers set to NULL.

struct Node* insert(struct Node* root, int val); // insert a node with value val into the tree with the given root. Return the root.

struct Node* get(struct Node* root, int val); // Return a pointer to a node with value val in the tree. Return NULL if no such node exists.

int getAtMost(int val, struct Node* root); // Return the greatest value present in the tree which is <= val. Return -1 if no such node exists.

int main(){
    struct Node* root=make_node(3);
    root=insert(root, 2);
    root=insert(root, 4);
    root=insert(root, 5);
    root=insert(root, 6);
    root=insert(root, 7);
    root=insert(root, 8);
    struct Node* ans=get(root, 1);
    printf("%d\n", ans == NULL ? root->val : ans->val);
    printf("%d\n", getAtMost(1, root));
    return 0;
}
