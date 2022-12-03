
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8c070713          	addi	a4,a4,-1856 # 80008910 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	bae78793          	addi	a5,a5,-1106 # 80005c10 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca7f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	388080e7          	jalr	904(ra) # 800024b2 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	134080e7          	jalr	308(ra) # 800022fc <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e7e080e7          	jalr	-386(ra) # 80002054 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	24a080e7          	jalr	586(ra) # 8000245c <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	216080e7          	jalr	534(ra) # 80002508 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	c72080e7          	jalr	-910(ra) # 800020b8 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00020797          	auipc	a5,0x20
    8000047c:	77078793          	addi	a5,a5,1904 # 80020be8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	5c07a223          	sw	zero,1476(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	34f72823          	sw	a5,848(a4) # 800088d0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	554dad83          	lw	s11,1364(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	4fe50513          	addi	a0,a0,1278 # 80010af8 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	3a050513          	addi	a0,a0,928 # 80010af8 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	38448493          	addi	s1,s1,900 # 80010af8 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	34450513          	addi	a0,a0,836 # 80010b18 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	0d07a783          	lw	a5,208(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	0a07b783          	ld	a5,160(a5) # 800088d8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0a073703          	ld	a4,160(a4) # 800088e0 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	2b6a0a13          	addi	s4,s4,694 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	06e48493          	addi	s1,s1,110 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	06e98993          	addi	s3,s3,110 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	824080e7          	jalr	-2012(ra) # 800020b8 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	24850513          	addi	a0,a0,584 # 80010b18 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	ff07a783          	lw	a5,-16(a5) # 800088d0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	ff673703          	ld	a4,-10(a4) # 800088e0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	fe67b783          	ld	a5,-26(a5) # 800088d8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	21a98993          	addi	s3,s3,538 # 80010b18 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	fd248493          	addi	s1,s1,-46 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	fd290913          	addi	s2,s2,-46 # 800088e0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	736080e7          	jalr	1846(ra) # 80002054 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	1e448493          	addi	s1,s1,484 # 80010b18 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	f8e7bc23          	sd	a4,-104(a5) # 800088e0 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	15e48493          	addi	s1,s1,350 # 80010b18 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	38478793          	addi	a5,a5,900 # 80021d80 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	13490913          	addi	s2,s2,308 # 80010b50 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	2b250513          	addi	a0,a0,690 # 80021d80 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd281>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	7fa080e7          	jalr	2042(ra) # 800026b8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	d8a080e7          	jalr	-630(ra) # 80005c50 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fd4080e7          	jalr	-44(ra) # 80001ea2 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00001097          	auipc	ra,0x1
    80000f3a:	75a080e7          	jalr	1882(ra) # 80002690 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	77a080e7          	jalr	1914(ra) # 800026b8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	cf4080e7          	jalr	-780(ra) # 80005c3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	d02080e7          	jalr	-766(ra) # 80005c50 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	e9e080e7          	jalr	-354(ra) # 80002df4 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	53e080e7          	jalr	1342(ra) # 8000349c <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	4e4080e7          	jalr	1252(ra) # 8000444a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	dea080e7          	jalr	-534(ra) # 80005d58 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d0e080e7          	jalr	-754(ra) # 80001c84 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72223          	sw	a5,-1692(a4) # 800088e8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9587b783          	ld	a5,-1704(a5) # 800088f0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd277>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	68a7be23          	sd	a0,1692(a5) # 800088f0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd280>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	75448493          	addi	s1,s1,1876 # 80010fa0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00015a17          	auipc	s4,0x15
    8000186a:	13aa0a13          	addi	s4,s4,314 # 800169a0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	858d                	srai	a1,a1,0x3
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	16848493          	addi	s1,s1,360
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7c080e7          	jalr	-900(ra) # 80000540 <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	28850513          	addi	a0,a0,648 # 80010b70 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	28850513          	addi	a0,a0,648 # 80010b88 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	69048493          	addi	s1,s1,1680 # 80010fa0 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00015997          	auipc	s3,0x15
    80001936:	06e98993          	addi	s3,s3,110 # 800169a0 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	878d                	srai	a5,a5,0x3
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	16848493          	addi	s1,s1,360
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	20450513          	addi	a0,a0,516 # 80010ba0 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	1ac70713          	addi	a4,a4,428 # 80010b70 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first) {
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	e647a783          	lw	a5,-412(a5) # 80008860 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	cca080e7          	jalr	-822(ra) # 800026d0 <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e407a523          	sw	zero,-438(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	9fc080e7          	jalr	-1540(ra) # 8000341c <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	13a90913          	addi	s2,s2,314 # 80010b70 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e1c78793          	addi	a5,a5,-484 # 80008864 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	05893683          	ld	a3,88(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a54080e7          	jalr	-1452(ra) # 8000152e <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2e080e7          	jalr	-1490(ra) # 8000152e <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e4080e7          	jalr	-1564(ra) # 8000152e <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7a080e7          	jalr	-390(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	3de48493          	addi	s1,s1,990 # 80010fa0 <proc>
    80001bca:	00015917          	auipc	s2,0x15
    80001bce:	dd690913          	addi	s2,s2,-554 # 800169a0 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bea:	16848493          	addi	s1,s1,360
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a889                	j	80001c46 <allocproc+0x90>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	ee2080e7          	jalr	-286(ra) # 80000ae6 <kalloc>
    80001c0c:	892a                	mv	s2,a0
    80001c0e:	eca8                	sd	a0,88(s1)
    80001c10:	c131                	beqz	a0,80001c54 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e5c080e7          	jalr	-420(ra) # 80001a70 <proc_pagetable>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c20:	c531                	beqz	a0,80001c6c <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c22:	07000613          	li	a2,112
    80001c26:	4581                	li	a1,0
    80001c28:	06048513          	addi	a0,s1,96
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	0a6080e7          	jalr	166(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c34:	00000797          	auipc	a5,0x0
    80001c38:	db078793          	addi	a5,a5,-592 # 800019e4 <forkret>
    80001c3c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3e:	60bc                	ld	a5,64(s1)
    80001c40:	6705                	lui	a4,0x1
    80001c42:	97ba                	add	a5,a5,a4
    80001c44:	f4bc                	sd	a5,104(s1)
}
    80001c46:	8526                	mv	a0,s1
    80001c48:	60e2                	ld	ra,24(sp)
    80001c4a:	6442                	ld	s0,16(sp)
    80001c4c:	64a2                	ld	s1,8(sp)
    80001c4e:	6902                	ld	s2,0(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret
    freeproc(p);
    80001c54:	8526                	mv	a0,s1
    80001c56:	00000097          	auipc	ra,0x0
    80001c5a:	f08080e7          	jalr	-248(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	02a080e7          	jalr	42(ra) # 80000c8a <release>
    return 0;
    80001c68:	84ca                	mv	s1,s2
    80001c6a:	bff1                	j	80001c46 <allocproc+0x90>
    freeproc(p);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	00000097          	auipc	ra,0x0
    80001c72:	ef0080e7          	jalr	-272(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	012080e7          	jalr	18(ra) # 80000c8a <release>
    return 0;
    80001c80:	84ca                	mv	s1,s2
    80001c82:	b7d1                	j	80001c46 <allocproc+0x90>

0000000080001c84 <userinit>:
{
    80001c84:	1101                	addi	sp,sp,-32
    80001c86:	ec06                	sd	ra,24(sp)
    80001c88:	e822                	sd	s0,16(sp)
    80001c8a:	e426                	sd	s1,8(sp)
    80001c8c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	f28080e7          	jalr	-216(ra) # 80001bb6 <allocproc>
    80001c96:	84aa                	mv	s1,a0
  initproc = p;
    80001c98:	00007797          	auipc	a5,0x7
    80001c9c:	c6a7b023          	sd	a0,-928(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca0:	03400613          	li	a2,52
    80001ca4:	00007597          	auipc	a1,0x7
    80001ca8:	bcc58593          	addi	a1,a1,-1076 # 80008870 <initcode>
    80001cac:	6928                	ld	a0,80(a0)
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	6a8080e7          	jalr	1704(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cb6:	6785                	lui	a5,0x1
    80001cb8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cba:	6cb8                	ld	a4,88(s1)
    80001cbc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc0:	6cb8                	ld	a4,88(s1)
    80001cc2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc4:	4641                	li	a2,16
    80001cc6:	00006597          	auipc	a1,0x6
    80001cca:	53a58593          	addi	a1,a1,1338 # 80008200 <digits+0x1c0>
    80001cce:	15848513          	addi	a0,s1,344
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	14a080e7          	jalr	330(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cda:	00006517          	auipc	a0,0x6
    80001cde:	53650513          	addi	a0,a0,1334 # 80008210 <digits+0x1d0>
    80001ce2:	00002097          	auipc	ra,0x2
    80001ce6:	164080e7          	jalr	356(ra) # 80003e46 <namei>
    80001cea:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cee:	478d                	li	a5,3
    80001cf0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	fffff097          	auipc	ra,0xfffff
    80001cf8:	f96080e7          	jalr	-106(ra) # 80000c8a <release>
}
    80001cfc:	60e2                	ld	ra,24(sp)
    80001cfe:	6442                	ld	s0,16(sp)
    80001d00:	64a2                	ld	s1,8(sp)
    80001d02:	6105                	addi	sp,sp,32
    80001d04:	8082                	ret

0000000080001d06 <growproc>:
{
    80001d06:	1101                	addi	sp,sp,-32
    80001d08:	ec06                	sd	ra,24(sp)
    80001d0a:	e822                	sd	s0,16(sp)
    80001d0c:	e426                	sd	s1,8(sp)
    80001d0e:	e04a                	sd	s2,0(sp)
    80001d10:	1000                	addi	s0,sp,32
    80001d12:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d14:	00000097          	auipc	ra,0x0
    80001d18:	c98080e7          	jalr	-872(ra) # 800019ac <myproc>
    80001d1c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d1e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d20:	01204c63          	bgtz	s2,80001d38 <growproc+0x32>
  } else if(n < 0){
    80001d24:	02094663          	bltz	s2,80001d50 <growproc+0x4a>
  p->sz = sz;
    80001d28:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d2a:	4501                	li	a0,0
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6902                	ld	s2,0(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d38:	4691                	li	a3,4
    80001d3a:	00b90633          	add	a2,s2,a1
    80001d3e:	6928                	ld	a0,80(a0)
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	6d0080e7          	jalr	1744(ra) # 80001410 <uvmalloc>
    80001d48:	85aa                	mv	a1,a0
    80001d4a:	fd79                	bnez	a0,80001d28 <growproc+0x22>
      return -1;
    80001d4c:	557d                	li	a0,-1
    80001d4e:	bff9                	j	80001d2c <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d50:	00b90633          	add	a2,s2,a1
    80001d54:	6928                	ld	a0,80(a0)
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	672080e7          	jalr	1650(ra) # 800013c8 <uvmdealloc>
    80001d5e:	85aa                	mv	a1,a0
    80001d60:	b7e1                	j	80001d28 <growproc+0x22>

0000000080001d62 <fork>:
{
    80001d62:	7139                	addi	sp,sp,-64
    80001d64:	fc06                	sd	ra,56(sp)
    80001d66:	f822                	sd	s0,48(sp)
    80001d68:	f426                	sd	s1,40(sp)
    80001d6a:	f04a                	sd	s2,32(sp)
    80001d6c:	ec4e                	sd	s3,24(sp)
    80001d6e:	e852                	sd	s4,16(sp)
    80001d70:	e456                	sd	s5,8(sp)
    80001d72:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	c38080e7          	jalr	-968(ra) # 800019ac <myproc>
    80001d7c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d7e:	00000097          	auipc	ra,0x0
    80001d82:	e38080e7          	jalr	-456(ra) # 80001bb6 <allocproc>
    80001d86:	10050c63          	beqz	a0,80001e9e <fork+0x13c>
    80001d8a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8c:	048ab603          	ld	a2,72(s5)
    80001d90:	692c                	ld	a1,80(a0)
    80001d92:	050ab503          	ld	a0,80(s5)
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	7d2080e7          	jalr	2002(ra) # 80001568 <uvmcopy>
    80001d9e:	04054863          	bltz	a0,80001dee <fork+0x8c>
  np->sz = p->sz;
    80001da2:	048ab783          	ld	a5,72(s5)
    80001da6:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001daa:	058ab683          	ld	a3,88(s5)
    80001dae:	87b6                	mv	a5,a3
    80001db0:	058a3703          	ld	a4,88(s4)
    80001db4:	12068693          	addi	a3,a3,288
    80001db8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dbc:	6788                	ld	a0,8(a5)
    80001dbe:	6b8c                	ld	a1,16(a5)
    80001dc0:	6f90                	ld	a2,24(a5)
    80001dc2:	01073023          	sd	a6,0(a4)
    80001dc6:	e708                	sd	a0,8(a4)
    80001dc8:	eb0c                	sd	a1,16(a4)
    80001dca:	ef10                	sd	a2,24(a4)
    80001dcc:	02078793          	addi	a5,a5,32
    80001dd0:	02070713          	addi	a4,a4,32
    80001dd4:	fed792e3          	bne	a5,a3,80001db8 <fork+0x56>
  np->trapframe->a0 = 0;
    80001dd8:	058a3783          	ld	a5,88(s4)
    80001ddc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de0:	0d0a8493          	addi	s1,s5,208
    80001de4:	0d0a0913          	addi	s2,s4,208
    80001de8:	150a8993          	addi	s3,s5,336
    80001dec:	a00d                	j	80001e0e <fork+0xac>
    freeproc(np);
    80001dee:	8552                	mv	a0,s4
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	d6e080e7          	jalr	-658(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001df8:	8552                	mv	a0,s4
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	e90080e7          	jalr	-368(ra) # 80000c8a <release>
    return -1;
    80001e02:	597d                	li	s2,-1
    80001e04:	a059                	j	80001e8a <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e06:	04a1                	addi	s1,s1,8
    80001e08:	0921                	addi	s2,s2,8
    80001e0a:	01348b63          	beq	s1,s3,80001e20 <fork+0xbe>
    if(p->ofile[i])
    80001e0e:	6088                	ld	a0,0(s1)
    80001e10:	d97d                	beqz	a0,80001e06 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e12:	00002097          	auipc	ra,0x2
    80001e16:	6ca080e7          	jalr	1738(ra) # 800044dc <filedup>
    80001e1a:	00a93023          	sd	a0,0(s2)
    80001e1e:	b7e5                	j	80001e06 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e20:	150ab503          	ld	a0,336(s5)
    80001e24:	00002097          	auipc	ra,0x2
    80001e28:	838080e7          	jalr	-1992(ra) # 8000365c <idup>
    80001e2c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e30:	4641                	li	a2,16
    80001e32:	158a8593          	addi	a1,s5,344
    80001e36:	158a0513          	addi	a0,s4,344
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	fe2080e7          	jalr	-30(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e42:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e46:	8552                	mv	a0,s4
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	e42080e7          	jalr	-446(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e50:	0000f497          	auipc	s1,0xf
    80001e54:	d3848493          	addi	s1,s1,-712 # 80010b88 <wait_lock>
    80001e58:	8526                	mv	a0,s1
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	d7c080e7          	jalr	-644(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e62:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e66:	8526                	mv	a0,s1
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	e22080e7          	jalr	-478(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e70:	8552                	mv	a0,s4
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	d64080e7          	jalr	-668(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e7a:	478d                	li	a5,3
    80001e7c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e80:	8552                	mv	a0,s4
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	e08080e7          	jalr	-504(ra) # 80000c8a <release>
}
    80001e8a:	854a                	mv	a0,s2
    80001e8c:	70e2                	ld	ra,56(sp)
    80001e8e:	7442                	ld	s0,48(sp)
    80001e90:	74a2                	ld	s1,40(sp)
    80001e92:	7902                	ld	s2,32(sp)
    80001e94:	69e2                	ld	s3,24(sp)
    80001e96:	6a42                	ld	s4,16(sp)
    80001e98:	6aa2                	ld	s5,8(sp)
    80001e9a:	6121                	addi	sp,sp,64
    80001e9c:	8082                	ret
    return -1;
    80001e9e:	597d                	li	s2,-1
    80001ea0:	b7ed                	j	80001e8a <fork+0x128>

0000000080001ea2 <scheduler>:
{
    80001ea2:	7139                	addi	sp,sp,-64
    80001ea4:	fc06                	sd	ra,56(sp)
    80001ea6:	f822                	sd	s0,48(sp)
    80001ea8:	f426                	sd	s1,40(sp)
    80001eaa:	f04a                	sd	s2,32(sp)
    80001eac:	ec4e                	sd	s3,24(sp)
    80001eae:	e852                	sd	s4,16(sp)
    80001eb0:	e456                	sd	s5,8(sp)
    80001eb2:	e05a                	sd	s6,0(sp)
    80001eb4:	0080                	addi	s0,sp,64
    80001eb6:	8792                	mv	a5,tp
  int id = r_tp();
    80001eb8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eba:	00779a93          	slli	s5,a5,0x7
    80001ebe:	0000f717          	auipc	a4,0xf
    80001ec2:	cb270713          	addi	a4,a4,-846 # 80010b70 <pid_lock>
    80001ec6:	9756                	add	a4,a4,s5
    80001ec8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ecc:	0000f717          	auipc	a4,0xf
    80001ed0:	cdc70713          	addi	a4,a4,-804 # 80010ba8 <cpus+0x8>
    80001ed4:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed6:	498d                	li	s3,3
        p->state = RUNNING;
    80001ed8:	4b11                	li	s6,4
        c->proc = p;
    80001eda:	079e                	slli	a5,a5,0x7
    80001edc:	0000fa17          	auipc	s4,0xf
    80001ee0:	c94a0a13          	addi	s4,s4,-876 # 80010b70 <pid_lock>
    80001ee4:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee6:	00015917          	auipc	s2,0x15
    80001eea:	aba90913          	addi	s2,s2,-1350 # 800169a0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef6:	10079073          	csrw	sstatus,a5
    80001efa:	0000f497          	auipc	s1,0xf
    80001efe:	0a648493          	addi	s1,s1,166 # 80010fa0 <proc>
    80001f02:	a811                	j	80001f16 <scheduler+0x74>
      release(&p->lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	d84080e7          	jalr	-636(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	16848493          	addi	s1,s1,360
    80001f12:	fd248ee3          	beq	s1,s2,80001eee <scheduler+0x4c>
      acquire(&p->lock);
    80001f16:	8526                	mv	a0,s1
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	cbe080e7          	jalr	-834(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f20:	4c9c                	lw	a5,24(s1)
    80001f22:	ff3791e3          	bne	a5,s3,80001f04 <scheduler+0x62>
        p->state = RUNNING;
    80001f26:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f2a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f2e:	06048593          	addi	a1,s1,96
    80001f32:	8556                	mv	a0,s5
    80001f34:	00000097          	auipc	ra,0x0
    80001f38:	6f2080e7          	jalr	1778(ra) # 80002626 <swtch>
        c->proc = 0;
    80001f3c:	020a3823          	sd	zero,48(s4)
    80001f40:	b7d1                	j	80001f04 <scheduler+0x62>

0000000080001f42 <sched>:
{
    80001f42:	7179                	addi	sp,sp,-48
    80001f44:	f406                	sd	ra,40(sp)
    80001f46:	f022                	sd	s0,32(sp)
    80001f48:	ec26                	sd	s1,24(sp)
    80001f4a:	e84a                	sd	s2,16(sp)
    80001f4c:	e44e                	sd	s3,8(sp)
    80001f4e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f50:	00000097          	auipc	ra,0x0
    80001f54:	a5c080e7          	jalr	-1444(ra) # 800019ac <myproc>
    80001f58:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	c02080e7          	jalr	-1022(ra) # 80000b5c <holding>
    80001f62:	c93d                	beqz	a0,80001fd8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f64:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f66:	2781                	sext.w	a5,a5
    80001f68:	079e                	slli	a5,a5,0x7
    80001f6a:	0000f717          	auipc	a4,0xf
    80001f6e:	c0670713          	addi	a4,a4,-1018 # 80010b70 <pid_lock>
    80001f72:	97ba                	add	a5,a5,a4
    80001f74:	0a87a703          	lw	a4,168(a5)
    80001f78:	4785                	li	a5,1
    80001f7a:	06f71763          	bne	a4,a5,80001fe8 <sched+0xa6>
  if(p->state == RUNNING)
    80001f7e:	4c98                	lw	a4,24(s1)
    80001f80:	4791                	li	a5,4
    80001f82:	06f70b63          	beq	a4,a5,80001ff8 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f86:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f8a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f8c:	efb5                	bnez	a5,80002008 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f8e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f90:	0000f917          	auipc	s2,0xf
    80001f94:	be090913          	addi	s2,s2,-1056 # 80010b70 <pid_lock>
    80001f98:	2781                	sext.w	a5,a5
    80001f9a:	079e                	slli	a5,a5,0x7
    80001f9c:	97ca                	add	a5,a5,s2
    80001f9e:	0ac7a983          	lw	s3,172(a5)
    80001fa2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fa4:	2781                	sext.w	a5,a5
    80001fa6:	079e                	slli	a5,a5,0x7
    80001fa8:	0000f597          	auipc	a1,0xf
    80001fac:	c0058593          	addi	a1,a1,-1024 # 80010ba8 <cpus+0x8>
    80001fb0:	95be                	add	a1,a1,a5
    80001fb2:	06048513          	addi	a0,s1,96
    80001fb6:	00000097          	auipc	ra,0x0
    80001fba:	670080e7          	jalr	1648(ra) # 80002626 <swtch>
    80001fbe:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc0:	2781                	sext.w	a5,a5
    80001fc2:	079e                	slli	a5,a5,0x7
    80001fc4:	993e                	add	s2,s2,a5
    80001fc6:	0b392623          	sw	s3,172(s2)
}
    80001fca:	70a2                	ld	ra,40(sp)
    80001fcc:	7402                	ld	s0,32(sp)
    80001fce:	64e2                	ld	s1,24(sp)
    80001fd0:	6942                	ld	s2,16(sp)
    80001fd2:	69a2                	ld	s3,8(sp)
    80001fd4:	6145                	addi	sp,sp,48
    80001fd6:	8082                	ret
    panic("sched p->lock");
    80001fd8:	00006517          	auipc	a0,0x6
    80001fdc:	24050513          	addi	a0,a0,576 # 80008218 <digits+0x1d8>
    80001fe0:	ffffe097          	auipc	ra,0xffffe
    80001fe4:	560080e7          	jalr	1376(ra) # 80000540 <panic>
    panic("sched locks");
    80001fe8:	00006517          	auipc	a0,0x6
    80001fec:	24050513          	addi	a0,a0,576 # 80008228 <digits+0x1e8>
    80001ff0:	ffffe097          	auipc	ra,0xffffe
    80001ff4:	550080e7          	jalr	1360(ra) # 80000540 <panic>
    panic("sched running");
    80001ff8:	00006517          	auipc	a0,0x6
    80001ffc:	24050513          	addi	a0,a0,576 # 80008238 <digits+0x1f8>
    80002000:	ffffe097          	auipc	ra,0xffffe
    80002004:	540080e7          	jalr	1344(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002008:	00006517          	auipc	a0,0x6
    8000200c:	24050513          	addi	a0,a0,576 # 80008248 <digits+0x208>
    80002010:	ffffe097          	auipc	ra,0xffffe
    80002014:	530080e7          	jalr	1328(ra) # 80000540 <panic>

0000000080002018 <yield>:
{
    80002018:	1101                	addi	sp,sp,-32
    8000201a:	ec06                	sd	ra,24(sp)
    8000201c:	e822                	sd	s0,16(sp)
    8000201e:	e426                	sd	s1,8(sp)
    80002020:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002022:	00000097          	auipc	ra,0x0
    80002026:	98a080e7          	jalr	-1654(ra) # 800019ac <myproc>
    8000202a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000202c:	fffff097          	auipc	ra,0xfffff
    80002030:	baa080e7          	jalr	-1110(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002034:	478d                	li	a5,3
    80002036:	cc9c                	sw	a5,24(s1)
  sched();
    80002038:	00000097          	auipc	ra,0x0
    8000203c:	f0a080e7          	jalr	-246(ra) # 80001f42 <sched>
  release(&p->lock);
    80002040:	8526                	mv	a0,s1
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	c48080e7          	jalr	-952(ra) # 80000c8a <release>
}
    8000204a:	60e2                	ld	ra,24(sp)
    8000204c:	6442                	ld	s0,16(sp)
    8000204e:	64a2                	ld	s1,8(sp)
    80002050:	6105                	addi	sp,sp,32
    80002052:	8082                	ret

0000000080002054 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002054:	7179                	addi	sp,sp,-48
    80002056:	f406                	sd	ra,40(sp)
    80002058:	f022                	sd	s0,32(sp)
    8000205a:	ec26                	sd	s1,24(sp)
    8000205c:	e84a                	sd	s2,16(sp)
    8000205e:	e44e                	sd	s3,8(sp)
    80002060:	1800                	addi	s0,sp,48
    80002062:	89aa                	mv	s3,a0
    80002064:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002066:	00000097          	auipc	ra,0x0
    8000206a:	946080e7          	jalr	-1722(ra) # 800019ac <myproc>
    8000206e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	b66080e7          	jalr	-1178(ra) # 80000bd6 <acquire>
  release(lk);
    80002078:	854a                	mv	a0,s2
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	c10080e7          	jalr	-1008(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002082:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002086:	4789                	li	a5,2
    80002088:	cc9c                	sw	a5,24(s1)

  sched();
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	eb8080e7          	jalr	-328(ra) # 80001f42 <sched>

  // Tidy up.
  p->chan = 0;
    80002092:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	bf2080e7          	jalr	-1038(ra) # 80000c8a <release>
  acquire(lk);
    800020a0:	854a                	mv	a0,s2
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	b34080e7          	jalr	-1228(ra) # 80000bd6 <acquire>
}
    800020aa:	70a2                	ld	ra,40(sp)
    800020ac:	7402                	ld	s0,32(sp)
    800020ae:	64e2                	ld	s1,24(sp)
    800020b0:	6942                	ld	s2,16(sp)
    800020b2:	69a2                	ld	s3,8(sp)
    800020b4:	6145                	addi	sp,sp,48
    800020b6:	8082                	ret

00000000800020b8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020b8:	7139                	addi	sp,sp,-64
    800020ba:	fc06                	sd	ra,56(sp)
    800020bc:	f822                	sd	s0,48(sp)
    800020be:	f426                	sd	s1,40(sp)
    800020c0:	f04a                	sd	s2,32(sp)
    800020c2:	ec4e                	sd	s3,24(sp)
    800020c4:	e852                	sd	s4,16(sp)
    800020c6:	e456                	sd	s5,8(sp)
    800020c8:	0080                	addi	s0,sp,64
    800020ca:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020cc:	0000f497          	auipc	s1,0xf
    800020d0:	ed448493          	addi	s1,s1,-300 # 80010fa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020d4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020d6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d8:	00015917          	auipc	s2,0x15
    800020dc:	8c890913          	addi	s2,s2,-1848 # 800169a0 <tickslock>
    800020e0:	a811                	j	800020f4 <wakeup+0x3c>
      }
      release(&p->lock);
    800020e2:	8526                	mv	a0,s1
    800020e4:	fffff097          	auipc	ra,0xfffff
    800020e8:	ba6080e7          	jalr	-1114(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ec:	16848493          	addi	s1,s1,360
    800020f0:	03248663          	beq	s1,s2,8000211c <wakeup+0x64>
    if(p != myproc()){
    800020f4:	00000097          	auipc	ra,0x0
    800020f8:	8b8080e7          	jalr	-1864(ra) # 800019ac <myproc>
    800020fc:	fea488e3          	beq	s1,a0,800020ec <wakeup+0x34>
      acquire(&p->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	ad4080e7          	jalr	-1324(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000210a:	4c9c                	lw	a5,24(s1)
    8000210c:	fd379be3          	bne	a5,s3,800020e2 <wakeup+0x2a>
    80002110:	709c                	ld	a5,32(s1)
    80002112:	fd4798e3          	bne	a5,s4,800020e2 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002116:	0154ac23          	sw	s5,24(s1)
    8000211a:	b7e1                	j	800020e2 <wakeup+0x2a>
    }
  }
}
    8000211c:	70e2                	ld	ra,56(sp)
    8000211e:	7442                	ld	s0,48(sp)
    80002120:	74a2                	ld	s1,40(sp)
    80002122:	7902                	ld	s2,32(sp)
    80002124:	69e2                	ld	s3,24(sp)
    80002126:	6a42                	ld	s4,16(sp)
    80002128:	6aa2                	ld	s5,8(sp)
    8000212a:	6121                	addi	sp,sp,64
    8000212c:	8082                	ret

000000008000212e <reparent>:
{
    8000212e:	7179                	addi	sp,sp,-48
    80002130:	f406                	sd	ra,40(sp)
    80002132:	f022                	sd	s0,32(sp)
    80002134:	ec26                	sd	s1,24(sp)
    80002136:	e84a                	sd	s2,16(sp)
    80002138:	e44e                	sd	s3,8(sp)
    8000213a:	e052                	sd	s4,0(sp)
    8000213c:	1800                	addi	s0,sp,48
    8000213e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002140:	0000f497          	auipc	s1,0xf
    80002144:	e6048493          	addi	s1,s1,-416 # 80010fa0 <proc>
      pp->parent = initproc;
    80002148:	00006a17          	auipc	s4,0x6
    8000214c:	7b0a0a13          	addi	s4,s4,1968 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002150:	00015997          	auipc	s3,0x15
    80002154:	85098993          	addi	s3,s3,-1968 # 800169a0 <tickslock>
    80002158:	a029                	j	80002162 <reparent+0x34>
    8000215a:	16848493          	addi	s1,s1,360
    8000215e:	01348d63          	beq	s1,s3,80002178 <reparent+0x4a>
    if(pp->parent == p){
    80002162:	7c9c                	ld	a5,56(s1)
    80002164:	ff279be3          	bne	a5,s2,8000215a <reparent+0x2c>
      pp->parent = initproc;
    80002168:	000a3503          	ld	a0,0(s4)
    8000216c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000216e:	00000097          	auipc	ra,0x0
    80002172:	f4a080e7          	jalr	-182(ra) # 800020b8 <wakeup>
    80002176:	b7d5                	j	8000215a <reparent+0x2c>
}
    80002178:	70a2                	ld	ra,40(sp)
    8000217a:	7402                	ld	s0,32(sp)
    8000217c:	64e2                	ld	s1,24(sp)
    8000217e:	6942                	ld	s2,16(sp)
    80002180:	69a2                	ld	s3,8(sp)
    80002182:	6a02                	ld	s4,0(sp)
    80002184:	6145                	addi	sp,sp,48
    80002186:	8082                	ret

0000000080002188 <exit>:
{
    80002188:	7179                	addi	sp,sp,-48
    8000218a:	f406                	sd	ra,40(sp)
    8000218c:	f022                	sd	s0,32(sp)
    8000218e:	ec26                	sd	s1,24(sp)
    80002190:	e84a                	sd	s2,16(sp)
    80002192:	e44e                	sd	s3,8(sp)
    80002194:	e052                	sd	s4,0(sp)
    80002196:	1800                	addi	s0,sp,48
    80002198:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000219a:	00000097          	auipc	ra,0x0
    8000219e:	812080e7          	jalr	-2030(ra) # 800019ac <myproc>
    800021a2:	89aa                	mv	s3,a0
  if(p == initproc)
    800021a4:	00006797          	auipc	a5,0x6
    800021a8:	7547b783          	ld	a5,1876(a5) # 800088f8 <initproc>
    800021ac:	0d050493          	addi	s1,a0,208
    800021b0:	15050913          	addi	s2,a0,336
    800021b4:	02a79363          	bne	a5,a0,800021da <exit+0x52>
    panic("init exiting");
    800021b8:	00006517          	auipc	a0,0x6
    800021bc:	0a850513          	addi	a0,a0,168 # 80008260 <digits+0x220>
    800021c0:	ffffe097          	auipc	ra,0xffffe
    800021c4:	380080e7          	jalr	896(ra) # 80000540 <panic>
      fileclose(f);
    800021c8:	00002097          	auipc	ra,0x2
    800021cc:	366080e7          	jalr	870(ra) # 8000452e <fileclose>
      p->ofile[fd] = 0;
    800021d0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021d4:	04a1                	addi	s1,s1,8
    800021d6:	01248563          	beq	s1,s2,800021e0 <exit+0x58>
    if(p->ofile[fd]){
    800021da:	6088                	ld	a0,0(s1)
    800021dc:	f575                	bnez	a0,800021c8 <exit+0x40>
    800021de:	bfdd                	j	800021d4 <exit+0x4c>
  begin_op();
    800021e0:	00002097          	auipc	ra,0x2
    800021e4:	e86080e7          	jalr	-378(ra) # 80004066 <begin_op>
  iput(p->cwd);
    800021e8:	1509b503          	ld	a0,336(s3)
    800021ec:	00001097          	auipc	ra,0x1
    800021f0:	668080e7          	jalr	1640(ra) # 80003854 <iput>
  end_op();
    800021f4:	00002097          	auipc	ra,0x2
    800021f8:	ef0080e7          	jalr	-272(ra) # 800040e4 <end_op>
  p->cwd = 0;
    800021fc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002200:	0000f497          	auipc	s1,0xf
    80002204:	98848493          	addi	s1,s1,-1656 # 80010b88 <wait_lock>
    80002208:	8526                	mv	a0,s1
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	9cc080e7          	jalr	-1588(ra) # 80000bd6 <acquire>
  reparent(p);
    80002212:	854e                	mv	a0,s3
    80002214:	00000097          	auipc	ra,0x0
    80002218:	f1a080e7          	jalr	-230(ra) # 8000212e <reparent>
  wakeup(p->parent);
    8000221c:	0389b503          	ld	a0,56(s3)
    80002220:	00000097          	auipc	ra,0x0
    80002224:	e98080e7          	jalr	-360(ra) # 800020b8 <wakeup>
  acquire(&p->lock);
    80002228:	854e                	mv	a0,s3
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	9ac080e7          	jalr	-1620(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002232:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002236:	4795                	li	a5,5
    80002238:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000223c:	8526                	mv	a0,s1
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	a4c080e7          	jalr	-1460(ra) # 80000c8a <release>
  sched();
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	cfc080e7          	jalr	-772(ra) # 80001f42 <sched>
  panic("zombie exit");
    8000224e:	00006517          	auipc	a0,0x6
    80002252:	02250513          	addi	a0,a0,34 # 80008270 <digits+0x230>
    80002256:	ffffe097          	auipc	ra,0xffffe
    8000225a:	2ea080e7          	jalr	746(ra) # 80000540 <panic>

000000008000225e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000225e:	7179                	addi	sp,sp,-48
    80002260:	f406                	sd	ra,40(sp)
    80002262:	f022                	sd	s0,32(sp)
    80002264:	ec26                	sd	s1,24(sp)
    80002266:	e84a                	sd	s2,16(sp)
    80002268:	e44e                	sd	s3,8(sp)
    8000226a:	1800                	addi	s0,sp,48
    8000226c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000226e:	0000f497          	auipc	s1,0xf
    80002272:	d3248493          	addi	s1,s1,-718 # 80010fa0 <proc>
    80002276:	00014997          	auipc	s3,0x14
    8000227a:	72a98993          	addi	s3,s3,1834 # 800169a0 <tickslock>
    acquire(&p->lock);
    8000227e:	8526                	mv	a0,s1
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	956080e7          	jalr	-1706(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002288:	589c                	lw	a5,48(s1)
    8000228a:	01278d63          	beq	a5,s2,800022a4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000228e:	8526                	mv	a0,s1
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	9fa080e7          	jalr	-1542(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002298:	16848493          	addi	s1,s1,360
    8000229c:	ff3491e3          	bne	s1,s3,8000227e <kill+0x20>
  }
  return -1;
    800022a0:	557d                	li	a0,-1
    800022a2:	a829                	j	800022bc <kill+0x5e>
      p->killed = 1;
    800022a4:	4785                	li	a5,1
    800022a6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022a8:	4c98                	lw	a4,24(s1)
    800022aa:	4789                	li	a5,2
    800022ac:	00f70f63          	beq	a4,a5,800022ca <kill+0x6c>
      release(&p->lock);
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	9d8080e7          	jalr	-1576(ra) # 80000c8a <release>
      return 0;
    800022ba:	4501                	li	a0,0
}
    800022bc:	70a2                	ld	ra,40(sp)
    800022be:	7402                	ld	s0,32(sp)
    800022c0:	64e2                	ld	s1,24(sp)
    800022c2:	6942                	ld	s2,16(sp)
    800022c4:	69a2                	ld	s3,8(sp)
    800022c6:	6145                	addi	sp,sp,48
    800022c8:	8082                	ret
        p->state = RUNNABLE;
    800022ca:	478d                	li	a5,3
    800022cc:	cc9c                	sw	a5,24(s1)
    800022ce:	b7cd                	j	800022b0 <kill+0x52>

00000000800022d0 <setkilled>:

void
setkilled(struct proc *p)
{
    800022d0:	1101                	addi	sp,sp,-32
    800022d2:	ec06                	sd	ra,24(sp)
    800022d4:	e822                	sd	s0,16(sp)
    800022d6:	e426                	sd	s1,8(sp)
    800022d8:	1000                	addi	s0,sp,32
    800022da:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	8fa080e7          	jalr	-1798(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022e4:	4785                	li	a5,1
    800022e6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	9a0080e7          	jalr	-1632(ra) # 80000c8a <release>
}
    800022f2:	60e2                	ld	ra,24(sp)
    800022f4:	6442                	ld	s0,16(sp)
    800022f6:	64a2                	ld	s1,8(sp)
    800022f8:	6105                	addi	sp,sp,32
    800022fa:	8082                	ret

00000000800022fc <killed>:

int
killed(struct proc *p)
{
    800022fc:	1101                	addi	sp,sp,-32
    800022fe:	ec06                	sd	ra,24(sp)
    80002300:	e822                	sd	s0,16(sp)
    80002302:	e426                	sd	s1,8(sp)
    80002304:	e04a                	sd	s2,0(sp)
    80002306:	1000                	addi	s0,sp,32
    80002308:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	8cc080e7          	jalr	-1844(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002312:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002316:	8526                	mv	a0,s1
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	972080e7          	jalr	-1678(ra) # 80000c8a <release>
  return k;
}
    80002320:	854a                	mv	a0,s2
    80002322:	60e2                	ld	ra,24(sp)
    80002324:	6442                	ld	s0,16(sp)
    80002326:	64a2                	ld	s1,8(sp)
    80002328:	6902                	ld	s2,0(sp)
    8000232a:	6105                	addi	sp,sp,32
    8000232c:	8082                	ret

000000008000232e <wait>:
{
    8000232e:	715d                	addi	sp,sp,-80
    80002330:	e486                	sd	ra,72(sp)
    80002332:	e0a2                	sd	s0,64(sp)
    80002334:	fc26                	sd	s1,56(sp)
    80002336:	f84a                	sd	s2,48(sp)
    80002338:	f44e                	sd	s3,40(sp)
    8000233a:	f052                	sd	s4,32(sp)
    8000233c:	ec56                	sd	s5,24(sp)
    8000233e:	e85a                	sd	s6,16(sp)
    80002340:	e45e                	sd	s7,8(sp)
    80002342:	e062                	sd	s8,0(sp)
    80002344:	0880                	addi	s0,sp,80
    80002346:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	664080e7          	jalr	1636(ra) # 800019ac <myproc>
    80002350:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002352:	0000f517          	auipc	a0,0xf
    80002356:	83650513          	addi	a0,a0,-1994 # 80010b88 <wait_lock>
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	87c080e7          	jalr	-1924(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002362:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002364:	4a15                	li	s4,5
        havekids = 1;
    80002366:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002368:	00014997          	auipc	s3,0x14
    8000236c:	63898993          	addi	s3,s3,1592 # 800169a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002370:	0000fc17          	auipc	s8,0xf
    80002374:	818c0c13          	addi	s8,s8,-2024 # 80010b88 <wait_lock>
    havekids = 0;
    80002378:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000237a:	0000f497          	auipc	s1,0xf
    8000237e:	c2648493          	addi	s1,s1,-986 # 80010fa0 <proc>
    80002382:	a0bd                	j	800023f0 <wait+0xc2>
          pid = pp->pid;
    80002384:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002388:	000b0e63          	beqz	s6,800023a4 <wait+0x76>
    8000238c:	4691                	li	a3,4
    8000238e:	02c48613          	addi	a2,s1,44
    80002392:	85da                	mv	a1,s6
    80002394:	05093503          	ld	a0,80(s2)
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	2d4080e7          	jalr	724(ra) # 8000166c <copyout>
    800023a0:	02054563          	bltz	a0,800023ca <wait+0x9c>
          freeproc(pp);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	7b8080e7          	jalr	1976(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	8da080e7          	jalr	-1830(ra) # 80000c8a <release>
          release(&wait_lock);
    800023b8:	0000e517          	auipc	a0,0xe
    800023bc:	7d050513          	addi	a0,a0,2000 # 80010b88 <wait_lock>
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	8ca080e7          	jalr	-1846(ra) # 80000c8a <release>
          return pid;
    800023c8:	a0b5                	j	80002434 <wait+0x106>
            release(&pp->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	8be080e7          	jalr	-1858(ra) # 80000c8a <release>
            release(&wait_lock);
    800023d4:	0000e517          	auipc	a0,0xe
    800023d8:	7b450513          	addi	a0,a0,1972 # 80010b88 <wait_lock>
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	8ae080e7          	jalr	-1874(ra) # 80000c8a <release>
            return -1;
    800023e4:	59fd                	li	s3,-1
    800023e6:	a0b9                	j	80002434 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023e8:	16848493          	addi	s1,s1,360
    800023ec:	03348463          	beq	s1,s3,80002414 <wait+0xe6>
      if(pp->parent == p){
    800023f0:	7c9c                	ld	a5,56(s1)
    800023f2:	ff279be3          	bne	a5,s2,800023e8 <wait+0xba>
        acquire(&pp->lock);
    800023f6:	8526                	mv	a0,s1
    800023f8:	ffffe097          	auipc	ra,0xffffe
    800023fc:	7de080e7          	jalr	2014(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002400:	4c9c                	lw	a5,24(s1)
    80002402:	f94781e3          	beq	a5,s4,80002384 <wait+0x56>
        release(&pp->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	882080e7          	jalr	-1918(ra) # 80000c8a <release>
        havekids = 1;
    80002410:	8756                	mv	a4,s5
    80002412:	bfd9                	j	800023e8 <wait+0xba>
    if(!havekids || killed(p)){
    80002414:	c719                	beqz	a4,80002422 <wait+0xf4>
    80002416:	854a                	mv	a0,s2
    80002418:	00000097          	auipc	ra,0x0
    8000241c:	ee4080e7          	jalr	-284(ra) # 800022fc <killed>
    80002420:	c51d                	beqz	a0,8000244e <wait+0x120>
      release(&wait_lock);
    80002422:	0000e517          	auipc	a0,0xe
    80002426:	76650513          	addi	a0,a0,1894 # 80010b88 <wait_lock>
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	860080e7          	jalr	-1952(ra) # 80000c8a <release>
      return -1;
    80002432:	59fd                	li	s3,-1
}
    80002434:	854e                	mv	a0,s3
    80002436:	60a6                	ld	ra,72(sp)
    80002438:	6406                	ld	s0,64(sp)
    8000243a:	74e2                	ld	s1,56(sp)
    8000243c:	7942                	ld	s2,48(sp)
    8000243e:	79a2                	ld	s3,40(sp)
    80002440:	7a02                	ld	s4,32(sp)
    80002442:	6ae2                	ld	s5,24(sp)
    80002444:	6b42                	ld	s6,16(sp)
    80002446:	6ba2                	ld	s7,8(sp)
    80002448:	6c02                	ld	s8,0(sp)
    8000244a:	6161                	addi	sp,sp,80
    8000244c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000244e:	85e2                	mv	a1,s8
    80002450:	854a                	mv	a0,s2
    80002452:	00000097          	auipc	ra,0x0
    80002456:	c02080e7          	jalr	-1022(ra) # 80002054 <sleep>
    havekids = 0;
    8000245a:	bf39                	j	80002378 <wait+0x4a>

000000008000245c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000245c:	7179                	addi	sp,sp,-48
    8000245e:	f406                	sd	ra,40(sp)
    80002460:	f022                	sd	s0,32(sp)
    80002462:	ec26                	sd	s1,24(sp)
    80002464:	e84a                	sd	s2,16(sp)
    80002466:	e44e                	sd	s3,8(sp)
    80002468:	e052                	sd	s4,0(sp)
    8000246a:	1800                	addi	s0,sp,48
    8000246c:	84aa                	mv	s1,a0
    8000246e:	892e                	mv	s2,a1
    80002470:	89b2                	mv	s3,a2
    80002472:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	538080e7          	jalr	1336(ra) # 800019ac <myproc>
  if(user_dst){
    8000247c:	c08d                	beqz	s1,8000249e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000247e:	86d2                	mv	a3,s4
    80002480:	864e                	mv	a2,s3
    80002482:	85ca                	mv	a1,s2
    80002484:	6928                	ld	a0,80(a0)
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	1e6080e7          	jalr	486(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000248e:	70a2                	ld	ra,40(sp)
    80002490:	7402                	ld	s0,32(sp)
    80002492:	64e2                	ld	s1,24(sp)
    80002494:	6942                	ld	s2,16(sp)
    80002496:	69a2                	ld	s3,8(sp)
    80002498:	6a02                	ld	s4,0(sp)
    8000249a:	6145                	addi	sp,sp,48
    8000249c:	8082                	ret
    memmove((char *)dst, src, len);
    8000249e:	000a061b          	sext.w	a2,s4
    800024a2:	85ce                	mv	a1,s3
    800024a4:	854a                	mv	a0,s2
    800024a6:	fffff097          	auipc	ra,0xfffff
    800024aa:	888080e7          	jalr	-1912(ra) # 80000d2e <memmove>
    return 0;
    800024ae:	8526                	mv	a0,s1
    800024b0:	bff9                	j	8000248e <either_copyout+0x32>

00000000800024b2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024b2:	7179                	addi	sp,sp,-48
    800024b4:	f406                	sd	ra,40(sp)
    800024b6:	f022                	sd	s0,32(sp)
    800024b8:	ec26                	sd	s1,24(sp)
    800024ba:	e84a                	sd	s2,16(sp)
    800024bc:	e44e                	sd	s3,8(sp)
    800024be:	e052                	sd	s4,0(sp)
    800024c0:	1800                	addi	s0,sp,48
    800024c2:	892a                	mv	s2,a0
    800024c4:	84ae                	mv	s1,a1
    800024c6:	89b2                	mv	s3,a2
    800024c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	4e2080e7          	jalr	1250(ra) # 800019ac <myproc>
  if(user_src){
    800024d2:	c08d                	beqz	s1,800024f4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024d4:	86d2                	mv	a3,s4
    800024d6:	864e                	mv	a2,s3
    800024d8:	85ca                	mv	a1,s2
    800024da:	6928                	ld	a0,80(a0)
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	21c080e7          	jalr	540(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024e4:	70a2                	ld	ra,40(sp)
    800024e6:	7402                	ld	s0,32(sp)
    800024e8:	64e2                	ld	s1,24(sp)
    800024ea:	6942                	ld	s2,16(sp)
    800024ec:	69a2                	ld	s3,8(sp)
    800024ee:	6a02                	ld	s4,0(sp)
    800024f0:	6145                	addi	sp,sp,48
    800024f2:	8082                	ret
    memmove(dst, (char*)src, len);
    800024f4:	000a061b          	sext.w	a2,s4
    800024f8:	85ce                	mv	a1,s3
    800024fa:	854a                	mv	a0,s2
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	832080e7          	jalr	-1998(ra) # 80000d2e <memmove>
    return 0;
    80002504:	8526                	mv	a0,s1
    80002506:	bff9                	j	800024e4 <either_copyin+0x32>

0000000080002508 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002508:	715d                	addi	sp,sp,-80
    8000250a:	e486                	sd	ra,72(sp)
    8000250c:	e0a2                	sd	s0,64(sp)
    8000250e:	fc26                	sd	s1,56(sp)
    80002510:	f84a                	sd	s2,48(sp)
    80002512:	f44e                	sd	s3,40(sp)
    80002514:	f052                	sd	s4,32(sp)
    80002516:	ec56                	sd	s5,24(sp)
    80002518:	e85a                	sd	s6,16(sp)
    8000251a:	e45e                	sd	s7,8(sp)
    8000251c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000251e:	00006517          	auipc	a0,0x6
    80002522:	baa50513          	addi	a0,a0,-1110 # 800080c8 <digits+0x88>
    80002526:	ffffe097          	auipc	ra,0xffffe
    8000252a:	064080e7          	jalr	100(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000252e:	0000f497          	auipc	s1,0xf
    80002532:	bca48493          	addi	s1,s1,-1078 # 800110f8 <proc+0x158>
    80002536:	00014917          	auipc	s2,0x14
    8000253a:	5c290913          	addi	s2,s2,1474 # 80016af8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000253e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002540:	00006997          	auipc	s3,0x6
    80002544:	d4098993          	addi	s3,s3,-704 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002548:	00006a97          	auipc	s5,0x6
    8000254c:	d40a8a93          	addi	s5,s5,-704 # 80008288 <digits+0x248>
    printf("\n");
    80002550:	00006a17          	auipc	s4,0x6
    80002554:	b78a0a13          	addi	s4,s4,-1160 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002558:	00006b97          	auipc	s7,0x6
    8000255c:	d88b8b93          	addi	s7,s7,-632 # 800082e0 <states.0>
    80002560:	a00d                	j	80002582 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002562:	ed86a583          	lw	a1,-296(a3)
    80002566:	8556                	mv	a0,s5
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	022080e7          	jalr	34(ra) # 8000058a <printf>
    printf("\n");
    80002570:	8552                	mv	a0,s4
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	018080e7          	jalr	24(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257a:	16848493          	addi	s1,s1,360
    8000257e:	03248263          	beq	s1,s2,800025a2 <procdump+0x9a>
    if(p->state == UNUSED)
    80002582:	86a6                	mv	a3,s1
    80002584:	ec04a783          	lw	a5,-320(s1)
    80002588:	dbed                	beqz	a5,8000257a <procdump+0x72>
      state = "???";
    8000258a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000258c:	fcfb6be3          	bltu	s6,a5,80002562 <procdump+0x5a>
    80002590:	02079713          	slli	a4,a5,0x20
    80002594:	01d75793          	srli	a5,a4,0x1d
    80002598:	97de                	add	a5,a5,s7
    8000259a:	6390                	ld	a2,0(a5)
    8000259c:	f279                	bnez	a2,80002562 <procdump+0x5a>
      state = "???";
    8000259e:	864e                	mv	a2,s3
    800025a0:	b7c9                	j	80002562 <procdump+0x5a>
  }
}
    800025a2:	60a6                	ld	ra,72(sp)
    800025a4:	6406                	ld	s0,64(sp)
    800025a6:	74e2                	ld	s1,56(sp)
    800025a8:	7942                	ld	s2,48(sp)
    800025aa:	79a2                	ld	s3,40(sp)
    800025ac:	7a02                	ld	s4,32(sp)
    800025ae:	6ae2                	ld	s5,24(sp)
    800025b0:	6b42                	ld	s6,16(sp)
    800025b2:	6ba2                	ld	s7,8(sp)
    800025b4:	6161                	addi	sp,sp,80
    800025b6:	8082                	ret

00000000800025b8 <ps>:

// CODE
void ps(){
    800025b8:	7179                	addi	sp,sp,-48
    800025ba:	f406                	sd	ra,40(sp)
    800025bc:	f022                	sd	s0,32(sp)
    800025be:	ec26                	sd	s1,24(sp)
    800025c0:	e84a                	sd	s2,16(sp)
    800025c2:	e44e                	sd	s3,8(sp)
    800025c4:	e052                	sd	s4,0(sp)
    800025c6:	1800                	addi	s0,sp,48
	struct proc *p;
	printf("PID\t\tNAME\n");
    800025c8:	00006517          	auipc	a0,0x6
    800025cc:	cd050513          	addi	a0,a0,-816 # 80008298 <digits+0x258>
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	fba080e7          	jalr	-70(ra) # 8000058a <printf>
	for(p = proc; p < &proc[NPROC]; p++)
    800025d8:	0000f497          	auipc	s1,0xf
    800025dc:	b2048493          	addi	s1,s1,-1248 # 800110f8 <proc+0x158>
    800025e0:	00014997          	auipc	s3,0x14
    800025e4:	51898993          	addi	s3,s3,1304 # 80016af8 <bcache+0x140>
		if(p->state == RUNNING)
    800025e8:	4911                	li	s2,4
			printf("%d\t\t%s\n", p->pid, p->name);
    800025ea:	00006a17          	auipc	s4,0x6
    800025ee:	cbea0a13          	addi	s4,s4,-834 # 800082a8 <digits+0x268>
    800025f2:	a029                	j	800025fc <ps+0x44>
	for(p = proc; p < &proc[NPROC]; p++)
    800025f4:	16848493          	addi	s1,s1,360
    800025f8:	01348f63          	beq	s1,s3,80002616 <ps+0x5e>
		if(p->state == RUNNING)
    800025fc:	ec04a783          	lw	a5,-320(s1)
    80002600:	ff279ae3          	bne	a5,s2,800025f4 <ps+0x3c>
			printf("%d\t\t%s\n", p->pid, p->name);
    80002604:	8626                	mv	a2,s1
    80002606:	ed84a583          	lw	a1,-296(s1)
    8000260a:	8552                	mv	a0,s4
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	f7e080e7          	jalr	-130(ra) # 8000058a <printf>
    80002614:	b7c5                	j	800025f4 <ps+0x3c>
}
    80002616:	70a2                	ld	ra,40(sp)
    80002618:	7402                	ld	s0,32(sp)
    8000261a:	64e2                	ld	s1,24(sp)
    8000261c:	6942                	ld	s2,16(sp)
    8000261e:	69a2                	ld	s3,8(sp)
    80002620:	6a02                	ld	s4,0(sp)
    80002622:	6145                	addi	sp,sp,48
    80002624:	8082                	ret

0000000080002626 <swtch>:
    80002626:	00153023          	sd	ra,0(a0)
    8000262a:	00253423          	sd	sp,8(a0)
    8000262e:	e900                	sd	s0,16(a0)
    80002630:	ed04                	sd	s1,24(a0)
    80002632:	03253023          	sd	s2,32(a0)
    80002636:	03353423          	sd	s3,40(a0)
    8000263a:	03453823          	sd	s4,48(a0)
    8000263e:	03553c23          	sd	s5,56(a0)
    80002642:	05653023          	sd	s6,64(a0)
    80002646:	05753423          	sd	s7,72(a0)
    8000264a:	05853823          	sd	s8,80(a0)
    8000264e:	05953c23          	sd	s9,88(a0)
    80002652:	07a53023          	sd	s10,96(a0)
    80002656:	07b53423          	sd	s11,104(a0)
    8000265a:	0005b083          	ld	ra,0(a1)
    8000265e:	0085b103          	ld	sp,8(a1)
    80002662:	6980                	ld	s0,16(a1)
    80002664:	6d84                	ld	s1,24(a1)
    80002666:	0205b903          	ld	s2,32(a1)
    8000266a:	0285b983          	ld	s3,40(a1)
    8000266e:	0305ba03          	ld	s4,48(a1)
    80002672:	0385ba83          	ld	s5,56(a1)
    80002676:	0405bb03          	ld	s6,64(a1)
    8000267a:	0485bb83          	ld	s7,72(a1)
    8000267e:	0505bc03          	ld	s8,80(a1)
    80002682:	0585bc83          	ld	s9,88(a1)
    80002686:	0605bd03          	ld	s10,96(a1)
    8000268a:	0685bd83          	ld	s11,104(a1)
    8000268e:	8082                	ret

0000000080002690 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002690:	1141                	addi	sp,sp,-16
    80002692:	e406                	sd	ra,8(sp)
    80002694:	e022                	sd	s0,0(sp)
    80002696:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002698:	00006597          	auipc	a1,0x6
    8000269c:	c7858593          	addi	a1,a1,-904 # 80008310 <states.0+0x30>
    800026a0:	00014517          	auipc	a0,0x14
    800026a4:	30050513          	addi	a0,a0,768 # 800169a0 <tickslock>
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	49e080e7          	jalr	1182(ra) # 80000b46 <initlock>
}
    800026b0:	60a2                	ld	ra,8(sp)
    800026b2:	6402                	ld	s0,0(sp)
    800026b4:	0141                	addi	sp,sp,16
    800026b6:	8082                	ret

00000000800026b8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026b8:	1141                	addi	sp,sp,-16
    800026ba:	e422                	sd	s0,8(sp)
    800026bc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026be:	00003797          	auipc	a5,0x3
    800026c2:	4c278793          	addi	a5,a5,1218 # 80005b80 <kernelvec>
    800026c6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026ca:	6422                	ld	s0,8(sp)
    800026cc:	0141                	addi	sp,sp,16
    800026ce:	8082                	ret

00000000800026d0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026d0:	1141                	addi	sp,sp,-16
    800026d2:	e406                	sd	ra,8(sp)
    800026d4:	e022                	sd	s0,0(sp)
    800026d6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026d8:	fffff097          	auipc	ra,0xfffff
    800026dc:	2d4080e7          	jalr	724(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026e4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026ea:	00005697          	auipc	a3,0x5
    800026ee:	91668693          	addi	a3,a3,-1770 # 80007000 <_trampoline>
    800026f2:	00005717          	auipc	a4,0x5
    800026f6:	90e70713          	addi	a4,a4,-1778 # 80007000 <_trampoline>
    800026fa:	8f15                	sub	a4,a4,a3
    800026fc:	040007b7          	lui	a5,0x4000
    80002700:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002702:	07b2                	slli	a5,a5,0xc
    80002704:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002706:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000270a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000270c:	18002673          	csrr	a2,satp
    80002710:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002712:	6d30                	ld	a2,88(a0)
    80002714:	6138                	ld	a4,64(a0)
    80002716:	6585                	lui	a1,0x1
    80002718:	972e                	add	a4,a4,a1
    8000271a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000271c:	6d38                	ld	a4,88(a0)
    8000271e:	00000617          	auipc	a2,0x0
    80002722:	13060613          	addi	a2,a2,304 # 8000284e <usertrap>
    80002726:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002728:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000272a:	8612                	mv	a2,tp
    8000272c:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000272e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002732:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002736:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000273a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000273e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002740:	6f18                	ld	a4,24(a4)
    80002742:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002746:	6928                	ld	a0,80(a0)
    80002748:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000274a:	00005717          	auipc	a4,0x5
    8000274e:	95270713          	addi	a4,a4,-1710 # 8000709c <userret>
    80002752:	8f15                	sub	a4,a4,a3
    80002754:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002756:	577d                	li	a4,-1
    80002758:	177e                	slli	a4,a4,0x3f
    8000275a:	8d59                	or	a0,a0,a4
    8000275c:	9782                	jalr	a5
}
    8000275e:	60a2                	ld	ra,8(sp)
    80002760:	6402                	ld	s0,0(sp)
    80002762:	0141                	addi	sp,sp,16
    80002764:	8082                	ret

0000000080002766 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002766:	1101                	addi	sp,sp,-32
    80002768:	ec06                	sd	ra,24(sp)
    8000276a:	e822                	sd	s0,16(sp)
    8000276c:	e426                	sd	s1,8(sp)
    8000276e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002770:	00014497          	auipc	s1,0x14
    80002774:	23048493          	addi	s1,s1,560 # 800169a0 <tickslock>
    80002778:	8526                	mv	a0,s1
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	45c080e7          	jalr	1116(ra) # 80000bd6 <acquire>
  ticks++;
    80002782:	00006517          	auipc	a0,0x6
    80002786:	17e50513          	addi	a0,a0,382 # 80008900 <ticks>
    8000278a:	411c                	lw	a5,0(a0)
    8000278c:	2785                	addiw	a5,a5,1
    8000278e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002790:	00000097          	auipc	ra,0x0
    80002794:	928080e7          	jalr	-1752(ra) # 800020b8 <wakeup>
  release(&tickslock);
    80002798:	8526                	mv	a0,s1
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	4f0080e7          	jalr	1264(ra) # 80000c8a <release>
}
    800027a2:	60e2                	ld	ra,24(sp)
    800027a4:	6442                	ld	s0,16(sp)
    800027a6:	64a2                	ld	s1,8(sp)
    800027a8:	6105                	addi	sp,sp,32
    800027aa:	8082                	ret

00000000800027ac <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027ac:	1101                	addi	sp,sp,-32
    800027ae:	ec06                	sd	ra,24(sp)
    800027b0:	e822                	sd	s0,16(sp)
    800027b2:	e426                	sd	s1,8(sp)
    800027b4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027b6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027ba:	00074d63          	bltz	a4,800027d4 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027be:	57fd                	li	a5,-1
    800027c0:	17fe                	slli	a5,a5,0x3f
    800027c2:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027c4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027c6:	06f70363          	beq	a4,a5,8000282c <devintr+0x80>
  }
}
    800027ca:	60e2                	ld	ra,24(sp)
    800027cc:	6442                	ld	s0,16(sp)
    800027ce:	64a2                	ld	s1,8(sp)
    800027d0:	6105                	addi	sp,sp,32
    800027d2:	8082                	ret
     (scause & 0xff) == 9){
    800027d4:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800027d8:	46a5                	li	a3,9
    800027da:	fed792e3          	bne	a5,a3,800027be <devintr+0x12>
    int irq = plic_claim();
    800027de:	00003097          	auipc	ra,0x3
    800027e2:	4aa080e7          	jalr	1194(ra) # 80005c88 <plic_claim>
    800027e6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027e8:	47a9                	li	a5,10
    800027ea:	02f50763          	beq	a0,a5,80002818 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027ee:	4785                	li	a5,1
    800027f0:	02f50963          	beq	a0,a5,80002822 <devintr+0x76>
    return 1;
    800027f4:	4505                	li	a0,1
    } else if(irq){
    800027f6:	d8f1                	beqz	s1,800027ca <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027f8:	85a6                	mv	a1,s1
    800027fa:	00006517          	auipc	a0,0x6
    800027fe:	b1e50513          	addi	a0,a0,-1250 # 80008318 <states.0+0x38>
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	d88080e7          	jalr	-632(ra) # 8000058a <printf>
      plic_complete(irq);
    8000280a:	8526                	mv	a0,s1
    8000280c:	00003097          	auipc	ra,0x3
    80002810:	4a0080e7          	jalr	1184(ra) # 80005cac <plic_complete>
    return 1;
    80002814:	4505                	li	a0,1
    80002816:	bf55                	j	800027ca <devintr+0x1e>
      uartintr();
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	180080e7          	jalr	384(ra) # 80000998 <uartintr>
    80002820:	b7ed                	j	8000280a <devintr+0x5e>
      virtio_disk_intr();
    80002822:	00004097          	auipc	ra,0x4
    80002826:	952080e7          	jalr	-1710(ra) # 80006174 <virtio_disk_intr>
    8000282a:	b7c5                	j	8000280a <devintr+0x5e>
    if(cpuid() == 0){
    8000282c:	fffff097          	auipc	ra,0xfffff
    80002830:	154080e7          	jalr	340(ra) # 80001980 <cpuid>
    80002834:	c901                	beqz	a0,80002844 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002836:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000283a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000283c:	14479073          	csrw	sip,a5
    return 2;
    80002840:	4509                	li	a0,2
    80002842:	b761                	j	800027ca <devintr+0x1e>
      clockintr();
    80002844:	00000097          	auipc	ra,0x0
    80002848:	f22080e7          	jalr	-222(ra) # 80002766 <clockintr>
    8000284c:	b7ed                	j	80002836 <devintr+0x8a>

000000008000284e <usertrap>:
{
    8000284e:	1101                	addi	sp,sp,-32
    80002850:	ec06                	sd	ra,24(sp)
    80002852:	e822                	sd	s0,16(sp)
    80002854:	e426                	sd	s1,8(sp)
    80002856:	e04a                	sd	s2,0(sp)
    80002858:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000285a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000285e:	1007f793          	andi	a5,a5,256
    80002862:	e3b1                	bnez	a5,800028a6 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002864:	00003797          	auipc	a5,0x3
    80002868:	31c78793          	addi	a5,a5,796 # 80005b80 <kernelvec>
    8000286c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002870:	fffff097          	auipc	ra,0xfffff
    80002874:	13c080e7          	jalr	316(ra) # 800019ac <myproc>
    80002878:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000287a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000287c:	14102773          	csrr	a4,sepc
    80002880:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002882:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002886:	47a1                	li	a5,8
    80002888:	02f70763          	beq	a4,a5,800028b6 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000288c:	00000097          	auipc	ra,0x0
    80002890:	f20080e7          	jalr	-224(ra) # 800027ac <devintr>
    80002894:	892a                	mv	s2,a0
    80002896:	c151                	beqz	a0,8000291a <usertrap+0xcc>
  if(killed(p))
    80002898:	8526                	mv	a0,s1
    8000289a:	00000097          	auipc	ra,0x0
    8000289e:	a62080e7          	jalr	-1438(ra) # 800022fc <killed>
    800028a2:	c929                	beqz	a0,800028f4 <usertrap+0xa6>
    800028a4:	a099                	j	800028ea <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800028a6:	00006517          	auipc	a0,0x6
    800028aa:	a9250513          	addi	a0,a0,-1390 # 80008338 <states.0+0x58>
    800028ae:	ffffe097          	auipc	ra,0xffffe
    800028b2:	c92080e7          	jalr	-878(ra) # 80000540 <panic>
    if(killed(p))
    800028b6:	00000097          	auipc	ra,0x0
    800028ba:	a46080e7          	jalr	-1466(ra) # 800022fc <killed>
    800028be:	e921                	bnez	a0,8000290e <usertrap+0xc0>
    p->trapframe->epc += 4;
    800028c0:	6cb8                	ld	a4,88(s1)
    800028c2:	6f1c                	ld	a5,24(a4)
    800028c4:	0791                	addi	a5,a5,4
    800028c6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028c8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028cc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d0:	10079073          	csrw	sstatus,a5
    syscall();
    800028d4:	00000097          	auipc	ra,0x0
    800028d8:	2d4080e7          	jalr	724(ra) # 80002ba8 <syscall>
  if(killed(p))
    800028dc:	8526                	mv	a0,s1
    800028de:	00000097          	auipc	ra,0x0
    800028e2:	a1e080e7          	jalr	-1506(ra) # 800022fc <killed>
    800028e6:	c911                	beqz	a0,800028fa <usertrap+0xac>
    800028e8:	4901                	li	s2,0
    exit(-1);
    800028ea:	557d                	li	a0,-1
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	89c080e7          	jalr	-1892(ra) # 80002188 <exit>
  if(which_dev == 2)
    800028f4:	4789                	li	a5,2
    800028f6:	04f90f63          	beq	s2,a5,80002954 <usertrap+0x106>
  usertrapret();
    800028fa:	00000097          	auipc	ra,0x0
    800028fe:	dd6080e7          	jalr	-554(ra) # 800026d0 <usertrapret>
}
    80002902:	60e2                	ld	ra,24(sp)
    80002904:	6442                	ld	s0,16(sp)
    80002906:	64a2                	ld	s1,8(sp)
    80002908:	6902                	ld	s2,0(sp)
    8000290a:	6105                	addi	sp,sp,32
    8000290c:	8082                	ret
      exit(-1);
    8000290e:	557d                	li	a0,-1
    80002910:	00000097          	auipc	ra,0x0
    80002914:	878080e7          	jalr	-1928(ra) # 80002188 <exit>
    80002918:	b765                	j	800028c0 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000291a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000291e:	5890                	lw	a2,48(s1)
    80002920:	00006517          	auipc	a0,0x6
    80002924:	a3850513          	addi	a0,a0,-1480 # 80008358 <states.0+0x78>
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	c62080e7          	jalr	-926(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002930:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002934:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002938:	00006517          	auipc	a0,0x6
    8000293c:	a5050513          	addi	a0,a0,-1456 # 80008388 <states.0+0xa8>
    80002940:	ffffe097          	auipc	ra,0xffffe
    80002944:	c4a080e7          	jalr	-950(ra) # 8000058a <printf>
    setkilled(p);
    80002948:	8526                	mv	a0,s1
    8000294a:	00000097          	auipc	ra,0x0
    8000294e:	986080e7          	jalr	-1658(ra) # 800022d0 <setkilled>
    80002952:	b769                	j	800028dc <usertrap+0x8e>
    yield();
    80002954:	fffff097          	auipc	ra,0xfffff
    80002958:	6c4080e7          	jalr	1732(ra) # 80002018 <yield>
    8000295c:	bf79                	j	800028fa <usertrap+0xac>

000000008000295e <kerneltrap>:
{
    8000295e:	7179                	addi	sp,sp,-48
    80002960:	f406                	sd	ra,40(sp)
    80002962:	f022                	sd	s0,32(sp)
    80002964:	ec26                	sd	s1,24(sp)
    80002966:	e84a                	sd	s2,16(sp)
    80002968:	e44e                	sd	s3,8(sp)
    8000296a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000296c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002970:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002974:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002978:	1004f793          	andi	a5,s1,256
    8000297c:	cb85                	beqz	a5,800029ac <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000297e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002982:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002984:	ef85                	bnez	a5,800029bc <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002986:	00000097          	auipc	ra,0x0
    8000298a:	e26080e7          	jalr	-474(ra) # 800027ac <devintr>
    8000298e:	cd1d                	beqz	a0,800029cc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002990:	4789                	li	a5,2
    80002992:	06f50a63          	beq	a0,a5,80002a06 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002996:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000299a:	10049073          	csrw	sstatus,s1
}
    8000299e:	70a2                	ld	ra,40(sp)
    800029a0:	7402                	ld	s0,32(sp)
    800029a2:	64e2                	ld	s1,24(sp)
    800029a4:	6942                	ld	s2,16(sp)
    800029a6:	69a2                	ld	s3,8(sp)
    800029a8:	6145                	addi	sp,sp,48
    800029aa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029ac:	00006517          	auipc	a0,0x6
    800029b0:	9fc50513          	addi	a0,a0,-1540 # 800083a8 <states.0+0xc8>
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	b8c080e7          	jalr	-1140(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    800029bc:	00006517          	auipc	a0,0x6
    800029c0:	a1450513          	addi	a0,a0,-1516 # 800083d0 <states.0+0xf0>
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	b7c080e7          	jalr	-1156(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    800029cc:	85ce                	mv	a1,s3
    800029ce:	00006517          	auipc	a0,0x6
    800029d2:	a2250513          	addi	a0,a0,-1502 # 800083f0 <states.0+0x110>
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	bb4080e7          	jalr	-1100(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029de:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029e2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029e6:	00006517          	auipc	a0,0x6
    800029ea:	a1a50513          	addi	a0,a0,-1510 # 80008400 <states.0+0x120>
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	b9c080e7          	jalr	-1124(ra) # 8000058a <printf>
    panic("kerneltrap");
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	a2250513          	addi	a0,a0,-1502 # 80008418 <states.0+0x138>
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	b42080e7          	jalr	-1214(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a06:	fffff097          	auipc	ra,0xfffff
    80002a0a:	fa6080e7          	jalr	-90(ra) # 800019ac <myproc>
    80002a0e:	d541                	beqz	a0,80002996 <kerneltrap+0x38>
    80002a10:	fffff097          	auipc	ra,0xfffff
    80002a14:	f9c080e7          	jalr	-100(ra) # 800019ac <myproc>
    80002a18:	4d18                	lw	a4,24(a0)
    80002a1a:	4791                	li	a5,4
    80002a1c:	f6f71de3          	bne	a4,a5,80002996 <kerneltrap+0x38>
    yield();
    80002a20:	fffff097          	auipc	ra,0xfffff
    80002a24:	5f8080e7          	jalr	1528(ra) # 80002018 <yield>
    80002a28:	b7bd                	j	80002996 <kerneltrap+0x38>

0000000080002a2a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a2a:	1101                	addi	sp,sp,-32
    80002a2c:	ec06                	sd	ra,24(sp)
    80002a2e:	e822                	sd	s0,16(sp)
    80002a30:	e426                	sd	s1,8(sp)
    80002a32:	1000                	addi	s0,sp,32
    80002a34:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a36:	fffff097          	auipc	ra,0xfffff
    80002a3a:	f76080e7          	jalr	-138(ra) # 800019ac <myproc>
  switch (n) {
    80002a3e:	4795                	li	a5,5
    80002a40:	0497e163          	bltu	a5,s1,80002a82 <argraw+0x58>
    80002a44:	048a                	slli	s1,s1,0x2
    80002a46:	00006717          	auipc	a4,0x6
    80002a4a:	a0a70713          	addi	a4,a4,-1526 # 80008450 <states.0+0x170>
    80002a4e:	94ba                	add	s1,s1,a4
    80002a50:	409c                	lw	a5,0(s1)
    80002a52:	97ba                	add	a5,a5,a4
    80002a54:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a56:	6d3c                	ld	a5,88(a0)
    80002a58:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a5a:	60e2                	ld	ra,24(sp)
    80002a5c:	6442                	ld	s0,16(sp)
    80002a5e:	64a2                	ld	s1,8(sp)
    80002a60:	6105                	addi	sp,sp,32
    80002a62:	8082                	ret
    return p->trapframe->a1;
    80002a64:	6d3c                	ld	a5,88(a0)
    80002a66:	7fa8                	ld	a0,120(a5)
    80002a68:	bfcd                	j	80002a5a <argraw+0x30>
    return p->trapframe->a2;
    80002a6a:	6d3c                	ld	a5,88(a0)
    80002a6c:	63c8                	ld	a0,128(a5)
    80002a6e:	b7f5                	j	80002a5a <argraw+0x30>
    return p->trapframe->a3;
    80002a70:	6d3c                	ld	a5,88(a0)
    80002a72:	67c8                	ld	a0,136(a5)
    80002a74:	b7dd                	j	80002a5a <argraw+0x30>
    return p->trapframe->a4;
    80002a76:	6d3c                	ld	a5,88(a0)
    80002a78:	6bc8                	ld	a0,144(a5)
    80002a7a:	b7c5                	j	80002a5a <argraw+0x30>
    return p->trapframe->a5;
    80002a7c:	6d3c                	ld	a5,88(a0)
    80002a7e:	6fc8                	ld	a0,152(a5)
    80002a80:	bfe9                	j	80002a5a <argraw+0x30>
  panic("argraw");
    80002a82:	00006517          	auipc	a0,0x6
    80002a86:	9a650513          	addi	a0,a0,-1626 # 80008428 <states.0+0x148>
    80002a8a:	ffffe097          	auipc	ra,0xffffe
    80002a8e:	ab6080e7          	jalr	-1354(ra) # 80000540 <panic>

0000000080002a92 <fetchaddr>:
{
    80002a92:	1101                	addi	sp,sp,-32
    80002a94:	ec06                	sd	ra,24(sp)
    80002a96:	e822                	sd	s0,16(sp)
    80002a98:	e426                	sd	s1,8(sp)
    80002a9a:	e04a                	sd	s2,0(sp)
    80002a9c:	1000                	addi	s0,sp,32
    80002a9e:	84aa                	mv	s1,a0
    80002aa0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002aa2:	fffff097          	auipc	ra,0xfffff
    80002aa6:	f0a080e7          	jalr	-246(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002aaa:	653c                	ld	a5,72(a0)
    80002aac:	02f4f863          	bgeu	s1,a5,80002adc <fetchaddr+0x4a>
    80002ab0:	00848713          	addi	a4,s1,8
    80002ab4:	02e7e663          	bltu	a5,a4,80002ae0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ab8:	46a1                	li	a3,8
    80002aba:	8626                	mv	a2,s1
    80002abc:	85ca                	mv	a1,s2
    80002abe:	6928                	ld	a0,80(a0)
    80002ac0:	fffff097          	auipc	ra,0xfffff
    80002ac4:	c38080e7          	jalr	-968(ra) # 800016f8 <copyin>
    80002ac8:	00a03533          	snez	a0,a0
    80002acc:	40a00533          	neg	a0,a0
}
    80002ad0:	60e2                	ld	ra,24(sp)
    80002ad2:	6442                	ld	s0,16(sp)
    80002ad4:	64a2                	ld	s1,8(sp)
    80002ad6:	6902                	ld	s2,0(sp)
    80002ad8:	6105                	addi	sp,sp,32
    80002ada:	8082                	ret
    return -1;
    80002adc:	557d                	li	a0,-1
    80002ade:	bfcd                	j	80002ad0 <fetchaddr+0x3e>
    80002ae0:	557d                	li	a0,-1
    80002ae2:	b7fd                	j	80002ad0 <fetchaddr+0x3e>

0000000080002ae4 <fetchstr>:
{
    80002ae4:	7179                	addi	sp,sp,-48
    80002ae6:	f406                	sd	ra,40(sp)
    80002ae8:	f022                	sd	s0,32(sp)
    80002aea:	ec26                	sd	s1,24(sp)
    80002aec:	e84a                	sd	s2,16(sp)
    80002aee:	e44e                	sd	s3,8(sp)
    80002af0:	1800                	addi	s0,sp,48
    80002af2:	892a                	mv	s2,a0
    80002af4:	84ae                	mv	s1,a1
    80002af6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	eb4080e7          	jalr	-332(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b00:	86ce                	mv	a3,s3
    80002b02:	864a                	mv	a2,s2
    80002b04:	85a6                	mv	a1,s1
    80002b06:	6928                	ld	a0,80(a0)
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	c7e080e7          	jalr	-898(ra) # 80001786 <copyinstr>
    80002b10:	00054e63          	bltz	a0,80002b2c <fetchstr+0x48>
  return strlen(buf);
    80002b14:	8526                	mv	a0,s1
    80002b16:	ffffe097          	auipc	ra,0xffffe
    80002b1a:	338080e7          	jalr	824(ra) # 80000e4e <strlen>
}
    80002b1e:	70a2                	ld	ra,40(sp)
    80002b20:	7402                	ld	s0,32(sp)
    80002b22:	64e2                	ld	s1,24(sp)
    80002b24:	6942                	ld	s2,16(sp)
    80002b26:	69a2                	ld	s3,8(sp)
    80002b28:	6145                	addi	sp,sp,48
    80002b2a:	8082                	ret
    return -1;
    80002b2c:	557d                	li	a0,-1
    80002b2e:	bfc5                	j	80002b1e <fetchstr+0x3a>

0000000080002b30 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b30:	1101                	addi	sp,sp,-32
    80002b32:	ec06                	sd	ra,24(sp)
    80002b34:	e822                	sd	s0,16(sp)
    80002b36:	e426                	sd	s1,8(sp)
    80002b38:	1000                	addi	s0,sp,32
    80002b3a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b3c:	00000097          	auipc	ra,0x0
    80002b40:	eee080e7          	jalr	-274(ra) # 80002a2a <argraw>
    80002b44:	c088                	sw	a0,0(s1)
}
    80002b46:	60e2                	ld	ra,24(sp)
    80002b48:	6442                	ld	s0,16(sp)
    80002b4a:	64a2                	ld	s1,8(sp)
    80002b4c:	6105                	addi	sp,sp,32
    80002b4e:	8082                	ret

0000000080002b50 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b50:	1101                	addi	sp,sp,-32
    80002b52:	ec06                	sd	ra,24(sp)
    80002b54:	e822                	sd	s0,16(sp)
    80002b56:	e426                	sd	s1,8(sp)
    80002b58:	1000                	addi	s0,sp,32
    80002b5a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b5c:	00000097          	auipc	ra,0x0
    80002b60:	ece080e7          	jalr	-306(ra) # 80002a2a <argraw>
    80002b64:	e088                	sd	a0,0(s1)
}
    80002b66:	60e2                	ld	ra,24(sp)
    80002b68:	6442                	ld	s0,16(sp)
    80002b6a:	64a2                	ld	s1,8(sp)
    80002b6c:	6105                	addi	sp,sp,32
    80002b6e:	8082                	ret

0000000080002b70 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b70:	7179                	addi	sp,sp,-48
    80002b72:	f406                	sd	ra,40(sp)
    80002b74:	f022                	sd	s0,32(sp)
    80002b76:	ec26                	sd	s1,24(sp)
    80002b78:	e84a                	sd	s2,16(sp)
    80002b7a:	1800                	addi	s0,sp,48
    80002b7c:	84ae                	mv	s1,a1
    80002b7e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b80:	fd840593          	addi	a1,s0,-40
    80002b84:	00000097          	auipc	ra,0x0
    80002b88:	fcc080e7          	jalr	-52(ra) # 80002b50 <argaddr>
  return fetchstr(addr, buf, max);
    80002b8c:	864a                	mv	a2,s2
    80002b8e:	85a6                	mv	a1,s1
    80002b90:	fd843503          	ld	a0,-40(s0)
    80002b94:	00000097          	auipc	ra,0x0
    80002b98:	f50080e7          	jalr	-176(ra) # 80002ae4 <fetchstr>
}
    80002b9c:	70a2                	ld	ra,40(sp)
    80002b9e:	7402                	ld	s0,32(sp)
    80002ba0:	64e2                	ld	s1,24(sp)
    80002ba2:	6942                	ld	s2,16(sp)
    80002ba4:	6145                	addi	sp,sp,48
    80002ba6:	8082                	ret

0000000080002ba8 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002ba8:	1101                	addi	sp,sp,-32
    80002baa:	ec06                	sd	ra,24(sp)
    80002bac:	e822                	sd	s0,16(sp)
    80002bae:	e426                	sd	s1,8(sp)
    80002bb0:	e04a                	sd	s2,0(sp)
    80002bb2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bb4:	fffff097          	auipc	ra,0xfffff
    80002bb8:	df8080e7          	jalr	-520(ra) # 800019ac <myproc>
    80002bbc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bbe:	05853903          	ld	s2,88(a0)
    80002bc2:	0a893783          	ld	a5,168(s2)
    80002bc6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bca:	37fd                	addiw	a5,a5,-1
    80002bcc:	4751                	li	a4,20
    80002bce:	00f76f63          	bltu	a4,a5,80002bec <syscall+0x44>
    80002bd2:	00369713          	slli	a4,a3,0x3
    80002bd6:	00006797          	auipc	a5,0x6
    80002bda:	89278793          	addi	a5,a5,-1902 # 80008468 <syscalls>
    80002bde:	97ba                	add	a5,a5,a4
    80002be0:	639c                	ld	a5,0(a5)
    80002be2:	c789                	beqz	a5,80002bec <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002be4:	9782                	jalr	a5
    80002be6:	06a93823          	sd	a0,112(s2)
    80002bea:	a839                	j	80002c08 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bec:	15848613          	addi	a2,s1,344
    80002bf0:	588c                	lw	a1,48(s1)
    80002bf2:	00006517          	auipc	a0,0x6
    80002bf6:	83e50513          	addi	a0,a0,-1986 # 80008430 <states.0+0x150>
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	990080e7          	jalr	-1648(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c02:	6cbc                	ld	a5,88(s1)
    80002c04:	577d                	li	a4,-1
    80002c06:	fbb8                	sd	a4,112(a5)
  }
}
    80002c08:	60e2                	ld	ra,24(sp)
    80002c0a:	6442                	ld	s0,16(sp)
    80002c0c:	64a2                	ld	s1,8(sp)
    80002c0e:	6902                	ld	s2,0(sp)
    80002c10:	6105                	addi	sp,sp,32
    80002c12:	8082                	ret

0000000080002c14 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c14:	1101                	addi	sp,sp,-32
    80002c16:	ec06                	sd	ra,24(sp)
    80002c18:	e822                	sd	s0,16(sp)
    80002c1a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c1c:	fec40593          	addi	a1,s0,-20
    80002c20:	4501                	li	a0,0
    80002c22:	00000097          	auipc	ra,0x0
    80002c26:	f0e080e7          	jalr	-242(ra) # 80002b30 <argint>
  exit(n);
    80002c2a:	fec42503          	lw	a0,-20(s0)
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	55a080e7          	jalr	1370(ra) # 80002188 <exit>
  return 0;  // not reached
}
    80002c36:	4501                	li	a0,0
    80002c38:	60e2                	ld	ra,24(sp)
    80002c3a:	6442                	ld	s0,16(sp)
    80002c3c:	6105                	addi	sp,sp,32
    80002c3e:	8082                	ret

0000000080002c40 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c40:	1141                	addi	sp,sp,-16
    80002c42:	e406                	sd	ra,8(sp)
    80002c44:	e022                	sd	s0,0(sp)
    80002c46:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c48:	fffff097          	auipc	ra,0xfffff
    80002c4c:	d64080e7          	jalr	-668(ra) # 800019ac <myproc>
}
    80002c50:	5908                	lw	a0,48(a0)
    80002c52:	60a2                	ld	ra,8(sp)
    80002c54:	6402                	ld	s0,0(sp)
    80002c56:	0141                	addi	sp,sp,16
    80002c58:	8082                	ret

0000000080002c5a <sys_fork>:

uint64
sys_fork(void)
{
    80002c5a:	1141                	addi	sp,sp,-16
    80002c5c:	e406                	sd	ra,8(sp)
    80002c5e:	e022                	sd	s0,0(sp)
    80002c60:	0800                	addi	s0,sp,16
  return fork();
    80002c62:	fffff097          	auipc	ra,0xfffff
    80002c66:	100080e7          	jalr	256(ra) # 80001d62 <fork>
}
    80002c6a:	60a2                	ld	ra,8(sp)
    80002c6c:	6402                	ld	s0,0(sp)
    80002c6e:	0141                	addi	sp,sp,16
    80002c70:	8082                	ret

0000000080002c72 <sys_wait>:

uint64
sys_wait(void)
{
    80002c72:	1101                	addi	sp,sp,-32
    80002c74:	ec06                	sd	ra,24(sp)
    80002c76:	e822                	sd	s0,16(sp)
    80002c78:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c7a:	fe840593          	addi	a1,s0,-24
    80002c7e:	4501                	li	a0,0
    80002c80:	00000097          	auipc	ra,0x0
    80002c84:	ed0080e7          	jalr	-304(ra) # 80002b50 <argaddr>
  return wait(p);
    80002c88:	fe843503          	ld	a0,-24(s0)
    80002c8c:	fffff097          	auipc	ra,0xfffff
    80002c90:	6a2080e7          	jalr	1698(ra) # 8000232e <wait>
}
    80002c94:	60e2                	ld	ra,24(sp)
    80002c96:	6442                	ld	s0,16(sp)
    80002c98:	6105                	addi	sp,sp,32
    80002c9a:	8082                	ret

0000000080002c9c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c9c:	7179                	addi	sp,sp,-48
    80002c9e:	f406                	sd	ra,40(sp)
    80002ca0:	f022                	sd	s0,32(sp)
    80002ca2:	ec26                	sd	s1,24(sp)
    80002ca4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ca6:	fdc40593          	addi	a1,s0,-36
    80002caa:	4501                	li	a0,0
    80002cac:	00000097          	auipc	ra,0x0
    80002cb0:	e84080e7          	jalr	-380(ra) # 80002b30 <argint>
  addr = myproc()->sz;
    80002cb4:	fffff097          	auipc	ra,0xfffff
    80002cb8:	cf8080e7          	jalr	-776(ra) # 800019ac <myproc>
    80002cbc:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002cbe:	fdc42503          	lw	a0,-36(s0)
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	044080e7          	jalr	68(ra) # 80001d06 <growproc>
    80002cca:	00054863          	bltz	a0,80002cda <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002cce:	8526                	mv	a0,s1
    80002cd0:	70a2                	ld	ra,40(sp)
    80002cd2:	7402                	ld	s0,32(sp)
    80002cd4:	64e2                	ld	s1,24(sp)
    80002cd6:	6145                	addi	sp,sp,48
    80002cd8:	8082                	ret
    return -1;
    80002cda:	54fd                	li	s1,-1
    80002cdc:	bfcd                	j	80002cce <sys_sbrk+0x32>

0000000080002cde <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cde:	7139                	addi	sp,sp,-64
    80002ce0:	fc06                	sd	ra,56(sp)
    80002ce2:	f822                	sd	s0,48(sp)
    80002ce4:	f426                	sd	s1,40(sp)
    80002ce6:	f04a                	sd	s2,32(sp)
    80002ce8:	ec4e                	sd	s3,24(sp)
    80002cea:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cec:	fcc40593          	addi	a1,s0,-52
    80002cf0:	4501                	li	a0,0
    80002cf2:	00000097          	auipc	ra,0x0
    80002cf6:	e3e080e7          	jalr	-450(ra) # 80002b30 <argint>
  acquire(&tickslock);
    80002cfa:	00014517          	auipc	a0,0x14
    80002cfe:	ca650513          	addi	a0,a0,-858 # 800169a0 <tickslock>
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	ed4080e7          	jalr	-300(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002d0a:	00006917          	auipc	s2,0x6
    80002d0e:	bf692903          	lw	s2,-1034(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80002d12:	fcc42783          	lw	a5,-52(s0)
    80002d16:	cf9d                	beqz	a5,80002d54 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d18:	00014997          	auipc	s3,0x14
    80002d1c:	c8898993          	addi	s3,s3,-888 # 800169a0 <tickslock>
    80002d20:	00006497          	auipc	s1,0x6
    80002d24:	be048493          	addi	s1,s1,-1056 # 80008900 <ticks>
    if(killed(myproc())){
    80002d28:	fffff097          	auipc	ra,0xfffff
    80002d2c:	c84080e7          	jalr	-892(ra) # 800019ac <myproc>
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	5cc080e7          	jalr	1484(ra) # 800022fc <killed>
    80002d38:	ed15                	bnez	a0,80002d74 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d3a:	85ce                	mv	a1,s3
    80002d3c:	8526                	mv	a0,s1
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	316080e7          	jalr	790(ra) # 80002054 <sleep>
  while(ticks - ticks0 < n){
    80002d46:	409c                	lw	a5,0(s1)
    80002d48:	412787bb          	subw	a5,a5,s2
    80002d4c:	fcc42703          	lw	a4,-52(s0)
    80002d50:	fce7ece3          	bltu	a5,a4,80002d28 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002d54:	00014517          	auipc	a0,0x14
    80002d58:	c4c50513          	addi	a0,a0,-948 # 800169a0 <tickslock>
    80002d5c:	ffffe097          	auipc	ra,0xffffe
    80002d60:	f2e080e7          	jalr	-210(ra) # 80000c8a <release>
  return 0;
    80002d64:	4501                	li	a0,0
}
    80002d66:	70e2                	ld	ra,56(sp)
    80002d68:	7442                	ld	s0,48(sp)
    80002d6a:	74a2                	ld	s1,40(sp)
    80002d6c:	7902                	ld	s2,32(sp)
    80002d6e:	69e2                	ld	s3,24(sp)
    80002d70:	6121                	addi	sp,sp,64
    80002d72:	8082                	ret
      release(&tickslock);
    80002d74:	00014517          	auipc	a0,0x14
    80002d78:	c2c50513          	addi	a0,a0,-980 # 800169a0 <tickslock>
    80002d7c:	ffffe097          	auipc	ra,0xffffe
    80002d80:	f0e080e7          	jalr	-242(ra) # 80000c8a <release>
      return -1;
    80002d84:	557d                	li	a0,-1
    80002d86:	b7c5                	j	80002d66 <sys_sleep+0x88>

0000000080002d88 <sys_kill>:

uint64
sys_kill(void)
{
    80002d88:	1101                	addi	sp,sp,-32
    80002d8a:	ec06                	sd	ra,24(sp)
    80002d8c:	e822                	sd	s0,16(sp)
    80002d8e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d90:	fec40593          	addi	a1,s0,-20
    80002d94:	4501                	li	a0,0
    80002d96:	00000097          	auipc	ra,0x0
    80002d9a:	d9a080e7          	jalr	-614(ra) # 80002b30 <argint>
  return kill(pid);
    80002d9e:	fec42503          	lw	a0,-20(s0)
    80002da2:	fffff097          	auipc	ra,0xfffff
    80002da6:	4bc080e7          	jalr	1212(ra) # 8000225e <kill>
}
    80002daa:	60e2                	ld	ra,24(sp)
    80002dac:	6442                	ld	s0,16(sp)
    80002dae:	6105                	addi	sp,sp,32
    80002db0:	8082                	ret

0000000080002db2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	e426                	sd	s1,8(sp)
    80002dba:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dbc:	00014517          	auipc	a0,0x14
    80002dc0:	be450513          	addi	a0,a0,-1052 # 800169a0 <tickslock>
    80002dc4:	ffffe097          	auipc	ra,0xffffe
    80002dc8:	e12080e7          	jalr	-494(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002dcc:	00006497          	auipc	s1,0x6
    80002dd0:	b344a483          	lw	s1,-1228(s1) # 80008900 <ticks>
  release(&tickslock);
    80002dd4:	00014517          	auipc	a0,0x14
    80002dd8:	bcc50513          	addi	a0,a0,-1076 # 800169a0 <tickslock>
    80002ddc:	ffffe097          	auipc	ra,0xffffe
    80002de0:	eae080e7          	jalr	-338(ra) # 80000c8a <release>
  return xticks;
}
    80002de4:	02049513          	slli	a0,s1,0x20
    80002de8:	9101                	srli	a0,a0,0x20
    80002dea:	60e2                	ld	ra,24(sp)
    80002dec:	6442                	ld	s0,16(sp)
    80002dee:	64a2                	ld	s1,8(sp)
    80002df0:	6105                	addi	sp,sp,32
    80002df2:	8082                	ret

0000000080002df4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002df4:	7179                	addi	sp,sp,-48
    80002df6:	f406                	sd	ra,40(sp)
    80002df8:	f022                	sd	s0,32(sp)
    80002dfa:	ec26                	sd	s1,24(sp)
    80002dfc:	e84a                	sd	s2,16(sp)
    80002dfe:	e44e                	sd	s3,8(sp)
    80002e00:	e052                	sd	s4,0(sp)
    80002e02:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e04:	00005597          	auipc	a1,0x5
    80002e08:	71458593          	addi	a1,a1,1812 # 80008518 <syscalls+0xb0>
    80002e0c:	00014517          	auipc	a0,0x14
    80002e10:	bac50513          	addi	a0,a0,-1108 # 800169b8 <bcache>
    80002e14:	ffffe097          	auipc	ra,0xffffe
    80002e18:	d32080e7          	jalr	-718(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e1c:	0001c797          	auipc	a5,0x1c
    80002e20:	b9c78793          	addi	a5,a5,-1124 # 8001e9b8 <bcache+0x8000>
    80002e24:	0001c717          	auipc	a4,0x1c
    80002e28:	dfc70713          	addi	a4,a4,-516 # 8001ec20 <bcache+0x8268>
    80002e2c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e30:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e34:	00014497          	auipc	s1,0x14
    80002e38:	b9c48493          	addi	s1,s1,-1124 # 800169d0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e3c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e3e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e40:	00005a17          	auipc	s4,0x5
    80002e44:	6e0a0a13          	addi	s4,s4,1760 # 80008520 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002e48:	2b893783          	ld	a5,696(s2)
    80002e4c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e4e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e52:	85d2                	mv	a1,s4
    80002e54:	01048513          	addi	a0,s1,16
    80002e58:	00001097          	auipc	ra,0x1
    80002e5c:	4c8080e7          	jalr	1224(ra) # 80004320 <initsleeplock>
    bcache.head.next->prev = b;
    80002e60:	2b893783          	ld	a5,696(s2)
    80002e64:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e66:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e6a:	45848493          	addi	s1,s1,1112
    80002e6e:	fd349de3          	bne	s1,s3,80002e48 <binit+0x54>
  }
}
    80002e72:	70a2                	ld	ra,40(sp)
    80002e74:	7402                	ld	s0,32(sp)
    80002e76:	64e2                	ld	s1,24(sp)
    80002e78:	6942                	ld	s2,16(sp)
    80002e7a:	69a2                	ld	s3,8(sp)
    80002e7c:	6a02                	ld	s4,0(sp)
    80002e7e:	6145                	addi	sp,sp,48
    80002e80:	8082                	ret

0000000080002e82 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e82:	7179                	addi	sp,sp,-48
    80002e84:	f406                	sd	ra,40(sp)
    80002e86:	f022                	sd	s0,32(sp)
    80002e88:	ec26                	sd	s1,24(sp)
    80002e8a:	e84a                	sd	s2,16(sp)
    80002e8c:	e44e                	sd	s3,8(sp)
    80002e8e:	1800                	addi	s0,sp,48
    80002e90:	892a                	mv	s2,a0
    80002e92:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e94:	00014517          	auipc	a0,0x14
    80002e98:	b2450513          	addi	a0,a0,-1244 # 800169b8 <bcache>
    80002e9c:	ffffe097          	auipc	ra,0xffffe
    80002ea0:	d3a080e7          	jalr	-710(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ea4:	0001c497          	auipc	s1,0x1c
    80002ea8:	dcc4b483          	ld	s1,-564(s1) # 8001ec70 <bcache+0x82b8>
    80002eac:	0001c797          	auipc	a5,0x1c
    80002eb0:	d7478793          	addi	a5,a5,-652 # 8001ec20 <bcache+0x8268>
    80002eb4:	02f48f63          	beq	s1,a5,80002ef2 <bread+0x70>
    80002eb8:	873e                	mv	a4,a5
    80002eba:	a021                	j	80002ec2 <bread+0x40>
    80002ebc:	68a4                	ld	s1,80(s1)
    80002ebe:	02e48a63          	beq	s1,a4,80002ef2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ec2:	449c                	lw	a5,8(s1)
    80002ec4:	ff279ce3          	bne	a5,s2,80002ebc <bread+0x3a>
    80002ec8:	44dc                	lw	a5,12(s1)
    80002eca:	ff3799e3          	bne	a5,s3,80002ebc <bread+0x3a>
      b->refcnt++;
    80002ece:	40bc                	lw	a5,64(s1)
    80002ed0:	2785                	addiw	a5,a5,1
    80002ed2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ed4:	00014517          	auipc	a0,0x14
    80002ed8:	ae450513          	addi	a0,a0,-1308 # 800169b8 <bcache>
    80002edc:	ffffe097          	auipc	ra,0xffffe
    80002ee0:	dae080e7          	jalr	-594(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002ee4:	01048513          	addi	a0,s1,16
    80002ee8:	00001097          	auipc	ra,0x1
    80002eec:	472080e7          	jalr	1138(ra) # 8000435a <acquiresleep>
      return b;
    80002ef0:	a8b9                	j	80002f4e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ef2:	0001c497          	auipc	s1,0x1c
    80002ef6:	d764b483          	ld	s1,-650(s1) # 8001ec68 <bcache+0x82b0>
    80002efa:	0001c797          	auipc	a5,0x1c
    80002efe:	d2678793          	addi	a5,a5,-730 # 8001ec20 <bcache+0x8268>
    80002f02:	00f48863          	beq	s1,a5,80002f12 <bread+0x90>
    80002f06:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f08:	40bc                	lw	a5,64(s1)
    80002f0a:	cf81                	beqz	a5,80002f22 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f0c:	64a4                	ld	s1,72(s1)
    80002f0e:	fee49de3          	bne	s1,a4,80002f08 <bread+0x86>
  panic("bget: no buffers");
    80002f12:	00005517          	auipc	a0,0x5
    80002f16:	61650513          	addi	a0,a0,1558 # 80008528 <syscalls+0xc0>
    80002f1a:	ffffd097          	auipc	ra,0xffffd
    80002f1e:	626080e7          	jalr	1574(ra) # 80000540 <panic>
      b->dev = dev;
    80002f22:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f26:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f2a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f2e:	4785                	li	a5,1
    80002f30:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f32:	00014517          	auipc	a0,0x14
    80002f36:	a8650513          	addi	a0,a0,-1402 # 800169b8 <bcache>
    80002f3a:	ffffe097          	auipc	ra,0xffffe
    80002f3e:	d50080e7          	jalr	-688(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f42:	01048513          	addi	a0,s1,16
    80002f46:	00001097          	auipc	ra,0x1
    80002f4a:	414080e7          	jalr	1044(ra) # 8000435a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f4e:	409c                	lw	a5,0(s1)
    80002f50:	cb89                	beqz	a5,80002f62 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f52:	8526                	mv	a0,s1
    80002f54:	70a2                	ld	ra,40(sp)
    80002f56:	7402                	ld	s0,32(sp)
    80002f58:	64e2                	ld	s1,24(sp)
    80002f5a:	6942                	ld	s2,16(sp)
    80002f5c:	69a2                	ld	s3,8(sp)
    80002f5e:	6145                	addi	sp,sp,48
    80002f60:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f62:	4581                	li	a1,0
    80002f64:	8526                	mv	a0,s1
    80002f66:	00003097          	auipc	ra,0x3
    80002f6a:	fdc080e7          	jalr	-36(ra) # 80005f42 <virtio_disk_rw>
    b->valid = 1;
    80002f6e:	4785                	li	a5,1
    80002f70:	c09c                	sw	a5,0(s1)
  return b;
    80002f72:	b7c5                	j	80002f52 <bread+0xd0>

0000000080002f74 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f74:	1101                	addi	sp,sp,-32
    80002f76:	ec06                	sd	ra,24(sp)
    80002f78:	e822                	sd	s0,16(sp)
    80002f7a:	e426                	sd	s1,8(sp)
    80002f7c:	1000                	addi	s0,sp,32
    80002f7e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f80:	0541                	addi	a0,a0,16
    80002f82:	00001097          	auipc	ra,0x1
    80002f86:	472080e7          	jalr	1138(ra) # 800043f4 <holdingsleep>
    80002f8a:	cd01                	beqz	a0,80002fa2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f8c:	4585                	li	a1,1
    80002f8e:	8526                	mv	a0,s1
    80002f90:	00003097          	auipc	ra,0x3
    80002f94:	fb2080e7          	jalr	-78(ra) # 80005f42 <virtio_disk_rw>
}
    80002f98:	60e2                	ld	ra,24(sp)
    80002f9a:	6442                	ld	s0,16(sp)
    80002f9c:	64a2                	ld	s1,8(sp)
    80002f9e:	6105                	addi	sp,sp,32
    80002fa0:	8082                	ret
    panic("bwrite");
    80002fa2:	00005517          	auipc	a0,0x5
    80002fa6:	59e50513          	addi	a0,a0,1438 # 80008540 <syscalls+0xd8>
    80002faa:	ffffd097          	auipc	ra,0xffffd
    80002fae:	596080e7          	jalr	1430(ra) # 80000540 <panic>

0000000080002fb2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fb2:	1101                	addi	sp,sp,-32
    80002fb4:	ec06                	sd	ra,24(sp)
    80002fb6:	e822                	sd	s0,16(sp)
    80002fb8:	e426                	sd	s1,8(sp)
    80002fba:	e04a                	sd	s2,0(sp)
    80002fbc:	1000                	addi	s0,sp,32
    80002fbe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fc0:	01050913          	addi	s2,a0,16
    80002fc4:	854a                	mv	a0,s2
    80002fc6:	00001097          	auipc	ra,0x1
    80002fca:	42e080e7          	jalr	1070(ra) # 800043f4 <holdingsleep>
    80002fce:	c92d                	beqz	a0,80003040 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002fd0:	854a                	mv	a0,s2
    80002fd2:	00001097          	auipc	ra,0x1
    80002fd6:	3de080e7          	jalr	990(ra) # 800043b0 <releasesleep>

  acquire(&bcache.lock);
    80002fda:	00014517          	auipc	a0,0x14
    80002fde:	9de50513          	addi	a0,a0,-1570 # 800169b8 <bcache>
    80002fe2:	ffffe097          	auipc	ra,0xffffe
    80002fe6:	bf4080e7          	jalr	-1036(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002fea:	40bc                	lw	a5,64(s1)
    80002fec:	37fd                	addiw	a5,a5,-1
    80002fee:	0007871b          	sext.w	a4,a5
    80002ff2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002ff4:	eb05                	bnez	a4,80003024 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002ff6:	68bc                	ld	a5,80(s1)
    80002ff8:	64b8                	ld	a4,72(s1)
    80002ffa:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002ffc:	64bc                	ld	a5,72(s1)
    80002ffe:	68b8                	ld	a4,80(s1)
    80003000:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003002:	0001c797          	auipc	a5,0x1c
    80003006:	9b678793          	addi	a5,a5,-1610 # 8001e9b8 <bcache+0x8000>
    8000300a:	2b87b703          	ld	a4,696(a5)
    8000300e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003010:	0001c717          	auipc	a4,0x1c
    80003014:	c1070713          	addi	a4,a4,-1008 # 8001ec20 <bcache+0x8268>
    80003018:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000301a:	2b87b703          	ld	a4,696(a5)
    8000301e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003020:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003024:	00014517          	auipc	a0,0x14
    80003028:	99450513          	addi	a0,a0,-1644 # 800169b8 <bcache>
    8000302c:	ffffe097          	auipc	ra,0xffffe
    80003030:	c5e080e7          	jalr	-930(ra) # 80000c8a <release>
}
    80003034:	60e2                	ld	ra,24(sp)
    80003036:	6442                	ld	s0,16(sp)
    80003038:	64a2                	ld	s1,8(sp)
    8000303a:	6902                	ld	s2,0(sp)
    8000303c:	6105                	addi	sp,sp,32
    8000303e:	8082                	ret
    panic("brelse");
    80003040:	00005517          	auipc	a0,0x5
    80003044:	50850513          	addi	a0,a0,1288 # 80008548 <syscalls+0xe0>
    80003048:	ffffd097          	auipc	ra,0xffffd
    8000304c:	4f8080e7          	jalr	1272(ra) # 80000540 <panic>

0000000080003050 <bpin>:

void
bpin(struct buf *b) {
    80003050:	1101                	addi	sp,sp,-32
    80003052:	ec06                	sd	ra,24(sp)
    80003054:	e822                	sd	s0,16(sp)
    80003056:	e426                	sd	s1,8(sp)
    80003058:	1000                	addi	s0,sp,32
    8000305a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000305c:	00014517          	auipc	a0,0x14
    80003060:	95c50513          	addi	a0,a0,-1700 # 800169b8 <bcache>
    80003064:	ffffe097          	auipc	ra,0xffffe
    80003068:	b72080e7          	jalr	-1166(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000306c:	40bc                	lw	a5,64(s1)
    8000306e:	2785                	addiw	a5,a5,1
    80003070:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003072:	00014517          	auipc	a0,0x14
    80003076:	94650513          	addi	a0,a0,-1722 # 800169b8 <bcache>
    8000307a:	ffffe097          	auipc	ra,0xffffe
    8000307e:	c10080e7          	jalr	-1008(ra) # 80000c8a <release>
}
    80003082:	60e2                	ld	ra,24(sp)
    80003084:	6442                	ld	s0,16(sp)
    80003086:	64a2                	ld	s1,8(sp)
    80003088:	6105                	addi	sp,sp,32
    8000308a:	8082                	ret

000000008000308c <bunpin>:

void
bunpin(struct buf *b) {
    8000308c:	1101                	addi	sp,sp,-32
    8000308e:	ec06                	sd	ra,24(sp)
    80003090:	e822                	sd	s0,16(sp)
    80003092:	e426                	sd	s1,8(sp)
    80003094:	1000                	addi	s0,sp,32
    80003096:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003098:	00014517          	auipc	a0,0x14
    8000309c:	92050513          	addi	a0,a0,-1760 # 800169b8 <bcache>
    800030a0:	ffffe097          	auipc	ra,0xffffe
    800030a4:	b36080e7          	jalr	-1226(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800030a8:	40bc                	lw	a5,64(s1)
    800030aa:	37fd                	addiw	a5,a5,-1
    800030ac:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030ae:	00014517          	auipc	a0,0x14
    800030b2:	90a50513          	addi	a0,a0,-1782 # 800169b8 <bcache>
    800030b6:	ffffe097          	auipc	ra,0xffffe
    800030ba:	bd4080e7          	jalr	-1068(ra) # 80000c8a <release>
}
    800030be:	60e2                	ld	ra,24(sp)
    800030c0:	6442                	ld	s0,16(sp)
    800030c2:	64a2                	ld	s1,8(sp)
    800030c4:	6105                	addi	sp,sp,32
    800030c6:	8082                	ret

00000000800030c8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030c8:	1101                	addi	sp,sp,-32
    800030ca:	ec06                	sd	ra,24(sp)
    800030cc:	e822                	sd	s0,16(sp)
    800030ce:	e426                	sd	s1,8(sp)
    800030d0:	e04a                	sd	s2,0(sp)
    800030d2:	1000                	addi	s0,sp,32
    800030d4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030d6:	00d5d59b          	srliw	a1,a1,0xd
    800030da:	0001c797          	auipc	a5,0x1c
    800030de:	fba7a783          	lw	a5,-70(a5) # 8001f094 <sb+0x1c>
    800030e2:	9dbd                	addw	a1,a1,a5
    800030e4:	00000097          	auipc	ra,0x0
    800030e8:	d9e080e7          	jalr	-610(ra) # 80002e82 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030ec:	0074f713          	andi	a4,s1,7
    800030f0:	4785                	li	a5,1
    800030f2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030f6:	14ce                	slli	s1,s1,0x33
    800030f8:	90d9                	srli	s1,s1,0x36
    800030fa:	00950733          	add	a4,a0,s1
    800030fe:	05874703          	lbu	a4,88(a4)
    80003102:	00e7f6b3          	and	a3,a5,a4
    80003106:	c69d                	beqz	a3,80003134 <bfree+0x6c>
    80003108:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000310a:	94aa                	add	s1,s1,a0
    8000310c:	fff7c793          	not	a5,a5
    80003110:	8f7d                	and	a4,a4,a5
    80003112:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003116:	00001097          	auipc	ra,0x1
    8000311a:	126080e7          	jalr	294(ra) # 8000423c <log_write>
  brelse(bp);
    8000311e:	854a                	mv	a0,s2
    80003120:	00000097          	auipc	ra,0x0
    80003124:	e92080e7          	jalr	-366(ra) # 80002fb2 <brelse>
}
    80003128:	60e2                	ld	ra,24(sp)
    8000312a:	6442                	ld	s0,16(sp)
    8000312c:	64a2                	ld	s1,8(sp)
    8000312e:	6902                	ld	s2,0(sp)
    80003130:	6105                	addi	sp,sp,32
    80003132:	8082                	ret
    panic("freeing free block");
    80003134:	00005517          	auipc	a0,0x5
    80003138:	41c50513          	addi	a0,a0,1052 # 80008550 <syscalls+0xe8>
    8000313c:	ffffd097          	auipc	ra,0xffffd
    80003140:	404080e7          	jalr	1028(ra) # 80000540 <panic>

0000000080003144 <balloc>:
{
    80003144:	711d                	addi	sp,sp,-96
    80003146:	ec86                	sd	ra,88(sp)
    80003148:	e8a2                	sd	s0,80(sp)
    8000314a:	e4a6                	sd	s1,72(sp)
    8000314c:	e0ca                	sd	s2,64(sp)
    8000314e:	fc4e                	sd	s3,56(sp)
    80003150:	f852                	sd	s4,48(sp)
    80003152:	f456                	sd	s5,40(sp)
    80003154:	f05a                	sd	s6,32(sp)
    80003156:	ec5e                	sd	s7,24(sp)
    80003158:	e862                	sd	s8,16(sp)
    8000315a:	e466                	sd	s9,8(sp)
    8000315c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000315e:	0001c797          	auipc	a5,0x1c
    80003162:	f1e7a783          	lw	a5,-226(a5) # 8001f07c <sb+0x4>
    80003166:	cff5                	beqz	a5,80003262 <balloc+0x11e>
    80003168:	8baa                	mv	s7,a0
    8000316a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000316c:	0001cb17          	auipc	s6,0x1c
    80003170:	f0cb0b13          	addi	s6,s6,-244 # 8001f078 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003174:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003176:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003178:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000317a:	6c89                	lui	s9,0x2
    8000317c:	a061                	j	80003204 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000317e:	97ca                	add	a5,a5,s2
    80003180:	8e55                	or	a2,a2,a3
    80003182:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003186:	854a                	mv	a0,s2
    80003188:	00001097          	auipc	ra,0x1
    8000318c:	0b4080e7          	jalr	180(ra) # 8000423c <log_write>
        brelse(bp);
    80003190:	854a                	mv	a0,s2
    80003192:	00000097          	auipc	ra,0x0
    80003196:	e20080e7          	jalr	-480(ra) # 80002fb2 <brelse>
  bp = bread(dev, bno);
    8000319a:	85a6                	mv	a1,s1
    8000319c:	855e                	mv	a0,s7
    8000319e:	00000097          	auipc	ra,0x0
    800031a2:	ce4080e7          	jalr	-796(ra) # 80002e82 <bread>
    800031a6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031a8:	40000613          	li	a2,1024
    800031ac:	4581                	li	a1,0
    800031ae:	05850513          	addi	a0,a0,88
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	b20080e7          	jalr	-1248(ra) # 80000cd2 <memset>
  log_write(bp);
    800031ba:	854a                	mv	a0,s2
    800031bc:	00001097          	auipc	ra,0x1
    800031c0:	080080e7          	jalr	128(ra) # 8000423c <log_write>
  brelse(bp);
    800031c4:	854a                	mv	a0,s2
    800031c6:	00000097          	auipc	ra,0x0
    800031ca:	dec080e7          	jalr	-532(ra) # 80002fb2 <brelse>
}
    800031ce:	8526                	mv	a0,s1
    800031d0:	60e6                	ld	ra,88(sp)
    800031d2:	6446                	ld	s0,80(sp)
    800031d4:	64a6                	ld	s1,72(sp)
    800031d6:	6906                	ld	s2,64(sp)
    800031d8:	79e2                	ld	s3,56(sp)
    800031da:	7a42                	ld	s4,48(sp)
    800031dc:	7aa2                	ld	s5,40(sp)
    800031de:	7b02                	ld	s6,32(sp)
    800031e0:	6be2                	ld	s7,24(sp)
    800031e2:	6c42                	ld	s8,16(sp)
    800031e4:	6ca2                	ld	s9,8(sp)
    800031e6:	6125                	addi	sp,sp,96
    800031e8:	8082                	ret
    brelse(bp);
    800031ea:	854a                	mv	a0,s2
    800031ec:	00000097          	auipc	ra,0x0
    800031f0:	dc6080e7          	jalr	-570(ra) # 80002fb2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031f4:	015c87bb          	addw	a5,s9,s5
    800031f8:	00078a9b          	sext.w	s5,a5
    800031fc:	004b2703          	lw	a4,4(s6)
    80003200:	06eaf163          	bgeu	s5,a4,80003262 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003204:	41fad79b          	sraiw	a5,s5,0x1f
    80003208:	0137d79b          	srliw	a5,a5,0x13
    8000320c:	015787bb          	addw	a5,a5,s5
    80003210:	40d7d79b          	sraiw	a5,a5,0xd
    80003214:	01cb2583          	lw	a1,28(s6)
    80003218:	9dbd                	addw	a1,a1,a5
    8000321a:	855e                	mv	a0,s7
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	c66080e7          	jalr	-922(ra) # 80002e82 <bread>
    80003224:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003226:	004b2503          	lw	a0,4(s6)
    8000322a:	000a849b          	sext.w	s1,s5
    8000322e:	8762                	mv	a4,s8
    80003230:	faa4fde3          	bgeu	s1,a0,800031ea <balloc+0xa6>
      m = 1 << (bi % 8);
    80003234:	00777693          	andi	a3,a4,7
    80003238:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000323c:	41f7579b          	sraiw	a5,a4,0x1f
    80003240:	01d7d79b          	srliw	a5,a5,0x1d
    80003244:	9fb9                	addw	a5,a5,a4
    80003246:	4037d79b          	sraiw	a5,a5,0x3
    8000324a:	00f90633          	add	a2,s2,a5
    8000324e:	05864603          	lbu	a2,88(a2)
    80003252:	00c6f5b3          	and	a1,a3,a2
    80003256:	d585                	beqz	a1,8000317e <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003258:	2705                	addiw	a4,a4,1
    8000325a:	2485                	addiw	s1,s1,1
    8000325c:	fd471ae3          	bne	a4,s4,80003230 <balloc+0xec>
    80003260:	b769                	j	800031ea <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003262:	00005517          	auipc	a0,0x5
    80003266:	30650513          	addi	a0,a0,774 # 80008568 <syscalls+0x100>
    8000326a:	ffffd097          	auipc	ra,0xffffd
    8000326e:	320080e7          	jalr	800(ra) # 8000058a <printf>
  return 0;
    80003272:	4481                	li	s1,0
    80003274:	bfa9                	j	800031ce <balloc+0x8a>

0000000080003276 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003276:	7179                	addi	sp,sp,-48
    80003278:	f406                	sd	ra,40(sp)
    8000327a:	f022                	sd	s0,32(sp)
    8000327c:	ec26                	sd	s1,24(sp)
    8000327e:	e84a                	sd	s2,16(sp)
    80003280:	e44e                	sd	s3,8(sp)
    80003282:	e052                	sd	s4,0(sp)
    80003284:	1800                	addi	s0,sp,48
    80003286:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003288:	47ad                	li	a5,11
    8000328a:	02b7e863          	bltu	a5,a1,800032ba <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    8000328e:	02059793          	slli	a5,a1,0x20
    80003292:	01e7d593          	srli	a1,a5,0x1e
    80003296:	00b504b3          	add	s1,a0,a1
    8000329a:	0504a903          	lw	s2,80(s1)
    8000329e:	06091e63          	bnez	s2,8000331a <bmap+0xa4>
      addr = balloc(ip->dev);
    800032a2:	4108                	lw	a0,0(a0)
    800032a4:	00000097          	auipc	ra,0x0
    800032a8:	ea0080e7          	jalr	-352(ra) # 80003144 <balloc>
    800032ac:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032b0:	06090563          	beqz	s2,8000331a <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800032b4:	0524a823          	sw	s2,80(s1)
    800032b8:	a08d                	j	8000331a <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800032ba:	ff45849b          	addiw	s1,a1,-12
    800032be:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032c2:	0ff00793          	li	a5,255
    800032c6:	08e7e563          	bltu	a5,a4,80003350 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800032ca:	08052903          	lw	s2,128(a0)
    800032ce:	00091d63          	bnez	s2,800032e8 <bmap+0x72>
      addr = balloc(ip->dev);
    800032d2:	4108                	lw	a0,0(a0)
    800032d4:	00000097          	auipc	ra,0x0
    800032d8:	e70080e7          	jalr	-400(ra) # 80003144 <balloc>
    800032dc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032e0:	02090d63          	beqz	s2,8000331a <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032e4:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800032e8:	85ca                	mv	a1,s2
    800032ea:	0009a503          	lw	a0,0(s3)
    800032ee:	00000097          	auipc	ra,0x0
    800032f2:	b94080e7          	jalr	-1132(ra) # 80002e82 <bread>
    800032f6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032f8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032fc:	02049713          	slli	a4,s1,0x20
    80003300:	01e75593          	srli	a1,a4,0x1e
    80003304:	00b784b3          	add	s1,a5,a1
    80003308:	0004a903          	lw	s2,0(s1)
    8000330c:	02090063          	beqz	s2,8000332c <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003310:	8552                	mv	a0,s4
    80003312:	00000097          	auipc	ra,0x0
    80003316:	ca0080e7          	jalr	-864(ra) # 80002fb2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000331a:	854a                	mv	a0,s2
    8000331c:	70a2                	ld	ra,40(sp)
    8000331e:	7402                	ld	s0,32(sp)
    80003320:	64e2                	ld	s1,24(sp)
    80003322:	6942                	ld	s2,16(sp)
    80003324:	69a2                	ld	s3,8(sp)
    80003326:	6a02                	ld	s4,0(sp)
    80003328:	6145                	addi	sp,sp,48
    8000332a:	8082                	ret
      addr = balloc(ip->dev);
    8000332c:	0009a503          	lw	a0,0(s3)
    80003330:	00000097          	auipc	ra,0x0
    80003334:	e14080e7          	jalr	-492(ra) # 80003144 <balloc>
    80003338:	0005091b          	sext.w	s2,a0
      if(addr){
    8000333c:	fc090ae3          	beqz	s2,80003310 <bmap+0x9a>
        a[bn] = addr;
    80003340:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003344:	8552                	mv	a0,s4
    80003346:	00001097          	auipc	ra,0x1
    8000334a:	ef6080e7          	jalr	-266(ra) # 8000423c <log_write>
    8000334e:	b7c9                	j	80003310 <bmap+0x9a>
  panic("bmap: out of range");
    80003350:	00005517          	auipc	a0,0x5
    80003354:	23050513          	addi	a0,a0,560 # 80008580 <syscalls+0x118>
    80003358:	ffffd097          	auipc	ra,0xffffd
    8000335c:	1e8080e7          	jalr	488(ra) # 80000540 <panic>

0000000080003360 <iget>:
{
    80003360:	7179                	addi	sp,sp,-48
    80003362:	f406                	sd	ra,40(sp)
    80003364:	f022                	sd	s0,32(sp)
    80003366:	ec26                	sd	s1,24(sp)
    80003368:	e84a                	sd	s2,16(sp)
    8000336a:	e44e                	sd	s3,8(sp)
    8000336c:	e052                	sd	s4,0(sp)
    8000336e:	1800                	addi	s0,sp,48
    80003370:	89aa                	mv	s3,a0
    80003372:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003374:	0001c517          	auipc	a0,0x1c
    80003378:	d2450513          	addi	a0,a0,-732 # 8001f098 <itable>
    8000337c:	ffffe097          	auipc	ra,0xffffe
    80003380:	85a080e7          	jalr	-1958(ra) # 80000bd6 <acquire>
  empty = 0;
    80003384:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003386:	0001c497          	auipc	s1,0x1c
    8000338a:	d2a48493          	addi	s1,s1,-726 # 8001f0b0 <itable+0x18>
    8000338e:	0001d697          	auipc	a3,0x1d
    80003392:	7b268693          	addi	a3,a3,1970 # 80020b40 <log>
    80003396:	a039                	j	800033a4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003398:	02090b63          	beqz	s2,800033ce <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000339c:	08848493          	addi	s1,s1,136
    800033a0:	02d48a63          	beq	s1,a3,800033d4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033a4:	449c                	lw	a5,8(s1)
    800033a6:	fef059e3          	blez	a5,80003398 <iget+0x38>
    800033aa:	4098                	lw	a4,0(s1)
    800033ac:	ff3716e3          	bne	a4,s3,80003398 <iget+0x38>
    800033b0:	40d8                	lw	a4,4(s1)
    800033b2:	ff4713e3          	bne	a4,s4,80003398 <iget+0x38>
      ip->ref++;
    800033b6:	2785                	addiw	a5,a5,1
    800033b8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033ba:	0001c517          	auipc	a0,0x1c
    800033be:	cde50513          	addi	a0,a0,-802 # 8001f098 <itable>
    800033c2:	ffffe097          	auipc	ra,0xffffe
    800033c6:	8c8080e7          	jalr	-1848(ra) # 80000c8a <release>
      return ip;
    800033ca:	8926                	mv	s2,s1
    800033cc:	a03d                	j	800033fa <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033ce:	f7f9                	bnez	a5,8000339c <iget+0x3c>
    800033d0:	8926                	mv	s2,s1
    800033d2:	b7e9                	j	8000339c <iget+0x3c>
  if(empty == 0)
    800033d4:	02090c63          	beqz	s2,8000340c <iget+0xac>
  ip->dev = dev;
    800033d8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033dc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033e0:	4785                	li	a5,1
    800033e2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033e6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800033ea:	0001c517          	auipc	a0,0x1c
    800033ee:	cae50513          	addi	a0,a0,-850 # 8001f098 <itable>
    800033f2:	ffffe097          	auipc	ra,0xffffe
    800033f6:	898080e7          	jalr	-1896(ra) # 80000c8a <release>
}
    800033fa:	854a                	mv	a0,s2
    800033fc:	70a2                	ld	ra,40(sp)
    800033fe:	7402                	ld	s0,32(sp)
    80003400:	64e2                	ld	s1,24(sp)
    80003402:	6942                	ld	s2,16(sp)
    80003404:	69a2                	ld	s3,8(sp)
    80003406:	6a02                	ld	s4,0(sp)
    80003408:	6145                	addi	sp,sp,48
    8000340a:	8082                	ret
    panic("iget: no inodes");
    8000340c:	00005517          	auipc	a0,0x5
    80003410:	18c50513          	addi	a0,a0,396 # 80008598 <syscalls+0x130>
    80003414:	ffffd097          	auipc	ra,0xffffd
    80003418:	12c080e7          	jalr	300(ra) # 80000540 <panic>

000000008000341c <fsinit>:
fsinit(int dev) {
    8000341c:	7179                	addi	sp,sp,-48
    8000341e:	f406                	sd	ra,40(sp)
    80003420:	f022                	sd	s0,32(sp)
    80003422:	ec26                	sd	s1,24(sp)
    80003424:	e84a                	sd	s2,16(sp)
    80003426:	e44e                	sd	s3,8(sp)
    80003428:	1800                	addi	s0,sp,48
    8000342a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000342c:	4585                	li	a1,1
    8000342e:	00000097          	auipc	ra,0x0
    80003432:	a54080e7          	jalr	-1452(ra) # 80002e82 <bread>
    80003436:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003438:	0001c997          	auipc	s3,0x1c
    8000343c:	c4098993          	addi	s3,s3,-960 # 8001f078 <sb>
    80003440:	02000613          	li	a2,32
    80003444:	05850593          	addi	a1,a0,88
    80003448:	854e                	mv	a0,s3
    8000344a:	ffffe097          	auipc	ra,0xffffe
    8000344e:	8e4080e7          	jalr	-1820(ra) # 80000d2e <memmove>
  brelse(bp);
    80003452:	8526                	mv	a0,s1
    80003454:	00000097          	auipc	ra,0x0
    80003458:	b5e080e7          	jalr	-1186(ra) # 80002fb2 <brelse>
  if(sb.magic != FSMAGIC)
    8000345c:	0009a703          	lw	a4,0(s3)
    80003460:	102037b7          	lui	a5,0x10203
    80003464:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003468:	02f71263          	bne	a4,a5,8000348c <fsinit+0x70>
  initlog(dev, &sb);
    8000346c:	0001c597          	auipc	a1,0x1c
    80003470:	c0c58593          	addi	a1,a1,-1012 # 8001f078 <sb>
    80003474:	854a                	mv	a0,s2
    80003476:	00001097          	auipc	ra,0x1
    8000347a:	b4a080e7          	jalr	-1206(ra) # 80003fc0 <initlog>
}
    8000347e:	70a2                	ld	ra,40(sp)
    80003480:	7402                	ld	s0,32(sp)
    80003482:	64e2                	ld	s1,24(sp)
    80003484:	6942                	ld	s2,16(sp)
    80003486:	69a2                	ld	s3,8(sp)
    80003488:	6145                	addi	sp,sp,48
    8000348a:	8082                	ret
    panic("invalid file system");
    8000348c:	00005517          	auipc	a0,0x5
    80003490:	11c50513          	addi	a0,a0,284 # 800085a8 <syscalls+0x140>
    80003494:	ffffd097          	auipc	ra,0xffffd
    80003498:	0ac080e7          	jalr	172(ra) # 80000540 <panic>

000000008000349c <iinit>:
{
    8000349c:	7179                	addi	sp,sp,-48
    8000349e:	f406                	sd	ra,40(sp)
    800034a0:	f022                	sd	s0,32(sp)
    800034a2:	ec26                	sd	s1,24(sp)
    800034a4:	e84a                	sd	s2,16(sp)
    800034a6:	e44e                	sd	s3,8(sp)
    800034a8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034aa:	00005597          	auipc	a1,0x5
    800034ae:	11658593          	addi	a1,a1,278 # 800085c0 <syscalls+0x158>
    800034b2:	0001c517          	auipc	a0,0x1c
    800034b6:	be650513          	addi	a0,a0,-1050 # 8001f098 <itable>
    800034ba:	ffffd097          	auipc	ra,0xffffd
    800034be:	68c080e7          	jalr	1676(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034c2:	0001c497          	auipc	s1,0x1c
    800034c6:	bfe48493          	addi	s1,s1,-1026 # 8001f0c0 <itable+0x28>
    800034ca:	0001d997          	auipc	s3,0x1d
    800034ce:	68698993          	addi	s3,s3,1670 # 80020b50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034d2:	00005917          	auipc	s2,0x5
    800034d6:	0f690913          	addi	s2,s2,246 # 800085c8 <syscalls+0x160>
    800034da:	85ca                	mv	a1,s2
    800034dc:	8526                	mv	a0,s1
    800034de:	00001097          	auipc	ra,0x1
    800034e2:	e42080e7          	jalr	-446(ra) # 80004320 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034e6:	08848493          	addi	s1,s1,136
    800034ea:	ff3498e3          	bne	s1,s3,800034da <iinit+0x3e>
}
    800034ee:	70a2                	ld	ra,40(sp)
    800034f0:	7402                	ld	s0,32(sp)
    800034f2:	64e2                	ld	s1,24(sp)
    800034f4:	6942                	ld	s2,16(sp)
    800034f6:	69a2                	ld	s3,8(sp)
    800034f8:	6145                	addi	sp,sp,48
    800034fa:	8082                	ret

00000000800034fc <ialloc>:
{
    800034fc:	715d                	addi	sp,sp,-80
    800034fe:	e486                	sd	ra,72(sp)
    80003500:	e0a2                	sd	s0,64(sp)
    80003502:	fc26                	sd	s1,56(sp)
    80003504:	f84a                	sd	s2,48(sp)
    80003506:	f44e                	sd	s3,40(sp)
    80003508:	f052                	sd	s4,32(sp)
    8000350a:	ec56                	sd	s5,24(sp)
    8000350c:	e85a                	sd	s6,16(sp)
    8000350e:	e45e                	sd	s7,8(sp)
    80003510:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003512:	0001c717          	auipc	a4,0x1c
    80003516:	b7272703          	lw	a4,-1166(a4) # 8001f084 <sb+0xc>
    8000351a:	4785                	li	a5,1
    8000351c:	04e7fa63          	bgeu	a5,a4,80003570 <ialloc+0x74>
    80003520:	8aaa                	mv	s5,a0
    80003522:	8bae                	mv	s7,a1
    80003524:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003526:	0001ca17          	auipc	s4,0x1c
    8000352a:	b52a0a13          	addi	s4,s4,-1198 # 8001f078 <sb>
    8000352e:	00048b1b          	sext.w	s6,s1
    80003532:	0044d593          	srli	a1,s1,0x4
    80003536:	018a2783          	lw	a5,24(s4)
    8000353a:	9dbd                	addw	a1,a1,a5
    8000353c:	8556                	mv	a0,s5
    8000353e:	00000097          	auipc	ra,0x0
    80003542:	944080e7          	jalr	-1724(ra) # 80002e82 <bread>
    80003546:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003548:	05850993          	addi	s3,a0,88
    8000354c:	00f4f793          	andi	a5,s1,15
    80003550:	079a                	slli	a5,a5,0x6
    80003552:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003554:	00099783          	lh	a5,0(s3)
    80003558:	c3a1                	beqz	a5,80003598 <ialloc+0x9c>
    brelse(bp);
    8000355a:	00000097          	auipc	ra,0x0
    8000355e:	a58080e7          	jalr	-1448(ra) # 80002fb2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003562:	0485                	addi	s1,s1,1
    80003564:	00ca2703          	lw	a4,12(s4)
    80003568:	0004879b          	sext.w	a5,s1
    8000356c:	fce7e1e3          	bltu	a5,a4,8000352e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003570:	00005517          	auipc	a0,0x5
    80003574:	06050513          	addi	a0,a0,96 # 800085d0 <syscalls+0x168>
    80003578:	ffffd097          	auipc	ra,0xffffd
    8000357c:	012080e7          	jalr	18(ra) # 8000058a <printf>
  return 0;
    80003580:	4501                	li	a0,0
}
    80003582:	60a6                	ld	ra,72(sp)
    80003584:	6406                	ld	s0,64(sp)
    80003586:	74e2                	ld	s1,56(sp)
    80003588:	7942                	ld	s2,48(sp)
    8000358a:	79a2                	ld	s3,40(sp)
    8000358c:	7a02                	ld	s4,32(sp)
    8000358e:	6ae2                	ld	s5,24(sp)
    80003590:	6b42                	ld	s6,16(sp)
    80003592:	6ba2                	ld	s7,8(sp)
    80003594:	6161                	addi	sp,sp,80
    80003596:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003598:	04000613          	li	a2,64
    8000359c:	4581                	li	a1,0
    8000359e:	854e                	mv	a0,s3
    800035a0:	ffffd097          	auipc	ra,0xffffd
    800035a4:	732080e7          	jalr	1842(ra) # 80000cd2 <memset>
      dip->type = type;
    800035a8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035ac:	854a                	mv	a0,s2
    800035ae:	00001097          	auipc	ra,0x1
    800035b2:	c8e080e7          	jalr	-882(ra) # 8000423c <log_write>
      brelse(bp);
    800035b6:	854a                	mv	a0,s2
    800035b8:	00000097          	auipc	ra,0x0
    800035bc:	9fa080e7          	jalr	-1542(ra) # 80002fb2 <brelse>
      return iget(dev, inum);
    800035c0:	85da                	mv	a1,s6
    800035c2:	8556                	mv	a0,s5
    800035c4:	00000097          	auipc	ra,0x0
    800035c8:	d9c080e7          	jalr	-612(ra) # 80003360 <iget>
    800035cc:	bf5d                	j	80003582 <ialloc+0x86>

00000000800035ce <iupdate>:
{
    800035ce:	1101                	addi	sp,sp,-32
    800035d0:	ec06                	sd	ra,24(sp)
    800035d2:	e822                	sd	s0,16(sp)
    800035d4:	e426                	sd	s1,8(sp)
    800035d6:	e04a                	sd	s2,0(sp)
    800035d8:	1000                	addi	s0,sp,32
    800035da:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035dc:	415c                	lw	a5,4(a0)
    800035de:	0047d79b          	srliw	a5,a5,0x4
    800035e2:	0001c597          	auipc	a1,0x1c
    800035e6:	aae5a583          	lw	a1,-1362(a1) # 8001f090 <sb+0x18>
    800035ea:	9dbd                	addw	a1,a1,a5
    800035ec:	4108                	lw	a0,0(a0)
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	894080e7          	jalr	-1900(ra) # 80002e82 <bread>
    800035f6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035f8:	05850793          	addi	a5,a0,88
    800035fc:	40d8                	lw	a4,4(s1)
    800035fe:	8b3d                	andi	a4,a4,15
    80003600:	071a                	slli	a4,a4,0x6
    80003602:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003604:	04449703          	lh	a4,68(s1)
    80003608:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000360c:	04649703          	lh	a4,70(s1)
    80003610:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003614:	04849703          	lh	a4,72(s1)
    80003618:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000361c:	04a49703          	lh	a4,74(s1)
    80003620:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003624:	44f8                	lw	a4,76(s1)
    80003626:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003628:	03400613          	li	a2,52
    8000362c:	05048593          	addi	a1,s1,80
    80003630:	00c78513          	addi	a0,a5,12
    80003634:	ffffd097          	auipc	ra,0xffffd
    80003638:	6fa080e7          	jalr	1786(ra) # 80000d2e <memmove>
  log_write(bp);
    8000363c:	854a                	mv	a0,s2
    8000363e:	00001097          	auipc	ra,0x1
    80003642:	bfe080e7          	jalr	-1026(ra) # 8000423c <log_write>
  brelse(bp);
    80003646:	854a                	mv	a0,s2
    80003648:	00000097          	auipc	ra,0x0
    8000364c:	96a080e7          	jalr	-1686(ra) # 80002fb2 <brelse>
}
    80003650:	60e2                	ld	ra,24(sp)
    80003652:	6442                	ld	s0,16(sp)
    80003654:	64a2                	ld	s1,8(sp)
    80003656:	6902                	ld	s2,0(sp)
    80003658:	6105                	addi	sp,sp,32
    8000365a:	8082                	ret

000000008000365c <idup>:
{
    8000365c:	1101                	addi	sp,sp,-32
    8000365e:	ec06                	sd	ra,24(sp)
    80003660:	e822                	sd	s0,16(sp)
    80003662:	e426                	sd	s1,8(sp)
    80003664:	1000                	addi	s0,sp,32
    80003666:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003668:	0001c517          	auipc	a0,0x1c
    8000366c:	a3050513          	addi	a0,a0,-1488 # 8001f098 <itable>
    80003670:	ffffd097          	auipc	ra,0xffffd
    80003674:	566080e7          	jalr	1382(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003678:	449c                	lw	a5,8(s1)
    8000367a:	2785                	addiw	a5,a5,1
    8000367c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000367e:	0001c517          	auipc	a0,0x1c
    80003682:	a1a50513          	addi	a0,a0,-1510 # 8001f098 <itable>
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	604080e7          	jalr	1540(ra) # 80000c8a <release>
}
    8000368e:	8526                	mv	a0,s1
    80003690:	60e2                	ld	ra,24(sp)
    80003692:	6442                	ld	s0,16(sp)
    80003694:	64a2                	ld	s1,8(sp)
    80003696:	6105                	addi	sp,sp,32
    80003698:	8082                	ret

000000008000369a <ilock>:
{
    8000369a:	1101                	addi	sp,sp,-32
    8000369c:	ec06                	sd	ra,24(sp)
    8000369e:	e822                	sd	s0,16(sp)
    800036a0:	e426                	sd	s1,8(sp)
    800036a2:	e04a                	sd	s2,0(sp)
    800036a4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036a6:	c115                	beqz	a0,800036ca <ilock+0x30>
    800036a8:	84aa                	mv	s1,a0
    800036aa:	451c                	lw	a5,8(a0)
    800036ac:	00f05f63          	blez	a5,800036ca <ilock+0x30>
  acquiresleep(&ip->lock);
    800036b0:	0541                	addi	a0,a0,16
    800036b2:	00001097          	auipc	ra,0x1
    800036b6:	ca8080e7          	jalr	-856(ra) # 8000435a <acquiresleep>
  if(ip->valid == 0){
    800036ba:	40bc                	lw	a5,64(s1)
    800036bc:	cf99                	beqz	a5,800036da <ilock+0x40>
}
    800036be:	60e2                	ld	ra,24(sp)
    800036c0:	6442                	ld	s0,16(sp)
    800036c2:	64a2                	ld	s1,8(sp)
    800036c4:	6902                	ld	s2,0(sp)
    800036c6:	6105                	addi	sp,sp,32
    800036c8:	8082                	ret
    panic("ilock");
    800036ca:	00005517          	auipc	a0,0x5
    800036ce:	f1e50513          	addi	a0,a0,-226 # 800085e8 <syscalls+0x180>
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	e6e080e7          	jalr	-402(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036da:	40dc                	lw	a5,4(s1)
    800036dc:	0047d79b          	srliw	a5,a5,0x4
    800036e0:	0001c597          	auipc	a1,0x1c
    800036e4:	9b05a583          	lw	a1,-1616(a1) # 8001f090 <sb+0x18>
    800036e8:	9dbd                	addw	a1,a1,a5
    800036ea:	4088                	lw	a0,0(s1)
    800036ec:	fffff097          	auipc	ra,0xfffff
    800036f0:	796080e7          	jalr	1942(ra) # 80002e82 <bread>
    800036f4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036f6:	05850593          	addi	a1,a0,88
    800036fa:	40dc                	lw	a5,4(s1)
    800036fc:	8bbd                	andi	a5,a5,15
    800036fe:	079a                	slli	a5,a5,0x6
    80003700:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003702:	00059783          	lh	a5,0(a1)
    80003706:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000370a:	00259783          	lh	a5,2(a1)
    8000370e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003712:	00459783          	lh	a5,4(a1)
    80003716:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000371a:	00659783          	lh	a5,6(a1)
    8000371e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003722:	459c                	lw	a5,8(a1)
    80003724:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003726:	03400613          	li	a2,52
    8000372a:	05b1                	addi	a1,a1,12
    8000372c:	05048513          	addi	a0,s1,80
    80003730:	ffffd097          	auipc	ra,0xffffd
    80003734:	5fe080e7          	jalr	1534(ra) # 80000d2e <memmove>
    brelse(bp);
    80003738:	854a                	mv	a0,s2
    8000373a:	00000097          	auipc	ra,0x0
    8000373e:	878080e7          	jalr	-1928(ra) # 80002fb2 <brelse>
    ip->valid = 1;
    80003742:	4785                	li	a5,1
    80003744:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003746:	04449783          	lh	a5,68(s1)
    8000374a:	fbb5                	bnez	a5,800036be <ilock+0x24>
      panic("ilock: no type");
    8000374c:	00005517          	auipc	a0,0x5
    80003750:	ea450513          	addi	a0,a0,-348 # 800085f0 <syscalls+0x188>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	dec080e7          	jalr	-532(ra) # 80000540 <panic>

000000008000375c <iunlock>:
{
    8000375c:	1101                	addi	sp,sp,-32
    8000375e:	ec06                	sd	ra,24(sp)
    80003760:	e822                	sd	s0,16(sp)
    80003762:	e426                	sd	s1,8(sp)
    80003764:	e04a                	sd	s2,0(sp)
    80003766:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003768:	c905                	beqz	a0,80003798 <iunlock+0x3c>
    8000376a:	84aa                	mv	s1,a0
    8000376c:	01050913          	addi	s2,a0,16
    80003770:	854a                	mv	a0,s2
    80003772:	00001097          	auipc	ra,0x1
    80003776:	c82080e7          	jalr	-894(ra) # 800043f4 <holdingsleep>
    8000377a:	cd19                	beqz	a0,80003798 <iunlock+0x3c>
    8000377c:	449c                	lw	a5,8(s1)
    8000377e:	00f05d63          	blez	a5,80003798 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003782:	854a                	mv	a0,s2
    80003784:	00001097          	auipc	ra,0x1
    80003788:	c2c080e7          	jalr	-980(ra) # 800043b0 <releasesleep>
}
    8000378c:	60e2                	ld	ra,24(sp)
    8000378e:	6442                	ld	s0,16(sp)
    80003790:	64a2                	ld	s1,8(sp)
    80003792:	6902                	ld	s2,0(sp)
    80003794:	6105                	addi	sp,sp,32
    80003796:	8082                	ret
    panic("iunlock");
    80003798:	00005517          	auipc	a0,0x5
    8000379c:	e6850513          	addi	a0,a0,-408 # 80008600 <syscalls+0x198>
    800037a0:	ffffd097          	auipc	ra,0xffffd
    800037a4:	da0080e7          	jalr	-608(ra) # 80000540 <panic>

00000000800037a8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037a8:	7179                	addi	sp,sp,-48
    800037aa:	f406                	sd	ra,40(sp)
    800037ac:	f022                	sd	s0,32(sp)
    800037ae:	ec26                	sd	s1,24(sp)
    800037b0:	e84a                	sd	s2,16(sp)
    800037b2:	e44e                	sd	s3,8(sp)
    800037b4:	e052                	sd	s4,0(sp)
    800037b6:	1800                	addi	s0,sp,48
    800037b8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037ba:	05050493          	addi	s1,a0,80
    800037be:	08050913          	addi	s2,a0,128
    800037c2:	a021                	j	800037ca <itrunc+0x22>
    800037c4:	0491                	addi	s1,s1,4
    800037c6:	01248d63          	beq	s1,s2,800037e0 <itrunc+0x38>
    if(ip->addrs[i]){
    800037ca:	408c                	lw	a1,0(s1)
    800037cc:	dde5                	beqz	a1,800037c4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037ce:	0009a503          	lw	a0,0(s3)
    800037d2:	00000097          	auipc	ra,0x0
    800037d6:	8f6080e7          	jalr	-1802(ra) # 800030c8 <bfree>
      ip->addrs[i] = 0;
    800037da:	0004a023          	sw	zero,0(s1)
    800037de:	b7dd                	j	800037c4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037e0:	0809a583          	lw	a1,128(s3)
    800037e4:	e185                	bnez	a1,80003804 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037e6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037ea:	854e                	mv	a0,s3
    800037ec:	00000097          	auipc	ra,0x0
    800037f0:	de2080e7          	jalr	-542(ra) # 800035ce <iupdate>
}
    800037f4:	70a2                	ld	ra,40(sp)
    800037f6:	7402                	ld	s0,32(sp)
    800037f8:	64e2                	ld	s1,24(sp)
    800037fa:	6942                	ld	s2,16(sp)
    800037fc:	69a2                	ld	s3,8(sp)
    800037fe:	6a02                	ld	s4,0(sp)
    80003800:	6145                	addi	sp,sp,48
    80003802:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003804:	0009a503          	lw	a0,0(s3)
    80003808:	fffff097          	auipc	ra,0xfffff
    8000380c:	67a080e7          	jalr	1658(ra) # 80002e82 <bread>
    80003810:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003812:	05850493          	addi	s1,a0,88
    80003816:	45850913          	addi	s2,a0,1112
    8000381a:	a021                	j	80003822 <itrunc+0x7a>
    8000381c:	0491                	addi	s1,s1,4
    8000381e:	01248b63          	beq	s1,s2,80003834 <itrunc+0x8c>
      if(a[j])
    80003822:	408c                	lw	a1,0(s1)
    80003824:	dde5                	beqz	a1,8000381c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003826:	0009a503          	lw	a0,0(s3)
    8000382a:	00000097          	auipc	ra,0x0
    8000382e:	89e080e7          	jalr	-1890(ra) # 800030c8 <bfree>
    80003832:	b7ed                	j	8000381c <itrunc+0x74>
    brelse(bp);
    80003834:	8552                	mv	a0,s4
    80003836:	fffff097          	auipc	ra,0xfffff
    8000383a:	77c080e7          	jalr	1916(ra) # 80002fb2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000383e:	0809a583          	lw	a1,128(s3)
    80003842:	0009a503          	lw	a0,0(s3)
    80003846:	00000097          	auipc	ra,0x0
    8000384a:	882080e7          	jalr	-1918(ra) # 800030c8 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000384e:	0809a023          	sw	zero,128(s3)
    80003852:	bf51                	j	800037e6 <itrunc+0x3e>

0000000080003854 <iput>:
{
    80003854:	1101                	addi	sp,sp,-32
    80003856:	ec06                	sd	ra,24(sp)
    80003858:	e822                	sd	s0,16(sp)
    8000385a:	e426                	sd	s1,8(sp)
    8000385c:	e04a                	sd	s2,0(sp)
    8000385e:	1000                	addi	s0,sp,32
    80003860:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003862:	0001c517          	auipc	a0,0x1c
    80003866:	83650513          	addi	a0,a0,-1994 # 8001f098 <itable>
    8000386a:	ffffd097          	auipc	ra,0xffffd
    8000386e:	36c080e7          	jalr	876(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003872:	4498                	lw	a4,8(s1)
    80003874:	4785                	li	a5,1
    80003876:	02f70363          	beq	a4,a5,8000389c <iput+0x48>
  ip->ref--;
    8000387a:	449c                	lw	a5,8(s1)
    8000387c:	37fd                	addiw	a5,a5,-1
    8000387e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003880:	0001c517          	auipc	a0,0x1c
    80003884:	81850513          	addi	a0,a0,-2024 # 8001f098 <itable>
    80003888:	ffffd097          	auipc	ra,0xffffd
    8000388c:	402080e7          	jalr	1026(ra) # 80000c8a <release>
}
    80003890:	60e2                	ld	ra,24(sp)
    80003892:	6442                	ld	s0,16(sp)
    80003894:	64a2                	ld	s1,8(sp)
    80003896:	6902                	ld	s2,0(sp)
    80003898:	6105                	addi	sp,sp,32
    8000389a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000389c:	40bc                	lw	a5,64(s1)
    8000389e:	dff1                	beqz	a5,8000387a <iput+0x26>
    800038a0:	04a49783          	lh	a5,74(s1)
    800038a4:	fbf9                	bnez	a5,8000387a <iput+0x26>
    acquiresleep(&ip->lock);
    800038a6:	01048913          	addi	s2,s1,16
    800038aa:	854a                	mv	a0,s2
    800038ac:	00001097          	auipc	ra,0x1
    800038b0:	aae080e7          	jalr	-1362(ra) # 8000435a <acquiresleep>
    release(&itable.lock);
    800038b4:	0001b517          	auipc	a0,0x1b
    800038b8:	7e450513          	addi	a0,a0,2020 # 8001f098 <itable>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	3ce080e7          	jalr	974(ra) # 80000c8a <release>
    itrunc(ip);
    800038c4:	8526                	mv	a0,s1
    800038c6:	00000097          	auipc	ra,0x0
    800038ca:	ee2080e7          	jalr	-286(ra) # 800037a8 <itrunc>
    ip->type = 0;
    800038ce:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038d2:	8526                	mv	a0,s1
    800038d4:	00000097          	auipc	ra,0x0
    800038d8:	cfa080e7          	jalr	-774(ra) # 800035ce <iupdate>
    ip->valid = 0;
    800038dc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038e0:	854a                	mv	a0,s2
    800038e2:	00001097          	auipc	ra,0x1
    800038e6:	ace080e7          	jalr	-1330(ra) # 800043b0 <releasesleep>
    acquire(&itable.lock);
    800038ea:	0001b517          	auipc	a0,0x1b
    800038ee:	7ae50513          	addi	a0,a0,1966 # 8001f098 <itable>
    800038f2:	ffffd097          	auipc	ra,0xffffd
    800038f6:	2e4080e7          	jalr	740(ra) # 80000bd6 <acquire>
    800038fa:	b741                	j	8000387a <iput+0x26>

00000000800038fc <iunlockput>:
{
    800038fc:	1101                	addi	sp,sp,-32
    800038fe:	ec06                	sd	ra,24(sp)
    80003900:	e822                	sd	s0,16(sp)
    80003902:	e426                	sd	s1,8(sp)
    80003904:	1000                	addi	s0,sp,32
    80003906:	84aa                	mv	s1,a0
  iunlock(ip);
    80003908:	00000097          	auipc	ra,0x0
    8000390c:	e54080e7          	jalr	-428(ra) # 8000375c <iunlock>
  iput(ip);
    80003910:	8526                	mv	a0,s1
    80003912:	00000097          	auipc	ra,0x0
    80003916:	f42080e7          	jalr	-190(ra) # 80003854 <iput>
}
    8000391a:	60e2                	ld	ra,24(sp)
    8000391c:	6442                	ld	s0,16(sp)
    8000391e:	64a2                	ld	s1,8(sp)
    80003920:	6105                	addi	sp,sp,32
    80003922:	8082                	ret

0000000080003924 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003924:	1141                	addi	sp,sp,-16
    80003926:	e422                	sd	s0,8(sp)
    80003928:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000392a:	411c                	lw	a5,0(a0)
    8000392c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000392e:	415c                	lw	a5,4(a0)
    80003930:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003932:	04451783          	lh	a5,68(a0)
    80003936:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000393a:	04a51783          	lh	a5,74(a0)
    8000393e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003942:	04c56783          	lwu	a5,76(a0)
    80003946:	e99c                	sd	a5,16(a1)
}
    80003948:	6422                	ld	s0,8(sp)
    8000394a:	0141                	addi	sp,sp,16
    8000394c:	8082                	ret

000000008000394e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000394e:	457c                	lw	a5,76(a0)
    80003950:	0ed7e963          	bltu	a5,a3,80003a42 <readi+0xf4>
{
    80003954:	7159                	addi	sp,sp,-112
    80003956:	f486                	sd	ra,104(sp)
    80003958:	f0a2                	sd	s0,96(sp)
    8000395a:	eca6                	sd	s1,88(sp)
    8000395c:	e8ca                	sd	s2,80(sp)
    8000395e:	e4ce                	sd	s3,72(sp)
    80003960:	e0d2                	sd	s4,64(sp)
    80003962:	fc56                	sd	s5,56(sp)
    80003964:	f85a                	sd	s6,48(sp)
    80003966:	f45e                	sd	s7,40(sp)
    80003968:	f062                	sd	s8,32(sp)
    8000396a:	ec66                	sd	s9,24(sp)
    8000396c:	e86a                	sd	s10,16(sp)
    8000396e:	e46e                	sd	s11,8(sp)
    80003970:	1880                	addi	s0,sp,112
    80003972:	8b2a                	mv	s6,a0
    80003974:	8bae                	mv	s7,a1
    80003976:	8a32                	mv	s4,a2
    80003978:	84b6                	mv	s1,a3
    8000397a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000397c:	9f35                	addw	a4,a4,a3
    return 0;
    8000397e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003980:	0ad76063          	bltu	a4,a3,80003a20 <readi+0xd2>
  if(off + n > ip->size)
    80003984:	00e7f463          	bgeu	a5,a4,8000398c <readi+0x3e>
    n = ip->size - off;
    80003988:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000398c:	0a0a8963          	beqz	s5,80003a3e <readi+0xf0>
    80003990:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003992:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003996:	5c7d                	li	s8,-1
    80003998:	a82d                	j	800039d2 <readi+0x84>
    8000399a:	020d1d93          	slli	s11,s10,0x20
    8000399e:	020ddd93          	srli	s11,s11,0x20
    800039a2:	05890613          	addi	a2,s2,88
    800039a6:	86ee                	mv	a3,s11
    800039a8:	963a                	add	a2,a2,a4
    800039aa:	85d2                	mv	a1,s4
    800039ac:	855e                	mv	a0,s7
    800039ae:	fffff097          	auipc	ra,0xfffff
    800039b2:	aae080e7          	jalr	-1362(ra) # 8000245c <either_copyout>
    800039b6:	05850d63          	beq	a0,s8,80003a10 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039ba:	854a                	mv	a0,s2
    800039bc:	fffff097          	auipc	ra,0xfffff
    800039c0:	5f6080e7          	jalr	1526(ra) # 80002fb2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039c4:	013d09bb          	addw	s3,s10,s3
    800039c8:	009d04bb          	addw	s1,s10,s1
    800039cc:	9a6e                	add	s4,s4,s11
    800039ce:	0559f763          	bgeu	s3,s5,80003a1c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800039d2:	00a4d59b          	srliw	a1,s1,0xa
    800039d6:	855a                	mv	a0,s6
    800039d8:	00000097          	auipc	ra,0x0
    800039dc:	89e080e7          	jalr	-1890(ra) # 80003276 <bmap>
    800039e0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039e4:	cd85                	beqz	a1,80003a1c <readi+0xce>
    bp = bread(ip->dev, addr);
    800039e6:	000b2503          	lw	a0,0(s6)
    800039ea:	fffff097          	auipc	ra,0xfffff
    800039ee:	498080e7          	jalr	1176(ra) # 80002e82 <bread>
    800039f2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039f4:	3ff4f713          	andi	a4,s1,1023
    800039f8:	40ec87bb          	subw	a5,s9,a4
    800039fc:	413a86bb          	subw	a3,s5,s3
    80003a00:	8d3e                	mv	s10,a5
    80003a02:	2781                	sext.w	a5,a5
    80003a04:	0006861b          	sext.w	a2,a3
    80003a08:	f8f679e3          	bgeu	a2,a5,8000399a <readi+0x4c>
    80003a0c:	8d36                	mv	s10,a3
    80003a0e:	b771                	j	8000399a <readi+0x4c>
      brelse(bp);
    80003a10:	854a                	mv	a0,s2
    80003a12:	fffff097          	auipc	ra,0xfffff
    80003a16:	5a0080e7          	jalr	1440(ra) # 80002fb2 <brelse>
      tot = -1;
    80003a1a:	59fd                	li	s3,-1
  }
  return tot;
    80003a1c:	0009851b          	sext.w	a0,s3
}
    80003a20:	70a6                	ld	ra,104(sp)
    80003a22:	7406                	ld	s0,96(sp)
    80003a24:	64e6                	ld	s1,88(sp)
    80003a26:	6946                	ld	s2,80(sp)
    80003a28:	69a6                	ld	s3,72(sp)
    80003a2a:	6a06                	ld	s4,64(sp)
    80003a2c:	7ae2                	ld	s5,56(sp)
    80003a2e:	7b42                	ld	s6,48(sp)
    80003a30:	7ba2                	ld	s7,40(sp)
    80003a32:	7c02                	ld	s8,32(sp)
    80003a34:	6ce2                	ld	s9,24(sp)
    80003a36:	6d42                	ld	s10,16(sp)
    80003a38:	6da2                	ld	s11,8(sp)
    80003a3a:	6165                	addi	sp,sp,112
    80003a3c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a3e:	89d6                	mv	s3,s5
    80003a40:	bff1                	j	80003a1c <readi+0xce>
    return 0;
    80003a42:	4501                	li	a0,0
}
    80003a44:	8082                	ret

0000000080003a46 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a46:	457c                	lw	a5,76(a0)
    80003a48:	10d7e863          	bltu	a5,a3,80003b58 <writei+0x112>
{
    80003a4c:	7159                	addi	sp,sp,-112
    80003a4e:	f486                	sd	ra,104(sp)
    80003a50:	f0a2                	sd	s0,96(sp)
    80003a52:	eca6                	sd	s1,88(sp)
    80003a54:	e8ca                	sd	s2,80(sp)
    80003a56:	e4ce                	sd	s3,72(sp)
    80003a58:	e0d2                	sd	s4,64(sp)
    80003a5a:	fc56                	sd	s5,56(sp)
    80003a5c:	f85a                	sd	s6,48(sp)
    80003a5e:	f45e                	sd	s7,40(sp)
    80003a60:	f062                	sd	s8,32(sp)
    80003a62:	ec66                	sd	s9,24(sp)
    80003a64:	e86a                	sd	s10,16(sp)
    80003a66:	e46e                	sd	s11,8(sp)
    80003a68:	1880                	addi	s0,sp,112
    80003a6a:	8aaa                	mv	s5,a0
    80003a6c:	8bae                	mv	s7,a1
    80003a6e:	8a32                	mv	s4,a2
    80003a70:	8936                	mv	s2,a3
    80003a72:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a74:	00e687bb          	addw	a5,a3,a4
    80003a78:	0ed7e263          	bltu	a5,a3,80003b5c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a7c:	00043737          	lui	a4,0x43
    80003a80:	0ef76063          	bltu	a4,a5,80003b60 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a84:	0c0b0863          	beqz	s6,80003b54 <writei+0x10e>
    80003a88:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a8a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a8e:	5c7d                	li	s8,-1
    80003a90:	a091                	j	80003ad4 <writei+0x8e>
    80003a92:	020d1d93          	slli	s11,s10,0x20
    80003a96:	020ddd93          	srli	s11,s11,0x20
    80003a9a:	05848513          	addi	a0,s1,88
    80003a9e:	86ee                	mv	a3,s11
    80003aa0:	8652                	mv	a2,s4
    80003aa2:	85de                	mv	a1,s7
    80003aa4:	953a                	add	a0,a0,a4
    80003aa6:	fffff097          	auipc	ra,0xfffff
    80003aaa:	a0c080e7          	jalr	-1524(ra) # 800024b2 <either_copyin>
    80003aae:	07850263          	beq	a0,s8,80003b12 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ab2:	8526                	mv	a0,s1
    80003ab4:	00000097          	auipc	ra,0x0
    80003ab8:	788080e7          	jalr	1928(ra) # 8000423c <log_write>
    brelse(bp);
    80003abc:	8526                	mv	a0,s1
    80003abe:	fffff097          	auipc	ra,0xfffff
    80003ac2:	4f4080e7          	jalr	1268(ra) # 80002fb2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ac6:	013d09bb          	addw	s3,s10,s3
    80003aca:	012d093b          	addw	s2,s10,s2
    80003ace:	9a6e                	add	s4,s4,s11
    80003ad0:	0569f663          	bgeu	s3,s6,80003b1c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003ad4:	00a9559b          	srliw	a1,s2,0xa
    80003ad8:	8556                	mv	a0,s5
    80003ada:	fffff097          	auipc	ra,0xfffff
    80003ade:	79c080e7          	jalr	1948(ra) # 80003276 <bmap>
    80003ae2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ae6:	c99d                	beqz	a1,80003b1c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003ae8:	000aa503          	lw	a0,0(s5)
    80003aec:	fffff097          	auipc	ra,0xfffff
    80003af0:	396080e7          	jalr	918(ra) # 80002e82 <bread>
    80003af4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003af6:	3ff97713          	andi	a4,s2,1023
    80003afa:	40ec87bb          	subw	a5,s9,a4
    80003afe:	413b06bb          	subw	a3,s6,s3
    80003b02:	8d3e                	mv	s10,a5
    80003b04:	2781                	sext.w	a5,a5
    80003b06:	0006861b          	sext.w	a2,a3
    80003b0a:	f8f674e3          	bgeu	a2,a5,80003a92 <writei+0x4c>
    80003b0e:	8d36                	mv	s10,a3
    80003b10:	b749                	j	80003a92 <writei+0x4c>
      brelse(bp);
    80003b12:	8526                	mv	a0,s1
    80003b14:	fffff097          	auipc	ra,0xfffff
    80003b18:	49e080e7          	jalr	1182(ra) # 80002fb2 <brelse>
  }

  if(off > ip->size)
    80003b1c:	04caa783          	lw	a5,76(s5)
    80003b20:	0127f463          	bgeu	a5,s2,80003b28 <writei+0xe2>
    ip->size = off;
    80003b24:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b28:	8556                	mv	a0,s5
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	aa4080e7          	jalr	-1372(ra) # 800035ce <iupdate>

  return tot;
    80003b32:	0009851b          	sext.w	a0,s3
}
    80003b36:	70a6                	ld	ra,104(sp)
    80003b38:	7406                	ld	s0,96(sp)
    80003b3a:	64e6                	ld	s1,88(sp)
    80003b3c:	6946                	ld	s2,80(sp)
    80003b3e:	69a6                	ld	s3,72(sp)
    80003b40:	6a06                	ld	s4,64(sp)
    80003b42:	7ae2                	ld	s5,56(sp)
    80003b44:	7b42                	ld	s6,48(sp)
    80003b46:	7ba2                	ld	s7,40(sp)
    80003b48:	7c02                	ld	s8,32(sp)
    80003b4a:	6ce2                	ld	s9,24(sp)
    80003b4c:	6d42                	ld	s10,16(sp)
    80003b4e:	6da2                	ld	s11,8(sp)
    80003b50:	6165                	addi	sp,sp,112
    80003b52:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b54:	89da                	mv	s3,s6
    80003b56:	bfc9                	j	80003b28 <writei+0xe2>
    return -1;
    80003b58:	557d                	li	a0,-1
}
    80003b5a:	8082                	ret
    return -1;
    80003b5c:	557d                	li	a0,-1
    80003b5e:	bfe1                	j	80003b36 <writei+0xf0>
    return -1;
    80003b60:	557d                	li	a0,-1
    80003b62:	bfd1                	j	80003b36 <writei+0xf0>

0000000080003b64 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b64:	1141                	addi	sp,sp,-16
    80003b66:	e406                	sd	ra,8(sp)
    80003b68:	e022                	sd	s0,0(sp)
    80003b6a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b6c:	4639                	li	a2,14
    80003b6e:	ffffd097          	auipc	ra,0xffffd
    80003b72:	234080e7          	jalr	564(ra) # 80000da2 <strncmp>
}
    80003b76:	60a2                	ld	ra,8(sp)
    80003b78:	6402                	ld	s0,0(sp)
    80003b7a:	0141                	addi	sp,sp,16
    80003b7c:	8082                	ret

0000000080003b7e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b7e:	7139                	addi	sp,sp,-64
    80003b80:	fc06                	sd	ra,56(sp)
    80003b82:	f822                	sd	s0,48(sp)
    80003b84:	f426                	sd	s1,40(sp)
    80003b86:	f04a                	sd	s2,32(sp)
    80003b88:	ec4e                	sd	s3,24(sp)
    80003b8a:	e852                	sd	s4,16(sp)
    80003b8c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b8e:	04451703          	lh	a4,68(a0)
    80003b92:	4785                	li	a5,1
    80003b94:	00f71a63          	bne	a4,a5,80003ba8 <dirlookup+0x2a>
    80003b98:	892a                	mv	s2,a0
    80003b9a:	89ae                	mv	s3,a1
    80003b9c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b9e:	457c                	lw	a5,76(a0)
    80003ba0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ba2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ba4:	e79d                	bnez	a5,80003bd2 <dirlookup+0x54>
    80003ba6:	a8a5                	j	80003c1e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ba8:	00005517          	auipc	a0,0x5
    80003bac:	a6050513          	addi	a0,a0,-1440 # 80008608 <syscalls+0x1a0>
    80003bb0:	ffffd097          	auipc	ra,0xffffd
    80003bb4:	990080e7          	jalr	-1648(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003bb8:	00005517          	auipc	a0,0x5
    80003bbc:	a6850513          	addi	a0,a0,-1432 # 80008620 <syscalls+0x1b8>
    80003bc0:	ffffd097          	auipc	ra,0xffffd
    80003bc4:	980080e7          	jalr	-1664(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bc8:	24c1                	addiw	s1,s1,16
    80003bca:	04c92783          	lw	a5,76(s2)
    80003bce:	04f4f763          	bgeu	s1,a5,80003c1c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bd2:	4741                	li	a4,16
    80003bd4:	86a6                	mv	a3,s1
    80003bd6:	fc040613          	addi	a2,s0,-64
    80003bda:	4581                	li	a1,0
    80003bdc:	854a                	mv	a0,s2
    80003bde:	00000097          	auipc	ra,0x0
    80003be2:	d70080e7          	jalr	-656(ra) # 8000394e <readi>
    80003be6:	47c1                	li	a5,16
    80003be8:	fcf518e3          	bne	a0,a5,80003bb8 <dirlookup+0x3a>
    if(de.inum == 0)
    80003bec:	fc045783          	lhu	a5,-64(s0)
    80003bf0:	dfe1                	beqz	a5,80003bc8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bf2:	fc240593          	addi	a1,s0,-62
    80003bf6:	854e                	mv	a0,s3
    80003bf8:	00000097          	auipc	ra,0x0
    80003bfc:	f6c080e7          	jalr	-148(ra) # 80003b64 <namecmp>
    80003c00:	f561                	bnez	a0,80003bc8 <dirlookup+0x4a>
      if(poff)
    80003c02:	000a0463          	beqz	s4,80003c0a <dirlookup+0x8c>
        *poff = off;
    80003c06:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c0a:	fc045583          	lhu	a1,-64(s0)
    80003c0e:	00092503          	lw	a0,0(s2)
    80003c12:	fffff097          	auipc	ra,0xfffff
    80003c16:	74e080e7          	jalr	1870(ra) # 80003360 <iget>
    80003c1a:	a011                	j	80003c1e <dirlookup+0xa0>
  return 0;
    80003c1c:	4501                	li	a0,0
}
    80003c1e:	70e2                	ld	ra,56(sp)
    80003c20:	7442                	ld	s0,48(sp)
    80003c22:	74a2                	ld	s1,40(sp)
    80003c24:	7902                	ld	s2,32(sp)
    80003c26:	69e2                	ld	s3,24(sp)
    80003c28:	6a42                	ld	s4,16(sp)
    80003c2a:	6121                	addi	sp,sp,64
    80003c2c:	8082                	ret

0000000080003c2e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c2e:	711d                	addi	sp,sp,-96
    80003c30:	ec86                	sd	ra,88(sp)
    80003c32:	e8a2                	sd	s0,80(sp)
    80003c34:	e4a6                	sd	s1,72(sp)
    80003c36:	e0ca                	sd	s2,64(sp)
    80003c38:	fc4e                	sd	s3,56(sp)
    80003c3a:	f852                	sd	s4,48(sp)
    80003c3c:	f456                	sd	s5,40(sp)
    80003c3e:	f05a                	sd	s6,32(sp)
    80003c40:	ec5e                	sd	s7,24(sp)
    80003c42:	e862                	sd	s8,16(sp)
    80003c44:	e466                	sd	s9,8(sp)
    80003c46:	e06a                	sd	s10,0(sp)
    80003c48:	1080                	addi	s0,sp,96
    80003c4a:	84aa                	mv	s1,a0
    80003c4c:	8b2e                	mv	s6,a1
    80003c4e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c50:	00054703          	lbu	a4,0(a0)
    80003c54:	02f00793          	li	a5,47
    80003c58:	02f70363          	beq	a4,a5,80003c7e <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c5c:	ffffe097          	auipc	ra,0xffffe
    80003c60:	d50080e7          	jalr	-688(ra) # 800019ac <myproc>
    80003c64:	15053503          	ld	a0,336(a0)
    80003c68:	00000097          	auipc	ra,0x0
    80003c6c:	9f4080e7          	jalr	-1548(ra) # 8000365c <idup>
    80003c70:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c72:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c76:	4cb5                	li	s9,13
  len = path - s;
    80003c78:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c7a:	4c05                	li	s8,1
    80003c7c:	a87d                	j	80003d3a <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003c7e:	4585                	li	a1,1
    80003c80:	4505                	li	a0,1
    80003c82:	fffff097          	auipc	ra,0xfffff
    80003c86:	6de080e7          	jalr	1758(ra) # 80003360 <iget>
    80003c8a:	8a2a                	mv	s4,a0
    80003c8c:	b7dd                	j	80003c72 <namex+0x44>
      iunlockput(ip);
    80003c8e:	8552                	mv	a0,s4
    80003c90:	00000097          	auipc	ra,0x0
    80003c94:	c6c080e7          	jalr	-916(ra) # 800038fc <iunlockput>
      return 0;
    80003c98:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c9a:	8552                	mv	a0,s4
    80003c9c:	60e6                	ld	ra,88(sp)
    80003c9e:	6446                	ld	s0,80(sp)
    80003ca0:	64a6                	ld	s1,72(sp)
    80003ca2:	6906                	ld	s2,64(sp)
    80003ca4:	79e2                	ld	s3,56(sp)
    80003ca6:	7a42                	ld	s4,48(sp)
    80003ca8:	7aa2                	ld	s5,40(sp)
    80003caa:	7b02                	ld	s6,32(sp)
    80003cac:	6be2                	ld	s7,24(sp)
    80003cae:	6c42                	ld	s8,16(sp)
    80003cb0:	6ca2                	ld	s9,8(sp)
    80003cb2:	6d02                	ld	s10,0(sp)
    80003cb4:	6125                	addi	sp,sp,96
    80003cb6:	8082                	ret
      iunlock(ip);
    80003cb8:	8552                	mv	a0,s4
    80003cba:	00000097          	auipc	ra,0x0
    80003cbe:	aa2080e7          	jalr	-1374(ra) # 8000375c <iunlock>
      return ip;
    80003cc2:	bfe1                	j	80003c9a <namex+0x6c>
      iunlockput(ip);
    80003cc4:	8552                	mv	a0,s4
    80003cc6:	00000097          	auipc	ra,0x0
    80003cca:	c36080e7          	jalr	-970(ra) # 800038fc <iunlockput>
      return 0;
    80003cce:	8a4e                	mv	s4,s3
    80003cd0:	b7e9                	j	80003c9a <namex+0x6c>
  len = path - s;
    80003cd2:	40998633          	sub	a2,s3,s1
    80003cd6:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003cda:	09acd863          	bge	s9,s10,80003d6a <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003cde:	4639                	li	a2,14
    80003ce0:	85a6                	mv	a1,s1
    80003ce2:	8556                	mv	a0,s5
    80003ce4:	ffffd097          	auipc	ra,0xffffd
    80003ce8:	04a080e7          	jalr	74(ra) # 80000d2e <memmove>
    80003cec:	84ce                	mv	s1,s3
  while(*path == '/')
    80003cee:	0004c783          	lbu	a5,0(s1)
    80003cf2:	01279763          	bne	a5,s2,80003d00 <namex+0xd2>
    path++;
    80003cf6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cf8:	0004c783          	lbu	a5,0(s1)
    80003cfc:	ff278de3          	beq	a5,s2,80003cf6 <namex+0xc8>
    ilock(ip);
    80003d00:	8552                	mv	a0,s4
    80003d02:	00000097          	auipc	ra,0x0
    80003d06:	998080e7          	jalr	-1640(ra) # 8000369a <ilock>
    if(ip->type != T_DIR){
    80003d0a:	044a1783          	lh	a5,68(s4)
    80003d0e:	f98790e3          	bne	a5,s8,80003c8e <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003d12:	000b0563          	beqz	s6,80003d1c <namex+0xee>
    80003d16:	0004c783          	lbu	a5,0(s1)
    80003d1a:	dfd9                	beqz	a5,80003cb8 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d1c:	865e                	mv	a2,s7
    80003d1e:	85d6                	mv	a1,s5
    80003d20:	8552                	mv	a0,s4
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	e5c080e7          	jalr	-420(ra) # 80003b7e <dirlookup>
    80003d2a:	89aa                	mv	s3,a0
    80003d2c:	dd41                	beqz	a0,80003cc4 <namex+0x96>
    iunlockput(ip);
    80003d2e:	8552                	mv	a0,s4
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	bcc080e7          	jalr	-1076(ra) # 800038fc <iunlockput>
    ip = next;
    80003d38:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d3a:	0004c783          	lbu	a5,0(s1)
    80003d3e:	01279763          	bne	a5,s2,80003d4c <namex+0x11e>
    path++;
    80003d42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d44:	0004c783          	lbu	a5,0(s1)
    80003d48:	ff278de3          	beq	a5,s2,80003d42 <namex+0x114>
  if(*path == 0)
    80003d4c:	cb9d                	beqz	a5,80003d82 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003d4e:	0004c783          	lbu	a5,0(s1)
    80003d52:	89a6                	mv	s3,s1
  len = path - s;
    80003d54:	8d5e                	mv	s10,s7
    80003d56:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d58:	01278963          	beq	a5,s2,80003d6a <namex+0x13c>
    80003d5c:	dbbd                	beqz	a5,80003cd2 <namex+0xa4>
    path++;
    80003d5e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d60:	0009c783          	lbu	a5,0(s3)
    80003d64:	ff279ce3          	bne	a5,s2,80003d5c <namex+0x12e>
    80003d68:	b7ad                	j	80003cd2 <namex+0xa4>
    memmove(name, s, len);
    80003d6a:	2601                	sext.w	a2,a2
    80003d6c:	85a6                	mv	a1,s1
    80003d6e:	8556                	mv	a0,s5
    80003d70:	ffffd097          	auipc	ra,0xffffd
    80003d74:	fbe080e7          	jalr	-66(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003d78:	9d56                	add	s10,s10,s5
    80003d7a:	000d0023          	sb	zero,0(s10)
    80003d7e:	84ce                	mv	s1,s3
    80003d80:	b7bd                	j	80003cee <namex+0xc0>
  if(nameiparent){
    80003d82:	f00b0ce3          	beqz	s6,80003c9a <namex+0x6c>
    iput(ip);
    80003d86:	8552                	mv	a0,s4
    80003d88:	00000097          	auipc	ra,0x0
    80003d8c:	acc080e7          	jalr	-1332(ra) # 80003854 <iput>
    return 0;
    80003d90:	4a01                	li	s4,0
    80003d92:	b721                	j	80003c9a <namex+0x6c>

0000000080003d94 <dirlink>:
{
    80003d94:	7139                	addi	sp,sp,-64
    80003d96:	fc06                	sd	ra,56(sp)
    80003d98:	f822                	sd	s0,48(sp)
    80003d9a:	f426                	sd	s1,40(sp)
    80003d9c:	f04a                	sd	s2,32(sp)
    80003d9e:	ec4e                	sd	s3,24(sp)
    80003da0:	e852                	sd	s4,16(sp)
    80003da2:	0080                	addi	s0,sp,64
    80003da4:	892a                	mv	s2,a0
    80003da6:	8a2e                	mv	s4,a1
    80003da8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003daa:	4601                	li	a2,0
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	dd2080e7          	jalr	-558(ra) # 80003b7e <dirlookup>
    80003db4:	e93d                	bnez	a0,80003e2a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003db6:	04c92483          	lw	s1,76(s2)
    80003dba:	c49d                	beqz	s1,80003de8 <dirlink+0x54>
    80003dbc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dbe:	4741                	li	a4,16
    80003dc0:	86a6                	mv	a3,s1
    80003dc2:	fc040613          	addi	a2,s0,-64
    80003dc6:	4581                	li	a1,0
    80003dc8:	854a                	mv	a0,s2
    80003dca:	00000097          	auipc	ra,0x0
    80003dce:	b84080e7          	jalr	-1148(ra) # 8000394e <readi>
    80003dd2:	47c1                	li	a5,16
    80003dd4:	06f51163          	bne	a0,a5,80003e36 <dirlink+0xa2>
    if(de.inum == 0)
    80003dd8:	fc045783          	lhu	a5,-64(s0)
    80003ddc:	c791                	beqz	a5,80003de8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dde:	24c1                	addiw	s1,s1,16
    80003de0:	04c92783          	lw	a5,76(s2)
    80003de4:	fcf4ede3          	bltu	s1,a5,80003dbe <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003de8:	4639                	li	a2,14
    80003dea:	85d2                	mv	a1,s4
    80003dec:	fc240513          	addi	a0,s0,-62
    80003df0:	ffffd097          	auipc	ra,0xffffd
    80003df4:	fee080e7          	jalr	-18(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003df8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dfc:	4741                	li	a4,16
    80003dfe:	86a6                	mv	a3,s1
    80003e00:	fc040613          	addi	a2,s0,-64
    80003e04:	4581                	li	a1,0
    80003e06:	854a                	mv	a0,s2
    80003e08:	00000097          	auipc	ra,0x0
    80003e0c:	c3e080e7          	jalr	-962(ra) # 80003a46 <writei>
    80003e10:	1541                	addi	a0,a0,-16
    80003e12:	00a03533          	snez	a0,a0
    80003e16:	40a00533          	neg	a0,a0
}
    80003e1a:	70e2                	ld	ra,56(sp)
    80003e1c:	7442                	ld	s0,48(sp)
    80003e1e:	74a2                	ld	s1,40(sp)
    80003e20:	7902                	ld	s2,32(sp)
    80003e22:	69e2                	ld	s3,24(sp)
    80003e24:	6a42                	ld	s4,16(sp)
    80003e26:	6121                	addi	sp,sp,64
    80003e28:	8082                	ret
    iput(ip);
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	a2a080e7          	jalr	-1494(ra) # 80003854 <iput>
    return -1;
    80003e32:	557d                	li	a0,-1
    80003e34:	b7dd                	j	80003e1a <dirlink+0x86>
      panic("dirlink read");
    80003e36:	00004517          	auipc	a0,0x4
    80003e3a:	7fa50513          	addi	a0,a0,2042 # 80008630 <syscalls+0x1c8>
    80003e3e:	ffffc097          	auipc	ra,0xffffc
    80003e42:	702080e7          	jalr	1794(ra) # 80000540 <panic>

0000000080003e46 <namei>:

struct inode*
namei(char *path)
{
    80003e46:	1101                	addi	sp,sp,-32
    80003e48:	ec06                	sd	ra,24(sp)
    80003e4a:	e822                	sd	s0,16(sp)
    80003e4c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e4e:	fe040613          	addi	a2,s0,-32
    80003e52:	4581                	li	a1,0
    80003e54:	00000097          	auipc	ra,0x0
    80003e58:	dda080e7          	jalr	-550(ra) # 80003c2e <namex>
}
    80003e5c:	60e2                	ld	ra,24(sp)
    80003e5e:	6442                	ld	s0,16(sp)
    80003e60:	6105                	addi	sp,sp,32
    80003e62:	8082                	ret

0000000080003e64 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e64:	1141                	addi	sp,sp,-16
    80003e66:	e406                	sd	ra,8(sp)
    80003e68:	e022                	sd	s0,0(sp)
    80003e6a:	0800                	addi	s0,sp,16
    80003e6c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e6e:	4585                	li	a1,1
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	dbe080e7          	jalr	-578(ra) # 80003c2e <namex>
}
    80003e78:	60a2                	ld	ra,8(sp)
    80003e7a:	6402                	ld	s0,0(sp)
    80003e7c:	0141                	addi	sp,sp,16
    80003e7e:	8082                	ret

0000000080003e80 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e80:	1101                	addi	sp,sp,-32
    80003e82:	ec06                	sd	ra,24(sp)
    80003e84:	e822                	sd	s0,16(sp)
    80003e86:	e426                	sd	s1,8(sp)
    80003e88:	e04a                	sd	s2,0(sp)
    80003e8a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e8c:	0001d917          	auipc	s2,0x1d
    80003e90:	cb490913          	addi	s2,s2,-844 # 80020b40 <log>
    80003e94:	01892583          	lw	a1,24(s2)
    80003e98:	02892503          	lw	a0,40(s2)
    80003e9c:	fffff097          	auipc	ra,0xfffff
    80003ea0:	fe6080e7          	jalr	-26(ra) # 80002e82 <bread>
    80003ea4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ea6:	02c92683          	lw	a3,44(s2)
    80003eaa:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003eac:	02d05863          	blez	a3,80003edc <write_head+0x5c>
    80003eb0:	0001d797          	auipc	a5,0x1d
    80003eb4:	cc078793          	addi	a5,a5,-832 # 80020b70 <log+0x30>
    80003eb8:	05c50713          	addi	a4,a0,92
    80003ebc:	36fd                	addiw	a3,a3,-1
    80003ebe:	02069613          	slli	a2,a3,0x20
    80003ec2:	01e65693          	srli	a3,a2,0x1e
    80003ec6:	0001d617          	auipc	a2,0x1d
    80003eca:	cae60613          	addi	a2,a2,-850 # 80020b74 <log+0x34>
    80003ece:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003ed0:	4390                	lw	a2,0(a5)
    80003ed2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ed4:	0791                	addi	a5,a5,4
    80003ed6:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003ed8:	fed79ce3          	bne	a5,a3,80003ed0 <write_head+0x50>
  }
  bwrite(buf);
    80003edc:	8526                	mv	a0,s1
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	096080e7          	jalr	150(ra) # 80002f74 <bwrite>
  brelse(buf);
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	fffff097          	auipc	ra,0xfffff
    80003eec:	0ca080e7          	jalr	202(ra) # 80002fb2 <brelse>
}
    80003ef0:	60e2                	ld	ra,24(sp)
    80003ef2:	6442                	ld	s0,16(sp)
    80003ef4:	64a2                	ld	s1,8(sp)
    80003ef6:	6902                	ld	s2,0(sp)
    80003ef8:	6105                	addi	sp,sp,32
    80003efa:	8082                	ret

0000000080003efc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003efc:	0001d797          	auipc	a5,0x1d
    80003f00:	c707a783          	lw	a5,-912(a5) # 80020b6c <log+0x2c>
    80003f04:	0af05d63          	blez	a5,80003fbe <install_trans+0xc2>
{
    80003f08:	7139                	addi	sp,sp,-64
    80003f0a:	fc06                	sd	ra,56(sp)
    80003f0c:	f822                	sd	s0,48(sp)
    80003f0e:	f426                	sd	s1,40(sp)
    80003f10:	f04a                	sd	s2,32(sp)
    80003f12:	ec4e                	sd	s3,24(sp)
    80003f14:	e852                	sd	s4,16(sp)
    80003f16:	e456                	sd	s5,8(sp)
    80003f18:	e05a                	sd	s6,0(sp)
    80003f1a:	0080                	addi	s0,sp,64
    80003f1c:	8b2a                	mv	s6,a0
    80003f1e:	0001da97          	auipc	s5,0x1d
    80003f22:	c52a8a93          	addi	s5,s5,-942 # 80020b70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f26:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f28:	0001d997          	auipc	s3,0x1d
    80003f2c:	c1898993          	addi	s3,s3,-1000 # 80020b40 <log>
    80003f30:	a00d                	j	80003f52 <install_trans+0x56>
    brelse(lbuf);
    80003f32:	854a                	mv	a0,s2
    80003f34:	fffff097          	auipc	ra,0xfffff
    80003f38:	07e080e7          	jalr	126(ra) # 80002fb2 <brelse>
    brelse(dbuf);
    80003f3c:	8526                	mv	a0,s1
    80003f3e:	fffff097          	auipc	ra,0xfffff
    80003f42:	074080e7          	jalr	116(ra) # 80002fb2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f46:	2a05                	addiw	s4,s4,1
    80003f48:	0a91                	addi	s5,s5,4
    80003f4a:	02c9a783          	lw	a5,44(s3)
    80003f4e:	04fa5e63          	bge	s4,a5,80003faa <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f52:	0189a583          	lw	a1,24(s3)
    80003f56:	014585bb          	addw	a1,a1,s4
    80003f5a:	2585                	addiw	a1,a1,1
    80003f5c:	0289a503          	lw	a0,40(s3)
    80003f60:	fffff097          	auipc	ra,0xfffff
    80003f64:	f22080e7          	jalr	-222(ra) # 80002e82 <bread>
    80003f68:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f6a:	000aa583          	lw	a1,0(s5)
    80003f6e:	0289a503          	lw	a0,40(s3)
    80003f72:	fffff097          	auipc	ra,0xfffff
    80003f76:	f10080e7          	jalr	-240(ra) # 80002e82 <bread>
    80003f7a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f7c:	40000613          	li	a2,1024
    80003f80:	05890593          	addi	a1,s2,88
    80003f84:	05850513          	addi	a0,a0,88
    80003f88:	ffffd097          	auipc	ra,0xffffd
    80003f8c:	da6080e7          	jalr	-602(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f90:	8526                	mv	a0,s1
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	fe2080e7          	jalr	-30(ra) # 80002f74 <bwrite>
    if(recovering == 0)
    80003f9a:	f80b1ce3          	bnez	s6,80003f32 <install_trans+0x36>
      bunpin(dbuf);
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	fffff097          	auipc	ra,0xfffff
    80003fa4:	0ec080e7          	jalr	236(ra) # 8000308c <bunpin>
    80003fa8:	b769                	j	80003f32 <install_trans+0x36>
}
    80003faa:	70e2                	ld	ra,56(sp)
    80003fac:	7442                	ld	s0,48(sp)
    80003fae:	74a2                	ld	s1,40(sp)
    80003fb0:	7902                	ld	s2,32(sp)
    80003fb2:	69e2                	ld	s3,24(sp)
    80003fb4:	6a42                	ld	s4,16(sp)
    80003fb6:	6aa2                	ld	s5,8(sp)
    80003fb8:	6b02                	ld	s6,0(sp)
    80003fba:	6121                	addi	sp,sp,64
    80003fbc:	8082                	ret
    80003fbe:	8082                	ret

0000000080003fc0 <initlog>:
{
    80003fc0:	7179                	addi	sp,sp,-48
    80003fc2:	f406                	sd	ra,40(sp)
    80003fc4:	f022                	sd	s0,32(sp)
    80003fc6:	ec26                	sd	s1,24(sp)
    80003fc8:	e84a                	sd	s2,16(sp)
    80003fca:	e44e                	sd	s3,8(sp)
    80003fcc:	1800                	addi	s0,sp,48
    80003fce:	892a                	mv	s2,a0
    80003fd0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fd2:	0001d497          	auipc	s1,0x1d
    80003fd6:	b6e48493          	addi	s1,s1,-1170 # 80020b40 <log>
    80003fda:	00004597          	auipc	a1,0x4
    80003fde:	66658593          	addi	a1,a1,1638 # 80008640 <syscalls+0x1d8>
    80003fe2:	8526                	mv	a0,s1
    80003fe4:	ffffd097          	auipc	ra,0xffffd
    80003fe8:	b62080e7          	jalr	-1182(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80003fec:	0149a583          	lw	a1,20(s3)
    80003ff0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003ff2:	0109a783          	lw	a5,16(s3)
    80003ff6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ff8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ffc:	854a                	mv	a0,s2
    80003ffe:	fffff097          	auipc	ra,0xfffff
    80004002:	e84080e7          	jalr	-380(ra) # 80002e82 <bread>
  log.lh.n = lh->n;
    80004006:	4d34                	lw	a3,88(a0)
    80004008:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000400a:	02d05663          	blez	a3,80004036 <initlog+0x76>
    8000400e:	05c50793          	addi	a5,a0,92
    80004012:	0001d717          	auipc	a4,0x1d
    80004016:	b5e70713          	addi	a4,a4,-1186 # 80020b70 <log+0x30>
    8000401a:	36fd                	addiw	a3,a3,-1
    8000401c:	02069613          	slli	a2,a3,0x20
    80004020:	01e65693          	srli	a3,a2,0x1e
    80004024:	06050613          	addi	a2,a0,96
    80004028:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000402a:	4390                	lw	a2,0(a5)
    8000402c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000402e:	0791                	addi	a5,a5,4
    80004030:	0711                	addi	a4,a4,4
    80004032:	fed79ce3          	bne	a5,a3,8000402a <initlog+0x6a>
  brelse(buf);
    80004036:	fffff097          	auipc	ra,0xfffff
    8000403a:	f7c080e7          	jalr	-132(ra) # 80002fb2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000403e:	4505                	li	a0,1
    80004040:	00000097          	auipc	ra,0x0
    80004044:	ebc080e7          	jalr	-324(ra) # 80003efc <install_trans>
  log.lh.n = 0;
    80004048:	0001d797          	auipc	a5,0x1d
    8000404c:	b207a223          	sw	zero,-1244(a5) # 80020b6c <log+0x2c>
  write_head(); // clear the log
    80004050:	00000097          	auipc	ra,0x0
    80004054:	e30080e7          	jalr	-464(ra) # 80003e80 <write_head>
}
    80004058:	70a2                	ld	ra,40(sp)
    8000405a:	7402                	ld	s0,32(sp)
    8000405c:	64e2                	ld	s1,24(sp)
    8000405e:	6942                	ld	s2,16(sp)
    80004060:	69a2                	ld	s3,8(sp)
    80004062:	6145                	addi	sp,sp,48
    80004064:	8082                	ret

0000000080004066 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004066:	1101                	addi	sp,sp,-32
    80004068:	ec06                	sd	ra,24(sp)
    8000406a:	e822                	sd	s0,16(sp)
    8000406c:	e426                	sd	s1,8(sp)
    8000406e:	e04a                	sd	s2,0(sp)
    80004070:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004072:	0001d517          	auipc	a0,0x1d
    80004076:	ace50513          	addi	a0,a0,-1330 # 80020b40 <log>
    8000407a:	ffffd097          	auipc	ra,0xffffd
    8000407e:	b5c080e7          	jalr	-1188(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004082:	0001d497          	auipc	s1,0x1d
    80004086:	abe48493          	addi	s1,s1,-1346 # 80020b40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000408a:	4979                	li	s2,30
    8000408c:	a039                	j	8000409a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000408e:	85a6                	mv	a1,s1
    80004090:	8526                	mv	a0,s1
    80004092:	ffffe097          	auipc	ra,0xffffe
    80004096:	fc2080e7          	jalr	-62(ra) # 80002054 <sleep>
    if(log.committing){
    8000409a:	50dc                	lw	a5,36(s1)
    8000409c:	fbed                	bnez	a5,8000408e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000409e:	5098                	lw	a4,32(s1)
    800040a0:	2705                	addiw	a4,a4,1
    800040a2:	0007069b          	sext.w	a3,a4
    800040a6:	0027179b          	slliw	a5,a4,0x2
    800040aa:	9fb9                	addw	a5,a5,a4
    800040ac:	0017979b          	slliw	a5,a5,0x1
    800040b0:	54d8                	lw	a4,44(s1)
    800040b2:	9fb9                	addw	a5,a5,a4
    800040b4:	00f95963          	bge	s2,a5,800040c6 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040b8:	85a6                	mv	a1,s1
    800040ba:	8526                	mv	a0,s1
    800040bc:	ffffe097          	auipc	ra,0xffffe
    800040c0:	f98080e7          	jalr	-104(ra) # 80002054 <sleep>
    800040c4:	bfd9                	j	8000409a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040c6:	0001d517          	auipc	a0,0x1d
    800040ca:	a7a50513          	addi	a0,a0,-1414 # 80020b40 <log>
    800040ce:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800040d0:	ffffd097          	auipc	ra,0xffffd
    800040d4:	bba080e7          	jalr	-1094(ra) # 80000c8a <release>
      break;
    }
  }
}
    800040d8:	60e2                	ld	ra,24(sp)
    800040da:	6442                	ld	s0,16(sp)
    800040dc:	64a2                	ld	s1,8(sp)
    800040de:	6902                	ld	s2,0(sp)
    800040e0:	6105                	addi	sp,sp,32
    800040e2:	8082                	ret

00000000800040e4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040e4:	7139                	addi	sp,sp,-64
    800040e6:	fc06                	sd	ra,56(sp)
    800040e8:	f822                	sd	s0,48(sp)
    800040ea:	f426                	sd	s1,40(sp)
    800040ec:	f04a                	sd	s2,32(sp)
    800040ee:	ec4e                	sd	s3,24(sp)
    800040f0:	e852                	sd	s4,16(sp)
    800040f2:	e456                	sd	s5,8(sp)
    800040f4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040f6:	0001d497          	auipc	s1,0x1d
    800040fa:	a4a48493          	addi	s1,s1,-1462 # 80020b40 <log>
    800040fe:	8526                	mv	a0,s1
    80004100:	ffffd097          	auipc	ra,0xffffd
    80004104:	ad6080e7          	jalr	-1322(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004108:	509c                	lw	a5,32(s1)
    8000410a:	37fd                	addiw	a5,a5,-1
    8000410c:	0007891b          	sext.w	s2,a5
    80004110:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004112:	50dc                	lw	a5,36(s1)
    80004114:	e7b9                	bnez	a5,80004162 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004116:	04091e63          	bnez	s2,80004172 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000411a:	0001d497          	auipc	s1,0x1d
    8000411e:	a2648493          	addi	s1,s1,-1498 # 80020b40 <log>
    80004122:	4785                	li	a5,1
    80004124:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004126:	8526                	mv	a0,s1
    80004128:	ffffd097          	auipc	ra,0xffffd
    8000412c:	b62080e7          	jalr	-1182(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004130:	54dc                	lw	a5,44(s1)
    80004132:	06f04763          	bgtz	a5,800041a0 <end_op+0xbc>
    acquire(&log.lock);
    80004136:	0001d497          	auipc	s1,0x1d
    8000413a:	a0a48493          	addi	s1,s1,-1526 # 80020b40 <log>
    8000413e:	8526                	mv	a0,s1
    80004140:	ffffd097          	auipc	ra,0xffffd
    80004144:	a96080e7          	jalr	-1386(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004148:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000414c:	8526                	mv	a0,s1
    8000414e:	ffffe097          	auipc	ra,0xffffe
    80004152:	f6a080e7          	jalr	-150(ra) # 800020b8 <wakeup>
    release(&log.lock);
    80004156:	8526                	mv	a0,s1
    80004158:	ffffd097          	auipc	ra,0xffffd
    8000415c:	b32080e7          	jalr	-1230(ra) # 80000c8a <release>
}
    80004160:	a03d                	j	8000418e <end_op+0xaa>
    panic("log.committing");
    80004162:	00004517          	auipc	a0,0x4
    80004166:	4e650513          	addi	a0,a0,1254 # 80008648 <syscalls+0x1e0>
    8000416a:	ffffc097          	auipc	ra,0xffffc
    8000416e:	3d6080e7          	jalr	982(ra) # 80000540 <panic>
    wakeup(&log);
    80004172:	0001d497          	auipc	s1,0x1d
    80004176:	9ce48493          	addi	s1,s1,-1586 # 80020b40 <log>
    8000417a:	8526                	mv	a0,s1
    8000417c:	ffffe097          	auipc	ra,0xffffe
    80004180:	f3c080e7          	jalr	-196(ra) # 800020b8 <wakeup>
  release(&log.lock);
    80004184:	8526                	mv	a0,s1
    80004186:	ffffd097          	auipc	ra,0xffffd
    8000418a:	b04080e7          	jalr	-1276(ra) # 80000c8a <release>
}
    8000418e:	70e2                	ld	ra,56(sp)
    80004190:	7442                	ld	s0,48(sp)
    80004192:	74a2                	ld	s1,40(sp)
    80004194:	7902                	ld	s2,32(sp)
    80004196:	69e2                	ld	s3,24(sp)
    80004198:	6a42                	ld	s4,16(sp)
    8000419a:	6aa2                	ld	s5,8(sp)
    8000419c:	6121                	addi	sp,sp,64
    8000419e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a0:	0001da97          	auipc	s5,0x1d
    800041a4:	9d0a8a93          	addi	s5,s5,-1584 # 80020b70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041a8:	0001da17          	auipc	s4,0x1d
    800041ac:	998a0a13          	addi	s4,s4,-1640 # 80020b40 <log>
    800041b0:	018a2583          	lw	a1,24(s4)
    800041b4:	012585bb          	addw	a1,a1,s2
    800041b8:	2585                	addiw	a1,a1,1
    800041ba:	028a2503          	lw	a0,40(s4)
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	cc4080e7          	jalr	-828(ra) # 80002e82 <bread>
    800041c6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041c8:	000aa583          	lw	a1,0(s5)
    800041cc:	028a2503          	lw	a0,40(s4)
    800041d0:	fffff097          	auipc	ra,0xfffff
    800041d4:	cb2080e7          	jalr	-846(ra) # 80002e82 <bread>
    800041d8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041da:	40000613          	li	a2,1024
    800041de:	05850593          	addi	a1,a0,88
    800041e2:	05848513          	addi	a0,s1,88
    800041e6:	ffffd097          	auipc	ra,0xffffd
    800041ea:	b48080e7          	jalr	-1208(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800041ee:	8526                	mv	a0,s1
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	d84080e7          	jalr	-636(ra) # 80002f74 <bwrite>
    brelse(from);
    800041f8:	854e                	mv	a0,s3
    800041fa:	fffff097          	auipc	ra,0xfffff
    800041fe:	db8080e7          	jalr	-584(ra) # 80002fb2 <brelse>
    brelse(to);
    80004202:	8526                	mv	a0,s1
    80004204:	fffff097          	auipc	ra,0xfffff
    80004208:	dae080e7          	jalr	-594(ra) # 80002fb2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000420c:	2905                	addiw	s2,s2,1
    8000420e:	0a91                	addi	s5,s5,4
    80004210:	02ca2783          	lw	a5,44(s4)
    80004214:	f8f94ee3          	blt	s2,a5,800041b0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004218:	00000097          	auipc	ra,0x0
    8000421c:	c68080e7          	jalr	-920(ra) # 80003e80 <write_head>
    install_trans(0); // Now install writes to home locations
    80004220:	4501                	li	a0,0
    80004222:	00000097          	auipc	ra,0x0
    80004226:	cda080e7          	jalr	-806(ra) # 80003efc <install_trans>
    log.lh.n = 0;
    8000422a:	0001d797          	auipc	a5,0x1d
    8000422e:	9407a123          	sw	zero,-1726(a5) # 80020b6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004232:	00000097          	auipc	ra,0x0
    80004236:	c4e080e7          	jalr	-946(ra) # 80003e80 <write_head>
    8000423a:	bdf5                	j	80004136 <end_op+0x52>

000000008000423c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000423c:	1101                	addi	sp,sp,-32
    8000423e:	ec06                	sd	ra,24(sp)
    80004240:	e822                	sd	s0,16(sp)
    80004242:	e426                	sd	s1,8(sp)
    80004244:	e04a                	sd	s2,0(sp)
    80004246:	1000                	addi	s0,sp,32
    80004248:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000424a:	0001d917          	auipc	s2,0x1d
    8000424e:	8f690913          	addi	s2,s2,-1802 # 80020b40 <log>
    80004252:	854a                	mv	a0,s2
    80004254:	ffffd097          	auipc	ra,0xffffd
    80004258:	982080e7          	jalr	-1662(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000425c:	02c92603          	lw	a2,44(s2)
    80004260:	47f5                	li	a5,29
    80004262:	06c7c563          	blt	a5,a2,800042cc <log_write+0x90>
    80004266:	0001d797          	auipc	a5,0x1d
    8000426a:	8f67a783          	lw	a5,-1802(a5) # 80020b5c <log+0x1c>
    8000426e:	37fd                	addiw	a5,a5,-1
    80004270:	04f65e63          	bge	a2,a5,800042cc <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004274:	0001d797          	auipc	a5,0x1d
    80004278:	8ec7a783          	lw	a5,-1812(a5) # 80020b60 <log+0x20>
    8000427c:	06f05063          	blez	a5,800042dc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004280:	4781                	li	a5,0
    80004282:	06c05563          	blez	a2,800042ec <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004286:	44cc                	lw	a1,12(s1)
    80004288:	0001d717          	auipc	a4,0x1d
    8000428c:	8e870713          	addi	a4,a4,-1816 # 80020b70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004290:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004292:	4314                	lw	a3,0(a4)
    80004294:	04b68c63          	beq	a3,a1,800042ec <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004298:	2785                	addiw	a5,a5,1
    8000429a:	0711                	addi	a4,a4,4
    8000429c:	fef61be3          	bne	a2,a5,80004292 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042a0:	0621                	addi	a2,a2,8
    800042a2:	060a                	slli	a2,a2,0x2
    800042a4:	0001d797          	auipc	a5,0x1d
    800042a8:	89c78793          	addi	a5,a5,-1892 # 80020b40 <log>
    800042ac:	97b2                	add	a5,a5,a2
    800042ae:	44d8                	lw	a4,12(s1)
    800042b0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042b2:	8526                	mv	a0,s1
    800042b4:	fffff097          	auipc	ra,0xfffff
    800042b8:	d9c080e7          	jalr	-612(ra) # 80003050 <bpin>
    log.lh.n++;
    800042bc:	0001d717          	auipc	a4,0x1d
    800042c0:	88470713          	addi	a4,a4,-1916 # 80020b40 <log>
    800042c4:	575c                	lw	a5,44(a4)
    800042c6:	2785                	addiw	a5,a5,1
    800042c8:	d75c                	sw	a5,44(a4)
    800042ca:	a82d                	j	80004304 <log_write+0xc8>
    panic("too big a transaction");
    800042cc:	00004517          	auipc	a0,0x4
    800042d0:	38c50513          	addi	a0,a0,908 # 80008658 <syscalls+0x1f0>
    800042d4:	ffffc097          	auipc	ra,0xffffc
    800042d8:	26c080e7          	jalr	620(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    800042dc:	00004517          	auipc	a0,0x4
    800042e0:	39450513          	addi	a0,a0,916 # 80008670 <syscalls+0x208>
    800042e4:	ffffc097          	auipc	ra,0xffffc
    800042e8:	25c080e7          	jalr	604(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    800042ec:	00878693          	addi	a3,a5,8
    800042f0:	068a                	slli	a3,a3,0x2
    800042f2:	0001d717          	auipc	a4,0x1d
    800042f6:	84e70713          	addi	a4,a4,-1970 # 80020b40 <log>
    800042fa:	9736                	add	a4,a4,a3
    800042fc:	44d4                	lw	a3,12(s1)
    800042fe:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004300:	faf609e3          	beq	a2,a5,800042b2 <log_write+0x76>
  }
  release(&log.lock);
    80004304:	0001d517          	auipc	a0,0x1d
    80004308:	83c50513          	addi	a0,a0,-1988 # 80020b40 <log>
    8000430c:	ffffd097          	auipc	ra,0xffffd
    80004310:	97e080e7          	jalr	-1666(ra) # 80000c8a <release>
}
    80004314:	60e2                	ld	ra,24(sp)
    80004316:	6442                	ld	s0,16(sp)
    80004318:	64a2                	ld	s1,8(sp)
    8000431a:	6902                	ld	s2,0(sp)
    8000431c:	6105                	addi	sp,sp,32
    8000431e:	8082                	ret

0000000080004320 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004320:	1101                	addi	sp,sp,-32
    80004322:	ec06                	sd	ra,24(sp)
    80004324:	e822                	sd	s0,16(sp)
    80004326:	e426                	sd	s1,8(sp)
    80004328:	e04a                	sd	s2,0(sp)
    8000432a:	1000                	addi	s0,sp,32
    8000432c:	84aa                	mv	s1,a0
    8000432e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004330:	00004597          	auipc	a1,0x4
    80004334:	36058593          	addi	a1,a1,864 # 80008690 <syscalls+0x228>
    80004338:	0521                	addi	a0,a0,8
    8000433a:	ffffd097          	auipc	ra,0xffffd
    8000433e:	80c080e7          	jalr	-2036(ra) # 80000b46 <initlock>
  lk->name = name;
    80004342:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004346:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000434a:	0204a423          	sw	zero,40(s1)
}
    8000434e:	60e2                	ld	ra,24(sp)
    80004350:	6442                	ld	s0,16(sp)
    80004352:	64a2                	ld	s1,8(sp)
    80004354:	6902                	ld	s2,0(sp)
    80004356:	6105                	addi	sp,sp,32
    80004358:	8082                	ret

000000008000435a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000435a:	1101                	addi	sp,sp,-32
    8000435c:	ec06                	sd	ra,24(sp)
    8000435e:	e822                	sd	s0,16(sp)
    80004360:	e426                	sd	s1,8(sp)
    80004362:	e04a                	sd	s2,0(sp)
    80004364:	1000                	addi	s0,sp,32
    80004366:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004368:	00850913          	addi	s2,a0,8
    8000436c:	854a                	mv	a0,s2
    8000436e:	ffffd097          	auipc	ra,0xffffd
    80004372:	868080e7          	jalr	-1944(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004376:	409c                	lw	a5,0(s1)
    80004378:	cb89                	beqz	a5,8000438a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000437a:	85ca                	mv	a1,s2
    8000437c:	8526                	mv	a0,s1
    8000437e:	ffffe097          	auipc	ra,0xffffe
    80004382:	cd6080e7          	jalr	-810(ra) # 80002054 <sleep>
  while (lk->locked) {
    80004386:	409c                	lw	a5,0(s1)
    80004388:	fbed                	bnez	a5,8000437a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000438a:	4785                	li	a5,1
    8000438c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000438e:	ffffd097          	auipc	ra,0xffffd
    80004392:	61e080e7          	jalr	1566(ra) # 800019ac <myproc>
    80004396:	591c                	lw	a5,48(a0)
    80004398:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000439a:	854a                	mv	a0,s2
    8000439c:	ffffd097          	auipc	ra,0xffffd
    800043a0:	8ee080e7          	jalr	-1810(ra) # 80000c8a <release>
}
    800043a4:	60e2                	ld	ra,24(sp)
    800043a6:	6442                	ld	s0,16(sp)
    800043a8:	64a2                	ld	s1,8(sp)
    800043aa:	6902                	ld	s2,0(sp)
    800043ac:	6105                	addi	sp,sp,32
    800043ae:	8082                	ret

00000000800043b0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043b0:	1101                	addi	sp,sp,-32
    800043b2:	ec06                	sd	ra,24(sp)
    800043b4:	e822                	sd	s0,16(sp)
    800043b6:	e426                	sd	s1,8(sp)
    800043b8:	e04a                	sd	s2,0(sp)
    800043ba:	1000                	addi	s0,sp,32
    800043bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043be:	00850913          	addi	s2,a0,8
    800043c2:	854a                	mv	a0,s2
    800043c4:	ffffd097          	auipc	ra,0xffffd
    800043c8:	812080e7          	jalr	-2030(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800043cc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043d0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043d4:	8526                	mv	a0,s1
    800043d6:	ffffe097          	auipc	ra,0xffffe
    800043da:	ce2080e7          	jalr	-798(ra) # 800020b8 <wakeup>
  release(&lk->lk);
    800043de:	854a                	mv	a0,s2
    800043e0:	ffffd097          	auipc	ra,0xffffd
    800043e4:	8aa080e7          	jalr	-1878(ra) # 80000c8a <release>
}
    800043e8:	60e2                	ld	ra,24(sp)
    800043ea:	6442                	ld	s0,16(sp)
    800043ec:	64a2                	ld	s1,8(sp)
    800043ee:	6902                	ld	s2,0(sp)
    800043f0:	6105                	addi	sp,sp,32
    800043f2:	8082                	ret

00000000800043f4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043f4:	7179                	addi	sp,sp,-48
    800043f6:	f406                	sd	ra,40(sp)
    800043f8:	f022                	sd	s0,32(sp)
    800043fa:	ec26                	sd	s1,24(sp)
    800043fc:	e84a                	sd	s2,16(sp)
    800043fe:	e44e                	sd	s3,8(sp)
    80004400:	1800                	addi	s0,sp,48
    80004402:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004404:	00850913          	addi	s2,a0,8
    80004408:	854a                	mv	a0,s2
    8000440a:	ffffc097          	auipc	ra,0xffffc
    8000440e:	7cc080e7          	jalr	1996(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004412:	409c                	lw	a5,0(s1)
    80004414:	ef99                	bnez	a5,80004432 <holdingsleep+0x3e>
    80004416:	4481                	li	s1,0
  release(&lk->lk);
    80004418:	854a                	mv	a0,s2
    8000441a:	ffffd097          	auipc	ra,0xffffd
    8000441e:	870080e7          	jalr	-1936(ra) # 80000c8a <release>
  return r;
}
    80004422:	8526                	mv	a0,s1
    80004424:	70a2                	ld	ra,40(sp)
    80004426:	7402                	ld	s0,32(sp)
    80004428:	64e2                	ld	s1,24(sp)
    8000442a:	6942                	ld	s2,16(sp)
    8000442c:	69a2                	ld	s3,8(sp)
    8000442e:	6145                	addi	sp,sp,48
    80004430:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004432:	0284a983          	lw	s3,40(s1)
    80004436:	ffffd097          	auipc	ra,0xffffd
    8000443a:	576080e7          	jalr	1398(ra) # 800019ac <myproc>
    8000443e:	5904                	lw	s1,48(a0)
    80004440:	413484b3          	sub	s1,s1,s3
    80004444:	0014b493          	seqz	s1,s1
    80004448:	bfc1                	j	80004418 <holdingsleep+0x24>

000000008000444a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000444a:	1141                	addi	sp,sp,-16
    8000444c:	e406                	sd	ra,8(sp)
    8000444e:	e022                	sd	s0,0(sp)
    80004450:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004452:	00004597          	auipc	a1,0x4
    80004456:	24e58593          	addi	a1,a1,590 # 800086a0 <syscalls+0x238>
    8000445a:	0001d517          	auipc	a0,0x1d
    8000445e:	82e50513          	addi	a0,a0,-2002 # 80020c88 <ftable>
    80004462:	ffffc097          	auipc	ra,0xffffc
    80004466:	6e4080e7          	jalr	1764(ra) # 80000b46 <initlock>
}
    8000446a:	60a2                	ld	ra,8(sp)
    8000446c:	6402                	ld	s0,0(sp)
    8000446e:	0141                	addi	sp,sp,16
    80004470:	8082                	ret

0000000080004472 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004472:	1101                	addi	sp,sp,-32
    80004474:	ec06                	sd	ra,24(sp)
    80004476:	e822                	sd	s0,16(sp)
    80004478:	e426                	sd	s1,8(sp)
    8000447a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000447c:	0001d517          	auipc	a0,0x1d
    80004480:	80c50513          	addi	a0,a0,-2036 # 80020c88 <ftable>
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	752080e7          	jalr	1874(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000448c:	0001d497          	auipc	s1,0x1d
    80004490:	81448493          	addi	s1,s1,-2028 # 80020ca0 <ftable+0x18>
    80004494:	0001d717          	auipc	a4,0x1d
    80004498:	7ac70713          	addi	a4,a4,1964 # 80021c40 <disk>
    if(f->ref == 0){
    8000449c:	40dc                	lw	a5,4(s1)
    8000449e:	cf99                	beqz	a5,800044bc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044a0:	02848493          	addi	s1,s1,40
    800044a4:	fee49ce3          	bne	s1,a4,8000449c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044a8:	0001c517          	auipc	a0,0x1c
    800044ac:	7e050513          	addi	a0,a0,2016 # 80020c88 <ftable>
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	7da080e7          	jalr	2010(ra) # 80000c8a <release>
  return 0;
    800044b8:	4481                	li	s1,0
    800044ba:	a819                	j	800044d0 <filealloc+0x5e>
      f->ref = 1;
    800044bc:	4785                	li	a5,1
    800044be:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044c0:	0001c517          	auipc	a0,0x1c
    800044c4:	7c850513          	addi	a0,a0,1992 # 80020c88 <ftable>
    800044c8:	ffffc097          	auipc	ra,0xffffc
    800044cc:	7c2080e7          	jalr	1986(ra) # 80000c8a <release>
}
    800044d0:	8526                	mv	a0,s1
    800044d2:	60e2                	ld	ra,24(sp)
    800044d4:	6442                	ld	s0,16(sp)
    800044d6:	64a2                	ld	s1,8(sp)
    800044d8:	6105                	addi	sp,sp,32
    800044da:	8082                	ret

00000000800044dc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044dc:	1101                	addi	sp,sp,-32
    800044de:	ec06                	sd	ra,24(sp)
    800044e0:	e822                	sd	s0,16(sp)
    800044e2:	e426                	sd	s1,8(sp)
    800044e4:	1000                	addi	s0,sp,32
    800044e6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044e8:	0001c517          	auipc	a0,0x1c
    800044ec:	7a050513          	addi	a0,a0,1952 # 80020c88 <ftable>
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	6e6080e7          	jalr	1766(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800044f8:	40dc                	lw	a5,4(s1)
    800044fa:	02f05263          	blez	a5,8000451e <filedup+0x42>
    panic("filedup");
  f->ref++;
    800044fe:	2785                	addiw	a5,a5,1
    80004500:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004502:	0001c517          	auipc	a0,0x1c
    80004506:	78650513          	addi	a0,a0,1926 # 80020c88 <ftable>
    8000450a:	ffffc097          	auipc	ra,0xffffc
    8000450e:	780080e7          	jalr	1920(ra) # 80000c8a <release>
  return f;
}
    80004512:	8526                	mv	a0,s1
    80004514:	60e2                	ld	ra,24(sp)
    80004516:	6442                	ld	s0,16(sp)
    80004518:	64a2                	ld	s1,8(sp)
    8000451a:	6105                	addi	sp,sp,32
    8000451c:	8082                	ret
    panic("filedup");
    8000451e:	00004517          	auipc	a0,0x4
    80004522:	18a50513          	addi	a0,a0,394 # 800086a8 <syscalls+0x240>
    80004526:	ffffc097          	auipc	ra,0xffffc
    8000452a:	01a080e7          	jalr	26(ra) # 80000540 <panic>

000000008000452e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000452e:	7139                	addi	sp,sp,-64
    80004530:	fc06                	sd	ra,56(sp)
    80004532:	f822                	sd	s0,48(sp)
    80004534:	f426                	sd	s1,40(sp)
    80004536:	f04a                	sd	s2,32(sp)
    80004538:	ec4e                	sd	s3,24(sp)
    8000453a:	e852                	sd	s4,16(sp)
    8000453c:	e456                	sd	s5,8(sp)
    8000453e:	0080                	addi	s0,sp,64
    80004540:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004542:	0001c517          	auipc	a0,0x1c
    80004546:	74650513          	addi	a0,a0,1862 # 80020c88 <ftable>
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	68c080e7          	jalr	1676(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004552:	40dc                	lw	a5,4(s1)
    80004554:	06f05163          	blez	a5,800045b6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004558:	37fd                	addiw	a5,a5,-1
    8000455a:	0007871b          	sext.w	a4,a5
    8000455e:	c0dc                	sw	a5,4(s1)
    80004560:	06e04363          	bgtz	a4,800045c6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004564:	0004a903          	lw	s2,0(s1)
    80004568:	0094ca83          	lbu	s5,9(s1)
    8000456c:	0104ba03          	ld	s4,16(s1)
    80004570:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004574:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004578:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000457c:	0001c517          	auipc	a0,0x1c
    80004580:	70c50513          	addi	a0,a0,1804 # 80020c88 <ftable>
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	706080e7          	jalr	1798(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    8000458c:	4785                	li	a5,1
    8000458e:	04f90d63          	beq	s2,a5,800045e8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004592:	3979                	addiw	s2,s2,-2
    80004594:	4785                	li	a5,1
    80004596:	0527e063          	bltu	a5,s2,800045d6 <fileclose+0xa8>
    begin_op();
    8000459a:	00000097          	auipc	ra,0x0
    8000459e:	acc080e7          	jalr	-1332(ra) # 80004066 <begin_op>
    iput(ff.ip);
    800045a2:	854e                	mv	a0,s3
    800045a4:	fffff097          	auipc	ra,0xfffff
    800045a8:	2b0080e7          	jalr	688(ra) # 80003854 <iput>
    end_op();
    800045ac:	00000097          	auipc	ra,0x0
    800045b0:	b38080e7          	jalr	-1224(ra) # 800040e4 <end_op>
    800045b4:	a00d                	j	800045d6 <fileclose+0xa8>
    panic("fileclose");
    800045b6:	00004517          	auipc	a0,0x4
    800045ba:	0fa50513          	addi	a0,a0,250 # 800086b0 <syscalls+0x248>
    800045be:	ffffc097          	auipc	ra,0xffffc
    800045c2:	f82080e7          	jalr	-126(ra) # 80000540 <panic>
    release(&ftable.lock);
    800045c6:	0001c517          	auipc	a0,0x1c
    800045ca:	6c250513          	addi	a0,a0,1730 # 80020c88 <ftable>
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	6bc080e7          	jalr	1724(ra) # 80000c8a <release>
  }
}
    800045d6:	70e2                	ld	ra,56(sp)
    800045d8:	7442                	ld	s0,48(sp)
    800045da:	74a2                	ld	s1,40(sp)
    800045dc:	7902                	ld	s2,32(sp)
    800045de:	69e2                	ld	s3,24(sp)
    800045e0:	6a42                	ld	s4,16(sp)
    800045e2:	6aa2                	ld	s5,8(sp)
    800045e4:	6121                	addi	sp,sp,64
    800045e6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045e8:	85d6                	mv	a1,s5
    800045ea:	8552                	mv	a0,s4
    800045ec:	00000097          	auipc	ra,0x0
    800045f0:	34c080e7          	jalr	844(ra) # 80004938 <pipeclose>
    800045f4:	b7cd                	j	800045d6 <fileclose+0xa8>

00000000800045f6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045f6:	715d                	addi	sp,sp,-80
    800045f8:	e486                	sd	ra,72(sp)
    800045fa:	e0a2                	sd	s0,64(sp)
    800045fc:	fc26                	sd	s1,56(sp)
    800045fe:	f84a                	sd	s2,48(sp)
    80004600:	f44e                	sd	s3,40(sp)
    80004602:	0880                	addi	s0,sp,80
    80004604:	84aa                	mv	s1,a0
    80004606:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004608:	ffffd097          	auipc	ra,0xffffd
    8000460c:	3a4080e7          	jalr	932(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004610:	409c                	lw	a5,0(s1)
    80004612:	37f9                	addiw	a5,a5,-2
    80004614:	4705                	li	a4,1
    80004616:	04f76763          	bltu	a4,a5,80004664 <filestat+0x6e>
    8000461a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000461c:	6c88                	ld	a0,24(s1)
    8000461e:	fffff097          	auipc	ra,0xfffff
    80004622:	07c080e7          	jalr	124(ra) # 8000369a <ilock>
    stati(f->ip, &st);
    80004626:	fb840593          	addi	a1,s0,-72
    8000462a:	6c88                	ld	a0,24(s1)
    8000462c:	fffff097          	auipc	ra,0xfffff
    80004630:	2f8080e7          	jalr	760(ra) # 80003924 <stati>
    iunlock(f->ip);
    80004634:	6c88                	ld	a0,24(s1)
    80004636:	fffff097          	auipc	ra,0xfffff
    8000463a:	126080e7          	jalr	294(ra) # 8000375c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000463e:	46e1                	li	a3,24
    80004640:	fb840613          	addi	a2,s0,-72
    80004644:	85ce                	mv	a1,s3
    80004646:	05093503          	ld	a0,80(s2)
    8000464a:	ffffd097          	auipc	ra,0xffffd
    8000464e:	022080e7          	jalr	34(ra) # 8000166c <copyout>
    80004652:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004656:	60a6                	ld	ra,72(sp)
    80004658:	6406                	ld	s0,64(sp)
    8000465a:	74e2                	ld	s1,56(sp)
    8000465c:	7942                	ld	s2,48(sp)
    8000465e:	79a2                	ld	s3,40(sp)
    80004660:	6161                	addi	sp,sp,80
    80004662:	8082                	ret
  return -1;
    80004664:	557d                	li	a0,-1
    80004666:	bfc5                	j	80004656 <filestat+0x60>

0000000080004668 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004668:	7179                	addi	sp,sp,-48
    8000466a:	f406                	sd	ra,40(sp)
    8000466c:	f022                	sd	s0,32(sp)
    8000466e:	ec26                	sd	s1,24(sp)
    80004670:	e84a                	sd	s2,16(sp)
    80004672:	e44e                	sd	s3,8(sp)
    80004674:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004676:	00854783          	lbu	a5,8(a0)
    8000467a:	c3d5                	beqz	a5,8000471e <fileread+0xb6>
    8000467c:	84aa                	mv	s1,a0
    8000467e:	89ae                	mv	s3,a1
    80004680:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004682:	411c                	lw	a5,0(a0)
    80004684:	4705                	li	a4,1
    80004686:	04e78963          	beq	a5,a4,800046d8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000468a:	470d                	li	a4,3
    8000468c:	04e78d63          	beq	a5,a4,800046e6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004690:	4709                	li	a4,2
    80004692:	06e79e63          	bne	a5,a4,8000470e <fileread+0xa6>
    ilock(f->ip);
    80004696:	6d08                	ld	a0,24(a0)
    80004698:	fffff097          	auipc	ra,0xfffff
    8000469c:	002080e7          	jalr	2(ra) # 8000369a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046a0:	874a                	mv	a4,s2
    800046a2:	5094                	lw	a3,32(s1)
    800046a4:	864e                	mv	a2,s3
    800046a6:	4585                	li	a1,1
    800046a8:	6c88                	ld	a0,24(s1)
    800046aa:	fffff097          	auipc	ra,0xfffff
    800046ae:	2a4080e7          	jalr	676(ra) # 8000394e <readi>
    800046b2:	892a                	mv	s2,a0
    800046b4:	00a05563          	blez	a0,800046be <fileread+0x56>
      f->off += r;
    800046b8:	509c                	lw	a5,32(s1)
    800046ba:	9fa9                	addw	a5,a5,a0
    800046bc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046be:	6c88                	ld	a0,24(s1)
    800046c0:	fffff097          	auipc	ra,0xfffff
    800046c4:	09c080e7          	jalr	156(ra) # 8000375c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046c8:	854a                	mv	a0,s2
    800046ca:	70a2                	ld	ra,40(sp)
    800046cc:	7402                	ld	s0,32(sp)
    800046ce:	64e2                	ld	s1,24(sp)
    800046d0:	6942                	ld	s2,16(sp)
    800046d2:	69a2                	ld	s3,8(sp)
    800046d4:	6145                	addi	sp,sp,48
    800046d6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046d8:	6908                	ld	a0,16(a0)
    800046da:	00000097          	auipc	ra,0x0
    800046de:	3c6080e7          	jalr	966(ra) # 80004aa0 <piperead>
    800046e2:	892a                	mv	s2,a0
    800046e4:	b7d5                	j	800046c8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046e6:	02451783          	lh	a5,36(a0)
    800046ea:	03079693          	slli	a3,a5,0x30
    800046ee:	92c1                	srli	a3,a3,0x30
    800046f0:	4725                	li	a4,9
    800046f2:	02d76863          	bltu	a4,a3,80004722 <fileread+0xba>
    800046f6:	0792                	slli	a5,a5,0x4
    800046f8:	0001c717          	auipc	a4,0x1c
    800046fc:	4f070713          	addi	a4,a4,1264 # 80020be8 <devsw>
    80004700:	97ba                	add	a5,a5,a4
    80004702:	639c                	ld	a5,0(a5)
    80004704:	c38d                	beqz	a5,80004726 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004706:	4505                	li	a0,1
    80004708:	9782                	jalr	a5
    8000470a:	892a                	mv	s2,a0
    8000470c:	bf75                	j	800046c8 <fileread+0x60>
    panic("fileread");
    8000470e:	00004517          	auipc	a0,0x4
    80004712:	fb250513          	addi	a0,a0,-78 # 800086c0 <syscalls+0x258>
    80004716:	ffffc097          	auipc	ra,0xffffc
    8000471a:	e2a080e7          	jalr	-470(ra) # 80000540 <panic>
    return -1;
    8000471e:	597d                	li	s2,-1
    80004720:	b765                	j	800046c8 <fileread+0x60>
      return -1;
    80004722:	597d                	li	s2,-1
    80004724:	b755                	j	800046c8 <fileread+0x60>
    80004726:	597d                	li	s2,-1
    80004728:	b745                	j	800046c8 <fileread+0x60>

000000008000472a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000472a:	715d                	addi	sp,sp,-80
    8000472c:	e486                	sd	ra,72(sp)
    8000472e:	e0a2                	sd	s0,64(sp)
    80004730:	fc26                	sd	s1,56(sp)
    80004732:	f84a                	sd	s2,48(sp)
    80004734:	f44e                	sd	s3,40(sp)
    80004736:	f052                	sd	s4,32(sp)
    80004738:	ec56                	sd	s5,24(sp)
    8000473a:	e85a                	sd	s6,16(sp)
    8000473c:	e45e                	sd	s7,8(sp)
    8000473e:	e062                	sd	s8,0(sp)
    80004740:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004742:	00954783          	lbu	a5,9(a0)
    80004746:	10078663          	beqz	a5,80004852 <filewrite+0x128>
    8000474a:	892a                	mv	s2,a0
    8000474c:	8b2e                	mv	s6,a1
    8000474e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004750:	411c                	lw	a5,0(a0)
    80004752:	4705                	li	a4,1
    80004754:	02e78263          	beq	a5,a4,80004778 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004758:	470d                	li	a4,3
    8000475a:	02e78663          	beq	a5,a4,80004786 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000475e:	4709                	li	a4,2
    80004760:	0ee79163          	bne	a5,a4,80004842 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004764:	0ac05d63          	blez	a2,8000481e <filewrite+0xf4>
    int i = 0;
    80004768:	4981                	li	s3,0
    8000476a:	6b85                	lui	s7,0x1
    8000476c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004770:	6c05                	lui	s8,0x1
    80004772:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004776:	a861                	j	8000480e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004778:	6908                	ld	a0,16(a0)
    8000477a:	00000097          	auipc	ra,0x0
    8000477e:	22e080e7          	jalr	558(ra) # 800049a8 <pipewrite>
    80004782:	8a2a                	mv	s4,a0
    80004784:	a045                	j	80004824 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004786:	02451783          	lh	a5,36(a0)
    8000478a:	03079693          	slli	a3,a5,0x30
    8000478e:	92c1                	srli	a3,a3,0x30
    80004790:	4725                	li	a4,9
    80004792:	0cd76263          	bltu	a4,a3,80004856 <filewrite+0x12c>
    80004796:	0792                	slli	a5,a5,0x4
    80004798:	0001c717          	auipc	a4,0x1c
    8000479c:	45070713          	addi	a4,a4,1104 # 80020be8 <devsw>
    800047a0:	97ba                	add	a5,a5,a4
    800047a2:	679c                	ld	a5,8(a5)
    800047a4:	cbdd                	beqz	a5,8000485a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800047a6:	4505                	li	a0,1
    800047a8:	9782                	jalr	a5
    800047aa:	8a2a                	mv	s4,a0
    800047ac:	a8a5                	j	80004824 <filewrite+0xfa>
    800047ae:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800047b2:	00000097          	auipc	ra,0x0
    800047b6:	8b4080e7          	jalr	-1868(ra) # 80004066 <begin_op>
      ilock(f->ip);
    800047ba:	01893503          	ld	a0,24(s2)
    800047be:	fffff097          	auipc	ra,0xfffff
    800047c2:	edc080e7          	jalr	-292(ra) # 8000369a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047c6:	8756                	mv	a4,s5
    800047c8:	02092683          	lw	a3,32(s2)
    800047cc:	01698633          	add	a2,s3,s6
    800047d0:	4585                	li	a1,1
    800047d2:	01893503          	ld	a0,24(s2)
    800047d6:	fffff097          	auipc	ra,0xfffff
    800047da:	270080e7          	jalr	624(ra) # 80003a46 <writei>
    800047de:	84aa                	mv	s1,a0
    800047e0:	00a05763          	blez	a0,800047ee <filewrite+0xc4>
        f->off += r;
    800047e4:	02092783          	lw	a5,32(s2)
    800047e8:	9fa9                	addw	a5,a5,a0
    800047ea:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047ee:	01893503          	ld	a0,24(s2)
    800047f2:	fffff097          	auipc	ra,0xfffff
    800047f6:	f6a080e7          	jalr	-150(ra) # 8000375c <iunlock>
      end_op();
    800047fa:	00000097          	auipc	ra,0x0
    800047fe:	8ea080e7          	jalr	-1814(ra) # 800040e4 <end_op>

      if(r != n1){
    80004802:	009a9f63          	bne	s5,s1,80004820 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004806:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000480a:	0149db63          	bge	s3,s4,80004820 <filewrite+0xf6>
      int n1 = n - i;
    8000480e:	413a04bb          	subw	s1,s4,s3
    80004812:	0004879b          	sext.w	a5,s1
    80004816:	f8fbdce3          	bge	s7,a5,800047ae <filewrite+0x84>
    8000481a:	84e2                	mv	s1,s8
    8000481c:	bf49                	j	800047ae <filewrite+0x84>
    int i = 0;
    8000481e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004820:	013a1f63          	bne	s4,s3,8000483e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004824:	8552                	mv	a0,s4
    80004826:	60a6                	ld	ra,72(sp)
    80004828:	6406                	ld	s0,64(sp)
    8000482a:	74e2                	ld	s1,56(sp)
    8000482c:	7942                	ld	s2,48(sp)
    8000482e:	79a2                	ld	s3,40(sp)
    80004830:	7a02                	ld	s4,32(sp)
    80004832:	6ae2                	ld	s5,24(sp)
    80004834:	6b42                	ld	s6,16(sp)
    80004836:	6ba2                	ld	s7,8(sp)
    80004838:	6c02                	ld	s8,0(sp)
    8000483a:	6161                	addi	sp,sp,80
    8000483c:	8082                	ret
    ret = (i == n ? n : -1);
    8000483e:	5a7d                	li	s4,-1
    80004840:	b7d5                	j	80004824 <filewrite+0xfa>
    panic("filewrite");
    80004842:	00004517          	auipc	a0,0x4
    80004846:	e8e50513          	addi	a0,a0,-370 # 800086d0 <syscalls+0x268>
    8000484a:	ffffc097          	auipc	ra,0xffffc
    8000484e:	cf6080e7          	jalr	-778(ra) # 80000540 <panic>
    return -1;
    80004852:	5a7d                	li	s4,-1
    80004854:	bfc1                	j	80004824 <filewrite+0xfa>
      return -1;
    80004856:	5a7d                	li	s4,-1
    80004858:	b7f1                	j	80004824 <filewrite+0xfa>
    8000485a:	5a7d                	li	s4,-1
    8000485c:	b7e1                	j	80004824 <filewrite+0xfa>

000000008000485e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000485e:	7179                	addi	sp,sp,-48
    80004860:	f406                	sd	ra,40(sp)
    80004862:	f022                	sd	s0,32(sp)
    80004864:	ec26                	sd	s1,24(sp)
    80004866:	e84a                	sd	s2,16(sp)
    80004868:	e44e                	sd	s3,8(sp)
    8000486a:	e052                	sd	s4,0(sp)
    8000486c:	1800                	addi	s0,sp,48
    8000486e:	84aa                	mv	s1,a0
    80004870:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004872:	0005b023          	sd	zero,0(a1)
    80004876:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000487a:	00000097          	auipc	ra,0x0
    8000487e:	bf8080e7          	jalr	-1032(ra) # 80004472 <filealloc>
    80004882:	e088                	sd	a0,0(s1)
    80004884:	c551                	beqz	a0,80004910 <pipealloc+0xb2>
    80004886:	00000097          	auipc	ra,0x0
    8000488a:	bec080e7          	jalr	-1044(ra) # 80004472 <filealloc>
    8000488e:	00aa3023          	sd	a0,0(s4)
    80004892:	c92d                	beqz	a0,80004904 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004894:	ffffc097          	auipc	ra,0xffffc
    80004898:	252080e7          	jalr	594(ra) # 80000ae6 <kalloc>
    8000489c:	892a                	mv	s2,a0
    8000489e:	c125                	beqz	a0,800048fe <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048a0:	4985                	li	s3,1
    800048a2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048a6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048aa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048ae:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048b2:	00004597          	auipc	a1,0x4
    800048b6:	e2e58593          	addi	a1,a1,-466 # 800086e0 <syscalls+0x278>
    800048ba:	ffffc097          	auipc	ra,0xffffc
    800048be:	28c080e7          	jalr	652(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    800048c2:	609c                	ld	a5,0(s1)
    800048c4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048c8:	609c                	ld	a5,0(s1)
    800048ca:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048ce:	609c                	ld	a5,0(s1)
    800048d0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048d4:	609c                	ld	a5,0(s1)
    800048d6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048da:	000a3783          	ld	a5,0(s4)
    800048de:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048e2:	000a3783          	ld	a5,0(s4)
    800048e6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048ea:	000a3783          	ld	a5,0(s4)
    800048ee:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048f2:	000a3783          	ld	a5,0(s4)
    800048f6:	0127b823          	sd	s2,16(a5)
  return 0;
    800048fa:	4501                	li	a0,0
    800048fc:	a025                	j	80004924 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800048fe:	6088                	ld	a0,0(s1)
    80004900:	e501                	bnez	a0,80004908 <pipealloc+0xaa>
    80004902:	a039                	j	80004910 <pipealloc+0xb2>
    80004904:	6088                	ld	a0,0(s1)
    80004906:	c51d                	beqz	a0,80004934 <pipealloc+0xd6>
    fileclose(*f0);
    80004908:	00000097          	auipc	ra,0x0
    8000490c:	c26080e7          	jalr	-986(ra) # 8000452e <fileclose>
  if(*f1)
    80004910:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004914:	557d                	li	a0,-1
  if(*f1)
    80004916:	c799                	beqz	a5,80004924 <pipealloc+0xc6>
    fileclose(*f1);
    80004918:	853e                	mv	a0,a5
    8000491a:	00000097          	auipc	ra,0x0
    8000491e:	c14080e7          	jalr	-1004(ra) # 8000452e <fileclose>
  return -1;
    80004922:	557d                	li	a0,-1
}
    80004924:	70a2                	ld	ra,40(sp)
    80004926:	7402                	ld	s0,32(sp)
    80004928:	64e2                	ld	s1,24(sp)
    8000492a:	6942                	ld	s2,16(sp)
    8000492c:	69a2                	ld	s3,8(sp)
    8000492e:	6a02                	ld	s4,0(sp)
    80004930:	6145                	addi	sp,sp,48
    80004932:	8082                	ret
  return -1;
    80004934:	557d                	li	a0,-1
    80004936:	b7fd                	j	80004924 <pipealloc+0xc6>

0000000080004938 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004938:	1101                	addi	sp,sp,-32
    8000493a:	ec06                	sd	ra,24(sp)
    8000493c:	e822                	sd	s0,16(sp)
    8000493e:	e426                	sd	s1,8(sp)
    80004940:	e04a                	sd	s2,0(sp)
    80004942:	1000                	addi	s0,sp,32
    80004944:	84aa                	mv	s1,a0
    80004946:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	28e080e7          	jalr	654(ra) # 80000bd6 <acquire>
  if(writable){
    80004950:	02090d63          	beqz	s2,8000498a <pipeclose+0x52>
    pi->writeopen = 0;
    80004954:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004958:	21848513          	addi	a0,s1,536
    8000495c:	ffffd097          	auipc	ra,0xffffd
    80004960:	75c080e7          	jalr	1884(ra) # 800020b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004964:	2204b783          	ld	a5,544(s1)
    80004968:	eb95                	bnez	a5,8000499c <pipeclose+0x64>
    release(&pi->lock);
    8000496a:	8526                	mv	a0,s1
    8000496c:	ffffc097          	auipc	ra,0xffffc
    80004970:	31e080e7          	jalr	798(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004974:	8526                	mv	a0,s1
    80004976:	ffffc097          	auipc	ra,0xffffc
    8000497a:	072080e7          	jalr	114(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    8000497e:	60e2                	ld	ra,24(sp)
    80004980:	6442                	ld	s0,16(sp)
    80004982:	64a2                	ld	s1,8(sp)
    80004984:	6902                	ld	s2,0(sp)
    80004986:	6105                	addi	sp,sp,32
    80004988:	8082                	ret
    pi->readopen = 0;
    8000498a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000498e:	21c48513          	addi	a0,s1,540
    80004992:	ffffd097          	auipc	ra,0xffffd
    80004996:	726080e7          	jalr	1830(ra) # 800020b8 <wakeup>
    8000499a:	b7e9                	j	80004964 <pipeclose+0x2c>
    release(&pi->lock);
    8000499c:	8526                	mv	a0,s1
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	2ec080e7          	jalr	748(ra) # 80000c8a <release>
}
    800049a6:	bfe1                	j	8000497e <pipeclose+0x46>

00000000800049a8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049a8:	711d                	addi	sp,sp,-96
    800049aa:	ec86                	sd	ra,88(sp)
    800049ac:	e8a2                	sd	s0,80(sp)
    800049ae:	e4a6                	sd	s1,72(sp)
    800049b0:	e0ca                	sd	s2,64(sp)
    800049b2:	fc4e                	sd	s3,56(sp)
    800049b4:	f852                	sd	s4,48(sp)
    800049b6:	f456                	sd	s5,40(sp)
    800049b8:	f05a                	sd	s6,32(sp)
    800049ba:	ec5e                	sd	s7,24(sp)
    800049bc:	e862                	sd	s8,16(sp)
    800049be:	1080                	addi	s0,sp,96
    800049c0:	84aa                	mv	s1,a0
    800049c2:	8aae                	mv	s5,a1
    800049c4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049c6:	ffffd097          	auipc	ra,0xffffd
    800049ca:	fe6080e7          	jalr	-26(ra) # 800019ac <myproc>
    800049ce:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049d0:	8526                	mv	a0,s1
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	204080e7          	jalr	516(ra) # 80000bd6 <acquire>
  while(i < n){
    800049da:	0b405663          	blez	s4,80004a86 <pipewrite+0xde>
  int i = 0;
    800049de:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049e0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800049e2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800049e6:	21c48b93          	addi	s7,s1,540
    800049ea:	a089                	j	80004a2c <pipewrite+0x84>
      release(&pi->lock);
    800049ec:	8526                	mv	a0,s1
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	29c080e7          	jalr	668(ra) # 80000c8a <release>
      return -1;
    800049f6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800049f8:	854a                	mv	a0,s2
    800049fa:	60e6                	ld	ra,88(sp)
    800049fc:	6446                	ld	s0,80(sp)
    800049fe:	64a6                	ld	s1,72(sp)
    80004a00:	6906                	ld	s2,64(sp)
    80004a02:	79e2                	ld	s3,56(sp)
    80004a04:	7a42                	ld	s4,48(sp)
    80004a06:	7aa2                	ld	s5,40(sp)
    80004a08:	7b02                	ld	s6,32(sp)
    80004a0a:	6be2                	ld	s7,24(sp)
    80004a0c:	6c42                	ld	s8,16(sp)
    80004a0e:	6125                	addi	sp,sp,96
    80004a10:	8082                	ret
      wakeup(&pi->nread);
    80004a12:	8562                	mv	a0,s8
    80004a14:	ffffd097          	auipc	ra,0xffffd
    80004a18:	6a4080e7          	jalr	1700(ra) # 800020b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a1c:	85a6                	mv	a1,s1
    80004a1e:	855e                	mv	a0,s7
    80004a20:	ffffd097          	auipc	ra,0xffffd
    80004a24:	634080e7          	jalr	1588(ra) # 80002054 <sleep>
  while(i < n){
    80004a28:	07495063          	bge	s2,s4,80004a88 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a2c:	2204a783          	lw	a5,544(s1)
    80004a30:	dfd5                	beqz	a5,800049ec <pipewrite+0x44>
    80004a32:	854e                	mv	a0,s3
    80004a34:	ffffe097          	auipc	ra,0xffffe
    80004a38:	8c8080e7          	jalr	-1848(ra) # 800022fc <killed>
    80004a3c:	f945                	bnez	a0,800049ec <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a3e:	2184a783          	lw	a5,536(s1)
    80004a42:	21c4a703          	lw	a4,540(s1)
    80004a46:	2007879b          	addiw	a5,a5,512
    80004a4a:	fcf704e3          	beq	a4,a5,80004a12 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a4e:	4685                	li	a3,1
    80004a50:	01590633          	add	a2,s2,s5
    80004a54:	faf40593          	addi	a1,s0,-81
    80004a58:	0509b503          	ld	a0,80(s3)
    80004a5c:	ffffd097          	auipc	ra,0xffffd
    80004a60:	c9c080e7          	jalr	-868(ra) # 800016f8 <copyin>
    80004a64:	03650263          	beq	a0,s6,80004a88 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a68:	21c4a783          	lw	a5,540(s1)
    80004a6c:	0017871b          	addiw	a4,a5,1
    80004a70:	20e4ae23          	sw	a4,540(s1)
    80004a74:	1ff7f793          	andi	a5,a5,511
    80004a78:	97a6                	add	a5,a5,s1
    80004a7a:	faf44703          	lbu	a4,-81(s0)
    80004a7e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a82:	2905                	addiw	s2,s2,1
    80004a84:	b755                	j	80004a28 <pipewrite+0x80>
  int i = 0;
    80004a86:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a88:	21848513          	addi	a0,s1,536
    80004a8c:	ffffd097          	auipc	ra,0xffffd
    80004a90:	62c080e7          	jalr	1580(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80004a94:	8526                	mv	a0,s1
    80004a96:	ffffc097          	auipc	ra,0xffffc
    80004a9a:	1f4080e7          	jalr	500(ra) # 80000c8a <release>
  return i;
    80004a9e:	bfa9                	j	800049f8 <pipewrite+0x50>

0000000080004aa0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004aa0:	715d                	addi	sp,sp,-80
    80004aa2:	e486                	sd	ra,72(sp)
    80004aa4:	e0a2                	sd	s0,64(sp)
    80004aa6:	fc26                	sd	s1,56(sp)
    80004aa8:	f84a                	sd	s2,48(sp)
    80004aaa:	f44e                	sd	s3,40(sp)
    80004aac:	f052                	sd	s4,32(sp)
    80004aae:	ec56                	sd	s5,24(sp)
    80004ab0:	e85a                	sd	s6,16(sp)
    80004ab2:	0880                	addi	s0,sp,80
    80004ab4:	84aa                	mv	s1,a0
    80004ab6:	892e                	mv	s2,a1
    80004ab8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004aba:	ffffd097          	auipc	ra,0xffffd
    80004abe:	ef2080e7          	jalr	-270(ra) # 800019ac <myproc>
    80004ac2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ac4:	8526                	mv	a0,s1
    80004ac6:	ffffc097          	auipc	ra,0xffffc
    80004aca:	110080e7          	jalr	272(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ace:	2184a703          	lw	a4,536(s1)
    80004ad2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ad6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ada:	02f71763          	bne	a4,a5,80004b08 <piperead+0x68>
    80004ade:	2244a783          	lw	a5,548(s1)
    80004ae2:	c39d                	beqz	a5,80004b08 <piperead+0x68>
    if(killed(pr)){
    80004ae4:	8552                	mv	a0,s4
    80004ae6:	ffffe097          	auipc	ra,0xffffe
    80004aea:	816080e7          	jalr	-2026(ra) # 800022fc <killed>
    80004aee:	e949                	bnez	a0,80004b80 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004af0:	85a6                	mv	a1,s1
    80004af2:	854e                	mv	a0,s3
    80004af4:	ffffd097          	auipc	ra,0xffffd
    80004af8:	560080e7          	jalr	1376(ra) # 80002054 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004afc:	2184a703          	lw	a4,536(s1)
    80004b00:	21c4a783          	lw	a5,540(s1)
    80004b04:	fcf70de3          	beq	a4,a5,80004ade <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b08:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b0a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b0c:	05505463          	blez	s5,80004b54 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b10:	2184a783          	lw	a5,536(s1)
    80004b14:	21c4a703          	lw	a4,540(s1)
    80004b18:	02f70e63          	beq	a4,a5,80004b54 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b1c:	0017871b          	addiw	a4,a5,1
    80004b20:	20e4ac23          	sw	a4,536(s1)
    80004b24:	1ff7f793          	andi	a5,a5,511
    80004b28:	97a6                	add	a5,a5,s1
    80004b2a:	0187c783          	lbu	a5,24(a5)
    80004b2e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b32:	4685                	li	a3,1
    80004b34:	fbf40613          	addi	a2,s0,-65
    80004b38:	85ca                	mv	a1,s2
    80004b3a:	050a3503          	ld	a0,80(s4)
    80004b3e:	ffffd097          	auipc	ra,0xffffd
    80004b42:	b2e080e7          	jalr	-1234(ra) # 8000166c <copyout>
    80004b46:	01650763          	beq	a0,s6,80004b54 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b4a:	2985                	addiw	s3,s3,1
    80004b4c:	0905                	addi	s2,s2,1
    80004b4e:	fd3a91e3          	bne	s5,s3,80004b10 <piperead+0x70>
    80004b52:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b54:	21c48513          	addi	a0,s1,540
    80004b58:	ffffd097          	auipc	ra,0xffffd
    80004b5c:	560080e7          	jalr	1376(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80004b60:	8526                	mv	a0,s1
    80004b62:	ffffc097          	auipc	ra,0xffffc
    80004b66:	128080e7          	jalr	296(ra) # 80000c8a <release>
  return i;
}
    80004b6a:	854e                	mv	a0,s3
    80004b6c:	60a6                	ld	ra,72(sp)
    80004b6e:	6406                	ld	s0,64(sp)
    80004b70:	74e2                	ld	s1,56(sp)
    80004b72:	7942                	ld	s2,48(sp)
    80004b74:	79a2                	ld	s3,40(sp)
    80004b76:	7a02                	ld	s4,32(sp)
    80004b78:	6ae2                	ld	s5,24(sp)
    80004b7a:	6b42                	ld	s6,16(sp)
    80004b7c:	6161                	addi	sp,sp,80
    80004b7e:	8082                	ret
      release(&pi->lock);
    80004b80:	8526                	mv	a0,s1
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	108080e7          	jalr	264(ra) # 80000c8a <release>
      return -1;
    80004b8a:	59fd                	li	s3,-1
    80004b8c:	bff9                	j	80004b6a <piperead+0xca>

0000000080004b8e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004b8e:	1141                	addi	sp,sp,-16
    80004b90:	e422                	sd	s0,8(sp)
    80004b92:	0800                	addi	s0,sp,16
    80004b94:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b96:	8905                	andi	a0,a0,1
    80004b98:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004b9a:	8b89                	andi	a5,a5,2
    80004b9c:	c399                	beqz	a5,80004ba2 <flags2perm+0x14>
      perm |= PTE_W;
    80004b9e:	00456513          	ori	a0,a0,4
    return perm;
}
    80004ba2:	6422                	ld	s0,8(sp)
    80004ba4:	0141                	addi	sp,sp,16
    80004ba6:	8082                	ret

0000000080004ba8 <exec>:

int
exec(char *path, char **argv)
{
    80004ba8:	de010113          	addi	sp,sp,-544
    80004bac:	20113c23          	sd	ra,536(sp)
    80004bb0:	20813823          	sd	s0,528(sp)
    80004bb4:	20913423          	sd	s1,520(sp)
    80004bb8:	21213023          	sd	s2,512(sp)
    80004bbc:	ffce                	sd	s3,504(sp)
    80004bbe:	fbd2                	sd	s4,496(sp)
    80004bc0:	f7d6                	sd	s5,488(sp)
    80004bc2:	f3da                	sd	s6,480(sp)
    80004bc4:	efde                	sd	s7,472(sp)
    80004bc6:	ebe2                	sd	s8,464(sp)
    80004bc8:	e7e6                	sd	s9,456(sp)
    80004bca:	e3ea                	sd	s10,448(sp)
    80004bcc:	ff6e                	sd	s11,440(sp)
    80004bce:	1400                	addi	s0,sp,544
    80004bd0:	892a                	mv	s2,a0
    80004bd2:	dea43423          	sd	a0,-536(s0)
    80004bd6:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bda:	ffffd097          	auipc	ra,0xffffd
    80004bde:	dd2080e7          	jalr	-558(ra) # 800019ac <myproc>
    80004be2:	84aa                	mv	s1,a0

  begin_op();
    80004be4:	fffff097          	auipc	ra,0xfffff
    80004be8:	482080e7          	jalr	1154(ra) # 80004066 <begin_op>

  if((ip = namei(path)) == 0){
    80004bec:	854a                	mv	a0,s2
    80004bee:	fffff097          	auipc	ra,0xfffff
    80004bf2:	258080e7          	jalr	600(ra) # 80003e46 <namei>
    80004bf6:	c93d                	beqz	a0,80004c6c <exec+0xc4>
    80004bf8:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bfa:	fffff097          	auipc	ra,0xfffff
    80004bfe:	aa0080e7          	jalr	-1376(ra) # 8000369a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c02:	04000713          	li	a4,64
    80004c06:	4681                	li	a3,0
    80004c08:	e5040613          	addi	a2,s0,-432
    80004c0c:	4581                	li	a1,0
    80004c0e:	8556                	mv	a0,s5
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	d3e080e7          	jalr	-706(ra) # 8000394e <readi>
    80004c18:	04000793          	li	a5,64
    80004c1c:	00f51a63          	bne	a0,a5,80004c30 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c20:	e5042703          	lw	a4,-432(s0)
    80004c24:	464c47b7          	lui	a5,0x464c4
    80004c28:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c2c:	04f70663          	beq	a4,a5,80004c78 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c30:	8556                	mv	a0,s5
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	cca080e7          	jalr	-822(ra) # 800038fc <iunlockput>
    end_op();
    80004c3a:	fffff097          	auipc	ra,0xfffff
    80004c3e:	4aa080e7          	jalr	1194(ra) # 800040e4 <end_op>
  }
  return -1;
    80004c42:	557d                	li	a0,-1
}
    80004c44:	21813083          	ld	ra,536(sp)
    80004c48:	21013403          	ld	s0,528(sp)
    80004c4c:	20813483          	ld	s1,520(sp)
    80004c50:	20013903          	ld	s2,512(sp)
    80004c54:	79fe                	ld	s3,504(sp)
    80004c56:	7a5e                	ld	s4,496(sp)
    80004c58:	7abe                	ld	s5,488(sp)
    80004c5a:	7b1e                	ld	s6,480(sp)
    80004c5c:	6bfe                	ld	s7,472(sp)
    80004c5e:	6c5e                	ld	s8,464(sp)
    80004c60:	6cbe                	ld	s9,456(sp)
    80004c62:	6d1e                	ld	s10,448(sp)
    80004c64:	7dfa                	ld	s11,440(sp)
    80004c66:	22010113          	addi	sp,sp,544
    80004c6a:	8082                	ret
    end_op();
    80004c6c:	fffff097          	auipc	ra,0xfffff
    80004c70:	478080e7          	jalr	1144(ra) # 800040e4 <end_op>
    return -1;
    80004c74:	557d                	li	a0,-1
    80004c76:	b7f9                	j	80004c44 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c78:	8526                	mv	a0,s1
    80004c7a:	ffffd097          	auipc	ra,0xffffd
    80004c7e:	df6080e7          	jalr	-522(ra) # 80001a70 <proc_pagetable>
    80004c82:	8b2a                	mv	s6,a0
    80004c84:	d555                	beqz	a0,80004c30 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c86:	e7042783          	lw	a5,-400(s0)
    80004c8a:	e8845703          	lhu	a4,-376(s0)
    80004c8e:	c735                	beqz	a4,80004cfa <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c90:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c92:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004c96:	6a05                	lui	s4,0x1
    80004c98:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c9c:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004ca0:	6d85                	lui	s11,0x1
    80004ca2:	7d7d                	lui	s10,0xfffff
    80004ca4:	ac3d                	j	80004ee2 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ca6:	00004517          	auipc	a0,0x4
    80004caa:	a4250513          	addi	a0,a0,-1470 # 800086e8 <syscalls+0x280>
    80004cae:	ffffc097          	auipc	ra,0xffffc
    80004cb2:	892080e7          	jalr	-1902(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cb6:	874a                	mv	a4,s2
    80004cb8:	009c86bb          	addw	a3,s9,s1
    80004cbc:	4581                	li	a1,0
    80004cbe:	8556                	mv	a0,s5
    80004cc0:	fffff097          	auipc	ra,0xfffff
    80004cc4:	c8e080e7          	jalr	-882(ra) # 8000394e <readi>
    80004cc8:	2501                	sext.w	a0,a0
    80004cca:	1aa91963          	bne	s2,a0,80004e7c <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004cce:	009d84bb          	addw	s1,s11,s1
    80004cd2:	013d09bb          	addw	s3,s10,s3
    80004cd6:	1f74f663          	bgeu	s1,s7,80004ec2 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004cda:	02049593          	slli	a1,s1,0x20
    80004cde:	9181                	srli	a1,a1,0x20
    80004ce0:	95e2                	add	a1,a1,s8
    80004ce2:	855a                	mv	a0,s6
    80004ce4:	ffffc097          	auipc	ra,0xffffc
    80004ce8:	378080e7          	jalr	888(ra) # 8000105c <walkaddr>
    80004cec:	862a                	mv	a2,a0
    if(pa == 0)
    80004cee:	dd45                	beqz	a0,80004ca6 <exec+0xfe>
      n = PGSIZE;
    80004cf0:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004cf2:	fd49f2e3          	bgeu	s3,s4,80004cb6 <exec+0x10e>
      n = sz - i;
    80004cf6:	894e                	mv	s2,s3
    80004cf8:	bf7d                	j	80004cb6 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cfa:	4901                	li	s2,0
  iunlockput(ip);
    80004cfc:	8556                	mv	a0,s5
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	bfe080e7          	jalr	-1026(ra) # 800038fc <iunlockput>
  end_op();
    80004d06:	fffff097          	auipc	ra,0xfffff
    80004d0a:	3de080e7          	jalr	990(ra) # 800040e4 <end_op>
  p = myproc();
    80004d0e:	ffffd097          	auipc	ra,0xffffd
    80004d12:	c9e080e7          	jalr	-866(ra) # 800019ac <myproc>
    80004d16:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d18:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d1c:	6785                	lui	a5,0x1
    80004d1e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004d20:	97ca                	add	a5,a5,s2
    80004d22:	777d                	lui	a4,0xfffff
    80004d24:	8ff9                	and	a5,a5,a4
    80004d26:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d2a:	4691                	li	a3,4
    80004d2c:	6609                	lui	a2,0x2
    80004d2e:	963e                	add	a2,a2,a5
    80004d30:	85be                	mv	a1,a5
    80004d32:	855a                	mv	a0,s6
    80004d34:	ffffc097          	auipc	ra,0xffffc
    80004d38:	6dc080e7          	jalr	1756(ra) # 80001410 <uvmalloc>
    80004d3c:	8c2a                	mv	s8,a0
  ip = 0;
    80004d3e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d40:	12050e63          	beqz	a0,80004e7c <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d44:	75f9                	lui	a1,0xffffe
    80004d46:	95aa                	add	a1,a1,a0
    80004d48:	855a                	mv	a0,s6
    80004d4a:	ffffd097          	auipc	ra,0xffffd
    80004d4e:	8f0080e7          	jalr	-1808(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80004d52:	7afd                	lui	s5,0xfffff
    80004d54:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d56:	df043783          	ld	a5,-528(s0)
    80004d5a:	6388                	ld	a0,0(a5)
    80004d5c:	c925                	beqz	a0,80004dcc <exec+0x224>
    80004d5e:	e9040993          	addi	s3,s0,-368
    80004d62:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d66:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d68:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d6a:	ffffc097          	auipc	ra,0xffffc
    80004d6e:	0e4080e7          	jalr	228(ra) # 80000e4e <strlen>
    80004d72:	0015079b          	addiw	a5,a0,1
    80004d76:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d7a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004d7e:	13596663          	bltu	s2,s5,80004eaa <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d82:	df043d83          	ld	s11,-528(s0)
    80004d86:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004d8a:	8552                	mv	a0,s4
    80004d8c:	ffffc097          	auipc	ra,0xffffc
    80004d90:	0c2080e7          	jalr	194(ra) # 80000e4e <strlen>
    80004d94:	0015069b          	addiw	a3,a0,1
    80004d98:	8652                	mv	a2,s4
    80004d9a:	85ca                	mv	a1,s2
    80004d9c:	855a                	mv	a0,s6
    80004d9e:	ffffd097          	auipc	ra,0xffffd
    80004da2:	8ce080e7          	jalr	-1842(ra) # 8000166c <copyout>
    80004da6:	10054663          	bltz	a0,80004eb2 <exec+0x30a>
    ustack[argc] = sp;
    80004daa:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004dae:	0485                	addi	s1,s1,1
    80004db0:	008d8793          	addi	a5,s11,8
    80004db4:	def43823          	sd	a5,-528(s0)
    80004db8:	008db503          	ld	a0,8(s11)
    80004dbc:	c911                	beqz	a0,80004dd0 <exec+0x228>
    if(argc >= MAXARG)
    80004dbe:	09a1                	addi	s3,s3,8
    80004dc0:	fb3c95e3          	bne	s9,s3,80004d6a <exec+0x1c2>
  sz = sz1;
    80004dc4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004dc8:	4a81                	li	s5,0
    80004dca:	a84d                	j	80004e7c <exec+0x2d4>
  sp = sz;
    80004dcc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004dce:	4481                	li	s1,0
  ustack[argc] = 0;
    80004dd0:	00349793          	slli	a5,s1,0x3
    80004dd4:	f9078793          	addi	a5,a5,-112
    80004dd8:	97a2                	add	a5,a5,s0
    80004dda:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004dde:	00148693          	addi	a3,s1,1
    80004de2:	068e                	slli	a3,a3,0x3
    80004de4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004de8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004dec:	01597663          	bgeu	s2,s5,80004df8 <exec+0x250>
  sz = sz1;
    80004df0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004df4:	4a81                	li	s5,0
    80004df6:	a059                	j	80004e7c <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004df8:	e9040613          	addi	a2,s0,-368
    80004dfc:	85ca                	mv	a1,s2
    80004dfe:	855a                	mv	a0,s6
    80004e00:	ffffd097          	auipc	ra,0xffffd
    80004e04:	86c080e7          	jalr	-1940(ra) # 8000166c <copyout>
    80004e08:	0a054963          	bltz	a0,80004eba <exec+0x312>
  p->trapframe->a1 = sp;
    80004e0c:	058bb783          	ld	a5,88(s7)
    80004e10:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e14:	de843783          	ld	a5,-536(s0)
    80004e18:	0007c703          	lbu	a4,0(a5)
    80004e1c:	cf11                	beqz	a4,80004e38 <exec+0x290>
    80004e1e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e20:	02f00693          	li	a3,47
    80004e24:	a039                	j	80004e32 <exec+0x28a>
      last = s+1;
    80004e26:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e2a:	0785                	addi	a5,a5,1
    80004e2c:	fff7c703          	lbu	a4,-1(a5)
    80004e30:	c701                	beqz	a4,80004e38 <exec+0x290>
    if(*s == '/')
    80004e32:	fed71ce3          	bne	a4,a3,80004e2a <exec+0x282>
    80004e36:	bfc5                	j	80004e26 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e38:	4641                	li	a2,16
    80004e3a:	de843583          	ld	a1,-536(s0)
    80004e3e:	158b8513          	addi	a0,s7,344
    80004e42:	ffffc097          	auipc	ra,0xffffc
    80004e46:	fda080e7          	jalr	-38(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e4a:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e4e:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004e52:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e56:	058bb783          	ld	a5,88(s7)
    80004e5a:	e6843703          	ld	a4,-408(s0)
    80004e5e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e60:	058bb783          	ld	a5,88(s7)
    80004e64:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e68:	85ea                	mv	a1,s10
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	ca2080e7          	jalr	-862(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e72:	0004851b          	sext.w	a0,s1
    80004e76:	b3f9                	j	80004c44 <exec+0x9c>
    80004e78:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004e7c:	df843583          	ld	a1,-520(s0)
    80004e80:	855a                	mv	a0,s6
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	c8a080e7          	jalr	-886(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    80004e8a:	da0a93e3          	bnez	s5,80004c30 <exec+0x88>
  return -1;
    80004e8e:	557d                	li	a0,-1
    80004e90:	bb55                	j	80004c44 <exec+0x9c>
    80004e92:	df243c23          	sd	s2,-520(s0)
    80004e96:	b7dd                	j	80004e7c <exec+0x2d4>
    80004e98:	df243c23          	sd	s2,-520(s0)
    80004e9c:	b7c5                	j	80004e7c <exec+0x2d4>
    80004e9e:	df243c23          	sd	s2,-520(s0)
    80004ea2:	bfe9                	j	80004e7c <exec+0x2d4>
    80004ea4:	df243c23          	sd	s2,-520(s0)
    80004ea8:	bfd1                	j	80004e7c <exec+0x2d4>
  sz = sz1;
    80004eaa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eae:	4a81                	li	s5,0
    80004eb0:	b7f1                	j	80004e7c <exec+0x2d4>
  sz = sz1;
    80004eb2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eb6:	4a81                	li	s5,0
    80004eb8:	b7d1                	j	80004e7c <exec+0x2d4>
  sz = sz1;
    80004eba:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ebe:	4a81                	li	s5,0
    80004ec0:	bf75                	j	80004e7c <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ec2:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ec6:	e0843783          	ld	a5,-504(s0)
    80004eca:	0017869b          	addiw	a3,a5,1
    80004ece:	e0d43423          	sd	a3,-504(s0)
    80004ed2:	e0043783          	ld	a5,-512(s0)
    80004ed6:	0387879b          	addiw	a5,a5,56
    80004eda:	e8845703          	lhu	a4,-376(s0)
    80004ede:	e0e6dfe3          	bge	a3,a4,80004cfc <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ee2:	2781                	sext.w	a5,a5
    80004ee4:	e0f43023          	sd	a5,-512(s0)
    80004ee8:	03800713          	li	a4,56
    80004eec:	86be                	mv	a3,a5
    80004eee:	e1840613          	addi	a2,s0,-488
    80004ef2:	4581                	li	a1,0
    80004ef4:	8556                	mv	a0,s5
    80004ef6:	fffff097          	auipc	ra,0xfffff
    80004efa:	a58080e7          	jalr	-1448(ra) # 8000394e <readi>
    80004efe:	03800793          	li	a5,56
    80004f02:	f6f51be3          	bne	a0,a5,80004e78 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80004f06:	e1842783          	lw	a5,-488(s0)
    80004f0a:	4705                	li	a4,1
    80004f0c:	fae79de3          	bne	a5,a4,80004ec6 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80004f10:	e4043483          	ld	s1,-448(s0)
    80004f14:	e3843783          	ld	a5,-456(s0)
    80004f18:	f6f4ede3          	bltu	s1,a5,80004e92 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f1c:	e2843783          	ld	a5,-472(s0)
    80004f20:	94be                	add	s1,s1,a5
    80004f22:	f6f4ebe3          	bltu	s1,a5,80004e98 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80004f26:	de043703          	ld	a4,-544(s0)
    80004f2a:	8ff9                	and	a5,a5,a4
    80004f2c:	fbad                	bnez	a5,80004e9e <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f2e:	e1c42503          	lw	a0,-484(s0)
    80004f32:	00000097          	auipc	ra,0x0
    80004f36:	c5c080e7          	jalr	-932(ra) # 80004b8e <flags2perm>
    80004f3a:	86aa                	mv	a3,a0
    80004f3c:	8626                	mv	a2,s1
    80004f3e:	85ca                	mv	a1,s2
    80004f40:	855a                	mv	a0,s6
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	4ce080e7          	jalr	1230(ra) # 80001410 <uvmalloc>
    80004f4a:	dea43c23          	sd	a0,-520(s0)
    80004f4e:	d939                	beqz	a0,80004ea4 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f50:	e2843c03          	ld	s8,-472(s0)
    80004f54:	e2042c83          	lw	s9,-480(s0)
    80004f58:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f5c:	f60b83e3          	beqz	s7,80004ec2 <exec+0x31a>
    80004f60:	89de                	mv	s3,s7
    80004f62:	4481                	li	s1,0
    80004f64:	bb9d                	j	80004cda <exec+0x132>

0000000080004f66 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f66:	7179                	addi	sp,sp,-48
    80004f68:	f406                	sd	ra,40(sp)
    80004f6a:	f022                	sd	s0,32(sp)
    80004f6c:	ec26                	sd	s1,24(sp)
    80004f6e:	e84a                	sd	s2,16(sp)
    80004f70:	1800                	addi	s0,sp,48
    80004f72:	892e                	mv	s2,a1
    80004f74:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f76:	fdc40593          	addi	a1,s0,-36
    80004f7a:	ffffe097          	auipc	ra,0xffffe
    80004f7e:	bb6080e7          	jalr	-1098(ra) # 80002b30 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f82:	fdc42703          	lw	a4,-36(s0)
    80004f86:	47bd                	li	a5,15
    80004f88:	02e7eb63          	bltu	a5,a4,80004fbe <argfd+0x58>
    80004f8c:	ffffd097          	auipc	ra,0xffffd
    80004f90:	a20080e7          	jalr	-1504(ra) # 800019ac <myproc>
    80004f94:	fdc42703          	lw	a4,-36(s0)
    80004f98:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd29a>
    80004f9c:	078e                	slli	a5,a5,0x3
    80004f9e:	953e                	add	a0,a0,a5
    80004fa0:	611c                	ld	a5,0(a0)
    80004fa2:	c385                	beqz	a5,80004fc2 <argfd+0x5c>
    return -1;
  if(pfd)
    80004fa4:	00090463          	beqz	s2,80004fac <argfd+0x46>
    *pfd = fd;
    80004fa8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fac:	4501                	li	a0,0
  if(pf)
    80004fae:	c091                	beqz	s1,80004fb2 <argfd+0x4c>
    *pf = f;
    80004fb0:	e09c                	sd	a5,0(s1)
}
    80004fb2:	70a2                	ld	ra,40(sp)
    80004fb4:	7402                	ld	s0,32(sp)
    80004fb6:	64e2                	ld	s1,24(sp)
    80004fb8:	6942                	ld	s2,16(sp)
    80004fba:	6145                	addi	sp,sp,48
    80004fbc:	8082                	ret
    return -1;
    80004fbe:	557d                	li	a0,-1
    80004fc0:	bfcd                	j	80004fb2 <argfd+0x4c>
    80004fc2:	557d                	li	a0,-1
    80004fc4:	b7fd                	j	80004fb2 <argfd+0x4c>

0000000080004fc6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fc6:	1101                	addi	sp,sp,-32
    80004fc8:	ec06                	sd	ra,24(sp)
    80004fca:	e822                	sd	s0,16(sp)
    80004fcc:	e426                	sd	s1,8(sp)
    80004fce:	1000                	addi	s0,sp,32
    80004fd0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fd2:	ffffd097          	auipc	ra,0xffffd
    80004fd6:	9da080e7          	jalr	-1574(ra) # 800019ac <myproc>
    80004fda:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fdc:	0d050793          	addi	a5,a0,208
    80004fe0:	4501                	li	a0,0
    80004fe2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004fe4:	6398                	ld	a4,0(a5)
    80004fe6:	cb19                	beqz	a4,80004ffc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004fe8:	2505                	addiw	a0,a0,1
    80004fea:	07a1                	addi	a5,a5,8
    80004fec:	fed51ce3          	bne	a0,a3,80004fe4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ff0:	557d                	li	a0,-1
}
    80004ff2:	60e2                	ld	ra,24(sp)
    80004ff4:	6442                	ld	s0,16(sp)
    80004ff6:	64a2                	ld	s1,8(sp)
    80004ff8:	6105                	addi	sp,sp,32
    80004ffa:	8082                	ret
      p->ofile[fd] = f;
    80004ffc:	01a50793          	addi	a5,a0,26
    80005000:	078e                	slli	a5,a5,0x3
    80005002:	963e                	add	a2,a2,a5
    80005004:	e204                	sd	s1,0(a2)
      return fd;
    80005006:	b7f5                	j	80004ff2 <fdalloc+0x2c>

0000000080005008 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005008:	715d                	addi	sp,sp,-80
    8000500a:	e486                	sd	ra,72(sp)
    8000500c:	e0a2                	sd	s0,64(sp)
    8000500e:	fc26                	sd	s1,56(sp)
    80005010:	f84a                	sd	s2,48(sp)
    80005012:	f44e                	sd	s3,40(sp)
    80005014:	f052                	sd	s4,32(sp)
    80005016:	ec56                	sd	s5,24(sp)
    80005018:	e85a                	sd	s6,16(sp)
    8000501a:	0880                	addi	s0,sp,80
    8000501c:	8b2e                	mv	s6,a1
    8000501e:	89b2                	mv	s3,a2
    80005020:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005022:	fb040593          	addi	a1,s0,-80
    80005026:	fffff097          	auipc	ra,0xfffff
    8000502a:	e3e080e7          	jalr	-450(ra) # 80003e64 <nameiparent>
    8000502e:	84aa                	mv	s1,a0
    80005030:	14050f63          	beqz	a0,8000518e <create+0x186>
    return 0;

  ilock(dp);
    80005034:	ffffe097          	auipc	ra,0xffffe
    80005038:	666080e7          	jalr	1638(ra) # 8000369a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000503c:	4601                	li	a2,0
    8000503e:	fb040593          	addi	a1,s0,-80
    80005042:	8526                	mv	a0,s1
    80005044:	fffff097          	auipc	ra,0xfffff
    80005048:	b3a080e7          	jalr	-1222(ra) # 80003b7e <dirlookup>
    8000504c:	8aaa                	mv	s5,a0
    8000504e:	c931                	beqz	a0,800050a2 <create+0x9a>
    iunlockput(dp);
    80005050:	8526                	mv	a0,s1
    80005052:	fffff097          	auipc	ra,0xfffff
    80005056:	8aa080e7          	jalr	-1878(ra) # 800038fc <iunlockput>
    ilock(ip);
    8000505a:	8556                	mv	a0,s5
    8000505c:	ffffe097          	auipc	ra,0xffffe
    80005060:	63e080e7          	jalr	1598(ra) # 8000369a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005064:	000b059b          	sext.w	a1,s6
    80005068:	4789                	li	a5,2
    8000506a:	02f59563          	bne	a1,a5,80005094 <create+0x8c>
    8000506e:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd2c4>
    80005072:	37f9                	addiw	a5,a5,-2
    80005074:	17c2                	slli	a5,a5,0x30
    80005076:	93c1                	srli	a5,a5,0x30
    80005078:	4705                	li	a4,1
    8000507a:	00f76d63          	bltu	a4,a5,80005094 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000507e:	8556                	mv	a0,s5
    80005080:	60a6                	ld	ra,72(sp)
    80005082:	6406                	ld	s0,64(sp)
    80005084:	74e2                	ld	s1,56(sp)
    80005086:	7942                	ld	s2,48(sp)
    80005088:	79a2                	ld	s3,40(sp)
    8000508a:	7a02                	ld	s4,32(sp)
    8000508c:	6ae2                	ld	s5,24(sp)
    8000508e:	6b42                	ld	s6,16(sp)
    80005090:	6161                	addi	sp,sp,80
    80005092:	8082                	ret
    iunlockput(ip);
    80005094:	8556                	mv	a0,s5
    80005096:	fffff097          	auipc	ra,0xfffff
    8000509a:	866080e7          	jalr	-1946(ra) # 800038fc <iunlockput>
    return 0;
    8000509e:	4a81                	li	s5,0
    800050a0:	bff9                	j	8000507e <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800050a2:	85da                	mv	a1,s6
    800050a4:	4088                	lw	a0,0(s1)
    800050a6:	ffffe097          	auipc	ra,0xffffe
    800050aa:	456080e7          	jalr	1110(ra) # 800034fc <ialloc>
    800050ae:	8a2a                	mv	s4,a0
    800050b0:	c539                	beqz	a0,800050fe <create+0xf6>
  ilock(ip);
    800050b2:	ffffe097          	auipc	ra,0xffffe
    800050b6:	5e8080e7          	jalr	1512(ra) # 8000369a <ilock>
  ip->major = major;
    800050ba:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800050be:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800050c2:	4905                	li	s2,1
    800050c4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800050c8:	8552                	mv	a0,s4
    800050ca:	ffffe097          	auipc	ra,0xffffe
    800050ce:	504080e7          	jalr	1284(ra) # 800035ce <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050d2:	000b059b          	sext.w	a1,s6
    800050d6:	03258b63          	beq	a1,s2,8000510c <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800050da:	004a2603          	lw	a2,4(s4)
    800050de:	fb040593          	addi	a1,s0,-80
    800050e2:	8526                	mv	a0,s1
    800050e4:	fffff097          	auipc	ra,0xfffff
    800050e8:	cb0080e7          	jalr	-848(ra) # 80003d94 <dirlink>
    800050ec:	06054f63          	bltz	a0,8000516a <create+0x162>
  iunlockput(dp);
    800050f0:	8526                	mv	a0,s1
    800050f2:	fffff097          	auipc	ra,0xfffff
    800050f6:	80a080e7          	jalr	-2038(ra) # 800038fc <iunlockput>
  return ip;
    800050fa:	8ad2                	mv	s5,s4
    800050fc:	b749                	j	8000507e <create+0x76>
    iunlockput(dp);
    800050fe:	8526                	mv	a0,s1
    80005100:	ffffe097          	auipc	ra,0xffffe
    80005104:	7fc080e7          	jalr	2044(ra) # 800038fc <iunlockput>
    return 0;
    80005108:	8ad2                	mv	s5,s4
    8000510a:	bf95                	j	8000507e <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000510c:	004a2603          	lw	a2,4(s4)
    80005110:	00003597          	auipc	a1,0x3
    80005114:	5f858593          	addi	a1,a1,1528 # 80008708 <syscalls+0x2a0>
    80005118:	8552                	mv	a0,s4
    8000511a:	fffff097          	auipc	ra,0xfffff
    8000511e:	c7a080e7          	jalr	-902(ra) # 80003d94 <dirlink>
    80005122:	04054463          	bltz	a0,8000516a <create+0x162>
    80005126:	40d0                	lw	a2,4(s1)
    80005128:	00003597          	auipc	a1,0x3
    8000512c:	5e858593          	addi	a1,a1,1512 # 80008710 <syscalls+0x2a8>
    80005130:	8552                	mv	a0,s4
    80005132:	fffff097          	auipc	ra,0xfffff
    80005136:	c62080e7          	jalr	-926(ra) # 80003d94 <dirlink>
    8000513a:	02054863          	bltz	a0,8000516a <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000513e:	004a2603          	lw	a2,4(s4)
    80005142:	fb040593          	addi	a1,s0,-80
    80005146:	8526                	mv	a0,s1
    80005148:	fffff097          	auipc	ra,0xfffff
    8000514c:	c4c080e7          	jalr	-948(ra) # 80003d94 <dirlink>
    80005150:	00054d63          	bltz	a0,8000516a <create+0x162>
    dp->nlink++;  // for ".."
    80005154:	04a4d783          	lhu	a5,74(s1)
    80005158:	2785                	addiw	a5,a5,1
    8000515a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000515e:	8526                	mv	a0,s1
    80005160:	ffffe097          	auipc	ra,0xffffe
    80005164:	46e080e7          	jalr	1134(ra) # 800035ce <iupdate>
    80005168:	b761                	j	800050f0 <create+0xe8>
  ip->nlink = 0;
    8000516a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000516e:	8552                	mv	a0,s4
    80005170:	ffffe097          	auipc	ra,0xffffe
    80005174:	45e080e7          	jalr	1118(ra) # 800035ce <iupdate>
  iunlockput(ip);
    80005178:	8552                	mv	a0,s4
    8000517a:	ffffe097          	auipc	ra,0xffffe
    8000517e:	782080e7          	jalr	1922(ra) # 800038fc <iunlockput>
  iunlockput(dp);
    80005182:	8526                	mv	a0,s1
    80005184:	ffffe097          	auipc	ra,0xffffe
    80005188:	778080e7          	jalr	1912(ra) # 800038fc <iunlockput>
  return 0;
    8000518c:	bdcd                	j	8000507e <create+0x76>
    return 0;
    8000518e:	8aaa                	mv	s5,a0
    80005190:	b5fd                	j	8000507e <create+0x76>

0000000080005192 <sys_dup>:
{
    80005192:	7179                	addi	sp,sp,-48
    80005194:	f406                	sd	ra,40(sp)
    80005196:	f022                	sd	s0,32(sp)
    80005198:	ec26                	sd	s1,24(sp)
    8000519a:	e84a                	sd	s2,16(sp)
    8000519c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000519e:	fd840613          	addi	a2,s0,-40
    800051a2:	4581                	li	a1,0
    800051a4:	4501                	li	a0,0
    800051a6:	00000097          	auipc	ra,0x0
    800051aa:	dc0080e7          	jalr	-576(ra) # 80004f66 <argfd>
    return -1;
    800051ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051b0:	02054363          	bltz	a0,800051d6 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800051b4:	fd843903          	ld	s2,-40(s0)
    800051b8:	854a                	mv	a0,s2
    800051ba:	00000097          	auipc	ra,0x0
    800051be:	e0c080e7          	jalr	-500(ra) # 80004fc6 <fdalloc>
    800051c2:	84aa                	mv	s1,a0
    return -1;
    800051c4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051c6:	00054863          	bltz	a0,800051d6 <sys_dup+0x44>
  filedup(f);
    800051ca:	854a                	mv	a0,s2
    800051cc:	fffff097          	auipc	ra,0xfffff
    800051d0:	310080e7          	jalr	784(ra) # 800044dc <filedup>
  return fd;
    800051d4:	87a6                	mv	a5,s1
}
    800051d6:	853e                	mv	a0,a5
    800051d8:	70a2                	ld	ra,40(sp)
    800051da:	7402                	ld	s0,32(sp)
    800051dc:	64e2                	ld	s1,24(sp)
    800051de:	6942                	ld	s2,16(sp)
    800051e0:	6145                	addi	sp,sp,48
    800051e2:	8082                	ret

00000000800051e4 <sys_read>:
{
    800051e4:	7179                	addi	sp,sp,-48
    800051e6:	f406                	sd	ra,40(sp)
    800051e8:	f022                	sd	s0,32(sp)
    800051ea:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051ec:	fd840593          	addi	a1,s0,-40
    800051f0:	4505                	li	a0,1
    800051f2:	ffffe097          	auipc	ra,0xffffe
    800051f6:	95e080e7          	jalr	-1698(ra) # 80002b50 <argaddr>
  argint(2, &n);
    800051fa:	fe440593          	addi	a1,s0,-28
    800051fe:	4509                	li	a0,2
    80005200:	ffffe097          	auipc	ra,0xffffe
    80005204:	930080e7          	jalr	-1744(ra) # 80002b30 <argint>
  if(argfd(0, 0, &f) < 0)
    80005208:	fe840613          	addi	a2,s0,-24
    8000520c:	4581                	li	a1,0
    8000520e:	4501                	li	a0,0
    80005210:	00000097          	auipc	ra,0x0
    80005214:	d56080e7          	jalr	-682(ra) # 80004f66 <argfd>
    80005218:	87aa                	mv	a5,a0
    return -1;
    8000521a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000521c:	0007cc63          	bltz	a5,80005234 <sys_read+0x50>
  return fileread(f, p, n);
    80005220:	fe442603          	lw	a2,-28(s0)
    80005224:	fd843583          	ld	a1,-40(s0)
    80005228:	fe843503          	ld	a0,-24(s0)
    8000522c:	fffff097          	auipc	ra,0xfffff
    80005230:	43c080e7          	jalr	1084(ra) # 80004668 <fileread>
}
    80005234:	70a2                	ld	ra,40(sp)
    80005236:	7402                	ld	s0,32(sp)
    80005238:	6145                	addi	sp,sp,48
    8000523a:	8082                	ret

000000008000523c <sys_write>:
{
    8000523c:	7179                	addi	sp,sp,-48
    8000523e:	f406                	sd	ra,40(sp)
    80005240:	f022                	sd	s0,32(sp)
    80005242:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005244:	fd840593          	addi	a1,s0,-40
    80005248:	4505                	li	a0,1
    8000524a:	ffffe097          	auipc	ra,0xffffe
    8000524e:	906080e7          	jalr	-1786(ra) # 80002b50 <argaddr>
  argint(2, &n);
    80005252:	fe440593          	addi	a1,s0,-28
    80005256:	4509                	li	a0,2
    80005258:	ffffe097          	auipc	ra,0xffffe
    8000525c:	8d8080e7          	jalr	-1832(ra) # 80002b30 <argint>
  if(argfd(0, 0, &f) < 0)
    80005260:	fe840613          	addi	a2,s0,-24
    80005264:	4581                	li	a1,0
    80005266:	4501                	li	a0,0
    80005268:	00000097          	auipc	ra,0x0
    8000526c:	cfe080e7          	jalr	-770(ra) # 80004f66 <argfd>
    80005270:	87aa                	mv	a5,a0
    return -1;
    80005272:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005274:	0007cc63          	bltz	a5,8000528c <sys_write+0x50>
  return filewrite(f, p, n);
    80005278:	fe442603          	lw	a2,-28(s0)
    8000527c:	fd843583          	ld	a1,-40(s0)
    80005280:	fe843503          	ld	a0,-24(s0)
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	4a6080e7          	jalr	1190(ra) # 8000472a <filewrite>
}
    8000528c:	70a2                	ld	ra,40(sp)
    8000528e:	7402                	ld	s0,32(sp)
    80005290:	6145                	addi	sp,sp,48
    80005292:	8082                	ret

0000000080005294 <sys_close>:
{
    80005294:	1101                	addi	sp,sp,-32
    80005296:	ec06                	sd	ra,24(sp)
    80005298:	e822                	sd	s0,16(sp)
    8000529a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000529c:	fe040613          	addi	a2,s0,-32
    800052a0:	fec40593          	addi	a1,s0,-20
    800052a4:	4501                	li	a0,0
    800052a6:	00000097          	auipc	ra,0x0
    800052aa:	cc0080e7          	jalr	-832(ra) # 80004f66 <argfd>
    return -1;
    800052ae:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052b0:	02054463          	bltz	a0,800052d8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052b4:	ffffc097          	auipc	ra,0xffffc
    800052b8:	6f8080e7          	jalr	1784(ra) # 800019ac <myproc>
    800052bc:	fec42783          	lw	a5,-20(s0)
    800052c0:	07e9                	addi	a5,a5,26
    800052c2:	078e                	slli	a5,a5,0x3
    800052c4:	953e                	add	a0,a0,a5
    800052c6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800052ca:	fe043503          	ld	a0,-32(s0)
    800052ce:	fffff097          	auipc	ra,0xfffff
    800052d2:	260080e7          	jalr	608(ra) # 8000452e <fileclose>
  return 0;
    800052d6:	4781                	li	a5,0
}
    800052d8:	853e                	mv	a0,a5
    800052da:	60e2                	ld	ra,24(sp)
    800052dc:	6442                	ld	s0,16(sp)
    800052de:	6105                	addi	sp,sp,32
    800052e0:	8082                	ret

00000000800052e2 <sys_fstat>:
{
    800052e2:	1101                	addi	sp,sp,-32
    800052e4:	ec06                	sd	ra,24(sp)
    800052e6:	e822                	sd	s0,16(sp)
    800052e8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800052ea:	fe040593          	addi	a1,s0,-32
    800052ee:	4505                	li	a0,1
    800052f0:	ffffe097          	auipc	ra,0xffffe
    800052f4:	860080e7          	jalr	-1952(ra) # 80002b50 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052f8:	fe840613          	addi	a2,s0,-24
    800052fc:	4581                	li	a1,0
    800052fe:	4501                	li	a0,0
    80005300:	00000097          	auipc	ra,0x0
    80005304:	c66080e7          	jalr	-922(ra) # 80004f66 <argfd>
    80005308:	87aa                	mv	a5,a0
    return -1;
    8000530a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000530c:	0007ca63          	bltz	a5,80005320 <sys_fstat+0x3e>
  return filestat(f, st);
    80005310:	fe043583          	ld	a1,-32(s0)
    80005314:	fe843503          	ld	a0,-24(s0)
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	2de080e7          	jalr	734(ra) # 800045f6 <filestat>
}
    80005320:	60e2                	ld	ra,24(sp)
    80005322:	6442                	ld	s0,16(sp)
    80005324:	6105                	addi	sp,sp,32
    80005326:	8082                	ret

0000000080005328 <sys_link>:
{
    80005328:	7169                	addi	sp,sp,-304
    8000532a:	f606                	sd	ra,296(sp)
    8000532c:	f222                	sd	s0,288(sp)
    8000532e:	ee26                	sd	s1,280(sp)
    80005330:	ea4a                	sd	s2,272(sp)
    80005332:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005334:	08000613          	li	a2,128
    80005338:	ed040593          	addi	a1,s0,-304
    8000533c:	4501                	li	a0,0
    8000533e:	ffffe097          	auipc	ra,0xffffe
    80005342:	832080e7          	jalr	-1998(ra) # 80002b70 <argstr>
    return -1;
    80005346:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005348:	10054e63          	bltz	a0,80005464 <sys_link+0x13c>
    8000534c:	08000613          	li	a2,128
    80005350:	f5040593          	addi	a1,s0,-176
    80005354:	4505                	li	a0,1
    80005356:	ffffe097          	auipc	ra,0xffffe
    8000535a:	81a080e7          	jalr	-2022(ra) # 80002b70 <argstr>
    return -1;
    8000535e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005360:	10054263          	bltz	a0,80005464 <sys_link+0x13c>
  begin_op();
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	d02080e7          	jalr	-766(ra) # 80004066 <begin_op>
  if((ip = namei(old)) == 0){
    8000536c:	ed040513          	addi	a0,s0,-304
    80005370:	fffff097          	auipc	ra,0xfffff
    80005374:	ad6080e7          	jalr	-1322(ra) # 80003e46 <namei>
    80005378:	84aa                	mv	s1,a0
    8000537a:	c551                	beqz	a0,80005406 <sys_link+0xde>
  ilock(ip);
    8000537c:	ffffe097          	auipc	ra,0xffffe
    80005380:	31e080e7          	jalr	798(ra) # 8000369a <ilock>
  if(ip->type == T_DIR){
    80005384:	04449703          	lh	a4,68(s1)
    80005388:	4785                	li	a5,1
    8000538a:	08f70463          	beq	a4,a5,80005412 <sys_link+0xea>
  ip->nlink++;
    8000538e:	04a4d783          	lhu	a5,74(s1)
    80005392:	2785                	addiw	a5,a5,1
    80005394:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005398:	8526                	mv	a0,s1
    8000539a:	ffffe097          	auipc	ra,0xffffe
    8000539e:	234080e7          	jalr	564(ra) # 800035ce <iupdate>
  iunlock(ip);
    800053a2:	8526                	mv	a0,s1
    800053a4:	ffffe097          	auipc	ra,0xffffe
    800053a8:	3b8080e7          	jalr	952(ra) # 8000375c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053ac:	fd040593          	addi	a1,s0,-48
    800053b0:	f5040513          	addi	a0,s0,-176
    800053b4:	fffff097          	auipc	ra,0xfffff
    800053b8:	ab0080e7          	jalr	-1360(ra) # 80003e64 <nameiparent>
    800053bc:	892a                	mv	s2,a0
    800053be:	c935                	beqz	a0,80005432 <sys_link+0x10a>
  ilock(dp);
    800053c0:	ffffe097          	auipc	ra,0xffffe
    800053c4:	2da080e7          	jalr	730(ra) # 8000369a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053c8:	00092703          	lw	a4,0(s2)
    800053cc:	409c                	lw	a5,0(s1)
    800053ce:	04f71d63          	bne	a4,a5,80005428 <sys_link+0x100>
    800053d2:	40d0                	lw	a2,4(s1)
    800053d4:	fd040593          	addi	a1,s0,-48
    800053d8:	854a                	mv	a0,s2
    800053da:	fffff097          	auipc	ra,0xfffff
    800053de:	9ba080e7          	jalr	-1606(ra) # 80003d94 <dirlink>
    800053e2:	04054363          	bltz	a0,80005428 <sys_link+0x100>
  iunlockput(dp);
    800053e6:	854a                	mv	a0,s2
    800053e8:	ffffe097          	auipc	ra,0xffffe
    800053ec:	514080e7          	jalr	1300(ra) # 800038fc <iunlockput>
  iput(ip);
    800053f0:	8526                	mv	a0,s1
    800053f2:	ffffe097          	auipc	ra,0xffffe
    800053f6:	462080e7          	jalr	1122(ra) # 80003854 <iput>
  end_op();
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	cea080e7          	jalr	-790(ra) # 800040e4 <end_op>
  return 0;
    80005402:	4781                	li	a5,0
    80005404:	a085                	j	80005464 <sys_link+0x13c>
    end_op();
    80005406:	fffff097          	auipc	ra,0xfffff
    8000540a:	cde080e7          	jalr	-802(ra) # 800040e4 <end_op>
    return -1;
    8000540e:	57fd                	li	a5,-1
    80005410:	a891                	j	80005464 <sys_link+0x13c>
    iunlockput(ip);
    80005412:	8526                	mv	a0,s1
    80005414:	ffffe097          	auipc	ra,0xffffe
    80005418:	4e8080e7          	jalr	1256(ra) # 800038fc <iunlockput>
    end_op();
    8000541c:	fffff097          	auipc	ra,0xfffff
    80005420:	cc8080e7          	jalr	-824(ra) # 800040e4 <end_op>
    return -1;
    80005424:	57fd                	li	a5,-1
    80005426:	a83d                	j	80005464 <sys_link+0x13c>
    iunlockput(dp);
    80005428:	854a                	mv	a0,s2
    8000542a:	ffffe097          	auipc	ra,0xffffe
    8000542e:	4d2080e7          	jalr	1234(ra) # 800038fc <iunlockput>
  ilock(ip);
    80005432:	8526                	mv	a0,s1
    80005434:	ffffe097          	auipc	ra,0xffffe
    80005438:	266080e7          	jalr	614(ra) # 8000369a <ilock>
  ip->nlink--;
    8000543c:	04a4d783          	lhu	a5,74(s1)
    80005440:	37fd                	addiw	a5,a5,-1
    80005442:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005446:	8526                	mv	a0,s1
    80005448:	ffffe097          	auipc	ra,0xffffe
    8000544c:	186080e7          	jalr	390(ra) # 800035ce <iupdate>
  iunlockput(ip);
    80005450:	8526                	mv	a0,s1
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	4aa080e7          	jalr	1194(ra) # 800038fc <iunlockput>
  end_op();
    8000545a:	fffff097          	auipc	ra,0xfffff
    8000545e:	c8a080e7          	jalr	-886(ra) # 800040e4 <end_op>
  return -1;
    80005462:	57fd                	li	a5,-1
}
    80005464:	853e                	mv	a0,a5
    80005466:	70b2                	ld	ra,296(sp)
    80005468:	7412                	ld	s0,288(sp)
    8000546a:	64f2                	ld	s1,280(sp)
    8000546c:	6952                	ld	s2,272(sp)
    8000546e:	6155                	addi	sp,sp,304
    80005470:	8082                	ret

0000000080005472 <sys_unlink>:
{
    80005472:	7151                	addi	sp,sp,-240
    80005474:	f586                	sd	ra,232(sp)
    80005476:	f1a2                	sd	s0,224(sp)
    80005478:	eda6                	sd	s1,216(sp)
    8000547a:	e9ca                	sd	s2,208(sp)
    8000547c:	e5ce                	sd	s3,200(sp)
    8000547e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005480:	08000613          	li	a2,128
    80005484:	f3040593          	addi	a1,s0,-208
    80005488:	4501                	li	a0,0
    8000548a:	ffffd097          	auipc	ra,0xffffd
    8000548e:	6e6080e7          	jalr	1766(ra) # 80002b70 <argstr>
    80005492:	18054163          	bltz	a0,80005614 <sys_unlink+0x1a2>
  begin_op();
    80005496:	fffff097          	auipc	ra,0xfffff
    8000549a:	bd0080e7          	jalr	-1072(ra) # 80004066 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000549e:	fb040593          	addi	a1,s0,-80
    800054a2:	f3040513          	addi	a0,s0,-208
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	9be080e7          	jalr	-1602(ra) # 80003e64 <nameiparent>
    800054ae:	84aa                	mv	s1,a0
    800054b0:	c979                	beqz	a0,80005586 <sys_unlink+0x114>
  ilock(dp);
    800054b2:	ffffe097          	auipc	ra,0xffffe
    800054b6:	1e8080e7          	jalr	488(ra) # 8000369a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054ba:	00003597          	auipc	a1,0x3
    800054be:	24e58593          	addi	a1,a1,590 # 80008708 <syscalls+0x2a0>
    800054c2:	fb040513          	addi	a0,s0,-80
    800054c6:	ffffe097          	auipc	ra,0xffffe
    800054ca:	69e080e7          	jalr	1694(ra) # 80003b64 <namecmp>
    800054ce:	14050a63          	beqz	a0,80005622 <sys_unlink+0x1b0>
    800054d2:	00003597          	auipc	a1,0x3
    800054d6:	23e58593          	addi	a1,a1,574 # 80008710 <syscalls+0x2a8>
    800054da:	fb040513          	addi	a0,s0,-80
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	686080e7          	jalr	1670(ra) # 80003b64 <namecmp>
    800054e6:	12050e63          	beqz	a0,80005622 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800054ea:	f2c40613          	addi	a2,s0,-212
    800054ee:	fb040593          	addi	a1,s0,-80
    800054f2:	8526                	mv	a0,s1
    800054f4:	ffffe097          	auipc	ra,0xffffe
    800054f8:	68a080e7          	jalr	1674(ra) # 80003b7e <dirlookup>
    800054fc:	892a                	mv	s2,a0
    800054fe:	12050263          	beqz	a0,80005622 <sys_unlink+0x1b0>
  ilock(ip);
    80005502:	ffffe097          	auipc	ra,0xffffe
    80005506:	198080e7          	jalr	408(ra) # 8000369a <ilock>
  if(ip->nlink < 1)
    8000550a:	04a91783          	lh	a5,74(s2)
    8000550e:	08f05263          	blez	a5,80005592 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005512:	04491703          	lh	a4,68(s2)
    80005516:	4785                	li	a5,1
    80005518:	08f70563          	beq	a4,a5,800055a2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000551c:	4641                	li	a2,16
    8000551e:	4581                	li	a1,0
    80005520:	fc040513          	addi	a0,s0,-64
    80005524:	ffffb097          	auipc	ra,0xffffb
    80005528:	7ae080e7          	jalr	1966(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000552c:	4741                	li	a4,16
    8000552e:	f2c42683          	lw	a3,-212(s0)
    80005532:	fc040613          	addi	a2,s0,-64
    80005536:	4581                	li	a1,0
    80005538:	8526                	mv	a0,s1
    8000553a:	ffffe097          	auipc	ra,0xffffe
    8000553e:	50c080e7          	jalr	1292(ra) # 80003a46 <writei>
    80005542:	47c1                	li	a5,16
    80005544:	0af51563          	bne	a0,a5,800055ee <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005548:	04491703          	lh	a4,68(s2)
    8000554c:	4785                	li	a5,1
    8000554e:	0af70863          	beq	a4,a5,800055fe <sys_unlink+0x18c>
  iunlockput(dp);
    80005552:	8526                	mv	a0,s1
    80005554:	ffffe097          	auipc	ra,0xffffe
    80005558:	3a8080e7          	jalr	936(ra) # 800038fc <iunlockput>
  ip->nlink--;
    8000555c:	04a95783          	lhu	a5,74(s2)
    80005560:	37fd                	addiw	a5,a5,-1
    80005562:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005566:	854a                	mv	a0,s2
    80005568:	ffffe097          	auipc	ra,0xffffe
    8000556c:	066080e7          	jalr	102(ra) # 800035ce <iupdate>
  iunlockput(ip);
    80005570:	854a                	mv	a0,s2
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	38a080e7          	jalr	906(ra) # 800038fc <iunlockput>
  end_op();
    8000557a:	fffff097          	auipc	ra,0xfffff
    8000557e:	b6a080e7          	jalr	-1174(ra) # 800040e4 <end_op>
  return 0;
    80005582:	4501                	li	a0,0
    80005584:	a84d                	j	80005636 <sys_unlink+0x1c4>
    end_op();
    80005586:	fffff097          	auipc	ra,0xfffff
    8000558a:	b5e080e7          	jalr	-1186(ra) # 800040e4 <end_op>
    return -1;
    8000558e:	557d                	li	a0,-1
    80005590:	a05d                	j	80005636 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005592:	00003517          	auipc	a0,0x3
    80005596:	18650513          	addi	a0,a0,390 # 80008718 <syscalls+0x2b0>
    8000559a:	ffffb097          	auipc	ra,0xffffb
    8000559e:	fa6080e7          	jalr	-90(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055a2:	04c92703          	lw	a4,76(s2)
    800055a6:	02000793          	li	a5,32
    800055aa:	f6e7f9e3          	bgeu	a5,a4,8000551c <sys_unlink+0xaa>
    800055ae:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055b2:	4741                	li	a4,16
    800055b4:	86ce                	mv	a3,s3
    800055b6:	f1840613          	addi	a2,s0,-232
    800055ba:	4581                	li	a1,0
    800055bc:	854a                	mv	a0,s2
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	390080e7          	jalr	912(ra) # 8000394e <readi>
    800055c6:	47c1                	li	a5,16
    800055c8:	00f51b63          	bne	a0,a5,800055de <sys_unlink+0x16c>
    if(de.inum != 0)
    800055cc:	f1845783          	lhu	a5,-232(s0)
    800055d0:	e7a1                	bnez	a5,80005618 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055d2:	29c1                	addiw	s3,s3,16
    800055d4:	04c92783          	lw	a5,76(s2)
    800055d8:	fcf9ede3          	bltu	s3,a5,800055b2 <sys_unlink+0x140>
    800055dc:	b781                	j	8000551c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800055de:	00003517          	auipc	a0,0x3
    800055e2:	15250513          	addi	a0,a0,338 # 80008730 <syscalls+0x2c8>
    800055e6:	ffffb097          	auipc	ra,0xffffb
    800055ea:	f5a080e7          	jalr	-166(ra) # 80000540 <panic>
    panic("unlink: writei");
    800055ee:	00003517          	auipc	a0,0x3
    800055f2:	15a50513          	addi	a0,a0,346 # 80008748 <syscalls+0x2e0>
    800055f6:	ffffb097          	auipc	ra,0xffffb
    800055fa:	f4a080e7          	jalr	-182(ra) # 80000540 <panic>
    dp->nlink--;
    800055fe:	04a4d783          	lhu	a5,74(s1)
    80005602:	37fd                	addiw	a5,a5,-1
    80005604:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005608:	8526                	mv	a0,s1
    8000560a:	ffffe097          	auipc	ra,0xffffe
    8000560e:	fc4080e7          	jalr	-60(ra) # 800035ce <iupdate>
    80005612:	b781                	j	80005552 <sys_unlink+0xe0>
    return -1;
    80005614:	557d                	li	a0,-1
    80005616:	a005                	j	80005636 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005618:	854a                	mv	a0,s2
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	2e2080e7          	jalr	738(ra) # 800038fc <iunlockput>
  iunlockput(dp);
    80005622:	8526                	mv	a0,s1
    80005624:	ffffe097          	auipc	ra,0xffffe
    80005628:	2d8080e7          	jalr	728(ra) # 800038fc <iunlockput>
  end_op();
    8000562c:	fffff097          	auipc	ra,0xfffff
    80005630:	ab8080e7          	jalr	-1352(ra) # 800040e4 <end_op>
  return -1;
    80005634:	557d                	li	a0,-1
}
    80005636:	70ae                	ld	ra,232(sp)
    80005638:	740e                	ld	s0,224(sp)
    8000563a:	64ee                	ld	s1,216(sp)
    8000563c:	694e                	ld	s2,208(sp)
    8000563e:	69ae                	ld	s3,200(sp)
    80005640:	616d                	addi	sp,sp,240
    80005642:	8082                	ret

0000000080005644 <sys_open>:

uint64
sys_open(void)
{
    80005644:	7131                	addi	sp,sp,-192
    80005646:	fd06                	sd	ra,184(sp)
    80005648:	f922                	sd	s0,176(sp)
    8000564a:	f526                	sd	s1,168(sp)
    8000564c:	f14a                	sd	s2,160(sp)
    8000564e:	ed4e                	sd	s3,152(sp)
    80005650:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005652:	f4c40593          	addi	a1,s0,-180
    80005656:	4505                	li	a0,1
    80005658:	ffffd097          	auipc	ra,0xffffd
    8000565c:	4d8080e7          	jalr	1240(ra) # 80002b30 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005660:	08000613          	li	a2,128
    80005664:	f5040593          	addi	a1,s0,-176
    80005668:	4501                	li	a0,0
    8000566a:	ffffd097          	auipc	ra,0xffffd
    8000566e:	506080e7          	jalr	1286(ra) # 80002b70 <argstr>
    80005672:	87aa                	mv	a5,a0
    return -1;
    80005674:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005676:	0a07c963          	bltz	a5,80005728 <sys_open+0xe4>

  begin_op();
    8000567a:	fffff097          	auipc	ra,0xfffff
    8000567e:	9ec080e7          	jalr	-1556(ra) # 80004066 <begin_op>

  if(omode & O_CREATE){
    80005682:	f4c42783          	lw	a5,-180(s0)
    80005686:	2007f793          	andi	a5,a5,512
    8000568a:	cfc5                	beqz	a5,80005742 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000568c:	4681                	li	a3,0
    8000568e:	4601                	li	a2,0
    80005690:	4589                	li	a1,2
    80005692:	f5040513          	addi	a0,s0,-176
    80005696:	00000097          	auipc	ra,0x0
    8000569a:	972080e7          	jalr	-1678(ra) # 80005008 <create>
    8000569e:	84aa                	mv	s1,a0
    if(ip == 0){
    800056a0:	c959                	beqz	a0,80005736 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056a2:	04449703          	lh	a4,68(s1)
    800056a6:	478d                	li	a5,3
    800056a8:	00f71763          	bne	a4,a5,800056b6 <sys_open+0x72>
    800056ac:	0464d703          	lhu	a4,70(s1)
    800056b0:	47a5                	li	a5,9
    800056b2:	0ce7ed63          	bltu	a5,a4,8000578c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056b6:	fffff097          	auipc	ra,0xfffff
    800056ba:	dbc080e7          	jalr	-580(ra) # 80004472 <filealloc>
    800056be:	89aa                	mv	s3,a0
    800056c0:	10050363          	beqz	a0,800057c6 <sys_open+0x182>
    800056c4:	00000097          	auipc	ra,0x0
    800056c8:	902080e7          	jalr	-1790(ra) # 80004fc6 <fdalloc>
    800056cc:	892a                	mv	s2,a0
    800056ce:	0e054763          	bltz	a0,800057bc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056d2:	04449703          	lh	a4,68(s1)
    800056d6:	478d                	li	a5,3
    800056d8:	0cf70563          	beq	a4,a5,800057a2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056dc:	4789                	li	a5,2
    800056de:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800056e2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800056e6:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800056ea:	f4c42783          	lw	a5,-180(s0)
    800056ee:	0017c713          	xori	a4,a5,1
    800056f2:	8b05                	andi	a4,a4,1
    800056f4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800056f8:	0037f713          	andi	a4,a5,3
    800056fc:	00e03733          	snez	a4,a4
    80005700:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005704:	4007f793          	andi	a5,a5,1024
    80005708:	c791                	beqz	a5,80005714 <sys_open+0xd0>
    8000570a:	04449703          	lh	a4,68(s1)
    8000570e:	4789                	li	a5,2
    80005710:	0af70063          	beq	a4,a5,800057b0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005714:	8526                	mv	a0,s1
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	046080e7          	jalr	70(ra) # 8000375c <iunlock>
  end_op();
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	9c6080e7          	jalr	-1594(ra) # 800040e4 <end_op>

  return fd;
    80005726:	854a                	mv	a0,s2
}
    80005728:	70ea                	ld	ra,184(sp)
    8000572a:	744a                	ld	s0,176(sp)
    8000572c:	74aa                	ld	s1,168(sp)
    8000572e:	790a                	ld	s2,160(sp)
    80005730:	69ea                	ld	s3,152(sp)
    80005732:	6129                	addi	sp,sp,192
    80005734:	8082                	ret
      end_op();
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	9ae080e7          	jalr	-1618(ra) # 800040e4 <end_op>
      return -1;
    8000573e:	557d                	li	a0,-1
    80005740:	b7e5                	j	80005728 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005742:	f5040513          	addi	a0,s0,-176
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	700080e7          	jalr	1792(ra) # 80003e46 <namei>
    8000574e:	84aa                	mv	s1,a0
    80005750:	c905                	beqz	a0,80005780 <sys_open+0x13c>
    ilock(ip);
    80005752:	ffffe097          	auipc	ra,0xffffe
    80005756:	f48080e7          	jalr	-184(ra) # 8000369a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000575a:	04449703          	lh	a4,68(s1)
    8000575e:	4785                	li	a5,1
    80005760:	f4f711e3          	bne	a4,a5,800056a2 <sys_open+0x5e>
    80005764:	f4c42783          	lw	a5,-180(s0)
    80005768:	d7b9                	beqz	a5,800056b6 <sys_open+0x72>
      iunlockput(ip);
    8000576a:	8526                	mv	a0,s1
    8000576c:	ffffe097          	auipc	ra,0xffffe
    80005770:	190080e7          	jalr	400(ra) # 800038fc <iunlockput>
      end_op();
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	970080e7          	jalr	-1680(ra) # 800040e4 <end_op>
      return -1;
    8000577c:	557d                	li	a0,-1
    8000577e:	b76d                	j	80005728 <sys_open+0xe4>
      end_op();
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	964080e7          	jalr	-1692(ra) # 800040e4 <end_op>
      return -1;
    80005788:	557d                	li	a0,-1
    8000578a:	bf79                	j	80005728 <sys_open+0xe4>
    iunlockput(ip);
    8000578c:	8526                	mv	a0,s1
    8000578e:	ffffe097          	auipc	ra,0xffffe
    80005792:	16e080e7          	jalr	366(ra) # 800038fc <iunlockput>
    end_op();
    80005796:	fffff097          	auipc	ra,0xfffff
    8000579a:	94e080e7          	jalr	-1714(ra) # 800040e4 <end_op>
    return -1;
    8000579e:	557d                	li	a0,-1
    800057a0:	b761                	j	80005728 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057a2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057a6:	04649783          	lh	a5,70(s1)
    800057aa:	02f99223          	sh	a5,36(s3)
    800057ae:	bf25                	j	800056e6 <sys_open+0xa2>
    itrunc(ip);
    800057b0:	8526                	mv	a0,s1
    800057b2:	ffffe097          	auipc	ra,0xffffe
    800057b6:	ff6080e7          	jalr	-10(ra) # 800037a8 <itrunc>
    800057ba:	bfa9                	j	80005714 <sys_open+0xd0>
      fileclose(f);
    800057bc:	854e                	mv	a0,s3
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	d70080e7          	jalr	-656(ra) # 8000452e <fileclose>
    iunlockput(ip);
    800057c6:	8526                	mv	a0,s1
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	134080e7          	jalr	308(ra) # 800038fc <iunlockput>
    end_op();
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	914080e7          	jalr	-1772(ra) # 800040e4 <end_op>
    return -1;
    800057d8:	557d                	li	a0,-1
    800057da:	b7b9                	j	80005728 <sys_open+0xe4>

00000000800057dc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057dc:	7175                	addi	sp,sp,-144
    800057de:	e506                	sd	ra,136(sp)
    800057e0:	e122                	sd	s0,128(sp)
    800057e2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800057e4:	fffff097          	auipc	ra,0xfffff
    800057e8:	882080e7          	jalr	-1918(ra) # 80004066 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057ec:	08000613          	li	a2,128
    800057f0:	f7040593          	addi	a1,s0,-144
    800057f4:	4501                	li	a0,0
    800057f6:	ffffd097          	auipc	ra,0xffffd
    800057fa:	37a080e7          	jalr	890(ra) # 80002b70 <argstr>
    800057fe:	02054963          	bltz	a0,80005830 <sys_mkdir+0x54>
    80005802:	4681                	li	a3,0
    80005804:	4601                	li	a2,0
    80005806:	4585                	li	a1,1
    80005808:	f7040513          	addi	a0,s0,-144
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	7fc080e7          	jalr	2044(ra) # 80005008 <create>
    80005814:	cd11                	beqz	a0,80005830 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	0e6080e7          	jalr	230(ra) # 800038fc <iunlockput>
  end_op();
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	8c6080e7          	jalr	-1850(ra) # 800040e4 <end_op>
  return 0;
    80005826:	4501                	li	a0,0
}
    80005828:	60aa                	ld	ra,136(sp)
    8000582a:	640a                	ld	s0,128(sp)
    8000582c:	6149                	addi	sp,sp,144
    8000582e:	8082                	ret
    end_op();
    80005830:	fffff097          	auipc	ra,0xfffff
    80005834:	8b4080e7          	jalr	-1868(ra) # 800040e4 <end_op>
    return -1;
    80005838:	557d                	li	a0,-1
    8000583a:	b7fd                	j	80005828 <sys_mkdir+0x4c>

000000008000583c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000583c:	7135                	addi	sp,sp,-160
    8000583e:	ed06                	sd	ra,152(sp)
    80005840:	e922                	sd	s0,144(sp)
    80005842:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005844:	fffff097          	auipc	ra,0xfffff
    80005848:	822080e7          	jalr	-2014(ra) # 80004066 <begin_op>
  argint(1, &major);
    8000584c:	f6c40593          	addi	a1,s0,-148
    80005850:	4505                	li	a0,1
    80005852:	ffffd097          	auipc	ra,0xffffd
    80005856:	2de080e7          	jalr	734(ra) # 80002b30 <argint>
  argint(2, &minor);
    8000585a:	f6840593          	addi	a1,s0,-152
    8000585e:	4509                	li	a0,2
    80005860:	ffffd097          	auipc	ra,0xffffd
    80005864:	2d0080e7          	jalr	720(ra) # 80002b30 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005868:	08000613          	li	a2,128
    8000586c:	f7040593          	addi	a1,s0,-144
    80005870:	4501                	li	a0,0
    80005872:	ffffd097          	auipc	ra,0xffffd
    80005876:	2fe080e7          	jalr	766(ra) # 80002b70 <argstr>
    8000587a:	02054b63          	bltz	a0,800058b0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000587e:	f6841683          	lh	a3,-152(s0)
    80005882:	f6c41603          	lh	a2,-148(s0)
    80005886:	458d                	li	a1,3
    80005888:	f7040513          	addi	a0,s0,-144
    8000588c:	fffff097          	auipc	ra,0xfffff
    80005890:	77c080e7          	jalr	1916(ra) # 80005008 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005894:	cd11                	beqz	a0,800058b0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	066080e7          	jalr	102(ra) # 800038fc <iunlockput>
  end_op();
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	846080e7          	jalr	-1978(ra) # 800040e4 <end_op>
  return 0;
    800058a6:	4501                	li	a0,0
}
    800058a8:	60ea                	ld	ra,152(sp)
    800058aa:	644a                	ld	s0,144(sp)
    800058ac:	610d                	addi	sp,sp,160
    800058ae:	8082                	ret
    end_op();
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	834080e7          	jalr	-1996(ra) # 800040e4 <end_op>
    return -1;
    800058b8:	557d                	li	a0,-1
    800058ba:	b7fd                	j	800058a8 <sys_mknod+0x6c>

00000000800058bc <sys_chdir>:

uint64
sys_chdir(void)
{
    800058bc:	7135                	addi	sp,sp,-160
    800058be:	ed06                	sd	ra,152(sp)
    800058c0:	e922                	sd	s0,144(sp)
    800058c2:	e526                	sd	s1,136(sp)
    800058c4:	e14a                	sd	s2,128(sp)
    800058c6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058c8:	ffffc097          	auipc	ra,0xffffc
    800058cc:	0e4080e7          	jalr	228(ra) # 800019ac <myproc>
    800058d0:	892a                	mv	s2,a0
  
  begin_op();
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	794080e7          	jalr	1940(ra) # 80004066 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800058da:	08000613          	li	a2,128
    800058de:	f6040593          	addi	a1,s0,-160
    800058e2:	4501                	li	a0,0
    800058e4:	ffffd097          	auipc	ra,0xffffd
    800058e8:	28c080e7          	jalr	652(ra) # 80002b70 <argstr>
    800058ec:	04054b63          	bltz	a0,80005942 <sys_chdir+0x86>
    800058f0:	f6040513          	addi	a0,s0,-160
    800058f4:	ffffe097          	auipc	ra,0xffffe
    800058f8:	552080e7          	jalr	1362(ra) # 80003e46 <namei>
    800058fc:	84aa                	mv	s1,a0
    800058fe:	c131                	beqz	a0,80005942 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	d9a080e7          	jalr	-614(ra) # 8000369a <ilock>
  if(ip->type != T_DIR){
    80005908:	04449703          	lh	a4,68(s1)
    8000590c:	4785                	li	a5,1
    8000590e:	04f71063          	bne	a4,a5,8000594e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005912:	8526                	mv	a0,s1
    80005914:	ffffe097          	auipc	ra,0xffffe
    80005918:	e48080e7          	jalr	-440(ra) # 8000375c <iunlock>
  iput(p->cwd);
    8000591c:	15093503          	ld	a0,336(s2)
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	f34080e7          	jalr	-204(ra) # 80003854 <iput>
  end_op();
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	7bc080e7          	jalr	1980(ra) # 800040e4 <end_op>
  p->cwd = ip;
    80005930:	14993823          	sd	s1,336(s2)
  return 0;
    80005934:	4501                	li	a0,0
}
    80005936:	60ea                	ld	ra,152(sp)
    80005938:	644a                	ld	s0,144(sp)
    8000593a:	64aa                	ld	s1,136(sp)
    8000593c:	690a                	ld	s2,128(sp)
    8000593e:	610d                	addi	sp,sp,160
    80005940:	8082                	ret
    end_op();
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	7a2080e7          	jalr	1954(ra) # 800040e4 <end_op>
    return -1;
    8000594a:	557d                	li	a0,-1
    8000594c:	b7ed                	j	80005936 <sys_chdir+0x7a>
    iunlockput(ip);
    8000594e:	8526                	mv	a0,s1
    80005950:	ffffe097          	auipc	ra,0xffffe
    80005954:	fac080e7          	jalr	-84(ra) # 800038fc <iunlockput>
    end_op();
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	78c080e7          	jalr	1932(ra) # 800040e4 <end_op>
    return -1;
    80005960:	557d                	li	a0,-1
    80005962:	bfd1                	j	80005936 <sys_chdir+0x7a>

0000000080005964 <sys_exec>:

uint64
sys_exec(void)
{
    80005964:	7145                	addi	sp,sp,-464
    80005966:	e786                	sd	ra,456(sp)
    80005968:	e3a2                	sd	s0,448(sp)
    8000596a:	ff26                	sd	s1,440(sp)
    8000596c:	fb4a                	sd	s2,432(sp)
    8000596e:	f74e                	sd	s3,424(sp)
    80005970:	f352                	sd	s4,416(sp)
    80005972:	ef56                	sd	s5,408(sp)
    80005974:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005976:	e3840593          	addi	a1,s0,-456
    8000597a:	4505                	li	a0,1
    8000597c:	ffffd097          	auipc	ra,0xffffd
    80005980:	1d4080e7          	jalr	468(ra) # 80002b50 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005984:	08000613          	li	a2,128
    80005988:	f4040593          	addi	a1,s0,-192
    8000598c:	4501                	li	a0,0
    8000598e:	ffffd097          	auipc	ra,0xffffd
    80005992:	1e2080e7          	jalr	482(ra) # 80002b70 <argstr>
    80005996:	87aa                	mv	a5,a0
    return -1;
    80005998:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000599a:	0c07c363          	bltz	a5,80005a60 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    8000599e:	10000613          	li	a2,256
    800059a2:	4581                	li	a1,0
    800059a4:	e4040513          	addi	a0,s0,-448
    800059a8:	ffffb097          	auipc	ra,0xffffb
    800059ac:	32a080e7          	jalr	810(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059b0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800059b4:	89a6                	mv	s3,s1
    800059b6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800059b8:	02000a13          	li	s4,32
    800059bc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059c0:	00391513          	slli	a0,s2,0x3
    800059c4:	e3040593          	addi	a1,s0,-464
    800059c8:	e3843783          	ld	a5,-456(s0)
    800059cc:	953e                	add	a0,a0,a5
    800059ce:	ffffd097          	auipc	ra,0xffffd
    800059d2:	0c4080e7          	jalr	196(ra) # 80002a92 <fetchaddr>
    800059d6:	02054a63          	bltz	a0,80005a0a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800059da:	e3043783          	ld	a5,-464(s0)
    800059de:	c3b9                	beqz	a5,80005a24 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800059e0:	ffffb097          	auipc	ra,0xffffb
    800059e4:	106080e7          	jalr	262(ra) # 80000ae6 <kalloc>
    800059e8:	85aa                	mv	a1,a0
    800059ea:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800059ee:	cd11                	beqz	a0,80005a0a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800059f0:	6605                	lui	a2,0x1
    800059f2:	e3043503          	ld	a0,-464(s0)
    800059f6:	ffffd097          	auipc	ra,0xffffd
    800059fa:	0ee080e7          	jalr	238(ra) # 80002ae4 <fetchstr>
    800059fe:	00054663          	bltz	a0,80005a0a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005a02:	0905                	addi	s2,s2,1
    80005a04:	09a1                	addi	s3,s3,8
    80005a06:	fb491be3          	bne	s2,s4,800059bc <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a0a:	f4040913          	addi	s2,s0,-192
    80005a0e:	6088                	ld	a0,0(s1)
    80005a10:	c539                	beqz	a0,80005a5e <sys_exec+0xfa>
    kfree(argv[i]);
    80005a12:	ffffb097          	auipc	ra,0xffffb
    80005a16:	fd6080e7          	jalr	-42(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a1a:	04a1                	addi	s1,s1,8
    80005a1c:	ff2499e3          	bne	s1,s2,80005a0e <sys_exec+0xaa>
  return -1;
    80005a20:	557d                	li	a0,-1
    80005a22:	a83d                	j	80005a60 <sys_exec+0xfc>
      argv[i] = 0;
    80005a24:	0a8e                	slli	s5,s5,0x3
    80005a26:	fc0a8793          	addi	a5,s5,-64
    80005a2a:	00878ab3          	add	s5,a5,s0
    80005a2e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a32:	e4040593          	addi	a1,s0,-448
    80005a36:	f4040513          	addi	a0,s0,-192
    80005a3a:	fffff097          	auipc	ra,0xfffff
    80005a3e:	16e080e7          	jalr	366(ra) # 80004ba8 <exec>
    80005a42:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a44:	f4040993          	addi	s3,s0,-192
    80005a48:	6088                	ld	a0,0(s1)
    80005a4a:	c901                	beqz	a0,80005a5a <sys_exec+0xf6>
    kfree(argv[i]);
    80005a4c:	ffffb097          	auipc	ra,0xffffb
    80005a50:	f9c080e7          	jalr	-100(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a54:	04a1                	addi	s1,s1,8
    80005a56:	ff3499e3          	bne	s1,s3,80005a48 <sys_exec+0xe4>
  return ret;
    80005a5a:	854a                	mv	a0,s2
    80005a5c:	a011                	j	80005a60 <sys_exec+0xfc>
  return -1;
    80005a5e:	557d                	li	a0,-1
}
    80005a60:	60be                	ld	ra,456(sp)
    80005a62:	641e                	ld	s0,448(sp)
    80005a64:	74fa                	ld	s1,440(sp)
    80005a66:	795a                	ld	s2,432(sp)
    80005a68:	79ba                	ld	s3,424(sp)
    80005a6a:	7a1a                	ld	s4,416(sp)
    80005a6c:	6afa                	ld	s5,408(sp)
    80005a6e:	6179                	addi	sp,sp,464
    80005a70:	8082                	ret

0000000080005a72 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a72:	7139                	addi	sp,sp,-64
    80005a74:	fc06                	sd	ra,56(sp)
    80005a76:	f822                	sd	s0,48(sp)
    80005a78:	f426                	sd	s1,40(sp)
    80005a7a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a7c:	ffffc097          	auipc	ra,0xffffc
    80005a80:	f30080e7          	jalr	-208(ra) # 800019ac <myproc>
    80005a84:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a86:	fd840593          	addi	a1,s0,-40
    80005a8a:	4501                	li	a0,0
    80005a8c:	ffffd097          	auipc	ra,0xffffd
    80005a90:	0c4080e7          	jalr	196(ra) # 80002b50 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005a94:	fc840593          	addi	a1,s0,-56
    80005a98:	fd040513          	addi	a0,s0,-48
    80005a9c:	fffff097          	auipc	ra,0xfffff
    80005aa0:	dc2080e7          	jalr	-574(ra) # 8000485e <pipealloc>
    return -1;
    80005aa4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005aa6:	0c054463          	bltz	a0,80005b6e <sys_pipe+0xfc>
  fd0 = -1;
    80005aaa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005aae:	fd043503          	ld	a0,-48(s0)
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	514080e7          	jalr	1300(ra) # 80004fc6 <fdalloc>
    80005aba:	fca42223          	sw	a0,-60(s0)
    80005abe:	08054b63          	bltz	a0,80005b54 <sys_pipe+0xe2>
    80005ac2:	fc843503          	ld	a0,-56(s0)
    80005ac6:	fffff097          	auipc	ra,0xfffff
    80005aca:	500080e7          	jalr	1280(ra) # 80004fc6 <fdalloc>
    80005ace:	fca42023          	sw	a0,-64(s0)
    80005ad2:	06054863          	bltz	a0,80005b42 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ad6:	4691                	li	a3,4
    80005ad8:	fc440613          	addi	a2,s0,-60
    80005adc:	fd843583          	ld	a1,-40(s0)
    80005ae0:	68a8                	ld	a0,80(s1)
    80005ae2:	ffffc097          	auipc	ra,0xffffc
    80005ae6:	b8a080e7          	jalr	-1142(ra) # 8000166c <copyout>
    80005aea:	02054063          	bltz	a0,80005b0a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005aee:	4691                	li	a3,4
    80005af0:	fc040613          	addi	a2,s0,-64
    80005af4:	fd843583          	ld	a1,-40(s0)
    80005af8:	0591                	addi	a1,a1,4
    80005afa:	68a8                	ld	a0,80(s1)
    80005afc:	ffffc097          	auipc	ra,0xffffc
    80005b00:	b70080e7          	jalr	-1168(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b04:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b06:	06055463          	bgez	a0,80005b6e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b0a:	fc442783          	lw	a5,-60(s0)
    80005b0e:	07e9                	addi	a5,a5,26
    80005b10:	078e                	slli	a5,a5,0x3
    80005b12:	97a6                	add	a5,a5,s1
    80005b14:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b18:	fc042783          	lw	a5,-64(s0)
    80005b1c:	07e9                	addi	a5,a5,26
    80005b1e:	078e                	slli	a5,a5,0x3
    80005b20:	94be                	add	s1,s1,a5
    80005b22:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b26:	fd043503          	ld	a0,-48(s0)
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	a04080e7          	jalr	-1532(ra) # 8000452e <fileclose>
    fileclose(wf);
    80005b32:	fc843503          	ld	a0,-56(s0)
    80005b36:	fffff097          	auipc	ra,0xfffff
    80005b3a:	9f8080e7          	jalr	-1544(ra) # 8000452e <fileclose>
    return -1;
    80005b3e:	57fd                	li	a5,-1
    80005b40:	a03d                	j	80005b6e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005b42:	fc442783          	lw	a5,-60(s0)
    80005b46:	0007c763          	bltz	a5,80005b54 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005b4a:	07e9                	addi	a5,a5,26
    80005b4c:	078e                	slli	a5,a5,0x3
    80005b4e:	97a6                	add	a5,a5,s1
    80005b50:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005b54:	fd043503          	ld	a0,-48(s0)
    80005b58:	fffff097          	auipc	ra,0xfffff
    80005b5c:	9d6080e7          	jalr	-1578(ra) # 8000452e <fileclose>
    fileclose(wf);
    80005b60:	fc843503          	ld	a0,-56(s0)
    80005b64:	fffff097          	auipc	ra,0xfffff
    80005b68:	9ca080e7          	jalr	-1590(ra) # 8000452e <fileclose>
    return -1;
    80005b6c:	57fd                	li	a5,-1
}
    80005b6e:	853e                	mv	a0,a5
    80005b70:	70e2                	ld	ra,56(sp)
    80005b72:	7442                	ld	s0,48(sp)
    80005b74:	74a2                	ld	s1,40(sp)
    80005b76:	6121                	addi	sp,sp,64
    80005b78:	8082                	ret
    80005b7a:	0000                	unimp
    80005b7c:	0000                	unimp
	...

0000000080005b80 <kernelvec>:
    80005b80:	7111                	addi	sp,sp,-256
    80005b82:	e006                	sd	ra,0(sp)
    80005b84:	e40a                	sd	sp,8(sp)
    80005b86:	e80e                	sd	gp,16(sp)
    80005b88:	ec12                	sd	tp,24(sp)
    80005b8a:	f016                	sd	t0,32(sp)
    80005b8c:	f41a                	sd	t1,40(sp)
    80005b8e:	f81e                	sd	t2,48(sp)
    80005b90:	fc22                	sd	s0,56(sp)
    80005b92:	e0a6                	sd	s1,64(sp)
    80005b94:	e4aa                	sd	a0,72(sp)
    80005b96:	e8ae                	sd	a1,80(sp)
    80005b98:	ecb2                	sd	a2,88(sp)
    80005b9a:	f0b6                	sd	a3,96(sp)
    80005b9c:	f4ba                	sd	a4,104(sp)
    80005b9e:	f8be                	sd	a5,112(sp)
    80005ba0:	fcc2                	sd	a6,120(sp)
    80005ba2:	e146                	sd	a7,128(sp)
    80005ba4:	e54a                	sd	s2,136(sp)
    80005ba6:	e94e                	sd	s3,144(sp)
    80005ba8:	ed52                	sd	s4,152(sp)
    80005baa:	f156                	sd	s5,160(sp)
    80005bac:	f55a                	sd	s6,168(sp)
    80005bae:	f95e                	sd	s7,176(sp)
    80005bb0:	fd62                	sd	s8,184(sp)
    80005bb2:	e1e6                	sd	s9,192(sp)
    80005bb4:	e5ea                	sd	s10,200(sp)
    80005bb6:	e9ee                	sd	s11,208(sp)
    80005bb8:	edf2                	sd	t3,216(sp)
    80005bba:	f1f6                	sd	t4,224(sp)
    80005bbc:	f5fa                	sd	t5,232(sp)
    80005bbe:	f9fe                	sd	t6,240(sp)
    80005bc0:	d9ffc0ef          	jal	ra,8000295e <kerneltrap>
    80005bc4:	6082                	ld	ra,0(sp)
    80005bc6:	6122                	ld	sp,8(sp)
    80005bc8:	61c2                	ld	gp,16(sp)
    80005bca:	7282                	ld	t0,32(sp)
    80005bcc:	7322                	ld	t1,40(sp)
    80005bce:	73c2                	ld	t2,48(sp)
    80005bd0:	7462                	ld	s0,56(sp)
    80005bd2:	6486                	ld	s1,64(sp)
    80005bd4:	6526                	ld	a0,72(sp)
    80005bd6:	65c6                	ld	a1,80(sp)
    80005bd8:	6666                	ld	a2,88(sp)
    80005bda:	7686                	ld	a3,96(sp)
    80005bdc:	7726                	ld	a4,104(sp)
    80005bde:	77c6                	ld	a5,112(sp)
    80005be0:	7866                	ld	a6,120(sp)
    80005be2:	688a                	ld	a7,128(sp)
    80005be4:	692a                	ld	s2,136(sp)
    80005be6:	69ca                	ld	s3,144(sp)
    80005be8:	6a6a                	ld	s4,152(sp)
    80005bea:	7a8a                	ld	s5,160(sp)
    80005bec:	7b2a                	ld	s6,168(sp)
    80005bee:	7bca                	ld	s7,176(sp)
    80005bf0:	7c6a                	ld	s8,184(sp)
    80005bf2:	6c8e                	ld	s9,192(sp)
    80005bf4:	6d2e                	ld	s10,200(sp)
    80005bf6:	6dce                	ld	s11,208(sp)
    80005bf8:	6e6e                	ld	t3,216(sp)
    80005bfa:	7e8e                	ld	t4,224(sp)
    80005bfc:	7f2e                	ld	t5,232(sp)
    80005bfe:	7fce                	ld	t6,240(sp)
    80005c00:	6111                	addi	sp,sp,256
    80005c02:	10200073          	sret
    80005c06:	00000013          	nop
    80005c0a:	00000013          	nop
    80005c0e:	0001                	nop

0000000080005c10 <timervec>:
    80005c10:	34051573          	csrrw	a0,mscratch,a0
    80005c14:	e10c                	sd	a1,0(a0)
    80005c16:	e510                	sd	a2,8(a0)
    80005c18:	e914                	sd	a3,16(a0)
    80005c1a:	6d0c                	ld	a1,24(a0)
    80005c1c:	7110                	ld	a2,32(a0)
    80005c1e:	6194                	ld	a3,0(a1)
    80005c20:	96b2                	add	a3,a3,a2
    80005c22:	e194                	sd	a3,0(a1)
    80005c24:	4589                	li	a1,2
    80005c26:	14459073          	csrw	sip,a1
    80005c2a:	6914                	ld	a3,16(a0)
    80005c2c:	6510                	ld	a2,8(a0)
    80005c2e:	610c                	ld	a1,0(a0)
    80005c30:	34051573          	csrrw	a0,mscratch,a0
    80005c34:	30200073          	mret
	...

0000000080005c3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c3a:	1141                	addi	sp,sp,-16
    80005c3c:	e422                	sd	s0,8(sp)
    80005c3e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c40:	0c0007b7          	lui	a5,0xc000
    80005c44:	4705                	li	a4,1
    80005c46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c48:	c3d8                	sw	a4,4(a5)
}
    80005c4a:	6422                	ld	s0,8(sp)
    80005c4c:	0141                	addi	sp,sp,16
    80005c4e:	8082                	ret

0000000080005c50 <plicinithart>:

void
plicinithart(void)
{
    80005c50:	1141                	addi	sp,sp,-16
    80005c52:	e406                	sd	ra,8(sp)
    80005c54:	e022                	sd	s0,0(sp)
    80005c56:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c58:	ffffc097          	auipc	ra,0xffffc
    80005c5c:	d28080e7          	jalr	-728(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c60:	0085171b          	slliw	a4,a0,0x8
    80005c64:	0c0027b7          	lui	a5,0xc002
    80005c68:	97ba                	add	a5,a5,a4
    80005c6a:	40200713          	li	a4,1026
    80005c6e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c72:	00d5151b          	slliw	a0,a0,0xd
    80005c76:	0c2017b7          	lui	a5,0xc201
    80005c7a:	97aa                	add	a5,a5,a0
    80005c7c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005c80:	60a2                	ld	ra,8(sp)
    80005c82:	6402                	ld	s0,0(sp)
    80005c84:	0141                	addi	sp,sp,16
    80005c86:	8082                	ret

0000000080005c88 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c88:	1141                	addi	sp,sp,-16
    80005c8a:	e406                	sd	ra,8(sp)
    80005c8c:	e022                	sd	s0,0(sp)
    80005c8e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c90:	ffffc097          	auipc	ra,0xffffc
    80005c94:	cf0080e7          	jalr	-784(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c98:	00d5151b          	slliw	a0,a0,0xd
    80005c9c:	0c2017b7          	lui	a5,0xc201
    80005ca0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ca2:	43c8                	lw	a0,4(a5)
    80005ca4:	60a2                	ld	ra,8(sp)
    80005ca6:	6402                	ld	s0,0(sp)
    80005ca8:	0141                	addi	sp,sp,16
    80005caa:	8082                	ret

0000000080005cac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005cac:	1101                	addi	sp,sp,-32
    80005cae:	ec06                	sd	ra,24(sp)
    80005cb0:	e822                	sd	s0,16(sp)
    80005cb2:	e426                	sd	s1,8(sp)
    80005cb4:	1000                	addi	s0,sp,32
    80005cb6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005cb8:	ffffc097          	auipc	ra,0xffffc
    80005cbc:	cc8080e7          	jalr	-824(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005cc0:	00d5151b          	slliw	a0,a0,0xd
    80005cc4:	0c2017b7          	lui	a5,0xc201
    80005cc8:	97aa                	add	a5,a5,a0
    80005cca:	c3c4                	sw	s1,4(a5)
}
    80005ccc:	60e2                	ld	ra,24(sp)
    80005cce:	6442                	ld	s0,16(sp)
    80005cd0:	64a2                	ld	s1,8(sp)
    80005cd2:	6105                	addi	sp,sp,32
    80005cd4:	8082                	ret

0000000080005cd6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005cd6:	1141                	addi	sp,sp,-16
    80005cd8:	e406                	sd	ra,8(sp)
    80005cda:	e022                	sd	s0,0(sp)
    80005cdc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005cde:	479d                	li	a5,7
    80005ce0:	04a7cc63          	blt	a5,a0,80005d38 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005ce4:	0001c797          	auipc	a5,0x1c
    80005ce8:	f5c78793          	addi	a5,a5,-164 # 80021c40 <disk>
    80005cec:	97aa                	add	a5,a5,a0
    80005cee:	0187c783          	lbu	a5,24(a5)
    80005cf2:	ebb9                	bnez	a5,80005d48 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005cf4:	00451693          	slli	a3,a0,0x4
    80005cf8:	0001c797          	auipc	a5,0x1c
    80005cfc:	f4878793          	addi	a5,a5,-184 # 80021c40 <disk>
    80005d00:	6398                	ld	a4,0(a5)
    80005d02:	9736                	add	a4,a4,a3
    80005d04:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005d08:	6398                	ld	a4,0(a5)
    80005d0a:	9736                	add	a4,a4,a3
    80005d0c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d10:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d14:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d18:	97aa                	add	a5,a5,a0
    80005d1a:	4705                	li	a4,1
    80005d1c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005d20:	0001c517          	auipc	a0,0x1c
    80005d24:	f3850513          	addi	a0,a0,-200 # 80021c58 <disk+0x18>
    80005d28:	ffffc097          	auipc	ra,0xffffc
    80005d2c:	390080e7          	jalr	912(ra) # 800020b8 <wakeup>
}
    80005d30:	60a2                	ld	ra,8(sp)
    80005d32:	6402                	ld	s0,0(sp)
    80005d34:	0141                	addi	sp,sp,16
    80005d36:	8082                	ret
    panic("free_desc 1");
    80005d38:	00003517          	auipc	a0,0x3
    80005d3c:	a2050513          	addi	a0,a0,-1504 # 80008758 <syscalls+0x2f0>
    80005d40:	ffffb097          	auipc	ra,0xffffb
    80005d44:	800080e7          	jalr	-2048(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005d48:	00003517          	auipc	a0,0x3
    80005d4c:	a2050513          	addi	a0,a0,-1504 # 80008768 <syscalls+0x300>
    80005d50:	ffffa097          	auipc	ra,0xffffa
    80005d54:	7f0080e7          	jalr	2032(ra) # 80000540 <panic>

0000000080005d58 <virtio_disk_init>:
{
    80005d58:	1101                	addi	sp,sp,-32
    80005d5a:	ec06                	sd	ra,24(sp)
    80005d5c:	e822                	sd	s0,16(sp)
    80005d5e:	e426                	sd	s1,8(sp)
    80005d60:	e04a                	sd	s2,0(sp)
    80005d62:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d64:	00003597          	auipc	a1,0x3
    80005d68:	a1458593          	addi	a1,a1,-1516 # 80008778 <syscalls+0x310>
    80005d6c:	0001c517          	auipc	a0,0x1c
    80005d70:	ffc50513          	addi	a0,a0,-4 # 80021d68 <disk+0x128>
    80005d74:	ffffb097          	auipc	ra,0xffffb
    80005d78:	dd2080e7          	jalr	-558(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d7c:	100017b7          	lui	a5,0x10001
    80005d80:	4398                	lw	a4,0(a5)
    80005d82:	2701                	sext.w	a4,a4
    80005d84:	747277b7          	lui	a5,0x74727
    80005d88:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d8c:	14f71b63          	bne	a4,a5,80005ee2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d90:	100017b7          	lui	a5,0x10001
    80005d94:	43dc                	lw	a5,4(a5)
    80005d96:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d98:	4709                	li	a4,2
    80005d9a:	14e79463          	bne	a5,a4,80005ee2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d9e:	100017b7          	lui	a5,0x10001
    80005da2:	479c                	lw	a5,8(a5)
    80005da4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005da6:	12e79e63          	bne	a5,a4,80005ee2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005daa:	100017b7          	lui	a5,0x10001
    80005dae:	47d8                	lw	a4,12(a5)
    80005db0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005db2:	554d47b7          	lui	a5,0x554d4
    80005db6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005dba:	12f71463          	bne	a4,a5,80005ee2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dbe:	100017b7          	lui	a5,0x10001
    80005dc2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dc6:	4705                	li	a4,1
    80005dc8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dca:	470d                	li	a4,3
    80005dcc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005dce:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005dd0:	c7ffe6b7          	lui	a3,0xc7ffe
    80005dd4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9df>
    80005dd8:	8f75                	and	a4,a4,a3
    80005dda:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ddc:	472d                	li	a4,11
    80005dde:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005de0:	5bbc                	lw	a5,112(a5)
    80005de2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005de6:	8ba1                	andi	a5,a5,8
    80005de8:	10078563          	beqz	a5,80005ef2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005dec:	100017b7          	lui	a5,0x10001
    80005df0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005df4:	43fc                	lw	a5,68(a5)
    80005df6:	2781                	sext.w	a5,a5
    80005df8:	10079563          	bnez	a5,80005f02 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005dfc:	100017b7          	lui	a5,0x10001
    80005e00:	5bdc                	lw	a5,52(a5)
    80005e02:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e04:	10078763          	beqz	a5,80005f12 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005e08:	471d                	li	a4,7
    80005e0a:	10f77c63          	bgeu	a4,a5,80005f22 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005e0e:	ffffb097          	auipc	ra,0xffffb
    80005e12:	cd8080e7          	jalr	-808(ra) # 80000ae6 <kalloc>
    80005e16:	0001c497          	auipc	s1,0x1c
    80005e1a:	e2a48493          	addi	s1,s1,-470 # 80021c40 <disk>
    80005e1e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e20:	ffffb097          	auipc	ra,0xffffb
    80005e24:	cc6080e7          	jalr	-826(ra) # 80000ae6 <kalloc>
    80005e28:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e2a:	ffffb097          	auipc	ra,0xffffb
    80005e2e:	cbc080e7          	jalr	-836(ra) # 80000ae6 <kalloc>
    80005e32:	87aa                	mv	a5,a0
    80005e34:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e36:	6088                	ld	a0,0(s1)
    80005e38:	cd6d                	beqz	a0,80005f32 <virtio_disk_init+0x1da>
    80005e3a:	0001c717          	auipc	a4,0x1c
    80005e3e:	e0e73703          	ld	a4,-498(a4) # 80021c48 <disk+0x8>
    80005e42:	cb65                	beqz	a4,80005f32 <virtio_disk_init+0x1da>
    80005e44:	c7fd                	beqz	a5,80005f32 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005e46:	6605                	lui	a2,0x1
    80005e48:	4581                	li	a1,0
    80005e4a:	ffffb097          	auipc	ra,0xffffb
    80005e4e:	e88080e7          	jalr	-376(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005e52:	0001c497          	auipc	s1,0x1c
    80005e56:	dee48493          	addi	s1,s1,-530 # 80021c40 <disk>
    80005e5a:	6605                	lui	a2,0x1
    80005e5c:	4581                	li	a1,0
    80005e5e:	6488                	ld	a0,8(s1)
    80005e60:	ffffb097          	auipc	ra,0xffffb
    80005e64:	e72080e7          	jalr	-398(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005e68:	6605                	lui	a2,0x1
    80005e6a:	4581                	li	a1,0
    80005e6c:	6888                	ld	a0,16(s1)
    80005e6e:	ffffb097          	auipc	ra,0xffffb
    80005e72:	e64080e7          	jalr	-412(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e76:	100017b7          	lui	a5,0x10001
    80005e7a:	4721                	li	a4,8
    80005e7c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005e7e:	4098                	lw	a4,0(s1)
    80005e80:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005e84:	40d8                	lw	a4,4(s1)
    80005e86:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005e8a:	6498                	ld	a4,8(s1)
    80005e8c:	0007069b          	sext.w	a3,a4
    80005e90:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005e94:	9701                	srai	a4,a4,0x20
    80005e96:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005e9a:	6898                	ld	a4,16(s1)
    80005e9c:	0007069b          	sext.w	a3,a4
    80005ea0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005ea4:	9701                	srai	a4,a4,0x20
    80005ea6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005eaa:	4705                	li	a4,1
    80005eac:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005eae:	00e48c23          	sb	a4,24(s1)
    80005eb2:	00e48ca3          	sb	a4,25(s1)
    80005eb6:	00e48d23          	sb	a4,26(s1)
    80005eba:	00e48da3          	sb	a4,27(s1)
    80005ebe:	00e48e23          	sb	a4,28(s1)
    80005ec2:	00e48ea3          	sb	a4,29(s1)
    80005ec6:	00e48f23          	sb	a4,30(s1)
    80005eca:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005ece:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ed2:	0727a823          	sw	s2,112(a5)
}
    80005ed6:	60e2                	ld	ra,24(sp)
    80005ed8:	6442                	ld	s0,16(sp)
    80005eda:	64a2                	ld	s1,8(sp)
    80005edc:	6902                	ld	s2,0(sp)
    80005ede:	6105                	addi	sp,sp,32
    80005ee0:	8082                	ret
    panic("could not find virtio disk");
    80005ee2:	00003517          	auipc	a0,0x3
    80005ee6:	8a650513          	addi	a0,a0,-1882 # 80008788 <syscalls+0x320>
    80005eea:	ffffa097          	auipc	ra,0xffffa
    80005eee:	656080e7          	jalr	1622(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ef2:	00003517          	auipc	a0,0x3
    80005ef6:	8b650513          	addi	a0,a0,-1866 # 800087a8 <syscalls+0x340>
    80005efa:	ffffa097          	auipc	ra,0xffffa
    80005efe:	646080e7          	jalr	1606(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80005f02:	00003517          	auipc	a0,0x3
    80005f06:	8c650513          	addi	a0,a0,-1850 # 800087c8 <syscalls+0x360>
    80005f0a:	ffffa097          	auipc	ra,0xffffa
    80005f0e:	636080e7          	jalr	1590(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80005f12:	00003517          	auipc	a0,0x3
    80005f16:	8d650513          	addi	a0,a0,-1834 # 800087e8 <syscalls+0x380>
    80005f1a:	ffffa097          	auipc	ra,0xffffa
    80005f1e:	626080e7          	jalr	1574(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80005f22:	00003517          	auipc	a0,0x3
    80005f26:	8e650513          	addi	a0,a0,-1818 # 80008808 <syscalls+0x3a0>
    80005f2a:	ffffa097          	auipc	ra,0xffffa
    80005f2e:	616080e7          	jalr	1558(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80005f32:	00003517          	auipc	a0,0x3
    80005f36:	8f650513          	addi	a0,a0,-1802 # 80008828 <syscalls+0x3c0>
    80005f3a:	ffffa097          	auipc	ra,0xffffa
    80005f3e:	606080e7          	jalr	1542(ra) # 80000540 <panic>

0000000080005f42 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f42:	7119                	addi	sp,sp,-128
    80005f44:	fc86                	sd	ra,120(sp)
    80005f46:	f8a2                	sd	s0,112(sp)
    80005f48:	f4a6                	sd	s1,104(sp)
    80005f4a:	f0ca                	sd	s2,96(sp)
    80005f4c:	ecce                	sd	s3,88(sp)
    80005f4e:	e8d2                	sd	s4,80(sp)
    80005f50:	e4d6                	sd	s5,72(sp)
    80005f52:	e0da                	sd	s6,64(sp)
    80005f54:	fc5e                	sd	s7,56(sp)
    80005f56:	f862                	sd	s8,48(sp)
    80005f58:	f466                	sd	s9,40(sp)
    80005f5a:	f06a                	sd	s10,32(sp)
    80005f5c:	ec6e                	sd	s11,24(sp)
    80005f5e:	0100                	addi	s0,sp,128
    80005f60:	8aaa                	mv	s5,a0
    80005f62:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f64:	00c52d03          	lw	s10,12(a0)
    80005f68:	001d1d1b          	slliw	s10,s10,0x1
    80005f6c:	1d02                	slli	s10,s10,0x20
    80005f6e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005f72:	0001c517          	auipc	a0,0x1c
    80005f76:	df650513          	addi	a0,a0,-522 # 80021d68 <disk+0x128>
    80005f7a:	ffffb097          	auipc	ra,0xffffb
    80005f7e:	c5c080e7          	jalr	-932(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005f82:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f84:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f86:	0001cb97          	auipc	s7,0x1c
    80005f8a:	cbab8b93          	addi	s7,s7,-838 # 80021c40 <disk>
  for(int i = 0; i < 3; i++){
    80005f8e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f90:	0001cc97          	auipc	s9,0x1c
    80005f94:	dd8c8c93          	addi	s9,s9,-552 # 80021d68 <disk+0x128>
    80005f98:	a08d                	j	80005ffa <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005f9a:	00fb8733          	add	a4,s7,a5
    80005f9e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005fa2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005fa4:	0207c563          	bltz	a5,80005fce <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005fa8:	2905                	addiw	s2,s2,1
    80005faa:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005fac:	05690c63          	beq	s2,s6,80006004 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005fb0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005fb2:	0001c717          	auipc	a4,0x1c
    80005fb6:	c8e70713          	addi	a4,a4,-882 # 80021c40 <disk>
    80005fba:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005fbc:	01874683          	lbu	a3,24(a4)
    80005fc0:	fee9                	bnez	a3,80005f9a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005fc2:	2785                	addiw	a5,a5,1
    80005fc4:	0705                	addi	a4,a4,1
    80005fc6:	fe979be3          	bne	a5,s1,80005fbc <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80005fca:	57fd                	li	a5,-1
    80005fcc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005fce:	01205d63          	blez	s2,80005fe8 <virtio_disk_rw+0xa6>
    80005fd2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005fd4:	000a2503          	lw	a0,0(s4)
    80005fd8:	00000097          	auipc	ra,0x0
    80005fdc:	cfe080e7          	jalr	-770(ra) # 80005cd6 <free_desc>
      for(int j = 0; j < i; j++)
    80005fe0:	2d85                	addiw	s11,s11,1
    80005fe2:	0a11                	addi	s4,s4,4
    80005fe4:	ff2d98e3          	bne	s11,s2,80005fd4 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fe8:	85e6                	mv	a1,s9
    80005fea:	0001c517          	auipc	a0,0x1c
    80005fee:	c6e50513          	addi	a0,a0,-914 # 80021c58 <disk+0x18>
    80005ff2:	ffffc097          	auipc	ra,0xffffc
    80005ff6:	062080e7          	jalr	98(ra) # 80002054 <sleep>
  for(int i = 0; i < 3; i++){
    80005ffa:	f8040a13          	addi	s4,s0,-128
{
    80005ffe:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006000:	894e                	mv	s2,s3
    80006002:	b77d                	j	80005fb0 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006004:	f8042503          	lw	a0,-128(s0)
    80006008:	00a50713          	addi	a4,a0,10
    8000600c:	0712                	slli	a4,a4,0x4

  if(write)
    8000600e:	0001c797          	auipc	a5,0x1c
    80006012:	c3278793          	addi	a5,a5,-974 # 80021c40 <disk>
    80006016:	00e786b3          	add	a3,a5,a4
    8000601a:	01803633          	snez	a2,s8
    8000601e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006020:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006024:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006028:	f6070613          	addi	a2,a4,-160
    8000602c:	6394                	ld	a3,0(a5)
    8000602e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006030:	00870593          	addi	a1,a4,8
    80006034:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006036:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006038:	0007b803          	ld	a6,0(a5)
    8000603c:	9642                	add	a2,a2,a6
    8000603e:	46c1                	li	a3,16
    80006040:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006042:	4585                	li	a1,1
    80006044:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006048:	f8442683          	lw	a3,-124(s0)
    8000604c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006050:	0692                	slli	a3,a3,0x4
    80006052:	9836                	add	a6,a6,a3
    80006054:	058a8613          	addi	a2,s5,88
    80006058:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000605c:	0007b803          	ld	a6,0(a5)
    80006060:	96c2                	add	a3,a3,a6
    80006062:	40000613          	li	a2,1024
    80006066:	c690                	sw	a2,8(a3)
  if(write)
    80006068:	001c3613          	seqz	a2,s8
    8000606c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006070:	00166613          	ori	a2,a2,1
    80006074:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006078:	f8842603          	lw	a2,-120(s0)
    8000607c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006080:	00250693          	addi	a3,a0,2
    80006084:	0692                	slli	a3,a3,0x4
    80006086:	96be                	add	a3,a3,a5
    80006088:	58fd                	li	a7,-1
    8000608a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000608e:	0612                	slli	a2,a2,0x4
    80006090:	9832                	add	a6,a6,a2
    80006092:	f9070713          	addi	a4,a4,-112
    80006096:	973e                	add	a4,a4,a5
    80006098:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000609c:	6398                	ld	a4,0(a5)
    8000609e:	9732                	add	a4,a4,a2
    800060a0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060a2:	4609                	li	a2,2
    800060a4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800060a8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060ac:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800060b0:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800060b4:	6794                	ld	a3,8(a5)
    800060b6:	0026d703          	lhu	a4,2(a3)
    800060ba:	8b1d                	andi	a4,a4,7
    800060bc:	0706                	slli	a4,a4,0x1
    800060be:	96ba                	add	a3,a3,a4
    800060c0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800060c4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800060c8:	6798                	ld	a4,8(a5)
    800060ca:	00275783          	lhu	a5,2(a4)
    800060ce:	2785                	addiw	a5,a5,1
    800060d0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800060d4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060d8:	100017b7          	lui	a5,0x10001
    800060dc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060e0:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    800060e4:	0001c917          	auipc	s2,0x1c
    800060e8:	c8490913          	addi	s2,s2,-892 # 80021d68 <disk+0x128>
  while(b->disk == 1) {
    800060ec:	4485                	li	s1,1
    800060ee:	00b79c63          	bne	a5,a1,80006106 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800060f2:	85ca                	mv	a1,s2
    800060f4:	8556                	mv	a0,s5
    800060f6:	ffffc097          	auipc	ra,0xffffc
    800060fa:	f5e080e7          	jalr	-162(ra) # 80002054 <sleep>
  while(b->disk == 1) {
    800060fe:	004aa783          	lw	a5,4(s5)
    80006102:	fe9788e3          	beq	a5,s1,800060f2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006106:	f8042903          	lw	s2,-128(s0)
    8000610a:	00290713          	addi	a4,s2,2
    8000610e:	0712                	slli	a4,a4,0x4
    80006110:	0001c797          	auipc	a5,0x1c
    80006114:	b3078793          	addi	a5,a5,-1232 # 80021c40 <disk>
    80006118:	97ba                	add	a5,a5,a4
    8000611a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000611e:	0001c997          	auipc	s3,0x1c
    80006122:	b2298993          	addi	s3,s3,-1246 # 80021c40 <disk>
    80006126:	00491713          	slli	a4,s2,0x4
    8000612a:	0009b783          	ld	a5,0(s3)
    8000612e:	97ba                	add	a5,a5,a4
    80006130:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006134:	854a                	mv	a0,s2
    80006136:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000613a:	00000097          	auipc	ra,0x0
    8000613e:	b9c080e7          	jalr	-1124(ra) # 80005cd6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006142:	8885                	andi	s1,s1,1
    80006144:	f0ed                	bnez	s1,80006126 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006146:	0001c517          	auipc	a0,0x1c
    8000614a:	c2250513          	addi	a0,a0,-990 # 80021d68 <disk+0x128>
    8000614e:	ffffb097          	auipc	ra,0xffffb
    80006152:	b3c080e7          	jalr	-1220(ra) # 80000c8a <release>
}
    80006156:	70e6                	ld	ra,120(sp)
    80006158:	7446                	ld	s0,112(sp)
    8000615a:	74a6                	ld	s1,104(sp)
    8000615c:	7906                	ld	s2,96(sp)
    8000615e:	69e6                	ld	s3,88(sp)
    80006160:	6a46                	ld	s4,80(sp)
    80006162:	6aa6                	ld	s5,72(sp)
    80006164:	6b06                	ld	s6,64(sp)
    80006166:	7be2                	ld	s7,56(sp)
    80006168:	7c42                	ld	s8,48(sp)
    8000616a:	7ca2                	ld	s9,40(sp)
    8000616c:	7d02                	ld	s10,32(sp)
    8000616e:	6de2                	ld	s11,24(sp)
    80006170:	6109                	addi	sp,sp,128
    80006172:	8082                	ret

0000000080006174 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006174:	1101                	addi	sp,sp,-32
    80006176:	ec06                	sd	ra,24(sp)
    80006178:	e822                	sd	s0,16(sp)
    8000617a:	e426                	sd	s1,8(sp)
    8000617c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000617e:	0001c497          	auipc	s1,0x1c
    80006182:	ac248493          	addi	s1,s1,-1342 # 80021c40 <disk>
    80006186:	0001c517          	auipc	a0,0x1c
    8000618a:	be250513          	addi	a0,a0,-1054 # 80021d68 <disk+0x128>
    8000618e:	ffffb097          	auipc	ra,0xffffb
    80006192:	a48080e7          	jalr	-1464(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006196:	10001737          	lui	a4,0x10001
    8000619a:	533c                	lw	a5,96(a4)
    8000619c:	8b8d                	andi	a5,a5,3
    8000619e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800061a0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061a4:	689c                	ld	a5,16(s1)
    800061a6:	0204d703          	lhu	a4,32(s1)
    800061aa:	0027d783          	lhu	a5,2(a5)
    800061ae:	04f70863          	beq	a4,a5,800061fe <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800061b2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061b6:	6898                	ld	a4,16(s1)
    800061b8:	0204d783          	lhu	a5,32(s1)
    800061bc:	8b9d                	andi	a5,a5,7
    800061be:	078e                	slli	a5,a5,0x3
    800061c0:	97ba                	add	a5,a5,a4
    800061c2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800061c4:	00278713          	addi	a4,a5,2
    800061c8:	0712                	slli	a4,a4,0x4
    800061ca:	9726                	add	a4,a4,s1
    800061cc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800061d0:	e721                	bnez	a4,80006218 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800061d2:	0789                	addi	a5,a5,2
    800061d4:	0792                	slli	a5,a5,0x4
    800061d6:	97a6                	add	a5,a5,s1
    800061d8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800061da:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800061de:	ffffc097          	auipc	ra,0xffffc
    800061e2:	eda080e7          	jalr	-294(ra) # 800020b8 <wakeup>

    disk.used_idx += 1;
    800061e6:	0204d783          	lhu	a5,32(s1)
    800061ea:	2785                	addiw	a5,a5,1
    800061ec:	17c2                	slli	a5,a5,0x30
    800061ee:	93c1                	srli	a5,a5,0x30
    800061f0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800061f4:	6898                	ld	a4,16(s1)
    800061f6:	00275703          	lhu	a4,2(a4)
    800061fa:	faf71ce3          	bne	a4,a5,800061b2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800061fe:	0001c517          	auipc	a0,0x1c
    80006202:	b6a50513          	addi	a0,a0,-1174 # 80021d68 <disk+0x128>
    80006206:	ffffb097          	auipc	ra,0xffffb
    8000620a:	a84080e7          	jalr	-1404(ra) # 80000c8a <release>
}
    8000620e:	60e2                	ld	ra,24(sp)
    80006210:	6442                	ld	s0,16(sp)
    80006212:	64a2                	ld	s1,8(sp)
    80006214:	6105                	addi	sp,sp,32
    80006216:	8082                	ret
      panic("virtio_disk_intr status");
    80006218:	00002517          	auipc	a0,0x2
    8000621c:	62850513          	addi	a0,a0,1576 # 80008840 <syscalls+0x3d8>
    80006220:	ffffa097          	auipc	ra,0xffffa
    80006224:	320080e7          	jalr	800(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
