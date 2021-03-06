#include "conf.h"
#include "kernel.h"
#include "proc.h"

//------------------------------------------------------------------------
//  sendf  --  sendf a message to another process, forcing delivery
//------------------------------------------------------------------------
SYSCALL
sendf(int pid, int msg)
{
	struct pentry *pptr;
	int ps;

	ps = disable();
	if (isbadpid(pid) || ((pptr = &proctab[pid])->pstate == PRFREE)) {
		restore(ps);
		return SYSERR;
	}
	pptr->pmsg = msg;
	pptr->phasmsg = TRUE;
	if (pptr->pstate == PRRECV)
		readysched(pid);
	else if (pptr->pstate == PRTRECV) {
		unsleep(pid);
		readysched(pid);
	}
	restore(ps);

	return OK;
}
