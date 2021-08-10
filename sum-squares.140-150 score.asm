.text
############################################################
###     Enter your code here.
###     Write function squaredSum

# Function to calculate squared sum
# 
# Inputs:
#       $a0: address of array in memory (*a)
#       $a1: array size (n)
#
# Outputs:
#       $v0: low 32 bytes of result
#       $v1: high 32 bytes of result
#
# If the array is empty, then the function returns zero.
#
j main
squaredSum:

       beq	$a1,$zero, Ret0		# if the dimension of the chart is zero it returns zero
       li	$v0,0			# v0 = 0
       li	$v1,0	      		# v1 = 0
       li 	$t0,0			# t0 = i
       la       $s0,($a0)		# s0 = *a
       move	$s1, $a1		# s1 = n
       
       
Loop:
	beq	$t0, $s1, endLoop	# when t0=s1(i=n) go to endLoop 

	lw	$t1, ($s0)
	multu	$t1,$t1			# (Hi,Lo) = t1 * t1
	mflo	$s2			# move quantity from Lo to $s2
	mfhi	$s3			# move quantity from Hi to $s3
	j	adduover  	

Continue:
	addi	$s0,$s0,4		# from a[i] goes to a[i+1]
	addi	$t0,$t0,1		# i = i + 1
	
	b	Loop		

endLoop:	
	jr	$ra


adduover:
	addu	$s2, $s2, $v0		# s2=s2+v0
	sltu	$t2, $s2, $v0		# if s2 < v0 then t2 = 1 else t2 = 0	
	addu	$s3, $s3,$v1		# s3=s3+v1
	move	$v0, $s2		# v0 = s2 = s2+v0
	beq	$t2, 1, overflow	# if t2 = 1 go to overflow
	move	$v1, $s3		# v1 = s3
	b	Continue		
	
overflow:
	addiu	$t4, $s3,1		# t4 = s3 + 1 
	sltu	$t5, $t4,$s3		# if t4 < s3 then t5 = 1 else t5 = 0  
	beq	$t5,1,deadbeef		# if t5 = 1 go to deadbeef
	move	$s3, $t4		# s3 = t4 = s3 + 1
	sltu	$t3, $s3,$v1		# if s3 < v1 then t3 = 1 else t3 = 0
	bne	$t3,0,deadbeef		# if t3 = 1 go to deadbeef
	move	$v1, $s3		# v1 = s3 = s3 + 1
	b	Continue		

deadbeef:
	li	$v0,0xDEADBEEF		# load 0xDEADBEEF to v0
	li	$v1,0x00000000		# load 0 to v1
	jr	$ra			# in order to return to the programm 
	
Ret0:
                add $v0, $zero, $zero
                add $v1, $zero, $zero
                jr $ra
	
        
###     squaredSum ending        
############################################################

############################################################
###     DO NOT CHANGE ANYTHING BELOW !!!


.data
array_a:.space  1000            # 250 integers

strSize:.asciiz "Enter array size (maximum 250)"

strInp: .asciiz "Enter next number (element "
               
strPower: .asciiz " * 2^(32) + "

strHex: .asciiz "0x"


.text
# Entry point for program (main function)
main:

        # original values for *a and i
        la      $s1, array_a    # $s1 = *a
        li      $t0, 0          # $t0 = i

        # display line to input size
        la      $a0, strSize
        jal     printStringln
        
        # get array size
        addi    $v0, $0, 5      # user input
        syscall                   

        move    $s0, $v0        # s0 := n

initLoop:
        beq     $t0, $s0, initDone  # jump if loop finished

        # Display line for next element input
        la      $a0, strInp
        jal     printString

        move    $a0, $t0
        jal     printInteger

        li      $a0, 41         # ')'
        jal     printASCIIln
        
        # Get user input (element a[i])
        addi    $v0, $0, 5        
        syscall
        
        sw      $v0, ($s1)      # store input number in a[i]

        addi    $s1, $s1, 4     # move array pointer
        addi    $t0, $t0, 1     # increase i
        b       initLoop        # loop

initDone: 
        la      $a0, array_a    # first argument is array address
        move    $a1, $s0        # second argument is size of array
        jal     squaredSum      # call squaredSum

        move    $s0, $v0        # first return output LO
        move    $s1, $v1        # second return output HI

        la      $a0, strHex
        jal     printString
        move    $a0, $s1
        jal     printHEX
        move    $a0, $s0
        jal     printHEX
        jal     printNewline
        
        ## move    $a0, $s1
        ## jal     printInteger
        
        ## # print result
        ## la      $a0, strPower
        ## jal     printString

        ## move    $a0, $s0
        ## jal     printIntegerln

        # exit
        li      $v0, 10
        syscall


# printString -- Print input string to console
#
# Inputs:
#       $a0:    Memory address of string
#
# Outputs:
#       (none)
#       
printString:

        # print input string
        addi    $v0, $0, 4
        syscall

        jr      $ra

# printStringln -- Print input string to console, followed by
#  new line
#
# Inputs:
#       $a0:    Memory address of string
#
# Outputs:
#       (none)
#       
printStringln:

        # print input string
        addi    $v0, $0, 4
        syscall
        
        # print new line
        addi    $v0, $0, 11     # ASCII character print
        li      $a0, 10         # ASCII character new line
        syscall

        jr      $ra

# printInteger -- Print input integer to console
#
# Inputs:
#       $a0:    Integer value
#
# Outputs:
#       (none)
#       
printInteger:

        # print integer
        addi    $v0, $0, 1
        syscall

        jr      $ra

# printNewline -- Print new line
#
# Inputs:
#       (none)
#       
# Outputs:
#       (none)
#       
printNewline:

        # print new line
        addi    $v0, $0, 11     # ASCII character print
        li      $a0, 10         # ASCII character new line
        syscall

        jr      $ra
        
# printIntegerln -- Print input integer to console, followed
#  by new line
#
# Inputs:
#       $a0:    Integer value
#
# Outputs:
#       (none)
#       
printIntegerln:

        # print integer
        addi    $v0, $0, 1
        syscall

        # print new line
        addi    $v0, $0, 11     # ASCII character print
        li      $a0, 10         # ASCII character new line
        syscall

        jr      $ra

# printASCII -- Print input ASCII character to console
#
# Inputs:
#       $a0:    ASCII character to print
#
# Outputs:
#       (none)
#       
printASCII:

        # print ASCII
        addi    $v0, $0, 11
        syscall

        jr      $ra

# printASCIIln -- Print input ASCII character to console, followed
#  by new line
#
# Inputs:
#       $a0:    ASCII character to print
#
# Outputs:
#       (none)
#       
printASCIIln:

        # print ASCII
        addi    $v0, $0, 11
        syscall

        # print new line
        addi    $v0, $0, 11     # ASCII character print
        li      $a0, 10         # ASCII character new line
        syscall

        jr      $ra


# printHEX -- Print HEX represenation of word
#
# Inputs:
#       $a0:    Word to print
#
# Outputs:
#       (none)
#              
printHEX:

        move    $t1, $a0
        li      $t3, 8
        
LoopHEX:
        beqz    $t3, ExitHEX
        rol     $t1, $t1, 4
        and     $t4, $t1, 0xf
        ble     $t4, 9, SumHEX
        addi    $t4, $t4, 55

        b       EndHEX

SumHEX:
        addi    $t4, $t4, 48

EndHEX:
        move    $a0, $t4
        
        # print ASCII
        addi    $v0, $0, 11
        syscall
        
        addi    $t3, $t3, -1

        j       LoopHEX

ExitHEX:

        jr      $ra
