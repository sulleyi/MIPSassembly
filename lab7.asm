#  Linked structures in assembler       D. Hemmendinger  24 January 2009
#  Linked structures in assembler       J. Rieffel 15 February 2011
#  Linked structures in assembler       I. Sulley 22 February 2022
# (removed dependance on in-line constant definitions)
#  This program builds a heap as a singly-linked list of nodes that
#  are then used to build a singly-linked list of numbers.
#       mknodes: builds a linked list of free nodes from an 
#                 unstructured heap space. 
#       new:    (you complete it) returns a node from the free list
#       insert: (you write) inserts an integer into a linked list, in order.
#       print:  (you write) traverses a list and prints its contents neatly

## System calls
PR_INT = 1
PR_STR = 4

## Node structure
NEXT     = 0                    ## offset to next pointer
DATA     = 4                    ## offset to data
DATASIZE = 4
NODESIZE = 8    ##DATA + DATASIZE       bytes per node
NUMNODES = 15           
HEAPSIZE = 120  ##NODESIZE*NUMNODES
NIL      = 0                    ## for null pointer

        .data
input: .word 5, 7, 25, 9, 8, -14 ## you add more numbers here  (no more than NUMNODES)
inp_end:
INSIZE = 1 #(inp_end - input)/4    # number of input array elements

list:   .space  4
heap:   .space  HEAPSIZE           # storage for nodes 
spce:   .asciiz "  "
nofree: .asciiz "\nOut of free nodes; terminating program"
unsorted: .asciiz "\nUnsorted List: "
sorted: .asciiz "\nSorted List: "

        .align 2
        .text
main:   addi $sp, $sp, -4	
        sw $ra, 0($sp)		# save $ra to the stack
        li $s7, NIL             # global variable holding the NIL value
        la $a0, heap            # pass the heap address to mknodes
        li $a1, HEAPSIZE	# and its size
        li $a2, NODESIZE 	# and the size of a node
        jal mknodes		# initialize nodes
	la $s0, input		# load address of array of numbers to insert
	lw $a0, 0($s0) 		# load first N
	move $a1, $s7   	# initially our linked list will be empty (nil)
	move $a2, $v0  		# presuming $v0 contains a pointer to free after mknodes is called 
	jal insert		# call insert subroutine on first N
	addi $s1, $0, 1		# initializw index counter
iter:	sll $s2, $s1, 2  	# increment byte counter
	add $s2, $s0, $s2	# start add + index byte offset
	lw $a0, 0($s2)   	# load value at current index
	move $a1, $v0  		# initially our linked list will be empty (nil)
	move $a2, $v1  		# presuming $v0 contains a pointer to free after mknodes is called 
	beq $a0, $s7, done	# we are done if a0 is NIL
	jal insert		# otherwise, insert again
	addi $s1, $s1, 1	# increment index counter
	j iter			# iterate again
done:   move $a0, $v0		# move output to a0 for printing
	jal print		# call print subroutine
	lw $ra, 0($sp)		# pop $ra from stack
        addi $sp, $sp, 4	# reset stack pointer
        jr $ra			# return

# mknodes takes a heap address in a0, its byte-size in a1, and node size in a2
#  and partitions it into a singly-linked list of nodesize
# (NODESIZE-byte) nodes, pointed to by free.  
# NOTE:  the list is built with free pointing to the last node in the
#    heap area, which points to the previous one, etc.  The reason for
#    this construction is to be sure that you get nodes by calling
#    "new" rather than by rebuilding the heap yourself!  
# Register usage:
# inputs:
# $a0 contains a pointer to the heap
# $a1 contains the heapsize
# $a2 contains the nodesize

# used registers
# $t0: pointer to block that will become a node
# $t1: pointer to previous block (will become next node)

# $v0: points to the first free node in the heap
mknodes:
        add $t0, $a0, $a1       # t0 starts by pointing to the last
        sub $t0, $t0, $a2       # node-sized block in the heap
        move  $v0, $t0          # set output v0 to point to that first node
mkloop: sub $t1, $t0, $a2       # t1 points to previous node-sized block
        sw  $t1, NEXT($t0)      # link the t0->node to point to t1 node
        move $t0, $t1           # back up t0 by one node
        bne $t0, $a0, mkloop    # repeat if not at heap-start
        sw $s7, NEXT($t1)       # ground node (first block in heap)
        jr $ra

# Removes a node from free (passed in via $a0), returning a pointer to the node in $v0,
# and a pointer to the new free in $v1
#  ( returns NIL if none available)
# inputs:
#    $a0: points to the first "free" node in the heap
# outputs:
#    $v0: the node we have "created" (pulled off the stack from free)
#    $v1: the new value of free (we don't want to clobber $a0 when we change free, right? right?)
new:
	bne $a0, NIL, free	# branch if first free value is not NIL
	move $v0, $s7		# else, node is NIL
	move $v1, $s7		# and free is NIL
	j rtn			# return
free:	move $v0, $a0		
	lw $v1, NEXT($a0)	# load value at first free node
	sw $v0, NEXT($a0)	# point to next free node
rtn:	# if the value in the first free node is NIL, it is still free.
	jr $ra	# return


#insert behaves as described in the lab text
#
# registers used:
# 	 $t0: tmpptr
#	 $t1: if flag
#	 $t2: curptr
#	 $t3: curptr.next
#	 $t4: curptr.next.data
#	 $t5: while flag
# inputs:
#	 $a0: should contain N
#	 $a1: should contain a pointer to our linked list
#	 $a2: should contain a pointer to free
#
# outputs:
# 	v0 should contain the new pointer to our linked list
#	$v1 should contain the new pointer to free

		# ------ a node has              \
		# | ---|---> a pointer-to-node field 
		# ------    a data field             
		# | 17 | and it has the type-name: Node   
		# ------
		#typedef struct node {
		#    struct node *next   
		#    int data;           
		#    } Node;
insert:				#   insert(int N, Node *listptr)
	addi $sp, $sp, -8       #   allocate space on the stack
        sw $ra, 0($sp)		#   push $ra to the stack
        sw $a0, 4($sp)          #   push $a0 to stack
	move $a0, $a2		#   $a0 = ptr to free
	jal new			#   v0 = new Node();
	lw $a0, 4($sp)          #   restore $a0 from stack
	beq $v0, $s7, node	#   if new() retrun NIL
	move $t0, $v0		#   $t0 = tmpptr
	sw $a0, DATASIZE($t0)	#   tmptr.data = N;
	beq $a1, $s7, if	#   if listptr == Nil or N < listptr.data 
	lw $t1, DATASIZE($a1)  	#   { $t1 = 1 if  N < listptr.data; 0 otherwise
	ble $t1, $a0, else	
if:	sw $a1, NEXT($t0)	#      tmpptr.next = listptr
	move $a1, $t0		#      listptr = tmpptr
	j done2			#   }
else:	move $t2, $a1		# else curptr = listptr
while:				# while curptr.next != Nil and curptr.next.data <= N
	lw $t3, NEXT($t2)   	#	t3 = curptr.next
	beq $t3, $s7, w_end
	lw $t4, DATASIZE($t3)   #	t4 = curptr.next.data
	blt $a0, $t4, w_end 
				#      {
	move $t2, $t3		#         curptr = curptr.next
	j while			#      }
w_end:	lw $t5, NEXT($t2)	#
	sw $t5, NEXT($t0)	#      tmpptr.next = curptr.next
	sw $t0, NEXT($t2)	#      curptr.next = tmpptr
				#   }
done2:	move $v0, $a1		#   return listptr
	lw $ra, 0($sp)		# pop $ra from stack
	addi $sp, $sp, 8	# reset stack 
	jr $ra			# return
node:	addi $sp, $sp, -8       #   allocate space on the stack
        sw $v0, 0($sp)		#   push $ra to the stack
        sw $a0, 4($sp)          #   push $a0 to stack
	li $v0, PR_STR		#   end of routine printing
	la $a0, nofree	
	syscall
	lw $a0, 4($sp)
	lw $v0, 0($sp)
	addi $sp, $sp, 8
	j done2


##print_arr
## register use:
##	$a0: parameter: pointer to heap
##	$t2: data word 
##	$t0: a0 from first call to print_arr 
print:  move $t0, $a0 
        j w_test2               # jump to test 
next:   
	lw $t2, DATASIZE($t0)   # get next data word
	move $a0, $t2 	        # move integer to be printed into $a0:  $a0 = $t2
	li $v0, PR_INT 		# syscall to print int
	syscall			# call operating system to perform print
        
	li $v0, PR_STR		#mpre printing
	la $a0, spce
	syscall
	lw $t0, NEXT($t0)
w_test2:
	bne $t0, $s7, next    	# while not NIL
	jr $ra			# return
