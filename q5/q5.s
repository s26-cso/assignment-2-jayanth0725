.data
    filename: .string "input.txt"   # File name that contains the long palindrome
    fmt_true: .string "Yes\n"       # Format string for output is palindrome
    fmt_false: .string "No\n"       # Format string for output is not palindrome

.text
.globl main

main:
    addi x17, x0, 56                # Set the syscall number to 56 for openat
    addi x10, x0, -100              # Set x10 to -100 to to tell syscall to find file in current directory
    la x11, filename                # Set x11 to the address of filename - input.txt
    addi x12, x0, 0                 # Set x12 to 0 to indicate the file should be opened in read-only mode
    addi x13, x0, 0                 # Set x13 to 0 to indicate no special mode is required
    ecall                           # Call the syscall openat to open the file

    add x18, x10, x0                # Copy file descriptor to safe register x18
    addi x17, x0, 62                # Set the syscall number to 62 for lseek
    add x10, x18, x0                # Copy file descriptor address from x18 into x10
    add x11, x0, x0                 # Set the offset to 0 to register x11
    addi x12, x0, 2                 # Set the start of lseek to the end of the file
    ecall                           # Call syscall lseek to shift the file cursor to the end of the file to get string length

    add x19, x10, x0                # Copy length of the palindrome to safe register x19
    add x20, x0, x0                 # Initialise left pointer to 0
    addi x21, x19, -1               # Initialise right pointer to length-1
    addi sp, sp, -16                # Move stack pointer down
    
    addi x17, x0, 62                # Set the syscall number to 62 for lseek
    add x10, x18, x0                # Copy file descriptor address from x18 into x10
    add x11, x21, x0                # Set the offset to length-1 to register x11
    add x12, x0, x0                 # Set the start of lseek to the start of file
    ecall                           # Call syscall lseek to shift the file cursor to the last character of the file for read syscall

    addi x17, x0, 63                # Set the syscall number to 63 for read
    add  x10, x18, x0               # Copy file descriptor address from x18 into x10
    addi x11, sp, 0                 # Set x11 to the address of sp for read's input buffer
    addi x12, x0, 1                 # Read exactly 1 byte at the file cursor position
    ecall                           # Call syscall read to get the character at the end of the file
    lb x22, 0(sp)                   # Load the byte from stack address into x22
    
    addi sp, sp, 16                 # Deallocate the stack
    addi x5, x0, 10                 # Set the value of x5 to 10 to indicate "\n"
    bne x22, x5, check              # If x22 is not equal to x5, last character is not "\n", branch to check
    addi x19, x19, -1               # Else decrement the length of the string
    addi x21, x21, -1               # Decrement the right pointer pointer as well

check:
    bge x20, x21, is_true           # If x20's address >= x21's address, then it is palindrome
    addi x17, x0, 62                # Set the syscall number to 62 for lseek
    add x10, x18, x0                # Copy file descriptor address from x18 into x10
    add x11, x20, x0                # Set the offset to left pointer x20 to register x11
    add x12, x0, x0                 # Set the start of lseek to the start of the file
    ecall                           # Call syscall lseek to shift the file cursor to current position of left pointer for read syscall

    addi sp, sp, -16                # Allocate 16 bytes in stack for read syscalls
    addi x17, x0, 63                # Set the syscall number to 63 for read
    add  x10, x18, x0               # Copy file descriptor address from x18 into x10
    addi x11, sp, 0                 # Set x11 to the address of sp for read's input buffer
    addi x12, x0, 1                 # Read exactly 1 byte at the file cursor position
    ecall                           # Call syscall read to get the character of the left pointer
    lb x22, 0(sp)                   # Load the value of the character from the input buffer in stack to register x22
    
    addi x17, x0, 62                # Set the syscall number to 62 for lseek
    add x10, x18, x0                # Copy file descriptor address from x18 into x10
    add x11, x21, x0                # Set the offset to right pointer x21 to register x11
    add x12, x0, x0                 # Set the start of lseek to the start of the file
    ecall                           # Call syscall lseek to shift the file cursor to current position of right pointer for read syscall

    addi x17, x0, 63                # Set the syscall number to 63 for read
    add  x10, x18, x0               # Copy file descriptor address from x18 into x10
    addi x11, sp, 8                 # Set x11 to the address of sp for read's input buffer
    addi x12, x0, 1                 # Read exactly 1 byte at the file cursor position
    ecall                           # Call syscall read to get the character of the right pointer
    lb x23, 8(sp)                   # Load the value of the character from the input buffer in stack to register x23

    addi sp, sp, 16                 # Deallocate the stack
    bne x22, x23, is_false          # If their values are not equal, then not a palindrome
    addi x20, x20, 1                # Incrementing left pointer by 1 byte
    addi x21, x21, -1               # Decrementing right pointer by 1 byte
    jal x0, check                   # Unconditional jump back to start of check

is_true:
    addi x17, x0, 64                # Set the syscall number to 64 for write
    addi x10, x0, 1                 # Set the register x10 to 1 for stdout
    la x11, fmt_true                # Load the address of fmt_true into x11
    addi x12, x0, 4                 # Set the length of the string to be printed to register x12
    ecall                           # Call the syscall write to print "Yes"
    jal x0, end                     # Unconditional jump to end

is_false:
    addi x17, x0, 64                # Set the syscall number to 64 for write
    addi x10, x0, 1                 # Set the register x10 to 1 for stdout
    la x11, fmt_false               # Load the address of fmt_false into x11
    addi x12, x0, 3                 # Set the length of the string to be printed to register x12
    ecall                           # Call the syscall write to print "No"
    jal x0, end                     # Unconditional jump to end

end:
    addi x17, x0, 57                # Set the syscall number to 57 for close
    add x10, x18, x0                # Copy the saved file descriptor from x18 into x10
    ecall                           # Call syscall close to close the opened file input.txt
    addi x17, x0, 93                # Set the syscall number to 93 for exit
    add x10, x0, x0                 # Set x10 to 0 to end program
    ecall                           # Call exit to end program
    
