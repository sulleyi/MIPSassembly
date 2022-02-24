#  Linked structures in assembler       D. Hemmendinger  24 January 2009
#  Linked structures in assembler       J. Rieffel 15 February 2011
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
input: .word 5 ## you add more numbers here  (no more than NUMNODES)
inp_end:
INSIZE = 1 #(inp_end - input)/4    # number of input array elements

heap:   .space  HEAPSIZE           # storage for nodes 
spce:   .asciiz "  "
nofree: .asciiz "Out of free nodes; terminating program\n"

        .align 2
        .text
main:   addi $sp, $sp, -4
        sw $ra, 0($sp)
        li $s7, NIL             # global variable holding the NIL value
        la $a0, heap            # pass the heap address to mknodes
        li $a1, HEAPSIZE	#      and its size
        li $a2, NODESIZE 	#      and the size of a node
        jal mknodes
	

###   Insert the values in the input array by calling insert for each one.
###   When the insertion is done, store the list pointer in the list variable
###   and then call a subroutine to traverse the list and print its contents
###   REMOVE these comment lines before turning in the program.

	#initially our linked list will be empty (nil)
	#lw, $a0, input
	#li, $a1, nil
	#move $a2, $v0  #presuming $v0 contains a pointer to free after mknodes is called

done:   lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

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
        sub $t0, $t0, $a2       #   node-sized block in the heap
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
	lw $t0, 0($a0)		# load value at first free node
	move $v0, $t0 		# move value in free node to v0
	beq $t0, $0, nil	# branch if first free value is NIL
	addi $v1, $a0, NODESIZE	# point to next free node
nil:	move $v1, $a0		# if the value in the first free node is NIL, it is still free.
	jr $ra	


#insert behaves as described in the lab text
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
		#
insert:				#insert(int N, Node *listptr)
				#{
				#   tmpptr = new Node(); -> in $a2
	sw $a0, DATASIZE($a2)	#   tmptr.data = N;
	bne $a1, $0, else	#   if listptr == Nil or N < listptr.data TODO make sure this is OR not AND
	lw $t0, DATASIZE($a1)	# $t0 = listptr.data
	sgt $t1, $t0, $a0  	#   { $t1 = 1 if  N < listptr.data; 0 otherwise
	beq $t1, $0, else	
	sw $a1, NODESIZE($a2)	#      tmpptr.next = listptr
	sw $a2,	0($a1)		#      listptr = tmpptr
				#   }
else:				#   else 
				#   {
	move $t2, $a1		#      curptr = listptr
while:				#      while curptr.next != Nil and curptr.next.data <= N
	lw $t3, NODESIDE($t2)   # t3 = curptr.next
	lw $t4, DATASIZE($t3)   # t4 = curptr.next.data

	beq $t3, $0, w_end
	sgt $t5, $t4, $a0	# t5 = curptr.next.data > N
	bne $t5, $0, w_end 
				#      {
	sw $t3, 0($t2)		#         curptr = curptr.next
				#      }
w_end:				#
	sw $t3, NODESIZE($a2)	#      tmpptr.next = curptr.next
	sw $a2, 0($t3)		#      curptr.next = tmpptr
				#   }
	move $v0, $a1		#   return listptr
	jr $ra			#}

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
