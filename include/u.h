// u.h - Types and useful constants.

#ifndef U_H__
#define U_H__

#include "stddef.h"

typedef unsigned char  byte;
typedef unsigned char  u8;
typedef unsigned short u16;
typedef unsigned int   u32;
typedef unsigned long  ulong;
typedef signed char    i8;
typedef signed short   i16;
typedef signed int     i32;
typedef int            word;	// Register word.
typedef unsigned int   uword;

//
typedef	u32		DBADDR;

// Symbolic constants used throughout Xinu

typedef	char		Bool;		// Boolean type
#define	FALSE		0		// Boolean constants
#define	TRUE		1
#define	NULLCH		'\0'		// The null character
#define	NULLSTR		""		// Pointer to empty string
#define	SYSCALL		int		// System call declaration
#define	LOCAL		static		// Local procedure declaration
#define	COMMAND		int		// Shell command declaration
#define	BUILTIN		int		// Shell builtin " "
#define	INTPROC		void		// Interrupt procedure  "
#define	PROCESS		int		// Process declaration
#define	RESCHYES	1		// tell	ready to reschedule
#define	RESCHNO		0		// tell	ready not to resch.
#define	MININT		-32768		// minimum integer (-32768)
#define	MAXINT		0077777		// maximum integer
#define	LOWBYTE		0377		// mask for low-order 8 bits
#define	HIBYTE		0177400		// mask for high 8 of 16 bits
#define	LOW16		0177777		// mask for low-order 16 bits
#define	SP		6		// reg.	6 is stack pointer
#define	PC		7		// reg.	7 is program counter
#define	PS		8		// proc. status	in 8th reg. loc
#define	MINSTK		40		// minimum process stack size
#define	NULLSTK		300		// process 0 stack size
#define	DISABLE		0340		// PS to disable interrupts
#define	MAGIC		0125252		// unusual value for top of stk

// Universal return constants

#define	OK		 1		// system call ok
#define	SYSERR		-1		// system call failed
#define	EOF		-2		// End-of-file (usu. from read)
#define	TIMEOUT		-3		// time out  (usu. recvtim)
#define	INTRMSG		-4		// keyboard "intr" key pressed
					// (usu. defined as ^B)
// Initialization constants

#define	INITSTK		500		// initial process stack
#define	INITPRIO	20		// initial process priority
#define	INITNAME	"main"		// initial process name
#define	INITARGS	1,0		// initial count/arguments
#define	INITRET		userret		// processes return address
#define	INITPS		0		// initial process PS
#define	INITREG		0		// initial register contents
#define	QUANTUM		10		// clock ticks until preemption

// Miscellaneous utility inline functions

#define	isodd(x)	(01&(int)(x))
#define	min(a,b)	( (a) < (b) ? (a) : (b) )
#define	pause()
#define	halt()

#endif
