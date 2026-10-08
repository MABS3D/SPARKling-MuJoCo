
/var/tmp/sparkling-alignment-315-sparse-args-release-r15-20261007/force-build/release/bin/flex_constrained_probe:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

00000000000bcae0 <mj__constraint_solvers__sparse_cholesky__factor>:
   bcae0:	4c 8d 54 24 08       	lea    0x8(%rsp),%r10
   bcae5:	48 83 e4 c0          	and    $0xffffffffffffffc0,%rsp
   bcae9:	41 ff 72 f8          	push   -0x8(%r10)
   bcaed:	55                   	push   %rbp
   bcaee:	48 89 e5             	mov    %rsp,%rbp
   bcaf1:	41 57                	push   %r15
   bcaf3:	41 56                	push   %r14
   bcaf5:	41 55                	push   %r13
   bcaf7:	41 54                	push   %r12
   bcaf9:	41 52                	push   %r10
   bcafb:	53                   	push   %rbx
   bcafc:	49 89 cc             	mov    %rcx,%r12
   bcaff:	48 81 ec 00 01 00 00 	sub    $0x100,%rsp
   bcb06:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
   bcb0d:	48 63 12             	movslq (%rdx),%rdx
   bcb10:	45 8b 48 0c          	mov    0xc(%r8),%r9d
   bcb14:	45 8b 78 04          	mov    0x4(%r8),%r15d
   bcb18:	41 8b 18             	mov    (%r8),%ebx
   bcb1b:	4c 89 85 08 ff ff ff 	mov    %r8,-0xf8(%rbp)
   bcb22:	45 8b 40 08          	mov    0x8(%r8),%r8d
   bcb26:	c5 fb 11 85 18 ff ff 	vmovsd %xmm0,-0xe8(%rbp)
   bcb2d:	ff 
   bcb2e:	48 89 bd 00 ff ff ff 	mov    %rdi,-0x100(%rbp)
   bcb35:	48 89 b5 30 ff ff ff 	mov    %rsi,-0xd0(%rbp)
   bcb3c:	31 f6                	xor    %esi,%esi
   bcb3e:	49 89 d5             	mov    %rdx,%r13
   bcb41:	44 89 4d 80          	mov    %r9d,-0x80(%rbp)
   bcb45:	44 89 45 88          	mov    %r8d,-0x78(%rbp)
   bcb49:	48 c1 e2 03          	shl    $0x3,%rdx
   bcb4d:	48 8d 42 0f          	lea    0xf(%rdx),%rax
   bcb51:	48 83 e0 f0          	and    $0xfffffffffffffff0,%rax
   bcb55:	48 29 c4             	sub    %rax,%rsp
   bcb58:	48 89 e7             	mov    %rsp,%rdi
   bcb5b:	e8 80 89 f4 ff       	call   54e0 <memset@plt>
   bcb60:	48 63 55 88          	movslq -0x78(%rbp),%rdx
   bcb64:	48 63 45 80          	movslq -0x80(%rbp),%rax
   bcb68:	31 c9                	xor    %ecx,%ecx
   bcb6a:	48 63 f3             	movslq %ebx,%rsi
   bcb6d:	4c 89 e7             	mov    %r12,%rdi
   bcb70:	49 89 c1             	mov    %rax,%r9
   bcb73:	48 29 d0             	sub    %rdx,%rax
   bcb76:	48 8d 04 c5 08 00 00 	lea    0x8(,%rax,8),%rax
   bcb7d:	00 
   bcb7e:	41 39 d1             	cmp    %edx,%r9d
   bcb81:	48 0f 4d c8          	cmovge %rax,%rcx
   bcb85:	49 63 c7             	movslq %r15d,%rax
   bcb88:	31 d2                	xor    %edx,%edx
   bcb8a:	48 ff c0             	inc    %rax
   bcb8d:	48 29 f0             	sub    %rsi,%rax
   bcb90:	48 0f af c1          	imul   %rcx,%rax
   bcb94:	41 39 df             	cmp    %ebx,%r15d
   bcb97:	48 0f 4d d0          	cmovge %rax,%rdx
   bcb9b:	31 f6                	xor    %esi,%esi
   bcb9d:	e8 3e 89 f4 ff       	call   54e0 <memset@plt>
   bcba2:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
   bcba9:	8b 00                	mov    (%rax),%eax
   bcbab:	85 c0                	test   %eax,%eax
   bcbad:	0f 8e 7b 09 00 00    	jle    bd52e <mj__constraint_solvers__sparse_cholesky__factor+0xa4e>
   bcbb3:	48 ff c0             	inc    %rax
   bcbb6:	c5 fb 10 25 32 7c 24 	vmovsd 0x247c32(%rip),%xmm4        # 3047f0 <CSWTCH.1415+0x470>
   bcbbd:	00 
   bcbbe:	44 89 ad 70 ff ff ff 	mov    %r13d,-0x90(%rbp)
   bcbc5:	48 89 a5 38 ff ff ff 	mov    %rsp,-0xc8(%rbp)
   bcbcc:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
   bcbd3:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   bcbda:	4c 8b bd 28 ff ff ff 	mov    -0xd8(%rbp),%r15
   bcbe1:	4c 89 a5 10 ff ff ff 	mov    %r12,-0xf0(%rbp)
   bcbe8:	8b 48 04             	mov    0x4(%rax),%ecx
   bcbeb:	8b 58 0c             	mov    0xc(%rax),%ebx
   bcbee:	44 8b 50 08          	mov    0x8(%rax),%r10d
   bcbf2:	89 8d 74 ff ff ff    	mov    %ecx,-0x8c(%rbp)
   bcbf8:	8b 08                	mov    (%rax),%ecx
   bcbfa:	89 4d 88             	mov    %ecx,-0x78(%rbp)
   bcbfd:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
   bcc04:	48 8b 8d 58 ff ff ff 	mov    -0xa8(%rbp),%rcx
   bcc0b:	45 31 db             	xor    %r11d,%r11d
   bcc0e:	48 63 78 08          	movslq 0x8(%rax),%rdi
   bcc12:	48 63 40 0c          	movslq 0xc(%rax),%rax
   bcc16:	48 89 8d 20 ff ff ff 	mov    %rcx,-0xe0(%rbp)
   bcc1d:	48 ff c9             	dec    %rcx
   bcc20:	41 8b 34 8f          	mov    (%r15,%rcx,4),%esi
   bcc24:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
   bcc2b:	48 89 c2             	mov    %rax,%rdx
   bcc2e:	89 85 68 ff ff ff    	mov    %eax,-0x98(%rbp)
   bcc34:	48 29 f8             	sub    %rdi,%rax
   bcc37:	89 7d 80             	mov    %edi,-0x80(%rbp)
   bcc3a:	48 8d 04 c5 08 00 00 	lea    0x8(,%rax,8),%rax
   bcc41:	00 
   bcc42:	39 d7                	cmp    %edx,%edi
   bcc44:	4c 0f 4e d8          	cmovle %rax,%r11
   bcc48:	85 f6                	test   %esi,%esi
   bcc4a:	0f 88 cd 08 00 00    	js     bd51d <mj__constraint_solvers__sparse_cholesky__factor+0xa3d>
   bcc50:	41 8b 0f             	mov    (%r15),%ecx
   bcc53:	0f 84 56 01 00 00    	je     bcdaf <mj__constraint_solvers__sparse_cholesky__factor+0x2cf>
   bcc59:	4c 8b a5 58 ff ff ff 	mov    -0xa8(%rbp),%r12
   bcc60:	44 39 e1             	cmp    %r12d,%ecx
   bcc63:	0f 8c 70 08 00 00    	jl     bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bcc69:	41 89 c9             	mov    %ecx,%r9d
   bcc6c:	49 8d 44 24 ff       	lea    -0x1(%r12),%rax
   bcc71:	49 0f af c1          	imul   %r9,%rax
   bcc75:	4a 8d 44 48 01       	lea    0x1(%rax,%r9,2),%rax
   bcc7a:	41 8b 04 87          	mov    (%r15,%rax,4),%eax
   bcc7e:	85 c0                	test   %eax,%eax
   bcc80:	0f 8e 53 08 00 00    	jle    bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bcc86:	41 39 c5             	cmp    %eax,%r13d
   bcc89:	0f 8c 4a 08 00 00    	jl     bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bcc8f:	4c 8b b5 30 ff ff ff 	mov    -0xd0(%rbp),%r14
   bcc96:	41 8b 16             	mov    (%r14),%edx
   bcc99:	89 95 78 ff ff ff    	mov    %edx,-0x88(%rbp)
   bcc9f:	41 39 d4             	cmp    %edx,%r12d
   bcca2:	0f 8c 31 08 00 00    	jl     bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bcca8:	45 3b 66 04          	cmp    0x4(%r14),%r12d
   bccac:	0f 8f 27 08 00 00    	jg     bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bccb2:	39 45 80             	cmp    %eax,-0x80(%rbp)
   bccb5:	0f 8f 1e 08 00 00    	jg     bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bccbb:	48 63 95 78 ff ff ff 	movslq -0x88(%rbp),%rdx
   bccc2:	c4 c1 f9 6e ef       	vmovq  %r15,%xmm5
   bccc7:	89 9d 78 ff ff ff    	mov    %ebx,-0x88(%rbp)
   bcccd:	4c 8b b5 38 ff ff ff 	mov    -0xc8(%rbp),%r14
   bccd4:	89 cb                	mov    %ecx,%ebx
   bccd6:	8d 4e 01             	lea    0x1(%rsi),%ecx
   bccd9:	49 c1 eb 03          	shr    $0x3,%r11
   bccdd:	c4 e1 f9 6e c2       	vmovq  %rdx,%xmm0
   bcce2:	48 8b 95 20 ff ff ff 	mov    -0xe0(%rbp),%rdx
   bcce9:	48 83 ea 02          	sub    $0x2,%rdx
   bcced:	49 0f af d1          	imul   %r9,%rdx
   bccf1:	4a 8d 54 4a 01       	lea    0x1(%rdx,%r9,2),%rdx
   bccf6:	4d 89 e1             	mov    %r12,%r9
   bccf9:	c4 c1 f9 7e c4       	vmovq  %xmm0,%r12
   bccfe:	4d 29 e1             	sub    %r12,%r9
   bcd01:	4d 8d 04 97          	lea    (%r15,%rdx,4),%r8
   bcd05:	ba 02 00 00 00       	mov    $0x2,%edx
   bcd0a:	4d 0f af cb          	imul   %r11,%r9
   bcd0e:	4d 89 c7             	mov    %r8,%r15
   bcd11:	44 8b 9d 68 ff ff ff 	mov    -0x98(%rbp),%r11d
   bcd18:	44 89 95 68 ff ff ff 	mov    %r10d,-0x98(%rbp)
   bcd1f:	4c 8b 95 00 ff ff ff 	mov    -0x100(%rbp),%r10
   bcd26:	4d 89 cc             	mov    %r9,%r12
   bcd29:	49 89 f9             	mov    %rdi,%r9
   bcd2c:	8b 7d 80             	mov    -0x80(%rbp),%edi
   bcd2f:	eb 3f                	jmp    bcd70 <mj__constraint_solvers__sparse_cholesky__factor+0x290>
   bcd31:	0f 1f 40 00          	nopl   0x0(%rax)
   bcd35:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   bcd3c:	00 00 00 00 
   bcd40:	89 d0                	mov    %edx,%eax
   bcd42:	39 d6                	cmp    %edx,%esi
   bcd44:	0f 4e c6             	cmovle %esi,%eax
   bcd47:	39 c3                	cmp    %eax,%ebx
   bcd49:	0f 8c 8a 07 00 00    	jl     bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bcd4f:	41 8b 44 97 fc       	mov    -0x4(%r15,%rdx,4),%eax
   bcd54:	85 c0                	test   %eax,%eax
   bcd56:	0f 8e 7d 07 00 00    	jle    bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bcd5c:	41 39 c5             	cmp    %eax,%r13d
   bcd5f:	0f 8c 74 07 00 00    	jl     bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bcd65:	48 ff c2             	inc    %rdx
   bcd68:	39 c7                	cmp    %eax,%edi
   bcd6a:	0f 8f 69 07 00 00    	jg     bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bcd70:	41 39 c3             	cmp    %eax,%r11d
   bcd73:	0f 8c 60 07 00 00    	jl     bd4d9 <mj__constraint_solvers__sparse_cholesky__factor+0x9f9>
   bcd79:	49 89 c0             	mov    %rax,%r8
   bcd7c:	4d 29 c8             	sub    %r9,%r8
   bcd7f:	4d 01 e0             	add    %r12,%r8
   bcd82:	c4 81 7b 10 04 c2    	vmovsd (%r10,%r8,8),%xmm0
   bcd88:	c4 c1 7b 11 44 c6 f8 	vmovsd %xmm0,-0x8(%r14,%rax,8)
   bcd8f:	48 39 d1             	cmp    %rdx,%rcx
   bcd92:	75 ac                	jne    bcd40 <mj__constraint_solvers__sparse_cholesky__factor+0x260>
   bcd94:	89 d9                	mov    %ebx,%ecx
   bcd96:	44 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%r10d
   bcd9d:	8b 9d 78 ff ff ff    	mov    -0x88(%rbp),%ebx
   bcda3:	4c 89 b5 38 ff ff ff 	mov    %r14,-0xc8(%rbp)
   bcdaa:	c4 c1 f9 7e ef       	vmovq  %xmm5,%r15
   bcdaf:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
   bcdb6:	48 63 c1             	movslq %ecx,%rax
   bcdb9:	48 ba ff ff ff ff ff 	movabs $0x3fffffffffffffff,%rdx
   bcdc0:	ff ff 3f 
   bcdc3:	c4 e1 f9 6e d0       	vmovq  %rax,%xmm2
   bcdc8:	48 ff c0             	inc    %rax
   bcdcb:	48 21 d0             	and    %rdx,%rax
   bcdce:	48 8d 44 06 ff       	lea    -0x1(%rsi,%rax,1),%rax
   bcdd3:	41 8b 04 87          	mov    (%r15,%rax,4),%eax
   bcdd7:	89 85 78 ff ff ff    	mov    %eax,-0x88(%rbp)
   bcddd:	85 c0                	test   %eax,%eax
   bcddf:	0f 88 27 07 00 00    	js     bd50c <mj__constraint_solvers__sparse_cholesky__factor+0xa2c>
   bcde5:	41 89 c3             	mov    %eax,%r11d
   bcde8:	83 f8 01             	cmp    $0x1,%eax
   bcdeb:	0f 8e 41 02 00 00    	jle    bd032 <mj__constraint_solvers__sparse_cholesky__factor+0x552>
   bcdf1:	49 89 f6             	mov    %rsi,%r14
   bcdf4:	39 f1                	cmp    %esi,%ecx
   bcdf6:	0f 8c f2 07 00 00    	jl     bd5ee <mj__constraint_solvers__sparse_cholesky__factor+0xb0e>
   bcdfc:	c4 e1 f9 7e d0       	vmovq  %xmm2,%rax
   bce01:	4d 63 c2             	movslq %r10d,%r8
   bce04:	48 63 f3             	movslq %ebx,%rsi
   bce07:	4c 8d 0c c5 00 00 00 	lea    0x0(,%rax,8),%r9
   bce0e:	00 
   bce0f:	48 0f af c0          	imul   %rax,%rax
   bce13:	4c 29 c6             	sub    %r8,%rsi
   bce16:	48 8d 3c f5 08 00 00 	lea    0x8(,%rsi,8),%rdi
   bce1d:	00 
   bce1e:	31 f6                	xor    %esi,%esi
   bce20:	48 c1 e0 02          	shl    $0x2,%rax
   bce24:	44 39 d3             	cmp    %r10d,%ebx
   bce27:	4e 8d 24 08          	lea    (%rax,%r9,1),%r12
   bce2b:	4a 8d 54 08 04       	lea    0x4(%rax,%r9,1),%rdx
   bce30:	48 0f 4d f7          	cmovge %rdi,%rsi
   bce34:	4a 8d 44 20 04       	lea    0x4(%rax,%r12,1),%rax
   bce39:	49 8d 7e ff          	lea    -0x1(%r14),%rdi
   bce3d:	4c 89 a5 48 ff ff ff 	mov    %r12,-0xb8(%rbp)
   bce44:	c4 61 f9 6e c7       	vmovq  %rdi,%xmm8
   bce49:	48 89 b5 68 ff ff ff 	mov    %rsi,-0x98(%rbp)
   bce50:	c4 e1 f9 7e d7       	vmovq  %xmm2,%rdi
   bce55:	41 8d 73 01          	lea    0x1(%r11),%esi
   bce59:	c4 41 f9 7e c3       	vmovq  %xmm8,%r11
   bce5e:	48 89 b5 50 ff ff ff 	mov    %rsi,-0xb0(%rbp)
   bce65:	4d 89 c4             	mov    %r8,%r12
   bce68:	be 02 00 00 00       	mov    $0x2,%esi
   bce6d:	49 0f af fb          	imul   %r11,%rdi
   bce71:	4c 8b 9d 10 ff ff ff 	mov    -0xf0(%rbp),%r11
   bce78:	49 c1 e9 02          	shr    $0x2,%r9
   bce7c:	c4 61 f9 6e cf       	vmovq  %rdi,%xmm9
   bce81:	48 c1 ea 02          	shr    $0x2,%rdx
   bce85:	48 c1 e8 02          	shr    $0x2,%rax
   bce89:	4c 89 4d 80          	mov    %r9,-0x80(%rbp)
   bce8d:	48 89 95 40 ff ff ff 	mov    %rdx,-0xc0(%rbp)
   bce94:	4d 89 f9             	mov    %r15,%r9
   bce97:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
   bce9e:	4c 8b bd 38 ff ff ff 	mov    -0xc8(%rbp),%r15
   bcea5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   bceac:	00 00 00 00 
   bceb0:	3b 8d 78 ff ff ff    	cmp    -0x88(%rbp),%ecx
   bceb6:	0f 8d d4 03 00 00    	jge    bd290 <mj__constraint_solvers__sparse_cholesky__factor+0x7b0>
   bcebc:	39 f1                	cmp    %esi,%ecx
   bcebe:	0f 8c 2a 07 00 00    	jl     bd5ee <mj__constraint_solvers__sparse_cholesky__factor+0xb0e>
   bcec4:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
   bcecb:	c4 61 f9 7e c8       	vmovq  %xmm9,%rax
   bced0:	48 01 f0             	add    %rsi,%rax
   bced3:	48 c1 ea 02          	shr    $0x2,%rdx
   bced7:	48 01 d0             	add    %rdx,%rax
   bceda:	41 8b 3c 81          	mov    (%r9,%rax,4),%edi
   bcede:	85 ff                	test   %edi,%edi
   bcee0:	0f 8e f7 06 00 00    	jle    bd5dd <mj__constraint_solvers__sparse_cholesky__factor+0xafd>
   bcee6:	c4 e1 f9 7e d2       	vmovq  %xmm2,%rdx
   bceeb:	c4 61 f9 7e c0       	vmovq  %xmm8,%rax
   bcef0:	48 0f af c2          	imul   %rdx,%rax
   bcef4:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   bcefb:	48 01 f0             	add    %rsi,%rax
   bcefe:	48 8d 44 10 ff       	lea    -0x1(%rax,%rdx,1),%rax
   bcf03:	41 8b 14 81          	mov    (%r9,%rax,4),%edx
   bcf07:	85 d2                	test   %edx,%edx
   bcf09:	0f 8e ce 06 00 00    	jle    bd5dd <mj__constraint_solvers__sparse_cholesky__factor+0xafd>
   bcf0f:	39 f9                	cmp    %edi,%ecx
   bcf11:	0f 8c 2a 07 00 00    	jl     bd641 <mj__constraint_solvers__sparse_cholesky__factor+0xb61>
   bcf17:	39 d1                	cmp    %edx,%ecx
   bcf19:	0f 8c 22 07 00 00    	jl     bd641 <mj__constraint_solvers__sparse_cholesky__factor+0xb61>
   bcf1f:	89 f8                	mov    %edi,%eax
   bcf21:	c4 c1 f9 7e d6       	vmovq  %xmm2,%r14
   bcf26:	4c 8d 40 ff          	lea    -0x1(%rax),%r8
   bcf2a:	4d 0f af c6          	imul   %r14,%r8
   bcf2e:	4c 8b 75 80          	mov    -0x80(%rbp),%r14
   bcf32:	4a 8d 54 32 01       	lea    0x1(%rdx,%r14,1),%rdx
   bcf37:	4e 8d 34 02          	lea    (%rdx,%r8,1),%r14
   bcf3b:	49 8d 54 10 ff       	lea    -0x1(%r8,%rdx,1),%rdx
   bcf40:	41 8b 14 91          	mov    (%r9,%rdx,4),%edx
   bcf44:	c4 c1 f9 6e f6       	vmovq  %r14,%xmm6
   bcf49:	85 d2                	test   %edx,%edx
   bcf4b:	0f 8e df 06 00 00    	jle    bd630 <mj__constraint_solvers__sparse_cholesky__factor+0xb50>
   bcf51:	3b 7d 88             	cmp    -0x78(%rbp),%edi
   bcf54:	0f 8c a1 05 00 00    	jl     bd4fb <mj__constraint_solvers__sparse_cholesky__factor+0xa1b>
   bcf5a:	3b bd 74 ff ff ff    	cmp    -0x8c(%rbp),%edi
   bcf60:	0f 8f 95 05 00 00    	jg     bd4fb <mj__constraint_solvers__sparse_cholesky__factor+0xa1b>
   bcf66:	44 39 d2             	cmp    %r10d,%edx
   bcf69:	0f 8c 8c 05 00 00    	jl     bd4fb <mj__constraint_solvers__sparse_cholesky__factor+0xa1b>
   bcf6f:	39 da                	cmp    %ebx,%edx
   bcf71:	0f 8f 84 05 00 00    	jg     bd4fb <mj__constraint_solvers__sparse_cholesky__factor+0xa1b>
   bcf77:	4c 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%r14
   bcf7e:	48 63 7d 88          	movslq -0x78(%rbp),%rdi
   bcf82:	4c 29 e2             	sub    %r12,%rdx
   bcf85:	49 c1 ee 03          	shr    $0x3,%r14
   bcf89:	48 29 f8             	sub    %rdi,%rax
   bcf8c:	48 8b 7d 80          	mov    -0x80(%rbp),%rdi
   bcf90:	49 0f af c6          	imul   %r14,%rax
   bcf94:	48 01 c2             	add    %rax,%rdx
   bcf97:	c4 c1 7b 10 1c d3    	vmovsd (%r11,%rdx,8),%xmm3
   bcf9d:	49 8d 54 38 01       	lea    0x1(%r8,%rdi,1),%rdx
   bcfa2:	c4 e1 f9 7e f7       	vmovq  %xmm6,%rdi
   bcfa7:	4d 8d 04 91          	lea    (%r9,%rdx,4),%r8
   bcfab:	4d 8d 34 b9          	lea    (%r9,%rdi,4),%r14
   bcfaf:	90                   	nop
   bcfb0:	41 8b 10             	mov    (%r8),%edx
   bcfb3:	85 d2                	test   %edx,%edx
   bcfb5:	0f 8e f2 02 00 00    	jle    bd2ad <mj__constraint_solvers__sparse_cholesky__factor+0x7cd>
   bcfbb:	41 39 d5             	cmp    %edx,%r13d
   bcfbe:	0f 8c e9 02 00 00    	jl     bd2ad <mj__constraint_solvers__sparse_cholesky__factor+0x7cd>
   bcfc4:	44 39 d2             	cmp    %r10d,%edx
   bcfc7:	0f 8c e0 02 00 00    	jl     bd2ad <mj__constraint_solvers__sparse_cholesky__factor+0x7cd>
   bcfcd:	39 da                	cmp    %ebx,%edx
   bcfcf:	0f 8f d8 02 00 00    	jg     bd2ad <mj__constraint_solvers__sparse_cholesky__factor+0x7cd>
   bcfd5:	48 89 d7             	mov    %rdx,%rdi
   bcfd8:	4c 29 e7             	sub    %r12,%rdi
   bcfdb:	48 ff ca             	dec    %rdx
   bcfde:	48 01 c7             	add    %rax,%rdi
   bcfe1:	c4 c1 7b 10 04 d7    	vmovsd (%r15,%rdx,8),%xmm0
   bcfe7:	c4 c1 63 59 0c fb    	vmulsd (%r11,%rdi,8),%xmm3,%xmm1
   bcfed:	c5 fb 5c c1          	vsubsd %xmm1,%xmm0,%xmm0
   bcff1:	c5 f9 2e 05 ef 77 24 	vucomisd 0x2477ef(%rip),%xmm0        # 3047e8 <CSWTCH.1415+0x468>
   bcff8:	00 
   bcff9:	0f 82 51 02 00 00    	jb     bd250 <mj__constraint_solvers__sparse_cholesky__factor+0x770>
   bcfff:	c5 f9 2e e0          	vucomisd %xmm0,%xmm4
   bd003:	0f 82 47 02 00 00    	jb     bd250 <mj__constraint_solvers__sparse_cholesky__factor+0x770>
   bd009:	49 83 c0 04          	add    $0x4,%r8
   bd00d:	c4 c1 7b 11 04 d7    	vmovsd %xmm0,(%r15,%rdx,8)
   bd013:	4d 39 f0             	cmp    %r14,%r8
   bd016:	75 98                	jne    bcfb0 <mj__constraint_solvers__sparse_cholesky__factor+0x4d0>
   bd018:	48 ff c6             	inc    %rsi
   bd01b:	48 39 b5 50 ff ff ff 	cmp    %rsi,-0xb0(%rbp)
   bd022:	0f 85 88 fe ff ff    	jne    bceb0 <mj__constraint_solvers__sparse_cholesky__factor+0x3d0>
   bd028:	4c 89 bd 38 ff ff ff 	mov    %r15,-0xc8(%rbp)
   bd02f:	4d 89 cf             	mov    %r9,%r15
   bd032:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
   bd039:	41 39 c5             	cmp    %eax,%r13d
   bd03c:	0f 8c ce 05 00 00    	jl     bd610 <mj__constraint_solvers__sparse_cholesky__factor+0xb30>
   bd042:	89 45 80             	mov    %eax,-0x80(%rbp)
   bd045:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
   bd04c:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
   bd053:	c5 fb 10 ad 18 ff ff 	vmovsd -0xe8(%rbp),%xmm5
   bd05a:	ff 
   bd05b:	c5 fb 10 5c c1 f8    	vmovsd -0x8(%rcx,%rax,8),%xmm3
   bd061:	c5 d3 5f c3          	vmaxsd %xmm3,%xmm5,%xmm0
   bd065:	c5 fb 11 5d 88       	vmovsd %xmm3,-0x78(%rbp)
   bd06a:	e8 71 2d ff ff       	call   afde0 <mj__quaternion_math__sqrt>
   bd06f:	c5 fb 10 5d 88       	vmovsd -0x78(%rbp),%xmm3
   bd074:	c5 f9 2e 05 8c 74 24 	vucomisd 0x24748c(%rip),%xmm0        # 304508 <CSWTCH.1415+0x188>
   bd07b:	00 
   bd07c:	c5 f9 28 c8          	vmovapd %xmm0,%xmm1
   bd080:	0f 82 b6 01 00 00    	jb     bd23c <mj__constraint_solvers__sparse_cholesky__factor+0x75c>
   bd086:	c5 fb 10 3d 22 77 24 	vmovsd 0x247722(%rip),%xmm7        # 3047b0 <CSWTCH.1415+0x430>
   bd08d:	00 
   bd08e:	c5 fb 10 25 5a 77 24 	vmovsd 0x24775a(%rip),%xmm4        # 3047f0 <CSWTCH.1415+0x470>
   bd095:	00 
   bd096:	8b 7d 80             	mov    -0x80(%rbp),%edi
   bd099:	c5 f9 2e f8          	vucomisd %xmm0,%xmm7
   bd09d:	0f 82 99 01 00 00    	jb     bd23c <mj__constraint_solvers__sparse_cholesky__factor+0x75c>
   bd0a3:	41 8b 07             	mov    (%r15),%eax
   bd0a6:	3b 85 58 ff ff ff    	cmp    -0xa8(%rbp),%eax
   bd0ac:	0f 8c 4d 05 00 00    	jl     bd5ff <mj__constraint_solvers__sparse_cholesky__factor+0xb1f>
   bd0b2:	48 8b 8d 08 ff ff ff 	mov    -0xf8(%rbp),%rcx
   bd0b9:	4c 8b 8d 58 ff ff ff 	mov    -0xa8(%rbp),%r9
   bd0c0:	8b 59 04             	mov    0x4(%rcx),%ebx
   bd0c3:	44 8b 21             	mov    (%rcx),%r12d
   bd0c6:	4c 63 59 08          	movslq 0x8(%rcx),%r11
   bd0ca:	43 8b 34 8f          	mov    (%r15,%r9,4),%esi
   bd0ce:	89 9d 74 ff ff ff    	mov    %ebx,-0x8c(%rbp)
   bd0d4:	44 89 65 88          	mov    %r12d,-0x78(%rbp)
   bd0d8:	8b 59 0c             	mov    0xc(%rcx),%ebx
   bd0db:	4d 89 da             	mov    %r11,%r10
   bd0de:	83 fe 01             	cmp    $0x1,%esi
   bd0e1:	0f 8e f9 01 00 00    	jle    bd2e0 <mj__constraint_solvers__sparse_cholesky__factor+0x800>
   bd0e7:	c5 fb 10 15 a9 73 24 	vmovsd 0x2473a9(%rip),%xmm2        # 304498 <CSWTCH.1415+0x118>
   bd0ee:	00 
   bd0ef:	c5 eb 5e d0          	vdivsd %xmm0,%xmm2,%xmm2
   bd0f3:	45 39 cc             	cmp    %r9d,%r12d
   bd0f6:	0f 8f 9a 04 00 00    	jg     bd596 <mj__constraint_solvers__sparse_cholesky__factor+0xab6>
   bd0fc:	c5 fb 10 b5 18 ff ff 	vmovsd -0xe8(%rbp),%xmm6
   bd103:	ff 
   bd104:	8d 56 ff             	lea    -0x1(%rsi),%edx
   bd107:	48 63 cb             	movslq %ebx,%rcx
   bd10a:	39 d0                	cmp    %edx,%eax
   bd10c:	48 89 8d 78 ff ff ff 	mov    %rcx,-0x88(%rbp)
   bd113:	41 0f 9c c0          	setl   %r8b
   bd117:	4c 29 d9             	sub    %r11,%rcx
   bd11a:	31 d2                	xor    %edx,%edx
   bd11c:	44 39 db             	cmp    %r11d,%ebx
   bd11f:	48 8d 0c cd 08 00 00 	lea    0x8(,%rcx,8),%rcx
   bd126:	00 
   bd127:	48 0f 4d d1          	cmovge %rcx,%rdx
   bd12b:	49 89 d6             	mov    %rdx,%r14
   bd12e:	c5 f9 2f f3          	vcomisd %xmm3,%xmm6
   bd132:	0f 87 c9 02 00 00    	ja     bd401 <mj__constraint_solvers__sparse_cholesky__factor+0x921>
   bd138:	c5 79 6e c6          	vmovd  %esi,%xmm8
   bd13c:	4c 89 c9             	mov    %r9,%rcx
   bd13f:	49 63 f4             	movslq %r12d,%rsi
   bd142:	44 89 6d 80          	mov    %r13d,-0x80(%rbp)
   bd146:	48 29 f1             	sub    %rsi,%rcx
   bd149:	4c 89 f6             	mov    %r14,%rsi
   bd14c:	48 c1 ee 03          	shr    $0x3,%rsi
   bd150:	48 0f af ce          	imul   %rsi,%rcx
   bd154:	4d 8d 61 ff          	lea    -0x1(%r9),%r12
   bd158:	45 89 c5             	mov    %r8d,%r13d
   bd15b:	c5 fa 7e b5 38 ff ff 	vmovq  -0xc8(%rbp),%xmm6
   bd162:	ff 
   bd163:	c5 fa 7e ad 10 ff ff 	vmovq  -0xf0(%rbp),%xmm5
   bd16a:	ff 
   bd16b:	44 8b 85 74 ff ff ff 	mov    -0x8c(%rbp),%r8d
   bd172:	ba 01 00 00 00       	mov    $0x1,%edx
   bd177:	c4 41 f9 7e c1       	vmovq  %xmm8,%r9
   bd17c:	49 89 ce             	mov    %rcx,%r14
   bd17f:	eb 12                	jmp    bd193 <mj__constraint_solvers__sparse_cholesky__factor+0x6b3>
   bd181:	0f 1f 40 00          	nopl   0x0(%rax)
   bd185:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   bd18c:	00 00 00 00 
   bd190:	41 8b 07             	mov    (%r15),%eax
   bd193:	39 f8                	cmp    %edi,%eax
   bd195:	0f 8c b7 04 00 00    	jl     bd652 <mj__constraint_solvers__sparse_cholesky__factor+0xb72>
   bd19b:	39 d0                	cmp    %edx,%eax
   bd19d:	40 0f 9c c6          	setl   %sil
   bd1a1:	44 84 ee             	test   %r13b,%sil
   bd1a4:	0f 85 a8 04 00 00    	jne    bd652 <mj__constraint_solvers__sparse_cholesky__factor+0xb72>
   bd1aa:	4c 89 e6             	mov    %r12,%rsi
   bd1ad:	48 0f af f0          	imul   %rax,%rsi
   bd1b1:	48 01 d6             	add    %rdx,%rsi
   bd1b4:	48 8d 04 46          	lea    (%rsi,%rax,2),%rax
   bd1b8:	41 8b 34 87          	mov    (%r15,%rax,4),%esi
   bd1bc:	85 f6                	test   %esi,%esi
   bd1be:	0f 8e 8c 03 00 00    	jle    bd550 <mj__constraint_solvers__sparse_cholesky__factor+0xa70>
   bd1c4:	39 75 80             	cmp    %esi,-0x80(%rbp)
   bd1c7:	0f 8c 83 03 00 00    	jl     bd550 <mj__constraint_solvers__sparse_cholesky__factor+0xa70>
   bd1cd:	89 f0                	mov    %esi,%eax
   bd1cf:	c4 e1 f9 7e f1       	vmovq  %xmm6,%rcx
   bd1d4:	c5 eb 59 44 c1 f8    	vmulsd -0x8(%rcx,%rax,8),%xmm2,%xmm0
   bd1da:	c5 f9 2e 05 c6 75 24 	vucomisd 0x2475c6(%rip),%xmm0        # 3047a8 <CSWTCH.1415+0x428>
   bd1e1:	00 
   bd1e2:	72 6c                	jb     bd250 <mj__constraint_solvers__sparse_cholesky__factor+0x770>
   bd1e4:	c5 f9 2e f8          	vucomisd %xmm0,%xmm7
   bd1e8:	72 66                	jb     bd250 <mj__constraint_solvers__sparse_cholesky__factor+0x770>
   bd1ea:	41 39 f8             	cmp    %edi,%r8d
   bd1ed:	0f 8c 92 03 00 00    	jl     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd1f3:	41 39 f2             	cmp    %esi,%r10d
   bd1f6:	0f 8f 89 03 00 00    	jg     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd1fc:	39 f3                	cmp    %esi,%ebx
   bd1fe:	0f 8c 81 03 00 00    	jl     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd204:	4c 29 d8             	sub    %r11,%rax
   bd207:	c4 e1 f9 7e e9       	vmovq  %xmm5,%rcx
   bd20c:	48 ff c2             	inc    %rdx
   bd20f:	4c 01 f0             	add    %r14,%rax
   bd212:	c5 fb 11 04 c1       	vmovsd %xmm0,(%rcx,%rax,8)
   bd217:	4c 39 ca             	cmp    %r9,%rdx
   bd21a:	0f 85 70 ff ff ff    	jne    bd190 <mj__constraint_solvers__sparse_cholesky__factor+0x6b0>
   bd220:	44 8b 6d 80          	mov    -0x80(%rbp),%r13d
   bd224:	c5 f9 d6 b5 38 ff ff 	vmovq  %xmm6,-0xc8(%rbp)
   bd22b:	ff 
   bd22c:	31 d2                	xor    %edx,%edx
   bd22e:	44 39 d3             	cmp    %r10d,%ebx
   bd231:	0f 8c bd 00 00 00    	jl     bd2f4 <mj__constraint_solvers__sparse_cholesky__factor+0x814>
   bd237:	e9 86 02 00 00       	jmp    bd4c2 <mj__constraint_solvers__sparse_cholesky__factor+0x9e2>
   bd23c:	c5 fb 10 b5 18 ff ff 	vmovsd -0xe8(%rbp),%xmm6
   bd243:	ff 
   bd244:	c5 f9 2f f3          	vcomisd %xmm3,%xmm6
   bd248:	77 74                	ja     bd2be <mj__constraint_solvers__sparse_cholesky__factor+0x7de>
   bd24a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
   bd250:	b8 02 00 00 00       	mov    $0x2,%eax
   bd255:	66 c7 45 90 00 00    	movw   $0x0,-0x70(%rbp)
   bd25b:	c6 45 92 00          	movb   $0x0,-0x6e(%rbp)
   bd25f:	8b 95 70 ff ff ff    	mov    -0x90(%rbp),%edx
   bd265:	8b 4d 90             	mov    -0x70(%rbp),%ecx
   bd268:	48 c1 e0 20          	shl    $0x20,%rax
   bd26c:	48 c1 e1 28          	shl    $0x28,%rcx
   bd270:	48 09 ca             	or     %rcx,%rdx
   bd273:	48 09 d0             	or     %rdx,%rax
   bd276:	48 8d 65 d0          	lea    -0x30(%rbp),%rsp
   bd27a:	5b                   	pop    %rbx
   bd27b:	41 5a                	pop    %r10
   bd27d:	41 5c                	pop    %r12
   bd27f:	41 5d                	pop    %r13
   bd281:	41 5e                	pop    %r14
   bd283:	41 5f                	pop    %r15
   bd285:	5d                   	pop    %rbp
   bd286:	49 8d 62 f8          	lea    -0x8(%r10),%rsp
   bd28a:	c3                   	ret
   bd28b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   bd290:	48 8b bd 40 ff ff ff 	mov    -0xc0(%rbp),%rdi
   bd297:	c4 61 f9 7e c8       	vmovq  %xmm9,%rax
   bd29c:	48 01 f0             	add    %rsi,%rax
   bd29f:	48 8d 44 38 ff       	lea    -0x1(%rax,%rdi,1),%rax
   bd2a4:	41 8b 3c 81          	mov    (%r9,%rax,4),%edi
   bd2a8:	e9 31 fc ff ff       	jmp    bcede <mj__constraint_solvers__sparse_cholesky__factor+0x3fe>
   bd2ad:	be 7a 00 00 00       	mov    $0x7a,%esi
   bd2b2:	48 8d 3d b7 e5 24 00 	lea    0x24e5b7(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd2b9:	e8 b8 94 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd2be:	ff 8d 70 ff ff ff    	decl   -0x90(%rbp)
   bd2c4:	79 8a                	jns    bd250 <mj__constraint_solvers__sparse_cholesky__factor+0x770>
   bd2c6:	be 7a 01 00 00       	mov    $0x17a,%esi
   bd2cb:	48 8d 3d 9e e5 24 00 	lea    0x24e59e(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd2d2:	e8 39 95 20 00       	call   2c6810 <__gnat_rcheck_CE_Range_Check>
   bd2d7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
   bd2de:	00 00 
   bd2e0:	31 d2                	xor    %edx,%edx
   bd2e2:	44 39 db             	cmp    %r11d,%ebx
   bd2e5:	0f 8d cd 01 00 00    	jge    bd4b8 <mj__constraint_solvers__sparse_cholesky__factor+0x9d8>
   bd2eb:	39 7d 88             	cmp    %edi,-0x78(%rbp)
   bd2ee:	0f 8f 91 02 00 00    	jg     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd2f4:	39 bd 74 ff ff ff    	cmp    %edi,-0x8c(%rbp)
   bd2fa:	0f 8c 85 02 00 00    	jl     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd300:	41 39 fa             	cmp    %edi,%r10d
   bd303:	0f 8f 7c 02 00 00    	jg     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd309:	39 fb                	cmp    %edi,%ebx
   bd30b:	0f 8c 74 02 00 00    	jl     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd311:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
   bd318:	48 63 75 88          	movslq -0x78(%rbp),%rsi
   bd31c:	c5 fb 10 ad 18 ff ff 	vmovsd -0xe8(%rbp),%xmm5
   bd323:	ff 
   bd324:	48 c1 ea 03          	shr    $0x3,%rdx
   bd328:	48 89 c1             	mov    %rax,%rcx
   bd32b:	4c 29 d9             	sub    %r11,%rcx
   bd32e:	48 29 f0             	sub    %rsi,%rax
   bd331:	48 0f af c2          	imul   %rdx,%rax
   bd335:	48 01 c1             	add    %rax,%rcx
   bd338:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
   bd33f:	c5 f9 2f eb          	vcomisd %xmm3,%xmm5
   bd343:	c5 fb 11 0c c8       	vmovsd %xmm1,(%rax,%rcx,8)
   bd348:	76 0c                	jbe    bd356 <mj__constraint_solvers__sparse_cholesky__factor+0x876>
   bd34a:	ff 8d 70 ff ff ff    	decl   -0x90(%rbp)
   bd350:	0f 88 70 ff ff ff    	js     bd2c6 <mj__constraint_solvers__sparse_cholesky__factor+0x7e6>
   bd356:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
   bd35d:	41 8b 14 87          	mov    (%r15,%rax,4),%edx
   bd361:	85 d2                	test   %edx,%edx
   bd363:	0f 88 d6 01 00 00    	js     bd53f <mj__constraint_solvers__sparse_cholesky__factor+0xa5f>
   bd369:	0f 84 7d 00 00 00    	je     bd3ec <mj__constraint_solvers__sparse_cholesky__factor+0x90c>
   bd36f:	41 8b 0f             	mov    (%r15),%ecx
   bd372:	39 cf                	cmp    %ecx,%edi
   bd374:	0f 8f 70 01 00 00    	jg     bd4ea <mj__constraint_solvers__sparse_cholesky__factor+0xa0a>
   bd37a:	48 8b b5 20 ff ff ff 	mov    -0xe0(%rbp),%rsi
   bd381:	89 c8                	mov    %ecx,%eax
   bd383:	4c 8b b5 38 ff ff ff 	mov    -0xc8(%rbp),%r14
   bd38a:	44 8d 42 01          	lea    0x1(%rdx),%r8d
   bd38e:	48 83 ee 02          	sub    $0x2,%rsi
   bd392:	48 0f af f0          	imul   %rax,%rsi
   bd396:	48 8d 44 46 01       	lea    0x1(%rsi,%rax,2),%rax
   bd39b:	be 02 00 00 00       	mov    $0x2,%esi
   bd3a0:	49 8d 3c 87          	lea    (%r15,%rax,4),%rdi
   bd3a4:	eb 1c                	jmp    bd3c2 <mj__constraint_solvers__sparse_cholesky__factor+0x8e2>
   bd3a6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   bd3ad:	00 00 00 
   bd3b0:	89 f0                	mov    %esi,%eax
   bd3b2:	39 f2                	cmp    %esi,%edx
   bd3b4:	0f 4e c2             	cmovle %edx,%eax
   bd3b7:	48 ff c6             	inc    %rsi
   bd3ba:	39 c1                	cmp    %eax,%ecx
   bd3bc:	0f 8c 28 01 00 00    	jl     bd4ea <mj__constraint_solvers__sparse_cholesky__factor+0xa0a>
   bd3c2:	8b 44 b7 f8          	mov    -0x8(%rdi,%rsi,4),%eax
   bd3c6:	85 c0                	test   %eax,%eax
   bd3c8:	0f 8e 1c 01 00 00    	jle    bd4ea <mj__constraint_solvers__sparse_cholesky__factor+0xa0a>
   bd3ce:	41 39 c5             	cmp    %eax,%r13d
   bd3d1:	0f 8c 13 01 00 00    	jl     bd4ea <mj__constraint_solvers__sparse_cholesky__factor+0xa0a>
   bd3d7:	49 c7 44 c6 f8 00 00 	movq   $0x0,-0x8(%r14,%rax,8)
   bd3de:	00 00 
   bd3e0:	4c 39 c6             	cmp    %r8,%rsi
   bd3e3:	75 cb                	jne    bd3b0 <mj__constraint_solvers__sparse_cholesky__factor+0x8d0>
   bd3e5:	4c 89 b5 38 ff ff ff 	mov    %r14,-0xc8(%rbp)
   bd3ec:	48 83 bd 58 ff ff ff 	cmpq   $0x1,-0xa8(%rbp)
   bd3f3:	01 
   bd3f4:	0f 85 03 f8 ff ff    	jne    bcbfd <mj__constraint_solvers__sparse_cholesky__factor+0x11d>
   bd3fa:	31 c0                	xor    %eax,%eax
   bd3fc:	e9 54 fe ff ff       	jmp    bd255 <mj__constraint_solvers__sparse_cholesky__factor+0x775>
   bd401:	4c 89 c9             	mov    %r9,%rcx
   bd404:	39 bd 74 ff ff ff    	cmp    %edi,-0x8c(%rbp)
   bd40a:	0f 8c 51 01 00 00    	jl     bd561 <mj__constraint_solvers__sparse_cholesky__factor+0xa81>
   bd410:	c5 f9 6e c6          	vmovd  %esi,%xmm0
   bd414:	48 63 75 88          	movslq -0x78(%rbp),%rsi
   bd418:	c5 fa 7e ad 38 ff ff 	vmovq  -0xc8(%rbp),%xmm5
   bd41f:	ff 
   bd420:	ba 01 00 00 00       	mov    $0x1,%edx
   bd425:	4d 8d 49 ff          	lea    -0x1(%r9),%r9
   bd429:	48 29 f1             	sub    %rsi,%rcx
   bd42c:	4c 89 f6             	mov    %r14,%rsi
   bd42f:	48 c1 ee 03          	shr    $0x3,%rsi
   bd433:	48 0f af ce          	imul   %rsi,%rcx
   bd437:	4c 8b b5 10 ff ff ff 	mov    -0xf0(%rbp),%r14
   bd43e:	49 89 cc             	mov    %rcx,%r12
   bd441:	c4 e1 f9 7e c1       	vmovq  %xmm0,%rcx
   bd446:	eb 0b                	jmp    bd453 <mj__constraint_solvers__sparse_cholesky__factor+0x973>
   bd448:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
   bd44f:	00 
   bd450:	41 8b 07             	mov    (%r15),%eax
   bd453:	39 c7                	cmp    %eax,%edi
   bd455:	0f 8f f7 01 00 00    	jg     bd652 <mj__constraint_solvers__sparse_cholesky__factor+0xb72>
   bd45b:	39 d0                	cmp    %edx,%eax
   bd45d:	40 0f 9c c6          	setl   %sil
   bd461:	44 84 c6             	test   %r8b,%sil
   bd464:	0f 85 e8 01 00 00    	jne    bd652 <mj__constraint_solvers__sparse_cholesky__factor+0xb72>
   bd46a:	4c 89 ce             	mov    %r9,%rsi
   bd46d:	48 0f af f0          	imul   %rax,%rsi
   bd471:	48 01 d6             	add    %rdx,%rsi
   bd474:	48 8d 04 46          	lea    (%rsi,%rax,2),%rax
   bd478:	41 8b 04 87          	mov    (%r15,%rax,4),%eax
   bd47c:	85 c0                	test   %eax,%eax
   bd47e:	0f 8e 48 01 00 00    	jle    bd5cc <mj__constraint_solvers__sparse_cholesky__factor+0xaec>
   bd484:	41 39 c2             	cmp    %eax,%r10d
   bd487:	0f 8f f8 00 00 00    	jg     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd48d:	39 c3                	cmp    %eax,%ebx
   bd48f:	0f 8c f0 00 00 00    	jl     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd495:	4c 29 d8             	sub    %r11,%rax
   bd498:	48 ff c2             	inc    %rdx
   bd49b:	4c 01 e0             	add    %r12,%rax
   bd49e:	49 c7 04 c6 00 00 00 	movq   $0x0,(%r14,%rax,8)
   bd4a5:	00 
   bd4a6:	48 39 ca             	cmp    %rcx,%rdx
   bd4a9:	75 a5                	jne    bd450 <mj__constraint_solvers__sparse_cholesky__factor+0x970>
   bd4ab:	c5 f9 d6 ad 38 ff ff 	vmovq  %xmm5,-0xc8(%rbp)
   bd4b2:	ff 
   bd4b3:	e9 74 fd ff ff       	jmp    bd22c <mj__constraint_solvers__sparse_cholesky__factor+0x74c>
   bd4b8:	48 63 c3             	movslq %ebx,%rax
   bd4bb:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
   bd4c2:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   bd4c9:	4c 29 d8             	sub    %r11,%rax
   bd4cc:	48 8d 14 c5 08 00 00 	lea    0x8(,%rax,8),%rdx
   bd4d3:	00 
   bd4d4:	e9 12 fe ff ff       	jmp    bd2eb <mj__constraint_solvers__sparse_cholesky__factor+0x80b>
   bd4d9:	be 9b 00 00 00       	mov    $0x9b,%esi
   bd4de:	48 8d 3d 8b e3 24 00 	lea    0x24e38b(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd4e5:	e8 8c 92 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd4ea:	be 50 01 00 00       	mov    $0x150,%esi
   bd4ef:	48 8d 3d 7a e3 24 00 	lea    0x24e37a(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd4f6:	e8 7b 92 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd4fb:	be 72 00 00 00       	mov    $0x72,%esi
   bd500:	48 8d 3d 69 e3 24 00 	lea    0x24e369(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd507:	e8 6a 92 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd50c:	be 9e 00 00 00       	mov    $0x9e,%esi
   bd511:	48 8d 3d 58 e3 24 00 	lea    0x24e358(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd518:	e8 6f 92 20 00       	call   2c678c <__gnat_rcheck_CE_Invalid_Data>
   bd51d:	be 9a 00 00 00       	mov    $0x9a,%esi
   bd522:	48 8d 3d 47 e3 24 00 	lea    0x24e347(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd529:	e8 5e 92 20 00       	call   2c678c <__gnat_rcheck_CE_Invalid_Data>
   bd52e:	be 74 01 00 00       	mov    $0x174,%esi
   bd533:	48 8d 3d 36 e3 24 00 	lea    0x24e336(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd53a:	e8 4d 92 20 00       	call   2c678c <__gnat_rcheck_CE_Invalid_Data>
   bd53f:	be 4f 01 00 00       	mov    $0x14f,%esi
   bd544:	48 8d 3d 25 e3 24 00 	lea    0x24e325(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd54b:	e8 3c 92 20 00       	call   2c678c <__gnat_rcheck_CE_Invalid_Data>
   bd550:	be 0b 01 00 00       	mov    $0x10b,%esi
   bd555:	48 8d 3d 14 e3 24 00 	lea    0x24e314(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd55c:	e8 15 92 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd561:	44 39 c8             	cmp    %r9d,%eax
   bd564:	0f 8c e8 00 00 00    	jl     bd652 <mj__constraint_solvers__sparse_cholesky__factor+0xb72>
   bd56a:	48 8b 8d 28 ff ff ff 	mov    -0xd8(%rbp),%rcx
   bd571:	49 8d 51 ff          	lea    -0x1(%r9),%rdx
   bd575:	48 0f af d0          	imul   %rax,%rdx
   bd579:	48 8d 44 42 01       	lea    0x1(%rdx,%rax,2),%rax
   bd57e:	8b 04 81             	mov    (%rcx,%rax,4),%eax
   bd581:	85 c0                	test   %eax,%eax
   bd583:	7e 47                	jle    bd5cc <mj__constraint_solvers__sparse_cholesky__factor+0xaec>
   bd585:	be b2 00 00 00       	mov    $0xb2,%esi
   bd58a:	48 8d 3d df e2 24 00 	lea    0x24e2df(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd591:	e8 e0 91 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd596:	c5 fb 10 b5 18 ff ff 	vmovsd -0xe8(%rbp),%xmm6
   bd59d:	ff 
   bd59e:	48 8b 8d 28 ff ff ff 	mov    -0xd8(%rbp),%rcx
   bd5a5:	4c 89 ca             	mov    %r9,%rdx
   bd5a8:	48 ff ca             	dec    %rdx
   bd5ab:	48 0f af d0          	imul   %rax,%rdx
   bd5af:	4c 8b b5 38 ff ff ff 	mov    -0xc8(%rbp),%r14
   bd5b6:	48 8d 44 42 01       	lea    0x1(%rdx,%rax,2),%rax
   bd5bb:	8b 04 81             	mov    (%rcx,%rax,4),%eax
   bd5be:	c5 f9 2f f3          	vcomisd %xmm3,%xmm6
   bd5c2:	0f 86 9b 00 00 00    	jbe    bd663 <mj__constraint_solvers__sparse_cholesky__factor+0xb83>
   bd5c8:	85 c0                	test   %eax,%eax
   bd5ca:	7f b9                	jg     bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd5cc:	be 0e 01 00 00       	mov    $0x10e,%esi
   bd5d1:	48 8d 3d 98 e2 24 00 	lea    0x24e298(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd5d8:	e8 33 92 20 00       	call   2c6810 <__gnat_rcheck_CE_Range_Check>
   bd5dd:	be a0 00 00 00       	mov    $0xa0,%esi
   bd5e2:	48 8d 3d 87 e2 24 00 	lea    0x24e287(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd5e9:	e8 22 92 20 00       	call   2c6810 <__gnat_rcheck_CE_Range_Check>
   bd5ee:	be 9f 00 00 00       	mov    $0x9f,%esi
   bd5f3:	48 8d 3d 76 e2 24 00 	lea    0x24e276(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd5fa:	e8 77 91 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd5ff:	be 07 01 00 00       	mov    $0x107,%esi
   bd604:	48 8d 3d 65 e2 24 00 	lea    0x24e265(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd60b:	e8 66 91 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd610:	be 35 01 00 00       	mov    $0x135,%esi
   bd615:	48 8d 3d 54 e2 24 00 	lea    0x24e254(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd61c:	e8 55 91 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd621:	0f 1f 40 00          	nopl   0x0(%rax)
   bd625:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   bd62c:	00 00 00 00 
   bd630:	be 71 00 00 00       	mov    $0x71,%esi
   bd635:	48 8d 3d 34 e2 24 00 	lea    0x24e234(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd63c:	e8 cf 91 20 00       	call   2c6810 <__gnat_rcheck_CE_Range_Check>
   bd641:	be 71 00 00 00       	mov    $0x71,%esi
   bd646:	48 8d 3d 23 e2 24 00 	lea    0x24e223(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd64d:	e8 24 91 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd652:	be 0a 01 00 00       	mov    $0x10a,%esi
   bd657:	48 8d 3d 12 e2 24 00 	lea    0x24e212(%rip),%rdi        # 30b870 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd65e:	e8 13 91 20 00       	call   2c6776 <__gnat_rcheck_CE_Index_Check>
   bd663:	85 c0                	test   %eax,%eax
   bd665:	0f 8e e5 fe ff ff    	jle    bd550 <mj__constraint_solvers__sparse_cholesky__factor+0xa70>
   bd66b:	41 39 c5             	cmp    %eax,%r13d
   bd66e:	0f 8c dc fe ff ff    	jl     bd550 <mj__constraint_solvers__sparse_cholesky__factor+0xa70>
   bd674:	c4 c1 6b 59 54 c6 f8 	vmulsd -0x8(%r14,%rax,8),%xmm2,%xmm2
   bd67b:	c5 f9 2e 15 25 71 24 	vucomisd 0x247125(%rip),%xmm2        # 3047a8 <CSWTCH.1415+0x428>
   bd682:	00 
   bd683:	0f 82 c7 fb ff ff    	jb     bd250 <mj__constraint_solvers__sparse_cholesky__factor+0x770>
   bd689:	c5 f9 2e fa          	vucomisd %xmm2,%xmm7
   bd68d:	0f 83 f2 fe ff ff    	jae    bd585 <mj__constraint_solvers__sparse_cholesky__factor+0xaa5>
   bd693:	e9 b8 fb ff ff       	jmp    bd250 <mj__constraint_solvers__sparse_cholesky__factor+0x770>

Disassembly of section .fini:
