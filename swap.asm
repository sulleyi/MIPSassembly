#   swap.asm Ian Sulley 02 01 2022	
#   Elementary program to swap the content of 2 array indexs.
#   Register use:
#	$t0: stores base address of array 
#	$t5: stores value of i 
#	$t6: stores value of k
#	$t1: memory address of first index
#	$t2: memory address of second index
#	$t3: value at first index 
#	$t4: value at second index 
#	$v0, $a0: hold parameters to syscall

        .data                   # FYI: start of data section
ar:     .word 5, 17, -3, 22, 120, -1      # a six-element array
i:      .word 1                 #index to swap   
k:      .word 3                 #other index to  swap

        .text                   # FYI: start of code section
        .align 2                # FYI: align to start code on a word boundary
        .globl main             # FYI: make 'main' visible to the simulator
main:                           # main() { #swaps content of index 0 and index 5
        la  $t0, ar             #put mem address of ar[] into $t0
        lw $t5, i               # load i into $t5  
        lw $t6, k               # load k into $t6
        sll $t1, $t5, 2         # t1 = i*4
        sll $t2, $t6, 2         # t2 = k*4
        add $t1, $t0, $t1        # t1 = &ar[i]
        add $t2, $t0, $t2        # t2 = &ar[k]
        lw  $t3, 0($t1)         #t3 = ar[i]
        lw  $t4, 0($t2)         #t4 = ar[k]
        sw  $t3, 0($t2)         # ar[k] = t3
        sw  $t4, 0($t1)         # ar[i] = t4
                                # }
        li $v0,10
        syscall                                      


