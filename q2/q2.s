.data
    format_string: .string "%d "        # Format string for printing the nge indices
    format_endstr: .string "%d"         # Format string for printing the last index of the nge output array
    newline_string: .string "\n"        # Format string for new line character at the end of printing the result

.text
.globl main
main:
    addi sp, sp, -80                    # Allocating 80 bytes of space in the stack
    sd x1, 72(sp)                       # Store the return address in stack
    sd x20, 64(sp)                      # Store original value of x20 in stack
    sd x21, 56(sp)                      # Store original value of x21 in stack
    sd x22, 48(sp)                      # Store original value of x22 in stack
    sd x23, 40(sp)                      # Store original value of x23 in stack
    sd x24, 32(sp)                      # Store original value of x24 in stack
    sd x25, 24(sp)                      # Store original value of x25 in stack
    sd x26, 16(sp)                      # Store original value of x26 in stack
    sd x27, 8(sp)                       # Store original value of x27 in stack
    add x20, x10, x0                    # Save argc value to callee-saved register x20
    add x21, x11, x0                    # Save argv base adress to callee-saved register x21
    addi x22, x20, -1                   # Subtract 1 to ignore the ./a.out
    slli x10, x22, 2                    # Multiplying (argc - 1) * 4 and storing in x10 - int is 32-bit
    jal x1, malloc                      # Allocating value of x10 bytes of space using C malloc
    add x23, x10, x0                    # Copy the returned base address of the new integer array
    addi x24, x0, 1                     # Initialise loop counter to 1 as we are starting from argv[1]
    addi x25, x21, 8                    # Increment base address of argv to now point to argv[1]
    add x26, x23, x0                    # Copy base address of integer array to x26

    input_loop:
        bge x24, x20, input_done        # If loop counter i >= argc then branch to input_done
        ld x10, 0(x25)                  # Load the string from current argv[i] address
        jal x1, string_to_int           # Call the string_to_int function to convert the string to integer
        sw x10, 0(x26)                  # Store the integer into the input integer array
        addi x24, x24, 1                # Increment loop counter i by 1
        addi x25, x25, 8                # Increment the argv pointer forward by 8 bytes
        addi x26, x26, 4                # Increment the integer array pointer forward by 4 bytes
        jal x0, input_loop              # Unconditional jump back to start of input_loop

    input_done:                         # x22 has number of elements and x23 has base address of the input integer array
        slli x10, x22, 2                # Calculate size of result array by x22 * 4
        jal x1, malloc                  # Call C malloc to allocate x22 * 4 number of bytes for result array
        add x24, x10, x0                # Copy the base address of newly allocated result array into x24
        slli x10, x22, 2                # Calculate size of stack by x22 * 4
        jal x1, malloc                  # Call C malloc to allocate x22 * 4 number of bytes for stack
        add x25, x10, x0                # Copy the base address of newly allocated stack into x25
        add x26, x25, x0                # Set stack pointer x26 to top of stack which is in x25
        addi x27, x22, -1               # Set loop counter i = n -1

    nge_loop:
        blt x27, x0, print_result       # If i < 0, branch to print
        slli x28, x27, 2                # Calculate offset - i*4
        add x28, x23, x28               # Add offset to base address of input array arr to get arr[i] address
        lw x5, 0(x28)                   # Load integer value of arr[i] into x5

        while_loop:
            beq x26, x25, update_result # If stack pointer is equal to base address of stack, stack is empty and nge does not exist, branch to update_result
            addi x29, x26, -4           # Address of actual top element
            lw x6, 0(x29)               # Load the index of the element at stack top
            slli x30, x6, 2             # Calculate offset - top of stack's index * 4
            add x30, x23, x30           # Add offset to base address of input array arr to get arr[i] address
            lw x7, 0(x30)               # Load the value of arr[stack top's index] into x7
            bgt x7, x5, update_result   # If arr[stack top] > arr[i], nge has been found, branch to update_result
            addi x26, x26, -4           # Increment stack pointer done by 4 bytes
            jal x0, while_loop          # Unconditional jump back to start of while loop

        update_result:
            beq x26, x25, no_nge        # If stack top is equal to base address, stack is empty so nge not found, branch to no_nge
            addi x29, x26, -4           # Address of actual top element
            lw x31, 0(x29)              # Load the nge index into x31
            jal x0, store_index         # Unconditional jump to store_index

        no_nge:
            addi x31, x0, -1            # Set the value to -1 to indicate nge does not exist for that value

        store_index:
            slli x28, x27, 2            # Calculate offset - i*4
            add x28, x24, x28           # Add offset to base address of result array res to get res[i]
            sw x31, 0(x28)              # Store the index of nge else -1 into res[i]
            sw x27, 0(x26)              # Store i at the current top of stack
            addi x26, x26, 4            # Increment stack pointer up by 4 bytes
            addi x27, x27, -1           # Decrement loop counter i by 1
            jal x0, nge_loop            # Unconditional jump back to start of nge_loop

    print_result:
        addi x27, x0, 0                 # Reset loop counter i to 0
        add x28, x24, x0                # Copy the base address of result array to x28
        addi x20, x22, -1               # Set the value of x20 to n-1 for pritning the last index
        
        print_loop:
            bge x27, x22, nge_done      # If loop counter i >= n, branch to nge_done
            slli x28, x27, 2            # Calculate offset - i*4
            add x28, x24, x28           # Add offset to base address of result array res to get res[i]
            beq x27, x20, print_end     # If loop counter i == n-1, branch to print_end
            la x10, format_string       # Else, load address of format_string into x10
            lw x11, 0(x28)              # Load the value of res[i] into x11
            jal x1, printf              # Call C printf to print the nge index in the result array
            addi x27, x27, 1            # Increment loop counter i by 1
            jal x0, print_loop          # Unconditional jump back to start of print_loop

        print_end:
            la x10, format_endstr       # Load address of format_endstr into x10
            lw x11, 0(x28)              # Load the value of res[n-1] into x11
            jal x1, printf              # Call C printf to print the nge index in the result array

        nge_done:
            la x10, newline_string      # Load address of newline_string into x10
            jal x1, printf              # Call C printf to print newline at the end of the printed result array
            ld x27, 8(sp)               # Restore original value of x27 back
            ld x26, 16(sp)              # Restore original value of x26 back
            ld x25, 24(sp)              # Restore original value of x25 back
            ld x24, 32(sp)              # Restore original value of x24 back
            ld x23, 40(sp)              # Restore original value of x23 back
            ld x22, 48(sp)              # Restore original value of x22 back
            ld x21, 56(sp)              # Restore original value of x21 back
            ld x20, 64(sp)              # Restore original value of x20 back
            ld x1, 72(sp)               # Restore original return address into x1
            addi sp, sp, 80             # Deallocate the stack
            addi x10, x0, 0             # Setting return register x10 to 0 to indicate success
            jalr x0, 0(x1)              # Return to caller - program ends

    string_to_int:
        addi x11, x0, 0                 # Set the initial integer value to 0
        addi x14, x0, 10                # Store the value 10 in x14 for conversion

    conversion_loop:
        lb x12, 0(x10)                  # Load the current character into x12
        beq x12, x0, conversion_done    # If the character is \0, branch to finish
        mul x11, x11, x14               # Multiply integer value in x11 by 10
        addi x12, x12, -48              # Convert character to integer by subtracting 48 - '0'
        add x11, x11, x12               # Add it to the integer value
        addi x10, x10, 1                # Increment the address by 1, moving on to next character
        jal x0, conversion_loop         # Unconditional jump back to start of the loop

    conversion_done:
        add x10, x11, x0                # Copy final integer value into return register x10
        jalr x0, 0(x1)                  # Return to caller


