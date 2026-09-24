
/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/tests/quaternions/build/release/bin/main:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

0000000000005030 <quat_run>:
    5030:	48 89 d0             	mov    %rdx,%rax
    5033:	48 89 ca             	mov    %rcx,%rdx
    5036:	83 ff 09             	cmp    $0x9,%edi
    5039:	77 65                	ja     50a0 <quat_run+0x70>
    503b:	4c 8d 15 ce 64 02 00 	lea    0x264ce(%rip),%r10        # 2b510 <_fini+0x164>
    5042:	89 ff                	mov    %edi,%edi
    5044:	49 63 0c ba          	movslq (%r10,%rdi,4),%rcx
    5048:	4c 01 d1             	add    %r10,%rcx
    504b:	ff e1                	jmp    *%rcx
    504d:	85 f6                	test   %esi,%esi
    504f:	74 4f                	je     50a0 <quat_run+0x70>
    5051:	c5 fb 12 1d 77 87 02 	vmovddup 0x28777(%rip),%xmm3        # 2d7d0 <system__secondary_stack__invalid_memory_size+0xa8>
    5058:	00 
    5059:	31 c9                	xor    %ecx,%ecx
    505b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    5060:	c5 fd 6f 00          	vmovdqa (%rax),%ymm0
    5064:	62 f3 fd 28 19 c2 01 	vextractf64x2 $0x1,%ymm0,%xmm2
    506b:	c4 c1 7d 7f 01       	vmovdqa %ymm0,(%r9)
    5070:	c5 f9 15 c8          	vunpckhpd %xmm0,%xmm0,%xmm1
    5074:	62 f3 fd 28 03 c0 03 	valignq $0x3,%ymm0,%ymm0,%ymm0
    507b:	c5 f1 14 ca          	vunpcklpd %xmm2,%xmm1,%xmm1
    507f:	c5 f1 57 cb          	vxorpd %xmm3,%xmm1,%xmm1
    5083:	c4 c1 79 11 49 08    	vmovupd %xmm1,0x8(%r9)
    5089:	c5 f9 57 05 3f 87 02 	vxorpd 0x2873f(%rip),%xmm0,%xmm0        # 2d7d0 <system__secondary_stack__invalid_memory_size+0xa8>
    5090:	00 
    5091:	c4 c1 7b 11 41 18    	vmovsd %xmm0,0x18(%r9)
    5097:	ff c1                	inc    %ecx
    5099:	39 ce                	cmp    %ecx,%esi
    509b:	75 c3                	jne    5060 <quat_run+0x30>
    509d:	c5 f8 77             	vzeroupper
    50a0:	c5 f1 57 c9          	vxorpd %xmm1,%xmm1,%xmm1
    50a4:	c5 f9 28 c1          	vmovapd %xmm1,%xmm0
    50a8:	c3                   	ret
    50a9:	85 f6                	test   %esi,%esi
    50ab:	74 f3                	je     50a0 <quat_run+0x70>
    50ad:	c5 7b 10 15 4b 63 02 	vmovsd 0x2634b(%rip),%xmm10        # 2b400 <_fini+0x54>
    50b4:	00 
    50b5:	31 c9                	xor    %ecx,%ecx
    50b7:	c4 41 21 57 db       	vxorpd %xmm11,%xmm11,%xmm11
    50bc:	eb 34                	jmp    50f2 <quat_run+0xc2>
    50be:	c4 c1 79 2f eb       	vcomisd %xmm11,%xmm5
    50c3:	75 47                	jne    510c <quat_run+0xdc>
    50c5:	c4 c1 79 2f cb       	vcomisd %xmm11,%xmm1
    50ca:	75 40                	jne    510c <quat_run+0xdc>
    50cc:	c4 c1 79 2f f3       	vcomisd %xmm11,%xmm6
    50d1:	75 39                	jne    510c <quat_run+0xdc>
    50d3:	62 f1 fd 48 28 05 23 	vmovapd 0x26323(%rip),%zmm0        # 2b400 <_fini+0x54>
    50da:	63 02 00 
    50dd:	0f 1f 00             	nopl   (%rax)
    50e0:	62 d1 fd 48 29 01    	vmovapd %zmm0,(%r9)
    50e6:	c4 c1 7b 11 51 40    	vmovsd %xmm2,0x40(%r9)
    50ec:	ff c1                	inc    %ecx
    50ee:	39 ce                	cmp    %ecx,%esi
    50f0:	74 ab                	je     509d <quat_run+0x6d>
    50f2:	c5 fb 10 10          	vmovsd (%rax),%xmm2
    50f6:	c5 fb 10 68 08       	vmovsd 0x8(%rax),%xmm5
    50fb:	c5 fb 10 48 10       	vmovsd 0x10(%rax),%xmm1
    5100:	c5 fb 10 70 18       	vmovsd 0x18(%rax),%xmm6
    5105:	c4 c1 79 2f d2       	vcomisd %xmm10,%xmm2
    510a:	74 b2                	je     50be <quat_run+0x8e>
    510c:	c5 6b 59 ee          	vmulsd %xmm6,%xmm2,%xmm13
    5110:	c5 d3 59 e1          	vmulsd %xmm1,%xmm5,%xmm4
    5114:	c5 53 59 e5          	vmulsd %xmm5,%xmm5,%xmm12
    5118:	c5 d3 59 de          	vmulsd %xmm6,%xmm5,%xmm3
    511c:	c5 6b 59 f1          	vmulsd %xmm1,%xmm2,%xmm14
    5120:	c5 eb 59 c2          	vmulsd %xmm2,%xmm2,%xmm0
    5124:	c5 eb 59 d5          	vmulsd %xmm5,%xmm2,%xmm2
    5128:	c4 c1 5b 5c ed       	vsubsd %xmm13,%xmm4,%xmm5
    512d:	c5 73 59 c9          	vmulsd %xmm1,%xmm1,%xmm9
    5131:	c4 c1 5b 58 e5       	vaddsd %xmm13,%xmm4,%xmm4
    5136:	c5 f3 59 ce          	vmulsd %xmm6,%xmm1,%xmm1
    513a:	c5 4b 59 c6          	vmulsd %xmm6,%xmm6,%xmm8
    513e:	c4 c1 7b 5c fc       	vsubsd %xmm12,%xmm0,%xmm7
    5143:	c4 c1 7b 58 c4       	vaddsd %xmm12,%xmm0,%xmm0
    5148:	c5 53 58 e5          	vaddsd %xmm5,%xmm5,%xmm12
    514c:	c4 c1 63 58 ee       	vaddsd %xmm14,%xmm3,%xmm5
    5151:	c5 73 5c ea          	vsubsd %xmm2,%xmm1,%xmm13
    5155:	c4 c1 63 5c de       	vsubsd %xmm14,%xmm3,%xmm3
    515a:	c5 f3 58 ca          	vaddsd %xmm2,%xmm1,%xmm1
    515e:	c4 c1 7b 5c c1       	vsubsd %xmm9,%xmm0,%xmm0
    5163:	c5 d3 58 f5          	vaddsd %xmm5,%xmm5,%xmm6
    5167:	c5 db 58 ec          	vaddsd %xmm4,%xmm4,%xmm5
    516b:	c5 b3 58 e7          	vaddsd %xmm7,%xmm9,%xmm4
    516f:	c4 41 13 58 ed       	vaddsd %xmm13,%xmm13,%xmm13
    5174:	c5 f3 58 c9          	vaddsd %xmm1,%xmm1,%xmm1
    5178:	c4 c1 7b 5c c0       	vsubsd %xmm8,%xmm0,%xmm0
    517d:	c5 e3 58 db          	vaddsd %xmm3,%xmm3,%xmm3
    5181:	c4 c1 43 5c f9       	vsubsd %xmm9,%xmm7,%xmm7
    5186:	c5 c9 14 ed          	vunpcklpd %xmm5,%xmm6,%xmm5
    518a:	c4 c1 5b 5c e0       	vsubsd %xmm8,%xmm4,%xmm4
    518f:	c4 c1 79 14 c4       	vunpcklpd %xmm12,%xmm0,%xmm0
    5194:	c5 e1 14 d9          	vunpcklpd %xmm1,%xmm3,%xmm3
    5198:	62 f3 fd 28 18 c5 01 	vinsertf64x2 $0x1,%xmm5,%ymm0,%ymm0
    519f:	c4 c1 43 58 d0       	vaddsd %xmm8,%xmm7,%xmm2
    51a4:	c4 c1 59 14 cd       	vunpcklpd %xmm13,%xmm4,%xmm1
    51a9:	62 f3 f5 28 18 cb 01 	vinsertf64x2 $0x1,%xmm3,%ymm1,%ymm1
    51b0:	62 f3 fd 48 1a c1 01 	vinsertf64x4 $0x1,%ymm1,%zmm0,%zmm0
    51b7:	e9 24 ff ff ff       	jmp    50e0 <quat_run+0xb0>
    51bc:	85 f6                	test   %esi,%esi
    51be:	0f 84 dc fe ff ff    	je     50a0 <quat_run+0x70>
    51c4:	c5 fd 28 05 34 62 02 	vmovapd 0x26234(%rip),%ymm0        # 2b400 <_fini+0x54>
    51cb:	00 
    51cc:	31 c9                	xor    %ecx,%ecx
    51ce:	66 90                	xchg   %ax,%ax
    51d0:	c4 c1 7d 29 01       	vmovapd %ymm0,(%r9)
    51d5:	ff c1                	inc    %ecx
    51d7:	39 ce                	cmp    %ecx,%esi
    51d9:	75 f5                	jne    51d0 <quat_run+0x1a0>
    51db:	e9 bd fe ff ff       	jmp    509d <quat_run+0x6d>
    51e0:	85 f6                	test   %esi,%esi
    51e2:	0f 84 b8 fe ff ff    	je     50a0 <quat_run+0x70>
    51e8:	31 c9                	xor    %ecx,%ecx
    51ea:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    51f0:	c5 fb 10 40 08       	vmovsd 0x8(%rax),%xmm0
    51f5:	c5 fb 10 48 10       	vmovsd 0x10(%rax),%xmm1
    51fa:	c5 fb 10 50 18       	vmovsd 0x18(%rax),%xmm2
    51ff:	c5 fb 10 38          	vmovsd (%rax),%xmm7
    5203:	c5 f9 57 05 c5 85 02 	vxorpd 0x285c5(%rip),%xmm0,%xmm0        # 2d7d0 <system__secondary_stack__invalid_memory_size+0xa8>
    520a:	00 
    520b:	c5 f1 57 0d bd 85 02 	vxorpd 0x285bd(%rip),%xmm1,%xmm1        # 2d7d0 <system__secondary_stack__invalid_memory_size+0xa8>
    5212:	00 
    5213:	c5 e9 57 15 b5 85 02 	vxorpd 0x285b5(%rip),%xmm2,%xmm2        # 2d7d0 <system__secondary_stack__invalid_memory_size+0xa8>
    521a:	00 
    521b:	c5 c1 14 c0          	vunpcklpd %xmm0,%xmm7,%xmm0
    521f:	c5 f1 14 ca          	vunpcklpd %xmm2,%xmm1,%xmm1
    5223:	62 f3 fd 28 18 c1 01 	vinsertf64x2 $0x1,%xmm1,%ymm0,%ymm0
    522a:	c4 c1 7d 29 01       	vmovapd %ymm0,(%r9)
    522f:	ff c1                	inc    %ecx
    5231:	39 ce                	cmp    %ecx,%esi
    5233:	75 bb                	jne    51f0 <quat_run+0x1c0>
    5235:	e9 63 fe ff ff       	jmp    509d <quat_run+0x6d>
    523a:	85 f6                	test   %esi,%esi
    523c:	0f 84 5e fe ff ff    	je     50a0 <quat_run+0x70>
    5242:	31 c9                	xor    %ecx,%ecx
    5244:	90                   	nop
    5245:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    524c:	00 00 00 00 
    5250:	c5 fd 28 08          	vmovapd (%rax),%ymm1
    5254:	c5 fd 28 02          	vmovapd (%rdx),%ymm0
    5258:	c4 e2 7d 19 d1       	vbroadcastsd %xmm1,%ymm2
    525d:	c4 e3 fd 01 e0 4e    	vpermpd $0x4e,%ymm0,%ymm4
    5263:	c4 e3 fd 01 d8 1b    	vpermpd $0x1b,%ymm0,%ymm3
    5269:	c4 e3 fd 01 e9 55    	vpermpd $0x55,%ymm1,%ymm5
    526f:	c5 ed 59 d0          	vmulpd %ymm0,%ymm2,%ymm2
    5273:	c4 e3 7d 05 c0 05    	vpermilpd $0x5,%ymm0,%ymm0
    5279:	c5 fd 59 c5          	vmulpd %ymm5,%ymm0,%ymm0
    527d:	c5 ed d0 d0          	vaddsubpd %ymm0,%ymm2,%ymm2
    5281:	c4 e3 fd 01 c1 aa    	vpermpd $0xaa,%ymm1,%ymm0
    5287:	c4 e3 fd 01 c9 ff    	vpermpd $0xff,%ymm1,%ymm1
    528d:	c5 fd 59 c4          	vmulpd %ymm4,%ymm0,%ymm0
    5291:	c5 f5 59 cb          	vmulpd %ymm3,%ymm1,%ymm1
    5295:	c5 ed 5c e0          	vsubpd %ymm0,%ymm2,%ymm4
    5299:	c5 fd 58 c2          	vaddpd %ymm2,%ymm0,%ymm0
    529d:	c4 e3 7d 0d c4 09    	vblendpd $0x9,%ymm4,%ymm0,%ymm0
    52a3:	c5 fd 5c d1          	vsubpd %ymm1,%ymm0,%ymm2
    52a7:	c5 fd 58 c1          	vaddpd %ymm1,%ymm0,%ymm0
    52ab:	c4 e3 7d 0d c2 03    	vblendpd $0x3,%ymm2,%ymm0,%ymm0
    52b1:	c4 c1 7d 29 01       	vmovapd %ymm0,(%r9)
    52b6:	ff c1                	inc    %ecx
    52b8:	39 ce                	cmp    %ecx,%esi
    52ba:	75 94                	jne    5250 <quat_run+0x220>
    52bc:	e9 dc fd ff ff       	jmp    509d <quat_run+0x6d>
    52c1:	85 f6                	test   %esi,%esi
    52c3:	0f 84 d7 fd ff ff    	je     50a0 <quat_run+0x70>
    52c9:	c5 fd 6f 3d af 62 02 	vmovdqa 0x262af(%rip),%ymm7        # 2b580 <__gnat_ada_main_program_name+0x28>
    52d0:	00 
    52d1:	c5 fd 6f 35 c7 62 02 	vmovdqa 0x262c7(%rip),%ymm6        # 2b5a0 <__gnat_ada_main_program_name+0x48>
    52d8:	00 
    52d9:	31 c9                	xor    %ecx,%ecx
    52db:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    52e0:	c5 fd 6f 00          	vmovdqa (%rax),%ymm0
    52e4:	c4 c1 7d 7f 01       	vmovdqa %ymm0,(%r9)
    52e9:	c5 fd 28 0a          	vmovapd (%rdx),%ymm1
    52ed:	c5 f9 28 d0          	vmovapd %xmm0,%xmm2
    52f1:	c5 f9 15 e8          	vunpckhpd %xmm0,%xmm0,%xmm5
    52f5:	62 f3 fd 28 19 c4 01 	vextractf64x2 $0x1,%ymm0,%xmm4
    52fc:	c4 e2 7d 19 ed       	vbroadcastsd %xmm5,%ymm5
    5301:	c4 e2 7d 19 d2       	vbroadcastsd %xmm2,%ymm2
    5306:	62 f3 fd 28 03 c0 03 	valignq $0x3,%ymm0,%ymm0,%ymm0
    530d:	c4 e3 7d 05 d9 05    	vpermilpd $0x5,%ymm1,%ymm3
    5313:	c5 ed 59 d1          	vmulpd %ymm1,%ymm2,%ymm2
    5317:	c4 e2 7d 19 e4       	vbroadcastsd %xmm4,%ymm4
    531c:	c5 e5 59 dd          	vmulpd %ymm5,%ymm3,%ymm3
    5320:	c4 e2 7d 19 c0       	vbroadcastsd %xmm0,%ymm0
    5325:	c5 ed d0 d3          	vaddsubpd %ymm3,%ymm2,%ymm2
    5329:	c5 fd 59 c1          	vmulpd %ymm1,%ymm0,%ymm0
    532d:	c4 e3 fd 01 c9 4e    	vpermpd $0x4e,%ymm1,%ymm1
    5333:	c5 f5 59 cc          	vmulpd %ymm4,%ymm1,%ymm1
    5337:	c5 ed 5c d9          	vsubpd %ymm1,%ymm2,%ymm3
    533b:	c5 f5 58 ca          	vaddpd %ymm2,%ymm1,%ymm1
    533f:	62 f2 c5 28 7f d9    	vpermt2pd %ymm1,%ymm7,%ymm3
    5345:	c5 e5 5c c8          	vsubpd %ymm0,%ymm3,%ymm1
    5349:	c5 fd 58 c3          	vaddpd %ymm3,%ymm0,%ymm0
    534d:	62 f2 cd 28 7f c8    	vpermt2pd %ymm0,%ymm6,%ymm1
    5353:	c4 c1 7d 29 09       	vmovapd %ymm1,(%r9)
    5358:	ff c1                	inc    %ecx
    535a:	39 ce                	cmp    %ecx,%esi
    535c:	75 82                	jne    52e0 <quat_run+0x2b0>
    535e:	e9 3a fd ff ff       	jmp    509d <quat_run+0x6d>
    5363:	85 f6                	test   %esi,%esi
    5365:	0f 84 35 fd ff ff    	je     50a0 <quat_run+0x70>
    536b:	c5 f1 57 c9          	vxorpd %xmm1,%xmm1,%xmm1
    536f:	31 c9                	xor    %ecx,%ecx
    5371:	c5 f9 28 e9          	vmovapd %xmm1,%xmm5
    5375:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    537c:	00 00 00 00 
    5380:	c5 fb 10 00          	vmovsd (%rax),%xmm0
    5384:	c5 fb 10 60 08       	vmovsd 0x8(%rax),%xmm4
    5389:	c5 fb 10 58 10       	vmovsd 0x10(%rax),%xmm3
    538e:	c5 fb 10 50 18       	vmovsd 0x18(%rax),%xmm2
    5393:	c5 fb 59 c0          	vmulsd %xmm0,%xmm0,%xmm0
    5397:	c5 db 59 e4          	vmulsd %xmm4,%xmm4,%xmm4
    539b:	c5 e3 59 db          	vmulsd %xmm3,%xmm3,%xmm3
    539f:	c5 eb 59 d2          	vmulsd %xmm2,%xmm2,%xmm2
    53a3:	c5 fb 58 c4          	vaddsd %xmm4,%xmm0,%xmm0
    53a7:	c5 fb 58 c3          	vaddsd %xmm3,%xmm0,%xmm0
    53ab:	c5 fb 58 c2          	vaddsd %xmm2,%xmm0,%xmm0
    53af:	c5 f9 2f c5          	vcomisd %xmm5,%xmm0
    53b3:	74 04                	je     53b9 <quat_run+0x389>
    53b5:	c5 fb 51 c0          	vsqrtsd %xmm0,%xmm0,%xmm0
    53b9:	c5 f3 58 c8          	vaddsd %xmm0,%xmm1,%xmm1
    53bd:	ff c1                	inc    %ecx
    53bf:	39 ce                	cmp    %ecx,%esi
    53c1:	75 bd                	jne    5380 <quat_run+0x350>
    53c3:	e9 dc fc ff ff       	jmp    50a4 <quat_run+0x74>
    53c8:	85 f6                	test   %esi,%esi
    53ca:	0f 84 d0 fc ff ff    	je     50a0 <quat_run+0x70>
    53d0:	c5 f1 57 c9          	vxorpd %xmm1,%xmm1,%xmm1
    53d4:	c5 fb 10 35 24 60 02 	vmovsd 0x26024(%rip),%xmm6        # 2b400 <_fini+0x54>
    53db:	00 
    53dc:	c5 7b 10 05 f4 82 02 	vmovsd 0x282f4(%rip),%xmm8        # 2d6d8 <system__os_lib__standin+0xc>
    53e3:	00 
    53e4:	c5 fd 28 3d 14 60 02 	vmovapd 0x26014(%rip),%ymm7        # 2b400 <_fini+0x54>
    53eb:	00 
    53ec:	31 c9                	xor    %ecx,%ecx
    53ee:	c5 f9 28 e9          	vmovapd %xmm1,%xmm5
    53f2:	eb 17                	jmp    540b <quat_run+0x3db>
    53f4:	c4 c1 7d 29 39       	vmovapd %ymm7,(%r9)
    53f9:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
    53fd:	c5 f3 58 c8          	vaddsd %xmm0,%xmm1,%xmm1
    5401:	ff c1                	inc    %ecx
    5403:	39 ce                	cmp    %ecx,%esi
    5405:	0f 84 7e 01 00 00    	je     5589 <quat_run+0x559>
    540b:	c5 fd 6f 20          	vmovdqa (%rax),%ymm4
    540f:	c5 dd 59 d4          	vmulpd %ymm4,%ymm4,%ymm2
    5413:	c4 c1 7d 7f 21       	vmovdqa %ymm4,(%r9)
    5418:	c5 e9 15 da          	vunpckhpd %xmm2,%xmm2,%xmm3
    541c:	c5 eb 58 c3          	vaddsd %xmm3,%xmm2,%xmm0
    5420:	62 f3 fd 28 19 d3 01 	vextractf64x2 $0x1,%ymm2,%xmm3
    5427:	62 f3 ed 28 03 d2 03 	valignq $0x3,%ymm2,%ymm2,%ymm2
    542e:	c5 fb 58 c3          	vaddsd %xmm3,%xmm0,%xmm0
    5432:	c5 fb 58 c2          	vaddsd %xmm2,%xmm0,%xmm0
    5436:	c5 f9 2f c5          	vcomisd %xmm5,%xmm0
    543a:	74 b8                	je     53f4 <quat_run+0x3c4>
    543c:	c5 f9 54 05 9c 83 02 	vandpd 0x2839c(%rip),%xmm0,%xmm0        # 2d7e0 <system__secondary_stack__invalid_memory_size+0xb8>
    5443:	00 
    5444:	c5 f9 2f c6          	vcomisd %xmm6,%xmm0
    5448:	74 b3                	je     53fd <quat_run+0x3cd>
    544a:	c5 fb 51 c0          	vsqrtsd %xmm0,%xmm0,%xmm0
    544e:	c5 79 2f c0          	vcomisd %xmm0,%xmm8
    5452:	0f 86 39 01 00 00    	jbe    5591 <quat_run+0x561>
    5458:	c5 fd 28 15 a0 5f 02 	vmovapd 0x25fa0(%rip),%ymm2        # 2b400 <_fini+0x54>
    545f:	00 
    5460:	c4 c1 7d 29 11       	vmovapd %ymm2,(%r9)
    5465:	eb 96                	jmp    53fd <quat_run+0x3cd>
    5467:	85 f6                	test   %esi,%esi
    5469:	0f 84 31 fc ff ff    	je     50a0 <quat_run+0x70>
    546f:	c5 7b 10 1d 89 5f 02 	vmovsd 0x25f89(%rip),%xmm11        # 2b400 <_fini+0x54>
    5476:	00 
    5477:	31 c9                	xor    %ecx,%ecx
    5479:	c4 41 29 57 d2       	vxorpd %xmm10,%xmm10,%xmm10
    547e:	66 90                	xchg   %ax,%ax
    5480:	c4 c1 7b 10 28       	vmovsd (%r8),%xmm5
    5485:	c4 c1 79 2f ea       	vcomisd %xmm10,%xmm5
    548a:	75 14                	jne    54a0 <quat_run+0x470>
    548c:	c4 41 79 2f 50 08    	vcomisd 0x8(%r8),%xmm10
    5492:	75 0c                	jne    54a0 <quat_run+0x470>
    5494:	c4 41 79 2f 50 10    	vcomisd 0x10(%r8),%xmm10
    549a:	0f 84 1f 01 00 00    	je     55bf <quat_run+0x58f>
    54a0:	c5 fb 10 18          	vmovsd (%rax),%xmm3
    54a4:	c5 fb 10 70 08       	vmovsd 0x8(%rax),%xmm6
    54a9:	c5 fb 10 78 10       	vmovsd 0x10(%rax),%xmm7
    54ae:	c5 fb 10 50 18       	vmovsd 0x18(%rax),%xmm2
    54b3:	c4 c1 79 2f db       	vcomisd %xmm11,%xmm3
    54b8:	75 26                	jne    54e0 <quat_run+0x4b0>
    54ba:	c4 c1 79 2f f2       	vcomisd %xmm10,%xmm6
    54bf:	75 1f                	jne    54e0 <quat_run+0x4b0>
    54c1:	c4 c1 79 2f fa       	vcomisd %xmm10,%xmm7
    54c6:	75 18                	jne    54e0 <quat_run+0x4b0>
    54c8:	c4 c1 79 2f d2       	vcomisd %xmm10,%xmm2
    54cd:	0f 84 06 01 00 00    	je     55d9 <quat_run+0x5a9>
    54d3:	66 90                	xchg   %ax,%ax
    54d5:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
    54dc:	00 00 00 00 
    54e0:	c4 41 7b 10 40 10    	vmovsd 0x10(%r8),%xmm8
    54e6:	c4 41 7b 10 48 08    	vmovsd 0x8(%r8),%xmm9
    54ec:	c5 d3 59 e3          	vmulsd %xmm3,%xmm5,%xmm4
    54f0:	c5 bb 59 c7          	vmulsd %xmm7,%xmm8,%xmm0
    54f4:	c4 c1 63 59 c9       	vmulsd %xmm9,%xmm3,%xmm1
    54f9:	c4 c1 63 59 d8       	vmulsd %xmm8,%xmm3,%xmm3
    54fe:	c5 db 58 e0          	vaddsd %xmm0,%xmm4,%xmm4
    5502:	c5 b3 59 c2          	vmulsd %xmm2,%xmm9,%xmm0
    5506:	c5 db 5c e0          	vsubsd %xmm0,%xmm4,%xmm4
    550a:	c5 d3 59 c2          	vmulsd %xmm2,%xmm5,%xmm0
    550e:	c5 f3 58 c0          	vaddsd %xmm0,%xmm1,%xmm0
    5512:	c5 bb 59 ce          	vmulsd %xmm6,%xmm8,%xmm1
    5516:	c5 fb 5c c1          	vsubsd %xmm1,%xmm0,%xmm0
    551a:	c5 b3 59 ce          	vmulsd %xmm6,%xmm9,%xmm1
    551e:	c5 e3 58 d9          	vaddsd %xmm1,%xmm3,%xmm3
    5522:	c5 d3 59 cf          	vmulsd %xmm7,%xmm5,%xmm1
    5526:	c5 7b 59 e2          	vmulsd %xmm2,%xmm0,%xmm12
    552a:	c5 db 59 d2          	vmulsd %xmm2,%xmm4,%xmm2
    552e:	c5 fb 59 c6          	vmulsd %xmm6,%xmm0,%xmm0
    5532:	c5 db 59 e7          	vmulsd %xmm7,%xmm4,%xmm4
    5536:	c5 e3 5c d9          	vsubsd %xmm1,%xmm3,%xmm3
    553a:	c5 fb 5c c4          	vsubsd %xmm4,%xmm0,%xmm0
    553e:	c5 e3 59 cf          	vmulsd %xmm7,%xmm3,%xmm1
    5542:	c5 e3 59 de          	vmulsd %xmm6,%xmm3,%xmm3
    5546:	c5 fb 58 c0          	vaddsd %xmm0,%xmm0,%xmm0
    554a:	c4 c1 73 5c cc       	vsubsd %xmm12,%xmm1,%xmm1
    554f:	c5 eb 5c d3          	vsubsd %xmm3,%xmm2,%xmm2
    5553:	c4 c1 7b 58 c0       	vaddsd %xmm8,%xmm0,%xmm0
    5558:	c5 f3 58 c9          	vaddsd %xmm1,%xmm1,%xmm1
    555c:	c5 eb 58 d2          	vaddsd %xmm2,%xmm2,%xmm2
    5560:	c4 c1 7b 11 41 10    	vmovsd %xmm0,0x10(%r9)
    5566:	c5 f3 58 cd          	vaddsd %xmm5,%xmm1,%xmm1
    556a:	c4 c1 6b 58 d1       	vaddsd %xmm9,%xmm2,%xmm2
    556f:	c4 c1 7b 11 09       	vmovsd %xmm1,(%r9)
    5574:	c4 c1 7b 11 51 08    	vmovsd %xmm2,0x8(%r9)
    557a:	ff c1                	inc    %ecx
    557c:	39 ce                	cmp    %ecx,%esi
    557e:	0f 85 fc fe ff ff    	jne    5480 <quat_run+0x450>
    5584:	e9 17 fb ff ff       	jmp    50a0 <quat_run+0x70>
    5589:	c5 f8 77             	vzeroupper
    558c:	e9 13 fb ff ff       	jmp    50a4 <quat_run+0x74>
    5591:	c5 fb 5c d6          	vsubsd %xmm6,%xmm0,%xmm2
    5595:	c5 e9 54 15 43 82 02 	vandpd 0x28243(%rip),%xmm2,%xmm2        # 2d7e0 <system__secondary_stack__invalid_memory_size+0xb8>
    559c:	00 
    559d:	c4 c1 79 2f d0       	vcomisd %xmm8,%xmm2
    55a2:	0f 86 55 fe ff ff    	jbe    53fd <quat_run+0x3cd>
    55a8:	c5 cb 5e d0          	vdivsd %xmm0,%xmm6,%xmm2
    55ac:	c4 e2 7d 19 d2       	vbroadcastsd %xmm2,%ymm2
    55b1:	c5 ed 59 d4          	vmulpd %ymm4,%ymm2,%ymm2
    55b5:	c4 c1 7d 29 11       	vmovapd %ymm2,(%r9)
    55ba:	e9 3e fe ff ff       	jmp    53fd <quat_run+0x3cd>
    55bf:	c5 f9 6f 05 09 5e 02 	vmovdqa 0x25e09(%rip),%xmm0        # 2b3d0 <_fini+0x24>
    55c6:	00 
    55c7:	48 8b 3d 12 5e 02 00 	mov    0x25e12(%rip),%rdi        # 2b3e0 <_fini+0x34>
    55ce:	49 89 79 10          	mov    %rdi,0x10(%r9)
    55d2:	c4 c1 79 7f 01       	vmovdqa %xmm0,(%r9)
    55d7:	eb a1                	jmp    557a <quat_run+0x54a>
    55d9:	c4 c1 79 6f 00       	vmovdqa (%r8),%xmm0
    55de:	c4 c1 79 7f 01       	vmovdqa %xmm0,(%r9)
    55e3:	49 8b 78 10          	mov    0x10(%r8),%rdi
    55e7:	49 89 79 10          	mov    %rdi,0x10(%r9)
    55eb:	eb 8d                	jmp    557a <quat_run+0x54a>

Disassembly of section .fini:
