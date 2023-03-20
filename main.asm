####################################################################################################
## Author:      Michal Natonek                                                                    ##
## Task:        MIPS assembly - exercise 5                                                        ##
## Description: Create a tic tac toe game.                                                        ##
## Using:       MIPS Assembly / MARS 4.5                                                          ##
####################################################################################################

####################################################################################################
#  Global system call constants                                                                    #
####################################################################################################

.eqv SYS_PRINT_INT          1
.eqv SYS_PRINT_FLOAT        2
.eqv SYS_PRINT_DOUBLE       3
.eqv SYS_PRINT_STRING       4
.eqv SYS_READ_INT           5
.eqv SYS_READ_FLOAT         6
.eqv SYS_READ_DOUBLE        7
.eqv SYS_READ_STRING        8
.eqv SYS_SBRK               9
.eqv SYS_EXIT               10
.eqv SYS_PRINT_CHAR         11
.eqv SYS_READ_CHAR          12
.eqv SYS_RAND_INT_RANGE     42

####################################################################################################
#  Usefull macros                                                                                  #
####################################################################################################

#############################################################
# Name: pushStack                                           #
# Description: Saves contents of an register on the stack   #
# Inputs:  $reg - register to be saved                      #
# Outputs:                                                  #
#############################################################
.macro pushStack($reg)
	addi $sp, $sp, -4
	sw $reg, 0($sp)
.end_macro

#############################################################
# Name: popStack                                            #
# Description: Retrieves top of stack to an register        #
# Inputs:   $reg - register the value is stored into        #
# Outputs:  Saves top of the stack to given register        #
#############################################################
.macro popStack($reg)
	lw $reg, 0($sp)
	addi $sp, $sp, 4
.end_macro

#############################################################
# Name: newline                                             #
# Description: Prints new line character to the console     #
# Inputs:                                                   #
# Outputs:                                                  #
#############################################################
.macro newline
	pushStack($v0)
	pushStack($a0)
	li $v0, SYS_PRINT_CHAR
	li $a0, '\n'
	syscall
	popStack($a0)
	popStack($v0)
.end_macro

#############################################################
# Name: exit                                                #
# Description: Exirs the program                            #
# Inputs:                                                   #
# Outputs:                                                  #
#############################################################
.macro exit
	li $v0, SYS_EXIT
	syscall
.end_macro

####################################################################################################
# Main function                                                                                    #
####################################################################################################
.text
.globl main 
main:	
	la $a0, promptRounds
	jal PromptForInt
	add $s0, $zero, $v0
	li $s1, 0
	li $s2, 0
roundLoop:
	beqz $s0, roundLoopEnd
	jal ClearBoard
gameLoop:
	jal BoardState
	li $a0, 'X'
	jal NextMove
	jal CheckForWin
	beq $v0, 1, playerXwin
	jal CheckForDraw
	beq $v0, 1, playerDraw
	li $a0, 'O'
	#jal BoardState
	#jal NextMove # Manual player
	jal ComputerMakeMove # Computer player
	jal CheckForWin
	beq $v0, 1, playerOwin
	jal CheckForDraw
	beq $v0, 1, playerDraw
	j gameLoop
playerOwin:
	la $a0, messageWinO
	jal PrintMessage
	addi $s1, $s1, 1
	j gameLoopEnd
playerXwin:
	la $a0, messageWinX
	jal PrintMessage
	addi $s2, $s2, 1
	j gameLoopEnd
playerDraw:
	la $a0, messageDraw
	jal PrintMessage
	j gameLoopEnd
gameLoopEnd:
	la $a0, messageScore
	jal PrintMessage
	la $a0, scoreO
	jal PrintMessage
	add $a0, $zero, $s1
	li $v0, SYS_PRINT_INT
	syscall
	newline
	la $a0, scoreX
	jal PrintMessage
	add $a0, $zero, $s2
	li $v0, SYS_PRINT_INT
	syscall
	newline
	subi $s0, $s0, 1
	j roundLoop
roundLoopEnd:
	exit
.data
	board:        .byte 'O', 'X', ' ', ' ', 'X', 'O', 'O', 'O', ' '
	promptRounds: .asciiz "Number of rounds to be played (1-5): "
	messageDraw:  .asciiz "It's a draw!!!\n"
	messageWinO:  .asciiz "Player O wins!!!\n"
	messageWinX:  .asciiz "Player X wins!!!\n"
	messageScore: .asciiz "Current score:\n"
	scoreO:	      .asciiz "O - "
	scoreX:       .asciiz "X - "
####################################################################################################
#  Utility Functions                                                                               #
####################################################################################################
	
#############################################################
# Name: PrintMessage                                        #
# Description: Prints string message to the console         #
# Inputs:  $a0 - address of the string to be printed        #
# Outputs:                                                  #
#############################################################
.text
.globl PrintMessage
PrintMessage:	
	li $v0, SYS_PRINT_STRING
	syscall
	jr $ra
	
###########################################################################
# Name: PromptForInt                                                      #
# Description: Prints message to the console then waits for integer input #
# Inputs:  $a0 - address of the string to print                           #
# Outputs: $v0 - inputed number                                           #
###########################################################################
.text
.globl PromptForInt
PromptForInt:
	li $v0, SYS_PRINT_STRING
	syscall
	li $v0, SYS_READ_INT
	syscall
	jr $ra
	
###########################################################################
# Name: ClearBoard                                                        #
# Description: Clears board                                               #
# Inputs:                                                                 #
# Outputs:                                                                #
###########################################################################
.text
.globl ClearBoard 
ClearBoard:
	la $t0, board
	li $t1, ' '
	sb $t1, 0($t0)
	sb $t1, 1($t0)
	sb $t1, 2($t0)
	sb $t1, 3($t0)
	sb $t1, 4($t0)
	sb $t1, 5($t0)
	sb $t1, 6($t0)
	sb $t1, 7($t0)
	sb $t1, 8($t0)
	jr $ra
	
###########################################################################
# Name: BoardState                                                        #
# Description: Prints board state                                         #
# Inputs:                                                                 #
# Outputs:                                                                #
###########################################################################
.text
.globl BoardState
BoardState:
	pushStack($ra)
	pushStack($s0)
	pushStack($s1)
	
	la $a0, message1
	jal PrintMessage
	la $a0, boardNames
	jal PrintMessage
	newline
	la $a0, message2
	jal PrintMessage
	
	li $t0, 0
	la $s0, board
BoardStateLoop:
	la $s1, lineBuffer
	
	li $t3, ' '
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	lb $t3, ($s0)
	sb $t3, ($s1)
	addi $s1, $s1, 1
	addi $s0, $s0, 1
	
	li $t3, ' '
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	li $t3, '|'
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	li $t3, ' '
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	lb $t3, ($s0)
	sb $t3, ($s1)
	addi $s1, $s1, 1
	addi $s0, $s0, 1
	
	li $t3, ' '
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	li $t3, '|'
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	li $t3, ' '
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	lb $t3, ($s0)
	sb $t3, ($s1)
	addi $s1, $s1, 1
	addi $s0, $s0, 1
	
	li $t3, ' '
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	li $t3, '\n'
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	li $t3, '\0'
	sb $t3, ($s1)
	addi $s1, $s1, 1
	
	la $a0, lineBuffer
	jal PrintMessage
	
	addi $t0, $t0, 1
	
	beq $t0, 3, BoardStateEnd
	
	la $a0, deli
	jal PrintMessage
	
	j BoardStateLoop
BoardStateEnd:
	newline
	popStack($s1)
	popStack($s0)
	popStack($ra)
	jr $ra	
.data
	message1: .asciiz "Board's fields codes:\n\n"
	message2: .asciiz "Current board state:\n\n"
	deli: .asciiz "---|---|---\n"
	boardNames: .asciiz " 1 | 2 | 3 \n---|---|---\n 4 | 5 | 6 \n---|---|---\n 7 | 8 | 9 \n"
	lineBuffer: .space 13
	
###########################################################################
# Name: NextMove                                                          #
# Description: Prompts for next move from player                          #
# Inputs:  $a0 - next character to be placed                              #
# Outputs:                                                                #
###########################################################################
.text
.globl NextMove 
NextMove:
	pushStack($ra)
	pushStack($s0)
	add $s0, $zero, $a0
NextMoveBeging:
	la $a0, messageNextMove
	jal PrintMessage
	
	add $a0, $zero, $s0
	li $v0, SYS_PRINT_CHAR
	syscall
	newline
	
	la $a0, promptNextMove
	jal PromptForInt
	
	slti $t0, $v0, 10
	sub $t1, $zero, $v0
	slti $t1, $t1, 0
	and $t0, $t0, $t1
	bnez $t0, NextMoveCheck
NextMoveError:
	la $a0, errorNextMove
	jal PrintMessage
	j NextMoveBeging
NextMoveCheck:
	subi $v0, $v0, 1
	la $t0, board
	add $t0, $t0, $v0
	lb $t1, ($t0)
	bne $t1, ' ', NextMoveError
	sb $s0, ($t0)
	popStack($s0)
	popStack($ra)
	jr $ra
.data
	messageNextMove: .asciiz "Current player "
	promptNextMove: .asciiz "Your next move: "
	errorNextMove: .asciiz "Incorect move!!!\n"
	
###########################################################################
# Name: CheckForWin                                                       #
# Description: Checks if current state is winning                         #
# Inputs:                                                                 #
# Outputs: v0 - 0 = not wining state  1 = winning state                   #
###########################################################################
.macro checkWin
	seq $t0, $t0, $t1
	seq $t1, $t1, $t2
	sne $t2, $t2, ' '
	and $t0, $t0, $t1
	and $t0, $t0, $t2
.end_macro
.text
.globl CheckForWin 
CheckForWin:
	pushStack($s0)
	li $v0, 0
	la $s0, board
	#Rows
	lb $t0, 0($s0)
	lb $t1, 1($s0)
	lb $t2, 2($s0)
	checkWin
	bnez $t0, Win
	
	lb $t0, 3($s0)
	lb $t1, 4($s0)
	lb $t2, 5($s0)
	checkWin
	bnez $t0, Win

	lb $t0, 6($s0)
	lb $t1, 7($s0)
	lb $t2, 8($s0)
	checkWin
	bnez $t0, Win
	#Columns
	lb $t0, 0($s0)
	lb $t1, 3($s0)
	lb $t2, 6($s0)
	checkWin
	bnez $t0, Win
	
	lb $t0, 1($s0)
	lb $t1, 4($s0)
	lb $t2, 7($s0)
	checkWin
	bnez $t0, Win
	
	lb $t0, 2($s0)
	lb $t1, 5($s0)
	lb $t2, 8($s0)
	checkWin
	bnez $t0, Win
	#Diagonal
	lb $t0, 0($s0)
	lb $t1, 4($s0)
	lb $t2, 8($s0)
	checkWin
	bnez $t0, Win
	
	lb $t0, 2($s0)
	lb $t1, 4($s0)
	lb $t2, 6($s0)
	checkWin
	bnez $t0, Win
	
	j ItsNeutral
Win:
	li $v0, 1
ItsNeutral:
	popStack($s0)
	jr $ra

###########################################################################
# Name: CheckForDraw                                                      #
# Description: Checks if current state is draw                            #
# Inputs:                                                                 #
# Outputs: $v0 - 0 = not draw state  1 = draw state                       #
###########################################################################
.macro checkDraw
	seq $t0, $t0, ' '
	or $t1, $t1, $t0
.end_macro
.text
.globl CheckForDraw
CheckForDraw:
	pushStack($s0)
	la $s0, board
	li $v0, 0
	
	lb $t0, 0($s0)
	seq $t1, $t0, ' ' 
	lb $t0, 1($s0)
	checkDraw
	lb $t0, 2($s0)
	checkDraw
	lb $t0, 3($s0)
	checkDraw
	lb $t0, 4($s0)
	checkDraw
	lb $t0, 5($s0)
	checkDraw
	lb $t0, 6($s0)
	checkDraw
	lb $t0, 7($s0)
	checkDraw
	lb $t0, 8($s0)
	checkDraw
	
	bnez $t1, CheckForDrawEnd
	li $v0, 1
CheckForDrawEnd:
	popStack($s0)
	jr $ra

###########################################################################
# Name: ComputerMakeMove                                                  #
# Description: Generates next move by cumputer.                           #
# Inputs:  $a0 - next character to be placed                              #
# Outputs:                                                                #
###########################################################################
.text
.globl ComputerMakeMove    
ComputerMakeMove:
	pushStack($ra)
	pushStack($s0)
	pushStack($s1)
	pushStack($s2)
	pushStack($s3)
	add $s2, $zero, $a0

#Seek win
	li $s1, 0
	la $s0, board
SeekWin:
	beq $s1, 9, SeekWinEnd
	
	lb $t1, ($s0)
	bne $t1, ' ', SeekWinNext

	sb $s2, ($s0)
	jal CheckForWin
	bnez $v0, ComputerMakeMoveEnd
	
	li $t1, ' '
	sb $t1, ($s0)
SeekWinNext:	
	addi $s0, $s0, 1
	addi $s1, $s1, 1 
	j SeekWin
SeekWinEnd:

#Seek counter
	li $s1, 0
	la $s0, board
	pushStack($s2)
	beq $s2, 'O', ChangeToX
	li $s2, 'O'
	j SeekCounter
ChangeToX:
	li $s2, 'X'
SeekCounter:
	beq $s1, 9,  SeekCounterEnd
	
	lb $t1, ($s0)
	bne $t1, ' ', SeekCounterNext
	
	sb $s2, ($s0)
	jal CheckForWin
	beqz $v0, SeekCounterReverse
	popStack($s2)
	sb $s2, ($s0)
	j ComputerMakeMoveEnd
SeekCounterReverse:
	li $t1, ' '
	sb $t1, ($s0)
SeekCounterNext:
	addi $s0, $s0, 1
	addi $s1, $s1, 1 
	j SeekCounter
SeekCounterEnd:
	popStack($s2)


#SeekInOrder
	li $s1, 0
	la $s0, board
	la $s3, checkInOrder
SeekInOrder:
	beq $s1, 9, SeekInOrderEnd
	
	add $t0, $zero, $s0
	lb $t1, ($s3)
	add $t0, $t0, $t1
	lb $t1, ($t0)
	bne $t1, ' ', SeekInOrderNext
	sb $s2, ($t0)
	j ComputerMakeMoveEnd
	
SeekInOrderNext:
	addi $s1, $s1, 1
	addi $s3, $s3, 1
	j SeekInOrder
SeekInOrderEnd:

ComputerMakeMoveEnd:
	popStack($s3)
	popStack($s2)
	popStack($s1)
	popStack($s0)
	popStack($ra)
	jr $ra
.data
	checkInOrder: .byte 4, 0, 6, 8, 2, 1, 3, 7, 5

