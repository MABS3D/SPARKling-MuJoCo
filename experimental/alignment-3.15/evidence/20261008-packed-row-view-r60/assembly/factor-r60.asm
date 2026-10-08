
/var/tmp/sparkling-alignment-315-packed-native-r60-20261008/build/release/bin/packed_cholesky_probe:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

000000000001a630 <mj__constraint_solvers__packed_cholesky__factor>:
   1a630:	55                   	push   %rbp
   1a631:	48 89 e5             	mov    %rsp,%rbp
   1a634:	41 57                	push   %r15
   1a636:	41 56                	push   %r14
   1a638:	41 55                	push   %r13
   1a63a:	41 54                	push   %r12
   1a63c:	53                   	push   %rbx
   1a63d:	49 89 d4             	mov    %rdx,%r12
   1a640:	31 db                	xor    %ebx,%ebx
   1a642:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
   1a649:	48 8b 45 18          	mov    0x18(%rbp),%rax
   1a64d:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
   1a654:	4c 63 32             	movslq (%rdx),%r14
   1a657:	4c 8b 4d 10          	mov    0x10(%rbp),%r9
   1a65b:	48 89 bd 50 ff ff ff 	mov    %rdi,-0xb0(%rbp)
   1a662:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
   1a666:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
   1a66d:	c5 fb 11 45 88       	vmovsd %xmm0,-0x78(%rbp)
   1a672:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
   1a679:	8b 00                	mov    (%rax),%eax
   1a67b:	44 89 75 c8          	mov    %r14d,-0x38(%rbp)
   1a67f:	4c 89 4d c0          	mov    %r9,-0x40(%rbp)
   1a683:	89 45 b8             	mov    %eax,-0x48(%rbp)
   1a686:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   1a68d:	48 63 78 08          	movslq 0x8(%rax),%rdi
   1a691:	44 8b 38             	mov    (%rax),%r15d
   1a694:	44 8b 68 04          	mov    0x4(%rax),%r13d
   1a698:	48 89 7d 90          	mov    %rdi,-0x70(%rbp)
   1a69c:	48 63 40 0c          	movslq 0xc(%rax),%rax
   1a6a0:	48 89 c2             	mov    %rax,%rdx
   1a6a3:	48 29 f8             	sub    %rdi,%rax
   1a6a6:	48 8d 04 c5 08 00 00 	lea    0x8(,%rax,8),%rax
   1a6ad:	00 
   1a6ae:	39 d7                	cmp    %edx,%edi
   1a6b0:	4a 8d 14 f5 00 00 00 	lea    0x0(,%r14,8),%rdx
   1a6b7:	00 
   1a6b8:	48 0f 4f c3          	cmovg  %rbx,%rax
   1a6bc:	31 f6                	xor    %esi,%esi
   1a6be:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
   1a6c5:	4a 8d 04 f5 0f 00 00 	lea    0xf(,%r14,8),%rax
   1a6cc:	00 
   1a6cd:	48 83 e0 f0          	and    $0xfffffffffffffff0,%rax
   1a6d1:	48 29 c4             	sub    %rax,%rsp
   1a6d4:	48 89 e7             	mov    %rsp,%rdi
   1a6d7:	e8 74 9e fe ff       	call   4550 <memset@plt>
   1a6dc:	44 8b 55 c8          	mov    -0x38(%rbp),%r10d
   1a6e0:	4c 8b 4d c0          	mov    -0x40(%rbp),%r9
   1a6e4:	45 85 d2             	test   %r10d,%r10d
   1a6e7:	0f 8e 14 0a 00 00    	jle    1b101 <mj__constraint_solvers__packed_cholesky__factor+0xad1>
   1a6ed:	48 63 45 b8          	movslq -0x48(%rbp),%rax
   1a6f1:	41 83 ff 01          	cmp    $0x1,%r15d
   1a6f5:	44 89 95 5c ff ff ff 	mov    %r10d,-0xa4(%rbp)
   1a6fc:	4c 89 4d 80          	mov    %r9,-0x80(%rbp)
   1a700:	48 89 e3             	mov    %rsp,%rbx
   1a703:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
   1a70a:	49 8d 46 01          	lea    0x1(%r14),%rax
   1a70e:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
   1a712:	49 63 c7             	movslq %r15d,%rax
   1a715:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
   1a71c:	0f 9f c0             	setg   %al
   1a71f:	45 39 ea             	cmp    %r13d,%r10d
   1a722:	45 89 d5             	mov    %r10d,%r13d
   1a725:	0f 9f c2             	setg   %dl
   1a728:	09 d0                	or     %edx,%eax
   1a72a:	88 85 5b ff ff ff    	mov    %al,-0xa5(%rbp)
   1a730:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1a734:	48 89 45 98          	mov    %rax,-0x68(%rbp)
   1a738:	48 ff c8             	dec    %rax
   1a73b:	41 8b 34 84          	mov    (%r12,%rax,4),%esi
   1a73f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
   1a743:	85 f6                	test   %esi,%esi
   1a745:	0f 88 a5 09 00 00    	js     1b0f0 <mj__constraint_solvers__packed_cholesky__factor+0xac0>
   1a74b:	49 63 04 24          	movslq (%r12),%rax
   1a74f:	49 89 c0             	mov    %rax,%r8
   1a752:	c4 e1 f9 6e e0       	vmovq  %rax,%xmm4
   1a757:	0f 85 e3 03 00 00    	jne    1ab40 <mj__constraint_solvers__packed_cholesky__factor+0x510>
   1a75d:	c4 e1 f9 7e e0       	vmovq  %xmm4,%rax
   1a762:	48 bf ff ff ff ff ff 	movabs $0x3fffffffffffffff,%rdi
   1a769:	ff ff 3f 
   1a76c:	48 ff c0             	inc    %rax
   1a76f:	48 21 f8             	and    %rdi,%rax
   1a772:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
   1a776:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
   1a77b:	41 8b 34 84          	mov    (%r12,%rax,4),%esi
   1a77f:	85 f6                	test   %esi,%esi
   1a781:	0f 88 58 09 00 00    	js     1b0df <mj__constraint_solvers__packed_cholesky__factor+0xaaf>
   1a787:	83 fe 01             	cmp    $0x1,%esi
   1a78a:	0f 8f 10 01 00 00    	jg     1a8a0 <mj__constraint_solvers__packed_cholesky__factor+0x270>
   1a790:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1a794:	c5 fb 10 7d 88       	vmovsd -0x78(%rbp),%xmm7
   1a799:	c5 fb 10 4c c3 f8    	vmovsd -0x8(%rbx,%rax,8),%xmm1
   1a79f:	c5 f9 2f f9          	vcomisd %xmm1,%xmm7
   1a7a3:	0f 86 e5 04 00 00    	jbe    1ac8e <mj__constraint_solvers__packed_cholesky__factor+0x65e>
   1a7a9:	ff 8d 5c ff ff ff    	decl   -0xa4(%rbp)
   1a7af:	0f 88 19 09 00 00    	js     1b0ce <mj__constraint_solvers__packed_cholesky__factor+0xa9e>
   1a7b5:	c5 f9 28 c7          	vmovapd %xmm7,%xmm0
   1a7b9:	c5 fb 11 4d c0       	vmovsd %xmm1,-0x40(%rbp)
   1a7be:	e8 4d ff fe ff       	call   a710 <mj__quaternion_math__sqrt>
   1a7c3:	c5 f9 2e 05 95 e5 05 	vucomisd 0x5e595(%rip),%xmm0        # 78d60 <_IO_stdin_used+0x22a0>
   1a7ca:	00 
   1a7cb:	0f 82 0d 08 00 00    	jb     1afde <mj__constraint_solvers__packed_cholesky__factor+0x9ae>
   1a7d1:	c5 fb 10 35 8f e5 05 	vmovsd 0x5e58f(%rip),%xmm6        # 78d68 <_IO_stdin_used+0x22a8>
   1a7d8:	00 
   1a7d9:	c5 f9 2e f0          	vucomisd %xmm0,%xmm6
   1a7dd:	0f 82 fb 07 00 00    	jb     1afde <mj__constraint_solvers__packed_cholesky__factor+0x9ae>
   1a7e3:	48 8b b5 70 ff ff ff 	mov    -0x90(%rbp),%rsi
   1a7ea:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
   1a7ee:	48 63 06             	movslq (%rsi),%rax
   1a7f1:	39 f8                	cmp    %edi,%eax
   1a7f3:	0f 8f 80 08 00 00    	jg     1b079 <mj__constraint_solvers__packed_cholesky__factor+0xa49>
   1a7f9:	39 7e 04             	cmp    %edi,0x4(%rsi)
   1a7fc:	0f 8c 77 08 00 00    	jl     1b079 <mj__constraint_solvers__packed_cholesky__factor+0xa49>
   1a802:	48 89 fa             	mov    %rdi,%rdx
   1a805:	48 29 c2             	sub    %rax,%rdx
   1a808:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
   1a80c:	31 c9                	xor    %ecx,%ecx
   1a80e:	44 8b 14 90          	mov    (%rax,%rdx,4),%r10d
   1a812:	44 89 d0             	mov    %r10d,%eax
   1a815:	83 c0 01             	add    $0x1,%eax
   1a818:	0f 90 c1             	seto   %cl
   1a81b:	85 c9                	test   %ecx,%ecx
   1a81d:	0f 85 34 08 00 00    	jne    1b057 <mj__constraint_solvers__packed_cholesky__factor+0xa27>
   1a823:	41 8b 14 bc          	mov    (%r12,%rdi,4),%edx
   1a827:	8d 72 ff             	lea    -0x1(%rdx),%esi
   1a82a:	85 f6                	test   %esi,%esi
   1a82c:	0f 8f f5 03 00 00    	jg     1ac27 <mj__constraint_solvers__packed_cholesky__factor+0x5f7>
   1a832:	85 d2                	test   %edx,%edx
   1a834:	0f 8e 50 08 00 00    	jle    1b08a <mj__constraint_solvers__packed_cholesky__factor+0xa5a>
   1a83a:	89 d1                	mov    %edx,%ecx
   1a83c:	44 01 d1             	add    %r10d,%ecx
   1a83f:	0f 80 12 08 00 00    	jo     1b057 <mj__constraint_solvers__packed_cholesky__factor+0xa27>
   1a845:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   1a84c:	8b 38                	mov    (%rax),%edi
   1a84e:	89 7d b8             	mov    %edi,-0x48(%rbp)
   1a851:	39 cf                	cmp    %ecx,%edi
   1a853:	0f 8f fa 08 00 00    	jg     1b153 <mj__constraint_solvers__packed_cholesky__factor+0xb23>
   1a859:	39 48 04             	cmp    %ecx,0x4(%rax)
   1a85c:	0f 8c f1 08 00 00    	jl     1b153 <mj__constraint_solvers__packed_cholesky__factor+0xb23>
   1a862:	48 8b 45 80          	mov    -0x80(%rbp),%rax
   1a866:	48 63 d1             	movslq %ecx,%rdx
   1a869:	48 2b 95 68 ff ff ff 	sub    -0x98(%rbp),%rdx
   1a870:	c5 fb 11 04 d0       	vmovsd %xmm0,(%rax,%rdx,8)
   1a875:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1a879:	41 8b 0c 84          	mov    (%r12,%rax,4),%ecx
   1a87d:	85 c9                	test   %ecx,%ecx
   1a87f:	0f 88 bd 08 00 00    	js     1b142 <mj__constraint_solvers__packed_cholesky__factor+0xb12>
   1a885:	0f 85 df 05 00 00    	jne    1ae6a <mj__constraint_solvers__packed_cholesky__factor+0x83a>
   1a88b:	48 83 7d c8 01       	cmpq   $0x1,-0x38(%rbp)
   1a890:	0f 85 9a fe ff ff    	jne    1a730 <mj__constraint_solvers__packed_cholesky__factor+0x100>
   1a896:	31 c0                	xor    %eax,%eax
   1a898:	e9 46 07 00 00       	jmp    1afe3 <mj__constraint_solvers__packed_cholesky__factor+0x9b3>
   1a89d:	0f 1f 00             	nopl   (%rax)
   1a8a0:	44 39 c6             	cmp    %r8d,%esi
   1a8a3:	0f 9f 45 c0          	setg   -0x40(%rbp)
   1a8a7:	41 83 f8 01          	cmp    $0x1,%r8d
   1a8ab:	0f 9e c0             	setle  %al
   1a8ae:	84 45 c0             	test   %al,-0x40(%rbp)
   1a8b1:	0f 85 7a 08 00 00    	jne    1b131 <mj__constraint_solvers__packed_cholesky__factor+0xb01>
   1a8b7:	c4 e1 f9 7e e0       	vmovq  %xmm4,%rax
   1a8bc:	4c 8d 5f ff          	lea    -0x1(%rdi),%r11
   1a8c0:	c4 e1 f9 7e e1       	vmovq  %xmm4,%rcx
   1a8c5:	49 89 fa             	mov    %rdi,%r10
   1a8c8:	4c 8d 34 c5 00 00 00 	lea    0x0(,%rax,8),%r14
   1a8cf:	00 
   1a8d0:	48 0f af c0          	imul   %rax,%rax
   1a8d4:	49 0f af cb          	imul   %r11,%rcx
   1a8d8:	48 c1 e0 02          	shl    $0x2,%rax
   1a8dc:	4a 8d 54 30 04       	lea    0x4(%rax,%r14,1),%rdx
   1a8e1:	48 c1 ea 02          	shr    $0x2,%rdx
   1a8e5:	49 89 d1             	mov    %rdx,%r9
   1a8e8:	48 8d 54 0a 01       	lea    0x1(%rdx,%rcx,1),%rdx
   1a8ed:	41 8b 14 94          	mov    (%r12,%rdx,4),%edx
   1a8f1:	85 d2                	test   %edx,%edx
   1a8f3:	0f 8e 27 08 00 00    	jle    1b120 <mj__constraint_solvers__packed_cholesky__factor+0xaf0>
   1a8f9:	49 8d 44 46 04       	lea    0x4(%r14,%rax,2),%rax
   1a8fe:	48 c1 e8 02          	shr    $0x2,%rax
   1a902:	49 89 c3             	mov    %rax,%r11
   1a905:	48 8d 44 08 01       	lea    0x1(%rax,%rcx,1),%rax
   1a90a:	41 8b 04 84          	mov    (%r12,%rax,4),%eax
   1a90e:	85 c0                	test   %eax,%eax
   1a910:	0f 8e 0a 08 00 00    	jle    1b120 <mj__constraint_solvers__packed_cholesky__factor+0xaf0>
   1a916:	44 89 c1             	mov    %r8d,%ecx
   1a919:	44 29 d1             	sub    %r10d,%ecx
   1a91c:	8d b9 00 00 00 01    	lea    0x1000000(%rcx),%edi
   1a922:	81 ff ff ff ff 01    	cmp    $0x1ffffff,%edi
   1a928:	0f 87 dd 01 00 00    	ja     1ab0b <mj__constraint_solvers__packed_cholesky__factor+0x4db>
   1a92e:	48 8b bd 70 ff ff ff 	mov    -0x90(%rbp),%rdi
   1a935:	4c 8b bd 78 ff ff ff 	mov    -0x88(%rbp),%r15
   1a93c:	c1 e1 07             	shl    $0x7,%ecx
   1a93f:	49 c1 ee 02          	shr    $0x2,%r14
   1a943:	44 8b 57 04          	mov    0x4(%rdi),%r10d
   1a947:	48 63 3f             	movslq (%rdi),%rdi
   1a94a:	45 8b 7f 04          	mov    0x4(%r15),%r15d
   1a94e:	89 4d a0             	mov    %ecx,-0x60(%rbp)
   1a951:	83 c1 02             	add    $0x2,%ecx
   1a954:	c4 e1 f9 6e ff       	vmovq  %rdi,%xmm7
   1a959:	89 7d a8             	mov    %edi,-0x58(%rbp)
   1a95c:	8d 7e 01             	lea    0x1(%rsi),%edi
   1a95f:	48 8b 75 98          	mov    -0x68(%rbp),%rsi
   1a963:	c4 e1 f9 6e ef       	vmovq  %rdi,%xmm5
   1a968:	c4 e1 f9 7e e7       	vmovq  %xmm4,%rdi
   1a96d:	44 89 55 bc          	mov    %r10d,-0x44(%rbp)
   1a971:	4c 63 55 b8          	movslq -0x48(%rbp),%r10
   1a975:	44 89 7d a4          	mov    %r15d,-0x5c(%rbp)
   1a979:	4c 89 75 98          	mov    %r14,-0x68(%rbp)
   1a97d:	48 83 ee 02          	sub    $0x2,%rsi
   1a981:	48 0f af f7          	imul   %rdi,%rsi
   1a985:	4d 89 d6             	mov    %r10,%r14
   1a988:	49 8d 3c 31          	lea    (%r9,%rsi,1),%rdi
   1a98c:	4c 01 de             	add    %r11,%rsi
   1a98f:	4c 8b 5d 80          	mov    -0x80(%rbp),%r11
   1a993:	4d 8d 0c bc          	lea    (%r12,%rdi,4),%r9
   1a997:	49 8d 3c b4          	lea    (%r12,%rsi,4),%rdi
   1a99b:	89 c6                	mov    %eax,%esi
   1a99d:	c4 e1 f9 7e f8       	vmovq  %xmm7,%rax
   1a9a2:	c4 e1 f9 6e d7       	vmovq  %rdi,%xmm2
   1a9a7:	c4 c1 f9 6e f9       	vmovq  %r9,%xmm7
   1a9ac:	bf 03 00 00 00       	mov    $0x3,%edi
   1a9b1:	49 89 c1             	mov    %rax,%r9
   1a9b4:	90                   	nop
   1a9b5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1a9bc:	00 00 00 00 
   1a9c0:	85 c9                	test   %ecx,%ecx
   1a9c2:	0f 8e e4 06 00 00    	jle    1b0ac <mj__constraint_solvers__packed_cholesky__factor+0xa7c>
   1a9c8:	39 55 a8             	cmp    %edx,-0x58(%rbp)
   1a9cb:	0f 8f a8 06 00 00    	jg     1b079 <mj__constraint_solvers__packed_cholesky__factor+0xa49>
   1a9d1:	39 55 bc             	cmp    %edx,-0x44(%rbp)
   1a9d4:	0f 8c 9f 06 00 00    	jl     1b079 <mj__constraint_solvers__packed_cholesky__factor+0xa49>
   1a9da:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
   1a9de:	41 89 d7             	mov    %edx,%r15d
   1a9e1:	4c 89 f8             	mov    %r15,%rax
   1a9e4:	4c 29 c8             	sub    %r9,%rax
   1a9e7:	8b 04 81             	mov    (%rcx,%rax,4),%eax
   1a9ea:	89 c1                	mov    %eax,%ecx
   1a9ec:	83 c1 01             	add    $0x1,%ecx
   1a9ef:	0f 80 62 06 00 00    	jo     1b057 <mj__constraint_solvers__packed_cholesky__factor+0xa27>
   1a9f5:	01 c6                	add    %eax,%esi
   1a9f7:	0f 80 5a 06 00 00    	jo     1b057 <mj__constraint_solvers__packed_cholesky__factor+0xa27>
   1a9fd:	39 ce                	cmp    %ecx,%esi
   1a9ff:	0f 8c 1b 01 00 00    	jl     1ab20 <mj__constraint_solvers__packed_cholesky__factor+0x4f0>
   1aa05:	39 4d b8             	cmp    %ecx,-0x48(%rbp)
   1aa08:	0f 8f 8d 06 00 00    	jg     1b09b <mj__constraint_solvers__packed_cholesky__factor+0xa6b>
   1aa0e:	39 75 a4             	cmp    %esi,-0x5c(%rbp)
   1aa11:	0f 8c 84 06 00 00    	jl     1b09b <mj__constraint_solvers__packed_cholesky__factor+0xa6b>
   1aa17:	41 39 d0             	cmp    %edx,%r8d
   1aa1a:	0f 8c 9c 05 00 00    	jl     1afbc <mj__constraint_solvers__packed_cholesky__factor+0x98c>
   1aa20:	c4 c1 f9 7e e2       	vmovq  %xmm4,%r10
   1aa25:	49 ff cf             	dec    %r15
   1aa28:	48 63 c6             	movslq %esi,%rax
   1aa2b:	48 63 d1             	movslq %ecx,%rdx
   1aa2e:	4d 0f af fa          	imul   %r10,%r15
   1aa32:	4c 8b 55 98          	mov    -0x68(%rbp),%r10
   1aa36:	4c 29 f0             	sub    %r14,%rax
   1aa39:	c4 c1 7b 10 1c c3    	vmovsd (%r11,%rax,8),%xmm3
   1aa3f:	b8 01 00 00 00       	mov    $0x1,%eax
   1aa44:	4f 8d 54 17 01       	lea    0x1(%r15,%r10,1),%r10
   1aa49:	eb 31                	jmp    1aa7c <mj__constraint_solvers__packed_cholesky__factor+0x44c>
   1aa4b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   1aa50:	8d 42 01             	lea    0x1(%rdx),%eax
   1aa53:	29 c8                	sub    %ecx,%eax
   1aa55:	0f 80 72 05 00 00    	jo     1afcd <mj__constraint_solvers__packed_cholesky__factor+0x99d>
   1aa5b:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
   1aa60:	0f 84 67 05 00 00    	je     1afcd <mj__constraint_solvers__packed_cholesky__factor+0x99d>
   1aa66:	ff c0                	inc    %eax
   1aa68:	85 c0                	test   %eax,%eax
   1aa6a:	0f 8e a3 05 00 00    	jle    1b013 <mj__constraint_solvers__packed_cholesky__factor+0x9e3>
   1aa70:	48 ff c2             	inc    %rdx
   1aa73:	44 39 c0             	cmp    %r8d,%eax
   1aa76:	0f 8f 40 05 00 00    	jg     1afbc <mj__constraint_solvers__packed_cholesky__factor+0x98c>
   1aa7c:	4a 8d 44 10 ff       	lea    -0x1(%rax,%r10,1),%rax
   1aa81:	41 8b 04 84          	mov    (%r12,%rax,4),%eax
   1aa85:	85 c0                	test   %eax,%eax
   1aa87:	0f 8e 97 05 00 00    	jle    1b024 <mj__constraint_solvers__packed_cholesky__factor+0x9f4>
   1aa8d:	41 39 c5             	cmp    %eax,%r13d
   1aa90:	0f 8c 6c 05 00 00    	jl     1b002 <mj__constraint_solvers__packed_cholesky__factor+0x9d2>
   1aa96:	49 89 d7             	mov    %rdx,%r15
   1aa99:	4d 29 f7             	sub    %r14,%r15
   1aa9c:	48 ff c8             	dec    %rax
   1aa9f:	c4 81 63 59 0c fb    	vmulsd (%r11,%r15,8),%xmm3,%xmm1
   1aaa5:	c5 fb 10 04 c3       	vmovsd (%rbx,%rax,8),%xmm0
   1aaaa:	c5 fb 5c c1          	vsubsd %xmm1,%xmm0,%xmm0
   1aaae:	c5 fb 11 04 c3       	vmovsd %xmm0,(%rbx,%rax,8)
   1aab3:	39 d6                	cmp    %edx,%esi
   1aab5:	75 99                	jne    1aa50 <mj__constraint_solvers__packed_cholesky__factor+0x420>
   1aab7:	c4 e1 f9 7e e8       	vmovq  %xmm5,%rax
   1aabc:	48 39 c7             	cmp    %rax,%rdi
   1aabf:	0f 84 cb fc ff ff    	je     1a790 <mj__constraint_solvers__packed_cholesky__factor+0x160>
   1aac5:	41 39 f8             	cmp    %edi,%r8d
   1aac8:	0f 9c c0             	setl   %al
   1aacb:	84 45 c0             	test   %al,-0x40(%rbp)
   1aace:	0f 85 5d 06 00 00    	jne    1b131 <mj__constraint_solvers__packed_cholesky__factor+0xb01>
   1aad4:	c4 e1 f9 7e f8       	vmovq  %xmm7,%rax
   1aad9:	8b 54 b8 fc          	mov    -0x4(%rax,%rdi,4),%edx
   1aadd:	85 d2                	test   %edx,%edx
   1aadf:	0f 8e 3b 06 00 00    	jle    1b120 <mj__constraint_solvers__packed_cholesky__factor+0xaf0>
   1aae5:	c4 e1 f9 7e d0       	vmovq  %xmm2,%rax
   1aaea:	8b 74 b8 fc          	mov    -0x4(%rax,%rdi,4),%esi
   1aaee:	85 f6                	test   %esi,%esi
   1aaf0:	0f 8e 2a 06 00 00    	jle    1b120 <mj__constraint_solvers__packed_cholesky__factor+0xaf0>
   1aaf6:	8b 4d a0             	mov    -0x60(%rbp),%ecx
   1aaf9:	31 c0                	xor    %eax,%eax
   1aafb:	01 f9                	add    %edi,%ecx
   1aafd:	0f 90 c0             	seto   %al
   1ab00:	48 ff c7             	inc    %rdi
   1ab03:	85 c0                	test   %eax,%eax
   1ab05:	0f 84 b5 fe ff ff    	je     1a9c0 <mj__constraint_solvers__packed_cholesky__factor+0x390>
   1ab0b:	be ea 00 00 00       	mov    $0xea,%esi
   1ab10:	48 8d 3d f1 01 06 00 	lea    0x601f1(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1ab17:	e8 08 2c 02 00       	call   3d724 <__gnat_rcheck_CE_Overflow_Check>
   1ab1c:	0f 1f 40 00          	nopl   0x0(%rax)
   1ab20:	39 75 b8             	cmp    %esi,-0x48(%rbp)
   1ab23:	7f 05                	jg     1ab2a <mj__constraint_solvers__packed_cholesky__factor+0x4fa>
   1ab25:	39 75 a4             	cmp    %esi,-0x5c(%rbp)
   1ab28:	7d 8d                	jge    1aab7 <mj__constraint_solvers__packed_cholesky__factor+0x487>
   1ab2a:	be c0 00 00 00       	mov    $0xc0,%esi
   1ab2f:	48 8d 3d d2 01 06 00 	lea    0x601d2(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1ab36:	e8 7b 2b 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1ab3b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
   1ab40:	48 8b bd 60 ff ff ff 	mov    -0xa0(%rbp),%rdi
   1ab47:	48 c1 e0 03          	shl    $0x3,%rax
   1ab4b:	44 8b 4f 08          	mov    0x8(%rdi),%r9d
   1ab4f:	44 8b 57 0c          	mov    0xc(%rdi),%r10d
   1ab53:	80 bd 5b ff ff ff 00 	cmpb   $0x0,-0xa5(%rbp)
   1ab5a:	0f 85 37 01 00 00    	jne    1ac97 <mj__constraint_solvers__packed_cholesky__factor+0x667>
   1ab60:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
   1ab64:	44 89 4d c0          	mov    %r9d,-0x40(%rbp)
   1ab68:	44 89 55 bc          	mov    %r10d,-0x44(%rbp)
   1ab6c:	4c 8b 8d 50 ff ff ff 	mov    -0xb0(%rbp),%r9
   1ab73:	4d 89 e2             	mov    %r12,%r10
   1ab76:	ba 01 00 00 00       	mov    $0x1,%edx
   1ab7b:	48 c1 e8 02          	shr    $0x2,%rax
   1ab7f:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
   1ab83:	49 89 dc             	mov    %rbx,%r12
   1ab86:	89 f3                	mov    %esi,%ebx
   1ab88:	49 8d 4e ff          	lea    -0x1(%r14),%rcx
   1ab8c:	4c 89 f0             	mov    %r14,%rax
   1ab8f:	48 2b 85 48 ff ff ff 	sub    -0xb8(%rbp),%rax
   1ab96:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
   1ab9a:	49 0f af c8          	imul   %r8,%rcx
   1ab9e:	49 89 ce             	mov    %rcx,%r14
   1aba1:	48 8b 8d 40 ff ff ff 	mov    -0xc0(%rbp),%rcx
   1aba8:	49 89 c3             	mov    %rax,%r11
   1abab:	48 c1 e9 03          	shr    $0x3,%rcx
   1abaf:	4c 0f af d9          	imul   %rcx,%r11
   1abb3:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
   1abb7:	4d 89 df             	mov    %r11,%r15
   1abba:	eb 07                	jmp    1abc3 <mj__constraint_solvers__packed_cholesky__factor+0x593>
   1abbc:	0f 1f 40 00          	nopl   0x0(%rax)
   1abc0:	48 ff c2             	inc    %rdx
   1abc3:	89 d0                	mov    %edx,%eax
   1abc5:	39 d6                	cmp    %edx,%esi
   1abc7:	0f 4e c6             	cmovle %esi,%eax
   1abca:	44 39 c0             	cmp    %r8d,%eax
   1abcd:	0f 8f 86 02 00 00    	jg     1ae59 <mj__constraint_solvers__packed_cholesky__factor+0x829>
   1abd3:	4a 8d 04 32          	lea    (%rdx,%r14,1),%rax
   1abd7:	48 01 f8             	add    %rdi,%rax
   1abda:	41 8b 04 82          	mov    (%r10,%rax,4),%eax
   1abde:	85 c0                	test   %eax,%eax
   1abe0:	0f 8e 4f 04 00 00    	jle    1b035 <mj__constraint_solvers__packed_cholesky__factor+0xa05>
   1abe6:	41 39 c5             	cmp    %eax,%r13d
   1abe9:	0f 8c 6a 02 00 00    	jl     1ae59 <mj__constraint_solvers__packed_cholesky__factor+0x829>
   1abef:	39 45 c0             	cmp    %eax,-0x40(%rbp)
   1abf2:	0f 8f 61 02 00 00    	jg     1ae59 <mj__constraint_solvers__packed_cholesky__factor+0x829>
   1abf8:	39 45 bc             	cmp    %eax,-0x44(%rbp)
   1abfb:	0f 8c 58 02 00 00    	jl     1ae59 <mj__constraint_solvers__packed_cholesky__factor+0x829>
   1ac01:	49 89 c3             	mov    %rax,%r11
   1ac04:	49 29 cb             	sub    %rcx,%r11
   1ac07:	4d 01 fb             	add    %r15,%r11
   1ac0a:	c4 81 7b 10 04 d9    	vmovsd (%r9,%r11,8),%xmm0
   1ac10:	c4 c1 7b 11 44 c4 f8 	vmovsd %xmm0,-0x8(%r12,%rax,8)
   1ac17:	48 39 da             	cmp    %rbx,%rdx
   1ac1a:	75 a4                	jne    1abc0 <mj__constraint_solvers__packed_cholesky__factor+0x590>
   1ac1c:	4c 89 e3             	mov    %r12,%rbx
   1ac1f:	4d 89 d4             	mov    %r10,%r12
   1ac22:	e9 36 fb ff ff       	jmp    1a75d <mj__constraint_solvers__packed_cholesky__factor+0x12d>
   1ac27:	4c 8b 8d 78 ff ff ff 	mov    -0x88(%rbp),%r9
   1ac2e:	c5 fb 10 6d 88       	vmovsd -0x78(%rbp),%xmm5
   1ac33:	c5 f9 2f 6d c0       	vcomisd -0x40(%rbp),%xmm5
   1ac38:	41 8b 39             	mov    (%r9),%edi
   1ac3b:	45 8b 41 04          	mov    0x4(%r9),%r8d
   1ac3f:	0f 86 2b 01 00 00    	jbe    1ad70 <mj__constraint_solvers__packed_cholesky__factor+0x740>
   1ac45:	4c 8b 8d 68 ff ff ff 	mov    -0x98(%rbp),%r9
   1ac4c:	4c 8b 75 80          	mov    -0x80(%rbp),%r14
   1ac50:	ff c1                	inc    %ecx
   1ac52:	89 ca                	mov    %ecx,%edx
   1ac54:	01 c2                	add    %eax,%edx
   1ac56:	0f 80 61 04 00 00    	jo     1b0bd <mj__constraint_solvers__packed_cholesky__factor+0xa8d>
   1ac5c:	ff ca                	dec    %edx
   1ac5e:	39 d7                	cmp    %edx,%edi
   1ac60:	0f 8f e0 03 00 00    	jg     1b046 <mj__constraint_solvers__packed_cholesky__factor+0xa16>
   1ac66:	41 39 d0             	cmp    %edx,%r8d
   1ac69:	0f 8c d7 03 00 00    	jl     1b046 <mj__constraint_solvers__packed_cholesky__factor+0xa16>
   1ac6f:	48 63 d2             	movslq %edx,%rdx
   1ac72:	4c 29 ca             	sub    %r9,%rdx
   1ac75:	49 c7 04 d6 00 00 00 	movq   $0x0,(%r14,%rdx,8)
   1ac7c:	00 
   1ac7d:	39 ce                	cmp    %ecx,%esi
   1ac7f:	75 cf                	jne    1ac50 <mj__constraint_solvers__packed_cholesky__factor+0x620>
   1ac81:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1ac85:	41 8b 14 84          	mov    (%r12,%rax,4),%edx
   1ac89:	e9 a4 fb ff ff       	jmp    1a832 <mj__constraint_solvers__packed_cholesky__factor+0x202>
   1ac8e:	c5 f9 28 c1          	vmovapd %xmm1,%xmm0
   1ac92:	e9 22 fb ff ff       	jmp    1a7b9 <mj__constraint_solvers__packed_cholesky__factor+0x189>
   1ac97:	48 89 f9             	mov    %rdi,%rcx
   1ac9a:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
   1ac9e:	39 39                	cmp    %edi,(%rcx)
   1aca0:	0f 8f 8a 01 00 00    	jg     1ae30 <mj__constraint_solvers__packed_cholesky__factor+0x800>
   1aca6:	39 79 04             	cmp    %edi,0x4(%rcx)
   1aca9:	0f 8c 81 01 00 00    	jl     1ae30 <mj__constraint_solvers__packed_cholesky__factor+0x800>
   1acaf:	48 8d 57 ff          	lea    -0x1(%rdi),%rdx
   1acb3:	c4 c1 f9 6e ec       	vmovq  %r12,%xmm5
   1acb8:	b9 01 00 00 00       	mov    $0x1,%ecx
   1acbd:	49 89 dc             	mov    %rbx,%r12
   1acc0:	49 0f af d0          	imul   %r8,%rdx
   1acc4:	89 f3                	mov    %esi,%ebx
   1acc6:	48 c1 e8 02          	shr    $0x2,%rax
   1acca:	49 89 d6             	mov    %rdx,%r14
   1accd:	48 89 c2             	mov    %rax,%rdx
   1acd0:	48 89 f8             	mov    %rdi,%rax
   1acd3:	48 8b bd 40 ff ff ff 	mov    -0xc0(%rbp),%rdi
   1acda:	48 2b 85 48 ff ff ff 	sub    -0xb8(%rbp),%rax
   1ace1:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
   1ace5:	48 c1 ef 03          	shr    $0x3,%rdi
   1ace9:	48 0f af c7          	imul   %rdi,%rax
   1aced:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
   1acf4:	49 89 c7             	mov    %rax,%r15
   1acf7:	eb 0a                	jmp    1ad03 <mj__constraint_solvers__packed_cholesky__factor+0x6d3>
   1acf9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   1ad00:	48 ff c1             	inc    %rcx
   1ad03:	89 c8                	mov    %ecx,%eax
   1ad05:	39 ce                	cmp    %ecx,%esi
   1ad07:	0f 4e c6             	cmovle %esi,%eax
   1ad0a:	41 39 c0             	cmp    %eax,%r8d
   1ad0d:	0f 8c 46 01 00 00    	jl     1ae59 <mj__constraint_solvers__packed_cholesky__factor+0x829>
   1ad13:	4a 8d 04 31          	lea    (%rcx,%r14,1),%rax
   1ad17:	48 03 45 c0          	add    -0x40(%rbp),%rax
   1ad1b:	c4 c1 f9 7e eb       	vmovq  %xmm5,%r11
   1ad20:	41 8b 04 83          	mov    (%r11,%rax,4),%eax
   1ad24:	85 c0                	test   %eax,%eax
   1ad26:	0f 8e 09 03 00 00    	jle    1b035 <mj__constraint_solvers__packed_cholesky__factor+0xa05>
   1ad2c:	41 39 c5             	cmp    %eax,%r13d
   1ad2f:	0f 8c 24 01 00 00    	jl     1ae59 <mj__constraint_solvers__packed_cholesky__factor+0x829>
   1ad35:	41 39 c1             	cmp    %eax,%r9d
   1ad38:	0f 8f 1b 01 00 00    	jg     1ae59 <mj__constraint_solvers__packed_cholesky__factor+0x829>
   1ad3e:	41 39 c2             	cmp    %eax,%r10d
   1ad41:	0f 8c 12 01 00 00    	jl     1ae59 <mj__constraint_solvers__packed_cholesky__factor+0x829>
   1ad47:	49 89 c3             	mov    %rax,%r11
   1ad4a:	4c 2b 5d 90          	sub    -0x70(%rbp),%r11
   1ad4e:	4d 01 fb             	add    %r15,%r11
   1ad51:	c4 a1 7b 10 04 df    	vmovsd (%rdi,%r11,8),%xmm0
   1ad57:	c4 c1 7b 11 44 c4 f8 	vmovsd %xmm0,-0x8(%r12,%rax,8)
   1ad5e:	48 39 d9             	cmp    %rbx,%rcx
   1ad61:	75 9d                	jne    1ad00 <mj__constraint_solvers__packed_cholesky__factor+0x6d0>
   1ad63:	4c 89 e3             	mov    %r12,%rbx
   1ad66:	c4 c1 f9 7e ec       	vmovq  %xmm5,%r12
   1ad6b:	e9 ed f9 ff ff       	jmp    1a75d <mj__constraint_solvers__packed_cholesky__factor+0x12d>
   1ad70:	c5 fb 10 15 60 e0 05 	vmovsd 0x5e060(%rip),%xmm2        # 78dd8 <_IO_stdin_used+0x2318>
   1ad77:	00 
   1ad78:	c5 eb 5e d0          	vdivsd %xmm0,%xmm2,%xmm2
   1ad7c:	41 39 34 24          	cmp    %esi,(%r12)
   1ad80:	0f 8d 6a 01 00 00    	jge    1aef0 <mj__constraint_solvers__packed_cholesky__factor+0x8c0>
   1ad86:	89 d1                	mov    %edx,%ecx
   1ad88:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
   1ad8c:	4c 8b 8d 68 ff ff ff 	mov    -0x98(%rbp),%r9
   1ad93:	4c 8b 75 80          	mov    -0x80(%rbp),%r14
   1ad97:	be 01 00 00 00       	mov    $0x1,%esi
   1ad9c:	4c 8d 7a ff          	lea    -0x1(%rdx),%r15
   1ada0:	41 8b 14 24          	mov    (%r12),%edx
   1ada4:	39 f2                	cmp    %esi,%edx
   1ada6:	0f 8c bc 02 00 00    	jl     1b068 <mj__constraint_solvers__packed_cholesky__factor+0xa38>
   1adac:	4d 89 fb             	mov    %r15,%r11
   1adaf:	4c 0f af da          	imul   %rdx,%r11
   1adb3:	49 01 f3             	add    %rsi,%r11
   1adb6:	49 8d 14 53          	lea    (%r11,%rdx,2),%rdx
   1adba:	41 8b 14 94          	mov    (%r12,%rdx,4),%edx
   1adbe:	85 d2                	test   %edx,%edx
   1adc0:	0f 8e a2 02 00 00    	jle    1b068 <mj__constraint_solvers__packed_cholesky__factor+0xa38>
   1adc6:	41 39 d5             	cmp    %edx,%r13d
   1adc9:	0f 8c 99 02 00 00    	jl     1b068 <mj__constraint_solvers__packed_cholesky__factor+0xa38>
   1adcf:	c5 eb 59 4c d3 f8    	vmulsd -0x8(%rbx,%rdx,8),%xmm2,%xmm1
   1add5:	c5 f9 2e 0d 2b e1 05 	vucomisd 0x5e12b(%rip),%xmm1        # 78f08 <_IO_stdin_used+0x2448>
   1addc:	00 
   1addd:	0f 82 fb 01 00 00    	jb     1afde <mj__constraint_solvers__packed_cholesky__factor+0x9ae>
   1ade3:	c5 f9 2e f1          	vucomisd %xmm1,%xmm6
   1ade7:	0f 82 f1 01 00 00    	jb     1afde <mj__constraint_solvers__packed_cholesky__factor+0x9ae>
   1aded:	89 c2                	mov    %eax,%edx
   1adef:	01 f2                	add    %esi,%edx
   1adf1:	0f 80 c6 02 00 00    	jo     1b0bd <mj__constraint_solvers__packed_cholesky__factor+0xa8d>
   1adf7:	ff ca                	dec    %edx
   1adf9:	39 d7                	cmp    %edx,%edi
   1adfb:	0f 8f 45 02 00 00    	jg     1b046 <mj__constraint_solvers__packed_cholesky__factor+0xa16>
   1ae01:	41 39 d0             	cmp    %edx,%r8d
   1ae04:	0f 8c 3c 02 00 00    	jl     1b046 <mj__constraint_solvers__packed_cholesky__factor+0xa16>
   1ae0a:	48 63 d2             	movslq %edx,%rdx
   1ae0d:	48 ff c6             	inc    %rsi
   1ae10:	4c 29 ca             	sub    %r9,%rdx
   1ae13:	c4 c1 7b 11 0c d6    	vmovsd %xmm1,(%r14,%rdx,8)
   1ae19:	48 39 f1             	cmp    %rsi,%rcx
   1ae1c:	75 82                	jne    1ada0 <mj__constraint_solvers__packed_cholesky__factor+0x770>
   1ae1e:	e9 5e fe ff ff       	jmp    1ac81 <mj__constraint_solvers__packed_cholesky__factor+0x651>
   1ae23:	66 90                	xchg   %ax,%ax
   1ae25:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1ae2c:	00 00 00 00 
   1ae30:	45 85 c0             	test   %r8d,%r8d
   1ae33:	7e 24                	jle    1ae59 <mj__constraint_solvers__packed_cholesky__factor+0x829>
   1ae35:	48 89 fa             	mov    %rdi,%rdx
   1ae38:	48 ff ca             	dec    %rdx
   1ae3b:	c4 e1 f9 7e e7       	vmovq  %xmm4,%rdi
   1ae40:	48 0f af d7          	imul   %rdi,%rdx
   1ae44:	48 c1 e8 02          	shr    $0x2,%rax
   1ae48:	48 8d 44 02 01       	lea    0x1(%rdx,%rax,1),%rax
   1ae4d:	41 8b 04 84          	mov    (%r12,%rax,4),%eax
   1ae51:	85 c0                	test   %eax,%eax
   1ae53:	0f 8e dc 01 00 00    	jle    1b035 <mj__constraint_solvers__packed_cholesky__factor+0xa05>
   1ae59:	be e6 00 00 00       	mov    $0xe6,%esi
   1ae5e:	48 8d 3d a3 fe 05 00 	lea    0x5fea3(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1ae65:	e8 4c 28 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1ae6a:	49 89 c1             	mov    %rax,%r9
   1ae6d:	49 ff c9             	dec    %r9
   1ae70:	49 63 04 24          	movslq (%r12),%rax
   1ae74:	41 89 c8             	mov    %ecx,%r8d
   1ae77:	ba 01 00 00 00       	mov    $0x1,%edx
   1ae7c:	48 8d 34 c5 00 00 00 	lea    0x0(,%rax,8),%rsi
   1ae83:	00 
   1ae84:	4c 0f af c8          	imul   %rax,%r9
   1ae88:	48 89 c7             	mov    %rax,%rdi
   1ae8b:	48 c1 ee 02          	shr    $0x2,%rsi
   1ae8f:	eb 29                	jmp    1aeba <mj__constraint_solvers__packed_cholesky__factor+0x88a>
   1ae91:	0f 1f 40 00          	nopl   0x0(%rax)
   1ae95:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1ae9c:	00 00 00 00 
   1aea0:	41 39 c5             	cmp    %eax,%r13d
   1aea3:	7c 2f                	jl     1aed4 <mj__constraint_solvers__packed_cholesky__factor+0x8a4>
   1aea5:	48 c7 44 c3 f8 00 00 	movq   $0x0,-0x8(%rbx,%rax,8)
   1aeac:	00 00 
   1aeae:	49 39 d0             	cmp    %rdx,%r8
   1aeb1:	0f 84 d4 f9 ff ff    	je     1a88b <mj__constraint_solvers__packed_cholesky__factor+0x25b>
   1aeb7:	48 ff c2             	inc    %rdx
   1aeba:	89 d0                	mov    %edx,%eax
   1aebc:	39 d1                	cmp    %edx,%ecx
   1aebe:	0f 4e c1             	cmovle %ecx,%eax
   1aec1:	39 c7                	cmp    %eax,%edi
   1aec3:	7c 0f                	jl     1aed4 <mj__constraint_solvers__packed_cholesky__factor+0x8a4>
   1aec5:	4a 8d 04 0a          	lea    (%rdx,%r9,1),%rax
   1aec9:	48 01 f0             	add    %rsi,%rax
   1aecc:	41 8b 04 84          	mov    (%r12,%rax,4),%eax
   1aed0:	85 c0                	test   %eax,%eax
   1aed2:	7f cc                	jg     1aea0 <mj__constraint_solvers__packed_cholesky__factor+0x870>
   1aed4:	be f8 00 00 00       	mov    $0xf8,%esi
   1aed9:	48 8d 3d 28 fe 05 00 	lea    0x5fe28(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1aee0:	e8 d1 27 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1aee5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1aeec:	00 00 00 00 
   1aef0:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
   1aef4:	4c 8b 75 80          	mov    -0x80(%rbp),%r14
   1aef8:	44 89 55 c0          	mov    %r10d,-0x40(%rbp)
   1aefc:	b9 01 00 00 00       	mov    $0x1,%ecx
   1af01:	49 89 da             	mov    %rbx,%r10
   1af04:	89 d3                	mov    %edx,%ebx
   1af06:	4c 8d 7e ff          	lea    -0x1(%rsi),%r15
   1af0a:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
   1af11:	0f 1f 40 00          	nopl   0x0(%rax)
   1af15:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1af1c:	00 00 00 00 
   1af20:	49 63 14 24          	movslq (%r12),%rdx
   1af24:	49 b9 ff ff ff ff ff 	movabs $0x3fffffffffffffff,%r9
   1af2b:	ff ff 3f 
   1af2e:	49 21 d1             	and    %rdx,%r9
   1af31:	48 c1 e2 03          	shl    $0x3,%rdx
   1af35:	4d 0f af cf          	imul   %r15,%r9
   1af39:	48 c1 ea 02          	shr    $0x2,%rdx
   1af3d:	49 89 d3             	mov    %rdx,%r11
   1af40:	4a 8d 14 09          	lea    (%rcx,%r9,1),%rdx
   1af44:	4c 01 da             	add    %r11,%rdx
   1af47:	41 8b 14 94          	mov    (%r12,%rdx,4),%edx
   1af4b:	85 d2                	test   %edx,%edx
   1af4d:	0f 8e 15 01 00 00    	jle    1b068 <mj__constraint_solvers__packed_cholesky__factor+0xa38>
   1af53:	41 39 d5             	cmp    %edx,%r13d
   1af56:	0f 8c 0c 01 00 00    	jl     1b068 <mj__constraint_solvers__packed_cholesky__factor+0xa38>
   1af5c:	c4 c1 6b 59 4c d2 f8 	vmulsd -0x8(%r10,%rdx,8),%xmm2,%xmm1
   1af63:	c5 f9 2e 0d 9d df 05 	vucomisd 0x5df9d(%rip),%xmm1        # 78f08 <_IO_stdin_used+0x2448>
   1af6a:	00 
   1af6b:	72 71                	jb     1afde <mj__constraint_solvers__packed_cholesky__factor+0x9ae>
   1af6d:	c5 f9 2e f1          	vucomisd %xmm1,%xmm6
   1af71:	72 6b                	jb     1afde <mj__constraint_solvers__packed_cholesky__factor+0x9ae>
   1af73:	89 c2                	mov    %eax,%edx
   1af75:	01 ca                	add    %ecx,%edx
   1af77:	0f 80 40 01 00 00    	jo     1b0bd <mj__constraint_solvers__packed_cholesky__factor+0xa8d>
   1af7d:	ff ca                	dec    %edx
   1af7f:	39 d7                	cmp    %edx,%edi
   1af81:	0f 8f bf 00 00 00    	jg     1b046 <mj__constraint_solvers__packed_cholesky__factor+0xa16>
   1af87:	41 39 d0             	cmp    %edx,%r8d
   1af8a:	0f 8c b6 00 00 00    	jl     1b046 <mj__constraint_solvers__packed_cholesky__factor+0xa16>
   1af90:	48 63 d2             	movslq %edx,%rdx
   1af93:	48 ff c1             	inc    %rcx
   1af96:	48 29 f2             	sub    %rsi,%rdx
   1af99:	c4 c1 7b 11 0c d6    	vmovsd %xmm1,(%r14,%rdx,8)
   1af9f:	48 39 d9             	cmp    %rbx,%rcx
   1afa2:	0f 85 78 ff ff ff    	jne    1af20 <mj__constraint_solvers__packed_cholesky__factor+0x8f0>
   1afa8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1afac:	4c 89 d3             	mov    %r10,%rbx
   1afaf:	44 8b 55 c0          	mov    -0x40(%rbp),%r10d
   1afb3:	41 8b 14 84          	mov    (%r12,%rax,4),%edx
   1afb7:	e9 76 f8 ff ff       	jmp    1a832 <mj__constraint_solvers__packed_cholesky__factor+0x202>
   1afbc:	be c9 00 00 00       	mov    $0xc9,%esi
   1afc1:	48 8d 3d 40 fd 05 00 	lea    0x5fd40(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1afc8:	e8 e9 26 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1afcd:	be c6 00 00 00       	mov    $0xc6,%esi
   1afd2:	48 8d 3d 2f fd 05 00 	lea    0x5fd2f(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1afd9:	e8 46 27 02 00       	call   3d724 <__gnat_rcheck_CE_Overflow_Check>
   1afde:	b8 02 00 00 00       	mov    $0x2,%eax
   1afe3:	48 89 c2             	mov    %rax,%rdx
   1afe6:	48 c1 e2 20          	shl    $0x20,%rdx
   1afea:	8b 85 5c ff ff ff    	mov    -0xa4(%rbp),%eax
   1aff0:	48 09 d0             	or     %rdx,%rax
   1aff3:	48 8d 65 d8          	lea    -0x28(%rbp),%rsp
   1aff7:	5b                   	pop    %rbx
   1aff8:	41 5c                	pop    %r12
   1affa:	41 5d                	pop    %r13
   1affc:	41 5e                	pop    %r14
   1affe:	41 5f                	pop    %r15
   1b000:	5d                   	pop    %rbp
   1b001:	c3                   	ret
   1b002:	be cc 00 00 00       	mov    $0xcc,%esi
   1b007:	48 8d 3d fa fc 05 00 	lea    0x5fcfa(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b00e:	e8 a3 26 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b013:	be c6 00 00 00       	mov    $0xc6,%esi
   1b018:	48 8d 3d e9 fc 05 00 	lea    0x5fce9(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b01f:	e8 2c 27 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b024:	be c9 00 00 00       	mov    $0xc9,%esi
   1b029:	48 8d 3d d8 fc 05 00 	lea    0x5fcd8(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b030:	e8 1b 27 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b035:	be e6 00 00 00       	mov    $0xe6,%esi
   1b03a:	48 8d 3d c7 fc 05 00 	lea    0x5fcc7(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b041:	e8 0a 27 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b046:	be f5 00 00 00       	mov    $0xf5,%esi
   1b04b:	48 8d 3d b6 fc 05 00 	lea    0x5fcb6(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b052:	e8 5f 26 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b057:	be 1d 00 00 00       	mov    $0x1d,%esi
   1b05c:	48 8d 3d d5 fc 05 00 	lea    0x5fcd5(%rip),%rdi        # 7ad38 <mj__constraint_solvers__cholesky_updates__statusS+0x48>
   1b063:	e8 bc 26 02 00       	call   3d724 <__gnat_rcheck_CE_Overflow_Check>
   1b068:	be f3 00 00 00       	mov    $0xf3,%esi
   1b06d:	48 8d 3d 94 fc 05 00 	lea    0x5fc94(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b074:	e8 3d 26 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b079:	be 1d 00 00 00       	mov    $0x1d,%esi
   1b07e:	48 8d 3d b3 fc 05 00 	lea    0x5fcb3(%rip),%rdi        # 7ad38 <mj__constraint_solvers__cholesky_updates__statusS+0x48>
   1b085:	e8 2c 26 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b08a:	be f7 00 00 00       	mov    $0xf7,%esi
   1b08f:	48 8d 3d 72 fc 05 00 	lea    0x5fc72(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b096:	e8 b5 26 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b09b:	be bf 00 00 00       	mov    $0xbf,%esi
   1b0a0:	48 8d 3d 61 fc 05 00 	lea    0x5fc61(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b0a7:	e8 a4 26 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b0ac:	be ea 00 00 00       	mov    $0xea,%esi
   1b0b1:	48 8d 3d 50 fc 05 00 	lea    0x5fc50(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b0b8:	e8 93 26 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b0bd:	be f5 00 00 00       	mov    $0xf5,%esi
   1b0c2:	48 8d 3d 3f fc 05 00 	lea    0x5fc3f(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b0c9:	e8 56 26 02 00       	call   3d724 <__gnat_rcheck_CE_Overflow_Check>
   1b0ce:	be ed 00 00 00       	mov    $0xed,%esi
   1b0d3:	48 8d 3d 2e fc 05 00 	lea    0x5fc2e(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b0da:	e8 71 26 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b0df:	be e8 00 00 00       	mov    $0xe8,%esi
   1b0e4:	48 8d 3d 1d fc 05 00 	lea    0x5fc1d(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b0eb:	e8 dc 25 02 00       	call   3d6cc <__gnat_rcheck_CE_Invalid_Data>
   1b0f0:	be e5 00 00 00       	mov    $0xe5,%esi
   1b0f5:	48 8d 3d 0c fc 05 00 	lea    0x5fc0c(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b0fc:	e8 cb 25 02 00       	call   3d6cc <__gnat_rcheck_CE_Invalid_Data>
   1b101:	be e4 00 00 00       	mov    $0xe4,%esi
   1b106:	48 8d 3d fb fb 05 00 	lea    0x5fbfb(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b10d:	e8 ba 25 02 00       	call   3d6cc <__gnat_rcheck_CE_Invalid_Data>
   1b112:	0f 1f 00             	nopl   (%rax)
   1b115:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1b11c:	00 00 00 00 
   1b120:	be e9 00 00 00       	mov    $0xe9,%esi
   1b125:	48 8d 3d dc fb 05 00 	lea    0x5fbdc(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b12c:	e8 1f 26 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b131:	be e9 00 00 00       	mov    $0xe9,%esi
   1b136:	48 8d 3d cb fb 05 00 	lea    0x5fbcb(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b13d:	e8 74 25 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b142:	be f8 00 00 00       	mov    $0xf8,%esi
   1b147:	48 8d 3d ba fb 05 00 	lea    0x5fbba(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b14e:	e8 79 25 02 00       	call   3d6cc <__gnat_rcheck_CE_Invalid_Data>
   1b153:	be f7 00 00 00       	mov    $0xf7,%esi
   1b158:	48 8d 3d a9 fb 05 00 	lea    0x5fba9(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b15f:	e8 52 25 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>

Disassembly of section .fini:
