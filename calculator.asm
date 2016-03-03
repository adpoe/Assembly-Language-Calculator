#######################################################
# Anthony Poerio (adp59@pitt.edu)                     #
# CS 447 - Fall 2015                                  #
# PROJECT 01 - SIMPLE CALCULATOR     	              # 
#######################################################

#  Architecture:
#     - Input:   connected to $t9 
#     - Output:  connected to $t8
#     - Upon beginning the program, user can build a number until an operator is pressed
#     - Once an operator is pressed, the operator value is stored in $t5, and the current display value is
#       stored in $t4
#     - Then, we loop back to the beginning of the program to collect a second operand
#     - Next time an operator is pressed, we perform the operation
#
# Operations Supported:
#     - Addition
#     - Subtraction
#     - Multiplication (both positive and negative numbers)
#     - Division (both positive and negative numbers)
#     - Clear
#     - LAST operator pressed is always the one used
#
#  Registers used:
#  ----------------------------------------------------------------------------------------
#    $t0 = intermediate value #1 for building numbers (previous number * 8)
#    $t1 = intermediate value #2 for building numbers (previous number * 2)
#    $t2 = $t0 + $t1, when building a number
#    $t4 = OPERAND register. If an operator is entered, store the current number in $t4
#          and when a new number is entered, store in $t6/$t7
#    $t5 = OPERATOR register.  Stores MOST recent operator entered.
#    $t6 = Builder value
#    $t7 = store value of input from $t9 after it is received 
#    $t8 = output
#    $t9 = input 
#    $s5 = sentinel value used to specify intended subtraction from zero
#    $s6 = sentinel value used to specify intended multipication by a negative number
#    $s7 = sentinel value used to specify intended multiplication or division by zero
#  ----------------------------------------------------------------------------------------
#

######################
### Wait for input ###
######################

wait:
	beq   $t9, 0, wait           # Wait for input if nothing in $t9, which is linked 
				     # to input values on the calculator
	bne   $t9, 0, accept_input   # If any button on calculator is pressed
				     # then accept it as input
			

#####################
### Accept Input ####
#####################

accept_input:
	add $t6, $zero, $t9         # Input is in $t9, store it in $t6
	sll $t6, $t6, 1             # Zero, input from calculator interface, has a 1 in MSB
	srl $t6, $t6, 1             # So, clear that one, make it a zero

if_operator:
	blt  $t6, 10, build_number
	bgt  $t6, 9, push_operator  # Go to the selected operator function
	
push_operator:
	beq   $t6, 10, plus
	beq   $t6, 11, minus
	beq   $t6, 12, multiply
	beq   $t6, 13, divide
	beq   $t6, 14, equals
	beq   $t6, 15, clear
	
	
build_number:
	sll  $t0, $t7, 3            # $t0 = previous number * 8
	sll  $t1, $t7, 1            # $t1 = previous number * 2
	add  $t2, $t1, $t0          # $t2 = $t0 + $t1 - previous value * 10
	add  $t6, $t2, $t6          # $t6 = (the previous value * 10) + Most recent digit input
	j builder

builder:		
	add  $t7, $zero, $t6        # And add the $t6 value to $t7, the output
	add  $t8, $zero, $t6        # And add the $t6 value to $t7, the output
	addi $t9, $zero, 0          # set $t9 back to $zero
	j wait


	

			
#################################
#####   Route  Function    ######
#################################
				
equals:
	beq   $t5, 10, plus
	beq   $t5, 11, minus
	beq   $t5, 12, multiply
	beq   $t5, 13, divide
	beq   $t5, 14, equals
	beq   $t5, 15, clear

	
	

#################################
###   Mathematical Operators  ###
#################################


#//////////////////////
#//////   PLUS  ///////
#//////////////////////
plus: 
	beq  $t4, 2147483648, _plus_OperandDNE         
	bne  $t4, 2147483648, _plus_performOperation
_plus_OperandDNE:
	addi $t4, $t7, 0          # if nothing in $t4, store current display value in operand
	# Reset values
	add  $t6, $zero, 0        # Set $t6 to zero  
	addi $t7, $zero, 0        # Set $t7 to zero
	addi $t9, $zero, 0        # set $t9 back to $zero
	j wait	
_plus_performOperation:
	# add The current value in $t7 and stored operand into $t7
	add  $t8, $t7, $t4        # Add whatever's in the OPERAND register and $t7, store in $t7
	# Reset values
	addi $t5, $zero, 0        # Clear operand register
	addi $t4, $t8, 0          # Set $t4 to new operand
	add  $t6, $zero, 0        # Set $t6 to zero  
	addi $t7, $zero, 0        # Set $t7 = 0
	addi $t9, $zero, 0        # set $t9 back to $zero
	j wait

	
#//////////////////////
#//////   MINUS  //////
#//////////////////////	
minus:
	beq  $t4, 0, _minus_OperandDNE
	bne  $t4, 0, _minus_performOperation
_minus_OperandDNE:
	beq  $s5, 1, _minus_performOperation   
	addi $t4, $t7, 0          # if nothing in $t4, store current display value in operand
	addi $s5, $zero, 1        # $t4 = 0, because user wants to subtract from zero
	# Reset values      
	addi $t5, $zero, 11       # Keep operand minus	
	add  $t6, $zero, 0        # Set $t6 to zero  
	addi $t7, $zero, 0        # Set $t7 to zero
	addi $t9, $zero, 0        # set $t9 back to $zero
	j wait	
_minus_performOperation:				
	nor  $t7, $t7, $zero      # Changes the second operand to a negative number
	addi $t7, $t7, 1          # Adds the now negative second operand to the first operand to turn it into subtraction
	add  $t8, $t7, $t4	
	# Reset values
	addi $t5, $zero, 11       # Keep operand minus
	addi $t4, $t8, 0          # Set $t4 to new operand
	add  $t6, $zero, 0        # Set $t6 to zero  
	addi $t7, $zero, 0        # Set $t7 = 0
	addi $t9, $zero, 0        # set $t9 back to $zero
	addi $s5, $zero, 0        # restore subtract from zero sentinel value ($s5)
	j wait
	
			
#//////////////////////////
#//////   MULTIPLY  ///////
#//////////////////////////	
multiply:
	#bgt  $t4, 0, _mult_performOperation 
	blt  $t4, 0, _multiply_by_negative
	bne  $t4, 0, _mult_performOperation
	beq  $t4, 0, _mult_OperandDNE
#	bne  $t4, 0, _mult_performOperation
_mult_OperandDNE:
	beq  $s7, 1, times_zero      # $t4 = 0, because user wants to multiply by zero
	addi $t4, $t8, 0             # if nothing in $t4, store current display value in operand
	# Reset values
	beq  $t4, $zero, m_user_entered_zero       # if User ENTERS a zero
	bne  $t4, $zero, m_continue
m_user_entered_zero:
	addi $s7, $zero 1            # set $s7 to 1, as a sentinel value
m_continue:
	addi $t5, $zero, 12          # Keep operand multiply
	add  $t6, $zero, 0           # Set $t6 to zero  
	addi $t7, $zero, 0           # Set $t7 to zero
	addi $t9, $zero, 0           # set $t9 back to $zero
	j wait	
_mult_performOperation:
	beq  $s7, 1, times_zero      # If $s7 = 1, then user entered a zero as the operand
	beq  $t8, 0, times_zero      # If display value = zero when we multiply, the answer is zero
	addi $s0, $zero, 1           # $s0 = counter, initialized to 1
	addi $s1, $t4, 0             # $s1 = value of $t4, before any multiplication is done
	                             # We'll preserve $t4, and use $s1 as an accumulator
accumulate:	                          
	add  $s1, $s1, $t4           # Add the inital value of operand to the accumulator
	addi $s0, $s0, 1             # Increase counter by 1
	beq  $s0, $t8, display_multiple  # If counter = the 2nd operand, we are done multiplying  
	j accumulate

_multiply_by_negative:
	beq  $s6, 1, _mult_performOperation   # We're here because user wants a negative number
	addi $t4, $t8, 0
	addi $s6, $zero, 1          # $t4 < 0 because user has entered a negative number
	addi $t5, $zero, 12         # Keep operand multiply
	add  $t6, $zero, 0          # Set $t6 to zero  
	addi $t7, $zero, 0          # Set $t7 to zero
	addi $t9, $zero, 0          # set $t9 back to $zero
	j wait
				
times_zero:
	addi $t8, $zero, 0           # answer is zero
	addi $s7, $zero, 0           # restore zero value sentinel ($s7) to zero
	j end_multiply 
display_multiple:
	add  $t8, $s1, $zero         # Output value is the result of all our accumulation
	addi $s6, $zero, 0           # restore negative value sentinel ($s6) to zero
end_multiply:	
	# Reset values
	addi $t5, $zero, 0           # Clear operand register
	addi $t4, $t8, 0             # Set $t4 to new operand
	add  $t6, $zero, 0           # Set $t6 to zero  
	addi $t7, $zero, 0           # Set $t7 = 0
	addi $t9, $zero, 0           # set $t9 back to $zero
	j wait


#/////////////////////////
#//////   DIVIDE  ////////
#/////////////////////////	
divide:

	blt  $t4, 0, _divide_by_negative
	bne  $t4, 0, _div_performOperation
	beq  $t4, 0, _div_OperandDNE
_div_OperandDNE:
	beq  $s7, 1, divideBy_zero      # $t4 = 0, because user wants to multiply by zero
	addi $t4, $t8, 0                # if nothing in $t4, store current display value in operand
	# Reset values
	beq  $t4, $zero, d_user_entered_zero     # if User ENTERS a zero
	bne  $t4, $zero, d_continue
d_user_entered_zero:
	addi $s7, $zero 1            # set $s7 to 1, as a sentinel value
d_continue:
	addi $t5, $zero, 13          # Keep operand divide
	add  $t6, $zero, 0           # Set $t6 to zero  
	addi $t7, $zero, 0           # Set $t7 to zero
	addi $t9, $zero, 0           # set $t9 back to $zero
	j wait	
_div_performOperation:	
	beq  $s6, 1, negDivSetup      # if $s6, doesn't matter if denominator > numerator
	bgt  $t8, $t4, divideBy_zero  # If denominator > numerator, division = 0 
	bne  $s6, 1, divSetup         # Otherwise, setup divide as normal

negDivSetup:
	# Treat the negative numerator as a positive for purpose of calculation
	nor  $t4, $t4, $zero          # Bitwise NOR $s4 (numerator) with $zero to flip the bits
	addi $t1, $t1, 1              # Add one to numerator, making ita  two's complement number
				      
	
divSetup:					
	beq  $s7, 1, divideBy_zero   # If $s7 = 1, then user entered a zero as the operand
	beq  $t8, 0, divideBy_zero   # If display value = zero when we multiply, the answer is zero
	addi $s0, $zero, -1          # $s0 = counter, initialized to -1
	addi $s1, $t8, 0             # $s1 = value of $t8 (denominator), before we manipulate it
	
	nor  $s1, $s1, $zero         # Bitwise NOR $s1  (denom) with $zero to flip the bits
	addi $s1, $s1, 1             # Add 1 to put $s1 (denom) to make a NEGATIVE 2s complement number
	          
de_accumulate:
	beq, $t4, $s1, display_dividend  # If counter = the 2nd operand, we are done dividing  
	blt, $t4, $s1, display_dividend  # If counter < the 2nd operand, we are done dividing  	                          
	add  $t4, $t4, $s1               # subtract the value of denominator from the quotient
	addi $s0, $s0, 1                 # Increase counter by 1
	j de_accumulate

_divide_by_negative:
	beq  $s6, 1, _div_performOperation   # We're here because user wants a negative number
	addi $t4, $t8, 0
	addi $s6, $zero, 1          # $t4 < 0 because user has entered a negative number
	addi $t5, $zero, 13         # Keep operand divide
	add  $t6, $zero, 0          # Set $t6 to zero  
	addi $t7, $zero, 0          # Set $t7 to zero
	addi $t9, $zero, 0          # set $t9 back to $zero
	j wait
				
divideBy_zero:
	addi $t8, $zero, 0           # answer is zero
	addi $s7, $zero, 0           # restore zero value sentinel ($s7) to zero
	j end_divide
		  
display_dividend:
	beq  $s6, 1, negate_result
	bne  $s6, 1, positive_result
negate_result:
	nor  $s0, $s0, $zero         # Bitwise NOR $s1  (denom) with $zero to flip the bits
	addi $s0, $s0, 1  
	add  $t8, $s0, 0   
	add  $s6, $zero, 0
	j end_divide
positive_result:
	add  $t8, $s0, $zero         # Output value is the result of all our accumulation
	addi $s6, $zero, 0           # restore negative value sentinel ($s6) to zero
end_divide:	
	# Reset values
	addi $t5, $zero, 13          # Clear operand register
	addi $t4, $t8, 0             # Set $t4 to new operand
	add  $t6, $zero, 0           # Set $t6 to zero  
	addi $t7, $zero, 0           # Set $t7 = 0
	addi $t9, $zero, 0           # set $t9 back to $zero
	j wait

    
#////////////////////////
#//////   CLEAR  ////////
#////////////////////////	                                 
clear:
       # clear all registers
       addi $t9, $zero, 0 
       addi $t8, $zero, 0
       addi $t7, $zero, 0
       addi $t6, $zero, 0
       addi $t4, $zero, 0
       addi $t5, $zero, 0
       addi $t4, $zero, 0 
       addi $t3, $zero, 0
       addi $t2, $zero, 0
       addi $t1, $zero, 0
       addi $t0, $zero, 0
       j wait	

