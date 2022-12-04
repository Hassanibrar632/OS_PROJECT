
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	572080e7          	jalr	1394(ra) # 582 <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	546080e7          	jalr	1350(ra) # 582 <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	524080e7          	jalr	1316(ra) # 582 <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	faa98993          	addi	s3,s3,-86 # 1010 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	67e080e7          	jalr	1662(ra) # 6f4 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	502080e7          	jalr	1282(ra) # 582 <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	4f4080e7          	jalr	1268(ra) # 582 <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	504080e7          	jalr	1284(ra) # 5ac <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	addi	s0,sp,624
  d6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  d8:	4581                	li	a1,0
  da:	00000097          	auipc	ra,0x0
  de:	70c080e7          	jalr	1804(ra) # 7e6 <open>
  e2:	08054163          	bltz	a0,164 <ls+0xb0>
  e6:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  e8:	d9840593          	addi	a1,s0,-616
  ec:	00000097          	auipc	ra,0x0
  f0:	712080e7          	jalr	1810(ra) # 7fe <fstat>
  f4:	08054363          	bltz	a0,17a <ls+0xc6>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  f8:	da041783          	lh	a5,-608(s0)
  fc:	0007869b          	sext.w	a3,a5
 100:	4705                	li	a4,1
 102:	08e68c63          	beq	a3,a4,19a <ls+0xe6>
 106:	37f9                	addiw	a5,a5,-2
 108:	17c2                	slli	a5,a5,0x30
 10a:	93c1                	srli	a5,a5,0x30
 10c:	02f76663          	bltu	a4,a5,138 <ls+0x84>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 110:	854a                	mv	a0,s2
 112:	00000097          	auipc	ra,0x0
 116:	eee080e7          	jalr	-274(ra) # 0 <fmtname>
 11a:	85aa                	mv	a1,a0
 11c:	da843703          	ld	a4,-600(s0)
 120:	d9c42683          	lw	a3,-612(s0)
 124:	da041603          	lh	a2,-608(s0)
 128:	00001517          	auipc	a0,0x1
 12c:	bd850513          	addi	a0,a0,-1064 # d00 <malloc+0x120>
 130:	00001097          	auipc	ra,0x1
 134:	9f8080e7          	jalr	-1544(ra) # b28 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 138:	8526                	mv	a0,s1
 13a:	00000097          	auipc	ra,0x0
 13e:	694080e7          	jalr	1684(ra) # 7ce <close>
}
 142:	26813083          	ld	ra,616(sp)
 146:	26013403          	ld	s0,608(sp)
 14a:	25813483          	ld	s1,600(sp)
 14e:	25013903          	ld	s2,592(sp)
 152:	24813983          	ld	s3,584(sp)
 156:	24013a03          	ld	s4,576(sp)
 15a:	23813a83          	ld	s5,568(sp)
 15e:	27010113          	addi	sp,sp,624
 162:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 164:	864a                	mv	a2,s2
 166:	00001597          	auipc	a1,0x1
 16a:	b6a58593          	addi	a1,a1,-1174 # cd0 <malloc+0xf0>
 16e:	4509                	li	a0,2
 170:	00001097          	auipc	ra,0x1
 174:	98a080e7          	jalr	-1654(ra) # afa <fprintf>
    return;
 178:	b7e9                	j	142 <ls+0x8e>
    fprintf(2, "ls: cannot stat %s\n", path);
 17a:	864a                	mv	a2,s2
 17c:	00001597          	auipc	a1,0x1
 180:	b6c58593          	addi	a1,a1,-1172 # ce8 <malloc+0x108>
 184:	4509                	li	a0,2
 186:	00001097          	auipc	ra,0x1
 18a:	974080e7          	jalr	-1676(ra) # afa <fprintf>
    close(fd);
 18e:	8526                	mv	a0,s1
 190:	00000097          	auipc	ra,0x0
 194:	63e080e7          	jalr	1598(ra) # 7ce <close>
    return;
 198:	b76d                	j	142 <ls+0x8e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 19a:	854a                	mv	a0,s2
 19c:	00000097          	auipc	ra,0x0
 1a0:	3e6080e7          	jalr	998(ra) # 582 <strlen>
 1a4:	2541                	addiw	a0,a0,16
 1a6:	20000793          	li	a5,512
 1aa:	00a7fb63          	bgeu	a5,a0,1c0 <ls+0x10c>
      printf("ls: path too long\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	b6250513          	addi	a0,a0,-1182 # d10 <malloc+0x130>
 1b6:	00001097          	auipc	ra,0x1
 1ba:	972080e7          	jalr	-1678(ra) # b28 <printf>
      break;
 1be:	bfad                	j	138 <ls+0x84>
    strcpy(buf, path);
 1c0:	85ca                	mv	a1,s2
 1c2:	dc040513          	addi	a0,s0,-576
 1c6:	00000097          	auipc	ra,0x0
 1ca:	374080e7          	jalr	884(ra) # 53a <strcpy>
    p = buf+strlen(buf);
 1ce:	dc040513          	addi	a0,s0,-576
 1d2:	00000097          	auipc	ra,0x0
 1d6:	3b0080e7          	jalr	944(ra) # 582 <strlen>
 1da:	1502                	slli	a0,a0,0x20
 1dc:	9101                	srli	a0,a0,0x20
 1de:	dc040793          	addi	a5,s0,-576
 1e2:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 1e6:	00190993          	addi	s3,s2,1
 1ea:	02f00793          	li	a5,47
 1ee:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 1f2:	00001a17          	auipc	s4,0x1
 1f6:	b36a0a13          	addi	s4,s4,-1226 # d28 <malloc+0x148>
        printf("ls: cannot stat %s\n", buf);
 1fa:	00001a97          	auipc	s5,0x1
 1fe:	aeea8a93          	addi	s5,s5,-1298 # ce8 <malloc+0x108>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 202:	a801                	j	212 <ls+0x15e>
        printf("ls: cannot stat %s\n", buf);
 204:	dc040593          	addi	a1,s0,-576
 208:	8556                	mv	a0,s5
 20a:	00001097          	auipc	ra,0x1
 20e:	91e080e7          	jalr	-1762(ra) # b28 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 212:	4641                	li	a2,16
 214:	db040593          	addi	a1,s0,-592
 218:	8526                	mv	a0,s1
 21a:	00000097          	auipc	ra,0x0
 21e:	5a4080e7          	jalr	1444(ra) # 7be <read>
 222:	47c1                	li	a5,16
 224:	f0f51ae3          	bne	a0,a5,138 <ls+0x84>
      if(de.inum == 0)
 228:	db045783          	lhu	a5,-592(s0)
 22c:	d3fd                	beqz	a5,212 <ls+0x15e>
      memmove(p, de.name, DIRSIZ);
 22e:	4639                	li	a2,14
 230:	db240593          	addi	a1,s0,-590
 234:	854e                	mv	a0,s3
 236:	00000097          	auipc	ra,0x0
 23a:	4be080e7          	jalr	1214(ra) # 6f4 <memmove>
      p[DIRSIZ] = 0;
 23e:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 242:	d9840593          	addi	a1,s0,-616
 246:	dc040513          	addi	a0,s0,-576
 24a:	00000097          	auipc	ra,0x0
 24e:	41c080e7          	jalr	1052(ra) # 666 <stat>
 252:	fa0549e3          	bltz	a0,204 <ls+0x150>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 256:	dc040513          	addi	a0,s0,-576
 25a:	00000097          	auipc	ra,0x0
 25e:	da6080e7          	jalr	-602(ra) # 0 <fmtname>
 262:	85aa                	mv	a1,a0
 264:	da843703          	ld	a4,-600(s0)
 268:	d9c42683          	lw	a3,-612(s0)
 26c:	da041603          	lh	a2,-608(s0)
 270:	8552                	mv	a0,s4
 272:	00001097          	auipc	ra,0x1
 276:	8b6080e7          	jalr	-1866(ra) # b28 <printf>
 27a:	bf61                	j	212 <ls+0x15e>

000000000000027c <ls_n>:

void
ls_n(char *path)
{
 27c:	d8010113          	addi	sp,sp,-640
 280:	26113c23          	sd	ra,632(sp)
 284:	26813823          	sd	s0,624(sp)
 288:	26913423          	sd	s1,616(sp)
 28c:	27213023          	sd	s2,608(sp)
 290:	25313c23          	sd	s3,600(sp)
 294:	25413823          	sd	s4,592(sp)
 298:	25513423          	sd	s5,584(sp)
 29c:	25613023          	sd	s6,576(sp)
 2a0:	23713c23          	sd	s7,568(sp)
 2a4:	0500                	addi	s0,sp,640
 2a6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd, counter = 1;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
 2a8:	4581                	li	a1,0
 2aa:	00000097          	auipc	ra,0x0
 2ae:	53c080e7          	jalr	1340(ra) # 7e6 <open>
 2b2:	08054663          	bltz	a0,33e <ls_n+0xc2>
 2b6:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
 2b8:	d8840593          	addi	a1,s0,-632
 2bc:	00000097          	auipc	ra,0x0
 2c0:	542080e7          	jalr	1346(ra) # 7fe <fstat>
 2c4:	08054863          	bltz	a0,354 <ls_n+0xd8>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
 2c8:	d9041783          	lh	a5,-624(s0)
 2cc:	0007869b          	sext.w	a3,a5
 2d0:	4705                	li	a4,1
 2d2:	0ae68163          	beq	a3,a4,374 <ls_n+0xf8>
 2d6:	37f9                	addiw	a5,a5,-2
 2d8:	17c2                	slli	a5,a5,0x30
 2da:	93c1                	srli	a5,a5,0x30
 2dc:	02f76763          	bltu	a4,a5,30a <ls_n+0x8e>
  case T_DEVICE:
  case T_FILE:
    printf("%d %s %d %d %l\n", counter++, fmtname(path), st.type, st.ino, st.size);
 2e0:	854a                	mv	a0,s2
 2e2:	00000097          	auipc	ra,0x0
 2e6:	d1e080e7          	jalr	-738(ra) # 0 <fmtname>
 2ea:	862a                	mv	a2,a0
 2ec:	d9843783          	ld	a5,-616(s0)
 2f0:	d8c42703          	lw	a4,-628(s0)
 2f4:	d9041683          	lh	a3,-624(s0)
 2f8:	4585                	li	a1,1
 2fa:	00001517          	auipc	a0,0x1
 2fe:	a3e50513          	addi	a0,a0,-1474 # d38 <malloc+0x158>
 302:	00001097          	auipc	ra,0x1
 306:	826080e7          	jalr	-2010(ra) # b28 <printf>
      }
      printf("%d %s %d %d %d\n", counter++, fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 30a:	8526                	mv	a0,s1
 30c:	00000097          	auipc	ra,0x0
 310:	4c2080e7          	jalr	1218(ra) # 7ce <close>
}
 314:	27813083          	ld	ra,632(sp)
 318:	27013403          	ld	s0,624(sp)
 31c:	26813483          	ld	s1,616(sp)
 320:	26013903          	ld	s2,608(sp)
 324:	25813983          	ld	s3,600(sp)
 328:	25013a03          	ld	s4,592(sp)
 32c:	24813a83          	ld	s5,584(sp)
 330:	24013b03          	ld	s6,576(sp)
 334:	23813b83          	ld	s7,568(sp)
 338:	28010113          	addi	sp,sp,640
 33c:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 33e:	864a                	mv	a2,s2
 340:	00001597          	auipc	a1,0x1
 344:	99058593          	addi	a1,a1,-1648 # cd0 <malloc+0xf0>
 348:	4509                	li	a0,2
 34a:	00000097          	auipc	ra,0x0
 34e:	7b0080e7          	jalr	1968(ra) # afa <fprintf>
    return;
 352:	b7c9                	j	314 <ls_n+0x98>
    fprintf(2, "ls: cannot stat %s\n", path);
 354:	864a                	mv	a2,s2
 356:	00001597          	auipc	a1,0x1
 35a:	99258593          	addi	a1,a1,-1646 # ce8 <malloc+0x108>
 35e:	4509                	li	a0,2
 360:	00000097          	auipc	ra,0x0
 364:	79a080e7          	jalr	1946(ra) # afa <fprintf>
    close(fd);
 368:	8526                	mv	a0,s1
 36a:	00000097          	auipc	ra,0x0
 36e:	464080e7          	jalr	1124(ra) # 7ce <close>
    return;
 372:	b74d                	j	314 <ls_n+0x98>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 374:	854a                	mv	a0,s2
 376:	00000097          	auipc	ra,0x0
 37a:	20c080e7          	jalr	524(ra) # 582 <strlen>
 37e:	2541                	addiw	a0,a0,16
 380:	20000793          	li	a5,512
 384:	00a7fb63          	bgeu	a5,a0,39a <ls_n+0x11e>
      printf("ls: path too long\n");
 388:	00001517          	auipc	a0,0x1
 38c:	98850513          	addi	a0,a0,-1656 # d10 <malloc+0x130>
 390:	00000097          	auipc	ra,0x0
 394:	798080e7          	jalr	1944(ra) # b28 <printf>
      break;
 398:	bf8d                	j	30a <ls_n+0x8e>
    strcpy(buf, path);
 39a:	85ca                	mv	a1,s2
 39c:	db040513          	addi	a0,s0,-592
 3a0:	00000097          	auipc	ra,0x0
 3a4:	19a080e7          	jalr	410(ra) # 53a <strcpy>
    p = buf+strlen(buf);
 3a8:	db040513          	addi	a0,s0,-592
 3ac:	00000097          	auipc	ra,0x0
 3b0:	1d6080e7          	jalr	470(ra) # 582 <strlen>
 3b4:	1502                	slli	a0,a0,0x20
 3b6:	9101                	srli	a0,a0,0x20
 3b8:	db040793          	addi	a5,s0,-592
 3bc:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 3c0:	00190a93          	addi	s5,s2,1
 3c4:	02f00793          	li	a5,47
 3c8:	00f90023          	sb	a5,0(s2)
  int fd, counter = 1;
 3cc:	4985                	li	s3,1
      printf("%d %s %d %d %d\n", counter++, fmtname(buf), st.type, st.ino, st.size);
 3ce:	00001b17          	auipc	s6,0x1
 3d2:	97ab0b13          	addi	s6,s6,-1670 # d48 <malloc+0x168>
        printf("ls: cannot stat %s\n", buf);
 3d6:	00001b97          	auipc	s7,0x1
 3da:	912b8b93          	addi	s7,s7,-1774 # ce8 <malloc+0x108>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 3de:	a801                	j	3ee <ls_n+0x172>
        printf("ls: cannot stat %s\n", buf);
 3e0:	db040593          	addi	a1,s0,-592
 3e4:	855e                	mv	a0,s7
 3e6:	00000097          	auipc	ra,0x0
 3ea:	742080e7          	jalr	1858(ra) # b28 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 3ee:	4641                	li	a2,16
 3f0:	da040593          	addi	a1,s0,-608
 3f4:	8526                	mv	a0,s1
 3f6:	00000097          	auipc	ra,0x0
 3fa:	3c8080e7          	jalr	968(ra) # 7be <read>
 3fe:	47c1                	li	a5,16
 400:	f0f515e3          	bne	a0,a5,30a <ls_n+0x8e>
      if(de.inum == 0)
 404:	da045783          	lhu	a5,-608(s0)
 408:	d3fd                	beqz	a5,3ee <ls_n+0x172>
      memmove(p, de.name, DIRSIZ);
 40a:	4639                	li	a2,14
 40c:	da240593          	addi	a1,s0,-606
 410:	8556                	mv	a0,s5
 412:	00000097          	auipc	ra,0x0
 416:	2e2080e7          	jalr	738(ra) # 6f4 <memmove>
      p[DIRSIZ] = 0;
 41a:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 41e:	d8840593          	addi	a1,s0,-632
 422:	db040513          	addi	a0,s0,-592
 426:	00000097          	auipc	ra,0x0
 42a:	240080e7          	jalr	576(ra) # 666 <stat>
 42e:	fa0549e3          	bltz	a0,3e0 <ls_n+0x164>
      printf("%d %s %d %d %d\n", counter++, fmtname(buf), st.type, st.ino, st.size);
 432:	00198a1b          	addiw	s4,s3,1
 436:	db040513          	addi	a0,s0,-592
 43a:	00000097          	auipc	ra,0x0
 43e:	bc6080e7          	jalr	-1082(ra) # 0 <fmtname>
 442:	862a                	mv	a2,a0
 444:	d9843783          	ld	a5,-616(s0)
 448:	d8c42703          	lw	a4,-628(s0)
 44c:	d9041683          	lh	a3,-624(s0)
 450:	85ce                	mv	a1,s3
 452:	855a                	mv	a0,s6
 454:	00000097          	auipc	ra,0x0
 458:	6d4080e7          	jalr	1748(ra) # b28 <printf>
 45c:	89d2                	mv	s3,s4
 45e:	bf41                	j	3ee <ls_n+0x172>

0000000000000460 <main>:

int
main(int argc, char *argv[])
{
 460:	7179                	addi	sp,sp,-48
 462:	f406                	sd	ra,40(sp)
 464:	f022                	sd	s0,32(sp)
 466:	ec26                	sd	s1,24(sp)
 468:	e84a                	sd	s2,16(sp)
 46a:	e44e                	sd	s3,8(sp)
 46c:	1800                	addi	s0,sp,48
 46e:	892a                	mv	s2,a0
 470:	89ae                	mv	s3,a1
  int i;
  
  if(argv[1][0] == '-' && argv[1][1] == 'n'){
 472:	659c                	ld	a5,8(a1)
 474:	0007c683          	lbu	a3,0(a5)
 478:	02d00713          	li	a4,45
 47c:	02e68c63          	beq	a3,a4,4b4 <main+0x54>
  	for(i=2; i<argc; i++)
    		ls_n(argv[i]);
  	exit(0);
  }

  if(argc < 2){
 480:	4785                	li	a5,1
 482:	0927d263          	bge	a5,s2,506 <main+0xa6>
 486:	00898493          	addi	s1,s3,8
 48a:	3979                	addiw	s2,s2,-2
 48c:	02091793          	slli	a5,s2,0x20
 490:	01d7d913          	srli	s2,a5,0x1d
 494:	01098593          	addi	a1,s3,16
 498:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 49a:	6088                	ld	a0,0(s1)
 49c:	00000097          	auipc	ra,0x0
 4a0:	c18080e7          	jalr	-1000(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 4a4:	04a1                	addi	s1,s1,8
 4a6:	ff249ae3          	bne	s1,s2,49a <main+0x3a>
  exit(0);
 4aa:	4501                	li	a0,0
 4ac:	00000097          	auipc	ra,0x0
 4b0:	2fa080e7          	jalr	762(ra) # 7a6 <exit>
  if(argv[1][0] == '-' && argv[1][1] == 'n'){
 4b4:	0017c703          	lbu	a4,1(a5)
 4b8:	06e00793          	li	a5,110
 4bc:	fcf712e3          	bne	a4,a5,480 <main+0x20>
  	if(argc < 3){
 4c0:	4789                	li	a5,2
 4c2:	4489                	li	s1,2
 4c4:	02a7d463          	bge	a5,a0,4ec <main+0x8c>
    		ls_n(argv[i]);
 4c8:	00349793          	slli	a5,s1,0x3
 4cc:	97ce                	add	a5,a5,s3
 4ce:	6388                	ld	a0,0(a5)
 4d0:	00000097          	auipc	ra,0x0
 4d4:	dac080e7          	jalr	-596(ra) # 27c <ls_n>
  	for(i=2; i<argc; i++)
 4d8:	0485                	addi	s1,s1,1
 4da:	0004879b          	sext.w	a5,s1
 4de:	ff27c5e3          	blt	a5,s2,4c8 <main+0x68>
  	exit(0);
 4e2:	4501                	li	a0,0
 4e4:	00000097          	auipc	ra,0x0
 4e8:	2c2080e7          	jalr	706(ra) # 7a6 <exit>
    		ls_n(".");
 4ec:	00001517          	auipc	a0,0x1
 4f0:	86c50513          	addi	a0,a0,-1940 # d58 <malloc+0x178>
 4f4:	00000097          	auipc	ra,0x0
 4f8:	d88080e7          	jalr	-632(ra) # 27c <ls_n>
    		exit(0);
 4fc:	4501                	li	a0,0
 4fe:	00000097          	auipc	ra,0x0
 502:	2a8080e7          	jalr	680(ra) # 7a6 <exit>
    ls(".");
 506:	00001517          	auipc	a0,0x1
 50a:	85250513          	addi	a0,a0,-1966 # d58 <malloc+0x178>
 50e:	00000097          	auipc	ra,0x0
 512:	ba6080e7          	jalr	-1114(ra) # b4 <ls>
    exit(0);
 516:	4501                	li	a0,0
 518:	00000097          	auipc	ra,0x0
 51c:	28e080e7          	jalr	654(ra) # 7a6 <exit>

0000000000000520 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 520:	1141                	addi	sp,sp,-16
 522:	e406                	sd	ra,8(sp)
 524:	e022                	sd	s0,0(sp)
 526:	0800                	addi	s0,sp,16
  extern int main();
  main();
 528:	00000097          	auipc	ra,0x0
 52c:	f38080e7          	jalr	-200(ra) # 460 <main>
  exit(0);
 530:	4501                	li	a0,0
 532:	00000097          	auipc	ra,0x0
 536:	274080e7          	jalr	628(ra) # 7a6 <exit>

000000000000053a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 53a:	1141                	addi	sp,sp,-16
 53c:	e422                	sd	s0,8(sp)
 53e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 540:	87aa                	mv	a5,a0
 542:	0585                	addi	a1,a1,1
 544:	0785                	addi	a5,a5,1
 546:	fff5c703          	lbu	a4,-1(a1)
 54a:	fee78fa3          	sb	a4,-1(a5)
 54e:	fb75                	bnez	a4,542 <strcpy+0x8>
    ;
  return os;
}
 550:	6422                	ld	s0,8(sp)
 552:	0141                	addi	sp,sp,16
 554:	8082                	ret

0000000000000556 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 556:	1141                	addi	sp,sp,-16
 558:	e422                	sd	s0,8(sp)
 55a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 55c:	00054783          	lbu	a5,0(a0)
 560:	cb91                	beqz	a5,574 <strcmp+0x1e>
 562:	0005c703          	lbu	a4,0(a1)
 566:	00f71763          	bne	a4,a5,574 <strcmp+0x1e>
    p++, q++;
 56a:	0505                	addi	a0,a0,1
 56c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 56e:	00054783          	lbu	a5,0(a0)
 572:	fbe5                	bnez	a5,562 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 574:	0005c503          	lbu	a0,0(a1)
}
 578:	40a7853b          	subw	a0,a5,a0
 57c:	6422                	ld	s0,8(sp)
 57e:	0141                	addi	sp,sp,16
 580:	8082                	ret

0000000000000582 <strlen>:

uint
strlen(const char *s)
{
 582:	1141                	addi	sp,sp,-16
 584:	e422                	sd	s0,8(sp)
 586:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 588:	00054783          	lbu	a5,0(a0)
 58c:	cf91                	beqz	a5,5a8 <strlen+0x26>
 58e:	0505                	addi	a0,a0,1
 590:	87aa                	mv	a5,a0
 592:	4685                	li	a3,1
 594:	9e89                	subw	a3,a3,a0
 596:	00f6853b          	addw	a0,a3,a5
 59a:	0785                	addi	a5,a5,1
 59c:	fff7c703          	lbu	a4,-1(a5)
 5a0:	fb7d                	bnez	a4,596 <strlen+0x14>
    ;
  return n;
}
 5a2:	6422                	ld	s0,8(sp)
 5a4:	0141                	addi	sp,sp,16
 5a6:	8082                	ret
  for(n = 0; s[n]; n++)
 5a8:	4501                	li	a0,0
 5aa:	bfe5                	j	5a2 <strlen+0x20>

00000000000005ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 5ac:	1141                	addi	sp,sp,-16
 5ae:	e422                	sd	s0,8(sp)
 5b0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 5b2:	ca19                	beqz	a2,5c8 <memset+0x1c>
 5b4:	87aa                	mv	a5,a0
 5b6:	1602                	slli	a2,a2,0x20
 5b8:	9201                	srli	a2,a2,0x20
 5ba:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 5be:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 5c2:	0785                	addi	a5,a5,1
 5c4:	fee79de3          	bne	a5,a4,5be <memset+0x12>
  }
  return dst;
}
 5c8:	6422                	ld	s0,8(sp)
 5ca:	0141                	addi	sp,sp,16
 5cc:	8082                	ret

00000000000005ce <strchr>:

char*
strchr(const char *s, char c)
{
 5ce:	1141                	addi	sp,sp,-16
 5d0:	e422                	sd	s0,8(sp)
 5d2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 5d4:	00054783          	lbu	a5,0(a0)
 5d8:	cb99                	beqz	a5,5ee <strchr+0x20>
    if(*s == c)
 5da:	00f58763          	beq	a1,a5,5e8 <strchr+0x1a>
  for(; *s; s++)
 5de:	0505                	addi	a0,a0,1
 5e0:	00054783          	lbu	a5,0(a0)
 5e4:	fbfd                	bnez	a5,5da <strchr+0xc>
      return (char*)s;
  return 0;
 5e6:	4501                	li	a0,0
}
 5e8:	6422                	ld	s0,8(sp)
 5ea:	0141                	addi	sp,sp,16
 5ec:	8082                	ret
  return 0;
 5ee:	4501                	li	a0,0
 5f0:	bfe5                	j	5e8 <strchr+0x1a>

00000000000005f2 <gets>:

char*
gets(char *buf, int max)
{
 5f2:	711d                	addi	sp,sp,-96
 5f4:	ec86                	sd	ra,88(sp)
 5f6:	e8a2                	sd	s0,80(sp)
 5f8:	e4a6                	sd	s1,72(sp)
 5fa:	e0ca                	sd	s2,64(sp)
 5fc:	fc4e                	sd	s3,56(sp)
 5fe:	f852                	sd	s4,48(sp)
 600:	f456                	sd	s5,40(sp)
 602:	f05a                	sd	s6,32(sp)
 604:	ec5e                	sd	s7,24(sp)
 606:	1080                	addi	s0,sp,96
 608:	8baa                	mv	s7,a0
 60a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 60c:	892a                	mv	s2,a0
 60e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 610:	4aa9                	li	s5,10
 612:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 614:	89a6                	mv	s3,s1
 616:	2485                	addiw	s1,s1,1
 618:	0344d863          	bge	s1,s4,648 <gets+0x56>
    cc = read(0, &c, 1);
 61c:	4605                	li	a2,1
 61e:	faf40593          	addi	a1,s0,-81
 622:	4501                	li	a0,0
 624:	00000097          	auipc	ra,0x0
 628:	19a080e7          	jalr	410(ra) # 7be <read>
    if(cc < 1)
 62c:	00a05e63          	blez	a0,648 <gets+0x56>
    buf[i++] = c;
 630:	faf44783          	lbu	a5,-81(s0)
 634:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 638:	01578763          	beq	a5,s5,646 <gets+0x54>
 63c:	0905                	addi	s2,s2,1
 63e:	fd679be3          	bne	a5,s6,614 <gets+0x22>
  for(i=0; i+1 < max; ){
 642:	89a6                	mv	s3,s1
 644:	a011                	j	648 <gets+0x56>
 646:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 648:	99de                	add	s3,s3,s7
 64a:	00098023          	sb	zero,0(s3)
  return buf;
}
 64e:	855e                	mv	a0,s7
 650:	60e6                	ld	ra,88(sp)
 652:	6446                	ld	s0,80(sp)
 654:	64a6                	ld	s1,72(sp)
 656:	6906                	ld	s2,64(sp)
 658:	79e2                	ld	s3,56(sp)
 65a:	7a42                	ld	s4,48(sp)
 65c:	7aa2                	ld	s5,40(sp)
 65e:	7b02                	ld	s6,32(sp)
 660:	6be2                	ld	s7,24(sp)
 662:	6125                	addi	sp,sp,96
 664:	8082                	ret

0000000000000666 <stat>:

int
stat(const char *n, struct stat *st)
{
 666:	1101                	addi	sp,sp,-32
 668:	ec06                	sd	ra,24(sp)
 66a:	e822                	sd	s0,16(sp)
 66c:	e426                	sd	s1,8(sp)
 66e:	e04a                	sd	s2,0(sp)
 670:	1000                	addi	s0,sp,32
 672:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 674:	4581                	li	a1,0
 676:	00000097          	auipc	ra,0x0
 67a:	170080e7          	jalr	368(ra) # 7e6 <open>
  if(fd < 0)
 67e:	02054563          	bltz	a0,6a8 <stat+0x42>
 682:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 684:	85ca                	mv	a1,s2
 686:	00000097          	auipc	ra,0x0
 68a:	178080e7          	jalr	376(ra) # 7fe <fstat>
 68e:	892a                	mv	s2,a0
  close(fd);
 690:	8526                	mv	a0,s1
 692:	00000097          	auipc	ra,0x0
 696:	13c080e7          	jalr	316(ra) # 7ce <close>
  return r;
}
 69a:	854a                	mv	a0,s2
 69c:	60e2                	ld	ra,24(sp)
 69e:	6442                	ld	s0,16(sp)
 6a0:	64a2                	ld	s1,8(sp)
 6a2:	6902                	ld	s2,0(sp)
 6a4:	6105                	addi	sp,sp,32
 6a6:	8082                	ret
    return -1;
 6a8:	597d                	li	s2,-1
 6aa:	bfc5                	j	69a <stat+0x34>

00000000000006ac <atoi>:

int
atoi(const char *s)
{
 6ac:	1141                	addi	sp,sp,-16
 6ae:	e422                	sd	s0,8(sp)
 6b0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6b2:	00054683          	lbu	a3,0(a0)
 6b6:	fd06879b          	addiw	a5,a3,-48
 6ba:	0ff7f793          	zext.b	a5,a5
 6be:	4625                	li	a2,9
 6c0:	02f66863          	bltu	a2,a5,6f0 <atoi+0x44>
 6c4:	872a                	mv	a4,a0
  n = 0;
 6c6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 6c8:	0705                	addi	a4,a4,1
 6ca:	0025179b          	slliw	a5,a0,0x2
 6ce:	9fa9                	addw	a5,a5,a0
 6d0:	0017979b          	slliw	a5,a5,0x1
 6d4:	9fb5                	addw	a5,a5,a3
 6d6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 6da:	00074683          	lbu	a3,0(a4)
 6de:	fd06879b          	addiw	a5,a3,-48
 6e2:	0ff7f793          	zext.b	a5,a5
 6e6:	fef671e3          	bgeu	a2,a5,6c8 <atoi+0x1c>
  return n;
}
 6ea:	6422                	ld	s0,8(sp)
 6ec:	0141                	addi	sp,sp,16
 6ee:	8082                	ret
  n = 0;
 6f0:	4501                	li	a0,0
 6f2:	bfe5                	j	6ea <atoi+0x3e>

00000000000006f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6f4:	1141                	addi	sp,sp,-16
 6f6:	e422                	sd	s0,8(sp)
 6f8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6fa:	02b57463          	bgeu	a0,a1,722 <memmove+0x2e>
    while(n-- > 0)
 6fe:	00c05f63          	blez	a2,71c <memmove+0x28>
 702:	1602                	slli	a2,a2,0x20
 704:	9201                	srli	a2,a2,0x20
 706:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 70a:	872a                	mv	a4,a0
      *dst++ = *src++;
 70c:	0585                	addi	a1,a1,1
 70e:	0705                	addi	a4,a4,1
 710:	fff5c683          	lbu	a3,-1(a1)
 714:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 718:	fee79ae3          	bne	a5,a4,70c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 71c:	6422                	ld	s0,8(sp)
 71e:	0141                	addi	sp,sp,16
 720:	8082                	ret
    dst += n;
 722:	00c50733          	add	a4,a0,a2
    src += n;
 726:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 728:	fec05ae3          	blez	a2,71c <memmove+0x28>
 72c:	fff6079b          	addiw	a5,a2,-1
 730:	1782                	slli	a5,a5,0x20
 732:	9381                	srli	a5,a5,0x20
 734:	fff7c793          	not	a5,a5
 738:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 73a:	15fd                	addi	a1,a1,-1
 73c:	177d                	addi	a4,a4,-1
 73e:	0005c683          	lbu	a3,0(a1)
 742:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 746:	fee79ae3          	bne	a5,a4,73a <memmove+0x46>
 74a:	bfc9                	j	71c <memmove+0x28>

000000000000074c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 74c:	1141                	addi	sp,sp,-16
 74e:	e422                	sd	s0,8(sp)
 750:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 752:	ca05                	beqz	a2,782 <memcmp+0x36>
 754:	fff6069b          	addiw	a3,a2,-1
 758:	1682                	slli	a3,a3,0x20
 75a:	9281                	srli	a3,a3,0x20
 75c:	0685                	addi	a3,a3,1
 75e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 760:	00054783          	lbu	a5,0(a0)
 764:	0005c703          	lbu	a4,0(a1)
 768:	00e79863          	bne	a5,a4,778 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 76c:	0505                	addi	a0,a0,1
    p2++;
 76e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 770:	fed518e3          	bne	a0,a3,760 <memcmp+0x14>
  }
  return 0;
 774:	4501                	li	a0,0
 776:	a019                	j	77c <memcmp+0x30>
      return *p1 - *p2;
 778:	40e7853b          	subw	a0,a5,a4
}
 77c:	6422                	ld	s0,8(sp)
 77e:	0141                	addi	sp,sp,16
 780:	8082                	ret
  return 0;
 782:	4501                	li	a0,0
 784:	bfe5                	j	77c <memcmp+0x30>

0000000000000786 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 786:	1141                	addi	sp,sp,-16
 788:	e406                	sd	ra,8(sp)
 78a:	e022                	sd	s0,0(sp)
 78c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 78e:	00000097          	auipc	ra,0x0
 792:	f66080e7          	jalr	-154(ra) # 6f4 <memmove>
}
 796:	60a2                	ld	ra,8(sp)
 798:	6402                	ld	s0,0(sp)
 79a:	0141                	addi	sp,sp,16
 79c:	8082                	ret

000000000000079e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 79e:	4885                	li	a7,1
 ecall
 7a0:	00000073          	ecall
 ret
 7a4:	8082                	ret

00000000000007a6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 7a6:	4889                	li	a7,2
 ecall
 7a8:	00000073          	ecall
 ret
 7ac:	8082                	ret

00000000000007ae <wait>:
.global wait
wait:
 li a7, SYS_wait
 7ae:	488d                	li	a7,3
 ecall
 7b0:	00000073          	ecall
 ret
 7b4:	8082                	ret

00000000000007b6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 7b6:	4891                	li	a7,4
 ecall
 7b8:	00000073          	ecall
 ret
 7bc:	8082                	ret

00000000000007be <read>:
.global read
read:
 li a7, SYS_read
 7be:	4895                	li	a7,5
 ecall
 7c0:	00000073          	ecall
 ret
 7c4:	8082                	ret

00000000000007c6 <write>:
.global write
write:
 li a7, SYS_write
 7c6:	48c1                	li	a7,16
 ecall
 7c8:	00000073          	ecall
 ret
 7cc:	8082                	ret

00000000000007ce <close>:
.global close
close:
 li a7, SYS_close
 7ce:	48d5                	li	a7,21
 ecall
 7d0:	00000073          	ecall
 ret
 7d4:	8082                	ret

00000000000007d6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 7d6:	4899                	li	a7,6
 ecall
 7d8:	00000073          	ecall
 ret
 7dc:	8082                	ret

00000000000007de <exec>:
.global exec
exec:
 li a7, SYS_exec
 7de:	489d                	li	a7,7
 ecall
 7e0:	00000073          	ecall
 ret
 7e4:	8082                	ret

00000000000007e6 <open>:
.global open
open:
 li a7, SYS_open
 7e6:	48bd                	li	a7,15
 ecall
 7e8:	00000073          	ecall
 ret
 7ec:	8082                	ret

00000000000007ee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 7ee:	48c5                	li	a7,17
 ecall
 7f0:	00000073          	ecall
 ret
 7f4:	8082                	ret

00000000000007f6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 7f6:	48c9                	li	a7,18
 ecall
 7f8:	00000073          	ecall
 ret
 7fc:	8082                	ret

00000000000007fe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 7fe:	48a1                	li	a7,8
 ecall
 800:	00000073          	ecall
 ret
 804:	8082                	ret

0000000000000806 <link>:
.global link
link:
 li a7, SYS_link
 806:	48cd                	li	a7,19
 ecall
 808:	00000073          	ecall
 ret
 80c:	8082                	ret

000000000000080e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 80e:	48d1                	li	a7,20
 ecall
 810:	00000073          	ecall
 ret
 814:	8082                	ret

0000000000000816 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 816:	48a5                	li	a7,9
 ecall
 818:	00000073          	ecall
 ret
 81c:	8082                	ret

000000000000081e <dup>:
.global dup
dup:
 li a7, SYS_dup
 81e:	48a9                	li	a7,10
 ecall
 820:	00000073          	ecall
 ret
 824:	8082                	ret

0000000000000826 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 826:	48ad                	li	a7,11
 ecall
 828:	00000073          	ecall
 ret
 82c:	8082                	ret

000000000000082e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 82e:	48b1                	li	a7,12
 ecall
 830:	00000073          	ecall
 ret
 834:	8082                	ret

0000000000000836 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 836:	48b5                	li	a7,13
 ecall
 838:	00000073          	ecall
 ret
 83c:	8082                	ret

000000000000083e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 83e:	48b9                	li	a7,14
 ecall
 840:	00000073          	ecall
 ret
 844:	8082                	ret

0000000000000846 <ps>:
.global ps
ps:
 li a7, SYS_ps
 846:	48d9                	li	a7,22
 ecall
 848:	00000073          	ecall
 ret
 84c:	8082                	ret

000000000000084e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 84e:	1101                	addi	sp,sp,-32
 850:	ec06                	sd	ra,24(sp)
 852:	e822                	sd	s0,16(sp)
 854:	1000                	addi	s0,sp,32
 856:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 85a:	4605                	li	a2,1
 85c:	fef40593          	addi	a1,s0,-17
 860:	00000097          	auipc	ra,0x0
 864:	f66080e7          	jalr	-154(ra) # 7c6 <write>
}
 868:	60e2                	ld	ra,24(sp)
 86a:	6442                	ld	s0,16(sp)
 86c:	6105                	addi	sp,sp,32
 86e:	8082                	ret

0000000000000870 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 870:	7139                	addi	sp,sp,-64
 872:	fc06                	sd	ra,56(sp)
 874:	f822                	sd	s0,48(sp)
 876:	f426                	sd	s1,40(sp)
 878:	f04a                	sd	s2,32(sp)
 87a:	ec4e                	sd	s3,24(sp)
 87c:	0080                	addi	s0,sp,64
 87e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 880:	c299                	beqz	a3,886 <printint+0x16>
 882:	0805c963          	bltz	a1,914 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 886:	2581                	sext.w	a1,a1
  neg = 0;
 888:	4881                	li	a7,0
 88a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 88e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 890:	2601                	sext.w	a2,a2
 892:	00000517          	auipc	a0,0x0
 896:	52e50513          	addi	a0,a0,1326 # dc0 <digits>
 89a:	883a                	mv	a6,a4
 89c:	2705                	addiw	a4,a4,1
 89e:	02c5f7bb          	remuw	a5,a1,a2
 8a2:	1782                	slli	a5,a5,0x20
 8a4:	9381                	srli	a5,a5,0x20
 8a6:	97aa                	add	a5,a5,a0
 8a8:	0007c783          	lbu	a5,0(a5)
 8ac:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 8b0:	0005879b          	sext.w	a5,a1
 8b4:	02c5d5bb          	divuw	a1,a1,a2
 8b8:	0685                	addi	a3,a3,1
 8ba:	fec7f0e3          	bgeu	a5,a2,89a <printint+0x2a>
  if(neg)
 8be:	00088c63          	beqz	a7,8d6 <printint+0x66>
    buf[i++] = '-';
 8c2:	fd070793          	addi	a5,a4,-48
 8c6:	00878733          	add	a4,a5,s0
 8ca:	02d00793          	li	a5,45
 8ce:	fef70823          	sb	a5,-16(a4)
 8d2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 8d6:	02e05863          	blez	a4,906 <printint+0x96>
 8da:	fc040793          	addi	a5,s0,-64
 8de:	00e78933          	add	s2,a5,a4
 8e2:	fff78993          	addi	s3,a5,-1
 8e6:	99ba                	add	s3,s3,a4
 8e8:	377d                	addiw	a4,a4,-1
 8ea:	1702                	slli	a4,a4,0x20
 8ec:	9301                	srli	a4,a4,0x20
 8ee:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 8f2:	fff94583          	lbu	a1,-1(s2)
 8f6:	8526                	mv	a0,s1
 8f8:	00000097          	auipc	ra,0x0
 8fc:	f56080e7          	jalr	-170(ra) # 84e <putc>
  while(--i >= 0)
 900:	197d                	addi	s2,s2,-1
 902:	ff3918e3          	bne	s2,s3,8f2 <printint+0x82>
}
 906:	70e2                	ld	ra,56(sp)
 908:	7442                	ld	s0,48(sp)
 90a:	74a2                	ld	s1,40(sp)
 90c:	7902                	ld	s2,32(sp)
 90e:	69e2                	ld	s3,24(sp)
 910:	6121                	addi	sp,sp,64
 912:	8082                	ret
    x = -xx;
 914:	40b005bb          	negw	a1,a1
    neg = 1;
 918:	4885                	li	a7,1
    x = -xx;
 91a:	bf85                	j	88a <printint+0x1a>

000000000000091c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 91c:	7119                	addi	sp,sp,-128
 91e:	fc86                	sd	ra,120(sp)
 920:	f8a2                	sd	s0,112(sp)
 922:	f4a6                	sd	s1,104(sp)
 924:	f0ca                	sd	s2,96(sp)
 926:	ecce                	sd	s3,88(sp)
 928:	e8d2                	sd	s4,80(sp)
 92a:	e4d6                	sd	s5,72(sp)
 92c:	e0da                	sd	s6,64(sp)
 92e:	fc5e                	sd	s7,56(sp)
 930:	f862                	sd	s8,48(sp)
 932:	f466                	sd	s9,40(sp)
 934:	f06a                	sd	s10,32(sp)
 936:	ec6e                	sd	s11,24(sp)
 938:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 93a:	0005c903          	lbu	s2,0(a1)
 93e:	18090f63          	beqz	s2,adc <vprintf+0x1c0>
 942:	8aaa                	mv	s5,a0
 944:	8b32                	mv	s6,a2
 946:	00158493          	addi	s1,a1,1
  state = 0;
 94a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 94c:	02500a13          	li	s4,37
 950:	4c55                	li	s8,21
 952:	00000c97          	auipc	s9,0x0
 956:	416c8c93          	addi	s9,s9,1046 # d68 <malloc+0x188>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 95a:	02800d93          	li	s11,40
  putc(fd, 'x');
 95e:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 960:	00000b97          	auipc	s7,0x0
 964:	460b8b93          	addi	s7,s7,1120 # dc0 <digits>
 968:	a839                	j	986 <vprintf+0x6a>
        putc(fd, c);
 96a:	85ca                	mv	a1,s2
 96c:	8556                	mv	a0,s5
 96e:	00000097          	auipc	ra,0x0
 972:	ee0080e7          	jalr	-288(ra) # 84e <putc>
 976:	a019                	j	97c <vprintf+0x60>
    } else if(state == '%'){
 978:	01498d63          	beq	s3,s4,992 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 97c:	0485                	addi	s1,s1,1
 97e:	fff4c903          	lbu	s2,-1(s1)
 982:	14090d63          	beqz	s2,adc <vprintf+0x1c0>
    if(state == 0){
 986:	fe0999e3          	bnez	s3,978 <vprintf+0x5c>
      if(c == '%'){
 98a:	ff4910e3          	bne	s2,s4,96a <vprintf+0x4e>
        state = '%';
 98e:	89d2                	mv	s3,s4
 990:	b7f5                	j	97c <vprintf+0x60>
      if(c == 'd'){
 992:	11490c63          	beq	s2,s4,aaa <vprintf+0x18e>
 996:	f9d9079b          	addiw	a5,s2,-99
 99a:	0ff7f793          	zext.b	a5,a5
 99e:	10fc6e63          	bltu	s8,a5,aba <vprintf+0x19e>
 9a2:	f9d9079b          	addiw	a5,s2,-99
 9a6:	0ff7f713          	zext.b	a4,a5
 9aa:	10ec6863          	bltu	s8,a4,aba <vprintf+0x19e>
 9ae:	00271793          	slli	a5,a4,0x2
 9b2:	97e6                	add	a5,a5,s9
 9b4:	439c                	lw	a5,0(a5)
 9b6:	97e6                	add	a5,a5,s9
 9b8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 9ba:	008b0913          	addi	s2,s6,8
 9be:	4685                	li	a3,1
 9c0:	4629                	li	a2,10
 9c2:	000b2583          	lw	a1,0(s6)
 9c6:	8556                	mv	a0,s5
 9c8:	00000097          	auipc	ra,0x0
 9cc:	ea8080e7          	jalr	-344(ra) # 870 <printint>
 9d0:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 9d2:	4981                	li	s3,0
 9d4:	b765                	j	97c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9d6:	008b0913          	addi	s2,s6,8
 9da:	4681                	li	a3,0
 9dc:	4629                	li	a2,10
 9de:	000b2583          	lw	a1,0(s6)
 9e2:	8556                	mv	a0,s5
 9e4:	00000097          	auipc	ra,0x0
 9e8:	e8c080e7          	jalr	-372(ra) # 870 <printint>
 9ec:	8b4a                	mv	s6,s2
      state = 0;
 9ee:	4981                	li	s3,0
 9f0:	b771                	j	97c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9f2:	008b0913          	addi	s2,s6,8
 9f6:	4681                	li	a3,0
 9f8:	866a                	mv	a2,s10
 9fa:	000b2583          	lw	a1,0(s6)
 9fe:	8556                	mv	a0,s5
 a00:	00000097          	auipc	ra,0x0
 a04:	e70080e7          	jalr	-400(ra) # 870 <printint>
 a08:	8b4a                	mv	s6,s2
      state = 0;
 a0a:	4981                	li	s3,0
 a0c:	bf85                	j	97c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 a0e:	008b0793          	addi	a5,s6,8
 a12:	f8f43423          	sd	a5,-120(s0)
 a16:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 a1a:	03000593          	li	a1,48
 a1e:	8556                	mv	a0,s5
 a20:	00000097          	auipc	ra,0x0
 a24:	e2e080e7          	jalr	-466(ra) # 84e <putc>
  putc(fd, 'x');
 a28:	07800593          	li	a1,120
 a2c:	8556                	mv	a0,s5
 a2e:	00000097          	auipc	ra,0x0
 a32:	e20080e7          	jalr	-480(ra) # 84e <putc>
 a36:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a38:	03c9d793          	srli	a5,s3,0x3c
 a3c:	97de                	add	a5,a5,s7
 a3e:	0007c583          	lbu	a1,0(a5)
 a42:	8556                	mv	a0,s5
 a44:	00000097          	auipc	ra,0x0
 a48:	e0a080e7          	jalr	-502(ra) # 84e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a4c:	0992                	slli	s3,s3,0x4
 a4e:	397d                	addiw	s2,s2,-1
 a50:	fe0914e3          	bnez	s2,a38 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 a54:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a58:	4981                	li	s3,0
 a5a:	b70d                	j	97c <vprintf+0x60>
        s = va_arg(ap, char*);
 a5c:	008b0913          	addi	s2,s6,8
 a60:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 a64:	02098163          	beqz	s3,a86 <vprintf+0x16a>
        while(*s != 0){
 a68:	0009c583          	lbu	a1,0(s3)
 a6c:	c5ad                	beqz	a1,ad6 <vprintf+0x1ba>
          putc(fd, *s);
 a6e:	8556                	mv	a0,s5
 a70:	00000097          	auipc	ra,0x0
 a74:	dde080e7          	jalr	-546(ra) # 84e <putc>
          s++;
 a78:	0985                	addi	s3,s3,1
        while(*s != 0){
 a7a:	0009c583          	lbu	a1,0(s3)
 a7e:	f9e5                	bnez	a1,a6e <vprintf+0x152>
        s = va_arg(ap, char*);
 a80:	8b4a                	mv	s6,s2
      state = 0;
 a82:	4981                	li	s3,0
 a84:	bde5                	j	97c <vprintf+0x60>
          s = "(null)";
 a86:	00000997          	auipc	s3,0x0
 a8a:	2da98993          	addi	s3,s3,730 # d60 <malloc+0x180>
        while(*s != 0){
 a8e:	85ee                	mv	a1,s11
 a90:	bff9                	j	a6e <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 a92:	008b0913          	addi	s2,s6,8
 a96:	000b4583          	lbu	a1,0(s6)
 a9a:	8556                	mv	a0,s5
 a9c:	00000097          	auipc	ra,0x0
 aa0:	db2080e7          	jalr	-590(ra) # 84e <putc>
 aa4:	8b4a                	mv	s6,s2
      state = 0;
 aa6:	4981                	li	s3,0
 aa8:	bdd1                	j	97c <vprintf+0x60>
        putc(fd, c);
 aaa:	85d2                	mv	a1,s4
 aac:	8556                	mv	a0,s5
 aae:	00000097          	auipc	ra,0x0
 ab2:	da0080e7          	jalr	-608(ra) # 84e <putc>
      state = 0;
 ab6:	4981                	li	s3,0
 ab8:	b5d1                	j	97c <vprintf+0x60>
        putc(fd, '%');
 aba:	85d2                	mv	a1,s4
 abc:	8556                	mv	a0,s5
 abe:	00000097          	auipc	ra,0x0
 ac2:	d90080e7          	jalr	-624(ra) # 84e <putc>
        putc(fd, c);
 ac6:	85ca                	mv	a1,s2
 ac8:	8556                	mv	a0,s5
 aca:	00000097          	auipc	ra,0x0
 ace:	d84080e7          	jalr	-636(ra) # 84e <putc>
      state = 0;
 ad2:	4981                	li	s3,0
 ad4:	b565                	j	97c <vprintf+0x60>
        s = va_arg(ap, char*);
 ad6:	8b4a                	mv	s6,s2
      state = 0;
 ad8:	4981                	li	s3,0
 ada:	b54d                	j	97c <vprintf+0x60>
    }
  }
}
 adc:	70e6                	ld	ra,120(sp)
 ade:	7446                	ld	s0,112(sp)
 ae0:	74a6                	ld	s1,104(sp)
 ae2:	7906                	ld	s2,96(sp)
 ae4:	69e6                	ld	s3,88(sp)
 ae6:	6a46                	ld	s4,80(sp)
 ae8:	6aa6                	ld	s5,72(sp)
 aea:	6b06                	ld	s6,64(sp)
 aec:	7be2                	ld	s7,56(sp)
 aee:	7c42                	ld	s8,48(sp)
 af0:	7ca2                	ld	s9,40(sp)
 af2:	7d02                	ld	s10,32(sp)
 af4:	6de2                	ld	s11,24(sp)
 af6:	6109                	addi	sp,sp,128
 af8:	8082                	ret

0000000000000afa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 afa:	715d                	addi	sp,sp,-80
 afc:	ec06                	sd	ra,24(sp)
 afe:	e822                	sd	s0,16(sp)
 b00:	1000                	addi	s0,sp,32
 b02:	e010                	sd	a2,0(s0)
 b04:	e414                	sd	a3,8(s0)
 b06:	e818                	sd	a4,16(s0)
 b08:	ec1c                	sd	a5,24(s0)
 b0a:	03043023          	sd	a6,32(s0)
 b0e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b12:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b16:	8622                	mv	a2,s0
 b18:	00000097          	auipc	ra,0x0
 b1c:	e04080e7          	jalr	-508(ra) # 91c <vprintf>
}
 b20:	60e2                	ld	ra,24(sp)
 b22:	6442                	ld	s0,16(sp)
 b24:	6161                	addi	sp,sp,80
 b26:	8082                	ret

0000000000000b28 <printf>:

void
printf(const char *fmt, ...)
{
 b28:	711d                	addi	sp,sp,-96
 b2a:	ec06                	sd	ra,24(sp)
 b2c:	e822                	sd	s0,16(sp)
 b2e:	1000                	addi	s0,sp,32
 b30:	e40c                	sd	a1,8(s0)
 b32:	e810                	sd	a2,16(s0)
 b34:	ec14                	sd	a3,24(s0)
 b36:	f018                	sd	a4,32(s0)
 b38:	f41c                	sd	a5,40(s0)
 b3a:	03043823          	sd	a6,48(s0)
 b3e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b42:	00840613          	addi	a2,s0,8
 b46:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b4a:	85aa                	mv	a1,a0
 b4c:	4505                	li	a0,1
 b4e:	00000097          	auipc	ra,0x0
 b52:	dce080e7          	jalr	-562(ra) # 91c <vprintf>
}
 b56:	60e2                	ld	ra,24(sp)
 b58:	6442                	ld	s0,16(sp)
 b5a:	6125                	addi	sp,sp,96
 b5c:	8082                	ret

0000000000000b5e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b5e:	1141                	addi	sp,sp,-16
 b60:	e422                	sd	s0,8(sp)
 b62:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b64:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b68:	00000797          	auipc	a5,0x0
 b6c:	4987b783          	ld	a5,1176(a5) # 1000 <freep>
 b70:	a02d                	j	b9a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b72:	4618                	lw	a4,8(a2)
 b74:	9f2d                	addw	a4,a4,a1
 b76:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b7a:	6398                	ld	a4,0(a5)
 b7c:	6310                	ld	a2,0(a4)
 b7e:	a83d                	j	bbc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b80:	ff852703          	lw	a4,-8(a0)
 b84:	9f31                	addw	a4,a4,a2
 b86:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b88:	ff053683          	ld	a3,-16(a0)
 b8c:	a091                	j	bd0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b8e:	6398                	ld	a4,0(a5)
 b90:	00e7e463          	bltu	a5,a4,b98 <free+0x3a>
 b94:	00e6ea63          	bltu	a3,a4,ba8 <free+0x4a>
{
 b98:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b9a:	fed7fae3          	bgeu	a5,a3,b8e <free+0x30>
 b9e:	6398                	ld	a4,0(a5)
 ba0:	00e6e463          	bltu	a3,a4,ba8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ba4:	fee7eae3          	bltu	a5,a4,b98 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 ba8:	ff852583          	lw	a1,-8(a0)
 bac:	6390                	ld	a2,0(a5)
 bae:	02059813          	slli	a6,a1,0x20
 bb2:	01c85713          	srli	a4,a6,0x1c
 bb6:	9736                	add	a4,a4,a3
 bb8:	fae60de3          	beq	a2,a4,b72 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 bbc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 bc0:	4790                	lw	a2,8(a5)
 bc2:	02061593          	slli	a1,a2,0x20
 bc6:	01c5d713          	srli	a4,a1,0x1c
 bca:	973e                	add	a4,a4,a5
 bcc:	fae68ae3          	beq	a3,a4,b80 <free+0x22>
    p->s.ptr = bp->s.ptr;
 bd0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 bd2:	00000717          	auipc	a4,0x0
 bd6:	42f73723          	sd	a5,1070(a4) # 1000 <freep>
}
 bda:	6422                	ld	s0,8(sp)
 bdc:	0141                	addi	sp,sp,16
 bde:	8082                	ret

0000000000000be0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 be0:	7139                	addi	sp,sp,-64
 be2:	fc06                	sd	ra,56(sp)
 be4:	f822                	sd	s0,48(sp)
 be6:	f426                	sd	s1,40(sp)
 be8:	f04a                	sd	s2,32(sp)
 bea:	ec4e                	sd	s3,24(sp)
 bec:	e852                	sd	s4,16(sp)
 bee:	e456                	sd	s5,8(sp)
 bf0:	e05a                	sd	s6,0(sp)
 bf2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bf4:	02051493          	slli	s1,a0,0x20
 bf8:	9081                	srli	s1,s1,0x20
 bfa:	04bd                	addi	s1,s1,15
 bfc:	8091                	srli	s1,s1,0x4
 bfe:	0014899b          	addiw	s3,s1,1
 c02:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 c04:	00000517          	auipc	a0,0x0
 c08:	3fc53503          	ld	a0,1020(a0) # 1000 <freep>
 c0c:	c515                	beqz	a0,c38 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c0e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c10:	4798                	lw	a4,8(a5)
 c12:	02977f63          	bgeu	a4,s1,c50 <malloc+0x70>
 c16:	8a4e                	mv	s4,s3
 c18:	0009871b          	sext.w	a4,s3
 c1c:	6685                	lui	a3,0x1
 c1e:	00d77363          	bgeu	a4,a3,c24 <malloc+0x44>
 c22:	6a05                	lui	s4,0x1
 c24:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c28:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c2c:	00000917          	auipc	s2,0x0
 c30:	3d490913          	addi	s2,s2,980 # 1000 <freep>
  if(p == (char*)-1)
 c34:	5afd                	li	s5,-1
 c36:	a895                	j	caa <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 c38:	00000797          	auipc	a5,0x0
 c3c:	3e878793          	addi	a5,a5,1000 # 1020 <base>
 c40:	00000717          	auipc	a4,0x0
 c44:	3cf73023          	sd	a5,960(a4) # 1000 <freep>
 c48:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c4a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c4e:	b7e1                	j	c16 <malloc+0x36>
      if(p->s.size == nunits)
 c50:	02e48c63          	beq	s1,a4,c88 <malloc+0xa8>
        p->s.size -= nunits;
 c54:	4137073b          	subw	a4,a4,s3
 c58:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c5a:	02071693          	slli	a3,a4,0x20
 c5e:	01c6d713          	srli	a4,a3,0x1c
 c62:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c64:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c68:	00000717          	auipc	a4,0x0
 c6c:	38a73c23          	sd	a0,920(a4) # 1000 <freep>
      return (void*)(p + 1);
 c70:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c74:	70e2                	ld	ra,56(sp)
 c76:	7442                	ld	s0,48(sp)
 c78:	74a2                	ld	s1,40(sp)
 c7a:	7902                	ld	s2,32(sp)
 c7c:	69e2                	ld	s3,24(sp)
 c7e:	6a42                	ld	s4,16(sp)
 c80:	6aa2                	ld	s5,8(sp)
 c82:	6b02                	ld	s6,0(sp)
 c84:	6121                	addi	sp,sp,64
 c86:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c88:	6398                	ld	a4,0(a5)
 c8a:	e118                	sd	a4,0(a0)
 c8c:	bff1                	j	c68 <malloc+0x88>
  hp->s.size = nu;
 c8e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c92:	0541                	addi	a0,a0,16
 c94:	00000097          	auipc	ra,0x0
 c98:	eca080e7          	jalr	-310(ra) # b5e <free>
  return freep;
 c9c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ca0:	d971                	beqz	a0,c74 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ca2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ca4:	4798                	lw	a4,8(a5)
 ca6:	fa9775e3          	bgeu	a4,s1,c50 <malloc+0x70>
    if(p == freep)
 caa:	00093703          	ld	a4,0(s2)
 cae:	853e                	mv	a0,a5
 cb0:	fef719e3          	bne	a4,a5,ca2 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 cb4:	8552                	mv	a0,s4
 cb6:	00000097          	auipc	ra,0x0
 cba:	b78080e7          	jalr	-1160(ra) # 82e <sbrk>
  if(p == (char*)-1)
 cbe:	fd5518e3          	bne	a0,s5,c8e <malloc+0xae>
        return 0;
 cc2:	4501                	li	a0,0
 cc4:	bf45                	j	c74 <malloc+0x94>
