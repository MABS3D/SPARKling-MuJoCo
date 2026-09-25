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
    3d00:	c5 7b 10 0d 58 9b 02 	vmovsd xmm9,QWORD PTR [rip+0x29b58]        # 2d860 <__gnat_ada_main_program_name+0x18>
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
    3d3d:	c5 e1 57 05 eb bd 02 	vxorpd xmm0,xmm3,XMMWORD PTR [rip+0x2bdeb]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    3d44:	00 
    3d45:	c5 c9 57 25 e3 bd 02 	vxorpd xmm4,xmm6,XMMWORD PTR [rip+0x2bde3]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    3d4c:	00 
    3d4d:	c5 d1 57 0d db bd 02 	vxorpd xmm1,xmm5,XMMWORD PTR [rip+0x2bddb]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
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
    3e3a:	c5 e1 57 1d ee bc 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2bcee]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    3e41:	00 
    3e42:	c5 f1 57 0d e6 bc 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2bce6]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    3e49:	00 
    3e4a:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    3e4f:	c5 f9 57 05 d9 bc 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2bcd9]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
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
    3e80:	c5 fb 10 05 a8 bc 02 	vmovsd xmm0,QWORD PTR [rip+0x2bca8]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    3e87:	00 
    3e88:	c5 f9 28 c8          	vmovapd xmm1,xmm0
    3e8c:	c5 f9 28 d8          	vmovapd xmm3,xmm0
    3e90:	eb c5                	jmp    3e57 <adapter__run_4+0x157>
    3e92:	0f 1f 00             	nop    DWORD PTR [rax]
    3e95:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    3e9c:	00 00 00 00 
    3ea0:	c5 c1 57 1d 88 bc 02 	vxorpd xmm3,xmm7,XMMWORD PTR [rip+0x2bc88]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    3ea7:	00 
    3ea8:	c5 a1 57 0d 80 bc 02 	vxorpd xmm1,xmm11,XMMWORD PTR [rip+0x2bc80]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    3eaf:	00 
    3eb0:	c5 a9 57 05 78 bc 02 	vxorpd xmm0,xmm10,XMMWORD PTR [rip+0x2bc78]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    3eb7:	00 
    3eb8:	eb 9d                	jmp    3e57 <adapter__run_4+0x157>
    3eba:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000003ec0 <adapter__run_5>:
    3ec0:	89 f8                	mov    eax,edi
    3ec2:	c5 7b 10 05 96 99 02 	vmovsd xmm8,QWORD PTR [rip+0x29996]        # 2d860 <__gnat_ada_main_program_name+0x18>
    3ec9:	00 
    3eca:	c4 41 31 57 c9       	vxorpd xmm9,xmm9,xmm9
    3ecf:	48 6b c0 38          	imul   rax,rax,0x38
    3ed3:	4c 01 c0             	add    rax,r8
    3ed6:	eb 50                	jmp    3f28 <adapter__run_5+0x68>
    3ed8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    3edf:	00 
    3ee0:	c4 c1 79 2f e9       	vcomisd xmm5,xmm9
    3ee5:	75 79                	jne    3f60 <adapter__run_5+0xa0>
    3ee7:	c4 41 79 2f e9       	vcomisd xmm13,xmm9
    3eec:	75 72                	jne    3f60 <adapter__run_5+0xa0>
    3eee:	c5 e9 15 da          	vunpckhpd xmm3,xmm2,xmm2
    3ef2:	c4 c1 79 2f d9       	vcomisd xmm3,xmm9
    3ef7:	75 67                	jne    3f60 <adapter__run_5+0xa0>
    3ef9:	c4 c1 21 58 d4       	vaddpd xmm2,xmm11,xmm12
    3efe:	c5 ab 58 c7          	vaddsd xmm0,xmm10,xmm7
    3f02:	0f 1f 00             	nop    DWORD PTR [rax]
    3f05:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    3f0c:	00 00 00 00 
    3f10:	c4 c1 79 11 10       	vmovupd XMMWORD PTR [r8],xmm2
    3f15:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    3f1b:	49 83 c0 38          	add    r8,0x38
    3f1f:	49 39 c0             	cmp    r8,rax
    3f22:	0f 84 c8 00 00 00    	je     3ff0 <adapter__run_5+0x130>
    3f28:	c5 f9 28 4e 10       	vmovapd xmm1,XMMWORD PTR [rsi+0x10]
    3f2d:	c5 f9 28 6e 20       	vmovapd xmm5,XMMWORD PTR [rsi+0x20]
    3f32:	c5 f9 10 41 08       	vmovupd xmm0,XMMWORD PTR [rcx+0x8]
    3f37:	c5 f9 10 56 28       	vmovupd xmm2,XMMWORD PTR [rsi+0x28]
    3f3c:	c5 79 28 21          	vmovapd xmm12,XMMWORD PTR [rcx]
    3f40:	c5 79 28 1e          	vmovapd xmm11,XMMWORD PTR [rsi]
    3f44:	c5 fb 10 7e 10       	vmovsd xmm7,QWORD PTR [rsi+0x10]
    3f49:	c5 f1 15 d9          	vunpckhpd xmm3,xmm1,xmm1
    3f4d:	c5 51 15 ed          	vunpckhpd xmm13,xmm5,xmm5
    3f51:	c5 79 28 f5          	vmovapd xmm14,xmm5
    3f55:	c4 c1 79 2f d8       	vcomisd xmm3,xmm8
    3f5a:	c5 79 15 d0          	vunpckhpd xmm10,xmm0,xmm0
    3f5e:	74 80                	je     3ee0 <adapter__run_5+0x20>
    3f60:	c5 fb 12 31          	vmovddup xmm6,QWORD PTR [rcx]
    3f64:	c5 fb 10 66 30       	vmovsd xmm4,QWORD PTR [rsi+0x30]
    3f69:	c5 d9 16 66 20       	vmovhpd xmm4,xmm4,QWORD PTR [rsi+0x20]
    3f6e:	c4 e3 79 05 d9 03    	vpermilpd xmm3,xmm1,0x3
    3f74:	c5 79 59 fb          	vmulpd xmm15,xmm0,xmm3
    3f78:	c5 f9 15 f6          	vunpckhpd xmm6,xmm0,xmm6
    3f7c:	c5 f9 59 c5          	vmulpd xmm0,xmm0,xmm5
    3f80:	c5 e1 59 de          	vmulpd xmm3,xmm3,xmm6
    3f84:	c4 c1 59 59 cc       	vmulpd xmm1,xmm4,xmm12
    3f89:	c5 f9 58 c3          	vaddpd xmm0,xmm0,xmm3
    3f8d:	c4 c1 69 59 dc       	vmulpd xmm3,xmm2,xmm12
    3f92:	c4 c1 71 58 cf       	vaddpd xmm1,xmm1,xmm15
    3f97:	c5 51 59 fe          	vmulpd xmm15,xmm5,xmm6
    3f9b:	c5 f9 5c c3          	vsubpd xmm0,xmm0,xmm3
    3f9f:	c4 c1 71 5c cf       	vsubpd xmm1,xmm1,xmm15
    3fa4:	c5 f9 59 d2          	vmulpd xmm2,xmm0,xmm2
    3fa8:	c5 f1 59 e4          	vmulpd xmm4,xmm1,xmm4
    3fac:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    3fb0:	c4 c1 73 59 ce       	vmulsd xmm1,xmm1,xmm14
    3fb5:	c4 c1 7b 59 c5       	vmulsd xmm0,xmm0,xmm13
    3fba:	c5 e9 5c d4          	vsubpd xmm2,xmm2,xmm4
    3fbe:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    3fc2:	c5 e9 58 d2          	vaddpd xmm2,xmm2,xmm2
    3fc6:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    3fca:	c4 c1 69 58 d4       	vaddpd xmm2,xmm2,xmm12
    3fcf:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    3fd4:	c4 c1 69 58 d3       	vaddpd xmm2,xmm2,xmm11
    3fd9:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    3fdd:	e9 2e ff ff ff       	jmp    3f10 <adapter__run_5+0x50>
    3fe2:	0f 1f 00             	nop    DWORD PTR [rax]
    3fe5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    3fec:	00 00 00 00 
    3ff0:	c3                   	ret
    3ff1:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    3ff8:	00 00 00 
    3ffb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000004000 <adapter__run_6>:
    4000:	89 f8                	mov    eax,edi
    4002:	c5 7b 10 05 56 98 02 	vmovsd xmm8,QWORD PTR [rip+0x29856]        # 2d860 <__gnat_ada_main_program_name+0x18>
    4009:	00 
    400a:	c4 41 31 57 c9       	vxorpd xmm9,xmm9,xmm9
    400f:	48 6b c0 38          	imul   rax,rax,0x38
    4013:	4c 01 c0             	add    rax,r8
    4016:	eb 50                	jmp    4068 <adapter__run_6+0x68>
    4018:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    401f:	00 
    4020:	c4 c1 79 2f d9       	vcomisd xmm3,xmm9
    4025:	75 7f                	jne    40a6 <adapter__run_6+0xa6>
    4027:	c4 41 79 2f e9       	vcomisd xmm13,xmm9
    402c:	75 78                	jne    40a6 <adapter__run_6+0xa6>
    402e:	c5 f9 15 d0          	vunpckhpd xmm2,xmm0,xmm0
    4032:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    4037:	75 6d                	jne    40a6 <adapter__run_6+0xa6>
    4039:	c4 c1 19 58 de       	vaddpd xmm3,xmm12,xmm14
    403e:	c4 c1 23 58 c2       	vaddsd xmm0,xmm11,xmm10
    4043:	66 90                	xchg   ax,ax
    4045:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    404c:	00 00 00 00 
    4050:	c4 c1 79 11 18       	vmovupd XMMWORD PTR [r8],xmm3
    4055:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    405b:	49 83 c0 38          	add    r8,0x38
    405f:	49 39 c0             	cmp    r8,rax
    4062:	0f 84 c8 00 00 00    	je     4130 <adapter__run_6+0x130>
    4068:	c5 f9 28 4e 10       	vmovapd xmm1,XMMWORD PTR [rsi+0x10]
    406d:	c5 f9 28 5e 20       	vmovapd xmm3,XMMWORD PTR [rsi+0x20]
    4072:	c4 c1 79 10 60 08    	vmovupd xmm4,XMMWORD PTR [r8+0x8]
    4078:	c4 41 79 10 30       	vmovupd xmm14,XMMWORD PTR [r8]
    407d:	c5 f9 10 46 28       	vmovupd xmm0,XMMWORD PTR [rsi+0x28]
    4082:	c5 79 28 26          	vmovapd xmm12,XMMWORD PTR [rsi]
    4086:	c5 7b 10 56 10       	vmovsd xmm10,QWORD PTR [rsi+0x10]
    408b:	c5 f1 15 d1          	vunpckhpd xmm2,xmm1,xmm1
    408f:	c5 59 15 dc          	vunpckhpd xmm11,xmm4,xmm4
    4093:	c5 79 28 fb          	vmovapd xmm15,xmm3
    4097:	c4 c1 79 2f d0       	vcomisd xmm2,xmm8
    409c:	c5 61 15 eb          	vunpckhpd xmm13,xmm3,xmm3
    40a0:	0f 84 7a ff ff ff    	je     4020 <adapter__run_6+0x20>
    40a6:	c4 c1 7b 12 38       	vmovddup xmm7,QWORD PTR [r8]
    40ab:	c4 e3 79 05 f1 03    	vpermilpd xmm6,xmm1,0x3
    40b1:	c5 e1 59 d4          	vmulpd xmm2,xmm3,xmm4
    40b5:	c5 fb 10 6e 30       	vmovsd xmm5,QWORD PTR [rsi+0x30]
    40ba:	c5 d1 16 6e 20       	vmovhpd xmm5,xmm5,QWORD PTR [rsi+0x20]
    40bf:	c5 d9 15 ff          	vunpckhpd xmm7,xmm4,xmm7
    40c3:	c5 d9 59 e6          	vmulpd xmm4,xmm4,xmm6
    40c7:	c5 c9 59 cf          	vmulpd xmm1,xmm6,xmm7
    40cb:	c5 e1 59 df          	vmulpd xmm3,xmm3,xmm7
    40cf:	c5 e9 58 d1          	vaddpd xmm2,xmm2,xmm1
    40d3:	c4 c1 79 59 ce       	vmulpd xmm1,xmm0,xmm14
    40d8:	c5 e9 5c d1          	vsubpd xmm2,xmm2,xmm1
    40dc:	c4 c1 51 59 ce       	vmulpd xmm1,xmm5,xmm14
    40e1:	c5 f1 58 cc          	vaddpd xmm1,xmm1,xmm4
    40e5:	c5 e9 59 c0          	vmulpd xmm0,xmm2,xmm0
    40e9:	c5 e9 15 d2          	vunpckhpd xmm2,xmm2,xmm2
    40ed:	c4 c1 6b 59 d5       	vmulsd xmm2,xmm2,xmm13
    40f2:	c5 f1 5c cb          	vsubpd xmm1,xmm1,xmm3
    40f6:	c5 f1 59 ed          	vmulpd xmm5,xmm1,xmm5
    40fa:	c4 c1 73 59 cf       	vmulsd xmm1,xmm1,xmm15
    40ff:	c5 f9 5c c5          	vsubpd xmm0,xmm0,xmm5
    4103:	c5 f9 58 c0          	vaddpd xmm0,xmm0,xmm0
    4107:	c4 c1 79 58 c6       	vaddpd xmm0,xmm0,xmm14
    410c:	c4 c1 79 58 dc       	vaddpd xmm3,xmm0,xmm12
    4111:	c5 f3 5c c2          	vsubsd xmm0,xmm1,xmm2
    4115:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4119:	c4 c1 7b 58 c3       	vaddsd xmm0,xmm0,xmm11
    411e:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    4123:	e9 28 ff ff ff       	jmp    4050 <adapter__run_6+0x50>
    4128:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    412f:	00 
    4130:	c3                   	ret
    4131:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    4138:	00 00 00 
    413b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000004140 <c_run_7.constprop.0>:
    4140:	48 8d 81 c0 01 00 00 	lea    rax,[rcx+0x1c0]
    4147:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    414e:	00 00 
    4150:	c5 fd 10 4f 18       	vmovupd ymm1,YMMWORD PTR [rdi+0x18]
    4155:	c5 fd 10 56 18       	vmovupd ymm2,YMMWORD PTR [rsi+0x18]
    415a:	c4 e2 7d 19 c1       	vbroadcastsd ymm0,xmm1
    415f:	c4 e3 fd 01 ea 4e    	vpermpd ymm5,ymm2,0x4e
    4165:	c4 e3 fd 01 e2 1b    	vpermpd ymm4,ymm2,0x1b
    416b:	c4 e3 fd 01 d9 55    	vpermpd ymm3,ymm1,0x55
    4171:	c5 fd 59 c2          	vmulpd ymm0,ymm0,ymm2
    4175:	c4 e3 7d 05 d2 05    	vpermilpd ymm2,ymm2,0x5
    417b:	c5 e5 59 d2          	vmulpd ymm2,ymm3,ymm2
    417f:	c5 fd d0 c2          	vaddsubpd ymm0,ymm0,ymm2
    4183:	c4 e3 fd 01 d1 aa    	vpermpd ymm2,ymm1,0xaa
    4189:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    418f:	c5 ed 59 d5          	vmulpd ymm2,ymm2,ymm5
    4193:	c5 f5 59 cc          	vmulpd ymm1,ymm1,ymm4
    4197:	c5 fd 5c da          	vsubpd ymm3,ymm0,ymm2
    419b:	c5 fd 58 c2          	vaddpd ymm0,ymm0,ymm2
    419f:	c4 e3 7d 0d c3 09    	vblendpd ymm0,ymm0,ymm3,0x9
    41a5:	c5 fd 5c d1          	vsubpd ymm2,ymm0,ymm1
    41a9:	c5 fd 58 c1          	vaddpd ymm0,ymm0,ymm1
    41ad:	c4 e3 7d 0d c2 03    	vblendpd ymm0,ymm0,ymm2,0x3
    41b3:	c5 fd 11 41 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm0
    41b8:	48 83 c1 38          	add    rcx,0x38
    41bc:	48 39 c1             	cmp    rcx,rax
    41bf:	75 8f                	jne    4150 <c_run_7.constprop.0+0x10>
    41c1:	c5 f8 77             	vzeroupper
    41c4:	c3                   	ret
    41c5:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    41cc:	00 00 00 
    41cf:	90                   	nop

00000000000041d0 <c_run_7>:
    41d0:	89 f8                	mov    eax,edi
    41d2:	48 6b c0 38          	imul   rax,rax,0x38
    41d6:	4c 01 c0             	add    rax,r8
    41d9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    41e0:	c5 fd 10 4e 18       	vmovupd ymm1,YMMWORD PTR [rsi+0x18]
    41e5:	c5 fd 10 52 18       	vmovupd ymm2,YMMWORD PTR [rdx+0x18]
    41ea:	c4 e2 7d 19 c1       	vbroadcastsd ymm0,xmm1
    41ef:	c4 e3 fd 01 ea 4e    	vpermpd ymm5,ymm2,0x4e
    41f5:	c4 e3 fd 01 e2 1b    	vpermpd ymm4,ymm2,0x1b
    41fb:	c4 e3 fd 01 d9 55    	vpermpd ymm3,ymm1,0x55
    4201:	c5 fd 59 c2          	vmulpd ymm0,ymm0,ymm2
    4205:	c4 e3 7d 05 d2 05    	vpermilpd ymm2,ymm2,0x5
    420b:	c5 e5 59 d2          	vmulpd ymm2,ymm3,ymm2
    420f:	c5 fd d0 c2          	vaddsubpd ymm0,ymm0,ymm2
    4213:	c4 e3 fd 01 d1 aa    	vpermpd ymm2,ymm1,0xaa
    4219:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    421f:	c5 ed 59 d5          	vmulpd ymm2,ymm2,ymm5
    4223:	c5 f5 59 cc          	vmulpd ymm1,ymm1,ymm4
    4227:	c5 fd 5c da          	vsubpd ymm3,ymm0,ymm2
    422b:	c5 fd 58 c2          	vaddpd ymm0,ymm0,ymm2
    422f:	c4 e3 7d 0d c3 09    	vblendpd ymm0,ymm0,ymm3,0x9
    4235:	c5 fd 5c d1          	vsubpd ymm2,ymm0,ymm1
    4239:	c5 fd 58 c1          	vaddpd ymm0,ymm0,ymm1
    423d:	c4 e3 7d 0d c2 03    	vblendpd ymm0,ymm0,ymm2,0x3
    4243:	c4 c1 7d 11 40 18    	vmovupd YMMWORD PTR [r8+0x18],ymm0
    4249:	49 83 c0 38          	add    r8,0x38
    424d:	49 39 c0             	cmp    r8,rax
    4250:	75 8e                	jne    41e0 <c_run_7+0x10>
    4252:	c5 f8 77             	vzeroupper
    4255:	c3                   	ret
    4256:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    425d:	00 00 00 

0000000000004260 <c_run_3.constprop.0>:
    4260:	c5 7b 10 0d f8 95 02 	vmovsd xmm9,QWORD PTR [rip+0x295f8]        # 2d860 <__gnat_ada_main_program_name+0x18>
    4267:	00 
    4268:	48 89 f8             	mov    rax,rdi
    426b:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    4270:	48 8d b9 c0 01 00 00 	lea    rdi,[rcx+0x1c0]
    4277:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    427e:	00 00 
    4280:	c5 fb 10 70 28       	vmovsd xmm6,QWORD PTR [rax+0x28]
    4285:	c5 fb 10 68 30       	vmovsd xmm5,QWORD PTR [rax+0x30]
    428a:	c5 fb 10 50 18       	vmovsd xmm2,QWORD PTR [rax+0x18]
    428f:	c5 7b 10 60 20       	vmovsd xmm12,QWORD PTR [rax+0x20]
    4294:	c5 c9 57 25 94 b8 02 	vxorpd xmm4,xmm6,XMMWORD PTR [rip+0x2b894]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    429b:	00 
    429c:	c5 99 57 05 8c b8 02 	vxorpd xmm0,xmm12,XMMWORD PTR [rip+0x2b88c]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    42a3:	00 
    42a4:	c5 d1 57 0d 84 b8 02 	vxorpd xmm1,xmm5,XMMWORD PTR [rip+0x2b884]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    42ab:	00 
    42ac:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    42b1:	c5 d9 14 f9          	vunpcklpd xmm7,xmm4,xmm1
    42b5:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    42b9:	41 0f 94 c1          	sete   r9b
    42bd:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    42c2:	62 f3 e5 28 18 df 01 	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    42c9:	41 0f 94 c0          	sete   r8b
    42cd:	c5 fd 11 59 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm3
    42d2:	c5 7b 10 10          	vmovsd xmm10,QWORD PTR [rax]
    42d6:	c5 fb 10 78 10       	vmovsd xmm7,QWORD PTR [rax+0x10]
    42db:	c5 7b 10 58 08       	vmovsd xmm11,QWORD PTR [rax+0x8]
    42e0:	45 84 c1             	test   r9b,r8b
    42e3:	74 1b                	je     4300 <c_run_3.constprop.0+0xa0>
    42e5:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    42ea:	41 0f 94 c1          	sete   r9b
    42ee:	c4 41 79 2f e0       	vcomisd xmm12,xmm8
    42f3:	41 0f 94 c0          	sete   r8b
    42f7:	45 84 c1             	test   r9b,r8b
    42fa:	0f 85 b8 00 00 00    	jne    43b8 <c_run_3.constprop.0+0x158>
    4300:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    4304:	c4 c1 6b 59 ea       	vmulsd xmm5,xmm2,xmm10
    4309:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    430e:	c5 eb 59 d7          	vmulsd xmm2,xmm2,xmm7
    4312:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    4316:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    431b:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    431f:	c4 c1 73 59 da       	vmulsd xmm3,xmm1,xmm10
    4324:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    4328:	c5 fb 59 df          	vmulsd xmm3,xmm0,xmm7
    432c:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    4330:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    4335:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    4339:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    433e:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    4342:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    4346:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    434a:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    434e:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    4352:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    4356:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    435a:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    435f:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    4363:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    4367:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    436b:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    436f:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4373:	c4 c1 63 58 da       	vaddsd xmm3,xmm3,xmm10
    4378:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    437d:	c5 e1 57 1d ab b7 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2b7ab]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4384:	00 
    4385:	c5 f1 57 0d a3 b7 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2b7a3]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    438c:	00 
    438d:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4391:	c5 f9 57 05 97 b7 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2b797]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4398:	00 
    4399:	c5 fb 11 19          	vmovsd QWORD PTR [rcx],xmm3
    439d:	c5 fb 11 49 08       	vmovsd QWORD PTR [rcx+0x8],xmm1
    43a2:	c5 fb 11 41 10       	vmovsd QWORD PTR [rcx+0x10],xmm0
    43a7:	48 83 c1 38          	add    rcx,0x38
    43ab:	48 39 f9             	cmp    rcx,rdi
    43ae:	0f 85 cc fe ff ff    	jne    4280 <c_run_3.constprop.0+0x20>
    43b4:	c5 f8 77             	vzeroupper
    43b7:	c3                   	ret
    43b8:	c5 29 57 15 70 b7 02 	vxorpd xmm10,xmm10,XMMWORD PTR [rip+0x2b770]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    43bf:	00 
    43c0:	c5 21 57 1d 68 b7 02 	vxorpd xmm11,xmm11,XMMWORD PTR [rip+0x2b768]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    43c7:	00 
    43c8:	c5 c1 57 3d 60 b7 02 	vxorpd xmm7,xmm7,XMMWORD PTR [rip+0x2b760]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    43cf:	00 
    43d0:	c5 7b 11 11          	vmovsd QWORD PTR [rcx],xmm10
    43d4:	c5 7b 11 59 08       	vmovsd QWORD PTR [rcx+0x8],xmm11
    43d9:	c5 fb 11 79 10       	vmovsd QWORD PTR [rcx+0x10],xmm7
    43de:	48 83 c1 38          	add    rcx,0x38
    43e2:	48 39 f9             	cmp    rcx,rdi
    43e5:	0f 85 95 fe ff ff    	jne    4280 <c_run_3.constprop.0+0x20>
    43eb:	eb c7                	jmp    43b4 <c_run_3.constprop.0+0x154>
    43ed:	0f 1f 00             	nop    DWORD PTR [rax]

00000000000043f0 <c_run_3>:
    43f0:	c5 7b 10 0d 68 94 02 	vmovsd xmm9,QWORD PTR [rip+0x29468]        # 2d860 <__gnat_ada_main_program_name+0x18>
    43f7:	00 
    43f8:	48 89 f0             	mov    rax,rsi
    43fb:	89 fe                	mov    esi,edi
    43fd:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    4402:	48 6b f6 38          	imul   rsi,rsi,0x38
    4406:	4c 01 c6             	add    rsi,r8
    4409:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    4410:	c5 fb 10 70 28       	vmovsd xmm6,QWORD PTR [rax+0x28]
    4415:	c5 fb 10 68 30       	vmovsd xmm5,QWORD PTR [rax+0x30]
    441a:	c5 fb 10 50 18       	vmovsd xmm2,QWORD PTR [rax+0x18]
    441f:	c5 7b 10 60 20       	vmovsd xmm12,QWORD PTR [rax+0x20]
    4424:	c5 c9 57 25 04 b7 02 	vxorpd xmm4,xmm6,XMMWORD PTR [rip+0x2b704]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    442b:	00 
    442c:	c5 99 57 05 fc b6 02 	vxorpd xmm0,xmm12,XMMWORD PTR [rip+0x2b6fc]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4433:	00 
    4434:	c5 d1 57 0d f4 b6 02 	vxorpd xmm1,xmm5,XMMWORD PTR [rip+0x2b6f4]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    443b:	00 
    443c:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    4441:	c5 d9 14 f9          	vunpcklpd xmm7,xmm4,xmm1
    4445:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    4449:	41 0f 94 c1          	sete   r9b
    444d:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    4452:	62 f3 e5 28 18 df 01 	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    4459:	40 0f 94 c7          	sete   dil
    445d:	c4 c1 7d 11 58 18    	vmovupd YMMWORD PTR [r8+0x18],ymm3
    4463:	c5 7b 10 10          	vmovsd xmm10,QWORD PTR [rax]
    4467:	c5 fb 10 78 10       	vmovsd xmm7,QWORD PTR [rax+0x10]
    446c:	c5 7b 10 58 08       	vmovsd xmm11,QWORD PTR [rax+0x8]
    4471:	41 84 f9             	test   r9b,dil
    4474:	74 1b                	je     4491 <c_run_3+0xa1>
    4476:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    447b:	41 0f 94 c1          	sete   r9b
    447f:	c4 41 79 2f e0       	vcomisd xmm12,xmm8
    4484:	40 0f 94 c7          	sete   dil
    4488:	41 84 f9             	test   r9b,dil
    448b:	0f 85 bf 00 00 00    	jne    4550 <c_run_3+0x160>
    4491:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    4495:	c4 c1 6b 59 ea       	vmulsd xmm5,xmm2,xmm10
    449a:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    449f:	c5 eb 59 d7          	vmulsd xmm2,xmm2,xmm7
    44a3:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    44a7:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    44ac:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    44b0:	c4 c1 73 59 da       	vmulsd xmm3,xmm1,xmm10
    44b5:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    44b9:	c5 fb 59 df          	vmulsd xmm3,xmm0,xmm7
    44bd:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    44c1:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    44c6:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    44ca:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    44cf:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    44d3:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    44d7:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    44db:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    44df:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    44e3:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    44e7:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    44eb:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    44f0:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    44f4:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    44f8:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    44fc:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    4500:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4504:	c4 c1 63 58 da       	vaddsd xmm3,xmm3,xmm10
    4509:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    450e:	c5 e1 57 1d 1a b6 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2b61a]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4515:	00 
    4516:	c5 f1 57 0d 12 b6 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2b612]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    451d:	00 
    451e:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4522:	c5 f9 57 05 06 b6 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2b606]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4529:	00 
    452a:	c4 c1 7b 11 18       	vmovsd QWORD PTR [r8],xmm3
    452f:	c4 c1 7b 11 48 08    	vmovsd QWORD PTR [r8+0x8],xmm1
    4535:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    453b:	49 83 c0 38          	add    r8,0x38
    453f:	49 39 f0             	cmp    r8,rsi
    4542:	0f 85 c8 fe ff ff    	jne    4410 <c_run_3+0x20>
    4548:	c5 f8 77             	vzeroupper
    454b:	c3                   	ret
    454c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    4550:	c5 29 57 15 d8 b5 02 	vxorpd xmm10,xmm10,XMMWORD PTR [rip+0x2b5d8]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4557:	00 
    4558:	c5 21 57 1d d0 b5 02 	vxorpd xmm11,xmm11,XMMWORD PTR [rip+0x2b5d0]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    455f:	00 
    4560:	c5 c1 57 3d c8 b5 02 	vxorpd xmm7,xmm7,XMMWORD PTR [rip+0x2b5c8]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4567:	00 
    4568:	c4 41 7b 11 10       	vmovsd QWORD PTR [r8],xmm10
    456d:	c4 41 7b 11 58 08    	vmovsd QWORD PTR [r8+0x8],xmm11
    4573:	c4 c1 7b 11 78 10    	vmovsd QWORD PTR [r8+0x10],xmm7
    4579:	49 83 c0 38          	add    r8,0x38
    457d:	49 39 f0             	cmp    r8,rsi
    4580:	0f 85 8a fe ff ff    	jne    4410 <c_run_3+0x20>
    4586:	eb c0                	jmp    4548 <c_run_3+0x158>
    4588:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    458f:	00 

0000000000004590 <c_run_5.constprop.0>:
    4590:	c5 7b 10 1d c8 92 02 	vmovsd xmm11,QWORD PTR [rip+0x292c8]        # 2d860 <__gnat_ada_main_program_name+0x18>
    4597:	00 
    4598:	48 8d 81 c0 01 00 00 	lea    rax,[rcx+0x1c0]
    459f:	c4 41 19 57 e4       	vxorpd xmm12,xmm12,xmm12
    45a4:	eb 59                	jmp    45ff <c_run_5.constprop.0+0x6f>
    45a6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    45ad:	00 00 00 
    45b0:	c4 c1 79 2f f4       	vcomisd xmm6,xmm12
    45b5:	75 73                	jne    462a <c_run_5.constprop.0+0x9a>
    45b7:	c4 41 79 2f d4       	vcomisd xmm10,xmm12
    45bc:	75 6c                	jne    462a <c_run_5.constprop.0+0x9a>
    45be:	c5 e9 15 e2          	vunpckhpd xmm4,xmm2,xmm2
    45c2:	c4 c1 79 2f e4       	vcomisd xmm4,xmm12
    45c7:	75 61                	jne    462a <c_run_5.constprop.0+0x9a>
    45c9:	c5 f9 11 19          	vmovupd XMMWORD PTR [rcx],xmm3
    45cd:	c5 fb 11 69 10       	vmovsd QWORD PTR [rcx+0x10],xmm5
    45d2:	0f 1f 00             	nop    DWORD PTR [rax]
    45d5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    45dc:	00 00 00 00 
    45e0:	c5 e1 58 1f          	vaddpd xmm3,xmm3,XMMWORD PTR [rdi]
    45e4:	c5 d3 58 6f 10       	vaddsd xmm5,xmm5,QWORD PTR [rdi+0x10]
    45e9:	c5 f9 11 19          	vmovupd XMMWORD PTR [rcx],xmm3
    45ed:	c5 fb 11 69 10       	vmovsd QWORD PTR [rcx+0x10],xmm5
    45f2:	48 83 c1 38          	add    rcx,0x38
    45f6:	48 39 c8             	cmp    rax,rcx
    45f9:	0f 84 b1 00 00 00    	je     46b0 <c_run_5.constprop.0+0x120>
    45ff:	c5 f9 10 4f 18       	vmovupd xmm1,XMMWORD PTR [rdi+0x18]
    4604:	c5 f9 28 77 20       	vmovapd xmm6,XMMWORD PTR [rdi+0x20]
    4609:	c5 f9 10 42 08       	vmovupd xmm0,XMMWORD PTR [rdx+0x8]
    460e:	c5 f9 10 57 28       	vmovupd xmm2,XMMWORD PTR [rdi+0x28]
    4613:	c5 f9 28 1a          	vmovapd xmm3,XMMWORD PTR [rdx]
    4617:	c4 c1 79 2f cb       	vcomisd xmm1,xmm11
    461c:	c5 49 15 d6          	vunpckhpd xmm10,xmm6,xmm6
    4620:	c5 79 28 ce          	vmovapd xmm9,xmm6
    4624:	c5 f9 15 e8          	vunpckhpd xmm5,xmm0,xmm0
    4628:	74 86                	je     45b0 <c_run_5.constprop.0+0x20>
    462a:	c4 63 79 05 c1 00    	vpermilpd xmm8,xmm1,0x0
    4630:	c5 e9 15 e1          	vunpckhpd xmm4,xmm2,xmm1
    4634:	c5 f9 c6 fb 01       	vshufpd xmm7,xmm0,xmm3,0x1
    4639:	c5 d9 59 cb          	vmulpd xmm1,xmm4,xmm3
    463d:	c4 41 79 59 e8       	vmulpd xmm13,xmm0,xmm8
    4642:	c5 f9 59 c6          	vmulpd xmm0,xmm0,xmm6
    4646:	c4 c1 71 58 cd       	vaddpd xmm1,xmm1,xmm13
    464b:	c5 41 59 ee          	vmulpd xmm13,xmm7,xmm6
    464f:	c4 c1 41 59 f8       	vmulpd xmm7,xmm7,xmm8
    4654:	c5 e9 59 f3          	vmulpd xmm6,xmm2,xmm3
    4658:	c5 f9 58 c7          	vaddpd xmm0,xmm0,xmm7
    465c:	c4 c1 71 5c cd       	vsubpd xmm1,xmm1,xmm13
    4661:	c5 f9 5c c6          	vsubpd xmm0,xmm0,xmm6
    4665:	c5 f1 59 e4          	vmulpd xmm4,xmm1,xmm4
    4669:	c4 c1 73 59 c9       	vmulsd xmm1,xmm1,xmm9
    466e:	c5 e9 59 d0          	vmulpd xmm2,xmm2,xmm0
    4672:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    4676:	c4 c1 7b 59 c2       	vmulsd xmm0,xmm0,xmm10
    467b:	c5 e9 5c d4          	vsubpd xmm2,xmm2,xmm4
    467f:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    4683:	c5 e9 58 d2          	vaddpd xmm2,xmm2,xmm2
    4687:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    468b:	c5 e1 58 da          	vaddpd xmm3,xmm3,xmm2
    468f:	c5 d3 58 e8          	vaddsd xmm5,xmm5,xmm0
    4693:	c5 f9 11 19          	vmovupd XMMWORD PTR [rcx],xmm3
    4697:	c5 fb 11 69 10       	vmovsd QWORD PTR [rcx+0x10],xmm5
    469c:	e9 3f ff ff ff       	jmp    45e0 <c_run_5.constprop.0+0x50>
    46a1:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    46a5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    46ac:	00 00 00 00 
    46b0:	c3                   	ret
    46b1:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    46b8:	00 00 00 
    46bb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

00000000000046c0 <c_run_5>:
    46c0:	48 89 f0             	mov    rax,rsi
    46c3:	89 fe                	mov    esi,edi
    46c5:	c5 7b 10 1d 93 91 02 	vmovsd xmm11,QWORD PTR [rip+0x29193]        # 2d860 <__gnat_ada_main_program_name+0x18>
    46cc:	00 
    46cd:	c4 41 19 57 e4       	vxorpd xmm12,xmm12,xmm12
    46d2:	48 6b f6 38          	imul   rsi,rsi,0x38
    46d6:	4c 01 c6             	add    rsi,r8
    46d9:	eb 56                	jmp    4731 <c_run_5+0x71>
    46db:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    46e0:	c4 c1 79 2f f4       	vcomisd xmm6,xmm12
    46e5:	75 75                	jne    475c <c_run_5+0x9c>
    46e7:	c4 41 79 2f d4       	vcomisd xmm10,xmm12
    46ec:	75 6e                	jne    475c <c_run_5+0x9c>
    46ee:	c5 e9 15 e2          	vunpckhpd xmm4,xmm2,xmm2
    46f2:	c4 c1 79 2f e4       	vcomisd xmm4,xmm12
    46f7:	75 63                	jne    475c <c_run_5+0x9c>
    46f9:	c4 c1 79 11 18       	vmovupd XMMWORD PTR [r8],xmm3
    46fe:	c4 c1 7b 11 68 10    	vmovsd QWORD PTR [r8+0x10],xmm5
    4704:	90                   	nop
    4705:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    470c:	00 00 00 00 
    4710:	c5 e1 58 18          	vaddpd xmm3,xmm3,XMMWORD PTR [rax]
    4714:	c5 d3 58 68 10       	vaddsd xmm5,xmm5,QWORD PTR [rax+0x10]
    4719:	c4 c1 79 11 18       	vmovupd XMMWORD PTR [r8],xmm3
    471e:	c4 c1 7b 11 68 10    	vmovsd QWORD PTR [r8+0x10],xmm5
    4724:	49 83 c0 38          	add    r8,0x38
    4728:	4c 39 c6             	cmp    rsi,r8
    472b:	0f 84 af 00 00 00    	je     47e0 <c_run_5+0x120>
    4731:	c5 f9 10 48 18       	vmovupd xmm1,XMMWORD PTR [rax+0x18]
    4736:	c5 f9 28 70 20       	vmovapd xmm6,XMMWORD PTR [rax+0x20]
    473b:	c5 f9 10 41 08       	vmovupd xmm0,XMMWORD PTR [rcx+0x8]
    4740:	c5 f9 10 50 28       	vmovupd xmm2,XMMWORD PTR [rax+0x28]
    4745:	c5 f9 28 19          	vmovapd xmm3,XMMWORD PTR [rcx]
    4749:	c4 c1 79 2f cb       	vcomisd xmm1,xmm11
    474e:	c5 49 15 d6          	vunpckhpd xmm10,xmm6,xmm6
    4752:	c5 79 28 ce          	vmovapd xmm9,xmm6
    4756:	c5 f9 15 e8          	vunpckhpd xmm5,xmm0,xmm0
    475a:	74 84                	je     46e0 <c_run_5+0x20>
    475c:	c4 63 79 05 c1 00    	vpermilpd xmm8,xmm1,0x0
    4762:	c5 e9 15 e1          	vunpckhpd xmm4,xmm2,xmm1
    4766:	c5 f9 c6 fb 01       	vshufpd xmm7,xmm0,xmm3,0x1
    476b:	c5 d9 59 cb          	vmulpd xmm1,xmm4,xmm3
    476f:	c4 41 79 59 e8       	vmulpd xmm13,xmm0,xmm8
    4774:	c5 f9 59 c6          	vmulpd xmm0,xmm0,xmm6
    4778:	c4 c1 71 58 cd       	vaddpd xmm1,xmm1,xmm13
    477d:	c5 41 59 ee          	vmulpd xmm13,xmm7,xmm6
    4781:	c4 c1 41 59 f8       	vmulpd xmm7,xmm7,xmm8
    4786:	c5 e9 59 f3          	vmulpd xmm6,xmm2,xmm3
    478a:	c5 f9 58 c7          	vaddpd xmm0,xmm0,xmm7
    478e:	c4 c1 71 5c cd       	vsubpd xmm1,xmm1,xmm13
    4793:	c5 f9 5c c6          	vsubpd xmm0,xmm0,xmm6
    4797:	c5 f1 59 e4          	vmulpd xmm4,xmm1,xmm4
    479b:	c4 c1 73 59 c9       	vmulsd xmm1,xmm1,xmm9
    47a0:	c5 e9 59 d0          	vmulpd xmm2,xmm2,xmm0
    47a4:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    47a8:	c4 c1 7b 59 c2       	vmulsd xmm0,xmm0,xmm10
    47ad:	c5 e9 5c d4          	vsubpd xmm2,xmm2,xmm4
    47b1:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    47b5:	c5 e9 58 d2          	vaddpd xmm2,xmm2,xmm2
    47b9:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    47bd:	c5 e1 58 da          	vaddpd xmm3,xmm3,xmm2
    47c1:	c5 d3 58 e8          	vaddsd xmm5,xmm5,xmm0
    47c5:	c4 c1 79 11 18       	vmovupd XMMWORD PTR [r8],xmm3
    47ca:	c4 c1 7b 11 68 10    	vmovsd QWORD PTR [r8+0x10],xmm5
    47d0:	e9 3b ff ff ff       	jmp    4710 <c_run_5+0x50>
    47d5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    47dc:	00 00 00 00 
    47e0:	c3                   	ret
    47e1:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    47e8:	00 00 00 
    47eb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

00000000000047f0 <c_run_6.constprop.0>:
    47f0:	c5 7b 10 15 68 90 02 	vmovsd xmm10,QWORD PTR [rip+0x29068]        # 2d860 <__gnat_ada_main_program_name+0x18>
    47f7:	00 
    47f8:	48 89 f8             	mov    rax,rdi
    47fb:	c4 41 21 57 db       	vxorpd xmm11,xmm11,xmm11
    4800:	48 8d b9 c0 01 00 00 	lea    rdi,[rcx+0x1c0]
    4807:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    480e:	00 00 
    4810:	c5 fb 10 40 18       	vmovsd xmm0,QWORD PTR [rax+0x18]
    4815:	c5 fb 10 29          	vmovsd xmm5,QWORD PTR [rcx]
    4819:	c5 fb 10 61 08       	vmovsd xmm4,QWORD PTR [rcx+0x8]
    481e:	c5 fb 10 59 10       	vmovsd xmm3,QWORD PTR [rcx+0x10]
    4823:	c5 7b 10 40 20       	vmovsd xmm8,QWORD PTR [rax+0x20]
    4828:	c5 7b 10 48 28       	vmovsd xmm9,QWORD PTR [rax+0x28]
    482d:	c5 fb 10 50 30       	vmovsd xmm2,QWORD PTR [rax+0x30]
    4832:	c4 c1 79 2f c2       	vcomisd xmm0,xmm10
    4837:	75 27                	jne    4860 <c_run_6.constprop.0+0x70>
    4839:	c4 41 79 2f c3       	vcomisd xmm8,xmm11
    483e:	75 20                	jne    4860 <c_run_6.constprop.0+0x70>
    4840:	c4 41 79 2f cb       	vcomisd xmm9,xmm11
    4845:	75 19                	jne    4860 <c_run_6.constprop.0+0x70>
    4847:	c4 c1 79 2f d3       	vcomisd xmm2,xmm11
    484c:	0f 84 9d 00 00 00    	je     48ef <c_run_6.constprop.0+0xff>
    4852:	0f 1f 00             	nop    DWORD PTR [rax]
    4855:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    485c:	00 00 00 00 
    4860:	c5 d3 59 f0          	vmulsd xmm6,xmm5,xmm0
    4864:	c4 c1 63 59 c9       	vmulsd xmm1,xmm3,xmm9
    4869:	c5 d3 59 fa          	vmulsd xmm7,xmm5,xmm2
    486d:	c5 cb 58 f1          	vaddsd xmm6,xmm6,xmm1
    4871:	c5 db 59 ca          	vmulsd xmm1,xmm4,xmm2
    4875:	c5 cb 5c f1          	vsubsd xmm6,xmm6,xmm1
    4879:	c5 db 59 c8          	vmulsd xmm1,xmm4,xmm0
    487d:	c5 e3 59 c0          	vmulsd xmm0,xmm3,xmm0
    4881:	c5 f3 58 cf          	vaddsd xmm1,xmm1,xmm7
    4885:	c4 c1 63 59 f8       	vmulsd xmm7,xmm3,xmm8
    488a:	c5 f3 5c cf          	vsubsd xmm1,xmm1,xmm7
    488e:	c4 c1 5b 59 f8       	vmulsd xmm7,xmm4,xmm8
    4893:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4897:	c4 c1 53 59 f9       	vmulsd xmm7,xmm5,xmm9
    489c:	c5 73 59 e2          	vmulsd xmm12,xmm1,xmm2
    48a0:	c5 cb 59 d2          	vmulsd xmm2,xmm6,xmm2
    48a4:	c4 c1 4b 59 f1       	vmulsd xmm6,xmm6,xmm9
    48a9:	c5 fb 5c c7          	vsubsd xmm0,xmm0,xmm7
    48ad:	c4 c1 7b 59 f9       	vmulsd xmm7,xmm0,xmm9
    48b2:	c4 c1 7b 59 c0       	vmulsd xmm0,xmm0,xmm8
    48b7:	c5 eb 5c d0          	vsubsd xmm2,xmm2,xmm0
    48bb:	c4 c1 73 59 c0       	vmulsd xmm0,xmm1,xmm8
    48c0:	c4 c1 43 5c fc       	vsubsd xmm7,xmm7,xmm12
    48c5:	c5 fb 5c c6          	vsubsd xmm0,xmm0,xmm6
    48c9:	c5 c3 58 ff          	vaddsd xmm7,xmm7,xmm7
    48cd:	c5 eb 58 d2          	vaddsd xmm2,xmm2,xmm2
    48d1:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    48d5:	c5 d3 58 ef          	vaddsd xmm5,xmm5,xmm7
    48d9:	c5 db 58 e2          	vaddsd xmm4,xmm4,xmm2
    48dd:	c5 e3 58 d8          	vaddsd xmm3,xmm3,xmm0
    48e1:	c5 fb 11 29          	vmovsd QWORD PTR [rcx],xmm5
    48e5:	c5 fb 11 61 08       	vmovsd QWORD PTR [rcx+0x8],xmm4
    48ea:	c5 fb 11 59 10       	vmovsd QWORD PTR [rcx+0x10],xmm3
    48ef:	c5 d3 58 28          	vaddsd xmm5,xmm5,QWORD PTR [rax]
    48f3:	c5 db 58 60 08       	vaddsd xmm4,xmm4,QWORD PTR [rax+0x8]
    48f8:	c5 e3 58 58 10       	vaddsd xmm3,xmm3,QWORD PTR [rax+0x10]
    48fd:	c5 fb 11 29          	vmovsd QWORD PTR [rcx],xmm5
    4901:	c5 fb 11 61 08       	vmovsd QWORD PTR [rcx+0x8],xmm4
    4906:	c5 fb 11 59 10       	vmovsd QWORD PTR [rcx+0x10],xmm3
    490b:	48 83 c1 38          	add    rcx,0x38
    490f:	48 39 cf             	cmp    rdi,rcx
    4912:	0f 85 f8 fe ff ff    	jne    4810 <c_run_6.constprop.0+0x20>
    4918:	c3                   	ret
    4919:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000004920 <c_run_6>:
    4920:	c5 7b 10 15 38 8f 02 	vmovsd xmm10,QWORD PTR [rip+0x28f38]        # 2d860 <__gnat_ada_main_program_name+0x18>
    4927:	00 
    4928:	48 89 f0             	mov    rax,rsi
    492b:	48 89 d6             	mov    rsi,rdx
    492e:	48 89 ca             	mov    rdx,rcx
    4931:	89 f9                	mov    ecx,edi
    4933:	c4 41 21 57 db       	vxorpd xmm11,xmm11,xmm11
    4938:	48 6b c9 38          	imul   rcx,rcx,0x38
    493c:	4c 01 c1             	add    rcx,r8
    493f:	90                   	nop
    4940:	c5 fb 10 40 18       	vmovsd xmm0,QWORD PTR [rax+0x18]
    4945:	c4 c1 7b 10 28       	vmovsd xmm5,QWORD PTR [r8]
    494a:	c4 c1 7b 10 60 08    	vmovsd xmm4,QWORD PTR [r8+0x8]
    4950:	c4 c1 7b 10 58 10    	vmovsd xmm3,QWORD PTR [r8+0x10]
    4956:	c5 7b 10 40 20       	vmovsd xmm8,QWORD PTR [rax+0x20]
    495b:	c5 7b 10 48 28       	vmovsd xmm9,QWORD PTR [rax+0x28]
    4960:	c5 fb 10 50 30       	vmovsd xmm2,QWORD PTR [rax+0x30]
    4965:	c4 c1 79 2f c2       	vcomisd xmm0,xmm10
    496a:	75 24                	jne    4990 <c_run_6+0x70>
    496c:	c4 41 79 2f c3       	vcomisd xmm8,xmm11
    4971:	75 1d                	jne    4990 <c_run_6+0x70>
    4973:	c4 41 79 2f cb       	vcomisd xmm9,xmm11
    4978:	75 16                	jne    4990 <c_run_6+0x70>
    497a:	c4 c1 79 2f d3       	vcomisd xmm2,xmm11
    497f:	0f 84 9d 00 00 00    	je     4a22 <c_run_6+0x102>
    4985:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    498c:	00 00 00 00 
    4990:	c5 d3 59 f0          	vmulsd xmm6,xmm5,xmm0
    4994:	c4 c1 63 59 c9       	vmulsd xmm1,xmm3,xmm9
    4999:	c5 d3 59 fa          	vmulsd xmm7,xmm5,xmm2
    499d:	c5 cb 58 f1          	vaddsd xmm6,xmm6,xmm1
    49a1:	c5 db 59 ca          	vmulsd xmm1,xmm4,xmm2
    49a5:	c5 cb 5c f1          	vsubsd xmm6,xmm6,xmm1
    49a9:	c5 db 59 c8          	vmulsd xmm1,xmm4,xmm0
    49ad:	c5 e3 59 c0          	vmulsd xmm0,xmm3,xmm0
    49b1:	c5 f3 58 cf          	vaddsd xmm1,xmm1,xmm7
    49b5:	c4 c1 63 59 f8       	vmulsd xmm7,xmm3,xmm8
    49ba:	c5 f3 5c cf          	vsubsd xmm1,xmm1,xmm7
    49be:	c4 c1 5b 59 f8       	vmulsd xmm7,xmm4,xmm8
    49c3:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    49c7:	c4 c1 53 59 f9       	vmulsd xmm7,xmm5,xmm9
    49cc:	c5 73 59 e2          	vmulsd xmm12,xmm1,xmm2
    49d0:	c5 cb 59 d2          	vmulsd xmm2,xmm6,xmm2
    49d4:	c4 c1 4b 59 f1       	vmulsd xmm6,xmm6,xmm9
    49d9:	c5 fb 5c c7          	vsubsd xmm0,xmm0,xmm7
    49dd:	c4 c1 7b 59 f9       	vmulsd xmm7,xmm0,xmm9
    49e2:	c4 c1 7b 59 c0       	vmulsd xmm0,xmm0,xmm8
    49e7:	c5 eb 5c d0          	vsubsd xmm2,xmm2,xmm0
    49eb:	c4 c1 73 59 c0       	vmulsd xmm0,xmm1,xmm8
    49f0:	c4 c1 43 5c fc       	vsubsd xmm7,xmm7,xmm12
    49f5:	c5 fb 5c c6          	vsubsd xmm0,xmm0,xmm6
    49f9:	c5 c3 58 ff          	vaddsd xmm7,xmm7,xmm7
    49fd:	c5 eb 58 d2          	vaddsd xmm2,xmm2,xmm2
    4a01:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4a05:	c5 d3 58 ef          	vaddsd xmm5,xmm5,xmm7
    4a09:	c5 db 58 e2          	vaddsd xmm4,xmm4,xmm2
    4a0d:	c5 e3 58 d8          	vaddsd xmm3,xmm3,xmm0
    4a11:	c4 c1 7b 11 28       	vmovsd QWORD PTR [r8],xmm5
    4a16:	c4 c1 7b 11 60 08    	vmovsd QWORD PTR [r8+0x8],xmm4
    4a1c:	c4 c1 7b 11 58 10    	vmovsd QWORD PTR [r8+0x10],xmm3
    4a22:	c5 d3 58 28          	vaddsd xmm5,xmm5,QWORD PTR [rax]
    4a26:	c5 db 58 60 08       	vaddsd xmm4,xmm4,QWORD PTR [rax+0x8]
    4a2b:	c5 e3 58 58 10       	vaddsd xmm3,xmm3,QWORD PTR [rax+0x10]
    4a30:	c4 c1 7b 11 28       	vmovsd QWORD PTR [r8],xmm5
    4a35:	c4 c1 7b 11 60 08    	vmovsd QWORD PTR [r8+0x8],xmm4
    4a3b:	c4 c1 7b 11 58 10    	vmovsd QWORD PTR [r8+0x10],xmm3
    4a41:	49 83 c0 38          	add    r8,0x38
    4a45:	4c 39 c1             	cmp    rcx,r8
    4a48:	0f 85 f2 fe ff ff    	jne    4940 <c_run_6+0x20>
    4a4e:	c3                   	ret
    4a4f:	90                   	nop

0000000000004a50 <adapter__run_3>:
    4a50:	c5 7b 10 0d 08 8e 02 	vmovsd xmm9,QWORD PTR [rip+0x28e08]        # 2d860 <__gnat_ada_main_program_name+0x18>
    4a57:	00 
    4a58:	48 89 f0             	mov    rax,rsi
    4a5b:	89 fe                	mov    esi,edi
    4a5d:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    4a62:	48 6b f6 38          	imul   rsi,rsi,0x38
    4a66:	4c 01 c6             	add    rsi,r8
    4a69:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    4a70:	c5 fb 10 50 18       	vmovsd xmm2,QWORD PTR [rax+0x18]
    4a75:	c5 fb 10 68 20       	vmovsd xmm5,QWORD PTR [rax+0x20]
    4a7a:	c5 7b 10 50 28       	vmovsd xmm10,QWORD PTR [rax+0x28]
    4a7f:	c5 fb 10 70 30       	vmovsd xmm6,QWORD PTR [rax+0x30]
    4a84:	c5 d1 57 05 a4 b0 02 	vxorpd xmm0,xmm5,XMMWORD PTR [rip+0x2b0a4]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4a8b:	00 
    4a8c:	c5 a9 57 25 9c b0 02 	vxorpd xmm4,xmm10,XMMWORD PTR [rip+0x2b09c]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4a93:	00 
    4a94:	c5 c9 57 0d 94 b0 02 	vxorpd xmm1,xmm6,XMMWORD PTR [rip+0x2b094]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4a9b:	00 
    4a9c:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    4aa0:	c5 d9 14 f9          	vunpcklpd xmm7,xmm4,xmm1
    4aa4:	62 f3 e5 28 18 df 01 	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    4aab:	c4 c1 7d 11 58 18    	vmovupd YMMWORD PTR [r8+0x18],ymm3
    4ab1:	c5 fb 10 38          	vmovsd xmm7,QWORD PTR [rax]
    4ab5:	c5 7b 10 58 08       	vmovsd xmm11,QWORD PTR [rax+0x8]
    4aba:	c4 c1 79 2f f8       	vcomisd xmm7,xmm8
    4abf:	75 1f                	jne    4ae0 <adapter__run_3+0x90>
    4ac1:	c4 41 79 2f d8       	vcomisd xmm11,xmm8
    4ac6:	75 18                	jne    4ae0 <adapter__run_3+0x90>
    4ac8:	c5 79 2f 40 10       	vcomisd xmm8,QWORD PTR [rax+0x10]
    4acd:	0f 84 0d 01 00 00    	je     4be0 <adapter__run_3+0x190>
    4ad3:	66 90                	xchg   ax,ax
    4ad5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4adc:	00 00 00 00 
    4ae0:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    4ae5:	41 0f 94 c1          	sete   r9b
    4ae9:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    4aee:	40 0f 94 c7          	sete   dil
    4af2:	41 84 f9             	test   r9b,dil
    4af5:	74 1b                	je     4b12 <adapter__run_3+0xc2>
    4af7:	c4 41 79 2f d0       	vcomisd xmm10,xmm8
    4afc:	41 0f 94 c1          	sete   r9b
    4b00:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    4b05:	40 0f 94 c7          	sete   dil
    4b09:	41 84 f9             	test   r9b,dil
    4b0c:	0f 85 ee 00 00 00    	jne    4c00 <adapter__run_3+0x1b0>
    4b12:	c5 7b 10 50 10       	vmovsd xmm10,QWORD PTR [rax+0x10]
    4b17:	c5 eb 59 ef          	vmulsd xmm5,xmm2,xmm7
    4b1b:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    4b20:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    4b25:	c4 c1 6b 59 d2       	vmulsd xmm2,xmm2,xmm10
    4b2a:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    4b2e:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    4b33:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    4b37:	c5 f3 59 df          	vmulsd xmm3,xmm1,xmm7
    4b3b:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    4b3f:	c4 c1 7b 59 da       	vmulsd xmm3,xmm0,xmm10
    4b44:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    4b48:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    4b4d:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    4b51:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    4b55:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    4b59:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    4b5d:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    4b61:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    4b65:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    4b69:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    4b6d:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    4b71:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    4b76:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    4b7a:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    4b7e:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    4b82:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    4b86:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4b8a:	c5 e3 58 df          	vaddsd xmm3,xmm3,xmm7
    4b8e:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    4b93:	c5 e1 57 1d 95 af 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2af95]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4b9a:	00 
    4b9b:	c5 f1 57 0d 8d af 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2af8d]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4ba2:	00 
    4ba3:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    4ba8:	c5 f9 57 05 80 af 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2af80]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4baf:	00 
    4bb0:	c4 c1 7b 11 18       	vmovsd QWORD PTR [r8],xmm3
    4bb5:	c4 c1 7b 11 48 08    	vmovsd QWORD PTR [r8+0x8],xmm1
    4bbb:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    4bc1:	49 83 c0 38          	add    r8,0x38
    4bc5:	49 39 f0             	cmp    r8,rsi
    4bc8:	0f 85 a2 fe ff ff    	jne    4a70 <adapter__run_3+0x20>
    4bce:	c5 f8 77             	vzeroupper
    4bd1:	c3                   	ret
    4bd2:	0f 1f 00             	nop    DWORD PTR [rax]
    4bd5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4bdc:	00 00 00 00 
    4be0:	c5 fb 10 05 48 af 02 	vmovsd xmm0,QWORD PTR [rip+0x2af48]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4be7:	00 
    4be8:	c5 f9 28 c8          	vmovapd xmm1,xmm0
    4bec:	c5 f9 28 d8          	vmovapd xmm3,xmm0
    4bf0:	eb be                	jmp    4bb0 <adapter__run_3+0x160>
    4bf2:	0f 1f 00             	nop    DWORD PTR [rax]
    4bf5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4bfc:	00 00 00 00 
    4c00:	c5 fb 10 40 10       	vmovsd xmm0,QWORD PTR [rax+0x10]
    4c05:	c5 c1 57 1d 23 af 02 	vxorpd xmm3,xmm7,XMMWORD PTR [rip+0x2af23]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4c0c:	00 
    4c0d:	c5 a1 57 0d 1b af 02 	vxorpd xmm1,xmm11,XMMWORD PTR [rip+0x2af1b]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4c14:	00 
    4c15:	c5 f9 57 05 13 af 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2af13]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4c1c:	00 
    4c1d:	eb 91                	jmp    4bb0 <adapter__run_3+0x160>
    4c1f:	90                   	nop

0000000000004c20 <c_run_4>:
    4c20:	55                   	push   rbp
    4c21:	48 89 f0             	mov    rax,rsi
    4c24:	89 fe                	mov    esi,edi
    4c26:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    4c2b:	48 89 e5             	mov    rbp,rsp
    4c2e:	48 6b f6 38          	imul   rsi,rsi,0x38
    4c32:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    4c36:	c5 7b 10 0d 22 8c 02 	vmovsd xmm9,QWORD PTR [rip+0x28c22]        # 2d860 <__gnat_ada_main_program_name+0x18>
    4c3d:	00 
    4c3e:	4c 01 c6             	add    rsi,r8
    4c41:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    4c45:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4c4c:	00 00 00 00 
    4c50:	c4 c1 7e 6f 00       	vmovdqu ymm0,YMMWORD PTR [r8]
    4c55:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    4c5b:	c4 c1 7e 6f 40 18    	vmovdqu ymm0,YMMWORD PTR [r8+0x18]
    4c61:	c5 7b 10 54 24 c0    	vmovsd xmm10,QWORD PTR [rsp-0x40]
    4c67:	c5 7b 10 5c 24 c8    	vmovsd xmm11,QWORD PTR [rsp-0x38]
    4c6d:	c5 fb 10 7c 24 d0    	vmovsd xmm7,QWORD PTR [rsp-0x30]
    4c73:	c5 fe 7f 44 24 d8    	vmovdqu YMMWORD PTR [rsp-0x28],ymm0
    4c79:	c5 fb 10 54 24 d8    	vmovsd xmm2,QWORD PTR [rsp-0x28]
    4c7f:	c5 fb 10 6c 24 e0    	vmovsd xmm5,QWORD PTR [rsp-0x20]
    4c85:	c5 7b 10 64 24 e8    	vmovsd xmm12,QWORD PTR [rsp-0x18]
    4c8b:	c5 d1 57 05 9d ae 02 	vxorpd xmm0,xmm5,XMMWORD PTR [rip+0x2ae9d]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4c92:	00 
    4c93:	c5 99 57 25 95 ae 02 	vxorpd xmm4,xmm12,XMMWORD PTR [rip+0x2ae95]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4c9a:	00 
    4c9b:	c5 fb 10 74 24 f0    	vmovsd xmm6,QWORD PTR [rsp-0x10]
    4ca1:	c5 c9 57 0d 87 ae 02 	vxorpd xmm1,xmm6,XMMWORD PTR [rip+0x2ae87]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4ca8:	00 
    4ca9:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    4cae:	c5 59 14 e9          	vunpcklpd xmm13,xmm4,xmm1
    4cb2:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    4cb6:	41 0f 94 c1          	sete   r9b
    4cba:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    4cbf:	62 d3 e5 28 18 dd 01 	vinsertf64x2 ymm3,ymm3,xmm13,0x1
    4cc6:	40 0f 94 c7          	sete   dil
    4cca:	c4 c1 7d 11 58 18    	vmovupd YMMWORD PTR [r8+0x18],ymm3
    4cd0:	41 84 f9             	test   r9b,dil
    4cd3:	74 1b                	je     4cf0 <c_run_4+0xd0>
    4cd5:	c4 41 79 2f e0       	vcomisd xmm12,xmm8
    4cda:	41 0f 94 c1          	sete   r9b
    4cde:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    4ce3:	40 0f 94 c7          	sete   dil
    4ce7:	41 84 f9             	test   r9b,dil
    4cea:	0f 85 c0 00 00 00    	jne    4db0 <c_run_4+0x190>
    4cf0:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    4cf4:	c4 c1 6b 59 ea       	vmulsd xmm5,xmm2,xmm10
    4cf9:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    4cfe:	c5 eb 59 d7          	vmulsd xmm2,xmm2,xmm7
    4d02:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    4d06:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    4d0b:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    4d0f:	c4 c1 73 59 da       	vmulsd xmm3,xmm1,xmm10
    4d14:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    4d18:	c5 fb 59 df          	vmulsd xmm3,xmm0,xmm7
    4d1c:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    4d20:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    4d25:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    4d29:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    4d2e:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    4d32:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    4d36:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    4d3a:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    4d3e:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    4d42:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    4d46:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    4d4a:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    4d4f:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    4d53:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    4d57:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    4d5b:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    4d5f:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4d63:	c4 c1 63 58 da       	vaddsd xmm3,xmm3,xmm10
    4d68:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    4d6d:	c5 e1 57 1d bb ad 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2adbb]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4d74:	00 
    4d75:	c5 f1 57 0d b3 ad 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2adb3]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4d7c:	00 
    4d7d:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4d81:	c5 f9 57 05 a7 ad 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2ada7]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4d88:	00 
    4d89:	c4 c1 7b 11 18       	vmovsd QWORD PTR [r8],xmm3
    4d8e:	c4 c1 7b 11 48 08    	vmovsd QWORD PTR [r8+0x8],xmm1
    4d94:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    4d9a:	49 83 c0 38          	add    r8,0x38
    4d9e:	49 39 f0             	cmp    r8,rsi
    4da1:	0f 85 a9 fe ff ff    	jne    4c50 <c_run_4+0x30>
    4da7:	c5 f8 77             	vzeroupper
    4daa:	c9                   	leave
    4dab:	c3                   	ret
    4dac:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    4db0:	c5 29 57 15 78 ad 02 	vxorpd xmm10,xmm10,XMMWORD PTR [rip+0x2ad78]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4db7:	00 
    4db8:	c5 21 57 1d 70 ad 02 	vxorpd xmm11,xmm11,XMMWORD PTR [rip+0x2ad70]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4dbf:	00 
    4dc0:	c5 c1 57 3d 68 ad 02 	vxorpd xmm7,xmm7,XMMWORD PTR [rip+0x2ad68]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4dc7:	00 
    4dc8:	c4 41 7b 11 10       	vmovsd QWORD PTR [r8],xmm10
    4dcd:	c4 41 7b 11 58 08    	vmovsd QWORD PTR [r8+0x8],xmm11
    4dd3:	c4 c1 7b 11 78 10    	vmovsd QWORD PTR [r8+0x10],xmm7
    4dd9:	49 83 c0 38          	add    r8,0x38
    4ddd:	4c 39 c6             	cmp    rsi,r8
    4de0:	0f 85 6a fe ff ff    	jne    4c50 <c_run_4+0x30>
    4de6:	eb bf                	jmp    4da7 <c_run_4+0x187>
    4de8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    4def:	00 

0000000000004df0 <c_run_4.constprop.0>:
    4df0:	55                   	push   rbp
    4df1:	48 89 c8             	mov    rax,rcx
    4df4:	c4 41 39 57 c0       	vxorpd xmm8,xmm8,xmm8
    4df9:	48 8d 89 c0 01 00 00 	lea    rcx,[rcx+0x1c0]
    4e00:	48 89 e5             	mov    rbp,rsp
    4e03:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    4e07:	c5 7b 10 0d 51 8a 02 	vmovsd xmm9,QWORD PTR [rip+0x28a51]        # 2d860 <__gnat_ada_main_program_name+0x18>
    4e0e:	00 
    4e0f:	90                   	nop
    4e10:	c5 fe 6f 00          	vmovdqu ymm0,YMMWORD PTR [rax]
    4e14:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    4e1a:	c5 fe 6f 40 18       	vmovdqu ymm0,YMMWORD PTR [rax+0x18]
    4e1f:	c5 7b 10 54 24 c0    	vmovsd xmm10,QWORD PTR [rsp-0x40]
    4e25:	c5 7b 10 5c 24 c8    	vmovsd xmm11,QWORD PTR [rsp-0x38]
    4e2b:	c5 fb 10 7c 24 d0    	vmovsd xmm7,QWORD PTR [rsp-0x30]
    4e31:	c5 fe 7f 44 24 d8    	vmovdqu YMMWORD PTR [rsp-0x28],ymm0
    4e37:	c5 fb 10 54 24 d8    	vmovsd xmm2,QWORD PTR [rsp-0x28]
    4e3d:	c5 fb 10 6c 24 e0    	vmovsd xmm5,QWORD PTR [rsp-0x20]
    4e43:	c5 7b 10 64 24 e8    	vmovsd xmm12,QWORD PTR [rsp-0x18]
    4e49:	c5 d1 57 05 df ac 02 	vxorpd xmm0,xmm5,XMMWORD PTR [rip+0x2acdf]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4e50:	00 
    4e51:	c5 99 57 25 d7 ac 02 	vxorpd xmm4,xmm12,XMMWORD PTR [rip+0x2acd7]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4e58:	00 
    4e59:	c5 fb 10 74 24 f0    	vmovsd xmm6,QWORD PTR [rsp-0x10]
    4e5f:	c5 c9 57 0d c9 ac 02 	vxorpd xmm1,xmm6,XMMWORD PTR [rip+0x2acc9]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4e66:	00 
    4e67:	c4 c1 79 2f d1       	vcomisd xmm2,xmm9
    4e6c:	c5 59 14 e9          	vunpcklpd xmm13,xmm4,xmm1
    4e70:	c5 e9 14 d8          	vunpcklpd xmm3,xmm2,xmm0
    4e74:	41 0f 94 c1          	sete   r9b
    4e78:	c4 c1 79 2f e8       	vcomisd xmm5,xmm8
    4e7d:	62 d3 e5 28 18 dd 01 	vinsertf64x2 ymm3,ymm3,xmm13,0x1
    4e84:	41 0f 94 c0          	sete   r8b
    4e88:	c5 fd 11 58 18       	vmovupd YMMWORD PTR [rax+0x18],ymm3
    4e8d:	45 84 c1             	test   r9b,r8b
    4e90:	74 1b                	je     4ead <c_run_4.constprop.0+0xbd>
    4e92:	c4 41 79 2f e0       	vcomisd xmm12,xmm8
    4e97:	41 0f 94 c1          	sete   r9b
    4e9b:	c4 c1 79 2f f0       	vcomisd xmm6,xmm8
    4ea0:	41 0f 94 c0          	sete   r8b
    4ea4:	45 84 c1             	test   r9b,r8b
    4ea7:	0f 85 b9 00 00 00    	jne    4f66 <c_run_4.constprop.0+0x176>
    4ead:	c5 db 59 df          	vmulsd xmm3,xmm4,xmm7
    4eb1:	c4 c1 6b 59 ea       	vmulsd xmm5,xmm2,xmm10
    4eb6:	c4 c1 6b 59 f3       	vmulsd xmm6,xmm2,xmm11
    4ebb:	c5 eb 59 d7          	vmulsd xmm2,xmm2,xmm7
    4ebf:	c5 d3 58 eb          	vaddsd xmm5,xmm5,xmm3
    4ec3:	c4 c1 73 59 db       	vmulsd xmm3,xmm1,xmm11
    4ec8:	c5 d3 5c eb          	vsubsd xmm5,xmm5,xmm3
    4ecc:	c4 c1 73 59 da       	vmulsd xmm3,xmm1,xmm10
    4ed1:	c5 cb 58 f3          	vaddsd xmm6,xmm6,xmm3
    4ed5:	c5 fb 59 df          	vmulsd xmm3,xmm0,xmm7
    4ed9:	c5 cb 5c f3          	vsubsd xmm6,xmm6,xmm3
    4edd:	c4 c1 7b 59 db       	vmulsd xmm3,xmm0,xmm11
    4ee2:	c5 eb 58 d3          	vaddsd xmm2,xmm2,xmm3
    4ee6:	c4 c1 5b 59 da       	vmulsd xmm3,xmm4,xmm10
    4eeb:	c5 73 59 e6          	vmulsd xmm12,xmm1,xmm6
    4eef:	c5 f3 59 cd          	vmulsd xmm1,xmm1,xmm5
    4ef3:	c5 eb 5c d3          	vsubsd xmm2,xmm2,xmm3
    4ef7:	c5 db 59 da          	vmulsd xmm3,xmm4,xmm2
    4efb:	c5 fb 59 d2          	vmulsd xmm2,xmm0,xmm2
    4eff:	c5 db 59 e5          	vmulsd xmm4,xmm4,xmm5
    4f03:	c5 fb 59 c6          	vmulsd xmm0,xmm0,xmm6
    4f07:	c4 c1 63 5c dc       	vsubsd xmm3,xmm3,xmm12
    4f0c:	c5 f3 5c ca          	vsubsd xmm1,xmm1,xmm2
    4f10:	c5 fb 5c c4          	vsubsd xmm0,xmm0,xmm4
    4f14:	c5 e3 58 db          	vaddsd xmm3,xmm3,xmm3
    4f18:	c5 f3 58 c9          	vaddsd xmm1,xmm1,xmm1
    4f1c:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    4f20:	c4 c1 63 58 da       	vaddsd xmm3,xmm3,xmm10
    4f25:	c4 c1 73 58 cb       	vaddsd xmm1,xmm1,xmm11
    4f2a:	c5 e1 57 1d fe ab 02 	vxorpd xmm3,xmm3,XMMWORD PTR [rip+0x2abfe]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4f31:	00 
    4f32:	c5 f1 57 0d f6 ab 02 	vxorpd xmm1,xmm1,XMMWORD PTR [rip+0x2abf6]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4f39:	00 
    4f3a:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    4f3e:	c5 f9 57 05 ea ab 02 	vxorpd xmm0,xmm0,XMMWORD PTR [rip+0x2abea]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4f45:	00 
    4f46:	c5 fb 11 18          	vmovsd QWORD PTR [rax],xmm3
    4f4a:	c5 fb 11 48 08       	vmovsd QWORD PTR [rax+0x8],xmm1
    4f4f:	c5 fb 11 40 10       	vmovsd QWORD PTR [rax+0x10],xmm0
    4f54:	48 83 c0 38          	add    rax,0x38
    4f58:	48 39 c8             	cmp    rax,rcx
    4f5b:	0f 85 af fe ff ff    	jne    4e10 <c_run_4.constprop.0+0x20>
    4f61:	c5 f8 77             	vzeroupper
    4f64:	c9                   	leave
    4f65:	c3                   	ret
    4f66:	c5 29 57 15 c2 ab 02 	vxorpd xmm10,xmm10,XMMWORD PTR [rip+0x2abc2]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4f6d:	00 
    4f6e:	c5 21 57 1d ba ab 02 	vxorpd xmm11,xmm11,XMMWORD PTR [rip+0x2abba]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4f75:	00 
    4f76:	c5 c1 57 3d b2 ab 02 	vxorpd xmm7,xmm7,XMMWORD PTR [rip+0x2abb2]        # 2fb30 <system__secondary_stack__invalid_memory_size+0xa8>
    4f7d:	00 
    4f7e:	c5 7b 11 10          	vmovsd QWORD PTR [rax],xmm10
    4f82:	c5 7b 11 58 08       	vmovsd QWORD PTR [rax+0x8],xmm11
    4f87:	c5 fb 11 78 10       	vmovsd QWORD PTR [rax+0x10],xmm7
    4f8c:	48 83 c0 38          	add    rax,0x38
    4f90:	48 39 c8             	cmp    rax,rcx
    4f93:	0f 85 77 fe ff ff    	jne    4e10 <c_run_4.constprop.0+0x20>
    4f99:	eb c6                	jmp    4f61 <c_run_4.constprop.0+0x171>
    4f9b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000005b10 <adapter__run_1>:
    5b10:	48 89 f0             	mov    rax,rsi
    5b13:	89 fe                	mov    esi,edi
    5b15:	c5 fb 10 1d 43 7d 02 	vmovsd xmm3,QWORD PTR [rip+0x27d43]        # 2d860 <__gnat_ada_main_program_name+0x18>
    5b1c:	00 
    5b1d:	c5 fd 6f 2d 3b 7d 02 	vmovdqa ymm5,YMMWORD PTR [rip+0x27d3b]        # 2d860 <__gnat_ada_main_program_name+0x18>
    5b24:	00 
    5b25:	48 6b f6 38          	imul   rsi,rsi,0x38
    5b29:	c5 fb 10 25 07 9f 02 	vmovsd xmm4,QWORD PTR [rip+0x29f07]        # 2fa38 <system__os_lib__standin+0xc>
    5b30:	00 
    5b31:	c5 e9 57 d2          	vxorpd xmm2,xmm2,xmm2
    5b35:	4c 01 c6             	add    rsi,r8
    5b38:	eb 4e                	jmp    5b88 <adapter__run_1+0x78>
    5b3a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    5b40:	c5 79 2f ca          	vcomisd xmm9,xmm2
    5b44:	0f 85 4a 01 00 00    	jne    5c94 <adapter__run_1+0x184>
    5b4a:	c5 79 2f ea          	vcomisd xmm13,xmm2
    5b4e:	0f 85 40 01 00 00    	jne    5c94 <adapter__run_1+0x184>
    5b54:	c5 c9 15 fe          	vunpckhpd xmm7,xmm6,xmm6
    5b58:	c5 f9 2f fa          	vcomisd xmm7,xmm2
    5b5c:	0f 85 32 01 00 00    	jne    5c94 <adapter__run_1+0x184>
    5b62:	62 b1 8d 08 58 f0    	vaddpd xmm6,xmm14,xmm16
    5b68:	c4 41 1b 58 db       	vaddsd xmm11,xmm12,xmm11
    5b6d:	0f 1f 00             	nop    DWORD PTR [rax]
    5b70:	c4 c1 79 11 30       	vmovupd XMMWORD PTR [r8],xmm6
    5b75:	c4 41 7b 11 58 10    	vmovsd QWORD PTR [r8+0x10],xmm11
    5b7b:	49 83 c0 38          	add    r8,0x38
    5b7f:	4c 39 c6             	cmp    rsi,r8
    5b82:	0f 84 d8 01 00 00    	je     5d60 <adapter__run_1+0x250>
    5b88:	49 8d 78 18          	lea    rdi,[r8+0x18]
    5b8c:	c5 fd 10 48 18       	vmovupd ymm1,YMMWORD PTR [rax+0x18]
    5b91:	c5 fd 10 42 18       	vmovupd ymm0,YMMWORD PTR [rdx+0x18]
    5b96:	c4 e2 7d 19 f1       	vbroadcastsd ymm6,xmm1
    5b9b:	c4 63 fd 01 c0 4e    	vpermpd ymm8,ymm0,0x4e
    5ba1:	c4 e3 fd 01 f8 1b    	vpermpd ymm7,ymm0,0x1b
    5ba7:	c4 63 fd 01 c9 55    	vpermpd ymm9,ymm1,0x55
    5bad:	c5 cd 59 f0          	vmulpd ymm6,ymm6,ymm0
    5bb1:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    5bb7:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    5bbc:	c5 cd d0 f0          	vaddsubpd ymm6,ymm6,ymm0
    5bc0:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    5bc6:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    5bcc:	c4 c1 7d 59 c0       	vmulpd ymm0,ymm0,ymm8
    5bd1:	c5 f5 59 cf          	vmulpd ymm1,ymm1,ymm7
    5bd5:	c5 4d 5c c0          	vsubpd ymm8,ymm6,ymm0
    5bd9:	c5 fd 58 c6          	vaddpd ymm0,ymm0,ymm6
    5bdd:	c4 c3 7d 0d c0 09    	vblendpd ymm0,ymm0,ymm8,0x9
    5be3:	c5 75 58 c8          	vaddpd ymm9,ymm1,ymm0
    5be7:	c5 fd 5c c9          	vsubpd ymm1,ymm0,ymm1
    5beb:	62 73 fd 28 19 cf 01 	vextractf64x2 xmm7,ymm9,0x1
    5bf2:	c5 71 15 c1          	vunpckhpd xmm8,xmm1,xmm1
    5bf6:	c5 f3 59 c1          	vmulsd xmm0,xmm1,xmm1
    5bfa:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    5bff:	62 d3 b5 28 03 f1 03 	valignq ymm6,ymm9,ymm9,0x3
    5c06:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    5c0b:	c5 c3 59 ff          	vmulsd xmm7,xmm7,xmm7
    5c0f:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    5c13:	c5 cb 59 f6          	vmulsd xmm6,xmm6,xmm6
    5c17:	c5 fb 58 c6          	vaddsd xmm0,xmm0,xmm6
    5c1b:	c5 f9 2f c2          	vcomisd xmm0,xmm2
    5c1f:	0f 84 0b 01 00 00    	je     5d30 <adapter__run_1+0x220>
    5c25:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    5c29:	c5 f9 2f e0          	vcomisd xmm4,xmm0
    5c2d:	0f 87 fd 00 00 00    	ja     5d30 <adapter__run_1+0x220>
    5c33:	c4 63 35 0d c9 03    	vblendpd ymm9,ymm9,ymm1,0x3
    5c39:	c5 fb 5c cb          	vsubsd xmm1,xmm0,xmm3
    5c3d:	c5 f1 54 0d fb 9e 02 	vandpd xmm1,xmm1,XMMWORD PTR [rip+0x29efb]        # 2fb40 <system__secondary_stack__invalid_memory_size+0xb8>
    5c44:	00 
    5c45:	c5 f9 2f cc          	vcomisd xmm1,xmm4
    5c49:	0f 87 f1 00 00 00    	ja     5d40 <adapter__run_1+0x230>
    5c4f:	c4 41 7d 11 48 18    	vmovupd YMMWORD PTR [r8+0x18],ymm9
    5c55:	c5 f9 28 48 10       	vmovapd xmm1,XMMWORD PTR [rax+0x10]
    5c5a:	c5 79 28 48 20       	vmovapd xmm9,XMMWORD PTR [rax+0x20]
    5c5f:	c5 f9 10 42 08       	vmovupd xmm0,XMMWORD PTR [rdx+0x8]
    5c64:	c5 f9 10 70 28       	vmovupd xmm6,XMMWORD PTR [rax+0x28]
    5c69:	62 e1 fd 08 28 02    	vmovapd xmm16,XMMWORD PTR [rdx]
    5c6f:	c5 79 28 30          	vmovapd xmm14,XMMWORD PTR [rax]
    5c73:	c5 7b 10 58 10       	vmovsd xmm11,QWORD PTR [rax+0x10]
    5c78:	c5 f1 15 f9          	vunpckhpd xmm7,xmm1,xmm1
    5c7c:	c4 41 31 15 e9       	vunpckhpd xmm13,xmm9,xmm9
    5c81:	c4 41 79 28 f9       	vmovapd xmm15,xmm9
    5c86:	c5 f9 2f fb          	vcomisd xmm7,xmm3
    5c8a:	c5 79 15 e0          	vunpckhpd xmm12,xmm0,xmm0
    5c8e:	0f 84 ac fe ff ff    	je     5b40 <adapter__run_1+0x30>
    5c94:	c5 7b 12 12          	vmovddup xmm10,QWORD PTR [rdx]
    5c98:	c5 7b 10 40 30       	vmovsd xmm8,QWORD PTR [rax+0x30]
    5c9d:	c5 39 16 40 20       	vmovhpd xmm8,xmm8,QWORD PTR [rax+0x20]
    5ca2:	c4 e3 79 05 f9 03    	vpermilpd xmm7,xmm1,0x3
    5ca8:	62 e1 fd 08 59 cf    	vmulpd xmm17,xmm0,xmm7
    5cae:	c4 41 79 15 d2       	vunpckhpd xmm10,xmm0,xmm10
    5cb3:	c4 c1 79 59 c1       	vmulpd xmm0,xmm0,xmm9
    5cb8:	c4 c1 41 59 fa       	vmulpd xmm7,xmm7,xmm10
    5cbd:	62 b1 bd 08 59 c8    	vmulpd xmm1,xmm8,xmm16
    5cc3:	c5 f9 58 c7          	vaddpd xmm0,xmm0,xmm7
    5cc7:	62 b1 cd 08 59 f8    	vmulpd xmm7,xmm6,xmm16
    5ccd:	62 b1 f5 08 58 c9    	vaddpd xmm1,xmm1,xmm17
    5cd3:	62 c1 b5 08 59 ca    	vmulpd xmm17,xmm9,xmm10
    5cd9:	c5 f9 5c c7          	vsubpd xmm0,xmm0,xmm7
    5cdd:	62 b1 f5 08 5c c9    	vsubpd xmm1,xmm1,xmm17
    5ce3:	c5 f9 59 f6          	vmulpd xmm6,xmm0,xmm6
    5ce7:	c4 41 71 59 c0       	vmulpd xmm8,xmm1,xmm8
    5cec:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    5cf0:	c4 c1 73 59 cf       	vmulsd xmm1,xmm1,xmm15
    5cf5:	c4 c1 7b 59 c5       	vmulsd xmm0,xmm0,xmm13
    5cfa:	c4 c1 49 5c f0       	vsubpd xmm6,xmm6,xmm8
    5cff:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    5d03:	c5 c9 58 f6          	vaddpd xmm6,xmm6,xmm6
    5d07:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    5d0b:	62 b1 cd 08 58 f0    	vaddpd xmm6,xmm6,xmm16
    5d11:	c4 c1 7b 58 c4       	vaddsd xmm0,xmm0,xmm12
    5d16:	c4 c1 49 58 f6       	vaddpd xmm6,xmm6,xmm14
    5d1b:	c4 41 7b 58 db       	vaddsd xmm11,xmm0,xmm11
    5d20:	e9 4b fe ff ff       	jmp    5b70 <adapter__run_1+0x60>
    5d25:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5d2c:	00 00 00 00 
    5d30:	c5 fe 7f 2f          	vmovdqu YMMWORD PTR [rdi],ymm5
    5d34:	e9 1c ff ff ff       	jmp    5c55 <adapter__run_1+0x145>
    5d39:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    5d40:	c5 e3 5e c0          	vdivsd xmm0,xmm3,xmm0
    5d44:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    5d49:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    5d4e:	c5 fe 7f 07          	vmovdqu YMMWORD PTR [rdi],ymm0
    5d52:	e9 fe fe ff ff       	jmp    5c55 <adapter__run_1+0x145>
    5d57:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    5d5e:	00 00 
    5d60:	c5 f8 77             	vzeroupper
    5d63:	c3                   	ret
    5d64:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    5d6b:	00 00 00 
    5d6e:	66 90                	xchg   ax,ax

0000000000005d70 <adapter__run_2>:
    5d70:	41 89 f9             	mov    r9d,edi
    5d73:	c5 fd 6f 35 e5 7a 02 	vmovdqa ymm6,YMMWORD PTR [rip+0x27ae5]        # 2d860 <__gnat_ada_main_program_name+0x18>
    5d7a:	00 
    5d7b:	c5 fb 10 2d b5 9c 02 	vmovsd xmm5,QWORD PTR [rip+0x29cb5]        # 2fa38 <system__os_lib__standin+0xc>
    5d82:	00 
    5d83:	c5 fb 10 25 d5 7a 02 	vmovsd xmm4,QWORD PTR [rip+0x27ad5]        # 2d860 <__gnat_ada_main_program_name+0x18>
    5d8a:	00 
    5d8b:	4d 6b c9 38          	imul   r9,r9,0x38
    5d8f:	c5 e1 57 db          	vxorpd xmm3,xmm3,xmm3
    5d93:	4d 01 c1             	add    r9,r8
    5d96:	e9 1f 01 00 00       	jmp    5eba <adapter__run_2+0x14a>
    5d9b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    5da0:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    5da4:	c5 f9 2f e8          	vcomisd xmm5,xmm0
    5da8:	0f 87 00 02 00 00    	ja     5fae <adapter__run_2+0x23e>
    5dae:	62 31 fd 28 28 f2    	vmovapd ymm14,ymm18
    5db4:	c4 e3 0d 0d c9 03    	vblendpd ymm1,ymm14,ymm1,0x3
    5dba:	c5 7b 5c f4          	vsubsd xmm14,xmm0,xmm4
    5dbe:	c5 09 54 35 7a 9d 02 	vandpd xmm14,xmm14,XMMWORD PTR [rip+0x29d7a]        # 2fb40 <system__secondary_stack__invalid_memory_size+0xb8>
    5dc5:	00 
    5dc6:	c5 79 2f f5          	vcomisd xmm14,xmm5
    5dca:	0f 87 f0 01 00 00    	ja     5fc0 <adapter__run_2+0x250>
    5dd0:	c4 c1 7d 11 48 18    	vmovupd YMMWORD PTR [r8+0x18],ymm1
    5dd6:	62 e1 fd 08 10 82 08 	vmovupd xmm16,XMMWORD PTR [rdx+0x8]
    5ddd:	00 00 00 
    5de0:	62 e1 fd 08 2f db    	vcomisd xmm19,xmm3
    5de6:	62 e1 fd 08 28 0a    	vmovapd xmm17,XMMWORD PTR [rdx]
    5dec:	40 0f 94 c7          	sete   dil
    5df0:	c5 79 2f e3          	vcomisd xmm12,xmm3
    5df4:	0f 94 c0             	sete   al
    5df7:	62 31 fd 00 15 f0    	vunpckhpd xmm14,xmm16,xmm16
    5dfd:	40 84 c7             	test   dil,al
    5e00:	74 1a                	je     5e1c <adapter__run_2+0xac>
    5e02:	62 e1 fd 08 2f e4    	vcomisd xmm20,xmm4
    5e08:	40 0f 94 c7          	sete   dil
    5e0c:	c5 79 2f fb          	vcomisd xmm15,xmm3
    5e10:	0f 94 c0             	sete   al
    5e13:	40 84 c7             	test   dil,al
    5e16:	0f 85 c4 01 00 00    	jne    5fe0 <adapter__run_2+0x270>
    5e1c:	c5 fb 12 02          	vmovddup xmm0,QWORD PTR [rdx]
    5e20:	c4 43 79 05 ed 03    	vpermilpd xmm13,xmm13,0x3
    5e26:	c4 41 19 14 e7       	vunpcklpd xmm12,xmm12,xmm15
    5e2b:	62 51 f5 00 59 fc    	vmulpd xmm15,xmm17,xmm12
    5e31:	62 b1 95 08 59 c8    	vmulpd xmm1,xmm13,xmm16
    5e37:	c4 c1 71 58 cf       	vaddpd xmm1,xmm1,xmm15
    5e3c:	62 f1 fd 00 15 c0    	vunpckhpd xmm0,xmm16,xmm0
    5e42:	c4 41 79 59 fb       	vmulpd xmm15,xmm0,xmm11
    5e47:	62 31 a5 08 59 d8    	vmulpd xmm11,xmm11,xmm16
    5e4d:	c4 c1 79 59 c5       	vmulpd xmm0,xmm0,xmm13
    5e52:	c4 c1 71 5c cf       	vsubpd xmm1,xmm1,xmm15
    5e57:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    5e5c:	62 31 ed 08 59 d9    	vmulpd xmm11,xmm2,xmm17
    5e62:	c5 19 59 e1          	vmulpd xmm12,xmm12,xmm1
    5e66:	c4 c1 73 59 c9       	vmulsd xmm1,xmm1,xmm9
    5e6b:	c4 c1 79 5c c3       	vsubpd xmm0,xmm0,xmm11
    5e70:	c5 e9 59 d0          	vmulpd xmm2,xmm2,xmm0
    5e74:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    5e78:	c4 c1 7b 59 c0       	vmulsd xmm0,xmm0,xmm8
    5e7d:	c4 c1 69 5c d4       	vsubpd xmm2,xmm2,xmm12
    5e82:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    5e86:	c5 e9 58 d2          	vaddpd xmm2,xmm2,xmm2
    5e8a:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    5e8e:	62 b1 ed 08 58 d1    	vaddpd xmm2,xmm2,xmm17
    5e94:	c4 c1 7b 58 c6       	vaddsd xmm0,xmm0,xmm14
    5e99:	c4 c1 69 58 d2       	vaddpd xmm2,xmm2,xmm10
    5e9e:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    5ea2:	c4 c1 79 11 10       	vmovupd XMMWORD PTR [r8],xmm2
    5ea7:	c4 c1 7b 11 40 10    	vmovsd QWORD PTR [r8+0x10],xmm0
    5ead:	49 83 c0 38          	add    r8,0x38
    5eb1:	4d 39 c1             	cmp    r9,r8
    5eb4:	0f 84 4a 01 00 00    	je     6004 <adapter__run_2+0x294>
    5eba:	49 8d 40 18          	lea    rax,[r8+0x18]
    5ebe:	c5 fd 10 4a 18       	vmovupd ymm1,YMMWORD PTR [rdx+0x18]
    5ec3:	c5 79 10 58 08       	vmovupd xmm11,XMMWORD PTR [rax+0x8]
    5ec8:	c4 63 fd 01 70 e8 ff 	vpermpd ymm14,YMMWORD PTR [rax-0x18],0xff
    5ecf:	c5 f9 10 50 10       	vmovupd xmm2,XMMWORD PTR [rax+0x10]
    5ed4:	c4 41 79 10 10       	vmovupd xmm10,XMMWORD PTR [r8]
    5ed9:	c4 c1 7b 10 78 10    	vmovsd xmm7,QWORD PTR [r8+0x10]
    5edf:	c5 79 10 68 f8       	vmovupd xmm13,XMMWORD PTR [rax-0x8]
    5ee4:	62 c1 ff 08 10 60 03 	vmovsd xmm20,QWORD PTR [r8+0x18]
    5eeb:	c5 7b 10 78 08       	vmovsd xmm15,QWORD PTR [rax+0x8]
    5ef0:	62 e1 ff 08 10 58 02 	vmovsd xmm19,QWORD PTR [rax+0x10]
    5ef7:	c5 7b 10 60 18       	vmovsd xmm12,QWORD PTR [rax+0x18]
    5efc:	c4 e3 7d 05 c1 05    	vpermilpd ymm0,ymm1,0x5
    5f02:	62 c2 fd 28 19 d3    	vbroadcastsd ymm18,xmm11
    5f08:	62 e2 fd 28 19 ca    	vbroadcastsd ymm17,xmm2
    5f0e:	c4 41 79 28 cb       	vmovapd xmm9,xmm11
    5f13:	62 b1 fd 28 59 c2    	vmulpd ymm0,ymm0,ymm18
    5f19:	c5 0d 59 f1          	vmulpd ymm14,ymm14,ymm1
    5f1d:	62 e1 ed 08 15 c2    	vunpckhpd xmm16,xmm2,xmm2
    5f23:	c5 79 28 c2          	vmovapd xmm8,xmm2
    5f27:	62 a2 fd 28 19 c0    	vbroadcastsd ymm16,xmm16
    5f2d:	c5 0d d0 f0          	vaddsubpd ymm14,ymm14,ymm0
    5f31:	c4 e3 fd 01 c1 4e    	vpermpd ymm0,ymm1,0x4e
    5f37:	c4 e3 fd 01 c9 1b    	vpermpd ymm1,ymm1,0x1b
    5f3d:	62 b1 fd 28 59 c1    	vmulpd ymm0,ymm0,ymm17
    5f43:	62 b1 f5 28 59 c8    	vmulpd ymm1,ymm1,ymm16
    5f49:	62 e1 8d 28 5c c8    	vsubpd ymm17,ymm14,ymm0
    5f4f:	c4 c1 7d 58 c6       	vaddpd ymm0,ymm0,ymm14
    5f54:	62 31 fd 28 28 f1    	vmovapd ymm14,ymm17
    5f5a:	c4 c3 7d 0d c6 09    	vblendpd ymm0,ymm0,ymm14,0x9
    5f60:	62 e1 f5 28 58 d0    	vaddpd ymm18,ymm1,ymm0
    5f66:	c5 fd 5c c9          	vsubpd ymm1,ymm0,ymm1
    5f6a:	62 a3 fd 28 19 d0 01 	vextractf64x2 xmm16,ymm18,0x1
    5f71:	62 e1 f5 08 15 c9    	vunpckhpd xmm17,xmm1,xmm1
    5f77:	c5 f3 59 c1          	vmulsd xmm0,xmm1,xmm1
    5f7b:	62 a1 f7 00 59 c9    	vmulsd xmm17,xmm17,xmm17
    5f81:	62 33 ed 20 03 f2 03 	valignq ymm14,ymm18,ymm18,0x3
    5f88:	62 b1 ff 08 58 c1    	vaddsd xmm0,xmm0,xmm17
    5f8e:	62 a1 ff 00 59 c0    	vmulsd xmm16,xmm16,xmm16
    5f94:	62 b1 ff 08 58 c0    	vaddsd xmm0,xmm0,xmm16
    5f9a:	c4 41 0b 59 f6       	vmulsd xmm14,xmm14,xmm14
    5f9f:	c4 c1 7b 58 c6       	vaddsd xmm0,xmm0,xmm14
    5fa4:	c5 f9 2f c3          	vcomisd xmm0,xmm3
    5fa8:	0f 85 f2 fd ff ff    	jne    5da0 <adapter__run_2+0x30>
    5fae:	c5 fe 7f 30          	vmovdqu YMMWORD PTR [rax],ymm6
    5fb2:	e9 1f fe ff ff       	jmp    5dd6 <adapter__run_2+0x66>
    5fb7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    5fbe:	00 00 
    5fc0:	c5 db 5e c0          	vdivsd xmm0,xmm4,xmm0
    5fc4:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    5fc9:	c5 fd 59 c1          	vmulpd ymm0,ymm0,ymm1
    5fcd:	c5 fe 7f 00          	vmovdqu YMMWORD PTR [rax],ymm0
    5fd1:	e9 00 fe ff ff       	jmp    5dd6 <adapter__run_2+0x66>
    5fd6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    5fdd:	00 00 00 
    5fe0:	62 c1 f5 00 58 ca    	vaddpd xmm17,xmm17,xmm10
    5fe6:	c4 41 43 58 f6       	vaddsd xmm14,xmm7,xmm14
    5feb:	62 c1 fd 08 11 08    	vmovupd XMMWORD PTR [r8],xmm17
    5ff1:	c4 41 7b 11 70 10    	vmovsd QWORD PTR [r8+0x10],xmm14
    5ff7:	49 83 c0 38          	add    r8,0x38
    5ffb:	4d 39 c8             	cmp    r8,r9
    5ffe:	0f 85 b6 fe ff ff    	jne    5eba <adapter__run_2+0x14a>
    6004:	c5 f8 77             	vzeroupper
    6007:	c3                   	ret
    6008:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    600f:	00 

0000000000006930 <c_run_1.constprop.0>:
    6930:	48 89 f8             	mov    rax,rdi
    6933:	c5 fb 10 1d fd 90 02 	vmovsd xmm3,QWORD PTR [rip+0x290fd]        # 2fa38 <system__os_lib__standin+0xc>
    693a:	00 
    693b:	c5 fb 10 15 1d 6f 02 	vmovsd xmm2,QWORD PTR [rip+0x26f1d]        # 2d860 <__gnat_ada_main_program_name+0x18>
    6942:	00 
    6943:	c5 fd 28 2d 15 6f 02 	vmovapd ymm5,YMMWORD PTR [rip+0x26f15]        # 2d860 <__gnat_ada_main_program_name+0x18>
    694a:	00 
    694b:	48 8d b9 c0 01 00 00 	lea    rdi,[rcx+0x1c0]
    6952:	c5 d9 57 e4          	vxorpd xmm4,xmm4,xmm4
    6956:	e9 84 00 00 00       	jmp    69df <c_run_1.constprop.0+0xaf>
    695b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    6960:	c5 fd 11 69 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm5
    6965:	c5 f9 10 48 18       	vmovupd xmm1,XMMWORD PTR [rax+0x18]
    696a:	c5 79 28 50 20       	vmovapd xmm10,XMMWORD PTR [rax+0x20]
    696f:	c5 f9 10 46 08       	vmovupd xmm0,XMMWORD PTR [rsi+0x8]
    6974:	c5 f9 10 70 28       	vmovupd xmm6,XMMWORD PTR [rax+0x28]
    6979:	c5 f9 28 3e          	vmovapd xmm7,XMMWORD PTR [rsi]
    697d:	c5 f9 2f ca          	vcomisd xmm1,xmm2
    6981:	c4 41 29 15 f2       	vunpckhpd xmm14,xmm10,xmm10
    6986:	c4 41 79 28 ea       	vmovapd xmm13,xmm10
    698b:	c5 79 15 c8          	vunpckhpd xmm9,xmm0,xmm0
    698f:	0f 85 1b 01 00 00    	jne    6ab0 <c_run_1.constprop.0+0x180>
    6995:	c5 79 2f d4          	vcomisd xmm10,xmm4
    6999:	0f 85 11 01 00 00    	jne    6ab0 <c_run_1.constprop.0+0x180>
    699f:	c5 79 2f f4          	vcomisd xmm14,xmm4
    69a3:	0f 85 07 01 00 00    	jne    6ab0 <c_run_1.constprop.0+0x180>
    69a9:	c5 49 15 c6          	vunpckhpd xmm8,xmm6,xmm6
    69ad:	c5 79 2f c4          	vcomisd xmm8,xmm4
    69b1:	0f 85 f9 00 00 00    	jne    6ab0 <c_run_1.constprop.0+0x180>
    69b7:	c5 f9 11 39          	vmovupd XMMWORD PTR [rcx],xmm7
    69bb:	c5 7b 11 49 10       	vmovsd QWORD PTR [rcx+0x10],xmm9
    69c0:	c5 c1 58 38          	vaddpd xmm7,xmm7,XMMWORD PTR [rax]
    69c4:	c5 33 58 48 10       	vaddsd xmm9,xmm9,QWORD PTR [rax+0x10]
    69c9:	c5 f9 11 39          	vmovupd XMMWORD PTR [rcx],xmm7
    69cd:	c5 7b 11 49 10       	vmovsd QWORD PTR [rcx+0x10],xmm9
    69d2:	48 83 c1 38          	add    rcx,0x38
    69d6:	48 39 cf             	cmp    rdi,rcx
    69d9:	0f 84 71 01 00 00    	je     6b50 <c_run_1.constprop.0+0x220>
    69df:	c5 fd 10 48 18       	vmovupd ymm1,YMMWORD PTR [rax+0x18]
    69e4:	c5 fd 10 46 18       	vmovupd ymm0,YMMWORD PTR [rsi+0x18]
    69e9:	c4 e2 7d 19 f1       	vbroadcastsd ymm6,xmm1
    69ee:	c4 63 fd 01 c0 4e    	vpermpd ymm8,ymm0,0x4e
    69f4:	c4 e3 fd 01 f8 1b    	vpermpd ymm7,ymm0,0x1b
    69fa:	c4 63 fd 01 c9 55    	vpermpd ymm9,ymm1,0x55
    6a00:	c5 cd 59 f0          	vmulpd ymm6,ymm6,ymm0
    6a04:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    6a0a:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    6a0f:	c5 cd d0 f0          	vaddsubpd ymm6,ymm6,ymm0
    6a13:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    6a19:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    6a1f:	c4 c1 7d 59 c0       	vmulpd ymm0,ymm0,ymm8
    6a24:	c5 f5 59 cf          	vmulpd ymm1,ymm1,ymm7
    6a28:	c5 4d 5c c0          	vsubpd ymm8,ymm6,ymm0
    6a2c:	c5 fd 58 c6          	vaddpd ymm0,ymm0,ymm6
    6a30:	c4 c3 7d 0d c0 09    	vblendpd ymm0,ymm0,ymm8,0x9
    6a36:	c5 75 58 c8          	vaddpd ymm9,ymm1,ymm0
    6a3a:	c5 fd 5c c9          	vsubpd ymm1,ymm0,ymm1
    6a3e:	62 73 fd 28 19 cf 01 	vextractf64x2 xmm7,ymm9,0x1
    6a45:	c5 71 15 c1          	vunpckhpd xmm8,xmm1,xmm1
    6a49:	c5 f3 59 c1          	vmulsd xmm0,xmm1,xmm1
    6a4d:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    6a52:	62 d3 b5 28 03 f1 03 	valignq ymm6,ymm9,ymm9,0x3
    6a59:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    6a5e:	c5 c3 59 ff          	vmulsd xmm7,xmm7,xmm7
    6a62:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    6a66:	c5 cb 59 f6          	vmulsd xmm6,xmm6,xmm6
    6a6a:	c5 fb 58 c6          	vaddsd xmm0,xmm0,xmm6
    6a6e:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    6a72:	c5 f9 2f d8          	vcomisd xmm3,xmm0
    6a76:	0f 87 e4 fe ff ff    	ja     6960 <c_run_1.constprop.0+0x30>
    6a7c:	c4 63 35 0d c9 03    	vblendpd ymm9,ymm9,ymm1,0x3
    6a82:	c5 fb 5c ca          	vsubsd xmm1,xmm0,xmm2
    6a86:	c5 f1 54 0d b2 90 02 	vandpd xmm1,xmm1,XMMWORD PTR [rip+0x290b2]        # 2fb40 <system__secondary_stack__invalid_memory_size+0xb8>
    6a8d:	00 
    6a8e:	c5 f9 2f cb          	vcomisd xmm1,xmm3
    6a92:	0f 87 98 00 00 00    	ja     6b30 <c_run_1.constprop.0+0x200>
    6a98:	c5 7d 11 49 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm9
    6a9d:	e9 c3 fe ff ff       	jmp    6965 <c_run_1.constprop.0+0x35>
    6aa2:	0f 1f 00             	nop    DWORD PTR [rax]
    6aa5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6aac:	00 00 00 00 
    6ab0:	c4 63 79 05 e1 00    	vpermilpd xmm12,xmm1,0x0
    6ab6:	c5 49 15 c1          	vunpckhpd xmm8,xmm6,xmm1
    6aba:	c5 79 c6 df 01       	vshufpd xmm11,xmm0,xmm7,0x1
    6abf:	c5 b9 59 cf          	vmulpd xmm1,xmm8,xmm7
    6ac3:	c4 41 79 59 fc       	vmulpd xmm15,xmm0,xmm12
    6ac8:	c4 c1 79 59 c2       	vmulpd xmm0,xmm0,xmm10
    6acd:	c4 c1 71 58 cf       	vaddpd xmm1,xmm1,xmm15
    6ad2:	c4 41 21 59 fa       	vmulpd xmm15,xmm11,xmm10
    6ad7:	c4 41 21 59 dc       	vmulpd xmm11,xmm11,xmm12
    6adc:	c5 49 59 d7          	vmulpd xmm10,xmm6,xmm7
    6ae0:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    6ae5:	c4 c1 71 5c cf       	vsubpd xmm1,xmm1,xmm15
    6aea:	c4 c1 79 5c c2       	vsubpd xmm0,xmm0,xmm10
    6aef:	c4 41 71 59 c0       	vmulpd xmm8,xmm1,xmm8
    6af4:	c4 c1 73 59 cd       	vmulsd xmm1,xmm1,xmm13
    6af9:	c5 c9 59 f0          	vmulpd xmm6,xmm6,xmm0
    6afd:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    6b01:	c4 c1 7b 59 c6       	vmulsd xmm0,xmm0,xmm14
    6b06:	c4 c1 49 5c f0       	vsubpd xmm6,xmm6,xmm8
    6b0b:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    6b0f:	c5 c9 58 f6          	vaddpd xmm6,xmm6,xmm6
    6b13:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    6b17:	c5 c1 58 fe          	vaddpd xmm7,xmm7,xmm6
    6b1b:	c5 33 58 c8          	vaddsd xmm9,xmm9,xmm0
    6b1f:	c5 f9 11 39          	vmovupd XMMWORD PTR [rcx],xmm7
    6b23:	c5 7b 11 49 10       	vmovsd QWORD PTR [rcx+0x10],xmm9
    6b28:	e9 93 fe ff ff       	jmp    69c0 <c_run_1.constprop.0+0x90>
    6b2d:	0f 1f 00             	nop    DWORD PTR [rax]
    6b30:	c5 eb 5e c0          	vdivsd xmm0,xmm2,xmm0
    6b34:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    6b39:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    6b3e:	c5 fd 11 41 18       	vmovupd YMMWORD PTR [rcx+0x18],ymm0
    6b43:	e9 1d fe ff ff       	jmp    6965 <c_run_1.constprop.0+0x35>
    6b48:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    6b4f:	00 
    6b50:	c5 f8 77             	vzeroupper
    6b53:	c3                   	ret
    6b54:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    6b5b:	00 00 00 
    6b5e:	66 90                	xchg   ax,ax

0000000000006b60 <c_run_1>:
    6b60:	48 89 f0             	mov    rax,rsi
    6b63:	89 fe                	mov    esi,edi
    6b65:	c5 fb 10 1d cb 8e 02 	vmovsd xmm3,QWORD PTR [rip+0x28ecb]        # 2fa38 <system__os_lib__standin+0xc>
    6b6c:	00 
    6b6d:	c5 fb 10 15 eb 6c 02 	vmovsd xmm2,QWORD PTR [rip+0x26ceb]        # 2d860 <__gnat_ada_main_program_name+0x18>
    6b74:	00 
    6b75:	48 6b f6 38          	imul   rsi,rsi,0x38
    6b79:	c5 fd 28 2d df 6c 02 	vmovapd ymm5,YMMWORD PTR [rip+0x26cdf]        # 2d860 <__gnat_ada_main_program_name+0x18>
    6b80:	00 
    6b81:	c5 d9 57 e4          	vxorpd xmm4,xmm4,xmm4
    6b85:	4c 01 c6             	add    rsi,r8
    6b88:	e9 94 00 00 00       	jmp    6c21 <c_run_1+0xc1>
    6b8d:	0f 1f 00             	nop    DWORD PTR [rax]
    6b90:	c4 c1 7d 11 68 18    	vmovupd YMMWORD PTR [r8+0x18],ymm5
    6b96:	c5 f9 10 48 18       	vmovupd xmm1,XMMWORD PTR [rax+0x18]
    6b9b:	c5 79 28 50 20       	vmovapd xmm10,XMMWORD PTR [rax+0x20]
    6ba0:	c5 f9 10 42 08       	vmovupd xmm0,XMMWORD PTR [rdx+0x8]
    6ba5:	c5 f9 10 70 28       	vmovupd xmm6,XMMWORD PTR [rax+0x28]
    6baa:	c5 f9 28 3a          	vmovapd xmm7,XMMWORD PTR [rdx]
    6bae:	c5 f9 2f ca          	vcomisd xmm1,xmm2
    6bb2:	c4 41 29 15 f2       	vunpckhpd xmm14,xmm10,xmm10
    6bb7:	c4 41 79 28 ea       	vmovapd xmm13,xmm10
    6bbc:	c5 79 15 c8          	vunpckhpd xmm9,xmm0,xmm0
    6bc0:	0f 85 2a 01 00 00    	jne    6cf0 <c_run_1+0x190>
    6bc6:	c5 79 2f d4          	vcomisd xmm10,xmm4
    6bca:	0f 85 20 01 00 00    	jne    6cf0 <c_run_1+0x190>
    6bd0:	c5 79 2f f4          	vcomisd xmm14,xmm4
    6bd4:	0f 85 16 01 00 00    	jne    6cf0 <c_run_1+0x190>
    6bda:	c5 49 15 c6          	vunpckhpd xmm8,xmm6,xmm6
    6bde:	c5 79 2f c4          	vcomisd xmm8,xmm4
    6be2:	0f 85 08 01 00 00    	jne    6cf0 <c_run_1+0x190>
    6be8:	c4 c1 79 11 38       	vmovupd XMMWORD PTR [r8],xmm7
    6bed:	c4 41 7b 11 48 10    	vmovsd QWORD PTR [r8+0x10],xmm9
    6bf3:	66 90                	xchg   ax,ax
    6bf5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6bfc:	00 00 00 00 
    6c00:	c5 c1 58 38          	vaddpd xmm7,xmm7,XMMWORD PTR [rax]
    6c04:	c5 33 58 48 10       	vaddsd xmm9,xmm9,QWORD PTR [rax+0x10]
    6c09:	c4 c1 79 11 38       	vmovupd XMMWORD PTR [r8],xmm7
    6c0e:	c4 41 7b 11 48 10    	vmovsd QWORD PTR [r8+0x10],xmm9
    6c14:	49 83 c0 38          	add    r8,0x38
    6c18:	4c 39 c6             	cmp    rsi,r8
    6c1b:	0f 84 6f 01 00 00    	je     6d90 <c_run_1+0x230>
    6c21:	c5 fd 10 48 18       	vmovupd ymm1,YMMWORD PTR [rax+0x18]
    6c26:	c5 fd 10 42 18       	vmovupd ymm0,YMMWORD PTR [rdx+0x18]
    6c2b:	c4 e2 7d 19 f1       	vbroadcastsd ymm6,xmm1
    6c30:	c4 63 fd 01 c0 4e    	vpermpd ymm8,ymm0,0x4e
    6c36:	c4 e3 fd 01 f8 1b    	vpermpd ymm7,ymm0,0x1b
    6c3c:	c4 63 fd 01 c9 55    	vpermpd ymm9,ymm1,0x55
    6c42:	c5 cd 59 f0          	vmulpd ymm6,ymm6,ymm0
    6c46:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    6c4c:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    6c51:	c5 cd d0 f0          	vaddsubpd ymm6,ymm6,ymm0
    6c55:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    6c5b:	c4 e3 fd 01 c9 ff    	vpermpd ymm1,ymm1,0xff
    6c61:	c4 c1 7d 59 c0       	vmulpd ymm0,ymm0,ymm8
    6c66:	c5 f5 59 cf          	vmulpd ymm1,ymm1,ymm7
    6c6a:	c5 4d 5c c0          	vsubpd ymm8,ymm6,ymm0
    6c6e:	c5 fd 58 c6          	vaddpd ymm0,ymm0,ymm6
    6c72:	c4 c3 7d 0d c0 09    	vblendpd ymm0,ymm0,ymm8,0x9
    6c78:	c5 75 58 c8          	vaddpd ymm9,ymm1,ymm0
    6c7c:	c5 fd 5c c9          	vsubpd ymm1,ymm0,ymm1
    6c80:	62 73 fd 28 19 cf 01 	vextractf64x2 xmm7,ymm9,0x1
    6c87:	c5 71 15 c1          	vunpckhpd xmm8,xmm1,xmm1
    6c8b:	c5 f3 59 c1          	vmulsd xmm0,xmm1,xmm1
    6c8f:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    6c94:	62 d3 b5 28 03 f1 03 	valignq ymm6,ymm9,ymm9,0x3
    6c9b:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    6ca0:	c5 c3 59 ff          	vmulsd xmm7,xmm7,xmm7
    6ca4:	c5 fb 58 c7          	vaddsd xmm0,xmm0,xmm7
    6ca8:	c5 cb 59 f6          	vmulsd xmm6,xmm6,xmm6
    6cac:	c5 fb 58 c6          	vaddsd xmm0,xmm0,xmm6
    6cb0:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    6cb4:	c5 f9 2f d8          	vcomisd xmm3,xmm0
    6cb8:	0f 87 d2 fe ff ff    	ja     6b90 <c_run_1+0x30>
    6cbe:	c4 63 35 0d c9 03    	vblendpd ymm9,ymm9,ymm1,0x3
    6cc4:	c5 fb 5c ca          	vsubsd xmm1,xmm0,xmm2
    6cc8:	c5 f1 54 0d 70 8e 02 	vandpd xmm1,xmm1,XMMWORD PTR [rip+0x28e70]        # 2fb40 <system__secondary_stack__invalid_memory_size+0xb8>
    6ccf:	00 
    6cd0:	c5 f9 2f cb          	vcomisd xmm1,xmm3
    6cd4:	0f 87 96 00 00 00    	ja     6d70 <c_run_1+0x210>
    6cda:	c4 41 7d 11 48 18    	vmovupd YMMWORD PTR [r8+0x18],ymm9
    6ce0:	e9 b1 fe ff ff       	jmp    6b96 <c_run_1+0x36>
    6ce5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6cec:	00 00 00 00 
    6cf0:	c4 63 79 05 e1 00    	vpermilpd xmm12,xmm1,0x0
    6cf6:	c5 49 15 c1          	vunpckhpd xmm8,xmm6,xmm1
    6cfa:	c5 79 c6 df 01       	vshufpd xmm11,xmm0,xmm7,0x1
    6cff:	c5 b9 59 cf          	vmulpd xmm1,xmm8,xmm7
    6d03:	c4 41 79 59 fc       	vmulpd xmm15,xmm0,xmm12
    6d08:	c4 c1 79 59 c2       	vmulpd xmm0,xmm0,xmm10
    6d0d:	c4 c1 71 58 cf       	vaddpd xmm1,xmm1,xmm15
    6d12:	c4 41 21 59 fa       	vmulpd xmm15,xmm11,xmm10
    6d17:	c4 41 21 59 dc       	vmulpd xmm11,xmm11,xmm12
    6d1c:	c5 49 59 d7          	vmulpd xmm10,xmm6,xmm7
    6d20:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    6d25:	c4 c1 71 5c cf       	vsubpd xmm1,xmm1,xmm15
    6d2a:	c4 c1 79 5c c2       	vsubpd xmm0,xmm0,xmm10
    6d2f:	c4 41 71 59 c0       	vmulpd xmm8,xmm1,xmm8
    6d34:	c4 c1 73 59 cd       	vmulsd xmm1,xmm1,xmm13
    6d39:	c5 c9 59 f0          	vmulpd xmm6,xmm6,xmm0
    6d3d:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    6d41:	c4 c1 7b 59 c6       	vmulsd xmm0,xmm0,xmm14
    6d46:	c4 c1 49 5c f0       	vsubpd xmm6,xmm6,xmm8
    6d4b:	c5 f3 5c c0          	vsubsd xmm0,xmm1,xmm0
    6d4f:	c5 c9 58 f6          	vaddpd xmm6,xmm6,xmm6
    6d53:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    6d57:	c5 c1 58 fe          	vaddpd xmm7,xmm7,xmm6
    6d5b:	c5 33 58 c8          	vaddsd xmm9,xmm9,xmm0
    6d5f:	c4 c1 79 11 38       	vmovupd XMMWORD PTR [r8],xmm7
    6d64:	c4 41 7b 11 48 10    	vmovsd QWORD PTR [r8+0x10],xmm9
    6d6a:	e9 91 fe ff ff       	jmp    6c00 <c_run_1+0xa0>
    6d6f:	90                   	nop
    6d70:	c5 eb 5e c0          	vdivsd xmm0,xmm2,xmm0
    6d74:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    6d79:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    6d7e:	c4 c1 7d 11 40 18    	vmovupd YMMWORD PTR [r8+0x18],ymm0
    6d84:	e9 0d fe ff ff       	jmp    6b96 <c_run_1+0x36>
    6d89:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    6d90:	c5 f8 77             	vzeroupper
    6d93:	c3                   	ret
    6d94:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    6d9b:	00 00 00 
    6d9e:	66 90                	xchg   ax,ax

0000000000006da0 <c_run_2.constprop.0>:
    6da0:	55                   	push   rbp
    6da1:	48 89 c8             	mov    rax,rcx
    6da4:	4c 8d 89 c0 01 00 00 	lea    r9,[rcx+0x1c0]
    6dab:	c5 d9 57 e4          	vxorpd xmm4,xmm4,xmm4
    6daf:	48 89 e5             	mov    rbp,rsp
    6db2:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    6db6:	c5 fb 10 2d 7a 8c 02 	vmovsd xmm5,QWORD PTR [rip+0x28c7a]        # 2fa38 <system__os_lib__standin+0xc>
    6dbd:	00 
    6dbe:	c5 fb 10 35 9a 6a 02 	vmovsd xmm6,QWORD PTR [rip+0x26a9a]        # 2d860 <__gnat_ada_main_program_name+0x18>
    6dc5:	00 
    6dc6:	c5 fd 28 3d 92 6a 02 	vmovapd ymm7,YMMWORD PTR [rip+0x26a92]        # 2d860 <__gnat_ada_main_program_name+0x18>
    6dcd:	00 
    6dce:	e9 e6 00 00 00       	jmp    6eb9 <c_run_2.constprop.0+0x119>
    6dd3:	66 90                	xchg   ax,ax
    6dd5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6ddc:	00 00 00 00 
    6de0:	c5 fd 11 78 18       	vmovupd YMMWORD PTR [rax+0x18],ymm7
    6de5:	c5 f9 10 56 08       	vmovupd xmm2,XMMWORD PTR [rsi+0x8]
    6dea:	c5 79 2f f4          	vcomisd xmm14,xmm4
    6dee:	c5 79 28 0e          	vmovapd xmm9,XMMWORD PTR [rsi]
    6df2:	41 0f 94 c0          	sete   r8b
    6df6:	c5 79 2f ec          	vcomisd xmm13,xmm4
    6dfa:	0f 94 c1             	sete   cl
    6dfd:	c5 69 15 d2          	vunpckhpd xmm10,xmm2,xmm2
    6e01:	41 84 c8             	test   r8b,cl
    6e04:	74 16                	je     6e1c <c_run_2.constprop.0+0x7c>
    6e06:	62 e1 fd 08 2f c6    	vcomisd xmm16,xmm6
    6e0c:	41 0f 94 c0          	sete   r8b
    6e10:	c5 79 2f fc          	vcomisd xmm15,xmm4
    6e14:	0f 94 c1             	sete   cl
    6e17:	41 84 c8             	test   r8b,cl
    6e1a:	75 7b                	jne    6e97 <c_run_2.constprop.0+0xf7>
    6e1c:	c5 7b 12 2e          	vmovddup xmm13,QWORD PTR [rsi]
    6e20:	c5 61 15 e1          	vunpckhpd xmm12,xmm3,xmm1
    6e24:	c4 e3 79 05 c1 00    	vpermilpd xmm0,xmm1,0x0
    6e2a:	c4 41 31 59 f4       	vmulpd xmm14,xmm9,xmm12
    6e2f:	c5 79 59 c2          	vmulpd xmm8,xmm0,xmm2
    6e33:	c4 41 39 58 c6       	vaddpd xmm8,xmm8,xmm14
    6e38:	c4 41 69 15 ed       	vunpckhpd xmm13,xmm2,xmm13
    6e3d:	c4 41 11 59 f3       	vmulpd xmm14,xmm13,xmm11
    6e42:	c4 c1 79 59 c5       	vmulpd xmm0,xmm0,xmm13
    6e47:	c5 21 59 da          	vmulpd xmm11,xmm11,xmm2
    6e4b:	c5 b1 59 d3          	vmulpd xmm2,xmm9,xmm3
    6e4f:	c4 41 39 5c c6       	vsubpd xmm8,xmm8,xmm14
    6e54:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    6e59:	c4 41 19 59 e0       	vmulpd xmm12,xmm12,xmm8
    6e5e:	c5 f9 5c c2          	vsubpd xmm0,xmm0,xmm2
    6e62:	c5 f1 15 d1          	vunpckhpd xmm2,xmm1,xmm1
    6e66:	62 f3 fd 28 19 c9 01 	vextractf64x2 xmm1,ymm1,0x1
    6e6d:	c4 c1 6b 59 d0       	vmulsd xmm2,xmm2,xmm8
    6e72:	c5 f9 59 db          	vmulpd xmm3,xmm0,xmm3
    6e76:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    6e7a:	c5 f3 59 c8          	vmulsd xmm1,xmm1,xmm0
    6e7e:	c4 c1 61 5c dc       	vsubpd xmm3,xmm3,xmm12
    6e83:	c5 eb 5c c1          	vsubsd xmm0,xmm2,xmm1
    6e87:	c5 e1 58 db          	vaddpd xmm3,xmm3,xmm3
    6e8b:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    6e8f:	c5 31 58 cb          	vaddpd xmm9,xmm9,xmm3
    6e93:	c5 2b 58 d0          	vaddsd xmm10,xmm10,xmm0
    6e97:	c5 31 58 4c 24 c0    	vaddpd xmm9,xmm9,XMMWORD PTR [rsp-0x40]
    6e9d:	c5 2b 58 54 24 d0    	vaddsd xmm10,xmm10,QWORD PTR [rsp-0x30]
    6ea3:	c5 79 11 08          	vmovupd XMMWORD PTR [rax],xmm9
    6ea7:	c5 7b 11 50 10       	vmovsd QWORD PTR [rax+0x10],xmm10
    6eac:	48 83 c0 38          	add    rax,0x38
    6eb0:	49 39 c1             	cmp    r9,rax
    6eb3:	0f 84 27 01 00 00    	je     6fe0 <c_run_2.constprop.0+0x240>
    6eb9:	c5 fe 6f 00          	vmovdqu ymm0,YMMWORD PTR [rax]
    6ebd:	c5 fe 6f 48 18       	vmovdqu ymm1,YMMWORD PTR [rax+0x18]
    6ec2:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    6ec8:	c5 fd 10 46 18       	vmovupd ymm0,YMMWORD PTR [rsi+0x18]
    6ecd:	c4 e2 7d 19 d1       	vbroadcastsd ymm2,xmm1
    6ed2:	c4 e3 fd 01 d9 55    	vpermpd ymm3,ymm1,0x55
    6ed8:	c5 fe 7f 4c 24 d8    	vmovdqu YMMWORD PTR [rsp-0x28],ymm1
    6ede:	62 e1 ff 08 10 44 24 	vmovsd xmm16,QWORD PTR [rsp-0x28]
    6ee5:	fb 
    6ee6:	c5 79 28 5c 24 e0    	vmovapd xmm11,XMMWORD PTR [rsp-0x20]
    6eec:	c5 7b 10 7c 24 e0    	vmovsd xmm15,QWORD PTR [rsp-0x20]
    6ef2:	c5 7b 10 6c 24 e8    	vmovsd xmm13,QWORD PTR [rsp-0x18]
    6ef8:	c5 7b 10 74 24 f0    	vmovsd xmm14,QWORD PTR [rsp-0x10]
    6efe:	c4 63 fd 01 c8 4e    	vpermpd ymm9,ymm0,0x4e
    6f04:	c5 ed 59 d0          	vmulpd ymm2,ymm2,ymm0
    6f08:	c4 63 fd 01 c0 1b    	vpermpd ymm8,ymm0,0x1b
    6f0e:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    6f14:	c5 fd 59 c3          	vmulpd ymm0,ymm0,ymm3
    6f18:	c5 f9 10 5c 24 e8    	vmovupd xmm3,XMMWORD PTR [rsp-0x18]
    6f1e:	c5 ed d0 d0          	vaddsubpd ymm2,ymm2,ymm0
    6f22:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    6f28:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    6f2d:	c5 6d 5c c8          	vsubpd ymm9,ymm2,ymm0
    6f31:	c5 fd 58 c2          	vaddpd ymm0,ymm0,ymm2
    6f35:	c4 e3 fd 01 d1 ff    	vpermpd ymm2,ymm1,0xff
    6f3b:	c4 c1 6d 59 d0       	vmulpd ymm2,ymm2,ymm8
    6f40:	c4 c3 7d 0d c1 09    	vblendpd ymm0,ymm0,ymm9,0x9
    6f46:	c5 6d 58 e0          	vaddpd ymm12,ymm2,ymm0
    6f4a:	c5 fd 5c d2          	vsubpd ymm2,ymm0,ymm2
    6f4e:	62 53 fd 28 19 e1 01 	vextractf64x2 xmm9,ymm12,0x1
    6f55:	c5 69 15 d2          	vunpckhpd xmm10,xmm2,xmm2
    6f59:	c5 eb 59 c2          	vmulsd xmm0,xmm2,xmm2
    6f5d:	c4 41 2b 59 d2       	vmulsd xmm10,xmm10,xmm10
    6f62:	62 53 9d 28 03 c4 03 	valignq ymm8,ymm12,ymm12,0x3
    6f69:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    6f6e:	c4 41 33 59 c9       	vmulsd xmm9,xmm9,xmm9
    6f73:	c4 c1 7b 58 c1       	vaddsd xmm0,xmm0,xmm9
    6f78:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    6f7d:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    6f82:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    6f86:	c5 f9 2f e8          	vcomisd xmm5,xmm0
    6f8a:	0f 87 50 fe ff ff    	ja     6de0 <c_run_2.constprop.0+0x40>
    6f90:	c4 63 1d 0d e2 03    	vblendpd ymm12,ymm12,ymm2,0x3
    6f96:	c5 fb 5c d6          	vsubsd xmm2,xmm0,xmm6
    6f9a:	c5 e9 54 15 9e 8b 02 	vandpd xmm2,xmm2,XMMWORD PTR [rip+0x28b9e]        # 2fb40 <system__secondary_stack__invalid_memory_size+0xb8>
    6fa1:	00 
    6fa2:	c5 f9 2f d5          	vcomisd xmm2,xmm5
    6fa6:	77 18                	ja     6fc0 <c_run_2.constprop.0+0x220>
    6fa8:	c5 7d 11 60 18       	vmovupd YMMWORD PTR [rax+0x18],ymm12
    6fad:	e9 33 fe ff ff       	jmp    6de5 <c_run_2.constprop.0+0x45>
    6fb2:	0f 1f 00             	nop    DWORD PTR [rax]
    6fb5:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6fbc:	00 00 00 00 
    6fc0:	c5 cb 5e c0          	vdivsd xmm0,xmm6,xmm0
    6fc4:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    6fc9:	c4 c1 7d 59 c4       	vmulpd ymm0,ymm0,ymm12
    6fce:	c5 fd 11 40 18       	vmovupd YMMWORD PTR [rax+0x18],ymm0
    6fd3:	e9 0d fe ff ff       	jmp    6de5 <c_run_2.constprop.0+0x45>
    6fd8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    6fdf:	00 
    6fe0:	c5 f8 77             	vzeroupper
    6fe3:	c9                   	leave
    6fe4:	c3                   	ret
    6fe5:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    6fec:	00 00 00 
    6fef:	90                   	nop

0000000000007080 <c_run_2>:
    7080:	41 89 f9             	mov    r9d,edi
    7083:	55                   	push   rbp
    7084:	48 89 d0             	mov    rax,rdx
    7087:	c5 d9 57 e4          	vxorpd xmm4,xmm4,xmm4
    708b:	4d 6b c9 38          	imul   r9,r9,0x38
    708f:	48 89 e5             	mov    rbp,rsp
    7092:	48 89 ca             	mov    rdx,rcx
    7095:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    7099:	4d 01 c1             	add    r9,r8
    709c:	c5 fb 10 2d 94 89 02 	vmovsd xmm5,QWORD PTR [rip+0x28994]        # 2fa38 <system__os_lib__standin+0xc>
    70a3:	00 
    70a4:	c5 fb 10 35 b4 67 02 	vmovsd xmm6,QWORD PTR [rip+0x267b4]        # 2d860 <__gnat_ada_main_program_name+0x18>
    70ab:	00 
    70ac:	c5 fd 28 3d ac 67 02 	vmovapd ymm7,YMMWORD PTR [rip+0x267ac]        # 2d860 <__gnat_ada_main_program_name+0x18>
    70b3:	00 
    70b4:	e9 e3 00 00 00       	jmp    719c <c_run_2+0x11c>
    70b9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    70c0:	c4 c1 7d 11 78 18    	vmovupd YMMWORD PTR [r8+0x18],ymm7
    70c6:	c5 f9 10 50 08       	vmovupd xmm2,XMMWORD PTR [rax+0x8]
    70cb:	c5 79 2f f4          	vcomisd xmm14,xmm4
    70cf:	c5 79 28 08          	vmovapd xmm9,XMMWORD PTR [rax]
    70d3:	40 0f 94 c7          	sete   dil
    70d7:	c5 79 2f ec          	vcomisd xmm13,xmm4
    70db:	0f 94 c1             	sete   cl
    70de:	c5 69 15 d2          	vunpckhpd xmm10,xmm2,xmm2
    70e2:	40 84 cf             	test   dil,cl
    70e5:	74 16                	je     70fd <c_run_2+0x7d>
    70e7:	62 e1 fd 08 2f c6    	vcomisd xmm16,xmm6
    70ed:	40 0f 94 c7          	sete   dil
    70f1:	c5 79 2f fc          	vcomisd xmm15,xmm4
    70f5:	0f 94 c1             	sete   cl
    70f8:	40 84 cf             	test   dil,cl
    70fb:	75 7b                	jne    7178 <c_run_2+0xf8>
    70fd:	c5 7b 12 28          	vmovddup xmm13,QWORD PTR [rax]
    7101:	c5 61 15 e1          	vunpckhpd xmm12,xmm3,xmm1
    7105:	c4 e3 79 05 c1 00    	vpermilpd xmm0,xmm1,0x0
    710b:	c4 41 31 59 f4       	vmulpd xmm14,xmm9,xmm12
    7110:	c5 79 59 c2          	vmulpd xmm8,xmm0,xmm2
    7114:	c4 41 39 58 c6       	vaddpd xmm8,xmm8,xmm14
    7119:	c4 41 69 15 ed       	vunpckhpd xmm13,xmm2,xmm13
    711e:	c4 41 11 59 f3       	vmulpd xmm14,xmm13,xmm11
    7123:	c4 c1 79 59 c5       	vmulpd xmm0,xmm0,xmm13
    7128:	c5 21 59 da          	vmulpd xmm11,xmm11,xmm2
    712c:	c5 b1 59 d3          	vmulpd xmm2,xmm9,xmm3
    7130:	c4 41 39 5c c6       	vsubpd xmm8,xmm8,xmm14
    7135:	c4 c1 79 58 c3       	vaddpd xmm0,xmm0,xmm11
    713a:	c4 41 19 59 e0       	vmulpd xmm12,xmm12,xmm8
    713f:	c5 f9 5c c2          	vsubpd xmm0,xmm0,xmm2
    7143:	c5 f1 15 d1          	vunpckhpd xmm2,xmm1,xmm1
    7147:	62 f3 fd 28 19 c9 01 	vextractf64x2 xmm1,ymm1,0x1
    714e:	c4 c1 6b 59 d0       	vmulsd xmm2,xmm2,xmm8
    7153:	c5 f9 59 db          	vmulpd xmm3,xmm0,xmm3
    7157:	c5 f9 15 c0          	vunpckhpd xmm0,xmm0,xmm0
    715b:	c5 f3 59 c8          	vmulsd xmm1,xmm1,xmm0
    715f:	c4 c1 61 5c dc       	vsubpd xmm3,xmm3,xmm12
    7164:	c5 eb 5c c1          	vsubsd xmm0,xmm2,xmm1
    7168:	c5 e1 58 db          	vaddpd xmm3,xmm3,xmm3
    716c:	c5 fb 58 c0          	vaddsd xmm0,xmm0,xmm0
    7170:	c5 31 58 cb          	vaddpd xmm9,xmm9,xmm3
    7174:	c5 2b 58 d0          	vaddsd xmm10,xmm10,xmm0
    7178:	c5 31 58 4c 24 c0    	vaddpd xmm9,xmm9,XMMWORD PTR [rsp-0x40]
    717e:	c5 2b 58 54 24 d0    	vaddsd xmm10,xmm10,QWORD PTR [rsp-0x30]
    7184:	c4 41 79 11 08       	vmovupd XMMWORD PTR [r8],xmm9
    7189:	c4 41 7b 11 50 10    	vmovsd QWORD PTR [r8+0x10],xmm10
    718f:	49 83 c0 38          	add    r8,0x38
    7193:	4d 39 c1             	cmp    r9,r8
    7196:	0f 84 24 01 00 00    	je     72c0 <c_run_2+0x240>
    719c:	c4 c1 7e 6f 00       	vmovdqu ymm0,YMMWORD PTR [r8]
    71a1:	c4 c1 7e 6f 48 18    	vmovdqu ymm1,YMMWORD PTR [r8+0x18]
    71a7:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    71ad:	c5 fd 10 40 18       	vmovupd ymm0,YMMWORD PTR [rax+0x18]
    71b2:	c4 e2 7d 19 d1       	vbroadcastsd ymm2,xmm1
    71b7:	c4 e3 fd 01 d9 55    	vpermpd ymm3,ymm1,0x55
    71bd:	c5 fe 7f 4c 24 d8    	vmovdqu YMMWORD PTR [rsp-0x28],ymm1
    71c3:	62 e1 ff 08 10 44 24 	vmovsd xmm16,QWORD PTR [rsp-0x28]
    71ca:	fb 
    71cb:	c5 79 28 5c 24 e0    	vmovapd xmm11,XMMWORD PTR [rsp-0x20]
    71d1:	c5 7b 10 7c 24 e0    	vmovsd xmm15,QWORD PTR [rsp-0x20]
    71d7:	c5 7b 10 6c 24 e8    	vmovsd xmm13,QWORD PTR [rsp-0x18]
    71dd:	c5 7b 10 74 24 f0    	vmovsd xmm14,QWORD PTR [rsp-0x10]
    71e3:	c4 63 fd 01 c8 4e    	vpermpd ymm9,ymm0,0x4e
    71e9:	c5 ed 59 d0          	vmulpd ymm2,ymm2,ymm0
    71ed:	c4 63 fd 01 c0 1b    	vpermpd ymm8,ymm0,0x1b
    71f3:	c4 e3 7d 05 c0 05    	vpermilpd ymm0,ymm0,0x5
    71f9:	c5 fd 59 c3          	vmulpd ymm0,ymm0,ymm3
    71fd:	c5 f9 10 5c 24 e8    	vmovupd xmm3,XMMWORD PTR [rsp-0x18]
    7203:	c5 ed d0 d0          	vaddsubpd ymm2,ymm2,ymm0
    7207:	c4 e3 fd 01 c1 aa    	vpermpd ymm0,ymm1,0xaa
    720d:	c4 c1 7d 59 c1       	vmulpd ymm0,ymm0,ymm9
    7212:	c5 6d 5c c8          	vsubpd ymm9,ymm2,ymm0
    7216:	c5 fd 58 c2          	vaddpd ymm0,ymm0,ymm2
    721a:	c4 e3 fd 01 d1 ff    	vpermpd ymm2,ymm1,0xff
    7220:	c4 c1 6d 59 d0       	vmulpd ymm2,ymm2,ymm8
    7225:	c4 c3 7d 0d c1 09    	vblendpd ymm0,ymm0,ymm9,0x9
    722b:	c5 6d 58 e0          	vaddpd ymm12,ymm2,ymm0
    722f:	c5 fd 5c d2          	vsubpd ymm2,ymm0,ymm2
    7233:	62 53 fd 28 19 e1 01 	vextractf64x2 xmm9,ymm12,0x1
    723a:	c5 69 15 d2          	vunpckhpd xmm10,xmm2,xmm2
    723e:	c5 eb 59 c2          	vmulsd xmm0,xmm2,xmm2
    7242:	c4 41 2b 59 d2       	vmulsd xmm10,xmm10,xmm10
    7247:	62 53 9d 28 03 c4 03 	valignq ymm8,ymm12,ymm12,0x3
    724e:	c4 c1 7b 58 c2       	vaddsd xmm0,xmm0,xmm10
    7253:	c4 41 33 59 c9       	vmulsd xmm9,xmm9,xmm9
    7258:	c4 c1 7b 58 c1       	vaddsd xmm0,xmm0,xmm9
    725d:	c4 41 3b 59 c0       	vmulsd xmm8,xmm8,xmm8
    7262:	c4 c1 7b 58 c0       	vaddsd xmm0,xmm0,xmm8
    7267:	c5 fb 51 c0          	vsqrtsd xmm0,xmm0,xmm0
    726b:	c5 f9 2f e8          	vcomisd xmm5,xmm0
    726f:	0f 87 4b fe ff ff    	ja     70c0 <c_run_2+0x40>
    7275:	c4 63 1d 0d e2 03    	vblendpd ymm12,ymm12,ymm2,0x3
    727b:	c5 fb 5c d6          	vsubsd xmm2,xmm0,xmm6
    727f:	c5 e9 54 15 b9 88 02 	vandpd xmm2,xmm2,XMMWORD PTR [rip+0x288b9]        # 2fb40 <system__secondary_stack__invalid_memory_size+0xb8>
    7286:	00 
    7287:	c5 f9 2f d5          	vcomisd xmm2,xmm5
    728b:	77 13                	ja     72a0 <c_run_2+0x220>
    728d:	c4 41 7d 11 60 18    	vmovupd YMMWORD PTR [r8+0x18],ymm12
    7293:	e9 2e fe ff ff       	jmp    70c6 <c_run_2+0x46>
    7298:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    729f:	00 
    72a0:	c5 cb 5e c0          	vdivsd xmm0,xmm6,xmm0
    72a4:	c4 e2 7d 19 c0       	vbroadcastsd ymm0,xmm0
    72a9:	c4 c1 7d 59 c4       	vmulpd ymm0,ymm0,ymm12
    72ae:	c4 c1 7d 11 40 18    	vmovupd YMMWORD PTR [r8+0x18],ymm0
    72b4:	e9 0d fe ff ff       	jmp    70c6 <c_run_2+0x46>
    72b9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    72c0:	c5 f8 77             	vzeroupper
    72c3:	c9                   	leave
    72c4:	c3                   	ret
    72c5:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
    72cc:	00 00 00 
    72cf:	90                   	nop
