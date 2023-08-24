.globl main

.data
str1: .space 17
str2: .space 17

.text
main:
	# read the two strings
	li $v0, 8	# read string system call
	la $a0, str1	# load the address of the input buffer
	li $a1, 17	# maximum number of characters to read
	syscall
	
	li $v0, 8
	la $a0, str2
	li $a1, 17
	syscall
	
	# load the strings in s6 and s7
	la $s6, str1
	la $s7, str2
	
	# initialize final result to 0
	li $s0, 0
	
# length of the shorter string
li $s1, 16
la $t9, str1
# length counter
li $t8, 0
# calculate length of str1
str1_length_loop:
	lb $t7, ($t9)
	beqz $t7, str1_length_done
	addi $t8, $t8, 1
	addi $t9, $t9, 1
	j str1_length_loop
	
str1_length_done:
addi $t8, $t8, -1
# move the result to s1
move $s1, $t8
la $t9, str2
# length counter
li $t8, 0
# calculate length of str1
str2_length_loop:
	lb $t7, ($t9)
	beqz $t7, str2_length_done
	addi $t8, $t8, 1
	addi $t9, $t9, 1
	j str2_length_loop
# move the result to $s2
str2_length_done:
addi $t8, $t8, -1
# bgt $t8, $s1, str1_shorter
move $s2, $t8
# str1_shorter:

# str1 in $s6, str2 in $s7, length of str1 in $s1, length of str2 in $s2, final result(now 0) in $s0

# Pseudocode:
# LCS(s1, s2, i, j):
#     if(i == -1 || j == -1)
#         return 0
#     if(s1[i] == s2[j])
#         return 1 + LCS(s1, s2, i-1, j-1)
#     return max(LCS(s1, s2, i-1, j), LCS(s1, s2, i, j-1))

lcs_length:
	# move lengths into arguments
	move $a0, $s1
	move $a1, $s2
	
	# turn them into indices
	addi $a0, $a0, -1
	addi $a1, $a1, -1
	
	# call recursive function
	jal lcs_rec
	
	# print the result
	move $a0, $v0
	li $v0, 1
	syscall
	
	# exit program
	li $v0, 10
	syscall

# Pseudocode:
# LCS(s1, s2, i, j):
#     if(i == -1 || j == -1)
#         return 0
#     if(s1[i] == s2[j])
#         return 1 + LCS(s1, s2, i-1, j-1)
#     return max(LCS(s1, s2, i-1, j), LCS(s1, s2, i, j-1))
lcs_rec:
	# save ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	#     if(i == -1 || j == -1)
	#         return 0
	beq $a0, -1, ret0
	beq $a1, -1, ret0
	
	# see the chars at s1[i] and s2[j]
	la $t0, str1
	la $t1, str2
	add $t0, $t0, $a0
	add $t1, $t1, $a1
	
	# load char from both strings
	lb $t2, ($t0)
	lb $t3, ($t1)
	
	beq $t2, $t3, eqchar
	
	jal noneqchar
	
	ret0:
		li $v0, 0
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
	eqchar:
		# return 1 + LCS(s1, s2, i-1, j-1)
		addi $a0, $a0, -1
		addi $a1, $a1, -1
		jal lcs_rec
		addi $v0, $v0, 1
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
	noneqchar:
		# return max(LCS(s1, s2, i-1, j), LCS(s1, s2, i, j-1))
		# save argumi
		addi $sp, $sp, -12
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		
		# i - 1, j
		addi $a0, $a0, -1
		jal lcs_rec
		sw $v0, 8($sp)
		
		#restore argumi
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		addi $sp, $sp, 8
		# i, j - 1
		addi $a1, $a1, -1
		jal lcs_rec
		
		# result of second call in $t1
		move $t1, $v0
		# result of first call in $t0
		lw $t0, 0($sp)
		addi $sp, $sp, 4
		
		# $t0 = max($t0, $t1)
		slt $t2, $t0, $t1
		movn $t0, $t1, $t2
		
		# return $t0
		move $v0, $t0
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
