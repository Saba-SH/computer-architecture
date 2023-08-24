.globl main

.data
# hardcoded strings for output
no_message: .asciiz "NO\n"
yes_message: .asciiz "YES\n"
space_str: .asciiz " "
newline_str: .asciiz "\n"
# fixed-size(25) array for the set
arr: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

.text
main:
	# initialize size of array to 0
	li $s3, 0
	# read N into $s0
	li $v0, 5
	syscall
	move $s0, $v0
	
	# initialize loop counter
	li $s4, 0
	loop:
		# exit if all iterations have passed
		bge $s4, $s0, exit
		
		# read operation code in $s1
		li $v0, 5
		syscall
		move $s1, $v0
		
		# 4 -> print set
		beq $s1, 4, pront
		
		# read argument for operation
		li $v0, 5
		syscall
		move $s2, $v0
		
		# 1 -> insert
		beq $s1, 1, insert
		# 2 -> erase
		beq $s1, 2, erase
		# 3 -> find
		beq $s1, 3, find
		
		# continuiing loop after operation
		keepLoop:
		addi $s4, $s4, 1
		j loop
	# exit program
	exit:
		li $v0, 10
		syscall

# $a0 = arr[$a0]
loadAtIndex:
	sll $a0, $a0, 2
	la $t9, arr
	add $t9, $t9, $a0
	lw $a0, ($t9)
	jr $ra

# arr[$a1] = $a0
storeAtIndex:
	sll $a1, $a1, 2
	la $t9, arr
	add $t9, $t9, $a1
	sw $a0, ($t9)
	jr $ra
	
# assume $s2 contains the number to operate on
# assume $s3 contains the current size of the array
insert:
	# set $t0 to 0 (array index)
	move $t0, $zero
insloop:
	# if we reached end of array, exit loop
	beq $t0, $s3, endinsloop
	
	# load value at index $t0 into $t1
	move $a0, $t0
	jal loadAtIndex
	move $t1, $a0
	
	# if value at index $t0 is not equal to $s2, continue searching
	bne $t1, $s2, insnotfound
	# if we found $s2, resume program
	j keepLoop

insnotfound:
	# if value at index $t0 is smaller than $s2, continue searching
	blt $t1, $s2, insnext

	# if we find a bigger number in the array, shift every number starting there one int(4 bytes) to the right
 	# set $t2 to the last index in the array
 	addi $t2, $s3, -1
shiftinsloop:
	# load value from arr[$t2] into $t3
	move $a0, $t2
	jal loadAtIndex
	move $t3, $a0
	
	# increment index at $t2
	addi $t2, $t2, 1
	
	# store the loaded value at the incremented index(one int to the right)
	move $a0, $t3
	move $a1, $t2
	jal storeAtIndex

	# decrement index
	subi $t2, $t2, 2
	# repeat until we reach the index where we insert our new number
	bge $t2, $t0, shiftinsloop

	# place $s2 number at the correct position
	move $a0, $s2
	move $a1, $t0
	jal storeAtIndex
	
	# increment size of array
	addi $s3, $s3, 1
	j keepLoop

insnext:
	# increment index and continue loop
	addi $t0, $t0, 1
	j insloop

endinsloop:
	# if we go $s3 iterations without finding a bigger number, add $s2 to the end of array
	move $a0, $s2
	move $a1, $t0
	jal storeAtIndex
	
	# increment size of array
	addi $s3, $s3, 1
	j keepLoop

j keepLoop

erase:
	#set index to zero
	move $t0, $zero	
eraloop:
	# $t1 = arr[$t0]
	move $a0, $t0
	jal loadAtIndex
	move $t1, $a0
	
	# if not equal to $s2, check next element
	bne $t1, $s2, eranext

erashift:
	# shift all elements starting at $0 to the left
	# arr[$t0] = arr[$t0 + 1]
	move $a0, $t0
	addi $a0, $a0, 1
	jal loadAtIndex
	
	move $a1, $t0
	jal storeAtIndex
	
	# $t0++
	addi $t0, $t0, 1
	
	# if there are more elements to shift, continue
	bne $t0, $s3, erashift
	
	# decrement array size
	addi $s3, $s3, -1
	j keepLoop

eranext:
	# move to next element
	addi $t0, $t0, 1
	bne $t0, $s3, eraloop

j keepLoop

find:
        move $t0, $zero

findloop:
	# end loop if $t0 == $s3
	beq $t0, $s3, findnotfound

	# load array element to $t1
	move $a0, $t0
	jal loadAtIndex
	move $t1, $a0
	
	# jump to "found" if element == $s2
	beq $t1, $s2, findfound

	addi $t0, $t0, 1
	j findloop

findfound:
	# print "YES"
	li $v0, 4
	la $a0, yes_message
	syscall

        j keepLoop
        
findnotfound:
	# print "NO"
	li $v0, 4
	la $a0, no_message
	syscall
	
	j keepLoop

j keepLoop

# pront(print), not print
pront:
	move $t0, $zero
    
prontloop:
	bge $t0, $s3, endpront
	
	move $a0, $t0
	jal loadAtIndex
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, space_str
	syscall

	addi $t0, $t0, 1
	
	j prontloop
	
endpront:
	li $v0, 4
	la $a0, newline_str
	syscall

j keepLoop
