
/var/tmp/sparkling-alignment-315-packed-native-r53-20261008/build/release/bin/packed_cholesky_probe:     file format elf64-x86-64


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
   1a63d:	49 89 d5             	mov    %rdx,%r13
   1a640:	48 81 ec a8 00 00 00 	sub    $0xa8,%rsp
   1a647:	48 8b 45 10          	mov    0x10(%rbp),%rax
   1a64b:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
   1a652:	4c 89 85 68 ff ff ff 	mov    %r8,-0x98(%rbp)
   1a659:	4c 63 3a             	movslq (%rdx),%r15
   1a65c:	48 89 bd 50 ff ff ff 	mov    %rdi,-0xb0(%rbp)
   1a663:	48 89 4d a8          	mov    %rcx,-0x58(%rbp)
   1a667:	c5 fb 11 85 78 ff ff 	vmovsd %xmm0,-0x88(%rbp)
   1a66e:	ff 
   1a66f:	31 ff                	xor    %edi,%edi
   1a671:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
   1a675:	48 8b 45 18          	mov    0x18(%rbp),%rax
   1a679:	44 8b 18             	mov    (%rax),%r11d
   1a67c:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
   1a683:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
   1a68a:	44 8b 00             	mov    (%rax),%r8d
   1a68d:	48 63 58 08          	movslq 0x8(%rax),%rbx
   1a691:	44 89 5d c0          	mov    %r11d,-0x40(%rbp)
   1a695:	44 8b 70 04          	mov    0x4(%rax),%r14d
   1a699:	44 89 45 c8          	mov    %r8d,-0x38(%rbp)
   1a69d:	48 89 5d 80          	mov    %rbx,-0x80(%rbp)
   1a6a1:	48 63 40 0c          	movslq 0xc(%rax),%rax
   1a6a5:	48 89 c2             	mov    %rax,%rdx
   1a6a8:	48 29 d8             	sub    %rbx,%rax
   1a6ab:	48 8d 04 c5 08 00 00 	lea    0x8(,%rax,8),%rax
   1a6b2:	00 
   1a6b3:	39 d3                	cmp    %edx,%ebx
   1a6b5:	4a 8d 14 fd 00 00 00 	lea    0x0(,%r15,8),%rdx
   1a6bc:	00 
   1a6bd:	48 0f 4f c7          	cmovg  %rdi,%rax
   1a6c1:	31 f6                	xor    %esi,%esi
   1a6c3:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
   1a6ca:	4a 8d 04 fd 0f 00 00 	lea    0xf(,%r15,8),%rax
   1a6d1:	00 
   1a6d2:	48 83 e0 f0          	and    $0xfffffffffffffff0,%rax
   1a6d6:	48 29 c4             	sub    %rax,%rsp
   1a6d9:	48 89 e7             	mov    %rsp,%rdi
   1a6dc:	e8 6f 9e fe ff       	call   4550 <memset@plt>
   1a6e1:	45 85 ff             	test   %r15d,%r15d
   1a6e4:	44 8b 45 c8          	mov    -0x38(%rbp),%r8d
   1a6e8:	44 8b 5d c0          	mov    -0x40(%rbp),%r11d
   1a6ec:	0f 8e 6d 09 00 00    	jle    1b05f <mj__constraint_solvers__packed_cholesky__factor+0xa2f>
   1a6f2:	49 63 c3             	movslq %r11d,%rax
   1a6f5:	41 83 f8 01          	cmp    $0x1,%r8d
   1a6f9:	44 89 7d 88          	mov    %r15d,-0x78(%rbp)
   1a6fd:	4d 89 fc             	mov    %r15,%r12
   1a700:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
   1a707:	49 8d 47 01          	lea    0x1(%r15),%rax
   1a70b:	48 89 e3             	mov    %rsp,%rbx
   1a70e:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
   1a712:	49 63 c0             	movslq %r8d,%rax
   1a715:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
   1a71c:	0f 9f c0             	setg   %al
   1a71f:	45 39 f7             	cmp    %r14d,%r15d
   1a722:	0f 9f c2             	setg   %dl
   1a725:	09 d0                	or     %edx,%eax
   1a727:	88 85 47 ff ff ff    	mov    %al,-0xb9(%rbp)
   1a72d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1a731:	48 89 45 90          	mov    %rax,-0x70(%rbp)
   1a735:	48 ff c8             	dec    %rax
   1a738:	41 8b 7c 85 00       	mov    0x0(%r13,%rax,4),%edi
   1a73d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
   1a741:	85 ff                	test   %edi,%edi
   1a743:	0f 88 de 09 00 00    	js     1b127 <mj__constraint_solvers__packed_cholesky__factor+0xaf7>
   1a749:	49 63 45 00          	movslq 0x0(%r13),%rax
   1a74d:	49 89 c0             	mov    %rax,%r8
   1a750:	c4 e1 f9 6e d0       	vmovq  %rax,%xmm2
   1a755:	0f 85 05 04 00 00    	jne    1ab60 <mj__constraint_solvers__packed_cholesky__factor+0x530>
   1a75b:	c4 e1 f9 7e d0       	vmovq  %xmm2,%rax
   1a760:	48 ba ff ff ff ff ff 	movabs $0x3fffffffffffffff,%rdx
   1a767:	ff ff 3f 
   1a76a:	48 ff c0             	inc    %rax
   1a76d:	48 21 d0             	and    %rdx,%rax
   1a770:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
   1a774:	48 8d 44 02 ff       	lea    -0x1(%rdx,%rax,1),%rax
   1a779:	41 8b 7c 85 00       	mov    0x0(%r13,%rax,4),%edi
   1a77e:	85 ff                	test   %edi,%edi
   1a780:	0f 88 fb 08 00 00    	js     1b081 <mj__constraint_solvers__packed_cholesky__factor+0xa51>
   1a786:	83 ff 01             	cmp    $0x1,%edi
   1a789:	0f 8f 11 01 00 00    	jg     1a8a0 <mj__constraint_solvers__packed_cholesky__factor+0x270>
   1a78f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1a793:	c5 fb 10 9d 78 ff ff 	vmovsd -0x88(%rbp),%xmm3
   1a79a:	ff 
   1a79b:	c5 fb 10 4c c3 f8    	vmovsd -0x8(%rbx,%rax,8),%xmm1
   1a7a1:	c5 f9 2f d9          	vcomisd %xmm1,%xmm3
   1a7a5:	0f 86 93 06 00 00    	jbe    1ae3e <mj__constraint_solvers__packed_cholesky__factor+0x80e>
   1a7ab:	ff 4d 88             	decl   -0x78(%rbp)
   1a7ae:	0f 88 de 08 00 00    	js     1b092 <mj__constraint_solvers__packed_cholesky__factor+0xa62>
   1a7b4:	c5 f9 28 c3          	vmovapd %xmm3,%xmm0
   1a7b8:	c5 fb 11 4d c0       	vmovsd %xmm1,-0x40(%rbp)
   1a7bd:	e8 4e ff fe ff       	call   a710 <mj__quaternion_math__sqrt>
   1a7c2:	c5 f9 2e 05 96 e5 05 	vucomisd 0x5e596(%rip),%xmm0        # 78d60 <_IO_stdin_used+0x22a0>
   1a7c9:	00 
   1a7ca:	0f 82 2e 08 00 00    	jb     1affe <mj__constraint_solvers__packed_cholesky__factor+0x9ce>
   1a7d0:	c5 fb 10 2d 90 e5 05 	vmovsd 0x5e590(%rip),%xmm5        # 78d68 <_IO_stdin_used+0x22a8>
   1a7d7:	00 
   1a7d8:	c5 f9 2e e8          	vucomisd %xmm0,%xmm5
   1a7dc:	0f 82 1c 08 00 00    	jb     1affe <mj__constraint_solvers__packed_cholesky__factor+0x9ce>
   1a7e2:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
   1a7e9:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
   1a7ed:	48 63 02             	movslq (%rdx),%rax
   1a7f0:	39 c6                	cmp    %eax,%esi
   1a7f2:	0f 8c c9 08 00 00    	jl     1b0c1 <mj__constraint_solvers__packed_cholesky__factor+0xa91>
   1a7f8:	3b 72 04             	cmp    0x4(%rdx),%esi
   1a7fb:	0f 8f c0 08 00 00    	jg     1b0c1 <mj__constraint_solvers__packed_cholesky__factor+0xa91>
   1a801:	48 89 f2             	mov    %rsi,%rdx
   1a804:	48 29 c2             	sub    %rax,%rdx
   1a807:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   1a80b:	44 8b 0c 90          	mov    (%rax,%rdx,4),%r9d
   1a80f:	31 d2                	xor    %edx,%edx
   1a811:	44 89 c9             	mov    %r9d,%ecx
   1a814:	83 c1 01             	add    $0x1,%ecx
   1a817:	0f 90 c2             	seto   %dl
   1a81a:	85 d2                	test   %edx,%edx
   1a81c:	0f 85 8e 08 00 00    	jne    1b0b0 <mj__constraint_solvers__packed_cholesky__factor+0xa80>
   1a822:	41 8b 44 b5 00       	mov    0x0(%r13,%rsi,4),%eax
   1a827:	44 8d 40 ff          	lea    -0x1(%rax),%r8d
   1a82b:	45 85 c0             	test   %r8d,%r8d
   1a82e:	0f 8f 27 05 00 00    	jg     1ad5b <mj__constraint_solvers__packed_cholesky__factor+0x72b>
   1a834:	85 c0                	test   %eax,%eax
   1a836:	0f 8e da 08 00 00    	jle    1b116 <mj__constraint_solvers__packed_cholesky__factor+0xae6>
   1a83c:	44 01 c8             	add    %r9d,%eax
   1a83f:	0f 80 6b 08 00 00    	jo     1b0b0 <mj__constraint_solvers__packed_cholesky__factor+0xa80>
   1a845:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
   1a84c:	44 8b 1a             	mov    (%rdx),%r11d
   1a84f:	41 39 c3             	cmp    %eax,%r11d
   1a852:	0f 8f ad 08 00 00    	jg     1b105 <mj__constraint_solvers__packed_cholesky__factor+0xad5>
   1a858:	39 42 04             	cmp    %eax,0x4(%rdx)
   1a85b:	0f 8c a4 08 00 00    	jl     1b105 <mj__constraint_solvers__packed_cholesky__factor+0xad5>
   1a861:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
   1a865:	48 98                	cltq
   1a867:	48 2b 85 60 ff ff ff 	sub    -0xa0(%rbp),%rax
   1a86e:	c5 fb 11 04 c2       	vmovsd %xmm0,(%rdx,%rax,8)
   1a873:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1a877:	41 8b 4c 85 00       	mov    0x0(%r13,%rax,4),%ecx
   1a87c:	85 c9                	test   %ecx,%ecx
   1a87e:	0f 88 e7 08 00 00    	js     1b16b <mj__constraint_solvers__packed_cholesky__factor+0xb3b>
   1a884:	0f 85 bd 05 00 00    	jne    1ae47 <mj__constraint_solvers__packed_cholesky__factor+0x817>
   1a88a:	48 83 7d c8 01       	cmpq   $0x1,-0x38(%rbp)
   1a88f:	0f 85 98 fe ff ff    	jne    1a72d <mj__constraint_solvers__packed_cholesky__factor+0xfd>
   1a895:	31 c0                	xor    %eax,%eax
   1a897:	e9 67 07 00 00       	jmp    1b003 <mj__constraint_solvers__packed_cholesky__factor+0x9d3>
   1a89c:	0f 1f 40 00          	nopl   0x0(%rax)
   1a8a0:	44 39 c7             	cmp    %r8d,%edi
   1a8a3:	0f 9f 45 b8          	setg   -0x48(%rbp)
   1a8a7:	41 83 f8 01          	cmp    $0x1,%r8d
   1a8ab:	0f 9e c0             	setle  %al
   1a8ae:	84 45 b8             	test   %al,-0x48(%rbp)
   1a8b1:	0f 85 a3 08 00 00    	jne    1b15a <mj__constraint_solvers__packed_cholesky__factor+0xb2a>
   1a8b7:	c4 e1 f9 7e d0       	vmovq  %xmm2,%rax
   1a8bc:	49 89 d2             	mov    %rdx,%r10
   1a8bf:	c4 e1 f9 7e d1       	vmovq  %xmm2,%rcx
   1a8c4:	4c 8d 34 c5 00 00 00 	lea    0x0(,%rax,8),%r14
   1a8cb:	00 
   1a8cc:	48 0f af c0          	imul   %rax,%rax
   1a8d0:	4d 8d 7a ff          	lea    -0x1(%r10),%r15
   1a8d4:	4c 0f af f9          	imul   %rcx,%r15
   1a8d8:	48 c1 e0 02          	shl    $0x2,%rax
   1a8dc:	4a 8d 54 30 04       	lea    0x4(%rax,%r14,1),%rdx
   1a8e1:	48 c1 ea 02          	shr    $0x2,%rdx
   1a8e5:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
   1a8e9:	4a 8d 54 3a 01       	lea    0x1(%rdx,%r15,1),%rdx
   1a8ee:	41 8b 4c 95 00       	mov    0x0(%r13,%rdx,4),%ecx
   1a8f3:	85 c9                	test   %ecx,%ecx
   1a8f5:	0f 8e d7 07 00 00    	jle    1b0d2 <mj__constraint_solvers__packed_cholesky__factor+0xaa2>
   1a8fb:	4d 8d 4c 46 04       	lea    0x4(%r14,%rax,2),%r9
   1a900:	49 c1 e9 02          	shr    $0x2,%r9
   1a904:	4b 8d 44 39 01       	lea    0x1(%r9,%r15,1),%rax
   1a909:	41 8b 44 85 00       	mov    0x0(%r13,%rax,4),%eax
   1a90e:	85 c0                	test   %eax,%eax
   1a910:	0f 8e bc 07 00 00    	jle    1b0d2 <mj__constraint_solvers__packed_cholesky__factor+0xaa2>
   1a916:	44 89 c2             	mov    %r8d,%edx
   1a919:	44 29 d2             	sub    %r10d,%edx
   1a91c:	8d b2 00 00 00 01    	lea    0x1000000(%rdx),%esi
   1a922:	81 fe ff ff ff 01    	cmp    $0x1ffffff,%esi
   1a928:	0f 87 1a 02 00 00    	ja     1ab48 <mj__constraint_solvers__packed_cholesky__factor+0x518>
   1a92e:	c1 e2 07             	shl    $0x7,%edx
   1a931:	c5 79 6f c2          	vmovdqa %xmm2,%xmm8
   1a935:	c4 41 f9 6e f5       	vmovq  %r13,%xmm14
   1a93a:	89 55 8c             	mov    %edx,-0x74(%rbp)
   1a93d:	8d 72 02             	lea    0x2(%rdx),%esi
   1a940:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
   1a947:	ff c7                	inc    %edi
   1a949:	c4 61 f9 6e d7       	vmovq  %rdi,%xmm10
   1a94e:	48 8b 7d 90          	mov    -0x70(%rbp),%rdi
   1a952:	49 c1 ee 02          	shr    $0x2,%r14
   1a956:	4c 63 12             	movslq (%rdx),%r10
   1a959:	44 8b 7a 04          	mov    0x4(%rdx),%r15d
   1a95d:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
   1a964:	4c 89 75 90          	mov    %r14,-0x70(%rbp)
   1a968:	48 83 ef 02          	sub    $0x2,%rdi
   1a96c:	44 89 55 a0          	mov    %r10d,-0x60(%rbp)
   1a970:	c4 c1 f9 6e fa       	vmovq  %r10,%xmm7
   1a975:	c4 c1 f9 7e d2       	vmovq  %xmm2,%r10
   1a97a:	8b 52 04             	mov    0x4(%rdx),%edx
   1a97d:	44 89 7d a4          	mov    %r15d,-0x5c(%rbp)
   1a981:	4d 63 fb             	movslq %r11d,%r15
   1a984:	49 0f af fa          	imul   %r10,%rdi
   1a988:	4c 8b 55 c0          	mov    -0x40(%rbp),%r10
   1a98c:	4c 89 7d 98          	mov    %r15,-0x68(%rbp)
   1a990:	49 f7 df             	neg    %r15
   1a993:	49 01 f9             	add    %rdi,%r9
   1a996:	49 01 fa             	add    %rdi,%r10
   1a999:	4b 8d 7c 8d 00       	lea    0x0(%r13,%r9,4),%rdi
   1a99e:	c4 e1 f9 6e df       	vmovq  %rdi,%xmm3
   1a9a3:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
   1a9a7:	4f 8d 54 95 00       	lea    0x0(%r13,%r10,4),%r10
   1a9ac:	49 89 dd             	mov    %rbx,%r13
   1a9af:	c4 41 f9 6e ca       	vmovq  %r10,%xmm9
   1a9b4:	41 ba 03 00 00 00    	mov    $0x3,%r10d
   1a9ba:	c5 79 7f ca          	vmovdqa %xmm9,%xmm2
   1a9be:	4a 8d 3c ff          	lea    (%rdi,%r15,8),%rdi
   1a9c2:	c4 e1 f9 6e f7       	vmovq  %rdi,%xmm6
   1a9c7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
   1a9ce:	00 00 
   1a9d0:	85 f6                	test   %esi,%esi
   1a9d2:	0f 8e 98 06 00 00    	jle    1b070 <mj__constraint_solvers__packed_cholesky__factor+0xa40>
   1a9d8:	39 4d a0             	cmp    %ecx,-0x60(%rbp)
   1a9db:	0f 8f e0 06 00 00    	jg     1b0c1 <mj__constraint_solvers__packed_cholesky__factor+0xa91>
   1a9e1:	39 4d a4             	cmp    %ecx,-0x5c(%rbp)
   1a9e4:	0f 8c d7 06 00 00    	jl     1b0c1 <mj__constraint_solvers__packed_cholesky__factor+0xa91>
   1a9ea:	89 cf                	mov    %ecx,%edi
   1a9ec:	c4 e1 f9 7e fb       	vmovq  %xmm7,%rbx
   1a9f1:	48 89 fe             	mov    %rdi,%rsi
   1a9f4:	48 29 de             	sub    %rbx,%rsi
   1a9f7:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
   1a9fb:	8b 34 b3             	mov    (%rbx,%rsi,4),%esi
   1a9fe:	41 89 f1             	mov    %esi,%r9d
   1aa01:	41 83 c1 01          	add    $0x1,%r9d
   1aa05:	0f 80 a5 06 00 00    	jo     1b0b0 <mj__constraint_solvers__packed_cholesky__factor+0xa80>
   1aa0b:	01 c6                	add    %eax,%esi
   1aa0d:	0f 80 9d 06 00 00    	jo     1b0b0 <mj__constraint_solvers__packed_cholesky__factor+0xa80>
   1aa13:	41 39 f3             	cmp    %esi,%r11d
   1aa16:	0f 8f 1c 07 00 00    	jg     1b138 <mj__constraint_solvers__packed_cholesky__factor+0xb08>
   1aa1c:	39 f2                	cmp    %esi,%edx
   1aa1e:	0f 8c 14 07 00 00    	jl     1b138 <mj__constraint_solvers__packed_cholesky__factor+0xb08>
   1aa24:	44 39 c1             	cmp    %r8d,%ecx
   1aa27:	0f 8f c0 05 00 00    	jg     1afed <mj__constraint_solvers__packed_cholesky__factor+0x9bd>
   1aa2d:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
   1aa31:	48 63 f6             	movslq %esi,%rsi
   1aa34:	48 2b 75 98          	sub    -0x68(%rbp),%rsi
   1aa38:	48 ff cf             	dec    %rdi
   1aa3b:	4c 89 55 c0          	mov    %r10,-0x40(%rbp)
   1aa3f:	44 8d 50 01          	lea    0x1(%rax),%r10d
   1aa43:	c5 fb 10 24 f3       	vmovsd (%rbx,%rsi,8),%xmm4
   1aa48:	c4 61 f9 7e c6       	vmovq  %xmm8,%rsi
   1aa4d:	48 0f af fe          	imul   %rsi,%rdi
   1aa51:	48 8b 75 90          	mov    -0x70(%rbp),%rsi
   1aa55:	48 8d 4c 37 01       	lea    0x1(%rdi,%rsi,1),%rcx
   1aa5a:	c4 61 f9 7e f6       	vmovq  %xmm14,%rsi
   1aa5f:	bf 02 00 00 00       	mov    $0x2,%edi
   1aa64:	48 8d 1c 8e          	lea    (%rsi,%rcx,4),%rbx
   1aa68:	49 63 c9             	movslq %r9d,%rcx
   1aa6b:	c4 e1 f9 7e f6       	vmovq  %xmm6,%rsi
   1aa70:	4c 8d 3c ce          	lea    (%rsi,%rcx,8),%r15
   1aa74:	49 89 de             	mov    %rbx,%r14
   1aa77:	eb 1a                	jmp    1aa93 <mj__constraint_solvers__packed_cholesky__factor+0x463>
   1aa79:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   1aa80:	89 f9                	mov    %edi,%ecx
   1aa82:	39 f8                	cmp    %edi,%eax
   1aa84:	0f 4e c8             	cmovle %eax,%ecx
   1aa87:	48 ff c7             	inc    %rdi
   1aa8a:	44 39 c1             	cmp    %r8d,%ecx
   1aa8d:	0f 8f 5a 05 00 00    	jg     1afed <mj__constraint_solvers__packed_cholesky__factor+0x9bd>
   1aa93:	41 8b 5c be f8       	mov    -0x8(%r14,%rdi,4),%ebx
   1aa98:	85 db                	test   %ebx,%ebx
   1aa9a:	0f 8e 9d 05 00 00    	jle    1b03d <mj__constraint_solvers__packed_cholesky__factor+0xa0d>
   1aaa0:	41 39 dc             	cmp    %ebx,%r12d
   1aaa3:	0f 8c 17 04 00 00    	jl     1aec0 <mj__constraint_solvers__packed_cholesky__factor+0x890>
   1aaa9:	8d 4f ff             	lea    -0x1(%rdi),%ecx
   1aaac:	44 01 c9             	add    %r9d,%ecx
   1aaaf:	0f 80 6a 05 00 00    	jo     1b01f <mj__constraint_solvers__packed_cholesky__factor+0x9ef>
   1aab5:	8d 71 ff             	lea    -0x1(%rcx),%esi
   1aab8:	41 39 f3             	cmp    %esi,%r11d
   1aabb:	0f 8f ff 03 00 00    	jg     1aec0 <mj__constraint_solvers__packed_cholesky__factor+0x890>
   1aac1:	39 f2                	cmp    %esi,%edx
   1aac3:	0f 8c f7 03 00 00    	jl     1aec0 <mj__constraint_solvers__packed_cholesky__factor+0x890>
   1aac9:	c4 c1 5b 59 4c ff f0 	vmulsd -0x10(%r15,%rdi,8),%xmm4,%xmm1
   1aad0:	89 d9                	mov    %ebx,%ecx
   1aad2:	48 ff c9             	dec    %rcx
   1aad5:	c4 c1 7b 10 44 cd 00 	vmovsd 0x0(%r13,%rcx,8),%xmm0
   1aadc:	c5 fb 5c c1          	vsubsd %xmm1,%xmm0,%xmm0
   1aae0:	c4 c1 7b 11 44 cd 00 	vmovsd %xmm0,0x0(%r13,%rcx,8)
   1aae7:	4c 39 d7             	cmp    %r10,%rdi
   1aaea:	75 94                	jne    1aa80 <mj__constraint_solvers__packed_cholesky__factor+0x450>
   1aaec:	4c 8b 55 c0          	mov    -0x40(%rbp),%r10
   1aaf0:	c4 61 f9 7e d0       	vmovq  %xmm10,%rax
   1aaf5:	49 39 c2             	cmp    %rax,%r10
   1aaf8:	0f 84 32 05 00 00    	je     1b030 <mj__constraint_solvers__packed_cholesky__factor+0xa00>
   1aafe:	45 39 d0             	cmp    %r10d,%r8d
   1ab01:	0f 9c c0             	setl   %al
   1ab04:	84 45 b8             	test   %al,-0x48(%rbp)
   1ab07:	0f 85 4d 06 00 00    	jne    1b15a <mj__constraint_solvers__packed_cholesky__factor+0xb2a>
   1ab0d:	c4 e1 f9 7e d0       	vmovq  %xmm2,%rax
   1ab12:	42 8b 4c 90 fc       	mov    -0x4(%rax,%r10,4),%ecx
   1ab17:	85 c9                	test   %ecx,%ecx
   1ab19:	0f 8e b3 05 00 00    	jle    1b0d2 <mj__constraint_solvers__packed_cholesky__factor+0xaa2>
   1ab1f:	c4 e1 f9 7e d8       	vmovq  %xmm3,%rax
   1ab24:	42 8b 44 90 fc       	mov    -0x4(%rax,%r10,4),%eax
   1ab29:	85 c0                	test   %eax,%eax
   1ab2b:	0f 8e a1 05 00 00    	jle    1b0d2 <mj__constraint_solvers__packed_cholesky__factor+0xaa2>
   1ab31:	8b 75 8c             	mov    -0x74(%rbp),%esi
   1ab34:	31 ff                	xor    %edi,%edi
   1ab36:	44 01 d6             	add    %r10d,%esi
   1ab39:	40 0f 90 c7          	seto   %dil
   1ab3d:	49 ff c2             	inc    %r10
   1ab40:	85 ff                	test   %edi,%edi
   1ab42:	0f 84 88 fe ff ff    	je     1a9d0 <mj__constraint_solvers__packed_cholesky__factor+0x3a0>
   1ab48:	be b9 00 00 00       	mov    $0xb9,%esi
   1ab4d:	48 8d 3d b4 01 06 00 	lea    0x601b4(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1ab54:	e8 cb 2b 02 00       	call   3d724 <__gnat_rcheck_CE_Overflow_Check>
   1ab59:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   1ab60:	48 8d 34 c5 00 00 00 	lea    0x0(,%rax,8),%rsi
   1ab67:	00 
   1ab68:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
   1ab6f:	44 8b 48 08          	mov    0x8(%rax),%r9d
   1ab73:	44 8b 50 0c          	mov    0xc(%rax),%r10d
   1ab77:	80 bd 47 ff ff ff 00 	cmpb   $0x0,-0xb9(%rbp)
   1ab7e:	0f 85 cb 00 00 00    	jne    1ac4f <mj__constraint_solvers__packed_cholesky__factor+0x61f>
   1ab84:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
   1ab88:	89 f8                	mov    %edi,%eax
   1ab8a:	44 89 65 c0          	mov    %r12d,-0x40(%rbp)
   1ab8e:	44 89 5d a4          	mov    %r11d,-0x5c(%rbp)
   1ab92:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
   1ab96:	4d 89 ec             	mov    %r13,%r12
   1ab99:	ba 01 00 00 00       	mov    $0x1,%edx
   1ab9e:	49 89 dd             	mov    %rbx,%r13
   1aba1:	48 c1 ee 02          	shr    $0x2,%rsi
   1aba5:	48 8d 41 ff          	lea    -0x1(%rcx),%rax
   1aba9:	49 89 f3             	mov    %rsi,%r11
   1abac:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
   1abb3:	49 0f af c0          	imul   %r8,%rax
   1abb7:	49 89 c6             	mov    %rax,%r14
   1abba:	48 89 c8             	mov    %rcx,%rax
   1abbd:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
   1abc4:	48 2b 85 48 ff ff ff 	sub    -0xb8(%rbp),%rax
   1abcb:	48 c1 e9 03          	shr    $0x3,%rcx
   1abcf:	48 0f af c1          	imul   %rcx,%rax
   1abd3:	48 8b 4d 80          	mov    -0x80(%rbp),%rcx
   1abd7:	49 89 c7             	mov    %rax,%r15
   1abda:	eb 07                	jmp    1abe3 <mj__constraint_solvers__packed_cholesky__factor+0x5b3>
   1abdc:	0f 1f 40 00          	nopl   0x0(%rax)
   1abe0:	48 ff c2             	inc    %rdx
   1abe3:	89 d0                	mov    %edx,%eax
   1abe5:	39 d7                	cmp    %edx,%edi
   1abe7:	0f 4e c7             	cmovle %edi,%eax
   1abea:	44 39 c0             	cmp    %r8d,%eax
   1abed:	0f 8f 57 01 00 00    	jg     1ad4a <mj__constraint_solvers__packed_cholesky__factor+0x71a>
   1abf3:	4a 8d 04 32          	lea    (%rdx,%r14,1),%rax
   1abf7:	4c 01 d8             	add    %r11,%rax
   1abfa:	41 8b 04 84          	mov    (%r12,%rax,4),%eax
   1abfe:	85 c0                	test   %eax,%eax
   1ac00:	0f 8e 43 05 00 00    	jle    1b149 <mj__constraint_solvers__packed_cholesky__factor+0xb19>
   1ac06:	39 45 c0             	cmp    %eax,-0x40(%rbp)
   1ac09:	0f 8c 3b 01 00 00    	jl     1ad4a <mj__constraint_solvers__packed_cholesky__factor+0x71a>
   1ac0f:	44 39 c8             	cmp    %r9d,%eax
   1ac12:	0f 8c 32 01 00 00    	jl     1ad4a <mj__constraint_solvers__packed_cholesky__factor+0x71a>
   1ac18:	44 39 d0             	cmp    %r10d,%eax
   1ac1b:	0f 8f 29 01 00 00    	jg     1ad4a <mj__constraint_solvers__packed_cholesky__factor+0x71a>
   1ac21:	48 89 c3             	mov    %rax,%rbx
   1ac24:	48 29 cb             	sub    %rcx,%rbx
   1ac27:	4c 01 fb             	add    %r15,%rbx
   1ac2a:	c5 fb 10 04 de       	vmovsd (%rsi,%rbx,8),%xmm0
   1ac2f:	c4 c1 7b 11 44 c5 f8 	vmovsd %xmm0,-0x8(%r13,%rax,8)
   1ac36:	48 39 55 b8          	cmp    %rdx,-0x48(%rbp)
   1ac3a:	75 a4                	jne    1abe0 <mj__constraint_solvers__packed_cholesky__factor+0x5b0>
   1ac3c:	4c 89 eb             	mov    %r13,%rbx
   1ac3f:	44 8b 5d a4          	mov    -0x5c(%rbp),%r11d
   1ac43:	4d 89 e5             	mov    %r12,%r13
   1ac46:	44 8b 65 c0          	mov    -0x40(%rbp),%r12d
   1ac4a:	e9 0c fb ff ff       	jmp    1a75b <mj__constraint_solvers__packed_cholesky__factor+0x12b>
   1ac4f:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
   1ac53:	44 39 30             	cmp    %r14d,(%rax)
   1ac56:	0f 8f c4 00 00 00    	jg     1ad20 <mj__constraint_solvers__packed_cholesky__factor+0x6f0>
   1ac5c:	44 39 70 04          	cmp    %r14d,0x4(%rax)
   1ac60:	0f 8c ba 00 00 00    	jl     1ad20 <mj__constraint_solvers__packed_cholesky__factor+0x6f0>
   1ac66:	89 f8                	mov    %edi,%eax
   1ac68:	48 89 f2             	mov    %rsi,%rdx
   1ac6b:	48 c1 ea 02          	shr    $0x2,%rdx
   1ac6f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
   1ac73:	49 8d 46 ff          	lea    -0x1(%r14),%rax
   1ac77:	48 8b b5 38 ff ff ff 	mov    -0xc8(%rbp),%rsi
   1ac7e:	44 89 5d b8          	mov    %r11d,-0x48(%rbp)
   1ac82:	c5 fa 7e bd 50 ff ff 	vmovq  -0xb0(%rbp),%xmm7
   1ac89:	ff 
   1ac8a:	b9 01 00 00 00       	mov    $0x1,%ecx
   1ac8f:	49 89 d3             	mov    %rdx,%r11
   1ac92:	49 0f af c0          	imul   %r8,%rax
   1ac96:	c4 e1 f9 6e d8       	vmovq  %rax,%xmm3
   1ac9b:	4c 89 f0             	mov    %r14,%rax
   1ac9e:	48 2b 85 48 ff ff ff 	sub    -0xb8(%rbp),%rax
   1aca5:	c4 c1 f9 7e de       	vmovq  %xmm3,%r14
   1acaa:	48 c1 ee 03          	shr    $0x3,%rsi
   1acae:	48 0f af c6          	imul   %rsi,%rax
   1acb2:	4c 89 ee             	mov    %r13,%rsi
   1acb5:	49 89 dd             	mov    %rbx,%r13
   1acb8:	49 89 c7             	mov    %rax,%r15
   1acbb:	eb 06                	jmp    1acc3 <mj__constraint_solvers__packed_cholesky__factor+0x693>
   1acbd:	0f 1f 00             	nopl   (%rax)
   1acc0:	48 ff c1             	inc    %rcx
   1acc3:	89 c8                	mov    %ecx,%eax
   1acc5:	39 cf                	cmp    %ecx,%edi
   1acc7:	0f 4e c7             	cmovle %edi,%eax
   1acca:	41 39 c0             	cmp    %eax,%r8d
   1accd:	7c 7b                	jl     1ad4a <mj__constraint_solvers__packed_cholesky__factor+0x71a>
   1accf:	4a 8d 04 31          	lea    (%rcx,%r14,1),%rax
   1acd3:	4c 01 d8             	add    %r11,%rax
   1acd6:	8b 04 86             	mov    (%rsi,%rax,4),%eax
   1acd9:	85 c0                	test   %eax,%eax
   1acdb:	0f 8e 68 04 00 00    	jle    1b149 <mj__constraint_solvers__packed_cholesky__factor+0xb19>
   1ace1:	41 39 c4             	cmp    %eax,%r12d
   1ace4:	7c 64                	jl     1ad4a <mj__constraint_solvers__packed_cholesky__factor+0x71a>
   1ace6:	41 39 c1             	cmp    %eax,%r9d
   1ace9:	7f 5f                	jg     1ad4a <mj__constraint_solvers__packed_cholesky__factor+0x71a>
   1aceb:	41 39 c2             	cmp    %eax,%r10d
   1acee:	7c 5a                	jl     1ad4a <mj__constraint_solvers__packed_cholesky__factor+0x71a>
   1acf0:	48 89 c3             	mov    %rax,%rbx
   1acf3:	48 2b 5d 80          	sub    -0x80(%rbp),%rbx
   1acf7:	c4 e1 f9 7e fa       	vmovq  %xmm7,%rdx
   1acfc:	4c 01 fb             	add    %r15,%rbx
   1acff:	c5 fb 10 04 da       	vmovsd (%rdx,%rbx,8),%xmm0
   1ad04:	c4 c1 7b 11 44 c5 f8 	vmovsd %xmm0,-0x8(%r13,%rax,8)
   1ad0b:	48 39 4d c0          	cmp    %rcx,-0x40(%rbp)
   1ad0f:	75 af                	jne    1acc0 <mj__constraint_solvers__packed_cholesky__factor+0x690>
   1ad11:	4c 89 eb             	mov    %r13,%rbx
   1ad14:	44 8b 5d b8          	mov    -0x48(%rbp),%r11d
   1ad18:	49 89 f5             	mov    %rsi,%r13
   1ad1b:	e9 3b fa ff ff       	jmp    1a75b <mj__constraint_solvers__packed_cholesky__factor+0x12b>
   1ad20:	45 85 c0             	test   %r8d,%r8d
   1ad23:	7e 25                	jle    1ad4a <mj__constraint_solvers__packed_cholesky__factor+0x71a>
   1ad25:	4c 89 f0             	mov    %r14,%rax
   1ad28:	48 ff c8             	dec    %rax
   1ad2b:	c4 e1 f9 7e d2       	vmovq  %xmm2,%rdx
   1ad30:	48 0f af c2          	imul   %rdx,%rax
   1ad34:	48 c1 ee 02          	shr    $0x2,%rsi
   1ad38:	48 8d 44 30 01       	lea    0x1(%rax,%rsi,1),%rax
   1ad3d:	41 8b 44 85 00       	mov    0x0(%r13,%rax,4),%eax
   1ad42:	85 c0                	test   %eax,%eax
   1ad44:	0f 8e ff 03 00 00    	jle    1b149 <mj__constraint_solvers__packed_cholesky__factor+0xb19>
   1ad4a:	be b5 00 00 00       	mov    $0xb5,%esi
   1ad4f:	48 8d 3d b2 ff 05 00 	lea    0x5ffb2(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1ad56:	e8 5b 29 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1ad5b:	48 8b bd 70 ff ff ff 	mov    -0x90(%rbp),%rdi
   1ad62:	c5 fb 10 b5 78 ff ff 	vmovsd -0x88(%rbp),%xmm6
   1ad69:	ff 
   1ad6a:	c5 f9 2f 75 c0       	vcomisd -0x40(%rbp),%xmm6
   1ad6f:	8b 37                	mov    (%rdi),%esi
   1ad71:	8b 7f 04             	mov    0x4(%rdi),%edi
   1ad74:	0f 87 57 01 00 00    	ja     1aed1 <mj__constraint_solvers__packed_cholesky__factor+0x8a1>
   1ad7a:	c5 fb 10 15 56 e0 05 	vmovsd 0x5e056(%rip),%xmm2        # 78dd8 <_IO_stdin_used+0x2318>
   1ad81:	00 
   1ad82:	45 39 45 00          	cmp    %r8d,0x0(%r13)
   1ad86:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
   1ad8a:	41 b8 01 00 00 00    	mov    $0x1,%r8d
   1ad90:	c5 eb 5e d0          	vdivsd %xmm0,%xmm2,%xmm2
   1ad94:	0f 8d 84 01 00 00    	jge    1af1e <mj__constraint_solvers__packed_cholesky__factor+0x8ee>
   1ad9a:	4c 8b 9d 60 ff ff ff 	mov    -0xa0(%rbp),%r11
   1ada1:	4c 8b 7d b0          	mov    -0x50(%rbp),%r15
   1ada5:	4c 8d 72 ff          	lea    -0x1(%rdx),%r14
   1ada9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   1adb0:	41 8b 55 00          	mov    0x0(%r13),%edx
   1adb4:	44 39 c2             	cmp    %r8d,%edx
   1adb7:	0f 8c 91 02 00 00    	jl     1b04e <mj__constraint_solvers__packed_cholesky__factor+0xa1e>
   1adbd:	4d 89 f2             	mov    %r14,%r10
   1adc0:	4c 0f af d2          	imul   %rdx,%r10
   1adc4:	4d 01 c2             	add    %r8,%r10
   1adc7:	49 8d 14 52          	lea    (%r10,%rdx,2),%rdx
   1adcb:	41 8b 54 95 00       	mov    0x0(%r13,%rdx,4),%edx
   1add0:	85 d2                	test   %edx,%edx
   1add2:	0f 8e 76 02 00 00    	jle    1b04e <mj__constraint_solvers__packed_cholesky__factor+0xa1e>
   1add8:	41 39 d4             	cmp    %edx,%r12d
   1addb:	0f 8c 6d 02 00 00    	jl     1b04e <mj__constraint_solvers__packed_cholesky__factor+0xa1e>
   1ade1:	c5 eb 59 4c d3 f8    	vmulsd -0x8(%rbx,%rdx,8),%xmm2,%xmm1
   1ade7:	c5 f9 2e 0d 19 e1 05 	vucomisd 0x5e119(%rip),%xmm1        # 78f08 <_IO_stdin_used+0x2448>
   1adee:	00 
   1adef:	0f 82 09 02 00 00    	jb     1affe <mj__constraint_solvers__packed_cholesky__factor+0x9ce>
   1adf5:	c5 f9 2e e9          	vucomisd %xmm1,%xmm5
   1adf9:	0f 82 ff 01 00 00    	jb     1affe <mj__constraint_solvers__packed_cholesky__factor+0x9ce>
   1adff:	89 ca                	mov    %ecx,%edx
   1ae01:	44 01 c2             	add    %r8d,%edx
   1ae04:	0f 80 d9 02 00 00    	jo     1b0e3 <mj__constraint_solvers__packed_cholesky__factor+0xab3>
   1ae0a:	ff ca                	dec    %edx
   1ae0c:	39 d6                	cmp    %edx,%esi
   1ae0e:	0f 8f e0 02 00 00    	jg     1b0f4 <mj__constraint_solvers__packed_cholesky__factor+0xac4>
   1ae14:	39 d7                	cmp    %edx,%edi
   1ae16:	0f 8c d8 02 00 00    	jl     1b0f4 <mj__constraint_solvers__packed_cholesky__factor+0xac4>
   1ae1c:	48 63 d2             	movslq %edx,%rdx
   1ae1f:	49 ff c0             	inc    %r8
   1ae22:	4c 29 da             	sub    %r11,%rdx
   1ae25:	c4 c1 7b 11 0c d7    	vmovsd %xmm1,(%r15,%rdx,8)
   1ae2b:	49 39 c0             	cmp    %rax,%r8
   1ae2e:	75 80                	jne    1adb0 <mj__constraint_solvers__packed_cholesky__factor+0x780>
   1ae30:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1ae34:	41 8b 44 85 00       	mov    0x0(%r13,%rax,4),%eax
   1ae39:	e9 f6 f9 ff ff       	jmp    1a834 <mj__constraint_solvers__packed_cholesky__factor+0x204>
   1ae3e:	c5 f9 28 c1          	vmovapd %xmm1,%xmm0
   1ae42:	e9 71 f9 ff ff       	jmp    1a7b8 <mj__constraint_solvers__packed_cholesky__factor+0x188>
   1ae47:	49 89 c6             	mov    %rax,%r14
   1ae4a:	49 63 45 00          	movslq 0x0(%r13),%rax
   1ae4e:	41 89 c8             	mov    %ecx,%r8d
   1ae51:	ba 01 00 00 00       	mov    $0x1,%edx
   1ae56:	4d 8d 4e ff          	lea    -0x1(%r14),%r9
   1ae5a:	48 8d 34 c5 00 00 00 	lea    0x0(,%rax,8),%rsi
   1ae61:	00 
   1ae62:	4c 0f af c8          	imul   %rax,%r9
   1ae66:	48 89 c7             	mov    %rax,%rdi
   1ae69:	48 c1 ee 02          	shr    $0x2,%rsi
   1ae6d:	eb 1b                	jmp    1ae8a <mj__constraint_solvers__packed_cholesky__factor+0x85a>
   1ae6f:	90                   	nop
   1ae70:	41 39 c4             	cmp    %eax,%r12d
   1ae73:	7c 30                	jl     1aea5 <mj__constraint_solvers__packed_cholesky__factor+0x875>
   1ae75:	48 c7 44 c3 f8 00 00 	movq   $0x0,-0x8(%rbx,%rax,8)
   1ae7c:	00 00 
   1ae7e:	49 39 d0             	cmp    %rdx,%r8
   1ae81:	0f 84 03 fa ff ff    	je     1a88a <mj__constraint_solvers__packed_cholesky__factor+0x25a>
   1ae87:	48 ff c2             	inc    %rdx
   1ae8a:	89 d0                	mov    %edx,%eax
   1ae8c:	39 d1                	cmp    %edx,%ecx
   1ae8e:	0f 4e c1             	cmovle %ecx,%eax
   1ae91:	39 f8                	cmp    %edi,%eax
   1ae93:	7f 10                	jg     1aea5 <mj__constraint_solvers__packed_cholesky__factor+0x875>
   1ae95:	4a 8d 04 0a          	lea    (%rdx,%r9,1),%rax
   1ae99:	48 01 f0             	add    %rsi,%rax
   1ae9c:	41 8b 44 85 00       	mov    0x0(%r13,%rax,4),%eax
   1aea1:	85 c0                	test   %eax,%eax
   1aea3:	7f cb                	jg     1ae70 <mj__constraint_solvers__packed_cholesky__factor+0x840>
   1aea5:	be c7 00 00 00       	mov    $0xc7,%esi
   1aeaa:	48 8d 3d 57 fe 05 00 	lea    0x5fe57(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1aeb1:	e8 00 28 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1aeb6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
   1aebd:	00 00 00 
   1aec0:	be 9d 00 00 00       	mov    $0x9d,%esi
   1aec5:	48 8d 3d 3c fe 05 00 	lea    0x5fe3c(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1aecc:	e8 e5 27 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1aed1:	4c 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%r10
   1aed8:	4c 8b 5d b0          	mov    -0x50(%rbp),%r11
   1aedc:	0f 1f 40 00          	nopl   0x0(%rax)
   1aee0:	ff c2                	inc    %edx
   1aee2:	89 d0                	mov    %edx,%eax
   1aee4:	01 c8                	add    %ecx,%eax
   1aee6:	0f 80 f7 01 00 00    	jo     1b0e3 <mj__constraint_solvers__packed_cholesky__factor+0xab3>
   1aeec:	ff c8                	dec    %eax
   1aeee:	39 c6                	cmp    %eax,%esi
   1aef0:	0f 8f fe 01 00 00    	jg     1b0f4 <mj__constraint_solvers__packed_cholesky__factor+0xac4>
   1aef6:	39 c7                	cmp    %eax,%edi
   1aef8:	0f 8c f6 01 00 00    	jl     1b0f4 <mj__constraint_solvers__packed_cholesky__factor+0xac4>
   1aefe:	48 98                	cltq
   1af00:	4c 29 d0             	sub    %r10,%rax
   1af03:	49 c7 04 c3 00 00 00 	movq   $0x0,(%r11,%rax,8)
   1af0a:	00 
   1af0b:	41 39 d0             	cmp    %edx,%r8d
   1af0e:	75 d0                	jne    1aee0 <mj__constraint_solvers__packed_cholesky__factor+0x8b0>
   1af10:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1af14:	41 8b 44 85 00       	mov    0x0(%r13,%rax,4),%eax
   1af19:	e9 16 f9 ff ff       	jmp    1a834 <mj__constraint_solvers__packed_cholesky__factor+0x204>
   1af1e:	44 89 4d c0          	mov    %r9d,-0x40(%rbp)
   1af22:	4c 8b 9d 60 ff ff ff 	mov    -0xa0(%rbp),%r11
   1af29:	4c 8b 4d b0          	mov    -0x50(%rbp),%r9
   1af2d:	4c 8d 7a ff          	lea    -0x1(%rdx),%r15
   1af31:	49 ba ff ff ff ff ff 	movabs $0x3fffffffffffffff,%r10
   1af38:	ff ff 3f 
   1af3b:	41 89 c6             	mov    %eax,%r14d
   1af3e:	c4 e1 f9 6e f3       	vmovq  %rbx,%xmm6
   1af43:	66 90                	xchg   %ax,%ax
   1af45:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1af4c:	00 00 00 00 
   1af50:	49 63 55 00          	movslq 0x0(%r13),%rdx
   1af54:	48 89 d0             	mov    %rdx,%rax
   1af57:	4c 21 d0             	and    %r10,%rax
   1af5a:	48 c1 e2 03          	shl    $0x3,%rdx
   1af5e:	49 0f af c7          	imul   %r15,%rax
   1af62:	48 c1 ea 02          	shr    $0x2,%rdx
   1af66:	48 89 d3             	mov    %rdx,%rbx
   1af69:	49 8d 14 00          	lea    (%r8,%rax,1),%rdx
   1af6d:	48 01 da             	add    %rbx,%rdx
   1af70:	41 8b 54 95 00       	mov    0x0(%r13,%rdx,4),%edx
   1af75:	85 d2                	test   %edx,%edx
   1af77:	0f 8e d1 00 00 00    	jle    1b04e <mj__constraint_solvers__packed_cholesky__factor+0xa1e>
   1af7d:	41 39 d4             	cmp    %edx,%r12d
   1af80:	0f 8c c8 00 00 00    	jl     1b04e <mj__constraint_solvers__packed_cholesky__factor+0xa1e>
   1af86:	c4 e1 f9 7e f0       	vmovq  %xmm6,%rax
   1af8b:	c5 eb 59 4c d0 f8    	vmulsd -0x8(%rax,%rdx,8),%xmm2,%xmm1
   1af91:	c5 f9 2e 0d 6f df 05 	vucomisd 0x5df6f(%rip),%xmm1        # 78f08 <_IO_stdin_used+0x2448>
   1af98:	00 
   1af99:	72 63                	jb     1affe <mj__constraint_solvers__packed_cholesky__factor+0x9ce>
   1af9b:	c5 f9 2e e9          	vucomisd %xmm1,%xmm5
   1af9f:	72 5d                	jb     1affe <mj__constraint_solvers__packed_cholesky__factor+0x9ce>
   1afa1:	89 ca                	mov    %ecx,%edx
   1afa3:	44 01 c2             	add    %r8d,%edx
   1afa6:	0f 80 37 01 00 00    	jo     1b0e3 <mj__constraint_solvers__packed_cholesky__factor+0xab3>
   1afac:	ff ca                	dec    %edx
   1afae:	39 d6                	cmp    %edx,%esi
   1afb0:	0f 8f 3e 01 00 00    	jg     1b0f4 <mj__constraint_solvers__packed_cholesky__factor+0xac4>
   1afb6:	39 d7                	cmp    %edx,%edi
   1afb8:	0f 8c 36 01 00 00    	jl     1b0f4 <mj__constraint_solvers__packed_cholesky__factor+0xac4>
   1afbe:	48 63 d2             	movslq %edx,%rdx
   1afc1:	49 ff c0             	inc    %r8
   1afc4:	4c 29 da             	sub    %r11,%rdx
   1afc7:	c4 c1 7b 11 0c d1    	vmovsd %xmm1,(%r9,%rdx,8)
   1afcd:	4d 39 f0             	cmp    %r14,%r8
   1afd0:	0f 85 7a ff ff ff    	jne    1af50 <mj__constraint_solvers__packed_cholesky__factor+0x920>
   1afd6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   1afda:	44 8b 4d c0          	mov    -0x40(%rbp),%r9d
   1afde:	c4 e1 f9 7e f3       	vmovq  %xmm6,%rbx
   1afe3:	41 8b 44 85 00       	mov    0x0(%r13,%rax,4),%eax
   1afe8:	e9 47 f8 ff ff       	jmp    1a834 <mj__constraint_solvers__packed_cholesky__factor+0x204>
   1afed:	be 9a 00 00 00       	mov    $0x9a,%esi
   1aff2:	48 8d 3d 0f fd 05 00 	lea    0x5fd0f(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1aff9:	e8 b8 26 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1affe:	b8 02 00 00 00       	mov    $0x2,%eax
   1b003:	48 89 c2             	mov    %rax,%rdx
   1b006:	48 c1 e2 20          	shl    $0x20,%rdx
   1b00a:	8b 45 88             	mov    -0x78(%rbp),%eax
   1b00d:	48 09 d0             	or     %rdx,%rax
   1b010:	48 8d 65 d8          	lea    -0x28(%rbp),%rsp
   1b014:	5b                   	pop    %rbx
   1b015:	41 5c                	pop    %r12
   1b017:	41 5d                	pop    %r13
   1b019:	41 5e                	pop    %r14
   1b01b:	41 5f                	pop    %r15
   1b01d:	5d                   	pop    %rbp
   1b01e:	c3                   	ret
   1b01f:	be 9d 00 00 00       	mov    $0x9d,%esi
   1b024:	48 8d 3d dd fc 05 00 	lea    0x5fcdd(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b02b:	e8 f4 26 02 00       	call   3d724 <__gnat_rcheck_CE_Overflow_Check>
   1b030:	4c 89 eb             	mov    %r13,%rbx
   1b033:	c4 41 f9 7e f5       	vmovq  %xmm14,%r13
   1b038:	e9 52 f7 ff ff       	jmp    1a78f <mj__constraint_solvers__packed_cholesky__factor+0x15f>
   1b03d:	be 9a 00 00 00       	mov    $0x9a,%esi
   1b042:	48 8d 3d bf fc 05 00 	lea    0x5fcbf(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b049:	e8 02 27 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b04e:	be c2 00 00 00       	mov    $0xc2,%esi
   1b053:	48 8d 3d ae fc 05 00 	lea    0x5fcae(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b05a:	e8 57 26 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b05f:	be b3 00 00 00       	mov    $0xb3,%esi
   1b064:	48 8d 3d 9d fc 05 00 	lea    0x5fc9d(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b06b:	e8 5c 26 02 00       	call   3d6cc <__gnat_rcheck_CE_Invalid_Data>
   1b070:	be b9 00 00 00       	mov    $0xb9,%esi
   1b075:	48 8d 3d 8c fc 05 00 	lea    0x5fc8c(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b07c:	e8 cf 26 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b081:	be b7 00 00 00       	mov    $0xb7,%esi
   1b086:	48 8d 3d 7b fc 05 00 	lea    0x5fc7b(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b08d:	e8 3a 26 02 00       	call   3d6cc <__gnat_rcheck_CE_Invalid_Data>
   1b092:	be bc 00 00 00       	mov    $0xbc,%esi
   1b097:	48 8d 3d 6a fc 05 00 	lea    0x5fc6a(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b09e:	e8 ad 26 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b0a3:	66 90                	xchg   %ax,%ax
   1b0a5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
   1b0ac:	00 00 00 00 
   1b0b0:	be 1d 00 00 00       	mov    $0x1d,%esi
   1b0b5:	48 8d 3d 7c fc 05 00 	lea    0x5fc7c(%rip),%rdi        # 7ad38 <mj__constraint_solvers__cholesky_updates__statusS+0x48>
   1b0bc:	e8 63 26 02 00       	call   3d724 <__gnat_rcheck_CE_Overflow_Check>
   1b0c1:	be 1d 00 00 00       	mov    $0x1d,%esi
   1b0c6:	48 8d 3d 6b fc 05 00 	lea    0x5fc6b(%rip),%rdi        # 7ad38 <mj__constraint_solvers__cholesky_updates__statusS+0x48>
   1b0cd:	e8 e4 25 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b0d2:	be b8 00 00 00       	mov    $0xb8,%esi
   1b0d7:	48 8d 3d 2a fc 05 00 	lea    0x5fc2a(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b0de:	e8 6d 26 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b0e3:	be c4 00 00 00       	mov    $0xc4,%esi
   1b0e8:	48 8d 3d 19 fc 05 00 	lea    0x5fc19(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b0ef:	e8 30 26 02 00       	call   3d724 <__gnat_rcheck_CE_Overflow_Check>
   1b0f4:	be c4 00 00 00       	mov    $0xc4,%esi
   1b0f9:	48 8d 3d 08 fc 05 00 	lea    0x5fc08(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b100:	e8 b1 25 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b105:	be c6 00 00 00       	mov    $0xc6,%esi
   1b10a:	48 8d 3d f7 fb 05 00 	lea    0x5fbf7(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b111:	e8 a0 25 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b116:	be c6 00 00 00       	mov    $0xc6,%esi
   1b11b:	48 8d 3d e6 fb 05 00 	lea    0x5fbe6(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b122:	e8 29 26 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b127:	be b4 00 00 00       	mov    $0xb4,%esi
   1b12c:	48 8d 3d d5 fb 05 00 	lea    0x5fbd5(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b133:	e8 94 25 02 00       	call   3d6cc <__gnat_rcheck_CE_Invalid_Data>
   1b138:	be 93 00 00 00       	mov    $0x93,%esi
   1b13d:	48 8d 3d c4 fb 05 00 	lea    0x5fbc4(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b144:	e8 6d 25 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b149:	be b5 00 00 00       	mov    $0xb5,%esi
   1b14e:	48 8d 3d b3 fb 05 00 	lea    0x5fbb3(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b155:	e8 f6 25 02 00       	call   3d750 <__gnat_rcheck_CE_Range_Check>
   1b15a:	be b8 00 00 00       	mov    $0xb8,%esi
   1b15f:	48 8d 3d a2 fb 05 00 	lea    0x5fba2(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b166:	e8 4b 25 02 00       	call   3d6b6 <__gnat_rcheck_CE_Index_Check>
   1b16b:	be c7 00 00 00       	mov    $0xc7,%esi
   1b170:	48 8d 3d 91 fb 05 00 	lea    0x5fb91(%rip),%rdi        # 7ad08 <mj__constraint_solvers__cholesky_updates__statusS+0x18>
   1b177:	e8 50 25 02 00       	call   3d6cc <__gnat_rcheck_CE_Invalid_Data>

Disassembly of section .fini:
