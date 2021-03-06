#ifndef DISK_H__
#define DISK_H__

#include "u.h"

#include <xebec.h>		// disk controller constants
#include <dtc.h>		// disk interface constants

struct dir;

#define	DBNULL	(DBADDR)0xFFFF	// null disk block address

struct dsblk {			// disk driver control block
	struct dtc *dcsr;	// disk interface csr address
	struct dreq *dreqlst;	// list of pending requests
	int dnum;		// device number of this disk
	int dibsem;		// i-block mutual exclusion sem.
	int dflsem;		// free list  "        "      "
	int ddirsem;		// directory  "        "      "
	int dnfiles;		// num. of currently open files
	struct dir *ddir;	// address of in-core directory
	struct xbdcb ddcb;	// holds command that interface
				// sends to disk controller
};
extern struct dsblk dstab[];

struct dreq {			// node in list of requests
	DBADDR drdba;		// disk block address to use
	int drpid;		// process id making request
	byte *drbuff;		// buffer address for read/write
	char drop;		// operation: READ/WRITE/SEEK
	int drstat;		// returned status OK/SYSERR
	struct dreq *drnext;	// ptr to next node on req. list
};

#define	DRNULL	(struct dreq *)0	// null pointer in request list
#define	DIRBLK	0		// block used to hold directory
#define	DONQ	2		// status if request enqueued
#define	DBUFSIZ	512		// size of disk data block
#define	DREQSIZ	sizeof(struct dreq)	// size of disk request node
#ifndef	NDBUFF
#define	NDBUFF	10		// number of disk data buffers
#endif
#define	NDREQ	10		// number of disk request buf.
#define	DREAD	XOREAD		// read command in dreq.drop
#define	DWRITE	XOWRITE		// write   "
#define	DSEEK	XOSEEK		// seek    "
#define	DSYNC	XOTDR		// sync    "  (test-disk-ready)

extern int dskrbp;		// disk request node buffer pool
extern int dskdbp;		// disk data block buffer pool

// disk control function codes
#define	DSKSYNC	0		// synchronize (flush all I/O)
#define	dssync(ddev)	control((ddev),DSKSYNC, 0);

#define	dsdirec(ddev)	(((struct dsblk *)(devtab[ddev].iobuf))->ddir)

#endif
