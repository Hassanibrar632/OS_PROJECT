
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(){
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
   6:	3e800613          	li	a2,1000
   a:	3e800693          	li	a3,1000
   e:	85b6                	mv	a1,a3
  10:	8736                	mv	a4,a3
  12:	87b6                	mv	a5,a3
	for(int i=0; i<1000; i++)
		for(int j=0; j<1000; j++)
			for(int k=0; k<1000; k++)
				for(int l=0; l<1000; l++)
  14:	37fd                	addiw	a5,a5,-1
  16:	fffd                	bnez	a5,14 <main+0x14>
			for(int k=0; k<1000; k++)
  18:	377d                	addiw	a4,a4,-1
  1a:	ff65                	bnez	a4,12 <main+0x12>
		for(int j=0; j<1000; j++)
  1c:	35fd                	addiw	a1,a1,-1
  1e:	f9ed                	bnez	a1,10 <main+0x10>
	for(int i=0; i<1000; i++)
  20:	367d                	addiw	a2,a2,-1
  22:	f675                	bnez	a2,e <main+0xe>
					continue;
	return 0;
}
  24:	4501                	li	a0,0
  26:	6422                	ld	s0,8(sp)
  28:	0141                	addi	sp,sp,16
  2a:	8082                	ret

000000000000002c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  2c:	1141                	addi	sp,sp,-16
  2e:	e406                	sd	ra,8(sp)
  30:	e022                	sd	s0,0(sp)
  32:	0800                	addi	s0,sp,16
  extern int main();
  main();
  34:	00000097          	auipc	ra,0x0
  38:	fcc080e7          	jalr	-52(ra) # 0 <main>
  exit(0);
  3c:	4501                	li	a0,0
  3e:	00000097          	auipc	ra,0x0
  42:	274080e7          	jalr	628(ra) # 2b2 <exit>

0000000000000046 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4c:	87aa                	mv	a5,a0
  4e:	0585                	addi	a1,a1,1
  50:	0785                	addi	a5,a5,1
  52:	fff5c703          	lbu	a4,-1(a1)
  56:	fee78fa3          	sb	a4,-1(a5)
  5a:	fb75                	bnez	a4,4e <strcpy+0x8>
    ;
  return os;
}
  5c:	6422                	ld	s0,8(sp)
  5e:	0141                	addi	sp,sp,16
  60:	8082                	ret

0000000000000062 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  62:	1141                	addi	sp,sp,-16
  64:	e422                	sd	s0,8(sp)
  66:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  68:	00054783          	lbu	a5,0(a0)
  6c:	cb91                	beqz	a5,80 <strcmp+0x1e>
  6e:	0005c703          	lbu	a4,0(a1)
  72:	00f71763          	bne	a4,a5,80 <strcmp+0x1e>
    p++, q++;
  76:	0505                	addi	a0,a0,1
  78:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	fbe5                	bnez	a5,6e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  80:	0005c503          	lbu	a0,0(a1)
}
  84:	40a7853b          	subw	a0,a5,a0
  88:	6422                	ld	s0,8(sp)
  8a:	0141                	addi	sp,sp,16
  8c:	8082                	ret

000000000000008e <strlen>:

uint
strlen(const char *s)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e422                	sd	s0,8(sp)
  92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  94:	00054783          	lbu	a5,0(a0)
  98:	cf91                	beqz	a5,b4 <strlen+0x26>
  9a:	0505                	addi	a0,a0,1
  9c:	87aa                	mv	a5,a0
  9e:	4685                	li	a3,1
  a0:	9e89                	subw	a3,a3,a0
  a2:	00f6853b          	addw	a0,a3,a5
  a6:	0785                	addi	a5,a5,1
  a8:	fff7c703          	lbu	a4,-1(a5)
  ac:	fb7d                	bnez	a4,a2 <strlen+0x14>
    ;
  return n;
}
  ae:	6422                	ld	s0,8(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret
  for(n = 0; s[n]; n++)
  b4:	4501                	li	a0,0
  b6:	bfe5                	j	ae <strlen+0x20>

00000000000000b8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e422                	sd	s0,8(sp)
  bc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  be:	ca19                	beqz	a2,d4 <memset+0x1c>
  c0:	87aa                	mv	a5,a0
  c2:	1602                	slli	a2,a2,0x20
  c4:	9201                	srli	a2,a2,0x20
  c6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ce:	0785                	addi	a5,a5,1
  d0:	fee79de3          	bne	a5,a4,ca <memset+0x12>
  }
  return dst;
}
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret

00000000000000da <strchr>:

char*
strchr(const char *s, char c)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	cb99                	beqz	a5,fa <strchr+0x20>
    if(*s == c)
  e6:	00f58763          	beq	a1,a5,f4 <strchr+0x1a>
  for(; *s; s++)
  ea:	0505                	addi	a0,a0,1
  ec:	00054783          	lbu	a5,0(a0)
  f0:	fbfd                	bnez	a5,e6 <strchr+0xc>
      return (char*)s;
  return 0;
  f2:	4501                	li	a0,0
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret
  return 0;
  fa:	4501                	li	a0,0
  fc:	bfe5                	j	f4 <strchr+0x1a>

00000000000000fe <gets>:

char*
gets(char *buf, int max)
{
  fe:	711d                	addi	sp,sp,-96
 100:	ec86                	sd	ra,88(sp)
 102:	e8a2                	sd	s0,80(sp)
 104:	e4a6                	sd	s1,72(sp)
 106:	e0ca                	sd	s2,64(sp)
 108:	fc4e                	sd	s3,56(sp)
 10a:	f852                	sd	s4,48(sp)
 10c:	f456                	sd	s5,40(sp)
 10e:	f05a                	sd	s6,32(sp)
 110:	ec5e                	sd	s7,24(sp)
 112:	1080                	addi	s0,sp,96
 114:	8baa                	mv	s7,a0
 116:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 118:	892a                	mv	s2,a0
 11a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11c:	4aa9                	li	s5,10
 11e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 120:	89a6                	mv	s3,s1
 122:	2485                	addiw	s1,s1,1
 124:	0344d863          	bge	s1,s4,154 <gets+0x56>
    cc = read(0, &c, 1);
 128:	4605                	li	a2,1
 12a:	faf40593          	addi	a1,s0,-81
 12e:	4501                	li	a0,0
 130:	00000097          	auipc	ra,0x0
 134:	19a080e7          	jalr	410(ra) # 2ca <read>
    if(cc < 1)
 138:	00a05e63          	blez	a0,154 <gets+0x56>
    buf[i++] = c;
 13c:	faf44783          	lbu	a5,-81(s0)
 140:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 144:	01578763          	beq	a5,s5,152 <gets+0x54>
 148:	0905                	addi	s2,s2,1
 14a:	fd679be3          	bne	a5,s6,120 <gets+0x22>
  for(i=0; i+1 < max; ){
 14e:	89a6                	mv	s3,s1
 150:	a011                	j	154 <gets+0x56>
 152:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 154:	99de                	add	s3,s3,s7
 156:	00098023          	sb	zero,0(s3)
  return buf;
}
 15a:	855e                	mv	a0,s7
 15c:	60e6                	ld	ra,88(sp)
 15e:	6446                	ld	s0,80(sp)
 160:	64a6                	ld	s1,72(sp)
 162:	6906                	ld	s2,64(sp)
 164:	79e2                	ld	s3,56(sp)
 166:	7a42                	ld	s4,48(sp)
 168:	7aa2                	ld	s5,40(sp)
 16a:	7b02                	ld	s6,32(sp)
 16c:	6be2                	ld	s7,24(sp)
 16e:	6125                	addi	sp,sp,96
 170:	8082                	ret

0000000000000172 <stat>:

int
stat(const char *n, struct stat *st)
{
 172:	1101                	addi	sp,sp,-32
 174:	ec06                	sd	ra,24(sp)
 176:	e822                	sd	s0,16(sp)
 178:	e426                	sd	s1,8(sp)
 17a:	e04a                	sd	s2,0(sp)
 17c:	1000                	addi	s0,sp,32
 17e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 180:	4581                	li	a1,0
 182:	00000097          	auipc	ra,0x0
 186:	170080e7          	jalr	368(ra) # 2f2 <open>
  if(fd < 0)
 18a:	02054563          	bltz	a0,1b4 <stat+0x42>
 18e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 190:	85ca                	mv	a1,s2
 192:	00000097          	auipc	ra,0x0
 196:	178080e7          	jalr	376(ra) # 30a <fstat>
 19a:	892a                	mv	s2,a0
  close(fd);
 19c:	8526                	mv	a0,s1
 19e:	00000097          	auipc	ra,0x0
 1a2:	13c080e7          	jalr	316(ra) # 2da <close>
  return r;
}
 1a6:	854a                	mv	a0,s2
 1a8:	60e2                	ld	ra,24(sp)
 1aa:	6442                	ld	s0,16(sp)
 1ac:	64a2                	ld	s1,8(sp)
 1ae:	6902                	ld	s2,0(sp)
 1b0:	6105                	addi	sp,sp,32
 1b2:	8082                	ret
    return -1;
 1b4:	597d                	li	s2,-1
 1b6:	bfc5                	j	1a6 <stat+0x34>

00000000000001b8 <atoi>:

int
atoi(const char *s)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e422                	sd	s0,8(sp)
 1bc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1be:	00054683          	lbu	a3,0(a0)
 1c2:	fd06879b          	addiw	a5,a3,-48
 1c6:	0ff7f793          	zext.b	a5,a5
 1ca:	4625                	li	a2,9
 1cc:	02f66863          	bltu	a2,a5,1fc <atoi+0x44>
 1d0:	872a                	mv	a4,a0
  n = 0;
 1d2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1d4:	0705                	addi	a4,a4,1
 1d6:	0025179b          	slliw	a5,a0,0x2
 1da:	9fa9                	addw	a5,a5,a0
 1dc:	0017979b          	slliw	a5,a5,0x1
 1e0:	9fb5                	addw	a5,a5,a3
 1e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e6:	00074683          	lbu	a3,0(a4)
 1ea:	fd06879b          	addiw	a5,a3,-48
 1ee:	0ff7f793          	zext.b	a5,a5
 1f2:	fef671e3          	bgeu	a2,a5,1d4 <atoi+0x1c>
  return n;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  n = 0;
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <atoi+0x3e>

0000000000000200 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 206:	02b57463          	bgeu	a0,a1,22e <memmove+0x2e>
    while(n-- > 0)
 20a:	00c05f63          	blez	a2,228 <memmove+0x28>
 20e:	1602                	slli	a2,a2,0x20
 210:	9201                	srli	a2,a2,0x20
 212:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 216:	872a                	mv	a4,a0
      *dst++ = *src++;
 218:	0585                	addi	a1,a1,1
 21a:	0705                	addi	a4,a4,1
 21c:	fff5c683          	lbu	a3,-1(a1)
 220:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 224:	fee79ae3          	bne	a5,a4,218 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
    dst += n;
 22e:	00c50733          	add	a4,a0,a2
    src += n;
 232:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 234:	fec05ae3          	blez	a2,228 <memmove+0x28>
 238:	fff6079b          	addiw	a5,a2,-1
 23c:	1782                	slli	a5,a5,0x20
 23e:	9381                	srli	a5,a5,0x20
 240:	fff7c793          	not	a5,a5
 244:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 246:	15fd                	addi	a1,a1,-1
 248:	177d                	addi	a4,a4,-1
 24a:	0005c683          	lbu	a3,0(a1)
 24e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 252:	fee79ae3          	bne	a5,a4,246 <memmove+0x46>
 256:	bfc9                	j	228 <memmove+0x28>

0000000000000258 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 25e:	ca05                	beqz	a2,28e <memcmp+0x36>
 260:	fff6069b          	addiw	a3,a2,-1
 264:	1682                	slli	a3,a3,0x20
 266:	9281                	srli	a3,a3,0x20
 268:	0685                	addi	a3,a3,1
 26a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 26c:	00054783          	lbu	a5,0(a0)
 270:	0005c703          	lbu	a4,0(a1)
 274:	00e79863          	bne	a5,a4,284 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 278:	0505                	addi	a0,a0,1
    p2++;
 27a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 27c:	fed518e3          	bne	a0,a3,26c <memcmp+0x14>
  }
  return 0;
 280:	4501                	li	a0,0
 282:	a019                	j	288 <memcmp+0x30>
      return *p1 - *p2;
 284:	40e7853b          	subw	a0,a5,a4
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  return 0;
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <memcmp+0x30>

0000000000000292 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 292:	1141                	addi	sp,sp,-16
 294:	e406                	sd	ra,8(sp)
 296:	e022                	sd	s0,0(sp)
 298:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 29a:	00000097          	auipc	ra,0x0
 29e:	f66080e7          	jalr	-154(ra) # 200 <memmove>
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2aa:	4885                	li	a7,1
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b2:	4889                	li	a7,2
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ba:	488d                	li	a7,3
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c2:	4891                	li	a7,4
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <read>:
.global read
read:
 li a7, SYS_read
 2ca:	4895                	li	a7,5
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <write>:
.global write
write:
 li a7, SYS_write
 2d2:	48c1                	li	a7,16
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <close>:
.global close
close:
 li a7, SYS_close
 2da:	48d5                	li	a7,21
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e2:	4899                	li	a7,6
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ea:	489d                	li	a7,7
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <open>:
.global open
open:
 li a7, SYS_open
 2f2:	48bd                	li	a7,15
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2fa:	48c5                	li	a7,17
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 302:	48c9                	li	a7,18
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 30a:	48a1                	li	a7,8
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <link>:
.global link
link:
 li a7, SYS_link
 312:	48cd                	li	a7,19
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 31a:	48d1                	li	a7,20
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 322:	48a5                	li	a7,9
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <dup>:
.global dup
dup:
 li a7, SYS_dup
 32a:	48a9                	li	a7,10
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 332:	48ad                	li	a7,11
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 33a:	48b1                	li	a7,12
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 342:	48b5                	li	a7,13
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 34a:	48b9                	li	a7,14
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <ps>:
.global ps
ps:
 li a7, SYS_ps
 352:	48d9                	li	a7,22
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 35a:	1101                	addi	sp,sp,-32
 35c:	ec06                	sd	ra,24(sp)
 35e:	e822                	sd	s0,16(sp)
 360:	1000                	addi	s0,sp,32
 362:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 366:	4605                	li	a2,1
 368:	fef40593          	addi	a1,s0,-17
 36c:	00000097          	auipc	ra,0x0
 370:	f66080e7          	jalr	-154(ra) # 2d2 <write>
}
 374:	60e2                	ld	ra,24(sp)
 376:	6442                	ld	s0,16(sp)
 378:	6105                	addi	sp,sp,32
 37a:	8082                	ret

000000000000037c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 37c:	7139                	addi	sp,sp,-64
 37e:	fc06                	sd	ra,56(sp)
 380:	f822                	sd	s0,48(sp)
 382:	f426                	sd	s1,40(sp)
 384:	f04a                	sd	s2,32(sp)
 386:	ec4e                	sd	s3,24(sp)
 388:	0080                	addi	s0,sp,64
 38a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 38c:	c299                	beqz	a3,392 <printint+0x16>
 38e:	0805c963          	bltz	a1,420 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 392:	2581                	sext.w	a1,a1
  neg = 0;
 394:	4881                	li	a7,0
 396:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 39a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 39c:	2601                	sext.w	a2,a2
 39e:	00000517          	auipc	a0,0x0
 3a2:	4a250513          	addi	a0,a0,1186 # 840 <digits>
 3a6:	883a                	mv	a6,a4
 3a8:	2705                	addiw	a4,a4,1
 3aa:	02c5f7bb          	remuw	a5,a1,a2
 3ae:	1782                	slli	a5,a5,0x20
 3b0:	9381                	srli	a5,a5,0x20
 3b2:	97aa                	add	a5,a5,a0
 3b4:	0007c783          	lbu	a5,0(a5)
 3b8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3bc:	0005879b          	sext.w	a5,a1
 3c0:	02c5d5bb          	divuw	a1,a1,a2
 3c4:	0685                	addi	a3,a3,1
 3c6:	fec7f0e3          	bgeu	a5,a2,3a6 <printint+0x2a>
  if(neg)
 3ca:	00088c63          	beqz	a7,3e2 <printint+0x66>
    buf[i++] = '-';
 3ce:	fd070793          	addi	a5,a4,-48
 3d2:	00878733          	add	a4,a5,s0
 3d6:	02d00793          	li	a5,45
 3da:	fef70823          	sb	a5,-16(a4)
 3de:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3e2:	02e05863          	blez	a4,412 <printint+0x96>
 3e6:	fc040793          	addi	a5,s0,-64
 3ea:	00e78933          	add	s2,a5,a4
 3ee:	fff78993          	addi	s3,a5,-1
 3f2:	99ba                	add	s3,s3,a4
 3f4:	377d                	addiw	a4,a4,-1
 3f6:	1702                	slli	a4,a4,0x20
 3f8:	9301                	srli	a4,a4,0x20
 3fa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3fe:	fff94583          	lbu	a1,-1(s2)
 402:	8526                	mv	a0,s1
 404:	00000097          	auipc	ra,0x0
 408:	f56080e7          	jalr	-170(ra) # 35a <putc>
  while(--i >= 0)
 40c:	197d                	addi	s2,s2,-1
 40e:	ff3918e3          	bne	s2,s3,3fe <printint+0x82>
}
 412:	70e2                	ld	ra,56(sp)
 414:	7442                	ld	s0,48(sp)
 416:	74a2                	ld	s1,40(sp)
 418:	7902                	ld	s2,32(sp)
 41a:	69e2                	ld	s3,24(sp)
 41c:	6121                	addi	sp,sp,64
 41e:	8082                	ret
    x = -xx;
 420:	40b005bb          	negw	a1,a1
    neg = 1;
 424:	4885                	li	a7,1
    x = -xx;
 426:	bf85                	j	396 <printint+0x1a>

0000000000000428 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 428:	7119                	addi	sp,sp,-128
 42a:	fc86                	sd	ra,120(sp)
 42c:	f8a2                	sd	s0,112(sp)
 42e:	f4a6                	sd	s1,104(sp)
 430:	f0ca                	sd	s2,96(sp)
 432:	ecce                	sd	s3,88(sp)
 434:	e8d2                	sd	s4,80(sp)
 436:	e4d6                	sd	s5,72(sp)
 438:	e0da                	sd	s6,64(sp)
 43a:	fc5e                	sd	s7,56(sp)
 43c:	f862                	sd	s8,48(sp)
 43e:	f466                	sd	s9,40(sp)
 440:	f06a                	sd	s10,32(sp)
 442:	ec6e                	sd	s11,24(sp)
 444:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 446:	0005c903          	lbu	s2,0(a1)
 44a:	18090f63          	beqz	s2,5e8 <vprintf+0x1c0>
 44e:	8aaa                	mv	s5,a0
 450:	8b32                	mv	s6,a2
 452:	00158493          	addi	s1,a1,1
  state = 0;
 456:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 458:	02500a13          	li	s4,37
 45c:	4c55                	li	s8,21
 45e:	00000c97          	auipc	s9,0x0
 462:	38ac8c93          	addi	s9,s9,906 # 7e8 <malloc+0xfc>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 466:	02800d93          	li	s11,40
  putc(fd, 'x');
 46a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 46c:	00000b97          	auipc	s7,0x0
 470:	3d4b8b93          	addi	s7,s7,980 # 840 <digits>
 474:	a839                	j	492 <vprintf+0x6a>
        putc(fd, c);
 476:	85ca                	mv	a1,s2
 478:	8556                	mv	a0,s5
 47a:	00000097          	auipc	ra,0x0
 47e:	ee0080e7          	jalr	-288(ra) # 35a <putc>
 482:	a019                	j	488 <vprintf+0x60>
    } else if(state == '%'){
 484:	01498d63          	beq	s3,s4,49e <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 488:	0485                	addi	s1,s1,1
 48a:	fff4c903          	lbu	s2,-1(s1)
 48e:	14090d63          	beqz	s2,5e8 <vprintf+0x1c0>
    if(state == 0){
 492:	fe0999e3          	bnez	s3,484 <vprintf+0x5c>
      if(c == '%'){
 496:	ff4910e3          	bne	s2,s4,476 <vprintf+0x4e>
        state = '%';
 49a:	89d2                	mv	s3,s4
 49c:	b7f5                	j	488 <vprintf+0x60>
      if(c == 'd'){
 49e:	11490c63          	beq	s2,s4,5b6 <vprintf+0x18e>
 4a2:	f9d9079b          	addiw	a5,s2,-99
 4a6:	0ff7f793          	zext.b	a5,a5
 4aa:	10fc6e63          	bltu	s8,a5,5c6 <vprintf+0x19e>
 4ae:	f9d9079b          	addiw	a5,s2,-99
 4b2:	0ff7f713          	zext.b	a4,a5
 4b6:	10ec6863          	bltu	s8,a4,5c6 <vprintf+0x19e>
 4ba:	00271793          	slli	a5,a4,0x2
 4be:	97e6                	add	a5,a5,s9
 4c0:	439c                	lw	a5,0(a5)
 4c2:	97e6                	add	a5,a5,s9
 4c4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4c6:	008b0913          	addi	s2,s6,8
 4ca:	4685                	li	a3,1
 4cc:	4629                	li	a2,10
 4ce:	000b2583          	lw	a1,0(s6)
 4d2:	8556                	mv	a0,s5
 4d4:	00000097          	auipc	ra,0x0
 4d8:	ea8080e7          	jalr	-344(ra) # 37c <printint>
 4dc:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4de:	4981                	li	s3,0
 4e0:	b765                	j	488 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4e2:	008b0913          	addi	s2,s6,8
 4e6:	4681                	li	a3,0
 4e8:	4629                	li	a2,10
 4ea:	000b2583          	lw	a1,0(s6)
 4ee:	8556                	mv	a0,s5
 4f0:	00000097          	auipc	ra,0x0
 4f4:	e8c080e7          	jalr	-372(ra) # 37c <printint>
 4f8:	8b4a                	mv	s6,s2
      state = 0;
 4fa:	4981                	li	s3,0
 4fc:	b771                	j	488 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4fe:	008b0913          	addi	s2,s6,8
 502:	4681                	li	a3,0
 504:	866a                	mv	a2,s10
 506:	000b2583          	lw	a1,0(s6)
 50a:	8556                	mv	a0,s5
 50c:	00000097          	auipc	ra,0x0
 510:	e70080e7          	jalr	-400(ra) # 37c <printint>
 514:	8b4a                	mv	s6,s2
      state = 0;
 516:	4981                	li	s3,0
 518:	bf85                	j	488 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 51a:	008b0793          	addi	a5,s6,8
 51e:	f8f43423          	sd	a5,-120(s0)
 522:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 526:	03000593          	li	a1,48
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	e2e080e7          	jalr	-466(ra) # 35a <putc>
  putc(fd, 'x');
 534:	07800593          	li	a1,120
 538:	8556                	mv	a0,s5
 53a:	00000097          	auipc	ra,0x0
 53e:	e20080e7          	jalr	-480(ra) # 35a <putc>
 542:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 544:	03c9d793          	srli	a5,s3,0x3c
 548:	97de                	add	a5,a5,s7
 54a:	0007c583          	lbu	a1,0(a5)
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	e0a080e7          	jalr	-502(ra) # 35a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 558:	0992                	slli	s3,s3,0x4
 55a:	397d                	addiw	s2,s2,-1
 55c:	fe0914e3          	bnez	s2,544 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 560:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 564:	4981                	li	s3,0
 566:	b70d                	j	488 <vprintf+0x60>
        s = va_arg(ap, char*);
 568:	008b0913          	addi	s2,s6,8
 56c:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 570:	02098163          	beqz	s3,592 <vprintf+0x16a>
        while(*s != 0){
 574:	0009c583          	lbu	a1,0(s3)
 578:	c5ad                	beqz	a1,5e2 <vprintf+0x1ba>
          putc(fd, *s);
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	dde080e7          	jalr	-546(ra) # 35a <putc>
          s++;
 584:	0985                	addi	s3,s3,1
        while(*s != 0){
 586:	0009c583          	lbu	a1,0(s3)
 58a:	f9e5                	bnez	a1,57a <vprintf+0x152>
        s = va_arg(ap, char*);
 58c:	8b4a                	mv	s6,s2
      state = 0;
 58e:	4981                	li	s3,0
 590:	bde5                	j	488 <vprintf+0x60>
          s = "(null)";
 592:	00000997          	auipc	s3,0x0
 596:	24e98993          	addi	s3,s3,590 # 7e0 <malloc+0xf4>
        while(*s != 0){
 59a:	85ee                	mv	a1,s11
 59c:	bff9                	j	57a <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 59e:	008b0913          	addi	s2,s6,8
 5a2:	000b4583          	lbu	a1,0(s6)
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	db2080e7          	jalr	-590(ra) # 35a <putc>
 5b0:	8b4a                	mv	s6,s2
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	bdd1                	j	488 <vprintf+0x60>
        putc(fd, c);
 5b6:	85d2                	mv	a1,s4
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	da0080e7          	jalr	-608(ra) # 35a <putc>
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	b5d1                	j	488 <vprintf+0x60>
        putc(fd, '%');
 5c6:	85d2                	mv	a1,s4
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	d90080e7          	jalr	-624(ra) # 35a <putc>
        putc(fd, c);
 5d2:	85ca                	mv	a1,s2
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	d84080e7          	jalr	-636(ra) # 35a <putc>
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b565                	j	488 <vprintf+0x60>
        s = va_arg(ap, char*);
 5e2:	8b4a                	mv	s6,s2
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	b54d                	j	488 <vprintf+0x60>
    }
  }
}
 5e8:	70e6                	ld	ra,120(sp)
 5ea:	7446                	ld	s0,112(sp)
 5ec:	74a6                	ld	s1,104(sp)
 5ee:	7906                	ld	s2,96(sp)
 5f0:	69e6                	ld	s3,88(sp)
 5f2:	6a46                	ld	s4,80(sp)
 5f4:	6aa6                	ld	s5,72(sp)
 5f6:	6b06                	ld	s6,64(sp)
 5f8:	7be2                	ld	s7,56(sp)
 5fa:	7c42                	ld	s8,48(sp)
 5fc:	7ca2                	ld	s9,40(sp)
 5fe:	7d02                	ld	s10,32(sp)
 600:	6de2                	ld	s11,24(sp)
 602:	6109                	addi	sp,sp,128
 604:	8082                	ret

0000000000000606 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 606:	715d                	addi	sp,sp,-80
 608:	ec06                	sd	ra,24(sp)
 60a:	e822                	sd	s0,16(sp)
 60c:	1000                	addi	s0,sp,32
 60e:	e010                	sd	a2,0(s0)
 610:	e414                	sd	a3,8(s0)
 612:	e818                	sd	a4,16(s0)
 614:	ec1c                	sd	a5,24(s0)
 616:	03043023          	sd	a6,32(s0)
 61a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 61e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 622:	8622                	mv	a2,s0
 624:	00000097          	auipc	ra,0x0
 628:	e04080e7          	jalr	-508(ra) # 428 <vprintf>
}
 62c:	60e2                	ld	ra,24(sp)
 62e:	6442                	ld	s0,16(sp)
 630:	6161                	addi	sp,sp,80
 632:	8082                	ret

0000000000000634 <printf>:

void
printf(const char *fmt, ...)
{
 634:	711d                	addi	sp,sp,-96
 636:	ec06                	sd	ra,24(sp)
 638:	e822                	sd	s0,16(sp)
 63a:	1000                	addi	s0,sp,32
 63c:	e40c                	sd	a1,8(s0)
 63e:	e810                	sd	a2,16(s0)
 640:	ec14                	sd	a3,24(s0)
 642:	f018                	sd	a4,32(s0)
 644:	f41c                	sd	a5,40(s0)
 646:	03043823          	sd	a6,48(s0)
 64a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 64e:	00840613          	addi	a2,s0,8
 652:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 656:	85aa                	mv	a1,a0
 658:	4505                	li	a0,1
 65a:	00000097          	auipc	ra,0x0
 65e:	dce080e7          	jalr	-562(ra) # 428 <vprintf>
}
 662:	60e2                	ld	ra,24(sp)
 664:	6442                	ld	s0,16(sp)
 666:	6125                	addi	sp,sp,96
 668:	8082                	ret

000000000000066a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 66a:	1141                	addi	sp,sp,-16
 66c:	e422                	sd	s0,8(sp)
 66e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 670:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 674:	00001797          	auipc	a5,0x1
 678:	98c7b783          	ld	a5,-1652(a5) # 1000 <freep>
 67c:	a02d                	j	6a6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 67e:	4618                	lw	a4,8(a2)
 680:	9f2d                	addw	a4,a4,a1
 682:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 686:	6398                	ld	a4,0(a5)
 688:	6310                	ld	a2,0(a4)
 68a:	a83d                	j	6c8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 68c:	ff852703          	lw	a4,-8(a0)
 690:	9f31                	addw	a4,a4,a2
 692:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 694:	ff053683          	ld	a3,-16(a0)
 698:	a091                	j	6dc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 69a:	6398                	ld	a4,0(a5)
 69c:	00e7e463          	bltu	a5,a4,6a4 <free+0x3a>
 6a0:	00e6ea63          	bltu	a3,a4,6b4 <free+0x4a>
{
 6a4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a6:	fed7fae3          	bgeu	a5,a3,69a <free+0x30>
 6aa:	6398                	ld	a4,0(a5)
 6ac:	00e6e463          	bltu	a3,a4,6b4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b0:	fee7eae3          	bltu	a5,a4,6a4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6b4:	ff852583          	lw	a1,-8(a0)
 6b8:	6390                	ld	a2,0(a5)
 6ba:	02059813          	slli	a6,a1,0x20
 6be:	01c85713          	srli	a4,a6,0x1c
 6c2:	9736                	add	a4,a4,a3
 6c4:	fae60de3          	beq	a2,a4,67e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6c8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6cc:	4790                	lw	a2,8(a5)
 6ce:	02061593          	slli	a1,a2,0x20
 6d2:	01c5d713          	srli	a4,a1,0x1c
 6d6:	973e                	add	a4,a4,a5
 6d8:	fae68ae3          	beq	a3,a4,68c <free+0x22>
    p->s.ptr = bp->s.ptr;
 6dc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6de:	00001717          	auipc	a4,0x1
 6e2:	92f73123          	sd	a5,-1758(a4) # 1000 <freep>
}
 6e6:	6422                	ld	s0,8(sp)
 6e8:	0141                	addi	sp,sp,16
 6ea:	8082                	ret

00000000000006ec <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6ec:	7139                	addi	sp,sp,-64
 6ee:	fc06                	sd	ra,56(sp)
 6f0:	f822                	sd	s0,48(sp)
 6f2:	f426                	sd	s1,40(sp)
 6f4:	f04a                	sd	s2,32(sp)
 6f6:	ec4e                	sd	s3,24(sp)
 6f8:	e852                	sd	s4,16(sp)
 6fa:	e456                	sd	s5,8(sp)
 6fc:	e05a                	sd	s6,0(sp)
 6fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 700:	02051493          	slli	s1,a0,0x20
 704:	9081                	srli	s1,s1,0x20
 706:	04bd                	addi	s1,s1,15
 708:	8091                	srli	s1,s1,0x4
 70a:	0014899b          	addiw	s3,s1,1
 70e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 710:	00001517          	auipc	a0,0x1
 714:	8f053503          	ld	a0,-1808(a0) # 1000 <freep>
 718:	c515                	beqz	a0,744 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 71a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 71c:	4798                	lw	a4,8(a5)
 71e:	02977f63          	bgeu	a4,s1,75c <malloc+0x70>
 722:	8a4e                	mv	s4,s3
 724:	0009871b          	sext.w	a4,s3
 728:	6685                	lui	a3,0x1
 72a:	00d77363          	bgeu	a4,a3,730 <malloc+0x44>
 72e:	6a05                	lui	s4,0x1
 730:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 734:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 738:	00001917          	auipc	s2,0x1
 73c:	8c890913          	addi	s2,s2,-1848 # 1000 <freep>
  if(p == (char*)-1)
 740:	5afd                	li	s5,-1
 742:	a895                	j	7b6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 744:	00001797          	auipc	a5,0x1
 748:	8cc78793          	addi	a5,a5,-1844 # 1010 <base>
 74c:	00001717          	auipc	a4,0x1
 750:	8af73a23          	sd	a5,-1868(a4) # 1000 <freep>
 754:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 756:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 75a:	b7e1                	j	722 <malloc+0x36>
      if(p->s.size == nunits)
 75c:	02e48c63          	beq	s1,a4,794 <malloc+0xa8>
        p->s.size -= nunits;
 760:	4137073b          	subw	a4,a4,s3
 764:	c798                	sw	a4,8(a5)
        p += p->s.size;
 766:	02071693          	slli	a3,a4,0x20
 76a:	01c6d713          	srli	a4,a3,0x1c
 76e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 770:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 774:	00001717          	auipc	a4,0x1
 778:	88a73623          	sd	a0,-1908(a4) # 1000 <freep>
      return (void*)(p + 1);
 77c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 780:	70e2                	ld	ra,56(sp)
 782:	7442                	ld	s0,48(sp)
 784:	74a2                	ld	s1,40(sp)
 786:	7902                	ld	s2,32(sp)
 788:	69e2                	ld	s3,24(sp)
 78a:	6a42                	ld	s4,16(sp)
 78c:	6aa2                	ld	s5,8(sp)
 78e:	6b02                	ld	s6,0(sp)
 790:	6121                	addi	sp,sp,64
 792:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 794:	6398                	ld	a4,0(a5)
 796:	e118                	sd	a4,0(a0)
 798:	bff1                	j	774 <malloc+0x88>
  hp->s.size = nu;
 79a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 79e:	0541                	addi	a0,a0,16
 7a0:	00000097          	auipc	ra,0x0
 7a4:	eca080e7          	jalr	-310(ra) # 66a <free>
  return freep;
 7a8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7ac:	d971                	beqz	a0,780 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b0:	4798                	lw	a4,8(a5)
 7b2:	fa9775e3          	bgeu	a4,s1,75c <malloc+0x70>
    if(p == freep)
 7b6:	00093703          	ld	a4,0(s2)
 7ba:	853e                	mv	a0,a5
 7bc:	fef719e3          	bne	a4,a5,7ae <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7c0:	8552                	mv	a0,s4
 7c2:	00000097          	auipc	ra,0x0
 7c6:	b78080e7          	jalr	-1160(ra) # 33a <sbrk>
  if(p == (char*)-1)
 7ca:	fd5518e3          	bne	a0,s5,79a <malloc+0xae>
        return 0;
 7ce:	4501                	li	a0,0
 7d0:	bf45                	j	780 <malloc+0x94>
