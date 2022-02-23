## Sum an array with a subroutine.
## Ian Sulley 02 08 2022

        .data
array:  .word -123, 548, 923, 431, 560, -348, 961
endarr: .word 7 
        .text
        .align 2
main:   la $a0, array        		# a0 points into array
        la $a1, endarr       		# a1 points to array end
        sub $a1, $a1, $a0    		# a1 = &endarr - &arr   <-- len(arr) in bytes
        srl $a1, $a1, 2      		# a1 = a1/4   <-- len(arr) in words
	addi $sp, $sp, -4   		# push 
	sw $ra, 0($sp)       		# ret addr on stack
	jal print_arr			# print unsorted arr

	la $a0, array        		# a0 points into array
        la $a1, endarr       		# a1 points to array end
        sub $a1, $a1, $a0    		# a1 = &endarr - &arr   <-- len(arr) in bytes
        srl $a1, $a1, 2      		# a1 = a1/4   <-- len(arr) in words
        jal isort 			# sort arr

	la $a0, array        		# a0 points into array
        la $a1, endarr       		# a1 points to array end
        sub $a1, $a1, $a0    		# a1 = &endarr - &arr   <-- len(arr) in bytes
        srl $a1, $a1, 2      		# a1 = a1/4   <-- len(arr) in words
	jal print_arr 			# print out the sorted array
	
	lw $ra, 0($sp)       		# pop
	addi $sp, $sp, 4    		# ret addr
	# exit program
	li $v0, 10			# system call code for exit = 10
	syscall	
	jr $ra

## insertion sort subroutine
# register used
#	$a0: parameter: pointer-to-int array - Base address
#	$a1: parameter: size of array in bytes
##
#	$t0: pointer to int p - address of first unsorted index
#	$t1: pointer to int q - address of test index
#	$t2: value @ test index
#	$t3: mem address of beginning of array  
#	$s0: value to insert
#	$s1: address of last array element
isort:	
	la $t0, array			# t0 = array base address
	addi $t0, $t0, 4		# t0 = first unsorted address
	#add $t3, $0, $a1		
	la $t3, endarr 			# t3 = end array address
	addi $s1, $t3, -4		# s1 = address of last array element 
	la $t3, array
f_test: 				# for (++p;  p < a+asize; p++) {
	bgt $t0, $s1, f_done		# branch if first unsorted index > end address
	addi $t1, $t0, -4		# t1 = address of next item to sort
	lw $s0, 0($t0)			# t2 = current value pointed to by t0
while: 					# while ((q > a) && (*(q-1) > tmp)) {
	blt $t1, $t3, w_done		# branch if address of item to sort < end address			
	lw $t2, 0($t1)			# s0 = value of next item to sort
	ble $t2, $s0, w_done		# branch if value of next item to sort <= current unsorted value
	sw $t2, 4($t1)			# insert value into next address
	addi $t1, $t1, -4 		# move pointer; get address of next index to sort
	j while				# jump to while test
w_done:
	sw $s0, 4($t1)			# save value at first unsorted index into next address 
	addi $t0, $t0, 4		# move pointer of unsorted index forward 
	j f_test			# jump to for test
f_done:
	jr $ra				# jump to return address	


##print_arr
## register use:
##	$a0: parameter: array addr; used as pointer to current element
##	$a1: parameter: size of arr 
##	$v0: accumulator and return value
##	$t2: temporary copy of current array element
##	$t0: a0 from first call to print_arr 
print_arr: 
	add $t0, $0, $a0 
        li $t3, 0		# initialize counter
        j w_test2               # jump to test 
next:   
	lw $t2, 0($t0)       	# get next array element
	add $a0, $0, $t2 	# move integer to be printed into $a0:  $a0 = $t2
	li $v0, 1 		# syscall to print int
	syscall			# call operating system to perform print
        addi $t0, $t0, 4      	# point to next word
        addi $t3, $t3, 1     	# count++
w_test2:
	blt $t3, $a1, next    	# while t3 < len(arr) do
	jr $ra

