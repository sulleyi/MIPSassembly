## Fib calculator 
## John Rieffel 11 February 2022

PR_INT = 1                   # (example of defining a constant)
        .data
n:	.word 8
        .text
        .align 2
main:   lw $a0, n	     # a0 contains n
	addi $sp, $sp, -4    # push 
	sw $ra, 0($sp)       # ret addr on stack
        jal fib 
	lw $ra, 0($sp)       # pop
	addi $sp, $sp, 4     # ret addr
        add $a0, $0, $v0     # copy result into $a0
        addi $v0, $0, PR_INT # print code in $v0
        syscall
        jr $ra                  

## fib subroutine
## register use:
##	$a0: parameter: N

fib:    addi $t0 $0 1		# move 1 into t0
        beq  $a0 $t0 base       # check if N = 1
	bne  $a0 $0  recur      # check if N = 1 
base: 	addi $v0 $0 1 
	jr $ra

recur:  addi $sp $sp -12	# make room on stack
	sw $ra 0($sp)		# store RA 
	sw $a0 4($sp)		# store a0 on stack
	addi $a0 $a0 -1         # N - 1
	jal fib			# v0 = fib(n-1) 
	sw $v0 8($sp)		# put fib(n-1) somehwere safe
	lw $a0 4($sp)           # restore N
	addi $a0 $a0 -2		# N - 2
	jal fib			# v0 = fib (n-2)
	lw $t0 8($sp)		# pop fib(n-1) off stack
	add $v0 $v0 $t0    	# fib(n-1) + fib(n-2)
	lw $ra 0($sp)		# restore ra
	addi $sp $sp 12		# restore stack
done:   jr $ra			# return

