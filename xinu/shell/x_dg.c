#include <stddef.h>
#include <string.h>

#include "conf.h"
#include "kernel.h"
#include "network.h"

//------------------------------------------------------------------------
// x_dg - (command dg) print info for currently open datagram devices
//------------------------------------------------------------------------
COMMAND
x_dg(int stdin, int stdout, int stderr, int nargs, char *args[])
{

	for (int i = 0; i < Ndg; i++) {
		struct dgblk *dgptr = &dgtab[i];
		char str[80];

		if (dgptr->dg_state == DG_FREE)
			continue;
		sprintf(str, "Dev=%2d: lport=%4d, fport=%4d, ",
			dgptr->dg_dnum, dgptr->dg_lport, dgptr->dg_fport);
		sprintf(&str[strlen(str)],
			"mode=%03o, xport=%2d addr=%d.%d.%d.%d\n",
			dgptr->dg_mode, dgptr->dg_xport,
			dgptr->dg_faddr[0] & 0xFF,
			dgptr->dg_faddr[1] & 0xFF,
			dgptr->dg_faddr[2] & 0xFF,
			dgptr->dg_faddr[3] & 0xFF);
		write(stdout, str, strlen(str));
	}

	return OK;
}
