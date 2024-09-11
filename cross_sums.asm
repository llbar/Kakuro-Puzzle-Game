#
# FILE:         $Id$
# AUTHOR:       Lachlan Bartle
#
# DESCRIPTION:
#	This program replicates a cross sums puzzle.
#       This file is the main of that puzzle.

#-------------------------------

#
# CONSTANTS
#

READ_INT =      5
PRINT_INT =     1
PRINT_STRING =  4
EXIT = 	        10

#-------------------------------

#
# DATA AREAS
#

	.data
	.align  0
size:
        .word   0
        
board:
        .space  1200
        
banner:
        .ascii  "******************\n"
        .ascii  "**  CROSS SUMS  **\n"
        .asciiz "******************\n\n"
        
init_board:
        .asciiz "Initial Puzzle\n\n"
        
#-------------------------------

#
# CODE AREAS
#
	.text			   
	.align  2		   
 
        .globl  main		   
        .globl  cell
        .globl  cell_val
        .globl  empty_cell        
        .globl  read_board
        .globl  print_board
        .globl  size
        .globl  find_empty_cell
        .globl  solve_puzzle
        .globl  board
        .globl  nl
#
# Name:         main
#
# Description:  EXECUTION BEGINS HERE
#        

main:
        addi    $sp, $sp, -4      # Initialization
        sw      $ra, 0($sp)
        # Print welcome banner
        li      $v0, PRINT_STRING
        la      $a0, nl
        syscall
        li      $v0, PRINT_STRING
        la      $a0, banner
        syscall
        jal     read_board        # Read puzzle
        # Print initial game message
        li      $v0, PRINT_STRING
        la      $a0, init_board
        syscall
        jal     print_board        # Print the board
       	jal	find_empty_cell    # Get the next empty cell
	jal	solve_puzzle       # solve the puzzle
        lw      $ra, 0($sp)        # Restore and return
        addi    $sp, $sp, 4
        jr      $ra
