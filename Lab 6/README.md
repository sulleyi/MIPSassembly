# Ian Sulley: CSC-270 Lab 6

<aside>
🔃 Working with Subroutines and Arrays

</aside>

---

---

## array_sum.asm

The `array_sum` subroutine takes an array of intergers (32 bit) and computes their sum. 

```graphql
## Sum an array with a subroutine.
## Ian Sulley 02 08 2022

        .data
str:	.asciiz "Sum of all Array elements\n"

array:  .word -123, 548, 923, 431, 560, -348, 961
endarr: 
        .text
        .align 2
```

<aside>
⚠️ The code here is partitioned by execution order, and is not the same as how the code appears in the array_sum.asm file. This is to illustrate the effect of `jal` instructions on instruction execution order.

</aside>

The instructions within the `main:` tag load inital values into the registers before calling the `array_sum` subroutine. `$a0` is loaded with the base address of `array`, and `$a1`is loaded with the address at the end of `array`. the next two instructions convert `$a1` to now represent the length of `array` in words. the next two instructions push the return address value in `$ra` onto the stack. `jal arrsum` calls the subroutine to compute the summation.

The `arrsum:` subroutine begins by clearing the `$v0` register to 0, which will be used in the loop to hold the summation. `$t3` is also initialized to 0 to act as a counter. `j test` brings us to the `test:` tag. `blt` instructs to go to `sum:` if `$t3 < $a1`. `sum` is the loop body. It first loads the current value in the array, adds it to the acculator, points to the next index in the array and increments the counter once. when the last the counter value, `$t3`, is equal to the length of the array the branch is not taken and    `jr $ra` returns the program to the previous `jal` instruction.

 

returning back to the main instruction set, the return value `$v0` holding the sum of array elements is copied into `$s0`. `$ra` is loaded from the stack. The first `syscall` prints the string,

<aside>
➡️ "Sum of all Array elements\n"

</aside>

The next `syscall` prints the integer value of the sum of array elements. The final `syscall` exits the program.

 

```graphql

main:   la $a0, array        		# a0 points into array
        la $a1, endarr       		# a1 points to array end
        sub $a1, $a1, $a0    		# a1 = &endarr - &arr   <-- len(arr) in bytes
        srl $a1, $a1, 2      		# a1 = a1/4   <-- len(arr) in words
				 addi $sp, $sp, -4    		# push 
				 sw $ra, 0($sp)       		# ret addr on stack
        jal arrsum
				 ..
				####BREAK IN MAIN####
```

```graphql
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
```

```graphql
				 ####CONTINUATION OF MAIN####
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
```

---

---

## i_sort.acm

```graphql
## Insertion Sort Subroutine
## Ian Sulley 02 08 2022

        .data
array:  .word -123, 548, 923, 431, 560, -348, 961
endarr: .word 7 
        .text
        .align 2
```

The main subroutine begins by loading relevant array addresses, and doing many of the same setup tasks seen in array_sum. `jal print_arr` jumps to the subroutine that prints the array (see below). 

Reinitialzing some values (could also do this with the stack). 

`jal isort` jumps to the insertion sort subroutine (see below).

pop the return address from the stack.

`syscall` to exit program.

```graphql
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
```

Comments note what registers are used to store which values.

The beginning of the isort routine loads relevant values into their corresponding registers as defined in the above comments. 

`f_test` notes the test at each iteration of the for loop. 

`while` notes the loop tests and iterates through the array.

`w_done:` inserted a sorted value and moves the sorted pointer up one index. Then, the for loop test is run again.

`f_done:` returns to the previous `jal` instruction.

```graphql
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
				lw $s0, 0($t0)			# s0 = current value pointed to by t0
while: 					# while ((q > a) && (*(q-1) > tmp)) {
				blt $t1, $t3, w_done		# branch if address of item to sort < end address			
				lw $t2, 0($t1)			# t2 = value of next item to sort
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
```

The `print_arr` subroutine iterates through an array and prints each of the values at each word-length index.

```graphql
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
```