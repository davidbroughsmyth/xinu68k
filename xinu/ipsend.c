#include "conf.h"
#include "kernel.h"
#include "network.h"
#include "string.h"

//------------------------------------------------------------------------
//  ipsend  -  fill in IP header and send datagram to specified address
//------------------------------------------------------------------------
int
ipsend(IPaddr faddr, struct epacket *packet, int datalen)
{
	static int ipackid = 1;
	struct ip *ipptr;

	packet->ep_hdr.e_ptype = hs2net(EP_IP);
	ipptr = (struct ip *)packet->ep_data;
	ipptr->i_verlen = IVERLEN;
	ipptr->i_svctyp = ISVCTYP;
	ipptr->i_paclen = hs2net(datalen + IPHLEN);
	ipptr->i_id = hs2net(ipackid++);
	ipptr->i_fragoff = hs2net(IFRAGOFF);
	ipptr->i_tim2liv = ITIM2LIV;
	ipptr->i_cksum = 0;
	getaddr(ipptr->i_src);
	memmove(ipptr->i_dest, faddr, IPLEN);
	ipptr->i_cksum = cksum(ipptr, IPHLEN >> 1);

	return route(faddr, packet, EHLEN + IPHLEN + datalen);
}
