# 486
.globl main
.data
	newline: .asciiz "\n"
.text
main:
	# read input
	li $v0, 5
	syscall
	move $t0, $v0
	
	li $v0, 5
	syscall
	move $t1, $v0
	
	move $t2, $t0
	move $t3, $t1
	
	j loop
	
loop:
	beqz 	$t3, finish
	
	div 	$t2, $t3
	mfhi	$t4
	move	$t2, $t3
	move 	$t3, $t4
	
	j	loop
	
finish:
	div $t5, $t0, $t2
	div $t6, $t1, $t2
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall
	
	li $v0, 10
	syscall
