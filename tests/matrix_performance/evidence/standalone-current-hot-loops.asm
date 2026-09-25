<bench_ada__run_1.isra.0>:
    4140:	push   rbp
    4141:	mov    r10,rdx
    4144:	mov    rbp,rsp
    4147:	push   rbx
    4148:	sub    rsp,0x8
    414c:	mov    rdx,QWORD PTR [rbp+0x10]
    4150:	mov    rbx,QWORD PTR [rbp+0x18]
    4154:	test   edi,edi
    4156:	je     418e <bench_ada__run_1.isra.0+0x4e>
    4158:	mov    rax,rsi
    415b:	mov    r11d,edi
    415e:	xor    esi,esi
    4160:	inc    esi
    4162:	vmovdqu64 zmm0,ZMMWORD PTR [rax]
    4168:	mov    rdi,QWORD PTR [rax+0x40]
    416c:	mov    QWORD PTR [rsp-0x10],rdi
    4171:	vmovdqu64 ZMMWORD PTR [rdx],zmm0
    4177:	mov    QWORD PTR [rdx+0x40],rdi
    417b:	vmovdqu64 ZMMWORD PTR [rsp-0x50],zmm0
    4186:	cmp    r11d,esi
    4189:	jne    4160 <bench_ada__run_1.isra.0+0x20>
    418b:	vzeroupper
    418e:	add    rsp,0x8
    4192:	pop    rbx
    4193:	pop    rbp
    4194:	ret
    4195:	nop
    4196:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_10.isra.0>:
    4e50:	push   rbp
    4e51:	mov    rbp,rsp
    4e54:	push   r15
    4e56:	push   r14
    4e58:	push   r13
    4e5a:	push   r12
    4e5c:	push   rbx
    4e5d:	and    rsp,0xffffffffffffffc0
    4e61:	sub    rsp,0x8
    4e65:	mov    rbx,QWORD PTR [rbp+0x10]
    4e69:	mov    DWORD PTR [rsp-0x4],edi
    4e6d:	mov    DWORD PTR [rsp-0x20],esi
    4e71:	mov    DWORD PTR [rsp-0x8],edx
    4e75:	mov    r14,QWORD PTR [rbp+0x20]
    4e79:	test   edx,edx
    4e7b:	je     4f03 <bench_ada__run_10.isra.0+0xb3>
    4e81:	mov    eax,esi
    4e83:	lea    edx,[rdi-0x1]
    4e86:	mov    r12,rcx
    4e89:	mov    ecx,edi
    4e8b:	mov    edi,eax
    4e8d:	mov    DWORD PTR [rsp-0x1c],edx
    4e91:	mov    r15,QWORD PTR [rbp+0x18]
    4e95:	mov    r11,QWORD PTR [rbp+0x28]
    4e99:	mov    rsi,r9
    4e9c:	lea    eax,[rdi-0x1]
    4e9f:	cmp    eax,0xffffffff
    4ea2:	je     5860 <bench_ada__run_10.isra.0+0xa10>
    4ea8:	inc    edx
    4eaa:	je     5860 <bench_ada__run_10.isra.0+0xa10>
    4eb0:	mov    DWORD PTR [rsp-0x18],0x1
    4eb8:	mov    QWORD PTR [rsp-0x28],rax
    4ebd:	mov    eax,ecx
    4ebf:	mov    QWORD PTR [rsp-0x10],rdi
    4ec4:	mov    QWORD PTR [rsp],rax
    4ec8:	lea    rax,[rip+0x2c731]        # 31600 <_fini+0x14>
    4ecf:	lea    r13,[rdi*8+0x0]
    4ed7:	mov    rcx,rbx
    4eda:	vmovq  xmm3,rax
    4edf:	mov    rdi,r8
    4ee2:	cmp    DWORD PTR [rsp-0x4],0x40
    4ee7:	ja     4f12 <bench_ada__run_10.isra.0+0xc2>
    4ee9:	mov    rbx,QWORD PTR [rsp]
    4eed:	vmovq  rax,xmm3
    4ef2:	movsxd rax,DWORD PTR [rax+rbx*4]
    4ef6:	vmovq  rbx,xmm3
    4efb:	add    rax,rbx
    4efe:	jmp    rax
    4f00:	vzeroupper
    4f03:	lea    rsp,[rbp-0x28]
    4f07:	pop    rbx
    4f08:	pop    r12
    4f0a:	pop    r13
    4f0c:	pop    r14
    4f0e:	pop    r15
    4f10:	pop    rbp
    4f11:	ret
    4f12:	mov    rdx,QWORD PTR [rsp]
    4f16:	mov    r15,r13
    4f19:	shr    r15,0x3
    4f1d:	mov    ebx,DWORD PTR [rsp-0x1c]
    4f21:	mov    QWORD PTR [rsp-0x30],rdi
    4f26:	mov    QWORD PTR [rsp-0x38],rsi
    4f2b:	mov    QWORD PTR [rbp+0x10],rcx
    4f2f:	lea    rax,[rdx*8+0x0]
    4f37:	mov    r9,r14
    4f3a:	vmovq  xmm1,rax
    4f3f:	lea    rax,[rdx-0x1]
    4f43:	mov    r10,r12
    4f46:	xor    r8d,r8d
    4f49:	imul   rax,r15
    4f4d:	vmovq  rcx,xmm1
    4f52:	shr    rdx,1
    4f55:	vmovq  xmm2,rax
    4f5a:	vmovq  rax,xmm1
    4f5f:	mov    r11,rdx
    4f62:	sub    rax,0x8
    4f66:	mov    rsi,rax
    4f69:	nop    DWORD PTR [rax+0x0]
    4f70:	lea    rax,[rsi+r9*1]
    4f74:	cmp    rax,r10
    4f77:	jb     4f8b <bench_ada__run_10.isra.0+0x13b>
    4f79:	vmovq  rax,xmm2
    4f7e:	lea    rax,[r10+rax*8]
    4f82:	cmp    rax,r9
    4f85:	jae    5600 <bench_ada__run_10.isra.0+0x7b0>
    4f8b:	mov    rax,r10
    4f8e:	mov    rdi,r9
    4f91:	xor    edx,edx
    4f93:	vmovsd xmm0,QWORD PTR [rax]
    4f97:	vmovhpd xmm0,xmm0,QWORD PTR [r13+rax*1+0x0]
    4f9e:	inc    rdx
    4fa1:	add    rdi,0x10
    4fa5:	lea    rax,[rax+r13*2]
    4fa9:	vmovupd XMMWORD PTR [rdi-0x10],xmm0
    4fae:	cmp    rdx,r11
    4fb1:	jb     4f93 <bench_ada__run_10.isra.0+0x143>
    4fb3:	mov    rdi,QWORD PTR [rsp]
    4fb7:	lea    rdx,[r11+r11*1]
    4fbb:	cmp    rdx,rdi
    4fbe:	je     4fe0 <bench_ada__run_10.isra.0+0x190>
    4fc0:	mov    rax,rdx
    4fc3:	imul   rax,r15
    4fc7:	add    rax,r8
    4fca:	vmovsd xmm0,QWORD PTR [r12+rax*8]
    4fd0:	mov    rax,rdi
    4fd3:	imul   rax,r8
    4fd7:	add    rax,rdx
    4fda:	vmovsd QWORD PTR [r14+rax*8],xmm0
    4fe0:	inc    r8
    4fe3:	add    r9,rcx
    4fe6:	add    r10,0x8
    4fea:	cmp    QWORD PTR [rsp-0x10],r8
    4fef:	jne    4f70 <bench_ada__run_10.isra.0+0x120>
    4ff5:	mov    rdi,QWORD PTR [rsp-0x30]
    4ffa:	mov    rsi,QWORD PTR [rsp-0x38]
    4fff:	mov    rcx,QWORD PTR [rbp+0x10]
    5003:	mov    rax,QWORD PTR [rbp+0x18]
    5007:	mov    rbx,QWORD PTR [rbp+0x28]
    500b:	mov    eax,DWORD PTR [rsp-0x18]
    500f:	cmp    DWORD PTR [rsp-0x8],eax
    5013:	je     4f00 <bench_ada__run_10.isra.0+0xb0>
    5019:	inc    eax
    501b:	mov    rbx,QWORD PTR [rbp+0x28]
    501f:	mov    DWORD PTR [rsp-0x18],eax
    5023:	mov    rax,QWORD PTR [rbp+0x18]
    5027:	jmp    4ee2 <bench_ada__run_10.isra.0+0x92>
    502c:	mov    rdx,r13
    502f:	shr    rdx,0x3
    5033:	mov    r8d,DWORD PTR [rsp-0x4]
    5038:	imul   rax,rdx,0x6
    503c:	mov    ebx,DWORD PTR [rsp-0x1c]
    5040:	mov    QWORD PTR [rsp-0x30],rdi
    5045:	mov    r9,QWORD PTR [rsp-0x10]
    504a:	mov    r10,r13
    504d:	vmovq  xmm7,rax
    5052:	imul   rax,rdx,0x7
    5056:	sar    r8d,1
    5059:	vmovq  xmm1,rax
    505e:	dec    r8d
    5061:	imul   r15,rdx,0xa
    5065:	lea    rdi,[rdx+rdx*4]
    5069:	lea    r11,[rdx+rdx*8]
    506d:	mov    QWORD PTR [rbp+0x10],rcx
    5071:	xor    eax,eax
    5073:	mov    rcx,rbx
    5076:	lea    r13,[rdx+rdx*2]
    507a:	mov    ebx,r8d
    507d:	vmovq  xmm4,rdi
    5082:	mov    r8,rdx
    5085:	vmovq  xmm5,r11
    508a:	vmovq  xmm2,r15
    508f:	vmovq  r15,xmm7
    5094:	lea    r11,[r8+r8*1]
    5098:	mov    rdx,QWORD PTR [rsp]
    509c:	vmovsd xmm0,QWORD PTR [r12+rax*8]
    50a2:	lea    rdi,[r8+rax*1]
    50a6:	imul   rdx,rax
    50aa:	vmovsd QWORD PTR [r14+rdx*8],xmm0
    50b0:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    50b6:	lea    rdi,[r11+rax*1]
    50ba:	vmovsd QWORD PTR [r14+rdx*8+0x8],xmm0
    50c1:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    50c7:	lea    rdi,[r13+rax*1+0x0]
    50cc:	vmovsd QWORD PTR [r14+rdx*8+0x10],xmm0
    50d3:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    50d9:	lea    rdi,[rax+r8*4]
    50dd:	vmovsd QWORD PTR [r14+rdx*8+0x18],xmm0
    50e4:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    50ea:	vmovq  rdi,xmm4
    50ef:	add    rdi,rax
    50f2:	vmovsd QWORD PTR [r14+rdx*8+0x20],xmm0
    50f9:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    50ff:	vmovsd QWORD PTR [r14+rdx*8+0x28],xmm0
    5106:	cmp    ebx,0x2
    5109:	je     51bf <bench_ada__run_10.isra.0+0x36f>
    510f:	lea    rdi,[r15+rax*1]
    5113:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    5119:	vmovq  rdi,xmm1
    511e:	add    rdi,rax
    5121:	vmovsd QWORD PTR [r14+rdx*8+0x30],xmm0
    5128:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    512e:	vmovsd QWORD PTR [r14+rdx*8+0x38],xmm0
    5135:	cmp    ebx,0x3
    5138:	je     51bf <bench_ada__run_10.isra.0+0x36f>
    513e:	lea    rdi,[rax+r8*8]
    5142:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    5148:	vmovq  rdi,xmm5
    514d:	add    rdi,rax
    5150:	vmovsd QWORD PTR [r14+rdx*8+0x40],xmm0
    5157:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    515d:	vmovsd QWORD PTR [r14+rdx*8+0x48],xmm0
    5164:	cmp    ebx,0x4
    5167:	je     51bf <bench_ada__run_10.isra.0+0x36f>
    5169:	vmovq  rdi,xmm2
    516e:	add    rdi,rax
    5171:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    5177:	imul   rdi,r8,0xb
    517b:	add    rdi,rax
    517e:	vmovsd QWORD PTR [r14+rdx*8+0x50],xmm0
    5185:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    518b:	vmovsd QWORD PTR [r14+rdx*8+0x58],xmm0
    5192:	cmp    ebx,0x5
    5195:	je     51bf <bench_ada__run_10.isra.0+0x36f>
    5197:	imul   rdi,r8,0xc
    519b:	add    rdi,rax
    519e:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    51a4:	imul   rdi,r8,0xd
    51a8:	add    rdi,rax
    51ab:	vmovsd QWORD PTR [r14+rdx*8+0x60],xmm0
    51b2:	vmovsd xmm0,QWORD PTR [r12+rdi*8]
    51b8:	vmovsd QWORD PTR [r14+rdx*8+0x68],xmm0
    51bf:	test   BYTE PTR [rsp-0x4],0x1
    51c4:	je     5400 <bench_ada__run_10.isra.0+0x5b0>
    51ca:	mov    rdx,rcx
    51cd:	imul   rdx,r8
    51d1:	add    rdx,rax
    51d4:	vmovsd xmm0,QWORD PTR [r12+rdx*8]
    51da:	mov    rdx,QWORD PTR [rsp]
    51de:	imul   rdx,rax
    51e2:	inc    rax
    51e5:	add    rdx,rcx
    51e8:	vmovsd QWORD PTR [r14+rdx*8],xmm0
    51ee:	cmp    rax,r9
    51f1:	jne    5094 <bench_ada__run_10.isra.0+0x244>
    51f7:	mov    rdx,r8
    51fa:	mov    rdi,QWORD PTR [rsp-0x30]
    51ff:	mov    r8d,ebx
    5202:	mov    rax,QWORD PTR [rbp+0x18]
    5206:	mov    rbx,rcx
    5209:	mov    r15,QWORD PTR [rbp+0x28]
    520d:	mov    rcx,QWORD PTR [rbp+0x10]
    5211:	mov    eax,DWORD PTR [rsp-0x18]
    5215:	cmp    DWORD PTR [rsp-0x8],eax
    5219:	je     4f00 <bench_ada__run_10.isra.0+0xb0>
    521f:	inc    eax
    5221:	mov    r15,QWORD PTR [rbp+0x28]
    5225:	mov    DWORD PTR [rsp-0x18],eax
    5229:	mov    rax,QWORD PTR [rbp+0x18]
    522d:	jmp    5061 <bench_ada__run_10.isra.0+0x211>
    5232:	mov    edx,DWORD PTR [rsp-0x20]
    5236:	mov    rax,QWORD PTR [rsp]
    523a:	mov    r8,r13
    523d:	shr    r8,0x3
    5241:	cmp    DWORD PTR [rsp-0x4],edx
    5245:	mov    rdx,QWORD PTR [rsp]
    5249:	mov    ebx,DWORD PTR [rsp-0x1c]
    524d:	lea    rax,[rax*8+0x0]
    5255:	vmovq  xmm5,rax
    525a:	lea    rax,[rdx-0x1]
    525e:	je     5419 <bench_ada__run_10.isra.0+0x5c9>
    5264:	imul   rax,r8
    5268:	mov    QWORD PTR [rsp-0x30],rdi
    526d:	mov    QWORD PTR [rsp-0x38],rsi
    5272:	mov    QWORD PTR [rbp+0x10],rcx
    5276:	mov    QWORD PTR [rsp-0x40],rbx
    527b:	mov    r11,r12
    527e:	mov    r9,r14
    5281:	xor    r10d,r10d
    5284:	vmovq  rcx,xmm5
    5289:	vmovq  xmm1,rax
    528e:	vmovq  rax,xmm5
    5293:	shr    rdx,1
    5296:	vmovq  rsi,xmm1
    529b:	sub    rax,0x8
    529f:	mov    r15,rdx
    52a2:	mov    rbx,rax
    52a5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    52b0:	lea    rax,[rbx+r9*1]
    52b4:	cmp    rax,r11
    52b7:	jb     52c6 <bench_ada__run_10.isra.0+0x476>
    52b9:	lea    rax,[r11+rsi*8]
    52bd:	cmp    rax,r9
    52c0:	jae    562a <bench_ada__run_10.isra.0+0x7da>
    52c6:	mov    rdi,r9
    52c9:	mov    rax,r11
    52cc:	xor    edx,edx
    52ce:	vmovsd xmm0,QWORD PTR [rax]
    52d2:	vmovhpd xmm0,xmm0,QWORD PTR [r13+rax*1+0x0]
    52d9:	inc    rdx
    52dc:	lea    rax,[rax+r13*2]
    52e0:	add    rdi,0x10
    52e4:	vmovupd XMMWORD PTR [rdi-0x10],xmm0
    52e9:	cmp    rdx,r15
    52ec:	jb     52ce <bench_ada__run_10.isra.0+0x47e>
    52ee:	lea    rdx,[r15+r15*1]
    52f2:	cmp    QWORD PTR [rsp],rdx
    52f6:	je     5319 <bench_ada__run_10.isra.0+0x4c9>
    52f8:	mov    rax,r8
    52fb:	imul   rax,rdx
    52ff:	add    rax,r10
    5302:	vmovsd xmm0,QWORD PTR [r12+rax*8]
    5308:	mov    rax,QWORD PTR [rsp]
    530c:	imul   rax,r10
    5310:	add    rax,rdx
    5313:	vmovsd QWORD PTR [r14+rax*8],xmm0
    5319:	inc    r10
    531c:	add    r9,rcx
    531f:	add    r11,0x8
    5323:	cmp    QWORD PTR [rsp-0x10],r10
    5328:	jne    52b0 <bench_ada__run_10.isra.0+0x460>
    532a:	jmp    4ff5 <bench_ada__run_10.isra.0+0x1a5>
    532f:	mov    rbx,QWORD PTR [rsp-0x10]
    5334:	lea    r8,[r12+r13*1]
    5338:	mov    rdx,r14
    533b:	xor    eax,eax
    533d:	lea    r10,[r8+r13*1]
    5341:	lea    r9,[r13+r10*1+0x0]
    5346:	lea    r11,[r13+r9*1+0x0]
    534b:	nop    DWORD PTR [rax+rax*1+0x0]
    5350:	vmovsd xmm0,QWORD PTR [r12+rax*8]
    5356:	add    rdx,0x28
    535a:	vmovsd QWORD PTR [rdx-0x28],xmm0
    535f:	vmovsd xmm0,QWORD PTR [r8+rax*8]
    5365:	vmovsd QWORD PTR [rdx-0x20],xmm0
    536a:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    5370:	vmovsd QWORD PTR [rdx-0x18],xmm0
    5375:	vmovsd xmm0,QWORD PTR [r9+rax*8]
    537b:	vmovsd QWORD PTR [rdx-0x10],xmm0
    5380:	vmovsd xmm0,QWORD PTR [r11+rax*8]
    5386:	inc    rax
    5389:	vmovsd QWORD PTR [rdx-0x8],xmm0
    538e:	cmp    rax,rbx
    5391:	jne    5350 <bench_ada__run_10.isra.0+0x500>
    5393:	jmp    5003 <bench_ada__run_10.isra.0+0x1b3>
    5398:	mov    r10,QWORD PTR [rsp-0x10]
    539d:	lea    r8,[r12+r13*1]
    53a1:	mov    rdx,r14
    53a4:	xor    eax,eax
    53a6:	lea    r9,[r8+r13*1]
    53aa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    53b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    53c0:	vmovsd xmm0,QWORD PTR [r12+rax*8]
    53c6:	add    rdx,0x18
    53ca:	vmovsd QWORD PTR [rdx-0x18],xmm0
    53cf:	vmovsd xmm0,QWORD PTR [r8+rax*8]
    53d5:	vmovsd QWORD PTR [rdx-0x10],xmm0
    53da:	vmovsd xmm0,QWORD PTR [r9+rax*8]
    53e0:	inc    rax
    53e3:	vmovsd QWORD PTR [rdx-0x8],xmm0
    53e8:	cmp    rax,r10
    53eb:	jne    53c0 <bench_ada__run_10.isra.0+0x570>
    53ed:	jmp    5003 <bench_ada__run_10.isra.0+0x1b3>
    53f2:	nop    DWORD PTR [rax]
    53f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5400:	inc    rax
    5403:	cmp    r9,rax
    5406:	jne    5098 <bench_ada__run_10.isra.0+0x248>
    540c:	mov    rdi,QWORD PTR [rsp-0x30]
    5411:	mov    r13,r10
    5414:	jmp    4fff <bench_ada__run_10.isra.0+0x1af>
    5419:	imul   rax,r8
    541d:	imul   r11,QWORD PTR [rsp-0x10],0x5
    5423:	mov    QWORD PTR [rsp-0x68],rdi
    5428:	mov    QWORD PTR [rsp-0x70],rsi
    542d:	mov    QWORD PTR [rbp+0x10],rcx
    5431:	mov    QWORD PTR [rbp+0x20],r14
    5435:	mov    r10,r12
    5438:	xor    r15d,r15d
    543b:	mov    r9,0xffffffffffffffff
    5442:	vmovq  xmm7,rax
    5447:	mov    rax,QWORD PTR [rsp-0x10]
    544c:	shr    rdx,0x3
    5450:	mov    QWORD PTR [rsp-0x30],rdx
    5455:	shl    rax,0x5
    5459:	mov    QWORD PTR [rsp-0x38],rax
    545e:	vmovq  rax,xmm5
    5463:	sub    rax,0x8
    5467:	shl    r11,0x3
    546b:	vmovq  xmm6,rax
    5470:	mov    rax,r14
    5473:	mov    r14,rbx
    5476:	vmovq  rsi,xmm6
    547b:	inc    r9
    547e:	lea    rdx,[rsi+rax*1]
    5482:	cmp    rdx,r10
    5485:	jb     5499 <bench_ada__run_10.isra.0+0x649>
    5487:	vmovq  rsi,xmm7
    548c:	lea    rdx,[r10+rsi*8]
    5490:	cmp    rdx,rax
    5493:	jae    5828 <bench_ada__run_10.isra.0+0x9d8>
    5499:	mov    rbx,QWORD PTR [rsp-0x38]
    549e:	mov    QWORD PTR [rsp-0x40],r8
    54a3:	mov    QWORD PTR [rsp-0x48],r9
    54a8:	mov    QWORD PTR [rsp-0x50],rax
    54ad:	mov    QWORD PTR [rsp-0x58],r10
    54b2:	mov    QWORD PTR [rsp-0x60],r12
    54b7:	mov    rsi,rax
    54ba:	mov    rcx,r10
    54bd:	xor    edx,edx
    54bf:	lea    rdi,[rbx+r10*1]
    54c3:	lea    r12,[rdi+r13*2]
    54c7:	vmovsd xmm1,QWORD PTR [rdi]
    54cb:	vmovhpd xmm1,xmm1,QWORD PTR [r13+rdi*1+0x0]
    54d2:	lea    r9,[rcx+r13*2]
    54d6:	vmovsd xmm0,QWORD PTR [r12]
    54dc:	vmovhpd xmm0,xmm0,QWORD PTR [r13+r12*1+0x0]
    54e3:	lea    rbx,[r13+r9*1+0x0]
    54e8:	lea    r8,[r13+r12*1+0x0]
    54ed:	inc    rdx
    54f0:	add    rsi,0x40
    54f4:	lea    rdi,[r11+r8*1]
    54f8:	vinsertf64x2 ymm1,ymm1,xmm0,0x1
    54ff:	vmovsd xmm0,QWORD PTR [r9]
    5504:	vmovhpd xmm2,xmm0,QWORD PTR [r13+r9*1+0x0]
    550b:	vmovsd xmm0,QWORD PTR [rcx]
    550f:	vmovhpd xmm0,xmm0,QWORD PTR [rcx+r13*1]
    5515:	lea    rcx,[r11+rbx*1]
    5519:	vinsertf64x2 ymm0,ymm0,xmm2,0x1
    5520:	vinsertf64x4 zmm0,zmm0,ymm1,0x1
    5527:	vmovupd ZMMWORD PTR [rsi-0x40],zmm0
    552e:	cmp    rdx,QWORD PTR [rsp-0x30]
    5533:	jb     54c3 <bench_ada__run_10.isra.0+0x673>
    5535:	mov    rsi,QWORD PTR [rsp-0x30]
    553a:	mov    r8,QWORD PTR [rsp-0x40]
    553f:	mov    r9,QWORD PTR [rsp-0x48]
    5544:	mov    rax,QWORD PTR [rsp-0x50]
    5549:	mov    r10,QWORD PTR [rsp-0x58]
    554e:	mov    r12,QWORD PTR [rsp-0x60]
    5553:	shl    rsi,0x3
    5557:	cmp    QWORD PTR [rsp],rsi
    555b:	je     55ce <bench_ada__run_10.isra.0+0x77e>
    555d:	mov    rcx,r8
    5560:	mov    rbx,QWORD PTR [rbp+0x20]
    5564:	mov    rdx,r14
    5567:	sub    rdx,rsi
    556a:	imul   rcx,rsi
    556e:	inc    rdx
    5571:	add    rcx,r9
    5574:	lea    rdi,[r12+rcx*8]
    5578:	lea    rcx,[rdi+r13*1]
    557c:	vmovsd xmm0,QWORD PTR [rcx+r13*1]
    5582:	vmovhpd xmm4,xmm0,QWORD PTR [rcx+r13*2]
    5588:	vmovsd xmm0,QWORD PTR [rdi]
    558c:	vmovhpd xmm0,xmm0,QWORD PTR [rcx]
    5590:	lea    rcx,[rsi+r15*1]
    5594:	vinsertf64x2 ymm0,ymm0,xmm4,0x1
    559b:	vmovupd YMMWORD PTR [rbx+rcx*8],ymm0
    55a0:	mov    rcx,rdx
    55a3:	and    rcx,0xfffffffffffffffc
    55a7:	and    dl,0x3
    55aa:	je     55ce <bench_ada__run_10.isra.0+0x77e>
    55ac:	lea    rdx,[rsi+rcx*1-0x1]
    55b1:	inc    rdx
    55b4:	mov    rcx,r8
    55b7:	imul   rcx,rdx
    55bb:	add    rcx,r9
    55be:	vmovsd xmm0,QWORD PTR [r12+rcx*8]
    55c4:	vmovsd QWORD PTR [rax+rdx*8],xmm0
    55c9:	cmp    r14,rdx
    55cc:	jne    55b1 <bench_ada__run_10.isra.0+0x761>
    55ce:	vmovq  rsi,xmm5
    55d3:	add    r15,QWORD PTR [rsp]
    55d7:	add    r10,0x8
    55db:	add    rax,rsi
    55de:	cmp    QWORD PTR [rsp-0x28],r9
    55e3:	jne    5476 <bench_ada__run_10.isra.0+0x626>
    55e9:	mov    rdi,QWORD PTR [rsp-0x68]
    55ee:	mov    rsi,QWORD PTR [rsp-0x70]
    55f3:	mov    rcx,QWORD PTR [rbp+0x10]
    55f7:	mov    r14,QWORD PTR [rbp+0x20]
    55fb:	jmp    5003 <bench_ada__run_10.isra.0+0x1b3>
    5600:	mov    rax,0xffffffffffffffff
    5607:	inc    rax
    560a:	mov    rdx,rax
    560d:	imul   rdx,r15
    5611:	add    rdx,r8
    5614:	vmovsd xmm0,QWORD PTR [r12+rdx*8]
    561a:	vmovsd QWORD PTR [r9+rax*8],xmm0
    5620:	cmp    rax,rbx
    5623:	jne    5607 <bench_ada__run_10.isra.0+0x7b7>
    5625:	jmp    4fe0 <bench_ada__run_10.isra.0+0x190>
    562a:	mov    rdi,QWORD PTR [rsp-0x40]
    562f:	mov    rax,0xffffffffffffffff
    5636:	inc    rax
    5639:	mov    rdx,r8
    563c:	imul   rdx,rax
    5640:	add    rdx,r10
    5643:	vmovsd xmm0,QWORD PTR [r12+rdx*8]
    5649:	vmovsd QWORD PTR [r9+rax*8],xmm0
    564f:	cmp    rdi,rax
    5652:	jne    5636 <bench_ada__run_10.isra.0+0x7e6>
    5654:	jmp    5319 <bench_ada__run_10.isra.0+0x4c9>
    5659:	mov    r8,rdi
    565c:	mov    rbx,rcx
    565f:	mov    r9d,DWORD PTR [rsp-0x18]
    5664:	lea    rcx,[r12+r13*1]
    5668:	mov    r10,QWORD PTR [rbp+0x18]
    566c:	mov    r11,QWORD PTR [rbp+0x28]
    5670:	mov    rdi,QWORD PTR [rsp-0x10]
    5675:	mov    r13d,DWORD PTR [rsp-0x8]
    567a:	mov    rdx,r14
    567d:	xor    eax,eax
    567f:	nop
    5680:	vmovsd xmm0,QWORD PTR [r12+rax*8]
    5686:	add    rdx,0x10
    568a:	vmovsd QWORD PTR [rdx-0x10],xmm0
    568f:	vmovsd xmm0,QWORD PTR [rcx+rax*8]
    5694:	inc    rax
    5697:	vmovsd QWORD PTR [rdx-0x8],xmm0
    569c:	cmp    rdi,rax
    569f:	jne    5680 <bench_ada__run_10.isra.0+0x830>
    56a1:	cmp    r13d,r9d
    56a4:	je     4f00 <bench_ada__run_10.isra.0+0xb0>
    56aa:	inc    r9d
    56ad:	jmp    567a <bench_ada__run_10.isra.0+0x82a>
    56af:	mov    rbx,rcx
    56b2:	lea    rcx,[r12+r13*1]
    56b6:	mov    r8,rdi
    56b9:	mov    r11d,DWORD PTR [rsp-0x18]
    56be:	lea    r9,[rcx+r13*1]
    56c2:	mov    r15,QWORD PTR [rbp+0x28]
    56c6:	mov    r10,QWORD PTR [rsp-0x10]
    56cb:	lea    rdi,[r13+r9*1+0x0]
    56d0:	mov    r13,QWORD PTR [rbp+0x18]
    56d4:	mov    rdx,r14
    56d7:	xor    eax,eax
    56d9:	nop    DWORD PTR [rax+0x0]
    56e0:	vmovsd xmm0,QWORD PTR [r12+rax*8]
    56e6:	add    rdx,0x20
    56ea:	vmovsd QWORD PTR [rdx-0x20],xmm0
    56ef:	vmovsd xmm0,QWORD PTR [rcx+rax*8]
    56f4:	vmovsd QWORD PTR [rdx-0x18],xmm0
    56f9:	vmovsd xmm0,QWORD PTR [r9+rax*8]
    56ff:	vmovsd QWORD PTR [rdx-0x10],xmm0
    5704:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    5709:	inc    rax
    570c:	vmovsd QWORD PTR [rdx-0x8],xmm0
    5711:	cmp    r10,rax
    5714:	jne    56e0 <bench_ada__run_10.isra.0+0x890>
    5716:	cmp    DWORD PTR [rsp-0x8],r11d
    571b:	je     4f00 <bench_ada__run_10.isra.0+0xb0>
    5721:	inc    r11d
    5724:	jmp    56d4 <bench_ada__run_10.isra.0+0x884>
    5726:	lea    rax,[r14-0x8]
    572a:	mov    QWORD PTR [rsp-0x38],r13
    572f:	mov    r11d,DWORD PTR [rsp-0x18]
    5734:	mov    r13,QWORD PTR [rbp+0x18]
    5738:	sub    rax,r12
    573b:	mov    rbx,QWORD PTR [rbp+0x28]
    573f:	mov    r10,r14
    5742:	sub    r10,r12
    5745:	mov    QWORD PTR [rsp-0x30],rax
    574a:	mov    rax,QWORD PTR [rsp-0x10]
    574f:	lea    r9,[rax-0x8]
    5753:	shr    r9,0x3
    5757:	inc    r9
    575a:	lea    r15,[r9*8+0x0]
    5762:	mov    QWORD PTR [rsp-0x18],r15
    5767:	cmp    QWORD PTR [rsp-0x30],0x30
    576d:	jbe    58bf <bench_ada__run_10.isra.0+0xa6f>
    5773:	mov    rax,r12
    5776:	xor    edx,edx
    5778:	cmp    QWORD PTR [rsp-0x28],0x6
    577e:	jbe    58ee <bench_ada__run_10.isra.0+0xa9e>
    5784:	nop    WORD PTR [rax+rax*1+0x0]
    578a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5795:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    57a0:	vmovupd zmm0,ZMMWORD PTR [rax]
    57a6:	inc    rdx
    57a9:	vmovupd ZMMWORD PTR [r10+rax*1],zmm0
    57b0:	add    rax,0x40
    57b4:	cmp    rdx,r9
    57b7:	jb     57a0 <bench_ada__run_10.isra.0+0x950>
    57b9:	mov    rax,QWORD PTR [rsp-0x18]
    57be:	mov    r8,rax
    57c1:	cmp    rax,QWORD PTR [rsp-0x10]
    57c6:	je     5892 <bench_ada__run_10.isra.0+0xa42>
    57cc:	vmovdqa xmm1,XMMWORD PTR [rip+0x2e69c]        # 33e70 <system__secondary_stack__invalid_memory_size+0xa8>
    57d4:	mov    rax,QWORD PTR [rsp-0x10]
    57d9:	mov    r15d,0x8
    57df:	xor    edx,edx
    57e1:	sub    rax,r8
    57e4:	cmp    r15,rax
    57e7:	mov    r15d,0x0
    57ed:	sbb    r15,rdx
    57f0:	mov    r15d,0x8
    57f6:	cmovb  rax,r15
    57fa:	vpbroadcastw xmm0,eax
    5800:	vpcmpnleuw k1,xmm0,xmm1
    5807:	vmovupd zmm0{k1}{z},ZMMWORD PTR [r12+r8*8]
    580e:	vmovupd ZMMWORD PTR [r14+r8*8]{k1},zmm0
    5815:	cmp    DWORD PTR [rsp-0x8],r11d
    581a:	je     4f00 <bench_ada__run_10.isra.0+0xb0>
    5820:	inc    r11d
    5823:	jmp    5767 <bench_ada__run_10.isra.0+0x917>
    5828:	mov    rdx,0xffffffffffffffff
    582f:	inc    rdx
    5832:	mov    rcx,r8
    5835:	imul   rcx,rdx
    5839:	add    rcx,r9
    583c:	vmovsd xmm0,QWORD PTR [r12+rcx*8]
    5842:	vmovsd QWORD PTR [rax+rdx*8],xmm0
    5847:	cmp    r14,rdx
    584a:	jne    582f <bench_ada__run_10.isra.0+0x9df>
    584c:	jmp    55ce <bench_ada__run_10.isra.0+0x77e>
    5851:	nop    DWORD PTR [rax+0x0]
    5855:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5860:	mov    rdx,QWORD PTR [rbp+0x18]
    5864:	mov    rcx,QWORD PTR [rbp+0x28]
    5868:	mov    edi,DWORD PTR [rsp-0x8]
    586c:	mov    eax,0x1
    5871:	cmp    edi,eax
    5873:	je     4f03 <bench_ada__run_10.isra.0+0xb3>
    5879:	lea    r9d,[rax+0x1]
    587d:	cmp    edi,r9d
    5880:	je     4f03 <bench_ada__run_10.isra.0+0xb3>
    5886:	add    eax,0x2
    5889:	cmp    edi,eax
    588b:	jne    5879 <bench_ada__run_10.isra.0+0xa29>
    588d:	jmp    4f03 <bench_ada__run_10.isra.0+0xb3>
    5892:	mov    r13,QWORD PTR [rsp-0x38]
    5897:	mov    rax,QWORD PTR [rbp+0x18]
    589b:	mov    rbx,QWORD PTR [rbp+0x28]
    589f:	cmp    DWORD PTR [rsp-0x8],r11d
    58a4:	je     4f00 <bench_ada__run_10.isra.0+0xb0>
    58aa:	inc    r11d
    58ad:	mov    rax,QWORD PTR [rbp+0x18]
    58b1:	mov    rbx,QWORD PTR [rbp+0x28]
    58b5:	mov    DWORD PTR [rsp-0x18],r11d
    58ba:	jmp    4ee2 <bench_ada__run_10.isra.0+0x92>
    58bf:	mov    r13,QWORD PTR [rsp-0x38]
    58c4:	mov    DWORD PTR [rsp-0x18],r11d
    58c9:	mov    rdx,QWORD PTR [rsp-0x28]
    58ce:	mov    rax,0xffffffffffffffff
    58d5:	inc    rax
    58d8:	vmovsd xmm0,QWORD PTR [r12+rax*8]
    58de:	vmovsd QWORD PTR [r14+rax*8],xmm0
    58e4:	cmp    rax,rdx
    58e7:	jne    58d5 <bench_ada__run_10.isra.0+0xa85>
    58e9:	jmp    5003 <bench_ada__run_10.isra.0+0x1b3>
    58ee:	mov    rax,QWORD PTR [rsp-0x10]
    58f3:	vmovdqa xmm1,XMMWORD PTR [rip+0x2e575]        # 33e70 <system__secondary_stack__invalid_memory_size+0xa8>
    58fb:	mov    r15d,0x8
    5901:	xor    edx,edx
    5903:	xor    r8d,r8d
    5906:	cmp    r15,rax
    5909:	sbb    r8,rdx
    590c:	cmovb  rax,r15
    5910:	vpbroadcastw xmm0,eax
    5916:	vpcmpnleuw k1,xmm0,xmm1
    591d:	vmovupd zmm0{k1}{z},ZMMWORD PTR [r12]
    5924:	vmovupd ZMMWORD PTR [r14]{k1},zmm0
    592a:	cmp    DWORD PTR [rsp-0x8],r11d
    592f:	je     4f00 <bench_ada__run_10.isra.0+0xb0>
    5935:	inc    r11d
    5938:	xor    r8d,r8d
    593b:	jmp    57d4 <bench_ada__run_10.isra.0+0x984>


<bench_ada__run_11.isra.0>:
    5940:	sub    rsp,0x30
    5944:	mov    QWORD PTR [rsp+0x10],r12
    5949:	mov    QWORD PTR [rsp+0x18],r13
    594e:	mov    DWORD PTR [rsp-0xc],esi
    5952:	mov    r12,QWORD PTR [rsp+0x38]
    5957:	mov    r10,QWORD PTR [rsp+0x40]
    595c:	mov    r13,QWORD PTR [rsp+0x48]
    5961:	test   esi,esi
    5963:	je     5b2c <bench_ada__run_11.isra.0+0x1ec>
    5969:	mov    QWORD PTR [rsp+0x8],rbp
    596e:	mov    r11d,edi
    5971:	mov    rbp,rcx
    5974:	mov    rdi,rdx
    5977:	test   r11d,r11d
    597a:	je     5b3b <bench_ada__run_11.isra.0+0x1fb>
    5980:	vmovsd xmm1,QWORD PTR [rip+0x2e3d0]        # 33d58 <system__os_lib__standin+0xc>
    5988:	mov    QWORD PTR [rsp],rbx
    598c:	mov    QWORD PTR [rsp-0x8],rcx
    5991:	mov    QWORD PTR [rsp+0x48],r13
    5996:	mov    QWORD PTR [rsp+0x20],r14
    599b:	mov    QWORD PTR [rsp+0x28],r15
    59a0:	lea    r14,[r11+0x1]
    59a4:	lea    r15,[r11*8+0x0]
    59ac:	mov    QWORD PTR [rsp+0x38],r12
    59b1:	mov    edx,0x1
    59b6:	mov    r12,r9
    59b9:	vmovq  xmm3,r15
    59be:	mov    r9,r8
    59c1:	vmovq  xmm2,r14
    59c6:	cs nop WORD PTR [rax+rax*1+0x0]
    59d0:	mov    r13,r12
    59d3:	mov    DWORD PTR [rsp-0x10],edx
    59d7:	mov    r12,r9
    59da:	mov    rbx,r10
    59dd:	xor    esi,esi
    59df:	vmovq  r14,xmm3
    59e4:	mov    r9,0xffffffffffffffff
    59eb:	jmp    5a12 <bench_ada__run_11.isra.0+0xd2>
    59ed:	nop    DWORD PTR [rax+rax*1+0x0]
    59f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5a00:	inc    rsi
    5a03:	inc    r9
    5a06:	add    rbx,r14
    5a09:	cmp    r11,rsi
    5a0c:	je     5af7 <bench_ada__run_11.isra.0+0x1b7>
    5a12:	vmovq  rax,xmm2
    5a17:	imul   rax,rsi
    5a1b:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    5a20:	vmovsd QWORD PTR [r10+rax*8],xmm0
    5a26:	test   r9d,r9d
    5a29:	js     5a00 <bench_ada__run_11.isra.0+0xc0>
    5a2b:	movsxd r15,esi
    5a2e:	mov    ecx,r9d
    5a31:	mov    rbp,r13
    5a34:	xor    eax,eax
    5a36:	mov    r8,r15
    5a39:	mov    r13,r12
    5a3c:	mov    r12,r9
    5a3f:	imul   r8,r14
    5a43:	lea    r9,[r8+rdi*1]
    5a47:	mov    r8,rcx
    5a4a:	jmp    5ab0 <bench_ada__run_11.isra.0+0x170>
    5a4c:	nop    DWORD PTR [rax+rax*1+0x0]
    5a54:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5a5f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5a6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5a75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5a80:	mov    rdx,rax
    5a83:	vmovsd xmm0,QWORD PTR [r9+rax*8]
    5a89:	imul   rdx,r11
    5a8d:	lea    rcx,[rdx+r15*1]
    5a91:	add    rdx,rsi
    5a94:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*8]
    5a99:	vmulsd xmm0,xmm0,xmm1
    5a9d:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    5aa2:	vmovsd QWORD PTR [r10+rdx*8],xmm0
    5aa8:	cmp    r8,rax
    5aab:	je     5adc <bench_ada__run_11.isra.0+0x19c>
    5aad:	inc    rax
    5ab0:	cmp    esi,eax
    5ab2:	jne    5a80 <bench_ada__run_11.isra.0+0x140>
    5ab4:	vmovq  rdx,xmm2
    5ab9:	imul   rdx,rax
    5abd:	vmovsd xmm0,QWORD PTR [rdi+rdx*8]
    5ac2:	mov    rdx,rax
    5ac5:	imul   rdx,r11
    5ac9:	add    rdx,rsi
    5acc:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    5ad1:	vmovsd QWORD PTR [r10+rdx*8],xmm0
    5ad7:	cmp    r8,rax
    5ada:	jne    5aad <bench_ada__run_11.isra.0+0x16d>
    5adc:	mov    r9,r12
    5adf:	inc    rsi
    5ae2:	mov    r12,r13
    5ae5:	add    rbx,r14
    5ae8:	mov    r13,rbp
    5aeb:	inc    r9
    5aee:	cmp    r11,rsi
    5af1:	jne    5a12 <bench_ada__run_11.isra.0+0xd2>
    5af7:	mov    r9,r12
    5afa:	mov    edx,DWORD PTR [rsp-0x10]
    5afe:	mov    rax,QWORD PTR [rsp-0x8]
    5b03:	mov    rbx,QWORD PTR [rsp+0x38]
    5b08:	mov    rcx,QWORD PTR [rsp+0x48]
    5b0d:	mov    r12,r13
    5b10:	cmp    DWORD PTR [rsp-0xc],edx
    5b14:	je     5b54 <bench_ada__run_11.isra.0+0x214>
    5b16:	mov    rcx,QWORD PTR [rsp+0x38]
    5b1b:	mov    rbx,QWORD PTR [rsp+0x48]
    5b20:	inc    edx
    5b22:	jmp    59d0 <bench_ada__run_11.isra.0+0x90>
    5b27:	mov    rbp,QWORD PTR [rsp+0x8]
    5b2c:	mov    r12,QWORD PTR [rsp+0x10]
    5b31:	mov    r13,QWORD PTR [rsp+0x18]
    5b36:	add    rsp,0x30
    5b3a:	ret
    5b3b:	mov    edx,DWORD PTR [rsp-0xc]
    5b3f:	mov    eax,0x1
    5b44:	cmp    edx,eax
    5b46:	je     5b27 <bench_ada__run_11.isra.0+0x1e7>
    5b48:	lea    ecx,[rax+0x1]
    5b4b:	cmp    edx,ecx
    5b4d:	je     5b27 <bench_ada__run_11.isra.0+0x1e7>
    5b4f:	add    eax,0x2
    5b52:	jmp    5b44 <bench_ada__run_11.isra.0+0x204>
    5b54:	mov    rbx,QWORD PTR [rsp]
    5b58:	mov    rbp,QWORD PTR [rsp+0x8]
    5b5d:	mov    r14,QWORD PTR [rsp+0x20]
    5b62:	mov    r15,QWORD PTR [rsp+0x28]
    5b67:	jmp    5b2c <bench_ada__run_11.isra.0+0x1ec>
    5b69:	nop
    5b6a:	nop    WORD PTR [rax+rax*1+0x0]


<bench_ada__run_12.isra.0>:
    7f20:	sub    rsp,0x48
    7f24:	mov    QWORD PTR [rsp+0x18],rbx
    7f29:	mov    QWORD PTR [rsp+0x38],r14
    7f2e:	mov    QWORD PTR [rsp+0x40],r15
    7f33:	mov    ebx,edi
    7f35:	mov    r14,rcx
    7f38:	mov    r15,r8
    7f3b:	mov    rcx,QWORD PTR [rsp+0x50]
    7f40:	mov    rdi,QWORD PTR [rsp+0x58]
    7f45:	mov    r8,QWORD PTR [rsp+0x60]
    7f4a:	test   esi,esi
    7f4c:	je     8015 <bench_ada__run_12.isra.0+0xf5>
    7f52:	mov    QWORD PTR [rsp+0x28],r12
    7f57:	mov    QWORD PTR [rsp+0x30],r13
    7f5c:	mov    r12,rdx
    7f5f:	mov    r13,r9
    7f62:	test   ebx,ebx
    7f64:	je     8029 <bench_ada__run_12.isra.0+0x109>
    7f6a:	lea    rax,[rbx*8+0x0]
    7f72:	mov    DWORD PTR [rsp+0xc],esi
    7f76:	mov    rsi,rbx
    7f79:	mov    DWORD PTR [rsp+0x8],0x1
    7f81:	mov    QWORD PTR [rsp+0x20],rbp
    7f86:	imul   rsi,rax
    7f8a:	shr    rax,0x3
    7f8e:	mov    QWORD PTR [rsp],rsi
    7f92:	lea    rbp,[rax+0x1]
    7f96:	mov    rdx,QWORD PTR [rsp]
    7f9a:	xor    esi,esi
    7f9c:	mov    QWORD PTR [rsp+0x60],r8
    7fa1:	mov    QWORD PTR [rsp+0x50],rcx
    7fa6:	call   2bd0 <memset@plt>
    7fab:	vmovsd xmm0,QWORD PTR [rip+0x2bdd5]        # 33d88 <system__os_lib__standin+0x3c>
    7fb3:	mov    r8,QWORD PTR [rsp+0x60]
    7fb8:	mov    rcx,QWORD PTR [rsp+0x50]
    7fbd:	mov    rdi,rax
    7fc0:	xor    eax,eax
    7fc2:	nop    DWORD PTR [rax+rax*1+0x0]
    7fca:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7fd5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7fe0:	mov    rdx,rbp
    7fe3:	imul   rdx,rax
    7fe7:	inc    rax
    7fea:	vmovsd QWORD PTR [rdi+rdx*8],xmm0
    7fef:	cmp    rax,rbx
    7ff2:	jne    7fe0 <bench_ada__run_12.isra.0+0xc0>
    7ff4:	mov    eax,DWORD PTR [rsp+0x8]
    7ff8:	cmp    DWORD PTR [rsp+0xc],eax
    7ffc:	je     8006 <bench_ada__run_12.isra.0+0xe6>
    7ffe:	inc    eax
    8000:	mov    DWORD PTR [rsp+0x8],eax
    8004:	jmp    7f96 <bench_ada__run_12.isra.0+0x76>
    8006:	mov    rbp,QWORD PTR [rsp+0x20]
    800b:	mov    r12,QWORD PTR [rsp+0x28]
    8010:	mov    r13,QWORD PTR [rsp+0x30]
    8015:	mov    rbx,QWORD PTR [rsp+0x18]
    801a:	mov    r14,QWORD PTR [rsp+0x38]
    801f:	mov    r15,QWORD PTR [rsp+0x40]
    8024:	add    rsp,0x48
    8028:	ret
    8029:	mov    eax,0x1
    802e:	cmp    esi,eax
    8030:	je     800b <bench_ada__run_12.isra.0+0xeb>
    8032:	lea    edx,[rax+0x1]
    8035:	cmp    esi,edx
    8037:	je     800b <bench_ada__run_12.isra.0+0xeb>
    8039:	add    eax,0x2
    803c:	cmp    esi,eax
    803e:	jne    8032 <bench_ada__run_12.isra.0+0x112>
    8040:	jmp    800b <bench_ada__run_12.isra.0+0xeb>
    8042:	nop    DWORD PTR [rax]
    8045:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_13.isra.0>:
    5b70:	push   rbp
    5b71:	mov    rbp,rsp
    5b74:	push   r15
    5b76:	push   r14
    5b78:	push   r13
    5b7a:	push   r12
    5b7c:	push   rbx
    5b7d:	mov    r12,r9
    5b80:	and    rsp,0xffffffffffffffc0
    5b84:	test   edx,edx
    5b86:	mov    rax,QWORD PTR [rbp+0x10]
    5b8a:	mov    DWORD PTR [rsp-0xc],edx
    5b8e:	mov    r15,QWORD PTR [rbp+0x18]
    5b92:	mov    r10,QWORD PTR [rbp+0x20]
    5b96:	mov    r9,QWORD PTR [rbp+0x28]
    5b9a:	je     5bcc <bench_ada__run_13.isra.0+0x5c>
    5b9c:	mov    rbx,rcx
    5b9f:	mov    rdx,r8
    5ba2:	sar    edi,1
    5ba4:	lea    ecx,[rdi-0x1]
    5ba7:	cmp    ecx,0xffffffff
    5baa:	je     5bdb <bench_ada__run_13.isra.0+0x6b>
    5bac:	test   esi,esi
    5bae:	jne    5bf4 <bench_ada__run_13.isra.0+0x84>
    5bb0:	mov    esi,DWORD PTR [rsp-0xc]
    5bb4:	mov    ecx,0x1
    5bb9:	cmp    esi,ecx
    5bbb:	je     5bcc <bench_ada__run_13.isra.0+0x5c>
    5bbd:	lea    edi,[rcx+0x1]
    5bc0:	cmp    esi,edi
    5bc2:	je     5bcc <bench_ada__run_13.isra.0+0x5c>
    5bc4:	add    ecx,0x2
    5bc7:	jmp    5bb9 <bench_ada__run_13.isra.0+0x49>
    5bc9:	vzeroupper
    5bcc:	lea    rsp,[rbp-0x28]
    5bd0:	pop    rbx
    5bd1:	pop    r12
    5bd3:	pop    r13
    5bd5:	pop    r14
    5bd7:	pop    r15
    5bd9:	pop    rbp
    5bda:	ret
    5bdb:	mov    esi,DWORD PTR [rsp-0xc]
    5bdf:	mov    ecx,0x1
    5be4:	cmp    esi,ecx
    5be6:	je     5bcc <bench_ada__run_13.isra.0+0x5c>
    5be8:	lea    edi,[rcx+0x1]
    5beb:	cmp    esi,edi
    5bed:	je     5bcc <bench_ada__run_13.isra.0+0x5c>
    5bef:	add    ecx,0x2
    5bf2:	jmp    5be4 <bench_ada__run_13.isra.0+0x74>
    5bf4:	vmovdqa xmm2,XMMWORD PTR [rip+0x2e274]        # 33e70 <system__secondary_stack__invalid_memory_size+0xa8>
    5bfc:	mov    QWORD PTR [rsp-0x18],r8
    5c01:	mov    QWORD PTR [rsp-0x20],r12
    5c06:	mov    QWORD PTR [rbp+0x10],rax
    5c0a:	mov    QWORD PTR [rbp+0x18],r15
    5c0e:	mov    r11d,esi
    5c11:	dec    esi
    5c13:	mov    edx,0x1
    5c18:	mov    rdi,r11
    5c1b:	shr    rdi,0x3
    5c1f:	vmovd  xmm3,ecx
    5c23:	mov    r14,r11
    5c26:	mov    QWORD PTR [rsp-0x8],rsi
    5c2b:	mov    rsi,r10
    5c2e:	sub    rsi,rbx
    5c31:	and    r14d,0xfffffff8
    5c35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5c40:	mov    DWORD PTR [rsp-0x10],edx
    5c44:	mov    r8,0xffffffffffffffff
    5c4b:	mov    r15,rbx
    5c4e:	vmovq  r12,xmm3
    5c53:	xchg   ax,ax
    5c55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5c60:	inc    r8
    5c63:	movsxd rax,DWORD PTR [r9+r8*4]
    5c67:	imul   rax,r11
    5c6b:	lea    rcx,[rax*8+0x0]
    5c73:	lea    rbx,[r15+rcx*1]
    5c77:	lea    r13,[r10+rcx*1]
    5c7b:	lea    rcx,[rcx+r10*1-0x8]
    5c80:	sub    rcx,rbx
    5c83:	mov    rdx,rbx
    5c86:	cmp    rcx,0x30
    5c8a:	jbe    5d40 <bench_ada__run_13.isra.0+0x1d0>
    5c90:	cmp    QWORD PTR [rsp-0x8],0x6
    5c96:	jbe    5d76 <bench_ada__run_13.isra.0+0x206>
    5c9c:	xor    ecx,ecx
    5c9e:	xchg   ax,ax
    5ca0:	vmovupd zmm0,ZMMWORD PTR [rdx]
    5ca6:	inc    rcx
    5ca9:	vmovupd ZMMWORD PTR [rsi+rdx*1],zmm0
    5cb0:	add    rdx,0x40
    5cb4:	cmp    rcx,rdi
    5cb7:	jb     5ca0 <bench_ada__run_13.isra.0+0x130>
    5cb9:	mov    rdx,r14
    5cbc:	cmp    r14,r11
    5cbf:	je     5cf9 <bench_ada__run_13.isra.0+0x189>
    5cc1:	add    rax,rdx
    5cc4:	mov    rcx,r11
    5cc7:	sub    rcx,rdx
    5cca:	mov    edx,0x8
    5ccf:	xor    ebx,ebx
    5cd1:	xor    r13d,r13d
    5cd4:	cmp    rdx,rcx
    5cd7:	sbb    r13,rbx
    5cda:	cmovb  rcx,rdx
    5cde:	vpbroadcastw xmm0,ecx
    5ce4:	vpcmpnleuw k1,xmm0,xmm2
    5ceb:	vmovupd zmm0{k1}{z},ZMMWORD PTR [r15+rax*8]
    5cf2:	vmovupd ZMMWORD PTR [r10+rax*8]{k1},zmm0
    5cf9:	cmp    r8,r12
    5cfc:	jne    5c60 <bench_ada__run_13.isra.0+0xf0>
    5d02:	mov    rbx,r15
    5d05:	mov    edx,DWORD PTR [rsp-0x10]
    5d09:	mov    rax,QWORD PTR [rsp-0x18]
    5d0e:	mov    rcx,QWORD PTR [rsp-0x20]
    5d13:	mov    r15,QWORD PTR [rbp+0x10]
    5d17:	mov    r8,QWORD PTR [rbp+0x18]
    5d1b:	cmp    DWORD PTR [rsp-0xc],edx
    5d1f:	je     5bc9 <bench_ada__run_13.isra.0+0x59>
    5d25:	mov    r15,QWORD PTR [rbp+0x10]
    5d29:	mov    r8,QWORD PTR [rbp+0x18]
    5d2d:	inc    edx
    5d2f:	jmp    5c40 <bench_ada__run_13.isra.0+0xd0>
    5d34:	nop
    5d35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5d40:	xor    eax,eax
    5d42:	nop    DWORD PTR [rax+rax*1+0x0]
    5d4a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5d55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5d60:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    5d65:	vmovsd QWORD PTR [r13+rax*8+0x0],xmm0
    5d6c:	inc    rax
    5d6f:	cmp    rax,r11
    5d72:	jne    5d60 <bench_ada__run_13.isra.0+0x1f0>
    5d74:	jmp    5cf9 <bench_ada__run_13.isra.0+0x189>
    5d76:	xor    edx,edx
    5d78:	jmp    5cc1 <bench_ada__run_13.isra.0+0x151>
    5d7d:	nop
    5d7e:	xchg   ax,ax


<bench_ada__run_14.isra.0>:
    8050:	push   rbp
    8051:	mov    r11d,ecx
    8054:	mov    r10d,edi
    8057:	mov    rbp,rsp
    805a:	push   r15
    805c:	push   r14
    805e:	push   r13
    8060:	push   r12
    8062:	push   rbx
    8063:	and    rsp,0xffffffffffffffc0
    8067:	add    rsp,0xffffffffffffff80
    806b:	mov    rcx,QWORD PTR [rbp+0x18]
    806f:	mov    rax,QWORD PTR [rbp+0x20]
    8073:	mov    rdi,QWORD PTR [rbp+0x28]
    8077:	mov    r14,QWORD PTR [rbp+0x30]
    807b:	test   r11d,r11d
    807e:	je     8176 <bench_ada__run_14.isra.0+0x126>
    8084:	mov    rbx,r8
    8087:	mov    r12,r9
    808a:	mov    r8,QWORD PTR [rbp+0x10]
    808e:	test   r10d,r10d
    8091:	je     8157 <bench_ada__run_14.isra.0+0x107>
    8097:	mov    r15d,esi
    809a:	mov    DWORD PTR [rsp+0x2c],esi
    809e:	lea    esi,[rdx-0x1]
    80a1:	mov    DWORD PTR [rsp+0x14],r11d
    80a6:	mov    DWORD PTR [rsp+0x6c],esi
    80aa:	mov    esi,edx
    80ac:	mov    r11d,edx
    80af:	mov    DWORD PTR [rsp+0x78],edx
    80b3:	lea    r8,[rsi*8+0x0]
    80bb:	mov    edx,r10d
    80be:	mov    esi,r15d
    80c1:	mov    DWORD PTR [rsp+0x28],0x1
    80c9:	mov    r9,r8
    80cc:	mov    QWORD PTR [rsp+0x20],rsi
    80d1:	mov    QWORD PTR [rsp+0x60],r8
    80d6:	lea    r15,[rdx-0x1]
    80da:	mov    QWORD PTR [rbp+0x18],rcx
    80de:	mov    QWORD PTR [rbp+0x20],rax
    80e2:	mov    QWORD PTR [rbp+0x30],r14
    80e6:	mov    QWORD PTR [rsp+0x38],r15
    80eb:	imul   r9,rdx
    80ef:	shl    rsi,0x3
    80f3:	test   r11d,r11d
    80f6:	mov    QWORD PTR [rsp+0x30],r9
    80fb:	mov    QWORD PTR [rsp+0x18],rsi
    8100:	setne  BYTE PTR [rsp+0x7f]
    8105:	shr    r8,0x3
    8109:	mov    QWORD PTR [rsp+0x70],r8
    810e:	mov    rdx,QWORD PTR [rsp+0x30]
    8113:	xor    esi,esi
    8115:	call   2bd0 <memset@plt>
    811a:	mov    rdi,rax
    811d:	mov    eax,DWORD PTR [rsp+0x2c]
    8121:	test   eax,eax
    8123:	jne    8185 <bench_ada__run_14.isra.0+0x135>
    8125:	mov    rax,QWORD PTR [rbp+0x10]
    8129:	mov    rdx,QWORD PTR [rbp+0x18]
    812d:	mov    rcx,QWORD PTR [rbp+0x20]
    8131:	mov    rsi,QWORD PTR [rbp+0x30]
    8135:	mov    eax,DWORD PTR [rsp+0x28]
    8139:	cmp    DWORD PTR [rsp+0x14],eax
    813d:	je     8176 <bench_ada__run_14.isra.0+0x126>
    813f:	inc    eax
    8141:	mov    rdx,QWORD PTR [rbp+0x18]
    8145:	mov    rcx,QWORD PTR [rbp+0x20]
    8149:	mov    rsi,QWORD PTR [rbp+0x30]
    814d:	mov    DWORD PTR [rsp+0x28],eax
    8151:	mov    rax,QWORD PTR [rbp+0x10]
    8155:	jmp    810e <bench_ada__run_14.isra.0+0xbe>
    8157:	mov    rsi,QWORD PTR [rbp+0x10]
    815b:	mov    edx,0x1
    8160:	cmp    r11d,edx
    8163:	je     8176 <bench_ada__run_14.isra.0+0x126>
    8165:	lea    r8d,[rdx+0x1]
    8169:	cmp    r11d,r8d
    816c:	je     8176 <bench_ada__run_14.isra.0+0x126>
    816e:	add    edx,0x2
    8171:	cmp    r11d,edx
    8174:	jne    8165 <bench_ada__run_14.isra.0+0x115>
    8176:	lea    rsp,[rbp-0x28]
    817a:	pop    rbx
    817b:	pop    r12
    817d:	pop    r13
    817f:	pop    r14
    8181:	pop    r15
    8183:	pop    rbp
    8184:	ret
    8185:	mov    rax,QWORD PTR [rsp+0x20]
    818a:	mov    r11,QWORD PTR [rsp+0x18]
    818f:	mov    r9,0xffffffffffffffff
    8196:	vxorpd xmm7,xmm7,xmm7
    819a:	lea    r13,[rax-0x1]
    819e:	mov    eax,DWORD PTR [rsp+0x78]
    81a2:	shr    r11,0x3
    81a6:	mov    QWORD PTR [rsp+0x40],r11
    81ab:	shr    eax,0x3
    81ae:	mov    DWORD PTR [rsp+0x68],eax
    81b2:	shl    rax,0x6
    81b6:	mov    QWORD PTR [rsp+0x48],rax
    81bb:	nop    DWORD PTR [rax+rax*1+0x0]
    81c0:	mov    r11,QWORD PTR [rsp+0x40]
    81c5:	mov    r14,QWORD PTR [rsp+0x70]
    81ca:	inc    r9
    81cd:	mov    rcx,QWORD PTR [rsp+0x48]
    81d2:	movsxd rsi,r9d
    81d5:	mov    QWORD PTR [rsp+0x50],r9
    81da:	mov    rax,0xffffffffffffffff
    81e1:	imul   r11,rsi
    81e5:	imul   r14,rsi
    81e9:	imul   rsi,QWORD PTR [rsp+0x60]
    81ef:	mov    r8,r11
    81f2:	mov    r9,r14
    81f5:	lea    rdx,[rsi+rdi*1]
    81f9:	mov    QWORD PTR [rsp+0x58],rdx
    81fe:	lea    r15,[rcx+rdx*1]
    8202:	jmp    8249 <bench_ada__run_14.isra.0+0x1f9>
    8204:	nop    DWORD PTR [rax+rax*1+0x0]
    8209:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8214:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    821f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    822a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8235:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8240:	cmp    rax,r13
    8243:	je     83a0 <bench_ada__run_14.isra.0+0x350>
    8249:	inc    rax
    824c:	movsxd rdx,eax
    824f:	lea    rsi,[r8+rdx*1]
    8253:	vmovsd xmm1,QWORD PTR [rbx+rsi*8]
    8258:	vcomisd xmm1,xmm7
    825c:	vbroadcastsd zmm2,xmm1
    8262:	je     8240 <bench_ada__run_14.isra.0+0x1f0>
    8264:	cmp    BYTE PTR [rsp+0x7f],0x0
    8269:	je     8240 <bench_ada__run_14.isra.0+0x1f0>
    826b:	cmp    DWORD PTR [rsp+0x6c],0x6
    8270:	jbe    83f0 <bench_ada__run_14.isra.0+0x3a0>
    8276:	mov    r10,QWORD PTR [rsp+0x60]
    827b:	mov    rcx,QWORD PTR [rsp+0x58]
    8280:	vmovapd zmm3,zmm2
    8286:	imul   r10,rdx
    828a:	mov    rsi,rcx
    828d:	add    r10,r12
    8290:	sub    r10,rcx
    8293:	xchg   ax,ax
    8295:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    82a0:	vmulpd zmm0,zmm3,ZMMWORD PTR [rsi+r10*1]
    82a7:	add    rsi,0x40
    82ab:	vaddpd zmm0,zmm0,ZMMWORD PTR [rsi-0x40]
    82b2:	vmovupd ZMMWORD PTR [rsi-0x40],zmm0
    82b9:	cmp    rsi,r15
    82bc:	jne    82a0 <bench_ada__run_14.isra.0+0x250>
    82be:	mov    ecx,DWORD PTR [rsp+0x68]
    82c2:	lea    esi,[rcx*8+0x0]
    82c9:	cmp    esi,DWORD PTR [rsp+0x78]
    82cd:	je     8240 <bench_ada__run_14.isra.0+0x1f0>
    82d3:	lea    r10d,[rsi-0x1]
    82d7:	mov    r11d,DWORD PTR [rsp+0x78]
    82dc:	sub    r11d,esi
    82df:	lea    r14d,[r11-0x1]
    82e3:	cmp    r14d,0x2
    82e7:	jbe    831e <bench_ada__run_14.isra.0+0x2ce>
    82e9:	lea    r14,[r9+rsi*1]
    82ed:	lea    rcx,[rdi+r14*8]
    82f1:	mov    r14,QWORD PTR [rsp+0x70]
    82f6:	imul   r14,rdx
    82fa:	add    rsi,r14
    82fd:	vmulpd ymm2,ymm2,YMMWORD PTR [r12+rsi*8]
    8303:	mov    esi,r11d
    8306:	and    esi,0xfffffffc
    8309:	and    r11d,0x3
    830d:	vaddpd ymm2,ymm2,YMMWORD PTR [rcx]
    8311:	vmovupd YMMWORD PTR [rcx],ymm2
    8315:	je     8240 <bench_ada__run_14.isra.0+0x1f0>
    831b:	add    r10d,esi
    831e:	imul   rdx,QWORD PTR [rsp+0x70]
    8324:	lea    esi,[r10+0x1]
    8328:	mov    ecx,DWORD PTR [rsp+0x6c]
    832c:	lea    r14,[r9+rsi*1]
    8330:	mov    r11,rsi
    8333:	add    rsi,rdx
    8336:	vmulsd xmm0,xmm1,QWORD PTR [r12+rsi*8]
    833c:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    8342:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    8348:	cmp    ecx,r11d
    834b:	je     8240 <bench_ada__run_14.isra.0+0x1f0>
    8351:	lea    esi,[r10+0x2]
    8355:	lea    r14,[r9+rsi*1]
    8359:	mov    r11,rsi
    835c:	add    rsi,rdx
    835f:	vmulsd xmm0,xmm1,QWORD PTR [r12+rsi*8]
    8365:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    836b:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    8371:	cmp    ecx,r11d
    8374:	je     8240 <bench_ada__run_14.isra.0+0x1f0>
    837a:	lea    esi,[r10+0x3]
    837e:	lea    r10,[r9+rsi*1]
    8382:	add    rsi,rdx
    8385:	vmulsd xmm1,xmm1,QWORD PTR [r12+rsi*8]
    838b:	vaddsd xmm1,xmm1,QWORD PTR [rdi+r10*8]
    8391:	vmovsd QWORD PTR [rdi+r10*8],xmm1
    8397:	cmp    rax,r13
    839a:	jne    8249 <bench_ada__run_14.isra.0+0x1f9>
    83a0:	mov    r9,QWORD PTR [rsp+0x50]
    83a5:	cmp    r9,QWORD PTR [rsp+0x38]
    83aa:	jne    81c0 <bench_ada__run_14.isra.0+0x170>
    83b0:	mov    rax,QWORD PTR [rbp+0x10]
    83b4:	mov    rdx,QWORD PTR [rbp+0x18]
    83b8:	mov    rcx,QWORD PTR [rbp+0x20]
    83bc:	mov    rsi,QWORD PTR [rbp+0x30]
    83c0:	mov    eax,DWORD PTR [rsp+0x28]
    83c4:	cmp    DWORD PTR [rsp+0x14],eax
    83c8:	je     83fd <bench_ada__run_14.isra.0+0x3ad>
    83ca:	inc    eax
    83cc:	mov    rdx,QWORD PTR [rbp+0x18]
    83d0:	mov    rcx,QWORD PTR [rbp+0x20]
    83d4:	mov    rsi,QWORD PTR [rbp+0x30]
    83d8:	mov    DWORD PTR [rsp+0x28],eax
    83dc:	mov    rax,QWORD PTR [rbp+0x10]
    83e0:	vzeroupper
    83e3:	jmp    810e <bench_ada__run_14.isra.0+0xbe>
    83e8:	nop    DWORD PTR [rax+rax*1+0x0]
    83f0:	xor    esi,esi
    83f2:	mov    r10d,0xffffffff
    83f8:	jmp    82d7 <bench_ada__run_14.isra.0+0x287>
    83fd:	vzeroupper
    8400:	jmp    8176 <bench_ada__run_14.isra.0+0x126>
    8405:	nop
    8406:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_15.isra.0>:
    8410:	push   rbp
    8411:	mov    eax,edi
    8413:	mov    rbp,rsp
    8416:	push   r15
    8418:	push   r14
    841a:	push   r13
    841c:	push   r12
    841e:	push   rbx
    841f:	and    rsp,0xffffffffffffffc0
    8423:	add    rsp,0xffffffffffffff80
    8427:	mov    rdi,QWORD PTR [rbp+0x28]
    842b:	test   ecx,ecx
    842d:	je     8728 <bench_ada__run_15.isra.0+0x318>
    8433:	mov    DWORD PTR [rsp+0x34],eax
    8437:	mov    eax,edx
    8439:	mov    DWORD PTR [rsp+0x30],ecx
    843d:	mov    ecx,esi
    843f:	lea    rsi,[rax*8+0x0]
    8447:	mov    DWORD PTR [rsp+0x78],edx
    844b:	mov    eax,ecx
    844d:	mov    r12,r9
    8450:	lea    r9d,[rdx-0x1]
    8454:	mov    rdx,rsi
    8457:	mov    QWORD PTR [rsp+0x60],rsi
    845c:	mov    QWORD PTR [rsp+0x18],rax
    8461:	mov    DWORD PTR [rsp+0x2c],ecx
    8465:	mov    rbx,r8
    8468:	mov    r14d,r9d
    846b:	xor    r8d,r8d
    846e:	imul   rdx,rax
    8472:	shr    rsi,0x3
    8476:	mov    QWORD PTR [rsp+0x38],rdx
    847b:	lea    rdx,[rax*8+0x0]
    8483:	mov    QWORD PTR [rsp+0x68],rsi
    8488:	mov    QWORD PTR [rsp+0x20],rdx
    848d:	nop    DWORD PTR [rax]
    8490:	inc    r8d
    8493:	mov    rax,QWORD PTR [rbp+0x10]
    8497:	mov    rsi,QWORD PTR [rbp+0x18]
    849b:	mov    rdx,QWORD PTR [rbp+0x20]
    849f:	mov    DWORD PTR [rsp+0x7c],r8d
    84a4:	mov    rcx,QWORD PTR [rbp+0x30]
    84a8:	mov    rdx,QWORD PTR [rsp+0x38]
    84ad:	xor    esi,esi
    84af:	call   2bd0 <memset@plt>
    84b4:	mov    r8d,DWORD PTR [rsp+0x7c]
    84b9:	mov    rdi,rax
    84bc:	mov    eax,DWORD PTR [rsp+0x34]
    84c0:	test   eax,eax
    84c2:	je     870d <bench_ada__run_15.isra.0+0x2fd>
    84c8:	mov    edx,DWORD PTR [rsp+0x2c]
    84cc:	test   edx,edx
    84ce:	je     870d <bench_ada__run_15.isra.0+0x2fd>
    84d4:	lea    r15,[rax-0x1]
    84d8:	mov    rax,QWORD PTR [rsp+0x20]
    84dd:	mov    r10d,DWORD PTR [rsp+0x78]
    84e2:	mov    r9d,r8d
    84e5:	mov    rcx,0xffffffffffffffff
    84ec:	vxorpd xmm4,xmm4,xmm4
    84f0:	mov    r8,r15
    84f3:	shr    rax,0x3
    84f7:	mov    QWORD PTR [rsp+0x70],rax
    84fc:	mov    rax,QWORD PTR [rsp+0x18]
    8501:	and    r10d,0xfffffff8
    8505:	lea    rsi,[rax-0x1]
    8509:	mov    eax,DWORD PTR [rsp+0x78]
    850d:	shr    eax,0x3
    8510:	shl    rax,0x6
    8514:	mov    QWORD PTR [rsp+0x50],rax
    8519:	nop    DWORD PTR [rax+0x0]
    8520:	mov    rdx,QWORD PTR [rsp+0x60]
    8525:	inc    rcx
    8528:	mov    r15,QWORD PTR [rsp+0x68]
    852d:	mov    rax,0xffffffffffffffff
    8534:	movsxd r13,ecx
    8537:	imul   rdx,r13
    853b:	imul   r15,r13
    853f:	add    rdx,r12
    8542:	mov    QWORD PTR [rsp+0x58],rdx
    8547:	vmovq  xmm3,r15
    854c:	mov    r15d,r9d
    854f:	mov    r9,r13
    8552:	mov    r11,QWORD PTR [rsp+0x70]
    8557:	inc    rax
    855a:	movsxd rdx,eax
    855d:	imul   r11,r9
    8561:	lea    r13,[r11+rdx*1]
    8565:	vmovsd xmm2,QWORD PTR [rbx+r13*8]
    856b:	vcomisd xmm2,xmm4
    856f:	je     86f2 <bench_ada__run_15.isra.0+0x2e2>
    8575:	cmp    r14d,0xffffffff
    8579:	je     8740 <bench_ada__run_15.isra.0+0x330>
    857f:	mov    DWORD PTR [rsp+0x7c],r15d
    8584:	mov    QWORD PTR [rsp+0x48],rcx
    8589:	mov    QWORD PTR [rsp+0x40],r8
    858e:	cmp    r14d,0x6
    8592:	jbe    87be <bench_ada__run_15.isra.0+0x3ae>
    8598:	mov    rcx,QWORD PTR [rsp+0x60]
    859d:	mov    r15,QWORD PTR [rsp+0x50]
    85a2:	mov    r11,QWORD PTR [rsp+0x58]
    85a7:	vbroadcastsd zmm1,xmm2
    85ad:	imul   rcx,rdx
    85b1:	add    rcx,rdi
    85b4:	lea    r13,[r15+rcx*1]
    85b8:	mov    r15d,DWORD PTR [rsp+0x7c]
    85bd:	sub    r11,rcx
    85c0:	vmulpd zmm0,zmm1,ZMMWORD PTR [rcx+r11*1]
    85c7:	add    rcx,0x40
    85cb:	vaddpd zmm0,zmm0,ZMMWORD PTR [rcx-0x40]
    85d2:	vmovupd ZMMWORD PTR [rcx-0x40],zmm0
    85d9:	cmp    rcx,r13
    85dc:	jne    85c0 <bench_ada__run_15.isra.0+0x1b0>
    85de:	mov    DWORD PTR [rsp+0x7c],r15d
    85e3:	mov    r11d,r10d
    85e6:	cmp    r10d,DWORD PTR [rsp+0x78]
    85eb:	je     8810 <bench_ada__run_15.isra.0+0x400>
    85f1:	lea    r13d,[r10-0x1]
    85f5:	mov    r8d,DWORD PTR [rsp+0x78]
    85fa:	sub    r8d,r11d
    85fd:	lea    ecx,[r8-0x1]
    8601:	cmp    ecx,0x2
    8604:	jbe    8642 <bench_ada__run_15.isra.0+0x232>
    8606:	mov    rcx,QWORD PTR [rsp+0x68]
    860b:	vmovq  r15,xmm3
    8610:	vbroadcastsd ymm0,xmm2
    8615:	imul   rcx,rdx
    8619:	add    rcx,r11
    861c:	add    r11,r15
    861f:	vmulpd ymm0,ymm0,YMMWORD PTR [r12+r11*8]
    8625:	vaddpd ymm0,ymm0,YMMWORD PTR [rdi+rcx*8]
    862a:	vmovupd YMMWORD PTR [rdi+rcx*8],ymm0
    862f:	mov    ecx,r8d
    8632:	and    ecx,0xfffffffc
    8635:	and    r8d,0x3
    8639:	je     87d0 <bench_ada__run_15.isra.0+0x3c0>
    863f:	add    r13d,ecx
    8642:	imul   rdx,QWORD PTR [rsp+0x68]
    8648:	lea    ecx,[r13+0x1]
    864c:	vmovq  r15,xmm3
    8651:	mov    r8,rcx
    8654:	lea    r11,[rdx+rcx*1]
    8658:	add    rcx,r15
    865b:	vmulsd xmm0,xmm2,QWORD PTR [r12+rcx*8]
    8661:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r11*8]
    8667:	vmovsd QWORD PTR [rdi+r11*8],xmm0
    866d:	cmp    r14d,r8d
    8670:	je     8770 <bench_ada__run_15.isra.0+0x360>
    8676:	lea    ecx,[r13+0x2]
    867a:	lea    r11,[rdx+rcx*1]
    867e:	mov    r8,rcx
    8681:	add    rcx,r15
    8684:	vmulsd xmm0,xmm2,QWORD PTR [r12+rcx*8]
    868a:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r11*8]
    8690:	vmovsd QWORD PTR [rdi+r11*8],xmm0
    8696:	cmp    r14d,r8d
    8699:	je     8770 <bench_ada__run_15.isra.0+0x360>
    869f:	lea    ecx,[r13+0x3]
    86a3:	add    rdx,rcx
    86a6:	add    rcx,r15
    86a9:	vmulsd xmm2,xmm2,QWORD PTR [r12+rcx*8]
    86af:	vaddsd xmm2,xmm2,QWORD PTR [rdi+rdx*8]
    86b4:	vmovsd QWORD PTR [rdi+rdx*8],xmm2
    86b9:	cmp    rax,rsi
    86bc:	je     87e0 <bench_ada__run_15.isra.0+0x3d0>
    86c2:	mov    rcx,QWORD PTR [rsp+0x70]
    86c7:	inc    rax
    86ca:	movsxd rdx,eax
    86cd:	imul   rcx,r9
    86d1:	add    rcx,rdx
    86d4:	vmovsd xmm2,QWORD PTR [rbx+rcx*8]
    86d9:	vcomisd xmm2,xmm4
    86dd:	jne    858e <bench_ada__run_15.isra.0+0x17e>
    86e3:	mov    r15d,DWORD PTR [rsp+0x7c]
    86e8:	mov    rcx,QWORD PTR [rsp+0x48]
    86ed:	mov    r8,QWORD PTR [rsp+0x40]
    86f2:	cmp    rsi,rax
    86f5:	jne    8552 <bench_ada__run_15.isra.0+0x142>
    86fb:	mov    r9d,r15d
    86fe:	cmp    rcx,r8
    8701:	jne    8520 <bench_ada__run_15.isra.0+0x110>
    8707:	mov    r8d,r9d
    870a:	vzeroupper
    870d:	mov    rax,QWORD PTR [rbp+0x10]
    8711:	mov    rsi,QWORD PTR [rbp+0x18]
    8715:	mov    rdx,QWORD PTR [rbp+0x20]
    8719:	mov    rcx,QWORD PTR [rbp+0x30]
    871d:	cmp    DWORD PTR [rsp+0x30],r8d
    8722:	jne    8490 <bench_ada__run_15.isra.0+0x80>
    8728:	lea    rsp,[rbp-0x28]
    872c:	pop    rbx
    872d:	pop    r12
    872f:	pop    r13
    8731:	pop    r14
    8733:	pop    r15
    8735:	pop    rbp
    8736:	ret
    8737:	nop    WORD PTR [rax+rax*1+0x0]
    8740:	cmp    rsi,rax
    8743:	je     86fb <bench_ada__run_15.isra.0+0x2eb>
    8745:	lea    rdx,[rax+0x1]
    8749:	cmp    rdx,rsi
    874c:	je     86fb <bench_ada__run_15.isra.0+0x2eb>
    874e:	add    rax,0x2
    8752:	movsxd rdx,eax
    8755:	add    rdx,r11
    8758:	vcomisd xmm4,QWORD PTR [rbx+rdx*8]
    875d:	jne    8740 <bench_ada__run_15.isra.0+0x330>
    875f:	jmp    86f2 <bench_ada__run_15.isra.0+0x2e2>
    8761:	nop    DWORD PTR [rax+0x0]
    8765:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8770:	cmp    rax,rsi
    8773:	je     87e0 <bench_ada__run_15.isra.0+0x3d0>
    8775:	mov    r11,QWORD PTR [rsp+0x70]
    877a:	lea    rcx,[rax+0x1]
    877e:	movsxd rdx,ecx
    8781:	imul   r11,r9
    8785:	lea    r13,[r11+rdx*1]
    8789:	vmovsd xmm2,QWORD PTR [rbx+r13*8]
    878f:	vcomisd xmm2,xmm4
    8793:	jne    8800 <bench_ada__run_15.isra.0+0x3f0>
    8795:	cmp    rsi,rcx
    8798:	je     87e0 <bench_ada__run_15.isra.0+0x3d0>
    879a:	add    rax,0x2
    879e:	movsxd rdx,eax
    87a1:	add    r11,rdx
    87a4:	vmovsd xmm2,QWORD PTR [rbx+r11*8]
    87aa:	vcomisd xmm2,xmm4
    87ae:	je     86e3 <bench_ada__run_15.isra.0+0x2d3>
    87b4:	cmp    r14d,0x6
    87b8:	ja     8598 <bench_ada__run_15.isra.0+0x188>
    87be:	xor    r11d,r11d
    87c1:	mov    r13d,0xffffffff
    87c7:	jmp    85f5 <bench_ada__run_15.isra.0+0x1e5>
    87cc:	nop    DWORD PTR [rax+0x0]
    87d0:	cmp    rax,rsi
    87d3:	jne    86c2 <bench_ada__run_15.isra.0+0x2b2>
    87d9:	nop    DWORD PTR [rax+0x0]
    87e0:	mov    r9d,DWORD PTR [rsp+0x7c]
    87e5:	mov    rcx,QWORD PTR [rsp+0x48]
    87ea:	mov    r8,QWORD PTR [rsp+0x40]
    87ef:	jmp    86fe <bench_ada__run_15.isra.0+0x2ee>
    87f4:	nop
    87f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8800:	mov    rax,rcx
    8803:	jmp    858e <bench_ada__run_15.isra.0+0x17e>
    8808:	nop    DWORD PTR [rax+rax*1+0x0]
    8810:	cmp    rax,rsi
    8813:	je     87e0 <bench_ada__run_15.isra.0+0x3d0>
    8815:	mov    rcx,QWORD PTR [rsp+0x70]
    881a:	inc    rax
    881d:	movsxd rdx,eax
    8820:	imul   rcx,r9
    8824:	add    rcx,rdx
    8827:	vmovsd xmm2,QWORD PTR [rbx+rcx*8]
    882c:	vcomisd xmm2,xmm4
    8830:	jne    858e <bench_ada__run_15.isra.0+0x17e>
    8836:	mov    rcx,QWORD PTR [rsp+0x48]
    883b:	mov    r8,QWORD PTR [rsp+0x40]
    8840:	jmp    86f2 <bench_ada__run_15.isra.0+0x2e2>
    8845:	nop
    8846:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_16.isra.0>:
    5d80:	push   rbp
    5d81:	mov    eax,edi
    5d83:	mov    r10d,esi
    5d86:	mov    r11d,edx
    5d89:	mov    rbp,rsp
    5d8c:	push   r15
    5d8e:	push   r14
    5d90:	push   r13
    5d92:	push   r12
    5d94:	push   rbx
    5d95:	and    rsp,0xffffffffffffffe0
    5d99:	sub    rsp,0x60
    5d9d:	mov    rdi,QWORD PTR [rbp+0x18]
    5da1:	mov    rsi,QWORD PTR [rbp+0x20]
    5da5:	mov    r15,QWORD PTR [rbp+0x28]
    5da9:	mov    rdx,QWORD PTR [rbp+0x30]
    5dad:	test   ecx,ecx
    5daf:	je     5fe1 <bench_ada__run_16.isra.0+0x261>
    5db5:	mov    r14,QWORD PTR [rbp+0x10]
    5db9:	mov    r12,r8
    5dbc:	mov    rbx,r9
    5dbf:	test   r11d,r11d
    5dc2:	je     6097 <bench_ada__run_16.isra.0+0x317>
    5dc8:	lea    r14d,[rax-0x1]
    5dcc:	mov    DWORD PTR [rsp+0x34],ecx
    5dd0:	mov    ecx,r11d
    5dd3:	mov    DWORD PTR [rsp+0x5c],r10d
    5dd8:	mov    DWORD PTR [rsp+0x58],r14d
    5ddd:	lea    r14d,[r10-0x1]
    5de1:	mov    DWORD PTR [rsp+0x24],eax
    5de5:	mov    QWORD PTR [rsp+0x28],rcx
    5dea:	mov    DWORD PTR [rsp+0x4c],r14d
    5def:	mov    DWORD PTR [rsp+0x48],0x1
    5df7:	mov    QWORD PTR [rbp+0x18],rdi
    5dfb:	mov    r13d,eax
    5dfe:	mov    rdi,rsi
    5e01:	mov    rsi,rdx
    5e04:	mov    rdx,r15
    5e07:	lea    r15,[rcx*8+0x0]
    5e0f:	mov    eax,DWORD PTR [rsp+0x58]
    5e13:	cmp    eax,0xffffffff
    5e16:	je     6062 <bench_ada__run_16.isra.0+0x2e2>
    5e1c:	mov    rax,rsi
    5e1f:	mov    esi,DWORD PTR [rsp+0x4c]
    5e23:	cmp    esi,0xffffffff
    5e26:	je     5ff0 <bench_ada__run_16.isra.0+0x270>
    5e2c:	mov    esi,DWORD PTR [rsp+0x5c]
    5e30:	cmp    esi,0x3
    5e33:	je     6491 <bench_ada__run_16.isra.0+0x711>
    5e39:	jg     5f05 <bench_ada__run_16.isra.0+0x185>
    5e3f:	dec    esi
    5e41:	je     63d7 <bench_ada__run_16.isra.0+0x657>
    5e47:	mov    r14d,DWORD PTR [rsp+0x24]
    5e4c:	mov    rsi,rax
    5e4f:	mov    rax,QWORD PTR [rsp+0x28]
    5e54:	mov    r10,rdx
    5e57:	mov    r11,0xffffffffffffffff
    5e5e:	vxorpd xmm2,xmm2,xmm2
    5e62:	dec    r14
    5e65:	lea    r9,[rax-0x1]
    5e69:	nop    DWORD PTR [rax+0x0]
    5e70:	inc    r11
    5e73:	mov    rcx,0xffffffffffffffff
    5e7a:	movsxd r8,r11d
    5e7d:	shl    r8,0x4
    5e81:	add    r8,r12
    5e84:	nop    DWORD PTR [rax+rax*1+0x0]
    5e89:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5e94:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5e9f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5eaa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5eb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5ec0:	inc    rcx
    5ec3:	movsxd rax,ecx
    5ec6:	shl    rax,0x4
    5eca:	add    rax,rbx
    5ecd:	vmovsd xmm0,QWORD PTR [rax]
    5ed1:	vmulsd xmm0,xmm0,QWORD PTR [r8]
    5ed6:	vmovsd xmm1,QWORD PTR [rax+0x8]
    5edb:	vmulsd xmm1,xmm1,QWORD PTR [r8+0x8]
    5ee1:	vaddsd xmm0,xmm0,xmm1
    5ee5:	vaddsd xmm0,xmm0,xmm2
    5ee9:	vmovsd QWORD PTR [r10+rcx*8],xmm0
    5eef:	cmp    rcx,r9
    5ef2:	jne    5ec0 <bench_ada__run_16.isra.0+0x140>
    5ef4:	add    r10,r15
    5ef7:	cmp    r11,r14
    5efa:	jne    5e70 <bench_ada__run_16.isra.0+0xf0>
    5f00:	jmp    5fcc <bench_ada__run_16.isra.0+0x24c>
    5f05:	cmp    DWORD PTR [rsp+0x5c],0x4
    5f0a:	jne    60ba <bench_ada__run_16.isra.0+0x33a>
    5f10:	mov    rsi,rax
    5f13:	mov    rax,QWORD PTR [rsp+0x28]
    5f18:	mov    r14d,DWORD PTR [rsp+0x24]
    5f1d:	mov    r10,rdx
    5f20:	xor    r11d,r11d
    5f23:	lea    r9,[rax-0x1]
    5f27:	nop    WORD PTR [rax+rax*1+0x0]
    5f30:	movsxd r8,r11d
    5f33:	mov    rax,0xffffffffffffffff
    5f3a:	shl    r8,0x5
    5f3e:	add    r8,r12
    5f41:	nop    DWORD PTR [rax+rax*1+0x0]
    5f49:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f54:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f5f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f80:	inc    rax
    5f83:	vmovupd ymm0,YMMWORD PTR [r8]
    5f88:	movsxd rcx,eax
    5f8b:	shl    rcx,0x5
    5f8f:	vmulpd ymm0,ymm0,YMMWORD PTR [rcx+rbx*1]
    5f94:	vextractf64x2 xmm2,ymm0,0x1
    5f9b:	vunpckhpd xmm1,xmm0,xmm0
    5f9f:	vaddsd xmm2,xmm2,xmm0
    5fa3:	valignq ymm0,ymm0,ymm0,0x3
    5faa:	vaddsd xmm1,xmm1,xmm0
    5fae:	vaddsd xmm1,xmm2,xmm1
    5fb2:	vmovsd QWORD PTR [r10+rax*8],xmm1
    5fb8:	cmp    rax,r9
    5fbb:	jne    5f80 <bench_ada__run_16.isra.0+0x200>
    5fbd:	inc    r11
    5fc0:	add    r10,r15
    5fc3:	cmp    r14,r11
    5fc6:	jne    5f30 <bench_ada__run_16.isra.0+0x1b0>
    5fcc:	mov    rax,QWORD PTR [rbp+0x10]
    5fd0:	mov    rcx,QWORD PTR [rbp+0x18]
    5fd4:	mov    eax,DWORD PTR [rsp+0x48]
    5fd8:	cmp    DWORD PTR [rsp+0x34],eax
    5fdc:	jne    604f <bench_ada__run_16.isra.0+0x2cf>
    5fde:	vzeroupper
    5fe1:	lea    rsp,[rbp-0x28]
    5fe5:	pop    rbx
    5fe6:	pop    r12
    5fe8:	pop    r13
    5fea:	pop    r14
    5fec:	pop    r15
    5fee:	pop    rbp
    5fef:	ret
    5ff0:	mov    QWORD PTR [rsp+0x50],r12
    5ff5:	mov    QWORD PTR [rsp+0x40],rbx
    5ffa:	mov    QWORD PTR [rbp+0x20],rdi
    5ffe:	xor    ebx,ebx
    6000:	mov    rcx,rdx
    6003:	mov    r12,rdx
    6006:	mov    r14,rax
    6009:	vzeroupper
    600c:	nop    DWORD PTR [rax+0x0]
    6010:	mov    rdi,rcx
    6013:	mov    rdx,r15
    6016:	xor    esi,esi
    6018:	inc    rbx
    601b:	call   2bd0 <memset@plt>
    6020:	lea    rcx,[rax+r15*1]
    6024:	cmp    rbx,r13
    6027:	jne    6010 <bench_ada__run_16.isra.0+0x290>
    6029:	mov    rdx,r12
    602c:	mov    rbx,QWORD PTR [rsp+0x40]
    6031:	mov    rdi,QWORD PTR [rbp+0x20]
    6035:	mov    r12,QWORD PTR [rsp+0x50]
    603a:	mov    rax,QWORD PTR [rbp+0x10]
    603e:	mov    rcx,QWORD PTR [rbp+0x18]
    6042:	mov    rsi,r14
    6045:	mov    eax,DWORD PTR [rsp+0x48]
    6049:	cmp    DWORD PTR [rsp+0x34],eax
    604d:	je     5fe1 <bench_ada__run_16.isra.0+0x261>
    604f:	inc    eax
    6051:	mov    rcx,QWORD PTR [rbp+0x18]
    6055:	mov    DWORD PTR [rsp+0x48],eax
    6059:	mov    rax,QWORD PTR [rbp+0x10]
    605d:	jmp    5e0f <bench_ada__run_16.isra.0+0x8f>
    6062:	mov    r15,rdx
    6065:	mov    ecx,DWORD PTR [rsp+0x48]
    6069:	mov    rdx,rsi
    606c:	mov    rax,QWORD PTR [rbp+0x10]
    6070:	mov    rsi,rdi
    6073:	mov    r8d,DWORD PTR [rsp+0x34]
    6078:	mov    rdi,QWORD PTR [rbp+0x18]
    607c:	cmp    r8d,ecx
    607f:	je     5fde <bench_ada__run_16.isra.0+0x25e>
    6085:	lea    r9d,[rcx+0x1]
    6089:	cmp    r8d,r9d
    608c:	je     5fde <bench_ada__run_16.isra.0+0x25e>
    6092:	add    ecx,0x2
    6095:	jmp    607c <bench_ada__run_16.isra.0+0x2fc>
    6097:	mov    r8,QWORD PTR [rbp+0x10]
    609b:	mov    eax,0x1
    60a0:	cmp    ecx,eax
    60a2:	je     5fe1 <bench_ada__run_16.isra.0+0x261>
    60a8:	lea    r9d,[rax+0x1]
    60ac:	cmp    ecx,r9d
    60af:	je     5fe1 <bench_ada__run_16.isra.0+0x261>
    60b5:	add    eax,0x2
    60b8:	jmp    60a0 <bench_ada__run_16.isra.0+0x320>
    60ba:	vmovd  xmm7,DWORD PTR [rsp+0x5c]
    60c0:	vmovd  xmm14,DWORD PTR [rsp+0x58]
    60c6:	mov    QWORD PTR [rsp+0x50],rdx
    60cb:	mov    QWORD PTR [rbp+0x20],rdi
    60cf:	vmovd  xmm5,DWORD PTR [rsp+0x4c]
    60d5:	mov    QWORD PTR [rbp+0x28],rdx
    60d9:	lea    r10,[r12+0x20]
    60de:	mov    QWORD PTR [rbp+0x30],rax
    60e2:	vmovq  xmm18,r13
    60e8:	mov    rax,0xffffffffffffffff
    60ef:	vmovq  xmm17,r15
    60f5:	vmovq  xmm4,r10
    60fa:	vmovq  rsi,xmm7
    60ff:	mov    r9d,esi
    6102:	sar    r9d,0x2
    6106:	and    esi,0x3
    6109:	dec    r9d
    610c:	mov    DWORD PTR [rsp+0x20],esi
    6110:	mov    rsi,QWORD PTR [rsp+0x28]
    6115:	mov    r14d,r9d
    6118:	sar    r14d,1
    611b:	lea    ecx,[r14-0x1]
    611f:	mov    DWORD PTR [rsp+0x30],r14d
    6124:	sub    r14d,0x3
    6128:	lea    r8,[rsi-0x1]
    612c:	lea    esi,[r9*4+0x0]
    6134:	or     r14d,0x1
    6138:	mov    r13d,ecx
    613b:	mov    QWORD PTR [rsp+0x40],r8
    6140:	vmovq  xmm3,rsi
    6145:	inc    rax
    6148:	vmovq  rdx,xmm7
    614d:	vmovq  rdi,xmm4
    6152:	movsxd r10,eax
    6155:	mov    QWORD PTR [rsp+0x18],rax
    615a:	mov    rax,0xffffffffffffffff
    6161:	imul   r10,rdx
    6165:	lea    r11,[r10*8+0x0]
    616d:	mov    r15,r10
    6170:	add    rdi,r11
    6173:	lea    rsi,[r12+r11*1]
    6177:	mov    QWORD PTR [rsp+0x38],rdi
    617c:	vmovq  rdi,xmm3
    6181:	add    rdi,r10
    6184:	lea    rdi,[r12+rdi*8]
    6188:	vmovq  xmm6,rdi
    618d:	vmovq  rdi,xmm5
    6192:	add    rdi,r10
    6195:	vmovq  xmm15,rdi
    619a:	nop    WORD PTR [rax+rax*1+0x0]
    61a0:	inc    rax
    61a3:	mov    r9,rdx
    61a6:	vmovupd ymm0,YMMWORD PTR [rsi]
    61aa:	movsxd r8,eax
    61ad:	imul   r9,r8
    61b1:	vmulpd ymm0,ymm0,YMMWORD PTR [rbx+r9*8]
    61b7:	cmp    r13d,0xffffffff
    61bb:	je     6320 <bench_ada__run_16.isra.0+0x5a0>
    61c1:	cmp    DWORD PTR [rsp+0x30],0x2
    61c6:	jle    63cc <bench_ada__run_16.isra.0+0x64c>
    61cc:	mov    rcx,QWORD PTR [rsp+0x38]
    61d1:	lea    rdi,[rbx+r9*8+0x20]
    61d6:	mov    r11d,0xffffffff
    61dc:	vmovupd ymm2,YMMWORD PTR [rdi]
    61e0:	vmulpd ymm2,ymm2,YMMWORD PTR [rcx]
    61e4:	vmovupd ymm1,YMMWORD PTR [rdi+0x20]
    61e9:	add    r11d,0x2
    61ed:	vmulpd ymm1,ymm1,YMMWORD PTR [rcx+0x20]
    61f2:	sub    rdi,0xffffffffffffff80
    61f6:	sub    rcx,0xffffffffffffff80
    61fa:	vaddpd ymm0,ymm2,ymm0
    61fe:	vaddpd ymm1,ymm1,ymm0
    6202:	vmovupd ymm0,YMMWORD PTR [rdi-0x40]
    6207:	vmulpd ymm0,ymm0,YMMWORD PTR [rcx-0x40]
    620c:	vaddpd ymm1,ymm1,ymm0
    6210:	vmovupd ymm0,YMMWORD PTR [rdi-0x20]
    6215:	vmulpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    621a:	vaddpd ymm0,ymm1,ymm0
    621e:	cmp    r11d,r14d
    6221:	jne    61dc <bench_ada__run_16.isra.0+0x45c>
    6223:	movsxd rcx,r11d
    6226:	inc    r11d
    6229:	shl    rcx,0x3
    622d:	lea    rdi,[r9+rcx*1+0xc]
    6232:	lea    r10,[r15+rcx*1+0xc]
    6237:	vmovupd ymm1,YMMWORD PTR [r12+r10*8]
    623d:	vmulpd ymm1,ymm1,YMMWORD PTR [rbx+rdi*8]
    6242:	vmovupd ymm10,YMMWORD PTR [r12+r10*8+0x20]
    6249:	vmulpd ymm10,ymm10,YMMWORD PTR [rbx+rdi*8+0x20]
    624f:	vaddpd ymm0,ymm1,ymm0
    6253:	vaddpd ymm0,ymm10,ymm0
    6257:	cmp    r11d,r13d
    625a:	je     6286 <bench_ada__run_16.isra.0+0x506>
    625c:	lea    rdi,[r9+rcx*1+0x14]
    6261:	lea    rcx,[r15+rcx*1+0x14]
    6266:	vmovupd ymm1,YMMWORD PTR [rbx+rdi*8]
    626b:	vmulpd ymm1,ymm1,YMMWORD PTR [r12+rcx*8]
    6271:	vaddpd ymm1,ymm1,ymm0
    6275:	vmovupd ymm0,YMMWORD PTR [rbx+rdi*8+0x20]
    627b:	vmulpd ymm0,ymm0,YMMWORD PTR [r12+rcx*8+0x20]
    6282:	vaddpd ymm0,ymm0,ymm1
    6286:	test   BYTE PTR [rsp+0x5c],0x4
    628b:	jne    62a9 <bench_ada__run_16.isra.0+0x529>
    628d:	vmovq  rdi,xmm3
    6292:	add    r9,rdi
    6295:	vmovq  rdi,xmm6
    629a:	vmovupd ymm10,YMMWORD PTR [rdi]
    629e:	vmulpd ymm10,ymm10,YMMWORD PTR [rbx+r9*8]
    62a4:	vaddpd ymm0,ymm0,ymm10
    62a9:	cmp    DWORD PTR [rsp+0x20],0x0
    62ae:	jne    632b <bench_ada__run_16.isra.0+0x5ab>
    62b0:	vunpckhpd xmm11,xmm0,xmm0
    62b4:	vextractf64x2 xmm12,ymm0,0x1
    62bb:	vaddsd xmm10,xmm0,xmm12
    62c0:	valignq ymm0,ymm0,ymm0,0x3
    62c7:	vaddsd xmm11,xmm11,xmm0
    62cb:	vaddsd xmm0,xmm10,xmm11
    62d0:	mov    rdi,QWORD PTR [rsp+0x50]
    62d5:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    62da:	cmp    QWORD PTR [rsp+0x40],rax
    62df:	jne    61a0 <bench_ada__run_16.isra.0+0x420>
    62e5:	mov    rax,QWORD PTR [rsp+0x18]
    62ea:	vmovq  rdx,xmm14
    62ef:	vmovq  rdi,xmm17
    62f5:	add    QWORD PTR [rsp+0x50],rdi
    62fa:	cmp    rax,rdx
    62fd:	jne    6145 <bench_ada__run_16.isra.0+0x3c5>
    6303:	mov    rdi,QWORD PTR [rbp+0x20]
    6307:	mov    rdx,QWORD PTR [rbp+0x28]
    630b:	mov    rax,QWORD PTR [rbp+0x30]
    630f:	vmovq  r15,xmm17
    6315:	vmovq  r13,xmm18
    631b:	jmp    6468 <bench_ada__run_16.isra.0+0x6e8>
    6320:	cmp    DWORD PTR [rsp+0x5c],0x7
    6325:	jg     6286 <bench_ada__run_16.isra.0+0x506>
    632b:	imul   r8,rdx
    632f:	vmovq  rdi,xmm5
    6334:	lea    rcx,[r8+rdi*1]
    6338:	vmovq  rdi,xmm15
    633d:	vmovsd xmm12,QWORD PTR [rbx+rcx*8]
    6342:	vmulsd xmm12,xmm12,QWORD PTR [r12+rdi*8]
    6348:	mov    edi,DWORD PTR [rsp+0x20]
    634c:	cmp    edi,0x2
    634f:	je     6521 <bench_ada__run_16.isra.0+0x7a1>
    6355:	cmp    edi,0x3
    6358:	jne    63a2 <bench_ada__run_16.isra.0+0x622>
    635a:	vmovq  rdi,xmm5
    635f:	vmovq  rcx,xmm5
    6364:	lea    rdi,[r8+rdi*1-0x2]
    6369:	lea    rcx,[r15+rcx*1-0x2]
    636e:	vmovsd xmm10,QWORD PTR [rbx+rdi*8]
    6373:	vmovq  rdi,xmm5
    6378:	vmulsd xmm10,xmm10,QWORD PTR [r12+rcx*8]
    637e:	vmovq  rcx,xmm5
    6383:	lea    rdi,[r8+rdi*1-0x1]
    6388:	lea    rcx,[r15+rcx*1-0x1]
    638d:	vmovsd xmm11,QWORD PTR [rbx+rdi*8]
    6392:	vmulsd xmm11,xmm11,QWORD PTR [r12+rcx*8]
    6398:	vaddsd xmm10,xmm10,xmm11
    639d:	vaddsd xmm12,xmm12,xmm10
    63a2:	vextractf64x2 xmm13,ymm0,0x1
    63a9:	vunpckhpd xmm11,xmm0,xmm0
    63ad:	vaddsd xmm10,xmm0,xmm13
    63b2:	valignq ymm0,ymm0,ymm0,0x3
    63b9:	vaddsd xmm11,xmm11,xmm0
    63bd:	vaddsd xmm0,xmm10,xmm11
    63c2:	vaddsd xmm0,xmm0,xmm12
    63c7:	jmp    62d0 <bench_ada__run_16.isra.0+0x550>
    63cc:	mov    r11d,0xffffffff
    63d2:	jmp    6223 <bench_ada__run_16.isra.0+0x4a3>
    63d7:	mov    r14d,DWORD PTR [rsp+0x24]
    63dc:	mov    rsi,QWORD PTR [rsp+0x28]
    63e1:	mov    r9,rdx
    63e4:	mov    r11,0xffffffffffffffff
    63eb:	vxorpd xmm1,xmm1,xmm1
    63ef:	dec    r14
    63f2:	lea    r8,[rsi-0x1]
    63f6:	cs nop WORD PTR [rax+rax*1+0x0]
    6400:	inc    r11
    6403:	mov    rcx,0xffffffffffffffff
    640a:	movsxd r10,r11d
    640d:	nop    DWORD PTR [rax+0x0]
    6414:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    641f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    642a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6435:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6440:	inc    rcx
    6443:	movsxd rsi,ecx
    6446:	vmovsd xmm0,QWORD PTR [rbx+rsi*8]
    644b:	vmulsd xmm0,xmm0,QWORD PTR [r12+r10*8]
    6451:	vaddsd xmm0,xmm0,xmm1
    6455:	vmovsd QWORD PTR [r9+rcx*8],xmm0
    645b:	cmp    rcx,r8
    645e:	jne    6440 <bench_ada__run_16.isra.0+0x6c0>
    6460:	add    r9,r15
    6463:	cmp    r11,r14
    6466:	jne    6400 <bench_ada__run_16.isra.0+0x680>
    6468:	mov    rsi,QWORD PTR [rbp+0x10]
    646c:	mov    rcx,QWORD PTR [rbp+0x18]
    6470:	mov    esi,DWORD PTR [rsp+0x48]
    6474:	cmp    DWORD PTR [rsp+0x34],esi
    6478:	je     5fde <bench_ada__run_16.isra.0+0x25e>
    647e:	inc    esi
    6480:	mov    rcx,QWORD PTR [rbp+0x18]
    6484:	mov    DWORD PTR [rsp+0x48],esi
    6488:	mov    rsi,QWORD PTR [rbp+0x10]
    648c:	jmp    5e1f <bench_ada__run_16.isra.0+0x9f>
    6491:	mov    r14d,DWORD PTR [rsp+0x24]
    6496:	mov    rsi,QWORD PTR [rsp+0x28]
    649b:	mov    r10,rdx
    649e:	mov    r11,0xffffffffffffffff
    64a5:	vxorpd xmm2,xmm2,xmm2
    64a9:	dec    r14
    64ac:	lea    r8,[rsi-0x1]
    64b0:	inc    r11
    64b3:	mov    rcx,0xffffffffffffffff
    64ba:	movsxd rsi,r11d
    64bd:	lea    rsi,[rsi+rsi*2]
    64c1:	lea    r9,[r12+rsi*8]
    64c5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    64d0:	inc    rcx
    64d3:	movsxd rsi,ecx
    64d6:	lea    rsi,[rsi+rsi*2]
    64da:	lea    rsi,[rbx+rsi*8]
    64de:	vmovsd xmm0,QWORD PTR [rsi]
    64e2:	vmulsd xmm0,xmm0,QWORD PTR [r9]
    64e7:	vmovsd xmm1,QWORD PTR [rsi+0x8]
    64ec:	vmulsd xmm1,xmm1,QWORD PTR [r9+0x8]
    64f2:	vaddsd xmm0,xmm0,xmm1
    64f6:	vmovsd xmm1,QWORD PTR [rsi+0x10]
    64fb:	vmulsd xmm1,xmm1,QWORD PTR [r9+0x10]
    6501:	vaddsd xmm0,xmm0,xmm1
    6505:	vaddsd xmm0,xmm0,xmm2
    6509:	vmovsd QWORD PTR [r10+rcx*8],xmm0
    650f:	cmp    rcx,r8
    6512:	jne    64d0 <bench_ada__run_16.isra.0+0x750>
    6514:	add    r10,r15
    6517:	cmp    r11,r14
    651a:	jne    64b0 <bench_ada__run_16.isra.0+0x730>
    651c:	jmp    6468 <bench_ada__run_16.isra.0+0x6e8>
    6521:	vmovq  rdi,xmm5
    6526:	vmovq  rcx,xmm5
    652b:	lea    rdi,[r8+rdi*1-0x1]
    6530:	lea    rcx,[r15+rcx*1-0x1]
    6535:	vmovsd xmm10,QWORD PTR [rbx+rdi*8]
    653a:	vmulsd xmm10,xmm10,QWORD PTR [r12+rcx*8]
    6540:	vaddsd xmm12,xmm12,xmm10
    6545:	jmp    63a2 <bench_ada__run_16.isra.0+0x622>
    654a:	nop    WORD PTR [rax+rax*1+0x0]


<bench_ada__run_17.isra.0>:
    8850:	push   rbp
    8851:	mov    rbp,rsp
    8854:	push   r15
    8856:	push   r14
    8858:	push   r13
    885a:	push   r12
    885c:	push   rbx
    885d:	and    rsp,0xffffffffffffffc0
    8861:	add    rsp,0xffffffffffffff80
    8865:	mov    r10,QWORD PTR [rbp+0x20]
    8869:	mov    QWORD PTR [rsp+0x58],r8
    886e:	mov    QWORD PTR [rsp+0x50],r9
    8873:	test   edx,edx
    8875:	je     8c8a <bench_ada__run_17.isra.0+0x43a>
    887b:	mov    DWORD PTR [rsp+0x34],edi
    887f:	dec    edi
    8881:	mov    rbx,rcx
    8884:	mov    ecx,esi
    8886:	mov    DWORD PTR [rsp+0x40],edi
    888a:	lea    edi,[rsi-0x1]
    888d:	mov    DWORD PTR [rsp+0x44],edx
    8891:	lea    rdx,[rcx*8+0x0]
    8899:	mov    DWORD PTR [rsp+0x48],edi
    889d:	mov    rdi,rcx
    88a0:	xor    eax,eax
    88a2:	lea    r14,[rcx-0x1]
    88a6:	imul   rdi,rdx
    88aa:	test   esi,esi
    88ac:	cmovne rax,rdx
    88b0:	mov    r12,rax
    88b3:	xor    eax,eax
    88b5:	mov    QWORD PTR [rsp+0x38],rdi
    88ba:	mov    DWORD PTR [rsp+0x4c],eax
    88be:	xchg   ax,ax
    88c0:	inc    DWORD PTR [rsp+0x4c]
    88c4:	mov    rax,QWORD PTR [rsp+0x58]
    88c9:	mov    rdi,QWORD PTR [rsp+0x50]
    88ce:	mov    rdx,QWORD PTR [rbp+0x10]
    88d2:	mov    rsi,QWORD PTR [rbp+0x18]
    88d6:	mov    rcx,QWORD PTR [rbp+0x28]
    88da:	mov    eax,DWORD PTR [rsp+0x48]
    88de:	cmp    eax,0xffffffff
    88e1:	je     8ce8 <bench_ada__run_17.isra.0+0x498>
    88e7:	mov    rdx,QWORD PTR [rsp+0x38]
    88ec:	mov    rdi,r10
    88ef:	xor    esi,esi
    88f1:	call   2bd0 <memset@plt>
    88f6:	vxorpd xmm6,xmm6,xmm6
    88fa:	mov    r10,rax
    88fd:	mov    eax,DWORD PTR [rsp+0x40]
    8901:	cmp    eax,0xffffffff
    8904:	je     8b08 <bench_ada__run_17.isra.0+0x2b8>
    890a:	mov    eax,DWORD PTR [rsp+0x34]
    890e:	mov    QWORD PTR [rsp+0x70],r12
    8913:	mov    r8,0xffffffffffffffff
    891a:	vmovq  xmm3,r14
    891f:	lea    rcx,[rax-0x1]
    8923:	mov    rax,r12
    8926:	shr    rax,0x3
    892a:	mov    QWORD PTR [rsp+0x60],rcx
    892f:	mov    QWORD PTR [rsp+0x78],rax
    8934:	nop
    8935:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8940:	mov    r15,QWORD PTR [rsp+0x70]
    8945:	inc    r8
    8948:	mov    r9d,0x1
    894e:	movsxd rdx,r8d
    8951:	imul   r15,rdx
    8955:	lea    rax,[r15+rbx*1]
    8959:	mov    r15,QWORD PTR [rsp+0x78]
    895e:	mov    QWORD PTR [rsp+0x68],rax
    8963:	vmovq  rax,xmm3
    8968:	imul   r15,rdx
    896c:	mov    rdx,0xffffffffffffffff
    8973:	mov    r12,r15
    8976:	jmp    898c <bench_ada__run_17.isra.0+0x13c>
    8978:	nop    DWORD PTR [rax+rax*1+0x0]
    8980:	inc    r9d
    8983:	cmp    rdx,rax
    8986:	je     8af0 <bench_ada__run_17.isra.0+0x2a0>
    898c:	inc    rdx
    898f:	movsxd r15,edx
    8992:	mov    r14d,edx
    8995:	lea    rcx,[r12+r15*1]
    8999:	vmovsd xmm1,QWORD PTR [rbx+rcx*8]
    899e:	vbroadcastsd zmm2,xmm1
    89a4:	test   edx,edx
    89a6:	js     8980 <bench_ada__run_17.isra.0+0x130>
    89a8:	vcomisd xmm1,xmm6
    89ac:	je     8980 <bench_ada__run_17.isra.0+0x130>
    89ae:	mov    r13d,edx
    89b1:	cmp    edx,0x6
    89b4:	jbe    8ca0 <bench_ada__run_17.isra.0+0x450>
    89ba:	mov    rcx,QWORD PTR [rsp+0x70]
    89bf:	mov    r11,QWORD PTR [rsp+0x68]
    89c4:	mov    edi,r9d
    89c7:	shr    edi,0x3
    89ca:	vmovapd zmm4,zmm2
    89d0:	mov    esi,edi
    89d2:	imul   rcx,r15
    89d6:	shl    rsi,0x6
    89da:	add    rcx,r10
    89dd:	add    rsi,rcx
    89e0:	sub    r11,rcx
    89e3:	nop    DWORD PTR [rax+0x0]
    89ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    89f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8a00:	vmulpd zmm0,zmm4,ZMMWORD PTR [rcx+r11*1]
    8a07:	add    rcx,0x40
    8a0b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rcx-0x40]
    8a12:	vmovupd ZMMWORD PTR [rcx-0x40],zmm0
    8a19:	cmp    rsi,rcx
    8a1c:	jne    8a00 <bench_ada__run_17.isra.0+0x1b0>
    8a1e:	shl    edi,0x3
    8a21:	cmp    r9d,edi
    8a24:	je     8980 <bench_ada__run_17.isra.0+0x130>
    8a2a:	lea    ecx,[rdi-0x1]
    8a2d:	sub    r13d,edi
    8a30:	cmp    r13d,0x2
    8a34:	jbe    8a6b <bench_ada__run_17.isra.0+0x21b>
    8a36:	mov    rsi,QWORD PTR [rsp+0x78]
    8a3b:	inc    r13d
    8a3e:	imul   rsi,r15
    8a42:	add    rsi,rdi
    8a45:	add    rdi,r12
    8a48:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+rdi*8]
    8a4d:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+rsi*8]
    8a53:	vmovupd YMMWORD PTR [r10+rsi*8],ymm2
    8a59:	mov    esi,r13d
    8a5c:	and    esi,0xfffffffc
    8a5f:	and    r13d,0x3
    8a63:	je     8980 <bench_ada__run_17.isra.0+0x130>
    8a69:	add    ecx,esi
    8a6b:	mov    r11,QWORD PTR [rsp+0x78]
    8a70:	lea    esi,[rcx+0x1]
    8a73:	mov    rdi,rsi
    8a76:	imul   r11,r15
    8a7a:	lea    r13,[r11+rsi*1]
    8a7e:	add    rsi,r12
    8a81:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    8a86:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    8a8c:	vmovsd QWORD PTR [r10+r13*8],xmm0
    8a92:	cmp    edi,r14d
    8a95:	je     8980 <bench_ada__run_17.isra.0+0x130>
    8a9b:	lea    esi,[rcx+0x2]
    8a9e:	lea    r13,[r11+rsi*1]
    8aa2:	mov    rdi,rsi
    8aa5:	add    rsi,r12
    8aa8:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    8aad:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    8ab3:	vmovsd QWORD PTR [r10+r13*8],xmm0
    8ab9:	cmp    r14d,edi
    8abc:	je     8980 <bench_ada__run_17.isra.0+0x130>
    8ac2:	add    ecx,0x3
    8ac5:	inc    r9d
    8ac8:	lea    r15,[r11+rcx*1]
    8acc:	add    rcx,r12
    8acf:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    8ad4:	vaddsd xmm1,xmm1,QWORD PTR [r10+r15*8]
    8ada:	vmovsd QWORD PTR [r10+r15*8],xmm1
    8ae0:	cmp    rdx,rax
    8ae3:	jne    898c <bench_ada__run_17.isra.0+0x13c>
    8ae9:	nop    DWORD PTR [rax+0x0]
    8af0:	cmp    r8,QWORD PTR [rsp+0x60]
    8af5:	jne    8940 <bench_ada__run_17.isra.0+0xf0>
    8afb:	mov    r12,QWORD PTR [rsp+0x70]
    8b00:	vmovq  r14,xmm3
    8b05:	vzeroupper
    8b08:	mov    eax,DWORD PTR [rsp+0x48]
    8b0c:	lea    r13,[r12+r12*1]
    8b10:	mov    r11,r12
    8b13:	shr    r11,0x3
    8b17:	vmovq  xmm5,r13
    8b1c:	mov    QWORD PTR [rsp+0x70],rbx
    8b21:	mov    r8d,0x1
    8b27:	mov    rsi,0xffffffffffffffff
    8b2e:	mov    QWORD PTR [rsp+0x78],rax
    8b33:	mov    r15,rax
    8b36:	jmp    8b4c <bench_ada__run_17.isra.0+0x2fc>
    8b38:	nop    DWORD PTR [rax+rax*1+0x0]
    8b40:	inc    r8d
    8b43:	cmp    rsi,r14
    8b46:	je     8c61 <bench_ada__run_17.isra.0+0x411>
    8b4c:	mov    rdx,rsi
    8b4f:	inc    rsi
    8b52:	cmp    r15d,r8d
    8b55:	jl     8b40 <bench_ada__run_17.isra.0+0x2f0>
    8b57:	mov    rcx,QWORD PTR [rsp+0x78]
    8b5c:	movsxd rax,r8d
    8b5f:	lea    r9,[rax-0x1]
    8b63:	sub    rcx,rax
    8b66:	cmp    rcx,0xe
    8b6a:	jbe    8cac <bench_ada__run_17.isra.0+0x45c>
    8b70:	imul   rax,r11
    8b74:	mov    rbx,rsi
    8b77:	imul   rbx,r11
    8b7b:	add    rax,rdx
    8b7e:	movsxd rdx,esi
    8b81:	add    rdx,rbx
    8b84:	shl    rdx,0x3
    8b88:	lea    rbx,[r10+rdx*1]
    8b8c:	vmovq  xmm1,rbx
    8b91:	lea    rbx,[rdx+r10*1+0x8]
    8b96:	mov    r13,rbx
    8b99:	mov    rbx,r12
    8b9c:	imul   rbx,rcx
    8ba0:	shl    rax,0x3
    8ba4:	lea    rdi,[r10+rax*1]
    8ba8:	lea    rbx,[rdi+rbx*1+0x8]
    8bad:	cmp    rbx,r13
    8bb0:	jb     8bc9 <bench_ada__run_17.isra.0+0x379>
    8bb2:	vmovq  rbx,xmm1
    8bb7:	add    rdi,0x8
    8bbb:	lea    rbx,[rbx+rcx*8+0x8]
    8bc0:	cmp    rbx,rdi
    8bc3:	jae    8cac <bench_ada__run_17.isra.0+0x45c>
    8bc9:	cmp    r15d,r8d
    8bcc:	je     8c32 <bench_ada__run_17.isra.0+0x3e2>
    8bce:	lea    rbx,[rcx+0x1]
    8bd2:	dec    rcx
    8bd5:	lea    rax,[rax+r10*1+0x8]
    8bda:	vmovq  r13,xmm5
    8bdf:	shr    rcx,1
    8be2:	lea    rdi,[rcx+0x1]
    8be6:	lea    rcx,[rdx+r10*1+0x8]
    8beb:	xor    edx,edx
    8bed:	nop    DWORD PTR [rax+rax*1+0x0]
    8bf5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8c00:	vmovsd xmm0,QWORD PTR [rax]
    8c04:	vmovhpd xmm0,xmm0,QWORD PTR [r12+rax*1]
    8c0a:	inc    rdx
    8c0d:	add    rax,r13
    8c10:	add    rcx,0x10
    8c14:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    8c19:	cmp    rdx,rdi
    8c1c:	jb     8c00 <bench_ada__run_17.isra.0+0x3b0>
    8c1e:	add    rdi,rdi
    8c21:	vmovq  xmm5,r13
    8c26:	cmp    rbx,rdi
    8c29:	je     8b40 <bench_ada__run_17.isra.0+0x2f0>
    8c2f:	add    r9,rdi
    8c32:	inc    r9
    8c35:	mov    rax,r11
    8c38:	inc    r8d
    8c3b:	imul   rax,r9
    8c3f:	add    rax,rsi
    8c42:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    8c48:	mov    rax,rsi
    8c4b:	imul   rax,r11
    8c4f:	add    rax,r9
    8c52:	vmovsd QWORD PTR [r10+rax*8],xmm0
    8c58:	cmp    rsi,r14
    8c5b:	jne    8b4c <bench_ada__run_17.isra.0+0x2fc>
    8c61:	mov    rbx,QWORD PTR [rsp+0x70]
    8c66:	mov    rax,QWORD PTR [rsp+0x58]
    8c6b:	mov    rdi,QWORD PTR [rsp+0x50]
    8c70:	mov    rdx,QWORD PTR [rbp+0x10]
    8c74:	mov    rsi,QWORD PTR [rbp+0x18]
    8c78:	mov    rcx,QWORD PTR [rbp+0x28]
    8c7c:	mov    edi,DWORD PTR [rsp+0x4c]
    8c80:	cmp    DWORD PTR [rsp+0x44],edi
    8c84:	jne    88c0 <bench_ada__run_17.isra.0+0x70>
    8c8a:	lea    rsp,[rbp-0x28]
    8c8e:	pop    rbx
    8c8f:	pop    r12
    8c91:	pop    r13
    8c93:	pop    r14
    8c95:	pop    r15
    8c97:	pop    rbp
    8c98:	ret
    8c99:	nop    DWORD PTR [rax+0x0]
    8ca0:	xor    edi,edi
    8ca2:	mov    ecx,0xffffffff
    8ca7:	jmp    8a2d <bench_ada__run_17.isra.0+0x1dd>
    8cac:	mov    rdx,rsi
    8caf:	vmovq  r13,xmm5
    8cb4:	imul   rdx,r12
    8cb8:	add    rdx,r10
    8cbb:	nop    DWORD PTR [rax+rax*1+0x0]
    8cc0:	inc    r9
    8cc3:	mov    rax,r11
    8cc6:	imul   rax,r9
    8cca:	add    rax,rsi
    8ccd:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    8cd3:	vmovsd QWORD PTR [rdx+r9*8],xmm0
    8cd9:	cmp    r9,r14
    8cdc:	jne    8cc0 <bench_ada__run_17.isra.0+0x470>
    8cde:	vmovq  xmm5,r13
    8ce3:	jmp    8b40 <bench_ada__run_17.isra.0+0x2f0>
    8ce8:	mov    eax,DWORD PTR [rsp+0x40]
    8cec:	mov    r9d,DWORD PTR [rsp+0x4c]
    8cf1:	mov    rdx,QWORD PTR [rsp+0x50]
    8cf6:	mov    rcx,QWORD PTR [rbp+0x10]
    8cfa:	mov    rsi,QWORD PTR [rbp+0x18]
    8cfe:	mov    rdi,QWORD PTR [rbp+0x28]
    8d02:	mov    r8d,DWORD PTR [rsp+0x44]
    8d07:	cmp    eax,0xffffffff
    8d0a:	mov    rax,QWORD PTR [rsp+0x58]
    8d0f:	jne    8d16 <bench_ada__run_17.isra.0+0x4c6>
    8d11:	jmp    8d20 <bench_ada__run_17.isra.0+0x4d0>
    8d13:	inc    r9d
    8d16:	cmp    r8d,r9d
    8d19:	jne    8d13 <bench_ada__run_17.isra.0+0x4c3>
    8d1b:	jmp    8c8a <bench_ada__run_17.isra.0+0x43a>
    8d20:	cmp    r8d,r9d
    8d23:	je     8c8a <bench_ada__run_17.isra.0+0x43a>
    8d29:	lea    r11d,[r9+0x1]
    8d2d:	cmp    r8d,r11d
    8d30:	je     8c8a <bench_ada__run_17.isra.0+0x43a>
    8d36:	add    r9d,0x2
    8d3a:	jmp    8d20 <bench_ada__run_17.isra.0+0x4d0>
    8d3c:	nop    DWORD PTR [rax+0x0]


<bench_ada__run_18.isra.0>:
    8d40:	push   rbp
    8d41:	mov    eax,edi
    8d43:	mov    rbp,rsp
    8d46:	push   r15
    8d48:	push   r14
    8d4a:	push   r13
    8d4c:	push   r12
    8d4e:	push   rbx
    8d4f:	and    rsp,0xffffffffffffffc0
    8d53:	add    rsp,0xffffffffffffff80
    8d57:	mov    rdi,QWORD PTR [rbp+0x20]
    8d5b:	test   edx,edx
    8d5d:	je     91c9 <bench_ada__run_18.isra.0+0x489>
    8d63:	mov    r12d,esi
    8d66:	test   esi,esi
    8d68:	lea    r15d,[rsi-0x1]
    8d6c:	mov    DWORD PTR [rsp+0x2c],eax
    8d70:	setne  BYTE PTR [rsp+0x67]
    8d75:	lea    r13,[r12*8+0x0]
    8d7d:	xor    eax,eax
    8d7f:	cmp    r15d,0xffffffff
    8d83:	cmove  r13,rax
    8d87:	cmovne rax,r12
    8d8b:	mov    DWORD PTR [rsp+0x28],edx
    8d8f:	mov    DWORD PTR [rsp+0x24],r15d
    8d94:	mov    QWORD PTR [rsp+0x40],r8
    8d99:	mov    QWORD PTR [rsp+0x38],r9
    8d9e:	mov    rbx,rcx
    8da1:	dec    r12
    8da4:	imul   rax,r13
    8da8:	mov    QWORD PTR [rsp+0x30],rax
    8dad:	xor    eax,eax
    8daf:	mov    DWORD PTR [rsp+0x60],eax
    8db3:	mov    rax,r13
    8db6:	shr    rax,0x3
    8dba:	mov    QWORD PTR [rsp+0x78],rax
    8dbf:	nop
    8dc0:	inc    DWORD PTR [rsp+0x60]
    8dc4:	mov    rax,QWORD PTR [rsp+0x40]
    8dc9:	mov    rsi,QWORD PTR [rsp+0x38]
    8dce:	mov    rcx,QWORD PTR [rbp+0x10]
    8dd2:	mov    rdx,QWORD PTR [rbp+0x18]
    8dd6:	mov    r10,QWORD PTR [rbp+0x28]
    8dda:	mov    rdx,QWORD PTR [rsp+0x30]
    8ddf:	xor    esi,esi
    8de1:	call   2bd0 <memset@plt>
    8de6:	vxorpd xmm2,xmm2,xmm2
    8dea:	mov    rdi,rax
    8ded:	mov    eax,DWORD PTR [rsp+0x2c]
    8df1:	test   eax,eax
    8df3:	je     901a <bench_ada__run_18.isra.0+0x2da>
    8df9:	mov    QWORD PTR [rsp+0x70],r13
    8dfe:	mov    QWORD PTR [rbp+0x20],rdi
    8e02:	mov    r13,QWORD PTR [rbp+0x18]
    8e06:	lea    rsi,[rax-0x1]
    8e0a:	mov    r8,0xffffffffffffffff
    8e11:	jmp    8e29 <bench_ada__run_18.isra.0+0xe9>
    8e13:	xchg   ax,ax
    8e15:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8e20:	cmp    r8,rsi
    8e23:	je     900e <bench_ada__run_18.isra.0+0x2ce>
    8e29:	inc    r8
    8e2c:	movsxd rdi,r8d
    8e2f:	vcomisd xmm2,QWORD PTR [r13+rdi*8+0x0]
    8e36:	je     8e20 <bench_ada__run_18.isra.0+0xe0>
    8e38:	cmp    BYTE PTR [rsp+0x67],0x0
    8e3d:	je     8e20 <bench_ada__run_18.isra.0+0xe0>
    8e3f:	mov    rax,QWORD PTR [rsp+0x70]
    8e44:	mov    r14,QWORD PTR [rsp+0x78]
    8e49:	mov    QWORD PTR [rsp+0x50],r8
    8e4e:	mov    QWORD PTR [rsp+0x48],rsi
    8e53:	mov    r8,rdi
    8e56:	mov    ecx,0x1
    8e5b:	mov    rdx,0xffffffffffffffff
    8e62:	imul   rax,rdi
    8e66:	imul   r14,rdi
    8e6a:	mov    rdi,QWORD PTR [rbp+0x20]
    8e6e:	add    rax,rbx
    8e71:	mov    QWORD PTR [rsp+0x58],rax
    8e76:	mov    r10,r14
    8e79:	nop    DWORD PTR [rax+0x0]
    8e80:	inc    rdx
    8e83:	movsxd r14,edx
    8e86:	lea    rax,[r10+r14*1]
    8e8a:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    8e8f:	vcomisd xmm0,xmm2
    8e93:	je     8ff0 <bench_ada__run_18.isra.0+0x2b0>
    8e99:	vmovsd xmm1,QWORD PTR [r13+r8*8+0x0]
    8ea0:	vcomisd xmm1,xmm2
    8ea4:	je     8ff0 <bench_ada__run_18.isra.0+0x2b0>
    8eaa:	mov    esi,edx
    8eac:	test   edx,edx
    8eae:	js     8ff0 <bench_ada__run_18.isra.0+0x2b0>
    8eb4:	vmulsd xmm1,xmm0,xmm1
    8eb8:	mov    DWORD PTR [rsp+0x68],edx
    8ebc:	vbroadcastsd zmm6,xmm1
    8ec2:	cmp    edx,0x6
    8ec5:	jbe    9230 <bench_ada__run_18.isra.0+0x4f0>
    8ecb:	mov    r9,QWORD PTR [rsp+0x70]
    8ed0:	mov    r15,QWORD PTR [rsp+0x58]
    8ed5:	mov    r11d,ecx
    8ed8:	shr    r11d,0x3
    8edc:	vmovapd zmm4,zmm6
    8ee2:	imul   r9,r14
    8ee6:	lea    rax,[r9+rdi*1]
    8eea:	mov    r9d,r11d
    8eed:	shl    r9,0x6
    8ef1:	sub    r15,rax
    8ef4:	add    r9,rax
    8ef7:	nop    WORD PTR [rax+rax*1+0x0]
    8f00:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    8f07:	add    rax,0x40
    8f0b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    8f12:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    8f19:	cmp    r9,rax
    8f1c:	jne    8f00 <bench_ada__run_18.isra.0+0x1c0>
    8f1e:	shl    r11d,0x3
    8f22:	cmp    ecx,r11d
    8f25:	je     8ff0 <bench_ada__run_18.isra.0+0x2b0>
    8f2b:	lea    r9d,[r11-0x1]
    8f2f:	mov    r15d,DWORD PTR [rsp+0x68]
    8f34:	sub    r15d,r11d
    8f37:	cmp    r15d,0x2
    8f3b:	jbe    8f73 <bench_ada__run_18.isra.0+0x233>
    8f3d:	mov    rax,QWORD PTR [rsp+0x78]
    8f42:	inc    r15d
    8f45:	imul   rax,r14
    8f49:	add    rax,r11
    8f4c:	add    r11,r10
    8f4f:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r11*8]
    8f55:	mov    r11d,r15d
    8f58:	and    r11d,0xfffffffc
    8f5c:	and    r15d,0x3
    8f60:	vaddpd ymm6,ymm6,YMMWORD PTR [rdi+rax*8]
    8f65:	vmovupd YMMWORD PTR [rdi+rax*8],ymm6
    8f6a:	je     8ff0 <bench_ada__run_18.isra.0+0x2b0>
    8f70:	add    r9d,r11d
    8f73:	mov    r15,QWORD PTR [rsp+0x78]
    8f78:	lea    r11d,[r9+0x1]
    8f7c:	mov    DWORD PTR [rsp+0x68],r11d
    8f81:	mov    rax,r15
    8f84:	imul   r15,r8
    8f88:	imul   rax,r14
    8f8c:	lea    r14,[rax+r11*1]
    8f90:	add    r11,r15
    8f93:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    8f99:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    8f9f:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    8fa5:	cmp    DWORD PTR [rsp+0x68],esi
    8fa9:	je     8ff0 <bench_ada__run_18.isra.0+0x2b0>
    8fab:	lea    r11d,[r9+0x2]
    8faf:	lea    r14,[rax+r11*1]
    8fb3:	mov    DWORD PTR [rsp+0x68],r11d
    8fb8:	add    r11,r15
    8fbb:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    8fc1:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    8fc7:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    8fcd:	cmp    esi,DWORD PTR [rsp+0x68]
    8fd1:	je     8ff0 <bench_ada__run_18.isra.0+0x2b0>
    8fd3:	lea    esi,[r9+0x3]
    8fd7:	add    rax,rsi
    8fda:	add    rsi,r15
    8fdd:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    8fe2:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rax*8]
    8fe7:	vmovsd QWORD PTR [rdi+rax*8],xmm1
    8fec:	nop    DWORD PTR [rax+0x0]
    8ff0:	inc    ecx
    8ff2:	cmp    rdx,r12
    8ff5:	jne    8e80 <bench_ada__run_18.isra.0+0x140>
    8ffb:	mov    r8,QWORD PTR [rsp+0x50]
    9000:	mov    rsi,QWORD PTR [rsp+0x48]
    9005:	cmp    r8,rsi
    9008:	jne    8e29 <bench_ada__run_18.isra.0+0xe9>
    900e:	mov    r13,QWORD PTR [rsp+0x70]
    9013:	mov    rdi,QWORD PTR [rbp+0x20]
    9017:	vzeroupper
    901a:	mov    eax,DWORD PTR [rsp+0x24]
    901e:	cmp    eax,0xffffffff
    9021:	je     91a5 <bench_ada__run_18.isra.0+0x465>
    9027:	mov    r14d,eax
    902a:	mov    QWORD PTR [rsp+0x58],rbx
    902f:	mov    r11,QWORD PTR [rsp+0x78]
    9034:	mov    r9d,0x1
    903a:	mov    QWORD PTR [rsp+0x68],r14
    903f:	mov    rsi,0xffffffffffffffff
    9046:	lea    rbx,[r13+r13*1+0x0]
    904b:	mov    r15d,eax
    904e:	jmp    906c <bench_ada__run_18.isra.0+0x32c>
    9050:	nop    DWORD PTR [rax+rax*1+0x0]
    9055:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9060:	inc    r9d
    9063:	cmp    rsi,r12
    9066:	je     91a0 <bench_ada__run_18.isra.0+0x460>
    906c:	mov    rax,rsi
    906f:	inc    rsi
    9072:	cmp    r15d,r9d
    9075:	jl     9060 <bench_ada__run_18.isra.0+0x320>
    9077:	mov    rcx,QWORD PTR [rsp+0x68]
    907c:	movsxd rdx,r9d
    907f:	lea    r10,[rdx-0x1]
    9083:	sub    rcx,rdx
    9086:	cmp    rcx,0xe
    908a:	jbe    91e0 <bench_ada__run_18.isra.0+0x4a0>
    9090:	imul   rdx,r11
    9094:	movsxd r14,esi
    9097:	add    rax,rdx
    909a:	mov    rdx,rsi
    909d:	imul   rdx,r11
    90a1:	shl    rax,0x3
    90a5:	add    rdx,r14
    90a8:	lea    r8,[rdi+rax*1]
    90ac:	shl    rdx,0x3
    90b0:	lea    r14,[rdi+rdx*1]
    90b4:	vmovq  xmm3,r14
    90b9:	mov    r14,r13
    90bc:	imul   r14,rcx
    90c0:	lea    r14,[r8+r14*1+0x8]
    90c5:	mov    QWORD PTR [rsp+0x70],r14
    90ca:	lea    r14,[rdx+rdi*1+0x8]
    90cf:	cmp    QWORD PTR [rsp+0x70],r14
    90d4:	jb     90ed <bench_ada__run_18.isra.0+0x3ad>
    90d6:	vmovq  r14,xmm3
    90db:	add    r8,0x8
    90df:	lea    r14,[r14+rcx*8+0x8]
    90e4:	cmp    r14,r8
    90e7:	jae    91e0 <bench_ada__run_18.isra.0+0x4a0>
    90ed:	cmp    r15d,r9d
    90f0:	je     916e <bench_ada__run_18.isra.0+0x42e>
    90f2:	lea    r14,[rcx+0x1]
    90f6:	dec    rcx
    90f9:	lea    rax,[rax+rdi*1+0x8]
    90fe:	shr    rcx,1
    9101:	lea    r8,[rcx+0x1]
    9105:	lea    rcx,[rdx+rdi*1+0x8]
    910a:	xor    edx,edx
    910c:	nop    DWORD PTR [rax+rax*1+0x0]
    9114:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    911f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    912a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9135:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9140:	vmovsd xmm0,QWORD PTR [rax]
    9144:	vmovhpd xmm0,xmm0,QWORD PTR [r13+rax*1+0x0]
    914b:	inc    rdx
    914e:	add    rax,rbx
    9151:	add    rcx,0x10
    9155:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    915a:	cmp    rdx,r8
    915d:	jb     9140 <bench_ada__run_18.isra.0+0x400>
    915f:	add    r8,r8
    9162:	cmp    r14,r8
    9165:	je     9060 <bench_ada__run_18.isra.0+0x320>
    916b:	add    r10,r8
    916e:	inc    r10
    9171:	mov    rax,r11
    9174:	inc    r9d
    9177:	imul   rax,r10
    917b:	add    rax,rsi
    917e:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    9183:	mov    rax,rsi
    9186:	imul   rax,r11
    918a:	add    rax,r10
    918d:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    9192:	cmp    rsi,r12
    9195:	jne    906c <bench_ada__run_18.isra.0+0x32c>
    919b:	nop    DWORD PTR [rax+rax*1+0x0]
    91a0:	mov    rbx,QWORD PTR [rsp+0x58]
    91a5:	mov    rax,QWORD PTR [rsp+0x40]
    91aa:	mov    rsi,QWORD PTR [rsp+0x38]
    91af:	mov    rcx,QWORD PTR [rbp+0x10]
    91b3:	mov    rdx,QWORD PTR [rbp+0x18]
    91b7:	mov    r10,QWORD PTR [rbp+0x28]
    91bb:	mov    esi,DWORD PTR [rsp+0x60]
    91bf:	cmp    DWORD PTR [rsp+0x28],esi
    91c3:	jne    8dc0 <bench_ada__run_18.isra.0+0x80>
    91c9:	lea    rsp,[rbp-0x28]
    91cd:	pop    rbx
    91ce:	pop    r12
    91d0:	pop    r13
    91d2:	pop    r14
    91d4:	pop    r15
    91d6:	pop    rbp
    91d7:	ret
    91d8:	nop    DWORD PTR [rax+rax*1+0x0]
    91e0:	mov    rdx,r13
    91e3:	imul   rdx,rsi
    91e7:	add    rdx,rdi
    91ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    91f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9200:	inc    r10
    9203:	mov    rax,r11
    9206:	imul   rax,r10
    920a:	add    rax,rsi
    920d:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    9212:	vmovsd QWORD PTR [rdx+r10*8],xmm0
    9218:	cmp    r10,r12
    921b:	jne    9200 <bench_ada__run_18.isra.0+0x4c0>
    921d:	jmp    9060 <bench_ada__run_18.isra.0+0x320>
    9222:	nop    DWORD PTR [rax]
    9225:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9230:	xor    r11d,r11d
    9233:	mov    r9d,0xffffffff
    9239:	jmp    8f2f <bench_ada__run_18.isra.0+0x1ef>
    923e:	xchg   ax,ax


<bench_ada__run_19.isra.0>:
    9240:	push   rbp
    9241:	mov    rbp,rsp
    9244:	push   r15
    9246:	push   r14
    9248:	push   r13
    924a:	push   r12
    924c:	push   rbx
    924d:	and    rsp,0xffffffffffffffc0
    9251:	add    rsp,0xffffffffffffff80
    9255:	mov    r12,QWORD PTR [rbp+0x18]
    9259:	test   edx,edx
    925b:	je     9533 <bench_ada__run_19.isra.0+0x2f3>
    9261:	mov    r13d,esi
    9264:	test   esi,esi
    9266:	mov    eax,0x0
    926b:	mov    DWORD PTR [rsp+0x38],edx
    926f:	lea    rsi,[r13*8+0x0]
    9277:	setne  r14b
    927b:	mov    DWORD PTR [rsp+0x3c],edi
    927f:	mov    QWORD PTR [rsp+0x48],r8
    9284:	cmove  rsi,rax
    9288:	mov    BYTE PTR [rsp+0x73],r14b
    928d:	mov    r14,r9
    9290:	mov    r9,QWORD PTR [rbp+0x20]
    9294:	cmovne rax,r13
    9298:	mov    QWORD PTR [rsp+0x68],rsi
    929d:	mov    rbx,rcx
    92a0:	xor    r15d,r15d
    92a3:	imul   rax,rsi
    92a7:	dec    r13
    92aa:	shr    rsi,0x3
    92ae:	mov    QWORD PTR [rsp+0x40],rax
    92b3:	mov    QWORD PTR [rsp+0x78],rsi
    92b8:	nop    DWORD PTR [rax+rax*1+0x0]
    92c0:	mov    rax,QWORD PTR [rsp+0x48]
    92c5:	mov    rsi,QWORD PTR [rbp+0x10]
    92c9:	mov    rcx,QWORD PTR [rbp+0x28]
    92cd:	inc    r15d
    92d0:	mov    rdx,QWORD PTR [rsp+0x40]
    92d5:	xor    esi,esi
    92d7:	mov    rdi,r9
    92da:	call   2bd0 <memset@plt>
    92df:	vxorpd xmm2,xmm2,xmm2
    92e3:	mov    r9,rax
    92e6:	mov    eax,DWORD PTR [rsp+0x3c]
    92ea:	test   eax,eax
    92ec:	je     951b <bench_ada__run_19.isra.0+0x2db>
    92f2:	mov    DWORD PTR [rsp+0x34],r15d
    92f7:	mov    QWORD PTR [rsp+0x28],r14
    92fc:	mov    rdi,0xffffffffffffffff
    9303:	lea    r11,[rax-0x1]
    9307:	jmp    9329 <bench_ada__run_19.isra.0+0xe9>
    9309:	nop
    930a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9315:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9320:	cmp    rdi,r11
    9323:	je     950e <bench_ada__run_19.isra.0+0x2ce>
    9329:	inc    rdi
    932c:	movsxd r14,edi
    932f:	vcomisd xmm2,QWORD PTR [r12+r14*8]
    9335:	je     9320 <bench_ada__run_19.isra.0+0xe0>
    9337:	cmp    BYTE PTR [rsp+0x73],0x0
    933c:	je     9320 <bench_ada__run_19.isra.0+0xe0>
    933e:	mov    rax,QWORD PTR [rsp+0x68]
    9343:	mov    r10,QWORD PTR [rsp+0x78]
    9348:	mov    QWORD PTR [rsp+0x58],rdi
    934d:	mov    QWORD PTR [rsp+0x50],r11
    9352:	mov    ecx,0x1
    9357:	mov    rdx,0xffffffffffffffff
    935e:	mov    r11,r14
    9361:	imul   rax,r14
    9365:	imul   r10,r14
    9369:	add    rax,rbx
    936c:	mov    QWORD PTR [rsp+0x60],rax
    9371:	nop    DWORD PTR [rax+0x0]
    9375:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9380:	inc    rdx
    9383:	movsxd r14,edx
    9386:	lea    rax,[r10+r14*1]
    938a:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    938f:	vcomisd xmm0,xmm2
    9393:	je     94f0 <bench_ada__run_19.isra.0+0x2b0>
    9399:	vmovsd xmm1,QWORD PTR [r12+r11*8]
    939f:	vcomisd xmm1,xmm2
    93a3:	je     94f0 <bench_ada__run_19.isra.0+0x2b0>
    93a9:	mov    esi,edx
    93ab:	test   edx,edx
    93ad:	js     94f0 <bench_ada__run_19.isra.0+0x2b0>
    93b3:	vmulsd xmm1,xmm0,xmm1
    93b7:	mov    DWORD PTR [rsp+0x74],edx
    93bb:	vbroadcastsd zmm6,xmm1
    93c1:	cmp    edx,0x6
    93c4:	jbe    9550 <bench_ada__run_19.isra.0+0x310>
    93ca:	mov    rdi,QWORD PTR [rsp+0x68]
    93cf:	mov    r15,QWORD PTR [rsp+0x60]
    93d4:	mov    r8d,ecx
    93d7:	shr    r8d,0x3
    93db:	vmovapd zmm4,zmm6
    93e1:	imul   rdi,r14
    93e5:	lea    rax,[rdi+r9*1]
    93e9:	mov    edi,r8d
    93ec:	shl    rdi,0x6
    93f0:	sub    r15,rax
    93f3:	add    rdi,rax
    93f6:	cs nop WORD PTR [rax+rax*1+0x0]
    9400:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    9407:	add    rax,0x40
    940b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    9412:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    9419:	cmp    rax,rdi
    941c:	jne    9400 <bench_ada__run_19.isra.0+0x1c0>
    941e:	shl    r8d,0x3
    9422:	cmp    r8d,ecx
    9425:	je     94f0 <bench_ada__run_19.isra.0+0x2b0>
    942b:	lea    edi,[r8-0x1]
    942f:	mov    r15d,DWORD PTR [rsp+0x74]
    9434:	sub    r15d,r8d
    9437:	cmp    r15d,0x2
    943b:	jbe    9475 <bench_ada__run_19.isra.0+0x235>
    943d:	mov    rax,QWORD PTR [rsp+0x78]
    9442:	inc    r15d
    9445:	imul   rax,r14
    9449:	add    rax,r8
    944c:	add    r8,r10
    944f:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r8*8]
    9455:	mov    r8d,r15d
    9458:	and    r8d,0xfffffffc
    945c:	and    r15d,0x3
    9460:	vaddpd ymm6,ymm6,YMMWORD PTR [r9+rax*8]
    9466:	vmovupd YMMWORD PTR [r9+rax*8],ymm6
    946c:	je     94f0 <bench_ada__run_19.isra.0+0x2b0>
    9472:	add    edi,r8d
    9475:	mov    r15,QWORD PTR [rsp+0x78]
    947a:	lea    r8d,[rdi+0x1]
    947e:	mov    DWORD PTR [rsp+0x74],r8d
    9483:	mov    rax,r15
    9486:	imul   r15,r11
    948a:	imul   rax,r14
    948e:	lea    r14,[rax+r8*1]
    9492:	add    r8,r15
    9495:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    949b:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    94a1:	vmovsd QWORD PTR [r9+r14*8],xmm0
    94a7:	cmp    esi,DWORD PTR [rsp+0x74]
    94ab:	je     94f0 <bench_ada__run_19.isra.0+0x2b0>
    94ad:	lea    r8d,[rdi+0x2]
    94b1:	lea    r14,[rax+r8*1]
    94b5:	mov    DWORD PTR [rsp+0x74],r8d
    94ba:	add    r8,r15
    94bd:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    94c3:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    94c9:	vmovsd QWORD PTR [r9+r14*8],xmm0
    94cf:	cmp    esi,DWORD PTR [rsp+0x74]
    94d3:	je     94f0 <bench_ada__run_19.isra.0+0x2b0>
    94d5:	lea    esi,[rdi+0x3]
    94d8:	add    rax,rsi
    94db:	add    rsi,r15
    94de:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    94e3:	vaddsd xmm1,xmm1,QWORD PTR [r9+rax*8]
    94e9:	vmovsd QWORD PTR [r9+rax*8],xmm1
    94ef:	nop
    94f0:	inc    ecx
    94f2:	cmp    rdx,r13
    94f5:	jne    9380 <bench_ada__run_19.isra.0+0x140>
    94fb:	mov    rdi,QWORD PTR [rsp+0x58]
    9500:	mov    r11,QWORD PTR [rsp+0x50]
    9505:	cmp    rdi,r11
    9508:	jne    9329 <bench_ada__run_19.isra.0+0xe9>
    950e:	mov    r15d,DWORD PTR [rsp+0x34]
    9513:	mov    r14,QWORD PTR [rsp+0x28]
    9518:	vzeroupper
    951b:	mov    rax,QWORD PTR [rsp+0x48]
    9520:	mov    rsi,QWORD PTR [rbp+0x10]
    9524:	mov    rcx,QWORD PTR [rbp+0x28]
    9528:	cmp    DWORD PTR [rsp+0x38],r15d
    952d:	jne    92c0 <bench_ada__run_19.isra.0+0x80>
    9533:	lea    rsp,[rbp-0x28]
    9537:	pop    rbx
    9538:	pop    r12
    953a:	pop    r13
    953c:	pop    r14
    953e:	pop    r15
    9540:	pop    rbp
    9541:	ret
    9542:	nop    DWORD PTR [rax]
    9545:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9550:	xor    r8d,r8d
    9553:	mov    edi,0xffffffff
    9558:	jmp    942f <bench_ada__run_19.isra.0+0x1ef>
    955d:	nop
    955e:	xchg   ax,ax


<bench_ada__run_2.isra.0>:
    41a0:	mov    rax,rsi
    41a3:	mov    r11,QWORD PTR [rsp+0x10]
    41a8:	mov    rsi,rdx
    41ab:	mov    r10,rcx
    41ae:	mov    rdx,QWORD PTR [rsp+0x8]
    41b3:	test   edi,edi
    41b5:	je     4229 <bench_ada__run_2.isra.0+0x89>
    41b7:	xor    ecx,ecx
    41b9:	nop    DWORD PTR [rax+0x0]
    41c0:	inc    ecx
    41c2:	vmovsd xmm4,QWORD PTR [r8+0x8]
    41c8:	vmulsd xmm2,xmm4,QWORD PTR [rax+0x20]
    41cd:	vmovsd xmm0,QWORD PTR [r8]
    41d2:	vmovsd xmm3,QWORD PTR [r8+0x10]
    41d8:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x18]
    41dd:	vmulsd xmm5,xmm4,QWORD PTR [rax+0x38]
    41e2:	vmulsd xmm4,xmm4,QWORD PTR [rax+0x8]
    41e7:	vaddsd xmm1,xmm1,xmm2
    41eb:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x28]
    41f0:	vaddsd xmm2,xmm1,xmm2
    41f4:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x30]
    41f9:	vmulsd xmm0,xmm0,QWORD PTR [rax]
    41fd:	vaddsd xmm1,xmm1,xmm5
    4201:	vmulsd xmm5,xmm3,QWORD PTR [rax+0x40]
    4206:	vmulsd xmm3,xmm3,QWORD PTR [rax+0x10]
    420b:	vaddsd xmm0,xmm0,xmm4
    420f:	vmovsd QWORD PTR [rdx+0x8],xmm2
    4214:	vaddsd xmm1,xmm1,xmm5
    4218:	vaddsd xmm0,xmm0,xmm3
    421c:	vmovsd QWORD PTR [rdx+0x10],xmm1
    4221:	vmovsd QWORD PTR [rdx],xmm0
    4225:	cmp    edi,ecx
    4227:	jne    41c0 <bench_ada__run_2.isra.0+0x20>
    4229:	ret
    422a:	nop    WORD PTR [rax+rax*1+0x0]


<bench_ada__run_20.isra.0>:
    9560:	push   rbp
    9561:	mov    rbp,rsp
    9564:	push   r15
    9566:	push   r14
    9568:	push   r13
    956a:	push   r12
    956c:	push   rbx
    956d:	and    rsp,0xffffffffffffffc0
    9571:	add    rsp,0xffffffffffffff80
    9575:	mov    r10,QWORD PTR [rbp+0x20]
    9579:	mov    QWORD PTR [rsp+0x58],r8
    957e:	test   edx,edx
    9580:	je     9827 <bench_ada__run_20.isra.0+0x2c7>
    9586:	mov    r8d,esi
    9589:	xor    eax,eax
    958b:	mov    DWORD PTR [rsp+0x4c],edi
    958f:	test   esi,esi
    9591:	lea    rdi,[r8*8+0x0]
    9599:	mov    DWORD PTR [rsp+0x48],edx
    959d:	mov    QWORD PTR [rsp+0x30],r8
    95a2:	mov    DWORD PTR [rsp+0x44],esi
    95a6:	cmove  rdi,rax
    95aa:	mov    rbx,rcx
    95ad:	mov    r12,r9
    95b0:	cmovne rax,r8
    95b4:	mov    QWORD PTR [rsp+0x70],rdi
    95b9:	xor    r15d,r15d
    95bc:	imul   rax,rdi
    95c0:	shr    rdi,0x3
    95c4:	mov    QWORD PTR [rsp+0x50],rax
    95c9:	mov    QWORD PTR [rsp+0x78],rdi
    95ce:	xchg   ax,ax
    95d0:	mov    rax,QWORD PTR [rsp+0x58]
    95d5:	mov    rsi,QWORD PTR [rbp+0x10]
    95d9:	mov    rdi,QWORD PTR [rbp+0x18]
    95dd:	mov    rcx,QWORD PTR [rbp+0x28]
    95e1:	inc    r15d
    95e4:	mov    rdx,QWORD PTR [rsp+0x50]
    95e9:	xor    esi,esi
    95eb:	mov    rdi,r10
    95ee:	call   2bd0 <memset@plt>
    95f3:	vxorpd xmm7,xmm7,xmm7
    95f7:	mov    r10,rax
    95fa:	mov    eax,DWORD PTR [rsp+0x4c]
    95fe:	test   eax,eax
    9600:	je     980b <bench_ada__run_20.isra.0+0x2ab>
    9606:	mov    edx,DWORD PTR [rsp+0x44]
    960a:	test   edx,edx
    960c:	je     980b <bench_ada__run_20.isra.0+0x2ab>
    9612:	lea    rcx,[rax-0x1]
    9616:	mov    rax,QWORD PTR [rsp+0x30]
    961b:	mov    DWORD PTR [rsp+0x40],r15d
    9620:	mov    QWORD PTR [rsp+0x38],r12
    9625:	mov    QWORD PTR [rsp+0x60],rcx
    962a:	mov    rdi,0xffffffffffffffff
    9631:	lea    r13,[rax-0x1]
    9635:	vmovq  xmm3,r13
    963a:	nop    WORD PTR [rax+rax*1+0x0]
    9640:	mov    r14,QWORD PTR [rsp+0x70]
    9645:	inc    rdi
    9648:	mov    r9d,0x1
    964e:	mov    rdx,0xffffffffffffffff
    9655:	movsxd rax,edi
    9658:	mov    r8,rdi
    965b:	vmovq  rdi,xmm3
    9660:	imul   r14,rax
    9664:	lea    rsi,[r14+rbx*1]
    9668:	mov    r14,QWORD PTR [rsp+0x78]
    966d:	mov    QWORD PTR [rsp+0x68],rsi
    9672:	imul   r14,rax
    9676:	mov    r13,r14
    9679:	jmp    968c <bench_ada__run_20.isra.0+0x12c>
    967b:	nop    DWORD PTR [rax+rax*1+0x0]
    9680:	inc    r9d
    9683:	cmp    rdx,rdi
    9686:	je     97f0 <bench_ada__run_20.isra.0+0x290>
    968c:	inc    rdx
    968f:	movsxd r14,edx
    9692:	mov    esi,edx
    9694:	lea    rax,[r13+r14*1+0x0]
    9699:	vmovsd xmm1,QWORD PTR [rbx+rax*8]
    969e:	vbroadcastsd zmm2,xmm1
    96a4:	test   edx,edx
    96a6:	js     9680 <bench_ada__run_20.isra.0+0x120>
    96a8:	vcomisd xmm1,xmm7
    96ac:	je     9680 <bench_ada__run_20.isra.0+0x120>
    96ae:	mov    ecx,edx
    96b0:	cmp    edx,0x6
    96b3:	jbe    9840 <bench_ada__run_20.isra.0+0x2e0>
    96b9:	mov    r11,QWORD PTR [rsp+0x70]
    96be:	mov    r15,QWORD PTR [rsp+0x68]
    96c3:	mov    r12d,r9d
    96c6:	shr    r12d,0x3
    96ca:	vmovapd zmm4,zmm2
    96d0:	imul   r11,r14
    96d4:	lea    rax,[r11+r10*1]
    96d8:	mov    r11d,r12d
    96db:	shl    r11,0x6
    96df:	sub    r15,rax
    96e2:	add    r11,rax
    96e5:	nop    DWORD PTR [rax+rax*1+0x0]
    96ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    96f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9700:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    9707:	add    rax,0x40
    970b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    9712:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    9719:	cmp    rax,r11
    971c:	jne    9700 <bench_ada__run_20.isra.0+0x1a0>
    971e:	shl    r12d,0x3
    9722:	cmp    r12d,r9d
    9725:	je     9680 <bench_ada__run_20.isra.0+0x120>
    972b:	lea    r11d,[r12-0x1]
    9730:	sub    ecx,r12d
    9733:	cmp    ecx,0x2
    9736:	jbe    976e <bench_ada__run_20.isra.0+0x20e>
    9738:	mov    r15,QWORD PTR [rsp+0x78]
    973d:	inc    ecx
    973f:	imul   r15,r14
    9743:	add    r15,r12
    9746:	add    r12,r13
    9749:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+r12*8]
    974f:	mov    r12d,ecx
    9752:	and    r12d,0xfffffffc
    9756:	and    ecx,0x3
    9759:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+r15*8]
    975f:	vmovupd YMMWORD PTR [r10+r15*8],ymm2
    9765:	je     9680 <bench_ada__run_20.isra.0+0x120>
    976b:	add    r11d,r12d
    976e:	mov    rax,QWORD PTR [rsp+0x78]
    9773:	lea    ecx,[r11+0x1]
    9777:	mov    r12,rcx
    977a:	imul   rax,r14
    977e:	lea    r14,[rax+rcx*1]
    9782:	add    rcx,r13
    9785:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    978a:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    9790:	vmovsd QWORD PTR [r10+r14*8],xmm0
    9796:	cmp    r12d,esi
    9799:	je     9680 <bench_ada__run_20.isra.0+0x120>
    979f:	lea    ecx,[r11+0x2]
    97a3:	lea    r14,[rax+rcx*1]
    97a7:	mov    r12,rcx
    97aa:	add    rcx,r13
    97ad:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    97b2:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    97b8:	vmovsd QWORD PTR [r10+r14*8],xmm0
    97be:	cmp    r12d,esi
    97c1:	je     9680 <bench_ada__run_20.isra.0+0x120>
    97c7:	lea    ecx,[r11+0x3]
    97cb:	inc    r9d
    97ce:	add    rax,rcx
    97d1:	add    rcx,r13
    97d4:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    97d9:	vaddsd xmm1,xmm1,QWORD PTR [r10+rax*8]
    97df:	vmovsd QWORD PTR [r10+rax*8],xmm1
    97e5:	cmp    rdx,rdi
    97e8:	jne    968c <bench_ada__run_20.isra.0+0x12c>
    97ee:	xchg   ax,ax
    97f0:	mov    rdi,r8
    97f3:	cmp    r8,QWORD PTR [rsp+0x60]
    97f8:	jne    9640 <bench_ada__run_20.isra.0+0xe0>
    97fe:	mov    r15d,DWORD PTR [rsp+0x40]
    9803:	mov    r12,QWORD PTR [rsp+0x38]
    9808:	vzeroupper
    980b:	mov    rax,QWORD PTR [rsp+0x58]
    9810:	mov    rsi,QWORD PTR [rbp+0x10]
    9814:	mov    rdi,QWORD PTR [rbp+0x18]
    9818:	mov    rcx,QWORD PTR [rbp+0x28]
    981c:	cmp    DWORD PTR [rsp+0x48],r15d
    9821:	jne    95d0 <bench_ada__run_20.isra.0+0x70>
    9827:	lea    rsp,[rbp-0x28]
    982b:	pop    rbx
    982c:	pop    r12
    982e:	pop    r13
    9830:	pop    r14
    9832:	pop    r15
    9834:	pop    rbp
    9835:	ret
    9836:	cs nop WORD PTR [rax+rax*1+0x0]
    9840:	xor    r12d,r12d
    9843:	mov    r11d,0xffffffff
    9849:	jmp    9730 <bench_ada__run_20.isra.0+0x1d0>
    984e:	xchg   ax,ax


<bench_ada__run_3.isra.0>:
    4230:	mov    r10d,edi
    4233:	mov    r11,QWORD PTR [rsp+0x10]
    4238:	mov    rdi,rdx
    423b:	mov    rax,rsi
    423e:	mov    rdx,QWORD PTR [rsp+0x8]
    4243:	test   r10d,r10d
    4246:	je     42b0 <bench_ada__run_3.isra.0+0x80>
    4248:	xor    esi,esi
    424a:	nop    WORD PTR [rax+rax*1+0x0]
    4250:	inc    esi
    4252:	vmovupd xmm0,XMMWORD PTR [r8]
    4257:	vmovsd xmm1,QWORD PTR [rax+0x10]
    425c:	vmovsd xmm3,QWORD PTR [r8+0x10]
    4262:	vunpckhpd xmm2,xmm0,xmm0
    4266:	vmulsd xmm2,xmm2,QWORD PTR [rax+0x28]
    426b:	vmulsd xmm1,xmm1,xmm0
    426f:	vaddsd xmm1,xmm1,xmm2
    4273:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x40]
    4278:	vmovddup xmm3,xmm3
    427c:	vmulpd xmm3,xmm3,XMMWORD PTR [rax+0x30]
    4281:	vaddsd xmm1,xmm1,xmm2
    4285:	vpermilpd xmm2,xmm0,0x0
    428b:	vpermilpd xmm0,xmm0,0x3
    4291:	vmulpd xmm2,xmm2,XMMWORD PTR [rax]
    4295:	vmulpd xmm0,xmm0,XMMWORD PTR [rax+0x18]
    429a:	vmovsd QWORD PTR [rdx+0x10],xmm1
    429f:	vaddpd xmm0,xmm2,xmm0
    42a3:	vaddpd xmm0,xmm0,xmm3
    42a7:	vmovupd XMMWORD PTR [rdx],xmm0
    42ab:	cmp    r10d,esi
    42ae:	jne    4250 <bench_ada__run_3.isra.0+0x20>
    42b0:	ret
    42b1:	nop
    42b2:	nop    DWORD PTR [rax]
    42b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_4.isra.0>:
    42c0:	push   rbp
    42c1:	mov    r10d,edi
    42c4:	mov    rdi,rcx
    42c7:	mov    rbp,rsp
    42ca:	push   rbx
    42cb:	and    rsp,0xffffffffffffffc0
    42cf:	sub    rsp,0x8
    42d3:	mov    rcx,QWORD PTR [rbp+0x10]
    42d7:	mov    r11,QWORD PTR [rbp+0x18]
    42db:	test   r10d,r10d
    42de:	je     4427 <bench_ada__run_4.isra.0+0x167>
    42e4:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2d4d2]        # 317c0 <__gnat_ada_main_program_name+0x10>
    42ee:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2d508]        # 31800 <__gnat_ada_main_program_name+0x50>
    42f8:	mov    rax,rsi
    42fb:	xor    esi,esi
    42fd:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2d539]        # 31840 <__gnat_ada_main_program_name+0x90>
    4307:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2d56f]        # 31880 <__gnat_ada_main_program_name+0xd0>
    4311:	nop    DWORD PTR [rax+0x0]
    4315:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4320:	inc    esi
    4322:	vmovupd zmm1,ZMMWORD PTR [rdx]
    4328:	vmovupd zmm4,ZMMWORD PTR [rax]
    432e:	vmovsd xmm6,QWORD PTR [rdx+0x40]
    4333:	vmovsd xmm12,QWORD PTR [rdx+0x30]
    4338:	vmovsd xmm5,QWORD PTR [rdx+0x38]
    433d:	vmovsd xmm3,QWORD PTR [rax+0x10]
    4342:	vmovsd xmm7,QWORD PTR [rax+0x28]
    4347:	vmovsd xmm13,QWORD PTR [rax+0x40]
    434c:	vpermpd zmm2,zmm10,zmm1
    4352:	vpermpd zmm0,zmm11,zmm4
    4358:	vpermpd zmm14,zmm8,zmm4
    435e:	vmulpd zmm0,zmm0,zmm2
    4364:	vpermpd zmm2,zmm9,zmm1
    436a:	vmulpd zmm2,zmm2,zmm14
    4370:	vaddpd zmm0,zmm0,zmm2
    4376:	vunpcklpd xmm2,xmm12,xmm5
    437a:	vunpcklpd xmm12,xmm6,xmm12
    437f:	vunpcklpd xmm5,xmm5,xmm6
    4383:	vinsertf64x2 ymm5,ymm5,xmm2,0x1
    438a:	vmulsd xmm6,xmm6,xmm13
    438f:	vinsertf64x2 ymm2,ymm2,xmm12,0x1
    4396:	vmovddup xmm12,xmm13
    439b:	vinsertf64x4 zmm2,zmm2,ymm5,0x1
    43a2:	vmovddup xmm5,xmm7
    43a6:	vunpcklpd xmm7,xmm3,xmm7
    43aa:	vmovddup xmm3,xmm3
    43ae:	vinsertf64x2 ymm5,ymm5,xmm12,0x1
    43b5:	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    43bc:	vinsertf64x4 zmm3,zmm3,ymm5,0x1
    43c3:	vmulpd zmm2,zmm2,zmm3
    43c9:	vextractf64x2 xmm3,zmm4,0x3
    43d0:	vaddpd zmm0,zmm0,zmm2
    43d6:	vmovdqu64 ZMMWORD PTR [rcx],zmm0
    43dc:	vmovapd ZMMWORD PTR [rsp-0x78],zmm0
    43e7:	vextractf64x2 xmm2,ymm1,0x1
    43ee:	valignq zmm4,zmm4,zmm4,0x7
    43f5:	vmulsd xmm2,xmm2,xmm3
    43f9:	valignq zmm1,zmm1,zmm1,0x5
    4400:	vmulsd xmm1,xmm1,xmm4
    4404:	vaddsd xmm1,xmm2,xmm1
    4408:	vaddsd xmm1,xmm1,xmm6
    440c:	vmovsd QWORD PTR [rsp-0x38],xmm1
    4412:	mov    rbx,QWORD PTR [rsp-0x38]
    4417:	mov    QWORD PTR [rcx+0x40],rbx
    441b:	cmp    r10d,esi
    441e:	jne    4320 <bench_ada__run_4.isra.0+0x60>
    4424:	vzeroupper
    4427:	mov    rbx,QWORD PTR [rbp-0x8]
    442b:	leave
    442c:	ret
    442d:	nop
    442e:	xchg   ax,ax


<bench_ada__run_5.isra.0>:
    4430:	push   rbp
    4431:	mov    r10d,edi
    4434:	mov    rdi,rcx
    4437:	mov    rbp,rsp
    443a:	push   rbx
    443b:	and    rsp,0xffffffffffffffc0
    443f:	sub    rsp,0x8
    4443:	mov    rcx,QWORD PTR [rbp+0x10]
    4447:	mov    r11,QWORD PTR [rbp+0x18]
    444b:	test   r10d,r10d
    444e:	je     4597 <bench_ada__run_5.isra.0+0x167>
    4454:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2d462]        # 318c0 <__gnat_ada_main_program_name+0x110>
    445e:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2d398]        # 31800 <__gnat_ada_main_program_name+0x50>
    4468:	mov    rax,rsi
    446b:	xor    esi,esi
    446d:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2d3c9]        # 31840 <__gnat_ada_main_program_name+0x90>
    4477:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2d47f]        # 31900 <__gnat_ada_main_program_name+0x150>
    4481:	nop    DWORD PTR [rax+0x0]
    4485:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4490:	inc    esi
    4492:	vmovupd zmm1,ZMMWORD PTR [rdx]
    4498:	vmovupd zmm4,ZMMWORD PTR [rax]
    449e:	vmovsd xmm6,QWORD PTR [rdx+0x40]
    44a3:	vmovsd xmm12,QWORD PTR [rdx+0x30]
    44a8:	vmovsd xmm5,QWORD PTR [rdx+0x38]
    44ad:	vmovsd xmm3,QWORD PTR [rax+0x30]
    44b2:	vmovsd xmm7,QWORD PTR [rax+0x38]
    44b7:	vmovsd xmm13,QWORD PTR [rax+0x40]
    44bc:	vpermpd zmm2,zmm10,zmm1
    44c2:	vpermpd zmm0,zmm11,zmm4
    44c8:	vpermpd zmm14,zmm8,zmm4
    44ce:	vmulpd zmm0,zmm0,zmm2
    44d4:	vpermpd zmm2,zmm9,zmm1
    44da:	vmulpd zmm2,zmm2,zmm14
    44e0:	vaddpd zmm0,zmm0,zmm2
    44e6:	vunpcklpd xmm2,xmm12,xmm5
    44ea:	vunpcklpd xmm12,xmm6,xmm12
    44ef:	vunpcklpd xmm5,xmm5,xmm6
    44f3:	vinsertf64x2 ymm5,ymm5,xmm2,0x1
    44fa:	vmulsd xmm6,xmm6,xmm13
    44ff:	vinsertf64x2 ymm2,ymm2,xmm12,0x1
    4506:	vmovddup xmm12,xmm13
    450b:	vinsertf64x4 zmm2,zmm2,ymm5,0x1
    4512:	vmovddup xmm5,xmm7
    4516:	vunpcklpd xmm7,xmm3,xmm7
    451a:	vmovddup xmm3,xmm3
    451e:	vinsertf64x2 ymm5,ymm5,xmm12,0x1
    4525:	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    452c:	vinsertf64x4 zmm3,zmm3,ymm5,0x1
    4533:	vmulpd zmm2,zmm2,zmm3
    4539:	vextractf64x2 xmm3,ymm4,0x1
    4540:	vaddpd zmm0,zmm0,zmm2
    4546:	vmovdqu64 ZMMWORD PTR [rcx],zmm0
    454c:	vmovapd ZMMWORD PTR [rsp-0x78],zmm0
    4557:	vextractf64x2 xmm2,ymm1,0x1
    455e:	valignq zmm4,zmm4,zmm4,0x5
    4565:	vmulsd xmm2,xmm2,xmm3
    4569:	valignq zmm1,zmm1,zmm1,0x5
    4570:	vmulsd xmm1,xmm1,xmm4
    4574:	vaddsd xmm1,xmm2,xmm1
    4578:	vaddsd xmm1,xmm1,xmm6
    457c:	vmovsd QWORD PTR [rsp-0x38],xmm1
    4582:	mov    rbx,QWORD PTR [rsp-0x38]
    4587:	mov    QWORD PTR [rcx+0x40],rbx
    458b:	cmp    r10d,esi
    458e:	jne    4490 <bench_ada__run_5.isra.0+0x60>
    4594:	vzeroupper
    4597:	mov    rbx,QWORD PTR [rbp-0x8]
    459b:	leave
    459c:	ret
    459d:	nop
    459e:	xchg   ax,ax


<bench_ada__run_6.isra.0>:
    45a0:	push   rbp
    45a1:	mov    r10d,edi
    45a4:	mov    rdi,rcx
    45a7:	mov    rbp,rsp
    45aa:	push   rbx
    45ab:	and    rsp,0xffffffffffffffc0
    45af:	sub    rsp,0x8
    45b3:	mov    rcx,QWORD PTR [rbp+0x10]
    45b7:	mov    r11,QWORD PTR [rbp+0x18]
    45bb:	test   r10d,r10d
    45be:	je     4707 <bench_ada__run_6.isra.0+0x167>
    45c4:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2d1f2]        # 317c0 <__gnat_ada_main_program_name+0x10>
    45ce:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2d368]        # 31940 <__gnat_ada_main_program_name+0x190>
    45d8:	mov    rax,rsi
    45db:	xor    esi,esi
    45dd:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2d399]        # 31980 <__gnat_ada_main_program_name+0x1d0>
    45e7:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2d28f]        # 31880 <__gnat_ada_main_program_name+0xd0>
    45f1:	nop    DWORD PTR [rax+0x0]
    45f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4600:	inc    esi
    4602:	vmovupd zmm1,ZMMWORD PTR [rdx]
    4608:	vmovupd zmm4,ZMMWORD PTR [rax]
    460e:	vmovsd xmm6,QWORD PTR [rdx+0x40]
    4613:	vmovsd xmm12,QWORD PTR [rdx+0x10]
    4618:	vmovsd xmm5,QWORD PTR [rdx+0x28]
    461d:	vmovsd xmm3,QWORD PTR [rax+0x10]
    4622:	vmovsd xmm7,QWORD PTR [rax+0x28]
    4627:	vmovsd xmm13,QWORD PTR [rax+0x40]
    462c:	vpermpd zmm2,zmm10,zmm1
    4632:	vpermpd zmm0,zmm11,zmm4
    4638:	vpermpd zmm14,zmm8,zmm4
    463e:	vmulpd zmm0,zmm0,zmm2
    4644:	vpermpd zmm2,zmm9,zmm1
    464a:	vmulpd zmm2,zmm2,zmm14
    4650:	vaddpd zmm0,zmm0,zmm2
    4656:	vunpcklpd xmm2,xmm12,xmm5
    465a:	vunpcklpd xmm12,xmm6,xmm12
    465f:	vunpcklpd xmm5,xmm5,xmm6
    4663:	vinsertf64x2 ymm5,ymm5,xmm2,0x1
    466a:	vmulsd xmm6,xmm6,xmm13
    466f:	vinsertf64x2 ymm2,ymm2,xmm12,0x1
    4676:	vmovddup xmm12,xmm13
    467b:	vinsertf64x4 zmm2,zmm2,ymm5,0x1
    4682:	vmovddup xmm5,xmm7
    4686:	vunpcklpd xmm7,xmm3,xmm7
    468a:	vmovddup xmm3,xmm3
    468e:	vinsertf64x2 ymm5,ymm5,xmm12,0x1
    4695:	vinsertf64x2 ymm3,ymm3,xmm7,0x1
    469c:	vinsertf64x4 zmm3,zmm3,ymm5,0x1
    46a3:	vmulpd zmm2,zmm2,zmm3
    46a9:	vextractf64x2 xmm3,zmm4,0x3
    46b0:	vaddpd zmm0,zmm0,zmm2
    46b6:	vmovdqu64 ZMMWORD PTR [rcx],zmm0
    46bc:	vmovapd ZMMWORD PTR [rsp-0x78],zmm0
    46c7:	vextractf64x2 xmm2,zmm1,0x3
    46ce:	valignq zmm4,zmm4,zmm4,0x7
    46d5:	vmulsd xmm2,xmm2,xmm3
    46d9:	valignq zmm1,zmm1,zmm1,0x7
    46e0:	vmulsd xmm1,xmm1,xmm4
    46e4:	vaddsd xmm1,xmm2,xmm1
    46e8:	vaddsd xmm1,xmm1,xmm6
    46ec:	vmovsd QWORD PTR [rsp-0x38],xmm1
    46f2:	mov    rbx,QWORD PTR [rsp-0x38]
    46f7:	mov    QWORD PTR [rcx+0x40],rbx
    46fb:	cmp    r10d,esi
    46fe:	jne    4600 <bench_ada__run_6.isra.0+0x60>
    4704:	vzeroupper
    4707:	mov    rbx,QWORD PTR [rbp-0x8]
    470b:	leave
    470c:	ret
    470d:	nop
    470e:	xchg   ax,ax


<bench_ada__run_7.isra.0>:
    4710:	push   rbp
    4711:	mov    r10,rcx
    4714:	mov    rcx,r8
    4717:	mov    rbp,rsp
    471a:	push   r15
    471c:	push   r14
    471e:	push   r13
    4720:	push   r12
    4722:	push   rbx
    4723:	and    rsp,0xffffffffffffffe0
    4727:	mov    r8,QWORD PTR [rbp+0x10]
    472b:	mov    DWORD PTR [rsp-0xc],edx
    472f:	mov    r14,QWORD PTR [rbp+0x18]
    4733:	mov    r11,QWORD PTR [rbp+0x20]
    4737:	test   edx,edx
    4739:	je     47c9 <bench_ada__run_7.isra.0+0xb9>
    473f:	mov    rbx,QWORD PTR [rbp+0x28]
    4743:	mov    rax,r9
    4746:	test   edi,edi
    4748:	je     48df <bench_ada__run_7.isra.0+0x1cf>
    474e:	mov    DWORD PTR [rsp-0x8],0x1
    4756:	mov    DWORD PTR [rsp-0x4],esi
    475a:	mov    edx,esi
    475c:	mov    r13,rax
    475f:	lea    rbx,[rdx*8+0x0]
    4767:	mov    r9d,edi
    476a:	lea    eax,[rsi-0x1]
    476d:	mov    QWORD PTR [rsp-0x20],rbx
    4772:	mov    ebx,esi
    4774:	and    ebx,0x3
    4777:	xor    esi,esi
    4779:	movsxd rdx,esi
    477c:	cmp    eax,0x2
    477f:	jg     4906 <bench_ada__run_7.isra.0+0x1f6>
    4785:	cmp    eax,0xffffffff
    4788:	je     48b0 <bench_ada__run_7.isra.0+0x1a0>
    478e:	mov    edi,DWORD PTR [rsp-0x4]
    4792:	cmp    edi,0x2
    4795:	je     4803 <bench_ada__run_7.isra.0+0xf3>
    4797:	cmp    edi,0x3
    479a:	je     4864 <bench_ada__run_7.isra.0+0x154>
    47a0:	vmovsd xmm0,QWORD PTR [r8]
    47a5:	vmulsd xmm0,xmm0,QWORD PTR [r10+rdx*8]
    47ab:	vxorpd xmm1,xmm1,xmm1
    47af:	vaddsd xmm0,xmm0,xmm1
    47b3:	vmovsd QWORD PTR [r11+rsi*8],xmm0
    47b9:	inc    rsi
    47bc:	cmp    r9,rsi
    47bf:	je     4840 <bench_ada__run_7.isra.0+0x130>
    47c1:	movsxd rdx,esi
    47c4:	jmp    478e <bench_ada__run_7.isra.0+0x7e>
    47c6:	vzeroupper
    47c9:	lea    rsp,[rbp-0x28]
    47cd:	pop    rbx
    47ce:	pop    r12
    47d0:	pop    r13
    47d2:	pop    r14
    47d4:	pop    r15
    47d6:	pop    rbp
    47d7:	ret
    47d8:	nop    DWORD PTR [rax+0x0]
    47df:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    47ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    47f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4800:	movsxd rdx,esi
    4803:	shl    rdx,0x4
    4807:	add    rdx,r10
    480a:	vmovsd xmm0,QWORD PTR [r8]
    480f:	vmovsd xmm1,QWORD PTR [r8+0x8]
    4815:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    4819:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    481e:	vaddsd xmm0,xmm0,xmm1
    4822:	vxorpd xmm1,xmm1,xmm1
    4826:	vaddsd xmm0,xmm0,xmm1
    482a:	vmovsd QWORD PTR [r11+rsi*8],xmm0
    4830:	inc    rsi
    4833:	cmp    r9,rsi
    4836:	jne    4800 <bench_ada__run_7.isra.0+0xf0>
    4838:	nop    DWORD PTR [rax+rax*1+0x0]
    4840:	mov    rdi,QWORD PTR [rbp+0x28]
    4844:	mov    edi,DWORD PTR [rsp-0x8]
    4848:	cmp    DWORD PTR [rsp-0xc],edi
    484c:	je     47c6 <bench_ada__run_7.isra.0+0xb6>
    4852:	inc    edi
    4854:	mov    DWORD PTR [rsp-0x8],edi
    4858:	mov    rdi,QWORD PTR [rbp+0x28]
    485c:	jmp    4777 <bench_ada__run_7.isra.0+0x67>
    4861:	movsxd rdx,esi
    4864:	imul   rdx,rdx,0x18
    4868:	vmovsd xmm0,QWORD PTR [r8]
    486d:	vmovsd xmm1,QWORD PTR [r8+0x8]
    4873:	add    rdx,r10
    4876:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    487b:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    487f:	vaddsd xmm0,xmm0,xmm1
    4883:	vmovsd xmm1,QWORD PTR [r8+0x10]
    4889:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    488e:	vaddsd xmm0,xmm0,xmm1
    4892:	vxorpd xmm1,xmm1,xmm1
    4896:	vaddsd xmm0,xmm0,xmm1
    489a:	vmovsd QWORD PTR [r11+rsi*8],xmm0
    48a0:	inc    rsi
    48a3:	cmp    r9,rsi
    48a6:	jne    4861 <bench_ada__run_7.isra.0+0x151>
    48a8:	jmp    4840 <bench_ada__run_7.isra.0+0x130>
    48aa:	nop    WORD PTR [rax+rax*1+0x0]
    48b0:	lea    rdx,[rsi+0x1]
    48b4:	mov    QWORD PTR [r11+rsi*8],0x0
    48bc:	cmp    r9,rdx
    48bf:	je     4840 <bench_ada__run_7.isra.0+0x130>
    48c5:	add    rsi,0x2
    48c9:	mov    QWORD PTR [r11+rdx*8],0x0
    48d1:	cmp    r9,rsi
    48d4:	jne    4779 <bench_ada__run_7.isra.0+0x69>
    48da:	jmp    4840 <bench_ada__run_7.isra.0+0x130>
    48df:	mov    rsi,QWORD PTR [rbp+0x28]
    48e3:	mov    edi,DWORD PTR [rsp-0xc]
    48e7:	mov    edx,0x1
    48ec:	cmp    edi,edx
    48ee:	je     47c9 <bench_ada__run_7.isra.0+0xb9>
    48f4:	lea    r9d,[rdx+0x1]
    48f8:	cmp    edi,r9d
    48fb:	je     47c9 <bench_ada__run_7.isra.0+0xb9>
    4901:	add    edx,0x2
    4904:	jmp    48ec <bench_ada__run_7.isra.0+0x1dc>
    4906:	mov    edi,DWORD PTR [rsp-0x4]
    490a:	mov    r12,QWORD PTR [rsp-0x20]
    490f:	mov    DWORD PTR [rsp-0x24],eax
    4913:	mov    QWORD PTR [rsp-0x30],rcx
    4918:	mov    QWORD PTR [rbp+0x18],r14
    491c:	vmovd  xmm6,eax
    4920:	mov    r14,r13
    4923:	sar    edi,0x2
    4926:	lea    r15d,[rdi-0x1]
    492a:	mov    DWORD PTR [rsp-0x10],edi
    492e:	sub    edi,0x4
    4931:	and    edi,0xfffffffe
    4934:	vmovd  xmm5,r15d
    4939:	add    edi,0x2
    493c:	mov    DWORD PTR [rsp-0x28],edi
    4940:	mov    rdi,r10
    4943:	sub    rdi,r8
    4946:	mov    QWORD PTR [rsp-0x18],rdi
    494b:	mov    rdi,QWORD PTR [rsp-0x20]
    4950:	shr    r12,0x3
    4954:	mov    rcx,r12
    4957:	mov    r12,rsi
    495a:	add    rdi,r8
    495d:	vmovq  xmm4,rdi
    4962:	mov    edi,DWORD PTR [rsp-0x28]
    4966:	cs nop WORD PTR [rax+rax*1+0x0]
    4970:	movsxd r13,edx
    4973:	mov    r15,rcx
    4976:	vmovd  eax,xmm5
    497a:	vmovupd ymm0,YMMWORD PTR [r8]
    497f:	imul   r15,r13
    4983:	vmulpd ymm0,ymm0,YMMWORD PTR [r10+r15*8]
    4989:	test   eax,eax
    498b:	je     4a16 <bench_ada__run_7.isra.0+0x306>
    4991:	cmp    DWORD PTR [rsp-0x10],0x3
    4996:	jle    4aec <bench_ada__run_7.isra.0+0x3dc>
    499c:	mov    rdx,QWORD PTR [rsp-0x18]
    49a1:	lea    rax,[r8+0x20]
    49a5:	lea    rsi,[rdx+r15*8]
    49a9:	xor    edx,edx
    49ab:	cs nop WORD PTR [rax+rax*1+0x0]
    49b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    49c0:	vmovupd ymm1,YMMWORD PTR [rax]
    49c4:	vmulpd ymm1,ymm1,YMMWORD PTR [rax+rsi*1]
    49c9:	vmovupd ymm2,YMMWORD PTR [rax+0x20]
    49ce:	add    edx,0x2
    49d1:	vmulpd ymm2,ymm2,YMMWORD PTR [rax+rsi*1+0x20]
    49d7:	add    rax,0x40
    49db:	vaddpd ymm0,ymm1,ymm0
    49df:	vaddpd ymm0,ymm2,ymm0
    49e3:	cmp    edi,edx
    49e5:	jne    49c0 <bench_ada__run_7.isra.0+0x2b0>
    49e7:	mov    esi,edx
    49e9:	inc    edx
    49eb:	lea    rax,[rsi+0x1]
    49ef:	lea    rsi,[r15+rsi*4+0x4]
    49f4:	vmovd  r15d,xmm5
    49f9:	shl    rax,0x5
    49fd:	vmovupd ymm1,YMMWORD PTR [r8+rax*1]
    4a03:	vmulpd ymm1,ymm1,YMMWORD PTR [r10+rsi*8]
    4a09:	vaddpd ymm0,ymm1,ymm0
    4a0d:	cmp    edx,r15d
    4a10:	jne    4ac3 <bench_ada__run_7.isra.0+0x3b3>
    4a16:	vextractf64x2 xmm3,ymm0,0x1
    4a1d:	vunpckhpd xmm1,xmm0,xmm0
    4a21:	vaddsd xmm2,xmm0,xmm3
    4a25:	valignq ymm0,ymm0,ymm0,0x3
    4a2c:	vaddsd xmm1,xmm1,xmm0
    4a30:	vaddsd xmm2,xmm2,xmm1
    4a34:	test   ebx,ebx
    4a36:	je     4aa0 <bench_ada__run_7.isra.0+0x390>
    4a38:	mov    rax,r13
    4a3b:	vmovq  rsi,xmm6
    4a40:	vmovq  rdx,xmm4
    4a45:	imul   rax,rcx
    4a49:	vmovsd xmm0,QWORD PTR [rdx-0x8]
    4a4e:	add    rax,rsi
    4a51:	vmulsd xmm0,xmm0,QWORD PTR [r10+rax*8]
    4a57:	cmp    ebx,0x2
    4a5a:	je     4ada <bench_ada__run_7.isra.0+0x3ca>
    4a5c:	cmp    ebx,0x3
    4a5f:	jne    4a81 <bench_ada__run_7.isra.0+0x371>
    4a61:	vmovsd xmm1,QWORD PTR [r10+rax*8-0x10]
    4a68:	vmulsd xmm1,xmm1,QWORD PTR [rdx-0x18]
    4a6d:	vmovsd xmm3,QWORD PTR [r10+rax*8-0x8]
    4a74:	vmulsd xmm3,xmm3,QWORD PTR [rdx-0x10]
    4a79:	vaddsd xmm1,xmm1,xmm3
    4a7d:	vaddsd xmm0,xmm0,xmm1
    4a81:	vaddsd xmm0,xmm0,xmm2
    4a85:	vmovsd QWORD PTR [r11+r12*8],xmm0
    4a8b:	inc    r12
    4a8e:	cmp    r9,r12
    4a91:	je     4aae <bench_ada__run_7.isra.0+0x39e>
    4a93:	mov    edx,r12d
    4a96:	jmp    4970 <bench_ada__run_7.isra.0+0x260>
    4a9b:	nop    DWORD PTR [rax+rax*1+0x0]
    4aa0:	vmovsd QWORD PTR [r11+r12*8],xmm2
    4aa6:	inc    r12
    4aa9:	cmp    r9,r12
    4aac:	jne    4a93 <bench_ada__run_7.isra.0+0x383>
    4aae:	mov    r13,r14
    4ab1:	mov    eax,DWORD PTR [rsp-0x24]
    4ab5:	mov    rcx,QWORD PTR [rsp-0x30]
    4aba:	mov    r14,QWORD PTR [rbp+0x18]
    4abe:	jmp    4840 <bench_ada__run_7.isra.0+0x130>
    4ac3:	vmovupd ymm1,YMMWORD PTR [rax+r8*1+0x20]
    4aca:	vmulpd ymm1,ymm1,YMMWORD PTR [r10+rsi*8+0x20]
    4ad1:	vaddpd ymm0,ymm0,ymm1
    4ad5:	jmp    4a16 <bench_ada__run_7.isra.0+0x306>
    4ada:	vmovsd xmm1,QWORD PTR [r10+rax*8-0x8]
    4ae1:	vmulsd xmm1,xmm1,QWORD PTR [rdx-0x10]
    4ae6:	vaddsd xmm0,xmm0,xmm1
    4aea:	jmp    4a81 <bench_ada__run_7.isra.0+0x371>
    4aec:	xor    edx,edx
    4aee:	jmp    49e7 <bench_ada__run_7.isra.0+0x2d7>
    4af3:	nop
    4af4:	nop
    4af5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_8.isra.0>:
    7c10:	push   rbp
    7c11:	mov    rbp,rsp
    7c14:	push   r15
    7c16:	push   r14
    7c18:	push   r13
    7c1a:	push   r12
    7c1c:	push   rbx
    7c1d:	mov    r13,rcx
    7c20:	and    rsp,0xffffffffffffffc0
    7c24:	add    rsp,0xffffffffffffff80
    7c28:	mov    rcx,QWORD PTR [rbp+0x20]
    7c2c:	test   edx,edx
    7c2e:	je     7e94 <bench_ada__run_8.isra.0+0x284>
    7c34:	mov    ebx,esi
    7c36:	mov    DWORD PTR [rsp+0x48],edx
    7c3a:	mov    DWORD PTR [rsp+0x4c],edi
    7c3e:	mov    QWORD PTR [rsp+0x78],r8
    7c43:	test   ebx,ebx
    7c45:	lea    edx,[rbx-0x1]
    7c48:	lea    rsi,[rbx*8+0x0]
    7c50:	mov    QWORD PTR [rsp+0x50],rbx
    7c55:	setne  r15b
    7c59:	sub    rbx,0x8
    7c5d:	movsxd rax,edx
    7c60:	mov    QWORD PTR [rsp+0x60],rsi
    7c65:	mov    QWORD PTR [rsp+0x68],rax
    7c6a:	mov    r12,r9
    7c6d:	xor    r14d,r14d
    7c70:	shr    rbx,0x3
    7c74:	inc    rbx
    7c77:	lea    rax,[rbx*8+0x0]
    7c7f:	mov    QWORD PTR [rsp+0x38],rax
    7c84:	nop
    7c85:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7c90:	mov    rax,QWORD PTR [rsp+0x78]
    7c95:	mov    rsi,QWORD PTR [rbp+0x10]
    7c99:	mov    rdi,QWORD PTR [rbp+0x18]
    7c9d:	mov    rdx,QWORD PTR [rbp+0x28]
    7ca1:	inc    r14d
    7ca4:	mov    rdx,QWORD PTR [rsp+0x60]
    7ca9:	mov    rdi,rcx
    7cac:	xor    esi,esi
    7cae:	call   2bd0 <memset@plt>
    7cb3:	mov    rcx,rax
    7cb6:	mov    eax,DWORD PTR [rsp+0x4c]
    7cba:	test   eax,eax
    7cbc:	je     7e78 <bench_ada__run_8.isra.0+0x268>
    7cc2:	mov    rsi,QWORD PTR [rsp+0x60]
    7cc7:	mov    r11d,eax
    7cca:	mov    DWORD PTR [rsp+0x44],r14d
    7ccf:	xor    eax,eax
    7cd1:	vxorpd xmm4,xmm4,xmm4
    7cd5:	shr    rsi,0x3
    7cd9:	mov    QWORD PTR [rsp+0x70],rsi
    7cde:	lea    rsi,[rcx-0x8]
    7ce2:	mov    QWORD PTR [rsp+0x58],rsi
    7ce7:	jmp    7d0c <bench_ada__run_8.isra.0+0xfc>
    7ce9:	nop
    7cea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7cf5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7d00:	inc    rax
    7d03:	cmp    rax,r11
    7d06:	je     7e70 <bench_ada__run_8.isra.0+0x260>
    7d0c:	vmovsd xmm1,QWORD PTR [r12+rax*8]
    7d12:	vcomisd xmm1,xmm4
    7d16:	vbroadcastsd zmm2,xmm1
    7d1c:	je     7d00 <bench_ada__run_8.isra.0+0xf0>
    7d1e:	test   r15b,r15b
    7d21:	je     7d00 <bench_ada__run_8.isra.0+0xf0>
    7d23:	mov    rsi,QWORD PTR [rsp+0x70]
    7d28:	mov    rdx,QWORD PTR [rsp+0x58]
    7d2d:	movsxd r14,eax
    7d30:	imul   rsi,r14
    7d34:	lea    r8,[r13+rsi*8+0x0]
    7d39:	sub    rdx,r8
    7d3c:	cmp    rdx,0x30
    7d40:	jbe    7eb0 <bench_ada__run_8.isra.0+0x2a0>
    7d46:	cmp    QWORD PTR [rsp+0x68],0x6
    7d4c:	jbe    7efc <bench_ada__run_8.isra.0+0x2ec>
    7d52:	vmovapd zmm3,zmm2
    7d58:	mov    rdx,rcx
    7d5b:	xor    edi,edi
    7d5d:	sub    r8,rcx
    7d60:	cs nop WORD PTR [rax+rax*1+0x0]
    7d6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7d75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7d80:	vmulpd zmm0,zmm3,ZMMWORD PTR [rdx+r8*1]
    7d87:	inc    rdi
    7d8a:	add    rdx,0x40
    7d8e:	vaddpd zmm0,zmm0,ZMMWORD PTR [rdx-0x40]
    7d95:	vmovupd ZMMWORD PTR [rdx-0x40],zmm0
    7d9c:	cmp    rdi,rbx
    7d9f:	jb     7d80 <bench_ada__run_8.isra.0+0x170>
    7da1:	mov    rdi,QWORD PTR [rsp+0x38]
    7da6:	mov    rdx,rdi
    7da9:	cmp    QWORD PTR [rsp+0x50],rdi
    7dae:	je     7d00 <bench_ada__run_8.isra.0+0xf0>
    7db4:	lea    r8,[rdi-0x1]
    7db8:	mov    r10,QWORD PTR [rsp+0x68]
    7dbd:	sub    r10,rdx
    7dc0:	lea    rdi,[r10+0x1]
    7dc4:	cmp    r10,0x2
    7dc8:	jbe    7f0a <bench_ada__run_8.isra.0+0x2fa>
    7dce:	lea    r9,[rcx+rdx*8]
    7dd2:	vmovq  xmm5,r9
    7dd7:	lea    r9,[rsi+rdx*1]
    7ddb:	vmulpd ymm0,ymm2,YMMWORD PTR [r13+r9*8+0x0]
    7de2:	vmovq  r9,xmm5
    7de7:	vaddpd ymm0,ymm0,YMMWORD PTR [r9]
    7dec:	vmovupd YMMWORD PTR [r9],ymm0
    7df1:	mov    r9,rdi
    7df4:	and    r9,0xfffffffffffffffc
    7df8:	add    r8,r9
    7dfb:	test   dil,0x3
    7dff:	je     7d00 <bench_ada__run_8.isra.0+0xf0>
    7e05:	cmp    r10,r9
    7e08:	je     7e37 <bench_ada__run_8.isra.0+0x227>
    7e0a:	add    rdx,r9
    7e0d:	sub    rdi,r9
    7e10:	add    rsi,rdx
    7e13:	vmulpd xmm0,xmm2,XMMWORD PTR [r13+rsi*8+0x0]
    7e1a:	vaddpd xmm0,xmm0,XMMWORD PTR [rcx+rdx*8]
    7e1f:	vmovupd XMMWORD PTR [rcx+rdx*8],xmm0
    7e24:	mov    rdx,rdi
    7e27:	and    rdx,0xfffffffffffffffe
    7e2b:	and    edi,0x1
    7e2e:	je     7d00 <bench_ada__run_8.isra.0+0xf0>
    7e34:	add    r8,rdx
    7e37:	imul   r14,QWORD PTR [rsp+0x70]
    7e3d:	inc    rax
    7e40:	lea    rdx,[r8+r14*1+0x1]
    7e45:	vmulsd xmm1,xmm1,QWORD PTR [r13+rdx*8+0x0]
    7e4c:	vaddsd xmm1,xmm1,QWORD PTR [rcx+r8*8+0x8]
    7e53:	vmovsd QWORD PTR [rcx+r8*8+0x8],xmm1
    7e5a:	cmp    rax,r11
    7e5d:	jne    7d0c <bench_ada__run_8.isra.0+0xfc>
    7e63:	xchg   ax,ax
    7e65:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7e70:	mov    r14d,DWORD PTR [rsp+0x44]
    7e75:	vzeroupper
    7e78:	mov    rax,QWORD PTR [rsp+0x78]
    7e7d:	mov    rsi,QWORD PTR [rbp+0x10]
    7e81:	mov    rdi,QWORD PTR [rbp+0x18]
    7e85:	mov    rdx,QWORD PTR [rbp+0x28]
    7e89:	cmp    DWORD PTR [rsp+0x48],r14d
    7e8e:	jne    7c90 <bench_ada__run_8.isra.0+0x80>
    7e94:	lea    rsp,[rbp-0x28]
    7e98:	pop    rbx
    7e99:	pop    r12
    7e9b:	pop    r13
    7e9d:	pop    r14
    7e9f:	pop    r15
    7ea1:	pop    rbp
    7ea2:	ret
    7ea3:	xchg   ax,ax
    7ea5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7eb0:	mov    rsi,QWORD PTR [rsp+0x60]
    7eb5:	mov    rdi,QWORD PTR [rsp+0x50]
    7eba:	xor    edx,edx
    7ebc:	imul   rsi,r14
    7ec0:	add    rsi,r13
    7ec3:	nop    DWORD PTR [rax+0x0]
    7eca:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7ed5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7ee0:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rdx*8]
    7ee5:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rdx*8]
    7eea:	vmovsd QWORD PTR [rcx+rdx*8],xmm0
    7eef:	inc    rdx
    7ef2:	cmp    rdi,rdx
    7ef5:	jne    7ee0 <bench_ada__run_8.isra.0+0x2d0>
    7ef7:	jmp    7d00 <bench_ada__run_8.isra.0+0xf0>
    7efc:	xor    edx,edx
    7efe:	mov    r8,0xffffffffffffffff
    7f05:	jmp    7db8 <bench_ada__run_8.isra.0+0x1a8>
    7f0a:	xor    r9d,r9d
    7f0d:	jmp    7e05 <bench_ada__run_8.isra.0+0x1f5>
    7f12:	nop    DWORD PTR [rax]
    7f15:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_9.isra.0>:
    4b00:	push   rbp
    4b01:	vxorpd xmm1,xmm1,xmm1
    4b05:	mov    rbp,rsp
    4b08:	push   r15
    4b0a:	push   r14
    4b0c:	push   r13
    4b0e:	push   r12
    4b10:	push   rbx
    4b11:	and    rsp,0xffffffffffffffe0
    4b15:	mov    r14,QWORD PTR [rbp+0x10]
    4b19:	mov    DWORD PTR [rsp-0x24],esi
    4b1d:	test   esi,esi
    4b1f:	je     4c20 <bench_ada__run_9.isra.0+0x120>
    4b25:	mov    eax,edi
    4b27:	mov    rdi,rdx
    4b2a:	xor    edx,edx
    4b2c:	mov    r10,rcx
    4b2f:	mov    DWORD PTR [rsp-0x18],edx
    4b33:	mov    DWORD PTR [rsp-0x14],eax
    4b37:	lea    ebx,[rax-0x1]
    4b3a:	mov    esi,eax
    4b3c:	mov    DWORD PTR [rsp-0xc],ebx
    4b40:	lea    rbx,[rsi*8+0x0]
    4b48:	lea    r15,[rsi-0x1]
    4b4c:	vmovapd xmm5,xmm1
    4b50:	mov    QWORD PTR [rsp-0x30],rbx
    4b55:	mov    rcx,r14
    4b58:	mov    ebx,eax
    4b5a:	and    ebx,0x3
    4b5d:	inc    DWORD PTR [rsp-0x18]
    4b61:	mov    rax,QWORD PTR [rbp+0x18]
    4b65:	mov    rsi,QWORD PTR [rbp+0x20]
    4b69:	mov    eax,DWORD PTR [rsp-0xc]
    4b6d:	inc    eax
    4b6f:	je     4c64 <bench_ada__run_9.isra.0+0x164>
    4b75:	cmp    DWORD PTR [rsp-0xc],0x2
    4b7a:	jg     4c97 <bench_ada__run_9.isra.0+0x197>
    4b80:	mov    eax,DWORD PTR [rsp-0x14]
    4b84:	vmovsd xmm2,QWORD PTR [r9]
    4b89:	xor    r11d,r11d
    4b8c:	vxorpd xmm3,xmm3,xmm3
    4b90:	xor    esi,esi
    4b92:	cmp    eax,0x2
    4b95:	je     4bc4 <bench_ada__run_9.isra.0+0xc4>
    4b97:	cmp    eax,0x3
    4b9a:	je     4c33 <bench_ada__run_9.isra.0+0x133>
    4ba0:	vmulsd xmm0,xmm2,QWORD PTR [rdi+r11*8]
    4ba6:	vaddsd xmm0,xmm0,xmm5
    4baa:	vmulsd xmm0,xmm0,QWORD PTR [r8+rsi*8]
    4bb0:	vaddsd xmm3,xmm3,xmm0
    4bb4:	cmp    rsi,r15
    4bb7:	je     4c03 <bench_ada__run_9.isra.0+0x103>
    4bb9:	inc    rsi
    4bbc:	movsxd r11,esi
    4bbf:	cmp    eax,0x2
    4bc2:	jne    4b97 <bench_ada__run_9.isra.0+0x97>
    4bc4:	shl    r11,0x4
    4bc8:	add    r11,rdi
    4bcb:	vmovsd xmm0,QWORD PTR [r9+0x8]
    4bd1:	vmulsd xmm4,xmm2,QWORD PTR [r11]
    4bd6:	vmulsd xmm0,xmm0,QWORD PTR [r11+0x8]
    4bdc:	vaddsd xmm0,xmm0,xmm4
    4be0:	jmp    4ba6 <bench_ada__run_9.isra.0+0xa6>
    4be2:	nop    DWORD PTR [rax]
    4be5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4bf0:	vmulsd xmm2,xmm2,QWORD PTR [r8+r12*8]
    4bf6:	vaddsd xmm3,xmm3,xmm2
    4bfa:	cmp    r12,r15
    4bfd:	jne    4e2b <bench_ada__run_9.isra.0+0x32b>
    4c03:	mov    rax,QWORD PTR [rbp+0x18]
    4c07:	mov    rsi,QWORD PTR [rbp+0x20]
    4c0b:	vaddsd xmm1,xmm1,xmm3
    4c0f:	mov    esi,DWORD PTR [rsp-0x18]
    4c13:	cmp    DWORD PTR [rsp-0x24],esi
    4c17:	jne    4b5d <bench_ada__run_9.isra.0+0x5d>
    4c1d:	vzeroupper
    4c20:	vmovapd xmm0,xmm1
    4c24:	lea    rsp,[rbp-0x28]
    4c28:	pop    rbx
    4c29:	pop    r12
    4c2b:	pop    r13
    4c2d:	pop    r14
    4c2f:	pop    r15
    4c31:	pop    rbp
    4c32:	ret
    4c33:	imul   r11,r11,0x18
    4c37:	vmovsd xmm0,QWORD PTR [r9+0x8]
    4c3d:	add    r11,rdi
    4c40:	vmulsd xmm4,xmm2,QWORD PTR [r11]
    4c45:	vmulsd xmm0,xmm0,QWORD PTR [r11+0x8]
    4c4b:	vaddsd xmm0,xmm0,xmm4
    4c4f:	vmovsd xmm4,QWORD PTR [r9+0x10]
    4c55:	vmulsd xmm4,xmm4,QWORD PTR [r11+0x10]
    4c5b:	vaddsd xmm0,xmm0,xmm4
    4c5f:	jmp    4ba6 <bench_ada__run_9.isra.0+0xa6>
    4c64:	mov    r14,rcx
    4c67:	mov    edx,DWORD PTR [rsp-0x18]
    4c6b:	mov    rcx,r10
    4c6e:	mov    rax,QWORD PTR [rbp+0x18]
    4c72:	mov    rsi,QWORD PTR [rbp+0x20]
    4c76:	mov    r10d,DWORD PTR [rsp-0x24]
    4c7b:	vxorpd xmm0,xmm0,xmm0
    4c7f:	nop
    4c80:	vaddsd xmm1,xmm1,xmm0
    4c84:	cmp    r10d,edx
    4c87:	je     4c1d <bench_ada__run_9.isra.0+0x11d>
    4c89:	lea    r11d,[rdx+0x1]
    4c8d:	cmp    r10d,r11d
    4c90:	je     4c1d <bench_ada__run_9.isra.0+0x11d>
    4c92:	add    edx,0x2
    4c95:	jmp    4c80 <bench_ada__run_9.isra.0+0x180>
    4c97:	mov    rsi,QWORD PTR [rsp-0x30]
    4c9c:	vmovd  xmm9,DWORD PTR [rsp-0xc]
    4ca2:	vmovupd ymm7,YMMWORD PTR [r9]
    4ca7:	vxorpd xmm3,xmm3,xmm3
    4cab:	mov    rax,rsi
    4cae:	shr    rax,0x3
    4cb2:	mov    QWORD PTR [rsp-0x8],rax
    4cb7:	mov    eax,DWORD PTR [rsp-0x14]
    4cbb:	sar    eax,0x2
    4cbe:	lea    r14d,[rax-0x1]
    4cc2:	lea    r12d,[rax-0x4]
    4cc6:	mov    DWORD PTR [rsp-0x10],eax
    4cca:	mov    rax,rdi
    4ccd:	sub    rax,r9
    4cd0:	and    r12d,0xfffffffe
    4cd4:	vmovd  xmm11,r14d
    4cd9:	mov    QWORD PTR [rsp-0x20],rax
    4cde:	lea    rax,[r9+rsi*1]
    4ce2:	lea    r13d,[r12+0x2]
    4ce7:	xor    r12d,r12d
    4cea:	vmovq  xmm8,rax
    4cef:	xor    eax,eax
    4cf1:	nop    DWORD PTR [rax+0x0]
    4cf5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4d00:	mov    r14,QWORD PTR [rsp-0x8]
    4d05:	vmovd  esi,xmm11
    4d09:	imul   r14,rax
    4d0d:	vmulpd ymm0,ymm7,YMMWORD PTR [rdi+r14*8]
    4d13:	test   esi,esi
    4d15:	je     4da8 <bench_ada__run_9.isra.0+0x2a8>
    4d1b:	cmp    DWORD PTR [rsp-0x10],0x3
    4d20:	jle    4e47 <bench_ada__run_9.isra.0+0x347>
    4d26:	mov    rsi,QWORD PTR [rsp-0x20]
    4d2b:	lea    rdx,[r9+0x20]
    4d2f:	lea    r11,[rsi+r14*8]
    4d33:	xor    esi,esi
    4d35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4d40:	vmovupd ymm6,YMMWORD PTR [rdx]
    4d44:	vmulpd ymm4,ymm6,YMMWORD PTR [rdx+r11*1]
    4d4a:	vmovupd ymm2,YMMWORD PTR [rdx+0x20]
    4d4f:	add    esi,0x2
    4d52:	vmulpd ymm2,ymm2,YMMWORD PTR [rdx+r11*1+0x20]
    4d59:	add    rdx,0x40
    4d5d:	vaddpd ymm0,ymm4,ymm0
    4d61:	vaddpd ymm0,ymm2,ymm0
    4d65:	cmp    r13d,esi
    4d68:	jne    4d40 <bench_ada__run_9.isra.0+0x240>
    4d6a:	mov    r11d,esi
    4d6d:	inc    esi
    4d6f:	lea    rdx,[r11+0x1]
    4d73:	lea    r11,[r14+r11*4+0x4]
    4d78:	vmovd  r14d,xmm11
    4d7d:	shl    rdx,0x5
    4d81:	vmovupd ymm2,YMMWORD PTR [r9+rdx*1]
    4d87:	vmulpd ymm2,ymm2,YMMWORD PTR [rdi+r11*8]
    4d8d:	vaddpd ymm0,ymm2,ymm0
    4d91:	cmp    esi,r14d
    4d94:	je     4da8 <bench_ada__run_9.isra.0+0x2a8>
    4d96:	vmovupd ymm2,YMMWORD PTR [rdx+r9*1+0x20]
    4d9d:	vmulpd ymm2,ymm2,YMMWORD PTR [rdi+r11*8+0x20]
    4da4:	vaddpd ymm0,ymm2,ymm0
    4da8:	vextractf64x2 xmm4,ymm0,0x1
    4daf:	vunpckhpd xmm6,xmm0,xmm0
    4db3:	vaddsd xmm2,xmm0,xmm4
    4db7:	valignq ymm0,ymm0,ymm0,0x3
    4dbe:	vaddsd xmm4,xmm6,xmm0
    4dc2:	vaddsd xmm2,xmm2,xmm4
    4dc6:	test   ebx,ebx
    4dc8:	je     4bf0 <bench_ada__run_9.isra.0+0xf0>
    4dce:	imul   rax,QWORD PTR [rsp-0x8]
    4dd4:	vmovq  rsi,xmm9
    4dd9:	add    rax,rsi
    4ddc:	vmovq  rsi,xmm8
    4de1:	vmovsd xmm0,QWORD PTR [rsi-0x8]
    4de6:	vmulsd xmm0,xmm0,QWORD PTR [rdi+rax*8]
    4deb:	cmp    ebx,0x2
    4dee:	je     4e36 <bench_ada__run_9.isra.0+0x336>
    4df0:	cmp    ebx,0x3
    4df3:	jne    4e14 <bench_ada__run_9.isra.0+0x314>
    4df5:	vmovsd xmm4,QWORD PTR [rdi+rax*8-0x10]
    4dfb:	vmulsd xmm4,xmm4,QWORD PTR [rsi-0x18]
    4e00:	vmovsd xmm10,QWORD PTR [rdi+rax*8-0x8]
    4e06:	vmulsd xmm10,xmm10,QWORD PTR [rsi-0x10]
    4e0b:	vaddsd xmm4,xmm4,xmm10
    4e10:	vaddsd xmm0,xmm0,xmm4
    4e14:	vaddsd xmm0,xmm0,xmm2
    4e18:	vmulsd xmm0,xmm0,QWORD PTR [r8+r12*8]
    4e1e:	vaddsd xmm3,xmm3,xmm0
    4e22:	cmp    r12,r15
    4e25:	je     4c03 <bench_ada__run_9.isra.0+0x103>
    4e2b:	inc    r12
    4e2e:	movsxd rax,r12d
    4e31:	jmp    4d00 <bench_ada__run_9.isra.0+0x200>
    4e36:	vmovsd xmm4,QWORD PTR [rdi+rax*8-0x8]
    4e3c:	vmulsd xmm4,xmm4,QWORD PTR [rsi-0x10]
    4e41:	vaddsd xmm0,xmm0,xmm4
    4e45:	jmp    4e14 <bench_ada__run_9.isra.0+0x314>
    4e47:	xor    esi,esi
    4e49:	jmp    4d6a <bench_ada__run_9.isra.0+0x26a>
    4e4e:	xchg   ax,ax


<c_run_1.isra.0>:
    6550:	mov    rax,rsi
    6553:	mov    r10,QWORD PTR [rsp+0x10]
    6558:	mov    rsi,QWORD PTR [rsp+0x8]
    655d:	mov    r11d,edi
    6560:	test   edi,edi
    6562:	je     65cf <c_run_1.isra.0+0x7f>
    6564:	xor    edi,edi
    6566:	cs nop WORD PTR [rax+rax*1+0x0]
    6570:	vmovsd xmm0,QWORD PTR [rax]
    6574:	vmovsd QWORD PTR [rsi],xmm0
    6578:	vmovsd xmm0,QWORD PTR [rax+0x8]
    657d:	vmovsd QWORD PTR [rsi+0x8],xmm0
    6582:	vmovsd xmm0,QWORD PTR [rax+0x10]
    6587:	vmovsd QWORD PTR [rsi+0x10],xmm0
    658c:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6591:	vmovsd QWORD PTR [rsi+0x18],xmm0
    6596:	vmovsd xmm0,QWORD PTR [rax+0x20]
    659b:	vmovsd QWORD PTR [rsi+0x20],xmm0
    65a0:	vmovsd xmm0,QWORD PTR [rax+0x28]
    65a5:	vmovsd QWORD PTR [rsi+0x28],xmm0
    65aa:	vmovsd xmm0,QWORD PTR [rax+0x30]
    65af:	vmovsd QWORD PTR [rsi+0x30],xmm0
    65b4:	vmovsd xmm0,QWORD PTR [rax+0x38]
    65b9:	vmovsd QWORD PTR [rsi+0x38],xmm0
    65be:	vmovsd xmm0,QWORD PTR [rax+0x40]
    65c3:	vmovsd QWORD PTR [rsi+0x40],xmm0
    65c8:	inc    edi
    65ca:	cmp    edi,r11d
    65cd:	jne    6570 <c_run_1.isra.0+0x20>
    65cf:	ret


<c_run_10.isra.0>:
    6c00:	sub    rsp,0x30
    6c04:	mov    QWORD PTR [rsp+0x18],r13
    6c09:	mov    QWORD PTR [rsp+0x20],r14
    6c0e:	mov    QWORD PTR [rsp+0x28],r15
    6c13:	mov    DWORD PTR [rsp-0xc],edx
    6c17:	mov    r15,QWORD PTR [rsp+0x38]
    6c1c:	mov    r13,QWORD PTR [rsp+0x40]
    6c21:	mov    rax,QWORD PTR [rsp+0x48]
    6c26:	mov    r14,QWORD PTR [rsp+0x50]
    6c2b:	test   edx,edx
    6c2d:	je     6ce4 <c_run_10.isra.0+0xe4>
    6c33:	mov    QWORD PTR [rsp],rbx
    6c37:	mov    QWORD PTR [rsp+0x8],rbp
    6c3c:	mov    QWORD PTR [rsp+0x10],r12
    6c41:	mov    r10d,edi
    6c44:	mov    rbx,rcx
    6c47:	mov    rbp,r8
    6c4a:	mov    r12,r9
    6c4d:	test   edi,edi
    6c4f:	je     6cf8 <c_run_10.isra.0+0xf8>
    6c55:	xor    r11d,r11d
    6c58:	test   esi,esi
    6c5a:	je     6d10 <c_run_10.isra.0+0x110>
    6c60:	mov    esi,esi
    6c62:	lea    r9,[rsi*8+0x0]
    6c6a:	mov    esi,edi
    6c6c:	lea    rdx,[rcx+r9*1]
    6c70:	shl    rsi,0x3
    6c74:	mov    QWORD PTR [rsp-0x8],rdx
    6c79:	mov    rdx,rcx
    6c7c:	nop    DWORD PTR [rax+0x0]
    6c80:	mov    rdi,QWORD PTR [rsp-0x8]
    6c85:	mov    DWORD PTR [rsp-0x10],r11d
    6c8a:	mov    rbx,rax
    6c8d:	xor    r8d,r8d
    6c90:	mov    rcx,rdi
    6c93:	sub    rcx,r9
    6c96:	mov    r11,rbx
    6c99:	nop    DWORD PTR [rax+0x0]
    6ca0:	vmovsd xmm0,QWORD PTR [rcx]
    6ca4:	add    rcx,0x8
    6ca8:	vmovsd QWORD PTR [r11],xmm0
    6cad:	add    r11,rsi
    6cb0:	cmp    rcx,rdi
    6cb3:	jne    6ca0 <c_run_10.isra.0+0xa0>
    6cb5:	inc    r8d
    6cb8:	add    rbx,0x8
    6cbc:	lea    rdi,[rcx+r9*1]
    6cc0:	cmp    r10d,r8d
    6cc3:	jne    6c90 <c_run_10.isra.0+0x90>
    6cc5:	mov    r11d,DWORD PTR [rsp-0x10]
    6cca:	inc    r11d
    6ccd:	cmp    DWORD PTR [rsp-0xc],r11d
    6cd2:	je     6cd6 <c_run_10.isra.0+0xd6>
    6cd4:	jmp    6c80 <c_run_10.isra.0+0x80>
    6cd6:	mov    rbx,QWORD PTR [rsp]
    6cda:	mov    rbp,QWORD PTR [rsp+0x8]
    6cdf:	mov    r12,QWORD PTR [rsp+0x10]
    6ce4:	mov    r13,QWORD PTR [rsp+0x18]
    6ce9:	mov    r14,QWORD PTR [rsp+0x20]
    6cee:	mov    r15,QWORD PTR [rsp+0x28]
    6cf3:	add    rsp,0x30
    6cf7:	ret
    6cf8:	mov    edi,DWORD PTR [rsp-0xc]
    6cfc:	lea    edx,[r10+0x1]
    6d00:	cmp    edi,edx
    6d02:	je     6cd6 <c_run_10.isra.0+0xd6>
    6d04:	add    r10d,0x2
    6d08:	cmp    edi,r10d
    6d0b:	je     6cd6 <c_run_10.isra.0+0xd6>
    6d0d:	jmp    6cf8 <c_run_10.isra.0+0xf8>
    6d0f:	nop
    6d10:	mov    edi,DWORD PTR [rsp-0xc]
    6d14:	lea    edx,[r11+0x1]
    6d18:	cmp    edi,edx
    6d1a:	je     6cd6 <c_run_10.isra.0+0xd6>
    6d1c:	add    r11d,0x2
    6d20:	cmp    edi,r11d
    6d23:	je     6cd6 <c_run_10.isra.0+0xd6>
    6d25:	jmp    6d10 <c_run_10.isra.0+0x110>
    6d27:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_11.isra.0>:
    6d30:	sub    rsp,0x50
    6d34:	mov    QWORD PTR [rsp+0x48],r15
    6d39:	mov    DWORD PTR [rsp-0x60],edi
    6d3d:	mov    DWORD PTR [rsp+0xc],esi
    6d41:	mov    r15,QWORD PTR [rsp+0x60]
    6d46:	mov    r11,QWORD PTR [rsp+0x68]
    6d4b:	test   esi,esi
    6d4d:	je     7108 <c_run_11.isra.0+0x3d8>
    6d53:	mov    QWORD PTR [rsp+0x28],rbp
    6d58:	mov    QWORD PTR [rsp+0x38],r13
    6d5d:	mov    rax,QWORD PTR [rsp+0x58]
    6d62:	mov    r10,rdx
    6d65:	mov    r13,rcx
    6d68:	mov    rbp,r8
    6d6b:	mov    esi,edi
    6d6d:	test   edi,edi
    6d6f:	je     711a <c_run_11.isra.0+0x3ea>
    6d75:	lea    eax,[rdi-0x1]
    6d78:	xor    edx,edx
    6d7a:	mov    QWORD PTR [rsp+0x20],rbx
    6d7f:	lea    ecx,[rdi+0x1]
    6d82:	test   eax,eax
    6d84:	vmovsd xmm4,QWORD PTR [rip+0x2cfcc]        # 33d58 <system__os_lib__standin+0xc>
    6d8c:	mov    QWORD PTR [rsp+0x40],r14
    6d91:	mov    QWORD PTR [rsp+0x30],r12
    6d96:	cmovg  eax,edx
    6d99:	mov    rbp,r11
    6d9c:	xor    r12d,r12d
    6d9f:	lea    edx,[rax+0x1]
    6da2:	lea    rax,[rdx*8+0x0]
    6daa:	mov    rdi,rdx
    6dad:	mov    DWORD PTR [rsp+0x8],edx
    6db1:	mov    QWORD PTR [rsp-0x8],rdx
    6db6:	lea    rbx,[r10+rax*1]
    6dba:	add    rax,r15
    6dbd:	mov    QWORD PTR [rsp-0x38],rbx
    6dc2:	mov    ebx,esi
    6dc4:	mov    QWORD PTR [rsp-0x10],rax
    6dc9:	add    rdx,rbx
    6dcc:	mov    QWORD PTR [rsp-0x68],rbx
    6dd1:	vmovddup xmm3,xmm4
    6dd5:	shl    rdx,0x3
    6dd9:	lea    rax,[rdx+r10*1]
    6ddd:	mov    QWORD PTR [rsp-0x18],rax
    6de2:	mov    eax,edi
    6de4:	mov    edi,esi
    6de6:	lea    rsi,[rdx+r15*1]
    6dea:	neg    eax
    6dec:	mov    edx,ecx
    6dee:	mov    QWORD PTR [rsp-0x28],rsi
    6df3:	lea    rsi,[rbx*8+0x0]
    6dfb:	and    edi,eax
    6dfd:	and    eax,ecx
    6dff:	mov    rbx,r9
    6e02:	vmovq  xmm5,rsi
    6e07:	shl    rax,0x3
    6e0b:	lea    rcx,[r10+rax*1]
    6e0f:	add    rax,r15
    6e12:	mov    QWORD PTR [rsp-0x20],rdi
    6e17:	lea    rdi,[rdx*8+0x0]
    6e1f:	mov    QWORD PTR [rsp],rax
    6e23:	lea    rax,[r10+0x8]
    6e27:	mov    QWORD PTR [rsp-0x30],rdi
    6e2c:	vmovq  xmm6,rcx
    6e31:	mov    QWORD PTR [rsp+0x10],rax
    6e36:	mov    r9,r8
    6e39:	nop    DWORD PTR [rax+0x0]
    6e40:	vmovsd xmm0,QWORD PTR [r10]
    6e45:	mov    edi,DWORD PTR [rsp+0x8]
    6e49:	vmovsd QWORD PTR [r15],xmm0
    6e4e:	cmp    DWORD PTR [rsp-0x60],edi
    6e52:	jle    7075 <c_run_11.isra.0+0x345>
    6e58:	mov    rax,QWORD PTR [rsp-0x20]
    6e5d:	mov    rdi,QWORD PTR [rsp-0x28]
    6e62:	mov    rsi,QWORD PTR [rsp-0x18]
    6e67:	mov    rcx,QWORD PTR [rsp-0x38]
    6e6c:	mov    rdx,QWORD PTR [rsp-0x8]
    6e71:	mov    DWORD PTR [rsp-0x5c],r12d
    6e76:	mov    QWORD PTR [rsp-0x58],r13
    6e7b:	mov    QWORD PTR [rsp-0x50],r9
    6e80:	mov    QWORD PTR [rsp-0x48],rbx
    6e85:	mov    QWORD PTR [rsp+0x68],rbp
    6e8a:	xor    r11d,r11d
    6e8d:	mov    QWORD PTR [rsp-0x70],rax
    6e92:	mov    rax,QWORD PTR [rsp-0x10]
    6e97:	vmovq  rbx,xmm6
    6e9c:	lea    r8d,[rdx-0x1]
    6ea0:	mov    DWORD PTR [rsp-0x3c],edx
    6ea4:	vmovsd xmm0,QWORD PTR [rbx+r11*1]
    6eaa:	mov    rbx,QWORD PTR [rsp]
    6eae:	vmovsd QWORD PTR [rbx+r11*1],xmm0
    6eb4:	cmp    r8d,0x20
    6eb8:	jbe    708e <c_run_11.isra.0+0x35e>
    6ebe:	mov    ebx,edx
    6ec0:	mov    r13,QWORD PTR [rsp-0x70]
    6ec5:	lea    r8,[rbx-0x1]
    6ec9:	imul   r8,QWORD PTR [rsp-0x68]
    6ecf:	lea    rbx,[rbx+r13*1-0x1]
    6ed4:	lea    r9,[r13*8+0x0]
    6edc:	shl    rbx,0x3
    6ee0:	add    r8,rdx
    6ee3:	lea    rbp,[r15+r9*1]
    6ee7:	lea    r14,[r10+r9*1]
    6eeb:	shl    r8,0x3
    6eef:	lea    r12,[r10+r8*1]
    6ef3:	cmp    r12,rbp
    6ef6:	lea    r12,[r15+rbx*1]
    6efa:	setb   r13b
    6efe:	cmp    r12,rcx
    6f01:	setb   r12b
    6f05:	or     r13d,r12d
    6f08:	lea    r12,[r10+rbx*1]
    6f0c:	cmp    r12,rax
    6f0f:	mov    BYTE PTR [rsp-0x3e],r13b
    6f14:	lea    r13,[r15+r8*1]
    6f18:	setb   r12b
    6f1c:	cmp    r13,r14
    6f1f:	setb   BYTE PTR [rsp-0x3d]
    6f24:	or     r12b,BYTE PTR [rsp-0x3d]
    6f29:	test   BYTE PTR [rsp-0x3e],r12b
    6f2e:	je     709b <c_run_11.isra.0+0x36b>
    6f34:	lea    r12,[rdx*8+0x0]
    6f3c:	cmp    rbx,r12
    6f3f:	setl   bl
    6f42:	cmp    r8,r9
    6f45:	setl   r8b
    6f49:	or     ebx,r8d
    6f4c:	cmp    QWORD PTR [rsp+0x10],r15
    6f51:	setne  r8b
    6f55:	cmp    rsi,rax
    6f58:	setne  r12b
    6f5c:	and    r8d,r12d
    6f5f:	test   bl,r8b
    6f62:	je     709b <c_run_11.isra.0+0x36b>
    6f68:	cmp    edx,0x1
    6f6b:	je     7112 <c_run_11.isra.0+0x3e2>
    6f71:	mov    r12,QWORD PTR [rsp-0x68]
    6f76:	mov    r13d,edx
    6f79:	shr    r13d,1
    6f7c:	mov    ebx,r13d
    6f7f:	xor    r8d,r8d
    6f82:	xor    r9d,r9d
    6f85:	shl    r12,0x4
    6f89:	shl    rbx,0x4
    6f8d:	nop    DWORD PTR [rax+0x0]
    6f94:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6f9f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6faa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6fb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6fc0:	vmovsd xmm0,QWORD PTR [rcx+r8*1]
    6fc6:	vmovhpd xmm0,xmm0,QWORD PTR [rsi+r8*1]
    6fcc:	vaddpd xmm0,xmm0,XMMWORD PTR [r14+r9*1]
    6fd2:	vmulpd xmm0,xmm0,xmm3
    6fd6:	vmovlpd QWORD PTR [rax+r8*1],xmm0
    6fdc:	vmovhpd QWORD PTR [rdi+r8*1],xmm0
    6fe2:	add    r8,r12
    6fe5:	vmovupd XMMWORD PTR [rbp+r9*1+0x0],xmm0
    6fec:	add    r9,0x10
    6ff0:	cmp    rbx,r9
    6ff3:	jne    6fc0 <c_run_11.isra.0+0x290>
    6ff5:	add    r13d,r13d
    6ff8:	cmp    r13d,DWORD PTR [rsp-0x3c]
    6ffd:	je     7030 <c_run_11.isra.0+0x300>
    6fff:	mov    rbx,QWORD PTR [rsp-0x70]
    7004:	lea    r8d,[r13+rbx*1+0x0]
    7009:	imul   r13d,DWORD PTR [rsp-0x60]
    700f:	vmovsd xmm0,QWORD PTR [r10+r8*8]
    7015:	lea    r9d,[r13+rdx*1+0x0]
    701a:	vaddsd xmm0,xmm0,QWORD PTR [r10+r9*8]
    7020:	vmulsd xmm0,xmm0,xmm4
    7024:	vmovsd QWORD PTR [r15+r9*8],xmm0
    702a:	vmovsd QWORD PTR [r15+r8*8],xmm0
    7030:	mov    r14,QWORD PTR [rsp-0x68]
    7035:	add    r11,QWORD PTR [rsp-0x30]
    703a:	inc    rdx
    703d:	add    rcx,0x8
    7041:	add    QWORD PTR [rsp-0x70],r14
    7046:	add    rax,0x8
    704a:	add    rsi,0x8
    704e:	add    rdi,0x8
    7052:	cmp    DWORD PTR [rsp-0x60],edx
    7056:	jg     6e97 <c_run_11.isra.0+0x167>
    705c:	mov    r12d,DWORD PTR [rsp-0x5c]
    7061:	mov    r13,QWORD PTR [rsp-0x58]
    7066:	mov    r9,QWORD PTR [rsp-0x50]
    706b:	mov    rbx,QWORD PTR [rsp-0x48]
    7070:	mov    rbp,QWORD PTR [rsp+0x68]
    7075:	mov    rax,QWORD PTR [rsp+0x58]
    707a:	inc    r12d
    707d:	cmp    DWORD PTR [rsp+0xc],r12d
    7082:	je     70ef <c_run_11.isra.0+0x3bf>
    7084:	mov    rax,QWORD PTR [rsp+0x58]
    7089:	jmp    6e40 <c_run_11.isra.0+0x110>
    708e:	mov    rbx,QWORD PTR [rsp-0x70]
    7093:	lea    r9,[rbx*8+0x0]
    709b:	lea    r12,[r10+r9*1]
    709f:	xor    ebx,ebx
    70a1:	add    r9,r15
    70a4:	xor    r8d,r8d
    70a7:	vmovq  rbp,xmm5
    70ac:	nop    WORD PTR [rax+rax*1+0x0]
    70b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    70c0:	vmovsd xmm0,QWORD PTR [r12+r8*8]
    70c6:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rbx*1]
    70cb:	vmulsd xmm0,xmm0,xmm4
    70cf:	vmovsd QWORD PTR [rax+rbx*1],xmm0
    70d4:	vmovsd QWORD PTR [r9+r8*8],xmm0
    70da:	inc    r8
    70dd:	add    rbx,rbp
    70e0:	cmp    r8d,edx
    70e3:	jl     70c0 <c_run_11.isra.0+0x390>
    70e5:	vmovq  xmm5,rbp
    70ea:	jmp    7030 <c_run_11.isra.0+0x300>
    70ef:	mov    rbx,QWORD PTR [rsp+0x20]
    70f4:	mov    rbp,QWORD PTR [rsp+0x28]
    70f9:	mov    r12,QWORD PTR [rsp+0x30]
    70fe:	mov    r13,QWORD PTR [rsp+0x38]
    7103:	mov    r14,QWORD PTR [rsp+0x40]
    7108:	mov    r15,QWORD PTR [rsp+0x48]
    710d:	add    rsp,0x50
    7111:	ret
    7112:	xor    r13d,r13d
    7115:	jmp    6fff <c_run_11.isra.0+0x2cf>
    711a:	mov    eax,DWORD PTR [rsp-0x60]
    711e:	mov    rdx,QWORD PTR [rsp+0x58]
    7123:	mov    esi,DWORD PTR [rsp+0xc]
    7127:	lea    ecx,[rax+0x1]
    712a:	cmp    esi,ecx
    712c:	je     7140 <c_run_11.isra.0+0x410>
    712e:	add    eax,0x2
    7131:	cmp    esi,eax
    7133:	je     7140 <c_run_11.isra.0+0x410>
    7135:	mov    esi,DWORD PTR [rsp+0xc]
    7139:	lea    ecx,[rax+0x1]
    713c:	cmp    esi,ecx
    713e:	jne    712e <c_run_11.isra.0+0x3fe>
    7140:	mov    rbp,QWORD PTR [rsp+0x28]
    7145:	mov    r13,QWORD PTR [rsp+0x38]
    714a:	jmp    7108 <c_run_11.isra.0+0x3d8>
    714c:	nop    DWORD PTR [rax+0x0]


<c_run_12.isra.0>:
    9e80:	sub    rsp,0x58
    9e84:	mov    QWORD PTR [rsp+0x28],rbx
    9e89:	mov    QWORD PTR [rsp+0x8],rdx
    9e8e:	mov    ebx,edi
    9e90:	mov    rdi,QWORD PTR [rsp+0x68]
    9e95:	test   esi,esi
    9e97:	je     9f4f <c_run_12.isra.0+0xcf>
    9e9d:	mov    eax,ebx
    9e9f:	mov    DWORD PTR [rsp+0x1c],esi
    9ea3:	mov    QWORD PTR [rsp+0x38],r12
    9ea8:	mov    r12,r8
    9eab:	lea    r8d,[rbx+0x1]
    9eaf:	mov    QWORD PTR [rsp+0x30],rbp
    9eb4:	mov    QWORD PTR [rsp+0x40],r13
    9eb9:	mov    QWORD PTR [rsp+0x48],r14
    9ebe:	mov    QWORD PTR [rsp+0x50],r15
    9ec3:	mov    rbp,rcx
    9ec6:	mov    r13,r9
    9ec9:	lea    r15,[r8*8+0x0]
    9ed1:	imul   eax,ebx
    9ed4:	xor    r14d,r14d
    9ed7:	shl    rax,0x3
    9edb:	mov    QWORD PTR [rsp+0x10],rax
    9ee0:	mov    rax,QWORD PTR [rsp+0x8]
    9ee5:	mov    rcx,QWORD PTR [rsp+0x60]
    9eea:	mov    rsi,QWORD PTR [rsp+0x70]
    9eef:	mov    rdx,QWORD PTR [rsp+0x10]
    9ef4:	xor    esi,esi
    9ef6:	call   2bd0 <memset@plt>
    9efb:	test   ebx,ebx
    9efd:	vmovsd xmm0,QWORD PTR [rip+0x29e83]        # 33d88 <system__os_lib__standin+0x3c>
    9f05:	mov    rdi,rax
    9f08:	je     9f1d <c_run_12.isra.0+0x9d>
    9f0a:	mov    rdx,rax
    9f0d:	xor    eax,eax
    9f0f:	nop
    9f10:	inc    eax
    9f12:	vmovsd QWORD PTR [rdx],xmm0
    9f16:	add    rdx,r15
    9f19:	cmp    ebx,eax
    9f1b:	jne    9f10 <c_run_12.isra.0+0x90>
    9f1d:	mov    rax,QWORD PTR [rsp+0x8]
    9f22:	mov    rcx,QWORD PTR [rsp+0x60]
    9f27:	mov    rsi,QWORD PTR [rsp+0x70]
    9f2c:	inc    r14d
    9f2f:	cmp    r14d,DWORD PTR [rsp+0x1c]
    9f34:	jne    9ee0 <c_run_12.isra.0+0x60>
    9f36:	mov    rbp,QWORD PTR [rsp+0x30]
    9f3b:	mov    r12,QWORD PTR [rsp+0x38]
    9f40:	mov    r13,QWORD PTR [rsp+0x40]
    9f45:	mov    r14,QWORD PTR [rsp+0x48]
    9f4a:	mov    r15,QWORD PTR [rsp+0x50]
    9f4f:	mov    rbx,QWORD PTR [rsp+0x28]
    9f54:	add    rsp,0x58
    9f58:	ret
    9f59:	nop    DWORD PTR [rax+0x0]


<c_run_13.isra.0>:
    ac20:	sub    rsp,0x58
    ac24:	mov    QWORD PTR [rsp+0x48],r14
    ac29:	mov    QWORD PTR [rsp+0x50],r15
    ac2e:	mov    r14,rcx
    ac31:	mov    r10,QWORD PTR [rsp+0x60]
    ac36:	mov    r11,QWORD PTR [rsp+0x68]
    ac3b:	mov    r15,QWORD PTR [rsp+0x70]
    ac40:	mov    rcx,QWORD PTR [rsp+0x78]
    ac45:	test   edx,edx
    ac47:	je     ad1b <c_run_13.isra.0+0xfb>
    ac4d:	mov    eax,edi
    ac4f:	sar    eax,1
    ac51:	je     ad06 <c_run_13.isra.0+0xe6>
    ac57:	mov    QWORD PTR [rsp+0x28],rbx
    ac5c:	mov    DWORD PTR [rsp+0xc],edx
    ac60:	mov    QWORD PTR [rsp+0x10],r8
    ac65:	mov    QWORD PTR [rsp+0x18],r9
    ac6a:	mov    QWORD PTR [rsp+0x60],r10
    ac6f:	mov    QWORD PTR [rsp+0x68],r11
    ac74:	mov    QWORD PTR [rsp+0x30],rbp
    ac79:	mov    ebp,esi
    ac7b:	mov    eax,eax
    ac7d:	mov    QWORD PTR [rsp+0x40],r13
    ac82:	mov    r13,rbp
    ac85:	mov    QWORD PTR [rsp+0x38],r12
    ac8a:	lea    r12,[rcx+rax*4]
    ac8e:	xor    eax,eax
    ac90:	shl    rbp,0x3
    ac94:	nop
    ac95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aca0:	mov    DWORD PTR [rsp+0x8],eax
    aca4:	mov    QWORD PTR [rsp+0x78],rcx
    aca9:	mov    rbx,rcx
    acac:	nop    DWORD PTR [rax+0x0]
    acb0:	mov    esi,DWORD PTR [rbx]
    acb2:	mov    rdx,rbp
    acb5:	add    rbx,0x4
    acb9:	imul   esi,r13d
    acbd:	movsxd rsi,esi
    acc0:	shl    rsi,0x3
    acc4:	lea    rdi,[r15+rsi*1]
    acc8:	add    rsi,r14
    accb:	call   30f0 <memcpy@plt>
    acd0:	cmp    r12,rbx
    acd3:	jne    acb0 <c_run_13.isra.0+0x90>
    acd5:	mov    eax,DWORD PTR [rsp+0x8]
    acd9:	mov    rcx,QWORD PTR [rsp+0x78]
    acde:	mov    rdx,QWORD PTR [rsp+0x10]
    ace3:	mov    rdi,QWORD PTR [rsp+0x18]
    ace8:	mov    rbx,QWORD PTR [rsp+0x60]
    aced:	mov    rsi,QWORD PTR [rsp+0x68]
    acf2:	inc    eax
    acf4:	cmp    DWORD PTR [rsp+0xc],eax
    acf8:	je     ad30 <c_run_13.isra.0+0x110>
    acfa:	mov    rbx,QWORD PTR [rsp+0x60]
    acff:	mov    rsi,QWORD PTR [rsp+0x68]
    ad04:	jmp    aca0 <c_run_13.isra.0+0x80>
    ad06:	lea    esi,[rax+0x1]
    ad09:	cmp    edx,esi
    ad0b:	je     ad1b <c_run_13.isra.0+0xfb>
    ad0d:	add    eax,0x2
    ad10:	cmp    edx,eax
    ad12:	je     ad1b <c_run_13.isra.0+0xfb>
    ad14:	lea    esi,[rax+0x1]
    ad17:	cmp    edx,esi
    ad19:	jne    ad0d <c_run_13.isra.0+0xed>
    ad1b:	mov    r14,QWORD PTR [rsp+0x48]
    ad20:	mov    r15,QWORD PTR [rsp+0x50]
    ad25:	add    rsp,0x58
    ad29:	ret
    ad2a:	nop    WORD PTR [rax+rax*1+0x0]
    ad30:	mov    rbx,QWORD PTR [rsp+0x28]
    ad35:	mov    rbp,QWORD PTR [rsp+0x30]
    ad3a:	mov    r12,QWORD PTR [rsp+0x38]
    ad3f:	mov    r13,QWORD PTR [rsp+0x40]
    ad44:	mov    r14,QWORD PTR [rsp+0x48]
    ad49:	mov    r15,QWORD PTR [rsp+0x50]
    ad4e:	add    rsp,0x58
    ad52:	ret
    ad53:	xchg   ax,ax
    ad55:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_14.isra.0>:
    9f60:	push   rbp
    9f61:	mov    rbp,rsp
    9f64:	push   r15
    9f66:	push   r14
    9f68:	push   r13
    9f6a:	push   r12
    9f6c:	push   rbx
    9f6d:	and    rsp,0xffffffffffffffe0
    9f71:	sub    rsp,0x40
    9f75:	mov    QWORD PTR [rsp+0x18],r8
    9f7a:	test   ecx,ecx
    9f7c:	je     a145 <c_run_14.isra.0+0x1e5>
    9f82:	mov    eax,edi
    9f84:	mov    DWORD PTR [rsp+0x28],edi
    9f88:	mov    DWORD PTR [rsp+0x20],ecx
    9f8c:	mov    DWORD PTR [rsp+0x4],esi
    9f90:	mov    DWORD PTR [rsp+0x24],0x0
    9f98:	mov    r14,QWORD PTR [rbp+0x28]
    9f9c:	mov    r12,r9
    9f9f:	mov    ebx,edx
    9fa1:	imul   eax,edx
    9fa4:	shl    rax,0x3
    9fa8:	mov    QWORD PTR [rsp+0x10],rax
    9fad:	mov    eax,esi
    9faf:	lea    r15,[rax*8+0x0]
    9fb7:	lea    rax,[r8+r15*1]
    9fbb:	mov    QWORD PTR [rsp+0x38],r15
    9fc0:	mov    QWORD PTR [rsp+0x8],rax
    9fc5:	lea    eax,[rdx-0x4]
    9fc8:	and    eax,0xfffffffc
    9fcb:	add    eax,0x4
    9fce:	mov    edi,edx
    9fd0:	sub    edi,eax
    9fd2:	mov    DWORD PTR [rsp+0x30],eax
    9fd6:	mov    DWORD PTR [rsp+0x2c],edi
    9fda:	mov    rax,QWORD PTR [rsp+0x18]
    9fdf:	mov    rdi,QWORD PTR [rbp+0x10]
    9fe3:	mov    rcx,QWORD PTR [rbp+0x18]
    9fe7:	mov    rsi,QWORD PTR [rbp+0x20]
    9feb:	mov    rdx,QWORD PTR [rbp+0x30]
    9fef:	mov    rdx,QWORD PTR [rsp+0x10]
    9ff4:	xor    esi,esi
    9ff6:	mov    rdi,r14
    9ff9:	call   2bd0 <memset@plt>
    9ffe:	mov    edx,DWORD PTR [rsp+0x28]
    a002:	test   edx,edx
    a004:	je     a11e <c_run_14.isra.0+0x1be>
    a00a:	mov    eax,DWORD PTR [rsp+0x4]
    a00e:	mov    rdi,QWORD PTR [rsp+0x8]
    a013:	xor    r11d,r11d
    a016:	xor    r10d,r10d
    a019:	test   eax,eax
    a01b:	je     a11e <c_run_14.isra.0+0x1be>
    a021:	lea    eax,[rbx-0x4]
    a024:	vxorpd xmm3,xmm3,xmm3
    a028:	shr    eax,0x2
    a02b:	inc    eax
    a02d:	shl    rax,0x5
    a031:	nop    DWORD PTR [rax+0x0]
    a035:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a040:	movsxd rdx,r11d
    a043:	mov    DWORD PTR [rsp+0x34],r10d
    a048:	xor    ecx,ecx
    a04a:	lea    r8,[r14+rdx*8]
    a04e:	mov    rdx,rdi
    a051:	sub    rdx,QWORD PTR [rsp+0x38]
    a056:	lea    rsi,[rax+r8*1]
    a05a:	jmp    a06f <c_run_14.isra.0+0x10f>
    a05c:	nop    DWORD PTR [rax+0x0]
    a060:	add    rdx,0x8
    a064:	add    ecx,ebx
    a066:	cmp    rdi,rdx
    a069:	je     a100 <c_run_14.isra.0+0x1a0>
    a06f:	vmovsd xmm1,QWORD PTR [rdx]
    a073:	vcomisd xmm1,xmm3
    a077:	je     a060 <c_run_14.isra.0+0x100>
    a079:	mov    r9d,ecx
    a07c:	lea    r10,[r12+r9*8]
    a080:	cmp    ebx,0x4
    a083:	js     a160 <c_run_14.isra.0+0x200>
    a089:	mov    r15,r10
    a08c:	sub    r15,r8
    a08f:	vbroadcastsd ymm2,xmm1
    a094:	mov    r9,r8
    a097:	nop    WORD PTR [rax+rax*1+0x0]
    a0a0:	vmulpd ymm0,ymm2,YMMWORD PTR [r15+r9*1]
    a0a6:	add    r9,0x20
    a0aa:	vaddpd ymm0,ymm0,YMMWORD PTR [r9-0x20]
    a0b0:	vmovupd YMMWORD PTR [r9-0x20],ymm0
    a0b6:	cmp    rsi,r9
    a0b9:	jne    a0a0 <c_run_14.isra.0+0x140>
    a0bb:	mov    r15d,DWORD PTR [rsp+0x2c]
    a0c0:	mov    r9d,DWORD PTR [rsp+0x30]
    a0c5:	cmp    r15d,0x3
    a0c9:	je     a170 <c_run_14.isra.0+0x210>
    a0cf:	cmp    r15d,0x2
    a0d3:	je     a1c0 <c_run_14.isra.0+0x260>
    a0d9:	cmp    r15d,0x1
    a0dd:	jne    a060 <c_run_14.isra.0+0x100>
    a0df:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*8]
    a0e5:	add    rdx,0x8
    a0e9:	add    ecx,ebx
    a0eb:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*8]
    a0f1:	vmovsd QWORD PTR [r8+r9*8],xmm1
    a0f7:	cmp    rdi,rdx
    a0fa:	jne    a06f <c_run_14.isra.0+0x10f>
    a100:	mov    r10d,DWORD PTR [rsp+0x34]
    a105:	add    rdi,QWORD PTR [rsp+0x38]
    a10a:	add    r11d,ebx
    a10d:	inc    r10d
    a110:	cmp    DWORD PTR [rsp+0x28],r10d
    a115:	jne    a040 <c_run_14.isra.0+0xe0>
    a11b:	vzeroupper
    a11e:	mov    rax,QWORD PTR [rsp+0x18]
    a123:	mov    rdi,QWORD PTR [rbp+0x10]
    a127:	mov    rcx,QWORD PTR [rbp+0x18]
    a12b:	mov    rsi,QWORD PTR [rbp+0x20]
    a12f:	mov    rdx,QWORD PTR [rbp+0x30]
    a133:	inc    DWORD PTR [rsp+0x24]
    a137:	mov    edi,DWORD PTR [rsp+0x20]
    a13b:	cmp    DWORD PTR [rsp+0x24],edi
    a13f:	jne    9fda <c_run_14.isra.0+0x7a>
    a145:	lea    rsp,[rbp-0x28]
    a149:	pop    rbx
    a14a:	pop    r12
    a14c:	pop    r13
    a14e:	pop    r14
    a150:	pop    r15
    a152:	pop    rbp
    a153:	ret
    a154:	nop
    a155:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a160:	mov    r15d,ebx
    a163:	xor    r9d,r9d
    a166:	cmp    r15d,0x3
    a16a:	jne    a0cf <c_run_14.isra.0+0x16f>
    a170:	shl    r9,0x3
    a174:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1]
    a17a:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1]
    a180:	vmovsd QWORD PTR [r8+r9*1],xmm0
    a186:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1+0x8]
    a18d:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1+0x8]
    a194:	vmovsd QWORD PTR [r8+r9*1+0x8],xmm0
    a19b:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*1+0x10]
    a1a2:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*1+0x10]
    a1a9:	vmovsd QWORD PTR [r8+r9*1+0x10],xmm1
    a1b0:	jmp    a060 <c_run_14.isra.0+0x100>
    a1b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a1c0:	shl    r9,0x3
    a1c4:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1]
    a1ca:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1]
    a1d0:	vmovsd QWORD PTR [r8+r9*1],xmm0
    a1d6:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*1+0x8]
    a1dd:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*1+0x8]
    a1e4:	vmovsd QWORD PTR [r8+r9*1+0x8],xmm1
    a1eb:	jmp    a060 <c_run_14.isra.0+0x100>


<c_run_15.isra.0>:
    a1f0:	push   rbp
    a1f1:	mov    rbp,rsp
    a1f4:	push   r15
    a1f6:	push   r14
    a1f8:	push   r13
    a1fa:	push   r12
    a1fc:	push   rbx
    a1fd:	and    rsp,0xffffffffffffffe0
    a201:	sub    rsp,0x40
    a205:	mov    r11,QWORD PTR [rbp+0x28]
    a209:	mov    QWORD PTR [rsp+0x18],r8
    a20e:	test   ecx,ecx
    a210:	je     a3e4 <c_run_15.isra.0+0x1f4>
    a216:	mov    eax,esi
    a218:	mov    DWORD PTR [rsp+0x28],edi
    a21c:	mov    DWORD PTR [rsp+0x20],ecx
    a220:	mov    DWORD PTR [rsp+0x24],0x0
    a228:	mov    DWORD PTR [rsp+0x4],esi
    a22c:	mov    r14,r9
    a22f:	mov    ebx,edx
    a231:	imul   eax,edx
    a234:	shl    rax,0x3
    a238:	mov    QWORD PTR [rsp+0x10],rax
    a23d:	mov    eax,esi
    a23f:	lea    r15,[rax*8+0x0]
    a247:	lea    rax,[r8+r15*1]
    a24b:	mov    QWORD PTR [rsp+0x38],r15
    a250:	mov    QWORD PTR [rsp+0x8],rax
    a255:	lea    eax,[rdx-0x4]
    a258:	and    eax,0xfffffffc
    a25b:	add    eax,0x4
    a25e:	mov    edi,edx
    a260:	sub    edi,eax
    a262:	mov    DWORD PTR [rsp+0x30],eax
    a266:	mov    DWORD PTR [rsp+0x2c],edi
    a26a:	mov    rax,QWORD PTR [rsp+0x18]
    a26f:	mov    rdi,QWORD PTR [rbp+0x10]
    a273:	mov    rdx,QWORD PTR [rbp+0x18]
    a277:	mov    rcx,QWORD PTR [rbp+0x20]
    a27b:	mov    rsi,QWORD PTR [rbp+0x30]
    a27f:	mov    rdx,QWORD PTR [rsp+0x10]
    a284:	mov    rdi,r11
    a287:	xor    esi,esi
    a289:	call   2bd0 <memset@plt>
    a28e:	mov    ecx,DWORD PTR [rsp+0x28]
    a292:	mov    r11,rax
    a295:	test   ecx,ecx
    a297:	je     a3bd <c_run_15.isra.0+0x1cd>
    a29d:	mov    edx,DWORD PTR [rsp+0x4]
    a2a1:	mov    r8,QWORD PTR [rsp+0x8]
    a2a6:	xor    ecx,ecx
    a2a8:	xor    eax,eax
    a2aa:	test   edx,edx
    a2ac:	je     a3bd <c_run_15.isra.0+0x1cd>
    a2b2:	lea    edx,[rbx-0x4]
    a2b5:	vxorpd xmm3,xmm3,xmm3
    a2b9:	mov    rdi,r14
    a2bc:	shr    edx,0x2
    a2bf:	inc    edx
    a2c1:	shl    rdx,0x5
    a2c5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a2d0:	movsxd rsi,ecx
    a2d3:	mov    DWORD PTR [rsp+0x34],eax
    a2d7:	xor    r9d,r9d
    a2da:	lea    r13,[rdi+rsi*8]
    a2de:	mov    rsi,r8
    a2e1:	sub    rsi,QWORD PTR [rsp+0x38]
    a2e6:	lea    r10,[rdx+r13*1]
    a2ea:	jmp    a310 <c_run_15.isra.0+0x120>
    a2ec:	nop    WORD PTR [rax+rax*1+0x0]
    a2f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a300:	add    rsi,0x8
    a304:	add    r9d,ebx
    a307:	cmp    r8,rsi
    a30a:	je     a3a0 <c_run_15.isra.0+0x1b0>
    a310:	vmovsd xmm1,QWORD PTR [rsi]
    a314:	vcomisd xmm1,xmm3
    a318:	je     a300 <c_run_15.isra.0+0x110>
    a31a:	mov    eax,r9d
    a31d:	lea    r15,[r11+rax*8]
    a321:	cmp    ebx,0x4
    a324:	js     a400 <c_run_15.isra.0+0x210>
    a32a:	mov    r14,r15
    a32d:	sub    r14,r13
    a330:	vbroadcastsd ymm2,xmm1
    a335:	mov    rax,r13
    a338:	nop    DWORD PTR [rax+rax*1+0x0]
    a340:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    a344:	vaddpd ymm0,ymm0,YMMWORD PTR [r14+rax*1]
    a34a:	vmovupd YMMWORD PTR [r14+rax*1],ymm0
    a350:	add    rax,0x20
    a354:	cmp    r10,rax
    a357:	jne    a340 <c_run_15.isra.0+0x150>
    a359:	mov    r14d,DWORD PTR [rsp+0x2c]
    a35e:	mov    eax,DWORD PTR [rsp+0x30]
    a362:	cmp    r14d,0x3
    a366:	je     a40f <c_run_15.isra.0+0x21f>
    a36c:	cmp    r14d,0x2
    a370:	je     a460 <c_run_15.isra.0+0x270>
    a376:	cmp    r14d,0x1
    a37a:	jne    a300 <c_run_15.isra.0+0x110>
    a37c:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*8+0x0]
    a383:	add    rsi,0x8
    a387:	add    r9d,ebx
    a38a:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*8]
    a390:	vmovsd QWORD PTR [r15+rax*8],xmm1
    a396:	cmp    r8,rsi
    a399:	jne    a310 <c_run_15.isra.0+0x120>
    a39f:	nop
    a3a0:	mov    eax,DWORD PTR [rsp+0x34]
    a3a4:	add    r8,QWORD PTR [rsp+0x38]
    a3a9:	add    ecx,ebx
    a3ab:	inc    eax
    a3ad:	cmp    DWORD PTR [rsp+0x28],eax
    a3b1:	jne    a2d0 <c_run_15.isra.0+0xe0>
    a3b7:	mov    r14,rdi
    a3ba:	vzeroupper
    a3bd:	mov    rax,QWORD PTR [rsp+0x18]
    a3c2:	mov    rdi,QWORD PTR [rbp+0x10]
    a3c6:	mov    rdx,QWORD PTR [rbp+0x18]
    a3ca:	mov    rcx,QWORD PTR [rbp+0x20]
    a3ce:	mov    rsi,QWORD PTR [rbp+0x30]
    a3d2:	inc    DWORD PTR [rsp+0x24]
    a3d6:	mov    edi,DWORD PTR [rsp+0x20]
    a3da:	cmp    DWORD PTR [rsp+0x24],edi
    a3de:	jne    a26a <c_run_15.isra.0+0x7a>
    a3e4:	lea    rsp,[rbp-0x28]
    a3e8:	pop    rbx
    a3e9:	pop    r12
    a3eb:	pop    r13
    a3ed:	pop    r14
    a3ef:	pop    r15
    a3f1:	pop    rbp
    a3f2:	ret
    a3f3:	xchg   ax,ax
    a3f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a400:	mov    r14d,ebx
    a403:	xor    eax,eax
    a405:	cmp    r14d,0x3
    a409:	jne    a36c <c_run_15.isra.0+0x17c>
    a40f:	shl    rax,0x3
    a413:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x0]
    a41a:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    a420:	vmovsd QWORD PTR [r15+rax*1],xmm0
    a426:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x8]
    a42d:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1+0x8]
    a434:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm0
    a43b:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*1+0x10]
    a442:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x10]
    a449:	vmovsd QWORD PTR [r15+rax*1+0x10],xmm1
    a450:	jmp    a300 <c_run_15.isra.0+0x110>
    a455:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a460:	shl    rax,0x3
    a464:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x0]
    a46b:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    a471:	vmovsd QWORD PTR [r15+rax*1],xmm0
    a477:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*1+0x8]
    a47e:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x8]
    a485:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm1
    a48c:	jmp    a300 <c_run_15.isra.0+0x110>
    a491:	nop    DWORD PTR [rax+0x0]
    a495:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_16.isra.0>:
    a980:	push   rbp
    a981:	mov    rbp,rsp
    a984:	push   r15
    a986:	push   r14
    a988:	push   r13
    a98a:	push   r12
    a98c:	push   rbx
    a98d:	and    rsp,0xffffffffffffffe0
    a991:	mov    rax,QWORD PTR [rbp+0x28]
    a995:	mov    DWORD PTR [rsp-0xc],ecx
    a999:	test   ecx,ecx
    a99b:	je     aa03 <c_run_16.isra.0+0x83>
    a99d:	mov    r15d,edi
    a9a0:	mov    ebx,esi
    a9a2:	mov    rdi,r8
    a9a5:	mov    rcx,QWORD PTR [rbp+0x10]
    a9a9:	mov    rsi,QWORD PTR [rbp+0x18]
    a9ad:	mov    r11,QWORD PTR [rbp+0x20]
    a9b1:	mov    r8,QWORD PTR [rbp+0x30]
    a9b5:	mov    r14,r9
    a9b8:	test   r15d,r15d
    a9bb:	je     abe3 <c_run_16.isra.0+0x263>
    a9c1:	mov    DWORD PTR [rsp-0x8],0x0
    a9c9:	test   edx,edx
    a9cb:	jne    aa12 <c_run_16.isra.0+0x92>
    a9cd:	mov    rcx,QWORD PTR [rbp+0x10]
    a9d1:	mov    rsi,QWORD PTR [rbp+0x18]
    a9d5:	mov    r8,QWORD PTR [rbp+0x20]
    a9d9:	mov    r9,QWORD PTR [rbp+0x30]
    a9dd:	xor    edx,edx
    a9df:	mov    ebx,DWORD PTR [rsp-0xc]
    a9e3:	lea    r10d,[rdx+0x1]
    a9e7:	cmp    ebx,r10d
    a9ea:	je     aa03 <c_run_16.isra.0+0x83>
    a9ec:	add    edx,0x2
    a9ef:	cmp    ebx,edx
    a9f1:	je     aa03 <c_run_16.isra.0+0x83>
    a9f3:	jmp    a9df <c_run_16.isra.0+0x5f>
    a9f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aa00:	vzeroupper
    aa03:	lea    rsp,[rbp-0x28]
    aa07:	pop    rbx
    aa08:	pop    r12
    aa0a:	pop    r13
    aa0c:	pop    r14
    aa0e:	pop    r15
    aa10:	pop    rbp
    aa11:	ret
    aa12:	mov    edx,edx
    aa14:	lea    r11d,[rbx-0x8]
    aa18:	lea    ecx,[rbx-0x4]
    aa1b:	mov    r10d,ebx
    aa1e:	lea    r13,[rdx*8+0x0]
    aa26:	and    r11d,0xfffffffc
    aa2a:	lea    rdx,[rax+r13*1]
    aa2e:	add    r11d,0x8
    aa32:	mov    QWORD PTR [rsp-0x20],rdx
    aa37:	mov    edx,0x4
    aa3c:	shl    r10,0x3
    aa40:	cmp    ecx,0x3
    aa43:	cmovle r11d,edx
    aa47:	mov    r12d,ebx
    aa4a:	sub    r12d,r11d
    aa4d:	mov    r9,QWORD PTR [rsp-0x20]
    aa52:	mov    QWORD PTR [rsp-0x18],rdi
    aa57:	mov    QWORD PTR [rbp+0x28],rax
    aa5b:	mov    rdx,rdi
    aa5e:	xor    r8d,r8d
    aa61:	nop    DWORD PTR [rax+0x0]
    aa65:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aa70:	mov    DWORD PTR [rsp-0x4],r8d
    aa75:	mov    rdi,r9
    aa78:	sub    rdi,r13
    aa7b:	mov    rax,r14
    aa7e:	xchg   ax,ax
    aa80:	test   ecx,ecx
    aa82:	js     ab70 <c_run_16.isra.0+0x1f0>
    aa88:	vmovupd ymm1,YMMWORD PTR [rdx]
    aa8c:	vmulpd ymm1,ymm1,YMMWORD PTR [rax]
    aa90:	cmp    ecx,0x3
    aa93:	jle    aab6 <c_run_16.isra.0+0x136>
    aa95:	mov    esi,0x4
    aa9a:	nop    WORD PTR [rax+rax*1+0x0]
    aaa0:	vmovupd ymm0,YMMWORD PTR [rdx+rsi*8]
    aaa5:	vmulpd ymm0,ymm0,YMMWORD PTR [rax+rsi*8]
    aaaa:	add    rsi,0x4
    aaae:	vaddpd ymm1,ymm1,ymm0
    aab2:	cmp    ecx,esi
    aab4:	jge    aaa0 <c_run_16.isra.0+0x120>
    aab6:	vmovapd xmm0,xmm1
    aaba:	vextractf64x2 xmm1,ymm1,0x1
    aac1:	mov    r8d,r12d
    aac4:	mov    esi,r11d
    aac7:	vaddpd xmm0,xmm0,xmm1
    aacb:	vunpckhpd xmm1,xmm0,xmm0
    aacf:	vaddsd xmm0,xmm0,xmm1
    aad3:	cmp    r8d,0x3
    aad7:	je     ab83 <c_run_16.isra.0+0x203>
    aadd:	cmp    r8d,0x2
    aae1:	je     abc0 <c_run_16.isra.0+0x240>
    aae7:	cmp    r8d,0x1
    aaeb:	jne    ab00 <c_run_16.isra.0+0x180>
    aaed:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    aaf2:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    aaf7:	vaddsd xmm0,xmm0,xmm1
    aafb:	nop    DWORD PTR [rax+rax*1+0x0]
    ab00:	vmovsd QWORD PTR [rdi],xmm0
    ab04:	add    rdi,0x8
    ab08:	add    rax,r10
    ab0b:	cmp    r9,rdi
    ab0e:	jne    aa80 <c_run_16.isra.0+0x100>
    ab14:	mov    r8d,DWORD PTR [rsp-0x4]
    ab19:	add    r9,r13
    ab1c:	add    rdx,r10
    ab1f:	inc    r8d
    ab22:	cmp    r15d,r8d
    ab25:	jne    aa70 <c_run_16.isra.0+0xf0>
    ab2b:	mov    rdi,QWORD PTR [rsp-0x18]
    ab30:	mov    rax,QWORD PTR [rbp+0x28]
    ab34:	mov    rdx,QWORD PTR [rbp+0x10]
    ab38:	mov    rsi,QWORD PTR [rbp+0x18]
    ab3c:	mov    r8,QWORD PTR [rbp+0x20]
    ab40:	mov    r9,QWORD PTR [rbp+0x30]
    ab44:	inc    DWORD PTR [rsp-0x8]
    ab48:	mov    edx,DWORD PTR [rsp-0x8]
    ab4c:	cmp    DWORD PTR [rsp-0xc],edx
    ab50:	je     aa00 <c_run_16.isra.0+0x80>
    ab56:	mov    rdx,QWORD PTR [rbp+0x10]
    ab5a:	mov    rsi,QWORD PTR [rbp+0x18]
    ab5e:	mov    r8,QWORD PTR [rbp+0x20]
    ab62:	mov    r9,QWORD PTR [rbp+0x30]
    ab66:	jmp    aa4d <c_run_16.isra.0+0xcd>
    ab6b:	nop    DWORD PTR [rax+rax*1+0x0]
    ab70:	mov    r8d,ebx
    ab73:	xor    esi,esi
    ab75:	vxorpd xmm0,xmm0,xmm0
    ab79:	cmp    r8d,0x3
    ab7d:	jne    aadd <c_run_16.isra.0+0x15d>
    ab83:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    ab88:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    ab8d:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x8]
    ab93:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x8]
    ab99:	vaddsd xmm1,xmm1,xmm2
    ab9d:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x10]
    aba3:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x10]
    aba9:	vaddsd xmm1,xmm1,xmm2
    abad:	vaddsd xmm0,xmm0,xmm1
    abb1:	jmp    ab00 <c_run_16.isra.0+0x180>
    abb6:	cs nop WORD PTR [rax+rax*1+0x0]
    abc0:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    abc5:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    abca:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x8]
    abd0:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x8]
    abd6:	vaddsd xmm1,xmm1,xmm2
    abda:	vaddsd xmm0,xmm0,xmm1
    abde:	jmp    ab00 <c_run_16.isra.0+0x180>
    abe3:	mov    rdx,QWORD PTR [rbp+0x10]
    abe7:	mov    rcx,QWORD PTR [rbp+0x18]
    abeb:	mov    rsi,QWORD PTR [rbp+0x20]
    abef:	mov    r8,QWORD PTR [rbp+0x30]
    abf3:	mov    ebx,DWORD PTR [rsp-0xc]
    abf7:	lea    r9d,[r15+0x1]
    abfb:	cmp    ebx,r9d
    abfe:	je     aa03 <c_run_16.isra.0+0x83>
    ac04:	add    r15d,0x2
    ac08:	cmp    ebx,r15d
    ac0b:	je     aa03 <c_run_16.isra.0+0x83>
    ac11:	jmp    abf3 <c_run_16.isra.0+0x273>
    ac13:	xchg   ax,ax
    ac15:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_17.isra.0>:
    ad60:	push   rbp
    ad61:	mov    rbp,rsp
    ad64:	push   r15
    ad66:	push   r14
    ad68:	push   r13
    ad6a:	push   r12
    ad6c:	push   rbx
    ad6d:	and    rsp,0xffffffffffffffe0
    ad71:	sub    rsp,0x60
    ad75:	mov    QWORD PTR [rsp+0x48],rcx
    ad7a:	mov    QWORD PTR [rsp+0x30],r8
    ad7f:	mov    QWORD PTR [rsp+0x28],r9
    ad84:	test   edx,edx
    ad86:	je     b0c5 <c_run_17.isra.0+0x365>
    ad8c:	mov    eax,esi
    ad8e:	mov    r13d,esi
    ad91:	mov    DWORD PTR [rsp+0x20],edx
    ad95:	mov    DWORD PTR [rsp+0x44],esi
    ad99:	lea    rbx,[r13*8+0x0]
    ada1:	mov    DWORD PTR [rsp+0x40],0x0
    ada9:	mov    r15d,edi
    adac:	imul   eax,esi
    adaf:	mov    QWORD PTR [rsp+0x38],rbx
    adb4:	shl    rax,0x3
    adb8:	mov    QWORD PTR [rsp+0x18],rax
    adbd:	mov    rax,r13
    adc0:	shl    rax,0x4
    adc4:	mov    QWORD PTR [rsp+0x10],rax
    adc9:	mov    rax,QWORD PTR [rsp+0x48]
    adce:	mov    rdi,QWORD PTR [rsp+0x30]
    add3:	mov    rsi,QWORD PTR [rsp+0x28]
    add8:	mov    rbx,QWORD PTR [rbp+0x10]
    addc:	mov    rdx,QWORD PTR [rbp+0x18]
    ade0:	mov    rcx,QWORD PTR [rbp+0x20]
    ade4:	mov    r14,QWORD PTR [rbp+0x28]
    ade8:	mov    rdx,QWORD PTR [rsp+0x18]
    aded:	mov    rdi,QWORD PTR [rbp+0x20]
    adf1:	xor    esi,esi
    adf3:	call   2bd0 <memset@plt>
    adf8:	mov    eax,DWORD PTR [rsp+0x44]
    adfc:	vxorpd xmm3,xmm3,xmm3
    ae00:	test   eax,eax
    ae02:	je     b094 <c_run_17.isra.0+0x334>
    ae08:	test   r15d,r15d
    ae0b:	je     af43 <c_run_17.isra.0+0x1e3>
    ae11:	mov    QWORD PTR [rsp+0x50],r13
    ae16:	mov    r10d,0xfffffffd
    ae1c:	xor    r9d,r9d
    ae1f:	xor    r8d,r8d
    ae22:	xor    r12d,r12d
    ae25:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ae30:	mov    rdi,QWORD PTR [rbp+0x20]
    ae34:	movsxd rax,r9d
    ae37:	mov    ecx,r10d
    ae3a:	mov    r13d,r10d
    ae3d:	and    r13d,0xfffffffc
    ae41:	inc    r12d
    ae44:	mov    DWORD PTR [rsp+0x5c],r9d
    ae49:	xor    edx,edx
    ae4b:	add    r13d,0x4
    ae4f:	mov    r9,QWORD PTR [rsp+0x38]
    ae54:	mov    r14d,r12d
    ae57:	sub    r14d,r13d
    ae5a:	shr    ecx,0x2
    ae5d:	lea    rsi,[rdi+rax*8]
    ae61:	mov    rax,QWORD PTR [rsp+0x48]
    ae66:	shl    rcx,0x5
    ae6a:	lea    rdi,[rsi+rcx*1+0x20]
    ae6f:	sub    rax,rsi
    ae72:	jmp    ae8e <c_run_17.isra.0+0x12e>
    ae74:	nop
    ae75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ae80:	inc    edx
    ae82:	add    rax,r9
    ae85:	cmp    r15d,edx
    ae88:	je     af20 <c_run_17.isra.0+0x1c0>
    ae8e:	lea    r11,[rsi+rax*1]
    ae92:	vmovsd xmm1,QWORD PTR [r11+r8*8]
    ae98:	vcomisd xmm1,xmm3
    ae9c:	je     ae80 <c_run_17.isra.0+0x120>
    ae9e:	test   r10d,r10d
    aea1:	js     b0e0 <c_run_17.isra.0+0x380>
    aea7:	vbroadcastsd ymm2,xmm1
    aeac:	mov    rcx,rsi
    aeaf:	nop    WORD PTR [rax+rax*1+0x0]
    aeb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aec0:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
    aec5:	add    rcx,0x20
    aec9:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    aece:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
    aed3:	cmp    rdi,rcx
    aed6:	jne    aec0 <c_run_17.isra.0+0x160>
    aed8:	mov    ebx,r14d
    aedb:	mov    ecx,r13d
    aede:	cmp    ebx,0x3
    aee1:	je     b0ee <c_run_17.isra.0+0x38e>
    aee7:	cmp    ebx,0x2
    aeea:	je     b130 <c_run_17.isra.0+0x3d0>
    aef0:	cmp    ebx,0x1
    aef3:	jne    ae80 <c_run_17.isra.0+0x120>
    aef5:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*8]
    aefb:	inc    edx
    aefd:	add    rax,r9
    af00:	vaddsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    af05:	vmovsd QWORD PTR [rsi+rcx*8],xmm1
    af0a:	cmp    r15d,edx
    af0d:	jne    ae8e <c_run_17.isra.0+0x12e>
    af13:	xchg   ax,ax
    af15:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    af20:	mov    r9d,DWORD PTR [rsp+0x5c]
    af25:	mov    eax,DWORD PTR [rsp+0x44]
    af29:	inc    r8
    af2c:	inc    r10d
    af2f:	add    r9d,eax
    af32:	cmp    eax,r12d
    af35:	jne    ae30 <c_run_17.isra.0+0xd0>
    af3b:	mov    r13,QWORD PTR [rsp+0x50]
    af40:	vzeroupper
    af43:	mov    r14d,DWORD PTR [rsp+0x44]
    af48:	cmp    r14d,0x1
    af4c:	je     b094 <c_run_17.isra.0+0x334>
    af52:	mov    rax,QWORD PTR [rbp+0x20]
    af56:	mov    DWORD PTR [rsp+0x24],r15d
    af5b:	mov    DWORD PTR [rsp+0x50],0x0
    af63:	mov    rcx,QWORD PTR [rsp+0x10]
    af68:	mov    r15,QWORD PTR [rsp+0x38]
    af6d:	lea    r11d,[r14-0x1]
    af71:	mov    r9d,0x8
    af77:	mov    esi,0x1
    af7c:	xor    r12d,r12d
    af7f:	lea    r8,[rax+0x8]
    af83:	mov    rdi,rax
    af86:	cs nop WORD PTR [rax+rax*1+0x0]
    af90:	mov    DWORD PTR [rsp+0x5c],r11d
    af95:	dec    r11d
    af98:	mov    eax,DWORD PTR [rsp+0x50]
    af9c:	cmp    r11d,0xe
    afa0:	jbe    b15c <c_run_17.isra.0+0x3fc>
    afa6:	cmp    r14d,esi
    afa9:	jle    b15c <c_run_17.isra.0+0x3fc>
    afaf:	lea    r10d,[rax+r14*1]
    afb3:	mov    eax,DWORD PTR [rsp+0x5c]
    afb7:	mov    DWORD PTR [rsp+0x58],r10d
    afbc:	add    r10,r12
    afbf:	lea    rbx,[rax-0x1]
    afc3:	lea    rax,[r10*8+0x0]
    afcb:	mov    rdx,rbx
    afce:	imul   rdx,r13
    afd2:	add    rdx,r10
    afd5:	shl    rdx,0x3
    afd9:	cmp    rdx,r9
    afdc:	jl     afeb <c_run_17.isra.0+0x28b>
    afde:	lea    rdx,[r9+rbx*8]
    afe2:	cmp    rax,rdx
    afe5:	jle    b163 <c_run_17.isra.0+0x403>
    afeb:	mov    r10d,DWORD PTR [rsp+0x5c]
    aff0:	add    rax,QWORD PTR [rbp+0x20]
    aff4:	shr    r10d,1
    aff7:	mov    edx,r10d
    affa:	shl    rdx,0x4
    affe:	lea    rbx,[rdx+r8*1]
    b002:	mov    rdx,r8
    b005:	nop    DWORD PTR [rax+rax*1+0x0]
    b00a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b015:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b020:	vmovsd xmm0,QWORD PTR [rax]
    b024:	vmovhpd xmm0,xmm0,QWORD PTR [rax+r13*8]
    b02a:	add    rdx,0x10
    b02e:	add    rax,rcx
    b031:	vmovupd XMMWORD PTR [rdx-0x10],xmm0
    b036:	cmp    rbx,rdx
    b039:	jne    b020 <c_run_17.isra.0+0x2c0>
    b03b:	add    r10d,r10d
    b03e:	cmp    r10d,DWORD PTR [rsp+0x5c]
    b043:	je     b06b <c_run_17.isra.0+0x30b>
    b045:	add    r10d,esi
    b048:	mov    eax,r14d
    b04b:	mov    rbx,QWORD PTR [rbp+0x20]
    b04f:	imul   eax,r10d
    b053:	add    eax,r12d
    b056:	mov    eax,eax
    b058:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    b05d:	mov    eax,DWORD PTR [rsp+0x50]
    b061:	add    eax,r10d
    b064:	mov    eax,eax
    b066:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    b06b:	mov    eax,DWORD PTR [rsp+0x58]
    b06f:	inc    rsi
    b072:	inc    r12
    b075:	add    rdi,r15
    b078:	lea    r9,[r15+r9*1+0x8]
    b07d:	lea    r8,[r15+r8*1+0x8]
    b082:	mov    DWORD PTR [rsp+0x50],eax
    b086:	cmp    r13,rsi
    b089:	jne    af90 <c_run_17.isra.0+0x230>
    b08f:	mov    r15d,DWORD PTR [rsp+0x24]
    b094:	mov    rax,QWORD PTR [rsp+0x48]
    b099:	mov    rdi,QWORD PTR [rsp+0x30]
    b09e:	mov    rsi,QWORD PTR [rsp+0x28]
    b0a3:	mov    rbx,QWORD PTR [rbp+0x10]
    b0a7:	mov    rdx,QWORD PTR [rbp+0x18]
    b0ab:	mov    rcx,QWORD PTR [rbp+0x20]
    b0af:	mov    r14,QWORD PTR [rbp+0x28]
    b0b3:	inc    DWORD PTR [rsp+0x40]
    b0b7:	mov    edi,DWORD PTR [rsp+0x20]
    b0bb:	cmp    DWORD PTR [rsp+0x40],edi
    b0bf:	jne    adc9 <c_run_17.isra.0+0x69>
    b0c5:	lea    rsp,[rbp-0x28]
    b0c9:	pop    rbx
    b0ca:	pop    r12
    b0cc:	pop    r13
    b0ce:	pop    r14
    b0d0:	pop    r15
    b0d2:	pop    rbp
    b0d3:	ret
    b0d4:	nop
    b0d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b0e0:	mov    ebx,r12d
    b0e3:	xor    ecx,ecx
    b0e5:	cmp    ebx,0x3
    b0e8:	jne    aee7 <c_run_17.isra.0+0x187>
    b0ee:	shl    rcx,0x3
    b0f2:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    b0f8:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    b0fd:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    b102:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1+0x8]
    b109:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rsi*1+0x8]
    b10f:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm0
    b115:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x10]
    b11c:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x10]
    b122:	vmovsd QWORD PTR [rcx+rsi*1+0x10],xmm1
    b128:	jmp    ae80 <c_run_17.isra.0+0x120>
    b12d:	nop    DWORD PTR [rax]
    b130:	shl    rcx,0x3
    b134:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    b13a:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    b13f:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    b144:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x8]
    b14b:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x8]
    b151:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm1
    b157:	jmp    ae80 <c_run_17.isra.0+0x120>
    b15c:	add    eax,r14d
    b15f:	mov    DWORD PTR [rsp+0x58],eax
    b163:	mov    eax,DWORD PTR [rsp+0x58]
    b167:	mov    rbx,QWORD PTR [rbp+0x20]
    b16b:	add    rax,r12
    b16e:	lea    rdx,[rbx+rax*8]
    b172:	mov    rax,rsi
    b175:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b180:	vmovsd xmm0,QWORD PTR [rdx]
    b184:	add    rdx,r15
    b187:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    b18c:	inc    rax
    b18f:	cmp    r14d,eax
    b192:	jg     b180 <c_run_17.isra.0+0x420>
    b194:	jmp    b06b <c_run_17.isra.0+0x30b>
    b199:	nop    DWORD PTR [rax+0x0]


<c_run_18.isra.0>:
    b1a0:	push   rbp
    b1a1:	mov    rbp,rsp
    b1a4:	push   r15
    b1a6:	push   r14
    b1a8:	push   r13
    b1aa:	push   r12
    b1ac:	push   rbx
    b1ad:	mov    r15,rcx
    b1b0:	and    rsp,0xffffffffffffffe0
    b1b4:	sub    rsp,0x60
    b1b8:	mov    rcx,QWORD PTR [rbp+0x18]
    b1bc:	mov    QWORD PTR [rsp+0x40],r8
    b1c1:	mov    QWORD PTR [rsp+0x38],r9
    b1c6:	test   edx,edx
    b1c8:	je     b53a <c_run_18.isra.0+0x39a>
    b1ce:	mov    ebx,esi
    b1d0:	mov    DWORD PTR [rsp+0x24],edx
    b1d4:	mov    DWORD PTR [rsp+0x48],edi
    b1d8:	mov    DWORD PTR [rsp+0x4c],0x0
    b1e0:	mov    eax,ebx
    b1e2:	mov    r14,rbx
    b1e5:	shl    r14,0x4
    b1e9:	imul   eax,ebx
    b1ec:	mov    QWORD PTR [rsp+0x8],r14
    b1f1:	mov    r13,rbx
    b1f4:	shl    rax,0x3
    b1f8:	mov    QWORD PTR [rsp+0x28],rax
    b1fd:	mov    eax,edi
    b1ff:	lea    rax,[rcx+rax*8]
    b203:	mov    QWORD PTR [rsp+0x18],rax
    b208:	lea    rax,[rbx*8+0x0]
    b210:	mov    QWORD PTR [rsp+0x10],rax
    b215:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b220:	mov    rax,QWORD PTR [rsp+0x40]
    b225:	mov    rdi,QWORD PTR [rsp+0x38]
    b22a:	mov    rsi,QWORD PTR [rbp+0x10]
    b22e:	mov    rdx,QWORD PTR [rbp+0x20]
    b232:	mov    r8,QWORD PTR [rbp+0x28]
    b236:	mov    rdx,QWORD PTR [rsp+0x28]
    b23b:	mov    rdi,QWORD PTR [rbp+0x20]
    b23f:	xor    esi,esi
    b241:	mov    QWORD PTR [rbp+0x18],rcx
    b245:	call   2bd0 <memset@plt>
    b24a:	mov    eax,DWORD PTR [rsp+0x48]
    b24e:	mov    rcx,QWORD PTR [rbp+0x18]
    b252:	vxorpd xmm3,xmm3,xmm3
    b256:	test   eax,eax
    b258:	je     b3b6 <c_run_18.isra.0+0x216>
    b25e:	mov    r11,QWORD PTR [rsp+0x18]
    b263:	mov    r9,rcx
    b266:	xor    eax,eax
    b268:	mov    rdx,rcx
    b26b:	jmp    b290 <c_run_18.isra.0+0xf0>
    b26d:	nop    DWORD PTR [rax+rax*1+0x0]
    b275:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b280:	add    r9,0x8
    b284:	add    eax,r13d
    b287:	cmp    r11,r9
    b28a:	je     b3b0 <c_run_18.isra.0+0x210>
    b290:	vcomisd xmm3,QWORD PTR [r9]
    b295:	je     b280 <c_run_18.isra.0+0xe0>
    b297:	test   r13d,r13d
    b29a:	je     b549 <c_run_18.isra.0+0x3a9>
    b2a0:	mov    ecx,eax
    b2a2:	mov    QWORD PTR [rsp+0x58],r11
    b2a7:	mov    DWORD PTR [rsp+0x54],eax
    b2ab:	mov    edi,0xfffffffd
    b2b0:	lea    r10,[r15+rcx*8]
    b2b4:	xor    r8d,r8d
    b2b7:	mov    ecx,0x1
    b2bc:	jmp    b2d1 <c_run_18.isra.0+0x131>
    b2be:	xchg   ax,ax
    b2c0:	add    r8d,r13d
    b2c3:	inc    edi
    b2c5:	cmp    rcx,rbx
    b2c8:	je     b380 <c_run_18.isra.0+0x1e0>
    b2ce:	inc    rcx
    b2d1:	vmovsd xmm0,QWORD PTR [r10+rcx*8-0x8]
    b2d8:	vcomisd xmm0,xmm3
    b2dc:	je     b2c0 <c_run_18.isra.0+0x120>
    b2de:	mov    rsi,QWORD PTR [rbp+0x20]
    b2e2:	mov    eax,r8d
    b2e5:	vmulsd xmm1,xmm0,QWORD PTR [r9]
    b2ea:	mov    r12d,ecx
    b2ed:	lea    r14,[rsi+rax*8]
    b2f1:	xor    eax,eax
    b2f3:	test   edi,edi
    b2f5:	js     b342 <c_run_18.isra.0+0x1a2>
    b2f7:	mov    eax,edi
    b2f9:	mov    rsi,r14
    b2fc:	sub    rsi,r10
    b2ff:	vbroadcastsd ymm2,xmm1
    b304:	shr    eax,0x2
    b307:	shl    rax,0x5
    b30b:	lea    r11,[r10+rax*1+0x20]
    b310:	mov    rax,r10
    b313:	xchg   ax,ax
    b315:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b320:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    b324:	vaddpd ymm0,ymm0,YMMWORD PTR [rsi+rax*1]
    b329:	vmovupd YMMWORD PTR [rsi+rax*1],ymm0
    b32e:	add    rax,0x20
    b332:	cmp    r11,rax
    b335:	jne    b320 <c_run_18.isra.0+0x180>
    b337:	mov    eax,edi
    b339:	and    eax,0xfffffffc
    b33c:	add    eax,0x4
    b33f:	sub    r12d,eax
    b342:	cmp    r12d,0x3
    b346:	je     b570 <c_run_18.isra.0+0x3d0>
    b34c:	cmp    r12d,0x2
    b350:	je     b5c0 <c_run_18.isra.0+0x420>
    b356:	cmp    r12d,0x1
    b35a:	jne    b2c0 <c_run_18.isra.0+0x120>
    b360:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*8]
    b366:	add    r8d,r13d
    b369:	inc    edi
    b36b:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*8]
    b371:	vmovsd QWORD PTR [r14+rax*8],xmm1
    b377:	cmp    rcx,rbx
    b37a:	jne    b2ce <c_run_18.isra.0+0x12e>
    b380:	mov    r11,QWORD PTR [rsp+0x58]
    b385:	add    r9,0x8
    b389:	mov    eax,DWORD PTR [rsp+0x54]
    b38d:	cmp    r9,r11
    b390:	je     b3b0 <c_run_18.isra.0+0x210>
    b392:	add    eax,r13d
    b395:	vcomisd xmm3,QWORD PTR [r9]
    b39a:	jne    b2a0 <c_run_18.isra.0+0x100>
    b3a0:	add    r9,0x8
    b3a4:	add    eax,r13d
    b3a7:	cmp    r11,r9
    b3aa:	jne    b290 <c_run_18.isra.0+0xf0>
    b3b0:	mov    rcx,rdx
    b3b3:	vzeroupper
    b3b6:	test   r13d,r13d
    b3b9:	je     b512 <c_run_18.isra.0+0x372>
    b3bf:	cmp    r13d,0x1
    b3c3:	je     b512 <c_run_18.isra.0+0x372>
    b3c9:	mov    rax,QWORD PTR [rbp+0x20]
    b3cd:	mov    DWORD PTR [rsp+0x54],0x0
    b3d5:	mov    r14,QWORD PTR [rsp+0x8]
    b3da:	mov    rdi,QWORD PTR [rsp+0x10]
    b3df:	mov    QWORD PTR [rsp+0x30],r15
    b3e4:	mov    QWORD PTR [rbp+0x18],rcx
    b3e8:	mov    r11d,0x8
    b3ee:	mov    esi,0x1
    b3f3:	xor    r9d,r9d
    b3f6:	lea    r12d,[r13-0x1]
    b3fa:	lea    r10,[rax+0x8]
    b3fe:	mov    r8,rax
    b401:	nop    DWORD PTR [rax+0x0]
    b405:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b410:	mov    DWORD PTR [rsp+0x58],r12d
    b415:	dec    r12d
    b418:	mov    eax,DWORD PTR [rsp+0x54]
    b41c:	cmp    r12d,0xe
    b420:	jbe    b5f0 <c_run_18.isra.0+0x450>
    b426:	cmp    r13d,esi
    b429:	jle    b5f0 <c_run_18.isra.0+0x450>
    b42f:	mov    r15d,DWORD PTR [rsp+0x58]
    b434:	lea    ecx,[rax+r13*1]
    b438:	mov    DWORD PTR [rsp+0x50],ecx
    b43c:	add    rcx,r9
    b43f:	lea    rax,[rcx*8+0x0]
    b447:	dec    r15
    b44a:	mov    rdx,r15
    b44d:	imul   rdx,rbx
    b451:	add    rdx,rcx
    b454:	shl    rdx,0x3
    b458:	cmp    rdx,r11
    b45b:	jl     b46a <c_run_18.isra.0+0x2ca>
    b45d:	lea    rdx,[r11+r15*8]
    b461:	cmp    rax,rdx
    b464:	jle    b5f7 <c_run_18.isra.0+0x457>
    b46a:	mov    ecx,DWORD PTR [rsp+0x58]
    b46e:	add    rax,QWORD PTR [rbp+0x20]
    b472:	mov    rdx,r10
    b475:	shr    ecx,1
    b477:	mov    r15d,ecx
    b47a:	shl    r15,0x4
    b47e:	add    r15,r10
    b481:	nop    WORD PTR [rax+rax*1+0x0]
    b48a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b495:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b4a0:	vmovsd xmm0,QWORD PTR [rax]
    b4a4:	vmovhpd xmm0,xmm0,QWORD PTR [rax+rbx*8]
    b4a9:	add    rdx,0x10
    b4ad:	add    rax,r14
    b4b0:	vmovupd XMMWORD PTR [rdx-0x10],xmm0
    b4b5:	cmp    r15,rdx
    b4b8:	jne    b4a0 <c_run_18.isra.0+0x300>
    b4ba:	add    ecx,ecx
    b4bc:	cmp    ecx,DWORD PTR [rsp+0x58]
    b4c0:	je     b4e5 <c_run_18.isra.0+0x345>
    b4c2:	add    ecx,esi
    b4c4:	mov    eax,r13d
    b4c7:	mov    rdx,QWORD PTR [rbp+0x20]
    b4cb:	imul   eax,ecx
    b4ce:	add    eax,r9d
    b4d1:	mov    eax,eax
    b4d3:	vmovsd xmm0,QWORD PTR [rdx+rax*8]
    b4d8:	mov    eax,DWORD PTR [rsp+0x54]
    b4dc:	add    eax,ecx
    b4de:	mov    eax,eax
    b4e0:	vmovsd QWORD PTR [rdx+rax*8],xmm0
    b4e5:	mov    eax,DWORD PTR [rsp+0x50]
    b4e9:	inc    rsi
    b4ec:	inc    r9
    b4ef:	add    r8,rdi
    b4f2:	lea    r11,[r11+rdi*1+0x8]
    b4f7:	lea    r10,[r10+rdi*1+0x8]
    b4fc:	mov    DWORD PTR [rsp+0x54],eax
    b500:	cmp    rbx,rsi
    b503:	jne    b410 <c_run_18.isra.0+0x270>
    b509:	mov    r15,QWORD PTR [rsp+0x30]
    b50e:	mov    rcx,QWORD PTR [rbp+0x18]
    b512:	mov    rax,QWORD PTR [rsp+0x40]
    b517:	mov    rdi,QWORD PTR [rsp+0x38]
    b51c:	mov    rsi,QWORD PTR [rbp+0x10]
    b520:	mov    rdx,QWORD PTR [rbp+0x20]
    b524:	mov    r8,QWORD PTR [rbp+0x28]
    b528:	inc    DWORD PTR [rsp+0x4c]
    b52c:	mov    edi,DWORD PTR [rsp+0x24]
    b530:	cmp    DWORD PTR [rsp+0x4c],edi
    b534:	jne    b220 <c_run_18.isra.0+0x80>
    b53a:	lea    rsp,[rbp-0x28]
    b53e:	pop    rbx
    b53f:	pop    r12
    b541:	pop    r13
    b543:	pop    r14
    b545:	pop    r15
    b547:	pop    rbp
    b548:	ret
    b549:	lea    rcx,[r9+0x8]
    b54d:	cmp    r11,rcx
    b550:	je     b63a <c_run_18.isra.0+0x49a>
    b556:	add    r9,0x10
    b55a:	cmp    r9,r11
    b55d:	je     b63a <c_run_18.isra.0+0x49a>
    b563:	vcomisd xmm3,QWORD PTR [r9]
    b568:	je     b280 <c_run_18.isra.0+0xe0>
    b56e:	jmp    b549 <c_run_18.isra.0+0x3a9>
    b570:	shl    rax,0x3
    b574:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1]
    b57a:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1]
    b580:	vmovsd QWORD PTR [r14+rax*1],xmm0
    b586:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1+0x8]
    b58d:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1+0x8]
    b594:	vmovsd QWORD PTR [r14+rax*1+0x8],xmm0
    b59b:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*1+0x10]
    b5a2:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*1+0x10]
    b5a9:	vmovsd QWORD PTR [r14+rax*1+0x10],xmm1
    b5b0:	jmp    b2c0 <c_run_18.isra.0+0x120>
    b5b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b5c0:	shl    rax,0x3
    b5c4:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1]
    b5ca:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1]
    b5d0:	vmovsd QWORD PTR [r14+rax*1],xmm0
    b5d6:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*1+0x8]
    b5dd:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*1+0x8]
    b5e4:	vmovsd QWORD PTR [r14+rax*1+0x8],xmm1
    b5eb:	jmp    b2c0 <c_run_18.isra.0+0x120>
    b5f0:	add    eax,r13d
    b5f3:	mov    DWORD PTR [rsp+0x50],eax
    b5f7:	mov    eax,DWORD PTR [rsp+0x50]
    b5fb:	mov    rcx,QWORD PTR [rbp+0x20]
    b5ff:	add    rax,r9
    b602:	lea    rdx,[rcx+rax*8]
    b606:	mov    rax,rsi
    b609:	nop
    b60a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b615:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b620:	vmovsd xmm0,QWORD PTR [rdx]
    b624:	add    rdx,rdi
    b627:	vmovsd QWORD PTR [r8+rax*8],xmm0
    b62d:	inc    rax
    b630:	cmp    r13d,eax
    b633:	jg     b620 <c_run_18.isra.0+0x480>
    b635:	jmp    b4e5 <c_run_18.isra.0+0x345>
    b63a:	mov    rcx,rdx
    b63d:	vzeroupper
    b640:	jmp    b512 <c_run_18.isra.0+0x372>
    b645:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_19.isra.0>:
    b650:	push   rbp
    b651:	mov    rbp,rsp
    b654:	push   r15
    b656:	push   r14
    b658:	push   r13
    b65a:	push   r12
    b65c:	push   rbx
    b65d:	and    rsp,0xffffffffffffffe0
    b661:	sub    rsp,0x40
    b665:	mov    r12,QWORD PTR [rbp+0x20]
    b669:	mov    QWORD PTR [rsp+0x28],r8
    b66e:	mov    QWORD PTR [rsp+0x20],r9
    b673:	mov    r8,QWORD PTR [rbp+0x18]
    b677:	test   edx,edx
    b679:	je     b894 <c_run_19.isra.0+0x244>
    b67f:	mov    eax,esi
    b681:	mov    DWORD PTR [rsp+0x18],edx
    b685:	mov    DWORD PTR [rsp+0xc],edi
    b689:	mov    ebx,esi
    b68b:	xor    r13d,r13d
    b68e:	imul   eax,esi
    b691:	shl    rax,0x3
    b695:	mov    QWORD PTR [rsp+0x10],rax
    b69a:	mov    eax,edi
    b69c:	lea    r15,[r8+rax*8]
    b6a0:	lea    eax,[rsi+0x1]
    b6a3:	mov    DWORD PTR [rsp+0x8],eax
    b6a7:	nop    WORD PTR [rax+rax*1+0x0]
    b6b0:	mov    rax,QWORD PTR [rsp+0x28]
    b6b5:	mov    rdi,QWORD PTR [rsp+0x20]
    b6ba:	mov    rdx,QWORD PTR [rbp+0x10]
    b6be:	mov    rsi,QWORD PTR [rbp+0x28]
    b6c2:	mov    rdx,QWORD PTR [rsp+0x10]
    b6c7:	xor    esi,esi
    b6c9:	mov    rdi,r12
    b6cc:	mov    QWORD PTR [rbp+0x18],r8
    b6d0:	mov    QWORD PTR [rsp+0x38],rcx
    b6d5:	call   2bd0 <memset@plt>
    b6da:	mov    eax,DWORD PTR [rsp+0xc]
    b6de:	mov    rcx,QWORD PTR [rsp+0x38]
    b6e3:	mov    r8,QWORD PTR [rbp+0x18]
    b6e7:	vxorpd xmm3,xmm3,xmm3
    b6eb:	test   eax,eax
    b6ed:	je     b874 <c_run_19.isra.0+0x224>
    b6f3:	mov    r14d,DWORD PTR [rsp+0x8]
    b6f8:	mov    DWORD PTR [rsp+0x1c],r13d
    b6fd:	mov    QWORD PTR [rbp+0x20],r12
    b701:	mov    r9,r8
    b704:	xor    eax,eax
    b706:	mov    rdx,rcx
    b709:	jmp    b72f <c_run_19.isra.0+0xdf>
    b70b:	cs nop WORD PTR [rax+rax*1+0x0]
    b715:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b720:	add    r9,0x8
    b724:	add    eax,ebx
    b726:	cmp    r15,r9
    b729:	je     b865 <c_run_19.isra.0+0x215>
    b72f:	vcomisd xmm3,QWORD PTR [r9]
    b734:	je     b720 <c_run_19.isra.0+0xd0>
    b736:	test   ebx,ebx
    b738:	je     b8a3 <c_run_19.isra.0+0x253>
    b73e:	mov    QWORD PTR [rsp+0x30],r15
    b743:	mov    rdi,r8
    b746:	mov    esi,eax
    b748:	mov    DWORD PTR [rsp+0x38],eax
    b74c:	mov    r8d,0xfffffffd
    b752:	xor    r10d,r10d
    b755:	lea    r11,[rdx+rsi*8]
    b759:	mov    esi,0x1
    b75e:	jmp    b772 <c_run_19.isra.0+0x122>
    b760:	inc    rsi
    b763:	add    r10d,ebx
    b766:	inc    r8d
    b769:	cmp    r14,rsi
    b76c:	je     b830 <c_run_19.isra.0+0x1e0>
    b772:	vmovsd xmm0,QWORD PTR [r11+rsi*8-0x8]
    b779:	vcomisd xmm0,xmm3
    b77d:	je     b760 <c_run_19.isra.0+0x110>
    b77f:	mov    rcx,QWORD PTR [rbp+0x20]
    b783:	mov    eax,r10d
    b786:	vmulsd xmm1,xmm0,QWORD PTR [r9]
    b78b:	mov    r13d,esi
    b78e:	lea    r15,[rcx+rax*8]
    b792:	xor    eax,eax
    b794:	test   r8d,r8d
    b797:	js     b7e3 <c_run_19.isra.0+0x193>
    b799:	mov    eax,r8d
    b79c:	mov    rcx,r15
    b79f:	sub    rcx,r11
    b7a2:	vbroadcastsd ymm2,xmm1
    b7a7:	shr    eax,0x2
    b7aa:	shl    rax,0x5
    b7ae:	lea    r12,[r11+rax*1+0x20]
    b7b3:	mov    rax,r11
    b7b6:	cs nop WORD PTR [rax+rax*1+0x0]
    b7c0:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    b7c4:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx+rax*1]
    b7c9:	vmovupd YMMWORD PTR [rcx+rax*1],ymm0
    b7ce:	add    rax,0x20
    b7d2:	cmp    r12,rax
    b7d5:	jne    b7c0 <c_run_19.isra.0+0x170>
    b7d7:	mov    eax,r8d
    b7da:	and    eax,0xfffffffc
    b7dd:	add    eax,0x4
    b7e0:	sub    r13d,eax
    b7e3:	cmp    r13d,0x3
    b7e7:	je     b8d0 <c_run_19.isra.0+0x280>
    b7ed:	cmp    r13d,0x2
    b7f1:	je     b920 <c_run_19.isra.0+0x2d0>
    b7f7:	cmp    r13d,0x1
    b7fb:	jne    b760 <c_run_19.isra.0+0x110>
    b801:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*8]
    b807:	inc    rsi
    b80a:	add    r10d,ebx
    b80d:	inc    r8d
    b810:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*8]
    b816:	vmovsd QWORD PTR [r15+rax*8],xmm1
    b81c:	cmp    r14,rsi
    b81f:	jne    b772 <c_run_19.isra.0+0x122>
    b825:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b830:	mov    r15,QWORD PTR [rsp+0x30]
    b835:	add    r9,0x8
    b839:	mov    eax,DWORD PTR [rsp+0x38]
    b83d:	cmp    r9,r15
    b840:	je     b950 <c_run_19.isra.0+0x300>
    b846:	add    eax,ebx
    b848:	vcomisd xmm3,QWORD PTR [r9]
    b84d:	jne    b746 <c_run_19.isra.0+0xf6>
    b853:	add    r9,0x8
    b857:	mov    r8,rdi
    b85a:	add    eax,ebx
    b85c:	cmp    r15,r9
    b85f:	jne    b72f <c_run_19.isra.0+0xdf>
    b865:	mov    r13d,DWORD PTR [rsp+0x1c]
    b86a:	mov    r12,QWORD PTR [rbp+0x20]
    b86e:	mov    rcx,rdx
    b871:	vzeroupper
    b874:	mov    rax,QWORD PTR [rsp+0x28]
    b879:	mov    rdi,QWORD PTR [rsp+0x20]
    b87e:	mov    rdx,QWORD PTR [rbp+0x10]
    b882:	mov    rsi,QWORD PTR [rbp+0x28]
    b886:	inc    r13d
    b889:	cmp    r13d,DWORD PTR [rsp+0x18]
    b88e:	jne    b6b0 <c_run_19.isra.0+0x60>
    b894:	lea    rsp,[rbp-0x28]
    b898:	pop    rbx
    b899:	pop    r12
    b89b:	pop    r13
    b89d:	pop    r14
    b89f:	pop    r15
    b8a1:	pop    rbp
    b8a2:	ret
    b8a3:	lea    rcx,[r9+0x8]
    b8a7:	cmp    r15,rcx
    b8aa:	je     b865 <c_run_19.isra.0+0x215>
    b8ac:	add    r9,0x10
    b8b0:	cmp    r9,r15
    b8b3:	je     b865 <c_run_19.isra.0+0x215>
    b8b5:	vcomisd xmm3,QWORD PTR [r9]
    b8ba:	je     b720 <c_run_19.isra.0+0xd0>
    b8c0:	jmp    b8a3 <c_run_19.isra.0+0x253>
    b8c2:	nop    DWORD PTR [rax]
    b8c5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b8d0:	shl    rax,0x3
    b8d4:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1]
    b8da:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    b8e0:	vmovsd QWORD PTR [r15+rax*1],xmm0
    b8e6:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1+0x8]
    b8ed:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1+0x8]
    b8f4:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm0
    b8fb:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*1+0x10]
    b902:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x10]
    b909:	vmovsd QWORD PTR [r15+rax*1+0x10],xmm1
    b910:	jmp    b760 <c_run_19.isra.0+0x110>
    b915:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b920:	shl    rax,0x3
    b924:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1]
    b92a:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    b930:	vmovsd QWORD PTR [r15+rax*1],xmm0
    b936:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*1+0x8]
    b93d:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x8]
    b944:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm1
    b94b:	jmp    b760 <c_run_19.isra.0+0x110>
    b950:	mov    r13d,DWORD PTR [rsp+0x1c]
    b955:	mov    r12,QWORD PTR [rbp+0x20]
    b959:	mov    rcx,rdx
    b95c:	mov    r8,rdi
    b95f:	vzeroupper
    b962:	jmp    b874 <c_run_19.isra.0+0x224>
    b967:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_2.isra.0>:
    65d0:	mov    r11d,edi
    65d3:	mov    rax,rsi
    65d6:	mov    r10,QWORD PTR [rsp+0x10]
    65db:	mov    rsi,rdx
    65de:	mov    rdi,rcx
    65e1:	mov    rdx,QWORD PTR [rsp+0x8]
    65e6:	test   r11d,r11d
    65e9:	je     665a <c_run_2.isra.0+0x8a>
    65eb:	xor    ecx,ecx
    65ed:	nop    DWORD PTR [rax]
    65f0:	vmovsd xmm0,QWORD PTR [r8]
    65f5:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x18]
    65fa:	vmovsd xmm4,QWORD PTR [r8+0x8]
    6600:	vmovsd xmm3,QWORD PTR [r8+0x10]
    6606:	vmulsd xmm2,xmm4,QWORD PTR [rax+0x20]
    660b:	vmulsd xmm5,xmm4,QWORD PTR [rax+0x38]
    6610:	vmulsd xmm4,xmm4,QWORD PTR [rax+0x8]
    6615:	vaddsd xmm1,xmm1,xmm2
    6619:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x28]
    661e:	vaddsd xmm2,xmm1,xmm2
    6622:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x30]
    6627:	vmulsd xmm0,xmm0,QWORD PTR [rax]
    662b:	vaddsd xmm1,xmm1,xmm5
    662f:	vmulsd xmm5,xmm3,QWORD PTR [rax+0x40]
    6634:	vmulsd xmm3,xmm3,QWORD PTR [rax+0x10]
    6639:	vaddsd xmm0,xmm0,xmm4
    663d:	vmovsd QWORD PTR [rdx+0x8],xmm2
    6642:	vaddsd xmm1,xmm1,xmm5
    6646:	vaddsd xmm0,xmm0,xmm3
    664a:	vmovsd QWORD PTR [rdx+0x10],xmm1
    664f:	vmovsd QWORD PTR [rdx],xmm0
    6653:	inc    ecx
    6655:	cmp    ecx,r11d
    6658:	jne    65f0 <c_run_2.isra.0+0x20>
    665a:	ret
    665b:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_20.isra.0>:
    b970:	push   rbp
    b971:	mov    rbp,rsp
    b974:	push   r15
    b976:	push   r14
    b978:	push   r13
    b97a:	push   r12
    b97c:	push   rbx
    b97d:	and    rsp,0xffffffffffffffe0
    b981:	sub    rsp,0x40
    b985:	mov    QWORD PTR [rsp+0x30],rcx
    b98a:	mov    QWORD PTR [rsp+0x28],r8
    b98f:	mov    QWORD PTR [rsp+0x20],r9
    b994:	test   edx,edx
    b996:	je     bb70 <c_run_20.isra.0+0x200>
    b99c:	mov    eax,esi
    b99e:	mov    DWORD PTR [rsp+0x18],edx
    b9a2:	mov    DWORD PTR [rsp+0x38],esi
    b9a6:	mov    r12d,esi
    b9a9:	mov    ebx,edi
    b9ab:	xor    r14d,r14d
    b9ae:	imul   eax,esi
    b9b1:	shl    r12,0x3
    b9b5:	shl    rax,0x3
    b9b9:	mov    QWORD PTR [rsp+0x10],rax
    b9be:	mov    rax,QWORD PTR [rsp+0x30]
    b9c3:	mov    rdi,QWORD PTR [rsp+0x28]
    b9c8:	mov    rsi,QWORD PTR [rsp+0x20]
    b9cd:	mov    rdx,QWORD PTR [rbp+0x10]
    b9d1:	mov    rcx,QWORD PTR [rbp+0x18]
    b9d5:	mov    r9,QWORD PTR [rbp+0x20]
    b9d9:	mov    r15,QWORD PTR [rbp+0x28]
    b9dd:	mov    rdx,QWORD PTR [rsp+0x10]
    b9e2:	mov    rdi,QWORD PTR [rbp+0x20]
    b9e6:	xor    esi,esi
    b9e8:	call   2bd0 <memset@plt>
    b9ed:	mov    eax,DWORD PTR [rsp+0x38]
    b9f1:	vxorpd xmm3,xmm3,xmm3
    b9f5:	test   eax,eax
    b9f7:	je     bb43 <c_run_20.isra.0+0x1d3>
    b9fd:	test   ebx,ebx
    b9ff:	je     bb43 <c_run_20.isra.0+0x1d3>
    ba05:	mov    DWORD PTR [rsp+0x1c],r14d
    ba0a:	mov    r10d,0xfffffffd
    ba10:	xor    r9d,r9d
    ba13:	xor    r8d,r8d
    ba16:	xor    r13d,r13d
    ba19:	nop    DWORD PTR [rax+0x0]
    ba20:	mov    rdi,QWORD PTR [rbp+0x20]
    ba24:	movsxd rax,r9d
    ba27:	mov    ecx,r10d
    ba2a:	mov    r14d,r10d
    ba2d:	and    r14d,0xfffffffc
    ba31:	inc    r13d
    ba34:	mov    DWORD PTR [rsp+0x3c],r9d
    ba39:	xor    edx,edx
    ba3b:	add    r14d,0x4
    ba3f:	shr    ecx,0x2
    ba42:	lea    rsi,[rdi+rax*8]
    ba46:	mov    rax,QWORD PTR [rsp+0x30]
    ba4b:	mov    r15d,r13d
    ba4e:	sub    r15d,r14d
    ba51:	mov    r9d,r14d
    ba54:	shl    rcx,0x5
    ba58:	lea    rdi,[rsi+rcx*1+0x20]
    ba5d:	sub    rax,rsi
    ba60:	jmp    ba8d <c_run_20.isra.0+0x11d>
    ba62:	nop    DWORD PTR [rax+rax*1+0x0]
    ba6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ba75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ba80:	inc    edx
    ba82:	add    rax,r12
    ba85:	cmp    ebx,edx
    ba87:	je     bb20 <c_run_20.isra.0+0x1b0>
    ba8d:	lea    r11,[rsi+rax*1]
    ba91:	vmovsd xmm1,QWORD PTR [r11+r8*8]
    ba97:	vcomisd xmm1,xmm3
    ba9b:	je     ba80 <c_run_20.isra.0+0x110>
    ba9d:	test   r10d,r10d
    baa0:	js     bb80 <c_run_20.isra.0+0x210>
    baa6:	vbroadcastsd ymm2,xmm1
    baab:	mov    rcx,rsi
    baae:	nop    DWORD PTR [rax+0x0]
    bab5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bac0:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
    bac5:	add    rcx,0x20
    bac9:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    bace:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
    bad3:	cmp    rdi,rcx
    bad6:	jne    bac0 <c_run_20.isra.0+0x150>
    bad8:	mov    r14d,r15d
    badb:	mov    ecx,r9d
    bade:	cmp    r14d,0x3
    bae2:	je     bb8f <c_run_20.isra.0+0x21f>
    bae8:	cmp    r14d,0x2
    baec:	je     bbd0 <c_run_20.isra.0+0x260>
    baf2:	cmp    r14d,0x1
    baf6:	jne    ba80 <c_run_20.isra.0+0x110>
    baf8:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*8]
    bafe:	inc    edx
    bb00:	add    rax,r12
    bb03:	vaddsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    bb08:	vmovsd QWORD PTR [rsi+rcx*8],xmm1
    bb0d:	cmp    ebx,edx
    bb0f:	jne    ba8d <c_run_20.isra.0+0x11d>
    bb15:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bb20:	mov    r9d,DWORD PTR [rsp+0x3c]
    bb25:	mov    eax,DWORD PTR [rsp+0x38]
    bb29:	inc    r8
    bb2c:	inc    r10d
    bb2f:	add    r9d,eax
    bb32:	cmp    eax,r13d
    bb35:	jne    ba20 <c_run_20.isra.0+0xb0>
    bb3b:	mov    r14d,DWORD PTR [rsp+0x1c]
    bb40:	vzeroupper
    bb43:	mov    rax,QWORD PTR [rsp+0x30]
    bb48:	mov    rdi,QWORD PTR [rsp+0x28]
    bb4d:	mov    rsi,QWORD PTR [rsp+0x20]
    bb52:	mov    rdx,QWORD PTR [rbp+0x10]
    bb56:	mov    rcx,QWORD PTR [rbp+0x18]
    bb5a:	mov    r9,QWORD PTR [rbp+0x20]
    bb5e:	mov    r15,QWORD PTR [rbp+0x28]
    bb62:	inc    r14d
    bb65:	cmp    r14d,DWORD PTR [rsp+0x18]
    bb6a:	jne    b9be <c_run_20.isra.0+0x4e>
    bb70:	lea    rsp,[rbp-0x28]
    bb74:	pop    rbx
    bb75:	pop    r12
    bb77:	pop    r13
    bb79:	pop    r14
    bb7b:	pop    r15
    bb7d:	pop    rbp
    bb7e:	ret
    bb7f:	nop
    bb80:	mov    r14d,r13d
    bb83:	xor    ecx,ecx
    bb85:	cmp    r14d,0x3
    bb89:	jne    bae8 <c_run_20.isra.0+0x178>
    bb8f:	shl    rcx,0x3
    bb93:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    bb99:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    bb9e:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    bba3:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1+0x8]
    bbaa:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rsi*1+0x8]
    bbb0:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm0
    bbb6:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x10]
    bbbd:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x10]
    bbc3:	vmovsd QWORD PTR [rcx+rsi*1+0x10],xmm1
    bbc9:	jmp    ba80 <c_run_20.isra.0+0x110>
    bbce:	xchg   ax,ax
    bbd0:	shl    rcx,0x3
    bbd4:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    bbda:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    bbdf:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    bbe4:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x8]
    bbeb:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x8]
    bbf1:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm1
    bbf7:	jmp    ba80 <c_run_20.isra.0+0x110>
    bbfc:	nop    DWORD PTR [rax+0x0]


<c_run_3.isra.0>:
    6660:	mov    r11d,edi
    6663:	mov    r10,QWORD PTR [rsp+0x10]
    6668:	mov    rdi,rdx
    666b:	mov    rax,rsi
    666e:	mov    rdx,QWORD PTR [rsp+0x8]
    6673:	test   r11d,r11d
    6676:	je     66e0 <c_run_3.isra.0+0x80>
    6678:	xor    esi,esi
    667a:	nop    WORD PTR [rax+rax*1+0x0]
    6680:	vmovupd xmm0,XMMWORD PTR [r8]
    6685:	vmovsd xmm1,QWORD PTR [rax+0x10]
    668a:	vmovsd xmm3,QWORD PTR [r8+0x10]
    6690:	vunpckhpd xmm2,xmm0,xmm0
    6694:	vmulsd xmm2,xmm2,QWORD PTR [rax+0x28]
    6699:	vmulsd xmm1,xmm1,xmm0
    669d:	vaddsd xmm1,xmm1,xmm2
    66a1:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x40]
    66a6:	vmovddup xmm3,xmm3
    66aa:	vmulpd xmm3,xmm3,XMMWORD PTR [rax+0x30]
    66af:	vaddsd xmm1,xmm1,xmm2
    66b3:	vpermilpd xmm2,xmm0,0x0
    66b9:	vpermilpd xmm0,xmm0,0x3
    66bf:	vmulpd xmm2,xmm2,XMMWORD PTR [rax]
    66c3:	vmulpd xmm0,xmm0,XMMWORD PTR [rax+0x18]
    66c8:	vmovsd QWORD PTR [rdx+0x10],xmm1
    66cd:	vaddpd xmm0,xmm2,xmm0
    66d1:	vaddpd xmm0,xmm0,xmm3
    66d5:	vmovupd XMMWORD PTR [rdx],xmm0
    66d9:	inc    esi
    66db:	cmp    esi,r11d
    66de:	jne    6680 <c_run_3.isra.0+0x20>
    66e0:	ret
    66e1:	nop    DWORD PTR [rax+0x0]
    66e5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_4.isra.0>:
    66f0:	mov    r11d,edi
    66f3:	mov    r10,QWORD PTR [rsp+0x10]
    66f8:	mov    rdi,rcx
    66fb:	mov    rax,rsi
    66fe:	mov    rcx,QWORD PTR [rsp+0x8]
    6703:	test   r11d,r11d
    6706:	je     6897 <c_run_4.isra.0+0x1a7>
    670c:	xor    esi,esi
    670e:	xchg   ax,ax
    6710:	vmovsd xmm0,QWORD PTR [rax]
    6714:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6718:	vmovsd xmm1,QWORD PTR [rax+0x8]
    671d:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    6722:	vaddsd xmm0,xmm0,xmm1
    6726:	vmovsd xmm1,QWORD PTR [rax+0x10]
    672b:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    6730:	vaddsd xmm0,xmm0,xmm1
    6734:	vmovsd QWORD PTR [rcx],xmm0
    6738:	vmovsd xmm0,QWORD PTR [rax]
    673c:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6741:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6746:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    674b:	vaddsd xmm0,xmm0,xmm1
    674f:	vmovsd xmm1,QWORD PTR [rax+0x10]
    6754:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6759:	vaddsd xmm0,xmm0,xmm1
    675d:	vmovsd QWORD PTR [rcx+0x8],xmm0
    6762:	vmovsd xmm0,QWORD PTR [rax]
    6766:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    676b:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6770:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6775:	vaddsd xmm0,xmm0,xmm1
    6779:	vmovsd xmm1,QWORD PTR [rax+0x10]
    677e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6783:	vaddsd xmm0,xmm0,xmm1
    6787:	vmovsd QWORD PTR [rcx+0x10],xmm0
    678c:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6791:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6795:	vmovsd xmm1,QWORD PTR [rax+0x20]
    679a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    679f:	vaddsd xmm0,xmm0,xmm1
    67a3:	vmovsd xmm1,QWORD PTR [rax+0x28]
    67a8:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    67ad:	vaddsd xmm0,xmm0,xmm1
    67b1:	vmovsd QWORD PTR [rcx+0x18],xmm0
    67b6:	vmovsd xmm0,QWORD PTR [rax+0x18]
    67bb:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    67c0:	vmovsd xmm1,QWORD PTR [rax+0x20]
    67c5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    67ca:	vaddsd xmm0,xmm0,xmm1
    67ce:	vmovsd xmm1,QWORD PTR [rax+0x28]
    67d3:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    67d8:	vaddsd xmm0,xmm0,xmm1
    67dc:	vmovsd QWORD PTR [rcx+0x20],xmm0
    67e1:	vmovsd xmm0,QWORD PTR [rax+0x18]
    67e6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    67eb:	vmovsd xmm1,QWORD PTR [rax+0x20]
    67f0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    67f5:	vaddsd xmm0,xmm0,xmm1
    67f9:	vmovsd xmm1,QWORD PTR [rax+0x28]
    67fe:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6803:	vaddsd xmm0,xmm0,xmm1
    6807:	vmovsd QWORD PTR [rcx+0x28],xmm0
    680c:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6811:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6815:	vmovsd xmm1,QWORD PTR [rax+0x38]
    681a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    681f:	vaddsd xmm0,xmm0,xmm1
    6823:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6828:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    682d:	vaddsd xmm0,xmm0,xmm1
    6831:	vmovsd QWORD PTR [rcx+0x30],xmm0
    6836:	vmovsd xmm0,QWORD PTR [rax+0x30]
    683b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6840:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6845:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    684a:	vaddsd xmm0,xmm0,xmm1
    684e:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6853:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6858:	vaddsd xmm0,xmm0,xmm1
    685c:	vmovsd QWORD PTR [rcx+0x38],xmm0
    6861:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6866:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    686b:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6870:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6875:	vaddsd xmm0,xmm0,xmm1
    6879:	vmovsd xmm1,QWORD PTR [rax+0x40]
    687e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6883:	vaddsd xmm0,xmm0,xmm1
    6887:	vmovsd QWORD PTR [rcx+0x40],xmm0
    688c:	inc    esi
    688e:	cmp    esi,r11d
    6891:	jne    6710 <c_run_4.isra.0+0x20>
    6897:	ret
    6898:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_5.isra.0>:
    68a0:	mov    r11d,edi
    68a3:	mov    r10,QWORD PTR [rsp+0x10]
    68a8:	mov    rdi,rcx
    68ab:	mov    rax,rsi
    68ae:	mov    rcx,QWORD PTR [rsp+0x8]
    68b3:	test   r11d,r11d
    68b6:	je     6a47 <c_run_5.isra.0+0x1a7>
    68bc:	xor    esi,esi
    68be:	xchg   ax,ax
    68c0:	vmovsd xmm0,QWORD PTR [rax]
    68c4:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    68c8:	vmovsd xmm1,QWORD PTR [rax+0x18]
    68cd:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    68d2:	vaddsd xmm0,xmm0,xmm1
    68d6:	vmovsd xmm1,QWORD PTR [rax+0x30]
    68db:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    68e0:	vaddsd xmm0,xmm0,xmm1
    68e4:	vmovsd QWORD PTR [rcx],xmm0
    68e8:	vmovsd xmm0,QWORD PTR [rax]
    68ec:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    68f1:	vmovsd xmm1,QWORD PTR [rax+0x18]
    68f6:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    68fb:	vaddsd xmm0,xmm0,xmm1
    68ff:	vmovsd xmm1,QWORD PTR [rax+0x30]
    6904:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6909:	vaddsd xmm0,xmm0,xmm1
    690d:	vmovsd QWORD PTR [rcx+0x8],xmm0
    6912:	vmovsd xmm0,QWORD PTR [rax]
    6916:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    691b:	vmovsd xmm1,QWORD PTR [rax+0x18]
    6920:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6925:	vaddsd xmm0,xmm0,xmm1
    6929:	vmovsd xmm1,QWORD PTR [rax+0x30]
    692e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6933:	vaddsd xmm0,xmm0,xmm1
    6937:	vmovsd QWORD PTR [rcx+0x10],xmm0
    693c:	vmovsd xmm0,QWORD PTR [rax+0x8]
    6941:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6945:	vmovsd xmm1,QWORD PTR [rax+0x20]
    694a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    694f:	vaddsd xmm0,xmm0,xmm1
    6953:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6958:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    695d:	vaddsd xmm0,xmm0,xmm1
    6961:	vmovsd QWORD PTR [rcx+0x18],xmm0
    6966:	vmovsd xmm0,QWORD PTR [rax+0x8]
    696b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6970:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6975:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    697a:	vaddsd xmm0,xmm0,xmm1
    697e:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6983:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6988:	vaddsd xmm0,xmm0,xmm1
    698c:	vmovsd QWORD PTR [rcx+0x20],xmm0
    6991:	vmovsd xmm0,QWORD PTR [rax+0x8]
    6996:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    699b:	vmovsd xmm1,QWORD PTR [rax+0x20]
    69a0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    69a5:	vaddsd xmm0,xmm0,xmm1
    69a9:	vmovsd xmm1,QWORD PTR [rax+0x38]
    69ae:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    69b3:	vaddsd xmm0,xmm0,xmm1
    69b7:	vmovsd QWORD PTR [rcx+0x28],xmm0
    69bc:	vmovsd xmm0,QWORD PTR [rax+0x10]
    69c1:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    69c5:	vmovsd xmm1,QWORD PTR [rax+0x28]
    69ca:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    69cf:	vaddsd xmm0,xmm0,xmm1
    69d3:	vmovsd xmm1,QWORD PTR [rax+0x40]
    69d8:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    69dd:	vaddsd xmm0,xmm0,xmm1
    69e1:	vmovsd QWORD PTR [rcx+0x30],xmm0
    69e6:	vmovsd xmm0,QWORD PTR [rax+0x10]
    69eb:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    69f0:	vmovsd xmm1,QWORD PTR [rax+0x28]
    69f5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    69fa:	vaddsd xmm0,xmm0,xmm1
    69fe:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6a03:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6a08:	vaddsd xmm0,xmm0,xmm1
    6a0c:	vmovsd QWORD PTR [rcx+0x38],xmm0
    6a11:	vmovsd xmm0,QWORD PTR [rax+0x10]
    6a16:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    6a1b:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6a20:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6a25:	vaddsd xmm0,xmm0,xmm1
    6a29:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6a2e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6a33:	vaddsd xmm0,xmm0,xmm1
    6a37:	vmovsd QWORD PTR [rcx+0x40],xmm0
    6a3c:	inc    esi
    6a3e:	cmp    esi,r11d
    6a41:	jne    68c0 <c_run_5.isra.0+0x20>
    6a47:	ret
    6a48:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_6.isra.0>:
    6a50:	mov    r11d,edi
    6a53:	mov    r10,QWORD PTR [rsp+0x10]
    6a58:	mov    rdi,rcx
    6a5b:	mov    rax,rsi
    6a5e:	mov    rcx,QWORD PTR [rsp+0x8]
    6a63:	test   r11d,r11d
    6a66:	je     6bf7 <c_run_6.isra.0+0x1a7>
    6a6c:	xor    esi,esi
    6a6e:	xchg   ax,ax
    6a70:	vmovsd xmm0,QWORD PTR [rax]
    6a74:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6a78:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6a7d:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    6a82:	vaddsd xmm0,xmm0,xmm1
    6a86:	vmovsd xmm1,QWORD PTR [rax+0x10]
    6a8b:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    6a90:	vaddsd xmm0,xmm0,xmm1
    6a94:	vmovsd QWORD PTR [rcx],xmm0
    6a98:	vmovsd xmm0,QWORD PTR [rax]
    6a9c:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    6aa1:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6aa6:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    6aab:	vaddsd xmm0,xmm0,xmm1
    6aaf:	vmovsd xmm1,QWORD PTR [rax+0x10]
    6ab4:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6ab9:	vaddsd xmm0,xmm0,xmm1
    6abd:	vmovsd QWORD PTR [rcx+0x8],xmm0
    6ac2:	vmovsd xmm0,QWORD PTR [rax]
    6ac6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    6acb:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6ad0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6ad5:	vaddsd xmm0,xmm0,xmm1
    6ad9:	vmovsd xmm1,QWORD PTR [rax+0x10]
    6ade:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6ae3:	vaddsd xmm0,xmm0,xmm1
    6ae7:	vmovsd QWORD PTR [rcx+0x10],xmm0
    6aec:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6af1:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6af5:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6afa:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    6aff:	vaddsd xmm0,xmm0,xmm1
    6b03:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6b08:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    6b0d:	vaddsd xmm0,xmm0,xmm1
    6b11:	vmovsd QWORD PTR [rcx+0x18],xmm0
    6b16:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6b1b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    6b20:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6b25:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    6b2a:	vaddsd xmm0,xmm0,xmm1
    6b2e:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6b33:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6b38:	vaddsd xmm0,xmm0,xmm1
    6b3c:	vmovsd QWORD PTR [rcx+0x20],xmm0
    6b41:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6b46:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    6b4b:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6b50:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6b55:	vaddsd xmm0,xmm0,xmm1
    6b59:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6b5e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6b63:	vaddsd xmm0,xmm0,xmm1
    6b67:	vmovsd QWORD PTR [rcx+0x28],xmm0
    6b6c:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6b71:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6b75:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6b7a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    6b7f:	vaddsd xmm0,xmm0,xmm1
    6b83:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6b88:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    6b8d:	vaddsd xmm0,xmm0,xmm1
    6b91:	vmovsd QWORD PTR [rcx+0x30],xmm0
    6b96:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6b9b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    6ba0:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6ba5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    6baa:	vaddsd xmm0,xmm0,xmm1
    6bae:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6bb3:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6bb8:	vaddsd xmm0,xmm0,xmm1
    6bbc:	vmovsd QWORD PTR [rcx+0x38],xmm0
    6bc1:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6bc6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    6bcb:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6bd0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6bd5:	vaddsd xmm0,xmm0,xmm1
    6bd9:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6bde:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6be3:	vaddsd xmm0,xmm0,xmm1
    6be7:	vmovsd QWORD PTR [rcx+0x40],xmm0
    6bec:	inc    esi
    6bee:	cmp    esi,r11d
    6bf1:	jne    6a70 <c_run_6.isra.0+0x20>
    6bf7:	ret
    6bf8:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_7.isra.0>:
    a790:	push   rbp
    a791:	mov    rbp,rsp
    a794:	push   r15
    a796:	push   r14
    a798:	push   r13
    a79a:	push   r12
    a79c:	push   rbx
    a79d:	mov    r13,rcx
    a7a0:	mov    rcx,r8
    a7a3:	and    rsp,0xffffffffffffffe0
    a7a7:	test   edx,edx
    a7a9:	mov    DWORD PTR [rsp-0x8],edx
    a7ad:	mov    QWORD PTR [rsp-0x10],r8
    a7b2:	mov    rdx,QWORD PTR [rbp+0x10]
    a7b6:	mov    r8,QWORD PTR [rbp+0x20]
    a7ba:	je     a946 <c_run_7.isra.0+0x1b6>
    a7c0:	mov    eax,edi
    a7c2:	mov    ebx,esi
    a7c4:	mov    rdi,QWORD PTR [rbp+0x18]
    a7c8:	mov    rsi,QWORD PTR [rbp+0x28]
    a7cc:	mov    r15,r9
    a7cf:	test   eax,eax
    a7d1:	je     a955 <c_run_7.isra.0+0x1c5>
    a7d7:	lea    r11d,[rbx-0x8]
    a7db:	lea    ecx,[rbx-0x4]
    a7de:	mov    r9d,ebx
    a7e1:	lea    r10,[r8+rax*8]
    a7e5:	and    r11d,0xfffffffc
    a7e9:	mov    eax,0x4
    a7ee:	add    r11d,0x8
    a7f2:	shl    r9,0x3
    a7f6:	cmp    ecx,0x3
    a7f9:	cmovle r11d,eax
    a7fd:	xor    r14d,r14d
    a800:	mov    r12d,ebx
    a803:	sub    r12d,r11d
    a806:	cs nop WORD PTR [rax+rax*1+0x0]
    a810:	mov    DWORD PTR [rsp-0x4],r14d
    a815:	mov    rax,r13
    a818:	mov    rdi,r8
    a81b:	nop    DWORD PTR [rax+rax*1+0x0]
    a820:	test   ecx,ecx
    a822:	js     a8e0 <c_run_7.isra.0+0x150>
    a828:	vmovupd ymm1,YMMWORD PTR [rax]
    a82c:	vmulpd ymm1,ymm1,YMMWORD PTR [rdx]
    a830:	cmp    ecx,0x3
    a833:	jle    a856 <c_run_7.isra.0+0xc6>
    a835:	mov    esi,0x4
    a83a:	nop    WORD PTR [rax+rax*1+0x0]
    a840:	vmovupd ymm0,YMMWORD PTR [rax+rsi*8]
    a845:	vmulpd ymm0,ymm0,YMMWORD PTR [rdx+rsi*8]
    a84a:	add    rsi,0x4
    a84e:	vaddpd ymm1,ymm1,ymm0
    a852:	cmp    ecx,esi
    a854:	jge    a840 <c_run_7.isra.0+0xb0>
    a856:	vmovapd xmm0,xmm1
    a85a:	vextractf64x2 xmm1,ymm1,0x1
    a861:	mov    r14d,r12d
    a864:	mov    esi,r11d
    a867:	vaddpd xmm0,xmm0,xmm1
    a86b:	vunpckhpd xmm1,xmm0,xmm0
    a86f:	vaddsd xmm0,xmm0,xmm1
    a873:	cmp    r14d,0x3
    a877:	je     a8ef <c_run_7.isra.0+0x15f>
    a879:	cmp    r14d,0x2
    a87d:	je     a920 <c_run_7.isra.0+0x190>
    a883:	cmp    r14d,0x1
    a887:	jne    a8a0 <c_run_7.isra.0+0x110>
    a889:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    a88e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    a893:	vaddsd xmm0,xmm0,xmm1
    a897:	nop    WORD PTR [rax+rax*1+0x0]
    a8a0:	vmovsd QWORD PTR [rdi],xmm0
    a8a4:	add    rdi,0x8
    a8a8:	add    rax,r9
    a8ab:	cmp    r10,rdi
    a8ae:	jne    a820 <c_run_7.isra.0+0x90>
    a8b4:	mov    r14d,DWORD PTR [rsp-0x4]
    a8b9:	mov    rax,QWORD PTR [rsp-0x10]
    a8be:	mov    rdi,QWORD PTR [rbp+0x18]
    a8c2:	mov    rsi,QWORD PTR [rbp+0x28]
    a8c6:	inc    r14d
    a8c9:	cmp    DWORD PTR [rsp-0x8],r14d
    a8ce:	je     a943 <c_run_7.isra.0+0x1b3>
    a8d0:	mov    rdi,QWORD PTR [rbp+0x18]
    a8d4:	mov    rsi,QWORD PTR [rbp+0x28]
    a8d8:	jmp    a810 <c_run_7.isra.0+0x80>
    a8dd:	nop    DWORD PTR [rax]
    a8e0:	mov    r14d,ebx
    a8e3:	xor    esi,esi
    a8e5:	vxorpd xmm0,xmm0,xmm0
    a8e9:	cmp    r14d,0x3
    a8ed:	jne    a879 <c_run_7.isra.0+0xe9>
    a8ef:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    a8f4:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    a8f9:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x8]
    a8ff:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x8]
    a905:	vaddsd xmm1,xmm1,xmm2
    a909:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x10]
    a90f:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x10]
    a915:	vaddsd xmm1,xmm1,xmm2
    a919:	vaddsd xmm0,xmm0,xmm1
    a91d:	jmp    a8a0 <c_run_7.isra.0+0x110>
    a91f:	nop
    a920:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    a925:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    a92a:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x8]
    a930:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x8]
    a936:	vaddsd xmm1,xmm1,xmm2
    a93a:	vaddsd xmm0,xmm0,xmm1
    a93e:	jmp    a8a0 <c_run_7.isra.0+0x110>
    a943:	vzeroupper
    a946:	lea    rsp,[rbp-0x28]
    a94a:	pop    rbx
    a94b:	pop    r12
    a94d:	pop    r13
    a94f:	pop    r14
    a951:	pop    r15
    a953:	pop    rbp
    a954:	ret
    a955:	mov    rcx,QWORD PTR [rsp-0x10]
    a95a:	mov    rsi,QWORD PTR [rbp+0x18]
    a95e:	mov    rdi,QWORD PTR [rbp+0x28]
    a962:	mov    r9d,DWORD PTR [rsp-0x8]
    a967:	lea    r10d,[rax+0x1]
    a96b:	cmp    r9d,r10d
    a96e:	je     a946 <c_run_7.isra.0+0x1b6>
    a970:	add    eax,0x2
    a973:	cmp    r9d,eax
    a976:	je     a946 <c_run_7.isra.0+0x1b6>
    a978:	jmp    a967 <c_run_7.isra.0+0x1d7>
    a97a:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_8.isra.0>:
    9c50:	push   rbp
    9c51:	mov    r11d,edi
    9c54:	mov    rbp,rsp
    9c57:	push   r15
    9c59:	push   r14
    9c5b:	push   r13
    9c5d:	push   r12
    9c5f:	push   rbx
    9c60:	and    rsp,0xffffffffffffffe0
    9c64:	sub    rsp,0x40
    9c68:	mov    rdi,QWORD PTR [rbp+0x20]
    9c6c:	mov    QWORD PTR [rsp+0x38],r8
    9c71:	test   edx,edx
    9c73:	je     9de2 <c_run_8.isra.0+0x192>
    9c79:	mov    eax,esi
    9c7b:	mov    DWORD PTR [rsp+0x1c],edx
    9c7f:	mov    DWORD PTR [rsp+0x18],r11d
    9c84:	mov    r10,r9
    9c87:	mov    r15,rax
    9c8a:	xor    r12d,r12d
    9c8d:	shl    rax,0x3
    9c91:	lea    ebx,[r15-0x4]
    9c95:	mov    QWORD PTR [rsp+0x20],rax
    9c9a:	mov    eax,r11d
    9c9d:	lea    r14,[r9+rax*8]
    9ca1:	mov    eax,ebx
    9ca3:	and    eax,0xfffffffc
    9ca6:	add    eax,0x4
    9ca9:	mov    r13,r14
    9cac:	mov    r14,rcx
    9caf:	mov    edx,r15d
    9cb2:	sub    edx,eax
    9cb4:	mov    DWORD PTR [rsp+0x2c],eax
    9cb8:	mov    DWORD PTR [rsp+0x28],edx
    9cbc:	nop    DWORD PTR [rax+0x0]
    9cc0:	mov    rax,QWORD PTR [rsp+0x38]
    9cc5:	mov    rdx,QWORD PTR [rbp+0x10]
    9cc9:	mov    rsi,QWORD PTR [rbp+0x18]
    9ccd:	mov    rcx,QWORD PTR [rbp+0x28]
    9cd1:	mov    rdx,QWORD PTR [rsp+0x20]
    9cd6:	xor    esi,esi
    9cd8:	mov    QWORD PTR [rsp+0x30],r10
    9cdd:	call   2bd0 <memset@plt>
    9ce2:	mov    r10,QWORD PTR [rsp+0x30]
    9ce7:	mov    rdi,rax
    9cea:	mov    eax,DWORD PTR [rsp+0x18]
    9cee:	test   eax,eax
    9cf0:	je     9dc3 <c_run_8.isra.0+0x173>
    9cf6:	mov    rax,r10
    9cf9:	xor    edx,edx
    9cfb:	vxorpd xmm3,xmm3,xmm3
    9cff:	jmp    9d30 <c_run_8.isra.0+0xe0>
    9d01:	nop    WORD PTR [rax+rax*1+0x0]
    9d0a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9d15:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9d20:	add    rax,0x8
    9d24:	add    edx,r15d
    9d27:	cmp    r13,rax
    9d2a:	je     9dc0 <c_run_8.isra.0+0x170>
    9d30:	vmovsd xmm1,QWORD PTR [rax]
    9d34:	vcomisd xmm1,xmm3
    9d38:	je     9d20 <c_run_8.isra.0+0xd0>
    9d3a:	mov    ecx,edx
    9d3c:	lea    rsi,[r14+rcx*8]
    9d40:	test   ebx,ebx
    9d42:	js     9e00 <c_run_8.isra.0+0x1b0>
    9d48:	vbroadcastsd ymm2,xmm1
    9d4d:	xor    ecx,ecx
    9d4f:	nop    WORD PTR [rax+rax*1+0x0]
    9d55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9d60:	vmulpd ymm0,ymm2,YMMWORD PTR [rsi+rcx*8]
    9d65:	vaddpd ymm0,ymm0,YMMWORD PTR [rdi+rcx*8]
    9d6a:	vmovupd YMMWORD PTR [rdi+rcx*8],ymm0
    9d6f:	add    rcx,0x4
    9d73:	cmp    ebx,ecx
    9d75:	jge    9d60 <c_run_8.isra.0+0x110>
    9d77:	mov    r8d,DWORD PTR [rsp+0x28]
    9d7c:	mov    ecx,DWORD PTR [rsp+0x2c]
    9d80:	cmp    r8d,0x3
    9d84:	je     9e0f <c_run_8.isra.0+0x1bf>
    9d8a:	cmp    r8d,0x2
    9d8e:	je     9e50 <c_run_8.isra.0+0x200>
    9d94:	cmp    r8d,0x1
    9d98:	jne    9d20 <c_run_8.isra.0+0xd0>
    9d9a:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    9d9f:	add    rax,0x8
    9da3:	add    edx,r15d
    9da6:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*8]
    9dab:	vmovsd QWORD PTR [rdi+rcx*8],xmm1
    9db0:	cmp    r13,rax
    9db3:	jne    9d30 <c_run_8.isra.0+0xe0>
    9db9:	nop    DWORD PTR [rax+0x0]
    9dc0:	vzeroupper
    9dc3:	mov    rax,QWORD PTR [rsp+0x38]
    9dc8:	mov    rdx,QWORD PTR [rbp+0x10]
    9dcc:	mov    rsi,QWORD PTR [rbp+0x18]
    9dd0:	mov    rcx,QWORD PTR [rbp+0x28]
    9dd4:	inc    r12d
    9dd7:	cmp    r12d,DWORD PTR [rsp+0x1c]
    9ddc:	jne    9cc0 <c_run_8.isra.0+0x70>
    9de2:	lea    rsp,[rbp-0x28]
    9de6:	pop    rbx
    9de7:	pop    r12
    9de9:	pop    r13
    9deb:	pop    r14
    9ded:	pop    r15
    9def:	pop    rbp
    9df0:	ret
    9df1:	nop    DWORD PTR [rax+0x0]
    9df5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9e00:	mov    r8d,r15d
    9e03:	xor    ecx,ecx
    9e05:	cmp    r8d,0x3
    9e09:	jne    9d8a <c_run_8.isra.0+0x13a>
    9e0f:	shl    rcx,0x3
    9e13:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1]
    9e18:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1]
    9e1d:	vmovsd QWORD PTR [rdi+rcx*1],xmm0
    9e22:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1+0x8]
    9e28:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1+0x8]
    9e2e:	vmovsd QWORD PTR [rdi+rcx*1+0x8],xmm0
    9e34:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*1+0x10]
    9e3a:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*1+0x10]
    9e40:	vmovsd QWORD PTR [rdi+rcx*1+0x10],xmm1
    9e46:	jmp    9d20 <c_run_8.isra.0+0xd0>
    9e4b:	nop    DWORD PTR [rax+rax*1+0x0]
    9e50:	shl    rcx,0x3
    9e54:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1]
    9e59:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1]
    9e5e:	vmovsd QWORD PTR [rdi+rcx*1],xmm0
    9e63:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*1+0x8]
    9e69:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*1+0x8]
    9e6f:	vmovsd QWORD PTR [rdi+rcx*1+0x8],xmm1
    9e75:	jmp    9d20 <c_run_8.isra.0+0xd0>
    9e7a:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_9.isra.0>:
    a4a0:	push   rbp
    a4a1:	mov    rbp,rsp
    a4a4:	push   r15
    a4a6:	push   r14
    a4a8:	push   r13
    a4aa:	push   r12
    a4ac:	push   rbx
    a4ad:	and    rsp,0xffffffffffffffe0
    a4b1:	mov    DWORD PTR [rsp-0x10],esi
    a4b5:	test   esi,esi
    a4b7:	je     a75f <c_run_9.isra.0+0x2bf>
    a4bd:	mov    ebx,edi
    a4bf:	mov    r15,rcx
    a4c2:	mov    rax,QWORD PTR [rbp+0x10]
    a4c6:	mov    rdi,QWORD PTR [rbp+0x18]
    a4ca:	mov    rcx,QWORD PTR [rbp+0x20]
    a4ce:	mov    r11,rdx
    a4d1:	test   ebx,ebx
    a4d3:	je     a765 <c_run_9.isra.0+0x2c5>
    a4d9:	lea    eax,[rbx-0x8]
    a4dc:	lea    edx,[rbx-0x4]
    a4df:	mov    r10d,ebx
    a4e2:	mov    ecx,0x4
    a4e7:	and    eax,0xfffffffc
    a4ea:	mov    QWORD PTR [rsp-0x28],r15
    a4ef:	vxorpd xmm0,xmm0,xmm0
    a4f3:	add    eax,0x8
    a4f6:	shl    r10,0x3
    a4fa:	cmp    edx,0x3
    a4fd:	lea    r12,[r8+r10*1]
    a501:	cmovle eax,ecx
    a504:	xor    r13d,r13d
    a507:	mov    r14d,eax
    a50a:	lea    ecx,[rax+0x1]
    a50d:	mov    edi,ebx
    a50f:	sub    edi,eax
    a511:	shl    r14,0x3
    a515:	vmovq  xmm8,rcx
    a51a:	lea    rcx,[r9+r14*1]
    a51e:	add    eax,0x2
    a521:	mov    QWORD PTR [rsp-0x8],rcx
    a526:	vmovq  xmm6,rax
    a52b:	nop    DWORD PTR [rax+rax*1+0x0]
    a530:	mov    DWORD PTR [rsp-0xc],r13d
    a535:	mov    QWORD PTR [rsp-0x18],r11
    a53a:	mov    QWORD PTR [rsp-0x20],r8
    a53f:	mov    rcx,r8
    a542:	mov    rax,r11
    a545:	vxorpd xmm2,xmm2,xmm2
    a549:	vmovq  r8,xmm8
    a54e:	xchg   ax,ax
    a550:	vmovsd xmm3,QWORD PTR [rcx]
    a554:	mov    rsi,rax
    a557:	test   edx,edx
    a559:	js     a5f0 <c_run_9.isra.0+0x150>
    a55f:	vmovupd ymm4,YMMWORD PTR [r9]
    a564:	vmulpd ymm1,ymm4,YMMWORD PTR [rax]
    a568:	cmp    edx,0x3
    a56b:	jle    a597 <c_run_9.isra.0+0xf7>
    a56d:	mov    esi,0x4
    a572:	nop    DWORD PTR [rax]
    a575:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a580:	vmovupd ymm7,YMMWORD PTR [rax+rsi*8]
    a585:	vmulpd ymm5,ymm7,YMMWORD PTR [r9+rsi*8]
    a58b:	add    rsi,0x4
    a58f:	vaddpd ymm1,ymm1,ymm5
    a593:	cmp    edx,esi
    a595:	jge    a580 <c_run_9.isra.0+0xe0>
    a597:	vmovapd xmm5,xmm1
    a59b:	vextractf64x2 xmm1,ymm1,0x1
    a5a2:	vaddpd xmm5,xmm5,xmm1
    a5a6:	vunpckhpd xmm1,xmm5,xmm5
    a5aa:	vaddsd xmm7,xmm5,xmm1
    a5ae:	cmp    edi,0x3
    a5b1:	je     a680 <c_run_9.isra.0+0x1e0>
    a5b7:	cmp    edi,0x2
    a5ba:	je     a6f0 <c_run_9.isra.0+0x250>
    a5c0:	cmp    edi,0x1
    a5c3:	je     a73f <c_run_9.isra.0+0x29f>
    a5c9:	vmulsd xmm3,xmm7,xmm3
    a5cd:	add    rcx,0x8
    a5d1:	vaddsd xmm2,xmm2,xmm3
    a5d5:	cmp    rcx,r12
    a5d8:	je     a62e <c_run_9.isra.0+0x18e>
    a5da:	vmovsd xmm3,QWORD PTR [rcx]
    a5de:	add    rax,r10
    a5e1:	jmp    a564 <c_run_9.isra.0+0xc4>
    a5e6:	cs nop WORD PTR [rax+rax*1+0x0]
    a5f0:	cmp    ebx,0x3
    a5f3:	je     a6d0 <c_run_9.isra.0+0x230>
    a5f9:	cmp    ebx,0x2
    a5fc:	je     a730 <c_run_9.isra.0+0x290>
    a602:	mov    r11,r9
    a605:	vxorpd xmm7,xmm7,xmm7
    a609:	vmovsd xmm1,QWORD PTR [rsi]
    a60d:	vmulsd xmm1,xmm1,QWORD PTR [r11]
    a612:	vaddsd xmm4,xmm1,xmm7
    a616:	vmulsd xmm3,xmm4,xmm3
    a61a:	add    rcx,0x8
    a61e:	add    rax,r10
    a621:	vaddsd xmm2,xmm2,xmm3
    a625:	cmp    r12,rcx
    a628:	jne    a550 <c_run_9.isra.0+0xb0>
    a62e:	mov    r13d,DWORD PTR [rsp-0xc]
    a633:	mov    r11,QWORD PTR [rsp-0x18]
    a638:	mov    r8,QWORD PTR [rsp-0x20]
    a63d:	mov    rax,QWORD PTR [rsp-0x28]
    a642:	mov    rcx,QWORD PTR [rbp+0x10]
    a646:	mov    rsi,QWORD PTR [rbp+0x18]
    a64a:	mov    r15,QWORD PTR [rbp+0x20]
    a64e:	vaddsd xmm0,xmm0,xmm2
    a652:	inc    r13d
    a655:	cmp    DWORD PTR [rsp-0x10],r13d
    a65a:	je     a74d <c_run_9.isra.0+0x2ad>
    a660:	mov    rcx,QWORD PTR [rbp+0x10]
    a664:	mov    rsi,QWORD PTR [rbp+0x18]
    a668:	mov    r15,QWORD PTR [rbp+0x20]
    a66c:	jmp    a530 <c_run_9.isra.0+0x90>
    a671:	nop    DWORD PTR [rax+0x0]
    a675:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a680:	mov    r15,QWORD PTR [rsp-0x8]
    a685:	vmovq  r11,xmm6
    a68a:	lea    r13,[r8*8+0x0]
    a692:	lea    rsi,[rax+r14*1]
    a696:	lea    r11,[r11*8+0x0]
    a69e:	vmovsd xmm1,QWORD PTR [rax+r13*1]
    a6a4:	vmulsd xmm1,xmm1,QWORD PTR [r9+r13*1]
    a6aa:	vmovsd xmm4,QWORD PTR [rsi]
    a6ae:	vmulsd xmm4,xmm4,QWORD PTR [r15]
    a6b3:	vaddsd xmm1,xmm1,xmm4
    a6b7:	vmovsd xmm4,QWORD PTR [rax+r11*1]
    a6bd:	vmulsd xmm4,xmm4,QWORD PTR [r9+r11*1]
    a6c3:	vaddsd xmm1,xmm1,xmm4
    a6c7:	vaddsd xmm4,xmm1,xmm7
    a6cb:	jmp    a616 <c_run_9.isra.0+0x176>
    a6d0:	mov    r15,r9
    a6d3:	mov    r13d,0x8
    a6d9:	mov    r11d,0x10
    a6df:	vxorpd xmm7,xmm7,xmm7
    a6e3:	jmp    a69e <c_run_9.isra.0+0x1fe>
    a6e5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a6f0:	mov    r13,QWORD PTR [rsp-0x8]
    a6f5:	lea    rsi,[rax+r14*1]
    a6f9:	lea    r11,[r8*8+0x0]
    a701:	vmovsd xmm1,QWORD PTR [rax+r11*1]
    a707:	vmulsd xmm1,xmm1,QWORD PTR [r9+r11*1]
    a70d:	vmovsd xmm4,QWORD PTR [rsi]
    a711:	vmulsd xmm4,xmm4,QWORD PTR [r13+0x0]
    a717:	vaddsd xmm1,xmm1,xmm4
    a71b:	vaddsd xmm4,xmm1,xmm7
    a71f:	jmp    a616 <c_run_9.isra.0+0x176>
    a724:	nop
    a725:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a730:	mov    r13,r9
    a733:	mov    r11d,0x8
    a739:	vxorpd xmm7,xmm7,xmm7
    a73d:	jmp    a701 <c_run_9.isra.0+0x261>
    a73f:	mov    r11,QWORD PTR [rsp-0x8]
    a744:	lea    rsi,[rax+r14*1]
    a748:	jmp    a609 <c_run_9.isra.0+0x169>
    a74d:	vzeroupper
    a750:	lea    rsp,[rbp-0x28]
    a754:	pop    rbx
    a755:	pop    r12
    a757:	pop    r13
    a759:	pop    r14
    a75b:	pop    r15
    a75d:	pop    rbp
    a75e:	ret
    a75f:	vxorpd xmm0,xmm0,xmm0
    a763:	jmp    a750 <c_run_9.isra.0+0x2b0>
    a765:	mov    rax,QWORD PTR [rbp+0x10]
    a769:	mov    rdx,QWORD PTR [rbp+0x18]
    a76d:	mov    rcx,QWORD PTR [rbp+0x20]
    a771:	mov    esi,DWORD PTR [rsp-0x10]
    a775:	lea    edi,[rbx+0x1]
    a778:	cmp    esi,edi
    a77a:	je     a75f <c_run_9.isra.0+0x2bf>
    a77c:	add    ebx,0x2
    a77f:	cmp    esi,ebx
    a781:	je     a75f <c_run_9.isra.0+0x2bf>
    a783:	jmp    a775 <c_run_9.isra.0+0x2d5>
    a785:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<memcpy@plt>:
    30f0:	jmp    QWORD PTR [rip+0x3f1da]        # 422d0 <memcpy@GLIBC_2.14>
    30f6:	push   0x5a
    30fb:	jmp    2b40 <_init+0x28>


<memset@plt>:
    2bd0:	jmp    QWORD PTR [rip+0x3f46a]        # 42040 <memset@GLIBC_2.2.5>
    2bd6:	push   0x8
    2bdb:	jmp    2b40 <_init+0x28>

