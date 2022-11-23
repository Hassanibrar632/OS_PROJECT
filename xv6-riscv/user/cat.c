#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

char buf[512];

void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
    if (write(1, buf, n) != n) {
      fprintf(2, "cat: write error\n");
      exit(1);
    }
  }
  if(n < 0){
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}

void 
cat_n(int fd)
{
  int n;
  int c=1;
  printf("1\t");
  while((n=read(fd,buf,sizeof(buf)))>0){ 
 	for(int i=0;i<sizeof(buf);i++){
		if(buf[i] != '\n'){
			printf("%c",buf[i]);
  		}else{
			c++;
			printf("\n");
			printf("%d \t",c);
		}
	}
	printf("\n");
  }
}

int
main(int argc, char *argv[])
{
  int fd, i;
  if(argv[1][0] == '-' && argv[1][1] == 'n'){
  	for(i = 2; i < argc; i++){
    		if((fd = open(argv[i], 0)) < 0){
      			fprintf(2, "cat: cannot open %s\n", argv[i]);
      			exit(1);
    		}
    		cat_n(fd);
    		close(fd);
  	}
  	exit(0);
  }
  else if(argc <= 1){
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
    close(fd);
  }
  exit(0);
}
