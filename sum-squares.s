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

squaredSum:
        
        li 	$v0, 0
        li 	$v1, 0
        li 	$t0, 0
        
        la	$s0, ($a0)
        move    $s1, $a1
        
        
        jr      $ra                      # return
        
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

        move    $s0, $v0        # first return output HI
        move    $s1, $v1        # second return output LO

        move    $a0, $s1
        jal     printInteger
        
        # print result
        la      $a0, strPower
        jal     printString

        move    $a0, $s0
        jal     printIntegerln

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
