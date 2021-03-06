#include "conf.h"
#include "kernel.h"
#include "proc.h"
#include "disk.h"

//------------------------------------------------------------------------
//  dsseek  --  schedule a request to move the disk arm
//------------------------------------------------------------------------
int
dsseek(struct devsw *devptr, DBADDR block)
{
	struct dreq *drptr;
	int ps;

	ps = disable();
	drptr = (struct dreq *)getbuf(dskrbp);
	drptr->drdba = block;
	drptr->drpid = currpid;
	drptr->drbuff = NULL;
	drptr->drop = DSEEK;

	// enqueued with normal policy like other read/write requests
	dskenq(drptr, (struct dsblk *)devptr->iobuf);
	restore(ps);
	return OK;
}
