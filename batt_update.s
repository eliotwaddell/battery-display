	.file	"batt_update.c"
	.text
	.globl	set_batt_from_ports
	.type	set_batt_from_ports, @function
set_batt_from_ports:
.LFB53:
	.cfi_startproc
	movzwl	BATT_VOLTAGE_PORT(%rip), %eax
	testw	%ax, %ax
	js	.L6
	movw	%ax, (%rdi)
	cmpw	$3800, %ax
	jle	.L3
	movb	$100, 2(%rdi)
.L4:
	cmpb	$0, 2(%rdi)
	js	.L7
.L5:
	movzbl	BATT_STATUS_PORT(%rip), %eax
	andl	$1, %eax
	movb	%al, 3(%rdi)
	movl	$0, %eax
	ret
.L3:
	movswl	BATT_VOLTAGE_PORT(%rip), %edx
	subl	$3000, %edx
	leal	7(%rdx), %eax
	testl	%edx, %edx
	cmovns	%edx, %eax
	sarl	$3, %eax
	movb	%al, 2(%rdi)
	jmp	.L4
.L7:
	movb	$0, 2(%rdi)
	jmp	.L5
.L6:
	movl	$1, %eax
	ret
	.cfi_endproc
.LFE53:
	.size	set_batt_from_ports, .-set_batt_from_ports
	.globl	set_display_from_batt
	.type	set_display_from_batt, @function
set_display_from_batt:
.LFB54:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	subq	$48, %rsp
	.cfi_def_cfa_offset 64
	movq	%fs:40, %rax
	movq	%rax, 40(%rsp)
	xorl	%eax, %eax
	movl	$0, (%rsi)
	movl	$63, (%rsp)
	movl	$3, 4(%rsp)
	movl	$109, 8(%rsp)
	movl	$103, 12(%rsp)
	movl	$83, 16(%rsp)
	movl	$118, 20(%rsp)
	movl	$126, 24(%rsp)
	movl	$35, 28(%rsp)
	movl	$127, 32(%rsp)
	movl	$119, 36(%rsp)
	movl	%edi, %eax
	sarl	$24, %eax
	testb	%al, %al
	je	.L9
	movl	%edi, %ecx
	sall	$8, %ecx
	sarl	$24, %ecx
.L10:
	movl	$1717986919, %r8d
	movl	%ecx, %eax
	imull	%r8d
	sarl	$2, %edx
	movl	%ecx, %ebx
	sarl	$31, %ebx
	subl	%ebx, %edx
	movl	%edx, %r11d
	leal	(%rdx,%rdx,4), %edx
	leal	(%rdx,%rdx), %eax
	movl	%ecx, %r9d
	subl	%eax, %r9d
	movl	%r11d, %eax
	imull	%r8d
	sarl	$2, %edx
	movl	%r11d, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	leal	(%rdx,%rdx,4), %edx
	leal	(%rdx,%rdx), %eax
	subl	%eax, %r11d
	movl	$1374389535, %edx
	movl	%ecx, %eax
	imull	%edx
	movl	%edx, %ecx
	sarl	$5, %ecx
	subl	%ebx, %ecx
	movl	%ecx, %eax
	imull	%r8d
	movl	%edx, %eax
	sarl	$2, %eax
	movl	%ecx, %edx
	sarl	$31, %edx
	subl	%edx, %eax
	leal	(%rax,%rax,4), %edx
	leal	(%rdx,%rdx), %eax
	subl	%eax, %ecx
	movl	%ecx, %eax
	je	.L11
	cltq
	movl	(%rsp,%rax,4), %eax
	sall	$7, %eax
	movslq	%r11d, %r10
	orl	(%rsp,%r10,4), %eax
	sall	$7, %eax
	movslq	%r9d, %r9
	orl	(%rsp,%r9,4), %eax
	movl	%eax, (%rsi)
.L12:
	movl	%edi, %eax
	sarl	$24, %eax
	testb	%al, %al
	je	.L14
	orl	$8388608, (%rsi)
.L15:
	sall	$8, %edi
	sarl	$24, %edi
	cmpb	$89, %dil
	jg	.L23
	cmpb	$69, %dil
	jg	.L24
	cmpb	$49, %dil
	jg	.L25
	cmpb	$29, %dil
	jg	.L26
	cmpb	$4, %dil
	jle	.L17
	orl	$268435456, (%rsi)
	jmp	.L17
.L9:
	movswl	%di, %r8d
	addl	$5, %r8d
	movl	$1717986919, %edx
	movl	%r8d, %eax
	imull	%edx
	sarl	$2, %edx
	sarl	$31, %r8d
	movl	%edx, %ecx
	subl	%r8d, %ecx
	jmp	.L10
.L11:
	testl	%r11d, %r11d
	je	.L13
	movslq	%r11d, %r10
	movl	(%rsp,%r10,4), %eax
	sall	$7, %eax
	movslq	%r9d, %r9
	orl	(%rsp,%r9,4), %eax
	movl	%eax, (%rsi)
	jmp	.L12
.L13:
	movslq	%r9d, %r9
	movl	(%rsp,%r9,4), %eax
	movl	%eax, (%rsi)
	jmp	.L12
.L14:
	movl	(%rsi), %eax
	orl	$6291456, %eax
	movl	%eax, (%rsi)
	jmp	.L15
.L23:
	movl	(%rsi), %eax
	orl	$520093696, %eax
	movl	%eax, (%rsi)
.L17:
	movl	$0, %eax
	movq	40(%rsp), %rbx
	xorq	%fs:40, %rbx
	jne	.L27
	addq	$48, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
.L24:
	.cfi_restore_state
	movl	(%rsi), %eax
	orl	$503316480, %eax
	movl	%eax, (%rsi)
	jmp	.L17
.L25:
	movl	(%rsi), %eax
	orl	$469762048, %eax
	movl	%eax, (%rsi)
	jmp	.L17
.L26:
	movl	(%rsi), %eax
	orl	$402653184, %eax
	movl	%eax, (%rsi)
	jmp	.L17
.L27:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE54:
	.size	set_display_from_batt, .-set_display_from_batt
	.globl	batt_update
	.type	batt_update, @function
batt_update:
.LFB52:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	movq	%fs:40, %rax
	movq	%rax, 8(%rsp)
	xorl	%eax, %eax
	movw	$-100, 4(%rsp)
	movb	$-1, 6(%rsp)
	movb	$-1, 7(%rsp)
	leaq	4(%rsp), %rdi
	call	set_batt_from_ports
	testl	%eax, %eax
	je	.L33
	movl	$1, %ebx
.L28:
	movl	%ebx, %eax
	movq	8(%rsp), %rdx
	xorq	%fs:40, %rdx
	jne	.L34
	addq	$16, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
.L33:
	.cfi_restore_state
	movl	%eax, %ebx
	leaq	BATT_DISPLAY_PORT(%rip), %rsi
	movl	4(%rsp), %edi
	call	set_display_from_batt
	jmp	.L28
.L34:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE52:
	.size	batt_update, .-batt_update
	.ident	"GCC: (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0"
	.section	.note.GNU-stack,"",@progbits
