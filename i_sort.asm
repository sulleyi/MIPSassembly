## Sum an array with a subroutine.
## Ian Sulley 02 08 2022

        .data
array:  .word -123, 548, 923, 431, 560, -348, 961
endarr: 
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
        jal isort 			# sort arr

	la $a0, array        		# a0 points into array
        la $a1, endarr       		# a1 points to array end
	jal print_arr 			# print out the sorted array
	
	lw $ra, 0($sp)       		# pop
	addi $sp, $sp, 4    		# ret addr
	# exit program
	li $v0, 10			# system call code for exit = 10
	syscall	
	jr $ra

## insertion sort subroutine
# register use:
#	$a0: parameter: pointer-to-int array
#	$a1: parameter: size of array in ints/words
#	$t0: pointer to int p
#	$t1: pointer to int q
#	$t2: temp storage of current value being sorted
#	$t3: mem address of end of array  
#	$t4: a < q
#	$t5: q - 1
#	$t6: *(q-1) > tmp
#	$t7: = t4 && t5
isort:	add $t0, $0, $a0		# int *p = a;
	add $t1, $0, $0			# int *q;
	add $t2, $0, $0			# int  tmp;
	add $t3, $a0, $a1
	j f_test
loop: 	add $t1, $0, $t0		# q = p;
	lw $t2, 0($t0)			# tmp = *p;

while_test: 				# while ((q > a) && (*(q-1) > tmp)) {
	slt $t4, $a1, $t1		# t4 = (a < q)			
	addi $t5, $t1, -1		# t5 = q-1
	sgt $t6, $t5, $t4		# t6 = t5 > tmp
	and $t7, $t4, $t6		# t7 = t4 && t6
	beq $t7, $0, done_while

	sw $t5, 0($t1)			#	    *q = *(q-1);
	addi $t1, $t1, -1 		#            q--;
					#        }
done_while:
	sw $t2, 0($t1)			#       *q = tmp;
					#    }
					# }
f_test: 				# for (++p;  p < a+asize; p++) {
	blt $t0, $t3, loop	
	jr $ra


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
        j w_test               	# jump to test 
next:   lw $t2, 0($t0)       	# get next array element
	add $a0, $0, $t2 	# move integer to be printed into $a0:  $a0 = $t2
	li $v0, 1 		#syscall to print int
	syscall			# call operating system to perform print
        addi $t0, $t0, 4      	# point to next word
        addi $t3, $t3, 1     	# count++
w_test: blt $t3, $a1, next    	# while t3 < len(arr) do
	jr $ra

