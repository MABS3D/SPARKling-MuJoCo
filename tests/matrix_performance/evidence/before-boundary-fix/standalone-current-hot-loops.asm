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
    4e65:	mov    r12,QWORD PTR [rbp+0x20]
    4e69:	mov    DWORD PTR [rsp-0x8],edi
    4e6d:	mov    DWORD PTR [rsp-0x20],esi
    4e71:	mov    DWORD PTR [rsp-0xc],edx
    4e75:	mov    r14,QWORD PTR [rbp+0x28]
    4e79:	test   edx,edx
    4e7b:	je     4f40 <bench_ada__run_10.isra.0+0xf0>
    4e81:	mov    ebx,edi
    4e83:	mov    rax,rcx
    4e86:	mov    rdi,r8
    4e89:	mov    r15,QWORD PTR [rbp+0x18]
    4e8d:	lea    r11d,[rbx-0x1]
    4e91:	mov    ecx,ebx
    4e93:	mov    r8,r9
    4e96:	mov    rbx,QWORD PTR [rbp+0x10]
    4e9a:	mov    DWORD PTR [rsp-0x34],r11d
    4e9f:	lea    edx,[rsi-0x1]
    4ea2:	cmp    edx,0xffffffff
    4ea5:	je     5730 <bench_ada__run_10.isra.0+0x8e0>
    4eab:	cmp    r11d,0xffffffff
    4eaf:	je     5730 <bench_ada__run_10.isra.0+0x8e0>
    4eb5:	mov    r13d,esi
    4eb8:	mov    esi,edx
    4eba:	mov    DWORD PTR [rsp-0x10],0x1
    4ec2:	mov    QWORD PTR [rsp-0x30],rsi
    4ec7:	mov    esi,ecx
    4ec9:	lea    rcx,[rip+0x2c770]        # 31640 <_fini+0x14>
    4ed0:	lea    r15,[r13*8+0x0]
    4ed8:	vmovq  xmm2,rcx
    4edd:	mov    ecx,r11d
    4ee0:	mov    QWORD PTR [rsp],rsi
    4ee4:	lea    rsi,[rsi*8+0x0]
    4eec:	mov    QWORD PTR [rsp-0x18],rcx
    4ef1:	vmovq  xmm4,rsi
    4ef6:	mov    rbx,r13
    4ef9:	mov    rsi,rdi
    4efc:	mov    rdi,r14
    4eff:	mov    r14,r12
    4f02:	cmp    DWORD PTR [rsp-0x8],0x40
    4f07:	ja     57e5 <bench_ada__run_10.isra.0+0x995>
    4f0d:	mov    rdx,QWORD PTR [rsp]
    4f11:	vmovq  rcx,xmm2
    4f16:	movsxd rdx,DWORD PTR [rcx+rdx*4]
    4f1a:	add    rdx,rcx
    4f1d:	jmp    rdx
    4f1f:	mov    ecx,ebx
    4f21:	mov    r15,QWORD PTR [rsp-0x50]
    4f26:	mov    rbx,QWORD PTR [rsp-0x28]
    4f2b:	mov    rdx,QWORD PTR [rbp+0x10]
    4f2f:	mov    r11,QWORD PTR [rbp+0x18]
    4f33:	cmp    DWORD PTR [rsp-0xc],ecx
    4f37:	jne    52a1 <bench_ada__run_10.isra.0+0x451>
    4f3d:	vzeroupper
    4f40:	lea    rsp,[rbp-0x28]
    4f44:	pop    rbx
    4f45:	pop    r12
    4f47:	pop    r13
    4f49:	pop    r14
    4f4b:	pop    r15
    4f4d:	pop    rbp
    4f4e:	ret
    4f4f:	imul   rdx,rbx
    4f53:	mov    QWORD PTR [rsp-0x70],rsi
    4f58:	mov    QWORD PTR [rsp-0x78],r8
    4f5d:	mov    QWORD PTR [rbp+0x28],rdi
    4f61:	vmovq  r9,xmm4
    4f66:	mov    r13,rax
    4f69:	mov    r12,r14
    4f6c:	xor    r11d,r11d
    4f6f:	shr    rcx,0x3
    4f73:	vmovq  xmm6,rdx
    4f78:	mov    rdx,rbx
    4f7b:	shl    rdx,0x5
    4f7f:	sub    r9,0x8
    4f83:	mov    QWORD PTR [rsp-0x28],rcx
    4f88:	lea    rcx,[rbx+rbx*4]
    4f8c:	mov    QWORD PTR [rsp-0x40],rdx
    4f91:	vmovq  xmm5,r9
    4f96:	mov    rdx,0xffffffffffffffff
    4f9d:	lea    r9,[rcx*8+0x0]
    4fa5:	vmovq  rsi,xmm5
    4faa:	inc    rdx
    4fad:	lea    rcx,[rsi+r12*1]
    4fb1:	cmp    rcx,r13
    4fb4:	jb     4fc9 <bench_ada__run_10.isra.0+0x179>
    4fb6:	vmovq  rsi,xmm6
    4fbb:	lea    rcx,[r13+rsi*8+0x0]
    4fc0:	cmp    rcx,r12
    4fc3:	jae    5505 <bench_ada__run_10.isra.0+0x6b5>
    4fc9:	mov    rsi,QWORD PTR [rsp-0x40]
    4fce:	mov    QWORD PTR [rsp-0x48],r12
    4fd3:	mov    QWORD PTR [rsp-0x50],rdx
    4fd8:	mov    QWORD PTR [rsp-0x58],r11
    4fdd:	mov    QWORD PTR [rsp-0x60],rax
    4fe2:	mov    QWORD PTR [rsp-0x68],rbx
    4fe7:	mov    rdi,r12
    4fea:	xor    ecx,ecx
    4fec:	lea    r8,[rsi+r13*1]
    4ff0:	mov    rsi,r13
    4ff3:	lea    rbx,[r8+r15*2]
    4ff7:	vmovsd xmm1,QWORD PTR [r8]
    4ffc:	vmovhpd xmm1,xmm1,QWORD PTR [r8+r15*1]
    5002:	lea    rdx,[rsi+r15*2]
    5006:	vmovsd xmm0,QWORD PTR [rbx]
    500a:	vmovhpd xmm0,xmm0,QWORD PTR [rbx+r15*1]
    5010:	lea    r12,[rdx+r15*1]
    5014:	lea    r10,[rbx+r15*1]
    5018:	inc    rcx
    501b:	add    rdi,0x40
    501f:	lea    r8,[r10+r9*1]
    5023:	vinsertf64x2 ymm1,ymm1,xmm0,0x1
    502a:	vmovsd xmm0,QWORD PTR [rdx]
    502e:	vmovhpd xmm3,xmm0,QWORD PTR [rdx+r15*1]
    5034:	vmovsd xmm0,QWORD PTR [rsi]
    5038:	vmovhpd xmm0,xmm0,QWORD PTR [rsi+r15*1]
    503e:	lea    rsi,[r12+r9*1]
    5042:	vinsertf64x2 ymm0,ymm0,xmm3,0x1
    5049:	vinsertf64x4 zmm0,zmm0,ymm1,0x1
    5050:	vmovupd ZMMWORD PTR [rdi-0x40],zmm0
    5057:	cmp    rcx,QWORD PTR [rsp-0x28]
    505c:	jb     4ff3 <bench_ada__run_10.isra.0+0x1a3>
    505e:	mov    rsi,QWORD PTR [rsp-0x28]
    5063:	mov    r12,QWORD PTR [rsp-0x48]
    5068:	mov    rdx,QWORD PTR [rsp-0x50]
    506d:	mov    r11,QWORD PTR [rsp-0x58]
    5072:	mov    rax,QWORD PTR [rsp-0x60]
    5077:	mov    rbx,QWORD PTR [rsp-0x68]
    507c:	shl    rsi,0x3
    5080:	cmp    QWORD PTR [rsp],rsi
    5084:	je     5154 <bench_ada__run_10.isra.0+0x304>
    508a:	mov    rdi,QWORD PTR [rsp-0x18]
    508f:	lea    rcx,[rsi-0x1]
    5093:	sub    rdi,rsi
    5096:	cmp    rdi,0x2
    509a:	jbe    50e7 <bench_ada__run_10.isra.0+0x297>
    509c:	mov    r8,rbx
    509f:	inc    rdi
    50a2:	imul   r8,rsi
    50a6:	add    rsi,r11
    50a9:	add    r8,rdx
    50ac:	lea    r10,[rax+r8*8]
    50b0:	lea    r8,[r10+r15*1]
    50b4:	vmovsd xmm0,QWORD PTR [r8+r15*1]
    50ba:	vmovhpd xmm3,xmm0,QWORD PTR [r8+r15*2]
    50c0:	vmovsd xmm0,QWORD PTR [r10]
    50c5:	vmovhpd xmm0,xmm0,QWORD PTR [r8]
    50ca:	vinsertf64x2 ymm0,ymm0,xmm3,0x1
    50d1:	vmovupd YMMWORD PTR [r14+rsi*8],ymm0
    50d7:	mov    rsi,rdi
    50da:	and    rsi,0xfffffffffffffffc
    50de:	and    dil,0x3
    50e2:	je     5154 <bench_ada__run_10.isra.0+0x304>
    50e4:	add    rcx,rsi
    50e7:	lea    rdi,[rcx+0x1]
    50eb:	mov    rsi,rbx
    50ee:	mov    r10,QWORD PTR [rsp-0x18]
    50f3:	imul   rsi,rdi
    50f7:	add    rsi,rdx
    50fa:	vmovsd xmm0,QWORD PTR [rax+rsi*8]
    50ff:	mov    rsi,QWORD PTR [rsp]
    5103:	imul   rsi,rdx
    5107:	lea    r8,[rsi+rdi*1]
    510b:	vmovsd QWORD PTR [r14+r8*8],xmm0
    5111:	cmp    r10,rdi
    5114:	je     5154 <bench_ada__run_10.isra.0+0x304>
    5116:	lea    r8,[rcx+0x2]
    511a:	mov    rdi,rbx
    511d:	imul   rdi,r8
    5121:	add    rdi,rdx
    5124:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    5129:	lea    rdi,[rsi+r8*1]
    512d:	vmovsd QWORD PTR [r14+rdi*8],xmm0
    5133:	cmp    r10,r8
    5136:	je     5154 <bench_ada__run_10.isra.0+0x304>
    5138:	add    rcx,0x3
    513c:	mov    rdi,rbx
    513f:	imul   rdi,rcx
    5143:	add    rsi,rcx
    5146:	add    rdi,rdx
    5149:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    514e:	vmovsd QWORD PTR [r14+rsi*8],xmm0
    5154:	vmovq  rsi,xmm4
    5159:	add    r11,QWORD PTR [rsp]
    515d:	add    r13,0x8
    5161:	add    r12,rsi
    5164:	cmp    rdx,QWORD PTR [rsp-0x30]
    5169:	jne    4fa5 <bench_ada__run_10.isra.0+0x155>
    516f:	mov    rsi,QWORD PTR [rsp-0x70]
    5174:	mov    r8,QWORD PTR [rsp-0x78]
    5179:	mov    rdi,QWORD PTR [rbp+0x28]
    517d:	mov    rcx,QWORD PTR [rbp+0x10]
    5181:	mov    rdx,QWORD PTR [rbp+0x18]
    5185:	mov    ecx,DWORD PTR [rsp-0x10]
    5189:	cmp    DWORD PTR [rsp-0xc],ecx
    518d:	je     4f3d <bench_ada__run_10.isra.0+0xed>
    5193:	inc    ecx
    5195:	mov    rdx,QWORD PTR [rbp+0x18]
    5199:	mov    DWORD PTR [rsp-0x10],ecx
    519d:	mov    rcx,QWORD PTR [rbp+0x10]
    51a1:	mov    edx,DWORD PTR [rsp-0x20]
    51a5:	mov    rcx,QWORD PTR [rsp]
    51a9:	cmp    DWORD PTR [rsp-0x8],edx
    51ad:	lea    rdx,[rcx-0x1]
    51b1:	je     4f4f <bench_ada__run_10.isra.0+0xff>
    51b7:	imul   rdx,rbx
    51bb:	mov    QWORD PTR [rsp-0x28],rsi
    51c0:	mov    QWORD PTR [rsp-0x40],r8
    51c5:	mov    QWORD PTR [rbp+0x28],rdi
    51c9:	mov    r12,rax
    51cc:	mov    r10,r14
    51cf:	xor    r11d,r11d
    51d2:	vmovq  r8,xmm4
    51d7:	shr    rcx,1
    51da:	vmovq  xmm1,rdx
    51df:	vmovq  rdx,xmm4
    51e4:	sub    rdx,0x8
    51e8:	mov    r13,rcx
    51eb:	vmovq  rsi,xmm1
    51f0:	mov    rdi,rdx
    51f3:	xchg   ax,ax
    51f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5200:	lea    rdx,[rdi+r10*1]
    5204:	cmp    rdx,r12
    5207:	jb     5216 <bench_ada__run_10.isra.0+0x3c6>
    5209:	lea    rdx,[r12+rsi*8]
    520d:	cmp    rdx,r10
    5210:	jae    54d7 <bench_ada__run_10.isra.0+0x687>
    5216:	mov    r9,r10
    5219:	mov    rdx,r12
    521c:	xor    ecx,ecx
    521e:	vmovsd xmm0,QWORD PTR [rdx]
    5222:	vmovhpd xmm0,xmm0,QWORD PTR [r15+rdx*1]
    5228:	inc    rcx
    522b:	lea    rdx,[rdx+r15*2]
    522f:	add    r9,0x10
    5233:	vmovupd XMMWORD PTR [r9-0x10],xmm0
    5239:	cmp    rcx,r13
    523c:	jb     521e <bench_ada__run_10.isra.0+0x3ce>
    523e:	lea    rcx,[r13+r13*1+0x0]
    5243:	cmp    QWORD PTR [rsp],rcx
    5247:	je     5269 <bench_ada__run_10.isra.0+0x419>
    5249:	mov    rdx,rbx
    524c:	imul   rdx,rcx
    5250:	add    rdx,r11
    5253:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    5258:	mov    rdx,QWORD PTR [rsp]
    525c:	imul   rdx,r11
    5260:	add    rdx,rcx
    5263:	vmovsd QWORD PTR [r14+rdx*8],xmm0
    5269:	inc    r11
    526c:	add    r10,r8
    526f:	add    r12,0x8
    5273:	cmp    rbx,r11
    5276:	jne    5200 <bench_ada__run_10.isra.0+0x3b0>
    5278:	vmovq  xmm4,r8
    527d:	mov    rsi,QWORD PTR [rsp-0x28]
    5282:	mov    rdi,QWORD PTR [rbp+0x28]
    5286:	mov    r8,QWORD PTR [rsp-0x40]
    528b:	mov    rcx,QWORD PTR [rbp+0x10]
    528f:	mov    rdx,QWORD PTR [rbp+0x18]
    5293:	mov    ecx,DWORD PTR [rsp-0x10]
    5297:	cmp    DWORD PTR [rsp-0xc],ecx
    529b:	je     4f3d <bench_ada__run_10.isra.0+0xed>
    52a1:	inc    ecx
    52a3:	mov    rdx,QWORD PTR [rbp+0x18]
    52a7:	mov    DWORD PTR [rsp-0x10],ecx
    52ab:	mov    rcx,QWORD PTR [rbp+0x10]
    52af:	jmp    4f02 <bench_ada__run_10.isra.0+0xb2>
    52b4:	mov    rcx,r15
    52b7:	shr    rcx,0x3
    52bb:	lea    r10,[rcx+rcx*4]
    52bf:	mov    r9d,DWORD PTR [rsp-0x8]
    52c4:	mov    r11d,DWORD PTR [rsp-0x34]
    52c9:	mov    r12,rsi
    52cc:	vmovq  xmm7,r10
    52d1:	xor    edx,edx
    52d3:	lea    rsi,[rcx+rcx*2]
    52d7:	imul   r10,rcx,0x6
    52db:	vmovq  xmm3,r10
    52e0:	imul   r10,rcx,0x7
    52e4:	sar    r9d,1
    52e7:	vmovq  xmm1,r10
    52ec:	lea    r10,[rcx+rcx*8]
    52f0:	dec    r9d
    52f3:	vmovq  xmm5,r10
    52f8:	imul   r10,rcx,0xa
    52fc:	vmovq  xmm6,r10
    5301:	lea    r13,[rcx+rcx*1]
    5305:	vmovq  xmm8,r13
    530a:	mov    r13,rdi
    530d:	mov    rdi,QWORD PTR [rsp]
    5311:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    5316:	imul   rdi,rdx
    531a:	lea    r10,[r14+rdi*8]
    531e:	lea    rdi,[rcx+rdx*1]
    5322:	vmovsd QWORD PTR [r10],xmm0
    5327:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    532c:	vmovq  rdi,xmm8
    5331:	add    rdi,rdx
    5334:	vmovsd QWORD PTR [r10+0x8],xmm0
    533a:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    533f:	lea    rdi,[rsi+rdx*1]
    5343:	vmovsd QWORD PTR [r10+0x10],xmm0
    5349:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    534e:	vmovsd QWORD PTR [r10+0x18],xmm0
    5354:	cmp    r9d,0x1
    5358:	je     542d <bench_ada__run_10.isra.0+0x5dd>
    535e:	lea    rdi,[rdx+rcx*4]
    5362:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    5367:	vmovq  rdi,xmm7
    536c:	add    rdi,rdx
    536f:	vmovsd QWORD PTR [r10+0x20],xmm0
    5375:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    537a:	vmovsd QWORD PTR [r10+0x28],xmm0
    5380:	cmp    r9d,0x2
    5384:	je     542d <bench_ada__run_10.isra.0+0x5dd>
    538a:	vmovq  rdi,xmm3
    538f:	add    rdi,rdx
    5392:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    5397:	vmovq  rdi,xmm1
    539c:	add    rdi,rdx
    539f:	vmovsd QWORD PTR [r10+0x30],xmm0
    53a5:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    53aa:	vmovsd QWORD PTR [r10+0x38],xmm0
    53b0:	cmp    r9d,0x3
    53b4:	je     542d <bench_ada__run_10.isra.0+0x5dd>
    53b6:	lea    rdi,[rdx+rcx*8]
    53ba:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    53bf:	vmovq  rdi,xmm5
    53c4:	add    rdi,rdx
    53c7:	vmovsd QWORD PTR [r10+0x40],xmm0
    53cd:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    53d2:	vmovsd QWORD PTR [r10+0x48],xmm0
    53d8:	cmp    r9d,0x4
    53dc:	je     542d <bench_ada__run_10.isra.0+0x5dd>
    53de:	vmovq  rdi,xmm6
    53e3:	add    rdi,rdx
    53e6:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    53eb:	imul   rdi,rcx,0xb
    53ef:	add    rdi,rdx
    53f2:	vmovsd QWORD PTR [r10+0x50],xmm0
    53f8:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    53fd:	vmovsd QWORD PTR [r10+0x58],xmm0
    5403:	cmp    r9d,0x5
    5407:	je     542d <bench_ada__run_10.isra.0+0x5dd>
    5409:	imul   rdi,rcx,0xc
    540d:	add    rdi,rdx
    5410:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    5415:	imul   rdi,rcx,0xd
    5419:	add    rdi,rdx
    541c:	vmovsd QWORD PTR [r10+0x60],xmm0
    5422:	vmovsd xmm0,QWORD PTR [rax+rdi*8]
    5427:	vmovsd QWORD PTR [r10+0x68],xmm0
    542d:	test   BYTE PTR [rsp-0x8],0x1
    5432:	je     54c0 <bench_ada__run_10.isra.0+0x670>
    5438:	mov    r10,r11
    543b:	mov    rdi,r13
    543e:	imul   r10,rcx
    5442:	add    r10,rdx
    5445:	vmovsd xmm0,QWORD PTR [rax+r10*8]
    544b:	mov    r10,QWORD PTR [rsp]
    544f:	imul   r10,rdx
    5453:	inc    rdx
    5456:	add    r10,r11
    5459:	vmovsd QWORD PTR [r14+r10*8],xmm0
    545f:	cmp    rdx,rbx
    5462:	jne    5301 <bench_ada__run_10.isra.0+0x4b1>
    5468:	mov    rsi,r12
    546b:	jmp    528b <bench_ada__run_10.isra.0+0x43b>
    5470:	lea    r9,[rax+r15*1]
    5474:	mov    rcx,r14
    5477:	xor    edx,edx
    5479:	lea    r10,[r9+r15*1]
    547d:	nop    DWORD PTR [rax]
    5480:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    5485:	add    rcx,0x18
    5489:	vmovsd QWORD PTR [rcx-0x18],xmm0
    548e:	vmovsd xmm0,QWORD PTR [r9+rdx*8]
    5494:	vmovsd QWORD PTR [rcx-0x10],xmm0
    5499:	vmovsd xmm0,QWORD PTR [r10+rdx*8]
    549f:	inc    rdx
    54a2:	vmovsd QWORD PTR [rcx-0x8],xmm0
    54a7:	cmp    rdx,rbx
    54aa:	jne    5480 <bench_ada__run_10.isra.0+0x630>
    54ac:	jmp    528b <bench_ada__run_10.isra.0+0x43b>
    54b1:	nop    DWORD PTR [rax+0x0]
    54b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    54c0:	inc    rdx
    54c3:	cmp    rbx,rdx
    54c6:	jne    530d <bench_ada__run_10.isra.0+0x4bd>
    54cc:	mov    rsi,r12
    54cf:	mov    rdi,r13
    54d2:	jmp    528b <bench_ada__run_10.isra.0+0x43b>
    54d7:	mov    r9,QWORD PTR [rsp-0x18]
    54dc:	mov    rdx,0xffffffffffffffff
    54e3:	inc    rdx
    54e6:	mov    rcx,rbx
    54e9:	imul   rcx,rdx
    54ed:	add    rcx,r11
    54f0:	vmovsd xmm0,QWORD PTR [rax+rcx*8]
    54f5:	vmovsd QWORD PTR [r10+rdx*8],xmm0
    54fb:	cmp    r9,rdx
    54fe:	jne    54e3 <bench_ada__run_10.isra.0+0x693>
    5500:	jmp    5269 <bench_ada__run_10.isra.0+0x419>
    5505:	mov    rdi,QWORD PTR [rsp-0x18]
    550a:	mov    rcx,0xffffffffffffffff
    5511:	inc    rcx
    5514:	mov    rsi,rbx
    5517:	imul   rsi,rcx
    551b:	add    rsi,rdx
    551e:	vmovsd xmm0,QWORD PTR [rax+rsi*8]
    5523:	vmovsd QWORD PTR [r12+rcx*8],xmm0
    5529:	cmp    rdi,rcx
    552c:	jne    5511 <bench_ada__run_10.isra.0+0x6c1>
    552e:	jmp    5154 <bench_ada__run_10.isra.0+0x304>
    5533:	mov    r13,rbx
    5536:	mov    r9d,DWORD PTR [rsp-0x10]
    553b:	mov    r10,QWORD PTR [rbp+0x10]
    553f:	mov    r11,QWORD PTR [rbp+0x18]
    5543:	mov    ebx,DWORD PTR [rsp-0xc]
    5547:	mov    r12,r14
    554a:	mov    r14,rdi
    554d:	mov    rdi,rsi
    5550:	lea    rsi,[rax+r15*1]
    5554:	mov    rcx,r12
    5557:	xor    edx,edx
    5559:	nop    WORD PTR [rax+rax*1+0x0]
    555f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    556a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5575:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5580:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    5585:	add    rcx,0x10
    5589:	vmovsd QWORD PTR [rcx-0x10],xmm0
    558e:	vmovsd xmm0,QWORD PTR [rsi+rdx*8]
    5593:	inc    rdx
    5596:	vmovsd QWORD PTR [rcx-0x8],xmm0
    559b:	cmp    r13,rdx
    559e:	jne    5580 <bench_ada__run_10.isra.0+0x730>
    55a0:	cmp    ebx,r9d
    55a3:	je     4f3d <bench_ada__run_10.isra.0+0xed>
    55a9:	inc    r9d
    55ac:	jmp    5554 <bench_ada__run_10.isra.0+0x704>
    55ae:	mov    r12,r14
    55b1:	mov    r14,rdi
    55b4:	mov    rdi,rsi
    55b7:	lea    rsi,[rax+r15*1]
    55bb:	lea    r10,[rsi+r15*1]
    55bf:	mov    r13,rbx
    55c2:	mov    r11d,DWORD PTR [rsp-0x10]
    55c7:	mov    rbx,QWORD PTR [rbp+0x10]
    55cb:	lea    r9,[r15+r10*1]
    55cf:	mov    r15,QWORD PTR [rbp+0x18]
    55d3:	mov    rcx,r12
    55d6:	xor    edx,edx
    55d8:	nop    DWORD PTR [rax+rax*1+0x0]
    55e0:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    55e5:	add    rcx,0x20
    55e9:	vmovsd QWORD PTR [rcx-0x20],xmm0
    55ee:	vmovsd xmm0,QWORD PTR [rsi+rdx*8]
    55f3:	vmovsd QWORD PTR [rcx-0x18],xmm0
    55f8:	vmovsd xmm0,QWORD PTR [r10+rdx*8]
    55fe:	vmovsd QWORD PTR [rcx-0x10],xmm0
    5603:	vmovsd xmm0,QWORD PTR [r9+rdx*8]
    5609:	inc    rdx
    560c:	vmovsd QWORD PTR [rcx-0x8],xmm0
    5611:	cmp    r13,rdx
    5614:	jne    55e0 <bench_ada__run_10.isra.0+0x790>
    5616:	cmp    DWORD PTR [rsp-0xc],r11d
    561b:	je     4f3d <bench_ada__run_10.isra.0+0xed>
    5621:	inc    r11d
    5624:	jmp    55d3 <bench_ada__run_10.isra.0+0x783>
    5626:	lea    rcx,[rbx-0x8]
    562a:	lea    rdx,[r14-0x8]
    562e:	mov    QWORD PTR [rsp-0x28],rbx
    5633:	mov    QWORD PTR [rsp-0x50],r15
    5638:	sub    rdx,rax
    563b:	mov    r13,QWORD PTR [rbp+0x10]
    563f:	mov    r12,QWORD PTR [rbp+0x18]
    5643:	mov    ebx,DWORD PTR [rsp-0x10]
    5647:	mov    QWORD PTR [rsp-0x48],rdx
    564c:	mov    r9,r14
    564f:	sub    r9,rax
    5652:	shr    rcx,0x3
    5656:	inc    rcx
    5659:	lea    rdx,[rcx*8+0x0]
    5661:	mov    QWORD PTR [rsp-0x40],rdx
    5666:	cmp    QWORD PTR [rsp-0x48],0x30
    566c:	jbe    5765 <bench_ada__run_10.isra.0+0x915>
    5672:	mov    rdx,rax
    5675:	xor    r10d,r10d
    5678:	cmp    QWORD PTR [rsp-0x30],0x6
    567e:	jbe    5797 <bench_ada__run_10.isra.0+0x947>
    5684:	nop    WORD PTR [rax+rax*1+0x0]
    568a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5695:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    56a0:	vmovupd zmm0,ZMMWORD PTR [rdx]
    56a6:	inc    r10
    56a9:	vmovupd ZMMWORD PTR [r9+rdx*1],zmm0
    56b0:	add    rdx,0x40
    56b4:	cmp    r10,rcx
    56b7:	jb     56a0 <bench_ada__run_10.isra.0+0x850>
    56b9:	mov    r11,QWORD PTR [rsp-0x40]
    56be:	mov    rdx,r11
    56c1:	cmp    r11,QWORD PTR [rsp-0x28]
    56c6:	je     4f1f <bench_ada__run_10.isra.0+0xcf>
    56cc:	vmovdqa xmm3,XMMWORD PTR [rip+0x2e7dc]        # 33eb0 <system__secondary_stack__invalid_memory_size+0xa8>
    56d4:	mov    r10,QWORD PTR [rsp-0x28]
    56d9:	mov    r15d,0x8
    56df:	xor    r11d,r11d
    56e2:	sub    r10,rdx
    56e5:	cmp    r15,r10
    56e8:	mov    r15d,0x0
    56ee:	sbb    r15,r11
    56f1:	mov    r15d,0x8
    56f7:	cmovb  r10,r15
    56fb:	vpbroadcastw xmm0,r10d
    5701:	vpcmpnleuw k1,xmm0,xmm3
    5708:	vmovupd zmm0{k1}{z},ZMMWORD PTR [rax+rdx*8]
    570f:	vmovupd ZMMWORD PTR [r14+rdx*8]{k1},zmm0
    5716:	cmp    DWORD PTR [rsp-0xc],ebx
    571a:	je     4f3d <bench_ada__run_10.isra.0+0xed>
    5720:	inc    ebx
    5722:	jmp    5666 <bench_ada__run_10.isra.0+0x816>
    5727:	nop    WORD PTR [rax+rax*1+0x0]
    5730:	mov    rcx,QWORD PTR [rbp+0x10]
    5734:	mov    rsi,QWORD PTR [rbp+0x18]
    5738:	mov    r9d,DWORD PTR [rsp-0xc]
    573d:	mov    edx,0x1
    5742:	cmp    r9d,edx
    5745:	je     4f40 <bench_ada__run_10.isra.0+0xf0>
    574b:	lea    r10d,[rdx+0x1]
    574f:	cmp    r9d,r10d
    5752:	je     4f40 <bench_ada__run_10.isra.0+0xf0>
    5758:	add    edx,0x2
    575b:	cmp    r9d,edx
    575e:	jne    574b <bench_ada__run_10.isra.0+0x8fb>
    5760:	jmp    4f40 <bench_ada__run_10.isra.0+0xf0>
    5765:	mov    DWORD PTR [rsp-0x10],ebx
    5769:	mov    r15,QWORD PTR [rsp-0x50]
    576e:	mov    rbx,QWORD PTR [rsp-0x28]
    5773:	mov    rcx,QWORD PTR [rsp-0x30]
    5778:	mov    rdx,0xffffffffffffffff
    577f:	inc    rdx
    5782:	vmovsd xmm0,QWORD PTR [rax+rdx*8]
    5787:	vmovsd QWORD PTR [r14+rdx*8],xmm0
    578d:	cmp    rdx,rcx
    5790:	jne    577f <bench_ada__run_10.isra.0+0x92f>
    5792:	jmp    528b <bench_ada__run_10.isra.0+0x43b>
    5797:	mov    r10,QWORD PTR [rsp-0x28]
    579c:	vmovdqa xmm3,XMMWORD PTR [rip+0x2e70c]        # 33eb0 <system__secondary_stack__invalid_memory_size+0xa8>
    57a4:	mov    r15d,0x8
    57aa:	xor    r11d,r11d
    57ad:	xor    edx,edx
    57af:	cmp    r15,r10
    57b2:	sbb    rdx,r11
    57b5:	cmovb  r10,r15
    57b9:	vpbroadcastw xmm0,r10d
    57bf:	vpcmpnleuw k1,xmm0,xmm3
    57c6:	vmovupd zmm0{k1}{z},ZMMWORD PTR [rax]
    57cc:	vmovupd ZMMWORD PTR [r14]{k1},zmm0
    57d2:	cmp    DWORD PTR [rsp-0xc],ebx
    57d6:	je     4f3d <bench_ada__run_10.isra.0+0xed>
    57dc:	inc    ebx
    57de:	xor    edx,edx
    57e0:	jmp    56d4 <bench_ada__run_10.isra.0+0x884>
    57e5:	mov    r10,QWORD PTR [rsp]
    57e9:	mov    r12,r14
    57ec:	mov    r14,rdi
    57ef:	mov    rdi,rsi
    57f2:	mov    r13,rbx
    57f5:	mov    rbx,r15
    57f8:	mov    QWORD PTR [rsp-0x18],rdi
    57fd:	mov    QWORD PTR [rsp-0x20],r8
    5802:	mov    QWORD PTR [rbp+0x28],r14
    5806:	lea    rsi,[r10*8+0x0]
    580e:	lea    rdx,[r10-0x1]
    5812:	vmovq  xmm1,rsi
    5817:	mov    rsi,r15
    581a:	shr    rsi,0x3
    581e:	vmovq  r14,xmm1
    5823:	imul   rdx,rsi
    5827:	mov    r15,r10
    582a:	shr    r15,1
    582d:	lea    rcx,[rdx*8+0x0]
    5835:	mov    QWORD PTR [rsp-0x28],rsi
    583a:	mov    QWORD PTR [rsp],rcx
    583e:	vmovq  rcx,xmm1
    5843:	sub    rcx,0x8
    5847:	mov    r11,rcx
    584a:	lea    rcx,[r15+r15*1]
    584e:	mov    QWORD PTR [rsp-0x8],rcx
    5853:	imul   rsi,rcx
    5857:	vmovq  xmm3,rsi
    585c:	mov    rcx,rax
    585f:	mov    rsi,rax
    5862:	mov    r9,r12
    5865:	xor    eax,eax
    5867:	nop    WORD PTR [rax+rax*1+0x0]
    5870:	lea    rdx,[r11+r9*1]
    5874:	cmp    rdx,rcx
    5877:	jb     588a <bench_ada__run_10.isra.0+0xa3a>
    5879:	mov    rdi,QWORD PTR [rsp]
    587d:	lea    rdx,[rdi+rcx*1]
    5881:	cmp    rdx,r9
    5884:	jae    5926 <bench_ada__run_10.isra.0+0xad6>
    588a:	mov    rdx,rcx
    588d:	mov    r8,r9
    5890:	xor    edi,edi
    5892:	vmovsd xmm0,QWORD PTR [rdx]
    5896:	vmovhpd xmm0,xmm0,QWORD PTR [rbx+rdx*1]
    589b:	inc    rdi
    589e:	add    r8,0x10
    58a2:	lea    rdx,[rdx+rbx*2]
    58a6:	vmovupd XMMWORD PTR [r8-0x10],xmm0
    58ac:	cmp    rdi,r15
    58af:	jb     5892 <bench_ada__run_10.isra.0+0xa42>
    58b1:	mov    r8,QWORD PTR [rsp-0x8]
    58b6:	cmp    r8,r10
    58b9:	je     58d9 <bench_ada__run_10.isra.0+0xa89>
    58bb:	vmovq  rdi,xmm3
    58c0:	lea    rdx,[rdi+rax*1]
    58c4:	vmovsd xmm0,QWORD PTR [rsi+rdx*8]
    58c9:	mov    rdx,r10
    58cc:	imul   rdx,rax
    58d0:	add    rdx,r8
    58d3:	vmovsd QWORD PTR [r12+rdx*8],xmm0
    58d9:	inc    rax
    58dc:	add    r9,r14
    58df:	add    rcx,0x8
    58e3:	cmp    rax,r13
    58e6:	jne    5870 <bench_ada__run_10.isra.0+0xa20>
    58e8:	mov    rax,rsi
    58eb:	mov    rdi,QWORD PTR [rsp-0x18]
    58f0:	mov    rcx,QWORD PTR [rsp-0x20]
    58f5:	mov    rsi,QWORD PTR [rbp+0x10]
    58f9:	mov    rdx,QWORD PTR [rbp+0x18]
    58fd:	mov    r9,QWORD PTR [rbp+0x28]
    5901:	mov    esi,DWORD PTR [rsp-0x10]
    5905:	cmp    DWORD PTR [rsp-0xc],esi
    5909:	je     4f3d <bench_ada__run_10.isra.0+0xed>
    590f:	inc    esi
    5911:	mov    rdx,QWORD PTR [rbp+0x18]
    5915:	mov    r9,QWORD PTR [rbp+0x28]
    5919:	mov    DWORD PTR [rsp-0x10],esi
    591d:	mov    rsi,QWORD PTR [rbp+0x10]
    5921:	jmp    585c <bench_ada__run_10.isra.0+0xa0c>
    5926:	mov    r8,QWORD PTR [rsp-0x28]
    592b:	xor    edx,edx
    592d:	nop    DWORD PTR [rax+rax*1+0x0]
    5935:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5940:	mov    rdi,r8
    5943:	imul   rdi,rdx
    5947:	add    rdi,rax
    594a:	vmovsd xmm0,QWORD PTR [rsi+rdi*8]
    594f:	vmovsd QWORD PTR [r9+rdx*8],xmm0
    5955:	inc    rdx
    5958:	cmp    r10,rdx
    595b:	jne    5940 <bench_ada__run_10.isra.0+0xaf0>
    595d:	jmp    58d9 <bench_ada__run_10.isra.0+0xa89>
    5962:	nop    DWORD PTR [rax]
    5965:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_11.isra.0>:
    5970:	sub    rsp,0x30
    5974:	mov    QWORD PTR [rsp+0x10],r12
    5979:	mov    QWORD PTR [rsp+0x18],r13
    597e:	mov    DWORD PTR [rsp-0xc],esi
    5982:	mov    r12,QWORD PTR [rsp+0x38]
    5987:	mov    r10,QWORD PTR [rsp+0x40]
    598c:	mov    r13,QWORD PTR [rsp+0x48]
    5991:	test   esi,esi
    5993:	je     5b6c <bench_ada__run_11.isra.0+0x1fc>
    5999:	mov    QWORD PTR [rsp+0x8],rbp
    599e:	mov    r11d,edi
    59a1:	mov    rbp,rcx
    59a4:	mov    rdi,rdx
    59a7:	test   r11d,r11d
    59aa:	je     5b7b <bench_ada__run_11.isra.0+0x20b>
    59b0:	vmovsd xmm1,QWORD PTR [rip+0x2e3e0]        # 33d98 <system__os_lib__standin+0xc>
    59b8:	mov    QWORD PTR [rsp],rbx
    59bc:	mov    QWORD PTR [rsp-0x8],rcx
    59c1:	mov    QWORD PTR [rsp+0x48],r13
    59c6:	mov    QWORD PTR [rsp+0x20],r14
    59cb:	mov    QWORD PTR [rsp+0x28],r15
    59d0:	lea    r14,[r11+0x1]
    59d4:	lea    r15,[r11*8+0x0]
    59dc:	mov    QWORD PTR [rsp+0x38],r12
    59e1:	mov    edx,0x1
    59e6:	mov    r12,r9
    59e9:	vmovq  xmm3,r15
    59ee:	mov    r9,r8
    59f1:	vmovq  xmm2,r14
    59f6:	cs nop WORD PTR [rax+rax*1+0x0]
    5a00:	mov    r13,r12
    5a03:	mov    DWORD PTR [rsp-0x10],edx
    5a07:	mov    r12,r9
    5a0a:	mov    rbx,r10
    5a0d:	xor    esi,esi
    5a0f:	vmovq  r14,xmm3
    5a14:	mov    r9,0xffffffffffffffff
    5a1b:	jmp    5a52 <bench_ada__run_11.isra.0+0xe2>
    5a1d:	xchg   ax,ax
    5a1f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5a2a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5a35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5a40:	inc    rsi
    5a43:	inc    r9
    5a46:	add    rbx,r14
    5a49:	cmp    r11,rsi
    5a4c:	je     5b37 <bench_ada__run_11.isra.0+0x1c7>
    5a52:	vmovq  rax,xmm2
    5a57:	imul   rax,rsi
    5a5b:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    5a60:	vmovsd QWORD PTR [r10+rax*8],xmm0
    5a66:	test   r9d,r9d
    5a69:	js     5a40 <bench_ada__run_11.isra.0+0xd0>
    5a6b:	movsxd r15,esi
    5a6e:	mov    ecx,r9d
    5a71:	mov    rbp,r13
    5a74:	xor    eax,eax
    5a76:	mov    r8,r15
    5a79:	mov    r13,r12
    5a7c:	mov    r12,r9
    5a7f:	imul   r8,r14
    5a83:	lea    r9,[r8+rdi*1]
    5a87:	mov    r8,rcx
    5a8a:	jmp    5af0 <bench_ada__run_11.isra.0+0x180>
    5a8c:	nop    DWORD PTR [rax+rax*1+0x0]
    5a94:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5a9f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5aaa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5ab5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5ac0:	mov    rdx,rax
    5ac3:	vmovsd xmm0,QWORD PTR [r9+rax*8]
    5ac9:	imul   rdx,r11
    5acd:	lea    rcx,[rdx+r15*1]
    5ad1:	add    rdx,rsi
    5ad4:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*8]
    5ad9:	vmulsd xmm0,xmm0,xmm1
    5add:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    5ae2:	vmovsd QWORD PTR [r10+rdx*8],xmm0
    5ae8:	cmp    r8,rax
    5aeb:	je     5b1c <bench_ada__run_11.isra.0+0x1ac>
    5aed:	inc    rax
    5af0:	cmp    esi,eax
    5af2:	jne    5ac0 <bench_ada__run_11.isra.0+0x150>
    5af4:	vmovq  rdx,xmm2
    5af9:	imul   rdx,rax
    5afd:	vmovsd xmm0,QWORD PTR [rdi+rdx*8]
    5b02:	mov    rdx,rax
    5b05:	imul   rdx,r11
    5b09:	add    rdx,rsi
    5b0c:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    5b11:	vmovsd QWORD PTR [r10+rdx*8],xmm0
    5b17:	cmp    r8,rax
    5b1a:	jne    5aed <bench_ada__run_11.isra.0+0x17d>
    5b1c:	mov    r9,r12
    5b1f:	inc    rsi
    5b22:	mov    r12,r13
    5b25:	add    rbx,r14
    5b28:	mov    r13,rbp
    5b2b:	inc    r9
    5b2e:	cmp    r11,rsi
    5b31:	jne    5a52 <bench_ada__run_11.isra.0+0xe2>
    5b37:	mov    r9,r12
    5b3a:	mov    edx,DWORD PTR [rsp-0x10]
    5b3e:	mov    rax,QWORD PTR [rsp-0x8]
    5b43:	mov    rbx,QWORD PTR [rsp+0x38]
    5b48:	mov    rcx,QWORD PTR [rsp+0x48]
    5b4d:	mov    r12,r13
    5b50:	cmp    DWORD PTR [rsp-0xc],edx
    5b54:	je     5b94 <bench_ada__run_11.isra.0+0x224>
    5b56:	mov    rcx,QWORD PTR [rsp+0x38]
    5b5b:	mov    rbx,QWORD PTR [rsp+0x48]
    5b60:	inc    edx
    5b62:	jmp    5a00 <bench_ada__run_11.isra.0+0x90>
    5b67:	mov    rbp,QWORD PTR [rsp+0x8]
    5b6c:	mov    r12,QWORD PTR [rsp+0x10]
    5b71:	mov    r13,QWORD PTR [rsp+0x18]
    5b76:	add    rsp,0x30
    5b7a:	ret
    5b7b:	mov    edx,DWORD PTR [rsp-0xc]
    5b7f:	mov    eax,0x1
    5b84:	cmp    edx,eax
    5b86:	je     5b67 <bench_ada__run_11.isra.0+0x1f7>
    5b88:	lea    ecx,[rax+0x1]
    5b8b:	cmp    edx,ecx
    5b8d:	je     5b67 <bench_ada__run_11.isra.0+0x1f7>
    5b8f:	add    eax,0x2
    5b92:	jmp    5b84 <bench_ada__run_11.isra.0+0x214>
    5b94:	mov    rbx,QWORD PTR [rsp]
    5b98:	mov    rbp,QWORD PTR [rsp+0x8]
    5b9d:	mov    r14,QWORD PTR [rsp+0x20]
    5ba2:	mov    r15,QWORD PTR [rsp+0x28]
    5ba7:	jmp    5b6c <bench_ada__run_11.isra.0+0x1fc>
    5ba9:	nop
    5baa:	nop    WORD PTR [rax+rax*1+0x0]


<bench_ada__run_12.isra.0>:
    7f60:	sub    rsp,0x48
    7f64:	mov    QWORD PTR [rsp+0x18],rbx
    7f69:	mov    QWORD PTR [rsp+0x38],r14
    7f6e:	mov    QWORD PTR [rsp+0x40],r15
    7f73:	mov    ebx,edi
    7f75:	mov    r14,rcx
    7f78:	mov    r15,r8
    7f7b:	mov    rcx,QWORD PTR [rsp+0x50]
    7f80:	mov    rdi,QWORD PTR [rsp+0x58]
    7f85:	mov    r8,QWORD PTR [rsp+0x60]
    7f8a:	test   esi,esi
    7f8c:	je     8055 <bench_ada__run_12.isra.0+0xf5>
    7f92:	mov    QWORD PTR [rsp+0x28],r12
    7f97:	mov    QWORD PTR [rsp+0x30],r13
    7f9c:	mov    r12,rdx
    7f9f:	mov    r13,r9
    7fa2:	test   ebx,ebx
    7fa4:	je     8069 <bench_ada__run_12.isra.0+0x109>
    7faa:	lea    rax,[rbx*8+0x0]
    7fb2:	mov    DWORD PTR [rsp+0xc],esi
    7fb6:	mov    rsi,rbx
    7fb9:	mov    DWORD PTR [rsp+0x8],0x1
    7fc1:	mov    QWORD PTR [rsp+0x20],rbp
    7fc6:	imul   rsi,rax
    7fca:	shr    rax,0x3
    7fce:	mov    QWORD PTR [rsp],rsi
    7fd2:	lea    rbp,[rax+0x1]
    7fd6:	mov    rdx,QWORD PTR [rsp]
    7fda:	xor    esi,esi
    7fdc:	mov    QWORD PTR [rsp+0x60],r8
    7fe1:	mov    QWORD PTR [rsp+0x50],rcx
    7fe6:	call   2bd0 <memset@plt>
    7feb:	vmovsd xmm0,QWORD PTR [rip+0x2bdd5]        # 33dc8 <system__os_lib__standin+0x3c>
    7ff3:	mov    r8,QWORD PTR [rsp+0x60]
    7ff8:	mov    rcx,QWORD PTR [rsp+0x50]
    7ffd:	mov    rdi,rax
    8000:	xor    eax,eax
    8002:	nop    DWORD PTR [rax+rax*1+0x0]
    800a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8015:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8020:	mov    rdx,rbp
    8023:	imul   rdx,rax
    8027:	inc    rax
    802a:	vmovsd QWORD PTR [rdi+rdx*8],xmm0
    802f:	cmp    rax,rbx
    8032:	jne    8020 <bench_ada__run_12.isra.0+0xc0>
    8034:	mov    eax,DWORD PTR [rsp+0x8]
    8038:	cmp    DWORD PTR [rsp+0xc],eax
    803c:	je     8046 <bench_ada__run_12.isra.0+0xe6>
    803e:	inc    eax
    8040:	mov    DWORD PTR [rsp+0x8],eax
    8044:	jmp    7fd6 <bench_ada__run_12.isra.0+0x76>
    8046:	mov    rbp,QWORD PTR [rsp+0x20]
    804b:	mov    r12,QWORD PTR [rsp+0x28]
    8050:	mov    r13,QWORD PTR [rsp+0x30]
    8055:	mov    rbx,QWORD PTR [rsp+0x18]
    805a:	mov    r14,QWORD PTR [rsp+0x38]
    805f:	mov    r15,QWORD PTR [rsp+0x40]
    8064:	add    rsp,0x48
    8068:	ret
    8069:	mov    eax,0x1
    806e:	cmp    esi,eax
    8070:	je     804b <bench_ada__run_12.isra.0+0xeb>
    8072:	lea    edx,[rax+0x1]
    8075:	cmp    esi,edx
    8077:	je     804b <bench_ada__run_12.isra.0+0xeb>
    8079:	add    eax,0x2
    807c:	cmp    esi,eax
    807e:	jne    8072 <bench_ada__run_12.isra.0+0x112>
    8080:	jmp    804b <bench_ada__run_12.isra.0+0xeb>
    8082:	nop    DWORD PTR [rax]
    8085:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_13.isra.0>:
    5bb0:	push   rbp
    5bb1:	mov    rbp,rsp
    5bb4:	push   r15
    5bb6:	push   r14
    5bb8:	push   r13
    5bba:	push   r12
    5bbc:	push   rbx
    5bbd:	mov    r12,r9
    5bc0:	and    rsp,0xffffffffffffffc0
    5bc4:	test   edx,edx
    5bc6:	mov    rax,QWORD PTR [rbp+0x10]
    5bca:	mov    DWORD PTR [rsp-0xc],edx
    5bce:	mov    r15,QWORD PTR [rbp+0x18]
    5bd2:	mov    r10,QWORD PTR [rbp+0x20]
    5bd6:	mov    r9,QWORD PTR [rbp+0x28]
    5bda:	je     5c0c <bench_ada__run_13.isra.0+0x5c>
    5bdc:	mov    rbx,rcx
    5bdf:	mov    rdx,r8
    5be2:	sar    edi,1
    5be4:	lea    ecx,[rdi-0x1]
    5be7:	cmp    ecx,0xffffffff
    5bea:	je     5c1b <bench_ada__run_13.isra.0+0x6b>
    5bec:	test   esi,esi
    5bee:	jne    5c34 <bench_ada__run_13.isra.0+0x84>
    5bf0:	mov    esi,DWORD PTR [rsp-0xc]
    5bf4:	mov    ecx,0x1
    5bf9:	cmp    esi,ecx
    5bfb:	je     5c0c <bench_ada__run_13.isra.0+0x5c>
    5bfd:	lea    edi,[rcx+0x1]
    5c00:	cmp    esi,edi
    5c02:	je     5c0c <bench_ada__run_13.isra.0+0x5c>
    5c04:	add    ecx,0x2
    5c07:	jmp    5bf9 <bench_ada__run_13.isra.0+0x49>
    5c09:	vzeroupper
    5c0c:	lea    rsp,[rbp-0x28]
    5c10:	pop    rbx
    5c11:	pop    r12
    5c13:	pop    r13
    5c15:	pop    r14
    5c17:	pop    r15
    5c19:	pop    rbp
    5c1a:	ret
    5c1b:	mov    esi,DWORD PTR [rsp-0xc]
    5c1f:	mov    ecx,0x1
    5c24:	cmp    esi,ecx
    5c26:	je     5c0c <bench_ada__run_13.isra.0+0x5c>
    5c28:	lea    edi,[rcx+0x1]
    5c2b:	cmp    esi,edi
    5c2d:	je     5c0c <bench_ada__run_13.isra.0+0x5c>
    5c2f:	add    ecx,0x2
    5c32:	jmp    5c24 <bench_ada__run_13.isra.0+0x74>
    5c34:	vmovdqa xmm2,XMMWORD PTR [rip+0x2e274]        # 33eb0 <system__secondary_stack__invalid_memory_size+0xa8>
    5c3c:	mov    QWORD PTR [rsp-0x18],r8
    5c41:	mov    QWORD PTR [rsp-0x20],r12
    5c46:	mov    QWORD PTR [rbp+0x10],rax
    5c4a:	mov    QWORD PTR [rbp+0x18],r15
    5c4e:	mov    r11d,esi
    5c51:	dec    esi
    5c53:	mov    edx,0x1
    5c58:	mov    rdi,r11
    5c5b:	shr    rdi,0x3
    5c5f:	vmovd  xmm3,ecx
    5c63:	mov    r14,r11
    5c66:	mov    QWORD PTR [rsp-0x8],rsi
    5c6b:	mov    rsi,r10
    5c6e:	sub    rsi,rbx
    5c71:	and    r14d,0xfffffff8
    5c75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5c80:	mov    DWORD PTR [rsp-0x10],edx
    5c84:	mov    r8,0xffffffffffffffff
    5c8b:	mov    r15,rbx
    5c8e:	vmovq  r12,xmm3
    5c93:	xchg   ax,ax
    5c95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5ca0:	inc    r8
    5ca3:	movsxd rax,DWORD PTR [r9+r8*4]
    5ca7:	imul   rax,r11
    5cab:	lea    rcx,[rax*8+0x0]
    5cb3:	lea    rbx,[r15+rcx*1]
    5cb7:	lea    r13,[r10+rcx*1]
    5cbb:	lea    rcx,[rcx+r10*1-0x8]
    5cc0:	sub    rcx,rbx
    5cc3:	mov    rdx,rbx
    5cc6:	cmp    rcx,0x30
    5cca:	jbe    5d80 <bench_ada__run_13.isra.0+0x1d0>
    5cd0:	cmp    QWORD PTR [rsp-0x8],0x6
    5cd6:	jbe    5db6 <bench_ada__run_13.isra.0+0x206>
    5cdc:	xor    ecx,ecx
    5cde:	xchg   ax,ax
    5ce0:	vmovupd zmm0,ZMMWORD PTR [rdx]
    5ce6:	inc    rcx
    5ce9:	vmovupd ZMMWORD PTR [rsi+rdx*1],zmm0
    5cf0:	add    rdx,0x40
    5cf4:	cmp    rcx,rdi
    5cf7:	jb     5ce0 <bench_ada__run_13.isra.0+0x130>
    5cf9:	mov    rdx,r14
    5cfc:	cmp    r14,r11
    5cff:	je     5d39 <bench_ada__run_13.isra.0+0x189>
    5d01:	add    rax,rdx
    5d04:	mov    rcx,r11
    5d07:	sub    rcx,rdx
    5d0a:	mov    edx,0x8
    5d0f:	xor    ebx,ebx
    5d11:	xor    r13d,r13d
    5d14:	cmp    rdx,rcx
    5d17:	sbb    r13,rbx
    5d1a:	cmovb  rcx,rdx
    5d1e:	vpbroadcastw xmm0,ecx
    5d24:	vpcmpnleuw k1,xmm0,xmm2
    5d2b:	vmovupd zmm0{k1}{z},ZMMWORD PTR [r15+rax*8]
    5d32:	vmovupd ZMMWORD PTR [r10+rax*8]{k1},zmm0
    5d39:	cmp    r8,r12
    5d3c:	jne    5ca0 <bench_ada__run_13.isra.0+0xf0>
    5d42:	mov    rbx,r15
    5d45:	mov    edx,DWORD PTR [rsp-0x10]
    5d49:	mov    rax,QWORD PTR [rsp-0x18]
    5d4e:	mov    rcx,QWORD PTR [rsp-0x20]
    5d53:	mov    r15,QWORD PTR [rbp+0x10]
    5d57:	mov    r8,QWORD PTR [rbp+0x18]
    5d5b:	cmp    DWORD PTR [rsp-0xc],edx
    5d5f:	je     5c09 <bench_ada__run_13.isra.0+0x59>
    5d65:	mov    r15,QWORD PTR [rbp+0x10]
    5d69:	mov    r8,QWORD PTR [rbp+0x18]
    5d6d:	inc    edx
    5d6f:	jmp    5c80 <bench_ada__run_13.isra.0+0xd0>
    5d74:	nop
    5d75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5d80:	xor    eax,eax
    5d82:	nop    DWORD PTR [rax+rax*1+0x0]
    5d8a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5d95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5da0:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    5da5:	vmovsd QWORD PTR [r13+rax*8+0x0],xmm0
    5dac:	inc    rax
    5daf:	cmp    rax,r11
    5db2:	jne    5da0 <bench_ada__run_13.isra.0+0x1f0>
    5db4:	jmp    5d39 <bench_ada__run_13.isra.0+0x189>
    5db6:	xor    edx,edx
    5db8:	jmp    5d01 <bench_ada__run_13.isra.0+0x151>
    5dbd:	nop
    5dbe:	xchg   ax,ax


<bench_ada__run_14.isra.0>:
    8090:	push   rbp
    8091:	mov    r11d,ecx
    8094:	mov    r10d,edi
    8097:	mov    rbp,rsp
    809a:	push   r15
    809c:	push   r14
    809e:	push   r13
    80a0:	push   r12
    80a2:	push   rbx
    80a3:	and    rsp,0xffffffffffffffc0
    80a7:	add    rsp,0xffffffffffffff80
    80ab:	mov    rcx,QWORD PTR [rbp+0x18]
    80af:	mov    rax,QWORD PTR [rbp+0x20]
    80b3:	mov    rdi,QWORD PTR [rbp+0x28]
    80b7:	mov    r14,QWORD PTR [rbp+0x30]
    80bb:	test   r11d,r11d
    80be:	je     81b6 <bench_ada__run_14.isra.0+0x126>
    80c4:	mov    rbx,r8
    80c7:	mov    r12,r9
    80ca:	mov    r8,QWORD PTR [rbp+0x10]
    80ce:	test   r10d,r10d
    80d1:	je     8197 <bench_ada__run_14.isra.0+0x107>
    80d7:	mov    r15d,esi
    80da:	mov    DWORD PTR [rsp+0x2c],esi
    80de:	lea    esi,[rdx-0x1]
    80e1:	mov    DWORD PTR [rsp+0x14],r11d
    80e6:	mov    DWORD PTR [rsp+0x6c],esi
    80ea:	mov    esi,edx
    80ec:	mov    r11d,edx
    80ef:	mov    DWORD PTR [rsp+0x78],edx
    80f3:	lea    r8,[rsi*8+0x0]
    80fb:	mov    edx,r10d
    80fe:	mov    esi,r15d
    8101:	mov    DWORD PTR [rsp+0x28],0x1
    8109:	mov    r9,r8
    810c:	mov    QWORD PTR [rsp+0x20],rsi
    8111:	mov    QWORD PTR [rsp+0x60],r8
    8116:	lea    r15,[rdx-0x1]
    811a:	mov    QWORD PTR [rbp+0x18],rcx
    811e:	mov    QWORD PTR [rbp+0x20],rax
    8122:	mov    QWORD PTR [rbp+0x30],r14
    8126:	mov    QWORD PTR [rsp+0x38],r15
    812b:	imul   r9,rdx
    812f:	shl    rsi,0x3
    8133:	test   r11d,r11d
    8136:	mov    QWORD PTR [rsp+0x30],r9
    813b:	mov    QWORD PTR [rsp+0x18],rsi
    8140:	setne  BYTE PTR [rsp+0x7f]
    8145:	shr    r8,0x3
    8149:	mov    QWORD PTR [rsp+0x70],r8
    814e:	mov    rdx,QWORD PTR [rsp+0x30]
    8153:	xor    esi,esi
    8155:	call   2bd0 <memset@plt>
    815a:	mov    rdi,rax
    815d:	mov    eax,DWORD PTR [rsp+0x2c]
    8161:	test   eax,eax
    8163:	jne    81c5 <bench_ada__run_14.isra.0+0x135>
    8165:	mov    rax,QWORD PTR [rbp+0x10]
    8169:	mov    rdx,QWORD PTR [rbp+0x18]
    816d:	mov    rcx,QWORD PTR [rbp+0x20]
    8171:	mov    rsi,QWORD PTR [rbp+0x30]
    8175:	mov    eax,DWORD PTR [rsp+0x28]
    8179:	cmp    DWORD PTR [rsp+0x14],eax
    817d:	je     81b6 <bench_ada__run_14.isra.0+0x126>
    817f:	inc    eax
    8181:	mov    rdx,QWORD PTR [rbp+0x18]
    8185:	mov    rcx,QWORD PTR [rbp+0x20]
    8189:	mov    rsi,QWORD PTR [rbp+0x30]
    818d:	mov    DWORD PTR [rsp+0x28],eax
    8191:	mov    rax,QWORD PTR [rbp+0x10]
    8195:	jmp    814e <bench_ada__run_14.isra.0+0xbe>
    8197:	mov    rsi,QWORD PTR [rbp+0x10]
    819b:	mov    edx,0x1
    81a0:	cmp    r11d,edx
    81a3:	je     81b6 <bench_ada__run_14.isra.0+0x126>
    81a5:	lea    r8d,[rdx+0x1]
    81a9:	cmp    r11d,r8d
    81ac:	je     81b6 <bench_ada__run_14.isra.0+0x126>
    81ae:	add    edx,0x2
    81b1:	cmp    r11d,edx
    81b4:	jne    81a5 <bench_ada__run_14.isra.0+0x115>
    81b6:	lea    rsp,[rbp-0x28]
    81ba:	pop    rbx
    81bb:	pop    r12
    81bd:	pop    r13
    81bf:	pop    r14
    81c1:	pop    r15
    81c3:	pop    rbp
    81c4:	ret
    81c5:	mov    rax,QWORD PTR [rsp+0x20]
    81ca:	mov    r11,QWORD PTR [rsp+0x18]
    81cf:	mov    r9,0xffffffffffffffff
    81d6:	vxorpd xmm7,xmm7,xmm7
    81da:	lea    r13,[rax-0x1]
    81de:	mov    eax,DWORD PTR [rsp+0x78]
    81e2:	shr    r11,0x3
    81e6:	mov    QWORD PTR [rsp+0x40],r11
    81eb:	shr    eax,0x3
    81ee:	mov    DWORD PTR [rsp+0x68],eax
    81f2:	shl    rax,0x6
    81f6:	mov    QWORD PTR [rsp+0x48],rax
    81fb:	nop    DWORD PTR [rax+rax*1+0x0]
    8200:	mov    r11,QWORD PTR [rsp+0x40]
    8205:	mov    r14,QWORD PTR [rsp+0x70]
    820a:	inc    r9
    820d:	mov    rcx,QWORD PTR [rsp+0x48]
    8212:	movsxd rsi,r9d
    8215:	mov    QWORD PTR [rsp+0x50],r9
    821a:	mov    rax,0xffffffffffffffff
    8221:	imul   r11,rsi
    8225:	imul   r14,rsi
    8229:	imul   rsi,QWORD PTR [rsp+0x60]
    822f:	mov    r8,r11
    8232:	mov    r9,r14
    8235:	lea    rdx,[rsi+rdi*1]
    8239:	mov    QWORD PTR [rsp+0x58],rdx
    823e:	lea    r15,[rcx+rdx*1]
    8242:	jmp    8289 <bench_ada__run_14.isra.0+0x1f9>
    8244:	nop    DWORD PTR [rax+rax*1+0x0]
    8249:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8254:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    825f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    826a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8275:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8280:	cmp    rax,r13
    8283:	je     83e0 <bench_ada__run_14.isra.0+0x350>
    8289:	inc    rax
    828c:	movsxd rdx,eax
    828f:	lea    rsi,[r8+rdx*1]
    8293:	vmovsd xmm1,QWORD PTR [rbx+rsi*8]
    8298:	vcomisd xmm1,xmm7
    829c:	vbroadcastsd zmm2,xmm1
    82a2:	je     8280 <bench_ada__run_14.isra.0+0x1f0>
    82a4:	cmp    BYTE PTR [rsp+0x7f],0x0
    82a9:	je     8280 <bench_ada__run_14.isra.0+0x1f0>
    82ab:	cmp    DWORD PTR [rsp+0x6c],0x6
    82b0:	jbe    8430 <bench_ada__run_14.isra.0+0x3a0>
    82b6:	mov    r10,QWORD PTR [rsp+0x60]
    82bb:	mov    rcx,QWORD PTR [rsp+0x58]
    82c0:	vmovapd zmm3,zmm2
    82c6:	imul   r10,rdx
    82ca:	mov    rsi,rcx
    82cd:	add    r10,r12
    82d0:	sub    r10,rcx
    82d3:	xchg   ax,ax
    82d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    82e0:	vmulpd zmm0,zmm3,ZMMWORD PTR [rsi+r10*1]
    82e7:	add    rsi,0x40
    82eb:	vaddpd zmm0,zmm0,ZMMWORD PTR [rsi-0x40]
    82f2:	vmovupd ZMMWORD PTR [rsi-0x40],zmm0
    82f9:	cmp    rsi,r15
    82fc:	jne    82e0 <bench_ada__run_14.isra.0+0x250>
    82fe:	mov    ecx,DWORD PTR [rsp+0x68]
    8302:	lea    esi,[rcx*8+0x0]
    8309:	cmp    esi,DWORD PTR [rsp+0x78]
    830d:	je     8280 <bench_ada__run_14.isra.0+0x1f0>
    8313:	lea    r10d,[rsi-0x1]
    8317:	mov    r11d,DWORD PTR [rsp+0x78]
    831c:	sub    r11d,esi
    831f:	lea    r14d,[r11-0x1]
    8323:	cmp    r14d,0x2
    8327:	jbe    835e <bench_ada__run_14.isra.0+0x2ce>
    8329:	lea    r14,[r9+rsi*1]
    832d:	lea    rcx,[rdi+r14*8]
    8331:	mov    r14,QWORD PTR [rsp+0x70]
    8336:	imul   r14,rdx
    833a:	add    rsi,r14
    833d:	vmulpd ymm2,ymm2,YMMWORD PTR [r12+rsi*8]
    8343:	mov    esi,r11d
    8346:	and    esi,0xfffffffc
    8349:	and    r11d,0x3
    834d:	vaddpd ymm2,ymm2,YMMWORD PTR [rcx]
    8351:	vmovupd YMMWORD PTR [rcx],ymm2
    8355:	je     8280 <bench_ada__run_14.isra.0+0x1f0>
    835b:	add    r10d,esi
    835e:	imul   rdx,QWORD PTR [rsp+0x70]
    8364:	lea    esi,[r10+0x1]
    8368:	mov    ecx,DWORD PTR [rsp+0x6c]
    836c:	lea    r14,[r9+rsi*1]
    8370:	mov    r11,rsi
    8373:	add    rsi,rdx
    8376:	vmulsd xmm0,xmm1,QWORD PTR [r12+rsi*8]
    837c:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    8382:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    8388:	cmp    ecx,r11d
    838b:	je     8280 <bench_ada__run_14.isra.0+0x1f0>
    8391:	lea    esi,[r10+0x2]
    8395:	lea    r14,[r9+rsi*1]
    8399:	mov    r11,rsi
    839c:	add    rsi,rdx
    839f:	vmulsd xmm0,xmm1,QWORD PTR [r12+rsi*8]
    83a5:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    83ab:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    83b1:	cmp    ecx,r11d
    83b4:	je     8280 <bench_ada__run_14.isra.0+0x1f0>
    83ba:	lea    esi,[r10+0x3]
    83be:	lea    r10,[r9+rsi*1]
    83c2:	add    rsi,rdx
    83c5:	vmulsd xmm1,xmm1,QWORD PTR [r12+rsi*8]
    83cb:	vaddsd xmm1,xmm1,QWORD PTR [rdi+r10*8]
    83d1:	vmovsd QWORD PTR [rdi+r10*8],xmm1
    83d7:	cmp    rax,r13
    83da:	jne    8289 <bench_ada__run_14.isra.0+0x1f9>
    83e0:	mov    r9,QWORD PTR [rsp+0x50]
    83e5:	cmp    r9,QWORD PTR [rsp+0x38]
    83ea:	jne    8200 <bench_ada__run_14.isra.0+0x170>
    83f0:	mov    rax,QWORD PTR [rbp+0x10]
    83f4:	mov    rdx,QWORD PTR [rbp+0x18]
    83f8:	mov    rcx,QWORD PTR [rbp+0x20]
    83fc:	mov    rsi,QWORD PTR [rbp+0x30]
    8400:	mov    eax,DWORD PTR [rsp+0x28]
    8404:	cmp    DWORD PTR [rsp+0x14],eax
    8408:	je     843d <bench_ada__run_14.isra.0+0x3ad>
    840a:	inc    eax
    840c:	mov    rdx,QWORD PTR [rbp+0x18]
    8410:	mov    rcx,QWORD PTR [rbp+0x20]
    8414:	mov    rsi,QWORD PTR [rbp+0x30]
    8418:	mov    DWORD PTR [rsp+0x28],eax
    841c:	mov    rax,QWORD PTR [rbp+0x10]
    8420:	vzeroupper
    8423:	jmp    814e <bench_ada__run_14.isra.0+0xbe>
    8428:	nop    DWORD PTR [rax+rax*1+0x0]
    8430:	xor    esi,esi
    8432:	mov    r10d,0xffffffff
    8438:	jmp    8317 <bench_ada__run_14.isra.0+0x287>
    843d:	vzeroupper
    8440:	jmp    81b6 <bench_ada__run_14.isra.0+0x126>
    8445:	nop
    8446:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_15.isra.0>:
    8450:	push   rbp
    8451:	mov    eax,edi
    8453:	mov    rbp,rsp
    8456:	push   r15
    8458:	push   r14
    845a:	push   r13
    845c:	push   r12
    845e:	push   rbx
    845f:	and    rsp,0xffffffffffffffc0
    8463:	add    rsp,0xffffffffffffff80
    8467:	mov    rdi,QWORD PTR [rbp+0x28]
    846b:	test   ecx,ecx
    846d:	je     8768 <bench_ada__run_15.isra.0+0x318>
    8473:	mov    DWORD PTR [rsp+0x34],eax
    8477:	mov    eax,edx
    8479:	mov    DWORD PTR [rsp+0x30],ecx
    847d:	mov    ecx,esi
    847f:	lea    rsi,[rax*8+0x0]
    8487:	mov    DWORD PTR [rsp+0x78],edx
    848b:	mov    eax,ecx
    848d:	mov    r12,r9
    8490:	lea    r9d,[rdx-0x1]
    8494:	mov    rdx,rsi
    8497:	mov    QWORD PTR [rsp+0x60],rsi
    849c:	mov    QWORD PTR [rsp+0x18],rax
    84a1:	mov    DWORD PTR [rsp+0x2c],ecx
    84a5:	mov    rbx,r8
    84a8:	mov    r14d,r9d
    84ab:	xor    r8d,r8d
    84ae:	imul   rdx,rax
    84b2:	shr    rsi,0x3
    84b6:	mov    QWORD PTR [rsp+0x38],rdx
    84bb:	lea    rdx,[rax*8+0x0]
    84c3:	mov    QWORD PTR [rsp+0x68],rsi
    84c8:	mov    QWORD PTR [rsp+0x20],rdx
    84cd:	nop    DWORD PTR [rax]
    84d0:	inc    r8d
    84d3:	mov    rax,QWORD PTR [rbp+0x10]
    84d7:	mov    rsi,QWORD PTR [rbp+0x18]
    84db:	mov    rdx,QWORD PTR [rbp+0x20]
    84df:	mov    DWORD PTR [rsp+0x7c],r8d
    84e4:	mov    rcx,QWORD PTR [rbp+0x30]
    84e8:	mov    rdx,QWORD PTR [rsp+0x38]
    84ed:	xor    esi,esi
    84ef:	call   2bd0 <memset@plt>
    84f4:	mov    r8d,DWORD PTR [rsp+0x7c]
    84f9:	mov    rdi,rax
    84fc:	mov    eax,DWORD PTR [rsp+0x34]
    8500:	test   eax,eax
    8502:	je     874d <bench_ada__run_15.isra.0+0x2fd>
    8508:	mov    edx,DWORD PTR [rsp+0x2c]
    850c:	test   edx,edx
    850e:	je     874d <bench_ada__run_15.isra.0+0x2fd>
    8514:	lea    r15,[rax-0x1]
    8518:	mov    rax,QWORD PTR [rsp+0x20]
    851d:	mov    r10d,DWORD PTR [rsp+0x78]
    8522:	mov    r9d,r8d
    8525:	mov    rcx,0xffffffffffffffff
    852c:	vxorpd xmm4,xmm4,xmm4
    8530:	mov    r8,r15
    8533:	shr    rax,0x3
    8537:	mov    QWORD PTR [rsp+0x70],rax
    853c:	mov    rax,QWORD PTR [rsp+0x18]
    8541:	and    r10d,0xfffffff8
    8545:	lea    rsi,[rax-0x1]
    8549:	mov    eax,DWORD PTR [rsp+0x78]
    854d:	shr    eax,0x3
    8550:	shl    rax,0x6
    8554:	mov    QWORD PTR [rsp+0x50],rax
    8559:	nop    DWORD PTR [rax+0x0]
    8560:	mov    rdx,QWORD PTR [rsp+0x60]
    8565:	inc    rcx
    8568:	mov    r15,QWORD PTR [rsp+0x68]
    856d:	mov    rax,0xffffffffffffffff
    8574:	movsxd r13,ecx
    8577:	imul   rdx,r13
    857b:	imul   r15,r13
    857f:	add    rdx,r12
    8582:	mov    QWORD PTR [rsp+0x58],rdx
    8587:	vmovq  xmm3,r15
    858c:	mov    r15d,r9d
    858f:	mov    r9,r13
    8592:	mov    r11,QWORD PTR [rsp+0x70]
    8597:	inc    rax
    859a:	movsxd rdx,eax
    859d:	imul   r11,r9
    85a1:	lea    r13,[r11+rdx*1]
    85a5:	vmovsd xmm2,QWORD PTR [rbx+r13*8]
    85ab:	vcomisd xmm2,xmm4
    85af:	je     8732 <bench_ada__run_15.isra.0+0x2e2>
    85b5:	cmp    r14d,0xffffffff
    85b9:	je     8780 <bench_ada__run_15.isra.0+0x330>
    85bf:	mov    DWORD PTR [rsp+0x7c],r15d
    85c4:	mov    QWORD PTR [rsp+0x48],rcx
    85c9:	mov    QWORD PTR [rsp+0x40],r8
    85ce:	cmp    r14d,0x6
    85d2:	jbe    87fe <bench_ada__run_15.isra.0+0x3ae>
    85d8:	mov    rcx,QWORD PTR [rsp+0x60]
    85dd:	mov    r15,QWORD PTR [rsp+0x50]
    85e2:	mov    r11,QWORD PTR [rsp+0x58]
    85e7:	vbroadcastsd zmm1,xmm2
    85ed:	imul   rcx,rdx
    85f1:	add    rcx,rdi
    85f4:	lea    r13,[r15+rcx*1]
    85f8:	mov    r15d,DWORD PTR [rsp+0x7c]
    85fd:	sub    r11,rcx
    8600:	vmulpd zmm0,zmm1,ZMMWORD PTR [rcx+r11*1]
    8607:	add    rcx,0x40
    860b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rcx-0x40]
    8612:	vmovupd ZMMWORD PTR [rcx-0x40],zmm0
    8619:	cmp    rcx,r13
    861c:	jne    8600 <bench_ada__run_15.isra.0+0x1b0>
    861e:	mov    DWORD PTR [rsp+0x7c],r15d
    8623:	mov    r11d,r10d
    8626:	cmp    r10d,DWORD PTR [rsp+0x78]
    862b:	je     8850 <bench_ada__run_15.isra.0+0x400>
    8631:	lea    r13d,[r10-0x1]
    8635:	mov    r8d,DWORD PTR [rsp+0x78]
    863a:	sub    r8d,r11d
    863d:	lea    ecx,[r8-0x1]
    8641:	cmp    ecx,0x2
    8644:	jbe    8682 <bench_ada__run_15.isra.0+0x232>
    8646:	mov    rcx,QWORD PTR [rsp+0x68]
    864b:	vmovq  r15,xmm3
    8650:	vbroadcastsd ymm0,xmm2
    8655:	imul   rcx,rdx
    8659:	add    rcx,r11
    865c:	add    r11,r15
    865f:	vmulpd ymm0,ymm0,YMMWORD PTR [r12+r11*8]
    8665:	vaddpd ymm0,ymm0,YMMWORD PTR [rdi+rcx*8]
    866a:	vmovupd YMMWORD PTR [rdi+rcx*8],ymm0
    866f:	mov    ecx,r8d
    8672:	and    ecx,0xfffffffc
    8675:	and    r8d,0x3
    8679:	je     8810 <bench_ada__run_15.isra.0+0x3c0>
    867f:	add    r13d,ecx
    8682:	imul   rdx,QWORD PTR [rsp+0x68]
    8688:	lea    ecx,[r13+0x1]
    868c:	vmovq  r15,xmm3
    8691:	mov    r8,rcx
    8694:	lea    r11,[rdx+rcx*1]
    8698:	add    rcx,r15
    869b:	vmulsd xmm0,xmm2,QWORD PTR [r12+rcx*8]
    86a1:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r11*8]
    86a7:	vmovsd QWORD PTR [rdi+r11*8],xmm0
    86ad:	cmp    r14d,r8d
    86b0:	je     87b0 <bench_ada__run_15.isra.0+0x360>
    86b6:	lea    ecx,[r13+0x2]
    86ba:	lea    r11,[rdx+rcx*1]
    86be:	mov    r8,rcx
    86c1:	add    rcx,r15
    86c4:	vmulsd xmm0,xmm2,QWORD PTR [r12+rcx*8]
    86ca:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r11*8]
    86d0:	vmovsd QWORD PTR [rdi+r11*8],xmm0
    86d6:	cmp    r14d,r8d
    86d9:	je     87b0 <bench_ada__run_15.isra.0+0x360>
    86df:	lea    ecx,[r13+0x3]
    86e3:	add    rdx,rcx
    86e6:	add    rcx,r15
    86e9:	vmulsd xmm2,xmm2,QWORD PTR [r12+rcx*8]
    86ef:	vaddsd xmm2,xmm2,QWORD PTR [rdi+rdx*8]
    86f4:	vmovsd QWORD PTR [rdi+rdx*8],xmm2
    86f9:	cmp    rax,rsi
    86fc:	je     8820 <bench_ada__run_15.isra.0+0x3d0>
    8702:	mov    rcx,QWORD PTR [rsp+0x70]
    8707:	inc    rax
    870a:	movsxd rdx,eax
    870d:	imul   rcx,r9
    8711:	add    rcx,rdx
    8714:	vmovsd xmm2,QWORD PTR [rbx+rcx*8]
    8719:	vcomisd xmm2,xmm4
    871d:	jne    85ce <bench_ada__run_15.isra.0+0x17e>
    8723:	mov    r15d,DWORD PTR [rsp+0x7c]
    8728:	mov    rcx,QWORD PTR [rsp+0x48]
    872d:	mov    r8,QWORD PTR [rsp+0x40]
    8732:	cmp    rsi,rax
    8735:	jne    8592 <bench_ada__run_15.isra.0+0x142>
    873b:	mov    r9d,r15d
    873e:	cmp    rcx,r8
    8741:	jne    8560 <bench_ada__run_15.isra.0+0x110>
    8747:	mov    r8d,r9d
    874a:	vzeroupper
    874d:	mov    rax,QWORD PTR [rbp+0x10]
    8751:	mov    rsi,QWORD PTR [rbp+0x18]
    8755:	mov    rdx,QWORD PTR [rbp+0x20]
    8759:	mov    rcx,QWORD PTR [rbp+0x30]
    875d:	cmp    DWORD PTR [rsp+0x30],r8d
    8762:	jne    84d0 <bench_ada__run_15.isra.0+0x80>
    8768:	lea    rsp,[rbp-0x28]
    876c:	pop    rbx
    876d:	pop    r12
    876f:	pop    r13
    8771:	pop    r14
    8773:	pop    r15
    8775:	pop    rbp
    8776:	ret
    8777:	nop    WORD PTR [rax+rax*1+0x0]
    8780:	cmp    rsi,rax
    8783:	je     873b <bench_ada__run_15.isra.0+0x2eb>
    8785:	lea    rdx,[rax+0x1]
    8789:	cmp    rdx,rsi
    878c:	je     873b <bench_ada__run_15.isra.0+0x2eb>
    878e:	add    rax,0x2
    8792:	movsxd rdx,eax
    8795:	add    rdx,r11
    8798:	vcomisd xmm4,QWORD PTR [rbx+rdx*8]
    879d:	jne    8780 <bench_ada__run_15.isra.0+0x330>
    879f:	jmp    8732 <bench_ada__run_15.isra.0+0x2e2>
    87a1:	nop    DWORD PTR [rax+0x0]
    87a5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    87b0:	cmp    rax,rsi
    87b3:	je     8820 <bench_ada__run_15.isra.0+0x3d0>
    87b5:	mov    r11,QWORD PTR [rsp+0x70]
    87ba:	lea    rcx,[rax+0x1]
    87be:	movsxd rdx,ecx
    87c1:	imul   r11,r9
    87c5:	lea    r13,[r11+rdx*1]
    87c9:	vmovsd xmm2,QWORD PTR [rbx+r13*8]
    87cf:	vcomisd xmm2,xmm4
    87d3:	jne    8840 <bench_ada__run_15.isra.0+0x3f0>
    87d5:	cmp    rsi,rcx
    87d8:	je     8820 <bench_ada__run_15.isra.0+0x3d0>
    87da:	add    rax,0x2
    87de:	movsxd rdx,eax
    87e1:	add    r11,rdx
    87e4:	vmovsd xmm2,QWORD PTR [rbx+r11*8]
    87ea:	vcomisd xmm2,xmm4
    87ee:	je     8723 <bench_ada__run_15.isra.0+0x2d3>
    87f4:	cmp    r14d,0x6
    87f8:	ja     85d8 <bench_ada__run_15.isra.0+0x188>
    87fe:	xor    r11d,r11d
    8801:	mov    r13d,0xffffffff
    8807:	jmp    8635 <bench_ada__run_15.isra.0+0x1e5>
    880c:	nop    DWORD PTR [rax+0x0]
    8810:	cmp    rax,rsi
    8813:	jne    8702 <bench_ada__run_15.isra.0+0x2b2>
    8819:	nop    DWORD PTR [rax+0x0]
    8820:	mov    r9d,DWORD PTR [rsp+0x7c]
    8825:	mov    rcx,QWORD PTR [rsp+0x48]
    882a:	mov    r8,QWORD PTR [rsp+0x40]
    882f:	jmp    873e <bench_ada__run_15.isra.0+0x2ee>
    8834:	nop
    8835:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8840:	mov    rax,rcx
    8843:	jmp    85ce <bench_ada__run_15.isra.0+0x17e>
    8848:	nop    DWORD PTR [rax+rax*1+0x0]
    8850:	cmp    rax,rsi
    8853:	je     8820 <bench_ada__run_15.isra.0+0x3d0>
    8855:	mov    rcx,QWORD PTR [rsp+0x70]
    885a:	inc    rax
    885d:	movsxd rdx,eax
    8860:	imul   rcx,r9
    8864:	add    rcx,rdx
    8867:	vmovsd xmm2,QWORD PTR [rbx+rcx*8]
    886c:	vcomisd xmm2,xmm4
    8870:	jne    85ce <bench_ada__run_15.isra.0+0x17e>
    8876:	mov    rcx,QWORD PTR [rsp+0x48]
    887b:	mov    r8,QWORD PTR [rsp+0x40]
    8880:	jmp    8732 <bench_ada__run_15.isra.0+0x2e2>
    8885:	nop
    8886:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_16.isra.0>:
    5dc0:	push   rbp
    5dc1:	mov    eax,edi
    5dc3:	mov    r10d,esi
    5dc6:	mov    r11d,edx
    5dc9:	mov    rbp,rsp
    5dcc:	push   r15
    5dce:	push   r14
    5dd0:	push   r13
    5dd2:	push   r12
    5dd4:	push   rbx
    5dd5:	and    rsp,0xffffffffffffffe0
    5dd9:	sub    rsp,0x60
    5ddd:	mov    rdi,QWORD PTR [rbp+0x18]
    5de1:	mov    rsi,QWORD PTR [rbp+0x20]
    5de5:	mov    r15,QWORD PTR [rbp+0x28]
    5de9:	mov    rdx,QWORD PTR [rbp+0x30]
    5ded:	test   ecx,ecx
    5def:	je     6021 <bench_ada__run_16.isra.0+0x261>
    5df5:	mov    r14,QWORD PTR [rbp+0x10]
    5df9:	mov    r12,r8
    5dfc:	mov    rbx,r9
    5dff:	test   r11d,r11d
    5e02:	je     60d7 <bench_ada__run_16.isra.0+0x317>
    5e08:	lea    r14d,[rax-0x1]
    5e0c:	mov    DWORD PTR [rsp+0x34],ecx
    5e10:	mov    ecx,r11d
    5e13:	mov    DWORD PTR [rsp+0x5c],r10d
    5e18:	mov    DWORD PTR [rsp+0x58],r14d
    5e1d:	lea    r14d,[r10-0x1]
    5e21:	mov    DWORD PTR [rsp+0x24],eax
    5e25:	mov    QWORD PTR [rsp+0x28],rcx
    5e2a:	mov    DWORD PTR [rsp+0x4c],r14d
    5e2f:	mov    DWORD PTR [rsp+0x48],0x1
    5e37:	mov    QWORD PTR [rbp+0x18],rdi
    5e3b:	mov    r13d,eax
    5e3e:	mov    rdi,rsi
    5e41:	mov    rsi,rdx
    5e44:	mov    rdx,r15
    5e47:	lea    r15,[rcx*8+0x0]
    5e4f:	mov    eax,DWORD PTR [rsp+0x58]
    5e53:	cmp    eax,0xffffffff
    5e56:	je     60a2 <bench_ada__run_16.isra.0+0x2e2>
    5e5c:	mov    rax,rsi
    5e5f:	mov    esi,DWORD PTR [rsp+0x4c]
    5e63:	cmp    esi,0xffffffff
    5e66:	je     6030 <bench_ada__run_16.isra.0+0x270>
    5e6c:	mov    esi,DWORD PTR [rsp+0x5c]
    5e70:	cmp    esi,0x3
    5e73:	je     64d1 <bench_ada__run_16.isra.0+0x711>
    5e79:	jg     5f45 <bench_ada__run_16.isra.0+0x185>
    5e7f:	dec    esi
    5e81:	je     6417 <bench_ada__run_16.isra.0+0x657>
    5e87:	mov    r14d,DWORD PTR [rsp+0x24]
    5e8c:	mov    rsi,rax
    5e8f:	mov    rax,QWORD PTR [rsp+0x28]
    5e94:	mov    r10,rdx
    5e97:	mov    r11,0xffffffffffffffff
    5e9e:	vxorpd xmm2,xmm2,xmm2
    5ea2:	dec    r14
    5ea5:	lea    r9,[rax-0x1]
    5ea9:	nop    DWORD PTR [rax+0x0]
    5eb0:	inc    r11
    5eb3:	mov    rcx,0xffffffffffffffff
    5eba:	movsxd r8,r11d
    5ebd:	shl    r8,0x4
    5ec1:	add    r8,r12
    5ec4:	nop    DWORD PTR [rax+rax*1+0x0]
    5ec9:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5ed4:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5edf:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5eea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5ef5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f00:	inc    rcx
    5f03:	movsxd rax,ecx
    5f06:	shl    rax,0x4
    5f0a:	add    rax,rbx
    5f0d:	vmovsd xmm0,QWORD PTR [rax]
    5f11:	vmulsd xmm0,xmm0,QWORD PTR [r8]
    5f16:	vmovsd xmm1,QWORD PTR [rax+0x8]
    5f1b:	vmulsd xmm1,xmm1,QWORD PTR [r8+0x8]
    5f21:	vaddsd xmm0,xmm0,xmm1
    5f25:	vaddsd xmm0,xmm0,xmm2
    5f29:	vmovsd QWORD PTR [r10+rcx*8],xmm0
    5f2f:	cmp    rcx,r9
    5f32:	jne    5f00 <bench_ada__run_16.isra.0+0x140>
    5f34:	add    r10,r15
    5f37:	cmp    r11,r14
    5f3a:	jne    5eb0 <bench_ada__run_16.isra.0+0xf0>
    5f40:	jmp    600c <bench_ada__run_16.isra.0+0x24c>
    5f45:	cmp    DWORD PTR [rsp+0x5c],0x4
    5f4a:	jne    60fa <bench_ada__run_16.isra.0+0x33a>
    5f50:	mov    rsi,rax
    5f53:	mov    rax,QWORD PTR [rsp+0x28]
    5f58:	mov    r14d,DWORD PTR [rsp+0x24]
    5f5d:	mov    r10,rdx
    5f60:	xor    r11d,r11d
    5f63:	lea    r9,[rax-0x1]
    5f67:	nop    WORD PTR [rax+rax*1+0x0]
    5f70:	movsxd r8,r11d
    5f73:	mov    rax,0xffffffffffffffff
    5f7a:	shl    r8,0x5
    5f7e:	add    r8,r12
    5f81:	nop    DWORD PTR [rax+rax*1+0x0]
    5f89:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f94:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5f9f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5faa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5fb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5fc0:	inc    rax
    5fc3:	vmovupd ymm0,YMMWORD PTR [r8]
    5fc8:	movsxd rcx,eax
    5fcb:	shl    rcx,0x5
    5fcf:	vmulpd ymm0,ymm0,YMMWORD PTR [rcx+rbx*1]
    5fd4:	vextractf64x2 xmm2,ymm0,0x1
    5fdb:	vunpckhpd xmm1,xmm0,xmm0
    5fdf:	vaddsd xmm2,xmm2,xmm0
    5fe3:	valignq ymm0,ymm0,ymm0,0x3
    5fea:	vaddsd xmm1,xmm1,xmm0
    5fee:	vaddsd xmm1,xmm2,xmm1
    5ff2:	vmovsd QWORD PTR [r10+rax*8],xmm1
    5ff8:	cmp    rax,r9
    5ffb:	jne    5fc0 <bench_ada__run_16.isra.0+0x200>
    5ffd:	inc    r11
    6000:	add    r10,r15
    6003:	cmp    r14,r11
    6006:	jne    5f70 <bench_ada__run_16.isra.0+0x1b0>
    600c:	mov    rax,QWORD PTR [rbp+0x10]
    6010:	mov    rcx,QWORD PTR [rbp+0x18]
    6014:	mov    eax,DWORD PTR [rsp+0x48]
    6018:	cmp    DWORD PTR [rsp+0x34],eax
    601c:	jne    608f <bench_ada__run_16.isra.0+0x2cf>
    601e:	vzeroupper
    6021:	lea    rsp,[rbp-0x28]
    6025:	pop    rbx
    6026:	pop    r12
    6028:	pop    r13
    602a:	pop    r14
    602c:	pop    r15
    602e:	pop    rbp
    602f:	ret
    6030:	mov    QWORD PTR [rsp+0x50],r12
    6035:	mov    QWORD PTR [rsp+0x40],rbx
    603a:	mov    QWORD PTR [rbp+0x20],rdi
    603e:	xor    ebx,ebx
    6040:	mov    rcx,rdx
    6043:	mov    r12,rdx
    6046:	mov    r14,rax
    6049:	vzeroupper
    604c:	nop    DWORD PTR [rax+0x0]
    6050:	mov    rdi,rcx
    6053:	mov    rdx,r15
    6056:	xor    esi,esi
    6058:	inc    rbx
    605b:	call   2bd0 <memset@plt>
    6060:	lea    rcx,[rax+r15*1]
    6064:	cmp    rbx,r13
    6067:	jne    6050 <bench_ada__run_16.isra.0+0x290>
    6069:	mov    rdx,r12
    606c:	mov    rbx,QWORD PTR [rsp+0x40]
    6071:	mov    rdi,QWORD PTR [rbp+0x20]
    6075:	mov    r12,QWORD PTR [rsp+0x50]
    607a:	mov    rax,QWORD PTR [rbp+0x10]
    607e:	mov    rcx,QWORD PTR [rbp+0x18]
    6082:	mov    rsi,r14
    6085:	mov    eax,DWORD PTR [rsp+0x48]
    6089:	cmp    DWORD PTR [rsp+0x34],eax
    608d:	je     6021 <bench_ada__run_16.isra.0+0x261>
    608f:	inc    eax
    6091:	mov    rcx,QWORD PTR [rbp+0x18]
    6095:	mov    DWORD PTR [rsp+0x48],eax
    6099:	mov    rax,QWORD PTR [rbp+0x10]
    609d:	jmp    5e4f <bench_ada__run_16.isra.0+0x8f>
    60a2:	mov    r15,rdx
    60a5:	mov    ecx,DWORD PTR [rsp+0x48]
    60a9:	mov    rdx,rsi
    60ac:	mov    rax,QWORD PTR [rbp+0x10]
    60b0:	mov    rsi,rdi
    60b3:	mov    r8d,DWORD PTR [rsp+0x34]
    60b8:	mov    rdi,QWORD PTR [rbp+0x18]
    60bc:	cmp    r8d,ecx
    60bf:	je     601e <bench_ada__run_16.isra.0+0x25e>
    60c5:	lea    r9d,[rcx+0x1]
    60c9:	cmp    r8d,r9d
    60cc:	je     601e <bench_ada__run_16.isra.0+0x25e>
    60d2:	add    ecx,0x2
    60d5:	jmp    60bc <bench_ada__run_16.isra.0+0x2fc>
    60d7:	mov    r8,QWORD PTR [rbp+0x10]
    60db:	mov    eax,0x1
    60e0:	cmp    ecx,eax
    60e2:	je     6021 <bench_ada__run_16.isra.0+0x261>
    60e8:	lea    r9d,[rax+0x1]
    60ec:	cmp    ecx,r9d
    60ef:	je     6021 <bench_ada__run_16.isra.0+0x261>
    60f5:	add    eax,0x2
    60f8:	jmp    60e0 <bench_ada__run_16.isra.0+0x320>
    60fa:	vmovd  xmm7,DWORD PTR [rsp+0x5c]
    6100:	vmovd  xmm14,DWORD PTR [rsp+0x58]
    6106:	mov    QWORD PTR [rsp+0x50],rdx
    610b:	mov    QWORD PTR [rbp+0x20],rdi
    610f:	vmovd  xmm5,DWORD PTR [rsp+0x4c]
    6115:	mov    QWORD PTR [rbp+0x28],rdx
    6119:	lea    r10,[r12+0x20]
    611e:	mov    QWORD PTR [rbp+0x30],rax
    6122:	vmovq  xmm18,r13
    6128:	mov    rax,0xffffffffffffffff
    612f:	vmovq  xmm17,r15
    6135:	vmovq  xmm4,r10
    613a:	vmovq  rsi,xmm7
    613f:	mov    r9d,esi
    6142:	sar    r9d,0x2
    6146:	and    esi,0x3
    6149:	dec    r9d
    614c:	mov    DWORD PTR [rsp+0x20],esi
    6150:	mov    rsi,QWORD PTR [rsp+0x28]
    6155:	mov    r14d,r9d
    6158:	sar    r14d,1
    615b:	lea    ecx,[r14-0x1]
    615f:	mov    DWORD PTR [rsp+0x30],r14d
    6164:	sub    r14d,0x3
    6168:	lea    r8,[rsi-0x1]
    616c:	lea    esi,[r9*4+0x0]
    6174:	or     r14d,0x1
    6178:	mov    r13d,ecx
    617b:	mov    QWORD PTR [rsp+0x40],r8
    6180:	vmovq  xmm3,rsi
    6185:	inc    rax
    6188:	vmovq  rdx,xmm7
    618d:	vmovq  rdi,xmm4
    6192:	movsxd r10,eax
    6195:	mov    QWORD PTR [rsp+0x18],rax
    619a:	mov    rax,0xffffffffffffffff
    61a1:	imul   r10,rdx
    61a5:	lea    r11,[r10*8+0x0]
    61ad:	mov    r15,r10
    61b0:	add    rdi,r11
    61b3:	lea    rsi,[r12+r11*1]
    61b7:	mov    QWORD PTR [rsp+0x38],rdi
    61bc:	vmovq  rdi,xmm3
    61c1:	add    rdi,r10
    61c4:	lea    rdi,[r12+rdi*8]
    61c8:	vmovq  xmm6,rdi
    61cd:	vmovq  rdi,xmm5
    61d2:	add    rdi,r10
    61d5:	vmovq  xmm15,rdi
    61da:	nop    WORD PTR [rax+rax*1+0x0]
    61e0:	inc    rax
    61e3:	mov    r9,rdx
    61e6:	vmovupd ymm0,YMMWORD PTR [rsi]
    61ea:	movsxd r8,eax
    61ed:	imul   r9,r8
    61f1:	vmulpd ymm0,ymm0,YMMWORD PTR [rbx+r9*8]
    61f7:	cmp    r13d,0xffffffff
    61fb:	je     6360 <bench_ada__run_16.isra.0+0x5a0>
    6201:	cmp    DWORD PTR [rsp+0x30],0x2
    6206:	jle    640c <bench_ada__run_16.isra.0+0x64c>
    620c:	mov    rcx,QWORD PTR [rsp+0x38]
    6211:	lea    rdi,[rbx+r9*8+0x20]
    6216:	mov    r11d,0xffffffff
    621c:	vmovupd ymm2,YMMWORD PTR [rdi]
    6220:	vmulpd ymm2,ymm2,YMMWORD PTR [rcx]
    6224:	vmovupd ymm1,YMMWORD PTR [rdi+0x20]
    6229:	add    r11d,0x2
    622d:	vmulpd ymm1,ymm1,YMMWORD PTR [rcx+0x20]
    6232:	sub    rdi,0xffffffffffffff80
    6236:	sub    rcx,0xffffffffffffff80
    623a:	vaddpd ymm0,ymm2,ymm0
    623e:	vaddpd ymm1,ymm1,ymm0
    6242:	vmovupd ymm0,YMMWORD PTR [rdi-0x40]
    6247:	vmulpd ymm0,ymm0,YMMWORD PTR [rcx-0x40]
    624c:	vaddpd ymm1,ymm1,ymm0
    6250:	vmovupd ymm0,YMMWORD PTR [rdi-0x20]
    6255:	vmulpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    625a:	vaddpd ymm0,ymm1,ymm0
    625e:	cmp    r11d,r14d
    6261:	jne    621c <bench_ada__run_16.isra.0+0x45c>
    6263:	movsxd rcx,r11d
    6266:	inc    r11d
    6269:	shl    rcx,0x3
    626d:	lea    rdi,[r9+rcx*1+0xc]
    6272:	lea    r10,[r15+rcx*1+0xc]
    6277:	vmovupd ymm1,YMMWORD PTR [r12+r10*8]
    627d:	vmulpd ymm1,ymm1,YMMWORD PTR [rbx+rdi*8]
    6282:	vmovupd ymm10,YMMWORD PTR [r12+r10*8+0x20]
    6289:	vmulpd ymm10,ymm10,YMMWORD PTR [rbx+rdi*8+0x20]
    628f:	vaddpd ymm0,ymm1,ymm0
    6293:	vaddpd ymm0,ymm10,ymm0
    6297:	cmp    r11d,r13d
    629a:	je     62c6 <bench_ada__run_16.isra.0+0x506>
    629c:	lea    rdi,[r9+rcx*1+0x14]
    62a1:	lea    rcx,[r15+rcx*1+0x14]
    62a6:	vmovupd ymm1,YMMWORD PTR [rbx+rdi*8]
    62ab:	vmulpd ymm1,ymm1,YMMWORD PTR [r12+rcx*8]
    62b1:	vaddpd ymm1,ymm1,ymm0
    62b5:	vmovupd ymm0,YMMWORD PTR [rbx+rdi*8+0x20]
    62bb:	vmulpd ymm0,ymm0,YMMWORD PTR [r12+rcx*8+0x20]
    62c2:	vaddpd ymm0,ymm0,ymm1
    62c6:	test   BYTE PTR [rsp+0x5c],0x4
    62cb:	jne    62e9 <bench_ada__run_16.isra.0+0x529>
    62cd:	vmovq  rdi,xmm3
    62d2:	add    r9,rdi
    62d5:	vmovq  rdi,xmm6
    62da:	vmovupd ymm10,YMMWORD PTR [rdi]
    62de:	vmulpd ymm10,ymm10,YMMWORD PTR [rbx+r9*8]
    62e4:	vaddpd ymm0,ymm0,ymm10
    62e9:	cmp    DWORD PTR [rsp+0x20],0x0
    62ee:	jne    636b <bench_ada__run_16.isra.0+0x5ab>
    62f0:	vunpckhpd xmm11,xmm0,xmm0
    62f4:	vextractf64x2 xmm12,ymm0,0x1
    62fb:	vaddsd xmm10,xmm0,xmm12
    6300:	valignq ymm0,ymm0,ymm0,0x3
    6307:	vaddsd xmm11,xmm11,xmm0
    630b:	vaddsd xmm0,xmm10,xmm11
    6310:	mov    rdi,QWORD PTR [rsp+0x50]
    6315:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    631a:	cmp    QWORD PTR [rsp+0x40],rax
    631f:	jne    61e0 <bench_ada__run_16.isra.0+0x420>
    6325:	mov    rax,QWORD PTR [rsp+0x18]
    632a:	vmovq  rdx,xmm14
    632f:	vmovq  rdi,xmm17
    6335:	add    QWORD PTR [rsp+0x50],rdi
    633a:	cmp    rax,rdx
    633d:	jne    6185 <bench_ada__run_16.isra.0+0x3c5>
    6343:	mov    rdi,QWORD PTR [rbp+0x20]
    6347:	mov    rdx,QWORD PTR [rbp+0x28]
    634b:	mov    rax,QWORD PTR [rbp+0x30]
    634f:	vmovq  r15,xmm17
    6355:	vmovq  r13,xmm18
    635b:	jmp    64a8 <bench_ada__run_16.isra.0+0x6e8>
    6360:	cmp    DWORD PTR [rsp+0x5c],0x7
    6365:	jg     62c6 <bench_ada__run_16.isra.0+0x506>
    636b:	imul   r8,rdx
    636f:	vmovq  rdi,xmm5
    6374:	lea    rcx,[r8+rdi*1]
    6378:	vmovq  rdi,xmm15
    637d:	vmovsd xmm12,QWORD PTR [rbx+rcx*8]
    6382:	vmulsd xmm12,xmm12,QWORD PTR [r12+rdi*8]
    6388:	mov    edi,DWORD PTR [rsp+0x20]
    638c:	cmp    edi,0x2
    638f:	je     6561 <bench_ada__run_16.isra.0+0x7a1>
    6395:	cmp    edi,0x3
    6398:	jne    63e2 <bench_ada__run_16.isra.0+0x622>
    639a:	vmovq  rdi,xmm5
    639f:	vmovq  rcx,xmm5
    63a4:	lea    rdi,[r8+rdi*1-0x2]
    63a9:	lea    rcx,[r15+rcx*1-0x2]
    63ae:	vmovsd xmm10,QWORD PTR [rbx+rdi*8]
    63b3:	vmovq  rdi,xmm5
    63b8:	vmulsd xmm10,xmm10,QWORD PTR [r12+rcx*8]
    63be:	vmovq  rcx,xmm5
    63c3:	lea    rdi,[r8+rdi*1-0x1]
    63c8:	lea    rcx,[r15+rcx*1-0x1]
    63cd:	vmovsd xmm11,QWORD PTR [rbx+rdi*8]
    63d2:	vmulsd xmm11,xmm11,QWORD PTR [r12+rcx*8]
    63d8:	vaddsd xmm10,xmm10,xmm11
    63dd:	vaddsd xmm12,xmm12,xmm10
    63e2:	vextractf64x2 xmm13,ymm0,0x1
    63e9:	vunpckhpd xmm11,xmm0,xmm0
    63ed:	vaddsd xmm10,xmm0,xmm13
    63f2:	valignq ymm0,ymm0,ymm0,0x3
    63f9:	vaddsd xmm11,xmm11,xmm0
    63fd:	vaddsd xmm0,xmm10,xmm11
    6402:	vaddsd xmm0,xmm0,xmm12
    6407:	jmp    6310 <bench_ada__run_16.isra.0+0x550>
    640c:	mov    r11d,0xffffffff
    6412:	jmp    6263 <bench_ada__run_16.isra.0+0x4a3>
    6417:	mov    r14d,DWORD PTR [rsp+0x24]
    641c:	mov    rsi,QWORD PTR [rsp+0x28]
    6421:	mov    r9,rdx
    6424:	mov    r11,0xffffffffffffffff
    642b:	vxorpd xmm1,xmm1,xmm1
    642f:	dec    r14
    6432:	lea    r8,[rsi-0x1]
    6436:	cs nop WORD PTR [rax+rax*1+0x0]
    6440:	inc    r11
    6443:	mov    rcx,0xffffffffffffffff
    644a:	movsxd r10,r11d
    644d:	nop    DWORD PTR [rax+0x0]
    6454:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    645f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    646a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6475:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6480:	inc    rcx
    6483:	movsxd rsi,ecx
    6486:	vmovsd xmm0,QWORD PTR [rbx+rsi*8]
    648b:	vmulsd xmm0,xmm0,QWORD PTR [r12+r10*8]
    6491:	vaddsd xmm0,xmm0,xmm1
    6495:	vmovsd QWORD PTR [r9+rcx*8],xmm0
    649b:	cmp    rcx,r8
    649e:	jne    6480 <bench_ada__run_16.isra.0+0x6c0>
    64a0:	add    r9,r15
    64a3:	cmp    r11,r14
    64a6:	jne    6440 <bench_ada__run_16.isra.0+0x680>
    64a8:	mov    rsi,QWORD PTR [rbp+0x10]
    64ac:	mov    rcx,QWORD PTR [rbp+0x18]
    64b0:	mov    esi,DWORD PTR [rsp+0x48]
    64b4:	cmp    DWORD PTR [rsp+0x34],esi
    64b8:	je     601e <bench_ada__run_16.isra.0+0x25e>
    64be:	inc    esi
    64c0:	mov    rcx,QWORD PTR [rbp+0x18]
    64c4:	mov    DWORD PTR [rsp+0x48],esi
    64c8:	mov    rsi,QWORD PTR [rbp+0x10]
    64cc:	jmp    5e5f <bench_ada__run_16.isra.0+0x9f>
    64d1:	mov    r14d,DWORD PTR [rsp+0x24]
    64d6:	mov    rsi,QWORD PTR [rsp+0x28]
    64db:	mov    r10,rdx
    64de:	mov    r11,0xffffffffffffffff
    64e5:	vxorpd xmm2,xmm2,xmm2
    64e9:	dec    r14
    64ec:	lea    r8,[rsi-0x1]
    64f0:	inc    r11
    64f3:	mov    rcx,0xffffffffffffffff
    64fa:	movsxd rsi,r11d
    64fd:	lea    rsi,[rsi+rsi*2]
    6501:	lea    r9,[r12+rsi*8]
    6505:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6510:	inc    rcx
    6513:	movsxd rsi,ecx
    6516:	lea    rsi,[rsi+rsi*2]
    651a:	lea    rsi,[rbx+rsi*8]
    651e:	vmovsd xmm0,QWORD PTR [rsi]
    6522:	vmulsd xmm0,xmm0,QWORD PTR [r9]
    6527:	vmovsd xmm1,QWORD PTR [rsi+0x8]
    652c:	vmulsd xmm1,xmm1,QWORD PTR [r9+0x8]
    6532:	vaddsd xmm0,xmm0,xmm1
    6536:	vmovsd xmm1,QWORD PTR [rsi+0x10]
    653b:	vmulsd xmm1,xmm1,QWORD PTR [r9+0x10]
    6541:	vaddsd xmm0,xmm0,xmm1
    6545:	vaddsd xmm0,xmm0,xmm2
    6549:	vmovsd QWORD PTR [r10+rcx*8],xmm0
    654f:	cmp    rcx,r8
    6552:	jne    6510 <bench_ada__run_16.isra.0+0x750>
    6554:	add    r10,r15
    6557:	cmp    r11,r14
    655a:	jne    64f0 <bench_ada__run_16.isra.0+0x730>
    655c:	jmp    64a8 <bench_ada__run_16.isra.0+0x6e8>
    6561:	vmovq  rdi,xmm5
    6566:	vmovq  rcx,xmm5
    656b:	lea    rdi,[r8+rdi*1-0x1]
    6570:	lea    rcx,[r15+rcx*1-0x1]
    6575:	vmovsd xmm10,QWORD PTR [rbx+rdi*8]
    657a:	vmulsd xmm10,xmm10,QWORD PTR [r12+rcx*8]
    6580:	vaddsd xmm12,xmm12,xmm10
    6585:	jmp    63e2 <bench_ada__run_16.isra.0+0x622>
    658a:	nop    WORD PTR [rax+rax*1+0x0]


<bench_ada__run_17.isra.0>:
    8890:	push   rbp
    8891:	mov    rbp,rsp
    8894:	push   r15
    8896:	push   r14
    8898:	push   r13
    889a:	push   r12
    889c:	push   rbx
    889d:	and    rsp,0xffffffffffffffc0
    88a1:	add    rsp,0xffffffffffffff80
    88a5:	mov    r10,QWORD PTR [rbp+0x20]
    88a9:	mov    QWORD PTR [rsp+0x58],r8
    88ae:	mov    QWORD PTR [rsp+0x50],r9
    88b3:	test   edx,edx
    88b5:	je     8cca <bench_ada__run_17.isra.0+0x43a>
    88bb:	mov    DWORD PTR [rsp+0x34],edi
    88bf:	dec    edi
    88c1:	mov    rbx,rcx
    88c4:	mov    ecx,esi
    88c6:	mov    DWORD PTR [rsp+0x40],edi
    88ca:	lea    edi,[rsi-0x1]
    88cd:	mov    DWORD PTR [rsp+0x44],edx
    88d1:	lea    rdx,[rcx*8+0x0]
    88d9:	mov    DWORD PTR [rsp+0x48],edi
    88dd:	mov    rdi,rcx
    88e0:	xor    eax,eax
    88e2:	lea    r14,[rcx-0x1]
    88e6:	imul   rdi,rdx
    88ea:	test   esi,esi
    88ec:	cmovne rax,rdx
    88f0:	mov    r12,rax
    88f3:	xor    eax,eax
    88f5:	mov    QWORD PTR [rsp+0x38],rdi
    88fa:	mov    DWORD PTR [rsp+0x4c],eax
    88fe:	xchg   ax,ax
    8900:	inc    DWORD PTR [rsp+0x4c]
    8904:	mov    rax,QWORD PTR [rsp+0x58]
    8909:	mov    rdi,QWORD PTR [rsp+0x50]
    890e:	mov    rdx,QWORD PTR [rbp+0x10]
    8912:	mov    rsi,QWORD PTR [rbp+0x18]
    8916:	mov    rcx,QWORD PTR [rbp+0x28]
    891a:	mov    eax,DWORD PTR [rsp+0x48]
    891e:	cmp    eax,0xffffffff
    8921:	je     8d28 <bench_ada__run_17.isra.0+0x498>
    8927:	mov    rdx,QWORD PTR [rsp+0x38]
    892c:	mov    rdi,r10
    892f:	xor    esi,esi
    8931:	call   2bd0 <memset@plt>
    8936:	vxorpd xmm6,xmm6,xmm6
    893a:	mov    r10,rax
    893d:	mov    eax,DWORD PTR [rsp+0x40]
    8941:	cmp    eax,0xffffffff
    8944:	je     8b48 <bench_ada__run_17.isra.0+0x2b8>
    894a:	mov    eax,DWORD PTR [rsp+0x34]
    894e:	mov    QWORD PTR [rsp+0x70],r12
    8953:	mov    r8,0xffffffffffffffff
    895a:	vmovq  xmm3,r14
    895f:	lea    rcx,[rax-0x1]
    8963:	mov    rax,r12
    8966:	shr    rax,0x3
    896a:	mov    QWORD PTR [rsp+0x60],rcx
    896f:	mov    QWORD PTR [rsp+0x78],rax
    8974:	nop
    8975:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8980:	mov    r15,QWORD PTR [rsp+0x70]
    8985:	inc    r8
    8988:	mov    r9d,0x1
    898e:	movsxd rdx,r8d
    8991:	imul   r15,rdx
    8995:	lea    rax,[r15+rbx*1]
    8999:	mov    r15,QWORD PTR [rsp+0x78]
    899e:	mov    QWORD PTR [rsp+0x68],rax
    89a3:	vmovq  rax,xmm3
    89a8:	imul   r15,rdx
    89ac:	mov    rdx,0xffffffffffffffff
    89b3:	mov    r12,r15
    89b6:	jmp    89cc <bench_ada__run_17.isra.0+0x13c>
    89b8:	nop    DWORD PTR [rax+rax*1+0x0]
    89c0:	inc    r9d
    89c3:	cmp    rdx,rax
    89c6:	je     8b30 <bench_ada__run_17.isra.0+0x2a0>
    89cc:	inc    rdx
    89cf:	movsxd r15,edx
    89d2:	mov    r14d,edx
    89d5:	lea    rcx,[r12+r15*1]
    89d9:	vmovsd xmm1,QWORD PTR [rbx+rcx*8]
    89de:	vbroadcastsd zmm2,xmm1
    89e4:	test   edx,edx
    89e6:	js     89c0 <bench_ada__run_17.isra.0+0x130>
    89e8:	vcomisd xmm1,xmm6
    89ec:	je     89c0 <bench_ada__run_17.isra.0+0x130>
    89ee:	mov    r13d,edx
    89f1:	cmp    edx,0x6
    89f4:	jbe    8ce0 <bench_ada__run_17.isra.0+0x450>
    89fa:	mov    rcx,QWORD PTR [rsp+0x70]
    89ff:	mov    r11,QWORD PTR [rsp+0x68]
    8a04:	mov    edi,r9d
    8a07:	shr    edi,0x3
    8a0a:	vmovapd zmm4,zmm2
    8a10:	mov    esi,edi
    8a12:	imul   rcx,r15
    8a16:	shl    rsi,0x6
    8a1a:	add    rcx,r10
    8a1d:	add    rsi,rcx
    8a20:	sub    r11,rcx
    8a23:	nop    DWORD PTR [rax+0x0]
    8a2a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8a35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8a40:	vmulpd zmm0,zmm4,ZMMWORD PTR [rcx+r11*1]
    8a47:	add    rcx,0x40
    8a4b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rcx-0x40]
    8a52:	vmovupd ZMMWORD PTR [rcx-0x40],zmm0
    8a59:	cmp    rsi,rcx
    8a5c:	jne    8a40 <bench_ada__run_17.isra.0+0x1b0>
    8a5e:	shl    edi,0x3
    8a61:	cmp    r9d,edi
    8a64:	je     89c0 <bench_ada__run_17.isra.0+0x130>
    8a6a:	lea    ecx,[rdi-0x1]
    8a6d:	sub    r13d,edi
    8a70:	cmp    r13d,0x2
    8a74:	jbe    8aab <bench_ada__run_17.isra.0+0x21b>
    8a76:	mov    rsi,QWORD PTR [rsp+0x78]
    8a7b:	inc    r13d
    8a7e:	imul   rsi,r15
    8a82:	add    rsi,rdi
    8a85:	add    rdi,r12
    8a88:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+rdi*8]
    8a8d:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+rsi*8]
    8a93:	vmovupd YMMWORD PTR [r10+rsi*8],ymm2
    8a99:	mov    esi,r13d
    8a9c:	and    esi,0xfffffffc
    8a9f:	and    r13d,0x3
    8aa3:	je     89c0 <bench_ada__run_17.isra.0+0x130>
    8aa9:	add    ecx,esi
    8aab:	mov    r11,QWORD PTR [rsp+0x78]
    8ab0:	lea    esi,[rcx+0x1]
    8ab3:	mov    rdi,rsi
    8ab6:	imul   r11,r15
    8aba:	lea    r13,[r11+rsi*1]
    8abe:	add    rsi,r12
    8ac1:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    8ac6:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    8acc:	vmovsd QWORD PTR [r10+r13*8],xmm0
    8ad2:	cmp    edi,r14d
    8ad5:	je     89c0 <bench_ada__run_17.isra.0+0x130>
    8adb:	lea    esi,[rcx+0x2]
    8ade:	lea    r13,[r11+rsi*1]
    8ae2:	mov    rdi,rsi
    8ae5:	add    rsi,r12
    8ae8:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    8aed:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    8af3:	vmovsd QWORD PTR [r10+r13*8],xmm0
    8af9:	cmp    r14d,edi
    8afc:	je     89c0 <bench_ada__run_17.isra.0+0x130>
    8b02:	add    ecx,0x3
    8b05:	inc    r9d
    8b08:	lea    r15,[r11+rcx*1]
    8b0c:	add    rcx,r12
    8b0f:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    8b14:	vaddsd xmm1,xmm1,QWORD PTR [r10+r15*8]
    8b1a:	vmovsd QWORD PTR [r10+r15*8],xmm1
    8b20:	cmp    rdx,rax
    8b23:	jne    89cc <bench_ada__run_17.isra.0+0x13c>
    8b29:	nop    DWORD PTR [rax+0x0]
    8b30:	cmp    r8,QWORD PTR [rsp+0x60]
    8b35:	jne    8980 <bench_ada__run_17.isra.0+0xf0>
    8b3b:	mov    r12,QWORD PTR [rsp+0x70]
    8b40:	vmovq  r14,xmm3
    8b45:	vzeroupper
    8b48:	mov    eax,DWORD PTR [rsp+0x48]
    8b4c:	lea    r13,[r12+r12*1]
    8b50:	mov    r11,r12
    8b53:	shr    r11,0x3
    8b57:	vmovq  xmm5,r13
    8b5c:	mov    QWORD PTR [rsp+0x70],rbx
    8b61:	mov    r8d,0x1
    8b67:	mov    rsi,0xffffffffffffffff
    8b6e:	mov    QWORD PTR [rsp+0x78],rax
    8b73:	mov    r15,rax
    8b76:	jmp    8b8c <bench_ada__run_17.isra.0+0x2fc>
    8b78:	nop    DWORD PTR [rax+rax*1+0x0]
    8b80:	inc    r8d
    8b83:	cmp    rsi,r14
    8b86:	je     8ca1 <bench_ada__run_17.isra.0+0x411>
    8b8c:	mov    rdx,rsi
    8b8f:	inc    rsi
    8b92:	cmp    r15d,r8d
    8b95:	jl     8b80 <bench_ada__run_17.isra.0+0x2f0>
    8b97:	mov    rcx,QWORD PTR [rsp+0x78]
    8b9c:	movsxd rax,r8d
    8b9f:	lea    r9,[rax-0x1]
    8ba3:	sub    rcx,rax
    8ba6:	cmp    rcx,0xe
    8baa:	jbe    8cec <bench_ada__run_17.isra.0+0x45c>
    8bb0:	imul   rax,r11
    8bb4:	mov    rbx,rsi
    8bb7:	imul   rbx,r11
    8bbb:	add    rax,rdx
    8bbe:	movsxd rdx,esi
    8bc1:	add    rdx,rbx
    8bc4:	shl    rdx,0x3
    8bc8:	lea    rbx,[r10+rdx*1]
    8bcc:	vmovq  xmm1,rbx
    8bd1:	lea    rbx,[rdx+r10*1+0x8]
    8bd6:	mov    r13,rbx
    8bd9:	mov    rbx,r12
    8bdc:	imul   rbx,rcx
    8be0:	shl    rax,0x3
    8be4:	lea    rdi,[r10+rax*1]
    8be8:	lea    rbx,[rdi+rbx*1+0x8]
    8bed:	cmp    rbx,r13
    8bf0:	jb     8c09 <bench_ada__run_17.isra.0+0x379>
    8bf2:	vmovq  rbx,xmm1
    8bf7:	add    rdi,0x8
    8bfb:	lea    rbx,[rbx+rcx*8+0x8]
    8c00:	cmp    rbx,rdi
    8c03:	jae    8cec <bench_ada__run_17.isra.0+0x45c>
    8c09:	cmp    r15d,r8d
    8c0c:	je     8c72 <bench_ada__run_17.isra.0+0x3e2>
    8c0e:	lea    rbx,[rcx+0x1]
    8c12:	dec    rcx
    8c15:	lea    rax,[rax+r10*1+0x8]
    8c1a:	vmovq  r13,xmm5
    8c1f:	shr    rcx,1
    8c22:	lea    rdi,[rcx+0x1]
    8c26:	lea    rcx,[rdx+r10*1+0x8]
    8c2b:	xor    edx,edx
    8c2d:	nop    DWORD PTR [rax+rax*1+0x0]
    8c35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8c40:	vmovsd xmm0,QWORD PTR [rax]
    8c44:	vmovhpd xmm0,xmm0,QWORD PTR [r12+rax*1]
    8c4a:	inc    rdx
    8c4d:	add    rax,r13
    8c50:	add    rcx,0x10
    8c54:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    8c59:	cmp    rdx,rdi
    8c5c:	jb     8c40 <bench_ada__run_17.isra.0+0x3b0>
    8c5e:	add    rdi,rdi
    8c61:	vmovq  xmm5,r13
    8c66:	cmp    rbx,rdi
    8c69:	je     8b80 <bench_ada__run_17.isra.0+0x2f0>
    8c6f:	add    r9,rdi
    8c72:	inc    r9
    8c75:	mov    rax,r11
    8c78:	inc    r8d
    8c7b:	imul   rax,r9
    8c7f:	add    rax,rsi
    8c82:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    8c88:	mov    rax,rsi
    8c8b:	imul   rax,r11
    8c8f:	add    rax,r9
    8c92:	vmovsd QWORD PTR [r10+rax*8],xmm0
    8c98:	cmp    rsi,r14
    8c9b:	jne    8b8c <bench_ada__run_17.isra.0+0x2fc>
    8ca1:	mov    rbx,QWORD PTR [rsp+0x70]
    8ca6:	mov    rax,QWORD PTR [rsp+0x58]
    8cab:	mov    rdi,QWORD PTR [rsp+0x50]
    8cb0:	mov    rdx,QWORD PTR [rbp+0x10]
    8cb4:	mov    rsi,QWORD PTR [rbp+0x18]
    8cb8:	mov    rcx,QWORD PTR [rbp+0x28]
    8cbc:	mov    edi,DWORD PTR [rsp+0x4c]
    8cc0:	cmp    DWORD PTR [rsp+0x44],edi
    8cc4:	jne    8900 <bench_ada__run_17.isra.0+0x70>
    8cca:	lea    rsp,[rbp-0x28]
    8cce:	pop    rbx
    8ccf:	pop    r12
    8cd1:	pop    r13
    8cd3:	pop    r14
    8cd5:	pop    r15
    8cd7:	pop    rbp
    8cd8:	ret
    8cd9:	nop    DWORD PTR [rax+0x0]
    8ce0:	xor    edi,edi
    8ce2:	mov    ecx,0xffffffff
    8ce7:	jmp    8a6d <bench_ada__run_17.isra.0+0x1dd>
    8cec:	mov    rdx,rsi
    8cef:	vmovq  r13,xmm5
    8cf4:	imul   rdx,r12
    8cf8:	add    rdx,r10
    8cfb:	nop    DWORD PTR [rax+rax*1+0x0]
    8d00:	inc    r9
    8d03:	mov    rax,r11
    8d06:	imul   rax,r9
    8d0a:	add    rax,rsi
    8d0d:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    8d13:	vmovsd QWORD PTR [rdx+r9*8],xmm0
    8d19:	cmp    r9,r14
    8d1c:	jne    8d00 <bench_ada__run_17.isra.0+0x470>
    8d1e:	vmovq  xmm5,r13
    8d23:	jmp    8b80 <bench_ada__run_17.isra.0+0x2f0>
    8d28:	mov    eax,DWORD PTR [rsp+0x40]
    8d2c:	mov    r9d,DWORD PTR [rsp+0x4c]
    8d31:	mov    rdx,QWORD PTR [rsp+0x50]
    8d36:	mov    rcx,QWORD PTR [rbp+0x10]
    8d3a:	mov    rsi,QWORD PTR [rbp+0x18]
    8d3e:	mov    rdi,QWORD PTR [rbp+0x28]
    8d42:	mov    r8d,DWORD PTR [rsp+0x44]
    8d47:	cmp    eax,0xffffffff
    8d4a:	mov    rax,QWORD PTR [rsp+0x58]
    8d4f:	jne    8d56 <bench_ada__run_17.isra.0+0x4c6>
    8d51:	jmp    8d60 <bench_ada__run_17.isra.0+0x4d0>
    8d53:	inc    r9d
    8d56:	cmp    r8d,r9d
    8d59:	jne    8d53 <bench_ada__run_17.isra.0+0x4c3>
    8d5b:	jmp    8cca <bench_ada__run_17.isra.0+0x43a>
    8d60:	cmp    r8d,r9d
    8d63:	je     8cca <bench_ada__run_17.isra.0+0x43a>
    8d69:	lea    r11d,[r9+0x1]
    8d6d:	cmp    r8d,r11d
    8d70:	je     8cca <bench_ada__run_17.isra.0+0x43a>
    8d76:	add    r9d,0x2
    8d7a:	jmp    8d60 <bench_ada__run_17.isra.0+0x4d0>
    8d7c:	nop    DWORD PTR [rax+0x0]


<bench_ada__run_18.isra.0>:
    8d80:	push   rbp
    8d81:	mov    eax,edi
    8d83:	mov    rbp,rsp
    8d86:	push   r15
    8d88:	push   r14
    8d8a:	push   r13
    8d8c:	push   r12
    8d8e:	push   rbx
    8d8f:	and    rsp,0xffffffffffffffc0
    8d93:	add    rsp,0xffffffffffffff80
    8d97:	mov    rdi,QWORD PTR [rbp+0x20]
    8d9b:	test   edx,edx
    8d9d:	je     9209 <bench_ada__run_18.isra.0+0x489>
    8da3:	mov    r12d,esi
    8da6:	test   esi,esi
    8da8:	lea    r15d,[rsi-0x1]
    8dac:	mov    DWORD PTR [rsp+0x2c],eax
    8db0:	setne  BYTE PTR [rsp+0x67]
    8db5:	lea    r13,[r12*8+0x0]
    8dbd:	xor    eax,eax
    8dbf:	cmp    r15d,0xffffffff
    8dc3:	cmove  r13,rax
    8dc7:	cmovne rax,r12
    8dcb:	mov    DWORD PTR [rsp+0x28],edx
    8dcf:	mov    DWORD PTR [rsp+0x24],r15d
    8dd4:	mov    QWORD PTR [rsp+0x40],r8
    8dd9:	mov    QWORD PTR [rsp+0x38],r9
    8dde:	mov    rbx,rcx
    8de1:	dec    r12
    8de4:	imul   rax,r13
    8de8:	mov    QWORD PTR [rsp+0x30],rax
    8ded:	xor    eax,eax
    8def:	mov    DWORD PTR [rsp+0x60],eax
    8df3:	mov    rax,r13
    8df6:	shr    rax,0x3
    8dfa:	mov    QWORD PTR [rsp+0x78],rax
    8dff:	nop
    8e00:	inc    DWORD PTR [rsp+0x60]
    8e04:	mov    rax,QWORD PTR [rsp+0x40]
    8e09:	mov    rsi,QWORD PTR [rsp+0x38]
    8e0e:	mov    rcx,QWORD PTR [rbp+0x10]
    8e12:	mov    rdx,QWORD PTR [rbp+0x18]
    8e16:	mov    r10,QWORD PTR [rbp+0x28]
    8e1a:	mov    rdx,QWORD PTR [rsp+0x30]
    8e1f:	xor    esi,esi
    8e21:	call   2bd0 <memset@plt>
    8e26:	vxorpd xmm2,xmm2,xmm2
    8e2a:	mov    rdi,rax
    8e2d:	mov    eax,DWORD PTR [rsp+0x2c]
    8e31:	test   eax,eax
    8e33:	je     905a <bench_ada__run_18.isra.0+0x2da>
    8e39:	mov    QWORD PTR [rsp+0x70],r13
    8e3e:	mov    QWORD PTR [rbp+0x20],rdi
    8e42:	mov    r13,QWORD PTR [rbp+0x18]
    8e46:	lea    rsi,[rax-0x1]
    8e4a:	mov    r8,0xffffffffffffffff
    8e51:	jmp    8e69 <bench_ada__run_18.isra.0+0xe9>
    8e53:	xchg   ax,ax
    8e55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8e60:	cmp    r8,rsi
    8e63:	je     904e <bench_ada__run_18.isra.0+0x2ce>
    8e69:	inc    r8
    8e6c:	movsxd rdi,r8d
    8e6f:	vcomisd xmm2,QWORD PTR [r13+rdi*8+0x0]
    8e76:	je     8e60 <bench_ada__run_18.isra.0+0xe0>
    8e78:	cmp    BYTE PTR [rsp+0x67],0x0
    8e7d:	je     8e60 <bench_ada__run_18.isra.0+0xe0>
    8e7f:	mov    rax,QWORD PTR [rsp+0x70]
    8e84:	mov    r14,QWORD PTR [rsp+0x78]
    8e89:	mov    QWORD PTR [rsp+0x50],r8
    8e8e:	mov    QWORD PTR [rsp+0x48],rsi
    8e93:	mov    r8,rdi
    8e96:	mov    ecx,0x1
    8e9b:	mov    rdx,0xffffffffffffffff
    8ea2:	imul   rax,rdi
    8ea6:	imul   r14,rdi
    8eaa:	mov    rdi,QWORD PTR [rbp+0x20]
    8eae:	add    rax,rbx
    8eb1:	mov    QWORD PTR [rsp+0x58],rax
    8eb6:	mov    r10,r14
    8eb9:	nop    DWORD PTR [rax+0x0]
    8ec0:	inc    rdx
    8ec3:	movsxd r14,edx
    8ec6:	lea    rax,[r10+r14*1]
    8eca:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    8ecf:	vcomisd xmm0,xmm2
    8ed3:	je     9030 <bench_ada__run_18.isra.0+0x2b0>
    8ed9:	vmovsd xmm1,QWORD PTR [r13+r8*8+0x0]
    8ee0:	vcomisd xmm1,xmm2
    8ee4:	je     9030 <bench_ada__run_18.isra.0+0x2b0>
    8eea:	mov    esi,edx
    8eec:	test   edx,edx
    8eee:	js     9030 <bench_ada__run_18.isra.0+0x2b0>
    8ef4:	vmulsd xmm1,xmm0,xmm1
    8ef8:	mov    DWORD PTR [rsp+0x68],edx
    8efc:	vbroadcastsd zmm6,xmm1
    8f02:	cmp    edx,0x6
    8f05:	jbe    9270 <bench_ada__run_18.isra.0+0x4f0>
    8f0b:	mov    r9,QWORD PTR [rsp+0x70]
    8f10:	mov    r15,QWORD PTR [rsp+0x58]
    8f15:	mov    r11d,ecx
    8f18:	shr    r11d,0x3
    8f1c:	vmovapd zmm4,zmm6
    8f22:	imul   r9,r14
    8f26:	lea    rax,[r9+rdi*1]
    8f2a:	mov    r9d,r11d
    8f2d:	shl    r9,0x6
    8f31:	sub    r15,rax
    8f34:	add    r9,rax
    8f37:	nop    WORD PTR [rax+rax*1+0x0]
    8f40:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    8f47:	add    rax,0x40
    8f4b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    8f52:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    8f59:	cmp    r9,rax
    8f5c:	jne    8f40 <bench_ada__run_18.isra.0+0x1c0>
    8f5e:	shl    r11d,0x3
    8f62:	cmp    ecx,r11d
    8f65:	je     9030 <bench_ada__run_18.isra.0+0x2b0>
    8f6b:	lea    r9d,[r11-0x1]
    8f6f:	mov    r15d,DWORD PTR [rsp+0x68]
    8f74:	sub    r15d,r11d
    8f77:	cmp    r15d,0x2
    8f7b:	jbe    8fb3 <bench_ada__run_18.isra.0+0x233>
    8f7d:	mov    rax,QWORD PTR [rsp+0x78]
    8f82:	inc    r15d
    8f85:	imul   rax,r14
    8f89:	add    rax,r11
    8f8c:	add    r11,r10
    8f8f:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r11*8]
    8f95:	mov    r11d,r15d
    8f98:	and    r11d,0xfffffffc
    8f9c:	and    r15d,0x3
    8fa0:	vaddpd ymm6,ymm6,YMMWORD PTR [rdi+rax*8]
    8fa5:	vmovupd YMMWORD PTR [rdi+rax*8],ymm6
    8faa:	je     9030 <bench_ada__run_18.isra.0+0x2b0>
    8fb0:	add    r9d,r11d
    8fb3:	mov    r15,QWORD PTR [rsp+0x78]
    8fb8:	lea    r11d,[r9+0x1]
    8fbc:	mov    DWORD PTR [rsp+0x68],r11d
    8fc1:	mov    rax,r15
    8fc4:	imul   r15,r8
    8fc8:	imul   rax,r14
    8fcc:	lea    r14,[rax+r11*1]
    8fd0:	add    r11,r15
    8fd3:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    8fd9:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    8fdf:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    8fe5:	cmp    DWORD PTR [rsp+0x68],esi
    8fe9:	je     9030 <bench_ada__run_18.isra.0+0x2b0>
    8feb:	lea    r11d,[r9+0x2]
    8fef:	lea    r14,[rax+r11*1]
    8ff3:	mov    DWORD PTR [rsp+0x68],r11d
    8ff8:	add    r11,r15
    8ffb:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    9001:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    9007:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    900d:	cmp    esi,DWORD PTR [rsp+0x68]
    9011:	je     9030 <bench_ada__run_18.isra.0+0x2b0>
    9013:	lea    esi,[r9+0x3]
    9017:	add    rax,rsi
    901a:	add    rsi,r15
    901d:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    9022:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rax*8]
    9027:	vmovsd QWORD PTR [rdi+rax*8],xmm1
    902c:	nop    DWORD PTR [rax+0x0]
    9030:	inc    ecx
    9032:	cmp    rdx,r12
    9035:	jne    8ec0 <bench_ada__run_18.isra.0+0x140>
    903b:	mov    r8,QWORD PTR [rsp+0x50]
    9040:	mov    rsi,QWORD PTR [rsp+0x48]
    9045:	cmp    r8,rsi
    9048:	jne    8e69 <bench_ada__run_18.isra.0+0xe9>
    904e:	mov    r13,QWORD PTR [rsp+0x70]
    9053:	mov    rdi,QWORD PTR [rbp+0x20]
    9057:	vzeroupper
    905a:	mov    eax,DWORD PTR [rsp+0x24]
    905e:	cmp    eax,0xffffffff
    9061:	je     91e5 <bench_ada__run_18.isra.0+0x465>
    9067:	mov    r14d,eax
    906a:	mov    QWORD PTR [rsp+0x58],rbx
    906f:	mov    r11,QWORD PTR [rsp+0x78]
    9074:	mov    r9d,0x1
    907a:	mov    QWORD PTR [rsp+0x68],r14
    907f:	mov    rsi,0xffffffffffffffff
    9086:	lea    rbx,[r13+r13*1+0x0]
    908b:	mov    r15d,eax
    908e:	jmp    90ac <bench_ada__run_18.isra.0+0x32c>
    9090:	nop    DWORD PTR [rax+rax*1+0x0]
    9095:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    90a0:	inc    r9d
    90a3:	cmp    rsi,r12
    90a6:	je     91e0 <bench_ada__run_18.isra.0+0x460>
    90ac:	mov    rax,rsi
    90af:	inc    rsi
    90b2:	cmp    r15d,r9d
    90b5:	jl     90a0 <bench_ada__run_18.isra.0+0x320>
    90b7:	mov    rcx,QWORD PTR [rsp+0x68]
    90bc:	movsxd rdx,r9d
    90bf:	lea    r10,[rdx-0x1]
    90c3:	sub    rcx,rdx
    90c6:	cmp    rcx,0xe
    90ca:	jbe    9220 <bench_ada__run_18.isra.0+0x4a0>
    90d0:	imul   rdx,r11
    90d4:	movsxd r14,esi
    90d7:	add    rax,rdx
    90da:	mov    rdx,rsi
    90dd:	imul   rdx,r11
    90e1:	shl    rax,0x3
    90e5:	add    rdx,r14
    90e8:	lea    r8,[rdi+rax*1]
    90ec:	shl    rdx,0x3
    90f0:	lea    r14,[rdi+rdx*1]
    90f4:	vmovq  xmm3,r14
    90f9:	mov    r14,r13
    90fc:	imul   r14,rcx
    9100:	lea    r14,[r8+r14*1+0x8]
    9105:	mov    QWORD PTR [rsp+0x70],r14
    910a:	lea    r14,[rdx+rdi*1+0x8]
    910f:	cmp    QWORD PTR [rsp+0x70],r14
    9114:	jb     912d <bench_ada__run_18.isra.0+0x3ad>
    9116:	vmovq  r14,xmm3
    911b:	add    r8,0x8
    911f:	lea    r14,[r14+rcx*8+0x8]
    9124:	cmp    r14,r8
    9127:	jae    9220 <bench_ada__run_18.isra.0+0x4a0>
    912d:	cmp    r15d,r9d
    9130:	je     91ae <bench_ada__run_18.isra.0+0x42e>
    9132:	lea    r14,[rcx+0x1]
    9136:	dec    rcx
    9139:	lea    rax,[rax+rdi*1+0x8]
    913e:	shr    rcx,1
    9141:	lea    r8,[rcx+0x1]
    9145:	lea    rcx,[rdx+rdi*1+0x8]
    914a:	xor    edx,edx
    914c:	nop    DWORD PTR [rax+rax*1+0x0]
    9154:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    915f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    916a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9175:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9180:	vmovsd xmm0,QWORD PTR [rax]
    9184:	vmovhpd xmm0,xmm0,QWORD PTR [r13+rax*1+0x0]
    918b:	inc    rdx
    918e:	add    rax,rbx
    9191:	add    rcx,0x10
    9195:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    919a:	cmp    rdx,r8
    919d:	jb     9180 <bench_ada__run_18.isra.0+0x400>
    919f:	add    r8,r8
    91a2:	cmp    r14,r8
    91a5:	je     90a0 <bench_ada__run_18.isra.0+0x320>
    91ab:	add    r10,r8
    91ae:	inc    r10
    91b1:	mov    rax,r11
    91b4:	inc    r9d
    91b7:	imul   rax,r10
    91bb:	add    rax,rsi
    91be:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    91c3:	mov    rax,rsi
    91c6:	imul   rax,r11
    91ca:	add    rax,r10
    91cd:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    91d2:	cmp    rsi,r12
    91d5:	jne    90ac <bench_ada__run_18.isra.0+0x32c>
    91db:	nop    DWORD PTR [rax+rax*1+0x0]
    91e0:	mov    rbx,QWORD PTR [rsp+0x58]
    91e5:	mov    rax,QWORD PTR [rsp+0x40]
    91ea:	mov    rsi,QWORD PTR [rsp+0x38]
    91ef:	mov    rcx,QWORD PTR [rbp+0x10]
    91f3:	mov    rdx,QWORD PTR [rbp+0x18]
    91f7:	mov    r10,QWORD PTR [rbp+0x28]
    91fb:	mov    esi,DWORD PTR [rsp+0x60]
    91ff:	cmp    DWORD PTR [rsp+0x28],esi
    9203:	jne    8e00 <bench_ada__run_18.isra.0+0x80>
    9209:	lea    rsp,[rbp-0x28]
    920d:	pop    rbx
    920e:	pop    r12
    9210:	pop    r13
    9212:	pop    r14
    9214:	pop    r15
    9216:	pop    rbp
    9217:	ret
    9218:	nop    DWORD PTR [rax+rax*1+0x0]
    9220:	mov    rdx,r13
    9223:	imul   rdx,rsi
    9227:	add    rdx,rdi
    922a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9235:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9240:	inc    r10
    9243:	mov    rax,r11
    9246:	imul   rax,r10
    924a:	add    rax,rsi
    924d:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    9252:	vmovsd QWORD PTR [rdx+r10*8],xmm0
    9258:	cmp    r10,r12
    925b:	jne    9240 <bench_ada__run_18.isra.0+0x4c0>
    925d:	jmp    90a0 <bench_ada__run_18.isra.0+0x320>
    9262:	nop    DWORD PTR [rax]
    9265:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9270:	xor    r11d,r11d
    9273:	mov    r9d,0xffffffff
    9279:	jmp    8f6f <bench_ada__run_18.isra.0+0x1ef>
    927e:	xchg   ax,ax


<bench_ada__run_19.isra.0>:
    9280:	push   rbp
    9281:	mov    rbp,rsp
    9284:	push   r15
    9286:	push   r14
    9288:	push   r13
    928a:	push   r12
    928c:	push   rbx
    928d:	and    rsp,0xffffffffffffffc0
    9291:	add    rsp,0xffffffffffffff80
    9295:	mov    r12,QWORD PTR [rbp+0x18]
    9299:	test   edx,edx
    929b:	je     9573 <bench_ada__run_19.isra.0+0x2f3>
    92a1:	mov    r13d,esi
    92a4:	test   esi,esi
    92a6:	mov    eax,0x0
    92ab:	mov    DWORD PTR [rsp+0x38],edx
    92af:	lea    rsi,[r13*8+0x0]
    92b7:	setne  r14b
    92bb:	mov    DWORD PTR [rsp+0x3c],edi
    92bf:	mov    QWORD PTR [rsp+0x48],r8
    92c4:	cmove  rsi,rax
    92c8:	mov    BYTE PTR [rsp+0x73],r14b
    92cd:	mov    r14,r9
    92d0:	mov    r9,QWORD PTR [rbp+0x20]
    92d4:	cmovne rax,r13
    92d8:	mov    QWORD PTR [rsp+0x68],rsi
    92dd:	mov    rbx,rcx
    92e0:	xor    r15d,r15d
    92e3:	imul   rax,rsi
    92e7:	dec    r13
    92ea:	shr    rsi,0x3
    92ee:	mov    QWORD PTR [rsp+0x40],rax
    92f3:	mov    QWORD PTR [rsp+0x78],rsi
    92f8:	nop    DWORD PTR [rax+rax*1+0x0]
    9300:	mov    rax,QWORD PTR [rsp+0x48]
    9305:	mov    rsi,QWORD PTR [rbp+0x10]
    9309:	mov    rcx,QWORD PTR [rbp+0x28]
    930d:	inc    r15d
    9310:	mov    rdx,QWORD PTR [rsp+0x40]
    9315:	xor    esi,esi
    9317:	mov    rdi,r9
    931a:	call   2bd0 <memset@plt>
    931f:	vxorpd xmm2,xmm2,xmm2
    9323:	mov    r9,rax
    9326:	mov    eax,DWORD PTR [rsp+0x3c]
    932a:	test   eax,eax
    932c:	je     955b <bench_ada__run_19.isra.0+0x2db>
    9332:	mov    DWORD PTR [rsp+0x34],r15d
    9337:	mov    QWORD PTR [rsp+0x28],r14
    933c:	mov    rdi,0xffffffffffffffff
    9343:	lea    r11,[rax-0x1]
    9347:	jmp    9369 <bench_ada__run_19.isra.0+0xe9>
    9349:	nop
    934a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9355:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9360:	cmp    rdi,r11
    9363:	je     954e <bench_ada__run_19.isra.0+0x2ce>
    9369:	inc    rdi
    936c:	movsxd r14,edi
    936f:	vcomisd xmm2,QWORD PTR [r12+r14*8]
    9375:	je     9360 <bench_ada__run_19.isra.0+0xe0>
    9377:	cmp    BYTE PTR [rsp+0x73],0x0
    937c:	je     9360 <bench_ada__run_19.isra.0+0xe0>
    937e:	mov    rax,QWORD PTR [rsp+0x68]
    9383:	mov    r10,QWORD PTR [rsp+0x78]
    9388:	mov    QWORD PTR [rsp+0x58],rdi
    938d:	mov    QWORD PTR [rsp+0x50],r11
    9392:	mov    ecx,0x1
    9397:	mov    rdx,0xffffffffffffffff
    939e:	mov    r11,r14
    93a1:	imul   rax,r14
    93a5:	imul   r10,r14
    93a9:	add    rax,rbx
    93ac:	mov    QWORD PTR [rsp+0x60],rax
    93b1:	nop    DWORD PTR [rax+0x0]
    93b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    93c0:	inc    rdx
    93c3:	movsxd r14,edx
    93c6:	lea    rax,[r10+r14*1]
    93ca:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    93cf:	vcomisd xmm0,xmm2
    93d3:	je     9530 <bench_ada__run_19.isra.0+0x2b0>
    93d9:	vmovsd xmm1,QWORD PTR [r12+r11*8]
    93df:	vcomisd xmm1,xmm2
    93e3:	je     9530 <bench_ada__run_19.isra.0+0x2b0>
    93e9:	mov    esi,edx
    93eb:	test   edx,edx
    93ed:	js     9530 <bench_ada__run_19.isra.0+0x2b0>
    93f3:	vmulsd xmm1,xmm0,xmm1
    93f7:	mov    DWORD PTR [rsp+0x74],edx
    93fb:	vbroadcastsd zmm6,xmm1
    9401:	cmp    edx,0x6
    9404:	jbe    9590 <bench_ada__run_19.isra.0+0x310>
    940a:	mov    rdi,QWORD PTR [rsp+0x68]
    940f:	mov    r15,QWORD PTR [rsp+0x60]
    9414:	mov    r8d,ecx
    9417:	shr    r8d,0x3
    941b:	vmovapd zmm4,zmm6
    9421:	imul   rdi,r14
    9425:	lea    rax,[rdi+r9*1]
    9429:	mov    edi,r8d
    942c:	shl    rdi,0x6
    9430:	sub    r15,rax
    9433:	add    rdi,rax
    9436:	cs nop WORD PTR [rax+rax*1+0x0]
    9440:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    9447:	add    rax,0x40
    944b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    9452:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    9459:	cmp    rax,rdi
    945c:	jne    9440 <bench_ada__run_19.isra.0+0x1c0>
    945e:	shl    r8d,0x3
    9462:	cmp    r8d,ecx
    9465:	je     9530 <bench_ada__run_19.isra.0+0x2b0>
    946b:	lea    edi,[r8-0x1]
    946f:	mov    r15d,DWORD PTR [rsp+0x74]
    9474:	sub    r15d,r8d
    9477:	cmp    r15d,0x2
    947b:	jbe    94b5 <bench_ada__run_19.isra.0+0x235>
    947d:	mov    rax,QWORD PTR [rsp+0x78]
    9482:	inc    r15d
    9485:	imul   rax,r14
    9489:	add    rax,r8
    948c:	add    r8,r10
    948f:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r8*8]
    9495:	mov    r8d,r15d
    9498:	and    r8d,0xfffffffc
    949c:	and    r15d,0x3
    94a0:	vaddpd ymm6,ymm6,YMMWORD PTR [r9+rax*8]
    94a6:	vmovupd YMMWORD PTR [r9+rax*8],ymm6
    94ac:	je     9530 <bench_ada__run_19.isra.0+0x2b0>
    94b2:	add    edi,r8d
    94b5:	mov    r15,QWORD PTR [rsp+0x78]
    94ba:	lea    r8d,[rdi+0x1]
    94be:	mov    DWORD PTR [rsp+0x74],r8d
    94c3:	mov    rax,r15
    94c6:	imul   r15,r11
    94ca:	imul   rax,r14
    94ce:	lea    r14,[rax+r8*1]
    94d2:	add    r8,r15
    94d5:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    94db:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    94e1:	vmovsd QWORD PTR [r9+r14*8],xmm0
    94e7:	cmp    esi,DWORD PTR [rsp+0x74]
    94eb:	je     9530 <bench_ada__run_19.isra.0+0x2b0>
    94ed:	lea    r8d,[rdi+0x2]
    94f1:	lea    r14,[rax+r8*1]
    94f5:	mov    DWORD PTR [rsp+0x74],r8d
    94fa:	add    r8,r15
    94fd:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    9503:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    9509:	vmovsd QWORD PTR [r9+r14*8],xmm0
    950f:	cmp    esi,DWORD PTR [rsp+0x74]
    9513:	je     9530 <bench_ada__run_19.isra.0+0x2b0>
    9515:	lea    esi,[rdi+0x3]
    9518:	add    rax,rsi
    951b:	add    rsi,r15
    951e:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    9523:	vaddsd xmm1,xmm1,QWORD PTR [r9+rax*8]
    9529:	vmovsd QWORD PTR [r9+rax*8],xmm1
    952f:	nop
    9530:	inc    ecx
    9532:	cmp    rdx,r13
    9535:	jne    93c0 <bench_ada__run_19.isra.0+0x140>
    953b:	mov    rdi,QWORD PTR [rsp+0x58]
    9540:	mov    r11,QWORD PTR [rsp+0x50]
    9545:	cmp    rdi,r11
    9548:	jne    9369 <bench_ada__run_19.isra.0+0xe9>
    954e:	mov    r15d,DWORD PTR [rsp+0x34]
    9553:	mov    r14,QWORD PTR [rsp+0x28]
    9558:	vzeroupper
    955b:	mov    rax,QWORD PTR [rsp+0x48]
    9560:	mov    rsi,QWORD PTR [rbp+0x10]
    9564:	mov    rcx,QWORD PTR [rbp+0x28]
    9568:	cmp    DWORD PTR [rsp+0x38],r15d
    956d:	jne    9300 <bench_ada__run_19.isra.0+0x80>
    9573:	lea    rsp,[rbp-0x28]
    9577:	pop    rbx
    9578:	pop    r12
    957a:	pop    r13
    957c:	pop    r14
    957e:	pop    r15
    9580:	pop    rbp
    9581:	ret
    9582:	nop    DWORD PTR [rax]
    9585:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9590:	xor    r8d,r8d
    9593:	mov    edi,0xffffffff
    9598:	jmp    946f <bench_ada__run_19.isra.0+0x1ef>
    959d:	nop
    959e:	xchg   ax,ax


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
    95a0:	push   rbp
    95a1:	mov    rbp,rsp
    95a4:	push   r15
    95a6:	push   r14
    95a8:	push   r13
    95aa:	push   r12
    95ac:	push   rbx
    95ad:	and    rsp,0xffffffffffffffc0
    95b1:	add    rsp,0xffffffffffffff80
    95b5:	mov    r10,QWORD PTR [rbp+0x20]
    95b9:	mov    QWORD PTR [rsp+0x58],r8
    95be:	test   edx,edx
    95c0:	je     9867 <bench_ada__run_20.isra.0+0x2c7>
    95c6:	mov    r8d,esi
    95c9:	xor    eax,eax
    95cb:	mov    DWORD PTR [rsp+0x4c],edi
    95cf:	test   esi,esi
    95d1:	lea    rdi,[r8*8+0x0]
    95d9:	mov    DWORD PTR [rsp+0x48],edx
    95dd:	mov    QWORD PTR [rsp+0x30],r8
    95e2:	mov    DWORD PTR [rsp+0x44],esi
    95e6:	cmove  rdi,rax
    95ea:	mov    rbx,rcx
    95ed:	mov    r12,r9
    95f0:	cmovne rax,r8
    95f4:	mov    QWORD PTR [rsp+0x70],rdi
    95f9:	xor    r15d,r15d
    95fc:	imul   rax,rdi
    9600:	shr    rdi,0x3
    9604:	mov    QWORD PTR [rsp+0x50],rax
    9609:	mov    QWORD PTR [rsp+0x78],rdi
    960e:	xchg   ax,ax
    9610:	mov    rax,QWORD PTR [rsp+0x58]
    9615:	mov    rsi,QWORD PTR [rbp+0x10]
    9619:	mov    rdi,QWORD PTR [rbp+0x18]
    961d:	mov    rcx,QWORD PTR [rbp+0x28]
    9621:	inc    r15d
    9624:	mov    rdx,QWORD PTR [rsp+0x50]
    9629:	xor    esi,esi
    962b:	mov    rdi,r10
    962e:	call   2bd0 <memset@plt>
    9633:	vxorpd xmm7,xmm7,xmm7
    9637:	mov    r10,rax
    963a:	mov    eax,DWORD PTR [rsp+0x4c]
    963e:	test   eax,eax
    9640:	je     984b <bench_ada__run_20.isra.0+0x2ab>
    9646:	mov    edx,DWORD PTR [rsp+0x44]
    964a:	test   edx,edx
    964c:	je     984b <bench_ada__run_20.isra.0+0x2ab>
    9652:	lea    rcx,[rax-0x1]
    9656:	mov    rax,QWORD PTR [rsp+0x30]
    965b:	mov    DWORD PTR [rsp+0x40],r15d
    9660:	mov    QWORD PTR [rsp+0x38],r12
    9665:	mov    QWORD PTR [rsp+0x60],rcx
    966a:	mov    rdi,0xffffffffffffffff
    9671:	lea    r13,[rax-0x1]
    9675:	vmovq  xmm3,r13
    967a:	nop    WORD PTR [rax+rax*1+0x0]
    9680:	mov    r14,QWORD PTR [rsp+0x70]
    9685:	inc    rdi
    9688:	mov    r9d,0x1
    968e:	mov    rdx,0xffffffffffffffff
    9695:	movsxd rax,edi
    9698:	mov    r8,rdi
    969b:	vmovq  rdi,xmm3
    96a0:	imul   r14,rax
    96a4:	lea    rsi,[r14+rbx*1]
    96a8:	mov    r14,QWORD PTR [rsp+0x78]
    96ad:	mov    QWORD PTR [rsp+0x68],rsi
    96b2:	imul   r14,rax
    96b6:	mov    r13,r14
    96b9:	jmp    96cc <bench_ada__run_20.isra.0+0x12c>
    96bb:	nop    DWORD PTR [rax+rax*1+0x0]
    96c0:	inc    r9d
    96c3:	cmp    rdx,rdi
    96c6:	je     9830 <bench_ada__run_20.isra.0+0x290>
    96cc:	inc    rdx
    96cf:	movsxd r14,edx
    96d2:	mov    esi,edx
    96d4:	lea    rax,[r13+r14*1+0x0]
    96d9:	vmovsd xmm1,QWORD PTR [rbx+rax*8]
    96de:	vbroadcastsd zmm2,xmm1
    96e4:	test   edx,edx
    96e6:	js     96c0 <bench_ada__run_20.isra.0+0x120>
    96e8:	vcomisd xmm1,xmm7
    96ec:	je     96c0 <bench_ada__run_20.isra.0+0x120>
    96ee:	mov    ecx,edx
    96f0:	cmp    edx,0x6
    96f3:	jbe    9880 <bench_ada__run_20.isra.0+0x2e0>
    96f9:	mov    r11,QWORD PTR [rsp+0x70]
    96fe:	mov    r15,QWORD PTR [rsp+0x68]
    9703:	mov    r12d,r9d
    9706:	shr    r12d,0x3
    970a:	vmovapd zmm4,zmm2
    9710:	imul   r11,r14
    9714:	lea    rax,[r11+r10*1]
    9718:	mov    r11d,r12d
    971b:	shl    r11,0x6
    971f:	sub    r15,rax
    9722:	add    r11,rax
    9725:	nop    DWORD PTR [rax+rax*1+0x0]
    972a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9735:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9740:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    9747:	add    rax,0x40
    974b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    9752:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    9759:	cmp    rax,r11
    975c:	jne    9740 <bench_ada__run_20.isra.0+0x1a0>
    975e:	shl    r12d,0x3
    9762:	cmp    r12d,r9d
    9765:	je     96c0 <bench_ada__run_20.isra.0+0x120>
    976b:	lea    r11d,[r12-0x1]
    9770:	sub    ecx,r12d
    9773:	cmp    ecx,0x2
    9776:	jbe    97ae <bench_ada__run_20.isra.0+0x20e>
    9778:	mov    r15,QWORD PTR [rsp+0x78]
    977d:	inc    ecx
    977f:	imul   r15,r14
    9783:	add    r15,r12
    9786:	add    r12,r13
    9789:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+r12*8]
    978f:	mov    r12d,ecx
    9792:	and    r12d,0xfffffffc
    9796:	and    ecx,0x3
    9799:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+r15*8]
    979f:	vmovupd YMMWORD PTR [r10+r15*8],ymm2
    97a5:	je     96c0 <bench_ada__run_20.isra.0+0x120>
    97ab:	add    r11d,r12d
    97ae:	mov    rax,QWORD PTR [rsp+0x78]
    97b3:	lea    ecx,[r11+0x1]
    97b7:	mov    r12,rcx
    97ba:	imul   rax,r14
    97be:	lea    r14,[rax+rcx*1]
    97c2:	add    rcx,r13
    97c5:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    97ca:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    97d0:	vmovsd QWORD PTR [r10+r14*8],xmm0
    97d6:	cmp    r12d,esi
    97d9:	je     96c0 <bench_ada__run_20.isra.0+0x120>
    97df:	lea    ecx,[r11+0x2]
    97e3:	lea    r14,[rax+rcx*1]
    97e7:	mov    r12,rcx
    97ea:	add    rcx,r13
    97ed:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    97f2:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    97f8:	vmovsd QWORD PTR [r10+r14*8],xmm0
    97fe:	cmp    r12d,esi
    9801:	je     96c0 <bench_ada__run_20.isra.0+0x120>
    9807:	lea    ecx,[r11+0x3]
    980b:	inc    r9d
    980e:	add    rax,rcx
    9811:	add    rcx,r13
    9814:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    9819:	vaddsd xmm1,xmm1,QWORD PTR [r10+rax*8]
    981f:	vmovsd QWORD PTR [r10+rax*8],xmm1
    9825:	cmp    rdx,rdi
    9828:	jne    96cc <bench_ada__run_20.isra.0+0x12c>
    982e:	xchg   ax,ax
    9830:	mov    rdi,r8
    9833:	cmp    r8,QWORD PTR [rsp+0x60]
    9838:	jne    9680 <bench_ada__run_20.isra.0+0xe0>
    983e:	mov    r15d,DWORD PTR [rsp+0x40]
    9843:	mov    r12,QWORD PTR [rsp+0x38]
    9848:	vzeroupper
    984b:	mov    rax,QWORD PTR [rsp+0x58]
    9850:	mov    rsi,QWORD PTR [rbp+0x10]
    9854:	mov    rdi,QWORD PTR [rbp+0x18]
    9858:	mov    rcx,QWORD PTR [rbp+0x28]
    985c:	cmp    DWORD PTR [rsp+0x48],r15d
    9861:	jne    9610 <bench_ada__run_20.isra.0+0x70>
    9867:	lea    rsp,[rbp-0x28]
    986b:	pop    rbx
    986c:	pop    r12
    986e:	pop    r13
    9870:	pop    r14
    9872:	pop    r15
    9874:	pop    rbp
    9875:	ret
    9876:	cs nop WORD PTR [rax+rax*1+0x0]
    9880:	xor    r12d,r12d
    9883:	mov    r11d,0xffffffff
    9889:	jmp    9770 <bench_ada__run_20.isra.0+0x1d0>
    988e:	xchg   ax,ax


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
    42e4:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2d512]        # 31800 <__gnat_ada_main_program_name+0x10>
    42ee:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2d548]        # 31840 <__gnat_ada_main_program_name+0x50>
    42f8:	mov    rax,rsi
    42fb:	xor    esi,esi
    42fd:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2d579]        # 31880 <__gnat_ada_main_program_name+0x90>
    4307:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2d5af]        # 318c0 <__gnat_ada_main_program_name+0xd0>
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
    4454:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2d4a2]        # 31900 <__gnat_ada_main_program_name+0x110>
    445e:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2d3d8]        # 31840 <__gnat_ada_main_program_name+0x50>
    4468:	mov    rax,rsi
    446b:	xor    esi,esi
    446d:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2d409]        # 31880 <__gnat_ada_main_program_name+0x90>
    4477:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2d4bf]        # 31940 <__gnat_ada_main_program_name+0x150>
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
    45c4:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2d232]        # 31800 <__gnat_ada_main_program_name+0x10>
    45ce:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2d3a8]        # 31980 <__gnat_ada_main_program_name+0x190>
    45d8:	mov    rax,rsi
    45db:	xor    esi,esi
    45dd:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2d3d9]        # 319c0 <__gnat_ada_main_program_name+0x1d0>
    45e7:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2d2cf]        # 318c0 <__gnat_ada_main_program_name+0xd0>
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
    7c50:	push   rbp
    7c51:	mov    rbp,rsp
    7c54:	push   r15
    7c56:	push   r14
    7c58:	push   r13
    7c5a:	push   r12
    7c5c:	push   rbx
    7c5d:	mov    r13,rcx
    7c60:	and    rsp,0xffffffffffffffc0
    7c64:	add    rsp,0xffffffffffffff80
    7c68:	mov    rcx,QWORD PTR [rbp+0x20]
    7c6c:	test   edx,edx
    7c6e:	je     7ed4 <bench_ada__run_8.isra.0+0x284>
    7c74:	mov    ebx,esi
    7c76:	mov    DWORD PTR [rsp+0x48],edx
    7c7a:	mov    DWORD PTR [rsp+0x4c],edi
    7c7e:	mov    QWORD PTR [rsp+0x78],r8
    7c83:	test   ebx,ebx
    7c85:	lea    edx,[rbx-0x1]
    7c88:	lea    rsi,[rbx*8+0x0]
    7c90:	mov    QWORD PTR [rsp+0x50],rbx
    7c95:	setne  r15b
    7c99:	sub    rbx,0x8
    7c9d:	movsxd rax,edx
    7ca0:	mov    QWORD PTR [rsp+0x60],rsi
    7ca5:	mov    QWORD PTR [rsp+0x68],rax
    7caa:	mov    r12,r9
    7cad:	xor    r14d,r14d
    7cb0:	shr    rbx,0x3
    7cb4:	inc    rbx
    7cb7:	lea    rax,[rbx*8+0x0]
    7cbf:	mov    QWORD PTR [rsp+0x38],rax
    7cc4:	nop
    7cc5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7cd0:	mov    rax,QWORD PTR [rsp+0x78]
    7cd5:	mov    rsi,QWORD PTR [rbp+0x10]
    7cd9:	mov    rdi,QWORD PTR [rbp+0x18]
    7cdd:	mov    rdx,QWORD PTR [rbp+0x28]
    7ce1:	inc    r14d
    7ce4:	mov    rdx,QWORD PTR [rsp+0x60]
    7ce9:	mov    rdi,rcx
    7cec:	xor    esi,esi
    7cee:	call   2bd0 <memset@plt>
    7cf3:	mov    rcx,rax
    7cf6:	mov    eax,DWORD PTR [rsp+0x4c]
    7cfa:	test   eax,eax
    7cfc:	je     7eb8 <bench_ada__run_8.isra.0+0x268>
    7d02:	mov    rsi,QWORD PTR [rsp+0x60]
    7d07:	mov    r11d,eax
    7d0a:	mov    DWORD PTR [rsp+0x44],r14d
    7d0f:	xor    eax,eax
    7d11:	vxorpd xmm4,xmm4,xmm4
    7d15:	shr    rsi,0x3
    7d19:	mov    QWORD PTR [rsp+0x70],rsi
    7d1e:	lea    rsi,[rcx-0x8]
    7d22:	mov    QWORD PTR [rsp+0x58],rsi
    7d27:	jmp    7d4c <bench_ada__run_8.isra.0+0xfc>
    7d29:	nop
    7d2a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7d35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7d40:	inc    rax
    7d43:	cmp    rax,r11
    7d46:	je     7eb0 <bench_ada__run_8.isra.0+0x260>
    7d4c:	vmovsd xmm1,QWORD PTR [r12+rax*8]
    7d52:	vcomisd xmm1,xmm4
    7d56:	vbroadcastsd zmm2,xmm1
    7d5c:	je     7d40 <bench_ada__run_8.isra.0+0xf0>
    7d5e:	test   r15b,r15b
    7d61:	je     7d40 <bench_ada__run_8.isra.0+0xf0>
    7d63:	mov    rsi,QWORD PTR [rsp+0x70]
    7d68:	mov    rdx,QWORD PTR [rsp+0x58]
    7d6d:	movsxd r14,eax
    7d70:	imul   rsi,r14
    7d74:	lea    r8,[r13+rsi*8+0x0]
    7d79:	sub    rdx,r8
    7d7c:	cmp    rdx,0x30
    7d80:	jbe    7ef0 <bench_ada__run_8.isra.0+0x2a0>
    7d86:	cmp    QWORD PTR [rsp+0x68],0x6
    7d8c:	jbe    7f3c <bench_ada__run_8.isra.0+0x2ec>
    7d92:	vmovapd zmm3,zmm2
    7d98:	mov    rdx,rcx
    7d9b:	xor    edi,edi
    7d9d:	sub    r8,rcx
    7da0:	cs nop WORD PTR [rax+rax*1+0x0]
    7daa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7db5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7dc0:	vmulpd zmm0,zmm3,ZMMWORD PTR [rdx+r8*1]
    7dc7:	inc    rdi
    7dca:	add    rdx,0x40
    7dce:	vaddpd zmm0,zmm0,ZMMWORD PTR [rdx-0x40]
    7dd5:	vmovupd ZMMWORD PTR [rdx-0x40],zmm0
    7ddc:	cmp    rdi,rbx
    7ddf:	jb     7dc0 <bench_ada__run_8.isra.0+0x170>
    7de1:	mov    rdi,QWORD PTR [rsp+0x38]
    7de6:	mov    rdx,rdi
    7de9:	cmp    QWORD PTR [rsp+0x50],rdi
    7dee:	je     7d40 <bench_ada__run_8.isra.0+0xf0>
    7df4:	lea    r8,[rdi-0x1]
    7df8:	mov    r10,QWORD PTR [rsp+0x68]
    7dfd:	sub    r10,rdx
    7e00:	lea    rdi,[r10+0x1]
    7e04:	cmp    r10,0x2
    7e08:	jbe    7f4a <bench_ada__run_8.isra.0+0x2fa>
    7e0e:	lea    r9,[rcx+rdx*8]
    7e12:	vmovq  xmm5,r9
    7e17:	lea    r9,[rsi+rdx*1]
    7e1b:	vmulpd ymm0,ymm2,YMMWORD PTR [r13+r9*8+0x0]
    7e22:	vmovq  r9,xmm5
    7e27:	vaddpd ymm0,ymm0,YMMWORD PTR [r9]
    7e2c:	vmovupd YMMWORD PTR [r9],ymm0
    7e31:	mov    r9,rdi
    7e34:	and    r9,0xfffffffffffffffc
    7e38:	add    r8,r9
    7e3b:	test   dil,0x3
    7e3f:	je     7d40 <bench_ada__run_8.isra.0+0xf0>
    7e45:	cmp    r10,r9
    7e48:	je     7e77 <bench_ada__run_8.isra.0+0x227>
    7e4a:	add    rdx,r9
    7e4d:	sub    rdi,r9
    7e50:	add    rsi,rdx
    7e53:	vmulpd xmm0,xmm2,XMMWORD PTR [r13+rsi*8+0x0]
    7e5a:	vaddpd xmm0,xmm0,XMMWORD PTR [rcx+rdx*8]
    7e5f:	vmovupd XMMWORD PTR [rcx+rdx*8],xmm0
    7e64:	mov    rdx,rdi
    7e67:	and    rdx,0xfffffffffffffffe
    7e6b:	and    edi,0x1
    7e6e:	je     7d40 <bench_ada__run_8.isra.0+0xf0>
    7e74:	add    r8,rdx
    7e77:	imul   r14,QWORD PTR [rsp+0x70]
    7e7d:	inc    rax
    7e80:	lea    rdx,[r8+r14*1+0x1]
    7e85:	vmulsd xmm1,xmm1,QWORD PTR [r13+rdx*8+0x0]
    7e8c:	vaddsd xmm1,xmm1,QWORD PTR [rcx+r8*8+0x8]
    7e93:	vmovsd QWORD PTR [rcx+r8*8+0x8],xmm1
    7e9a:	cmp    rax,r11
    7e9d:	jne    7d4c <bench_ada__run_8.isra.0+0xfc>
    7ea3:	xchg   ax,ax
    7ea5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7eb0:	mov    r14d,DWORD PTR [rsp+0x44]
    7eb5:	vzeroupper
    7eb8:	mov    rax,QWORD PTR [rsp+0x78]
    7ebd:	mov    rsi,QWORD PTR [rbp+0x10]
    7ec1:	mov    rdi,QWORD PTR [rbp+0x18]
    7ec5:	mov    rdx,QWORD PTR [rbp+0x28]
    7ec9:	cmp    DWORD PTR [rsp+0x48],r14d
    7ece:	jne    7cd0 <bench_ada__run_8.isra.0+0x80>
    7ed4:	lea    rsp,[rbp-0x28]
    7ed8:	pop    rbx
    7ed9:	pop    r12
    7edb:	pop    r13
    7edd:	pop    r14
    7edf:	pop    r15
    7ee1:	pop    rbp
    7ee2:	ret
    7ee3:	xchg   ax,ax
    7ee5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7ef0:	mov    rsi,QWORD PTR [rsp+0x60]
    7ef5:	mov    rdi,QWORD PTR [rsp+0x50]
    7efa:	xor    edx,edx
    7efc:	imul   rsi,r14
    7f00:	add    rsi,r13
    7f03:	nop    DWORD PTR [rax+0x0]
    7f0a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7f15:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7f20:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rdx*8]
    7f25:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rdx*8]
    7f2a:	vmovsd QWORD PTR [rcx+rdx*8],xmm0
    7f2f:	inc    rdx
    7f32:	cmp    rdi,rdx
    7f35:	jne    7f20 <bench_ada__run_8.isra.0+0x2d0>
    7f37:	jmp    7d40 <bench_ada__run_8.isra.0+0xf0>
    7f3c:	xor    edx,edx
    7f3e:	mov    r8,0xffffffffffffffff
    7f45:	jmp    7df8 <bench_ada__run_8.isra.0+0x1a8>
    7f4a:	xor    r9d,r9d
    7f4d:	jmp    7e45 <bench_ada__run_8.isra.0+0x1f5>
    7f52:	nop    DWORD PTR [rax]
    7f55:	data16 cs nop WORD PTR [rax+rax*1+0x0]


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
    6590:	mov    rax,rsi
    6593:	mov    r10,QWORD PTR [rsp+0x10]
    6598:	mov    rsi,QWORD PTR [rsp+0x8]
    659d:	mov    r11d,edi
    65a0:	test   edi,edi
    65a2:	je     660f <c_run_1.isra.0+0x7f>
    65a4:	xor    edi,edi
    65a6:	cs nop WORD PTR [rax+rax*1+0x0]
    65b0:	vmovsd xmm0,QWORD PTR [rax]
    65b4:	vmovsd QWORD PTR [rsi],xmm0
    65b8:	vmovsd xmm0,QWORD PTR [rax+0x8]
    65bd:	vmovsd QWORD PTR [rsi+0x8],xmm0
    65c2:	vmovsd xmm0,QWORD PTR [rax+0x10]
    65c7:	vmovsd QWORD PTR [rsi+0x10],xmm0
    65cc:	vmovsd xmm0,QWORD PTR [rax+0x18]
    65d1:	vmovsd QWORD PTR [rsi+0x18],xmm0
    65d6:	vmovsd xmm0,QWORD PTR [rax+0x20]
    65db:	vmovsd QWORD PTR [rsi+0x20],xmm0
    65e0:	vmovsd xmm0,QWORD PTR [rax+0x28]
    65e5:	vmovsd QWORD PTR [rsi+0x28],xmm0
    65ea:	vmovsd xmm0,QWORD PTR [rax+0x30]
    65ef:	vmovsd QWORD PTR [rsi+0x30],xmm0
    65f4:	vmovsd xmm0,QWORD PTR [rax+0x38]
    65f9:	vmovsd QWORD PTR [rsi+0x38],xmm0
    65fe:	vmovsd xmm0,QWORD PTR [rax+0x40]
    6603:	vmovsd QWORD PTR [rsi+0x40],xmm0
    6608:	inc    edi
    660a:	cmp    edi,r11d
    660d:	jne    65b0 <c_run_1.isra.0+0x20>
    660f:	ret


<c_run_10.isra.0>:
    6c40:	sub    rsp,0x30
    6c44:	mov    QWORD PTR [rsp+0x18],r13
    6c49:	mov    QWORD PTR [rsp+0x20],r14
    6c4e:	mov    QWORD PTR [rsp+0x28],r15
    6c53:	mov    DWORD PTR [rsp-0xc],edx
    6c57:	mov    r15,QWORD PTR [rsp+0x38]
    6c5c:	mov    r13,QWORD PTR [rsp+0x40]
    6c61:	mov    rax,QWORD PTR [rsp+0x48]
    6c66:	mov    r14,QWORD PTR [rsp+0x50]
    6c6b:	test   edx,edx
    6c6d:	je     6d24 <c_run_10.isra.0+0xe4>
    6c73:	mov    QWORD PTR [rsp],rbx
    6c77:	mov    QWORD PTR [rsp+0x8],rbp
    6c7c:	mov    QWORD PTR [rsp+0x10],r12
    6c81:	mov    r10d,edi
    6c84:	mov    rbx,rcx
    6c87:	mov    rbp,r8
    6c8a:	mov    r12,r9
    6c8d:	test   edi,edi
    6c8f:	je     6d38 <c_run_10.isra.0+0xf8>
    6c95:	xor    r11d,r11d
    6c98:	test   esi,esi
    6c9a:	je     6d50 <c_run_10.isra.0+0x110>
    6ca0:	mov    esi,esi
    6ca2:	lea    r9,[rsi*8+0x0]
    6caa:	mov    esi,edi
    6cac:	lea    rdx,[rcx+r9*1]
    6cb0:	shl    rsi,0x3
    6cb4:	mov    QWORD PTR [rsp-0x8],rdx
    6cb9:	mov    rdx,rcx
    6cbc:	nop    DWORD PTR [rax+0x0]
    6cc0:	mov    rdi,QWORD PTR [rsp-0x8]
    6cc5:	mov    DWORD PTR [rsp-0x10],r11d
    6cca:	mov    rbx,rax
    6ccd:	xor    r8d,r8d
    6cd0:	mov    rcx,rdi
    6cd3:	sub    rcx,r9
    6cd6:	mov    r11,rbx
    6cd9:	nop    DWORD PTR [rax+0x0]
    6ce0:	vmovsd xmm0,QWORD PTR [rcx]
    6ce4:	add    rcx,0x8
    6ce8:	vmovsd QWORD PTR [r11],xmm0
    6ced:	add    r11,rsi
    6cf0:	cmp    rcx,rdi
    6cf3:	jne    6ce0 <c_run_10.isra.0+0xa0>
    6cf5:	inc    r8d
    6cf8:	add    rbx,0x8
    6cfc:	lea    rdi,[rcx+r9*1]
    6d00:	cmp    r10d,r8d
    6d03:	jne    6cd0 <c_run_10.isra.0+0x90>
    6d05:	mov    r11d,DWORD PTR [rsp-0x10]
    6d0a:	inc    r11d
    6d0d:	cmp    DWORD PTR [rsp-0xc],r11d
    6d12:	je     6d16 <c_run_10.isra.0+0xd6>
    6d14:	jmp    6cc0 <c_run_10.isra.0+0x80>
    6d16:	mov    rbx,QWORD PTR [rsp]
    6d1a:	mov    rbp,QWORD PTR [rsp+0x8]
    6d1f:	mov    r12,QWORD PTR [rsp+0x10]
    6d24:	mov    r13,QWORD PTR [rsp+0x18]
    6d29:	mov    r14,QWORD PTR [rsp+0x20]
    6d2e:	mov    r15,QWORD PTR [rsp+0x28]
    6d33:	add    rsp,0x30
    6d37:	ret
    6d38:	mov    edi,DWORD PTR [rsp-0xc]
    6d3c:	lea    edx,[r10+0x1]
    6d40:	cmp    edi,edx
    6d42:	je     6d16 <c_run_10.isra.0+0xd6>
    6d44:	add    r10d,0x2
    6d48:	cmp    edi,r10d
    6d4b:	je     6d16 <c_run_10.isra.0+0xd6>
    6d4d:	jmp    6d38 <c_run_10.isra.0+0xf8>
    6d4f:	nop
    6d50:	mov    edi,DWORD PTR [rsp-0xc]
    6d54:	lea    edx,[r11+0x1]
    6d58:	cmp    edi,edx
    6d5a:	je     6d16 <c_run_10.isra.0+0xd6>
    6d5c:	add    r11d,0x2
    6d60:	cmp    edi,r11d
    6d63:	je     6d16 <c_run_10.isra.0+0xd6>
    6d65:	jmp    6d50 <c_run_10.isra.0+0x110>
    6d67:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_11.isra.0>:
    6d70:	sub    rsp,0x50
    6d74:	mov    QWORD PTR [rsp+0x48],r15
    6d79:	mov    DWORD PTR [rsp-0x60],edi
    6d7d:	mov    DWORD PTR [rsp+0xc],esi
    6d81:	mov    r15,QWORD PTR [rsp+0x60]
    6d86:	mov    r11,QWORD PTR [rsp+0x68]
    6d8b:	test   esi,esi
    6d8d:	je     7148 <c_run_11.isra.0+0x3d8>
    6d93:	mov    QWORD PTR [rsp+0x28],rbp
    6d98:	mov    QWORD PTR [rsp+0x38],r13
    6d9d:	mov    rax,QWORD PTR [rsp+0x58]
    6da2:	mov    r10,rdx
    6da5:	mov    r13,rcx
    6da8:	mov    rbp,r8
    6dab:	mov    esi,edi
    6dad:	test   edi,edi
    6daf:	je     715a <c_run_11.isra.0+0x3ea>
    6db5:	lea    eax,[rdi-0x1]
    6db8:	xor    edx,edx
    6dba:	mov    QWORD PTR [rsp+0x20],rbx
    6dbf:	lea    ecx,[rdi+0x1]
    6dc2:	test   eax,eax
    6dc4:	vmovsd xmm4,QWORD PTR [rip+0x2cfcc]        # 33d98 <system__os_lib__standin+0xc>
    6dcc:	mov    QWORD PTR [rsp+0x40],r14
    6dd1:	mov    QWORD PTR [rsp+0x30],r12
    6dd6:	cmovg  eax,edx
    6dd9:	mov    rbp,r11
    6ddc:	xor    r12d,r12d
    6ddf:	lea    edx,[rax+0x1]
    6de2:	lea    rax,[rdx*8+0x0]
    6dea:	mov    rdi,rdx
    6ded:	mov    DWORD PTR [rsp+0x8],edx
    6df1:	mov    QWORD PTR [rsp-0x8],rdx
    6df6:	lea    rbx,[r10+rax*1]
    6dfa:	add    rax,r15
    6dfd:	mov    QWORD PTR [rsp-0x38],rbx
    6e02:	mov    ebx,esi
    6e04:	mov    QWORD PTR [rsp-0x10],rax
    6e09:	add    rdx,rbx
    6e0c:	mov    QWORD PTR [rsp-0x68],rbx
    6e11:	vmovddup xmm3,xmm4
    6e15:	shl    rdx,0x3
    6e19:	lea    rax,[rdx+r10*1]
    6e1d:	mov    QWORD PTR [rsp-0x18],rax
    6e22:	mov    eax,edi
    6e24:	mov    edi,esi
    6e26:	lea    rsi,[rdx+r15*1]
    6e2a:	neg    eax
    6e2c:	mov    edx,ecx
    6e2e:	mov    QWORD PTR [rsp-0x28],rsi
    6e33:	lea    rsi,[rbx*8+0x0]
    6e3b:	and    edi,eax
    6e3d:	and    eax,ecx
    6e3f:	mov    rbx,r9
    6e42:	vmovq  xmm5,rsi
    6e47:	shl    rax,0x3
    6e4b:	lea    rcx,[r10+rax*1]
    6e4f:	add    rax,r15
    6e52:	mov    QWORD PTR [rsp-0x20],rdi
    6e57:	lea    rdi,[rdx*8+0x0]
    6e5f:	mov    QWORD PTR [rsp],rax
    6e63:	lea    rax,[r10+0x8]
    6e67:	mov    QWORD PTR [rsp-0x30],rdi
    6e6c:	vmovq  xmm6,rcx
    6e71:	mov    QWORD PTR [rsp+0x10],rax
    6e76:	mov    r9,r8
    6e79:	nop    DWORD PTR [rax+0x0]
    6e80:	vmovsd xmm0,QWORD PTR [r10]
    6e85:	mov    edi,DWORD PTR [rsp+0x8]
    6e89:	vmovsd QWORD PTR [r15],xmm0
    6e8e:	cmp    DWORD PTR [rsp-0x60],edi
    6e92:	jle    70b5 <c_run_11.isra.0+0x345>
    6e98:	mov    rax,QWORD PTR [rsp-0x20]
    6e9d:	mov    rdi,QWORD PTR [rsp-0x28]
    6ea2:	mov    rsi,QWORD PTR [rsp-0x18]
    6ea7:	mov    rcx,QWORD PTR [rsp-0x38]
    6eac:	mov    rdx,QWORD PTR [rsp-0x8]
    6eb1:	mov    DWORD PTR [rsp-0x5c],r12d
    6eb6:	mov    QWORD PTR [rsp-0x58],r13
    6ebb:	mov    QWORD PTR [rsp-0x50],r9
    6ec0:	mov    QWORD PTR [rsp-0x48],rbx
    6ec5:	mov    QWORD PTR [rsp+0x68],rbp
    6eca:	xor    r11d,r11d
    6ecd:	mov    QWORD PTR [rsp-0x70],rax
    6ed2:	mov    rax,QWORD PTR [rsp-0x10]
    6ed7:	vmovq  rbx,xmm6
    6edc:	lea    r8d,[rdx-0x1]
    6ee0:	mov    DWORD PTR [rsp-0x3c],edx
    6ee4:	vmovsd xmm0,QWORD PTR [rbx+r11*1]
    6eea:	mov    rbx,QWORD PTR [rsp]
    6eee:	vmovsd QWORD PTR [rbx+r11*1],xmm0
    6ef4:	cmp    r8d,0x20
    6ef8:	jbe    70ce <c_run_11.isra.0+0x35e>
    6efe:	mov    ebx,edx
    6f00:	mov    r13,QWORD PTR [rsp-0x70]
    6f05:	lea    r8,[rbx-0x1]
    6f09:	imul   r8,QWORD PTR [rsp-0x68]
    6f0f:	lea    rbx,[rbx+r13*1-0x1]
    6f14:	lea    r9,[r13*8+0x0]
    6f1c:	shl    rbx,0x3
    6f20:	add    r8,rdx
    6f23:	lea    rbp,[r15+r9*1]
    6f27:	lea    r14,[r10+r9*1]
    6f2b:	shl    r8,0x3
    6f2f:	lea    r12,[r10+r8*1]
    6f33:	cmp    r12,rbp
    6f36:	lea    r12,[r15+rbx*1]
    6f3a:	setb   r13b
    6f3e:	cmp    r12,rcx
    6f41:	setb   r12b
    6f45:	or     r13d,r12d
    6f48:	lea    r12,[r10+rbx*1]
    6f4c:	cmp    r12,rax
    6f4f:	mov    BYTE PTR [rsp-0x3e],r13b
    6f54:	lea    r13,[r15+r8*1]
    6f58:	setb   r12b
    6f5c:	cmp    r13,r14
    6f5f:	setb   BYTE PTR [rsp-0x3d]
    6f64:	or     r12b,BYTE PTR [rsp-0x3d]
    6f69:	test   BYTE PTR [rsp-0x3e],r12b
    6f6e:	je     70db <c_run_11.isra.0+0x36b>
    6f74:	lea    r12,[rdx*8+0x0]
    6f7c:	cmp    rbx,r12
    6f7f:	setl   bl
    6f82:	cmp    r8,r9
    6f85:	setl   r8b
    6f89:	or     ebx,r8d
    6f8c:	cmp    QWORD PTR [rsp+0x10],r15
    6f91:	setne  r8b
    6f95:	cmp    rsi,rax
    6f98:	setne  r12b
    6f9c:	and    r8d,r12d
    6f9f:	test   bl,r8b
    6fa2:	je     70db <c_run_11.isra.0+0x36b>
    6fa8:	cmp    edx,0x1
    6fab:	je     7152 <c_run_11.isra.0+0x3e2>
    6fb1:	mov    r12,QWORD PTR [rsp-0x68]
    6fb6:	mov    r13d,edx
    6fb9:	shr    r13d,1
    6fbc:	mov    ebx,r13d
    6fbf:	xor    r8d,r8d
    6fc2:	xor    r9d,r9d
    6fc5:	shl    r12,0x4
    6fc9:	shl    rbx,0x4
    6fcd:	nop    DWORD PTR [rax+0x0]
    6fd4:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6fdf:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6fea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6ff5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7000:	vmovsd xmm0,QWORD PTR [rcx+r8*1]
    7006:	vmovhpd xmm0,xmm0,QWORD PTR [rsi+r8*1]
    700c:	vaddpd xmm0,xmm0,XMMWORD PTR [r14+r9*1]
    7012:	vmulpd xmm0,xmm0,xmm3
    7016:	vmovlpd QWORD PTR [rax+r8*1],xmm0
    701c:	vmovhpd QWORD PTR [rdi+r8*1],xmm0
    7022:	add    r8,r12
    7025:	vmovupd XMMWORD PTR [rbp+r9*1+0x0],xmm0
    702c:	add    r9,0x10
    7030:	cmp    rbx,r9
    7033:	jne    7000 <c_run_11.isra.0+0x290>
    7035:	add    r13d,r13d
    7038:	cmp    r13d,DWORD PTR [rsp-0x3c]
    703d:	je     7070 <c_run_11.isra.0+0x300>
    703f:	mov    rbx,QWORD PTR [rsp-0x70]
    7044:	lea    r8d,[r13+rbx*1+0x0]
    7049:	imul   r13d,DWORD PTR [rsp-0x60]
    704f:	vmovsd xmm0,QWORD PTR [r10+r8*8]
    7055:	lea    r9d,[r13+rdx*1+0x0]
    705a:	vaddsd xmm0,xmm0,QWORD PTR [r10+r9*8]
    7060:	vmulsd xmm0,xmm0,xmm4
    7064:	vmovsd QWORD PTR [r15+r9*8],xmm0
    706a:	vmovsd QWORD PTR [r15+r8*8],xmm0
    7070:	mov    r14,QWORD PTR [rsp-0x68]
    7075:	add    r11,QWORD PTR [rsp-0x30]
    707a:	inc    rdx
    707d:	add    rcx,0x8
    7081:	add    QWORD PTR [rsp-0x70],r14
    7086:	add    rax,0x8
    708a:	add    rsi,0x8
    708e:	add    rdi,0x8
    7092:	cmp    DWORD PTR [rsp-0x60],edx
    7096:	jg     6ed7 <c_run_11.isra.0+0x167>
    709c:	mov    r12d,DWORD PTR [rsp-0x5c]
    70a1:	mov    r13,QWORD PTR [rsp-0x58]
    70a6:	mov    r9,QWORD PTR [rsp-0x50]
    70ab:	mov    rbx,QWORD PTR [rsp-0x48]
    70b0:	mov    rbp,QWORD PTR [rsp+0x68]
    70b5:	mov    rax,QWORD PTR [rsp+0x58]
    70ba:	inc    r12d
    70bd:	cmp    DWORD PTR [rsp+0xc],r12d
    70c2:	je     712f <c_run_11.isra.0+0x3bf>
    70c4:	mov    rax,QWORD PTR [rsp+0x58]
    70c9:	jmp    6e80 <c_run_11.isra.0+0x110>
    70ce:	mov    rbx,QWORD PTR [rsp-0x70]
    70d3:	lea    r9,[rbx*8+0x0]
    70db:	lea    r12,[r10+r9*1]
    70df:	xor    ebx,ebx
    70e1:	add    r9,r15
    70e4:	xor    r8d,r8d
    70e7:	vmovq  rbp,xmm5
    70ec:	nop    WORD PTR [rax+rax*1+0x0]
    70f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7100:	vmovsd xmm0,QWORD PTR [r12+r8*8]
    7106:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rbx*1]
    710b:	vmulsd xmm0,xmm0,xmm4
    710f:	vmovsd QWORD PTR [rax+rbx*1],xmm0
    7114:	vmovsd QWORD PTR [r9+r8*8],xmm0
    711a:	inc    r8
    711d:	add    rbx,rbp
    7120:	cmp    r8d,edx
    7123:	jl     7100 <c_run_11.isra.0+0x390>
    7125:	vmovq  xmm5,rbp
    712a:	jmp    7070 <c_run_11.isra.0+0x300>
    712f:	mov    rbx,QWORD PTR [rsp+0x20]
    7134:	mov    rbp,QWORD PTR [rsp+0x28]
    7139:	mov    r12,QWORD PTR [rsp+0x30]
    713e:	mov    r13,QWORD PTR [rsp+0x38]
    7143:	mov    r14,QWORD PTR [rsp+0x40]
    7148:	mov    r15,QWORD PTR [rsp+0x48]
    714d:	add    rsp,0x50
    7151:	ret
    7152:	xor    r13d,r13d
    7155:	jmp    703f <c_run_11.isra.0+0x2cf>
    715a:	mov    eax,DWORD PTR [rsp-0x60]
    715e:	mov    rdx,QWORD PTR [rsp+0x58]
    7163:	mov    esi,DWORD PTR [rsp+0xc]
    7167:	lea    ecx,[rax+0x1]
    716a:	cmp    esi,ecx
    716c:	je     7180 <c_run_11.isra.0+0x410>
    716e:	add    eax,0x2
    7171:	cmp    esi,eax
    7173:	je     7180 <c_run_11.isra.0+0x410>
    7175:	mov    esi,DWORD PTR [rsp+0xc]
    7179:	lea    ecx,[rax+0x1]
    717c:	cmp    esi,ecx
    717e:	jne    716e <c_run_11.isra.0+0x3fe>
    7180:	mov    rbp,QWORD PTR [rsp+0x28]
    7185:	mov    r13,QWORD PTR [rsp+0x38]
    718a:	jmp    7148 <c_run_11.isra.0+0x3d8>
    718c:	nop    DWORD PTR [rax+0x0]


<c_run_12.isra.0>:
    9ec0:	sub    rsp,0x58
    9ec4:	mov    QWORD PTR [rsp+0x28],rbx
    9ec9:	mov    QWORD PTR [rsp+0x8],rdx
    9ece:	mov    ebx,edi
    9ed0:	mov    rdi,QWORD PTR [rsp+0x68]
    9ed5:	test   esi,esi
    9ed7:	je     9f8f <c_run_12.isra.0+0xcf>
    9edd:	mov    eax,ebx
    9edf:	mov    DWORD PTR [rsp+0x1c],esi
    9ee3:	mov    QWORD PTR [rsp+0x38],r12
    9ee8:	mov    r12,r8
    9eeb:	lea    r8d,[rbx+0x1]
    9eef:	mov    QWORD PTR [rsp+0x30],rbp
    9ef4:	mov    QWORD PTR [rsp+0x40],r13
    9ef9:	mov    QWORD PTR [rsp+0x48],r14
    9efe:	mov    QWORD PTR [rsp+0x50],r15
    9f03:	mov    rbp,rcx
    9f06:	mov    r13,r9
    9f09:	lea    r15,[r8*8+0x0]
    9f11:	imul   eax,ebx
    9f14:	xor    r14d,r14d
    9f17:	shl    rax,0x3
    9f1b:	mov    QWORD PTR [rsp+0x10],rax
    9f20:	mov    rax,QWORD PTR [rsp+0x8]
    9f25:	mov    rcx,QWORD PTR [rsp+0x60]
    9f2a:	mov    rsi,QWORD PTR [rsp+0x70]
    9f2f:	mov    rdx,QWORD PTR [rsp+0x10]
    9f34:	xor    esi,esi
    9f36:	call   2bd0 <memset@plt>
    9f3b:	test   ebx,ebx
    9f3d:	vmovsd xmm0,QWORD PTR [rip+0x29e83]        # 33dc8 <system__os_lib__standin+0x3c>
    9f45:	mov    rdi,rax
    9f48:	je     9f5d <c_run_12.isra.0+0x9d>
    9f4a:	mov    rdx,rax
    9f4d:	xor    eax,eax
    9f4f:	nop
    9f50:	inc    eax
    9f52:	vmovsd QWORD PTR [rdx],xmm0
    9f56:	add    rdx,r15
    9f59:	cmp    ebx,eax
    9f5b:	jne    9f50 <c_run_12.isra.0+0x90>
    9f5d:	mov    rax,QWORD PTR [rsp+0x8]
    9f62:	mov    rcx,QWORD PTR [rsp+0x60]
    9f67:	mov    rsi,QWORD PTR [rsp+0x70]
    9f6c:	inc    r14d
    9f6f:	cmp    r14d,DWORD PTR [rsp+0x1c]
    9f74:	jne    9f20 <c_run_12.isra.0+0x60>
    9f76:	mov    rbp,QWORD PTR [rsp+0x30]
    9f7b:	mov    r12,QWORD PTR [rsp+0x38]
    9f80:	mov    r13,QWORD PTR [rsp+0x40]
    9f85:	mov    r14,QWORD PTR [rsp+0x48]
    9f8a:	mov    r15,QWORD PTR [rsp+0x50]
    9f8f:	mov    rbx,QWORD PTR [rsp+0x28]
    9f94:	add    rsp,0x58
    9f98:	ret
    9f99:	nop    DWORD PTR [rax+0x0]


<c_run_13.isra.0>:
    ac60:	sub    rsp,0x58
    ac64:	mov    QWORD PTR [rsp+0x48],r14
    ac69:	mov    QWORD PTR [rsp+0x50],r15
    ac6e:	mov    r14,rcx
    ac71:	mov    r10,QWORD PTR [rsp+0x60]
    ac76:	mov    r11,QWORD PTR [rsp+0x68]
    ac7b:	mov    r15,QWORD PTR [rsp+0x70]
    ac80:	mov    rcx,QWORD PTR [rsp+0x78]
    ac85:	test   edx,edx
    ac87:	je     ad5b <c_run_13.isra.0+0xfb>
    ac8d:	mov    eax,edi
    ac8f:	sar    eax,1
    ac91:	je     ad46 <c_run_13.isra.0+0xe6>
    ac97:	mov    QWORD PTR [rsp+0x28],rbx
    ac9c:	mov    DWORD PTR [rsp+0xc],edx
    aca0:	mov    QWORD PTR [rsp+0x10],r8
    aca5:	mov    QWORD PTR [rsp+0x18],r9
    acaa:	mov    QWORD PTR [rsp+0x60],r10
    acaf:	mov    QWORD PTR [rsp+0x68],r11
    acb4:	mov    QWORD PTR [rsp+0x30],rbp
    acb9:	mov    ebp,esi
    acbb:	mov    eax,eax
    acbd:	mov    QWORD PTR [rsp+0x40],r13
    acc2:	mov    r13,rbp
    acc5:	mov    QWORD PTR [rsp+0x38],r12
    acca:	lea    r12,[rcx+rax*4]
    acce:	xor    eax,eax
    acd0:	shl    rbp,0x3
    acd4:	nop
    acd5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ace0:	mov    DWORD PTR [rsp+0x8],eax
    ace4:	mov    QWORD PTR [rsp+0x78],rcx
    ace9:	mov    rbx,rcx
    acec:	nop    DWORD PTR [rax+0x0]
    acf0:	mov    esi,DWORD PTR [rbx]
    acf2:	mov    rdx,rbp
    acf5:	add    rbx,0x4
    acf9:	imul   esi,r13d
    acfd:	movsxd rsi,esi
    ad00:	shl    rsi,0x3
    ad04:	lea    rdi,[r15+rsi*1]
    ad08:	add    rsi,r14
    ad0b:	call   30f0 <memcpy@plt>
    ad10:	cmp    r12,rbx
    ad13:	jne    acf0 <c_run_13.isra.0+0x90>
    ad15:	mov    eax,DWORD PTR [rsp+0x8]
    ad19:	mov    rcx,QWORD PTR [rsp+0x78]
    ad1e:	mov    rdx,QWORD PTR [rsp+0x10]
    ad23:	mov    rdi,QWORD PTR [rsp+0x18]
    ad28:	mov    rbx,QWORD PTR [rsp+0x60]
    ad2d:	mov    rsi,QWORD PTR [rsp+0x68]
    ad32:	inc    eax
    ad34:	cmp    DWORD PTR [rsp+0xc],eax
    ad38:	je     ad70 <c_run_13.isra.0+0x110>
    ad3a:	mov    rbx,QWORD PTR [rsp+0x60]
    ad3f:	mov    rsi,QWORD PTR [rsp+0x68]
    ad44:	jmp    ace0 <c_run_13.isra.0+0x80>
    ad46:	lea    esi,[rax+0x1]
    ad49:	cmp    edx,esi
    ad4b:	je     ad5b <c_run_13.isra.0+0xfb>
    ad4d:	add    eax,0x2
    ad50:	cmp    edx,eax
    ad52:	je     ad5b <c_run_13.isra.0+0xfb>
    ad54:	lea    esi,[rax+0x1]
    ad57:	cmp    edx,esi
    ad59:	jne    ad4d <c_run_13.isra.0+0xed>
    ad5b:	mov    r14,QWORD PTR [rsp+0x48]
    ad60:	mov    r15,QWORD PTR [rsp+0x50]
    ad65:	add    rsp,0x58
    ad69:	ret
    ad6a:	nop    WORD PTR [rax+rax*1+0x0]
    ad70:	mov    rbx,QWORD PTR [rsp+0x28]
    ad75:	mov    rbp,QWORD PTR [rsp+0x30]
    ad7a:	mov    r12,QWORD PTR [rsp+0x38]
    ad7f:	mov    r13,QWORD PTR [rsp+0x40]
    ad84:	mov    r14,QWORD PTR [rsp+0x48]
    ad89:	mov    r15,QWORD PTR [rsp+0x50]
    ad8e:	add    rsp,0x58
    ad92:	ret
    ad93:	xchg   ax,ax
    ad95:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_14.isra.0>:
    9fa0:	push   rbp
    9fa1:	mov    rbp,rsp
    9fa4:	push   r15
    9fa6:	push   r14
    9fa8:	push   r13
    9faa:	push   r12
    9fac:	push   rbx
    9fad:	and    rsp,0xffffffffffffffe0
    9fb1:	sub    rsp,0x40
    9fb5:	mov    QWORD PTR [rsp+0x18],r8
    9fba:	test   ecx,ecx
    9fbc:	je     a185 <c_run_14.isra.0+0x1e5>
    9fc2:	mov    eax,edi
    9fc4:	mov    DWORD PTR [rsp+0x28],edi
    9fc8:	mov    DWORD PTR [rsp+0x20],ecx
    9fcc:	mov    DWORD PTR [rsp+0x4],esi
    9fd0:	mov    DWORD PTR [rsp+0x24],0x0
    9fd8:	mov    r14,QWORD PTR [rbp+0x28]
    9fdc:	mov    r12,r9
    9fdf:	mov    ebx,edx
    9fe1:	imul   eax,edx
    9fe4:	shl    rax,0x3
    9fe8:	mov    QWORD PTR [rsp+0x10],rax
    9fed:	mov    eax,esi
    9fef:	lea    r15,[rax*8+0x0]
    9ff7:	lea    rax,[r8+r15*1]
    9ffb:	mov    QWORD PTR [rsp+0x38],r15
    a000:	mov    QWORD PTR [rsp+0x8],rax
    a005:	lea    eax,[rdx-0x4]
    a008:	and    eax,0xfffffffc
    a00b:	add    eax,0x4
    a00e:	mov    edi,edx
    a010:	sub    edi,eax
    a012:	mov    DWORD PTR [rsp+0x30],eax
    a016:	mov    DWORD PTR [rsp+0x2c],edi
    a01a:	mov    rax,QWORD PTR [rsp+0x18]
    a01f:	mov    rdi,QWORD PTR [rbp+0x10]
    a023:	mov    rcx,QWORD PTR [rbp+0x18]
    a027:	mov    rsi,QWORD PTR [rbp+0x20]
    a02b:	mov    rdx,QWORD PTR [rbp+0x30]
    a02f:	mov    rdx,QWORD PTR [rsp+0x10]
    a034:	xor    esi,esi
    a036:	mov    rdi,r14
    a039:	call   2bd0 <memset@plt>
    a03e:	mov    edx,DWORD PTR [rsp+0x28]
    a042:	test   edx,edx
    a044:	je     a15e <c_run_14.isra.0+0x1be>
    a04a:	mov    eax,DWORD PTR [rsp+0x4]
    a04e:	mov    rdi,QWORD PTR [rsp+0x8]
    a053:	xor    r11d,r11d
    a056:	xor    r10d,r10d
    a059:	test   eax,eax
    a05b:	je     a15e <c_run_14.isra.0+0x1be>
    a061:	lea    eax,[rbx-0x4]
    a064:	vxorpd xmm3,xmm3,xmm3
    a068:	shr    eax,0x2
    a06b:	inc    eax
    a06d:	shl    rax,0x5
    a071:	nop    DWORD PTR [rax+0x0]
    a075:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a080:	movsxd rdx,r11d
    a083:	mov    DWORD PTR [rsp+0x34],r10d
    a088:	xor    ecx,ecx
    a08a:	lea    r8,[r14+rdx*8]
    a08e:	mov    rdx,rdi
    a091:	sub    rdx,QWORD PTR [rsp+0x38]
    a096:	lea    rsi,[rax+r8*1]
    a09a:	jmp    a0af <c_run_14.isra.0+0x10f>
    a09c:	nop    DWORD PTR [rax+0x0]
    a0a0:	add    rdx,0x8
    a0a4:	add    ecx,ebx
    a0a6:	cmp    rdi,rdx
    a0a9:	je     a140 <c_run_14.isra.0+0x1a0>
    a0af:	vmovsd xmm1,QWORD PTR [rdx]
    a0b3:	vcomisd xmm1,xmm3
    a0b7:	je     a0a0 <c_run_14.isra.0+0x100>
    a0b9:	mov    r9d,ecx
    a0bc:	lea    r10,[r12+r9*8]
    a0c0:	cmp    ebx,0x4
    a0c3:	js     a1a0 <c_run_14.isra.0+0x200>
    a0c9:	mov    r15,r10
    a0cc:	sub    r15,r8
    a0cf:	vbroadcastsd ymm2,xmm1
    a0d4:	mov    r9,r8
    a0d7:	nop    WORD PTR [rax+rax*1+0x0]
    a0e0:	vmulpd ymm0,ymm2,YMMWORD PTR [r15+r9*1]
    a0e6:	add    r9,0x20
    a0ea:	vaddpd ymm0,ymm0,YMMWORD PTR [r9-0x20]
    a0f0:	vmovupd YMMWORD PTR [r9-0x20],ymm0
    a0f6:	cmp    rsi,r9
    a0f9:	jne    a0e0 <c_run_14.isra.0+0x140>
    a0fb:	mov    r15d,DWORD PTR [rsp+0x2c]
    a100:	mov    r9d,DWORD PTR [rsp+0x30]
    a105:	cmp    r15d,0x3
    a109:	je     a1b0 <c_run_14.isra.0+0x210>
    a10f:	cmp    r15d,0x2
    a113:	je     a200 <c_run_14.isra.0+0x260>
    a119:	cmp    r15d,0x1
    a11d:	jne    a0a0 <c_run_14.isra.0+0x100>
    a11f:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*8]
    a125:	add    rdx,0x8
    a129:	add    ecx,ebx
    a12b:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*8]
    a131:	vmovsd QWORD PTR [r8+r9*8],xmm1
    a137:	cmp    rdi,rdx
    a13a:	jne    a0af <c_run_14.isra.0+0x10f>
    a140:	mov    r10d,DWORD PTR [rsp+0x34]
    a145:	add    rdi,QWORD PTR [rsp+0x38]
    a14a:	add    r11d,ebx
    a14d:	inc    r10d
    a150:	cmp    DWORD PTR [rsp+0x28],r10d
    a155:	jne    a080 <c_run_14.isra.0+0xe0>
    a15b:	vzeroupper
    a15e:	mov    rax,QWORD PTR [rsp+0x18]
    a163:	mov    rdi,QWORD PTR [rbp+0x10]
    a167:	mov    rcx,QWORD PTR [rbp+0x18]
    a16b:	mov    rsi,QWORD PTR [rbp+0x20]
    a16f:	mov    rdx,QWORD PTR [rbp+0x30]
    a173:	inc    DWORD PTR [rsp+0x24]
    a177:	mov    edi,DWORD PTR [rsp+0x20]
    a17b:	cmp    DWORD PTR [rsp+0x24],edi
    a17f:	jne    a01a <c_run_14.isra.0+0x7a>
    a185:	lea    rsp,[rbp-0x28]
    a189:	pop    rbx
    a18a:	pop    r12
    a18c:	pop    r13
    a18e:	pop    r14
    a190:	pop    r15
    a192:	pop    rbp
    a193:	ret
    a194:	nop
    a195:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a1a0:	mov    r15d,ebx
    a1a3:	xor    r9d,r9d
    a1a6:	cmp    r15d,0x3
    a1aa:	jne    a10f <c_run_14.isra.0+0x16f>
    a1b0:	shl    r9,0x3
    a1b4:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1]
    a1ba:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1]
    a1c0:	vmovsd QWORD PTR [r8+r9*1],xmm0
    a1c6:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1+0x8]
    a1cd:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1+0x8]
    a1d4:	vmovsd QWORD PTR [r8+r9*1+0x8],xmm0
    a1db:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*1+0x10]
    a1e2:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*1+0x10]
    a1e9:	vmovsd QWORD PTR [r8+r9*1+0x10],xmm1
    a1f0:	jmp    a0a0 <c_run_14.isra.0+0x100>
    a1f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a200:	shl    r9,0x3
    a204:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1]
    a20a:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1]
    a210:	vmovsd QWORD PTR [r8+r9*1],xmm0
    a216:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*1+0x8]
    a21d:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*1+0x8]
    a224:	vmovsd QWORD PTR [r8+r9*1+0x8],xmm1
    a22b:	jmp    a0a0 <c_run_14.isra.0+0x100>


<c_run_15.isra.0>:
    a230:	push   rbp
    a231:	mov    rbp,rsp
    a234:	push   r15
    a236:	push   r14
    a238:	push   r13
    a23a:	push   r12
    a23c:	push   rbx
    a23d:	and    rsp,0xffffffffffffffe0
    a241:	sub    rsp,0x40
    a245:	mov    r11,QWORD PTR [rbp+0x28]
    a249:	mov    QWORD PTR [rsp+0x18],r8
    a24e:	test   ecx,ecx
    a250:	je     a424 <c_run_15.isra.0+0x1f4>
    a256:	mov    eax,esi
    a258:	mov    DWORD PTR [rsp+0x28],edi
    a25c:	mov    DWORD PTR [rsp+0x20],ecx
    a260:	mov    DWORD PTR [rsp+0x24],0x0
    a268:	mov    DWORD PTR [rsp+0x4],esi
    a26c:	mov    r14,r9
    a26f:	mov    ebx,edx
    a271:	imul   eax,edx
    a274:	shl    rax,0x3
    a278:	mov    QWORD PTR [rsp+0x10],rax
    a27d:	mov    eax,esi
    a27f:	lea    r15,[rax*8+0x0]
    a287:	lea    rax,[r8+r15*1]
    a28b:	mov    QWORD PTR [rsp+0x38],r15
    a290:	mov    QWORD PTR [rsp+0x8],rax
    a295:	lea    eax,[rdx-0x4]
    a298:	and    eax,0xfffffffc
    a29b:	add    eax,0x4
    a29e:	mov    edi,edx
    a2a0:	sub    edi,eax
    a2a2:	mov    DWORD PTR [rsp+0x30],eax
    a2a6:	mov    DWORD PTR [rsp+0x2c],edi
    a2aa:	mov    rax,QWORD PTR [rsp+0x18]
    a2af:	mov    rdi,QWORD PTR [rbp+0x10]
    a2b3:	mov    rdx,QWORD PTR [rbp+0x18]
    a2b7:	mov    rcx,QWORD PTR [rbp+0x20]
    a2bb:	mov    rsi,QWORD PTR [rbp+0x30]
    a2bf:	mov    rdx,QWORD PTR [rsp+0x10]
    a2c4:	mov    rdi,r11
    a2c7:	xor    esi,esi
    a2c9:	call   2bd0 <memset@plt>
    a2ce:	mov    ecx,DWORD PTR [rsp+0x28]
    a2d2:	mov    r11,rax
    a2d5:	test   ecx,ecx
    a2d7:	je     a3fd <c_run_15.isra.0+0x1cd>
    a2dd:	mov    edx,DWORD PTR [rsp+0x4]
    a2e1:	mov    r8,QWORD PTR [rsp+0x8]
    a2e6:	xor    ecx,ecx
    a2e8:	xor    eax,eax
    a2ea:	test   edx,edx
    a2ec:	je     a3fd <c_run_15.isra.0+0x1cd>
    a2f2:	lea    edx,[rbx-0x4]
    a2f5:	vxorpd xmm3,xmm3,xmm3
    a2f9:	mov    rdi,r14
    a2fc:	shr    edx,0x2
    a2ff:	inc    edx
    a301:	shl    rdx,0x5
    a305:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a310:	movsxd rsi,ecx
    a313:	mov    DWORD PTR [rsp+0x34],eax
    a317:	xor    r9d,r9d
    a31a:	lea    r13,[rdi+rsi*8]
    a31e:	mov    rsi,r8
    a321:	sub    rsi,QWORD PTR [rsp+0x38]
    a326:	lea    r10,[rdx+r13*1]
    a32a:	jmp    a350 <c_run_15.isra.0+0x120>
    a32c:	nop    WORD PTR [rax+rax*1+0x0]
    a335:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a340:	add    rsi,0x8
    a344:	add    r9d,ebx
    a347:	cmp    r8,rsi
    a34a:	je     a3e0 <c_run_15.isra.0+0x1b0>
    a350:	vmovsd xmm1,QWORD PTR [rsi]
    a354:	vcomisd xmm1,xmm3
    a358:	je     a340 <c_run_15.isra.0+0x110>
    a35a:	mov    eax,r9d
    a35d:	lea    r15,[r11+rax*8]
    a361:	cmp    ebx,0x4
    a364:	js     a440 <c_run_15.isra.0+0x210>
    a36a:	mov    r14,r15
    a36d:	sub    r14,r13
    a370:	vbroadcastsd ymm2,xmm1
    a375:	mov    rax,r13
    a378:	nop    DWORD PTR [rax+rax*1+0x0]
    a380:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    a384:	vaddpd ymm0,ymm0,YMMWORD PTR [r14+rax*1]
    a38a:	vmovupd YMMWORD PTR [r14+rax*1],ymm0
    a390:	add    rax,0x20
    a394:	cmp    r10,rax
    a397:	jne    a380 <c_run_15.isra.0+0x150>
    a399:	mov    r14d,DWORD PTR [rsp+0x2c]
    a39e:	mov    eax,DWORD PTR [rsp+0x30]
    a3a2:	cmp    r14d,0x3
    a3a6:	je     a44f <c_run_15.isra.0+0x21f>
    a3ac:	cmp    r14d,0x2
    a3b0:	je     a4a0 <c_run_15.isra.0+0x270>
    a3b6:	cmp    r14d,0x1
    a3ba:	jne    a340 <c_run_15.isra.0+0x110>
    a3bc:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*8+0x0]
    a3c3:	add    rsi,0x8
    a3c7:	add    r9d,ebx
    a3ca:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*8]
    a3d0:	vmovsd QWORD PTR [r15+rax*8],xmm1
    a3d6:	cmp    r8,rsi
    a3d9:	jne    a350 <c_run_15.isra.0+0x120>
    a3df:	nop
    a3e0:	mov    eax,DWORD PTR [rsp+0x34]
    a3e4:	add    r8,QWORD PTR [rsp+0x38]
    a3e9:	add    ecx,ebx
    a3eb:	inc    eax
    a3ed:	cmp    DWORD PTR [rsp+0x28],eax
    a3f1:	jne    a310 <c_run_15.isra.0+0xe0>
    a3f7:	mov    r14,rdi
    a3fa:	vzeroupper
    a3fd:	mov    rax,QWORD PTR [rsp+0x18]
    a402:	mov    rdi,QWORD PTR [rbp+0x10]
    a406:	mov    rdx,QWORD PTR [rbp+0x18]
    a40a:	mov    rcx,QWORD PTR [rbp+0x20]
    a40e:	mov    rsi,QWORD PTR [rbp+0x30]
    a412:	inc    DWORD PTR [rsp+0x24]
    a416:	mov    edi,DWORD PTR [rsp+0x20]
    a41a:	cmp    DWORD PTR [rsp+0x24],edi
    a41e:	jne    a2aa <c_run_15.isra.0+0x7a>
    a424:	lea    rsp,[rbp-0x28]
    a428:	pop    rbx
    a429:	pop    r12
    a42b:	pop    r13
    a42d:	pop    r14
    a42f:	pop    r15
    a431:	pop    rbp
    a432:	ret
    a433:	xchg   ax,ax
    a435:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a440:	mov    r14d,ebx
    a443:	xor    eax,eax
    a445:	cmp    r14d,0x3
    a449:	jne    a3ac <c_run_15.isra.0+0x17c>
    a44f:	shl    rax,0x3
    a453:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x0]
    a45a:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    a460:	vmovsd QWORD PTR [r15+rax*1],xmm0
    a466:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x8]
    a46d:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1+0x8]
    a474:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm0
    a47b:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*1+0x10]
    a482:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x10]
    a489:	vmovsd QWORD PTR [r15+rax*1+0x10],xmm1
    a490:	jmp    a340 <c_run_15.isra.0+0x110>
    a495:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a4a0:	shl    rax,0x3
    a4a4:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x0]
    a4ab:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    a4b1:	vmovsd QWORD PTR [r15+rax*1],xmm0
    a4b7:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*1+0x8]
    a4be:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x8]
    a4c5:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm1
    a4cc:	jmp    a340 <c_run_15.isra.0+0x110>
    a4d1:	nop    DWORD PTR [rax+0x0]
    a4d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_16.isra.0>:
    a9c0:	push   rbp
    a9c1:	mov    rbp,rsp
    a9c4:	push   r15
    a9c6:	push   r14
    a9c8:	push   r13
    a9ca:	push   r12
    a9cc:	push   rbx
    a9cd:	and    rsp,0xffffffffffffffe0
    a9d1:	mov    rax,QWORD PTR [rbp+0x28]
    a9d5:	mov    DWORD PTR [rsp-0xc],ecx
    a9d9:	test   ecx,ecx
    a9db:	je     aa43 <c_run_16.isra.0+0x83>
    a9dd:	mov    r15d,edi
    a9e0:	mov    ebx,esi
    a9e2:	mov    rdi,r8
    a9e5:	mov    rcx,QWORD PTR [rbp+0x10]
    a9e9:	mov    rsi,QWORD PTR [rbp+0x18]
    a9ed:	mov    r11,QWORD PTR [rbp+0x20]
    a9f1:	mov    r8,QWORD PTR [rbp+0x30]
    a9f5:	mov    r14,r9
    a9f8:	test   r15d,r15d
    a9fb:	je     ac23 <c_run_16.isra.0+0x263>
    aa01:	mov    DWORD PTR [rsp-0x8],0x0
    aa09:	test   edx,edx
    aa0b:	jne    aa52 <c_run_16.isra.0+0x92>
    aa0d:	mov    rcx,QWORD PTR [rbp+0x10]
    aa11:	mov    rsi,QWORD PTR [rbp+0x18]
    aa15:	mov    r8,QWORD PTR [rbp+0x20]
    aa19:	mov    r9,QWORD PTR [rbp+0x30]
    aa1d:	xor    edx,edx
    aa1f:	mov    ebx,DWORD PTR [rsp-0xc]
    aa23:	lea    r10d,[rdx+0x1]
    aa27:	cmp    ebx,r10d
    aa2a:	je     aa43 <c_run_16.isra.0+0x83>
    aa2c:	add    edx,0x2
    aa2f:	cmp    ebx,edx
    aa31:	je     aa43 <c_run_16.isra.0+0x83>
    aa33:	jmp    aa1f <c_run_16.isra.0+0x5f>
    aa35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aa40:	vzeroupper
    aa43:	lea    rsp,[rbp-0x28]
    aa47:	pop    rbx
    aa48:	pop    r12
    aa4a:	pop    r13
    aa4c:	pop    r14
    aa4e:	pop    r15
    aa50:	pop    rbp
    aa51:	ret
    aa52:	mov    edx,edx
    aa54:	lea    r11d,[rbx-0x8]
    aa58:	lea    ecx,[rbx-0x4]
    aa5b:	mov    r10d,ebx
    aa5e:	lea    r13,[rdx*8+0x0]
    aa66:	and    r11d,0xfffffffc
    aa6a:	lea    rdx,[rax+r13*1]
    aa6e:	add    r11d,0x8
    aa72:	mov    QWORD PTR [rsp-0x20],rdx
    aa77:	mov    edx,0x4
    aa7c:	shl    r10,0x3
    aa80:	cmp    ecx,0x3
    aa83:	cmovle r11d,edx
    aa87:	mov    r12d,ebx
    aa8a:	sub    r12d,r11d
    aa8d:	mov    r9,QWORD PTR [rsp-0x20]
    aa92:	mov    QWORD PTR [rsp-0x18],rdi
    aa97:	mov    QWORD PTR [rbp+0x28],rax
    aa9b:	mov    rdx,rdi
    aa9e:	xor    r8d,r8d
    aaa1:	nop    DWORD PTR [rax+0x0]
    aaa5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aab0:	mov    DWORD PTR [rsp-0x4],r8d
    aab5:	mov    rdi,r9
    aab8:	sub    rdi,r13
    aabb:	mov    rax,r14
    aabe:	xchg   ax,ax
    aac0:	test   ecx,ecx
    aac2:	js     abb0 <c_run_16.isra.0+0x1f0>
    aac8:	vmovupd ymm1,YMMWORD PTR [rdx]
    aacc:	vmulpd ymm1,ymm1,YMMWORD PTR [rax]
    aad0:	cmp    ecx,0x3
    aad3:	jle    aaf6 <c_run_16.isra.0+0x136>
    aad5:	mov    esi,0x4
    aada:	nop    WORD PTR [rax+rax*1+0x0]
    aae0:	vmovupd ymm0,YMMWORD PTR [rdx+rsi*8]
    aae5:	vmulpd ymm0,ymm0,YMMWORD PTR [rax+rsi*8]
    aaea:	add    rsi,0x4
    aaee:	vaddpd ymm1,ymm1,ymm0
    aaf2:	cmp    ecx,esi
    aaf4:	jge    aae0 <c_run_16.isra.0+0x120>
    aaf6:	vmovapd xmm0,xmm1
    aafa:	vextractf64x2 xmm1,ymm1,0x1
    ab01:	mov    r8d,r12d
    ab04:	mov    esi,r11d
    ab07:	vaddpd xmm0,xmm0,xmm1
    ab0b:	vunpckhpd xmm1,xmm0,xmm0
    ab0f:	vaddsd xmm0,xmm0,xmm1
    ab13:	cmp    r8d,0x3
    ab17:	je     abc3 <c_run_16.isra.0+0x203>
    ab1d:	cmp    r8d,0x2
    ab21:	je     ac00 <c_run_16.isra.0+0x240>
    ab27:	cmp    r8d,0x1
    ab2b:	jne    ab40 <c_run_16.isra.0+0x180>
    ab2d:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    ab32:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    ab37:	vaddsd xmm0,xmm0,xmm1
    ab3b:	nop    DWORD PTR [rax+rax*1+0x0]
    ab40:	vmovsd QWORD PTR [rdi],xmm0
    ab44:	add    rdi,0x8
    ab48:	add    rax,r10
    ab4b:	cmp    r9,rdi
    ab4e:	jne    aac0 <c_run_16.isra.0+0x100>
    ab54:	mov    r8d,DWORD PTR [rsp-0x4]
    ab59:	add    r9,r13
    ab5c:	add    rdx,r10
    ab5f:	inc    r8d
    ab62:	cmp    r15d,r8d
    ab65:	jne    aab0 <c_run_16.isra.0+0xf0>
    ab6b:	mov    rdi,QWORD PTR [rsp-0x18]
    ab70:	mov    rax,QWORD PTR [rbp+0x28]
    ab74:	mov    rdx,QWORD PTR [rbp+0x10]
    ab78:	mov    rsi,QWORD PTR [rbp+0x18]
    ab7c:	mov    r8,QWORD PTR [rbp+0x20]
    ab80:	mov    r9,QWORD PTR [rbp+0x30]
    ab84:	inc    DWORD PTR [rsp-0x8]
    ab88:	mov    edx,DWORD PTR [rsp-0x8]
    ab8c:	cmp    DWORD PTR [rsp-0xc],edx
    ab90:	je     aa40 <c_run_16.isra.0+0x80>
    ab96:	mov    rdx,QWORD PTR [rbp+0x10]
    ab9a:	mov    rsi,QWORD PTR [rbp+0x18]
    ab9e:	mov    r8,QWORD PTR [rbp+0x20]
    aba2:	mov    r9,QWORD PTR [rbp+0x30]
    aba6:	jmp    aa8d <c_run_16.isra.0+0xcd>
    abab:	nop    DWORD PTR [rax+rax*1+0x0]
    abb0:	mov    r8d,ebx
    abb3:	xor    esi,esi
    abb5:	vxorpd xmm0,xmm0,xmm0
    abb9:	cmp    r8d,0x3
    abbd:	jne    ab1d <c_run_16.isra.0+0x15d>
    abc3:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    abc8:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    abcd:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x8]
    abd3:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x8]
    abd9:	vaddsd xmm1,xmm1,xmm2
    abdd:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x10]
    abe3:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x10]
    abe9:	vaddsd xmm1,xmm1,xmm2
    abed:	vaddsd xmm0,xmm0,xmm1
    abf1:	jmp    ab40 <c_run_16.isra.0+0x180>
    abf6:	cs nop WORD PTR [rax+rax*1+0x0]
    ac00:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    ac05:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    ac0a:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x8]
    ac10:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x8]
    ac16:	vaddsd xmm1,xmm1,xmm2
    ac1a:	vaddsd xmm0,xmm0,xmm1
    ac1e:	jmp    ab40 <c_run_16.isra.0+0x180>
    ac23:	mov    rdx,QWORD PTR [rbp+0x10]
    ac27:	mov    rcx,QWORD PTR [rbp+0x18]
    ac2b:	mov    rsi,QWORD PTR [rbp+0x20]
    ac2f:	mov    r8,QWORD PTR [rbp+0x30]
    ac33:	mov    ebx,DWORD PTR [rsp-0xc]
    ac37:	lea    r9d,[r15+0x1]
    ac3b:	cmp    ebx,r9d
    ac3e:	je     aa43 <c_run_16.isra.0+0x83>
    ac44:	add    r15d,0x2
    ac48:	cmp    ebx,r15d
    ac4b:	je     aa43 <c_run_16.isra.0+0x83>
    ac51:	jmp    ac33 <c_run_16.isra.0+0x273>
    ac53:	xchg   ax,ax
    ac55:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_17.isra.0>:
    ada0:	push   rbp
    ada1:	mov    rbp,rsp
    ada4:	push   r15
    ada6:	push   r14
    ada8:	push   r13
    adaa:	push   r12
    adac:	push   rbx
    adad:	and    rsp,0xffffffffffffffe0
    adb1:	sub    rsp,0x60
    adb5:	mov    QWORD PTR [rsp+0x48],rcx
    adba:	mov    QWORD PTR [rsp+0x30],r8
    adbf:	mov    QWORD PTR [rsp+0x28],r9
    adc4:	test   edx,edx
    adc6:	je     b105 <c_run_17.isra.0+0x365>
    adcc:	mov    eax,esi
    adce:	mov    r13d,esi
    add1:	mov    DWORD PTR [rsp+0x20],edx
    add5:	mov    DWORD PTR [rsp+0x44],esi
    add9:	lea    rbx,[r13*8+0x0]
    ade1:	mov    DWORD PTR [rsp+0x40],0x0
    ade9:	mov    r15d,edi
    adec:	imul   eax,esi
    adef:	mov    QWORD PTR [rsp+0x38],rbx
    adf4:	shl    rax,0x3
    adf8:	mov    QWORD PTR [rsp+0x18],rax
    adfd:	mov    rax,r13
    ae00:	shl    rax,0x4
    ae04:	mov    QWORD PTR [rsp+0x10],rax
    ae09:	mov    rax,QWORD PTR [rsp+0x48]
    ae0e:	mov    rdi,QWORD PTR [rsp+0x30]
    ae13:	mov    rsi,QWORD PTR [rsp+0x28]
    ae18:	mov    rbx,QWORD PTR [rbp+0x10]
    ae1c:	mov    rdx,QWORD PTR [rbp+0x18]
    ae20:	mov    rcx,QWORD PTR [rbp+0x20]
    ae24:	mov    r14,QWORD PTR [rbp+0x28]
    ae28:	mov    rdx,QWORD PTR [rsp+0x18]
    ae2d:	mov    rdi,QWORD PTR [rbp+0x20]
    ae31:	xor    esi,esi
    ae33:	call   2bd0 <memset@plt>
    ae38:	mov    eax,DWORD PTR [rsp+0x44]
    ae3c:	vxorpd xmm3,xmm3,xmm3
    ae40:	test   eax,eax
    ae42:	je     b0d4 <c_run_17.isra.0+0x334>
    ae48:	test   r15d,r15d
    ae4b:	je     af83 <c_run_17.isra.0+0x1e3>
    ae51:	mov    QWORD PTR [rsp+0x50],r13
    ae56:	mov    r10d,0xfffffffd
    ae5c:	xor    r9d,r9d
    ae5f:	xor    r8d,r8d
    ae62:	xor    r12d,r12d
    ae65:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ae70:	mov    rdi,QWORD PTR [rbp+0x20]
    ae74:	movsxd rax,r9d
    ae77:	mov    ecx,r10d
    ae7a:	mov    r13d,r10d
    ae7d:	and    r13d,0xfffffffc
    ae81:	inc    r12d
    ae84:	mov    DWORD PTR [rsp+0x5c],r9d
    ae89:	xor    edx,edx
    ae8b:	add    r13d,0x4
    ae8f:	mov    r9,QWORD PTR [rsp+0x38]
    ae94:	mov    r14d,r12d
    ae97:	sub    r14d,r13d
    ae9a:	shr    ecx,0x2
    ae9d:	lea    rsi,[rdi+rax*8]
    aea1:	mov    rax,QWORD PTR [rsp+0x48]
    aea6:	shl    rcx,0x5
    aeaa:	lea    rdi,[rsi+rcx*1+0x20]
    aeaf:	sub    rax,rsi
    aeb2:	jmp    aece <c_run_17.isra.0+0x12e>
    aeb4:	nop
    aeb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aec0:	inc    edx
    aec2:	add    rax,r9
    aec5:	cmp    r15d,edx
    aec8:	je     af60 <c_run_17.isra.0+0x1c0>
    aece:	lea    r11,[rsi+rax*1]
    aed2:	vmovsd xmm1,QWORD PTR [r11+r8*8]
    aed8:	vcomisd xmm1,xmm3
    aedc:	je     aec0 <c_run_17.isra.0+0x120>
    aede:	test   r10d,r10d
    aee1:	js     b120 <c_run_17.isra.0+0x380>
    aee7:	vbroadcastsd ymm2,xmm1
    aeec:	mov    rcx,rsi
    aeef:	nop    WORD PTR [rax+rax*1+0x0]
    aef5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    af00:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
    af05:	add    rcx,0x20
    af09:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    af0e:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
    af13:	cmp    rdi,rcx
    af16:	jne    af00 <c_run_17.isra.0+0x160>
    af18:	mov    ebx,r14d
    af1b:	mov    ecx,r13d
    af1e:	cmp    ebx,0x3
    af21:	je     b12e <c_run_17.isra.0+0x38e>
    af27:	cmp    ebx,0x2
    af2a:	je     b170 <c_run_17.isra.0+0x3d0>
    af30:	cmp    ebx,0x1
    af33:	jne    aec0 <c_run_17.isra.0+0x120>
    af35:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*8]
    af3b:	inc    edx
    af3d:	add    rax,r9
    af40:	vaddsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    af45:	vmovsd QWORD PTR [rsi+rcx*8],xmm1
    af4a:	cmp    r15d,edx
    af4d:	jne    aece <c_run_17.isra.0+0x12e>
    af53:	xchg   ax,ax
    af55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    af60:	mov    r9d,DWORD PTR [rsp+0x5c]
    af65:	mov    eax,DWORD PTR [rsp+0x44]
    af69:	inc    r8
    af6c:	inc    r10d
    af6f:	add    r9d,eax
    af72:	cmp    eax,r12d
    af75:	jne    ae70 <c_run_17.isra.0+0xd0>
    af7b:	mov    r13,QWORD PTR [rsp+0x50]
    af80:	vzeroupper
    af83:	mov    r14d,DWORD PTR [rsp+0x44]
    af88:	cmp    r14d,0x1
    af8c:	je     b0d4 <c_run_17.isra.0+0x334>
    af92:	mov    rax,QWORD PTR [rbp+0x20]
    af96:	mov    DWORD PTR [rsp+0x24],r15d
    af9b:	mov    DWORD PTR [rsp+0x50],0x0
    afa3:	mov    rcx,QWORD PTR [rsp+0x10]
    afa8:	mov    r15,QWORD PTR [rsp+0x38]
    afad:	lea    r11d,[r14-0x1]
    afb1:	mov    r9d,0x8
    afb7:	mov    esi,0x1
    afbc:	xor    r12d,r12d
    afbf:	lea    r8,[rax+0x8]
    afc3:	mov    rdi,rax
    afc6:	cs nop WORD PTR [rax+rax*1+0x0]
    afd0:	mov    DWORD PTR [rsp+0x5c],r11d
    afd5:	dec    r11d
    afd8:	mov    eax,DWORD PTR [rsp+0x50]
    afdc:	cmp    r11d,0xe
    afe0:	jbe    b19c <c_run_17.isra.0+0x3fc>
    afe6:	cmp    r14d,esi
    afe9:	jle    b19c <c_run_17.isra.0+0x3fc>
    afef:	lea    r10d,[rax+r14*1]
    aff3:	mov    eax,DWORD PTR [rsp+0x5c]
    aff7:	mov    DWORD PTR [rsp+0x58],r10d
    affc:	add    r10,r12
    afff:	lea    rbx,[rax-0x1]
    b003:	lea    rax,[r10*8+0x0]
    b00b:	mov    rdx,rbx
    b00e:	imul   rdx,r13
    b012:	add    rdx,r10
    b015:	shl    rdx,0x3
    b019:	cmp    rdx,r9
    b01c:	jl     b02b <c_run_17.isra.0+0x28b>
    b01e:	lea    rdx,[r9+rbx*8]
    b022:	cmp    rax,rdx
    b025:	jle    b1a3 <c_run_17.isra.0+0x403>
    b02b:	mov    r10d,DWORD PTR [rsp+0x5c]
    b030:	add    rax,QWORD PTR [rbp+0x20]
    b034:	shr    r10d,1
    b037:	mov    edx,r10d
    b03a:	shl    rdx,0x4
    b03e:	lea    rbx,[rdx+r8*1]
    b042:	mov    rdx,r8
    b045:	nop    DWORD PTR [rax+rax*1+0x0]
    b04a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b055:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b060:	vmovsd xmm0,QWORD PTR [rax]
    b064:	vmovhpd xmm0,xmm0,QWORD PTR [rax+r13*8]
    b06a:	add    rdx,0x10
    b06e:	add    rax,rcx
    b071:	vmovupd XMMWORD PTR [rdx-0x10],xmm0
    b076:	cmp    rbx,rdx
    b079:	jne    b060 <c_run_17.isra.0+0x2c0>
    b07b:	add    r10d,r10d
    b07e:	cmp    r10d,DWORD PTR [rsp+0x5c]
    b083:	je     b0ab <c_run_17.isra.0+0x30b>
    b085:	add    r10d,esi
    b088:	mov    eax,r14d
    b08b:	mov    rbx,QWORD PTR [rbp+0x20]
    b08f:	imul   eax,r10d
    b093:	add    eax,r12d
    b096:	mov    eax,eax
    b098:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    b09d:	mov    eax,DWORD PTR [rsp+0x50]
    b0a1:	add    eax,r10d
    b0a4:	mov    eax,eax
    b0a6:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    b0ab:	mov    eax,DWORD PTR [rsp+0x58]
    b0af:	inc    rsi
    b0b2:	inc    r12
    b0b5:	add    rdi,r15
    b0b8:	lea    r9,[r15+r9*1+0x8]
    b0bd:	lea    r8,[r15+r8*1+0x8]
    b0c2:	mov    DWORD PTR [rsp+0x50],eax
    b0c6:	cmp    r13,rsi
    b0c9:	jne    afd0 <c_run_17.isra.0+0x230>
    b0cf:	mov    r15d,DWORD PTR [rsp+0x24]
    b0d4:	mov    rax,QWORD PTR [rsp+0x48]
    b0d9:	mov    rdi,QWORD PTR [rsp+0x30]
    b0de:	mov    rsi,QWORD PTR [rsp+0x28]
    b0e3:	mov    rbx,QWORD PTR [rbp+0x10]
    b0e7:	mov    rdx,QWORD PTR [rbp+0x18]
    b0eb:	mov    rcx,QWORD PTR [rbp+0x20]
    b0ef:	mov    r14,QWORD PTR [rbp+0x28]
    b0f3:	inc    DWORD PTR [rsp+0x40]
    b0f7:	mov    edi,DWORD PTR [rsp+0x20]
    b0fb:	cmp    DWORD PTR [rsp+0x40],edi
    b0ff:	jne    ae09 <c_run_17.isra.0+0x69>
    b105:	lea    rsp,[rbp-0x28]
    b109:	pop    rbx
    b10a:	pop    r12
    b10c:	pop    r13
    b10e:	pop    r14
    b110:	pop    r15
    b112:	pop    rbp
    b113:	ret
    b114:	nop
    b115:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b120:	mov    ebx,r12d
    b123:	xor    ecx,ecx
    b125:	cmp    ebx,0x3
    b128:	jne    af27 <c_run_17.isra.0+0x187>
    b12e:	shl    rcx,0x3
    b132:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    b138:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    b13d:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    b142:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1+0x8]
    b149:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rsi*1+0x8]
    b14f:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm0
    b155:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x10]
    b15c:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x10]
    b162:	vmovsd QWORD PTR [rcx+rsi*1+0x10],xmm1
    b168:	jmp    aec0 <c_run_17.isra.0+0x120>
    b16d:	nop    DWORD PTR [rax]
    b170:	shl    rcx,0x3
    b174:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    b17a:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    b17f:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    b184:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x8]
    b18b:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x8]
    b191:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm1
    b197:	jmp    aec0 <c_run_17.isra.0+0x120>
    b19c:	add    eax,r14d
    b19f:	mov    DWORD PTR [rsp+0x58],eax
    b1a3:	mov    eax,DWORD PTR [rsp+0x58]
    b1a7:	mov    rbx,QWORD PTR [rbp+0x20]
    b1ab:	add    rax,r12
    b1ae:	lea    rdx,[rbx+rax*8]
    b1b2:	mov    rax,rsi
    b1b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b1c0:	vmovsd xmm0,QWORD PTR [rdx]
    b1c4:	add    rdx,r15
    b1c7:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    b1cc:	inc    rax
    b1cf:	cmp    r14d,eax
    b1d2:	jg     b1c0 <c_run_17.isra.0+0x420>
    b1d4:	jmp    b0ab <c_run_17.isra.0+0x30b>
    b1d9:	nop    DWORD PTR [rax+0x0]


<c_run_18.isra.0>:
    b1e0:	push   rbp
    b1e1:	mov    rbp,rsp
    b1e4:	push   r15
    b1e6:	push   r14
    b1e8:	push   r13
    b1ea:	push   r12
    b1ec:	push   rbx
    b1ed:	mov    r15,rcx
    b1f0:	and    rsp,0xffffffffffffffe0
    b1f4:	sub    rsp,0x60
    b1f8:	mov    rcx,QWORD PTR [rbp+0x18]
    b1fc:	mov    QWORD PTR [rsp+0x40],r8
    b201:	mov    QWORD PTR [rsp+0x38],r9
    b206:	test   edx,edx
    b208:	je     b57a <c_run_18.isra.0+0x39a>
    b20e:	mov    ebx,esi
    b210:	mov    DWORD PTR [rsp+0x24],edx
    b214:	mov    DWORD PTR [rsp+0x48],edi
    b218:	mov    DWORD PTR [rsp+0x4c],0x0
    b220:	mov    eax,ebx
    b222:	mov    r14,rbx
    b225:	shl    r14,0x4
    b229:	imul   eax,ebx
    b22c:	mov    QWORD PTR [rsp+0x8],r14
    b231:	mov    r13,rbx
    b234:	shl    rax,0x3
    b238:	mov    QWORD PTR [rsp+0x28],rax
    b23d:	mov    eax,edi
    b23f:	lea    rax,[rcx+rax*8]
    b243:	mov    QWORD PTR [rsp+0x18],rax
    b248:	lea    rax,[rbx*8+0x0]
    b250:	mov    QWORD PTR [rsp+0x10],rax
    b255:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b260:	mov    rax,QWORD PTR [rsp+0x40]
    b265:	mov    rdi,QWORD PTR [rsp+0x38]
    b26a:	mov    rsi,QWORD PTR [rbp+0x10]
    b26e:	mov    rdx,QWORD PTR [rbp+0x20]
    b272:	mov    r8,QWORD PTR [rbp+0x28]
    b276:	mov    rdx,QWORD PTR [rsp+0x28]
    b27b:	mov    rdi,QWORD PTR [rbp+0x20]
    b27f:	xor    esi,esi
    b281:	mov    QWORD PTR [rbp+0x18],rcx
    b285:	call   2bd0 <memset@plt>
    b28a:	mov    eax,DWORD PTR [rsp+0x48]
    b28e:	mov    rcx,QWORD PTR [rbp+0x18]
    b292:	vxorpd xmm3,xmm3,xmm3
    b296:	test   eax,eax
    b298:	je     b3f6 <c_run_18.isra.0+0x216>
    b29e:	mov    r11,QWORD PTR [rsp+0x18]
    b2a3:	mov    r9,rcx
    b2a6:	xor    eax,eax
    b2a8:	mov    rdx,rcx
    b2ab:	jmp    b2d0 <c_run_18.isra.0+0xf0>
    b2ad:	nop    DWORD PTR [rax+rax*1+0x0]
    b2b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b2c0:	add    r9,0x8
    b2c4:	add    eax,r13d
    b2c7:	cmp    r11,r9
    b2ca:	je     b3f0 <c_run_18.isra.0+0x210>
    b2d0:	vcomisd xmm3,QWORD PTR [r9]
    b2d5:	je     b2c0 <c_run_18.isra.0+0xe0>
    b2d7:	test   r13d,r13d
    b2da:	je     b589 <c_run_18.isra.0+0x3a9>
    b2e0:	mov    ecx,eax
    b2e2:	mov    QWORD PTR [rsp+0x58],r11
    b2e7:	mov    DWORD PTR [rsp+0x54],eax
    b2eb:	mov    edi,0xfffffffd
    b2f0:	lea    r10,[r15+rcx*8]
    b2f4:	xor    r8d,r8d
    b2f7:	mov    ecx,0x1
    b2fc:	jmp    b311 <c_run_18.isra.0+0x131>
    b2fe:	xchg   ax,ax
    b300:	add    r8d,r13d
    b303:	inc    edi
    b305:	cmp    rcx,rbx
    b308:	je     b3c0 <c_run_18.isra.0+0x1e0>
    b30e:	inc    rcx
    b311:	vmovsd xmm0,QWORD PTR [r10+rcx*8-0x8]
    b318:	vcomisd xmm0,xmm3
    b31c:	je     b300 <c_run_18.isra.0+0x120>
    b31e:	mov    rsi,QWORD PTR [rbp+0x20]
    b322:	mov    eax,r8d
    b325:	vmulsd xmm1,xmm0,QWORD PTR [r9]
    b32a:	mov    r12d,ecx
    b32d:	lea    r14,[rsi+rax*8]
    b331:	xor    eax,eax
    b333:	test   edi,edi
    b335:	js     b382 <c_run_18.isra.0+0x1a2>
    b337:	mov    eax,edi
    b339:	mov    rsi,r14
    b33c:	sub    rsi,r10
    b33f:	vbroadcastsd ymm2,xmm1
    b344:	shr    eax,0x2
    b347:	shl    rax,0x5
    b34b:	lea    r11,[r10+rax*1+0x20]
    b350:	mov    rax,r10
    b353:	xchg   ax,ax
    b355:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b360:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    b364:	vaddpd ymm0,ymm0,YMMWORD PTR [rsi+rax*1]
    b369:	vmovupd YMMWORD PTR [rsi+rax*1],ymm0
    b36e:	add    rax,0x20
    b372:	cmp    r11,rax
    b375:	jne    b360 <c_run_18.isra.0+0x180>
    b377:	mov    eax,edi
    b379:	and    eax,0xfffffffc
    b37c:	add    eax,0x4
    b37f:	sub    r12d,eax
    b382:	cmp    r12d,0x3
    b386:	je     b5b0 <c_run_18.isra.0+0x3d0>
    b38c:	cmp    r12d,0x2
    b390:	je     b600 <c_run_18.isra.0+0x420>
    b396:	cmp    r12d,0x1
    b39a:	jne    b300 <c_run_18.isra.0+0x120>
    b3a0:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*8]
    b3a6:	add    r8d,r13d
    b3a9:	inc    edi
    b3ab:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*8]
    b3b1:	vmovsd QWORD PTR [r14+rax*8],xmm1
    b3b7:	cmp    rcx,rbx
    b3ba:	jne    b30e <c_run_18.isra.0+0x12e>
    b3c0:	mov    r11,QWORD PTR [rsp+0x58]
    b3c5:	add    r9,0x8
    b3c9:	mov    eax,DWORD PTR [rsp+0x54]
    b3cd:	cmp    r9,r11
    b3d0:	je     b3f0 <c_run_18.isra.0+0x210>
    b3d2:	add    eax,r13d
    b3d5:	vcomisd xmm3,QWORD PTR [r9]
    b3da:	jne    b2e0 <c_run_18.isra.0+0x100>
    b3e0:	add    r9,0x8
    b3e4:	add    eax,r13d
    b3e7:	cmp    r11,r9
    b3ea:	jne    b2d0 <c_run_18.isra.0+0xf0>
    b3f0:	mov    rcx,rdx
    b3f3:	vzeroupper
    b3f6:	test   r13d,r13d
    b3f9:	je     b552 <c_run_18.isra.0+0x372>
    b3ff:	cmp    r13d,0x1
    b403:	je     b552 <c_run_18.isra.0+0x372>
    b409:	mov    rax,QWORD PTR [rbp+0x20]
    b40d:	mov    DWORD PTR [rsp+0x54],0x0
    b415:	mov    r14,QWORD PTR [rsp+0x8]
    b41a:	mov    rdi,QWORD PTR [rsp+0x10]
    b41f:	mov    QWORD PTR [rsp+0x30],r15
    b424:	mov    QWORD PTR [rbp+0x18],rcx
    b428:	mov    r11d,0x8
    b42e:	mov    esi,0x1
    b433:	xor    r9d,r9d
    b436:	lea    r12d,[r13-0x1]
    b43a:	lea    r10,[rax+0x8]
    b43e:	mov    r8,rax
    b441:	nop    DWORD PTR [rax+0x0]
    b445:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b450:	mov    DWORD PTR [rsp+0x58],r12d
    b455:	dec    r12d
    b458:	mov    eax,DWORD PTR [rsp+0x54]
    b45c:	cmp    r12d,0xe
    b460:	jbe    b630 <c_run_18.isra.0+0x450>
    b466:	cmp    r13d,esi
    b469:	jle    b630 <c_run_18.isra.0+0x450>
    b46f:	mov    r15d,DWORD PTR [rsp+0x58]
    b474:	lea    ecx,[rax+r13*1]
    b478:	mov    DWORD PTR [rsp+0x50],ecx
    b47c:	add    rcx,r9
    b47f:	lea    rax,[rcx*8+0x0]
    b487:	dec    r15
    b48a:	mov    rdx,r15
    b48d:	imul   rdx,rbx
    b491:	add    rdx,rcx
    b494:	shl    rdx,0x3
    b498:	cmp    rdx,r11
    b49b:	jl     b4aa <c_run_18.isra.0+0x2ca>
    b49d:	lea    rdx,[r11+r15*8]
    b4a1:	cmp    rax,rdx
    b4a4:	jle    b637 <c_run_18.isra.0+0x457>
    b4aa:	mov    ecx,DWORD PTR [rsp+0x58]
    b4ae:	add    rax,QWORD PTR [rbp+0x20]
    b4b2:	mov    rdx,r10
    b4b5:	shr    ecx,1
    b4b7:	mov    r15d,ecx
    b4ba:	shl    r15,0x4
    b4be:	add    r15,r10
    b4c1:	nop    WORD PTR [rax+rax*1+0x0]
    b4ca:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b4d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b4e0:	vmovsd xmm0,QWORD PTR [rax]
    b4e4:	vmovhpd xmm0,xmm0,QWORD PTR [rax+rbx*8]
    b4e9:	add    rdx,0x10
    b4ed:	add    rax,r14
    b4f0:	vmovupd XMMWORD PTR [rdx-0x10],xmm0
    b4f5:	cmp    r15,rdx
    b4f8:	jne    b4e0 <c_run_18.isra.0+0x300>
    b4fa:	add    ecx,ecx
    b4fc:	cmp    ecx,DWORD PTR [rsp+0x58]
    b500:	je     b525 <c_run_18.isra.0+0x345>
    b502:	add    ecx,esi
    b504:	mov    eax,r13d
    b507:	mov    rdx,QWORD PTR [rbp+0x20]
    b50b:	imul   eax,ecx
    b50e:	add    eax,r9d
    b511:	mov    eax,eax
    b513:	vmovsd xmm0,QWORD PTR [rdx+rax*8]
    b518:	mov    eax,DWORD PTR [rsp+0x54]
    b51c:	add    eax,ecx
    b51e:	mov    eax,eax
    b520:	vmovsd QWORD PTR [rdx+rax*8],xmm0
    b525:	mov    eax,DWORD PTR [rsp+0x50]
    b529:	inc    rsi
    b52c:	inc    r9
    b52f:	add    r8,rdi
    b532:	lea    r11,[r11+rdi*1+0x8]
    b537:	lea    r10,[r10+rdi*1+0x8]
    b53c:	mov    DWORD PTR [rsp+0x54],eax
    b540:	cmp    rbx,rsi
    b543:	jne    b450 <c_run_18.isra.0+0x270>
    b549:	mov    r15,QWORD PTR [rsp+0x30]
    b54e:	mov    rcx,QWORD PTR [rbp+0x18]
    b552:	mov    rax,QWORD PTR [rsp+0x40]
    b557:	mov    rdi,QWORD PTR [rsp+0x38]
    b55c:	mov    rsi,QWORD PTR [rbp+0x10]
    b560:	mov    rdx,QWORD PTR [rbp+0x20]
    b564:	mov    r8,QWORD PTR [rbp+0x28]
    b568:	inc    DWORD PTR [rsp+0x4c]
    b56c:	mov    edi,DWORD PTR [rsp+0x24]
    b570:	cmp    DWORD PTR [rsp+0x4c],edi
    b574:	jne    b260 <c_run_18.isra.0+0x80>
    b57a:	lea    rsp,[rbp-0x28]
    b57e:	pop    rbx
    b57f:	pop    r12
    b581:	pop    r13
    b583:	pop    r14
    b585:	pop    r15
    b587:	pop    rbp
    b588:	ret
    b589:	lea    rcx,[r9+0x8]
    b58d:	cmp    r11,rcx
    b590:	je     b67a <c_run_18.isra.0+0x49a>
    b596:	add    r9,0x10
    b59a:	cmp    r9,r11
    b59d:	je     b67a <c_run_18.isra.0+0x49a>
    b5a3:	vcomisd xmm3,QWORD PTR [r9]
    b5a8:	je     b2c0 <c_run_18.isra.0+0xe0>
    b5ae:	jmp    b589 <c_run_18.isra.0+0x3a9>
    b5b0:	shl    rax,0x3
    b5b4:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1]
    b5ba:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1]
    b5c0:	vmovsd QWORD PTR [r14+rax*1],xmm0
    b5c6:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1+0x8]
    b5cd:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1+0x8]
    b5d4:	vmovsd QWORD PTR [r14+rax*1+0x8],xmm0
    b5db:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*1+0x10]
    b5e2:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*1+0x10]
    b5e9:	vmovsd QWORD PTR [r14+rax*1+0x10],xmm1
    b5f0:	jmp    b300 <c_run_18.isra.0+0x120>
    b5f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b600:	shl    rax,0x3
    b604:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1]
    b60a:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1]
    b610:	vmovsd QWORD PTR [r14+rax*1],xmm0
    b616:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*1+0x8]
    b61d:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*1+0x8]
    b624:	vmovsd QWORD PTR [r14+rax*1+0x8],xmm1
    b62b:	jmp    b300 <c_run_18.isra.0+0x120>
    b630:	add    eax,r13d
    b633:	mov    DWORD PTR [rsp+0x50],eax
    b637:	mov    eax,DWORD PTR [rsp+0x50]
    b63b:	mov    rcx,QWORD PTR [rbp+0x20]
    b63f:	add    rax,r9
    b642:	lea    rdx,[rcx+rax*8]
    b646:	mov    rax,rsi
    b649:	nop
    b64a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b655:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b660:	vmovsd xmm0,QWORD PTR [rdx]
    b664:	add    rdx,rdi
    b667:	vmovsd QWORD PTR [r8+rax*8],xmm0
    b66d:	inc    rax
    b670:	cmp    r13d,eax
    b673:	jg     b660 <c_run_18.isra.0+0x480>
    b675:	jmp    b525 <c_run_18.isra.0+0x345>
    b67a:	mov    rcx,rdx
    b67d:	vzeroupper
    b680:	jmp    b552 <c_run_18.isra.0+0x372>
    b685:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_19.isra.0>:
    b690:	push   rbp
    b691:	mov    rbp,rsp
    b694:	push   r15
    b696:	push   r14
    b698:	push   r13
    b69a:	push   r12
    b69c:	push   rbx
    b69d:	and    rsp,0xffffffffffffffe0
    b6a1:	sub    rsp,0x40
    b6a5:	mov    r12,QWORD PTR [rbp+0x20]
    b6a9:	mov    QWORD PTR [rsp+0x28],r8
    b6ae:	mov    QWORD PTR [rsp+0x20],r9
    b6b3:	mov    r8,QWORD PTR [rbp+0x18]
    b6b7:	test   edx,edx
    b6b9:	je     b8d4 <c_run_19.isra.0+0x244>
    b6bf:	mov    eax,esi
    b6c1:	mov    DWORD PTR [rsp+0x18],edx
    b6c5:	mov    DWORD PTR [rsp+0xc],edi
    b6c9:	mov    ebx,esi
    b6cb:	xor    r13d,r13d
    b6ce:	imul   eax,esi
    b6d1:	shl    rax,0x3
    b6d5:	mov    QWORD PTR [rsp+0x10],rax
    b6da:	mov    eax,edi
    b6dc:	lea    r15,[r8+rax*8]
    b6e0:	lea    eax,[rsi+0x1]
    b6e3:	mov    DWORD PTR [rsp+0x8],eax
    b6e7:	nop    WORD PTR [rax+rax*1+0x0]
    b6f0:	mov    rax,QWORD PTR [rsp+0x28]
    b6f5:	mov    rdi,QWORD PTR [rsp+0x20]
    b6fa:	mov    rdx,QWORD PTR [rbp+0x10]
    b6fe:	mov    rsi,QWORD PTR [rbp+0x28]
    b702:	mov    rdx,QWORD PTR [rsp+0x10]
    b707:	xor    esi,esi
    b709:	mov    rdi,r12
    b70c:	mov    QWORD PTR [rbp+0x18],r8
    b710:	mov    QWORD PTR [rsp+0x38],rcx
    b715:	call   2bd0 <memset@plt>
    b71a:	mov    eax,DWORD PTR [rsp+0xc]
    b71e:	mov    rcx,QWORD PTR [rsp+0x38]
    b723:	mov    r8,QWORD PTR [rbp+0x18]
    b727:	vxorpd xmm3,xmm3,xmm3
    b72b:	test   eax,eax
    b72d:	je     b8b4 <c_run_19.isra.0+0x224>
    b733:	mov    r14d,DWORD PTR [rsp+0x8]
    b738:	mov    DWORD PTR [rsp+0x1c],r13d
    b73d:	mov    QWORD PTR [rbp+0x20],r12
    b741:	mov    r9,r8
    b744:	xor    eax,eax
    b746:	mov    rdx,rcx
    b749:	jmp    b76f <c_run_19.isra.0+0xdf>
    b74b:	cs nop WORD PTR [rax+rax*1+0x0]
    b755:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b760:	add    r9,0x8
    b764:	add    eax,ebx
    b766:	cmp    r15,r9
    b769:	je     b8a5 <c_run_19.isra.0+0x215>
    b76f:	vcomisd xmm3,QWORD PTR [r9]
    b774:	je     b760 <c_run_19.isra.0+0xd0>
    b776:	test   ebx,ebx
    b778:	je     b8e3 <c_run_19.isra.0+0x253>
    b77e:	mov    QWORD PTR [rsp+0x30],r15
    b783:	mov    rdi,r8
    b786:	mov    esi,eax
    b788:	mov    DWORD PTR [rsp+0x38],eax
    b78c:	mov    r8d,0xfffffffd
    b792:	xor    r10d,r10d
    b795:	lea    r11,[rdx+rsi*8]
    b799:	mov    esi,0x1
    b79e:	jmp    b7b2 <c_run_19.isra.0+0x122>
    b7a0:	inc    rsi
    b7a3:	add    r10d,ebx
    b7a6:	inc    r8d
    b7a9:	cmp    r14,rsi
    b7ac:	je     b870 <c_run_19.isra.0+0x1e0>
    b7b2:	vmovsd xmm0,QWORD PTR [r11+rsi*8-0x8]
    b7b9:	vcomisd xmm0,xmm3
    b7bd:	je     b7a0 <c_run_19.isra.0+0x110>
    b7bf:	mov    rcx,QWORD PTR [rbp+0x20]
    b7c3:	mov    eax,r10d
    b7c6:	vmulsd xmm1,xmm0,QWORD PTR [r9]
    b7cb:	mov    r13d,esi
    b7ce:	lea    r15,[rcx+rax*8]
    b7d2:	xor    eax,eax
    b7d4:	test   r8d,r8d
    b7d7:	js     b823 <c_run_19.isra.0+0x193>
    b7d9:	mov    eax,r8d
    b7dc:	mov    rcx,r15
    b7df:	sub    rcx,r11
    b7e2:	vbroadcastsd ymm2,xmm1
    b7e7:	shr    eax,0x2
    b7ea:	shl    rax,0x5
    b7ee:	lea    r12,[r11+rax*1+0x20]
    b7f3:	mov    rax,r11
    b7f6:	cs nop WORD PTR [rax+rax*1+0x0]
    b800:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    b804:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx+rax*1]
    b809:	vmovupd YMMWORD PTR [rcx+rax*1],ymm0
    b80e:	add    rax,0x20
    b812:	cmp    r12,rax
    b815:	jne    b800 <c_run_19.isra.0+0x170>
    b817:	mov    eax,r8d
    b81a:	and    eax,0xfffffffc
    b81d:	add    eax,0x4
    b820:	sub    r13d,eax
    b823:	cmp    r13d,0x3
    b827:	je     b910 <c_run_19.isra.0+0x280>
    b82d:	cmp    r13d,0x2
    b831:	je     b960 <c_run_19.isra.0+0x2d0>
    b837:	cmp    r13d,0x1
    b83b:	jne    b7a0 <c_run_19.isra.0+0x110>
    b841:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*8]
    b847:	inc    rsi
    b84a:	add    r10d,ebx
    b84d:	inc    r8d
    b850:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*8]
    b856:	vmovsd QWORD PTR [r15+rax*8],xmm1
    b85c:	cmp    r14,rsi
    b85f:	jne    b7b2 <c_run_19.isra.0+0x122>
    b865:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b870:	mov    r15,QWORD PTR [rsp+0x30]
    b875:	add    r9,0x8
    b879:	mov    eax,DWORD PTR [rsp+0x38]
    b87d:	cmp    r9,r15
    b880:	je     b990 <c_run_19.isra.0+0x300>
    b886:	add    eax,ebx
    b888:	vcomisd xmm3,QWORD PTR [r9]
    b88d:	jne    b786 <c_run_19.isra.0+0xf6>
    b893:	add    r9,0x8
    b897:	mov    r8,rdi
    b89a:	add    eax,ebx
    b89c:	cmp    r15,r9
    b89f:	jne    b76f <c_run_19.isra.0+0xdf>
    b8a5:	mov    r13d,DWORD PTR [rsp+0x1c]
    b8aa:	mov    r12,QWORD PTR [rbp+0x20]
    b8ae:	mov    rcx,rdx
    b8b1:	vzeroupper
    b8b4:	mov    rax,QWORD PTR [rsp+0x28]
    b8b9:	mov    rdi,QWORD PTR [rsp+0x20]
    b8be:	mov    rdx,QWORD PTR [rbp+0x10]
    b8c2:	mov    rsi,QWORD PTR [rbp+0x28]
    b8c6:	inc    r13d
    b8c9:	cmp    r13d,DWORD PTR [rsp+0x18]
    b8ce:	jne    b6f0 <c_run_19.isra.0+0x60>
    b8d4:	lea    rsp,[rbp-0x28]
    b8d8:	pop    rbx
    b8d9:	pop    r12
    b8db:	pop    r13
    b8dd:	pop    r14
    b8df:	pop    r15
    b8e1:	pop    rbp
    b8e2:	ret
    b8e3:	lea    rcx,[r9+0x8]
    b8e7:	cmp    r15,rcx
    b8ea:	je     b8a5 <c_run_19.isra.0+0x215>
    b8ec:	add    r9,0x10
    b8f0:	cmp    r9,r15
    b8f3:	je     b8a5 <c_run_19.isra.0+0x215>
    b8f5:	vcomisd xmm3,QWORD PTR [r9]
    b8fa:	je     b760 <c_run_19.isra.0+0xd0>
    b900:	jmp    b8e3 <c_run_19.isra.0+0x253>
    b902:	nop    DWORD PTR [rax]
    b905:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b910:	shl    rax,0x3
    b914:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1]
    b91a:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    b920:	vmovsd QWORD PTR [r15+rax*1],xmm0
    b926:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1+0x8]
    b92d:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1+0x8]
    b934:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm0
    b93b:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*1+0x10]
    b942:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x10]
    b949:	vmovsd QWORD PTR [r15+rax*1+0x10],xmm1
    b950:	jmp    b7a0 <c_run_19.isra.0+0x110>
    b955:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b960:	shl    rax,0x3
    b964:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1]
    b96a:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    b970:	vmovsd QWORD PTR [r15+rax*1],xmm0
    b976:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*1+0x8]
    b97d:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x8]
    b984:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm1
    b98b:	jmp    b7a0 <c_run_19.isra.0+0x110>
    b990:	mov    r13d,DWORD PTR [rsp+0x1c]
    b995:	mov    r12,QWORD PTR [rbp+0x20]
    b999:	mov    rcx,rdx
    b99c:	mov    r8,rdi
    b99f:	vzeroupper
    b9a2:	jmp    b8b4 <c_run_19.isra.0+0x224>
    b9a7:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_2.isra.0>:
    6610:	mov    r11d,edi
    6613:	mov    rax,rsi
    6616:	mov    r10,QWORD PTR [rsp+0x10]
    661b:	mov    rsi,rdx
    661e:	mov    rdi,rcx
    6621:	mov    rdx,QWORD PTR [rsp+0x8]
    6626:	test   r11d,r11d
    6629:	je     669a <c_run_2.isra.0+0x8a>
    662b:	xor    ecx,ecx
    662d:	nop    DWORD PTR [rax]
    6630:	vmovsd xmm0,QWORD PTR [r8]
    6635:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x18]
    663a:	vmovsd xmm4,QWORD PTR [r8+0x8]
    6640:	vmovsd xmm3,QWORD PTR [r8+0x10]
    6646:	vmulsd xmm2,xmm4,QWORD PTR [rax+0x20]
    664b:	vmulsd xmm5,xmm4,QWORD PTR [rax+0x38]
    6650:	vmulsd xmm4,xmm4,QWORD PTR [rax+0x8]
    6655:	vaddsd xmm1,xmm1,xmm2
    6659:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x28]
    665e:	vaddsd xmm2,xmm1,xmm2
    6662:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x30]
    6667:	vmulsd xmm0,xmm0,QWORD PTR [rax]
    666b:	vaddsd xmm1,xmm1,xmm5
    666f:	vmulsd xmm5,xmm3,QWORD PTR [rax+0x40]
    6674:	vmulsd xmm3,xmm3,QWORD PTR [rax+0x10]
    6679:	vaddsd xmm0,xmm0,xmm4
    667d:	vmovsd QWORD PTR [rdx+0x8],xmm2
    6682:	vaddsd xmm1,xmm1,xmm5
    6686:	vaddsd xmm0,xmm0,xmm3
    668a:	vmovsd QWORD PTR [rdx+0x10],xmm1
    668f:	vmovsd QWORD PTR [rdx],xmm0
    6693:	inc    ecx
    6695:	cmp    ecx,r11d
    6698:	jne    6630 <c_run_2.isra.0+0x20>
    669a:	ret
    669b:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_20.isra.0>:
    b9b0:	push   rbp
    b9b1:	mov    rbp,rsp
    b9b4:	push   r15
    b9b6:	push   r14
    b9b8:	push   r13
    b9ba:	push   r12
    b9bc:	push   rbx
    b9bd:	and    rsp,0xffffffffffffffe0
    b9c1:	sub    rsp,0x40
    b9c5:	mov    QWORD PTR [rsp+0x30],rcx
    b9ca:	mov    QWORD PTR [rsp+0x28],r8
    b9cf:	mov    QWORD PTR [rsp+0x20],r9
    b9d4:	test   edx,edx
    b9d6:	je     bbb0 <c_run_20.isra.0+0x200>
    b9dc:	mov    eax,esi
    b9de:	mov    DWORD PTR [rsp+0x18],edx
    b9e2:	mov    DWORD PTR [rsp+0x38],esi
    b9e6:	mov    r12d,esi
    b9e9:	mov    ebx,edi
    b9eb:	xor    r14d,r14d
    b9ee:	imul   eax,esi
    b9f1:	shl    r12,0x3
    b9f5:	shl    rax,0x3
    b9f9:	mov    QWORD PTR [rsp+0x10],rax
    b9fe:	mov    rax,QWORD PTR [rsp+0x30]
    ba03:	mov    rdi,QWORD PTR [rsp+0x28]
    ba08:	mov    rsi,QWORD PTR [rsp+0x20]
    ba0d:	mov    rdx,QWORD PTR [rbp+0x10]
    ba11:	mov    rcx,QWORD PTR [rbp+0x18]
    ba15:	mov    r9,QWORD PTR [rbp+0x20]
    ba19:	mov    r15,QWORD PTR [rbp+0x28]
    ba1d:	mov    rdx,QWORD PTR [rsp+0x10]
    ba22:	mov    rdi,QWORD PTR [rbp+0x20]
    ba26:	xor    esi,esi
    ba28:	call   2bd0 <memset@plt>
    ba2d:	mov    eax,DWORD PTR [rsp+0x38]
    ba31:	vxorpd xmm3,xmm3,xmm3
    ba35:	test   eax,eax
    ba37:	je     bb83 <c_run_20.isra.0+0x1d3>
    ba3d:	test   ebx,ebx
    ba3f:	je     bb83 <c_run_20.isra.0+0x1d3>
    ba45:	mov    DWORD PTR [rsp+0x1c],r14d
    ba4a:	mov    r10d,0xfffffffd
    ba50:	xor    r9d,r9d
    ba53:	xor    r8d,r8d
    ba56:	xor    r13d,r13d
    ba59:	nop    DWORD PTR [rax+0x0]
    ba60:	mov    rdi,QWORD PTR [rbp+0x20]
    ba64:	movsxd rax,r9d
    ba67:	mov    ecx,r10d
    ba6a:	mov    r14d,r10d
    ba6d:	and    r14d,0xfffffffc
    ba71:	inc    r13d
    ba74:	mov    DWORD PTR [rsp+0x3c],r9d
    ba79:	xor    edx,edx
    ba7b:	add    r14d,0x4
    ba7f:	shr    ecx,0x2
    ba82:	lea    rsi,[rdi+rax*8]
    ba86:	mov    rax,QWORD PTR [rsp+0x30]
    ba8b:	mov    r15d,r13d
    ba8e:	sub    r15d,r14d
    ba91:	mov    r9d,r14d
    ba94:	shl    rcx,0x5
    ba98:	lea    rdi,[rsi+rcx*1+0x20]
    ba9d:	sub    rax,rsi
    baa0:	jmp    bacd <c_run_20.isra.0+0x11d>
    baa2:	nop    DWORD PTR [rax+rax*1+0x0]
    baaa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bab5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bac0:	inc    edx
    bac2:	add    rax,r12
    bac5:	cmp    ebx,edx
    bac7:	je     bb60 <c_run_20.isra.0+0x1b0>
    bacd:	lea    r11,[rsi+rax*1]
    bad1:	vmovsd xmm1,QWORD PTR [r11+r8*8]
    bad7:	vcomisd xmm1,xmm3
    badb:	je     bac0 <c_run_20.isra.0+0x110>
    badd:	test   r10d,r10d
    bae0:	js     bbc0 <c_run_20.isra.0+0x210>
    bae6:	vbroadcastsd ymm2,xmm1
    baeb:	mov    rcx,rsi
    baee:	nop    DWORD PTR [rax+0x0]
    baf5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bb00:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
    bb05:	add    rcx,0x20
    bb09:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    bb0e:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
    bb13:	cmp    rdi,rcx
    bb16:	jne    bb00 <c_run_20.isra.0+0x150>
    bb18:	mov    r14d,r15d
    bb1b:	mov    ecx,r9d
    bb1e:	cmp    r14d,0x3
    bb22:	je     bbcf <c_run_20.isra.0+0x21f>
    bb28:	cmp    r14d,0x2
    bb2c:	je     bc10 <c_run_20.isra.0+0x260>
    bb32:	cmp    r14d,0x1
    bb36:	jne    bac0 <c_run_20.isra.0+0x110>
    bb38:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*8]
    bb3e:	inc    edx
    bb40:	add    rax,r12
    bb43:	vaddsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    bb48:	vmovsd QWORD PTR [rsi+rcx*8],xmm1
    bb4d:	cmp    ebx,edx
    bb4f:	jne    bacd <c_run_20.isra.0+0x11d>
    bb55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    bb60:	mov    r9d,DWORD PTR [rsp+0x3c]
    bb65:	mov    eax,DWORD PTR [rsp+0x38]
    bb69:	inc    r8
    bb6c:	inc    r10d
    bb6f:	add    r9d,eax
    bb72:	cmp    eax,r13d
    bb75:	jne    ba60 <c_run_20.isra.0+0xb0>
    bb7b:	mov    r14d,DWORD PTR [rsp+0x1c]
    bb80:	vzeroupper
    bb83:	mov    rax,QWORD PTR [rsp+0x30]
    bb88:	mov    rdi,QWORD PTR [rsp+0x28]
    bb8d:	mov    rsi,QWORD PTR [rsp+0x20]
    bb92:	mov    rdx,QWORD PTR [rbp+0x10]
    bb96:	mov    rcx,QWORD PTR [rbp+0x18]
    bb9a:	mov    r9,QWORD PTR [rbp+0x20]
    bb9e:	mov    r15,QWORD PTR [rbp+0x28]
    bba2:	inc    r14d
    bba5:	cmp    r14d,DWORD PTR [rsp+0x18]
    bbaa:	jne    b9fe <c_run_20.isra.0+0x4e>
    bbb0:	lea    rsp,[rbp-0x28]
    bbb4:	pop    rbx
    bbb5:	pop    r12
    bbb7:	pop    r13
    bbb9:	pop    r14
    bbbb:	pop    r15
    bbbd:	pop    rbp
    bbbe:	ret
    bbbf:	nop
    bbc0:	mov    r14d,r13d
    bbc3:	xor    ecx,ecx
    bbc5:	cmp    r14d,0x3
    bbc9:	jne    bb28 <c_run_20.isra.0+0x178>
    bbcf:	shl    rcx,0x3
    bbd3:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    bbd9:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    bbde:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    bbe3:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1+0x8]
    bbea:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rsi*1+0x8]
    bbf0:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm0
    bbf6:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x10]
    bbfd:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x10]
    bc03:	vmovsd QWORD PTR [rcx+rsi*1+0x10],xmm1
    bc09:	jmp    bac0 <c_run_20.isra.0+0x110>
    bc0e:	xchg   ax,ax
    bc10:	shl    rcx,0x3
    bc14:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    bc1a:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    bc1f:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    bc24:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x8]
    bc2b:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x8]
    bc31:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm1
    bc37:	jmp    bac0 <c_run_20.isra.0+0x110>
    bc3c:	nop    DWORD PTR [rax+0x0]


<c_run_3.isra.0>:
    66a0:	mov    r11d,edi
    66a3:	mov    r10,QWORD PTR [rsp+0x10]
    66a8:	mov    rdi,rdx
    66ab:	mov    rax,rsi
    66ae:	mov    rdx,QWORD PTR [rsp+0x8]
    66b3:	test   r11d,r11d
    66b6:	je     6720 <c_run_3.isra.0+0x80>
    66b8:	xor    esi,esi
    66ba:	nop    WORD PTR [rax+rax*1+0x0]
    66c0:	vmovupd xmm0,XMMWORD PTR [r8]
    66c5:	vmovsd xmm1,QWORD PTR [rax+0x10]
    66ca:	vmovsd xmm3,QWORD PTR [r8+0x10]
    66d0:	vunpckhpd xmm2,xmm0,xmm0
    66d4:	vmulsd xmm2,xmm2,QWORD PTR [rax+0x28]
    66d9:	vmulsd xmm1,xmm1,xmm0
    66dd:	vaddsd xmm1,xmm1,xmm2
    66e1:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x40]
    66e6:	vmovddup xmm3,xmm3
    66ea:	vmulpd xmm3,xmm3,XMMWORD PTR [rax+0x30]
    66ef:	vaddsd xmm1,xmm1,xmm2
    66f3:	vpermilpd xmm2,xmm0,0x0
    66f9:	vpermilpd xmm0,xmm0,0x3
    66ff:	vmulpd xmm2,xmm2,XMMWORD PTR [rax]
    6703:	vmulpd xmm0,xmm0,XMMWORD PTR [rax+0x18]
    6708:	vmovsd QWORD PTR [rdx+0x10],xmm1
    670d:	vaddpd xmm0,xmm2,xmm0
    6711:	vaddpd xmm0,xmm0,xmm3
    6715:	vmovupd XMMWORD PTR [rdx],xmm0
    6719:	inc    esi
    671b:	cmp    esi,r11d
    671e:	jne    66c0 <c_run_3.isra.0+0x20>
    6720:	ret
    6721:	nop    DWORD PTR [rax+0x0]
    6725:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_4.isra.0>:
    6730:	mov    r11d,edi
    6733:	mov    r10,QWORD PTR [rsp+0x10]
    6738:	mov    rdi,rcx
    673b:	mov    rax,rsi
    673e:	mov    rcx,QWORD PTR [rsp+0x8]
    6743:	test   r11d,r11d
    6746:	je     68d7 <c_run_4.isra.0+0x1a7>
    674c:	xor    esi,esi
    674e:	xchg   ax,ax
    6750:	vmovsd xmm0,QWORD PTR [rax]
    6754:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6758:	vmovsd xmm1,QWORD PTR [rax+0x8]
    675d:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    6762:	vaddsd xmm0,xmm0,xmm1
    6766:	vmovsd xmm1,QWORD PTR [rax+0x10]
    676b:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    6770:	vaddsd xmm0,xmm0,xmm1
    6774:	vmovsd QWORD PTR [rcx],xmm0
    6778:	vmovsd xmm0,QWORD PTR [rax]
    677c:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6781:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6786:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    678b:	vaddsd xmm0,xmm0,xmm1
    678f:	vmovsd xmm1,QWORD PTR [rax+0x10]
    6794:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6799:	vaddsd xmm0,xmm0,xmm1
    679d:	vmovsd QWORD PTR [rcx+0x8],xmm0
    67a2:	vmovsd xmm0,QWORD PTR [rax]
    67a6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    67ab:	vmovsd xmm1,QWORD PTR [rax+0x8]
    67b0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    67b5:	vaddsd xmm0,xmm0,xmm1
    67b9:	vmovsd xmm1,QWORD PTR [rax+0x10]
    67be:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    67c3:	vaddsd xmm0,xmm0,xmm1
    67c7:	vmovsd QWORD PTR [rcx+0x10],xmm0
    67cc:	vmovsd xmm0,QWORD PTR [rax+0x18]
    67d1:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    67d5:	vmovsd xmm1,QWORD PTR [rax+0x20]
    67da:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    67df:	vaddsd xmm0,xmm0,xmm1
    67e3:	vmovsd xmm1,QWORD PTR [rax+0x28]
    67e8:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    67ed:	vaddsd xmm0,xmm0,xmm1
    67f1:	vmovsd QWORD PTR [rcx+0x18],xmm0
    67f6:	vmovsd xmm0,QWORD PTR [rax+0x18]
    67fb:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6800:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6805:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    680a:	vaddsd xmm0,xmm0,xmm1
    680e:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6813:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6818:	vaddsd xmm0,xmm0,xmm1
    681c:	vmovsd QWORD PTR [rcx+0x20],xmm0
    6821:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6826:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    682b:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6830:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6835:	vaddsd xmm0,xmm0,xmm1
    6839:	vmovsd xmm1,QWORD PTR [rax+0x28]
    683e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6843:	vaddsd xmm0,xmm0,xmm1
    6847:	vmovsd QWORD PTR [rcx+0x28],xmm0
    684c:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6851:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6855:	vmovsd xmm1,QWORD PTR [rax+0x38]
    685a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    685f:	vaddsd xmm0,xmm0,xmm1
    6863:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6868:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    686d:	vaddsd xmm0,xmm0,xmm1
    6871:	vmovsd QWORD PTR [rcx+0x30],xmm0
    6876:	vmovsd xmm0,QWORD PTR [rax+0x30]
    687b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6880:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6885:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    688a:	vaddsd xmm0,xmm0,xmm1
    688e:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6893:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6898:	vaddsd xmm0,xmm0,xmm1
    689c:	vmovsd QWORD PTR [rcx+0x38],xmm0
    68a1:	vmovsd xmm0,QWORD PTR [rax+0x30]
    68a6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    68ab:	vmovsd xmm1,QWORD PTR [rax+0x38]
    68b0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    68b5:	vaddsd xmm0,xmm0,xmm1
    68b9:	vmovsd xmm1,QWORD PTR [rax+0x40]
    68be:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    68c3:	vaddsd xmm0,xmm0,xmm1
    68c7:	vmovsd QWORD PTR [rcx+0x40],xmm0
    68cc:	inc    esi
    68ce:	cmp    esi,r11d
    68d1:	jne    6750 <c_run_4.isra.0+0x20>
    68d7:	ret
    68d8:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_5.isra.0>:
    68e0:	mov    r11d,edi
    68e3:	mov    r10,QWORD PTR [rsp+0x10]
    68e8:	mov    rdi,rcx
    68eb:	mov    rax,rsi
    68ee:	mov    rcx,QWORD PTR [rsp+0x8]
    68f3:	test   r11d,r11d
    68f6:	je     6a87 <c_run_5.isra.0+0x1a7>
    68fc:	xor    esi,esi
    68fe:	xchg   ax,ax
    6900:	vmovsd xmm0,QWORD PTR [rax]
    6904:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6908:	vmovsd xmm1,QWORD PTR [rax+0x18]
    690d:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    6912:	vaddsd xmm0,xmm0,xmm1
    6916:	vmovsd xmm1,QWORD PTR [rax+0x30]
    691b:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    6920:	vaddsd xmm0,xmm0,xmm1
    6924:	vmovsd QWORD PTR [rcx],xmm0
    6928:	vmovsd xmm0,QWORD PTR [rax]
    692c:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6931:	vmovsd xmm1,QWORD PTR [rax+0x18]
    6936:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    693b:	vaddsd xmm0,xmm0,xmm1
    693f:	vmovsd xmm1,QWORD PTR [rax+0x30]
    6944:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6949:	vaddsd xmm0,xmm0,xmm1
    694d:	vmovsd QWORD PTR [rcx+0x8],xmm0
    6952:	vmovsd xmm0,QWORD PTR [rax]
    6956:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    695b:	vmovsd xmm1,QWORD PTR [rax+0x18]
    6960:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6965:	vaddsd xmm0,xmm0,xmm1
    6969:	vmovsd xmm1,QWORD PTR [rax+0x30]
    696e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6973:	vaddsd xmm0,xmm0,xmm1
    6977:	vmovsd QWORD PTR [rcx+0x10],xmm0
    697c:	vmovsd xmm0,QWORD PTR [rax+0x8]
    6981:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6985:	vmovsd xmm1,QWORD PTR [rax+0x20]
    698a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    698f:	vaddsd xmm0,xmm0,xmm1
    6993:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6998:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    699d:	vaddsd xmm0,xmm0,xmm1
    69a1:	vmovsd QWORD PTR [rcx+0x18],xmm0
    69a6:	vmovsd xmm0,QWORD PTR [rax+0x8]
    69ab:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    69b0:	vmovsd xmm1,QWORD PTR [rax+0x20]
    69b5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    69ba:	vaddsd xmm0,xmm0,xmm1
    69be:	vmovsd xmm1,QWORD PTR [rax+0x38]
    69c3:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    69c8:	vaddsd xmm0,xmm0,xmm1
    69cc:	vmovsd QWORD PTR [rcx+0x20],xmm0
    69d1:	vmovsd xmm0,QWORD PTR [rax+0x8]
    69d6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    69db:	vmovsd xmm1,QWORD PTR [rax+0x20]
    69e0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    69e5:	vaddsd xmm0,xmm0,xmm1
    69e9:	vmovsd xmm1,QWORD PTR [rax+0x38]
    69ee:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    69f3:	vaddsd xmm0,xmm0,xmm1
    69f7:	vmovsd QWORD PTR [rcx+0x28],xmm0
    69fc:	vmovsd xmm0,QWORD PTR [rax+0x10]
    6a01:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6a05:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6a0a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    6a0f:	vaddsd xmm0,xmm0,xmm1
    6a13:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6a18:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    6a1d:	vaddsd xmm0,xmm0,xmm1
    6a21:	vmovsd QWORD PTR [rcx+0x30],xmm0
    6a26:	vmovsd xmm0,QWORD PTR [rax+0x10]
    6a2b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6a30:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6a35:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    6a3a:	vaddsd xmm0,xmm0,xmm1
    6a3e:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6a43:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6a48:	vaddsd xmm0,xmm0,xmm1
    6a4c:	vmovsd QWORD PTR [rcx+0x38],xmm0
    6a51:	vmovsd xmm0,QWORD PTR [rax+0x10]
    6a56:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    6a5b:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6a60:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6a65:	vaddsd xmm0,xmm0,xmm1
    6a69:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6a6e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6a73:	vaddsd xmm0,xmm0,xmm1
    6a77:	vmovsd QWORD PTR [rcx+0x40],xmm0
    6a7c:	inc    esi
    6a7e:	cmp    esi,r11d
    6a81:	jne    6900 <c_run_5.isra.0+0x20>
    6a87:	ret
    6a88:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_6.isra.0>:
    6a90:	mov    r11d,edi
    6a93:	mov    r10,QWORD PTR [rsp+0x10]
    6a98:	mov    rdi,rcx
    6a9b:	mov    rax,rsi
    6a9e:	mov    rcx,QWORD PTR [rsp+0x8]
    6aa3:	test   r11d,r11d
    6aa6:	je     6c37 <c_run_6.isra.0+0x1a7>
    6aac:	xor    esi,esi
    6aae:	xchg   ax,ax
    6ab0:	vmovsd xmm0,QWORD PTR [rax]
    6ab4:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6ab8:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6abd:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    6ac2:	vaddsd xmm0,xmm0,xmm1
    6ac6:	vmovsd xmm1,QWORD PTR [rax+0x10]
    6acb:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    6ad0:	vaddsd xmm0,xmm0,xmm1
    6ad4:	vmovsd QWORD PTR [rcx],xmm0
    6ad8:	vmovsd xmm0,QWORD PTR [rax]
    6adc:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    6ae1:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6ae6:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    6aeb:	vaddsd xmm0,xmm0,xmm1
    6aef:	vmovsd xmm1,QWORD PTR [rax+0x10]
    6af4:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6af9:	vaddsd xmm0,xmm0,xmm1
    6afd:	vmovsd QWORD PTR [rcx+0x8],xmm0
    6b02:	vmovsd xmm0,QWORD PTR [rax]
    6b06:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    6b0b:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6b10:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6b15:	vaddsd xmm0,xmm0,xmm1
    6b19:	vmovsd xmm1,QWORD PTR [rax+0x10]
    6b1e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6b23:	vaddsd xmm0,xmm0,xmm1
    6b27:	vmovsd QWORD PTR [rcx+0x10],xmm0
    6b2c:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6b31:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6b35:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6b3a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    6b3f:	vaddsd xmm0,xmm0,xmm1
    6b43:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6b48:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    6b4d:	vaddsd xmm0,xmm0,xmm1
    6b51:	vmovsd QWORD PTR [rcx+0x18],xmm0
    6b56:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6b5b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    6b60:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6b65:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    6b6a:	vaddsd xmm0,xmm0,xmm1
    6b6e:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6b73:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6b78:	vaddsd xmm0,xmm0,xmm1
    6b7c:	vmovsd QWORD PTR [rcx+0x20],xmm0
    6b81:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6b86:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    6b8b:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6b90:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6b95:	vaddsd xmm0,xmm0,xmm1
    6b99:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6b9e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6ba3:	vaddsd xmm0,xmm0,xmm1
    6ba7:	vmovsd QWORD PTR [rcx+0x28],xmm0
    6bac:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6bb1:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6bb5:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6bba:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    6bbf:	vaddsd xmm0,xmm0,xmm1
    6bc3:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6bc8:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    6bcd:	vaddsd xmm0,xmm0,xmm1
    6bd1:	vmovsd QWORD PTR [rcx+0x30],xmm0
    6bd6:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6bdb:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    6be0:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6be5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    6bea:	vaddsd xmm0,xmm0,xmm1
    6bee:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6bf3:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6bf8:	vaddsd xmm0,xmm0,xmm1
    6bfc:	vmovsd QWORD PTR [rcx+0x38],xmm0
    6c01:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6c06:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    6c0b:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6c10:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6c15:	vaddsd xmm0,xmm0,xmm1
    6c19:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6c1e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6c23:	vaddsd xmm0,xmm0,xmm1
    6c27:	vmovsd QWORD PTR [rcx+0x40],xmm0
    6c2c:	inc    esi
    6c2e:	cmp    esi,r11d
    6c31:	jne    6ab0 <c_run_6.isra.0+0x20>
    6c37:	ret
    6c38:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_7.isra.0>:
    a7d0:	push   rbp
    a7d1:	mov    rbp,rsp
    a7d4:	push   r15
    a7d6:	push   r14
    a7d8:	push   r13
    a7da:	push   r12
    a7dc:	push   rbx
    a7dd:	mov    r13,rcx
    a7e0:	mov    rcx,r8
    a7e3:	and    rsp,0xffffffffffffffe0
    a7e7:	test   edx,edx
    a7e9:	mov    DWORD PTR [rsp-0x8],edx
    a7ed:	mov    QWORD PTR [rsp-0x10],r8
    a7f2:	mov    rdx,QWORD PTR [rbp+0x10]
    a7f6:	mov    r8,QWORD PTR [rbp+0x20]
    a7fa:	je     a986 <c_run_7.isra.0+0x1b6>
    a800:	mov    eax,edi
    a802:	mov    ebx,esi
    a804:	mov    rdi,QWORD PTR [rbp+0x18]
    a808:	mov    rsi,QWORD PTR [rbp+0x28]
    a80c:	mov    r15,r9
    a80f:	test   eax,eax
    a811:	je     a995 <c_run_7.isra.0+0x1c5>
    a817:	lea    r11d,[rbx-0x8]
    a81b:	lea    ecx,[rbx-0x4]
    a81e:	mov    r9d,ebx
    a821:	lea    r10,[r8+rax*8]
    a825:	and    r11d,0xfffffffc
    a829:	mov    eax,0x4
    a82e:	add    r11d,0x8
    a832:	shl    r9,0x3
    a836:	cmp    ecx,0x3
    a839:	cmovle r11d,eax
    a83d:	xor    r14d,r14d
    a840:	mov    r12d,ebx
    a843:	sub    r12d,r11d
    a846:	cs nop WORD PTR [rax+rax*1+0x0]
    a850:	mov    DWORD PTR [rsp-0x4],r14d
    a855:	mov    rax,r13
    a858:	mov    rdi,r8
    a85b:	nop    DWORD PTR [rax+rax*1+0x0]
    a860:	test   ecx,ecx
    a862:	js     a920 <c_run_7.isra.0+0x150>
    a868:	vmovupd ymm1,YMMWORD PTR [rax]
    a86c:	vmulpd ymm1,ymm1,YMMWORD PTR [rdx]
    a870:	cmp    ecx,0x3
    a873:	jle    a896 <c_run_7.isra.0+0xc6>
    a875:	mov    esi,0x4
    a87a:	nop    WORD PTR [rax+rax*1+0x0]
    a880:	vmovupd ymm0,YMMWORD PTR [rax+rsi*8]
    a885:	vmulpd ymm0,ymm0,YMMWORD PTR [rdx+rsi*8]
    a88a:	add    rsi,0x4
    a88e:	vaddpd ymm1,ymm1,ymm0
    a892:	cmp    ecx,esi
    a894:	jge    a880 <c_run_7.isra.0+0xb0>
    a896:	vmovapd xmm0,xmm1
    a89a:	vextractf64x2 xmm1,ymm1,0x1
    a8a1:	mov    r14d,r12d
    a8a4:	mov    esi,r11d
    a8a7:	vaddpd xmm0,xmm0,xmm1
    a8ab:	vunpckhpd xmm1,xmm0,xmm0
    a8af:	vaddsd xmm0,xmm0,xmm1
    a8b3:	cmp    r14d,0x3
    a8b7:	je     a92f <c_run_7.isra.0+0x15f>
    a8b9:	cmp    r14d,0x2
    a8bd:	je     a960 <c_run_7.isra.0+0x190>
    a8c3:	cmp    r14d,0x1
    a8c7:	jne    a8e0 <c_run_7.isra.0+0x110>
    a8c9:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    a8ce:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    a8d3:	vaddsd xmm0,xmm0,xmm1
    a8d7:	nop    WORD PTR [rax+rax*1+0x0]
    a8e0:	vmovsd QWORD PTR [rdi],xmm0
    a8e4:	add    rdi,0x8
    a8e8:	add    rax,r9
    a8eb:	cmp    r10,rdi
    a8ee:	jne    a860 <c_run_7.isra.0+0x90>
    a8f4:	mov    r14d,DWORD PTR [rsp-0x4]
    a8f9:	mov    rax,QWORD PTR [rsp-0x10]
    a8fe:	mov    rdi,QWORD PTR [rbp+0x18]
    a902:	mov    rsi,QWORD PTR [rbp+0x28]
    a906:	inc    r14d
    a909:	cmp    DWORD PTR [rsp-0x8],r14d
    a90e:	je     a983 <c_run_7.isra.0+0x1b3>
    a910:	mov    rdi,QWORD PTR [rbp+0x18]
    a914:	mov    rsi,QWORD PTR [rbp+0x28]
    a918:	jmp    a850 <c_run_7.isra.0+0x80>
    a91d:	nop    DWORD PTR [rax]
    a920:	mov    r14d,ebx
    a923:	xor    esi,esi
    a925:	vxorpd xmm0,xmm0,xmm0
    a929:	cmp    r14d,0x3
    a92d:	jne    a8b9 <c_run_7.isra.0+0xe9>
    a92f:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    a934:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    a939:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x8]
    a93f:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x8]
    a945:	vaddsd xmm1,xmm1,xmm2
    a949:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x10]
    a94f:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x10]
    a955:	vaddsd xmm1,xmm1,xmm2
    a959:	vaddsd xmm0,xmm0,xmm1
    a95d:	jmp    a8e0 <c_run_7.isra.0+0x110>
    a95f:	nop
    a960:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    a965:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    a96a:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x8]
    a970:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x8]
    a976:	vaddsd xmm1,xmm1,xmm2
    a97a:	vaddsd xmm0,xmm0,xmm1
    a97e:	jmp    a8e0 <c_run_7.isra.0+0x110>
    a983:	vzeroupper
    a986:	lea    rsp,[rbp-0x28]
    a98a:	pop    rbx
    a98b:	pop    r12
    a98d:	pop    r13
    a98f:	pop    r14
    a991:	pop    r15
    a993:	pop    rbp
    a994:	ret
    a995:	mov    rcx,QWORD PTR [rsp-0x10]
    a99a:	mov    rsi,QWORD PTR [rbp+0x18]
    a99e:	mov    rdi,QWORD PTR [rbp+0x28]
    a9a2:	mov    r9d,DWORD PTR [rsp-0x8]
    a9a7:	lea    r10d,[rax+0x1]
    a9ab:	cmp    r9d,r10d
    a9ae:	je     a986 <c_run_7.isra.0+0x1b6>
    a9b0:	add    eax,0x2
    a9b3:	cmp    r9d,eax
    a9b6:	je     a986 <c_run_7.isra.0+0x1b6>
    a9b8:	jmp    a9a7 <c_run_7.isra.0+0x1d7>
    a9ba:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_8.isra.0>:
    9c90:	push   rbp
    9c91:	mov    r11d,edi
    9c94:	mov    rbp,rsp
    9c97:	push   r15
    9c99:	push   r14
    9c9b:	push   r13
    9c9d:	push   r12
    9c9f:	push   rbx
    9ca0:	and    rsp,0xffffffffffffffe0
    9ca4:	sub    rsp,0x40
    9ca8:	mov    rdi,QWORD PTR [rbp+0x20]
    9cac:	mov    QWORD PTR [rsp+0x38],r8
    9cb1:	test   edx,edx
    9cb3:	je     9e22 <c_run_8.isra.0+0x192>
    9cb9:	mov    eax,esi
    9cbb:	mov    DWORD PTR [rsp+0x1c],edx
    9cbf:	mov    DWORD PTR [rsp+0x18],r11d
    9cc4:	mov    r10,r9
    9cc7:	mov    r15,rax
    9cca:	xor    r12d,r12d
    9ccd:	shl    rax,0x3
    9cd1:	lea    ebx,[r15-0x4]
    9cd5:	mov    QWORD PTR [rsp+0x20],rax
    9cda:	mov    eax,r11d
    9cdd:	lea    r14,[r9+rax*8]
    9ce1:	mov    eax,ebx
    9ce3:	and    eax,0xfffffffc
    9ce6:	add    eax,0x4
    9ce9:	mov    r13,r14
    9cec:	mov    r14,rcx
    9cef:	mov    edx,r15d
    9cf2:	sub    edx,eax
    9cf4:	mov    DWORD PTR [rsp+0x2c],eax
    9cf8:	mov    DWORD PTR [rsp+0x28],edx
    9cfc:	nop    DWORD PTR [rax+0x0]
    9d00:	mov    rax,QWORD PTR [rsp+0x38]
    9d05:	mov    rdx,QWORD PTR [rbp+0x10]
    9d09:	mov    rsi,QWORD PTR [rbp+0x18]
    9d0d:	mov    rcx,QWORD PTR [rbp+0x28]
    9d11:	mov    rdx,QWORD PTR [rsp+0x20]
    9d16:	xor    esi,esi
    9d18:	mov    QWORD PTR [rsp+0x30],r10
    9d1d:	call   2bd0 <memset@plt>
    9d22:	mov    r10,QWORD PTR [rsp+0x30]
    9d27:	mov    rdi,rax
    9d2a:	mov    eax,DWORD PTR [rsp+0x18]
    9d2e:	test   eax,eax
    9d30:	je     9e03 <c_run_8.isra.0+0x173>
    9d36:	mov    rax,r10
    9d39:	xor    edx,edx
    9d3b:	vxorpd xmm3,xmm3,xmm3
    9d3f:	jmp    9d70 <c_run_8.isra.0+0xe0>
    9d41:	nop    WORD PTR [rax+rax*1+0x0]
    9d4a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9d55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9d60:	add    rax,0x8
    9d64:	add    edx,r15d
    9d67:	cmp    r13,rax
    9d6a:	je     9e00 <c_run_8.isra.0+0x170>
    9d70:	vmovsd xmm1,QWORD PTR [rax]
    9d74:	vcomisd xmm1,xmm3
    9d78:	je     9d60 <c_run_8.isra.0+0xd0>
    9d7a:	mov    ecx,edx
    9d7c:	lea    rsi,[r14+rcx*8]
    9d80:	test   ebx,ebx
    9d82:	js     9e40 <c_run_8.isra.0+0x1b0>
    9d88:	vbroadcastsd ymm2,xmm1
    9d8d:	xor    ecx,ecx
    9d8f:	nop    WORD PTR [rax+rax*1+0x0]
    9d95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9da0:	vmulpd ymm0,ymm2,YMMWORD PTR [rsi+rcx*8]
    9da5:	vaddpd ymm0,ymm0,YMMWORD PTR [rdi+rcx*8]
    9daa:	vmovupd YMMWORD PTR [rdi+rcx*8],ymm0
    9daf:	add    rcx,0x4
    9db3:	cmp    ebx,ecx
    9db5:	jge    9da0 <c_run_8.isra.0+0x110>
    9db7:	mov    r8d,DWORD PTR [rsp+0x28]
    9dbc:	mov    ecx,DWORD PTR [rsp+0x2c]
    9dc0:	cmp    r8d,0x3
    9dc4:	je     9e4f <c_run_8.isra.0+0x1bf>
    9dca:	cmp    r8d,0x2
    9dce:	je     9e90 <c_run_8.isra.0+0x200>
    9dd4:	cmp    r8d,0x1
    9dd8:	jne    9d60 <c_run_8.isra.0+0xd0>
    9dda:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    9ddf:	add    rax,0x8
    9de3:	add    edx,r15d
    9de6:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*8]
    9deb:	vmovsd QWORD PTR [rdi+rcx*8],xmm1
    9df0:	cmp    r13,rax
    9df3:	jne    9d70 <c_run_8.isra.0+0xe0>
    9df9:	nop    DWORD PTR [rax+0x0]
    9e00:	vzeroupper
    9e03:	mov    rax,QWORD PTR [rsp+0x38]
    9e08:	mov    rdx,QWORD PTR [rbp+0x10]
    9e0c:	mov    rsi,QWORD PTR [rbp+0x18]
    9e10:	mov    rcx,QWORD PTR [rbp+0x28]
    9e14:	inc    r12d
    9e17:	cmp    r12d,DWORD PTR [rsp+0x1c]
    9e1c:	jne    9d00 <c_run_8.isra.0+0x70>
    9e22:	lea    rsp,[rbp-0x28]
    9e26:	pop    rbx
    9e27:	pop    r12
    9e29:	pop    r13
    9e2b:	pop    r14
    9e2d:	pop    r15
    9e2f:	pop    rbp
    9e30:	ret
    9e31:	nop    DWORD PTR [rax+0x0]
    9e35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9e40:	mov    r8d,r15d
    9e43:	xor    ecx,ecx
    9e45:	cmp    r8d,0x3
    9e49:	jne    9dca <c_run_8.isra.0+0x13a>
    9e4f:	shl    rcx,0x3
    9e53:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1]
    9e58:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1]
    9e5d:	vmovsd QWORD PTR [rdi+rcx*1],xmm0
    9e62:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1+0x8]
    9e68:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1+0x8]
    9e6e:	vmovsd QWORD PTR [rdi+rcx*1+0x8],xmm0
    9e74:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*1+0x10]
    9e7a:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*1+0x10]
    9e80:	vmovsd QWORD PTR [rdi+rcx*1+0x10],xmm1
    9e86:	jmp    9d60 <c_run_8.isra.0+0xd0>
    9e8b:	nop    DWORD PTR [rax+rax*1+0x0]
    9e90:	shl    rcx,0x3
    9e94:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1]
    9e99:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1]
    9e9e:	vmovsd QWORD PTR [rdi+rcx*1],xmm0
    9ea3:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*1+0x8]
    9ea9:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*1+0x8]
    9eaf:	vmovsd QWORD PTR [rdi+rcx*1+0x8],xmm1
    9eb5:	jmp    9d60 <c_run_8.isra.0+0xd0>
    9eba:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_9.isra.0>:
    a4e0:	push   rbp
    a4e1:	mov    rbp,rsp
    a4e4:	push   r15
    a4e6:	push   r14
    a4e8:	push   r13
    a4ea:	push   r12
    a4ec:	push   rbx
    a4ed:	and    rsp,0xffffffffffffffe0
    a4f1:	mov    DWORD PTR [rsp-0x10],esi
    a4f5:	test   esi,esi
    a4f7:	je     a79f <c_run_9.isra.0+0x2bf>
    a4fd:	mov    ebx,edi
    a4ff:	mov    r15,rcx
    a502:	mov    rax,QWORD PTR [rbp+0x10]
    a506:	mov    rdi,QWORD PTR [rbp+0x18]
    a50a:	mov    rcx,QWORD PTR [rbp+0x20]
    a50e:	mov    r11,rdx
    a511:	test   ebx,ebx
    a513:	je     a7a5 <c_run_9.isra.0+0x2c5>
    a519:	lea    eax,[rbx-0x8]
    a51c:	lea    edx,[rbx-0x4]
    a51f:	mov    r10d,ebx
    a522:	mov    ecx,0x4
    a527:	and    eax,0xfffffffc
    a52a:	mov    QWORD PTR [rsp-0x28],r15
    a52f:	vxorpd xmm0,xmm0,xmm0
    a533:	add    eax,0x8
    a536:	shl    r10,0x3
    a53a:	cmp    edx,0x3
    a53d:	lea    r12,[r8+r10*1]
    a541:	cmovle eax,ecx
    a544:	xor    r13d,r13d
    a547:	mov    r14d,eax
    a54a:	lea    ecx,[rax+0x1]
    a54d:	mov    edi,ebx
    a54f:	sub    edi,eax
    a551:	shl    r14,0x3
    a555:	vmovq  xmm8,rcx
    a55a:	lea    rcx,[r9+r14*1]
    a55e:	add    eax,0x2
    a561:	mov    QWORD PTR [rsp-0x8],rcx
    a566:	vmovq  xmm6,rax
    a56b:	nop    DWORD PTR [rax+rax*1+0x0]
    a570:	mov    DWORD PTR [rsp-0xc],r13d
    a575:	mov    QWORD PTR [rsp-0x18],r11
    a57a:	mov    QWORD PTR [rsp-0x20],r8
    a57f:	mov    rcx,r8
    a582:	mov    rax,r11
    a585:	vxorpd xmm2,xmm2,xmm2
    a589:	vmovq  r8,xmm8
    a58e:	xchg   ax,ax
    a590:	vmovsd xmm3,QWORD PTR [rcx]
    a594:	mov    rsi,rax
    a597:	test   edx,edx
    a599:	js     a630 <c_run_9.isra.0+0x150>
    a59f:	vmovupd ymm4,YMMWORD PTR [r9]
    a5a4:	vmulpd ymm1,ymm4,YMMWORD PTR [rax]
    a5a8:	cmp    edx,0x3
    a5ab:	jle    a5d7 <c_run_9.isra.0+0xf7>
    a5ad:	mov    esi,0x4
    a5b2:	nop    DWORD PTR [rax]
    a5b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a5c0:	vmovupd ymm7,YMMWORD PTR [rax+rsi*8]
    a5c5:	vmulpd ymm5,ymm7,YMMWORD PTR [r9+rsi*8]
    a5cb:	add    rsi,0x4
    a5cf:	vaddpd ymm1,ymm1,ymm5
    a5d3:	cmp    edx,esi
    a5d5:	jge    a5c0 <c_run_9.isra.0+0xe0>
    a5d7:	vmovapd xmm5,xmm1
    a5db:	vextractf64x2 xmm1,ymm1,0x1
    a5e2:	vaddpd xmm5,xmm5,xmm1
    a5e6:	vunpckhpd xmm1,xmm5,xmm5
    a5ea:	vaddsd xmm7,xmm5,xmm1
    a5ee:	cmp    edi,0x3
    a5f1:	je     a6c0 <c_run_9.isra.0+0x1e0>
    a5f7:	cmp    edi,0x2
    a5fa:	je     a730 <c_run_9.isra.0+0x250>
    a600:	cmp    edi,0x1
    a603:	je     a77f <c_run_9.isra.0+0x29f>
    a609:	vmulsd xmm3,xmm7,xmm3
    a60d:	add    rcx,0x8
    a611:	vaddsd xmm2,xmm2,xmm3
    a615:	cmp    rcx,r12
    a618:	je     a66e <c_run_9.isra.0+0x18e>
    a61a:	vmovsd xmm3,QWORD PTR [rcx]
    a61e:	add    rax,r10
    a621:	jmp    a5a4 <c_run_9.isra.0+0xc4>
    a626:	cs nop WORD PTR [rax+rax*1+0x0]
    a630:	cmp    ebx,0x3
    a633:	je     a710 <c_run_9.isra.0+0x230>
    a639:	cmp    ebx,0x2
    a63c:	je     a770 <c_run_9.isra.0+0x290>
    a642:	mov    r11,r9
    a645:	vxorpd xmm7,xmm7,xmm7
    a649:	vmovsd xmm1,QWORD PTR [rsi]
    a64d:	vmulsd xmm1,xmm1,QWORD PTR [r11]
    a652:	vaddsd xmm4,xmm1,xmm7
    a656:	vmulsd xmm3,xmm4,xmm3
    a65a:	add    rcx,0x8
    a65e:	add    rax,r10
    a661:	vaddsd xmm2,xmm2,xmm3
    a665:	cmp    r12,rcx
    a668:	jne    a590 <c_run_9.isra.0+0xb0>
    a66e:	mov    r13d,DWORD PTR [rsp-0xc]
    a673:	mov    r11,QWORD PTR [rsp-0x18]
    a678:	mov    r8,QWORD PTR [rsp-0x20]
    a67d:	mov    rax,QWORD PTR [rsp-0x28]
    a682:	mov    rcx,QWORD PTR [rbp+0x10]
    a686:	mov    rsi,QWORD PTR [rbp+0x18]
    a68a:	mov    r15,QWORD PTR [rbp+0x20]
    a68e:	vaddsd xmm0,xmm0,xmm2
    a692:	inc    r13d
    a695:	cmp    DWORD PTR [rsp-0x10],r13d
    a69a:	je     a78d <c_run_9.isra.0+0x2ad>
    a6a0:	mov    rcx,QWORD PTR [rbp+0x10]
    a6a4:	mov    rsi,QWORD PTR [rbp+0x18]
    a6a8:	mov    r15,QWORD PTR [rbp+0x20]
    a6ac:	jmp    a570 <c_run_9.isra.0+0x90>
    a6b1:	nop    DWORD PTR [rax+0x0]
    a6b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a6c0:	mov    r15,QWORD PTR [rsp-0x8]
    a6c5:	vmovq  r11,xmm6
    a6ca:	lea    r13,[r8*8+0x0]
    a6d2:	lea    rsi,[rax+r14*1]
    a6d6:	lea    r11,[r11*8+0x0]
    a6de:	vmovsd xmm1,QWORD PTR [rax+r13*1]
    a6e4:	vmulsd xmm1,xmm1,QWORD PTR [r9+r13*1]
    a6ea:	vmovsd xmm4,QWORD PTR [rsi]
    a6ee:	vmulsd xmm4,xmm4,QWORD PTR [r15]
    a6f3:	vaddsd xmm1,xmm1,xmm4
    a6f7:	vmovsd xmm4,QWORD PTR [rax+r11*1]
    a6fd:	vmulsd xmm4,xmm4,QWORD PTR [r9+r11*1]
    a703:	vaddsd xmm1,xmm1,xmm4
    a707:	vaddsd xmm4,xmm1,xmm7
    a70b:	jmp    a656 <c_run_9.isra.0+0x176>
    a710:	mov    r15,r9
    a713:	mov    r13d,0x8
    a719:	mov    r11d,0x10
    a71f:	vxorpd xmm7,xmm7,xmm7
    a723:	jmp    a6de <c_run_9.isra.0+0x1fe>
    a725:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a730:	mov    r13,QWORD PTR [rsp-0x8]
    a735:	lea    rsi,[rax+r14*1]
    a739:	lea    r11,[r8*8+0x0]
    a741:	vmovsd xmm1,QWORD PTR [rax+r11*1]
    a747:	vmulsd xmm1,xmm1,QWORD PTR [r9+r11*1]
    a74d:	vmovsd xmm4,QWORD PTR [rsi]
    a751:	vmulsd xmm4,xmm4,QWORD PTR [r13+0x0]
    a757:	vaddsd xmm1,xmm1,xmm4
    a75b:	vaddsd xmm4,xmm1,xmm7
    a75f:	jmp    a656 <c_run_9.isra.0+0x176>
    a764:	nop
    a765:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a770:	mov    r13,r9
    a773:	mov    r11d,0x8
    a779:	vxorpd xmm7,xmm7,xmm7
    a77d:	jmp    a741 <c_run_9.isra.0+0x261>
    a77f:	mov    r11,QWORD PTR [rsp-0x8]
    a784:	lea    rsi,[rax+r14*1]
    a788:	jmp    a649 <c_run_9.isra.0+0x169>
    a78d:	vzeroupper
    a790:	lea    rsp,[rbp-0x28]
    a794:	pop    rbx
    a795:	pop    r12
    a797:	pop    r13
    a799:	pop    r14
    a79b:	pop    r15
    a79d:	pop    rbp
    a79e:	ret
    a79f:	vxorpd xmm0,xmm0,xmm0
    a7a3:	jmp    a790 <c_run_9.isra.0+0x2b0>
    a7a5:	mov    rax,QWORD PTR [rbp+0x10]
    a7a9:	mov    rdx,QWORD PTR [rbp+0x18]
    a7ad:	mov    rcx,QWORD PTR [rbp+0x20]
    a7b1:	mov    esi,DWORD PTR [rsp-0x10]
    a7b5:	lea    edi,[rbx+0x1]
    a7b8:	cmp    esi,edi
    a7ba:	je     a79f <c_run_9.isra.0+0x2bf>
    a7bc:	add    ebx,0x2
    a7bf:	cmp    esi,ebx
    a7c1:	je     a79f <c_run_9.isra.0+0x2bf>
    a7c3:	jmp    a7b5 <c_run_9.isra.0+0x2d5>
    a7c5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<memcpy@plt>:
    30f0:	jmp    QWORD PTR [rip+0x3f1da]        # 422d0 <memcpy@GLIBC_2.14>
    30f6:	push   0x5a
    30fb:	jmp    2b40 <_init+0x28>


<memset@plt>:
    2bd0:	jmp    QWORD PTR [rip+0x3f46a]        # 42040 <memset@GLIBC_2.2.5>
    2bd6:	push   0x8
    2bdb:	jmp    2b40 <_init+0x28>

