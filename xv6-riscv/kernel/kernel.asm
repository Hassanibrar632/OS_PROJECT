
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
    80000ec2:	7fc080e7          	jalr	2044(ra) # 800026ba <trapinithart>
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
    80000f3a:	75c080e7          	jalr	1884(ra) # 80002692 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	77c080e7          	jalr	1916(ra) # 800026ba <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	cf4080e7          	jalr	-780(ra) # 80005c3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	d02080e7          	jalr	-766(ra) # 80005c50 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	ea0080e7          	jalr	-352(ra) # 80002df6 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	540080e7          	jalr	1344(ra) # 8000349e <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	4e6080e7          	jalr	1254(ra) # 8000444c <fileinit>
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
    80001a0a:	ccc080e7          	jalr	-820(ra) # 800026d2 <usertrapret>
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
    80001a24:	9fe080e7          	jalr	-1538(ra) # 8000341e <fsinit>
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
    80001ce6:	166080e7          	jalr	358(ra) # 80003e48 <namei>
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
    80001e16:	6cc080e7          	jalr	1740(ra) # 800044de <filedup>
    80001e1a:	00a93023          	sd	a0,0(s2)
    80001e1e:	b7e5                	j	80001e06 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e20:	150ab503          	ld	a0,336(s5)
    80001e24:	00002097          	auipc	ra,0x2
    80001e28:	83a080e7          	jalr	-1990(ra) # 8000365e <idup>
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
    80001f38:	6f4080e7          	jalr	1780(ra) # 80002628 <swtch>
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
    80001fba:	672080e7          	jalr	1650(ra) # 80002628 <swtch>
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
    800021cc:	368080e7          	jalr	872(ra) # 80004530 <fileclose>
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
    800021e4:	e88080e7          	jalr	-376(ra) # 80004068 <begin_op>
  iput(p->cwd);
    800021e8:	1509b503          	ld	a0,336(s3)
    800021ec:	00001097          	auipc	ra,0x1
    800021f0:	66a080e7          	jalr	1642(ra) # 80003856 <iput>
  end_op();
    800021f4:	00002097          	auipc	ra,0x2
    800021f8:	ef2080e7          	jalr	-270(ra) # 800040e6 <end_op>
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

00000000800025b8 <sys_ps>:

// CODE
uint64 sys_ps(void){
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
    800025f2:	a029                	j	800025fc <sys_ps+0x44>
	for(p = proc; p < &proc[NPROC]; p++)
    800025f4:	16848493          	addi	s1,s1,360
    800025f8:	01348f63          	beq	s1,s3,80002616 <sys_ps+0x5e>
		if(p->state == RUNNING)
    800025fc:	ec04a783          	lw	a5,-320(s1)
    80002600:	ff279ae3          	bne	a5,s2,800025f4 <sys_ps+0x3c>
			printf("%d\t\t%s\n", p->pid, p->name);
    80002604:	8626                	mv	a2,s1
    80002606:	ed84a583          	lw	a1,-296(s1)
    8000260a:	8552                	mv	a0,s4
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	f7e080e7          	jalr	-130(ra) # 8000058a <printf>
    80002614:	b7c5                	j	800025f4 <sys_ps+0x3c>
	return 0;
}
    80002616:	4501                	li	a0,0
    80002618:	70a2                	ld	ra,40(sp)
    8000261a:	7402                	ld	s0,32(sp)
    8000261c:	64e2                	ld	s1,24(sp)
    8000261e:	6942                	ld	s2,16(sp)
    80002620:	69a2                	ld	s3,8(sp)
    80002622:	6a02                	ld	s4,0(sp)
    80002624:	6145                	addi	sp,sp,48
    80002626:	8082                	ret

0000000080002628 <swtch>:
    80002628:	00153023          	sd	ra,0(a0)
    8000262c:	00253423          	sd	sp,8(a0)
    80002630:	e900                	sd	s0,16(a0)
    80002632:	ed04                	sd	s1,24(a0)
    80002634:	03253023          	sd	s2,32(a0)
    80002638:	03353423          	sd	s3,40(a0)
    8000263c:	03453823          	sd	s4,48(a0)
    80002640:	03553c23          	sd	s5,56(a0)
    80002644:	05653023          	sd	s6,64(a0)
    80002648:	05753423          	sd	s7,72(a0)
    8000264c:	05853823          	sd	s8,80(a0)
    80002650:	05953c23          	sd	s9,88(a0)
    80002654:	07a53023          	sd	s10,96(a0)
    80002658:	07b53423          	sd	s11,104(a0)
    8000265c:	0005b083          	ld	ra,0(a1)
    80002660:	0085b103          	ld	sp,8(a1)
    80002664:	6980                	ld	s0,16(a1)
    80002666:	6d84                	ld	s1,24(a1)
    80002668:	0205b903          	ld	s2,32(a1)
    8000266c:	0285b983          	ld	s3,40(a1)
    80002670:	0305ba03          	ld	s4,48(a1)
    80002674:	0385ba83          	ld	s5,56(a1)
    80002678:	0405bb03          	ld	s6,64(a1)
    8000267c:	0485bb83          	ld	s7,72(a1)
    80002680:	0505bc03          	ld	s8,80(a1)
    80002684:	0585bc83          	ld	s9,88(a1)
    80002688:	0605bd03          	ld	s10,96(a1)
    8000268c:	0685bd83          	ld	s11,104(a1)
    80002690:	8082                	ret

0000000080002692 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002692:	1141                	addi	sp,sp,-16
    80002694:	e406                	sd	ra,8(sp)
    80002696:	e022                	sd	s0,0(sp)
    80002698:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000269a:	00006597          	auipc	a1,0x6
    8000269e:	c7658593          	addi	a1,a1,-906 # 80008310 <states.0+0x30>
    800026a2:	00014517          	auipc	a0,0x14
    800026a6:	2fe50513          	addi	a0,a0,766 # 800169a0 <tickslock>
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	49c080e7          	jalr	1180(ra) # 80000b46 <initlock>
}
    800026b2:	60a2                	ld	ra,8(sp)
    800026b4:	6402                	ld	s0,0(sp)
    800026b6:	0141                	addi	sp,sp,16
    800026b8:	8082                	ret

00000000800026ba <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026ba:	1141                	addi	sp,sp,-16
    800026bc:	e422                	sd	s0,8(sp)
    800026be:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026c0:	00003797          	auipc	a5,0x3
    800026c4:	4c078793          	addi	a5,a5,1216 # 80005b80 <kernelvec>
    800026c8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026cc:	6422                	ld	s0,8(sp)
    800026ce:	0141                	addi	sp,sp,16
    800026d0:	8082                	ret

00000000800026d2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026d2:	1141                	addi	sp,sp,-16
    800026d4:	e406                	sd	ra,8(sp)
    800026d6:	e022                	sd	s0,0(sp)
    800026d8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026da:	fffff097          	auipc	ra,0xfffff
    800026de:	2d2080e7          	jalr	722(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026e6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026ec:	00005697          	auipc	a3,0x5
    800026f0:	91468693          	addi	a3,a3,-1772 # 80007000 <_trampoline>
    800026f4:	00005717          	auipc	a4,0x5
    800026f8:	90c70713          	addi	a4,a4,-1780 # 80007000 <_trampoline>
    800026fc:	8f15                	sub	a4,a4,a3
    800026fe:	040007b7          	lui	a5,0x4000
    80002702:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002704:	07b2                	slli	a5,a5,0xc
    80002706:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002708:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000270c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000270e:	18002673          	csrr	a2,satp
    80002712:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002714:	6d30                	ld	a2,88(a0)
    80002716:	6138                	ld	a4,64(a0)
    80002718:	6585                	lui	a1,0x1
    8000271a:	972e                	add	a4,a4,a1
    8000271c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000271e:	6d38                	ld	a4,88(a0)
    80002720:	00000617          	auipc	a2,0x0
    80002724:	13060613          	addi	a2,a2,304 # 80002850 <usertrap>
    80002728:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000272a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000272c:	8612                	mv	a2,tp
    8000272e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002730:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002734:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002738:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000273c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002740:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002742:	6f18                	ld	a4,24(a4)
    80002744:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002748:	6928                	ld	a0,80(a0)
    8000274a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000274c:	00005717          	auipc	a4,0x5
    80002750:	95070713          	addi	a4,a4,-1712 # 8000709c <userret>
    80002754:	8f15                	sub	a4,a4,a3
    80002756:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002758:	577d                	li	a4,-1
    8000275a:	177e                	slli	a4,a4,0x3f
    8000275c:	8d59                	or	a0,a0,a4
    8000275e:	9782                	jalr	a5
}
    80002760:	60a2                	ld	ra,8(sp)
    80002762:	6402                	ld	s0,0(sp)
    80002764:	0141                	addi	sp,sp,16
    80002766:	8082                	ret

0000000080002768 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002768:	1101                	addi	sp,sp,-32
    8000276a:	ec06                	sd	ra,24(sp)
    8000276c:	e822                	sd	s0,16(sp)
    8000276e:	e426                	sd	s1,8(sp)
    80002770:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002772:	00014497          	auipc	s1,0x14
    80002776:	22e48493          	addi	s1,s1,558 # 800169a0 <tickslock>
    8000277a:	8526                	mv	a0,s1
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	45a080e7          	jalr	1114(ra) # 80000bd6 <acquire>
  ticks++;
    80002784:	00006517          	auipc	a0,0x6
    80002788:	17c50513          	addi	a0,a0,380 # 80008900 <ticks>
    8000278c:	411c                	lw	a5,0(a0)
    8000278e:	2785                	addiw	a5,a5,1
    80002790:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002792:	00000097          	auipc	ra,0x0
    80002796:	926080e7          	jalr	-1754(ra) # 800020b8 <wakeup>
  release(&tickslock);
    8000279a:	8526                	mv	a0,s1
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	4ee080e7          	jalr	1262(ra) # 80000c8a <release>
}
    800027a4:	60e2                	ld	ra,24(sp)
    800027a6:	6442                	ld	s0,16(sp)
    800027a8:	64a2                	ld	s1,8(sp)
    800027aa:	6105                	addi	sp,sp,32
    800027ac:	8082                	ret

00000000800027ae <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027ae:	1101                	addi	sp,sp,-32
    800027b0:	ec06                	sd	ra,24(sp)
    800027b2:	e822                	sd	s0,16(sp)
    800027b4:	e426                	sd	s1,8(sp)
    800027b6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027b8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027bc:	00074d63          	bltz	a4,800027d6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027c0:	57fd                	li	a5,-1
    800027c2:	17fe                	slli	a5,a5,0x3f
    800027c4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027c6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027c8:	06f70363          	beq	a4,a5,8000282e <devintr+0x80>
  }
}
    800027cc:	60e2                	ld	ra,24(sp)
    800027ce:	6442                	ld	s0,16(sp)
    800027d0:	64a2                	ld	s1,8(sp)
    800027d2:	6105                	addi	sp,sp,32
    800027d4:	8082                	ret
     (scause & 0xff) == 9){
    800027d6:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800027da:	46a5                	li	a3,9
    800027dc:	fed792e3          	bne	a5,a3,800027c0 <devintr+0x12>
    int irq = plic_claim();
    800027e0:	00003097          	auipc	ra,0x3
    800027e4:	4a8080e7          	jalr	1192(ra) # 80005c88 <plic_claim>
    800027e8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027ea:	47a9                	li	a5,10
    800027ec:	02f50763          	beq	a0,a5,8000281a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027f0:	4785                	li	a5,1
    800027f2:	02f50963          	beq	a0,a5,80002824 <devintr+0x76>
    return 1;
    800027f6:	4505                	li	a0,1
    } else if(irq){
    800027f8:	d8f1                	beqz	s1,800027cc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027fa:	85a6                	mv	a1,s1
    800027fc:	00006517          	auipc	a0,0x6
    80002800:	b1c50513          	addi	a0,a0,-1252 # 80008318 <states.0+0x38>
    80002804:	ffffe097          	auipc	ra,0xffffe
    80002808:	d86080e7          	jalr	-634(ra) # 8000058a <printf>
      plic_complete(irq);
    8000280c:	8526                	mv	a0,s1
    8000280e:	00003097          	auipc	ra,0x3
    80002812:	49e080e7          	jalr	1182(ra) # 80005cac <plic_complete>
    return 1;
    80002816:	4505                	li	a0,1
    80002818:	bf55                	j	800027cc <devintr+0x1e>
      uartintr();
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	17e080e7          	jalr	382(ra) # 80000998 <uartintr>
    80002822:	b7ed                	j	8000280c <devintr+0x5e>
      virtio_disk_intr();
    80002824:	00004097          	auipc	ra,0x4
    80002828:	950080e7          	jalr	-1712(ra) # 80006174 <virtio_disk_intr>
    8000282c:	b7c5                	j	8000280c <devintr+0x5e>
    if(cpuid() == 0){
    8000282e:	fffff097          	auipc	ra,0xfffff
    80002832:	152080e7          	jalr	338(ra) # 80001980 <cpuid>
    80002836:	c901                	beqz	a0,80002846 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002838:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000283c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000283e:	14479073          	csrw	sip,a5
    return 2;
    80002842:	4509                	li	a0,2
    80002844:	b761                	j	800027cc <devintr+0x1e>
      clockintr();
    80002846:	00000097          	auipc	ra,0x0
    8000284a:	f22080e7          	jalr	-222(ra) # 80002768 <clockintr>
    8000284e:	b7ed                	j	80002838 <devintr+0x8a>

0000000080002850 <usertrap>:
{
    80002850:	1101                	addi	sp,sp,-32
    80002852:	ec06                	sd	ra,24(sp)
    80002854:	e822                	sd	s0,16(sp)
    80002856:	e426                	sd	s1,8(sp)
    80002858:	e04a                	sd	s2,0(sp)
    8000285a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000285c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002860:	1007f793          	andi	a5,a5,256
    80002864:	e3b1                	bnez	a5,800028a8 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002866:	00003797          	auipc	a5,0x3
    8000286a:	31a78793          	addi	a5,a5,794 # 80005b80 <kernelvec>
    8000286e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002872:	fffff097          	auipc	ra,0xfffff
    80002876:	13a080e7          	jalr	314(ra) # 800019ac <myproc>
    8000287a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000287c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000287e:	14102773          	csrr	a4,sepc
    80002882:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002884:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002888:	47a1                	li	a5,8
    8000288a:	02f70763          	beq	a4,a5,800028b8 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000288e:	00000097          	auipc	ra,0x0
    80002892:	f20080e7          	jalr	-224(ra) # 800027ae <devintr>
    80002896:	892a                	mv	s2,a0
    80002898:	c151                	beqz	a0,8000291c <usertrap+0xcc>
  if(killed(p))
    8000289a:	8526                	mv	a0,s1
    8000289c:	00000097          	auipc	ra,0x0
    800028a0:	a60080e7          	jalr	-1440(ra) # 800022fc <killed>
    800028a4:	c929                	beqz	a0,800028f6 <usertrap+0xa6>
    800028a6:	a099                	j	800028ec <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800028a8:	00006517          	auipc	a0,0x6
    800028ac:	a9050513          	addi	a0,a0,-1392 # 80008338 <states.0+0x58>
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	c90080e7          	jalr	-880(ra) # 80000540 <panic>
    if(killed(p))
    800028b8:	00000097          	auipc	ra,0x0
    800028bc:	a44080e7          	jalr	-1468(ra) # 800022fc <killed>
    800028c0:	e921                	bnez	a0,80002910 <usertrap+0xc0>
    p->trapframe->epc += 4;
    800028c2:	6cb8                	ld	a4,88(s1)
    800028c4:	6f1c                	ld	a5,24(a4)
    800028c6:	0791                	addi	a5,a5,4
    800028c8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028ce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d2:	10079073          	csrw	sstatus,a5
    syscall();
    800028d6:	00000097          	auipc	ra,0x0
    800028da:	2d4080e7          	jalr	724(ra) # 80002baa <syscall>
  if(killed(p))
    800028de:	8526                	mv	a0,s1
    800028e0:	00000097          	auipc	ra,0x0
    800028e4:	a1c080e7          	jalr	-1508(ra) # 800022fc <killed>
    800028e8:	c911                	beqz	a0,800028fc <usertrap+0xac>
    800028ea:	4901                	li	s2,0
    exit(-1);
    800028ec:	557d                	li	a0,-1
    800028ee:	00000097          	auipc	ra,0x0
    800028f2:	89a080e7          	jalr	-1894(ra) # 80002188 <exit>
  if(which_dev == 2)
    800028f6:	4789                	li	a5,2
    800028f8:	04f90f63          	beq	s2,a5,80002956 <usertrap+0x106>
  usertrapret();
    800028fc:	00000097          	auipc	ra,0x0
    80002900:	dd6080e7          	jalr	-554(ra) # 800026d2 <usertrapret>
}
    80002904:	60e2                	ld	ra,24(sp)
    80002906:	6442                	ld	s0,16(sp)
    80002908:	64a2                	ld	s1,8(sp)
    8000290a:	6902                	ld	s2,0(sp)
    8000290c:	6105                	addi	sp,sp,32
    8000290e:	8082                	ret
      exit(-1);
    80002910:	557d                	li	a0,-1
    80002912:	00000097          	auipc	ra,0x0
    80002916:	876080e7          	jalr	-1930(ra) # 80002188 <exit>
    8000291a:	b765                	j	800028c2 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000291c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002920:	5890                	lw	a2,48(s1)
    80002922:	00006517          	auipc	a0,0x6
    80002926:	a3650513          	addi	a0,a0,-1482 # 80008358 <states.0+0x78>
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	c60080e7          	jalr	-928(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002932:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002936:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000293a:	00006517          	auipc	a0,0x6
    8000293e:	a4e50513          	addi	a0,a0,-1458 # 80008388 <states.0+0xa8>
    80002942:	ffffe097          	auipc	ra,0xffffe
    80002946:	c48080e7          	jalr	-952(ra) # 8000058a <printf>
    setkilled(p);
    8000294a:	8526                	mv	a0,s1
    8000294c:	00000097          	auipc	ra,0x0
    80002950:	984080e7          	jalr	-1660(ra) # 800022d0 <setkilled>
    80002954:	b769                	j	800028de <usertrap+0x8e>
    yield();
    80002956:	fffff097          	auipc	ra,0xfffff
    8000295a:	6c2080e7          	jalr	1730(ra) # 80002018 <yield>
    8000295e:	bf79                	j	800028fc <usertrap+0xac>

0000000080002960 <kerneltrap>:
{
    80002960:	7179                	addi	sp,sp,-48
    80002962:	f406                	sd	ra,40(sp)
    80002964:	f022                	sd	s0,32(sp)
    80002966:	ec26                	sd	s1,24(sp)
    80002968:	e84a                	sd	s2,16(sp)
    8000296a:	e44e                	sd	s3,8(sp)
    8000296c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000296e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002972:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002976:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000297a:	1004f793          	andi	a5,s1,256
    8000297e:	cb85                	beqz	a5,800029ae <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002980:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002984:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002986:	ef85                	bnez	a5,800029be <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002988:	00000097          	auipc	ra,0x0
    8000298c:	e26080e7          	jalr	-474(ra) # 800027ae <devintr>
    80002990:	cd1d                	beqz	a0,800029ce <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002992:	4789                	li	a5,2
    80002994:	06f50a63          	beq	a0,a5,80002a08 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002998:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000299c:	10049073          	csrw	sstatus,s1
}
    800029a0:	70a2                	ld	ra,40(sp)
    800029a2:	7402                	ld	s0,32(sp)
    800029a4:	64e2                	ld	s1,24(sp)
    800029a6:	6942                	ld	s2,16(sp)
    800029a8:	69a2                	ld	s3,8(sp)
    800029aa:	6145                	addi	sp,sp,48
    800029ac:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029ae:	00006517          	auipc	a0,0x6
    800029b2:	9fa50513          	addi	a0,a0,-1542 # 800083a8 <states.0+0xc8>
    800029b6:	ffffe097          	auipc	ra,0xffffe
    800029ba:	b8a080e7          	jalr	-1142(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    800029be:	00006517          	auipc	a0,0x6
    800029c2:	a1250513          	addi	a0,a0,-1518 # 800083d0 <states.0+0xf0>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	b7a080e7          	jalr	-1158(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    800029ce:	85ce                	mv	a1,s3
    800029d0:	00006517          	auipc	a0,0x6
    800029d4:	a2050513          	addi	a0,a0,-1504 # 800083f0 <states.0+0x110>
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	bb2080e7          	jalr	-1102(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029e0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029e4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029e8:	00006517          	auipc	a0,0x6
    800029ec:	a1850513          	addi	a0,a0,-1512 # 80008400 <states.0+0x120>
    800029f0:	ffffe097          	auipc	ra,0xffffe
    800029f4:	b9a080e7          	jalr	-1126(ra) # 8000058a <printf>
    panic("kerneltrap");
    800029f8:	00006517          	auipc	a0,0x6
    800029fc:	a2050513          	addi	a0,a0,-1504 # 80008418 <states.0+0x138>
    80002a00:	ffffe097          	auipc	ra,0xffffe
    80002a04:	b40080e7          	jalr	-1216(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a08:	fffff097          	auipc	ra,0xfffff
    80002a0c:	fa4080e7          	jalr	-92(ra) # 800019ac <myproc>
    80002a10:	d541                	beqz	a0,80002998 <kerneltrap+0x38>
    80002a12:	fffff097          	auipc	ra,0xfffff
    80002a16:	f9a080e7          	jalr	-102(ra) # 800019ac <myproc>
    80002a1a:	4d18                	lw	a4,24(a0)
    80002a1c:	4791                	li	a5,4
    80002a1e:	f6f71de3          	bne	a4,a5,80002998 <kerneltrap+0x38>
    yield();
    80002a22:	fffff097          	auipc	ra,0xfffff
    80002a26:	5f6080e7          	jalr	1526(ra) # 80002018 <yield>
    80002a2a:	b7bd                	j	80002998 <kerneltrap+0x38>

0000000080002a2c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a2c:	1101                	addi	sp,sp,-32
    80002a2e:	ec06                	sd	ra,24(sp)
    80002a30:	e822                	sd	s0,16(sp)
    80002a32:	e426                	sd	s1,8(sp)
    80002a34:	1000                	addi	s0,sp,32
    80002a36:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a38:	fffff097          	auipc	ra,0xfffff
    80002a3c:	f74080e7          	jalr	-140(ra) # 800019ac <myproc>
  switch (n) {
    80002a40:	4795                	li	a5,5
    80002a42:	0497e163          	bltu	a5,s1,80002a84 <argraw+0x58>
    80002a46:	048a                	slli	s1,s1,0x2
    80002a48:	00006717          	auipc	a4,0x6
    80002a4c:	a0870713          	addi	a4,a4,-1528 # 80008450 <states.0+0x170>
    80002a50:	94ba                	add	s1,s1,a4
    80002a52:	409c                	lw	a5,0(s1)
    80002a54:	97ba                	add	a5,a5,a4
    80002a56:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a58:	6d3c                	ld	a5,88(a0)
    80002a5a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a5c:	60e2                	ld	ra,24(sp)
    80002a5e:	6442                	ld	s0,16(sp)
    80002a60:	64a2                	ld	s1,8(sp)
    80002a62:	6105                	addi	sp,sp,32
    80002a64:	8082                	ret
    return p->trapframe->a1;
    80002a66:	6d3c                	ld	a5,88(a0)
    80002a68:	7fa8                	ld	a0,120(a5)
    80002a6a:	bfcd                	j	80002a5c <argraw+0x30>
    return p->trapframe->a2;
    80002a6c:	6d3c                	ld	a5,88(a0)
    80002a6e:	63c8                	ld	a0,128(a5)
    80002a70:	b7f5                	j	80002a5c <argraw+0x30>
    return p->trapframe->a3;
    80002a72:	6d3c                	ld	a5,88(a0)
    80002a74:	67c8                	ld	a0,136(a5)
    80002a76:	b7dd                	j	80002a5c <argraw+0x30>
    return p->trapframe->a4;
    80002a78:	6d3c                	ld	a5,88(a0)
    80002a7a:	6bc8                	ld	a0,144(a5)
    80002a7c:	b7c5                	j	80002a5c <argraw+0x30>
    return p->trapframe->a5;
    80002a7e:	6d3c                	ld	a5,88(a0)
    80002a80:	6fc8                	ld	a0,152(a5)
    80002a82:	bfe9                	j	80002a5c <argraw+0x30>
  panic("argraw");
    80002a84:	00006517          	auipc	a0,0x6
    80002a88:	9a450513          	addi	a0,a0,-1628 # 80008428 <states.0+0x148>
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	ab4080e7          	jalr	-1356(ra) # 80000540 <panic>

0000000080002a94 <fetchaddr>:
{
    80002a94:	1101                	addi	sp,sp,-32
    80002a96:	ec06                	sd	ra,24(sp)
    80002a98:	e822                	sd	s0,16(sp)
    80002a9a:	e426                	sd	s1,8(sp)
    80002a9c:	e04a                	sd	s2,0(sp)
    80002a9e:	1000                	addi	s0,sp,32
    80002aa0:	84aa                	mv	s1,a0
    80002aa2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002aa4:	fffff097          	auipc	ra,0xfffff
    80002aa8:	f08080e7          	jalr	-248(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002aac:	653c                	ld	a5,72(a0)
    80002aae:	02f4f863          	bgeu	s1,a5,80002ade <fetchaddr+0x4a>
    80002ab2:	00848713          	addi	a4,s1,8
    80002ab6:	02e7e663          	bltu	a5,a4,80002ae2 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002aba:	46a1                	li	a3,8
    80002abc:	8626                	mv	a2,s1
    80002abe:	85ca                	mv	a1,s2
    80002ac0:	6928                	ld	a0,80(a0)
    80002ac2:	fffff097          	auipc	ra,0xfffff
    80002ac6:	c36080e7          	jalr	-970(ra) # 800016f8 <copyin>
    80002aca:	00a03533          	snez	a0,a0
    80002ace:	40a00533          	neg	a0,a0
}
    80002ad2:	60e2                	ld	ra,24(sp)
    80002ad4:	6442                	ld	s0,16(sp)
    80002ad6:	64a2                	ld	s1,8(sp)
    80002ad8:	6902                	ld	s2,0(sp)
    80002ada:	6105                	addi	sp,sp,32
    80002adc:	8082                	ret
    return -1;
    80002ade:	557d                	li	a0,-1
    80002ae0:	bfcd                	j	80002ad2 <fetchaddr+0x3e>
    80002ae2:	557d                	li	a0,-1
    80002ae4:	b7fd                	j	80002ad2 <fetchaddr+0x3e>

0000000080002ae6 <fetchstr>:
{
    80002ae6:	7179                	addi	sp,sp,-48
    80002ae8:	f406                	sd	ra,40(sp)
    80002aea:	f022                	sd	s0,32(sp)
    80002aec:	ec26                	sd	s1,24(sp)
    80002aee:	e84a                	sd	s2,16(sp)
    80002af0:	e44e                	sd	s3,8(sp)
    80002af2:	1800                	addi	s0,sp,48
    80002af4:	892a                	mv	s2,a0
    80002af6:	84ae                	mv	s1,a1
    80002af8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002afa:	fffff097          	auipc	ra,0xfffff
    80002afe:	eb2080e7          	jalr	-334(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b02:	86ce                	mv	a3,s3
    80002b04:	864a                	mv	a2,s2
    80002b06:	85a6                	mv	a1,s1
    80002b08:	6928                	ld	a0,80(a0)
    80002b0a:	fffff097          	auipc	ra,0xfffff
    80002b0e:	c7c080e7          	jalr	-900(ra) # 80001786 <copyinstr>
    80002b12:	00054e63          	bltz	a0,80002b2e <fetchstr+0x48>
  return strlen(buf);
    80002b16:	8526                	mv	a0,s1
    80002b18:	ffffe097          	auipc	ra,0xffffe
    80002b1c:	336080e7          	jalr	822(ra) # 80000e4e <strlen>
}
    80002b20:	70a2                	ld	ra,40(sp)
    80002b22:	7402                	ld	s0,32(sp)
    80002b24:	64e2                	ld	s1,24(sp)
    80002b26:	6942                	ld	s2,16(sp)
    80002b28:	69a2                	ld	s3,8(sp)
    80002b2a:	6145                	addi	sp,sp,48
    80002b2c:	8082                	ret
    return -1;
    80002b2e:	557d                	li	a0,-1
    80002b30:	bfc5                	j	80002b20 <fetchstr+0x3a>

0000000080002b32 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b32:	1101                	addi	sp,sp,-32
    80002b34:	ec06                	sd	ra,24(sp)
    80002b36:	e822                	sd	s0,16(sp)
    80002b38:	e426                	sd	s1,8(sp)
    80002b3a:	1000                	addi	s0,sp,32
    80002b3c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b3e:	00000097          	auipc	ra,0x0
    80002b42:	eee080e7          	jalr	-274(ra) # 80002a2c <argraw>
    80002b46:	c088                	sw	a0,0(s1)
}
    80002b48:	60e2                	ld	ra,24(sp)
    80002b4a:	6442                	ld	s0,16(sp)
    80002b4c:	64a2                	ld	s1,8(sp)
    80002b4e:	6105                	addi	sp,sp,32
    80002b50:	8082                	ret

0000000080002b52 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b52:	1101                	addi	sp,sp,-32
    80002b54:	ec06                	sd	ra,24(sp)
    80002b56:	e822                	sd	s0,16(sp)
    80002b58:	e426                	sd	s1,8(sp)
    80002b5a:	1000                	addi	s0,sp,32
    80002b5c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b5e:	00000097          	auipc	ra,0x0
    80002b62:	ece080e7          	jalr	-306(ra) # 80002a2c <argraw>
    80002b66:	e088                	sd	a0,0(s1)
}
    80002b68:	60e2                	ld	ra,24(sp)
    80002b6a:	6442                	ld	s0,16(sp)
    80002b6c:	64a2                	ld	s1,8(sp)
    80002b6e:	6105                	addi	sp,sp,32
    80002b70:	8082                	ret

0000000080002b72 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b72:	7179                	addi	sp,sp,-48
    80002b74:	f406                	sd	ra,40(sp)
    80002b76:	f022                	sd	s0,32(sp)
    80002b78:	ec26                	sd	s1,24(sp)
    80002b7a:	e84a                	sd	s2,16(sp)
    80002b7c:	1800                	addi	s0,sp,48
    80002b7e:	84ae                	mv	s1,a1
    80002b80:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b82:	fd840593          	addi	a1,s0,-40
    80002b86:	00000097          	auipc	ra,0x0
    80002b8a:	fcc080e7          	jalr	-52(ra) # 80002b52 <argaddr>
  return fetchstr(addr, buf, max);
    80002b8e:	864a                	mv	a2,s2
    80002b90:	85a6                	mv	a1,s1
    80002b92:	fd843503          	ld	a0,-40(s0)
    80002b96:	00000097          	auipc	ra,0x0
    80002b9a:	f50080e7          	jalr	-176(ra) # 80002ae6 <fetchstr>
}
    80002b9e:	70a2                	ld	ra,40(sp)
    80002ba0:	7402                	ld	s0,32(sp)
    80002ba2:	64e2                	ld	s1,24(sp)
    80002ba4:	6942                	ld	s2,16(sp)
    80002ba6:	6145                	addi	sp,sp,48
    80002ba8:	8082                	ret

0000000080002baa <syscall>:
[SYS_ps]      sys_ps,
};

void
syscall(void)
{
    80002baa:	1101                	addi	sp,sp,-32
    80002bac:	ec06                	sd	ra,24(sp)
    80002bae:	e822                	sd	s0,16(sp)
    80002bb0:	e426                	sd	s1,8(sp)
    80002bb2:	e04a                	sd	s2,0(sp)
    80002bb4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bb6:	fffff097          	auipc	ra,0xfffff
    80002bba:	df6080e7          	jalr	-522(ra) # 800019ac <myproc>
    80002bbe:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bc0:	05853903          	ld	s2,88(a0)
    80002bc4:	0a893783          	ld	a5,168(s2)
    80002bc8:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bcc:	37fd                	addiw	a5,a5,-1
    80002bce:	4755                	li	a4,21
    80002bd0:	00f76f63          	bltu	a4,a5,80002bee <syscall+0x44>
    80002bd4:	00369713          	slli	a4,a3,0x3
    80002bd8:	00006797          	auipc	a5,0x6
    80002bdc:	89078793          	addi	a5,a5,-1904 # 80008468 <syscalls>
    80002be0:	97ba                	add	a5,a5,a4
    80002be2:	639c                	ld	a5,0(a5)
    80002be4:	c789                	beqz	a5,80002bee <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002be6:	9782                	jalr	a5
    80002be8:	06a93823          	sd	a0,112(s2)
    80002bec:	a839                	j	80002c0a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bee:	15848613          	addi	a2,s1,344
    80002bf2:	588c                	lw	a1,48(s1)
    80002bf4:	00006517          	auipc	a0,0x6
    80002bf8:	83c50513          	addi	a0,a0,-1988 # 80008430 <states.0+0x150>
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	98e080e7          	jalr	-1650(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c04:	6cbc                	ld	a5,88(s1)
    80002c06:	577d                	li	a4,-1
    80002c08:	fbb8                	sd	a4,112(a5)
  }
}
    80002c0a:	60e2                	ld	ra,24(sp)
    80002c0c:	6442                	ld	s0,16(sp)
    80002c0e:	64a2                	ld	s1,8(sp)
    80002c10:	6902                	ld	s2,0(sp)
    80002c12:	6105                	addi	sp,sp,32
    80002c14:	8082                	ret

0000000080002c16 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c16:	1101                	addi	sp,sp,-32
    80002c18:	ec06                	sd	ra,24(sp)
    80002c1a:	e822                	sd	s0,16(sp)
    80002c1c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c1e:	fec40593          	addi	a1,s0,-20
    80002c22:	4501                	li	a0,0
    80002c24:	00000097          	auipc	ra,0x0
    80002c28:	f0e080e7          	jalr	-242(ra) # 80002b32 <argint>
  exit(n);
    80002c2c:	fec42503          	lw	a0,-20(s0)
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	558080e7          	jalr	1368(ra) # 80002188 <exit>
  return 0;  // not reached
}
    80002c38:	4501                	li	a0,0
    80002c3a:	60e2                	ld	ra,24(sp)
    80002c3c:	6442                	ld	s0,16(sp)
    80002c3e:	6105                	addi	sp,sp,32
    80002c40:	8082                	ret

0000000080002c42 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c42:	1141                	addi	sp,sp,-16
    80002c44:	e406                	sd	ra,8(sp)
    80002c46:	e022                	sd	s0,0(sp)
    80002c48:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c4a:	fffff097          	auipc	ra,0xfffff
    80002c4e:	d62080e7          	jalr	-670(ra) # 800019ac <myproc>
}
    80002c52:	5908                	lw	a0,48(a0)
    80002c54:	60a2                	ld	ra,8(sp)
    80002c56:	6402                	ld	s0,0(sp)
    80002c58:	0141                	addi	sp,sp,16
    80002c5a:	8082                	ret

0000000080002c5c <sys_fork>:

uint64
sys_fork(void)
{
    80002c5c:	1141                	addi	sp,sp,-16
    80002c5e:	e406                	sd	ra,8(sp)
    80002c60:	e022                	sd	s0,0(sp)
    80002c62:	0800                	addi	s0,sp,16
  return fork();
    80002c64:	fffff097          	auipc	ra,0xfffff
    80002c68:	0fe080e7          	jalr	254(ra) # 80001d62 <fork>
}
    80002c6c:	60a2                	ld	ra,8(sp)
    80002c6e:	6402                	ld	s0,0(sp)
    80002c70:	0141                	addi	sp,sp,16
    80002c72:	8082                	ret

0000000080002c74 <sys_wait>:

uint64
sys_wait(void)
{
    80002c74:	1101                	addi	sp,sp,-32
    80002c76:	ec06                	sd	ra,24(sp)
    80002c78:	e822                	sd	s0,16(sp)
    80002c7a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c7c:	fe840593          	addi	a1,s0,-24
    80002c80:	4501                	li	a0,0
    80002c82:	00000097          	auipc	ra,0x0
    80002c86:	ed0080e7          	jalr	-304(ra) # 80002b52 <argaddr>
  return wait(p);
    80002c8a:	fe843503          	ld	a0,-24(s0)
    80002c8e:	fffff097          	auipc	ra,0xfffff
    80002c92:	6a0080e7          	jalr	1696(ra) # 8000232e <wait>
}
    80002c96:	60e2                	ld	ra,24(sp)
    80002c98:	6442                	ld	s0,16(sp)
    80002c9a:	6105                	addi	sp,sp,32
    80002c9c:	8082                	ret

0000000080002c9e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c9e:	7179                	addi	sp,sp,-48
    80002ca0:	f406                	sd	ra,40(sp)
    80002ca2:	f022                	sd	s0,32(sp)
    80002ca4:	ec26                	sd	s1,24(sp)
    80002ca6:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ca8:	fdc40593          	addi	a1,s0,-36
    80002cac:	4501                	li	a0,0
    80002cae:	00000097          	auipc	ra,0x0
    80002cb2:	e84080e7          	jalr	-380(ra) # 80002b32 <argint>
  addr = myproc()->sz;
    80002cb6:	fffff097          	auipc	ra,0xfffff
    80002cba:	cf6080e7          	jalr	-778(ra) # 800019ac <myproc>
    80002cbe:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002cc0:	fdc42503          	lw	a0,-36(s0)
    80002cc4:	fffff097          	auipc	ra,0xfffff
    80002cc8:	042080e7          	jalr	66(ra) # 80001d06 <growproc>
    80002ccc:	00054863          	bltz	a0,80002cdc <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002cd0:	8526                	mv	a0,s1
    80002cd2:	70a2                	ld	ra,40(sp)
    80002cd4:	7402                	ld	s0,32(sp)
    80002cd6:	64e2                	ld	s1,24(sp)
    80002cd8:	6145                	addi	sp,sp,48
    80002cda:	8082                	ret
    return -1;
    80002cdc:	54fd                	li	s1,-1
    80002cde:	bfcd                	j	80002cd0 <sys_sbrk+0x32>

0000000080002ce0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ce0:	7139                	addi	sp,sp,-64
    80002ce2:	fc06                	sd	ra,56(sp)
    80002ce4:	f822                	sd	s0,48(sp)
    80002ce6:	f426                	sd	s1,40(sp)
    80002ce8:	f04a                	sd	s2,32(sp)
    80002cea:	ec4e                	sd	s3,24(sp)
    80002cec:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cee:	fcc40593          	addi	a1,s0,-52
    80002cf2:	4501                	li	a0,0
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	e3e080e7          	jalr	-450(ra) # 80002b32 <argint>
  acquire(&tickslock);
    80002cfc:	00014517          	auipc	a0,0x14
    80002d00:	ca450513          	addi	a0,a0,-860 # 800169a0 <tickslock>
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	ed2080e7          	jalr	-302(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002d0c:	00006917          	auipc	s2,0x6
    80002d10:	bf492903          	lw	s2,-1036(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80002d14:	fcc42783          	lw	a5,-52(s0)
    80002d18:	cf9d                	beqz	a5,80002d56 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d1a:	00014997          	auipc	s3,0x14
    80002d1e:	c8698993          	addi	s3,s3,-890 # 800169a0 <tickslock>
    80002d22:	00006497          	auipc	s1,0x6
    80002d26:	bde48493          	addi	s1,s1,-1058 # 80008900 <ticks>
    if(killed(myproc())){
    80002d2a:	fffff097          	auipc	ra,0xfffff
    80002d2e:	c82080e7          	jalr	-894(ra) # 800019ac <myproc>
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	5ca080e7          	jalr	1482(ra) # 800022fc <killed>
    80002d3a:	ed15                	bnez	a0,80002d76 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d3c:	85ce                	mv	a1,s3
    80002d3e:	8526                	mv	a0,s1
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	314080e7          	jalr	788(ra) # 80002054 <sleep>
  while(ticks - ticks0 < n){
    80002d48:	409c                	lw	a5,0(s1)
    80002d4a:	412787bb          	subw	a5,a5,s2
    80002d4e:	fcc42703          	lw	a4,-52(s0)
    80002d52:	fce7ece3          	bltu	a5,a4,80002d2a <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002d56:	00014517          	auipc	a0,0x14
    80002d5a:	c4a50513          	addi	a0,a0,-950 # 800169a0 <tickslock>
    80002d5e:	ffffe097          	auipc	ra,0xffffe
    80002d62:	f2c080e7          	jalr	-212(ra) # 80000c8a <release>
  return 0;
    80002d66:	4501                	li	a0,0
}
    80002d68:	70e2                	ld	ra,56(sp)
    80002d6a:	7442                	ld	s0,48(sp)
    80002d6c:	74a2                	ld	s1,40(sp)
    80002d6e:	7902                	ld	s2,32(sp)
    80002d70:	69e2                	ld	s3,24(sp)
    80002d72:	6121                	addi	sp,sp,64
    80002d74:	8082                	ret
      release(&tickslock);
    80002d76:	00014517          	auipc	a0,0x14
    80002d7a:	c2a50513          	addi	a0,a0,-982 # 800169a0 <tickslock>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	f0c080e7          	jalr	-244(ra) # 80000c8a <release>
      return -1;
    80002d86:	557d                	li	a0,-1
    80002d88:	b7c5                	j	80002d68 <sys_sleep+0x88>

0000000080002d8a <sys_kill>:

uint64
sys_kill(void)
{
    80002d8a:	1101                	addi	sp,sp,-32
    80002d8c:	ec06                	sd	ra,24(sp)
    80002d8e:	e822                	sd	s0,16(sp)
    80002d90:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d92:	fec40593          	addi	a1,s0,-20
    80002d96:	4501                	li	a0,0
    80002d98:	00000097          	auipc	ra,0x0
    80002d9c:	d9a080e7          	jalr	-614(ra) # 80002b32 <argint>
  return kill(pid);
    80002da0:	fec42503          	lw	a0,-20(s0)
    80002da4:	fffff097          	auipc	ra,0xfffff
    80002da8:	4ba080e7          	jalr	1210(ra) # 8000225e <kill>
}
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	6105                	addi	sp,sp,32
    80002db2:	8082                	ret

0000000080002db4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002db4:	1101                	addi	sp,sp,-32
    80002db6:	ec06                	sd	ra,24(sp)
    80002db8:	e822                	sd	s0,16(sp)
    80002dba:	e426                	sd	s1,8(sp)
    80002dbc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dbe:	00014517          	auipc	a0,0x14
    80002dc2:	be250513          	addi	a0,a0,-1054 # 800169a0 <tickslock>
    80002dc6:	ffffe097          	auipc	ra,0xffffe
    80002dca:	e10080e7          	jalr	-496(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002dce:	00006497          	auipc	s1,0x6
    80002dd2:	b324a483          	lw	s1,-1230(s1) # 80008900 <ticks>
  release(&tickslock);
    80002dd6:	00014517          	auipc	a0,0x14
    80002dda:	bca50513          	addi	a0,a0,-1078 # 800169a0 <tickslock>
    80002dde:	ffffe097          	auipc	ra,0xffffe
    80002de2:	eac080e7          	jalr	-340(ra) # 80000c8a <release>
  return xticks;
}
    80002de6:	02049513          	slli	a0,s1,0x20
    80002dea:	9101                	srli	a0,a0,0x20
    80002dec:	60e2                	ld	ra,24(sp)
    80002dee:	6442                	ld	s0,16(sp)
    80002df0:	64a2                	ld	s1,8(sp)
    80002df2:	6105                	addi	sp,sp,32
    80002df4:	8082                	ret

0000000080002df6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002df6:	7179                	addi	sp,sp,-48
    80002df8:	f406                	sd	ra,40(sp)
    80002dfa:	f022                	sd	s0,32(sp)
    80002dfc:	ec26                	sd	s1,24(sp)
    80002dfe:	e84a                	sd	s2,16(sp)
    80002e00:	e44e                	sd	s3,8(sp)
    80002e02:	e052                	sd	s4,0(sp)
    80002e04:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e06:	00005597          	auipc	a1,0x5
    80002e0a:	71a58593          	addi	a1,a1,1818 # 80008520 <syscalls+0xb8>
    80002e0e:	00014517          	auipc	a0,0x14
    80002e12:	baa50513          	addi	a0,a0,-1110 # 800169b8 <bcache>
    80002e16:	ffffe097          	auipc	ra,0xffffe
    80002e1a:	d30080e7          	jalr	-720(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e1e:	0001c797          	auipc	a5,0x1c
    80002e22:	b9a78793          	addi	a5,a5,-1126 # 8001e9b8 <bcache+0x8000>
    80002e26:	0001c717          	auipc	a4,0x1c
    80002e2a:	dfa70713          	addi	a4,a4,-518 # 8001ec20 <bcache+0x8268>
    80002e2e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e32:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e36:	00014497          	auipc	s1,0x14
    80002e3a:	b9a48493          	addi	s1,s1,-1126 # 800169d0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e3e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e40:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e42:	00005a17          	auipc	s4,0x5
    80002e46:	6e6a0a13          	addi	s4,s4,1766 # 80008528 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002e4a:	2b893783          	ld	a5,696(s2)
    80002e4e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e50:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e54:	85d2                	mv	a1,s4
    80002e56:	01048513          	addi	a0,s1,16
    80002e5a:	00001097          	auipc	ra,0x1
    80002e5e:	4c8080e7          	jalr	1224(ra) # 80004322 <initsleeplock>
    bcache.head.next->prev = b;
    80002e62:	2b893783          	ld	a5,696(s2)
    80002e66:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e68:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e6c:	45848493          	addi	s1,s1,1112
    80002e70:	fd349de3          	bne	s1,s3,80002e4a <binit+0x54>
  }
}
    80002e74:	70a2                	ld	ra,40(sp)
    80002e76:	7402                	ld	s0,32(sp)
    80002e78:	64e2                	ld	s1,24(sp)
    80002e7a:	6942                	ld	s2,16(sp)
    80002e7c:	69a2                	ld	s3,8(sp)
    80002e7e:	6a02                	ld	s4,0(sp)
    80002e80:	6145                	addi	sp,sp,48
    80002e82:	8082                	ret

0000000080002e84 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e84:	7179                	addi	sp,sp,-48
    80002e86:	f406                	sd	ra,40(sp)
    80002e88:	f022                	sd	s0,32(sp)
    80002e8a:	ec26                	sd	s1,24(sp)
    80002e8c:	e84a                	sd	s2,16(sp)
    80002e8e:	e44e                	sd	s3,8(sp)
    80002e90:	1800                	addi	s0,sp,48
    80002e92:	892a                	mv	s2,a0
    80002e94:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e96:	00014517          	auipc	a0,0x14
    80002e9a:	b2250513          	addi	a0,a0,-1246 # 800169b8 <bcache>
    80002e9e:	ffffe097          	auipc	ra,0xffffe
    80002ea2:	d38080e7          	jalr	-712(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ea6:	0001c497          	auipc	s1,0x1c
    80002eaa:	dca4b483          	ld	s1,-566(s1) # 8001ec70 <bcache+0x82b8>
    80002eae:	0001c797          	auipc	a5,0x1c
    80002eb2:	d7278793          	addi	a5,a5,-654 # 8001ec20 <bcache+0x8268>
    80002eb6:	02f48f63          	beq	s1,a5,80002ef4 <bread+0x70>
    80002eba:	873e                	mv	a4,a5
    80002ebc:	a021                	j	80002ec4 <bread+0x40>
    80002ebe:	68a4                	ld	s1,80(s1)
    80002ec0:	02e48a63          	beq	s1,a4,80002ef4 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ec4:	449c                	lw	a5,8(s1)
    80002ec6:	ff279ce3          	bne	a5,s2,80002ebe <bread+0x3a>
    80002eca:	44dc                	lw	a5,12(s1)
    80002ecc:	ff3799e3          	bne	a5,s3,80002ebe <bread+0x3a>
      b->refcnt++;
    80002ed0:	40bc                	lw	a5,64(s1)
    80002ed2:	2785                	addiw	a5,a5,1
    80002ed4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ed6:	00014517          	auipc	a0,0x14
    80002eda:	ae250513          	addi	a0,a0,-1310 # 800169b8 <bcache>
    80002ede:	ffffe097          	auipc	ra,0xffffe
    80002ee2:	dac080e7          	jalr	-596(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002ee6:	01048513          	addi	a0,s1,16
    80002eea:	00001097          	auipc	ra,0x1
    80002eee:	472080e7          	jalr	1138(ra) # 8000435c <acquiresleep>
      return b;
    80002ef2:	a8b9                	j	80002f50 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ef4:	0001c497          	auipc	s1,0x1c
    80002ef8:	d744b483          	ld	s1,-652(s1) # 8001ec68 <bcache+0x82b0>
    80002efc:	0001c797          	auipc	a5,0x1c
    80002f00:	d2478793          	addi	a5,a5,-732 # 8001ec20 <bcache+0x8268>
    80002f04:	00f48863          	beq	s1,a5,80002f14 <bread+0x90>
    80002f08:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f0a:	40bc                	lw	a5,64(s1)
    80002f0c:	cf81                	beqz	a5,80002f24 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f0e:	64a4                	ld	s1,72(s1)
    80002f10:	fee49de3          	bne	s1,a4,80002f0a <bread+0x86>
  panic("bget: no buffers");
    80002f14:	00005517          	auipc	a0,0x5
    80002f18:	61c50513          	addi	a0,a0,1564 # 80008530 <syscalls+0xc8>
    80002f1c:	ffffd097          	auipc	ra,0xffffd
    80002f20:	624080e7          	jalr	1572(ra) # 80000540 <panic>
      b->dev = dev;
    80002f24:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f28:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f2c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f30:	4785                	li	a5,1
    80002f32:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f34:	00014517          	auipc	a0,0x14
    80002f38:	a8450513          	addi	a0,a0,-1404 # 800169b8 <bcache>
    80002f3c:	ffffe097          	auipc	ra,0xffffe
    80002f40:	d4e080e7          	jalr	-690(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f44:	01048513          	addi	a0,s1,16
    80002f48:	00001097          	auipc	ra,0x1
    80002f4c:	414080e7          	jalr	1044(ra) # 8000435c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f50:	409c                	lw	a5,0(s1)
    80002f52:	cb89                	beqz	a5,80002f64 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f54:	8526                	mv	a0,s1
    80002f56:	70a2                	ld	ra,40(sp)
    80002f58:	7402                	ld	s0,32(sp)
    80002f5a:	64e2                	ld	s1,24(sp)
    80002f5c:	6942                	ld	s2,16(sp)
    80002f5e:	69a2                	ld	s3,8(sp)
    80002f60:	6145                	addi	sp,sp,48
    80002f62:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f64:	4581                	li	a1,0
    80002f66:	8526                	mv	a0,s1
    80002f68:	00003097          	auipc	ra,0x3
    80002f6c:	fda080e7          	jalr	-38(ra) # 80005f42 <virtio_disk_rw>
    b->valid = 1;
    80002f70:	4785                	li	a5,1
    80002f72:	c09c                	sw	a5,0(s1)
  return b;
    80002f74:	b7c5                	j	80002f54 <bread+0xd0>

0000000080002f76 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f76:	1101                	addi	sp,sp,-32
    80002f78:	ec06                	sd	ra,24(sp)
    80002f7a:	e822                	sd	s0,16(sp)
    80002f7c:	e426                	sd	s1,8(sp)
    80002f7e:	1000                	addi	s0,sp,32
    80002f80:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f82:	0541                	addi	a0,a0,16
    80002f84:	00001097          	auipc	ra,0x1
    80002f88:	472080e7          	jalr	1138(ra) # 800043f6 <holdingsleep>
    80002f8c:	cd01                	beqz	a0,80002fa4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f8e:	4585                	li	a1,1
    80002f90:	8526                	mv	a0,s1
    80002f92:	00003097          	auipc	ra,0x3
    80002f96:	fb0080e7          	jalr	-80(ra) # 80005f42 <virtio_disk_rw>
}
    80002f9a:	60e2                	ld	ra,24(sp)
    80002f9c:	6442                	ld	s0,16(sp)
    80002f9e:	64a2                	ld	s1,8(sp)
    80002fa0:	6105                	addi	sp,sp,32
    80002fa2:	8082                	ret
    panic("bwrite");
    80002fa4:	00005517          	auipc	a0,0x5
    80002fa8:	5a450513          	addi	a0,a0,1444 # 80008548 <syscalls+0xe0>
    80002fac:	ffffd097          	auipc	ra,0xffffd
    80002fb0:	594080e7          	jalr	1428(ra) # 80000540 <panic>

0000000080002fb4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fb4:	1101                	addi	sp,sp,-32
    80002fb6:	ec06                	sd	ra,24(sp)
    80002fb8:	e822                	sd	s0,16(sp)
    80002fba:	e426                	sd	s1,8(sp)
    80002fbc:	e04a                	sd	s2,0(sp)
    80002fbe:	1000                	addi	s0,sp,32
    80002fc0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fc2:	01050913          	addi	s2,a0,16
    80002fc6:	854a                	mv	a0,s2
    80002fc8:	00001097          	auipc	ra,0x1
    80002fcc:	42e080e7          	jalr	1070(ra) # 800043f6 <holdingsleep>
    80002fd0:	c92d                	beqz	a0,80003042 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002fd2:	854a                	mv	a0,s2
    80002fd4:	00001097          	auipc	ra,0x1
    80002fd8:	3de080e7          	jalr	990(ra) # 800043b2 <releasesleep>

  acquire(&bcache.lock);
    80002fdc:	00014517          	auipc	a0,0x14
    80002fe0:	9dc50513          	addi	a0,a0,-1572 # 800169b8 <bcache>
    80002fe4:	ffffe097          	auipc	ra,0xffffe
    80002fe8:	bf2080e7          	jalr	-1038(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002fec:	40bc                	lw	a5,64(s1)
    80002fee:	37fd                	addiw	a5,a5,-1
    80002ff0:	0007871b          	sext.w	a4,a5
    80002ff4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002ff6:	eb05                	bnez	a4,80003026 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002ff8:	68bc                	ld	a5,80(s1)
    80002ffa:	64b8                	ld	a4,72(s1)
    80002ffc:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002ffe:	64bc                	ld	a5,72(s1)
    80003000:	68b8                	ld	a4,80(s1)
    80003002:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003004:	0001c797          	auipc	a5,0x1c
    80003008:	9b478793          	addi	a5,a5,-1612 # 8001e9b8 <bcache+0x8000>
    8000300c:	2b87b703          	ld	a4,696(a5)
    80003010:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003012:	0001c717          	auipc	a4,0x1c
    80003016:	c0e70713          	addi	a4,a4,-1010 # 8001ec20 <bcache+0x8268>
    8000301a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000301c:	2b87b703          	ld	a4,696(a5)
    80003020:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003022:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003026:	00014517          	auipc	a0,0x14
    8000302a:	99250513          	addi	a0,a0,-1646 # 800169b8 <bcache>
    8000302e:	ffffe097          	auipc	ra,0xffffe
    80003032:	c5c080e7          	jalr	-932(ra) # 80000c8a <release>
}
    80003036:	60e2                	ld	ra,24(sp)
    80003038:	6442                	ld	s0,16(sp)
    8000303a:	64a2                	ld	s1,8(sp)
    8000303c:	6902                	ld	s2,0(sp)
    8000303e:	6105                	addi	sp,sp,32
    80003040:	8082                	ret
    panic("brelse");
    80003042:	00005517          	auipc	a0,0x5
    80003046:	50e50513          	addi	a0,a0,1294 # 80008550 <syscalls+0xe8>
    8000304a:	ffffd097          	auipc	ra,0xffffd
    8000304e:	4f6080e7          	jalr	1270(ra) # 80000540 <panic>

0000000080003052 <bpin>:

void
bpin(struct buf *b) {
    80003052:	1101                	addi	sp,sp,-32
    80003054:	ec06                	sd	ra,24(sp)
    80003056:	e822                	sd	s0,16(sp)
    80003058:	e426                	sd	s1,8(sp)
    8000305a:	1000                	addi	s0,sp,32
    8000305c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000305e:	00014517          	auipc	a0,0x14
    80003062:	95a50513          	addi	a0,a0,-1702 # 800169b8 <bcache>
    80003066:	ffffe097          	auipc	ra,0xffffe
    8000306a:	b70080e7          	jalr	-1168(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000306e:	40bc                	lw	a5,64(s1)
    80003070:	2785                	addiw	a5,a5,1
    80003072:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003074:	00014517          	auipc	a0,0x14
    80003078:	94450513          	addi	a0,a0,-1724 # 800169b8 <bcache>
    8000307c:	ffffe097          	auipc	ra,0xffffe
    80003080:	c0e080e7          	jalr	-1010(ra) # 80000c8a <release>
}
    80003084:	60e2                	ld	ra,24(sp)
    80003086:	6442                	ld	s0,16(sp)
    80003088:	64a2                	ld	s1,8(sp)
    8000308a:	6105                	addi	sp,sp,32
    8000308c:	8082                	ret

000000008000308e <bunpin>:

void
bunpin(struct buf *b) {
    8000308e:	1101                	addi	sp,sp,-32
    80003090:	ec06                	sd	ra,24(sp)
    80003092:	e822                	sd	s0,16(sp)
    80003094:	e426                	sd	s1,8(sp)
    80003096:	1000                	addi	s0,sp,32
    80003098:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000309a:	00014517          	auipc	a0,0x14
    8000309e:	91e50513          	addi	a0,a0,-1762 # 800169b8 <bcache>
    800030a2:	ffffe097          	auipc	ra,0xffffe
    800030a6:	b34080e7          	jalr	-1228(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800030aa:	40bc                	lw	a5,64(s1)
    800030ac:	37fd                	addiw	a5,a5,-1
    800030ae:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030b0:	00014517          	auipc	a0,0x14
    800030b4:	90850513          	addi	a0,a0,-1784 # 800169b8 <bcache>
    800030b8:	ffffe097          	auipc	ra,0xffffe
    800030bc:	bd2080e7          	jalr	-1070(ra) # 80000c8a <release>
}
    800030c0:	60e2                	ld	ra,24(sp)
    800030c2:	6442                	ld	s0,16(sp)
    800030c4:	64a2                	ld	s1,8(sp)
    800030c6:	6105                	addi	sp,sp,32
    800030c8:	8082                	ret

00000000800030ca <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030ca:	1101                	addi	sp,sp,-32
    800030cc:	ec06                	sd	ra,24(sp)
    800030ce:	e822                	sd	s0,16(sp)
    800030d0:	e426                	sd	s1,8(sp)
    800030d2:	e04a                	sd	s2,0(sp)
    800030d4:	1000                	addi	s0,sp,32
    800030d6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030d8:	00d5d59b          	srliw	a1,a1,0xd
    800030dc:	0001c797          	auipc	a5,0x1c
    800030e0:	fb87a783          	lw	a5,-72(a5) # 8001f094 <sb+0x1c>
    800030e4:	9dbd                	addw	a1,a1,a5
    800030e6:	00000097          	auipc	ra,0x0
    800030ea:	d9e080e7          	jalr	-610(ra) # 80002e84 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030ee:	0074f713          	andi	a4,s1,7
    800030f2:	4785                	li	a5,1
    800030f4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030f8:	14ce                	slli	s1,s1,0x33
    800030fa:	90d9                	srli	s1,s1,0x36
    800030fc:	00950733          	add	a4,a0,s1
    80003100:	05874703          	lbu	a4,88(a4)
    80003104:	00e7f6b3          	and	a3,a5,a4
    80003108:	c69d                	beqz	a3,80003136 <bfree+0x6c>
    8000310a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000310c:	94aa                	add	s1,s1,a0
    8000310e:	fff7c793          	not	a5,a5
    80003112:	8f7d                	and	a4,a4,a5
    80003114:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003118:	00001097          	auipc	ra,0x1
    8000311c:	126080e7          	jalr	294(ra) # 8000423e <log_write>
  brelse(bp);
    80003120:	854a                	mv	a0,s2
    80003122:	00000097          	auipc	ra,0x0
    80003126:	e92080e7          	jalr	-366(ra) # 80002fb4 <brelse>
}
    8000312a:	60e2                	ld	ra,24(sp)
    8000312c:	6442                	ld	s0,16(sp)
    8000312e:	64a2                	ld	s1,8(sp)
    80003130:	6902                	ld	s2,0(sp)
    80003132:	6105                	addi	sp,sp,32
    80003134:	8082                	ret
    panic("freeing free block");
    80003136:	00005517          	auipc	a0,0x5
    8000313a:	42250513          	addi	a0,a0,1058 # 80008558 <syscalls+0xf0>
    8000313e:	ffffd097          	auipc	ra,0xffffd
    80003142:	402080e7          	jalr	1026(ra) # 80000540 <panic>

0000000080003146 <balloc>:
{
    80003146:	711d                	addi	sp,sp,-96
    80003148:	ec86                	sd	ra,88(sp)
    8000314a:	e8a2                	sd	s0,80(sp)
    8000314c:	e4a6                	sd	s1,72(sp)
    8000314e:	e0ca                	sd	s2,64(sp)
    80003150:	fc4e                	sd	s3,56(sp)
    80003152:	f852                	sd	s4,48(sp)
    80003154:	f456                	sd	s5,40(sp)
    80003156:	f05a                	sd	s6,32(sp)
    80003158:	ec5e                	sd	s7,24(sp)
    8000315a:	e862                	sd	s8,16(sp)
    8000315c:	e466                	sd	s9,8(sp)
    8000315e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003160:	0001c797          	auipc	a5,0x1c
    80003164:	f1c7a783          	lw	a5,-228(a5) # 8001f07c <sb+0x4>
    80003168:	cff5                	beqz	a5,80003264 <balloc+0x11e>
    8000316a:	8baa                	mv	s7,a0
    8000316c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000316e:	0001cb17          	auipc	s6,0x1c
    80003172:	f0ab0b13          	addi	s6,s6,-246 # 8001f078 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003176:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003178:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000317a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000317c:	6c89                	lui	s9,0x2
    8000317e:	a061                	j	80003206 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003180:	97ca                	add	a5,a5,s2
    80003182:	8e55                	or	a2,a2,a3
    80003184:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003188:	854a                	mv	a0,s2
    8000318a:	00001097          	auipc	ra,0x1
    8000318e:	0b4080e7          	jalr	180(ra) # 8000423e <log_write>
        brelse(bp);
    80003192:	854a                	mv	a0,s2
    80003194:	00000097          	auipc	ra,0x0
    80003198:	e20080e7          	jalr	-480(ra) # 80002fb4 <brelse>
  bp = bread(dev, bno);
    8000319c:	85a6                	mv	a1,s1
    8000319e:	855e                	mv	a0,s7
    800031a0:	00000097          	auipc	ra,0x0
    800031a4:	ce4080e7          	jalr	-796(ra) # 80002e84 <bread>
    800031a8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031aa:	40000613          	li	a2,1024
    800031ae:	4581                	li	a1,0
    800031b0:	05850513          	addi	a0,a0,88
    800031b4:	ffffe097          	auipc	ra,0xffffe
    800031b8:	b1e080e7          	jalr	-1250(ra) # 80000cd2 <memset>
  log_write(bp);
    800031bc:	854a                	mv	a0,s2
    800031be:	00001097          	auipc	ra,0x1
    800031c2:	080080e7          	jalr	128(ra) # 8000423e <log_write>
  brelse(bp);
    800031c6:	854a                	mv	a0,s2
    800031c8:	00000097          	auipc	ra,0x0
    800031cc:	dec080e7          	jalr	-532(ra) # 80002fb4 <brelse>
}
    800031d0:	8526                	mv	a0,s1
    800031d2:	60e6                	ld	ra,88(sp)
    800031d4:	6446                	ld	s0,80(sp)
    800031d6:	64a6                	ld	s1,72(sp)
    800031d8:	6906                	ld	s2,64(sp)
    800031da:	79e2                	ld	s3,56(sp)
    800031dc:	7a42                	ld	s4,48(sp)
    800031de:	7aa2                	ld	s5,40(sp)
    800031e0:	7b02                	ld	s6,32(sp)
    800031e2:	6be2                	ld	s7,24(sp)
    800031e4:	6c42                	ld	s8,16(sp)
    800031e6:	6ca2                	ld	s9,8(sp)
    800031e8:	6125                	addi	sp,sp,96
    800031ea:	8082                	ret
    brelse(bp);
    800031ec:	854a                	mv	a0,s2
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	dc6080e7          	jalr	-570(ra) # 80002fb4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031f6:	015c87bb          	addw	a5,s9,s5
    800031fa:	00078a9b          	sext.w	s5,a5
    800031fe:	004b2703          	lw	a4,4(s6)
    80003202:	06eaf163          	bgeu	s5,a4,80003264 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003206:	41fad79b          	sraiw	a5,s5,0x1f
    8000320a:	0137d79b          	srliw	a5,a5,0x13
    8000320e:	015787bb          	addw	a5,a5,s5
    80003212:	40d7d79b          	sraiw	a5,a5,0xd
    80003216:	01cb2583          	lw	a1,28(s6)
    8000321a:	9dbd                	addw	a1,a1,a5
    8000321c:	855e                	mv	a0,s7
    8000321e:	00000097          	auipc	ra,0x0
    80003222:	c66080e7          	jalr	-922(ra) # 80002e84 <bread>
    80003226:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003228:	004b2503          	lw	a0,4(s6)
    8000322c:	000a849b          	sext.w	s1,s5
    80003230:	8762                	mv	a4,s8
    80003232:	faa4fde3          	bgeu	s1,a0,800031ec <balloc+0xa6>
      m = 1 << (bi % 8);
    80003236:	00777693          	andi	a3,a4,7
    8000323a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000323e:	41f7579b          	sraiw	a5,a4,0x1f
    80003242:	01d7d79b          	srliw	a5,a5,0x1d
    80003246:	9fb9                	addw	a5,a5,a4
    80003248:	4037d79b          	sraiw	a5,a5,0x3
    8000324c:	00f90633          	add	a2,s2,a5
    80003250:	05864603          	lbu	a2,88(a2)
    80003254:	00c6f5b3          	and	a1,a3,a2
    80003258:	d585                	beqz	a1,80003180 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000325a:	2705                	addiw	a4,a4,1
    8000325c:	2485                	addiw	s1,s1,1
    8000325e:	fd471ae3          	bne	a4,s4,80003232 <balloc+0xec>
    80003262:	b769                	j	800031ec <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003264:	00005517          	auipc	a0,0x5
    80003268:	30c50513          	addi	a0,a0,780 # 80008570 <syscalls+0x108>
    8000326c:	ffffd097          	auipc	ra,0xffffd
    80003270:	31e080e7          	jalr	798(ra) # 8000058a <printf>
  return 0;
    80003274:	4481                	li	s1,0
    80003276:	bfa9                	j	800031d0 <balloc+0x8a>

0000000080003278 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003278:	7179                	addi	sp,sp,-48
    8000327a:	f406                	sd	ra,40(sp)
    8000327c:	f022                	sd	s0,32(sp)
    8000327e:	ec26                	sd	s1,24(sp)
    80003280:	e84a                	sd	s2,16(sp)
    80003282:	e44e                	sd	s3,8(sp)
    80003284:	e052                	sd	s4,0(sp)
    80003286:	1800                	addi	s0,sp,48
    80003288:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000328a:	47ad                	li	a5,11
    8000328c:	02b7e863          	bltu	a5,a1,800032bc <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003290:	02059793          	slli	a5,a1,0x20
    80003294:	01e7d593          	srli	a1,a5,0x1e
    80003298:	00b504b3          	add	s1,a0,a1
    8000329c:	0504a903          	lw	s2,80(s1)
    800032a0:	06091e63          	bnez	s2,8000331c <bmap+0xa4>
      addr = balloc(ip->dev);
    800032a4:	4108                	lw	a0,0(a0)
    800032a6:	00000097          	auipc	ra,0x0
    800032aa:	ea0080e7          	jalr	-352(ra) # 80003146 <balloc>
    800032ae:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032b2:	06090563          	beqz	s2,8000331c <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800032b6:	0524a823          	sw	s2,80(s1)
    800032ba:	a08d                	j	8000331c <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800032bc:	ff45849b          	addiw	s1,a1,-12
    800032c0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032c4:	0ff00793          	li	a5,255
    800032c8:	08e7e563          	bltu	a5,a4,80003352 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800032cc:	08052903          	lw	s2,128(a0)
    800032d0:	00091d63          	bnez	s2,800032ea <bmap+0x72>
      addr = balloc(ip->dev);
    800032d4:	4108                	lw	a0,0(a0)
    800032d6:	00000097          	auipc	ra,0x0
    800032da:	e70080e7          	jalr	-400(ra) # 80003146 <balloc>
    800032de:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032e2:	02090d63          	beqz	s2,8000331c <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032e6:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800032ea:	85ca                	mv	a1,s2
    800032ec:	0009a503          	lw	a0,0(s3)
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	b94080e7          	jalr	-1132(ra) # 80002e84 <bread>
    800032f8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032fa:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032fe:	02049713          	slli	a4,s1,0x20
    80003302:	01e75593          	srli	a1,a4,0x1e
    80003306:	00b784b3          	add	s1,a5,a1
    8000330a:	0004a903          	lw	s2,0(s1)
    8000330e:	02090063          	beqz	s2,8000332e <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003312:	8552                	mv	a0,s4
    80003314:	00000097          	auipc	ra,0x0
    80003318:	ca0080e7          	jalr	-864(ra) # 80002fb4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000331c:	854a                	mv	a0,s2
    8000331e:	70a2                	ld	ra,40(sp)
    80003320:	7402                	ld	s0,32(sp)
    80003322:	64e2                	ld	s1,24(sp)
    80003324:	6942                	ld	s2,16(sp)
    80003326:	69a2                	ld	s3,8(sp)
    80003328:	6a02                	ld	s4,0(sp)
    8000332a:	6145                	addi	sp,sp,48
    8000332c:	8082                	ret
      addr = balloc(ip->dev);
    8000332e:	0009a503          	lw	a0,0(s3)
    80003332:	00000097          	auipc	ra,0x0
    80003336:	e14080e7          	jalr	-492(ra) # 80003146 <balloc>
    8000333a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000333e:	fc090ae3          	beqz	s2,80003312 <bmap+0x9a>
        a[bn] = addr;
    80003342:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003346:	8552                	mv	a0,s4
    80003348:	00001097          	auipc	ra,0x1
    8000334c:	ef6080e7          	jalr	-266(ra) # 8000423e <log_write>
    80003350:	b7c9                	j	80003312 <bmap+0x9a>
  panic("bmap: out of range");
    80003352:	00005517          	auipc	a0,0x5
    80003356:	23650513          	addi	a0,a0,566 # 80008588 <syscalls+0x120>
    8000335a:	ffffd097          	auipc	ra,0xffffd
    8000335e:	1e6080e7          	jalr	486(ra) # 80000540 <panic>

0000000080003362 <iget>:
{
    80003362:	7179                	addi	sp,sp,-48
    80003364:	f406                	sd	ra,40(sp)
    80003366:	f022                	sd	s0,32(sp)
    80003368:	ec26                	sd	s1,24(sp)
    8000336a:	e84a                	sd	s2,16(sp)
    8000336c:	e44e                	sd	s3,8(sp)
    8000336e:	e052                	sd	s4,0(sp)
    80003370:	1800                	addi	s0,sp,48
    80003372:	89aa                	mv	s3,a0
    80003374:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003376:	0001c517          	auipc	a0,0x1c
    8000337a:	d2250513          	addi	a0,a0,-734 # 8001f098 <itable>
    8000337e:	ffffe097          	auipc	ra,0xffffe
    80003382:	858080e7          	jalr	-1960(ra) # 80000bd6 <acquire>
  empty = 0;
    80003386:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003388:	0001c497          	auipc	s1,0x1c
    8000338c:	d2848493          	addi	s1,s1,-728 # 8001f0b0 <itable+0x18>
    80003390:	0001d697          	auipc	a3,0x1d
    80003394:	7b068693          	addi	a3,a3,1968 # 80020b40 <log>
    80003398:	a039                	j	800033a6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000339a:	02090b63          	beqz	s2,800033d0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000339e:	08848493          	addi	s1,s1,136
    800033a2:	02d48a63          	beq	s1,a3,800033d6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033a6:	449c                	lw	a5,8(s1)
    800033a8:	fef059e3          	blez	a5,8000339a <iget+0x38>
    800033ac:	4098                	lw	a4,0(s1)
    800033ae:	ff3716e3          	bne	a4,s3,8000339a <iget+0x38>
    800033b2:	40d8                	lw	a4,4(s1)
    800033b4:	ff4713e3          	bne	a4,s4,8000339a <iget+0x38>
      ip->ref++;
    800033b8:	2785                	addiw	a5,a5,1
    800033ba:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033bc:	0001c517          	auipc	a0,0x1c
    800033c0:	cdc50513          	addi	a0,a0,-804 # 8001f098 <itable>
    800033c4:	ffffe097          	auipc	ra,0xffffe
    800033c8:	8c6080e7          	jalr	-1850(ra) # 80000c8a <release>
      return ip;
    800033cc:	8926                	mv	s2,s1
    800033ce:	a03d                	j	800033fc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033d0:	f7f9                	bnez	a5,8000339e <iget+0x3c>
    800033d2:	8926                	mv	s2,s1
    800033d4:	b7e9                	j	8000339e <iget+0x3c>
  if(empty == 0)
    800033d6:	02090c63          	beqz	s2,8000340e <iget+0xac>
  ip->dev = dev;
    800033da:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033de:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033e2:	4785                	li	a5,1
    800033e4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033e8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800033ec:	0001c517          	auipc	a0,0x1c
    800033f0:	cac50513          	addi	a0,a0,-852 # 8001f098 <itable>
    800033f4:	ffffe097          	auipc	ra,0xffffe
    800033f8:	896080e7          	jalr	-1898(ra) # 80000c8a <release>
}
    800033fc:	854a                	mv	a0,s2
    800033fe:	70a2                	ld	ra,40(sp)
    80003400:	7402                	ld	s0,32(sp)
    80003402:	64e2                	ld	s1,24(sp)
    80003404:	6942                	ld	s2,16(sp)
    80003406:	69a2                	ld	s3,8(sp)
    80003408:	6a02                	ld	s4,0(sp)
    8000340a:	6145                	addi	sp,sp,48
    8000340c:	8082                	ret
    panic("iget: no inodes");
    8000340e:	00005517          	auipc	a0,0x5
    80003412:	19250513          	addi	a0,a0,402 # 800085a0 <syscalls+0x138>
    80003416:	ffffd097          	auipc	ra,0xffffd
    8000341a:	12a080e7          	jalr	298(ra) # 80000540 <panic>

000000008000341e <fsinit>:
fsinit(int dev) {
    8000341e:	7179                	addi	sp,sp,-48
    80003420:	f406                	sd	ra,40(sp)
    80003422:	f022                	sd	s0,32(sp)
    80003424:	ec26                	sd	s1,24(sp)
    80003426:	e84a                	sd	s2,16(sp)
    80003428:	e44e                	sd	s3,8(sp)
    8000342a:	1800                	addi	s0,sp,48
    8000342c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000342e:	4585                	li	a1,1
    80003430:	00000097          	auipc	ra,0x0
    80003434:	a54080e7          	jalr	-1452(ra) # 80002e84 <bread>
    80003438:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000343a:	0001c997          	auipc	s3,0x1c
    8000343e:	c3e98993          	addi	s3,s3,-962 # 8001f078 <sb>
    80003442:	02000613          	li	a2,32
    80003446:	05850593          	addi	a1,a0,88
    8000344a:	854e                	mv	a0,s3
    8000344c:	ffffe097          	auipc	ra,0xffffe
    80003450:	8e2080e7          	jalr	-1822(ra) # 80000d2e <memmove>
  brelse(bp);
    80003454:	8526                	mv	a0,s1
    80003456:	00000097          	auipc	ra,0x0
    8000345a:	b5e080e7          	jalr	-1186(ra) # 80002fb4 <brelse>
  if(sb.magic != FSMAGIC)
    8000345e:	0009a703          	lw	a4,0(s3)
    80003462:	102037b7          	lui	a5,0x10203
    80003466:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000346a:	02f71263          	bne	a4,a5,8000348e <fsinit+0x70>
  initlog(dev, &sb);
    8000346e:	0001c597          	auipc	a1,0x1c
    80003472:	c0a58593          	addi	a1,a1,-1014 # 8001f078 <sb>
    80003476:	854a                	mv	a0,s2
    80003478:	00001097          	auipc	ra,0x1
    8000347c:	b4a080e7          	jalr	-1206(ra) # 80003fc2 <initlog>
}
    80003480:	70a2                	ld	ra,40(sp)
    80003482:	7402                	ld	s0,32(sp)
    80003484:	64e2                	ld	s1,24(sp)
    80003486:	6942                	ld	s2,16(sp)
    80003488:	69a2                	ld	s3,8(sp)
    8000348a:	6145                	addi	sp,sp,48
    8000348c:	8082                	ret
    panic("invalid file system");
    8000348e:	00005517          	auipc	a0,0x5
    80003492:	12250513          	addi	a0,a0,290 # 800085b0 <syscalls+0x148>
    80003496:	ffffd097          	auipc	ra,0xffffd
    8000349a:	0aa080e7          	jalr	170(ra) # 80000540 <panic>

000000008000349e <iinit>:
{
    8000349e:	7179                	addi	sp,sp,-48
    800034a0:	f406                	sd	ra,40(sp)
    800034a2:	f022                	sd	s0,32(sp)
    800034a4:	ec26                	sd	s1,24(sp)
    800034a6:	e84a                	sd	s2,16(sp)
    800034a8:	e44e                	sd	s3,8(sp)
    800034aa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034ac:	00005597          	auipc	a1,0x5
    800034b0:	11c58593          	addi	a1,a1,284 # 800085c8 <syscalls+0x160>
    800034b4:	0001c517          	auipc	a0,0x1c
    800034b8:	be450513          	addi	a0,a0,-1052 # 8001f098 <itable>
    800034bc:	ffffd097          	auipc	ra,0xffffd
    800034c0:	68a080e7          	jalr	1674(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034c4:	0001c497          	auipc	s1,0x1c
    800034c8:	bfc48493          	addi	s1,s1,-1028 # 8001f0c0 <itable+0x28>
    800034cc:	0001d997          	auipc	s3,0x1d
    800034d0:	68498993          	addi	s3,s3,1668 # 80020b50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034d4:	00005917          	auipc	s2,0x5
    800034d8:	0fc90913          	addi	s2,s2,252 # 800085d0 <syscalls+0x168>
    800034dc:	85ca                	mv	a1,s2
    800034de:	8526                	mv	a0,s1
    800034e0:	00001097          	auipc	ra,0x1
    800034e4:	e42080e7          	jalr	-446(ra) # 80004322 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034e8:	08848493          	addi	s1,s1,136
    800034ec:	ff3498e3          	bne	s1,s3,800034dc <iinit+0x3e>
}
    800034f0:	70a2                	ld	ra,40(sp)
    800034f2:	7402                	ld	s0,32(sp)
    800034f4:	64e2                	ld	s1,24(sp)
    800034f6:	6942                	ld	s2,16(sp)
    800034f8:	69a2                	ld	s3,8(sp)
    800034fa:	6145                	addi	sp,sp,48
    800034fc:	8082                	ret

00000000800034fe <ialloc>:
{
    800034fe:	715d                	addi	sp,sp,-80
    80003500:	e486                	sd	ra,72(sp)
    80003502:	e0a2                	sd	s0,64(sp)
    80003504:	fc26                	sd	s1,56(sp)
    80003506:	f84a                	sd	s2,48(sp)
    80003508:	f44e                	sd	s3,40(sp)
    8000350a:	f052                	sd	s4,32(sp)
    8000350c:	ec56                	sd	s5,24(sp)
    8000350e:	e85a                	sd	s6,16(sp)
    80003510:	e45e                	sd	s7,8(sp)
    80003512:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003514:	0001c717          	auipc	a4,0x1c
    80003518:	b7072703          	lw	a4,-1168(a4) # 8001f084 <sb+0xc>
    8000351c:	4785                	li	a5,1
    8000351e:	04e7fa63          	bgeu	a5,a4,80003572 <ialloc+0x74>
    80003522:	8aaa                	mv	s5,a0
    80003524:	8bae                	mv	s7,a1
    80003526:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003528:	0001ca17          	auipc	s4,0x1c
    8000352c:	b50a0a13          	addi	s4,s4,-1200 # 8001f078 <sb>
    80003530:	00048b1b          	sext.w	s6,s1
    80003534:	0044d593          	srli	a1,s1,0x4
    80003538:	018a2783          	lw	a5,24(s4)
    8000353c:	9dbd                	addw	a1,a1,a5
    8000353e:	8556                	mv	a0,s5
    80003540:	00000097          	auipc	ra,0x0
    80003544:	944080e7          	jalr	-1724(ra) # 80002e84 <bread>
    80003548:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000354a:	05850993          	addi	s3,a0,88
    8000354e:	00f4f793          	andi	a5,s1,15
    80003552:	079a                	slli	a5,a5,0x6
    80003554:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003556:	00099783          	lh	a5,0(s3)
    8000355a:	c3a1                	beqz	a5,8000359a <ialloc+0x9c>
    brelse(bp);
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	a58080e7          	jalr	-1448(ra) # 80002fb4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003564:	0485                	addi	s1,s1,1
    80003566:	00ca2703          	lw	a4,12(s4)
    8000356a:	0004879b          	sext.w	a5,s1
    8000356e:	fce7e1e3          	bltu	a5,a4,80003530 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003572:	00005517          	auipc	a0,0x5
    80003576:	06650513          	addi	a0,a0,102 # 800085d8 <syscalls+0x170>
    8000357a:	ffffd097          	auipc	ra,0xffffd
    8000357e:	010080e7          	jalr	16(ra) # 8000058a <printf>
  return 0;
    80003582:	4501                	li	a0,0
}
    80003584:	60a6                	ld	ra,72(sp)
    80003586:	6406                	ld	s0,64(sp)
    80003588:	74e2                	ld	s1,56(sp)
    8000358a:	7942                	ld	s2,48(sp)
    8000358c:	79a2                	ld	s3,40(sp)
    8000358e:	7a02                	ld	s4,32(sp)
    80003590:	6ae2                	ld	s5,24(sp)
    80003592:	6b42                	ld	s6,16(sp)
    80003594:	6ba2                	ld	s7,8(sp)
    80003596:	6161                	addi	sp,sp,80
    80003598:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000359a:	04000613          	li	a2,64
    8000359e:	4581                	li	a1,0
    800035a0:	854e                	mv	a0,s3
    800035a2:	ffffd097          	auipc	ra,0xffffd
    800035a6:	730080e7          	jalr	1840(ra) # 80000cd2 <memset>
      dip->type = type;
    800035aa:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035ae:	854a                	mv	a0,s2
    800035b0:	00001097          	auipc	ra,0x1
    800035b4:	c8e080e7          	jalr	-882(ra) # 8000423e <log_write>
      brelse(bp);
    800035b8:	854a                	mv	a0,s2
    800035ba:	00000097          	auipc	ra,0x0
    800035be:	9fa080e7          	jalr	-1542(ra) # 80002fb4 <brelse>
      return iget(dev, inum);
    800035c2:	85da                	mv	a1,s6
    800035c4:	8556                	mv	a0,s5
    800035c6:	00000097          	auipc	ra,0x0
    800035ca:	d9c080e7          	jalr	-612(ra) # 80003362 <iget>
    800035ce:	bf5d                	j	80003584 <ialloc+0x86>

00000000800035d0 <iupdate>:
{
    800035d0:	1101                	addi	sp,sp,-32
    800035d2:	ec06                	sd	ra,24(sp)
    800035d4:	e822                	sd	s0,16(sp)
    800035d6:	e426                	sd	s1,8(sp)
    800035d8:	e04a                	sd	s2,0(sp)
    800035da:	1000                	addi	s0,sp,32
    800035dc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035de:	415c                	lw	a5,4(a0)
    800035e0:	0047d79b          	srliw	a5,a5,0x4
    800035e4:	0001c597          	auipc	a1,0x1c
    800035e8:	aac5a583          	lw	a1,-1364(a1) # 8001f090 <sb+0x18>
    800035ec:	9dbd                	addw	a1,a1,a5
    800035ee:	4108                	lw	a0,0(a0)
    800035f0:	00000097          	auipc	ra,0x0
    800035f4:	894080e7          	jalr	-1900(ra) # 80002e84 <bread>
    800035f8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035fa:	05850793          	addi	a5,a0,88
    800035fe:	40d8                	lw	a4,4(s1)
    80003600:	8b3d                	andi	a4,a4,15
    80003602:	071a                	slli	a4,a4,0x6
    80003604:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003606:	04449703          	lh	a4,68(s1)
    8000360a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000360e:	04649703          	lh	a4,70(s1)
    80003612:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003616:	04849703          	lh	a4,72(s1)
    8000361a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000361e:	04a49703          	lh	a4,74(s1)
    80003622:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003626:	44f8                	lw	a4,76(s1)
    80003628:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000362a:	03400613          	li	a2,52
    8000362e:	05048593          	addi	a1,s1,80
    80003632:	00c78513          	addi	a0,a5,12
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	6f8080e7          	jalr	1784(ra) # 80000d2e <memmove>
  log_write(bp);
    8000363e:	854a                	mv	a0,s2
    80003640:	00001097          	auipc	ra,0x1
    80003644:	bfe080e7          	jalr	-1026(ra) # 8000423e <log_write>
  brelse(bp);
    80003648:	854a                	mv	a0,s2
    8000364a:	00000097          	auipc	ra,0x0
    8000364e:	96a080e7          	jalr	-1686(ra) # 80002fb4 <brelse>
}
    80003652:	60e2                	ld	ra,24(sp)
    80003654:	6442                	ld	s0,16(sp)
    80003656:	64a2                	ld	s1,8(sp)
    80003658:	6902                	ld	s2,0(sp)
    8000365a:	6105                	addi	sp,sp,32
    8000365c:	8082                	ret

000000008000365e <idup>:
{
    8000365e:	1101                	addi	sp,sp,-32
    80003660:	ec06                	sd	ra,24(sp)
    80003662:	e822                	sd	s0,16(sp)
    80003664:	e426                	sd	s1,8(sp)
    80003666:	1000                	addi	s0,sp,32
    80003668:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000366a:	0001c517          	auipc	a0,0x1c
    8000366e:	a2e50513          	addi	a0,a0,-1490 # 8001f098 <itable>
    80003672:	ffffd097          	auipc	ra,0xffffd
    80003676:	564080e7          	jalr	1380(ra) # 80000bd6 <acquire>
  ip->ref++;
    8000367a:	449c                	lw	a5,8(s1)
    8000367c:	2785                	addiw	a5,a5,1
    8000367e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003680:	0001c517          	auipc	a0,0x1c
    80003684:	a1850513          	addi	a0,a0,-1512 # 8001f098 <itable>
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	602080e7          	jalr	1538(ra) # 80000c8a <release>
}
    80003690:	8526                	mv	a0,s1
    80003692:	60e2                	ld	ra,24(sp)
    80003694:	6442                	ld	s0,16(sp)
    80003696:	64a2                	ld	s1,8(sp)
    80003698:	6105                	addi	sp,sp,32
    8000369a:	8082                	ret

000000008000369c <ilock>:
{
    8000369c:	1101                	addi	sp,sp,-32
    8000369e:	ec06                	sd	ra,24(sp)
    800036a0:	e822                	sd	s0,16(sp)
    800036a2:	e426                	sd	s1,8(sp)
    800036a4:	e04a                	sd	s2,0(sp)
    800036a6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036a8:	c115                	beqz	a0,800036cc <ilock+0x30>
    800036aa:	84aa                	mv	s1,a0
    800036ac:	451c                	lw	a5,8(a0)
    800036ae:	00f05f63          	blez	a5,800036cc <ilock+0x30>
  acquiresleep(&ip->lock);
    800036b2:	0541                	addi	a0,a0,16
    800036b4:	00001097          	auipc	ra,0x1
    800036b8:	ca8080e7          	jalr	-856(ra) # 8000435c <acquiresleep>
  if(ip->valid == 0){
    800036bc:	40bc                	lw	a5,64(s1)
    800036be:	cf99                	beqz	a5,800036dc <ilock+0x40>
}
    800036c0:	60e2                	ld	ra,24(sp)
    800036c2:	6442                	ld	s0,16(sp)
    800036c4:	64a2                	ld	s1,8(sp)
    800036c6:	6902                	ld	s2,0(sp)
    800036c8:	6105                	addi	sp,sp,32
    800036ca:	8082                	ret
    panic("ilock");
    800036cc:	00005517          	auipc	a0,0x5
    800036d0:	f2450513          	addi	a0,a0,-220 # 800085f0 <syscalls+0x188>
    800036d4:	ffffd097          	auipc	ra,0xffffd
    800036d8:	e6c080e7          	jalr	-404(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036dc:	40dc                	lw	a5,4(s1)
    800036de:	0047d79b          	srliw	a5,a5,0x4
    800036e2:	0001c597          	auipc	a1,0x1c
    800036e6:	9ae5a583          	lw	a1,-1618(a1) # 8001f090 <sb+0x18>
    800036ea:	9dbd                	addw	a1,a1,a5
    800036ec:	4088                	lw	a0,0(s1)
    800036ee:	fffff097          	auipc	ra,0xfffff
    800036f2:	796080e7          	jalr	1942(ra) # 80002e84 <bread>
    800036f6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036f8:	05850593          	addi	a1,a0,88
    800036fc:	40dc                	lw	a5,4(s1)
    800036fe:	8bbd                	andi	a5,a5,15
    80003700:	079a                	slli	a5,a5,0x6
    80003702:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003704:	00059783          	lh	a5,0(a1)
    80003708:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000370c:	00259783          	lh	a5,2(a1)
    80003710:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003714:	00459783          	lh	a5,4(a1)
    80003718:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000371c:	00659783          	lh	a5,6(a1)
    80003720:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003724:	459c                	lw	a5,8(a1)
    80003726:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003728:	03400613          	li	a2,52
    8000372c:	05b1                	addi	a1,a1,12
    8000372e:	05048513          	addi	a0,s1,80
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	5fc080e7          	jalr	1532(ra) # 80000d2e <memmove>
    brelse(bp);
    8000373a:	854a                	mv	a0,s2
    8000373c:	00000097          	auipc	ra,0x0
    80003740:	878080e7          	jalr	-1928(ra) # 80002fb4 <brelse>
    ip->valid = 1;
    80003744:	4785                	li	a5,1
    80003746:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003748:	04449783          	lh	a5,68(s1)
    8000374c:	fbb5                	bnez	a5,800036c0 <ilock+0x24>
      panic("ilock: no type");
    8000374e:	00005517          	auipc	a0,0x5
    80003752:	eaa50513          	addi	a0,a0,-342 # 800085f8 <syscalls+0x190>
    80003756:	ffffd097          	auipc	ra,0xffffd
    8000375a:	dea080e7          	jalr	-534(ra) # 80000540 <panic>

000000008000375e <iunlock>:
{
    8000375e:	1101                	addi	sp,sp,-32
    80003760:	ec06                	sd	ra,24(sp)
    80003762:	e822                	sd	s0,16(sp)
    80003764:	e426                	sd	s1,8(sp)
    80003766:	e04a                	sd	s2,0(sp)
    80003768:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000376a:	c905                	beqz	a0,8000379a <iunlock+0x3c>
    8000376c:	84aa                	mv	s1,a0
    8000376e:	01050913          	addi	s2,a0,16
    80003772:	854a                	mv	a0,s2
    80003774:	00001097          	auipc	ra,0x1
    80003778:	c82080e7          	jalr	-894(ra) # 800043f6 <holdingsleep>
    8000377c:	cd19                	beqz	a0,8000379a <iunlock+0x3c>
    8000377e:	449c                	lw	a5,8(s1)
    80003780:	00f05d63          	blez	a5,8000379a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003784:	854a                	mv	a0,s2
    80003786:	00001097          	auipc	ra,0x1
    8000378a:	c2c080e7          	jalr	-980(ra) # 800043b2 <releasesleep>
}
    8000378e:	60e2                	ld	ra,24(sp)
    80003790:	6442                	ld	s0,16(sp)
    80003792:	64a2                	ld	s1,8(sp)
    80003794:	6902                	ld	s2,0(sp)
    80003796:	6105                	addi	sp,sp,32
    80003798:	8082                	ret
    panic("iunlock");
    8000379a:	00005517          	auipc	a0,0x5
    8000379e:	e6e50513          	addi	a0,a0,-402 # 80008608 <syscalls+0x1a0>
    800037a2:	ffffd097          	auipc	ra,0xffffd
    800037a6:	d9e080e7          	jalr	-610(ra) # 80000540 <panic>

00000000800037aa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037aa:	7179                	addi	sp,sp,-48
    800037ac:	f406                	sd	ra,40(sp)
    800037ae:	f022                	sd	s0,32(sp)
    800037b0:	ec26                	sd	s1,24(sp)
    800037b2:	e84a                	sd	s2,16(sp)
    800037b4:	e44e                	sd	s3,8(sp)
    800037b6:	e052                	sd	s4,0(sp)
    800037b8:	1800                	addi	s0,sp,48
    800037ba:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037bc:	05050493          	addi	s1,a0,80
    800037c0:	08050913          	addi	s2,a0,128
    800037c4:	a021                	j	800037cc <itrunc+0x22>
    800037c6:	0491                	addi	s1,s1,4
    800037c8:	01248d63          	beq	s1,s2,800037e2 <itrunc+0x38>
    if(ip->addrs[i]){
    800037cc:	408c                	lw	a1,0(s1)
    800037ce:	dde5                	beqz	a1,800037c6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037d0:	0009a503          	lw	a0,0(s3)
    800037d4:	00000097          	auipc	ra,0x0
    800037d8:	8f6080e7          	jalr	-1802(ra) # 800030ca <bfree>
      ip->addrs[i] = 0;
    800037dc:	0004a023          	sw	zero,0(s1)
    800037e0:	b7dd                	j	800037c6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037e2:	0809a583          	lw	a1,128(s3)
    800037e6:	e185                	bnez	a1,80003806 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037e8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037ec:	854e                	mv	a0,s3
    800037ee:	00000097          	auipc	ra,0x0
    800037f2:	de2080e7          	jalr	-542(ra) # 800035d0 <iupdate>
}
    800037f6:	70a2                	ld	ra,40(sp)
    800037f8:	7402                	ld	s0,32(sp)
    800037fa:	64e2                	ld	s1,24(sp)
    800037fc:	6942                	ld	s2,16(sp)
    800037fe:	69a2                	ld	s3,8(sp)
    80003800:	6a02                	ld	s4,0(sp)
    80003802:	6145                	addi	sp,sp,48
    80003804:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003806:	0009a503          	lw	a0,0(s3)
    8000380a:	fffff097          	auipc	ra,0xfffff
    8000380e:	67a080e7          	jalr	1658(ra) # 80002e84 <bread>
    80003812:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003814:	05850493          	addi	s1,a0,88
    80003818:	45850913          	addi	s2,a0,1112
    8000381c:	a021                	j	80003824 <itrunc+0x7a>
    8000381e:	0491                	addi	s1,s1,4
    80003820:	01248b63          	beq	s1,s2,80003836 <itrunc+0x8c>
      if(a[j])
    80003824:	408c                	lw	a1,0(s1)
    80003826:	dde5                	beqz	a1,8000381e <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003828:	0009a503          	lw	a0,0(s3)
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	89e080e7          	jalr	-1890(ra) # 800030ca <bfree>
    80003834:	b7ed                	j	8000381e <itrunc+0x74>
    brelse(bp);
    80003836:	8552                	mv	a0,s4
    80003838:	fffff097          	auipc	ra,0xfffff
    8000383c:	77c080e7          	jalr	1916(ra) # 80002fb4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003840:	0809a583          	lw	a1,128(s3)
    80003844:	0009a503          	lw	a0,0(s3)
    80003848:	00000097          	auipc	ra,0x0
    8000384c:	882080e7          	jalr	-1918(ra) # 800030ca <bfree>
    ip->addrs[NDIRECT] = 0;
    80003850:	0809a023          	sw	zero,128(s3)
    80003854:	bf51                	j	800037e8 <itrunc+0x3e>

0000000080003856 <iput>:
{
    80003856:	1101                	addi	sp,sp,-32
    80003858:	ec06                	sd	ra,24(sp)
    8000385a:	e822                	sd	s0,16(sp)
    8000385c:	e426                	sd	s1,8(sp)
    8000385e:	e04a                	sd	s2,0(sp)
    80003860:	1000                	addi	s0,sp,32
    80003862:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003864:	0001c517          	auipc	a0,0x1c
    80003868:	83450513          	addi	a0,a0,-1996 # 8001f098 <itable>
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	36a080e7          	jalr	874(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003874:	4498                	lw	a4,8(s1)
    80003876:	4785                	li	a5,1
    80003878:	02f70363          	beq	a4,a5,8000389e <iput+0x48>
  ip->ref--;
    8000387c:	449c                	lw	a5,8(s1)
    8000387e:	37fd                	addiw	a5,a5,-1
    80003880:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003882:	0001c517          	auipc	a0,0x1c
    80003886:	81650513          	addi	a0,a0,-2026 # 8001f098 <itable>
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	400080e7          	jalr	1024(ra) # 80000c8a <release>
}
    80003892:	60e2                	ld	ra,24(sp)
    80003894:	6442                	ld	s0,16(sp)
    80003896:	64a2                	ld	s1,8(sp)
    80003898:	6902                	ld	s2,0(sp)
    8000389a:	6105                	addi	sp,sp,32
    8000389c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000389e:	40bc                	lw	a5,64(s1)
    800038a0:	dff1                	beqz	a5,8000387c <iput+0x26>
    800038a2:	04a49783          	lh	a5,74(s1)
    800038a6:	fbf9                	bnez	a5,8000387c <iput+0x26>
    acquiresleep(&ip->lock);
    800038a8:	01048913          	addi	s2,s1,16
    800038ac:	854a                	mv	a0,s2
    800038ae:	00001097          	auipc	ra,0x1
    800038b2:	aae080e7          	jalr	-1362(ra) # 8000435c <acquiresleep>
    release(&itable.lock);
    800038b6:	0001b517          	auipc	a0,0x1b
    800038ba:	7e250513          	addi	a0,a0,2018 # 8001f098 <itable>
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	3cc080e7          	jalr	972(ra) # 80000c8a <release>
    itrunc(ip);
    800038c6:	8526                	mv	a0,s1
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	ee2080e7          	jalr	-286(ra) # 800037aa <itrunc>
    ip->type = 0;
    800038d0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038d4:	8526                	mv	a0,s1
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	cfa080e7          	jalr	-774(ra) # 800035d0 <iupdate>
    ip->valid = 0;
    800038de:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038e2:	854a                	mv	a0,s2
    800038e4:	00001097          	auipc	ra,0x1
    800038e8:	ace080e7          	jalr	-1330(ra) # 800043b2 <releasesleep>
    acquire(&itable.lock);
    800038ec:	0001b517          	auipc	a0,0x1b
    800038f0:	7ac50513          	addi	a0,a0,1964 # 8001f098 <itable>
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	2e2080e7          	jalr	738(ra) # 80000bd6 <acquire>
    800038fc:	b741                	j	8000387c <iput+0x26>

00000000800038fe <iunlockput>:
{
    800038fe:	1101                	addi	sp,sp,-32
    80003900:	ec06                	sd	ra,24(sp)
    80003902:	e822                	sd	s0,16(sp)
    80003904:	e426                	sd	s1,8(sp)
    80003906:	1000                	addi	s0,sp,32
    80003908:	84aa                	mv	s1,a0
  iunlock(ip);
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	e54080e7          	jalr	-428(ra) # 8000375e <iunlock>
  iput(ip);
    80003912:	8526                	mv	a0,s1
    80003914:	00000097          	auipc	ra,0x0
    80003918:	f42080e7          	jalr	-190(ra) # 80003856 <iput>
}
    8000391c:	60e2                	ld	ra,24(sp)
    8000391e:	6442                	ld	s0,16(sp)
    80003920:	64a2                	ld	s1,8(sp)
    80003922:	6105                	addi	sp,sp,32
    80003924:	8082                	ret

0000000080003926 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003926:	1141                	addi	sp,sp,-16
    80003928:	e422                	sd	s0,8(sp)
    8000392a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000392c:	411c                	lw	a5,0(a0)
    8000392e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003930:	415c                	lw	a5,4(a0)
    80003932:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003934:	04451783          	lh	a5,68(a0)
    80003938:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000393c:	04a51783          	lh	a5,74(a0)
    80003940:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003944:	04c56783          	lwu	a5,76(a0)
    80003948:	e99c                	sd	a5,16(a1)
}
    8000394a:	6422                	ld	s0,8(sp)
    8000394c:	0141                	addi	sp,sp,16
    8000394e:	8082                	ret

0000000080003950 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003950:	457c                	lw	a5,76(a0)
    80003952:	0ed7e963          	bltu	a5,a3,80003a44 <readi+0xf4>
{
    80003956:	7159                	addi	sp,sp,-112
    80003958:	f486                	sd	ra,104(sp)
    8000395a:	f0a2                	sd	s0,96(sp)
    8000395c:	eca6                	sd	s1,88(sp)
    8000395e:	e8ca                	sd	s2,80(sp)
    80003960:	e4ce                	sd	s3,72(sp)
    80003962:	e0d2                	sd	s4,64(sp)
    80003964:	fc56                	sd	s5,56(sp)
    80003966:	f85a                	sd	s6,48(sp)
    80003968:	f45e                	sd	s7,40(sp)
    8000396a:	f062                	sd	s8,32(sp)
    8000396c:	ec66                	sd	s9,24(sp)
    8000396e:	e86a                	sd	s10,16(sp)
    80003970:	e46e                	sd	s11,8(sp)
    80003972:	1880                	addi	s0,sp,112
    80003974:	8b2a                	mv	s6,a0
    80003976:	8bae                	mv	s7,a1
    80003978:	8a32                	mv	s4,a2
    8000397a:	84b6                	mv	s1,a3
    8000397c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000397e:	9f35                	addw	a4,a4,a3
    return 0;
    80003980:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003982:	0ad76063          	bltu	a4,a3,80003a22 <readi+0xd2>
  if(off + n > ip->size)
    80003986:	00e7f463          	bgeu	a5,a4,8000398e <readi+0x3e>
    n = ip->size - off;
    8000398a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000398e:	0a0a8963          	beqz	s5,80003a40 <readi+0xf0>
    80003992:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003994:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003998:	5c7d                	li	s8,-1
    8000399a:	a82d                	j	800039d4 <readi+0x84>
    8000399c:	020d1d93          	slli	s11,s10,0x20
    800039a0:	020ddd93          	srli	s11,s11,0x20
    800039a4:	05890613          	addi	a2,s2,88
    800039a8:	86ee                	mv	a3,s11
    800039aa:	963a                	add	a2,a2,a4
    800039ac:	85d2                	mv	a1,s4
    800039ae:	855e                	mv	a0,s7
    800039b0:	fffff097          	auipc	ra,0xfffff
    800039b4:	aac080e7          	jalr	-1364(ra) # 8000245c <either_copyout>
    800039b8:	05850d63          	beq	a0,s8,80003a12 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039bc:	854a                	mv	a0,s2
    800039be:	fffff097          	auipc	ra,0xfffff
    800039c2:	5f6080e7          	jalr	1526(ra) # 80002fb4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039c6:	013d09bb          	addw	s3,s10,s3
    800039ca:	009d04bb          	addw	s1,s10,s1
    800039ce:	9a6e                	add	s4,s4,s11
    800039d0:	0559f763          	bgeu	s3,s5,80003a1e <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800039d4:	00a4d59b          	srliw	a1,s1,0xa
    800039d8:	855a                	mv	a0,s6
    800039da:	00000097          	auipc	ra,0x0
    800039de:	89e080e7          	jalr	-1890(ra) # 80003278 <bmap>
    800039e2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039e6:	cd85                	beqz	a1,80003a1e <readi+0xce>
    bp = bread(ip->dev, addr);
    800039e8:	000b2503          	lw	a0,0(s6)
    800039ec:	fffff097          	auipc	ra,0xfffff
    800039f0:	498080e7          	jalr	1176(ra) # 80002e84 <bread>
    800039f4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039f6:	3ff4f713          	andi	a4,s1,1023
    800039fa:	40ec87bb          	subw	a5,s9,a4
    800039fe:	413a86bb          	subw	a3,s5,s3
    80003a02:	8d3e                	mv	s10,a5
    80003a04:	2781                	sext.w	a5,a5
    80003a06:	0006861b          	sext.w	a2,a3
    80003a0a:	f8f679e3          	bgeu	a2,a5,8000399c <readi+0x4c>
    80003a0e:	8d36                	mv	s10,a3
    80003a10:	b771                	j	8000399c <readi+0x4c>
      brelse(bp);
    80003a12:	854a                	mv	a0,s2
    80003a14:	fffff097          	auipc	ra,0xfffff
    80003a18:	5a0080e7          	jalr	1440(ra) # 80002fb4 <brelse>
      tot = -1;
    80003a1c:	59fd                	li	s3,-1
  }
  return tot;
    80003a1e:	0009851b          	sext.w	a0,s3
}
    80003a22:	70a6                	ld	ra,104(sp)
    80003a24:	7406                	ld	s0,96(sp)
    80003a26:	64e6                	ld	s1,88(sp)
    80003a28:	6946                	ld	s2,80(sp)
    80003a2a:	69a6                	ld	s3,72(sp)
    80003a2c:	6a06                	ld	s4,64(sp)
    80003a2e:	7ae2                	ld	s5,56(sp)
    80003a30:	7b42                	ld	s6,48(sp)
    80003a32:	7ba2                	ld	s7,40(sp)
    80003a34:	7c02                	ld	s8,32(sp)
    80003a36:	6ce2                	ld	s9,24(sp)
    80003a38:	6d42                	ld	s10,16(sp)
    80003a3a:	6da2                	ld	s11,8(sp)
    80003a3c:	6165                	addi	sp,sp,112
    80003a3e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a40:	89d6                	mv	s3,s5
    80003a42:	bff1                	j	80003a1e <readi+0xce>
    return 0;
    80003a44:	4501                	li	a0,0
}
    80003a46:	8082                	ret

0000000080003a48 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a48:	457c                	lw	a5,76(a0)
    80003a4a:	10d7e863          	bltu	a5,a3,80003b5a <writei+0x112>
{
    80003a4e:	7159                	addi	sp,sp,-112
    80003a50:	f486                	sd	ra,104(sp)
    80003a52:	f0a2                	sd	s0,96(sp)
    80003a54:	eca6                	sd	s1,88(sp)
    80003a56:	e8ca                	sd	s2,80(sp)
    80003a58:	e4ce                	sd	s3,72(sp)
    80003a5a:	e0d2                	sd	s4,64(sp)
    80003a5c:	fc56                	sd	s5,56(sp)
    80003a5e:	f85a                	sd	s6,48(sp)
    80003a60:	f45e                	sd	s7,40(sp)
    80003a62:	f062                	sd	s8,32(sp)
    80003a64:	ec66                	sd	s9,24(sp)
    80003a66:	e86a                	sd	s10,16(sp)
    80003a68:	e46e                	sd	s11,8(sp)
    80003a6a:	1880                	addi	s0,sp,112
    80003a6c:	8aaa                	mv	s5,a0
    80003a6e:	8bae                	mv	s7,a1
    80003a70:	8a32                	mv	s4,a2
    80003a72:	8936                	mv	s2,a3
    80003a74:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a76:	00e687bb          	addw	a5,a3,a4
    80003a7a:	0ed7e263          	bltu	a5,a3,80003b5e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a7e:	00043737          	lui	a4,0x43
    80003a82:	0ef76063          	bltu	a4,a5,80003b62 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a86:	0c0b0863          	beqz	s6,80003b56 <writei+0x10e>
    80003a8a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a8c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a90:	5c7d                	li	s8,-1
    80003a92:	a091                	j	80003ad6 <writei+0x8e>
    80003a94:	020d1d93          	slli	s11,s10,0x20
    80003a98:	020ddd93          	srli	s11,s11,0x20
    80003a9c:	05848513          	addi	a0,s1,88
    80003aa0:	86ee                	mv	a3,s11
    80003aa2:	8652                	mv	a2,s4
    80003aa4:	85de                	mv	a1,s7
    80003aa6:	953a                	add	a0,a0,a4
    80003aa8:	fffff097          	auipc	ra,0xfffff
    80003aac:	a0a080e7          	jalr	-1526(ra) # 800024b2 <either_copyin>
    80003ab0:	07850263          	beq	a0,s8,80003b14 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ab4:	8526                	mv	a0,s1
    80003ab6:	00000097          	auipc	ra,0x0
    80003aba:	788080e7          	jalr	1928(ra) # 8000423e <log_write>
    brelse(bp);
    80003abe:	8526                	mv	a0,s1
    80003ac0:	fffff097          	auipc	ra,0xfffff
    80003ac4:	4f4080e7          	jalr	1268(ra) # 80002fb4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ac8:	013d09bb          	addw	s3,s10,s3
    80003acc:	012d093b          	addw	s2,s10,s2
    80003ad0:	9a6e                	add	s4,s4,s11
    80003ad2:	0569f663          	bgeu	s3,s6,80003b1e <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003ad6:	00a9559b          	srliw	a1,s2,0xa
    80003ada:	8556                	mv	a0,s5
    80003adc:	fffff097          	auipc	ra,0xfffff
    80003ae0:	79c080e7          	jalr	1948(ra) # 80003278 <bmap>
    80003ae4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ae8:	c99d                	beqz	a1,80003b1e <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003aea:	000aa503          	lw	a0,0(s5)
    80003aee:	fffff097          	auipc	ra,0xfffff
    80003af2:	396080e7          	jalr	918(ra) # 80002e84 <bread>
    80003af6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003af8:	3ff97713          	andi	a4,s2,1023
    80003afc:	40ec87bb          	subw	a5,s9,a4
    80003b00:	413b06bb          	subw	a3,s6,s3
    80003b04:	8d3e                	mv	s10,a5
    80003b06:	2781                	sext.w	a5,a5
    80003b08:	0006861b          	sext.w	a2,a3
    80003b0c:	f8f674e3          	bgeu	a2,a5,80003a94 <writei+0x4c>
    80003b10:	8d36                	mv	s10,a3
    80003b12:	b749                	j	80003a94 <writei+0x4c>
      brelse(bp);
    80003b14:	8526                	mv	a0,s1
    80003b16:	fffff097          	auipc	ra,0xfffff
    80003b1a:	49e080e7          	jalr	1182(ra) # 80002fb4 <brelse>
  }

  if(off > ip->size)
    80003b1e:	04caa783          	lw	a5,76(s5)
    80003b22:	0127f463          	bgeu	a5,s2,80003b2a <writei+0xe2>
    ip->size = off;
    80003b26:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b2a:	8556                	mv	a0,s5
    80003b2c:	00000097          	auipc	ra,0x0
    80003b30:	aa4080e7          	jalr	-1372(ra) # 800035d0 <iupdate>

  return tot;
    80003b34:	0009851b          	sext.w	a0,s3
}
    80003b38:	70a6                	ld	ra,104(sp)
    80003b3a:	7406                	ld	s0,96(sp)
    80003b3c:	64e6                	ld	s1,88(sp)
    80003b3e:	6946                	ld	s2,80(sp)
    80003b40:	69a6                	ld	s3,72(sp)
    80003b42:	6a06                	ld	s4,64(sp)
    80003b44:	7ae2                	ld	s5,56(sp)
    80003b46:	7b42                	ld	s6,48(sp)
    80003b48:	7ba2                	ld	s7,40(sp)
    80003b4a:	7c02                	ld	s8,32(sp)
    80003b4c:	6ce2                	ld	s9,24(sp)
    80003b4e:	6d42                	ld	s10,16(sp)
    80003b50:	6da2                	ld	s11,8(sp)
    80003b52:	6165                	addi	sp,sp,112
    80003b54:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b56:	89da                	mv	s3,s6
    80003b58:	bfc9                	j	80003b2a <writei+0xe2>
    return -1;
    80003b5a:	557d                	li	a0,-1
}
    80003b5c:	8082                	ret
    return -1;
    80003b5e:	557d                	li	a0,-1
    80003b60:	bfe1                	j	80003b38 <writei+0xf0>
    return -1;
    80003b62:	557d                	li	a0,-1
    80003b64:	bfd1                	j	80003b38 <writei+0xf0>

0000000080003b66 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b66:	1141                	addi	sp,sp,-16
    80003b68:	e406                	sd	ra,8(sp)
    80003b6a:	e022                	sd	s0,0(sp)
    80003b6c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b6e:	4639                	li	a2,14
    80003b70:	ffffd097          	auipc	ra,0xffffd
    80003b74:	232080e7          	jalr	562(ra) # 80000da2 <strncmp>
}
    80003b78:	60a2                	ld	ra,8(sp)
    80003b7a:	6402                	ld	s0,0(sp)
    80003b7c:	0141                	addi	sp,sp,16
    80003b7e:	8082                	ret

0000000080003b80 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b80:	7139                	addi	sp,sp,-64
    80003b82:	fc06                	sd	ra,56(sp)
    80003b84:	f822                	sd	s0,48(sp)
    80003b86:	f426                	sd	s1,40(sp)
    80003b88:	f04a                	sd	s2,32(sp)
    80003b8a:	ec4e                	sd	s3,24(sp)
    80003b8c:	e852                	sd	s4,16(sp)
    80003b8e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b90:	04451703          	lh	a4,68(a0)
    80003b94:	4785                	li	a5,1
    80003b96:	00f71a63          	bne	a4,a5,80003baa <dirlookup+0x2a>
    80003b9a:	892a                	mv	s2,a0
    80003b9c:	89ae                	mv	s3,a1
    80003b9e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ba0:	457c                	lw	a5,76(a0)
    80003ba2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ba4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ba6:	e79d                	bnez	a5,80003bd4 <dirlookup+0x54>
    80003ba8:	a8a5                	j	80003c20 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003baa:	00005517          	auipc	a0,0x5
    80003bae:	a6650513          	addi	a0,a0,-1434 # 80008610 <syscalls+0x1a8>
    80003bb2:	ffffd097          	auipc	ra,0xffffd
    80003bb6:	98e080e7          	jalr	-1650(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003bba:	00005517          	auipc	a0,0x5
    80003bbe:	a6e50513          	addi	a0,a0,-1426 # 80008628 <syscalls+0x1c0>
    80003bc2:	ffffd097          	auipc	ra,0xffffd
    80003bc6:	97e080e7          	jalr	-1666(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bca:	24c1                	addiw	s1,s1,16
    80003bcc:	04c92783          	lw	a5,76(s2)
    80003bd0:	04f4f763          	bgeu	s1,a5,80003c1e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bd4:	4741                	li	a4,16
    80003bd6:	86a6                	mv	a3,s1
    80003bd8:	fc040613          	addi	a2,s0,-64
    80003bdc:	4581                	li	a1,0
    80003bde:	854a                	mv	a0,s2
    80003be0:	00000097          	auipc	ra,0x0
    80003be4:	d70080e7          	jalr	-656(ra) # 80003950 <readi>
    80003be8:	47c1                	li	a5,16
    80003bea:	fcf518e3          	bne	a0,a5,80003bba <dirlookup+0x3a>
    if(de.inum == 0)
    80003bee:	fc045783          	lhu	a5,-64(s0)
    80003bf2:	dfe1                	beqz	a5,80003bca <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bf4:	fc240593          	addi	a1,s0,-62
    80003bf8:	854e                	mv	a0,s3
    80003bfa:	00000097          	auipc	ra,0x0
    80003bfe:	f6c080e7          	jalr	-148(ra) # 80003b66 <namecmp>
    80003c02:	f561                	bnez	a0,80003bca <dirlookup+0x4a>
      if(poff)
    80003c04:	000a0463          	beqz	s4,80003c0c <dirlookup+0x8c>
        *poff = off;
    80003c08:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c0c:	fc045583          	lhu	a1,-64(s0)
    80003c10:	00092503          	lw	a0,0(s2)
    80003c14:	fffff097          	auipc	ra,0xfffff
    80003c18:	74e080e7          	jalr	1870(ra) # 80003362 <iget>
    80003c1c:	a011                	j	80003c20 <dirlookup+0xa0>
  return 0;
    80003c1e:	4501                	li	a0,0
}
    80003c20:	70e2                	ld	ra,56(sp)
    80003c22:	7442                	ld	s0,48(sp)
    80003c24:	74a2                	ld	s1,40(sp)
    80003c26:	7902                	ld	s2,32(sp)
    80003c28:	69e2                	ld	s3,24(sp)
    80003c2a:	6a42                	ld	s4,16(sp)
    80003c2c:	6121                	addi	sp,sp,64
    80003c2e:	8082                	ret

0000000080003c30 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c30:	711d                	addi	sp,sp,-96
    80003c32:	ec86                	sd	ra,88(sp)
    80003c34:	e8a2                	sd	s0,80(sp)
    80003c36:	e4a6                	sd	s1,72(sp)
    80003c38:	e0ca                	sd	s2,64(sp)
    80003c3a:	fc4e                	sd	s3,56(sp)
    80003c3c:	f852                	sd	s4,48(sp)
    80003c3e:	f456                	sd	s5,40(sp)
    80003c40:	f05a                	sd	s6,32(sp)
    80003c42:	ec5e                	sd	s7,24(sp)
    80003c44:	e862                	sd	s8,16(sp)
    80003c46:	e466                	sd	s9,8(sp)
    80003c48:	e06a                	sd	s10,0(sp)
    80003c4a:	1080                	addi	s0,sp,96
    80003c4c:	84aa                	mv	s1,a0
    80003c4e:	8b2e                	mv	s6,a1
    80003c50:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c52:	00054703          	lbu	a4,0(a0)
    80003c56:	02f00793          	li	a5,47
    80003c5a:	02f70363          	beq	a4,a5,80003c80 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c5e:	ffffe097          	auipc	ra,0xffffe
    80003c62:	d4e080e7          	jalr	-690(ra) # 800019ac <myproc>
    80003c66:	15053503          	ld	a0,336(a0)
    80003c6a:	00000097          	auipc	ra,0x0
    80003c6e:	9f4080e7          	jalr	-1548(ra) # 8000365e <idup>
    80003c72:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c74:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c78:	4cb5                	li	s9,13
  len = path - s;
    80003c7a:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c7c:	4c05                	li	s8,1
    80003c7e:	a87d                	j	80003d3c <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003c80:	4585                	li	a1,1
    80003c82:	4505                	li	a0,1
    80003c84:	fffff097          	auipc	ra,0xfffff
    80003c88:	6de080e7          	jalr	1758(ra) # 80003362 <iget>
    80003c8c:	8a2a                	mv	s4,a0
    80003c8e:	b7dd                	j	80003c74 <namex+0x44>
      iunlockput(ip);
    80003c90:	8552                	mv	a0,s4
    80003c92:	00000097          	auipc	ra,0x0
    80003c96:	c6c080e7          	jalr	-916(ra) # 800038fe <iunlockput>
      return 0;
    80003c9a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c9c:	8552                	mv	a0,s4
    80003c9e:	60e6                	ld	ra,88(sp)
    80003ca0:	6446                	ld	s0,80(sp)
    80003ca2:	64a6                	ld	s1,72(sp)
    80003ca4:	6906                	ld	s2,64(sp)
    80003ca6:	79e2                	ld	s3,56(sp)
    80003ca8:	7a42                	ld	s4,48(sp)
    80003caa:	7aa2                	ld	s5,40(sp)
    80003cac:	7b02                	ld	s6,32(sp)
    80003cae:	6be2                	ld	s7,24(sp)
    80003cb0:	6c42                	ld	s8,16(sp)
    80003cb2:	6ca2                	ld	s9,8(sp)
    80003cb4:	6d02                	ld	s10,0(sp)
    80003cb6:	6125                	addi	sp,sp,96
    80003cb8:	8082                	ret
      iunlock(ip);
    80003cba:	8552                	mv	a0,s4
    80003cbc:	00000097          	auipc	ra,0x0
    80003cc0:	aa2080e7          	jalr	-1374(ra) # 8000375e <iunlock>
      return ip;
    80003cc4:	bfe1                	j	80003c9c <namex+0x6c>
      iunlockput(ip);
    80003cc6:	8552                	mv	a0,s4
    80003cc8:	00000097          	auipc	ra,0x0
    80003ccc:	c36080e7          	jalr	-970(ra) # 800038fe <iunlockput>
      return 0;
    80003cd0:	8a4e                	mv	s4,s3
    80003cd2:	b7e9                	j	80003c9c <namex+0x6c>
  len = path - s;
    80003cd4:	40998633          	sub	a2,s3,s1
    80003cd8:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003cdc:	09acd863          	bge	s9,s10,80003d6c <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003ce0:	4639                	li	a2,14
    80003ce2:	85a6                	mv	a1,s1
    80003ce4:	8556                	mv	a0,s5
    80003ce6:	ffffd097          	auipc	ra,0xffffd
    80003cea:	048080e7          	jalr	72(ra) # 80000d2e <memmove>
    80003cee:	84ce                	mv	s1,s3
  while(*path == '/')
    80003cf0:	0004c783          	lbu	a5,0(s1)
    80003cf4:	01279763          	bne	a5,s2,80003d02 <namex+0xd2>
    path++;
    80003cf8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cfa:	0004c783          	lbu	a5,0(s1)
    80003cfe:	ff278de3          	beq	a5,s2,80003cf8 <namex+0xc8>
    ilock(ip);
    80003d02:	8552                	mv	a0,s4
    80003d04:	00000097          	auipc	ra,0x0
    80003d08:	998080e7          	jalr	-1640(ra) # 8000369c <ilock>
    if(ip->type != T_DIR){
    80003d0c:	044a1783          	lh	a5,68(s4)
    80003d10:	f98790e3          	bne	a5,s8,80003c90 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003d14:	000b0563          	beqz	s6,80003d1e <namex+0xee>
    80003d18:	0004c783          	lbu	a5,0(s1)
    80003d1c:	dfd9                	beqz	a5,80003cba <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d1e:	865e                	mv	a2,s7
    80003d20:	85d6                	mv	a1,s5
    80003d22:	8552                	mv	a0,s4
    80003d24:	00000097          	auipc	ra,0x0
    80003d28:	e5c080e7          	jalr	-420(ra) # 80003b80 <dirlookup>
    80003d2c:	89aa                	mv	s3,a0
    80003d2e:	dd41                	beqz	a0,80003cc6 <namex+0x96>
    iunlockput(ip);
    80003d30:	8552                	mv	a0,s4
    80003d32:	00000097          	auipc	ra,0x0
    80003d36:	bcc080e7          	jalr	-1076(ra) # 800038fe <iunlockput>
    ip = next;
    80003d3a:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d3c:	0004c783          	lbu	a5,0(s1)
    80003d40:	01279763          	bne	a5,s2,80003d4e <namex+0x11e>
    path++;
    80003d44:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d46:	0004c783          	lbu	a5,0(s1)
    80003d4a:	ff278de3          	beq	a5,s2,80003d44 <namex+0x114>
  if(*path == 0)
    80003d4e:	cb9d                	beqz	a5,80003d84 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003d50:	0004c783          	lbu	a5,0(s1)
    80003d54:	89a6                	mv	s3,s1
  len = path - s;
    80003d56:	8d5e                	mv	s10,s7
    80003d58:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d5a:	01278963          	beq	a5,s2,80003d6c <namex+0x13c>
    80003d5e:	dbbd                	beqz	a5,80003cd4 <namex+0xa4>
    path++;
    80003d60:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d62:	0009c783          	lbu	a5,0(s3)
    80003d66:	ff279ce3          	bne	a5,s2,80003d5e <namex+0x12e>
    80003d6a:	b7ad                	j	80003cd4 <namex+0xa4>
    memmove(name, s, len);
    80003d6c:	2601                	sext.w	a2,a2
    80003d6e:	85a6                	mv	a1,s1
    80003d70:	8556                	mv	a0,s5
    80003d72:	ffffd097          	auipc	ra,0xffffd
    80003d76:	fbc080e7          	jalr	-68(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003d7a:	9d56                	add	s10,s10,s5
    80003d7c:	000d0023          	sb	zero,0(s10)
    80003d80:	84ce                	mv	s1,s3
    80003d82:	b7bd                	j	80003cf0 <namex+0xc0>
  if(nameiparent){
    80003d84:	f00b0ce3          	beqz	s6,80003c9c <namex+0x6c>
    iput(ip);
    80003d88:	8552                	mv	a0,s4
    80003d8a:	00000097          	auipc	ra,0x0
    80003d8e:	acc080e7          	jalr	-1332(ra) # 80003856 <iput>
    return 0;
    80003d92:	4a01                	li	s4,0
    80003d94:	b721                	j	80003c9c <namex+0x6c>

0000000080003d96 <dirlink>:
{
    80003d96:	7139                	addi	sp,sp,-64
    80003d98:	fc06                	sd	ra,56(sp)
    80003d9a:	f822                	sd	s0,48(sp)
    80003d9c:	f426                	sd	s1,40(sp)
    80003d9e:	f04a                	sd	s2,32(sp)
    80003da0:	ec4e                	sd	s3,24(sp)
    80003da2:	e852                	sd	s4,16(sp)
    80003da4:	0080                	addi	s0,sp,64
    80003da6:	892a                	mv	s2,a0
    80003da8:	8a2e                	mv	s4,a1
    80003daa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dac:	4601                	li	a2,0
    80003dae:	00000097          	auipc	ra,0x0
    80003db2:	dd2080e7          	jalr	-558(ra) # 80003b80 <dirlookup>
    80003db6:	e93d                	bnez	a0,80003e2c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003db8:	04c92483          	lw	s1,76(s2)
    80003dbc:	c49d                	beqz	s1,80003dea <dirlink+0x54>
    80003dbe:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dc0:	4741                	li	a4,16
    80003dc2:	86a6                	mv	a3,s1
    80003dc4:	fc040613          	addi	a2,s0,-64
    80003dc8:	4581                	li	a1,0
    80003dca:	854a                	mv	a0,s2
    80003dcc:	00000097          	auipc	ra,0x0
    80003dd0:	b84080e7          	jalr	-1148(ra) # 80003950 <readi>
    80003dd4:	47c1                	li	a5,16
    80003dd6:	06f51163          	bne	a0,a5,80003e38 <dirlink+0xa2>
    if(de.inum == 0)
    80003dda:	fc045783          	lhu	a5,-64(s0)
    80003dde:	c791                	beqz	a5,80003dea <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003de0:	24c1                	addiw	s1,s1,16
    80003de2:	04c92783          	lw	a5,76(s2)
    80003de6:	fcf4ede3          	bltu	s1,a5,80003dc0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003dea:	4639                	li	a2,14
    80003dec:	85d2                	mv	a1,s4
    80003dee:	fc240513          	addi	a0,s0,-62
    80003df2:	ffffd097          	auipc	ra,0xffffd
    80003df6:	fec080e7          	jalr	-20(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003dfa:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dfe:	4741                	li	a4,16
    80003e00:	86a6                	mv	a3,s1
    80003e02:	fc040613          	addi	a2,s0,-64
    80003e06:	4581                	li	a1,0
    80003e08:	854a                	mv	a0,s2
    80003e0a:	00000097          	auipc	ra,0x0
    80003e0e:	c3e080e7          	jalr	-962(ra) # 80003a48 <writei>
    80003e12:	1541                	addi	a0,a0,-16
    80003e14:	00a03533          	snez	a0,a0
    80003e18:	40a00533          	neg	a0,a0
}
    80003e1c:	70e2                	ld	ra,56(sp)
    80003e1e:	7442                	ld	s0,48(sp)
    80003e20:	74a2                	ld	s1,40(sp)
    80003e22:	7902                	ld	s2,32(sp)
    80003e24:	69e2                	ld	s3,24(sp)
    80003e26:	6a42                	ld	s4,16(sp)
    80003e28:	6121                	addi	sp,sp,64
    80003e2a:	8082                	ret
    iput(ip);
    80003e2c:	00000097          	auipc	ra,0x0
    80003e30:	a2a080e7          	jalr	-1494(ra) # 80003856 <iput>
    return -1;
    80003e34:	557d                	li	a0,-1
    80003e36:	b7dd                	j	80003e1c <dirlink+0x86>
      panic("dirlink read");
    80003e38:	00005517          	auipc	a0,0x5
    80003e3c:	80050513          	addi	a0,a0,-2048 # 80008638 <syscalls+0x1d0>
    80003e40:	ffffc097          	auipc	ra,0xffffc
    80003e44:	700080e7          	jalr	1792(ra) # 80000540 <panic>

0000000080003e48 <namei>:

struct inode*
namei(char *path)
{
    80003e48:	1101                	addi	sp,sp,-32
    80003e4a:	ec06                	sd	ra,24(sp)
    80003e4c:	e822                	sd	s0,16(sp)
    80003e4e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e50:	fe040613          	addi	a2,s0,-32
    80003e54:	4581                	li	a1,0
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	dda080e7          	jalr	-550(ra) # 80003c30 <namex>
}
    80003e5e:	60e2                	ld	ra,24(sp)
    80003e60:	6442                	ld	s0,16(sp)
    80003e62:	6105                	addi	sp,sp,32
    80003e64:	8082                	ret

0000000080003e66 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e66:	1141                	addi	sp,sp,-16
    80003e68:	e406                	sd	ra,8(sp)
    80003e6a:	e022                	sd	s0,0(sp)
    80003e6c:	0800                	addi	s0,sp,16
    80003e6e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e70:	4585                	li	a1,1
    80003e72:	00000097          	auipc	ra,0x0
    80003e76:	dbe080e7          	jalr	-578(ra) # 80003c30 <namex>
}
    80003e7a:	60a2                	ld	ra,8(sp)
    80003e7c:	6402                	ld	s0,0(sp)
    80003e7e:	0141                	addi	sp,sp,16
    80003e80:	8082                	ret

0000000080003e82 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e82:	1101                	addi	sp,sp,-32
    80003e84:	ec06                	sd	ra,24(sp)
    80003e86:	e822                	sd	s0,16(sp)
    80003e88:	e426                	sd	s1,8(sp)
    80003e8a:	e04a                	sd	s2,0(sp)
    80003e8c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e8e:	0001d917          	auipc	s2,0x1d
    80003e92:	cb290913          	addi	s2,s2,-846 # 80020b40 <log>
    80003e96:	01892583          	lw	a1,24(s2)
    80003e9a:	02892503          	lw	a0,40(s2)
    80003e9e:	fffff097          	auipc	ra,0xfffff
    80003ea2:	fe6080e7          	jalr	-26(ra) # 80002e84 <bread>
    80003ea6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ea8:	02c92683          	lw	a3,44(s2)
    80003eac:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003eae:	02d05863          	blez	a3,80003ede <write_head+0x5c>
    80003eb2:	0001d797          	auipc	a5,0x1d
    80003eb6:	cbe78793          	addi	a5,a5,-834 # 80020b70 <log+0x30>
    80003eba:	05c50713          	addi	a4,a0,92
    80003ebe:	36fd                	addiw	a3,a3,-1
    80003ec0:	02069613          	slli	a2,a3,0x20
    80003ec4:	01e65693          	srli	a3,a2,0x1e
    80003ec8:	0001d617          	auipc	a2,0x1d
    80003ecc:	cac60613          	addi	a2,a2,-852 # 80020b74 <log+0x34>
    80003ed0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003ed2:	4390                	lw	a2,0(a5)
    80003ed4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ed6:	0791                	addi	a5,a5,4
    80003ed8:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003eda:	fed79ce3          	bne	a5,a3,80003ed2 <write_head+0x50>
  }
  bwrite(buf);
    80003ede:	8526                	mv	a0,s1
    80003ee0:	fffff097          	auipc	ra,0xfffff
    80003ee4:	096080e7          	jalr	150(ra) # 80002f76 <bwrite>
  brelse(buf);
    80003ee8:	8526                	mv	a0,s1
    80003eea:	fffff097          	auipc	ra,0xfffff
    80003eee:	0ca080e7          	jalr	202(ra) # 80002fb4 <brelse>
}
    80003ef2:	60e2                	ld	ra,24(sp)
    80003ef4:	6442                	ld	s0,16(sp)
    80003ef6:	64a2                	ld	s1,8(sp)
    80003ef8:	6902                	ld	s2,0(sp)
    80003efa:	6105                	addi	sp,sp,32
    80003efc:	8082                	ret

0000000080003efe <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003efe:	0001d797          	auipc	a5,0x1d
    80003f02:	c6e7a783          	lw	a5,-914(a5) # 80020b6c <log+0x2c>
    80003f06:	0af05d63          	blez	a5,80003fc0 <install_trans+0xc2>
{
    80003f0a:	7139                	addi	sp,sp,-64
    80003f0c:	fc06                	sd	ra,56(sp)
    80003f0e:	f822                	sd	s0,48(sp)
    80003f10:	f426                	sd	s1,40(sp)
    80003f12:	f04a                	sd	s2,32(sp)
    80003f14:	ec4e                	sd	s3,24(sp)
    80003f16:	e852                	sd	s4,16(sp)
    80003f18:	e456                	sd	s5,8(sp)
    80003f1a:	e05a                	sd	s6,0(sp)
    80003f1c:	0080                	addi	s0,sp,64
    80003f1e:	8b2a                	mv	s6,a0
    80003f20:	0001da97          	auipc	s5,0x1d
    80003f24:	c50a8a93          	addi	s5,s5,-944 # 80020b70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f28:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f2a:	0001d997          	auipc	s3,0x1d
    80003f2e:	c1698993          	addi	s3,s3,-1002 # 80020b40 <log>
    80003f32:	a00d                	j	80003f54 <install_trans+0x56>
    brelse(lbuf);
    80003f34:	854a                	mv	a0,s2
    80003f36:	fffff097          	auipc	ra,0xfffff
    80003f3a:	07e080e7          	jalr	126(ra) # 80002fb4 <brelse>
    brelse(dbuf);
    80003f3e:	8526                	mv	a0,s1
    80003f40:	fffff097          	auipc	ra,0xfffff
    80003f44:	074080e7          	jalr	116(ra) # 80002fb4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f48:	2a05                	addiw	s4,s4,1
    80003f4a:	0a91                	addi	s5,s5,4
    80003f4c:	02c9a783          	lw	a5,44(s3)
    80003f50:	04fa5e63          	bge	s4,a5,80003fac <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f54:	0189a583          	lw	a1,24(s3)
    80003f58:	014585bb          	addw	a1,a1,s4
    80003f5c:	2585                	addiw	a1,a1,1
    80003f5e:	0289a503          	lw	a0,40(s3)
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	f22080e7          	jalr	-222(ra) # 80002e84 <bread>
    80003f6a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f6c:	000aa583          	lw	a1,0(s5)
    80003f70:	0289a503          	lw	a0,40(s3)
    80003f74:	fffff097          	auipc	ra,0xfffff
    80003f78:	f10080e7          	jalr	-240(ra) # 80002e84 <bread>
    80003f7c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f7e:	40000613          	li	a2,1024
    80003f82:	05890593          	addi	a1,s2,88
    80003f86:	05850513          	addi	a0,a0,88
    80003f8a:	ffffd097          	auipc	ra,0xffffd
    80003f8e:	da4080e7          	jalr	-604(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f92:	8526                	mv	a0,s1
    80003f94:	fffff097          	auipc	ra,0xfffff
    80003f98:	fe2080e7          	jalr	-30(ra) # 80002f76 <bwrite>
    if(recovering == 0)
    80003f9c:	f80b1ce3          	bnez	s6,80003f34 <install_trans+0x36>
      bunpin(dbuf);
    80003fa0:	8526                	mv	a0,s1
    80003fa2:	fffff097          	auipc	ra,0xfffff
    80003fa6:	0ec080e7          	jalr	236(ra) # 8000308e <bunpin>
    80003faa:	b769                	j	80003f34 <install_trans+0x36>
}
    80003fac:	70e2                	ld	ra,56(sp)
    80003fae:	7442                	ld	s0,48(sp)
    80003fb0:	74a2                	ld	s1,40(sp)
    80003fb2:	7902                	ld	s2,32(sp)
    80003fb4:	69e2                	ld	s3,24(sp)
    80003fb6:	6a42                	ld	s4,16(sp)
    80003fb8:	6aa2                	ld	s5,8(sp)
    80003fba:	6b02                	ld	s6,0(sp)
    80003fbc:	6121                	addi	sp,sp,64
    80003fbe:	8082                	ret
    80003fc0:	8082                	ret

0000000080003fc2 <initlog>:
{
    80003fc2:	7179                	addi	sp,sp,-48
    80003fc4:	f406                	sd	ra,40(sp)
    80003fc6:	f022                	sd	s0,32(sp)
    80003fc8:	ec26                	sd	s1,24(sp)
    80003fca:	e84a                	sd	s2,16(sp)
    80003fcc:	e44e                	sd	s3,8(sp)
    80003fce:	1800                	addi	s0,sp,48
    80003fd0:	892a                	mv	s2,a0
    80003fd2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fd4:	0001d497          	auipc	s1,0x1d
    80003fd8:	b6c48493          	addi	s1,s1,-1172 # 80020b40 <log>
    80003fdc:	00004597          	auipc	a1,0x4
    80003fe0:	66c58593          	addi	a1,a1,1644 # 80008648 <syscalls+0x1e0>
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	ffffd097          	auipc	ra,0xffffd
    80003fea:	b60080e7          	jalr	-1184(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80003fee:	0149a583          	lw	a1,20(s3)
    80003ff2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003ff4:	0109a783          	lw	a5,16(s3)
    80003ff8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ffa:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ffe:	854a                	mv	a0,s2
    80004000:	fffff097          	auipc	ra,0xfffff
    80004004:	e84080e7          	jalr	-380(ra) # 80002e84 <bread>
  log.lh.n = lh->n;
    80004008:	4d34                	lw	a3,88(a0)
    8000400a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000400c:	02d05663          	blez	a3,80004038 <initlog+0x76>
    80004010:	05c50793          	addi	a5,a0,92
    80004014:	0001d717          	auipc	a4,0x1d
    80004018:	b5c70713          	addi	a4,a4,-1188 # 80020b70 <log+0x30>
    8000401c:	36fd                	addiw	a3,a3,-1
    8000401e:	02069613          	slli	a2,a3,0x20
    80004022:	01e65693          	srli	a3,a2,0x1e
    80004026:	06050613          	addi	a2,a0,96
    8000402a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000402c:	4390                	lw	a2,0(a5)
    8000402e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004030:	0791                	addi	a5,a5,4
    80004032:	0711                	addi	a4,a4,4
    80004034:	fed79ce3          	bne	a5,a3,8000402c <initlog+0x6a>
  brelse(buf);
    80004038:	fffff097          	auipc	ra,0xfffff
    8000403c:	f7c080e7          	jalr	-132(ra) # 80002fb4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004040:	4505                	li	a0,1
    80004042:	00000097          	auipc	ra,0x0
    80004046:	ebc080e7          	jalr	-324(ra) # 80003efe <install_trans>
  log.lh.n = 0;
    8000404a:	0001d797          	auipc	a5,0x1d
    8000404e:	b207a123          	sw	zero,-1246(a5) # 80020b6c <log+0x2c>
  write_head(); // clear the log
    80004052:	00000097          	auipc	ra,0x0
    80004056:	e30080e7          	jalr	-464(ra) # 80003e82 <write_head>
}
    8000405a:	70a2                	ld	ra,40(sp)
    8000405c:	7402                	ld	s0,32(sp)
    8000405e:	64e2                	ld	s1,24(sp)
    80004060:	6942                	ld	s2,16(sp)
    80004062:	69a2                	ld	s3,8(sp)
    80004064:	6145                	addi	sp,sp,48
    80004066:	8082                	ret

0000000080004068 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004068:	1101                	addi	sp,sp,-32
    8000406a:	ec06                	sd	ra,24(sp)
    8000406c:	e822                	sd	s0,16(sp)
    8000406e:	e426                	sd	s1,8(sp)
    80004070:	e04a                	sd	s2,0(sp)
    80004072:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004074:	0001d517          	auipc	a0,0x1d
    80004078:	acc50513          	addi	a0,a0,-1332 # 80020b40 <log>
    8000407c:	ffffd097          	auipc	ra,0xffffd
    80004080:	b5a080e7          	jalr	-1190(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004084:	0001d497          	auipc	s1,0x1d
    80004088:	abc48493          	addi	s1,s1,-1348 # 80020b40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000408c:	4979                	li	s2,30
    8000408e:	a039                	j	8000409c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004090:	85a6                	mv	a1,s1
    80004092:	8526                	mv	a0,s1
    80004094:	ffffe097          	auipc	ra,0xffffe
    80004098:	fc0080e7          	jalr	-64(ra) # 80002054 <sleep>
    if(log.committing){
    8000409c:	50dc                	lw	a5,36(s1)
    8000409e:	fbed                	bnez	a5,80004090 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040a0:	5098                	lw	a4,32(s1)
    800040a2:	2705                	addiw	a4,a4,1
    800040a4:	0007069b          	sext.w	a3,a4
    800040a8:	0027179b          	slliw	a5,a4,0x2
    800040ac:	9fb9                	addw	a5,a5,a4
    800040ae:	0017979b          	slliw	a5,a5,0x1
    800040b2:	54d8                	lw	a4,44(s1)
    800040b4:	9fb9                	addw	a5,a5,a4
    800040b6:	00f95963          	bge	s2,a5,800040c8 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040ba:	85a6                	mv	a1,s1
    800040bc:	8526                	mv	a0,s1
    800040be:	ffffe097          	auipc	ra,0xffffe
    800040c2:	f96080e7          	jalr	-106(ra) # 80002054 <sleep>
    800040c6:	bfd9                	j	8000409c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040c8:	0001d517          	auipc	a0,0x1d
    800040cc:	a7850513          	addi	a0,a0,-1416 # 80020b40 <log>
    800040d0:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800040d2:	ffffd097          	auipc	ra,0xffffd
    800040d6:	bb8080e7          	jalr	-1096(ra) # 80000c8a <release>
      break;
    }
  }
}
    800040da:	60e2                	ld	ra,24(sp)
    800040dc:	6442                	ld	s0,16(sp)
    800040de:	64a2                	ld	s1,8(sp)
    800040e0:	6902                	ld	s2,0(sp)
    800040e2:	6105                	addi	sp,sp,32
    800040e4:	8082                	ret

00000000800040e6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040e6:	7139                	addi	sp,sp,-64
    800040e8:	fc06                	sd	ra,56(sp)
    800040ea:	f822                	sd	s0,48(sp)
    800040ec:	f426                	sd	s1,40(sp)
    800040ee:	f04a                	sd	s2,32(sp)
    800040f0:	ec4e                	sd	s3,24(sp)
    800040f2:	e852                	sd	s4,16(sp)
    800040f4:	e456                	sd	s5,8(sp)
    800040f6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040f8:	0001d497          	auipc	s1,0x1d
    800040fc:	a4848493          	addi	s1,s1,-1464 # 80020b40 <log>
    80004100:	8526                	mv	a0,s1
    80004102:	ffffd097          	auipc	ra,0xffffd
    80004106:	ad4080e7          	jalr	-1324(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000410a:	509c                	lw	a5,32(s1)
    8000410c:	37fd                	addiw	a5,a5,-1
    8000410e:	0007891b          	sext.w	s2,a5
    80004112:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004114:	50dc                	lw	a5,36(s1)
    80004116:	e7b9                	bnez	a5,80004164 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004118:	04091e63          	bnez	s2,80004174 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000411c:	0001d497          	auipc	s1,0x1d
    80004120:	a2448493          	addi	s1,s1,-1500 # 80020b40 <log>
    80004124:	4785                	li	a5,1
    80004126:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004128:	8526                	mv	a0,s1
    8000412a:	ffffd097          	auipc	ra,0xffffd
    8000412e:	b60080e7          	jalr	-1184(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004132:	54dc                	lw	a5,44(s1)
    80004134:	06f04763          	bgtz	a5,800041a2 <end_op+0xbc>
    acquire(&log.lock);
    80004138:	0001d497          	auipc	s1,0x1d
    8000413c:	a0848493          	addi	s1,s1,-1528 # 80020b40 <log>
    80004140:	8526                	mv	a0,s1
    80004142:	ffffd097          	auipc	ra,0xffffd
    80004146:	a94080e7          	jalr	-1388(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000414a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000414e:	8526                	mv	a0,s1
    80004150:	ffffe097          	auipc	ra,0xffffe
    80004154:	f68080e7          	jalr	-152(ra) # 800020b8 <wakeup>
    release(&log.lock);
    80004158:	8526                	mv	a0,s1
    8000415a:	ffffd097          	auipc	ra,0xffffd
    8000415e:	b30080e7          	jalr	-1232(ra) # 80000c8a <release>
}
    80004162:	a03d                	j	80004190 <end_op+0xaa>
    panic("log.committing");
    80004164:	00004517          	auipc	a0,0x4
    80004168:	4ec50513          	addi	a0,a0,1260 # 80008650 <syscalls+0x1e8>
    8000416c:	ffffc097          	auipc	ra,0xffffc
    80004170:	3d4080e7          	jalr	980(ra) # 80000540 <panic>
    wakeup(&log);
    80004174:	0001d497          	auipc	s1,0x1d
    80004178:	9cc48493          	addi	s1,s1,-1588 # 80020b40 <log>
    8000417c:	8526                	mv	a0,s1
    8000417e:	ffffe097          	auipc	ra,0xffffe
    80004182:	f3a080e7          	jalr	-198(ra) # 800020b8 <wakeup>
  release(&log.lock);
    80004186:	8526                	mv	a0,s1
    80004188:	ffffd097          	auipc	ra,0xffffd
    8000418c:	b02080e7          	jalr	-1278(ra) # 80000c8a <release>
}
    80004190:	70e2                	ld	ra,56(sp)
    80004192:	7442                	ld	s0,48(sp)
    80004194:	74a2                	ld	s1,40(sp)
    80004196:	7902                	ld	s2,32(sp)
    80004198:	69e2                	ld	s3,24(sp)
    8000419a:	6a42                	ld	s4,16(sp)
    8000419c:	6aa2                	ld	s5,8(sp)
    8000419e:	6121                	addi	sp,sp,64
    800041a0:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a2:	0001da97          	auipc	s5,0x1d
    800041a6:	9cea8a93          	addi	s5,s5,-1586 # 80020b70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041aa:	0001da17          	auipc	s4,0x1d
    800041ae:	996a0a13          	addi	s4,s4,-1642 # 80020b40 <log>
    800041b2:	018a2583          	lw	a1,24(s4)
    800041b6:	012585bb          	addw	a1,a1,s2
    800041ba:	2585                	addiw	a1,a1,1
    800041bc:	028a2503          	lw	a0,40(s4)
    800041c0:	fffff097          	auipc	ra,0xfffff
    800041c4:	cc4080e7          	jalr	-828(ra) # 80002e84 <bread>
    800041c8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041ca:	000aa583          	lw	a1,0(s5)
    800041ce:	028a2503          	lw	a0,40(s4)
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	cb2080e7          	jalr	-846(ra) # 80002e84 <bread>
    800041da:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041dc:	40000613          	li	a2,1024
    800041e0:	05850593          	addi	a1,a0,88
    800041e4:	05848513          	addi	a0,s1,88
    800041e8:	ffffd097          	auipc	ra,0xffffd
    800041ec:	b46080e7          	jalr	-1210(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800041f0:	8526                	mv	a0,s1
    800041f2:	fffff097          	auipc	ra,0xfffff
    800041f6:	d84080e7          	jalr	-636(ra) # 80002f76 <bwrite>
    brelse(from);
    800041fa:	854e                	mv	a0,s3
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	db8080e7          	jalr	-584(ra) # 80002fb4 <brelse>
    brelse(to);
    80004204:	8526                	mv	a0,s1
    80004206:	fffff097          	auipc	ra,0xfffff
    8000420a:	dae080e7          	jalr	-594(ra) # 80002fb4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000420e:	2905                	addiw	s2,s2,1
    80004210:	0a91                	addi	s5,s5,4
    80004212:	02ca2783          	lw	a5,44(s4)
    80004216:	f8f94ee3          	blt	s2,a5,800041b2 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000421a:	00000097          	auipc	ra,0x0
    8000421e:	c68080e7          	jalr	-920(ra) # 80003e82 <write_head>
    install_trans(0); // Now install writes to home locations
    80004222:	4501                	li	a0,0
    80004224:	00000097          	auipc	ra,0x0
    80004228:	cda080e7          	jalr	-806(ra) # 80003efe <install_trans>
    log.lh.n = 0;
    8000422c:	0001d797          	auipc	a5,0x1d
    80004230:	9407a023          	sw	zero,-1728(a5) # 80020b6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004234:	00000097          	auipc	ra,0x0
    80004238:	c4e080e7          	jalr	-946(ra) # 80003e82 <write_head>
    8000423c:	bdf5                	j	80004138 <end_op+0x52>

000000008000423e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000423e:	1101                	addi	sp,sp,-32
    80004240:	ec06                	sd	ra,24(sp)
    80004242:	e822                	sd	s0,16(sp)
    80004244:	e426                	sd	s1,8(sp)
    80004246:	e04a                	sd	s2,0(sp)
    80004248:	1000                	addi	s0,sp,32
    8000424a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000424c:	0001d917          	auipc	s2,0x1d
    80004250:	8f490913          	addi	s2,s2,-1804 # 80020b40 <log>
    80004254:	854a                	mv	a0,s2
    80004256:	ffffd097          	auipc	ra,0xffffd
    8000425a:	980080e7          	jalr	-1664(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000425e:	02c92603          	lw	a2,44(s2)
    80004262:	47f5                	li	a5,29
    80004264:	06c7c563          	blt	a5,a2,800042ce <log_write+0x90>
    80004268:	0001d797          	auipc	a5,0x1d
    8000426c:	8f47a783          	lw	a5,-1804(a5) # 80020b5c <log+0x1c>
    80004270:	37fd                	addiw	a5,a5,-1
    80004272:	04f65e63          	bge	a2,a5,800042ce <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004276:	0001d797          	auipc	a5,0x1d
    8000427a:	8ea7a783          	lw	a5,-1814(a5) # 80020b60 <log+0x20>
    8000427e:	06f05063          	blez	a5,800042de <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004282:	4781                	li	a5,0
    80004284:	06c05563          	blez	a2,800042ee <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004288:	44cc                	lw	a1,12(s1)
    8000428a:	0001d717          	auipc	a4,0x1d
    8000428e:	8e670713          	addi	a4,a4,-1818 # 80020b70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004292:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004294:	4314                	lw	a3,0(a4)
    80004296:	04b68c63          	beq	a3,a1,800042ee <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000429a:	2785                	addiw	a5,a5,1
    8000429c:	0711                	addi	a4,a4,4
    8000429e:	fef61be3          	bne	a2,a5,80004294 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042a2:	0621                	addi	a2,a2,8
    800042a4:	060a                	slli	a2,a2,0x2
    800042a6:	0001d797          	auipc	a5,0x1d
    800042aa:	89a78793          	addi	a5,a5,-1894 # 80020b40 <log>
    800042ae:	97b2                	add	a5,a5,a2
    800042b0:	44d8                	lw	a4,12(s1)
    800042b2:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042b4:	8526                	mv	a0,s1
    800042b6:	fffff097          	auipc	ra,0xfffff
    800042ba:	d9c080e7          	jalr	-612(ra) # 80003052 <bpin>
    log.lh.n++;
    800042be:	0001d717          	auipc	a4,0x1d
    800042c2:	88270713          	addi	a4,a4,-1918 # 80020b40 <log>
    800042c6:	575c                	lw	a5,44(a4)
    800042c8:	2785                	addiw	a5,a5,1
    800042ca:	d75c                	sw	a5,44(a4)
    800042cc:	a82d                	j	80004306 <log_write+0xc8>
    panic("too big a transaction");
    800042ce:	00004517          	auipc	a0,0x4
    800042d2:	39250513          	addi	a0,a0,914 # 80008660 <syscalls+0x1f8>
    800042d6:	ffffc097          	auipc	ra,0xffffc
    800042da:	26a080e7          	jalr	618(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    800042de:	00004517          	auipc	a0,0x4
    800042e2:	39a50513          	addi	a0,a0,922 # 80008678 <syscalls+0x210>
    800042e6:	ffffc097          	auipc	ra,0xffffc
    800042ea:	25a080e7          	jalr	602(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    800042ee:	00878693          	addi	a3,a5,8
    800042f2:	068a                	slli	a3,a3,0x2
    800042f4:	0001d717          	auipc	a4,0x1d
    800042f8:	84c70713          	addi	a4,a4,-1972 # 80020b40 <log>
    800042fc:	9736                	add	a4,a4,a3
    800042fe:	44d4                	lw	a3,12(s1)
    80004300:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004302:	faf609e3          	beq	a2,a5,800042b4 <log_write+0x76>
  }
  release(&log.lock);
    80004306:	0001d517          	auipc	a0,0x1d
    8000430a:	83a50513          	addi	a0,a0,-1990 # 80020b40 <log>
    8000430e:	ffffd097          	auipc	ra,0xffffd
    80004312:	97c080e7          	jalr	-1668(ra) # 80000c8a <release>
}
    80004316:	60e2                	ld	ra,24(sp)
    80004318:	6442                	ld	s0,16(sp)
    8000431a:	64a2                	ld	s1,8(sp)
    8000431c:	6902                	ld	s2,0(sp)
    8000431e:	6105                	addi	sp,sp,32
    80004320:	8082                	ret

0000000080004322 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004322:	1101                	addi	sp,sp,-32
    80004324:	ec06                	sd	ra,24(sp)
    80004326:	e822                	sd	s0,16(sp)
    80004328:	e426                	sd	s1,8(sp)
    8000432a:	e04a                	sd	s2,0(sp)
    8000432c:	1000                	addi	s0,sp,32
    8000432e:	84aa                	mv	s1,a0
    80004330:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004332:	00004597          	auipc	a1,0x4
    80004336:	36658593          	addi	a1,a1,870 # 80008698 <syscalls+0x230>
    8000433a:	0521                	addi	a0,a0,8
    8000433c:	ffffd097          	auipc	ra,0xffffd
    80004340:	80a080e7          	jalr	-2038(ra) # 80000b46 <initlock>
  lk->name = name;
    80004344:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004348:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000434c:	0204a423          	sw	zero,40(s1)
}
    80004350:	60e2                	ld	ra,24(sp)
    80004352:	6442                	ld	s0,16(sp)
    80004354:	64a2                	ld	s1,8(sp)
    80004356:	6902                	ld	s2,0(sp)
    80004358:	6105                	addi	sp,sp,32
    8000435a:	8082                	ret

000000008000435c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	e426                	sd	s1,8(sp)
    80004364:	e04a                	sd	s2,0(sp)
    80004366:	1000                	addi	s0,sp,32
    80004368:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000436a:	00850913          	addi	s2,a0,8
    8000436e:	854a                	mv	a0,s2
    80004370:	ffffd097          	auipc	ra,0xffffd
    80004374:	866080e7          	jalr	-1946(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004378:	409c                	lw	a5,0(s1)
    8000437a:	cb89                	beqz	a5,8000438c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000437c:	85ca                	mv	a1,s2
    8000437e:	8526                	mv	a0,s1
    80004380:	ffffe097          	auipc	ra,0xffffe
    80004384:	cd4080e7          	jalr	-812(ra) # 80002054 <sleep>
  while (lk->locked) {
    80004388:	409c                	lw	a5,0(s1)
    8000438a:	fbed                	bnez	a5,8000437c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000438c:	4785                	li	a5,1
    8000438e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004390:	ffffd097          	auipc	ra,0xffffd
    80004394:	61c080e7          	jalr	1564(ra) # 800019ac <myproc>
    80004398:	591c                	lw	a5,48(a0)
    8000439a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000439c:	854a                	mv	a0,s2
    8000439e:	ffffd097          	auipc	ra,0xffffd
    800043a2:	8ec080e7          	jalr	-1812(ra) # 80000c8a <release>
}
    800043a6:	60e2                	ld	ra,24(sp)
    800043a8:	6442                	ld	s0,16(sp)
    800043aa:	64a2                	ld	s1,8(sp)
    800043ac:	6902                	ld	s2,0(sp)
    800043ae:	6105                	addi	sp,sp,32
    800043b0:	8082                	ret

00000000800043b2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043b2:	1101                	addi	sp,sp,-32
    800043b4:	ec06                	sd	ra,24(sp)
    800043b6:	e822                	sd	s0,16(sp)
    800043b8:	e426                	sd	s1,8(sp)
    800043ba:	e04a                	sd	s2,0(sp)
    800043bc:	1000                	addi	s0,sp,32
    800043be:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043c0:	00850913          	addi	s2,a0,8
    800043c4:	854a                	mv	a0,s2
    800043c6:	ffffd097          	auipc	ra,0xffffd
    800043ca:	810080e7          	jalr	-2032(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800043ce:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043d2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043d6:	8526                	mv	a0,s1
    800043d8:	ffffe097          	auipc	ra,0xffffe
    800043dc:	ce0080e7          	jalr	-800(ra) # 800020b8 <wakeup>
  release(&lk->lk);
    800043e0:	854a                	mv	a0,s2
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	8a8080e7          	jalr	-1880(ra) # 80000c8a <release>
}
    800043ea:	60e2                	ld	ra,24(sp)
    800043ec:	6442                	ld	s0,16(sp)
    800043ee:	64a2                	ld	s1,8(sp)
    800043f0:	6902                	ld	s2,0(sp)
    800043f2:	6105                	addi	sp,sp,32
    800043f4:	8082                	ret

00000000800043f6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043f6:	7179                	addi	sp,sp,-48
    800043f8:	f406                	sd	ra,40(sp)
    800043fa:	f022                	sd	s0,32(sp)
    800043fc:	ec26                	sd	s1,24(sp)
    800043fe:	e84a                	sd	s2,16(sp)
    80004400:	e44e                	sd	s3,8(sp)
    80004402:	1800                	addi	s0,sp,48
    80004404:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004406:	00850913          	addi	s2,a0,8
    8000440a:	854a                	mv	a0,s2
    8000440c:	ffffc097          	auipc	ra,0xffffc
    80004410:	7ca080e7          	jalr	1994(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004414:	409c                	lw	a5,0(s1)
    80004416:	ef99                	bnez	a5,80004434 <holdingsleep+0x3e>
    80004418:	4481                	li	s1,0
  release(&lk->lk);
    8000441a:	854a                	mv	a0,s2
    8000441c:	ffffd097          	auipc	ra,0xffffd
    80004420:	86e080e7          	jalr	-1938(ra) # 80000c8a <release>
  return r;
}
    80004424:	8526                	mv	a0,s1
    80004426:	70a2                	ld	ra,40(sp)
    80004428:	7402                	ld	s0,32(sp)
    8000442a:	64e2                	ld	s1,24(sp)
    8000442c:	6942                	ld	s2,16(sp)
    8000442e:	69a2                	ld	s3,8(sp)
    80004430:	6145                	addi	sp,sp,48
    80004432:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004434:	0284a983          	lw	s3,40(s1)
    80004438:	ffffd097          	auipc	ra,0xffffd
    8000443c:	574080e7          	jalr	1396(ra) # 800019ac <myproc>
    80004440:	5904                	lw	s1,48(a0)
    80004442:	413484b3          	sub	s1,s1,s3
    80004446:	0014b493          	seqz	s1,s1
    8000444a:	bfc1                	j	8000441a <holdingsleep+0x24>

000000008000444c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000444c:	1141                	addi	sp,sp,-16
    8000444e:	e406                	sd	ra,8(sp)
    80004450:	e022                	sd	s0,0(sp)
    80004452:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004454:	00004597          	auipc	a1,0x4
    80004458:	25458593          	addi	a1,a1,596 # 800086a8 <syscalls+0x240>
    8000445c:	0001d517          	auipc	a0,0x1d
    80004460:	82c50513          	addi	a0,a0,-2004 # 80020c88 <ftable>
    80004464:	ffffc097          	auipc	ra,0xffffc
    80004468:	6e2080e7          	jalr	1762(ra) # 80000b46 <initlock>
}
    8000446c:	60a2                	ld	ra,8(sp)
    8000446e:	6402                	ld	s0,0(sp)
    80004470:	0141                	addi	sp,sp,16
    80004472:	8082                	ret

0000000080004474 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004474:	1101                	addi	sp,sp,-32
    80004476:	ec06                	sd	ra,24(sp)
    80004478:	e822                	sd	s0,16(sp)
    8000447a:	e426                	sd	s1,8(sp)
    8000447c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000447e:	0001d517          	auipc	a0,0x1d
    80004482:	80a50513          	addi	a0,a0,-2038 # 80020c88 <ftable>
    80004486:	ffffc097          	auipc	ra,0xffffc
    8000448a:	750080e7          	jalr	1872(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000448e:	0001d497          	auipc	s1,0x1d
    80004492:	81248493          	addi	s1,s1,-2030 # 80020ca0 <ftable+0x18>
    80004496:	0001d717          	auipc	a4,0x1d
    8000449a:	7aa70713          	addi	a4,a4,1962 # 80021c40 <disk>
    if(f->ref == 0){
    8000449e:	40dc                	lw	a5,4(s1)
    800044a0:	cf99                	beqz	a5,800044be <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044a2:	02848493          	addi	s1,s1,40
    800044a6:	fee49ce3          	bne	s1,a4,8000449e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044aa:	0001c517          	auipc	a0,0x1c
    800044ae:	7de50513          	addi	a0,a0,2014 # 80020c88 <ftable>
    800044b2:	ffffc097          	auipc	ra,0xffffc
    800044b6:	7d8080e7          	jalr	2008(ra) # 80000c8a <release>
  return 0;
    800044ba:	4481                	li	s1,0
    800044bc:	a819                	j	800044d2 <filealloc+0x5e>
      f->ref = 1;
    800044be:	4785                	li	a5,1
    800044c0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044c2:	0001c517          	auipc	a0,0x1c
    800044c6:	7c650513          	addi	a0,a0,1990 # 80020c88 <ftable>
    800044ca:	ffffc097          	auipc	ra,0xffffc
    800044ce:	7c0080e7          	jalr	1984(ra) # 80000c8a <release>
}
    800044d2:	8526                	mv	a0,s1
    800044d4:	60e2                	ld	ra,24(sp)
    800044d6:	6442                	ld	s0,16(sp)
    800044d8:	64a2                	ld	s1,8(sp)
    800044da:	6105                	addi	sp,sp,32
    800044dc:	8082                	ret

00000000800044de <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044de:	1101                	addi	sp,sp,-32
    800044e0:	ec06                	sd	ra,24(sp)
    800044e2:	e822                	sd	s0,16(sp)
    800044e4:	e426                	sd	s1,8(sp)
    800044e6:	1000                	addi	s0,sp,32
    800044e8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044ea:	0001c517          	auipc	a0,0x1c
    800044ee:	79e50513          	addi	a0,a0,1950 # 80020c88 <ftable>
    800044f2:	ffffc097          	auipc	ra,0xffffc
    800044f6:	6e4080e7          	jalr	1764(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800044fa:	40dc                	lw	a5,4(s1)
    800044fc:	02f05263          	blez	a5,80004520 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004500:	2785                	addiw	a5,a5,1
    80004502:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004504:	0001c517          	auipc	a0,0x1c
    80004508:	78450513          	addi	a0,a0,1924 # 80020c88 <ftable>
    8000450c:	ffffc097          	auipc	ra,0xffffc
    80004510:	77e080e7          	jalr	1918(ra) # 80000c8a <release>
  return f;
}
    80004514:	8526                	mv	a0,s1
    80004516:	60e2                	ld	ra,24(sp)
    80004518:	6442                	ld	s0,16(sp)
    8000451a:	64a2                	ld	s1,8(sp)
    8000451c:	6105                	addi	sp,sp,32
    8000451e:	8082                	ret
    panic("filedup");
    80004520:	00004517          	auipc	a0,0x4
    80004524:	19050513          	addi	a0,a0,400 # 800086b0 <syscalls+0x248>
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	018080e7          	jalr	24(ra) # 80000540 <panic>

0000000080004530 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004530:	7139                	addi	sp,sp,-64
    80004532:	fc06                	sd	ra,56(sp)
    80004534:	f822                	sd	s0,48(sp)
    80004536:	f426                	sd	s1,40(sp)
    80004538:	f04a                	sd	s2,32(sp)
    8000453a:	ec4e                	sd	s3,24(sp)
    8000453c:	e852                	sd	s4,16(sp)
    8000453e:	e456                	sd	s5,8(sp)
    80004540:	0080                	addi	s0,sp,64
    80004542:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004544:	0001c517          	auipc	a0,0x1c
    80004548:	74450513          	addi	a0,a0,1860 # 80020c88 <ftable>
    8000454c:	ffffc097          	auipc	ra,0xffffc
    80004550:	68a080e7          	jalr	1674(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004554:	40dc                	lw	a5,4(s1)
    80004556:	06f05163          	blez	a5,800045b8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000455a:	37fd                	addiw	a5,a5,-1
    8000455c:	0007871b          	sext.w	a4,a5
    80004560:	c0dc                	sw	a5,4(s1)
    80004562:	06e04363          	bgtz	a4,800045c8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004566:	0004a903          	lw	s2,0(s1)
    8000456a:	0094ca83          	lbu	s5,9(s1)
    8000456e:	0104ba03          	ld	s4,16(s1)
    80004572:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004576:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000457a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000457e:	0001c517          	auipc	a0,0x1c
    80004582:	70a50513          	addi	a0,a0,1802 # 80020c88 <ftable>
    80004586:	ffffc097          	auipc	ra,0xffffc
    8000458a:	704080e7          	jalr	1796(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    8000458e:	4785                	li	a5,1
    80004590:	04f90d63          	beq	s2,a5,800045ea <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004594:	3979                	addiw	s2,s2,-2
    80004596:	4785                	li	a5,1
    80004598:	0527e063          	bltu	a5,s2,800045d8 <fileclose+0xa8>
    begin_op();
    8000459c:	00000097          	auipc	ra,0x0
    800045a0:	acc080e7          	jalr	-1332(ra) # 80004068 <begin_op>
    iput(ff.ip);
    800045a4:	854e                	mv	a0,s3
    800045a6:	fffff097          	auipc	ra,0xfffff
    800045aa:	2b0080e7          	jalr	688(ra) # 80003856 <iput>
    end_op();
    800045ae:	00000097          	auipc	ra,0x0
    800045b2:	b38080e7          	jalr	-1224(ra) # 800040e6 <end_op>
    800045b6:	a00d                	j	800045d8 <fileclose+0xa8>
    panic("fileclose");
    800045b8:	00004517          	auipc	a0,0x4
    800045bc:	10050513          	addi	a0,a0,256 # 800086b8 <syscalls+0x250>
    800045c0:	ffffc097          	auipc	ra,0xffffc
    800045c4:	f80080e7          	jalr	-128(ra) # 80000540 <panic>
    release(&ftable.lock);
    800045c8:	0001c517          	auipc	a0,0x1c
    800045cc:	6c050513          	addi	a0,a0,1728 # 80020c88 <ftable>
    800045d0:	ffffc097          	auipc	ra,0xffffc
    800045d4:	6ba080e7          	jalr	1722(ra) # 80000c8a <release>
  }
}
    800045d8:	70e2                	ld	ra,56(sp)
    800045da:	7442                	ld	s0,48(sp)
    800045dc:	74a2                	ld	s1,40(sp)
    800045de:	7902                	ld	s2,32(sp)
    800045e0:	69e2                	ld	s3,24(sp)
    800045e2:	6a42                	ld	s4,16(sp)
    800045e4:	6aa2                	ld	s5,8(sp)
    800045e6:	6121                	addi	sp,sp,64
    800045e8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045ea:	85d6                	mv	a1,s5
    800045ec:	8552                	mv	a0,s4
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	34c080e7          	jalr	844(ra) # 8000493a <pipeclose>
    800045f6:	b7cd                	j	800045d8 <fileclose+0xa8>

00000000800045f8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045f8:	715d                	addi	sp,sp,-80
    800045fa:	e486                	sd	ra,72(sp)
    800045fc:	e0a2                	sd	s0,64(sp)
    800045fe:	fc26                	sd	s1,56(sp)
    80004600:	f84a                	sd	s2,48(sp)
    80004602:	f44e                	sd	s3,40(sp)
    80004604:	0880                	addi	s0,sp,80
    80004606:	84aa                	mv	s1,a0
    80004608:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000460a:	ffffd097          	auipc	ra,0xffffd
    8000460e:	3a2080e7          	jalr	930(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004612:	409c                	lw	a5,0(s1)
    80004614:	37f9                	addiw	a5,a5,-2
    80004616:	4705                	li	a4,1
    80004618:	04f76763          	bltu	a4,a5,80004666 <filestat+0x6e>
    8000461c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000461e:	6c88                	ld	a0,24(s1)
    80004620:	fffff097          	auipc	ra,0xfffff
    80004624:	07c080e7          	jalr	124(ra) # 8000369c <ilock>
    stati(f->ip, &st);
    80004628:	fb840593          	addi	a1,s0,-72
    8000462c:	6c88                	ld	a0,24(s1)
    8000462e:	fffff097          	auipc	ra,0xfffff
    80004632:	2f8080e7          	jalr	760(ra) # 80003926 <stati>
    iunlock(f->ip);
    80004636:	6c88                	ld	a0,24(s1)
    80004638:	fffff097          	auipc	ra,0xfffff
    8000463c:	126080e7          	jalr	294(ra) # 8000375e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004640:	46e1                	li	a3,24
    80004642:	fb840613          	addi	a2,s0,-72
    80004646:	85ce                	mv	a1,s3
    80004648:	05093503          	ld	a0,80(s2)
    8000464c:	ffffd097          	auipc	ra,0xffffd
    80004650:	020080e7          	jalr	32(ra) # 8000166c <copyout>
    80004654:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004658:	60a6                	ld	ra,72(sp)
    8000465a:	6406                	ld	s0,64(sp)
    8000465c:	74e2                	ld	s1,56(sp)
    8000465e:	7942                	ld	s2,48(sp)
    80004660:	79a2                	ld	s3,40(sp)
    80004662:	6161                	addi	sp,sp,80
    80004664:	8082                	ret
  return -1;
    80004666:	557d                	li	a0,-1
    80004668:	bfc5                	j	80004658 <filestat+0x60>

000000008000466a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000466a:	7179                	addi	sp,sp,-48
    8000466c:	f406                	sd	ra,40(sp)
    8000466e:	f022                	sd	s0,32(sp)
    80004670:	ec26                	sd	s1,24(sp)
    80004672:	e84a                	sd	s2,16(sp)
    80004674:	e44e                	sd	s3,8(sp)
    80004676:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004678:	00854783          	lbu	a5,8(a0)
    8000467c:	c3d5                	beqz	a5,80004720 <fileread+0xb6>
    8000467e:	84aa                	mv	s1,a0
    80004680:	89ae                	mv	s3,a1
    80004682:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004684:	411c                	lw	a5,0(a0)
    80004686:	4705                	li	a4,1
    80004688:	04e78963          	beq	a5,a4,800046da <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000468c:	470d                	li	a4,3
    8000468e:	04e78d63          	beq	a5,a4,800046e8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004692:	4709                	li	a4,2
    80004694:	06e79e63          	bne	a5,a4,80004710 <fileread+0xa6>
    ilock(f->ip);
    80004698:	6d08                	ld	a0,24(a0)
    8000469a:	fffff097          	auipc	ra,0xfffff
    8000469e:	002080e7          	jalr	2(ra) # 8000369c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046a2:	874a                	mv	a4,s2
    800046a4:	5094                	lw	a3,32(s1)
    800046a6:	864e                	mv	a2,s3
    800046a8:	4585                	li	a1,1
    800046aa:	6c88                	ld	a0,24(s1)
    800046ac:	fffff097          	auipc	ra,0xfffff
    800046b0:	2a4080e7          	jalr	676(ra) # 80003950 <readi>
    800046b4:	892a                	mv	s2,a0
    800046b6:	00a05563          	blez	a0,800046c0 <fileread+0x56>
      f->off += r;
    800046ba:	509c                	lw	a5,32(s1)
    800046bc:	9fa9                	addw	a5,a5,a0
    800046be:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046c0:	6c88                	ld	a0,24(s1)
    800046c2:	fffff097          	auipc	ra,0xfffff
    800046c6:	09c080e7          	jalr	156(ra) # 8000375e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046ca:	854a                	mv	a0,s2
    800046cc:	70a2                	ld	ra,40(sp)
    800046ce:	7402                	ld	s0,32(sp)
    800046d0:	64e2                	ld	s1,24(sp)
    800046d2:	6942                	ld	s2,16(sp)
    800046d4:	69a2                	ld	s3,8(sp)
    800046d6:	6145                	addi	sp,sp,48
    800046d8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046da:	6908                	ld	a0,16(a0)
    800046dc:	00000097          	auipc	ra,0x0
    800046e0:	3c6080e7          	jalr	966(ra) # 80004aa2 <piperead>
    800046e4:	892a                	mv	s2,a0
    800046e6:	b7d5                	j	800046ca <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046e8:	02451783          	lh	a5,36(a0)
    800046ec:	03079693          	slli	a3,a5,0x30
    800046f0:	92c1                	srli	a3,a3,0x30
    800046f2:	4725                	li	a4,9
    800046f4:	02d76863          	bltu	a4,a3,80004724 <fileread+0xba>
    800046f8:	0792                	slli	a5,a5,0x4
    800046fa:	0001c717          	auipc	a4,0x1c
    800046fe:	4ee70713          	addi	a4,a4,1262 # 80020be8 <devsw>
    80004702:	97ba                	add	a5,a5,a4
    80004704:	639c                	ld	a5,0(a5)
    80004706:	c38d                	beqz	a5,80004728 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004708:	4505                	li	a0,1
    8000470a:	9782                	jalr	a5
    8000470c:	892a                	mv	s2,a0
    8000470e:	bf75                	j	800046ca <fileread+0x60>
    panic("fileread");
    80004710:	00004517          	auipc	a0,0x4
    80004714:	fb850513          	addi	a0,a0,-72 # 800086c8 <syscalls+0x260>
    80004718:	ffffc097          	auipc	ra,0xffffc
    8000471c:	e28080e7          	jalr	-472(ra) # 80000540 <panic>
    return -1;
    80004720:	597d                	li	s2,-1
    80004722:	b765                	j	800046ca <fileread+0x60>
      return -1;
    80004724:	597d                	li	s2,-1
    80004726:	b755                	j	800046ca <fileread+0x60>
    80004728:	597d                	li	s2,-1
    8000472a:	b745                	j	800046ca <fileread+0x60>

000000008000472c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000472c:	715d                	addi	sp,sp,-80
    8000472e:	e486                	sd	ra,72(sp)
    80004730:	e0a2                	sd	s0,64(sp)
    80004732:	fc26                	sd	s1,56(sp)
    80004734:	f84a                	sd	s2,48(sp)
    80004736:	f44e                	sd	s3,40(sp)
    80004738:	f052                	sd	s4,32(sp)
    8000473a:	ec56                	sd	s5,24(sp)
    8000473c:	e85a                	sd	s6,16(sp)
    8000473e:	e45e                	sd	s7,8(sp)
    80004740:	e062                	sd	s8,0(sp)
    80004742:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004744:	00954783          	lbu	a5,9(a0)
    80004748:	10078663          	beqz	a5,80004854 <filewrite+0x128>
    8000474c:	892a                	mv	s2,a0
    8000474e:	8b2e                	mv	s6,a1
    80004750:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004752:	411c                	lw	a5,0(a0)
    80004754:	4705                	li	a4,1
    80004756:	02e78263          	beq	a5,a4,8000477a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000475a:	470d                	li	a4,3
    8000475c:	02e78663          	beq	a5,a4,80004788 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004760:	4709                	li	a4,2
    80004762:	0ee79163          	bne	a5,a4,80004844 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004766:	0ac05d63          	blez	a2,80004820 <filewrite+0xf4>
    int i = 0;
    8000476a:	4981                	li	s3,0
    8000476c:	6b85                	lui	s7,0x1
    8000476e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004772:	6c05                	lui	s8,0x1
    80004774:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004778:	a861                	j	80004810 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000477a:	6908                	ld	a0,16(a0)
    8000477c:	00000097          	auipc	ra,0x0
    80004780:	22e080e7          	jalr	558(ra) # 800049aa <pipewrite>
    80004784:	8a2a                	mv	s4,a0
    80004786:	a045                	j	80004826 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004788:	02451783          	lh	a5,36(a0)
    8000478c:	03079693          	slli	a3,a5,0x30
    80004790:	92c1                	srli	a3,a3,0x30
    80004792:	4725                	li	a4,9
    80004794:	0cd76263          	bltu	a4,a3,80004858 <filewrite+0x12c>
    80004798:	0792                	slli	a5,a5,0x4
    8000479a:	0001c717          	auipc	a4,0x1c
    8000479e:	44e70713          	addi	a4,a4,1102 # 80020be8 <devsw>
    800047a2:	97ba                	add	a5,a5,a4
    800047a4:	679c                	ld	a5,8(a5)
    800047a6:	cbdd                	beqz	a5,8000485c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800047a8:	4505                	li	a0,1
    800047aa:	9782                	jalr	a5
    800047ac:	8a2a                	mv	s4,a0
    800047ae:	a8a5                	j	80004826 <filewrite+0xfa>
    800047b0:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800047b4:	00000097          	auipc	ra,0x0
    800047b8:	8b4080e7          	jalr	-1868(ra) # 80004068 <begin_op>
      ilock(f->ip);
    800047bc:	01893503          	ld	a0,24(s2)
    800047c0:	fffff097          	auipc	ra,0xfffff
    800047c4:	edc080e7          	jalr	-292(ra) # 8000369c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047c8:	8756                	mv	a4,s5
    800047ca:	02092683          	lw	a3,32(s2)
    800047ce:	01698633          	add	a2,s3,s6
    800047d2:	4585                	li	a1,1
    800047d4:	01893503          	ld	a0,24(s2)
    800047d8:	fffff097          	auipc	ra,0xfffff
    800047dc:	270080e7          	jalr	624(ra) # 80003a48 <writei>
    800047e0:	84aa                	mv	s1,a0
    800047e2:	00a05763          	blez	a0,800047f0 <filewrite+0xc4>
        f->off += r;
    800047e6:	02092783          	lw	a5,32(s2)
    800047ea:	9fa9                	addw	a5,a5,a0
    800047ec:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047f0:	01893503          	ld	a0,24(s2)
    800047f4:	fffff097          	auipc	ra,0xfffff
    800047f8:	f6a080e7          	jalr	-150(ra) # 8000375e <iunlock>
      end_op();
    800047fc:	00000097          	auipc	ra,0x0
    80004800:	8ea080e7          	jalr	-1814(ra) # 800040e6 <end_op>

      if(r != n1){
    80004804:	009a9f63          	bne	s5,s1,80004822 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004808:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000480c:	0149db63          	bge	s3,s4,80004822 <filewrite+0xf6>
      int n1 = n - i;
    80004810:	413a04bb          	subw	s1,s4,s3
    80004814:	0004879b          	sext.w	a5,s1
    80004818:	f8fbdce3          	bge	s7,a5,800047b0 <filewrite+0x84>
    8000481c:	84e2                	mv	s1,s8
    8000481e:	bf49                	j	800047b0 <filewrite+0x84>
    int i = 0;
    80004820:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004822:	013a1f63          	bne	s4,s3,80004840 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004826:	8552                	mv	a0,s4
    80004828:	60a6                	ld	ra,72(sp)
    8000482a:	6406                	ld	s0,64(sp)
    8000482c:	74e2                	ld	s1,56(sp)
    8000482e:	7942                	ld	s2,48(sp)
    80004830:	79a2                	ld	s3,40(sp)
    80004832:	7a02                	ld	s4,32(sp)
    80004834:	6ae2                	ld	s5,24(sp)
    80004836:	6b42                	ld	s6,16(sp)
    80004838:	6ba2                	ld	s7,8(sp)
    8000483a:	6c02                	ld	s8,0(sp)
    8000483c:	6161                	addi	sp,sp,80
    8000483e:	8082                	ret
    ret = (i == n ? n : -1);
    80004840:	5a7d                	li	s4,-1
    80004842:	b7d5                	j	80004826 <filewrite+0xfa>
    panic("filewrite");
    80004844:	00004517          	auipc	a0,0x4
    80004848:	e9450513          	addi	a0,a0,-364 # 800086d8 <syscalls+0x270>
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	cf4080e7          	jalr	-780(ra) # 80000540 <panic>
    return -1;
    80004854:	5a7d                	li	s4,-1
    80004856:	bfc1                	j	80004826 <filewrite+0xfa>
      return -1;
    80004858:	5a7d                	li	s4,-1
    8000485a:	b7f1                	j	80004826 <filewrite+0xfa>
    8000485c:	5a7d                	li	s4,-1
    8000485e:	b7e1                	j	80004826 <filewrite+0xfa>

0000000080004860 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004860:	7179                	addi	sp,sp,-48
    80004862:	f406                	sd	ra,40(sp)
    80004864:	f022                	sd	s0,32(sp)
    80004866:	ec26                	sd	s1,24(sp)
    80004868:	e84a                	sd	s2,16(sp)
    8000486a:	e44e                	sd	s3,8(sp)
    8000486c:	e052                	sd	s4,0(sp)
    8000486e:	1800                	addi	s0,sp,48
    80004870:	84aa                	mv	s1,a0
    80004872:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004874:	0005b023          	sd	zero,0(a1)
    80004878:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000487c:	00000097          	auipc	ra,0x0
    80004880:	bf8080e7          	jalr	-1032(ra) # 80004474 <filealloc>
    80004884:	e088                	sd	a0,0(s1)
    80004886:	c551                	beqz	a0,80004912 <pipealloc+0xb2>
    80004888:	00000097          	auipc	ra,0x0
    8000488c:	bec080e7          	jalr	-1044(ra) # 80004474 <filealloc>
    80004890:	00aa3023          	sd	a0,0(s4)
    80004894:	c92d                	beqz	a0,80004906 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	250080e7          	jalr	592(ra) # 80000ae6 <kalloc>
    8000489e:	892a                	mv	s2,a0
    800048a0:	c125                	beqz	a0,80004900 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048a2:	4985                	li	s3,1
    800048a4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048a8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048ac:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048b0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048b4:	00004597          	auipc	a1,0x4
    800048b8:	e3458593          	addi	a1,a1,-460 # 800086e8 <syscalls+0x280>
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	28a080e7          	jalr	650(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    800048c4:	609c                	ld	a5,0(s1)
    800048c6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048ca:	609c                	ld	a5,0(s1)
    800048cc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048d0:	609c                	ld	a5,0(s1)
    800048d2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048d6:	609c                	ld	a5,0(s1)
    800048d8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048dc:	000a3783          	ld	a5,0(s4)
    800048e0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048e4:	000a3783          	ld	a5,0(s4)
    800048e8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048ec:	000a3783          	ld	a5,0(s4)
    800048f0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048f4:	000a3783          	ld	a5,0(s4)
    800048f8:	0127b823          	sd	s2,16(a5)
  return 0;
    800048fc:	4501                	li	a0,0
    800048fe:	a025                	j	80004926 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004900:	6088                	ld	a0,0(s1)
    80004902:	e501                	bnez	a0,8000490a <pipealloc+0xaa>
    80004904:	a039                	j	80004912 <pipealloc+0xb2>
    80004906:	6088                	ld	a0,0(s1)
    80004908:	c51d                	beqz	a0,80004936 <pipealloc+0xd6>
    fileclose(*f0);
    8000490a:	00000097          	auipc	ra,0x0
    8000490e:	c26080e7          	jalr	-986(ra) # 80004530 <fileclose>
  if(*f1)
    80004912:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004916:	557d                	li	a0,-1
  if(*f1)
    80004918:	c799                	beqz	a5,80004926 <pipealloc+0xc6>
    fileclose(*f1);
    8000491a:	853e                	mv	a0,a5
    8000491c:	00000097          	auipc	ra,0x0
    80004920:	c14080e7          	jalr	-1004(ra) # 80004530 <fileclose>
  return -1;
    80004924:	557d                	li	a0,-1
}
    80004926:	70a2                	ld	ra,40(sp)
    80004928:	7402                	ld	s0,32(sp)
    8000492a:	64e2                	ld	s1,24(sp)
    8000492c:	6942                	ld	s2,16(sp)
    8000492e:	69a2                	ld	s3,8(sp)
    80004930:	6a02                	ld	s4,0(sp)
    80004932:	6145                	addi	sp,sp,48
    80004934:	8082                	ret
  return -1;
    80004936:	557d                	li	a0,-1
    80004938:	b7fd                	j	80004926 <pipealloc+0xc6>

000000008000493a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000493a:	1101                	addi	sp,sp,-32
    8000493c:	ec06                	sd	ra,24(sp)
    8000493e:	e822                	sd	s0,16(sp)
    80004940:	e426                	sd	s1,8(sp)
    80004942:	e04a                	sd	s2,0(sp)
    80004944:	1000                	addi	s0,sp,32
    80004946:	84aa                	mv	s1,a0
    80004948:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000494a:	ffffc097          	auipc	ra,0xffffc
    8000494e:	28c080e7          	jalr	652(ra) # 80000bd6 <acquire>
  if(writable){
    80004952:	02090d63          	beqz	s2,8000498c <pipeclose+0x52>
    pi->writeopen = 0;
    80004956:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000495a:	21848513          	addi	a0,s1,536
    8000495e:	ffffd097          	auipc	ra,0xffffd
    80004962:	75a080e7          	jalr	1882(ra) # 800020b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004966:	2204b783          	ld	a5,544(s1)
    8000496a:	eb95                	bnez	a5,8000499e <pipeclose+0x64>
    release(&pi->lock);
    8000496c:	8526                	mv	a0,s1
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	31c080e7          	jalr	796(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004976:	8526                	mv	a0,s1
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	070080e7          	jalr	112(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004980:	60e2                	ld	ra,24(sp)
    80004982:	6442                	ld	s0,16(sp)
    80004984:	64a2                	ld	s1,8(sp)
    80004986:	6902                	ld	s2,0(sp)
    80004988:	6105                	addi	sp,sp,32
    8000498a:	8082                	ret
    pi->readopen = 0;
    8000498c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004990:	21c48513          	addi	a0,s1,540
    80004994:	ffffd097          	auipc	ra,0xffffd
    80004998:	724080e7          	jalr	1828(ra) # 800020b8 <wakeup>
    8000499c:	b7e9                	j	80004966 <pipeclose+0x2c>
    release(&pi->lock);
    8000499e:	8526                	mv	a0,s1
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	2ea080e7          	jalr	746(ra) # 80000c8a <release>
}
    800049a8:	bfe1                	j	80004980 <pipeclose+0x46>

00000000800049aa <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049aa:	711d                	addi	sp,sp,-96
    800049ac:	ec86                	sd	ra,88(sp)
    800049ae:	e8a2                	sd	s0,80(sp)
    800049b0:	e4a6                	sd	s1,72(sp)
    800049b2:	e0ca                	sd	s2,64(sp)
    800049b4:	fc4e                	sd	s3,56(sp)
    800049b6:	f852                	sd	s4,48(sp)
    800049b8:	f456                	sd	s5,40(sp)
    800049ba:	f05a                	sd	s6,32(sp)
    800049bc:	ec5e                	sd	s7,24(sp)
    800049be:	e862                	sd	s8,16(sp)
    800049c0:	1080                	addi	s0,sp,96
    800049c2:	84aa                	mv	s1,a0
    800049c4:	8aae                	mv	s5,a1
    800049c6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049c8:	ffffd097          	auipc	ra,0xffffd
    800049cc:	fe4080e7          	jalr	-28(ra) # 800019ac <myproc>
    800049d0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049d2:	8526                	mv	a0,s1
    800049d4:	ffffc097          	auipc	ra,0xffffc
    800049d8:	202080e7          	jalr	514(ra) # 80000bd6 <acquire>
  while(i < n){
    800049dc:	0b405663          	blez	s4,80004a88 <pipewrite+0xde>
  int i = 0;
    800049e0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049e2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800049e4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800049e8:	21c48b93          	addi	s7,s1,540
    800049ec:	a089                	j	80004a2e <pipewrite+0x84>
      release(&pi->lock);
    800049ee:	8526                	mv	a0,s1
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	29a080e7          	jalr	666(ra) # 80000c8a <release>
      return -1;
    800049f8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800049fa:	854a                	mv	a0,s2
    800049fc:	60e6                	ld	ra,88(sp)
    800049fe:	6446                	ld	s0,80(sp)
    80004a00:	64a6                	ld	s1,72(sp)
    80004a02:	6906                	ld	s2,64(sp)
    80004a04:	79e2                	ld	s3,56(sp)
    80004a06:	7a42                	ld	s4,48(sp)
    80004a08:	7aa2                	ld	s5,40(sp)
    80004a0a:	7b02                	ld	s6,32(sp)
    80004a0c:	6be2                	ld	s7,24(sp)
    80004a0e:	6c42                	ld	s8,16(sp)
    80004a10:	6125                	addi	sp,sp,96
    80004a12:	8082                	ret
      wakeup(&pi->nread);
    80004a14:	8562                	mv	a0,s8
    80004a16:	ffffd097          	auipc	ra,0xffffd
    80004a1a:	6a2080e7          	jalr	1698(ra) # 800020b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a1e:	85a6                	mv	a1,s1
    80004a20:	855e                	mv	a0,s7
    80004a22:	ffffd097          	auipc	ra,0xffffd
    80004a26:	632080e7          	jalr	1586(ra) # 80002054 <sleep>
  while(i < n){
    80004a2a:	07495063          	bge	s2,s4,80004a8a <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a2e:	2204a783          	lw	a5,544(s1)
    80004a32:	dfd5                	beqz	a5,800049ee <pipewrite+0x44>
    80004a34:	854e                	mv	a0,s3
    80004a36:	ffffe097          	auipc	ra,0xffffe
    80004a3a:	8c6080e7          	jalr	-1850(ra) # 800022fc <killed>
    80004a3e:	f945                	bnez	a0,800049ee <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a40:	2184a783          	lw	a5,536(s1)
    80004a44:	21c4a703          	lw	a4,540(s1)
    80004a48:	2007879b          	addiw	a5,a5,512
    80004a4c:	fcf704e3          	beq	a4,a5,80004a14 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a50:	4685                	li	a3,1
    80004a52:	01590633          	add	a2,s2,s5
    80004a56:	faf40593          	addi	a1,s0,-81
    80004a5a:	0509b503          	ld	a0,80(s3)
    80004a5e:	ffffd097          	auipc	ra,0xffffd
    80004a62:	c9a080e7          	jalr	-870(ra) # 800016f8 <copyin>
    80004a66:	03650263          	beq	a0,s6,80004a8a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a6a:	21c4a783          	lw	a5,540(s1)
    80004a6e:	0017871b          	addiw	a4,a5,1
    80004a72:	20e4ae23          	sw	a4,540(s1)
    80004a76:	1ff7f793          	andi	a5,a5,511
    80004a7a:	97a6                	add	a5,a5,s1
    80004a7c:	faf44703          	lbu	a4,-81(s0)
    80004a80:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a84:	2905                	addiw	s2,s2,1
    80004a86:	b755                	j	80004a2a <pipewrite+0x80>
  int i = 0;
    80004a88:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a8a:	21848513          	addi	a0,s1,536
    80004a8e:	ffffd097          	auipc	ra,0xffffd
    80004a92:	62a080e7          	jalr	1578(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80004a96:	8526                	mv	a0,s1
    80004a98:	ffffc097          	auipc	ra,0xffffc
    80004a9c:	1f2080e7          	jalr	498(ra) # 80000c8a <release>
  return i;
    80004aa0:	bfa9                	j	800049fa <pipewrite+0x50>

0000000080004aa2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004aa2:	715d                	addi	sp,sp,-80
    80004aa4:	e486                	sd	ra,72(sp)
    80004aa6:	e0a2                	sd	s0,64(sp)
    80004aa8:	fc26                	sd	s1,56(sp)
    80004aaa:	f84a                	sd	s2,48(sp)
    80004aac:	f44e                	sd	s3,40(sp)
    80004aae:	f052                	sd	s4,32(sp)
    80004ab0:	ec56                	sd	s5,24(sp)
    80004ab2:	e85a                	sd	s6,16(sp)
    80004ab4:	0880                	addi	s0,sp,80
    80004ab6:	84aa                	mv	s1,a0
    80004ab8:	892e                	mv	s2,a1
    80004aba:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004abc:	ffffd097          	auipc	ra,0xffffd
    80004ac0:	ef0080e7          	jalr	-272(ra) # 800019ac <myproc>
    80004ac4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	ffffc097          	auipc	ra,0xffffc
    80004acc:	10e080e7          	jalr	270(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ad0:	2184a703          	lw	a4,536(s1)
    80004ad4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ad8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004adc:	02f71763          	bne	a4,a5,80004b0a <piperead+0x68>
    80004ae0:	2244a783          	lw	a5,548(s1)
    80004ae4:	c39d                	beqz	a5,80004b0a <piperead+0x68>
    if(killed(pr)){
    80004ae6:	8552                	mv	a0,s4
    80004ae8:	ffffe097          	auipc	ra,0xffffe
    80004aec:	814080e7          	jalr	-2028(ra) # 800022fc <killed>
    80004af0:	e949                	bnez	a0,80004b82 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004af2:	85a6                	mv	a1,s1
    80004af4:	854e                	mv	a0,s3
    80004af6:	ffffd097          	auipc	ra,0xffffd
    80004afa:	55e080e7          	jalr	1374(ra) # 80002054 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004afe:	2184a703          	lw	a4,536(s1)
    80004b02:	21c4a783          	lw	a5,540(s1)
    80004b06:	fcf70de3          	beq	a4,a5,80004ae0 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b0a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b0c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b0e:	05505463          	blez	s5,80004b56 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b12:	2184a783          	lw	a5,536(s1)
    80004b16:	21c4a703          	lw	a4,540(s1)
    80004b1a:	02f70e63          	beq	a4,a5,80004b56 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b1e:	0017871b          	addiw	a4,a5,1
    80004b22:	20e4ac23          	sw	a4,536(s1)
    80004b26:	1ff7f793          	andi	a5,a5,511
    80004b2a:	97a6                	add	a5,a5,s1
    80004b2c:	0187c783          	lbu	a5,24(a5)
    80004b30:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b34:	4685                	li	a3,1
    80004b36:	fbf40613          	addi	a2,s0,-65
    80004b3a:	85ca                	mv	a1,s2
    80004b3c:	050a3503          	ld	a0,80(s4)
    80004b40:	ffffd097          	auipc	ra,0xffffd
    80004b44:	b2c080e7          	jalr	-1236(ra) # 8000166c <copyout>
    80004b48:	01650763          	beq	a0,s6,80004b56 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b4c:	2985                	addiw	s3,s3,1
    80004b4e:	0905                	addi	s2,s2,1
    80004b50:	fd3a91e3          	bne	s5,s3,80004b12 <piperead+0x70>
    80004b54:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b56:	21c48513          	addi	a0,s1,540
    80004b5a:	ffffd097          	auipc	ra,0xffffd
    80004b5e:	55e080e7          	jalr	1374(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80004b62:	8526                	mv	a0,s1
    80004b64:	ffffc097          	auipc	ra,0xffffc
    80004b68:	126080e7          	jalr	294(ra) # 80000c8a <release>
  return i;
}
    80004b6c:	854e                	mv	a0,s3
    80004b6e:	60a6                	ld	ra,72(sp)
    80004b70:	6406                	ld	s0,64(sp)
    80004b72:	74e2                	ld	s1,56(sp)
    80004b74:	7942                	ld	s2,48(sp)
    80004b76:	79a2                	ld	s3,40(sp)
    80004b78:	7a02                	ld	s4,32(sp)
    80004b7a:	6ae2                	ld	s5,24(sp)
    80004b7c:	6b42                	ld	s6,16(sp)
    80004b7e:	6161                	addi	sp,sp,80
    80004b80:	8082                	ret
      release(&pi->lock);
    80004b82:	8526                	mv	a0,s1
    80004b84:	ffffc097          	auipc	ra,0xffffc
    80004b88:	106080e7          	jalr	262(ra) # 80000c8a <release>
      return -1;
    80004b8c:	59fd                	li	s3,-1
    80004b8e:	bff9                	j	80004b6c <piperead+0xca>

0000000080004b90 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004b90:	1141                	addi	sp,sp,-16
    80004b92:	e422                	sd	s0,8(sp)
    80004b94:	0800                	addi	s0,sp,16
    80004b96:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b98:	8905                	andi	a0,a0,1
    80004b9a:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004b9c:	8b89                	andi	a5,a5,2
    80004b9e:	c399                	beqz	a5,80004ba4 <flags2perm+0x14>
      perm |= PTE_W;
    80004ba0:	00456513          	ori	a0,a0,4
    return perm;
}
    80004ba4:	6422                	ld	s0,8(sp)
    80004ba6:	0141                	addi	sp,sp,16
    80004ba8:	8082                	ret

0000000080004baa <exec>:

int
exec(char *path, char **argv)
{
    80004baa:	de010113          	addi	sp,sp,-544
    80004bae:	20113c23          	sd	ra,536(sp)
    80004bb2:	20813823          	sd	s0,528(sp)
    80004bb6:	20913423          	sd	s1,520(sp)
    80004bba:	21213023          	sd	s2,512(sp)
    80004bbe:	ffce                	sd	s3,504(sp)
    80004bc0:	fbd2                	sd	s4,496(sp)
    80004bc2:	f7d6                	sd	s5,488(sp)
    80004bc4:	f3da                	sd	s6,480(sp)
    80004bc6:	efde                	sd	s7,472(sp)
    80004bc8:	ebe2                	sd	s8,464(sp)
    80004bca:	e7e6                	sd	s9,456(sp)
    80004bcc:	e3ea                	sd	s10,448(sp)
    80004bce:	ff6e                	sd	s11,440(sp)
    80004bd0:	1400                	addi	s0,sp,544
    80004bd2:	892a                	mv	s2,a0
    80004bd4:	dea43423          	sd	a0,-536(s0)
    80004bd8:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bdc:	ffffd097          	auipc	ra,0xffffd
    80004be0:	dd0080e7          	jalr	-560(ra) # 800019ac <myproc>
    80004be4:	84aa                	mv	s1,a0

  begin_op();
    80004be6:	fffff097          	auipc	ra,0xfffff
    80004bea:	482080e7          	jalr	1154(ra) # 80004068 <begin_op>

  if((ip = namei(path)) == 0){
    80004bee:	854a                	mv	a0,s2
    80004bf0:	fffff097          	auipc	ra,0xfffff
    80004bf4:	258080e7          	jalr	600(ra) # 80003e48 <namei>
    80004bf8:	c93d                	beqz	a0,80004c6e <exec+0xc4>
    80004bfa:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bfc:	fffff097          	auipc	ra,0xfffff
    80004c00:	aa0080e7          	jalr	-1376(ra) # 8000369c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c04:	04000713          	li	a4,64
    80004c08:	4681                	li	a3,0
    80004c0a:	e5040613          	addi	a2,s0,-432
    80004c0e:	4581                	li	a1,0
    80004c10:	8556                	mv	a0,s5
    80004c12:	fffff097          	auipc	ra,0xfffff
    80004c16:	d3e080e7          	jalr	-706(ra) # 80003950 <readi>
    80004c1a:	04000793          	li	a5,64
    80004c1e:	00f51a63          	bne	a0,a5,80004c32 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c22:	e5042703          	lw	a4,-432(s0)
    80004c26:	464c47b7          	lui	a5,0x464c4
    80004c2a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c2e:	04f70663          	beq	a4,a5,80004c7a <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c32:	8556                	mv	a0,s5
    80004c34:	fffff097          	auipc	ra,0xfffff
    80004c38:	cca080e7          	jalr	-822(ra) # 800038fe <iunlockput>
    end_op();
    80004c3c:	fffff097          	auipc	ra,0xfffff
    80004c40:	4aa080e7          	jalr	1194(ra) # 800040e6 <end_op>
  }
  return -1;
    80004c44:	557d                	li	a0,-1
}
    80004c46:	21813083          	ld	ra,536(sp)
    80004c4a:	21013403          	ld	s0,528(sp)
    80004c4e:	20813483          	ld	s1,520(sp)
    80004c52:	20013903          	ld	s2,512(sp)
    80004c56:	79fe                	ld	s3,504(sp)
    80004c58:	7a5e                	ld	s4,496(sp)
    80004c5a:	7abe                	ld	s5,488(sp)
    80004c5c:	7b1e                	ld	s6,480(sp)
    80004c5e:	6bfe                	ld	s7,472(sp)
    80004c60:	6c5e                	ld	s8,464(sp)
    80004c62:	6cbe                	ld	s9,456(sp)
    80004c64:	6d1e                	ld	s10,448(sp)
    80004c66:	7dfa                	ld	s11,440(sp)
    80004c68:	22010113          	addi	sp,sp,544
    80004c6c:	8082                	ret
    end_op();
    80004c6e:	fffff097          	auipc	ra,0xfffff
    80004c72:	478080e7          	jalr	1144(ra) # 800040e6 <end_op>
    return -1;
    80004c76:	557d                	li	a0,-1
    80004c78:	b7f9                	j	80004c46 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	ffffd097          	auipc	ra,0xffffd
    80004c80:	df4080e7          	jalr	-524(ra) # 80001a70 <proc_pagetable>
    80004c84:	8b2a                	mv	s6,a0
    80004c86:	d555                	beqz	a0,80004c32 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c88:	e7042783          	lw	a5,-400(s0)
    80004c8c:	e8845703          	lhu	a4,-376(s0)
    80004c90:	c735                	beqz	a4,80004cfc <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c92:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c94:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004c98:	6a05                	lui	s4,0x1
    80004c9a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c9e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004ca2:	6d85                	lui	s11,0x1
    80004ca4:	7d7d                	lui	s10,0xfffff
    80004ca6:	ac3d                	j	80004ee4 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ca8:	00004517          	auipc	a0,0x4
    80004cac:	a4850513          	addi	a0,a0,-1464 # 800086f0 <syscalls+0x288>
    80004cb0:	ffffc097          	auipc	ra,0xffffc
    80004cb4:	890080e7          	jalr	-1904(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cb8:	874a                	mv	a4,s2
    80004cba:	009c86bb          	addw	a3,s9,s1
    80004cbe:	4581                	li	a1,0
    80004cc0:	8556                	mv	a0,s5
    80004cc2:	fffff097          	auipc	ra,0xfffff
    80004cc6:	c8e080e7          	jalr	-882(ra) # 80003950 <readi>
    80004cca:	2501                	sext.w	a0,a0
    80004ccc:	1aa91963          	bne	s2,a0,80004e7e <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004cd0:	009d84bb          	addw	s1,s11,s1
    80004cd4:	013d09bb          	addw	s3,s10,s3
    80004cd8:	1f74f663          	bgeu	s1,s7,80004ec4 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004cdc:	02049593          	slli	a1,s1,0x20
    80004ce0:	9181                	srli	a1,a1,0x20
    80004ce2:	95e2                	add	a1,a1,s8
    80004ce4:	855a                	mv	a0,s6
    80004ce6:	ffffc097          	auipc	ra,0xffffc
    80004cea:	376080e7          	jalr	886(ra) # 8000105c <walkaddr>
    80004cee:	862a                	mv	a2,a0
    if(pa == 0)
    80004cf0:	dd45                	beqz	a0,80004ca8 <exec+0xfe>
      n = PGSIZE;
    80004cf2:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004cf4:	fd49f2e3          	bgeu	s3,s4,80004cb8 <exec+0x10e>
      n = sz - i;
    80004cf8:	894e                	mv	s2,s3
    80004cfa:	bf7d                	j	80004cb8 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cfc:	4901                	li	s2,0
  iunlockput(ip);
    80004cfe:	8556                	mv	a0,s5
    80004d00:	fffff097          	auipc	ra,0xfffff
    80004d04:	bfe080e7          	jalr	-1026(ra) # 800038fe <iunlockput>
  end_op();
    80004d08:	fffff097          	auipc	ra,0xfffff
    80004d0c:	3de080e7          	jalr	990(ra) # 800040e6 <end_op>
  p = myproc();
    80004d10:	ffffd097          	auipc	ra,0xffffd
    80004d14:	c9c080e7          	jalr	-868(ra) # 800019ac <myproc>
    80004d18:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d1a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d1e:	6785                	lui	a5,0x1
    80004d20:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004d22:	97ca                	add	a5,a5,s2
    80004d24:	777d                	lui	a4,0xfffff
    80004d26:	8ff9                	and	a5,a5,a4
    80004d28:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d2c:	4691                	li	a3,4
    80004d2e:	6609                	lui	a2,0x2
    80004d30:	963e                	add	a2,a2,a5
    80004d32:	85be                	mv	a1,a5
    80004d34:	855a                	mv	a0,s6
    80004d36:	ffffc097          	auipc	ra,0xffffc
    80004d3a:	6da080e7          	jalr	1754(ra) # 80001410 <uvmalloc>
    80004d3e:	8c2a                	mv	s8,a0
  ip = 0;
    80004d40:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d42:	12050e63          	beqz	a0,80004e7e <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d46:	75f9                	lui	a1,0xffffe
    80004d48:	95aa                	add	a1,a1,a0
    80004d4a:	855a                	mv	a0,s6
    80004d4c:	ffffd097          	auipc	ra,0xffffd
    80004d50:	8ee080e7          	jalr	-1810(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80004d54:	7afd                	lui	s5,0xfffff
    80004d56:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d58:	df043783          	ld	a5,-528(s0)
    80004d5c:	6388                	ld	a0,0(a5)
    80004d5e:	c925                	beqz	a0,80004dce <exec+0x224>
    80004d60:	e9040993          	addi	s3,s0,-368
    80004d64:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d68:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d6a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d6c:	ffffc097          	auipc	ra,0xffffc
    80004d70:	0e2080e7          	jalr	226(ra) # 80000e4e <strlen>
    80004d74:	0015079b          	addiw	a5,a0,1
    80004d78:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d7c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004d80:	13596663          	bltu	s2,s5,80004eac <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d84:	df043d83          	ld	s11,-528(s0)
    80004d88:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004d8c:	8552                	mv	a0,s4
    80004d8e:	ffffc097          	auipc	ra,0xffffc
    80004d92:	0c0080e7          	jalr	192(ra) # 80000e4e <strlen>
    80004d96:	0015069b          	addiw	a3,a0,1
    80004d9a:	8652                	mv	a2,s4
    80004d9c:	85ca                	mv	a1,s2
    80004d9e:	855a                	mv	a0,s6
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	8cc080e7          	jalr	-1844(ra) # 8000166c <copyout>
    80004da8:	10054663          	bltz	a0,80004eb4 <exec+0x30a>
    ustack[argc] = sp;
    80004dac:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004db0:	0485                	addi	s1,s1,1
    80004db2:	008d8793          	addi	a5,s11,8
    80004db6:	def43823          	sd	a5,-528(s0)
    80004dba:	008db503          	ld	a0,8(s11)
    80004dbe:	c911                	beqz	a0,80004dd2 <exec+0x228>
    if(argc >= MAXARG)
    80004dc0:	09a1                	addi	s3,s3,8
    80004dc2:	fb3c95e3          	bne	s9,s3,80004d6c <exec+0x1c2>
  sz = sz1;
    80004dc6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004dca:	4a81                	li	s5,0
    80004dcc:	a84d                	j	80004e7e <exec+0x2d4>
  sp = sz;
    80004dce:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004dd0:	4481                	li	s1,0
  ustack[argc] = 0;
    80004dd2:	00349793          	slli	a5,s1,0x3
    80004dd6:	f9078793          	addi	a5,a5,-112
    80004dda:	97a2                	add	a5,a5,s0
    80004ddc:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004de0:	00148693          	addi	a3,s1,1
    80004de4:	068e                	slli	a3,a3,0x3
    80004de6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004dea:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004dee:	01597663          	bgeu	s2,s5,80004dfa <exec+0x250>
  sz = sz1;
    80004df2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004df6:	4a81                	li	s5,0
    80004df8:	a059                	j	80004e7e <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004dfa:	e9040613          	addi	a2,s0,-368
    80004dfe:	85ca                	mv	a1,s2
    80004e00:	855a                	mv	a0,s6
    80004e02:	ffffd097          	auipc	ra,0xffffd
    80004e06:	86a080e7          	jalr	-1942(ra) # 8000166c <copyout>
    80004e0a:	0a054963          	bltz	a0,80004ebc <exec+0x312>
  p->trapframe->a1 = sp;
    80004e0e:	058bb783          	ld	a5,88(s7)
    80004e12:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e16:	de843783          	ld	a5,-536(s0)
    80004e1a:	0007c703          	lbu	a4,0(a5)
    80004e1e:	cf11                	beqz	a4,80004e3a <exec+0x290>
    80004e20:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e22:	02f00693          	li	a3,47
    80004e26:	a039                	j	80004e34 <exec+0x28a>
      last = s+1;
    80004e28:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e2c:	0785                	addi	a5,a5,1
    80004e2e:	fff7c703          	lbu	a4,-1(a5)
    80004e32:	c701                	beqz	a4,80004e3a <exec+0x290>
    if(*s == '/')
    80004e34:	fed71ce3          	bne	a4,a3,80004e2c <exec+0x282>
    80004e38:	bfc5                	j	80004e28 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e3a:	4641                	li	a2,16
    80004e3c:	de843583          	ld	a1,-536(s0)
    80004e40:	158b8513          	addi	a0,s7,344
    80004e44:	ffffc097          	auipc	ra,0xffffc
    80004e48:	fd8080e7          	jalr	-40(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e4c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e50:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004e54:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e58:	058bb783          	ld	a5,88(s7)
    80004e5c:	e6843703          	ld	a4,-408(s0)
    80004e60:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e62:	058bb783          	ld	a5,88(s7)
    80004e66:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e6a:	85ea                	mv	a1,s10
    80004e6c:	ffffd097          	auipc	ra,0xffffd
    80004e70:	ca0080e7          	jalr	-864(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e74:	0004851b          	sext.w	a0,s1
    80004e78:	b3f9                	j	80004c46 <exec+0x9c>
    80004e7a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004e7e:	df843583          	ld	a1,-520(s0)
    80004e82:	855a                	mv	a0,s6
    80004e84:	ffffd097          	auipc	ra,0xffffd
    80004e88:	c88080e7          	jalr	-888(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    80004e8c:	da0a93e3          	bnez	s5,80004c32 <exec+0x88>
  return -1;
    80004e90:	557d                	li	a0,-1
    80004e92:	bb55                	j	80004c46 <exec+0x9c>
    80004e94:	df243c23          	sd	s2,-520(s0)
    80004e98:	b7dd                	j	80004e7e <exec+0x2d4>
    80004e9a:	df243c23          	sd	s2,-520(s0)
    80004e9e:	b7c5                	j	80004e7e <exec+0x2d4>
    80004ea0:	df243c23          	sd	s2,-520(s0)
    80004ea4:	bfe9                	j	80004e7e <exec+0x2d4>
    80004ea6:	df243c23          	sd	s2,-520(s0)
    80004eaa:	bfd1                	j	80004e7e <exec+0x2d4>
  sz = sz1;
    80004eac:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eb0:	4a81                	li	s5,0
    80004eb2:	b7f1                	j	80004e7e <exec+0x2d4>
  sz = sz1;
    80004eb4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eb8:	4a81                	li	s5,0
    80004eba:	b7d1                	j	80004e7e <exec+0x2d4>
  sz = sz1;
    80004ebc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ec0:	4a81                	li	s5,0
    80004ec2:	bf75                	j	80004e7e <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ec4:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ec8:	e0843783          	ld	a5,-504(s0)
    80004ecc:	0017869b          	addiw	a3,a5,1
    80004ed0:	e0d43423          	sd	a3,-504(s0)
    80004ed4:	e0043783          	ld	a5,-512(s0)
    80004ed8:	0387879b          	addiw	a5,a5,56
    80004edc:	e8845703          	lhu	a4,-376(s0)
    80004ee0:	e0e6dfe3          	bge	a3,a4,80004cfe <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ee4:	2781                	sext.w	a5,a5
    80004ee6:	e0f43023          	sd	a5,-512(s0)
    80004eea:	03800713          	li	a4,56
    80004eee:	86be                	mv	a3,a5
    80004ef0:	e1840613          	addi	a2,s0,-488
    80004ef4:	4581                	li	a1,0
    80004ef6:	8556                	mv	a0,s5
    80004ef8:	fffff097          	auipc	ra,0xfffff
    80004efc:	a58080e7          	jalr	-1448(ra) # 80003950 <readi>
    80004f00:	03800793          	li	a5,56
    80004f04:	f6f51be3          	bne	a0,a5,80004e7a <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80004f08:	e1842783          	lw	a5,-488(s0)
    80004f0c:	4705                	li	a4,1
    80004f0e:	fae79de3          	bne	a5,a4,80004ec8 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80004f12:	e4043483          	ld	s1,-448(s0)
    80004f16:	e3843783          	ld	a5,-456(s0)
    80004f1a:	f6f4ede3          	bltu	s1,a5,80004e94 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f1e:	e2843783          	ld	a5,-472(s0)
    80004f22:	94be                	add	s1,s1,a5
    80004f24:	f6f4ebe3          	bltu	s1,a5,80004e9a <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80004f28:	de043703          	ld	a4,-544(s0)
    80004f2c:	8ff9                	and	a5,a5,a4
    80004f2e:	fbad                	bnez	a5,80004ea0 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f30:	e1c42503          	lw	a0,-484(s0)
    80004f34:	00000097          	auipc	ra,0x0
    80004f38:	c5c080e7          	jalr	-932(ra) # 80004b90 <flags2perm>
    80004f3c:	86aa                	mv	a3,a0
    80004f3e:	8626                	mv	a2,s1
    80004f40:	85ca                	mv	a1,s2
    80004f42:	855a                	mv	a0,s6
    80004f44:	ffffc097          	auipc	ra,0xffffc
    80004f48:	4cc080e7          	jalr	1228(ra) # 80001410 <uvmalloc>
    80004f4c:	dea43c23          	sd	a0,-520(s0)
    80004f50:	d939                	beqz	a0,80004ea6 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f52:	e2843c03          	ld	s8,-472(s0)
    80004f56:	e2042c83          	lw	s9,-480(s0)
    80004f5a:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f5e:	f60b83e3          	beqz	s7,80004ec4 <exec+0x31a>
    80004f62:	89de                	mv	s3,s7
    80004f64:	4481                	li	s1,0
    80004f66:	bb9d                	j	80004cdc <exec+0x132>

0000000080004f68 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f68:	7179                	addi	sp,sp,-48
    80004f6a:	f406                	sd	ra,40(sp)
    80004f6c:	f022                	sd	s0,32(sp)
    80004f6e:	ec26                	sd	s1,24(sp)
    80004f70:	e84a                	sd	s2,16(sp)
    80004f72:	1800                	addi	s0,sp,48
    80004f74:	892e                	mv	s2,a1
    80004f76:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f78:	fdc40593          	addi	a1,s0,-36
    80004f7c:	ffffe097          	auipc	ra,0xffffe
    80004f80:	bb6080e7          	jalr	-1098(ra) # 80002b32 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f84:	fdc42703          	lw	a4,-36(s0)
    80004f88:	47bd                	li	a5,15
    80004f8a:	02e7eb63          	bltu	a5,a4,80004fc0 <argfd+0x58>
    80004f8e:	ffffd097          	auipc	ra,0xffffd
    80004f92:	a1e080e7          	jalr	-1506(ra) # 800019ac <myproc>
    80004f96:	fdc42703          	lw	a4,-36(s0)
    80004f9a:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd29a>
    80004f9e:	078e                	slli	a5,a5,0x3
    80004fa0:	953e                	add	a0,a0,a5
    80004fa2:	611c                	ld	a5,0(a0)
    80004fa4:	c385                	beqz	a5,80004fc4 <argfd+0x5c>
    return -1;
  if(pfd)
    80004fa6:	00090463          	beqz	s2,80004fae <argfd+0x46>
    *pfd = fd;
    80004faa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fae:	4501                	li	a0,0
  if(pf)
    80004fb0:	c091                	beqz	s1,80004fb4 <argfd+0x4c>
    *pf = f;
    80004fb2:	e09c                	sd	a5,0(s1)
}
    80004fb4:	70a2                	ld	ra,40(sp)
    80004fb6:	7402                	ld	s0,32(sp)
    80004fb8:	64e2                	ld	s1,24(sp)
    80004fba:	6942                	ld	s2,16(sp)
    80004fbc:	6145                	addi	sp,sp,48
    80004fbe:	8082                	ret
    return -1;
    80004fc0:	557d                	li	a0,-1
    80004fc2:	bfcd                	j	80004fb4 <argfd+0x4c>
    80004fc4:	557d                	li	a0,-1
    80004fc6:	b7fd                	j	80004fb4 <argfd+0x4c>

0000000080004fc8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fc8:	1101                	addi	sp,sp,-32
    80004fca:	ec06                	sd	ra,24(sp)
    80004fcc:	e822                	sd	s0,16(sp)
    80004fce:	e426                	sd	s1,8(sp)
    80004fd0:	1000                	addi	s0,sp,32
    80004fd2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fd4:	ffffd097          	auipc	ra,0xffffd
    80004fd8:	9d8080e7          	jalr	-1576(ra) # 800019ac <myproc>
    80004fdc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fde:	0d050793          	addi	a5,a0,208
    80004fe2:	4501                	li	a0,0
    80004fe4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004fe6:	6398                	ld	a4,0(a5)
    80004fe8:	cb19                	beqz	a4,80004ffe <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004fea:	2505                	addiw	a0,a0,1
    80004fec:	07a1                	addi	a5,a5,8
    80004fee:	fed51ce3          	bne	a0,a3,80004fe6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ff2:	557d                	li	a0,-1
}
    80004ff4:	60e2                	ld	ra,24(sp)
    80004ff6:	6442                	ld	s0,16(sp)
    80004ff8:	64a2                	ld	s1,8(sp)
    80004ffa:	6105                	addi	sp,sp,32
    80004ffc:	8082                	ret
      p->ofile[fd] = f;
    80004ffe:	01a50793          	addi	a5,a0,26
    80005002:	078e                	slli	a5,a5,0x3
    80005004:	963e                	add	a2,a2,a5
    80005006:	e204                	sd	s1,0(a2)
      return fd;
    80005008:	b7f5                	j	80004ff4 <fdalloc+0x2c>

000000008000500a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000500a:	715d                	addi	sp,sp,-80
    8000500c:	e486                	sd	ra,72(sp)
    8000500e:	e0a2                	sd	s0,64(sp)
    80005010:	fc26                	sd	s1,56(sp)
    80005012:	f84a                	sd	s2,48(sp)
    80005014:	f44e                	sd	s3,40(sp)
    80005016:	f052                	sd	s4,32(sp)
    80005018:	ec56                	sd	s5,24(sp)
    8000501a:	e85a                	sd	s6,16(sp)
    8000501c:	0880                	addi	s0,sp,80
    8000501e:	8b2e                	mv	s6,a1
    80005020:	89b2                	mv	s3,a2
    80005022:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005024:	fb040593          	addi	a1,s0,-80
    80005028:	fffff097          	auipc	ra,0xfffff
    8000502c:	e3e080e7          	jalr	-450(ra) # 80003e66 <nameiparent>
    80005030:	84aa                	mv	s1,a0
    80005032:	14050f63          	beqz	a0,80005190 <create+0x186>
    return 0;

  ilock(dp);
    80005036:	ffffe097          	auipc	ra,0xffffe
    8000503a:	666080e7          	jalr	1638(ra) # 8000369c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000503e:	4601                	li	a2,0
    80005040:	fb040593          	addi	a1,s0,-80
    80005044:	8526                	mv	a0,s1
    80005046:	fffff097          	auipc	ra,0xfffff
    8000504a:	b3a080e7          	jalr	-1222(ra) # 80003b80 <dirlookup>
    8000504e:	8aaa                	mv	s5,a0
    80005050:	c931                	beqz	a0,800050a4 <create+0x9a>
    iunlockput(dp);
    80005052:	8526                	mv	a0,s1
    80005054:	fffff097          	auipc	ra,0xfffff
    80005058:	8aa080e7          	jalr	-1878(ra) # 800038fe <iunlockput>
    ilock(ip);
    8000505c:	8556                	mv	a0,s5
    8000505e:	ffffe097          	auipc	ra,0xffffe
    80005062:	63e080e7          	jalr	1598(ra) # 8000369c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005066:	000b059b          	sext.w	a1,s6
    8000506a:	4789                	li	a5,2
    8000506c:	02f59563          	bne	a1,a5,80005096 <create+0x8c>
    80005070:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd2c4>
    80005074:	37f9                	addiw	a5,a5,-2
    80005076:	17c2                	slli	a5,a5,0x30
    80005078:	93c1                	srli	a5,a5,0x30
    8000507a:	4705                	li	a4,1
    8000507c:	00f76d63          	bltu	a4,a5,80005096 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005080:	8556                	mv	a0,s5
    80005082:	60a6                	ld	ra,72(sp)
    80005084:	6406                	ld	s0,64(sp)
    80005086:	74e2                	ld	s1,56(sp)
    80005088:	7942                	ld	s2,48(sp)
    8000508a:	79a2                	ld	s3,40(sp)
    8000508c:	7a02                	ld	s4,32(sp)
    8000508e:	6ae2                	ld	s5,24(sp)
    80005090:	6b42                	ld	s6,16(sp)
    80005092:	6161                	addi	sp,sp,80
    80005094:	8082                	ret
    iunlockput(ip);
    80005096:	8556                	mv	a0,s5
    80005098:	fffff097          	auipc	ra,0xfffff
    8000509c:	866080e7          	jalr	-1946(ra) # 800038fe <iunlockput>
    return 0;
    800050a0:	4a81                	li	s5,0
    800050a2:	bff9                	j	80005080 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800050a4:	85da                	mv	a1,s6
    800050a6:	4088                	lw	a0,0(s1)
    800050a8:	ffffe097          	auipc	ra,0xffffe
    800050ac:	456080e7          	jalr	1110(ra) # 800034fe <ialloc>
    800050b0:	8a2a                	mv	s4,a0
    800050b2:	c539                	beqz	a0,80005100 <create+0xf6>
  ilock(ip);
    800050b4:	ffffe097          	auipc	ra,0xffffe
    800050b8:	5e8080e7          	jalr	1512(ra) # 8000369c <ilock>
  ip->major = major;
    800050bc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800050c0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800050c4:	4905                	li	s2,1
    800050c6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800050ca:	8552                	mv	a0,s4
    800050cc:	ffffe097          	auipc	ra,0xffffe
    800050d0:	504080e7          	jalr	1284(ra) # 800035d0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050d4:	000b059b          	sext.w	a1,s6
    800050d8:	03258b63          	beq	a1,s2,8000510e <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800050dc:	004a2603          	lw	a2,4(s4)
    800050e0:	fb040593          	addi	a1,s0,-80
    800050e4:	8526                	mv	a0,s1
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	cb0080e7          	jalr	-848(ra) # 80003d96 <dirlink>
    800050ee:	06054f63          	bltz	a0,8000516c <create+0x162>
  iunlockput(dp);
    800050f2:	8526                	mv	a0,s1
    800050f4:	fffff097          	auipc	ra,0xfffff
    800050f8:	80a080e7          	jalr	-2038(ra) # 800038fe <iunlockput>
  return ip;
    800050fc:	8ad2                	mv	s5,s4
    800050fe:	b749                	j	80005080 <create+0x76>
    iunlockput(dp);
    80005100:	8526                	mv	a0,s1
    80005102:	ffffe097          	auipc	ra,0xffffe
    80005106:	7fc080e7          	jalr	2044(ra) # 800038fe <iunlockput>
    return 0;
    8000510a:	8ad2                	mv	s5,s4
    8000510c:	bf95                	j	80005080 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000510e:	004a2603          	lw	a2,4(s4)
    80005112:	00003597          	auipc	a1,0x3
    80005116:	5fe58593          	addi	a1,a1,1534 # 80008710 <syscalls+0x2a8>
    8000511a:	8552                	mv	a0,s4
    8000511c:	fffff097          	auipc	ra,0xfffff
    80005120:	c7a080e7          	jalr	-902(ra) # 80003d96 <dirlink>
    80005124:	04054463          	bltz	a0,8000516c <create+0x162>
    80005128:	40d0                	lw	a2,4(s1)
    8000512a:	00003597          	auipc	a1,0x3
    8000512e:	5ee58593          	addi	a1,a1,1518 # 80008718 <syscalls+0x2b0>
    80005132:	8552                	mv	a0,s4
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	c62080e7          	jalr	-926(ra) # 80003d96 <dirlink>
    8000513c:	02054863          	bltz	a0,8000516c <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005140:	004a2603          	lw	a2,4(s4)
    80005144:	fb040593          	addi	a1,s0,-80
    80005148:	8526                	mv	a0,s1
    8000514a:	fffff097          	auipc	ra,0xfffff
    8000514e:	c4c080e7          	jalr	-948(ra) # 80003d96 <dirlink>
    80005152:	00054d63          	bltz	a0,8000516c <create+0x162>
    dp->nlink++;  // for ".."
    80005156:	04a4d783          	lhu	a5,74(s1)
    8000515a:	2785                	addiw	a5,a5,1
    8000515c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005160:	8526                	mv	a0,s1
    80005162:	ffffe097          	auipc	ra,0xffffe
    80005166:	46e080e7          	jalr	1134(ra) # 800035d0 <iupdate>
    8000516a:	b761                	j	800050f2 <create+0xe8>
  ip->nlink = 0;
    8000516c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005170:	8552                	mv	a0,s4
    80005172:	ffffe097          	auipc	ra,0xffffe
    80005176:	45e080e7          	jalr	1118(ra) # 800035d0 <iupdate>
  iunlockput(ip);
    8000517a:	8552                	mv	a0,s4
    8000517c:	ffffe097          	auipc	ra,0xffffe
    80005180:	782080e7          	jalr	1922(ra) # 800038fe <iunlockput>
  iunlockput(dp);
    80005184:	8526                	mv	a0,s1
    80005186:	ffffe097          	auipc	ra,0xffffe
    8000518a:	778080e7          	jalr	1912(ra) # 800038fe <iunlockput>
  return 0;
    8000518e:	bdcd                	j	80005080 <create+0x76>
    return 0;
    80005190:	8aaa                	mv	s5,a0
    80005192:	b5fd                	j	80005080 <create+0x76>

0000000080005194 <sys_dup>:
{
    80005194:	7179                	addi	sp,sp,-48
    80005196:	f406                	sd	ra,40(sp)
    80005198:	f022                	sd	s0,32(sp)
    8000519a:	ec26                	sd	s1,24(sp)
    8000519c:	e84a                	sd	s2,16(sp)
    8000519e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051a0:	fd840613          	addi	a2,s0,-40
    800051a4:	4581                	li	a1,0
    800051a6:	4501                	li	a0,0
    800051a8:	00000097          	auipc	ra,0x0
    800051ac:	dc0080e7          	jalr	-576(ra) # 80004f68 <argfd>
    return -1;
    800051b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051b2:	02054363          	bltz	a0,800051d8 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800051b6:	fd843903          	ld	s2,-40(s0)
    800051ba:	854a                	mv	a0,s2
    800051bc:	00000097          	auipc	ra,0x0
    800051c0:	e0c080e7          	jalr	-500(ra) # 80004fc8 <fdalloc>
    800051c4:	84aa                	mv	s1,a0
    return -1;
    800051c6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051c8:	00054863          	bltz	a0,800051d8 <sys_dup+0x44>
  filedup(f);
    800051cc:	854a                	mv	a0,s2
    800051ce:	fffff097          	auipc	ra,0xfffff
    800051d2:	310080e7          	jalr	784(ra) # 800044de <filedup>
  return fd;
    800051d6:	87a6                	mv	a5,s1
}
    800051d8:	853e                	mv	a0,a5
    800051da:	70a2                	ld	ra,40(sp)
    800051dc:	7402                	ld	s0,32(sp)
    800051de:	64e2                	ld	s1,24(sp)
    800051e0:	6942                	ld	s2,16(sp)
    800051e2:	6145                	addi	sp,sp,48
    800051e4:	8082                	ret

00000000800051e6 <sys_read>:
{
    800051e6:	7179                	addi	sp,sp,-48
    800051e8:	f406                	sd	ra,40(sp)
    800051ea:	f022                	sd	s0,32(sp)
    800051ec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051ee:	fd840593          	addi	a1,s0,-40
    800051f2:	4505                	li	a0,1
    800051f4:	ffffe097          	auipc	ra,0xffffe
    800051f8:	95e080e7          	jalr	-1698(ra) # 80002b52 <argaddr>
  argint(2, &n);
    800051fc:	fe440593          	addi	a1,s0,-28
    80005200:	4509                	li	a0,2
    80005202:	ffffe097          	auipc	ra,0xffffe
    80005206:	930080e7          	jalr	-1744(ra) # 80002b32 <argint>
  if(argfd(0, 0, &f) < 0)
    8000520a:	fe840613          	addi	a2,s0,-24
    8000520e:	4581                	li	a1,0
    80005210:	4501                	li	a0,0
    80005212:	00000097          	auipc	ra,0x0
    80005216:	d56080e7          	jalr	-682(ra) # 80004f68 <argfd>
    8000521a:	87aa                	mv	a5,a0
    return -1;
    8000521c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000521e:	0007cc63          	bltz	a5,80005236 <sys_read+0x50>
  return fileread(f, p, n);
    80005222:	fe442603          	lw	a2,-28(s0)
    80005226:	fd843583          	ld	a1,-40(s0)
    8000522a:	fe843503          	ld	a0,-24(s0)
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	43c080e7          	jalr	1084(ra) # 8000466a <fileread>
}
    80005236:	70a2                	ld	ra,40(sp)
    80005238:	7402                	ld	s0,32(sp)
    8000523a:	6145                	addi	sp,sp,48
    8000523c:	8082                	ret

000000008000523e <sys_write>:
{
    8000523e:	7179                	addi	sp,sp,-48
    80005240:	f406                	sd	ra,40(sp)
    80005242:	f022                	sd	s0,32(sp)
    80005244:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005246:	fd840593          	addi	a1,s0,-40
    8000524a:	4505                	li	a0,1
    8000524c:	ffffe097          	auipc	ra,0xffffe
    80005250:	906080e7          	jalr	-1786(ra) # 80002b52 <argaddr>
  argint(2, &n);
    80005254:	fe440593          	addi	a1,s0,-28
    80005258:	4509                	li	a0,2
    8000525a:	ffffe097          	auipc	ra,0xffffe
    8000525e:	8d8080e7          	jalr	-1832(ra) # 80002b32 <argint>
  if(argfd(0, 0, &f) < 0)
    80005262:	fe840613          	addi	a2,s0,-24
    80005266:	4581                	li	a1,0
    80005268:	4501                	li	a0,0
    8000526a:	00000097          	auipc	ra,0x0
    8000526e:	cfe080e7          	jalr	-770(ra) # 80004f68 <argfd>
    80005272:	87aa                	mv	a5,a0
    return -1;
    80005274:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005276:	0007cc63          	bltz	a5,8000528e <sys_write+0x50>
  return filewrite(f, p, n);
    8000527a:	fe442603          	lw	a2,-28(s0)
    8000527e:	fd843583          	ld	a1,-40(s0)
    80005282:	fe843503          	ld	a0,-24(s0)
    80005286:	fffff097          	auipc	ra,0xfffff
    8000528a:	4a6080e7          	jalr	1190(ra) # 8000472c <filewrite>
}
    8000528e:	70a2                	ld	ra,40(sp)
    80005290:	7402                	ld	s0,32(sp)
    80005292:	6145                	addi	sp,sp,48
    80005294:	8082                	ret

0000000080005296 <sys_close>:
{
    80005296:	1101                	addi	sp,sp,-32
    80005298:	ec06                	sd	ra,24(sp)
    8000529a:	e822                	sd	s0,16(sp)
    8000529c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000529e:	fe040613          	addi	a2,s0,-32
    800052a2:	fec40593          	addi	a1,s0,-20
    800052a6:	4501                	li	a0,0
    800052a8:	00000097          	auipc	ra,0x0
    800052ac:	cc0080e7          	jalr	-832(ra) # 80004f68 <argfd>
    return -1;
    800052b0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052b2:	02054463          	bltz	a0,800052da <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052b6:	ffffc097          	auipc	ra,0xffffc
    800052ba:	6f6080e7          	jalr	1782(ra) # 800019ac <myproc>
    800052be:	fec42783          	lw	a5,-20(s0)
    800052c2:	07e9                	addi	a5,a5,26
    800052c4:	078e                	slli	a5,a5,0x3
    800052c6:	953e                	add	a0,a0,a5
    800052c8:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800052cc:	fe043503          	ld	a0,-32(s0)
    800052d0:	fffff097          	auipc	ra,0xfffff
    800052d4:	260080e7          	jalr	608(ra) # 80004530 <fileclose>
  return 0;
    800052d8:	4781                	li	a5,0
}
    800052da:	853e                	mv	a0,a5
    800052dc:	60e2                	ld	ra,24(sp)
    800052de:	6442                	ld	s0,16(sp)
    800052e0:	6105                	addi	sp,sp,32
    800052e2:	8082                	ret

00000000800052e4 <sys_fstat>:
{
    800052e4:	1101                	addi	sp,sp,-32
    800052e6:	ec06                	sd	ra,24(sp)
    800052e8:	e822                	sd	s0,16(sp)
    800052ea:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800052ec:	fe040593          	addi	a1,s0,-32
    800052f0:	4505                	li	a0,1
    800052f2:	ffffe097          	auipc	ra,0xffffe
    800052f6:	860080e7          	jalr	-1952(ra) # 80002b52 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052fa:	fe840613          	addi	a2,s0,-24
    800052fe:	4581                	li	a1,0
    80005300:	4501                	li	a0,0
    80005302:	00000097          	auipc	ra,0x0
    80005306:	c66080e7          	jalr	-922(ra) # 80004f68 <argfd>
    8000530a:	87aa                	mv	a5,a0
    return -1;
    8000530c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000530e:	0007ca63          	bltz	a5,80005322 <sys_fstat+0x3e>
  return filestat(f, st);
    80005312:	fe043583          	ld	a1,-32(s0)
    80005316:	fe843503          	ld	a0,-24(s0)
    8000531a:	fffff097          	auipc	ra,0xfffff
    8000531e:	2de080e7          	jalr	734(ra) # 800045f8 <filestat>
}
    80005322:	60e2                	ld	ra,24(sp)
    80005324:	6442                	ld	s0,16(sp)
    80005326:	6105                	addi	sp,sp,32
    80005328:	8082                	ret

000000008000532a <sys_link>:
{
    8000532a:	7169                	addi	sp,sp,-304
    8000532c:	f606                	sd	ra,296(sp)
    8000532e:	f222                	sd	s0,288(sp)
    80005330:	ee26                	sd	s1,280(sp)
    80005332:	ea4a                	sd	s2,272(sp)
    80005334:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005336:	08000613          	li	a2,128
    8000533a:	ed040593          	addi	a1,s0,-304
    8000533e:	4501                	li	a0,0
    80005340:	ffffe097          	auipc	ra,0xffffe
    80005344:	832080e7          	jalr	-1998(ra) # 80002b72 <argstr>
    return -1;
    80005348:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000534a:	10054e63          	bltz	a0,80005466 <sys_link+0x13c>
    8000534e:	08000613          	li	a2,128
    80005352:	f5040593          	addi	a1,s0,-176
    80005356:	4505                	li	a0,1
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	81a080e7          	jalr	-2022(ra) # 80002b72 <argstr>
    return -1;
    80005360:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005362:	10054263          	bltz	a0,80005466 <sys_link+0x13c>
  begin_op();
    80005366:	fffff097          	auipc	ra,0xfffff
    8000536a:	d02080e7          	jalr	-766(ra) # 80004068 <begin_op>
  if((ip = namei(old)) == 0){
    8000536e:	ed040513          	addi	a0,s0,-304
    80005372:	fffff097          	auipc	ra,0xfffff
    80005376:	ad6080e7          	jalr	-1322(ra) # 80003e48 <namei>
    8000537a:	84aa                	mv	s1,a0
    8000537c:	c551                	beqz	a0,80005408 <sys_link+0xde>
  ilock(ip);
    8000537e:	ffffe097          	auipc	ra,0xffffe
    80005382:	31e080e7          	jalr	798(ra) # 8000369c <ilock>
  if(ip->type == T_DIR){
    80005386:	04449703          	lh	a4,68(s1)
    8000538a:	4785                	li	a5,1
    8000538c:	08f70463          	beq	a4,a5,80005414 <sys_link+0xea>
  ip->nlink++;
    80005390:	04a4d783          	lhu	a5,74(s1)
    80005394:	2785                	addiw	a5,a5,1
    80005396:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000539a:	8526                	mv	a0,s1
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	234080e7          	jalr	564(ra) # 800035d0 <iupdate>
  iunlock(ip);
    800053a4:	8526                	mv	a0,s1
    800053a6:	ffffe097          	auipc	ra,0xffffe
    800053aa:	3b8080e7          	jalr	952(ra) # 8000375e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053ae:	fd040593          	addi	a1,s0,-48
    800053b2:	f5040513          	addi	a0,s0,-176
    800053b6:	fffff097          	auipc	ra,0xfffff
    800053ba:	ab0080e7          	jalr	-1360(ra) # 80003e66 <nameiparent>
    800053be:	892a                	mv	s2,a0
    800053c0:	c935                	beqz	a0,80005434 <sys_link+0x10a>
  ilock(dp);
    800053c2:	ffffe097          	auipc	ra,0xffffe
    800053c6:	2da080e7          	jalr	730(ra) # 8000369c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053ca:	00092703          	lw	a4,0(s2)
    800053ce:	409c                	lw	a5,0(s1)
    800053d0:	04f71d63          	bne	a4,a5,8000542a <sys_link+0x100>
    800053d4:	40d0                	lw	a2,4(s1)
    800053d6:	fd040593          	addi	a1,s0,-48
    800053da:	854a                	mv	a0,s2
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	9ba080e7          	jalr	-1606(ra) # 80003d96 <dirlink>
    800053e4:	04054363          	bltz	a0,8000542a <sys_link+0x100>
  iunlockput(dp);
    800053e8:	854a                	mv	a0,s2
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	514080e7          	jalr	1300(ra) # 800038fe <iunlockput>
  iput(ip);
    800053f2:	8526                	mv	a0,s1
    800053f4:	ffffe097          	auipc	ra,0xffffe
    800053f8:	462080e7          	jalr	1122(ra) # 80003856 <iput>
  end_op();
    800053fc:	fffff097          	auipc	ra,0xfffff
    80005400:	cea080e7          	jalr	-790(ra) # 800040e6 <end_op>
  return 0;
    80005404:	4781                	li	a5,0
    80005406:	a085                	j	80005466 <sys_link+0x13c>
    end_op();
    80005408:	fffff097          	auipc	ra,0xfffff
    8000540c:	cde080e7          	jalr	-802(ra) # 800040e6 <end_op>
    return -1;
    80005410:	57fd                	li	a5,-1
    80005412:	a891                	j	80005466 <sys_link+0x13c>
    iunlockput(ip);
    80005414:	8526                	mv	a0,s1
    80005416:	ffffe097          	auipc	ra,0xffffe
    8000541a:	4e8080e7          	jalr	1256(ra) # 800038fe <iunlockput>
    end_op();
    8000541e:	fffff097          	auipc	ra,0xfffff
    80005422:	cc8080e7          	jalr	-824(ra) # 800040e6 <end_op>
    return -1;
    80005426:	57fd                	li	a5,-1
    80005428:	a83d                	j	80005466 <sys_link+0x13c>
    iunlockput(dp);
    8000542a:	854a                	mv	a0,s2
    8000542c:	ffffe097          	auipc	ra,0xffffe
    80005430:	4d2080e7          	jalr	1234(ra) # 800038fe <iunlockput>
  ilock(ip);
    80005434:	8526                	mv	a0,s1
    80005436:	ffffe097          	auipc	ra,0xffffe
    8000543a:	266080e7          	jalr	614(ra) # 8000369c <ilock>
  ip->nlink--;
    8000543e:	04a4d783          	lhu	a5,74(s1)
    80005442:	37fd                	addiw	a5,a5,-1
    80005444:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005448:	8526                	mv	a0,s1
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	186080e7          	jalr	390(ra) # 800035d0 <iupdate>
  iunlockput(ip);
    80005452:	8526                	mv	a0,s1
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	4aa080e7          	jalr	1194(ra) # 800038fe <iunlockput>
  end_op();
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	c8a080e7          	jalr	-886(ra) # 800040e6 <end_op>
  return -1;
    80005464:	57fd                	li	a5,-1
}
    80005466:	853e                	mv	a0,a5
    80005468:	70b2                	ld	ra,296(sp)
    8000546a:	7412                	ld	s0,288(sp)
    8000546c:	64f2                	ld	s1,280(sp)
    8000546e:	6952                	ld	s2,272(sp)
    80005470:	6155                	addi	sp,sp,304
    80005472:	8082                	ret

0000000080005474 <sys_unlink>:
{
    80005474:	7151                	addi	sp,sp,-240
    80005476:	f586                	sd	ra,232(sp)
    80005478:	f1a2                	sd	s0,224(sp)
    8000547a:	eda6                	sd	s1,216(sp)
    8000547c:	e9ca                	sd	s2,208(sp)
    8000547e:	e5ce                	sd	s3,200(sp)
    80005480:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005482:	08000613          	li	a2,128
    80005486:	f3040593          	addi	a1,s0,-208
    8000548a:	4501                	li	a0,0
    8000548c:	ffffd097          	auipc	ra,0xffffd
    80005490:	6e6080e7          	jalr	1766(ra) # 80002b72 <argstr>
    80005494:	18054163          	bltz	a0,80005616 <sys_unlink+0x1a2>
  begin_op();
    80005498:	fffff097          	auipc	ra,0xfffff
    8000549c:	bd0080e7          	jalr	-1072(ra) # 80004068 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054a0:	fb040593          	addi	a1,s0,-80
    800054a4:	f3040513          	addi	a0,s0,-208
    800054a8:	fffff097          	auipc	ra,0xfffff
    800054ac:	9be080e7          	jalr	-1602(ra) # 80003e66 <nameiparent>
    800054b0:	84aa                	mv	s1,a0
    800054b2:	c979                	beqz	a0,80005588 <sys_unlink+0x114>
  ilock(dp);
    800054b4:	ffffe097          	auipc	ra,0xffffe
    800054b8:	1e8080e7          	jalr	488(ra) # 8000369c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054bc:	00003597          	auipc	a1,0x3
    800054c0:	25458593          	addi	a1,a1,596 # 80008710 <syscalls+0x2a8>
    800054c4:	fb040513          	addi	a0,s0,-80
    800054c8:	ffffe097          	auipc	ra,0xffffe
    800054cc:	69e080e7          	jalr	1694(ra) # 80003b66 <namecmp>
    800054d0:	14050a63          	beqz	a0,80005624 <sys_unlink+0x1b0>
    800054d4:	00003597          	auipc	a1,0x3
    800054d8:	24458593          	addi	a1,a1,580 # 80008718 <syscalls+0x2b0>
    800054dc:	fb040513          	addi	a0,s0,-80
    800054e0:	ffffe097          	auipc	ra,0xffffe
    800054e4:	686080e7          	jalr	1670(ra) # 80003b66 <namecmp>
    800054e8:	12050e63          	beqz	a0,80005624 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800054ec:	f2c40613          	addi	a2,s0,-212
    800054f0:	fb040593          	addi	a1,s0,-80
    800054f4:	8526                	mv	a0,s1
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	68a080e7          	jalr	1674(ra) # 80003b80 <dirlookup>
    800054fe:	892a                	mv	s2,a0
    80005500:	12050263          	beqz	a0,80005624 <sys_unlink+0x1b0>
  ilock(ip);
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	198080e7          	jalr	408(ra) # 8000369c <ilock>
  if(ip->nlink < 1)
    8000550c:	04a91783          	lh	a5,74(s2)
    80005510:	08f05263          	blez	a5,80005594 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005514:	04491703          	lh	a4,68(s2)
    80005518:	4785                	li	a5,1
    8000551a:	08f70563          	beq	a4,a5,800055a4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000551e:	4641                	li	a2,16
    80005520:	4581                	li	a1,0
    80005522:	fc040513          	addi	a0,s0,-64
    80005526:	ffffb097          	auipc	ra,0xffffb
    8000552a:	7ac080e7          	jalr	1964(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000552e:	4741                	li	a4,16
    80005530:	f2c42683          	lw	a3,-212(s0)
    80005534:	fc040613          	addi	a2,s0,-64
    80005538:	4581                	li	a1,0
    8000553a:	8526                	mv	a0,s1
    8000553c:	ffffe097          	auipc	ra,0xffffe
    80005540:	50c080e7          	jalr	1292(ra) # 80003a48 <writei>
    80005544:	47c1                	li	a5,16
    80005546:	0af51563          	bne	a0,a5,800055f0 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000554a:	04491703          	lh	a4,68(s2)
    8000554e:	4785                	li	a5,1
    80005550:	0af70863          	beq	a4,a5,80005600 <sys_unlink+0x18c>
  iunlockput(dp);
    80005554:	8526                	mv	a0,s1
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	3a8080e7          	jalr	936(ra) # 800038fe <iunlockput>
  ip->nlink--;
    8000555e:	04a95783          	lhu	a5,74(s2)
    80005562:	37fd                	addiw	a5,a5,-1
    80005564:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005568:	854a                	mv	a0,s2
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	066080e7          	jalr	102(ra) # 800035d0 <iupdate>
  iunlockput(ip);
    80005572:	854a                	mv	a0,s2
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	38a080e7          	jalr	906(ra) # 800038fe <iunlockput>
  end_op();
    8000557c:	fffff097          	auipc	ra,0xfffff
    80005580:	b6a080e7          	jalr	-1174(ra) # 800040e6 <end_op>
  return 0;
    80005584:	4501                	li	a0,0
    80005586:	a84d                	j	80005638 <sys_unlink+0x1c4>
    end_op();
    80005588:	fffff097          	auipc	ra,0xfffff
    8000558c:	b5e080e7          	jalr	-1186(ra) # 800040e6 <end_op>
    return -1;
    80005590:	557d                	li	a0,-1
    80005592:	a05d                	j	80005638 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005594:	00003517          	auipc	a0,0x3
    80005598:	18c50513          	addi	a0,a0,396 # 80008720 <syscalls+0x2b8>
    8000559c:	ffffb097          	auipc	ra,0xffffb
    800055a0:	fa4080e7          	jalr	-92(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055a4:	04c92703          	lw	a4,76(s2)
    800055a8:	02000793          	li	a5,32
    800055ac:	f6e7f9e3          	bgeu	a5,a4,8000551e <sys_unlink+0xaa>
    800055b0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055b4:	4741                	li	a4,16
    800055b6:	86ce                	mv	a3,s3
    800055b8:	f1840613          	addi	a2,s0,-232
    800055bc:	4581                	li	a1,0
    800055be:	854a                	mv	a0,s2
    800055c0:	ffffe097          	auipc	ra,0xffffe
    800055c4:	390080e7          	jalr	912(ra) # 80003950 <readi>
    800055c8:	47c1                	li	a5,16
    800055ca:	00f51b63          	bne	a0,a5,800055e0 <sys_unlink+0x16c>
    if(de.inum != 0)
    800055ce:	f1845783          	lhu	a5,-232(s0)
    800055d2:	e7a1                	bnez	a5,8000561a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055d4:	29c1                	addiw	s3,s3,16
    800055d6:	04c92783          	lw	a5,76(s2)
    800055da:	fcf9ede3          	bltu	s3,a5,800055b4 <sys_unlink+0x140>
    800055de:	b781                	j	8000551e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800055e0:	00003517          	auipc	a0,0x3
    800055e4:	15850513          	addi	a0,a0,344 # 80008738 <syscalls+0x2d0>
    800055e8:	ffffb097          	auipc	ra,0xffffb
    800055ec:	f58080e7          	jalr	-168(ra) # 80000540 <panic>
    panic("unlink: writei");
    800055f0:	00003517          	auipc	a0,0x3
    800055f4:	16050513          	addi	a0,a0,352 # 80008750 <syscalls+0x2e8>
    800055f8:	ffffb097          	auipc	ra,0xffffb
    800055fc:	f48080e7          	jalr	-184(ra) # 80000540 <panic>
    dp->nlink--;
    80005600:	04a4d783          	lhu	a5,74(s1)
    80005604:	37fd                	addiw	a5,a5,-1
    80005606:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000560a:	8526                	mv	a0,s1
    8000560c:	ffffe097          	auipc	ra,0xffffe
    80005610:	fc4080e7          	jalr	-60(ra) # 800035d0 <iupdate>
    80005614:	b781                	j	80005554 <sys_unlink+0xe0>
    return -1;
    80005616:	557d                	li	a0,-1
    80005618:	a005                	j	80005638 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000561a:	854a                	mv	a0,s2
    8000561c:	ffffe097          	auipc	ra,0xffffe
    80005620:	2e2080e7          	jalr	738(ra) # 800038fe <iunlockput>
  iunlockput(dp);
    80005624:	8526                	mv	a0,s1
    80005626:	ffffe097          	auipc	ra,0xffffe
    8000562a:	2d8080e7          	jalr	728(ra) # 800038fe <iunlockput>
  end_op();
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	ab8080e7          	jalr	-1352(ra) # 800040e6 <end_op>
  return -1;
    80005636:	557d                	li	a0,-1
}
    80005638:	70ae                	ld	ra,232(sp)
    8000563a:	740e                	ld	s0,224(sp)
    8000563c:	64ee                	ld	s1,216(sp)
    8000563e:	694e                	ld	s2,208(sp)
    80005640:	69ae                	ld	s3,200(sp)
    80005642:	616d                	addi	sp,sp,240
    80005644:	8082                	ret

0000000080005646 <sys_open>:

uint64
sys_open(void)
{
    80005646:	7131                	addi	sp,sp,-192
    80005648:	fd06                	sd	ra,184(sp)
    8000564a:	f922                	sd	s0,176(sp)
    8000564c:	f526                	sd	s1,168(sp)
    8000564e:	f14a                	sd	s2,160(sp)
    80005650:	ed4e                	sd	s3,152(sp)
    80005652:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005654:	f4c40593          	addi	a1,s0,-180
    80005658:	4505                	li	a0,1
    8000565a:	ffffd097          	auipc	ra,0xffffd
    8000565e:	4d8080e7          	jalr	1240(ra) # 80002b32 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005662:	08000613          	li	a2,128
    80005666:	f5040593          	addi	a1,s0,-176
    8000566a:	4501                	li	a0,0
    8000566c:	ffffd097          	auipc	ra,0xffffd
    80005670:	506080e7          	jalr	1286(ra) # 80002b72 <argstr>
    80005674:	87aa                	mv	a5,a0
    return -1;
    80005676:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005678:	0a07c963          	bltz	a5,8000572a <sys_open+0xe4>

  begin_op();
    8000567c:	fffff097          	auipc	ra,0xfffff
    80005680:	9ec080e7          	jalr	-1556(ra) # 80004068 <begin_op>

  if(omode & O_CREATE){
    80005684:	f4c42783          	lw	a5,-180(s0)
    80005688:	2007f793          	andi	a5,a5,512
    8000568c:	cfc5                	beqz	a5,80005744 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000568e:	4681                	li	a3,0
    80005690:	4601                	li	a2,0
    80005692:	4589                	li	a1,2
    80005694:	f5040513          	addi	a0,s0,-176
    80005698:	00000097          	auipc	ra,0x0
    8000569c:	972080e7          	jalr	-1678(ra) # 8000500a <create>
    800056a0:	84aa                	mv	s1,a0
    if(ip == 0){
    800056a2:	c959                	beqz	a0,80005738 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056a4:	04449703          	lh	a4,68(s1)
    800056a8:	478d                	li	a5,3
    800056aa:	00f71763          	bne	a4,a5,800056b8 <sys_open+0x72>
    800056ae:	0464d703          	lhu	a4,70(s1)
    800056b2:	47a5                	li	a5,9
    800056b4:	0ce7ed63          	bltu	a5,a4,8000578e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	dbc080e7          	jalr	-580(ra) # 80004474 <filealloc>
    800056c0:	89aa                	mv	s3,a0
    800056c2:	10050363          	beqz	a0,800057c8 <sys_open+0x182>
    800056c6:	00000097          	auipc	ra,0x0
    800056ca:	902080e7          	jalr	-1790(ra) # 80004fc8 <fdalloc>
    800056ce:	892a                	mv	s2,a0
    800056d0:	0e054763          	bltz	a0,800057be <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056d4:	04449703          	lh	a4,68(s1)
    800056d8:	478d                	li	a5,3
    800056da:	0cf70563          	beq	a4,a5,800057a4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056de:	4789                	li	a5,2
    800056e0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800056e4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800056e8:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800056ec:	f4c42783          	lw	a5,-180(s0)
    800056f0:	0017c713          	xori	a4,a5,1
    800056f4:	8b05                	andi	a4,a4,1
    800056f6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800056fa:	0037f713          	andi	a4,a5,3
    800056fe:	00e03733          	snez	a4,a4
    80005702:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005706:	4007f793          	andi	a5,a5,1024
    8000570a:	c791                	beqz	a5,80005716 <sys_open+0xd0>
    8000570c:	04449703          	lh	a4,68(s1)
    80005710:	4789                	li	a5,2
    80005712:	0af70063          	beq	a4,a5,800057b2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005716:	8526                	mv	a0,s1
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	046080e7          	jalr	70(ra) # 8000375e <iunlock>
  end_op();
    80005720:	fffff097          	auipc	ra,0xfffff
    80005724:	9c6080e7          	jalr	-1594(ra) # 800040e6 <end_op>

  return fd;
    80005728:	854a                	mv	a0,s2
}
    8000572a:	70ea                	ld	ra,184(sp)
    8000572c:	744a                	ld	s0,176(sp)
    8000572e:	74aa                	ld	s1,168(sp)
    80005730:	790a                	ld	s2,160(sp)
    80005732:	69ea                	ld	s3,152(sp)
    80005734:	6129                	addi	sp,sp,192
    80005736:	8082                	ret
      end_op();
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	9ae080e7          	jalr	-1618(ra) # 800040e6 <end_op>
      return -1;
    80005740:	557d                	li	a0,-1
    80005742:	b7e5                	j	8000572a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005744:	f5040513          	addi	a0,s0,-176
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	700080e7          	jalr	1792(ra) # 80003e48 <namei>
    80005750:	84aa                	mv	s1,a0
    80005752:	c905                	beqz	a0,80005782 <sys_open+0x13c>
    ilock(ip);
    80005754:	ffffe097          	auipc	ra,0xffffe
    80005758:	f48080e7          	jalr	-184(ra) # 8000369c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000575c:	04449703          	lh	a4,68(s1)
    80005760:	4785                	li	a5,1
    80005762:	f4f711e3          	bne	a4,a5,800056a4 <sys_open+0x5e>
    80005766:	f4c42783          	lw	a5,-180(s0)
    8000576a:	d7b9                	beqz	a5,800056b8 <sys_open+0x72>
      iunlockput(ip);
    8000576c:	8526                	mv	a0,s1
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	190080e7          	jalr	400(ra) # 800038fe <iunlockput>
      end_op();
    80005776:	fffff097          	auipc	ra,0xfffff
    8000577a:	970080e7          	jalr	-1680(ra) # 800040e6 <end_op>
      return -1;
    8000577e:	557d                	li	a0,-1
    80005780:	b76d                	j	8000572a <sys_open+0xe4>
      end_op();
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	964080e7          	jalr	-1692(ra) # 800040e6 <end_op>
      return -1;
    8000578a:	557d                	li	a0,-1
    8000578c:	bf79                	j	8000572a <sys_open+0xe4>
    iunlockput(ip);
    8000578e:	8526                	mv	a0,s1
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	16e080e7          	jalr	366(ra) # 800038fe <iunlockput>
    end_op();
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	94e080e7          	jalr	-1714(ra) # 800040e6 <end_op>
    return -1;
    800057a0:	557d                	li	a0,-1
    800057a2:	b761                	j	8000572a <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057a4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057a8:	04649783          	lh	a5,70(s1)
    800057ac:	02f99223          	sh	a5,36(s3)
    800057b0:	bf25                	j	800056e8 <sys_open+0xa2>
    itrunc(ip);
    800057b2:	8526                	mv	a0,s1
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	ff6080e7          	jalr	-10(ra) # 800037aa <itrunc>
    800057bc:	bfa9                	j	80005716 <sys_open+0xd0>
      fileclose(f);
    800057be:	854e                	mv	a0,s3
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	d70080e7          	jalr	-656(ra) # 80004530 <fileclose>
    iunlockput(ip);
    800057c8:	8526                	mv	a0,s1
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	134080e7          	jalr	308(ra) # 800038fe <iunlockput>
    end_op();
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	914080e7          	jalr	-1772(ra) # 800040e6 <end_op>
    return -1;
    800057da:	557d                	li	a0,-1
    800057dc:	b7b9                	j	8000572a <sys_open+0xe4>

00000000800057de <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057de:	7175                	addi	sp,sp,-144
    800057e0:	e506                	sd	ra,136(sp)
    800057e2:	e122                	sd	s0,128(sp)
    800057e4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	882080e7          	jalr	-1918(ra) # 80004068 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057ee:	08000613          	li	a2,128
    800057f2:	f7040593          	addi	a1,s0,-144
    800057f6:	4501                	li	a0,0
    800057f8:	ffffd097          	auipc	ra,0xffffd
    800057fc:	37a080e7          	jalr	890(ra) # 80002b72 <argstr>
    80005800:	02054963          	bltz	a0,80005832 <sys_mkdir+0x54>
    80005804:	4681                	li	a3,0
    80005806:	4601                	li	a2,0
    80005808:	4585                	li	a1,1
    8000580a:	f7040513          	addi	a0,s0,-144
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	7fc080e7          	jalr	2044(ra) # 8000500a <create>
    80005816:	cd11                	beqz	a0,80005832 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005818:	ffffe097          	auipc	ra,0xffffe
    8000581c:	0e6080e7          	jalr	230(ra) # 800038fe <iunlockput>
  end_op();
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	8c6080e7          	jalr	-1850(ra) # 800040e6 <end_op>
  return 0;
    80005828:	4501                	li	a0,0
}
    8000582a:	60aa                	ld	ra,136(sp)
    8000582c:	640a                	ld	s0,128(sp)
    8000582e:	6149                	addi	sp,sp,144
    80005830:	8082                	ret
    end_op();
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	8b4080e7          	jalr	-1868(ra) # 800040e6 <end_op>
    return -1;
    8000583a:	557d                	li	a0,-1
    8000583c:	b7fd                	j	8000582a <sys_mkdir+0x4c>

000000008000583e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000583e:	7135                	addi	sp,sp,-160
    80005840:	ed06                	sd	ra,152(sp)
    80005842:	e922                	sd	s0,144(sp)
    80005844:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	822080e7          	jalr	-2014(ra) # 80004068 <begin_op>
  argint(1, &major);
    8000584e:	f6c40593          	addi	a1,s0,-148
    80005852:	4505                	li	a0,1
    80005854:	ffffd097          	auipc	ra,0xffffd
    80005858:	2de080e7          	jalr	734(ra) # 80002b32 <argint>
  argint(2, &minor);
    8000585c:	f6840593          	addi	a1,s0,-152
    80005860:	4509                	li	a0,2
    80005862:	ffffd097          	auipc	ra,0xffffd
    80005866:	2d0080e7          	jalr	720(ra) # 80002b32 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000586a:	08000613          	li	a2,128
    8000586e:	f7040593          	addi	a1,s0,-144
    80005872:	4501                	li	a0,0
    80005874:	ffffd097          	auipc	ra,0xffffd
    80005878:	2fe080e7          	jalr	766(ra) # 80002b72 <argstr>
    8000587c:	02054b63          	bltz	a0,800058b2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005880:	f6841683          	lh	a3,-152(s0)
    80005884:	f6c41603          	lh	a2,-148(s0)
    80005888:	458d                	li	a1,3
    8000588a:	f7040513          	addi	a0,s0,-144
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	77c080e7          	jalr	1916(ra) # 8000500a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005896:	cd11                	beqz	a0,800058b2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	066080e7          	jalr	102(ra) # 800038fe <iunlockput>
  end_op();
    800058a0:	fffff097          	auipc	ra,0xfffff
    800058a4:	846080e7          	jalr	-1978(ra) # 800040e6 <end_op>
  return 0;
    800058a8:	4501                	li	a0,0
}
    800058aa:	60ea                	ld	ra,152(sp)
    800058ac:	644a                	ld	s0,144(sp)
    800058ae:	610d                	addi	sp,sp,160
    800058b0:	8082                	ret
    end_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	834080e7          	jalr	-1996(ra) # 800040e6 <end_op>
    return -1;
    800058ba:	557d                	li	a0,-1
    800058bc:	b7fd                	j	800058aa <sys_mknod+0x6c>

00000000800058be <sys_chdir>:

uint64
sys_chdir(void)
{
    800058be:	7135                	addi	sp,sp,-160
    800058c0:	ed06                	sd	ra,152(sp)
    800058c2:	e922                	sd	s0,144(sp)
    800058c4:	e526                	sd	s1,136(sp)
    800058c6:	e14a                	sd	s2,128(sp)
    800058c8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058ca:	ffffc097          	auipc	ra,0xffffc
    800058ce:	0e2080e7          	jalr	226(ra) # 800019ac <myproc>
    800058d2:	892a                	mv	s2,a0
  
  begin_op();
    800058d4:	ffffe097          	auipc	ra,0xffffe
    800058d8:	794080e7          	jalr	1940(ra) # 80004068 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800058dc:	08000613          	li	a2,128
    800058e0:	f6040593          	addi	a1,s0,-160
    800058e4:	4501                	li	a0,0
    800058e6:	ffffd097          	auipc	ra,0xffffd
    800058ea:	28c080e7          	jalr	652(ra) # 80002b72 <argstr>
    800058ee:	04054b63          	bltz	a0,80005944 <sys_chdir+0x86>
    800058f2:	f6040513          	addi	a0,s0,-160
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	552080e7          	jalr	1362(ra) # 80003e48 <namei>
    800058fe:	84aa                	mv	s1,a0
    80005900:	c131                	beqz	a0,80005944 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	d9a080e7          	jalr	-614(ra) # 8000369c <ilock>
  if(ip->type != T_DIR){
    8000590a:	04449703          	lh	a4,68(s1)
    8000590e:	4785                	li	a5,1
    80005910:	04f71063          	bne	a4,a5,80005950 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005914:	8526                	mv	a0,s1
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	e48080e7          	jalr	-440(ra) # 8000375e <iunlock>
  iput(p->cwd);
    8000591e:	15093503          	ld	a0,336(s2)
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	f34080e7          	jalr	-204(ra) # 80003856 <iput>
  end_op();
    8000592a:	ffffe097          	auipc	ra,0xffffe
    8000592e:	7bc080e7          	jalr	1980(ra) # 800040e6 <end_op>
  p->cwd = ip;
    80005932:	14993823          	sd	s1,336(s2)
  return 0;
    80005936:	4501                	li	a0,0
}
    80005938:	60ea                	ld	ra,152(sp)
    8000593a:	644a                	ld	s0,144(sp)
    8000593c:	64aa                	ld	s1,136(sp)
    8000593e:	690a                	ld	s2,128(sp)
    80005940:	610d                	addi	sp,sp,160
    80005942:	8082                	ret
    end_op();
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	7a2080e7          	jalr	1954(ra) # 800040e6 <end_op>
    return -1;
    8000594c:	557d                	li	a0,-1
    8000594e:	b7ed                	j	80005938 <sys_chdir+0x7a>
    iunlockput(ip);
    80005950:	8526                	mv	a0,s1
    80005952:	ffffe097          	auipc	ra,0xffffe
    80005956:	fac080e7          	jalr	-84(ra) # 800038fe <iunlockput>
    end_op();
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	78c080e7          	jalr	1932(ra) # 800040e6 <end_op>
    return -1;
    80005962:	557d                	li	a0,-1
    80005964:	bfd1                	j	80005938 <sys_chdir+0x7a>

0000000080005966 <sys_exec>:

uint64
sys_exec(void)
{
    80005966:	7145                	addi	sp,sp,-464
    80005968:	e786                	sd	ra,456(sp)
    8000596a:	e3a2                	sd	s0,448(sp)
    8000596c:	ff26                	sd	s1,440(sp)
    8000596e:	fb4a                	sd	s2,432(sp)
    80005970:	f74e                	sd	s3,424(sp)
    80005972:	f352                	sd	s4,416(sp)
    80005974:	ef56                	sd	s5,408(sp)
    80005976:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005978:	e3840593          	addi	a1,s0,-456
    8000597c:	4505                	li	a0,1
    8000597e:	ffffd097          	auipc	ra,0xffffd
    80005982:	1d4080e7          	jalr	468(ra) # 80002b52 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005986:	08000613          	li	a2,128
    8000598a:	f4040593          	addi	a1,s0,-192
    8000598e:	4501                	li	a0,0
    80005990:	ffffd097          	auipc	ra,0xffffd
    80005994:	1e2080e7          	jalr	482(ra) # 80002b72 <argstr>
    80005998:	87aa                	mv	a5,a0
    return -1;
    8000599a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000599c:	0c07c363          	bltz	a5,80005a62 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800059a0:	10000613          	li	a2,256
    800059a4:	4581                	li	a1,0
    800059a6:	e4040513          	addi	a0,s0,-448
    800059aa:	ffffb097          	auipc	ra,0xffffb
    800059ae:	328080e7          	jalr	808(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059b2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800059b6:	89a6                	mv	s3,s1
    800059b8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800059ba:	02000a13          	li	s4,32
    800059be:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059c2:	00391513          	slli	a0,s2,0x3
    800059c6:	e3040593          	addi	a1,s0,-464
    800059ca:	e3843783          	ld	a5,-456(s0)
    800059ce:	953e                	add	a0,a0,a5
    800059d0:	ffffd097          	auipc	ra,0xffffd
    800059d4:	0c4080e7          	jalr	196(ra) # 80002a94 <fetchaddr>
    800059d8:	02054a63          	bltz	a0,80005a0c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800059dc:	e3043783          	ld	a5,-464(s0)
    800059e0:	c3b9                	beqz	a5,80005a26 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800059e2:	ffffb097          	auipc	ra,0xffffb
    800059e6:	104080e7          	jalr	260(ra) # 80000ae6 <kalloc>
    800059ea:	85aa                	mv	a1,a0
    800059ec:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800059f0:	cd11                	beqz	a0,80005a0c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800059f2:	6605                	lui	a2,0x1
    800059f4:	e3043503          	ld	a0,-464(s0)
    800059f8:	ffffd097          	auipc	ra,0xffffd
    800059fc:	0ee080e7          	jalr	238(ra) # 80002ae6 <fetchstr>
    80005a00:	00054663          	bltz	a0,80005a0c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005a04:	0905                	addi	s2,s2,1
    80005a06:	09a1                	addi	s3,s3,8
    80005a08:	fb491be3          	bne	s2,s4,800059be <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a0c:	f4040913          	addi	s2,s0,-192
    80005a10:	6088                	ld	a0,0(s1)
    80005a12:	c539                	beqz	a0,80005a60 <sys_exec+0xfa>
    kfree(argv[i]);
    80005a14:	ffffb097          	auipc	ra,0xffffb
    80005a18:	fd4080e7          	jalr	-44(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a1c:	04a1                	addi	s1,s1,8
    80005a1e:	ff2499e3          	bne	s1,s2,80005a10 <sys_exec+0xaa>
  return -1;
    80005a22:	557d                	li	a0,-1
    80005a24:	a83d                	j	80005a62 <sys_exec+0xfc>
      argv[i] = 0;
    80005a26:	0a8e                	slli	s5,s5,0x3
    80005a28:	fc0a8793          	addi	a5,s5,-64
    80005a2c:	00878ab3          	add	s5,a5,s0
    80005a30:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a34:	e4040593          	addi	a1,s0,-448
    80005a38:	f4040513          	addi	a0,s0,-192
    80005a3c:	fffff097          	auipc	ra,0xfffff
    80005a40:	16e080e7          	jalr	366(ra) # 80004baa <exec>
    80005a44:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a46:	f4040993          	addi	s3,s0,-192
    80005a4a:	6088                	ld	a0,0(s1)
    80005a4c:	c901                	beqz	a0,80005a5c <sys_exec+0xf6>
    kfree(argv[i]);
    80005a4e:	ffffb097          	auipc	ra,0xffffb
    80005a52:	f9a080e7          	jalr	-102(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a56:	04a1                	addi	s1,s1,8
    80005a58:	ff3499e3          	bne	s1,s3,80005a4a <sys_exec+0xe4>
  return ret;
    80005a5c:	854a                	mv	a0,s2
    80005a5e:	a011                	j	80005a62 <sys_exec+0xfc>
  return -1;
    80005a60:	557d                	li	a0,-1
}
    80005a62:	60be                	ld	ra,456(sp)
    80005a64:	641e                	ld	s0,448(sp)
    80005a66:	74fa                	ld	s1,440(sp)
    80005a68:	795a                	ld	s2,432(sp)
    80005a6a:	79ba                	ld	s3,424(sp)
    80005a6c:	7a1a                	ld	s4,416(sp)
    80005a6e:	6afa                	ld	s5,408(sp)
    80005a70:	6179                	addi	sp,sp,464
    80005a72:	8082                	ret

0000000080005a74 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a74:	7139                	addi	sp,sp,-64
    80005a76:	fc06                	sd	ra,56(sp)
    80005a78:	f822                	sd	s0,48(sp)
    80005a7a:	f426                	sd	s1,40(sp)
    80005a7c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a7e:	ffffc097          	auipc	ra,0xffffc
    80005a82:	f2e080e7          	jalr	-210(ra) # 800019ac <myproc>
    80005a86:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a88:	fd840593          	addi	a1,s0,-40
    80005a8c:	4501                	li	a0,0
    80005a8e:	ffffd097          	auipc	ra,0xffffd
    80005a92:	0c4080e7          	jalr	196(ra) # 80002b52 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005a96:	fc840593          	addi	a1,s0,-56
    80005a9a:	fd040513          	addi	a0,s0,-48
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	dc2080e7          	jalr	-574(ra) # 80004860 <pipealloc>
    return -1;
    80005aa6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005aa8:	0c054463          	bltz	a0,80005b70 <sys_pipe+0xfc>
  fd0 = -1;
    80005aac:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ab0:	fd043503          	ld	a0,-48(s0)
    80005ab4:	fffff097          	auipc	ra,0xfffff
    80005ab8:	514080e7          	jalr	1300(ra) # 80004fc8 <fdalloc>
    80005abc:	fca42223          	sw	a0,-60(s0)
    80005ac0:	08054b63          	bltz	a0,80005b56 <sys_pipe+0xe2>
    80005ac4:	fc843503          	ld	a0,-56(s0)
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	500080e7          	jalr	1280(ra) # 80004fc8 <fdalloc>
    80005ad0:	fca42023          	sw	a0,-64(s0)
    80005ad4:	06054863          	bltz	a0,80005b44 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ad8:	4691                	li	a3,4
    80005ada:	fc440613          	addi	a2,s0,-60
    80005ade:	fd843583          	ld	a1,-40(s0)
    80005ae2:	68a8                	ld	a0,80(s1)
    80005ae4:	ffffc097          	auipc	ra,0xffffc
    80005ae8:	b88080e7          	jalr	-1144(ra) # 8000166c <copyout>
    80005aec:	02054063          	bltz	a0,80005b0c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005af0:	4691                	li	a3,4
    80005af2:	fc040613          	addi	a2,s0,-64
    80005af6:	fd843583          	ld	a1,-40(s0)
    80005afa:	0591                	addi	a1,a1,4
    80005afc:	68a8                	ld	a0,80(s1)
    80005afe:	ffffc097          	auipc	ra,0xffffc
    80005b02:	b6e080e7          	jalr	-1170(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b06:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b08:	06055463          	bgez	a0,80005b70 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b0c:	fc442783          	lw	a5,-60(s0)
    80005b10:	07e9                	addi	a5,a5,26
    80005b12:	078e                	slli	a5,a5,0x3
    80005b14:	97a6                	add	a5,a5,s1
    80005b16:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b1a:	fc042783          	lw	a5,-64(s0)
    80005b1e:	07e9                	addi	a5,a5,26
    80005b20:	078e                	slli	a5,a5,0x3
    80005b22:	94be                	add	s1,s1,a5
    80005b24:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b28:	fd043503          	ld	a0,-48(s0)
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	a04080e7          	jalr	-1532(ra) # 80004530 <fileclose>
    fileclose(wf);
    80005b34:	fc843503          	ld	a0,-56(s0)
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	9f8080e7          	jalr	-1544(ra) # 80004530 <fileclose>
    return -1;
    80005b40:	57fd                	li	a5,-1
    80005b42:	a03d                	j	80005b70 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005b44:	fc442783          	lw	a5,-60(s0)
    80005b48:	0007c763          	bltz	a5,80005b56 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005b4c:	07e9                	addi	a5,a5,26
    80005b4e:	078e                	slli	a5,a5,0x3
    80005b50:	97a6                	add	a5,a5,s1
    80005b52:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005b56:	fd043503          	ld	a0,-48(s0)
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	9d6080e7          	jalr	-1578(ra) # 80004530 <fileclose>
    fileclose(wf);
    80005b62:	fc843503          	ld	a0,-56(s0)
    80005b66:	fffff097          	auipc	ra,0xfffff
    80005b6a:	9ca080e7          	jalr	-1590(ra) # 80004530 <fileclose>
    return -1;
    80005b6e:	57fd                	li	a5,-1
}
    80005b70:	853e                	mv	a0,a5
    80005b72:	70e2                	ld	ra,56(sp)
    80005b74:	7442                	ld	s0,48(sp)
    80005b76:	74a2                	ld	s1,40(sp)
    80005b78:	6121                	addi	sp,sp,64
    80005b7a:	8082                	ret
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
    80005bc0:	da1fc0ef          	jal	ra,80002960 <kerneltrap>
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
    80005d3c:	a2850513          	addi	a0,a0,-1496 # 80008760 <syscalls+0x2f8>
    80005d40:	ffffb097          	auipc	ra,0xffffb
    80005d44:	800080e7          	jalr	-2048(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005d48:	00003517          	auipc	a0,0x3
    80005d4c:	a2850513          	addi	a0,a0,-1496 # 80008770 <syscalls+0x308>
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
    80005d68:	a1c58593          	addi	a1,a1,-1508 # 80008780 <syscalls+0x318>
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
    80005ee6:	8ae50513          	addi	a0,a0,-1874 # 80008790 <syscalls+0x328>
    80005eea:	ffffa097          	auipc	ra,0xffffa
    80005eee:	656080e7          	jalr	1622(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ef2:	00003517          	auipc	a0,0x3
    80005ef6:	8be50513          	addi	a0,a0,-1858 # 800087b0 <syscalls+0x348>
    80005efa:	ffffa097          	auipc	ra,0xffffa
    80005efe:	646080e7          	jalr	1606(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80005f02:	00003517          	auipc	a0,0x3
    80005f06:	8ce50513          	addi	a0,a0,-1842 # 800087d0 <syscalls+0x368>
    80005f0a:	ffffa097          	auipc	ra,0xffffa
    80005f0e:	636080e7          	jalr	1590(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80005f12:	00003517          	auipc	a0,0x3
    80005f16:	8de50513          	addi	a0,a0,-1826 # 800087f0 <syscalls+0x388>
    80005f1a:	ffffa097          	auipc	ra,0xffffa
    80005f1e:	626080e7          	jalr	1574(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80005f22:	00003517          	auipc	a0,0x3
    80005f26:	8ee50513          	addi	a0,a0,-1810 # 80008810 <syscalls+0x3a8>
    80005f2a:	ffffa097          	auipc	ra,0xffffa
    80005f2e:	616080e7          	jalr	1558(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80005f32:	00003517          	auipc	a0,0x3
    80005f36:	8fe50513          	addi	a0,a0,-1794 # 80008830 <syscalls+0x3c8>
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
    8000621c:	63050513          	addi	a0,a0,1584 # 80008848 <syscalls+0x3e0>
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
