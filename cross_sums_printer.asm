#
# FILE:         $Id$
# AUTHOR:       Lachlan Bartle
#
# DESCRIPTION:
#	Prints the puzzle board for the cross_sums puzzle.
# 

#-------------------------------

#
# DATA AREAS
#

        .data
#-------------------------------

#
# CODE AREAS
#

	.globl  size
	.globl	board
        .globl  print_board
        .globl  nl
        
        .align  0
        
backslash: 
        .asciiz "\\" 
        
bar: 
        .asciiz "|"
        
pound: 
        .asciiz "#"
        
space: 
        .asciiz " "

border: 
        .asciiz	"---+"
        
plus: 
        .asciiz "+"
        
nl: 
        .asciiz "\n"

#-------------------------------
#
# CONSTANTS
#

PRINT_INT = 	1
PRINT_STRING = 	4
READ_INT = 	5
EXIT = 		10

        .text
        .align  2

#-------------------------------

# Prints the border pattern
print_border:
	li	$v0,PRINT_STRING
	la	$a0, plus
	syscall
	lw	$a1, size

print_border_next:
	la	$a0,border
	syscall
	addi	$a1, $a1, -1
	bne	$a1, $zero, print_border_next
	jr	$ra
 
# Prints space
print_space:
	li	$v0,PRINT_STRING
	la	$a0,space
	syscall
	jr	$ra
 
# Prints a backslash
print_backslash:
	li	$v0,PRINT_STRING
	la	$a0,backslash
	syscall
	jr	$ra
 
# Prints |
print_bar:
	li	$v0,PRINT_STRING
	la	$a0,bar
	syscall
	jr	$ra
 
# Prints newline
print_nl:
	li	$v0,PRINT_STRING
	la	$a0,nl
	syscall
	jr	$ra
 
# Prints #
print_pound:
	li	$v0,PRINT_STRING
	la	$a0,pound
	syscall
	jr	$ra
  
# Initalize printing the board
print_board:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	la	$t0, board
	lw	$t1, size
 	move	$t2, $t1
	move	$t3, $t0 
	move	$t4, $t1	
	jal	print_border   # Call the function to 
                               # print the border

print_row_loop:
	beq	$t2, $zero, print_done
	jal	print_nl
	jal	print_bar
 
across_loop:
	beq	$t4, $zero ,line_print

across_clue:
	lw	$t7, 0($t0)
	beq	$t7, $zero, blank_across
	jal	print_backslash
	div	$t6, $t7, 100
	li	$t5, 99
	beq	$t6, $t5, block_across
	slti	$t5, $t6, 10
	bne	$t5, $zero, across_value
	li	$v0, PRINT_INT
	move	$a0, $t6
	syscall
	j	across_done

blank_across:
	jal	print_space
	jal	print_space
	jal	print_space
	j	across_done

across_value:
	jal	print_pound
	li	$v0, PRINT_INT
	move	$a0, $t6       # Print the across clue
	syscall
	j	across_done

block_across:
	jal	print_pound
	jal	print_pound

across_done:
	jal	print_bar      # Print bar for column separation
	addi	$t4, $t4, -1
	addi	$t0, $t0, 8    # Move to next cell
	j	across_loop
	
line_print:
	move	$t0, $t3
        la      $t8, size
	lw	$t4, 0($t8)
	jal	print_nl
	jal	print_bar
 
line_loop:
	lw	$t7, 0($t0)
	beq	$t7, $zero, line_value
	jal	print_pound
	jal	print_backslash
	jal	print_pound
	j	line_done

line_value:
	jal	print_space
	li	$v0, PRINT_INT
	lw	$a0, 4($t0)
	beq	$a0, $zero, line_space
	syscall
	j	sp
 
line_space:
	jal	print_space
 
sp:
	jal	print_space
	j	line_done
	
line_done:
	jal	print_bar
	addi	$t0, $t0, 8
	addi	$t4, $t4, -1
	beq	$t4, $zero, down_clue
	j	line_loop
	
down_clue:
	move	$t0, $t3
	lw	$t7, 0($t0)
        la      $t8, size
	lw	$t4, 0($t8)
	jal	print_nl
	jal	print_bar

down_loop:
	lw	$t7, 0($t0)	
	beq	$t7, $zero, blank_down
	div	$t7, $t7, 100
	mfhi	$t7
	li	$t5, 99
	beq	$t7, $t5, down_clue_b
	slti	$t5, $t7, 10
	bne	$t5, $zero, down_value
	li	$v0, PRINT_INT
	move	$a0, $t7
	syscall
	jal	print_backslash
	j	down_clue_done

down_value:
	jal	print_pound
	li	$v0, PRINT_INT
	move	$a0, $t7
	syscall
	jal	print_backslash
	j	down_clue_done

blank_down:
	jal	print_space
	jal	print_space
	jal	print_space
	j	down_clue_done

down_clue_b:
	jal	print_pound
	jal	print_pound
	jal	print_backslash

down_clue_done:
	jal	print_bar
	addi	$t0, $t0, 8
	addi	$t4, $t4, -1
	beq	$t4, $zero, row_done
	j	down_loop

row_done:
	addi	$t2, $t2, -1
        la      $t8, size
	lw	$t4, 0($t8)
	mul	$t5, $t4, 8
	add	$t3, $t3, $t5
	move	$t0, $t3
	jal	print_nl
	jal	print_border
	j	print_row_loop

print_done:
	jal	print_nl
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	jr	$ra
