## Sum an array with a subroutine.
## Ian Sulley 02 08 2022

                             # REMOVE this comment and the next one
PR_INT = 1                   # (example of defining a constant)
        .data
array:  .word -123, 548, 923, 431, 560, -348, 961
endarr: 
        .text
        .align 2
main:   la $a0, array        # a0 points into array
        la $a1, endarr       # a1 points to array end
        sub $a1, $a1, $a0    # a1 = &endarr - &arr   <-- len(arr) in bytes
        srl $a1, $a1, 2      #a1 = a1/4   <-- len(arr) in words
	addi $sp, $sp, -4    # push 
	sw $ra, 0($sp)       #   ret addr on stack
        jal arrsum
	lw $ra, 0($sp)       # pop
	addi $sp, $sp, 4     #   ret addr
        add $a0, $0, $v0     # copy sum into $a0
        addi $v0, $0, PR_INT # print code in $v0
        syscall
        jr $ra                  

## array-summation subroutine
## register use:
##	$a0: parameter: array addr; used as pointer to current element
##	$a1: parameter: size of arr 
##	$v0: accumulator and return value
##	$t2: temporary copy of current array element
arrsum: move $v0, $0         # v0 accumulates sum
        move $t3, $0
        j test               #    and do it again
sum:    lw $t2, 0($a0)       #    get next array element
        add $v0, $v0, $t2    #    add it in
        sll $a0, $a0, 2      #    point to next word
        addi $t3, $t3, 1     # count++
test:   ble $t3, $a1, done   # while t3 < len(arr) do
done:   jr $ra
