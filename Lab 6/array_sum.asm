## Sum an array with a subroutine.
## Ian Sulley 02 08 2022

        .data
str:	.asciiz "Sum of all Array elements\n"

array:  .word -123, 548, 923, 431, 560, -348, 961
endarr: 
        .text
        .align 2
main:   la $a0, array        		# a0 points into array
        la $a1, endarr       		# a1 points to array end
        sub $a1, $a1, $a0    		# a1 = &endarr - &arr   <-- len(arr) in bytes
        srl $a1, $a1, 2      		# a1 = a1/4   <-- len(arr) in words
	addi $sp, $sp, -4    		# push 
	sw $ra, 0($sp)       		# ret addr on stack
        jal arrsum
        add $s0, $0, $v0    	 	# copy sum into $s0
	lw $ra, 0($sp)       		# pop
	addi $sp, $sp, 4     		# ret addr
	# print out the result string
	li $v0, 4			# system call code for printing string = 4
	la $a0, str			# load address of string to be printed into $a0
	syscall				# call operating system to perform print operation
	# print out integer value in $t1
	add $a0, $0, $s0 		# move integer to be printed into $a0:  $a0 = $s0
	li $v0, 1 
	syscall				# call operating system to perform print
	# exit program
	li $v0, 10			# system call code for exit = 10
	syscall	
	jr $ra

## array-summation subroutine
## register use:
##	$a0: parameter: array addr; used as pointer to current element
##	$a1: parameter: size of arr 
##	$v0: accumulator and return value
##	$t2: temporary copy of current array element
arrsum: li $v0, 0         		# v0 accumulates sum
        li $t3, 0
        j test               		# check test
sum:    lw $t2, 0($a0)       		# get next array element
        add $v0, $v0, $t2    		# add it in
        addi $a0, $a0, 4      		# point to next word
        addi $t3, $t3, 1     		# count++
test:   blt $t3, $a1, sum    		# while t3 < len(arr) do
	jr $ra

