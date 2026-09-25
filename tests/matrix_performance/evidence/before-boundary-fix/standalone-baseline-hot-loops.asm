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
    4e50:	sub    rsp,0x30
    4e54:	mov    DWORD PTR [rsp-0x10],edx
    4e58:	test   edx,edx
    4e5a:	je     507d <bench_ada__run_10.isra.0+0x22d>
    4e60:	mov    rdx,r9
    4e63:	mov    r9d,edi
    4e66:	mov    QWORD PTR [rsp],rbx
    4e6a:	mov    ebx,esi
    4e6c:	mov    r11,r9
    4e6f:	mov    QWORD PTR [rsp+0x28],r15
    4e74:	mov    r10,rcx
    4e77:	lea    ecx,[rdi-0x1]
    4e7a:	and    r11d,0xfffffffe
    4e7e:	movsxd rdi,ecx
    4e81:	mov    rax,r8
    4e84:	mov    QWORD PTR [rsp+0x18],r13
    4e89:	mov    r15,r11
    4e8c:	mov    QWORD PTR [rsp-0x28],rdi
    4e91:	lea    r13,[rbx*8+0x0]
    4e99:	mov    QWORD PTR [rsp+0x8],rbp
    4e9e:	mov    QWORD PTR [rsp+0x20],r14
    4ea3:	mov    QWORD PTR [rsp-0x20],rax
    4ea8:	mov    rbp,QWORD PTR [rsp-0x28]
    4ead:	mov    DWORD PTR [rsp-0xc],esi
    4eb1:	lea    r8,[r9*8+0x0]
    4eb9:	mov    QWORD PTR [rsp+0x10],r12
    4ebe:	mov    r12,r13
    4ec1:	imul   r11,rbx
    4ec5:	mov    QWORD PTR [rsp-0x18],r8
    4eca:	mov    r8d,ecx
    4ecd:	mov    rcx,rdx
    4ed0:	imul   rdi,r13
    4ed4:	vmovq  xmm3,r11
    4ed9:	xor    r11d,r11d
    4edc:	mov    DWORD PTR [rsp-0x2c],r11d
    4ee1:	mov    r11,QWORD PTR [rsp+0x48]
    4ee6:	vmovq  xmm5,rdi
    4eeb:	mov    rdi,r9
    4eee:	shr    rdi,1
    4ef1:	inc    DWORD PTR [rsp-0x2c]
    4ef5:	mov    rax,QWORD PTR [rsp-0x20]
    4efa:	mov    rsi,QWORD PTR [rsp+0x38]
    4eff:	mov    rdx,QWORD PTR [rsp+0x40]
    4f04:	mov    r14,QWORD PTR [rsp+0x50]
    4f09:	cmp    DWORD PTR [rsp-0xc],0x0
    4f0e:	je     5172 <bench_ada__run_10.isra.0+0x322>
    4f14:	cmp    r8d,0xffffffff
    4f18:	je     5137 <bench_ada__run_10.isra.0+0x2e7>
    4f1e:	mov    r14,QWORD PTR [rsp-0x18]
    4f23:	mov    DWORD PTR [rsp-0x28],r8d
    4f28:	mov    rsi,rcx
    4f2b:	shr    r14,0x3
    4f2f:	mov    rcx,r14
    4f32:	mov    r8,rcx
    4f35:	mov    rax,rsi
    4f38:	xor    ecx,ecx
    4f3a:	mov    rsi,r10
    4f3d:	vmovdqa xmm1,xmm5
    4f41:	cmp    rbp,0xe
    4f45:	jbe    508e <bench_ada__run_10.isra.0+0x23e>
    4f4b:	mov    r14,rax
    4f4e:	mov    rax,r8
    4f51:	mov    r8,rsi
    4f54:	mov    rsi,rcx
    4f57:	mov    rdx,rax
    4f5a:	imul   rdx,rsi
    4f5e:	lea    r13,[r11+rdx*8]
    4f62:	add    rdx,rbp
    4f65:	lea    rdx,[r11+rdx*8]
    4f69:	cmp    rdx,r8
    4f6c:	jb     4f80 <bench_ada__run_10.isra.0+0x130>
    4f6e:	vmovq  rcx,xmm1
    4f73:	lea    rdx,[rcx+r8*1]
    4f77:	cmp    rdx,r13
    4f7a:	jae    5082 <bench_ada__run_10.isra.0+0x232>
    4f80:	mov    rdx,r8
    4f83:	xor    ecx,ecx
    4f85:	nop    DWORD PTR [rax+0x0]
    4f89:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4f94:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4f9f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4faa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4fb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    4fc0:	vmovsd xmm0,QWORD PTR [rdx]
    4fc4:	vmovhpd xmm0,xmm0,QWORD PTR [rdx+r12*1]
    4fca:	inc    rcx
    4fcd:	lea    rdx,[rdx+r12*2]
    4fd1:	add    r13,0x10
    4fd5:	vmovupd XMMWORD PTR [r13-0x10],xmm0
    4fdb:	cmp    rcx,rdi
    4fde:	jb     4fc0 <bench_ada__run_10.isra.0+0x170>
    4fe0:	cmp    r9,r15
    4fe3:	je     5020 <bench_ada__run_10.isra.0+0x1d0>
    4fe5:	vmovq  rcx,xmm3
    4fea:	lea    rdx,[rcx+rsi*1]
    4fee:	vmovsd xmm0,QWORD PTR [r10+rdx*8]
    4ff4:	mov    rdx,rax
    4ff7:	imul   rdx,rsi
    4ffb:	inc    rsi
    4ffe:	add    rdx,r15
    5001:	vmovsd QWORD PTR [r11+rdx*8],xmm0
    5007:	cmp    rbx,rsi
    500a:	je     5028 <bench_ada__run_10.isra.0+0x1d8>
    500c:	add    r8,0x8
    5010:	jmp    4f57 <bench_ada__run_10.isra.0+0x107>
    5015:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5020:	inc    rsi
    5023:	cmp    rbx,rsi
    5026:	jne    500c <bench_ada__run_10.isra.0+0x1bc>
    5028:	mov    rcx,r14
    502b:	mov    r8d,DWORD PTR [rsp-0x28]
    5030:	mov    rax,QWORD PTR [rsp-0x20]
    5035:	mov    rsi,QWORD PTR [rsp+0x38]
    503a:	mov    rdx,QWORD PTR [rsp+0x40]
    503f:	mov    r14,QWORD PTR [rsp+0x50]
    5044:	mov    esi,DWORD PTR [rsp-0x2c]
    5048:	cmp    DWORD PTR [rsp-0x10],esi
    504c:	jne    4ef1 <bench_ada__run_10.isra.0+0xa1>
    5052:	nop    DWORD PTR [rax]
    5055:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5060:	mov    rbx,QWORD PTR [rsp]
    5064:	mov    rbp,QWORD PTR [rsp+0x8]
    5069:	mov    r12,QWORD PTR [rsp+0x10]
    506e:	mov    r13,QWORD PTR [rsp+0x18]
    5073:	mov    r14,QWORD PTR [rsp+0x20]
    5078:	mov    r15,QWORD PTR [rsp+0x28]
    507d:	add    rsp,0x30
    5081:	ret
    5082:	mov    rcx,rsi
    5085:	mov    rsi,r8
    5088:	mov    r8,rax
    508b:	mov    rax,r14
    508e:	mov    rdx,r8
    5091:	mov    r14,rdi
    5094:	mov    rdi,rax
    5097:	imul   rdx,rcx
    509b:	lea    r13,[r11+rdx*8]
    509f:	xor    edx,edx
    50a1:	nop    WORD PTR [rax+rax*1+0x0]
    50aa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    50b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    50c0:	mov    rax,rbx
    50c3:	imul   rax,rdx
    50c7:	add    rax,rcx
    50ca:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    50d0:	vmovsd QWORD PTR [r13+rdx*8+0x0],xmm0
    50d7:	inc    rdx
    50da:	cmp    r9,rdx
    50dd:	jne    50c0 <bench_ada__run_10.isra.0+0x270>
    50df:	inc    rcx
    50e2:	mov    rax,rdi
    50e5:	add    rsi,0x8
    50e9:	mov    rdi,r14
    50ec:	cmp    rbx,rcx
    50ef:	jne    4f41 <bench_ada__run_10.isra.0+0xf1>
    50f5:	mov    rcx,r8
    50f8:	mov    rsi,rax
    50fb:	mov    rdx,QWORD PTR [rsp-0x20]
    5100:	mov    rax,QWORD PTR [rsp+0x38]
    5105:	mov    r14,QWORD PTR [rsp+0x40]
    510a:	mov    r8,QWORD PTR [rsp+0x50]
    510f:	mov    eax,DWORD PTR [rsp-0x2c]
    5113:	cmp    DWORD PTR [rsp-0x10],eax
    5117:	je     5060 <bench_ada__run_10.isra.0+0x210>
    511d:	inc    eax
    511f:	mov    r14,QWORD PTR [rsp+0x40]
    5124:	mov    r8,QWORD PTR [rsp+0x50]
    5129:	mov    DWORD PTR [rsp-0x2c],eax
    512d:	mov    rax,QWORD PTR [rsp+0x38]
    5132:	jmp    4f32 <bench_ada__run_10.isra.0+0xe2>
    5137:	mov    rdx,rcx
    513a:	mov    r15d,DWORD PTR [rsp-0x2c]
    513f:	mov    rax,QWORD PTR [rsp-0x20]
    5144:	mov    r14,QWORD PTR [rsp+0x38]
    5149:	mov    rbp,QWORD PTR [rsp+0x40]
    514e:	mov    r12,QWORD PTR [rsp+0x50]
    5153:	mov    ecx,DWORD PTR [rsp-0x10]
    5157:	cmp    ecx,r15d
    515a:	je     5060 <bench_ada__run_10.isra.0+0x210>
    5160:	lea    esi,[r15+0x1]
    5164:	cmp    ecx,esi
    5166:	je     5060 <bench_ada__run_10.isra.0+0x210>
    516c:	add    r15d,0x2
    5170:	jmp    5157 <bench_ada__run_10.isra.0+0x307>
    5172:	mov    rdx,rcx
    5175:	mov    r15d,DWORD PTR [rsp-0x2c]
    517a:	mov    rax,QWORD PTR [rsp-0x20]
    517f:	mov    r14,QWORD PTR [rsp+0x38]
    5184:	mov    rbp,QWORD PTR [rsp+0x40]
    5189:	mov    r12,QWORD PTR [rsp+0x50]
    518e:	mov    ecx,DWORD PTR [rsp-0x10]
    5192:	nop    DWORD PTR [rax]
    5195:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    51a0:	cmp    ecx,r15d
    51a3:	je     5060 <bench_ada__run_10.isra.0+0x210>
    51a9:	lea    esi,[r15+0x1]
    51ad:	cmp    ecx,esi
    51af:	je     5060 <bench_ada__run_10.isra.0+0x210>
    51b5:	add    r15d,0x2
    51b9:	jmp    51a0 <bench_ada__run_10.isra.0+0x350>
    51bb:	nop
    51bc:	nop    DWORD PTR [rax+0x0]


<bench_ada__run_11.isra.0>:
    51c0:	sub    rsp,0x30
    51c4:	mov    QWORD PTR [rsp+0x10],r12
    51c9:	mov    QWORD PTR [rsp+0x18],r13
    51ce:	mov    DWORD PTR [rsp-0xc],esi
    51d2:	mov    r12,QWORD PTR [rsp+0x38]
    51d7:	mov    r10,QWORD PTR [rsp+0x40]
    51dc:	mov    r13,QWORD PTR [rsp+0x48]
    51e1:	test   esi,esi
    51e3:	je     53ac <bench_ada__run_11.isra.0+0x1ec>
    51e9:	mov    QWORD PTR [rsp+0x8],rbp
    51ee:	mov    r11d,edi
    51f1:	mov    rbp,rcx
    51f4:	mov    rdi,rdx
    51f7:	test   r11d,r11d
    51fa:	je     53bb <bench_ada__run_11.isra.0+0x1fb>
    5200:	vmovsd xmm1,QWORD PTR [rip+0x2e2d0]        # 334d8 <system__os_lib__standin+0xc>
    5208:	mov    QWORD PTR [rsp],rbx
    520c:	mov    QWORD PTR [rsp-0x8],rcx
    5211:	mov    QWORD PTR [rsp+0x48],r13
    5216:	mov    QWORD PTR [rsp+0x20],r14
    521b:	mov    QWORD PTR [rsp+0x28],r15
    5220:	lea    r14,[r11+0x1]
    5224:	lea    r15,[r11*8+0x0]
    522c:	mov    QWORD PTR [rsp+0x38],r12
    5231:	mov    edx,0x1
    5236:	mov    r12,r9
    5239:	vmovq  xmm3,r15
    523e:	mov    r9,r8
    5241:	vmovq  xmm2,r14
    5246:	cs nop WORD PTR [rax+rax*1+0x0]
    5250:	mov    r13,r12
    5253:	mov    DWORD PTR [rsp-0x10],edx
    5257:	mov    r12,r9
    525a:	mov    rbx,r10
    525d:	xor    esi,esi
    525f:	vmovq  r14,xmm3
    5264:	mov    r9,0xffffffffffffffff
    526b:	jmp    5292 <bench_ada__run_11.isra.0+0xd2>
    526d:	nop    DWORD PTR [rax+rax*1+0x0]
    5275:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5280:	inc    rsi
    5283:	inc    r9
    5286:	add    rbx,r14
    5289:	cmp    r11,rsi
    528c:	je     5377 <bench_ada__run_11.isra.0+0x1b7>
    5292:	vmovq  rax,xmm2
    5297:	imul   rax,rsi
    529b:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    52a0:	vmovsd QWORD PTR [r10+rax*8],xmm0
    52a6:	test   r9d,r9d
    52a9:	js     5280 <bench_ada__run_11.isra.0+0xc0>
    52ab:	movsxd r15,esi
    52ae:	mov    ecx,r9d
    52b1:	mov    rbp,r13
    52b4:	xor    eax,eax
    52b6:	mov    r8,r15
    52b9:	mov    r13,r12
    52bc:	mov    r12,r9
    52bf:	imul   r8,r14
    52c3:	lea    r9,[r8+rdi*1]
    52c7:	mov    r8,rcx
    52ca:	jmp    5330 <bench_ada__run_11.isra.0+0x170>
    52cc:	nop    DWORD PTR [rax+rax*1+0x0]
    52d4:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    52df:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    52ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    52f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5300:	mov    rdx,rax
    5303:	vmovsd xmm0,QWORD PTR [r9+rax*8]
    5309:	imul   rdx,r11
    530d:	lea    rcx,[rdx+r15*1]
    5311:	add    rdx,rsi
    5314:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*8]
    5319:	vmulsd xmm0,xmm0,xmm1
    531d:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    5322:	vmovsd QWORD PTR [r10+rdx*8],xmm0
    5328:	cmp    r8,rax
    532b:	je     535c <bench_ada__run_11.isra.0+0x19c>
    532d:	inc    rax
    5330:	cmp    esi,eax
    5332:	jne    5300 <bench_ada__run_11.isra.0+0x140>
    5334:	vmovq  rdx,xmm2
    5339:	imul   rdx,rax
    533d:	vmovsd xmm0,QWORD PTR [rdi+rdx*8]
    5342:	mov    rdx,rax
    5345:	imul   rdx,r11
    5349:	add    rdx,rsi
    534c:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    5351:	vmovsd QWORD PTR [r10+rdx*8],xmm0
    5357:	cmp    r8,rax
    535a:	jne    532d <bench_ada__run_11.isra.0+0x16d>
    535c:	mov    r9,r12
    535f:	inc    rsi
    5362:	mov    r12,r13
    5365:	add    rbx,r14
    5368:	mov    r13,rbp
    536b:	inc    r9
    536e:	cmp    r11,rsi
    5371:	jne    5292 <bench_ada__run_11.isra.0+0xd2>
    5377:	mov    r9,r12
    537a:	mov    edx,DWORD PTR [rsp-0x10]
    537e:	mov    rax,QWORD PTR [rsp-0x8]
    5383:	mov    rbx,QWORD PTR [rsp+0x38]
    5388:	mov    rcx,QWORD PTR [rsp+0x48]
    538d:	mov    r12,r13
    5390:	cmp    DWORD PTR [rsp-0xc],edx
    5394:	je     53d4 <bench_ada__run_11.isra.0+0x214>
    5396:	mov    rcx,QWORD PTR [rsp+0x38]
    539b:	mov    rbx,QWORD PTR [rsp+0x48]
    53a0:	inc    edx
    53a2:	jmp    5250 <bench_ada__run_11.isra.0+0x90>
    53a7:	mov    rbp,QWORD PTR [rsp+0x8]
    53ac:	mov    r12,QWORD PTR [rsp+0x10]
    53b1:	mov    r13,QWORD PTR [rsp+0x18]
    53b6:	add    rsp,0x30
    53ba:	ret
    53bb:	mov    edx,DWORD PTR [rsp-0xc]
    53bf:	mov    eax,0x1
    53c4:	cmp    edx,eax
    53c6:	je     53a7 <bench_ada__run_11.isra.0+0x1e7>
    53c8:	lea    ecx,[rax+0x1]
    53cb:	cmp    edx,ecx
    53cd:	je     53a7 <bench_ada__run_11.isra.0+0x1e7>
    53cf:	add    eax,0x2
    53d2:	jmp    53c4 <bench_ada__run_11.isra.0+0x204>
    53d4:	mov    rbx,QWORD PTR [rsp]
    53d8:	mov    rbp,QWORD PTR [rsp+0x8]
    53dd:	mov    r14,QWORD PTR [rsp+0x20]
    53e2:	mov    r15,QWORD PTR [rsp+0x28]
    53e7:	jmp    53ac <bench_ada__run_11.isra.0+0x1ec>
    53e9:	nop
    53ea:	nop    WORD PTR [rax+rax*1+0x0]


<bench_ada__run_12.isra.0>:
    77a0:	sub    rsp,0x48
    77a4:	mov    QWORD PTR [rsp+0x18],rbx
    77a9:	mov    QWORD PTR [rsp+0x38],r14
    77ae:	mov    QWORD PTR [rsp+0x40],r15
    77b3:	mov    ebx,edi
    77b5:	mov    r14,rcx
    77b8:	mov    r15,r8
    77bb:	mov    rcx,QWORD PTR [rsp+0x50]
    77c0:	mov    rdi,QWORD PTR [rsp+0x58]
    77c5:	mov    r8,QWORD PTR [rsp+0x60]
    77ca:	test   esi,esi
    77cc:	je     7895 <bench_ada__run_12.isra.0+0xf5>
    77d2:	mov    QWORD PTR [rsp+0x28],r12
    77d7:	mov    QWORD PTR [rsp+0x30],r13
    77dc:	mov    r12,rdx
    77df:	mov    r13,r9
    77e2:	test   ebx,ebx
    77e4:	je     78a9 <bench_ada__run_12.isra.0+0x109>
    77ea:	lea    rax,[rbx*8+0x0]
    77f2:	mov    DWORD PTR [rsp+0xc],esi
    77f6:	mov    rsi,rbx
    77f9:	mov    DWORD PTR [rsp+0x8],0x1
    7801:	mov    QWORD PTR [rsp+0x20],rbp
    7806:	imul   rsi,rax
    780a:	shr    rax,0x3
    780e:	mov    QWORD PTR [rsp],rsi
    7812:	lea    rbp,[rax+0x1]
    7816:	mov    rdx,QWORD PTR [rsp]
    781a:	xor    esi,esi
    781c:	mov    QWORD PTR [rsp+0x60],r8
    7821:	mov    QWORD PTR [rsp+0x50],rcx
    7826:	call   2bd0 <memset@plt>
    782b:	vmovsd xmm0,QWORD PTR [rip+0x2bcd5]        # 33508 <system__os_lib__standin+0x3c>
    7833:	mov    r8,QWORD PTR [rsp+0x60]
    7838:	mov    rcx,QWORD PTR [rsp+0x50]
    783d:	mov    rdi,rax
    7840:	xor    eax,eax
    7842:	nop    DWORD PTR [rax+rax*1+0x0]
    784a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7855:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7860:	mov    rdx,rbp
    7863:	imul   rdx,rax
    7867:	inc    rax
    786a:	vmovsd QWORD PTR [rdi+rdx*8],xmm0
    786f:	cmp    rax,rbx
    7872:	jne    7860 <bench_ada__run_12.isra.0+0xc0>
    7874:	mov    eax,DWORD PTR [rsp+0x8]
    7878:	cmp    DWORD PTR [rsp+0xc],eax
    787c:	je     7886 <bench_ada__run_12.isra.0+0xe6>
    787e:	inc    eax
    7880:	mov    DWORD PTR [rsp+0x8],eax
    7884:	jmp    7816 <bench_ada__run_12.isra.0+0x76>
    7886:	mov    rbp,QWORD PTR [rsp+0x20]
    788b:	mov    r12,QWORD PTR [rsp+0x28]
    7890:	mov    r13,QWORD PTR [rsp+0x30]
    7895:	mov    rbx,QWORD PTR [rsp+0x18]
    789a:	mov    r14,QWORD PTR [rsp+0x38]
    789f:	mov    r15,QWORD PTR [rsp+0x40]
    78a4:	add    rsp,0x48
    78a8:	ret
    78a9:	mov    eax,0x1
    78ae:	cmp    esi,eax
    78b0:	je     788b <bench_ada__run_12.isra.0+0xeb>
    78b2:	lea    edx,[rax+0x1]
    78b5:	cmp    esi,edx
    78b7:	je     788b <bench_ada__run_12.isra.0+0xeb>
    78b9:	add    eax,0x2
    78bc:	cmp    esi,eax
    78be:	jne    78b2 <bench_ada__run_12.isra.0+0x112>
    78c0:	jmp    788b <bench_ada__run_12.isra.0+0xeb>
    78c2:	nop    DWORD PTR [rax]
    78c5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_13.isra.0>:
    53f0:	push   rbp
    53f1:	mov    rbp,rsp
    53f4:	push   r15
    53f6:	push   r14
    53f8:	push   r13
    53fa:	push   r12
    53fc:	push   rbx
    53fd:	mov    r12,r9
    5400:	and    rsp,0xffffffffffffffc0
    5404:	test   edx,edx
    5406:	mov    rax,QWORD PTR [rbp+0x10]
    540a:	mov    DWORD PTR [rsp-0xc],edx
    540e:	mov    r15,QWORD PTR [rbp+0x18]
    5412:	mov    r10,QWORD PTR [rbp+0x20]
    5416:	mov    r9,QWORD PTR [rbp+0x28]
    541a:	je     544c <bench_ada__run_13.isra.0+0x5c>
    541c:	mov    rbx,rcx
    541f:	mov    rdx,r8
    5422:	sar    edi,1
    5424:	lea    ecx,[rdi-0x1]
    5427:	cmp    ecx,0xffffffff
    542a:	je     545b <bench_ada__run_13.isra.0+0x6b>
    542c:	test   esi,esi
    542e:	jne    5474 <bench_ada__run_13.isra.0+0x84>
    5430:	mov    esi,DWORD PTR [rsp-0xc]
    5434:	mov    ecx,0x1
    5439:	cmp    esi,ecx
    543b:	je     544c <bench_ada__run_13.isra.0+0x5c>
    543d:	lea    edi,[rcx+0x1]
    5440:	cmp    esi,edi
    5442:	je     544c <bench_ada__run_13.isra.0+0x5c>
    5444:	add    ecx,0x2
    5447:	jmp    5439 <bench_ada__run_13.isra.0+0x49>
    5449:	vzeroupper
    544c:	lea    rsp,[rbp-0x28]
    5450:	pop    rbx
    5451:	pop    r12
    5453:	pop    r13
    5455:	pop    r14
    5457:	pop    r15
    5459:	pop    rbp
    545a:	ret
    545b:	mov    esi,DWORD PTR [rsp-0xc]
    545f:	mov    ecx,0x1
    5464:	cmp    esi,ecx
    5466:	je     544c <bench_ada__run_13.isra.0+0x5c>
    5468:	lea    edi,[rcx+0x1]
    546b:	cmp    esi,edi
    546d:	je     544c <bench_ada__run_13.isra.0+0x5c>
    546f:	add    ecx,0x2
    5472:	jmp    5464 <bench_ada__run_13.isra.0+0x74>
    5474:	vmovdqa xmm2,XMMWORD PTR [rip+0x2e174]        # 335f0 <system__secondary_stack__invalid_memory_size+0xa8>
    547c:	mov    QWORD PTR [rsp-0x18],r8
    5481:	mov    QWORD PTR [rsp-0x20],r12
    5486:	mov    QWORD PTR [rbp+0x10],rax
    548a:	mov    QWORD PTR [rbp+0x18],r15
    548e:	mov    r11d,esi
    5491:	dec    esi
    5493:	mov    edx,0x1
    5498:	mov    rdi,r11
    549b:	shr    rdi,0x3
    549f:	vmovd  xmm3,ecx
    54a3:	mov    r14,r11
    54a6:	mov    QWORD PTR [rsp-0x8],rsi
    54ab:	mov    rsi,r10
    54ae:	sub    rsi,rbx
    54b1:	and    r14d,0xfffffff8
    54b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    54c0:	mov    DWORD PTR [rsp-0x10],edx
    54c4:	mov    r8,0xffffffffffffffff
    54cb:	mov    r15,rbx
    54ce:	vmovq  r12,xmm3
    54d3:	xchg   ax,ax
    54d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    54e0:	inc    r8
    54e3:	movsxd rax,DWORD PTR [r9+r8*4]
    54e7:	imul   rax,r11
    54eb:	lea    rcx,[rax*8+0x0]
    54f3:	lea    rbx,[r15+rcx*1]
    54f7:	lea    r13,[r10+rcx*1]
    54fb:	lea    rcx,[rcx+r10*1-0x8]
    5500:	sub    rcx,rbx
    5503:	mov    rdx,rbx
    5506:	cmp    rcx,0x30
    550a:	jbe    55c0 <bench_ada__run_13.isra.0+0x1d0>
    5510:	cmp    QWORD PTR [rsp-0x8],0x6
    5516:	jbe    55f6 <bench_ada__run_13.isra.0+0x206>
    551c:	xor    ecx,ecx
    551e:	xchg   ax,ax
    5520:	vmovupd zmm0,ZMMWORD PTR [rdx]
    5526:	inc    rcx
    5529:	vmovupd ZMMWORD PTR [rsi+rdx*1],zmm0
    5530:	add    rdx,0x40
    5534:	cmp    rcx,rdi
    5537:	jb     5520 <bench_ada__run_13.isra.0+0x130>
    5539:	mov    rdx,r14
    553c:	cmp    r14,r11
    553f:	je     5579 <bench_ada__run_13.isra.0+0x189>
    5541:	add    rax,rdx
    5544:	mov    rcx,r11
    5547:	sub    rcx,rdx
    554a:	mov    edx,0x8
    554f:	xor    ebx,ebx
    5551:	xor    r13d,r13d
    5554:	cmp    rdx,rcx
    5557:	sbb    r13,rbx
    555a:	cmovb  rcx,rdx
    555e:	vpbroadcastw xmm0,ecx
    5564:	vpcmpnleuw k1,xmm0,xmm2
    556b:	vmovupd zmm0{k1}{z},ZMMWORD PTR [r15+rax*8]
    5572:	vmovupd ZMMWORD PTR [r10+rax*8]{k1},zmm0
    5579:	cmp    r8,r12
    557c:	jne    54e0 <bench_ada__run_13.isra.0+0xf0>
    5582:	mov    rbx,r15
    5585:	mov    edx,DWORD PTR [rsp-0x10]
    5589:	mov    rax,QWORD PTR [rsp-0x18]
    558e:	mov    rcx,QWORD PTR [rsp-0x20]
    5593:	mov    r15,QWORD PTR [rbp+0x10]
    5597:	mov    r8,QWORD PTR [rbp+0x18]
    559b:	cmp    DWORD PTR [rsp-0xc],edx
    559f:	je     5449 <bench_ada__run_13.isra.0+0x59>
    55a5:	mov    r15,QWORD PTR [rbp+0x10]
    55a9:	mov    r8,QWORD PTR [rbp+0x18]
    55ad:	inc    edx
    55af:	jmp    54c0 <bench_ada__run_13.isra.0+0xd0>
    55b4:	nop
    55b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    55c0:	xor    eax,eax
    55c2:	nop    DWORD PTR [rax+rax*1+0x0]
    55ca:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    55d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    55e0:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    55e5:	vmovsd QWORD PTR [r13+rax*8+0x0],xmm0
    55ec:	inc    rax
    55ef:	cmp    rax,r11
    55f2:	jne    55e0 <bench_ada__run_13.isra.0+0x1f0>
    55f4:	jmp    5579 <bench_ada__run_13.isra.0+0x189>
    55f6:	xor    edx,edx
    55f8:	jmp    5541 <bench_ada__run_13.isra.0+0x151>
    55fd:	nop
    55fe:	xchg   ax,ax


<bench_ada__run_14.isra.0>:
    78d0:	push   rbp
    78d1:	mov    r11d,ecx
    78d4:	mov    r10d,edi
    78d7:	mov    rbp,rsp
    78da:	push   r15
    78dc:	push   r14
    78de:	push   r13
    78e0:	push   r12
    78e2:	push   rbx
    78e3:	and    rsp,0xffffffffffffffc0
    78e7:	add    rsp,0xffffffffffffff80
    78eb:	mov    rcx,QWORD PTR [rbp+0x18]
    78ef:	mov    rax,QWORD PTR [rbp+0x20]
    78f3:	mov    rdi,QWORD PTR [rbp+0x28]
    78f7:	mov    r14,QWORD PTR [rbp+0x30]
    78fb:	test   r11d,r11d
    78fe:	je     79f6 <bench_ada__run_14.isra.0+0x126>
    7904:	mov    rbx,r8
    7907:	mov    r12,r9
    790a:	mov    r8,QWORD PTR [rbp+0x10]
    790e:	test   r10d,r10d
    7911:	je     79d7 <bench_ada__run_14.isra.0+0x107>
    7917:	mov    r15d,esi
    791a:	mov    DWORD PTR [rsp+0x2c],esi
    791e:	lea    esi,[rdx-0x1]
    7921:	mov    DWORD PTR [rsp+0x14],r11d
    7926:	mov    DWORD PTR [rsp+0x6c],esi
    792a:	mov    esi,edx
    792c:	mov    r11d,edx
    792f:	mov    DWORD PTR [rsp+0x78],edx
    7933:	lea    r8,[rsi*8+0x0]
    793b:	mov    edx,r10d
    793e:	mov    esi,r15d
    7941:	mov    DWORD PTR [rsp+0x28],0x1
    7949:	mov    r9,r8
    794c:	mov    QWORD PTR [rsp+0x20],rsi
    7951:	mov    QWORD PTR [rsp+0x60],r8
    7956:	lea    r15,[rdx-0x1]
    795a:	mov    QWORD PTR [rbp+0x18],rcx
    795e:	mov    QWORD PTR [rbp+0x20],rax
    7962:	mov    QWORD PTR [rbp+0x30],r14
    7966:	mov    QWORD PTR [rsp+0x38],r15
    796b:	imul   r9,rdx
    796f:	shl    rsi,0x3
    7973:	test   r11d,r11d
    7976:	mov    QWORD PTR [rsp+0x30],r9
    797b:	mov    QWORD PTR [rsp+0x18],rsi
    7980:	setne  BYTE PTR [rsp+0x7f]
    7985:	shr    r8,0x3
    7989:	mov    QWORD PTR [rsp+0x70],r8
    798e:	mov    rdx,QWORD PTR [rsp+0x30]
    7993:	xor    esi,esi
    7995:	call   2bd0 <memset@plt>
    799a:	mov    rdi,rax
    799d:	mov    eax,DWORD PTR [rsp+0x2c]
    79a1:	test   eax,eax
    79a3:	jne    7a05 <bench_ada__run_14.isra.0+0x135>
    79a5:	mov    rax,QWORD PTR [rbp+0x10]
    79a9:	mov    rdx,QWORD PTR [rbp+0x18]
    79ad:	mov    rcx,QWORD PTR [rbp+0x20]
    79b1:	mov    rsi,QWORD PTR [rbp+0x30]
    79b5:	mov    eax,DWORD PTR [rsp+0x28]
    79b9:	cmp    DWORD PTR [rsp+0x14],eax
    79bd:	je     79f6 <bench_ada__run_14.isra.0+0x126>
    79bf:	inc    eax
    79c1:	mov    rdx,QWORD PTR [rbp+0x18]
    79c5:	mov    rcx,QWORD PTR [rbp+0x20]
    79c9:	mov    rsi,QWORD PTR [rbp+0x30]
    79cd:	mov    DWORD PTR [rsp+0x28],eax
    79d1:	mov    rax,QWORD PTR [rbp+0x10]
    79d5:	jmp    798e <bench_ada__run_14.isra.0+0xbe>
    79d7:	mov    rsi,QWORD PTR [rbp+0x10]
    79db:	mov    edx,0x1
    79e0:	cmp    r11d,edx
    79e3:	je     79f6 <bench_ada__run_14.isra.0+0x126>
    79e5:	lea    r8d,[rdx+0x1]
    79e9:	cmp    r11d,r8d
    79ec:	je     79f6 <bench_ada__run_14.isra.0+0x126>
    79ee:	add    edx,0x2
    79f1:	cmp    r11d,edx
    79f4:	jne    79e5 <bench_ada__run_14.isra.0+0x115>
    79f6:	lea    rsp,[rbp-0x28]
    79fa:	pop    rbx
    79fb:	pop    r12
    79fd:	pop    r13
    79ff:	pop    r14
    7a01:	pop    r15
    7a03:	pop    rbp
    7a04:	ret
    7a05:	mov    rax,QWORD PTR [rsp+0x20]
    7a0a:	mov    r11,QWORD PTR [rsp+0x18]
    7a0f:	mov    r9,0xffffffffffffffff
    7a16:	vxorpd xmm7,xmm7,xmm7
    7a1a:	lea    r13,[rax-0x1]
    7a1e:	mov    eax,DWORD PTR [rsp+0x78]
    7a22:	shr    r11,0x3
    7a26:	mov    QWORD PTR [rsp+0x40],r11
    7a2b:	shr    eax,0x3
    7a2e:	mov    DWORD PTR [rsp+0x68],eax
    7a32:	shl    rax,0x6
    7a36:	mov    QWORD PTR [rsp+0x48],rax
    7a3b:	nop    DWORD PTR [rax+rax*1+0x0]
    7a40:	mov    r11,QWORD PTR [rsp+0x40]
    7a45:	mov    r14,QWORD PTR [rsp+0x70]
    7a4a:	inc    r9
    7a4d:	mov    rcx,QWORD PTR [rsp+0x48]
    7a52:	movsxd rsi,r9d
    7a55:	mov    QWORD PTR [rsp+0x50],r9
    7a5a:	mov    rax,0xffffffffffffffff
    7a61:	imul   r11,rsi
    7a65:	imul   r14,rsi
    7a69:	imul   rsi,QWORD PTR [rsp+0x60]
    7a6f:	mov    r8,r11
    7a72:	mov    r9,r14
    7a75:	lea    rdx,[rsi+rdi*1]
    7a79:	mov    QWORD PTR [rsp+0x58],rdx
    7a7e:	lea    r15,[rcx+rdx*1]
    7a82:	jmp    7ac9 <bench_ada__run_14.isra.0+0x1f9>
    7a84:	nop    DWORD PTR [rax+rax*1+0x0]
    7a89:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7a94:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7a9f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7aaa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7ab5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7ac0:	cmp    rax,r13
    7ac3:	je     7c20 <bench_ada__run_14.isra.0+0x350>
    7ac9:	inc    rax
    7acc:	movsxd rdx,eax
    7acf:	lea    rsi,[r8+rdx*1]
    7ad3:	vmovsd xmm1,QWORD PTR [rbx+rsi*8]
    7ad8:	vcomisd xmm1,xmm7
    7adc:	vbroadcastsd zmm2,xmm1
    7ae2:	je     7ac0 <bench_ada__run_14.isra.0+0x1f0>
    7ae4:	cmp    BYTE PTR [rsp+0x7f],0x0
    7ae9:	je     7ac0 <bench_ada__run_14.isra.0+0x1f0>
    7aeb:	cmp    DWORD PTR [rsp+0x6c],0x6
    7af0:	jbe    7c70 <bench_ada__run_14.isra.0+0x3a0>
    7af6:	mov    r10,QWORD PTR [rsp+0x60]
    7afb:	mov    rcx,QWORD PTR [rsp+0x58]
    7b00:	vmovapd zmm3,zmm2
    7b06:	imul   r10,rdx
    7b0a:	mov    rsi,rcx
    7b0d:	add    r10,r12
    7b10:	sub    r10,rcx
    7b13:	xchg   ax,ax
    7b15:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7b20:	vmulpd zmm0,zmm3,ZMMWORD PTR [rsi+r10*1]
    7b27:	add    rsi,0x40
    7b2b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rsi-0x40]
    7b32:	vmovupd ZMMWORD PTR [rsi-0x40],zmm0
    7b39:	cmp    rsi,r15
    7b3c:	jne    7b20 <bench_ada__run_14.isra.0+0x250>
    7b3e:	mov    ecx,DWORD PTR [rsp+0x68]
    7b42:	lea    esi,[rcx*8+0x0]
    7b49:	cmp    esi,DWORD PTR [rsp+0x78]
    7b4d:	je     7ac0 <bench_ada__run_14.isra.0+0x1f0>
    7b53:	lea    r10d,[rsi-0x1]
    7b57:	mov    r11d,DWORD PTR [rsp+0x78]
    7b5c:	sub    r11d,esi
    7b5f:	lea    r14d,[r11-0x1]
    7b63:	cmp    r14d,0x2
    7b67:	jbe    7b9e <bench_ada__run_14.isra.0+0x2ce>
    7b69:	lea    r14,[r9+rsi*1]
    7b6d:	lea    rcx,[rdi+r14*8]
    7b71:	mov    r14,QWORD PTR [rsp+0x70]
    7b76:	imul   r14,rdx
    7b7a:	add    rsi,r14
    7b7d:	vmulpd ymm2,ymm2,YMMWORD PTR [r12+rsi*8]
    7b83:	mov    esi,r11d
    7b86:	and    esi,0xfffffffc
    7b89:	and    r11d,0x3
    7b8d:	vaddpd ymm2,ymm2,YMMWORD PTR [rcx]
    7b91:	vmovupd YMMWORD PTR [rcx],ymm2
    7b95:	je     7ac0 <bench_ada__run_14.isra.0+0x1f0>
    7b9b:	add    r10d,esi
    7b9e:	imul   rdx,QWORD PTR [rsp+0x70]
    7ba4:	lea    esi,[r10+0x1]
    7ba8:	mov    ecx,DWORD PTR [rsp+0x6c]
    7bac:	lea    r14,[r9+rsi*1]
    7bb0:	mov    r11,rsi
    7bb3:	add    rsi,rdx
    7bb6:	vmulsd xmm0,xmm1,QWORD PTR [r12+rsi*8]
    7bbc:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    7bc2:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    7bc8:	cmp    ecx,r11d
    7bcb:	je     7ac0 <bench_ada__run_14.isra.0+0x1f0>
    7bd1:	lea    esi,[r10+0x2]
    7bd5:	lea    r14,[r9+rsi*1]
    7bd9:	mov    r11,rsi
    7bdc:	add    rsi,rdx
    7bdf:	vmulsd xmm0,xmm1,QWORD PTR [r12+rsi*8]
    7be5:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    7beb:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    7bf1:	cmp    ecx,r11d
    7bf4:	je     7ac0 <bench_ada__run_14.isra.0+0x1f0>
    7bfa:	lea    esi,[r10+0x3]
    7bfe:	lea    r10,[r9+rsi*1]
    7c02:	add    rsi,rdx
    7c05:	vmulsd xmm1,xmm1,QWORD PTR [r12+rsi*8]
    7c0b:	vaddsd xmm1,xmm1,QWORD PTR [rdi+r10*8]
    7c11:	vmovsd QWORD PTR [rdi+r10*8],xmm1
    7c17:	cmp    rax,r13
    7c1a:	jne    7ac9 <bench_ada__run_14.isra.0+0x1f9>
    7c20:	mov    r9,QWORD PTR [rsp+0x50]
    7c25:	cmp    r9,QWORD PTR [rsp+0x38]
    7c2a:	jne    7a40 <bench_ada__run_14.isra.0+0x170>
    7c30:	mov    rax,QWORD PTR [rbp+0x10]
    7c34:	mov    rdx,QWORD PTR [rbp+0x18]
    7c38:	mov    rcx,QWORD PTR [rbp+0x20]
    7c3c:	mov    rsi,QWORD PTR [rbp+0x30]
    7c40:	mov    eax,DWORD PTR [rsp+0x28]
    7c44:	cmp    DWORD PTR [rsp+0x14],eax
    7c48:	je     7c7d <bench_ada__run_14.isra.0+0x3ad>
    7c4a:	inc    eax
    7c4c:	mov    rdx,QWORD PTR [rbp+0x18]
    7c50:	mov    rcx,QWORD PTR [rbp+0x20]
    7c54:	mov    rsi,QWORD PTR [rbp+0x30]
    7c58:	mov    DWORD PTR [rsp+0x28],eax
    7c5c:	mov    rax,QWORD PTR [rbp+0x10]
    7c60:	vzeroupper
    7c63:	jmp    798e <bench_ada__run_14.isra.0+0xbe>
    7c68:	nop    DWORD PTR [rax+rax*1+0x0]
    7c70:	xor    esi,esi
    7c72:	mov    r10d,0xffffffff
    7c78:	jmp    7b57 <bench_ada__run_14.isra.0+0x287>
    7c7d:	vzeroupper
    7c80:	jmp    79f6 <bench_ada__run_14.isra.0+0x126>
    7c85:	nop
    7c86:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_15.isra.0>:
    7c90:	push   rbp
    7c91:	mov    eax,edi
    7c93:	mov    rbp,rsp
    7c96:	push   r15
    7c98:	push   r14
    7c9a:	push   r13
    7c9c:	push   r12
    7c9e:	push   rbx
    7c9f:	and    rsp,0xffffffffffffffc0
    7ca3:	add    rsp,0xffffffffffffff80
    7ca7:	mov    rdi,QWORD PTR [rbp+0x28]
    7cab:	test   ecx,ecx
    7cad:	je     7fa8 <bench_ada__run_15.isra.0+0x318>
    7cb3:	mov    DWORD PTR [rsp+0x34],eax
    7cb7:	mov    eax,edx
    7cb9:	mov    DWORD PTR [rsp+0x30],ecx
    7cbd:	mov    ecx,esi
    7cbf:	lea    rsi,[rax*8+0x0]
    7cc7:	mov    DWORD PTR [rsp+0x78],edx
    7ccb:	mov    eax,ecx
    7ccd:	mov    r12,r9
    7cd0:	lea    r9d,[rdx-0x1]
    7cd4:	mov    rdx,rsi
    7cd7:	mov    QWORD PTR [rsp+0x60],rsi
    7cdc:	mov    QWORD PTR [rsp+0x18],rax
    7ce1:	mov    DWORD PTR [rsp+0x2c],ecx
    7ce5:	mov    rbx,r8
    7ce8:	mov    r14d,r9d
    7ceb:	xor    r8d,r8d
    7cee:	imul   rdx,rax
    7cf2:	shr    rsi,0x3
    7cf6:	mov    QWORD PTR [rsp+0x38],rdx
    7cfb:	lea    rdx,[rax*8+0x0]
    7d03:	mov    QWORD PTR [rsp+0x68],rsi
    7d08:	mov    QWORD PTR [rsp+0x20],rdx
    7d0d:	nop    DWORD PTR [rax]
    7d10:	inc    r8d
    7d13:	mov    rax,QWORD PTR [rbp+0x10]
    7d17:	mov    rsi,QWORD PTR [rbp+0x18]
    7d1b:	mov    rdx,QWORD PTR [rbp+0x20]
    7d1f:	mov    DWORD PTR [rsp+0x7c],r8d
    7d24:	mov    rcx,QWORD PTR [rbp+0x30]
    7d28:	mov    rdx,QWORD PTR [rsp+0x38]
    7d2d:	xor    esi,esi
    7d2f:	call   2bd0 <memset@plt>
    7d34:	mov    r8d,DWORD PTR [rsp+0x7c]
    7d39:	mov    rdi,rax
    7d3c:	mov    eax,DWORD PTR [rsp+0x34]
    7d40:	test   eax,eax
    7d42:	je     7f8d <bench_ada__run_15.isra.0+0x2fd>
    7d48:	mov    edx,DWORD PTR [rsp+0x2c]
    7d4c:	test   edx,edx
    7d4e:	je     7f8d <bench_ada__run_15.isra.0+0x2fd>
    7d54:	lea    r15,[rax-0x1]
    7d58:	mov    rax,QWORD PTR [rsp+0x20]
    7d5d:	mov    r10d,DWORD PTR [rsp+0x78]
    7d62:	mov    r9d,r8d
    7d65:	mov    rcx,0xffffffffffffffff
    7d6c:	vxorpd xmm4,xmm4,xmm4
    7d70:	mov    r8,r15
    7d73:	shr    rax,0x3
    7d77:	mov    QWORD PTR [rsp+0x70],rax
    7d7c:	mov    rax,QWORD PTR [rsp+0x18]
    7d81:	and    r10d,0xfffffff8
    7d85:	lea    rsi,[rax-0x1]
    7d89:	mov    eax,DWORD PTR [rsp+0x78]
    7d8d:	shr    eax,0x3
    7d90:	shl    rax,0x6
    7d94:	mov    QWORD PTR [rsp+0x50],rax
    7d99:	nop    DWORD PTR [rax+0x0]
    7da0:	mov    rdx,QWORD PTR [rsp+0x60]
    7da5:	inc    rcx
    7da8:	mov    r15,QWORD PTR [rsp+0x68]
    7dad:	mov    rax,0xffffffffffffffff
    7db4:	movsxd r13,ecx
    7db7:	imul   rdx,r13
    7dbb:	imul   r15,r13
    7dbf:	add    rdx,r12
    7dc2:	mov    QWORD PTR [rsp+0x58],rdx
    7dc7:	vmovq  xmm3,r15
    7dcc:	mov    r15d,r9d
    7dcf:	mov    r9,r13
    7dd2:	mov    r11,QWORD PTR [rsp+0x70]
    7dd7:	inc    rax
    7dda:	movsxd rdx,eax
    7ddd:	imul   r11,r9
    7de1:	lea    r13,[r11+rdx*1]
    7de5:	vmovsd xmm2,QWORD PTR [rbx+r13*8]
    7deb:	vcomisd xmm2,xmm4
    7def:	je     7f72 <bench_ada__run_15.isra.0+0x2e2>
    7df5:	cmp    r14d,0xffffffff
    7df9:	je     7fc0 <bench_ada__run_15.isra.0+0x330>
    7dff:	mov    DWORD PTR [rsp+0x7c],r15d
    7e04:	mov    QWORD PTR [rsp+0x48],rcx
    7e09:	mov    QWORD PTR [rsp+0x40],r8
    7e0e:	cmp    r14d,0x6
    7e12:	jbe    803e <bench_ada__run_15.isra.0+0x3ae>
    7e18:	mov    rcx,QWORD PTR [rsp+0x60]
    7e1d:	mov    r15,QWORD PTR [rsp+0x50]
    7e22:	mov    r11,QWORD PTR [rsp+0x58]
    7e27:	vbroadcastsd zmm1,xmm2
    7e2d:	imul   rcx,rdx
    7e31:	add    rcx,rdi
    7e34:	lea    r13,[r15+rcx*1]
    7e38:	mov    r15d,DWORD PTR [rsp+0x7c]
    7e3d:	sub    r11,rcx
    7e40:	vmulpd zmm0,zmm1,ZMMWORD PTR [rcx+r11*1]
    7e47:	add    rcx,0x40
    7e4b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rcx-0x40]
    7e52:	vmovupd ZMMWORD PTR [rcx-0x40],zmm0
    7e59:	cmp    rcx,r13
    7e5c:	jne    7e40 <bench_ada__run_15.isra.0+0x1b0>
    7e5e:	mov    DWORD PTR [rsp+0x7c],r15d
    7e63:	mov    r11d,r10d
    7e66:	cmp    r10d,DWORD PTR [rsp+0x78]
    7e6b:	je     8090 <bench_ada__run_15.isra.0+0x400>
    7e71:	lea    r13d,[r10-0x1]
    7e75:	mov    r8d,DWORD PTR [rsp+0x78]
    7e7a:	sub    r8d,r11d
    7e7d:	lea    ecx,[r8-0x1]
    7e81:	cmp    ecx,0x2
    7e84:	jbe    7ec2 <bench_ada__run_15.isra.0+0x232>
    7e86:	mov    rcx,QWORD PTR [rsp+0x68]
    7e8b:	vmovq  r15,xmm3
    7e90:	vbroadcastsd ymm0,xmm2
    7e95:	imul   rcx,rdx
    7e99:	add    rcx,r11
    7e9c:	add    r11,r15
    7e9f:	vmulpd ymm0,ymm0,YMMWORD PTR [r12+r11*8]
    7ea5:	vaddpd ymm0,ymm0,YMMWORD PTR [rdi+rcx*8]
    7eaa:	vmovupd YMMWORD PTR [rdi+rcx*8],ymm0
    7eaf:	mov    ecx,r8d
    7eb2:	and    ecx,0xfffffffc
    7eb5:	and    r8d,0x3
    7eb9:	je     8050 <bench_ada__run_15.isra.0+0x3c0>
    7ebf:	add    r13d,ecx
    7ec2:	imul   rdx,QWORD PTR [rsp+0x68]
    7ec8:	lea    ecx,[r13+0x1]
    7ecc:	vmovq  r15,xmm3
    7ed1:	mov    r8,rcx
    7ed4:	lea    r11,[rdx+rcx*1]
    7ed8:	add    rcx,r15
    7edb:	vmulsd xmm0,xmm2,QWORD PTR [r12+rcx*8]
    7ee1:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r11*8]
    7ee7:	vmovsd QWORD PTR [rdi+r11*8],xmm0
    7eed:	cmp    r14d,r8d
    7ef0:	je     7ff0 <bench_ada__run_15.isra.0+0x360>
    7ef6:	lea    ecx,[r13+0x2]
    7efa:	lea    r11,[rdx+rcx*1]
    7efe:	mov    r8,rcx
    7f01:	add    rcx,r15
    7f04:	vmulsd xmm0,xmm2,QWORD PTR [r12+rcx*8]
    7f0a:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r11*8]
    7f10:	vmovsd QWORD PTR [rdi+r11*8],xmm0
    7f16:	cmp    r14d,r8d
    7f19:	je     7ff0 <bench_ada__run_15.isra.0+0x360>
    7f1f:	lea    ecx,[r13+0x3]
    7f23:	add    rdx,rcx
    7f26:	add    rcx,r15
    7f29:	vmulsd xmm2,xmm2,QWORD PTR [r12+rcx*8]
    7f2f:	vaddsd xmm2,xmm2,QWORD PTR [rdi+rdx*8]
    7f34:	vmovsd QWORD PTR [rdi+rdx*8],xmm2
    7f39:	cmp    rax,rsi
    7f3c:	je     8060 <bench_ada__run_15.isra.0+0x3d0>
    7f42:	mov    rcx,QWORD PTR [rsp+0x70]
    7f47:	inc    rax
    7f4a:	movsxd rdx,eax
    7f4d:	imul   rcx,r9
    7f51:	add    rcx,rdx
    7f54:	vmovsd xmm2,QWORD PTR [rbx+rcx*8]
    7f59:	vcomisd xmm2,xmm4
    7f5d:	jne    7e0e <bench_ada__run_15.isra.0+0x17e>
    7f63:	mov    r15d,DWORD PTR [rsp+0x7c]
    7f68:	mov    rcx,QWORD PTR [rsp+0x48]
    7f6d:	mov    r8,QWORD PTR [rsp+0x40]
    7f72:	cmp    rsi,rax
    7f75:	jne    7dd2 <bench_ada__run_15.isra.0+0x142>
    7f7b:	mov    r9d,r15d
    7f7e:	cmp    rcx,r8
    7f81:	jne    7da0 <bench_ada__run_15.isra.0+0x110>
    7f87:	mov    r8d,r9d
    7f8a:	vzeroupper
    7f8d:	mov    rax,QWORD PTR [rbp+0x10]
    7f91:	mov    rsi,QWORD PTR [rbp+0x18]
    7f95:	mov    rdx,QWORD PTR [rbp+0x20]
    7f99:	mov    rcx,QWORD PTR [rbp+0x30]
    7f9d:	cmp    DWORD PTR [rsp+0x30],r8d
    7fa2:	jne    7d10 <bench_ada__run_15.isra.0+0x80>
    7fa8:	lea    rsp,[rbp-0x28]
    7fac:	pop    rbx
    7fad:	pop    r12
    7faf:	pop    r13
    7fb1:	pop    r14
    7fb3:	pop    r15
    7fb5:	pop    rbp
    7fb6:	ret
    7fb7:	nop    WORD PTR [rax+rax*1+0x0]
    7fc0:	cmp    rsi,rax
    7fc3:	je     7f7b <bench_ada__run_15.isra.0+0x2eb>
    7fc5:	lea    rdx,[rax+0x1]
    7fc9:	cmp    rdx,rsi
    7fcc:	je     7f7b <bench_ada__run_15.isra.0+0x2eb>
    7fce:	add    rax,0x2
    7fd2:	movsxd rdx,eax
    7fd5:	add    rdx,r11
    7fd8:	vcomisd xmm4,QWORD PTR [rbx+rdx*8]
    7fdd:	jne    7fc0 <bench_ada__run_15.isra.0+0x330>
    7fdf:	jmp    7f72 <bench_ada__run_15.isra.0+0x2e2>
    7fe1:	nop    DWORD PTR [rax+0x0]
    7fe5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7ff0:	cmp    rax,rsi
    7ff3:	je     8060 <bench_ada__run_15.isra.0+0x3d0>
    7ff5:	mov    r11,QWORD PTR [rsp+0x70]
    7ffa:	lea    rcx,[rax+0x1]
    7ffe:	movsxd rdx,ecx
    8001:	imul   r11,r9
    8005:	lea    r13,[r11+rdx*1]
    8009:	vmovsd xmm2,QWORD PTR [rbx+r13*8]
    800f:	vcomisd xmm2,xmm4
    8013:	jne    8080 <bench_ada__run_15.isra.0+0x3f0>
    8015:	cmp    rsi,rcx
    8018:	je     8060 <bench_ada__run_15.isra.0+0x3d0>
    801a:	add    rax,0x2
    801e:	movsxd rdx,eax
    8021:	add    r11,rdx
    8024:	vmovsd xmm2,QWORD PTR [rbx+r11*8]
    802a:	vcomisd xmm2,xmm4
    802e:	je     7f63 <bench_ada__run_15.isra.0+0x2d3>
    8034:	cmp    r14d,0x6
    8038:	ja     7e18 <bench_ada__run_15.isra.0+0x188>
    803e:	xor    r11d,r11d
    8041:	mov    r13d,0xffffffff
    8047:	jmp    7e75 <bench_ada__run_15.isra.0+0x1e5>
    804c:	nop    DWORD PTR [rax+0x0]
    8050:	cmp    rax,rsi
    8053:	jne    7f42 <bench_ada__run_15.isra.0+0x2b2>
    8059:	nop    DWORD PTR [rax+0x0]
    8060:	mov    r9d,DWORD PTR [rsp+0x7c]
    8065:	mov    rcx,QWORD PTR [rsp+0x48]
    806a:	mov    r8,QWORD PTR [rsp+0x40]
    806f:	jmp    7f7e <bench_ada__run_15.isra.0+0x2ee>
    8074:	nop
    8075:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8080:	mov    rax,rcx
    8083:	jmp    7e0e <bench_ada__run_15.isra.0+0x17e>
    8088:	nop    DWORD PTR [rax+rax*1+0x0]
    8090:	cmp    rax,rsi
    8093:	je     8060 <bench_ada__run_15.isra.0+0x3d0>
    8095:	mov    rcx,QWORD PTR [rsp+0x70]
    809a:	inc    rax
    809d:	movsxd rdx,eax
    80a0:	imul   rcx,r9
    80a4:	add    rcx,rdx
    80a7:	vmovsd xmm2,QWORD PTR [rbx+rcx*8]
    80ac:	vcomisd xmm2,xmm4
    80b0:	jne    7e0e <bench_ada__run_15.isra.0+0x17e>
    80b6:	mov    rcx,QWORD PTR [rsp+0x48]
    80bb:	mov    r8,QWORD PTR [rsp+0x40]
    80c0:	jmp    7f72 <bench_ada__run_15.isra.0+0x2e2>
    80c5:	nop
    80c6:	cs nop WORD PTR [rax+rax*1+0x0]


<bench_ada__run_16.isra.0>:
    5600:	push   rbp
    5601:	mov    eax,edi
    5603:	mov    r10d,esi
    5606:	mov    r11d,edx
    5609:	mov    rbp,rsp
    560c:	push   r15
    560e:	push   r14
    5610:	push   r13
    5612:	push   r12
    5614:	push   rbx
    5615:	and    rsp,0xffffffffffffffe0
    5619:	sub    rsp,0x60
    561d:	mov    rdi,QWORD PTR [rbp+0x18]
    5621:	mov    rsi,QWORD PTR [rbp+0x20]
    5625:	mov    r15,QWORD PTR [rbp+0x28]
    5629:	mov    rdx,QWORD PTR [rbp+0x30]
    562d:	test   ecx,ecx
    562f:	je     5861 <bench_ada__run_16.isra.0+0x261>
    5635:	mov    r14,QWORD PTR [rbp+0x10]
    5639:	mov    r12,r8
    563c:	mov    rbx,r9
    563f:	test   r11d,r11d
    5642:	je     5917 <bench_ada__run_16.isra.0+0x317>
    5648:	lea    r14d,[rax-0x1]
    564c:	mov    DWORD PTR [rsp+0x34],ecx
    5650:	mov    ecx,r11d
    5653:	mov    DWORD PTR [rsp+0x5c],r10d
    5658:	mov    DWORD PTR [rsp+0x58],r14d
    565d:	lea    r14d,[r10-0x1]
    5661:	mov    DWORD PTR [rsp+0x24],eax
    5665:	mov    QWORD PTR [rsp+0x28],rcx
    566a:	mov    DWORD PTR [rsp+0x4c],r14d
    566f:	mov    DWORD PTR [rsp+0x48],0x1
    5677:	mov    QWORD PTR [rbp+0x18],rdi
    567b:	mov    r13d,eax
    567e:	mov    rdi,rsi
    5681:	mov    rsi,rdx
    5684:	mov    rdx,r15
    5687:	lea    r15,[rcx*8+0x0]
    568f:	mov    eax,DWORD PTR [rsp+0x58]
    5693:	cmp    eax,0xffffffff
    5696:	je     58e2 <bench_ada__run_16.isra.0+0x2e2>
    569c:	mov    rax,rsi
    569f:	mov    esi,DWORD PTR [rsp+0x4c]
    56a3:	cmp    esi,0xffffffff
    56a6:	je     5870 <bench_ada__run_16.isra.0+0x270>
    56ac:	mov    esi,DWORD PTR [rsp+0x5c]
    56b0:	cmp    esi,0x3
    56b3:	je     5d11 <bench_ada__run_16.isra.0+0x711>
    56b9:	jg     5785 <bench_ada__run_16.isra.0+0x185>
    56bf:	dec    esi
    56c1:	je     5c57 <bench_ada__run_16.isra.0+0x657>
    56c7:	mov    r14d,DWORD PTR [rsp+0x24]
    56cc:	mov    rsi,rax
    56cf:	mov    rax,QWORD PTR [rsp+0x28]
    56d4:	mov    r10,rdx
    56d7:	mov    r11,0xffffffffffffffff
    56de:	vxorpd xmm2,xmm2,xmm2
    56e2:	dec    r14
    56e5:	lea    r9,[rax-0x1]
    56e9:	nop    DWORD PTR [rax+0x0]
    56f0:	inc    r11
    56f3:	mov    rcx,0xffffffffffffffff
    56fa:	movsxd r8,r11d
    56fd:	shl    r8,0x4
    5701:	add    r8,r12
    5704:	nop    DWORD PTR [rax+rax*1+0x0]
    5709:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5714:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    571f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    572a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5735:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5740:	inc    rcx
    5743:	movsxd rax,ecx
    5746:	shl    rax,0x4
    574a:	add    rax,rbx
    574d:	vmovsd xmm0,QWORD PTR [rax]
    5751:	vmulsd xmm0,xmm0,QWORD PTR [r8]
    5756:	vmovsd xmm1,QWORD PTR [rax+0x8]
    575b:	vmulsd xmm1,xmm1,QWORD PTR [r8+0x8]
    5761:	vaddsd xmm0,xmm0,xmm1
    5765:	vaddsd xmm0,xmm0,xmm2
    5769:	vmovsd QWORD PTR [r10+rcx*8],xmm0
    576f:	cmp    rcx,r9
    5772:	jne    5740 <bench_ada__run_16.isra.0+0x140>
    5774:	add    r10,r15
    5777:	cmp    r11,r14
    577a:	jne    56f0 <bench_ada__run_16.isra.0+0xf0>
    5780:	jmp    584c <bench_ada__run_16.isra.0+0x24c>
    5785:	cmp    DWORD PTR [rsp+0x5c],0x4
    578a:	jne    593a <bench_ada__run_16.isra.0+0x33a>
    5790:	mov    rsi,rax
    5793:	mov    rax,QWORD PTR [rsp+0x28]
    5798:	mov    r14d,DWORD PTR [rsp+0x24]
    579d:	mov    r10,rdx
    57a0:	xor    r11d,r11d
    57a3:	lea    r9,[rax-0x1]
    57a7:	nop    WORD PTR [rax+rax*1+0x0]
    57b0:	movsxd r8,r11d
    57b3:	mov    rax,0xffffffffffffffff
    57ba:	shl    r8,0x5
    57be:	add    r8,r12
    57c1:	nop    DWORD PTR [rax+rax*1+0x0]
    57c9:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    57d4:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    57df:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    57ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    57f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5800:	inc    rax
    5803:	vmovupd ymm0,YMMWORD PTR [r8]
    5808:	movsxd rcx,eax
    580b:	shl    rcx,0x5
    580f:	vmulpd ymm0,ymm0,YMMWORD PTR [rcx+rbx*1]
    5814:	vextractf64x2 xmm2,ymm0,0x1
    581b:	vunpckhpd xmm1,xmm0,xmm0
    581f:	vaddsd xmm2,xmm2,xmm0
    5823:	valignq ymm0,ymm0,ymm0,0x3
    582a:	vaddsd xmm1,xmm1,xmm0
    582e:	vaddsd xmm1,xmm2,xmm1
    5832:	vmovsd QWORD PTR [r10+rax*8],xmm1
    5838:	cmp    rax,r9
    583b:	jne    5800 <bench_ada__run_16.isra.0+0x200>
    583d:	inc    r11
    5840:	add    r10,r15
    5843:	cmp    r14,r11
    5846:	jne    57b0 <bench_ada__run_16.isra.0+0x1b0>
    584c:	mov    rax,QWORD PTR [rbp+0x10]
    5850:	mov    rcx,QWORD PTR [rbp+0x18]
    5854:	mov    eax,DWORD PTR [rsp+0x48]
    5858:	cmp    DWORD PTR [rsp+0x34],eax
    585c:	jne    58cf <bench_ada__run_16.isra.0+0x2cf>
    585e:	vzeroupper
    5861:	lea    rsp,[rbp-0x28]
    5865:	pop    rbx
    5866:	pop    r12
    5868:	pop    r13
    586a:	pop    r14
    586c:	pop    r15
    586e:	pop    rbp
    586f:	ret
    5870:	mov    QWORD PTR [rsp+0x50],r12
    5875:	mov    QWORD PTR [rsp+0x40],rbx
    587a:	mov    QWORD PTR [rbp+0x20],rdi
    587e:	xor    ebx,ebx
    5880:	mov    rcx,rdx
    5883:	mov    r12,rdx
    5886:	mov    r14,rax
    5889:	vzeroupper
    588c:	nop    DWORD PTR [rax+0x0]
    5890:	mov    rdi,rcx
    5893:	mov    rdx,r15
    5896:	xor    esi,esi
    5898:	inc    rbx
    589b:	call   2bd0 <memset@plt>
    58a0:	lea    rcx,[rax+r15*1]
    58a4:	cmp    rbx,r13
    58a7:	jne    5890 <bench_ada__run_16.isra.0+0x290>
    58a9:	mov    rdx,r12
    58ac:	mov    rbx,QWORD PTR [rsp+0x40]
    58b1:	mov    rdi,QWORD PTR [rbp+0x20]
    58b5:	mov    r12,QWORD PTR [rsp+0x50]
    58ba:	mov    rax,QWORD PTR [rbp+0x10]
    58be:	mov    rcx,QWORD PTR [rbp+0x18]
    58c2:	mov    rsi,r14
    58c5:	mov    eax,DWORD PTR [rsp+0x48]
    58c9:	cmp    DWORD PTR [rsp+0x34],eax
    58cd:	je     5861 <bench_ada__run_16.isra.0+0x261>
    58cf:	inc    eax
    58d1:	mov    rcx,QWORD PTR [rbp+0x18]
    58d5:	mov    DWORD PTR [rsp+0x48],eax
    58d9:	mov    rax,QWORD PTR [rbp+0x10]
    58dd:	jmp    568f <bench_ada__run_16.isra.0+0x8f>
    58e2:	mov    r15,rdx
    58e5:	mov    ecx,DWORD PTR [rsp+0x48]
    58e9:	mov    rdx,rsi
    58ec:	mov    rax,QWORD PTR [rbp+0x10]
    58f0:	mov    rsi,rdi
    58f3:	mov    r8d,DWORD PTR [rsp+0x34]
    58f8:	mov    rdi,QWORD PTR [rbp+0x18]
    58fc:	cmp    r8d,ecx
    58ff:	je     585e <bench_ada__run_16.isra.0+0x25e>
    5905:	lea    r9d,[rcx+0x1]
    5909:	cmp    r8d,r9d
    590c:	je     585e <bench_ada__run_16.isra.0+0x25e>
    5912:	add    ecx,0x2
    5915:	jmp    58fc <bench_ada__run_16.isra.0+0x2fc>
    5917:	mov    r8,QWORD PTR [rbp+0x10]
    591b:	mov    eax,0x1
    5920:	cmp    ecx,eax
    5922:	je     5861 <bench_ada__run_16.isra.0+0x261>
    5928:	lea    r9d,[rax+0x1]
    592c:	cmp    ecx,r9d
    592f:	je     5861 <bench_ada__run_16.isra.0+0x261>
    5935:	add    eax,0x2
    5938:	jmp    5920 <bench_ada__run_16.isra.0+0x320>
    593a:	vmovd  xmm7,DWORD PTR [rsp+0x5c]
    5940:	vmovd  xmm14,DWORD PTR [rsp+0x58]
    5946:	mov    QWORD PTR [rsp+0x50],rdx
    594b:	mov    QWORD PTR [rbp+0x20],rdi
    594f:	vmovd  xmm5,DWORD PTR [rsp+0x4c]
    5955:	mov    QWORD PTR [rbp+0x28],rdx
    5959:	lea    r10,[r12+0x20]
    595e:	mov    QWORD PTR [rbp+0x30],rax
    5962:	vmovq  xmm18,r13
    5968:	mov    rax,0xffffffffffffffff
    596f:	vmovq  xmm17,r15
    5975:	vmovq  xmm4,r10
    597a:	vmovq  rsi,xmm7
    597f:	mov    r9d,esi
    5982:	sar    r9d,0x2
    5986:	and    esi,0x3
    5989:	dec    r9d
    598c:	mov    DWORD PTR [rsp+0x20],esi
    5990:	mov    rsi,QWORD PTR [rsp+0x28]
    5995:	mov    r14d,r9d
    5998:	sar    r14d,1
    599b:	lea    ecx,[r14-0x1]
    599f:	mov    DWORD PTR [rsp+0x30],r14d
    59a4:	sub    r14d,0x3
    59a8:	lea    r8,[rsi-0x1]
    59ac:	lea    esi,[r9*4+0x0]
    59b4:	or     r14d,0x1
    59b8:	mov    r13d,ecx
    59bb:	mov    QWORD PTR [rsp+0x40],r8
    59c0:	vmovq  xmm3,rsi
    59c5:	inc    rax
    59c8:	vmovq  rdx,xmm7
    59cd:	vmovq  rdi,xmm4
    59d2:	movsxd r10,eax
    59d5:	mov    QWORD PTR [rsp+0x18],rax
    59da:	mov    rax,0xffffffffffffffff
    59e1:	imul   r10,rdx
    59e5:	lea    r11,[r10*8+0x0]
    59ed:	mov    r15,r10
    59f0:	add    rdi,r11
    59f3:	lea    rsi,[r12+r11*1]
    59f7:	mov    QWORD PTR [rsp+0x38],rdi
    59fc:	vmovq  rdi,xmm3
    5a01:	add    rdi,r10
    5a04:	lea    rdi,[r12+rdi*8]
    5a08:	vmovq  xmm6,rdi
    5a0d:	vmovq  rdi,xmm5
    5a12:	add    rdi,r10
    5a15:	vmovq  xmm15,rdi
    5a1a:	nop    WORD PTR [rax+rax*1+0x0]
    5a20:	inc    rax
    5a23:	mov    r9,rdx
    5a26:	vmovupd ymm0,YMMWORD PTR [rsi]
    5a2a:	movsxd r8,eax
    5a2d:	imul   r9,r8
    5a31:	vmulpd ymm0,ymm0,YMMWORD PTR [rbx+r9*8]
    5a37:	cmp    r13d,0xffffffff
    5a3b:	je     5ba0 <bench_ada__run_16.isra.0+0x5a0>
    5a41:	cmp    DWORD PTR [rsp+0x30],0x2
    5a46:	jle    5c4c <bench_ada__run_16.isra.0+0x64c>
    5a4c:	mov    rcx,QWORD PTR [rsp+0x38]
    5a51:	lea    rdi,[rbx+r9*8+0x20]
    5a56:	mov    r11d,0xffffffff
    5a5c:	vmovupd ymm2,YMMWORD PTR [rdi]
    5a60:	vmulpd ymm2,ymm2,YMMWORD PTR [rcx]
    5a64:	vmovupd ymm1,YMMWORD PTR [rdi+0x20]
    5a69:	add    r11d,0x2
    5a6d:	vmulpd ymm1,ymm1,YMMWORD PTR [rcx+0x20]
    5a72:	sub    rdi,0xffffffffffffff80
    5a76:	sub    rcx,0xffffffffffffff80
    5a7a:	vaddpd ymm0,ymm2,ymm0
    5a7e:	vaddpd ymm1,ymm1,ymm0
    5a82:	vmovupd ymm0,YMMWORD PTR [rdi-0x40]
    5a87:	vmulpd ymm0,ymm0,YMMWORD PTR [rcx-0x40]
    5a8c:	vaddpd ymm1,ymm1,ymm0
    5a90:	vmovupd ymm0,YMMWORD PTR [rdi-0x20]
    5a95:	vmulpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    5a9a:	vaddpd ymm0,ymm1,ymm0
    5a9e:	cmp    r11d,r14d
    5aa1:	jne    5a5c <bench_ada__run_16.isra.0+0x45c>
    5aa3:	movsxd rcx,r11d
    5aa6:	inc    r11d
    5aa9:	shl    rcx,0x3
    5aad:	lea    rdi,[r9+rcx*1+0xc]
    5ab2:	lea    r10,[r15+rcx*1+0xc]
    5ab7:	vmovupd ymm1,YMMWORD PTR [r12+r10*8]
    5abd:	vmulpd ymm1,ymm1,YMMWORD PTR [rbx+rdi*8]
    5ac2:	vmovupd ymm10,YMMWORD PTR [r12+r10*8+0x20]
    5ac9:	vmulpd ymm10,ymm10,YMMWORD PTR [rbx+rdi*8+0x20]
    5acf:	vaddpd ymm0,ymm1,ymm0
    5ad3:	vaddpd ymm0,ymm10,ymm0
    5ad7:	cmp    r11d,r13d
    5ada:	je     5b06 <bench_ada__run_16.isra.0+0x506>
    5adc:	lea    rdi,[r9+rcx*1+0x14]
    5ae1:	lea    rcx,[r15+rcx*1+0x14]
    5ae6:	vmovupd ymm1,YMMWORD PTR [rbx+rdi*8]
    5aeb:	vmulpd ymm1,ymm1,YMMWORD PTR [r12+rcx*8]
    5af1:	vaddpd ymm1,ymm1,ymm0
    5af5:	vmovupd ymm0,YMMWORD PTR [rbx+rdi*8+0x20]
    5afb:	vmulpd ymm0,ymm0,YMMWORD PTR [r12+rcx*8+0x20]
    5b02:	vaddpd ymm0,ymm0,ymm1
    5b06:	test   BYTE PTR [rsp+0x5c],0x4
    5b0b:	jne    5b29 <bench_ada__run_16.isra.0+0x529>
    5b0d:	vmovq  rdi,xmm3
    5b12:	add    r9,rdi
    5b15:	vmovq  rdi,xmm6
    5b1a:	vmovupd ymm10,YMMWORD PTR [rdi]
    5b1e:	vmulpd ymm10,ymm10,YMMWORD PTR [rbx+r9*8]
    5b24:	vaddpd ymm0,ymm0,ymm10
    5b29:	cmp    DWORD PTR [rsp+0x20],0x0
    5b2e:	jne    5bab <bench_ada__run_16.isra.0+0x5ab>
    5b30:	vunpckhpd xmm11,xmm0,xmm0
    5b34:	vextractf64x2 xmm12,ymm0,0x1
    5b3b:	vaddsd xmm10,xmm0,xmm12
    5b40:	valignq ymm0,ymm0,ymm0,0x3
    5b47:	vaddsd xmm11,xmm11,xmm0
    5b4b:	vaddsd xmm0,xmm10,xmm11
    5b50:	mov    rdi,QWORD PTR [rsp+0x50]
    5b55:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    5b5a:	cmp    QWORD PTR [rsp+0x40],rax
    5b5f:	jne    5a20 <bench_ada__run_16.isra.0+0x420>
    5b65:	mov    rax,QWORD PTR [rsp+0x18]
    5b6a:	vmovq  rdx,xmm14
    5b6f:	vmovq  rdi,xmm17
    5b75:	add    QWORD PTR [rsp+0x50],rdi
    5b7a:	cmp    rax,rdx
    5b7d:	jne    59c5 <bench_ada__run_16.isra.0+0x3c5>
    5b83:	mov    rdi,QWORD PTR [rbp+0x20]
    5b87:	mov    rdx,QWORD PTR [rbp+0x28]
    5b8b:	mov    rax,QWORD PTR [rbp+0x30]
    5b8f:	vmovq  r15,xmm17
    5b95:	vmovq  r13,xmm18
    5b9b:	jmp    5ce8 <bench_ada__run_16.isra.0+0x6e8>
    5ba0:	cmp    DWORD PTR [rsp+0x5c],0x7
    5ba5:	jg     5b06 <bench_ada__run_16.isra.0+0x506>
    5bab:	imul   r8,rdx
    5baf:	vmovq  rdi,xmm5
    5bb4:	lea    rcx,[r8+rdi*1]
    5bb8:	vmovq  rdi,xmm15
    5bbd:	vmovsd xmm12,QWORD PTR [rbx+rcx*8]
    5bc2:	vmulsd xmm12,xmm12,QWORD PTR [r12+rdi*8]
    5bc8:	mov    edi,DWORD PTR [rsp+0x20]
    5bcc:	cmp    edi,0x2
    5bcf:	je     5da1 <bench_ada__run_16.isra.0+0x7a1>
    5bd5:	cmp    edi,0x3
    5bd8:	jne    5c22 <bench_ada__run_16.isra.0+0x622>
    5bda:	vmovq  rdi,xmm5
    5bdf:	vmovq  rcx,xmm5
    5be4:	lea    rdi,[r8+rdi*1-0x2]
    5be9:	lea    rcx,[r15+rcx*1-0x2]
    5bee:	vmovsd xmm10,QWORD PTR [rbx+rdi*8]
    5bf3:	vmovq  rdi,xmm5
    5bf8:	vmulsd xmm10,xmm10,QWORD PTR [r12+rcx*8]
    5bfe:	vmovq  rcx,xmm5
    5c03:	lea    rdi,[r8+rdi*1-0x1]
    5c08:	lea    rcx,[r15+rcx*1-0x1]
    5c0d:	vmovsd xmm11,QWORD PTR [rbx+rdi*8]
    5c12:	vmulsd xmm11,xmm11,QWORD PTR [r12+rcx*8]
    5c18:	vaddsd xmm10,xmm10,xmm11
    5c1d:	vaddsd xmm12,xmm12,xmm10
    5c22:	vextractf64x2 xmm13,ymm0,0x1
    5c29:	vunpckhpd xmm11,xmm0,xmm0
    5c2d:	vaddsd xmm10,xmm0,xmm13
    5c32:	valignq ymm0,ymm0,ymm0,0x3
    5c39:	vaddsd xmm11,xmm11,xmm0
    5c3d:	vaddsd xmm0,xmm10,xmm11
    5c42:	vaddsd xmm0,xmm0,xmm12
    5c47:	jmp    5b50 <bench_ada__run_16.isra.0+0x550>
    5c4c:	mov    r11d,0xffffffff
    5c52:	jmp    5aa3 <bench_ada__run_16.isra.0+0x4a3>
    5c57:	mov    r14d,DWORD PTR [rsp+0x24]
    5c5c:	mov    rsi,QWORD PTR [rsp+0x28]
    5c61:	mov    r9,rdx
    5c64:	mov    r11,0xffffffffffffffff
    5c6b:	vxorpd xmm1,xmm1,xmm1
    5c6f:	dec    r14
    5c72:	lea    r8,[rsi-0x1]
    5c76:	cs nop WORD PTR [rax+rax*1+0x0]
    5c80:	inc    r11
    5c83:	mov    rcx,0xffffffffffffffff
    5c8a:	movsxd r10,r11d
    5c8d:	nop    DWORD PTR [rax+0x0]
    5c94:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5c9f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5caa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5cb5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5cc0:	inc    rcx
    5cc3:	movsxd rsi,ecx
    5cc6:	vmovsd xmm0,QWORD PTR [rbx+rsi*8]
    5ccb:	vmulsd xmm0,xmm0,QWORD PTR [r12+r10*8]
    5cd1:	vaddsd xmm0,xmm0,xmm1
    5cd5:	vmovsd QWORD PTR [r9+rcx*8],xmm0
    5cdb:	cmp    rcx,r8
    5cde:	jne    5cc0 <bench_ada__run_16.isra.0+0x6c0>
    5ce0:	add    r9,r15
    5ce3:	cmp    r11,r14
    5ce6:	jne    5c80 <bench_ada__run_16.isra.0+0x680>
    5ce8:	mov    rsi,QWORD PTR [rbp+0x10]
    5cec:	mov    rcx,QWORD PTR [rbp+0x18]
    5cf0:	mov    esi,DWORD PTR [rsp+0x48]
    5cf4:	cmp    DWORD PTR [rsp+0x34],esi
    5cf8:	je     585e <bench_ada__run_16.isra.0+0x25e>
    5cfe:	inc    esi
    5d00:	mov    rcx,QWORD PTR [rbp+0x18]
    5d04:	mov    DWORD PTR [rsp+0x48],esi
    5d08:	mov    rsi,QWORD PTR [rbp+0x10]
    5d0c:	jmp    569f <bench_ada__run_16.isra.0+0x9f>
    5d11:	mov    r14d,DWORD PTR [rsp+0x24]
    5d16:	mov    rsi,QWORD PTR [rsp+0x28]
    5d1b:	mov    r10,rdx
    5d1e:	mov    r11,0xffffffffffffffff
    5d25:	vxorpd xmm2,xmm2,xmm2
    5d29:	dec    r14
    5d2c:	lea    r8,[rsi-0x1]
    5d30:	inc    r11
    5d33:	mov    rcx,0xffffffffffffffff
    5d3a:	movsxd rsi,r11d
    5d3d:	lea    rsi,[rsi+rsi*2]
    5d41:	lea    r9,[r12+rsi*8]
    5d45:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    5d50:	inc    rcx
    5d53:	movsxd rsi,ecx
    5d56:	lea    rsi,[rsi+rsi*2]
    5d5a:	lea    rsi,[rbx+rsi*8]
    5d5e:	vmovsd xmm0,QWORD PTR [rsi]
    5d62:	vmulsd xmm0,xmm0,QWORD PTR [r9]
    5d67:	vmovsd xmm1,QWORD PTR [rsi+0x8]
    5d6c:	vmulsd xmm1,xmm1,QWORD PTR [r9+0x8]
    5d72:	vaddsd xmm0,xmm0,xmm1
    5d76:	vmovsd xmm1,QWORD PTR [rsi+0x10]
    5d7b:	vmulsd xmm1,xmm1,QWORD PTR [r9+0x10]
    5d81:	vaddsd xmm0,xmm0,xmm1
    5d85:	vaddsd xmm0,xmm0,xmm2
    5d89:	vmovsd QWORD PTR [r10+rcx*8],xmm0
    5d8f:	cmp    rcx,r8
    5d92:	jne    5d50 <bench_ada__run_16.isra.0+0x750>
    5d94:	add    r10,r15
    5d97:	cmp    r11,r14
    5d9a:	jne    5d30 <bench_ada__run_16.isra.0+0x730>
    5d9c:	jmp    5ce8 <bench_ada__run_16.isra.0+0x6e8>
    5da1:	vmovq  rdi,xmm5
    5da6:	vmovq  rcx,xmm5
    5dab:	lea    rdi,[r8+rdi*1-0x1]
    5db0:	lea    rcx,[r15+rcx*1-0x1]
    5db5:	vmovsd xmm10,QWORD PTR [rbx+rdi*8]
    5dba:	vmulsd xmm10,xmm10,QWORD PTR [r12+rcx*8]
    5dc0:	vaddsd xmm12,xmm12,xmm10
    5dc5:	jmp    5c22 <bench_ada__run_16.isra.0+0x622>
    5dca:	nop    WORD PTR [rax+rax*1+0x0]


<bench_ada__run_17.isra.0>:
    80d0:	push   rbp
    80d1:	mov    rbp,rsp
    80d4:	push   r15
    80d6:	push   r14
    80d8:	push   r13
    80da:	push   r12
    80dc:	push   rbx
    80dd:	and    rsp,0xffffffffffffffc0
    80e1:	add    rsp,0xffffffffffffff80
    80e5:	mov    r10,QWORD PTR [rbp+0x20]
    80e9:	mov    QWORD PTR [rsp+0x58],r8
    80ee:	mov    QWORD PTR [rsp+0x50],r9
    80f3:	test   edx,edx
    80f5:	je     850a <bench_ada__run_17.isra.0+0x43a>
    80fb:	mov    DWORD PTR [rsp+0x34],edi
    80ff:	dec    edi
    8101:	mov    rbx,rcx
    8104:	mov    ecx,esi
    8106:	mov    DWORD PTR [rsp+0x40],edi
    810a:	lea    edi,[rsi-0x1]
    810d:	mov    DWORD PTR [rsp+0x44],edx
    8111:	lea    rdx,[rcx*8+0x0]
    8119:	mov    DWORD PTR [rsp+0x48],edi
    811d:	mov    rdi,rcx
    8120:	xor    eax,eax
    8122:	lea    r14,[rcx-0x1]
    8126:	imul   rdi,rdx
    812a:	test   esi,esi
    812c:	cmovne rax,rdx
    8130:	mov    r12,rax
    8133:	xor    eax,eax
    8135:	mov    QWORD PTR [rsp+0x38],rdi
    813a:	mov    DWORD PTR [rsp+0x4c],eax
    813e:	xchg   ax,ax
    8140:	inc    DWORD PTR [rsp+0x4c]
    8144:	mov    rax,QWORD PTR [rsp+0x58]
    8149:	mov    rdi,QWORD PTR [rsp+0x50]
    814e:	mov    rdx,QWORD PTR [rbp+0x10]
    8152:	mov    rsi,QWORD PTR [rbp+0x18]
    8156:	mov    rcx,QWORD PTR [rbp+0x28]
    815a:	mov    eax,DWORD PTR [rsp+0x48]
    815e:	cmp    eax,0xffffffff
    8161:	je     8568 <bench_ada__run_17.isra.0+0x498>
    8167:	mov    rdx,QWORD PTR [rsp+0x38]
    816c:	mov    rdi,r10
    816f:	xor    esi,esi
    8171:	call   2bd0 <memset@plt>
    8176:	vxorpd xmm6,xmm6,xmm6
    817a:	mov    r10,rax
    817d:	mov    eax,DWORD PTR [rsp+0x40]
    8181:	cmp    eax,0xffffffff
    8184:	je     8388 <bench_ada__run_17.isra.0+0x2b8>
    818a:	mov    eax,DWORD PTR [rsp+0x34]
    818e:	mov    QWORD PTR [rsp+0x70],r12
    8193:	mov    r8,0xffffffffffffffff
    819a:	vmovq  xmm3,r14
    819f:	lea    rcx,[rax-0x1]
    81a3:	mov    rax,r12
    81a6:	shr    rax,0x3
    81aa:	mov    QWORD PTR [rsp+0x60],rcx
    81af:	mov    QWORD PTR [rsp+0x78],rax
    81b4:	nop
    81b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    81c0:	mov    r15,QWORD PTR [rsp+0x70]
    81c5:	inc    r8
    81c8:	mov    r9d,0x1
    81ce:	movsxd rdx,r8d
    81d1:	imul   r15,rdx
    81d5:	lea    rax,[r15+rbx*1]
    81d9:	mov    r15,QWORD PTR [rsp+0x78]
    81de:	mov    QWORD PTR [rsp+0x68],rax
    81e3:	vmovq  rax,xmm3
    81e8:	imul   r15,rdx
    81ec:	mov    rdx,0xffffffffffffffff
    81f3:	mov    r12,r15
    81f6:	jmp    820c <bench_ada__run_17.isra.0+0x13c>
    81f8:	nop    DWORD PTR [rax+rax*1+0x0]
    8200:	inc    r9d
    8203:	cmp    rdx,rax
    8206:	je     8370 <bench_ada__run_17.isra.0+0x2a0>
    820c:	inc    rdx
    820f:	movsxd r15,edx
    8212:	mov    r14d,edx
    8215:	lea    rcx,[r12+r15*1]
    8219:	vmovsd xmm1,QWORD PTR [rbx+rcx*8]
    821e:	vbroadcastsd zmm2,xmm1
    8224:	test   edx,edx
    8226:	js     8200 <bench_ada__run_17.isra.0+0x130>
    8228:	vcomisd xmm1,xmm6
    822c:	je     8200 <bench_ada__run_17.isra.0+0x130>
    822e:	mov    r13d,edx
    8231:	cmp    edx,0x6
    8234:	jbe    8520 <bench_ada__run_17.isra.0+0x450>
    823a:	mov    rcx,QWORD PTR [rsp+0x70]
    823f:	mov    r11,QWORD PTR [rsp+0x68]
    8244:	mov    edi,r9d
    8247:	shr    edi,0x3
    824a:	vmovapd zmm4,zmm2
    8250:	mov    esi,edi
    8252:	imul   rcx,r15
    8256:	shl    rsi,0x6
    825a:	add    rcx,r10
    825d:	add    rsi,rcx
    8260:	sub    r11,rcx
    8263:	nop    DWORD PTR [rax+0x0]
    826a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8275:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8280:	vmulpd zmm0,zmm4,ZMMWORD PTR [rcx+r11*1]
    8287:	add    rcx,0x40
    828b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rcx-0x40]
    8292:	vmovupd ZMMWORD PTR [rcx-0x40],zmm0
    8299:	cmp    rsi,rcx
    829c:	jne    8280 <bench_ada__run_17.isra.0+0x1b0>
    829e:	shl    edi,0x3
    82a1:	cmp    r9d,edi
    82a4:	je     8200 <bench_ada__run_17.isra.0+0x130>
    82aa:	lea    ecx,[rdi-0x1]
    82ad:	sub    r13d,edi
    82b0:	cmp    r13d,0x2
    82b4:	jbe    82eb <bench_ada__run_17.isra.0+0x21b>
    82b6:	mov    rsi,QWORD PTR [rsp+0x78]
    82bb:	inc    r13d
    82be:	imul   rsi,r15
    82c2:	add    rsi,rdi
    82c5:	add    rdi,r12
    82c8:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+rdi*8]
    82cd:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+rsi*8]
    82d3:	vmovupd YMMWORD PTR [r10+rsi*8],ymm2
    82d9:	mov    esi,r13d
    82dc:	and    esi,0xfffffffc
    82df:	and    r13d,0x3
    82e3:	je     8200 <bench_ada__run_17.isra.0+0x130>
    82e9:	add    ecx,esi
    82eb:	mov    r11,QWORD PTR [rsp+0x78]
    82f0:	lea    esi,[rcx+0x1]
    82f3:	mov    rdi,rsi
    82f6:	imul   r11,r15
    82fa:	lea    r13,[r11+rsi*1]
    82fe:	add    rsi,r12
    8301:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    8306:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    830c:	vmovsd QWORD PTR [r10+r13*8],xmm0
    8312:	cmp    edi,r14d
    8315:	je     8200 <bench_ada__run_17.isra.0+0x130>
    831b:	lea    esi,[rcx+0x2]
    831e:	lea    r13,[r11+rsi*1]
    8322:	mov    rdi,rsi
    8325:	add    rsi,r12
    8328:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rsi*8]
    832d:	vaddsd xmm0,xmm0,QWORD PTR [r10+r13*8]
    8333:	vmovsd QWORD PTR [r10+r13*8],xmm0
    8339:	cmp    r14d,edi
    833c:	je     8200 <bench_ada__run_17.isra.0+0x130>
    8342:	add    ecx,0x3
    8345:	inc    r9d
    8348:	lea    r15,[r11+rcx*1]
    834c:	add    rcx,r12
    834f:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    8354:	vaddsd xmm1,xmm1,QWORD PTR [r10+r15*8]
    835a:	vmovsd QWORD PTR [r10+r15*8],xmm1
    8360:	cmp    rdx,rax
    8363:	jne    820c <bench_ada__run_17.isra.0+0x13c>
    8369:	nop    DWORD PTR [rax+0x0]
    8370:	cmp    r8,QWORD PTR [rsp+0x60]
    8375:	jne    81c0 <bench_ada__run_17.isra.0+0xf0>
    837b:	mov    r12,QWORD PTR [rsp+0x70]
    8380:	vmovq  r14,xmm3
    8385:	vzeroupper
    8388:	mov    eax,DWORD PTR [rsp+0x48]
    838c:	lea    r13,[r12+r12*1]
    8390:	mov    r11,r12
    8393:	shr    r11,0x3
    8397:	vmovq  xmm5,r13
    839c:	mov    QWORD PTR [rsp+0x70],rbx
    83a1:	mov    r8d,0x1
    83a7:	mov    rsi,0xffffffffffffffff
    83ae:	mov    QWORD PTR [rsp+0x78],rax
    83b3:	mov    r15,rax
    83b6:	jmp    83cc <bench_ada__run_17.isra.0+0x2fc>
    83b8:	nop    DWORD PTR [rax+rax*1+0x0]
    83c0:	inc    r8d
    83c3:	cmp    rsi,r14
    83c6:	je     84e1 <bench_ada__run_17.isra.0+0x411>
    83cc:	mov    rdx,rsi
    83cf:	inc    rsi
    83d2:	cmp    r15d,r8d
    83d5:	jl     83c0 <bench_ada__run_17.isra.0+0x2f0>
    83d7:	mov    rcx,QWORD PTR [rsp+0x78]
    83dc:	movsxd rax,r8d
    83df:	lea    r9,[rax-0x1]
    83e3:	sub    rcx,rax
    83e6:	cmp    rcx,0xe
    83ea:	jbe    852c <bench_ada__run_17.isra.0+0x45c>
    83f0:	imul   rax,r11
    83f4:	mov    rbx,rsi
    83f7:	imul   rbx,r11
    83fb:	add    rax,rdx
    83fe:	movsxd rdx,esi
    8401:	add    rdx,rbx
    8404:	shl    rdx,0x3
    8408:	lea    rbx,[r10+rdx*1]
    840c:	vmovq  xmm1,rbx
    8411:	lea    rbx,[rdx+r10*1+0x8]
    8416:	mov    r13,rbx
    8419:	mov    rbx,r12
    841c:	imul   rbx,rcx
    8420:	shl    rax,0x3
    8424:	lea    rdi,[r10+rax*1]
    8428:	lea    rbx,[rdi+rbx*1+0x8]
    842d:	cmp    rbx,r13
    8430:	jb     8449 <bench_ada__run_17.isra.0+0x379>
    8432:	vmovq  rbx,xmm1
    8437:	add    rdi,0x8
    843b:	lea    rbx,[rbx+rcx*8+0x8]
    8440:	cmp    rbx,rdi
    8443:	jae    852c <bench_ada__run_17.isra.0+0x45c>
    8449:	cmp    r15d,r8d
    844c:	je     84b2 <bench_ada__run_17.isra.0+0x3e2>
    844e:	lea    rbx,[rcx+0x1]
    8452:	dec    rcx
    8455:	lea    rax,[rax+r10*1+0x8]
    845a:	vmovq  r13,xmm5
    845f:	shr    rcx,1
    8462:	lea    rdi,[rcx+0x1]
    8466:	lea    rcx,[rdx+r10*1+0x8]
    846b:	xor    edx,edx
    846d:	nop    DWORD PTR [rax+rax*1+0x0]
    8475:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8480:	vmovsd xmm0,QWORD PTR [rax]
    8484:	vmovhpd xmm0,xmm0,QWORD PTR [r12+rax*1]
    848a:	inc    rdx
    848d:	add    rax,r13
    8490:	add    rcx,0x10
    8494:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    8499:	cmp    rdx,rdi
    849c:	jb     8480 <bench_ada__run_17.isra.0+0x3b0>
    849e:	add    rdi,rdi
    84a1:	vmovq  xmm5,r13
    84a6:	cmp    rbx,rdi
    84a9:	je     83c0 <bench_ada__run_17.isra.0+0x2f0>
    84af:	add    r9,rdi
    84b2:	inc    r9
    84b5:	mov    rax,r11
    84b8:	inc    r8d
    84bb:	imul   rax,r9
    84bf:	add    rax,rsi
    84c2:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    84c8:	mov    rax,rsi
    84cb:	imul   rax,r11
    84cf:	add    rax,r9
    84d2:	vmovsd QWORD PTR [r10+rax*8],xmm0
    84d8:	cmp    rsi,r14
    84db:	jne    83cc <bench_ada__run_17.isra.0+0x2fc>
    84e1:	mov    rbx,QWORD PTR [rsp+0x70]
    84e6:	mov    rax,QWORD PTR [rsp+0x58]
    84eb:	mov    rdi,QWORD PTR [rsp+0x50]
    84f0:	mov    rdx,QWORD PTR [rbp+0x10]
    84f4:	mov    rsi,QWORD PTR [rbp+0x18]
    84f8:	mov    rcx,QWORD PTR [rbp+0x28]
    84fc:	mov    edi,DWORD PTR [rsp+0x4c]
    8500:	cmp    DWORD PTR [rsp+0x44],edi
    8504:	jne    8140 <bench_ada__run_17.isra.0+0x70>
    850a:	lea    rsp,[rbp-0x28]
    850e:	pop    rbx
    850f:	pop    r12
    8511:	pop    r13
    8513:	pop    r14
    8515:	pop    r15
    8517:	pop    rbp
    8518:	ret
    8519:	nop    DWORD PTR [rax+0x0]
    8520:	xor    edi,edi
    8522:	mov    ecx,0xffffffff
    8527:	jmp    82ad <bench_ada__run_17.isra.0+0x1dd>
    852c:	mov    rdx,rsi
    852f:	vmovq  r13,xmm5
    8534:	imul   rdx,r12
    8538:	add    rdx,r10
    853b:	nop    DWORD PTR [rax+rax*1+0x0]
    8540:	inc    r9
    8543:	mov    rax,r11
    8546:	imul   rax,r9
    854a:	add    rax,rsi
    854d:	vmovsd xmm0,QWORD PTR [r10+rax*8]
    8553:	vmovsd QWORD PTR [rdx+r9*8],xmm0
    8559:	cmp    r9,r14
    855c:	jne    8540 <bench_ada__run_17.isra.0+0x470>
    855e:	vmovq  xmm5,r13
    8563:	jmp    83c0 <bench_ada__run_17.isra.0+0x2f0>
    8568:	mov    eax,DWORD PTR [rsp+0x40]
    856c:	mov    r9d,DWORD PTR [rsp+0x4c]
    8571:	mov    rdx,QWORD PTR [rsp+0x50]
    8576:	mov    rcx,QWORD PTR [rbp+0x10]
    857a:	mov    rsi,QWORD PTR [rbp+0x18]
    857e:	mov    rdi,QWORD PTR [rbp+0x28]
    8582:	mov    r8d,DWORD PTR [rsp+0x44]
    8587:	cmp    eax,0xffffffff
    858a:	mov    rax,QWORD PTR [rsp+0x58]
    858f:	jne    8596 <bench_ada__run_17.isra.0+0x4c6>
    8591:	jmp    85a0 <bench_ada__run_17.isra.0+0x4d0>
    8593:	inc    r9d
    8596:	cmp    r8d,r9d
    8599:	jne    8593 <bench_ada__run_17.isra.0+0x4c3>
    859b:	jmp    850a <bench_ada__run_17.isra.0+0x43a>
    85a0:	cmp    r8d,r9d
    85a3:	je     850a <bench_ada__run_17.isra.0+0x43a>
    85a9:	lea    r11d,[r9+0x1]
    85ad:	cmp    r8d,r11d
    85b0:	je     850a <bench_ada__run_17.isra.0+0x43a>
    85b6:	add    r9d,0x2
    85ba:	jmp    85a0 <bench_ada__run_17.isra.0+0x4d0>
    85bc:	nop    DWORD PTR [rax+0x0]


<bench_ada__run_18.isra.0>:
    85c0:	push   rbp
    85c1:	mov    eax,edi
    85c3:	mov    rbp,rsp
    85c6:	push   r15
    85c8:	push   r14
    85ca:	push   r13
    85cc:	push   r12
    85ce:	push   rbx
    85cf:	and    rsp,0xffffffffffffffc0
    85d3:	add    rsp,0xffffffffffffff80
    85d7:	mov    rdi,QWORD PTR [rbp+0x20]
    85db:	test   edx,edx
    85dd:	je     8a49 <bench_ada__run_18.isra.0+0x489>
    85e3:	mov    r12d,esi
    85e6:	test   esi,esi
    85e8:	lea    r15d,[rsi-0x1]
    85ec:	mov    DWORD PTR [rsp+0x2c],eax
    85f0:	setne  BYTE PTR [rsp+0x67]
    85f5:	lea    r13,[r12*8+0x0]
    85fd:	xor    eax,eax
    85ff:	cmp    r15d,0xffffffff
    8603:	cmove  r13,rax
    8607:	cmovne rax,r12
    860b:	mov    DWORD PTR [rsp+0x28],edx
    860f:	mov    DWORD PTR [rsp+0x24],r15d
    8614:	mov    QWORD PTR [rsp+0x40],r8
    8619:	mov    QWORD PTR [rsp+0x38],r9
    861e:	mov    rbx,rcx
    8621:	dec    r12
    8624:	imul   rax,r13
    8628:	mov    QWORD PTR [rsp+0x30],rax
    862d:	xor    eax,eax
    862f:	mov    DWORD PTR [rsp+0x60],eax
    8633:	mov    rax,r13
    8636:	shr    rax,0x3
    863a:	mov    QWORD PTR [rsp+0x78],rax
    863f:	nop
    8640:	inc    DWORD PTR [rsp+0x60]
    8644:	mov    rax,QWORD PTR [rsp+0x40]
    8649:	mov    rsi,QWORD PTR [rsp+0x38]
    864e:	mov    rcx,QWORD PTR [rbp+0x10]
    8652:	mov    rdx,QWORD PTR [rbp+0x18]
    8656:	mov    r10,QWORD PTR [rbp+0x28]
    865a:	mov    rdx,QWORD PTR [rsp+0x30]
    865f:	xor    esi,esi
    8661:	call   2bd0 <memset@plt>
    8666:	vxorpd xmm2,xmm2,xmm2
    866a:	mov    rdi,rax
    866d:	mov    eax,DWORD PTR [rsp+0x2c]
    8671:	test   eax,eax
    8673:	je     889a <bench_ada__run_18.isra.0+0x2da>
    8679:	mov    QWORD PTR [rsp+0x70],r13
    867e:	mov    QWORD PTR [rbp+0x20],rdi
    8682:	mov    r13,QWORD PTR [rbp+0x18]
    8686:	lea    rsi,[rax-0x1]
    868a:	mov    r8,0xffffffffffffffff
    8691:	jmp    86a9 <bench_ada__run_18.isra.0+0xe9>
    8693:	xchg   ax,ax
    8695:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    86a0:	cmp    r8,rsi
    86a3:	je     888e <bench_ada__run_18.isra.0+0x2ce>
    86a9:	inc    r8
    86ac:	movsxd rdi,r8d
    86af:	vcomisd xmm2,QWORD PTR [r13+rdi*8+0x0]
    86b6:	je     86a0 <bench_ada__run_18.isra.0+0xe0>
    86b8:	cmp    BYTE PTR [rsp+0x67],0x0
    86bd:	je     86a0 <bench_ada__run_18.isra.0+0xe0>
    86bf:	mov    rax,QWORD PTR [rsp+0x70]
    86c4:	mov    r14,QWORD PTR [rsp+0x78]
    86c9:	mov    QWORD PTR [rsp+0x50],r8
    86ce:	mov    QWORD PTR [rsp+0x48],rsi
    86d3:	mov    r8,rdi
    86d6:	mov    ecx,0x1
    86db:	mov    rdx,0xffffffffffffffff
    86e2:	imul   rax,rdi
    86e6:	imul   r14,rdi
    86ea:	mov    rdi,QWORD PTR [rbp+0x20]
    86ee:	add    rax,rbx
    86f1:	mov    QWORD PTR [rsp+0x58],rax
    86f6:	mov    r10,r14
    86f9:	nop    DWORD PTR [rax+0x0]
    8700:	inc    rdx
    8703:	movsxd r14,edx
    8706:	lea    rax,[r10+r14*1]
    870a:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    870f:	vcomisd xmm0,xmm2
    8713:	je     8870 <bench_ada__run_18.isra.0+0x2b0>
    8719:	vmovsd xmm1,QWORD PTR [r13+r8*8+0x0]
    8720:	vcomisd xmm1,xmm2
    8724:	je     8870 <bench_ada__run_18.isra.0+0x2b0>
    872a:	mov    esi,edx
    872c:	test   edx,edx
    872e:	js     8870 <bench_ada__run_18.isra.0+0x2b0>
    8734:	vmulsd xmm1,xmm0,xmm1
    8738:	mov    DWORD PTR [rsp+0x68],edx
    873c:	vbroadcastsd zmm6,xmm1
    8742:	cmp    edx,0x6
    8745:	jbe    8ab0 <bench_ada__run_18.isra.0+0x4f0>
    874b:	mov    r9,QWORD PTR [rsp+0x70]
    8750:	mov    r15,QWORD PTR [rsp+0x58]
    8755:	mov    r11d,ecx
    8758:	shr    r11d,0x3
    875c:	vmovapd zmm4,zmm6
    8762:	imul   r9,r14
    8766:	lea    rax,[r9+rdi*1]
    876a:	mov    r9d,r11d
    876d:	shl    r9,0x6
    8771:	sub    r15,rax
    8774:	add    r9,rax
    8777:	nop    WORD PTR [rax+rax*1+0x0]
    8780:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    8787:	add    rax,0x40
    878b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    8792:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    8799:	cmp    r9,rax
    879c:	jne    8780 <bench_ada__run_18.isra.0+0x1c0>
    879e:	shl    r11d,0x3
    87a2:	cmp    ecx,r11d
    87a5:	je     8870 <bench_ada__run_18.isra.0+0x2b0>
    87ab:	lea    r9d,[r11-0x1]
    87af:	mov    r15d,DWORD PTR [rsp+0x68]
    87b4:	sub    r15d,r11d
    87b7:	cmp    r15d,0x2
    87bb:	jbe    87f3 <bench_ada__run_18.isra.0+0x233>
    87bd:	mov    rax,QWORD PTR [rsp+0x78]
    87c2:	inc    r15d
    87c5:	imul   rax,r14
    87c9:	add    rax,r11
    87cc:	add    r11,r10
    87cf:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r11*8]
    87d5:	mov    r11d,r15d
    87d8:	and    r11d,0xfffffffc
    87dc:	and    r15d,0x3
    87e0:	vaddpd ymm6,ymm6,YMMWORD PTR [rdi+rax*8]
    87e5:	vmovupd YMMWORD PTR [rdi+rax*8],ymm6
    87ea:	je     8870 <bench_ada__run_18.isra.0+0x2b0>
    87f0:	add    r9d,r11d
    87f3:	mov    r15,QWORD PTR [rsp+0x78]
    87f8:	lea    r11d,[r9+0x1]
    87fc:	mov    DWORD PTR [rsp+0x68],r11d
    8801:	mov    rax,r15
    8804:	imul   r15,r8
    8808:	imul   rax,r14
    880c:	lea    r14,[rax+r11*1]
    8810:	add    r11,r15
    8813:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    8819:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    881f:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    8825:	cmp    DWORD PTR [rsp+0x68],esi
    8829:	je     8870 <bench_ada__run_18.isra.0+0x2b0>
    882b:	lea    r11d,[r9+0x2]
    882f:	lea    r14,[rax+r11*1]
    8833:	mov    DWORD PTR [rsp+0x68],r11d
    8838:	add    r11,r15
    883b:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r11*8]
    8841:	vaddsd xmm0,xmm0,QWORD PTR [rdi+r14*8]
    8847:	vmovsd QWORD PTR [rdi+r14*8],xmm0
    884d:	cmp    esi,DWORD PTR [rsp+0x68]
    8851:	je     8870 <bench_ada__run_18.isra.0+0x2b0>
    8853:	lea    esi,[r9+0x3]
    8857:	add    rax,rsi
    885a:	add    rsi,r15
    885d:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    8862:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rax*8]
    8867:	vmovsd QWORD PTR [rdi+rax*8],xmm1
    886c:	nop    DWORD PTR [rax+0x0]
    8870:	inc    ecx
    8872:	cmp    rdx,r12
    8875:	jne    8700 <bench_ada__run_18.isra.0+0x140>
    887b:	mov    r8,QWORD PTR [rsp+0x50]
    8880:	mov    rsi,QWORD PTR [rsp+0x48]
    8885:	cmp    r8,rsi
    8888:	jne    86a9 <bench_ada__run_18.isra.0+0xe9>
    888e:	mov    r13,QWORD PTR [rsp+0x70]
    8893:	mov    rdi,QWORD PTR [rbp+0x20]
    8897:	vzeroupper
    889a:	mov    eax,DWORD PTR [rsp+0x24]
    889e:	cmp    eax,0xffffffff
    88a1:	je     8a25 <bench_ada__run_18.isra.0+0x465>
    88a7:	mov    r14d,eax
    88aa:	mov    QWORD PTR [rsp+0x58],rbx
    88af:	mov    r11,QWORD PTR [rsp+0x78]
    88b4:	mov    r9d,0x1
    88ba:	mov    QWORD PTR [rsp+0x68],r14
    88bf:	mov    rsi,0xffffffffffffffff
    88c6:	lea    rbx,[r13+r13*1+0x0]
    88cb:	mov    r15d,eax
    88ce:	jmp    88ec <bench_ada__run_18.isra.0+0x32c>
    88d0:	nop    DWORD PTR [rax+rax*1+0x0]
    88d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    88e0:	inc    r9d
    88e3:	cmp    rsi,r12
    88e6:	je     8a20 <bench_ada__run_18.isra.0+0x460>
    88ec:	mov    rax,rsi
    88ef:	inc    rsi
    88f2:	cmp    r15d,r9d
    88f5:	jl     88e0 <bench_ada__run_18.isra.0+0x320>
    88f7:	mov    rcx,QWORD PTR [rsp+0x68]
    88fc:	movsxd rdx,r9d
    88ff:	lea    r10,[rdx-0x1]
    8903:	sub    rcx,rdx
    8906:	cmp    rcx,0xe
    890a:	jbe    8a60 <bench_ada__run_18.isra.0+0x4a0>
    8910:	imul   rdx,r11
    8914:	movsxd r14,esi
    8917:	add    rax,rdx
    891a:	mov    rdx,rsi
    891d:	imul   rdx,r11
    8921:	shl    rax,0x3
    8925:	add    rdx,r14
    8928:	lea    r8,[rdi+rax*1]
    892c:	shl    rdx,0x3
    8930:	lea    r14,[rdi+rdx*1]
    8934:	vmovq  xmm3,r14
    8939:	mov    r14,r13
    893c:	imul   r14,rcx
    8940:	lea    r14,[r8+r14*1+0x8]
    8945:	mov    QWORD PTR [rsp+0x70],r14
    894a:	lea    r14,[rdx+rdi*1+0x8]
    894f:	cmp    QWORD PTR [rsp+0x70],r14
    8954:	jb     896d <bench_ada__run_18.isra.0+0x3ad>
    8956:	vmovq  r14,xmm3
    895b:	add    r8,0x8
    895f:	lea    r14,[r14+rcx*8+0x8]
    8964:	cmp    r14,r8
    8967:	jae    8a60 <bench_ada__run_18.isra.0+0x4a0>
    896d:	cmp    r15d,r9d
    8970:	je     89ee <bench_ada__run_18.isra.0+0x42e>
    8972:	lea    r14,[rcx+0x1]
    8976:	dec    rcx
    8979:	lea    rax,[rax+rdi*1+0x8]
    897e:	shr    rcx,1
    8981:	lea    r8,[rcx+0x1]
    8985:	lea    rcx,[rdx+rdi*1+0x8]
    898a:	xor    edx,edx
    898c:	nop    DWORD PTR [rax+rax*1+0x0]
    8994:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    899f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    89aa:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    89b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    89c0:	vmovsd xmm0,QWORD PTR [rax]
    89c4:	vmovhpd xmm0,xmm0,QWORD PTR [r13+rax*1+0x0]
    89cb:	inc    rdx
    89ce:	add    rax,rbx
    89d1:	add    rcx,0x10
    89d5:	vmovupd XMMWORD PTR [rcx-0x10],xmm0
    89da:	cmp    rdx,r8
    89dd:	jb     89c0 <bench_ada__run_18.isra.0+0x400>
    89df:	add    r8,r8
    89e2:	cmp    r14,r8
    89e5:	je     88e0 <bench_ada__run_18.isra.0+0x320>
    89eb:	add    r10,r8
    89ee:	inc    r10
    89f1:	mov    rax,r11
    89f4:	inc    r9d
    89f7:	imul   rax,r10
    89fb:	add    rax,rsi
    89fe:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    8a03:	mov    rax,rsi
    8a06:	imul   rax,r11
    8a0a:	add    rax,r10
    8a0d:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    8a12:	cmp    rsi,r12
    8a15:	jne    88ec <bench_ada__run_18.isra.0+0x32c>
    8a1b:	nop    DWORD PTR [rax+rax*1+0x0]
    8a20:	mov    rbx,QWORD PTR [rsp+0x58]
    8a25:	mov    rax,QWORD PTR [rsp+0x40]
    8a2a:	mov    rsi,QWORD PTR [rsp+0x38]
    8a2f:	mov    rcx,QWORD PTR [rbp+0x10]
    8a33:	mov    rdx,QWORD PTR [rbp+0x18]
    8a37:	mov    r10,QWORD PTR [rbp+0x28]
    8a3b:	mov    esi,DWORD PTR [rsp+0x60]
    8a3f:	cmp    DWORD PTR [rsp+0x28],esi
    8a43:	jne    8640 <bench_ada__run_18.isra.0+0x80>
    8a49:	lea    rsp,[rbp-0x28]
    8a4d:	pop    rbx
    8a4e:	pop    r12
    8a50:	pop    r13
    8a52:	pop    r14
    8a54:	pop    r15
    8a56:	pop    rbp
    8a57:	ret
    8a58:	nop    DWORD PTR [rax+rax*1+0x0]
    8a60:	mov    rdx,r13
    8a63:	imul   rdx,rsi
    8a67:	add    rdx,rdi
    8a6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8a75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8a80:	inc    r10
    8a83:	mov    rax,r11
    8a86:	imul   rax,r10
    8a8a:	add    rax,rsi
    8a8d:	vmovsd xmm0,QWORD PTR [rdi+rax*8]
    8a92:	vmovsd QWORD PTR [rdx+r10*8],xmm0
    8a98:	cmp    r10,r12
    8a9b:	jne    8a80 <bench_ada__run_18.isra.0+0x4c0>
    8a9d:	jmp    88e0 <bench_ada__run_18.isra.0+0x320>
    8aa2:	nop    DWORD PTR [rax]
    8aa5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8ab0:	xor    r11d,r11d
    8ab3:	mov    r9d,0xffffffff
    8ab9:	jmp    87af <bench_ada__run_18.isra.0+0x1ef>
    8abe:	xchg   ax,ax


<bench_ada__run_19.isra.0>:
    8ac0:	push   rbp
    8ac1:	mov    rbp,rsp
    8ac4:	push   r15
    8ac6:	push   r14
    8ac8:	push   r13
    8aca:	push   r12
    8acc:	push   rbx
    8acd:	and    rsp,0xffffffffffffffc0
    8ad1:	add    rsp,0xffffffffffffff80
    8ad5:	mov    r12,QWORD PTR [rbp+0x18]
    8ad9:	test   edx,edx
    8adb:	je     8db3 <bench_ada__run_19.isra.0+0x2f3>
    8ae1:	mov    r13d,esi
    8ae4:	test   esi,esi
    8ae6:	mov    eax,0x0
    8aeb:	mov    DWORD PTR [rsp+0x38],edx
    8aef:	lea    rsi,[r13*8+0x0]
    8af7:	setne  r14b
    8afb:	mov    DWORD PTR [rsp+0x3c],edi
    8aff:	mov    QWORD PTR [rsp+0x48],r8
    8b04:	cmove  rsi,rax
    8b08:	mov    BYTE PTR [rsp+0x73],r14b
    8b0d:	mov    r14,r9
    8b10:	mov    r9,QWORD PTR [rbp+0x20]
    8b14:	cmovne rax,r13
    8b18:	mov    QWORD PTR [rsp+0x68],rsi
    8b1d:	mov    rbx,rcx
    8b20:	xor    r15d,r15d
    8b23:	imul   rax,rsi
    8b27:	dec    r13
    8b2a:	shr    rsi,0x3
    8b2e:	mov    QWORD PTR [rsp+0x40],rax
    8b33:	mov    QWORD PTR [rsp+0x78],rsi
    8b38:	nop    DWORD PTR [rax+rax*1+0x0]
    8b40:	mov    rax,QWORD PTR [rsp+0x48]
    8b45:	mov    rsi,QWORD PTR [rbp+0x10]
    8b49:	mov    rcx,QWORD PTR [rbp+0x28]
    8b4d:	inc    r15d
    8b50:	mov    rdx,QWORD PTR [rsp+0x40]
    8b55:	xor    esi,esi
    8b57:	mov    rdi,r9
    8b5a:	call   2bd0 <memset@plt>
    8b5f:	vxorpd xmm2,xmm2,xmm2
    8b63:	mov    r9,rax
    8b66:	mov    eax,DWORD PTR [rsp+0x3c]
    8b6a:	test   eax,eax
    8b6c:	je     8d9b <bench_ada__run_19.isra.0+0x2db>
    8b72:	mov    DWORD PTR [rsp+0x34],r15d
    8b77:	mov    QWORD PTR [rsp+0x28],r14
    8b7c:	mov    rdi,0xffffffffffffffff
    8b83:	lea    r11,[rax-0x1]
    8b87:	jmp    8ba9 <bench_ada__run_19.isra.0+0xe9>
    8b89:	nop
    8b8a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8b95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8ba0:	cmp    rdi,r11
    8ba3:	je     8d8e <bench_ada__run_19.isra.0+0x2ce>
    8ba9:	inc    rdi
    8bac:	movsxd r14,edi
    8baf:	vcomisd xmm2,QWORD PTR [r12+r14*8]
    8bb5:	je     8ba0 <bench_ada__run_19.isra.0+0xe0>
    8bb7:	cmp    BYTE PTR [rsp+0x73],0x0
    8bbc:	je     8ba0 <bench_ada__run_19.isra.0+0xe0>
    8bbe:	mov    rax,QWORD PTR [rsp+0x68]
    8bc3:	mov    r10,QWORD PTR [rsp+0x78]
    8bc8:	mov    QWORD PTR [rsp+0x58],rdi
    8bcd:	mov    QWORD PTR [rsp+0x50],r11
    8bd2:	mov    ecx,0x1
    8bd7:	mov    rdx,0xffffffffffffffff
    8bde:	mov    r11,r14
    8be1:	imul   rax,r14
    8be5:	imul   r10,r14
    8be9:	add    rax,rbx
    8bec:	mov    QWORD PTR [rsp+0x60],rax
    8bf1:	nop    DWORD PTR [rax+0x0]
    8bf5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8c00:	inc    rdx
    8c03:	movsxd r14,edx
    8c06:	lea    rax,[r10+r14*1]
    8c0a:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    8c0f:	vcomisd xmm0,xmm2
    8c13:	je     8d70 <bench_ada__run_19.isra.0+0x2b0>
    8c19:	vmovsd xmm1,QWORD PTR [r12+r11*8]
    8c1f:	vcomisd xmm1,xmm2
    8c23:	je     8d70 <bench_ada__run_19.isra.0+0x2b0>
    8c29:	mov    esi,edx
    8c2b:	test   edx,edx
    8c2d:	js     8d70 <bench_ada__run_19.isra.0+0x2b0>
    8c33:	vmulsd xmm1,xmm0,xmm1
    8c37:	mov    DWORD PTR [rsp+0x74],edx
    8c3b:	vbroadcastsd zmm6,xmm1
    8c41:	cmp    edx,0x6
    8c44:	jbe    8dd0 <bench_ada__run_19.isra.0+0x310>
    8c4a:	mov    rdi,QWORD PTR [rsp+0x68]
    8c4f:	mov    r15,QWORD PTR [rsp+0x60]
    8c54:	mov    r8d,ecx
    8c57:	shr    r8d,0x3
    8c5b:	vmovapd zmm4,zmm6
    8c61:	imul   rdi,r14
    8c65:	lea    rax,[rdi+r9*1]
    8c69:	mov    edi,r8d
    8c6c:	shl    rdi,0x6
    8c70:	sub    r15,rax
    8c73:	add    rdi,rax
    8c76:	cs nop WORD PTR [rax+rax*1+0x0]
    8c80:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    8c87:	add    rax,0x40
    8c8b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    8c92:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    8c99:	cmp    rax,rdi
    8c9c:	jne    8c80 <bench_ada__run_19.isra.0+0x1c0>
    8c9e:	shl    r8d,0x3
    8ca2:	cmp    r8d,ecx
    8ca5:	je     8d70 <bench_ada__run_19.isra.0+0x2b0>
    8cab:	lea    edi,[r8-0x1]
    8caf:	mov    r15d,DWORD PTR [rsp+0x74]
    8cb4:	sub    r15d,r8d
    8cb7:	cmp    r15d,0x2
    8cbb:	jbe    8cf5 <bench_ada__run_19.isra.0+0x235>
    8cbd:	mov    rax,QWORD PTR [rsp+0x78]
    8cc2:	inc    r15d
    8cc5:	imul   rax,r14
    8cc9:	add    rax,r8
    8ccc:	add    r8,r10
    8ccf:	vmulpd ymm6,ymm6,YMMWORD PTR [rbx+r8*8]
    8cd5:	mov    r8d,r15d
    8cd8:	and    r8d,0xfffffffc
    8cdc:	and    r15d,0x3
    8ce0:	vaddpd ymm6,ymm6,YMMWORD PTR [r9+rax*8]
    8ce6:	vmovupd YMMWORD PTR [r9+rax*8],ymm6
    8cec:	je     8d70 <bench_ada__run_19.isra.0+0x2b0>
    8cf2:	add    edi,r8d
    8cf5:	mov    r15,QWORD PTR [rsp+0x78]
    8cfa:	lea    r8d,[rdi+0x1]
    8cfe:	mov    DWORD PTR [rsp+0x74],r8d
    8d03:	mov    rax,r15
    8d06:	imul   r15,r11
    8d0a:	imul   rax,r14
    8d0e:	lea    r14,[rax+r8*1]
    8d12:	add    r8,r15
    8d15:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    8d1b:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    8d21:	vmovsd QWORD PTR [r9+r14*8],xmm0
    8d27:	cmp    esi,DWORD PTR [rsp+0x74]
    8d2b:	je     8d70 <bench_ada__run_19.isra.0+0x2b0>
    8d2d:	lea    r8d,[rdi+0x2]
    8d31:	lea    r14,[rax+r8*1]
    8d35:	mov    DWORD PTR [rsp+0x74],r8d
    8d3a:	add    r8,r15
    8d3d:	vmulsd xmm0,xmm1,QWORD PTR [rbx+r8*8]
    8d43:	vaddsd xmm0,xmm0,QWORD PTR [r9+r14*8]
    8d49:	vmovsd QWORD PTR [r9+r14*8],xmm0
    8d4f:	cmp    esi,DWORD PTR [rsp+0x74]
    8d53:	je     8d70 <bench_ada__run_19.isra.0+0x2b0>
    8d55:	lea    esi,[rdi+0x3]
    8d58:	add    rax,rsi
    8d5b:	add    rsi,r15
    8d5e:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rsi*8]
    8d63:	vaddsd xmm1,xmm1,QWORD PTR [r9+rax*8]
    8d69:	vmovsd QWORD PTR [r9+rax*8],xmm1
    8d6f:	nop
    8d70:	inc    ecx
    8d72:	cmp    rdx,r13
    8d75:	jne    8c00 <bench_ada__run_19.isra.0+0x140>
    8d7b:	mov    rdi,QWORD PTR [rsp+0x58]
    8d80:	mov    r11,QWORD PTR [rsp+0x50]
    8d85:	cmp    rdi,r11
    8d88:	jne    8ba9 <bench_ada__run_19.isra.0+0xe9>
    8d8e:	mov    r15d,DWORD PTR [rsp+0x34]
    8d93:	mov    r14,QWORD PTR [rsp+0x28]
    8d98:	vzeroupper
    8d9b:	mov    rax,QWORD PTR [rsp+0x48]
    8da0:	mov    rsi,QWORD PTR [rbp+0x10]
    8da4:	mov    rcx,QWORD PTR [rbp+0x28]
    8da8:	cmp    DWORD PTR [rsp+0x38],r15d
    8dad:	jne    8b40 <bench_ada__run_19.isra.0+0x80>
    8db3:	lea    rsp,[rbp-0x28]
    8db7:	pop    rbx
    8db8:	pop    r12
    8dba:	pop    r13
    8dbc:	pop    r14
    8dbe:	pop    r15
    8dc0:	pop    rbp
    8dc1:	ret
    8dc2:	nop    DWORD PTR [rax]
    8dc5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8dd0:	xor    r8d,r8d
    8dd3:	mov    edi,0xffffffff
    8dd8:	jmp    8caf <bench_ada__run_19.isra.0+0x1ef>
    8ddd:	nop
    8dde:	xchg   ax,ax


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
    8de0:	push   rbp
    8de1:	mov    rbp,rsp
    8de4:	push   r15
    8de6:	push   r14
    8de8:	push   r13
    8dea:	push   r12
    8dec:	push   rbx
    8ded:	and    rsp,0xffffffffffffffc0
    8df1:	add    rsp,0xffffffffffffff80
    8df5:	mov    r10,QWORD PTR [rbp+0x20]
    8df9:	mov    QWORD PTR [rsp+0x58],r8
    8dfe:	test   edx,edx
    8e00:	je     90a7 <bench_ada__run_20.isra.0+0x2c7>
    8e06:	mov    r8d,esi
    8e09:	xor    eax,eax
    8e0b:	mov    DWORD PTR [rsp+0x4c],edi
    8e0f:	test   esi,esi
    8e11:	lea    rdi,[r8*8+0x0]
    8e19:	mov    DWORD PTR [rsp+0x48],edx
    8e1d:	mov    QWORD PTR [rsp+0x30],r8
    8e22:	mov    DWORD PTR [rsp+0x44],esi
    8e26:	cmove  rdi,rax
    8e2a:	mov    rbx,rcx
    8e2d:	mov    r12,r9
    8e30:	cmovne rax,r8
    8e34:	mov    QWORD PTR [rsp+0x70],rdi
    8e39:	xor    r15d,r15d
    8e3c:	imul   rax,rdi
    8e40:	shr    rdi,0x3
    8e44:	mov    QWORD PTR [rsp+0x50],rax
    8e49:	mov    QWORD PTR [rsp+0x78],rdi
    8e4e:	xchg   ax,ax
    8e50:	mov    rax,QWORD PTR [rsp+0x58]
    8e55:	mov    rsi,QWORD PTR [rbp+0x10]
    8e59:	mov    rdi,QWORD PTR [rbp+0x18]
    8e5d:	mov    rcx,QWORD PTR [rbp+0x28]
    8e61:	inc    r15d
    8e64:	mov    rdx,QWORD PTR [rsp+0x50]
    8e69:	xor    esi,esi
    8e6b:	mov    rdi,r10
    8e6e:	call   2bd0 <memset@plt>
    8e73:	vxorpd xmm7,xmm7,xmm7
    8e77:	mov    r10,rax
    8e7a:	mov    eax,DWORD PTR [rsp+0x4c]
    8e7e:	test   eax,eax
    8e80:	je     908b <bench_ada__run_20.isra.0+0x2ab>
    8e86:	mov    edx,DWORD PTR [rsp+0x44]
    8e8a:	test   edx,edx
    8e8c:	je     908b <bench_ada__run_20.isra.0+0x2ab>
    8e92:	lea    rcx,[rax-0x1]
    8e96:	mov    rax,QWORD PTR [rsp+0x30]
    8e9b:	mov    DWORD PTR [rsp+0x40],r15d
    8ea0:	mov    QWORD PTR [rsp+0x38],r12
    8ea5:	mov    QWORD PTR [rsp+0x60],rcx
    8eaa:	mov    rdi,0xffffffffffffffff
    8eb1:	lea    r13,[rax-0x1]
    8eb5:	vmovq  xmm3,r13
    8eba:	nop    WORD PTR [rax+rax*1+0x0]
    8ec0:	mov    r14,QWORD PTR [rsp+0x70]
    8ec5:	inc    rdi
    8ec8:	mov    r9d,0x1
    8ece:	mov    rdx,0xffffffffffffffff
    8ed5:	movsxd rax,edi
    8ed8:	mov    r8,rdi
    8edb:	vmovq  rdi,xmm3
    8ee0:	imul   r14,rax
    8ee4:	lea    rsi,[r14+rbx*1]
    8ee8:	mov    r14,QWORD PTR [rsp+0x78]
    8eed:	mov    QWORD PTR [rsp+0x68],rsi
    8ef2:	imul   r14,rax
    8ef6:	mov    r13,r14
    8ef9:	jmp    8f0c <bench_ada__run_20.isra.0+0x12c>
    8efb:	nop    DWORD PTR [rax+rax*1+0x0]
    8f00:	inc    r9d
    8f03:	cmp    rdx,rdi
    8f06:	je     9070 <bench_ada__run_20.isra.0+0x290>
    8f0c:	inc    rdx
    8f0f:	movsxd r14,edx
    8f12:	mov    esi,edx
    8f14:	lea    rax,[r13+r14*1+0x0]
    8f19:	vmovsd xmm1,QWORD PTR [rbx+rax*8]
    8f1e:	vbroadcastsd zmm2,xmm1
    8f24:	test   edx,edx
    8f26:	js     8f00 <bench_ada__run_20.isra.0+0x120>
    8f28:	vcomisd xmm1,xmm7
    8f2c:	je     8f00 <bench_ada__run_20.isra.0+0x120>
    8f2e:	mov    ecx,edx
    8f30:	cmp    edx,0x6
    8f33:	jbe    90c0 <bench_ada__run_20.isra.0+0x2e0>
    8f39:	mov    r11,QWORD PTR [rsp+0x70]
    8f3e:	mov    r15,QWORD PTR [rsp+0x68]
    8f43:	mov    r12d,r9d
    8f46:	shr    r12d,0x3
    8f4a:	vmovapd zmm4,zmm2
    8f50:	imul   r11,r14
    8f54:	lea    rax,[r11+r10*1]
    8f58:	mov    r11d,r12d
    8f5b:	shl    r11,0x6
    8f5f:	sub    r15,rax
    8f62:	add    r11,rax
    8f65:	nop    DWORD PTR [rax+rax*1+0x0]
    8f6a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8f75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    8f80:	vmulpd zmm0,zmm4,ZMMWORD PTR [rax+r15*1]
    8f87:	add    rax,0x40
    8f8b:	vaddpd zmm0,zmm0,ZMMWORD PTR [rax-0x40]
    8f92:	vmovupd ZMMWORD PTR [rax-0x40],zmm0
    8f99:	cmp    rax,r11
    8f9c:	jne    8f80 <bench_ada__run_20.isra.0+0x1a0>
    8f9e:	shl    r12d,0x3
    8fa2:	cmp    r12d,r9d
    8fa5:	je     8f00 <bench_ada__run_20.isra.0+0x120>
    8fab:	lea    r11d,[r12-0x1]
    8fb0:	sub    ecx,r12d
    8fb3:	cmp    ecx,0x2
    8fb6:	jbe    8fee <bench_ada__run_20.isra.0+0x20e>
    8fb8:	mov    r15,QWORD PTR [rsp+0x78]
    8fbd:	inc    ecx
    8fbf:	imul   r15,r14
    8fc3:	add    r15,r12
    8fc6:	add    r12,r13
    8fc9:	vmulpd ymm2,ymm2,YMMWORD PTR [rbx+r12*8]
    8fcf:	mov    r12d,ecx
    8fd2:	and    r12d,0xfffffffc
    8fd6:	and    ecx,0x3
    8fd9:	vaddpd ymm2,ymm2,YMMWORD PTR [r10+r15*8]
    8fdf:	vmovupd YMMWORD PTR [r10+r15*8],ymm2
    8fe5:	je     8f00 <bench_ada__run_20.isra.0+0x120>
    8feb:	add    r11d,r12d
    8fee:	mov    rax,QWORD PTR [rsp+0x78]
    8ff3:	lea    ecx,[r11+0x1]
    8ff7:	mov    r12,rcx
    8ffa:	imul   rax,r14
    8ffe:	lea    r14,[rax+rcx*1]
    9002:	add    rcx,r13
    9005:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    900a:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    9010:	vmovsd QWORD PTR [r10+r14*8],xmm0
    9016:	cmp    r12d,esi
    9019:	je     8f00 <bench_ada__run_20.isra.0+0x120>
    901f:	lea    ecx,[r11+0x2]
    9023:	lea    r14,[rax+rcx*1]
    9027:	mov    r12,rcx
    902a:	add    rcx,r13
    902d:	vmulsd xmm0,xmm1,QWORD PTR [rbx+rcx*8]
    9032:	vaddsd xmm0,xmm0,QWORD PTR [r10+r14*8]
    9038:	vmovsd QWORD PTR [r10+r14*8],xmm0
    903e:	cmp    r12d,esi
    9041:	je     8f00 <bench_ada__run_20.isra.0+0x120>
    9047:	lea    ecx,[r11+0x3]
    904b:	inc    r9d
    904e:	add    rax,rcx
    9051:	add    rcx,r13
    9054:	vmulsd xmm1,xmm1,QWORD PTR [rbx+rcx*8]
    9059:	vaddsd xmm1,xmm1,QWORD PTR [r10+rax*8]
    905f:	vmovsd QWORD PTR [r10+rax*8],xmm1
    9065:	cmp    rdx,rdi
    9068:	jne    8f0c <bench_ada__run_20.isra.0+0x12c>
    906e:	xchg   ax,ax
    9070:	mov    rdi,r8
    9073:	cmp    r8,QWORD PTR [rsp+0x60]
    9078:	jne    8ec0 <bench_ada__run_20.isra.0+0xe0>
    907e:	mov    r15d,DWORD PTR [rsp+0x40]
    9083:	mov    r12,QWORD PTR [rsp+0x38]
    9088:	vzeroupper
    908b:	mov    rax,QWORD PTR [rsp+0x58]
    9090:	mov    rsi,QWORD PTR [rbp+0x10]
    9094:	mov    rdi,QWORD PTR [rbp+0x18]
    9098:	mov    rcx,QWORD PTR [rbp+0x28]
    909c:	cmp    DWORD PTR [rsp+0x48],r15d
    90a1:	jne    8e50 <bench_ada__run_20.isra.0+0x70>
    90a7:	lea    rsp,[rbp-0x28]
    90ab:	pop    rbx
    90ac:	pop    r12
    90ae:	pop    r13
    90b0:	pop    r14
    90b2:	pop    r15
    90b4:	pop    rbp
    90b5:	ret
    90b6:	cs nop WORD PTR [rax+rax*1+0x0]
    90c0:	xor    r12d,r12d
    90c3:	mov    r11d,0xffffffff
    90c9:	jmp    8fb0 <bench_ada__run_20.isra.0+0x1d0>
    90ce:	xchg   ax,ax


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
    42e4:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2cc52]        # 30f40 <__gnat_ada_main_program_name+0x10>
    42ee:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2cc88]        # 30f80 <__gnat_ada_main_program_name+0x50>
    42f8:	mov    rax,rsi
    42fb:	xor    esi,esi
    42fd:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2ccb9]        # 30fc0 <__gnat_ada_main_program_name+0x90>
    4307:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2ccef]        # 31000 <__gnat_ada_main_program_name+0xd0>
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
    4454:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2cbe2]        # 31040 <__gnat_ada_main_program_name+0x110>
    445e:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2cb18]        # 30f80 <__gnat_ada_main_program_name+0x50>
    4468:	mov    rax,rsi
    446b:	xor    esi,esi
    446d:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2cb49]        # 30fc0 <__gnat_ada_main_program_name+0x90>
    4477:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2cbff]        # 31080 <__gnat_ada_main_program_name+0x150>
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
    45c4:	vmovdqa64 zmm11,ZMMWORD PTR [rip+0x2c972]        # 30f40 <__gnat_ada_main_program_name+0x10>
    45ce:	vmovdqa64 zmm10,ZMMWORD PTR [rip+0x2cae8]        # 310c0 <__gnat_ada_main_program_name+0x190>
    45d8:	mov    rax,rsi
    45db:	xor    esi,esi
    45dd:	vmovdqa64 zmm9,ZMMWORD PTR [rip+0x2cb19]        # 31100 <__gnat_ada_main_program_name+0x1d0>
    45e7:	vmovdqa64 zmm8,ZMMWORD PTR [rip+0x2ca0f]        # 31000 <__gnat_ada_main_program_name+0xd0>
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
    7490:	push   rbp
    7491:	mov    rbp,rsp
    7494:	push   r15
    7496:	push   r14
    7498:	push   r13
    749a:	push   r12
    749c:	push   rbx
    749d:	mov    r13,rcx
    74a0:	and    rsp,0xffffffffffffffc0
    74a4:	add    rsp,0xffffffffffffff80
    74a8:	mov    rcx,QWORD PTR [rbp+0x20]
    74ac:	test   edx,edx
    74ae:	je     7714 <bench_ada__run_8.isra.0+0x284>
    74b4:	mov    ebx,esi
    74b6:	mov    DWORD PTR [rsp+0x48],edx
    74ba:	mov    DWORD PTR [rsp+0x4c],edi
    74be:	mov    QWORD PTR [rsp+0x78],r8
    74c3:	test   ebx,ebx
    74c5:	lea    edx,[rbx-0x1]
    74c8:	lea    rsi,[rbx*8+0x0]
    74d0:	mov    QWORD PTR [rsp+0x50],rbx
    74d5:	setne  r15b
    74d9:	sub    rbx,0x8
    74dd:	movsxd rax,edx
    74e0:	mov    QWORD PTR [rsp+0x60],rsi
    74e5:	mov    QWORD PTR [rsp+0x68],rax
    74ea:	mov    r12,r9
    74ed:	xor    r14d,r14d
    74f0:	shr    rbx,0x3
    74f4:	inc    rbx
    74f7:	lea    rax,[rbx*8+0x0]
    74ff:	mov    QWORD PTR [rsp+0x38],rax
    7504:	nop
    7505:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7510:	mov    rax,QWORD PTR [rsp+0x78]
    7515:	mov    rsi,QWORD PTR [rbp+0x10]
    7519:	mov    rdi,QWORD PTR [rbp+0x18]
    751d:	mov    rdx,QWORD PTR [rbp+0x28]
    7521:	inc    r14d
    7524:	mov    rdx,QWORD PTR [rsp+0x60]
    7529:	mov    rdi,rcx
    752c:	xor    esi,esi
    752e:	call   2bd0 <memset@plt>
    7533:	mov    rcx,rax
    7536:	mov    eax,DWORD PTR [rsp+0x4c]
    753a:	test   eax,eax
    753c:	je     76f8 <bench_ada__run_8.isra.0+0x268>
    7542:	mov    rsi,QWORD PTR [rsp+0x60]
    7547:	mov    r11d,eax
    754a:	mov    DWORD PTR [rsp+0x44],r14d
    754f:	xor    eax,eax
    7551:	vxorpd xmm4,xmm4,xmm4
    7555:	shr    rsi,0x3
    7559:	mov    QWORD PTR [rsp+0x70],rsi
    755e:	lea    rsi,[rcx-0x8]
    7562:	mov    QWORD PTR [rsp+0x58],rsi
    7567:	jmp    758c <bench_ada__run_8.isra.0+0xfc>
    7569:	nop
    756a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7575:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7580:	inc    rax
    7583:	cmp    rax,r11
    7586:	je     76f0 <bench_ada__run_8.isra.0+0x260>
    758c:	vmovsd xmm1,QWORD PTR [r12+rax*8]
    7592:	vcomisd xmm1,xmm4
    7596:	vbroadcastsd zmm2,xmm1
    759c:	je     7580 <bench_ada__run_8.isra.0+0xf0>
    759e:	test   r15b,r15b
    75a1:	je     7580 <bench_ada__run_8.isra.0+0xf0>
    75a3:	mov    rsi,QWORD PTR [rsp+0x70]
    75a8:	mov    rdx,QWORD PTR [rsp+0x58]
    75ad:	movsxd r14,eax
    75b0:	imul   rsi,r14
    75b4:	lea    r8,[r13+rsi*8+0x0]
    75b9:	sub    rdx,r8
    75bc:	cmp    rdx,0x30
    75c0:	jbe    7730 <bench_ada__run_8.isra.0+0x2a0>
    75c6:	cmp    QWORD PTR [rsp+0x68],0x6
    75cc:	jbe    777c <bench_ada__run_8.isra.0+0x2ec>
    75d2:	vmovapd zmm3,zmm2
    75d8:	mov    rdx,rcx
    75db:	xor    edi,edi
    75dd:	sub    r8,rcx
    75e0:	cs nop WORD PTR [rax+rax*1+0x0]
    75ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    75f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7600:	vmulpd zmm0,zmm3,ZMMWORD PTR [rdx+r8*1]
    7607:	inc    rdi
    760a:	add    rdx,0x40
    760e:	vaddpd zmm0,zmm0,ZMMWORD PTR [rdx-0x40]
    7615:	vmovupd ZMMWORD PTR [rdx-0x40],zmm0
    761c:	cmp    rdi,rbx
    761f:	jb     7600 <bench_ada__run_8.isra.0+0x170>
    7621:	mov    rdi,QWORD PTR [rsp+0x38]
    7626:	mov    rdx,rdi
    7629:	cmp    QWORD PTR [rsp+0x50],rdi
    762e:	je     7580 <bench_ada__run_8.isra.0+0xf0>
    7634:	lea    r8,[rdi-0x1]
    7638:	mov    r10,QWORD PTR [rsp+0x68]
    763d:	sub    r10,rdx
    7640:	lea    rdi,[r10+0x1]
    7644:	cmp    r10,0x2
    7648:	jbe    778a <bench_ada__run_8.isra.0+0x2fa>
    764e:	lea    r9,[rcx+rdx*8]
    7652:	vmovq  xmm5,r9
    7657:	lea    r9,[rsi+rdx*1]
    765b:	vmulpd ymm0,ymm2,YMMWORD PTR [r13+r9*8+0x0]
    7662:	vmovq  r9,xmm5
    7667:	vaddpd ymm0,ymm0,YMMWORD PTR [r9]
    766c:	vmovupd YMMWORD PTR [r9],ymm0
    7671:	mov    r9,rdi
    7674:	and    r9,0xfffffffffffffffc
    7678:	add    r8,r9
    767b:	test   dil,0x3
    767f:	je     7580 <bench_ada__run_8.isra.0+0xf0>
    7685:	cmp    r10,r9
    7688:	je     76b7 <bench_ada__run_8.isra.0+0x227>
    768a:	add    rdx,r9
    768d:	sub    rdi,r9
    7690:	add    rsi,rdx
    7693:	vmulpd xmm0,xmm2,XMMWORD PTR [r13+rsi*8+0x0]
    769a:	vaddpd xmm0,xmm0,XMMWORD PTR [rcx+rdx*8]
    769f:	vmovupd XMMWORD PTR [rcx+rdx*8],xmm0
    76a4:	mov    rdx,rdi
    76a7:	and    rdx,0xfffffffffffffffe
    76ab:	and    edi,0x1
    76ae:	je     7580 <bench_ada__run_8.isra.0+0xf0>
    76b4:	add    r8,rdx
    76b7:	imul   r14,QWORD PTR [rsp+0x70]
    76bd:	inc    rax
    76c0:	lea    rdx,[r8+r14*1+0x1]
    76c5:	vmulsd xmm1,xmm1,QWORD PTR [r13+rdx*8+0x0]
    76cc:	vaddsd xmm1,xmm1,QWORD PTR [rcx+r8*8+0x8]
    76d3:	vmovsd QWORD PTR [rcx+r8*8+0x8],xmm1
    76da:	cmp    rax,r11
    76dd:	jne    758c <bench_ada__run_8.isra.0+0xfc>
    76e3:	xchg   ax,ax
    76e5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    76f0:	mov    r14d,DWORD PTR [rsp+0x44]
    76f5:	vzeroupper
    76f8:	mov    rax,QWORD PTR [rsp+0x78]
    76fd:	mov    rsi,QWORD PTR [rbp+0x10]
    7701:	mov    rdi,QWORD PTR [rbp+0x18]
    7705:	mov    rdx,QWORD PTR [rbp+0x28]
    7709:	cmp    DWORD PTR [rsp+0x48],r14d
    770e:	jne    7510 <bench_ada__run_8.isra.0+0x80>
    7714:	lea    rsp,[rbp-0x28]
    7718:	pop    rbx
    7719:	pop    r12
    771b:	pop    r13
    771d:	pop    r14
    771f:	pop    r15
    7721:	pop    rbp
    7722:	ret
    7723:	xchg   ax,ax
    7725:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7730:	mov    rsi,QWORD PTR [rsp+0x60]
    7735:	mov    rdi,QWORD PTR [rsp+0x50]
    773a:	xor    edx,edx
    773c:	imul   rsi,r14
    7740:	add    rsi,r13
    7743:	nop    DWORD PTR [rax+0x0]
    774a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7755:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    7760:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rdx*8]
    7765:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rdx*8]
    776a:	vmovsd QWORD PTR [rcx+rdx*8],xmm0
    776f:	inc    rdx
    7772:	cmp    rdi,rdx
    7775:	jne    7760 <bench_ada__run_8.isra.0+0x2d0>
    7777:	jmp    7580 <bench_ada__run_8.isra.0+0xf0>
    777c:	xor    edx,edx
    777e:	mov    r8,0xffffffffffffffff
    7785:	jmp    7638 <bench_ada__run_8.isra.0+0x1a8>
    778a:	xor    r9d,r9d
    778d:	jmp    7685 <bench_ada__run_8.isra.0+0x1f5>
    7792:	nop    DWORD PTR [rax]
    7795:	data16 cs nop WORD PTR [rax+rax*1+0x0]


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
    5dd0:	mov    rax,rsi
    5dd3:	mov    r10,QWORD PTR [rsp+0x10]
    5dd8:	mov    rsi,QWORD PTR [rsp+0x8]
    5ddd:	mov    r11d,edi
    5de0:	test   edi,edi
    5de2:	je     5e4f <c_run_1.isra.0+0x7f>
    5de4:	xor    edi,edi
    5de6:	cs nop WORD PTR [rax+rax*1+0x0]
    5df0:	vmovsd xmm0,QWORD PTR [rax]
    5df4:	vmovsd QWORD PTR [rsi],xmm0
    5df8:	vmovsd xmm0,QWORD PTR [rax+0x8]
    5dfd:	vmovsd QWORD PTR [rsi+0x8],xmm0
    5e02:	vmovsd xmm0,QWORD PTR [rax+0x10]
    5e07:	vmovsd QWORD PTR [rsi+0x10],xmm0
    5e0c:	vmovsd xmm0,QWORD PTR [rax+0x18]
    5e11:	vmovsd QWORD PTR [rsi+0x18],xmm0
    5e16:	vmovsd xmm0,QWORD PTR [rax+0x20]
    5e1b:	vmovsd QWORD PTR [rsi+0x20],xmm0
    5e20:	vmovsd xmm0,QWORD PTR [rax+0x28]
    5e25:	vmovsd QWORD PTR [rsi+0x28],xmm0
    5e2a:	vmovsd xmm0,QWORD PTR [rax+0x30]
    5e2f:	vmovsd QWORD PTR [rsi+0x30],xmm0
    5e34:	vmovsd xmm0,QWORD PTR [rax+0x38]
    5e39:	vmovsd QWORD PTR [rsi+0x38],xmm0
    5e3e:	vmovsd xmm0,QWORD PTR [rax+0x40]
    5e43:	vmovsd QWORD PTR [rsi+0x40],xmm0
    5e48:	inc    edi
    5e4a:	cmp    edi,r11d
    5e4d:	jne    5df0 <c_run_1.isra.0+0x20>
    5e4f:	ret


<c_run_10.isra.0>:
    6480:	sub    rsp,0x30
    6484:	mov    QWORD PTR [rsp+0x18],r13
    6489:	mov    QWORD PTR [rsp+0x20],r14
    648e:	mov    QWORD PTR [rsp+0x28],r15
    6493:	mov    DWORD PTR [rsp-0xc],edx
    6497:	mov    r15,QWORD PTR [rsp+0x38]
    649c:	mov    r13,QWORD PTR [rsp+0x40]
    64a1:	mov    rax,QWORD PTR [rsp+0x48]
    64a6:	mov    r14,QWORD PTR [rsp+0x50]
    64ab:	test   edx,edx
    64ad:	je     6564 <c_run_10.isra.0+0xe4>
    64b3:	mov    QWORD PTR [rsp],rbx
    64b7:	mov    QWORD PTR [rsp+0x8],rbp
    64bc:	mov    QWORD PTR [rsp+0x10],r12
    64c1:	mov    r10d,edi
    64c4:	mov    rbx,rcx
    64c7:	mov    rbp,r8
    64ca:	mov    r12,r9
    64cd:	test   edi,edi
    64cf:	je     6578 <c_run_10.isra.0+0xf8>
    64d5:	xor    r11d,r11d
    64d8:	test   esi,esi
    64da:	je     6590 <c_run_10.isra.0+0x110>
    64e0:	mov    esi,esi
    64e2:	lea    r9,[rsi*8+0x0]
    64ea:	mov    esi,edi
    64ec:	lea    rdx,[rcx+r9*1]
    64f0:	shl    rsi,0x3
    64f4:	mov    QWORD PTR [rsp-0x8],rdx
    64f9:	mov    rdx,rcx
    64fc:	nop    DWORD PTR [rax+0x0]
    6500:	mov    rdi,QWORD PTR [rsp-0x8]
    6505:	mov    DWORD PTR [rsp-0x10],r11d
    650a:	mov    rbx,rax
    650d:	xor    r8d,r8d
    6510:	mov    rcx,rdi
    6513:	sub    rcx,r9
    6516:	mov    r11,rbx
    6519:	nop    DWORD PTR [rax+0x0]
    6520:	vmovsd xmm0,QWORD PTR [rcx]
    6524:	add    rcx,0x8
    6528:	vmovsd QWORD PTR [r11],xmm0
    652d:	add    r11,rsi
    6530:	cmp    rcx,rdi
    6533:	jne    6520 <c_run_10.isra.0+0xa0>
    6535:	inc    r8d
    6538:	add    rbx,0x8
    653c:	lea    rdi,[rcx+r9*1]
    6540:	cmp    r10d,r8d
    6543:	jne    6510 <c_run_10.isra.0+0x90>
    6545:	mov    r11d,DWORD PTR [rsp-0x10]
    654a:	inc    r11d
    654d:	cmp    DWORD PTR [rsp-0xc],r11d
    6552:	je     6556 <c_run_10.isra.0+0xd6>
    6554:	jmp    6500 <c_run_10.isra.0+0x80>
    6556:	mov    rbx,QWORD PTR [rsp]
    655a:	mov    rbp,QWORD PTR [rsp+0x8]
    655f:	mov    r12,QWORD PTR [rsp+0x10]
    6564:	mov    r13,QWORD PTR [rsp+0x18]
    6569:	mov    r14,QWORD PTR [rsp+0x20]
    656e:	mov    r15,QWORD PTR [rsp+0x28]
    6573:	add    rsp,0x30
    6577:	ret
    6578:	mov    edi,DWORD PTR [rsp-0xc]
    657c:	lea    edx,[r10+0x1]
    6580:	cmp    edi,edx
    6582:	je     6556 <c_run_10.isra.0+0xd6>
    6584:	add    r10d,0x2
    6588:	cmp    edi,r10d
    658b:	je     6556 <c_run_10.isra.0+0xd6>
    658d:	jmp    6578 <c_run_10.isra.0+0xf8>
    658f:	nop
    6590:	mov    edi,DWORD PTR [rsp-0xc]
    6594:	lea    edx,[r11+0x1]
    6598:	cmp    edi,edx
    659a:	je     6556 <c_run_10.isra.0+0xd6>
    659c:	add    r11d,0x2
    65a0:	cmp    edi,r11d
    65a3:	je     6556 <c_run_10.isra.0+0xd6>
    65a5:	jmp    6590 <c_run_10.isra.0+0x110>
    65a7:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_11.isra.0>:
    65b0:	sub    rsp,0x50
    65b4:	mov    QWORD PTR [rsp+0x48],r15
    65b9:	mov    DWORD PTR [rsp-0x60],edi
    65bd:	mov    DWORD PTR [rsp+0xc],esi
    65c1:	mov    r15,QWORD PTR [rsp+0x60]
    65c6:	mov    r11,QWORD PTR [rsp+0x68]
    65cb:	test   esi,esi
    65cd:	je     6988 <c_run_11.isra.0+0x3d8>
    65d3:	mov    QWORD PTR [rsp+0x28],rbp
    65d8:	mov    QWORD PTR [rsp+0x38],r13
    65dd:	mov    rax,QWORD PTR [rsp+0x58]
    65e2:	mov    r10,rdx
    65e5:	mov    r13,rcx
    65e8:	mov    rbp,r8
    65eb:	mov    esi,edi
    65ed:	test   edi,edi
    65ef:	je     699a <c_run_11.isra.0+0x3ea>
    65f5:	lea    eax,[rdi-0x1]
    65f8:	xor    edx,edx
    65fa:	mov    QWORD PTR [rsp+0x20],rbx
    65ff:	lea    ecx,[rdi+0x1]
    6602:	test   eax,eax
    6604:	vmovsd xmm4,QWORD PTR [rip+0x2cecc]        # 334d8 <system__os_lib__standin+0xc>
    660c:	mov    QWORD PTR [rsp+0x40],r14
    6611:	mov    QWORD PTR [rsp+0x30],r12
    6616:	cmovg  eax,edx
    6619:	mov    rbp,r11
    661c:	xor    r12d,r12d
    661f:	lea    edx,[rax+0x1]
    6622:	lea    rax,[rdx*8+0x0]
    662a:	mov    rdi,rdx
    662d:	mov    DWORD PTR [rsp+0x8],edx
    6631:	mov    QWORD PTR [rsp-0x8],rdx
    6636:	lea    rbx,[r10+rax*1]
    663a:	add    rax,r15
    663d:	mov    QWORD PTR [rsp-0x38],rbx
    6642:	mov    ebx,esi
    6644:	mov    QWORD PTR [rsp-0x10],rax
    6649:	add    rdx,rbx
    664c:	mov    QWORD PTR [rsp-0x68],rbx
    6651:	vmovddup xmm3,xmm4
    6655:	shl    rdx,0x3
    6659:	lea    rax,[rdx+r10*1]
    665d:	mov    QWORD PTR [rsp-0x18],rax
    6662:	mov    eax,edi
    6664:	mov    edi,esi
    6666:	lea    rsi,[rdx+r15*1]
    666a:	neg    eax
    666c:	mov    edx,ecx
    666e:	mov    QWORD PTR [rsp-0x28],rsi
    6673:	lea    rsi,[rbx*8+0x0]
    667b:	and    edi,eax
    667d:	and    eax,ecx
    667f:	mov    rbx,r9
    6682:	vmovq  xmm5,rsi
    6687:	shl    rax,0x3
    668b:	lea    rcx,[r10+rax*1]
    668f:	add    rax,r15
    6692:	mov    QWORD PTR [rsp-0x20],rdi
    6697:	lea    rdi,[rdx*8+0x0]
    669f:	mov    QWORD PTR [rsp],rax
    66a3:	lea    rax,[r10+0x8]
    66a7:	mov    QWORD PTR [rsp-0x30],rdi
    66ac:	vmovq  xmm6,rcx
    66b1:	mov    QWORD PTR [rsp+0x10],rax
    66b6:	mov    r9,r8
    66b9:	nop    DWORD PTR [rax+0x0]
    66c0:	vmovsd xmm0,QWORD PTR [r10]
    66c5:	mov    edi,DWORD PTR [rsp+0x8]
    66c9:	vmovsd QWORD PTR [r15],xmm0
    66ce:	cmp    DWORD PTR [rsp-0x60],edi
    66d2:	jle    68f5 <c_run_11.isra.0+0x345>
    66d8:	mov    rax,QWORD PTR [rsp-0x20]
    66dd:	mov    rdi,QWORD PTR [rsp-0x28]
    66e2:	mov    rsi,QWORD PTR [rsp-0x18]
    66e7:	mov    rcx,QWORD PTR [rsp-0x38]
    66ec:	mov    rdx,QWORD PTR [rsp-0x8]
    66f1:	mov    DWORD PTR [rsp-0x5c],r12d
    66f6:	mov    QWORD PTR [rsp-0x58],r13
    66fb:	mov    QWORD PTR [rsp-0x50],r9
    6700:	mov    QWORD PTR [rsp-0x48],rbx
    6705:	mov    QWORD PTR [rsp+0x68],rbp
    670a:	xor    r11d,r11d
    670d:	mov    QWORD PTR [rsp-0x70],rax
    6712:	mov    rax,QWORD PTR [rsp-0x10]
    6717:	vmovq  rbx,xmm6
    671c:	lea    r8d,[rdx-0x1]
    6720:	mov    DWORD PTR [rsp-0x3c],edx
    6724:	vmovsd xmm0,QWORD PTR [rbx+r11*1]
    672a:	mov    rbx,QWORD PTR [rsp]
    672e:	vmovsd QWORD PTR [rbx+r11*1],xmm0
    6734:	cmp    r8d,0x20
    6738:	jbe    690e <c_run_11.isra.0+0x35e>
    673e:	mov    ebx,edx
    6740:	mov    r13,QWORD PTR [rsp-0x70]
    6745:	lea    r8,[rbx-0x1]
    6749:	imul   r8,QWORD PTR [rsp-0x68]
    674f:	lea    rbx,[rbx+r13*1-0x1]
    6754:	lea    r9,[r13*8+0x0]
    675c:	shl    rbx,0x3
    6760:	add    r8,rdx
    6763:	lea    rbp,[r15+r9*1]
    6767:	lea    r14,[r10+r9*1]
    676b:	shl    r8,0x3
    676f:	lea    r12,[r10+r8*1]
    6773:	cmp    r12,rbp
    6776:	lea    r12,[r15+rbx*1]
    677a:	setb   r13b
    677e:	cmp    r12,rcx
    6781:	setb   r12b
    6785:	or     r13d,r12d
    6788:	lea    r12,[r10+rbx*1]
    678c:	cmp    r12,rax
    678f:	mov    BYTE PTR [rsp-0x3e],r13b
    6794:	lea    r13,[r15+r8*1]
    6798:	setb   r12b
    679c:	cmp    r13,r14
    679f:	setb   BYTE PTR [rsp-0x3d]
    67a4:	or     r12b,BYTE PTR [rsp-0x3d]
    67a9:	test   BYTE PTR [rsp-0x3e],r12b
    67ae:	je     691b <c_run_11.isra.0+0x36b>
    67b4:	lea    r12,[rdx*8+0x0]
    67bc:	cmp    rbx,r12
    67bf:	setl   bl
    67c2:	cmp    r8,r9
    67c5:	setl   r8b
    67c9:	or     ebx,r8d
    67cc:	cmp    QWORD PTR [rsp+0x10],r15
    67d1:	setne  r8b
    67d5:	cmp    rsi,rax
    67d8:	setne  r12b
    67dc:	and    r8d,r12d
    67df:	test   bl,r8b
    67e2:	je     691b <c_run_11.isra.0+0x36b>
    67e8:	cmp    edx,0x1
    67eb:	je     6992 <c_run_11.isra.0+0x3e2>
    67f1:	mov    r12,QWORD PTR [rsp-0x68]
    67f6:	mov    r13d,edx
    67f9:	shr    r13d,1
    67fc:	mov    ebx,r13d
    67ff:	xor    r8d,r8d
    6802:	xor    r9d,r9d
    6805:	shl    r12,0x4
    6809:	shl    rbx,0x4
    680d:	nop    DWORD PTR [rax+0x0]
    6814:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    681f:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    682a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6835:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6840:	vmovsd xmm0,QWORD PTR [rcx+r8*1]
    6846:	vmovhpd xmm0,xmm0,QWORD PTR [rsi+r8*1]
    684c:	vaddpd xmm0,xmm0,XMMWORD PTR [r14+r9*1]
    6852:	vmulpd xmm0,xmm0,xmm3
    6856:	vmovlpd QWORD PTR [rax+r8*1],xmm0
    685c:	vmovhpd QWORD PTR [rdi+r8*1],xmm0
    6862:	add    r8,r12
    6865:	vmovupd XMMWORD PTR [rbp+r9*1+0x0],xmm0
    686c:	add    r9,0x10
    6870:	cmp    rbx,r9
    6873:	jne    6840 <c_run_11.isra.0+0x290>
    6875:	add    r13d,r13d
    6878:	cmp    r13d,DWORD PTR [rsp-0x3c]
    687d:	je     68b0 <c_run_11.isra.0+0x300>
    687f:	mov    rbx,QWORD PTR [rsp-0x70]
    6884:	lea    r8d,[r13+rbx*1+0x0]
    6889:	imul   r13d,DWORD PTR [rsp-0x60]
    688f:	vmovsd xmm0,QWORD PTR [r10+r8*8]
    6895:	lea    r9d,[r13+rdx*1+0x0]
    689a:	vaddsd xmm0,xmm0,QWORD PTR [r10+r9*8]
    68a0:	vmulsd xmm0,xmm0,xmm4
    68a4:	vmovsd QWORD PTR [r15+r9*8],xmm0
    68aa:	vmovsd QWORD PTR [r15+r8*8],xmm0
    68b0:	mov    r14,QWORD PTR [rsp-0x68]
    68b5:	add    r11,QWORD PTR [rsp-0x30]
    68ba:	inc    rdx
    68bd:	add    rcx,0x8
    68c1:	add    QWORD PTR [rsp-0x70],r14
    68c6:	add    rax,0x8
    68ca:	add    rsi,0x8
    68ce:	add    rdi,0x8
    68d2:	cmp    DWORD PTR [rsp-0x60],edx
    68d6:	jg     6717 <c_run_11.isra.0+0x167>
    68dc:	mov    r12d,DWORD PTR [rsp-0x5c]
    68e1:	mov    r13,QWORD PTR [rsp-0x58]
    68e6:	mov    r9,QWORD PTR [rsp-0x50]
    68eb:	mov    rbx,QWORD PTR [rsp-0x48]
    68f0:	mov    rbp,QWORD PTR [rsp+0x68]
    68f5:	mov    rax,QWORD PTR [rsp+0x58]
    68fa:	inc    r12d
    68fd:	cmp    DWORD PTR [rsp+0xc],r12d
    6902:	je     696f <c_run_11.isra.0+0x3bf>
    6904:	mov    rax,QWORD PTR [rsp+0x58]
    6909:	jmp    66c0 <c_run_11.isra.0+0x110>
    690e:	mov    rbx,QWORD PTR [rsp-0x70]
    6913:	lea    r9,[rbx*8+0x0]
    691b:	lea    r12,[r10+r9*1]
    691f:	xor    ebx,ebx
    6921:	add    r9,r15
    6924:	xor    r8d,r8d
    6927:	vmovq  rbp,xmm5
    692c:	nop    WORD PTR [rax+rax*1+0x0]
    6935:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    6940:	vmovsd xmm0,QWORD PTR [r12+r8*8]
    6946:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rbx*1]
    694b:	vmulsd xmm0,xmm0,xmm4
    694f:	vmovsd QWORD PTR [rax+rbx*1],xmm0
    6954:	vmovsd QWORD PTR [r9+r8*8],xmm0
    695a:	inc    r8
    695d:	add    rbx,rbp
    6960:	cmp    r8d,edx
    6963:	jl     6940 <c_run_11.isra.0+0x390>
    6965:	vmovq  xmm5,rbp
    696a:	jmp    68b0 <c_run_11.isra.0+0x300>
    696f:	mov    rbx,QWORD PTR [rsp+0x20]
    6974:	mov    rbp,QWORD PTR [rsp+0x28]
    6979:	mov    r12,QWORD PTR [rsp+0x30]
    697e:	mov    r13,QWORD PTR [rsp+0x38]
    6983:	mov    r14,QWORD PTR [rsp+0x40]
    6988:	mov    r15,QWORD PTR [rsp+0x48]
    698d:	add    rsp,0x50
    6991:	ret
    6992:	xor    r13d,r13d
    6995:	jmp    687f <c_run_11.isra.0+0x2cf>
    699a:	mov    eax,DWORD PTR [rsp-0x60]
    699e:	mov    rdx,QWORD PTR [rsp+0x58]
    69a3:	mov    esi,DWORD PTR [rsp+0xc]
    69a7:	lea    ecx,[rax+0x1]
    69aa:	cmp    esi,ecx
    69ac:	je     69c0 <c_run_11.isra.0+0x410>
    69ae:	add    eax,0x2
    69b1:	cmp    esi,eax
    69b3:	je     69c0 <c_run_11.isra.0+0x410>
    69b5:	mov    esi,DWORD PTR [rsp+0xc]
    69b9:	lea    ecx,[rax+0x1]
    69bc:	cmp    esi,ecx
    69be:	jne    69ae <c_run_11.isra.0+0x3fe>
    69c0:	mov    rbp,QWORD PTR [rsp+0x28]
    69c5:	mov    r13,QWORD PTR [rsp+0x38]
    69ca:	jmp    6988 <c_run_11.isra.0+0x3d8>
    69cc:	nop    DWORD PTR [rax+0x0]


<c_run_12.isra.0>:
    9700:	sub    rsp,0x58
    9704:	mov    QWORD PTR [rsp+0x28],rbx
    9709:	mov    QWORD PTR [rsp+0x8],rdx
    970e:	mov    ebx,edi
    9710:	mov    rdi,QWORD PTR [rsp+0x68]
    9715:	test   esi,esi
    9717:	je     97cf <c_run_12.isra.0+0xcf>
    971d:	mov    eax,ebx
    971f:	mov    DWORD PTR [rsp+0x1c],esi
    9723:	mov    QWORD PTR [rsp+0x38],r12
    9728:	mov    r12,r8
    972b:	lea    r8d,[rbx+0x1]
    972f:	mov    QWORD PTR [rsp+0x30],rbp
    9734:	mov    QWORD PTR [rsp+0x40],r13
    9739:	mov    QWORD PTR [rsp+0x48],r14
    973e:	mov    QWORD PTR [rsp+0x50],r15
    9743:	mov    rbp,rcx
    9746:	mov    r13,r9
    9749:	lea    r15,[r8*8+0x0]
    9751:	imul   eax,ebx
    9754:	xor    r14d,r14d
    9757:	shl    rax,0x3
    975b:	mov    QWORD PTR [rsp+0x10],rax
    9760:	mov    rax,QWORD PTR [rsp+0x8]
    9765:	mov    rcx,QWORD PTR [rsp+0x60]
    976a:	mov    rsi,QWORD PTR [rsp+0x70]
    976f:	mov    rdx,QWORD PTR [rsp+0x10]
    9774:	xor    esi,esi
    9776:	call   2bd0 <memset@plt>
    977b:	test   ebx,ebx
    977d:	vmovsd xmm0,QWORD PTR [rip+0x29d83]        # 33508 <system__os_lib__standin+0x3c>
    9785:	mov    rdi,rax
    9788:	je     979d <c_run_12.isra.0+0x9d>
    978a:	mov    rdx,rax
    978d:	xor    eax,eax
    978f:	nop
    9790:	inc    eax
    9792:	vmovsd QWORD PTR [rdx],xmm0
    9796:	add    rdx,r15
    9799:	cmp    ebx,eax
    979b:	jne    9790 <c_run_12.isra.0+0x90>
    979d:	mov    rax,QWORD PTR [rsp+0x8]
    97a2:	mov    rcx,QWORD PTR [rsp+0x60]
    97a7:	mov    rsi,QWORD PTR [rsp+0x70]
    97ac:	inc    r14d
    97af:	cmp    r14d,DWORD PTR [rsp+0x1c]
    97b4:	jne    9760 <c_run_12.isra.0+0x60>
    97b6:	mov    rbp,QWORD PTR [rsp+0x30]
    97bb:	mov    r12,QWORD PTR [rsp+0x38]
    97c0:	mov    r13,QWORD PTR [rsp+0x40]
    97c5:	mov    r14,QWORD PTR [rsp+0x48]
    97ca:	mov    r15,QWORD PTR [rsp+0x50]
    97cf:	mov    rbx,QWORD PTR [rsp+0x28]
    97d4:	add    rsp,0x58
    97d8:	ret
    97d9:	nop    DWORD PTR [rax+0x0]


<c_run_13.isra.0>:
    a4a0:	sub    rsp,0x58
    a4a4:	mov    QWORD PTR [rsp+0x48],r14
    a4a9:	mov    QWORD PTR [rsp+0x50],r15
    a4ae:	mov    r14,rcx
    a4b1:	mov    r10,QWORD PTR [rsp+0x60]
    a4b6:	mov    r11,QWORD PTR [rsp+0x68]
    a4bb:	mov    r15,QWORD PTR [rsp+0x70]
    a4c0:	mov    rcx,QWORD PTR [rsp+0x78]
    a4c5:	test   edx,edx
    a4c7:	je     a59b <c_run_13.isra.0+0xfb>
    a4cd:	mov    eax,edi
    a4cf:	sar    eax,1
    a4d1:	je     a586 <c_run_13.isra.0+0xe6>
    a4d7:	mov    QWORD PTR [rsp+0x28],rbx
    a4dc:	mov    DWORD PTR [rsp+0xc],edx
    a4e0:	mov    QWORD PTR [rsp+0x10],r8
    a4e5:	mov    QWORD PTR [rsp+0x18],r9
    a4ea:	mov    QWORD PTR [rsp+0x60],r10
    a4ef:	mov    QWORD PTR [rsp+0x68],r11
    a4f4:	mov    QWORD PTR [rsp+0x30],rbp
    a4f9:	mov    ebp,esi
    a4fb:	mov    eax,eax
    a4fd:	mov    QWORD PTR [rsp+0x40],r13
    a502:	mov    r13,rbp
    a505:	mov    QWORD PTR [rsp+0x38],r12
    a50a:	lea    r12,[rcx+rax*4]
    a50e:	xor    eax,eax
    a510:	shl    rbp,0x3
    a514:	nop
    a515:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a520:	mov    DWORD PTR [rsp+0x8],eax
    a524:	mov    QWORD PTR [rsp+0x78],rcx
    a529:	mov    rbx,rcx
    a52c:	nop    DWORD PTR [rax+0x0]
    a530:	mov    esi,DWORD PTR [rbx]
    a532:	mov    rdx,rbp
    a535:	add    rbx,0x4
    a539:	imul   esi,r13d
    a53d:	movsxd rsi,esi
    a540:	shl    rsi,0x3
    a544:	lea    rdi,[r15+rsi*1]
    a548:	add    rsi,r14
    a54b:	call   30f0 <memcpy@plt>
    a550:	cmp    r12,rbx
    a553:	jne    a530 <c_run_13.isra.0+0x90>
    a555:	mov    eax,DWORD PTR [rsp+0x8]
    a559:	mov    rcx,QWORD PTR [rsp+0x78]
    a55e:	mov    rdx,QWORD PTR [rsp+0x10]
    a563:	mov    rdi,QWORD PTR [rsp+0x18]
    a568:	mov    rbx,QWORD PTR [rsp+0x60]
    a56d:	mov    rsi,QWORD PTR [rsp+0x68]
    a572:	inc    eax
    a574:	cmp    DWORD PTR [rsp+0xc],eax
    a578:	je     a5b0 <c_run_13.isra.0+0x110>
    a57a:	mov    rbx,QWORD PTR [rsp+0x60]
    a57f:	mov    rsi,QWORD PTR [rsp+0x68]
    a584:	jmp    a520 <c_run_13.isra.0+0x80>
    a586:	lea    esi,[rax+0x1]
    a589:	cmp    edx,esi
    a58b:	je     a59b <c_run_13.isra.0+0xfb>
    a58d:	add    eax,0x2
    a590:	cmp    edx,eax
    a592:	je     a59b <c_run_13.isra.0+0xfb>
    a594:	lea    esi,[rax+0x1]
    a597:	cmp    edx,esi
    a599:	jne    a58d <c_run_13.isra.0+0xed>
    a59b:	mov    r14,QWORD PTR [rsp+0x48]
    a5a0:	mov    r15,QWORD PTR [rsp+0x50]
    a5a5:	add    rsp,0x58
    a5a9:	ret
    a5aa:	nop    WORD PTR [rax+rax*1+0x0]
    a5b0:	mov    rbx,QWORD PTR [rsp+0x28]
    a5b5:	mov    rbp,QWORD PTR [rsp+0x30]
    a5ba:	mov    r12,QWORD PTR [rsp+0x38]
    a5bf:	mov    r13,QWORD PTR [rsp+0x40]
    a5c4:	mov    r14,QWORD PTR [rsp+0x48]
    a5c9:	mov    r15,QWORD PTR [rsp+0x50]
    a5ce:	add    rsp,0x58
    a5d2:	ret
    a5d3:	xchg   ax,ax
    a5d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_14.isra.0>:
    97e0:	push   rbp
    97e1:	mov    rbp,rsp
    97e4:	push   r15
    97e6:	push   r14
    97e8:	push   r13
    97ea:	push   r12
    97ec:	push   rbx
    97ed:	and    rsp,0xffffffffffffffe0
    97f1:	sub    rsp,0x40
    97f5:	mov    QWORD PTR [rsp+0x18],r8
    97fa:	test   ecx,ecx
    97fc:	je     99c5 <c_run_14.isra.0+0x1e5>
    9802:	mov    eax,edi
    9804:	mov    DWORD PTR [rsp+0x28],edi
    9808:	mov    DWORD PTR [rsp+0x20],ecx
    980c:	mov    DWORD PTR [rsp+0x4],esi
    9810:	mov    DWORD PTR [rsp+0x24],0x0
    9818:	mov    r14,QWORD PTR [rbp+0x28]
    981c:	mov    r12,r9
    981f:	mov    ebx,edx
    9821:	imul   eax,edx
    9824:	shl    rax,0x3
    9828:	mov    QWORD PTR [rsp+0x10],rax
    982d:	mov    eax,esi
    982f:	lea    r15,[rax*8+0x0]
    9837:	lea    rax,[r8+r15*1]
    983b:	mov    QWORD PTR [rsp+0x38],r15
    9840:	mov    QWORD PTR [rsp+0x8],rax
    9845:	lea    eax,[rdx-0x4]
    9848:	and    eax,0xfffffffc
    984b:	add    eax,0x4
    984e:	mov    edi,edx
    9850:	sub    edi,eax
    9852:	mov    DWORD PTR [rsp+0x30],eax
    9856:	mov    DWORD PTR [rsp+0x2c],edi
    985a:	mov    rax,QWORD PTR [rsp+0x18]
    985f:	mov    rdi,QWORD PTR [rbp+0x10]
    9863:	mov    rcx,QWORD PTR [rbp+0x18]
    9867:	mov    rsi,QWORD PTR [rbp+0x20]
    986b:	mov    rdx,QWORD PTR [rbp+0x30]
    986f:	mov    rdx,QWORD PTR [rsp+0x10]
    9874:	xor    esi,esi
    9876:	mov    rdi,r14
    9879:	call   2bd0 <memset@plt>
    987e:	mov    edx,DWORD PTR [rsp+0x28]
    9882:	test   edx,edx
    9884:	je     999e <c_run_14.isra.0+0x1be>
    988a:	mov    eax,DWORD PTR [rsp+0x4]
    988e:	mov    rdi,QWORD PTR [rsp+0x8]
    9893:	xor    r11d,r11d
    9896:	xor    r10d,r10d
    9899:	test   eax,eax
    989b:	je     999e <c_run_14.isra.0+0x1be>
    98a1:	lea    eax,[rbx-0x4]
    98a4:	vxorpd xmm3,xmm3,xmm3
    98a8:	shr    eax,0x2
    98ab:	inc    eax
    98ad:	shl    rax,0x5
    98b1:	nop    DWORD PTR [rax+0x0]
    98b5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    98c0:	movsxd rdx,r11d
    98c3:	mov    DWORD PTR [rsp+0x34],r10d
    98c8:	xor    ecx,ecx
    98ca:	lea    r8,[r14+rdx*8]
    98ce:	mov    rdx,rdi
    98d1:	sub    rdx,QWORD PTR [rsp+0x38]
    98d6:	lea    rsi,[rax+r8*1]
    98da:	jmp    98ef <c_run_14.isra.0+0x10f>
    98dc:	nop    DWORD PTR [rax+0x0]
    98e0:	add    rdx,0x8
    98e4:	add    ecx,ebx
    98e6:	cmp    rdi,rdx
    98e9:	je     9980 <c_run_14.isra.0+0x1a0>
    98ef:	vmovsd xmm1,QWORD PTR [rdx]
    98f3:	vcomisd xmm1,xmm3
    98f7:	je     98e0 <c_run_14.isra.0+0x100>
    98f9:	mov    r9d,ecx
    98fc:	lea    r10,[r12+r9*8]
    9900:	cmp    ebx,0x4
    9903:	js     99e0 <c_run_14.isra.0+0x200>
    9909:	mov    r15,r10
    990c:	sub    r15,r8
    990f:	vbroadcastsd ymm2,xmm1
    9914:	mov    r9,r8
    9917:	nop    WORD PTR [rax+rax*1+0x0]
    9920:	vmulpd ymm0,ymm2,YMMWORD PTR [r15+r9*1]
    9926:	add    r9,0x20
    992a:	vaddpd ymm0,ymm0,YMMWORD PTR [r9-0x20]
    9930:	vmovupd YMMWORD PTR [r9-0x20],ymm0
    9936:	cmp    rsi,r9
    9939:	jne    9920 <c_run_14.isra.0+0x140>
    993b:	mov    r15d,DWORD PTR [rsp+0x2c]
    9940:	mov    r9d,DWORD PTR [rsp+0x30]
    9945:	cmp    r15d,0x3
    9949:	je     99f0 <c_run_14.isra.0+0x210>
    994f:	cmp    r15d,0x2
    9953:	je     9a40 <c_run_14.isra.0+0x260>
    9959:	cmp    r15d,0x1
    995d:	jne    98e0 <c_run_14.isra.0+0x100>
    995f:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*8]
    9965:	add    rdx,0x8
    9969:	add    ecx,ebx
    996b:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*8]
    9971:	vmovsd QWORD PTR [r8+r9*8],xmm1
    9977:	cmp    rdi,rdx
    997a:	jne    98ef <c_run_14.isra.0+0x10f>
    9980:	mov    r10d,DWORD PTR [rsp+0x34]
    9985:	add    rdi,QWORD PTR [rsp+0x38]
    998a:	add    r11d,ebx
    998d:	inc    r10d
    9990:	cmp    DWORD PTR [rsp+0x28],r10d
    9995:	jne    98c0 <c_run_14.isra.0+0xe0>
    999b:	vzeroupper
    999e:	mov    rax,QWORD PTR [rsp+0x18]
    99a3:	mov    rdi,QWORD PTR [rbp+0x10]
    99a7:	mov    rcx,QWORD PTR [rbp+0x18]
    99ab:	mov    rsi,QWORD PTR [rbp+0x20]
    99af:	mov    rdx,QWORD PTR [rbp+0x30]
    99b3:	inc    DWORD PTR [rsp+0x24]
    99b7:	mov    edi,DWORD PTR [rsp+0x20]
    99bb:	cmp    DWORD PTR [rsp+0x24],edi
    99bf:	jne    985a <c_run_14.isra.0+0x7a>
    99c5:	lea    rsp,[rbp-0x28]
    99c9:	pop    rbx
    99ca:	pop    r12
    99cc:	pop    r13
    99ce:	pop    r14
    99d0:	pop    r15
    99d2:	pop    rbp
    99d3:	ret
    99d4:	nop
    99d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    99e0:	mov    r15d,ebx
    99e3:	xor    r9d,r9d
    99e6:	cmp    r15d,0x3
    99ea:	jne    994f <c_run_14.isra.0+0x16f>
    99f0:	shl    r9,0x3
    99f4:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1]
    99fa:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1]
    9a00:	vmovsd QWORD PTR [r8+r9*1],xmm0
    9a06:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1+0x8]
    9a0d:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1+0x8]
    9a14:	vmovsd QWORD PTR [r8+r9*1+0x8],xmm0
    9a1b:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*1+0x10]
    9a22:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*1+0x10]
    9a29:	vmovsd QWORD PTR [r8+r9*1+0x10],xmm1
    9a30:	jmp    98e0 <c_run_14.isra.0+0x100>
    9a35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9a40:	shl    r9,0x3
    9a44:	vmulsd xmm0,xmm1,QWORD PTR [r10+r9*1]
    9a4a:	vaddsd xmm0,xmm0,QWORD PTR [r8+r9*1]
    9a50:	vmovsd QWORD PTR [r8+r9*1],xmm0
    9a56:	vmulsd xmm1,xmm1,QWORD PTR [r10+r9*1+0x8]
    9a5d:	vaddsd xmm1,xmm1,QWORD PTR [r8+r9*1+0x8]
    9a64:	vmovsd QWORD PTR [r8+r9*1+0x8],xmm1
    9a6b:	jmp    98e0 <c_run_14.isra.0+0x100>


<c_run_15.isra.0>:
    9a70:	push   rbp
    9a71:	mov    rbp,rsp
    9a74:	push   r15
    9a76:	push   r14
    9a78:	push   r13
    9a7a:	push   r12
    9a7c:	push   rbx
    9a7d:	and    rsp,0xffffffffffffffe0
    9a81:	sub    rsp,0x40
    9a85:	mov    r11,QWORD PTR [rbp+0x28]
    9a89:	mov    QWORD PTR [rsp+0x18],r8
    9a8e:	test   ecx,ecx
    9a90:	je     9c64 <c_run_15.isra.0+0x1f4>
    9a96:	mov    eax,esi
    9a98:	mov    DWORD PTR [rsp+0x28],edi
    9a9c:	mov    DWORD PTR [rsp+0x20],ecx
    9aa0:	mov    DWORD PTR [rsp+0x24],0x0
    9aa8:	mov    DWORD PTR [rsp+0x4],esi
    9aac:	mov    r14,r9
    9aaf:	mov    ebx,edx
    9ab1:	imul   eax,edx
    9ab4:	shl    rax,0x3
    9ab8:	mov    QWORD PTR [rsp+0x10],rax
    9abd:	mov    eax,esi
    9abf:	lea    r15,[rax*8+0x0]
    9ac7:	lea    rax,[r8+r15*1]
    9acb:	mov    QWORD PTR [rsp+0x38],r15
    9ad0:	mov    QWORD PTR [rsp+0x8],rax
    9ad5:	lea    eax,[rdx-0x4]
    9ad8:	and    eax,0xfffffffc
    9adb:	add    eax,0x4
    9ade:	mov    edi,edx
    9ae0:	sub    edi,eax
    9ae2:	mov    DWORD PTR [rsp+0x30],eax
    9ae6:	mov    DWORD PTR [rsp+0x2c],edi
    9aea:	mov    rax,QWORD PTR [rsp+0x18]
    9aef:	mov    rdi,QWORD PTR [rbp+0x10]
    9af3:	mov    rdx,QWORD PTR [rbp+0x18]
    9af7:	mov    rcx,QWORD PTR [rbp+0x20]
    9afb:	mov    rsi,QWORD PTR [rbp+0x30]
    9aff:	mov    rdx,QWORD PTR [rsp+0x10]
    9b04:	mov    rdi,r11
    9b07:	xor    esi,esi
    9b09:	call   2bd0 <memset@plt>
    9b0e:	mov    ecx,DWORD PTR [rsp+0x28]
    9b12:	mov    r11,rax
    9b15:	test   ecx,ecx
    9b17:	je     9c3d <c_run_15.isra.0+0x1cd>
    9b1d:	mov    edx,DWORD PTR [rsp+0x4]
    9b21:	mov    r8,QWORD PTR [rsp+0x8]
    9b26:	xor    ecx,ecx
    9b28:	xor    eax,eax
    9b2a:	test   edx,edx
    9b2c:	je     9c3d <c_run_15.isra.0+0x1cd>
    9b32:	lea    edx,[rbx-0x4]
    9b35:	vxorpd xmm3,xmm3,xmm3
    9b39:	mov    rdi,r14
    9b3c:	shr    edx,0x2
    9b3f:	inc    edx
    9b41:	shl    rdx,0x5
    9b45:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9b50:	movsxd rsi,ecx
    9b53:	mov    DWORD PTR [rsp+0x34],eax
    9b57:	xor    r9d,r9d
    9b5a:	lea    r13,[rdi+rsi*8]
    9b5e:	mov    rsi,r8
    9b61:	sub    rsi,QWORD PTR [rsp+0x38]
    9b66:	lea    r10,[rdx+r13*1]
    9b6a:	jmp    9b90 <c_run_15.isra.0+0x120>
    9b6c:	nop    WORD PTR [rax+rax*1+0x0]
    9b75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9b80:	add    rsi,0x8
    9b84:	add    r9d,ebx
    9b87:	cmp    r8,rsi
    9b8a:	je     9c20 <c_run_15.isra.0+0x1b0>
    9b90:	vmovsd xmm1,QWORD PTR [rsi]
    9b94:	vcomisd xmm1,xmm3
    9b98:	je     9b80 <c_run_15.isra.0+0x110>
    9b9a:	mov    eax,r9d
    9b9d:	lea    r15,[r11+rax*8]
    9ba1:	cmp    ebx,0x4
    9ba4:	js     9c80 <c_run_15.isra.0+0x210>
    9baa:	mov    r14,r15
    9bad:	sub    r14,r13
    9bb0:	vbroadcastsd ymm2,xmm1
    9bb5:	mov    rax,r13
    9bb8:	nop    DWORD PTR [rax+rax*1+0x0]
    9bc0:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    9bc4:	vaddpd ymm0,ymm0,YMMWORD PTR [r14+rax*1]
    9bca:	vmovupd YMMWORD PTR [r14+rax*1],ymm0
    9bd0:	add    rax,0x20
    9bd4:	cmp    r10,rax
    9bd7:	jne    9bc0 <c_run_15.isra.0+0x150>
    9bd9:	mov    r14d,DWORD PTR [rsp+0x2c]
    9bde:	mov    eax,DWORD PTR [rsp+0x30]
    9be2:	cmp    r14d,0x3
    9be6:	je     9c8f <c_run_15.isra.0+0x21f>
    9bec:	cmp    r14d,0x2
    9bf0:	je     9ce0 <c_run_15.isra.0+0x270>
    9bf6:	cmp    r14d,0x1
    9bfa:	jne    9b80 <c_run_15.isra.0+0x110>
    9bfc:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*8+0x0]
    9c03:	add    rsi,0x8
    9c07:	add    r9d,ebx
    9c0a:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*8]
    9c10:	vmovsd QWORD PTR [r15+rax*8],xmm1
    9c16:	cmp    r8,rsi
    9c19:	jne    9b90 <c_run_15.isra.0+0x120>
    9c1f:	nop
    9c20:	mov    eax,DWORD PTR [rsp+0x34]
    9c24:	add    r8,QWORD PTR [rsp+0x38]
    9c29:	add    ecx,ebx
    9c2b:	inc    eax
    9c2d:	cmp    DWORD PTR [rsp+0x28],eax
    9c31:	jne    9b50 <c_run_15.isra.0+0xe0>
    9c37:	mov    r14,rdi
    9c3a:	vzeroupper
    9c3d:	mov    rax,QWORD PTR [rsp+0x18]
    9c42:	mov    rdi,QWORD PTR [rbp+0x10]
    9c46:	mov    rdx,QWORD PTR [rbp+0x18]
    9c4a:	mov    rcx,QWORD PTR [rbp+0x20]
    9c4e:	mov    rsi,QWORD PTR [rbp+0x30]
    9c52:	inc    DWORD PTR [rsp+0x24]
    9c56:	mov    edi,DWORD PTR [rsp+0x20]
    9c5a:	cmp    DWORD PTR [rsp+0x24],edi
    9c5e:	jne    9aea <c_run_15.isra.0+0x7a>
    9c64:	lea    rsp,[rbp-0x28]
    9c68:	pop    rbx
    9c69:	pop    r12
    9c6b:	pop    r13
    9c6d:	pop    r14
    9c6f:	pop    r15
    9c71:	pop    rbp
    9c72:	ret
    9c73:	xchg   ax,ax
    9c75:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9c80:	mov    r14d,ebx
    9c83:	xor    eax,eax
    9c85:	cmp    r14d,0x3
    9c89:	jne    9bec <c_run_15.isra.0+0x17c>
    9c8f:	shl    rax,0x3
    9c93:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x0]
    9c9a:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    9ca0:	vmovsd QWORD PTR [r15+rax*1],xmm0
    9ca6:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x8]
    9cad:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1+0x8]
    9cb4:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm0
    9cbb:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*1+0x10]
    9cc2:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x10]
    9cc9:	vmovsd QWORD PTR [r15+rax*1+0x10],xmm1
    9cd0:	jmp    9b80 <c_run_15.isra.0+0x110>
    9cd5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9ce0:	shl    rax,0x3
    9ce4:	vmulsd xmm0,xmm1,QWORD PTR [r13+rax*1+0x0]
    9ceb:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    9cf1:	vmovsd QWORD PTR [r15+rax*1],xmm0
    9cf7:	vmulsd xmm1,xmm1,QWORD PTR [r13+rax*1+0x8]
    9cfe:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x8]
    9d05:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm1
    9d0c:	jmp    9b80 <c_run_15.isra.0+0x110>
    9d11:	nop    DWORD PTR [rax+0x0]
    9d15:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_16.isra.0>:
    a200:	push   rbp
    a201:	mov    rbp,rsp
    a204:	push   r15
    a206:	push   r14
    a208:	push   r13
    a20a:	push   r12
    a20c:	push   rbx
    a20d:	and    rsp,0xffffffffffffffe0
    a211:	mov    rax,QWORD PTR [rbp+0x28]
    a215:	mov    DWORD PTR [rsp-0xc],ecx
    a219:	test   ecx,ecx
    a21b:	je     a283 <c_run_16.isra.0+0x83>
    a21d:	mov    r15d,edi
    a220:	mov    ebx,esi
    a222:	mov    rdi,r8
    a225:	mov    rcx,QWORD PTR [rbp+0x10]
    a229:	mov    rsi,QWORD PTR [rbp+0x18]
    a22d:	mov    r11,QWORD PTR [rbp+0x20]
    a231:	mov    r8,QWORD PTR [rbp+0x30]
    a235:	mov    r14,r9
    a238:	test   r15d,r15d
    a23b:	je     a463 <c_run_16.isra.0+0x263>
    a241:	mov    DWORD PTR [rsp-0x8],0x0
    a249:	test   edx,edx
    a24b:	jne    a292 <c_run_16.isra.0+0x92>
    a24d:	mov    rcx,QWORD PTR [rbp+0x10]
    a251:	mov    rsi,QWORD PTR [rbp+0x18]
    a255:	mov    r8,QWORD PTR [rbp+0x20]
    a259:	mov    r9,QWORD PTR [rbp+0x30]
    a25d:	xor    edx,edx
    a25f:	mov    ebx,DWORD PTR [rsp-0xc]
    a263:	lea    r10d,[rdx+0x1]
    a267:	cmp    ebx,r10d
    a26a:	je     a283 <c_run_16.isra.0+0x83>
    a26c:	add    edx,0x2
    a26f:	cmp    ebx,edx
    a271:	je     a283 <c_run_16.isra.0+0x83>
    a273:	jmp    a25f <c_run_16.isra.0+0x5f>
    a275:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a280:	vzeroupper
    a283:	lea    rsp,[rbp-0x28]
    a287:	pop    rbx
    a288:	pop    r12
    a28a:	pop    r13
    a28c:	pop    r14
    a28e:	pop    r15
    a290:	pop    rbp
    a291:	ret
    a292:	mov    edx,edx
    a294:	lea    r11d,[rbx-0x8]
    a298:	lea    ecx,[rbx-0x4]
    a29b:	mov    r10d,ebx
    a29e:	lea    r13,[rdx*8+0x0]
    a2a6:	and    r11d,0xfffffffc
    a2aa:	lea    rdx,[rax+r13*1]
    a2ae:	add    r11d,0x8
    a2b2:	mov    QWORD PTR [rsp-0x20],rdx
    a2b7:	mov    edx,0x4
    a2bc:	shl    r10,0x3
    a2c0:	cmp    ecx,0x3
    a2c3:	cmovle r11d,edx
    a2c7:	mov    r12d,ebx
    a2ca:	sub    r12d,r11d
    a2cd:	mov    r9,QWORD PTR [rsp-0x20]
    a2d2:	mov    QWORD PTR [rsp-0x18],rdi
    a2d7:	mov    QWORD PTR [rbp+0x28],rax
    a2db:	mov    rdx,rdi
    a2de:	xor    r8d,r8d
    a2e1:	nop    DWORD PTR [rax+0x0]
    a2e5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a2f0:	mov    DWORD PTR [rsp-0x4],r8d
    a2f5:	mov    rdi,r9
    a2f8:	sub    rdi,r13
    a2fb:	mov    rax,r14
    a2fe:	xchg   ax,ax
    a300:	test   ecx,ecx
    a302:	js     a3f0 <c_run_16.isra.0+0x1f0>
    a308:	vmovupd ymm1,YMMWORD PTR [rdx]
    a30c:	vmulpd ymm1,ymm1,YMMWORD PTR [rax]
    a310:	cmp    ecx,0x3
    a313:	jle    a336 <c_run_16.isra.0+0x136>
    a315:	mov    esi,0x4
    a31a:	nop    WORD PTR [rax+rax*1+0x0]
    a320:	vmovupd ymm0,YMMWORD PTR [rdx+rsi*8]
    a325:	vmulpd ymm0,ymm0,YMMWORD PTR [rax+rsi*8]
    a32a:	add    rsi,0x4
    a32e:	vaddpd ymm1,ymm1,ymm0
    a332:	cmp    ecx,esi
    a334:	jge    a320 <c_run_16.isra.0+0x120>
    a336:	vmovapd xmm0,xmm1
    a33a:	vextractf64x2 xmm1,ymm1,0x1
    a341:	mov    r8d,r12d
    a344:	mov    esi,r11d
    a347:	vaddpd xmm0,xmm0,xmm1
    a34b:	vunpckhpd xmm1,xmm0,xmm0
    a34f:	vaddsd xmm0,xmm0,xmm1
    a353:	cmp    r8d,0x3
    a357:	je     a403 <c_run_16.isra.0+0x203>
    a35d:	cmp    r8d,0x2
    a361:	je     a440 <c_run_16.isra.0+0x240>
    a367:	cmp    r8d,0x1
    a36b:	jne    a380 <c_run_16.isra.0+0x180>
    a36d:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    a372:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    a377:	vaddsd xmm0,xmm0,xmm1
    a37b:	nop    DWORD PTR [rax+rax*1+0x0]
    a380:	vmovsd QWORD PTR [rdi],xmm0
    a384:	add    rdi,0x8
    a388:	add    rax,r10
    a38b:	cmp    r9,rdi
    a38e:	jne    a300 <c_run_16.isra.0+0x100>
    a394:	mov    r8d,DWORD PTR [rsp-0x4]
    a399:	add    r9,r13
    a39c:	add    rdx,r10
    a39f:	inc    r8d
    a3a2:	cmp    r15d,r8d
    a3a5:	jne    a2f0 <c_run_16.isra.0+0xf0>
    a3ab:	mov    rdi,QWORD PTR [rsp-0x18]
    a3b0:	mov    rax,QWORD PTR [rbp+0x28]
    a3b4:	mov    rdx,QWORD PTR [rbp+0x10]
    a3b8:	mov    rsi,QWORD PTR [rbp+0x18]
    a3bc:	mov    r8,QWORD PTR [rbp+0x20]
    a3c0:	mov    r9,QWORD PTR [rbp+0x30]
    a3c4:	inc    DWORD PTR [rsp-0x8]
    a3c8:	mov    edx,DWORD PTR [rsp-0x8]
    a3cc:	cmp    DWORD PTR [rsp-0xc],edx
    a3d0:	je     a280 <c_run_16.isra.0+0x80>
    a3d6:	mov    rdx,QWORD PTR [rbp+0x10]
    a3da:	mov    rsi,QWORD PTR [rbp+0x18]
    a3de:	mov    r8,QWORD PTR [rbp+0x20]
    a3e2:	mov    r9,QWORD PTR [rbp+0x30]
    a3e6:	jmp    a2cd <c_run_16.isra.0+0xcd>
    a3eb:	nop    DWORD PTR [rax+rax*1+0x0]
    a3f0:	mov    r8d,ebx
    a3f3:	xor    esi,esi
    a3f5:	vxorpd xmm0,xmm0,xmm0
    a3f9:	cmp    r8d,0x3
    a3fd:	jne    a35d <c_run_16.isra.0+0x15d>
    a403:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    a408:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    a40d:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x8]
    a413:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x8]
    a419:	vaddsd xmm1,xmm1,xmm2
    a41d:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x10]
    a423:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x10]
    a429:	vaddsd xmm1,xmm1,xmm2
    a42d:	vaddsd xmm0,xmm0,xmm1
    a431:	jmp    a380 <c_run_16.isra.0+0x180>
    a436:	cs nop WORD PTR [rax+rax*1+0x0]
    a440:	vmovsd xmm1,QWORD PTR [rdx+rsi*8]
    a445:	vmulsd xmm1,xmm1,QWORD PTR [rax+rsi*8]
    a44a:	vmovsd xmm2,QWORD PTR [rdx+rsi*8+0x8]
    a450:	vmulsd xmm2,xmm2,QWORD PTR [rax+rsi*8+0x8]
    a456:	vaddsd xmm1,xmm1,xmm2
    a45a:	vaddsd xmm0,xmm0,xmm1
    a45e:	jmp    a380 <c_run_16.isra.0+0x180>
    a463:	mov    rdx,QWORD PTR [rbp+0x10]
    a467:	mov    rcx,QWORD PTR [rbp+0x18]
    a46b:	mov    rsi,QWORD PTR [rbp+0x20]
    a46f:	mov    r8,QWORD PTR [rbp+0x30]
    a473:	mov    ebx,DWORD PTR [rsp-0xc]
    a477:	lea    r9d,[r15+0x1]
    a47b:	cmp    ebx,r9d
    a47e:	je     a283 <c_run_16.isra.0+0x83>
    a484:	add    r15d,0x2
    a488:	cmp    ebx,r15d
    a48b:	je     a283 <c_run_16.isra.0+0x83>
    a491:	jmp    a473 <c_run_16.isra.0+0x273>
    a493:	xchg   ax,ax
    a495:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_17.isra.0>:
    a5e0:	push   rbp
    a5e1:	mov    rbp,rsp
    a5e4:	push   r15
    a5e6:	push   r14
    a5e8:	push   r13
    a5ea:	push   r12
    a5ec:	push   rbx
    a5ed:	and    rsp,0xffffffffffffffe0
    a5f1:	sub    rsp,0x60
    a5f5:	mov    QWORD PTR [rsp+0x48],rcx
    a5fa:	mov    QWORD PTR [rsp+0x30],r8
    a5ff:	mov    QWORD PTR [rsp+0x28],r9
    a604:	test   edx,edx
    a606:	je     a945 <c_run_17.isra.0+0x365>
    a60c:	mov    eax,esi
    a60e:	mov    r13d,esi
    a611:	mov    DWORD PTR [rsp+0x20],edx
    a615:	mov    DWORD PTR [rsp+0x44],esi
    a619:	lea    rbx,[r13*8+0x0]
    a621:	mov    DWORD PTR [rsp+0x40],0x0
    a629:	mov    r15d,edi
    a62c:	imul   eax,esi
    a62f:	mov    QWORD PTR [rsp+0x38],rbx
    a634:	shl    rax,0x3
    a638:	mov    QWORD PTR [rsp+0x18],rax
    a63d:	mov    rax,r13
    a640:	shl    rax,0x4
    a644:	mov    QWORD PTR [rsp+0x10],rax
    a649:	mov    rax,QWORD PTR [rsp+0x48]
    a64e:	mov    rdi,QWORD PTR [rsp+0x30]
    a653:	mov    rsi,QWORD PTR [rsp+0x28]
    a658:	mov    rbx,QWORD PTR [rbp+0x10]
    a65c:	mov    rdx,QWORD PTR [rbp+0x18]
    a660:	mov    rcx,QWORD PTR [rbp+0x20]
    a664:	mov    r14,QWORD PTR [rbp+0x28]
    a668:	mov    rdx,QWORD PTR [rsp+0x18]
    a66d:	mov    rdi,QWORD PTR [rbp+0x20]
    a671:	xor    esi,esi
    a673:	call   2bd0 <memset@plt>
    a678:	mov    eax,DWORD PTR [rsp+0x44]
    a67c:	vxorpd xmm3,xmm3,xmm3
    a680:	test   eax,eax
    a682:	je     a914 <c_run_17.isra.0+0x334>
    a688:	test   r15d,r15d
    a68b:	je     a7c3 <c_run_17.isra.0+0x1e3>
    a691:	mov    QWORD PTR [rsp+0x50],r13
    a696:	mov    r10d,0xfffffffd
    a69c:	xor    r9d,r9d
    a69f:	xor    r8d,r8d
    a6a2:	xor    r12d,r12d
    a6a5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a6b0:	mov    rdi,QWORD PTR [rbp+0x20]
    a6b4:	movsxd rax,r9d
    a6b7:	mov    ecx,r10d
    a6ba:	mov    r13d,r10d
    a6bd:	and    r13d,0xfffffffc
    a6c1:	inc    r12d
    a6c4:	mov    DWORD PTR [rsp+0x5c],r9d
    a6c9:	xor    edx,edx
    a6cb:	add    r13d,0x4
    a6cf:	mov    r9,QWORD PTR [rsp+0x38]
    a6d4:	mov    r14d,r12d
    a6d7:	sub    r14d,r13d
    a6da:	shr    ecx,0x2
    a6dd:	lea    rsi,[rdi+rax*8]
    a6e1:	mov    rax,QWORD PTR [rsp+0x48]
    a6e6:	shl    rcx,0x5
    a6ea:	lea    rdi,[rsi+rcx*1+0x20]
    a6ef:	sub    rax,rsi
    a6f2:	jmp    a70e <c_run_17.isra.0+0x12e>
    a6f4:	nop
    a6f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a700:	inc    edx
    a702:	add    rax,r9
    a705:	cmp    r15d,edx
    a708:	je     a7a0 <c_run_17.isra.0+0x1c0>
    a70e:	lea    r11,[rsi+rax*1]
    a712:	vmovsd xmm1,QWORD PTR [r11+r8*8]
    a718:	vcomisd xmm1,xmm3
    a71c:	je     a700 <c_run_17.isra.0+0x120>
    a71e:	test   r10d,r10d
    a721:	js     a960 <c_run_17.isra.0+0x380>
    a727:	vbroadcastsd ymm2,xmm1
    a72c:	mov    rcx,rsi
    a72f:	nop    WORD PTR [rax+rax*1+0x0]
    a735:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a740:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
    a745:	add    rcx,0x20
    a749:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    a74e:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
    a753:	cmp    rdi,rcx
    a756:	jne    a740 <c_run_17.isra.0+0x160>
    a758:	mov    ebx,r14d
    a75b:	mov    ecx,r13d
    a75e:	cmp    ebx,0x3
    a761:	je     a96e <c_run_17.isra.0+0x38e>
    a767:	cmp    ebx,0x2
    a76a:	je     a9b0 <c_run_17.isra.0+0x3d0>
    a770:	cmp    ebx,0x1
    a773:	jne    a700 <c_run_17.isra.0+0x120>
    a775:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*8]
    a77b:	inc    edx
    a77d:	add    rax,r9
    a780:	vaddsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    a785:	vmovsd QWORD PTR [rsi+rcx*8],xmm1
    a78a:	cmp    r15d,edx
    a78d:	jne    a70e <c_run_17.isra.0+0x12e>
    a793:	xchg   ax,ax
    a795:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a7a0:	mov    r9d,DWORD PTR [rsp+0x5c]
    a7a5:	mov    eax,DWORD PTR [rsp+0x44]
    a7a9:	inc    r8
    a7ac:	inc    r10d
    a7af:	add    r9d,eax
    a7b2:	cmp    eax,r12d
    a7b5:	jne    a6b0 <c_run_17.isra.0+0xd0>
    a7bb:	mov    r13,QWORD PTR [rsp+0x50]
    a7c0:	vzeroupper
    a7c3:	mov    r14d,DWORD PTR [rsp+0x44]
    a7c8:	cmp    r14d,0x1
    a7cc:	je     a914 <c_run_17.isra.0+0x334>
    a7d2:	mov    rax,QWORD PTR [rbp+0x20]
    a7d6:	mov    DWORD PTR [rsp+0x24],r15d
    a7db:	mov    DWORD PTR [rsp+0x50],0x0
    a7e3:	mov    rcx,QWORD PTR [rsp+0x10]
    a7e8:	mov    r15,QWORD PTR [rsp+0x38]
    a7ed:	lea    r11d,[r14-0x1]
    a7f1:	mov    r9d,0x8
    a7f7:	mov    esi,0x1
    a7fc:	xor    r12d,r12d
    a7ff:	lea    r8,[rax+0x8]
    a803:	mov    rdi,rax
    a806:	cs nop WORD PTR [rax+rax*1+0x0]
    a810:	mov    DWORD PTR [rsp+0x5c],r11d
    a815:	dec    r11d
    a818:	mov    eax,DWORD PTR [rsp+0x50]
    a81c:	cmp    r11d,0xe
    a820:	jbe    a9dc <c_run_17.isra.0+0x3fc>
    a826:	cmp    r14d,esi
    a829:	jle    a9dc <c_run_17.isra.0+0x3fc>
    a82f:	lea    r10d,[rax+r14*1]
    a833:	mov    eax,DWORD PTR [rsp+0x5c]
    a837:	mov    DWORD PTR [rsp+0x58],r10d
    a83c:	add    r10,r12
    a83f:	lea    rbx,[rax-0x1]
    a843:	lea    rax,[r10*8+0x0]
    a84b:	mov    rdx,rbx
    a84e:	imul   rdx,r13
    a852:	add    rdx,r10
    a855:	shl    rdx,0x3
    a859:	cmp    rdx,r9
    a85c:	jl     a86b <c_run_17.isra.0+0x28b>
    a85e:	lea    rdx,[r9+rbx*8]
    a862:	cmp    rax,rdx
    a865:	jle    a9e3 <c_run_17.isra.0+0x403>
    a86b:	mov    r10d,DWORD PTR [rsp+0x5c]
    a870:	add    rax,QWORD PTR [rbp+0x20]
    a874:	shr    r10d,1
    a877:	mov    edx,r10d
    a87a:	shl    rdx,0x4
    a87e:	lea    rbx,[rdx+r8*1]
    a882:	mov    rdx,r8
    a885:	nop    DWORD PTR [rax+rax*1+0x0]
    a88a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a895:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a8a0:	vmovsd xmm0,QWORD PTR [rax]
    a8a4:	vmovhpd xmm0,xmm0,QWORD PTR [rax+r13*8]
    a8aa:	add    rdx,0x10
    a8ae:	add    rax,rcx
    a8b1:	vmovupd XMMWORD PTR [rdx-0x10],xmm0
    a8b6:	cmp    rbx,rdx
    a8b9:	jne    a8a0 <c_run_17.isra.0+0x2c0>
    a8bb:	add    r10d,r10d
    a8be:	cmp    r10d,DWORD PTR [rsp+0x5c]
    a8c3:	je     a8eb <c_run_17.isra.0+0x30b>
    a8c5:	add    r10d,esi
    a8c8:	mov    eax,r14d
    a8cb:	mov    rbx,QWORD PTR [rbp+0x20]
    a8cf:	imul   eax,r10d
    a8d3:	add    eax,r12d
    a8d6:	mov    eax,eax
    a8d8:	vmovsd xmm0,QWORD PTR [rbx+rax*8]
    a8dd:	mov    eax,DWORD PTR [rsp+0x50]
    a8e1:	add    eax,r10d
    a8e4:	mov    eax,eax
    a8e6:	vmovsd QWORD PTR [rbx+rax*8],xmm0
    a8eb:	mov    eax,DWORD PTR [rsp+0x58]
    a8ef:	inc    rsi
    a8f2:	inc    r12
    a8f5:	add    rdi,r15
    a8f8:	lea    r9,[r15+r9*1+0x8]
    a8fd:	lea    r8,[r15+r8*1+0x8]
    a902:	mov    DWORD PTR [rsp+0x50],eax
    a906:	cmp    r13,rsi
    a909:	jne    a810 <c_run_17.isra.0+0x230>
    a90f:	mov    r15d,DWORD PTR [rsp+0x24]
    a914:	mov    rax,QWORD PTR [rsp+0x48]
    a919:	mov    rdi,QWORD PTR [rsp+0x30]
    a91e:	mov    rsi,QWORD PTR [rsp+0x28]
    a923:	mov    rbx,QWORD PTR [rbp+0x10]
    a927:	mov    rdx,QWORD PTR [rbp+0x18]
    a92b:	mov    rcx,QWORD PTR [rbp+0x20]
    a92f:	mov    r14,QWORD PTR [rbp+0x28]
    a933:	inc    DWORD PTR [rsp+0x40]
    a937:	mov    edi,DWORD PTR [rsp+0x20]
    a93b:	cmp    DWORD PTR [rsp+0x40],edi
    a93f:	jne    a649 <c_run_17.isra.0+0x69>
    a945:	lea    rsp,[rbp-0x28]
    a949:	pop    rbx
    a94a:	pop    r12
    a94c:	pop    r13
    a94e:	pop    r14
    a950:	pop    r15
    a952:	pop    rbp
    a953:	ret
    a954:	nop
    a955:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    a960:	mov    ebx,r12d
    a963:	xor    ecx,ecx
    a965:	cmp    ebx,0x3
    a968:	jne    a767 <c_run_17.isra.0+0x187>
    a96e:	shl    rcx,0x3
    a972:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    a978:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    a97d:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    a982:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1+0x8]
    a989:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rsi*1+0x8]
    a98f:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm0
    a995:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x10]
    a99c:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x10]
    a9a2:	vmovsd QWORD PTR [rcx+rsi*1+0x10],xmm1
    a9a8:	jmp    a700 <c_run_17.isra.0+0x120>
    a9ad:	nop    DWORD PTR [rax]
    a9b0:	shl    rcx,0x3
    a9b4:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    a9ba:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    a9bf:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    a9c4:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x8]
    a9cb:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x8]
    a9d1:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm1
    a9d7:	jmp    a700 <c_run_17.isra.0+0x120>
    a9dc:	add    eax,r14d
    a9df:	mov    DWORD PTR [rsp+0x58],eax
    a9e3:	mov    eax,DWORD PTR [rsp+0x58]
    a9e7:	mov    rbx,QWORD PTR [rbp+0x20]
    a9eb:	add    rax,r12
    a9ee:	lea    rdx,[rbx+rax*8]
    a9f2:	mov    rax,rsi
    a9f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aa00:	vmovsd xmm0,QWORD PTR [rdx]
    aa04:	add    rdx,r15
    aa07:	vmovsd QWORD PTR [rdi+rax*8],xmm0
    aa0c:	inc    rax
    aa0f:	cmp    r14d,eax
    aa12:	jg     aa00 <c_run_17.isra.0+0x420>
    aa14:	jmp    a8eb <c_run_17.isra.0+0x30b>
    aa19:	nop    DWORD PTR [rax+0x0]


<c_run_18.isra.0>:
    aa20:	push   rbp
    aa21:	mov    rbp,rsp
    aa24:	push   r15
    aa26:	push   r14
    aa28:	push   r13
    aa2a:	push   r12
    aa2c:	push   rbx
    aa2d:	mov    r15,rcx
    aa30:	and    rsp,0xffffffffffffffe0
    aa34:	sub    rsp,0x60
    aa38:	mov    rcx,QWORD PTR [rbp+0x18]
    aa3c:	mov    QWORD PTR [rsp+0x40],r8
    aa41:	mov    QWORD PTR [rsp+0x38],r9
    aa46:	test   edx,edx
    aa48:	je     adba <c_run_18.isra.0+0x39a>
    aa4e:	mov    ebx,esi
    aa50:	mov    DWORD PTR [rsp+0x24],edx
    aa54:	mov    DWORD PTR [rsp+0x48],edi
    aa58:	mov    DWORD PTR [rsp+0x4c],0x0
    aa60:	mov    eax,ebx
    aa62:	mov    r14,rbx
    aa65:	shl    r14,0x4
    aa69:	imul   eax,ebx
    aa6c:	mov    QWORD PTR [rsp+0x8],r14
    aa71:	mov    r13,rbx
    aa74:	shl    rax,0x3
    aa78:	mov    QWORD PTR [rsp+0x28],rax
    aa7d:	mov    eax,edi
    aa7f:	lea    rax,[rcx+rax*8]
    aa83:	mov    QWORD PTR [rsp+0x18],rax
    aa88:	lea    rax,[rbx*8+0x0]
    aa90:	mov    QWORD PTR [rsp+0x10],rax
    aa95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aaa0:	mov    rax,QWORD PTR [rsp+0x40]
    aaa5:	mov    rdi,QWORD PTR [rsp+0x38]
    aaaa:	mov    rsi,QWORD PTR [rbp+0x10]
    aaae:	mov    rdx,QWORD PTR [rbp+0x20]
    aab2:	mov    r8,QWORD PTR [rbp+0x28]
    aab6:	mov    rdx,QWORD PTR [rsp+0x28]
    aabb:	mov    rdi,QWORD PTR [rbp+0x20]
    aabf:	xor    esi,esi
    aac1:	mov    QWORD PTR [rbp+0x18],rcx
    aac5:	call   2bd0 <memset@plt>
    aaca:	mov    eax,DWORD PTR [rsp+0x48]
    aace:	mov    rcx,QWORD PTR [rbp+0x18]
    aad2:	vxorpd xmm3,xmm3,xmm3
    aad6:	test   eax,eax
    aad8:	je     ac36 <c_run_18.isra.0+0x216>
    aade:	mov    r11,QWORD PTR [rsp+0x18]
    aae3:	mov    r9,rcx
    aae6:	xor    eax,eax
    aae8:	mov    rdx,rcx
    aaeb:	jmp    ab10 <c_run_18.isra.0+0xf0>
    aaed:	nop    DWORD PTR [rax+rax*1+0x0]
    aaf5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ab00:	add    r9,0x8
    ab04:	add    eax,r13d
    ab07:	cmp    r11,r9
    ab0a:	je     ac30 <c_run_18.isra.0+0x210>
    ab10:	vcomisd xmm3,QWORD PTR [r9]
    ab15:	je     ab00 <c_run_18.isra.0+0xe0>
    ab17:	test   r13d,r13d
    ab1a:	je     adc9 <c_run_18.isra.0+0x3a9>
    ab20:	mov    ecx,eax
    ab22:	mov    QWORD PTR [rsp+0x58],r11
    ab27:	mov    DWORD PTR [rsp+0x54],eax
    ab2b:	mov    edi,0xfffffffd
    ab30:	lea    r10,[r15+rcx*8]
    ab34:	xor    r8d,r8d
    ab37:	mov    ecx,0x1
    ab3c:	jmp    ab51 <c_run_18.isra.0+0x131>
    ab3e:	xchg   ax,ax
    ab40:	add    r8d,r13d
    ab43:	inc    edi
    ab45:	cmp    rcx,rbx
    ab48:	je     ac00 <c_run_18.isra.0+0x1e0>
    ab4e:	inc    rcx
    ab51:	vmovsd xmm0,QWORD PTR [r10+rcx*8-0x8]
    ab58:	vcomisd xmm0,xmm3
    ab5c:	je     ab40 <c_run_18.isra.0+0x120>
    ab5e:	mov    rsi,QWORD PTR [rbp+0x20]
    ab62:	mov    eax,r8d
    ab65:	vmulsd xmm1,xmm0,QWORD PTR [r9]
    ab6a:	mov    r12d,ecx
    ab6d:	lea    r14,[rsi+rax*8]
    ab71:	xor    eax,eax
    ab73:	test   edi,edi
    ab75:	js     abc2 <c_run_18.isra.0+0x1a2>
    ab77:	mov    eax,edi
    ab79:	mov    rsi,r14
    ab7c:	sub    rsi,r10
    ab7f:	vbroadcastsd ymm2,xmm1
    ab84:	shr    eax,0x2
    ab87:	shl    rax,0x5
    ab8b:	lea    r11,[r10+rax*1+0x20]
    ab90:	mov    rax,r10
    ab93:	xchg   ax,ax
    ab95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aba0:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    aba4:	vaddpd ymm0,ymm0,YMMWORD PTR [rsi+rax*1]
    aba9:	vmovupd YMMWORD PTR [rsi+rax*1],ymm0
    abae:	add    rax,0x20
    abb2:	cmp    r11,rax
    abb5:	jne    aba0 <c_run_18.isra.0+0x180>
    abb7:	mov    eax,edi
    abb9:	and    eax,0xfffffffc
    abbc:	add    eax,0x4
    abbf:	sub    r12d,eax
    abc2:	cmp    r12d,0x3
    abc6:	je     adf0 <c_run_18.isra.0+0x3d0>
    abcc:	cmp    r12d,0x2
    abd0:	je     ae40 <c_run_18.isra.0+0x420>
    abd6:	cmp    r12d,0x1
    abda:	jne    ab40 <c_run_18.isra.0+0x120>
    abe0:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*8]
    abe6:	add    r8d,r13d
    abe9:	inc    edi
    abeb:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*8]
    abf1:	vmovsd QWORD PTR [r14+rax*8],xmm1
    abf7:	cmp    rcx,rbx
    abfa:	jne    ab4e <c_run_18.isra.0+0x12e>
    ac00:	mov    r11,QWORD PTR [rsp+0x58]
    ac05:	add    r9,0x8
    ac09:	mov    eax,DWORD PTR [rsp+0x54]
    ac0d:	cmp    r9,r11
    ac10:	je     ac30 <c_run_18.isra.0+0x210>
    ac12:	add    eax,r13d
    ac15:	vcomisd xmm3,QWORD PTR [r9]
    ac1a:	jne    ab20 <c_run_18.isra.0+0x100>
    ac20:	add    r9,0x8
    ac24:	add    eax,r13d
    ac27:	cmp    r11,r9
    ac2a:	jne    ab10 <c_run_18.isra.0+0xf0>
    ac30:	mov    rcx,rdx
    ac33:	vzeroupper
    ac36:	test   r13d,r13d
    ac39:	je     ad92 <c_run_18.isra.0+0x372>
    ac3f:	cmp    r13d,0x1
    ac43:	je     ad92 <c_run_18.isra.0+0x372>
    ac49:	mov    rax,QWORD PTR [rbp+0x20]
    ac4d:	mov    DWORD PTR [rsp+0x54],0x0
    ac55:	mov    r14,QWORD PTR [rsp+0x8]
    ac5a:	mov    rdi,QWORD PTR [rsp+0x10]
    ac5f:	mov    QWORD PTR [rsp+0x30],r15
    ac64:	mov    QWORD PTR [rbp+0x18],rcx
    ac68:	mov    r11d,0x8
    ac6e:	mov    esi,0x1
    ac73:	xor    r9d,r9d
    ac76:	lea    r12d,[r13-0x1]
    ac7a:	lea    r10,[rax+0x8]
    ac7e:	mov    r8,rax
    ac81:	nop    DWORD PTR [rax+0x0]
    ac85:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ac90:	mov    DWORD PTR [rsp+0x58],r12d
    ac95:	dec    r12d
    ac98:	mov    eax,DWORD PTR [rsp+0x54]
    ac9c:	cmp    r12d,0xe
    aca0:	jbe    ae70 <c_run_18.isra.0+0x450>
    aca6:	cmp    r13d,esi
    aca9:	jle    ae70 <c_run_18.isra.0+0x450>
    acaf:	mov    r15d,DWORD PTR [rsp+0x58]
    acb4:	lea    ecx,[rax+r13*1]
    acb8:	mov    DWORD PTR [rsp+0x50],ecx
    acbc:	add    rcx,r9
    acbf:	lea    rax,[rcx*8+0x0]
    acc7:	dec    r15
    acca:	mov    rdx,r15
    accd:	imul   rdx,rbx
    acd1:	add    rdx,rcx
    acd4:	shl    rdx,0x3
    acd8:	cmp    rdx,r11
    acdb:	jl     acea <c_run_18.isra.0+0x2ca>
    acdd:	lea    rdx,[r11+r15*8]
    ace1:	cmp    rax,rdx
    ace4:	jle    ae77 <c_run_18.isra.0+0x457>
    acea:	mov    ecx,DWORD PTR [rsp+0x58]
    acee:	add    rax,QWORD PTR [rbp+0x20]
    acf2:	mov    rdx,r10
    acf5:	shr    ecx,1
    acf7:	mov    r15d,ecx
    acfa:	shl    r15,0x4
    acfe:	add    r15,r10
    ad01:	nop    WORD PTR [rax+rax*1+0x0]
    ad0a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ad15:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ad20:	vmovsd xmm0,QWORD PTR [rax]
    ad24:	vmovhpd xmm0,xmm0,QWORD PTR [rax+rbx*8]
    ad29:	add    rdx,0x10
    ad2d:	add    rax,r14
    ad30:	vmovupd XMMWORD PTR [rdx-0x10],xmm0
    ad35:	cmp    r15,rdx
    ad38:	jne    ad20 <c_run_18.isra.0+0x300>
    ad3a:	add    ecx,ecx
    ad3c:	cmp    ecx,DWORD PTR [rsp+0x58]
    ad40:	je     ad65 <c_run_18.isra.0+0x345>
    ad42:	add    ecx,esi
    ad44:	mov    eax,r13d
    ad47:	mov    rdx,QWORD PTR [rbp+0x20]
    ad4b:	imul   eax,ecx
    ad4e:	add    eax,r9d
    ad51:	mov    eax,eax
    ad53:	vmovsd xmm0,QWORD PTR [rdx+rax*8]
    ad58:	mov    eax,DWORD PTR [rsp+0x54]
    ad5c:	add    eax,ecx
    ad5e:	mov    eax,eax
    ad60:	vmovsd QWORD PTR [rdx+rax*8],xmm0
    ad65:	mov    eax,DWORD PTR [rsp+0x50]
    ad69:	inc    rsi
    ad6c:	inc    r9
    ad6f:	add    r8,rdi
    ad72:	lea    r11,[r11+rdi*1+0x8]
    ad77:	lea    r10,[r10+rdi*1+0x8]
    ad7c:	mov    DWORD PTR [rsp+0x54],eax
    ad80:	cmp    rbx,rsi
    ad83:	jne    ac90 <c_run_18.isra.0+0x270>
    ad89:	mov    r15,QWORD PTR [rsp+0x30]
    ad8e:	mov    rcx,QWORD PTR [rbp+0x18]
    ad92:	mov    rax,QWORD PTR [rsp+0x40]
    ad97:	mov    rdi,QWORD PTR [rsp+0x38]
    ad9c:	mov    rsi,QWORD PTR [rbp+0x10]
    ada0:	mov    rdx,QWORD PTR [rbp+0x20]
    ada4:	mov    r8,QWORD PTR [rbp+0x28]
    ada8:	inc    DWORD PTR [rsp+0x4c]
    adac:	mov    edi,DWORD PTR [rsp+0x24]
    adb0:	cmp    DWORD PTR [rsp+0x4c],edi
    adb4:	jne    aaa0 <c_run_18.isra.0+0x80>
    adba:	lea    rsp,[rbp-0x28]
    adbe:	pop    rbx
    adbf:	pop    r12
    adc1:	pop    r13
    adc3:	pop    r14
    adc5:	pop    r15
    adc7:	pop    rbp
    adc8:	ret
    adc9:	lea    rcx,[r9+0x8]
    adcd:	cmp    r11,rcx
    add0:	je     aeba <c_run_18.isra.0+0x49a>
    add6:	add    r9,0x10
    adda:	cmp    r9,r11
    addd:	je     aeba <c_run_18.isra.0+0x49a>
    ade3:	vcomisd xmm3,QWORD PTR [r9]
    ade8:	je     ab00 <c_run_18.isra.0+0xe0>
    adee:	jmp    adc9 <c_run_18.isra.0+0x3a9>
    adf0:	shl    rax,0x3
    adf4:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1]
    adfa:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1]
    ae00:	vmovsd QWORD PTR [r14+rax*1],xmm0
    ae06:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1+0x8]
    ae0d:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1+0x8]
    ae14:	vmovsd QWORD PTR [r14+rax*1+0x8],xmm0
    ae1b:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*1+0x10]
    ae22:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*1+0x10]
    ae29:	vmovsd QWORD PTR [r14+rax*1+0x10],xmm1
    ae30:	jmp    ab40 <c_run_18.isra.0+0x120>
    ae35:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ae40:	shl    rax,0x3
    ae44:	vmulsd xmm0,xmm1,QWORD PTR [r10+rax*1]
    ae4a:	vaddsd xmm0,xmm0,QWORD PTR [r14+rax*1]
    ae50:	vmovsd QWORD PTR [r14+rax*1],xmm0
    ae56:	vmulsd xmm1,xmm1,QWORD PTR [r10+rax*1+0x8]
    ae5d:	vaddsd xmm1,xmm1,QWORD PTR [r14+rax*1+0x8]
    ae64:	vmovsd QWORD PTR [r14+rax*1+0x8],xmm1
    ae6b:	jmp    ab40 <c_run_18.isra.0+0x120>
    ae70:	add    eax,r13d
    ae73:	mov    DWORD PTR [rsp+0x50],eax
    ae77:	mov    eax,DWORD PTR [rsp+0x50]
    ae7b:	mov    rcx,QWORD PTR [rbp+0x20]
    ae7f:	add    rax,r9
    ae82:	lea    rdx,[rcx+rax*8]
    ae86:	mov    rax,rsi
    ae89:	nop
    ae8a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    ae95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    aea0:	vmovsd xmm0,QWORD PTR [rdx]
    aea4:	add    rdx,rdi
    aea7:	vmovsd QWORD PTR [r8+rax*8],xmm0
    aead:	inc    rax
    aeb0:	cmp    r13d,eax
    aeb3:	jg     aea0 <c_run_18.isra.0+0x480>
    aeb5:	jmp    ad65 <c_run_18.isra.0+0x345>
    aeba:	mov    rcx,rdx
    aebd:	vzeroupper
    aec0:	jmp    ad92 <c_run_18.isra.0+0x372>
    aec5:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_19.isra.0>:
    aed0:	push   rbp
    aed1:	mov    rbp,rsp
    aed4:	push   r15
    aed6:	push   r14
    aed8:	push   r13
    aeda:	push   r12
    aedc:	push   rbx
    aedd:	and    rsp,0xffffffffffffffe0
    aee1:	sub    rsp,0x40
    aee5:	mov    r12,QWORD PTR [rbp+0x20]
    aee9:	mov    QWORD PTR [rsp+0x28],r8
    aeee:	mov    QWORD PTR [rsp+0x20],r9
    aef3:	mov    r8,QWORD PTR [rbp+0x18]
    aef7:	test   edx,edx
    aef9:	je     b114 <c_run_19.isra.0+0x244>
    aeff:	mov    eax,esi
    af01:	mov    DWORD PTR [rsp+0x18],edx
    af05:	mov    DWORD PTR [rsp+0xc],edi
    af09:	mov    ebx,esi
    af0b:	xor    r13d,r13d
    af0e:	imul   eax,esi
    af11:	shl    rax,0x3
    af15:	mov    QWORD PTR [rsp+0x10],rax
    af1a:	mov    eax,edi
    af1c:	lea    r15,[r8+rax*8]
    af20:	lea    eax,[rsi+0x1]
    af23:	mov    DWORD PTR [rsp+0x8],eax
    af27:	nop    WORD PTR [rax+rax*1+0x0]
    af30:	mov    rax,QWORD PTR [rsp+0x28]
    af35:	mov    rdi,QWORD PTR [rsp+0x20]
    af3a:	mov    rdx,QWORD PTR [rbp+0x10]
    af3e:	mov    rsi,QWORD PTR [rbp+0x28]
    af42:	mov    rdx,QWORD PTR [rsp+0x10]
    af47:	xor    esi,esi
    af49:	mov    rdi,r12
    af4c:	mov    QWORD PTR [rbp+0x18],r8
    af50:	mov    QWORD PTR [rsp+0x38],rcx
    af55:	call   2bd0 <memset@plt>
    af5a:	mov    eax,DWORD PTR [rsp+0xc]
    af5e:	mov    rcx,QWORD PTR [rsp+0x38]
    af63:	mov    r8,QWORD PTR [rbp+0x18]
    af67:	vxorpd xmm3,xmm3,xmm3
    af6b:	test   eax,eax
    af6d:	je     b0f4 <c_run_19.isra.0+0x224>
    af73:	mov    r14d,DWORD PTR [rsp+0x8]
    af78:	mov    DWORD PTR [rsp+0x1c],r13d
    af7d:	mov    QWORD PTR [rbp+0x20],r12
    af81:	mov    r9,r8
    af84:	xor    eax,eax
    af86:	mov    rdx,rcx
    af89:	jmp    afaf <c_run_19.isra.0+0xdf>
    af8b:	cs nop WORD PTR [rax+rax*1+0x0]
    af95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    afa0:	add    r9,0x8
    afa4:	add    eax,ebx
    afa6:	cmp    r15,r9
    afa9:	je     b0e5 <c_run_19.isra.0+0x215>
    afaf:	vcomisd xmm3,QWORD PTR [r9]
    afb4:	je     afa0 <c_run_19.isra.0+0xd0>
    afb6:	test   ebx,ebx
    afb8:	je     b123 <c_run_19.isra.0+0x253>
    afbe:	mov    QWORD PTR [rsp+0x30],r15
    afc3:	mov    rdi,r8
    afc6:	mov    esi,eax
    afc8:	mov    DWORD PTR [rsp+0x38],eax
    afcc:	mov    r8d,0xfffffffd
    afd2:	xor    r10d,r10d
    afd5:	lea    r11,[rdx+rsi*8]
    afd9:	mov    esi,0x1
    afde:	jmp    aff2 <c_run_19.isra.0+0x122>
    afe0:	inc    rsi
    afe3:	add    r10d,ebx
    afe6:	inc    r8d
    afe9:	cmp    r14,rsi
    afec:	je     b0b0 <c_run_19.isra.0+0x1e0>
    aff2:	vmovsd xmm0,QWORD PTR [r11+rsi*8-0x8]
    aff9:	vcomisd xmm0,xmm3
    affd:	je     afe0 <c_run_19.isra.0+0x110>
    afff:	mov    rcx,QWORD PTR [rbp+0x20]
    b003:	mov    eax,r10d
    b006:	vmulsd xmm1,xmm0,QWORD PTR [r9]
    b00b:	mov    r13d,esi
    b00e:	lea    r15,[rcx+rax*8]
    b012:	xor    eax,eax
    b014:	test   r8d,r8d
    b017:	js     b063 <c_run_19.isra.0+0x193>
    b019:	mov    eax,r8d
    b01c:	mov    rcx,r15
    b01f:	sub    rcx,r11
    b022:	vbroadcastsd ymm2,xmm1
    b027:	shr    eax,0x2
    b02a:	shl    rax,0x5
    b02e:	lea    r12,[r11+rax*1+0x20]
    b033:	mov    rax,r11
    b036:	cs nop WORD PTR [rax+rax*1+0x0]
    b040:	vmulpd ymm0,ymm2,YMMWORD PTR [rax]
    b044:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx+rax*1]
    b049:	vmovupd YMMWORD PTR [rcx+rax*1],ymm0
    b04e:	add    rax,0x20
    b052:	cmp    r12,rax
    b055:	jne    b040 <c_run_19.isra.0+0x170>
    b057:	mov    eax,r8d
    b05a:	and    eax,0xfffffffc
    b05d:	add    eax,0x4
    b060:	sub    r13d,eax
    b063:	cmp    r13d,0x3
    b067:	je     b150 <c_run_19.isra.0+0x280>
    b06d:	cmp    r13d,0x2
    b071:	je     b1a0 <c_run_19.isra.0+0x2d0>
    b077:	cmp    r13d,0x1
    b07b:	jne    afe0 <c_run_19.isra.0+0x110>
    b081:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*8]
    b087:	inc    rsi
    b08a:	add    r10d,ebx
    b08d:	inc    r8d
    b090:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*8]
    b096:	vmovsd QWORD PTR [r15+rax*8],xmm1
    b09c:	cmp    r14,rsi
    b09f:	jne    aff2 <c_run_19.isra.0+0x122>
    b0a5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b0b0:	mov    r15,QWORD PTR [rsp+0x30]
    b0b5:	add    r9,0x8
    b0b9:	mov    eax,DWORD PTR [rsp+0x38]
    b0bd:	cmp    r9,r15
    b0c0:	je     b1d0 <c_run_19.isra.0+0x300>
    b0c6:	add    eax,ebx
    b0c8:	vcomisd xmm3,QWORD PTR [r9]
    b0cd:	jne    afc6 <c_run_19.isra.0+0xf6>
    b0d3:	add    r9,0x8
    b0d7:	mov    r8,rdi
    b0da:	add    eax,ebx
    b0dc:	cmp    r15,r9
    b0df:	jne    afaf <c_run_19.isra.0+0xdf>
    b0e5:	mov    r13d,DWORD PTR [rsp+0x1c]
    b0ea:	mov    r12,QWORD PTR [rbp+0x20]
    b0ee:	mov    rcx,rdx
    b0f1:	vzeroupper
    b0f4:	mov    rax,QWORD PTR [rsp+0x28]
    b0f9:	mov    rdi,QWORD PTR [rsp+0x20]
    b0fe:	mov    rdx,QWORD PTR [rbp+0x10]
    b102:	mov    rsi,QWORD PTR [rbp+0x28]
    b106:	inc    r13d
    b109:	cmp    r13d,DWORD PTR [rsp+0x18]
    b10e:	jne    af30 <c_run_19.isra.0+0x60>
    b114:	lea    rsp,[rbp-0x28]
    b118:	pop    rbx
    b119:	pop    r12
    b11b:	pop    r13
    b11d:	pop    r14
    b11f:	pop    r15
    b121:	pop    rbp
    b122:	ret
    b123:	lea    rcx,[r9+0x8]
    b127:	cmp    r15,rcx
    b12a:	je     b0e5 <c_run_19.isra.0+0x215>
    b12c:	add    r9,0x10
    b130:	cmp    r9,r15
    b133:	je     b0e5 <c_run_19.isra.0+0x215>
    b135:	vcomisd xmm3,QWORD PTR [r9]
    b13a:	je     afa0 <c_run_19.isra.0+0xd0>
    b140:	jmp    b123 <c_run_19.isra.0+0x253>
    b142:	nop    DWORD PTR [rax]
    b145:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b150:	shl    rax,0x3
    b154:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1]
    b15a:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    b160:	vmovsd QWORD PTR [r15+rax*1],xmm0
    b166:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1+0x8]
    b16d:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1+0x8]
    b174:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm0
    b17b:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*1+0x10]
    b182:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x10]
    b189:	vmovsd QWORD PTR [r15+rax*1+0x10],xmm1
    b190:	jmp    afe0 <c_run_19.isra.0+0x110>
    b195:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b1a0:	shl    rax,0x3
    b1a4:	vmulsd xmm0,xmm1,QWORD PTR [r11+rax*1]
    b1aa:	vaddsd xmm0,xmm0,QWORD PTR [r15+rax*1]
    b1b0:	vmovsd QWORD PTR [r15+rax*1],xmm0
    b1b6:	vmulsd xmm1,xmm1,QWORD PTR [r11+rax*1+0x8]
    b1bd:	vaddsd xmm1,xmm1,QWORD PTR [r15+rax*1+0x8]
    b1c4:	vmovsd QWORD PTR [r15+rax*1+0x8],xmm1
    b1cb:	jmp    afe0 <c_run_19.isra.0+0x110>
    b1d0:	mov    r13d,DWORD PTR [rsp+0x1c]
    b1d5:	mov    r12,QWORD PTR [rbp+0x20]
    b1d9:	mov    rcx,rdx
    b1dc:	mov    r8,rdi
    b1df:	vzeroupper
    b1e2:	jmp    b0f4 <c_run_19.isra.0+0x224>
    b1e7:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_2.isra.0>:
    5e50:	mov    r11d,edi
    5e53:	mov    rax,rsi
    5e56:	mov    r10,QWORD PTR [rsp+0x10]
    5e5b:	mov    rsi,rdx
    5e5e:	mov    rdi,rcx
    5e61:	mov    rdx,QWORD PTR [rsp+0x8]
    5e66:	test   r11d,r11d
    5e69:	je     5eda <c_run_2.isra.0+0x8a>
    5e6b:	xor    ecx,ecx
    5e6d:	nop    DWORD PTR [rax]
    5e70:	vmovsd xmm0,QWORD PTR [r8]
    5e75:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x18]
    5e7a:	vmovsd xmm4,QWORD PTR [r8+0x8]
    5e80:	vmovsd xmm3,QWORD PTR [r8+0x10]
    5e86:	vmulsd xmm2,xmm4,QWORD PTR [rax+0x20]
    5e8b:	vmulsd xmm5,xmm4,QWORD PTR [rax+0x38]
    5e90:	vmulsd xmm4,xmm4,QWORD PTR [rax+0x8]
    5e95:	vaddsd xmm1,xmm1,xmm2
    5e99:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x28]
    5e9e:	vaddsd xmm2,xmm1,xmm2
    5ea2:	vmulsd xmm1,xmm0,QWORD PTR [rax+0x30]
    5ea7:	vmulsd xmm0,xmm0,QWORD PTR [rax]
    5eab:	vaddsd xmm1,xmm1,xmm5
    5eaf:	vmulsd xmm5,xmm3,QWORD PTR [rax+0x40]
    5eb4:	vmulsd xmm3,xmm3,QWORD PTR [rax+0x10]
    5eb9:	vaddsd xmm0,xmm0,xmm4
    5ebd:	vmovsd QWORD PTR [rdx+0x8],xmm2
    5ec2:	vaddsd xmm1,xmm1,xmm5
    5ec6:	vaddsd xmm0,xmm0,xmm3
    5eca:	vmovsd QWORD PTR [rdx+0x10],xmm1
    5ecf:	vmovsd QWORD PTR [rdx],xmm0
    5ed3:	inc    ecx
    5ed5:	cmp    ecx,r11d
    5ed8:	jne    5e70 <c_run_2.isra.0+0x20>
    5eda:	ret
    5edb:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_20.isra.0>:
    b1f0:	push   rbp
    b1f1:	mov    rbp,rsp
    b1f4:	push   r15
    b1f6:	push   r14
    b1f8:	push   r13
    b1fa:	push   r12
    b1fc:	push   rbx
    b1fd:	and    rsp,0xffffffffffffffe0
    b201:	sub    rsp,0x40
    b205:	mov    QWORD PTR [rsp+0x30],rcx
    b20a:	mov    QWORD PTR [rsp+0x28],r8
    b20f:	mov    QWORD PTR [rsp+0x20],r9
    b214:	test   edx,edx
    b216:	je     b3f0 <c_run_20.isra.0+0x200>
    b21c:	mov    eax,esi
    b21e:	mov    DWORD PTR [rsp+0x18],edx
    b222:	mov    DWORD PTR [rsp+0x38],esi
    b226:	mov    r12d,esi
    b229:	mov    ebx,edi
    b22b:	xor    r14d,r14d
    b22e:	imul   eax,esi
    b231:	shl    r12,0x3
    b235:	shl    rax,0x3
    b239:	mov    QWORD PTR [rsp+0x10],rax
    b23e:	mov    rax,QWORD PTR [rsp+0x30]
    b243:	mov    rdi,QWORD PTR [rsp+0x28]
    b248:	mov    rsi,QWORD PTR [rsp+0x20]
    b24d:	mov    rdx,QWORD PTR [rbp+0x10]
    b251:	mov    rcx,QWORD PTR [rbp+0x18]
    b255:	mov    r9,QWORD PTR [rbp+0x20]
    b259:	mov    r15,QWORD PTR [rbp+0x28]
    b25d:	mov    rdx,QWORD PTR [rsp+0x10]
    b262:	mov    rdi,QWORD PTR [rbp+0x20]
    b266:	xor    esi,esi
    b268:	call   2bd0 <memset@plt>
    b26d:	mov    eax,DWORD PTR [rsp+0x38]
    b271:	vxorpd xmm3,xmm3,xmm3
    b275:	test   eax,eax
    b277:	je     b3c3 <c_run_20.isra.0+0x1d3>
    b27d:	test   ebx,ebx
    b27f:	je     b3c3 <c_run_20.isra.0+0x1d3>
    b285:	mov    DWORD PTR [rsp+0x1c],r14d
    b28a:	mov    r10d,0xfffffffd
    b290:	xor    r9d,r9d
    b293:	xor    r8d,r8d
    b296:	xor    r13d,r13d
    b299:	nop    DWORD PTR [rax+0x0]
    b2a0:	mov    rdi,QWORD PTR [rbp+0x20]
    b2a4:	movsxd rax,r9d
    b2a7:	mov    ecx,r10d
    b2aa:	mov    r14d,r10d
    b2ad:	and    r14d,0xfffffffc
    b2b1:	inc    r13d
    b2b4:	mov    DWORD PTR [rsp+0x3c],r9d
    b2b9:	xor    edx,edx
    b2bb:	add    r14d,0x4
    b2bf:	shr    ecx,0x2
    b2c2:	lea    rsi,[rdi+rax*8]
    b2c6:	mov    rax,QWORD PTR [rsp+0x30]
    b2cb:	mov    r15d,r13d
    b2ce:	sub    r15d,r14d
    b2d1:	mov    r9d,r14d
    b2d4:	shl    rcx,0x5
    b2d8:	lea    rdi,[rsi+rcx*1+0x20]
    b2dd:	sub    rax,rsi
    b2e0:	jmp    b30d <c_run_20.isra.0+0x11d>
    b2e2:	nop    DWORD PTR [rax+rax*1+0x0]
    b2ea:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b2f5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b300:	inc    edx
    b302:	add    rax,r12
    b305:	cmp    ebx,edx
    b307:	je     b3a0 <c_run_20.isra.0+0x1b0>
    b30d:	lea    r11,[rsi+rax*1]
    b311:	vmovsd xmm1,QWORD PTR [r11+r8*8]
    b317:	vcomisd xmm1,xmm3
    b31b:	je     b300 <c_run_20.isra.0+0x110>
    b31d:	test   r10d,r10d
    b320:	js     b400 <c_run_20.isra.0+0x210>
    b326:	vbroadcastsd ymm2,xmm1
    b32b:	mov    rcx,rsi
    b32e:	nop    DWORD PTR [rax+0x0]
    b335:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b340:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
    b345:	add    rcx,0x20
    b349:	vaddpd ymm0,ymm0,YMMWORD PTR [rcx-0x20]
    b34e:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
    b353:	cmp    rdi,rcx
    b356:	jne    b340 <c_run_20.isra.0+0x150>
    b358:	mov    r14d,r15d
    b35b:	mov    ecx,r9d
    b35e:	cmp    r14d,0x3
    b362:	je     b40f <c_run_20.isra.0+0x21f>
    b368:	cmp    r14d,0x2
    b36c:	je     b450 <c_run_20.isra.0+0x260>
    b372:	cmp    r14d,0x1
    b376:	jne    b300 <c_run_20.isra.0+0x110>
    b378:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*8]
    b37e:	inc    edx
    b380:	add    rax,r12
    b383:	vaddsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    b388:	vmovsd QWORD PTR [rsi+rcx*8],xmm1
    b38d:	cmp    ebx,edx
    b38f:	jne    b30d <c_run_20.isra.0+0x11d>
    b395:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    b3a0:	mov    r9d,DWORD PTR [rsp+0x3c]
    b3a5:	mov    eax,DWORD PTR [rsp+0x38]
    b3a9:	inc    r8
    b3ac:	inc    r10d
    b3af:	add    r9d,eax
    b3b2:	cmp    eax,r13d
    b3b5:	jne    b2a0 <c_run_20.isra.0+0xb0>
    b3bb:	mov    r14d,DWORD PTR [rsp+0x1c]
    b3c0:	vzeroupper
    b3c3:	mov    rax,QWORD PTR [rsp+0x30]
    b3c8:	mov    rdi,QWORD PTR [rsp+0x28]
    b3cd:	mov    rsi,QWORD PTR [rsp+0x20]
    b3d2:	mov    rdx,QWORD PTR [rbp+0x10]
    b3d6:	mov    rcx,QWORD PTR [rbp+0x18]
    b3da:	mov    r9,QWORD PTR [rbp+0x20]
    b3de:	mov    r15,QWORD PTR [rbp+0x28]
    b3e2:	inc    r14d
    b3e5:	cmp    r14d,DWORD PTR [rsp+0x18]
    b3ea:	jne    b23e <c_run_20.isra.0+0x4e>
    b3f0:	lea    rsp,[rbp-0x28]
    b3f4:	pop    rbx
    b3f5:	pop    r12
    b3f7:	pop    r13
    b3f9:	pop    r14
    b3fb:	pop    r15
    b3fd:	pop    rbp
    b3fe:	ret
    b3ff:	nop
    b400:	mov    r14d,r13d
    b403:	xor    ecx,ecx
    b405:	cmp    r14d,0x3
    b409:	jne    b368 <c_run_20.isra.0+0x178>
    b40f:	shl    rcx,0x3
    b413:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    b419:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    b41e:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    b423:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1+0x8]
    b42a:	vaddsd xmm0,xmm0,QWORD PTR [rcx+rsi*1+0x8]
    b430:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm0
    b436:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x10]
    b43d:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x10]
    b443:	vmovsd QWORD PTR [rcx+rsi*1+0x10],xmm1
    b449:	jmp    b300 <c_run_20.isra.0+0x110>
    b44e:	xchg   ax,ax
    b450:	shl    rcx,0x3
    b454:	vmulsd xmm0,xmm1,QWORD PTR [r11+rcx*1]
    b45a:	vaddsd xmm0,xmm0,QWORD PTR [rsi+rcx*1]
    b45f:	vmovsd QWORD PTR [rsi+rcx*1],xmm0
    b464:	vmulsd xmm1,xmm1,QWORD PTR [r11+rcx*1+0x8]
    b46b:	vaddsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x8]
    b471:	vmovsd QWORD PTR [rcx+rsi*1+0x8],xmm1
    b477:	jmp    b300 <c_run_20.isra.0+0x110>
    b47c:	nop    DWORD PTR [rax+0x0]


<c_run_3.isra.0>:
    5ee0:	mov    r11d,edi
    5ee3:	mov    r10,QWORD PTR [rsp+0x10]
    5ee8:	mov    rdi,rdx
    5eeb:	mov    rax,rsi
    5eee:	mov    rdx,QWORD PTR [rsp+0x8]
    5ef3:	test   r11d,r11d
    5ef6:	je     5f60 <c_run_3.isra.0+0x80>
    5ef8:	xor    esi,esi
    5efa:	nop    WORD PTR [rax+rax*1+0x0]
    5f00:	vmovupd xmm0,XMMWORD PTR [r8]
    5f05:	vmovsd xmm1,QWORD PTR [rax+0x10]
    5f0a:	vmovsd xmm3,QWORD PTR [r8+0x10]
    5f10:	vunpckhpd xmm2,xmm0,xmm0
    5f14:	vmulsd xmm2,xmm2,QWORD PTR [rax+0x28]
    5f19:	vmulsd xmm1,xmm1,xmm0
    5f1d:	vaddsd xmm1,xmm1,xmm2
    5f21:	vmulsd xmm2,xmm3,QWORD PTR [rax+0x40]
    5f26:	vmovddup xmm3,xmm3
    5f2a:	vmulpd xmm3,xmm3,XMMWORD PTR [rax+0x30]
    5f2f:	vaddsd xmm1,xmm1,xmm2
    5f33:	vpermilpd xmm2,xmm0,0x0
    5f39:	vpermilpd xmm0,xmm0,0x3
    5f3f:	vmulpd xmm2,xmm2,XMMWORD PTR [rax]
    5f43:	vmulpd xmm0,xmm0,XMMWORD PTR [rax+0x18]
    5f48:	vmovsd QWORD PTR [rdx+0x10],xmm1
    5f4d:	vaddpd xmm0,xmm2,xmm0
    5f51:	vaddpd xmm0,xmm0,xmm3
    5f55:	vmovupd XMMWORD PTR [rdx],xmm0
    5f59:	inc    esi
    5f5b:	cmp    esi,r11d
    5f5e:	jne    5f00 <c_run_3.isra.0+0x20>
    5f60:	ret
    5f61:	nop    DWORD PTR [rax+0x0]
    5f65:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<c_run_4.isra.0>:
    5f70:	mov    r11d,edi
    5f73:	mov    r10,QWORD PTR [rsp+0x10]
    5f78:	mov    rdi,rcx
    5f7b:	mov    rax,rsi
    5f7e:	mov    rcx,QWORD PTR [rsp+0x8]
    5f83:	test   r11d,r11d
    5f86:	je     6117 <c_run_4.isra.0+0x1a7>
    5f8c:	xor    esi,esi
    5f8e:	xchg   ax,ax
    5f90:	vmovsd xmm0,QWORD PTR [rax]
    5f94:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    5f98:	vmovsd xmm1,QWORD PTR [rax+0x8]
    5f9d:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    5fa2:	vaddsd xmm0,xmm0,xmm1
    5fa6:	vmovsd xmm1,QWORD PTR [rax+0x10]
    5fab:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    5fb0:	vaddsd xmm0,xmm0,xmm1
    5fb4:	vmovsd QWORD PTR [rcx],xmm0
    5fb8:	vmovsd xmm0,QWORD PTR [rax]
    5fbc:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    5fc1:	vmovsd xmm1,QWORD PTR [rax+0x8]
    5fc6:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    5fcb:	vaddsd xmm0,xmm0,xmm1
    5fcf:	vmovsd xmm1,QWORD PTR [rax+0x10]
    5fd4:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    5fd9:	vaddsd xmm0,xmm0,xmm1
    5fdd:	vmovsd QWORD PTR [rcx+0x8],xmm0
    5fe2:	vmovsd xmm0,QWORD PTR [rax]
    5fe6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    5feb:	vmovsd xmm1,QWORD PTR [rax+0x8]
    5ff0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    5ff5:	vaddsd xmm0,xmm0,xmm1
    5ff9:	vmovsd xmm1,QWORD PTR [rax+0x10]
    5ffe:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6003:	vaddsd xmm0,xmm0,xmm1
    6007:	vmovsd QWORD PTR [rcx+0x10],xmm0
    600c:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6011:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6015:	vmovsd xmm1,QWORD PTR [rax+0x20]
    601a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    601f:	vaddsd xmm0,xmm0,xmm1
    6023:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6028:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    602d:	vaddsd xmm0,xmm0,xmm1
    6031:	vmovsd QWORD PTR [rcx+0x18],xmm0
    6036:	vmovsd xmm0,QWORD PTR [rax+0x18]
    603b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6040:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6045:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    604a:	vaddsd xmm0,xmm0,xmm1
    604e:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6053:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6058:	vaddsd xmm0,xmm0,xmm1
    605c:	vmovsd QWORD PTR [rcx+0x20],xmm0
    6061:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6066:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    606b:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6070:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6075:	vaddsd xmm0,xmm0,xmm1
    6079:	vmovsd xmm1,QWORD PTR [rax+0x28]
    607e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6083:	vaddsd xmm0,xmm0,xmm1
    6087:	vmovsd QWORD PTR [rcx+0x28],xmm0
    608c:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6091:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6095:	vmovsd xmm1,QWORD PTR [rax+0x38]
    609a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    609f:	vaddsd xmm0,xmm0,xmm1
    60a3:	vmovsd xmm1,QWORD PTR [rax+0x40]
    60a8:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    60ad:	vaddsd xmm0,xmm0,xmm1
    60b1:	vmovsd QWORD PTR [rcx+0x30],xmm0
    60b6:	vmovsd xmm0,QWORD PTR [rax+0x30]
    60bb:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    60c0:	vmovsd xmm1,QWORD PTR [rax+0x38]
    60c5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    60ca:	vaddsd xmm0,xmm0,xmm1
    60ce:	vmovsd xmm1,QWORD PTR [rax+0x40]
    60d3:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    60d8:	vaddsd xmm0,xmm0,xmm1
    60dc:	vmovsd QWORD PTR [rcx+0x38],xmm0
    60e1:	vmovsd xmm0,QWORD PTR [rax+0x30]
    60e6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    60eb:	vmovsd xmm1,QWORD PTR [rax+0x38]
    60f0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    60f5:	vaddsd xmm0,xmm0,xmm1
    60f9:	vmovsd xmm1,QWORD PTR [rax+0x40]
    60fe:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6103:	vaddsd xmm0,xmm0,xmm1
    6107:	vmovsd QWORD PTR [rcx+0x40],xmm0
    610c:	inc    esi
    610e:	cmp    esi,r11d
    6111:	jne    5f90 <c_run_4.isra.0+0x20>
    6117:	ret
    6118:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_5.isra.0>:
    6120:	mov    r11d,edi
    6123:	mov    r10,QWORD PTR [rsp+0x10]
    6128:	mov    rdi,rcx
    612b:	mov    rax,rsi
    612e:	mov    rcx,QWORD PTR [rsp+0x8]
    6133:	test   r11d,r11d
    6136:	je     62c7 <c_run_5.isra.0+0x1a7>
    613c:	xor    esi,esi
    613e:	xchg   ax,ax
    6140:	vmovsd xmm0,QWORD PTR [rax]
    6144:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6148:	vmovsd xmm1,QWORD PTR [rax+0x18]
    614d:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    6152:	vaddsd xmm0,xmm0,xmm1
    6156:	vmovsd xmm1,QWORD PTR [rax+0x30]
    615b:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    6160:	vaddsd xmm0,xmm0,xmm1
    6164:	vmovsd QWORD PTR [rcx],xmm0
    6168:	vmovsd xmm0,QWORD PTR [rax]
    616c:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6171:	vmovsd xmm1,QWORD PTR [rax+0x18]
    6176:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    617b:	vaddsd xmm0,xmm0,xmm1
    617f:	vmovsd xmm1,QWORD PTR [rax+0x30]
    6184:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6189:	vaddsd xmm0,xmm0,xmm1
    618d:	vmovsd QWORD PTR [rcx+0x8],xmm0
    6192:	vmovsd xmm0,QWORD PTR [rax]
    6196:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    619b:	vmovsd xmm1,QWORD PTR [rax+0x18]
    61a0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    61a5:	vaddsd xmm0,xmm0,xmm1
    61a9:	vmovsd xmm1,QWORD PTR [rax+0x30]
    61ae:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    61b3:	vaddsd xmm0,xmm0,xmm1
    61b7:	vmovsd QWORD PTR [rcx+0x10],xmm0
    61bc:	vmovsd xmm0,QWORD PTR [rax+0x8]
    61c1:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    61c5:	vmovsd xmm1,QWORD PTR [rax+0x20]
    61ca:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    61cf:	vaddsd xmm0,xmm0,xmm1
    61d3:	vmovsd xmm1,QWORD PTR [rax+0x38]
    61d8:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    61dd:	vaddsd xmm0,xmm0,xmm1
    61e1:	vmovsd QWORD PTR [rcx+0x18],xmm0
    61e6:	vmovsd xmm0,QWORD PTR [rax+0x8]
    61eb:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    61f0:	vmovsd xmm1,QWORD PTR [rax+0x20]
    61f5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    61fa:	vaddsd xmm0,xmm0,xmm1
    61fe:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6203:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6208:	vaddsd xmm0,xmm0,xmm1
    620c:	vmovsd QWORD PTR [rcx+0x20],xmm0
    6211:	vmovsd xmm0,QWORD PTR [rax+0x8]
    6216:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    621b:	vmovsd xmm1,QWORD PTR [rax+0x20]
    6220:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6225:	vaddsd xmm0,xmm0,xmm1
    6229:	vmovsd xmm1,QWORD PTR [rax+0x38]
    622e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6233:	vaddsd xmm0,xmm0,xmm1
    6237:	vmovsd QWORD PTR [rcx+0x28],xmm0
    623c:	vmovsd xmm0,QWORD PTR [rax+0x10]
    6241:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6245:	vmovsd xmm1,QWORD PTR [rax+0x28]
    624a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x18]
    624f:	vaddsd xmm0,xmm0,xmm1
    6253:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6258:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x30]
    625d:	vaddsd xmm0,xmm0,xmm1
    6261:	vmovsd QWORD PTR [rcx+0x30],xmm0
    6266:	vmovsd xmm0,QWORD PTR [rax+0x10]
    626b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x8]
    6270:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6275:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    627a:	vaddsd xmm0,xmm0,xmm1
    627e:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6283:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6288:	vaddsd xmm0,xmm0,xmm1
    628c:	vmovsd QWORD PTR [rcx+0x38],xmm0
    6291:	vmovsd xmm0,QWORD PTR [rax+0x10]
    6296:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x10]
    629b:	vmovsd xmm1,QWORD PTR [rax+0x28]
    62a0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    62a5:	vaddsd xmm0,xmm0,xmm1
    62a9:	vmovsd xmm1,QWORD PTR [rax+0x40]
    62ae:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    62b3:	vaddsd xmm0,xmm0,xmm1
    62b7:	vmovsd QWORD PTR [rcx+0x40],xmm0
    62bc:	inc    esi
    62be:	cmp    esi,r11d
    62c1:	jne    6140 <c_run_5.isra.0+0x20>
    62c7:	ret
    62c8:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_6.isra.0>:
    62d0:	mov    r11d,edi
    62d3:	mov    r10,QWORD PTR [rsp+0x10]
    62d8:	mov    rdi,rcx
    62db:	mov    rax,rsi
    62de:	mov    rcx,QWORD PTR [rsp+0x8]
    62e3:	test   r11d,r11d
    62e6:	je     6477 <c_run_6.isra.0+0x1a7>
    62ec:	xor    esi,esi
    62ee:	xchg   ax,ax
    62f0:	vmovsd xmm0,QWORD PTR [rax]
    62f4:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    62f8:	vmovsd xmm1,QWORD PTR [rax+0x8]
    62fd:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    6302:	vaddsd xmm0,xmm0,xmm1
    6306:	vmovsd xmm1,QWORD PTR [rax+0x10]
    630b:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    6310:	vaddsd xmm0,xmm0,xmm1
    6314:	vmovsd QWORD PTR [rcx],xmm0
    6318:	vmovsd xmm0,QWORD PTR [rax]
    631c:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    6321:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6326:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    632b:	vaddsd xmm0,xmm0,xmm1
    632f:	vmovsd xmm1,QWORD PTR [rax+0x10]
    6334:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6339:	vaddsd xmm0,xmm0,xmm1
    633d:	vmovsd QWORD PTR [rcx+0x8],xmm0
    6342:	vmovsd xmm0,QWORD PTR [rax]
    6346:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    634b:	vmovsd xmm1,QWORD PTR [rax+0x8]
    6350:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6355:	vaddsd xmm0,xmm0,xmm1
    6359:	vmovsd xmm1,QWORD PTR [rax+0x10]
    635e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6363:	vaddsd xmm0,xmm0,xmm1
    6367:	vmovsd QWORD PTR [rcx+0x10],xmm0
    636c:	vmovsd xmm0,QWORD PTR [rax+0x18]
    6371:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    6375:	vmovsd xmm1,QWORD PTR [rax+0x20]
    637a:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    637f:	vaddsd xmm0,xmm0,xmm1
    6383:	vmovsd xmm1,QWORD PTR [rax+0x28]
    6388:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    638d:	vaddsd xmm0,xmm0,xmm1
    6391:	vmovsd QWORD PTR [rcx+0x18],xmm0
    6396:	vmovsd xmm0,QWORD PTR [rax+0x18]
    639b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    63a0:	vmovsd xmm1,QWORD PTR [rax+0x20]
    63a5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    63aa:	vaddsd xmm0,xmm0,xmm1
    63ae:	vmovsd xmm1,QWORD PTR [rax+0x28]
    63b3:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    63b8:	vaddsd xmm0,xmm0,xmm1
    63bc:	vmovsd QWORD PTR [rcx+0x20],xmm0
    63c1:	vmovsd xmm0,QWORD PTR [rax+0x18]
    63c6:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    63cb:	vmovsd xmm1,QWORD PTR [rax+0x20]
    63d0:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    63d5:	vaddsd xmm0,xmm0,xmm1
    63d9:	vmovsd xmm1,QWORD PTR [rax+0x28]
    63de:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    63e3:	vaddsd xmm0,xmm0,xmm1
    63e7:	vmovsd QWORD PTR [rcx+0x28],xmm0
    63ec:	vmovsd xmm0,QWORD PTR [rax+0x30]
    63f1:	vmulsd xmm0,xmm0,QWORD PTR [rdx]
    63f5:	vmovsd xmm1,QWORD PTR [rax+0x38]
    63fa:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x8]
    63ff:	vaddsd xmm0,xmm0,xmm1
    6403:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6408:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x10]
    640d:	vaddsd xmm0,xmm0,xmm1
    6411:	vmovsd QWORD PTR [rcx+0x30],xmm0
    6416:	vmovsd xmm0,QWORD PTR [rax+0x30]
    641b:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x18]
    6420:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6425:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x20]
    642a:	vaddsd xmm0,xmm0,xmm1
    642e:	vmovsd xmm1,QWORD PTR [rax+0x40]
    6433:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x28]
    6438:	vaddsd xmm0,xmm0,xmm1
    643c:	vmovsd QWORD PTR [rcx+0x38],xmm0
    6441:	vmovsd xmm0,QWORD PTR [rax+0x30]
    6446:	vmulsd xmm0,xmm0,QWORD PTR [rdx+0x30]
    644b:	vmovsd xmm1,QWORD PTR [rax+0x38]
    6450:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x38]
    6455:	vaddsd xmm0,xmm0,xmm1
    6459:	vmovsd xmm1,QWORD PTR [rax+0x40]
    645e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+0x40]
    6463:	vaddsd xmm0,xmm0,xmm1
    6467:	vmovsd QWORD PTR [rcx+0x40],xmm0
    646c:	inc    esi
    646e:	cmp    esi,r11d
    6471:	jne    62f0 <c_run_6.isra.0+0x20>
    6477:	ret
    6478:	nop    DWORD PTR [rax+rax*1+0x0]


<c_run_7.isra.0>:
    a010:	push   rbp
    a011:	mov    rbp,rsp
    a014:	push   r15
    a016:	push   r14
    a018:	push   r13
    a01a:	push   r12
    a01c:	push   rbx
    a01d:	mov    r13,rcx
    a020:	mov    rcx,r8
    a023:	and    rsp,0xffffffffffffffe0
    a027:	test   edx,edx
    a029:	mov    DWORD PTR [rsp-0x8],edx
    a02d:	mov    QWORD PTR [rsp-0x10],r8
    a032:	mov    rdx,QWORD PTR [rbp+0x10]
    a036:	mov    r8,QWORD PTR [rbp+0x20]
    a03a:	je     a1c6 <c_run_7.isra.0+0x1b6>
    a040:	mov    eax,edi
    a042:	mov    ebx,esi
    a044:	mov    rdi,QWORD PTR [rbp+0x18]
    a048:	mov    rsi,QWORD PTR [rbp+0x28]
    a04c:	mov    r15,r9
    a04f:	test   eax,eax
    a051:	je     a1d5 <c_run_7.isra.0+0x1c5>
    a057:	lea    r11d,[rbx-0x8]
    a05b:	lea    ecx,[rbx-0x4]
    a05e:	mov    r9d,ebx
    a061:	lea    r10,[r8+rax*8]
    a065:	and    r11d,0xfffffffc
    a069:	mov    eax,0x4
    a06e:	add    r11d,0x8
    a072:	shl    r9,0x3
    a076:	cmp    ecx,0x3
    a079:	cmovle r11d,eax
    a07d:	xor    r14d,r14d
    a080:	mov    r12d,ebx
    a083:	sub    r12d,r11d
    a086:	cs nop WORD PTR [rax+rax*1+0x0]
    a090:	mov    DWORD PTR [rsp-0x4],r14d
    a095:	mov    rax,r13
    a098:	mov    rdi,r8
    a09b:	nop    DWORD PTR [rax+rax*1+0x0]
    a0a0:	test   ecx,ecx
    a0a2:	js     a160 <c_run_7.isra.0+0x150>
    a0a8:	vmovupd ymm1,YMMWORD PTR [rax]
    a0ac:	vmulpd ymm1,ymm1,YMMWORD PTR [rdx]
    a0b0:	cmp    ecx,0x3
    a0b3:	jle    a0d6 <c_run_7.isra.0+0xc6>
    a0b5:	mov    esi,0x4
    a0ba:	nop    WORD PTR [rax+rax*1+0x0]
    a0c0:	vmovupd ymm0,YMMWORD PTR [rax+rsi*8]
    a0c5:	vmulpd ymm0,ymm0,YMMWORD PTR [rdx+rsi*8]
    a0ca:	add    rsi,0x4
    a0ce:	vaddpd ymm1,ymm1,ymm0
    a0d2:	cmp    ecx,esi
    a0d4:	jge    a0c0 <c_run_7.isra.0+0xb0>
    a0d6:	vmovapd xmm0,xmm1
    a0da:	vextractf64x2 xmm1,ymm1,0x1
    a0e1:	mov    r14d,r12d
    a0e4:	mov    esi,r11d
    a0e7:	vaddpd xmm0,xmm0,xmm1
    a0eb:	vunpckhpd xmm1,xmm0,xmm0
    a0ef:	vaddsd xmm0,xmm0,xmm1
    a0f3:	cmp    r14d,0x3
    a0f7:	je     a16f <c_run_7.isra.0+0x15f>
    a0f9:	cmp    r14d,0x2
    a0fd:	je     a1a0 <c_run_7.isra.0+0x190>
    a103:	cmp    r14d,0x1
    a107:	jne    a120 <c_run_7.isra.0+0x110>
    a109:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    a10e:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    a113:	vaddsd xmm0,xmm0,xmm1
    a117:	nop    WORD PTR [rax+rax*1+0x0]
    a120:	vmovsd QWORD PTR [rdi],xmm0
    a124:	add    rdi,0x8
    a128:	add    rax,r9
    a12b:	cmp    r10,rdi
    a12e:	jne    a0a0 <c_run_7.isra.0+0x90>
    a134:	mov    r14d,DWORD PTR [rsp-0x4]
    a139:	mov    rax,QWORD PTR [rsp-0x10]
    a13e:	mov    rdi,QWORD PTR [rbp+0x18]
    a142:	mov    rsi,QWORD PTR [rbp+0x28]
    a146:	inc    r14d
    a149:	cmp    DWORD PTR [rsp-0x8],r14d
    a14e:	je     a1c3 <c_run_7.isra.0+0x1b3>
    a150:	mov    rdi,QWORD PTR [rbp+0x18]
    a154:	mov    rsi,QWORD PTR [rbp+0x28]
    a158:	jmp    a090 <c_run_7.isra.0+0x80>
    a15d:	nop    DWORD PTR [rax]
    a160:	mov    r14d,ebx
    a163:	xor    esi,esi
    a165:	vxorpd xmm0,xmm0,xmm0
    a169:	cmp    r14d,0x3
    a16d:	jne    a0f9 <c_run_7.isra.0+0xe9>
    a16f:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    a174:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    a179:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x8]
    a17f:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x8]
    a185:	vaddsd xmm1,xmm1,xmm2
    a189:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x10]
    a18f:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x10]
    a195:	vaddsd xmm1,xmm1,xmm2
    a199:	vaddsd xmm0,xmm0,xmm1
    a19d:	jmp    a120 <c_run_7.isra.0+0x110>
    a19f:	nop
    a1a0:	vmovsd xmm1,QWORD PTR [rax+rsi*8]
    a1a5:	vmulsd xmm1,xmm1,QWORD PTR [rdx+rsi*8]
    a1aa:	vmovsd xmm2,QWORD PTR [rax+rsi*8+0x8]
    a1b0:	vmulsd xmm2,xmm2,QWORD PTR [rdx+rsi*8+0x8]
    a1b6:	vaddsd xmm1,xmm1,xmm2
    a1ba:	vaddsd xmm0,xmm0,xmm1
    a1be:	jmp    a120 <c_run_7.isra.0+0x110>
    a1c3:	vzeroupper
    a1c6:	lea    rsp,[rbp-0x28]
    a1ca:	pop    rbx
    a1cb:	pop    r12
    a1cd:	pop    r13
    a1cf:	pop    r14
    a1d1:	pop    r15
    a1d3:	pop    rbp
    a1d4:	ret
    a1d5:	mov    rcx,QWORD PTR [rsp-0x10]
    a1da:	mov    rsi,QWORD PTR [rbp+0x18]
    a1de:	mov    rdi,QWORD PTR [rbp+0x28]
    a1e2:	mov    r9d,DWORD PTR [rsp-0x8]
    a1e7:	lea    r10d,[rax+0x1]
    a1eb:	cmp    r9d,r10d
    a1ee:	je     a1c6 <c_run_7.isra.0+0x1b6>
    a1f0:	add    eax,0x2
    a1f3:	cmp    r9d,eax
    a1f6:	je     a1c6 <c_run_7.isra.0+0x1b6>
    a1f8:	jmp    a1e7 <c_run_7.isra.0+0x1d7>
    a1fa:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_8.isra.0>:
    94d0:	push   rbp
    94d1:	mov    r11d,edi
    94d4:	mov    rbp,rsp
    94d7:	push   r15
    94d9:	push   r14
    94db:	push   r13
    94dd:	push   r12
    94df:	push   rbx
    94e0:	and    rsp,0xffffffffffffffe0
    94e4:	sub    rsp,0x40
    94e8:	mov    rdi,QWORD PTR [rbp+0x20]
    94ec:	mov    QWORD PTR [rsp+0x38],r8
    94f1:	test   edx,edx
    94f3:	je     9662 <c_run_8.isra.0+0x192>
    94f9:	mov    eax,esi
    94fb:	mov    DWORD PTR [rsp+0x1c],edx
    94ff:	mov    DWORD PTR [rsp+0x18],r11d
    9504:	mov    r10,r9
    9507:	mov    r15,rax
    950a:	xor    r12d,r12d
    950d:	shl    rax,0x3
    9511:	lea    ebx,[r15-0x4]
    9515:	mov    QWORD PTR [rsp+0x20],rax
    951a:	mov    eax,r11d
    951d:	lea    r14,[r9+rax*8]
    9521:	mov    eax,ebx
    9523:	and    eax,0xfffffffc
    9526:	add    eax,0x4
    9529:	mov    r13,r14
    952c:	mov    r14,rcx
    952f:	mov    edx,r15d
    9532:	sub    edx,eax
    9534:	mov    DWORD PTR [rsp+0x2c],eax
    9538:	mov    DWORD PTR [rsp+0x28],edx
    953c:	nop    DWORD PTR [rax+0x0]
    9540:	mov    rax,QWORD PTR [rsp+0x38]
    9545:	mov    rdx,QWORD PTR [rbp+0x10]
    9549:	mov    rsi,QWORD PTR [rbp+0x18]
    954d:	mov    rcx,QWORD PTR [rbp+0x28]
    9551:	mov    rdx,QWORD PTR [rsp+0x20]
    9556:	xor    esi,esi
    9558:	mov    QWORD PTR [rsp+0x30],r10
    955d:	call   2bd0 <memset@plt>
    9562:	mov    r10,QWORD PTR [rsp+0x30]
    9567:	mov    rdi,rax
    956a:	mov    eax,DWORD PTR [rsp+0x18]
    956e:	test   eax,eax
    9570:	je     9643 <c_run_8.isra.0+0x173>
    9576:	mov    rax,r10
    9579:	xor    edx,edx
    957b:	vxorpd xmm3,xmm3,xmm3
    957f:	jmp    95b0 <c_run_8.isra.0+0xe0>
    9581:	nop    WORD PTR [rax+rax*1+0x0]
    958a:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9595:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    95a0:	add    rax,0x8
    95a4:	add    edx,r15d
    95a7:	cmp    r13,rax
    95aa:	je     9640 <c_run_8.isra.0+0x170>
    95b0:	vmovsd xmm1,QWORD PTR [rax]
    95b4:	vcomisd xmm1,xmm3
    95b8:	je     95a0 <c_run_8.isra.0+0xd0>
    95ba:	mov    ecx,edx
    95bc:	lea    rsi,[r14+rcx*8]
    95c0:	test   ebx,ebx
    95c2:	js     9680 <c_run_8.isra.0+0x1b0>
    95c8:	vbroadcastsd ymm2,xmm1
    95cd:	xor    ecx,ecx
    95cf:	nop    WORD PTR [rax+rax*1+0x0]
    95d5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    95e0:	vmulpd ymm0,ymm2,YMMWORD PTR [rsi+rcx*8]
    95e5:	vaddpd ymm0,ymm0,YMMWORD PTR [rdi+rcx*8]
    95ea:	vmovupd YMMWORD PTR [rdi+rcx*8],ymm0
    95ef:	add    rcx,0x4
    95f3:	cmp    ebx,ecx
    95f5:	jge    95e0 <c_run_8.isra.0+0x110>
    95f7:	mov    r8d,DWORD PTR [rsp+0x28]
    95fc:	mov    ecx,DWORD PTR [rsp+0x2c]
    9600:	cmp    r8d,0x3
    9604:	je     968f <c_run_8.isra.0+0x1bf>
    960a:	cmp    r8d,0x2
    960e:	je     96d0 <c_run_8.isra.0+0x200>
    9614:	cmp    r8d,0x1
    9618:	jne    95a0 <c_run_8.isra.0+0xd0>
    961a:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*8]
    961f:	add    rax,0x8
    9623:	add    edx,r15d
    9626:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*8]
    962b:	vmovsd QWORD PTR [rdi+rcx*8],xmm1
    9630:	cmp    r13,rax
    9633:	jne    95b0 <c_run_8.isra.0+0xe0>
    9639:	nop    DWORD PTR [rax+0x0]
    9640:	vzeroupper
    9643:	mov    rax,QWORD PTR [rsp+0x38]
    9648:	mov    rdx,QWORD PTR [rbp+0x10]
    964c:	mov    rsi,QWORD PTR [rbp+0x18]
    9650:	mov    rcx,QWORD PTR [rbp+0x28]
    9654:	inc    r12d
    9657:	cmp    r12d,DWORD PTR [rsp+0x1c]
    965c:	jne    9540 <c_run_8.isra.0+0x70>
    9662:	lea    rsp,[rbp-0x28]
    9666:	pop    rbx
    9667:	pop    r12
    9669:	pop    r13
    966b:	pop    r14
    966d:	pop    r15
    966f:	pop    rbp
    9670:	ret
    9671:	nop    DWORD PTR [rax+0x0]
    9675:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9680:	mov    r8d,r15d
    9683:	xor    ecx,ecx
    9685:	cmp    r8d,0x3
    9689:	jne    960a <c_run_8.isra.0+0x13a>
    968f:	shl    rcx,0x3
    9693:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1]
    9698:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1]
    969d:	vmovsd QWORD PTR [rdi+rcx*1],xmm0
    96a2:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1+0x8]
    96a8:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1+0x8]
    96ae:	vmovsd QWORD PTR [rdi+rcx*1+0x8],xmm0
    96b4:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*1+0x10]
    96ba:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*1+0x10]
    96c0:	vmovsd QWORD PTR [rdi+rcx*1+0x10],xmm1
    96c6:	jmp    95a0 <c_run_8.isra.0+0xd0>
    96cb:	nop    DWORD PTR [rax+rax*1+0x0]
    96d0:	shl    rcx,0x3
    96d4:	vmulsd xmm0,xmm1,QWORD PTR [rsi+rcx*1]
    96d9:	vaddsd xmm0,xmm0,QWORD PTR [rdi+rcx*1]
    96de:	vmovsd QWORD PTR [rdi+rcx*1],xmm0
    96e3:	vmulsd xmm1,xmm1,QWORD PTR [rsi+rcx*1+0x8]
    96e9:	vaddsd xmm1,xmm1,QWORD PTR [rdi+rcx*1+0x8]
    96ef:	vmovsd QWORD PTR [rdi+rcx*1+0x8],xmm1
    96f5:	jmp    95a0 <c_run_8.isra.0+0xd0>
    96fa:	nop    WORD PTR [rax+rax*1+0x0]


<c_run_9.isra.0>:
    9d20:	push   rbp
    9d21:	mov    rbp,rsp
    9d24:	push   r15
    9d26:	push   r14
    9d28:	push   r13
    9d2a:	push   r12
    9d2c:	push   rbx
    9d2d:	and    rsp,0xffffffffffffffe0
    9d31:	mov    DWORD PTR [rsp-0x10],esi
    9d35:	test   esi,esi
    9d37:	je     9fdf <c_run_9.isra.0+0x2bf>
    9d3d:	mov    ebx,edi
    9d3f:	mov    r15,rcx
    9d42:	mov    rax,QWORD PTR [rbp+0x10]
    9d46:	mov    rdi,QWORD PTR [rbp+0x18]
    9d4a:	mov    rcx,QWORD PTR [rbp+0x20]
    9d4e:	mov    r11,rdx
    9d51:	test   ebx,ebx
    9d53:	je     9fe5 <c_run_9.isra.0+0x2c5>
    9d59:	lea    eax,[rbx-0x8]
    9d5c:	lea    edx,[rbx-0x4]
    9d5f:	mov    r10d,ebx
    9d62:	mov    ecx,0x4
    9d67:	and    eax,0xfffffffc
    9d6a:	mov    QWORD PTR [rsp-0x28],r15
    9d6f:	vxorpd xmm0,xmm0,xmm0
    9d73:	add    eax,0x8
    9d76:	shl    r10,0x3
    9d7a:	cmp    edx,0x3
    9d7d:	lea    r12,[r8+r10*1]
    9d81:	cmovle eax,ecx
    9d84:	xor    r13d,r13d
    9d87:	mov    r14d,eax
    9d8a:	lea    ecx,[rax+0x1]
    9d8d:	mov    edi,ebx
    9d8f:	sub    edi,eax
    9d91:	shl    r14,0x3
    9d95:	vmovq  xmm8,rcx
    9d9a:	lea    rcx,[r9+r14*1]
    9d9e:	add    eax,0x2
    9da1:	mov    QWORD PTR [rsp-0x8],rcx
    9da6:	vmovq  xmm6,rax
    9dab:	nop    DWORD PTR [rax+rax*1+0x0]
    9db0:	mov    DWORD PTR [rsp-0xc],r13d
    9db5:	mov    QWORD PTR [rsp-0x18],r11
    9dba:	mov    QWORD PTR [rsp-0x20],r8
    9dbf:	mov    rcx,r8
    9dc2:	mov    rax,r11
    9dc5:	vxorpd xmm2,xmm2,xmm2
    9dc9:	vmovq  r8,xmm8
    9dce:	xchg   ax,ax
    9dd0:	vmovsd xmm3,QWORD PTR [rcx]
    9dd4:	mov    rsi,rax
    9dd7:	test   edx,edx
    9dd9:	js     9e70 <c_run_9.isra.0+0x150>
    9ddf:	vmovupd ymm4,YMMWORD PTR [r9]
    9de4:	vmulpd ymm1,ymm4,YMMWORD PTR [rax]
    9de8:	cmp    edx,0x3
    9deb:	jle    9e17 <c_run_9.isra.0+0xf7>
    9ded:	mov    esi,0x4
    9df2:	nop    DWORD PTR [rax]
    9df5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9e00:	vmovupd ymm7,YMMWORD PTR [rax+rsi*8]
    9e05:	vmulpd ymm5,ymm7,YMMWORD PTR [r9+rsi*8]
    9e0b:	add    rsi,0x4
    9e0f:	vaddpd ymm1,ymm1,ymm5
    9e13:	cmp    edx,esi
    9e15:	jge    9e00 <c_run_9.isra.0+0xe0>
    9e17:	vmovapd xmm5,xmm1
    9e1b:	vextractf64x2 xmm1,ymm1,0x1
    9e22:	vaddpd xmm5,xmm5,xmm1
    9e26:	vunpckhpd xmm1,xmm5,xmm5
    9e2a:	vaddsd xmm7,xmm5,xmm1
    9e2e:	cmp    edi,0x3
    9e31:	je     9f00 <c_run_9.isra.0+0x1e0>
    9e37:	cmp    edi,0x2
    9e3a:	je     9f70 <c_run_9.isra.0+0x250>
    9e40:	cmp    edi,0x1
    9e43:	je     9fbf <c_run_9.isra.0+0x29f>
    9e49:	vmulsd xmm3,xmm7,xmm3
    9e4d:	add    rcx,0x8
    9e51:	vaddsd xmm2,xmm2,xmm3
    9e55:	cmp    rcx,r12
    9e58:	je     9eae <c_run_9.isra.0+0x18e>
    9e5a:	vmovsd xmm3,QWORD PTR [rcx]
    9e5e:	add    rax,r10
    9e61:	jmp    9de4 <c_run_9.isra.0+0xc4>
    9e66:	cs nop WORD PTR [rax+rax*1+0x0]
    9e70:	cmp    ebx,0x3
    9e73:	je     9f50 <c_run_9.isra.0+0x230>
    9e79:	cmp    ebx,0x2
    9e7c:	je     9fb0 <c_run_9.isra.0+0x290>
    9e82:	mov    r11,r9
    9e85:	vxorpd xmm7,xmm7,xmm7
    9e89:	vmovsd xmm1,QWORD PTR [rsi]
    9e8d:	vmulsd xmm1,xmm1,QWORD PTR [r11]
    9e92:	vaddsd xmm4,xmm1,xmm7
    9e96:	vmulsd xmm3,xmm4,xmm3
    9e9a:	add    rcx,0x8
    9e9e:	add    rax,r10
    9ea1:	vaddsd xmm2,xmm2,xmm3
    9ea5:	cmp    r12,rcx
    9ea8:	jne    9dd0 <c_run_9.isra.0+0xb0>
    9eae:	mov    r13d,DWORD PTR [rsp-0xc]
    9eb3:	mov    r11,QWORD PTR [rsp-0x18]
    9eb8:	mov    r8,QWORD PTR [rsp-0x20]
    9ebd:	mov    rax,QWORD PTR [rsp-0x28]
    9ec2:	mov    rcx,QWORD PTR [rbp+0x10]
    9ec6:	mov    rsi,QWORD PTR [rbp+0x18]
    9eca:	mov    r15,QWORD PTR [rbp+0x20]
    9ece:	vaddsd xmm0,xmm0,xmm2
    9ed2:	inc    r13d
    9ed5:	cmp    DWORD PTR [rsp-0x10],r13d
    9eda:	je     9fcd <c_run_9.isra.0+0x2ad>
    9ee0:	mov    rcx,QWORD PTR [rbp+0x10]
    9ee4:	mov    rsi,QWORD PTR [rbp+0x18]
    9ee8:	mov    r15,QWORD PTR [rbp+0x20]
    9eec:	jmp    9db0 <c_run_9.isra.0+0x90>
    9ef1:	nop    DWORD PTR [rax+0x0]
    9ef5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9f00:	mov    r15,QWORD PTR [rsp-0x8]
    9f05:	vmovq  r11,xmm6
    9f0a:	lea    r13,[r8*8+0x0]
    9f12:	lea    rsi,[rax+r14*1]
    9f16:	lea    r11,[r11*8+0x0]
    9f1e:	vmovsd xmm1,QWORD PTR [rax+r13*1]
    9f24:	vmulsd xmm1,xmm1,QWORD PTR [r9+r13*1]
    9f2a:	vmovsd xmm4,QWORD PTR [rsi]
    9f2e:	vmulsd xmm4,xmm4,QWORD PTR [r15]
    9f33:	vaddsd xmm1,xmm1,xmm4
    9f37:	vmovsd xmm4,QWORD PTR [rax+r11*1]
    9f3d:	vmulsd xmm4,xmm4,QWORD PTR [r9+r11*1]
    9f43:	vaddsd xmm1,xmm1,xmm4
    9f47:	vaddsd xmm4,xmm1,xmm7
    9f4b:	jmp    9e96 <c_run_9.isra.0+0x176>
    9f50:	mov    r15,r9
    9f53:	mov    r13d,0x8
    9f59:	mov    r11d,0x10
    9f5f:	vxorpd xmm7,xmm7,xmm7
    9f63:	jmp    9f1e <c_run_9.isra.0+0x1fe>
    9f65:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9f70:	mov    r13,QWORD PTR [rsp-0x8]
    9f75:	lea    rsi,[rax+r14*1]
    9f79:	lea    r11,[r8*8+0x0]
    9f81:	vmovsd xmm1,QWORD PTR [rax+r11*1]
    9f87:	vmulsd xmm1,xmm1,QWORD PTR [r9+r11*1]
    9f8d:	vmovsd xmm4,QWORD PTR [rsi]
    9f91:	vmulsd xmm4,xmm4,QWORD PTR [r13+0x0]
    9f97:	vaddsd xmm1,xmm1,xmm4
    9f9b:	vaddsd xmm4,xmm1,xmm7
    9f9f:	jmp    9e96 <c_run_9.isra.0+0x176>
    9fa4:	nop
    9fa5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
    9fb0:	mov    r13,r9
    9fb3:	mov    r11d,0x8
    9fb9:	vxorpd xmm7,xmm7,xmm7
    9fbd:	jmp    9f81 <c_run_9.isra.0+0x261>
    9fbf:	mov    r11,QWORD PTR [rsp-0x8]
    9fc4:	lea    rsi,[rax+r14*1]
    9fc8:	jmp    9e89 <c_run_9.isra.0+0x169>
    9fcd:	vzeroupper
    9fd0:	lea    rsp,[rbp-0x28]
    9fd4:	pop    rbx
    9fd5:	pop    r12
    9fd7:	pop    r13
    9fd9:	pop    r14
    9fdb:	pop    r15
    9fdd:	pop    rbp
    9fde:	ret
    9fdf:	vxorpd xmm0,xmm0,xmm0
    9fe3:	jmp    9fd0 <c_run_9.isra.0+0x2b0>
    9fe5:	mov    rax,QWORD PTR [rbp+0x10]
    9fe9:	mov    rdx,QWORD PTR [rbp+0x18]
    9fed:	mov    rcx,QWORD PTR [rbp+0x20]
    9ff1:	mov    esi,DWORD PTR [rsp-0x10]
    9ff5:	lea    edi,[rbx+0x1]
    9ff8:	cmp    esi,edi
    9ffa:	je     9fdf <c_run_9.isra.0+0x2bf>
    9ffc:	add    ebx,0x2
    9fff:	cmp    esi,ebx
    a001:	je     9fdf <c_run_9.isra.0+0x2bf>
    a003:	jmp    9ff5 <c_run_9.isra.0+0x2d5>
    a005:	data16 cs nop WORD PTR [rax+rax*1+0x0]


<memcpy@plt>:
    30f0:	jmp    QWORD PTR [rip+0x3e1da]        # 412d0 <memcpy@GLIBC_2.14>
    30f6:	push   0x5a
    30fb:	jmp    2b40 <_init+0x28>


<memset@plt>:
    2bd0:	jmp    QWORD PTR [rip+0x3e46a]        # 41040 <memset@GLIBC_2.2.5>
    2bd6:	push   0x8
    2bdb:	jmp    2b40 <_init+0x28>

