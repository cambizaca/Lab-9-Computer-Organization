.data 0x0
   pattern:		.space 21		#allocates 21 bytes of memory
   one:			.ascii "1"		#1
   zero:		.ascii "0" 		#0
   newline:		.ascii "\n"
   
   
.text 0x3000
.globl main

main:

    ori     $sp, $0, 0x3000     # Initialize stack pointer to the top word below .text
                                # The first value on stack will actually go at 0x2ffc
                                #   because $sp is decremented first.
    addi    $fp, $sp, -4        # Set $fp to the start of main's stack frame

    addi $v0, $0, 5			# system call 5 is for reading an integer
    syscall 				# integer value read is in $v0
    add	$a1, $0, $v0			# copy n value into $a1
    
    la $t0, pattern
    
    #index
    
    add $t1, $a1, $0	        
    sb $0, pattern($t1)		#places null terminator at n*4
    
    add $t2, $zero, $zero	#clears $t2 to set as counter


    jal  makepatterns              # call NchooseK
    
    exit:
    ori     $v0, $0, 10     # System call code 10 for exit
    syscall                 # Exit the program

 .globl makepatterns                    # Simply means proc1 can be found by code residing in other files

makepatterns: 
   addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    sw      $ra, 4($sp)         # Save $ra
    sw      $fp, 0($sp)         # Save $fp

    addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame

                                # From now on:
                                #     0($fp) --> $ra's saved value
                                #    -4($fp) --> caller's $fp's saved value

 # =============================================================
    # Save any $sx registers that proc1 will modify
    
    addi    $sp, $sp, -8        # e.g., $s0, $s1, $s2, $s3
    sw      $s0, 4($sp)         # Save $s0
    sw      $s1, 0($sp)         # Save $s1
   
    add $s0, $0, $a1			#storing n
    add $s1, $0, $t2			#storing CurrentValue

 # =============================================================
    #body
    la $v0, pattern			#loads address into into return register
    #basecase
    beq $a1, $t2, print 		#once CurrentValue = N -> print
  makePattern:

    li $t3, '0' 		# prepares to put 0 in pattern by putting a 0 in $t3
    sb $t3, pattern($t2)	# stores "0" into pattern
    addi $t2, $t2, 1		# incriments $t2 by 1 to prepare to another 0
    jal makepatterns		# recursion
    
    add $a1, $s0, $0 		#REstoring N value
    add $t2, $0, $s1		#REstoring CurrentValue
    
    li $t3, '1' 		#prepares to put 0 in pattern by putting a 1 in $t3
    sb $t3, pattern($t2)	#stores "1" into pattern
    addi $t2, $t2, 1		#incriments $t2 by 1 to prepare to another 0
    
    jal makepatterns		#recursion
    j return_from_makepatterns
    print:
    li $v0, 4				#prepares to print string
    la $a0, pattern			#loads addy of pattern to a0
    syscall 			       	
    li $v0, 4				#prepares to print string
    la $a0, newline 			#loads addy of newline to a0
    syscall 			        #prints a string from register
  return_from_makepatterns:
    # Restore $sx registers
    lw  $s0,  -8($fp)           # Restore $s0
    lw  $s1, -12($fp)           # Restore $s1

    

    addi    $sp, $fp, 4     # Restore $sp
    lw      $ra, 0($fp)     # Restore $ra
    lw      $fp, -4($fp)    # Restore $fp
    jr      $ra             # Return from procedure

  
 
