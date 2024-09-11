#
# FILE:         $Id$
# AUTHOR:       Lachlan Bartle
#
# DESCRIPTION:
#	Reads in and creates a board for the cross_sums puzzle.
#       Prints message if the input is bad.

#-------------------------------

# DATA AREAS
#

	.data
 
invalid_size:  
        .asciiz "Invalid board size, Cross Sums terminating\n"
illegal_input: 
        .asciiz "Illegal input value, Cross Sums terminating\n"
        
#-------------------------------

#
# CODE AREAS
#

	.globl  size
	.globl	board
        .globl  read_board

#-------------------------------

#
# CONSTANTS
#

.text
READ_INT =      5
PRINT_INT =     1
PRINT_STRING =  4
EXIT = 	        10

 
#-------------------------------

# Read the board for the puzzle        
read_board:
	addi	$sp, $sp, -4       # Allocate space on the stack                                      # for return address
	sw	$ra, 0($sp)        # Save the return address
	li	$v0, READ_INT      # Load system call for reading                                     # an integer
	syscall
	sw	$v0, size          # Store the size of the board
	move	$t0, $v0           # Copy the size to $t0
	slti	$t1, $t0, 13       # Check if the size is less 
                                   # than 13
	sgt	$t2, $t0, 1        # Check if the size is 
                                   # greater than 1
	and	$t0, $t1, $t2      # Check if both conditions 
                                   # are true
	beq	$t0, $zero, print_invalid_size
	# If size is invalid print error message and terminate
	mul	$t0, $v0, $v0      # Calculate the total number 
                                   # of elements in the board

	move	$t3, $v0           # Copy the size to $t5

	move	$t1, $zero         # Initialize loop counter to 0
	la	$t7, board         # Load address of the 
                                   # board array
 
read_board_loop:
        beq	$t1, $t0, done_read
                                   # Exit loop if all elements 
                                   # are read

	li	$v0, READ_INT
	syscall
	
	move	$t2, $v0
	move	$a0, $t2
	jal 	check_input

	sw	$t2, 0($t7)        # Store the integer in the 
                                   # board array
	sw	$zero, 4($t7)      # Store 0 in the second word 
                                   # for each element


	addi	$t1, $t1, 1        # Increment loop counter
	addi	$t7, $t7, 8        # Move to the next element
                                   # in the board array
	j	read_board_loop
 
done_read:
        lw      $ra, 0($sp)        # Restore the return address
        addi    $sp, $sp, 4
        jr      $ra
        
# Print error message for invalid board size 
# Terminates after printing invalid message
print_invalid_size:
        li      $v0, PRINT_STRING  # Load system call for printing
        la      $a0, invalid_size  # Load address of the string
        syscall                    # Print the string
        li      $v0, EXIT          # Load system call for exit
        syscall

# Print error message for illegal input value and terminate    
print_illegal_input:
        li      $v0, PRINT_STRING  # Load system call for printing
        la      $a0, illegal_input # Load address of the string
        syscall
        li      $v0, EXIT          # Load system call for exit
        syscall

# Function to validate input value
check_input:
	beq	$a0, $zero, done
	move	$t6, $a0
	move	$t4, $zero
	div	$t4, $t6, 100
	slti	$t5, $t4, 46
	sgt	$t6, $t6, 0
	seq	$t4, $t4, 99
	or	$t5, $t5, $t4
	and	$t5, $t5, $t6
	beq	$t5, $zero, print_illegal_input
	move	$t6, $a0
	move	$t4, $zero
	rem	$t4, $t6, 100
	slti	$t5, $t4, 46
	sgt	$t6, $t6, 0
	seq	$t4, $t4, 99
	or	$t5, $t5, $t4
	and	$t5, $t5, $t6
	beq	$t5, $zero, print_illegal_input
 
# Finished
done:	
	jr $ra
