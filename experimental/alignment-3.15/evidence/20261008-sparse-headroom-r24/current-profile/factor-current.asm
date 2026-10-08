
/var/tmp/sparkling-alignment-315-sparse-headroom-release-r24-20261007/force-build/release/bin/flex_constrained_probe:     file format elf64-x86-64


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
   bcafc:	49 89 ce             	mov    %rcx,%r14
   bcaff:	48 81 ec 00 01 00 00 	sub    $0x100,%rsp
   bcb06:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
   bcb0d:	48 63 12             	movslq (%rdx),%rdx
   bcb10:	45 8b 48 0c          	mov    0xc(%r8),%r9d
   bcb14:	45 8b 68 04          	mov    0x4(%r8),%r13d
   bcb18:	45 8b 20             	mov    (%r8),%r12d
   bcb1b:	4c 89 85 28 ff ff ff 	mov    %r8,-0xd8(%rbp)
   bcb22:	45 8b 40 08          	mov    0x8(%r8),%r8d
   bcb26:	c5 fb 11 85 78 ff ff 	vmovsd %xmm0,-0x88(%rbp)
   bcb2d:	ff 
   bcb2e:	48 89 bd 70 ff ff ff 	mov    %rdi,-0x90(%rbp)
   bcb35:	48 89 b5 18 ff ff ff 	mov    %rsi,-0xe8(%rbp)
   bcb3c:	31 f6                	xor    %esi,%esi
   bcb3e:	49 89 d7             	mov    %rdx,%r15
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
   bcb6a:	49 63 f4             	movslq %r12d,%rsi
   bcb6d:	4c 89 f7             	mov    %r14,%rdi
   bcb70:	49 89 c1             	mov    %rax,%r9
   bcb73:	48 29 d0             	sub    %rdx,%rax
   bcb76:	48 8d 04 c5 08 00 00 	lea    0x8(,%rax,8),%rax
   bcb7d:	00 
   bcb7e:	41 39 d1             	cmp    %edx,%r9d
   bcb81:	48 0f 4d c8          	cmovge %rax,%rcx
   bcb85:	49 63 c5             	movslq %r13d,%rax
   bcb88:	31 d2                	xor    %edx,%edx
   bcb8a:	48 ff c0             	inc    %rax
   bcb8d:	48 29 f0             	sub    %rsi,%rax
   bcb90:	48 0f af c1          	imul   %rcx,%rax
   bcb94:	45 39 e5             	cmp    %r12d,%r13d
   bcb97:	48 0f 4d d0          	cmovge %rax,%rdx
   bcb9b:	31 f6                	xor    %esi,%esi
   bcb9d:	e8 3e 89 f4 ff       	call   54e0 <memset@plt>
   bcba2:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   bcba9:	4c 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%r11
   bcbb0:	8b 00                	mov    (%rax),%eax
   bcbb2:	85 c0                	test   %eax,%eax
   bcbb4:	0f 8e 2b 09 00 00    	jle    bd4e5 <mj__constraint_solvers__sparse_cholesky__factor+0xa05>
   bcbba:	48 ff c0             	inc    %rax
   bcbbd:	c5 7b 10 9d 78 ff ff 	vmovsd -0x88(%rbp),%xmm11
   bcbc4:	ff 
   bcbc5:	44 89 bd 68 ff ff ff 	mov    %r15d,-0x98(%rbp)
   bcbcc:	4c 89 9d 10 ff ff ff 	mov    %r11,-0xf0(%rbp)
   bcbd3:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
   bcbda:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
   bcbe1:	4c 89 b5 20 ff ff ff 	mov    %r14,-0xe0(%rbp)
   bcbe8:	49 89 e6             	mov    %rsp,%r14
   bcbeb:	8b 78 04             	mov    0x4(%rax),%edi
   bcbee:	44 8b 60 0c          	mov    0xc(%rax),%r12d
   bcbf2:	44 8b 68 08          	mov    0x8(%rax),%r13d
   bcbf6:	89 bd 78 ff ff ff    	mov    %edi,-0x88(%rbp)
   bcbfc:	8b 38                	mov    (%rax),%edi
   bcbfe:	89 bd 70 ff ff ff    	mov    %edi,-0x90(%rbp)
   bcc04:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
   bcc0b:	31 c9                	xor    %ecx,%ecx
   bcc0d:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
   bcc11:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
   bcc18:	4c 63 50 08          	movslq 0x8(%rax),%r10
   bcc1c:	48 63 40 0c          	movslq 0xc(%rax),%rax
   bcc20:	48 89 c7             	mov    %rax,%rdi
   bcc23:	89 45 80             	mov    %eax,-0x80(%rbp)
   bcc26:	4c 29 d0             	sub    %r10,%rax
   bcc29:	44 89 55 88          	mov    %r10d,-0x78(%rbp)
   bcc2d:	48 8d 04 c5 08 00 00 	lea    0x8(,%rax,8),%rax
   bcc34:	00 
   bcc35:	41 39 fa             	cmp    %edi,%r10d
   bcc38:	48 0f 4e c8          	cmovle %rax,%rcx
   bcc3c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   bcc43:	44 8b 0c 90          	mov    (%rax,%rdx,4),%r9d
   bcc47:	45 85 c9             	test   %r9d,%r9d
   bcc4a:	0f 88 84 08 00 00    	js     bd4d4 <mj__constraint_solvers__sparse_cholesky__factor+0x9f4>
   bcc50:	8b 38                	mov    (%rax),%edi
   bcc52:	0f 84 20 01 00 00    	je     bcd78 <mj__constraint_solvers__sparse_cholesky__factor+0x298>
   bcc58:	39 d7                	cmp    %edx,%edi
   bcc5a:	0f 8c bb 07 00 00    	jl     bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bcc60:	48 8b 9d 30 ff ff ff 	mov    -0xd0(%rbp),%rbx
   bcc67:	89 f8                	mov    %edi,%eax
   bcc69:	48 8d 73 fe          	lea    -0x2(%rbx),%rsi
   bcc6d:	48 8b 9d 60 ff ff ff 	mov    -0xa0(%rbp),%rbx
   bcc74:	48 0f af f0          	imul   %rax,%rsi
   bcc78:	4c 8d 5c 46 01       	lea    0x1(%rsi,%rax,2),%r11
   bcc7d:	42 8b 04 9b          	mov    (%rbx,%r11,4),%eax
   bcc81:	85 c0                	test   %eax,%eax
   bcc83:	0f 8e 92 07 00 00    	jle    bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bcc89:	41 39 c7             	cmp    %eax,%r15d
   bcc8c:	0f 8c 89 07 00 00    	jl     bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bcc92:	4c 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%r8
   bcc99:	49 63 30             	movslq (%r8),%rsi
   bcc9c:	39 d6                	cmp    %edx,%esi
   bcc9e:	0f 8f 77 07 00 00    	jg     bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bcca4:	41 39 50 04          	cmp    %edx,0x4(%r8)
   bcca8:	0f 8c 6d 07 00 00    	jl     bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bccae:	44 8b 45 88          	mov    -0x78(%rbp),%r8d
   bccb2:	41 39 c0             	cmp    %eax,%r8d
   bccb5:	0f 8f 60 07 00 00    	jg     bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bccbb:	c4 e1 f9 6e c6       	vmovq  %rsi,%xmm0
   bccc0:	41 8d 71 01          	lea    0x1(%r9),%esi
   bccc4:	4e 8d 1c 9b          	lea    (%rbx,%r11,4),%r11
   bccc8:	48 89 d3             	mov    %rdx,%rbx
   bcccb:	c4 e1 f9 6e ce       	vmovq  %rsi,%xmm1
   bccd0:	c4 e1 f9 7e c6       	vmovq  %xmm0,%rsi
   bccd5:	44 89 a5 6c ff ff ff 	mov    %r12d,-0x94(%rbp)
   bccdc:	48 89 55 88          	mov    %rdx,-0x78(%rbp)
   bcce0:	48 29 f3             	sub    %rsi,%rbx
   bcce3:	41 89 fc             	mov    %edi,%r12d
   bcce6:	be 02 00 00 00       	mov    $0x2,%esi
   bcceb:	8b 7d 80             	mov    -0x80(%rbp),%edi
   bccee:	44 89 6d 80          	mov    %r13d,-0x80(%rbp)
   bccf2:	45 89 c5             	mov    %r8d,%r13d
   bccf5:	48 c1 e9 03          	shr    $0x3,%rcx
   bccf9:	48 0f af cb          	imul   %rbx,%rcx
   bccfd:	48 8b 9d 10 ff ff ff 	mov    -0xf0(%rbp),%rbx
   bcd04:	49 89 c8             	mov    %rcx,%r8
   bcd07:	c4 e1 f9 7e c9       	vmovq  %xmm1,%rcx
   bcd0c:	eb 36                	jmp    bcd44 <mj__constraint_solvers__sparse_cholesky__factor+0x264>
   bcd0e:	66 90                	xchg   %ax,%ax
   bcd10:	89 f0                	mov    %esi,%eax
   bcd12:	41 39 f1             	cmp    %esi,%r9d
   bcd15:	41 0f 4e c1          	cmovle %r9d,%eax
   bcd19:	41 39 c4             	cmp    %eax,%r12d
   bcd1c:	0f 8c f9 06 00 00    	jl     bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bcd22:	41 8b 44 b3 fc       	mov    -0x4(%r11,%rsi,4),%eax
   bcd27:	85 c0                	test   %eax,%eax
   bcd29:	0f 8e ec 06 00 00    	jle    bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bcd2f:	41 39 c7             	cmp    %eax,%r15d
   bcd32:	0f 8c e3 06 00 00    	jl     bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bcd38:	48 ff c6             	inc    %rsi
   bcd3b:	41 39 c5             	cmp    %eax,%r13d
   bcd3e:	0f 8f d7 06 00 00    	jg     bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bcd44:	39 c7                	cmp    %eax,%edi
   bcd46:	0f 8c cf 06 00 00    	jl     bd41b <mj__constraint_solvers__sparse_cholesky__factor+0x93b>
   bcd4c:	48 89 c2             	mov    %rax,%rdx
   bcd4f:	4c 29 d2             	sub    %r10,%rdx
   bcd52:	4c 01 c2             	add    %r8,%rdx
   bcd55:	c5 fb 10 04 d3       	vmovsd (%rbx,%rdx,8),%xmm0
   bcd5a:	c4 c1 7b 11 44 c6 f8 	vmovsd %xmm0,-0x8(%r14,%rax,8)
   bcd61:	48 39 ce             	cmp    %rcx,%rsi
   bcd64:	75 aa                	jne    bcd10 <mj__constraint_solvers__sparse_cholesky__factor+0x230>
   bcd66:	44 89 e7             	mov    %r12d,%edi
   bcd69:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
   bcd6d:	44 8b a5 6c ff ff ff 	mov    -0x94(%rbp),%r12d
   bcd74:	44 8b 6d 80          	mov    -0x80(%rbp),%r13d
   bcd78:	48 63 c7             	movslq %edi,%rax
   bcd7b:	48 bb ff ff ff ff ff 	movabs $0x3fffffffffffffff,%rbx
   bcd82:	ff ff 3f 
   bcd85:	c4 e1 f9 6e d0       	vmovq  %rax,%xmm2
   bcd8a:	48 ff c0             	inc    %rax
   bcd8d:	48 21 d8             	and    %rbx,%rax
   bcd90:	48 8b 9d 60 ff ff ff 	mov    -0xa0(%rbp),%rbx
   bcd97:	48 8d 44 02 ff       	lea    -0x1(%rdx,%rax,1),%rax
   bcd9c:	8b 04 83             	mov    (%rbx,%rax,4),%eax
   bcd9f:	89 85 6c ff ff ff    	mov    %eax,-0x94(%rbp)
   bcda5:	85 c0                	test   %eax,%eax
   bcda7:	0f 88 a4 07 00 00    	js     bd551 <mj__constraint_solvers__sparse_cholesky__factor+0xa71>
   bcdad:	89 c3                	mov    %eax,%ebx
   bcdaf:	83 f8 01             	cmp    $0x1,%eax
   bcdb2:	0f 8e 2f 02 00 00    	jle    bcfe7 <mj__constraint_solvers__sparse_cholesky__factor+0x507>
   bcdb8:	39 d7                	cmp    %edx,%edi
   bcdba:	0f 8c d1 07 00 00    	jl     bd591 <mj__constraint_solvers__sparse_cholesky__factor+0xab1>
   bcdc0:	c4 e1 f9 7e d0       	vmovq  %xmm2,%rax
   bcdc5:	4d 63 d5             	movslq %r13d,%r10
   bcdc8:	4d 63 cc             	movslq %r12d,%r9
   bcdcb:	31 c9                	xor    %ecx,%ecx
   bcdcd:	4c 8d 1c c5 00 00 00 	lea    0x0(,%rax,8),%r11
   bcdd4:	00 
   bcdd5:	48 0f af c0          	imul   %rax,%rax
   bcdd9:	4d 29 d1             	sub    %r10,%r9
   bcddc:	48 89 95 08 ff ff ff 	mov    %rdx,-0xf8(%rbp)
   bcde3:	4e 8d 0c cd 08 00 00 	lea    0x8(,%r9,8),%r9
   bcdea:	00 
   bcdeb:	89 7d 88             	mov    %edi,-0x78(%rbp)
   bcdee:	48 c1 e0 02          	shl    $0x2,%rax
   bcdf2:	45 39 ec             	cmp    %r13d,%r12d
   bcdf5:	4e 8d 44 18 04       	lea    0x4(%rax,%r11,1),%r8
   bcdfa:	49 0f 4d c9          	cmovge %r9,%rcx
   bcdfe:	ff c3                	inc    %ebx
   bce00:	41 b9 02 00 00 00    	mov    $0x2,%r9d
   bce06:	48 89 9d 48 ff ff ff 	mov    %rbx,-0xb8(%rbp)
   bce0d:	48 8d 5a ff          	lea    -0x1(%rdx),%rbx
   bce11:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
   bce18:	c4 61 f9 6e cb       	vmovq  %rbx,%xmm9
   bce1d:	c4 e1 f9 7e d3       	vmovq  %xmm2,%rbx
   bce22:	c4 61 f9 7e c9       	vmovq  %xmm9,%rcx
   bce27:	48 0f af d9          	imul   %rcx,%rbx
   bce2b:	49 c1 e8 02          	shr    $0x2,%r8
   bce2f:	c4 61 f9 6e e3       	vmovq  %rbx,%xmm12
   bce34:	4a 8d 1c 18          	lea    (%rax,%r11,1),%rbx
   bce38:	49 8d 44 43 04       	lea    0x4(%r11,%rax,2),%rax
   bce3d:	4c 89 85 40 ff ff ff 	mov    %r8,-0xc0(%rbp)
   bce44:	4c 8b 85 20 ff ff ff 	mov    -0xe0(%rbp),%r8
   bce4b:	48 c1 e8 02          	shr    $0x2,%rax
   bce4f:	49 c1 eb 02          	shr    $0x2,%r11
   bce53:	48 c1 eb 02          	shr    $0x2,%rbx
   bce57:	48 89 85 50 ff ff ff 	mov    %rax,-0xb0(%rbp)
   bce5e:	48 63 85 70 ff ff ff 	movslq -0x90(%rbp),%rax
   bce65:	4c 89 5d 80          	mov    %r11,-0x80(%rbp)
   bce69:	48 89 9d 38 ff ff ff 	mov    %rbx,-0xc8(%rbp)
   bce70:	4c 8b 9d 60 ff ff ff 	mov    -0xa0(%rbp),%r11
   bce77:	c4 61 f9 6e d0       	vmovq  %rax,%xmm10
   bce7c:	0f 1f 40 00          	nopl   0x0(%rax)
   bce80:	8b 45 88             	mov    -0x78(%rbp),%eax
   bce83:	3b 85 6c ff ff ff    	cmp    -0x94(%rbp),%eax
   bce89:	0f 8d 41 04 00 00    	jge    bd2d0 <mj__constraint_solvers__sparse_cholesky__factor+0x7f0>
   bce8f:	44 39 c8             	cmp    %r9d,%eax
   bce92:	0f 8c f9 06 00 00    	jl     bd591 <mj__constraint_solvers__sparse_cholesky__factor+0xab1>
   bce98:	c4 61 f9 7e e0       	vmovq  %xmm12,%rax
   bce9d:	4c 01 c8             	add    %r9,%rax
   bcea0:	48 03 85 38 ff ff ff 	add    -0xc8(%rbp),%rax
   bcea7:	41 8b 34 83          	mov    (%r11,%rax,4),%esi
   bceab:	85 f6                	test   %esi,%esi
   bcead:	0f 8e cd 06 00 00    	jle    bd580 <mj__constraint_solvers__sparse_cholesky__factor+0xaa0>
   bceb3:	c4 e1 f9 7e d3       	vmovq  %xmm2,%rbx
   bceb8:	c4 61 f9 7e c8       	vmovq  %xmm9,%rax
   bcebd:	48 0f af c3          	imul   %rbx,%rax
   bcec1:	48 8b 9d 50 ff ff ff 	mov    -0xb0(%rbp),%rbx
   bcec8:	4c 01 c8             	add    %r9,%rax
   bcecb:	48 8d 44 18 ff       	lea    -0x1(%rax,%rbx,1),%rax
   bced0:	41 8b 14 83          	mov    (%r11,%rax,4),%edx
   bced4:	85 d2                	test   %edx,%edx
   bced6:	0f 8e a4 06 00 00    	jle    bd580 <mj__constraint_solvers__sparse_cholesky__factor+0xaa0>
   bcedc:	39 75 88             	cmp    %esi,-0x78(%rbp)
   bcedf:	0f 8c 2c 06 00 00    	jl     bd511 <mj__constraint_solvers__sparse_cholesky__factor+0xa31>
   bcee5:	39 55 88             	cmp    %edx,-0x78(%rbp)
   bcee8:	0f 8c 23 06 00 00    	jl     bd511 <mj__constraint_solvers__sparse_cholesky__factor+0xa31>
   bceee:	89 f0                	mov    %esi,%eax
   bcef0:	c4 e1 f9 7e d7       	vmovq  %xmm2,%rdi
   bcef5:	48 8d 58 ff          	lea    -0x1(%rax),%rbx
   bcef9:	48 0f af df          	imul   %rdi,%rbx
   bcefd:	48 8b 7d 80          	mov    -0x80(%rbp),%rdi
   bcf01:	48 8d 54 3a 01       	lea    0x1(%rdx,%rdi,1),%rdx
   bcf06:	48 8d 0c 1a          	lea    (%rdx,%rbx,1),%rcx
   bcf0a:	48 8d 54 13 ff       	lea    -0x1(%rbx,%rdx,1),%rdx
   bcf0f:	41 8b 14 93          	mov    (%r11,%rdx,4),%edx
   bcf13:	85 d2                	test   %edx,%edx
   bcf15:	0f 8e e5 05 00 00    	jle    bd500 <mj__constraint_solvers__sparse_cholesky__factor+0xa20>
   bcf1b:	3b b5 70 ff ff ff    	cmp    -0x90(%rbp),%esi
   bcf21:	0f 8c 19 06 00 00    	jl     bd540 <mj__constraint_solvers__sparse_cholesky__factor+0xa60>
   bcf27:	3b b5 78 ff ff ff    	cmp    -0x88(%rbp),%esi
   bcf2d:	0f 8f 0d 06 00 00    	jg     bd540 <mj__constraint_solvers__sparse_cholesky__factor+0xa60>
   bcf33:	44 39 ea             	cmp    %r13d,%edx
   bcf36:	0f 8c 04 06 00 00    	jl     bd540 <mj__constraint_solvers__sparse_cholesky__factor+0xa60>
   bcf3c:	44 39 e2             	cmp    %r12d,%edx
   bcf3f:	0f 8f fb 05 00 00    	jg     bd540 <mj__constraint_solvers__sparse_cholesky__factor+0xa60>
   bcf45:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
   bcf4c:	c4 61 f9 7e d7       	vmovq  %xmm10,%rdi
   bcf51:	4c 29 d2             	sub    %r10,%rdx
   bcf54:	48 29 f8             	sub    %rdi,%rax
   bcf57:	48 c1 ee 03          	shr    $0x3,%rsi
   bcf5b:	48 0f af c6          	imul   %rsi,%rax
   bcf5f:	49 8d 34 8b          	lea    (%r11,%rcx,4),%rsi
   bcf63:	48 01 c2             	add    %rax,%rdx
   bcf66:	48 89 c7             	mov    %rax,%rdi
   bcf69:	48 8b 45 80          	mov    -0x80(%rbp),%rax
   bcf6d:	c4 c1 7b 10 24 d0    	vmovsd (%r8,%rdx,8),%xmm4
   bcf73:	48 8d 44 03 01       	lea    0x1(%rbx,%rax,1),%rax
   bcf78:	49 8d 14 83          	lea    (%r11,%rax,4),%rdx
   bcf7c:	0f 1f 40 00          	nopl   0x0(%rax)
   bcf80:	8b 02                	mov    (%rdx),%eax
   bcf82:	85 c0                	test   %eax,%eax
   bcf84:	0f 8e 63 03 00 00    	jle    bd2ed <mj__constraint_solvers__sparse_cholesky__factor+0x80d>
   bcf8a:	41 39 c7             	cmp    %eax,%r15d
   bcf8d:	0f 8c 5a 03 00 00    	jl     bd2ed <mj__constraint_solvers__sparse_cholesky__factor+0x80d>
   bcf93:	44 39 e8             	cmp    %r13d,%eax
   bcf96:	0f 8c 51 03 00 00    	jl     bd2ed <mj__constraint_solvers__sparse_cholesky__factor+0x80d>
   bcf9c:	44 39 e0             	cmp    %r12d,%eax
   bcf9f:	0f 8f 48 03 00 00    	jg     bd2ed <mj__constraint_solvers__sparse_cholesky__factor+0x80d>
   bcfa5:	48 89 c1             	mov    %rax,%rcx
   bcfa8:	4c 29 d1             	sub    %r10,%rcx
   bcfab:	48 ff c8             	dec    %rax
   bcfae:	48 83 c2 04          	add    $0x4,%rdx
   bcfb2:	48 01 f9             	add    %rdi,%rcx
   bcfb5:	c4 c1 7b 10 04 c6    	vmovsd (%r14,%rax,8),%xmm0
   bcfbb:	c4 c1 5b 59 0c c8    	vmulsd (%r8,%rcx,8),%xmm4,%xmm1
   bcfc1:	c5 fb 5c c1          	vsubsd %xmm1,%xmm0,%xmm0
   bcfc5:	c4 c1 7b 11 04 c6    	vmovsd %xmm0,(%r14,%rax,8)
   bcfcb:	48 39 d6             	cmp    %rdx,%rsi
   bcfce:	75 b0                	jne    bcf80 <mj__constraint_solvers__sparse_cholesky__factor+0x4a0>
   bcfd0:	49 ff c1             	inc    %r9
   bcfd3:	4c 39 8d 48 ff ff ff 	cmp    %r9,-0xb8(%rbp)
   bcfda:	0f 85 a0 fe ff ff    	jne    bce80 <mj__constraint_solvers__sparse_cholesky__factor+0x3a0>
   bcfe0:	48 8b 95 08 ff ff ff 	mov    -0xf8(%rbp),%rdx
   bcfe7:	41 39 d7             	cmp    %edx,%r15d
   bcfea:	0f 8c 32 05 00 00    	jl     bd522 <mj__constraint_solvers__sparse_cholesky__factor+0xa42>
   bcff0:	c4 c1 7b 10 6c d6 f8 	vmovsd -0x8(%r14,%rdx,8),%xmm5
   bcff7:	c5 7b 11 5d 88       	vmovsd %xmm11,-0x78(%rbp)
   bcffc:	48 89 95 78 ff ff ff 	mov    %rdx,-0x88(%rbp)
   bd003:	c5 a3 5f c5          	vmaxsd %xmm5,%xmm11,%xmm0
   bd007:	c5 fb 11 6d 80       	vmovsd %xmm5,-0x80(%rbp)
   bd00c:	e8 cf 2d ff ff       	call   afde0 <mj__quaternion_math__sqrt>
   bd011:	c5 7b 10 5d 88       	vmovsd -0x78(%rbp),%xmm11
   bd016:	c5 fb 10 6d 80       	vmovsd -0x80(%rbp),%xmm5
   bd01b:	c5 f9 2e 05 65 74 24 	vucomisd 0x247465(%rip),%xmm0        # 304488 <CSWTCH.1415+0x188>
   bd022:	00 
   bd023:	c5 f9 28 d8          	vmovapd %xmm0,%xmm3
   bd027:	0f 82 d1 02 00 00    	jb     bd2fe <mj__constraint_solvers__sparse_cholesky__factor+0x81e>
   bd02d:	c5 fb 10 25 fb 76 24 	vmovsd 0x2476fb(%rip),%xmm4        # 304730 <CSWTCH.1415+0x430>
   bd034:	00 
   bd035:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
   bd03c:	c5 f9 2e e0          	vucomisd %xmm0,%xmm4
   bd040:	0f 82 b8 02 00 00    	jb     bd2fe <mj__constraint_solvers__sparse_cholesky__factor+0x81e>
   bd046:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   bd04d:	8b 00                	mov    (%rax),%eax
   bd04f:	39 d0                	cmp    %edx,%eax
   bd051:	0f 8c 0b 05 00 00    	jl     bd562 <mj__constraint_solvers__sparse_cholesky__factor+0xa82>
   bd057:	48 8b 9d 28 ff ff ff 	mov    -0xd8(%rbp),%rbx
   bd05e:	8b 7b 04             	mov    0x4(%rbx),%edi
   bd061:	8b 33                	mov    (%rbx),%esi
   bd063:	4c 63 5b 08          	movslq 0x8(%rbx),%r11
   bd067:	44 8b 63 0c          	mov    0xc(%rbx),%r12d
   bd06b:	48 8b 9d 60 ff ff ff 	mov    -0xa0(%rbp),%rbx
   bd072:	89 bd 78 ff ff ff    	mov    %edi,-0x88(%rbp)
   bd078:	89 b5 70 ff ff ff    	mov    %esi,-0x90(%rbp)
   bd07e:	4d 89 dd             	mov    %r11,%r13
   bd081:	8b 3c 93             	mov    (%rbx,%rdx,4),%edi
   bd084:	83 ff 01             	cmp    $0x1,%edi
   bd087:	0f 8e 77 03 00 00    	jle    bd404 <mj__constraint_solvers__sparse_cholesky__factor+0x924>
   bd08d:	c5 fb 10 15 83 73 24 	vmovsd 0x247383(%rip),%xmm2        # 304418 <CSWTCH.1415+0x118>
   bd094:	00 
   bd095:	89 f3                	mov    %esi,%ebx
   bd097:	c5 eb 5e d0          	vdivsd %xmm0,%xmm2,%xmm2
   bd09b:	39 d6                	cmp    %edx,%esi
   bd09d:	0f 8f bc 03 00 00    	jg     bd45f <mj__constraint_solvers__sparse_cholesky__factor+0x97f>
   bd0a3:	8d 77 ff             	lea    -0x1(%rdi),%esi
   bd0a6:	39 f0                	cmp    %esi,%eax
   bd0a8:	49 63 f4             	movslq %r12d,%rsi
   bd0ab:	41 0f 9c c1          	setl   %r9b
   bd0af:	48 89 75 80          	mov    %rsi,-0x80(%rbp)
   bd0b3:	4c 29 de             	sub    %r11,%rsi
   bd0b6:	4c 8d 14 f5 08 00 00 	lea    0x8(,%rsi,8),%r10
   bd0bd:	00 
   bd0be:	31 f6                	xor    %esi,%esi
   bd0c0:	45 39 dc             	cmp    %r11d,%r12d
   bd0c3:	4c 0f 4c d6          	cmovl  %rsi,%r10
   bd0c7:	c5 79 2f dd          	vcomisd %xmm5,%xmm11
   bd0cb:	0f 87 7a 02 00 00    	ja     bd34b <mj__constraint_solvers__sparse_cholesky__factor+0x86b>
   bd0d1:	48 8d 4a ff          	lea    -0x1(%rdx),%rcx
   bd0d5:	89 fe                	mov    %edi,%esi
   bd0d7:	c4 e1 f9 6e c9       	vmovq  %rcx,%xmm1
   bd0dc:	48 63 cb             	movslq %ebx,%rcx
   bd0df:	48 89 75 88          	mov    %rsi,-0x78(%rbp)
   bd0e3:	48 8b 9d 20 ff ff ff 	mov    -0xe0(%rbp),%rbx
   bd0ea:	48 89 d7             	mov    %rdx,%rdi
   bd0ed:	48 29 cf             	sub    %rcx,%rdi
   bd0f0:	be 01 00 00 00       	mov    $0x1,%esi
   bd0f5:	49 c1 ea 03          	shr    $0x3,%r10
   bd0f9:	48 89 f9             	mov    %rdi,%rcx
   bd0fc:	48 8b bd 60 ff ff ff 	mov    -0xa0(%rbp),%rdi
   bd103:	49 0f af ca          	imul   %r10,%rcx
   bd107:	45 89 fa             	mov    %r15d,%r10d
   bd10a:	c4 c1 f9 7e cf       	vmovq  %xmm1,%r15
   bd10f:	49 89 c8             	mov    %rcx,%r8
   bd112:	eb 0e                	jmp    bd122 <mj__constraint_solvers__sparse_cholesky__factor+0x642>
   bd114:	90                   	nop
   bd115:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   bd11c:	00 00 00 00 
   bd120:	8b 07                	mov    (%rdi),%eax
   bd122:	39 d0                	cmp    %edx,%eax
   bd124:	0f 8c 99 03 00 00    	jl     bd4c3 <mj__constraint_solvers__sparse_cholesky__factor+0x9e3>
   bd12a:	39 f0                	cmp    %esi,%eax
   bd12c:	0f 9c c1             	setl   %cl
   bd12f:	44 84 c9             	test   %r9b,%cl
   bd132:	0f 85 8b 03 00 00    	jne    bd4c3 <mj__constraint_solvers__sparse_cholesky__factor+0x9e3>
   bd138:	4c 89 f9             	mov    %r15,%rcx
   bd13b:	48 0f af c8          	imul   %rax,%rcx
   bd13f:	48 01 f1             	add    %rsi,%rcx
   bd142:	48 8d 04 41          	lea    (%rcx,%rax,2),%rax
   bd146:	8b 0c 87             	mov    (%rdi,%rax,4),%ecx
   bd149:	85 c9                	test   %ecx,%ecx
   bd14b:	0f 8e fd 02 00 00    	jle    bd44e <mj__constraint_solvers__sparse_cholesky__factor+0x96e>
   bd151:	41 39 ca             	cmp    %ecx,%r10d
   bd154:	0f 8c f4 02 00 00    	jl     bd44e <mj__constraint_solvers__sparse_cholesky__factor+0x96e>
   bd15a:	89 c8                	mov    %ecx,%eax
   bd15c:	c4 c1 6b 59 44 c6 f8 	vmulsd -0x8(%r14,%rax,8),%xmm2,%xmm0
   bd163:	c5 f9 2e 05 bd 75 24 	vucomisd 0x2475bd(%rip),%xmm0        # 304728 <CSWTCH.1415+0x428>
   bd16a:	00 
   bd16b:	0f 82 9f 01 00 00    	jb     bd310 <mj__constraint_solvers__sparse_cholesky__factor+0x830>
   bd171:	c5 f9 2e e0          	vucomisd %xmm0,%xmm4
   bd175:	0f 82 95 01 00 00    	jb     bd310 <mj__constraint_solvers__sparse_cholesky__factor+0x830>
   bd17b:	39 95 78 ff ff ff    	cmp    %edx,-0x88(%rbp)
   bd181:	0f 8c fc 02 00 00    	jl     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd187:	41 39 cd             	cmp    %ecx,%r13d
   bd18a:	0f 8f f3 02 00 00    	jg     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd190:	41 39 cc             	cmp    %ecx,%r12d
   bd193:	0f 8c ea 02 00 00    	jl     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd199:	4c 29 d8             	sub    %r11,%rax
   bd19c:	48 ff c6             	inc    %rsi
   bd19f:	4c 01 c0             	add    %r8,%rax
   bd1a2:	c5 fb 11 04 c3       	vmovsd %xmm0,(%rbx,%rax,8)
   bd1a7:	48 39 75 88          	cmp    %rsi,-0x78(%rbp)
   bd1ab:	0f 85 6f ff ff ff    	jne    bd120 <mj__constraint_solvers__sparse_cholesky__factor+0x640>
   bd1b1:	45 89 d7             	mov    %r10d,%r15d
   bd1b4:	31 c0                	xor    %eax,%eax
   bd1b6:	45 39 ec             	cmp    %r13d,%r12d
   bd1b9:	7c 1b                	jl     bd1d6 <mj__constraint_solvers__sparse_cholesky__factor+0x6f6>
   bd1bb:	48 8b 45 80          	mov    -0x80(%rbp),%rax
   bd1bf:	4c 29 d8             	sub    %r11,%rax
   bd1c2:	48 8d 04 c5 08 00 00 	lea    0x8(,%rax,8),%rax
   bd1c9:	00 
   bd1ca:	39 95 70 ff ff ff    	cmp    %edx,-0x90(%rbp)
   bd1d0:	0f 8f ad 02 00 00    	jg     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd1d6:	39 95 78 ff ff ff    	cmp    %edx,-0x88(%rbp)
   bd1dc:	0f 8c a1 02 00 00    	jl     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd1e2:	41 39 d5             	cmp    %edx,%r13d
   bd1e5:	0f 8f 98 02 00 00    	jg     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd1eb:	41 39 d4             	cmp    %edx,%r12d
   bd1ee:	0f 8c 8f 02 00 00    	jl     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd1f4:	4c 63 8d 70 ff ff ff 	movslq -0x90(%rbp),%r9
   bd1fb:	48 89 d6             	mov    %rdx,%rsi
   bd1fe:	4c 29 de             	sub    %r11,%rsi
   bd201:	48 c1 e8 03          	shr    $0x3,%rax
   bd205:	48 89 d7             	mov    %rdx,%rdi
   bd208:	4c 29 cf             	sub    %r9,%rdi
   bd20b:	48 0f af c7          	imul   %rdi,%rax
   bd20f:	48 01 c6             	add    %rax,%rsi
   bd212:	48 8b 85 20 ff ff ff 	mov    -0xe0(%rbp),%rax
   bd219:	c5 79 2f dd          	vcomisd %xmm5,%xmm11
   bd21d:	c5 fb 11 1c f0       	vmovsd %xmm3,(%rax,%rsi,8)
   bd222:	76 0c                	jbe    bd230 <mj__constraint_solvers__sparse_cholesky__factor+0x750>
   bd224:	ff 8d 68 ff ff ff    	decl   -0x98(%rbp)
   bd22a:	0f 88 72 03 00 00    	js     bd5a2 <mj__constraint_solvers__sparse_cholesky__factor+0xac2>
   bd230:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   bd237:	8b 34 90             	mov    (%rax,%rdx,4),%esi
   bd23a:	85 f6                	test   %esi,%esi
   bd23c:	0f 88 fb 01 00 00    	js     bd43d <mj__constraint_solvers__sparse_cholesky__factor+0x95d>
   bd242:	74 74                	je     bd2b8 <mj__constraint_solvers__sparse_cholesky__factor+0x7d8>
   bd244:	8b 38                	mov    (%rax),%edi
   bd246:	48 89 c3             	mov    %rax,%rbx
   bd249:	39 fa                	cmp    %edi,%edx
   bd24b:	0f 8f db 01 00 00    	jg     bd42c <mj__constraint_solvers__sparse_cholesky__factor+0x94c>
   bd251:	4c 8b 8d 30 ff ff ff 	mov    -0xd0(%rbp),%r9
   bd258:	89 f8                	mov    %edi,%eax
   bd25a:	44 8d 5e 01          	lea    0x1(%rsi),%r11d
   bd25e:	49 83 e9 02          	sub    $0x2,%r9
   bd262:	4c 0f af c8          	imul   %rax,%r9
   bd266:	49 8d 44 41 01       	lea    0x1(%r9,%rax,2),%rax
   bd26b:	41 b9 02 00 00 00    	mov    $0x2,%r9d
   bd271:	4c 8d 14 83          	lea    (%rbx,%rax,4),%r10
   bd275:	eb 1d                	jmp    bd294 <mj__constraint_solvers__sparse_cholesky__factor+0x7b4>
   bd277:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
   bd27e:	00 00 
   bd280:	44 89 c8             	mov    %r9d,%eax
   bd283:	44 39 ce             	cmp    %r9d,%esi
   bd286:	0f 4e c6             	cmovle %esi,%eax
   bd289:	49 ff c1             	inc    %r9
   bd28c:	39 c7                	cmp    %eax,%edi
   bd28e:	0f 8c 98 01 00 00    	jl     bd42c <mj__constraint_solvers__sparse_cholesky__factor+0x94c>
   bd294:	43 8b 44 8a f8       	mov    -0x8(%r10,%r9,4),%eax
   bd299:	85 c0                	test   %eax,%eax
   bd29b:	0f 8e 8b 01 00 00    	jle    bd42c <mj__constraint_solvers__sparse_cholesky__factor+0x94c>
   bd2a1:	41 39 c7             	cmp    %eax,%r15d
   bd2a4:	0f 8c 82 01 00 00    	jl     bd42c <mj__constraint_solvers__sparse_cholesky__factor+0x94c>
   bd2aa:	49 c7 44 c6 f8 00 00 	movq   $0x0,-0x8(%r14,%rax,8)
   bd2b1:	00 00 
   bd2b3:	4d 39 d9             	cmp    %r11,%r9
   bd2b6:	75 c8                	jne    bd280 <mj__constraint_solvers__sparse_cholesky__factor+0x7a0>
   bd2b8:	48 83 fa 01          	cmp    $0x1,%rdx
   bd2bc:	0f 84 fe 02 00 00    	je     bd5c0 <mj__constraint_solvers__sparse_cholesky__factor+0xae0>
   bd2c2:	48 89 95 30 ff ff ff 	mov    %rdx,-0xd0(%rbp)
   bd2c9:	e9 36 f9 ff ff       	jmp    bcc04 <mj__constraint_solvers__sparse_cholesky__factor+0x124>
   bd2ce:	66 90                	xchg   %ax,%ax
   bd2d0:	48 8b 9d 40 ff ff ff 	mov    -0xc0(%rbp),%rbx
   bd2d7:	c4 61 f9 7e e0       	vmovq  %xmm12,%rax
   bd2dc:	4c 01 c8             	add    %r9,%rax
   bd2df:	48 8d 44 18 ff       	lea    -0x1(%rax,%rbx,1),%rax
   bd2e4:	41 8b 34 83          	mov    (%r11,%rax,4),%esi
   bd2e8:	e9 be fb ff ff       	jmp    bceab <mj__constraint_solvers__sparse_cholesky__factor+0x3cb>
   bd2ed:	be af 00 00 00       	mov    $0xaf,%esi
   bd2f2:	48 8d 3d f7 e4 24 00 	lea    0x24e4f7(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd2f9:	e8 f8 93 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd2fe:	c5 79 2f dd          	vcomisd %xmm5,%xmm11
   bd302:	76 0c                	jbe    bd310 <mj__constraint_solvers__sparse_cholesky__factor+0x830>
   bd304:	ff 8d 68 ff ff ff    	decl   -0x98(%rbp)
   bd30a:	0f 88 92 02 00 00    	js     bd5a2 <mj__constraint_solvers__sparse_cholesky__factor+0xac2>
   bd310:	ba 02 00 00 00       	mov    $0x2,%edx
   bd315:	66 c7 45 90 00 00    	movw   $0x0,-0x70(%rbp)
   bd31b:	c6 45 92 00          	movb   $0x0,-0x6e(%rbp)
   bd31f:	8b 85 68 ff ff ff    	mov    -0x98(%rbp),%eax
   bd325:	8b 4d 90             	mov    -0x70(%rbp),%ecx
   bd328:	48 c1 e2 20          	shl    $0x20,%rdx
   bd32c:	48 c1 e1 28          	shl    $0x28,%rcx
   bd330:	48 09 c8             	or     %rcx,%rax
   bd333:	48 09 d0             	or     %rdx,%rax
   bd336:	48 8d 65 d0          	lea    -0x30(%rbp),%rsp
   bd33a:	5b                   	pop    %rbx
   bd33b:	41 5a                	pop    %r10
   bd33d:	41 5c                	pop    %r12
   bd33f:	41 5d                	pop    %r13
   bd341:	41 5e                	pop    %r14
   bd343:	41 5f                	pop    %r15
   bd345:	5d                   	pop    %rbp
   bd346:	49 8d 62 f8          	lea    -0x8(%r10),%rsp
   bd34a:	c3                   	ret
   bd34b:	39 95 78 ff ff ff    	cmp    %edx,-0x88(%rbp)
   bd351:	0f 8c 3d 01 00 00    	jl     bd494 <mj__constraint_solvers__sparse_cholesky__factor+0x9b4>
   bd357:	48 63 8d 70 ff ff ff 	movslq -0x90(%rbp),%rcx
   bd35e:	48 8d 5a ff          	lea    -0x1(%rdx),%rbx
   bd362:	44 89 7d 88          	mov    %r15d,-0x78(%rbp)
   bd366:	be 01 00 00 00       	mov    $0x1,%esi
   bd36b:	c4 e1 f9 6e c3       	vmovq  %rbx,%xmm0
   bd370:	49 c1 ea 03          	shr    $0x3,%r10
   bd374:	c4 c1 f9 7e c7       	vmovq  %xmm0,%r15
   bd379:	48 89 d3             	mov    %rdx,%rbx
   bd37c:	48 29 cb             	sub    %rcx,%rbx
   bd37f:	49 0f af da          	imul   %r10,%rbx
   bd383:	4c 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%r10
   bd38a:	49 89 d8             	mov    %rbx,%r8
   bd38d:	48 8b 9d 20 ff ff ff 	mov    -0xe0(%rbp),%rbx
   bd394:	eb 0d                	jmp    bd3a3 <mj__constraint_solvers__sparse_cholesky__factor+0x8c3>
   bd396:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   bd39d:	00 00 00 
   bd3a0:	41 8b 02             	mov    (%r10),%eax
   bd3a3:	39 c2                	cmp    %eax,%edx
   bd3a5:	0f 8f 18 01 00 00    	jg     bd4c3 <mj__constraint_solvers__sparse_cholesky__factor+0x9e3>
   bd3ab:	39 f0                	cmp    %esi,%eax
   bd3ad:	0f 9c c1             	setl   %cl
   bd3b0:	44 84 c9             	test   %r9b,%cl
   bd3b3:	0f 85 0a 01 00 00    	jne    bd4c3 <mj__constraint_solvers__sparse_cholesky__factor+0x9e3>
   bd3b9:	4c 89 f9             	mov    %r15,%rcx
   bd3bc:	48 0f af c8          	imul   %rax,%rcx
   bd3c0:	48 01 f1             	add    %rsi,%rcx
   bd3c3:	48 8d 04 41          	lea    (%rcx,%rax,2),%rax
   bd3c7:	41 8b 04 82          	mov    (%r10,%rax,4),%eax
   bd3cb:	85 c0                	test   %eax,%eax
   bd3cd:	0f 8e df 00 00 00    	jle    bd4b2 <mj__constraint_solvers__sparse_cholesky__factor+0x9d2>
   bd3d3:	41 39 c5             	cmp    %eax,%r13d
   bd3d6:	0f 8f a7 00 00 00    	jg     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd3dc:	41 39 c4             	cmp    %eax,%r12d
   bd3df:	0f 8c 9e 00 00 00    	jl     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd3e5:	4c 29 d8             	sub    %r11,%rax
   bd3e8:	48 ff c6             	inc    %rsi
   bd3eb:	4c 01 c0             	add    %r8,%rax
   bd3ee:	48 c7 04 c3 00 00 00 	movq   $0x0,(%rbx,%rax,8)
   bd3f5:	00 
   bd3f6:	48 39 fe             	cmp    %rdi,%rsi
   bd3f9:	75 a5                	jne    bd3a0 <mj__constraint_solvers__sparse_cholesky__factor+0x8c0>
   bd3fb:	44 8b 7d 88          	mov    -0x78(%rbp),%r15d
   bd3ff:	e9 b0 fd ff ff       	jmp    bd1b4 <mj__constraint_solvers__sparse_cholesky__factor+0x6d4>
   bd404:	31 c0                	xor    %eax,%eax
   bd406:	45 39 dc             	cmp    %r11d,%r12d
   bd409:	0f 8c bb fd ff ff    	jl     bd1ca <mj__constraint_solvers__sparse_cholesky__factor+0x6ea>
   bd40f:	49 63 c4             	movslq %r12d,%rax
   bd412:	48 89 45 80          	mov    %rax,-0x80(%rbp)
   bd416:	e9 a0 fd ff ff       	jmp    bd1bb <mj__constraint_solvers__sparse_cholesky__factor+0x6db>
   bd41b:	be d7 00 00 00       	mov    $0xd7,%esi
   bd420:	48 8d 3d c9 e3 24 00 	lea    0x24e3c9(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd427:	e8 ca 92 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd42c:	be 97 01 00 00       	mov    $0x197,%esi
   bd431:	48 8d 3d b8 e3 24 00 	lea    0x24e3b8(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd438:	e8 b9 92 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd43d:	be 96 01 00 00       	mov    $0x196,%esi
   bd442:	48 8d 3d a7 e3 24 00 	lea    0x24e3a7(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd449:	e8 be 92 20 00       	call   2c670c <__gnat_rcheck_CE_Invalid_Data>
   bd44e:	be 4d 01 00 00       	mov    $0x14d,%esi
   bd453:	48 8d 3d 96 e3 24 00 	lea    0x24e396(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd45a:	e8 97 92 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd45f:	48 ff ca             	dec    %rdx
   bd462:	48 8b bd 60 ff ff ff 	mov    -0xa0(%rbp),%rdi
   bd469:	48 0f af d0          	imul   %rax,%rdx
   bd46d:	c5 79 2f dd          	vcomisd %xmm5,%xmm11
   bd471:	48 8d 44 42 01       	lea    0x1(%rdx,%rax,2),%rax
   bd476:	8b 04 87             	mov    (%rdi,%rax,4),%eax
   bd479:	0f 86 48 01 00 00    	jbe    bd5c7 <mj__constraint_solvers__sparse_cholesky__factor+0xae7>
   bd47f:	85 c0                	test   %eax,%eax
   bd481:	7e 2f                	jle    bd4b2 <mj__constraint_solvers__sparse_cholesky__factor+0x9d2>
   bd483:	be f4 00 00 00       	mov    $0xf4,%esi
   bd488:	48 8d 3d 61 e3 24 00 	lea    0x24e361(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd48f:	e8 62 92 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd494:	39 d0                	cmp    %edx,%eax
   bd496:	7c 2b                	jl     bd4c3 <mj__constraint_solvers__sparse_cholesky__factor+0x9e3>
   bd498:	48 8b 9d 60 ff ff ff 	mov    -0xa0(%rbp),%rbx
   bd49f:	48 ff ca             	dec    %rdx
   bd4a2:	48 0f af d0          	imul   %rax,%rdx
   bd4a6:	48 8d 44 42 01       	lea    0x1(%rdx,%rax,2),%rax
   bd4ab:	8b 04 83             	mov    (%rbx,%rax,4),%eax
   bd4ae:	85 c0                	test   %eax,%eax
   bd4b0:	7f d1                	jg     bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd4b2:	be 50 01 00 00       	mov    $0x150,%esi
   bd4b7:	48 8d 3d 32 e3 24 00 	lea    0x24e332(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd4be:	e8 cd 92 20 00       	call   2c6790 <__gnat_rcheck_CE_Range_Check>
   bd4c3:	be 4c 01 00 00       	mov    $0x14c,%esi
   bd4c8:	48 8d 3d 21 e3 24 00 	lea    0x24e321(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd4cf:	e8 22 92 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd4d4:	be d6 00 00 00       	mov    $0xd6,%esi
   bd4d9:	48 8d 3d 10 e3 24 00 	lea    0x24e310(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd4e0:	e8 27 92 20 00       	call   2c670c <__gnat_rcheck_CE_Invalid_Data>
   bd4e5:	be bd 01 00 00       	mov    $0x1bd,%esi
   bd4ea:	48 8d 3d ff e2 24 00 	lea    0x24e2ff(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd4f1:	e8 16 92 20 00       	call   2c670c <__gnat_rcheck_CE_Invalid_Data>
   bd4f6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   bd4fd:	00 00 00 
   bd500:	be a5 00 00 00       	mov    $0xa5,%esi
   bd505:	48 8d 3d e4 e2 24 00 	lea    0x24e2e4(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd50c:	e8 7f 92 20 00       	call   2c6790 <__gnat_rcheck_CE_Range_Check>
   bd511:	be a5 00 00 00       	mov    $0xa5,%esi
   bd516:	48 8d 3d d3 e2 24 00 	lea    0x24e2d3(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd51d:	e8 d4 91 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd522:	be 77 01 00 00       	mov    $0x177,%esi
   bd527:	48 8d 3d c2 e2 24 00 	lea    0x24e2c2(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd52e:	e8 c3 91 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd533:	66 90                	xchg   %ax,%ax
   bd535:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   bd53c:	00 00 00 00 
   bd540:	be a6 00 00 00       	mov    $0xa6,%esi
   bd545:	48 8d 3d a4 e2 24 00 	lea    0x24e2a4(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd54c:	e8 a5 91 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd551:	be dc 00 00 00       	mov    $0xdc,%esi
   bd556:	48 8d 3d 93 e2 24 00 	lea    0x24e293(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd55d:	e8 aa 91 20 00       	call   2c670c <__gnat_rcheck_CE_Invalid_Data>
   bd562:	be 49 01 00 00       	mov    $0x149,%esi
   bd567:	48 8d 3d 82 e2 24 00 	lea    0x24e282(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd56e:	e8 83 91 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd573:	66 90                	xchg   %ax,%ax
   bd575:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   bd57c:	00 00 00 00 
   bd580:	be de 00 00 00       	mov    $0xde,%esi
   bd585:	48 8d 3d 64 e2 24 00 	lea    0x24e264(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd58c:	e8 ff 91 20 00       	call   2c6790 <__gnat_rcheck_CE_Range_Check>
   bd591:	be dd 00 00 00       	mov    $0xdd,%esi
   bd596:	48 8d 3d 53 e2 24 00 	lea    0x24e253(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd59d:	e8 54 91 20 00       	call   2c66f6 <__gnat_rcheck_CE_Index_Check>
   bd5a2:	be c3 01 00 00       	mov    $0x1c3,%esi
   bd5a7:	48 8d 3d 42 e2 24 00 	lea    0x24e242(%rip),%rdi        # 30b7f0 <mj__constraint_solvers__dense_cholesky__statusS+0xd0>
   bd5ae:	e8 dd 91 20 00       	call   2c6790 <__gnat_rcheck_CE_Range_Check>
   bd5b3:	66 90                	xchg   %ax,%ax
   bd5b5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   bd5bc:	00 00 00 00 
   bd5c0:	31 d2                	xor    %edx,%edx
   bd5c2:	e9 4e fd ff ff       	jmp    bd315 <mj__constraint_solvers__sparse_cholesky__factor+0x835>
   bd5c7:	85 c0                	test   %eax,%eax
   bd5c9:	0f 8e 7f fe ff ff    	jle    bd44e <mj__constraint_solvers__sparse_cholesky__factor+0x96e>
   bd5cf:	41 39 c7             	cmp    %eax,%r15d
   bd5d2:	0f 8c 76 fe ff ff    	jl     bd44e <mj__constraint_solvers__sparse_cholesky__factor+0x96e>
   bd5d8:	c4 c1 6b 59 54 c6 f8 	vmulsd -0x8(%r14,%rax,8),%xmm2,%xmm2
   bd5df:	c5 f9 2e 15 41 71 24 	vucomisd 0x247141(%rip),%xmm2        # 304728 <CSWTCH.1415+0x428>
   bd5e6:	00 
   bd5e7:	0f 82 23 fd ff ff    	jb     bd310 <mj__constraint_solvers__sparse_cholesky__factor+0x830>
   bd5ed:	c5 f9 2e e2          	vucomisd %xmm2,%xmm4
   bd5f1:	0f 83 8c fe ff ff    	jae    bd483 <mj__constraint_solvers__sparse_cholesky__factor+0x9a3>
   bd5f7:	e9 14 fd ff ff       	jmp    bd310 <mj__constraint_solvers__sparse_cholesky__factor+0x830>

Disassembly of section .fini:
