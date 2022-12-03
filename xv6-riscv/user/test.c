#include "kernel/types.h"
#include "user/user.h"

int main(){
	for(int i=0; i<1000; i++)
		for(int j=0; j<1000; j++)
			for(int k=0; k<1000; k++)
				for(int l=0; l<1000; l++)
					continue;
	return 0;
}
