
/var/tmp/sparkling-dynamics-base-build-r1882-20261028/current/bin/movement_all_probe:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

00000000001001a0 <mj__data__inertia_phase__solve_acceleration>:
  1001a0:	55                   	push   %rbp
  1001a1:	48 89 e5             	mov    %rsp,%rbp
  1001a4:	41 57                	push   %r15
  1001a6:	41 56                	push   %r14
  1001a8:	41 55                	push   %r13
  1001aa:	41 54                	push   %r12
  1001ac:	41 52                	push   %r10
  1001ae:	53                   	push   %rbx
  1001af:	48 8d 45 10          	lea    0x10(%rbp),%rax
  1001b3:	48 81 ec d0 01 00 00 	sub    $0x1d0,%rsp
  1001ba:	48 89 fb             	mov    %rdi,%rbx
  1001bd:	48 8d bd 90 fe ff ff 	lea    -0x170(%rbp),%rdi
  1001c4:	48 89 b5 30 fe ff ff 	mov    %rsi,-0x1d0(%rbp)
  1001cb:	48 89 95 38 fe ff ff 	mov    %rdx,-0x1c8(%rbp)
  1001d2:	48 89 85 08 ff ff ff 	mov    %rax,-0xf8(%rbp)
  1001d9:	e8 12 15 03 00       	call   1316f0 <system__secondary_stack__ss_mark>
  1001de:	80 bb 96 80 00 00 00 	cmpb   $0x0,0x8096(%rbx)
  1001e5:	74 1b                	je     100202 <mj__data__inertia_phase__solve_acceleration+0x62>
  1001e7:	80 bb 98 80 00 00 00 	cmpb   $0x0,0x8098(%rbx)
  1001ee:	74 12                	je     100202 <mj__data__inertia_phase__solve_acceleration+0x62>
  1001f0:	80 bb 99 80 00 00 00 	cmpb   $0x0,0x8099(%rbx)
  1001f7:	74 09                	je     100202 <mj__data__inertia_phase__solve_acceleration+0x62>
  1001f9:	80 bb 9a 80 00 00 00 	cmpb   $0x0,0x809a(%rbx)
  100200:	75 2e                	jne    100230 <mj__data__inertia_phase__solve_acceleration+0x90>
  100202:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  100208:	48 8d bd 90 fe ff ff 	lea    -0x170(%rbp),%rdi
  10020f:	e8 fc 14 03 00       	call   131710 <system__secondary_stack__ss_release>
  100214:	44 89 e0             	mov    %r12d,%eax
  100217:	48 81 c4 d0 01 00 00 	add    $0x1d0,%rsp
  10021e:	5b                   	pop    %rbx
  10021f:	41 5a                	pop    %r10
  100221:	41 5c                	pop    %r12
  100223:	41 5d                	pop    %r13
  100225:	41 5e                	pop    %r14
  100227:	41 5f                	pop    %r15
  100229:	5d                   	pop    %rbp
  10022a:	c3                   	ret
  10022b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  100230:	48 8d bd f0 fe ff ff 	lea    -0x110(%rbp),%rdi
  100237:	e8 b4 14 03 00       	call   1316f0 <system__secondary_stack__ss_mark>
  10023c:	c6 83 9b 80 00 00 00 	movb   $0x0,0x809b(%rbx)
  100243:	4c 8b ab d8 81 00 00 	mov    0x81d8(%rbx),%r13
  10024a:	4d 85 ed             	test   %r13,%r13
  10024d:	0f 84 36 11 00 00    	je     101389 <mj__data__inertia_phase__solve_acceleration+0x11e9>
  100253:	4c 8b bb c8 81 00 00 	mov    0x81c8(%rbx),%r15
  10025a:	4d 85 ff             	test   %r15,%r15
  10025d:	0f 84 15 11 00 00    	je     101378 <mj__data__inertia_phase__solve_acceleration+0x11d8>
  100263:	4c 8b b3 e8 81 00 00 	mov    0x81e8(%rbx),%r14
  10026a:	4d 85 f6             	test   %r14,%r14
  10026d:	0f 84 f4 10 00 00    	je     101367 <mj__data__inertia_phase__solve_acceleration+0x11c7>
  100273:	4c 8b a3 f8 81 00 00 	mov    0x81f8(%rbx),%r12
  10027a:	4d 85 e4             	test   %r12,%r12
  10027d:	0f 84 d3 10 00 00    	je     101356 <mj__data__inertia_phase__solve_acceleration+0x11b6>
  100283:	4c 8b 8b 18 81 00 00 	mov    0x8118(%rbx),%r9
  10028a:	4d 85 c9             	test   %r9,%r9
  10028d:	0f 84 b2 10 00 00    	je     101345 <mj__data__inertia_phase__solve_acceleration+0x11a5>
  100293:	4c 8b 93 18 82 00 00 	mov    0x8218(%rbx),%r10
  10029a:	4d 85 d2             	test   %r10,%r10
  10029d:	0f 84 91 10 00 00    	je     101334 <mj__data__inertia_phase__solve_acceleration+0x1194>
  1002a3:	4c 8b 9b e0 81 00 00 	mov    0x81e0(%rbx),%r11
  1002aa:	c5 fa 7e ab d0 81 00 	vmovq  0x81d0(%rbx),%xmm5
  1002b1:	00 
  1002b2:	c5 fa 7e a3 f0 81 00 	vmovq  0x81f0(%rbx),%xmm4
  1002b9:	00 
  1002ba:	c5 fa 7e 9b 00 82 00 	vmovq  0x8200(%rbx),%xmm3
  1002c1:	00 
  1002c2:	c5 fa 7e 93 20 81 00 	vmovq  0x8120(%rbx),%xmm2
  1002c9:	00 
  1002ca:	48 8b 83 20 82 00 00 	mov    0x8220(%rbx),%rax
  1002d1:	8b 08                	mov    (%rax),%ecx
  1002d3:	8b 50 04             	mov    0x4(%rax),%edx
  1002d6:	39 d1                	cmp    %edx,%ecx
  1002d8:	0f 8f 92 02 00 00    	jg     100570 <mj__data__inertia_phase__solve_acceleration+0x3d0>
  1002de:	48 63 c1             	movslq %ecx,%rax
  1002e1:	c4 e1 f9 7e d9       	vmovq  %xmm3,%rcx
  1002e6:	c4 e1 f9 7e d6       	vmovq  %xmm2,%rsi
  1002eb:	c5 fb 10 0d 05 47 05 	vmovsd 0x54705(%rip),%xmm1        # 1549f8 <ada__numerics__long_elementary_functions__two_pi+0x288>
  1002f2:	00 
  1002f3:	8b 09                	mov    (%rcx),%ecx
  1002f5:	8b 36                	mov    (%rsi),%esi
  1002f7:	c4 c1 f9 7e e8       	vmovq  %xmm5,%r8
  1002fc:	c4 e1 f9 7e e7       	vmovq  %xmm4,%rdi
  100301:	45 8b 00             	mov    (%r8),%r8d
  100304:	8b 3f                	mov    (%rdi),%edi
  100306:	48 89 85 18 fe ff ff 	mov    %rax,-0x1e8(%rbp)
  10030d:	c5 7b 10 05 6b 46 05 	vmovsd 0x5466b(%rip),%xmm8        # 154980 <ada__numerics__long_elementary_functions__two_pi+0x210>
  100314:	00 
  100315:	48 ff c8             	dec    %rax
  100318:	89 8d 44 fe ff ff    	mov    %ecx,-0x1bc(%rbp)
  10031e:	49 63 0b             	movslq (%r11),%rcx
  100321:	45 8b 5b 04          	mov    0x4(%r11),%r11d
  100325:	89 b5 48 fe ff ff    	mov    %esi,-0x1b8(%rbp)
  10032b:	44 89 9d 40 fe ff ff 	mov    %r11d,-0x1c0(%rbp)
  100332:	c4 c1 f9 7e eb       	vmovq  %xmm5,%r11
  100337:	48 89 ce             	mov    %rcx,%rsi
  10033a:	48 f7 d9             	neg    %rcx
  10033d:	45 8b 5b 04          	mov    0x4(%r11),%r11d
  100341:	4d 8d 6c cd 00       	lea    0x0(%r13,%rcx,8),%r13
  100346:	49 63 c8             	movslq %r8d,%rcx
  100349:	48 f7 d9             	neg    %rcx
  10034c:	4d 8d 3c cf          	lea    (%r15,%rcx,8),%r15
  100350:	48 63 cf             	movslq %edi,%rcx
  100353:	48 f7 d9             	neg    %rcx
  100356:	4d 8d 34 ce          	lea    (%r14,%rcx,8),%r14
  10035a:	48 63 8d 44 fe ff ff 	movslq -0x1bc(%rbp),%rcx
  100361:	44 89 9d 2c fe ff ff 	mov    %r11d,-0x1d4(%rbp)
  100368:	c4 c1 f9 7e e3       	vmovq  %xmm4,%r11
  10036d:	45 8b 5b 04          	mov    0x4(%r11),%r11d
  100371:	48 f7 d9             	neg    %rcx
  100374:	44 89 9d 28 fe ff ff 	mov    %r11d,-0x1d8(%rbp)
  10037b:	c4 c1 f9 7e db       	vmovq  %xmm3,%r11
  100380:	45 8b 5b 04          	mov    0x4(%r11),%r11d
  100384:	44 89 9d 24 fe ff ff 	mov    %r11d,-0x1dc(%rbp)
  10038b:	c4 c1 f9 7e d3       	vmovq  %xmm2,%r11
  100390:	45 8b 5b 04          	mov    0x4(%r11),%r11d
  100394:	44 89 9d 20 fe ff ff 	mov    %r11d,-0x1e0(%rbp)
  10039b:	4d 8d 1c cc          	lea    (%r12,%rcx,8),%r11
  10039f:	48 63 8d 48 fe ff ff 	movslq -0x1b8(%rbp),%rcx
  1003a6:	4c 63 e2             	movslq %edx,%r12
  1003a9:	48 f7 d9             	neg    %rcx
  1003ac:	4d 8d 0c c9          	lea    (%r9,%rcx,8),%r9
  1003b0:	48 8b 8d 18 fe ff ff 	mov    -0x1e8(%rbp),%rcx
  1003b7:	48 f7 d9             	neg    %rcx
  1003ba:	4d 8d 14 ca          	lea    (%r10,%rcx,8),%r10
  1003be:	66 90                	xchg   %ax,%ax
  1003c0:	48 ff c0             	inc    %rax
  1003c3:	39 c6                	cmp    %eax,%esi
  1003c5:	7f 08                	jg     1003cf <mj__data__inertia_phase__solve_acceleration+0x22f>
  1003c7:	39 85 40 fe ff ff    	cmp    %eax,-0x1c0(%rbp)
  1003cd:	7d 11                	jge    1003e0 <mj__data__inertia_phase__solve_acceleration+0x240>
  1003cf:	be be 06 00 00       	mov    $0x6be,%esi
  1003d4:	48 8d 3d 65 07 05 00 	lea    0x50765(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1003db:	e8 d6 4d 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  1003e0:	41 39 c0             	cmp    %eax,%r8d
  1003e3:	7f 08                	jg     1003ed <mj__data__inertia_phase__solve_acceleration+0x24d>
  1003e5:	39 85 2c fe ff ff    	cmp    %eax,-0x1d4(%rbp)
  1003eb:	7d 13                	jge    100400 <mj__data__inertia_phase__solve_acceleration+0x260>
  1003ed:	be be 06 00 00       	mov    $0x6be,%esi
  1003f2:	48 8d 3d 47 07 05 00 	lea    0x50747(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1003f9:	e8 b8 4d 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  1003fe:	66 90                	xchg   %ax,%ax
  100400:	39 c7                	cmp    %eax,%edi
  100402:	7f 08                	jg     10040c <mj__data__inertia_phase__solve_acceleration+0x26c>
  100404:	39 85 28 fe ff ff    	cmp    %eax,-0x1d8(%rbp)
  10040a:	7d 14                	jge    100420 <mj__data__inertia_phase__solve_acceleration+0x280>
  10040c:	be be 06 00 00       	mov    $0x6be,%esi
  100411:	48 8d 3d 28 07 05 00 	lea    0x50728(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  100418:	e8 99 4d 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  10041d:	0f 1f 00             	nopl   (%rax)
  100420:	39 85 44 fe ff ff    	cmp    %eax,-0x1bc(%rbp)
  100426:	7f 08                	jg     100430 <mj__data__inertia_phase__solve_acceleration+0x290>
  100428:	39 85 24 fe ff ff    	cmp    %eax,-0x1dc(%rbp)
  10042e:	7d 20                	jge    100450 <mj__data__inertia_phase__solve_acceleration+0x2b0>
  100430:	be be 06 00 00       	mov    $0x6be,%esi
  100435:	48 8d 3d 04 07 05 00 	lea    0x50704(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  10043c:	e8 75 4d 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  100441:	0f 1f 40 00          	nopl   0x0(%rax)
  100445:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  10044c:	00 00 00 00 
  100450:	39 85 48 fe ff ff    	cmp    %eax,-0x1b8(%rbp)
  100456:	7f 08                	jg     100460 <mj__data__inertia_phase__solve_acceleration+0x2c0>
  100458:	39 85 20 fe ff ff    	cmp    %eax,-0x1e0(%rbp)
  10045e:	7d 20                	jge    100480 <mj__data__inertia_phase__solve_acceleration+0x2e0>
  100460:	be be 06 00 00       	mov    $0x6be,%esi
  100465:	48 8d 3d d4 06 05 00 	lea    0x506d4(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  10046c:	e8 45 4d 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  100471:	0f 1f 40 00          	nopl   0x0(%rax)
  100475:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  10047c:	00 00 00 00 
  100480:	c4 c1 7b 10 44 c5 00 	vmovsd 0x0(%r13,%rax,8),%xmm0
  100487:	c5 f9 2e 05 61 45 05 	vucomisd 0x54561(%rip),%xmm0        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  10048e:	00 
  10048f:	0f 82 55 0e 00 00    	jb     1012ea <mj__data__inertia_phase__solve_acceleration+0x114a>
  100495:	c5 f9 2e c8          	vucomisd %xmm0,%xmm1
  100499:	0f 82 4b 0e 00 00    	jb     1012ea <mj__data__inertia_phase__solve_acceleration+0x114a>
  10049f:	c4 c1 7b 10 1c c7    	vmovsd (%r15,%rax,8),%xmm3
  1004a5:	c5 f9 2e 1d 43 45 05 	vucomisd 0x54543(%rip),%xmm3        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  1004ac:	00 
  1004ad:	0f 82 26 0e 00 00    	jb     1012d9 <mj__data__inertia_phase__solve_acceleration+0x1139>
  1004b3:	c5 f9 2e cb          	vucomisd %xmm3,%xmm1
  1004b7:	0f 82 1c 0e 00 00    	jb     1012d9 <mj__data__inertia_phase__solve_acceleration+0x1139>
  1004bd:	c4 c1 7b 10 14 c6    	vmovsd (%r14,%rax,8),%xmm2
  1004c3:	c5 f9 2e 15 25 45 05 	vucomisd 0x54525(%rip),%xmm2        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  1004ca:	00 
  1004cb:	0f 82 f7 0d 00 00    	jb     1012c8 <mj__data__inertia_phase__solve_acceleration+0x1128>
  1004d1:	c5 f9 2e ca          	vucomisd %xmm2,%xmm1
  1004d5:	0f 82 ed 0d 00 00    	jb     1012c8 <mj__data__inertia_phase__solve_acceleration+0x1128>
  1004db:	c4 c1 7b 10 2c c3    	vmovsd (%r11,%rax,8),%xmm5
  1004e1:	c5 f9 2e 2d 07 45 05 	vucomisd 0x54507(%rip),%xmm5        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  1004e8:	00 
  1004e9:	0f 82 c8 0d 00 00    	jb     1012b7 <mj__data__inertia_phase__solve_acceleration+0x1117>
  1004ef:	c5 f9 2e cd          	vucomisd %xmm5,%xmm1
  1004f3:	0f 82 be 0d 00 00    	jb     1012b7 <mj__data__inertia_phase__solve_acceleration+0x1117>
  1004f9:	c4 c1 7b 10 24 c1    	vmovsd (%r9,%rax,8),%xmm4
  1004ff:	c5 f9 2e 25 71 44 05 	vucomisd 0x54471(%rip),%xmm4        # 154978 <ada__numerics__long_elementary_functions__two_pi+0x208>
  100506:	00 
  100507:	0f 82 99 0d 00 00    	jb     1012a6 <mj__data__inertia_phase__solve_acceleration+0x1106>
  10050d:	c5 79 2e c4          	vucomisd %xmm4,%xmm8
  100511:	0f 82 8f 0d 00 00    	jb     1012a6 <mj__data__inertia_phase__solve_acceleration+0x1106>
  100517:	c5 fb 5c c3          	vsubsd %xmm3,%xmm0,%xmm0
  10051b:	c5 fb 58 c2          	vaddsd %xmm2,%xmm0,%xmm0
  10051f:	c5 fb 58 c5          	vaddsd %xmm5,%xmm0,%xmm0
  100523:	c5 fb 58 c4          	vaddsd %xmm4,%xmm0,%xmm0
  100527:	c5 f9 2f 05 c1 44 05 	vcomisd 0x544c1(%rip),%xmm0        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  10052e:	00 
  10052f:	0f 93 c1             	setae  %cl
  100532:	c5 f9 2f c8          	vcomisd %xmm0,%xmm1
  100536:	0f 93 c2             	setae  %dl
  100539:	84 d1                	test   %dl,%cl
  10053b:	0f 84 2f 03 00 00    	je     100870 <mj__data__inertia_phase__solve_acceleration+0x6d0>
  100541:	c4 c1 7b 11 04 c2    	vmovsd %xmm0,(%r10,%rax,8)
  100547:	4c 39 e0             	cmp    %r12,%rax
  10054a:	0f 85 70 fe ff ff    	jne    1003c0 <mj__data__inertia_phase__solve_acceleration+0x220>
  100550:	45 31 e4             	xor    %r12d,%r12d
  100553:	48 8d bd f0 fe ff ff 	lea    -0x110(%rbp),%rdi
  10055a:	e8 b1 11 03 00       	call   131710 <system__secondary_stack__ss_release>
  10055f:	45 84 e4             	test   %r12b,%r12b
  100562:	74 18                	je     10057c <mj__data__inertia_phase__solve_acceleration+0x3dc>
  100564:	41 bc 0a 00 00 00    	mov    $0xa,%r12d
  10056a:	e9 99 fc ff ff       	jmp    100208 <mj__data__inertia_phase__solve_acceleration+0x68>
  10056f:	90                   	nop
  100570:	48 8d bd f0 fe ff ff 	lea    -0x110(%rbp),%rdi
  100577:	e8 94 11 03 00       	call   131710 <system__secondary_stack__ss_release>
  10057c:	48 8b 85 38 fe ff ff 	mov    -0x1c8(%rbp),%rax
  100583:	8b 70 04             	mov    0x4(%rax),%esi
  100586:	39 30                	cmp    %esi,(%rax)
  100588:	0f 8f 12 02 00 00    	jg     1007a0 <mj__data__inertia_phase__solve_acceleration+0x600>
  10058e:	48 8d bd d8 fe ff ff 	lea    -0x128(%rbp),%rdi
  100595:	e8 56 11 03 00       	call   1316f0 <system__secondary_stack__ss_mark>
  10059a:	4c 8b bb b8 80 00 00 	mov    0x80b8(%rbx),%r15
  1005a1:	4d 85 ff             	test   %r15,%r15
  1005a4:	0f 84 c2 0e 00 00    	je     10146c <mj__data__inertia_phase__solve_acceleration+0x12cc>
  1005aa:	4c 8b ab c8 80 00 00 	mov    0x80c8(%rbx),%r13
  1005b1:	4d 85 ed             	test   %r13,%r13
  1005b4:	0f 84 5d 0e 00 00    	je     101417 <mj__data__inertia_phase__solve_acceleration+0x1277>
  1005ba:	48 8b 8b 48 81 00 00 	mov    0x8148(%rbx),%rcx
  1005c1:	48 85 c9             	test   %rcx,%rcx
  1005c4:	0f 84 3c 0e 00 00    	je     101406 <mj__data__inertia_phase__solve_acceleration+0x1266>
  1005ca:	4c 8b a3 58 81 00 00 	mov    0x8158(%rbx),%r12
  1005d1:	4d 85 e4             	test   %r12,%r12
  1005d4:	0f 84 1b 0e 00 00    	je     1013f5 <mj__data__inertia_phase__solve_acceleration+0x1255>
  1005da:	4c 8b b3 18 82 00 00 	mov    0x8218(%rbx),%r14
  1005e1:	4d 85 f6             	test   %r14,%r14
  1005e4:	0f 84 fa 0d 00 00    	je     1013e4 <mj__data__inertia_phase__solve_acceleration+0x1244>
  1005ea:	48 8b 85 38 fe ff ff 	mov    -0x1c8(%rbp),%rax
  1005f1:	8b 10                	mov    (%rax),%edx
  1005f3:	8b 70 04             	mov    0x4(%rax),%esi
  1005f6:	39 f2                	cmp    %esi,%edx
  1005f8:	0f 8f 82 02 00 00    	jg     100880 <mj__data__inertia_phase__solve_acceleration+0x6e0>
  1005fe:	85 d2                	test   %edx,%edx
  100600:	0f 85 8b 02 00 00    	jne    100891 <mj__data__inertia_phase__solve_acceleration+0x6f1>
  100606:	48 8b 83 c0 80 00 00 	mov    0x80c0(%rbx),%rax
  10060d:	4c 63 c6             	movslq %esi,%r8
  100610:	44 8b 08             	mov    (%rax),%r9d
  100613:	8b 78 04             	mov    0x4(%rax),%edi
  100616:	41 39 f9             	cmp    %edi,%r9d
  100619:	0f 8e 27 03 00 00    	jle    100946 <mj__data__inertia_phase__solve_acceleration+0x7a6>
  10061f:	49 83 f8 ff          	cmp    $0xffffffffffffffff,%r8
  100623:	0f 85 68 02 00 00    	jne    100891 <mj__data__inertia_phase__solve_acceleration+0x6f1>
  100629:	49 63 c1             	movslq %r9d,%rax
  10062c:	c6 85 38 fe ff ff 01 	movb   $0x1,-0x1c8(%rbp)
  100633:	c4 e1 f9 6e e0       	vmovq  %rax,%xmm4
  100638:	85 ff                	test   %edi,%edi
  10063a:	0f 8e 40 02 00 00    	jle    100880 <mj__data__inertia_phase__solve_acceleration+0x6e0>
  100640:	c5 7a 7e 8b 60 81 00 	vmovq  0x8160(%rbx),%xmm9
  100647:	00 
  100648:	c5 7a 7e 93 d0 80 00 	vmovq  0x80d0(%rbx),%xmm10
  10064f:	00 
  100650:	48 8b 83 50 81 00 00 	mov    0x8150(%rbx),%rax
  100657:	c5 f1 57 c9          	vxorpd %xmm1,%xmm1,%xmm1
  10065b:	c5 7a 7e 83 20 82 00 	vmovq  0x8220(%rbx),%xmm8
  100662:	00 
  100663:	44 8b 10             	mov    (%rax),%r10d
  100666:	8b 40 04             	mov    0x4(%rax),%eax
  100669:	c4 41 f9 7e c8       	vmovq  %xmm9,%r8
  10066e:	4d 63 00             	movslq (%r8),%r8
  100671:	41 83 fa 01          	cmp    $0x1,%r10d
  100675:	89 85 00 fe ff ff    	mov    %eax,-0x200(%rbp)
  10067b:	44 89 95 04 fe ff ff 	mov    %r10d,-0x1fc(%rbp)
  100682:	44 89 85 28 fe ff ff 	mov    %r8d,-0x1d8(%rbp)
  100689:	c4 c1 f9 6e f0       	vmovq  %r8,%xmm6
  10068e:	c4 41 f9 7e d0       	vmovq  %xmm10,%r8
  100693:	4d 63 00             	movslq (%r8),%r8
  100696:	44 89 85 40 fe ff ff 	mov    %r8d,-0x1c0(%rbp)
  10069d:	c4 c1 f9 6e e8       	vmovq  %r8,%xmm5
  1006a2:	41 0f 9f c0          	setg   %r8b
  1006a6:	39 f8                	cmp    %edi,%eax
  1006a8:	0f 9c c0             	setl   %al
  1006ab:	48 81 c1 58 01 00 00 	add    $0x158,%rcx
  1006b2:	41 09 c0             	or     %eax,%r8d
  1006b5:	48 8b 85 30 fe ff ff 	mov    -0x1d0(%rbp),%rax
  1006bc:	44 88 85 0b fe ff ff 	mov    %r8b,-0x1f5(%rbp)
  1006c3:	4d 63 c2             	movslq %r10d,%r8
  1006c6:	4f 8d 04 80          	lea    (%r8,%r8,4),%r8
  1006ca:	49 c1 e0 06          	shl    $0x6,%r8
  1006ce:	4c 29 c1             	sub    %r8,%rcx
  1006d1:	48 83 c0 30          	add    $0x30,%rax
  1006d5:	48 89 8d 48 fe ff ff 	mov    %rcx,-0x1b8(%rbp)
  1006dc:	ff c2                	inc    %edx
  1006de:	39 d6                	cmp    %edx,%esi
  1006e0:	7d 0d                	jge    1006ef <mj__data__inertia_phase__solve_acceleration+0x54f>
  1006e2:	80 bd 38 fe ff ff 00 	cmpb   $0x0,-0x1c8(%rbp)
  1006e9:	0f 85 af 02 00 00    	jne    10099e <mj__data__inertia_phase__solve_acceleration+0x7fe>
  1006ef:	c5 fb 10 00          	vmovsd (%rax),%xmm0
  1006f3:	c5 f9 2e c1          	vucomisd %xmm1,%xmm0
  1006f7:	0f 8a b5 02 00 00    	jp     1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  1006fd:	0f 85 af 02 00 00    	jne    1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  100703:	c5 fb 10 40 08       	vmovsd 0x8(%rax),%xmm0
  100708:	c5 f9 2e c1          	vucomisd %xmm1,%xmm0
  10070c:	0f 8a a0 02 00 00    	jp     1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  100712:	0f 85 9a 02 00 00    	jne    1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  100718:	c5 fb 10 40 10       	vmovsd 0x10(%rax),%xmm0
  10071d:	c5 f9 2e c1          	vucomisd %xmm1,%xmm0
  100721:	0f 8a 8b 02 00 00    	jp     1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  100727:	0f 85 85 02 00 00    	jne    1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  10072d:	c5 fb 10 40 18       	vmovsd 0x18(%rax),%xmm0
  100732:	c5 f9 2e c1          	vucomisd %xmm1,%xmm0
  100736:	0f 8a 76 02 00 00    	jp     1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  10073c:	0f 85 70 02 00 00    	jne    1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  100742:	c5 fb 10 40 20       	vmovsd 0x20(%rax),%xmm0
  100747:	c5 f9 2e c1          	vucomisd %xmm1,%xmm0
  10074b:	0f 8a 61 02 00 00    	jp     1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  100751:	0f 85 5b 02 00 00    	jne    1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  100757:	c5 fb 10 40 28       	vmovsd 0x28(%rax),%xmm0
  10075c:	c5 f9 2e c1          	vucomisd %xmm1,%xmm0
  100760:	0f 8a 4c 02 00 00    	jp     1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  100766:	0f 85 46 02 00 00    	jne    1009b2 <mj__data__inertia_phase__solve_acceleration+0x812>
  10076c:	48 81 85 48 fe ff ff 	addq   $0x140,-0x1b8(%rbp)
  100773:	40 01 00 00 
  100777:	48 83 c0 30          	add    $0x30,%rax
  10077b:	39 d7                	cmp    %edx,%edi
  10077d:	0f 85 59 ff ff ff    	jne    1006dc <mj__data__inertia_phase__solve_acceleration+0x53c>
  100783:	48 8d bd d8 fe ff ff 	lea    -0x128(%rbp),%rdi
  10078a:	c5 f8 77             	vzeroupper
  10078d:	e8 7e 0f 03 00       	call   131710 <system__secondary_stack__ss_release>
  100792:	0f 1f 00             	nopl   (%rax)
  100795:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  10079c:	00 00 00 00 
  1007a0:	48 8d bd c0 fe ff ff 	lea    -0x140(%rbp),%rdi
  1007a7:	e8 44 0f 03 00       	call   1316f0 <system__secondary_stack__ss_mark>
  1007ac:	c5 f9 57 c0          	vxorpd %xmm0,%xmm0,%xmm0
  1007b0:	48 89 df             	mov    %rbx,%rdi
  1007b3:	e8 78 ec ff ff       	call   ff430 <mj__data__inertia_phase__solve.lto_priv.0>
  1007b8:	48 8d bd c0 fe ff ff 	lea    -0x140(%rbp),%rdi
  1007bf:	41 89 c4             	mov    %eax,%r12d
  1007c2:	e8 49 0f 03 00       	call   131710 <system__secondary_stack__ss_release>
  1007c7:	45 84 e4             	test   %r12b,%r12b
  1007ca:	0f 85 38 fa ff ff    	jne    100208 <mj__data__inertia_phase__solve_acceleration+0x68>
  1007d0:	48 8d bd a8 fe ff ff 	lea    -0x158(%rbp),%rdi
  1007d7:	e8 14 0f 03 00       	call   1316f0 <system__secondary_stack__ss_mark>
  1007dc:	8b bb 14 80 00 00    	mov    0x8014(%rbx),%edi
  1007e2:	85 ff                	test   %edi,%edi
  1007e4:	0f 8e be 00 00 00    	jle    1008a8 <mj__data__inertia_phase__solve_acceleration+0x708>
  1007ea:	c5 fb 10 0d 8e 41 05 	vmovsd 0x5418e(%rip),%xmm1        # 154980 <ada__numerics__long_elementary_functions__two_pi+0x210>
  1007f1:	00 
  1007f2:	31 c0                	xor    %eax,%eax
  1007f4:	eb 1c                	jmp    100812 <mj__data__inertia_phase__solve_acceleration+0x672>
  1007f6:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  1007fd:	00 00 00 
  100800:	c5 f9 2e c8          	vucomisd %xmm0,%xmm1
  100804:	72 4c                	jb     100852 <mj__data__inertia_phase__solve_acceleration+0x6b2>
  100806:	48 ff c0             	inc    %rax
  100809:	48 39 c7             	cmp    %rax,%rdi
  10080c:	0f 84 96 00 00 00    	je     1008a8 <mj__data__inertia_phase__solve_acceleration+0x708>
  100812:	48 8b 8b 78 82 00 00 	mov    0x8278(%rbx),%rcx
  100819:	48 85 c9             	test   %rcx,%rcx
  10081c:	0f 84 d9 0a 00 00    	je     1012fb <mj__data__inertia_phase__solve_acceleration+0x115b>
  100822:	48 8b b3 80 82 00 00 	mov    0x8280(%rbx),%rsi
  100829:	48 63 16             	movslq (%rsi),%rdx
  10082c:	39 46 04             	cmp    %eax,0x4(%rsi)
  10082f:	0f 8c 8d 0b 00 00    	jl     1013c2 <mj__data__inertia_phase__solve_acceleration+0x1222>
  100835:	39 c2                	cmp    %eax,%edx
  100837:	0f 8f 85 0b 00 00    	jg     1013c2 <mj__data__inertia_phase__solve_acceleration+0x1222>
  10083d:	48 89 c6             	mov    %rax,%rsi
  100840:	48 29 d6             	sub    %rdx,%rsi
  100843:	c5 fb 10 04 f1       	vmovsd (%rcx,%rsi,8),%xmm0
  100848:	c5 f9 2e 05 28 41 05 	vucomisd 0x54128(%rip),%xmm0        # 154978 <ada__numerics__long_elementary_functions__two_pi+0x208>
  10084f:	00 
  100850:	73 ae                	jae    100800 <mj__data__inertia_phase__solve_acceleration+0x660>
  100852:	41 bc 0a 00 00 00    	mov    $0xa,%r12d
  100858:	48 8d bd a8 fe ff ff 	lea    -0x158(%rbp),%rdi
  10085f:	e8 ac 0e 03 00       	call   131710 <system__secondary_stack__ss_release>
  100864:	e9 9f f9 ff ff       	jmp    100208 <mj__data__inertia_phase__solve_acceleration+0x68>
  100869:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  100870:	41 bc 0a 00 00 00    	mov    $0xa,%r12d
  100876:	e9 d8 fc ff ff       	jmp    100553 <mj__data__inertia_phase__solve_acceleration+0x3b3>
  10087b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  100880:	48 8d bd d8 fe ff ff 	lea    -0x128(%rbp),%rdi
  100887:	e8 84 0e 03 00       	call   131710 <system__secondary_stack__ss_release>
  10088c:	e9 0f ff ff ff       	jmp    1007a0 <mj__data__inertia_phase__solve_acceleration+0x600>
  100891:	48 8d bd d8 fe ff ff 	lea    -0x128(%rbp),%rdi
  100898:	e8 73 0e 03 00       	call   131710 <system__secondary_stack__ss_release>
  10089d:	41 bc 09 00 00 00    	mov    $0x9,%r12d
  1008a3:	e9 60 f9 ff ff       	jmp    100208 <mj__data__inertia_phase__solve_acceleration+0x68>
  1008a8:	4c 8b 83 08 82 00 00 	mov    0x8208(%rbx),%r8
  1008af:	4d 85 c0             	test   %r8,%r8
  1008b2:	0f 84 a3 0b 00 00    	je     10145b <mj__data__inertia_phase__solve_acceleration+0x12bb>
  1008b8:	48 8b 83 10 82 00 00 	mov    0x8210(%rbx),%rax
  1008bf:	48 63 08             	movslq (%rax),%rcx
  1008c2:	8b 70 04             	mov    0x4(%rax),%esi
  1008c5:	39 f1                	cmp    %esi,%ecx
  1008c7:	0f 9e c2             	setle  %dl
  1008ca:	89 c8                	mov    %ecx,%eax
  1008cc:	c1 e8 1f             	shr    $0x1f,%eax
  1008cf:	84 c2                	test   %al,%dl
  1008d1:	0f 85 73 0b 00 00    	jne    10144a <mj__data__inertia_phase__solve_acceleration+0x12aa>
  1008d7:	4c 8b 8b 78 82 00 00 	mov    0x8278(%rbx),%r9
  1008de:	4d 85 c9             	test   %r9,%r9
  1008e1:	0f 84 52 0b 00 00    	je     101439 <mj__data__inertia_phase__solve_acceleration+0x1299>
  1008e7:	48 8b 93 80 82 00 00 	mov    0x8280(%rbx),%rdx
  1008ee:	48 63 02             	movslq (%rdx),%rax
  1008f1:	48 63 52 04          	movslq 0x4(%rdx),%rdx
  1008f5:	39 d0                	cmp    %edx,%eax
  1008f7:	41 0f 9e c2          	setle  %r10b
  1008fb:	89 c7                	mov    %eax,%edi
  1008fd:	c1 ef 1f             	shr    $0x1f,%edi
  100900:	41 84 fa             	test   %dil,%r10b
  100903:	0f 85 1f 0b 00 00    	jne    101428 <mj__data__inertia_phase__solve_acceleration+0x1288>
  100909:	39 d0                	cmp    %edx,%eax
  10090b:	7e 66                	jle    100973 <mj__data__inertia_phase__solve_acceleration+0x7d3>
  10090d:	39 f1                	cmp    %esi,%ecx
  10090f:	0f 8f 7b 01 00 00    	jg     100a90 <mj__data__inertia_phase__solve_acceleration+0x8f0>
  100915:	48 63 fe             	movslq %esi,%rdi
  100918:	45 31 db             	xor    %r11d,%r11d
  10091b:	31 c0                	xor    %eax,%eax
  10091d:	48 29 cf             	sub    %rcx,%rdi
  100920:	48 ff c7             	inc    %rdi
  100923:	48 39 f8             	cmp    %rdi,%rax
  100926:	0f 85 a7 0a 00 00    	jne    1013d3 <mj__data__inertia_phase__solve_acceleration+0x1233>
  10092c:	4c 89 da             	mov    %r11,%rdx
  10092f:	4c 89 ce             	mov    %r9,%rsi
  100932:	4c 89 c7             	mov    %r8,%rdi
  100935:	e8 f6 53 f0 ff       	call   5d30 <memcpy@plt>
  10093a:	c6 83 9b 80 00 00 01 	movb   $0x1,0x809b(%rbx)
  100941:	e9 12 ff ff ff       	jmp    100858 <mj__data__inertia_phase__solve_acceleration+0x6b8>
  100946:	4d 63 d1             	movslq %r9d,%r10
  100949:	48 63 c7             	movslq %edi,%rax
  10094c:	4c 29 d0             	sub    %r10,%rax
  10094f:	c4 c1 f9 6e e2       	vmovq  %r10,%xmm4
  100954:	49 39 c0             	cmp    %rax,%r8
  100957:	0f 85 34 ff ff ff    	jne    100891 <mj__data__inertia_phase__solve_acceleration+0x6f1>
  10095d:	85 ff                	test   %edi,%edi
  10095f:	0f 8e 1b ff ff ff    	jle    100880 <mj__data__inertia_phase__solve_acceleration+0x6e0>
  100965:	39 fe                	cmp    %edi,%esi
  100967:	0f 9c 85 38 fe ff ff 	setl   -0x1c8(%rbp)
  10096e:	e9 cd fc ff ff       	jmp    100640 <mj__data__inertia_phase__solve_acceleration+0x4a0>
  100973:	4c 63 d6             	movslq %esi,%r10
  100976:	4c 63 e9             	movslq %ecx,%r13
  100979:	48 89 d7             	mov    %rdx,%rdi
  10097c:	48 29 c7             	sub    %rax,%rdi
  10097f:	4d 29 ea             	sub    %r13,%r10
  100982:	4c 8d 1c fd 08 00 00 	lea    0x8(,%rdi,8),%r11
  100989:	00 
  10098a:	31 ff                	xor    %edi,%edi
  10098c:	49 ff c2             	inc    %r10
  10098f:	39 f1                	cmp    %esi,%ecx
  100991:	49 0f 4e fa          	cmovle %r10,%rdi
  100995:	48 29 c2             	sub    %rax,%rdx
  100998:	48 8d 42 01          	lea    0x1(%rdx),%rax
  10099c:	eb 85                	jmp    100923 <mj__data__inertia_phase__solve_acceleration+0x783>
  10099e:	be 1e 00 00 00       	mov    $0x1e,%esi
  1009a3:	48 8d 3d 69 03 05 00 	lea    0x50369(%rip),%rdi        # 150d13 <CSWTCH.1374+0x1693>
  1009aa:	c5 f8 77             	vzeroupper
  1009ad:	e8 04 48 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  1009b2:	c4 61 f9 7e d1       	vmovq  %xmm10,%rcx
  1009b7:	8b 49 04             	mov    0x4(%rcx),%ecx
  1009ba:	89 8d 2c fe ff ff    	mov    %ecx,-0x1d4(%rbp)
  1009c0:	c4 61 f9 7e c9       	vmovq  %xmm9,%rcx
  1009c5:	8b 49 04             	mov    0x4(%rcx),%ecx
  1009c8:	89 8d 24 fe ff ff    	mov    %ecx,-0x1dc(%rbp)
  1009ce:	c4 61 f9 7e c1       	vmovq  %xmm8,%rcx
  1009d3:	48 63 09             	movslq (%rcx),%rcx
  1009d6:	89 8d 20 fe ff ff    	mov    %ecx,-0x1e0(%rbp)
  1009dc:	c4 e1 f9 6e f9       	vmovq  %rcx,%xmm7
  1009e1:	c4 61 f9 7e c1       	vmovq  %xmm8,%rcx
  1009e6:	8b 49 04             	mov    0x4(%rcx),%ecx
  1009e9:	89 8d 18 fe ff ff    	mov    %ecx,-0x1e8(%rbp)
  1009ef:	80 bd 0b fe ff ff 00 	cmpb   $0x0,-0x1f5(%rbp)
  1009f6:	0f 85 90 02 00 00    	jne    100c8c <mj__data__inertia_phase__solve_acceleration+0xaec>
  1009fc:	c5 7b 10 25 f4 3f 05 	vmovsd 0x53ff4(%rip),%xmm12        # 1549f8 <ada__numerics__long_elementary_functions__two_pi+0x288>
  100a03:	00 
  100a04:	41 89 d0             	mov    %edx,%r8d
  100a07:	45 39 c8             	cmp    %r9d,%r8d
  100a0a:	0f 8c 9e 09 00 00    	jl     1013ae <mj__data__inertia_phase__solve_acceleration+0x120e>
  100a10:	41 39 f8             	cmp    %edi,%r8d
  100a13:	0f 8f 95 09 00 00    	jg     1013ae <mj__data__inertia_phase__solve_acceleration+0x120e>
  100a19:	c4 c1 f9 7e e2       	vmovq  %xmm4,%r10
  100a1e:	4d 29 d0             	sub    %r10,%r8
  100a21:	4f 8d 04 40          	lea    (%r8,%r8,2),%r8
  100a25:	49 c1 e0 06          	shl    $0x6,%r8
  100a29:	4d 01 f8             	add    %r15,%r8
  100a2c:	62 d1 fe 48 6f 00    	vmovdqu64 (%r8),%zmm0
  100a32:	62 f1 fe 48 7f 85 10 	vmovdqu64 %zmm0,-0xf0(%rbp)
  100a39:	ff ff ff 
  100a3c:	62 d1 fe 48 6f 40 01 	vmovdqu64 0x40(%r8),%zmm0
  100a43:	62 f1 fe 48 7f 85 50 	vmovdqu64 %zmm0,-0xb0(%rbp)
  100a4a:	ff ff ff 
  100a4d:	62 d1 fe 48 6f 40 02 	vmovdqu64 0x80(%r8),%zmm0
  100a54:	44 8b 95 3c ff ff ff 	mov    -0xc4(%rbp),%r10d
  100a5b:	44 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%r8d
  100a62:	62 f1 fe 48 7f 85 90 	vmovdqu64 %zmm0,-0x70(%rbp)
  100a69:	ff ff ff 
  100a6c:	41 ff ca             	dec    %r10d
  100a6f:	44 89 95 10 fe ff ff 	mov    %r10d,-0x1f0(%rbp)
  100a76:	79 20                	jns    100a98 <mj__data__inertia_phase__solve_acceleration+0x8f8>
  100a78:	45 85 c0             	test   %r8d,%r8d
  100a7b:	7f 8a                	jg     100a07 <mj__data__inertia_phase__solve_acceleration+0x867>
  100a7d:	e9 ea fc ff ff       	jmp    10076c <mj__data__inertia_phase__solve_acceleration+0x5cc>
  100a82:	0f 1f 00             	nopl   (%rax)
  100a85:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  100a8c:	00 00 00 00 
  100a90:	45 31 db             	xor    %r11d,%r11d
  100a93:	e9 94 fe ff ff       	jmp    10092c <mj__data__inertia_phase__solve_acceleration+0x78c>
  100a98:	8b 8d 38 ff ff ff    	mov    -0xc8(%rbp),%ecx
  100a9e:	c7 85 44 fe ff ff ff 	movl   $0xffffffff,-0x1bc(%rbp)
  100aa5:	ff ff ff 
  100aa8:	89 8d 0c fe ff ff    	mov    %ecx,-0x1f4(%rbp)
  100aae:	ff 85 44 fe ff ff    	incl   -0x1bc(%rbp)
  100ab4:	44 8b 9d 0c fe ff ff 	mov    -0x1f4(%rbp),%r11d
  100abb:	44 03 9d 44 fe ff ff 	add    -0x1bc(%rbp),%r11d
  100ac2:	0f 80 44 08 00 00    	jo     10130c <mj__data__inertia_phase__solve_acceleration+0x116c>
  100ac8:	45 85 db             	test   %r11d,%r11d
  100acb:	0f 88 4f 08 00 00    	js     101320 <mj__data__inertia_phase__solve_acceleration+0x1180>
  100ad1:	44 39 9d 40 fe ff ff 	cmp    %r11d,-0x1c0(%rbp)
  100ad8:	0f 8f b4 07 00 00    	jg     101292 <mj__data__inertia_phase__solve_acceleration+0x10f2>
  100ade:	44 39 9d 2c fe ff ff 	cmp    %r11d,-0x1d4(%rbp)
  100ae5:	0f 8c a7 07 00 00    	jl     101292 <mj__data__inertia_phase__solve_acceleration+0x10f2>
  100aeb:	44 39 9d 28 fe ff ff 	cmp    %r11d,-0x1d8(%rbp)
  100af2:	0f 8f a2 08 00 00    	jg     10139a <mj__data__inertia_phase__solve_acceleration+0x11fa>
  100af8:	44 39 9d 24 fe ff ff 	cmp    %r11d,-0x1dc(%rbp)
  100aff:	0f 8c 95 08 00 00    	jl     10139a <mj__data__inertia_phase__solve_acceleration+0x11fa>
  100b05:	45 89 db             	mov    %r11d,%r11d
  100b08:	c4 e1 f9 7e e9       	vmovq  %xmm5,%rcx
  100b0d:	4d 89 da             	mov    %r11,%r10
  100b10:	49 29 ca             	sub    %rcx,%r10
  100b13:	49 69 ca b8 00 00 00 	imul   $0xb8,%r10,%rcx
  100b1a:	41 0f b6 4c 0d 00    	movzbl 0x0(%r13,%rcx,1),%ecx
  100b20:	80 f9 01             	cmp    $0x1,%cl
  100b23:	0f 84 82 00 00 00    	je     100bab <mj__data__inertia_phase__solve_acceleration+0xa0b>
  100b29:	c4 c1 f9 7e f2       	vmovq  %xmm6,%r10
  100b2e:	4c 89 d9             	mov    %r11,%rcx
  100b31:	4c 29 d1             	sub    %r10,%rcx
  100b34:	4c 8d 14 49          	lea    (%rcx,%rcx,2),%r10
  100b38:	49 c1 e2 04          	shl    $0x4,%r10
  100b3c:	4b 8d 4c 14 18       	lea    0x18(%r12,%r10,1),%rcx
  100b41:	c4 81 7a 6f 54 14 18 	vmovdqu 0x18(%r12,%r10,1),%xmm2
  100b48:	c5 f9 7f 95 50 fe ff 	vmovdqa %xmm2,-0x1b0(%rbp)
  100b4f:	ff 
  100b50:	c5 fa 7e 41 10       	vmovq  0x10(%rcx),%xmm0
  100b55:	c5 f9 d6 85 60 fe ff 	vmovq  %xmm0,-0x1a0(%rbp)
  100b5c:	ff 
  100b5d:	c5 7b 10 9d 58 fe ff 	vmovsd -0x1a8(%rbp),%xmm11
  100b64:	ff 
  100b65:	c5 fb 10 85 50 fe ff 	vmovsd -0x1b0(%rbp),%xmm0
  100b6c:	ff 
  100b6d:	c5 fb 10 9d 60 fe ff 	vmovsd -0x1a0(%rbp),%xmm3
  100b74:	ff 
  100b75:	c4 41 11 57 ed       	vxorpd %xmm13,%xmm13,%xmm13
  100b7a:	c4 41 79 28 f5       	vmovapd %xmm13,%xmm14
  100b7f:	c5 79 29 ea          	vmovapd %xmm13,%xmm2
  100b83:	c5 79 2f e0          	vcomisd %xmm0,%xmm12
  100b87:	72 0e                	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100b89:	c5 f9 2f 05 5f 3e 05 	vcomisd 0x53e5f(%rip),%xmm0        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100b90:	00 
  100b91:	0f 83 99 01 00 00    	jae    100d30 <mj__data__inertia_phase__solve_acceleration+0xb90>
  100b97:	48 8d bd d8 fe ff ff 	lea    -0x128(%rbp),%rdi
  100b9e:	c5 f8 77             	vzeroupper
  100ba1:	e8 6a 0b 03 00       	call   131710 <system__secondary_stack__ss_release>
  100ba6:	e9 b9 f9 ff ff       	jmp    100564 <mj__data__inertia_phase__solve_acceleration+0x3c4>
  100bab:	c4 c1 f9 7e f2       	vmovq  %xmm6,%r10
  100bb0:	4c 89 d9             	mov    %r11,%rcx
  100bb3:	4c 29 d1             	sub    %r10,%rcx
  100bb6:	48 8d 0c 49          	lea    (%rcx,%rcx,2),%rcx
  100bba:	48 c1 e1 04          	shl    $0x4,%rcx
  100bbe:	4d 8d 54 0c 18       	lea    0x18(%r12,%rcx,1),%r10
  100bc3:	c4 c1 7a 6f 54 0c 18 	vmovdqu 0x18(%r12,%rcx,1),%xmm2
  100bca:	c5 f9 7f 95 70 fe ff 	vmovdqa %xmm2,-0x190(%rbp)
  100bd1:	ff 
  100bd2:	c4 c1 7a 7e 42 10    	vmovq  0x10(%r10),%xmm0
  100bd8:	48 8b 8d 48 fe ff ff 	mov    -0x1b8(%rbp),%rcx
  100bdf:	c4 c1 f9 7e f2       	vmovq  %xmm6,%r10
  100be4:	c5 fb 10 95 70 fe ff 	vmovsd -0x190(%rbp),%xmm2
  100beb:	ff 
  100bec:	c5 7b 10 b5 78 fe ff 	vmovsd -0x188(%rbp),%xmm14
  100bf3:	ff 
  100bf4:	c5 f9 d6 85 80 fe ff 	vmovq  %xmm0,-0x180(%rbp)
  100bfb:	ff 
  100bfc:	c5 7b 10 ad 80 fe ff 	vmovsd -0x180(%rbp),%xmm13
  100c03:	ff 
  100c04:	c5 7b 10 39          	vmovsd (%rcx),%xmm15
  100c08:	4c 89 d9             	mov    %r11,%rcx
  100c0b:	4c 29 d1             	sub    %r10,%rcx
  100c0e:	48 8d 0c 49          	lea    (%rcx,%rcx,2),%rcx
  100c12:	48 c1 e1 04          	shl    $0x4,%rcx
  100c16:	4d 8d 14 0c          	lea    (%r12,%rcx,1),%r10
  100c1a:	48 8b 8d 48 fe ff ff 	mov    -0x1b8(%rbp),%rcx
  100c21:	c4 41 03 5c 3a       	vsubsd (%r10),%xmm15,%xmm15
  100c26:	62 c1 ff 08 10 4a 04 	vmovsd 0x20(%r10),%xmm17
  100c2d:	c4 41 7b 10 5a 28    	vmovsd 0x28(%r10),%xmm11
  100c33:	62 c1 ff 08 10 52 03 	vmovsd 0x18(%r10),%xmm18
  100c3a:	c5 fb 10 59 08       	vmovsd 0x8(%rcx),%xmm3
  100c3f:	62 e1 ff 08 10 41 02 	vmovsd 0x10(%rcx),%xmm16
  100c46:	c4 c1 63 5c 5a 08    	vsubsd 0x8(%r10),%xmm3,%xmm3
  100c4c:	62 c1 ff 00 5c 42 02 	vsubsd 0x10(%r10),%xmm16,%xmm16
  100c53:	62 c1 e7 08 59 db    	vmulsd %xmm11,%xmm3,%xmm19
  100c59:	62 b1 ff 00 59 c1    	vmulsd %xmm17,%xmm16,%xmm0
  100c5f:	c4 41 03 59 db       	vmulsd %xmm11,%xmm15,%xmm11
  100c64:	62 a1 ff 00 59 c2    	vmulsd %xmm18,%xmm16,%xmm16
  100c6a:	62 b1 e7 08 59 da    	vmulsd %xmm18,%xmm3,%xmm3
  100c70:	62 31 87 08 59 f9    	vmulsd %xmm17,%xmm15,%xmm15
  100c76:	62 b1 ff 08 5c c3    	vsubsd %xmm19,%xmm0,%xmm0
  100c7c:	62 31 a7 08 5c d8    	vsubsd %xmm16,%xmm11,%xmm11
  100c82:	c4 c1 63 5c df       	vsubsd %xmm15,%xmm3,%xmm3
  100c87:	e9 f7 fe ff ff       	jmp    100b83 <mj__data__inertia_phase__solve_acceleration+0x9e3>
  100c8c:	39 95 04 fe ff ff    	cmp    %edx,-0x1fc(%rbp)
  100c92:	0f 8f 5c 05 00 00    	jg     1011f4 <mj__data__inertia_phase__solve_acceleration+0x1054>
  100c98:	c5 7b 10 25 58 3d 05 	vmovsd 0x53d58(%rip),%xmm12        # 1549f8 <ada__numerics__long_elementary_functions__two_pi+0x288>
  100c9f:	00 
  100ca0:	41 89 d3             	mov    %edx,%r11d
  100ca3:	45 39 d9             	cmp    %r11d,%r9d
  100ca6:	0f 8f 02 07 00 00    	jg     1013ae <mj__data__inertia_phase__solve_acceleration+0x120e>
  100cac:	44 39 df             	cmp    %r11d,%edi
  100caf:	0f 8c f9 06 00 00    	jl     1013ae <mj__data__inertia_phase__solve_acceleration+0x120e>
  100cb5:	45 89 d8             	mov    %r11d,%r8d
  100cb8:	c4 e1 f9 7e e1       	vmovq  %xmm4,%rcx
  100cbd:	49 29 c8             	sub    %rcx,%r8
  100cc0:	4f 8d 04 40          	lea    (%r8,%r8,2),%r8
  100cc4:	49 c1 e0 06          	shl    $0x6,%r8
  100cc8:	4d 01 f8             	add    %r15,%r8
  100ccb:	62 d1 fe 48 6f 00    	vmovdqu64 (%r8),%zmm0
  100cd1:	62 f1 fe 48 7f 85 10 	vmovdqu64 %zmm0,-0xf0(%rbp)
  100cd8:	ff ff ff 
  100cdb:	62 d1 fe 48 6f 40 01 	vmovdqu64 0x40(%r8),%zmm0
  100ce2:	62 f1 fe 48 7f 85 50 	vmovdqu64 %zmm0,-0xb0(%rbp)
  100ce9:	ff ff ff 
  100cec:	62 d1 fe 48 6f 40 02 	vmovdqu64 0x80(%r8),%zmm0
  100cf3:	8b 8d 3c ff ff ff    	mov    -0xc4(%rbp),%ecx
  100cf9:	44 8b 9d 10 ff ff ff 	mov    -0xf0(%rbp),%r11d
  100d00:	62 f1 fe 48 7f 85 90 	vmovdqu64 %zmm0,-0x70(%rbp)
  100d07:	ff ff ff 
  100d0a:	ff c9                	dec    %ecx
  100d0c:	89 8d 14 fe ff ff    	mov    %ecx,-0x1ec(%rbp)
  100d12:	0f 89 88 01 00 00    	jns    100ea0 <mj__data__inertia_phase__solve_acceleration+0xd00>
  100d18:	45 85 db             	test   %r11d,%r11d
  100d1b:	7f 86                	jg     100ca3 <mj__data__inertia_phase__solve_acceleration+0xb03>
  100d1d:	e9 4a fa ff ff       	jmp    10076c <mj__data__inertia_phase__solve_acceleration+0x5cc>
  100d22:	0f 1f 00             	nopl   (%rax)
  100d25:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  100d2c:	00 00 00 00 
  100d30:	c4 41 79 2f e3       	vcomisd %xmm11,%xmm12
  100d35:	0f 82 5c fe ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100d3b:	c5 79 2f 1d ad 3c 05 	vcomisd 0x53cad(%rip),%xmm11        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100d42:	00 
  100d43:	0f 82 4e fe ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100d49:	c5 79 2f e3          	vcomisd %xmm3,%xmm12
  100d4d:	0f 82 44 fe ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100d53:	c5 f9 2f 1d 95 3c 05 	vcomisd 0x53c95(%rip),%xmm3        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100d5a:	00 
  100d5b:	0f 82 36 fe ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100d61:	c5 79 2f e2          	vcomisd %xmm2,%xmm12
  100d65:	0f 82 2c fe ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100d6b:	c5 f9 2f 15 7d 3c 05 	vcomisd 0x53c7d(%rip),%xmm2        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100d72:	00 
  100d73:	0f 82 1e fe ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100d79:	c4 41 79 2f e6       	vcomisd %xmm14,%xmm12
  100d7e:	0f 82 13 fe ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100d84:	c5 79 2f 35 64 3c 05 	vcomisd 0x53c64(%rip),%xmm14        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100d8b:	00 
  100d8c:	0f 82 05 fe ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100d92:	c4 41 79 2f e5       	vcomisd %xmm13,%xmm12
  100d97:	0f 82 fa fd ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100d9d:	c5 79 2f 2d 4b 3c 05 	vcomisd 0x53c4b(%rip),%xmm13        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100da4:	00 
  100da5:	0f 82 ec fd ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100dab:	c4 e1 f9 7e e9       	vmovq  %xmm5,%rcx
  100db0:	49 29 cb             	sub    %rcx,%r11
  100db3:	4d 69 db b8 00 00 00 	imul   $0xb8,%r11,%r11
  100dba:	47 8b 5c 1d 0c       	mov    0xc(%r13,%r11,1),%r11d
  100dbf:	44 39 9d 20 fe ff ff 	cmp    %r11d,-0x1e0(%rbp)
  100dc6:	0f 8f c5 06 00 00    	jg     101491 <mj__data__inertia_phase__solve_acceleration+0x12f1>
  100dcc:	44 39 9d 18 fe ff ff 	cmp    %r11d,-0x1e8(%rbp)
  100dd3:	0f 8c b8 06 00 00    	jl     101491 <mj__data__inertia_phase__solve_acceleration+0x12f1>
  100dd9:	4d 63 d3             	movslq %r11d,%r10
  100ddc:	c4 e1 f9 7e f9       	vmovq  %xmm7,%rcx
  100de1:	4c 89 95 30 fe ff ff 	mov    %r10,-0x1d0(%rbp)
  100de8:	49 29 ca             	sub    %rcx,%r10
  100deb:	c4 01 7b 10 3c d6    	vmovsd (%r14,%r10,8),%xmm15
  100df1:	c5 fb 59 00          	vmulsd (%rax),%xmm0,%xmm0
  100df5:	c5 23 59 58 08       	vmulsd 0x8(%rax),%xmm11,%xmm11
  100dfa:	c5 e3 59 58 10       	vmulsd 0x10(%rax),%xmm3,%xmm3
  100dff:	c5 eb 59 50 18       	vmulsd 0x18(%rax),%xmm2,%xmm2
  100e04:	c5 0b 59 70 20       	vmulsd 0x20(%rax),%xmm14,%xmm14
  100e09:	c5 13 59 68 28       	vmulsd 0x28(%rax),%xmm13,%xmm13
  100e0e:	c4 c1 7b 58 c3       	vaddsd %xmm11,%xmm0,%xmm0
  100e13:	c4 c1 6b 58 d6       	vaddsd %xmm14,%xmm2,%xmm2
  100e18:	c5 fb 58 c3          	vaddsd %xmm3,%xmm0,%xmm0
  100e1c:	c4 c1 6b 58 d5       	vaddsd %xmm13,%xmm2,%xmm2
  100e21:	c4 c1 7b 58 c7       	vaddsd %xmm15,%xmm0,%xmm0
  100e26:	c5 fb 58 c2          	vaddsd %xmm2,%xmm0,%xmm0
  100e2a:	c5 f9 2f 05 be 3b 05 	vcomisd 0x53bbe(%rip),%xmm0        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100e31:	00 
  100e32:	0f 93 85 14 fe ff ff 	setae  -0x1ec(%rbp)
  100e39:	0f b6 8d 14 fe ff ff 	movzbl -0x1ec(%rbp),%ecx
  100e40:	c5 79 2f e0          	vcomisd %xmm0,%xmm12
  100e44:	0f 93 85 14 fe ff ff 	setae  -0x1ec(%rbp)
  100e4b:	44 0f b6 95 14 fe ff 	movzbl -0x1ec(%rbp),%r10d
  100e52:	ff 
  100e53:	44 84 d1             	test   %r10b,%cl
  100e56:	0f 84 3b fd ff ff    	je     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100e5c:	45 85 db             	test   %r11d,%r11d
  100e5f:	0f 88 18 06 00 00    	js     10147d <mj__data__inertia_phase__solve_acceleration+0x12dd>
  100e65:	4c 8b 95 30 fe ff ff 	mov    -0x1d0(%rbp),%r10
  100e6c:	c4 e1 f9 7e f9       	vmovq  %xmm7,%rcx
  100e71:	49 29 ca             	sub    %rcx,%r10
  100e74:	c4 81 7b 11 04 d6    	vmovsd %xmm0,(%r14,%r10,8)
  100e7a:	8b 8d 10 fe ff ff    	mov    -0x1f0(%rbp),%ecx
  100e80:	39 8d 44 fe ff ff    	cmp    %ecx,-0x1bc(%rbp)
  100e86:	0f 85 22 fc ff ff    	jne    100aae <mj__data__inertia_phase__solve_acceleration+0x90e>
  100e8c:	e9 e7 fb ff ff       	jmp    100a78 <mj__data__inertia_phase__solve_acceleration+0x8d8>
  100e91:	0f 1f 40 00          	nopl   0x0(%rax)
  100e95:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  100e9c:	00 00 00 00 
  100ea0:	8b 8d 38 ff ff ff    	mov    -0xc8(%rbp),%ecx
  100ea6:	c7 85 44 fe ff ff ff 	movl   $0xffffffff,-0x1bc(%rbp)
  100ead:	ff ff ff 
  100eb0:	89 8d 10 fe ff ff    	mov    %ecx,-0x1f0(%rbp)
  100eb6:	ff 85 44 fe ff ff    	incl   -0x1bc(%rbp)
  100ebc:	44 8b 85 10 fe ff ff 	mov    -0x1f0(%rbp),%r8d
  100ec3:	44 03 85 44 fe ff ff 	add    -0x1bc(%rbp),%r8d
  100eca:	0f 80 3c 04 00 00    	jo     10130c <mj__data__inertia_phase__solve_acceleration+0x116c>
  100ed0:	45 85 c0             	test   %r8d,%r8d
  100ed3:	0f 88 47 04 00 00    	js     101320 <mj__data__inertia_phase__solve_acceleration+0x1180>
  100ed9:	44 39 85 40 fe ff ff 	cmp    %r8d,-0x1c0(%rbp)
  100ee0:	0f 8f ac 03 00 00    	jg     101292 <mj__data__inertia_phase__solve_acceleration+0x10f2>
  100ee6:	44 39 85 2c fe ff ff 	cmp    %r8d,-0x1d4(%rbp)
  100eed:	0f 8c 9f 03 00 00    	jl     101292 <mj__data__inertia_phase__solve_acceleration+0x10f2>
  100ef3:	39 95 00 fe ff ff    	cmp    %edx,-0x200(%rbp)
  100ef9:	0f 8c 11 02 00 00    	jl     101110 <mj__data__inertia_phase__solve_acceleration+0xf70>
  100eff:	44 39 85 28 fe ff ff 	cmp    %r8d,-0x1d8(%rbp)
  100f06:	0f 8f 8e 04 00 00    	jg     10139a <mj__data__inertia_phase__solve_acceleration+0x11fa>
  100f0c:	44 39 85 24 fe ff ff 	cmp    %r8d,-0x1dc(%rbp)
  100f13:	0f 8c 81 04 00 00    	jl     10139a <mj__data__inertia_phase__solve_acceleration+0x11fa>
  100f19:	45 89 c2             	mov    %r8d,%r10d
  100f1c:	c4 e1 f9 7e e9       	vmovq  %xmm5,%rcx
  100f21:	4d 89 d0             	mov    %r10,%r8
  100f24:	49 29 c8             	sub    %rcx,%r8
  100f27:	4d 69 c0 b8 00 00 00 	imul   $0xb8,%r8,%r8
  100f2e:	47 0f b6 44 05 00    	movzbl 0x0(%r13,%r8,1),%r8d
  100f34:	41 80 f8 01          	cmp    $0x1,%r8b
  100f38:	0f 84 e6 01 00 00    	je     101124 <mj__data__inertia_phase__solve_acceleration+0xf84>
  100f3e:	c4 e1 f9 7e f1       	vmovq  %xmm6,%rcx
  100f43:	4d 89 d0             	mov    %r10,%r8
  100f46:	49 29 c8             	sub    %rcx,%r8
  100f49:	4f 8d 04 40          	lea    (%r8,%r8,2),%r8
  100f4d:	49 c1 e0 04          	shl    $0x4,%r8
  100f51:	4b 8d 4c 04 18       	lea    0x18(%r12,%r8,1),%rcx
  100f56:	c4 81 7a 6f 54 04 18 	vmovdqu 0x18(%r12,%r8,1),%xmm2
  100f5d:	c5 f9 7f 95 50 fe ff 	vmovdqa %xmm2,-0x1b0(%rbp)
  100f64:	ff 
  100f65:	4c 8b 41 10          	mov    0x10(%rcx),%r8
  100f69:	4c 89 85 60 fe ff ff 	mov    %r8,-0x1a0(%rbp)
  100f70:	c5 fb 10 85 50 fe ff 	vmovsd -0x1b0(%rbp),%xmm0
  100f77:	ff 
  100f78:	c5 fb 10 9d 58 fe ff 	vmovsd -0x1a8(%rbp),%xmm3
  100f7f:	ff 
  100f80:	c5 fb 10 95 60 fe ff 	vmovsd -0x1a0(%rbp),%xmm2
  100f87:	ff 
  100f88:	c4 41 09 57 f6       	vxorpd %xmm14,%xmm14,%xmm14
  100f8d:	c4 41 79 28 fe       	vmovapd %xmm14,%xmm15
  100f92:	c4 41 79 28 de       	vmovapd %xmm14,%xmm11
  100f97:	c5 79 2f e0          	vcomisd %xmm0,%xmm12
  100f9b:	0f 82 f6 fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100fa1:	c5 f9 2f 05 47 3a 05 	vcomisd 0x53a47(%rip),%xmm0        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100fa8:	00 
  100fa9:	0f 82 e8 fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100faf:	c5 79 2f e3          	vcomisd %xmm3,%xmm12
  100fb3:	0f 82 de fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100fb9:	c5 f9 2f 1d 2f 3a 05 	vcomisd 0x53a2f(%rip),%xmm3        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100fc0:	00 
  100fc1:	0f 82 d0 fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100fc7:	c5 79 2f e2          	vcomisd %xmm2,%xmm12
  100fcb:	0f 82 c6 fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100fd1:	c5 f9 2f 15 17 3a 05 	vcomisd 0x53a17(%rip),%xmm2        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100fd8:	00 
  100fd9:	0f 82 b8 fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100fdf:	c4 41 79 2f e3       	vcomisd %xmm11,%xmm12
  100fe4:	0f 82 ad fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100fea:	c5 79 2f 1d fe 39 05 	vcomisd 0x539fe(%rip),%xmm11        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  100ff1:	00 
  100ff2:	0f 82 9f fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  100ff8:	c4 41 79 2f e7       	vcomisd %xmm15,%xmm12
  100ffd:	0f 82 94 fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  101003:	c5 79 2f 3d e5 39 05 	vcomisd 0x539e5(%rip),%xmm15        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  10100a:	00 
  10100b:	0f 82 86 fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  101011:	c4 41 79 2f e6       	vcomisd %xmm14,%xmm12
  101016:	0f 82 7b fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  10101c:	c5 79 2f 35 cc 39 05 	vcomisd 0x539cc(%rip),%xmm14        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  101023:	00 
  101024:	0f 82 6d fb ff ff    	jb     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  10102a:	4d 89 d0             	mov    %r10,%r8
  10102d:	c4 e1 f9 7e e9       	vmovq  %xmm5,%rcx
  101032:	49 29 c8             	sub    %rcx,%r8
  101035:	4d 69 c0 b8 00 00 00 	imul   $0xb8,%r8,%r8
  10103c:	47 8b 54 05 0c       	mov    0xc(%r13,%r8,1),%r10d
  101041:	44 39 95 20 fe ff ff 	cmp    %r10d,-0x1e0(%rbp)
  101048:	0f 8f 43 04 00 00    	jg     101491 <mj__data__inertia_phase__solve_acceleration+0x12f1>
  10104e:	44 39 95 18 fe ff ff 	cmp    %r10d,-0x1e8(%rbp)
  101055:	0f 8c 36 04 00 00    	jl     101491 <mj__data__inertia_phase__solve_acceleration+0x12f1>
  10105b:	49 63 ca             	movslq %r10d,%rcx
  10105e:	49 89 c8             	mov    %rcx,%r8
  101061:	48 89 8d 30 fe ff ff 	mov    %rcx,-0x1d0(%rbp)
  101068:	c4 e1 f9 7e f9       	vmovq  %xmm7,%rcx
  10106d:	49 29 c8             	sub    %rcx,%r8
  101070:	c4 01 7b 10 2c c6    	vmovsd (%r14,%r8,8),%xmm13
  101076:	c5 fb 59 00          	vmulsd (%rax),%xmm0,%xmm0
  10107a:	c5 e3 59 58 08       	vmulsd 0x8(%rax),%xmm3,%xmm3
  10107f:	c5 eb 59 50 10       	vmulsd 0x10(%rax),%xmm2,%xmm2
  101084:	c5 03 59 78 20       	vmulsd 0x20(%rax),%xmm15,%xmm15
  101089:	c5 0b 59 70 28       	vmulsd 0x28(%rax),%xmm14,%xmm14
  10108e:	c5 fb 58 c3          	vaddsd %xmm3,%xmm0,%xmm0
  101092:	c5 fb 58 c2          	vaddsd %xmm2,%xmm0,%xmm0
  101096:	c5 a3 59 50 18       	vmulsd 0x18(%rax),%xmm11,%xmm2
  10109b:	c4 c1 7b 58 c5       	vaddsd %xmm13,%xmm0,%xmm0
  1010a0:	c4 c1 6b 58 d7       	vaddsd %xmm15,%xmm2,%xmm2
  1010a5:	c4 c1 6b 58 d6       	vaddsd %xmm14,%xmm2,%xmm2
  1010aa:	c5 fb 58 c2          	vaddsd %xmm2,%xmm0,%xmm0
  1010ae:	c5 f9 2f 05 3a 39 05 	vcomisd 0x5393a(%rip),%xmm0        # 1549f0 <ada__numerics__long_elementary_functions__two_pi+0x280>
  1010b5:	00 
  1010b6:	0f 93 85 0c fe ff ff 	setae  -0x1f4(%rbp)
  1010bd:	c5 79 2f e0          	vcomisd %xmm0,%xmm12
  1010c1:	41 0f 93 c0          	setae  %r8b
  1010c5:	44 84 85 0c fe ff ff 	test   %r8b,-0x1f4(%rbp)
  1010cc:	0f 84 c5 fa ff ff    	je     100b97 <mj__data__inertia_phase__solve_acceleration+0x9f7>
  1010d2:	45 85 d2             	test   %r10d,%r10d
  1010d5:	0f 88 a2 03 00 00    	js     10147d <mj__data__inertia_phase__solve_acceleration+0x12dd>
  1010db:	48 8b 8d 30 fe ff ff 	mov    -0x1d0(%rbp),%rcx
  1010e2:	c4 c1 f9 7e f8       	vmovq  %xmm7,%r8
  1010e7:	4c 29 c1             	sub    %r8,%rcx
  1010ea:	c4 c1 7b 11 04 ce    	vmovsd %xmm0,(%r14,%rcx,8)
  1010f0:	44 8b 85 44 fe ff ff 	mov    -0x1bc(%rbp),%r8d
  1010f7:	44 39 85 14 fe ff ff 	cmp    %r8d,-0x1ec(%rbp)
  1010fe:	0f 85 b2 fd ff ff    	jne    100eb6 <mj__data__inertia_phase__solve_acceleration+0xd16>
  101104:	e9 0f fc ff ff       	jmp    100d18 <mj__data__inertia_phase__solve_acceleration+0xb78>
  101109:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  101110:	be 31 00 00 00       	mov    $0x31,%esi
  101115:	48 8d 3d f7 fb 04 00 	lea    0x4fbf7(%rip),%rdi        # 150d13 <CSWTCH.1374+0x1693>
  10111c:	c5 f8 77             	vzeroupper
  10111f:	e8 92 40 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  101124:	4d 89 d0             	mov    %r10,%r8
  101127:	c4 e1 f9 7e f1       	vmovq  %xmm6,%rcx
  10112c:	49 29 c8             	sub    %rcx,%r8
  10112f:	4d 6b c0 30          	imul   $0x30,%r8,%r8
  101133:	c4 81 7a 6f 44 04 18 	vmovdqu 0x18(%r12,%r8,1),%xmm0
  10113a:	c5 f9 7f 85 70 fe ff 	vmovdqa %xmm0,-0x190(%rbp)
  101141:	ff 
  101142:	4f 8b 44 04 28       	mov    0x28(%r12,%r8,1),%r8
  101147:	48 8b 8d 48 fe ff ff 	mov    -0x1b8(%rbp),%rcx
  10114e:	4c 89 85 80 fe ff ff 	mov    %r8,-0x180(%rbp)
  101155:	4d 89 d0             	mov    %r10,%r8
  101158:	c5 7b 10 9d 70 fe ff 	vmovsd -0x190(%rbp),%xmm11
  10115f:	ff 
  101160:	c5 7b 10 bd 78 fe ff 	vmovsd -0x188(%rbp),%xmm15
  101167:	ff 
  101168:	c5 7b 10 b5 80 fe ff 	vmovsd -0x180(%rbp),%xmm14
  10116f:	ff 
  101170:	c5 7b 10 29          	vmovsd (%rcx),%xmm13
  101174:	c4 e1 f9 7e f1       	vmovq  %xmm6,%rcx
  101179:	49 29 c8             	sub    %rcx,%r8
  10117c:	48 8b 8d 48 fe ff ff 	mov    -0x1b8(%rbp),%rcx
  101183:	4d 6b c0 30          	imul   $0x30,%r8,%r8
  101187:	4d 01 e0             	add    %r12,%r8
  10118a:	c4 41 13 5c 28       	vsubsd (%r8),%xmm13,%xmm13
  10118f:	c5 fb 10 51 08       	vmovsd 0x8(%rcx),%xmm2
  101194:	62 e1 ff 08 10 41 02 	vmovsd 0x10(%rcx),%xmm16
  10119b:	c4 c1 6b 5c 50 08    	vsubsd 0x8(%r8),%xmm2,%xmm2
  1011a1:	62 c1 ff 00 5c 40 02 	vsubsd 0x10(%r8),%xmm16,%xmm16
  1011a8:	62 c1 ff 08 10 48 04 	vmovsd 0x20(%r8),%xmm17
  1011af:	c4 c1 7b 10 58 28    	vmovsd 0x28(%r8),%xmm3
  1011b5:	62 c1 ff 08 10 50 03 	vmovsd 0x18(%r8),%xmm18
  1011bc:	62 e1 ef 08 59 db    	vmulsd %xmm3,%xmm2,%xmm19
  1011c2:	c5 93 59 db          	vmulsd %xmm3,%xmm13,%xmm3
  1011c6:	62 b1 ff 00 59 c1    	vmulsd %xmm17,%xmm16,%xmm0
  1011cc:	62 b1 ef 08 59 d2    	vmulsd %xmm18,%xmm2,%xmm2
  1011d2:	62 a1 ff 00 59 c2    	vmulsd %xmm18,%xmm16,%xmm16
  1011d8:	62 31 97 08 59 e9    	vmulsd %xmm17,%xmm13,%xmm13
  1011de:	62 b1 ff 08 5c c3    	vsubsd %xmm19,%xmm0,%xmm0
  1011e4:	62 b1 e7 08 5c d8    	vsubsd %xmm16,%xmm3,%xmm3
  1011ea:	c4 c1 6b 5c d5       	vsubsd %xmm13,%xmm2,%xmm2
  1011ef:	e9 a3 fd ff ff       	jmp    100f97 <mj__data__inertia_phase__solve_acceleration+0xdf7>
  1011f4:	41 89 d0             	mov    %edx,%r8d
  1011f7:	45 39 c1             	cmp    %r8d,%r9d
  1011fa:	0f 8f ae 01 00 00    	jg     1013ae <mj__data__inertia_phase__solve_acceleration+0x120e>
  101200:	44 39 c7             	cmp    %r8d,%edi
  101203:	0f 8c a5 01 00 00    	jl     1013ae <mj__data__inertia_phase__solve_acceleration+0x120e>
  101209:	c4 e1 f9 7e e1       	vmovq  %xmm4,%rcx
  10120e:	49 29 c8             	sub    %rcx,%r8
  101211:	4f 8d 04 40          	lea    (%r8,%r8,2),%r8
  101215:	49 c1 e0 06          	shl    $0x6,%r8
  101219:	4d 01 f8             	add    %r15,%r8
  10121c:	62 d1 fe 48 6f 00    	vmovdqu64 (%r8),%zmm0
  101222:	62 f1 fe 48 7f 85 10 	vmovdqu64 %zmm0,-0xf0(%rbp)
  101229:	ff ff ff 
  10122c:	62 d1 fe 48 6f 40 01 	vmovdqu64 0x40(%r8),%zmm0
  101233:	62 f1 fe 48 7f 85 50 	vmovdqu64 %zmm0,-0xb0(%rbp)
  10123a:	ff ff ff 
  10123d:	62 d1 fe 48 6f 40 02 	vmovdqu64 0x80(%r8),%zmm0
  101244:	8b 8d 3c ff ff ff    	mov    -0xc4(%rbp),%ecx
  10124a:	62 f1 fe 48 7f 85 90 	vmovdqu64 %zmm0,-0x70(%rbp)
  101251:	ff ff ff 
  101254:	85 c9                	test   %ecx,%ecx
  101256:	7f 18                	jg     101270 <mj__data__inertia_phase__solve_acceleration+0x10d0>
  101258:	44 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%r8d
  10125f:	45 85 c0             	test   %r8d,%r8d
  101262:	7f 93                	jg     1011f7 <mj__data__inertia_phase__solve_acceleration+0x1057>
  101264:	e9 03 f5 ff ff       	jmp    10076c <mj__data__inertia_phase__solve_acceleration+0x5cc>
  101269:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  101270:	8b 85 38 ff ff ff    	mov    -0xc8(%rbp),%eax
  101276:	85 c0                	test   %eax,%eax
  101278:	0f 88 a2 00 00 00    	js     101320 <mj__data__inertia_phase__solve_acceleration+0x1180>
  10127e:	39 85 40 fe ff ff    	cmp    %eax,-0x1c0(%rbp)
  101284:	7f 0c                	jg     101292 <mj__data__inertia_phase__solve_acceleration+0x10f2>
  101286:	39 85 2c fe ff ff    	cmp    %eax,-0x1d4(%rbp)
  10128c:	0f 8d 7e fe ff ff    	jge    101110 <mj__data__inertia_phase__solve_acceleration+0xf70>
  101292:	be 31 00 00 00       	mov    $0x31,%esi
  101297:	48 8d 3d 75 fa 04 00 	lea    0x4fa75(%rip),%rdi        # 150d13 <CSWTCH.1374+0x1693>
  10129e:	c5 f8 77             	vzeroupper
  1012a1:	e8 10 3f 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  1012a6:	be be 06 00 00       	mov    $0x6be,%esi
  1012ab:	48 8d 3d 8e f8 04 00 	lea    0x4f88e(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1012b2:	e8 99 3f 01 00       	call   115250 <__gnat_rcheck_CE_Range_Check>
  1012b7:	be be 06 00 00       	mov    $0x6be,%esi
  1012bc:	48 8d 3d 7d f8 04 00 	lea    0x4f87d(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1012c3:	e8 88 3f 01 00       	call   115250 <__gnat_rcheck_CE_Range_Check>
  1012c8:	be be 06 00 00       	mov    $0x6be,%esi
  1012cd:	48 8d 3d 6c f8 04 00 	lea    0x4f86c(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1012d4:	e8 77 3f 01 00       	call   115250 <__gnat_rcheck_CE_Range_Check>
  1012d9:	be be 06 00 00       	mov    $0x6be,%esi
  1012de:	48 8d 3d 5b f8 04 00 	lea    0x4f85b(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1012e5:	e8 66 3f 01 00       	call   115250 <__gnat_rcheck_CE_Range_Check>
  1012ea:	be be 06 00 00       	mov    $0x6be,%esi
  1012ef:	48 8d 3d 4a f8 04 00 	lea    0x4f84a(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1012f6:	e8 55 3f 01 00       	call   115250 <__gnat_rcheck_CE_Range_Check>
  1012fb:	be 47 07 00 00       	mov    $0x747,%esi
  101300:	48 8d 3d 39 f8 04 00 	lea    0x4f839(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101307:	e8 3c 3e 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  10130c:	be 2c 00 00 00       	mov    $0x2c,%esi
  101311:	48 8d 3d fb f9 04 00 	lea    0x4f9fb(%rip),%rdi        # 150d13 <CSWTCH.1374+0x1693>
  101318:	c5 f8 77             	vzeroupper
  10131b:	e8 04 3f 01 00       	call   115224 <__gnat_rcheck_CE_Overflow_Check>
  101320:	be 2c 00 00 00       	mov    $0x2c,%esi
  101325:	48 8d 3d e7 f9 04 00 	lea    0x4f9e7(%rip),%rdi        # 150d13 <CSWTCH.1374+0x1693>
  10132c:	c5 f8 77             	vzeroupper
  10132f:	e8 1c 3f 01 00       	call   115250 <__gnat_rcheck_CE_Range_Check>
  101334:	be f3 06 00 00       	mov    $0x6f3,%esi
  101339:	48 8d 3d 00 f8 04 00 	lea    0x4f800(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101340:	e8 03 3e 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  101345:	be f3 06 00 00       	mov    $0x6f3,%esi
  10134a:	48 8d 3d ef f7 04 00 	lea    0x4f7ef(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101351:	e8 f2 3d 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  101356:	be f3 06 00 00       	mov    $0x6f3,%esi
  10135b:	48 8d 3d de f7 04 00 	lea    0x4f7de(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101362:	e8 e1 3d 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  101367:	be f2 06 00 00       	mov    $0x6f2,%esi
  10136c:	48 8d 3d cd f7 04 00 	lea    0x4f7cd(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101373:	e8 d0 3d 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  101378:	be f2 06 00 00       	mov    $0x6f2,%esi
  10137d:	48 8d 3d bc f7 04 00 	lea    0x4f7bc(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101384:	e8 bf 3d 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  101389:	be f2 06 00 00       	mov    $0x6f2,%esi
  10138e:	48 8d 3d ab f7 04 00 	lea    0x4f7ab(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101395:	e8 ae 3d 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  10139a:	be 32 00 00 00       	mov    $0x32,%esi
  10139f:	48 8d 3d 6d f9 04 00 	lea    0x4f96d(%rip),%rdi        # 150d13 <CSWTCH.1374+0x1693>
  1013a6:	c5 f8 77             	vzeroupper
  1013a9:	e8 08 3e 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  1013ae:	be 27 00 00 00       	mov    $0x27,%esi
  1013b3:	48 8d 3d 59 f9 04 00 	lea    0x4f959(%rip),%rdi        # 150d13 <CSWTCH.1374+0x1693>
  1013ba:	c5 f8 77             	vzeroupper
  1013bd:	e8 f4 3d 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  1013c2:	be 47 07 00 00       	mov    $0x747,%esi
  1013c7:	48 8d 3d 72 f7 04 00 	lea    0x4f772(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1013ce:	e8 e3 3d 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  1013d3:	be 4a 07 00 00       	mov    $0x74a,%esi
  1013d8:	48 8d 3d 61 f7 04 00 	lea    0x4f761(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1013df:	e8 fe 3d 01 00       	call   1151e2 <__gnat_rcheck_CE_Length_Check>
  1013e4:	be 21 07 00 00       	mov    $0x721,%esi
  1013e9:	48 8d 3d 50 f7 04 00 	lea    0x4f750(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  1013f0:	e8 53 3d 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  1013f5:	be 21 07 00 00       	mov    $0x721,%esi
  1013fa:	48 8d 3d 3f f7 04 00 	lea    0x4f73f(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101401:	e8 42 3d 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  101406:	be 20 07 00 00       	mov    $0x720,%esi
  10140b:	48 8d 3d 2e f7 04 00 	lea    0x4f72e(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101412:	e8 31 3d 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  101417:	be 20 07 00 00       	mov    $0x720,%esi
  10141c:	48 8d 3d 1d f7 04 00 	lea    0x4f71d(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101423:	e8 20 3d 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  101428:	be 4a 07 00 00       	mov    $0x74a,%esi
  10142d:	48 8d 3d 0c f7 04 00 	lea    0x4f70c(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101434:	e8 17 3e 01 00       	call   115250 <__gnat_rcheck_CE_Range_Check>
  101439:	be 4a 07 00 00       	mov    $0x74a,%esi
  10143e:	48 8d 3d fb f6 04 00 	lea    0x4f6fb(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101445:	e8 fe 3c 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  10144a:	be 4a 07 00 00       	mov    $0x74a,%esi
  10144f:	48 8d 3d ea f6 04 00 	lea    0x4f6ea(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101456:	e8 f5 3d 01 00       	call   115250 <__gnat_rcheck_CE_Range_Check>
  10145b:	be 4a 07 00 00       	mov    $0x74a,%esi
  101460:	48 8d 3d d9 f6 04 00 	lea    0x4f6d9(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101467:	e8 dc 3c 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  10146c:	be 20 07 00 00       	mov    $0x720,%esi
  101471:	48 8d 3d c8 f6 04 00 	lea    0x4f6c8(%rip),%rdi        # 150b40 <CSWTCH.1374+0x14c0>
  101478:	e8 cb 3c 01 00       	call   115148 <__gnat_rcheck_CE_Access_Check>
  10147d:	be 0a 00 00 00       	mov    $0xa,%esi
  101482:	48 8d 3d 8a f8 04 00 	lea    0x4f88a(%rip),%rdi        # 150d13 <CSWTCH.1374+0x1693>
  101489:	c5 f8 77             	vzeroupper
  10148c:	e8 3b 3d 01 00       	call   1151cc <__gnat_rcheck_CE_Invalid_Data>
  101491:	be 07 00 00 00       	mov    $0x7,%esi
  101496:	48 8d 3d 76 f8 04 00 	lea    0x4f876(%rip),%rdi        # 150d13 <CSWTCH.1374+0x1693>
  10149d:	c5 f8 77             	vzeroupper
  1014a0:	e8 11 3d 01 00       	call   1151b6 <__gnat_rcheck_CE_Index_Check>
  1014a5:	48 89 c3             	mov    %rax,%rbx
  1014a8:	e9 f5 4d f0 ff       	jmp    62a2 <mj__data__inertia_phase__solve_acceleration.cold>
  1014ad:	48 89 c3             	mov    %rax,%rbx
  1014b0:	e9 10 4e f0 ff       	jmp    62c5 <mj__data__inertia_phase__solve_acceleration.cold+0x23>
  1014b5:	48 89 c3             	mov    %rax,%rbx
  1014b8:	e9 19 4e f0 ff       	jmp    62d6 <mj__data__inertia_phase__solve_acceleration.cold+0x34>
  1014bd:	48 89 c3             	mov    %rax,%rbx
  1014c0:	e9 2a 4e f0 ff       	jmp    62ef <mj__data__inertia_phase__solve_acceleration.cold+0x4d>
  1014c5:	e9 1d 4e f0 ff       	jmp    62e7 <mj__data__inertia_phase__solve_acceleration.cold+0x45>

Disassembly of section .fini:
