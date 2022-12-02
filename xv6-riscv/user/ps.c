#include "kernel/types.h"
#include "kernel/param.h"
#include "kernel/proc.h"
#include "user/user.h"

struct proc proc[NPROC];

int main(){
	struct proc *p;
	printf("PID\t\tNAME\n");
	for(p = proc; p < &proc[NPROC]; p++)
		if(p->state == RUNNING)
			printf("%d\t\t%s\n", p->pid, p->name);
	return 0;
}
