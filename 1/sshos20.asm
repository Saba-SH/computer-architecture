# 47
.globl main
.text
main:
	li $v0, 5
	syscall
	move $t0, $v0
	
	li $v0, 5
	syscall
	move $t1, $v0
	
	li $v0, 5
	syscall
	move $t2, $v0
	
	sub $t3, $t2, $t0
	sub $t4, $t2, $t1
	
	abs $t3, $t3
	abs $t4, $t4
	
	bge $t4, $t3, bal
	
	li $v0, 1
	li $a0, 2
	syscall
	li	$v0, 10		# Exit
	syscall
	
bal:
	li $v0, 1
	li $a0, 1
	syscall
	li	$v0, 10		# Exit
	syscall