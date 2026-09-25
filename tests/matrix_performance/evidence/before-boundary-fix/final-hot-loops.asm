<bench_ada__run_1.isra.0>:
    58c0:	push   rbp
    58c1:	mov    r10,rdx
    58c4:	mov    rbp,rsp
    58c7:	push   rbx
    58c8:	sub    rsp,0x8
    58cc:	mov    rdx,QWORD PTR [rbp+0x10]
    58d0:	mov    rbx,QWORD PTR [rbp+0x18]
    58d4:	test   edi,edi
    58d6:	je     590e <bench_ada__run_1.isra.0+0x4e>
    58d8:	mov    rax,rsi
    58db:	mov    r11d,edi
    58de:	xor    esi,esi
    58e0:	inc    esi
    58e2:	vmovdqu64 zmm0,ZMMWORD PTR [rax]
    58e8:	mov    rdi,QWORD PTR [rax+0x40]
    58ec:	mov    QWORD PTR [rsp-0x10],rdi
    58f1:	vmovdqu64 ZMMWORD PTR [rdx],zmm0
    58f7:	mov    QWORD PTR [rdx+0x40],rdi
    58fb:	vmovdqu64 ZMMWORD PTR [rsp-0x50],zmm0
    5906:	cmp    r11d,esi
    5909:	jne    58e0 <bench_ada__run_1.isra.0+0x20>
    590b:	vzeroupper
    590e:	add    rsp,0x8
    5912:	pop    rbx
    5913:	pop    rbp
    5914:	ret
    5915:	nop
    5916:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_10.isra.0>:
    60d0:	push   rbp
    60d1:	mov    rbp,rsp
    60d4:	push   r15
    60d6:	push   r14
    60d8:	push   r13
    60da:	push   r12
    60dc:	push   rbx
    60dd:	and    rsp,0xffffffffffffffc0
    60e1:	sub    rsp,0x8
    60e5:	mov    r12,QWORD PTR [rbp+0x20]
    60e9:	mov    DWORD PTR [rsp-0x8],edi
    60ed:	mov    DWORD PTR [rsp-0x20],esi
    60f1:	mov    DWORD PTR [rsp-0xc],edx
    60f5:	mov    r14,QWORD PTR [rbp+0x28]
    60f9:	test   edx,edx
    60fb:	je     61c0 <bench_ada__run_10.isra.0+0xf0>
    6101:	mov    ebx,edi
    6103:	mov    rax,rcx
    6106:	mov    rdi,r8
    6109:	mov    r15,QWORD PTR [rbp+0x18]
    610d:	lea    r11d,[rbx-0x1]
    6111:	mov    ecx,ebx
    6113:	mov    r8,r9
    6116:	mov    rbx,QWORD PTR [rbp+0x10]
    611a:	mov    DWORD PTR [rsp-0x34],r11d
    611f:	lea    edx,[rsi-0x1]
    6122:	cmp    edx,0xffffffff
    6125:	je     69b0 <bench_ada__run_10.isra.0+0x8e0>
    612b:	cmp    r11d,0xffffffff
    612f:	je     69b0 <bench_ada__run_10.isra.0+0x8e0>
    6135:	mov    r13d,esi
    6138:	mov    esi,edx
    613a:	mov    DWORD PTR [rsp-0x10],0x1
    6142:	mov    QWORD PTR [rsp-0x30],rsi
    6147:	mov    esi,ecx
    6149:	lea    rcx,[rip+0x2f230]        # 35380 <_fini+0x14>
    6150:	lea    r15,[r13*8+0x0]
    6158:	vmovq  xmm2,rcx
    615d:	mov    ecx,r11d
    6160:	mov    QWORD PTR [rsp],rsi
    6164:	lea    rsi,[rsi*8+0x0]
    616c:	mov    QWORD PTR [rsp-0x18],rcx
    6171:	vmovq  xmm4,rsi
    6176:	mov    rbx,r13
    6179:	mov    rsi,rdi
    617c:	mov    rdi,r14
    617f:	mov    r14,r12
    6182:	cmp    DWORD PTR [rsp-0x8],0x40
    6187:	ja     6a65 <bench_ada__run_10.isra.0+0x995>
    618d:	mov    rdx,QWORD PTR [rsp]
    6191:	vmovq  rcx,xmm2
    6196:	movsxd rdx,DWORD PTR [rcx+rdx*4]
    619a:	add    rdx,rcx
    619d:	jmp    rdx
    619f:	mov    ecx,ebx
    61a1:	mov    r15,QWORD PTR [rsp-0x50]
    61a6:	mov    rbx,QWORD PTR [rsp-0x28]
    61ab:	mov    rdx,QWORD PTR [rbp+0x10]
    61af:	mov    r11,QWORD PTR [rbp+0x18]
    61b3:	cmp    DWORD PTR [rsp-0xc],ecx
    61b7:	jne    6521 <bench_ada__run_10.isra.0+0x451>
    61bd:	vzeroupper
    61c0:	lea    rsp,[rbp-0x28]
    61c4:	pop    rbx
    61c5:	pop    r12
    61c7:	pop    r13
    61c9:	pop    r14
    61cb:	pop    r15
    61cd:	pop    rbp
    61ce:	ret
    61cf:	imul   rdx,rbx
    61d3:	mov    QWORD PTR [rsp-0x70],rsi
    61d8:	mov    QWORD PTR [rsp-0x78],r8
    61dd:	mov    QWORD PTR [rbp+0x28],rdi
    61e1:	vmovq  r9,xmm4
    61e6:	mov    r13,rax
    61e9:	mov    r12,r14
    61ec:	xor    r11d,r11d
    61ef:	shr    rcx,0x3
    61f3:	vmovq  xmm6,rdx
    61f8:	mov    rdx,rbx
    61fb:	shl    rdx,0x5
    61ff:	sub    r9,0x8
    6203:	mov    QWORD PTR [rsp-0x28],rcx
    6208:	lea    rcx,[rbx+rbx*4]
    620c:	mov    QWORD PTR [rsp-0x40],rdx
    6211:	vmovq  xmm5,r9
    6216:	mov    rdx,0xffffffffffffffff
    621d:	lea    r9,[rcx*8+0x0]
    6225:	vmovq  rsi,xmm5
    622a:	inc    rdx
    622d:	lea    rcx,[rsi+r12*1]
    6231:	cmp    rcx,r13
    6234:	jb     6249 <bench_ada__run_10.isra.0+0x179>
    6236:	vmovq  rsi,xmm6
    623b:	lea    rcx,[r13+rsi*8+0x0]
    6240:	cmp    rcx,r12
    6243:	jae    6785 <bench_ada__run_10.isra.0+0x6b5>
    6249:	mov    rsi,QWORD PTR [rsp-0x40]
    624e:	mov    QWORD PTR [rsp-0x48],r12
    6253:	mov    QWORD PTR [rsp-0x50],rdx
    6258:	mov    QWORD PTR [rsp-0x58],r11
    625d:	mov    QWORD PTR [rsp-0x60],rax
    6262:	mov    QWORD PTR [rsp-0x68],rbx
    6267:	mov    rdi,r12
    626a:	xor    ecx,ecx
    626c:	lea    r8,[rsi+r13*1]
    6270:	mov    rsi,r13
    6273:	lea    rbx,[r8+r15*2]
    6277:	vmovsd xmm1,QWORD PTR [r8]
    627c:	vmovhpd xmm1,xmm1,QWORD PTR [r8+r15*1]
    6282:	lea    rdx,[rsi+r15*2]
    6286:	vmovsd xmm0,QWORD PTR [rbx]
    628a:	vmovhpd xmm0,xmm0,QWORD PTR [rbx+r15*1]
    6290:	lea    r12,[rdx+r15*1]
    6294:	lea    r10,[rbx+r15*1]
    6298:	inc    rcx
    629b:	add    rdi,0x40
    629f:	lea    r8,[r10+r9*1]
    62a3:	vinsertf64x2 ymm1,ymm1,xmm0,0x1
    62aa:	vmovsd xmm0,QWORD PTR [rdx]
    62ae:	vmovhpd xmm3,xmm0,QWORD PTR [rdx+r15*1]
    62b4:	vmovsd xmm0,QWORD PTR [rsi]
    62b8:	vmovhpd xmm0,xmm0,QWORD PTR [rsi+r15*1]
    62be:	lea    rsi,[r12+r9*1]
    62c2:	vinsertf64x2 ymm0,ymm0,xmm3,0x1
    62c9:	vinsertf64x4 zmm0,zmm0,ymm1,0x1
    62d0:	vmovupd ZMMWORD PTR [rdi-0x40],zmm0
    62d7:	cmp    rcx,QWORD PTR [rsp-0x28]
    62dc:	jb     6273 <bench_ada__run_10.isra.0+0x1a3>
    62de:	mov    rsi,QWORD PTR [rsp-0x28]
    62e3:	mov    r12,QWORD PTR [rsp-0x48]
    62e8:	mov    rdx,QWORD PTR [rsp-0x50]
    62ed:	mov    r11,QWORD PTR [rsp-0x58]
    62f2:	mov    rax,QWORD PTR [rsp-0x60]
    62f7:	mov    rbx,QWORD PTR [rsp-0x68]
    62fc:	shl    rsi,0x3
    6300:	cmp    QWORD PTR [rsp],rsi
    6304:	je     63d4 <bench_ada__run_10.isra.0+0x304>
    630a:	mov    rdi,QWORD PTR [rsp-0x18]
    630f:	lea    rcx,[rsi-0x1]
    6313:	sub    rdi,rsi
    6316:	cmp    rdi,0x2
    631a:	jbe    6367 <bench_ada__run_10.isra.0+0x297>
    631c:	mov    r8,rbx
    631f:	inc    rdi
    6322:	imul   r8,rsi
    6326:	add    rsi,r11
    6329:	add    r8,rdx
    632c:	lea    r10,[rax+r8*8]
    6330:	lea    r8,[r10+r15*1]
    6334:	vmovsd xmm0,QWORD PTR [r8+r15*1]
    633a:	vmovhpd xmm3,xmm0,QWORD PTR [r8+r15*2]
    6340:	vmovsd xmm0,QWORD PTR [r10]
    6345:	vmovhpd xmm0,xmm0,QWORD PTR [r8]
    634a:	vinsertf64x2 ymm0,ymm0,xmm3,0x1
    6351:	vmovupd YMMWORD PTR [r14+rsi*8],ymm0
    6357:	mov    rsi,rdi
    635a:	and    rsi,0xfffffffffffffffc
    635e:	and    dil,0x3
    6362:	je     63d4 <bench_ada__run_10.isra.0+0x304>
    6364:	add    rcx,rsi
    6367:	lea    rdi,[rcx+0x1]
    636b:	mov    rsi,rbx
    636e:	mov    r10,QWORD PTR [rsp-0x18]
    6373:	imul   rsi,rdi
    6377:	add    rsi,rdx
    637a:	vmovsd xmm0,QWORD PTR [rax+rsi*8]
    637f:	mov    rsi,QWORD PTR [rsp]
    6383:	imul   rsi,rdx
    6387:	lea    r8,[rsi+rdi*1]
    638b:	vmovsd QWORD PTR [r14+r8*8],xmm0
    6391:	cmp    r10,rdi
    6394:	je     63d4 <bench_ada__run_10.isra.0+0x304>
    6396:	lea    r8,[rcx+0x2]
    639a:	mov    rdi,rbx
    639d:	imul   rdi,r8
    63a1:	add    rdi,rdx
    63a4:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    63a9:	lea    rdi,[rsi+r8*1]
    63ad:	vmovsd QWORD PTR [r14+rdi*8],xmm0
    63b3:	cmp    r10,r8
    63b6:	je     63d4 <bench_ada__run_10.isra.0+0x304>
    63b8:	add    rcx,0x3
    63bc:	mov    rdi,rbx
    63bf:	imul   rdi,rcx
    63c3:	add    rsi,rcx
    63c6:	add    rdi,rdx
    63c9:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    63ce:	vmovsd QWORD PTR [r14+rsi*8],xmm0
    63d4:	vmovq  rsi,xmm4
    63d9:	add    r11,QWORD PTR [rsp]
    63dd:	add    r13,0x8
    63e1:	add    r12,rsi
    63e4:	cmp    rdx,QWORD PTR [rsp-0x30]
    63e9:	jne    6225 <bench_ada__run_10.isra.0+0x155>
    63ef:	mov    rsi,QWORD PTR [rsp-0x70]
    63f4:	mov    r8,QWORD PTR [rsp-0x78]
    63f9:	mov    rdi,QWORD PTR [rbp+0x28]
    63fd:	mov    rcx,QWORD PTR [rbp+0x10]
    6401:	mov    rdx,QWORD PTR [rbp+0x18]
    6405:	mov    ecx,DWORD PTR [rsp-0x10]
    6409:	cmp    DWORD PTR [rsp-0xc],ecx
    640d:	je     61bd <bench_ada__run_10.isra.0+0xed>
    6413:	inc    ecx
    6415:	mov    rdx,QWORD PTR [rbp+0x18]
    6419:	mov    DWORD PTR [rsp-0x10],ecx
    641d:	mov    rcx,QWORD PTR [rbp+0x10]
    6421:	mov    edx,DWORD PTR [rsp-0x20]
    6425:	mov    rcx,QWORD PTR [rsp]
    6429:	cmp    DWORD PTR [rsp-0x8],edx
    642d:	lea    rdx,[rcx-0x1]
    6431:	je     61cf <bench_ada__run_10.isra.0+0xff>
    6437:	imul   rdx,rbx
    643b:	mov    QWORD PTR [rsp-0x28],rsi
    6440:	mov    QWORD PTR [rsp-0x40],r8
    6445:	mov    QWORD PTR [rbp+0x28],rdi
    6449:	mov    r12,rax
    644c:	mov    r10,r14
    644f:	xor    r11d,r11d
    6452:	vmovq  r8,xmm4
    6457:	shr    rcx,1
    645a:	vmovq  xmm1,rdx
    645f:	vmovq  rdx,xmm4
    6464:	sub    rdx,0x8
    6468:	mov    r13,rcx
    646b:	vmovq  rsi,xmm1
    6470:	mov    rdi,rdx
    6473:	xchg   ax,ax
    6475:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6480:	lea    rdx,[rdi+r10*1]
    6484:	cmp    rdx,r12
    6487:	jb     6496 <bench_ada__run_10.isra.0+0x3c6>
    6489:	lea    rdx,[r12+rsi*8]
    648d:	cmp    rdx,r10
    6490:	jae    6757 <bench_ada__run_10.isra.0+0x687>
    6496:	mov    r9,r10
    6499:	mov    rdx,r12
    649c:	xor    ecx,ecx
    649e:	vmovsd xmm0,QWORD PTR [rdx]
    64a2:	vmovhpd xmm0,xmm0,QWORD PTR [r15+rdx*1]
    64a8:	inc    rcx
    64ab:	lea    rdx,[rdx+r15*2]
    64af:	add    r9,0x10
    64b3:	vmovupd XMMWORD PTR [r9-0x10],xmm0
    64b9:	cmp    rcx,r13
    64bc:	jb     649e <bench_ada__run_10.isra.0+0x3ce>
    64be:	lea    rcx,[r13+r13*1+0x0]
    64c3:	cmp    QWORD PTR [rsp],rcx
    64c7:	je     64e9 <bench_ada__run_10.isra.0+0x419>
    64c9:	mov    rdx,rbx
    64cc:	imul   rdx,rcx
    64d0:	add    rdx,r11
    64d3:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    64d8:	mov    rdx,QWORD PTR [rsp]
    64dc:	imul   rdx,r11
    64e0:	add    rdx,rcx
    64e3:	vmovsd QWORD PTR [r14+rdx*8],xmm0
    64e9:	inc    r11
    64ec:	add    r10,r8
    64ef:	add    r12,0x8
    64f3:	cmp    rbx,r11
    64f6:	jne    6480 <bench_ada__run_10.isra.0+0x3b0>
    64f8:	vmovq  xmm4,r8
    64fd:	mov    rsi,QWORD PTR [rsp-0x28]
    6502:	mov    rdi,QWORD PTR [rbp+0x28]
    6506:	mov    r8,QWORD PTR [rsp-0x40]
    650b:	mov    rcx,QWORD PTR [rbp+0x10]
    650f:	mov    rdx,QWORD PTR [rbp+0x18]
    6513:	mov    ecx,DWORD PTR [rsp-0x10]
    6517:	cmp    DWORD PTR [rsp-0xc],ecx
    651b:	je     61bd <bench_ada__run_10.isra.0+0xed>
    6521:	inc    ecx
    6523:	mov    rdx,QWORD PTR [rbp+0x18]
    6527:	mov    DWORD PTR [rsp-0x10],ecx
    652b:	mov    rcx,QWORD PTR [rbp+0x10]
    652f:	jmp    6182 <bench_ada__run_10.isra.0+0xb2>
    6534:	mov    rcx,r15
    6537:	shr    rcx,0x3
    653b:	lea    r10,[rcx+rcx*4]
    653f:	mov    r9d,DWORD PTR [rsp-0x8]
    6544:	mov    r11d,DWORD PTR [rsp-0x34]
    6549:	mov    r12,rsi
    654c:	vmovq  xmm7,r10
    6551:	xor    edx,edx
    6553:	lea    rsi,[rcx+rcx*2]
    6557:	imul   r10,rcx,0x6
    655b:	vmovq  xmm3,r10
    6560:	imul   r10,rcx,0x7
    6564:	sar    r9d,1
    6567:	vmovq  xmm1,r10
    656c:	lea    r10,[rcx+rcx*8]
    6570:	dec    r9d
    6573:	vmovq  xmm5,r10
    6578:	imul   r10,rcx,0xa
    657c:	vmovq  xmm6,r10
    6581:	lea    r13,[rcx+rcx*1]
    6585:	vmovq  xmm8,r13
    658a:	mov    r13,rdi
    658d:	mov    rdi,QWORD PTR [rsp]
    6591:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    6596:	imul   rdi,rdx
    659a:	lea    r10,[r14+rdi*8]
    659e:	lea    rdi,[rcx+rdx*1]
    65a2:	vmovsd QWORD PTR [r10],xmm0
    65a7:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    65ac:	vmovq  rdi,xmm8
    65b1:	add    rdi,rdx
    65b4:	vmovsd QWORD PTR [r10+0x8],xmm0
    65ba:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    65bf:	lea    rdi,[rsi+rdx*1]
    65c3:	vmovsd QWORD PTR [r10+0x10],xmm0
    65c9:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    65ce:	vmovsd QWORD PTR [r10+0x18],xmm0
    65d4:	cmp    r9d,0x1
    65d8:	je     66ad <bench_ada__run_10.isra.0+0x5dd>
    65de:	lea    rdi,[rdx+rcx*4]
    65e2:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    65e7:	vmovq  rdi,xmm7
    65ec:	add    rdi,rdx
    65ef:	vmovsd QWORD PTR [r10+0x20],xmm0
    65f5:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    65fa:	vmovsd QWORD PTR [r10+0x28],xmm0
    6600:	cmp    r9d,0x2
    6604:	je     66ad <bench_ada__run_10.isra.0+0x5dd>
    660a:	vmovq  rdi,xmm3
    660f:	add    rdi,rdx
    6612:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    6617:	vmovq  rdi,xmm1
    661c:	add    rdi,rdx
    661f:	vmovsd QWORD PTR [r10+0x30],xmm0
    6625:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    662a:	vmovsd QWORD PTR [r10+0x38],xmm0
    6630:	cmp    r9d,0x3
    6634:	je     66ad <bench_ada__run_10.isra.0+0x5dd>
    6636:	lea    rdi,[rdx+rcx*8]
    663a:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    663f:	vmovq  rdi,xmm5
    6644:	add    rdi,rdx
    6647:	vmovsd QWORD PTR [r10+0x40],xmm0
    664d:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    6652:	vmovsd QWORD PTR [r10+0x48],xmm0
    6658:	cmp    r9d,0x4
    665c:	je     66ad <bench_ada__run_10.isra.0+0x5dd>
    665e:	vmovq  rdi,xmm6
    6663:	add    rdi,rdx
    6666:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    666b:	imul   rdi,rcx,0xb
    666f:	add    rdi,rdx
    6672:	vmovsd QWORD PTR [r10+0x50],xmm0
    6678:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    667d:	vmovsd QWORD PTR [r10+0x58],xmm0
    6683:	cmp    r9d,0x5
    6687:	je     66ad <bench_ada__run_10.isra.0+0x5dd>
    6689:	imul   rdi,rcx,0xc
    668d:	add    rdi,rdx
    6690:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    6695:	imul   rdi,rcx,0xd
    6699:	add    rdi,rdx
    669c:	vmovsd QWORD PTR [r10+0x60],xmm0
    66a2:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    66a7:	vmovsd QWORD PTR [r10+0x68],xmm0
    66ad:	test   BYTE PTR [rsp-0x8],0x1
    66b2:	je     6740 <bench_ada__run_10.isra.0+0x670>
    66b8:	mov    r10,r11
    66bb:	mov    rdi,r13
    66be:	imul   r10,rcx
    66c2:	add    r10,rdx
    66c5:	vmovsd xmm0,QWORD PTR [rax+r10*8]
    66cb:	mov    r10,QWORD PTR [rsp]
    66cf:	imul   r10,rdx
    66d3:	inc    rdx
    66d6:	add    r10,r11
    66d9:	vmovsd QWORD PTR [r14+r10*8],xmm0
    66df:	cmp    rdx,rbx
    66e2:	jne    6581 <bench_ada__run_10.isra.0+0x4b1>
    66e8:	mov    rsi,r12
    66eb:	jmp    650b <bench_ada__run_10.isra.0+0x43b>
    66f0:	lea    r9,[rax+r15*1]
    66f4:	mov    rcx,r14
    66f7:	xor    edx,edx
    66f9:	lea    r10,[r9+r15*1]
    66fd:	nop    DWORD PTR [rax]
    6700:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    6705:	add    rcx,0x18
    6709:	vmovsd QWORD PTR [rcx-0x18],xmm0
    670e:	vmovsd xmm0,QWORD PTR [r9+rdx*8]
    6714:	vmovsd QWORD PTR [rcx-0x10],xmm0
    6719:	vmovsd xmm0,QWORD PTR [r10+rdx*8]
    671f:	inc    rdx
    6722:	vmovsd QWORD PTR [rcx-0x8],xmm0
    6727:	cmp    rdx,rbx
    672a:	jne    6700 <bench_ada__run_10.isra.0+0x630>
    672c:	jmp    650b <bench_ada__run_10.isra.0+0x43b>
    6731:	nop    DWORD PTR [rax+0x0]
    6735:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6740:	inc    rdx
    6743:	cmp    rbx,rdx
    6746:	jne    658d <bench_ada__run_10.isra.0+0x4bd>
    674c:	mov    rsi,r12
    674f:	mov    rdi,r13
    6752:	jmp    650b <bench_ada__run_10.isra.0+0x43b>
    6757:	mov    r9,QWORD PTR [rsp-0x18]
    675c:	mov    rdx,0xffffffffffffffff
    6763:	inc    rdx
    6766:	mov    rcx,rbx
    6769:	imul   rcx,rdx
    676d:	add    rcx,r11
    6770:	vmovsd xmm0,QWORD PTR [rax+rcx*8]
    6775:	vmovsd QWORD PTR [r10+rdx*8],xmm0
    677b:	cmp    r9,rdx
    677e:	jne    6763 <bench_ada__run_10.isra.0+0x693>
    6780:	jmp    64e9 <bench_ada__run_10.isra.0+0x419>
    6785:	mov    rdi,QWORD PTR [rsp-0x18]
    678a:	mov    rcx,0xffffffffffffffff
    6791:	inc    rcx
    6794:	mov    rsi,rbx
    6797:	imul   rsi,rcx
    679b:	add    rsi,rdx
    679e:	vmovsd xmm0,QWORD PTR [rax+rsi*8]
    67a3:	vmovsd QWORD PTR [r12+rcx*8],xmm0
    67a9:	cmp    rdi,rcx
    67ac:	jne    6791 <bench_ada__run_10.isra.0+0x6c1>
    67ae:	jmp    63d4 <bench_ada__run_10.isra.0+0x304>
    67b3:	mov    r13,rbx
    67b6:	mov    r9d,DWORD PTR [rsp-0x10]
    67bb:	mov    r10,QWORD PTR [rbp+0x10]
    67bf:	mov    r11,QWORD PTR [rbp+0x18]
    67c3:	mov    ebx,DWORD PTR [rsp-0xc]
    67c7:	mov    r12,r14
    67ca:	mov    r14,rdi
    67cd:	mov    rdi,rsi
    67d0:	lea    rsi,[rax+r15*1]
    67d4:	mov    rcx,r12
    67d7:	xor    edx,edx
    67d9:	nop    WORD PTR [rax+rax*1+0x0]
    67df:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    67ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    67f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6800:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    6805:	add    rcx,0x10
    6809:	vmovsd QWORD PTR [rcx-0x10],xmm0
    680e:	vmovsd xmm0,QWORD PTR [rsi+rdx*8]
    6813:	inc    rdx
    6816:	vmovsd QWORD PTR [rcx-0x8],xmm0
    681b:	cmp    r13,rdx
    681e:	jne    6800 <bench_ada__run_10.isra.0+0x730>
    6820:	cmp    ebx,r9d
    6823:	je     61bd <bench_ada__run_10.isra.0+0xed>
    6829:	inc    r9d
    682c:	jmp    67d4 <bench_ada__run_10.isra.0+0x704>
    682e:	mov    r12,r14
    6831:	mov    r14,rdi
    6834:	mov    rdi,rsi
    6837:	lea    rsi,[rax+r15*1]
    683b:	lea    r10,[rsi+r15*1]
    683f:	mov    r13,rbx
    6842:	mov    r11d,DWORD PTR [rsp-0x10]
    6847:	mov    rbx,QWORD PTR [rbp+0x10]
    684b:	lea    r9,[r15+r10*1]
    684f:	mov    r15,QWORD PTR [rbp+0x18]
    6853:	mov    rcx,r12
    6856:	xor    edx,edx
    6858:	nop    DWORD PTR [rax+rax*1+0x0]
    6860:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    6865:	add    rcx,0x20
    6869:	vmovsd QWORD PTR [rcx-0x20],xmm0
    686e:	vmovsd xmm0,QWORD PTR [rsi+rdx*8]
    6873:	vmovsd QWORD PTR [rcx-0x18],xmm0
    6878:	vmovsd xmm0,QWORD PTR [r10+rdx*8]
    687e:	vmovsd QWORD PTR [rcx-0x10],xmm0
    6883:	vmovsd xmm0,QWORD PTR [r9+rdx*8]
    6889:	inc    rdx
    688c:	vmovsd QWORD PTR [rcx-0x8],xmm0
    6891:	cmp    r13,rdx
    6894:	jne    6860 <bench_ada__run_10.isra.0+0x790>
    6896:	cmp    DWORD PTR [rsp-0xc],r11d
    689b:	je     61bd <bench_ada__run_10.isra.0+0xed>
    68a1:	inc    r11d
    68a4:	jmp    6853 <bench_ada__run_10.isra.0+0x783>
    68a6:	lea    rcx,[rbx-0x8]
    68aa:	lea    rdx,[r14-0x8]
    68ae:	mov    QWORD PTR [rsp-0x28],rbx
    68b3:	mov    QWORD PTR [rsp-0x50],r15
    68b8:	sub    rdx,rax
    68bb:	mov    r13,QWORD PTR [rbp+0x10]
    68bf:	mov    r12,QWORD PTR [rbp+0x18]
    68c3:	mov    ebx,DWORD PTR [rsp-0x10]
    68c7:	mov    QWORD PTR [rsp-0x48],rdx
    68cc:	mov    r9,r14
    68cf:	sub    r9,rax
    68d2:	shr    rcx,0x3
    68d6:	inc    rcx
    68d9:	lea    rdx,[rcx*8+0x0]
    68e1:	mov    QWORD PTR [rsp-0x40],rdx
    68e6:	cmp    QWORD PTR [rsp-0x48],0x30
    68ec:	jbe    69e5 <bench_ada__run_10.isra.0+0x915>
    68f2:	mov    rdx,rax
    68f5:	xor    r10d,r10d
    68f8:	cmp    QWORD PTR [rsp-0x30],0x6
    68fe:	jbe    6a17 <bench_ada__run_10.isra.0+0x947>
    6904:	nop    WORD PTR [rax+rax*1+0x0]
    690a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6915:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6920:	vmovupd zmm0,ZMMWORD PTR [rdx]
    6926:	inc    r10
    6929:	vmovupd ZMMWORD PTR [r9+rdx*1],zmm0
    6930:	add    rdx,0x40
    6934:	cmp    r10,rcx
    6937:	jb     6920 <bench_ada__run_10.isra.0+0x850>
    6939:	mov    r11,QWORD PTR [rsp-0x40]
    693e:	mov    rdx,r11
    6941:	cmp    r11,QWORD PTR [rsp-0x28]
    6946:	je     619f <bench_ada__run_10.isra.0+0xcf>
    694c:	vmovdqa xmm3,XMMWORD PTR [rip+0x3131c]        # 37c70 <system__secondary_stack__invalid_memory_size+0xa8>
    6954:	mov    r10,QWORD PTR [rsp-0x28]
    6959:	mov    r15d,0x8
    695f:	xor    r11d,r11d
    6962:	sub    r10,rdx
    6965:	cmp    r15,r10
    6968:	mov    r15d,0x0
    696e:	sbb    r15,r11
    6971:	mov    r15d,0x8
    6977:	cmovb  r10,r15
    697b:	vpbroadcastw xmm0,r10d
    6981:	vpcmpnleuw k1,xmm0,xmm3
    6988:	vmovupd zmm0{k1}{z},ZMMWORD PTR [rax+rdx*8]
    698f:	vmovupd ZMMWORD PTR [r14+rdx*8]{k1},zmm0
    6996:	cmp    DWORD PTR [rsp-0xc],ebx
    699a:	je     61bd <bench_ada__run_10.isra.0+0xed>
    69a0:	inc    ebx
    69a2:	jmp    68e6 <bench_ada__run_10.isra.0+0x816>
    69a7:	nop    WORD PTR [rax+rax*1+0x0]
    69b0:	mov    rcx,QWORD PTR [rbp+0x10]
    69b4:	mov    rsi,QWORD PTR [rbp+0x18]
    69b8:	mov    r9d,DWORD PTR [rsp-0xc]
    69bd:	mov    edx,0x1
    69c2:	cmp    r9d,edx
    69c5:	je     61c0 <bench_ada__run_10.isra.0+0xf0>
    69cb:	lea    r10d,[rdx+0x1]
    69cf:	cmp    r9d,r10d
    69d2:	je     61c0 <bench_ada__run_10.isra.0+0xf0>
    69d8:	add    edx,0x2
    69db:	cmp    r9d,edx
    69de:	jne    69cb <bench_ada__run_10.isra.0+0x8fb>
    69e0:	jmp    61c0 <bench_ada__run_10.isra.0+0xf0>
    69e5:	mov    DWORD PTR [rsp-0x10],ebx
    69e9:	mov    r15,QWORD PTR [rsp-0x50]
    69ee:	mov    rbx,QWORD PTR [rsp-0x28]
    69f3:	mov    rcx,QWORD PTR [rsp-0x30]
    69f8:	mov    rdx,0xffffffffffffffff
    69ff:	inc    rdx
    6a02:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    6a07:	vmovsd QWORD PTR [r14+rdx*8],xmm0
    6a0d:	cmp    rdx,rcx
    6a10:	jne    69ff <bench_ada__run_10.isra.0+0x92f>
    6a12:	jmp    650b <bench_ada__run_10.isra.0+0x43b>
    6a17:	mov    r10,QWORD PTR [rsp-0x28]
    6a1c:	vmovdqa xmm3,XMMWORD PTR [rip+0x3124c]        # 37c70 <system__secondary_stack__invalid_memory_size+0xa8>
    6a24:	mov    r15d,0x8
    6a2a:	xor    r11d,r11d
    6a2d:	xor    edx,edx
    6a2f:	cmp    r15,r10
    6a32:	sbb    rdx,r11
    6a35:	cmovb  r10,r15
    6a39:	vpbroadcastw xmm0,r10d
    6a3f:	vpcmpnleuw k1,xmm0,xmm3
    6a46:	vmovupd zmm0{k1}{z},ZMMWORD PTR [rax]
    6a4c:	vmovupd ZMMWORD PTR [r14]{k1},zmm0
    6a52:	cmp    DWORD PTR [rsp-0xc],ebx
    6a56:	je     61bd <bench_ada__run_10.isra.0+0xed>
    6a5c:	inc    ebx
    6a5e:	xor    edx,edx
    6a60:	jmp    6954 <bench_ada__run_10.isra.0+0x884>
    6a65:	mov    r10,QWORD PTR [rsp]
    6a69:	mov    r12,r14
    6a6c:	mov    r14,rdi
    6a6f:	mov    rdi,rsi
    6a72:	mov    r13,rbx
    6a75:	mov    rbx,r15
    6a78:	mov    QWORD PTR [rsp-0x18],rdi
    6a7d:	mov    QWORD PTR [rsp-0x20],r8
    6a82:	mov    QWORD PTR [rbp+0x28],r14
    6a86:	lea    rsi,[r10*8+0x0]
    6a8e:	lea    rdx,[r10-0x1]
    6a92:	vmovq  xmm1,rsi
    6a97:	mov    rsi,r15
    6a9a:	shr    rsi,0x3
    6a9e:	vmovq  r14,xmm1
    6aa3:	imul   rdx,rsi
    6aa7:	mov    r15,r10
    6aaa:	shr    r15,1
    6aad:	lea    rcx,[rdx*8+0x0]
    6ab5:	mov    QWORD PTR [rsp-0x28],rsi
    6aba:	mov    QWORD PTR [rsp],rcx
    6abe:	vmovq  rcx,xmm1
    6ac3:	sub    rcx,0x8
    6ac7:	mov    r11,rcx
    6aca:	lea    rcx,[r15+r15*1]
    6ace:	mov    QWORD PTR [rsp-0x8],rcx
    6ad3:	imul   rsi,rcx
    6ad7:	vmovq  xmm3,rsi
    6adc:	mov    rcx,rax
    6adf:	mov    rsi,rax
    6ae2:	mov    r9,r12
    6ae5:	xor    eax,eax
    6ae7:	nop    WORD PTR [rax+rax*1+0x0]
    6af0:	lea    rdx,[r11+r9*1]
    6af4:	cmp    rdx,rcx
    6af7:	jb     6b0a <bench_ada__run_10.isra.0+0xa3a>
    6af9:	mov    rdi,QWORD PTR [rsp]
    6afd:	lea    rdx,[rdi+rcx*1]
    6b01:	cmp    rdx,r9
    6b04:	jae    6ba6 <bench_ada__run_10.isra.0+0xad6>
    6b0a:	mov    rdx,rcx
    6b0d:	mov    r8,r9
    6b10:	xor    edi,edi
    6b12:	vmovsd xmm0,QWORD PTR [rdx]
    6b16:	vmovhpd xmm0,xmm0,QWORD PTR [rbx+rdx*1]
    6b1b:	inc    rdi
    6b1e:	add    r8,0x10
    6b22:	lea    rdx,[rdx+rbx*2]
    6b26:	vmovupd XMMWORD PTR [r8-0x10],xmm0
    6b2c:	cmp    rdi,r15
    6b2f:	jb     6b12 <bench_ada__run_10.isra.0+0xa42>
    6b31:	mov    r8,QWORD PTR [rsp-0x8]
    6b36:	cmp    r8,r10
    6b39:	je     6b59 <bench_ada__run_10.isra.0+0xa89>
    6b3b:	vmovq  rdi,xmm3
    6b40:	lea    rdx,[rdi+rax*1]
    6b44:	vmovsd xmm0,QWORD PTR [rsi+rdx*8]
    6b49:	mov    rdx,r10
    6b4c:	imul   rdx,rax
    6b50:	add    rdx,r8
    6b53:	vmovsd QWORD PTR [r12+rdx*8],xmm0
    6b59:	inc    rax
    6b5c:	add    r9,r14
    6b5f:	add    rcx,0x8
    6b63:	cmp    rax,r13
    6b66:	jne    6af0 <bench_ada__run_10.isra.0+0xa20>
    6b68:	mov    rax,rsi
    6b6b:	mov    rdi,QWORD PTR [rsp-0x18]
    6b70:	mov    rcx,QWORD PTR [rsp-0x20]
    6b75:	mov    rsi,QWORD PTR [rbp+0x10]
    6b79:	mov    rdx,QWORD PTR [rbp+0x18]
    6b7d:	mov    r9,QWORD PTR [rbp+0x28]
    6b81:	mov    esi,DWORD PTR [rsp-0x10]
    6b85:	cmp    DWORD PTR [rsp-0xc],esi
    6b89:	je     61bd <bench_ada__run_10.isra.0+0xed>
    6b8f:	inc    esi
    6b91:	mov    rdx,QWORD PTR [rbp+0x18]
    6b95:	mov    r9,QWORD PTR [rbp+0x28]
    6b99:	mov    DWORD PTR [rsp-0x10],esi
    6b9d:	mov    rsi,QWORD PTR [rbp+0x10]
    6ba1:	jmp    6adc <bench_ada__run_10.isra.0+0xa0c>
    6ba6:	mov    r8,QWORD PTR [rsp-0x28]
    6bab:	xor    edx,edx
    6bad:	nop    DWORD PTR [rax+rax*1+0x0]
    6bb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6bc0:	mov    rdi,r8
    6bc3:	imul   rdi,rdx
    6bc7:	add    rdi,rax
    6bca:	vmovsd xmm0,QWORD PTR [rsi+rdi*8]
    6bcf:	vmovsd QWORD PTR [r9+rdx*8],xmm0
    6bd5:	inc    rdx
    6bd8:	cmp    r10,rdx
    6bdb:	jne    6bc0 <bench_ada__run_10.isra.0+0xaf0>
    6bdd:	jmp    6b59 <bench_ada__run_10.isra.0+0xa89>
    6be2:	nop    DWORD PTR [rax]
    6be5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_11.isra.0>:
    6bf0:	test   esi,esi
    6bf2:	je     6cb3 <bench_ada__run_11.isra.0+0xc3>
    6bf8:	push   r15
    6bfa:	push   r14
    6bfc:	push   r13
    6bfe:	push   r12
    6c00:	push   rbp
    6c01:	push   rbx
    6c02:	mov    r12,rcx
    6c05:	mov    r13,r8
    6c08:	sub    rsp,0x38
    6c0c:	lea    ebx,[rdi-0x1]
    6c0f:	xor    r15d,r15d
    6c12:	mov    r14,rdx
    6c15:	mov    DWORD PTR [rsp+0xc],esi
    6c19:	mov    QWORD PTR [rsp],r9
    6c1d:	mov    rbp,QWORD PTR [rsp+0x78]
    6c22:	lea    rax,[rsp+0x20]
    6c27:	vmovq  xmm2,rax
    6c2c:	nop    DWORD PTR [rax+0x0]
    6c30:	mov    rax,QWORD PTR [rsp]
    6c34:	mov    rcx,QWORD PTR [rsp+0x70]
    6c39:	mov    rdi,QWORD PTR [rsp+0x80]
    6c41:	inc    r15d
    6c44:	lea    rax,[rsp+0x10]
    6c49:	vmovq  rcx,xmm2
    6c4e:	mov    rdi,rbp
    6c51:	mov    rdx,r14
    6c54:	mov    rsi,rax
    6c57:	mov    DWORD PTR [rsp+0x20],0x0
    6c5f:	mov    DWORD PTR [rsp+0x24],ebx
    6c63:	mov    DWORD PTR [rsp+0x28],0x0
    6c6b:	mov    DWORD PTR [rsp+0x2c],ebx
    6c6f:	mov    DWORD PTR [rsp+0x10],0x0
    6c77:	mov    DWORD PTR [rsp+0x14],ebx
    6c7b:	mov    DWORD PTR [rsp+0x18],0x0
    6c83:	mov    DWORD PTR [rsp+0x1c],ebx
    6c87:	call   4d60 <mj__matrices__symmetrize>
    6c8c:	mov    rax,QWORD PTR [rsp]
    6c90:	mov    rdi,QWORD PTR [rsp+0x70]
    6c95:	mov    rcx,QWORD PTR [rsp+0x80]
    6c9d:	cmp    DWORD PTR [rsp+0xc],r15d
    6ca2:	jne    6c30 <bench_ada__run_11.isra.0+0x40>
    6ca4:	add    rsp,0x38
    6ca8:	pop    rbx
    6ca9:	pop    rbp
    6caa:	pop    r12
    6cac:	pop    r13
    6cae:	pop    r14
    6cb0:	pop    r15
    6cb2:	ret
    6cb3:	ret
    6cb4:	nop
    6cb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_12.isra.0>:
    af50:	sub    rsp,0x48
    af54:	mov    QWORD PTR [rsp+0x18],rbx
    af59:	mov    QWORD PTR [rsp+0x38],r14
    af5e:	mov    QWORD PTR [rsp+0x40],r15
    af63:	mov    ebx,edi
    af65:	mov    r14,rcx
    af68:	mov    r15,r8
    af6b:	mov    rcx,QWORD PTR [rsp+0x50]
    af70:	mov    rdi,QWORD PTR [rsp+0x58]
    af75:	mov    r8,QWORD PTR [rsp+0x60]
    af7a:	test   esi,esi
    af7c:	je     b035 <bench_ada__run_12.isra.0+0xe5>
    af82:	mov    QWORD PTR [rsp+0x28],r12
    af87:	mov    QWORD PTR [rsp+0x30],r13
    af8c:	mov    r12,rdx
    af8f:	mov    r13,r9
    af92:	test   ebx,ebx
    af94:	je     b049 <bench_ada__run_12.isra.0+0xf9>
    af9a:	lea    rax,[rbx*8+0x0]
    afa2:	mov    DWORD PTR [rsp+0xc],esi
    afa6:	mov    rsi,rbx
    afa9:	mov    DWORD PTR [rsp+0x8],0x1
    afb1:	mov    QWORD PTR [rsp+0x20],rbp
    afb6:	imul   rsi,rax
    afba:	shr    rax,0x3
    afbe:	mov    QWORD PTR [rsp],rsi
    afc2:	lea    rbp,[rax+0x1]
    afc6:	mov    rdx,QWORD PTR [rsp]
    afca:	xor    esi,esi
    afcc:	mov    QWORD PTR [rsp+0x60],r8
    afd1:	mov    QWORD PTR [rsp+0x50],rcx
    afd6:	call   2bd0 <memset@plt>
    afdb:	vmovsd xmm0,QWORD PTR [rip+0x2cba5]        # 37b88 <system__os_lib__standin+0x3c>
    afe3:	mov    r8,QWORD PTR [rsp+0x60]
    afe8:	mov    rcx,QWORD PTR [rsp+0x50]
    afed:	mov    rdi,rax
    aff0:	xor    eax,eax
    aff2:	nop    DWORD PTR [rax]
    aff5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b000:	mov    rdx,rbp
    b003:	imul   rdx,rax
    b007:	inc    rax
    b00a:	vmovsd QWORD PTR [rdi+rdx*8],xmm0
    b00f:	cmp    rax,rbx
    b012:	jne    b000 <bench_ada__run_12.isra.0+0xb0>
    b014:	mov    eax,DWORD PTR [rsp+0x8]
    b018:	cmp    DWORD PTR [rsp+0xc],eax
    b01c:	je     b026 <bench_ada__run_12.isra.0+0xd6>
    b01e:	inc    eax
    b020:	mov    DWORD PTR [rsp+0x8],eax
    b024:	jmp    afc6 <bench_ada__run_12.isra.0+0x76>
    b026:	mov    rbp,QWORD PTR [rsp+0x20]
    b02b:	mov    r12,QWORD PTR [rsp+0x28]
    b030:	mov    r13,QWORD PTR [rsp+0x30]
    b035:	mov    rbx,QWORD PTR [rsp+0x18]
    b03a:	mov    r14,QWORD PTR [rsp+0x38]
    b03f:	mov    r15,QWORD PTR [rsp+0x40]
    b044:	add    rsp,0x48
    b048:	ret
    b049:	mov    eax,0x1
    b04e:	cmp    esi,eax
    b050:	je     b02b <bench_ada__run_12.isra.0+0xdb>
    b052:	lea    edx,[rax+0x1]
    b055:	cmp    esi,edx
    b057:	je     b02b <bench_ada__run_12.isra.0+0xdb>
    b059:	add    eax,0x2
    b05c:	cmp    esi,eax
    b05e:	jne    b052 <bench_ada__run_12.isra.0+0x102>
    b060:	jmp    b02b <bench_ada__run_12.isra.0+0xdb>
    b062:	nop    DWORD PTR [rax]
    b065:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_13.isra.0>:
    6cc0:	sub    rsp,0x88
    6cc7:	mov    QWORD PTR [rsp+0x78],r14
    6ccc:	mov    QWORD PTR [rsp+0x80],r15
    6cd4:	mov    QWORD PTR [rsp+0x8],r8
    6cd9:	mov    QWORD PTR [rsp+0x10],r9
    6cde:	mov    r14,QWORD PTR [rsp+0xa0]
    6ce6:	mov    r15,QWORD PTR [rsp+0xa8]
    6cee:	test   edx,edx
    6cf0:	je     6df0 <bench_ada__run_13.isra.0+0x130>
    6cf6:	mov    eax,edi
    6cf8:	mov    DWORD PTR [rsp+0x1c],edx
    6cfc:	mov    QWORD PTR [rsp+0x58],rbx
    6d01:	mov    QWORD PTR [rsp+0x60],rbp
    6d06:	mov    QWORD PTR [rsp+0x68],r12
    6d0b:	mov    QWORD PTR [rsp+0x70],r13
    6d10:	lea    ebp,[rsi-0x1]
    6d13:	lea    ebx,[rdi-0x1]
    6d16:	xor    r12d,r12d
    6d19:	mov    r13,rcx
    6d1c:	sar    eax,1
    6d1e:	dec    eax
    6d20:	mov    DWORD PTR [rsp+0x18],eax
    6d24:	lea    rax,[rsp+0x40]
    6d29:	vmovq  xmm17,rax
    6d2f:	nop
    6d30:	mov    rax,QWORD PTR [rsp+0x8]
    6d35:	mov    rcx,QWORD PTR [rsp+0x10]
    6d3a:	mov    rdi,QWORD PTR [rsp+0x90]
    6d42:	mov    rsi,QWORD PTR [rsp+0x98]
    6d4a:	inc    r12d
    6d4d:	mov    edi,DWORD PTR [rsp+0x18]
    6d51:	lea    rdx,[rsp+0x28]
    6d56:	vmovq  rsi,xmm17
    6d5c:	mov    r8,r15
    6d5f:	mov    r9,rdx
    6d62:	mov    rcx,rsi
    6d65:	mov    rdx,r13
    6d68:	mov    DWORD PTR [rsp+0x28],0x0
    6d70:	mov    DWORD PTR [rsp+0x40],0x0
    6d78:	mov    DWORD PTR [rsp+0x44],ebx
    6d7c:	mov    DWORD PTR [rsp+0x48],0x0
    6d84:	mov    DWORD PTR [rsp+0x4c],ebp
    6d88:	mov    DWORD PTR [rsp+0x30],0x0
    6d90:	mov    DWORD PTR [rsp+0x34],ebx
    6d94:	mov    DWORD PTR [rsp+0x38],0x0
    6d9c:	mov    DWORD PTR [rsp+0x3c],ebp
    6da0:	mov    DWORD PTR [rsp+0x2c],edi
    6da4:	lea    rdi,[rsp+0x30]
    6da9:	mov    r11,rdi
    6dac:	mov    rdi,r14
    6daf:	mov    rsi,r11
    6db2:	call   5630 <mj__matrices__copyrows>
    6db7:	mov    rax,QWORD PTR [rsp+0x8]
    6dbc:	mov    rcx,QWORD PTR [rsp+0x10]
    6dc1:	mov    rdx,QWORD PTR [rsp+0x90]
    6dc9:	mov    rsi,QWORD PTR [rsp+0x98]
    6dd1:	cmp    DWORD PTR [rsp+0x1c],r12d
    6dd6:	jne    6d30 <bench_ada__run_13.isra.0+0x70>
    6ddc:	mov    rbx,QWORD PTR [rsp+0x58]
    6de1:	mov    rbp,QWORD PTR [rsp+0x60]
    6de6:	mov    r12,QWORD PTR [rsp+0x68]
    6deb:	mov    r13,QWORD PTR [rsp+0x70]
    6df0:	mov    r14,QWORD PTR [rsp+0x78]
    6df5:	mov    r15,QWORD PTR [rsp+0x80]
    6dfd:	add    rsp,0x88
    6e04:	ret
    6e05:	nop
    6e06:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_14.isra.0>:
    a740:	sub    rsp,0x78
    a744:	mov    QWORD PTR [rsp+0x60],r13
    a749:	mov    r13,QWORD PTR [rsp+0x98]
    a751:	test   ecx,ecx
    a753:	je     a86d <bench_ada__run_14.isra.0+0x12d>
    a759:	lea    eax,[rdx-0x1]
    a75c:	mov    DWORD PTR [rsp+0xc],ecx
    a760:	mov    QWORD PTR [rsp+0x48],rbx
    a765:	mov    QWORD PTR [rsp+0x50],rbp
    a76a:	mov    DWORD PTR [rsp+0x8],eax
    a76e:	mov    QWORD PTR [rsp+0x58],r12
    a773:	mov    QWORD PTR [rsp+0x68],r14
    a778:	mov    QWORD PTR [rsp+0x70],r15
    a77d:	mov    rbx,r8
    a780:	mov    rbp,r9
    a783:	lea    r14d,[rdi-0x1]
    a787:	lea    r15d,[rsi-0x1]
    a78b:	xor    r12d,r12d
    a78e:	xchg   ax,ax
    a790:	mov    rax,QWORD PTR [rsp+0x80]
    a798:	mov    rcx,QWORD PTR [rsp+0x88]
    a7a0:	mov    rsi,QWORD PTR [rsp+0x90]
    a7a8:	mov    rdi,QWORD PTR [rsp+0xa0]
    a7b0:	inc    r12d
    a7b3:	mov    eax,DWORD PTR [rsp+0x8]
    a7b7:	lea    rcx,[rsp+0x30]
    a7bc:	mov    rdx,rbx
    a7bf:	mov    rdi,r13
    a7c2:	mov    r11,rcx
    a7c5:	mov    r8,rbp
    a7c8:	lea    rcx,[rsp+0x20]
    a7cd:	mov    DWORD PTR [rsp+0x30],0x0
    a7d5:	mov    r9,r11
    a7d8:	mov    DWORD PTR [rsp+0x34],r15d
    a7dd:	mov    DWORD PTR [rsp+0x38],0x0
    a7e5:	mov    DWORD PTR [rsp+0x20],0x0
    a7ed:	mov    DWORD PTR [rsp+0x24],r14d
    a7f2:	mov    DWORD PTR [rsp+0x28],0x0
    a7fa:	mov    DWORD PTR [rsp+0x2c],r15d
    a7ff:	mov    DWORD PTR [rsp+0x10],0x0
    a807:	mov    DWORD PTR [rsp+0x14],r14d
    a80c:	mov    DWORD PTR [rsp+0x18],0x0
    a814:	mov    DWORD PTR [rsp+0x3c],eax
    a818:	mov    DWORD PTR [rsp+0x1c],eax
    a81c:	lea    rax,[rsp+0x10]
    a821:	mov    rsi,rax
    a824:	call   a1b0 <mj__matrices__mulmatmat>
    a829:	mov    rax,QWORD PTR [rsp+0x80]
    a831:	mov    rdx,QWORD PTR [rsp+0x88]
    a839:	mov    rsi,QWORD PTR [rsp+0x90]
    a841:	mov    rdi,QWORD PTR [rsp+0xa0]
    a849:	cmp    DWORD PTR [rsp+0xc],r12d
    a84e:	jne    a790 <bench_ada__run_14.isra.0+0x50>
    a854:	mov    rbx,QWORD PTR [rsp+0x48]
    a859:	mov    rbp,QWORD PTR [rsp+0x50]
    a85e:	mov    r12,QWORD PTR [rsp+0x58]
    a863:	mov    r14,QWORD PTR [rsp+0x68]
    a868:	mov    r15,QWORD PTR [rsp+0x70]
    a86d:	mov    r13,QWORD PTR [rsp+0x60]
    a872:	add    rsp,0x78
    a876:	ret
    a877:	nop
    a878:	nop    DWORD PTR [rax+rax*1+0x0]


<bench_ada__run_15.isra.0>:
    ae10:	sub    rsp,0x78
    ae14:	mov    QWORD PTR [rsp+0x60],r13
    ae19:	mov    r13,QWORD PTR [rsp+0x98]
    ae21:	test   ecx,ecx
    ae23:	je     af3d <bench_ada__run_15.isra.0+0x12d>
    ae29:	lea    eax,[rdx-0x1]
    ae2c:	mov    DWORD PTR [rsp+0xc],ecx
    ae30:	mov    QWORD PTR [rsp+0x48],rbx
    ae35:	mov    QWORD PTR [rsp+0x50],rbp
    ae3a:	mov    DWORD PTR [rsp+0x8],eax
    ae3e:	mov    QWORD PTR [rsp+0x58],r12
    ae43:	mov    QWORD PTR [rsp+0x68],r14
    ae48:	mov    QWORD PTR [rsp+0x70],r15
    ae4d:	mov    rbx,r8
    ae50:	mov    rbp,r9
    ae53:	lea    r14d,[rdi-0x1]
    ae57:	lea    r15d,[rsi-0x1]
    ae5b:	xor    r12d,r12d
    ae5e:	xchg   ax,ax
    ae60:	mov    rax,QWORD PTR [rsp+0x80]
    ae68:	mov    rcx,QWORD PTR [rsp+0x88]
    ae70:	mov    rsi,QWORD PTR [rsp+0x90]
    ae78:	mov    rdi,QWORD PTR [rsp+0xa0]
    ae80:	inc    r12d
    ae83:	mov    eax,DWORD PTR [rsp+0x8]
    ae87:	lea    rcx,[rsp+0x30]
    ae8c:	mov    rdx,rbx
    ae8f:	mov    rdi,r13
    ae92:	mov    r11,rcx
    ae95:	mov    r8,rbp
    ae98:	lea    rcx,[rsp+0x20]
    ae9d:	mov    DWORD PTR [rsp+0x30],0x0
    aea5:	mov    r9,r11
    aea8:	mov    DWORD PTR [rsp+0x34],r14d
    aead:	mov    DWORD PTR [rsp+0x38],0x0
    aeb5:	mov    DWORD PTR [rsp+0x20],0x0
    aebd:	mov    DWORD PTR [rsp+0x24],r14d
    aec2:	mov    DWORD PTR [rsp+0x28],0x0
    aeca:	mov    DWORD PTR [rsp+0x2c],r15d
    aecf:	mov    DWORD PTR [rsp+0x10],0x0
    aed7:	mov    DWORD PTR [rsp+0x14],r15d
    aedc:	mov    DWORD PTR [rsp+0x18],0x0
    aee4:	mov    DWORD PTR [rsp+0x3c],eax
    aee8:	mov    DWORD PTR [rsp+0x1c],eax
    aeec:	lea    rax,[rsp+0x10]
    aef1:	mov    rsi,rax
    aef4:	call   a880 <mj__matrices__mulmattmat>
    aef9:	mov    rax,QWORD PTR [rsp+0x80]
    af01:	mov    rdx,QWORD PTR [rsp+0x88]
    af09:	mov    rsi,QWORD PTR [rsp+0x90]
    af11:	mov    rdi,QWORD PTR [rsp+0xa0]
    af19:	cmp    DWORD PTR [rsp+0xc],r12d
    af1e:	jne    ae60 <bench_ada__run_15.isra.0+0x50>
    af24:	mov    rbx,QWORD PTR [rsp+0x48]
    af29:	mov    rbp,QWORD PTR [rsp+0x50]
    af2e:	mov    r12,QWORD PTR [rsp+0x58]
    af33:	mov    r14,QWORD PTR [rsp+0x68]
    af38:	mov    r15,QWORD PTR [rsp+0x70]
    af3d:	mov    r13,QWORD PTR [rsp+0x60]
    af42:	add    rsp,0x78
    af46:	ret
    af47:	nop
    af48:	nop    DWORD PTR [rax+rax*1+0x0]


<bench_ada__run_16.isra.0>:
    6e10:	push   rbp
    6e11:	mov    rbp,rsp
    6e14:	push   r15
    6e16:	push   r14
    6e18:	push   r13
    6e1a:	push   r12
    6e1c:	push   rbx
    6e1d:	mov    rbx,r9
    6e20:	and    rsp,0xffffffffffffffe0
    6e24:	add    rsp,0xffffffffffffff80
    6e28:	mov    r9,QWORD PTR [rbp+0x30]
    6e2c:	test   ecx,ecx
    6e2e:	je     6fe9 <bench_ada__run_16.isra.0+0x1d9>
    6e34:	mov    eax,edx
    6e36:	mov    r11d,edi
    6e39:	mov    DWORD PTR [rsp+0x50],ecx
    6e3d:	lea    ecx,[rdi-0x1]
    6e40:	mov    DWORD PTR [rsp+0x54],ecx
    6e44:	mov    QWORD PTR [rsp+0x38],rax
    6e49:	lea    rcx,[rax*8+0x0]
    6e51:	mov    eax,r11d
    6e54:	mov    r14,QWORD PTR [rbp+0x28]
    6e58:	mov    QWORD PTR [rsp+0x18],rax
    6e5d:	mov    QWORD PTR [rsp+0x48],rcx
    6e62:	mov    DWORD PTR [rsp+0x30],esi
    6e66:	mov    DWORD PTR [rsp+0x34],edi
    6e6a:	lea    r12d,[rsi-0x1]
    6e6e:	lea    edi,[rdx-0x1]
    6e71:	mov    r15,r8
    6e74:	xor    esi,esi
    6e76:	cs nop WORD PTR [rax+rax*1+0x0]
    6e80:	mov    rax,QWORD PTR [rbp+0x10]
    6e84:	mov    rcx,QWORD PTR [rbp+0x18]
    6e88:	mov    rdx,QWORD PTR [rbp+0x20]
    6e8c:	inc    esi
    6e8e:	mov    eax,DWORD PTR [rsp+0x54]
    6e92:	mov    DWORD PTR [rsp+0x70],0x0
    6e9a:	mov    DWORD PTR [rsp+0x74],edi
    6e9e:	mov    DWORD PTR [rsp+0x78],0x0
    6ea6:	mov    DWORD PTR [rsp+0x7c],r12d
    6eab:	mov    DWORD PTR [rsp+0x60],0x0
    6eb3:	mov    DWORD PTR [rsp+0x68],0x0
    6ebb:	mov    DWORD PTR [rsp+0x6c],r12d
    6ec0:	mov    DWORD PTR [rsp+0x64],eax
    6ec4:	cmp    edi,0xffffffff
    6ec7:	je     6fd0 <bench_ada__run_16.isra.0+0x1c0>
    6ecd:	cmp    eax,0xffffffff
    6ed0:	je     6fd0 <bench_ada__run_16.isra.0+0x1c0>
    6ed6:	cmp    r12d,0xffffffff
    6eda:	je     6ff8 <bench_ada__run_16.isra.0+0x1e8>
    6ee0:	mov    eax,DWORD PTR [rsp+0x30]
    6ee4:	cmp    eax,0x3
    6ee7:	je     726d <bench_ada__run_16.isra.0+0x45d>
    6eed:	jg     7064 <bench_ada__run_16.isra.0+0x254>
    6ef3:	dec    eax
    6ef5:	je     71ee <bench_ada__run_16.isra.0+0x3de>
    6efb:	mov    eax,DWORD PTR [rsp+0x34]
    6eff:	mov    QWORD PTR [rbp+0x30],r9
    6f03:	mov    rcx,QWORD PTR [rsp+0x48]
    6f08:	mov    r9d,esi
    6f0b:	mov    rsi,QWORD PTR [rbp+0x30]
    6f0f:	mov    r11,r14
    6f12:	mov    r13,0xffffffffffffffff
    6f19:	vxorpd xmm2,xmm2,xmm2
    6f1d:	dec    rax
    6f20:	mov    QWORD PTR [rsp+0x58],rax
    6f25:	mov    rax,QWORD PTR [rsp+0x38]
    6f2a:	lea    r8,[rax-0x1]
    6f2e:	inc    r13
    6f31:	mov    rdx,0xffffffffffffffff
    6f38:	movsxd r10,r13d
    6f3b:	shl    r10,0x4
    6f3f:	add    r10,r15
    6f42:	nop    DWORD PTR [rax+0x0]
    6f49:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6f54:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6f5f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6f6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6f75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6f80:	inc    rdx
    6f83:	movsxd rax,edx
    6f86:	shl    rax,0x4
    6f8a:	add    rax,rbx
    6f8d:	vmovsd xmm0,QWORD PTR [rax]
    6f91:	vmulsd xmm0,xmm0,QWORD PTR [r10]
    6f96:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6f9b:	vmulsd xmm1,xmm1,QWORD PTR [r10+0x8]
    6fa1:	vaddsd xmm0,xmm0,xmm1
    6fa5:	vaddsd xmm0,xmm0,xmm2
    6fa9:	vmovsd QWORD PTR [r11+rdx*8],xmm0
    6faf:	cmp    rdx,r8
    6fb2:	jne    6f80 <bench_ada__run_16.isra.0+0x170>
    6fb4:	add    r11,rcx
    6fb7:	cmp    r13,QWORD PTR [rsp+0x58]
    6fbc:	jne    6f2e <bench_ada__run_16.isra.0+0x11e>
    6fc2:	mov    QWORD PTR [rbp+0x30],rsi
    6fc6:	mov    esi,r9d
    6fc9:	mov    r9,QWORD PTR [rbp+0x30]
    6fcd:	nop    DWORD PTR [rax]
    6fd0:	mov    rax,QWORD PTR [rbp+0x10]
    6fd4:	mov    rcx,QWORD PTR [rbp+0x18]
    6fd8:	mov    rdx,QWORD PTR [rbp+0x20]
    6fdc:	cmp    DWORD PTR [rsp+0x50],esi
    6fe0:	jne    6e80 <bench_ada__run_16.isra.0+0x70>
    6fe6:	vzeroupper
    6fe9:	lea    rsp,[rbp-0x28]
    6fed:	pop    rbx
    6fee:	pop    r12
    6ff0:	pop    r13
    6ff2:	pop    r14
    6ff4:	pop    r15
    6ff6:	pop    rbp
    6ff7:	ret
    6ff8:	mov    DWORD PTR [rsp+0x58],r12d
    6ffd:	mov    QWORD PTR [rsp+0x20],rbx
    7002:	mov    DWORD PTR [rsp+0x40],edi
    7006:	mov    DWORD PTR [rsp+0x28],esi
    700a:	mov    QWORD PTR [rbp+0x30],r9
    700e:	xor    r12d,r12d
    7011:	mov    rbx,QWORD PTR [rsp+0x48]
    7016:	mov    r13,QWORD PTR [rsp+0x18]
    701b:	mov    r10,r14
    701e:	vzeroupper
    7021:	nop    DWORD PTR [rax+0x0]
    7025:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7030:	mov    rdi,r10
    7033:	mov    rdx,rbx
    7036:	xor    esi,esi
    7038:	inc    r12
    703b:	call   2bd0 <memset@plt>
    7040:	lea    r10,[rax+rbx*1]
    7044:	cmp    r13,r12
    7047:	jne    7030 <bench_ada__run_16.isra.0+0x220>
    7049:	mov    r12d,DWORD PTR [rsp+0x58]
    704e:	mov    edi,DWORD PTR [rsp+0x40]
    7052:	mov    esi,DWORD PTR [rsp+0x28]
    7056:	mov    rbx,QWORD PTR [rsp+0x20]
    705b:	mov    r9,QWORD PTR [rbp+0x30]
    705f:	jmp    6fd0 <bench_ada__run_16.isra.0+0x1c0>
    7064:	cmp    DWORD PTR [rsp+0x30],0x4
    7069:	jne    710f <bench_ada__run_16.isra.0+0x2ff>
    706f:	mov    eax,DWORD PTR [rsp+0x34]
    7073:	mov    QWORD PTR [rbp+0x30],r9
    7077:	mov    rcx,QWORD PTR [rsp+0x48]
    707c:	mov    r9d,esi
    707f:	mov    rsi,QWORD PTR [rbp+0x30]
    7083:	mov    r11,r14
    7086:	xor    r13d,r13d
    7089:	mov    QWORD PTR [rsp+0x58],rax
    708e:	mov    rax,QWORD PTR [rsp+0x38]
    7093:	lea    r8,[rax-0x1]
    7097:	movsxd r10,r13d
    709a:	mov    rax,0xffffffffffffffff
    70a1:	shl    r10,0x5
    70a5:	add    r10,r15
    70a8:	xchg   ax,ax
    70aa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    70b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    70c0:	inc    rax
    70c3:	vmovupd ymm0,YMMWORD PTR [r10]
    70c8:	movsxd rdx,eax
    70cb:	shl    rdx,0x5
    70cf:	vmulpd ymm0,ymm0,YMMWORD PTR [rdx+rbx*1]
    70d4:	vextractf64x2 xmm2,ymm0,0x1
    70db:	vunpckhpd xmm1,xmm0,xmm0
    70df:	vaddsd xmm2,xmm2,xmm0
    70e3:	valignq ymm0,ymm0,ymm0,0x3
    70ea:	vaddsd xmm1,xmm1,xmm0
    70ee:	vaddsd xmm1,xmm2,xmm1
    70f2:	vmovsd QWORD PTR [r11+rax*8],xmm1
    70f8:	cmp    rax,r8
    70fb:	jne    70c0 <bench_ada__run_16.isra.0+0x2b0>
    70fd:	inc    r13
    7100:	add    r11,rcx
    7103:	cmp    QWORD PTR [rsp+0x58],r13
    7108:	jne    7097 <bench_ada__run_16.isra.0+0x287>
    710a:	jmp    6fc2 <bench_ada__run_16.isra.0+0x1b2>
    710f:	mov    eax,DWORD PTR [rsp+0x34]
    7113:	mov    rcx,QWORD PTR [rsp+0x38]
    7118:	mov    DWORD PTR [rsp+0x20],esi
    711c:	mov    QWORD PTR [rbp+0x28],r14
    7120:	mov    QWORD PTR [rbp+0x30],r9
    7124:	vmovd  xmm19,r12d
    712a:	vmovq  xmm21,QWORD PTR [rsp+0x48]
    7132:	vmovd  xmm20,edi
    7138:	mov    r12,r14
    713b:	mov    r13,rbx
    713e:	mov    QWORD PTR [rsp+0x28],rax
    7143:	lea    r8,[rcx-0x1]
    7147:	lea    rcx,[rsp+0x60]
    714c:	xor    eax,eax
    714e:	vmovq  xmm18,rcx
    7154:	lea    rcx,[rsp+0x70]
    7159:	vmovq  xmm16,r8
    715f:	vmovq  xmm17,rcx
    7165:	vzeroupper
    7168:	mov    DWORD PTR [rsp+0x58],eax
    716c:	mov    QWORD PTR [rsp+0x40],rax
    7171:	mov    rbx,0xffffffffffffffff
    7178:	vmovq  r14,xmm16
    717e:	xchg   ax,ax
    7180:	mov    r8d,DWORD PTR [rsp+0x58]
    7185:	vmovq  rax,xmm18
    718b:	inc    rbx
    718e:	mov    rdx,r13
    7191:	mov    r9,rax
    7194:	vmovq  rax,xmm17
    719a:	mov    rdi,r15
    719d:	mov    rsi,r9
    71a0:	mov    rcx,rax
    71a3:	mov    r9d,ebx
    71a6:	call   4f70 <mj__matrices__matt_component>
    71ab:	vmovsd QWORD PTR [r12+rbx*8],xmm0
    71b1:	cmp    rbx,r14
    71b4:	jne    7180 <bench_ada__run_16.isra.0+0x370>
    71b6:	mov    rax,QWORD PTR [rsp+0x40]
    71bb:	vmovq  rcx,xmm21
    71c1:	add    r12,rcx
    71c4:	inc    rax
    71c7:	cmp    QWORD PTR [rsp+0x28],rax
    71cc:	jne    7168 <bench_ada__run_16.isra.0+0x358>
    71ce:	mov    esi,DWORD PTR [rsp+0x20]
    71d2:	mov    r14,QWORD PTR [rbp+0x28]
    71d6:	mov    r9,QWORD PTR [rbp+0x30]
    71da:	vmovd  r12d,xmm19
    71e0:	vmovd  edi,xmm20
    71e6:	mov    rbx,r13
    71e9:	jmp    6fd0 <bench_ada__run_16.isra.0+0x1c0>
    71ee:	mov    eax,DWORD PTR [rsp+0x34]
    71f2:	mov    rcx,QWORD PTR [rsp+0x48]
    71f7:	mov    QWORD PTR [rbp+0x30],r9
    71fb:	mov    rdx,r14
    71fe:	mov    r10,0xffffffffffffffff
    7205:	vxorpd xmm1,xmm1,xmm1
    7209:	mov    r9d,esi
    720c:	lea    r11,[rax-0x1]
    7210:	mov    rax,QWORD PTR [rsp+0x38]
    7215:	lea    r8,[rax-0x1]
    7219:	inc    r10
    721c:	mov    rax,0xffffffffffffffff
    7223:	movsxd rsi,r10d
    7226:	nop    DWORD PTR [rax+0x0]
    722a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7235:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7240:	inc    rax
    7243:	movsxd r13,eax
    7246:	vmovsd xmm0,QWORD PTR [rbx+r13*8]
    724c:	vmulsd xmm0,xmm0,QWORD PTR [r15+rsi*8]
    7252:	vaddsd xmm0,xmm0,xmm1
    7256:	vmovsd QWORD PTR [rdx+rax*8],xmm0
    725b:	cmp    rax,r8
    725e:	jne    7240 <bench_ada__run_16.isra.0+0x430>
    7260:	add    rdx,rcx
    7263:	cmp    r10,r11
    7266:	jne    7219 <bench_ada__run_16.isra.0+0x409>
    7268:	jmp    6fc6 <bench_ada__run_16.isra.0+0x1b6>
    726d:	mov    eax,DWORD PTR [rsp+0x34]
    7271:	mov    rcx,QWORD PTR [rsp+0x48]
    7276:	mov    QWORD PTR [rbp+0x30],r9
    727a:	mov    r10,0xffffffffffffffff
    7281:	mov    r9d,esi
    7284:	vxorpd xmm2,xmm2,xmm2
    7288:	mov    rsi,r14
    728b:	lea    r11,[rax-0x1]
    728f:	mov    rax,QWORD PTR [rsp+0x38]
    7294:	lea    r8,[rax-0x1]
    7298:	inc    r10
    729b:	mov    rax,0xffffffffffffffff
    72a2:	movsxd rdx,r10d
    72a5:	lea    rdx,[rdx+rdx*2]
    72a9:	lea    rdx,[r15+rdx*8]
    72ad:	nop    DWORD PTR [rax]
    72b0:	inc    rax
    72b3:	movsxd r13,eax
    72b6:	lea    r13,[r13+r13*2+0x0]
    72bb:	lea    r13,[rbx+r13*8]
    72bf:	vmovsd xmm0,QWORD PTR [r13+0x0]
    72c5:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    72c9:	vmovsd xmm1,QWORD PTR [r13+0x8]
    72cf:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    72d4:	vaddsd xmm0,xmm0,xmm1
    72d8:	vmovsd xmm1,QWORD PTR [r13+0x10]
    72de:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    72e3:	vaddsd xmm0,xmm0,xmm1
    72e7:	vaddsd xmm0,xmm0,xmm2
    72eb:	vmovsd QWORD PTR [rsi+rax*8],xmm0
    72f0:	cmp    rax,r8
    72f3:	jne    72b0 <bench_ada__run_16.isra.0+0x4a0>
    72f5:	add    rsi,rcx
    72f8:	cmp    r10,r11
    72fb:	jne    7298 <bench_ada__run_16.isra.0+0x488>
    72fd:	jmp    6fc6 <bench_ada__run_16.isra.0+0x1b6>
    7302:	nop    DWORD PTR [rax]
    7305:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_17.isra.0>:
    b070:	push   rbp
    b071:	mov    rbp,rsp
    b074:	push   r15
    b076:	push   r14
    b078:	push   r13
    b07a:	push   r12
    b07c:	push   rbx
    b07d:	and    rsp,0xffffffffffffffc0
    b081:	add    rsp,0xffffffffffffff80
    b085:	mov    r10,QWORD PTR [rbp+0x20]
    b089:	mov    QWORD PTR [rsp+0x58],r8
    b08e:	mov    QWORD PTR [rsp+0x50],r9
    b093:	test   edx,edx
    b095:	je     b4ca <bench_ada__run_17.isra.0+0x45a>
    b09b:	mov    DWORD PTR [rsp+0x34],edi
    b09f:	dec    edi
    b0a1:	mov    rbx,rcx
    b0a4:	mov    ecx,esi
    b0a6:	mov    DWORD PTR [rsp+0x40],edi
    b0aa:	lea    edi,[rsi-0x1]
    b0ad:	mov    DWORD PTR [rsp+0x44],edx
    b0b1:	lea    rdx,[rcx*8+0x0]
    b0b9:	mov    DWORD PTR [rsp+0x48],edi
    b0bd:	mov    rdi,rcx
    b0c0:	xor    eax,eax
    b0c2:	lea    r14,[rcx-0x1]
    b0c6:	imul   rdi,rdx
    b0ca:	test   esi,esi
    b0cc:	cmovne rax,rdx
    b0d0:	mov    r12,rax
    b0d3:	xor    eax,eax
    b0d5:	mov    QWORD PTR [rsp+0x38],rdi
    b0da:	mov    DWORD PTR [rsp+0x4c],eax
    b0de:	xchg   ax,ax
    b0e0:	inc    DWORD PTR [rsp+0x4c]
    b0e4:	mov    rax,QWORD PTR [rsp+0x58]
    b0e9:	mov    rdi,QWORD PTR [rsp+0x50]
    b0ee:	mov    rdx,QWORD PTR [rbp+0x10]
    b0f2:	mov    rsi,QWORD PTR [rbp+0x18]
    b0f6:	mov    rcx,QWORD PTR [rbp+0x28]
    b0fa:	mov    eax,DWORD PTR [rsp+0x48]
    b0fe:	cmp    eax,0xffffffff
    b101:	je     b528 <bench_ada__run_17.isra.0+0x4b8>
    b107:	mov    rdx,QWORD PTR [rsp+0x38]
    b10c:	mov    rdi,r10
    b10f:	xor    esi,esi
    b111:	call   2bd0 <memset@plt>
    b116:	vxorpd xmm6,xmm6,xmm6
    b11a:	mov    r10,rax
    b11d:	mov    eax,DWORD PTR [rsp+0x40]
    b121:	cmp    eax,0xffffffff
    b124:	je     b348 <bench_ada__run_17.isra.0+0x2d8>
    b12a:	mov    eax,DWORD PTR [rsp+0x34]
    b12e:	mov    QWORD PTR [rsp+0x70],r12
    b133:	mov    r8,0xffffffffffffffff
    b13a:	vmovq  xmm3,r14
    b13f:	lea    rcx,[rax-0x1]
    b143:	mov    rax,r12
    b146:	shr    rax,0x3
    b14a:	mov    QWORD PTR [rsp+0x60],rcx
    b14f:	mov    QWORD PTR [rsp+0x78],rax
    b154:	nop
    b155:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b160:	mov    r15,QWORD PTR [rsp+0x70]
    b165:	inc    r8
    b168:	mov    r9d,0x1
    b16e:	movsxd rdx,r8d
    b171:	imul   r15,rdx
    b175:	lea    rax,[r15+rbx*1]
    b179:	mov    r15,QWORD PTR [rsp+0x78]
    b17e:	mov    QWORD PTR [rsp+0x68],rax
    b183:	vmovq  rax,xmm3
    b188:	imul   r15,rdx
    b18c:	mov    rdx,0xffffffffffffffff
    b193:	mov    r12,r15
    b196:	jmp    b1cc <bench_ada__run_17.isra.0+0x15c>
    b198:	nop    DWORD PTR [rax+0x0]
    b19f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b1aa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b1b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b1c0:	inc    r9d
    b1c3:	cmp    rdx,rax
    b1c6:	je     b330 <bench_ada__run_17.isra.0+0x2c0>
    b1cc:	inc    rdx
    b1cf:	movsxd r15,edx
    b1d2:	mov    r14d,edx
    b1d5:	lea    rcx,[r12+r15*1]
    b1d9:	vmovsd xmm1,QWORD PTR [rbx+rcx*8]
    b1de:	vbroadcastsd zmm2,xmm1
    b1e4:	test   edx,edx
    b1e6:	js     b1c0 <bench_ada__run_17.isra.0+0x150>
    b1e8:	vcomisd xmm1,xmm6
    b1ec:	je     b1c0 <bench_ada__run_17.isra.0+0x150>
    b1ee:	mov    r13d,edx
    b1f1:	cmp    edx,0x6
    b1f4:	jbe    b4e0 <bench_ada__run_17.isra.0+0x470>
    b1fa:	mov    rcx,QWORD PTR [rsp+0x70]
    b1ff:	mov    r11,QWORD PTR [rsp+0x68]
    b204:	mov    edi,r9d
    b207:	shr    edi,0x3
    b20a:	vmovapd zmm4,zmm2
    b210:	mov    esi,edi
    b212:	imul   rcx,r15
    b216:	shl    rsi,0x6
    b21a:	add    rcx,r10
    b21d:	add    rsi,rcx
    b220:	sub    r11,rcx
    b223:	nop    DWORD PTR [rax+0x0]
    b22a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b235:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b240:	vmulpd zmm0,zmm4,ZMMWORD PTR [rcx+r11*1]
    b247:	add    rcx,0x40
    b24b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rcx-0x40]
    b252:	vmovupd ZMMWORD PTR [rcx-0x40],zmm0
    b259:	cmp    rsi,rcx
    b25c:	jne    b240 <bench_ada__run_17.isra.0+0x1d0>
    b25e:	shl    edi,0x3
    b261:	cmp    r9d,edi
    b264:	je     b1c0 <bench_ada__run_17.isra.0+0x150>
    b26a:	lea    ecx,[rdi-0x1]
    b26d:	sub    r13d,edi
    b270:	cmp    r13d,0x2
    b274:	jbe    b2ab <bench_ada__run_17.isra.0+0x23b>
    b276:	mov    rsi,QWORD PTR [rsp+0x78]
    b27b:	inc    r13d
    b27e:	imul   rsi,r15
    b282:	add    rsi,rdi
    b285:	add    rdi,r12
    b288:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+rdi*8]
    b28d:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+rsi*8]
    b293:	vmovupd YMMWORD PTR [r10+rsi*8],ymm2
    b299:	mov    esi,r13d
    b29c:	and    esi,0xfffffffc
    b29f:	and    r13d,0x3
    b2a3:	je     b1c0 <bench_ada__run_17.isra.0+0x150>
    b2a9:	add    ecx,esi
    b2ab:	mov    r11,QWORD PTR [rsp+0x78]
    b2b0:	lea    esi,[rcx+0x1]
    b2b3:	mov    rdi,rsi
    b2b6:	imul   r11,r15
    b2ba:	lea    r13,[r11+rsi*1]
    b2be:	add    rsi,r12
    b2c1:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    b2c6:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    b2cc:	vmovsd QWORD PTR [r10+r13*8],xmm0
    b2d2:	cmp    edi,r14d
    b2d5:	je     b1c0 <bench_ada__run_17.isra.0+0x150>
    b2db:	lea    esi,[rcx+0x2]
    b2de:	lea    r13,[r11+rsi*1]
    b2e2:	mov    rdi,rsi
    b2e5:	add    rsi,r12
    b2e8:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    b2ed:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    b2f3:	vmovsd QWORD PTR [r10+r13*8],xmm0
    b2f9:	cmp    r14d,edi
    b2fc:	je     b1c0 <bench_ada__run_17.isra.0+0x150>
    b302:	add    ecx,0x3
    b305:	inc    r9d
    b308:	lea    r15,[r11+rcx*1]
    b30c:	add    rcx,r12
    b30f:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    b314:	vaddsd xmm1,xmm1,QWORD PTR [r10+r15*8]
    b31a:	vmovsd QWORD PTR [r10+r15*8],xmm1
    b320:	cmp    rdx,rax
    b323:	jne    b1cc <bench_ada__run_17.isra.0+0x15c>
    b329:	nop    DWORD PTR [rax+0x0]
    b330:	cmp    r8,QWORD PTR [rsp+0x60]
    b335:	jne    b160 <bench_ada__run_17.isra.0+0xf0>
    b33b:	mov    r12,QWORD PTR [rsp+0x70]
    b340:	vmovq  r14,xmm3
    b345:	vzeroupper
    b348:	mov    eax,DWORD PTR [rsp+0x48]
    b34c:	lea    r13,[r12+r12*1]
    b350:	mov    r11,r12
    b353:	shr    r11,0x3
    b357:	vmovq  xmm5,r13
    b35c:	mov    QWORD PTR [rsp+0x70],rbx
    b361:	mov    r8d,0x1
    b367:	mov    rsi,0xffffffffffffffff
    b36e:	mov    QWORD PTR [rsp+0x78],rax
    b373:	mov    r15,rax
    b376:	jmp    b38c <bench_ada__run_17.isra.0+0x31c>
    b378:	nop    DWORD PTR [rax+rax*1+0x0]
    b380:	inc    r8d
    b383:	cmp    rsi,r14
    b386:	je     b4a1 <bench_ada__run_17.isra.0+0x431>
    b38c:	mov    rdx,rsi
    b38f:	inc    rsi
    b392:	cmp    r15d,r8d
    b395:	jl     b380 <bench_ada__run_17.isra.0+0x310>
    b397:	mov    rcx,QWORD PTR [rsp+0x78]
    b39c:	movsxd rax,r8d
    b39f:	lea    r9,[rax-0x1]
    b3a3:	sub    rcx,rax
    b3a6:	cmp    rcx,0xe
    b3aa:	jbe    b4ec <bench_ada__run_17.isra.0+0x47c>
    b3b0:	imul   rax,r11
    b3b4:	mov    rbx,rsi
    b3b7:	imul   rbx,r11
    b3bb:	add    rax,rdx
    b3be:	movsxd rdx,esi
    b3c1:	add    rdx,rbx
    b3c4:	shl    rdx,0x3
    b3c8:	lea    rbx,[r10+rdx*1]
    b3cc:	vmovq  xmm1,rbx
    b3d1:	lea    rbx,[rdx+r10*1+0x8]
    b3d6:	mov    r13,rbx
    b3d9:	mov    rbx,r12
    b3dc:	imul   rbx,rcx
    b3e0:	shl    rax,0x3
    b3e4:	lea    rdi,[r10+rax*1]
    b3e8:	lea    rbx,[rdi+rbx*1+0x8]
    b3ed:	cmp    rbx,r13
    b3f0:	jb     b409 <bench_ada__run_17.isra.0+0x399>
    b3f2:	vmovq  rbx,xmm1
    b3f7:	add    rdi,0x8
    b3fb:	lea    rbx,[rbx+rcx*8+0x8]
    b400:	cmp    rbx,rdi
    b403:	jae    b4ec <bench_ada__run_17.isra.0+0x47c>
    b409:	cmp    r15d,r8d
    b40c:	je     b472 <bench_ada__run_17.isra.0+0x402>
    b40e:	lea    rbx,[rcx+0x1]
    b412:	dec    rcx
    b415:	lea    rax,[rax+r10*1+0x8]
    b41a:	vmovq  r13,xmm5
    b41f:	shr    rcx,1
    b422:	lea    rdi,[rcx+0x1]
    b426:	lea    rcx,[rdx+r10*1+0x8]
    b42b:	xor    edx,edx
    b42d:	nop    DWORD PTR [rax+rax*1+0x0]
    b435:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b440:	vmovsd xmm0,QWORD PTR [rax]
    b444:	vmovhpd xmm0,xmm0,QWORD PTR [r12+rax*1]
    b44a:	inc    rdx
    b44d:	add    rax,r13
    b450:	add    rcx,0x10
    b454:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    b459:	cmp    rdx,rdi
    b45c:	jb     b440 <bench_ada__run_17.isra.0+0x3d0>
    b45e:	add    rdi,rdi
    b461:	vmovq  xmm5,r13
    b466:	cmp    rbx,rdi
    b469:	je     b380 <bench_ada__run_17.isra.0+0x310>
    b46f:	add    r9,rdi
    b472:	inc    r9
    b475:	mov    rax,r11
    b478:	inc    r8d
    b47b:	imul   rax,r9
    b47f:	add    rax,rsi
    b482:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    b488:	mov    rax,rsi
    b48b:	imul   rax,r11
    b48f:	add    rax,r9
    b492:	vmovsd QWORD PTR [r10+rax*8],xmm0
    b498:	cmp    rsi,r14
    b49b:	jne    b38c <bench_ada__run_17.isra.0+0x31c>
    b4a1:	mov    rbx,QWORD PTR [rsp+0x70]
    b4a6:	mov    rax,QWORD PTR [rsp+0x58]
    b4ab:	mov    rdi,QWORD PTR [rsp+0x50]
    b4b0:	mov    rdx,QWORD PTR [rbp+0x10]
    b4b4:	mov    rsi,QWORD PTR [rbp+0x18]
    b4b8:	mov    rcx,QWORD PTR [rbp+0x28]
    b4bc:	mov    edi,DWORD PTR [rsp+0x4c]
    b4c0:	cmp    DWORD PTR [rsp+0x44],edi
    b4c4:	jne    b0e0 <bench_ada__run_17.isra.0+0x70>
    b4ca:	lea    rsp,[rbp-0x28]
    b4ce:	pop    rbx
    b4cf:	pop    r12
    b4d1:	pop    r13
    b4d3:	pop    r14
    b4d5:	pop    r15
    b4d7:	pop    rbp
    b4d8:	ret
    b4d9:	nop    DWORD PTR [rax+0x0]
    b4e0:	xor    edi,edi
    b4e2:	mov    ecx,0xffffffff
    b4e7:	jmp    b26d <bench_ada__run_17.isra.0+0x1fd>
    b4ec:	mov    rdx,rsi
    b4ef:	vmovq  r13,xmm5
    b4f4:	imul   rdx,r12
    b4f8:	add    rdx,r10
    b4fb:	nop    DWORD PTR [rax+rax*1+0x0]
    b500:	inc    r9
    b503:	mov    rax,r11
    b506:	imul   rax,r9
    b50a:	add    rax,rsi
    b50d:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    b513:	vmovsd QWORD PTR [rdx+r9*8],xmm0
    b519:	cmp    r9,r14
    b51c:	jne    b500 <bench_ada__run_17.isra.0+0x490>
    b51e:	vmovq  xmm5,r13
    b523:	jmp    b380 <bench_ada__run_17.isra.0+0x310>
    b528:	mov    eax,DWORD PTR [rsp+0x40]
    b52c:	mov    r9d,DWORD PTR [rsp+0x4c]
    b531:	mov    rdx,QWORD PTR [rsp+0x50]
    b536:	mov    rcx,QWORD PTR [rbp+0x10]
    b53a:	mov    rsi,QWORD PTR [rbp+0x18]
    b53e:	mov    rdi,QWORD PTR [rbp+0x28]
    b542:	mov    r8d,DWORD PTR [rsp+0x44]
    b547:	cmp    eax,0xffffffff
    b54a:	mov    rax,QWORD PTR [rsp+0x58]
    b54f:	jne    b556 <bench_ada__run_17.isra.0+0x4e6>
    b551:	jmp    b560 <bench_ada__run_17.isra.0+0x4f0>
    b553:	inc    r9d
    b556:	cmp    r8d,r9d
    b559:	jne    b553 <bench_ada__run_17.isra.0+0x4e3>
    b55b:	jmp    b4ca <bench_ada__run_17.isra.0+0x45a>
    b560:	cmp    r8d,r9d
    b563:	je     b4ca <bench_ada__run_17.isra.0+0x45a>
    b569:	lea    r11d,[r9+0x1]
    b56d:	cmp    r8d,r11d
    b570:	je     b4ca <bench_ada__run_17.isra.0+0x45a>
    b576:	add    r9d,0x2
    b57a:	jmp    b560 <bench_ada__run_17.isra.0+0x4f0>
    b57c:	nop    DWORD PTR [rax+0x0]


<bench_ada__run_18.isra.0>:
    b580:	push   rbp
    b581:	mov    eax,edi
    b583:	mov    rbp,rsp
    b586:	push   r15
    b588:	push   r14
    b58a:	push   r13
    b58c:	push   r12
    b58e:	push   rbx
    b58f:	and    rsp,0xffffffffffffffc0
    b593:	add    rsp,0xffffffffffffff80
    b597:	mov    rdi,QWORD PTR [rbp+0x20]
    b59b:	test   edx,edx
    b59d:	je     ba09 <bench_ada__run_18.isra.0+0x489>
    b5a3:	mov    r12d,esi
    b5a6:	test   esi,esi
    b5a8:	lea    r15d,[rsi-0x1]
    b5ac:	mov    DWORD PTR [rsp+0x2c],eax
    b5b0:	setne  BYTE PTR [rsp+0x67]
    b5b5:	lea    r13,[r12*8+0x0]
    b5bd:	xor    eax,eax
    b5bf:	cmp    r15d,0xffffffff
    b5c3:	cmove  r13,rax
    b5c7:	cmovne rax,r12
    b5cb:	mov    DWORD PTR [rsp+0x28],edx
    b5cf:	mov    DWORD PTR [rsp+0x24],r15d
    b5d4:	mov    QWORD PTR [rsp+0x40],r8
    b5d9:	mov    QWORD PTR [rsp+0x38],r9
    b5de:	mov    rbx,rcx
    b5e1:	dec    r12
    b5e4:	imul   rax,r13
    b5e8:	mov    QWORD PTR [rsp+0x30],rax
    b5ed:	xor    eax,eax
    b5ef:	mov    DWORD PTR [rsp+0x60],eax
    b5f3:	mov    rax,r13
    b5f6:	shr    rax,0x3
    b5fa:	mov    QWORD PTR [rsp+0x78],rax
    b5ff:	nop
    b600:	inc    DWORD PTR [rsp+0x60]
    b604:	mov    rax,QWORD PTR [rsp+0x40]
    b609:	mov    rsi,QWORD PTR [rsp+0x38]
    b60e:	mov    rcx,QWORD PTR [rbp+0x10]
    b612:	mov    rdx,QWORD PTR [rbp+0x18]
    b616:	mov    r10,QWORD PTR [rbp+0x28]
    b61a:	mov    rdx,QWORD PTR [rsp+0x30]
    b61f:	xor    esi,esi
    b621:	call   2bd0 <memset@plt>
    b626:	vxorpd xmm2,xmm2,xmm2
    b62a:	mov    rdi,rax
    b62d:	mov    eax,DWORD PTR [rsp+0x2c]
    b631:	test   eax,eax
    b633:	je     b85a <bench_ada__run_18.isra.0+0x2da>
    b639:	mov    QWORD PTR [rsp+0x70],r13
    b63e:	mov    QWORD PTR [rbp+0x20],rdi
    b642:	mov    r13,QWORD PTR [rbp+0x18]
    b646:	lea    rsi,[rax-0x1]
    b64a:	mov    r8,0xffffffffffffffff
    b651:	jmp    b669 <bench_ada__run_18.isra.0+0xe9>
    b653:	xchg   ax,ax
    b655:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b660:	cmp    r8,rsi
    b663:	je     b84e <bench_ada__run_18.isra.0+0x2ce>
    b669:	inc    r8
    b66c:	movsxd rdi,r8d
    b66f:	vcomisd xmm2,QWORD PTR [r13+rdi*8+0x0]
    b676:	je     b660 <bench_ada__run_18.isra.0+0xe0>
    b678:	cmp    BYTE PTR [rsp+0x67],0x0
    b67d:	je     b660 <bench_ada__run_18.isra.0+0xe0>
    b67f:	mov    rax,QWORD PTR [rsp+0x70]
    b684:	mov    r14,QWORD PTR [rsp+0x78]
    b689:	mov    QWORD PTR [rsp+0x50],r8
    b68e:	mov    QWORD PTR [rsp+0x48],rsi
    b693:	mov    r8,rdi
    b696:	mov    ecx,0x1
    b69b:	mov    rdx,0xffffffffffffffff
    b6a2:	imul   rax,rdi
    b6a6:	imul   r14,rdi
    b6aa:	mov    rdi,QWORD PTR [rbp+0x20]
    b6ae:	add    rax,rbx
    b6b1:	mov    QWORD PTR [rsp+0x58],rax
    b6b6:	mov    r10,r14
    b6b9:	nop    DWORD PTR [rax+0x0]
    b6c0:	inc    rdx
    b6c3:	movsxd r14,edx
    b6c6:	lea    rax,[r10+r14*1]
    b6ca:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    b6cf:	vcomisd xmm0,xmm2
    b6d3:	je     b830 <bench_ada__run_18.isra.0+0x2b0>
    b6d9:	vmovsd xmm1,QWORD PTR [r13+r8*8+0x0]
    b6e0:	vcomisd xmm1,xmm2
    b6e4:	je     b830 <bench_ada__run_18.isra.0+0x2b0>
    b6ea:	mov    esi,edx
    b6ec:	test   edx,edx
    b6ee:	js     b830 <bench_ada__run_18.isra.0+0x2b0>
    b6f4:	vmulsd xmm1,xmm0,xmm1
    b6f8:	mov    DWORD PTR [rsp+0x68],edx
    b6fc:	vbroadcastsd zmm6,xmm1
    b702:	cmp    edx,0x6
    b705:	jbe    ba70 <bench_ada__run_18.isra.0+0x4f0>
    b70b:	mov    r9,QWORD PTR [rsp+0x70]
    b710:	mov    r15,QWORD PTR [rsp+0x58]
    b715:	mov    r11d,ecx
    b718:	shr    r11d,0x3
    b71c:	vmovapd zmm4,zmm6
    b722:	imul   r9,r14
    b726:	lea    rax,[r9+rdi*1]
    b72a:	mov    r9d,r11d
    b72d:	shl    r9,0x6
    b731:	sub    r15,rax
    b734:	add    r9,rax
    b737:	nop    WORD PTR [rax+rax*1+0x0]
    b740:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    b747:	add    rax,0x40
    b74b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    b752:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    b759:	cmp    r9,rax
    b75c:	jne    b740 <bench_ada__run_18.isra.0+0x1c0>
    b75e:	shl    r11d,0x3
    b762:	cmp    ecx,r11d
    b765:	je     b830 <bench_ada__run_18.isra.0+0x2b0>
    b76b:	lea    r9d,[r11-0x1]
    b76f:	mov    r15d,DWORD PTR [rsp+0x68]
    b774:	sub    r15d,r11d
    b777:	cmp    r15d,0x2
    b77b:	jbe    b7b3 <bench_ada__run_18.isra.0+0x233>
    b77d:	mov    rax,QWORD PTR [rsp+0x78]
    b782:	inc    r15d
    b785:	imul   rax,r14
    b789:	add    rax,r11
    b78c:	add    r11,r10
    b78f:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r11*8]
    b795:	mov    r11d,r15d
    b798:	and    r11d,0xfffffffc
    b79c:	and    r15d,0x3
    b7a0:	vaddpd ymm6,ymm6,YMMWORD PTR [rdi+rax*8]
    b7a5:	vmovupd YMMWORD PTR [rdi+rax*8],ymm6
    b7aa:	je     b830 <bench_ada__run_18.isra.0+0x2b0>
    b7b0:	add    r9d,r11d
    b7b3:	mov    r15,QWORD PTR [rsp+0x78]
    b7b8:	lea    r11d,[r9+0x1]
    b7bc:	mov    DWORD PTR [rsp+0x68],r11d
    b7c1:	mov    rax,r15
    b7c4:	imul   r15,r8
    b7c8:	imul   rax,r14
    b7cc:	lea    r14,[rax+r11*1]
    b7d0:	add    r11,r15
    b7d3:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    b7d9:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    b7df:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    b7e5:	cmp    DWORD PTR [rsp+0x68],esi
    b7e9:	je     b830 <bench_ada__run_18.isra.0+0x2b0>
    b7eb:	lea    r11d,[r9+0x2]
    b7ef:	lea    r14,[rax+r11*1]
    b7f3:	mov    DWORD PTR [rsp+0x68],r11d
    b7f8:	add    r11,r15
    b7fb:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    b801:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    b807:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    b80d:	cmp    esi,DWORD PTR [rsp+0x68]
    b811:	je     b830 <bench_ada__run_18.isra.0+0x2b0>
    b813:	lea    esi,[r9+0x3]
    b817:	add    rax,rsi
    b81a:	add    rsi,r15
    b81d:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    b822:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rax*8]
    b827:	vmovsd QWORD PTR [rdi+rax*8],xmm1
    b82c:	nop    DWORD PTR [rax+0x0]
    b830:	inc    ecx
    b832:	cmp    rdx,r12
    b835:	jne    b6c0 <bench_ada__run_18.isra.0+0x140>
    b83b:	mov    r8,QWORD PTR [rsp+0x50]
    b840:	mov    rsi,QWORD PTR [rsp+0x48]
    b845:	cmp    r8,rsi
    b848:	jne    b669 <bench_ada__run_18.isra.0+0xe9>
    b84e:	mov    r13,QWORD PTR [rsp+0x70]
    b853:	mov    rdi,QWORD PTR [rbp+0x20]
    b857:	vzeroupper
    b85a:	mov    eax,DWORD PTR [rsp+0x24]
    b85e:	cmp    eax,0xffffffff
    b861:	je     b9e5 <bench_ada__run_18.isra.0+0x465>
    b867:	mov    r14d,eax
    b86a:	mov    QWORD PTR [rsp+0x58],rbx
    b86f:	mov    r11,QWORD PTR [rsp+0x78]
    b874:	mov    r9d,0x1
    b87a:	mov    QWORD PTR [rsp+0x68],r14
    b87f:	mov    rsi,0xffffffffffffffff
    b886:	lea    rbx,[r13+r13*1+0x0]
    b88b:	mov    r15d,eax
    b88e:	jmp    b8ac <bench_ada__run_18.isra.0+0x32c>
    b890:	nop    DWORD PTR [rax+rax*1+0x0]
    b895:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b8a0:	inc    r9d
    b8a3:	cmp    rsi,r12
    b8a6:	je     b9e0 <bench_ada__run_18.isra.0+0x460>
    b8ac:	mov    rax,rsi
    b8af:	inc    rsi
    b8b2:	cmp    r15d,r9d
    b8b5:	jl     b8a0 <bench_ada__run_18.isra.0+0x320>
    b8b7:	mov    rcx,QWORD PTR [rsp+0x68]
    b8bc:	movsxd rdx,r9d
    b8bf:	lea    r10,[rdx-0x1]
    b8c3:	sub    rcx,rdx
    b8c6:	cmp    rcx,0xe
    b8ca:	jbe    ba20 <bench_ada__run_18.isra.0+0x4a0>
    b8d0:	imul   rdx,r11
    b8d4:	movsxd r14,esi
    b8d7:	add    rax,rdx
    b8da:	mov    rdx,rsi
    b8dd:	imul   rdx,r11
    b8e1:	shl    rax,0x3
    b8e5:	add    rdx,r14
    b8e8:	lea    r8,[rdi+rax*1]
    b8ec:	shl    rdx,0x3
    b8f0:	lea    r14,[rdi+rdx*1]
    b8f4:	vmovq  xmm3,r14
    b8f9:	mov    r14,r13
    b8fc:	imul   r14,rcx
    b900:	lea    r14,[r8+r14*1+0x8]
    b905:	mov    QWORD PTR [rsp+0x70],r14
    b90a:	lea    r14,[rdx+rdi*1+0x8]
    b90f:	cmp    QWORD PTR [rsp+0x70],r14
    b914:	jb     b92d <bench_ada__run_18.isra.0+0x3ad>
    b916:	vmovq  r14,xmm3
    b91b:	add    r8,0x8
    b91f:	lea    r14,[r14+rcx*8+0x8]
    b924:	cmp    r14,r8
    b927:	jae    ba20 <bench_ada__run_18.isra.0+0x4a0>
    b92d:	cmp    r15d,r9d
    b930:	je     b9ae <bench_ada__run_18.isra.0+0x42e>
    b932:	lea    r14,[rcx+0x1]
    b936:	dec    rcx
    b939:	lea    rax,[rax+rdi*1+0x8]
    b93e:	shr    rcx,1
    b941:	lea    r8,[rcx+0x1]
    b945:	lea    rcx,[rdx+rdi*1+0x8]
    b94a:	xor    edx,edx
    b94c:	nop    DWORD PTR [rax+rax*1+0x0]
    b954:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b95f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b96a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b975:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b980:	vmovsd xmm0,QWORD PTR [rax]
    b984:	vmovhpd xmm0,xmm0,QWORD PTR [r13+rax*1+0x0]
    b98b:	inc    rdx
    b98e:	add    rax,rbx
    b991:	add    rcx,0x10
    b995:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    b99a:	cmp    rdx,r8
    b99d:	jb     b980 <bench_ada__run_18.isra.0+0x400>
    b99f:	add    r8,r8
    b9a2:	cmp    r14,r8
    b9a5:	je     b8a0 <bench_ada__run_18.isra.0+0x320>
    b9ab:	add    r10,r8
    b9ae:	inc    r10
    b9b1:	mov    rax,r11
    b9b4:	inc    r9d
    b9b7:	imul   rax,r10
    b9bb:	add    rax,rsi
    b9be:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    b9c3:	mov    rax,rsi
    b9c6:	imul   rax,r11
    b9ca:	add    rax,r10
    b9cd:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    b9d2:	cmp    rsi,r12
    b9d5:	jne    b8ac <bench_ada__run_18.isra.0+0x32c>
    b9db:	nop    DWORD PTR [rax+rax*1+0x0]
    b9e0:	mov    rbx,QWORD PTR [rsp+0x58]
    b9e5:	mov    rax,QWORD PTR [rsp+0x40]
    b9ea:	mov    rsi,QWORD PTR [rsp+0x38]
    b9ef:	mov    rcx,QWORD PTR [rbp+0x10]
    b9f3:	mov    rdx,QWORD PTR [rbp+0x18]
    b9f7:	mov    r10,QWORD PTR [rbp+0x28]
    b9fb:	mov    esi,DWORD PTR [rsp+0x60]
    b9ff:	cmp    DWORD PTR [rsp+0x28],esi
    ba03:	jne    b600 <bench_ada__run_18.isra.0+0x80>
    ba09:	lea    rsp,[rbp-0x28]
    ba0d:	pop    rbx
    ba0e:	pop    r12
    ba10:	pop    r13
    ba12:	pop    r14
    ba14:	pop    r15
    ba16:	pop    rbp
    ba17:	ret
    ba18:	nop    DWORD PTR [rax+rax*1+0x0]
    ba20:	mov    rdx,r13
    ba23:	imul   rdx,rsi
    ba27:	add    rdx,rdi
    ba2a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ba35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ba40:	inc    r10
    ba43:	mov    rax,r11
    ba46:	imul   rax,r10
    ba4a:	add    rax,rsi
    ba4d:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    ba52:	vmovsd QWORD PTR [rdx+r10*8],xmm0
    ba58:	cmp    r10,r12
    ba5b:	jne    ba40 <bench_ada__run_18.isra.0+0x4c0>
    ba5d:	jmp    b8a0 <bench_ada__run_18.isra.0+0x320>
    ba62:	nop    DWORD PTR [rax]
    ba65:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ba70:	xor    r11d,r11d
    ba73:	mov    r9d,0xffffffff
    ba79:	jmp    b76f <bench_ada__run_18.isra.0+0x1ef>
    ba7e:	xchg   ax,ax


<bench_ada__run_19.isra.0>:
    ba80:	push   rbp
    ba81:	mov    rbp,rsp
    ba84:	push   r15
    ba86:	push   r14
    ba88:	push   r13
    ba8a:	push   r12
    ba8c:	push   rbx
    ba8d:	and    rsp,0xffffffffffffffc0
    ba91:	add    rsp,0xffffffffffffff80
    ba95:	mov    r12,QWORD PTR [rbp+0x18]
    ba99:	test   edx,edx
    ba9b:	je     bd73 <bench_ada__run_19.isra.0+0x2f3>
    baa1:	mov    r13d,esi
    baa4:	test   esi,esi
    baa6:	mov    eax,0x0
    baab:	mov    DWORD PTR [rsp+0x38],edx
    baaf:	lea    rsi,[r13*8+0x0]
    bab7:	setne  r14b
    babb:	mov    DWORD PTR [rsp+0x3c],edi
    babf:	mov    QWORD PTR [rsp+0x48],r8
    bac4:	cmove  rsi,rax
    bac8:	mov    BYTE PTR [rsp+0x73],r14b
    bacd:	mov    r14,r9
    bad0:	mov    r9,QWORD PTR [rbp+0x20]
    bad4:	cmovne rax,r13
    bad8:	mov    QWORD PTR [rsp+0x68],rsi
    badd:	mov    rbx,rcx
    bae0:	xor    r15d,r15d
    bae3:	imul   rax,rsi
    bae7:	dec    r13
    baea:	shr    rsi,0x3
    baee:	mov    QWORD PTR [rsp+0x40],rax
    baf3:	mov    QWORD PTR [rsp+0x78],rsi
    baf8:	nop    DWORD PTR [rax+rax*1+0x0]
    bb00:	mov    rax,QWORD PTR [rsp+0x48]
    bb05:	mov    rsi,QWORD PTR [rbp+0x10]
    bb09:	mov    rcx,QWORD PTR [rbp+0x28]
    bb0d:	inc    r15d
    bb10:	mov    rdx,QWORD PTR [rsp+0x40]
    bb15:	xor    esi,esi
    bb17:	mov    rdi,r9
    bb1a:	call   2bd0 <memset@plt>
    bb1f:	vxorpd xmm2,xmm2,xmm2
    bb23:	mov    r9,rax
    bb26:	mov    eax,DWORD PTR [rsp+0x3c]
    bb2a:	test   eax,eax
    bb2c:	je     bd5b <bench_ada__run_19.isra.0+0x2db>
    bb32:	mov    DWORD PTR [rsp+0x34],r15d
    bb37:	mov    QWORD PTR [rsp+0x28],r14
    bb3c:	mov    rdi,0xffffffffffffffff
    bb43:	lea    r11,[rax-0x1]
    bb47:	jmp    bb69 <bench_ada__run_19.isra.0+0xe9>
    bb49:	nop
    bb4a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bb55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bb60:	cmp    rdi,r11
    bb63:	je     bd4e <bench_ada__run_19.isra.0+0x2ce>
    bb69:	inc    rdi
    bb6c:	movsxd r14,edi
    bb6f:	vcomisd xmm2,QWORD PTR [r12+r14*8]
    bb75:	je     bb60 <bench_ada__run_19.isra.0+0xe0>
    bb77:	cmp    BYTE PTR [rsp+0x73],0x0
    bb7c:	je     bb60 <bench_ada__run_19.isra.0+0xe0>
    bb7e:	mov    rax,QWORD PTR [rsp+0x68]
    bb83:	mov    r10,QWORD PTR [rsp+0x78]
    bb88:	mov    QWORD PTR [rsp+0x58],rdi
    bb8d:	mov    QWORD PTR [rsp+0x50],r11
    bb92:	mov    ecx,0x1
    bb97:	mov    rdx,0xffffffffffffffff
    bb9e:	mov    r11,r14
    bba1:	imul   rax,r14
    bba5:	imul   r10,r14
    bba9:	add    rax,rbx
    bbac:	mov    QWORD PTR [rsp+0x60],rax
    bbb1:	nop    DWORD PTR [rax+0x0]
    bbb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bbc0:	inc    rdx
    bbc3:	movsxd r14,edx
    bbc6:	lea    rax,[r10+r14*1]
    bbca:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    bbcf:	vcomisd xmm0,xmm2
    bbd3:	je     bd30 <bench_ada__run_19.isra.0+0x2b0>
    bbd9:	vmovsd xmm1,QWORD PTR [r12+r11*8]
    bbdf:	vcomisd xmm1,xmm2
    bbe3:	je     bd30 <bench_ada__run_19.isra.0+0x2b0>
    bbe9:	mov    esi,edx
    bbeb:	test   edx,edx
    bbed:	js     bd30 <bench_ada__run_19.isra.0+0x2b0>
    bbf3:	vmulsd xmm1,xmm0,xmm1
    bbf7:	mov    DWORD PTR [rsp+0x74],edx
    bbfb:	vbroadcastsd zmm6,xmm1
    bc01:	cmp    edx,0x6
    bc04:	jbe    bd90 <bench_ada__run_19.isra.0+0x310>
    bc0a:	mov    rdi,QWORD PTR [rsp+0x68]
    bc0f:	mov    r15,QWORD PTR [rsp+0x60]
    bc14:	mov    r8d,ecx
    bc17:	shr    r8d,0x3
    bc1b:	vmovapd zmm4,zmm6
    bc21:	imul   rdi,r14
    bc25:	lea    rax,[rdi+r9*1]
    bc29:	mov    edi,r8d
    bc2c:	shl    rdi,0x6
    bc30:	sub    r15,rax
    bc33:	add    rdi,rax
    bc36:	cs nop WORD PTR [rax+rax*1+0x0]
    bc40:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    bc47:	add    rax,0x40
    bc4b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    bc52:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    bc59:	cmp    rax,rdi
    bc5c:	jne    bc40 <bench_ada__run_19.isra.0+0x1c0>
    bc5e:	shl    r8d,0x3
    bc62:	cmp    r8d,ecx
    bc65:	je     bd30 <bench_ada__run_19.isra.0+0x2b0>
    bc6b:	lea    edi,[r8-0x1]
    bc6f:	mov    r15d,DWORD PTR [rsp+0x74]
    bc74:	sub    r15d,r8d
    bc77:	cmp    r15d,0x2
    bc7b:	jbe    bcb5 <bench_ada__run_19.isra.0+0x235>
    bc7d:	mov    rax,QWORD PTR [rsp+0x78]
    bc82:	inc    r15d
    bc85:	imul   rax,r14
    bc89:	add    rax,r8
    bc8c:	add    r8,r10
    bc8f:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r8*8]
    bc95:	mov    r8d,r15d
    bc98:	and    r8d,0xfffffffc
    bc9c:	and    r15d,0x3
    bca0:	vaddpd ymm6,ymm6,YMMWORD PTR [r9+rax*8]
    bca6:	vmovupd YMMWORD PTR [r9+rax*8],ymm6
    bcac:	je     bd30 <bench_ada__run_19.isra.0+0x2b0>
    bcb2:	add    edi,r8d
    bcb5:	mov    r15,QWORD PTR [rsp+0x78]
    bcba:	lea    r8d,[rdi+0x1]
    bcbe:	mov    DWORD PTR [rsp+0x74],r8d
    bcc3:	mov    rax,r15
    bcc6:	imul   r15,r11
    bcca:	imul   rax,r14
    bcce:	lea    r14,[rax+r8*1]
    bcd2:	add    r8,r15
    bcd5:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    bcdb:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    bce1:	vmovsd QWORD PTR [r9+r14*8],xmm0
    bce7:	cmp    esi,DWORD PTR [rsp+0x74]
    bceb:	je     bd30 <bench_ada__run_19.isra.0+0x2b0>
    bced:	lea    r8d,[rdi+0x2]
    bcf1:	lea    r14,[rax+r8*1]
    bcf5:	mov    DWORD PTR [rsp+0x74],r8d
    bcfa:	add    r8,r15
    bcfd:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    bd03:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    bd09:	vmovsd QWORD PTR [r9+r14*8],xmm0
    bd0f:	cmp    esi,DWORD PTR [rsp+0x74]
    bd13:	je     bd30 <bench_ada__run_19.isra.0+0x2b0>
    bd15:	lea    esi,[rdi+0x3]
    bd18:	add    rax,rsi
    bd1b:	add    rsi,r15
    bd1e:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    bd23:	vaddsd xmm1,xmm1,QWORD PTR [r9+rax*8]
    bd29:	vmovsd QWORD PTR [r9+rax*8],xmm1
    bd2f:	nop
    bd30:	inc    ecx
    bd32:	cmp    rdx,r13
    bd35:	jne    bbc0 <bench_ada__run_19.isra.0+0x140>
    bd3b:	mov    rdi,QWORD PTR [rsp+0x58]
    bd40:	mov    r11,QWORD PTR [rsp+0x50]
    bd45:	cmp    rdi,r11
    bd48:	jne    bb69 <bench_ada__run_19.isra.0+0xe9>
    bd4e:	mov    r15d,DWORD PTR [rsp+0x34]
    bd53:	mov    r14,QWORD PTR [rsp+0x28]
    bd58:	vzeroupper
    bd5b:	mov    rax,QWORD PTR [rsp+0x48]
    bd60:	mov    rsi,QWORD PTR [rbp+0x10]
    bd64:	mov    rcx,QWORD PTR [rbp+0x28]
    bd68:	cmp    DWORD PTR [rsp+0x38],r15d
    bd6d:	jne    bb00 <bench_ada__run_19.isra.0+0x80>
    bd73:	lea    rsp,[rbp-0x28]
    bd77:	pop    rbx
    bd78:	pop    r12
    bd7a:	pop    r13
    bd7c:	pop    r14
    bd7e:	pop    r15
    bd80:	pop    rbp
    bd81:	ret
    bd82:	nop    DWORD PTR [rax]
    bd85:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bd90:	xor    r8d,r8d
    bd93:	mov    edi,0xffffffff
    bd98:	jmp    bc6f <bench_ada__run_19.isra.0+0x1ef>
    bd9d:	nop
    bd9e:	xchg   ax,ax


<bench_ada__run_2.isra.0>:
    5920:	mov    rax,rsi
    5923:	mov    r11,QWORD PTR [rsp+0x10]
    5928:	mov    rsi,rdx
    592b:	mov    r10,rcx
    592e:	mov    rdx,QWORD PTR [rsp+0x8]
    5933:	test   edi,edi
    5935:	je     59a9 <bench_ada__run_2.isra.0+0x89>
    5937:	xor    ecx,ecx
    5939:	nop    DWORD PTR [rax+0x0]
    5940:	inc    ecx
    5942:	vmovsd xmm4,QWORD PTR [r8+0x8]
    5948:	vmulsd xmm2,xmm4,QWORD PTR [rax+0x20]
    594d:	vmovsd xmm0,QWORD PTR [r8]
    5952:	vmovsd xmm3,QWORD PTR [r8+0x10]
    5958:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x18]
    595d:	vmulsd xmm5,xmm4,QWORD PTR [rax+0x38]
    5962:	vmulsd xmm4,xmm4,QWORD PTR [rax+0x8]
    5967:	vaddsd xmm1,xmm1,xmm2
    596b:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x28]
    5970:	vaddsd xmm2,xmm1,xmm2
    5974:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x30]
    5979:	vmulsd xmm0,xmm0,QWORD PTR [rax]
    597d:	vaddsd xmm1,xmm1,xmm5
    5981:	vmulsd xmm5,xmm3,QWORD PTR [rax+0x40]
    5986:	vmulsd xmm3,xmm3,QWORD PTR [rax+0x10]
    598b:	vaddsd xmm0,xmm0,xmm4
    598f:	vmovsd QWORD PTR [rdx+0x8],xmm2
    5994:	vaddsd xmm1,xmm1,xmm5
    5998:	vaddsd xmm0,xmm0,xmm3
    599c:	vmovsd QWORD PTR [rdx+0x10],xmm1
    59a1:	vmovsd QWORD PTR [rdx],xmm0
    59a5:	cmp    edi,ecx
    59a7:	jne    5940 <bench_ada__run_2.isra.0+0x20>
    59a9:	ret
    59aa:	nop    WORD PTR [rax+rax*1+0x0]


<bench_ada__run_20.isra.0>:
    bda0:	push   rbp
    bda1:	mov    rbp,rsp
    bda4:	push   r15
    bda6:	push   r14
    bda8:	push   r13
    bdaa:	push   r12
    bdac:	push   rbx
    bdad:	and    rsp,0xffffffffffffffc0
    bdb1:	add    rsp,0xffffffffffffff80
    bdb5:	mov    r10,QWORD PTR [rbp+0x20]
    bdb9:	mov    QWORD PTR [rsp+0x58],r8
    bdbe:	test   edx,edx
    bdc0:	je     c067 <bench_ada__run_20.isra.0+0x2c7>
    bdc6:	mov    r8d,esi
    bdc9:	xor    eax,eax
    bdcb:	mov    DWORD PTR [rsp+0x4c],edi
    bdcf:	test   esi,esi
    bdd1:	lea    rdi,[r8*8+0x0]
    bdd9:	mov    DWORD PTR [rsp+0x48],edx
    bddd:	mov    QWORD PTR [rsp+0x30],r8
    bde2:	mov    DWORD PTR [rsp+0x44],esi
    bde6:	cmove  rdi,rax
    bdea:	mov    rbx,rcx
    bded:	mov    r12,r9
    bdf0:	cmovne rax,r8
    bdf4:	mov    QWORD PTR [rsp+0x70],rdi
    bdf9:	xor    r15d,r15d
    bdfc:	imul   rax,rdi
    be00:	shr    rdi,0x3
    be04:	mov    QWORD PTR [rsp+0x50],rax
    be09:	mov    QWORD PTR [rsp+0x78],rdi
    be0e:	xchg   ax,ax
    be10:	mov    rax,QWORD PTR [rsp+0x58]
    be15:	mov    rsi,QWORD PTR [rbp+0x10]
    be19:	mov    rdi,QWORD PTR [rbp+0x18]
    be1d:	mov    rcx,QWORD PTR [rbp+0x28]
    be21:	inc    r15d
    be24:	mov    rdx,QWORD PTR [rsp+0x50]
    be29:	xor    esi,esi
    be2b:	mov    rdi,r10
    be2e:	call   2bd0 <memset@plt>
    be33:	vxorpd xmm7,xmm7,xmm7
    be37:	mov    r10,rax
    be3a:	mov    eax,DWORD PTR [rsp+0x4c]
    be3e:	test   eax,eax
    be40:	je     c04b <bench_ada__run_20.isra.0+0x2ab>
    be46:	mov    edx,DWORD PTR [rsp+0x44]
    be4a:	test   edx,edx
    be4c:	je     c04b <bench_ada__run_20.isra.0+0x2ab>
    be52:	lea    rcx,[rax-0x1]
    be56:	mov    rax,QWORD PTR [rsp+0x30]
    be5b:	mov    DWORD PTR [rsp+0x40],r15d
    be60:	mov    QWORD PTR [rsp+0x38],r12
    be65:	mov    QWORD PTR [rsp+0x60],rcx
    be6a:	mov    rdi,0xffffffffffffffff
    be71:	lea    r13,[rax-0x1]
    be75:	vmovq  xmm3,r13
    be7a:	nop    WORD PTR [rax+rax*1+0x0]
    be80:	mov    r14,QWORD PTR [rsp+0x70]
    be85:	inc    rdi
    be88:	mov    r9d,0x1
    be8e:	mov    rdx,0xffffffffffffffff
    be95:	movsxd rax,edi
    be98:	mov    r8,rdi
    be9b:	vmovq  rdi,xmm3
    bea0:	imul   r14,rax
    bea4:	lea    rsi,[r14+rbx*1]
    bea8:	mov    r14,QWORD PTR [rsp+0x78]
    bead:	mov    QWORD PTR [rsp+0x68],rsi
    beb2:	imul   r14,rax
    beb6:	mov    r13,r14
    beb9:	jmp    becc <bench_ada__run_20.isra.0+0x12c>
    bebb:	nop    DWORD PTR [rax+rax*1+0x0]
    bec0:	inc    r9d
    bec3:	cmp    rdx,rdi
    bec6:	je     c030 <bench_ada__run_20.isra.0+0x290>
    becc:	inc    rdx
    becf:	movsxd r14,edx
    bed2:	mov    esi,edx
    bed4:	lea    rax,[r13+r14*1+0x0]
    bed9:	vmovsd xmm1,QWORD PTR [rbx+rax*8]
    bede:	vbroadcastsd zmm2,xmm1
    bee4:	test   edx,edx
    bee6:	js     bec0 <bench_ada__run_20.isra.0+0x120>
    bee8:	vcomisd xmm1,xmm7
    beec:	je     bec0 <bench_ada__run_20.isra.0+0x120>
    beee:	mov    ecx,edx
    bef0:	cmp    edx,0x6
    bef3:	jbe    c080 <bench_ada__run_20.isra.0+0x2e0>
    bef9:	mov    r11,QWORD PTR [rsp+0x70]
    befe:	mov    r15,QWORD PTR [rsp+0x68]
    bf03:	mov    r12d,r9d
    bf06:	shr    r12d,0x3
    bf0a:	vmovapd zmm4,zmm2
    bf10:	imul   r11,r14
    bf14:	lea    rax,[r11+r10*1]
    bf18:	mov    r11d,r12d
    bf1b:	shl    r11,0x6
    bf1f:	sub    r15,rax
    bf22:	add    r11,rax
    bf25:	nop    DWORD PTR [rax+rax*1+0x0]
    bf2a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bf35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bf40:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    bf47:	add    rax,0x40
    bf4b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    bf52:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    bf59:	cmp    rax,r11
    bf5c:	jne    bf40 <bench_ada__run_20.isra.0+0x1a0>
    bf5e:	shl    r12d,0x3
    bf62:	cmp    r12d,r9d
    bf65:	je     bec0 <bench_ada__run_20.isra.0+0x120>
    bf6b:	lea    r11d,[r12-0x1]
    bf70:	sub    ecx,r12d
    bf73:	cmp    ecx,0x2
    bf76:	jbe    bfae <bench_ada__run_20.isra.0+0x20e>
    bf78:	mov    r15,QWORD PTR [rsp+0x78]
    bf7d:	inc    ecx
    bf7f:	imul   r15,r14
    bf83:	add    r15,r12
    bf86:	add    r12,r13
    bf89:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+r12*8]
    bf8f:	mov    r12d,ecx
    bf92:	and    r12d,0xfffffffc
    bf96:	and    ecx,0x3
    bf99:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+r15*8]
    bf9f:	vmovupd YMMWORD PTR [r10+r15*8],ymm2
    bfa5:	je     bec0 <bench_ada__run_20.isra.0+0x120>
    bfab:	add    r11d,r12d
    bfae:	mov    rax,QWORD PTR [rsp+0x78]
    bfb3:	lea    ecx,[r11+0x1]
    bfb7:	mov    r12,rcx
    bfba:	imul   rax,r14
    bfbe:	lea    r14,[rax+rcx*1]
    bfc2:	add    rcx,r13
    bfc5:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    bfca:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    bfd0:	vmovsd QWORD PTR [r10+r14*8],xmm0
    bfd6:	cmp    r12d,esi
    bfd9:	je     bec0 <bench_ada__run_20.isra.0+0x120>
    bfdf:	lea    ecx,[r11+0x2]
    bfe3:	lea    r14,[rax+rcx*1]
    bfe7:	mov    r12,rcx
    bfea:	add    rcx,r13
    bfed:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    bff2:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    bff8:	vmovsd QWORD PTR [r10+r14*8],xmm0
    bffe:	cmp    r12d,esi
    c001:	je     bec0 <bench_ada__run_20.isra.0+0x120>
    c007:	lea    ecx,[r11+0x3]
    c00b:	inc    r9d
    c00e:	add    rax,rcx
    c011:	add    rcx,r13
    c014:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    c019:	vaddsd xmm1,xmm1,QWORD PTR [r10+rax*8]
    c01f:	vmovsd QWORD PTR [r10+rax*8],xmm1
    c025:	cmp    rdx,rdi
    c028:	jne    becc <bench_ada__run_20.isra.0+0x12c>
    c02e:	xchg   ax,ax
    c030:	mov    rdi,r8
    c033:	cmp    r8,QWORD PTR [rsp+0x60]
    c038:	jne    be80 <bench_ada__run_20.isra.0+0xe0>
    c03e:	mov    r15d,DWORD PTR [rsp+0x40]
    c043:	mov    r12,QWORD PTR [rsp+0x38]
    c048:	vzeroupper
    c04b:	mov    rax,QWORD PTR [rsp+0x58]
    c050:	mov    rsi,QWORD PTR [rbp+0x10]
    c054:	mov    rdi,QWORD PTR [rbp+0x18]
    c058:	mov    rcx,QWORD PTR [rbp+0x28]
    c05c:	cmp    DWORD PTR [rsp+0x48],r15d
    c061:	jne    be10 <bench_ada__run_20.isra.0+0x70>
    c067:	lea    rsp,[rbp-0x28]
    c06b:	pop    rbx
    c06c:	pop    r12
    c06e:	pop    r13
    c070:	pop    r14
    c072:	pop    r15
    c074:	pop    rbp
    c075:	ret
    c076:	cs nop WORD PTR [rax+rax*1+0x0]
    c080:	xor    r12d,r12d
    c083:	mov    r11d,0xffffffff
    c089:	jmp    bf70 <bench_ada__run_20.isra.0+0x1d0>
    c08e:	xchg   ax,ax


<bench_ada__run_3.isra.0>:
    59b0:	mov    r10d,edi
    59b3:	mov    r11,QWORD PTR [rsp+0x10]
    59b8:	mov    rdi,rdx
    59bb:	mov    rax,rsi
    59be:	mov    rdx,QWORD PTR [rsp+0x8]
    59c3:	test   r10d,r10d
    59c6:	je     5a30 <bench_ada__run_3.isra.0+0x80>
    59c8:	xor    esi,esi
    59ca:	nop    WORD PTR [rax+rax*1+0x0]
    59d0:	inc    esi
    59d2:	vmovupd xmm0,XMMWORD PTR [r8]
    59d7:	vmovsd xmm1,QWORD PTR [rax+0x10]
    59dc:	vmovsd xmm3,QWORD PTR [r8+0x10]
    59e2:	vunpckhpd xmm2,xmm0,xmm0
    59e6:	vmulsd xmm2,xmm2,QWORD PTR [rax+0x28]
    59eb:	vmulsd xmm1,xmm1,xmm0
    59ef:	vaddsd xmm1,xmm1,xmm2
    59f3:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x40]
    59f8:	vmovddup xmm3,xmm3
    59fc:	vmulpd xmm3,xmm3,XMMWORD PTR [rax+0x30]
    5a01:	vaddsd xmm1,xmm1,xmm2
    5a05:	vpermilpd xmm2,xmm0,0x0
    5a0b:	vpermilpd xmm0,xmm0,0x3
    5a11:	vmulpd xmm2,xmm2,XMMWORD PTR [rax]
    5a15:	vmulpd xmm0,xmm0,XMMWORD PTR [rax+0x18]
    5a1a:	vmovsd QWORD PTR [rdx+0x10],xmm1
    5a1f:	vaddpd xmm0,xmm2,xmm0
    5a23:	vaddpd xmm0,xmm0,xmm3
    5a27:	vmovupd XMMWORD PTR [rdx],xmm0
    5a2b:	cmp    r10d,esi
    5a2e:	jne    59d0 <bench_ada__run_3.isra.0+0x20>
    5a30:	ret
    5a31:	nop
    5a32:	nop    DWORD PTR [rax]
    5a35:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_4.isra.0>:
    5a40:	push   rbp
    5a41:	mov    r10d,edi
    5a44:	mov    rdi,rcx
    5a47:	mov    rbp,rsp
    5a4a:	push   rbx
    5a4b:	and    rsp,0xffffffffffffffc0
    5a4f:	sub    rsp,0x8
    5a53:	mov    rcx,QWORD PTR [rbp+0x10]
    5a57:	mov    r11,QWORD PTR [rbp+0x18]
    5a5b:	test   r10d,r10d
    5a5e:	je     5ba7 <bench_ada__run_4.isra.0+0x167>
    5a64:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2fb52]        # 355c0 <__gnat_ada_main_program_name+0x30>
    5a6e:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2fb88]        # 35600 <__gnat_ada_main_program_name+0x70>
    5a78:	mov    rax,rsi
    5a7b:	xor    esi,esi
    5a7d:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2fbb9]        # 35640 <__gnat_ada_main_program_name+0xb0>
    5a87:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2fbef]        # 35680 <__gnat_ada_main_program_name+0xf0>
    5a91:	nop    DWORD PTR [rax+0x0]
    5a95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5aa0:	inc    esi
    5aa2:	vmovupd zmm1,ZMMWORD PTR [rdx]
    5aa8:	vmovupd zmm4,ZMMWORD PTR [rax]
    5aae:	vmovsd xmm6,QWORD PTR [rdx+0x40]
    5ab3:	vmovsd xmm12,QWORD PTR [rdx+0x30]
    5ab8:	vmovsd xmm5,QWORD PTR [rdx+0x38]
    5abd:	vmovsd xmm3,QWORD PTR [rax+0x10]
    5ac2:	vmovsd xmm7,QWORD PTR [rax+0x28]
    5ac7:	vmovsd xmm13,QWORD PTR [rax+0x40]
    5acc:	vpermpd zmm2,zmm10,zmm1
    5ad2:	vpermpd zmm0,zmm11,zmm4
    5ad8:	vpermpd zmm14,zmm8,zmm4
    5ade:	vmulpd zmm0,zmm0,zmm2
    5ae4:	vpermpd zmm2,zmm9,zmm1
    5aea:	vmulpd zmm2,zmm2,zmm14
    5af0:	vaddpd zmm0,zmm0,zmm2
    5af6:	vunpcklpd xmm2,xmm12,xmm5
    5afa:	vunpcklpd xmm12,xmm6,xmm12
    5aff:	vunpcklpd xmm5,xmm5,xmm6
    5b03:	vinsertf64x2 ymm5,ymm5,xmm2,0x1
    5b0a:	vmulsd xmm6,xmm6,xmm13
    5b0f:	vinsertf64x2 ymm2,ymm2,xmm12,0x1
    5b16:	vmovddup xmm12,xmm13
    5b1b:	vinsertf64x4 zmm2,zmm2,ymm5,0x1
    5b22:	vmovddup xmm5,xmm7
    5b26:	vunpcklpd xmm7,xmm3,xmm7
    5b2a:	vmovddup xmm3,xmm3
    5b2e:	vinsertf64x2 ymm5,ymm5,xmm12,0x1
    5b35:	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    5b3c:	vinsertf64x4 zmm3,zmm3,ymm5,0x1
    5b43:	vmulpd zmm2,zmm2,zmm3
    5b49:	vextractf64x2 xmm3,zmm4,0x3
    5b50:	vaddpd zmm0,zmm0,zmm2
    5b56:	vmovdqu64 ZMMWORD PTR [rcx],zmm0
    5b5c:	vmovapd ZMMWORD PTR [rsp-0x78],zmm0
    5b67:	vextractf64x2 xmm2,ymm1,0x1
    5b6e:	valignq zmm4,zmm4,zmm4,0x7
    5b75:	vmulsd xmm2,xmm2,xmm3
    5b79:	valignq zmm1,zmm1,zmm1,0x5
    5b80:	vmulsd xmm1,xmm1,xmm4
    5b84:	vaddsd xmm1,xmm2,xmm1
    5b88:	vaddsd xmm1,xmm1,xmm6
    5b8c:	vmovsd QWORD PTR [rsp-0x38],xmm1
    5b92:	mov    rbx,QWORD PTR [rsp-0x38]
    5b97:	mov    QWORD PTR [rcx+0x40],rbx
    5b9b:	cmp    r10d,esi
    5b9e:	jne    5aa0 <bench_ada__run_4.isra.0+0x60>
    5ba4:	vzeroupper
    5ba7:	mov    rbx,QWORD PTR [rbp-0x8]
    5bab:	leave
    5bac:	ret
    5bad:	nop
    5bae:	xchg   ax,ax


<bench_ada__run_5.isra.0>:
    5bb0:	push   rbp
    5bb1:	mov    r10d,edi
    5bb4:	mov    rdi,rcx
    5bb7:	mov    rbp,rsp
    5bba:	push   rbx
    5bbb:	and    rsp,0xffffffffffffffc0
    5bbf:	sub    rsp,0x8
    5bc3:	mov    rcx,QWORD PTR [rbp+0x10]
    5bc7:	mov    r11,QWORD PTR [rbp+0x18]
    5bcb:	test   r10d,r10d
    5bce:	je     5d17 <bench_ada__run_5.isra.0+0x167>
    5bd4:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2fae2]        # 356c0 <__gnat_ada_main_program_name+0x130>
    5bde:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2fa18]        # 35600 <__gnat_ada_main_program_name+0x70>
    5be8:	mov    rax,rsi
    5beb:	xor    esi,esi
    5bed:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2fa49]        # 35640 <__gnat_ada_main_program_name+0xb0>
    5bf7:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2faff]        # 35700 <__gnat_ada_main_program_name+0x170>
    5c01:	nop    DWORD PTR [rax+0x0]
    5c05:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5c10:	inc    esi
    5c12:	vmovupd zmm1,ZMMWORD PTR [rdx]
    5c18:	vmovupd zmm4,ZMMWORD PTR [rax]
    5c1e:	vmovsd xmm6,QWORD PTR [rdx+0x40]
    5c23:	vmovsd xmm12,QWORD PTR [rdx+0x30]
    5c28:	vmovsd xmm5,QWORD PTR [rdx+0x38]
    5c2d:	vmovsd xmm3,QWORD PTR [rax+0x30]
    5c32:	vmovsd xmm7,QWORD PTR [rax+0x38]
    5c37:	vmovsd xmm13,QWORD PTR [rax+0x40]
    5c3c:	vpermpd zmm2,zmm10,zmm1
    5c42:	vpermpd zmm0,zmm11,zmm4
    5c48:	vpermpd zmm14,zmm8,zmm4
    5c4e:	vmulpd zmm0,zmm0,zmm2
    5c54:	vpermpd zmm2,zmm9,zmm1
    5c5a:	vmulpd zmm2,zmm2,zmm14
    5c60:	vaddpd zmm0,zmm0,zmm2
    5c66:	vunpcklpd xmm2,xmm12,xmm5
    5c6a:	vunpcklpd xmm12,xmm6,xmm12
    5c6f:	vunpcklpd xmm5,xmm5,xmm6
    5c73:	vinsertf64x2 ymm5,ymm5,xmm2,0x1
    5c7a:	vmulsd xmm6,xmm6,xmm13
    5c7f:	vinsertf64x2 ymm2,ymm2,xmm12,0x1
    5c86:	vmovddup xmm12,xmm13
    5c8b:	vinsertf64x4 zmm2,zmm2,ymm5,0x1
    5c92:	vmovddup xmm5,xmm7
    5c96:	vunpcklpd xmm7,xmm3,xmm7
    5c9a:	vmovddup xmm3,xmm3
    5c9e:	vinsertf64x2 ymm5,ymm5,xmm12,0x1
    5ca5:	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    5cac:	vinsertf64x4 zmm3,zmm3,ymm5,0x1
    5cb3:	vmulpd zmm2,zmm2,zmm3
    5cb9:	vextractf64x2 xmm3,ymm4,0x1
    5cc0:	vaddpd zmm0,zmm0,zmm2
    5cc6:	vmovdqu64 ZMMWORD PTR [rcx],zmm0
    5ccc:	vmovapd ZMMWORD PTR [rsp-0x78],zmm0
    5cd7:	vextractf64x2 xmm2,ymm1,0x1
    5cde:	valignq zmm4,zmm4,zmm4,0x5
    5ce5:	vmulsd xmm2,xmm2,xmm3
    5ce9:	valignq zmm1,zmm1,zmm1,0x5
    5cf0:	vmulsd xmm1,xmm1,xmm4
    5cf4:	vaddsd xmm1,xmm2,xmm1
    5cf8:	vaddsd xmm1,xmm1,xmm6
    5cfc:	vmovsd QWORD PTR [rsp-0x38],xmm1
    5d02:	mov    rbx,QWORD PTR [rsp-0x38]
    5d07:	mov    QWORD PTR [rcx+0x40],rbx
    5d0b:	cmp    r10d,esi
    5d0e:	jne    5c10 <bench_ada__run_5.isra.0+0x60>
    5d14:	vzeroupper
    5d17:	mov    rbx,QWORD PTR [rbp-0x8]
    5d1b:	leave
    5d1c:	ret
    5d1d:	nop
    5d1e:	xchg   ax,ax


<bench_ada__run_6.isra.0>:
    5d20:	push   rbp
    5d21:	mov    r10d,edi
    5d24:	mov    rdi,rcx
    5d27:	mov    rbp,rsp
    5d2a:	push   rbx
    5d2b:	and    rsp,0xffffffffffffffc0
    5d2f:	sub    rsp,0x8
    5d33:	mov    rcx,QWORD PTR [rbp+0x10]
    5d37:	mov    r11,QWORD PTR [rbp+0x18]
    5d3b:	test   r10d,r10d
    5d3e:	je     5e87 <bench_ada__run_6.isra.0+0x167>
    5d44:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2f872]        # 355c0 <__gnat_ada_main_program_name+0x30>
    5d4e:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2f9e8]        # 35740 <__gnat_ada_main_program_name+0x1b0>
    5d58:	mov    rax,rsi
    5d5b:	xor    esi,esi
    5d5d:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2fa19]        # 35780 <__gnat_ada_main_program_name+0x1f0>
    5d67:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2f90f]        # 35680 <__gnat_ada_main_program_name+0xf0>
    5d71:	nop    DWORD PTR [rax+0x0]
    5d75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5d80:	inc    esi
    5d82:	vmovupd zmm1,ZMMWORD PTR [rdx]
    5d88:	vmovupd zmm4,ZMMWORD PTR [rax]
    5d8e:	vmovsd xmm6,QWORD PTR [rdx+0x40]
    5d93:	vmovsd xmm12,QWORD PTR [rdx+0x10]
    5d98:	vmovsd xmm5,QWORD PTR [rdx+0x28]
    5d9d:	vmovsd xmm3,QWORD PTR [rax+0x10]
    5da2:	vmovsd xmm7,QWORD PTR [rax+0x28]
    5da7:	vmovsd xmm13,QWORD PTR [rax+0x40]
    5dac:	vpermpd zmm2,zmm10,zmm1
    5db2:	vpermpd zmm0,zmm11,zmm4
    5db8:	vpermpd zmm14,zmm8,zmm4
    5dbe:	vmulpd zmm0,zmm0,zmm2
    5dc4:	vpermpd zmm2,zmm9,zmm1
    5dca:	vmulpd zmm2,zmm2,zmm14
    5dd0:	vaddpd zmm0,zmm0,zmm2
    5dd6:	vunpcklpd xmm2,xmm12,xmm5
    5dda:	vunpcklpd xmm12,xmm6,xmm12
    5ddf:	vunpcklpd xmm5,xmm5,xmm6
    5de3:	vinsertf64x2 ymm5,ymm5,xmm2,0x1
    5dea:	vmulsd xmm6,xmm6,xmm13
    5def:	vinsertf64x2 ymm2,ymm2,xmm12,0x1
    5df6:	vmovddup xmm12,xmm13
    5dfb:	vinsertf64x4 zmm2,zmm2,ymm5,0x1
    5e02:	vmovddup xmm5,xmm7
    5e06:	vunpcklpd xmm7,xmm3,xmm7
    5e0a:	vmovddup xmm3,xmm3
    5e0e:	vinsertf64x2 ymm5,ymm5,xmm12,0x1
    5e15:	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    5e1c:	vinsertf64x4 zmm3,zmm3,ymm5,0x1
    5e23:	vmulpd zmm2,zmm2,zmm3
    5e29:	vextractf64x2 xmm3,zmm4,0x3
    5e30:	vaddpd zmm0,zmm0,zmm2
    5e36:	vmovdqu64 ZMMWORD PTR [rcx],zmm0
    5e3c:	vmovapd ZMMWORD PTR [rsp-0x78],zmm0
    5e47:	vextractf64x2 xmm2,zmm1,0x3
    5e4e:	valignq zmm4,zmm4,zmm4,0x7
    5e55:	vmulsd xmm2,xmm2,xmm3
    5e59:	valignq zmm1,zmm1,zmm1,0x7
    5e60:	vmulsd xmm1,xmm1,xmm4
    5e64:	vaddsd xmm1,xmm2,xmm1
    5e68:	vaddsd xmm1,xmm1,xmm6
    5e6c:	vmovsd QWORD PTR [rsp-0x38],xmm1
    5e72:	mov    rbx,QWORD PTR [rsp-0x38]
    5e77:	mov    QWORD PTR [rcx+0x40],rbx
    5e7b:	cmp    r10d,esi
    5e7e:	jne    5d80 <bench_ada__run_6.isra.0+0x60>
    5e84:	vzeroupper
    5e87:	mov    rbx,QWORD PTR [rbp-0x8]
    5e8b:	leave
    5e8c:	ret
    5e8d:	nop
    5e8e:	xchg   ax,ax


<bench_ada__run_7.isra.0>:
    5e90:	sub    rsp,0x78
    5e94:	mov    QWORD PTR [rsp+0x8],r9
    5e99:	test   edx,edx
    5e9b:	je     5fb9 <bench_ada__run_7.isra.0+0x129>
    5ea1:	mov    QWORD PTR [rsp+0x48],rbx
    5ea6:	mov    rbx,rcx
    5ea9:	mov    QWORD PTR [rsp+0x68],r14
    5eae:	mov    QWORD PTR [rsp+0x70],r15
    5eb3:	mov    r14,rbx
    5eb6:	mov    r15,QWORD PTR [rsp+0x80]
    5ebe:	mov    DWORD PTR [rsp+0x1c],edx
    5ec2:	mov    QWORD PTR [rsp+0x10],r8
    5ec7:	mov    rbx,QWORD PTR [rsp+0x90]
    5ecf:	lea    rcx,[rsp+0x30]
    5ed4:	mov    QWORD PTR [rsp+0x50],rbp
    5ed9:	mov    QWORD PTR [rsp+0x58],r12
    5ede:	mov    QWORD PTR [rsp+0x60],r13
    5ee3:	lea    r12d,[rdi-0x1]
    5ee7:	lea    ebp,[rsi-0x1]
    5eea:	xor    r13d,r13d
    5eed:	vmovq  xmm16,rcx
    5ef3:	xchg   ax,ax
    5ef5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f00:	mov    rax,QWORD PTR [rsp+0x10]
    5f05:	mov    rcx,QWORD PTR [rsp+0x8]
    5f0a:	mov    rsi,QWORD PTR [rsp+0x88]
    5f12:	mov    rdi,QWORD PTR [rsp+0x98]
    5f1a:	inc    r13d
    5f1d:	lea    rax,[rsp+0x20]
    5f22:	lea    rdx,[rsp+0x28]
    5f27:	vmovq  rsi,xmm16
    5f2d:	mov    rdi,rbx
    5f30:	mov    r9,rdx
    5f33:	mov    rcx,rsi
    5f36:	mov    rdx,r14
    5f39:	mov    rsi,rax
    5f3c:	mov    r8,r15
    5f3f:	mov    DWORD PTR [rsp+0x28],0x0
    5f47:	mov    DWORD PTR [rsp+0x2c],ebp
    5f4b:	mov    DWORD PTR [rsp+0x30],0x0
    5f53:	mov    DWORD PTR [rsp+0x34],r12d
    5f58:	mov    DWORD PTR [rsp+0x38],0x0
    5f60:	mov    DWORD PTR [rsp+0x3c],ebp
    5f64:	mov    DWORD PTR [rsp+0x20],0x0
    5f6c:	mov    DWORD PTR [rsp+0x24],r12d
    5f71:	call   4280 <mj__matrices__mulmatvec>
    5f76:	mov    rax,QWORD PTR [rsp+0x10]
    5f7b:	mov    rcx,QWORD PTR [rsp+0x8]
    5f80:	mov    rdi,QWORD PTR [rsp+0x88]
    5f88:	mov    rdx,QWORD PTR [rsp+0x98]
    5f90:	cmp    DWORD PTR [rsp+0x1c],r13d
    5f95:	jne    5f00 <bench_ada__run_7.isra.0+0x70>
    5f9b:	mov    rbx,QWORD PTR [rsp+0x48]
    5fa0:	mov    rbp,QWORD PTR [rsp+0x50]
    5fa5:	mov    r12,QWORD PTR [rsp+0x58]
    5faa:	mov    r13,QWORD PTR [rsp+0x60]
    5faf:	mov    r14,QWORD PTR [rsp+0x68]
    5fb4:	mov    r15,QWORD PTR [rsp+0x70]
    5fb9:	add    rsp,0x78
    5fbd:	ret
    5fbe:	xchg   ax,ax


<bench_ada__run_8.isra.0>:
    a0a0:	sub    rsp,0x68
    a0a4:	mov    QWORD PTR [rsp+0x50],r13
    a0a9:	mov    r13,QWORD PTR [rsp+0x80]
    a0b1:	test   edx,edx
    a0b3:	je     a197 <bench_ada__run_8.isra.0+0xf7>
    a0b9:	lea    eax,[rsi-0x1]
    a0bc:	mov    DWORD PTR [rsp+0xc],edx
    a0c0:	mov    QWORD PTR [rsp+0x38],rbx
    a0c5:	mov    QWORD PTR [rsp+0x40],rbp
    a0ca:	mov    DWORD PTR [rsp+0x8],eax
    a0ce:	mov    QWORD PTR [rsp+0x48],r12
    a0d3:	mov    QWORD PTR [rsp+0x58],r14
    a0d8:	mov    QWORD PTR [rsp+0x60],r15
    a0dd:	mov    rbx,rcx
    a0e0:	mov    r15,r8
    a0e3:	mov    rbp,r9
    a0e6:	lea    r14d,[rdi-0x1]
    a0ea:	xor    r12d,r12d
    a0ed:	nop    DWORD PTR [rax]
    a0f0:	mov    rax,QWORD PTR [rsp+0x70]
    a0f5:	mov    rcx,QWORD PTR [rsp+0x78]
    a0fa:	mov    rsi,QWORD PTR [rsp+0x88]
    a102:	inc    r12d
    a105:	lea    rax,[rsp+0x18]
    a10a:	lea    rcx,[rsp+0x20]
    a10f:	mov    rdi,r13
    a112:	mov    rdx,rbx
    a115:	mov    r11,rax
    a118:	mov    eax,DWORD PTR [rsp+0x8]
    a11c:	mov    r8,rbp
    a11f:	mov    DWORD PTR [rsp+0x18],0x0
    a127:	mov    r9,r11
    a12a:	mov    DWORD PTR [rsp+0x1c],r14d
    a12f:	mov    DWORD PTR [rsp+0x20],0x0
    a137:	mov    DWORD PTR [rsp+0x24],r14d
    a13c:	mov    DWORD PTR [rsp+0x28],0x0
    a144:	mov    DWORD PTR [rsp+0x10],0x0
    a14c:	mov    DWORD PTR [rsp+0x2c],eax
    a150:	mov    DWORD PTR [rsp+0x14],eax
    a154:	lea    rax,[rsp+0x10]
    a159:	mov    rsi,rax
    a15c:	call   9c50 <mj__matrices__mulmattvec>
    a161:	mov    rax,QWORD PTR [rsp+0x70]
    a166:	mov    rdi,QWORD PTR [rsp+0x78]
    a16b:	mov    rcx,QWORD PTR [rsp+0x88]
    a173:	cmp    DWORD PTR [rsp+0xc],r12d
    a178:	jne    a0f0 <bench_ada__run_8.isra.0+0x50>
    a17e:	mov    rbx,QWORD PTR [rsp+0x38]
    a183:	mov    rbp,QWORD PTR [rsp+0x40]
    a188:	mov    r12,QWORD PTR [rsp+0x48]
    a18d:	mov    r14,QWORD PTR [rsp+0x58]
    a192:	mov    r15,QWORD PTR [rsp+0x60]
    a197:	mov    r13,QWORD PTR [rsp+0x50]
    a19c:	add    rsp,0x68
    a1a0:	ret
    a1a1:	nop
    a1a2:	nop    DWORD PTR [rax]
    a1a5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_9.isra.0>:
    5fc0:	vxorpd xmm16,xmm16,xmm16
    5fc6:	test   esi,esi
    5fc8:	je     60c6 <bench_ada__run_9.isra.0+0x106>
    5fce:	push   r15
    5fd0:	push   r14
    5fd2:	push   r13
    5fd4:	push   r12
    5fd6:	push   rbp
    5fd7:	push   rbx
    5fd8:	mov    r15,rcx
    5fdb:	lea    ebx,[rdi-0x1]
    5fde:	sub    rsp,0x38
    5fe2:	xor    r14d,r14d
    5fe5:	mov    r12,r8
    5fe8:	mov    rbp,rdx
    5feb:	mov    DWORD PTR [rsp+0xc],esi
    5fef:	lea    rax,[rsp+0x18]
    5ff4:	mov    r13,r9
    5ff7:	vmovq  xmm19,rax
    5ffd:	lea    rax,[rsp+0x20]
    6002:	vmovq  xmm18,rax
    6008:	lea    rax,[rsp+0x10]
    600d:	vmovq  xmm17,rax
    6013:	xchg   ax,ax
    6015:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6020:	mov    rax,QWORD PTR [rsp+0x70]
    6025:	mov    rcx,QWORD PTR [rsp+0x78]
    602a:	mov    rdx,QWORD PTR [rsp+0x80]
    6032:	inc    r14d
    6035:	vmovq  rax,xmm19
    603b:	vmovq  rdx,xmm17
    6041:	mov    r8,r13
    6044:	mov    rdi,r12
    6047:	mov    r9,rax
    604a:	vmovq  rax,xmm18
    6050:	mov    rsi,rdx
    6053:	mov    rdx,rbp
    6056:	mov    rcx,rax
    6059:	mov    DWORD PTR [rsp+0x18],0x0
    6061:	mov    DWORD PTR [rsp+0x1c],ebx
    6065:	mov    DWORD PTR [rsp+0x20],0x0
    606d:	mov    DWORD PTR [rsp+0x24],ebx
    6071:	mov    DWORD PTR [rsp+0x28],0x0
    6079:	mov    DWORD PTR [rsp+0x2c],ebx
    607d:	mov    DWORD PTR [rsp+0x10],0x0
    6085:	mov    DWORD PTR [rsp+0x14],ebx
    6089:	call   4800 <mj__matrices__mulvecmatvec>
    608e:	mov    rax,QWORD PTR [rsp+0x70]
    6093:	mov    rcx,QWORD PTR [rsp+0x78]
    6098:	mov    rsi,QWORD PTR [rsp+0x80]
    60a0:	vaddsd xmm16,xmm16,xmm0
    60a6:	cmp    DWORD PTR [rsp+0xc],r14d
    60ab:	jne    6020 <bench_ada__run_9.isra.0+0x60>
    60b1:	add    rsp,0x38
    60b5:	vmovapd xmm0,xmm16
    60bb:	pop    rbx
    60bc:	pop    rbp
    60bd:	pop    r12
    60bf:	pop    r13
    60c1:	pop    r14
    60c3:	pop    r15
    60c5:	ret
    60c6:	vmovapd xmm0,xmm16
    60cc:	ret
    60cd:	nop
    60ce:	xchg   ax,ax


<bench_ada_baseline__run_1.isra.0>:
    7310:	push   rbp
    7311:	mov    r10,rdx
    7314:	mov    rbp,rsp
    7317:	push   rbx
    7318:	sub    rsp,0x8
    731c:	mov    rdx,QWORD PTR [rbp+0x10]
    7320:	mov    rbx,QWORD PTR [rbp+0x18]
    7324:	test   edi,edi
    7326:	je     735e <bench_ada_baseline__run_1.isra.0+0x4e>
    7328:	mov    rax,rsi
    732b:	mov    r11d,edi
    732e:	xor    esi,esi
    7330:	inc    esi
    7332:	vmovdqu64 zmm0,ZMMWORD PTR [rax]
    7338:	mov    rdi,QWORD PTR [rax+0x40]
    733c:	mov    QWORD PTR [rsp-0x10],rdi
    7341:	vmovdqu64 ZMMWORD PTR [rdx],zmm0
    7347:	mov    QWORD PTR [rdx+0x40],rdi
    734b:	vmovdqu64 ZMMWORD PTR [rsp-0x50],zmm0
    7356:	cmp    r11d,esi
    7359:	jne    7330 <bench_ada_baseline__run_1.isra.0+0x20>
    735b:	vzeroupper
    735e:	add    rsp,0x8
    7362:	pop    rbx
    7363:	pop    rbp
    7364:	ret
    7365:	nop
    7366:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_10.isra.0>:
    7b20:	sub    rsp,0x30
    7b24:	mov    DWORD PTR [rsp-0x10],edx
    7b28:	test   edx,edx
    7b2a:	je     7d3d <bench_ada_baseline__run_10.isra.0+0x21d>
    7b30:	mov    rdx,r9
    7b33:	mov    r9d,edi
    7b36:	mov    QWORD PTR [rsp],rbx
    7b3a:	mov    ebx,esi
    7b3c:	mov    r11,r9
    7b3f:	mov    QWORD PTR [rsp+0x28],r15
    7b44:	mov    r10,rcx
    7b47:	lea    ecx,[rdi-0x1]
    7b4a:	and    r11d,0xfffffffe
    7b4e:	movsxd rdi,ecx
    7b51:	mov    rax,r8
    7b54:	mov    QWORD PTR [rsp+0x18],r13
    7b59:	mov    r15,r11
    7b5c:	mov    QWORD PTR [rsp-0x28],rdi
    7b61:	lea    r13,[rbx*8+0x0]
    7b69:	mov    QWORD PTR [rsp+0x8],rbp
    7b6e:	mov    QWORD PTR [rsp+0x20],r14
    7b73:	mov    QWORD PTR [rsp-0x20],rax
    7b78:	mov    rbp,QWORD PTR [rsp-0x28]
    7b7d:	mov    DWORD PTR [rsp-0xc],esi
    7b81:	lea    r8,[r9*8+0x0]
    7b89:	mov    QWORD PTR [rsp+0x10],r12
    7b8e:	mov    r12,r13
    7b91:	imul   r11,rbx
    7b95:	mov    QWORD PTR [rsp-0x18],r8
    7b9a:	mov    r8d,ecx
    7b9d:	mov    rcx,rdx
    7ba0:	imul   rdi,r13
    7ba4:	vmovq  xmm3,r11
    7ba9:	xor    r11d,r11d
    7bac:	mov    DWORD PTR [rsp-0x2c],r11d
    7bb1:	mov    r11,QWORD PTR [rsp+0x48]
    7bb6:	vmovq  xmm5,rdi
    7bbb:	mov    rdi,r9
    7bbe:	shr    rdi,1
    7bc1:	inc    DWORD PTR [rsp-0x2c]
    7bc5:	mov    rax,QWORD PTR [rsp-0x20]
    7bca:	mov    rsi,QWORD PTR [rsp+0x38]
    7bcf:	mov    rdx,QWORD PTR [rsp+0x40]
    7bd4:	mov    r14,QWORD PTR [rsp+0x50]
    7bd9:	cmp    DWORD PTR [rsp-0xc],0x0
    7bde:	je     7e32 <bench_ada_baseline__run_10.isra.0+0x312>
    7be4:	cmp    r8d,0xffffffff
    7be8:	je     7df7 <bench_ada_baseline__run_10.isra.0+0x2d7>
    7bee:	mov    r14,QWORD PTR [rsp-0x18]
    7bf3:	mov    DWORD PTR [rsp-0x28],r8d
    7bf8:	mov    rsi,rcx
    7bfb:	shr    r14,0x3
    7bff:	mov    rcx,r14
    7c02:	mov    r8,rcx
    7c05:	mov    rax,rsi
    7c08:	xor    ecx,ecx
    7c0a:	mov    rsi,r10
    7c0d:	vmovdqa xmm1,xmm5
    7c11:	cmp    rbp,0xe
    7c15:	jbe    7d4e <bench_ada_baseline__run_10.isra.0+0x22e>
    7c1b:	mov    r14,rax
    7c1e:	mov    rax,r8
    7c21:	mov    r8,rsi
    7c24:	mov    rsi,rcx
    7c27:	mov    rdx,rax
    7c2a:	imul   rdx,rsi
    7c2e:	lea    r13,[r11+rdx*8]
    7c32:	add    rdx,rbp
    7c35:	lea    rdx,[r11+rdx*8]
    7c39:	cmp    rdx,r8
    7c3c:	jb     7c50 <bench_ada_baseline__run_10.isra.0+0x130>
    7c3e:	vmovq  rcx,xmm1
    7c43:	lea    rdx,[rcx+r8*1]
    7c47:	cmp    rdx,r13
    7c4a:	jae    7d42 <bench_ada_baseline__run_10.isra.0+0x222>
    7c50:	mov    rdx,r8
    7c53:	xor    ecx,ecx
    7c55:	cs nop WORD PTR [rax+rax*1+0x0]
    7c5f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7c6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7c75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7c80:	vmovsd xmm0,QWORD PTR [rdx]
    7c84:	vmovhpd xmm0,xmm0,QWORD PTR [rdx+r12*1]
    7c8a:	inc    rcx
    7c8d:	lea    rdx,[rdx+r12*2]
    7c91:	add    r13,0x10
    7c95:	vmovupd XMMWORD PTR [r13-0x10],xmm0
    7c9b:	cmp    rcx,rdi
    7c9e:	jb     7c80 <bench_ada_baseline__run_10.isra.0+0x160>
    7ca0:	cmp    r9,r15
    7ca3:	je     7ce0 <bench_ada_baseline__run_10.isra.0+0x1c0>
    7ca5:	vmovq  rcx,xmm3
    7caa:	lea    rdx,[rcx+rsi*1]
    7cae:	vmovsd xmm0,QWORD PTR [r10+rdx*8]
    7cb4:	mov    rdx,rax
    7cb7:	imul   rdx,rsi
    7cbb:	inc    rsi
    7cbe:	add    rdx,r15
    7cc1:	vmovsd QWORD PTR [r11+rdx*8],xmm0
    7cc7:	cmp    rbx,rsi
    7cca:	je     7ce8 <bench_ada_baseline__run_10.isra.0+0x1c8>
    7ccc:	add    r8,0x8
    7cd0:	jmp    7c27 <bench_ada_baseline__run_10.isra.0+0x107>
    7cd5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7ce0:	inc    rsi
    7ce3:	cmp    rbx,rsi
    7ce6:	jne    7ccc <bench_ada_baseline__run_10.isra.0+0x1ac>
    7ce8:	mov    rcx,r14
    7ceb:	mov    r8d,DWORD PTR [rsp-0x28]
    7cf0:	mov    rax,QWORD PTR [rsp-0x20]
    7cf5:	mov    rsi,QWORD PTR [rsp+0x38]
    7cfa:	mov    rdx,QWORD PTR [rsp+0x40]
    7cff:	mov    r14,QWORD PTR [rsp+0x50]
    7d04:	mov    esi,DWORD PTR [rsp-0x2c]
    7d08:	cmp    DWORD PTR [rsp-0x10],esi
    7d0c:	jne    7bc1 <bench_ada_baseline__run_10.isra.0+0xa1>
    7d12:	nop    DWORD PTR [rax]
    7d15:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7d20:	mov    rbx,QWORD PTR [rsp]
    7d24:	mov    rbp,QWORD PTR [rsp+0x8]
    7d29:	mov    r12,QWORD PTR [rsp+0x10]
    7d2e:	mov    r13,QWORD PTR [rsp+0x18]
    7d33:	mov    r14,QWORD PTR [rsp+0x20]
    7d38:	mov    r15,QWORD PTR [rsp+0x28]
    7d3d:	add    rsp,0x30
    7d41:	ret
    7d42:	mov    rcx,rsi
    7d45:	mov    rsi,r8
    7d48:	mov    r8,rax
    7d4b:	mov    rax,r14
    7d4e:	mov    rdx,r8
    7d51:	mov    r14,rdi
    7d54:	mov    rdi,rax
    7d57:	imul   rdx,rcx
    7d5b:	lea    r13,[r11+rdx*8]
    7d5f:	xor    edx,edx
    7d61:	nop    WORD PTR [rax+rax*1+0x0]
    7d6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7d75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7d80:	mov    rax,rbx
    7d83:	imul   rax,rdx
    7d87:	add    rax,rcx
    7d8a:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    7d90:	vmovsd QWORD PTR [r13+rdx*8+0x0],xmm0
    7d97:	inc    rdx
    7d9a:	cmp    r9,rdx
    7d9d:	jne    7d80 <bench_ada_baseline__run_10.isra.0+0x260>
    7d9f:	inc    rcx
    7da2:	mov    rax,rdi
    7da5:	add    rsi,0x8
    7da9:	mov    rdi,r14
    7dac:	cmp    rbx,rcx
    7daf:	jne    7c11 <bench_ada_baseline__run_10.isra.0+0xf1>
    7db5:	mov    rcx,r8
    7db8:	mov    rsi,rax
    7dbb:	mov    rdx,QWORD PTR [rsp-0x20]
    7dc0:	mov    rax,QWORD PTR [rsp+0x38]
    7dc5:	mov    r14,QWORD PTR [rsp+0x40]
    7dca:	mov    r8,QWORD PTR [rsp+0x50]
    7dcf:	mov    eax,DWORD PTR [rsp-0x2c]
    7dd3:	cmp    DWORD PTR [rsp-0x10],eax
    7dd7:	je     7d20 <bench_ada_baseline__run_10.isra.0+0x200>
    7ddd:	inc    eax
    7ddf:	mov    r14,QWORD PTR [rsp+0x40]
    7de4:	mov    r8,QWORD PTR [rsp+0x50]
    7de9:	mov    DWORD PTR [rsp-0x2c],eax
    7ded:	mov    rax,QWORD PTR [rsp+0x38]
    7df2:	jmp    7c02 <bench_ada_baseline__run_10.isra.0+0xe2>
    7df7:	mov    rdx,rcx
    7dfa:	mov    r15d,DWORD PTR [rsp-0x2c]
    7dff:	mov    rax,QWORD PTR [rsp-0x20]
    7e04:	mov    r14,QWORD PTR [rsp+0x38]
    7e09:	mov    rbp,QWORD PTR [rsp+0x40]
    7e0e:	mov    r12,QWORD PTR [rsp+0x50]
    7e13:	mov    ecx,DWORD PTR [rsp-0x10]
    7e17:	cmp    ecx,r15d
    7e1a:	je     7d20 <bench_ada_baseline__run_10.isra.0+0x200>
    7e20:	lea    esi,[r15+0x1]
    7e24:	cmp    ecx,esi
    7e26:	je     7d20 <bench_ada_baseline__run_10.isra.0+0x200>
    7e2c:	add    r15d,0x2
    7e30:	jmp    7e17 <bench_ada_baseline__run_10.isra.0+0x2f7>
    7e32:	mov    rdx,rcx
    7e35:	mov    r15d,DWORD PTR [rsp-0x2c]
    7e3a:	mov    rax,QWORD PTR [rsp-0x20]
    7e3f:	mov    r14,QWORD PTR [rsp+0x38]
    7e44:	mov    rbp,QWORD PTR [rsp+0x40]
    7e49:	mov    r12,QWORD PTR [rsp+0x50]
    7e4e:	mov    ecx,DWORD PTR [rsp-0x10]
    7e52:	nop    DWORD PTR [rax]
    7e55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7e60:	cmp    ecx,r15d
    7e63:	je     7d20 <bench_ada_baseline__run_10.isra.0+0x200>
    7e69:	lea    esi,[r15+0x1]
    7e6d:	cmp    ecx,esi
    7e6f:	je     7d20 <bench_ada_baseline__run_10.isra.0+0x200>
    7e75:	add    r15d,0x2
    7e79:	jmp    7e60 <bench_ada_baseline__run_10.isra.0+0x340>
    7e7b:	nop
    7e7c:	nop    DWORD PTR [rax+0x0]


<bench_ada_baseline__run_11.isra.0>:
    7e80:	test   esi,esi
    7e82:	je     7f43 <bench_ada_baseline__run_11.isra.0+0xc3>
    7e88:	push   r15
    7e8a:	push   r14
    7e8c:	push   r13
    7e8e:	push   r12
    7e90:	push   rbp
    7e91:	push   rbx
    7e92:	mov    r12,rcx
    7e95:	mov    r13,r8
    7e98:	sub    rsp,0x38
    7e9c:	lea    ebx,[rdi-0x1]
    7e9f:	xor    r15d,r15d
    7ea2:	mov    r14,rdx
    7ea5:	mov    DWORD PTR [rsp+0xc],esi
    7ea9:	mov    QWORD PTR [rsp],r9
    7ead:	mov    rbp,QWORD PTR [rsp+0x78]
    7eb2:	lea    rax,[rsp+0x20]
    7eb7:	vmovq  xmm2,rax
    7ebc:	nop    DWORD PTR [rax+0x0]
    7ec0:	mov    rax,QWORD PTR [rsp]
    7ec4:	mov    rcx,QWORD PTR [rsp+0x70]
    7ec9:	mov    rdi,QWORD PTR [rsp+0x80]
    7ed1:	inc    r15d
    7ed4:	lea    rax,[rsp+0x10]
    7ed9:	vmovq  rcx,xmm2
    7ede:	mov    rdi,rbp
    7ee1:	mov    rdx,r14
    7ee4:	mov    rsi,rax
    7ee7:	mov    DWORD PTR [rsp+0x20],0x0
    7eef:	mov    DWORD PTR [rsp+0x24],ebx
    7ef3:	mov    DWORD PTR [rsp+0x28],0x0
    7efb:	mov    DWORD PTR [rsp+0x2c],ebx
    7eff:	mov    DWORD PTR [rsp+0x10],0x0
    7f07:	mov    DWORD PTR [rsp+0x14],ebx
    7f0b:	mov    DWORD PTR [rsp+0x18],0x0
    7f13:	mov    DWORD PTR [rsp+0x1c],ebx
    7f17:	call   4d60 <mj__matrices__symmetrize>
    7f1c:	mov    rax,QWORD PTR [rsp]
    7f20:	mov    rdi,QWORD PTR [rsp+0x70]
    7f25:	mov    rcx,QWORD PTR [rsp+0x80]
    7f2d:	cmp    DWORD PTR [rsp+0xc],r15d
    7f32:	jne    7ec0 <bench_ada_baseline__run_11.isra.0+0x40>
    7f34:	add    rsp,0x38
    7f38:	pop    rbx
    7f39:	pop    rbp
    7f3a:	pop    r12
    7f3c:	pop    r13
    7f3e:	pop    r14
    7f40:	pop    r15
    7f42:	ret
    7f43:	ret
    7f44:	nop
    7f45:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_12.isra.0>:
    c490:	sub    rsp,0x48
    c494:	mov    QWORD PTR [rsp+0x18],rbx
    c499:	mov    QWORD PTR [rsp+0x38],r14
    c49e:	mov    QWORD PTR [rsp+0x40],r15
    c4a3:	mov    ebx,edi
    c4a5:	mov    r14,rcx
    c4a8:	mov    r15,r8
    c4ab:	mov    rcx,QWORD PTR [rsp+0x50]
    c4b0:	mov    rdi,QWORD PTR [rsp+0x58]
    c4b5:	mov    r8,QWORD PTR [rsp+0x60]
    c4ba:	test   esi,esi
    c4bc:	je     c575 <bench_ada_baseline__run_12.isra.0+0xe5>
    c4c2:	mov    QWORD PTR [rsp+0x28],r12
    c4c7:	mov    QWORD PTR [rsp+0x30],r13
    c4cc:	mov    r12,rdx
    c4cf:	mov    r13,r9
    c4d2:	test   ebx,ebx
    c4d4:	je     c589 <bench_ada_baseline__run_12.isra.0+0xf9>
    c4da:	lea    rax,[rbx*8+0x0]
    c4e2:	mov    DWORD PTR [rsp+0xc],esi
    c4e6:	mov    rsi,rbx
    c4e9:	mov    DWORD PTR [rsp+0x8],0x1
    c4f1:	mov    QWORD PTR [rsp+0x20],rbp
    c4f6:	imul   rsi,rax
    c4fa:	shr    rax,0x3
    c4fe:	mov    QWORD PTR [rsp],rsi
    c502:	lea    rbp,[rax+0x1]
    c506:	mov    rdx,QWORD PTR [rsp]
    c50a:	xor    esi,esi
    c50c:	mov    QWORD PTR [rsp+0x60],r8
    c511:	mov    QWORD PTR [rsp+0x50],rcx
    c516:	call   2bd0 <memset@plt>
    c51b:	vmovsd xmm0,QWORD PTR [rip+0x2b665]        # 37b88 <system__os_lib__standin+0x3c>
    c523:	mov    r8,QWORD PTR [rsp+0x60]
    c528:	mov    rcx,QWORD PTR [rsp+0x50]
    c52d:	mov    rdi,rax
    c530:	xor    eax,eax
    c532:	nop    DWORD PTR [rax]
    c535:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    c540:	mov    rdx,rbp
    c543:	imul   rdx,rax
    c547:	inc    rax
    c54a:	vmovsd QWORD PTR [rdi+rdx*8],xmm0
    c54f:	cmp    rax,rbx
    c552:	jne    c540 <bench_ada_baseline__run_12.isra.0+0xb0>
    c554:	mov    eax,DWORD PTR [rsp+0x8]
    c558:	cmp    DWORD PTR [rsp+0xc],eax
    c55c:	je     c566 <bench_ada_baseline__run_12.isra.0+0xd6>
    c55e:	inc    eax
    c560:	mov    DWORD PTR [rsp+0x8],eax
    c564:	jmp    c506 <bench_ada_baseline__run_12.isra.0+0x76>
    c566:	mov    rbp,QWORD PTR [rsp+0x20]
    c56b:	mov    r12,QWORD PTR [rsp+0x28]
    c570:	mov    r13,QWORD PTR [rsp+0x30]
    c575:	mov    rbx,QWORD PTR [rsp+0x18]
    c57a:	mov    r14,QWORD PTR [rsp+0x38]
    c57f:	mov    r15,QWORD PTR [rsp+0x40]
    c584:	add    rsp,0x48
    c588:	ret
    c589:	mov    eax,0x1
    c58e:	cmp    esi,eax
    c590:	je     c56b <bench_ada_baseline__run_12.isra.0+0xdb>
    c592:	lea    edx,[rax+0x1]
    c595:	cmp    esi,edx
    c597:	je     c56b <bench_ada_baseline__run_12.isra.0+0xdb>
    c599:	add    eax,0x2
    c59c:	cmp    esi,eax
    c59e:	jne    c592 <bench_ada_baseline__run_12.isra.0+0x102>
    c5a0:	jmp    c56b <bench_ada_baseline__run_12.isra.0+0xdb>
    c5a2:	nop    DWORD PTR [rax]
    c5a5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_13.isra.0>:
    7f50:	sub    rsp,0x88
    7f57:	mov    QWORD PTR [rsp+0x78],r14
    7f5c:	mov    QWORD PTR [rsp+0x80],r15
    7f64:	mov    QWORD PTR [rsp+0x8],r8
    7f69:	mov    QWORD PTR [rsp+0x10],r9
    7f6e:	mov    r14,QWORD PTR [rsp+0xa0]
    7f76:	mov    r15,QWORD PTR [rsp+0xa8]
    7f7e:	test   edx,edx
    7f80:	je     8080 <bench_ada_baseline__run_13.isra.0+0x130>
    7f86:	mov    eax,edi
    7f88:	mov    DWORD PTR [rsp+0x1c],edx
    7f8c:	mov    QWORD PTR [rsp+0x58],rbx
    7f91:	mov    QWORD PTR [rsp+0x60],rbp
    7f96:	mov    QWORD PTR [rsp+0x68],r12
    7f9b:	mov    QWORD PTR [rsp+0x70],r13
    7fa0:	lea    ebp,[rsi-0x1]
    7fa3:	lea    ebx,[rdi-0x1]
    7fa6:	xor    r12d,r12d
    7fa9:	mov    r13,rcx
    7fac:	sar    eax,1
    7fae:	dec    eax
    7fb0:	mov    DWORD PTR [rsp+0x18],eax
    7fb4:	lea    rax,[rsp+0x40]
    7fb9:	vmovq  xmm17,rax
    7fbf:	nop
    7fc0:	mov    rax,QWORD PTR [rsp+0x8]
    7fc5:	mov    rcx,QWORD PTR [rsp+0x10]
    7fca:	mov    rdi,QWORD PTR [rsp+0x90]
    7fd2:	mov    rsi,QWORD PTR [rsp+0x98]
    7fda:	inc    r12d
    7fdd:	mov    edi,DWORD PTR [rsp+0x18]
    7fe1:	lea    rdx,[rsp+0x28]
    7fe6:	vmovq  rsi,xmm17
    7fec:	mov    r8,r15
    7fef:	mov    r9,rdx
    7ff2:	mov    rcx,rsi
    7ff5:	mov    rdx,r13
    7ff8:	mov    DWORD PTR [rsp+0x28],0x0
    8000:	mov    DWORD PTR [rsp+0x40],0x0
    8008:	mov    DWORD PTR [rsp+0x44],ebx
    800c:	mov    DWORD PTR [rsp+0x48],0x0
    8014:	mov    DWORD PTR [rsp+0x4c],ebp
    8018:	mov    DWORD PTR [rsp+0x30],0x0
    8020:	mov    DWORD PTR [rsp+0x34],ebx
    8024:	mov    DWORD PTR [rsp+0x38],0x0
    802c:	mov    DWORD PTR [rsp+0x3c],ebp
    8030:	mov    DWORD PTR [rsp+0x2c],edi
    8034:	lea    rdi,[rsp+0x30]
    8039:	mov    r11,rdi
    803c:	mov    rdi,r14
    803f:	mov    rsi,r11
    8042:	call   5630 <mj__matrices__copyrows>
    8047:	mov    rax,QWORD PTR [rsp+0x8]
    804c:	mov    rcx,QWORD PTR [rsp+0x10]
    8051:	mov    rdx,QWORD PTR [rsp+0x90]
    8059:	mov    rsi,QWORD PTR [rsp+0x98]
    8061:	cmp    DWORD PTR [rsp+0x1c],r12d
    8066:	jne    7fc0 <bench_ada_baseline__run_13.isra.0+0x70>
    806c:	mov    rbx,QWORD PTR [rsp+0x58]
    8071:	mov    rbp,QWORD PTR [rsp+0x60]
    8076:	mov    r12,QWORD PTR [rsp+0x68]
    807b:	mov    r13,QWORD PTR [rsp+0x70]
    8080:	mov    r14,QWORD PTR [rsp+0x78]
    8085:	mov    r15,QWORD PTR [rsp+0x80]
    808d:	add    rsp,0x88
    8094:	ret
    8095:	nop
    8096:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_14.isra.0>:
    a600:	sub    rsp,0x78
    a604:	mov    QWORD PTR [rsp+0x60],r13
    a609:	mov    r13,QWORD PTR [rsp+0x98]
    a611:	test   ecx,ecx
    a613:	je     a72d <bench_ada_baseline__run_14.isra.0+0x12d>
    a619:	lea    eax,[rdx-0x1]
    a61c:	mov    DWORD PTR [rsp+0xc],ecx
    a620:	mov    QWORD PTR [rsp+0x48],rbx
    a625:	mov    QWORD PTR [rsp+0x50],rbp
    a62a:	mov    DWORD PTR [rsp+0x8],eax
    a62e:	mov    QWORD PTR [rsp+0x58],r12
    a633:	mov    QWORD PTR [rsp+0x68],r14
    a638:	mov    QWORD PTR [rsp+0x70],r15
    a63d:	mov    rbx,r8
    a640:	mov    rbp,r9
    a643:	lea    r14d,[rdi-0x1]
    a647:	lea    r15d,[rsi-0x1]
    a64b:	xor    r12d,r12d
    a64e:	xchg   ax,ax
    a650:	mov    rax,QWORD PTR [rsp+0x80]
    a658:	mov    rcx,QWORD PTR [rsp+0x88]
    a660:	mov    rsi,QWORD PTR [rsp+0x90]
    a668:	mov    rdi,QWORD PTR [rsp+0xa0]
    a670:	inc    r12d
    a673:	mov    eax,DWORD PTR [rsp+0x8]
    a677:	lea    rcx,[rsp+0x30]
    a67c:	mov    rdx,rbx
    a67f:	mov    rdi,r13
    a682:	mov    r11,rcx
    a685:	mov    r8,rbp
    a688:	lea    rcx,[rsp+0x20]
    a68d:	mov    DWORD PTR [rsp+0x30],0x0
    a695:	mov    r9,r11
    a698:	mov    DWORD PTR [rsp+0x34],r15d
    a69d:	mov    DWORD PTR [rsp+0x38],0x0
    a6a5:	mov    DWORD PTR [rsp+0x20],0x0
    a6ad:	mov    DWORD PTR [rsp+0x24],r14d
    a6b2:	mov    DWORD PTR [rsp+0x28],0x0
    a6ba:	mov    DWORD PTR [rsp+0x2c],r15d
    a6bf:	mov    DWORD PTR [rsp+0x10],0x0
    a6c7:	mov    DWORD PTR [rsp+0x14],r14d
    a6cc:	mov    DWORD PTR [rsp+0x18],0x0
    a6d4:	mov    DWORD PTR [rsp+0x3c],eax
    a6d8:	mov    DWORD PTR [rsp+0x1c],eax
    a6dc:	lea    rax,[rsp+0x10]
    a6e1:	mov    rsi,rax
    a6e4:	call   a1b0 <mj__matrices__mulmatmat>
    a6e9:	mov    rax,QWORD PTR [rsp+0x80]
    a6f1:	mov    rdx,QWORD PTR [rsp+0x88]
    a6f9:	mov    rsi,QWORD PTR [rsp+0x90]
    a701:	mov    rdi,QWORD PTR [rsp+0xa0]
    a709:	cmp    DWORD PTR [rsp+0xc],r12d
    a70e:	jne    a650 <bench_ada_baseline__run_14.isra.0+0x50>
    a714:	mov    rbx,QWORD PTR [rsp+0x48]
    a719:	mov    rbp,QWORD PTR [rsp+0x50]
    a71e:	mov    r12,QWORD PTR [rsp+0x58]
    a723:	mov    r14,QWORD PTR [rsp+0x68]
    a728:	mov    r15,QWORD PTR [rsp+0x70]
    a72d:	mov    r13,QWORD PTR [rsp+0x60]
    a732:	add    rsp,0x78
    a736:	ret
    a737:	nop
    a738:	nop    DWORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_15.isra.0>:
    acd0:	sub    rsp,0x78
    acd4:	mov    QWORD PTR [rsp+0x60],r13
    acd9:	mov    r13,QWORD PTR [rsp+0x98]
    ace1:	test   ecx,ecx
    ace3:	je     adfd <bench_ada_baseline__run_15.isra.0+0x12d>
    ace9:	lea    eax,[rdx-0x1]
    acec:	mov    DWORD PTR [rsp+0xc],ecx
    acf0:	mov    QWORD PTR [rsp+0x48],rbx
    acf5:	mov    QWORD PTR [rsp+0x50],rbp
    acfa:	mov    DWORD PTR [rsp+0x8],eax
    acfe:	mov    QWORD PTR [rsp+0x58],r12
    ad03:	mov    QWORD PTR [rsp+0x68],r14
    ad08:	mov    QWORD PTR [rsp+0x70],r15
    ad0d:	mov    rbx,r8
    ad10:	mov    rbp,r9
    ad13:	lea    r14d,[rdi-0x1]
    ad17:	lea    r15d,[rsi-0x1]
    ad1b:	xor    r12d,r12d
    ad1e:	xchg   ax,ax
    ad20:	mov    rax,QWORD PTR [rsp+0x80]
    ad28:	mov    rcx,QWORD PTR [rsp+0x88]
    ad30:	mov    rsi,QWORD PTR [rsp+0x90]
    ad38:	mov    rdi,QWORD PTR [rsp+0xa0]
    ad40:	inc    r12d
    ad43:	mov    eax,DWORD PTR [rsp+0x8]
    ad47:	lea    rcx,[rsp+0x30]
    ad4c:	mov    rdx,rbx
    ad4f:	mov    rdi,r13
    ad52:	mov    r11,rcx
    ad55:	mov    r8,rbp
    ad58:	lea    rcx,[rsp+0x20]
    ad5d:	mov    DWORD PTR [rsp+0x30],0x0
    ad65:	mov    r9,r11
    ad68:	mov    DWORD PTR [rsp+0x34],r14d
    ad6d:	mov    DWORD PTR [rsp+0x38],0x0
    ad75:	mov    DWORD PTR [rsp+0x20],0x0
    ad7d:	mov    DWORD PTR [rsp+0x24],r14d
    ad82:	mov    DWORD PTR [rsp+0x28],0x0
    ad8a:	mov    DWORD PTR [rsp+0x2c],r15d
    ad8f:	mov    DWORD PTR [rsp+0x10],0x0
    ad97:	mov    DWORD PTR [rsp+0x14],r15d
    ad9c:	mov    DWORD PTR [rsp+0x18],0x0
    ada4:	mov    DWORD PTR [rsp+0x3c],eax
    ada8:	mov    DWORD PTR [rsp+0x1c],eax
    adac:	lea    rax,[rsp+0x10]
    adb1:	mov    rsi,rax
    adb4:	call   a880 <mj__matrices__mulmattmat>
    adb9:	mov    rax,QWORD PTR [rsp+0x80]
    adc1:	mov    rdx,QWORD PTR [rsp+0x88]
    adc9:	mov    rsi,QWORD PTR [rsp+0x90]
    add1:	mov    rdi,QWORD PTR [rsp+0xa0]
    add9:	cmp    DWORD PTR [rsp+0xc],r12d
    adde:	jne    ad20 <bench_ada_baseline__run_15.isra.0+0x50>
    ade4:	mov    rbx,QWORD PTR [rsp+0x48]
    ade9:	mov    rbp,QWORD PTR [rsp+0x50]
    adee:	mov    r12,QWORD PTR [rsp+0x58]
    adf3:	mov    r14,QWORD PTR [rsp+0x68]
    adf8:	mov    r15,QWORD PTR [rsp+0x70]
    adfd:	mov    r13,QWORD PTR [rsp+0x60]
    ae02:	add    rsp,0x78
    ae06:	ret
    ae07:	nop
    ae08:	nop    DWORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_16.isra.0>:
    80a0:	push   rbp
    80a1:	mov    rbp,rsp
    80a4:	push   r15
    80a6:	push   r14
    80a8:	push   r13
    80aa:	push   r12
    80ac:	push   rbx
    80ad:	mov    rbx,r9
    80b0:	and    rsp,0xffffffffffffffe0
    80b4:	add    rsp,0xffffffffffffff80
    80b8:	mov    r9,QWORD PTR [rbp+0x30]
    80bc:	test   ecx,ecx
    80be:	je     8269 <bench_ada_baseline__run_16.isra.0+0x1c9>
    80c4:	mov    eax,edx
    80c6:	mov    r11d,edi
    80c9:	mov    DWORD PTR [rsp+0x50],ecx
    80cd:	lea    ecx,[rdi-0x1]
    80d0:	mov    DWORD PTR [rsp+0x54],ecx
    80d4:	mov    QWORD PTR [rsp+0x38],rax
    80d9:	lea    rcx,[rax*8+0x0]
    80e1:	mov    eax,r11d
    80e4:	mov    r14,QWORD PTR [rbp+0x28]
    80e8:	mov    QWORD PTR [rsp+0x18],rax
    80ed:	mov    QWORD PTR [rsp+0x48],rcx
    80f2:	mov    DWORD PTR [rsp+0x30],esi
    80f6:	mov    DWORD PTR [rsp+0x34],edi
    80fa:	lea    r12d,[rsi-0x1]
    80fe:	lea    edi,[rdx-0x1]
    8101:	mov    r15,r8
    8104:	xor    esi,esi
    8106:	cs nop WORD PTR [rax+rax*1+0x0]
    8110:	mov    rax,QWORD PTR [rbp+0x10]
    8114:	mov    rcx,QWORD PTR [rbp+0x18]
    8118:	mov    rdx,QWORD PTR [rbp+0x20]
    811c:	inc    esi
    811e:	mov    eax,DWORD PTR [rsp+0x54]
    8122:	mov    DWORD PTR [rsp+0x70],0x0
    812a:	mov    DWORD PTR [rsp+0x74],edi
    812e:	mov    DWORD PTR [rsp+0x78],0x0
    8136:	mov    DWORD PTR [rsp+0x7c],r12d
    813b:	mov    DWORD PTR [rsp+0x60],0x0
    8143:	mov    DWORD PTR [rsp+0x68],0x0
    814b:	mov    DWORD PTR [rsp+0x6c],r12d
    8150:	mov    DWORD PTR [rsp+0x64],eax
    8154:	cmp    edi,0xffffffff
    8157:	je     8250 <bench_ada_baseline__run_16.isra.0+0x1b0>
    815d:	cmp    eax,0xffffffff
    8160:	je     8250 <bench_ada_baseline__run_16.isra.0+0x1b0>
    8166:	cmp    r12d,0xffffffff
    816a:	je     8278 <bench_ada_baseline__run_16.isra.0+0x1d8>
    8170:	mov    eax,DWORD PTR [rsp+0x30]
    8174:	cmp    eax,0x3
    8177:	je     84ed <bench_ada_baseline__run_16.isra.0+0x44d>
    817d:	jg     82e4 <bench_ada_baseline__run_16.isra.0+0x244>
    8183:	dec    eax
    8185:	je     846e <bench_ada_baseline__run_16.isra.0+0x3ce>
    818b:	mov    eax,DWORD PTR [rsp+0x34]
    818f:	mov    QWORD PTR [rbp+0x30],r9
    8193:	mov    rcx,QWORD PTR [rsp+0x48]
    8198:	mov    r9d,esi
    819b:	mov    rsi,QWORD PTR [rbp+0x30]
    819f:	mov    r11,r14
    81a2:	mov    r13,0xffffffffffffffff
    81a9:	vxorpd xmm2,xmm2,xmm2
    81ad:	dec    rax
    81b0:	mov    QWORD PTR [rsp+0x58],rax
    81b5:	mov    rax,QWORD PTR [rsp+0x38]
    81ba:	lea    r8,[rax-0x1]
    81be:	inc    r13
    81c1:	mov    rdx,0xffffffffffffffff
    81c8:	movsxd r10,r13d
    81cb:	shl    r10,0x4
    81cf:	add    r10,r15
    81d2:	xchg   ax,ax
    81d4:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    81df:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    81ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    81f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8200:	inc    rdx
    8203:	movsxd rax,edx
    8206:	shl    rax,0x4
    820a:	add    rax,rbx
    820d:	vmovsd xmm0,QWORD PTR [rax]
    8211:	vmulsd xmm0,xmm0,QWORD PTR [r10]
    8216:	vmovsd xmm1,QWORD PTR [rax+0x8]
    821b:	vmulsd xmm1,xmm1,QWORD PTR [r10+0x8]
    8221:	vaddsd xmm0,xmm0,xmm1
    8225:	vaddsd xmm0,xmm0,xmm2
    8229:	vmovsd QWORD PTR [r11+rdx*8],xmm0
    822f:	cmp    rdx,r8
    8232:	jne    8200 <bench_ada_baseline__run_16.isra.0+0x160>
    8234:	add    r11,rcx
    8237:	cmp    r13,QWORD PTR [rsp+0x58]
    823c:	jne    81be <bench_ada_baseline__run_16.isra.0+0x11e>
    8242:	mov    QWORD PTR [rbp+0x30],rsi
    8246:	mov    esi,r9d
    8249:	mov    r9,QWORD PTR [rbp+0x30]
    824d:	nop    DWORD PTR [rax]
    8250:	mov    rax,QWORD PTR [rbp+0x10]
    8254:	mov    rcx,QWORD PTR [rbp+0x18]
    8258:	mov    rdx,QWORD PTR [rbp+0x20]
    825c:	cmp    DWORD PTR [rsp+0x50],esi
    8260:	jne    8110 <bench_ada_baseline__run_16.isra.0+0x70>
    8266:	vzeroupper
    8269:	lea    rsp,[rbp-0x28]
    826d:	pop    rbx
    826e:	pop    r12
    8270:	pop    r13
    8272:	pop    r14
    8274:	pop    r15
    8276:	pop    rbp
    8277:	ret
    8278:	mov    DWORD PTR [rsp+0x58],r12d
    827d:	mov    QWORD PTR [rsp+0x20],rbx
    8282:	mov    DWORD PTR [rsp+0x40],edi
    8286:	mov    DWORD PTR [rsp+0x28],esi
    828a:	mov    QWORD PTR [rbp+0x30],r9
    828e:	xor    r12d,r12d
    8291:	mov    rbx,QWORD PTR [rsp+0x48]
    8296:	mov    r13,QWORD PTR [rsp+0x18]
    829b:	mov    r10,r14
    829e:	vzeroupper
    82a1:	nop    DWORD PTR [rax+0x0]
    82a5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    82b0:	mov    rdi,r10
    82b3:	mov    rdx,rbx
    82b6:	xor    esi,esi
    82b8:	inc    r12
    82bb:	call   2bd0 <memset@plt>
    82c0:	lea    r10,[rax+rbx*1]
    82c4:	cmp    r13,r12
    82c7:	jne    82b0 <bench_ada_baseline__run_16.isra.0+0x210>
    82c9:	mov    r12d,DWORD PTR [rsp+0x58]
    82ce:	mov    edi,DWORD PTR [rsp+0x40]
    82d2:	mov    esi,DWORD PTR [rsp+0x28]
    82d6:	mov    rbx,QWORD PTR [rsp+0x20]
    82db:	mov    r9,QWORD PTR [rbp+0x30]
    82df:	jmp    8250 <bench_ada_baseline__run_16.isra.0+0x1b0>
    82e4:	cmp    DWORD PTR [rsp+0x30],0x4
    82e9:	jne    838f <bench_ada_baseline__run_16.isra.0+0x2ef>
    82ef:	mov    eax,DWORD PTR [rsp+0x34]
    82f3:	mov    QWORD PTR [rbp+0x30],r9
    82f7:	mov    rcx,QWORD PTR [rsp+0x48]
    82fc:	mov    r9d,esi
    82ff:	mov    rsi,QWORD PTR [rbp+0x30]
    8303:	mov    r11,r14
    8306:	xor    r13d,r13d
    8309:	mov    QWORD PTR [rsp+0x58],rax
    830e:	mov    rax,QWORD PTR [rsp+0x38]
    8313:	lea    r8,[rax-0x1]
    8317:	movsxd r10,r13d
    831a:	mov    rax,0xffffffffffffffff
    8321:	shl    r10,0x5
    8325:	add    r10,r15
    8328:	xchg   ax,ax
    832a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8335:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8340:	inc    rax
    8343:	vmovupd ymm0,YMMWORD PTR [r10]
    8348:	movsxd rdx,eax
    834b:	shl    rdx,0x5
    834f:	vmulpd ymm0,ymm0,YMMWORD PTR [rdx+rbx*1]
    8354:	vextractf64x2 xmm2,ymm0,0x1
    835b:	vunpckhpd xmm1,xmm0,xmm0
    835f:	vaddsd xmm2,xmm2,xmm0
    8363:	valignq ymm0,ymm0,ymm0,0x3
    836a:	vaddsd xmm1,xmm1,xmm0
    836e:	vaddsd xmm1,xmm2,xmm1
    8372:	vmovsd QWORD PTR [r11+rax*8],xmm1
    8378:	cmp    rax,r8
    837b:	jne    8340 <bench_ada_baseline__run_16.isra.0+0x2a0>
    837d:	inc    r13
    8380:	add    r11,rcx
    8383:	cmp    QWORD PTR [rsp+0x58],r13
    8388:	jne    8317 <bench_ada_baseline__run_16.isra.0+0x277>
    838a:	jmp    8242 <bench_ada_baseline__run_16.isra.0+0x1a2>
    838f:	mov    eax,DWORD PTR [rsp+0x34]
    8393:	mov    rcx,QWORD PTR [rsp+0x38]
    8398:	mov    DWORD PTR [rsp+0x20],esi
    839c:	mov    QWORD PTR [rbp+0x28],r14
    83a0:	mov    QWORD PTR [rbp+0x30],r9
    83a4:	vmovd  xmm19,r12d
    83aa:	vmovq  xmm21,QWORD PTR [rsp+0x48]
    83b2:	vmovd  xmm20,edi
    83b8:	mov    r12,r14
    83bb:	mov    r13,rbx
    83be:	mov    QWORD PTR [rsp+0x28],rax
    83c3:	lea    r8,[rcx-0x1]
    83c7:	lea    rcx,[rsp+0x60]
    83cc:	xor    eax,eax
    83ce:	vmovq  xmm18,rcx
    83d4:	lea    rcx,[rsp+0x70]
    83d9:	vmovq  xmm16,r8
    83df:	vmovq  xmm17,rcx
    83e5:	vzeroupper
    83e8:	mov    DWORD PTR [rsp+0x58],eax
    83ec:	mov    QWORD PTR [rsp+0x40],rax
    83f1:	mov    rbx,0xffffffffffffffff
    83f8:	vmovq  r14,xmm16
    83fe:	xchg   ax,ax
    8400:	mov    r8d,DWORD PTR [rsp+0x58]
    8405:	vmovq  rax,xmm18
    840b:	inc    rbx
    840e:	mov    rdx,r13
    8411:	mov    r9,rax
    8414:	vmovq  rax,xmm17
    841a:	mov    rdi,r15
    841d:	mov    rsi,r9
    8420:	mov    rcx,rax
    8423:	mov    r9d,ebx
    8426:	call   4f70 <mj__matrices__matt_component>
    842b:	vmovsd QWORD PTR [r12+rbx*8],xmm0
    8431:	cmp    rbx,r14
    8434:	jne    8400 <bench_ada_baseline__run_16.isra.0+0x360>
    8436:	mov    rax,QWORD PTR [rsp+0x40]
    843b:	vmovq  rcx,xmm21
    8441:	add    r12,rcx
    8444:	inc    rax
    8447:	cmp    QWORD PTR [rsp+0x28],rax
    844c:	jne    83e8 <bench_ada_baseline__run_16.isra.0+0x348>
    844e:	mov    esi,DWORD PTR [rsp+0x20]
    8452:	mov    r14,QWORD PTR [rbp+0x28]
    8456:	mov    r9,QWORD PTR [rbp+0x30]
    845a:	vmovd  r12d,xmm19
    8460:	vmovd  edi,xmm20
    8466:	mov    rbx,r13
    8469:	jmp    8250 <bench_ada_baseline__run_16.isra.0+0x1b0>
    846e:	mov    eax,DWORD PTR [rsp+0x34]
    8472:	mov    rcx,QWORD PTR [rsp+0x48]
    8477:	mov    QWORD PTR [rbp+0x30],r9
    847b:	mov    rdx,r14
    847e:	mov    r10,0xffffffffffffffff
    8485:	vxorpd xmm1,xmm1,xmm1
    8489:	mov    r9d,esi
    848c:	lea    r11,[rax-0x1]
    8490:	mov    rax,QWORD PTR [rsp+0x38]
    8495:	lea    r8,[rax-0x1]
    8499:	inc    r10
    849c:	mov    rax,0xffffffffffffffff
    84a3:	movsxd rsi,r10d
    84a6:	nop    DWORD PTR [rax+0x0]
    84aa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    84b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    84c0:	inc    rax
    84c3:	movsxd r13,eax
    84c6:	vmovsd xmm0,QWORD PTR [rbx+r13*8]
    84cc:	vmulsd xmm0,xmm0,QWORD PTR [r15+rsi*8]
    84d2:	vaddsd xmm0,xmm0,xmm1
    84d6:	vmovsd QWORD PTR [rdx+rax*8],xmm0
    84db:	cmp    rax,r8
    84de:	jne    84c0 <bench_ada_baseline__run_16.isra.0+0x420>
    84e0:	add    rdx,rcx
    84e3:	cmp    r10,r11
    84e6:	jne    8499 <bench_ada_baseline__run_16.isra.0+0x3f9>
    84e8:	jmp    8246 <bench_ada_baseline__run_16.isra.0+0x1a6>
    84ed:	mov    eax,DWORD PTR [rsp+0x34]
    84f1:	mov    rcx,QWORD PTR [rsp+0x48]
    84f6:	mov    QWORD PTR [rbp+0x30],r9
    84fa:	mov    r10,0xffffffffffffffff
    8501:	mov    r9d,esi
    8504:	vxorpd xmm2,xmm2,xmm2
    8508:	mov    rsi,r14
    850b:	lea    r11,[rax-0x1]
    850f:	mov    rax,QWORD PTR [rsp+0x38]
    8514:	lea    r8,[rax-0x1]
    8518:	inc    r10
    851b:	mov    rax,0xffffffffffffffff
    8522:	movsxd rdx,r10d
    8525:	lea    rdx,[rdx+rdx*2]
    8529:	lea    rdx,[r15+rdx*8]
    852d:	nop    DWORD PTR [rax]
    8530:	inc    rax
    8533:	movsxd r13,eax
    8536:	lea    r13,[r13+r13*2+0x0]
    853b:	lea    r13,[rbx+r13*8]
    853f:	vmovsd xmm0,QWORD PTR [r13+0x0]
    8545:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    8549:	vmovsd xmm1,QWORD PTR [r13+0x8]
    854f:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    8554:	vaddsd xmm0,xmm0,xmm1
    8558:	vmovsd xmm1,QWORD PTR [r13+0x10]
    855e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    8563:	vaddsd xmm0,xmm0,xmm1
    8567:	vaddsd xmm0,xmm0,xmm2
    856b:	vmovsd QWORD PTR [rsi+rax*8],xmm0
    8570:	cmp    rax,r8
    8573:	jne    8530 <bench_ada_baseline__run_16.isra.0+0x490>
    8575:	add    rsi,rcx
    8578:	cmp    r10,r11
    857b:	jne    8518 <bench_ada_baseline__run_16.isra.0+0x478>
    857d:	jmp    8246 <bench_ada_baseline__run_16.isra.0+0x1a6>
    8582:	nop    DWORD PTR [rax]
    8585:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_17.isra.0>:
    c5b0:	push   rbp
    c5b1:	mov    rbp,rsp
    c5b4:	push   r15
    c5b6:	push   r14
    c5b8:	push   r13
    c5ba:	push   r12
    c5bc:	push   rbx
    c5bd:	and    rsp,0xffffffffffffffc0
    c5c1:	add    rsp,0xffffffffffffff80
    c5c5:	mov    r10,QWORD PTR [rbp+0x20]
    c5c9:	mov    QWORD PTR [rsp+0x58],r8
    c5ce:	mov    QWORD PTR [rsp+0x50],r9
    c5d3:	test   edx,edx
    c5d5:	je     ca0a <bench_ada_baseline__run_17.isra.0+0x45a>
    c5db:	mov    DWORD PTR [rsp+0x34],edi
    c5df:	dec    edi
    c5e1:	mov    rbx,rcx
    c5e4:	mov    ecx,esi
    c5e6:	mov    DWORD PTR [rsp+0x40],edi
    c5ea:	lea    edi,[rsi-0x1]
    c5ed:	mov    DWORD PTR [rsp+0x44],edx
    c5f1:	lea    rdx,[rcx*8+0x0]
    c5f9:	mov    DWORD PTR [rsp+0x48],edi
    c5fd:	mov    rdi,rcx
    c600:	xor    eax,eax
    c602:	lea    r14,[rcx-0x1]
    c606:	imul   rdi,rdx
    c60a:	test   esi,esi
    c60c:	cmovne rax,rdx
    c610:	mov    r12,rax
    c613:	xor    eax,eax
    c615:	mov    QWORD PTR [rsp+0x38],rdi
    c61a:	mov    DWORD PTR [rsp+0x4c],eax
    c61e:	xchg   ax,ax
    c620:	inc    DWORD PTR [rsp+0x4c]
    c624:	mov    rax,QWORD PTR [rsp+0x58]
    c629:	mov    rdi,QWORD PTR [rsp+0x50]
    c62e:	mov    rdx,QWORD PTR [rbp+0x10]
    c632:	mov    rsi,QWORD PTR [rbp+0x18]
    c636:	mov    rcx,QWORD PTR [rbp+0x28]
    c63a:	mov    eax,DWORD PTR [rsp+0x48]
    c63e:	cmp    eax,0xffffffff
    c641:	je     ca68 <bench_ada_baseline__run_17.isra.0+0x4b8>
    c647:	mov    rdx,QWORD PTR [rsp+0x38]
    c64c:	mov    rdi,r10
    c64f:	xor    esi,esi
    c651:	call   2bd0 <memset@plt>
    c656:	vxorpd xmm6,xmm6,xmm6
    c65a:	mov    r10,rax
    c65d:	mov    eax,DWORD PTR [rsp+0x40]
    c661:	cmp    eax,0xffffffff
    c664:	je     c888 <bench_ada_baseline__run_17.isra.0+0x2d8>
    c66a:	mov    eax,DWORD PTR [rsp+0x34]
    c66e:	mov    QWORD PTR [rsp+0x70],r12
    c673:	mov    r8,0xffffffffffffffff
    c67a:	vmovq  xmm3,r14
    c67f:	lea    rcx,[rax-0x1]
    c683:	mov    rax,r12
    c686:	shr    rax,0x3
    c68a:	mov    QWORD PTR [rsp+0x60],rcx
    c68f:	mov    QWORD PTR [rsp+0x78],rax
    c694:	nop
    c695:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    c6a0:	mov    r15,QWORD PTR [rsp+0x70]
    c6a5:	inc    r8
    c6a8:	mov    r9d,0x1
    c6ae:	movsxd rdx,r8d
    c6b1:	imul   r15,rdx
    c6b5:	lea    rax,[r15+rbx*1]
    c6b9:	mov    r15,QWORD PTR [rsp+0x78]
    c6be:	mov    QWORD PTR [rsp+0x68],rax
    c6c3:	vmovq  rax,xmm3
    c6c8:	imul   r15,rdx
    c6cc:	mov    rdx,0xffffffffffffffff
    c6d3:	mov    r12,r15
    c6d6:	jmp    c70c <bench_ada_baseline__run_17.isra.0+0x15c>
    c6d8:	nop    DWORD PTR [rax+0x0]
    c6df:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    c6ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    c6f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    c700:	inc    r9d
    c703:	cmp    rdx,rax
    c706:	je     c870 <bench_ada_baseline__run_17.isra.0+0x2c0>
    c70c:	inc    rdx
    c70f:	movsxd r15,edx
    c712:	mov    r14d,edx
    c715:	lea    rcx,[r12+r15*1]
    c719:	vmovsd xmm1,QWORD PTR [rbx+rcx*8]
    c71e:	vbroadcastsd zmm2,xmm1
    c724:	test   edx,edx
    c726:	js     c700 <bench_ada_baseline__run_17.isra.0+0x150>
    c728:	vcomisd xmm1,xmm6
    c72c:	je     c700 <bench_ada_baseline__run_17.isra.0+0x150>
    c72e:	mov    r13d,edx
    c731:	cmp    edx,0x6
    c734:	jbe    ca20 <bench_ada_baseline__run_17.isra.0+0x470>
    c73a:	mov    rcx,QWORD PTR [rsp+0x70]
    c73f:	mov    r11,QWORD PTR [rsp+0x68]
    c744:	mov    edi,r9d
    c747:	shr    edi,0x3
    c74a:	vmovapd zmm4,zmm2
    c750:	mov    esi,edi
    c752:	imul   rcx,r15
    c756:	shl    rsi,0x6
    c75a:	add    rcx,r10
    c75d:	add    rsi,rcx
    c760:	sub    r11,rcx
    c763:	nop    DWORD PTR [rax+0x0]
    c76a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    c775:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    c780:	vmulpd zmm0,zmm4,ZMMWORD PTR [rcx+r11*1]
    c787:	add    rcx,0x40
    c78b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rcx-0x40]
    c792:	vmovupd ZMMWORD PTR [rcx-0x40],zmm0
    c799:	cmp    rsi,rcx
    c79c:	jne    c780 <bench_ada_baseline__run_17.isra.0+0x1d0>
    c79e:	shl    edi,0x3
    c7a1:	cmp    r9d,edi
    c7a4:	je     c700 <bench_ada_baseline__run_17.isra.0+0x150>
    c7aa:	lea    ecx,[rdi-0x1]
    c7ad:	sub    r13d,edi
    c7b0:	cmp    r13d,0x2
    c7b4:	jbe    c7eb <bench_ada_baseline__run_17.isra.0+0x23b>
    c7b6:	mov    rsi,QWORD PTR [rsp+0x78]
    c7bb:	inc    r13d
    c7be:	imul   rsi,r15
    c7c2:	add    rsi,rdi
    c7c5:	add    rdi,r12
    c7c8:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+rdi*8]
    c7cd:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+rsi*8]
    c7d3:	vmovupd YMMWORD PTR [r10+rsi*8],ymm2
    c7d9:	mov    esi,r13d
    c7dc:	and    esi,0xfffffffc
    c7df:	and    r13d,0x3
    c7e3:	je     c700 <bench_ada_baseline__run_17.isra.0+0x150>
    c7e9:	add    ecx,esi
    c7eb:	mov    r11,QWORD PTR [rsp+0x78]
    c7f0:	lea    esi,[rcx+0x1]
    c7f3:	mov    rdi,rsi
    c7f6:	imul   r11,r15
    c7fa:	lea    r13,[r11+rsi*1]
    c7fe:	add    rsi,r12
    c801:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    c806:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    c80c:	vmovsd QWORD PTR [r10+r13*8],xmm0
    c812:	cmp    edi,r14d
    c815:	je     c700 <bench_ada_baseline__run_17.isra.0+0x150>
    c81b:	lea    esi,[rcx+0x2]
    c81e:	lea    r13,[r11+rsi*1]
    c822:	mov    rdi,rsi
    c825:	add    rsi,r12
    c828:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    c82d:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    c833:	vmovsd QWORD PTR [r10+r13*8],xmm0
    c839:	cmp    r14d,edi
    c83c:	je     c700 <bench_ada_baseline__run_17.isra.0+0x150>
    c842:	add    ecx,0x3
    c845:	inc    r9d
    c848:	lea    r15,[r11+rcx*1]
    c84c:	add    rcx,r12
    c84f:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    c854:	vaddsd xmm1,xmm1,QWORD PTR [r10+r15*8]
    c85a:	vmovsd QWORD PTR [r10+r15*8],xmm1
    c860:	cmp    rdx,rax
    c863:	jne    c70c <bench_ada_baseline__run_17.isra.0+0x15c>
    c869:	nop    DWORD PTR [rax+0x0]
    c870:	cmp    r8,QWORD PTR [rsp+0x60]
    c875:	jne    c6a0 <bench_ada_baseline__run_17.isra.0+0xf0>
    c87b:	mov    r12,QWORD PTR [rsp+0x70]
    c880:	vmovq  r14,xmm3
    c885:	vzeroupper
    c888:	mov    eax,DWORD PTR [rsp+0x48]
    c88c:	lea    r13,[r12+r12*1]
    c890:	mov    r11,r12
    c893:	shr    r11,0x3
    c897:	vmovq  xmm5,r13
    c89c:	mov    QWORD PTR [rsp+0x70],rbx
    c8a1:	mov    r8d,0x1
    c8a7:	mov    rsi,0xffffffffffffffff
    c8ae:	mov    QWORD PTR [rsp+0x78],rax
    c8b3:	mov    r15,rax
    c8b6:	jmp    c8cc <bench_ada_baseline__run_17.isra.0+0x31c>
    c8b8:	nop    DWORD PTR [rax+rax*1+0x0]
    c8c0:	inc    r8d
    c8c3:	cmp    rsi,r14
    c8c6:	je     c9e1 <bench_ada_baseline__run_17.isra.0+0x431>
    c8cc:	mov    rdx,rsi
    c8cf:	inc    rsi
    c8d2:	cmp    r15d,r8d
    c8d5:	jl     c8c0 <bench_ada_baseline__run_17.isra.0+0x310>
    c8d7:	mov    rcx,QWORD PTR [rsp+0x78]
    c8dc:	movsxd rax,r8d
    c8df:	lea    r9,[rax-0x1]
    c8e3:	sub    rcx,rax
    c8e6:	cmp    rcx,0xe
    c8ea:	jbe    ca2c <bench_ada_baseline__run_17.isra.0+0x47c>
    c8f0:	imul   rax,r11
    c8f4:	mov    rbx,rsi
    c8f7:	imul   rbx,r11
    c8fb:	add    rax,rdx
    c8fe:	movsxd rdx,esi
    c901:	add    rdx,rbx
    c904:	shl    rdx,0x3
    c908:	lea    rbx,[r10+rdx*1]
    c90c:	vmovq  xmm1,rbx
    c911:	lea    rbx,[rdx+r10*1+0x8]
    c916:	mov    r13,rbx
    c919:	mov    rbx,r12
    c91c:	imul   rbx,rcx
    c920:	shl    rax,0x3
    c924:	lea    rdi,[r10+rax*1]
    c928:	lea    rbx,[rdi+rbx*1+0x8]
    c92d:	cmp    rbx,r13
    c930:	jb     c949 <bench_ada_baseline__run_17.isra.0+0x399>
    c932:	vmovq  rbx,xmm1
    c937:	add    rdi,0x8
    c93b:	lea    rbx,[rbx+rcx*8+0x8]
    c940:	cmp    rbx,rdi
    c943:	jae    ca2c <bench_ada_baseline__run_17.isra.0+0x47c>
    c949:	cmp    r15d,r8d
    c94c:	je     c9b2 <bench_ada_baseline__run_17.isra.0+0x402>
    c94e:	lea    rbx,[rcx+0x1]
    c952:	dec    rcx
    c955:	lea    rax,[rax+r10*1+0x8]
    c95a:	vmovq  r13,xmm5
    c95f:	shr    rcx,1
    c962:	lea    rdi,[rcx+0x1]
    c966:	lea    rcx,[rdx+r10*1+0x8]
    c96b:	xor    edx,edx
    c96d:	nop    DWORD PTR [rax+rax*1+0x0]
    c975:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    c980:	vmovsd xmm0,QWORD PTR [rax]
    c984:	vmovhpd xmm0,xmm0,QWORD PTR [r12+rax*1]
    c98a:	inc    rdx
    c98d:	add    rax,r13
    c990:	add    rcx,0x10
    c994:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    c999:	cmp    rdx,rdi
    c99c:	jb     c980 <bench_ada_baseline__run_17.isra.0+0x3d0>
    c99e:	add    rdi,rdi
    c9a1:	vmovq  xmm5,r13
    c9a6:	cmp    rbx,rdi
    c9a9:	je     c8c0 <bench_ada_baseline__run_17.isra.0+0x310>
    c9af:	add    r9,rdi
    c9b2:	inc    r9
    c9b5:	mov    rax,r11
    c9b8:	inc    r8d
    c9bb:	imul   rax,r9
    c9bf:	add    rax,rsi
    c9c2:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    c9c8:	mov    rax,rsi
    c9cb:	imul   rax,r11
    c9cf:	add    rax,r9
    c9d2:	vmovsd QWORD PTR [r10+rax*8],xmm0
    c9d8:	cmp    rsi,r14
    c9db:	jne    c8cc <bench_ada_baseline__run_17.isra.0+0x31c>
    c9e1:	mov    rbx,QWORD PTR [rsp+0x70]
    c9e6:	mov    rax,QWORD PTR [rsp+0x58]
    c9eb:	mov    rdi,QWORD PTR [rsp+0x50]
    c9f0:	mov    rdx,QWORD PTR [rbp+0x10]
    c9f4:	mov    rsi,QWORD PTR [rbp+0x18]
    c9f8:	mov    rcx,QWORD PTR [rbp+0x28]
    c9fc:	mov    edi,DWORD PTR [rsp+0x4c]
    ca00:	cmp    DWORD PTR [rsp+0x44],edi
    ca04:	jne    c620 <bench_ada_baseline__run_17.isra.0+0x70>
    ca0a:	lea    rsp,[rbp-0x28]
    ca0e:	pop    rbx
    ca0f:	pop    r12
    ca11:	pop    r13
    ca13:	pop    r14
    ca15:	pop    r15
    ca17:	pop    rbp
    ca18:	ret
    ca19:	nop    DWORD PTR [rax+0x0]
    ca20:	xor    edi,edi
    ca22:	mov    ecx,0xffffffff
    ca27:	jmp    c7ad <bench_ada_baseline__run_17.isra.0+0x1fd>
    ca2c:	mov    rdx,rsi
    ca2f:	vmovq  r13,xmm5
    ca34:	imul   rdx,r12
    ca38:	add    rdx,r10
    ca3b:	nop    DWORD PTR [rax+rax*1+0x0]
    ca40:	inc    r9
    ca43:	mov    rax,r11
    ca46:	imul   rax,r9
    ca4a:	add    rax,rsi
    ca4d:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    ca53:	vmovsd QWORD PTR [rdx+r9*8],xmm0
    ca59:	cmp    r9,r14
    ca5c:	jne    ca40 <bench_ada_baseline__run_17.isra.0+0x490>
    ca5e:	vmovq  xmm5,r13
    ca63:	jmp    c8c0 <bench_ada_baseline__run_17.isra.0+0x310>
    ca68:	mov    eax,DWORD PTR [rsp+0x40]
    ca6c:	mov    r9d,DWORD PTR [rsp+0x4c]
    ca71:	mov    rdx,QWORD PTR [rsp+0x50]
    ca76:	mov    rcx,QWORD PTR [rbp+0x10]
    ca7a:	mov    rsi,QWORD PTR [rbp+0x18]
    ca7e:	mov    rdi,QWORD PTR [rbp+0x28]
    ca82:	mov    r8d,DWORD PTR [rsp+0x44]
    ca87:	cmp    eax,0xffffffff
    ca8a:	mov    rax,QWORD PTR [rsp+0x58]
    ca8f:	jne    ca96 <bench_ada_baseline__run_17.isra.0+0x4e6>
    ca91:	jmp    caa0 <bench_ada_baseline__run_17.isra.0+0x4f0>
    ca93:	inc    r9d
    ca96:	cmp    r8d,r9d
    ca99:	jne    ca93 <bench_ada_baseline__run_17.isra.0+0x4e3>
    ca9b:	jmp    ca0a <bench_ada_baseline__run_17.isra.0+0x45a>
    caa0:	cmp    r8d,r9d
    caa3:	je     ca0a <bench_ada_baseline__run_17.isra.0+0x45a>
    caa9:	lea    r11d,[r9+0x1]
    caad:	cmp    r8d,r11d
    cab0:	je     ca0a <bench_ada_baseline__run_17.isra.0+0x45a>
    cab6:	add    r9d,0x2
    caba:	jmp    caa0 <bench_ada_baseline__run_17.isra.0+0x4f0>
    cabc:	nop    DWORD PTR [rax+0x0]


<bench_ada_baseline__run_18.isra.0>:
    cac0:	push   rbp
    cac1:	mov    eax,edi
    cac3:	mov    rbp,rsp
    cac6:	push   r15
    cac8:	push   r14
    caca:	push   r13
    cacc:	push   r12
    cace:	push   rbx
    cacf:	and    rsp,0xffffffffffffffc0
    cad3:	add    rsp,0xffffffffffffff80
    cad7:	mov    rdi,QWORD PTR [rbp+0x20]
    cadb:	test   edx,edx
    cadd:	je     cf49 <bench_ada_baseline__run_18.isra.0+0x489>
    cae3:	mov    r12d,esi
    cae6:	test   esi,esi
    cae8:	lea    r15d,[rsi-0x1]
    caec:	mov    DWORD PTR [rsp+0x2c],eax
    caf0:	setne  BYTE PTR [rsp+0x67]
    caf5:	lea    r13,[r12*8+0x0]
    cafd:	xor    eax,eax
    caff:	cmp    r15d,0xffffffff
    cb03:	cmove  r13,rax
    cb07:	cmovne rax,r12
    cb0b:	mov    DWORD PTR [rsp+0x28],edx
    cb0f:	mov    DWORD PTR [rsp+0x24],r15d
    cb14:	mov    QWORD PTR [rsp+0x40],r8
    cb19:	mov    QWORD PTR [rsp+0x38],r9
    cb1e:	mov    rbx,rcx
    cb21:	dec    r12
    cb24:	imul   rax,r13
    cb28:	mov    QWORD PTR [rsp+0x30],rax
    cb2d:	xor    eax,eax
    cb2f:	mov    DWORD PTR [rsp+0x60],eax
    cb33:	mov    rax,r13
    cb36:	shr    rax,0x3
    cb3a:	mov    QWORD PTR [rsp+0x78],rax
    cb3f:	nop
    cb40:	inc    DWORD PTR [rsp+0x60]
    cb44:	mov    rax,QWORD PTR [rsp+0x40]
    cb49:	mov    rsi,QWORD PTR [rsp+0x38]
    cb4e:	mov    rcx,QWORD PTR [rbp+0x10]
    cb52:	mov    rdx,QWORD PTR [rbp+0x18]
    cb56:	mov    r10,QWORD PTR [rbp+0x28]
    cb5a:	mov    rdx,QWORD PTR [rsp+0x30]
    cb5f:	xor    esi,esi
    cb61:	call   2bd0 <memset@plt>
    cb66:	vxorpd xmm2,xmm2,xmm2
    cb6a:	mov    rdi,rax
    cb6d:	mov    eax,DWORD PTR [rsp+0x2c]
    cb71:	test   eax,eax
    cb73:	je     cd9a <bench_ada_baseline__run_18.isra.0+0x2da>
    cb79:	mov    QWORD PTR [rsp+0x70],r13
    cb7e:	mov    QWORD PTR [rbp+0x20],rdi
    cb82:	mov    r13,QWORD PTR [rbp+0x18]
    cb86:	lea    rsi,[rax-0x1]
    cb8a:	mov    r8,0xffffffffffffffff
    cb91:	jmp    cba9 <bench_ada_baseline__run_18.isra.0+0xe9>
    cb93:	xchg   ax,ax
    cb95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    cba0:	cmp    r8,rsi
    cba3:	je     cd8e <bench_ada_baseline__run_18.isra.0+0x2ce>
    cba9:	inc    r8
    cbac:	movsxd rdi,r8d
    cbaf:	vcomisd xmm2,QWORD PTR [r13+rdi*8+0x0]
    cbb6:	je     cba0 <bench_ada_baseline__run_18.isra.0+0xe0>
    cbb8:	cmp    BYTE PTR [rsp+0x67],0x0
    cbbd:	je     cba0 <bench_ada_baseline__run_18.isra.0+0xe0>
    cbbf:	mov    rax,QWORD PTR [rsp+0x70]
    cbc4:	mov    r14,QWORD PTR [rsp+0x78]
    cbc9:	mov    QWORD PTR [rsp+0x50],r8
    cbce:	mov    QWORD PTR [rsp+0x48],rsi
    cbd3:	mov    r8,rdi
    cbd6:	mov    ecx,0x1
    cbdb:	mov    rdx,0xffffffffffffffff
    cbe2:	imul   rax,rdi
    cbe6:	imul   r14,rdi
    cbea:	mov    rdi,QWORD PTR [rbp+0x20]
    cbee:	add    rax,rbx
    cbf1:	mov    QWORD PTR [rsp+0x58],rax
    cbf6:	mov    r10,r14
    cbf9:	nop    DWORD PTR [rax+0x0]
    cc00:	inc    rdx
    cc03:	movsxd r14,edx
    cc06:	lea    rax,[r10+r14*1]
    cc0a:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    cc0f:	vcomisd xmm0,xmm2
    cc13:	je     cd70 <bench_ada_baseline__run_18.isra.0+0x2b0>
    cc19:	vmovsd xmm1,QWORD PTR [r13+r8*8+0x0]
    cc20:	vcomisd xmm1,xmm2
    cc24:	je     cd70 <bench_ada_baseline__run_18.isra.0+0x2b0>
    cc2a:	mov    esi,edx
    cc2c:	test   edx,edx
    cc2e:	js     cd70 <bench_ada_baseline__run_18.isra.0+0x2b0>
    cc34:	vmulsd xmm1,xmm0,xmm1
    cc38:	mov    DWORD PTR [rsp+0x68],edx
    cc3c:	vbroadcastsd zmm6,xmm1
    cc42:	cmp    edx,0x6
    cc45:	jbe    cfb0 <bench_ada_baseline__run_18.isra.0+0x4f0>
    cc4b:	mov    r9,QWORD PTR [rsp+0x70]
    cc50:	mov    r15,QWORD PTR [rsp+0x58]
    cc55:	mov    r11d,ecx
    cc58:	shr    r11d,0x3
    cc5c:	vmovapd zmm4,zmm6
    cc62:	imul   r9,r14
    cc66:	lea    rax,[r9+rdi*1]
    cc6a:	mov    r9d,r11d
    cc6d:	shl    r9,0x6
    cc71:	sub    r15,rax
    cc74:	add    r9,rax
    cc77:	nop    WORD PTR [rax+rax*1+0x0]
    cc80:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    cc87:	add    rax,0x40
    cc8b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    cc92:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    cc99:	cmp    r9,rax
    cc9c:	jne    cc80 <bench_ada_baseline__run_18.isra.0+0x1c0>
    cc9e:	shl    r11d,0x3
    cca2:	cmp    ecx,r11d
    cca5:	je     cd70 <bench_ada_baseline__run_18.isra.0+0x2b0>
    ccab:	lea    r9d,[r11-0x1]
    ccaf:	mov    r15d,DWORD PTR [rsp+0x68]
    ccb4:	sub    r15d,r11d
    ccb7:	cmp    r15d,0x2
    ccbb:	jbe    ccf3 <bench_ada_baseline__run_18.isra.0+0x233>
    ccbd:	mov    rax,QWORD PTR [rsp+0x78]
    ccc2:	inc    r15d
    ccc5:	imul   rax,r14
    ccc9:	add    rax,r11
    cccc:	add    r11,r10
    cccf:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r11*8]
    ccd5:	mov    r11d,r15d
    ccd8:	and    r11d,0xfffffffc
    ccdc:	and    r15d,0x3
    cce0:	vaddpd ymm6,ymm6,YMMWORD PTR [rdi+rax*8]
    cce5:	vmovupd YMMWORD PTR [rdi+rax*8],ymm6
    ccea:	je     cd70 <bench_ada_baseline__run_18.isra.0+0x2b0>
    ccf0:	add    r9d,r11d
    ccf3:	mov    r15,QWORD PTR [rsp+0x78]
    ccf8:	lea    r11d,[r9+0x1]
    ccfc:	mov    DWORD PTR [rsp+0x68],r11d
    cd01:	mov    rax,r15
    cd04:	imul   r15,r8
    cd08:	imul   rax,r14
    cd0c:	lea    r14,[rax+r11*1]
    cd10:	add    r11,r15
    cd13:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    cd19:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    cd1f:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    cd25:	cmp    DWORD PTR [rsp+0x68],esi
    cd29:	je     cd70 <bench_ada_baseline__run_18.isra.0+0x2b0>
    cd2b:	lea    r11d,[r9+0x2]
    cd2f:	lea    r14,[rax+r11*1]
    cd33:	mov    DWORD PTR [rsp+0x68],r11d
    cd38:	add    r11,r15
    cd3b:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    cd41:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    cd47:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    cd4d:	cmp    esi,DWORD PTR [rsp+0x68]
    cd51:	je     cd70 <bench_ada_baseline__run_18.isra.0+0x2b0>
    cd53:	lea    esi,[r9+0x3]
    cd57:	add    rax,rsi
    cd5a:	add    rsi,r15
    cd5d:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    cd62:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rax*8]
    cd67:	vmovsd QWORD PTR [rdi+rax*8],xmm1
    cd6c:	nop    DWORD PTR [rax+0x0]
    cd70:	inc    ecx
    cd72:	cmp    rdx,r12
    cd75:	jne    cc00 <bench_ada_baseline__run_18.isra.0+0x140>
    cd7b:	mov    r8,QWORD PTR [rsp+0x50]
    cd80:	mov    rsi,QWORD PTR [rsp+0x48]
    cd85:	cmp    r8,rsi
    cd88:	jne    cba9 <bench_ada_baseline__run_18.isra.0+0xe9>
    cd8e:	mov    r13,QWORD PTR [rsp+0x70]
    cd93:	mov    rdi,QWORD PTR [rbp+0x20]
    cd97:	vzeroupper
    cd9a:	mov    eax,DWORD PTR [rsp+0x24]
    cd9e:	cmp    eax,0xffffffff
    cda1:	je     cf25 <bench_ada_baseline__run_18.isra.0+0x465>
    cda7:	mov    r14d,eax
    cdaa:	mov    QWORD PTR [rsp+0x58],rbx
    cdaf:	mov    r11,QWORD PTR [rsp+0x78]
    cdb4:	mov    r9d,0x1
    cdba:	mov    QWORD PTR [rsp+0x68],r14
    cdbf:	mov    rsi,0xffffffffffffffff
    cdc6:	lea    rbx,[r13+r13*1+0x0]
    cdcb:	mov    r15d,eax
    cdce:	jmp    cdec <bench_ada_baseline__run_18.isra.0+0x32c>
    cdd0:	nop    DWORD PTR [rax+rax*1+0x0]
    cdd5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    cde0:	inc    r9d
    cde3:	cmp    rsi,r12
    cde6:	je     cf20 <bench_ada_baseline__run_18.isra.0+0x460>
    cdec:	mov    rax,rsi
    cdef:	inc    rsi
    cdf2:	cmp    r15d,r9d
    cdf5:	jl     cde0 <bench_ada_baseline__run_18.isra.0+0x320>
    cdf7:	mov    rcx,QWORD PTR [rsp+0x68]
    cdfc:	movsxd rdx,r9d
    cdff:	lea    r10,[rdx-0x1]
    ce03:	sub    rcx,rdx
    ce06:	cmp    rcx,0xe
    ce0a:	jbe    cf60 <bench_ada_baseline__run_18.isra.0+0x4a0>
    ce10:	imul   rdx,r11
    ce14:	movsxd r14,esi
    ce17:	add    rax,rdx
    ce1a:	mov    rdx,rsi
    ce1d:	imul   rdx,r11
    ce21:	shl    rax,0x3
    ce25:	add    rdx,r14
    ce28:	lea    r8,[rdi+rax*1]
    ce2c:	shl    rdx,0x3
    ce30:	lea    r14,[rdi+rdx*1]
    ce34:	vmovq  xmm3,r14
    ce39:	mov    r14,r13
    ce3c:	imul   r14,rcx
    ce40:	lea    r14,[r8+r14*1+0x8]
    ce45:	mov    QWORD PTR [rsp+0x70],r14
    ce4a:	lea    r14,[rdx+rdi*1+0x8]
    ce4f:	cmp    QWORD PTR [rsp+0x70],r14
    ce54:	jb     ce6d <bench_ada_baseline__run_18.isra.0+0x3ad>
    ce56:	vmovq  r14,xmm3
    ce5b:	add    r8,0x8
    ce5f:	lea    r14,[r14+rcx*8+0x8]
    ce64:	cmp    r14,r8
    ce67:	jae    cf60 <bench_ada_baseline__run_18.isra.0+0x4a0>
    ce6d:	cmp    r15d,r9d
    ce70:	je     ceee <bench_ada_baseline__run_18.isra.0+0x42e>
    ce72:	lea    r14,[rcx+0x1]
    ce76:	dec    rcx
    ce79:	lea    rax,[rax+rdi*1+0x8]
    ce7e:	shr    rcx,1
    ce81:	lea    r8,[rcx+0x1]
    ce85:	lea    rcx,[rdx+rdi*1+0x8]
    ce8a:	xor    edx,edx
    ce8c:	nop    DWORD PTR [rax+rax*1+0x0]
    ce94:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ce9f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ceaa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ceb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    cec0:	vmovsd xmm0,QWORD PTR [rax]
    cec4:	vmovhpd xmm0,xmm0,QWORD PTR [r13+rax*1+0x0]
    cecb:	inc    rdx
    cece:	add    rax,rbx
    ced1:	add    rcx,0x10
    ced5:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    ceda:	cmp    rdx,r8
    cedd:	jb     cec0 <bench_ada_baseline__run_18.isra.0+0x400>
    cedf:	add    r8,r8
    cee2:	cmp    r14,r8
    cee5:	je     cde0 <bench_ada_baseline__run_18.isra.0+0x320>
    ceeb:	add    r10,r8
    ceee:	inc    r10
    cef1:	mov    rax,r11
    cef4:	inc    r9d
    cef7:	imul   rax,r10
    cefb:	add    rax,rsi
    cefe:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    cf03:	mov    rax,rsi
    cf06:	imul   rax,r11
    cf0a:	add    rax,r10
    cf0d:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    cf12:	cmp    rsi,r12
    cf15:	jne    cdec <bench_ada_baseline__run_18.isra.0+0x32c>
    cf1b:	nop    DWORD PTR [rax+rax*1+0x0]
    cf20:	mov    rbx,QWORD PTR [rsp+0x58]
    cf25:	mov    rax,QWORD PTR [rsp+0x40]
    cf2a:	mov    rsi,QWORD PTR [rsp+0x38]
    cf2f:	mov    rcx,QWORD PTR [rbp+0x10]
    cf33:	mov    rdx,QWORD PTR [rbp+0x18]
    cf37:	mov    r10,QWORD PTR [rbp+0x28]
    cf3b:	mov    esi,DWORD PTR [rsp+0x60]
    cf3f:	cmp    DWORD PTR [rsp+0x28],esi
    cf43:	jne    cb40 <bench_ada_baseline__run_18.isra.0+0x80>
    cf49:	lea    rsp,[rbp-0x28]
    cf4d:	pop    rbx
    cf4e:	pop    r12
    cf50:	pop    r13
    cf52:	pop    r14
    cf54:	pop    r15
    cf56:	pop    rbp
    cf57:	ret
    cf58:	nop    DWORD PTR [rax+rax*1+0x0]
    cf60:	mov    rdx,r13
    cf63:	imul   rdx,rsi
    cf67:	add    rdx,rdi
    cf6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    cf75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    cf80:	inc    r10
    cf83:	mov    rax,r11
    cf86:	imul   rax,r10
    cf8a:	add    rax,rsi
    cf8d:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    cf92:	vmovsd QWORD PTR [rdx+r10*8],xmm0
    cf98:	cmp    r10,r12
    cf9b:	jne    cf80 <bench_ada_baseline__run_18.isra.0+0x4c0>
    cf9d:	jmp    cde0 <bench_ada_baseline__run_18.isra.0+0x320>
    cfa2:	nop    DWORD PTR [rax]
    cfa5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    cfb0:	xor    r11d,r11d
    cfb3:	mov    r9d,0xffffffff
    cfb9:	jmp    ccaf <bench_ada_baseline__run_18.isra.0+0x1ef>
    cfbe:	xchg   ax,ax


<bench_ada_baseline__run_19.isra.0>:
    cfc0:	push   rbp
    cfc1:	mov    rbp,rsp
    cfc4:	push   r15
    cfc6:	push   r14
    cfc8:	push   r13
    cfca:	push   r12
    cfcc:	push   rbx
    cfcd:	and    rsp,0xffffffffffffffc0
    cfd1:	add    rsp,0xffffffffffffff80
    cfd5:	mov    r12,QWORD PTR [rbp+0x18]
    cfd9:	test   edx,edx
    cfdb:	je     d2b3 <bench_ada_baseline__run_19.isra.0+0x2f3>
    cfe1:	mov    r13d,esi
    cfe4:	test   esi,esi
    cfe6:	mov    eax,0x0
    cfeb:	mov    DWORD PTR [rsp+0x38],edx
    cfef:	lea    rsi,[r13*8+0x0]
    cff7:	setne  r14b
    cffb:	mov    DWORD PTR [rsp+0x3c],edi
    cfff:	mov    QWORD PTR [rsp+0x48],r8
    d004:	cmove  rsi,rax
    d008:	mov    BYTE PTR [rsp+0x73],r14b
    d00d:	mov    r14,r9
    d010:	mov    r9,QWORD PTR [rbp+0x20]
    d014:	cmovne rax,r13
    d018:	mov    QWORD PTR [rsp+0x68],rsi
    d01d:	mov    rbx,rcx
    d020:	xor    r15d,r15d
    d023:	imul   rax,rsi
    d027:	dec    r13
    d02a:	shr    rsi,0x3
    d02e:	mov    QWORD PTR [rsp+0x40],rax
    d033:	mov    QWORD PTR [rsp+0x78],rsi
    d038:	nop    DWORD PTR [rax+rax*1+0x0]
    d040:	mov    rax,QWORD PTR [rsp+0x48]
    d045:	mov    rsi,QWORD PTR [rbp+0x10]
    d049:	mov    rcx,QWORD PTR [rbp+0x28]
    d04d:	inc    r15d
    d050:	mov    rdx,QWORD PTR [rsp+0x40]
    d055:	xor    esi,esi
    d057:	mov    rdi,r9
    d05a:	call   2bd0 <memset@plt>
    d05f:	vxorpd xmm2,xmm2,xmm2
    d063:	mov    r9,rax
    d066:	mov    eax,DWORD PTR [rsp+0x3c]
    d06a:	test   eax,eax
    d06c:	je     d29b <bench_ada_baseline__run_19.isra.0+0x2db>
    d072:	mov    DWORD PTR [rsp+0x34],r15d
    d077:	mov    QWORD PTR [rsp+0x28],r14
    d07c:	mov    rdi,0xffffffffffffffff
    d083:	lea    r11,[rax-0x1]
    d087:	jmp    d0a9 <bench_ada_baseline__run_19.isra.0+0xe9>
    d089:	nop
    d08a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    d095:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    d0a0:	cmp    rdi,r11
    d0a3:	je     d28e <bench_ada_baseline__run_19.isra.0+0x2ce>
    d0a9:	inc    rdi
    d0ac:	movsxd r14,edi
    d0af:	vcomisd xmm2,QWORD PTR [r12+r14*8]
    d0b5:	je     d0a0 <bench_ada_baseline__run_19.isra.0+0xe0>
    d0b7:	cmp    BYTE PTR [rsp+0x73],0x0
    d0bc:	je     d0a0 <bench_ada_baseline__run_19.isra.0+0xe0>
    d0be:	mov    rax,QWORD PTR [rsp+0x68]
    d0c3:	mov    r10,QWORD PTR [rsp+0x78]
    d0c8:	mov    QWORD PTR [rsp+0x58],rdi
    d0cd:	mov    QWORD PTR [rsp+0x50],r11
    d0d2:	mov    ecx,0x1
    d0d7:	mov    rdx,0xffffffffffffffff
    d0de:	mov    r11,r14
    d0e1:	imul   rax,r14
    d0e5:	imul   r10,r14
    d0e9:	add    rax,rbx
    d0ec:	mov    QWORD PTR [rsp+0x60],rax
    d0f1:	nop    DWORD PTR [rax+0x0]
    d0f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    d100:	inc    rdx
    d103:	movsxd r14,edx
    d106:	lea    rax,[r10+r14*1]
    d10a:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    d10f:	vcomisd xmm0,xmm2
    d113:	je     d270 <bench_ada_baseline__run_19.isra.0+0x2b0>
    d119:	vmovsd xmm1,QWORD PTR [r12+r11*8]
    d11f:	vcomisd xmm1,xmm2
    d123:	je     d270 <bench_ada_baseline__run_19.isra.0+0x2b0>
    d129:	mov    esi,edx
    d12b:	test   edx,edx
    d12d:	js     d270 <bench_ada_baseline__run_19.isra.0+0x2b0>
    d133:	vmulsd xmm1,xmm0,xmm1
    d137:	mov    DWORD PTR [rsp+0x74],edx
    d13b:	vbroadcastsd zmm6,xmm1
    d141:	cmp    edx,0x6
    d144:	jbe    d2d0 <bench_ada_baseline__run_19.isra.0+0x310>
    d14a:	mov    rdi,QWORD PTR [rsp+0x68]
    d14f:	mov    r15,QWORD PTR [rsp+0x60]
    d154:	mov    r8d,ecx
    d157:	shr    r8d,0x3
    d15b:	vmovapd zmm4,zmm6
    d161:	imul   rdi,r14
    d165:	lea    rax,[rdi+r9*1]
    d169:	mov    edi,r8d
    d16c:	shl    rdi,0x6
    d170:	sub    r15,rax
    d173:	add    rdi,rax
    d176:	cs nop WORD PTR [rax+rax*1+0x0]
    d180:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    d187:	add    rax,0x40
    d18b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    d192:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    d199:	cmp    rax,rdi
    d19c:	jne    d180 <bench_ada_baseline__run_19.isra.0+0x1c0>
    d19e:	shl    r8d,0x3
    d1a2:	cmp    r8d,ecx
    d1a5:	je     d270 <bench_ada_baseline__run_19.isra.0+0x2b0>
    d1ab:	lea    edi,[r8-0x1]
    d1af:	mov    r15d,DWORD PTR [rsp+0x74]
    d1b4:	sub    r15d,r8d
    d1b7:	cmp    r15d,0x2
    d1bb:	jbe    d1f5 <bench_ada_baseline__run_19.isra.0+0x235>
    d1bd:	mov    rax,QWORD PTR [rsp+0x78]
    d1c2:	inc    r15d
    d1c5:	imul   rax,r14
    d1c9:	add    rax,r8
    d1cc:	add    r8,r10
    d1cf:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r8*8]
    d1d5:	mov    r8d,r15d
    d1d8:	and    r8d,0xfffffffc
    d1dc:	and    r15d,0x3
    d1e0:	vaddpd ymm6,ymm6,YMMWORD PTR [r9+rax*8]
    d1e6:	vmovupd YMMWORD PTR [r9+rax*8],ymm6
    d1ec:	je     d270 <bench_ada_baseline__run_19.isra.0+0x2b0>
    d1f2:	add    edi,r8d
    d1f5:	mov    r15,QWORD PTR [rsp+0x78]
    d1fa:	lea    r8d,[rdi+0x1]
    d1fe:	mov    DWORD PTR [rsp+0x74],r8d
    d203:	mov    rax,r15
    d206:	imul   r15,r11
    d20a:	imul   rax,r14
    d20e:	lea    r14,[rax+r8*1]
    d212:	add    r8,r15
    d215:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    d21b:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    d221:	vmovsd QWORD PTR [r9+r14*8],xmm0
    d227:	cmp    esi,DWORD PTR [rsp+0x74]
    d22b:	je     d270 <bench_ada_baseline__run_19.isra.0+0x2b0>
    d22d:	lea    r8d,[rdi+0x2]
    d231:	lea    r14,[rax+r8*1]
    d235:	mov    DWORD PTR [rsp+0x74],r8d
    d23a:	add    r8,r15
    d23d:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    d243:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    d249:	vmovsd QWORD PTR [r9+r14*8],xmm0
    d24f:	cmp    esi,DWORD PTR [rsp+0x74]
    d253:	je     d270 <bench_ada_baseline__run_19.isra.0+0x2b0>
    d255:	lea    esi,[rdi+0x3]
    d258:	add    rax,rsi
    d25b:	add    rsi,r15
    d25e:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    d263:	vaddsd xmm1,xmm1,QWORD PTR [r9+rax*8]
    d269:	vmovsd QWORD PTR [r9+rax*8],xmm1
    d26f:	nop
    d270:	inc    ecx
    d272:	cmp    rdx,r13
    d275:	jne    d100 <bench_ada_baseline__run_19.isra.0+0x140>
    d27b:	mov    rdi,QWORD PTR [rsp+0x58]
    d280:	mov    r11,QWORD PTR [rsp+0x50]
    d285:	cmp    rdi,r11
    d288:	jne    d0a9 <bench_ada_baseline__run_19.isra.0+0xe9>
    d28e:	mov    r15d,DWORD PTR [rsp+0x34]
    d293:	mov    r14,QWORD PTR [rsp+0x28]
    d298:	vzeroupper
    d29b:	mov    rax,QWORD PTR [rsp+0x48]
    d2a0:	mov    rsi,QWORD PTR [rbp+0x10]
    d2a4:	mov    rcx,QWORD PTR [rbp+0x28]
    d2a8:	cmp    DWORD PTR [rsp+0x38],r15d
    d2ad:	jne    d040 <bench_ada_baseline__run_19.isra.0+0x80>
    d2b3:	lea    rsp,[rbp-0x28]
    d2b7:	pop    rbx
    d2b8:	pop    r12
    d2ba:	pop    r13
    d2bc:	pop    r14
    d2be:	pop    r15
    d2c0:	pop    rbp
    d2c1:	ret
    d2c2:	nop    DWORD PTR [rax]
    d2c5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    d2d0:	xor    r8d,r8d
    d2d3:	mov    edi,0xffffffff
    d2d8:	jmp    d1af <bench_ada_baseline__run_19.isra.0+0x1ef>
    d2dd:	nop
    d2de:	xchg   ax,ax


<bench_ada_baseline__run_2.isra.0>:
    7370:	mov    rax,rsi
    7373:	mov    r11,QWORD PTR [rsp+0x10]
    7378:	mov    rsi,rdx
    737b:	mov    r10,rcx
    737e:	mov    rdx,QWORD PTR [rsp+0x8]
    7383:	test   edi,edi
    7385:	je     73f9 <bench_ada_baseline__run_2.isra.0+0x89>
    7387:	xor    ecx,ecx
    7389:	nop    DWORD PTR [rax+0x0]
    7390:	inc    ecx
    7392:	vmovsd xmm4,QWORD PTR [r8+0x8]
    7398:	vmulsd xmm2,xmm4,QWORD PTR [rax+0x20]
    739d:	vmovsd xmm0,QWORD PTR [r8]
    73a2:	vmovsd xmm3,QWORD PTR [r8+0x10]
    73a8:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x18]
    73ad:	vmulsd xmm5,xmm4,QWORD PTR [rax+0x38]
    73b2:	vmulsd xmm4,xmm4,QWORD PTR [rax+0x8]
    73b7:	vaddsd xmm1,xmm1,xmm2
    73bb:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x28]
    73c0:	vaddsd xmm2,xmm1,xmm2
    73c4:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x30]
    73c9:	vmulsd xmm0,xmm0,QWORD PTR [rax]
    73cd:	vaddsd xmm1,xmm1,xmm5
    73d1:	vmulsd xmm5,xmm3,QWORD PTR [rax+0x40]
    73d6:	vmulsd xmm3,xmm3,QWORD PTR [rax+0x10]
    73db:	vaddsd xmm0,xmm0,xmm4
    73df:	vmovsd QWORD PTR [rdx+0x8],xmm2
    73e4:	vaddsd xmm1,xmm1,xmm5
    73e8:	vaddsd xmm0,xmm0,xmm3
    73ec:	vmovsd QWORD PTR [rdx+0x10],xmm1
    73f1:	vmovsd QWORD PTR [rdx],xmm0
    73f5:	cmp    edi,ecx
    73f7:	jne    7390 <bench_ada_baseline__run_2.isra.0+0x20>
    73f9:	ret
    73fa:	nop    WORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_20.isra.0>:
    d2e0:	push   rbp
    d2e1:	mov    rbp,rsp
    d2e4:	push   r15
    d2e6:	push   r14
    d2e8:	push   r13
    d2ea:	push   r12
    d2ec:	push   rbx
    d2ed:	and    rsp,0xffffffffffffffc0
    d2f1:	add    rsp,0xffffffffffffff80
    d2f5:	mov    r10,QWORD PTR [rbp+0x20]
    d2f9:	mov    QWORD PTR [rsp+0x58],r8
    d2fe:	test   edx,edx
    d300:	je     d5a7 <bench_ada_baseline__run_20.isra.0+0x2c7>
    d306:	mov    r8d,esi
    d309:	xor    eax,eax
    d30b:	mov    DWORD PTR [rsp+0x4c],edi
    d30f:	test   esi,esi
    d311:	lea    rdi,[r8*8+0x0]
    d319:	mov    DWORD PTR [rsp+0x48],edx
    d31d:	mov    QWORD PTR [rsp+0x30],r8
    d322:	mov    DWORD PTR [rsp+0x44],esi
    d326:	cmove  rdi,rax
    d32a:	mov    rbx,rcx
    d32d:	mov    r12,r9
    d330:	cmovne rax,r8
    d334:	mov    QWORD PTR [rsp+0x70],rdi
    d339:	xor    r15d,r15d
    d33c:	imul   rax,rdi
    d340:	shr    rdi,0x3
    d344:	mov    QWORD PTR [rsp+0x50],rax
    d349:	mov    QWORD PTR [rsp+0x78],rdi
    d34e:	xchg   ax,ax
    d350:	mov    rax,QWORD PTR [rsp+0x58]
    d355:	mov    rsi,QWORD PTR [rbp+0x10]
    d359:	mov    rdi,QWORD PTR [rbp+0x18]
    d35d:	mov    rcx,QWORD PTR [rbp+0x28]
    d361:	inc    r15d
    d364:	mov    rdx,QWORD PTR [rsp+0x50]
    d369:	xor    esi,esi
    d36b:	mov    rdi,r10
    d36e:	call   2bd0 <memset@plt>
    d373:	vxorpd xmm7,xmm7,xmm7
    d377:	mov    r10,rax
    d37a:	mov    eax,DWORD PTR [rsp+0x4c]
    d37e:	test   eax,eax
    d380:	je     d58b <bench_ada_baseline__run_20.isra.0+0x2ab>
    d386:	mov    edx,DWORD PTR [rsp+0x44]
    d38a:	test   edx,edx
    d38c:	je     d58b <bench_ada_baseline__run_20.isra.0+0x2ab>
    d392:	lea    rcx,[rax-0x1]
    d396:	mov    rax,QWORD PTR [rsp+0x30]
    d39b:	mov    DWORD PTR [rsp+0x40],r15d
    d3a0:	mov    QWORD PTR [rsp+0x38],r12
    d3a5:	mov    QWORD PTR [rsp+0x60],rcx
    d3aa:	mov    rdi,0xffffffffffffffff
    d3b1:	lea    r13,[rax-0x1]
    d3b5:	vmovq  xmm3,r13
    d3ba:	nop    WORD PTR [rax+rax*1+0x0]
    d3c0:	mov    r14,QWORD PTR [rsp+0x70]
    d3c5:	inc    rdi
    d3c8:	mov    r9d,0x1
    d3ce:	mov    rdx,0xffffffffffffffff
    d3d5:	movsxd rax,edi
    d3d8:	mov    r8,rdi
    d3db:	vmovq  rdi,xmm3
    d3e0:	imul   r14,rax
    d3e4:	lea    rsi,[r14+rbx*1]
    d3e8:	mov    r14,QWORD PTR [rsp+0x78]
    d3ed:	mov    QWORD PTR [rsp+0x68],rsi
    d3f2:	imul   r14,rax
    d3f6:	mov    r13,r14
    d3f9:	jmp    d40c <bench_ada_baseline__run_20.isra.0+0x12c>
    d3fb:	nop    DWORD PTR [rax+rax*1+0x0]
    d400:	inc    r9d
    d403:	cmp    rdx,rdi
    d406:	je     d570 <bench_ada_baseline__run_20.isra.0+0x290>
    d40c:	inc    rdx
    d40f:	movsxd r14,edx
    d412:	mov    esi,edx
    d414:	lea    rax,[r13+r14*1+0x0]
    d419:	vmovsd xmm1,QWORD PTR [rbx+rax*8]
    d41e:	vbroadcastsd zmm2,xmm1
    d424:	test   edx,edx
    d426:	js     d400 <bench_ada_baseline__run_20.isra.0+0x120>
    d428:	vcomisd xmm1,xmm7
    d42c:	je     d400 <bench_ada_baseline__run_20.isra.0+0x120>
    d42e:	mov    ecx,edx
    d430:	cmp    edx,0x6
    d433:	jbe    d5c0 <bench_ada_baseline__run_20.isra.0+0x2e0>
    d439:	mov    r11,QWORD PTR [rsp+0x70]
    d43e:	mov    r15,QWORD PTR [rsp+0x68]
    d443:	mov    r12d,r9d
    d446:	shr    r12d,0x3
    d44a:	vmovapd zmm4,zmm2
    d450:	imul   r11,r14
    d454:	lea    rax,[r11+r10*1]
    d458:	mov    r11d,r12d
    d45b:	shl    r11,0x6
    d45f:	sub    r15,rax
    d462:	add    r11,rax
    d465:	nop    DWORD PTR [rax+rax*1+0x0]
    d46a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    d475:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    d480:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    d487:	add    rax,0x40
    d48b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    d492:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    d499:	cmp    rax,r11
    d49c:	jne    d480 <bench_ada_baseline__run_20.isra.0+0x1a0>
    d49e:	shl    r12d,0x3
    d4a2:	cmp    r12d,r9d
    d4a5:	je     d400 <bench_ada_baseline__run_20.isra.0+0x120>
    d4ab:	lea    r11d,[r12-0x1]
    d4b0:	sub    ecx,r12d
    d4b3:	cmp    ecx,0x2
    d4b6:	jbe    d4ee <bench_ada_baseline__run_20.isra.0+0x20e>
    d4b8:	mov    r15,QWORD PTR [rsp+0x78]
    d4bd:	inc    ecx
    d4bf:	imul   r15,r14
    d4c3:	add    r15,r12
    d4c6:	add    r12,r13
    d4c9:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+r12*8]
    d4cf:	mov    r12d,ecx
    d4d2:	and    r12d,0xfffffffc
    d4d6:	and    ecx,0x3
    d4d9:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+r15*8]
    d4df:	vmovupd YMMWORD PTR [r10+r15*8],ymm2
    d4e5:	je     d400 <bench_ada_baseline__run_20.isra.0+0x120>
    d4eb:	add    r11d,r12d
    d4ee:	mov    rax,QWORD PTR [rsp+0x78]
    d4f3:	lea    ecx,[r11+0x1]
    d4f7:	mov    r12,rcx
    d4fa:	imul   rax,r14
    d4fe:	lea    r14,[rax+rcx*1]
    d502:	add    rcx,r13
    d505:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    d50a:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    d510:	vmovsd QWORD PTR [r10+r14*8],xmm0
    d516:	cmp    r12d,esi
    d519:	je     d400 <bench_ada_baseline__run_20.isra.0+0x120>
    d51f:	lea    ecx,[r11+0x2]
    d523:	lea    r14,[rax+rcx*1]
    d527:	mov    r12,rcx
    d52a:	add    rcx,r13
    d52d:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    d532:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    d538:	vmovsd QWORD PTR [r10+r14*8],xmm0
    d53e:	cmp    r12d,esi
    d541:	je     d400 <bench_ada_baseline__run_20.isra.0+0x120>
    d547:	lea    ecx,[r11+0x3]
    d54b:	inc    r9d
    d54e:	add    rax,rcx
    d551:	add    rcx,r13
    d554:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    d559:	vaddsd xmm1,xmm1,QWORD PTR [r10+rax*8]
    d55f:	vmovsd QWORD PTR [r10+rax*8],xmm1
    d565:	cmp    rdx,rdi
    d568:	jne    d40c <bench_ada_baseline__run_20.isra.0+0x12c>
    d56e:	xchg   ax,ax
    d570:	mov    rdi,r8
    d573:	cmp    r8,QWORD PTR [rsp+0x60]
    d578:	jne    d3c0 <bench_ada_baseline__run_20.isra.0+0xe0>
    d57e:	mov    r15d,DWORD PTR [rsp+0x40]
    d583:	mov    r12,QWORD PTR [rsp+0x38]
    d588:	vzeroupper
    d58b:	mov    rax,QWORD PTR [rsp+0x58]
    d590:	mov    rsi,QWORD PTR [rbp+0x10]
    d594:	mov    rdi,QWORD PTR [rbp+0x18]
    d598:	mov    rcx,QWORD PTR [rbp+0x28]
    d59c:	cmp    DWORD PTR [rsp+0x48],r15d
    d5a1:	jne    d350 <bench_ada_baseline__run_20.isra.0+0x70>
    d5a7:	lea    rsp,[rbp-0x28]
    d5ab:	pop    rbx
    d5ac:	pop    r12
    d5ae:	pop    r13
    d5b0:	pop    r14
    d5b2:	pop    r15
    d5b4:	pop    rbp
    d5b5:	ret
    d5b6:	cs nop WORD PTR [rax+rax*1+0x0]
    d5c0:	xor    r12d,r12d
    d5c3:	mov    r11d,0xffffffff
    d5c9:	jmp    d4b0 <bench_ada_baseline__run_20.isra.0+0x1d0>
    d5ce:	xchg   ax,ax


<bench_ada_baseline__run_3.isra.0>:
    7400:	mov    r10d,edi
    7403:	mov    r11,QWORD PTR [rsp+0x10]
    7408:	mov    rdi,rdx
    740b:	mov    rax,rsi
    740e:	mov    rdx,QWORD PTR [rsp+0x8]
    7413:	test   r10d,r10d
    7416:	je     7480 <bench_ada_baseline__run_3.isra.0+0x80>
    7418:	xor    esi,esi
    741a:	nop    WORD PTR [rax+rax*1+0x0]
    7420:	inc    esi
    7422:	vmovupd xmm0,XMMWORD PTR [r8]
    7427:	vmovsd xmm1,QWORD PTR [rax+0x10]
    742c:	vmovsd xmm3,QWORD PTR [r8+0x10]
    7432:	vunpckhpd xmm2,xmm0,xmm0
    7436:	vmulsd xmm2,xmm2,QWORD PTR [rax+0x28]
    743b:	vmulsd xmm1,xmm1,xmm0
    743f:	vaddsd xmm1,xmm1,xmm2
    7443:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x40]
    7448:	vmovddup xmm3,xmm3
    744c:	vmulpd xmm3,xmm3,XMMWORD PTR [rax+0x30]
    7451:	vaddsd xmm1,xmm1,xmm2
    7455:	vpermilpd xmm2,xmm0,0x0
    745b:	vpermilpd xmm0,xmm0,0x3
    7461:	vmulpd xmm2,xmm2,XMMWORD PTR [rax]
    7465:	vmulpd xmm0,xmm0,XMMWORD PTR [rax+0x18]
    746a:	vmovsd QWORD PTR [rdx+0x10],xmm1
    746f:	vaddpd xmm0,xmm2,xmm0
    7473:	vaddpd xmm0,xmm0,xmm3
    7477:	vmovupd XMMWORD PTR [rdx],xmm0
    747b:	cmp    r10d,esi
    747e:	jne    7420 <bench_ada_baseline__run_3.isra.0+0x20>
    7480:	ret
    7481:	nop
    7482:	nop    DWORD PTR [rax]
    7485:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_4.isra.0>:
    7490:	push   rbp
    7491:	mov    r10d,edi
    7494:	mov    rdi,rcx
    7497:	mov    rbp,rsp
    749a:	push   rbx
    749b:	and    rsp,0xffffffffffffffc0
    749f:	sub    rsp,0x8
    74a3:	mov    rcx,QWORD PTR [rbp+0x10]
    74a7:	mov    r11,QWORD PTR [rbp+0x18]
    74ab:	test   r10d,r10d
    74ae:	je     75f7 <bench_ada_baseline__run_4.isra.0+0x167>
    74b4:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2e102]        # 355c0 <__gnat_ada_main_program_name+0x30>
    74be:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2e138]        # 35600 <__gnat_ada_main_program_name+0x70>
    74c8:	mov    rax,rsi
    74cb:	xor    esi,esi
    74cd:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2e169]        # 35640 <__gnat_ada_main_program_name+0xb0>
    74d7:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2e19f]        # 35680 <__gnat_ada_main_program_name+0xf0>
    74e1:	nop    DWORD PTR [rax+0x0]
    74e5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    74f0:	inc    esi
    74f2:	vmovupd zmm1,ZMMWORD PTR [rdx]
    74f8:	vmovupd zmm4,ZMMWORD PTR [rax]
    74fe:	vmovsd xmm6,QWORD PTR [rdx+0x40]
    7503:	vmovsd xmm12,QWORD PTR [rdx+0x30]
    7508:	vmovsd xmm5,QWORD PTR [rdx+0x38]
    750d:	vmovsd xmm3,QWORD PTR [rax+0x10]
    7512:	vmovsd xmm7,QWORD PTR [rax+0x28]
    7517:	vmovsd xmm13,QWORD PTR [rax+0x40]
    751c:	vpermpd zmm2,zmm10,zmm1
    7522:	vpermpd zmm0,zmm11,zmm4
    7528:	vpermpd zmm14,zmm8,zmm4
    752e:	vmulpd zmm0,zmm0,zmm2
    7534:	vpermpd zmm2,zmm9,zmm1
    753a:	vmulpd zmm2,zmm2,zmm14
    7540:	vaddpd zmm0,zmm0,zmm2
    7546:	vunpcklpd xmm2,xmm12,xmm5
    754a:	vunpcklpd xmm12,xmm6,xmm12
    754f:	vunpcklpd xmm5,xmm5,xmm6
    7553:	vinsertf64x2 ymm5,ymm5,xmm2,0x1
    755a:	vmulsd xmm6,xmm6,xmm13
    755f:	vinsertf64x2 ymm2,ymm2,xmm12,0x1
    7566:	vmovddup xmm12,xmm13
    756b:	vinsertf64x4 zmm2,zmm2,ymm5,0x1
    7572:	vmovddup xmm5,xmm7
    7576:	vunpcklpd xmm7,xmm3,xmm7
    757a:	vmovddup xmm3,xmm3
    757e:	vinsertf64x2 ymm5,ymm5,xmm12,0x1
    7585:	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    758c:	vinsertf64x4 zmm3,zmm3,ymm5,0x1
    7593:	vmulpd zmm2,zmm2,zmm3
    7599:	vextractf64x2 xmm3,zmm4,0x3
    75a0:	vaddpd zmm0,zmm0,zmm2
    75a6:	vmovdqu64 ZMMWORD PTR [rcx],zmm0
    75ac:	vmovapd ZMMWORD PTR [rsp-0x78],zmm0
    75b7:	vextractf64x2 xmm2,ymm1,0x1
    75be:	valignq zmm4,zmm4,zmm4,0x7
    75c5:	vmulsd xmm2,xmm2,xmm3
    75c9:	valignq zmm1,zmm1,zmm1,0x5
    75d0:	vmulsd xmm1,xmm1,xmm4
    75d4:	vaddsd xmm1,xmm2,xmm1
    75d8:	vaddsd xmm1,xmm1,xmm6
    75dc:	vmovsd QWORD PTR [rsp-0x38],xmm1
    75e2:	mov    rbx,QWORD PTR [rsp-0x38]
    75e7:	mov    QWORD PTR [rcx+0x40],rbx
    75eb:	cmp    r10d,esi
    75ee:	jne    74f0 <bench_ada_baseline__run_4.isra.0+0x60>
    75f4:	vzeroupper
    75f7:	mov    rbx,QWORD PTR [rbp-0x8]
    75fb:	leave
    75fc:	ret
    75fd:	nop
    75fe:	xchg   ax,ax


<bench_ada_baseline__run_5.isra.0>:
    7600:	push   rbp
    7601:	mov    r10d,edi
    7604:	mov    rdi,rcx
    7607:	mov    rbp,rsp
    760a:	push   rbx
    760b:	and    rsp,0xffffffffffffffc0
    760f:	sub    rsp,0x8
    7613:	mov    rcx,QWORD PTR [rbp+0x10]
    7617:	mov    r11,QWORD PTR [rbp+0x18]
    761b:	test   r10d,r10d
    761e:	je     7767 <bench_ada_baseline__run_5.isra.0+0x167>
    7624:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2e092]        # 356c0 <__gnat_ada_main_program_name+0x130>
    762e:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2dfc8]        # 35600 <__gnat_ada_main_program_name+0x70>
    7638:	mov    rax,rsi
    763b:	xor    esi,esi
    763d:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2dff9]        # 35640 <__gnat_ada_main_program_name+0xb0>
    7647:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2e0af]        # 35700 <__gnat_ada_main_program_name+0x170>
    7651:	nop    DWORD PTR [rax+0x0]
    7655:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7660:	inc    esi
    7662:	vmovupd zmm1,ZMMWORD PTR [rdx]
    7668:	vmovupd zmm4,ZMMWORD PTR [rax]
    766e:	vmovsd xmm6,QWORD PTR [rdx+0x40]
    7673:	vmovsd xmm12,QWORD PTR [rdx+0x30]
    7678:	vmovsd xmm5,QWORD PTR [rdx+0x38]
    767d:	vmovsd xmm3,QWORD PTR [rax+0x30]
    7682:	vmovsd xmm7,QWORD PTR [rax+0x38]
    7687:	vmovsd xmm13,QWORD PTR [rax+0x40]
    768c:	vpermpd zmm2,zmm10,zmm1
    7692:	vpermpd zmm0,zmm11,zmm4
    7698:	vpermpd zmm14,zmm8,zmm4
    769e:	vmulpd zmm0,zmm0,zmm2
    76a4:	vpermpd zmm2,zmm9,zmm1
    76aa:	vmulpd zmm2,zmm2,zmm14
    76b0:	vaddpd zmm0,zmm0,zmm2
    76b6:	vunpcklpd xmm2,xmm12,xmm5
    76ba:	vunpcklpd xmm12,xmm6,xmm12
    76bf:	vunpcklpd xmm5,xmm5,xmm6
    76c3:	vinsertf64x2 ymm5,ymm5,xmm2,0x1
    76ca:	vmulsd xmm6,xmm6,xmm13
    76cf:	vinsertf64x2 ymm2,ymm2,xmm12,0x1
    76d6:	vmovddup xmm12,xmm13
    76db:	vinsertf64x4 zmm2,zmm2,ymm5,0x1
    76e2:	vmovddup xmm5,xmm7
    76e6:	vunpcklpd xmm7,xmm3,xmm7
    76ea:	vmovddup xmm3,xmm3
    76ee:	vinsertf64x2 ymm5,ymm5,xmm12,0x1
    76f5:	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    76fc:	vinsertf64x4 zmm3,zmm3,ymm5,0x1
    7703:	vmulpd zmm2,zmm2,zmm3
    7709:	vextractf64x2 xmm3,ymm4,0x1
    7710:	vaddpd zmm0,zmm0,zmm2
    7716:	vmovdqu64 ZMMWORD PTR [rcx],zmm0
    771c:	vmovapd ZMMWORD PTR [rsp-0x78],zmm0
    7727:	vextractf64x2 xmm2,ymm1,0x1
    772e:	valignq zmm4,zmm4,zmm4,0x5
    7735:	vmulsd xmm2,xmm2,xmm3
    7739:	valignq zmm1,zmm1,zmm1,0x5
    7740:	vmulsd xmm1,xmm1,xmm4
    7744:	vaddsd xmm1,xmm2,xmm1
    7748:	vaddsd xmm1,xmm1,xmm6
    774c:	vmovsd QWORD PTR [rsp-0x38],xmm1
    7752:	mov    rbx,QWORD PTR [rsp-0x38]
    7757:	mov    QWORD PTR [rcx+0x40],rbx
    775b:	cmp    r10d,esi
    775e:	jne    7660 <bench_ada_baseline__run_5.isra.0+0x60>
    7764:	vzeroupper
    7767:	mov    rbx,QWORD PTR [rbp-0x8]
    776b:	leave
    776c:	ret
    776d:	nop
    776e:	xchg   ax,ax


<bench_ada_baseline__run_6.isra.0>:
    7770:	push   rbp
    7771:	mov    r10d,edi
    7774:	mov    rdi,rcx
    7777:	mov    rbp,rsp
    777a:	push   rbx
    777b:	and    rsp,0xffffffffffffffc0
    777f:	sub    rsp,0x8
    7783:	mov    rcx,QWORD PTR [rbp+0x10]
    7787:	mov    r11,QWORD PTR [rbp+0x18]
    778b:	test   r10d,r10d
    778e:	je     78d7 <bench_ada_baseline__run_6.isra.0+0x167>
    7794:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2de22]        # 355c0 <__gnat_ada_main_program_name+0x30>
    779e:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2df98]        # 35740 <__gnat_ada_main_program_name+0x1b0>
    77a8:	mov    rax,rsi
    77ab:	xor    esi,esi
    77ad:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2dfc9]        # 35780 <__gnat_ada_main_program_name+0x1f0>
    77b7:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2debf]        # 35680 <__gnat_ada_main_program_name+0xf0>
    77c1:	nop    DWORD PTR [rax+0x0]
    77c5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    77d0:	inc    esi
    77d2:	vmovupd zmm1,ZMMWORD PTR [rdx]
    77d8:	vmovupd zmm4,ZMMWORD PTR [rax]
    77de:	vmovsd xmm6,QWORD PTR [rdx+0x40]
    77e3:	vmovsd xmm12,QWORD PTR [rdx+0x10]
    77e8:	vmovsd xmm5,QWORD PTR [rdx+0x28]
    77ed:	vmovsd xmm3,QWORD PTR [rax+0x10]
    77f2:	vmovsd xmm7,QWORD PTR [rax+0x28]
    77f7:	vmovsd xmm13,QWORD PTR [rax+0x40]
    77fc:	vpermpd zmm2,zmm10,zmm1
    7802:	vpermpd zmm0,zmm11,zmm4
    7808:	vpermpd zmm14,zmm8,zmm4
    780e:	vmulpd zmm0,zmm0,zmm2
    7814:	vpermpd zmm2,zmm9,zmm1
    781a:	vmulpd zmm2,zmm2,zmm14
    7820:	vaddpd zmm0,zmm0,zmm2
    7826:	vunpcklpd xmm2,xmm12,xmm5
    782a:	vunpcklpd xmm12,xmm6,xmm12
    782f:	vunpcklpd xmm5,xmm5,xmm6
    7833:	vinsertf64x2 ymm5,ymm5,xmm2,0x1
    783a:	vmulsd xmm6,xmm6,xmm13
    783f:	vinsertf64x2 ymm2,ymm2,xmm12,0x1
    7846:	vmovddup xmm12,xmm13
    784b:	vinsertf64x4 zmm2,zmm2,ymm5,0x1
    7852:	vmovddup xmm5,xmm7
    7856:	vunpcklpd xmm7,xmm3,xmm7
    785a:	vmovddup xmm3,xmm3
    785e:	vinsertf64x2 ymm5,ymm5,xmm12,0x1
    7865:	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    786c:	vinsertf64x4 zmm3,zmm3,ymm5,0x1
    7873:	vmulpd zmm2,zmm2,zmm3
    7879:	vextractf64x2 xmm3,zmm4,0x3
    7880:	vaddpd zmm0,zmm0,zmm2
    7886:	vmovdqu64 ZMMWORD PTR [rcx],zmm0
    788c:	vmovapd ZMMWORD PTR [rsp-0x78],zmm0
    7897:	vextractf64x2 xmm2,zmm1,0x3
    789e:	valignq zmm4,zmm4,zmm4,0x7
    78a5:	vmulsd xmm2,xmm2,xmm3
    78a9:	valignq zmm1,zmm1,zmm1,0x7
    78b0:	vmulsd xmm1,xmm1,xmm4
    78b4:	vaddsd xmm1,xmm2,xmm1
    78b8:	vaddsd xmm1,xmm1,xmm6
    78bc:	vmovsd QWORD PTR [rsp-0x38],xmm1
    78c2:	mov    rbx,QWORD PTR [rsp-0x38]
    78c7:	mov    QWORD PTR [rcx+0x40],rbx
    78cb:	cmp    r10d,esi
    78ce:	jne    77d0 <bench_ada_baseline__run_6.isra.0+0x60>
    78d4:	vzeroupper
    78d7:	mov    rbx,QWORD PTR [rbp-0x8]
    78db:	leave
    78dc:	ret
    78dd:	nop
    78de:	xchg   ax,ax


<bench_ada_baseline__run_7.isra.0>:
    78e0:	sub    rsp,0x78
    78e4:	mov    QWORD PTR [rsp+0x8],r9
    78e9:	test   edx,edx
    78eb:	je     7a09 <bench_ada_baseline__run_7.isra.0+0x129>
    78f1:	mov    QWORD PTR [rsp+0x48],rbx
    78f6:	mov    rbx,rcx
    78f9:	mov    QWORD PTR [rsp+0x68],r14
    78fe:	mov    QWORD PTR [rsp+0x70],r15
    7903:	mov    r14,rbx
    7906:	mov    r15,QWORD PTR [rsp+0x80]
    790e:	mov    DWORD PTR [rsp+0x1c],edx
    7912:	mov    QWORD PTR [rsp+0x10],r8
    7917:	mov    rbx,QWORD PTR [rsp+0x90]
    791f:	lea    rcx,[rsp+0x30]
    7924:	mov    QWORD PTR [rsp+0x50],rbp
    7929:	mov    QWORD PTR [rsp+0x58],r12
    792e:	mov    QWORD PTR [rsp+0x60],r13
    7933:	lea    r12d,[rdi-0x1]
    7937:	lea    ebp,[rsi-0x1]
    793a:	xor    r13d,r13d
    793d:	vmovq  xmm16,rcx
    7943:	xchg   ax,ax
    7945:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7950:	mov    rax,QWORD PTR [rsp+0x10]
    7955:	mov    rcx,QWORD PTR [rsp+0x8]
    795a:	mov    rsi,QWORD PTR [rsp+0x88]
    7962:	mov    rdi,QWORD PTR [rsp+0x98]
    796a:	inc    r13d
    796d:	lea    rax,[rsp+0x20]
    7972:	lea    rdx,[rsp+0x28]
    7977:	vmovq  rsi,xmm16
    797d:	mov    rdi,rbx
    7980:	mov    r9,rdx
    7983:	mov    rcx,rsi
    7986:	mov    rdx,r14
    7989:	mov    rsi,rax
    798c:	mov    r8,r15
    798f:	mov    DWORD PTR [rsp+0x28],0x0
    7997:	mov    DWORD PTR [rsp+0x2c],ebp
    799b:	mov    DWORD PTR [rsp+0x30],0x0
    79a3:	mov    DWORD PTR [rsp+0x34],r12d
    79a8:	mov    DWORD PTR [rsp+0x38],0x0
    79b0:	mov    DWORD PTR [rsp+0x3c],ebp
    79b4:	mov    DWORD PTR [rsp+0x20],0x0
    79bc:	mov    DWORD PTR [rsp+0x24],r12d
    79c1:	call   4280 <mj__matrices__mulmatvec>
    79c6:	mov    rax,QWORD PTR [rsp+0x10]
    79cb:	mov    rcx,QWORD PTR [rsp+0x8]
    79d0:	mov    rdi,QWORD PTR [rsp+0x88]
    79d8:	mov    rdx,QWORD PTR [rsp+0x98]
    79e0:	cmp    DWORD PTR [rsp+0x1c],r13d
    79e5:	jne    7950 <bench_ada_baseline__run_7.isra.0+0x70>
    79eb:	mov    rbx,QWORD PTR [rsp+0x48]
    79f0:	mov    rbp,QWORD PTR [rsp+0x50]
    79f5:	mov    r12,QWORD PTR [rsp+0x58]
    79fa:	mov    r13,QWORD PTR [rsp+0x60]
    79ff:	mov    r14,QWORD PTR [rsp+0x68]
    7a04:	mov    r15,QWORD PTR [rsp+0x70]
    7a09:	add    rsp,0x78
    7a0d:	ret
    7a0e:	xchg   ax,ax


<bench_ada_baseline__run_8.isra.0>:
    9f90:	sub    rsp,0x68
    9f94:	mov    QWORD PTR [rsp+0x50],r13
    9f99:	mov    r13,QWORD PTR [rsp+0x80]
    9fa1:	test   edx,edx
    9fa3:	je     a087 <bench_ada_baseline__run_8.isra.0+0xf7>
    9fa9:	lea    eax,[rsi-0x1]
    9fac:	mov    DWORD PTR [rsp+0xc],edx
    9fb0:	mov    QWORD PTR [rsp+0x38],rbx
    9fb5:	mov    QWORD PTR [rsp+0x40],rbp
    9fba:	mov    DWORD PTR [rsp+0x8],eax
    9fbe:	mov    QWORD PTR [rsp+0x48],r12
    9fc3:	mov    QWORD PTR [rsp+0x58],r14
    9fc8:	mov    QWORD PTR [rsp+0x60],r15
    9fcd:	mov    rbx,rcx
    9fd0:	mov    r15,r8
    9fd3:	mov    rbp,r9
    9fd6:	lea    r14d,[rdi-0x1]
    9fda:	xor    r12d,r12d
    9fdd:	nop    DWORD PTR [rax]
    9fe0:	mov    rax,QWORD PTR [rsp+0x70]
    9fe5:	mov    rcx,QWORD PTR [rsp+0x78]
    9fea:	mov    rsi,QWORD PTR [rsp+0x88]
    9ff2:	inc    r12d
    9ff5:	lea    rax,[rsp+0x18]
    9ffa:	lea    rcx,[rsp+0x20]
    9fff:	mov    rdi,r13
    a002:	mov    rdx,rbx
    a005:	mov    r11,rax
    a008:	mov    eax,DWORD PTR [rsp+0x8]
    a00c:	mov    r8,rbp
    a00f:	mov    DWORD PTR [rsp+0x18],0x0
    a017:	mov    r9,r11
    a01a:	mov    DWORD PTR [rsp+0x1c],r14d
    a01f:	mov    DWORD PTR [rsp+0x20],0x0
    a027:	mov    DWORD PTR [rsp+0x24],r14d
    a02c:	mov    DWORD PTR [rsp+0x28],0x0
    a034:	mov    DWORD PTR [rsp+0x10],0x0
    a03c:	mov    DWORD PTR [rsp+0x2c],eax
    a040:	mov    DWORD PTR [rsp+0x14],eax
    a044:	lea    rax,[rsp+0x10]
    a049:	mov    rsi,rax
    a04c:	call   9c50 <mj__matrices__mulmattvec>
    a051:	mov    rax,QWORD PTR [rsp+0x70]
    a056:	mov    rdi,QWORD PTR [rsp+0x78]
    a05b:	mov    rcx,QWORD PTR [rsp+0x88]
    a063:	cmp    DWORD PTR [rsp+0xc],r12d
    a068:	jne    9fe0 <bench_ada_baseline__run_8.isra.0+0x50>
    a06e:	mov    rbx,QWORD PTR [rsp+0x38]
    a073:	mov    rbp,QWORD PTR [rsp+0x40]
    a078:	mov    r12,QWORD PTR [rsp+0x48]
    a07d:	mov    r14,QWORD PTR [rsp+0x58]
    a082:	mov    r15,QWORD PTR [rsp+0x60]
    a087:	mov    r13,QWORD PTR [rsp+0x50]
    a08c:	add    rsp,0x68
    a090:	ret
    a091:	nop
    a092:	nop    DWORD PTR [rax]
    a095:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada_baseline__run_9.isra.0>:
    7a10:	vxorpd xmm16,xmm16,xmm16
    7a16:	test   esi,esi
    7a18:	je     7b16 <bench_ada_baseline__run_9.isra.0+0x106>
    7a1e:	push   r15
    7a20:	push   r14
    7a22:	push   r13
    7a24:	push   r12
    7a26:	push   rbp
    7a27:	push   rbx
    7a28:	mov    r15,rcx
    7a2b:	lea    ebx,[rdi-0x1]
    7a2e:	sub    rsp,0x38
    7a32:	xor    r14d,r14d
    7a35:	mov    r12,r8
    7a38:	mov    rbp,rdx
    7a3b:	mov    DWORD PTR [rsp+0xc],esi
    7a3f:	lea    rax,[rsp+0x18]
    7a44:	mov    r13,r9
    7a47:	vmovq  xmm19,rax
    7a4d:	lea    rax,[rsp+0x20]
    7a52:	vmovq  xmm18,rax
    7a58:	lea    rax,[rsp+0x10]
    7a5d:	vmovq  xmm17,rax
    7a63:	xchg   ax,ax
    7a65:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7a70:	mov    rax,QWORD PTR [rsp+0x70]
    7a75:	mov    rcx,QWORD PTR [rsp+0x78]
    7a7a:	mov    rdx,QWORD PTR [rsp+0x80]
    7a82:	inc    r14d
    7a85:	vmovq  rax,xmm19
    7a8b:	vmovq  rdx,xmm17
    7a91:	mov    r8,r13
    7a94:	mov    rdi,r12
    7a97:	mov    r9,rax
    7a9a:	vmovq  rax,xmm18
    7aa0:	mov    rsi,rdx
    7aa3:	mov    rdx,rbp
    7aa6:	mov    rcx,rax
    7aa9:	mov    DWORD PTR [rsp+0x18],0x0
    7ab1:	mov    DWORD PTR [rsp+0x1c],ebx
    7ab5:	mov    DWORD PTR [rsp+0x20],0x0
    7abd:	mov    DWORD PTR [rsp+0x24],ebx
    7ac1:	mov    DWORD PTR [rsp+0x28],0x0
    7ac9:	mov    DWORD PTR [rsp+0x2c],ebx
    7acd:	mov    DWORD PTR [rsp+0x10],0x0
    7ad5:	mov    DWORD PTR [rsp+0x14],ebx
    7ad9:	call   4800 <mj__matrices__mulvecmatvec>
    7ade:	mov    rax,QWORD PTR [rsp+0x70]
    7ae3:	mov    rcx,QWORD PTR [rsp+0x78]
    7ae8:	mov    rsi,QWORD PTR [rsp+0x80]
    7af0:	vaddsd xmm16,xmm16,xmm0
    7af6:	cmp    DWORD PTR [rsp+0xc],r14d
    7afb:	jne    7a70 <bench_ada_baseline__run_9.isra.0+0x60>
    7b01:	add    rsp,0x38
    7b05:	vmovapd xmm0,xmm16
    7b0b:	pop    rbx
    7b0c:	pop    rbp
    7b0d:	pop    r12
    7b0f:	pop    r13
    7b11:	pop    r14
    7b13:	pop    r15
    7b15:	ret
    7b16:	vmovapd xmm0,xmm16
    7b1c:	ret
    7b1d:	nop
    7b1e:	xchg   ax,ax


<c_run_1.isra.0>:
    8590:	mov    rax,rsi
    8593:	mov    r10,QWORD PTR [rsp+0x10]
    8598:	mov    rsi,QWORD PTR [rsp+0x8]
    859d:	mov    r11d,edi
    85a0:	test   edi,edi
    85a2:	je     860f <c_run_1.isra.0+0x7f>
    85a4:	xor    edi,edi
    85a6:	cs nop WORD PTR [rax+rax*1+0x0]
    85b0:	vmovsd xmm0,QWORD PTR [rax]
    85b4:	vmovsd QWORD PTR [rsi],xmm0
    85b8:	vmovsd xmm0,QWORD PTR [rax+0x8]
    85bd:	vmovsd QWORD PTR [rsi+0x8],xmm0
    85c2:	vmovsd xmm0,QWORD PTR [rax+0x10]
    85c7:	vmovsd QWORD PTR [rsi+0x10],xmm0
    85cc:	vmovsd xmm0,QWORD PTR [rax+0x18]
    85d1:	vmovsd QWORD PTR [rsi+0x18],xmm0
    85d6:	vmovsd xmm0,QWORD PTR [rax+0x20]
    85db:	vmovsd QWORD PTR [rsi+0x20],xmm0
    85e0:	vmovsd xmm0,QWORD PTR [rax+0x28]
    85e5:	vmovsd QWORD PTR [rsi+0x28],xmm0
    85ea:	vmovsd xmm0,QWORD PTR [rax+0x30]
    85ef:	vmovsd QWORD PTR [rsi+0x30],xmm0
    85f4:	vmovsd xmm0,QWORD PTR [rax+0x38]
    85f9:	vmovsd QWORD PTR [rsi+0x38],xmm0
    85fe:	vmovsd xmm0,QWORD PTR [rax+0x40]
    8603:	vmovsd QWORD PTR [rsi+0x40],xmm0
    8608:	inc    edi
    860a:	cmp    edi,r11d
    860d:	jne    85b0 <c_run_1.isra.0+0x20>
    860f:	ret


<c_run_10.isra.0>:
    8c40:	sub    rsp,0x30
    8c44:	mov    QWORD PTR [rsp+0x18],r13
    8c49:	mov    QWORD PTR [rsp+0x20],r14
    8c4e:	mov    QWORD PTR [rsp+0x28],r15
    8c53:	mov    DWORD PTR [rsp-0xc],edx
    8c57:	mov    r15,QWORD PTR [rsp+0x38]
    8c5c:	mov    r13,QWORD PTR [rsp+0x40]
    8c61:	mov    rax,QWORD PTR [rsp+0x48]
    8c66:	mov    r14,QWORD PTR [rsp+0x50]
    8c6b:	test   edx,edx
    8c6d:	je     8d24 <c_run_10.isra.0+0xe4>
    8c73:	mov    QWORD PTR [rsp],rbx
    8c77:	mov    QWORD PTR [rsp+0x8],rbp
    8c7c:	mov    QWORD PTR [rsp+0x10],r12
    8c81:	mov    r10d,edi
    8c84:	mov    rbx,rcx
    8c87:	mov    rbp,r8
    8c8a:	mov    r12,r9
    8c8d:	test   edi,edi
    8c8f:	je     8d38 <c_run_10.isra.0+0xf8>
    8c95:	xor    r11d,r11d
    8c98:	test   esi,esi
    8c9a:	je     8d50 <c_run_10.isra.0+0x110>
    8ca0:	mov    esi,esi
    8ca2:	lea    r9,[rsi*8+0x0]
    8caa:	mov    esi,edi
    8cac:	lea    rdx,[rcx+r9*1]
    8cb0:	shl    rsi,0x3
    8cb4:	mov    QWORD PTR [rsp-0x8],rdx
    8cb9:	mov    rdx,rcx
    8cbc:	nop    DWORD PTR [rax+0x0]
    8cc0:	mov    rdi,QWORD PTR [rsp-0x8]
    8cc5:	mov    DWORD PTR [rsp-0x10],r11d
    8cca:	mov    rbx,rax
    8ccd:	xor    r8d,r8d
    8cd0:	mov    rcx,rdi
    8cd3:	sub    rcx,r9
    8cd6:	mov    r11,rbx
    8cd9:	nop    DWORD PTR [rax+0x0]
    8ce0:	vmovsd xmm0,QWORD PTR [rcx]
    8ce4:	add    rcx,0x8
    8ce8:	vmovsd QWORD PTR [r11],xmm0
    8ced:	add    r11,rsi
    8cf0:	cmp    rcx,rdi
    8cf3:	jne    8ce0 <c_run_10.isra.0+0xa0>
    8cf5:	inc    r8d
    8cf8:	add    rbx,0x8
    8cfc:	lea    rdi,[rcx+r9*1]
    8d00:	cmp    r10d,r8d
    8d03:	jne    8cd0 <c_run_10.isra.0+0x90>
    8d05:	mov    r11d,DWORD PTR [rsp-0x10]
    8d0a:	inc    r11d
    8d0d:	cmp    DWORD PTR [rsp-0xc],r11d
    8d12:	je     8d16 <c_run_10.isra.0+0xd6>
    8d14:	jmp    8cc0 <c_run_10.isra.0+0x80>
    8d16:	mov    rbx,QWORD PTR [rsp]
    8d1a:	mov    rbp,QWORD PTR [rsp+0x8]
    8d1f:	mov    r12,QWORD PTR [rsp+0x10]
    8d24:	mov    r13,QWORD PTR [rsp+0x18]
    8d29:	mov    r14,QWORD PTR [rsp+0x20]
    8d2e:	mov    r15,QWORD PTR [rsp+0x28]
    8d33:	add    rsp,0x30
    8d37:	ret
    8d38:	mov    edi,DWORD PTR [rsp-0xc]
    8d3c:	lea    edx,[r10+0x1]
    8d40:	cmp    edi,edx
    8d42:	je     8d16 <c_run_10.isra.0+0xd6>
    8d44:	add    r10d,0x2
    8d48:	cmp    edi,r10d
    8d4b:	je     8d16 <c_run_10.isra.0+0xd6>
    8d4d:	jmp    8d38 <c_run_10.isra.0+0xf8>
    8d4f:	nop
    8d50:	mov    edi,DWORD PTR [rsp-0xc]
    8d54:	lea    edx,[r11+0x1]
    8d58:	cmp    edi,edx
    8d5a:	je     8d16 <c_run_10.isra.0+0xd6>
    8d5c:	add    r11d,0x2
    8d60:	cmp    edi,r11d
    8d63:	je     8d16 <c_run_10.isra.0+0xd6>
    8d65:	jmp    8d50 <c_run_10.isra.0+0x110>
    8d67:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_11.isra.0>:
    8d70:	sub    rsp,0x50
    8d74:	mov    QWORD PTR [rsp+0x48],r15
    8d79:	mov    DWORD PTR [rsp-0x60],edi
    8d7d:	mov    DWORD PTR [rsp+0xc],esi
    8d81:	mov    r15,QWORD PTR [rsp+0x60]
    8d86:	mov    r11,QWORD PTR [rsp+0x68]
    8d8b:	test   esi,esi
    8d8d:	je     9148 <c_run_11.isra.0+0x3d8>
    8d93:	mov    QWORD PTR [rsp+0x28],rbp
    8d98:	mov    QWORD PTR [rsp+0x38],r13
    8d9d:	mov    rax,QWORD PTR [rsp+0x58]
    8da2:	mov    r10,rdx
    8da5:	mov    r13,rcx
    8da8:	mov    rbp,r8
    8dab:	mov    esi,edi
    8dad:	test   edi,edi
    8daf:	je     915a <c_run_11.isra.0+0x3ea>
    8db5:	lea    eax,[rdi-0x1]
    8db8:	xor    edx,edx
    8dba:	mov    QWORD PTR [rsp+0x20],rbx
    8dbf:	lea    ecx,[rdi+0x1]
    8dc2:	test   eax,eax
    8dc4:	vmovsd xmm4,QWORD PTR [rip+0x2ed8c]        # 37b58 <system__os_lib__standin+0xc>
    8dcc:	mov    QWORD PTR [rsp+0x40],r14
    8dd1:	mov    QWORD PTR [rsp+0x30],r12
    8dd6:	cmovg  eax,edx
    8dd9:	mov    rbp,r11
    8ddc:	xor    r12d,r12d
    8ddf:	lea    edx,[rax+0x1]
    8de2:	lea    rax,[rdx*8+0x0]
    8dea:	mov    rdi,rdx
    8ded:	mov    DWORD PTR [rsp+0x8],edx
    8df1:	mov    QWORD PTR [rsp-0x8],rdx
    8df6:	lea    rbx,[r10+rax*1]
    8dfa:	add    rax,r15
    8dfd:	mov    QWORD PTR [rsp-0x38],rbx
    8e02:	mov    ebx,esi
    8e04:	mov    QWORD PTR [rsp-0x10],rax
    8e09:	add    rdx,rbx
    8e0c:	mov    QWORD PTR [rsp-0x68],rbx
    8e11:	vmovddup xmm3,xmm4
    8e15:	shl    rdx,0x3
    8e19:	lea    rax,[rdx+r10*1]
    8e1d:	mov    QWORD PTR [rsp-0x18],rax
    8e22:	mov    eax,edi
    8e24:	mov    edi,esi
    8e26:	lea    rsi,[rdx+r15*1]
    8e2a:	neg    eax
    8e2c:	mov    edx,ecx
    8e2e:	mov    QWORD PTR [rsp-0x28],rsi
    8e33:	lea    rsi,[rbx*8+0x0]
    8e3b:	and    edi,eax
    8e3d:	and    eax,ecx
    8e3f:	mov    rbx,r9
    8e42:	vmovq  xmm5,rsi
    8e47:	shl    rax,0x3
    8e4b:	lea    rcx,[r10+rax*1]
    8e4f:	add    rax,r15
    8e52:	mov    QWORD PTR [rsp-0x20],rdi
    8e57:	lea    rdi,[rdx*8+0x0]
    8e5f:	mov    QWORD PTR [rsp],rax
    8e63:	lea    rax,[r10+0x8]
    8e67:	mov    QWORD PTR [rsp-0x30],rdi
    8e6c:	vmovq  xmm6,rcx
    8e71:	mov    QWORD PTR [rsp+0x10],rax
    8e76:	mov    r9,r8
    8e79:	nop    DWORD PTR [rax+0x0]
    8e80:	vmovsd xmm0,QWORD PTR [r10]
    8e85:	mov    edi,DWORD PTR [rsp+0x8]
    8e89:	vmovsd QWORD PTR [r15],xmm0
    8e8e:	cmp    DWORD PTR [rsp-0x60],edi
    8e92:	jle    90b5 <c_run_11.isra.0+0x345>
    8e98:	mov    rax,QWORD PTR [rsp-0x20]
    8e9d:	mov    rdi,QWORD PTR [rsp-0x28]
    8ea2:	mov    rsi,QWORD PTR [rsp-0x18]
    8ea7:	mov    rcx,QWORD PTR [rsp-0x38]
    8eac:	mov    rdx,QWORD PTR [rsp-0x8]
    8eb1:	mov    DWORD PTR [rsp-0x5c],r12d
    8eb6:	mov    QWORD PTR [rsp-0x58],r13
    8ebb:	mov    QWORD PTR [rsp-0x50],r9
    8ec0:	mov    QWORD PTR [rsp-0x48],rbx
    8ec5:	mov    QWORD PTR [rsp+0x68],rbp
    8eca:	xor    r11d,r11d
    8ecd:	mov    QWORD PTR [rsp-0x70],rax
    8ed2:	mov    rax,QWORD PTR [rsp-0x10]
    8ed7:	vmovq  rbx,xmm6
    8edc:	lea    r8d,[rdx-0x1]
    8ee0:	mov    DWORD PTR [rsp-0x3c],edx
    8ee4:	vmovsd xmm0,QWORD PTR [rbx+r11*1]
    8eea:	mov    rbx,QWORD PTR [rsp]
    8eee:	vmovsd QWORD PTR [rbx+r11*1],xmm0
    8ef4:	cmp    r8d,0x20
    8ef8:	jbe    90ce <c_run_11.isra.0+0x35e>
    8efe:	mov    ebx,edx
    8f00:	mov    r13,QWORD PTR [rsp-0x70]
    8f05:	lea    r8,[rbx-0x1]
    8f09:	imul   r8,QWORD PTR [rsp-0x68]
    8f0f:	lea    rbx,[rbx+r13*1-0x1]
    8f14:	lea    r9,[r13*8+0x0]
    8f1c:	shl    rbx,0x3
    8f20:	add    r8,rdx
    8f23:	lea    rbp,[r15+r9*1]
    8f27:	lea    r14,[r10+r9*1]
    8f2b:	shl    r8,0x3
    8f2f:	lea    r12,[r10+r8*1]
    8f33:	cmp    r12,rbp
    8f36:	lea    r12,[r15+rbx*1]
    8f3a:	setb   r13b
    8f3e:	cmp    r12,rcx
    8f41:	setb   r12b
    8f45:	or     r13d,r12d
    8f48:	lea    r12,[r10+rbx*1]
    8f4c:	cmp    r12,rax
    8f4f:	mov    BYTE PTR [rsp-0x3e],r13b
    8f54:	lea    r13,[r15+r8*1]
    8f58:	setb   r12b
    8f5c:	cmp    r13,r14
    8f5f:	setb   BYTE PTR [rsp-0x3d]
    8f64:	or     r12b,BYTE PTR [rsp-0x3d]
    8f69:	test   BYTE PTR [rsp-0x3e],r12b
    8f6e:	je     90db <c_run_11.isra.0+0x36b>
    8f74:	lea    r12,[rdx*8+0x0]
    8f7c:	cmp    rbx,r12
    8f7f:	setl   bl
    8f82:	cmp    r8,r9
    8f85:	setl   r8b
    8f89:	or     ebx,r8d
    8f8c:	cmp    QWORD PTR [rsp+0x10],r15
    8f91:	setne  r8b
    8f95:	cmp    rsi,rax
    8f98:	setne  r12b
    8f9c:	and    r8d,r12d
    8f9f:	test   bl,r8b
    8fa2:	je     90db <c_run_11.isra.0+0x36b>
    8fa8:	cmp    edx,0x1
    8fab:	je     9152 <c_run_11.isra.0+0x3e2>
    8fb1:	mov    r12,QWORD PTR [rsp-0x68]
    8fb6:	mov    r13d,edx
    8fb9:	shr    r13d,1
    8fbc:	mov    ebx,r13d
    8fbf:	xor    r8d,r8d
    8fc2:	xor    r9d,r9d
    8fc5:	shl    r12,0x4
    8fc9:	shl    rbx,0x4
    8fcd:	nop    DWORD PTR [rax+0x0]
    8fd4:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8fdf:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8fea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8ff5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9000:	vmovsd xmm0,QWORD PTR [rcx+r8*1]
    9006:	vmovhpd xmm0,xmm0,QWORD PTR [rsi+r8*1]
    900c:	vaddpd xmm0,xmm0,XMMWORD PTR [r14+r9*1]
    9012:	vmulpd xmm0,xmm0,xmm3
    9016:	vmovlpd QWORD PTR [rax+r8*1],xmm0
    901c:	vmovhpd QWORD PTR [rdi+r8*1],xmm0
    9022:	add    r8,r12
    9025:	vmovupd XMMWORD PTR [rbp+r9*1+0x0],xmm0
    902c:	add    r9,0x10
    9030:	cmp    rbx,r9
    9033:	jne    9000 <c_run_11.isra.0+0x290>
    9035:	add    r13d,r13d
    9038:	cmp    r13d,DWORD PTR [rsp-0x3c]
    903d:	je     9070 <c_run_11.isra.0+0x300>
    903f:	mov    rbx,QWORD PTR [rsp-0x70]
    9044:	lea    r8d,[r13+rbx*1+0x0]
    9049:	imul   r13d,DWORD PTR [rsp-0x60]
    904f:	vmovsd xmm0,QWORD PTR [r10+r8*8]
    9055:	lea    r9d,[r13+rdx*1+0x0]
    905a:	vaddsd xmm0,xmm0,QWORD PTR [r10+r9*8]
    9060:	vmulsd xmm0,xmm0,xmm4
    9064:	vmovsd QWORD PTR [r15+r9*8],xmm0
    906a:	vmovsd QWORD PTR [r15+r8*8],xmm0
    9070:	mov    r14,QWORD PTR [rsp-0x68]
    9075:	add    r11,QWORD PTR [rsp-0x30]
    907a:	inc    rdx
    907d:	add    rcx,0x8
    9081:	add    QWORD PTR [rsp-0x70],r14
    9086:	add    rax,0x8
    908a:	add    rsi,0x8
    908e:	add    rdi,0x8
    9092:	cmp    DWORD PTR [rsp-0x60],edx
    9096:	jg     8ed7 <c_run_11.isra.0+0x167>
    909c:	mov    r12d,DWORD PTR [rsp-0x5c]
    90a1:	mov    r13,QWORD PTR [rsp-0x58]
    90a6:	mov    r9,QWORD PTR [rsp-0x50]
    90ab:	mov    rbx,QWORD PTR [rsp-0x48]
    90b0:	mov    rbp,QWORD PTR [rsp+0x68]
    90b5:	mov    rax,QWORD PTR [rsp+0x58]
    90ba:	inc    r12d
    90bd:	cmp    DWORD PTR [rsp+0xc],r12d
    90c2:	je     912f <c_run_11.isra.0+0x3bf>
    90c4:	mov    rax,QWORD PTR [rsp+0x58]
    90c9:	jmp    8e80 <c_run_11.isra.0+0x110>
    90ce:	mov    rbx,QWORD PTR [rsp-0x70]
    90d3:	lea    r9,[rbx*8+0x0]
    90db:	lea    r12,[r10+r9*1]
    90df:	xor    ebx,ebx
    90e1:	add    r9,r15
    90e4:	xor    r8d,r8d
    90e7:	vmovq  rbp,xmm5
    90ec:	nop    WORD PTR [rax+rax*1+0x0]
    90f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9100:	vmovsd xmm0,QWORD PTR [r12+r8*8]
    9106:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rbx*1]
    910b:	vmulsd xmm0,xmm0,xmm4
    910f:	vmovsd QWORD PTR [rax+rbx*1],xmm0
    9114:	vmovsd QWORD PTR [r9+r8*8],xmm0
    911a:	inc    r8
    911d:	add    rbx,rbp
    9120:	cmp    r8d,edx
    9123:	jl     9100 <c_run_11.isra.0+0x390>
    9125:	vmovq  xmm5,rbp
    912a:	jmp    9070 <c_run_11.isra.0+0x300>
    912f:	mov    rbx,QWORD PTR [rsp+0x20]
    9134:	mov    rbp,QWORD PTR [rsp+0x28]
    9139:	mov    r12,QWORD PTR [rsp+0x30]
    913e:	mov    r13,QWORD PTR [rsp+0x38]
    9143:	mov    r14,QWORD PTR [rsp+0x40]
    9148:	mov    r15,QWORD PTR [rsp+0x48]
    914d:	add    rsp,0x50
    9151:	ret
    9152:	xor    r13d,r13d
    9155:	jmp    903f <c_run_11.isra.0+0x2cf>
    915a:	mov    eax,DWORD PTR [rsp-0x60]
    915e:	mov    rdx,QWORD PTR [rsp+0x58]
    9163:	mov    esi,DWORD PTR [rsp+0xc]
    9167:	lea    ecx,[rax+0x1]
    916a:	cmp    esi,ecx
    916c:	je     9180 <c_run_11.isra.0+0x410>
    916e:	add    eax,0x2
    9171:	cmp    esi,eax
    9173:	je     9180 <c_run_11.isra.0+0x410>
    9175:	mov    esi,DWORD PTR [rsp+0xc]
    9179:	lea    ecx,[rax+0x1]
    917c:	cmp    esi,ecx
    917e:	jne    916e <c_run_11.isra.0+0x3fe>
    9180:	mov    rbp,QWORD PTR [rsp+0x28]
    9185:	mov    r13,QWORD PTR [rsp+0x38]
    918a:	jmp    9148 <c_run_11.isra.0+0x3d8>
    918c:	nop    DWORD PTR [rax+0x0]


<c_run_12.isra.0>:
    dc00:	sub    rsp,0x58
    dc04:	mov    QWORD PTR [rsp+0x28],rbx
    dc09:	mov    QWORD PTR [rsp+0x8],rdx
    dc0e:	mov    ebx,edi
    dc10:	mov    rdi,QWORD PTR [rsp+0x68]
    dc15:	test   esi,esi
    dc17:	je     dccf <c_run_12.isra.0+0xcf>
    dc1d:	mov    eax,ebx
    dc1f:	mov    DWORD PTR [rsp+0x1c],esi
    dc23:	mov    QWORD PTR [rsp+0x38],r12
    dc28:	mov    r12,r8
    dc2b:	lea    r8d,[rbx+0x1]
    dc2f:	mov    QWORD PTR [rsp+0x30],rbp
    dc34:	mov    QWORD PTR [rsp+0x40],r13
    dc39:	mov    QWORD PTR [rsp+0x48],r14
    dc3e:	mov    QWORD PTR [rsp+0x50],r15
    dc43:	mov    rbp,rcx
    dc46:	mov    r13,r9
    dc49:	lea    r15,[r8*8+0x0]
    dc51:	imul   eax,ebx
    dc54:	xor    r14d,r14d
    dc57:	shl    rax,0x3
    dc5b:	mov    QWORD PTR [rsp+0x10],rax
    dc60:	mov    rax,QWORD PTR [rsp+0x8]
    dc65:	mov    rcx,QWORD PTR [rsp+0x60]
    dc6a:	mov    rsi,QWORD PTR [rsp+0x70]
    dc6f:	mov    rdx,QWORD PTR [rsp+0x10]
    dc74:	xor    esi,esi
    dc76:	call   2bd0 <memset@plt>
    dc7b:	test   ebx,ebx
    dc7d:	vmovsd xmm0,QWORD PTR [rip+0x29f03]        # 37b88 <system__os_lib__standin+0x3c>
    dc85:	mov    rdi,rax
    dc88:	je     dc9d <c_run_12.isra.0+0x9d>
    dc8a:	mov    rdx,rax
    dc8d:	xor    eax,eax
    dc8f:	nop
    dc90:	inc    eax
    dc92:	vmovsd QWORD PTR [rdx],xmm0
    dc96:	add    rdx,r15
    dc99:	cmp    ebx,eax
    dc9b:	jne    dc90 <c_run_12.isra.0+0x90>
    dc9d:	mov    rax,QWORD PTR [rsp+0x8]
    dca2:	mov    rcx,QWORD PTR [rsp+0x60]
    dca7:	mov    rsi,QWORD PTR [rsp+0x70]
    dcac:	inc    r14d
    dcaf:	cmp    r14d,DWORD PTR [rsp+0x1c]
    dcb4:	jne    dc60 <c_run_12.isra.0+0x60>
    dcb6:	mov    rbp,QWORD PTR [rsp+0x30]
    dcbb:	mov    r12,QWORD PTR [rsp+0x38]
    dcc0:	mov    r13,QWORD PTR [rsp+0x40]
    dcc5:	mov    r14,QWORD PTR [rsp+0x48]
    dcca:	mov    r15,QWORD PTR [rsp+0x50]
    dccf:	mov    rbx,QWORD PTR [rsp+0x28]
    dcd4:	add    rsp,0x58
    dcd8:	ret
    dcd9:	nop    DWORD PTR [rax+0x0]


<c_run_13.isra.0>:
    e9a0:	sub    rsp,0x58
    e9a4:	mov    QWORD PTR [rsp+0x48],r14
    e9a9:	mov    QWORD PTR [rsp+0x50],r15
    e9ae:	mov    r14,rcx
    e9b1:	mov    r10,QWORD PTR [rsp+0x60]
    e9b6:	mov    r11,QWORD PTR [rsp+0x68]
    e9bb:	mov    r15,QWORD PTR [rsp+0x70]
    e9c0:	mov    rcx,QWORD PTR [rsp+0x78]
    e9c5:	test   edx,edx
    e9c7:	je     ea9b <c_run_13.isra.0+0xfb>
    e9cd:	mov    eax,edi
    e9cf:	sar    eax,1
    e9d1:	je     ea86 <c_run_13.isra.0+0xe6>
    e9d7:	mov    QWORD PTR [rsp+0x28],rbx
    e9dc:	mov    DWORD PTR [rsp+0xc],edx
    e9e0:	mov    QWORD PTR [rsp+0x10],r8
    e9e5:	mov    QWORD PTR [rsp+0x18],r9
    e9ea:	mov    QWORD PTR [rsp+0x60],r10
    e9ef:	mov    QWORD PTR [rsp+0x68],r11
    e9f4:	mov    QWORD PTR [rsp+0x30],rbp
    e9f9:	mov    ebp,esi
    e9fb:	mov    eax,eax
    e9fd:	mov    QWORD PTR [rsp+0x40],r13
    ea02:	mov    r13,rbp
    ea05:	mov    QWORD PTR [rsp+0x38],r12
    ea0a:	lea    r12,[rcx+rax*4]
    ea0e:	xor    eax,eax
    ea10:	shl    rbp,0x3
    ea14:	nop
    ea15:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ea20:	mov    DWORD PTR [rsp+0x8],eax
    ea24:	mov    QWORD PTR [rsp+0x78],rcx
    ea29:	mov    rbx,rcx
    ea2c:	nop    DWORD PTR [rax+0x0]
    ea30:	mov    esi,DWORD PTR [rbx]
    ea32:	mov    rdx,rbp
    ea35:	add    rbx,0x4
    ea39:	imul   esi,r13d
    ea3d:	movsxd rsi,esi
    ea40:	shl    rsi,0x3
    ea44:	lea    rdi,[r15+rsi*1]
    ea48:	add    rsi,r14
    ea4b:	call   30f0 <memcpy@plt>
    ea50:	cmp    r12,rbx
    ea53:	jne    ea30 <c_run_13.isra.0+0x90>
    ea55:	mov    eax,DWORD PTR [rsp+0x8]
    ea59:	mov    rcx,QWORD PTR [rsp+0x78]
    ea5e:	mov    rdx,QWORD PTR [rsp+0x10]
    ea63:	mov    rdi,QWORD PTR [rsp+0x18]
    ea68:	mov    rbx,QWORD PTR [rsp+0x60]
    ea6d:	mov    rsi,QWORD PTR [rsp+0x68]
    ea72:	inc    eax
    ea74:	cmp    DWORD PTR [rsp+0xc],eax
    ea78:	je     eab0 <c_run_13.isra.0+0x110>
    ea7a:	mov    rbx,QWORD PTR [rsp+0x60]
    ea7f:	mov    rsi,QWORD PTR [rsp+0x68]
    ea84:	jmp    ea20 <c_run_13.isra.0+0x80>
    ea86:	lea    esi,[rax+0x1]
    ea89:	cmp    edx,esi
    ea8b:	je     ea9b <c_run_13.isra.0+0xfb>
    ea8d:	add    eax,0x2
    ea90:	cmp    edx,eax
    ea92:	je     ea9b <c_run_13.isra.0+0xfb>
    ea94:	lea    esi,[rax+0x1]
    ea97:	cmp    edx,esi
    ea99:	jne    ea8d <c_run_13.isra.0+0xed>
    ea9b:	mov    r14,QWORD PTR [rsp+0x48]
    eaa0:	mov    r15,QWORD PTR [rsp+0x50]
    eaa5:	add    rsp,0x58
    eaa9:	ret
    eaaa:	nop    WORD PTR [rax+rax*1+0x0]
    eab0:	mov    rbx,QWORD PTR [rsp+0x28]
    eab5:	mov    rbp,QWORD PTR [rsp+0x30]
    eaba:	mov    r12,QWORD PTR [rsp+0x38]
    eabf:	mov    r13,QWORD PTR [rsp+0x40]
    eac4:	mov    r14,QWORD PTR [rsp+0x48]
    eac9:	mov    r15,QWORD PTR [rsp+0x50]
    eace:	add    rsp,0x58
    ead2:	ret
    ead3:	xchg   ax,ax
    ead5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_14.isra.0>:
    dce0:	push   rbp
    dce1:	mov    rbp,rsp
    dce4:	push   r15
    dce6:	push   r14
    dce8:	push   r13
    dcea:	push   r12
    dcec:	push   rbx
    dced:	and    rsp,0xffffffffffffffe0
    dcf1:	sub    rsp,0x40
    dcf5:	mov    QWORD PTR [rsp+0x18],r8
    dcfa:	test   ecx,ecx
    dcfc:	je     dec5 <c_run_14.isra.0+0x1e5>
    dd02:	mov    eax,edi
    dd04:	mov    DWORD PTR [rsp+0x28],edi
    dd08:	mov    DWORD PTR [rsp+0x20],ecx
    dd0c:	mov    DWORD PTR [rsp+0x4],esi
    dd10:	mov    DWORD PTR [rsp+0x24],0x0
    dd18:	mov    r14,QWORD PTR [rbp+0x28]
    dd1c:	mov    r12,r9
    dd1f:	mov    ebx,edx
    dd21:	imul   eax,edx
    dd24:	shl    rax,0x3
    dd28:	mov    QWORD PTR [rsp+0x10],rax
    dd2d:	mov    eax,esi
    dd2f:	lea    r15,[rax*8+0x0]
    dd37:	lea    rax,[r8+r15*1]
    dd3b:	mov    QWORD PTR [rsp+0x38],r15
    dd40:	mov    QWORD PTR [rsp+0x8],rax
    dd45:	lea    eax,[rdx-0x4]
    dd48:	and    eax,0xfffffffc
    dd4b:	add    eax,0x4
    dd4e:	mov    edi,edx
    dd50:	sub    edi,eax
    dd52:	mov    DWORD PTR [rsp+0x30],eax
    dd56:	mov    DWORD PTR [rsp+0x2c],edi
    dd5a:	mov    rax,QWORD PTR [rsp+0x18]
    dd5f:	mov    rdi,QWORD PTR [rbp+0x10]
    dd63:	mov    rcx,QWORD PTR [rbp+0x18]
    dd67:	mov    rsi,QWORD PTR [rbp+0x20]
    dd6b:	mov    rdx,QWORD PTR [rbp+0x30]
    dd6f:	mov    rdx,QWORD PTR [rsp+0x10]
    dd74:	xor    esi,esi
    dd76:	mov    rdi,r14
    dd79:	call   2bd0 <memset@plt>
    dd7e:	mov    edx,DWORD PTR [rsp+0x28]
    dd82:	test   edx,edx
    dd84:	je     de9e <c_run_14.isra.0+0x1be>
    dd8a:	mov    eax,DWORD PTR [rsp+0x4]
    dd8e:	mov    rdi,QWORD PTR [rsp+0x8]
    dd93:	xor    r11d,r11d
    dd96:	xor    r10d,r10d
    dd99:	test   eax,eax
    dd9b:	je     de9e <c_run_14.isra.0+0x1be>
    dda1:	lea    eax,[rbx-0x4]
    dda4:	vxorpd xmm3,xmm3,xmm3
    dda8:	shr    eax,0x2
    ddab:	inc    eax
    ddad:	shl    rax,0x5
    ddb1:	nop    DWORD PTR [rax+0x0]
    ddb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ddc0:	movsxd rdx,r11d
    ddc3:	mov    DWORD PTR [rsp+0x34],r10d
    ddc8:	xor    ecx,ecx
    ddca:	lea    r8,[r14+rdx*8]
    ddce:	mov    rdx,rdi
    ddd1:	sub    rdx,QWORD PTR [rsp+0x38]
    ddd6:	lea    rsi,[rax+r8*1]
    ddda:	jmp    ddef <c_run_14.isra.0+0x10f>
    dddc:	nop    DWORD PTR [rax+0x0]
    dde0:	add    rdx,0x8
    dde4:	add    ecx,ebx
    dde6:	cmp    rdi,rdx
    dde9:	je     de80 <c_run_14.isra.0+0x1a0>
    ddef:	vmovsd xmm1,QWORD PTR [rdx]
    ddf3:	vcomisd xmm1,xmm3
    ddf7:	je     dde0 <c_run_14.isra.0+0x100>
    ddf9:	mov    r9d,ecx
    ddfc:	lea    r10,[r12+r9*8]
    de00:	cmp    ebx,0x4
    de03:	js     dee0 <c_run_14.isra.0+0x200>
    de09:	mov    r15,r10
    de0c:	sub    r15,r8
    de0f:	vbroadcastsd ymm2,xmm1
    de14:	mov    r9,r8
    de17:	nop    WORD PTR [rax+rax*1+0x0]
    de20:	vmulpd ymm0,ymm2,YMMWORD PTR [r15+r9*1]
    de26:	add    r9,0x20
    de2a:	vaddpd ymm0,ymm0,YMMWORD PTR [r9-0x20]
    de30:	vmovupd YMMWORD PTR [r9-0x20],ymm0
    de36:	cmp    rsi,r9
    de39:	jne    de20 <c_run_14.isra.0+0x140>
    de3b:	mov    r15d,DWORD PTR [rsp+0x2c]
    de40:	mov    r9d,DWORD PTR [rsp+0x30]
    de45:	cmp    r15d,0x3
    de49:	je     def0 <c_run_14.isra.0+0x210>
    de4f:	cmp    r15d,0x2
    de53:	je     df40 <c_run_14.isra.0+0x260>
    de59:	cmp    r15d,0x1
    de5d:	jne    dde0 <c_run_14.isra.0+0x100>
    de5f:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*8]
    de65:	add    rdx,0x8
    de69:	add    ecx,ebx
    de6b:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*8]
    de71:	vmovsd QWORD PTR [r8+r9*8],xmm1
    de77:	cmp    rdi,rdx
    de7a:	jne    ddef <c_run_14.isra.0+0x10f>
    de80:	mov    r10d,DWORD PTR [rsp+0x34]
    de85:	add    rdi,QWORD PTR [rsp+0x38]
    de8a:	add    r11d,ebx
    de8d:	inc    r10d
    de90:	cmp    DWORD PTR [rsp+0x28],r10d
    de95:	jne    ddc0 <c_run_14.isra.0+0xe0>
    de9b:	vzeroupper
    de9e:	mov    rax,QWORD PTR [rsp+0x18]
    dea3:	mov    rdi,QWORD PTR [rbp+0x10]
    dea7:	mov    rcx,QWORD PTR [rbp+0x18]
    deab:	mov    rsi,QWORD PTR [rbp+0x20]
    deaf:	mov    rdx,QWORD PTR [rbp+0x30]
    deb3:	inc    DWORD PTR [rsp+0x24]
    deb7:	mov    edi,DWORD PTR [rsp+0x20]
    debb:	cmp    DWORD PTR [rsp+0x24],edi
    debf:	jne    dd5a <c_run_14.isra.0+0x7a>
    dec5:	lea    rsp,[rbp-0x28]
    dec9:	pop    rbx
    deca:	pop    r12
    decc:	pop    r13
    dece:	pop    r14
    ded0:	pop    r15
    ded2:	pop    rbp
    ded3:	ret
    ded4:	nop
    ded5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    dee0:	mov    r15d,ebx
    dee3:	xor    r9d,r9d
    dee6:	cmp    r15d,0x3
    deea:	jne    de4f <c_run_14.isra.0+0x16f>
    def0:	shl    r9,0x3
    def4:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1]
    defa:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1]
    df00:	vmovsd QWORD PTR [r8+r9*1],xmm0
    df06:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1+0x8]
    df0d:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1+0x8]
    df14:	vmovsd QWORD PTR [r8+r9*1+0x8],xmm0
    df1b:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*1+0x10]
    df22:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*1+0x10]
    df29:	vmovsd QWORD PTR [r8+r9*1+0x10],xmm1
    df30:	jmp    dde0 <c_run_14.isra.0+0x100>
    df35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    df40:	shl    r9,0x3
    df44:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1]
    df4a:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1]
    df50:	vmovsd QWORD PTR [r8+r9*1],xmm0
    df56:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*1+0x8]
    df5d:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*1+0x8]
    df64:	vmovsd QWORD PTR [r8+r9*1+0x8],xmm1
    df6b:	jmp    dde0 <c_run_14.isra.0+0x100>


<c_run_15.isra.0>:
    df70:	push   rbp
    df71:	mov    rbp,rsp
    df74:	push   r15
    df76:	push   r14
    df78:	push   r13
    df7a:	push   r12
    df7c:	push   rbx
    df7d:	and    rsp,0xffffffffffffffe0
    df81:	sub    rsp,0x40
    df85:	mov    r11,QWORD PTR [rbp+0x28]
    df89:	mov    QWORD PTR [rsp+0x18],r8
    df8e:	test   ecx,ecx
    df90:	je     e164 <c_run_15.isra.0+0x1f4>
    df96:	mov    eax,esi
    df98:	mov    DWORD PTR [rsp+0x28],edi
    df9c:	mov    DWORD PTR [rsp+0x20],ecx
    dfa0:	mov    DWORD PTR [rsp+0x24],0x0
    dfa8:	mov    DWORD PTR [rsp+0x4],esi
    dfac:	mov    r14,r9
    dfaf:	mov    ebx,edx
    dfb1:	imul   eax,edx
    dfb4:	shl    rax,0x3
    dfb8:	mov    QWORD PTR [rsp+0x10],rax
    dfbd:	mov    eax,esi
    dfbf:	lea    r15,[rax*8+0x0]
    dfc7:	lea    rax,[r8+r15*1]
    dfcb:	mov    QWORD PTR [rsp+0x38],r15
    dfd0:	mov    QWORD PTR [rsp+0x8],rax
    dfd5:	lea    eax,[rdx-0x4]
    dfd8:	and    eax,0xfffffffc
    dfdb:	add    eax,0x4
    dfde:	mov    edi,edx
    dfe0:	sub    edi,eax
    dfe2:	mov    DWORD PTR [rsp+0x30],eax
    dfe6:	mov    DWORD PTR [rsp+0x2c],edi
    dfea:	mov    rax,QWORD PTR [rsp+0x18]
    dfef:	mov    rdi,QWORD PTR [rbp+0x10]
    dff3:	mov    rdx,QWORD PTR [rbp+0x18]
    dff7:	mov    rcx,QWORD PTR [rbp+0x20]
    dffb:	mov    rsi,QWORD PTR [rbp+0x30]
    dfff:	mov    rdx,QWORD PTR [rsp+0x10]
    e004:	mov    rdi,r11
    e007:	xor    esi,esi
    e009:	call   2bd0 <memset@plt>
    e00e:	mov    ecx,DWORD PTR [rsp+0x28]
    e012:	mov    r11,rax
    e015:	test   ecx,ecx
    e017:	je     e13d <c_run_15.isra.0+0x1cd>
    e01d:	mov    edx,DWORD PTR [rsp+0x4]
    e021:	mov    r8,QWORD PTR [rsp+0x8]
    e026:	xor    ecx,ecx
    e028:	xor    eax,eax
    e02a:	test   edx,edx
    e02c:	je     e13d <c_run_15.isra.0+0x1cd>
    e032:	lea    edx,[rbx-0x4]
    e035:	vxorpd xmm3,xmm3,xmm3
    e039:	mov    rdi,r14
    e03c:	shr    edx,0x2
    e03f:	inc    edx
    e041:	shl    rdx,0x5
    e045:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e050:	movsxd rsi,ecx
    e053:	mov    DWORD PTR [rsp+0x34],eax
    e057:	xor    r9d,r9d
    e05a:	lea    r13,[rdi+rsi*8]
    e05e:	mov    rsi,r8
    e061:	sub    rsi,QWORD PTR [rsp+0x38]
    e066:	lea    r10,[rdx+r13*1]
    e06a:	jmp    e090 <c_run_15.isra.0+0x120>
    e06c:	nop    WORD PTR [rax+rax*1+0x0]
    e075:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e080:	add    rsi,0x8
    e084:	add    r9d,ebx
    e087:	cmp    r8,rsi
    e08a:	je     e120 <c_run_15.isra.0+0x1b0>
    e090:	vmovsd xmm1,QWORD PTR [rsi]
    e094:	vcomisd xmm1,xmm3
    e098:	je     e080 <c_run_15.isra.0+0x110>
    e09a:	mov    eax,r9d
    e09d:	lea    r15,[r11+rax*8]
    e0a1:	cmp    ebx,0x4
    e0a4:	js     e180 <c_run_15.isra.0+0x210>
    e0aa:	mov    r14,r15
    e0ad:	sub    r14,r13
    e0b0:	vbroadcastsd ymm2,xmm1
    e0b5:	mov    rax,r13
    e0b8:	nop    DWORD PTR [rax+rax*1+0x0]
    e0c0:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    e0c4:	vaddpd ymm0,ymm0,YMMWORD PTR [r14+rax*1]
    e0ca:	vmovupd YMMWORD PTR [r14+rax*1],ymm0
    e0d0:	add    rax,0x20
    e0d4:	cmp    r10,rax
    e0d7:	jne    e0c0 <c_run_15.isra.0+0x150>
    e0d9:	mov    r14d,DWORD PTR [rsp+0x2c]
    e0de:	mov    eax,DWORD PTR [rsp+0x30]
    e0e2:	cmp    r14d,0x3
    e0e6:	je     e18f <c_run_15.isra.0+0x21f>
    e0ec:	cmp    r14d,0x2
    e0f0:	je     e1e0 <c_run_15.isra.0+0x270>
    e0f6:	cmp    r14d,0x1
    e0fa:	jne    e080 <c_run_15.isra.0+0x110>
    e0fc:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*8+0x0]
    e103:	add    rsi,0x8
    e107:	add    r9d,ebx
    e10a:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*8]
    e110:	vmovsd QWORD PTR [r15+rax*8],xmm1
    e116:	cmp    r8,rsi
    e119:	jne    e090 <c_run_15.isra.0+0x120>
    e11f:	nop
    e120:	mov    eax,DWORD PTR [rsp+0x34]
    e124:	add    r8,QWORD PTR [rsp+0x38]
    e129:	add    ecx,ebx
    e12b:	inc    eax
    e12d:	cmp    DWORD PTR [rsp+0x28],eax
    e131:	jne    e050 <c_run_15.isra.0+0xe0>
    e137:	mov    r14,rdi
    e13a:	vzeroupper
    e13d:	mov    rax,QWORD PTR [rsp+0x18]
    e142:	mov    rdi,QWORD PTR [rbp+0x10]
    e146:	mov    rdx,QWORD PTR [rbp+0x18]
    e14a:	mov    rcx,QWORD PTR [rbp+0x20]
    e14e:	mov    rsi,QWORD PTR [rbp+0x30]
    e152:	inc    DWORD PTR [rsp+0x24]
    e156:	mov    edi,DWORD PTR [rsp+0x20]
    e15a:	cmp    DWORD PTR [rsp+0x24],edi
    e15e:	jne    dfea <c_run_15.isra.0+0x7a>
    e164:	lea    rsp,[rbp-0x28]
    e168:	pop    rbx
    e169:	pop    r12
    e16b:	pop    r13
    e16d:	pop    r14
    e16f:	pop    r15
    e171:	pop    rbp
    e172:	ret
    e173:	xchg   ax,ax
    e175:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e180:	mov    r14d,ebx
    e183:	xor    eax,eax
    e185:	cmp    r14d,0x3
    e189:	jne    e0ec <c_run_15.isra.0+0x17c>
    e18f:	shl    rax,0x3
    e193:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x0]
    e19a:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    e1a0:	vmovsd QWORD PTR [r15+rax*1],xmm0
    e1a6:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x8]
    e1ad:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1+0x8]
    e1b4:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm0
    e1bb:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*1+0x10]
    e1c2:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x10]
    e1c9:	vmovsd QWORD PTR [r15+rax*1+0x10],xmm1
    e1d0:	jmp    e080 <c_run_15.isra.0+0x110>
    e1d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e1e0:	shl    rax,0x3
    e1e4:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x0]
    e1eb:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    e1f1:	vmovsd QWORD PTR [r15+rax*1],xmm0
    e1f7:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*1+0x8]
    e1fe:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x8]
    e205:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm1
    e20c:	jmp    e080 <c_run_15.isra.0+0x110>
    e211:	nop    DWORD PTR [rax+0x0]
    e215:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_16.isra.0>:
    e700:	push   rbp
    e701:	mov    rbp,rsp
    e704:	push   r15
    e706:	push   r14
    e708:	push   r13
    e70a:	push   r12
    e70c:	push   rbx
    e70d:	and    rsp,0xffffffffffffffe0
    e711:	mov    rax,QWORD PTR [rbp+0x28]
    e715:	mov    DWORD PTR [rsp-0xc],ecx
    e719:	test   ecx,ecx
    e71b:	je     e783 <c_run_16.isra.0+0x83>
    e71d:	mov    r15d,edi
    e720:	mov    ebx,esi
    e722:	mov    rdi,r8
    e725:	mov    rcx,QWORD PTR [rbp+0x10]
    e729:	mov    rsi,QWORD PTR [rbp+0x18]
    e72d:	mov    r11,QWORD PTR [rbp+0x20]
    e731:	mov    r8,QWORD PTR [rbp+0x30]
    e735:	mov    r14,r9
    e738:	test   r15d,r15d
    e73b:	je     e963 <c_run_16.isra.0+0x263>
    e741:	mov    DWORD PTR [rsp-0x8],0x0
    e749:	test   edx,edx
    e74b:	jne    e792 <c_run_16.isra.0+0x92>
    e74d:	mov    rcx,QWORD PTR [rbp+0x10]
    e751:	mov    rsi,QWORD PTR [rbp+0x18]
    e755:	mov    r8,QWORD PTR [rbp+0x20]
    e759:	mov    r9,QWORD PTR [rbp+0x30]
    e75d:	xor    edx,edx
    e75f:	mov    ebx,DWORD PTR [rsp-0xc]
    e763:	lea    r10d,[rdx+0x1]
    e767:	cmp    ebx,r10d
    e76a:	je     e783 <c_run_16.isra.0+0x83>
    e76c:	add    edx,0x2
    e76f:	cmp    ebx,edx
    e771:	je     e783 <c_run_16.isra.0+0x83>
    e773:	jmp    e75f <c_run_16.isra.0+0x5f>
    e775:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e780:	vzeroupper
    e783:	lea    rsp,[rbp-0x28]
    e787:	pop    rbx
    e788:	pop    r12
    e78a:	pop    r13
    e78c:	pop    r14
    e78e:	pop    r15
    e790:	pop    rbp
    e791:	ret
    e792:	mov    edx,edx
    e794:	lea    r11d,[rbx-0x8]
    e798:	lea    ecx,[rbx-0x4]
    e79b:	mov    r10d,ebx
    e79e:	lea    r13,[rdx*8+0x0]
    e7a6:	and    r11d,0xfffffffc
    e7aa:	lea    rdx,[rax+r13*1]
    e7ae:	add    r11d,0x8
    e7b2:	mov    QWORD PTR [rsp-0x20],rdx
    e7b7:	mov    edx,0x4
    e7bc:	shl    r10,0x3
    e7c0:	cmp    ecx,0x3
    e7c3:	cmovle r11d,edx
    e7c7:	mov    r12d,ebx
    e7ca:	sub    r12d,r11d
    e7cd:	mov    r9,QWORD PTR [rsp-0x20]
    e7d2:	mov    QWORD PTR [rsp-0x18],rdi
    e7d7:	mov    QWORD PTR [rbp+0x28],rax
    e7db:	mov    rdx,rdi
    e7de:	xor    r8d,r8d
    e7e1:	nop    DWORD PTR [rax+0x0]
    e7e5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e7f0:	mov    DWORD PTR [rsp-0x4],r8d
    e7f5:	mov    rdi,r9
    e7f8:	sub    rdi,r13
    e7fb:	mov    rax,r14
    e7fe:	xchg   ax,ax
    e800:	test   ecx,ecx
    e802:	js     e8f0 <c_run_16.isra.0+0x1f0>
    e808:	vmovupd ymm1,YMMWORD PTR [rdx]
    e80c:	vmulpd ymm1,ymm1,YMMWORD PTR [rax]
    e810:	cmp    ecx,0x3
    e813:	jle    e836 <c_run_16.isra.0+0x136>
    e815:	mov    esi,0x4
    e81a:	nop    WORD PTR [rax+rax*1+0x0]
    e820:	vmovupd ymm0,YMMWORD PTR [rdx+rsi*8]
    e825:	vmulpd ymm0,ymm0,YMMWORD PTR [rax+rsi*8]
    e82a:	add    rsi,0x4
    e82e:	vaddpd ymm1,ymm1,ymm0
    e832:	cmp    ecx,esi
    e834:	jge    e820 <c_run_16.isra.0+0x120>
    e836:	vmovapd xmm0,xmm1
    e83a:	vextractf64x2 xmm1,ymm1,0x1
    e841:	mov    r8d,r12d
    e844:	mov    esi,r11d
    e847:	vaddpd xmm0,xmm0,xmm1
    e84b:	vunpckhpd xmm1,xmm0,xmm0
    e84f:	vaddsd xmm0,xmm0,xmm1
    e853:	cmp    r8d,0x3
    e857:	je     e903 <c_run_16.isra.0+0x203>
    e85d:	cmp    r8d,0x2
    e861:	je     e940 <c_run_16.isra.0+0x240>
    e867:	cmp    r8d,0x1
    e86b:	jne    e880 <c_run_16.isra.0+0x180>
    e86d:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    e872:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    e877:	vaddsd xmm0,xmm0,xmm1
    e87b:	nop    DWORD PTR [rax+rax*1+0x0]
    e880:	vmovsd QWORD PTR [rdi],xmm0
    e884:	add    rdi,0x8
    e888:	add    rax,r10
    e88b:	cmp    r9,rdi
    e88e:	jne    e800 <c_run_16.isra.0+0x100>
    e894:	mov    r8d,DWORD PTR [rsp-0x4]
    e899:	add    r9,r13
    e89c:	add    rdx,r10
    e89f:	inc    r8d
    e8a2:	cmp    r15d,r8d
    e8a5:	jne    e7f0 <c_run_16.isra.0+0xf0>
    e8ab:	mov    rdi,QWORD PTR [rsp-0x18]
    e8b0:	mov    rax,QWORD PTR [rbp+0x28]
    e8b4:	mov    rdx,QWORD PTR [rbp+0x10]
    e8b8:	mov    rsi,QWORD PTR [rbp+0x18]
    e8bc:	mov    r8,QWORD PTR [rbp+0x20]
    e8c0:	mov    r9,QWORD PTR [rbp+0x30]
    e8c4:	inc    DWORD PTR [rsp-0x8]
    e8c8:	mov    edx,DWORD PTR [rsp-0x8]
    e8cc:	cmp    DWORD PTR [rsp-0xc],edx
    e8d0:	je     e780 <c_run_16.isra.0+0x80>
    e8d6:	mov    rdx,QWORD PTR [rbp+0x10]
    e8da:	mov    rsi,QWORD PTR [rbp+0x18]
    e8de:	mov    r8,QWORD PTR [rbp+0x20]
    e8e2:	mov    r9,QWORD PTR [rbp+0x30]
    e8e6:	jmp    e7cd <c_run_16.isra.0+0xcd>
    e8eb:	nop    DWORD PTR [rax+rax*1+0x0]
    e8f0:	mov    r8d,ebx
    e8f3:	xor    esi,esi
    e8f5:	vxorpd xmm0,xmm0,xmm0
    e8f9:	cmp    r8d,0x3
    e8fd:	jne    e85d <c_run_16.isra.0+0x15d>
    e903:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    e908:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    e90d:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x8]
    e913:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x8]
    e919:	vaddsd xmm1,xmm1,xmm2
    e91d:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x10]
    e923:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x10]
    e929:	vaddsd xmm1,xmm1,xmm2
    e92d:	vaddsd xmm0,xmm0,xmm1
    e931:	jmp    e880 <c_run_16.isra.0+0x180>
    e936:	cs nop WORD PTR [rax+rax*1+0x0]
    e940:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    e945:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    e94a:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x8]
    e950:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x8]
    e956:	vaddsd xmm1,xmm1,xmm2
    e95a:	vaddsd xmm0,xmm0,xmm1
    e95e:	jmp    e880 <c_run_16.isra.0+0x180>
    e963:	mov    rdx,QWORD PTR [rbp+0x10]
    e967:	mov    rcx,QWORD PTR [rbp+0x18]
    e96b:	mov    rsi,QWORD PTR [rbp+0x20]
    e96f:	mov    r8,QWORD PTR [rbp+0x30]
    e973:	mov    ebx,DWORD PTR [rsp-0xc]
    e977:	lea    r9d,[r15+0x1]
    e97b:	cmp    ebx,r9d
    e97e:	je     e783 <c_run_16.isra.0+0x83>
    e984:	add    r15d,0x2
    e988:	cmp    ebx,r15d
    e98b:	je     e783 <c_run_16.isra.0+0x83>
    e991:	jmp    e973 <c_run_16.isra.0+0x273>
    e993:	xchg   ax,ax
    e995:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_17.isra.0>:
    eae0:	push   rbp
    eae1:	mov    rbp,rsp
    eae4:	push   r15
    eae6:	push   r14
    eae8:	push   r13
    eaea:	push   r12
    eaec:	push   rbx
    eaed:	and    rsp,0xffffffffffffffe0
    eaf1:	sub    rsp,0x60
    eaf5:	mov    QWORD PTR [rsp+0x48],rcx
    eafa:	mov    QWORD PTR [rsp+0x30],r8
    eaff:	mov    QWORD PTR [rsp+0x28],r9
    eb04:	test   edx,edx
    eb06:	je     ee45 <c_run_17.isra.0+0x365>
    eb0c:	mov    eax,esi
    eb0e:	mov    r13d,esi
    eb11:	mov    DWORD PTR [rsp+0x20],edx
    eb15:	mov    DWORD PTR [rsp+0x44],esi
    eb19:	lea    rbx,[r13*8+0x0]
    eb21:	mov    DWORD PTR [rsp+0x40],0x0
    eb29:	mov    r15d,edi
    eb2c:	imul   eax,esi
    eb2f:	mov    QWORD PTR [rsp+0x38],rbx
    eb34:	shl    rax,0x3
    eb38:	mov    QWORD PTR [rsp+0x18],rax
    eb3d:	mov    rax,r13
    eb40:	shl    rax,0x4
    eb44:	mov    QWORD PTR [rsp+0x10],rax
    eb49:	mov    rax,QWORD PTR [rsp+0x48]
    eb4e:	mov    rdi,QWORD PTR [rsp+0x30]
    eb53:	mov    rsi,QWORD PTR [rsp+0x28]
    eb58:	mov    rbx,QWORD PTR [rbp+0x10]
    eb5c:	mov    rdx,QWORD PTR [rbp+0x18]
    eb60:	mov    rcx,QWORD PTR [rbp+0x20]
    eb64:	mov    r14,QWORD PTR [rbp+0x28]
    eb68:	mov    rdx,QWORD PTR [rsp+0x18]
    eb6d:	mov    rdi,QWORD PTR [rbp+0x20]
    eb71:	xor    esi,esi
    eb73:	call   2bd0 <memset@plt>
    eb78:	mov    eax,DWORD PTR [rsp+0x44]
    eb7c:	vxorpd xmm3,xmm3,xmm3
    eb80:	test   eax,eax
    eb82:	je     ee14 <c_run_17.isra.0+0x334>
    eb88:	test   r15d,r15d
    eb8b:	je     ecc3 <c_run_17.isra.0+0x1e3>
    eb91:	mov    QWORD PTR [rsp+0x50],r13
    eb96:	mov    r10d,0xfffffffd
    eb9c:	xor    r9d,r9d
    eb9f:	xor    r8d,r8d
    eba2:	xor    r12d,r12d
    eba5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ebb0:	mov    rdi,QWORD PTR [rbp+0x20]
    ebb4:	movsxd rax,r9d
    ebb7:	mov    ecx,r10d
    ebba:	mov    r13d,r10d
    ebbd:	and    r13d,0xfffffffc
    ebc1:	inc    r12d
    ebc4:	mov    DWORD PTR [rsp+0x5c],r9d
    ebc9:	xor    edx,edx
    ebcb:	add    r13d,0x4
    ebcf:	mov    r9,QWORD PTR [rsp+0x38]
    ebd4:	mov    r14d,r12d
    ebd7:	sub    r14d,r13d
    ebda:	shr    ecx,0x2
    ebdd:	lea    rsi,[rdi+rax*8]
    ebe1:	mov    rax,QWORD PTR [rsp+0x48]
    ebe6:	shl    rcx,0x5
    ebea:	lea    rdi,[rsi+rcx*1+0x20]
    ebef:	sub    rax,rsi
    ebf2:	jmp    ec0e <c_run_17.isra.0+0x12e>
    ebf4:	nop
    ebf5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ec00:	inc    edx
    ec02:	add    rax,r9
    ec05:	cmp    r15d,edx
    ec08:	je     eca0 <c_run_17.isra.0+0x1c0>
    ec0e:	lea    r11,[rsi+rax*1]
    ec12:	vmovsd xmm1,QWORD PTR [r11+r8*8]
    ec18:	vcomisd xmm1,xmm3
    ec1c:	je     ec00 <c_run_17.isra.0+0x120>
    ec1e:	test   r10d,r10d
    ec21:	js     ee60 <c_run_17.isra.0+0x380>
    ec27:	vbroadcastsd ymm2,xmm1
    ec2c:	mov    rcx,rsi
    ec2f:	nop    WORD PTR [rax+rax*1+0x0]
    ec35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ec40:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
    ec45:	add    rcx,0x20
    ec49:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    ec4e:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
    ec53:	cmp    rdi,rcx
    ec56:	jne    ec40 <c_run_17.isra.0+0x160>
    ec58:	mov    ebx,r14d
    ec5b:	mov    ecx,r13d
    ec5e:	cmp    ebx,0x3
    ec61:	je     ee6e <c_run_17.isra.0+0x38e>
    ec67:	cmp    ebx,0x2
    ec6a:	je     eeb0 <c_run_17.isra.0+0x3d0>
    ec70:	cmp    ebx,0x1
    ec73:	jne    ec00 <c_run_17.isra.0+0x120>
    ec75:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*8]
    ec7b:	inc    edx
    ec7d:	add    rax,r9
    ec80:	vaddsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    ec85:	vmovsd QWORD PTR [rsi+rcx*8],xmm1
    ec8a:	cmp    r15d,edx
    ec8d:	jne    ec0e <c_run_17.isra.0+0x12e>
    ec93:	xchg   ax,ax
    ec95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    eca0:	mov    r9d,DWORD PTR [rsp+0x5c]
    eca5:	mov    eax,DWORD PTR [rsp+0x44]
    eca9:	inc    r8
    ecac:	inc    r10d
    ecaf:	add    r9d,eax
    ecb2:	cmp    eax,r12d
    ecb5:	jne    ebb0 <c_run_17.isra.0+0xd0>
    ecbb:	mov    r13,QWORD PTR [rsp+0x50]
    ecc0:	vzeroupper
    ecc3:	mov    r14d,DWORD PTR [rsp+0x44]
    ecc8:	cmp    r14d,0x1
    eccc:	je     ee14 <c_run_17.isra.0+0x334>
    ecd2:	mov    rax,QWORD PTR [rbp+0x20]
    ecd6:	mov    DWORD PTR [rsp+0x24],r15d
    ecdb:	mov    DWORD PTR [rsp+0x50],0x0
    ece3:	mov    rcx,QWORD PTR [rsp+0x10]
    ece8:	mov    r15,QWORD PTR [rsp+0x38]
    eced:	lea    r11d,[r14-0x1]
    ecf1:	mov    r9d,0x8
    ecf7:	mov    esi,0x1
    ecfc:	xor    r12d,r12d
    ecff:	lea    r8,[rax+0x8]
    ed03:	mov    rdi,rax
    ed06:	cs nop WORD PTR [rax+rax*1+0x0]
    ed10:	mov    DWORD PTR [rsp+0x5c],r11d
    ed15:	dec    r11d
    ed18:	mov    eax,DWORD PTR [rsp+0x50]
    ed1c:	cmp    r11d,0xe
    ed20:	jbe    eedc <c_run_17.isra.0+0x3fc>
    ed26:	cmp    r14d,esi
    ed29:	jle    eedc <c_run_17.isra.0+0x3fc>
    ed2f:	lea    r10d,[rax+r14*1]
    ed33:	mov    eax,DWORD PTR [rsp+0x5c]
    ed37:	mov    DWORD PTR [rsp+0x58],r10d
    ed3c:	add    r10,r12
    ed3f:	lea    rbx,[rax-0x1]
    ed43:	lea    rax,[r10*8+0x0]
    ed4b:	mov    rdx,rbx
    ed4e:	imul   rdx,r13
    ed52:	add    rdx,r10
    ed55:	shl    rdx,0x3
    ed59:	cmp    rdx,r9
    ed5c:	jl     ed6b <c_run_17.isra.0+0x28b>
    ed5e:	lea    rdx,[r9+rbx*8]
    ed62:	cmp    rax,rdx
    ed65:	jle    eee3 <c_run_17.isra.0+0x403>
    ed6b:	mov    r10d,DWORD PTR [rsp+0x5c]
    ed70:	add    rax,QWORD PTR [rbp+0x20]
    ed74:	shr    r10d,1
    ed77:	mov    edx,r10d
    ed7a:	shl    rdx,0x4
    ed7e:	lea    rbx,[rdx+r8*1]
    ed82:	mov    rdx,r8
    ed85:	nop    DWORD PTR [rax+rax*1+0x0]
    ed8a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ed95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    eda0:	vmovsd xmm0,QWORD PTR [rax]
    eda4:	vmovhpd xmm0,xmm0,QWORD PTR [rax+r13*8]
    edaa:	add    rdx,0x10
    edae:	add    rax,rcx
    edb1:	vmovupd XMMWORD PTR [rdx-0x10],xmm0
    edb6:	cmp    rbx,rdx
    edb9:	jne    eda0 <c_run_17.isra.0+0x2c0>
    edbb:	add    r10d,r10d
    edbe:	cmp    r10d,DWORD PTR [rsp+0x5c]
    edc3:	je     edeb <c_run_17.isra.0+0x30b>
    edc5:	add    r10d,esi
    edc8:	mov    eax,r14d
    edcb:	mov    rbx,QWORD PTR [rbp+0x20]
    edcf:	imul   eax,r10d
    edd3:	add    eax,r12d
    edd6:	mov    eax,eax
    edd8:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    eddd:	mov    eax,DWORD PTR [rsp+0x50]
    ede1:	add    eax,r10d
    ede4:	mov    eax,eax
    ede6:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    edeb:	mov    eax,DWORD PTR [rsp+0x58]
    edef:	inc    rsi
    edf2:	inc    r12
    edf5:	add    rdi,r15
    edf8:	lea    r9,[r15+r9*1+0x8]
    edfd:	lea    r8,[r15+r8*1+0x8]
    ee02:	mov    DWORD PTR [rsp+0x50],eax
    ee06:	cmp    r13,rsi
    ee09:	jne    ed10 <c_run_17.isra.0+0x230>
    ee0f:	mov    r15d,DWORD PTR [rsp+0x24]
    ee14:	mov    rax,QWORD PTR [rsp+0x48]
    ee19:	mov    rdi,QWORD PTR [rsp+0x30]
    ee1e:	mov    rsi,QWORD PTR [rsp+0x28]
    ee23:	mov    rbx,QWORD PTR [rbp+0x10]
    ee27:	mov    rdx,QWORD PTR [rbp+0x18]
    ee2b:	mov    rcx,QWORD PTR [rbp+0x20]
    ee2f:	mov    r14,QWORD PTR [rbp+0x28]
    ee33:	inc    DWORD PTR [rsp+0x40]
    ee37:	mov    edi,DWORD PTR [rsp+0x20]
    ee3b:	cmp    DWORD PTR [rsp+0x40],edi
    ee3f:	jne    eb49 <c_run_17.isra.0+0x69>
    ee45:	lea    rsp,[rbp-0x28]
    ee49:	pop    rbx
    ee4a:	pop    r12
    ee4c:	pop    r13
    ee4e:	pop    r14
    ee50:	pop    r15
    ee52:	pop    rbp
    ee53:	ret
    ee54:	nop
    ee55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ee60:	mov    ebx,r12d
    ee63:	xor    ecx,ecx
    ee65:	cmp    ebx,0x3
    ee68:	jne    ec67 <c_run_17.isra.0+0x187>
    ee6e:	shl    rcx,0x3
    ee72:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    ee78:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    ee7d:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    ee82:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1+0x8]
    ee89:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rsi*1+0x8]
    ee8f:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm0
    ee95:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x10]
    ee9c:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x10]
    eea2:	vmovsd QWORD PTR [rcx+rsi*1+0x10],xmm1
    eea8:	jmp    ec00 <c_run_17.isra.0+0x120>
    eead:	nop    DWORD PTR [rax]
    eeb0:	shl    rcx,0x3
    eeb4:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    eeba:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    eebf:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    eec4:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x8]
    eecb:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x8]
    eed1:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm1
    eed7:	jmp    ec00 <c_run_17.isra.0+0x120>
    eedc:	add    eax,r14d
    eedf:	mov    DWORD PTR [rsp+0x58],eax
    eee3:	mov    eax,DWORD PTR [rsp+0x58]
    eee7:	mov    rbx,QWORD PTR [rbp+0x20]
    eeeb:	add    rax,r12
    eeee:	lea    rdx,[rbx+rax*8]
    eef2:	mov    rax,rsi
    eef5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ef00:	vmovsd xmm0,QWORD PTR [rdx]
    ef04:	add    rdx,r15
    ef07:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    ef0c:	inc    rax
    ef0f:	cmp    r14d,eax
    ef12:	jg     ef00 <c_run_17.isra.0+0x420>
    ef14:	jmp    edeb <c_run_17.isra.0+0x30b>
    ef19:	nop    DWORD PTR [rax+0x0]


<c_run_18.isra.0>:
    ef20:	push   rbp
    ef21:	mov    rbp,rsp
    ef24:	push   r15
    ef26:	push   r14
    ef28:	push   r13
    ef2a:	push   r12
    ef2c:	push   rbx
    ef2d:	mov    r15,rcx
    ef30:	and    rsp,0xffffffffffffffe0
    ef34:	sub    rsp,0x60
    ef38:	mov    rcx,QWORD PTR [rbp+0x18]
    ef3c:	mov    QWORD PTR [rsp+0x40],r8
    ef41:	mov    QWORD PTR [rsp+0x38],r9
    ef46:	test   edx,edx
    ef48:	je     f2ba <c_run_18.isra.0+0x39a>
    ef4e:	mov    ebx,esi
    ef50:	mov    DWORD PTR [rsp+0x24],edx
    ef54:	mov    DWORD PTR [rsp+0x48],edi
    ef58:	mov    DWORD PTR [rsp+0x4c],0x0
    ef60:	mov    eax,ebx
    ef62:	mov    r14,rbx
    ef65:	shl    r14,0x4
    ef69:	imul   eax,ebx
    ef6c:	mov    QWORD PTR [rsp+0x8],r14
    ef71:	mov    r13,rbx
    ef74:	shl    rax,0x3
    ef78:	mov    QWORD PTR [rsp+0x28],rax
    ef7d:	mov    eax,edi
    ef7f:	lea    rax,[rcx+rax*8]
    ef83:	mov    QWORD PTR [rsp+0x18],rax
    ef88:	lea    rax,[rbx*8+0x0]
    ef90:	mov    QWORD PTR [rsp+0x10],rax
    ef95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    efa0:	mov    rax,QWORD PTR [rsp+0x40]
    efa5:	mov    rdi,QWORD PTR [rsp+0x38]
    efaa:	mov    rsi,QWORD PTR [rbp+0x10]
    efae:	mov    rdx,QWORD PTR [rbp+0x20]
    efb2:	mov    r8,QWORD PTR [rbp+0x28]
    efb6:	mov    rdx,QWORD PTR [rsp+0x28]
    efbb:	mov    rdi,QWORD PTR [rbp+0x20]
    efbf:	xor    esi,esi
    efc1:	mov    QWORD PTR [rbp+0x18],rcx
    efc5:	call   2bd0 <memset@plt>
    efca:	mov    eax,DWORD PTR [rsp+0x48]
    efce:	mov    rcx,QWORD PTR [rbp+0x18]
    efd2:	vxorpd xmm3,xmm3,xmm3
    efd6:	test   eax,eax
    efd8:	je     f136 <c_run_18.isra.0+0x216>
    efde:	mov    r11,QWORD PTR [rsp+0x18]
    efe3:	mov    r9,rcx
    efe6:	xor    eax,eax
    efe8:	mov    rdx,rcx
    efeb:	jmp    f010 <c_run_18.isra.0+0xf0>
    efed:	nop    DWORD PTR [rax+rax*1+0x0]
    eff5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f000:	add    r9,0x8
    f004:	add    eax,r13d
    f007:	cmp    r11,r9
    f00a:	je     f130 <c_run_18.isra.0+0x210>
    f010:	vcomisd xmm3,QWORD PTR [r9]
    f015:	je     f000 <c_run_18.isra.0+0xe0>
    f017:	test   r13d,r13d
    f01a:	je     f2c9 <c_run_18.isra.0+0x3a9>
    f020:	mov    ecx,eax
    f022:	mov    QWORD PTR [rsp+0x58],r11
    f027:	mov    DWORD PTR [rsp+0x54],eax
    f02b:	mov    edi,0xfffffffd
    f030:	lea    r10,[r15+rcx*8]
    f034:	xor    r8d,r8d
    f037:	mov    ecx,0x1
    f03c:	jmp    f051 <c_run_18.isra.0+0x131>
    f03e:	xchg   ax,ax
    f040:	add    r8d,r13d
    f043:	inc    edi
    f045:	cmp    rcx,rbx
    f048:	je     f100 <c_run_18.isra.0+0x1e0>
    f04e:	inc    rcx
    f051:	vmovsd xmm0,QWORD PTR [r10+rcx*8-0x8]
    f058:	vcomisd xmm0,xmm3
    f05c:	je     f040 <c_run_18.isra.0+0x120>
    f05e:	mov    rsi,QWORD PTR [rbp+0x20]
    f062:	mov    eax,r8d
    f065:	vmulsd xmm1,xmm0,QWORD PTR [r9]
    f06a:	mov    r12d,ecx
    f06d:	lea    r14,[rsi+rax*8]
    f071:	xor    eax,eax
    f073:	test   edi,edi
    f075:	js     f0c2 <c_run_18.isra.0+0x1a2>
    f077:	mov    eax,edi
    f079:	mov    rsi,r14
    f07c:	sub    rsi,r10
    f07f:	vbroadcastsd ymm2,xmm1
    f084:	shr    eax,0x2
    f087:	shl    rax,0x5
    f08b:	lea    r11,[r10+rax*1+0x20]
    f090:	mov    rax,r10
    f093:	xchg   ax,ax
    f095:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f0a0:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    f0a4:	vaddpd ymm0,ymm0,YMMWORD PTR [rsi+rax*1]
    f0a9:	vmovupd YMMWORD PTR [rsi+rax*1],ymm0
    f0ae:	add    rax,0x20
    f0b2:	cmp    r11,rax
    f0b5:	jne    f0a0 <c_run_18.isra.0+0x180>
    f0b7:	mov    eax,edi
    f0b9:	and    eax,0xfffffffc
    f0bc:	add    eax,0x4
    f0bf:	sub    r12d,eax
    f0c2:	cmp    r12d,0x3
    f0c6:	je     f2f0 <c_run_18.isra.0+0x3d0>
    f0cc:	cmp    r12d,0x2
    f0d0:	je     f340 <c_run_18.isra.0+0x420>
    f0d6:	cmp    r12d,0x1
    f0da:	jne    f040 <c_run_18.isra.0+0x120>
    f0e0:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*8]
    f0e6:	add    r8d,r13d
    f0e9:	inc    edi
    f0eb:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*8]
    f0f1:	vmovsd QWORD PTR [r14+rax*8],xmm1
    f0f7:	cmp    rcx,rbx
    f0fa:	jne    f04e <c_run_18.isra.0+0x12e>
    f100:	mov    r11,QWORD PTR [rsp+0x58]
    f105:	add    r9,0x8
    f109:	mov    eax,DWORD PTR [rsp+0x54]
    f10d:	cmp    r9,r11
    f110:	je     f130 <c_run_18.isra.0+0x210>
    f112:	add    eax,r13d
    f115:	vcomisd xmm3,QWORD PTR [r9]
    f11a:	jne    f020 <c_run_18.isra.0+0x100>
    f120:	add    r9,0x8
    f124:	add    eax,r13d
    f127:	cmp    r11,r9
    f12a:	jne    f010 <c_run_18.isra.0+0xf0>
    f130:	mov    rcx,rdx
    f133:	vzeroupper
    f136:	test   r13d,r13d
    f139:	je     f292 <c_run_18.isra.0+0x372>
    f13f:	cmp    r13d,0x1
    f143:	je     f292 <c_run_18.isra.0+0x372>
    f149:	mov    rax,QWORD PTR [rbp+0x20]
    f14d:	mov    DWORD PTR [rsp+0x54],0x0
    f155:	mov    r14,QWORD PTR [rsp+0x8]
    f15a:	mov    rdi,QWORD PTR [rsp+0x10]
    f15f:	mov    QWORD PTR [rsp+0x30],r15
    f164:	mov    QWORD PTR [rbp+0x18],rcx
    f168:	mov    r11d,0x8
    f16e:	mov    esi,0x1
    f173:	xor    r9d,r9d
    f176:	lea    r12d,[r13-0x1]
    f17a:	lea    r10,[rax+0x8]
    f17e:	mov    r8,rax
    f181:	nop    DWORD PTR [rax+0x0]
    f185:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f190:	mov    DWORD PTR [rsp+0x58],r12d
    f195:	dec    r12d
    f198:	mov    eax,DWORD PTR [rsp+0x54]
    f19c:	cmp    r12d,0xe
    f1a0:	jbe    f370 <c_run_18.isra.0+0x450>
    f1a6:	cmp    r13d,esi
    f1a9:	jle    f370 <c_run_18.isra.0+0x450>
    f1af:	mov    r15d,DWORD PTR [rsp+0x58]
    f1b4:	lea    ecx,[rax+r13*1]
    f1b8:	mov    DWORD PTR [rsp+0x50],ecx
    f1bc:	add    rcx,r9
    f1bf:	lea    rax,[rcx*8+0x0]
    f1c7:	dec    r15
    f1ca:	mov    rdx,r15
    f1cd:	imul   rdx,rbx
    f1d1:	add    rdx,rcx
    f1d4:	shl    rdx,0x3
    f1d8:	cmp    rdx,r11
    f1db:	jl     f1ea <c_run_18.isra.0+0x2ca>
    f1dd:	lea    rdx,[r11+r15*8]
    f1e1:	cmp    rax,rdx
    f1e4:	jle    f377 <c_run_18.isra.0+0x457>
    f1ea:	mov    ecx,DWORD PTR [rsp+0x58]
    f1ee:	add    rax,QWORD PTR [rbp+0x20]
    f1f2:	mov    rdx,r10
    f1f5:	shr    ecx,1
    f1f7:	mov    r15d,ecx
    f1fa:	shl    r15,0x4
    f1fe:	add    r15,r10
    f201:	nop    WORD PTR [rax+rax*1+0x0]
    f20a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f215:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f220:	vmovsd xmm0,QWORD PTR [rax]
    f224:	vmovhpd xmm0,xmm0,QWORD PTR [rax+rbx*8]
    f229:	add    rdx,0x10
    f22d:	add    rax,r14
    f230:	vmovupd XMMWORD PTR [rdx-0x10],xmm0
    f235:	cmp    r15,rdx
    f238:	jne    f220 <c_run_18.isra.0+0x300>
    f23a:	add    ecx,ecx
    f23c:	cmp    ecx,DWORD PTR [rsp+0x58]
    f240:	je     f265 <c_run_18.isra.0+0x345>
    f242:	add    ecx,esi
    f244:	mov    eax,r13d
    f247:	mov    rdx,QWORD PTR [rbp+0x20]
    f24b:	imul   eax,ecx
    f24e:	add    eax,r9d
    f251:	mov    eax,eax
    f253:	vmovsd xmm0,QWORD PTR [rdx+rax*8]
    f258:	mov    eax,DWORD PTR [rsp+0x54]
    f25c:	add    eax,ecx
    f25e:	mov    eax,eax
    f260:	vmovsd QWORD PTR [rdx+rax*8],xmm0
    f265:	mov    eax,DWORD PTR [rsp+0x50]
    f269:	inc    rsi
    f26c:	inc    r9
    f26f:	add    r8,rdi
    f272:	lea    r11,[r11+rdi*1+0x8]
    f277:	lea    r10,[r10+rdi*1+0x8]
    f27c:	mov    DWORD PTR [rsp+0x54],eax
    f280:	cmp    rbx,rsi
    f283:	jne    f190 <c_run_18.isra.0+0x270>
    f289:	mov    r15,QWORD PTR [rsp+0x30]
    f28e:	mov    rcx,QWORD PTR [rbp+0x18]
    f292:	mov    rax,QWORD PTR [rsp+0x40]
    f297:	mov    rdi,QWORD PTR [rsp+0x38]
    f29c:	mov    rsi,QWORD PTR [rbp+0x10]
    f2a0:	mov    rdx,QWORD PTR [rbp+0x20]
    f2a4:	mov    r8,QWORD PTR [rbp+0x28]
    f2a8:	inc    DWORD PTR [rsp+0x4c]
    f2ac:	mov    edi,DWORD PTR [rsp+0x24]
    f2b0:	cmp    DWORD PTR [rsp+0x4c],edi
    f2b4:	jne    efa0 <c_run_18.isra.0+0x80>
    f2ba:	lea    rsp,[rbp-0x28]
    f2be:	pop    rbx
    f2bf:	pop    r12
    f2c1:	pop    r13
    f2c3:	pop    r14
    f2c5:	pop    r15
    f2c7:	pop    rbp
    f2c8:	ret
    f2c9:	lea    rcx,[r9+0x8]
    f2cd:	cmp    r11,rcx
    f2d0:	je     f3ba <c_run_18.isra.0+0x49a>
    f2d6:	add    r9,0x10
    f2da:	cmp    r9,r11
    f2dd:	je     f3ba <c_run_18.isra.0+0x49a>
    f2e3:	vcomisd xmm3,QWORD PTR [r9]
    f2e8:	je     f000 <c_run_18.isra.0+0xe0>
    f2ee:	jmp    f2c9 <c_run_18.isra.0+0x3a9>
    f2f0:	shl    rax,0x3
    f2f4:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1]
    f2fa:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1]
    f300:	vmovsd QWORD PTR [r14+rax*1],xmm0
    f306:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1+0x8]
    f30d:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1+0x8]
    f314:	vmovsd QWORD PTR [r14+rax*1+0x8],xmm0
    f31b:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*1+0x10]
    f322:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*1+0x10]
    f329:	vmovsd QWORD PTR [r14+rax*1+0x10],xmm1
    f330:	jmp    f040 <c_run_18.isra.0+0x120>
    f335:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f340:	shl    rax,0x3
    f344:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1]
    f34a:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1]
    f350:	vmovsd QWORD PTR [r14+rax*1],xmm0
    f356:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*1+0x8]
    f35d:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*1+0x8]
    f364:	vmovsd QWORD PTR [r14+rax*1+0x8],xmm1
    f36b:	jmp    f040 <c_run_18.isra.0+0x120>
    f370:	add    eax,r13d
    f373:	mov    DWORD PTR [rsp+0x50],eax
    f377:	mov    eax,DWORD PTR [rsp+0x50]
    f37b:	mov    rcx,QWORD PTR [rbp+0x20]
    f37f:	add    rax,r9
    f382:	lea    rdx,[rcx+rax*8]
    f386:	mov    rax,rsi
    f389:	nop
    f38a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f395:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f3a0:	vmovsd xmm0,QWORD PTR [rdx]
    f3a4:	add    rdx,rdi
    f3a7:	vmovsd QWORD PTR [r8+rax*8],xmm0
    f3ad:	inc    rax
    f3b0:	cmp    r13d,eax
    f3b3:	jg     f3a0 <c_run_18.isra.0+0x480>
    f3b5:	jmp    f265 <c_run_18.isra.0+0x345>
    f3ba:	mov    rcx,rdx
    f3bd:	vzeroupper
    f3c0:	jmp    f292 <c_run_18.isra.0+0x372>
    f3c5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_19.isra.0>:
    f3d0:	push   rbp
    f3d1:	mov    rbp,rsp
    f3d4:	push   r15
    f3d6:	push   r14
    f3d8:	push   r13
    f3da:	push   r12
    f3dc:	push   rbx
    f3dd:	and    rsp,0xffffffffffffffe0
    f3e1:	sub    rsp,0x40
    f3e5:	mov    r12,QWORD PTR [rbp+0x20]
    f3e9:	mov    QWORD PTR [rsp+0x28],r8
    f3ee:	mov    QWORD PTR [rsp+0x20],r9
    f3f3:	mov    r8,QWORD PTR [rbp+0x18]
    f3f7:	test   edx,edx
    f3f9:	je     f614 <c_run_19.isra.0+0x244>
    f3ff:	mov    eax,esi
    f401:	mov    DWORD PTR [rsp+0x18],edx
    f405:	mov    DWORD PTR [rsp+0xc],edi
    f409:	mov    ebx,esi
    f40b:	xor    r13d,r13d
    f40e:	imul   eax,esi
    f411:	shl    rax,0x3
    f415:	mov    QWORD PTR [rsp+0x10],rax
    f41a:	mov    eax,edi
    f41c:	lea    r15,[r8+rax*8]
    f420:	lea    eax,[rsi+0x1]
    f423:	mov    DWORD PTR [rsp+0x8],eax
    f427:	nop    WORD PTR [rax+rax*1+0x0]
    f430:	mov    rax,QWORD PTR [rsp+0x28]
    f435:	mov    rdi,QWORD PTR [rsp+0x20]
    f43a:	mov    rdx,QWORD PTR [rbp+0x10]
    f43e:	mov    rsi,QWORD PTR [rbp+0x28]
    f442:	mov    rdx,QWORD PTR [rsp+0x10]
    f447:	xor    esi,esi
    f449:	mov    rdi,r12
    f44c:	mov    QWORD PTR [rbp+0x18],r8
    f450:	mov    QWORD PTR [rsp+0x38],rcx
    f455:	call   2bd0 <memset@plt>
    f45a:	mov    eax,DWORD PTR [rsp+0xc]
    f45e:	mov    rcx,QWORD PTR [rsp+0x38]
    f463:	mov    r8,QWORD PTR [rbp+0x18]
    f467:	vxorpd xmm3,xmm3,xmm3
    f46b:	test   eax,eax
    f46d:	je     f5f4 <c_run_19.isra.0+0x224>
    f473:	mov    r14d,DWORD PTR [rsp+0x8]
    f478:	mov    DWORD PTR [rsp+0x1c],r13d
    f47d:	mov    QWORD PTR [rbp+0x20],r12
    f481:	mov    r9,r8
    f484:	xor    eax,eax
    f486:	mov    rdx,rcx
    f489:	jmp    f4af <c_run_19.isra.0+0xdf>
    f48b:	cs nop WORD PTR [rax+rax*1+0x0]
    f495:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f4a0:	add    r9,0x8
    f4a4:	add    eax,ebx
    f4a6:	cmp    r15,r9
    f4a9:	je     f5e5 <c_run_19.isra.0+0x215>
    f4af:	vcomisd xmm3,QWORD PTR [r9]
    f4b4:	je     f4a0 <c_run_19.isra.0+0xd0>
    f4b6:	test   ebx,ebx
    f4b8:	je     f623 <c_run_19.isra.0+0x253>
    f4be:	mov    QWORD PTR [rsp+0x30],r15
    f4c3:	mov    rdi,r8
    f4c6:	mov    esi,eax
    f4c8:	mov    DWORD PTR [rsp+0x38],eax
    f4cc:	mov    r8d,0xfffffffd
    f4d2:	xor    r10d,r10d
    f4d5:	lea    r11,[rdx+rsi*8]
    f4d9:	mov    esi,0x1
    f4de:	jmp    f4f2 <c_run_19.isra.0+0x122>
    f4e0:	inc    rsi
    f4e3:	add    r10d,ebx
    f4e6:	inc    r8d
    f4e9:	cmp    r14,rsi
    f4ec:	je     f5b0 <c_run_19.isra.0+0x1e0>
    f4f2:	vmovsd xmm0,QWORD PTR [r11+rsi*8-0x8]
    f4f9:	vcomisd xmm0,xmm3
    f4fd:	je     f4e0 <c_run_19.isra.0+0x110>
    f4ff:	mov    rcx,QWORD PTR [rbp+0x20]
    f503:	mov    eax,r10d
    f506:	vmulsd xmm1,xmm0,QWORD PTR [r9]
    f50b:	mov    r13d,esi
    f50e:	lea    r15,[rcx+rax*8]
    f512:	xor    eax,eax
    f514:	test   r8d,r8d
    f517:	js     f563 <c_run_19.isra.0+0x193>
    f519:	mov    eax,r8d
    f51c:	mov    rcx,r15
    f51f:	sub    rcx,r11
    f522:	vbroadcastsd ymm2,xmm1
    f527:	shr    eax,0x2
    f52a:	shl    rax,0x5
    f52e:	lea    r12,[r11+rax*1+0x20]
    f533:	mov    rax,r11
    f536:	cs nop WORD PTR [rax+rax*1+0x0]
    f540:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    f544:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx+rax*1]
    f549:	vmovupd YMMWORD PTR [rcx+rax*1],ymm0
    f54e:	add    rax,0x20
    f552:	cmp    r12,rax
    f555:	jne    f540 <c_run_19.isra.0+0x170>
    f557:	mov    eax,r8d
    f55a:	and    eax,0xfffffffc
    f55d:	add    eax,0x4
    f560:	sub    r13d,eax
    f563:	cmp    r13d,0x3
    f567:	je     f650 <c_run_19.isra.0+0x280>
    f56d:	cmp    r13d,0x2
    f571:	je     f6a0 <c_run_19.isra.0+0x2d0>
    f577:	cmp    r13d,0x1
    f57b:	jne    f4e0 <c_run_19.isra.0+0x110>
    f581:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*8]
    f587:	inc    rsi
    f58a:	add    r10d,ebx
    f58d:	inc    r8d
    f590:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*8]
    f596:	vmovsd QWORD PTR [r15+rax*8],xmm1
    f59c:	cmp    r14,rsi
    f59f:	jne    f4f2 <c_run_19.isra.0+0x122>
    f5a5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f5b0:	mov    r15,QWORD PTR [rsp+0x30]
    f5b5:	add    r9,0x8
    f5b9:	mov    eax,DWORD PTR [rsp+0x38]
    f5bd:	cmp    r9,r15
    f5c0:	je     f6d0 <c_run_19.isra.0+0x300>
    f5c6:	add    eax,ebx
    f5c8:	vcomisd xmm3,QWORD PTR [r9]
    f5cd:	jne    f4c6 <c_run_19.isra.0+0xf6>
    f5d3:	add    r9,0x8
    f5d7:	mov    r8,rdi
    f5da:	add    eax,ebx
    f5dc:	cmp    r15,r9
    f5df:	jne    f4af <c_run_19.isra.0+0xdf>
    f5e5:	mov    r13d,DWORD PTR [rsp+0x1c]
    f5ea:	mov    r12,QWORD PTR [rbp+0x20]
    f5ee:	mov    rcx,rdx
    f5f1:	vzeroupper
    f5f4:	mov    rax,QWORD PTR [rsp+0x28]
    f5f9:	mov    rdi,QWORD PTR [rsp+0x20]
    f5fe:	mov    rdx,QWORD PTR [rbp+0x10]
    f602:	mov    rsi,QWORD PTR [rbp+0x28]
    f606:	inc    r13d
    f609:	cmp    r13d,DWORD PTR [rsp+0x18]
    f60e:	jne    f430 <c_run_19.isra.0+0x60>
    f614:	lea    rsp,[rbp-0x28]
    f618:	pop    rbx
    f619:	pop    r12
    f61b:	pop    r13
    f61d:	pop    r14
    f61f:	pop    r15
    f621:	pop    rbp
    f622:	ret
    f623:	lea    rcx,[r9+0x8]
    f627:	cmp    r15,rcx
    f62a:	je     f5e5 <c_run_19.isra.0+0x215>
    f62c:	add    r9,0x10
    f630:	cmp    r9,r15
    f633:	je     f5e5 <c_run_19.isra.0+0x215>
    f635:	vcomisd xmm3,QWORD PTR [r9]
    f63a:	je     f4a0 <c_run_19.isra.0+0xd0>
    f640:	jmp    f623 <c_run_19.isra.0+0x253>
    f642:	nop    DWORD PTR [rax]
    f645:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f650:	shl    rax,0x3
    f654:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1]
    f65a:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    f660:	vmovsd QWORD PTR [r15+rax*1],xmm0
    f666:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1+0x8]
    f66d:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1+0x8]
    f674:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm0
    f67b:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*1+0x10]
    f682:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x10]
    f689:	vmovsd QWORD PTR [r15+rax*1+0x10],xmm1
    f690:	jmp    f4e0 <c_run_19.isra.0+0x110>
    f695:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f6a0:	shl    rax,0x3
    f6a4:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1]
    f6aa:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    f6b0:	vmovsd QWORD PTR [r15+rax*1],xmm0
    f6b6:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*1+0x8]
    f6bd:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x8]
    f6c4:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm1
    f6cb:	jmp    f4e0 <c_run_19.isra.0+0x110>
    f6d0:	mov    r13d,DWORD PTR [rsp+0x1c]
    f6d5:	mov    r12,QWORD PTR [rbp+0x20]
    f6d9:	mov    rcx,rdx
    f6dc:	mov    r8,rdi
    f6df:	vzeroupper
    f6e2:	jmp    f5f4 <c_run_19.isra.0+0x224>
    f6e7:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_2.isra.0>:
    8610:	mov    r11d,edi
    8613:	mov    rax,rsi
    8616:	mov    r10,QWORD PTR [rsp+0x10]
    861b:	mov    rsi,rdx
    861e:	mov    rdi,rcx
    8621:	mov    rdx,QWORD PTR [rsp+0x8]
    8626:	test   r11d,r11d
    8629:	je     869a <c_run_2.isra.0+0x8a>
    862b:	xor    ecx,ecx
    862d:	nop    DWORD PTR [rax]
    8630:	vmovsd xmm0,QWORD PTR [r8]
    8635:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x18]
    863a:	vmovsd xmm4,QWORD PTR [r8+0x8]
    8640:	vmovsd xmm3,QWORD PTR [r8+0x10]
    8646:	vmulsd xmm2,xmm4,QWORD PTR [rax+0x20]
    864b:	vmulsd xmm5,xmm4,QWORD PTR [rax+0x38]
    8650:	vmulsd xmm4,xmm4,QWORD PTR [rax+0x8]
    8655:	vaddsd xmm1,xmm1,xmm2
    8659:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x28]
    865e:	vaddsd xmm2,xmm1,xmm2
    8662:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x30]
    8667:	vmulsd xmm0,xmm0,QWORD PTR [rax]
    866b:	vaddsd xmm1,xmm1,xmm5
    866f:	vmulsd xmm5,xmm3,QWORD PTR [rax+0x40]
    8674:	vmulsd xmm3,xmm3,QWORD PTR [rax+0x10]
    8679:	vaddsd xmm0,xmm0,xmm4
    867d:	vmovsd QWORD PTR [rdx+0x8],xmm2
    8682:	vaddsd xmm1,xmm1,xmm5
    8686:	vaddsd xmm0,xmm0,xmm3
    868a:	vmovsd QWORD PTR [rdx+0x10],xmm1
    868f:	vmovsd QWORD PTR [rdx],xmm0
    8693:	inc    ecx
    8695:	cmp    ecx,r11d
    8698:	jne    8630 <c_run_2.isra.0+0x20>
    869a:	ret
    869b:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_20.isra.0>:
    f6f0:	push   rbp
    f6f1:	mov    rbp,rsp
    f6f4:	push   r15
    f6f6:	push   r14
    f6f8:	push   r13
    f6fa:	push   r12
    f6fc:	push   rbx
    f6fd:	and    rsp,0xffffffffffffffe0
    f701:	sub    rsp,0x40
    f705:	mov    QWORD PTR [rsp+0x30],rcx
    f70a:	mov    QWORD PTR [rsp+0x28],r8
    f70f:	mov    QWORD PTR [rsp+0x20],r9
    f714:	test   edx,edx
    f716:	je     f8f0 <c_run_20.isra.0+0x200>
    f71c:	mov    eax,esi
    f71e:	mov    DWORD PTR [rsp+0x18],edx
    f722:	mov    DWORD PTR [rsp+0x38],esi
    f726:	mov    r12d,esi
    f729:	mov    ebx,edi
    f72b:	xor    r14d,r14d
    f72e:	imul   eax,esi
    f731:	shl    r12,0x3
    f735:	shl    rax,0x3
    f739:	mov    QWORD PTR [rsp+0x10],rax
    f73e:	mov    rax,QWORD PTR [rsp+0x30]
    f743:	mov    rdi,QWORD PTR [rsp+0x28]
    f748:	mov    rsi,QWORD PTR [rsp+0x20]
    f74d:	mov    rdx,QWORD PTR [rbp+0x10]
    f751:	mov    rcx,QWORD PTR [rbp+0x18]
    f755:	mov    r9,QWORD PTR [rbp+0x20]
    f759:	mov    r15,QWORD PTR [rbp+0x28]
    f75d:	mov    rdx,QWORD PTR [rsp+0x10]
    f762:	mov    rdi,QWORD PTR [rbp+0x20]
    f766:	xor    esi,esi
    f768:	call   2bd0 <memset@plt>
    f76d:	mov    eax,DWORD PTR [rsp+0x38]
    f771:	vxorpd xmm3,xmm3,xmm3
    f775:	test   eax,eax
    f777:	je     f8c3 <c_run_20.isra.0+0x1d3>
    f77d:	test   ebx,ebx
    f77f:	je     f8c3 <c_run_20.isra.0+0x1d3>
    f785:	mov    DWORD PTR [rsp+0x1c],r14d
    f78a:	mov    r10d,0xfffffffd
    f790:	xor    r9d,r9d
    f793:	xor    r8d,r8d
    f796:	xor    r13d,r13d
    f799:	nop    DWORD PTR [rax+0x0]
    f7a0:	mov    rdi,QWORD PTR [rbp+0x20]
    f7a4:	movsxd rax,r9d
    f7a7:	mov    ecx,r10d
    f7aa:	mov    r14d,r10d
    f7ad:	and    r14d,0xfffffffc
    f7b1:	inc    r13d
    f7b4:	mov    DWORD PTR [rsp+0x3c],r9d
    f7b9:	xor    edx,edx
    f7bb:	add    r14d,0x4
    f7bf:	shr    ecx,0x2
    f7c2:	lea    rsi,[rdi+rax*8]
    f7c6:	mov    rax,QWORD PTR [rsp+0x30]
    f7cb:	mov    r15d,r13d
    f7ce:	sub    r15d,r14d
    f7d1:	mov    r9d,r14d
    f7d4:	shl    rcx,0x5
    f7d8:	lea    rdi,[rsi+rcx*1+0x20]
    f7dd:	sub    rax,rsi
    f7e0:	jmp    f80d <c_run_20.isra.0+0x11d>
    f7e2:	nop    DWORD PTR [rax+rax*1+0x0]
    f7ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f7f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f800:	inc    edx
    f802:	add    rax,r12
    f805:	cmp    ebx,edx
    f807:	je     f8a0 <c_run_20.isra.0+0x1b0>
    f80d:	lea    r11,[rsi+rax*1]
    f811:	vmovsd xmm1,QWORD PTR [r11+r8*8]
    f817:	vcomisd xmm1,xmm3
    f81b:	je     f800 <c_run_20.isra.0+0x110>
    f81d:	test   r10d,r10d
    f820:	js     f900 <c_run_20.isra.0+0x210>
    f826:	vbroadcastsd ymm2,xmm1
    f82b:	mov    rcx,rsi
    f82e:	nop    DWORD PTR [rax+0x0]
    f835:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f840:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
    f845:	add    rcx,0x20
    f849:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    f84e:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
    f853:	cmp    rdi,rcx
    f856:	jne    f840 <c_run_20.isra.0+0x150>
    f858:	mov    r14d,r15d
    f85b:	mov    ecx,r9d
    f85e:	cmp    r14d,0x3
    f862:	je     f90f <c_run_20.isra.0+0x21f>
    f868:	cmp    r14d,0x2
    f86c:	je     f950 <c_run_20.isra.0+0x260>
    f872:	cmp    r14d,0x1
    f876:	jne    f800 <c_run_20.isra.0+0x110>
    f878:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*8]
    f87e:	inc    edx
    f880:	add    rax,r12
    f883:	vaddsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    f888:	vmovsd QWORD PTR [rsi+rcx*8],xmm1
    f88d:	cmp    ebx,edx
    f88f:	jne    f80d <c_run_20.isra.0+0x11d>
    f895:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    f8a0:	mov    r9d,DWORD PTR [rsp+0x3c]
    f8a5:	mov    eax,DWORD PTR [rsp+0x38]
    f8a9:	inc    r8
    f8ac:	inc    r10d
    f8af:	add    r9d,eax
    f8b2:	cmp    eax,r13d
    f8b5:	jne    f7a0 <c_run_20.isra.0+0xb0>
    f8bb:	mov    r14d,DWORD PTR [rsp+0x1c]
    f8c0:	vzeroupper
    f8c3:	mov    rax,QWORD PTR [rsp+0x30]
    f8c8:	mov    rdi,QWORD PTR [rsp+0x28]
    f8cd:	mov    rsi,QWORD PTR [rsp+0x20]
    f8d2:	mov    rdx,QWORD PTR [rbp+0x10]
    f8d6:	mov    rcx,QWORD PTR [rbp+0x18]
    f8da:	mov    r9,QWORD PTR [rbp+0x20]
    f8de:	mov    r15,QWORD PTR [rbp+0x28]
    f8e2:	inc    r14d
    f8e5:	cmp    r14d,DWORD PTR [rsp+0x18]
    f8ea:	jne    f73e <c_run_20.isra.0+0x4e>
    f8f0:	lea    rsp,[rbp-0x28]
    f8f4:	pop    rbx
    f8f5:	pop    r12
    f8f7:	pop    r13
    f8f9:	pop    r14
    f8fb:	pop    r15
    f8fd:	pop    rbp
    f8fe:	ret
    f8ff:	nop
    f900:	mov    r14d,r13d
    f903:	xor    ecx,ecx
    f905:	cmp    r14d,0x3
    f909:	jne    f868 <c_run_20.isra.0+0x178>
    f90f:	shl    rcx,0x3
    f913:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    f919:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    f91e:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    f923:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1+0x8]
    f92a:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rsi*1+0x8]
    f930:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm0
    f936:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x10]
    f93d:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x10]
    f943:	vmovsd QWORD PTR [rcx+rsi*1+0x10],xmm1
    f949:	jmp    f800 <c_run_20.isra.0+0x110>
    f94e:	xchg   ax,ax
    f950:	shl    rcx,0x3
    f954:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    f95a:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    f95f:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    f964:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x8]
    f96b:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x8]
    f971:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm1
    f977:	jmp    f800 <c_run_20.isra.0+0x110>
    f97c:	nop    DWORD PTR [rax+0x0]


<c_run_3.isra.0>:
    86a0:	mov    r11d,edi
    86a3:	mov    r10,QWORD PTR [rsp+0x10]
    86a8:	mov    rdi,rdx
    86ab:	mov    rax,rsi
    86ae:	mov    rdx,QWORD PTR [rsp+0x8]
    86b3:	test   r11d,r11d
    86b6:	je     8720 <c_run_3.isra.0+0x80>
    86b8:	xor    esi,esi
    86ba:	nop    WORD PTR [rax+rax*1+0x0]
    86c0:	vmovupd xmm0,XMMWORD PTR [r8]
    86c5:	vmovsd xmm1,QWORD PTR [rax+0x10]
    86ca:	vmovsd xmm3,QWORD PTR [r8+0x10]
    86d0:	vunpckhpd xmm2,xmm0,xmm0
    86d4:	vmulsd xmm2,xmm2,QWORD PTR [rax+0x28]
    86d9:	vmulsd xmm1,xmm1,xmm0
    86dd:	vaddsd xmm1,xmm1,xmm2
    86e1:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x40]
    86e6:	vmovddup xmm3,xmm3
    86ea:	vmulpd xmm3,xmm3,XMMWORD PTR [rax+0x30]
    86ef:	vaddsd xmm1,xmm1,xmm2
    86f3:	vpermilpd xmm2,xmm0,0x0
    86f9:	vpermilpd xmm0,xmm0,0x3
    86ff:	vmulpd xmm2,xmm2,XMMWORD PTR [rax]
    8703:	vmulpd xmm0,xmm0,XMMWORD PTR [rax+0x18]
    8708:	vmovsd QWORD PTR [rdx+0x10],xmm1
    870d:	vaddpd xmm0,xmm2,xmm0
    8711:	vaddpd xmm0,xmm0,xmm3
    8715:	vmovupd XMMWORD PTR [rdx],xmm0
    8719:	inc    esi
    871b:	cmp    esi,r11d
    871e:	jne    86c0 <c_run_3.isra.0+0x20>
    8720:	ret
    8721:	nop    DWORD PTR [rax+0x0]
    8725:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_4.isra.0>:
    8730:	mov    r11d,edi
    8733:	mov    r10,QWORD PTR [rsp+0x10]
    8738:	mov    rdi,rcx
    873b:	mov    rax,rsi
    873e:	mov    rcx,QWORD PTR [rsp+0x8]
    8743:	test   r11d,r11d
    8746:	je     88d7 <c_run_4.isra.0+0x1a7>
    874c:	xor    esi,esi
    874e:	xchg   ax,ax
    8750:	vmovsd xmm0,QWORD PTR [rax]
    8754:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    8758:	vmovsd xmm1,QWORD PTR [rax+0x8]
    875d:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    8762:	vaddsd xmm0,xmm0,xmm1
    8766:	vmovsd xmm1,QWORD PTR [rax+0x10]
    876b:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    8770:	vaddsd xmm0,xmm0,xmm1
    8774:	vmovsd QWORD PTR [rcx],xmm0
    8778:	vmovsd xmm0,QWORD PTR [rax]
    877c:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    8781:	vmovsd xmm1,QWORD PTR [rax+0x8]
    8786:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    878b:	vaddsd xmm0,xmm0,xmm1
    878f:	vmovsd xmm1,QWORD PTR [rax+0x10]
    8794:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    8799:	vaddsd xmm0,xmm0,xmm1
    879d:	vmovsd QWORD PTR [rcx+0x8],xmm0
    87a2:	vmovsd xmm0,QWORD PTR [rax]
    87a6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    87ab:	vmovsd xmm1,QWORD PTR [rax+0x8]
    87b0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    87b5:	vaddsd xmm0,xmm0,xmm1
    87b9:	vmovsd xmm1,QWORD PTR [rax+0x10]
    87be:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    87c3:	vaddsd xmm0,xmm0,xmm1
    87c7:	vmovsd QWORD PTR [rcx+0x10],xmm0
    87cc:	vmovsd xmm0,QWORD PTR [rax+0x18]
    87d1:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    87d5:	vmovsd xmm1,QWORD PTR [rax+0x20]
    87da:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    87df:	vaddsd xmm0,xmm0,xmm1
    87e3:	vmovsd xmm1,QWORD PTR [rax+0x28]
    87e8:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    87ed:	vaddsd xmm0,xmm0,xmm1
    87f1:	vmovsd QWORD PTR [rcx+0x18],xmm0
    87f6:	vmovsd xmm0,QWORD PTR [rax+0x18]
    87fb:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    8800:	vmovsd xmm1,QWORD PTR [rax+0x20]
    8805:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    880a:	vaddsd xmm0,xmm0,xmm1
    880e:	vmovsd xmm1,QWORD PTR [rax+0x28]
    8813:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    8818:	vaddsd xmm0,xmm0,xmm1
    881c:	vmovsd QWORD PTR [rcx+0x20],xmm0
    8821:	vmovsd xmm0,QWORD PTR [rax+0x18]
    8826:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    882b:	vmovsd xmm1,QWORD PTR [rax+0x20]
    8830:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    8835:	vaddsd xmm0,xmm0,xmm1
    8839:	vmovsd xmm1,QWORD PTR [rax+0x28]
    883e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    8843:	vaddsd xmm0,xmm0,xmm1
    8847:	vmovsd QWORD PTR [rcx+0x28],xmm0
    884c:	vmovsd xmm0,QWORD PTR [rax+0x30]
    8851:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    8855:	vmovsd xmm1,QWORD PTR [rax+0x38]
    885a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    885f:	vaddsd xmm0,xmm0,xmm1
    8863:	vmovsd xmm1,QWORD PTR [rax+0x40]
    8868:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    886d:	vaddsd xmm0,xmm0,xmm1
    8871:	vmovsd QWORD PTR [rcx+0x30],xmm0
    8876:	vmovsd xmm0,QWORD PTR [rax+0x30]
    887b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    8880:	vmovsd xmm1,QWORD PTR [rax+0x38]
    8885:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    888a:	vaddsd xmm0,xmm0,xmm1
    888e:	vmovsd xmm1,QWORD PTR [rax+0x40]
    8893:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    8898:	vaddsd xmm0,xmm0,xmm1
    889c:	vmovsd QWORD PTR [rcx+0x38],xmm0
    88a1:	vmovsd xmm0,QWORD PTR [rax+0x30]
    88a6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    88ab:	vmovsd xmm1,QWORD PTR [rax+0x38]
    88b0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    88b5:	vaddsd xmm0,xmm0,xmm1
    88b9:	vmovsd xmm1,QWORD PTR [rax+0x40]
    88be:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    88c3:	vaddsd xmm0,xmm0,xmm1
    88c7:	vmovsd QWORD PTR [rcx+0x40],xmm0
    88cc:	inc    esi
    88ce:	cmp    esi,r11d
    88d1:	jne    8750 <c_run_4.isra.0+0x20>
    88d7:	ret
    88d8:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_5.isra.0>:
    88e0:	mov    r11d,edi
    88e3:	mov    r10,QWORD PTR [rsp+0x10]
    88e8:	mov    rdi,rcx
    88eb:	mov    rax,rsi
    88ee:	mov    rcx,QWORD PTR [rsp+0x8]
    88f3:	test   r11d,r11d
    88f6:	je     8a87 <c_run_5.isra.0+0x1a7>
    88fc:	xor    esi,esi
    88fe:	xchg   ax,ax
    8900:	vmovsd xmm0,QWORD PTR [rax]
    8904:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    8908:	vmovsd xmm1,QWORD PTR [rax+0x18]
    890d:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    8912:	vaddsd xmm0,xmm0,xmm1
    8916:	vmovsd xmm1,QWORD PTR [rax+0x30]
    891b:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    8920:	vaddsd xmm0,xmm0,xmm1
    8924:	vmovsd QWORD PTR [rcx],xmm0
    8928:	vmovsd xmm0,QWORD PTR [rax]
    892c:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    8931:	vmovsd xmm1,QWORD PTR [rax+0x18]
    8936:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    893b:	vaddsd xmm0,xmm0,xmm1
    893f:	vmovsd xmm1,QWORD PTR [rax+0x30]
    8944:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    8949:	vaddsd xmm0,xmm0,xmm1
    894d:	vmovsd QWORD PTR [rcx+0x8],xmm0
    8952:	vmovsd xmm0,QWORD PTR [rax]
    8956:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    895b:	vmovsd xmm1,QWORD PTR [rax+0x18]
    8960:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    8965:	vaddsd xmm0,xmm0,xmm1
    8969:	vmovsd xmm1,QWORD PTR [rax+0x30]
    896e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    8973:	vaddsd xmm0,xmm0,xmm1
    8977:	vmovsd QWORD PTR [rcx+0x10],xmm0
    897c:	vmovsd xmm0,QWORD PTR [rax+0x8]
    8981:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    8985:	vmovsd xmm1,QWORD PTR [rax+0x20]
    898a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    898f:	vaddsd xmm0,xmm0,xmm1
    8993:	vmovsd xmm1,QWORD PTR [rax+0x38]
    8998:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    899d:	vaddsd xmm0,xmm0,xmm1
    89a1:	vmovsd QWORD PTR [rcx+0x18],xmm0
    89a6:	vmovsd xmm0,QWORD PTR [rax+0x8]
    89ab:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    89b0:	vmovsd xmm1,QWORD PTR [rax+0x20]
    89b5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    89ba:	vaddsd xmm0,xmm0,xmm1
    89be:	vmovsd xmm1,QWORD PTR [rax+0x38]
    89c3:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    89c8:	vaddsd xmm0,xmm0,xmm1
    89cc:	vmovsd QWORD PTR [rcx+0x20],xmm0
    89d1:	vmovsd xmm0,QWORD PTR [rax+0x8]
    89d6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    89db:	vmovsd xmm1,QWORD PTR [rax+0x20]
    89e0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    89e5:	vaddsd xmm0,xmm0,xmm1
    89e9:	vmovsd xmm1,QWORD PTR [rax+0x38]
    89ee:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    89f3:	vaddsd xmm0,xmm0,xmm1
    89f7:	vmovsd QWORD PTR [rcx+0x28],xmm0
    89fc:	vmovsd xmm0,QWORD PTR [rax+0x10]
    8a01:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    8a05:	vmovsd xmm1,QWORD PTR [rax+0x28]
    8a0a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    8a0f:	vaddsd xmm0,xmm0,xmm1
    8a13:	vmovsd xmm1,QWORD PTR [rax+0x40]
    8a18:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    8a1d:	vaddsd xmm0,xmm0,xmm1
    8a21:	vmovsd QWORD PTR [rcx+0x30],xmm0
    8a26:	vmovsd xmm0,QWORD PTR [rax+0x10]
    8a2b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    8a30:	vmovsd xmm1,QWORD PTR [rax+0x28]
    8a35:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    8a3a:	vaddsd xmm0,xmm0,xmm1
    8a3e:	vmovsd xmm1,QWORD PTR [rax+0x40]
    8a43:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    8a48:	vaddsd xmm0,xmm0,xmm1
    8a4c:	vmovsd QWORD PTR [rcx+0x38],xmm0
    8a51:	vmovsd xmm0,QWORD PTR [rax+0x10]
    8a56:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    8a5b:	vmovsd xmm1,QWORD PTR [rax+0x28]
    8a60:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    8a65:	vaddsd xmm0,xmm0,xmm1
    8a69:	vmovsd xmm1,QWORD PTR [rax+0x40]
    8a6e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    8a73:	vaddsd xmm0,xmm0,xmm1
    8a77:	vmovsd QWORD PTR [rcx+0x40],xmm0
    8a7c:	inc    esi
    8a7e:	cmp    esi,r11d
    8a81:	jne    8900 <c_run_5.isra.0+0x20>
    8a87:	ret
    8a88:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_6.isra.0>:
    8a90:	mov    r11d,edi
    8a93:	mov    r10,QWORD PTR [rsp+0x10]
    8a98:	mov    rdi,rcx
    8a9b:	mov    rax,rsi
    8a9e:	mov    rcx,QWORD PTR [rsp+0x8]
    8aa3:	test   r11d,r11d
    8aa6:	je     8c37 <c_run_6.isra.0+0x1a7>
    8aac:	xor    esi,esi
    8aae:	xchg   ax,ax
    8ab0:	vmovsd xmm0,QWORD PTR [rax]
    8ab4:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    8ab8:	vmovsd xmm1,QWORD PTR [rax+0x8]
    8abd:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    8ac2:	vaddsd xmm0,xmm0,xmm1
    8ac6:	vmovsd xmm1,QWORD PTR [rax+0x10]
    8acb:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    8ad0:	vaddsd xmm0,xmm0,xmm1
    8ad4:	vmovsd QWORD PTR [rcx],xmm0
    8ad8:	vmovsd xmm0,QWORD PTR [rax]
    8adc:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    8ae1:	vmovsd xmm1,QWORD PTR [rax+0x8]
    8ae6:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    8aeb:	vaddsd xmm0,xmm0,xmm1
    8aef:	vmovsd xmm1,QWORD PTR [rax+0x10]
    8af4:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    8af9:	vaddsd xmm0,xmm0,xmm1
    8afd:	vmovsd QWORD PTR [rcx+0x8],xmm0
    8b02:	vmovsd xmm0,QWORD PTR [rax]
    8b06:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    8b0b:	vmovsd xmm1,QWORD PTR [rax+0x8]
    8b10:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    8b15:	vaddsd xmm0,xmm0,xmm1
    8b19:	vmovsd xmm1,QWORD PTR [rax+0x10]
    8b1e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    8b23:	vaddsd xmm0,xmm0,xmm1
    8b27:	vmovsd QWORD PTR [rcx+0x10],xmm0
    8b2c:	vmovsd xmm0,QWORD PTR [rax+0x18]
    8b31:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    8b35:	vmovsd xmm1,QWORD PTR [rax+0x20]
    8b3a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    8b3f:	vaddsd xmm0,xmm0,xmm1
    8b43:	vmovsd xmm1,QWORD PTR [rax+0x28]
    8b48:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    8b4d:	vaddsd xmm0,xmm0,xmm1
    8b51:	vmovsd QWORD PTR [rcx+0x18],xmm0
    8b56:	vmovsd xmm0,QWORD PTR [rax+0x18]
    8b5b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    8b60:	vmovsd xmm1,QWORD PTR [rax+0x20]
    8b65:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    8b6a:	vaddsd xmm0,xmm0,xmm1
    8b6e:	vmovsd xmm1,QWORD PTR [rax+0x28]
    8b73:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    8b78:	vaddsd xmm0,xmm0,xmm1
    8b7c:	vmovsd QWORD PTR [rcx+0x20],xmm0
    8b81:	vmovsd xmm0,QWORD PTR [rax+0x18]
    8b86:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    8b8b:	vmovsd xmm1,QWORD PTR [rax+0x20]
    8b90:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    8b95:	vaddsd xmm0,xmm0,xmm1
    8b99:	vmovsd xmm1,QWORD PTR [rax+0x28]
    8b9e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    8ba3:	vaddsd xmm0,xmm0,xmm1
    8ba7:	vmovsd QWORD PTR [rcx+0x28],xmm0
    8bac:	vmovsd xmm0,QWORD PTR [rax+0x30]
    8bb1:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    8bb5:	vmovsd xmm1,QWORD PTR [rax+0x38]
    8bba:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    8bbf:	vaddsd xmm0,xmm0,xmm1
    8bc3:	vmovsd xmm1,QWORD PTR [rax+0x40]
    8bc8:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    8bcd:	vaddsd xmm0,xmm0,xmm1
    8bd1:	vmovsd QWORD PTR [rcx+0x30],xmm0
    8bd6:	vmovsd xmm0,QWORD PTR [rax+0x30]
    8bdb:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    8be0:	vmovsd xmm1,QWORD PTR [rax+0x38]
    8be5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    8bea:	vaddsd xmm0,xmm0,xmm1
    8bee:	vmovsd xmm1,QWORD PTR [rax+0x40]
    8bf3:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    8bf8:	vaddsd xmm0,xmm0,xmm1
    8bfc:	vmovsd QWORD PTR [rcx+0x38],xmm0
    8c01:	vmovsd xmm0,QWORD PTR [rax+0x30]
    8c06:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    8c0b:	vmovsd xmm1,QWORD PTR [rax+0x38]
    8c10:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    8c15:	vaddsd xmm0,xmm0,xmm1
    8c19:	vmovsd xmm1,QWORD PTR [rax+0x40]
    8c1e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    8c23:	vaddsd xmm0,xmm0,xmm1
    8c27:	vmovsd QWORD PTR [rcx+0x40],xmm0
    8c2c:	inc    esi
    8c2e:	cmp    esi,r11d
    8c31:	jne    8ab0 <c_run_6.isra.0+0x20>
    8c37:	ret
    8c38:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_7.isra.0>:
    e510:	push   rbp
    e511:	mov    rbp,rsp
    e514:	push   r15
    e516:	push   r14
    e518:	push   r13
    e51a:	push   r12
    e51c:	push   rbx
    e51d:	mov    r13,rcx
    e520:	mov    rcx,r8
    e523:	and    rsp,0xffffffffffffffe0
    e527:	test   edx,edx
    e529:	mov    DWORD PTR [rsp-0x8],edx
    e52d:	mov    QWORD PTR [rsp-0x10],r8
    e532:	mov    rdx,QWORD PTR [rbp+0x10]
    e536:	mov    r8,QWORD PTR [rbp+0x20]
    e53a:	je     e6c6 <c_run_7.isra.0+0x1b6>
    e540:	mov    eax,edi
    e542:	mov    ebx,esi
    e544:	mov    rdi,QWORD PTR [rbp+0x18]
    e548:	mov    rsi,QWORD PTR [rbp+0x28]
    e54c:	mov    r15,r9
    e54f:	test   eax,eax
    e551:	je     e6d5 <c_run_7.isra.0+0x1c5>
    e557:	lea    r11d,[rbx-0x8]
    e55b:	lea    ecx,[rbx-0x4]
    e55e:	mov    r9d,ebx
    e561:	lea    r10,[r8+rax*8]
    e565:	and    r11d,0xfffffffc
    e569:	mov    eax,0x4
    e56e:	add    r11d,0x8
    e572:	shl    r9,0x3
    e576:	cmp    ecx,0x3
    e579:	cmovle r11d,eax
    e57d:	xor    r14d,r14d
    e580:	mov    r12d,ebx
    e583:	sub    r12d,r11d
    e586:	cs nop WORD PTR [rax+rax*1+0x0]
    e590:	mov    DWORD PTR [rsp-0x4],r14d
    e595:	mov    rax,r13
    e598:	mov    rdi,r8
    e59b:	nop    DWORD PTR [rax+rax*1+0x0]
    e5a0:	test   ecx,ecx
    e5a2:	js     e660 <c_run_7.isra.0+0x150>
    e5a8:	vmovupd ymm1,YMMWORD PTR [rax]
    e5ac:	vmulpd ymm1,ymm1,YMMWORD PTR [rdx]
    e5b0:	cmp    ecx,0x3
    e5b3:	jle    e5d6 <c_run_7.isra.0+0xc6>
    e5b5:	mov    esi,0x4
    e5ba:	nop    WORD PTR [rax+rax*1+0x0]
    e5c0:	vmovupd ymm0,YMMWORD PTR [rax+rsi*8]
    e5c5:	vmulpd ymm0,ymm0,YMMWORD PTR [rdx+rsi*8]
    e5ca:	add    rsi,0x4
    e5ce:	vaddpd ymm1,ymm1,ymm0
    e5d2:	cmp    ecx,esi
    e5d4:	jge    e5c0 <c_run_7.isra.0+0xb0>
    e5d6:	vmovapd xmm0,xmm1
    e5da:	vextractf64x2 xmm1,ymm1,0x1
    e5e1:	mov    r14d,r12d
    e5e4:	mov    esi,r11d
    e5e7:	vaddpd xmm0,xmm0,xmm1
    e5eb:	vunpckhpd xmm1,xmm0,xmm0
    e5ef:	vaddsd xmm0,xmm0,xmm1
    e5f3:	cmp    r14d,0x3
    e5f7:	je     e66f <c_run_7.isra.0+0x15f>
    e5f9:	cmp    r14d,0x2
    e5fd:	je     e6a0 <c_run_7.isra.0+0x190>
    e603:	cmp    r14d,0x1
    e607:	jne    e620 <c_run_7.isra.0+0x110>
    e609:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    e60e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    e613:	vaddsd xmm0,xmm0,xmm1
    e617:	nop    WORD PTR [rax+rax*1+0x0]
    e620:	vmovsd QWORD PTR [rdi],xmm0
    e624:	add    rdi,0x8
    e628:	add    rax,r9
    e62b:	cmp    r10,rdi
    e62e:	jne    e5a0 <c_run_7.isra.0+0x90>
    e634:	mov    r14d,DWORD PTR [rsp-0x4]
    e639:	mov    rax,QWORD PTR [rsp-0x10]
    e63e:	mov    rdi,QWORD PTR [rbp+0x18]
    e642:	mov    rsi,QWORD PTR [rbp+0x28]
    e646:	inc    r14d
    e649:	cmp    DWORD PTR [rsp-0x8],r14d
    e64e:	je     e6c3 <c_run_7.isra.0+0x1b3>
    e650:	mov    rdi,QWORD PTR [rbp+0x18]
    e654:	mov    rsi,QWORD PTR [rbp+0x28]
    e658:	jmp    e590 <c_run_7.isra.0+0x80>
    e65d:	nop    DWORD PTR [rax]
    e660:	mov    r14d,ebx
    e663:	xor    esi,esi
    e665:	vxorpd xmm0,xmm0,xmm0
    e669:	cmp    r14d,0x3
    e66d:	jne    e5f9 <c_run_7.isra.0+0xe9>
    e66f:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    e674:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    e679:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x8]
    e67f:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x8]
    e685:	vaddsd xmm1,xmm1,xmm2
    e689:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x10]
    e68f:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x10]
    e695:	vaddsd xmm1,xmm1,xmm2
    e699:	vaddsd xmm0,xmm0,xmm1
    e69d:	jmp    e620 <c_run_7.isra.0+0x110>
    e69f:	nop
    e6a0:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    e6a5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    e6aa:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x8]
    e6b0:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x8]
    e6b6:	vaddsd xmm1,xmm1,xmm2
    e6ba:	vaddsd xmm0,xmm0,xmm1
    e6be:	jmp    e620 <c_run_7.isra.0+0x110>
    e6c3:	vzeroupper
    e6c6:	lea    rsp,[rbp-0x28]
    e6ca:	pop    rbx
    e6cb:	pop    r12
    e6cd:	pop    r13
    e6cf:	pop    r14
    e6d1:	pop    r15
    e6d3:	pop    rbp
    e6d4:	ret
    e6d5:	mov    rcx,QWORD PTR [rsp-0x10]
    e6da:	mov    rsi,QWORD PTR [rbp+0x18]
    e6de:	mov    rdi,QWORD PTR [rbp+0x28]
    e6e2:	mov    r9d,DWORD PTR [rsp-0x8]
    e6e7:	lea    r10d,[rax+0x1]
    e6eb:	cmp    r9d,r10d
    e6ee:	je     e6c6 <c_run_7.isra.0+0x1b6>
    e6f0:	add    eax,0x2
    e6f3:	cmp    r9d,eax
    e6f6:	je     e6c6 <c_run_7.isra.0+0x1b6>
    e6f8:	jmp    e6e7 <c_run_7.isra.0+0x1d7>
    e6fa:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_8.isra.0>:
    d9d0:	push   rbp
    d9d1:	mov    r11d,edi
    d9d4:	mov    rbp,rsp
    d9d7:	push   r15
    d9d9:	push   r14
    d9db:	push   r13
    d9dd:	push   r12
    d9df:	push   rbx
    d9e0:	and    rsp,0xffffffffffffffe0
    d9e4:	sub    rsp,0x40
    d9e8:	mov    rdi,QWORD PTR [rbp+0x20]
    d9ec:	mov    QWORD PTR [rsp+0x38],r8
    d9f1:	test   edx,edx
    d9f3:	je     db62 <c_run_8.isra.0+0x192>
    d9f9:	mov    eax,esi
    d9fb:	mov    DWORD PTR [rsp+0x1c],edx
    d9ff:	mov    DWORD PTR [rsp+0x18],r11d
    da04:	mov    r10,r9
    da07:	mov    r15,rax
    da0a:	xor    r12d,r12d
    da0d:	shl    rax,0x3
    da11:	lea    ebx,[r15-0x4]
    da15:	mov    QWORD PTR [rsp+0x20],rax
    da1a:	mov    eax,r11d
    da1d:	lea    r14,[r9+rax*8]
    da21:	mov    eax,ebx
    da23:	and    eax,0xfffffffc
    da26:	add    eax,0x4
    da29:	mov    r13,r14
    da2c:	mov    r14,rcx
    da2f:	mov    edx,r15d
    da32:	sub    edx,eax
    da34:	mov    DWORD PTR [rsp+0x2c],eax
    da38:	mov    DWORD PTR [rsp+0x28],edx
    da3c:	nop    DWORD PTR [rax+0x0]
    da40:	mov    rax,QWORD PTR [rsp+0x38]
    da45:	mov    rdx,QWORD PTR [rbp+0x10]
    da49:	mov    rsi,QWORD PTR [rbp+0x18]
    da4d:	mov    rcx,QWORD PTR [rbp+0x28]
    da51:	mov    rdx,QWORD PTR [rsp+0x20]
    da56:	xor    esi,esi
    da58:	mov    QWORD PTR [rsp+0x30],r10
    da5d:	call   2bd0 <memset@plt>
    da62:	mov    r10,QWORD PTR [rsp+0x30]
    da67:	mov    rdi,rax
    da6a:	mov    eax,DWORD PTR [rsp+0x18]
    da6e:	test   eax,eax
    da70:	je     db43 <c_run_8.isra.0+0x173>
    da76:	mov    rax,r10
    da79:	xor    edx,edx
    da7b:	vxorpd xmm3,xmm3,xmm3
    da7f:	jmp    dab0 <c_run_8.isra.0+0xe0>
    da81:	nop    WORD PTR [rax+rax*1+0x0]
    da8a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    da95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    daa0:	add    rax,0x8
    daa4:	add    edx,r15d
    daa7:	cmp    r13,rax
    daaa:	je     db40 <c_run_8.isra.0+0x170>
    dab0:	vmovsd xmm1,QWORD PTR [rax]
    dab4:	vcomisd xmm1,xmm3
    dab8:	je     daa0 <c_run_8.isra.0+0xd0>
    daba:	mov    ecx,edx
    dabc:	lea    rsi,[r14+rcx*8]
    dac0:	test   ebx,ebx
    dac2:	js     db80 <c_run_8.isra.0+0x1b0>
    dac8:	vbroadcastsd ymm2,xmm1
    dacd:	xor    ecx,ecx
    dacf:	nop    WORD PTR [rax+rax*1+0x0]
    dad5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    dae0:	vmulpd ymm0,ymm2,YMMWORD PTR [rsi+rcx*8]
    dae5:	vaddpd ymm0,ymm0,YMMWORD PTR [rdi+rcx*8]
    daea:	vmovupd YMMWORD PTR [rdi+rcx*8],ymm0
    daef:	add    rcx,0x4
    daf3:	cmp    ebx,ecx
    daf5:	jge    dae0 <c_run_8.isra.0+0x110>
    daf7:	mov    r8d,DWORD PTR [rsp+0x28]
    dafc:	mov    ecx,DWORD PTR [rsp+0x2c]
    db00:	cmp    r8d,0x3
    db04:	je     db8f <c_run_8.isra.0+0x1bf>
    db0a:	cmp    r8d,0x2
    db0e:	je     dbd0 <c_run_8.isra.0+0x200>
    db14:	cmp    r8d,0x1
    db18:	jne    daa0 <c_run_8.isra.0+0xd0>
    db1a:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    db1f:	add    rax,0x8
    db23:	add    edx,r15d
    db26:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*8]
    db2b:	vmovsd QWORD PTR [rdi+rcx*8],xmm1
    db30:	cmp    r13,rax
    db33:	jne    dab0 <c_run_8.isra.0+0xe0>
    db39:	nop    DWORD PTR [rax+0x0]
    db40:	vzeroupper
    db43:	mov    rax,QWORD PTR [rsp+0x38]
    db48:	mov    rdx,QWORD PTR [rbp+0x10]
    db4c:	mov    rsi,QWORD PTR [rbp+0x18]
    db50:	mov    rcx,QWORD PTR [rbp+0x28]
    db54:	inc    r12d
    db57:	cmp    r12d,DWORD PTR [rsp+0x1c]
    db5c:	jne    da40 <c_run_8.isra.0+0x70>
    db62:	lea    rsp,[rbp-0x28]
    db66:	pop    rbx
    db67:	pop    r12
    db69:	pop    r13
    db6b:	pop    r14
    db6d:	pop    r15
    db6f:	pop    rbp
    db70:	ret
    db71:	nop    DWORD PTR [rax+0x0]
    db75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    db80:	mov    r8d,r15d
    db83:	xor    ecx,ecx
    db85:	cmp    r8d,0x3
    db89:	jne    db0a <c_run_8.isra.0+0x13a>
    db8f:	shl    rcx,0x3
    db93:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1]
    db98:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1]
    db9d:	vmovsd QWORD PTR [rdi+rcx*1],xmm0
    dba2:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1+0x8]
    dba8:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1+0x8]
    dbae:	vmovsd QWORD PTR [rdi+rcx*1+0x8],xmm0
    dbb4:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*1+0x10]
    dbba:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*1+0x10]
    dbc0:	vmovsd QWORD PTR [rdi+rcx*1+0x10],xmm1
    dbc6:	jmp    daa0 <c_run_8.isra.0+0xd0>
    dbcb:	nop    DWORD PTR [rax+rax*1+0x0]
    dbd0:	shl    rcx,0x3
    dbd4:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1]
    dbd9:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1]
    dbde:	vmovsd QWORD PTR [rdi+rcx*1],xmm0
    dbe3:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*1+0x8]
    dbe9:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*1+0x8]
    dbef:	vmovsd QWORD PTR [rdi+rcx*1+0x8],xmm1
    dbf5:	jmp    daa0 <c_run_8.isra.0+0xd0>
    dbfa:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_9.isra.0>:
    e220:	push   rbp
    e221:	mov    rbp,rsp
    e224:	push   r15
    e226:	push   r14
    e228:	push   r13
    e22a:	push   r12
    e22c:	push   rbx
    e22d:	and    rsp,0xffffffffffffffe0
    e231:	mov    DWORD PTR [rsp-0x10],esi
    e235:	test   esi,esi
    e237:	je     e4df <c_run_9.isra.0+0x2bf>
    e23d:	mov    ebx,edi
    e23f:	mov    r15,rcx
    e242:	mov    rax,QWORD PTR [rbp+0x10]
    e246:	mov    rdi,QWORD PTR [rbp+0x18]
    e24a:	mov    rcx,QWORD PTR [rbp+0x20]
    e24e:	mov    r11,rdx
    e251:	test   ebx,ebx
    e253:	je     e4e5 <c_run_9.isra.0+0x2c5>
    e259:	lea    eax,[rbx-0x8]
    e25c:	lea    edx,[rbx-0x4]
    e25f:	mov    r10d,ebx
    e262:	mov    ecx,0x4
    e267:	and    eax,0xfffffffc
    e26a:	mov    QWORD PTR [rsp-0x28],r15
    e26f:	vxorpd xmm0,xmm0,xmm0
    e273:	add    eax,0x8
    e276:	shl    r10,0x3
    e27a:	cmp    edx,0x3
    e27d:	lea    r12,[r8+r10*1]
    e281:	cmovle eax,ecx
    e284:	xor    r13d,r13d
    e287:	mov    r14d,eax
    e28a:	lea    ecx,[rax+0x1]
    e28d:	mov    edi,ebx
    e28f:	sub    edi,eax
    e291:	shl    r14,0x3
    e295:	vmovq  xmm8,rcx
    e29a:	lea    rcx,[r9+r14*1]
    e29e:	add    eax,0x2
    e2a1:	mov    QWORD PTR [rsp-0x8],rcx
    e2a6:	vmovq  xmm6,rax
    e2ab:	nop    DWORD PTR [rax+rax*1+0x0]
    e2b0:	mov    DWORD PTR [rsp-0xc],r13d
    e2b5:	mov    QWORD PTR [rsp-0x18],r11
    e2ba:	mov    QWORD PTR [rsp-0x20],r8
    e2bf:	mov    rcx,r8
    e2c2:	mov    rax,r11
    e2c5:	vxorpd xmm2,xmm2,xmm2
    e2c9:	vmovq  r8,xmm8
    e2ce:	xchg   ax,ax
    e2d0:	vmovsd xmm3,QWORD PTR [rcx]
    e2d4:	mov    rsi,rax
    e2d7:	test   edx,edx
    e2d9:	js     e370 <c_run_9.isra.0+0x150>
    e2df:	vmovupd ymm4,YMMWORD PTR [r9]
    e2e4:	vmulpd ymm1,ymm4,YMMWORD PTR [rax]
    e2e8:	cmp    edx,0x3
    e2eb:	jle    e317 <c_run_9.isra.0+0xf7>
    e2ed:	mov    esi,0x4
    e2f2:	nop    DWORD PTR [rax]
    e2f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e300:	vmovupd ymm7,YMMWORD PTR [rax+rsi*8]
    e305:	vmulpd ymm5,ymm7,YMMWORD PTR [r9+rsi*8]
    e30b:	add    rsi,0x4
    e30f:	vaddpd ymm1,ymm1,ymm5
    e313:	cmp    edx,esi
    e315:	jge    e300 <c_run_9.isra.0+0xe0>
    e317:	vmovapd xmm5,xmm1
    e31b:	vextractf64x2 xmm1,ymm1,0x1
    e322:	vaddpd xmm5,xmm5,xmm1
    e326:	vunpckhpd xmm1,xmm5,xmm5
    e32a:	vaddsd xmm7,xmm5,xmm1
    e32e:	cmp    edi,0x3
    e331:	je     e400 <c_run_9.isra.0+0x1e0>
    e337:	cmp    edi,0x2
    e33a:	je     e470 <c_run_9.isra.0+0x250>
    e340:	cmp    edi,0x1
    e343:	je     e4bf <c_run_9.isra.0+0x29f>
    e349:	vmulsd xmm3,xmm7,xmm3
    e34d:	add    rcx,0x8
    e351:	vaddsd xmm2,xmm2,xmm3
    e355:	cmp    rcx,r12
    e358:	je     e3ae <c_run_9.isra.0+0x18e>
    e35a:	vmovsd xmm3,QWORD PTR [rcx]
    e35e:	add    rax,r10
    e361:	jmp    e2e4 <c_run_9.isra.0+0xc4>
    e366:	cs nop WORD PTR [rax+rax*1+0x0]
    e370:	cmp    ebx,0x3
    e373:	je     e450 <c_run_9.isra.0+0x230>
    e379:	cmp    ebx,0x2
    e37c:	je     e4b0 <c_run_9.isra.0+0x290>
    e382:	mov    r11,r9
    e385:	vxorpd xmm7,xmm7,xmm7
    e389:	vmovsd xmm1,QWORD PTR [rsi]
    e38d:	vmulsd xmm1,xmm1,QWORD PTR [r11]
    e392:	vaddsd xmm4,xmm1,xmm7
    e396:	vmulsd xmm3,xmm4,xmm3
    e39a:	add    rcx,0x8
    e39e:	add    rax,r10
    e3a1:	vaddsd xmm2,xmm2,xmm3
    e3a5:	cmp    r12,rcx
    e3a8:	jne    e2d0 <c_run_9.isra.0+0xb0>
    e3ae:	mov    r13d,DWORD PTR [rsp-0xc]
    e3b3:	mov    r11,QWORD PTR [rsp-0x18]
    e3b8:	mov    r8,QWORD PTR [rsp-0x20]
    e3bd:	mov    rax,QWORD PTR [rsp-0x28]
    e3c2:	mov    rcx,QWORD PTR [rbp+0x10]
    e3c6:	mov    rsi,QWORD PTR [rbp+0x18]
    e3ca:	mov    r15,QWORD PTR [rbp+0x20]
    e3ce:	vaddsd xmm0,xmm0,xmm2
    e3d2:	inc    r13d
    e3d5:	cmp    DWORD PTR [rsp-0x10],r13d
    e3da:	je     e4cd <c_run_9.isra.0+0x2ad>
    e3e0:	mov    rcx,QWORD PTR [rbp+0x10]
    e3e4:	mov    rsi,QWORD PTR [rbp+0x18]
    e3e8:	mov    r15,QWORD PTR [rbp+0x20]
    e3ec:	jmp    e2b0 <c_run_9.isra.0+0x90>
    e3f1:	nop    DWORD PTR [rax+0x0]
    e3f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e400:	mov    r15,QWORD PTR [rsp-0x8]
    e405:	vmovq  r11,xmm6
    e40a:	lea    r13,[r8*8+0x0]
    e412:	lea    rsi,[rax+r14*1]
    e416:	lea    r11,[r11*8+0x0]
    e41e:	vmovsd xmm1,QWORD PTR [rax+r13*1]
    e424:	vmulsd xmm1,xmm1,QWORD PTR [r9+r13*1]
    e42a:	vmovsd xmm4,QWORD PTR [rsi]
    e42e:	vmulsd xmm4,xmm4,QWORD PTR [r15]
    e433:	vaddsd xmm1,xmm1,xmm4
    e437:	vmovsd xmm4,QWORD PTR [rax+r11*1]
    e43d:	vmulsd xmm4,xmm4,QWORD PTR [r9+r11*1]
    e443:	vaddsd xmm1,xmm1,xmm4
    e447:	vaddsd xmm4,xmm1,xmm7
    e44b:	jmp    e396 <c_run_9.isra.0+0x176>
    e450:	mov    r15,r9
    e453:	mov    r13d,0x8
    e459:	mov    r11d,0x10
    e45f:	vxorpd xmm7,xmm7,xmm7
    e463:	jmp    e41e <c_run_9.isra.0+0x1fe>
    e465:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e470:	mov    r13,QWORD PTR [rsp-0x8]
    e475:	lea    rsi,[rax+r14*1]
    e479:	lea    r11,[r8*8+0x0]
    e481:	vmovsd xmm1,QWORD PTR [rax+r11*1]
    e487:	vmulsd xmm1,xmm1,QWORD PTR [r9+r11*1]
    e48d:	vmovsd xmm4,QWORD PTR [rsi]
    e491:	vmulsd xmm4,xmm4,QWORD PTR [r13+0x0]
    e497:	vaddsd xmm1,xmm1,xmm4
    e49b:	vaddsd xmm4,xmm1,xmm7
    e49f:	jmp    e396 <c_run_9.isra.0+0x176>
    e4a4:	nop
    e4a5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    e4b0:	mov    r13,r9
    e4b3:	mov    r11d,0x8
    e4b9:	vxorpd xmm7,xmm7,xmm7
    e4bd:	jmp    e481 <c_run_9.isra.0+0x261>
    e4bf:	mov    r11,QWORD PTR [rsp-0x8]
    e4c4:	lea    rsi,[rax+r14*1]
    e4c8:	jmp    e389 <c_run_9.isra.0+0x169>
    e4cd:	vzeroupper
    e4d0:	lea    rsp,[rbp-0x28]
    e4d4:	pop    rbx
    e4d5:	pop    r12
    e4d7:	pop    r13
    e4d9:	pop    r14
    e4db:	pop    r15
    e4dd:	pop    rbp
    e4de:	ret
    e4df:	vxorpd xmm0,xmm0,xmm0
    e4e3:	jmp    e4d0 <c_run_9.isra.0+0x2b0>
    e4e5:	mov    rax,QWORD PTR [rbp+0x10]
    e4e9:	mov    rdx,QWORD PTR [rbp+0x18]
    e4ed:	mov    rcx,QWORD PTR [rbp+0x20]
    e4f1:	mov    esi,DWORD PTR [rsp-0x10]
    e4f5:	lea    edi,[rbx+0x1]
    e4f8:	cmp    esi,edi
    e4fa:	je     e4df <c_run_9.isra.0+0x2bf>
    e4fc:	add    ebx,0x2
    e4ff:	cmp    esi,ebx
    e501:	je     e4df <c_run_9.isra.0+0x2bf>
    e503:	jmp    e4f5 <c_run_9.isra.0+0x2d5>
    e505:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<memcpy@plt>:
    30f0:	jmp    QWORD PTR [rip+0x431da]        # 462d0 <memcpy@GLIBC_2.14>
    30f6:	push   0x5a
    30fb:	jmp    2b40 <_init+0x28>


<memset@plt>:
    2bd0:	jmp    QWORD PTR [rip+0x4346a]        # 46040 <memset@GLIBC_2.2.5>
    2bd6:	push   0x8
    2bdb:	jmp    2b40 <_init+0x28>


<mj__matrices__copyrows>:
    5630:	movsxd rax,DWORD PTR [r9]
    5633:	movsxd r9,DWORD PTR [r9+0x4]
    5637:	cmp    eax,r9d
    563a:	jg     5850 <mj__matrices__copyrows+0x220>
    5640:	push   rbp
    5641:	mov    r10,rsi
    5644:	mov    r11,rdx
    5647:	lea    rsi,[rax-0x1]
    564b:	mov    rbp,rsp
    564e:	push   r15
    5650:	push   r14
    5652:	push   r13
    5654:	push   r12
    5656:	push   rbx
    5657:	mov    r12,rdi
    565a:	and    rsp,0xffffffffffffffc0
    565e:	sub    rsp,0x8
    5662:	movsxd r13,DWORD PTR [rcx+0x8]
    5666:	movsxd rbx,DWORD PTR [rcx]
    5669:	mov    ecx,DWORD PTR [rcx+0xc]
    566c:	movsxd r14,DWORD PTR [r10+0x8]
    5670:	movsxd r15,DWORD PTR [r10+0xc]
    5674:	vmovq  xmm5,rbx
    5679:	movsxd rbx,DWORD PTR [r10]
    567c:	movsxd r10,ecx
    567f:	mov    QWORD PTR [rsp-0x30],r13
    5684:	sub    r10,r13
    5687:	mov    rdx,r15
    568a:	sub    rdx,r14
    568d:	cmp    r13d,ecx
    5690:	lea    r10,[r10*8+0x8]
    5698:	mov    ecx,0x0
    569d:	mov    QWORD PTR [rsp-0x48],r15
    56a2:	lea    rdx,[rdx*8+0x8]
    56aa:	cmovle rcx,r10
    56ae:	neg    rax
    56b1:	mov    DWORD PTR [rsp+0x4],r14d
    56b6:	mov    QWORD PTR [rsp-0x38],r14
    56bb:	mov    QWORD PTR [rsp-0x40],rcx
    56c0:	lea    rax,[r8+rax*4]
    56c4:	vmovq  xmm4,rbx
    56c9:	mov    rbx,r15
    56cc:	sub    r15,r14
    56cf:	vmovq  xmm3,rax
    56d4:	shr    rcx,0x3
    56d8:	mov    QWORD PTR [rsp-0x18],rcx
    56dd:	lea    rcx,[r15-0x7]
    56e1:	lea    rax,[r15+0x1]
    56e5:	mov    QWORD PTR [rsp-0x20],r15
    56ea:	mov    QWORD PTR [rsp-0x8],rax
    56ef:	sub    r14,r13
    56f2:	mov    r13d,ebx
    56f5:	shr    rcx,0x3
    56f9:	shr    rdx,0x3
    56fd:	inc    rcx
    5700:	mov    QWORD PTR [rsp-0x10],rdx
    5705:	vmovdqa xmm6,XMMWORD PTR [rip+0x32563]        # 37c70 <system__secondary_stack__invalid_memory_size+0xa8>
    570d:	mov    rdx,r11
    5710:	lea    rax,[rcx*8+0x0]
    5718:	mov    r11,r14
    571b:	mov    rbx,rdx
    571e:	mov    QWORD PTR [rsp-0x28],rax
    5723:	xchg   ax,ax
    5725:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5730:	inc    rsi
    5733:	cmp    DWORD PTR [rsp+0x4],r13d
    5738:	jg     5827 <mj__matrices__copyrows+0x1f7>
    573e:	vmovq  rax,xmm3
    5743:	vmovq  rdx,xmm4
    5748:	movsxd rax,DWORD PTR [rax+rsi*4]
    574c:	mov    rdi,rax
    574f:	sub    rdi,rdx
    5752:	vmovq  rdx,xmm5
    5757:	imul   rdi,QWORD PTR [rsp-0x10]
    575d:	sub    rax,rdx
    5760:	mov    rdx,QWORD PTR [rsp-0x18]
    5765:	imul   rdx,rax
    5769:	lea    r14,[rdi*8+0x0]
    5771:	lea    r10,[r12+r14*1]
    5775:	lea    r8,[rdx+r11*1]
    5779:	lea    rdx,[rdx+r11*1+0x1]
    577e:	lea    r15,[rbx+rdx*8]
    5782:	mov    rdx,r10
    5785:	sub    rdx,r15
    5788:	cmp    rdx,0x30
    578c:	jbe    5860 <mj__matrices__copyrows+0x230>
    5792:	cmp    QWORD PTR [rsp-0x20],0x6
    5798:	jbe    58b7 <mj__matrices__copyrows+0x287>
    579e:	lea    r14,[rbx+r8*8]
    57a2:	xor    eax,eax
    57a4:	xor    edx,edx
    57a6:	nop    DWORD PTR [rax+0x0]
    57aa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    57b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    57c0:	vmovupd zmm0,ZMMWORD PTR [r14+rax*1]
    57c7:	inc    rdx
    57ca:	vmovupd ZMMWORD PTR [r10+rax*1],zmm0
    57d1:	add    rax,0x40
    57d5:	cmp    rdx,rcx
    57d8:	jb     57c0 <mj__matrices__copyrows+0x190>
    57da:	mov    rax,QWORD PTR [rsp-0x28]
    57df:	mov    r10,rax
    57e2:	cmp    QWORD PTR [rsp-0x8],rax
    57e7:	je     5827 <mj__matrices__copyrows+0x1f7>
    57e9:	mov    rax,QWORD PTR [rsp-0x8]
    57ee:	mov    r14d,0x8
    57f4:	add    rdi,r10
    57f7:	xor    edx,edx
    57f9:	xor    r15d,r15d
    57fc:	sub    rax,r10
    57ff:	cmp    r14,rax
    5802:	sbb    r15,rdx
    5805:	cmovb  rax,r14
    5809:	add    r8,r10
    580c:	vpbroadcastw xmm0,eax
    5812:	vpcmpnleuw k1,xmm0,xmm6
    5819:	vmovupd zmm0{k1}{z},ZMMWORD PTR [rbx+r8*8]
    5820:	vmovupd ZMMWORD PTR [r12+rdi*8]{k1},zmm0
    5827:	cmp    r9,rsi
    582a:	jne    5730 <mj__matrices__copyrows+0x100>
    5830:	vzeroupper
    5833:	lea    rsp,[rbp-0x28]
    5837:	pop    rbx
    5838:	pop    r12
    583a:	pop    r13
    583c:	pop    r14
    583e:	pop    r15
    5840:	pop    rbp
    5841:	ret
    5842:	nop    DWORD PTR [rax]
    5845:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5850:	ret
    5851:	nop    DWORD PTR [rax+0x0]
    5855:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5860:	imul   rax,QWORD PTR [rsp-0x40]
    5866:	mov    rdx,QWORD PTR [rsp-0x30]
    586b:	mov    r15,QWORD PTR [rsp-0x38]
    5870:	mov    r8,QWORD PTR [rsp-0x48]
    5875:	neg    rdx
    5878:	lea    rdi,[rax+rdx*8]
    587c:	mov    rax,r15
    587f:	neg    rax
    5882:	add    rdi,rbx
    5885:	lea    rdx,[r14+rax*8]
    5889:	lea    rax,[r15-0x1]
    588d:	add    rdx,r12
    5890:	nop    DWORD PTR [rax+rax*1+0x0]
    5895:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    58a0:	inc    rax
    58a3:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    58a8:	vmovsd QWORD PTR [rdx+rax*8],xmm0
    58ad:	cmp    r8,rax
    58b0:	jne    58a0 <mj__matrices__copyrows+0x270>
    58b2:	jmp    5827 <mj__matrices__copyrows+0x1f7>
    58b7:	xor    r10d,r10d
    58ba:	jmp    57e9 <mj__matrices__copyrows+0x1b9>
    58bf:	nop


<mj__matrices__matt_component>:
    4f70:	push   rbp
    4f71:	vmovq  xmm4,rdi
    4f76:	mov    rbp,rsp
    4f79:	push   r15
    4f7b:	push   r14
    4f7d:	push   r13
    4f7f:	push   r12
    4f81:	push   rbx
    4f82:	mov    r14,rdx
    4f85:	and    rsp,0xffffffffffffffe0
    4f89:	mov    eax,DWORD PTR [rcx]
    4f8b:	movsxd r15,DWORD PTR [rsi+0x8]
    4f8f:	mov    DWORD PTR [rsp-0x4],r8d
    4f94:	movsxd rdi,DWORD PTR [rsi+0xc]
    4f98:	mov    r8d,DWORD PTR [rsi]
    4f9b:	movsxd r10,DWORD PTR [rcx+0xc]
    4f9f:	mov    r12d,DWORD PTR [rcx+0x8]
    4fa3:	mov    DWORD PTR [rsp-0x8],eax
    4fa7:	lea    rax,[r15+0x2]
    4fab:	mov    r11,rdi
    4fae:	mov    rbx,r15
    4fb1:	mov    DWORD PTR [rsp-0xc],r8d
    4fb6:	mov    QWORD PTR [rsp-0x18],rax
    4fbb:	cmp    rax,rdi
    4fbe:	jge    5370 <mj__matrices__matt_component+0x400>
    4fc4:	movsxd rsi,DWORD PTR [rsp-0x8]
    4fc9:	movsxd r13,r12d
    4fcc:	movsxd rax,r10d
    4fcf:	xor    ecx,ecx
    4fd1:	sub    rax,r13
    4fd4:	cmp    r10d,r12d
    4fd7:	lea    rdx,[rax*8+0x8]
    4fdf:	movsxd rax,r9d
    4fe2:	cmovl  rdx,rcx
    4fe6:	shr    rdx,0x3
    4fea:	sub    rax,rsi
    4fed:	movsxd rsi,r8d
    4ff0:	imul   rax,rdx
    4ff4:	mov    rdx,rdi
    4ff7:	sub    rdx,r15
    4ffa:	lea    rdx,[rdx*8+0x8]
    5002:	sub    rax,r13
    5005:	cmp    edi,r15d
    5008:	cmovge rcx,rdx
    500c:	movsxd rdx,DWORD PTR [rsp-0x4]
    5011:	shr    rcx,0x3
    5015:	sub    rdx,rsi
    5018:	vmovq  rsi,xmm4
    501d:	imul   rdx,rcx
    5021:	sub    rdx,r15
    5024:	vmovupd ymm1,YMMWORD PTR [rsi+rdx*8]
    5029:	vmulpd ymm1,ymm1,YMMWORD PTR [r14+rax*8]
    502f:	cmp    edi,r15d
    5032:	jl     5340 <mj__matrices__matt_component+0x3d0>
    5038:	mov    eax,r11d
    503b:	sub    eax,ebx
    503d:	inc    eax
    503f:	sar    eax,0x2
    5042:	lea    esi,[rax-0x1]
    5045:	mov    DWORD PTR [rsp-0x10],eax
    5049:	mov    r8d,eax
    504c:	mov    ecx,esi
    504e:	shr    ecx,0x1f
    5051:	add    esi,ecx
    5053:	sar    esi,1
    5055:	lea    ecx,[rsi-0x1]
    5058:	vmovd  xmm7,ecx
    505c:	je     5213 <mj__matrices__matt_component+0x2a3>
    5062:	movsxd rcx,DWORD PTR [rsp-0x8]
    5067:	movsxd r13,r12d
    506a:	movsxd rax,r10d
    506d:	xor    edx,edx
    506f:	sub    rax,r13
    5072:	lea    rax,[rax*8+0x8]
    507a:	vmovq  xmm3,rcx
    507f:	movsxd rcx,DWORD PTR [rsp-0xc]
    5084:	vmovq  xmm2,rcx
    5089:	mov    rcx,rdi
    508c:	sub    rcx,r15
    508f:	cmp    r10d,r12d
    5092:	cmovge rdx,rax
    5096:	lea    rcx,[rcx*8+0x8]
    509e:	movsxd rax,r9d
    50a1:	mov    QWORD PTR [rsp-0x30],rax
    50a6:	mov    rax,rcx
    50a9:	shr    rax,0x3
    50ad:	mov    QWORD PTR [rsp-0x38],rax
    50b2:	movsxd rax,DWORD PTR [rsp-0x4]
    50b7:	shr    rdx,0x3
    50bb:	mov    QWORD PTR [rsp-0x28],rdx
    50c0:	mov    QWORD PTR [rsp-0x20],rax
    50c5:	cmp    r8d,0x6
    50c9:	jle    560c <mj__matrices__matt_component+0x69c>
    50cf:	vmovq  r8,xmm3
    50d4:	movsxd rax,r9d
    50d7:	sub    esi,0x3
    50da:	sub    rax,r8
    50dd:	vmovq  r8,xmm2
    50e2:	or     esi,0x1
    50e5:	imul   rax,rdx
    50e9:	sub    rax,r13
    50ec:	lea    rdx,[r14+rax*8+0x20]
    50f1:	mov    rax,QWORD PTR [rsp-0x20]
    50f6:	sub    rax,r8
    50f9:	mov    r8d,DWORD PTR [rsp-0x4]
    50fe:	imul   rax,rcx
    5102:	lea    rcx,[r15*8+0x0]
    510a:	sub    rax,rcx
    510d:	vmovq  rcx,xmm4
    5112:	lea    rax,[rax+rcx*1+0x20]
    5117:	mov    ecx,0xffffffff
    511c:	nop    DWORD PTR [rax+0x0]
    5120:	vmovupd ymm0,YMMWORD PTR [rdx]
    5124:	vmulpd ymm0,ymm0,YMMWORD PTR [rax]
    5128:	add    ecx,0x2
    512b:	sub    rdx,0xffffffffffffff80
    512f:	sub    rax,0xffffffffffffff80
    5133:	vaddpd ymm1,ymm0,ymm1
    5137:	vmovupd ymm0,YMMWORD PTR [rdx-0x60]
    513c:	vmulpd ymm0,ymm0,YMMWORD PTR [rax-0x60]
    5141:	vaddpd ymm1,ymm1,ymm0
    5145:	vmovupd ymm0,YMMWORD PTR [rax-0x40]
    514a:	vmulpd ymm0,ymm0,YMMWORD PTR [rdx-0x40]
    514f:	vaddpd ymm1,ymm1,ymm0
    5153:	vmovupd ymm0,YMMWORD PTR [rax-0x20]
    5158:	vmulpd ymm0,ymm0,YMMWORD PTR [rdx-0x20]
    515d:	vaddpd ymm1,ymm1,ymm0
    5161:	cmp    ecx,esi
    5163:	jne    5120 <mj__matrices__matt_component+0x1b0>
    5165:	mov    DWORD PTR [rsp-0x4],r8d
    516a:	mov    rdx,QWORD PTR [rsp-0x30]
    516f:	vmovq  rcx,xmm3
    5174:	movsxd rax,esi
    5177:	vmovq  r8,xmm4
    517c:	inc    esi
    517e:	shl    rax,0x3
    5182:	sub    rdx,rcx
    5185:	imul   rdx,QWORD PTR [rsp-0x28]
    518b:	mov    rcx,QWORD PTR [rsp-0x20]
    5190:	sub    rdx,r13
    5193:	lea    r13,[rax+rdx*1+0xc]
    5198:	mov    QWORD PTR [rsp-0x28],rdx
    519d:	vmovq  rdx,xmm2
    51a2:	sub    rcx,rdx
    51a5:	imul   rcx,QWORD PTR [rsp-0x38]
    51ab:	vmovupd ymm2,YMMWORD PTR [r14+r13*8+0x20]
    51b2:	sub    rcx,r15
    51b5:	lea    rdx,[rax+rcx*1+0xc]
    51ba:	vmovupd ymm0,YMMWORD PTR [r8+rdx*8]
    51c0:	vmulpd ymm0,ymm0,YMMWORD PTR [r14+r13*8]
    51c6:	vmulpd ymm2,ymm2,YMMWORD PTR [r8+rdx*8+0x20]
    51cd:	vmovd  r8d,xmm7
    51d2:	vaddpd ymm0,ymm0,ymm1
    51d6:	vaddpd ymm1,ymm2,ymm0
    51da:	cmp    esi,r8d
    51dd:	je     5213 <mj__matrices__matt_component+0x2a3>
    51df:	mov    rdx,QWORD PTR [rsp-0x28]
    51e4:	vmovq  rsi,xmm4
    51e9:	lea    rdx,[rax+rdx*1+0x14]
    51ee:	lea    rax,[rax+rcx*1+0x14]
    51f3:	vmovupd ymm0,YMMWORD PTR [r14+rdx*8]
    51f9:	vmulpd ymm0,ymm0,YMMWORD PTR [rsi+rax*8]
    51fe:	vaddpd ymm0,ymm0,ymm1
    5202:	vmovupd ymm1,YMMWORD PTR [r14+rdx*8+0x20]
    5209:	vmulpd ymm1,ymm1,YMMWORD PTR [rsi+rax*8+0x20]
    520f:	vaddpd ymm1,ymm1,ymm0
    5213:	mov    rax,rdi
    5216:	sub    rax,r15
    5219:	inc    rax
    521c:	cmp    rax,0x7
    5220:	jle    522a <mj__matrices__matt_component+0x2ba>
    5222:	test   al,0x4
    5224:	je     53f0 <mj__matrices__matt_component+0x480>
    522a:	cmp    QWORD PTR [rsp-0x18],rdi
    522f:	jge    5616 <mj__matrices__matt_component+0x6a6>
    5235:	and    eax,0x3
    5238:	je     5340 <mj__matrices__matt_component+0x3d0>
    523e:	movsxd r11,r12d
    5241:	movsxd rcx,r10d
    5244:	movsxd rbx,DWORD PTR [rsp-0x8]
    5249:	xor    edx,edx
    524b:	sub    rcx,r11
    524e:	movsxd r8,DWORD PTR [rsp-0x4]
    5253:	movsxd r9,r9d
    5256:	lea    rcx,[rcx*8+0x8]
    525e:	shr    rcx,0x3
    5262:	cmp    r10d,r12d
    5265:	movsxd r10,DWORD PTR [rsp-0xc]
    526a:	cmovge rdx,rcx
    526e:	sub    rdi,r15
    5271:	sub    r9,rbx
    5274:	vmovq  rbx,xmm4
    5279:	lea    rsi,[rdi*8+0x8]
    5281:	imul   r9,rdx
    5285:	mov    rcx,rdi
    5288:	sub    rcx,r11
    528b:	shr    rsi,0x3
    528f:	sub    r8,r10
    5292:	mov    rdx,rdi
    5295:	sub    rdx,r15
    5298:	add    rcx,r9
    529b:	imul   r8,rsi
    529f:	vmovsd xmm3,QWORD PTR [r14+rcx*8]
    52a5:	add    rdx,r8
    52a8:	vmulsd xmm3,xmm3,QWORD PTR [rbx+rdx*8]
    52ad:	cmp    rax,0x2
    52b1:	je     54a0 <mj__matrices__matt_component+0x530>
    52b7:	cmp    rax,0x3
    52bb:	jne    5301 <mj__matrices__matt_component+0x391>
    52bd:	lea    rax,[rdi-0x2]
    52c1:	dec    rdi
    52c4:	mov    rdx,rax
    52c7:	sub    rdx,r11
    52ca:	sub    rax,r15
    52cd:	add    rdx,r9
    52d0:	add    rax,r8
    52d3:	vmovsd xmm0,QWORD PTR [r14+rdx*8]
    52d9:	mov    rdx,rdi
    52dc:	sub    rdx,r11
    52df:	sub    rdi,r15
    52e2:	vmulsd xmm0,xmm0,QWORD PTR [rbx+rax*8]
    52e7:	add    rdx,r9
    52ea:	lea    rax,[rdi+r8*1]
    52ee:	vmovsd xmm2,QWORD PTR [r14+rdx*8]
    52f4:	vmulsd xmm2,xmm2,QWORD PTR [rbx+rax*8]
    52f9:	vaddsd xmm0,xmm0,xmm2
    52fd:	vaddsd xmm3,xmm3,xmm0
    5301:	vextractf64x2 xmm4,ymm1,0x1
    5308:	vunpckhpd xmm2,xmm1,xmm1
    530c:	vaddsd xmm0,xmm1,xmm4
    5310:	valignq ymm1,ymm1,ymm1,0x3
    5317:	vaddsd xmm1,xmm2,xmm1
    531b:	vaddsd xmm0,xmm0,xmm1
    531f:	vaddsd xmm0,xmm0,xmm3
    5323:	vzeroupper
    5326:	lea    rsp,[rbp-0x28]
    532a:	pop    rbx
    532b:	pop    r12
    532d:	pop    r13
    532f:	pop    r14
    5331:	pop    r15
    5333:	pop    rbp
    5334:	ret
    5335:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5340:	vextractf64x2 xmm3,ymm1,0x1
    5347:	vunpckhpd xmm2,xmm1,xmm1
    534b:	vaddsd xmm0,xmm1,xmm3
    534f:	valignq ymm1,ymm1,ymm1,0x3
    5356:	vaddsd xmm2,xmm2,xmm1
    535a:	vaddsd xmm0,xmm0,xmm2
    535e:	vzeroupper
    5361:	lea    rsp,[rbp-0x28]
    5365:	pop    rbx
    5366:	pop    r12
    5368:	pop    r13
    536a:	pop    r14
    536c:	pop    r15
    536e:	pop    rbp
    536f:	ret
    5370:	cmp    edi,r15d
    5373:	jge    54d0 <mj__matrices__matt_component+0x560>
    5379:	movsxd r13,r12d
    537c:	cmp    r10d,r12d
    537f:	jl     53dc <mj__matrices__matt_component+0x46c>
    5381:	sub    r10,r13
    5384:	lea    rdx,[r10*8+0x8]
    538c:	cmp    r11d,ebx
    538f:	jl     53dc <mj__matrices__matt_component+0x46c>
    5391:	sub    rdi,r15
    5394:	movsxd r12,DWORD PTR [rsp-0x8]
    5399:	movsxd r10,DWORD PTR [rsp-0xc]
    539e:	lea    rax,[rdi+0x1]
    53a2:	mov    rcx,rax
    53a5:	sar    rcx,0x3f
    53a9:	shr    rcx,0x3e
    53ad:	lea    rsi,[rax*8+0x0]
    53b5:	add    rax,rcx
    53b8:	and    eax,0x3
    53bb:	sub    rax,rcx
    53be:	cmp    rax,0x2
    53c2:	je     55c3 <mj__matrices__matt_component+0x653>
    53c8:	cmp    rax,0x3
    53cc:	je     5523 <mj__matrices__matt_component+0x5b3>
    53d2:	cmp    rax,0x1
    53d6:	je     54d9 <mj__matrices__matt_component+0x569>
    53dc:	vxorpd xmm0,xmm0,xmm0
    53e0:	lea    rsp,[rbp-0x28]
    53e4:	pop    rbx
    53e5:	pop    r12
    53e7:	pop    r13
    53e9:	pop    r14
    53eb:	pop    r15
    53ed:	pop    rbp
    53ee:	ret
    53ef:	nop
    53f0:	mov    edx,DWORD PTR [rsp-0x10]
    53f4:	movsxd rsi,DWORD PTR [rsp-0x8]
    53f9:	movsxd r13,r12d
    53fc:	xor    ecx,ecx
    53fe:	lea    r8,[rdx*4+0x0]
    5406:	movsxd rdx,r10d
    5409:	sub    rdx,r13
    540c:	cmp    r10d,r12d
    540f:	lea    rdx,[rdx*8+0x8]
    5417:	cmovl  rdx,rcx
    541b:	movsxd rcx,r9d
    541e:	shr    rdx,0x3
    5422:	sub    rcx,rsi
    5425:	mov    rsi,0xfffffffffffffffc
    542c:	imul   rdx,rcx
    5430:	mov    rcx,rsi
    5433:	sub    rcx,r13
    5436:	sub    rsi,r15
    5439:	add    rdx,r8
    543c:	add    rcx,rdx
    543f:	movsxd rdx,DWORD PTR [rsp-0xc]
    5444:	mov    QWORD PTR [rsp-0x20],rcx
    5449:	mov    rcx,rdi
    544c:	sub    rcx,r15
    544f:	lea    rcx,[rcx*8+0x8]
    5457:	shr    rcx,0x3
    545b:	mov    QWORD PTR [rsp-0x28],rcx
    5460:	movsxd rcx,DWORD PTR [rsp-0x4]
    5465:	sub    rcx,rdx
    5468:	imul   rcx,QWORD PTR [rsp-0x28]
    546e:	add    rcx,r8
    5471:	add    rcx,rsi
    5474:	vmovq  rsi,xmm4
    5479:	vmovupd ymm0,YMMWORD PTR [rsi+rcx*8]
    547e:	mov    rcx,QWORD PTR [rsp-0x20]
    5483:	vmulpd ymm0,ymm0,YMMWORD PTR [r14+rcx*8]
    5489:	vaddpd ymm1,ymm1,ymm0
    548d:	cmp    QWORD PTR [rsp-0x18],rdi
    5492:	jl     5235 <mj__matrices__matt_component+0x2c5>
    5498:	jmp    5619 <mj__matrices__matt_component+0x6a9>
    549d:	nop    DWORD PTR [rax]
    54a0:	lea    rax,[rdi-0x1]
    54a4:	mov    rdx,rax
    54a7:	sub    rdx,r11
    54aa:	sub    rax,r15
    54ad:	add    rdx,r9
    54b0:	add    rax,r8
    54b3:	vmovsd xmm0,QWORD PTR [r14+rdx*8]
    54b9:	vmulsd xmm0,xmm0,QWORD PTR [rbx+rax*8]
    54be:	vaddsd xmm3,xmm3,xmm0
    54c2:	jmp    5301 <mj__matrices__matt_component+0x391>
    54c7:	nop    WORD PTR [rax+rax*1+0x0]
    54d0:	vxorpd xmm1,xmm1,xmm1
    54d4:	jmp    5038 <mj__matrices__matt_component+0xc8>
    54d9:	shr    rdx,0x3
    54dd:	vxorpd xmm1,xmm1,xmm1
    54e1:	movsxd rax,r9d
    54e4:	mov    rcx,rdi
    54e7:	sub    rcx,r13
    54ea:	sub    rdi,r15
    54ed:	sub    rax,r12
    54f0:	imul   rax,rdx
    54f4:	shr    rsi,0x3
    54f8:	add    rcx,rax
    54fb:	movsxd rax,DWORD PTR [rsp-0x4]
    5500:	vmovsd xmm0,QWORD PTR [r14+rcx*8]
    5506:	sub    rax,r10
    5509:	imul   rax,rsi
    550d:	add    rdi,rax
    5510:	vmovq  rax,xmm4
    5515:	vmulsd xmm0,xmm0,QWORD PTR [rax+rdi*8]
    551a:	vaddsd xmm0,xmm0,xmm1
    551e:	jmp    5361 <mj__matrices__matt_component+0x3f1>
    5523:	movsxd r8,DWORD PTR [rsp-0x4]
    5528:	movsxd r9,r9d
    552b:	lea    rax,[rdi-0x2]
    552f:	lea    rcx,[rdi-0x1]
    5533:	sub    r9,r12
    5536:	mov    rbx,rax
    5539:	sub    rbx,r13
    553c:	sub    rax,r15
    553f:	shr    rdx,0x3
    5543:	shr    rsi,0x3
    5547:	mov    r11,rdx
    554a:	sub    r8,r10
    554d:	mov    rdx,r9
    5550:	mov    r9,rax
    5553:	imul   rdx,r11
    5557:	mov    rax,r8
    555a:	imul   rax,rsi
    555e:	add    rbx,rdx
    5561:	vmovsd xmm0,QWORD PTR [r14+rbx*8]
    5567:	lea    rsi,[r9+rax*1]
    556b:	vmovq  rbx,xmm4
    5570:	vmulsd xmm0,xmm0,QWORD PTR [rbx+rsi*8]
    5575:	mov    rsi,rcx
    5578:	sub    rsi,r13
    557b:	sub    rcx,r15
    557e:	add    rsi,rdx
    5581:	add    rcx,rax
    5584:	vmovsd xmm1,QWORD PTR [r14+rsi*8]
    558a:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    558f:	vaddsd xmm0,xmm0,xmm1
    5593:	mov    rcx,rdi
    5596:	sub    rcx,r13
    5599:	sub    rdi,r15
    559c:	add    rax,rdi
    559f:	add    rdx,rcx
    55a2:	vmovq  rdi,xmm4
    55a7:	vmovsd xmm1,QWORD PTR [r14+rdx*8]
    55ad:	vmulsd xmm1,xmm1,QWORD PTR [rdi+rax*8]
    55b2:	vaddsd xmm0,xmm0,xmm1
    55b6:	vxorpd xmm1,xmm1,xmm1
    55ba:	vaddsd xmm0,xmm0,xmm1
    55be:	jmp    5361 <mj__matrices__matt_component+0x3f1>
    55c3:	movsxd rax,DWORD PTR [rsp-0x4]
    55c8:	movsxd r9,r9d
    55cb:	lea    rcx,[rdi-0x1]
    55cf:	vmovq  rbx,xmm4
    55d4:	sub    r9,r12
    55d7:	mov    r8,rcx
    55da:	sub    r8,r13
    55dd:	sub    rcx,r15
    55e0:	shr    rdx,0x3
    55e4:	shr    rsi,0x3
    55e8:	mov    r11,rdx
    55eb:	sub    rax,r10
    55ee:	mov    rdx,r9
    55f1:	imul   rdx,r11
    55f5:	imul   rax,rsi
    55f9:	add    r8,rdx
    55fc:	add    rcx,rax
    55ff:	vmovsd xmm0,QWORD PTR [r14+r8*8]
    5605:	vmulsd xmm0,xmm0,QWORD PTR [rbx+rcx*8]
    560a:	jmp    5593 <mj__matrices__matt_component+0x623>
    560c:	mov    esi,0xffffffff
    5611:	jmp    516a <mj__matrices__matt_component+0x1fa>
    5616:	movsxd r13,r12d
    5619:	cmp    r10d,r12d
    561c:	jge    5628 <mj__matrices__matt_component+0x6b8>
    561e:	xor    edx,edx
    5620:	vzeroupper
    5623:	jmp    5391 <mj__matrices__matt_component+0x421>
    5628:	vzeroupper
    562b:	jmp    5381 <mj__matrices__matt_component+0x411>


<mj__matrices__mulmatmat>:
    a1b0:	push   rbp
    a1b1:	mov    rbp,rsp
    a1b4:	push   r15
    a1b6:	push   r14
    a1b8:	push   r13
    a1ba:	push   r12
    a1bc:	push   rbx
    a1bd:	mov    r13,rsi
    a1c0:	mov    r12,rdi
    a1c3:	and    rsp,0xffffffffffffffc0
    a1c7:	mov    r14,rcx
    a1ca:	xor    ecx,ecx
    a1cc:	mov    rbx,rdx
    a1cf:	add    rsp,0xffffffffffffff80
    a1d3:	movsxd rax,DWORD PTR [r13+0xc]
    a1d7:	movsxd r11,DWORD PTR [r13+0x8]
    a1db:	mov    edi,DWORD PTR [rsi+0x4]
    a1de:	mov    esi,DWORD PTR [rsi]
    a1e0:	mov    QWORD PTR [rsp+0x68],r8
    a1e5:	mov    QWORD PTR [rsp+0x78],r9
    a1ea:	mov    r10,rax
    a1ed:	sub    rax,r11
    a1f0:	lea    rax,[rax*8+0x8]
    a1f8:	cmp    r10d,r11d
    a1fb:	movsxd r10,esi
    a1fe:	cmovge rcx,rax
    a202:	movsxd rax,edi
    a205:	xor    edx,edx
    a207:	inc    rax
    a20a:	sub    rax,r10
    a20d:	imul   rax,rcx
    a211:	cmp    edi,esi
    a213:	mov    rdi,r12
    a216:	cmovge rdx,rax
    a21a:	xor    esi,esi
    a21c:	call   2bd0 <memset@plt>
    a221:	mov    ecx,DWORD PTR [r13+0x0]
    a225:	mov    edi,DWORD PTR [r13+0x4]
    a229:	cmp    ecx,edi
    a22b:	jg     a5dc <mj__matrices__mulmatmat+0x42c>
    a231:	mov    r9,QWORD PTR [rsp+0x78]
    a236:	mov    eax,DWORD PTR [r9+0x4]
    a23a:	movsxd rdx,DWORD PTR [r9]
    a23d:	cmp    eax,edx
    a23f:	jl     a5dc <mj__matrices__mulmatmat+0x42c>
    a245:	mov    r8d,DWORD PTR [r9+0xc]
    a249:	mov    r9d,DWORD PTR [r9+0x8]
    a24d:	mov    r15d,DWORD PTR [r13+0x8]
    a251:	mov    r11d,DWORD PTR [r13+0xc]
    a255:	vmovq  xmm12,rdx
    a25a:	mov    r10d,DWORD PTR [r14+0xc]
    a25e:	movsxd rsi,ecx
    a261:	mov    ecx,DWORD PTR [r14+0x8]
    a265:	vmovq  xmm7,QWORD PTR [rsp+0x68]
    a26b:	vmovq  xmm15,rbx
    a270:	vmovq  xmm6,rsi
    a275:	vxorpd xmm10,xmm10,xmm10
    a27a:	vmovq  xmm14,r12
    a27f:	movsxd rdx,r9d
    a282:	mov    DWORD PTR [rsp+0x48],r9d
    a287:	movsxd r9,r11d
    a28a:	mov    DWORD PTR [rsp+0x4c],r8d
    a28f:	vmovq  xmm1,rdx
    a294:	movsxd rdx,r15d
    a297:	movsxd r13,ecx
    a29a:	mov    DWORD PTR [rsp+0x74],r11d
    a29f:	sub    r9,rdx
    a2a2:	vmovq  xmm13,rdx
    a2a7:	mov    DWORD PTR [rsp+0x70],r15d
    a2ac:	vmovdqa xmm9,xmm1
    a2b0:	lea    rdx,[r9*8+0x8]
    a2b8:	movsxd r9,r8d
    a2bb:	vmovq  r8,xmm1
    a2c0:	mov    rbx,r13
    a2c3:	sub    r9,r8
    a2c6:	vmovdqa xmm1,xmm12
    a2ca:	lea    r9,[r9*8+0x8]
    a2d2:	mov    QWORD PTR [rsp+0x40],r9
    a2d7:	movsxd r9,edi
    a2da:	movsxd rdi,r10d
    a2dd:	sub    rdi,r13
    a2e0:	cmp    r10d,ecx
    a2e3:	mov    ecx,0x0
    a2e8:	mov    QWORD PTR [rsp+0x30],r9
    a2ed:	lea    rdi,[rdi*8+0x8]
    a2f5:	lea    r10,[rsi-0x1]
    a2f9:	cmovl  rdi,rcx
    a2fd:	movsxd rcx,DWORD PTR [r14]
    a300:	sub    r11d,r15d
    a303:	movsxd r15,eax
    a306:	lea    eax,[r11+0x1]
    a30a:	mov    DWORD PTR [rsp+0x78],r11d
    a30f:	vmovq  xmm11,r15
    a314:	mov    DWORD PTR [rsp+0x54],eax
    a318:	shr    rdi,0x3
    a31c:	vmovq  xmm16,rcx
    a322:	shr    rdx,0x3
    a326:	mov    ecx,eax
    a328:	and    ecx,0xfffffff8
    a32b:	mov    QWORD PTR [rsp+0x28],rdi
    a330:	mov    QWORD PTR [rsp+0x20],rdx
    a335:	mov    DWORD PTR [rsp+0x50],ecx
    a339:	mov    ecx,eax
    a33b:	shr    ecx,0x3
    a33e:	shl    rcx,0x6
    a342:	nop    DWORD PTR [rax]
    a345:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a350:	vmovq  rsi,xmm16
    a356:	vmovq  r11,xmm14
    a35b:	inc    r10
    a35e:	mov    r13,QWORD PTR [rsp+0x28]
    a363:	vmovq  rax,xmm1
    a368:	vmovq  r14,xmm11
    a36d:	movsxd r9,r10d
    a370:	mov    QWORD PTR [rsp+0x38],r10
    a375:	dec    rax
    a378:	vmovq  r10,xmm9
    a37d:	mov    rdx,r9
    a380:	sub    rdx,rsi
    a383:	vmovq  rsi,xmm6
    a388:	sub    r9,rsi
    a38b:	imul   r9,QWORD PTR [rsp+0x20]
    a391:	vmovq  rsi,xmm13
    a396:	imul   r13,rdx
    a39a:	mov    r12,r13
    a39d:	mov    QWORD PTR [rsp+0x60],r9
    a3a2:	sub    r9,rsi
    a3a5:	vmovq  rsi,xmm15
    a3aa:	mov    QWORD PTR [rsp+0x58],r9
    a3af:	lea    r9,[r11+r9*8]
    a3b3:	vmovq  xmm8,r9
    a3b8:	nop    DWORD PTR [rax+rax*1+0x0]
    a3c0:	inc    rax
    a3c3:	movsxd rdx,eax
    a3c6:	mov    rdi,rdx
    a3c9:	sub    rdi,rbx
    a3cc:	add    rdi,r12
    a3cf:	vmovsd xmm2,QWORD PTR [rsi+rdi*8]
    a3d4:	vcomisd xmm2,xmm10
    a3d9:	vbroadcastsd zmm3,xmm2
    a3df:	je     a5c0 <mj__matrices__mulmatmat+0x410>
    a3e5:	mov    r9d,DWORD PTR [rsp+0x70]
    a3ea:	cmp    DWORD PTR [rsp+0x74],r9d
    a3ef:	jl     a5c0 <mj__matrices__mulmatmat+0x410>
    a3f5:	mov    rdi,QWORD PTR [rsp+0x40]
    a3fa:	mov    r9d,DWORD PTR [rsp+0x48]
    a3ff:	xor    r15d,r15d
    a402:	shr    rdi,0x3
    a406:	cmp    DWORD PTR [rsp+0x4c],r9d
    a40b:	cmovl  rdi,r15
    a40f:	vmovq  xmm5,rdi
    a414:	cmp    DWORD PTR [rsp+0x78],0x6
    a419:	jbe    a5eb <mj__matrices__mulmatmat+0x43b>
    a41f:	vmovq  rdi,xmm1
    a424:	mov    r8,rdx
    a427:	vmovapd zmm4,zmm3
    a42d:	vmovq  r13,xmm8
    a432:	sub    r8,rdi
    a435:	vmovq  rdi,xmm5
    a43a:	imul   r8,rdi
    a43e:	vmovq  rdi,xmm7
    a443:	sub    r8,r10
    a446:	lea    r8,[rdi+r8*8]
    a44a:	xor    edi,edi
    a44c:	nop    WORD PTR [rax+rax*1+0x0]
    a455:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a460:	vmulpd zmm0,zmm4,ZMMWORD PTR [r8+rdi*1]
    a467:	vaddpd zmm0,zmm0,ZMMWORD PTR [r13+rdi*1+0x0]
    a46f:	vmovupd ZMMWORD PTR [r13+rdi*1+0x0],zmm0
    a477:	add    rdi,0x40
    a47b:	cmp    rcx,rdi
    a47e:	jne    a460 <mj__matrices__mulmatmat+0x2b0>
    a480:	mov    edi,DWORD PTR [rsp+0x50]
    a484:	vmovq  xmm8,r13
    a489:	mov    r15d,edi
    a48c:	cmp    DWORD PTR [rsp+0x54],edi
    a490:	je     a5c0 <mj__matrices__mulmatmat+0x410>
    a496:	dec    edi
    a498:	mov    r8d,DWORD PTR [rsp+0x78]
    a49d:	sub    r8d,r15d
    a4a0:	cmp    r8d,0x2
    a4a4:	jbe    a504 <mj__matrices__mulmatmat+0x354>
    a4a6:	lea    r9d,[r8+0x1]
    a4aa:	mov    r8,QWORD PTR [rsp+0x58]
    a4af:	vmovq  r13,xmm1
    a4b4:	mov    DWORD PTR [rsp+0x68],r9d
    a4b9:	add    r8,r15
    a4bc:	lea    r9,[r11+r8*8]
    a4c0:	mov    r8,rdx
    a4c3:	sub    r8,r13
    a4c6:	vmovq  r13,xmm5
    a4cb:	imul   r8,r13
    a4cf:	vmovq  r13,xmm7
    a4d4:	sub    r8,r10
    a4d7:	add    r8,r15
    a4da:	mov    r15d,DWORD PTR [rsp+0x68]
    a4df:	vmulpd ymm3,ymm3,YMMWORD PTR [r13+r8*8+0x0]
    a4e6:	vaddpd ymm3,ymm3,YMMWORD PTR [r9]
    a4eb:	mov    r8d,r15d
    a4ee:	and    r8d,0xfffffffc
    a4f2:	and    r15d,0x3
    a4f6:	vmovupd YMMWORD PTR [r9],ymm3
    a4fb:	je     a5c0 <mj__matrices__mulmatmat+0x410>
    a501:	add    edi,r8d
    a504:	lea    r15d,[rdi+0x1]
    a508:	vmovq  r13,xmm13
    a50d:	mov    r8,r15
    a510:	mov    r9,r15
    a513:	sub    r15,r10
    a516:	sub    r8,r13
    a519:	vmovq  r13,xmm1
    a51e:	add    r8,QWORD PTR [rsp+0x60]
    a523:	sub    rdx,r13
    a526:	vmovq  r13,xmm5
    a52b:	imul   rdx,r13
    a52f:	vmovq  r13,xmm7
    a534:	add    r15,rdx
    a537:	vmulsd xmm0,xmm2,QWORD PTR [r13+r15*8+0x0]
    a53e:	vaddsd xmm0,xmm0,QWORD PTR [r11+r8*8]
    a544:	vmovsd QWORD PTR [r11+r8*8],xmm0
    a54a:	cmp    r9d,DWORD PTR [rsp+0x78]
    a54f:	je     a5c0 <mj__matrices__mulmatmat+0x410>
    a551:	lea    r8d,[rdi+0x2]
    a555:	vmovq  r13,xmm13
    a55a:	mov    r15,r8
    a55d:	mov    r9,r8
    a560:	sub    r8,r10
    a563:	sub    r15,r13
    a566:	add    r15,QWORD PTR [rsp+0x60]
    a56b:	add    r8,rdx
    a56e:	vmovq  r13,xmm7
    a573:	vmulsd xmm0,xmm2,QWORD PTR [r13+r8*8+0x0]
    a57a:	vaddsd xmm0,xmm0,QWORD PTR [r11+r15*8]
    a580:	vmovsd QWORD PTR [r11+r15*8],xmm0
    a586:	cmp    DWORD PTR [rsp+0x78],r9d
    a58b:	je     a5c0 <mj__matrices__mulmatmat+0x410>
    a58d:	add    edi,0x3
    a590:	vmovq  r15,xmm13
    a595:	mov    r8,rdi
    a598:	sub    rdi,r10
    a59b:	sub    r8,r15
    a59e:	add    r8,QWORD PTR [rsp+0x60]
    a5a3:	add    rdi,rdx
    a5a6:	vmulsd xmm2,xmm2,QWORD PTR [r13+rdi*8+0x0]
    a5ad:	vaddsd xmm2,xmm2,QWORD PTR [r11+r8*8]
    a5b3:	vmovsd QWORD PTR [r11+r8*8],xmm2
    a5b9:	nop    DWORD PTR [rax+0x0]
    a5c0:	cmp    rax,r14
    a5c3:	jne    a3c0 <mj__matrices__mulmatmat+0x210>
    a5c9:	mov    r10,QWORD PTR [rsp+0x38]
    a5ce:	cmp    QWORD PTR [rsp+0x30],r10
    a5d3:	jne    a350 <mj__matrices__mulmatmat+0x1a0>
    a5d9:	vzeroupper
    a5dc:	lea    rsp,[rbp-0x28]
    a5e0:	pop    rbx
    a5e1:	pop    r12
    a5e3:	pop    r13
    a5e5:	pop    r14
    a5e7:	pop    r15
    a5e9:	pop    rbp
    a5ea:	ret
    a5eb:	xor    r15d,r15d
    a5ee:	mov    edi,0xffffffff
    a5f3:	jmp    a498 <mj__matrices__mulmatmat+0x2e8>
    a5f8:	nop    DWORD PTR [rax+rax*1+0x0]


<mj__matrices__mulmattmat>:
    a880:	push   rbp
    a881:	mov    rbp,rsp
    a884:	push   r15
    a886:	push   r14
    a888:	push   r13
    a88a:	push   r12
    a88c:	push   rbx
    a88d:	mov    r12,rsi
    a890:	mov    r13,rdi
    a893:	and    rsp,0xffffffffffffffc0
    a897:	mov    r14,rcx
    a89a:	xor    ecx,ecx
    a89c:	mov    rbx,rdx
    a89f:	add    rsp,0xffffffffffffff80
    a8a3:	movsxd rax,DWORD PTR [r12+0xc]
    a8a8:	movsxd r11,DWORD PTR [r12+0x8]
    a8ad:	mov    edi,DWORD PTR [rsi+0x4]
    a8b0:	mov    esi,DWORD PTR [rsi]
    a8b2:	mov    QWORD PTR [rsp+0x78],r9
    a8b7:	mov    QWORD PTR [rsp+0x68],r8
    a8bc:	mov    r10,rax
    a8bf:	sub    rax,r11
    a8c2:	lea    rax,[rax*8+0x8]
    a8ca:	cmp    r10d,r11d
    a8cd:	movsxd r10,esi
    a8d0:	cmovge rcx,rax
    a8d4:	movsxd rax,edi
    a8d7:	xor    edx,edx
    a8d9:	inc    rax
    a8dc:	sub    rax,r10
    a8df:	imul   rax,rcx
    a8e3:	cmp    edi,esi
    a8e5:	mov    rdi,r13
    a8e8:	cmovge rdx,rax
    a8ec:	xor    esi,esi
    a8ee:	call   2bd0 <memset@plt>
    a8f3:	mov    r9,QWORD PTR [rsp+0x78]
    a8f8:	mov    ecx,DWORD PTR [r9]
    a8fb:	mov    esi,DWORD PTR [r9+0x4]
    a8ff:	cmp    ecx,esi
    a901:	jg     acb1 <mj__matrices__mulmattmat+0x431>
    a907:	movsxd rax,DWORD PTR [r12+0x4]
    a90c:	mov    edx,DWORD PTR [r12]
    a910:	cmp    eax,edx
    a912:	jl     acb1 <mj__matrices__mulmattmat+0x431>
    a918:	movsxd rdi,ecx
    a91b:	movsxd r11,DWORD PTR [r9+0x8]
    a91f:	mov    r8d,DWORD PTR [r12+0xc]
    a924:	mov    r15d,DWORD PTR [r12+0x8]
    a929:	lea    r10,[rdi-0x1]
    a92d:	vmovq  xmm7,rdi
    a932:	mov    edi,DWORD PTR [r9+0xc]
    a936:	movsxd r9,edx
    a939:	mov    ecx,DWORD PTR [r14+0x8]
    a93d:	vmovq  xmm12,r9
    a942:	vmovq  xmm4,rax
    a947:	vmovq  xmm13,QWORD PTR [rsp+0x68]
    a94d:	vxorpd xmm8,xmm8,xmm8
    a952:	mov    rdx,r11
    a955:	movsxd r9,r8d
    a958:	mov    DWORD PTR [rsp+0x48],r11d
    a95d:	vmovq  xmm6,r11
    a962:	mov    DWORD PTR [rsp+0x4c],edi
    a966:	movsxd r11,r15d
    a969:	mov    edi,DWORD PTR [r14+0xc]
    a96d:	mov    DWORD PTR [rsp+0x70],r15d
    a972:	sub    r9,r11
    a975:	vmovq  xmm5,r11
    a97a:	movsxd r12,ecx
    a97d:	movsxd r15,esi
    a980:	lea    r11,[r9*8+0x8]
    a988:	movsxd r9,DWORD PTR [rsp+0x4c]
    a98d:	mov    DWORD PTR [rsp+0x5c],r8d
    a992:	mov    QWORD PTR [rsp+0x30],r15
    a997:	mov    QWORD PTR [rsp+0x20],r11
    a99c:	movsxd rsi,edi
    a99f:	sub    rsi,r12
    a9a2:	sub    r9,rdx
    a9a5:	lea    rsi,[rsi*8+0x8]
    a9ad:	cmp    edi,ecx
    a9af:	mov    ecx,0x0
    a9b4:	cmovl  rsi,rcx
    a9b8:	sub    r8d,DWORD PTR [rsp+0x70]
    a9bd:	lea    rdx,[r9*8+0x8]
    a9c5:	mov    rdi,rsi
    a9c8:	shr    rdi,0x3
    a9cc:	shr    rdx,0x3
    a9d0:	lea    eax,[r8+0x1]
    a9d4:	movsxd rsi,DWORD PTR [r14]
    a9d7:	mov    DWORD PTR [rsp+0x74],r8d
    a9dc:	mov    QWORD PTR [rsp+0x40],rdx
    a9e1:	mov    DWORD PTR [rsp+0x54],eax
    a9e5:	mov    QWORD PTR [rsp+0x28],rdi
    a9ea:	mov    r14,r10
    a9ed:	mov    r10,rbx
    a9f0:	mov    rbx,r12
    a9f3:	shr    eax,0x3
    a9f6:	mov    DWORD PTR [rsp+0x50],eax
    a9fa:	mov    ecx,eax
    a9fc:	vmovq  xmm14,rsi
    aa01:	mov    rsi,r13
    aa04:	vmovq  r13,xmm4
    aa09:	shl    rcx,0x6
    aa0d:	nop    DWORD PTR [rax]
    aa10:	vmovq  rdi,xmm14
    aa15:	vmovq  r15,xmm12
    aa1a:	inc    r14
    aa1d:	mov    r12,QWORD PTR [rsp+0x28]
    aa22:	mov    QWORD PTR [rsp+0x60],rcx
    aa27:	lea    rax,[r15-0x1]
    aa2b:	movsxd r11,r14d
    aa2e:	mov    QWORD PTR [rsp+0x38],r14
    aa33:	mov    rdx,r11
    aa36:	sub    rdx,rdi
    aa39:	mov    rdi,QWORD PTR [rsp+0x20]
    aa3e:	imul   r12,rdx
    aa42:	shr    rdi,0x3
    aa46:	mov    QWORD PTR [rsp+0x68],rdi
    aa4b:	vmovq  rdi,xmm7
    aa50:	sub    r11,rdi
    aa53:	mov    rdi,r12
    aa56:	mov    r12,r11
    aa59:	nop    DWORD PTR [rax+0x0]
    aa60:	inc    rax
    aa63:	movsxd rdx,eax
    aa66:	mov    r8,rdx
    aa69:	sub    r8,rbx
    aa6c:	add    r8,rdi
    aa6f:	vmovsd xmm1,QWORD PTR [r10+r8*8]
    aa75:	vcomisd xmm1,xmm8
    aa7a:	vbroadcastsd zmm2,xmm1
    aa80:	je     ac90 <mj__matrices__mulmattmat+0x410>
    aa86:	mov    r9d,DWORD PTR [rsp+0x70]
    aa8b:	cmp    DWORD PTR [rsp+0x5c],r9d
    aa90:	jl     ac90 <mj__matrices__mulmattmat+0x410>
    aa96:	mov    r11d,DWORD PTR [rsp+0x48]
    aa9b:	cmp    DWORD PTR [rsp+0x4c],r11d
    aaa0:	mov    r11d,0x0
    aaa6:	cmovge r11,QWORD PTR [rsp+0x40]
    aaac:	cmp    DWORD PTR [rsp+0x74],0x6
    aab1:	jbe    acc0 <mj__matrices__mulmattmat+0x440>
    aab7:	mov    r8,r12
    aaba:	vmovq  rcx,xmm6
    aabf:	vmovapd zmm3,zmm2
    aac5:	imul   r8,r11
    aac9:	sub    r8,rcx
    aacc:	vmovq  rcx,xmm13
    aad1:	lea    r14,[rcx+r8*8]
    aad5:	mov    r8,rdx
    aad8:	sub    r8,r15
    aadb:	imul   r8,QWORD PTR [rsp+0x68]
    aae1:	vmovq  rcx,xmm5
    aae6:	sub    r8,rcx
    aae9:	mov    rcx,QWORD PTR [rsp+0x60]
    aaee:	lea    r9,[rsi+r8*8]
    aaf2:	xor    r8d,r8d
    aaf5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ab00:	vmulpd zmm0,zmm3,ZMMWORD PTR [r14+r8*1]
    ab07:	vaddpd zmm0,zmm0,ZMMWORD PTR [r9+r8*1]
    ab0e:	vmovupd ZMMWORD PTR [r9+r8*1],zmm0
    ab15:	add    r8,0x40
    ab19:	cmp    rcx,r8
    ab1c:	jne    ab00 <mj__matrices__mulmattmat+0x280>
    ab1e:	mov    QWORD PTR [rsp+0x60],rcx
    ab23:	mov    ecx,DWORD PTR [rsp+0x50]
    ab27:	lea    r8d,[rcx*8+0x0]
    ab2f:	cmp    DWORD PTR [rsp+0x54],r8d
    ab34:	je     ac90 <mj__matrices__mulmattmat+0x410>
    ab3a:	lea    ecx,[r8-0x1]
    ab3e:	mov    DWORD PTR [rsp+0x78],ecx
    ab42:	mov    r14d,DWORD PTR [rsp+0x74]
    ab47:	sub    r14d,r8d
    ab4a:	cmp    r14d,0x2
    ab4e:	jbe    abbe <mj__matrices__mulmattmat+0x33e>
    ab50:	inc    r14d
    ab53:	mov    rcx,rdx
    ab56:	sub    rcx,r15
    ab59:	mov    r9,r8
    ab5c:	mov    DWORD PTR [rsp+0x58],r14d
    ab61:	mov    r14,QWORD PTR [rsp+0x68]
    ab66:	imul   r14,rcx
    ab6a:	vmovq  rcx,xmm5
    ab6f:	sub    r14,rcx
    ab72:	mov    rcx,r12
    ab75:	imul   rcx,r11
    ab79:	add    r14,r8
    ab7c:	lea    r8,[rsi+r14*8]
    ab80:	mov    r14,rcx
    ab83:	vmovq  rcx,xmm6
    ab88:	sub    r14,rcx
    ab8b:	vmovq  rcx,xmm13
    ab90:	add    r14,r9
    ab93:	vmulpd ymm2,ymm2,YMMWORD PTR [rcx+r14*8]
    ab99:	mov    r14d,DWORD PTR [rsp+0x58]
    ab9e:	vaddpd ymm2,ymm2,YMMWORD PTR [r8]
    aba3:	vmovupd YMMWORD PTR [r8],ymm2
    aba8:	mov    r8d,r14d
    abab:	and    r8d,0xfffffffc
    abaf:	and    r14d,0x3
    abb3:	je     ac90 <mj__matrices__mulmattmat+0x410>
    abb9:	add    DWORD PTR [rsp+0x78],r8d
    abbe:	mov    ecx,DWORD PTR [rsp+0x78]
    abc2:	vmovq  r9,xmm5
    abc7:	imul   r11,r12
    abcb:	sub    rdx,r15
    abce:	imul   rdx,QWORD PTR [rsp+0x68]
    abd4:	lea    r8d,[rcx+0x1]
    abd8:	mov    r14,r8
    abdb:	mov    rcx,r8
    abde:	sub    r14,r9
    abe1:	vmovq  r9,xmm6
    abe6:	sub    r8,r9
    abe9:	vmovq  r9,xmm13
    abee:	add    r14,rdx
    abf1:	add    r8,r11
    abf4:	vmulsd xmm0,xmm1,QWORD PTR [r9+r8*8]
    abfa:	vaddsd xmm0,xmm0,QWORD PTR [rsi+r14*8]
    ac00:	vmovsd QWORD PTR [rsi+r14*8],xmm0
    ac06:	cmp    ecx,DWORD PTR [rsp+0x74]
    ac0a:	je     ac90 <mj__matrices__mulmattmat+0x410>
    ac10:	mov    ecx,DWORD PTR [rsp+0x78]
    ac14:	lea    r8d,[rcx+0x2]
    ac18:	vmovq  rcx,xmm5
    ac1d:	mov    r14,r8
    ac20:	mov    r9,r8
    ac23:	sub    r14,rcx
    ac26:	vmovq  rcx,xmm6
    ac2b:	sub    r8,rcx
    ac2e:	vmovq  rcx,xmm13
    ac33:	add    r14,rdx
    ac36:	add    r8,r11
    ac39:	vmulsd xmm0,xmm1,QWORD PTR [rcx+r8*8]
    ac3f:	vaddsd xmm0,xmm0,QWORD PTR [rsi+r14*8]
    ac45:	vmovsd QWORD PTR [rsi+r14*8],xmm0
    ac4b:	cmp    DWORD PTR [rsp+0x74],r9d
    ac50:	je     ac90 <mj__matrices__mulmattmat+0x410>
    ac52:	mov    ecx,DWORD PTR [rsp+0x78]
    ac56:	lea    r8d,[rcx+0x3]
    ac5a:	vmovq  rcx,xmm5
    ac5f:	mov    r9,r8
    ac62:	sub    r9,rcx
    ac65:	add    r9,rdx
    ac68:	vmovq  rdx,xmm6
    ac6d:	sub    r8,rdx
    ac70:	vmovq  rdx,xmm13
    ac75:	add    r8,r11
    ac78:	vmulsd xmm1,xmm1,QWORD PTR [rdx+r8*8]
    ac7e:	vaddsd xmm1,xmm1,QWORD PTR [rsi+r9*8]
    ac84:	vmovsd QWORD PTR [rsi+r9*8],xmm1
    ac8a:	nop    WORD PTR [rax+rax*1+0x0]
    ac90:	cmp    rax,r13
    ac93:	jne    aa60 <mj__matrices__mulmattmat+0x1e0>
    ac99:	mov    r14,QWORD PTR [rsp+0x38]
    ac9e:	mov    rcx,QWORD PTR [rsp+0x60]
    aca3:	cmp    QWORD PTR [rsp+0x30],r14
    aca8:	jne    aa10 <mj__matrices__mulmattmat+0x190>
    acae:	vzeroupper
    acb1:	lea    rsp,[rbp-0x28]
    acb5:	pop    rbx
    acb6:	pop    r12
    acb8:	pop    r13
    acba:	pop    r14
    acbc:	pop    r15
    acbe:	pop    rbp
    acbf:	ret
    acc0:	mov    DWORD PTR [rsp+0x78],0xffffffff
    acc8:	xor    r8d,r8d
    accb:	jmp    ab42 <mj__matrices__mulmattmat+0x2c2>


<mj__matrices__mulmattvec>:
    9c50:	push   rbp
    9c51:	mov    rbp,rsp
    9c54:	push   r15
    9c56:	push   r14
    9c58:	push   r13
    9c5a:	push   r12
    9c5c:	push   rbx
    9c5d:	mov    r13,rsi
    9c60:	mov    rbx,rdx
    9c63:	and    rsp,0xffffffffffffffc0
    9c67:	xor    edx,edx
    9c69:	mov    r14,rcx
    9c6c:	add    rsp,0xffffffffffffff80
    9c70:	movsxd rax,DWORD PTR [rsi+0x4]
    9c74:	movsxd r12,DWORD PTR [r9]
    9c77:	movsxd r9,DWORD PTR [r13+0x0]
    9c7b:	mov    QWORD PTR [rsp+0x70],r8
    9c80:	mov    rsi,rax
    9c83:	sub    rax,r9
    9c86:	lea    rax,[rax*8+0x8]
    9c8e:	cmp    esi,r9d
    9c91:	cmovge rdx,rax
    9c95:	xor    esi,esi
    9c97:	call   2bd0 <memset@plt>
    9c9c:	movsxd rcx,DWORD PTR [r14+0x4]
    9ca0:	mov    rdi,rax
    9ca3:	movsxd rax,DWORD PTR [r14]
    9ca6:	cmp    eax,ecx
    9ca8:	jg     9efc <mj__matrices__mulmattvec+0x2ac>
    9cae:	movsxd rsi,DWORD PTR [r14+0x8]
    9cb2:	mov    r8,QWORD PTR [rsp+0x70]
    9cb7:	neg    r12
    9cba:	movsxd r15,DWORD PTR [r13+0x0]
    9cbe:	mov    r13d,DWORD PTR [r13+0x4]
    9cc2:	vmovq  xmm6,rax
    9cc7:	dec    rax
    9cca:	vmovq  xmm5,rbx
    9ccf:	vxorpd xmm4,xmm4,xmm4
    9cd3:	mov    rdx,rsi
    9cd6:	vmovq  xmm7,rsi
    9cdb:	mov    esi,DWORD PTR [r14+0xc]
    9cdf:	lea    r12,[r8+r12*8]
    9ce3:	mov    r10,rdx
    9ce6:	mov    DWORD PTR [rsp+0x7c],r15d
    9ceb:	mov    QWORD PTR [rsp+0x58],r15
    9cf0:	mov    rbx,r12
    9cf3:	vmovq  r12,xmm5
    9cf8:	movsxd r8,esi
    9cfb:	sub    r8,rdx
    9cfe:	cmp    edx,esi
    9d00:	mov    edx,0x0
    9d05:	movsxd rsi,r13d
    9d08:	lea    r8,[r8*8+0x8]
    9d10:	mov    QWORD PTR [rsp+0x38],rsi
    9d15:	cmovle rdx,r8
    9d19:	sub    rsi,r15
    9d1c:	shr    rdx,0x3
    9d20:	mov    QWORD PTR [rsp+0x60],rdx
    9d25:	mov    rdx,r15
    9d28:	sub    rdx,r10
    9d2b:	mov    QWORD PTR [rsp+0x70],rsi
    9d30:	mov    QWORD PTR [rsp+0x50],rdx
    9d35:	lea    rdx,[rsi+0x1]
    9d39:	mov    r15d,r13d
    9d3c:	mov    QWORD PTR [rsp+0x48],rdx
    9d41:	lea    rdx,[rsi-0x7]
    9d45:	shr    rdx,0x3
    9d49:	inc    rdx
    9d4c:	lea    rsi,[rdx*8+0x0]
    9d54:	mov    QWORD PTR [rsp+0x40],rsi
    9d59:	nop    DWORD PTR [rax+0x0]
    9d60:	inc    rax
    9d63:	vmovsd xmm1,QWORD PTR [rbx+rax*8]
    9d68:	vcomisd xmm1,xmm4
    9d6c:	vbroadcastsd zmm2,xmm1
    9d72:	je     9ef0 <mj__matrices__mulmattvec+0x2a0>
    9d78:	cmp    DWORD PTR [rsp+0x7c],r15d
    9d7d:	jg     9ef0 <mj__matrices__mulmattvec+0x2a0>
    9d83:	movsxd r10,eax
    9d86:	vmovq  r11,xmm6
    9d8b:	mov    r14,QWORD PTR [rsp+0x50]
    9d90:	mov    rsi,r10
    9d93:	sub    rsi,r11
    9d96:	imul   rsi,QWORD PTR [rsp+0x60]
    9d9c:	lea    r8,[rsi+r14*1+0x1]
    9da1:	lea    r11,[r14+rsi*1]
    9da5:	lea    r9,[r12+r8*8]
    9da9:	mov    r8,rdi
    9dac:	sub    r8,r9
    9daf:	cmp    r8,0x30
    9db3:	jbe    9f10 <mj__matrices__mulmattvec+0x2c0>
    9db9:	cmp    QWORD PTR [rsp+0x70],0x6
    9dbf:	jbe    9f65 <mj__matrices__mulmattvec+0x315>
    9dc5:	vmovapd zmm3,zmm2
    9dcb:	lea    r9,[r12+r11*8]
    9dcf:	xor    esi,esi
    9dd1:	xor    r8d,r8d
    9dd4:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9ddf:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9dea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9df5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9e00:	vmulpd zmm0,zmm3,ZMMWORD PTR [r9+rsi*1]
    9e07:	inc    r8
    9e0a:	vaddpd zmm0,zmm0,ZMMWORD PTR [rdi+rsi*1]
    9e11:	vmovupd ZMMWORD PTR [rdi+rsi*1],zmm0
    9e18:	add    rsi,0x40
    9e1c:	cmp    r8,rdx
    9e1f:	jb     9e00 <mj__matrices__mulmattvec+0x1b0>
    9e21:	mov    rsi,QWORD PTR [rsp+0x40]
    9e26:	mov    r8,rsi
    9e29:	cmp    QWORD PTR [rsp+0x48],rsi
    9e2e:	je     9ef0 <mj__matrices__mulmattvec+0x2a0>
    9e34:	mov    r14,QWORD PTR [rsp+0x58]
    9e39:	lea    rsi,[r14+rsi*1-0x1]
    9e3e:	mov    QWORD PTR [rsp+0x68],rsi
    9e43:	mov    r13,QWORD PTR [rsp+0x70]
    9e48:	sub    r13,r8
    9e4b:	lea    r9,[r13+0x1]
    9e4f:	cmp    r13,0x2
    9e53:	jbe    9f7a <mj__matrices__mulmattvec+0x32a>
    9e59:	lea    rsi,[r11+r8*1]
    9e5d:	mov    r14,r9
    9e60:	and    r14,0xfffffffffffffffc
    9e64:	vmulpd ymm0,ymm2,YMMWORD PTR [r12+rsi*8]
    9e6a:	vaddpd ymm0,ymm0,YMMWORD PTR [rdi+r8*8]
    9e70:	vmovupd YMMWORD PTR [rdi+r8*8],ymm0
    9e76:	test   r9b,0x3
    9e7a:	je     9ef0 <mj__matrices__mulmattvec+0x2a0>
    9e7c:	add    QWORD PTR [rsp+0x68],r14
    9e81:	cmp    r13,r14
    9e84:	je     9eb3 <mj__matrices__mulmattvec+0x263>
    9e86:	add    r8,r14
    9e89:	sub    r9,r14
    9e8c:	add    r11,r8
    9e8f:	vmulpd xmm0,xmm2,XMMWORD PTR [r12+r11*8]
    9e95:	vaddpd xmm0,xmm0,XMMWORD PTR [rdi+r8*8]
    9e9b:	vmovupd XMMWORD PTR [rdi+r8*8],xmm0
    9ea1:	mov    r8,r9
    9ea4:	and    r8,0xfffffffffffffffe
    9ea8:	and    r9d,0x1
    9eac:	je     9ef0 <mj__matrices__mulmattvec+0x2a0>
    9eae:	add    QWORD PTR [rsp+0x68],r8
    9eb3:	mov    rsi,QWORD PTR [rsp+0x68]
    9eb8:	vmovq  r11,xmm7
    9ebd:	inc    rsi
    9ec0:	mov    r8,rsi
    9ec3:	sub    rsi,r11
    9ec6:	vmovq  r11,xmm6
    9ecb:	sub    r8,QWORD PTR [rsp+0x58]
    9ed0:	sub    r10,r11
    9ed3:	imul   r10,QWORD PTR [rsp+0x60]
    9ed9:	add    rsi,r10
    9edc:	vmulsd xmm1,xmm1,QWORD PTR [r12+rsi*8]
    9ee2:	vaddsd xmm1,xmm1,QWORD PTR [rdi+r8*8]
    9ee8:	vmovsd QWORD PTR [rdi+r8*8],xmm1
    9eee:	xchg   ax,ax
    9ef0:	cmp    rcx,rax
    9ef3:	jne    9d60 <mj__matrices__mulmattvec+0x110>
    9ef9:	vzeroupper
    9efc:	lea    rsp,[rbp-0x28]
    9f00:	pop    rbx
    9f01:	pop    r12
    9f03:	pop    r13
    9f05:	pop    r14
    9f07:	pop    r15
    9f09:	pop    rbp
    9f0a:	ret
    9f0b:	nop    DWORD PTR [rax+rax*1+0x0]
    9f10:	vmovq  r10,xmm7
    9f15:	sub    rsi,r10
    9f18:	mov    r10,QWORD PTR [rsp+0x58]
    9f1d:	lea    r9,[r12+rsi*8]
    9f21:	mov    rsi,r10
    9f24:	neg    rsi
    9f27:	lea    r8,[rdi+rsi*8]
    9f2b:	lea    rsi,[r10-0x1]
    9f2f:	mov    r10,QWORD PTR [rsp+0x38]
    9f34:	nop
    9f35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9f40:	inc    rsi
    9f43:	vmulsd xmm0,xmm1,QWORD PTR [r9+rsi*8]
    9f49:	vaddsd xmm0,xmm0,QWORD PTR [r8+rsi*8]
    9f4f:	vmovsd QWORD PTR [r8+rsi*8],xmm0
    9f55:	cmp    r10,rsi
    9f58:	jne    9f40 <mj__matrices__mulmattvec+0x2f0>
    9f5a:	cmp    rcx,rax
    9f5d:	jne    9d60 <mj__matrices__mulmattvec+0x110>
    9f63:	jmp    9ef9 <mj__matrices__mulmattvec+0x2a9>
    9f65:	mov    rsi,QWORD PTR [rsp+0x58]
    9f6a:	xor    r8d,r8d
    9f6d:	dec    rsi
    9f70:	mov    QWORD PTR [rsp+0x68],rsi
    9f75:	jmp    9e43 <mj__matrices__mulmattvec+0x1f3>
    9f7a:	xor    r14d,r14d
    9f7d:	jmp    9e81 <mj__matrices__mulmattvec+0x231>
    9f82:	nop    DWORD PTR [rax]
    9f85:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<mj__matrices__mulmatvec>:
    4280:	push   rbp
    4281:	mov    rax,rcx
    4284:	mov    rbp,rsp
    4287:	push   r15
    4289:	push   r14
    428b:	push   r13
    428d:	push   r12
    428f:	push   rbx
    4290:	mov    r14,rdx
    4293:	and    rsp,0xffffffffffffffe0
    4297:	sub    rsp,0x8
    429b:	mov    ecx,DWORD PTR [rsi+0x4]
    429e:	movsxd rdx,DWORD PTR [rsi]
    42a1:	cmp    ecx,edx
    42a3:	jl     45e4 <mj__matrices__mulmatvec+0x364>
    42a9:	mov    ebx,DWORD PTR [rax]
    42ab:	mov    r10,rdi
    42ae:	movsxd rdi,DWORD PTR [rax+0x8]
    42b2:	movsxd r13,DWORD PTR [rax+0xc]
    42b6:	lea    rax,[rdx-0x1]
    42ba:	mov    r12,r14
    42bd:	mov    DWORD PTR [rsp-0x34],ebx
    42c1:	mov    rbx,rdi
    42c4:	add    rdi,0x2
    42c8:	mov    DWORD PTR [rsp-0x4],r13d
    42cd:	mov    rsi,r13
    42d0:	sub    rsi,rbx
    42d3:	mov    QWORD PTR [rsp],rdi
    42d7:	mov    DWORD PTR [rsp-0x8],ebx
    42db:	lea    rdi,[rsi*8+0x8]
    42e3:	xor    esi,esi
    42e5:	cmp    r13d,ebx
    42e8:	mov    r14,rbx
    42eb:	cmovge rsi,rdi
    42ef:	mov    r15,r13
    42f2:	sub    r15,rbx
    42f5:	mov    QWORD PTR [rsp-0x40],rdi
    42fa:	lea    rdi,[r15+0x1]
    42fe:	mov    QWORD PTR [rsp-0x20],rsi
    4303:	neg    rdx
    4306:	mov    QWORD PTR [rsp-0x58],r15
    430b:	mov    rsi,rdi
    430e:	and    esi,0x3
    4311:	mov    r11,rdi
    4314:	sar    r11,0x3f
    4318:	mov    QWORD PTR [rsp-0x18],rsi
    431d:	lea    rsi,[rdi*8+0x0]
    4325:	mov    QWORD PTR [rsp-0x48],rsi
    432a:	mov    rsi,r11
    432d:	shr    rsi,0x3e
    4331:	add    rdi,rsi
    4334:	mov    r11d,r13d
    4337:	sub    r11d,ebx
    433a:	and    edi,0x3
    433d:	inc    r11d
    4340:	sub    rdi,rsi
    4343:	mov    QWORD PTR [rsp-0x78],rdi
    4348:	movsxd rdi,ecx
    434b:	movsxd rcx,DWORD PTR [r9]
    434e:	vmovq  xmm7,rdi
    4353:	sar    r11d,0x2
    4357:	dec    r11d
    435a:	mov    rsi,rcx
    435d:	mov    QWORD PTR [rsp-0x50],rcx
    4362:	neg    rsi
    4365:	lea    rdi,[r8+rsi*8]
    4369:	mov    rsi,QWORD PTR [rsp-0x48]
    436e:	mov    QWORD PTR [rsp-0x10],rdi
    4373:	lea    rdi,[r10+rdx*8]
    4377:	vmovq  xmm3,rdi
    437c:	mov    rdi,r15
    437f:	sub    rdi,rcx
    4382:	sub    r15,rbx
    4385:	mov    QWORD PTR [rsp-0x68],rdi
    438a:	mov    edi,0x4
    438f:	mov    QWORD PTR [rsp-0x70],r15
    4394:	mov    r15,r8
    4397:	sub    rdi,rcx
    439a:	shr    rsi,0x3
    439e:	mov    QWORD PTR [rsp-0x30],rdi
    43a3:	lea    rdi,[rax+0x1]
    43a7:	mov    QWORD PTR [rsp-0x60],rsi
    43ac:	movsxd r10,edi
    43af:	cmp    QWORD PTR [rsp],r13
    43b3:	jge    4646 <mj__matrices__mulmatvec+0x3c6>
    43b9:	movsxd rbx,DWORD PTR [rsp-0x34]
    43be:	mov    rax,QWORD PTR [rsp-0x20]
    43c3:	movsxd r9,r10d
    43c6:	mov    rsi,QWORD PTR [rsp-0x10]
    43cb:	mov    ecx,DWORD PTR [rsp-0x8]
    43cf:	mov    rdx,r9
    43d2:	sub    rdx,rbx
    43d5:	shr    rax,0x3
    43d9:	imul   rax,rdx
    43dd:	vmovupd ymm0,YMMWORD PTR [rsi]
    43e1:	sub    rax,r14
    43e4:	vmulpd ymm0,ymm0,YMMWORD PTR [r12+rax*8]
    43ea:	cmp    DWORD PTR [rsp-0x4],ecx
    43ee:	jl     4600 <mj__matrices__mulmatvec+0x380>
    43f4:	test   r11d,r11d
    43f7:	jle    44ce <mj__matrices__mulmatvec+0x24e>
    43fd:	mov    r8,QWORD PTR [rsp-0x40]
    4402:	shr    r8,0x3
    4406:	cmp    r11d,0x2
    440a:	jle    47f0 <mj__matrices__mulmatvec+0x570>
    4410:	mov    rax,r9
    4413:	sub    rax,rbx
    4416:	lea    esi,[r11-0x3]
    441a:	xor    ecx,ecx
    441c:	imul   rax,r8
    4420:	and    esi,0xfffffffe
    4423:	add    esi,0x2
    4426:	sub    rax,r14
    4429:	lea    rdx,[r12+rax*8+0x20]
    442e:	mov    rax,QWORD PTR [rsp-0x10]
    4433:	xchg   ax,ax
    4435:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4440:	vmovupd ymm1,YMMWORD PTR [rdx]
    4444:	vmulpd ymm1,ymm1,YMMWORD PTR [rax+0x20]
    4449:	add    ecx,0x2
    444c:	add    rax,0x40
    4450:	add    rdx,0x40
    4454:	vaddpd ymm0,ymm1,ymm0
    4458:	vmovupd ymm1,YMMWORD PTR [rdx-0x20]
    445d:	vmulpd ymm1,ymm1,YMMWORD PTR [rax]
    4461:	vaddpd ymm0,ymm0,ymm1
    4465:	cmp    esi,ecx
    4467:	jne    4440 <mj__matrices__mulmatvec+0x1c0>
    4469:	mov    rdx,r9
    446c:	sub    rdx,rbx
    446f:	mov    eax,ecx
    4471:	inc    ecx
    4473:	imul   rdx,r8
    4477:	mov    r8d,0x4
    447d:	shl    rax,0x2
    4481:	sub    r8,r14
    4484:	lea    rsi,[rax+rdx*1]
    4488:	add    rsi,r8
    448b:	mov    QWORD PTR [rsp-0x28],rsi
    4490:	mov    rsi,QWORD PTR [rsp-0x30]
    4495:	add    rsi,rax
    4498:	vmovupd ymm1,YMMWORD PTR [r15+rsi*8]
    449e:	mov    rsi,QWORD PTR [rsp-0x28]
    44a3:	vmulpd ymm1,ymm1,YMMWORD PTR [r12+rsi*8]
    44a9:	vaddpd ymm0,ymm1,ymm0
    44ad:	cmp    ecx,r11d
    44b0:	jne    4680 <mj__matrices__mulmatvec+0x400>
    44b6:	cmp    QWORD PTR [rsp],r13
    44ba:	jge    45a7 <mj__matrices__mulmatvec+0x327>
    44c0:	mov    ecx,DWORD PTR [rsp-0x8]
    44c4:	cmp    DWORD PTR [rsp-0x4],ecx
    44c8:	jl     4600 <mj__matrices__mulmatvec+0x380>
    44ce:	cmp    QWORD PTR [rsp-0x18],0x0
    44d4:	je     4600 <mj__matrices__mulmatvec+0x380>
    44da:	sub    r9,rbx
    44dd:	imul   r9,QWORD PTR [rsp-0x60]
    44e3:	mov    rax,QWORD PTR [rsp-0x70]
    44e8:	mov    rcx,QWORD PTR [rsp-0x68]
    44ed:	vmovsd xmm8,QWORD PTR [r15+rcx*8]
    44f3:	add    rax,r9
    44f6:	vmulsd xmm8,xmm8,QWORD PTR [r12+rax*8]
    44fc:	mov    rax,QWORD PTR [rsp-0x18]
    4501:	cmp    rax,0x2
    4505:	je     46c1 <mj__matrices__mulmatvec+0x441>
    450b:	cmp    rax,0x3
    450f:	jne    455a <mj__matrices__mulmatvec+0x2da>
    4511:	mov    rax,QWORD PTR [rsp-0x58]
    4516:	mov    rsi,QWORD PTR [rsp-0x50]
    451b:	lea    rdx,[rax-0x2]
    451f:	dec    rax
    4522:	mov    rcx,rdx
    4525:	sub    rdx,r14
    4528:	add    rdx,r9
    452b:	sub    rcx,rsi
    452e:	vmovsd xmm1,QWORD PTR [r15+rcx*8]
    4534:	vmulsd xmm1,xmm1,QWORD PTR [r12+rdx*8]
    453a:	mov    rdx,rax
    453d:	sub    rdx,rsi
    4540:	sub    rax,r14
    4543:	vmovsd xmm5,QWORD PTR [r15+rdx*8]
    4549:	add    rax,r9
    454c:	vmulsd xmm5,xmm5,QWORD PTR [r12+rax*8]
    4552:	vaddsd xmm1,xmm1,xmm5
    4556:	vaddsd xmm8,xmm8,xmm1
    455a:	vextractf64x2 xmm9,ymm0,0x1
    4561:	vunpckhpd xmm5,xmm0,xmm0
    4565:	vaddsd xmm1,xmm0,xmm9
    456a:	valignq ymm0,ymm0,ymm0,0x3
    4571:	vaddsd xmm0,xmm5,xmm0
    4575:	vaddsd xmm0,xmm1,xmm0
    4579:	vaddsd xmm0,xmm0,xmm8
    457e:	vmovq  rax,xmm3
    4583:	vmovsd QWORD PTR [rax+rdi*8],xmm0
    4588:	vmovq  rax,xmm7
    458d:	cmp    rdi,rax
    4590:	je     45e1 <mj__matrices__mulmatvec+0x361>
    4592:	inc    rdi
    4595:	movsxd r10,edi
    4598:	cmp    QWORD PTR [rsp],r13
    459c:	jl     43be <mj__matrices__mulmatvec+0x13e>
    45a2:	jmp    46ac <mj__matrices__mulmatvec+0x42c>
    45a7:	mov    rax,QWORD PTR [rsp-0x78]
    45ac:	cmp    rax,0x2
    45b0:	je     4728 <mj__matrices__mulmatvec+0x4a8>
    45b6:	cmp    rax,0x3
    45ba:	je     4788 <mj__matrices__mulmatvec+0x508>
    45c0:	cmp    rax,0x1
    45c4:	je     46ec <mj__matrices__mulmatvec+0x46c>
    45ca:	vmovq  rax,xmm3
    45cf:	mov    QWORD PTR [rax+rdi*8],0x0
    45d7:	vmovq  rax,xmm7
    45dc:	cmp    rdi,rax
    45df:	jne    4592 <mj__matrices__mulmatvec+0x312>
    45e1:	vzeroupper
    45e4:	lea    rsp,[rbp-0x28]
    45e8:	pop    rbx
    45e9:	pop    r12
    45eb:	pop    r13
    45ed:	pop    r14
    45ef:	pop    r15
    45f1:	pop    rbp
    45f2:	ret
    45f3:	xchg   ax,ax
    45f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4600:	vextractf64x2 xmm5,ymm0,0x1
    4607:	vunpckhpd xmm1,xmm0,xmm0
    460b:	vaddsd xmm2,xmm0,xmm5
    460f:	mov    rax,rdi
    4612:	valignq ymm0,ymm0,ymm0,0x3
    4619:	vaddsd xmm1,xmm1,xmm0
    461d:	vaddsd xmm1,xmm2,xmm1
    4621:	vmovq  rbx,xmm3
    4626:	vmovsd QWORD PTR [rbx+rax*8],xmm1
    462b:	vmovq  rbx,xmm7
    4630:	cmp    rax,rbx
    4633:	je     45e1 <mj__matrices__mulmatvec+0x361>
    4635:	lea    rdi,[rax+0x1]
    4639:	movsxd r10,edi
    463c:	cmp    QWORD PTR [rsp],r13
    4640:	jl     43b9 <mj__matrices__mulmatvec+0x139>
    4646:	mov    ecx,DWORD PTR [rsp-0x8]
    464a:	cmp    DWORD PTR [rsp-0x4],ecx
    464e:	jge    46a7 <mj__matrices__mulmatvec+0x427>
    4650:	vmovq  rbx,xmm3
    4655:	mov    QWORD PTR [rbx+rdi*8],0x0
    465d:	vmovq  rbx,xmm7
    4662:	cmp    rdi,rbx
    4665:	je     45e1 <mj__matrices__mulmatvec+0x361>
    466b:	add    rax,0x2
    466f:	vxorpd xmm1,xmm1,xmm1
    4673:	jmp    4621 <mj__matrices__mulmatvec+0x3a1>
    4675:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4680:	mov    rsi,QWORD PTR [rsp-0x30]
    4685:	add    rdx,r8
    4688:	lea    rdx,[rax+rdx*1+0x4]
    468d:	lea    rax,[rax+rsi*1+0x4]
    4692:	vmovupd ymm1,YMMWORD PTR [r15+rax*8]
    4698:	vmulpd ymm1,ymm1,YMMWORD PTR [r12+rdx*8]
    469e:	vaddpd ymm0,ymm1,ymm0
    46a2:	jmp    44b6 <mj__matrices__mulmatvec+0x236>
    46a7:	movsxd rbx,DWORD PTR [rsp-0x34]
    46ac:	test   r11d,r11d
    46af:	jle    45a7 <mj__matrices__mulmatvec+0x327>
    46b5:	movsxd r9,r10d
    46b8:	vxorpd xmm0,xmm0,xmm0
    46bc:	jmp    43fd <mj__matrices__mulmatvec+0x17d>
    46c1:	mov    rax,QWORD PTR [rsp-0x58]
    46c6:	dec    rax
    46c9:	mov    rdx,rax
    46cc:	sub    rdx,QWORD PTR [rsp-0x50]
    46d1:	sub    rax,r14
    46d4:	add    rax,r9
    46d7:	vmovsd xmm1,QWORD PTR [r15+rdx*8]
    46dd:	vmulsd xmm1,xmm1,QWORD PTR [r12+rax*8]
    46e3:	vaddsd xmm8,xmm8,xmm1
    46e7:	jmp    455a <mj__matrices__mulmatvec+0x2da>
    46ec:	mov    rdx,QWORD PTR [rsp-0x48]
    46f1:	mov    rcx,QWORD PTR [rsp-0x58]
    46f6:	sub    r10,rbx
    46f9:	vxorpd xmm1,xmm1,xmm1
    46fd:	shr    rdx,0x3
    4701:	mov    rax,rcx
    4704:	sub    rax,r14
    4707:	sub    rcx,QWORD PTR [rsp-0x50]
    470c:	imul   r10,rdx
    4710:	add    rax,r10
    4713:	vmovsd xmm0,QWORD PTR [r12+rax*8]
    4719:	vmulsd xmm0,xmm0,QWORD PTR [r15+rcx*8]
    471f:	vaddsd xmm0,xmm0,xmm1
    4723:	jmp    457e <mj__matrices__mulmatvec+0x2fe>
    4728:	mov    rdx,QWORD PTR [rsp-0x48]
    472d:	mov    rsi,QWORD PTR [rsp-0x58]
    4732:	mov    r9,QWORD PTR [rsp-0x50]
    4737:	sub    r10,rbx
    473a:	shr    rdx,0x3
    473e:	imul   r10,rdx
    4742:	lea    rax,[rsi-0x1]
    4746:	mov    rdx,rsi
    4749:	sub    rdx,r9
    474c:	mov    rcx,rax
    474f:	sub    rax,r14
    4752:	sub    rsi,r14
    4755:	sub    rcx,r9
    4758:	add    rax,r10
    475b:	vmovsd xmm0,QWORD PTR [r15+rcx*8]
    4761:	vmulsd xmm0,xmm0,QWORD PTR [r12+rax*8]
    4767:	lea    rax,[rsi+r10*1]
    476b:	vmovsd xmm1,QWORD PTR [r15+rdx*8]
    4771:	vmulsd xmm1,xmm1,QWORD PTR [r12+rax*8]
    4777:	vaddsd xmm0,xmm0,xmm1
    477b:	vxorpd xmm1,xmm1,xmm1
    477f:	vaddsd xmm0,xmm0,xmm1
    4783:	jmp    457e <mj__matrices__mulmatvec+0x2fe>
    4788:	mov    rcx,QWORD PTR [rsp-0x48]
    478d:	mov    r9,QWORD PTR [rsp-0x58]
    4792:	mov    r8,QWORD PTR [rsp-0x50]
    4797:	sub    r10,rbx
    479a:	shr    rcx,0x3
    479e:	imul   r10,rcx
    47a2:	lea    rdx,[r9-0x2]
    47a6:	lea    rax,[r9-0x1]
    47aa:	mov    rsi,rdx
    47ad:	sub    rdx,r14
    47b0:	sub    rsi,r8
    47b3:	add    rdx,r10
    47b6:	vmovsd xmm0,QWORD PTR [r15+rsi*8]
    47bc:	vmulsd xmm0,xmm0,QWORD PTR [r12+rdx*8]
    47c2:	mov    rdx,rax
    47c5:	sub    rdx,r8
    47c8:	sub    rax,r14
    47cb:	add    rax,r10
    47ce:	vmovsd xmm1,QWORD PTR [r15+rdx*8]
    47d4:	mov    rdx,r9
    47d7:	sub    rdx,r8
    47da:	vmulsd xmm1,xmm1,QWORD PTR [r12+rax*8]
    47e0:	sub    r9,r14
    47e3:	lea    rax,[r9+r10*1]
    47e7:	vaddsd xmm0,xmm0,xmm1
    47eb:	jmp    476b <mj__matrices__mulmatvec+0x4eb>
    47f0:	xor    ecx,ecx
    47f2:	jmp    4469 <mj__matrices__mulmatvec+0x1e9>
    47f7:	nop
    47f8:	nop    DWORD PTR [rax+rax*1+0x0]


<mj__matrices__mulvecmatvec>:
    4800:	push   rbp
    4801:	vxorpd xmm3,xmm3,xmm3
    4805:	mov    rbp,rsp
    4808:	push   r15
    480a:	push   r14
    480c:	push   r13
    480e:	push   r12
    4810:	push   rbx
    4811:	mov    r15,rdx
    4814:	and    rsp,0xffffffffffffffe0
    4818:	sub    rsp,0x8
    481c:	movsxd rax,DWORD PTR [rsi]
    481f:	mov    edx,DWORD PTR [rsi+0x4]
    4822:	cmp    eax,edx
    4824:	jg     4b9a <mj__matrices__mulvecmatvec+0x39a>
    482a:	movsxd rbx,DWORD PTR [rcx+0x8]
    482e:	movsxd r14,DWORD PTR [rcx+0xc]
    4832:	mov    esi,DWORD PTR [rcx]
    4834:	mov    r10,rdi
    4837:	mov    r13,r15
    483a:	vmovq  xmm9,r8
    483f:	mov    r12,rbx
    4842:	add    rbx,0x2
    4846:	mov    DWORD PTR [rsp-0x8],esi
    484a:	lea    rsi,[rax-0x1]
    484e:	mov    rcx,r14
    4851:	sub    rcx,r12
    4854:	mov    QWORD PTR [rsp],rbx
    4858:	mov    DWORD PTR [rsp-0x4],r14d
    485d:	lea    rbx,[rcx*8+0x8]
    4865:	xor    ecx,ecx
    4867:	cmp    r14d,r12d
    486a:	mov    r15,r12
    486d:	cmovge rcx,rbx
    4871:	mov    QWORD PTR [rsp-0x40],rbx
    4876:	mov    rbx,r14
    4879:	sub    rbx,r12
    487c:	lea    rdi,[rbx+0x1]
    4880:	mov    QWORD PTR [rsp-0x28],rcx
    4885:	neg    rax
    4888:	mov    QWORD PTR [rsp-0x50],rbx
    488d:	mov    rcx,rdi
    4890:	and    ecx,0x3
    4893:	lea    r11,[rdi*8+0x0]
    489b:	lea    rax,[r10+rax*8]
    489f:	mov    QWORD PTR [rsp-0x20],rcx
    48a4:	mov    rcx,rdi
    48a7:	sar    rcx,0x3f
    48ab:	vmovq  xmm6,rax
    48b0:	shr    rcx,0x3e
    48b4:	add    rdi,rcx
    48b7:	mov    QWORD PTR [rsp-0x78],r11
    48bc:	mov    r10d,r14d
    48bf:	sub    r10d,r12d
    48c2:	and    edi,0x3
    48c5:	inc    r10d
    48c8:	sub    rdi,rcx
    48cb:	movsxd rcx,edx
    48ce:	mov    QWORD PTR [rsp-0x70],rdi
    48d3:	movsxd rdi,DWORD PTR [r9]
    48d6:	mov    QWORD PTR [rsp-0x10],rcx
    48db:	shr    r11,0x3
    48df:	mov    QWORD PTR [rsp-0x58],r11
    48e4:	mov    rax,rbx
    48e7:	sub    rax,rdi
    48ea:	mov    rdx,rdi
    48ed:	sub    rbx,r12
    48f0:	mov    QWORD PTR [rsp-0x60],rax
    48f5:	neg    rdx
    48f8:	mov    eax,0x4
    48fd:	mov    QWORD PTR [rsp-0x48],rdi
    4902:	lea    rcx,[r8+rdx*8]
    4906:	sub    rax,rdi
    4909:	mov    QWORD PTR [rsp-0x68],rbx
    490e:	mov    QWORD PTR [rsp-0x18],rcx
    4913:	mov    QWORD PTR [rsp-0x38],rax
    4918:	sar    r10d,0x2
    491c:	dec    r10d
    491f:	nop
    4920:	inc    rsi
    4923:	movsxd r11,esi
    4926:	cmp    QWORD PTR [rsp],r14
    492a:	jge    4a30 <mj__matrices__mulvecmatvec+0x230>
    4930:	mov    rax,QWORD PTR [rsp-0x28]
    4935:	movsxd rbx,DWORD PTR [rsp-0x8]
    493a:	movsxd r9,esi
    493d:	mov    rdi,QWORD PTR [rsp-0x18]
    4942:	shr    rax,0x3
    4946:	mov    rdx,r9
    4949:	sub    rdx,rbx
    494c:	vmovupd ymm0,YMMWORD PTR [rdi]
    4950:	imul   rax,rdx
    4954:	sub    rax,r15
    4957:	vmulpd ymm0,ymm0,YMMWORD PTR [r13+rax*8+0x0]
    495e:	cmp    DWORD PTR [rsp-0x4],r12d
    4963:	jl     4b60 <mj__matrices__mulvecmatvec+0x360>
    4969:	test   r10d,r10d
    496c:	jg     4a50 <mj__matrices__mulvecmatvec+0x250>
    4972:	cmp    QWORD PTR [rsp-0x20],0x0
    4978:	je     4b60 <mj__matrices__mulvecmatvec+0x360>
    497e:	sub    r9,rbx
    4981:	imul   r9,QWORD PTR [rsp-0x58]
    4987:	mov    rax,QWORD PTR [rsp-0x68]
    498c:	mov    rcx,QWORD PTR [rsp-0x60]
    4991:	vmovq  rbx,xmm9
    4996:	vmovsd xmm7,QWORD PTR [rbx+rcx*8]
    499b:	add    rax,r9
    499e:	vmulsd xmm7,xmm7,QWORD PTR [r13+rax*8+0x0]
    49a5:	mov    rax,QWORD PTR [rsp-0x20]
    49aa:	cmp    rax,0x2
    49ae:	je     4c11 <mj__matrices__mulvecmatvec+0x411>
    49b4:	cmp    rax,0x3
    49b8:	jne    4a08 <mj__matrices__mulvecmatvec+0x208>
    49ba:	mov    rax,QWORD PTR [rsp-0x50]
    49bf:	mov    rbx,QWORD PTR [rsp-0x48]
    49c4:	vmovq  rdi,xmm9
    49c9:	lea    rdx,[rax-0x2]
    49cd:	dec    rax
    49d0:	mov    rcx,rdx
    49d3:	sub    rdx,r15
    49d6:	add    rdx,r9
    49d9:	sub    rcx,rbx
    49dc:	vmovsd xmm1,QWORD PTR [rdi+rcx*8]
    49e1:	vmulsd xmm1,xmm1,QWORD PTR [r13+rdx*8+0x0]
    49e8:	mov    rdx,rax
    49eb:	sub    rdx,rbx
    49ee:	sub    rax,r15
    49f1:	vmovsd xmm2,QWORD PTR [rdi+rdx*8]
    49f6:	add    rax,r9
    49f9:	vmulsd xmm2,xmm2,QWORD PTR [r13+rax*8+0x0]
    4a00:	vaddsd xmm1,xmm1,xmm2
    4a04:	vaddsd xmm7,xmm7,xmm1
    4a08:	vextractf64x2 xmm8,ymm0,0x1
    4a0f:	vunpckhpd xmm2,xmm0,xmm0
    4a13:	vaddsd xmm1,xmm0,xmm8
    4a18:	valignq ymm0,ymm0,ymm0,0x3
    4a1f:	vaddsd xmm0,xmm2,xmm0
    4a23:	vaddsd xmm0,xmm1,xmm0
    4a27:	vaddsd xmm0,xmm0,xmm7
    4a2b:	jmp    4b7e <mj__matrices__mulvecmatvec+0x37e>
    4a30:	cmp    DWORD PTR [rsp-0x4],r12d
    4a35:	jl     4bd0 <mj__matrices__mulvecmatvec+0x3d0>
    4a3b:	movsxd rbx,DWORD PTR [rsp-0x8]
    4a40:	test   r10d,r10d
    4a43:	jle    4bad <mj__matrices__mulvecmatvec+0x3ad>
    4a49:	movsxd r9,r11d
    4a4c:	vxorpd xmm0,xmm0,xmm0
    4a50:	mov    r8,QWORD PTR [rsp-0x40]
    4a55:	shr    r8,0x3
    4a59:	cmp    r10d,0x2
    4a5d:	jle    4d4f <mj__matrices__mulvecmatvec+0x54f>
    4a63:	mov    rax,r9
    4a66:	sub    rax,rbx
    4a69:	lea    edi,[r10-0x3]
    4a6d:	xor    ecx,ecx
    4a6f:	imul   rax,r8
    4a73:	and    edi,0xfffffffe
    4a76:	add    edi,0x2
    4a79:	sub    rax,r15
    4a7c:	lea    rdx,[r13+rax*8+0x20]
    4a81:	mov    rax,QWORD PTR [rsp-0x18]
    4a86:	nop    DWORD PTR [rax]
    4a89:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4a94:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4a9f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4aaa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4ab5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4ac0:	vmovupd ymm1,YMMWORD PTR [rax+0x20]
    4ac5:	vmulpd ymm1,ymm1,YMMWORD PTR [rdx]
    4ac9:	add    ecx,0x2
    4acc:	add    rax,0x40
    4ad0:	add    rdx,0x40
    4ad4:	vaddpd ymm0,ymm1,ymm0
    4ad8:	vmovupd ymm1,YMMWORD PTR [rax]
    4adc:	vmulpd ymm1,ymm1,YMMWORD PTR [rdx-0x20]
    4ae1:	vaddpd ymm0,ymm0,ymm1
    4ae5:	cmp    edi,ecx
    4ae7:	jne    4ac0 <mj__matrices__mulvecmatvec+0x2c0>
    4ae9:	mov    rdx,r9
    4aec:	sub    rdx,rbx
    4aef:	mov    eax,ecx
    4af1:	inc    ecx
    4af3:	imul   rdx,r8
    4af7:	mov    r8d,0x4
    4afd:	shl    rax,0x2
    4b01:	sub    r8,r15
    4b04:	mov    rdi,rdx
    4b07:	add    rdi,rax
    4b0a:	vmovq  xmm5,rdx
    4b0f:	add    rdi,r8
    4b12:	vmovq  rdx,xmm9
    4b17:	mov    QWORD PTR [rsp-0x30],rdi
    4b1c:	mov    rdi,QWORD PTR [rsp-0x38]
    4b21:	add    rdi,rax
    4b24:	vmovupd ymm1,YMMWORD PTR [rdx+rdi*8]
    4b29:	mov    rdi,QWORD PTR [rsp-0x30]
    4b2e:	vmulpd ymm1,ymm1,YMMWORD PTR [r13+rdi*8+0x0]
    4b35:	vaddpd ymm0,ymm1,ymm0
    4b39:	cmp    ecx,r10d
    4b3c:	jne    4be0 <mj__matrices__mulvecmatvec+0x3e0>
    4b42:	cmp    QWORD PTR [rsp],r14
    4b46:	jge    4bad <mj__matrices__mulvecmatvec+0x3ad>
    4b48:	cmp    DWORD PTR [rsp-0x4],r12d
    4b4d:	jge    4972 <mj__matrices__mulvecmatvec+0x172>
    4b53:	xchg   ax,ax
    4b55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4b60:	vextractf64x2 xmm7,ymm0,0x1
    4b67:	vunpckhpd xmm2,xmm0,xmm0
    4b6b:	vaddsd xmm1,xmm0,xmm7
    4b6f:	valignq ymm0,ymm0,ymm0,0x3
    4b76:	vaddsd xmm2,xmm2,xmm0
    4b7a:	vaddsd xmm0,xmm1,xmm2
    4b7e:	vmovq  rax,xmm6
    4b83:	vmulsd xmm0,xmm0,QWORD PTR [rax+rsi*8]
    4b88:	vaddsd xmm3,xmm3,xmm0
    4b8c:	cmp    QWORD PTR [rsp-0x10],rsi
    4b91:	jne    4920 <mj__matrices__mulvecmatvec+0x120>
    4b97:	vzeroupper
    4b9a:	vmovapd xmm0,xmm3
    4b9e:	lea    rsp,[rbp-0x28]
    4ba2:	pop    rbx
    4ba3:	pop    r12
    4ba5:	pop    r13
    4ba7:	pop    r14
    4ba9:	pop    r15
    4bab:	pop    rbp
    4bac:	ret
    4bad:	mov    rax,QWORD PTR [rsp-0x70]
    4bb2:	cmp    rax,0x2
    4bb6:	je     4c7d <mj__matrices__mulvecmatvec+0x47d>
    4bbc:	cmp    rax,0x3
    4bc0:	je     4ce2 <mj__matrices__mulvecmatvec+0x4e2>
    4bc6:	cmp    rax,0x1
    4bca:	je     4c3c <mj__matrices__mulvecmatvec+0x43c>
    4bcc:	nop    DWORD PTR [rax+0x0]
    4bd0:	vxorpd xmm0,xmm0,xmm0
    4bd4:	jmp    4b7e <mj__matrices__mulvecmatvec+0x37e>
    4bd6:	cs nop WORD PTR [rax+rax*1+0x0]
    4be0:	mov    rdi,QWORD PTR [rsp-0x38]
    4be5:	vmovq  rcx,xmm5
    4bea:	lea    rdx,[rax+rcx*1+0x4]
    4bef:	add    rdx,r8
    4bf2:	lea    rax,[rax+rdi*1+0x4]
    4bf7:	vmovq  rdi,xmm9
    4bfc:	vmovupd ymm1,YMMWORD PTR [rdi+rax*8]
    4c01:	vmulpd ymm1,ymm1,YMMWORD PTR [r13+rdx*8+0x0]
    4c08:	vaddpd ymm0,ymm1,ymm0
    4c0c:	jmp    4b42 <mj__matrices__mulvecmatvec+0x342>
    4c11:	mov    rax,QWORD PTR [rsp-0x50]
    4c16:	dec    rax
    4c19:	mov    rdx,rax
    4c1c:	sub    rdx,QWORD PTR [rsp-0x48]
    4c21:	sub    rax,r15
    4c24:	add    rax,r9
    4c27:	vmovsd xmm1,QWORD PTR [rbx+rdx*8]
    4c2c:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*8+0x0]
    4c33:	vaddsd xmm7,xmm7,xmm1
    4c37:	jmp    4a08 <mj__matrices__mulvecmatvec+0x208>
    4c3c:	mov    rdx,QWORD PTR [rsp-0x78]
    4c41:	mov    rcx,QWORD PTR [rsp-0x50]
    4c46:	sub    r11,rbx
    4c49:	vxorpd xmm1,xmm1,xmm1
    4c4d:	shr    rdx,0x3
    4c51:	mov    rax,rcx
    4c54:	sub    rax,r15
    4c57:	sub    rcx,QWORD PTR [rsp-0x48]
    4c5c:	imul   r11,rdx
    4c60:	add    rax,r11
    4c63:	vmovsd xmm0,QWORD PTR [r13+rax*8+0x0]
    4c6a:	vmovq  rax,xmm9
    4c6f:	vmulsd xmm0,xmm0,QWORD PTR [rax+rcx*8]
    4c74:	vaddsd xmm0,xmm0,xmm1
    4c78:	jmp    4b7e <mj__matrices__mulvecmatvec+0x37e>
    4c7d:	mov    rdx,QWORD PTR [rsp-0x78]
    4c82:	mov    rdi,QWORD PTR [rsp-0x50]
    4c87:	mov    r9,QWORD PTR [rsp-0x48]
    4c8c:	sub    r11,rbx
    4c8f:	vmovq  rbx,xmm9
    4c94:	shr    rdx,0x3
    4c98:	imul   r11,rdx
    4c9c:	lea    rax,[rdi-0x1]
    4ca0:	mov    rdx,rdi
    4ca3:	sub    rdx,r9
    4ca6:	mov    rcx,rax
    4ca9:	sub    rax,r15
    4cac:	sub    rdi,r15
    4caf:	sub    rcx,r9
    4cb2:	add    rax,r11
    4cb5:	vmovsd xmm0,QWORD PTR [rbx+rcx*8]
    4cba:	vmulsd xmm0,xmm0,QWORD PTR [r13+rax*8+0x0]
    4cc1:	lea    rax,[rdi+r11*1]
    4cc5:	vmovsd xmm1,QWORD PTR [rbx+rdx*8]
    4cca:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*8+0x0]
    4cd1:	vaddsd xmm0,xmm0,xmm1
    4cd5:	vxorpd xmm1,xmm1,xmm1
    4cd9:	vaddsd xmm0,xmm0,xmm1
    4cdd:	jmp    4b7e <mj__matrices__mulvecmatvec+0x37e>
    4ce2:	mov    rcx,QWORD PTR [rsp-0x78]
    4ce7:	mov    r9,QWORD PTR [rsp-0x50]
    4cec:	mov    r8,QWORD PTR [rsp-0x48]
    4cf1:	sub    r11,rbx
    4cf4:	vmovq  rbx,xmm9
    4cf9:	shr    rcx,0x3
    4cfd:	imul   r11,rcx
    4d01:	lea    rdx,[r9-0x2]
    4d05:	lea    rax,[r9-0x1]
    4d09:	mov    rdi,rdx
    4d0c:	sub    rdx,r15
    4d0f:	sub    rdi,r8
    4d12:	add    rdx,r11
    4d15:	vmovsd xmm0,QWORD PTR [rbx+rdi*8]
    4d1a:	vmulsd xmm0,xmm0,QWORD PTR [r13+rdx*8+0x0]
    4d21:	mov    rdx,rax
    4d24:	sub    rdx,r8
    4d27:	sub    rax,r15
    4d2a:	add    rax,r11
    4d2d:	vmovsd xmm1,QWORD PTR [rbx+rdx*8]
    4d32:	mov    rdx,r9
    4d35:	sub    rdx,r8
    4d38:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*8+0x0]
    4d3f:	sub    r9,r15
    4d42:	lea    rax,[r9+r11*1]
    4d46:	vaddsd xmm0,xmm0,xmm1
    4d4a:	jmp    4cc5 <mj__matrices__mulvecmatvec+0x4c5>
    4d4f:	xor    ecx,ecx
    4d51:	jmp    4ae9 <mj__matrices__mulvecmatvec+0x2e9>
    4d56:	cs nop WORD PTR [rax+rax*1+0x0]


<mj__matrices__symmetrize>:
    4d60:	sub    rsp,0x30
    4d64:	movsxd r11,DWORD PTR [rcx+0x8]
    4d68:	movsxd rax,DWORD PTR [rcx+0xc]
    4d6c:	mov    r10d,DWORD PTR [rsi+0x4]
    4d70:	mov    QWORD PTR [rsp+0x28],r15
    4d75:	mov    r15,rdx
    4d78:	mov    QWORD PTR [rsp],rbx
    4d7c:	xor    ebx,ebx
    4d7e:	mov    QWORD PTR [rsp+0x20],r14
    4d83:	mov    r14d,DWORD PTR [rsi]
    4d86:	mov    rdx,rax
    4d89:	sub    rax,r11
    4d8c:	mov    QWORD PTR [rsp-0x30],r11
    4d91:	cmp    r11d,edx
    4d94:	lea    rax,[rax*8+0x8]
    4d9c:	cmovg  rax,rbx
    4da0:	mov    DWORD PTR [rsp-0x14],r14d
    4da5:	mov    QWORD PTR [rsp-0x10],rax
    4daa:	mov    r9,rax
    4dad:	movsxd rax,DWORD PTR [rsi+0x8]
    4db1:	mov    r8,rax
    4db4:	vmovq  xmm1,rax
    4db9:	movsxd rax,DWORD PTR [rsi+0xc]
    4dbd:	mov    rdx,rax
    4dc0:	sub    rax,r8
    4dc3:	lea    rax,[rax*8+0x8]
    4dcb:	cmp    r8d,edx
    4dce:	cmovle rbx,rax
    4dd2:	cmp    r14d,r10d
    4dd5:	jg     4f4f <mj__matrices__symmetrize+0x1ef>
    4ddb:	vmovq  rax,xmm1
    4de0:	mov    QWORD PTR [rsp+0x18],r13
    4de5:	movsxd r13,r14d
    4de8:	movsxd r14,DWORD PTR [rcx]
    4deb:	lea    rdx,[r13-0x1]
    4def:	mov    QWORD PTR [rsp+0x8],rbp
    4df4:	mov    r8,rbx
    4df7:	shr    r8,0x3
    4dfb:	shl    rax,0x3
    4dff:	mov    rcx,rdi
    4e02:	sub    rcx,rax
    4e05:	mov    rax,r11
    4e08:	vmovsd xmm5,QWORD PTR [rip+0x32d48]        # 37b58 <system__os_lib__standin+0xc>
    4e10:	neg    rax
    4e13:	mov    QWORD PTR [rsp+0x10],r12
    4e18:	mov    QWORD PTR [rsp-0x8],rdx
    4e1d:	mov    QWORD PTR [rsp-0x28],rbx
    4e22:	lea    rax,[r15+rax*8]
    4e26:	movsxd rbp,r10d
    4e29:	vmovq  xmm7,rax
    4e2e:	mov    rax,r15
    4e31:	mov    r15,r13
    4e34:	shr    r9,0x3
    4e38:	mov    r13,rax
    4e3b:	jmp    4e53 <mj__matrices__symmetrize+0xf3>
    4e3d:	nop    DWORD PTR [rax]
    4e40:	mov    rbp,QWORD PTR [rsp-0x20]
    4e45:	add    rcx,QWORD PTR [rsp-0x28]
    4e4a:	cmp    rbp,rdx
    4e4d:	je     4f40 <mj__matrices__symmetrize+0x1e0>
    4e53:	inc    rdx
    4e56:	mov    rsi,rdx
    4e59:	sub    rsi,QWORD PTR [rsp-0x30]
    4e5e:	mov    rax,rdx
    4e61:	sub    rax,r14
    4e64:	imul   rax,r9
    4e68:	add    rax,rsi
    4e6b:	mov    rsi,rdx
    4e6e:	vmovsd xmm0,QWORD PTR [r13+rax*8+0x0]
    4e75:	vmovq  rax,xmm1
    4e7a:	sub    rsi,rax
    4e7d:	mov    rax,rdx
    4e80:	sub    rax,r15
    4e83:	imul   rax,r8
    4e87:	add    rax,rsi
    4e8a:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    4e8f:	cmp    edx,0x1
    4e92:	js     4e45 <mj__matrices__symmetrize+0xe5>
    4e94:	movsxd r11,edx
    4e97:	mov    ebx,DWORD PTR [rsp-0x14]
    4e9b:	mov    eax,edx
    4e9d:	sub    eax,DWORD PTR [rsp-0x8]
    4ea1:	mov    r10,r11
    4ea4:	sub    r10,r14
    4ea7:	imul   r10,QWORD PTR [rsp-0x10]
    4ead:	sub    r11,QWORD PTR [rsp-0x30]
    4eb2:	mov    QWORD PTR [rsp-0x20],rbp
    4eb7:	lea    ebx,[rbx+rax*1-0x2]
    4ebb:	vmovq  rax,xmm7
    4ec0:	add    r10,rax
    4ec3:	xor    eax,eax
    4ec5:	jmp    4f0f <mj__matrices__symmetrize+0x1af>
    4ec7:	nop    WORD PTR [rax+rax*1+0x0]
    4ed0:	sub    r12,r14
    4ed3:	imul   r12,r9
    4ed7:	add    r12,r11
    4eda:	vmovsd xmm0,QWORD PTR [r13+r12*8+0x0]
    4ee1:	vaddsd xmm0,xmm0,QWORD PTR [r10+rax*8]
    4ee7:	vmulsd xmm0,xmm0,xmm5
    4eeb:	mov    r12,rax
    4eee:	sub    r12,r15
    4ef1:	vmovsd QWORD PTR [rcx+rax*8],xmm0
    4ef6:	imul   r12,r8
    4efa:	add    r12,rsi
    4efd:	vmovsd QWORD PTR [rdi+r12*8],xmm0
    4f03:	cmp    rax,rbx
    4f06:	je     4e40 <mj__matrices__symmetrize+0xe0>
    4f0c:	inc    rax
    4f0f:	mov    r12,rax
    4f12:	cmp    eax,edx
    4f14:	jne    4ed0 <mj__matrices__symmetrize+0x170>
    4f16:	mov    rbp,QWORD PTR [rsp-0x30]
    4f1b:	sub    r12,rbp
    4f1e:	mov    rbp,r12
    4f21:	mov    r12,rax
    4f24:	sub    r12,r14
    4f27:	imul   r12,r9
    4f2b:	add    r12,rbp
    4f2e:	vmovsd xmm0,QWORD PTR [r13+r12*8+0x0]
    4f35:	jmp    4eeb <mj__matrices__symmetrize+0x18b>
    4f37:	nop    WORD PTR [rax+rax*1+0x0]
    4f40:	mov    rbp,QWORD PTR [rsp+0x8]
    4f45:	mov    r12,QWORD PTR [rsp+0x10]
    4f4a:	mov    r13,QWORD PTR [rsp+0x18]
    4f4f:	mov    rbx,QWORD PTR [rsp]
    4f53:	mov    r14,QWORD PTR [rsp+0x20]
    4f58:	mov    r15,QWORD PTR [rsp+0x28]
    4f5d:	add    rsp,0x30
    4f61:	ret
    4f62:	nop    DWORD PTR [rax]
    4f65:	data16 cs nop WORD PTR [rax+rax*1+0x0]

