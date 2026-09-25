
/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/tests/rotations/build/release/bin/main:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

0000000000005f30 <rotation_run>:
    5f30:	48 89 c8             	mov    %rcx,%rax
    5f33:	83 ff 08             	cmp    $0x8,%edi
    5f36:	0f 87 06 01 00 00    	ja     6042 <rotation_run+0x112>
    5f3c:	4c 8d 15 fd 73 02 00 	lea    0x273fd(%rip),%r10        # 2d340 <_fini+0x154>
    5f43:	89 ff                	mov    %edi,%edi
    5f45:	c5 e1 ef db          	vpxor  %xmm3,%xmm3,%xmm3
    5f49:	49 63 0c ba          	movslq (%r10,%rdi,4),%rcx
    5f4d:	4c 01 d1             	add    %r10,%rcx
    5f50:	ff e1                	jmp    *%rcx
    5f52:	0f 1f 00             	nopl   (%rax)
    5f55:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    5f5c:	00 00 00 00
    5f60:	c5 fb 10 02          	vmovsd (%rdx),%xmm0
    5f64:	c4 c1 79 2f c4       	vcomisd %xmm12,%xmm0
    5f69:	0f 85 67 0b 00 00    	jne    6ad6 <rotation_run+0xba6>
    5f6f:	c5 7b 10 4a 08       	vmovsd 0x8(%rdx),%xmm9
    5f74:	c4 41 79 2f cb       	vcomisd %xmm11,%xmm9
    5f79:	c5 79 29 c8          	vmovapd %xmm9,%xmm0
    5f7d:	0f 84 86 02 00 00    	je     6209 <rotation_run+0x2d9>
    5f83:	c4 c1 79 2f eb       	vcomisd %xmm11,%xmm5
    5f88:	c4 c1 7b 10 79 10    	vmovsd 0x10(%r9),%xmm7
    5f8e:	0f 84 cc 06 00 00    	je     6660 <rotation_run+0x730>
    5f94:	c5 7b 10 52 10       	vmovsd 0x10(%rdx),%xmm10
    5f99:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    5f9e:	c5 79 28 c7          	vmovapd %xmm7,%xmm8
    5fa2:	c5 f9 28 e5          	vmovapd %xmm5,%xmm4
    5fa6:	c5 79 28 ee          	vmovapd %xmm6,%xmm13
    5faa:	c4 c1 43 59 d2       	vmulsd %xmm10,%xmm7,%xmm2
    5faf:	c5 d3 59 c1          	vmulsd %xmm1,%xmm5,%xmm0
    5fb3:	c4 c1 6b 58 d5       	vaddsd %xmm13,%xmm2,%xmm2
    5fb8:	c5 eb 5c d0          	vsubsd %xmm0,%xmm2,%xmm2
    5fbc:	c5 cb 59 c1          	vmulsd %xmm1,%xmm6,%xmm0
    5fc0:	c5 fb 58 c4          	vaddsd %xmm4,%xmm0,%xmm0
    5fc4:	c4 c1 43 59 e1       	vmulsd %xmm9,%xmm7,%xmm4
    5fc9:	c5 fb 5c c4          	vsubsd %xmm4,%xmm0,%xmm0
    5fcd:	c4 c1 53 59 e1       	vmulsd %xmm9,%xmm5,%xmm4
    5fd2:	c4 c1 5b 58 e0       	vaddsd %xmm8,%xmm4,%xmm4
    5fd7:	c4 41 4b 59 c2       	vmulsd %xmm10,%xmm6,%xmm8
    5fdc:	c5 7b 59 e9          	vmulsd %xmm1,%xmm0,%xmm13
    5fe0:	c5 eb 59 c9          	vmulsd %xmm1,%xmm2,%xmm1
    5fe4:	c4 c1 7b 59 c1       	vmulsd %xmm9,%xmm0,%xmm0
    5fe9:	c4 c1 6b 59 d2       	vmulsd %xmm10,%xmm2,%xmm2
    5fee:	c4 c1 5b 5c e0       	vsubsd %xmm8,%xmm4,%xmm4
    5ff3:	c5 fb 5c c2          	vsubsd %xmm2,%xmm0,%xmm0
    5ff7:	c4 41 5b 59 c2       	vmulsd %xmm10,%xmm4,%xmm8
    5ffc:	c4 c1 5b 59 e1       	vmulsd %xmm9,%xmm4,%xmm4
    6001:	c5 fb 58 c0          	vaddsd %xmm0,%xmm0,%xmm0
    6005:	c4 41 3b 5c c5       	vsubsd %xmm13,%xmm8,%xmm8
    600a:	c5 f3 5c cc          	vsubsd %xmm4,%xmm1,%xmm1
    600e:	c5 c3 58 f8          	vaddsd %xmm0,%xmm7,%xmm7
    6012:	c4 41 3b 58 c0       	vaddsd %xmm8,%xmm8,%xmm8
    6017:	c5 f3 58 c9          	vaddsd %xmm1,%xmm1,%xmm1
    601b:	c4 c1 4b 58 f0       	vaddsd %xmm8,%xmm6,%xmm6
    6020:	c5 d3 58 e9          	vaddsd %xmm1,%xmm5,%xmm5
    6024:	c4 c1 7b 11 31       	vmovsd %xmm6,(%r9)
    6029:	c4 c1 7b 11 69 08    	vmovsd %xmm5,0x8(%r9)
    602f:	c4 c1 7b 11 79 10    	vmovsd %xmm7,0x10(%r9)
    6035:	49 83 c1 18          	add    $0x18,%r9
    6039:	49 39 c9             	cmp    %rcx,%r9
    603c:	0f 85 6e 01 00 00    	jne    61b0 <rotation_run+0x280>
    6042:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    6046:	c3                   	ret
    6047:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    604e:	00 00
    6050:	89 f6                	mov    %esi,%esi
    6052:	48 8d 0c 76          	lea    (%rsi,%rsi,2),%rcx
    6056:	49 8d 0c c9          	lea    (%r9,%rcx,8),%rcx
    605a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    6060:	c4 c1 79 10 01       	vmovupd (%r9),%xmm0
    6065:	c5 fb 10 48 10       	vmovsd 0x10(%rax),%xmm1
    606a:	c4 c1 7b 10 59 10    	vmovsd 0x10(%r9),%xmm3
    6070:	c5 f9 15 d0          	vunpckhpd %xmm0,%xmm0,%xmm2
    6074:	c5 eb 59 50 28       	vmulsd 0x28(%rax),%xmm2,%xmm2
    6079:	c5 f3 59 c8          	vmulsd %xmm0,%xmm1,%xmm1
    607d:	c5 f3 58 ca          	vaddsd %xmm2,%xmm1,%xmm1
    6081:	c5 e3 59 50 40       	vmulsd 0x40(%rax),%xmm3,%xmm2
    6086:	c5 fb 12 db          	vmovddup %xmm3,%xmm3
    608a:	c5 e1 59 58 30       	vmulpd 0x30(%rax),%xmm3,%xmm3
    608f:	c5 f3 58 ca          	vaddsd %xmm2,%xmm1,%xmm1
    6093:	c4 e3 79 05 d0 03    	vpermilpd $0x3,%xmm0,%xmm2
    6099:	c4 e3 79 05 c0 00    	vpermilpd $0x0,%xmm0,%xmm0
    609f:	c5 e9 59 50 18       	vmulpd 0x18(%rax),%xmm2,%xmm2
    60a4:	c5 f9 59 00          	vmulpd (%rax),%xmm0,%xmm0
    60a8:	c4 c1 7b 11 49 10    	vmovsd %xmm1,0x10(%r9)
    60ae:	c5 e9 58 c0          	vaddpd %xmm0,%xmm2,%xmm0
    60b2:	c5 f9 58 c3          	vaddpd %xmm3,%xmm0,%xmm0
    60b6:	c4 c1 79 11 01       	vmovupd %xmm0,(%r9)
    60bb:	49 83 c1 18          	add    $0x18,%r9
    60bf:	4c 39 c9             	cmp    %r9,%rcx
    60c2:	75 9c                	jne    6060 <rotation_run+0x130>
    60c4:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    60c8:	c3                   	ret
    60c9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    60d0:	89 f6                	mov    %esi,%esi
    60d2:	c5 7b 10 1d e6 72 02 	vmovsd 0x272e6(%rip),%xmm11        # 2d3c0 <__gnat_ada_main_program_name+0x38>
    60d9:	00
    60da:	c4 41 29 57 d2       	vxorpd %xmm10,%xmm10,%xmm10
    60df:	48 8d 0c 76          	lea    (%rsi,%rsi,2),%rcx
    60e3:	49 8d 0c c9          	lea    (%r9,%rcx,8),%rcx
    60e7:	c4 c1 7b 10 10       	vmovsd (%r8),%xmm2
    60ec:	c4 c1 79 2f d2       	vcomisd %xmm10,%xmm2
    60f1:	0f 85 d6 06 00 00    	jne    67cd <rotation_run+0x89d>
    60f7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    60fe:	00 00
    6100:	c4 41 7b 10 60 08    	vmovsd 0x8(%r8),%xmm12
    6106:	c4 41 79 2f e2       	vcomisd %xmm10,%xmm12
    610b:	75 0c                	jne    6119 <rotation_run+0x1e9>
    610d:	c4 41 79 2f 50 10    	vcomisd 0x10(%r8),%xmm10
    6113:	0f 84 27 0b 00 00    	je     6c40 <rotation_run+0xd10>
    6119:	c5 fb 10 02          	vmovsd (%rdx),%xmm0
    611d:	c4 c1 79 2f c3       	vcomisd %xmm11,%xmm0
    6122:	0f 85 ba 06 00 00    	jne    67e2 <rotation_run+0x8b2>
    6128:	c5 fb 10 7a 08       	vmovsd 0x8(%rdx),%xmm7
    612d:	c4 c1 79 2f fa       	vcomisd %xmm10,%xmm7
    6132:	0f 85 de 09 00 00    	jne    6b16 <rotation_run+0xbe6>
    6138:	c5 7b 10 42 10       	vmovsd 0x10(%rdx),%xmm8
    613d:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    6141:	c5 79 2f c0          	vcomisd %xmm0,%xmm8
    6145:	0f 85 d5 0c 00 00    	jne    6e20 <rotation_run+0xef0>
    614b:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    6150:	c5 f9 2f c8          	vcomisd %xmm0,%xmm1
    6154:	0f 84 36 06 00 00    	je     6790 <rotation_run+0x860>
    615a:	c4 41 7b 10 60 08    	vmovsd 0x8(%r8),%xmm12
    6160:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    6164:	c5 79 2f e0          	vcomisd %xmm0,%xmm12
    6168:	75 0c                	jne    6176 <rotation_run+0x246>
    616a:	c4 c1 79 2f 40 10    	vcomisd 0x10(%r8),%xmm0
    6170:	0f 84 c6 0c 00 00    	je     6e3c <rotation_run+0xf0c>
    6176:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    617a:	c5 f9 2f c8          	vcomisd %xmm0,%xmm1
    617e:	0f 85 77 0a 00 00    	jne    6bfb <rotation_run+0xccb>
    6184:	c4 c1 7b 10 40 10    	vmovsd 0x10(%r8),%xmm0
    618a:	e9 e9 06 00 00       	jmp    6878 <rotation_run+0x948>
    618f:	90                   	nop
    6190:	c5 7b 10 25 28 72 02 	vmovsd 0x27228(%rip),%xmm12        # 2d3c0 <__gnat_ada_main_program_name+0x38>
    6197:	00
    6198:	89 f6                	mov    %esi,%esi
    619a:	c4 41 21 57 db       	vxorpd %xmm11,%xmm11,%xmm11
    619f:	48 8d 0c 76          	lea    (%rsi,%rsi,2),%rcx
    61a3:	49 8d 0c c9          	lea    (%r9,%rcx,8),%rcx
    61a7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    61ae:	00 00
    61b0:	c4 c1 7b 10 31       	vmovsd (%r9),%xmm6
    61b5:	c4 c1 79 2f f3       	vcomisd %xmm11,%xmm6
    61ba:	0f 85 d0 07 00 00    	jne    6990 <rotation_run+0xa60>
    61c0:	c4 c1 7b 10 69 08    	vmovsd 0x8(%r9),%xmm5
    61c6:	c4 c1 79 2f eb       	vcomisd %xmm11,%xmm5
    61cb:	c5 f9 28 e5          	vmovapd %xmm5,%xmm4
    61cf:	0f 85 8b fd ff ff    	jne    5f60 <rotation_run+0x30>
    61d5:	c4 c1 7b 10 79 10    	vmovsd 0x10(%r9),%xmm7
    61db:	c4 c1 79 2f fb       	vcomisd %xmm11,%xmm7
    61e0:	0f 84 ca 06 00 00    	je     68b0 <rotation_run+0x980>
    61e6:	c5 fb 10 02          	vmovsd (%rdx),%xmm0
    61ea:	c4 c1 79 2f c4       	vcomisd %xmm12,%xmm0
    61ef:	0f 85 e7 08 00 00    	jne    6adc <rotation_run+0xbac>
    61f5:	c5 fb 10 42 08       	vmovsd 0x8(%rdx),%xmm0
    61fa:	c4 c1 79 2f c3       	vcomisd %xmm11,%xmm0
    61ff:	c5 79 28 c8          	vmovapd %xmm0,%xmm9
    6203:	0f 85 57 04 00 00    	jne    6660 <rotation_run+0x730>
    6209:	c5 7b 10 52 10       	vmovsd 0x10(%rdx),%xmm10
    620e:	c5 e9 57 d2          	vxorpd %xmm2,%xmm2,%xmm2
    6212:	c5 79 2f d2          	vcomisd %xmm2,%xmm10
    6216:	0f 84 d4 0a 00 00    	je     6cf0 <rotation_run+0xdc0>
    621c:	c4 c1 7b 10 79 10    	vmovsd 0x10(%r9),%xmm7
    6222:	c5 f9 28 ec          	vmovapd %xmm4,%xmm5
    6226:	c5 f1 57 c9          	vxorpd %xmm1,%xmm1,%xmm1
    622a:	c5 f9 2f e9          	vcomisd %xmm1,%xmm5
    622e:	0f 85 93 0a 00 00    	jne    6cc7 <rotation_run+0xd97>
    6234:	c5 f9 2f f9          	vcomisd %xmm1,%xmm7
    6238:	0f 84 72 06 00 00    	je     68b0 <rotation_run+0x980>
    623e:	c5 f1 57 c9          	vxorpd %xmm1,%xmm1,%xmm1
    6242:	c5 f9 2f f9          	vcomisd %xmm1,%xmm7
    6246:	0f 85 7b 0a 00 00    	jne    6cc7 <rotation_run+0xd97>
    624c:	c5 c1 57 ff          	vxorpd %xmm7,%xmm7,%xmm7
    6250:	c5 f9 28 ef          	vmovapd %xmm7,%xmm5
    6254:	c5 f9 28 f7          	vmovapd %xmm7,%xmm6
    6258:	e9 c7 fd ff ff       	jmp    6024 <rotation_run+0xf4>
    625d:	0f 1f 00             	nopl   (%rax)
    6260:	c5 7b 10 25 58 71 02 	vmovsd 0x27158(%rip),%xmm12        # 2d3c0 <__gnat_ada_main_program_name+0x38>
    6267:	00
    6268:	89 f6                	mov    %esi,%esi
    626a:	c4 41 21 57 db       	vxorpd %xmm11,%xmm11,%xmm11
    626f:	48 8d 0c 76          	lea    (%rsi,%rsi,2),%rcx
    6273:	49 8d 0c c9          	lea    (%r9,%rcx,8),%rcx
    6277:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    627e:	00 00
    6280:	c4 41 7b 10 01       	vmovsd (%r9),%xmm8
    6285:	c5 fb 10 0a          	vmovsd (%rdx),%xmm1
    6289:	c5 fb 10 42 08       	vmovsd 0x8(%rdx),%xmm0
    628e:	c5 fb 10 62 10       	vmovsd 0x10(%rdx),%xmm4
    6293:	c5 fb 10 52 18       	vmovsd 0x18(%rdx),%xmm2
    6298:	c4 41 79 2f c3       	vcomisd %xmm11,%xmm8
    629d:	0f 85 8d 07 00 00    	jne    6a30 <rotation_run+0xb00>
    62a3:	c4 41 7b 10 49 08    	vmovsd 0x8(%r9),%xmm9
    62a9:	c4 41 79 2f cb       	vcomisd %xmm11,%xmm9
    62ae:	c5 79 29 cd          	vmovapd %xmm9,%xmm5
    62b2:	0f 85 d8 08 00 00    	jne    6b90 <rotation_run+0xc60>
    62b8:	c4 41 7b 10 51 10    	vmovsd 0x10(%r9),%xmm10
    62be:	c4 41 79 2f d3       	vcomisd %xmm11,%xmm10
    62c3:	0f 84 c7 05 00 00    	je     6890 <rotation_run+0x960>
    62c9:	c4 c1 79 2f cc       	vcomisd %xmm12,%xmm1
    62ce:	c5 79 29 e6          	vmovapd %xmm12,%xmm6
    62d2:	0f 85 18 04 00 00    	jne    66f0 <rotation_run+0x7c0>
    62d8:	c4 c1 79 2f c3       	vcomisd %xmm11,%xmm0
    62dd:	0f 85 d5 03 00 00    	jne    66b8 <rotation_run+0x788>
    62e3:	c5 c1 57 ff          	vxorpd %xmm7,%xmm7,%xmm7
    62e7:	c5 f9 2f e7          	vcomisd %xmm7,%xmm4
    62eb:	0f 84 5f 0b 00 00    	je     6e50 <rotation_run+0xf20>
    62f1:	c4 41 7a 6f 09       	vmovdqu (%r9),%xmm9
    62f6:	49 8b 71 10          	mov    0x10(%r9),%rsi
    62fa:	c5 f9 2f ef          	vcomisd %xmm7,%xmm5
    62fe:	c4 41 7b 10 51 10    	vmovsd 0x10(%r9),%xmm10
    6304:	48 89 74 24 e8       	mov    %rsi,-0x18(%rsp)
    6309:	c5 79 7f 4c 24 d8    	vmovdqa %xmm9,-0x28(%rsp)
    630f:	c5 79 28 cd          	vmovapd %xmm5,%xmm9
    6313:	0f 85 87 0a 00 00    	jne    6da0 <rotation_run+0xe70>
    6319:	c5 79 2f d7          	vcomisd %xmm7,%xmm10
    631d:	0f 84 6d 05 00 00    	je     6890 <rotation_run+0x960>
    6323:	c5 f9 2f e7          	vcomisd %xmm7,%xmm4
    6327:	0f 84 96 0b 00 00    	je     6ec3 <rotation_run+0xf93>
    632d:	c5 d1 57 ed          	vxorpd %xmm5,%xmm5,%xmm5
    6331:	c5 79 2f d5          	vcomisd %xmm5,%xmm10
    6335:	0f 85 6a 08 00 00    	jne    6ba5 <rotation_run+0xc75>
    633b:	c4 41 29 57 d2       	vxorpd %xmm10,%xmm10,%xmm10
    6340:	c4 41 79 28 ca       	vmovapd %xmm10,%xmm9
    6345:	c4 41 79 28 c2       	vmovapd %xmm10,%xmm8
    634a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    6350:	c4 41 39 14 c1       	vunpcklpd %xmm9,%xmm8,%xmm8
    6355:	c4 41 7b 11 51 10    	vmovsd %xmm10,0x10(%r9)
    635b:	c4 41 79 11 01       	vmovupd %xmm8,(%r9)
    6360:	49 83 c1 18          	add    $0x18,%r9
    6364:	4c 39 c9             	cmp    %r9,%rcx
    6367:	0f 85 13 ff ff ff    	jne    6280 <rotation_run+0x350>
    636d:	e9 d0 fc ff ff       	jmp    6042 <rotation_run+0x112>
    6372:	0f 1f 00             	nopl   (%rax)
    6375:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    637c:	00 00 00 00
    6380:	89 f6                	mov    %esi,%esi
    6382:	48 8d 0c 76          	lea    (%rsi,%rsi,2),%rcx
    6386:	49 8d 0c c9          	lea    (%r9,%rcx,8),%rcx
    638a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    6390:	c4 c1 7b 10 60 08    	vmovsd 0x8(%r8),%xmm4
    6396:	c5 db 59 50 20       	vmulsd 0x20(%rax),%xmm4,%xmm2
    639b:	c4 c1 7b 10 00       	vmovsd (%r8),%xmm0
    63a0:	c4 c1 7b 10 58 10    	vmovsd 0x10(%r8),%xmm3
    63a6:	c5 fb 59 48 18       	vmulsd 0x18(%rax),%xmm0,%xmm1
    63ab:	c5 db 59 68 38       	vmulsd 0x38(%rax),%xmm4,%xmm5
    63b0:	c5 db 59 60 08       	vmulsd 0x8(%rax),%xmm4,%xmm4
    63b5:	c5 f3 58 ca          	vaddsd %xmm2,%xmm1,%xmm1
    63b9:	c5 e3 59 50 28       	vmulsd 0x28(%rax),%xmm3,%xmm2
    63be:	c5 f3 58 d2          	vaddsd %xmm2,%xmm1,%xmm2
    63c2:	c5 fb 59 48 30       	vmulsd 0x30(%rax),%xmm0,%xmm1
    63c7:	c5 fb 59 00          	vmulsd (%rax),%xmm0,%xmm0
    63cb:	c5 f3 58 cd          	vaddsd %xmm5,%xmm1,%xmm1
    63cf:	c5 e3 59 68 40       	vmulsd 0x40(%rax),%xmm3,%xmm5
    63d4:	c5 e3 59 58 10       	vmulsd 0x10(%rax),%xmm3,%xmm3
    63d9:	c5 fb 58 c4          	vaddsd %xmm4,%xmm0,%xmm0
    63dd:	c4 c1 7b 11 51 08    	vmovsd %xmm2,0x8(%r9)
    63e3:	c5 f3 58 cd          	vaddsd %xmm5,%xmm1,%xmm1
    63e7:	c5 fb 58 c3          	vaddsd %xmm3,%xmm0,%xmm0
    63eb:	c4 c1 7b 11 49 10    	vmovsd %xmm1,0x10(%r9)
    63f1:	c4 c1 7b 11 01       	vmovsd %xmm0,(%r9)
    63f6:	49 83 c1 18          	add    $0x18,%r9
    63fa:	4c 39 c9             	cmp    %r9,%rcx
    63fd:	75 91                	jne    6390 <rotation_run+0x460>
    63ff:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    6403:	c3                   	ret
    6404:	90                   	nop
    6405:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    640c:	00 00 00 00
    6410:	c5 7b 10 1d a8 6f 02 	vmovsd 0x26fa8(%rip),%xmm11        # 2d3c0 <__gnat_ada_main_program_name+0x38>
    6417:	00
    6418:	89 f6                	mov    %esi,%esi
    641a:	c4 41 29 57 d2       	vxorpd %xmm10,%xmm10,%xmm10
    641f:	48 8d 0c 76          	lea    (%rsi,%rsi,2),%rcx
    6423:	49 8d 0c c9          	lea    (%r9,%rcx,8),%rcx
    6427:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    642e:	00 00
    6430:	c4 c1 7b 10 20       	vmovsd (%r8),%xmm4
    6435:	c5 fb 10 0a          	vmovsd (%rdx),%xmm1
    6439:	c5 fb 10 42 08       	vmovsd 0x8(%rdx),%xmm0
    643e:	c5 fb 10 6a 10       	vmovsd 0x10(%rdx),%xmm5
    6443:	c5 fb 10 52 18       	vmovsd 0x18(%rdx),%xmm2
    6448:	c4 c1 79 2f e2       	vcomisd %xmm10,%xmm4
    644d:	0f 85 7d 04 00 00    	jne    68d0 <rotation_run+0x9a0>
    6453:	c4 41 7b 10 48 08    	vmovsd 0x8(%r8),%xmm9
    6459:	c4 41 79 2f ca       	vcomisd %xmm10,%xmm9
    645e:	0f 84 dc 06 00 00    	je     6b40 <rotation_run+0xc10>
    6464:	c4 c1 79 2f cb       	vcomisd %xmm11,%xmm1
    6469:	75 15                	jne    6480 <rotation_run+0x550>
    646b:	c4 c1 79 2f c2       	vcomisd %xmm10,%xmm0
    6470:	75 0e                	jne    6480 <rotation_run+0x550>
    6472:	c4 c1 79 2f ea       	vcomisd %xmm10,%xmm5
    6477:	0f 84 e3 04 00 00    	je     6960 <rotation_run+0xa30>
    647d:	0f 1f 00             	nopl   (%rax)
    6480:	c4 41 7b 10 60 10    	vmovsd 0x10(%r8),%xmm12
    6486:	c5 d1 57 2d e2 90 02 	vxorpd 0x290e2(%rip),%xmm5,%xmm5        # 2f570 <system__secondary_stack__invalid_memory_size+0xa8>
    648d:	00
    648e:	c5 e9 57 15 da 90 02 	vxorpd 0x290da(%rip),%xmm2,%xmm2        # 2f570 <system__secondary_stack__invalid_memory_size+0xa8>
    6495:	00
    6496:	c5 f3 59 f4          	vmulsd %xmm4,%xmm1,%xmm6
    649a:	c5 f9 57 05 ce 90 02 	vxorpd 0x290ce(%rip),%xmm0,%xmm0        # 2f570 <system__secondary_stack__invalid_memory_size+0xa8>
    64a1:	00
    64a2:	c4 c1 53 59 fc       	vmulsd %xmm12,%xmm5,%xmm7
    64a7:	c5 6b 59 c4          	vmulsd %xmm4,%xmm2,%xmm8
    64ab:	c5 cb 58 f7          	vaddsd %xmm7,%xmm6,%xmm6
    64af:	c4 c1 6b 59 f9       	vmulsd %xmm9,%xmm2,%xmm7
    64b4:	c5 cb 5c f7          	vsubsd %xmm7,%xmm6,%xmm6
    64b8:	c4 c1 73 59 f9       	vmulsd %xmm9,%xmm1,%xmm7
    64bd:	c4 c1 73 59 cc       	vmulsd %xmm12,%xmm1,%xmm1
    64c2:	c4 c1 43 58 f8       	vaddsd %xmm8,%xmm7,%xmm7
    64c7:	c4 41 7b 59 c4       	vmulsd %xmm12,%xmm0,%xmm8
    64cc:	c4 c1 43 5c f8       	vsubsd %xmm8,%xmm7,%xmm7
    64d1:	c4 41 7b 59 c1       	vmulsd %xmm9,%xmm0,%xmm8
    64d6:	c4 c1 73 58 c8       	vaddsd %xmm8,%xmm1,%xmm1
    64db:	c5 53 59 c4          	vmulsd %xmm4,%xmm5,%xmm8
    64df:	c5 6b 59 ef          	vmulsd %xmm7,%xmm2,%xmm13
    64e3:	c5 eb 59 d6          	vmulsd %xmm6,%xmm2,%xmm2
    64e7:	c4 c1 73 5c c8       	vsubsd %xmm8,%xmm1,%xmm1
    64ec:	c5 53 59 c1          	vmulsd %xmm1,%xmm5,%xmm8
    64f0:	c5 fb 59 c9          	vmulsd %xmm1,%xmm0,%xmm1
    64f4:	c5 d3 59 ee          	vmulsd %xmm6,%xmm5,%xmm5
    64f8:	c5 fb 59 c7          	vmulsd %xmm7,%xmm0,%xmm0
    64fc:	c4 41 3b 5c c5       	vsubsd %xmm13,%xmm8,%xmm8
    6501:	c5 eb 5c d1          	vsubsd %xmm1,%xmm2,%xmm2
    6505:	c5 fb 5c c5          	vsubsd %xmm5,%xmm0,%xmm0
    6509:	c4 41 3b 58 c0       	vaddsd %xmm8,%xmm8,%xmm8
    650e:	c5 eb 58 d2          	vaddsd %xmm2,%xmm2,%xmm2
    6512:	c5 fb 58 c0          	vaddsd %xmm0,%xmm0,%xmm0
    6516:	c4 c1 5b 58 e0       	vaddsd %xmm8,%xmm4,%xmm4
    651b:	c5 33 58 ca          	vaddsd %xmm2,%xmm9,%xmm9
    651f:	c4 c1 7b 58 c4       	vaddsd %xmm12,%xmm0,%xmm0
    6524:	c4 c1 59 14 e1       	vunpcklpd %xmm9,%xmm4,%xmm4
    6529:	c4 c1 7b 11 41 10    	vmovsd %xmm0,0x10(%r9)
    652f:	c4 c1 79 11 21       	vmovupd %xmm4,(%r9)
    6534:	49 83 c1 18          	add    $0x18,%r9
    6538:	4c 39 c9             	cmp    %r9,%rcx
    653b:	0f 85 ef fe ff ff    	jne    6430 <rotation_run+0x500>
    6541:	e9 fc fa ff ff       	jmp    6042 <rotation_run+0x112>
    6546:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    654d:	00 00 00
    6550:	89 f6                	mov    %esi,%esi
    6552:	48 8d 0c 76          	lea    (%rsi,%rsi,2),%rcx
    6556:	49 8d 0c c9          	lea    (%r9,%rcx,8),%rcx
    655a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    6560:	c4 c1 7b 10 01       	vmovsd (%r9),%xmm0
    6565:	c5 fb 59 48 18       	vmulsd 0x18(%rax),%xmm0,%xmm1
    656a:	c4 c1 7b 10 61 08    	vmovsd 0x8(%r9),%xmm4
    6570:	c4 c1 7b 10 59 10    	vmovsd 0x10(%r9),%xmm3
    6576:	c5 db 59 50 20       	vmulsd 0x20(%rax),%xmm4,%xmm2
    657b:	c5 db 59 68 38       	vmulsd 0x38(%rax),%xmm4,%xmm5
    6580:	c5 db 59 60 08       	vmulsd 0x8(%rax),%xmm4,%xmm4
    6585:	c5 f3 58 ca          	vaddsd %xmm2,%xmm1,%xmm1
    6589:	c5 e3 59 50 28       	vmulsd 0x28(%rax),%xmm3,%xmm2
    658e:	c5 f3 58 d2          	vaddsd %xmm2,%xmm1,%xmm2
    6592:	c5 fb 59 48 30       	vmulsd 0x30(%rax),%xmm0,%xmm1
    6597:	c5 fb 59 00          	vmulsd (%rax),%xmm0,%xmm0
    659b:	c5 f3 58 cd          	vaddsd %xmm5,%xmm1,%xmm1
    659f:	c5 e3 59 68 40       	vmulsd 0x40(%rax),%xmm3,%xmm5
    65a4:	c5 e3 59 58 10       	vmulsd 0x10(%rax),%xmm3,%xmm3
    65a9:	c5 fb 58 c4          	vaddsd %xmm4,%xmm0,%xmm0
    65ad:	c4 c1 7b 11 51 08    	vmovsd %xmm2,0x8(%r9)
    65b3:	c5 f3 58 cd          	vaddsd %xmm5,%xmm1,%xmm1
    65b7:	c5 fb 58 c3          	vaddsd %xmm3,%xmm0,%xmm0
    65bb:	c4 c1 7b 11 49 10    	vmovsd %xmm1,0x10(%r9)
    65c1:	c4 c1 7b 11 01       	vmovsd %xmm0,(%r9)
    65c6:	49 83 c1 18          	add    $0x18,%r9
    65ca:	4c 39 c9             	cmp    %r9,%rcx
    65cd:	75 91                	jne    6560 <rotation_run+0x630>
    65cf:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    65d3:	c3                   	ret
    65d4:	90                   	nop
    65d5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    65dc:	00 00 00 00
    65e0:	89 f6                	mov    %esi,%esi
    65e2:	48 8d 0c 76          	lea    (%rsi,%rsi,2),%rcx
    65e6:	49 8d 0c c9          	lea    (%r9,%rcx,8),%rcx
    65ea:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    65f0:	c4 c1 79 28 00       	vmovapd (%r8),%xmm0
    65f5:	c5 fb 10 48 10       	vmovsd 0x10(%rax),%xmm1
    65fa:	c4 c1 7b 10 58 10    	vmovsd 0x10(%r8),%xmm3
    6600:	c5 f9 15 d0          	vunpckhpd %xmm0,%xmm0,%xmm2
    6604:	c5 eb 59 50 28       	vmulsd 0x28(%rax),%xmm2,%xmm2
    6609:	c5 f3 59 c8          	vmulsd %xmm0,%xmm1,%xmm1
    660d:	c5 f3 58 ca          	vaddsd %xmm2,%xmm1,%xmm1
    6611:	c5 e3 59 50 40       	vmulsd 0x40(%rax),%xmm3,%xmm2
    6616:	c5 fb 12 db          	vmovddup %xmm3,%xmm3
    661a:	c5 e1 59 58 30       	vmulpd 0x30(%rax),%xmm3,%xmm3
    661f:	c5 f3 58 ca          	vaddsd %xmm2,%xmm1,%xmm1
    6623:	c4 e3 79 05 d0 03    	vpermilpd $0x3,%xmm0,%xmm2
    6629:	c4 e3 79 05 c0 00    	vpermilpd $0x0,%xmm0,%xmm0
    662f:	c5 e9 59 50 18       	vmulpd 0x18(%rax),%xmm2,%xmm2
    6634:	c5 f9 59 00          	vmulpd (%rax),%xmm0,%xmm0
    6638:	c4 c1 7b 11 49 10    	vmovsd %xmm1,0x10(%r9)
    663e:	c5 e9 58 c0          	vaddpd %xmm0,%xmm2,%xmm0
    6642:	c5 f9 58 c3          	vaddpd %xmm3,%xmm0,%xmm0
    6646:	c4 c1 79 11 01       	vmovupd %xmm0,(%r9)
    664b:	49 83 c1 18          	add    $0x18,%r9
    664f:	4c 39 c9             	cmp    %r9,%rcx
    6652:	75 9c                	jne    65f0 <rotation_run+0x6c0>
    6654:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    6658:	c3                   	ret
    6659:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    6660:	c5 e9 57 d2          	vxorpd %xmm2,%xmm2,%xmm2
    6664:	c5 f9 2f fa          	vcomisd %xmm2,%xmm7
    6668:	0f 84 42 02 00 00    	je     68b0 <rotation_run+0x980>
    666e:	c5 f9 2f c2          	vcomisd %xmm2,%xmm0
    6672:	c5 7b 10 52 10       	vmovsd 0x10(%rdx),%xmm10
    6677:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    667c:	0f 85 2e 07 00 00    	jne    6db0 <rotation_run+0xe80>
    6682:	c5 79 2f d2          	vcomisd %xmm2,%xmm10
    6686:	0f 85 24 07 00 00    	jne    6db0 <rotation_run+0xe80>
    668c:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    6690:	c5 f9 2f c8          	vcomisd %xmm0,%xmm1
    6694:	0f 84 8a f9 ff ff    	je     6024 <rotation_run+0xf4>
    669a:	e9 ff f8 ff ff       	jmp    5f9e <rotation_run+0x6e>
    669f:	90                   	nop
    66a0:	c4 c1 79 2f c3       	vcomisd %xmm11,%xmm0
    66a5:	0f 84 38 fc ff ff    	je     62e3 <rotation_run+0x3b3>
    66ab:	c4 41 79 2f cb       	vcomisd %xmm11,%xmm9
    66b0:	c4 41 7b 10 51 10    	vmovsd 0x10(%r9),%xmm10
    66b6:	75 18                	jne    66d0 <rotation_run+0x7a0>
    66b8:	c4 41 79 2f d3       	vcomisd %xmm11,%xmm10
    66bd:	0f 84 cd 01 00 00    	je     6890 <rotation_run+0x960>
    66c3:	66 90                	xchg   %ax,%ax
    66c5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    66cc:	00 00 00 00
    66d0:	c4 c1 79 2f c3       	vcomisd %xmm11,%xmm0
    66d5:	75 19                	jne    66f0 <rotation_run+0x7c0>
    66d7:	c4 c1 79 2f e3       	vcomisd %xmm11,%xmm4
    66dc:	75 12                	jne    66f0 <rotation_run+0x7c0>
    66de:	c5 d1 57 ed          	vxorpd %xmm5,%xmm5,%xmm5
    66e2:	c5 f9 2f d5          	vcomisd %xmm5,%xmm2
    66e6:	0f 84 64 fc ff ff    	je     6350 <rotation_run+0x420>
    66ec:	0f 1f 40 00          	nopl   0x0(%rax)
    66f0:	c5 d9 57 25 78 8e 02 	vxorpd 0x28e78(%rip),%xmm4,%xmm4        # 2f570 <system__secondary_stack__invalid_memory_size+0xa8>
    66f7:	00
    66f8:	c5 e9 57 15 70 8e 02 	vxorpd 0x28e70(%rip),%xmm2,%xmm2        # 2f570 <system__secondary_stack__invalid_memory_size+0xa8>
    66ff:	00
    6700:	c4 c1 73 59 e8       	vmulsd %xmm8,%xmm1,%xmm5
    6705:	c5 f9 57 05 63 8e 02 	vxorpd 0x28e63(%rip),%xmm0,%xmm0        # 2f570 <system__secondary_stack__invalid_memory_size+0xa8>
    670c:	00
    670d:	c4 c1 5b 59 f2       	vmulsd %xmm10,%xmm4,%xmm6
    6712:	c4 c1 6b 59 f8       	vmulsd %xmm8,%xmm2,%xmm7
    6717:	c5 d3 58 ee          	vaddsd %xmm6,%xmm5,%xmm5
    671b:	c4 c1 6b 59 f1       	vmulsd %xmm9,%xmm2,%xmm6
    6720:	c5 d3 5c ee          	vsubsd %xmm6,%xmm5,%xmm5
    6724:	c4 c1 73 59 f1       	vmulsd %xmm9,%xmm1,%xmm6
    6729:	c4 c1 73 59 ca       	vmulsd %xmm10,%xmm1,%xmm1
    672e:	c5 cb 58 f7          	vaddsd %xmm7,%xmm6,%xmm6
    6732:	c4 c1 7b 59 fa       	vmulsd %xmm10,%xmm0,%xmm7
    6737:	c5 cb 5c f7          	vsubsd %xmm7,%xmm6,%xmm6
    673b:	c4 c1 7b 59 f9       	vmulsd %xmm9,%xmm0,%xmm7
    6740:	c5 f3 58 cf          	vaddsd %xmm7,%xmm1,%xmm1
    6744:	c4 c1 5b 59 f8       	vmulsd %xmm8,%xmm4,%xmm7
    6749:	c5 6b 59 ee          	vmulsd %xmm6,%xmm2,%xmm13
    674d:	c5 eb 59 d5          	vmulsd %xmm5,%xmm2,%xmm2
    6751:	c5 f3 5c cf          	vsubsd %xmm7,%xmm1,%xmm1
    6755:	c5 db 59 f9          	vmulsd %xmm1,%xmm4,%xmm7
    6759:	c5 fb 59 c9          	vmulsd %xmm1,%xmm0,%xmm1
    675d:	c5 db 59 e5          	vmulsd %xmm5,%xmm4,%xmm4
    6761:	c5 fb 59 c6          	vmulsd %xmm6,%xmm0,%xmm0
    6765:	c4 c1 43 5c fd       	vsubsd %xmm13,%xmm7,%xmm7
    676a:	c5 eb 5c d1          	vsubsd %xmm1,%xmm2,%xmm2
    676e:	c5 fb 5c c4          	vsubsd %xmm4,%xmm0,%xmm0
    6772:	c5 c3 58 ff          	vaddsd %xmm7,%xmm7,%xmm7
    6776:	c5 eb 58 d2          	vaddsd %xmm2,%xmm2,%xmm2
    677a:	c5 fb 58 c0          	vaddsd %xmm0,%xmm0,%xmm0
    677e:	c5 3b 58 c7          	vaddsd %xmm7,%xmm8,%xmm8
    6782:	c5 33 58 ca          	vaddsd %xmm2,%xmm9,%xmm9
    6786:	c5 2b 58 d0          	vaddsd %xmm0,%xmm10,%xmm10
    678a:	e9 c1 fb ff ff       	jmp    6350 <rotation_run+0x420>
    678f:	90                   	nop
    6790:	49 8b 70 10          	mov    0x10(%r8),%rsi
    6794:	c4 c1 7a 6f 00       	vmovdqu (%r8),%xmm0
    6799:	49 89 71 10          	mov    %rsi,0x10(%r9)
    679d:	c4 c1 7a 7f 01       	vmovdqu %xmm0,(%r9)
    67a2:	0f 1f 00             	nopl   (%rax)
    67a5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    67ac:	00 00 00 00
    67b0:	49 83 c1 18          	add    $0x18,%r9
    67b4:	4c 39 c9             	cmp    %r9,%rcx
    67b7:	0f 84 85 f8 ff ff    	je     6042 <rotation_run+0x112>
    67bd:	c4 c1 7b 10 10       	vmovsd (%r8),%xmm2
    67c2:	c4 c1 79 2f d2       	vcomisd %xmm10,%xmm2
    67c7:	0f 84 33 f9 ff ff    	je     6100 <rotation_run+0x1d0>
    67cd:	c5 fb 10 02          	vmovsd (%rdx),%xmm0
    67d1:	c4 c1 79 2f c3       	vcomisd %xmm11,%xmm0
    67d6:	0f 84 24 03 00 00    	je     6b00 <rotation_run+0xbd0>
    67dc:	c4 41 7b 10 60 08    	vmovsd 0x8(%r8),%xmm12
    67e2:	c4 41 7b 10 48 10    	vmovsd 0x10(%r8),%xmm9
    67e8:	c5 fb 10 7a 08       	vmovsd 0x8(%rdx),%xmm7
    67ed:	c5 7b 10 42 10       	vmovsd 0x10(%rdx),%xmm8
    67f2:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    67f7:	c5 6b 59 e8          	vmulsd %xmm0,%xmm2,%xmm13
    67fb:	c4 c1 7b 59 ec       	vmulsd %xmm12,%xmm0,%xmm5
    6800:	c4 c1 7b 59 f1       	vmulsd %xmm9,%xmm0,%xmm6
    6805:	c4 c1 33 59 e0       	vmulsd %xmm8,%xmm9,%xmm4
    680a:	c5 9b 59 c1          	vmulsd %xmm1,%xmm12,%xmm0
    680e:	c4 c1 5b 58 e5       	vaddsd %xmm13,%xmm4,%xmm4
    6813:	c5 db 5c e0          	vsubsd %xmm0,%xmm4,%xmm4
    6817:	c5 eb 59 c1          	vmulsd %xmm1,%xmm2,%xmm0
    681b:	c5 fb 58 c5          	vaddsd %xmm5,%xmm0,%xmm0
    681f:	c5 b3 59 ef          	vmulsd %xmm7,%xmm9,%xmm5
    6823:	c5 fb 5c c5          	vsubsd %xmm5,%xmm0,%xmm0
    6827:	c5 9b 59 ef          	vmulsd %xmm7,%xmm12,%xmm5
    682b:	c5 d3 58 ee          	vaddsd %xmm6,%xmm5,%xmm5
    682f:	c4 c1 6b 59 f0       	vmulsd %xmm8,%xmm2,%xmm6
    6834:	c5 7b 59 e9          	vmulsd %xmm1,%xmm0,%xmm13
    6838:	c5 db 59 c9          	vmulsd %xmm1,%xmm4,%xmm1
    683c:	c5 fb 59 c7          	vmulsd %xmm7,%xmm0,%xmm0
    6840:	c4 c1 5b 59 e0       	vmulsd %xmm8,%xmm4,%xmm4
    6845:	c5 d3 5c ee          	vsubsd %xmm6,%xmm5,%xmm5
    6849:	c5 fb 5c c4          	vsubsd %xmm4,%xmm0,%xmm0
    684d:	c4 c1 53 59 f0       	vmulsd %xmm8,%xmm5,%xmm6
    6852:	c5 d3 59 ef          	vmulsd %xmm7,%xmm5,%xmm5
    6856:	c5 fb 58 c0          	vaddsd %xmm0,%xmm0,%xmm0
    685a:	c4 c1 4b 5c f5       	vsubsd %xmm13,%xmm6,%xmm6
    685f:	c5 f3 5c cd          	vsubsd %xmm5,%xmm1,%xmm1
    6863:	c4 c1 7b 58 c1       	vaddsd %xmm9,%xmm0,%xmm0
    6868:	c5 cb 58 f6          	vaddsd %xmm6,%xmm6,%xmm6
    686c:	c5 f3 58 c9          	vaddsd %xmm1,%xmm1,%xmm1
    6870:	c5 eb 58 d6          	vaddsd %xmm6,%xmm2,%xmm2
    6874:	c5 1b 58 e1          	vaddsd %xmm1,%xmm12,%xmm12
    6878:	c4 c1 69 14 d4       	vunpcklpd %xmm12,%xmm2,%xmm2
    687d:	c4 c1 7b 11 41 10    	vmovsd %xmm0,0x10(%r9)
    6883:	c4 c1 79 11 11       	vmovupd %xmm2,(%r9)
    6888:	e9 23 ff ff ff       	jmp    67b0 <rotation_run+0x880>
    688d:	0f 1f 00             	nopl   (%rax)
    6890:	49 c7 41 10 00 00 00 	movq   $0x0,0x10(%r9)
    6897:	00
    6898:	c4 c1 7a 7f 19       	vmovdqu %xmm3,(%r9)
    689d:	e9 be fa ff ff       	jmp    6360 <rotation_run+0x430>
    68a2:	0f 1f 00             	nopl   (%rax)
    68a5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    68ac:	00 00 00 00
    68b0:	49 c7 41 10 00 00 00 	movq   $0x0,0x10(%r9)
    68b7:	00
    68b8:	c4 c1 7a 7f 19       	vmovdqu %xmm3,(%r9)
    68bd:	e9 73 f7 ff ff       	jmp    6035 <rotation_run+0x105>
    68c2:	0f 1f 00             	nopl   (%rax)
    68c5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    68cc:	00 00 00 00
    68d0:	c4 c1 79 2f cb       	vcomisd %xmm11,%xmm1
    68d5:	c5 79 29 de          	vmovapd %xmm11,%xmm6
    68d9:	0f 85 e1 01 00 00    	jne    6ac0 <rotation_run+0xb90>
    68df:	c4 c1 79 2f c2       	vcomisd %xmm10,%xmm0
    68e4:	0f 85 d6 01 00 00    	jne    6ac0 <rotation_run+0xb90>
    68ea:	c4 c1 79 2f ea       	vcomisd %xmm10,%xmm5
    68ef:	0f 85 6b 03 00 00    	jne    6c60 <rotation_run+0xd30>
    68f5:	c4 c1 79 2f d2       	vcomisd %xmm10,%xmm2
    68fa:	74 6f                	je     696b <rotation_run+0xa3b>
    68fc:	c4 c1 79 2f e2       	vcomisd %xmm10,%xmm4
    6901:	c4 41 7b 10 48 08    	vmovsd 0x8(%r8),%xmm9
    6907:	0f 85 73 fb ff ff    	jne    6480 <rotation_run+0x550>
    690d:	c5 c1 57 ff          	vxorpd %xmm7,%xmm7,%xmm7
    6911:	c5 79 2f cf          	vcomisd %xmm7,%xmm9
    6915:	0f 85 65 fb ff ff    	jne    6480 <rotation_run+0x550>
    691b:	c4 c1 79 2f 78 10    	vcomisd 0x10(%r8),%xmm7
    6921:	0f 84 50 02 00 00    	je     6b77 <rotation_run+0xc47>
    6927:	c5 f9 2f ce          	vcomisd %xmm6,%xmm1
    692b:	0f 85 4f fb ff ff    	jne    6480 <rotation_run+0x550>
    6931:	c5 f9 2f c7          	vcomisd %xmm7,%xmm0
    6935:	0f 85 45 fb ff ff    	jne    6480 <rotation_run+0x550>
    693b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    6940:	c5 c9 57 f6          	vxorpd %xmm6,%xmm6,%xmm6
    6944:	c5 f9 2f d6          	vcomisd %xmm6,%xmm2
    6948:	0f 85 32 fb ff ff    	jne    6480 <rotation_run+0x550>
    694e:	c4 c1 7b 10 40 10    	vmovsd 0x10(%r8),%xmm0
    6954:	e9 cb fb ff ff       	jmp    6524 <rotation_run+0x5f4>
    6959:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    6960:	c4 c1 79 2f d2       	vcomisd %xmm10,%xmm2
    6965:	0f 85 15 fb ff ff    	jne    6480 <rotation_run+0x550>
    696b:	c4 c1 7a 6f 00       	vmovdqu (%r8),%xmm0
    6970:	49 8b 70 10          	mov    0x10(%r8),%rsi
    6974:	49 89 71 10          	mov    %rsi,0x10(%r9)
    6978:	c4 c1 7a 7f 01       	vmovdqu %xmm0,(%r9)
    697d:	e9 b2 fb ff ff       	jmp    6534 <rotation_run+0x604>
    6982:	0f 1f 00             	nopl   (%rax)
    6985:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    698c:	00 00 00 00
    6990:	c5 fb 10 02          	vmovsd (%rdx),%xmm0
    6994:	c4 c1 79 2f c4       	vcomisd %xmm12,%xmm0
    6999:	0f 85 31 01 00 00    	jne    6ad0 <rotation_run+0xba0>
    699f:	c5 7b 10 4a 08       	vmovsd 0x8(%rdx),%xmm9
    69a4:	c4 41 79 2f cb       	vcomisd %xmm11,%xmm9
    69a9:	c5 79 29 c8          	vmovapd %xmm9,%xmm0
    69ad:	0f 85 0d 02 00 00    	jne    6bc0 <rotation_run+0xc90>
    69b3:	c5 7b 10 52 10       	vmovsd 0x10(%rdx),%xmm10
    69b8:	c4 41 79 2f d3       	vcomisd %xmm11,%xmm10
    69bd:	0f 85 ed 02 00 00    	jne    6cb0 <rotation_run+0xd80>
    69c3:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    69c8:	c4 c1 79 2f cb       	vcomisd %xmm11,%xmm1
    69cd:	c5 79 28 c1          	vmovapd %xmm1,%xmm8
    69d1:	0f 84 5e f6 ff ff    	je     6035 <rotation_run+0x105>
    69d7:	c4 c1 7a 6f 11       	vmovdqu (%r9),%xmm2
    69dc:	49 8b 71 10          	mov    0x10(%r9),%rsi
    69e0:	c4 c1 79 2f f3       	vcomisd %xmm11,%xmm6
    69e5:	c4 c1 7b 10 69 08    	vmovsd 0x8(%r9),%xmm5
    69eb:	c4 c1 7b 10 79 10    	vmovsd 0x10(%r9),%xmm7
    69f1:	48 89 74 24 e8       	mov    %rsi,-0x18(%rsp)
    69f6:	c5 f9 7f 54 24 d8    	vmovdqa %xmm2,-0x28(%rsp)
    69fc:	0f 84 1f 03 00 00    	je     6d21 <rotation_run+0xdf1>
    6a02:	c4 c1 79 2f cb       	vcomisd %xmm11,%xmm1
    6a07:	0f 84 b3 03 00 00    	je     6dc0 <rotation_run+0xe90>
    6a0d:	c4 c1 79 2f f3       	vcomisd %xmm11,%xmm6
    6a12:	0f 85 48 03 00 00    	jne    6d60 <rotation_run+0xe30>
    6a18:	c5 e9 57 d2          	vxorpd %xmm2,%xmm2,%xmm2
    6a1c:	c5 f9 2f ea          	vcomisd %xmm2,%xmm5
    6a20:	0f 85 3a 03 00 00    	jne    6d60 <rotation_run+0xe30>
    6a26:	e9 18 03 00 00       	jmp    6d43 <rotation_run+0xe13>
    6a2b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    6a30:	c4 c1 79 2f cc       	vcomisd %xmm12,%xmm1
    6a35:	c5 79 29 e6          	vmovapd %xmm12,%xmm6
    6a39:	75 65                	jne    6aa0 <rotation_run+0xb70>
    6a3b:	c4 c1 79 2f c3       	vcomisd %xmm11,%xmm0
    6a40:	75 5e                	jne    6aa0 <rotation_run+0xb70>
    6a42:	c4 c1 79 2f e3       	vcomisd %xmm11,%xmm4
    6a47:	75 57                	jne    6aa0 <rotation_run+0xb70>
    6a49:	c4 c1 79 2f d3       	vcomisd %xmm11,%xmm2
    6a4e:	0f 84 0c f9 ff ff    	je     6360 <rotation_run+0x430>
    6a54:	c4 c1 7a 6f 29       	vmovdqu (%r9),%xmm5
    6a59:	49 8b 71 10          	mov    0x10(%r9),%rsi
    6a5d:	c4 41 79 2f c3       	vcomisd %xmm11,%xmm8
    6a62:	c4 41 7b 10 49 08    	vmovsd 0x8(%r9),%xmm9
    6a68:	c4 41 7b 10 51 10    	vmovsd 0x10(%r9),%xmm10
    6a6e:	48 89 74 24 e8       	mov    %rsi,-0x18(%rsp)
    6a73:	c5 f9 7f 6c 24 d8    	vmovdqa %xmm5,-0x28(%rsp)
    6a79:	0f 85 71 fc ff ff    	jne    66f0 <rotation_run+0x7c0>
    6a7f:	90                   	nop
    6a80:	c5 d1 57 ed          	vxorpd %xmm5,%xmm5,%xmm5
    6a84:	c5 79 2f cd          	vcomisd %xmm5,%xmm9
    6a88:	0f 84 f2 03 00 00    	je     6e80 <rotation_run+0xf50>
    6a8e:	c5 f9 2f c5          	vcomisd %xmm5,%xmm0
    6a92:	0f 85 58 fc ff ff    	jne    66f0 <rotation_run+0x7c0>
    6a98:	e9 41 fc ff ff       	jmp    66de <rotation_run+0x7ae>
    6a9d:	0f 1f 00             	nopl   (%rax)
    6aa0:	c4 41 7b 10 49 08    	vmovsd 0x8(%r9),%xmm9
    6aa6:	c4 41 7b 10 51 10    	vmovsd 0x10(%r9),%xmm10
    6aac:	e9 3f fc ff ff       	jmp    66f0 <rotation_run+0x7c0>
    6ab1:	0f 1f 40 00          	nopl   0x0(%rax)
    6ab5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6abc:	00 00 00 00
    6ac0:	c4 41 7b 10 48 08    	vmovsd 0x8(%r8),%xmm9
    6ac6:	e9 b5 f9 ff ff       	jmp    6480 <rotation_run+0x550>
    6acb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    6ad0:	c4 c1 7b 10 69 08    	vmovsd 0x8(%r9),%xmm5
    6ad6:	c4 c1 7b 10 79 10    	vmovsd 0x10(%r9),%xmm7
    6adc:	c5 7b 10 4a 08       	vmovsd 0x8(%rdx),%xmm9
    6ae1:	c5 7b 10 52 10       	vmovsd 0x10(%rdx),%xmm10
    6ae6:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    6aeb:	c5 4b 59 e8          	vmulsd %xmm0,%xmm6,%xmm13
    6aef:	c5 d3 59 e0          	vmulsd %xmm0,%xmm5,%xmm4
    6af3:	c5 43 59 c0          	vmulsd %xmm0,%xmm7,%xmm8
    6af7:	e9 ae f4 ff ff       	jmp    5faa <rotation_run+0x7a>
    6afc:	0f 1f 40 00          	nopl   0x0(%rax)
    6b00:	c5 fb 10 7a 08       	vmovsd 0x8(%rdx),%xmm7
    6b05:	c4 c1 79 2f fa       	vcomisd %xmm10,%xmm7
    6b0a:	0f 84 d0 00 00 00    	je     6be0 <rotation_run+0xcb0>
    6b10:	c4 41 7b 10 60 08    	vmovsd 0x8(%r8),%xmm12
    6b16:	c4 41 7b 10 48 10    	vmovsd 0x10(%r8),%xmm9
    6b1c:	c5 7b 10 42 10       	vmovsd 0x10(%rdx),%xmm8
    6b21:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    6b26:	c5 79 29 e5          	vmovapd %xmm12,%xmm5
    6b2a:	c5 79 28 ea          	vmovapd %xmm2,%xmm13
    6b2e:	c5 79 29 ce          	vmovapd %xmm9,%xmm6
    6b32:	e9 ce fc ff ff       	jmp    6805 <rotation_run+0x8d5>
    6b37:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    6b3e:	00 00
    6b40:	c4 41 79 2f 50 10    	vcomisd 0x10(%r8),%xmm10
    6b46:	0f 84 d4 00 00 00    	je     6c20 <rotation_run+0xcf0>
    6b4c:	c4 c1 79 2f cb       	vcomisd %xmm11,%xmm1
    6b51:	c5 79 29 de          	vmovapd %xmm11,%xmm6
    6b55:	0f 85 25 f9 ff ff    	jne    6480 <rotation_run+0x550>
    6b5b:	c4 c1 79 2f c2       	vcomisd %xmm10,%xmm0
    6b60:	0f 84 1a 02 00 00    	je     6d80 <rotation_run+0xe50>
    6b66:	c4 41 7b 10 60 10    	vmovsd 0x10(%r8),%xmm12
    6b6c:	c4 41 79 2f e2       	vcomisd %xmm10,%xmm12
    6b71:	0f 85 0f f9 ff ff    	jne    6486 <rotation_run+0x556>
    6b77:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    6b7b:	c5 79 28 c8          	vmovapd %xmm0,%xmm9
    6b7f:	c5 f9 28 e0          	vmovapd %xmm0,%xmm4
    6b83:	e9 9c f9 ff ff       	jmp    6524 <rotation_run+0x5f4>
    6b88:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    6b8f:	00
    6b90:	c4 c1 79 2f cc       	vcomisd %xmm12,%xmm1
    6b95:	c5 79 29 e6          	vmovapd %xmm12,%xmm6
    6b99:	0f 84 01 fb ff ff    	je     66a0 <rotation_run+0x770>
    6b9f:	c4 41 7b 10 51 10    	vmovsd 0x10(%r9),%xmm10
    6ba5:	c5 f9 2f ce          	vcomisd %xmm6,%xmm1
    6ba9:	0f 84 21 fb ff ff    	je     66d0 <rotation_run+0x7a0>
    6baf:	e9 3c fb ff ff       	jmp    66f0 <rotation_run+0x7c0>
    6bb4:	90                   	nop
    6bb5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6bbc:	00 00 00 00
    6bc0:	c4 c1 7b 10 69 08    	vmovsd 0x8(%r9),%xmm5
    6bc6:	c4 c1 7b 10 79 10    	vmovsd 0x10(%r9),%xmm7
    6bcc:	e9 c3 f3 ff ff       	jmp    5f94 <rotation_run+0x64>
    6bd1:	0f 1f 40 00          	nopl   0x0(%rax)
    6bd5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6bdc:	00 00 00 00
    6be0:	c5 7b 10 42 10       	vmovsd 0x10(%rdx),%xmm8
    6be5:	c4 41 79 2f c2       	vcomisd %xmm10,%xmm8
    6bea:	0f 84 00 02 00 00    	je     6df0 <rotation_run+0xec0>
    6bf0:	c4 41 7b 10 60 08    	vmovsd 0x8(%r8),%xmm12
    6bf6:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    6bfb:	c4 41 7b 10 48 10    	vmovsd 0x10(%r8),%xmm9
    6c01:	c5 79 29 e5          	vmovapd %xmm12,%xmm5
    6c05:	c5 79 28 ea          	vmovapd %xmm2,%xmm13
    6c09:	c5 79 29 ce          	vmovapd %xmm9,%xmm6
    6c0d:	e9 f3 fb ff ff       	jmp    6805 <rotation_run+0x8d5>
    6c12:	0f 1f 00             	nopl   (%rax)
    6c15:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6c1c:	00 00 00 00
    6c20:	49 c7 41 10 00 00 00 	movq   $0x0,0x10(%r9)
    6c27:	00
    6c28:	c4 c1 7a 7f 19       	vmovdqu %xmm3,(%r9)
    6c2d:	e9 02 f9 ff ff       	jmp    6534 <rotation_run+0x604>
    6c32:	0f 1f 00             	nopl   (%rax)
    6c35:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6c3c:	00 00 00 00
    6c40:	49 c7 41 10 00 00 00 	movq   $0x0,0x10(%r9)
    6c47:	00
    6c48:	c4 c1 7a 7f 19       	vmovdqu %xmm3,(%r9)
    6c4d:	e9 5e fb ff ff       	jmp    67b0 <rotation_run+0x880>
    6c52:	0f 1f 00             	nopl   (%rax)
    6c55:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6c5c:	00 00 00 00
    6c60:	c4 c1 79 2f e2       	vcomisd %xmm10,%xmm4
    6c65:	c4 41 7b 10 48 08    	vmovsd 0x8(%r8),%xmm9
    6c6b:	0f 85 0f f8 ff ff    	jne    6480 <rotation_run+0x550>
    6c71:	c5 c1 57 ff          	vxorpd %xmm7,%xmm7,%xmm7
    6c75:	c5 79 2f cf          	vcomisd %xmm7,%xmm9
    6c79:	0f 85 01 f8 ff ff    	jne    6480 <rotation_run+0x550>
    6c7f:	c4 c1 79 2f 78 10    	vcomisd 0x10(%r8),%xmm7
    6c85:	0f 84 ec fe ff ff    	je     6b77 <rotation_run+0xc47>
    6c8b:	c5 f9 2f ce          	vcomisd %xmm6,%xmm1
    6c8f:	0f 85 eb f7 ff ff    	jne    6480 <rotation_run+0x550>
    6c95:	c5 c9 57 f6          	vxorpd %xmm6,%xmm6,%xmm6
    6c99:	c5 f9 2f ee          	vcomisd %xmm6,%xmm5
    6c9d:	0f 84 9d fc ff ff    	je     6940 <rotation_run+0xa10>
    6ca3:	e9 d8 f7 ff ff       	jmp    6480 <rotation_run+0x550>
    6ca8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
    6caf:	00
    6cb0:	c4 c1 79 2f f3       	vcomisd %xmm11,%xmm6
    6cb5:	c4 c1 7b 10 69 08    	vmovsd 0x8(%r9),%xmm5
    6cbb:	c4 c1 7b 10 79 10    	vmovsd 0x10(%r9),%xmm7
    6cc1:	0f 84 5f f5 ff ff    	je     6226 <rotation_run+0x2f6>
    6cc7:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    6ccc:	c5 79 28 c8          	vmovapd %xmm0,%xmm9
    6cd0:	c5 79 28 c7          	vmovapd %xmm7,%xmm8
    6cd4:	c5 f9 28 e5          	vmovapd %xmm5,%xmm4
    6cd8:	c5 79 28 ee          	vmovapd %xmm6,%xmm13
    6cdc:	e9 c9 f2 ff ff       	jmp    5faa <rotation_run+0x7a>
    6ce1:	0f 1f 40 00          	nopl   0x0(%rax)
    6ce5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6cec:	00 00 00 00
    6cf0:	c5 7b 10 42 18       	vmovsd 0x18(%rdx),%xmm8
    6cf5:	c5 79 2f c2          	vcomisd %xmm2,%xmm8
    6cf9:	c5 79 29 c1          	vmovapd %xmm8,%xmm1
    6cfd:	0f 84 32 f3 ff ff    	je     6035 <rotation_run+0x105>
    6d03:	49 8b 71 10          	mov    0x10(%r9),%rsi
    6d07:	c4 c1 7a 6f 11       	vmovdqu (%r9),%xmm2
    6d0c:	c4 c1 7b 10 79 10    	vmovsd 0x10(%r9),%xmm7
    6d12:	c5 f9 28 ec          	vmovapd %xmm4,%xmm5
    6d16:	48 89 74 24 e8       	mov    %rsi,-0x18(%rsp)
    6d1b:	c5 f9 7f 54 24 d8    	vmovdqa %xmm2,-0x28(%rsp)
    6d21:	c5 e9 57 d2          	vxorpd %xmm2,%xmm2,%xmm2
    6d25:	c5 f9 2f ea          	vcomisd %xmm2,%xmm5
    6d29:	0f 85 e9 fc ff ff    	jne    6a18 <rotation_run+0xae8>
    6d2f:	c5 f9 2f fa          	vcomisd %xmm2,%xmm7
    6d33:	0f 84 77 fb ff ff    	je     68b0 <rotation_run+0x980>
    6d39:	c5 79 2f c2          	vcomisd %xmm2,%xmm8
    6d3d:	c5 79 29 c1          	vmovapd %xmm8,%xmm1
    6d41:	74 7d                	je     6dc0 <rotation_run+0xe90>
    6d43:	c5 e9 57 d2          	vxorpd %xmm2,%xmm2,%xmm2
    6d47:	c5 f9 2f fa          	vcomisd %xmm2,%xmm7
    6d4b:	0f 84 fb f4 ff ff    	je     624c <rotation_run+0x31c>
    6d51:	0f 1f 40 00          	nopl   0x0(%rax)
    6d55:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6d5c:	00 00 00 00
    6d60:	c5 79 28 c8          	vmovapd %xmm0,%xmm9
    6d64:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    6d68:	c5 79 2f c8          	vcomisd %xmm0,%xmm9
    6d6c:	0f 84 1a f9 ff ff    	je     668c <rotation_run+0x75c>
    6d72:	e9 27 f2 ff ff       	jmp    5f9e <rotation_run+0x6e>
    6d77:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
    6d7e:	00 00
    6d80:	c4 c1 79 2f ea       	vcomisd %xmm10,%xmm5
    6d85:	0f 85 e6 fe ff ff    	jne    6c71 <rotation_run+0xd41>
    6d8b:	c4 c1 79 2f d2       	vcomisd %xmm10,%xmm2
    6d90:	0f 85 77 fb ff ff    	jne    690d <rotation_run+0x9dd>
    6d96:	e9 d0 fb ff ff       	jmp    696b <rotation_run+0xa3b>
    6d9b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    6da0:	c5 f9 2f ce          	vcomisd %xmm6,%xmm1
    6da4:	0f 84 2d f9 ff ff    	je     66d7 <rotation_run+0x7a7>
    6daa:	e9 41 f9 ff ff       	jmp    66f0 <rotation_run+0x7c0>
    6daf:	90                   	nop
    6db0:	c5 79 28 c7          	vmovapd %xmm7,%xmm8
    6db4:	c5 79 28 ee          	vmovapd %xmm6,%xmm13
    6db8:	e9 ed f1 ff ff       	jmp    5faa <rotation_run+0x7a>
    6dbd:	0f 1f 00             	nopl   (%rax)
    6dc0:	c5 fb 11 6c 24 e0    	vmovsd %xmm5,-0x20(%rsp)
    6dc6:	c5 f9 6f 44 24 d8    	vmovdqa -0x28(%rsp),%xmm0
    6dcc:	c5 fb 11 7c 24 e8    	vmovsd %xmm7,-0x18(%rsp)
    6dd2:	48 8b 74 24 e8       	mov    -0x18(%rsp),%rsi
    6dd7:	49 89 71 10          	mov    %rsi,0x10(%r9)
    6ddb:	c4 c1 7a 7f 01       	vmovdqu %xmm0,(%r9)
    6de0:	e9 50 f2 ff ff       	jmp    6035 <rotation_run+0x105>
    6de5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    6dec:	00 00 00 00
    6df0:	c5 fb 10 4a 18       	vmovsd 0x18(%rdx),%xmm1
    6df5:	c4 c1 79 2f ca       	vcomisd %xmm10,%xmm1
    6dfa:	0f 84 90 f9 ff ff    	je     6790 <rotation_run+0x860>
    6e00:	c4 c1 79 2f d2       	vcomisd %xmm10,%xmm2
    6e05:	c4 41 7b 10 60 08    	vmovsd 0x8(%r8),%xmm12
    6e0b:	0f 85 ea fd ff ff    	jne    6bfb <rotation_run+0xccb>
    6e11:	e9 4a f3 ff ff       	jmp    6160 <rotation_run+0x230>
    6e16:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
    6e1d:	00 00 00
    6e20:	c4 41 7b 10 60 08    	vmovsd 0x8(%r8),%xmm12
    6e26:	c5 79 2f e0          	vcomisd %xmm0,%xmm12
    6e2a:	0f 85 c6 fd ff ff    	jne    6bf6 <rotation_run+0xcc6>
    6e30:	c4 c1 79 2f 40 10    	vcomisd 0x10(%r8),%xmm0
    6e36:	0f 85 ba fd ff ff    	jne    6bf6 <rotation_run+0xcc6>
    6e3c:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    6e40:	c5 79 28 e0          	vmovapd %xmm0,%xmm12
    6e44:	c5 f9 28 d0          	vmovapd %xmm0,%xmm2
    6e48:	e9 2b fa ff ff       	jmp    6878 <rotation_run+0x948>
    6e4d:	0f 1f 00             	nopl   (%rax)
    6e50:	c5 f9 2f d7          	vcomisd %xmm7,%xmm2
    6e54:	0f 84 06 f5 ff ff    	je     6360 <rotation_run+0x430>
    6e5a:	c4 c1 7a 6f 39       	vmovdqu (%r9),%xmm7
    6e5f:	49 8b 71 10          	mov    0x10(%r9),%rsi
    6e63:	c4 41 7b 10 51 10    	vmovsd 0x10(%r9),%xmm10
    6e69:	c5 79 28 cd          	vmovapd %xmm5,%xmm9
    6e6d:	48 89 74 24 e8       	mov    %rsi,-0x18(%rsp)
    6e72:	c5 f9 7f 7c 24 d8    	vmovdqa %xmm7,-0x28(%rsp)
    6e78:	e9 03 fc ff ff       	jmp    6a80 <rotation_run+0xb50>
    6e7d:	0f 1f 00             	nopl   (%rax)
    6e80:	c5 79 2f d5          	vcomisd %xmm5,%xmm10
    6e84:	0f 84 06 fa ff ff    	je     6890 <rotation_run+0x960>
    6e8a:	c5 f9 2f e5          	vcomisd %xmm5,%xmm4
    6e8e:	0f 85 99 f4 ff ff    	jne    632d <rotation_run+0x3fd>
    6e94:	c5 f9 2f d5          	vcomisd %xmm5,%xmm2
    6e98:	0f 85 8f f4 ff ff    	jne    632d <rotation_run+0x3fd>
    6e9e:	c5 7b 11 4c 24 e0    	vmovsd %xmm9,-0x20(%rsp)
    6ea4:	c5 f9 6f 44 24 d8    	vmovdqa -0x28(%rsp),%xmm0
    6eaa:	c5 7b 11 54 24 e8    	vmovsd %xmm10,-0x18(%rsp)
    6eb0:	48 8b 74 24 e8       	mov    -0x18(%rsp),%rsi
    6eb5:	49 89 71 10          	mov    %rsi,0x10(%r9)
    6eb9:	c4 c1 7a 7f 01       	vmovdqu %xmm0,(%r9)
    6ebe:	e9 9d f4 ff ff       	jmp    6360 <rotation_run+0x430>
    6ec3:	c5 f9 2f d7          	vcomisd %xmm7,%xmm2
    6ec7:	74 d5                	je     6e9e <rotation_run+0xf6e>
    6ec9:	e9 5f f4 ff ff       	jmp    632d <rotation_run+0x3fd>

Disassembly of section .fini:
