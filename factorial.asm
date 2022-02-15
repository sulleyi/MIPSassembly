#a0:n

fact:
    bne $a0 $0 else
    addi $v0 $0 1
    jr $ra
else:
    addi $sp $sp -8
    sw $a0 0($sp)
    sw $ra 4($sp)
    addi $a0 $a0 -1
    jal fact
    lw $a0 0($sp)
    mul $v0 $a0 $v0
    lw $ra 4($sp)
    addi $sp $sp 8
    jr $ra


