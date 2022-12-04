
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	00090913          	mv	s2,s2
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	4f4080e7          	jalr	1268(ra) # 514 <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	4e8080e7          	jalr	1256(ra) # 51c <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	9e058593          	addi	a1,a1,-1568 # a20 <malloc+0xea>
  48:	4509                	li	a0,2
  4a:	00001097          	auipc	ra,0x1
  4e:	806080e7          	jalr	-2042(ra) # 850 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	4a8080e7          	jalr	1192(ra) # 4fc <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	9ca58593          	addi	a1,a1,-1590 # a38 <malloc+0x102>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	7d8080e7          	jalr	2008(ra) # 850 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	47a080e7          	jalr	1146(ra) # 4fc <exit>

000000000000008a <cat_n>:

void 
cat_n(int fd)
{
  8a:	711d                	addi	sp,sp,-96
  8c:	ec86                	sd	ra,88(sp)
  8e:	e8a2                	sd	s0,80(sp)
  90:	e4a6                	sd	s1,72(sp)
  92:	e0ca                	sd	s2,64(sp)
  94:	fc4e                	sd	s3,56(sp)
  96:	f852                	sd	s4,48(sp)
  98:	f456                	sd	s5,40(sp)
  9a:	f05a                	sd	s6,32(sp)
  9c:	ec5e                	sd	s7,24(sp)
  9e:	e862                	sd	s8,16(sp)
  a0:	e466                	sd	s9,8(sp)
  a2:	1080                	addi	s0,sp,96
  a4:	8c2a                	mv	s8,a0
  int n;
  int c=1;
  printf("1\t");
  a6:	00001517          	auipc	a0,0x1
  aa:	9aa50513          	addi	a0,a0,-1622 # a50 <malloc+0x11a>
  ae:	00000097          	auipc	ra,0x0
  b2:	7d0080e7          	jalr	2000(ra) # 87e <printf>
  int c=1;
  b6:	4905                	li	s2,1
  while((n=read(fd,buf,sizeof(buf)))>0){ 
  b8:	00001c97          	auipc	s9,0x1
  bc:	f58c8c93          	addi	s9,s9,-168 # 1010 <buf>
  c0:	00001a17          	auipc	s4,0x1
  c4:	150a0a13          	addi	s4,s4,336 # 1210 <base>
 	for(int i=0;i<sizeof(buf);i++){
		if(buf[i] != '\n'){
  c8:	49a9                	li	s3,10
			printf("%c",buf[i]);
  		}else{
			c++;
			printf("\n");
  ca:	00001b17          	auipc	s6,0x1
  ce:	966b0b13          	addi	s6,s6,-1690 # a30 <malloc+0xfa>
			printf("%d \t",c);
  d2:	00001b97          	auipc	s7,0x1
  d6:	98eb8b93          	addi	s7,s7,-1650 # a60 <malloc+0x12a>
			printf("%c",buf[i]);
  da:	00001a97          	auipc	s5,0x1
  de:	97ea8a93          	addi	s5,s5,-1666 # a58 <malloc+0x122>
  while((n=read(fd,buf,sizeof(buf)))>0){ 
  e2:	a83d                	j	120 <cat_n+0x96>
			c++;
  e4:	2905                	addiw	s2,s2,1 # 1011 <buf+0x1>
			printf("\n");
  e6:	855a                	mv	a0,s6
  e8:	00000097          	auipc	ra,0x0
  ec:	796080e7          	jalr	1942(ra) # 87e <printf>
			printf("%d \t",c);
  f0:	85ca                	mv	a1,s2
  f2:	855e                	mv	a0,s7
  f4:	00000097          	auipc	ra,0x0
  f8:	78a080e7          	jalr	1930(ra) # 87e <printf>
 	for(int i=0;i<sizeof(buf);i++){
  fc:	0485                	addi	s1,s1,1
  fe:	01448c63          	beq	s1,s4,116 <cat_n+0x8c>
		if(buf[i] != '\n'){
 102:	0004c583          	lbu	a1,0(s1)
 106:	fd358fe3          	beq	a1,s3,e4 <cat_n+0x5a>
			printf("%c",buf[i]);
 10a:	8556                	mv	a0,s5
 10c:	00000097          	auipc	ra,0x0
 110:	772080e7          	jalr	1906(ra) # 87e <printf>
 114:	b7e5                	j	fc <cat_n+0x72>
		}
	}
	printf("\n");
 116:	855a                	mv	a0,s6
 118:	00000097          	auipc	ra,0x0
 11c:	766080e7          	jalr	1894(ra) # 87e <printf>
  while((n=read(fd,buf,sizeof(buf)))>0){ 
 120:	20000613          	li	a2,512
 124:	85e6                	mv	a1,s9
 126:	8562                	mv	a0,s8
 128:	00000097          	auipc	ra,0x0
 12c:	3ec080e7          	jalr	1004(ra) # 514 <read>
 130:	00a05763          	blez	a0,13e <cat_n+0xb4>
 	for(int i=0;i<sizeof(buf);i++){
 134:	00001497          	auipc	s1,0x1
 138:	edc48493          	addi	s1,s1,-292 # 1010 <buf>
 13c:	b7d9                	j	102 <cat_n+0x78>
  }
}
 13e:	60e6                	ld	ra,88(sp)
 140:	6446                	ld	s0,80(sp)
 142:	64a6                	ld	s1,72(sp)
 144:	6906                	ld	s2,64(sp)
 146:	79e2                	ld	s3,56(sp)
 148:	7a42                	ld	s4,48(sp)
 14a:	7aa2                	ld	s5,40(sp)
 14c:	7b02                	ld	s6,32(sp)
 14e:	6be2                	ld	s7,24(sp)
 150:	6c42                	ld	s8,16(sp)
 152:	6ca2                	ld	s9,8(sp)
 154:	6125                	addi	sp,sp,96
 156:	8082                	ret

0000000000000158 <main>:

int
main(int argc, char *argv[])
{
 158:	7179                	addi	sp,sp,-48
 15a:	f406                	sd	ra,40(sp)
 15c:	f022                	sd	s0,32(sp)
 15e:	ec26                	sd	s1,24(sp)
 160:	e84a                	sd	s2,16(sp)
 162:	e44e                	sd	s3,8(sp)
 164:	e052                	sd	s4,0(sp)
 166:	1800                	addi	s0,sp,48
  int fd, i;
  if(argv[1][0] == '-' && argv[1][1] == 'n'){
 168:	659c                	ld	a5,8(a1)
 16a:	0007c683          	lbu	a3,0(a5)
 16e:	02d00713          	li	a4,45
 172:	04e68a63          	beq	a3,a4,1c6 <main+0x6e>
    		cat_n(fd);
    		close(fd);
  	}
  	exit(0);
  }
  else if(argc <= 1){
 176:	4785                	li	a5,1
 178:	0ca7d563          	bge	a5,a0,242 <main+0xea>
 17c:	00858913          	addi	s2,a1,8
 180:	ffe5099b          	addiw	s3,a0,-2
 184:	02099793          	slli	a5,s3,0x20
 188:	01d7d993          	srli	s3,a5,0x1d
 18c:	05c1                	addi	a1,a1,16
 18e:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 190:	4581                	li	a1,0
 192:	00093503          	ld	a0,0(s2)
 196:	00000097          	auipc	ra,0x0
 19a:	3a6080e7          	jalr	934(ra) # 53c <open>
 19e:	84aa                	mv	s1,a0
 1a0:	0a054b63          	bltz	a0,256 <main+0xfe>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
 1a4:	00000097          	auipc	ra,0x0
 1a8:	e5c080e7          	jalr	-420(ra) # 0 <cat>
    close(fd);
 1ac:	8526                	mv	a0,s1
 1ae:	00000097          	auipc	ra,0x0
 1b2:	376080e7          	jalr	886(ra) # 524 <close>
  for(i = 1; i < argc; i++){
 1b6:	0921                	addi	s2,s2,8
 1b8:	fd391ce3          	bne	s2,s3,190 <main+0x38>
  }
  exit(0);
 1bc:	4501                	li	a0,0
 1be:	00000097          	auipc	ra,0x0
 1c2:	33e080e7          	jalr	830(ra) # 4fc <exit>
  if(argv[1][0] == '-' && argv[1][1] == 'n'){
 1c6:	0017c703          	lbu	a4,1(a5)
 1ca:	06e00793          	li	a5,110
 1ce:	faf714e3          	bne	a4,a5,176 <main+0x1e>
  	for(i = 2; i < argc; i++){
 1d2:	4789                	li	a5,2
 1d4:	04a7d263          	bge	a5,a0,218 <main+0xc0>
 1d8:	01058993          	addi	s3,a1,16
 1dc:	ffd5049b          	addiw	s1,a0,-3
 1e0:	02049793          	slli	a5,s1,0x20
 1e4:	01d7d493          	srli	s1,a5,0x1d
 1e8:	05e1                	addi	a1,a1,24
 1ea:	94ae                	add	s1,s1,a1
    		if((fd = open(argv[i], 0)) < 0){
 1ec:	4581                	li	a1,0
 1ee:	0009b503          	ld	a0,0(s3)
 1f2:	00000097          	auipc	ra,0x0
 1f6:	34a080e7          	jalr	842(ra) # 53c <open>
 1fa:	892a                	mv	s2,a0
 1fc:	02054363          	bltz	a0,222 <main+0xca>
    		cat_n(fd);
 200:	00000097          	auipc	ra,0x0
 204:	e8a080e7          	jalr	-374(ra) # 8a <cat_n>
    		close(fd);
 208:	854a                	mv	a0,s2
 20a:	00000097          	auipc	ra,0x0
 20e:	31a080e7          	jalr	794(ra) # 524 <close>
  	for(i = 2; i < argc; i++){
 212:	09a1                	addi	s3,s3,8
 214:	fc999ce3          	bne	s3,s1,1ec <main+0x94>
  	exit(0);
 218:	4501                	li	a0,0
 21a:	00000097          	auipc	ra,0x0
 21e:	2e2080e7          	jalr	738(ra) # 4fc <exit>
      			fprintf(2, "cat: cannot open %s\n", argv[i]);
 222:	0009b603          	ld	a2,0(s3)
 226:	00001597          	auipc	a1,0x1
 22a:	84258593          	addi	a1,a1,-1982 # a68 <malloc+0x132>
 22e:	4509                	li	a0,2
 230:	00000097          	auipc	ra,0x0
 234:	620080e7          	jalr	1568(ra) # 850 <fprintf>
      			exit(1);
 238:	4505                	li	a0,1
 23a:	00000097          	auipc	ra,0x0
 23e:	2c2080e7          	jalr	706(ra) # 4fc <exit>
    cat(0);
 242:	4501                	li	a0,0
 244:	00000097          	auipc	ra,0x0
 248:	dbc080e7          	jalr	-580(ra) # 0 <cat>
    exit(0);
 24c:	4501                	li	a0,0
 24e:	00000097          	auipc	ra,0x0
 252:	2ae080e7          	jalr	686(ra) # 4fc <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
 256:	00093603          	ld	a2,0(s2)
 25a:	00001597          	auipc	a1,0x1
 25e:	80e58593          	addi	a1,a1,-2034 # a68 <malloc+0x132>
 262:	4509                	li	a0,2
 264:	00000097          	auipc	ra,0x0
 268:	5ec080e7          	jalr	1516(ra) # 850 <fprintf>
      exit(1);
 26c:	4505                	li	a0,1
 26e:	00000097          	auipc	ra,0x0
 272:	28e080e7          	jalr	654(ra) # 4fc <exit>

0000000000000276 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 276:	1141                	addi	sp,sp,-16
 278:	e406                	sd	ra,8(sp)
 27a:	e022                	sd	s0,0(sp)
 27c:	0800                	addi	s0,sp,16
  extern int main();
  main();
 27e:	00000097          	auipc	ra,0x0
 282:	eda080e7          	jalr	-294(ra) # 158 <main>
  exit(0);
 286:	4501                	li	a0,0
 288:	00000097          	auipc	ra,0x0
 28c:	274080e7          	jalr	628(ra) # 4fc <exit>

0000000000000290 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 290:	1141                	addi	sp,sp,-16
 292:	e422                	sd	s0,8(sp)
 294:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 296:	87aa                	mv	a5,a0
 298:	0585                	addi	a1,a1,1
 29a:	0785                	addi	a5,a5,1
 29c:	fff5c703          	lbu	a4,-1(a1)
 2a0:	fee78fa3          	sb	a4,-1(a5)
 2a4:	fb75                	bnez	a4,298 <strcpy+0x8>
    ;
  return os;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret

00000000000002ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e422                	sd	s0,8(sp)
 2b0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2b2:	00054783          	lbu	a5,0(a0)
 2b6:	cb91                	beqz	a5,2ca <strcmp+0x1e>
 2b8:	0005c703          	lbu	a4,0(a1)
 2bc:	00f71763          	bne	a4,a5,2ca <strcmp+0x1e>
    p++, q++;
 2c0:	0505                	addi	a0,a0,1
 2c2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2c4:	00054783          	lbu	a5,0(a0)
 2c8:	fbe5                	bnez	a5,2b8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2ca:	0005c503          	lbu	a0,0(a1)
}
 2ce:	40a7853b          	subw	a0,a5,a0
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret

00000000000002d8 <strlen>:

uint
strlen(const char *s)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e422                	sd	s0,8(sp)
 2dc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2de:	00054783          	lbu	a5,0(a0)
 2e2:	cf91                	beqz	a5,2fe <strlen+0x26>
 2e4:	0505                	addi	a0,a0,1
 2e6:	87aa                	mv	a5,a0
 2e8:	4685                	li	a3,1
 2ea:	9e89                	subw	a3,a3,a0
 2ec:	00f6853b          	addw	a0,a3,a5
 2f0:	0785                	addi	a5,a5,1
 2f2:	fff7c703          	lbu	a4,-1(a5)
 2f6:	fb7d                	bnez	a4,2ec <strlen+0x14>
    ;
  return n;
}
 2f8:	6422                	ld	s0,8(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret
  for(n = 0; s[n]; n++)
 2fe:	4501                	li	a0,0
 300:	bfe5                	j	2f8 <strlen+0x20>

0000000000000302 <memset>:

void*
memset(void *dst, int c, uint n)
{
 302:	1141                	addi	sp,sp,-16
 304:	e422                	sd	s0,8(sp)
 306:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 308:	ca19                	beqz	a2,31e <memset+0x1c>
 30a:	87aa                	mv	a5,a0
 30c:	1602                	slli	a2,a2,0x20
 30e:	9201                	srli	a2,a2,0x20
 310:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 314:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 318:	0785                	addi	a5,a5,1
 31a:	fee79de3          	bne	a5,a4,314 <memset+0x12>
  }
  return dst;
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <strchr>:

char*
strchr(const char *s, char c)
{
 324:	1141                	addi	sp,sp,-16
 326:	e422                	sd	s0,8(sp)
 328:	0800                	addi	s0,sp,16
  for(; *s; s++)
 32a:	00054783          	lbu	a5,0(a0)
 32e:	cb99                	beqz	a5,344 <strchr+0x20>
    if(*s == c)
 330:	00f58763          	beq	a1,a5,33e <strchr+0x1a>
  for(; *s; s++)
 334:	0505                	addi	a0,a0,1
 336:	00054783          	lbu	a5,0(a0)
 33a:	fbfd                	bnez	a5,330 <strchr+0xc>
      return (char*)s;
  return 0;
 33c:	4501                	li	a0,0
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
  return 0;
 344:	4501                	li	a0,0
 346:	bfe5                	j	33e <strchr+0x1a>

0000000000000348 <gets>:

char*
gets(char *buf, int max)
{
 348:	711d                	addi	sp,sp,-96
 34a:	ec86                	sd	ra,88(sp)
 34c:	e8a2                	sd	s0,80(sp)
 34e:	e4a6                	sd	s1,72(sp)
 350:	e0ca                	sd	s2,64(sp)
 352:	fc4e                	sd	s3,56(sp)
 354:	f852                	sd	s4,48(sp)
 356:	f456                	sd	s5,40(sp)
 358:	f05a                	sd	s6,32(sp)
 35a:	ec5e                	sd	s7,24(sp)
 35c:	1080                	addi	s0,sp,96
 35e:	8baa                	mv	s7,a0
 360:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 362:	892a                	mv	s2,a0
 364:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 366:	4aa9                	li	s5,10
 368:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 36a:	89a6                	mv	s3,s1
 36c:	2485                	addiw	s1,s1,1
 36e:	0344d863          	bge	s1,s4,39e <gets+0x56>
    cc = read(0, &c, 1);
 372:	4605                	li	a2,1
 374:	faf40593          	addi	a1,s0,-81
 378:	4501                	li	a0,0
 37a:	00000097          	auipc	ra,0x0
 37e:	19a080e7          	jalr	410(ra) # 514 <read>
    if(cc < 1)
 382:	00a05e63          	blez	a0,39e <gets+0x56>
    buf[i++] = c;
 386:	faf44783          	lbu	a5,-81(s0)
 38a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 38e:	01578763          	beq	a5,s5,39c <gets+0x54>
 392:	0905                	addi	s2,s2,1
 394:	fd679be3          	bne	a5,s6,36a <gets+0x22>
  for(i=0; i+1 < max; ){
 398:	89a6                	mv	s3,s1
 39a:	a011                	j	39e <gets+0x56>
 39c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 39e:	99de                	add	s3,s3,s7
 3a0:	00098023          	sb	zero,0(s3)
  return buf;
}
 3a4:	855e                	mv	a0,s7
 3a6:	60e6                	ld	ra,88(sp)
 3a8:	6446                	ld	s0,80(sp)
 3aa:	64a6                	ld	s1,72(sp)
 3ac:	6906                	ld	s2,64(sp)
 3ae:	79e2                	ld	s3,56(sp)
 3b0:	7a42                	ld	s4,48(sp)
 3b2:	7aa2                	ld	s5,40(sp)
 3b4:	7b02                	ld	s6,32(sp)
 3b6:	6be2                	ld	s7,24(sp)
 3b8:	6125                	addi	sp,sp,96
 3ba:	8082                	ret

00000000000003bc <stat>:

int
stat(const char *n, struct stat *st)
{
 3bc:	1101                	addi	sp,sp,-32
 3be:	ec06                	sd	ra,24(sp)
 3c0:	e822                	sd	s0,16(sp)
 3c2:	e426                	sd	s1,8(sp)
 3c4:	e04a                	sd	s2,0(sp)
 3c6:	1000                	addi	s0,sp,32
 3c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3ca:	4581                	li	a1,0
 3cc:	00000097          	auipc	ra,0x0
 3d0:	170080e7          	jalr	368(ra) # 53c <open>
  if(fd < 0)
 3d4:	02054563          	bltz	a0,3fe <stat+0x42>
 3d8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3da:	85ca                	mv	a1,s2
 3dc:	00000097          	auipc	ra,0x0
 3e0:	178080e7          	jalr	376(ra) # 554 <fstat>
 3e4:	892a                	mv	s2,a0
  close(fd);
 3e6:	8526                	mv	a0,s1
 3e8:	00000097          	auipc	ra,0x0
 3ec:	13c080e7          	jalr	316(ra) # 524 <close>
  return r;
}
 3f0:	854a                	mv	a0,s2
 3f2:	60e2                	ld	ra,24(sp)
 3f4:	6442                	ld	s0,16(sp)
 3f6:	64a2                	ld	s1,8(sp)
 3f8:	6902                	ld	s2,0(sp)
 3fa:	6105                	addi	sp,sp,32
 3fc:	8082                	ret
    return -1;
 3fe:	597d                	li	s2,-1
 400:	bfc5                	j	3f0 <stat+0x34>

0000000000000402 <atoi>:

int
atoi(const char *s)
{
 402:	1141                	addi	sp,sp,-16
 404:	e422                	sd	s0,8(sp)
 406:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 408:	00054683          	lbu	a3,0(a0)
 40c:	fd06879b          	addiw	a5,a3,-48
 410:	0ff7f793          	zext.b	a5,a5
 414:	4625                	li	a2,9
 416:	02f66863          	bltu	a2,a5,446 <atoi+0x44>
 41a:	872a                	mv	a4,a0
  n = 0;
 41c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 41e:	0705                	addi	a4,a4,1
 420:	0025179b          	slliw	a5,a0,0x2
 424:	9fa9                	addw	a5,a5,a0
 426:	0017979b          	slliw	a5,a5,0x1
 42a:	9fb5                	addw	a5,a5,a3
 42c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 430:	00074683          	lbu	a3,0(a4)
 434:	fd06879b          	addiw	a5,a3,-48
 438:	0ff7f793          	zext.b	a5,a5
 43c:	fef671e3          	bgeu	a2,a5,41e <atoi+0x1c>
  return n;
}
 440:	6422                	ld	s0,8(sp)
 442:	0141                	addi	sp,sp,16
 444:	8082                	ret
  n = 0;
 446:	4501                	li	a0,0
 448:	bfe5                	j	440 <atoi+0x3e>

000000000000044a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e422                	sd	s0,8(sp)
 44e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 450:	02b57463          	bgeu	a0,a1,478 <memmove+0x2e>
    while(n-- > 0)
 454:	00c05f63          	blez	a2,472 <memmove+0x28>
 458:	1602                	slli	a2,a2,0x20
 45a:	9201                	srli	a2,a2,0x20
 45c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 460:	872a                	mv	a4,a0
      *dst++ = *src++;
 462:	0585                	addi	a1,a1,1
 464:	0705                	addi	a4,a4,1
 466:	fff5c683          	lbu	a3,-1(a1)
 46a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 46e:	fee79ae3          	bne	a5,a4,462 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 472:	6422                	ld	s0,8(sp)
 474:	0141                	addi	sp,sp,16
 476:	8082                	ret
    dst += n;
 478:	00c50733          	add	a4,a0,a2
    src += n;
 47c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 47e:	fec05ae3          	blez	a2,472 <memmove+0x28>
 482:	fff6079b          	addiw	a5,a2,-1
 486:	1782                	slli	a5,a5,0x20
 488:	9381                	srli	a5,a5,0x20
 48a:	fff7c793          	not	a5,a5
 48e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 490:	15fd                	addi	a1,a1,-1
 492:	177d                	addi	a4,a4,-1
 494:	0005c683          	lbu	a3,0(a1)
 498:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 49c:	fee79ae3          	bne	a5,a4,490 <memmove+0x46>
 4a0:	bfc9                	j	472 <memmove+0x28>

00000000000004a2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4a2:	1141                	addi	sp,sp,-16
 4a4:	e422                	sd	s0,8(sp)
 4a6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4a8:	ca05                	beqz	a2,4d8 <memcmp+0x36>
 4aa:	fff6069b          	addiw	a3,a2,-1
 4ae:	1682                	slli	a3,a3,0x20
 4b0:	9281                	srli	a3,a3,0x20
 4b2:	0685                	addi	a3,a3,1
 4b4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4b6:	00054783          	lbu	a5,0(a0)
 4ba:	0005c703          	lbu	a4,0(a1)
 4be:	00e79863          	bne	a5,a4,4ce <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4c2:	0505                	addi	a0,a0,1
    p2++;
 4c4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4c6:	fed518e3          	bne	a0,a3,4b6 <memcmp+0x14>
  }
  return 0;
 4ca:	4501                	li	a0,0
 4cc:	a019                	j	4d2 <memcmp+0x30>
      return *p1 - *p2;
 4ce:	40e7853b          	subw	a0,a5,a4
}
 4d2:	6422                	ld	s0,8(sp)
 4d4:	0141                	addi	sp,sp,16
 4d6:	8082                	ret
  return 0;
 4d8:	4501                	li	a0,0
 4da:	bfe5                	j	4d2 <memcmp+0x30>

00000000000004dc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4dc:	1141                	addi	sp,sp,-16
 4de:	e406                	sd	ra,8(sp)
 4e0:	e022                	sd	s0,0(sp)
 4e2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4e4:	00000097          	auipc	ra,0x0
 4e8:	f66080e7          	jalr	-154(ra) # 44a <memmove>
}
 4ec:	60a2                	ld	ra,8(sp)
 4ee:	6402                	ld	s0,0(sp)
 4f0:	0141                	addi	sp,sp,16
 4f2:	8082                	ret

00000000000004f4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f4:	4885                	li	a7,1
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <exit>:
.global exit
exit:
 li a7, SYS_exit
 4fc:	4889                	li	a7,2
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <wait>:
.global wait
wait:
 li a7, SYS_wait
 504:	488d                	li	a7,3
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 50c:	4891                	li	a7,4
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <read>:
.global read
read:
 li a7, SYS_read
 514:	4895                	li	a7,5
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <write>:
.global write
write:
 li a7, SYS_write
 51c:	48c1                	li	a7,16
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <close>:
.global close
close:
 li a7, SYS_close
 524:	48d5                	li	a7,21
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <kill>:
.global kill
kill:
 li a7, SYS_kill
 52c:	4899                	li	a7,6
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <exec>:
.global exec
exec:
 li a7, SYS_exec
 534:	489d                	li	a7,7
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <open>:
.global open
open:
 li a7, SYS_open
 53c:	48bd                	li	a7,15
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 544:	48c5                	li	a7,17
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 54c:	48c9                	li	a7,18
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 554:	48a1                	li	a7,8
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <link>:
.global link
link:
 li a7, SYS_link
 55c:	48cd                	li	a7,19
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 564:	48d1                	li	a7,20
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 56c:	48a5                	li	a7,9
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <dup>:
.global dup
dup:
 li a7, SYS_dup
 574:	48a9                	li	a7,10
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 57c:	48ad                	li	a7,11
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 584:	48b1                	li	a7,12
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 58c:	48b5                	li	a7,13
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 594:	48b9                	li	a7,14
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <ps>:
.global ps
ps:
 li a7, SYS_ps
 59c:	48d9                	li	a7,22
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5a4:	1101                	addi	sp,sp,-32
 5a6:	ec06                	sd	ra,24(sp)
 5a8:	e822                	sd	s0,16(sp)
 5aa:	1000                	addi	s0,sp,32
 5ac:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5b0:	4605                	li	a2,1
 5b2:	fef40593          	addi	a1,s0,-17
 5b6:	00000097          	auipc	ra,0x0
 5ba:	f66080e7          	jalr	-154(ra) # 51c <write>
}
 5be:	60e2                	ld	ra,24(sp)
 5c0:	6442                	ld	s0,16(sp)
 5c2:	6105                	addi	sp,sp,32
 5c4:	8082                	ret

00000000000005c6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5c6:	7139                	addi	sp,sp,-64
 5c8:	fc06                	sd	ra,56(sp)
 5ca:	f822                	sd	s0,48(sp)
 5cc:	f426                	sd	s1,40(sp)
 5ce:	f04a                	sd	s2,32(sp)
 5d0:	ec4e                	sd	s3,24(sp)
 5d2:	0080                	addi	s0,sp,64
 5d4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5d6:	c299                	beqz	a3,5dc <printint+0x16>
 5d8:	0805c963          	bltz	a1,66a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5dc:	2581                	sext.w	a1,a1
  neg = 0;
 5de:	4881                	li	a7,0
 5e0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5e4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5e6:	2601                	sext.w	a2,a2
 5e8:	00000517          	auipc	a0,0x0
 5ec:	4f850513          	addi	a0,a0,1272 # ae0 <digits>
 5f0:	883a                	mv	a6,a4
 5f2:	2705                	addiw	a4,a4,1
 5f4:	02c5f7bb          	remuw	a5,a1,a2
 5f8:	1782                	slli	a5,a5,0x20
 5fa:	9381                	srli	a5,a5,0x20
 5fc:	97aa                	add	a5,a5,a0
 5fe:	0007c783          	lbu	a5,0(a5)
 602:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 606:	0005879b          	sext.w	a5,a1
 60a:	02c5d5bb          	divuw	a1,a1,a2
 60e:	0685                	addi	a3,a3,1
 610:	fec7f0e3          	bgeu	a5,a2,5f0 <printint+0x2a>
  if(neg)
 614:	00088c63          	beqz	a7,62c <printint+0x66>
    buf[i++] = '-';
 618:	fd070793          	addi	a5,a4,-48
 61c:	00878733          	add	a4,a5,s0
 620:	02d00793          	li	a5,45
 624:	fef70823          	sb	a5,-16(a4)
 628:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 62c:	02e05863          	blez	a4,65c <printint+0x96>
 630:	fc040793          	addi	a5,s0,-64
 634:	00e78933          	add	s2,a5,a4
 638:	fff78993          	addi	s3,a5,-1
 63c:	99ba                	add	s3,s3,a4
 63e:	377d                	addiw	a4,a4,-1
 640:	1702                	slli	a4,a4,0x20
 642:	9301                	srli	a4,a4,0x20
 644:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 648:	fff94583          	lbu	a1,-1(s2)
 64c:	8526                	mv	a0,s1
 64e:	00000097          	auipc	ra,0x0
 652:	f56080e7          	jalr	-170(ra) # 5a4 <putc>
  while(--i >= 0)
 656:	197d                	addi	s2,s2,-1
 658:	ff3918e3          	bne	s2,s3,648 <printint+0x82>
}
 65c:	70e2                	ld	ra,56(sp)
 65e:	7442                	ld	s0,48(sp)
 660:	74a2                	ld	s1,40(sp)
 662:	7902                	ld	s2,32(sp)
 664:	69e2                	ld	s3,24(sp)
 666:	6121                	addi	sp,sp,64
 668:	8082                	ret
    x = -xx;
 66a:	40b005bb          	negw	a1,a1
    neg = 1;
 66e:	4885                	li	a7,1
    x = -xx;
 670:	bf85                	j	5e0 <printint+0x1a>

0000000000000672 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 672:	7119                	addi	sp,sp,-128
 674:	fc86                	sd	ra,120(sp)
 676:	f8a2                	sd	s0,112(sp)
 678:	f4a6                	sd	s1,104(sp)
 67a:	f0ca                	sd	s2,96(sp)
 67c:	ecce                	sd	s3,88(sp)
 67e:	e8d2                	sd	s4,80(sp)
 680:	e4d6                	sd	s5,72(sp)
 682:	e0da                	sd	s6,64(sp)
 684:	fc5e                	sd	s7,56(sp)
 686:	f862                	sd	s8,48(sp)
 688:	f466                	sd	s9,40(sp)
 68a:	f06a                	sd	s10,32(sp)
 68c:	ec6e                	sd	s11,24(sp)
 68e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 690:	0005c903          	lbu	s2,0(a1)
 694:	18090f63          	beqz	s2,832 <vprintf+0x1c0>
 698:	8aaa                	mv	s5,a0
 69a:	8b32                	mv	s6,a2
 69c:	00158493          	addi	s1,a1,1
  state = 0;
 6a0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6a2:	02500a13          	li	s4,37
 6a6:	4c55                	li	s8,21
 6a8:	00000c97          	auipc	s9,0x0
 6ac:	3e0c8c93          	addi	s9,s9,992 # a88 <malloc+0x152>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6b0:	02800d93          	li	s11,40
  putc(fd, 'x');
 6b4:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b6:	00000b97          	auipc	s7,0x0
 6ba:	42ab8b93          	addi	s7,s7,1066 # ae0 <digits>
 6be:	a839                	j	6dc <vprintf+0x6a>
        putc(fd, c);
 6c0:	85ca                	mv	a1,s2
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	ee0080e7          	jalr	-288(ra) # 5a4 <putc>
 6cc:	a019                	j	6d2 <vprintf+0x60>
    } else if(state == '%'){
 6ce:	01498d63          	beq	s3,s4,6e8 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 6d2:	0485                	addi	s1,s1,1
 6d4:	fff4c903          	lbu	s2,-1(s1)
 6d8:	14090d63          	beqz	s2,832 <vprintf+0x1c0>
    if(state == 0){
 6dc:	fe0999e3          	bnez	s3,6ce <vprintf+0x5c>
      if(c == '%'){
 6e0:	ff4910e3          	bne	s2,s4,6c0 <vprintf+0x4e>
        state = '%';
 6e4:	89d2                	mv	s3,s4
 6e6:	b7f5                	j	6d2 <vprintf+0x60>
      if(c == 'd'){
 6e8:	11490c63          	beq	s2,s4,800 <vprintf+0x18e>
 6ec:	f9d9079b          	addiw	a5,s2,-99
 6f0:	0ff7f793          	zext.b	a5,a5
 6f4:	10fc6e63          	bltu	s8,a5,810 <vprintf+0x19e>
 6f8:	f9d9079b          	addiw	a5,s2,-99
 6fc:	0ff7f713          	zext.b	a4,a5
 700:	10ec6863          	bltu	s8,a4,810 <vprintf+0x19e>
 704:	00271793          	slli	a5,a4,0x2
 708:	97e6                	add	a5,a5,s9
 70a:	439c                	lw	a5,0(a5)
 70c:	97e6                	add	a5,a5,s9
 70e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 710:	008b0913          	addi	s2,s6,8
 714:	4685                	li	a3,1
 716:	4629                	li	a2,10
 718:	000b2583          	lw	a1,0(s6)
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	ea8080e7          	jalr	-344(ra) # 5c6 <printint>
 726:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 728:	4981                	li	s3,0
 72a:	b765                	j	6d2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 72c:	008b0913          	addi	s2,s6,8
 730:	4681                	li	a3,0
 732:	4629                	li	a2,10
 734:	000b2583          	lw	a1,0(s6)
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	e8c080e7          	jalr	-372(ra) # 5c6 <printint>
 742:	8b4a                	mv	s6,s2
      state = 0;
 744:	4981                	li	s3,0
 746:	b771                	j	6d2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 748:	008b0913          	addi	s2,s6,8
 74c:	4681                	li	a3,0
 74e:	866a                	mv	a2,s10
 750:	000b2583          	lw	a1,0(s6)
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	e70080e7          	jalr	-400(ra) # 5c6 <printint>
 75e:	8b4a                	mv	s6,s2
      state = 0;
 760:	4981                	li	s3,0
 762:	bf85                	j	6d2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 764:	008b0793          	addi	a5,s6,8
 768:	f8f43423          	sd	a5,-120(s0)
 76c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 770:	03000593          	li	a1,48
 774:	8556                	mv	a0,s5
 776:	00000097          	auipc	ra,0x0
 77a:	e2e080e7          	jalr	-466(ra) # 5a4 <putc>
  putc(fd, 'x');
 77e:	07800593          	li	a1,120
 782:	8556                	mv	a0,s5
 784:	00000097          	auipc	ra,0x0
 788:	e20080e7          	jalr	-480(ra) # 5a4 <putc>
 78c:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 78e:	03c9d793          	srli	a5,s3,0x3c
 792:	97de                	add	a5,a5,s7
 794:	0007c583          	lbu	a1,0(a5)
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	e0a080e7          	jalr	-502(ra) # 5a4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7a2:	0992                	slli	s3,s3,0x4
 7a4:	397d                	addiw	s2,s2,-1
 7a6:	fe0914e3          	bnez	s2,78e <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 7aa:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b70d                	j	6d2 <vprintf+0x60>
        s = va_arg(ap, char*);
 7b2:	008b0913          	addi	s2,s6,8
 7b6:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 7ba:	02098163          	beqz	s3,7dc <vprintf+0x16a>
        while(*s != 0){
 7be:	0009c583          	lbu	a1,0(s3)
 7c2:	c5ad                	beqz	a1,82c <vprintf+0x1ba>
          putc(fd, *s);
 7c4:	8556                	mv	a0,s5
 7c6:	00000097          	auipc	ra,0x0
 7ca:	dde080e7          	jalr	-546(ra) # 5a4 <putc>
          s++;
 7ce:	0985                	addi	s3,s3,1
        while(*s != 0){
 7d0:	0009c583          	lbu	a1,0(s3)
 7d4:	f9e5                	bnez	a1,7c4 <vprintf+0x152>
        s = va_arg(ap, char*);
 7d6:	8b4a                	mv	s6,s2
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	bde5                	j	6d2 <vprintf+0x60>
          s = "(null)";
 7dc:	00000997          	auipc	s3,0x0
 7e0:	2a498993          	addi	s3,s3,676 # a80 <malloc+0x14a>
        while(*s != 0){
 7e4:	85ee                	mv	a1,s11
 7e6:	bff9                	j	7c4 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 7e8:	008b0913          	addi	s2,s6,8
 7ec:	000b4583          	lbu	a1,0(s6)
 7f0:	8556                	mv	a0,s5
 7f2:	00000097          	auipc	ra,0x0
 7f6:	db2080e7          	jalr	-590(ra) # 5a4 <putc>
 7fa:	8b4a                	mv	s6,s2
      state = 0;
 7fc:	4981                	li	s3,0
 7fe:	bdd1                	j	6d2 <vprintf+0x60>
        putc(fd, c);
 800:	85d2                	mv	a1,s4
 802:	8556                	mv	a0,s5
 804:	00000097          	auipc	ra,0x0
 808:	da0080e7          	jalr	-608(ra) # 5a4 <putc>
      state = 0;
 80c:	4981                	li	s3,0
 80e:	b5d1                	j	6d2 <vprintf+0x60>
        putc(fd, '%');
 810:	85d2                	mv	a1,s4
 812:	8556                	mv	a0,s5
 814:	00000097          	auipc	ra,0x0
 818:	d90080e7          	jalr	-624(ra) # 5a4 <putc>
        putc(fd, c);
 81c:	85ca                	mv	a1,s2
 81e:	8556                	mv	a0,s5
 820:	00000097          	auipc	ra,0x0
 824:	d84080e7          	jalr	-636(ra) # 5a4 <putc>
      state = 0;
 828:	4981                	li	s3,0
 82a:	b565                	j	6d2 <vprintf+0x60>
        s = va_arg(ap, char*);
 82c:	8b4a                	mv	s6,s2
      state = 0;
 82e:	4981                	li	s3,0
 830:	b54d                	j	6d2 <vprintf+0x60>
    }
  }
}
 832:	70e6                	ld	ra,120(sp)
 834:	7446                	ld	s0,112(sp)
 836:	74a6                	ld	s1,104(sp)
 838:	7906                	ld	s2,96(sp)
 83a:	69e6                	ld	s3,88(sp)
 83c:	6a46                	ld	s4,80(sp)
 83e:	6aa6                	ld	s5,72(sp)
 840:	6b06                	ld	s6,64(sp)
 842:	7be2                	ld	s7,56(sp)
 844:	7c42                	ld	s8,48(sp)
 846:	7ca2                	ld	s9,40(sp)
 848:	7d02                	ld	s10,32(sp)
 84a:	6de2                	ld	s11,24(sp)
 84c:	6109                	addi	sp,sp,128
 84e:	8082                	ret

0000000000000850 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 850:	715d                	addi	sp,sp,-80
 852:	ec06                	sd	ra,24(sp)
 854:	e822                	sd	s0,16(sp)
 856:	1000                	addi	s0,sp,32
 858:	e010                	sd	a2,0(s0)
 85a:	e414                	sd	a3,8(s0)
 85c:	e818                	sd	a4,16(s0)
 85e:	ec1c                	sd	a5,24(s0)
 860:	03043023          	sd	a6,32(s0)
 864:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 868:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 86c:	8622                	mv	a2,s0
 86e:	00000097          	auipc	ra,0x0
 872:	e04080e7          	jalr	-508(ra) # 672 <vprintf>
}
 876:	60e2                	ld	ra,24(sp)
 878:	6442                	ld	s0,16(sp)
 87a:	6161                	addi	sp,sp,80
 87c:	8082                	ret

000000000000087e <printf>:

void
printf(const char *fmt, ...)
{
 87e:	711d                	addi	sp,sp,-96
 880:	ec06                	sd	ra,24(sp)
 882:	e822                	sd	s0,16(sp)
 884:	1000                	addi	s0,sp,32
 886:	e40c                	sd	a1,8(s0)
 888:	e810                	sd	a2,16(s0)
 88a:	ec14                	sd	a3,24(s0)
 88c:	f018                	sd	a4,32(s0)
 88e:	f41c                	sd	a5,40(s0)
 890:	03043823          	sd	a6,48(s0)
 894:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 898:	00840613          	addi	a2,s0,8
 89c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8a0:	85aa                	mv	a1,a0
 8a2:	4505                	li	a0,1
 8a4:	00000097          	auipc	ra,0x0
 8a8:	dce080e7          	jalr	-562(ra) # 672 <vprintf>
}
 8ac:	60e2                	ld	ra,24(sp)
 8ae:	6442                	ld	s0,16(sp)
 8b0:	6125                	addi	sp,sp,96
 8b2:	8082                	ret

00000000000008b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b4:	1141                	addi	sp,sp,-16
 8b6:	e422                	sd	s0,8(sp)
 8b8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ba:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8be:	00000797          	auipc	a5,0x0
 8c2:	7427b783          	ld	a5,1858(a5) # 1000 <freep>
 8c6:	a02d                	j	8f0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8c8:	4618                	lw	a4,8(a2)
 8ca:	9f2d                	addw	a4,a4,a1
 8cc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8d0:	6398                	ld	a4,0(a5)
 8d2:	6310                	ld	a2,0(a4)
 8d4:	a83d                	j	912 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8d6:	ff852703          	lw	a4,-8(a0)
 8da:	9f31                	addw	a4,a4,a2
 8dc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8de:	ff053683          	ld	a3,-16(a0)
 8e2:	a091                	j	926 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e4:	6398                	ld	a4,0(a5)
 8e6:	00e7e463          	bltu	a5,a4,8ee <free+0x3a>
 8ea:	00e6ea63          	bltu	a3,a4,8fe <free+0x4a>
{
 8ee:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f0:	fed7fae3          	bgeu	a5,a3,8e4 <free+0x30>
 8f4:	6398                	ld	a4,0(a5)
 8f6:	00e6e463          	bltu	a3,a4,8fe <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8fa:	fee7eae3          	bltu	a5,a4,8ee <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8fe:	ff852583          	lw	a1,-8(a0)
 902:	6390                	ld	a2,0(a5)
 904:	02059813          	slli	a6,a1,0x20
 908:	01c85713          	srli	a4,a6,0x1c
 90c:	9736                	add	a4,a4,a3
 90e:	fae60de3          	beq	a2,a4,8c8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 912:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 916:	4790                	lw	a2,8(a5)
 918:	02061593          	slli	a1,a2,0x20
 91c:	01c5d713          	srli	a4,a1,0x1c
 920:	973e                	add	a4,a4,a5
 922:	fae68ae3          	beq	a3,a4,8d6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 926:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 928:	00000717          	auipc	a4,0x0
 92c:	6cf73c23          	sd	a5,1752(a4) # 1000 <freep>
}
 930:	6422                	ld	s0,8(sp)
 932:	0141                	addi	sp,sp,16
 934:	8082                	ret

0000000000000936 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 936:	7139                	addi	sp,sp,-64
 938:	fc06                	sd	ra,56(sp)
 93a:	f822                	sd	s0,48(sp)
 93c:	f426                	sd	s1,40(sp)
 93e:	f04a                	sd	s2,32(sp)
 940:	ec4e                	sd	s3,24(sp)
 942:	e852                	sd	s4,16(sp)
 944:	e456                	sd	s5,8(sp)
 946:	e05a                	sd	s6,0(sp)
 948:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 94a:	02051493          	slli	s1,a0,0x20
 94e:	9081                	srli	s1,s1,0x20
 950:	04bd                	addi	s1,s1,15
 952:	8091                	srli	s1,s1,0x4
 954:	0014899b          	addiw	s3,s1,1
 958:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 95a:	00000517          	auipc	a0,0x0
 95e:	6a653503          	ld	a0,1702(a0) # 1000 <freep>
 962:	c515                	beqz	a0,98e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 964:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 966:	4798                	lw	a4,8(a5)
 968:	02977f63          	bgeu	a4,s1,9a6 <malloc+0x70>
 96c:	8a4e                	mv	s4,s3
 96e:	0009871b          	sext.w	a4,s3
 972:	6685                	lui	a3,0x1
 974:	00d77363          	bgeu	a4,a3,97a <malloc+0x44>
 978:	6a05                	lui	s4,0x1
 97a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 97e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 982:	00000917          	auipc	s2,0x0
 986:	67e90913          	addi	s2,s2,1662 # 1000 <freep>
  if(p == (char*)-1)
 98a:	5afd                	li	s5,-1
 98c:	a895                	j	a00 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 98e:	00001797          	auipc	a5,0x1
 992:	88278793          	addi	a5,a5,-1918 # 1210 <base>
 996:	00000717          	auipc	a4,0x0
 99a:	66f73523          	sd	a5,1642(a4) # 1000 <freep>
 99e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9a0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9a4:	b7e1                	j	96c <malloc+0x36>
      if(p->s.size == nunits)
 9a6:	02e48c63          	beq	s1,a4,9de <malloc+0xa8>
        p->s.size -= nunits;
 9aa:	4137073b          	subw	a4,a4,s3
 9ae:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9b0:	02071693          	slli	a3,a4,0x20
 9b4:	01c6d713          	srli	a4,a3,0x1c
 9b8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9ba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9be:	00000717          	auipc	a4,0x0
 9c2:	64a73123          	sd	a0,1602(a4) # 1000 <freep>
      return (void*)(p + 1);
 9c6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9ca:	70e2                	ld	ra,56(sp)
 9cc:	7442                	ld	s0,48(sp)
 9ce:	74a2                	ld	s1,40(sp)
 9d0:	7902                	ld	s2,32(sp)
 9d2:	69e2                	ld	s3,24(sp)
 9d4:	6a42                	ld	s4,16(sp)
 9d6:	6aa2                	ld	s5,8(sp)
 9d8:	6b02                	ld	s6,0(sp)
 9da:	6121                	addi	sp,sp,64
 9dc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9de:	6398                	ld	a4,0(a5)
 9e0:	e118                	sd	a4,0(a0)
 9e2:	bff1                	j	9be <malloc+0x88>
  hp->s.size = nu;
 9e4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9e8:	0541                	addi	a0,a0,16
 9ea:	00000097          	auipc	ra,0x0
 9ee:	eca080e7          	jalr	-310(ra) # 8b4 <free>
  return freep;
 9f2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9f6:	d971                	beqz	a0,9ca <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9fa:	4798                	lw	a4,8(a5)
 9fc:	fa9775e3          	bgeu	a4,s1,9a6 <malloc+0x70>
    if(p == freep)
 a00:	00093703          	ld	a4,0(s2)
 a04:	853e                	mv	a0,a5
 a06:	fef719e3          	bne	a4,a5,9f8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a0a:	8552                	mv	a0,s4
 a0c:	00000097          	auipc	ra,0x0
 a10:	b78080e7          	jalr	-1160(ra) # 584 <sbrk>
  if(p == (char*)-1)
 a14:	fd5518e3          	bne	a0,s5,9e4 <malloc+0xae>
        return 0;
 a18:	4501                	li	a0,0
 a1a:	bf45                	j	9ca <malloc+0x94>
