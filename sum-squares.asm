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
# check the algorithm's correctness
# as it concerns tha outputs :
# i put the zero as a dimension and the output is zero 
# also i put in a 2 dimension chart the zero as the first number and the one as the second and the result is one
# i put in a 4 dimension chart four times the number 2.147.483.647, the number 131.071, 
# the number 511, the number 31, the number 7 and two times the number 2 and the output was 0x00000000DEADBEEF, it was high overflow
# as these numbers have a combined squared sum of 2^64
# as it concerns the code :
# i did three checks
# the first was in line 57 in order to check if the new low sum is smaller than the older, 
# if it is that means that we have a "kratoumeno", so t2=1 and that way we go to the high register of 32-bit as the low register of 32-bit is whole
# the second check was in line 61 in order to see if after the addition of "kratoumeno" (in case that exists)
# we have overflow, so in that case we have high_overflow as the high register of 32-bit becomes whole, so the output must be 0x00000000DEADBEEF
# the third check is in line 64 and with this final check, if after the addition of "kratoumeno" (in case that exists) we don't have high overflow, we see 
# if after the addition of the next number in the high register of 32-bit we have high overflow (new high sum<old high sum) and the output must be 0x00000000DEADBEEF  

squaredSum:

       li	$v0,0			# v0 = 0
       li	$v1,0			# v1 = 0
       li 	$t0, 0			# t0 = i
       la 	$s0, ($a0)		# s0 = *a
       move	$s1, $a1		# s1 = n

firstLoop:
	beq	$t0, $s1, endfirstLoop	#jump if loop is finished

	lw	$t1, ($s0)
	multu	$t1,$t1			# (Hi,Lo) = t1 * t1
	mflo	$s2			# move quantity in register Lo to $s2
	mfhi	$s3			# move quantity in register Hi to $s3
	j	adduover		# goes to adduover

endfirstLoop:
	jr	$ra			# in order to return to the programm


adduover:
	addu	$s2, $s2, $v0		# s2 = new low sum (s2=s2+v0)
	sltu	$t2,$s2,$v0		# if new low sum < old low sum --> t2 = 1 else t2 = 0
	addu	$s3, $s3, $v1		# s3 = new high sum (s3=s3+v1)
	move	$v0, $s2                # v0 = new low sum
	addu	$t4, $s3, $t2		# t4 = s3 + t2 (high sum + low overflow(if there is "kratoumeno" t2 will be 1 else it will 0, but in any case it will be added to the number))
	sltu	$t5, $t4, $s3		# if t4 < s3 --> t5 = 1 else t5 = 0 , checking if with the addition of "kratoumeno" we have high_oveflow, because if we do,the s3 will become a zero and it will lose all the other numbers
	bne 	$t5, 0, high_overflow   # if t5 = 1 go to high_overflow
	move	$s3, $t4		# s3 = t4 = s3 + t2
	sltu	$t3, $s3,$v1		# if new high sum < old high sum --> t3 = 1 else t3 = 0
	bne	$t3, 0, high_overflow	# if t3 = 1 go to high_overflow
	move	$v1, $s3		# v1 = new high sum
  	addi	$s0,$s0,4	        # goes to the next adress
	addi	$t0,$t0,1		# i = i + 1
	b	firstLoop	        # branch to firstLoop

high_overflow:
	li	$v0,0xDEADBEEF		# load 0xDEADBEEF to the v0, as v0 is the low register
	li	$v1,0x00000000		# load 0 to the v1, as v1 is the high register
	jr	$ra			# in order to return to the programm


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
