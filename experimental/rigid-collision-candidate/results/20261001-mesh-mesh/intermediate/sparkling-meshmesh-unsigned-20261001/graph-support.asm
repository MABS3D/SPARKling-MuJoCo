
/var/tmp/sparkling-meshmesh-unsigned-20261001/build/release/bin/contact_probe:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

0000000000009ba0 <mj__convex_contacts__graph_support>:
    9ba0:	41 57                	push   %r15
    9ba2:	41 56                	push   %r14
    9ba4:	41 55                	push   %r13
    9ba6:	41 54                	push   %r12
    9ba8:	55                   	push   %rbp
    9ba9:	53                   	push   %rbx
    9baa:	48 8b 44 24 40       	mov    0x40(%rsp),%rax
    9baf:	c4 41 f9 6e f8       	vmovq  %r8,%xmm15
    9bb4:	48 89 f3             	mov    %rsi,%rbx
    9bb7:	49 89 d3             	mov    %rdx,%r11
    9bba:	48 63 97 00 01 00 00 	movslq 0x100(%rdi),%rdx
    9bc1:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
    9bc6:	c5 7b 10 4b 18       	vmovsd 0x18(%rbx),%xmm9
    9bcb:	c5 7b 10 53 30       	vmovsd 0x30(%rbx),%xmm10
    9bd0:	62 e1 ff 08 10 63 09 	vmovsd 0x48(%rbx),%xmm20
    9bd7:	62 e1 ff 08 10 43 04 	vmovsd 0x20(%rbx),%xmm16
    9bde:	62 e1 ff 08 10 4b 07 	vmovsd 0x38(%rbx),%xmm17
    9be5:	62 e1 ff 08 10 53 05 	vmovsd 0x28(%rbx),%xmm18
    9bec:	62 e1 ff 08 10 5b 08 	vmovsd 0x40(%rbx),%xmm19
    9bf3:	62 e1 ff 08 10 6b 0a 	vmovsd 0x50(%rbx),%xmm21
    9bfa:	62 e1 ff 08 10 73 0b 	vmovsd 0x58(%rbx),%xmm22
    9c01:	45 89 cc             	mov    %r9d,%r12d
    9c04:	4c 63 09             	movslq (%rcx),%r9
    9c07:	48 63 30             	movslq (%rax),%rsi
    9c0a:	c4 61 f9 7e f8       	vmovq  %xmm15,%rax
    9c0f:	c4 61 f9 6e e7       	vmovq  %rdi,%xmm12
    9c14:	c5 fb 10 10          	vmovsd (%rax),%xmm2
    9c18:	c5 fb 10 48 08       	vmovsd 0x8(%rax),%xmm1
    9c1d:	c5 fb 10 40 10       	vmovsd 0x10(%rax),%xmm0
    9c22:	49 89 d7             	mov    %rdx,%r15
    9c25:	48 89 d0             	mov    %rdx,%rax
    9c28:	48 29 f0             	sub    %rsi,%rax
    9c2b:	4d 63 2c 80          	movslq (%r8,%rax,4),%r13
    9c2f:	31 c0                	xor    %eax,%eax
    9c31:	c5 ab 59 e1          	vmulsd %xmm1,%xmm10,%xmm4
    9c35:	c5 b3 59 da          	vmulsd %xmm2,%xmm9,%xmm3
    9c39:	62 b1 f7 08 59 f9    	vmulsd %xmm17,%xmm1,%xmm7
    9c3f:	62 b1 f7 08 59 cb    	vmulsd %xmm19,%xmm1,%xmm1
    9c45:	c5 e3 58 dc          	vaddsd %xmm4,%xmm3,%xmm3
    9c49:	62 f1 df 00 59 e0    	vmulsd %xmm0,%xmm20,%xmm4
    9c4f:	4c 89 ef             	mov    %r13,%rdi
    9c52:	c5 e3 58 dc          	vaddsd %xmm4,%xmm3,%xmm3
    9c56:	62 b1 ef 08 59 e0    	vmulsd %xmm16,%xmm2,%xmm4
    9c5c:	62 b1 ef 08 59 d2    	vmulsd %xmm18,%xmm2,%xmm2
    9c62:	c5 db 58 e7          	vaddsd %xmm7,%xmm4,%xmm4
    9c66:	c5 eb 58 d1          	vaddsd %xmm1,%xmm2,%xmm2
    9c6a:	62 b1 ff 08 59 fd    	vmulsd %xmm21,%xmm0,%xmm7
    9c70:	62 b1 ff 08 59 c6    	vmulsd %xmm22,%xmm0,%xmm0
    9c76:	c5 fb 10 0d 2a 6f 06 	vmovsd 0x66f2a(%rip),%xmm1        # 70ba8 <ada__numerics__long_elementary_functions__two_pi+0x210>
    9c7d:	00 
    9c7e:	c5 eb 58 d0          	vaddsd %xmm0,%xmm2,%xmm2
    9c82:	c5 fb 10 05 26 6f 06 	vmovsd 0x66f26(%rip),%xmm0        # 70bb0 <ada__numerics__long_elementary_functions__two_pi+0x218>
    9c89:	00 
    9c8a:	c5 db 58 e7          	vaddsd %xmm7,%xmm4,%xmm4
    9c8e:	c5 f9 2f d9          	vcomisd %xmm1,%xmm3
    9c92:	0f 97 c0             	seta   %al
    9c95:	31 c9                	xor    %ecx,%ecx
    9c97:	c5 f9 2f c3          	vcomisd %xmm3,%xmm0
    9c9b:	0f 96 c1             	setbe  %cl
    9c9e:	c5 f9 2f e1          	vcomisd %xmm1,%xmm4
    9ca2:	8d 0c 01             	lea    (%rcx,%rax,1),%ecx
    9ca5:	0f 97 c0             	seta   %al
    9ca8:	45 31 d2             	xor    %r10d,%r10d
    9cab:	c5 f9 2f c4          	vcomisd %xmm4,%xmm0
    9caf:	41 0f 96 c2          	setbe  %r10b
    9cb3:	0f b6 c0             	movzbl %al,%eax
    9cb6:	c5 f9 2f d1          	vcomisd %xmm1,%xmm2
    9cba:	48 8d 0c c9          	lea    (%rcx,%rcx,8),%rcx
    9cbe:	41 8d 04 02          	lea    (%r10,%rax,1),%eax
    9cc2:	41 0f 97 c2          	seta   %r10b
    9cc6:	31 ed                	xor    %ebp,%ebp
    9cc8:	c5 f9 2f c2          	vcomisd %xmm2,%xmm0
    9ccc:	40 0f 96 c5          	setbe  %bpl
    9cd0:	45 0f b6 d2          	movzbl %r10b,%r10d
    9cd4:	48 8d 04 40          	lea    (%rax,%rax,2),%rax
    9cd8:	41 01 ea             	add    %ebp,%r10d
    9cdb:	48 01 c8             	add    %rcx,%rax
    9cde:	c4 61 f9 7e e1       	vmovq  %xmm12,%rcx
    9ce3:	45 89 d2             	mov    %r10d,%r10d
    9ce6:	49 8d 44 02 40       	lea    0x40(%r10,%rax,1),%rax
    9ceb:	c4 41 f9 7e e2       	vmovq  %xmm12,%r10
    9cf0:	8b 44 81 0c          	mov    0xc(%rcx,%rax,4),%eax
    9cf4:	8b 49 50             	mov    0x50(%rcx),%ecx
    9cf7:	89 4c 24 e8          	mov    %ecx,-0x18(%rsp)
    9cfb:	41 0f b6 8a 09 01 00 	movzbl 0x109(%r10),%ecx
    9d02:	00 
    9d03:	4c 8d 52 02          	lea    0x2(%rdx),%r10
    9d07:	c4 41 f9 6e ea       	vmovq  %r10,%xmm13
    9d0c:	4e 8d 54 2a 02       	lea    0x2(%rdx,%r13,1),%r10
    9d11:	88 4c 24 fa          	mov    %cl,-0x6(%rsp)
    9d15:	41 89 ce             	mov    %ecx,%r14d
    9d18:	48 63 c8             	movslq %eax,%rcx
    9d1b:	45 85 e4             	test   %r12d,%r12d
    9d1e:	0f 88 3c 01 00 00    	js     9e60 <mj__convex_contacts__graph_support+0x2c0>
    9d24:	4a 8d 2c 11          	lea    (%rcx,%r10,1),%rbp
    9d28:	48 29 f5             	sub    %rsi,%rbp
    9d2b:	41 8b 2c a8          	mov    (%r8,%rbp,4),%ebp
    9d2f:	89 6c 24 ec          	mov    %ebp,-0x14(%rsp)
    9d33:	44 89 e5             	mov    %r12d,%ebp
    9d36:	48 01 ea             	add    %rbp,%rdx
    9d39:	49 8d 54 15 02       	lea    0x2(%r13,%rdx,1),%rdx
    9d3e:	48 29 f2             	sub    %rsi,%rdx
    9d41:	41 8b 14 90          	mov    (%r8,%rdx,4),%edx
    9d45:	45 84 f6             	test   %r14b,%r14b
    9d48:	0f 84 92 00 00 00    	je     9de0 <mj__convex_contacts__graph_support+0x240>
    9d4e:	44 8b 6c 24 ec       	mov    -0x14(%rsp),%r13d
    9d53:	44 8b 74 24 e8       	mov    -0x18(%rsp),%r14d
    9d58:	81 e2 ff 1f 00 00    	and    $0x1fff,%edx
    9d5e:	41 81 e5 ff 1f 00 00 	and    $0x1fff,%r13d
    9d65:	44 01 f2             	add    %r14d,%edx
    9d68:	45 01 f5             	add    %r14d,%r13d
    9d6b:	48 63 d2             	movslq %edx,%rdx
    9d6e:	4d 63 ed             	movslq %r13d,%r13
    9d71:	4c 29 ca             	sub    %r9,%rdx
    9d74:	4d 29 cd             	sub    %r9,%r13
    9d77:	48 8d 14 52          	lea    (%rdx,%rdx,2),%rdx
    9d7b:	4f 8d 6c 6d 00       	lea    0x0(%r13,%r13,2),%r13
    9d80:	49 8d 14 d3          	lea    (%r11,%rdx,8),%rdx
    9d84:	4f 8d 2c eb          	lea    (%r11,%r13,8),%r13
    9d88:	c5 db 59 7a 08       	vmulsd 0x8(%rdx),%xmm4,%xmm7
    9d8d:	c4 c1 5b 59 45 08    	vmulsd 0x8(%r13),%xmm4,%xmm0
    9d93:	c4 c1 63 59 4d 00    	vmulsd 0x0(%r13),%xmm3,%xmm1
    9d99:	c5 f3 58 c8          	vaddsd %xmm0,%xmm1,%xmm1
    9d9d:	c4 c1 6b 59 45 10    	vmulsd 0x10(%r13),%xmm2,%xmm0
    9da3:	c5 f3 58 c8          	vaddsd %xmm0,%xmm1,%xmm1
    9da7:	c5 e3 59 02          	vmulsd (%rdx),%xmm3,%xmm0
    9dab:	c5 fb 58 c7          	vaddsd %xmm7,%xmm0,%xmm0
    9daf:	c5 eb 59 7a 10       	vmulsd 0x10(%rdx),%xmm2,%xmm7
    9db4:	c5 fb 58 c7          	vaddsd %xmm7,%xmm0,%xmm0
    9db8:	c5 f9 2f c8          	vcomisd %xmm0,%xmm1
    9dbc:	0f 86 fe 04 00 00    	jbe    a2c0 <mj__convex_contacts__graph_support+0x720>
    9dc2:	89 fa                	mov    %edi,%edx
    9dc4:	44 8b 74 24 ec       	mov    -0x14(%rsp),%r14d
    9dc9:	ff ca                	dec    %edx
    9dcb:	89 54 24 e4          	mov    %edx,-0x1c(%rsp)
    9dcf:	0f 89 e5 00 00 00    	jns    9eba <mj__convex_contacts__graph_support+0x31a>
    9dd5:	e9 76 01 00 00       	jmp    9f50 <mj__convex_contacts__graph_support+0x3b0>
    9dda:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    9de0:	44 8b 74 24 e8       	mov    -0x18(%rsp),%r14d
    9de5:	44 8b 6c 24 ec       	mov    -0x14(%rsp),%r13d
    9dea:	45 01 f5             	add    %r14d,%r13d
    9ded:	44 01 f2             	add    %r14d,%edx
    9df0:	4d 63 ed             	movslq %r13d,%r13
    9df3:	48 63 d2             	movslq %edx,%rdx
    9df6:	4d 29 cd             	sub    %r9,%r13
    9df9:	4c 29 ca             	sub    %r9,%rdx
    9dfc:	4f 8d 6c 6d 00       	lea    0x0(%r13,%r13,2),%r13
    9e01:	48 8d 14 52          	lea    (%rdx,%rdx,2),%rdx
    9e05:	4f 8d 2c eb          	lea    (%r11,%r13,8),%r13
    9e09:	49 8d 14 d3          	lea    (%r11,%rdx,8),%rdx
    9e0d:	c4 c1 5b 59 45 08    	vmulsd 0x8(%r13),%xmm4,%xmm0
    9e13:	c4 c1 63 59 4d 00    	vmulsd 0x0(%r13),%xmm3,%xmm1
    9e19:	c5 e3 59 3a          	vmulsd (%rdx),%xmm3,%xmm7
    9e1d:	c5 f3 58 c8          	vaddsd %xmm0,%xmm1,%xmm1
    9e21:	c4 c1 6b 59 45 10    	vmulsd 0x10(%r13),%xmm2,%xmm0
    9e27:	c5 f3 58 c8          	vaddsd %xmm0,%xmm1,%xmm1
    9e2b:	c5 db 59 42 08       	vmulsd 0x8(%rdx),%xmm4,%xmm0
    9e30:	c5 fb 58 c7          	vaddsd %xmm7,%xmm0,%xmm0
    9e34:	c5 eb 59 7a 10       	vmulsd 0x10(%rdx),%xmm2,%xmm7
    9e39:	c5 fb 58 c7          	vaddsd %xmm7,%xmm0,%xmm0
    9e3d:	c5 f9 2f c8          	vcomisd %xmm0,%xmm1
    9e41:	0f 86 29 04 00 00    	jbe    a270 <mj__convex_contacts__graph_support+0x6d0>
    9e47:	89 fa                	mov    %edi,%edx
    9e49:	44 8b 74 24 ec       	mov    -0x14(%rsp),%r14d
    9e4e:	ff ca                	dec    %edx
    9e50:	89 54 24 e4          	mov    %edx,-0x1c(%rsp)
    9e54:	79 64                	jns    9eba <mj__convex_contacts__graph_support+0x31a>
    9e56:	e9 05 01 00 00       	jmp    9f60 <mj__convex_contacts__graph_support+0x3c0>
    9e5b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    9e60:	4c 01 d1             	add    %r10,%rcx
    9e63:	48 89 ca             	mov    %rcx,%rdx
    9e66:	48 29 f2             	sub    %rsi,%rdx
    9e69:	41 8b 14 90          	mov    (%r8,%rdx,4),%edx
    9e6d:	80 7c 24 fa 00       	cmpb   $0x0,-0x6(%rsp)
    9e72:	0f 84 0a 04 00 00    	je     a282 <mj__convex_contacts__graph_support+0x6e2>
    9e78:	41 89 fe             	mov    %edi,%r14d
    9e7b:	41 ff ce             	dec    %r14d
    9e7e:	44 89 74 24 e4       	mov    %r14d,-0x1c(%rsp)
    9e83:	0f 88 5a 04 00 00    	js     a2e3 <mj__convex_contacts__graph_support+0x743>
    9e89:	81 e2 ff 1f 00 00    	and    $0x1fff,%edx
    9e8f:	03 54 24 e8          	add    -0x18(%rsp),%edx
    9e93:	48 63 c8             	movslq %eax,%rcx
    9e96:	48 63 d2             	movslq %edx,%rdx
    9e99:	4c 29 ca             	sub    %r9,%rdx
    9e9c:	48 8d 14 52          	lea    (%rdx,%rdx,2),%rdx
    9ea0:	49 8d 14 d3          	lea    (%r11,%rdx,8),%rdx
    9ea4:	c5 db 59 42 08       	vmulsd 0x8(%rdx),%xmm4,%xmm0
    9ea9:	c5 e3 59 0a          	vmulsd (%rdx),%xmm3,%xmm1
    9ead:	c5 f3 58 c8          	vaddsd %xmm0,%xmm1,%xmm1
    9eb1:	c5 eb 59 42 10       	vmulsd 0x10(%rdx),%xmm2,%xmm0
    9eb6:	c5 f3 58 c8          	vaddsd %xmm0,%xmm1,%xmm1
    9eba:	41 8d 7c 7f 02       	lea    0x2(%r15,%rdi,2),%edi
    9ebf:	4c 63 74 24 e8       	movslq -0x18(%rsp),%r14
    9ec4:	48 89 f2             	mov    %rsi,%rdx
    9ec7:	c5 79 6e f7          	vmovd  %edi,%xmm14
    9ecb:	c4 61 f9 7e e7       	vmovq  %xmm12,%rdi
    9ed0:	48 f7 da             	neg    %rdx
    9ed3:	0f b6 bf 08 01 00 00 	movzbl 0x108(%rdi),%edi
    9eda:	49 8d 2c 90          	lea    (%r8,%rdx,4),%rbp
    9ede:	40 88 7c 24 fb       	mov    %dil,-0x5(%rsp)
    9ee3:	c4 61 f9 7e e7       	vmovq  %xmm12,%rdi
    9ee8:	44 03 bf 04 01 00 00 	add    0x104(%rdi),%r15d
    9eef:	bf ff ff ff ff       	mov    $0xffffffff,%edi
    9ef4:	41 ff cf             	dec    %r15d
    9ef7:	44 89 7c 24 ec       	mov    %r15d,-0x14(%rsp)
    9efc:	4d 89 c7             	mov    %r8,%r15
    9eff:	49 89 e8             	mov    %rbp,%r8
    9f02:	0f 1f 00             	nopl   (%rax)
    9f05:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    9f0c:	00 00 00 00 
    9f10:	c4 61 f9 7e ea       	vmovq  %xmm13,%rdx
    9f15:	c5 79 7e f5          	vmovd  %xmm14,%ebp
    9f19:	48 01 ca             	add    %rcx,%rdx
    9f1c:	48 29 f2             	sub    %rsi,%rdx
    9f1f:	41 03 2c 97          	add    (%r15,%rdx,4),%ebp
    9f23:	48 63 d5             	movslq %ebp,%rdx
    9f26:	80 7c 24 fa 00       	cmpb   $0x0,-0x6(%rsp)
    9f2b:	0f 84 2f 01 00 00    	je     a060 <mj__convex_contacts__graph_support+0x4c0>
    9f31:	4c 01 d1             	add    %r10,%rcx
    9f34:	48 29 f1             	sub    %rsi,%rcx
    9f37:	45 8b 24 8f          	mov    (%r15,%rcx,4),%r12d
    9f3b:	44 89 e1             	mov    %r12d,%ecx
    9f3e:	c1 e9 0d             	shr    $0xd,%ecx
    9f41:	8d 4c 0a ff          	lea    -0x1(%rdx,%rcx,1),%ecx
    9f45:	39 d1                	cmp    %edx,%ecx
    9f47:	0f 8d f3 01 00 00    	jge    a140 <mj__convex_contacts__graph_support+0x5a0>
    9f4d:	45 89 e6             	mov    %r12d,%r14d
    9f50:	41 81 e6 ff 1f 00 00 	and    $0x1fff,%r14d
    9f57:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    9f5e:	00 00 
    9f60:	44 03 74 24 e8       	add    -0x18(%rsp),%r14d
    9f65:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
    9f6a:	49 63 d6             	movslq %r14d,%rdx
    9f6d:	4c 29 ca             	sub    %r9,%rdx
    9f70:	48 8d 14 52          	lea    (%rdx,%rdx,2),%rdx
    9f74:	49 8d 14 d3          	lea    (%r11,%rdx,8),%rdx
    9f78:	c5 fb 10 02          	vmovsd (%rdx),%xmm0
    9f7c:	c5 fb 10 62 08       	vmovsd 0x8(%rdx),%xmm4
    9f81:	c5 fb 10 5a 10       	vmovsd 0x10(%rdx),%xmm3
    9f86:	c5 b3 59 c8          	vmulsd %xmm0,%xmm9,%xmm1
    9f8a:	62 e1 ff 00 59 c4    	vmulsd %xmm4,%xmm16,%xmm16
    9f90:	c5 ab 59 d0          	vmulsd %xmm0,%xmm10,%xmm2
    9f94:	62 e1 f7 00 59 cc    	vmulsd %xmm4,%xmm17,%xmm17
    9f9a:	62 f1 df 00 59 c0    	vmulsd %xmm0,%xmm20,%xmm0
    9fa0:	62 f1 d7 00 59 e4    	vmulsd %xmm4,%xmm21,%xmm4
    9fa6:	62 e1 ef 00 59 d3    	vmulsd %xmm3,%xmm18,%xmm18
    9fac:	62 e1 e7 00 59 db    	vmulsd %xmm3,%xmm19,%xmm19
    9fb2:	62 b1 f7 08 58 c8    	vaddsd %xmm16,%xmm1,%xmm1
    9fb8:	62 f1 cf 00 59 db    	vmulsd %xmm3,%xmm22,%xmm3
    9fbe:	62 b1 ef 08 58 d1    	vaddsd %xmm17,%xmm2,%xmm2
    9fc4:	c5 fb 58 c4          	vaddsd %xmm4,%xmm0,%xmm0
    9fc8:	c5 d9 57 e4          	vxorpd %xmm4,%xmm4,%xmm4
    9fcc:	62 b1 f7 08 58 ca    	vaddsd %xmm18,%xmm1,%xmm1
    9fd2:	c5 f3 58 0b          	vaddsd (%rbx),%xmm1,%xmm1
    9fd6:	62 b1 ef 08 58 d3    	vaddsd %xmm19,%xmm2,%xmm2
    9fdc:	c5 eb 58 53 08       	vaddsd 0x8(%rbx),%xmm2,%xmm2
    9fe1:	c5 fb 58 c3          	vaddsd %xmm3,%xmm0,%xmm0
    9fe5:	c5 fb 58 43 10       	vaddsd 0x10(%rbx),%xmm0,%xmm0
    9fea:	c5 fb 11 0f          	vmovsd %xmm1,(%rdi)
    9fee:	c5 fb 11 57 08       	vmovsd %xmm2,0x8(%rdi)
    9ff3:	c5 fb 11 47 10       	vmovsd %xmm0,0x10(%rdi)
    9ff8:	c4 61 f9 7e e7       	vmovq  %xmm12,%rdi
    9ffd:	c5 fb 10 9f 80 01 00 	vmovsd 0x180(%rdi),%xmm3
    a004:	00 
    a005:	c5 f9 2f dc          	vcomisd %xmm4,%xmm3
    a009:	76 32                	jbe    a03d <mj__convex_contacts__graph_support+0x49d>
    a00b:	c4 61 f9 7e fe       	vmovq  %xmm15,%rsi
    a010:	c5 e3 59 66 08       	vmulsd 0x8(%rsi),%xmm3,%xmm4
    a015:	c5 db 58 e2          	vaddsd %xmm2,%xmm4,%xmm4
    a019:	c5 e3 59 56 10       	vmulsd 0x10(%rsi),%xmm3,%xmm2
    a01e:	c5 e3 59 1e          	vmulsd (%rsi),%xmm3,%xmm3
    a022:	48 8b 74 24 48       	mov    0x48(%rsp),%rsi
    a027:	c5 fb 11 66 08       	vmovsd %xmm4,0x8(%rsi)
    a02c:	c5 eb 58 d0          	vaddsd %xmm0,%xmm2,%xmm2
    a030:	c5 e3 58 d9          	vaddsd %xmm1,%xmm3,%xmm3
    a034:	c5 fb 11 56 10       	vmovsd %xmm2,0x10(%rsi)
    a039:	c5 fb 11 1e          	vmovsd %xmm3,(%rsi)
    a03d:	49 c1 e6 20          	shl    $0x20,%r14
    a041:	89 c0                	mov    %eax,%eax
    a043:	5b                   	pop    %rbx
    a044:	5d                   	pop    %rbp
    a045:	41 5c                	pop    %r12
    a047:	4c 09 f0             	or     %r14,%rax
    a04a:	41 5d                	pop    %r13
    a04c:	41 5e                	pop    %r14
    a04e:	41 5f                	pop    %r15
    a050:	c3                   	ret
    a051:	0f 1f 40 00          	nopl   0x0(%rax)
    a055:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a05c:	00 00 00 00 
    a060:	80 7c 24 fb 00       	cmpb   $0x0,-0x5(%rsp)
    a065:	74 19                	je     a080 <mj__convex_contacts__graph_support+0x4e0>
    a067:	39 54 24 ec          	cmp    %edx,-0x14(%rsp)
    a06b:	0f 8d 5f 01 00 00    	jge    a1d0 <mj__convex_contacts__graph_support+0x630>
    a071:	4c 01 d1             	add    %r10,%rcx
    a074:	48 29 f1             	sub    %rsi,%rcx
    a077:	45 8b 34 8f          	mov    (%r15,%rcx,4),%r14d
    a07b:	e9 e0 fe ff ff       	jmp    9f60 <mj__convex_contacts__graph_support+0x3c0>
    a080:	39 54 24 ec          	cmp    %edx,-0x14(%rsp)
    a084:	7c eb                	jl     a071 <mj__convex_contacts__graph_support+0x4d1>
    a086:	48 63 6c 24 ec       	movslq -0x14(%rsp),%rbp
    a08b:	89 44 24 f0          	mov    %eax,-0x10(%rsp)
    a08f:	89 7c 24 fc          	mov    %edi,-0x4(%rsp)
    a093:	89 c1                	mov    %eax,%ecx
    a095:	48 ff ca             	dec    %rdx
    a098:	8b 44 24 e8          	mov    -0x18(%rsp),%eax
    a09c:	c4 e1 f9 6e f3       	vmovq  %rbx,%xmm6
    a0a1:	48 89 ef             	mov    %rbp,%rdi
    a0a4:	eb 58                	jmp    a0fe <mj__convex_contacts__graph_support+0x55e>
    a0a6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a0ad:	00 00 00 
    a0b0:	44 89 e5             	mov    %r12d,%ebp
    a0b3:	4c 01 d5             	add    %r10,%rbp
    a0b6:	48 29 f5             	sub    %rsi,%rbp
    a0b9:	41 8b 1c af          	mov    (%r15,%rbp,4),%ebx
    a0bd:	01 c3                	add    %eax,%ebx
    a0bf:	48 63 eb             	movslq %ebx,%rbp
    a0c2:	4c 29 cd             	sub    %r9,%rbp
    a0c5:	48 8d 6c 6d 00       	lea    0x0(%rbp,%rbp,2),%rbp
    a0ca:	49 8d 2c eb          	lea    (%r11,%rbp,8),%rbp
    a0ce:	62 e1 df 08 59 7d 01 	vmulsd 0x8(%rbp),%xmm4,%xmm23
    a0d5:	c5 e3 59 45 00       	vmulsd 0x0(%rbp),%xmm3,%xmm0
    a0da:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a0e0:	62 e1 ef 08 59 7d 02 	vmulsd 0x10(%rbp),%xmm2,%xmm23
    a0e7:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a0ed:	c5 f9 2f c1          	vcomisd %xmm1,%xmm0
    a0f1:	c5 fb 5f c9          	vmaxsd %xmm1,%xmm0,%xmm1
    a0f5:	41 0f 47 cc          	cmova  %r12d,%ecx
    a0f9:	48 39 d7             	cmp    %rdx,%rdi
    a0fc:	74 0c                	je     a10a <mj__convex_contacts__graph_support+0x56a>
    a0fe:	48 ff c2             	inc    %rdx
    a101:	45 8b 24 90          	mov    (%r8,%rdx,4),%r12d
    a105:	45 85 e4             	test   %r12d,%r12d
    a108:	79 a6                	jns    a0b0 <mj__convex_contacts__graph_support+0x510>
    a10a:	8b 44 24 f0          	mov    -0x10(%rsp),%eax
    a10e:	8b 7c 24 fc          	mov    -0x4(%rsp),%edi
    a112:	c4 e1 f9 7e f3       	vmovq  %xmm6,%rbx
    a117:	39 c8                	cmp    %ecx,%eax
    a119:	0f 84 81 01 00 00    	je     a2a0 <mj__convex_contacts__graph_support+0x700>
    a11f:	ff c7                	inc    %edi
    a121:	3b 7c 24 e4          	cmp    -0x1c(%rsp),%edi
    a125:	0f 84 75 01 00 00    	je     a2a0 <mj__convex_contacts__graph_support+0x700>
    a12b:	48 63 c9             	movslq %ecx,%rcx
    a12e:	48 89 c8             	mov    %rcx,%rax
    a131:	e9 da fd ff ff       	jmp    9f10 <mj__convex_contacts__graph_support+0x370>
    a136:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a13d:	00 00 00 
    a140:	48 63 e9             	movslq %ecx,%rbp
    a143:	4c 89 54 24 f0       	mov    %r10,-0x10(%rsp)
    a148:	89 c1                	mov    %eax,%ecx
    a14a:	41 89 fa             	mov    %edi,%r10d
    a14d:	89 c7                	mov    %eax,%edi
    a14f:	48 89 e8             	mov    %rbp,%rax
    a152:	48 8d 6a ff          	lea    -0x1(%rdx),%rbp
    a156:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a15d:	00 00 00 
    a160:	48 ff c5             	inc    %rbp
    a163:	41 8b 14 a8          	mov    (%r8,%rbp,4),%edx
    a167:	41 89 d4             	mov    %edx,%r12d
    a16a:	41 81 e4 ff 1f 00 00 	and    $0x1fff,%r12d
    a171:	4d 01 f4             	add    %r14,%r12
    a174:	4d 29 cc             	sub    %r9,%r12
    a177:	4f 8d 24 64          	lea    (%r12,%r12,2),%r12
    a17b:	4f 8d 24 e3          	lea    (%r11,%r12,8),%r12
    a17f:	62 c1 e7 08 59 3c 24 	vmulsd (%r12),%xmm3,%xmm23
    a186:	c4 c1 5b 59 44 24 08 	vmulsd 0x8(%r12),%xmm4,%xmm0
    a18d:	c1 ea 0d             	shr    $0xd,%edx
    a190:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a196:	62 c1 ef 08 59 7c 24 	vmulsd 0x10(%r12),%xmm2,%xmm23
    a19d:	02 
    a19e:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a1a4:	c5 f9 2f c1          	vcomisd %xmm1,%xmm0
    a1a8:	c5 fb 5f c9          	vmaxsd %xmm1,%xmm0,%xmm1
    a1ac:	0f 47 ca             	cmova  %edx,%ecx
    a1af:	48 39 e8             	cmp    %rbp,%rax
    a1b2:	75 ac                	jne    a160 <mj__convex_contacts__graph_support+0x5c0>
    a1b4:	89 f8                	mov    %edi,%eax
    a1b6:	44 89 d7             	mov    %r10d,%edi
    a1b9:	4c 8b 54 24 f0       	mov    -0x10(%rsp),%r10
    a1be:	e9 54 ff ff ff       	jmp    a117 <mj__convex_contacts__graph_support+0x577>
    a1c3:	66 90                	xchg   %ax,%ax
    a1c5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a1cc:	00 00 00 00 
    a1d0:	48 63 6c 24 e8       	movslq -0x18(%rsp),%rbp
    a1d5:	4c 89 54 24 f0       	mov    %r10,-0x10(%rsp)
    a1da:	89 c1                	mov    %eax,%ecx
    a1dc:	41 89 fa             	mov    %edi,%r10d
    a1df:	c4 e1 f9 6e f3       	vmovq  %rbx,%xmm6
    a1e4:	89 c7                	mov    %eax,%edi
    a1e6:	4c 89 db             	mov    %r11,%rbx
    a1e9:	48 ff ca             	dec    %rdx
    a1ec:	c4 e1 f9 6e fd       	vmovq  %rbp,%xmm7
    a1f1:	48 63 6c 24 ec       	movslq -0x14(%rsp),%rbp
    a1f6:	c4 c1 f9 7e fb       	vmovq  %xmm7,%r11
    a1fb:	48 89 e8             	mov    %rbp,%rax
    a1fe:	eb 4c                	jmp    a24c <mj__convex_contacts__graph_support+0x6ac>
    a200:	44 89 e5             	mov    %r12d,%ebp
    a203:	81 e5 ff 1f 00 00    	and    $0x1fff,%ebp
    a209:	4c 01 dd             	add    %r11,%rbp
    a20c:	4c 29 cd             	sub    %r9,%rbp
    a20f:	48 8d 6c 6d 00       	lea    0x0(%rbp,%rbp,2),%rbp
    a214:	48 8d 2c eb          	lea    (%rbx,%rbp,8),%rbp
    a218:	62 e1 df 08 59 7d 01 	vmulsd 0x8(%rbp),%xmm4,%xmm23
    a21f:	c5 e3 59 45 00       	vmulsd 0x0(%rbp),%xmm3,%xmm0
    a224:	41 c1 ec 0d          	shr    $0xd,%r12d
    a228:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a22e:	62 e1 ef 08 59 7d 02 	vmulsd 0x10(%rbp),%xmm2,%xmm23
    a235:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a23b:	c5 f9 2f c1          	vcomisd %xmm1,%xmm0
    a23f:	c5 fb 5f c9          	vmaxsd %xmm1,%xmm0,%xmm1
    a243:	41 0f 47 cc          	cmova  %r12d,%ecx
    a247:	48 39 d0             	cmp    %rdx,%rax
    a24a:	74 0c                	je     a258 <mj__convex_contacts__graph_support+0x6b8>
    a24c:	48 ff c2             	inc    %rdx
    a24f:	45 8b 24 90          	mov    (%r8,%rdx,4),%r12d
    a253:	45 85 e4             	test   %r12d,%r12d
    a256:	79 a8                	jns    a200 <mj__convex_contacts__graph_support+0x660>
    a258:	89 f8                	mov    %edi,%eax
    a25a:	49 89 db             	mov    %rbx,%r11
    a25d:	44 89 d7             	mov    %r10d,%edi
    a260:	c4 e1 f9 7e f3       	vmovq  %xmm6,%rbx
    a265:	4c 8b 54 24 f0       	mov    -0x10(%rsp),%r10
    a26a:	e9 a8 fe ff ff       	jmp    a117 <mj__convex_contacts__graph_support+0x577>
    a26f:	90                   	nop
    a270:	4a 8d 4c 15 00       	lea    0x0(%rbp,%r10,1),%rcx
    a275:	48 89 c8             	mov    %rcx,%rax
    a278:	48 29 f0             	sub    %rsi,%rax
    a27b:	41 8b 14 80          	mov    (%r8,%rax,4),%edx
    a27f:	44 89 e0             	mov    %r12d,%eax
    a282:	41 89 fe             	mov    %edi,%r14d
    a285:	41 ff ce             	dec    %r14d
    a288:	44 89 74 24 e4       	mov    %r14d,-0x1c(%rsp)
    a28d:	0f 89 fc fb ff ff    	jns    9e8f <mj__convex_contacts__graph_support+0x2ef>
    a293:	48 29 f1             	sub    %rsi,%rcx
    a296:	45 8b 34 88          	mov    (%r8,%rcx,4),%r14d
    a29a:	e9 c1 fc ff ff       	jmp    9f60 <mj__convex_contacts__graph_support+0x3c0>
    a29f:	90                   	nop
    a2a0:	48 63 c1             	movslq %ecx,%rax
    a2a3:	4c 01 d0             	add    %r10,%rax
    a2a6:	48 29 f0             	sub    %rsi,%rax
    a2a9:	45 8b 34 87          	mov    (%r15,%rax,4),%r14d
    a2ad:	89 c8                	mov    %ecx,%eax
    a2af:	80 7c 24 fa 00       	cmpb   $0x0,-0x6(%rsp)
    a2b4:	0f 85 96 fc ff ff    	jne    9f50 <mj__convex_contacts__graph_support+0x3b0>
    a2ba:	e9 a1 fc ff ff       	jmp    9f60 <mj__convex_contacts__graph_support+0x3c0>
    a2bf:	90                   	nop
    a2c0:	4a 8d 4c 15 00       	lea    0x0(%rbp,%r10,1),%rcx
    a2c5:	41 89 fe             	mov    %edi,%r14d
    a2c8:	48 89 c8             	mov    %rcx,%rax
    a2cb:	48 29 f0             	sub    %rsi,%rax
    a2ce:	41 ff ce             	dec    %r14d
    a2d1:	41 8b 14 80          	mov    (%r8,%rax,4),%edx
    a2d5:	44 89 74 24 e4       	mov    %r14d,-0x1c(%rsp)
    a2da:	44 89 e0             	mov    %r12d,%eax
    a2dd:	0f 89 a6 fb ff ff    	jns    9e89 <mj__convex_contacts__graph_support+0x2e9>
    a2e3:	48 29 f1             	sub    %rsi,%rcx
    a2e6:	45 8b 34 88          	mov    (%r8,%rcx,4),%r14d
    a2ea:	e9 61 fc ff ff       	jmp    9f50 <mj__convex_contacts__graph_support+0x3b0>

Disassembly of section .fini:
