
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
  44:	9e058593          	addi	a1,a1,-1568 # a20 <malloc+0xf2>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	7fe080e7          	jalr	2046(ra) # 848 <fprintf>
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
  72:	9ca58593          	addi	a1,a1,-1590 # a38 <malloc+0x10a>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	7d0080e7          	jalr	2000(ra) # 848 <fprintf>
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
  aa:	9aa50513          	addi	a0,a0,-1622 # a50 <malloc+0x122>
  ae:	00000097          	auipc	ra,0x0
  b2:	7c8080e7          	jalr	1992(ra) # 876 <printf>
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
  ce:	966b0b13          	addi	s6,s6,-1690 # a30 <malloc+0x102>
			printf("%d \t",c);
  d2:	00001b97          	auipc	s7,0x1
  d6:	98eb8b93          	addi	s7,s7,-1650 # a60 <malloc+0x132>
			printf("%c",buf[i]);
  da:	00001a97          	auipc	s5,0x1
  de:	97ea8a93          	addi	s5,s5,-1666 # a58 <malloc+0x12a>
  while((n=read(fd,buf,sizeof(buf)))>0){ 
  e2:	a83d                	j	120 <cat_n+0x96>
			c++;
  e4:	2905                	addiw	s2,s2,1 # 1011 <buf+0x1>
			printf("\n");
  e6:	855a                	mv	a0,s6
  e8:	00000097          	auipc	ra,0x0
  ec:	78e080e7          	jalr	1934(ra) # 876 <printf>
			printf("%d \t",c);
  f0:	85ca                	mv	a1,s2
  f2:	855e                	mv	a0,s7
  f4:	00000097          	auipc	ra,0x0
  f8:	782080e7          	jalr	1922(ra) # 876 <printf>
 	for(int i=0;i<sizeof(buf);i++){
  fc:	0485                	addi	s1,s1,1
  fe:	01448c63          	beq	s1,s4,116 <cat_n+0x8c>
		if(buf[i] != '\n'){
 102:	0004c583          	lbu	a1,0(s1)
 106:	fd358fe3          	beq	a1,s3,e4 <cat_n+0x5a>
			printf("%c",buf[i]);
 10a:	8556                	mv	a0,s5
 10c:	00000097          	auipc	ra,0x0
 110:	76a080e7          	jalr	1898(ra) # 876 <printf>
 114:	b7e5                	j	fc <cat_n+0x72>
		}
	}
	printf("\n");
 116:	855a                	mv	a0,s6
 118:	00000097          	auipc	ra,0x0
 11c:	75e080e7          	jalr	1886(ra) # 876 <printf>
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
 22a:	84258593          	addi	a1,a1,-1982 # a68 <malloc+0x13a>
 22e:	4509                	li	a0,2
 230:	00000097          	auipc	ra,0x0
 234:	618080e7          	jalr	1560(ra) # 848 <fprintf>
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
 25e:	80e58593          	addi	a1,a1,-2034 # a68 <malloc+0x13a>
 262:	4509                	li	a0,2
 264:	00000097          	auipc	ra,0x0
 268:	5e4080e7          	jalr	1508(ra) # 848 <fprintf>
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

000000000000059c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 59c:	1101                	addi	sp,sp,-32
 59e:	ec06                	sd	ra,24(sp)
 5a0:	e822                	sd	s0,16(sp)
 5a2:	1000                	addi	s0,sp,32
 5a4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5a8:	4605                	li	a2,1
 5aa:	fef40593          	addi	a1,s0,-17
 5ae:	00000097          	auipc	ra,0x0
 5b2:	f6e080e7          	jalr	-146(ra) # 51c <write>
}
 5b6:	60e2                	ld	ra,24(sp)
 5b8:	6442                	ld	s0,16(sp)
 5ba:	6105                	addi	sp,sp,32
 5bc:	8082                	ret

00000000000005be <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5be:	7139                	addi	sp,sp,-64
 5c0:	fc06                	sd	ra,56(sp)
 5c2:	f822                	sd	s0,48(sp)
 5c4:	f426                	sd	s1,40(sp)
 5c6:	f04a                	sd	s2,32(sp)
 5c8:	ec4e                	sd	s3,24(sp)
 5ca:	0080                	addi	s0,sp,64
 5cc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5ce:	c299                	beqz	a3,5d4 <printint+0x16>
 5d0:	0805c963          	bltz	a1,662 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5d4:	2581                	sext.w	a1,a1
  neg = 0;
 5d6:	4881                	li	a7,0
 5d8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5dc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5de:	2601                	sext.w	a2,a2
 5e0:	00000517          	auipc	a0,0x0
 5e4:	50050513          	addi	a0,a0,1280 # ae0 <digits>
 5e8:	883a                	mv	a6,a4
 5ea:	2705                	addiw	a4,a4,1
 5ec:	02c5f7bb          	remuw	a5,a1,a2
 5f0:	1782                	slli	a5,a5,0x20
 5f2:	9381                	srli	a5,a5,0x20
 5f4:	97aa                	add	a5,a5,a0
 5f6:	0007c783          	lbu	a5,0(a5)
 5fa:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5fe:	0005879b          	sext.w	a5,a1
 602:	02c5d5bb          	divuw	a1,a1,a2
 606:	0685                	addi	a3,a3,1
 608:	fec7f0e3          	bgeu	a5,a2,5e8 <printint+0x2a>
  if(neg)
 60c:	00088c63          	beqz	a7,624 <printint+0x66>
    buf[i++] = '-';
 610:	fd070793          	addi	a5,a4,-48
 614:	00878733          	add	a4,a5,s0
 618:	02d00793          	li	a5,45
 61c:	fef70823          	sb	a5,-16(a4)
 620:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 624:	02e05863          	blez	a4,654 <printint+0x96>
 628:	fc040793          	addi	a5,s0,-64
 62c:	00e78933          	add	s2,a5,a4
 630:	fff78993          	addi	s3,a5,-1
 634:	99ba                	add	s3,s3,a4
 636:	377d                	addiw	a4,a4,-1
 638:	1702                	slli	a4,a4,0x20
 63a:	9301                	srli	a4,a4,0x20
 63c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 640:	fff94583          	lbu	a1,-1(s2)
 644:	8526                	mv	a0,s1
 646:	00000097          	auipc	ra,0x0
 64a:	f56080e7          	jalr	-170(ra) # 59c <putc>
  while(--i >= 0)
 64e:	197d                	addi	s2,s2,-1
 650:	ff3918e3          	bne	s2,s3,640 <printint+0x82>
}
 654:	70e2                	ld	ra,56(sp)
 656:	7442                	ld	s0,48(sp)
 658:	74a2                	ld	s1,40(sp)
 65a:	7902                	ld	s2,32(sp)
 65c:	69e2                	ld	s3,24(sp)
 65e:	6121                	addi	sp,sp,64
 660:	8082                	ret
    x = -xx;
 662:	40b005bb          	negw	a1,a1
    neg = 1;
 666:	4885                	li	a7,1
    x = -xx;
 668:	bf85                	j	5d8 <printint+0x1a>

000000000000066a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 66a:	7119                	addi	sp,sp,-128
 66c:	fc86                	sd	ra,120(sp)
 66e:	f8a2                	sd	s0,112(sp)
 670:	f4a6                	sd	s1,104(sp)
 672:	f0ca                	sd	s2,96(sp)
 674:	ecce                	sd	s3,88(sp)
 676:	e8d2                	sd	s4,80(sp)
 678:	e4d6                	sd	s5,72(sp)
 67a:	e0da                	sd	s6,64(sp)
 67c:	fc5e                	sd	s7,56(sp)
 67e:	f862                	sd	s8,48(sp)
 680:	f466                	sd	s9,40(sp)
 682:	f06a                	sd	s10,32(sp)
 684:	ec6e                	sd	s11,24(sp)
 686:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 688:	0005c903          	lbu	s2,0(a1)
 68c:	18090f63          	beqz	s2,82a <vprintf+0x1c0>
 690:	8aaa                	mv	s5,a0
 692:	8b32                	mv	s6,a2
 694:	00158493          	addi	s1,a1,1
  state = 0;
 698:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 69a:	02500a13          	li	s4,37
 69e:	4c55                	li	s8,21
 6a0:	00000c97          	auipc	s9,0x0
 6a4:	3e8c8c93          	addi	s9,s9,1000 # a88 <malloc+0x15a>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6a8:	02800d93          	li	s11,40
  putc(fd, 'x');
 6ac:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ae:	00000b97          	auipc	s7,0x0
 6b2:	432b8b93          	addi	s7,s7,1074 # ae0 <digits>
 6b6:	a839                	j	6d4 <vprintf+0x6a>
        putc(fd, c);
 6b8:	85ca                	mv	a1,s2
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	ee0080e7          	jalr	-288(ra) # 59c <putc>
 6c4:	a019                	j	6ca <vprintf+0x60>
    } else if(state == '%'){
 6c6:	01498d63          	beq	s3,s4,6e0 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 6ca:	0485                	addi	s1,s1,1
 6cc:	fff4c903          	lbu	s2,-1(s1)
 6d0:	14090d63          	beqz	s2,82a <vprintf+0x1c0>
    if(state == 0){
 6d4:	fe0999e3          	bnez	s3,6c6 <vprintf+0x5c>
      if(c == '%'){
 6d8:	ff4910e3          	bne	s2,s4,6b8 <vprintf+0x4e>
        state = '%';
 6dc:	89d2                	mv	s3,s4
 6de:	b7f5                	j	6ca <vprintf+0x60>
      if(c == 'd'){
 6e0:	11490c63          	beq	s2,s4,7f8 <vprintf+0x18e>
 6e4:	f9d9079b          	addiw	a5,s2,-99
 6e8:	0ff7f793          	zext.b	a5,a5
 6ec:	10fc6e63          	bltu	s8,a5,808 <vprintf+0x19e>
 6f0:	f9d9079b          	addiw	a5,s2,-99
 6f4:	0ff7f713          	zext.b	a4,a5
 6f8:	10ec6863          	bltu	s8,a4,808 <vprintf+0x19e>
 6fc:	00271793          	slli	a5,a4,0x2
 700:	97e6                	add	a5,a5,s9
 702:	439c                	lw	a5,0(a5)
 704:	97e6                	add	a5,a5,s9
 706:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 708:	008b0913          	addi	s2,s6,8
 70c:	4685                	li	a3,1
 70e:	4629                	li	a2,10
 710:	000b2583          	lw	a1,0(s6)
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	ea8080e7          	jalr	-344(ra) # 5be <printint>
 71e:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 720:	4981                	li	s3,0
 722:	b765                	j	6ca <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 724:	008b0913          	addi	s2,s6,8
 728:	4681                	li	a3,0
 72a:	4629                	li	a2,10
 72c:	000b2583          	lw	a1,0(s6)
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	e8c080e7          	jalr	-372(ra) # 5be <printint>
 73a:	8b4a                	mv	s6,s2
      state = 0;
 73c:	4981                	li	s3,0
 73e:	b771                	j	6ca <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 740:	008b0913          	addi	s2,s6,8
 744:	4681                	li	a3,0
 746:	866a                	mv	a2,s10
 748:	000b2583          	lw	a1,0(s6)
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	e70080e7          	jalr	-400(ra) # 5be <printint>
 756:	8b4a                	mv	s6,s2
      state = 0;
 758:	4981                	li	s3,0
 75a:	bf85                	j	6ca <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 75c:	008b0793          	addi	a5,s6,8
 760:	f8f43423          	sd	a5,-120(s0)
 764:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 768:	03000593          	li	a1,48
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	e2e080e7          	jalr	-466(ra) # 59c <putc>
  putc(fd, 'x');
 776:	07800593          	li	a1,120
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	e20080e7          	jalr	-480(ra) # 59c <putc>
 784:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 786:	03c9d793          	srli	a5,s3,0x3c
 78a:	97de                	add	a5,a5,s7
 78c:	0007c583          	lbu	a1,0(a5)
 790:	8556                	mv	a0,s5
 792:	00000097          	auipc	ra,0x0
 796:	e0a080e7          	jalr	-502(ra) # 59c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 79a:	0992                	slli	s3,s3,0x4
 79c:	397d                	addiw	s2,s2,-1
 79e:	fe0914e3          	bnez	s2,786 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 7a2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	b70d                	j	6ca <vprintf+0x60>
        s = va_arg(ap, char*);
 7aa:	008b0913          	addi	s2,s6,8
 7ae:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 7b2:	02098163          	beqz	s3,7d4 <vprintf+0x16a>
        while(*s != 0){
 7b6:	0009c583          	lbu	a1,0(s3)
 7ba:	c5ad                	beqz	a1,824 <vprintf+0x1ba>
          putc(fd, *s);
 7bc:	8556                	mv	a0,s5
 7be:	00000097          	auipc	ra,0x0
 7c2:	dde080e7          	jalr	-546(ra) # 59c <putc>
          s++;
 7c6:	0985                	addi	s3,s3,1
        while(*s != 0){
 7c8:	0009c583          	lbu	a1,0(s3)
 7cc:	f9e5                	bnez	a1,7bc <vprintf+0x152>
        s = va_arg(ap, char*);
 7ce:	8b4a                	mv	s6,s2
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	bde5                	j	6ca <vprintf+0x60>
          s = "(null)";
 7d4:	00000997          	auipc	s3,0x0
 7d8:	2ac98993          	addi	s3,s3,684 # a80 <malloc+0x152>
        while(*s != 0){
 7dc:	85ee                	mv	a1,s11
 7de:	bff9                	j	7bc <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 7e0:	008b0913          	addi	s2,s6,8
 7e4:	000b4583          	lbu	a1,0(s6)
 7e8:	8556                	mv	a0,s5
 7ea:	00000097          	auipc	ra,0x0
 7ee:	db2080e7          	jalr	-590(ra) # 59c <putc>
 7f2:	8b4a                	mv	s6,s2
      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	bdd1                	j	6ca <vprintf+0x60>
        putc(fd, c);
 7f8:	85d2                	mv	a1,s4
 7fa:	8556                	mv	a0,s5
 7fc:	00000097          	auipc	ra,0x0
 800:	da0080e7          	jalr	-608(ra) # 59c <putc>
      state = 0;
 804:	4981                	li	s3,0
 806:	b5d1                	j	6ca <vprintf+0x60>
        putc(fd, '%');
 808:	85d2                	mv	a1,s4
 80a:	8556                	mv	a0,s5
 80c:	00000097          	auipc	ra,0x0
 810:	d90080e7          	jalr	-624(ra) # 59c <putc>
        putc(fd, c);
 814:	85ca                	mv	a1,s2
 816:	8556                	mv	a0,s5
 818:	00000097          	auipc	ra,0x0
 81c:	d84080e7          	jalr	-636(ra) # 59c <putc>
      state = 0;
 820:	4981                	li	s3,0
 822:	b565                	j	6ca <vprintf+0x60>
        s = va_arg(ap, char*);
 824:	8b4a                	mv	s6,s2
      state = 0;
 826:	4981                	li	s3,0
 828:	b54d                	j	6ca <vprintf+0x60>
    }
  }
}
 82a:	70e6                	ld	ra,120(sp)
 82c:	7446                	ld	s0,112(sp)
 82e:	74a6                	ld	s1,104(sp)
 830:	7906                	ld	s2,96(sp)
 832:	69e6                	ld	s3,88(sp)
 834:	6a46                	ld	s4,80(sp)
 836:	6aa6                	ld	s5,72(sp)
 838:	6b06                	ld	s6,64(sp)
 83a:	7be2                	ld	s7,56(sp)
 83c:	7c42                	ld	s8,48(sp)
 83e:	7ca2                	ld	s9,40(sp)
 840:	7d02                	ld	s10,32(sp)
 842:	6de2                	ld	s11,24(sp)
 844:	6109                	addi	sp,sp,128
 846:	8082                	ret

0000000000000848 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 848:	715d                	addi	sp,sp,-80
 84a:	ec06                	sd	ra,24(sp)
 84c:	e822                	sd	s0,16(sp)
 84e:	1000                	addi	s0,sp,32
 850:	e010                	sd	a2,0(s0)
 852:	e414                	sd	a3,8(s0)
 854:	e818                	sd	a4,16(s0)
 856:	ec1c                	sd	a5,24(s0)
 858:	03043023          	sd	a6,32(s0)
 85c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 860:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 864:	8622                	mv	a2,s0
 866:	00000097          	auipc	ra,0x0
 86a:	e04080e7          	jalr	-508(ra) # 66a <vprintf>
}
 86e:	60e2                	ld	ra,24(sp)
 870:	6442                	ld	s0,16(sp)
 872:	6161                	addi	sp,sp,80
 874:	8082                	ret

0000000000000876 <printf>:

void
printf(const char *fmt, ...)
{
 876:	711d                	addi	sp,sp,-96
 878:	ec06                	sd	ra,24(sp)
 87a:	e822                	sd	s0,16(sp)
 87c:	1000                	addi	s0,sp,32
 87e:	e40c                	sd	a1,8(s0)
 880:	e810                	sd	a2,16(s0)
 882:	ec14                	sd	a3,24(s0)
 884:	f018                	sd	a4,32(s0)
 886:	f41c                	sd	a5,40(s0)
 888:	03043823          	sd	a6,48(s0)
 88c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 890:	00840613          	addi	a2,s0,8
 894:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 898:	85aa                	mv	a1,a0
 89a:	4505                	li	a0,1
 89c:	00000097          	auipc	ra,0x0
 8a0:	dce080e7          	jalr	-562(ra) # 66a <vprintf>
}
 8a4:	60e2                	ld	ra,24(sp)
 8a6:	6442                	ld	s0,16(sp)
 8a8:	6125                	addi	sp,sp,96
 8aa:	8082                	ret

00000000000008ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ac:	1141                	addi	sp,sp,-16
 8ae:	e422                	sd	s0,8(sp)
 8b0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8b2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b6:	00000797          	auipc	a5,0x0
 8ba:	74a7b783          	ld	a5,1866(a5) # 1000 <freep>
 8be:	a02d                	j	8e8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8c0:	4618                	lw	a4,8(a2)
 8c2:	9f2d                	addw	a4,a4,a1
 8c4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c8:	6398                	ld	a4,0(a5)
 8ca:	6310                	ld	a2,0(a4)
 8cc:	a83d                	j	90a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ce:	ff852703          	lw	a4,-8(a0)
 8d2:	9f31                	addw	a4,a4,a2
 8d4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8d6:	ff053683          	ld	a3,-16(a0)
 8da:	a091                	j	91e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8dc:	6398                	ld	a4,0(a5)
 8de:	00e7e463          	bltu	a5,a4,8e6 <free+0x3a>
 8e2:	00e6ea63          	bltu	a3,a4,8f6 <free+0x4a>
{
 8e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e8:	fed7fae3          	bgeu	a5,a3,8dc <free+0x30>
 8ec:	6398                	ld	a4,0(a5)
 8ee:	00e6e463          	bltu	a3,a4,8f6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f2:	fee7eae3          	bltu	a5,a4,8e6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8f6:	ff852583          	lw	a1,-8(a0)
 8fa:	6390                	ld	a2,0(a5)
 8fc:	02059813          	slli	a6,a1,0x20
 900:	01c85713          	srli	a4,a6,0x1c
 904:	9736                	add	a4,a4,a3
 906:	fae60de3          	beq	a2,a4,8c0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 90a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 90e:	4790                	lw	a2,8(a5)
 910:	02061593          	slli	a1,a2,0x20
 914:	01c5d713          	srli	a4,a1,0x1c
 918:	973e                	add	a4,a4,a5
 91a:	fae68ae3          	beq	a3,a4,8ce <free+0x22>
    p->s.ptr = bp->s.ptr;
 91e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 920:	00000717          	auipc	a4,0x0
 924:	6ef73023          	sd	a5,1760(a4) # 1000 <freep>
}
 928:	6422                	ld	s0,8(sp)
 92a:	0141                	addi	sp,sp,16
 92c:	8082                	ret

000000000000092e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 92e:	7139                	addi	sp,sp,-64
 930:	fc06                	sd	ra,56(sp)
 932:	f822                	sd	s0,48(sp)
 934:	f426                	sd	s1,40(sp)
 936:	f04a                	sd	s2,32(sp)
 938:	ec4e                	sd	s3,24(sp)
 93a:	e852                	sd	s4,16(sp)
 93c:	e456                	sd	s5,8(sp)
 93e:	e05a                	sd	s6,0(sp)
 940:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 942:	02051493          	slli	s1,a0,0x20
 946:	9081                	srli	s1,s1,0x20
 948:	04bd                	addi	s1,s1,15
 94a:	8091                	srli	s1,s1,0x4
 94c:	0014899b          	addiw	s3,s1,1
 950:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 952:	00000517          	auipc	a0,0x0
 956:	6ae53503          	ld	a0,1710(a0) # 1000 <freep>
 95a:	c515                	beqz	a0,986 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95e:	4798                	lw	a4,8(a5)
 960:	02977f63          	bgeu	a4,s1,99e <malloc+0x70>
 964:	8a4e                	mv	s4,s3
 966:	0009871b          	sext.w	a4,s3
 96a:	6685                	lui	a3,0x1
 96c:	00d77363          	bgeu	a4,a3,972 <malloc+0x44>
 970:	6a05                	lui	s4,0x1
 972:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 976:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 97a:	00000917          	auipc	s2,0x0
 97e:	68690913          	addi	s2,s2,1670 # 1000 <freep>
  if(p == (char*)-1)
 982:	5afd                	li	s5,-1
 984:	a895                	j	9f8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 986:	00001797          	auipc	a5,0x1
 98a:	88a78793          	addi	a5,a5,-1910 # 1210 <base>
 98e:	00000717          	auipc	a4,0x0
 992:	66f73923          	sd	a5,1650(a4) # 1000 <freep>
 996:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 998:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 99c:	b7e1                	j	964 <malloc+0x36>
      if(p->s.size == nunits)
 99e:	02e48c63          	beq	s1,a4,9d6 <malloc+0xa8>
        p->s.size -= nunits;
 9a2:	4137073b          	subw	a4,a4,s3
 9a6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9a8:	02071693          	slli	a3,a4,0x20
 9ac:	01c6d713          	srli	a4,a3,0x1c
 9b0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9b2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9b6:	00000717          	auipc	a4,0x0
 9ba:	64a73523          	sd	a0,1610(a4) # 1000 <freep>
      return (void*)(p + 1);
 9be:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9c2:	70e2                	ld	ra,56(sp)
 9c4:	7442                	ld	s0,48(sp)
 9c6:	74a2                	ld	s1,40(sp)
 9c8:	7902                	ld	s2,32(sp)
 9ca:	69e2                	ld	s3,24(sp)
 9cc:	6a42                	ld	s4,16(sp)
 9ce:	6aa2                	ld	s5,8(sp)
 9d0:	6b02                	ld	s6,0(sp)
 9d2:	6121                	addi	sp,sp,64
 9d4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9d6:	6398                	ld	a4,0(a5)
 9d8:	e118                	sd	a4,0(a0)
 9da:	bff1                	j	9b6 <malloc+0x88>
  hp->s.size = nu;
 9dc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9e0:	0541                	addi	a0,a0,16
 9e2:	00000097          	auipc	ra,0x0
 9e6:	eca080e7          	jalr	-310(ra) # 8ac <free>
  return freep;
 9ea:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ee:	d971                	beqz	a0,9c2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f2:	4798                	lw	a4,8(a5)
 9f4:	fa9775e3          	bgeu	a4,s1,99e <malloc+0x70>
    if(p == freep)
 9f8:	00093703          	ld	a4,0(s2)
 9fc:	853e                	mv	a0,a5
 9fe:	fef719e3          	bne	a4,a5,9f0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a02:	8552                	mv	a0,s4
 a04:	00000097          	auipc	ra,0x0
 a08:	b80080e7          	jalr	-1152(ra) # 584 <sbrk>
  if(p == (char*)-1)
 a0c:	fd5518e3          	bne	a0,s5,9dc <malloc+0xae>
        return 0;
 a10:	4501                	li	a0,0
 a12:	bf45                	j	9c2 <malloc+0x94>
