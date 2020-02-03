# Example: a simple factorial function:
#
#int fact (int n) {
#	if (n<1)
#		return 1;
#	else
#		return (n*fact(n-1));
#}

	.data
		insert_input:	.asciiz "Input: "
		output:	.asciiz "Factorial: "
	.text

main:	li $v0, 4
	la $a0, insert_input
	syscall	# prints input string
	
	li $v0, 5
	syscall	# reads input to factorial
	
	move $a0, $v0 #a0 = input

addi $sp, $sp, -4
sw $ra, 0($sp)
	jal fact
lw $ra, 0($sp)
addi $sp, $sp, 4
	
	move $t0, $v0	# t0 = factorial of input
	li $v0, 4
	la $a0, output
	syscall	#prints output string
	
	li $v0, 1
	move $a0, $t0
	syscall	# prints the input's factorial
	
	jr $ra
	

fact:	slti $t0, $a0, 1 #if (n>=1) go to "else"
	beq $t0, $0, else
	# else (make the "if")
	addi $v0, $0, 1	# if (n<1) return 1;
	jr $ra
	
else:	
addi $sp, $sp, -8 # save n and ra to stack before changing a0
sw $a0, 4($sp)	
sw $ra, 0($sp)
	addi $a0, $a0, -1 # $a0 = n – 1
	jal fact
lw $ra, 0($sp)
lw $a0, 4($sp)
addi $sp, $sp, 8
	mul $v0, $v0, $a0
	jr $ra