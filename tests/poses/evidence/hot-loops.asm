0000000000003c60 <adapter__run_7>:
    3c60:	55                   	push   rbp
    3c61:	89 f8                	mov    eax,edi
    3c63:	48 89 e5             	mov    rbp,rsp
    3c66:	48 6b c0 38          	imul   rax,rax,0x38
    3c6a:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    3c6e:	4c 01 c0             	add    rax,r8
    3c71:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    3c75:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    3c7c:	00 00 00 00 
    3c80:	c5 fd 10 4e 18       	vmovupd ymm1,YMMWORD PTR [rsi+0x18]
    3c85:	c5 fd 10 52 18       	vmovupd ymm2,YMMWORD PTR [rdx+0x18]
    3c8a:	c4 e2 7d 19 c1       	vbroadcastsd ymm0,xmm1
    3c8f:	c4 e3 fd 01 ea 4e    	vpermpd ymm5,ymm2,0x4e
    3c95:	c4 e3 fd 01 e2 1b    	vpermpd ymm4,ymm2,0x1b
    3c9b:	c4 e3 fd 01 d9 55    	vpermpd ymm3,ymm1,0x55
    3ca1:	c5 fd 59 c2          	vmulpd ymm0,ymm0,ymm2
    3ca5:	c4 e3 7d 05 d2 05    	vpermilpd ymm2,ymm2,0x5
    3cab:	c5 e5 59 d2          	vmulpd ymm2,ymm3,ymm2
    3caf:	c5 fd d0 c2          	vaddsubpd ymm0,ymm0,ymm2
    3cb3:	c4 e3 fd 01 d1 aa    	vpermpd ymm2,ymm1,0xaa
    3cb9:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    3cbf:	c5 ed 59 d5          	vmulpd ymm2,ymm2,ymm5
    3cc3:	c5 f5 59 cc          	vmulpd ymm1,ymm1,ymm4
    3cc7:	c5 fd 5c da          	vsubpd ymm3,ymm0,ymm2
    3ccb:	c5 fd 58 c2          	vaddpd ymm0,ymm0,ymm2
    3ccf:	c4 e3 7d 0d c3 09    	vblendpd ymm0,ymm0,ymm3,0x9
    3cd5:	c5 fd 5c d1          	vsubpd ymm2,ymm0,ymm1
    3cd9:	c5 fd 58 c1          	vaddpd ymm0,ymm0,ymm1
    3cdd:	c4 e3 7d 0d c2 03    	vblendpd ymm0,ymm0,ymm2,0x3
    3ce3:	c5 fd 29 44 24 e0    	vmovapd YMMWORD PTR [rsp-0x20],ymm0
    3ce9:	c4 c1 7e 7f 40 18    	vmovdqu YMMWORD PTR [r8+0x18],ymm0
    3cef:	49 83 c0 38          	add    r8,0x38
    3cf3:	4c 39 c0             	cmp    rax,r8
    3cf6:	75 88                	jne    3c80 <adapter__run_7+0x20>
    3cf8:	c5 f8 77             	vzeroupper
    3cfb:	c9                   	leave
    3cfc:	c3                   	ret
    3cfd:	0f 1f 00             	nop    DWORD PTR [rax]

0000000000003d00 <adapter__run_4>:
    3d00:	c5 7b 10 0d d8 9a 02 	vmovsd xmm9,QWORD PTR [rip+0x29ad8]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    3d07:	00 
    3d08:	89 ff                	mov    edi,edi
    3d0a:	48 89 c8             	mov    rax,rcx
    3d0d:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    3d12:	48 6b ff 38          	imul   rdi,rdi,0x38
    3d16:	4c 01 c7             	add    rdi,r8
    3d19:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    3d20:	c4 41 7b 10 58 08    	vmovsd xmm11,QWORD PTR [r8+0x8]
    3d26:	c4 c1 7b 10 38       	vmovsd xmm7,QWORD PTR [r8]
    3d2b:	c4 c1 7b 10 58 20    	vmovsd xmm3,QWORD PTR [r8+0x20]
    3d31:	c4 c1 7b 10 70 28    	vmovsd xmm6,QWORD PTR [r8+0x28]
    3d37:	c4 c1 7b 10 68 30    	vmovsd xmm5,QWORD PTR [r8+0x30]
    3d3d:	c5 e1 57 05 6b bd 02 	vxorpd xmm0,xmm3,XMMWORD PTR [rip+0x2bd6b]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3d44:	00 
    3d45:	c5 c9 57 25 63 bd 02 	vxorpd xmm4,xmm6,XMMWORD PTR [rip+0x2bd63]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3d4c:	00 
    3d4d:	c5 d1 57 0d 5b bd 02 	vxorpd xmm1,xmm5,XMMWORD PTR [rip+0x2bd5b]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3d54:	00 
    3d55:	c4 41 7b 10 50 10    	vmovsd xmm10,QWORD PTR [r8+0x10]
    3d5b:	c4 c1 7b 10 50 18    	vmovsd xmm2,QWORD PTR [r8+0x18]
    3d61:	c4 41 79 2f d8       	vcomisd xmm11,xmm8
    3d66:	41 0f 94 c1          	sete   r9b
    3d6a:	c4 c1 79 2f f8       	vcomisd xmm7,xmm8
    3d6f:	c4 c1 7b 11 40 20    	vmovsd QWORD PTR [r8+0x20],xmm0
    3d75:	c4 c1 7b 11 60 28    	vmovsd QWORD PTR [r8+0x28],xmm4
    3d7b:	0f 94 c1             	sete   cl
    3d7e:	c4 c1 7b 11 48 30    	vmovsd QWORD PTR [r8+0x30],xmm1
    3d84:	41 84 c9             	test   r9b,cl
    3d87:	74 0b                	je     3d94 <adapter__run_4+0x94>
    3d89:	c4 41 79 2f d0       	vcomisd xmm10,xmm8
    3d8e:	0f 84 ec 00 00 00    	je     3e80 <adapter__run_4+0x180>
    3d94:	c4 c1 79 2f d8       	vcomisd xmm3,xmm8
    3d99:	41 0f 94 c1          	sete   r9b
    3d9d:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    3da2:	0f 94 c1             	sete   cl
    3da5:	41 84 c9             	test   r9b,cl
    3da8:	74 1a                	je     3dc4 <adapter__run_4+0xc4>
    3daa:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    3daf:	41 0f 94 c1          	sete   r9b
    3db3:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    3db8:	0f 94 c1             	sete   cl
    3dbb:	41 84 c9             	test   r9b,cl
    3dbe:	0f 85 dc 00 00 00    	jne    3ea0 <adapter__run_4+0x1a0>
    3dc4:	c5 ab 59 dc          	vmulsd xmm3,xmm10,xmm4
    3dc8:	c5 c3 59 ea          	vmulsd xmm5,xmm7,xmm2
    3dcc:	c5 a3 59 f2          	vmulsd xmm6,xmm11,xmm2
    3dd0:	c5 ab 59 d2          	vmulsd xmm2,xmm10,xmm2
    3dd4:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    3dd8:	c5 a3 59 d9          	vmulsd xmm3,xmm11,xmm1
    3ddc:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    3de0:	c5 c3 59 d9          	vmulsd xmm3,xmm7,xmm1
    3de4:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    3de8:	c5 ab 59 d8          	vmulsd xmm3,xmm10,xmm0
    3dec:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    3df0:	c5 a3 59 d8          	vmulsd xmm3,xmm11,xmm0
    3df4:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    3df8:	c5 c3 59 dc          	vmulsd xmm3,xmm7,xmm4
    3dfc:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    3e00:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    3e04:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    3e08:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    3e0c:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    3e10:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    3e14:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    3e18:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    3e1d:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    3e21:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    3e25:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    3e29:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    3e2d:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    3e31:	c5 e3 58 df          	vaddsd xmm3,xmm3,xmm7
    3e35:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    3e3a:	c5 e1 57 1d 6e bc 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2bc6e]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3e41:	00 
    3e42:	c5 f1 57 0d 66 bc 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2bc66]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3e49:	00 
    3e4a:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    3e4f:	c5 f9 57 05 59 bc 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2bc59]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3e56:	00 
    3e57:	c4 c1 7b 11 18       	vmovsd QWORD PTR [r8],xmm3
    3e5c:	c4 c1 7b 11 48 08    	vmovsd QWORD PTR [r8+0x8],xmm1
    3e62:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    3e68:	49 83 c0 38          	add    r8,0x38
    3e6c:	49 39 f8             	cmp    r8,rdi
    3e6f:	0f 85 ab fe ff ff    	jne    3d20 <adapter__run_4+0x20>
    3e75:	c3                   	ret
    3e76:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    3e7d:	00 00 00 
    3e80:	c5 fb 10 05 28 bc 02 	vmovsd xmm0,QWORD PTR [rip+0x2bc28]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3e87:	00 
    3e88:	c5 f9 28 c8          	vmovapd xmm1,xmm0
    3e8c:	c5 f9 28 d8          	vmovapd xmm3,xmm0
    3e90:	eb c5                	jmp    3e57 <adapter__run_4+0x157>
    3e92:	0f 1f 00             	nop    DWORD PTR [rax]
    3e95:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    3e9c:	00 00 00 00 
    3ea0:	c5 c1 57 1d 08 bc 02 	vxorpd xmm3,xmm7,XMMWORD PTR [rip+0x2bc08]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3ea7:	00 
    3ea8:	c5 a1 57 0d 00 bc 02 	vxorpd xmm1,xmm11,XMMWORD PTR [rip+0x2bc00]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3eaf:	00 
    3eb0:	c5 a9 57 05 f8 bb 02 	vxorpd xmm0,xmm10,XMMWORD PTR [rip+0x2bbf8]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    3eb7:	00 
    3eb8:	eb 9d                	jmp    3e57 <adapter__run_4+0x157>
    3eba:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000003ec0 <adapter__run_5>:
    3ec0:	89 f8                	mov    eax,edi
    3ec2:	c4 41 31 57 c9       	vxorpd xmm9,xmm9,xmm9
    3ec7:	48 6b c0 38          	imul   rax,rax,0x38
    3ecb:	4c 01 c0             	add    rax,r8
    3ece:	eb 38                	jmp    3f08 <adapter__run_5+0x48>
    3ed0:	c4 41 79 2f e9       	vcomisd xmm13,xmm9
    3ed5:	75 60                	jne    3f37 <adapter__run_5+0x77>
    3ed7:	c5 e9 15 ca          	vunpckhpd xmm1,xmm2,xmm2
    3edb:	c4 c1 79 2f c9       	vcomisd xmm1,xmm9
    3ee0:	75 55                	jne    3f37 <adapter__run_5+0x77>
    3ee2:	c4 c1 39 58 d2       	vaddpd xmm2,xmm8,xmm10
    3ee7:	c5 a3 58 c7          	vaddsd xmm0,xmm11,xmm7
    3eeb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    3ef0:	c4 c1 79 11 10       	vmovupd XMMWORD PTR [r8],xmm2
    3ef5:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    3efb:	49 83 c0 38          	add    r8,0x38
    3eff:	49 39 c0             	cmp    r8,rax
    3f02:	0f 84 b8 00 00 00    	je     3fc0 <adapter__run_5+0x100>
    3f08:	c5 f9 28 66 20       	vmovapd xmm4,XMMWORD PTR [rsi+0x20]
    3f0d:	c5 f9 10 41 08       	vmovupd xmm0,XMMWORD PTR [rcx+0x8]
    3f12:	c5 f9 10 56 28       	vmovupd xmm2,XMMWORD PTR [rsi+0x28]
    3f17:	c5 79 28 11          	vmovapd xmm10,XMMWORD PTR [rcx]
    3f1b:	c5 79 28 06          	vmovapd xmm8,XMMWORD PTR [rsi]
    3f1f:	c5 fb 10 7e 10       	vmovsd xmm7,QWORD PTR [rsi+0x10]
    3f24:	c4 c1 79 2f e1       	vcomisd xmm4,xmm9
    3f29:	c5 59 15 ec          	vunpckhpd xmm13,xmm4,xmm4
    3f2d:	c5 79 28 e4          	vmovapd xmm12,xmm4
    3f31:	c5 79 15 d8          	vunpckhpd xmm11,xmm0,xmm0
    3f35:	74 99                	je     3ed0 <adapter__run_5+0x10>
    3f37:	c5 fb 12 31          	vmovddup xmm6,QWORD PTR [rcx]
    3f3b:	c5 fb 12 6e 18       	vmovddup xmm5,QWORD PTR [rsi+0x18]
    3f40:	c5 fb 10 5e 30       	vmovsd xmm3,QWORD PTR [rsi+0x30]
    3f45:	c5 e1 16 5e 20       	vmovhpd xmm3,xmm3,QWORD PTR [rsi+0x20]
    3f4a:	c5 51 59 f0          	vmulpd xmm14,xmm5,xmm0
    3f4e:	c4 c1 61 59 ca       	vmulpd xmm1,xmm3,xmm10
    3f53:	c5 f9 15 f6          	vunpckhpd xmm6,xmm0,xmm6
    3f57:	c5 d1 59 ee          	vmulpd xmm5,xmm5,xmm6
    3f5b:	c5 f9 59 c4          	vmulpd xmm0,xmm0,xmm4
    3f5f:	c4 c1 71 58 ce       	vaddpd xmm1,xmm1,xmm14
    3f64:	c5 49 59 f4          	vmulpd xmm14,xmm6,xmm4
    3f68:	c4 c1 69 59 e2       	vmulpd xmm4,xmm2,xmm10
    3f6d:	c5 f9 58 c5          	vaddpd xmm0,xmm0,xmm5
    3f71:	c4 c1 71 5c ce       	vsubpd xmm1,xmm1,xmm14
    3f76:	c5 f9 5c c4          	vsubpd xmm0,xmm0,xmm4
    3f7a:	c5 f1 59 db          	vmulpd xmm3,xmm1,xmm3
    3f7e:	c4 c1 73 59 cc       	vmulsd xmm1,xmm1,xmm12
    3f83:	c5 f9 59 d2          	vmulpd xmm2,xmm0,xmm2
    3f87:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    3f8b:	c4 c1 7b 59 c5       	vmulsd xmm0,xmm0,xmm13
    3f90:	c5 e9 5c d3          	vsubpd xmm2,xmm2,xmm3
    3f94:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    3f98:	c5 e9 58 d2          	vaddpd xmm2,xmm2,xmm2
    3f9c:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    3fa0:	c4 c1 69 58 d2       	vaddpd xmm2,xmm2,xmm10
    3fa5:	c4 c1 7b 58 c3       	vaddsd xmm0,xmm0,xmm11
    3faa:	c4 c1 69 58 d0       	vaddpd xmm2,xmm2,xmm8
    3faf:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    3fb3:	e9 38 ff ff ff       	jmp    3ef0 <adapter__run_5+0x30>
    3fb8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    3fbf:	00 
    3fc0:	c3                   	ret
    3fc1:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    3fc8:	00 00 00 
    3fcb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000003fd0 <adapter__run_6>:
    3fd0:	89 f8                	mov    eax,edi
    3fd2:	c4 41 31 57 c9       	vxorpd xmm9,xmm9,xmm9
    3fd7:	48 6b c0 38          	imul   rax,rax,0x38
    3fdb:	4c 01 c0             	add    rax,r8
    3fde:	eb 38                	jmp    4018 <adapter__run_6+0x48>
    3fe0:	c4 41 79 2f e9       	vcomisd xmm13,xmm9
    3fe5:	75 62                	jne    4049 <adapter__run_6+0x79>
    3fe7:	c5 e9 15 ca          	vunpckhpd xmm1,xmm2,xmm2
    3feb:	c4 c1 79 2f c9       	vcomisd xmm1,xmm9
    3ff0:	75 57                	jne    4049 <adapter__run_6+0x79>
    3ff2:	c4 c1 39 58 d2       	vaddpd xmm2,xmm8,xmm10
    3ff7:	c5 a3 58 c7          	vaddsd xmm0,xmm11,xmm7
    3ffb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    4000:	c4 c1 79 11 10       	vmovupd XMMWORD PTR [r8],xmm2
    4005:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    400b:	49 83 c0 38          	add    r8,0x38
    400f:	49 39 c0             	cmp    r8,rax
    4012:	0f 84 b8 00 00 00    	je     40d0 <adapter__run_6+0x100>
    4018:	c5 f9 28 46 20       	vmovapd xmm0,XMMWORD PTR [rsi+0x20]
    401d:	c4 c1 79 10 60 08    	vmovupd xmm4,XMMWORD PTR [r8+0x8]
    4023:	c4 41 79 10 10       	vmovupd xmm10,XMMWORD PTR [r8]
    4028:	c5 f9 10 56 28       	vmovupd xmm2,XMMWORD PTR [rsi+0x28]
    402d:	c5 79 28 06          	vmovapd xmm8,XMMWORD PTR [rsi]
    4031:	c5 fb 10 7e 10       	vmovsd xmm7,QWORD PTR [rsi+0x10]
    4036:	c4 c1 79 2f c1       	vcomisd xmm0,xmm9
    403b:	c5 59 15 dc          	vunpckhpd xmm11,xmm4,xmm4
    403f:	c5 79 28 e0          	vmovapd xmm12,xmm0
    4043:	c5 79 15 e8          	vunpckhpd xmm13,xmm0,xmm0
    4047:	74 97                	je     3fe0 <adapter__run_6+0x10>
    4049:	c5 fb 12 6e 18       	vmovddup xmm5,QWORD PTR [rsi+0x18]
    404e:	c5 fb 10 5e 30       	vmovsd xmm3,QWORD PTR [rsi+0x30]
    4053:	c5 e1 16 5e 20       	vmovhpd xmm3,xmm3,QWORD PTR [rsi+0x20]
    4058:	c4 c1 7b 12 30       	vmovddup xmm6,QWORD PTR [r8]
    405d:	c5 51 59 f4          	vmulpd xmm14,xmm5,xmm4
    4061:	c4 c1 61 59 ca       	vmulpd xmm1,xmm3,xmm10
    4066:	c5 d9 15 f6          	vunpckhpd xmm6,xmm4,xmm6
    406a:	c5 d1 59 ee          	vmulpd xmm5,xmm5,xmm6
    406e:	c4 c1 71 58 ce       	vaddpd xmm1,xmm1,xmm14
    4073:	c5 79 59 f6          	vmulpd xmm14,xmm0,xmm6
    4077:	c5 f9 59 c4          	vmulpd xmm0,xmm0,xmm4
    407b:	c4 c1 69 59 e2       	vmulpd xmm4,xmm2,xmm10
    4080:	c5 f9 58 c5          	vaddpd xmm0,xmm0,xmm5
    4084:	c4 c1 71 5c ce       	vsubpd xmm1,xmm1,xmm14
    4089:	c5 f9 5c c4          	vsubpd xmm0,xmm0,xmm4
    408d:	c5 f1 59 db          	vmulpd xmm3,xmm1,xmm3
    4091:	c4 c1 73 59 cc       	vmulsd xmm1,xmm1,xmm12
    4096:	c5 f9 59 d2          	vmulpd xmm2,xmm0,xmm2
    409a:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    409e:	c4 c1 7b 59 c5       	vmulsd xmm0,xmm0,xmm13
    40a3:	c5 e9 5c d3          	vsubpd xmm2,xmm2,xmm3
    40a7:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    40ab:	c5 e9 58 d2          	vaddpd xmm2,xmm2,xmm2
    40af:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    40b3:	c4 c1 69 58 d2       	vaddpd xmm2,xmm2,xmm10
    40b8:	c4 c1 7b 58 c3       	vaddsd xmm0,xmm0,xmm11
    40bd:	c4 c1 69 58 d0       	vaddpd xmm2,xmm2,xmm8
    40c2:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    40c6:	e9 35 ff ff ff       	jmp    4000 <adapter__run_6+0x30>
    40cb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    40d0:	c3                   	ret
    40d1:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    40d8:	00 00 00 
    40db:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

00000000000040e0 <c_run_7.constprop.0>:
    40e0:	48 8d 81 c0 01 00 00 	lea    rax,[rcx+0x1c0]
    40e7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    40ee:	00 00 
    40f0:	c5 fd 10 4f 18       	vmovupd ymm1,YMMWORD PTR [rdi+0x18]
    40f5:	c5 fd 10 56 18       	vmovupd ymm2,YMMWORD PTR [rsi+0x18]
    40fa:	c4 e2 7d 19 c1       	vbroadcastsd ymm0,xmm1
    40ff:	c4 e3 fd 01 ea 4e    	vpermpd ymm5,ymm2,0x4e
    4105:	c4 e3 fd 01 e2 1b    	vpermpd ymm4,ymm2,0x1b
    410b:	c4 e3 fd 01 d9 55    	vpermpd ymm3,ymm1,0x55
    4111:	c5 fd 59 c2          	vmulpd ymm0,ymm0,ymm2
    4115:	c4 e3 7d 05 d2 05    	vpermilpd ymm2,ymm2,0x5
    411b:	c5 e5 59 d2          	vmulpd ymm2,ymm3,ymm2
    411f:	c5 fd d0 c2          	vaddsubpd ymm0,ymm0,ymm2
    4123:	c4 e3 fd 01 d1 aa    	vpermpd ymm2,ymm1,0xaa
    4129:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    412f:	c5 ed 59 d5          	vmulpd ymm2,ymm2,ymm5
    4133:	c5 f5 59 cc          	vmulpd ymm1,ymm1,ymm4
    4137:	c5 fd 5c da          	vsubpd ymm3,ymm0,ymm2
    413b:	c5 fd 58 c2          	vaddpd ymm0,ymm0,ymm2
    413f:	c4 e3 7d 0d c3 09    	vblendpd ymm0,ymm0,ymm3,0x9
    4145:	c5 fd 5c d1          	vsubpd ymm2,ymm0,ymm1
    4149:	c5 fd 58 c1          	vaddpd ymm0,ymm0,ymm1
    414d:	c4 e3 7d 0d c2 03    	vblendpd ymm0,ymm0,ymm2,0x3
    4153:	c5 fd 11 41 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm0
    4158:	48 83 c1 38          	add    rcx,0x38
    415c:	48 39 c1             	cmp    rcx,rax
    415f:	75 8f                	jne    40f0 <c_run_7.constprop.0+0x10>
    4161:	c5 f8 77             	vzeroupper
    4164:	c3                   	ret
    4165:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    416c:	00 00 00 
    416f:	90                   	nop

0000000000004170 <c_run_7>:
    4170:	89 f8                	mov    eax,edi
    4172:	48 6b c0 38          	imul   rax,rax,0x38
    4176:	4c 01 c0             	add    rax,r8
    4179:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    4180:	c5 fd 10 4e 18       	vmovupd ymm1,YMMWORD PTR [rsi+0x18]
    4185:	c5 fd 10 52 18       	vmovupd ymm2,YMMWORD PTR [rdx+0x18]
    418a:	c4 e2 7d 19 c1       	vbroadcastsd ymm0,xmm1
    418f:	c4 e3 fd 01 ea 4e    	vpermpd ymm5,ymm2,0x4e
    4195:	c4 e3 fd 01 e2 1b    	vpermpd ymm4,ymm2,0x1b
    419b:	c4 e3 fd 01 d9 55    	vpermpd ymm3,ymm1,0x55
    41a1:	c5 fd 59 c2          	vmulpd ymm0,ymm0,ymm2
    41a5:	c4 e3 7d 05 d2 05    	vpermilpd ymm2,ymm2,0x5
    41ab:	c5 e5 59 d2          	vmulpd ymm2,ymm3,ymm2
    41af:	c5 fd d0 c2          	vaddsubpd ymm0,ymm0,ymm2
    41b3:	c4 e3 fd 01 d1 aa    	vpermpd ymm2,ymm1,0xaa
    41b9:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    41bf:	c5 ed 59 d5          	vmulpd ymm2,ymm2,ymm5
    41c3:	c5 f5 59 cc          	vmulpd ymm1,ymm1,ymm4
    41c7:	c5 fd 5c da          	vsubpd ymm3,ymm0,ymm2
    41cb:	c5 fd 58 c2          	vaddpd ymm0,ymm0,ymm2
    41cf:	c4 e3 7d 0d c3 09    	vblendpd ymm0,ymm0,ymm3,0x9
    41d5:	c5 fd 5c d1          	vsubpd ymm2,ymm0,ymm1
    41d9:	c5 fd 58 c1          	vaddpd ymm0,ymm0,ymm1
    41dd:	c4 e3 7d 0d c2 03    	vblendpd ymm0,ymm0,ymm2,0x3
    41e3:	c4 c1 7d 11 40 18    	vmovupd YMMWORD PTR [r8+0x18],ymm0
    41e9:	49 83 c0 38          	add    r8,0x38
    41ed:	49 39 c0             	cmp    r8,rax
    41f0:	75 8e                	jne    4180 <c_run_7+0x10>
    41f2:	c5 f8 77             	vzeroupper
    41f5:	c3                   	ret
    41f6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    41fd:	00 00 00 

0000000000004200 <c_run_3.constprop.0>:
    4200:	c5 7b 10 0d d8 95 02 	vmovsd xmm9,QWORD PTR [rip+0x295d8]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    4207:	00 
    4208:	48 89 f8             	mov    rax,rdi
    420b:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    4210:	48 8d b9 c0 01 00 00 	lea    rdi,[rcx+0x1c0]
    4217:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    421e:	00 00 
    4220:	c5 fb 10 70 28       	vmovsd xmm6,QWORD PTR [rax+0x28]
    4225:	c5 fb 10 68 30       	vmovsd xmm5,QWORD PTR [rax+0x30]
    422a:	c5 fb 10 50 18       	vmovsd xmm2,QWORD PTR [rax+0x18]
    422f:	c5 7b 10 60 20       	vmovsd xmm12,QWORD PTR [rax+0x20]
    4234:	c5 c9 57 25 74 b8 02 	vxorpd xmm4,xmm6,XMMWORD PTR [rip+0x2b874]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    423b:	00 
    423c:	c5 99 57 05 6c b8 02 	vxorpd xmm0,xmm12,XMMWORD PTR [rip+0x2b86c]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4243:	00 
    4244:	c5 d1 57 0d 64 b8 02 	vxorpd xmm1,xmm5,XMMWORD PTR [rip+0x2b864]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    424b:	00 
    424c:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    4251:	c5 d9 14 f9          	vunpcklpd xmm7,xmm4,xmm1
    4255:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    4259:	41 0f 94 c1          	sete   r9b
    425d:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    4262:	62 f3 e5 28 18 df 01 	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    4269:	41 0f 94 c0          	sete   r8b
    426d:	c5 fd 11 59 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm3
    4272:	c5 7b 10 10          	vmovsd xmm10,QWORD PTR [rax]
    4276:	c5 fb 10 78 10       	vmovsd xmm7,QWORD PTR [rax+0x10]
    427b:	c5 7b 10 58 08       	vmovsd xmm11,QWORD PTR [rax+0x8]
    4280:	45 84 c1             	test   r9b,r8b
    4283:	74 1b                	je     42a0 <c_run_3.constprop.0+0xa0>
    4285:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    428a:	41 0f 94 c1          	sete   r9b
    428e:	c4 41 79 2f e0       	vcomisd xmm12,xmm8
    4293:	41 0f 94 c0          	sete   r8b
    4297:	45 84 c1             	test   r9b,r8b
    429a:	0f 85 b8 00 00 00    	jne    4358 <c_run_3.constprop.0+0x158>
    42a0:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    42a4:	c4 c1 6b 59 ea       	vmulsd xmm5,xmm2,xmm10
    42a9:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    42ae:	c5 eb 59 d7          	vmulsd xmm2,xmm2,xmm7
    42b2:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    42b6:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    42bb:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    42bf:	c4 c1 73 59 da       	vmulsd xmm3,xmm1,xmm10
    42c4:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    42c8:	c5 fb 59 df          	vmulsd xmm3,xmm0,xmm7
    42cc:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    42d0:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    42d5:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    42d9:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    42de:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    42e2:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    42e6:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    42ea:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    42ee:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    42f2:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    42f6:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    42fa:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    42ff:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    4303:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    4307:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    430b:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    430f:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4313:	c4 c1 63 58 da       	vaddsd xmm3,xmm3,xmm10
    4318:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    431d:	c5 e1 57 1d 8b b7 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2b78b]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4324:	00 
    4325:	c5 f1 57 0d 83 b7 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2b783]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    432c:	00 
    432d:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4331:	c5 f9 57 05 77 b7 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2b777]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4338:	00 
    4339:	c5 fb 11 19          	vmovsd QWORD PTR [rcx],xmm3
    433d:	c5 fb 11 49 08       	vmovsd QWORD PTR [rcx+0x8],xmm1
    4342:	c5 fb 11 41 10       	vmovsd QWORD PTR [rcx+0x10],xmm0
    4347:	48 83 c1 38          	add    rcx,0x38
    434b:	48 39 f9             	cmp    rcx,rdi
    434e:	0f 85 cc fe ff ff    	jne    4220 <c_run_3.constprop.0+0x20>
    4354:	c5 f8 77             	vzeroupper
    4357:	c3                   	ret
    4358:	c5 29 57 15 50 b7 02 	vxorpd xmm10,xmm10,XMMWORD PTR [rip+0x2b750]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    435f:	00 
    4360:	c5 21 57 1d 48 b7 02 	vxorpd xmm11,xmm11,XMMWORD PTR [rip+0x2b748]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4367:	00 
    4368:	c5 c1 57 3d 40 b7 02 	vxorpd xmm7,xmm7,XMMWORD PTR [rip+0x2b740]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    436f:	00 
    4370:	c5 7b 11 11          	vmovsd QWORD PTR [rcx],xmm10
    4374:	c5 7b 11 59 08       	vmovsd QWORD PTR [rcx+0x8],xmm11
    4379:	c5 fb 11 79 10       	vmovsd QWORD PTR [rcx+0x10],xmm7
    437e:	48 83 c1 38          	add    rcx,0x38
    4382:	48 39 f9             	cmp    rcx,rdi
    4385:	0f 85 95 fe ff ff    	jne    4220 <c_run_3.constprop.0+0x20>
    438b:	eb c7                	jmp    4354 <c_run_3.constprop.0+0x154>
    438d:	0f 1f 00             	nop    DWORD PTR [rax]

0000000000004390 <c_run_3>:
    4390:	c5 7b 10 0d 48 94 02 	vmovsd xmm9,QWORD PTR [rip+0x29448]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    4397:	00 
    4398:	48 89 f0             	mov    rax,rsi
    439b:	89 fe                	mov    esi,edi
    439d:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    43a2:	48 6b f6 38          	imul   rsi,rsi,0x38
    43a6:	4c 01 c6             	add    rsi,r8
    43a9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    43b0:	c5 fb 10 70 28       	vmovsd xmm6,QWORD PTR [rax+0x28]
    43b5:	c5 fb 10 68 30       	vmovsd xmm5,QWORD PTR [rax+0x30]
    43ba:	c5 fb 10 50 18       	vmovsd xmm2,QWORD PTR [rax+0x18]
    43bf:	c5 7b 10 60 20       	vmovsd xmm12,QWORD PTR [rax+0x20]
    43c4:	c5 c9 57 25 e4 b6 02 	vxorpd xmm4,xmm6,XMMWORD PTR [rip+0x2b6e4]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    43cb:	00 
    43cc:	c5 99 57 05 dc b6 02 	vxorpd xmm0,xmm12,XMMWORD PTR [rip+0x2b6dc]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    43d3:	00 
    43d4:	c5 d1 57 0d d4 b6 02 	vxorpd xmm1,xmm5,XMMWORD PTR [rip+0x2b6d4]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    43db:	00 
    43dc:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    43e1:	c5 d9 14 f9          	vunpcklpd xmm7,xmm4,xmm1
    43e5:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    43e9:	41 0f 94 c1          	sete   r9b
    43ed:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    43f2:	62 f3 e5 28 18 df 01 	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    43f9:	40 0f 94 c7          	sete   dil
    43fd:	c4 c1 7d 11 58 18    	vmovupd YMMWORD PTR [r8+0x18],ymm3
    4403:	c5 7b 10 10          	vmovsd xmm10,QWORD PTR [rax]
    4407:	c5 fb 10 78 10       	vmovsd xmm7,QWORD PTR [rax+0x10]
    440c:	c5 7b 10 58 08       	vmovsd xmm11,QWORD PTR [rax+0x8]
    4411:	41 84 f9             	test   r9b,dil
    4414:	74 1b                	je     4431 <c_run_3+0xa1>
    4416:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    441b:	41 0f 94 c1          	sete   r9b
    441f:	c4 41 79 2f e0       	vcomisd xmm12,xmm8
    4424:	40 0f 94 c7          	sete   dil
    4428:	41 84 f9             	test   r9b,dil
    442b:	0f 85 bf 00 00 00    	jne    44f0 <c_run_3+0x160>
    4431:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    4435:	c4 c1 6b 59 ea       	vmulsd xmm5,xmm2,xmm10
    443a:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    443f:	c5 eb 59 d7          	vmulsd xmm2,xmm2,xmm7
    4443:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    4447:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    444c:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    4450:	c4 c1 73 59 da       	vmulsd xmm3,xmm1,xmm10
    4455:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    4459:	c5 fb 59 df          	vmulsd xmm3,xmm0,xmm7
    445d:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    4461:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    4466:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    446a:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    446f:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    4473:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    4477:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    447b:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    447f:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    4483:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    4487:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    448b:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    4490:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    4494:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    4498:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    449c:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    44a0:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    44a4:	c4 c1 63 58 da       	vaddsd xmm3,xmm3,xmm10
    44a9:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    44ae:	c5 e1 57 1d fa b5 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2b5fa]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    44b5:	00 
    44b6:	c5 f1 57 0d f2 b5 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2b5f2]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    44bd:	00 
    44be:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    44c2:	c5 f9 57 05 e6 b5 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2b5e6]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    44c9:	00 
    44ca:	c4 c1 7b 11 18       	vmovsd QWORD PTR [r8],xmm3
    44cf:	c4 c1 7b 11 48 08    	vmovsd QWORD PTR [r8+0x8],xmm1
    44d5:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    44db:	49 83 c0 38          	add    r8,0x38
    44df:	49 39 f0             	cmp    r8,rsi
    44e2:	0f 85 c8 fe ff ff    	jne    43b0 <c_run_3+0x20>
    44e8:	c5 f8 77             	vzeroupper
    44eb:	c3                   	ret
    44ec:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    44f0:	c5 29 57 15 b8 b5 02 	vxorpd xmm10,xmm10,XMMWORD PTR [rip+0x2b5b8]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    44f7:	00 
    44f8:	c5 21 57 1d b0 b5 02 	vxorpd xmm11,xmm11,XMMWORD PTR [rip+0x2b5b0]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    44ff:	00 
    4500:	c5 c1 57 3d a8 b5 02 	vxorpd xmm7,xmm7,XMMWORD PTR [rip+0x2b5a8]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4507:	00 
    4508:	c4 41 7b 11 10       	vmovsd QWORD PTR [r8],xmm10
    450d:	c4 41 7b 11 58 08    	vmovsd QWORD PTR [r8+0x8],xmm11
    4513:	c4 c1 7b 11 78 10    	vmovsd QWORD PTR [r8+0x10],xmm7
    4519:	49 83 c0 38          	add    r8,0x38
    451d:	49 39 f0             	cmp    r8,rsi
    4520:	0f 85 8a fe ff ff    	jne    43b0 <c_run_3+0x20>
    4526:	eb c0                	jmp    44e8 <c_run_3+0x158>
    4528:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    452f:	00 

0000000000004530 <c_run_5.constprop.0>:
    4530:	c5 7b 10 1d a8 92 02 	vmovsd xmm11,QWORD PTR [rip+0x292a8]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    4537:	00 
    4538:	48 8d 81 c0 01 00 00 	lea    rax,[rcx+0x1c0]
    453f:	c4 41 19 57 e4       	vxorpd xmm12,xmm12,xmm12
    4544:	eb 59                	jmp    459f <c_run_5.constprop.0+0x6f>
    4546:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    454d:	00 00 00 
    4550:	c4 c1 79 2f f4       	vcomisd xmm6,xmm12
    4555:	75 73                	jne    45ca <c_run_5.constprop.0+0x9a>
    4557:	c4 41 79 2f d4       	vcomisd xmm10,xmm12
    455c:	75 6c                	jne    45ca <c_run_5.constprop.0+0x9a>
    455e:	c5 e9 15 e2          	vunpckhpd xmm4,xmm2,xmm2
    4562:	c4 c1 79 2f e4       	vcomisd xmm4,xmm12
    4567:	75 61                	jne    45ca <c_run_5.constprop.0+0x9a>
    4569:	c5 f9 11 19          	vmovupd XMMWORD PTR [rcx],xmm3
    456d:	c5 fb 11 69 10       	vmovsd QWORD PTR [rcx+0x10],xmm5
    4572:	0f 1f 00             	nop    DWORD PTR [rax]
    4575:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    457c:	00 00 00 00 
    4580:	c5 e1 58 1f          	vaddpd xmm3,xmm3,XMMWORD PTR [rdi]
    4584:	c5 d3 58 6f 10       	vaddsd xmm5,xmm5,QWORD PTR [rdi+0x10]
    4589:	c5 f9 11 19          	vmovupd XMMWORD PTR [rcx],xmm3
    458d:	c5 fb 11 69 10       	vmovsd QWORD PTR [rcx+0x10],xmm5
    4592:	48 83 c1 38          	add    rcx,0x38
    4596:	48 39 c8             	cmp    rax,rcx
    4599:	0f 84 b1 00 00 00    	je     4650 <c_run_5.constprop.0+0x120>
    459f:	c5 f9 10 4f 18       	vmovupd xmm1,XMMWORD PTR [rdi+0x18]
    45a4:	c5 f9 28 77 20       	vmovapd xmm6,XMMWORD PTR [rdi+0x20]
    45a9:	c5 f9 10 42 08       	vmovupd xmm0,XMMWORD PTR [rdx+0x8]
    45ae:	c5 f9 10 57 28       	vmovupd xmm2,XMMWORD PTR [rdi+0x28]
    45b3:	c5 f9 28 1a          	vmovapd xmm3,XMMWORD PTR [rdx]
    45b7:	c4 c1 79 2f cb       	vcomisd xmm1,xmm11
    45bc:	c5 49 15 d6          	vunpckhpd xmm10,xmm6,xmm6
    45c0:	c5 79 28 ce          	vmovapd xmm9,xmm6
    45c4:	c5 f9 15 e8          	vunpckhpd xmm5,xmm0,xmm0
    45c8:	74 86                	je     4550 <c_run_5.constprop.0+0x20>
    45ca:	c4 63 79 05 c1 00    	vpermilpd xmm8,xmm1,0x0
    45d0:	c5 e9 15 e1          	vunpckhpd xmm4,xmm2,xmm1
    45d4:	c5 f9 c6 fb 01       	vshufpd xmm7,xmm0,xmm3,0x1
    45d9:	c5 d9 59 cb          	vmulpd xmm1,xmm4,xmm3
    45dd:	c4 41 79 59 e8       	vmulpd xmm13,xmm0,xmm8
    45e2:	c5 f9 59 c6          	vmulpd xmm0,xmm0,xmm6
    45e6:	c4 c1 71 58 cd       	vaddpd xmm1,xmm1,xmm13
    45eb:	c5 41 59 ee          	vmulpd xmm13,xmm7,xmm6
    45ef:	c4 c1 41 59 f8       	vmulpd xmm7,xmm7,xmm8
    45f4:	c5 e9 59 f3          	vmulpd xmm6,xmm2,xmm3
    45f8:	c5 f9 58 c7          	vaddpd xmm0,xmm0,xmm7
    45fc:	c4 c1 71 5c cd       	vsubpd xmm1,xmm1,xmm13
    4601:	c5 f9 5c c6          	vsubpd xmm0,xmm0,xmm6
    4605:	c5 f1 59 e4          	vmulpd xmm4,xmm1,xmm4
    4609:	c4 c1 73 59 c9       	vmulsd xmm1,xmm1,xmm9
    460e:	c5 e9 59 d0          	vmulpd xmm2,xmm2,xmm0
    4612:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    4616:	c4 c1 7b 59 c2       	vmulsd xmm0,xmm0,xmm10
    461b:	c5 e9 5c d4          	vsubpd xmm2,xmm2,xmm4
    461f:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    4623:	c5 e9 58 d2          	vaddpd xmm2,xmm2,xmm2
    4627:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    462b:	c5 e1 58 da          	vaddpd xmm3,xmm3,xmm2
    462f:	c5 d3 58 e8          	vaddsd xmm5,xmm5,xmm0
    4633:	c5 f9 11 19          	vmovupd XMMWORD PTR [rcx],xmm3
    4637:	c5 fb 11 69 10       	vmovsd QWORD PTR [rcx+0x10],xmm5
    463c:	e9 3f ff ff ff       	jmp    4580 <c_run_5.constprop.0+0x50>
    4641:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    4645:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    464c:	00 00 00 00 
    4650:	c3                   	ret
    4651:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    4658:	00 00 00 
    465b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000004660 <c_run_5>:
    4660:	48 89 f0             	mov    rax,rsi
    4663:	89 fe                	mov    esi,edi
    4665:	c5 7b 10 1d 73 91 02 	vmovsd xmm11,QWORD PTR [rip+0x29173]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    466c:	00 
    466d:	c4 41 19 57 e4       	vxorpd xmm12,xmm12,xmm12
    4672:	48 6b f6 38          	imul   rsi,rsi,0x38
    4676:	4c 01 c6             	add    rsi,r8
    4679:	eb 56                	jmp    46d1 <c_run_5+0x71>
    467b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    4680:	c4 c1 79 2f f4       	vcomisd xmm6,xmm12
    4685:	75 75                	jne    46fc <c_run_5+0x9c>
    4687:	c4 41 79 2f d4       	vcomisd xmm10,xmm12
    468c:	75 6e                	jne    46fc <c_run_5+0x9c>
    468e:	c5 e9 15 e2          	vunpckhpd xmm4,xmm2,xmm2
    4692:	c4 c1 79 2f e4       	vcomisd xmm4,xmm12
    4697:	75 63                	jne    46fc <c_run_5+0x9c>
    4699:	c4 c1 79 11 18       	vmovupd XMMWORD PTR [r8],xmm3
    469e:	c4 c1 7b 11 68 10    	vmovsd QWORD PTR [r8+0x10],xmm5
    46a4:	90                   	nop
    46a5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    46ac:	00 00 00 00 
    46b0:	c5 e1 58 18          	vaddpd xmm3,xmm3,XMMWORD PTR [rax]
    46b4:	c5 d3 58 68 10       	vaddsd xmm5,xmm5,QWORD PTR [rax+0x10]
    46b9:	c4 c1 79 11 18       	vmovupd XMMWORD PTR [r8],xmm3
    46be:	c4 c1 7b 11 68 10    	vmovsd QWORD PTR [r8+0x10],xmm5
    46c4:	49 83 c0 38          	add    r8,0x38
    46c8:	4c 39 c6             	cmp    rsi,r8
    46cb:	0f 84 af 00 00 00    	je     4780 <c_run_5+0x120>
    46d1:	c5 f9 10 48 18       	vmovupd xmm1,XMMWORD PTR [rax+0x18]
    46d6:	c5 f9 28 70 20       	vmovapd xmm6,XMMWORD PTR [rax+0x20]
    46db:	c5 f9 10 41 08       	vmovupd xmm0,XMMWORD PTR [rcx+0x8]
    46e0:	c5 f9 10 50 28       	vmovupd xmm2,XMMWORD PTR [rax+0x28]
    46e5:	c5 f9 28 19          	vmovapd xmm3,XMMWORD PTR [rcx]
    46e9:	c4 c1 79 2f cb       	vcomisd xmm1,xmm11
    46ee:	c5 49 15 d6          	vunpckhpd xmm10,xmm6,xmm6
    46f2:	c5 79 28 ce          	vmovapd xmm9,xmm6
    46f6:	c5 f9 15 e8          	vunpckhpd xmm5,xmm0,xmm0
    46fa:	74 84                	je     4680 <c_run_5+0x20>
    46fc:	c4 63 79 05 c1 00    	vpermilpd xmm8,xmm1,0x0
    4702:	c5 e9 15 e1          	vunpckhpd xmm4,xmm2,xmm1
    4706:	c5 f9 c6 fb 01       	vshufpd xmm7,xmm0,xmm3,0x1
    470b:	c5 d9 59 cb          	vmulpd xmm1,xmm4,xmm3
    470f:	c4 41 79 59 e8       	vmulpd xmm13,xmm0,xmm8
    4714:	c5 f9 59 c6          	vmulpd xmm0,xmm0,xmm6
    4718:	c4 c1 71 58 cd       	vaddpd xmm1,xmm1,xmm13
    471d:	c5 41 59 ee          	vmulpd xmm13,xmm7,xmm6
    4721:	c4 c1 41 59 f8       	vmulpd xmm7,xmm7,xmm8
    4726:	c5 e9 59 f3          	vmulpd xmm6,xmm2,xmm3
    472a:	c5 f9 58 c7          	vaddpd xmm0,xmm0,xmm7
    472e:	c4 c1 71 5c cd       	vsubpd xmm1,xmm1,xmm13
    4733:	c5 f9 5c c6          	vsubpd xmm0,xmm0,xmm6
    4737:	c5 f1 59 e4          	vmulpd xmm4,xmm1,xmm4
    473b:	c4 c1 73 59 c9       	vmulsd xmm1,xmm1,xmm9
    4740:	c5 e9 59 d0          	vmulpd xmm2,xmm2,xmm0
    4744:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    4748:	c4 c1 7b 59 c2       	vmulsd xmm0,xmm0,xmm10
    474d:	c5 e9 5c d4          	vsubpd xmm2,xmm2,xmm4
    4751:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    4755:	c5 e9 58 d2          	vaddpd xmm2,xmm2,xmm2
    4759:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    475d:	c5 e1 58 da          	vaddpd xmm3,xmm3,xmm2
    4761:	c5 d3 58 e8          	vaddsd xmm5,xmm5,xmm0
    4765:	c4 c1 79 11 18       	vmovupd XMMWORD PTR [r8],xmm3
    476a:	c4 c1 7b 11 68 10    	vmovsd QWORD PTR [r8+0x10],xmm5
    4770:	e9 3b ff ff ff       	jmp    46b0 <c_run_5+0x50>
    4775:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    477c:	00 00 00 00 
    4780:	c3                   	ret
    4781:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    4788:	00 00 00 
    478b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000004790 <c_run_6.constprop.0>:
    4790:	c5 7b 10 15 48 90 02 	vmovsd xmm10,QWORD PTR [rip+0x29048]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    4797:	00 
    4798:	48 89 f8             	mov    rax,rdi
    479b:	c4 41 21 57 db       	vxorpd xmm11,xmm11,xmm11
    47a0:	48 8d b9 c0 01 00 00 	lea    rdi,[rcx+0x1c0]
    47a7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    47ae:	00 00 
    47b0:	c5 fb 10 40 18       	vmovsd xmm0,QWORD PTR [rax+0x18]
    47b5:	c5 fb 10 29          	vmovsd xmm5,QWORD PTR [rcx]
    47b9:	c5 fb 10 61 08       	vmovsd xmm4,QWORD PTR [rcx+0x8]
    47be:	c5 fb 10 59 10       	vmovsd xmm3,QWORD PTR [rcx+0x10]
    47c3:	c5 7b 10 40 20       	vmovsd xmm8,QWORD PTR [rax+0x20]
    47c8:	c5 7b 10 48 28       	vmovsd xmm9,QWORD PTR [rax+0x28]
    47cd:	c5 fb 10 50 30       	vmovsd xmm2,QWORD PTR [rax+0x30]
    47d2:	c4 c1 79 2f c2       	vcomisd xmm0,xmm10
    47d7:	75 27                	jne    4800 <c_run_6.constprop.0+0x70>
    47d9:	c4 41 79 2f c3       	vcomisd xmm8,xmm11
    47de:	75 20                	jne    4800 <c_run_6.constprop.0+0x70>
    47e0:	c4 41 79 2f cb       	vcomisd xmm9,xmm11
    47e5:	75 19                	jne    4800 <c_run_6.constprop.0+0x70>
    47e7:	c4 c1 79 2f d3       	vcomisd xmm2,xmm11
    47ec:	0f 84 9d 00 00 00    	je     488f <c_run_6.constprop.0+0xff>
    47f2:	0f 1f 00             	nop    DWORD PTR [rax]
    47f5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    47fc:	00 00 00 00 
    4800:	c5 d3 59 f0          	vmulsd xmm6,xmm5,xmm0
    4804:	c4 c1 63 59 c9       	vmulsd xmm1,xmm3,xmm9
    4809:	c5 d3 59 fa          	vmulsd xmm7,xmm5,xmm2
    480d:	c5 cb 58 f1          	vaddsd xmm6,xmm6,xmm1
    4811:	c5 db 59 ca          	vmulsd xmm1,xmm4,xmm2
    4815:	c5 cb 5c f1          	vsubsd xmm6,xmm6,xmm1
    4819:	c5 db 59 c8          	vmulsd xmm1,xmm4,xmm0
    481d:	c5 e3 59 c0          	vmulsd xmm0,xmm3,xmm0
    4821:	c5 f3 58 cf          	vaddsd xmm1,xmm1,xmm7
    4825:	c4 c1 63 59 f8       	vmulsd xmm7,xmm3,xmm8
    482a:	c5 f3 5c cf          	vsubsd xmm1,xmm1,xmm7
    482e:	c4 c1 5b 59 f8       	vmulsd xmm7,xmm4,xmm8
    4833:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4837:	c4 c1 53 59 f9       	vmulsd xmm7,xmm5,xmm9
    483c:	c5 73 59 e2          	vmulsd xmm12,xmm1,xmm2
    4840:	c5 cb 59 d2          	vmulsd xmm2,xmm6,xmm2
    4844:	c4 c1 4b 59 f1       	vmulsd xmm6,xmm6,xmm9
    4849:	c5 fb 5c c7          	vsubsd xmm0,xmm0,xmm7
    484d:	c4 c1 7b 59 f9       	vmulsd xmm7,xmm0,xmm9
    4852:	c4 c1 7b 59 c0       	vmulsd xmm0,xmm0,xmm8
    4857:	c5 eb 5c d0          	vsubsd xmm2,xmm2,xmm0
    485b:	c4 c1 73 59 c0       	vmulsd xmm0,xmm1,xmm8
    4860:	c4 c1 43 5c fc       	vsubsd xmm7,xmm7,xmm12
    4865:	c5 fb 5c c6          	vsubsd xmm0,xmm0,xmm6
    4869:	c5 c3 58 ff          	vaddsd xmm7,xmm7,xmm7
    486d:	c5 eb 58 d2          	vaddsd xmm2,xmm2,xmm2
    4871:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4875:	c5 d3 58 ef          	vaddsd xmm5,xmm5,xmm7
    4879:	c5 db 58 e2          	vaddsd xmm4,xmm4,xmm2
    487d:	c5 e3 58 d8          	vaddsd xmm3,xmm3,xmm0
    4881:	c5 fb 11 29          	vmovsd QWORD PTR [rcx],xmm5
    4885:	c5 fb 11 61 08       	vmovsd QWORD PTR [rcx+0x8],xmm4
    488a:	c5 fb 11 59 10       	vmovsd QWORD PTR [rcx+0x10],xmm3
    488f:	c5 d3 58 28          	vaddsd xmm5,xmm5,QWORD PTR [rax]
    4893:	c5 db 58 60 08       	vaddsd xmm4,xmm4,QWORD PTR [rax+0x8]
    4898:	c5 e3 58 58 10       	vaddsd xmm3,xmm3,QWORD PTR [rax+0x10]
    489d:	c5 fb 11 29          	vmovsd QWORD PTR [rcx],xmm5
    48a1:	c5 fb 11 61 08       	vmovsd QWORD PTR [rcx+0x8],xmm4
    48a6:	c5 fb 11 59 10       	vmovsd QWORD PTR [rcx+0x10],xmm3
    48ab:	48 83 c1 38          	add    rcx,0x38
    48af:	48 39 cf             	cmp    rdi,rcx
    48b2:	0f 85 f8 fe ff ff    	jne    47b0 <c_run_6.constprop.0+0x20>
    48b8:	c3                   	ret
    48b9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000048c0 <c_run_6>:
    48c0:	c5 7b 10 15 18 8f 02 	vmovsd xmm10,QWORD PTR [rip+0x28f18]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    48c7:	00 
    48c8:	48 89 f0             	mov    rax,rsi
    48cb:	48 89 d6             	mov    rsi,rdx
    48ce:	48 89 ca             	mov    rdx,rcx
    48d1:	89 f9                	mov    ecx,edi
    48d3:	c4 41 21 57 db       	vxorpd xmm11,xmm11,xmm11
    48d8:	48 6b c9 38          	imul   rcx,rcx,0x38
    48dc:	4c 01 c1             	add    rcx,r8
    48df:	90                   	nop
    48e0:	c5 fb 10 40 18       	vmovsd xmm0,QWORD PTR [rax+0x18]
    48e5:	c4 c1 7b 10 28       	vmovsd xmm5,QWORD PTR [r8]
    48ea:	c4 c1 7b 10 60 08    	vmovsd xmm4,QWORD PTR [r8+0x8]
    48f0:	c4 c1 7b 10 58 10    	vmovsd xmm3,QWORD PTR [r8+0x10]
    48f6:	c5 7b 10 40 20       	vmovsd xmm8,QWORD PTR [rax+0x20]
    48fb:	c5 7b 10 48 28       	vmovsd xmm9,QWORD PTR [rax+0x28]
    4900:	c5 fb 10 50 30       	vmovsd xmm2,QWORD PTR [rax+0x30]
    4905:	c4 c1 79 2f c2       	vcomisd xmm0,xmm10
    490a:	75 24                	jne    4930 <c_run_6+0x70>
    490c:	c4 41 79 2f c3       	vcomisd xmm8,xmm11
    4911:	75 1d                	jne    4930 <c_run_6+0x70>
    4913:	c4 41 79 2f cb       	vcomisd xmm9,xmm11
    4918:	75 16                	jne    4930 <c_run_6+0x70>
    491a:	c4 c1 79 2f d3       	vcomisd xmm2,xmm11
    491f:	0f 84 9d 00 00 00    	je     49c2 <c_run_6+0x102>
    4925:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    492c:	00 00 00 00 
    4930:	c5 d3 59 f0          	vmulsd xmm6,xmm5,xmm0
    4934:	c4 c1 63 59 c9       	vmulsd xmm1,xmm3,xmm9
    4939:	c5 d3 59 fa          	vmulsd xmm7,xmm5,xmm2
    493d:	c5 cb 58 f1          	vaddsd xmm6,xmm6,xmm1
    4941:	c5 db 59 ca          	vmulsd xmm1,xmm4,xmm2
    4945:	c5 cb 5c f1          	vsubsd xmm6,xmm6,xmm1
    4949:	c5 db 59 c8          	vmulsd xmm1,xmm4,xmm0
    494d:	c5 e3 59 c0          	vmulsd xmm0,xmm3,xmm0
    4951:	c5 f3 58 cf          	vaddsd xmm1,xmm1,xmm7
    4955:	c4 c1 63 59 f8       	vmulsd xmm7,xmm3,xmm8
    495a:	c5 f3 5c cf          	vsubsd xmm1,xmm1,xmm7
    495e:	c4 c1 5b 59 f8       	vmulsd xmm7,xmm4,xmm8
    4963:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4967:	c4 c1 53 59 f9       	vmulsd xmm7,xmm5,xmm9
    496c:	c5 73 59 e2          	vmulsd xmm12,xmm1,xmm2
    4970:	c5 cb 59 d2          	vmulsd xmm2,xmm6,xmm2
    4974:	c4 c1 4b 59 f1       	vmulsd xmm6,xmm6,xmm9
    4979:	c5 fb 5c c7          	vsubsd xmm0,xmm0,xmm7
    497d:	c4 c1 7b 59 f9       	vmulsd xmm7,xmm0,xmm9
    4982:	c4 c1 7b 59 c0       	vmulsd xmm0,xmm0,xmm8
    4987:	c5 eb 5c d0          	vsubsd xmm2,xmm2,xmm0
    498b:	c4 c1 73 59 c0       	vmulsd xmm0,xmm1,xmm8
    4990:	c4 c1 43 5c fc       	vsubsd xmm7,xmm7,xmm12
    4995:	c5 fb 5c c6          	vsubsd xmm0,xmm0,xmm6
    4999:	c5 c3 58 ff          	vaddsd xmm7,xmm7,xmm7
    499d:	c5 eb 58 d2          	vaddsd xmm2,xmm2,xmm2
    49a1:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    49a5:	c5 d3 58 ef          	vaddsd xmm5,xmm5,xmm7
    49a9:	c5 db 58 e2          	vaddsd xmm4,xmm4,xmm2
    49ad:	c5 e3 58 d8          	vaddsd xmm3,xmm3,xmm0
    49b1:	c4 c1 7b 11 28       	vmovsd QWORD PTR [r8],xmm5
    49b6:	c4 c1 7b 11 60 08    	vmovsd QWORD PTR [r8+0x8],xmm4
    49bc:	c4 c1 7b 11 58 10    	vmovsd QWORD PTR [r8+0x10],xmm3
    49c2:	c5 d3 58 28          	vaddsd xmm5,xmm5,QWORD PTR [rax]
    49c6:	c5 db 58 60 08       	vaddsd xmm4,xmm4,QWORD PTR [rax+0x8]
    49cb:	c5 e3 58 58 10       	vaddsd xmm3,xmm3,QWORD PTR [rax+0x10]
    49d0:	c4 c1 7b 11 28       	vmovsd QWORD PTR [r8],xmm5
    49d5:	c4 c1 7b 11 60 08    	vmovsd QWORD PTR [r8+0x8],xmm4
    49db:	c4 c1 7b 11 58 10    	vmovsd QWORD PTR [r8+0x10],xmm3
    49e1:	49 83 c0 38          	add    r8,0x38
    49e5:	4c 39 c1             	cmp    rcx,r8
    49e8:	0f 85 f2 fe ff ff    	jne    48e0 <c_run_6+0x20>
    49ee:	c3                   	ret
    49ef:	90                   	nop

00000000000049f0 <adapter__run_3>:
    49f0:	c5 7b 10 0d e8 8d 02 	vmovsd xmm9,QWORD PTR [rip+0x28de8]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    49f7:	00 
    49f8:	48 89 f0             	mov    rax,rsi
    49fb:	89 fe                	mov    esi,edi
    49fd:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    4a02:	48 6b f6 38          	imul   rsi,rsi,0x38
    4a06:	4c 01 c6             	add    rsi,r8
    4a09:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    4a10:	c5 fb 10 50 18       	vmovsd xmm2,QWORD PTR [rax+0x18]
    4a15:	c5 fb 10 68 20       	vmovsd xmm5,QWORD PTR [rax+0x20]
    4a1a:	c5 7b 10 50 28       	vmovsd xmm10,QWORD PTR [rax+0x28]
    4a1f:	c5 fb 10 70 30       	vmovsd xmm6,QWORD PTR [rax+0x30]
    4a24:	c5 d1 57 05 84 b0 02 	vxorpd xmm0,xmm5,XMMWORD PTR [rip+0x2b084]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4a2b:	00 
    4a2c:	c5 a9 57 25 7c b0 02 	vxorpd xmm4,xmm10,XMMWORD PTR [rip+0x2b07c]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4a33:	00 
    4a34:	c5 c9 57 0d 74 b0 02 	vxorpd xmm1,xmm6,XMMWORD PTR [rip+0x2b074]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4a3b:	00 
    4a3c:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    4a40:	c5 d9 14 f9          	vunpcklpd xmm7,xmm4,xmm1
    4a44:	62 f3 e5 28 18 df 01 	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    4a4b:	c4 c1 7d 11 58 18    	vmovupd YMMWORD PTR [r8+0x18],ymm3
    4a51:	c5 fb 10 38          	vmovsd xmm7,QWORD PTR [rax]
    4a55:	c5 7b 10 58 08       	vmovsd xmm11,QWORD PTR [rax+0x8]
    4a5a:	c4 c1 79 2f f8       	vcomisd xmm7,xmm8
    4a5f:	75 1f                	jne    4a80 <adapter__run_3+0x90>
    4a61:	c4 41 79 2f d8       	vcomisd xmm11,xmm8
    4a66:	75 18                	jne    4a80 <adapter__run_3+0x90>
    4a68:	c5 79 2f 40 10       	vcomisd xmm8,QWORD PTR [rax+0x10]
    4a6d:	0f 84 0d 01 00 00    	je     4b80 <adapter__run_3+0x190>
    4a73:	66 90                	xchg   ax,ax
    4a75:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4a7c:	00 00 00 00 
    4a80:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    4a85:	41 0f 94 c1          	sete   r9b
    4a89:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    4a8e:	40 0f 94 c7          	sete   dil
    4a92:	41 84 f9             	test   r9b,dil
    4a95:	74 1b                	je     4ab2 <adapter__run_3+0xc2>
    4a97:	c4 41 79 2f d0       	vcomisd xmm10,xmm8
    4a9c:	41 0f 94 c1          	sete   r9b
    4aa0:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    4aa5:	40 0f 94 c7          	sete   dil
    4aa9:	41 84 f9             	test   r9b,dil
    4aac:	0f 85 ee 00 00 00    	jne    4ba0 <adapter__run_3+0x1b0>
    4ab2:	c5 7b 10 50 10       	vmovsd xmm10,QWORD PTR [rax+0x10]
    4ab7:	c5 eb 59 ef          	vmulsd xmm5,xmm2,xmm7
    4abb:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    4ac0:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    4ac5:	c4 c1 6b 59 d2       	vmulsd xmm2,xmm2,xmm10
    4aca:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    4ace:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    4ad3:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    4ad7:	c5 f3 59 df          	vmulsd xmm3,xmm1,xmm7
    4adb:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    4adf:	c4 c1 7b 59 da       	vmulsd xmm3,xmm0,xmm10
    4ae4:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    4ae8:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    4aed:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    4af1:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    4af5:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    4af9:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    4afd:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    4b01:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    4b05:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    4b09:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    4b0d:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    4b11:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    4b16:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    4b1a:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    4b1e:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    4b22:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    4b26:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4b2a:	c5 e3 58 df          	vaddsd xmm3,xmm3,xmm7
    4b2e:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    4b33:	c5 e1 57 1d 75 af 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2af75]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4b3a:	00 
    4b3b:	c5 f1 57 0d 6d af 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2af6d]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4b42:	00 
    4b43:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    4b48:	c5 f9 57 05 60 af 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2af60]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4b4f:	00 
    4b50:	c4 c1 7b 11 18       	vmovsd QWORD PTR [r8],xmm3
    4b55:	c4 c1 7b 11 48 08    	vmovsd QWORD PTR [r8+0x8],xmm1
    4b5b:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    4b61:	49 83 c0 38          	add    r8,0x38
    4b65:	49 39 f0             	cmp    r8,rsi
    4b68:	0f 85 a2 fe ff ff    	jne    4a10 <adapter__run_3+0x20>
    4b6e:	c5 f8 77             	vzeroupper
    4b71:	c3                   	ret
    4b72:	0f 1f 00             	nop    DWORD PTR [rax]
    4b75:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4b7c:	00 00 00 00 
    4b80:	c5 fb 10 05 28 af 02 	vmovsd xmm0,QWORD PTR [rip+0x2af28]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4b87:	00 
    4b88:	c5 f9 28 c8          	vmovapd xmm1,xmm0
    4b8c:	c5 f9 28 d8          	vmovapd xmm3,xmm0
    4b90:	eb be                	jmp    4b50 <adapter__run_3+0x160>
    4b92:	0f 1f 00             	nop    DWORD PTR [rax]
    4b95:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4b9c:	00 00 00 00 
    4ba0:	c5 fb 10 40 10       	vmovsd xmm0,QWORD PTR [rax+0x10]
    4ba5:	c5 c1 57 1d 03 af 02 	vxorpd xmm3,xmm7,XMMWORD PTR [rip+0x2af03]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4bac:	00 
    4bad:	c5 a1 57 0d fb ae 02 	vxorpd xmm1,xmm11,XMMWORD PTR [rip+0x2aefb]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4bb4:	00 
    4bb5:	c5 f9 57 05 f3 ae 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2aef3]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4bbc:	00 
    4bbd:	eb 91                	jmp    4b50 <adapter__run_3+0x160>
    4bbf:	90                   	nop

0000000000004bc0 <c_run_4>:
    4bc0:	55                   	push   rbp
    4bc1:	48 89 f0             	mov    rax,rsi
    4bc4:	89 fe                	mov    esi,edi
    4bc6:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    4bcb:	48 89 e5             	mov    rbp,rsp
    4bce:	48 6b f6 38          	imul   rsi,rsi,0x38
    4bd2:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    4bd6:	c5 7b 10 0d 02 8c 02 	vmovsd xmm9,QWORD PTR [rip+0x28c02]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    4bdd:	00 
    4bde:	4c 01 c6             	add    rsi,r8
    4be1:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    4be5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4bec:	00 00 00 00 
    4bf0:	c4 c1 7e 6f 00       	vmovdqu ymm0,YMMWORD PTR [r8]
    4bf5:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    4bfb:	c4 c1 7e 6f 40 18    	vmovdqu ymm0,YMMWORD PTR [r8+0x18]
    4c01:	c5 7b 10 54 24 c0    	vmovsd xmm10,QWORD PTR [rsp-0x40]
    4c07:	c5 7b 10 5c 24 c8    	vmovsd xmm11,QWORD PTR [rsp-0x38]
    4c0d:	c5 fb 10 7c 24 d0    	vmovsd xmm7,QWORD PTR [rsp-0x30]
    4c13:	c5 fe 7f 44 24 d8    	vmovdqu YMMWORD PTR [rsp-0x28],ymm0
    4c19:	c5 fb 10 54 24 d8    	vmovsd xmm2,QWORD PTR [rsp-0x28]
    4c1f:	c5 fb 10 6c 24 e0    	vmovsd xmm5,QWORD PTR [rsp-0x20]
    4c25:	c5 7b 10 64 24 e8    	vmovsd xmm12,QWORD PTR [rsp-0x18]
    4c2b:	c5 d1 57 05 7d ae 02 	vxorpd xmm0,xmm5,XMMWORD PTR [rip+0x2ae7d]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4c32:	00 
    4c33:	c5 99 57 25 75 ae 02 	vxorpd xmm4,xmm12,XMMWORD PTR [rip+0x2ae75]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4c3a:	00 
    4c3b:	c5 fb 10 74 24 f0    	vmovsd xmm6,QWORD PTR [rsp-0x10]
    4c41:	c5 c9 57 0d 67 ae 02 	vxorpd xmm1,xmm6,XMMWORD PTR [rip+0x2ae67]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4c48:	00 
    4c49:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    4c4e:	c5 59 14 e9          	vunpcklpd xmm13,xmm4,xmm1
    4c52:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    4c56:	41 0f 94 c1          	sete   r9b
    4c5a:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    4c5f:	62 d3 e5 28 18 dd 01 	vinsertf64x2 ymm3,ymm3,xmm13,0x1
    4c66:	40 0f 94 c7          	sete   dil
    4c6a:	c4 c1 7d 11 58 18    	vmovupd YMMWORD PTR [r8+0x18],ymm3
    4c70:	41 84 f9             	test   r9b,dil
    4c73:	74 1b                	je     4c90 <c_run_4+0xd0>
    4c75:	c4 41 79 2f e0       	vcomisd xmm12,xmm8
    4c7a:	41 0f 94 c1          	sete   r9b
    4c7e:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    4c83:	40 0f 94 c7          	sete   dil
    4c87:	41 84 f9             	test   r9b,dil
    4c8a:	0f 85 c0 00 00 00    	jne    4d50 <c_run_4+0x190>
    4c90:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    4c94:	c4 c1 6b 59 ea       	vmulsd xmm5,xmm2,xmm10
    4c99:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    4c9e:	c5 eb 59 d7          	vmulsd xmm2,xmm2,xmm7
    4ca2:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    4ca6:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    4cab:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    4caf:	c4 c1 73 59 da       	vmulsd xmm3,xmm1,xmm10
    4cb4:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    4cb8:	c5 fb 59 df          	vmulsd xmm3,xmm0,xmm7
    4cbc:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    4cc0:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    4cc5:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    4cc9:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    4cce:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    4cd2:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    4cd6:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    4cda:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    4cde:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    4ce2:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    4ce6:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    4cea:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    4cef:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    4cf3:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    4cf7:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    4cfb:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    4cff:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4d03:	c4 c1 63 58 da       	vaddsd xmm3,xmm3,xmm10
    4d08:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    4d0d:	c5 e1 57 1d 9b ad 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2ad9b]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4d14:	00 
    4d15:	c5 f1 57 0d 93 ad 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2ad93]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4d1c:	00 
    4d1d:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4d21:	c5 f9 57 05 87 ad 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2ad87]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4d28:	00 
    4d29:	c4 c1 7b 11 18       	vmovsd QWORD PTR [r8],xmm3
    4d2e:	c4 c1 7b 11 48 08    	vmovsd QWORD PTR [r8+0x8],xmm1
    4d34:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    4d3a:	49 83 c0 38          	add    r8,0x38
    4d3e:	49 39 f0             	cmp    r8,rsi
    4d41:	0f 85 a9 fe ff ff    	jne    4bf0 <c_run_4+0x30>
    4d47:	c5 f8 77             	vzeroupper
    4d4a:	c9                   	leave
    4d4b:	c3                   	ret
    4d4c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    4d50:	c5 29 57 15 58 ad 02 	vxorpd xmm10,xmm10,XMMWORD PTR [rip+0x2ad58]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4d57:	00 
    4d58:	c5 21 57 1d 50 ad 02 	vxorpd xmm11,xmm11,XMMWORD PTR [rip+0x2ad50]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4d5f:	00 
    4d60:	c5 c1 57 3d 48 ad 02 	vxorpd xmm7,xmm7,XMMWORD PTR [rip+0x2ad48]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4d67:	00 
    4d68:	c4 41 7b 11 10       	vmovsd QWORD PTR [r8],xmm10
    4d6d:	c4 41 7b 11 58 08    	vmovsd QWORD PTR [r8+0x8],xmm11
    4d73:	c4 c1 7b 11 78 10    	vmovsd QWORD PTR [r8+0x10],xmm7
    4d79:	49 83 c0 38          	add    r8,0x38
    4d7d:	4c 39 c6             	cmp    rsi,r8
    4d80:	0f 85 6a fe ff ff    	jne    4bf0 <c_run_4+0x30>
    4d86:	eb bf                	jmp    4d47 <c_run_4+0x187>
    4d88:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    4d8f:	00 

0000000000004d90 <c_run_4.constprop.0>:
    4d90:	55                   	push   rbp
    4d91:	48 89 c8             	mov    rax,rcx
    4d94:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    4d99:	48 8d 89 c0 01 00 00 	lea    rcx,[rcx+0x1c0]
    4da0:	48 89 e5             	mov    rbp,rsp
    4da3:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    4da7:	c5 7b 10 0d 31 8a 02 	vmovsd xmm9,QWORD PTR [rip+0x28a31]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    4dae:	00 
    4daf:	90                   	nop
    4db0:	c5 fe 6f 00          	vmovdqu ymm0,YMMWORD PTR [rax]
    4db4:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    4dba:	c5 fe 6f 40 18       	vmovdqu ymm0,YMMWORD PTR [rax+0x18]
    4dbf:	c5 7b 10 54 24 c0    	vmovsd xmm10,QWORD PTR [rsp-0x40]
    4dc5:	c5 7b 10 5c 24 c8    	vmovsd xmm11,QWORD PTR [rsp-0x38]
    4dcb:	c5 fb 10 7c 24 d0    	vmovsd xmm7,QWORD PTR [rsp-0x30]
    4dd1:	c5 fe 7f 44 24 d8    	vmovdqu YMMWORD PTR [rsp-0x28],ymm0
    4dd7:	c5 fb 10 54 24 d8    	vmovsd xmm2,QWORD PTR [rsp-0x28]
    4ddd:	c5 fb 10 6c 24 e0    	vmovsd xmm5,QWORD PTR [rsp-0x20]
    4de3:	c5 7b 10 64 24 e8    	vmovsd xmm12,QWORD PTR [rsp-0x18]
    4de9:	c5 d1 57 05 bf ac 02 	vxorpd xmm0,xmm5,XMMWORD PTR [rip+0x2acbf]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4df0:	00 
    4df1:	c5 99 57 25 b7 ac 02 	vxorpd xmm4,xmm12,XMMWORD PTR [rip+0x2acb7]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4df8:	00 
    4df9:	c5 fb 10 74 24 f0    	vmovsd xmm6,QWORD PTR [rsp-0x10]
    4dff:	c5 c9 57 0d a9 ac 02 	vxorpd xmm1,xmm6,XMMWORD PTR [rip+0x2aca9]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4e06:	00 
    4e07:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    4e0c:	c5 59 14 e9          	vunpcklpd xmm13,xmm4,xmm1
    4e10:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    4e14:	41 0f 94 c1          	sete   r9b
    4e18:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    4e1d:	62 d3 e5 28 18 dd 01 	vinsertf64x2 ymm3,ymm3,xmm13,0x1
    4e24:	41 0f 94 c0          	sete   r8b
    4e28:	c5 fd 11 58 18       	vmovupd YMMWORD PTR [rax+0x18],ymm3
    4e2d:	45 84 c1             	test   r9b,r8b
    4e30:	74 1b                	je     4e4d <c_run_4.constprop.0+0xbd>
    4e32:	c4 41 79 2f e0       	vcomisd xmm12,xmm8
    4e37:	41 0f 94 c1          	sete   r9b
    4e3b:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    4e40:	41 0f 94 c0          	sete   r8b
    4e44:	45 84 c1             	test   r9b,r8b
    4e47:	0f 85 b9 00 00 00    	jne    4f06 <c_run_4.constprop.0+0x176>
    4e4d:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    4e51:	c4 c1 6b 59 ea       	vmulsd xmm5,xmm2,xmm10
    4e56:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    4e5b:	c5 eb 59 d7          	vmulsd xmm2,xmm2,xmm7
    4e5f:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    4e63:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    4e68:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    4e6c:	c4 c1 73 59 da       	vmulsd xmm3,xmm1,xmm10
    4e71:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    4e75:	c5 fb 59 df          	vmulsd xmm3,xmm0,xmm7
    4e79:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    4e7d:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    4e82:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    4e86:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    4e8b:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    4e8f:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    4e93:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    4e97:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    4e9b:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    4e9f:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    4ea3:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    4ea7:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    4eac:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    4eb0:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    4eb4:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    4eb8:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    4ebc:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4ec0:	c4 c1 63 58 da       	vaddsd xmm3,xmm3,xmm10
    4ec5:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    4eca:	c5 e1 57 1d de ab 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2abde]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4ed1:	00 
    4ed2:	c5 f1 57 0d d6 ab 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2abd6]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4ed9:	00 
    4eda:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4ede:	c5 f9 57 05 ca ab 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2abca]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4ee5:	00 
    4ee6:	c5 fb 11 18          	vmovsd QWORD PTR [rax],xmm3
    4eea:	c5 fb 11 48 08       	vmovsd QWORD PTR [rax+0x8],xmm1
    4eef:	c5 fb 11 40 10       	vmovsd QWORD PTR [rax+0x10],xmm0
    4ef4:	48 83 c0 38          	add    rax,0x38
    4ef8:	48 39 c8             	cmp    rax,rcx
    4efb:	0f 85 af fe ff ff    	jne    4db0 <c_run_4.constprop.0+0x20>
    4f01:	c5 f8 77             	vzeroupper
    4f04:	c9                   	leave
    4f05:	c3                   	ret
    4f06:	c5 29 57 15 a2 ab 02 	vxorpd xmm10,xmm10,XMMWORD PTR [rip+0x2aba2]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4f0d:	00 
    4f0e:	c5 21 57 1d 9a ab 02 	vxorpd xmm11,xmm11,XMMWORD PTR [rip+0x2ab9a]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4f15:	00 
    4f16:	c5 c1 57 3d 92 ab 02 	vxorpd xmm7,xmm7,XMMWORD PTR [rip+0x2ab92]        # 2fab0 <system__secondary_stack__invalid_memory_size+0xa8>
    4f1d:	00 
    4f1e:	c5 7b 11 10          	vmovsd QWORD PTR [rax],xmm10
    4f22:	c5 7b 11 58 08       	vmovsd QWORD PTR [rax+0x8],xmm11
    4f27:	c5 fb 11 78 10       	vmovsd QWORD PTR [rax+0x10],xmm7
    4f2c:	48 83 c0 38          	add    rax,0x38
    4f30:	48 39 c8             	cmp    rax,rcx
    4f33:	0f 85 77 fe ff ff    	jne    4db0 <c_run_4.constprop.0+0x20>
    4f39:	eb c6                	jmp    4f01 <c_run_4.constprop.0+0x171>
    4f3b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000005ab0 <adapter__run_1>:
    5ab0:	48 89 f0             	mov    rax,rsi
    5ab3:	89 fe                	mov    esi,edi
    5ab5:	c5 fd 6f 2d 23 7d 02 	vmovdqa ymm5,YMMWORD PTR [rip+0x27d23]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    5abc:	00 
    5abd:	c5 fb 10 1d f3 9e 02 	vmovsd xmm3,QWORD PTR [rip+0x29ef3]        # 2f9b8 <system__os_lib__standin+0xc>
    5ac4:	00 
    5ac5:	48 6b f6 38          	imul   rsi,rsi,0x38
    5ac9:	c5 fb 10 25 0f 7d 02 	vmovsd xmm4,QWORD PTR [rip+0x27d0f]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    5ad0:	00 
    5ad1:	c5 e9 57 d2          	vxorpd xmm2,xmm2,xmm2
    5ad5:	4c 01 c6             	add    rsi,r8
    5ad8:	eb 4e                	jmp    5b28 <adapter__run_1+0x78>
    5ada:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    5ae0:	c5 79 2f f2          	vcomisd xmm14,xmm2
    5ae4:	0f 85 40 01 00 00    	jne    5c2a <adapter__run_1+0x17a>
    5aea:	c5 c9 15 ce          	vunpckhpd xmm1,xmm6,xmm6
    5aee:	c5 f9 2f ca          	vcomisd xmm1,xmm2
    5af2:	0f 85 32 01 00 00    	jne    5c2a <adapter__run_1+0x17a>
    5af8:	c4 c1 11 58 f7       	vaddpd xmm6,xmm13,xmm15
    5afd:	c4 c1 1b 58 c3       	vaddsd xmm0,xmm12,xmm11
    5b02:	0f 1f 00             	nop    DWORD PTR [rax]
    5b05:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5b0c:	00 00 00 00 
    5b10:	c4 c1 79 11 30       	vmovupd XMMWORD PTR [r8],xmm6
    5b15:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    5b1b:	49 83 c0 38          	add    r8,0x38
    5b1f:	4c 39 c6             	cmp    rsi,r8
    5b22:	0f 84 c8 01 00 00    	je     5cf0 <adapter__run_1+0x240>
    5b28:	49 8d 78 18          	lea    rdi,[r8+0x18]
    5b2c:	c5 fd 10 48 18       	vmovupd ymm1,YMMWORD PTR [rax+0x18]
    5b31:	c5 fd 10 42 18       	vmovupd ymm0,YMMWORD PTR [rdx+0x18]
    5b36:	c4 e2 7d 19 f1       	vbroadcastsd ymm6,xmm1
    5b3b:	c4 63 fd 01 c0 4e    	vpermpd ymm8,ymm0,0x4e
    5b41:	c4 e3 fd 01 f8 1b    	vpermpd ymm7,ymm0,0x1b
    5b47:	c4 63 fd 01 c9 55    	vpermpd ymm9,ymm1,0x55
    5b4d:	c5 cd 59 f0          	vmulpd ymm6,ymm6,ymm0
    5b51:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    5b57:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    5b5c:	c5 cd d0 f0          	vaddsubpd ymm6,ymm6,ymm0
    5b60:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    5b66:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    5b6c:	c4 c1 7d 59 c0       	vmulpd ymm0,ymm0,ymm8
    5b71:	c5 f5 59 cf          	vmulpd ymm1,ymm1,ymm7
    5b75:	c5 4d 5c c0          	vsubpd ymm8,ymm6,ymm0
    5b79:	c5 fd 58 c6          	vaddpd ymm0,ymm0,ymm6
    5b7d:	c4 c3 7d 0d c0 09    	vblendpd ymm0,ymm0,ymm8,0x9
    5b83:	c5 75 58 c8          	vaddpd ymm9,ymm1,ymm0
    5b87:	c5 fd 5c c9          	vsubpd ymm1,ymm0,ymm1
    5b8b:	62 73 fd 28 19 cf 01 	vextractf64x2 xmm7,ymm9,0x1
    5b92:	c5 71 15 c1          	vunpckhpd xmm8,xmm1,xmm1
    5b96:	c5 f3 59 c1          	vmulsd xmm0,xmm1,xmm1
    5b9a:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    5b9f:	62 d3 b5 28 03 f1 03 	valignq ymm6,ymm9,ymm9,0x3
    5ba6:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    5bab:	c5 c3 59 ff          	vmulsd xmm7,xmm7,xmm7
    5baf:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    5bb3:	c5 cb 59 f6          	vmulsd xmm6,xmm6,xmm6
    5bb7:	c5 fb 58 c6          	vaddsd xmm0,xmm0,xmm6
    5bbb:	c5 f9 2f c2          	vcomisd xmm0,xmm2
    5bbf:	0f 84 fb 00 00 00    	je     5cc0 <adapter__run_1+0x210>
    5bc5:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    5bc9:	c5 f9 2f d8          	vcomisd xmm3,xmm0
    5bcd:	0f 87 ed 00 00 00    	ja     5cc0 <adapter__run_1+0x210>
    5bd3:	c4 63 35 0d c9 03    	vblendpd ymm9,ymm9,ymm1,0x3
    5bd9:	c5 fb 5c cc          	vsubsd xmm1,xmm0,xmm4
    5bdd:	c5 f1 54 0d db 9e 02 	vandpd xmm1,xmm1,XMMWORD PTR [rip+0x29edb]        # 2fac0 <system__secondary_stack__invalid_memory_size+0xb8>
    5be4:	00 
    5be5:	c5 f9 2f cb          	vcomisd xmm1,xmm3
    5be9:	0f 87 e1 00 00 00    	ja     5cd0 <adapter__run_1+0x220>
    5bef:	c4 41 7d 11 48 18    	vmovupd YMMWORD PTR [r8+0x18],ymm9
    5bf5:	c5 79 28 40 20       	vmovapd xmm8,XMMWORD PTR [rax+0x20]
    5bfa:	c5 f9 10 42 08       	vmovupd xmm0,XMMWORD PTR [rdx+0x8]
    5bff:	c5 f9 10 70 28       	vmovupd xmm6,XMMWORD PTR [rax+0x28]
    5c04:	c5 79 28 3a          	vmovapd xmm15,XMMWORD PTR [rdx]
    5c08:	c5 79 28 28          	vmovapd xmm13,XMMWORD PTR [rax]
    5c0c:	c5 7b 10 58 10       	vmovsd xmm11,QWORD PTR [rax+0x10]
    5c11:	c5 79 2f c2          	vcomisd xmm8,xmm2
    5c15:	c4 41 39 15 f0       	vunpckhpd xmm14,xmm8,xmm8
    5c1a:	62 c1 fd 08 28 c0    	vmovapd xmm16,xmm8
    5c20:	c5 79 15 e0          	vunpckhpd xmm12,xmm0,xmm0
    5c24:	0f 84 b6 fe ff ff    	je     5ae0 <adapter__run_1+0x30>
    5c2a:	c5 7b 12 12          	vmovddup xmm10,QWORD PTR [rdx]
    5c2e:	c5 7b 12 48 18       	vmovddup xmm9,QWORD PTR [rax+0x18]
    5c33:	c5 fb 10 78 30       	vmovsd xmm7,QWORD PTR [rax+0x30]
    5c38:	c5 c1 16 78 20       	vmovhpd xmm7,xmm7,QWORD PTR [rax+0x20]
    5c3d:	62 e1 b5 08 59 c8    	vmulpd xmm17,xmm9,xmm0
    5c43:	c4 c1 41 59 cf       	vmulpd xmm1,xmm7,xmm15
    5c48:	c4 41 79 15 d2       	vunpckhpd xmm10,xmm0,xmm10
    5c4d:	c4 41 31 59 ca       	vmulpd xmm9,xmm9,xmm10
    5c52:	c4 c1 79 59 c0       	vmulpd xmm0,xmm0,xmm8
    5c57:	62 b1 f5 08 58 c9    	vaddpd xmm1,xmm1,xmm17
    5c5d:	62 c1 bd 08 59 ca    	vmulpd xmm17,xmm8,xmm10
    5c63:	c4 41 49 59 c7       	vmulpd xmm8,xmm6,xmm15
    5c68:	c4 c1 79 58 c1       	vaddpd xmm0,xmm0,xmm9
    5c6d:	62 b1 f5 08 5c c9    	vsubpd xmm1,xmm1,xmm17
    5c73:	c4 c1 79 5c c0       	vsubpd xmm0,xmm0,xmm8
    5c78:	c5 f1 59 ff          	vmulpd xmm7,xmm1,xmm7
    5c7c:	62 b1 f7 08 59 c8    	vmulsd xmm1,xmm1,xmm16
    5c82:	c5 f9 59 f6          	vmulpd xmm6,xmm0,xmm6
    5c86:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    5c8a:	c4 c1 7b 59 c6       	vmulsd xmm0,xmm0,xmm14
    5c8f:	c5 c9 5c f7          	vsubpd xmm6,xmm6,xmm7
    5c93:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    5c97:	c5 c9 58 f6          	vaddpd xmm6,xmm6,xmm6
    5c9b:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    5c9f:	c4 c1 49 58 f7       	vaddpd xmm6,xmm6,xmm15
    5ca4:	c4 c1 7b 58 c4       	vaddsd xmm0,xmm0,xmm12
    5ca9:	c4 c1 49 58 f5       	vaddpd xmm6,xmm6,xmm13
    5cae:	c4 c1 7b 58 c3       	vaddsd xmm0,xmm0,xmm11
    5cb3:	e9 58 fe ff ff       	jmp    5b10 <adapter__run_1+0x60>
    5cb8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    5cbf:	00 
    5cc0:	c5 fe 7f 2f          	vmovdqu YMMWORD PTR [rdi],ymm5
    5cc4:	e9 2c ff ff ff       	jmp    5bf5 <adapter__run_1+0x145>
    5cc9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    5cd0:	c5 db 5e c0          	vdivsd xmm0,xmm4,xmm0
    5cd4:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    5cd9:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    5cde:	c5 fe 7f 07          	vmovdqu YMMWORD PTR [rdi],ymm0
    5ce2:	e9 0e ff ff ff       	jmp    5bf5 <adapter__run_1+0x145>
    5ce7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    5cee:	00 00 
    5cf0:	c5 f8 77             	vzeroupper
    5cf3:	c3                   	ret
    5cf4:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    5cfb:	00 00 00 
    5cfe:	66 90                	xchg   ax,ax

0000000000005d00 <adapter__run_2>:
    5d00:	c5 fd 6f 35 d8 7a 02 	vmovdqa ymm6,YMMWORD PTR [rip+0x27ad8]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    5d07:	00 
    5d08:	c5 fb 10 25 a8 9c 02 	vmovsd xmm4,QWORD PTR [rip+0x29ca8]        # 2f9b8 <system__os_lib__standin+0xc>
    5d0f:	00 
    5d10:	c5 fb 10 2d c8 7a 02 	vmovsd xmm5,QWORD PTR [rip+0x27ac8]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    5d17:	00 
    5d18:	41 89 f9             	mov    r9d,edi
    5d1b:	4d 6b c9 38          	imul   r9,r9,0x38
    5d1f:	c5 e1 57 db          	vxorpd xmm3,xmm3,xmm3
    5d23:	4d 01 c1             	add    r9,r8
    5d26:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    5d2d:	00 00 00 
    5d30:	49 8d 40 18          	lea    rax,[r8+0x18]
    5d34:	c5 fd 10 4a 18       	vmovupd ymm1,YMMWORD PTR [rdx+0x18]
    5d39:	c5 79 10 58 08       	vmovupd xmm11,XMMWORD PTR [rax+0x8]
    5d3e:	c4 63 fd 01 70 e8 ff 	vpermpd ymm14,YMMWORD PTR [rax-0x18],0xff
    5d45:	c5 f9 10 50 10       	vmovupd xmm2,XMMWORD PTR [rax+0x10]
    5d4a:	c4 41 79 10 10       	vmovupd xmm10,XMMWORD PTR [r8]
    5d4f:	c4 c1 7b 10 78 10    	vmovsd xmm7,QWORD PTR [r8+0x10]
    5d55:	c5 79 10 68 f8       	vmovupd xmm13,XMMWORD PTR [rax-0x8]
    5d5a:	c5 7b 10 78 08       	vmovsd xmm15,QWORD PTR [rax+0x8]
    5d5f:	c5 7b 10 60 18       	vmovsd xmm12,QWORD PTR [rax+0x18]
    5d64:	c4 e3 7d 05 c1 05    	vpermilpd ymm0,ymm1,0x5
    5d6a:	62 c2 fd 28 19 d3    	vbroadcastsd ymm18,xmm11
    5d70:	62 e2 fd 28 19 ca    	vbroadcastsd ymm17,xmm2
    5d76:	c4 41 79 28 cb       	vmovapd xmm9,xmm11
    5d7b:	62 b1 fd 28 59 c2    	vmulpd ymm0,ymm0,ymm18
    5d81:	c5 0d 59 f1          	vmulpd ymm14,ymm14,ymm1
    5d85:	62 e1 ed 08 15 c2    	vunpckhpd xmm16,xmm2,xmm2
    5d8b:	c5 79 28 c2          	vmovapd xmm8,xmm2
    5d8f:	62 a2 fd 28 19 c0    	vbroadcastsd ymm16,xmm16
    5d95:	c5 0d d0 f0          	vaddsubpd ymm14,ymm14,ymm0
    5d99:	c4 e3 fd 01 c1 4e    	vpermpd ymm0,ymm1,0x4e
    5d9f:	c4 e3 fd 01 c9 1b    	vpermpd ymm1,ymm1,0x1b
    5da5:	62 b1 fd 28 59 c1    	vmulpd ymm0,ymm0,ymm17
    5dab:	62 b1 f5 28 59 c8    	vmulpd ymm1,ymm1,ymm16
    5db1:	62 e1 8d 28 5c c8    	vsubpd ymm17,ymm14,ymm0
    5db7:	c4 c1 7d 58 c6       	vaddpd ymm0,ymm0,ymm14
    5dbc:	62 31 fd 28 28 f1    	vmovapd ymm14,ymm17
    5dc2:	c4 c3 7d 0d c6 09    	vblendpd ymm0,ymm0,ymm14,0x9
    5dc8:	62 e1 f5 28 58 d0    	vaddpd ymm18,ymm1,ymm0
    5dce:	c5 fd 5c c9          	vsubpd ymm1,ymm0,ymm1
    5dd2:	62 a3 fd 28 19 d0 01 	vextractf64x2 xmm16,ymm18,0x1
    5dd9:	62 e1 f5 08 15 c9    	vunpckhpd xmm17,xmm1,xmm1
    5ddf:	c5 f3 59 c1          	vmulsd xmm0,xmm1,xmm1
    5de3:	62 a1 f7 00 59 c9    	vmulsd xmm17,xmm17,xmm17
    5de9:	62 33 ed 20 03 f2 03 	valignq ymm14,ymm18,ymm18,0x3
    5df0:	62 b1 ff 08 58 c1    	vaddsd xmm0,xmm0,xmm17
    5df6:	62 a1 ff 00 59 c0    	vmulsd xmm16,xmm16,xmm16
    5dfc:	62 b1 ff 08 58 c0    	vaddsd xmm0,xmm0,xmm16
    5e02:	c4 41 0b 59 f6       	vmulsd xmm14,xmm14,xmm14
    5e07:	c4 c1 7b 58 c6       	vaddsd xmm0,xmm0,xmm14
    5e0c:	c5 f9 2f c3          	vcomisd xmm0,xmm3
    5e10:	0f 84 1a 01 00 00    	je     5f30 <adapter__run_2+0x230>
    5e16:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    5e1a:	c5 f9 2f e0          	vcomisd xmm4,xmm0
    5e1e:	0f 87 0c 01 00 00    	ja     5f30 <adapter__run_2+0x230>
    5e24:	62 31 fd 28 28 f2    	vmovapd ymm14,ymm18
    5e2a:	c4 e3 0d 0d c9 03    	vblendpd ymm1,ymm14,ymm1,0x3
    5e30:	c5 7b 5c f5          	vsubsd xmm14,xmm0,xmm5
    5e34:	c5 09 54 35 84 9c 02 	vandpd xmm14,xmm14,XMMWORD PTR [rip+0x29c84]        # 2fac0 <system__secondary_stack__invalid_memory_size+0xb8>
    5e3b:	00 
    5e3c:	c5 79 2f f4          	vcomisd xmm14,xmm4
    5e40:	0f 87 fa 00 00 00    	ja     5f40 <adapter__run_2+0x240>
    5e46:	c4 c1 7d 11 48 18    	vmovupd YMMWORD PTR [r8+0x18],ymm1
    5e4c:	62 e1 fd 08 10 82 08 	vmovupd xmm16,XMMWORD PTR [rdx+0x8]
    5e53:	00 00 00 
    5e56:	c5 79 2f fb          	vcomisd xmm15,xmm3
    5e5a:	62 e1 fd 08 28 0a    	vmovapd xmm17,XMMWORD PTR [rdx]
    5e60:	40 0f 94 c7          	sete   dil
    5e64:	c5 79 2f e3          	vcomisd xmm12,xmm3
    5e68:	0f 94 c0             	sete   al
    5e6b:	62 31 fd 00 15 f0    	vunpckhpd xmm14,xmm16,xmm16
    5e71:	40 84 c7             	test   dil,al
    5e74:	74 0a                	je     5e80 <adapter__run_2+0x180>
    5e76:	c5 79 2f c3          	vcomisd xmm8,xmm3
    5e7a:	0f 84 e0 00 00 00    	je     5f60 <adapter__run_2+0x260>
    5e80:	c5 fb 12 02          	vmovddup xmm0,QWORD PTR [rdx]
    5e84:	c4 43 79 05 ed 03    	vpermilpd xmm13,xmm13,0x3
    5e8a:	c4 41 19 14 e7       	vunpcklpd xmm12,xmm12,xmm15
    5e8f:	62 51 f5 00 59 fc    	vmulpd xmm15,xmm17,xmm12
    5e95:	62 b1 95 08 59 c8    	vmulpd xmm1,xmm13,xmm16
    5e9b:	c4 c1 71 58 cf       	vaddpd xmm1,xmm1,xmm15
    5ea0:	62 f1 fd 00 15 c0    	vunpckhpd xmm0,xmm16,xmm0
    5ea6:	c4 41 79 59 fb       	vmulpd xmm15,xmm0,xmm11
    5eab:	62 31 a5 08 59 d8    	vmulpd xmm11,xmm11,xmm16
    5eb1:	c4 c1 79 59 c5       	vmulpd xmm0,xmm0,xmm13
    5eb6:	c4 c1 71 5c cf       	vsubpd xmm1,xmm1,xmm15
    5ebb:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    5ec0:	62 71 f5 00 59 da    	vmulpd xmm11,xmm17,xmm2
    5ec6:	c5 19 59 e1          	vmulpd xmm12,xmm12,xmm1
    5eca:	c4 c1 73 59 c9       	vmulsd xmm1,xmm1,xmm9
    5ecf:	c4 c1 79 5c c3       	vsubpd xmm0,xmm0,xmm11
    5ed4:	c5 e9 59 d0          	vmulpd xmm2,xmm2,xmm0
    5ed8:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    5edc:	c4 c1 7b 59 c0       	vmulsd xmm0,xmm0,xmm8
    5ee1:	c4 c1 69 5c d4       	vsubpd xmm2,xmm2,xmm12
    5ee6:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    5eea:	c5 e9 58 d2          	vaddpd xmm2,xmm2,xmm2
    5eee:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    5ef2:	62 b1 ed 08 58 d1    	vaddpd xmm2,xmm2,xmm17
    5ef8:	c4 c1 7b 58 c6       	vaddsd xmm0,xmm0,xmm14
    5efd:	c4 c1 69 58 d2       	vaddpd xmm2,xmm2,xmm10
    5f02:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    5f06:	c4 c1 79 11 10       	vmovupd XMMWORD PTR [r8],xmm2
    5f0b:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    5f11:	49 83 c0 38          	add    r8,0x38
    5f15:	4d 39 c1             	cmp    r9,r8
    5f18:	0f 85 12 fe ff ff    	jne    5d30 <adapter__run_2+0x30>
    5f1e:	c5 f8 77             	vzeroupper
    5f21:	c3                   	ret
    5f22:	0f 1f 00             	nop    DWORD PTR [rax]
    5f25:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f2c:	00 00 00 00 
    5f30:	c5 fe 7f 30          	vmovdqu YMMWORD PTR [rax],ymm6
    5f34:	e9 13 ff ff ff       	jmp    5e4c <adapter__run_2+0x14c>
    5f39:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    5f40:	c5 d3 5e c0          	vdivsd xmm0,xmm5,xmm0
    5f44:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    5f49:	c5 fd 59 c1          	vmulpd ymm0,ymm0,ymm1
    5f4d:	c5 fe 7f 00          	vmovdqu YMMWORD PTR [rax],ymm0
    5f51:	e9 f6 fe ff ff       	jmp    5e4c <adapter__run_2+0x14c>
    5f56:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    5f5d:	00 00 00 
    5f60:	62 c1 f5 00 58 ca    	vaddpd xmm17,xmm17,xmm10
    5f66:	c4 41 43 58 f6       	vaddsd xmm14,xmm7,xmm14
    5f6b:	62 c1 fd 08 11 08    	vmovupd XMMWORD PTR [r8],xmm17
    5f71:	c4 41 7b 11 70 10    	vmovsd QWORD PTR [r8+0x10],xmm14
    5f77:	49 83 c0 38          	add    r8,0x38
    5f7b:	4d 39 c8             	cmp    r8,r9
    5f7e:	0f 85 ac fd ff ff    	jne    5d30 <adapter__run_2+0x30>
    5f84:	c5 f8 77             	vzeroupper
    5f87:	c3                   	ret
    5f88:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    5f8f:	00 

00000000000068b0 <c_run_1.constprop.0>:
    68b0:	48 89 f8             	mov    rax,rdi
    68b3:	c5 fb 10 1d fd 90 02 	vmovsd xmm3,QWORD PTR [rip+0x290fd]        # 2f9b8 <system__os_lib__standin+0xc>
    68ba:	00 
    68bb:	c5 fb 10 15 1d 6f 02 	vmovsd xmm2,QWORD PTR [rip+0x26f1d]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    68c2:	00 
    68c3:	c5 fd 28 2d 15 6f 02 	vmovapd ymm5,YMMWORD PTR [rip+0x26f15]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    68ca:	00 
    68cb:	48 8d b9 c0 01 00 00 	lea    rdi,[rcx+0x1c0]
    68d2:	c5 d9 57 e4          	vxorpd xmm4,xmm4,xmm4
    68d6:	e9 84 00 00 00       	jmp    695f <c_run_1.constprop.0+0xaf>
    68db:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    68e0:	c5 fd 11 69 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm5
    68e5:	c5 f9 10 48 18       	vmovupd xmm1,XMMWORD PTR [rax+0x18]
    68ea:	c5 79 28 50 20       	vmovapd xmm10,XMMWORD PTR [rax+0x20]
    68ef:	c5 f9 10 46 08       	vmovupd xmm0,XMMWORD PTR [rsi+0x8]
    68f4:	c5 f9 10 70 28       	vmovupd xmm6,XMMWORD PTR [rax+0x28]
    68f9:	c5 f9 28 3e          	vmovapd xmm7,XMMWORD PTR [rsi]
    68fd:	c5 f9 2f ca          	vcomisd xmm1,xmm2
    6901:	c4 41 29 15 f2       	vunpckhpd xmm14,xmm10,xmm10
    6906:	c4 41 79 28 ea       	vmovapd xmm13,xmm10
    690b:	c5 79 15 c8          	vunpckhpd xmm9,xmm0,xmm0
    690f:	0f 85 1b 01 00 00    	jne    6a30 <c_run_1.constprop.0+0x180>
    6915:	c5 79 2f d4          	vcomisd xmm10,xmm4
    6919:	0f 85 11 01 00 00    	jne    6a30 <c_run_1.constprop.0+0x180>
    691f:	c5 79 2f f4          	vcomisd xmm14,xmm4
    6923:	0f 85 07 01 00 00    	jne    6a30 <c_run_1.constprop.0+0x180>
    6929:	c5 49 15 c6          	vunpckhpd xmm8,xmm6,xmm6
    692d:	c5 79 2f c4          	vcomisd xmm8,xmm4
    6931:	0f 85 f9 00 00 00    	jne    6a30 <c_run_1.constprop.0+0x180>
    6937:	c5 f9 11 39          	vmovupd XMMWORD PTR [rcx],xmm7
    693b:	c5 7b 11 49 10       	vmovsd QWORD PTR [rcx+0x10],xmm9
    6940:	c5 c1 58 38          	vaddpd xmm7,xmm7,XMMWORD PTR [rax]
    6944:	c5 33 58 48 10       	vaddsd xmm9,xmm9,QWORD PTR [rax+0x10]
    6949:	c5 f9 11 39          	vmovupd XMMWORD PTR [rcx],xmm7
    694d:	c5 7b 11 49 10       	vmovsd QWORD PTR [rcx+0x10],xmm9
    6952:	48 83 c1 38          	add    rcx,0x38
    6956:	48 39 cf             	cmp    rdi,rcx
    6959:	0f 84 71 01 00 00    	je     6ad0 <c_run_1.constprop.0+0x220>
    695f:	c5 fd 10 48 18       	vmovupd ymm1,YMMWORD PTR [rax+0x18]
    6964:	c5 fd 10 46 18       	vmovupd ymm0,YMMWORD PTR [rsi+0x18]
    6969:	c4 e2 7d 19 f1       	vbroadcastsd ymm6,xmm1
    696e:	c4 63 fd 01 c0 4e    	vpermpd ymm8,ymm0,0x4e
    6974:	c4 e3 fd 01 f8 1b    	vpermpd ymm7,ymm0,0x1b
    697a:	c4 63 fd 01 c9 55    	vpermpd ymm9,ymm1,0x55
    6980:	c5 cd 59 f0          	vmulpd ymm6,ymm6,ymm0
    6984:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    698a:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    698f:	c5 cd d0 f0          	vaddsubpd ymm6,ymm6,ymm0
    6993:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    6999:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    699f:	c4 c1 7d 59 c0       	vmulpd ymm0,ymm0,ymm8
    69a4:	c5 f5 59 cf          	vmulpd ymm1,ymm1,ymm7
    69a8:	c5 4d 5c c0          	vsubpd ymm8,ymm6,ymm0
    69ac:	c5 fd 58 c6          	vaddpd ymm0,ymm0,ymm6
    69b0:	c4 c3 7d 0d c0 09    	vblendpd ymm0,ymm0,ymm8,0x9
    69b6:	c5 75 58 c8          	vaddpd ymm9,ymm1,ymm0
    69ba:	c5 fd 5c c9          	vsubpd ymm1,ymm0,ymm1
    69be:	62 73 fd 28 19 cf 01 	vextractf64x2 xmm7,ymm9,0x1
    69c5:	c5 71 15 c1          	vunpckhpd xmm8,xmm1,xmm1
    69c9:	c5 f3 59 c1          	vmulsd xmm0,xmm1,xmm1
    69cd:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    69d2:	62 d3 b5 28 03 f1 03 	valignq ymm6,ymm9,ymm9,0x3
    69d9:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    69de:	c5 c3 59 ff          	vmulsd xmm7,xmm7,xmm7
    69e2:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    69e6:	c5 cb 59 f6          	vmulsd xmm6,xmm6,xmm6
    69ea:	c5 fb 58 c6          	vaddsd xmm0,xmm0,xmm6
    69ee:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    69f2:	c5 f9 2f d8          	vcomisd xmm3,xmm0
    69f6:	0f 87 e4 fe ff ff    	ja     68e0 <c_run_1.constprop.0+0x30>
    69fc:	c4 63 35 0d c9 03    	vblendpd ymm9,ymm9,ymm1,0x3
    6a02:	c5 fb 5c ca          	vsubsd xmm1,xmm0,xmm2
    6a06:	c5 f1 54 0d b2 90 02 	vandpd xmm1,xmm1,XMMWORD PTR [rip+0x290b2]        # 2fac0 <system__secondary_stack__invalid_memory_size+0xb8>
    6a0d:	00 
    6a0e:	c5 f9 2f cb          	vcomisd xmm1,xmm3
    6a12:	0f 87 98 00 00 00    	ja     6ab0 <c_run_1.constprop.0+0x200>
    6a18:	c5 7d 11 49 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm9
    6a1d:	e9 c3 fe ff ff       	jmp    68e5 <c_run_1.constprop.0+0x35>
    6a22:	0f 1f 00             	nop    DWORD PTR [rax]
    6a25:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6a2c:	00 00 00 00 
    6a30:	c4 63 79 05 e1 00    	vpermilpd xmm12,xmm1,0x0
    6a36:	c5 49 15 c1          	vunpckhpd xmm8,xmm6,xmm1
    6a3a:	c5 79 c6 df 01       	vshufpd xmm11,xmm0,xmm7,0x1
    6a3f:	c5 b9 59 cf          	vmulpd xmm1,xmm8,xmm7
    6a43:	c4 41 79 59 fc       	vmulpd xmm15,xmm0,xmm12
    6a48:	c4 c1 79 59 c2       	vmulpd xmm0,xmm0,xmm10
    6a4d:	c4 c1 71 58 cf       	vaddpd xmm1,xmm1,xmm15
    6a52:	c4 41 21 59 fa       	vmulpd xmm15,xmm11,xmm10
    6a57:	c4 41 21 59 dc       	vmulpd xmm11,xmm11,xmm12
    6a5c:	c5 49 59 d7          	vmulpd xmm10,xmm6,xmm7
    6a60:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    6a65:	c4 c1 71 5c cf       	vsubpd xmm1,xmm1,xmm15
    6a6a:	c4 c1 79 5c c2       	vsubpd xmm0,xmm0,xmm10
    6a6f:	c4 41 71 59 c0       	vmulpd xmm8,xmm1,xmm8
    6a74:	c4 c1 73 59 cd       	vmulsd xmm1,xmm1,xmm13
    6a79:	c5 c9 59 f0          	vmulpd xmm6,xmm6,xmm0
    6a7d:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    6a81:	c4 c1 7b 59 c6       	vmulsd xmm0,xmm0,xmm14
    6a86:	c4 c1 49 5c f0       	vsubpd xmm6,xmm6,xmm8
    6a8b:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    6a8f:	c5 c9 58 f6          	vaddpd xmm6,xmm6,xmm6
    6a93:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    6a97:	c5 c1 58 fe          	vaddpd xmm7,xmm7,xmm6
    6a9b:	c5 33 58 c8          	vaddsd xmm9,xmm9,xmm0
    6a9f:	c5 f9 11 39          	vmovupd XMMWORD PTR [rcx],xmm7
    6aa3:	c5 7b 11 49 10       	vmovsd QWORD PTR [rcx+0x10],xmm9
    6aa8:	e9 93 fe ff ff       	jmp    6940 <c_run_1.constprop.0+0x90>
    6aad:	0f 1f 00             	nop    DWORD PTR [rax]
    6ab0:	c5 eb 5e c0          	vdivsd xmm0,xmm2,xmm0
    6ab4:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    6ab9:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    6abe:	c5 fd 11 41 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm0
    6ac3:	e9 1d fe ff ff       	jmp    68e5 <c_run_1.constprop.0+0x35>
    6ac8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    6acf:	00 
    6ad0:	c5 f8 77             	vzeroupper
    6ad3:	c3                   	ret
    6ad4:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    6adb:	00 00 00 
    6ade:	66 90                	xchg   ax,ax

0000000000006ae0 <c_run_1>:
    6ae0:	48 89 f0             	mov    rax,rsi
    6ae3:	89 fe                	mov    esi,edi
    6ae5:	c5 fb 10 1d cb 8e 02 	vmovsd xmm3,QWORD PTR [rip+0x28ecb]        # 2f9b8 <system__os_lib__standin+0xc>
    6aec:	00 
    6aed:	c5 fb 10 15 eb 6c 02 	vmovsd xmm2,QWORD PTR [rip+0x26ceb]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    6af4:	00 
    6af5:	48 6b f6 38          	imul   rsi,rsi,0x38
    6af9:	c5 fd 28 2d df 6c 02 	vmovapd ymm5,YMMWORD PTR [rip+0x26cdf]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    6b00:	00 
    6b01:	c5 d9 57 e4          	vxorpd xmm4,xmm4,xmm4
    6b05:	4c 01 c6             	add    rsi,r8
    6b08:	e9 94 00 00 00       	jmp    6ba1 <c_run_1+0xc1>
    6b0d:	0f 1f 00             	nop    DWORD PTR [rax]
    6b10:	c4 c1 7d 11 68 18    	vmovupd YMMWORD PTR [r8+0x18],ymm5
    6b16:	c5 f9 10 48 18       	vmovupd xmm1,XMMWORD PTR [rax+0x18]
    6b1b:	c5 79 28 50 20       	vmovapd xmm10,XMMWORD PTR [rax+0x20]
    6b20:	c5 f9 10 42 08       	vmovupd xmm0,XMMWORD PTR [rdx+0x8]
    6b25:	c5 f9 10 70 28       	vmovupd xmm6,XMMWORD PTR [rax+0x28]
    6b2a:	c5 f9 28 3a          	vmovapd xmm7,XMMWORD PTR [rdx]
    6b2e:	c5 f9 2f ca          	vcomisd xmm1,xmm2
    6b32:	c4 41 29 15 f2       	vunpckhpd xmm14,xmm10,xmm10
    6b37:	c4 41 79 28 ea       	vmovapd xmm13,xmm10
    6b3c:	c5 79 15 c8          	vunpckhpd xmm9,xmm0,xmm0
    6b40:	0f 85 2a 01 00 00    	jne    6c70 <c_run_1+0x190>
    6b46:	c5 79 2f d4          	vcomisd xmm10,xmm4
    6b4a:	0f 85 20 01 00 00    	jne    6c70 <c_run_1+0x190>
    6b50:	c5 79 2f f4          	vcomisd xmm14,xmm4
    6b54:	0f 85 16 01 00 00    	jne    6c70 <c_run_1+0x190>
    6b5a:	c5 49 15 c6          	vunpckhpd xmm8,xmm6,xmm6
    6b5e:	c5 79 2f c4          	vcomisd xmm8,xmm4
    6b62:	0f 85 08 01 00 00    	jne    6c70 <c_run_1+0x190>
    6b68:	c4 c1 79 11 38       	vmovupd XMMWORD PTR [r8],xmm7
    6b6d:	c4 41 7b 11 48 10    	vmovsd QWORD PTR [r8+0x10],xmm9
    6b73:	66 90                	xchg   ax,ax
    6b75:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6b7c:	00 00 00 00 
    6b80:	c5 c1 58 38          	vaddpd xmm7,xmm7,XMMWORD PTR [rax]
    6b84:	c5 33 58 48 10       	vaddsd xmm9,xmm9,QWORD PTR [rax+0x10]
    6b89:	c4 c1 79 11 38       	vmovupd XMMWORD PTR [r8],xmm7
    6b8e:	c4 41 7b 11 48 10    	vmovsd QWORD PTR [r8+0x10],xmm9
    6b94:	49 83 c0 38          	add    r8,0x38
    6b98:	4c 39 c6             	cmp    rsi,r8
    6b9b:	0f 84 6f 01 00 00    	je     6d10 <c_run_1+0x230>
    6ba1:	c5 fd 10 48 18       	vmovupd ymm1,YMMWORD PTR [rax+0x18]
    6ba6:	c5 fd 10 42 18       	vmovupd ymm0,YMMWORD PTR [rdx+0x18]
    6bab:	c4 e2 7d 19 f1       	vbroadcastsd ymm6,xmm1
    6bb0:	c4 63 fd 01 c0 4e    	vpermpd ymm8,ymm0,0x4e
    6bb6:	c4 e3 fd 01 f8 1b    	vpermpd ymm7,ymm0,0x1b
    6bbc:	c4 63 fd 01 c9 55    	vpermpd ymm9,ymm1,0x55
    6bc2:	c5 cd 59 f0          	vmulpd ymm6,ymm6,ymm0
    6bc6:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    6bcc:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    6bd1:	c5 cd d0 f0          	vaddsubpd ymm6,ymm6,ymm0
    6bd5:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    6bdb:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    6be1:	c4 c1 7d 59 c0       	vmulpd ymm0,ymm0,ymm8
    6be6:	c5 f5 59 cf          	vmulpd ymm1,ymm1,ymm7
    6bea:	c5 4d 5c c0          	vsubpd ymm8,ymm6,ymm0
    6bee:	c5 fd 58 c6          	vaddpd ymm0,ymm0,ymm6
    6bf2:	c4 c3 7d 0d c0 09    	vblendpd ymm0,ymm0,ymm8,0x9
    6bf8:	c5 75 58 c8          	vaddpd ymm9,ymm1,ymm0
    6bfc:	c5 fd 5c c9          	vsubpd ymm1,ymm0,ymm1
    6c00:	62 73 fd 28 19 cf 01 	vextractf64x2 xmm7,ymm9,0x1
    6c07:	c5 71 15 c1          	vunpckhpd xmm8,xmm1,xmm1
    6c0b:	c5 f3 59 c1          	vmulsd xmm0,xmm1,xmm1
    6c0f:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    6c14:	62 d3 b5 28 03 f1 03 	valignq ymm6,ymm9,ymm9,0x3
    6c1b:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    6c20:	c5 c3 59 ff          	vmulsd xmm7,xmm7,xmm7
    6c24:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    6c28:	c5 cb 59 f6          	vmulsd xmm6,xmm6,xmm6
    6c2c:	c5 fb 58 c6          	vaddsd xmm0,xmm0,xmm6
    6c30:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    6c34:	c5 f9 2f d8          	vcomisd xmm3,xmm0
    6c38:	0f 87 d2 fe ff ff    	ja     6b10 <c_run_1+0x30>
    6c3e:	c4 63 35 0d c9 03    	vblendpd ymm9,ymm9,ymm1,0x3
    6c44:	c5 fb 5c ca          	vsubsd xmm1,xmm0,xmm2
    6c48:	c5 f1 54 0d 70 8e 02 	vandpd xmm1,xmm1,XMMWORD PTR [rip+0x28e70]        # 2fac0 <system__secondary_stack__invalid_memory_size+0xb8>
    6c4f:	00 
    6c50:	c5 f9 2f cb          	vcomisd xmm1,xmm3
    6c54:	0f 87 96 00 00 00    	ja     6cf0 <c_run_1+0x210>
    6c5a:	c4 41 7d 11 48 18    	vmovupd YMMWORD PTR [r8+0x18],ymm9
    6c60:	e9 b1 fe ff ff       	jmp    6b16 <c_run_1+0x36>
    6c65:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6c6c:	00 00 00 00 
    6c70:	c4 63 79 05 e1 00    	vpermilpd xmm12,xmm1,0x0
    6c76:	c5 49 15 c1          	vunpckhpd xmm8,xmm6,xmm1
    6c7a:	c5 79 c6 df 01       	vshufpd xmm11,xmm0,xmm7,0x1
    6c7f:	c5 b9 59 cf          	vmulpd xmm1,xmm8,xmm7
    6c83:	c4 41 79 59 fc       	vmulpd xmm15,xmm0,xmm12
    6c88:	c4 c1 79 59 c2       	vmulpd xmm0,xmm0,xmm10
    6c8d:	c4 c1 71 58 cf       	vaddpd xmm1,xmm1,xmm15
    6c92:	c4 41 21 59 fa       	vmulpd xmm15,xmm11,xmm10
    6c97:	c4 41 21 59 dc       	vmulpd xmm11,xmm11,xmm12
    6c9c:	c5 49 59 d7          	vmulpd xmm10,xmm6,xmm7
    6ca0:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    6ca5:	c4 c1 71 5c cf       	vsubpd xmm1,xmm1,xmm15
    6caa:	c4 c1 79 5c c2       	vsubpd xmm0,xmm0,xmm10
    6caf:	c4 41 71 59 c0       	vmulpd xmm8,xmm1,xmm8
    6cb4:	c4 c1 73 59 cd       	vmulsd xmm1,xmm1,xmm13
    6cb9:	c5 c9 59 f0          	vmulpd xmm6,xmm6,xmm0
    6cbd:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    6cc1:	c4 c1 7b 59 c6       	vmulsd xmm0,xmm0,xmm14
    6cc6:	c4 c1 49 5c f0       	vsubpd xmm6,xmm6,xmm8
    6ccb:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    6ccf:	c5 c9 58 f6          	vaddpd xmm6,xmm6,xmm6
    6cd3:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    6cd7:	c5 c1 58 fe          	vaddpd xmm7,xmm7,xmm6
    6cdb:	c5 33 58 c8          	vaddsd xmm9,xmm9,xmm0
    6cdf:	c4 c1 79 11 38       	vmovupd XMMWORD PTR [r8],xmm7
    6ce4:	c4 41 7b 11 48 10    	vmovsd QWORD PTR [r8+0x10],xmm9
    6cea:	e9 91 fe ff ff       	jmp    6b80 <c_run_1+0xa0>
    6cef:	90                   	nop
    6cf0:	c5 eb 5e c0          	vdivsd xmm0,xmm2,xmm0
    6cf4:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    6cf9:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    6cfe:	c4 c1 7d 11 40 18    	vmovupd YMMWORD PTR [r8+0x18],ymm0
    6d04:	e9 0d fe ff ff       	jmp    6b16 <c_run_1+0x36>
    6d09:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    6d10:	c5 f8 77             	vzeroupper
    6d13:	c3                   	ret
    6d14:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    6d1b:	00 00 00 
    6d1e:	66 90                	xchg   ax,ax

0000000000006d20 <c_run_2.constprop.0>:
    6d20:	55                   	push   rbp
    6d21:	48 89 c8             	mov    rax,rcx
    6d24:	4c 8d 89 c0 01 00 00 	lea    r9,[rcx+0x1c0]
    6d2b:	c5 d9 57 e4          	vxorpd xmm4,xmm4,xmm4
    6d2f:	48 89 e5             	mov    rbp,rsp
    6d32:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    6d36:	c5 fb 10 2d 7a 8c 02 	vmovsd xmm5,QWORD PTR [rip+0x28c7a]        # 2f9b8 <system__os_lib__standin+0xc>
    6d3d:	00 
    6d3e:	c5 fb 10 35 9a 6a 02 	vmovsd xmm6,QWORD PTR [rip+0x26a9a]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    6d45:	00 
    6d46:	c5 fd 28 3d 92 6a 02 	vmovapd ymm7,YMMWORD PTR [rip+0x26a92]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    6d4d:	00 
    6d4e:	e9 e6 00 00 00       	jmp    6e39 <c_run_2.constprop.0+0x119>
    6d53:	66 90                	xchg   ax,ax
    6d55:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6d5c:	00 00 00 00 
    6d60:	c5 fd 11 78 18       	vmovupd YMMWORD PTR [rax+0x18],ymm7
    6d65:	c5 f9 10 56 08       	vmovupd xmm2,XMMWORD PTR [rsi+0x8]
    6d6a:	c5 79 2f f4          	vcomisd xmm14,xmm4
    6d6e:	c5 79 28 0e          	vmovapd xmm9,XMMWORD PTR [rsi]
    6d72:	41 0f 94 c0          	sete   r8b
    6d76:	c5 79 2f ec          	vcomisd xmm13,xmm4
    6d7a:	0f 94 c1             	sete   cl
    6d7d:	c5 69 15 d2          	vunpckhpd xmm10,xmm2,xmm2
    6d81:	41 84 c8             	test   r8b,cl
    6d84:	74 16                	je     6d9c <c_run_2.constprop.0+0x7c>
    6d86:	62 e1 fd 08 2f c6    	vcomisd xmm16,xmm6
    6d8c:	41 0f 94 c0          	sete   r8b
    6d90:	c5 79 2f fc          	vcomisd xmm15,xmm4
    6d94:	0f 94 c1             	sete   cl
    6d97:	41 84 c8             	test   r8b,cl
    6d9a:	75 7b                	jne    6e17 <c_run_2.constprop.0+0xf7>
    6d9c:	c5 7b 12 2e          	vmovddup xmm13,QWORD PTR [rsi]
    6da0:	c5 61 15 e1          	vunpckhpd xmm12,xmm3,xmm1
    6da4:	c4 e3 79 05 c1 00    	vpermilpd xmm0,xmm1,0x0
    6daa:	c4 41 31 59 f4       	vmulpd xmm14,xmm9,xmm12
    6daf:	c5 79 59 c2          	vmulpd xmm8,xmm0,xmm2
    6db3:	c4 41 39 58 c6       	vaddpd xmm8,xmm8,xmm14
    6db8:	c4 41 69 15 ed       	vunpckhpd xmm13,xmm2,xmm13
    6dbd:	c4 41 11 59 f3       	vmulpd xmm14,xmm13,xmm11
    6dc2:	c4 c1 79 59 c5       	vmulpd xmm0,xmm0,xmm13
    6dc7:	c5 21 59 da          	vmulpd xmm11,xmm11,xmm2
    6dcb:	c5 b1 59 d3          	vmulpd xmm2,xmm9,xmm3
    6dcf:	c4 41 39 5c c6       	vsubpd xmm8,xmm8,xmm14
    6dd4:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    6dd9:	c4 41 19 59 e0       	vmulpd xmm12,xmm12,xmm8
    6dde:	c5 f9 5c c2          	vsubpd xmm0,xmm0,xmm2
    6de2:	c5 f1 15 d1          	vunpckhpd xmm2,xmm1,xmm1
    6de6:	62 f3 fd 28 19 c9 01 	vextractf64x2 xmm1,ymm1,0x1
    6ded:	c4 c1 6b 59 d0       	vmulsd xmm2,xmm2,xmm8
    6df2:	c5 f9 59 db          	vmulpd xmm3,xmm0,xmm3
    6df6:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    6dfa:	c5 f3 59 c8          	vmulsd xmm1,xmm1,xmm0
    6dfe:	c4 c1 61 5c dc       	vsubpd xmm3,xmm3,xmm12
    6e03:	c5 eb 5c c1          	vsubsd xmm0,xmm2,xmm1
    6e07:	c5 e1 58 db          	vaddpd xmm3,xmm3,xmm3
    6e0b:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    6e0f:	c5 31 58 cb          	vaddpd xmm9,xmm9,xmm3
    6e13:	c5 2b 58 d0          	vaddsd xmm10,xmm10,xmm0
    6e17:	c5 31 58 4c 24 c0    	vaddpd xmm9,xmm9,XMMWORD PTR [rsp-0x40]
    6e1d:	c5 2b 58 54 24 d0    	vaddsd xmm10,xmm10,QWORD PTR [rsp-0x30]
    6e23:	c5 79 11 08          	vmovupd XMMWORD PTR [rax],xmm9
    6e27:	c5 7b 11 50 10       	vmovsd QWORD PTR [rax+0x10],xmm10
    6e2c:	48 83 c0 38          	add    rax,0x38
    6e30:	49 39 c1             	cmp    r9,rax
    6e33:	0f 84 27 01 00 00    	je     6f60 <c_run_2.constprop.0+0x240>
    6e39:	c5 fe 6f 00          	vmovdqu ymm0,YMMWORD PTR [rax]
    6e3d:	c5 fe 6f 48 18       	vmovdqu ymm1,YMMWORD PTR [rax+0x18]
    6e42:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    6e48:	c5 fd 10 46 18       	vmovupd ymm0,YMMWORD PTR [rsi+0x18]
    6e4d:	c4 e2 7d 19 d1       	vbroadcastsd ymm2,xmm1
    6e52:	c4 e3 fd 01 d9 55    	vpermpd ymm3,ymm1,0x55
    6e58:	c5 fe 7f 4c 24 d8    	vmovdqu YMMWORD PTR [rsp-0x28],ymm1
    6e5e:	62 e1 ff 08 10 44 24 	vmovsd xmm16,QWORD PTR [rsp-0x28]
    6e65:	fb 
    6e66:	c5 79 28 5c 24 e0    	vmovapd xmm11,XMMWORD PTR [rsp-0x20]
    6e6c:	c5 7b 10 7c 24 e0    	vmovsd xmm15,QWORD PTR [rsp-0x20]
    6e72:	c5 7b 10 6c 24 e8    	vmovsd xmm13,QWORD PTR [rsp-0x18]
    6e78:	c5 7b 10 74 24 f0    	vmovsd xmm14,QWORD PTR [rsp-0x10]
    6e7e:	c4 63 fd 01 c8 4e    	vpermpd ymm9,ymm0,0x4e
    6e84:	c5 ed 59 d0          	vmulpd ymm2,ymm2,ymm0
    6e88:	c4 63 fd 01 c0 1b    	vpermpd ymm8,ymm0,0x1b
    6e8e:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    6e94:	c5 fd 59 c3          	vmulpd ymm0,ymm0,ymm3
    6e98:	c5 f9 10 5c 24 e8    	vmovupd xmm3,XMMWORD PTR [rsp-0x18]
    6e9e:	c5 ed d0 d0          	vaddsubpd ymm2,ymm2,ymm0
    6ea2:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    6ea8:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    6ead:	c5 6d 5c c8          	vsubpd ymm9,ymm2,ymm0
    6eb1:	c5 fd 58 c2          	vaddpd ymm0,ymm0,ymm2
    6eb5:	c4 e3 fd 01 d1 ff    	vpermpd ymm2,ymm1,0xff
    6ebb:	c4 c1 6d 59 d0       	vmulpd ymm2,ymm2,ymm8
    6ec0:	c4 c3 7d 0d c1 09    	vblendpd ymm0,ymm0,ymm9,0x9
    6ec6:	c5 6d 58 e0          	vaddpd ymm12,ymm2,ymm0
    6eca:	c5 fd 5c d2          	vsubpd ymm2,ymm0,ymm2
    6ece:	62 53 fd 28 19 e1 01 	vextractf64x2 xmm9,ymm12,0x1
    6ed5:	c5 69 15 d2          	vunpckhpd xmm10,xmm2,xmm2
    6ed9:	c5 eb 59 c2          	vmulsd xmm0,xmm2,xmm2
    6edd:	c4 41 2b 59 d2       	vmulsd xmm10,xmm10,xmm10
    6ee2:	62 53 9d 28 03 c4 03 	valignq ymm8,ymm12,ymm12,0x3
    6ee9:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    6eee:	c4 41 33 59 c9       	vmulsd xmm9,xmm9,xmm9
    6ef3:	c4 c1 7b 58 c1       	vaddsd xmm0,xmm0,xmm9
    6ef8:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    6efd:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    6f02:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    6f06:	c5 f9 2f e8          	vcomisd xmm5,xmm0
    6f0a:	0f 87 50 fe ff ff    	ja     6d60 <c_run_2.constprop.0+0x40>
    6f10:	c4 63 1d 0d e2 03    	vblendpd ymm12,ymm12,ymm2,0x3
    6f16:	c5 fb 5c d6          	vsubsd xmm2,xmm0,xmm6
    6f1a:	c5 e9 54 15 9e 8b 02 	vandpd xmm2,xmm2,XMMWORD PTR [rip+0x28b9e]        # 2fac0 <system__secondary_stack__invalid_memory_size+0xb8>
    6f21:	00 
    6f22:	c5 f9 2f d5          	vcomisd xmm2,xmm5
    6f26:	77 18                	ja     6f40 <c_run_2.constprop.0+0x220>
    6f28:	c5 7d 11 60 18       	vmovupd YMMWORD PTR [rax+0x18],ymm12
    6f2d:	e9 33 fe ff ff       	jmp    6d65 <c_run_2.constprop.0+0x45>
    6f32:	0f 1f 00             	nop    DWORD PTR [rax]
    6f35:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6f3c:	00 00 00 00 
    6f40:	c5 cb 5e c0          	vdivsd xmm0,xmm6,xmm0
    6f44:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    6f49:	c4 c1 7d 59 c4       	vmulpd ymm0,ymm0,ymm12
    6f4e:	c5 fd 11 40 18       	vmovupd YMMWORD PTR [rax+0x18],ymm0
    6f53:	e9 0d fe ff ff       	jmp    6d65 <c_run_2.constprop.0+0x45>
    6f58:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    6f5f:	00 
    6f60:	c5 f8 77             	vzeroupper
    6f63:	c9                   	leave
    6f64:	c3                   	ret
    6f65:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    6f6c:	00 00 00 
    6f6f:	90                   	nop

0000000000007000 <c_run_2>:
    7000:	41 89 f9             	mov    r9d,edi
    7003:	55                   	push   rbp
    7004:	48 89 d0             	mov    rax,rdx
    7007:	c5 d9 57 e4          	vxorpd xmm4,xmm4,xmm4
    700b:	4d 6b c9 38          	imul   r9,r9,0x38
    700f:	48 89 e5             	mov    rbp,rsp
    7012:	48 89 ca             	mov    rdx,rcx
    7015:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    7019:	4d 01 c1             	add    r9,r8
    701c:	c5 fb 10 2d 94 89 02 	vmovsd xmm5,QWORD PTR [rip+0x28994]        # 2f9b8 <system__os_lib__standin+0xc>
    7023:	00 
    7024:	c5 fb 10 35 b4 67 02 	vmovsd xmm6,QWORD PTR [rip+0x267b4]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    702b:	00 
    702c:	c5 fd 28 3d ac 67 02 	vmovapd ymm7,YMMWORD PTR [rip+0x267ac]        # 2d7e0 <__gnat_ada_main_program_name+0x18>
    7033:	00 
    7034:	e9 e3 00 00 00       	jmp    711c <c_run_2+0x11c>
    7039:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    7040:	c4 c1 7d 11 78 18    	vmovupd YMMWORD PTR [r8+0x18],ymm7
    7046:	c5 f9 10 50 08       	vmovupd xmm2,XMMWORD PTR [rax+0x8]
    704b:	c5 79 2f f4          	vcomisd xmm14,xmm4
    704f:	c5 79 28 08          	vmovapd xmm9,XMMWORD PTR [rax]
    7053:	40 0f 94 c7          	sete   dil
    7057:	c5 79 2f ec          	vcomisd xmm13,xmm4
    705b:	0f 94 c1             	sete   cl
    705e:	c5 69 15 d2          	vunpckhpd xmm10,xmm2,xmm2
    7062:	40 84 cf             	test   dil,cl
    7065:	74 16                	je     707d <c_run_2+0x7d>
    7067:	62 e1 fd 08 2f c6    	vcomisd xmm16,xmm6
    706d:	40 0f 94 c7          	sete   dil
    7071:	c5 79 2f fc          	vcomisd xmm15,xmm4
    7075:	0f 94 c1             	sete   cl
    7078:	40 84 cf             	test   dil,cl
    707b:	75 7b                	jne    70f8 <c_run_2+0xf8>
    707d:	c5 7b 12 28          	vmovddup xmm13,QWORD PTR [rax]
    7081:	c5 61 15 e1          	vunpckhpd xmm12,xmm3,xmm1
    7085:	c4 e3 79 05 c1 00    	vpermilpd xmm0,xmm1,0x0
    708b:	c4 41 31 59 f4       	vmulpd xmm14,xmm9,xmm12
    7090:	c5 79 59 c2          	vmulpd xmm8,xmm0,xmm2
    7094:	c4 41 39 58 c6       	vaddpd xmm8,xmm8,xmm14
    7099:	c4 41 69 15 ed       	vunpckhpd xmm13,xmm2,xmm13
    709e:	c4 41 11 59 f3       	vmulpd xmm14,xmm13,xmm11
    70a3:	c4 c1 79 59 c5       	vmulpd xmm0,xmm0,xmm13
    70a8:	c5 21 59 da          	vmulpd xmm11,xmm11,xmm2
    70ac:	c5 b1 59 d3          	vmulpd xmm2,xmm9,xmm3
    70b0:	c4 41 39 5c c6       	vsubpd xmm8,xmm8,xmm14
    70b5:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    70ba:	c4 41 19 59 e0       	vmulpd xmm12,xmm12,xmm8
    70bf:	c5 f9 5c c2          	vsubpd xmm0,xmm0,xmm2
    70c3:	c5 f1 15 d1          	vunpckhpd xmm2,xmm1,xmm1
    70c7:	62 f3 fd 28 19 c9 01 	vextractf64x2 xmm1,ymm1,0x1
    70ce:	c4 c1 6b 59 d0       	vmulsd xmm2,xmm2,xmm8
    70d3:	c5 f9 59 db          	vmulpd xmm3,xmm0,xmm3
    70d7:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    70db:	c5 f3 59 c8          	vmulsd xmm1,xmm1,xmm0
    70df:	c4 c1 61 5c dc       	vsubpd xmm3,xmm3,xmm12
    70e4:	c5 eb 5c c1          	vsubsd xmm0,xmm2,xmm1
    70e8:	c5 e1 58 db          	vaddpd xmm3,xmm3,xmm3
    70ec:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    70f0:	c5 31 58 cb          	vaddpd xmm9,xmm9,xmm3
    70f4:	c5 2b 58 d0          	vaddsd xmm10,xmm10,xmm0
    70f8:	c5 31 58 4c 24 c0    	vaddpd xmm9,xmm9,XMMWORD PTR [rsp-0x40]
    70fe:	c5 2b 58 54 24 d0    	vaddsd xmm10,xmm10,QWORD PTR [rsp-0x30]
    7104:	c4 41 79 11 08       	vmovupd XMMWORD PTR [r8],xmm9
    7109:	c4 41 7b 11 50 10    	vmovsd QWORD PTR [r8+0x10],xmm10
    710f:	49 83 c0 38          	add    r8,0x38
    7113:	4d 39 c1             	cmp    r9,r8
    7116:	0f 84 24 01 00 00    	je     7240 <c_run_2+0x240>
    711c:	c4 c1 7e 6f 00       	vmovdqu ymm0,YMMWORD PTR [r8]
    7121:	c4 c1 7e 6f 48 18    	vmovdqu ymm1,YMMWORD PTR [r8+0x18]
    7127:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    712d:	c5 fd 10 40 18       	vmovupd ymm0,YMMWORD PTR [rax+0x18]
    7132:	c4 e2 7d 19 d1       	vbroadcastsd ymm2,xmm1
    7137:	c4 e3 fd 01 d9 55    	vpermpd ymm3,ymm1,0x55
    713d:	c5 fe 7f 4c 24 d8    	vmovdqu YMMWORD PTR [rsp-0x28],ymm1
    7143:	62 e1 ff 08 10 44 24 	vmovsd xmm16,QWORD PTR [rsp-0x28]
    714a:	fb 
    714b:	c5 79 28 5c 24 e0    	vmovapd xmm11,XMMWORD PTR [rsp-0x20]
    7151:	c5 7b 10 7c 24 e0    	vmovsd xmm15,QWORD PTR [rsp-0x20]
    7157:	c5 7b 10 6c 24 e8    	vmovsd xmm13,QWORD PTR [rsp-0x18]
    715d:	c5 7b 10 74 24 f0    	vmovsd xmm14,QWORD PTR [rsp-0x10]
    7163:	c4 63 fd 01 c8 4e    	vpermpd ymm9,ymm0,0x4e
    7169:	c5 ed 59 d0          	vmulpd ymm2,ymm2,ymm0
    716d:	c4 63 fd 01 c0 1b    	vpermpd ymm8,ymm0,0x1b
    7173:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    7179:	c5 fd 59 c3          	vmulpd ymm0,ymm0,ymm3
    717d:	c5 f9 10 5c 24 e8    	vmovupd xmm3,XMMWORD PTR [rsp-0x18]
    7183:	c5 ed d0 d0          	vaddsubpd ymm2,ymm2,ymm0
    7187:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    718d:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    7192:	c5 6d 5c c8          	vsubpd ymm9,ymm2,ymm0
    7196:	c5 fd 58 c2          	vaddpd ymm0,ymm0,ymm2
    719a:	c4 e3 fd 01 d1 ff    	vpermpd ymm2,ymm1,0xff
    71a0:	c4 c1 6d 59 d0       	vmulpd ymm2,ymm2,ymm8
    71a5:	c4 c3 7d 0d c1 09    	vblendpd ymm0,ymm0,ymm9,0x9
    71ab:	c5 6d 58 e0          	vaddpd ymm12,ymm2,ymm0
    71af:	c5 fd 5c d2          	vsubpd ymm2,ymm0,ymm2
    71b3:	62 53 fd 28 19 e1 01 	vextractf64x2 xmm9,ymm12,0x1
    71ba:	c5 69 15 d2          	vunpckhpd xmm10,xmm2,xmm2
    71be:	c5 eb 59 c2          	vmulsd xmm0,xmm2,xmm2
    71c2:	c4 41 2b 59 d2       	vmulsd xmm10,xmm10,xmm10
    71c7:	62 53 9d 28 03 c4 03 	valignq ymm8,ymm12,ymm12,0x3
    71ce:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    71d3:	c4 41 33 59 c9       	vmulsd xmm9,xmm9,xmm9
    71d8:	c4 c1 7b 58 c1       	vaddsd xmm0,xmm0,xmm9
    71dd:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    71e2:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    71e7:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    71eb:	c5 f9 2f e8          	vcomisd xmm5,xmm0
    71ef:	0f 87 4b fe ff ff    	ja     7040 <c_run_2+0x40>
    71f5:	c4 63 1d 0d e2 03    	vblendpd ymm12,ymm12,ymm2,0x3
    71fb:	c5 fb 5c d6          	vsubsd xmm2,xmm0,xmm6
    71ff:	c5 e9 54 15 b9 88 02 	vandpd xmm2,xmm2,XMMWORD PTR [rip+0x288b9]        # 2fac0 <system__secondary_stack__invalid_memory_size+0xb8>
    7206:	00 
    7207:	c5 f9 2f d5          	vcomisd xmm2,xmm5
    720b:	77 13                	ja     7220 <c_run_2+0x220>
    720d:	c4 41 7d 11 60 18    	vmovupd YMMWORD PTR [r8+0x18],ymm12
    7213:	e9 2e fe ff ff       	jmp    7046 <c_run_2+0x46>
    7218:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    721f:	00 
    7220:	c5 cb 5e c0          	vdivsd xmm0,xmm6,xmm0
    7224:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    7229:	c4 c1 7d 59 c4       	vmulpd ymm0,ymm0,ymm12
    722e:	c4 c1 7d 11 40 18    	vmovupd YMMWORD PTR [r8+0x18],ymm0
    7234:	e9 0d fe ff ff       	jmp    7046 <c_run_2+0x46>
    7239:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    7240:	c5 f8 77             	vzeroupper
    7243:	c9                   	leave
    7244:	c3                   	ret
    7245:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    724c:	00 00 00 
    724f:	90                   	nop
