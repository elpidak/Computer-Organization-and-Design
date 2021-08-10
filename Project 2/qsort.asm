	.globl	v
	.data
	.align	2
v:
	.word	3
	.word	10
	.word	8
	.word	2
	.word	7
	.word	1
	.word	5
	.word	9
	.word	6
	.word	4

array_a:.space  1000            # 250 integers

strSize:.asciiz "Enter array size (maximum 250)"

strInp: .asciiz "Enter next number (element "

strPower: .asciiz " * 2^(32) + "

strHex: .asciiz "0x"

	.text
	 j main
swap:
       	sll	$t1,$a1,2	# t1 = k*4
        add	$t1,$a0,$t1	# t1 = v + t1 = v + (k*4) , so t1 contains the address of v[k]
        lw	$t0,0($t1)	# t0 = v[k] temporary
        sll	$t2,$a2,2	# t2 = l*4
        add	$t2,$a0,$t2	# t2 = v + t2 = v + (l*4), so t2 contains tha address of v[l]
        lw	$t3,0($t2)	# t3 = v[l] temporary
        sw	$t0,0($t2)	# store t0 to address of t2 that way t0 = v[l], so t0 from v[k] becomes v[l]
        sw	$t3,0($t1)	# store t3 to address of t1 that way t3 = v[k], so t1 from v[l] becomes v[k]
        addi	$s7,$s7,9	# s7 -> the counter of the commands 
	jr	$ra		# jump to register address
	nop


partition:
	addiu	$sp,$sp,-56
	sw	$ra,44($sp)
	sw	$fp,40($sp)
	move	$fp,$sp
	sw	$a0,48($fp)
	sw	$a1,52($fp)
	lw	$v1,52($fp)
	li	$v0,1073676288			# 0x3fff0000
	ori	$v0,$v0,0xffff
	addu	$v0,$v1,$v0
	sll	$v0,$v0,2
	lw	$v1,48($fp)
	addu	$v0,$v1,$v0
	lw	$v0,0($v0)
	sw	$v0,36($fp)
	sw	$0,28($fp)
	sw	$0,32($fp)
	addi	$s7,$s7,18
	b	part_loop
	nop

part_for:
	lw	$v0,32($fp)
	sll	$v0,$v0,2
	lw	$v1,48($fp)
	addu	$v0,$v1,$v0
	lw	$v1,0($v0)
	lw	$v0,36($fp)
	slt	$v0,$v1,$v0
	addi	$s7,$s7,8
	beq	$v0,$0,part_noswap
	nop

	lw	$v0,28($fp)
	addiu	$v1,$v0,1
	sw	$v1,28($fp)
	lw	$a2,32($fp)
	move	$a1,$v0
	lw	$a0,48($fp)
	addi	$s7,$s7,7

	jal	swap

part_noswap:
	lw	$v0,32($fp)
	addiu	$v0,$v0,1
	sw	$v0,32($fp)
	addi	$s7,$s7,3
part_loop:
	lw	$v0,52($fp)
	addiu	$v1,$v0,-1
	lw	$v0,32($fp)
	slt	$v0,$v0,$v1
	addi	$s7,$s7,5
	bne	$v0,$0,part_for
	nop

	lw	$v0,52($fp)
	addiu	$v0,$v0,-1
	move	$a2,$v0
	lw	$a1,28($fp)
	lw	$a0,48($fp)
	addi	$s7,$s7,5

	jal	swap

	lw	$v0,28($fp)
	move	$sp,$fp
	lw	$ra,44($sp)
	lw	$fp,40($sp)
	addiu	$sp,$sp,56
	addi	$s7,$s7,6
	jr	$ra


qsort:
        addi	$sp,$sp,-20	# creation of space for 5 registers
        sw	$ra,16($sp)	# store register address to the stack
        sw	$s3,12($sp)	# store s3 to the stack
        sw	$s2,8($sp)	# store s2 to the stack
        sw	$s1,4($sp)	# store s1 to the stack
        sw	$s0,0($sp)	# store s0 to the stack
        move	$s0,$a0		# copy a0 to s0, so s0 = v[] = v[0]
        move	$s1,$a1		# copy a1 to s1, so s1 = n
        move	$s2,$ra		# copy register address to s2, so after the second call of qsort inside the qsort to return in right address
 	li	$t2,1		# t2 = 1(in order to do the comparison in the next step)
 	slt	$t1,$t2,$s1	# if t2 < s1 => 1 < n then set t1 = 1 else t1 = 0
 	addi	$s7,$s7,12	# s7 -> the counter of the commands is getting bigger
 	beqz	$t1,exit	# if t1 = 0, which means that qsort can't be executed and that's why it goes to the exit
	jal	partition	# if t1 = 1 => n > 1 goes to partition
	move	$s3,$v0		# store p to s3 in order to use it to the next step to qsort (which is the return value of partition, which is i)
	move	$a0,$s0		# copy a0 to s0, so a0 = v[0] because after the call of partition a0 might have changed
	move	$a1,$s3		# copy a1 to s1, so a1 = p, beacause after the call of partition a1 might have changed
	addi	$s7,$s7,4	# s7 -> the counter of the commands is getting bigger
	jal	qsort		# goes to qsort
	add	$s1,$s1,-1	# so n = n-1
	sub	$s1,$s1,$s3	# so n = n-p (n = n-p-1), we created that way the new n = n-p-1
	sll	$s3,$s3,2	# s3 = s3 *4
	add	$s3,$s0,$s3	# s3 = v + ( s3*4), so s3 contains v[p]
	addi	$s3,$s3,4	# s3 = s3 + 4 so s3 contains &v[p+1], we created that way the new v[0] = &v[p+1]
	move	$a0,$s3		# a0 = s3 = &v[p+1], we store the v[0]
	move	$a1,$s1		# a1 = n = n-p-1, we store the new n
	addi	$s7,$s7,8	# s7 -> the counter of the commands is getting bigger
	jal	qsort		# goes to qsort



exit:
	move	$ra,$s2		# copy register address to s2, in order to do
	lw	$s0,0($sp)	# reset s0 from the stack
	lw	$s1,4($sp)	# reset s1 from the stack
	lw	$s2,8($sp)	# reset s2 from the stack
	lw	$s3,12($sp)	# reset s3 from the stack
	lw	$ra,16($sp)	# reset register address from the stack
	addi	$sp,$sp,20	# reset the space of the stack
	addi	$s7,$s7,8	# s7 -> the counter of the commands is getting bigger
	jr	$ra		# jump to register address

main:
	addiu	$sp,$sp,-40
	sw	$ra,36($sp)
	sw	$fp,32($sp)
	move	$fp,$sp
	## li	$v0,10			# 0xa


        # original values for *a and i
        la      $t1, array_a    # $s1 = *v
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

        sw      $v0, ($t1)      # store input number in a[i]

        addi    $t1, $t1, 4     # move array pointer
        addi    $t0, $t0, 1     # increase i
        b       initLoop        # loop

initDone:

        move    $v0, $s0

	sw	$v0,28($fp)
	lw	$a1,28($fp)

        la      $a0, array_a

        jal     printArray

        lw	$a1,28($fp)
        la      $a0, array_a

	jal	qsort

        la      $a0, array_a
        move    $a1, $s0
        jal     printArray

	move	$v0,$0
	move	$sp,$fp
	lw	$ra,36($sp)
	lw	$fp,32($sp)
	addiu	$sp,$sp,40
	
	li $v0, 10
	syscall 
	jr	$ra


# printArray -- Function to print an array
#
# Inputs:
#       $a0:    Array pointer
#       $a1:    Array length
#
# Outputs:
#       (none)
#
printArray:
        # initialize i
        li     $t0, 0
        move   $t1, $a0

        # print [
        addi   $v0, $0, 11
        li     $a0, 91
        syscall

        # print space
        addi    $v0, $0, 11
        li      $a0, 32
        syscall



loopPrint:
        beq    $t0, $a1, loopEnd

        # print element a[i]
        li     $v0, 1
        lw     $a0, ($t1)
        syscall

        # print space
        addi   $v0, $0, 11
        li     $a0, 32
        syscall

        addi   $t1, $t1, 4
        addi   $t0, $t0, 1

        b      loopPrint


loopEnd:

        # print ]
        addi   $v0, $0, 11
        li     $a0, 93
        syscall

        move   $t0, $ra
        jal    printNewline
        move   $ra, $t0

        jr     $ra


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
