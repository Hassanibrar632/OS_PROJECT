
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
 12c:	bc850513          	addi	a0,a0,-1080 # cf0 <malloc+0x118>
 130:	00001097          	auipc	ra,0x1
 134:	9f0080e7          	jalr	-1552(ra) # b20 <printf>
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
 16a:	b5a58593          	addi	a1,a1,-1190 # cc0 <malloc+0xe8>
 16e:	4509                	li	a0,2
 170:	00001097          	auipc	ra,0x1
 174:	982080e7          	jalr	-1662(ra) # af2 <fprintf>
    return;
 178:	b7e9                	j	142 <ls+0x8e>
    fprintf(2, "ls: cannot stat %s\n", path);
 17a:	864a                	mv	a2,s2
 17c:	00001597          	auipc	a1,0x1
 180:	b5c58593          	addi	a1,a1,-1188 # cd8 <malloc+0x100>
 184:	4509                	li	a0,2
 186:	00001097          	auipc	ra,0x1
 18a:	96c080e7          	jalr	-1684(ra) # af2 <fprintf>
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
 1b2:	b5250513          	addi	a0,a0,-1198 # d00 <malloc+0x128>
 1b6:	00001097          	auipc	ra,0x1
 1ba:	96a080e7          	jalr	-1686(ra) # b20 <printf>
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
 1f6:	b26a0a13          	addi	s4,s4,-1242 # d18 <malloc+0x140>
        printf("ls: cannot stat %s\n", buf);
 1fa:	00001a97          	auipc	s5,0x1
 1fe:	adea8a93          	addi	s5,s5,-1314 # cd8 <malloc+0x100>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 202:	a801                	j	212 <ls+0x15e>
        printf("ls: cannot stat %s\n", buf);
 204:	dc040593          	addi	a1,s0,-576
 208:	8556                	mv	a0,s5
 20a:	00001097          	auipc	ra,0x1
 20e:	916080e7          	jalr	-1770(ra) # b20 <printf>
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
 276:	8ae080e7          	jalr	-1874(ra) # b20 <printf>
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
 2fe:	a2e50513          	addi	a0,a0,-1490 # d28 <malloc+0x150>
 302:	00001097          	auipc	ra,0x1
 306:	81e080e7          	jalr	-2018(ra) # b20 <printf>
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
 344:	98058593          	addi	a1,a1,-1664 # cc0 <malloc+0xe8>
 348:	4509                	li	a0,2
 34a:	00000097          	auipc	ra,0x0
 34e:	7a8080e7          	jalr	1960(ra) # af2 <fprintf>
    return;
 352:	b7c9                	j	314 <ls_n+0x98>
    fprintf(2, "ls: cannot stat %s\n", path);
 354:	864a                	mv	a2,s2
 356:	00001597          	auipc	a1,0x1
 35a:	98258593          	addi	a1,a1,-1662 # cd8 <malloc+0x100>
 35e:	4509                	li	a0,2
 360:	00000097          	auipc	ra,0x0
 364:	792080e7          	jalr	1938(ra) # af2 <fprintf>
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
 38c:	97850513          	addi	a0,a0,-1672 # d00 <malloc+0x128>
 390:	00000097          	auipc	ra,0x0
 394:	790080e7          	jalr	1936(ra) # b20 <printf>
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
 3d2:	96ab0b13          	addi	s6,s6,-1686 # d38 <malloc+0x160>
        printf("ls: cannot stat %s\n", buf);
 3d6:	00001b97          	auipc	s7,0x1
 3da:	902b8b93          	addi	s7,s7,-1790 # cd8 <malloc+0x100>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 3de:	a801                	j	3ee <ls_n+0x172>
        printf("ls: cannot stat %s\n", buf);
 3e0:	db040593          	addi	a1,s0,-592
 3e4:	855e                	mv	a0,s7
 3e6:	00000097          	auipc	ra,0x0
 3ea:	73a080e7          	jalr	1850(ra) # b20 <printf>
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
 458:	6cc080e7          	jalr	1740(ra) # b20 <printf>
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
 4f0:	85c50513          	addi	a0,a0,-1956 # d48 <malloc+0x170>
 4f4:	00000097          	auipc	ra,0x0
 4f8:	d88080e7          	jalr	-632(ra) # 27c <ls_n>
    		exit(0);
 4fc:	4501                	li	a0,0
 4fe:	00000097          	auipc	ra,0x0
 502:	2a8080e7          	jalr	680(ra) # 7a6 <exit>
    ls(".");
 506:	00001517          	auipc	a0,0x1
 50a:	84250513          	addi	a0,a0,-1982 # d48 <malloc+0x170>
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

0000000000000846 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 846:	1101                	addi	sp,sp,-32
 848:	ec06                	sd	ra,24(sp)
 84a:	e822                	sd	s0,16(sp)
 84c:	1000                	addi	s0,sp,32
 84e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 852:	4605                	li	a2,1
 854:	fef40593          	addi	a1,s0,-17
 858:	00000097          	auipc	ra,0x0
 85c:	f6e080e7          	jalr	-146(ra) # 7c6 <write>
}
 860:	60e2                	ld	ra,24(sp)
 862:	6442                	ld	s0,16(sp)
 864:	6105                	addi	sp,sp,32
 866:	8082                	ret

0000000000000868 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 868:	7139                	addi	sp,sp,-64
 86a:	fc06                	sd	ra,56(sp)
 86c:	f822                	sd	s0,48(sp)
 86e:	f426                	sd	s1,40(sp)
 870:	f04a                	sd	s2,32(sp)
 872:	ec4e                	sd	s3,24(sp)
 874:	0080                	addi	s0,sp,64
 876:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 878:	c299                	beqz	a3,87e <printint+0x16>
 87a:	0805c963          	bltz	a1,90c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 87e:	2581                	sext.w	a1,a1
  neg = 0;
 880:	4881                	li	a7,0
 882:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 886:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 888:	2601                	sext.w	a2,a2
 88a:	00000517          	auipc	a0,0x0
 88e:	52650513          	addi	a0,a0,1318 # db0 <digits>
 892:	883a                	mv	a6,a4
 894:	2705                	addiw	a4,a4,1
 896:	02c5f7bb          	remuw	a5,a1,a2
 89a:	1782                	slli	a5,a5,0x20
 89c:	9381                	srli	a5,a5,0x20
 89e:	97aa                	add	a5,a5,a0
 8a0:	0007c783          	lbu	a5,0(a5)
 8a4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 8a8:	0005879b          	sext.w	a5,a1
 8ac:	02c5d5bb          	divuw	a1,a1,a2
 8b0:	0685                	addi	a3,a3,1
 8b2:	fec7f0e3          	bgeu	a5,a2,892 <printint+0x2a>
  if(neg)
 8b6:	00088c63          	beqz	a7,8ce <printint+0x66>
    buf[i++] = '-';
 8ba:	fd070793          	addi	a5,a4,-48
 8be:	00878733          	add	a4,a5,s0
 8c2:	02d00793          	li	a5,45
 8c6:	fef70823          	sb	a5,-16(a4)
 8ca:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 8ce:	02e05863          	blez	a4,8fe <printint+0x96>
 8d2:	fc040793          	addi	a5,s0,-64
 8d6:	00e78933          	add	s2,a5,a4
 8da:	fff78993          	addi	s3,a5,-1
 8de:	99ba                	add	s3,s3,a4
 8e0:	377d                	addiw	a4,a4,-1
 8e2:	1702                	slli	a4,a4,0x20
 8e4:	9301                	srli	a4,a4,0x20
 8e6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 8ea:	fff94583          	lbu	a1,-1(s2)
 8ee:	8526                	mv	a0,s1
 8f0:	00000097          	auipc	ra,0x0
 8f4:	f56080e7          	jalr	-170(ra) # 846 <putc>
  while(--i >= 0)
 8f8:	197d                	addi	s2,s2,-1
 8fa:	ff3918e3          	bne	s2,s3,8ea <printint+0x82>
}
 8fe:	70e2                	ld	ra,56(sp)
 900:	7442                	ld	s0,48(sp)
 902:	74a2                	ld	s1,40(sp)
 904:	7902                	ld	s2,32(sp)
 906:	69e2                	ld	s3,24(sp)
 908:	6121                	addi	sp,sp,64
 90a:	8082                	ret
    x = -xx;
 90c:	40b005bb          	negw	a1,a1
    neg = 1;
 910:	4885                	li	a7,1
    x = -xx;
 912:	bf85                	j	882 <printint+0x1a>

0000000000000914 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 914:	7119                	addi	sp,sp,-128
 916:	fc86                	sd	ra,120(sp)
 918:	f8a2                	sd	s0,112(sp)
 91a:	f4a6                	sd	s1,104(sp)
 91c:	f0ca                	sd	s2,96(sp)
 91e:	ecce                	sd	s3,88(sp)
 920:	e8d2                	sd	s4,80(sp)
 922:	e4d6                	sd	s5,72(sp)
 924:	e0da                	sd	s6,64(sp)
 926:	fc5e                	sd	s7,56(sp)
 928:	f862                	sd	s8,48(sp)
 92a:	f466                	sd	s9,40(sp)
 92c:	f06a                	sd	s10,32(sp)
 92e:	ec6e                	sd	s11,24(sp)
 930:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 932:	0005c903          	lbu	s2,0(a1)
 936:	18090f63          	beqz	s2,ad4 <vprintf+0x1c0>
 93a:	8aaa                	mv	s5,a0
 93c:	8b32                	mv	s6,a2
 93e:	00158493          	addi	s1,a1,1
  state = 0;
 942:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 944:	02500a13          	li	s4,37
 948:	4c55                	li	s8,21
 94a:	00000c97          	auipc	s9,0x0
 94e:	40ec8c93          	addi	s9,s9,1038 # d58 <malloc+0x180>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 952:	02800d93          	li	s11,40
  putc(fd, 'x');
 956:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 958:	00000b97          	auipc	s7,0x0
 95c:	458b8b93          	addi	s7,s7,1112 # db0 <digits>
 960:	a839                	j	97e <vprintf+0x6a>
        putc(fd, c);
 962:	85ca                	mv	a1,s2
 964:	8556                	mv	a0,s5
 966:	00000097          	auipc	ra,0x0
 96a:	ee0080e7          	jalr	-288(ra) # 846 <putc>
 96e:	a019                	j	974 <vprintf+0x60>
    } else if(state == '%'){
 970:	01498d63          	beq	s3,s4,98a <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 974:	0485                	addi	s1,s1,1
 976:	fff4c903          	lbu	s2,-1(s1)
 97a:	14090d63          	beqz	s2,ad4 <vprintf+0x1c0>
    if(state == 0){
 97e:	fe0999e3          	bnez	s3,970 <vprintf+0x5c>
      if(c == '%'){
 982:	ff4910e3          	bne	s2,s4,962 <vprintf+0x4e>
        state = '%';
 986:	89d2                	mv	s3,s4
 988:	b7f5                	j	974 <vprintf+0x60>
      if(c == 'd'){
 98a:	11490c63          	beq	s2,s4,aa2 <vprintf+0x18e>
 98e:	f9d9079b          	addiw	a5,s2,-99
 992:	0ff7f793          	zext.b	a5,a5
 996:	10fc6e63          	bltu	s8,a5,ab2 <vprintf+0x19e>
 99a:	f9d9079b          	addiw	a5,s2,-99
 99e:	0ff7f713          	zext.b	a4,a5
 9a2:	10ec6863          	bltu	s8,a4,ab2 <vprintf+0x19e>
 9a6:	00271793          	slli	a5,a4,0x2
 9aa:	97e6                	add	a5,a5,s9
 9ac:	439c                	lw	a5,0(a5)
 9ae:	97e6                	add	a5,a5,s9
 9b0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 9b2:	008b0913          	addi	s2,s6,8
 9b6:	4685                	li	a3,1
 9b8:	4629                	li	a2,10
 9ba:	000b2583          	lw	a1,0(s6)
 9be:	8556                	mv	a0,s5
 9c0:	00000097          	auipc	ra,0x0
 9c4:	ea8080e7          	jalr	-344(ra) # 868 <printint>
 9c8:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 9ca:	4981                	li	s3,0
 9cc:	b765                	j	974 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9ce:	008b0913          	addi	s2,s6,8
 9d2:	4681                	li	a3,0
 9d4:	4629                	li	a2,10
 9d6:	000b2583          	lw	a1,0(s6)
 9da:	8556                	mv	a0,s5
 9dc:	00000097          	auipc	ra,0x0
 9e0:	e8c080e7          	jalr	-372(ra) # 868 <printint>
 9e4:	8b4a                	mv	s6,s2
      state = 0;
 9e6:	4981                	li	s3,0
 9e8:	b771                	j	974 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9ea:	008b0913          	addi	s2,s6,8
 9ee:	4681                	li	a3,0
 9f0:	866a                	mv	a2,s10
 9f2:	000b2583          	lw	a1,0(s6)
 9f6:	8556                	mv	a0,s5
 9f8:	00000097          	auipc	ra,0x0
 9fc:	e70080e7          	jalr	-400(ra) # 868 <printint>
 a00:	8b4a                	mv	s6,s2
      state = 0;
 a02:	4981                	li	s3,0
 a04:	bf85                	j	974 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 a06:	008b0793          	addi	a5,s6,8
 a0a:	f8f43423          	sd	a5,-120(s0)
 a0e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 a12:	03000593          	li	a1,48
 a16:	8556                	mv	a0,s5
 a18:	00000097          	auipc	ra,0x0
 a1c:	e2e080e7          	jalr	-466(ra) # 846 <putc>
  putc(fd, 'x');
 a20:	07800593          	li	a1,120
 a24:	8556                	mv	a0,s5
 a26:	00000097          	auipc	ra,0x0
 a2a:	e20080e7          	jalr	-480(ra) # 846 <putc>
 a2e:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a30:	03c9d793          	srli	a5,s3,0x3c
 a34:	97de                	add	a5,a5,s7
 a36:	0007c583          	lbu	a1,0(a5)
 a3a:	8556                	mv	a0,s5
 a3c:	00000097          	auipc	ra,0x0
 a40:	e0a080e7          	jalr	-502(ra) # 846 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a44:	0992                	slli	s3,s3,0x4
 a46:	397d                	addiw	s2,s2,-1
 a48:	fe0914e3          	bnez	s2,a30 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 a4c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a50:	4981                	li	s3,0
 a52:	b70d                	j	974 <vprintf+0x60>
        s = va_arg(ap, char*);
 a54:	008b0913          	addi	s2,s6,8
 a58:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 a5c:	02098163          	beqz	s3,a7e <vprintf+0x16a>
        while(*s != 0){
 a60:	0009c583          	lbu	a1,0(s3)
 a64:	c5ad                	beqz	a1,ace <vprintf+0x1ba>
          putc(fd, *s);
 a66:	8556                	mv	a0,s5
 a68:	00000097          	auipc	ra,0x0
 a6c:	dde080e7          	jalr	-546(ra) # 846 <putc>
          s++;
 a70:	0985                	addi	s3,s3,1
        while(*s != 0){
 a72:	0009c583          	lbu	a1,0(s3)
 a76:	f9e5                	bnez	a1,a66 <vprintf+0x152>
        s = va_arg(ap, char*);
 a78:	8b4a                	mv	s6,s2
      state = 0;
 a7a:	4981                	li	s3,0
 a7c:	bde5                	j	974 <vprintf+0x60>
          s = "(null)";
 a7e:	00000997          	auipc	s3,0x0
 a82:	2d298993          	addi	s3,s3,722 # d50 <malloc+0x178>
        while(*s != 0){
 a86:	85ee                	mv	a1,s11
 a88:	bff9                	j	a66 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 a8a:	008b0913          	addi	s2,s6,8
 a8e:	000b4583          	lbu	a1,0(s6)
 a92:	8556                	mv	a0,s5
 a94:	00000097          	auipc	ra,0x0
 a98:	db2080e7          	jalr	-590(ra) # 846 <putc>
 a9c:	8b4a                	mv	s6,s2
      state = 0;
 a9e:	4981                	li	s3,0
 aa0:	bdd1                	j	974 <vprintf+0x60>
        putc(fd, c);
 aa2:	85d2                	mv	a1,s4
 aa4:	8556                	mv	a0,s5
 aa6:	00000097          	auipc	ra,0x0
 aaa:	da0080e7          	jalr	-608(ra) # 846 <putc>
      state = 0;
 aae:	4981                	li	s3,0
 ab0:	b5d1                	j	974 <vprintf+0x60>
        putc(fd, '%');
 ab2:	85d2                	mv	a1,s4
 ab4:	8556                	mv	a0,s5
 ab6:	00000097          	auipc	ra,0x0
 aba:	d90080e7          	jalr	-624(ra) # 846 <putc>
        putc(fd, c);
 abe:	85ca                	mv	a1,s2
 ac0:	8556                	mv	a0,s5
 ac2:	00000097          	auipc	ra,0x0
 ac6:	d84080e7          	jalr	-636(ra) # 846 <putc>
      state = 0;
 aca:	4981                	li	s3,0
 acc:	b565                	j	974 <vprintf+0x60>
        s = va_arg(ap, char*);
 ace:	8b4a                	mv	s6,s2
      state = 0;
 ad0:	4981                	li	s3,0
 ad2:	b54d                	j	974 <vprintf+0x60>
    }
  }
}
 ad4:	70e6                	ld	ra,120(sp)
 ad6:	7446                	ld	s0,112(sp)
 ad8:	74a6                	ld	s1,104(sp)
 ada:	7906                	ld	s2,96(sp)
 adc:	69e6                	ld	s3,88(sp)
 ade:	6a46                	ld	s4,80(sp)
 ae0:	6aa6                	ld	s5,72(sp)
 ae2:	6b06                	ld	s6,64(sp)
 ae4:	7be2                	ld	s7,56(sp)
 ae6:	7c42                	ld	s8,48(sp)
 ae8:	7ca2                	ld	s9,40(sp)
 aea:	7d02                	ld	s10,32(sp)
 aec:	6de2                	ld	s11,24(sp)
 aee:	6109                	addi	sp,sp,128
 af0:	8082                	ret

0000000000000af2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 af2:	715d                	addi	sp,sp,-80
 af4:	ec06                	sd	ra,24(sp)
 af6:	e822                	sd	s0,16(sp)
 af8:	1000                	addi	s0,sp,32
 afa:	e010                	sd	a2,0(s0)
 afc:	e414                	sd	a3,8(s0)
 afe:	e818                	sd	a4,16(s0)
 b00:	ec1c                	sd	a5,24(s0)
 b02:	03043023          	sd	a6,32(s0)
 b06:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b0a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b0e:	8622                	mv	a2,s0
 b10:	00000097          	auipc	ra,0x0
 b14:	e04080e7          	jalr	-508(ra) # 914 <vprintf>
}
 b18:	60e2                	ld	ra,24(sp)
 b1a:	6442                	ld	s0,16(sp)
 b1c:	6161                	addi	sp,sp,80
 b1e:	8082                	ret

0000000000000b20 <printf>:

void
printf(const char *fmt, ...)
{
 b20:	711d                	addi	sp,sp,-96
 b22:	ec06                	sd	ra,24(sp)
 b24:	e822                	sd	s0,16(sp)
 b26:	1000                	addi	s0,sp,32
 b28:	e40c                	sd	a1,8(s0)
 b2a:	e810                	sd	a2,16(s0)
 b2c:	ec14                	sd	a3,24(s0)
 b2e:	f018                	sd	a4,32(s0)
 b30:	f41c                	sd	a5,40(s0)
 b32:	03043823          	sd	a6,48(s0)
 b36:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b3a:	00840613          	addi	a2,s0,8
 b3e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b42:	85aa                	mv	a1,a0
 b44:	4505                	li	a0,1
 b46:	00000097          	auipc	ra,0x0
 b4a:	dce080e7          	jalr	-562(ra) # 914 <vprintf>
}
 b4e:	60e2                	ld	ra,24(sp)
 b50:	6442                	ld	s0,16(sp)
 b52:	6125                	addi	sp,sp,96
 b54:	8082                	ret

0000000000000b56 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b56:	1141                	addi	sp,sp,-16
 b58:	e422                	sd	s0,8(sp)
 b5a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b5c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b60:	00000797          	auipc	a5,0x0
 b64:	4a07b783          	ld	a5,1184(a5) # 1000 <freep>
 b68:	a02d                	j	b92 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b6a:	4618                	lw	a4,8(a2)
 b6c:	9f2d                	addw	a4,a4,a1
 b6e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b72:	6398                	ld	a4,0(a5)
 b74:	6310                	ld	a2,0(a4)
 b76:	a83d                	j	bb4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b78:	ff852703          	lw	a4,-8(a0)
 b7c:	9f31                	addw	a4,a4,a2
 b7e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b80:	ff053683          	ld	a3,-16(a0)
 b84:	a091                	j	bc8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b86:	6398                	ld	a4,0(a5)
 b88:	00e7e463          	bltu	a5,a4,b90 <free+0x3a>
 b8c:	00e6ea63          	bltu	a3,a4,ba0 <free+0x4a>
{
 b90:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b92:	fed7fae3          	bgeu	a5,a3,b86 <free+0x30>
 b96:	6398                	ld	a4,0(a5)
 b98:	00e6e463          	bltu	a3,a4,ba0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b9c:	fee7eae3          	bltu	a5,a4,b90 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 ba0:	ff852583          	lw	a1,-8(a0)
 ba4:	6390                	ld	a2,0(a5)
 ba6:	02059813          	slli	a6,a1,0x20
 baa:	01c85713          	srli	a4,a6,0x1c
 bae:	9736                	add	a4,a4,a3
 bb0:	fae60de3          	beq	a2,a4,b6a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 bb4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 bb8:	4790                	lw	a2,8(a5)
 bba:	02061593          	slli	a1,a2,0x20
 bbe:	01c5d713          	srli	a4,a1,0x1c
 bc2:	973e                	add	a4,a4,a5
 bc4:	fae68ae3          	beq	a3,a4,b78 <free+0x22>
    p->s.ptr = bp->s.ptr;
 bc8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 bca:	00000717          	auipc	a4,0x0
 bce:	42f73b23          	sd	a5,1078(a4) # 1000 <freep>
}
 bd2:	6422                	ld	s0,8(sp)
 bd4:	0141                	addi	sp,sp,16
 bd6:	8082                	ret

0000000000000bd8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 bd8:	7139                	addi	sp,sp,-64
 bda:	fc06                	sd	ra,56(sp)
 bdc:	f822                	sd	s0,48(sp)
 bde:	f426                	sd	s1,40(sp)
 be0:	f04a                	sd	s2,32(sp)
 be2:	ec4e                	sd	s3,24(sp)
 be4:	e852                	sd	s4,16(sp)
 be6:	e456                	sd	s5,8(sp)
 be8:	e05a                	sd	s6,0(sp)
 bea:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bec:	02051493          	slli	s1,a0,0x20
 bf0:	9081                	srli	s1,s1,0x20
 bf2:	04bd                	addi	s1,s1,15
 bf4:	8091                	srli	s1,s1,0x4
 bf6:	0014899b          	addiw	s3,s1,1
 bfa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 bfc:	00000517          	auipc	a0,0x0
 c00:	40453503          	ld	a0,1028(a0) # 1000 <freep>
 c04:	c515                	beqz	a0,c30 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c06:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c08:	4798                	lw	a4,8(a5)
 c0a:	02977f63          	bgeu	a4,s1,c48 <malloc+0x70>
 c0e:	8a4e                	mv	s4,s3
 c10:	0009871b          	sext.w	a4,s3
 c14:	6685                	lui	a3,0x1
 c16:	00d77363          	bgeu	a4,a3,c1c <malloc+0x44>
 c1a:	6a05                	lui	s4,0x1
 c1c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c20:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c24:	00000917          	auipc	s2,0x0
 c28:	3dc90913          	addi	s2,s2,988 # 1000 <freep>
  if(p == (char*)-1)
 c2c:	5afd                	li	s5,-1
 c2e:	a895                	j	ca2 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 c30:	00000797          	auipc	a5,0x0
 c34:	3f078793          	addi	a5,a5,1008 # 1020 <base>
 c38:	00000717          	auipc	a4,0x0
 c3c:	3cf73423          	sd	a5,968(a4) # 1000 <freep>
 c40:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c42:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c46:	b7e1                	j	c0e <malloc+0x36>
      if(p->s.size == nunits)
 c48:	02e48c63          	beq	s1,a4,c80 <malloc+0xa8>
        p->s.size -= nunits;
 c4c:	4137073b          	subw	a4,a4,s3
 c50:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c52:	02071693          	slli	a3,a4,0x20
 c56:	01c6d713          	srli	a4,a3,0x1c
 c5a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c5c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c60:	00000717          	auipc	a4,0x0
 c64:	3aa73023          	sd	a0,928(a4) # 1000 <freep>
      return (void*)(p + 1);
 c68:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c6c:	70e2                	ld	ra,56(sp)
 c6e:	7442                	ld	s0,48(sp)
 c70:	74a2                	ld	s1,40(sp)
 c72:	7902                	ld	s2,32(sp)
 c74:	69e2                	ld	s3,24(sp)
 c76:	6a42                	ld	s4,16(sp)
 c78:	6aa2                	ld	s5,8(sp)
 c7a:	6b02                	ld	s6,0(sp)
 c7c:	6121                	addi	sp,sp,64
 c7e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c80:	6398                	ld	a4,0(a5)
 c82:	e118                	sd	a4,0(a0)
 c84:	bff1                	j	c60 <malloc+0x88>
  hp->s.size = nu;
 c86:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c8a:	0541                	addi	a0,a0,16
 c8c:	00000097          	auipc	ra,0x0
 c90:	eca080e7          	jalr	-310(ra) # b56 <free>
  return freep;
 c94:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c98:	d971                	beqz	a0,c6c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c9a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c9c:	4798                	lw	a4,8(a5)
 c9e:	fa9775e3          	bgeu	a4,s1,c48 <malloc+0x70>
    if(p == freep)
 ca2:	00093703          	ld	a4,0(s2)
 ca6:	853e                	mv	a0,a5
 ca8:	fef719e3          	bne	a4,a5,c9a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 cac:	8552                	mv	a0,s4
 cae:	00000097          	auipc	ra,0x0
 cb2:	b80080e7          	jalr	-1152(ra) # 82e <sbrk>
  if(p == (char*)-1)
 cb6:	fd5518e3          	bne	a0,s5,c86 <malloc+0xae>
        return 0;
 cba:	4501                	li	a0,0
 cbc:	bf45                	j	c6c <malloc+0x94>
