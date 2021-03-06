#include "conf.h"
#include "kernel.h"
#include "proc.h"

//------------------------------------------------------------------------
// resume  --  unsuspend a process, making it ready; return the priority
//------------------------------------------------------------------------
SYSCALL
resume(int pid)
{
	int ps;			// saved processor status
	struct pentry *pptr;	// pointer to proc. tab. entry
	int prio;		// priority to return

	ps = disable();
	if (isbadpid(pid) || (pptr = &proctab[pid])->pstate != PRSUSP) {
		restore(ps);
		return SYSERR;
	}
	prio = pptr->pprio;
	readysched(pid);
	restore(ps);

	return prio;
}
