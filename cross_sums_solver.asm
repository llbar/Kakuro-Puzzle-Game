#
# FILE:         $Id$
# AUTHOR:       Lachlan Bartle
#
# DESCRIPTION:
#	This program replicates a cross sums puzzle.
#       This file is the solver algorithm of that puzzle
#       using backracking.

#-------------------------------

#
# CONSTANTS
#

PRINT_INT =     1
PRINT_STRING =  4
EXIT = 	        10

#-------------------------------

#
# DATA AREAS
#
	.data
	.align  0

cell:
        .word   board
        
cell_val:
        .word   0
        
empty_cell:
        .word   0
        
impossible_soln_msg:
        .asciiz "Impossible Puzzle\n\n"
        
board_done:
        .asciiz	"Final Puzzle\n\n"
        
#-------------------------------

#
# CODE AREAS
#
	.text			   # this is program code
	.align  2		   # instructions must be on word
                                   # boundary
        .globl  size
        .globl  find_empty_cell
        .globl  solve_puzzle
        .globl  cell             
        .globl  empty_cell
        .globl  cell_val
        .globl  nl
        .globl  print_board
        .globl  board
        
#-------------------------------

# Entry point for solving the puzzle    
solve_puzzle:
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s1, 4($sp)
	move	$s3, $sp
 
# Main loop for solving the puzzle
solve_puzzle_loop:
	jal	check_goal
	beq	$v0, $zero, not_goal
 	li	$v0, PRINT_STRING
	la	$a0, nl
	syscall
	li	$v0, PRINT_STRING
	la	$a0, board_done
	syscall
	jal	print_board
	li	$v0, PRINT_STRING
	la	$a0, nl
	syscall
	li	$v0, EXIT
	syscall
 
not_goal:
	jal	apply_next_value	
	j	solve_puzzle_loop
	lw	$s1, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
 
# Apply the next value to the puzzle, or go back to previous
apply_next_value:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
 
incr_loop:
	lw	$t0, cell
	lw	$t1, 4($t0)
	li	$t2, 9
	beq	$t1, $t2, undo
	addi	$t1, $t1, 1
	sw	$t1, 4($t0)
	sw	$t0, cell
	jal	validate_move
	beq	$v0, $zero, incr_loop
	j	done_here
 
# Undo the last move
undo:
	
	jal	revert_move
	j	incr_loop
 
# End of applying values, find next empty cell
done_here:
	jal	find_empty_cell
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra 
 
# Revert the last move 
revert_move:
	addi	$sp, $sp, -36
	sw	$ra, 0($sp)
	sw	$t7, 4($sp)
	sw	$t6, 8($sp)
	sw	$t5, 12($sp)
	sw	$t4, 16($sp)
	sw	$t3, 20($sp)
	sw	$t2, 24($sp)
	sw	$t1, 28($sp)
	sw	$t0, 32($sp)
	lw	$t0, cell
	lw	$t1, 4($t0)
	move	$t1, $zero
	sw	$t1, 4($t0)
	sw	$t0, cell
	jal	find_prev_empty
	jal     load_reg
	jr	$ra   
           
# Making my life easier (loading registers)
load_reg:
        lw	$ra, 0($sp)
	lw	$t7, 4($sp)
	lw	$t6, 8($sp)
	lw	$t5, 12($sp)
	lw	$t4, 16($sp)
	lw	$t3, 20($sp)
	lw	$t2, 24($sp)
	lw	$t1, 28($sp)
	lw	$t0, 32($sp)
	addi	$sp, $sp, 36
	jr	$ra
 
load_half_reg:
        lw	$t7, 0($sp)
	lw	$t6, 4($sp)
	lw	$t5, 8($sp)
	lw	$t4, 12($sp)
        lw	$ra, 16($sp)
	addi	$sp, $sp, 20
        jr      $ra

# Display message for impossible puzzle   
impossible_soln:
	li	$v0, PRINT_STRING
	la	$a0, impossible_soln_msg
	syscall
	li	$v0, EXIT
	syscall
 
# Check if the puzzle is solved by searching for 
# empty squares
check_goal:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	has_empty_cells
	move	$s1, $v0
	move	$v0, $s1
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
 
has_empty_cells:
	la	$t0, board
	lw	$t1, size
	mul	$t1, $t1, $t1
 
has_empty_cells_loop:
	beq	$t1, $zero, block_clue_rt
	lw	$t2, 0($t0)
	lw	$t3, 4($t0)
	beq	$t2, $t3, is_empty
	addi	$t1, $t1, -1
	addi	$t0, $t0, 8
	j	has_empty_cells_loop
 
is_empty:
	move	$v0, $zero
	jr	$ra
 
# Validate the move
validate_move:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	validate_row
	move	$s1, $v0
	jal	validate_column
	and	$s1, $s1, $v0
	jal	check_row_duplicates
	and	$s1, $s1, $v0
	jal	check_column_duplicates
	and	$s1, $s1, $v0
	move	$v0, $s1
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
 
# Find the next empty cell
find_empty_cell:
	la	$t0, board
	lw	$t1, 0($t0)
	lw	$t3, 4($t0)
	move	$t2, $zero

find_empty_cell_loop:
	beq	$t1, $t3, find_empty_cell_done
	addi	$t0, $t0, 8
	addi	$t2, $t2, 1
	lw	$t1, 0($t0)
	lw	$t3, 4($t0)
	j	find_empty_cell_loop
 
find_empty_cell_done:
	sw	$t0, cell
	sw	$t2, cell_val
        jr      $ra

# Find the previous empty cell
find_prev_empty:	
	lw	$t0, cell
	addi	$t0, $t0, -8
	lw	$t1, 0($t0)
	lw	$t2, cell_val
	addi	$t2, $t2, -1
	lw	$s4, empty_cell
	addi	$s4, $s4, -1
	beq	$s4, $t2, impossible_soln
 
find_prev_empty_loop:
	beq	$t1, $zero, find_empty_cell_done
	addi	$t0, $t0, -8
	addi	$t2, $t2, -1
	lw	$t1, 0($t0)
	j	find_prev_empty_loop
 
# Validate a row
validate_row:
	addi	$sp, $sp, -36
	sw	$ra, 0($sp)
	sw	$t7, 4($sp)
	sw	$t6, 8($sp)
	sw	$t5, 12($sp)
	sw	$t4, 16($sp)
	sw	$t3, 20($sp)
	sw	$t2, 24($sp)
	sw	$t1, 28($sp)
	sw	$t0, 32($sp)  
	lw	$t0, cell
	lw	$t1, cell_val
	lw	$t2, size
	move	$t5, $zero
 
validate_row_loop:
	lw	$t3, 0($t0)
	lw	$t4, 4($t0)
	add	$t5, $t5, $t4
	move	$a0, $t1
	lw	$a0, -8($t0)
	jal	block_clue
	move	$t4, $v0
	bne	$t4, $zero, done_row_loop
	addi	$t0, $t0, -8
	j	validate_row_loop
 
done_row_loop:
	move	$t1, $t0
	jal	last_horizontal
	move	$a0, $v0
	li	$v0, PRINT_INT
	move	$v0, $a0
	move	$t0, $t1
	move	$t4, $v0
	lw	$t7, -8($t0)
	div	$t7, $t7, 100
	move	$a0, $t7
	li	$v0, PRINT_INT
	move	$a0, $t5
	li	$v0, PRINT_INT
	bne	$t4, $zero, check_horizontal
	slt	$t5, $t5, $t7
	bne	$t5, $zero, horizontal_loop_rt
	move	$v0, $zero
	jr	$ra	
 
check_horizontal:
	beq	$t5, $t7, horizontal_loop_rt
	move	$v0, $zero	
        jal     load_reg
        jr      $ra
 
horizontal_loop_rt:
	li	$v0, 1
        jal     load_reg
	jr	$ra
 
# Find the last horizontal clue in a row
last_horizontal:
        addi	$sp, $sp, -20
	sw	$t7, 0($sp)
	sw	$t6, 4($sp)
	sw	$t5, 8($sp)
	sw	$t4, 12($sp)
        sw	$ra, 16($sp)
	lw	$t5, cell
	lw	$t4, 0($t5)
	lw	$t5, 8($t5)
	lw	$t6, cell_val
	sne	$t0, $t5, $zero
	move	$v0, $zero
	move	$a0, $t6
	jal	find_right_wall
	move	$s5, $v0
	move	$v0, $s5
	or	$v0, $t0, $v0
        jal     load_half_reg
	jr	$ra
 
# Validate a column
validate_column:
	addi	$sp, $sp, -36
	sw	$ra, 0($sp)
	sw	$t7, 4($sp)
	sw	$t6, 8($sp)
	sw	$t5, 12($sp)
	sw	$t4, 16($sp)
	sw	$t3, 20($sp)
	sw	$t2, 24($sp)
	sw	$t1, 28($sp)
	sw	$t0, 32($sp)
	lw	$t0, cell
	lw	$t1, cell_val
	move	$t5, $zero
 
validate_column_loop:
	lw	$t3, 0($t0)
	lw	$t4, 4($t0)
	add	$t5, $t5, $t4
	move	$a0, $t1
	lw	$t2, size
	mul	$t2, $t2, 8
	move	$a0, $t0
	sub	$a0, $a0, $t2
	lw	$a0, 0($a0)
	jal	block_clue
	move	$t4, $v0
	bne	$t4, $zero, done_column_loop
	sub	$t0, $t0, $t2
	j	validate_column_loop
 
done_column_loop:
	jal	last_vertical
	move	$t4, $v0
	lw	$t2, size
	mul	$t2, $t2, 8
	move	$t6, $t2
	move	$t7, $t0
	sub	$t7, $t7, $t6
	lw	$t7, 0($t7)
	rem	$t7, $t7, 100
	bne	$t4, $zero, check_vertical
	slt	$t5, $t5, $t7
	bne	$t5, $zero, horizontal_loop_rt
	move	$v0, $zero
        jal     load_reg
	jr	$ra
        	
check_vertical:
	beq	$t5, $t7, horizontal_loop_rt
	move	$v0, $zero	
        jal     load_reg
	jr	$ra
 
# Find the last vertical clue in a column
last_vertical:
        addi	$sp, $sp, -20
	sw	$t7, 0($sp)
	sw	$t6, 4($sp)
	sw	$t5, 8($sp)
	sw	$t4, 12($sp)
        sw	$ra, 16($sp)
	lw	$t7, cell
	lw	$t5, size
	mul	$t5, $t5, 8
	add	$t7, $t7, $t5
	lw	$t7, 0($t7)
	lw	$t6, cell_val
	sne	$t7, $t7, $zero
	move	$v0, $zero
	move	$a0, $t6
	jal	find_lower_wall
	or	$v0, $t7, $v0
        jal     load_half_reg
	jr	$ra
 
# Checks for duplicates in columns
check_column_duplicates:	
        addi	$sp, $sp, -20
	sw	$t7, 0($sp)
	sw	$t6, 4($sp)
	sw	$t5, 8($sp)
	sw	$t4, 12($sp)
        sw	$ra, 16($sp)
	lw	$t7, cell
	lw	$t3, size
	mul	$t3, $t3, -8
 
cd_outer_loop:
	lw	$t6, 0($t7)
	move	$t4, $t7
	add	$t4, $t4, $t3
	move	$a0, $t6
	jal	block_clue
	lw	$t6, 4($t7)
	bne	$v0, $zero, found_duplicate
 
cd_inner_loop:
	lw	$t5, 0($t4)
	move	$a0, $t5
	jal	block_clue
	bne	$v0, $zero, vertical_duplicates
	lw	$t5, 4($t4)
	beq	$t5, $t6, no_duplicates
	add	$t4, $t4, $t3
	j	cd_inner_loop
 
vertical_duplicates:
	add	$t7, $t7, $t3
	j	cd_outer_loop
 
no_duplicates:
        jal     load_half_reg
	move	$v0, $zero
	jr	$ra
 
found_duplicate:
        jal     load_half_reg
	li	$v0, 1
	jr	$ra    

check_row_duplicates:
        addi	$sp, $sp, -20
	sw	$t7, 0($sp)
	sw	$t6, 4($sp)
	sw	$t5, 8($sp)
	sw	$t4, 12($sp)
        sw	$ra, 16($sp)	
	lw	$t7, cell
	lw	$t4, cell
 
rd_outer_loop:
	lw	$t6, 0($t7)
	move	$t4, $t7
	addi	$t4, $t4, -8
	move	$a0, $t6
	jal	block_clue
	lw	$t6, 4($t7)
	bne	$v0, $zero, found_duplicate
 
rd_inner_loop:
	lw	$t5, 0($t4)
	move	$a0, $t5
	jal	block_clue
	bne	$v0, $zero, horizontal_duplicates
	lw	$t5, 4($t4)
	beq	$t5, $t6, no_duplicates
	addi	$t4, $t4, -8
	j	rd_inner_loop
 
# Checks for duplicates in horizontal
horizontal_duplicates:
	addi	$t7, $t7, -8
	j	rd_outer_loop
        jal     no_duplicates
        jr      $ra
 
# Check if value is clue
block_clue:
	bne	$a0, $zero, block_clue_rt
	move	$v0, $zero
	jr	$ra
 
block_clue_rt:
	li	$v0, 1
	jr	$ra

# Find the left wall for a row
find_left_wall:
	beq	$a0, $zero, block_clue_rt
	lw	$t2, size
	div	$v0, $a0, $t2
	mfhi	$v0
	beq	$v0, $zero, block_clue_rt
	move	$v0, $zero
	jr	$ra
 
# Find the right wall for a row
find_right_wall:
	lw	$t7, cell_val
	lw	$t2, size
	div	$t6, $t7, $t2
	mfhi	$t6
	li	$v0, PRINT_INT
	move	$a0, $t6
	move	$t7, $zero
	lw	$t7, size
	addi	$t7, $t7, -1
	li	$v0, PRINT_INT
	move	$a0, $t7
	beq	$t6, $t7, block_clue_rt
	move	$v0, $zero
	jr	$ra
 
# Check if square is on the upper wall
find_upper_wall:
	lw	$t7, size
	move	$t6, $a0
	slt	$v0, $t6, $t2
	bne	$v0, $zero, block_clue_rt
	move	$v0, $zero 
	jr	$ra
 
# Check if square is on the lower wall
find_lower_wall:
	addi	$sp,$sp,-16	
	sw	$t7, 0($sp)
	sw	$t6, 4($sp)
	sw	$t5, 8($sp)
	sw	$t4, 12($sp)
	move	$t6, $a0
	lw	$t7, size
	mul	$t5, $t7, $t7
	sub	$t5, $t5, $t7
	slt	$v0, $t6, $t5
	beq	$v0, $zero, lower_wall_rt
	move	$v0, $zero
        lw	$t7, 0($sp)
	lw	$t6, 4($sp)
	lw	$t5, 8($sp)
	lw	$t4, 12($sp)
	addi	$sp, $sp, 16
	jr	$ra
 
lower_wall_rt:
	li	$v0, 1
        lw	$t7, 0($sp)
	lw	$t6, 4($sp)
	lw	$t5, 8($sp)
	lw	$t4, 12($sp)
	addi	$sp, $sp, 16
	jr	$ra
