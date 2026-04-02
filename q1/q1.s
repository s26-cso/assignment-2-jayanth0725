.globl make_node, get, insert, getAtMost

make_node:
    addi sp, sp, -16            # Allocating 16 bytes of space in stack
    sd x1, 0(sp)                # Storing function return address in stack
    sd x10, 8(sp)               # Storing new node value in stack
    addi x10, x0, 24            # Giving argument register x10 the value 24
    jal x1, malloc              # Calling C malloc function to allocate 24 bytes of space, which is the size of each struct Node
    ld x5, 8(sp)                # Loading the new node value to temporary register x5
    sw x5, 0(x10)               # Storing the value of x5 at 0(x10, which is the location of int val for the node. After the malloc, x10 has the address of the newly allocated node
    sd x0, 8(x10)               # Storing NULL value for left pointer of the node
    sd x0, 16(x10)              # Storing NULL for right pointer of the node
    ld x1, 0(sp)                # Loading back the function return address to x1
    addi sp, sp, 16             # Restoring the stack
    jalr x0, 0(x1)              # Return to caller

get:
    getLoop:
        beq x10, x0, end        # If root is NULL, return NULL by branching to end
        lw x5, 0(x10)           # Else, load the current node's value into x5
        beq x5, x11, end        # If the current node's value is equal to the target, branch to end
        blt x11, x5, goLeft     # Else if, if target < current, branch to goLeft
        ld x10, 16(x10)         # Else, load the value of the right child
        jal x0, getLoop         # Jump unconditionally back to the start of the loop
    goLeft:
        ld x10, 8(x10)          # Load the value of the left child
        jal x0, getLoop         # Jump unconditionally back to the start of the loop
    end:
        jalr x0, 0(x1)          # Return to caller

insert:
    beq x10, x0, insertion      # Base Case: If root is NULL, go to insertion and create new node
    addi sp, sp, -32            # Allocating 32 bytes of space in stack
    sd x1, 0(sp)                # Saving return address in stack
    sd x10, 8(sp)               # Saving current root address in stack
    sw x11, 16(sp)              # Saving value to insert in stack
    lw x5, 0(x10)               # Loading root->val into x5
    blt x11, x5, recLeft        # If val < root->val, branch to recLeft
    recRight:
        ld x10, 16(x10)         # Else, branch to recRight and load address of root->right into x10
        jal x1, insert          # Recursive function call to insert again
        ld x5, 8(sp)            # After returning, load original root address from stack into x5
        sd x10, 16(x5)          # Store the returned address from insertion in root->right
        add x10, x5, x0         # Restore original root address to x10
        jal x0, insertDone      # Unconditional jump to insertDone, insertion complete
    recLeft:
        ld x10, 8(x10)          # Load address of root->left into x10
        jal x1, insert          # Recursive function call to insert again
        ld x5, 8(sp)            # After returning, load original root address from stack into x5
        sd x10, 8(x5)           # Store the returned address from insertion in root->left
        add x10, x5, x0         # Restore original root address to x10
    insertDone:
        ld x1, 0(sp)
        addi sp, sp, 32         # Deallocating the stack
        jalr x0, 0(x1)          # Return to caller - either previous insert call or main. This return is called only when the tree is not empty
    insertion:
        addi sp, sp, -16        # Allocating 16 bytes of space in stack
        sd x1, 0(sp)            # Save the return address to stack
        add x10, x11, x0        # Move the value to insert into x10 for the make_node function
        jal x1, make_node       # Jump to make_node
        ld x1, 0(sp)            # Restore the original return address to x1
        addi sp, sp, 16         # Deallocating the stack
        jalr x0, 0(x1)          # x10 now has the address of the created node. Function return back to whoever called insert - main if tree was empty, otherwise previous insert call


getAtMost:
    addi x12, x0, -1            # Set the answer to -1
    atMostLoop:
        beq x11, x0, done       # If the current node is NULL, we have found the best answer < x10, branch to done
        lw x5, 0(x11)           # Loading the curr->val into x5
        beq x5, x10, match      # If curr->val is equal to target, branch to match since we have found the best possible answer
        blt x5, x10, possible   # If target > curr->val, branch to possible
        ld x11, 8(x11)          # Load the address of curr->left into x11
        jal x0, atMostLoop      # Unconditional jump back to start of the loop
    possible:
        add x12, x5, x0         # Update the value of x12
        ld x11, 16(x11)         # Load the address of curr->right into x11
        jal x0, atMostLoop      # Unconditional jump back to start of the loop
    match:
        add x12, x5, x0         # Copy the value of the exact match from x5 to x12
    done:
        add x10, x12, x0        # Copy the value of the answer from x12 to x10
        jalr x0, 0(x1)          # Return to caller

