
/var/tmp/sparkling-movement-final/current/bin/movement_bench:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

0000000000085fa0 <mj__smooth_math__apply>:
   85fa0:	c5 fb 10 1a          	vmovsd (%rdx),%xmm3
   85fa4:	c5 fb 10 62 08       	vmovsd 0x8(%rdx),%xmm4
   85fa9:	c5 fb 10 6a 10       	vmovsd 0x10(%rdx),%xmm5
   85fae:	48 89 f8             	mov    %rdi,%rax
   85fb1:	c5 db 59 4e 08       	vmulsd 0x8(%rsi),%xmm4,%xmm1
   85fb6:	c5 e3 59 06          	vmulsd (%rsi),%xmm3,%xmm0
   85fba:	c5 f9 2f 1d be 56 06 	vcomisd 0x656be(%rip),%xmm3        # eb680 <ada__numerics__long_elementary_functions__two_pi+0x210>
   85fc1:	00 
   85fc2:	c5 db 59 76 38       	vmulsd 0x38(%rsi),%xmm4,%xmm6
   85fc7:	c5 fb 58 c1          	vaddsd %xmm1,%xmm0,%xmm0
   85fcb:	c5 d3 59 4e 10       	vmulsd 0x10(%rsi),%xmm5,%xmm1
   85fd0:	c5 fb 58 d1          	vaddsd %xmm1,%xmm0,%xmm2
   85fd4:	c5 db 59 4e 20       	vmulsd 0x20(%rsi),%xmm4,%xmm1
   85fd9:	c5 e3 59 46 18       	vmulsd 0x18(%rsi),%xmm3,%xmm0
   85fde:	c5 fb 58 c1          	vaddsd %xmm1,%xmm0,%xmm0
   85fe2:	c5 d3 59 4e 28       	vmulsd 0x28(%rsi),%xmm5,%xmm1
   85fe7:	c5 fb 58 c9          	vaddsd %xmm1,%xmm0,%xmm1
   85feb:	c5 e3 59 46 30       	vmulsd 0x30(%rsi),%xmm3,%xmm0
   85ff0:	c5 fb 58 c6          	vaddsd %xmm6,%xmm0,%xmm0
   85ff4:	c5 d3 59 76 40       	vmulsd 0x40(%rsi),%xmm5,%xmm6
   85ff9:	c5 fb 58 c6          	vaddsd %xmm6,%xmm0,%xmm0
   85ffd:	77 0a                	ja     86009 <mj__smooth_math__apply+0x69>
   85fff:	c5 f9 2f 1d a1 56 06 	vcomisd 0x656a1(%rip),%xmm3        # eb6a8 <ada__numerics__long_elementary_functions__two_pi+0x238>
   86006:	00 
   86007:	73 17                	jae    86020 <mj__smooth_math__apply+0x80>
   86009:	c5 fb 11 10          	vmovsd %xmm2,(%rax)
   8600d:	c5 fb 11 48 08       	vmovsd %xmm1,0x8(%rax)
   86012:	c5 fb 11 40 10       	vmovsd %xmm0,0x10(%rax)
   86017:	c3                   	ret
   86018:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
   8601f:	00 
   86020:	c5 f9 2f 25 58 56 06 	vcomisd 0x65658(%rip),%xmm4        # eb680 <ada__numerics__long_elementary_functions__two_pi+0x210>
   86027:	00 
   86028:	77 df                	ja     86009 <mj__smooth_math__apply+0x69>
   8602a:	eb dd                	jmp    86009 <mj__smooth_math__apply+0x69>

Disassembly of section .fini:
