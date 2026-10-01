
/var/tmp/sparkling-meshmesh-seed-cache-20261001/build/release/bin/contact_probe:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

0000000000009ba0 <mj__convex_contacts__graph_support>:
    9ba0:	c4 c1 f9 6e f0       	vmovq  %r8,%xmm6
    9ba5:	41 57                	push   %r15
    9ba7:	41 56                	push   %r14
    9ba9:	41 55                	push   %r13
    9bab:	41 54                	push   %r12
    9bad:	55                   	push   %rbp
    9bae:	53                   	push   %rbx
    9baf:	c4 e1 f9 7e f3       	vmovq  %xmm6,%rbx
    9bb4:	c5 fb 10 13          	vmovsd (%rbx),%xmm2
    9bb8:	c5 fb 10 4b 08       	vmovsd 0x8(%rbx),%xmm1
    9bbd:	c5 7b 10 4e 18       	vmovsd 0x18(%rsi),%xmm9
    9bc2:	c5 7b 10 5e 30       	vmovsd 0x30(%rsi),%xmm11
    9bc7:	c5 fb 10 43 10       	vmovsd 0x10(%rbx),%xmm0
    9bcc:	c5 7b 10 56 48       	vmovsd 0x48(%rsi),%xmm10
    9bd1:	62 e1 ff 08 10 76 04 	vmovsd 0x20(%rsi),%xmm22
    9bd8:	62 e1 ff 08 10 66 07 	vmovsd 0x38(%rsi),%xmm20
    9bdf:	62 e1 ff 08 10 6e 05 	vmovsd 0x28(%rsi),%xmm21
    9be6:	62 e1 ff 08 10 5e 08 	vmovsd 0x40(%rsi),%xmm19
    9bed:	48 8b 44 24 40       	mov    0x40(%rsp),%rax
    9bf2:	62 e1 ff 08 10 56 0a 	vmovsd 0x50(%rsi),%xmm18
    9bf9:	62 e1 ff 08 10 4e 0b 	vmovsd 0x58(%rsi),%xmm17
    9c00:	49 89 d7             	mov    %rdx,%r15
    9c03:	48 63 97 00 01 00 00 	movslq 0x100(%rdi),%rdx
    9c0a:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
    9c0f:	49 89 f6             	mov    %rsi,%r14
    9c12:	4c 63 21             	movslq (%rcx),%r12
    9c15:	48 8b 4c 24 48       	mov    0x48(%rsp),%rcx
    9c1a:	c4 61 f9 6e ef       	vmovq  %rdi,%xmm13
    9c1f:	31 ff                	xor    %edi,%edi
    9c21:	c5 a3 59 e1          	vmulsd %xmm1,%xmm11,%xmm4
    9c25:	c5 b3 59 da          	vmulsd %xmm2,%xmm9,%xmm3
    9c29:	48 63 00             	movslq (%rax),%rax
    9c2c:	62 b1 f7 08 59 fc    	vmulsd %xmm20,%xmm1,%xmm7
    9c32:	62 b1 f7 08 59 cb    	vmulsd %xmm19,%xmm1,%xmm1
    9c38:	48 8d 6a 02          	lea    0x2(%rdx),%rbp
    9c3c:	49 89 d5             	mov    %rdx,%r13
    9c3f:	c5 e3 58 dc          	vaddsd %xmm4,%xmm3,%xmm3
    9c43:	c5 ab 59 e0          	vmulsd %xmm0,%xmm10,%xmm4
    9c47:	c4 61 f9 6e f5       	vmovq  %rbp,%xmm14
    9c4c:	c5 e3 58 dc          	vaddsd %xmm4,%xmm3,%xmm3
    9c50:	62 b1 ef 08 59 e6    	vmulsd %xmm22,%xmm2,%xmm4
    9c56:	62 b1 ef 08 59 d5    	vmulsd %xmm21,%xmm2,%xmm2
    9c5c:	48 89 d6             	mov    %rdx,%rsi
    9c5f:	48 29 c6             	sub    %rax,%rsi
    9c62:	41 8b 34 b0          	mov    (%r8,%rsi,4),%esi
    9c66:	c5 db 58 e7          	vaddsd %xmm7,%xmm4,%xmm4
    9c6a:	c5 eb 58 d1          	vaddsd %xmm1,%xmm2,%xmm2
    9c6e:	62 b1 ff 08 59 fa    	vmulsd %xmm18,%xmm0,%xmm7
    9c74:	62 b1 ff 08 59 c1    	vmulsd %xmm17,%xmm0,%xmm0
    9c7a:	c5 fb 10 0d e6 6e 06 	vmovsd 0x66ee6(%rip),%xmm1        # 70b68 <ada__numerics__long_elementary_functions__two_pi+0x210>
    9c81:	00 
    9c82:	c5 eb 58 d0          	vaddsd %xmm0,%xmm2,%xmm2
    9c86:	c5 fb 10 05 e2 6e 06 	vmovsd 0x66ee2(%rip),%xmm0        # 70b70 <ada__numerics__long_elementary_functions__two_pi+0x218>
    9c8d:	00 
    9c8e:	c5 db 58 e7          	vaddsd %xmm7,%xmm4,%xmm4
    9c92:	c5 f9 2f d9          	vcomisd %xmm1,%xmm3
    9c96:	40 0f 97 c7          	seta   %dil
    9c9a:	45 31 d2             	xor    %r10d,%r10d
    9c9d:	c5 f9 2f c3          	vcomisd %xmm3,%xmm0
    9ca1:	41 0f 96 c2          	setbe  %r10b
    9ca5:	c5 f9 2f e1          	vcomisd %xmm1,%xmm4
    9ca9:	45 8d 14 3a          	lea    (%r10,%rdi,1),%r10d
    9cad:	40 0f 97 c7          	seta   %dil
    9cb1:	45 31 db             	xor    %r11d,%r11d
    9cb4:	c5 f9 2f c4          	vcomisd %xmm4,%xmm0
    9cb8:	41 0f 96 c3          	setbe  %r11b
    9cbc:	40 0f b6 ff          	movzbl %dil,%edi
    9cc0:	c5 f9 2f d1          	vcomisd %xmm1,%xmm2
    9cc4:	4f 8d 14 d2          	lea    (%r10,%r10,8),%r10
    9cc8:	41 8d 3c 3b          	lea    (%r11,%rdi,1),%edi
    9ccc:	41 0f 97 c3          	seta   %r11b
    9cd0:	31 db                	xor    %ebx,%ebx
    9cd2:	c5 f9 2f c2          	vcomisd %xmm2,%xmm0
    9cd6:	0f 96 c3             	setbe  %bl
    9cd9:	45 0f b6 db          	movzbl %r11b,%r11d
    9cdd:	48 8d 3c 7f          	lea    (%rdi,%rdi,2),%rdi
    9ce1:	41 01 db             	add    %ebx,%r11d
    9ce4:	4c 01 d7             	add    %r10,%rdi
    9ce7:	c4 61 f9 7e eb       	vmovq  %xmm13,%rbx
    9cec:	45 89 db             	mov    %r11d,%r11d
    9cef:	49 8d 7c 3b 40       	lea    0x40(%r11,%rdi,1),%rdi
    9cf4:	44 8b 54 bb 0c       	mov    0xc(%rbx,%rdi,4),%r10d
    9cf9:	8b 5b 50             	mov    0x50(%rbx),%ebx
    9cfc:	c4 61 f9 7e ef       	vmovq  %xmm13,%rdi
    9d01:	89 5c 24 e8          	mov    %ebx,-0x18(%rsp)
    9d05:	0f b6 9f 09 01 00 00 	movzbl 0x109(%rdi),%ebx
    9d0c:	48 63 fe             	movslq %esi,%rdi
    9d0f:	4c 8d 1c 3a          	lea    (%rdx,%rdi,1),%r11
    9d13:	48 8d 6c 3a 02       	lea    0x2(%rdx,%rdi,1),%rbp
    9d18:	c4 c1 f9 6e eb       	vmovq  %r11,%xmm5
    9d1d:	4d 63 da             	movslq %r10d,%r11
    9d20:	49 8d 14 2b          	lea    (%r11,%rbp,1),%rdx
    9d24:	48 29 c2             	sub    %rax,%rdx
    9d27:	88 5c 24 fa          	mov    %bl,-0x6(%rsp)
    9d2b:	41 8b 14 90          	mov    (%r8,%rdx,4),%edx
    9d2f:	84 db                	test   %bl,%bl
    9d31:	0f 84 39 04 00 00    	je     a170 <mj__convex_contacts__graph_support+0x5d0>
    9d37:	89 d7                	mov    %edx,%edi
    9d39:	c1 ff 1f             	sar    $0x1f,%edi
    9d3c:	89 fb                	mov    %edi,%ebx
    9d3e:	c1 eb 13             	shr    $0x13,%ebx
    9d41:	8d 3c 1a             	lea    (%rdx,%rbx,1),%edi
    9d44:	81 e7 ff 1f 00 00    	and    $0x1fff,%edi
    9d4a:	29 df                	sub    %ebx,%edi
    9d4c:	03 7c 24 e8          	add    -0x18(%rsp),%edi
    9d50:	48 63 ff             	movslq %edi,%rdi
    9d53:	4c 29 e7             	sub    %r12,%rdi
    9d56:	48 8d 3c 7f          	lea    (%rdi,%rdi,2),%rdi
    9d5a:	49 8d 3c ff          	lea    (%r15,%rdi,8),%rdi
    9d5e:	c5 db 59 4f 08       	vmulsd 0x8(%rdi),%xmm4,%xmm1
    9d63:	c5 e3 59 07          	vmulsd (%rdi),%xmm3,%xmm0
    9d67:	c5 fb 58 c1          	vaddsd %xmm1,%xmm0,%xmm0
    9d6b:	c5 eb 59 4f 10       	vmulsd 0x10(%rdi),%xmm2,%xmm1
    9d70:	c5 fb 58 c1          	vaddsd %xmm1,%xmm0,%xmm0
    9d74:	45 85 c9             	test   %r9d,%r9d
    9d77:	0f 88 33 02 00 00    	js     9fb0 <mj__convex_contacts__graph_support+0x410>
    9d7d:	c4 e1 f9 7e eb       	vmovq  %xmm5,%rbx
    9d82:	44 89 cf             	mov    %r9d,%edi
    9d85:	48 8d 54 3b 02       	lea    0x2(%rbx,%rdi,1),%rdx
    9d8a:	48 29 c2             	sub    %rax,%rdx
    9d8d:	41 8b 14 90          	mov    (%r8,%rdx,4),%edx
    9d91:	89 d3                	mov    %edx,%ebx
    9d93:	c1 fb 1f             	sar    $0x1f,%ebx
    9d96:	c1 eb 13             	shr    $0x13,%ebx
    9d99:	01 da                	add    %ebx,%edx
    9d9b:	81 e2 ff 1f 00 00    	and    $0x1fff,%edx
    9da1:	29 da                	sub    %ebx,%edx
    9da3:	03 54 24 e8          	add    -0x18(%rsp),%edx
    9da7:	89 f3                	mov    %esi,%ebx
    9da9:	48 63 d2             	movslq %edx,%rdx
    9dac:	4c 29 e2             	sub    %r12,%rdx
    9daf:	48 8d 14 52          	lea    (%rdx,%rdx,2),%rdx
    9db3:	49 8d 14 d7          	lea    (%r15,%rdx,8),%rdx
    9db7:	c5 db 59 7a 08       	vmulsd 0x8(%rdx),%xmm4,%xmm7
    9dbc:	c5 e3 59 0a          	vmulsd (%rdx),%xmm3,%xmm1
    9dc0:	c5 f3 58 cf          	vaddsd %xmm7,%xmm1,%xmm1
    9dc4:	c5 eb 59 7a 10       	vmulsd 0x10(%rdx),%xmm2,%xmm7
    9dc9:	c5 f3 58 cf          	vaddsd %xmm7,%xmm1,%xmm1
    9dcd:	c5 f9 2f c8          	vcomisd %xmm0,%xmm1
    9dd1:	c5 fb c2 f9 02       	vcmplesd %xmm1,%xmm0,%xmm7
    9dd6:	45 0f 42 ca          	cmovb  %r10d,%r9d
    9dda:	49 0f 42 fb          	cmovb  %r11,%rdi
    9dde:	ff cb                	dec    %ebx
    9de0:	c4 e3 79 4b c9 70    	vblendvpd %xmm7,%xmm1,%xmm0,%xmm1
    9de6:	41 89 da             	mov    %ebx,%r10d
    9de9:	0f 88 91 04 00 00    	js     a280 <mj__convex_contacts__graph_support+0x6e0>
    9def:	41 8d 5c 75 02       	lea    0x2(%r13,%rsi,2),%ebx
    9df4:	48 89 4c 24 48       	mov    %rcx,0x48(%rsp)
    9df9:	41 bb ff ff ff ff    	mov    $0xffffffff,%r11d
    9dff:	48 89 e9             	mov    %rbp,%rcx
    9e02:	c5 f9 6e eb          	vmovd  %ebx,%xmm5
    9e06:	c4 61 f9 7e eb       	vmovq  %xmm13,%rbx
    9e0b:	48 89 c5             	mov    %rax,%rbp
    9e0e:	0f b6 9b 08 01 00 00 	movzbl 0x108(%rbx),%ebx
    9e15:	88 5c 24 fb          	mov    %bl,-0x5(%rsp)
    9e19:	c4 61 f9 7e eb       	vmovq  %xmm13,%rbx
    9e1e:	8b 93 04 01 00 00    	mov    0x104(%rbx),%edx
    9e24:	42 8d 5c 2a ff       	lea    -0x1(%rdx,%r13,1),%ebx
    9e29:	48 89 c2             	mov    %rax,%rdx
    9e2c:	89 5c 24 ec          	mov    %ebx,-0x14(%rsp)
    9e30:	48 63 5c 24 e8       	movslq -0x18(%rsp),%rbx
    9e35:	48 f7 da             	neg    %rdx
    9e38:	4d 8d 2c 90          	lea    (%r8,%rdx,4),%r13
    9e3c:	c4 c1 f9 6e fd       	vmovq  %r13,%xmm7
    9e41:	4d 89 c5             	mov    %r8,%r13
    9e44:	c4 61 f9 6e e3       	vmovq  %rbx,%xmm12
    9e49:	44 89 d3             	mov    %r10d,%ebx
    9e4c:	0f 1f 40 00          	nopl   0x0(%rax)
    9e50:	49 63 c1             	movslq %r9d,%rax
    9e53:	c4 61 f9 7e f2       	vmovq  %xmm14,%rdx
    9e58:	c5 f9 7e ef          	vmovd  %xmm5,%edi
    9e5c:	48 8d 34 10          	lea    (%rax,%rdx,1),%rsi
    9e60:	48 29 ee             	sub    %rbp,%rsi
    9e63:	41 03 7c b5 00       	add    0x0(%r13,%rsi,4),%edi
    9e68:	80 7c 24 fa 00       	cmpb   $0x0,-0x6(%rsp)
    9e6d:	0f 84 5d 01 00 00    	je     9fd0 <mj__convex_contacts__graph_support+0x430>
    9e73:	48 01 c8             	add    %rcx,%rax
    9e76:	48 29 e8             	sub    %rbp,%rax
    9e79:	41 8b 74 85 00       	mov    0x0(%r13,%rax,4),%esi
    9e7e:	85 f6                	test   %esi,%esi
    9e80:	8d 86 ff 1f 00 00    	lea    0x1fff(%rsi),%eax
    9e86:	0f 49 c6             	cmovns %esi,%eax
    9e89:	c1 f8 0d             	sar    $0xd,%eax
    9e8c:	8d 44 07 ff          	lea    -0x1(%rdi,%rax,1),%eax
    9e90:	39 f8                	cmp    %edi,%eax
    9e92:	0f 8d 28 02 00 00    	jge    a0c0 <mj__convex_contacts__graph_support+0x520>
    9e98:	48 8b 4c 24 48       	mov    0x48(%rsp),%rcx
    9e9d:	89 f2                	mov    %esi,%edx
    9e9f:	89 d0                	mov    %edx,%eax
    9ea1:	c1 f8 1f             	sar    $0x1f,%eax
    9ea4:	c1 e8 13             	shr    $0x13,%eax
    9ea7:	01 c2                	add    %eax,%edx
    9ea9:	81 e2 ff 1f 00 00    	and    $0x1fff,%edx
    9eaf:	29 c2                	sub    %eax,%edx
    9eb1:	0f 1f 40 00          	nopl   0x0(%rax)
    9eb5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    9ebc:	00 00 00 00 
    9ec0:	8b 44 24 e8          	mov    -0x18(%rsp),%eax
    9ec4:	01 c2                	add    %eax,%edx
    9ec6:	48 63 c2             	movslq %edx,%rax
    9ec9:	4c 29 e0             	sub    %r12,%rax
    9ecc:	48 8d 04 40          	lea    (%rax,%rax,2),%rax
    9ed0:	49 8d 04 c7          	lea    (%r15,%rax,8),%rax
    9ed4:	c5 fb 10 60 08       	vmovsd 0x8(%rax),%xmm4
    9ed9:	c5 fb 10 08          	vmovsd (%rax),%xmm1
    9edd:	c5 fb 10 58 10       	vmovsd 0x10(%rax),%xmm3
    9ee2:	c4 61 f9 7e e8       	vmovq  %xmm13,%rax
    9ee7:	c5 b3 59 c1          	vmulsd %xmm1,%xmm9,%xmm0
    9eeb:	62 e1 cf 00 59 f4    	vmulsd %xmm4,%xmm22,%xmm22
    9ef1:	c5 a3 59 d1          	vmulsd %xmm1,%xmm11,%xmm2
    9ef5:	62 e1 df 00 59 e4    	vmulsd %xmm4,%xmm20,%xmm20
    9efb:	62 e1 ef 00 59 d4    	vmulsd %xmm4,%xmm18,%xmm18
    9f01:	c5 ab 59 c9          	vmulsd %xmm1,%xmm10,%xmm1
    9f05:	c5 d9 57 e4          	vxorpd %xmm4,%xmm4,%xmm4
    9f09:	62 e1 d7 00 59 eb    	vmulsd %xmm3,%xmm21,%xmm21
    9f0f:	62 e1 e7 00 59 db    	vmulsd %xmm3,%xmm19,%xmm19
    9f15:	62 b1 ff 08 58 c6    	vaddsd %xmm22,%xmm0,%xmm0
    9f1b:	62 e1 f7 00 59 cb    	vmulsd %xmm3,%xmm17,%xmm17
    9f21:	62 b1 ef 08 58 d4    	vaddsd %xmm20,%xmm2,%xmm2
    9f27:	62 b1 f7 08 58 ca    	vaddsd %xmm18,%xmm1,%xmm1
    9f2d:	62 b1 ff 08 58 c5    	vaddsd %xmm21,%xmm0,%xmm0
    9f33:	c4 c1 7b 58 06       	vaddsd (%r14),%xmm0,%xmm0
    9f38:	62 b1 ef 08 58 d3    	vaddsd %xmm19,%xmm2,%xmm2
    9f3e:	c4 c1 6b 58 56 08    	vaddsd 0x8(%r14),%xmm2,%xmm2
    9f44:	62 b1 f7 08 58 c9    	vaddsd %xmm17,%xmm1,%xmm1
    9f4a:	c4 c1 73 58 4e 10    	vaddsd 0x10(%r14),%xmm1,%xmm1
    9f50:	c5 fb 11 01          	vmovsd %xmm0,(%rcx)
    9f54:	c5 fb 11 51 08       	vmovsd %xmm2,0x8(%rcx)
    9f59:	c5 fb 11 49 10       	vmovsd %xmm1,0x10(%rcx)
    9f5e:	c5 fb 10 98 80 01 00 	vmovsd 0x180(%rax),%xmm3
    9f65:	00 
    9f66:	c5 f9 2f dc          	vcomisd %xmm4,%xmm3
    9f6a:	76 2d                	jbe    9f99 <mj__convex_contacts__graph_support+0x3f9>
    9f6c:	c4 e1 f9 7e f0       	vmovq  %xmm6,%rax
    9f71:	c5 e3 59 60 08       	vmulsd 0x8(%rax),%xmm3,%xmm4
    9f76:	c5 db 58 e2          	vaddsd %xmm2,%xmm4,%xmm4
    9f7a:	c5 e3 59 50 10       	vmulsd 0x10(%rax),%xmm3,%xmm2
    9f7f:	c5 e3 59 18          	vmulsd (%rax),%xmm3,%xmm3
    9f83:	c5 fb 11 61 08       	vmovsd %xmm4,0x8(%rcx)
    9f88:	c5 eb 58 d1          	vaddsd %xmm1,%xmm2,%xmm2
    9f8c:	c5 e3 58 d8          	vaddsd %xmm0,%xmm3,%xmm3
    9f90:	c5 fb 11 51 10       	vmovsd %xmm2,0x10(%rcx)
    9f95:	c5 fb 11 19          	vmovsd %xmm3,(%rcx)
    9f99:	48 c1 e2 20          	shl    $0x20,%rdx
    9f9d:	44 89 c8             	mov    %r9d,%eax
    9fa0:	5b                   	pop    %rbx
    9fa1:	5d                   	pop    %rbp
    9fa2:	41 5c                	pop    %r12
    9fa4:	48 09 d0             	or     %rdx,%rax
    9fa7:	41 5d                	pop    %r13
    9fa9:	41 5e                	pop    %r14
    9fab:	41 5f                	pop    %r15
    9fad:	c3                   	ret
    9fae:	66 90                	xchg   %ax,%ax
    9fb0:	89 f3                	mov    %esi,%ebx
    9fb2:	45 89 d1             	mov    %r10d,%r9d
    9fb5:	c5 f9 28 c8          	vmovapd %xmm0,%xmm1
    9fb9:	ff cb                	dec    %ebx
    9fbb:	41 89 da             	mov    %ebx,%r10d
    9fbe:	0f 89 2b fe ff ff    	jns    9def <mj__convex_contacts__graph_support+0x24f>
    9fc4:	e9 d6 fe ff ff       	jmp    9e9f <mj__convex_contacts__graph_support+0x2ff>
    9fc9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    9fd0:	80 7c 24 fb 00       	cmpb   $0x0,-0x5(%rsp)
    9fd5:	74 29                	je     a000 <mj__convex_contacts__graph_support+0x460>
    9fd7:	39 7c 24 ec          	cmp    %edi,-0x14(%rsp)
    9fdb:	0f 8d df 01 00 00    	jge    a1c0 <mj__convex_contacts__graph_support+0x620>
    9fe1:	48 89 c2             	mov    %rax,%rdx
    9fe4:	48 01 ca             	add    %rcx,%rdx
    9fe7:	48 8b 4c 24 48       	mov    0x48(%rsp),%rcx
    9fec:	48 29 ea             	sub    %rbp,%rdx
    9fef:	41 8b 54 95 00       	mov    0x0(%r13,%rdx,4),%edx
    9ff4:	e9 c7 fe ff ff       	jmp    9ec0 <mj__convex_contacts__graph_support+0x320>
    9ff9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    a000:	39 7c 24 ec          	cmp    %edi,-0x14(%rsp)
    a004:	7c db                	jl     9fe1 <mj__convex_contacts__graph_support+0x441>
    a006:	4c 63 54 24 ec       	movslq -0x14(%rsp),%r10
    a00b:	48 63 ff             	movslq %edi,%rdi
    a00e:	44 89 4c 24 fc       	mov    %r9d,-0x4(%rsp)
    a013:	44 89 ce             	mov    %r9d,%esi
    a016:	44 89 5c 24 f0       	mov    %r11d,-0x10(%rsp)
    a01b:	8b 54 24 e8          	mov    -0x18(%rsp),%edx
    a01f:	48 ff cf             	dec    %rdi
    a022:	c4 c1 f9 7e f8       	vmovq  %xmm7,%r8
    a027:	4d 89 d1             	mov    %r10,%r9
    a02a:	eb 52                	jmp    a07e <mj__convex_contacts__graph_support+0x4de>
    a02c:	0f 1f 40 00          	nopl   0x0(%rax)
    a030:	44 89 d0             	mov    %r10d,%eax
    a033:	48 01 c8             	add    %rcx,%rax
    a036:	48 29 e8             	sub    %rbp,%rax
    a039:	45 8b 5c 85 00       	mov    0x0(%r13,%rax,4),%r11d
    a03e:	41 01 d3             	add    %edx,%r11d
    a041:	49 63 c3             	movslq %r11d,%rax
    a044:	4c 29 e0             	sub    %r12,%rax
    a047:	48 8d 04 40          	lea    (%rax,%rax,2),%rax
    a04b:	49 8d 04 c7          	lea    (%r15,%rax,8),%rax
    a04f:	62 e1 df 08 59 78 01 	vmulsd 0x8(%rax),%xmm4,%xmm23
    a056:	c5 e3 59 00          	vmulsd (%rax),%xmm3,%xmm0
    a05a:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a060:	62 e1 ef 08 59 78 02 	vmulsd 0x10(%rax),%xmm2,%xmm23
    a067:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a06d:	c5 f9 2f c1          	vcomisd %xmm1,%xmm0
    a071:	c5 fb 5f c9          	vmaxsd %xmm1,%xmm0,%xmm1
    a075:	41 0f 47 f2          	cmova  %r10d,%esi
    a079:	49 39 f9             	cmp    %rdi,%r9
    a07c:	74 0c                	je     a08a <mj__convex_contacts__graph_support+0x4ea>
    a07e:	48 ff c7             	inc    %rdi
    a081:	45 8b 14 b8          	mov    (%r8,%rdi,4),%r10d
    a085:	45 85 d2             	test   %r10d,%r10d
    a088:	79 a6                	jns    a030 <mj__convex_contacts__graph_support+0x490>
    a08a:	44 8b 5c 24 f0       	mov    -0x10(%rsp),%r11d
    a08f:	44 8b 4c 24 fc       	mov    -0x4(%rsp),%r9d
    a094:	41 39 f1             	cmp    %esi,%r9d
    a097:	0f 84 b3 01 00 00    	je     a250 <mj__convex_contacts__graph_support+0x6b0>
    a09d:	41 ff c3             	inc    %r11d
    a0a0:	41 39 db             	cmp    %ebx,%r11d
    a0a3:	0f 84 a7 01 00 00    	je     a250 <mj__convex_contacts__graph_support+0x6b0>
    a0a9:	41 89 f1             	mov    %esi,%r9d
    a0ac:	e9 9f fd ff ff       	jmp    9e50 <mj__convex_contacts__graph_support+0x2b0>
    a0b1:	0f 1f 40 00          	nopl   0x0(%rax)
    a0b5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a0bc:	00 00 00 00 
    a0c0:	48 63 ff             	movslq %edi,%rdi
    a0c3:	48 89 4c 24 f0       	mov    %rcx,-0x10(%rsp)
    a0c8:	c4 41 f9 6e c5       	vmovq  %r13,%xmm8
    a0cd:	44 89 ce             	mov    %r9d,%esi
    a0d0:	48 ff cf             	dec    %rdi
    a0d3:	48 63 d0             	movslq %eax,%rdx
    a0d6:	c4 c1 f9 7e fd       	vmovq  %xmm7,%r13
    a0db:	c4 61 f9 7e e1       	vmovq  %xmm12,%rcx
    a0e0:	48 ff c7             	inc    %rdi
    a0e3:	41 8b 44 bd 00       	mov    0x0(%r13,%rdi,4),%eax
    a0e8:	41 89 c0             	mov    %eax,%r8d
    a0eb:	41 c1 f8 1f          	sar    $0x1f,%r8d
    a0ef:	41 c1 e8 13          	shr    $0x13,%r8d
    a0f3:	46 8d 14 00          	lea    (%rax,%r8,1),%r10d
    a0f7:	41 81 e2 ff 1f 00 00 	and    $0x1fff,%r10d
    a0fe:	45 29 c2             	sub    %r8d,%r10d
    a101:	4d 63 d2             	movslq %r10d,%r10
    a104:	49 01 ca             	add    %rcx,%r10
    a107:	4d 29 e2             	sub    %r12,%r10
    a10a:	4f 8d 14 52          	lea    (%r10,%r10,2),%r10
    a10e:	4f 8d 14 d7          	lea    (%r15,%r10,8),%r10
    a112:	62 c1 e7 08 59 3a    	vmulsd (%r10),%xmm3,%xmm23
    a118:	c4 c1 5b 59 42 08    	vmulsd 0x8(%r10),%xmm4,%xmm0
    a11e:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a124:	62 c1 ef 08 59 7a 02 	vmulsd 0x10(%r10),%xmm2,%xmm23
    a12b:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a131:	c5 f9 2f c1          	vcomisd %xmm1,%xmm0
    a135:	76 12                	jbe    a149 <mj__convex_contacts__graph_support+0x5a9>
    a137:	85 c0                	test   %eax,%eax
    a139:	8d b0 ff 1f 00 00    	lea    0x1fff(%rax),%esi
    a13f:	c5 f9 28 c8          	vmovapd %xmm0,%xmm1
    a143:	0f 49 f0             	cmovns %eax,%esi
    a146:	c1 fe 0d             	sar    $0xd,%esi
    a149:	48 39 fa             	cmp    %rdi,%rdx
    a14c:	75 92                	jne    a0e0 <mj__convex_contacts__graph_support+0x540>
    a14e:	c4 61 f9 6e e1       	vmovq  %rcx,%xmm12
    a153:	c4 41 f9 7e c5       	vmovq  %xmm8,%r13
    a158:	48 8b 4c 24 f0       	mov    -0x10(%rsp),%rcx
    a15d:	e9 32 ff ff ff       	jmp    a094 <mj__convex_contacts__graph_support+0x4f4>
    a162:	0f 1f 00             	nopl   (%rax)
    a165:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    a16c:	00 00 00 00 
    a170:	8b 5c 24 e8          	mov    -0x18(%rsp),%ebx
    a174:	8d 3c 13             	lea    (%rbx,%rdx,1),%edi
    a177:	48 63 ff             	movslq %edi,%rdi
    a17a:	4c 29 e7             	sub    %r12,%rdi
    a17d:	48 8d 3c 7f          	lea    (%rdi,%rdi,2),%rdi
    a181:	49 8d 3c ff          	lea    (%r15,%rdi,8),%rdi
    a185:	c5 db 59 4f 08       	vmulsd 0x8(%rdi),%xmm4,%xmm1
    a18a:	c5 e3 59 07          	vmulsd (%rdi),%xmm3,%xmm0
    a18e:	c5 fb 58 c1          	vaddsd %xmm1,%xmm0,%xmm0
    a192:	c5 eb 59 4f 10       	vmulsd 0x10(%rdi),%xmm2,%xmm1
    a197:	c5 fb 58 c1          	vaddsd %xmm1,%xmm0,%xmm0
    a19b:	45 85 c9             	test   %r9d,%r9d
    a19e:	0f 88 ec 00 00 00    	js     a290 <mj__convex_contacts__graph_support+0x6f0>
    a1a4:	44 89 cf             	mov    %r9d,%edi
    a1a7:	c4 e1 f9 7e eb       	vmovq  %xmm5,%rbx
    a1ac:	48 8d 54 3b 02       	lea    0x2(%rbx,%rdi,1),%rdx
    a1b1:	48 29 c2             	sub    %rax,%rdx
    a1b4:	41 8b 14 90          	mov    (%r8,%rdx,4),%edx
    a1b8:	e9 e6 fb ff ff       	jmp    9da3 <mj__convex_contacts__graph_support+0x203>
    a1bd:	0f 1f 00             	nopl   (%rax)
    a1c0:	48 63 44 24 ec       	movslq -0x14(%rsp),%rax
    a1c5:	48 63 ff             	movslq %edi,%rdi
    a1c8:	44 89 4c 24 f0       	mov    %r9d,-0x10(%rsp)
    a1cd:	44 89 ce             	mov    %r9d,%esi
    a1d0:	4c 63 54 24 e8       	movslq -0x18(%rsp),%r10
    a1d5:	49 89 c9             	mov    %rcx,%r9
    a1d8:	48 8d 57 ff          	lea    -0x1(%rdi),%rdx
    a1dc:	c4 c1 f9 7e f8       	vmovq  %xmm7,%r8
    a1e1:	48 89 c1             	mov    %rax,%rcx
    a1e4:	eb 50                	jmp    a236 <mj__convex_contacts__graph_support+0x696>
    a1e6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    a1ed:	00 00 00 
    a1f0:	89 f8                	mov    %edi,%eax
    a1f2:	25 ff 1f 00 00       	and    $0x1fff,%eax
    a1f7:	4c 01 d0             	add    %r10,%rax
    a1fa:	4c 29 e0             	sub    %r12,%rax
    a1fd:	48 8d 04 40          	lea    (%rax,%rax,2),%rax
    a201:	49 8d 04 c7          	lea    (%r15,%rax,8),%rax
    a205:	62 e1 df 08 59 78 01 	vmulsd 0x8(%rax),%xmm4,%xmm23
    a20c:	c5 e3 59 00          	vmulsd (%rax),%xmm3,%xmm0
    a210:	c1 ff 0d             	sar    $0xd,%edi
    a213:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a219:	62 e1 ef 08 59 78 02 	vmulsd 0x10(%rax),%xmm2,%xmm23
    a220:	62 b1 ff 08 58 c7    	vaddsd %xmm23,%xmm0,%xmm0
    a226:	c5 f9 2f c1          	vcomisd %xmm1,%xmm0
    a22a:	c5 fb 5f c9          	vmaxsd %xmm1,%xmm0,%xmm1
    a22e:	0f 47 f7             	cmova  %edi,%esi
    a231:	48 39 d1             	cmp    %rdx,%rcx
    a234:	74 0b                	je     a241 <mj__convex_contacts__graph_support+0x6a1>
    a236:	48 ff c2             	inc    %rdx
    a239:	41 8b 3c 90          	mov    (%r8,%rdx,4),%edi
    a23d:	85 ff                	test   %edi,%edi
    a23f:	79 af                	jns    a1f0 <mj__convex_contacts__graph_support+0x650>
    a241:	4c 89 c9             	mov    %r9,%rcx
    a244:	44 8b 4c 24 f0       	mov    -0x10(%rsp),%r9d
    a249:	e9 46 fe ff ff       	jmp    a094 <mj__convex_contacts__graph_support+0x4f4>
    a24e:	66 90                	xchg   %ax,%ax
    a250:	48 89 e8             	mov    %rbp,%rax
    a253:	48 63 d6             	movslq %esi,%rdx
    a256:	48 89 cd             	mov    %rcx,%rbp
    a259:	48 8b 4c 24 48       	mov    0x48(%rsp),%rcx
    a25e:	48 01 ea             	add    %rbp,%rdx
    a261:	48 29 c2             	sub    %rax,%rdx
    a264:	41 8b 54 95 00       	mov    0x0(%r13,%rdx,4),%edx
    a269:	41 89 f1             	mov    %esi,%r9d
    a26c:	80 7c 24 fa 00       	cmpb   $0x0,-0x6(%rsp)
    a271:	0f 85 28 fc ff ff    	jne    9e9f <mj__convex_contacts__graph_support+0x2ff>
    a277:	e9 44 fc ff ff       	jmp    9ec0 <mj__convex_contacts__graph_support+0x320>
    a27c:	0f 1f 40 00          	nopl   0x0(%rax)
    a280:	48 01 ef             	add    %rbp,%rdi
    a283:	44 89 ce             	mov    %r9d,%esi
    a286:	48 29 c7             	sub    %rax,%rdi
    a289:	41 8b 14 b8          	mov    (%r8,%rdi,4),%edx
    a28d:	eb da                	jmp    a269 <mj__convex_contacts__graph_support+0x6c9>
    a28f:	90                   	nop
    a290:	89 f3                	mov    %esi,%ebx
    a292:	45 89 d1             	mov    %r10d,%r9d
    a295:	c5 f9 28 c8          	vmovapd %xmm0,%xmm1
    a299:	ff cb                	dec    %ebx
    a29b:	41 89 da             	mov    %ebx,%r10d
    a29e:	0f 89 4b fb ff ff    	jns    9def <mj__convex_contacts__graph_support+0x24f>
    a2a4:	e9 17 fc ff ff       	jmp    9ec0 <mj__convex_contacts__graph_support+0x320>

Disassembly of section .fini:
