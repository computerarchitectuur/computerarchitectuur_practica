	.file	"lucas.c"
	.text
.globl lucas
	.type	lucas, @function
lucas:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	movl	$0, -12(%ebp)
	cmpl	$1, 8(%ebp)
	jg	.L2
	movl	$2, -12(%ebp)
	jmp	.L3
.L2:
	movl	8(%ebp), %eax
	subl	$1, %eax
	movl	%eax, (%esp)
	call	lucas
	movl	%eax, -16(%ebp)
	movl	8(%ebp), %eax
	subl	$2, %eax
	movl	%eax, (%esp)
	call	lucas
	movl	%eax, -20(%ebp)
	movl	-20(%ebp), %eax
	addl	%eax, %eax
	addl	-16(%ebp), %eax
	movl	%eax, -12(%ebp)
.L3:
	movl	-12(%ebp), %eax
	leave
	ret
	.size	lucas, .-lucas
	.section	.rodata
.LC0:
	.string	"Lucas(%d) = %d \n"
	.align 4
.LC1:
	.string	"Formaat: %s waarde aantal_iteraties\n"
	.text
.globl main
	.type	main, @function
main:
	pushl	%ebp
	movl	%esp, %ebp
	andl	$-16, %esp
	subl	$48, %esp
	cmpl	$3, 8(%ebp)
	jne	.L6
	movl	12(%ebp), %eax
	addl	$4, %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	atoi
	movl	%eax, 40(%esp)
	movl	12(%ebp), %eax
	addl	$8, %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	atoi
	movl	%eax, 28(%esp)
	call	clock
	movl	%eax, 32(%esp)
	movl	$0, 44(%esp)
	jmp	.L7
.L8:
	movl	40(%esp), %eax
	movl	%eax, (%esp)
	call	lucas
	movl	%eax, 36(%esp)
	addl	$1, 44(%esp)
.L7:
	movl	44(%esp), %eax
	cmpl	28(%esp), %eax
	jl	.L8
	call	clock
	subl	32(%esp), %eax
	movl	%eax, 32(%esp)
	movl	$.LC0, %eax
	movl	36(%esp), %edx
	movl	%edx, 8(%esp)
	movl	40(%esp), %edx
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	printf
	movl	$0, %eax
	jmp	.L9
.L6:
	movl	12(%ebp), %eax
	movl	(%eax), %edx
	movl	$.LC1, %eax
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	printf
	movl	$1, %eax
.L9:
	leave
	ret
	.size	main, .-main
	.ident	"GCC: (Ubuntu 4.4.3-4ubuntu5) 4.4.3"
	.section	.note.GNU-stack,"",@progbits
