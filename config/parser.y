%token DEFBRK COLON HEX OCTAL INTEGER IDENT CSR IVEC INTR
	INIT OPEN CLOSE	READ WRITE SEEK CNTL IS ON GETC PUTC
%{
#include <stdio.h>
#include <stdlib.h>
#include "lexer.c"

#define	CONFIGC		"conf.c"		// name of .c output
#define	CONFIGH		"conf.h"		// name of .h output
#define	CONFHREF	"\"conf.h\""		// how conf.h referenced
#define	DEFAULT		"xinu.conf"		// name of input file

FILE *confc;
FILE *confh;

char *dbstr;
int ndevs = 0;
int currname = -1;
int currtname = -1;
int currdname = -1;
int brkcount = 0;

// Symbol table.
struct syment {
	char *symname;
	int symoccurs;
} symtab[250];

int nsym = 0;
int lineno = 1;
char *doing = "device type declaration";
char *s;

struct dvtype {
	char *dvname;		// device name (not used in types)
	char *dvtname;		// type name
	int dvtnum;		// symbol table index of type
	char *dvdevice;		// device name
	int dvcsr;		// Control Status Register addr
	int dvivec;		// input interrupt vector
	char dvintr[20];	// input interrupt routine
	char dvinit[20];	// init routine name
	char dvopen[20];	// open routine name
	char dvclose[20];	// close routine name
	char dvread[20];	// read routine name
	char dvwrite[20];	// write routine name
	char dvcntl[20];	// control routine name
	char dvseek[20];	// seek routine name
	char dvgetc[20];	// getc routine name
	char dvputc[20];	// putc routine name
	int dvminor;		// device number 0,1,...
	struct dvtype *dvnext;	// next node on the list
};
typedef struct dvtype *dvptr;

dvptr ftypes = NULL;		// linked list of device types.
dvptr devs = NULL;		// linked list of device decls.
dvptr lastdv = NULL;
dvptr currtype = NULL;

char *ftout[] = {
	"struct\tdevsw\t{\t\t\t// device table entry\n",
	"\tint\tnum;\n",
	"\tchar\t*name;\n",
	"\tvoid\t(*init)();\n",
	"\tint\t(*open)();\n",
	"\tint\t(*close)();\n",
	"\tint\t(*read)();\n",
	"\tint\t(*write)();\n",
	"\tint\t(*seek)();\n",
	"\tint\t(*getc)();\n",
	"\tint\t(*putc)();\n",
	"\tint\t(*ctl)();\n",
	"\tvoid\t*csr;\n",
	"\tint\tivec;\n",
	"\tvoid\t(*intr)();\n",
	"\tchar\t*iobuf;\n",
	"\tint\tminor;\n",
	"\t};\n\n",
	"extern\tstruct\tdevsw devtab[];",
	"\t\t// one entry per device\n",
	NULL
};

void yyerror(char *s);
int lookup(char *str, int len);
int strtoi(char *str);
void newattr(int tok, int val);
int cktname(int symid);
void mktype(int deviceid);
void initattr(dvptr fstr, int tnum, int deviceid);
void mkdev(int nameid, int typid, int deviceid);
int ckdname(int devid);
%}
%%
config.input	:	devicetypes devicedescriptors
		;
devicetypes	:	ftypes DEFBRK
					{doing = "device definitions";}
		;
ftypes		:	/**/
		|	ftypes ftype
		;
ftype		:	tname device.list
		;
device.list	:	devheader attribute.list
		|	device.list devheader attribute.list
		;
devheader	:	ON id
					{mktype($2);}
		;
tname		:	id COLON
					{$$ = currtname = cktname($1);}
		;
id		:	IDENT
					{$$ = currname =
					 lookup(yytext,yyleng);
					}
		;
attribute.list	:	/**/
		|	attribute.list attribute
		;
attribute	:	CSR number
					{newattr(CSR,$2);}
		|	IVEC number
					{newattr(IVEC,$2);}
		|	INTR id
					{newattr(INTR,$2);}
		|	OPEN id
					{newattr(OPEN,$2);}
		|	CLOSE id
					{newattr(CLOSE,$2);}
		|	INIT id
					{newattr(INIT,$2);}
		|	GETC id
					{newattr(GETC,$2);}
		|	PUTC id
					{newattr(PUTC,$2);}
		|	READ id
					{newattr(READ,$2);}
		|	WRITE id
					{newattr(WRITE,$2);}
		|	SEEK id
					{newattr(SEEK,$2);}
		|	CNTL id
					{newattr(CNTL,$2);}
		;
number		:	INTEGER
					{$$ = strtoi(yytext);}
		|	HEX
					{$$ = strtoi(yytext);}
		|	OCTAL
					{$$ = strtoi(yytext);}
		;
devicedescriptors	:	/**/
		|	devicedescriptors descriptor
		;
descriptor	:	fspec attribute.list
		;
fspec		:	dname IS id optional.on
					{mkdev($1,$3,$4);}
		;
dname		:	id
					{$$ = currdname = ckdname($1);}
		;
optional.on	:	/**/
					{$$ = 0;}
		|	ON id
					{$$ = $2;}
		;
%%

int
main(int argc, char *argv[])
{
	int n, i, fcount;
	dvptr s;
	int verbose = 0;
	char *p;
	char c;

	if (argc > 1 && (strcmp("-v", argv[1]) == 0)) {
		argc--;
		argv++;
		verbose++;
	}
	if (argc > 2) {
		fprintf(stderr, "use: config [-v] [file]\n");
		exit(1);
	}
	if (verbose)
		printf("Opening input file...\n");
	if (argc == 2) {
		if (freopen(argv[1], "r", stdin) == NULL) {
			fprintf(stderr, "Can't open %s\n", argv[1]);
			exit(1);
		}
	} else {		// try to open Configuration file
		if (freopen(DEFAULT, "r", stdin) == NULL) {
			fprintf(stderr, "Can't open %s\n", DEFAULT);
			exit(1);
		}
	}

	// Parse the Configuration file
	if (verbose)
		printf("Parsing configuration specs...\n");
	if ((n = yyparse()) != 0)
		exit(n);

	// write config.h and config.c
	if (verbose)
		printf("Opening output files...\n");
	if ((confc = fopen(CONFIGC, "w")) == NULL) {
		fprintf(stderr, "Can't write on %s\n", CONFIGC);
		exit(1);
	}

	if ((confh = fopen(CONFIGH, "w")) == NULL) {
		fprintf(stderr, "Can't write on %s\n", CONFIGH);
		exit(1);
	}
	fprintf(confh, "// conf.h (GENERATED FILE; DO NOT EDIT)\n");
	fprintf(confc, "// conf.c (GENERATED FILE; DO NOT EDIT)\n");
	fprintf(confc, "\n#include <kernel.h>\n");
	fprintf(confc, "\n#include %s\n", CONFHREF);
	fprintf(confh, "\n#define\tNULLPTR\t(char *)0\n");

	if (verbose)
		printf("Writing output...\n");
	fprintf(confh, "\n// Device table declarations\n");
	for (i = 0; (p = ftout[i]) != NULL; i++)
		fprintf(confh, "%s", p);

	// write device declarations and definitions; count type refs.
	fprintf(confh, "\n// Device name definitions\n");
	for (i = 0, s = devs; s != NULL; s = s->dvnext, i++) {
		fprintf(confh, "#define\t%-12s%d\t\t\t// type %-8s\n",
			s->dvname, i, s->dvtname);
		s->dvminor = symtab[s->dvtnum].symoccurs++;
	}

	// write count of device types
	fprintf(confh, "\n// Control block sizes\n");
	for (i = 0; i < nsym; i++)
		if (symtab[i].symoccurs > 0) {
			fprintf(confh, "#define\tN%s\t%d\n",
				symtab[i].symname, symtab[i].symoccurs);
		}
	if (ndevs > 0)
		fprintf(confh, "\n#define\tNDEVS\t%d\n\n", ndevs);

	// empty symbol table, collect, and write names of all I/O routines
	nsym = 0;
	for (s = devs; s != NULL; s = s->dvnext) {
		lookup(s->dvinit, strlen(s->dvinit));
		lookup(s->dvopen, strlen(s->dvopen));
		lookup(s->dvclose, strlen(s->dvclose));
		lookup(s->dvread, strlen(s->dvread));
		lookup(s->dvwrite, strlen(s->dvwrite));
		lookup(s->dvseek, strlen(s->dvseek));
		lookup(s->dvcntl, strlen(s->dvcntl));
		lookup(s->dvgetc, strlen(s->dvgetc));
		lookup(s->dvputc, strlen(s->dvputc));
		lookup(s->dvintr, strlen(s->dvintr));

	}

	// produce devtab (giant I/O switch table)
	fprintf(confc, "\n// device independent I/O switch\n");
	if (ndevs > 0) {
		fprintf(confc, "struct\tdevsw\tdevtab[NDEVS] = {\n");
		fprintf(confc, "%s",
			"// Format of entries is:\n"
			"// device-number, device-name,\n"
			"// init, open, close,\n"
			"// read, write, seek,\n"
			"// getc, putc, cntl,\n"
			"// device-csr-address, input-vector, output-vector,\n"
			"// intr-handler, control-block, minor-device,\n");
	}
	for (fcount = 0, s = devs; s != NULL; s = s->dvnext, fcount++) {
		fprintf(confc, "\n//  %s  is %s\n", s->dvname,
			s->dvtname);
		fprintf(confc, "{ %d, \"%s\",\n", fcount, s->dvname);
		fprintf(confc, "%s, %s, %s,\n",
			s->dvinit, s->dvopen, s->dvclose);
		fprintf(confc, "%s, %s, %s,\n",
			s->dvread, s->dvwrite, s->dvseek);
		fprintf(confc, "%s, %s, %s,\n",
			s->dvgetc, s->dvputc, s->dvcntl);
		fprintf(confc, "(void*)0x%08x, 0x%02x,\n",
			s->dvcsr, s->dvivec);
		fprintf(confc, "%s, NULLPTR, %d",
			s->dvintr, s->dvminor);
		if (s->dvnext != NULL)
			fprintf(confc, "},\n");
		else
			fprintf(confc, "}\n\t};");
	}

	// Copy definitions to output
	if (brkcount == 2 && verbose)
		printf("Copying definitions to %s...\n", CONFIGH);
	if (brkcount == 2)
		while ((c = input()) != 0)	// lex input routine
			putc(c, confh);

	// guarantee conf.c written later than conf.c for make
	fclose(confh);
	fprintf(confc, "\n");
	fclose(confc);

	// finish up and write report for user if requested
	if (verbose) {
		printf("\nConfiguration complete. Number of devs=%d:\n\n", ndevs);
		for (s = devs; s != NULL; s = s->dvnext)
			printf("Device %s (on %s) csr=0x%-8x, ivec=0x%-3x, minor=%d\n",
				s->dvname, s->dvdevice, s->dvcsr, s->dvivec, s->dvminor);
	}


}

void
yyerror(char *s)
{
	fprintf(stderr, "Syntax error in %s on line %d\n", doing, lineno);
}


//  lookup  --  lookup a name in the symbol table; return position
int
lookup(char *str, int len)
{
	int i;
	char *s;

	if (len >= 20) {
		len = 19;
		fprintf(stderr, "warning: name %s truncated\n", str);
	}
	s = malloc(len + 1);
	strncpy(s, str, len);
	s[len] = '\000';
	for (i = 0; i < nsym; i++) {
		if (strcmp(s, symtab[i].symname) == 0) {
			return i;
		}
	}
	symtab[nsym].symname = s;
	symtab[nsym].symoccurs = 0;
	return nsym++;
}

int
strtoi(char *str)
{
	int n;
	char *err;

	err = NULL;
	n = strtol(str, &err, 0);
	if (err != NULL && *err != '\0') {
		fprintf(stderr, "invalid digit on line %d\n", lineno);
	}

	return n;
}

// newattr -- add a new attribute spec to current type/device description
// tok is token type (attribute type)
// val is symbol number of value
void
newattr(int tok, int val)
{
	char *c;
	dvptr s;

	s = lastdv;
	if (devs == NULL)	// doing types
		s = currtype;
	c = NULL;
	if (val >= 0 && val < nsym) {
		c = symtab[val].symname;
		if (strlen(c) > 20) {
			fprintf(stderr, "Internal overflow\n");
			exit(1);
		}
	}

	switch (tok) {
	case CSR:
		s->dvcsr = val;
		break;
	case IVEC:
		s->dvivec = val;
		break;
	case INTR:
		strcpy(s->dvintr, c);
		break;
	case READ:
		strcpy(s->dvread, c);
		break;
	case WRITE:
		strcpy(s->dvwrite, c);
		break;
	case GETC:
		strcpy(s->dvgetc, c);
		break;
	case PUTC:
		strcpy(s->dvputc, c);
		break;
	case OPEN:
		strcpy(s->dvopen, c);
		break;
	case CLOSE:
		strcpy(s->dvclose, c);
		break;
	case INIT:
		strcpy(s->dvinit, c);
		break;
	case SEEK:
		strcpy(s->dvseek, c);
		break;
	case CNTL:
		strcpy(s->dvcntl, c);
		break;
	default:
		fprintf(stderr, "Internal error 1\n");
	}
}

// cktname  --  check type name for duplicates
int
cktname(int symid)
{
	dvptr s;
	char *name;

	name = symtab[symid].symname;
	for (s = ftypes; s != NULL; s = s->dvnext) {
		if (s->dvtname == name) {
			fprintf(stderr,
				"Duplicate type name %s on line %d\n",
				name, lineno);
			exit(1);
		}
	}
	return symid;
}

// mktype  --  make a node in the type list and initialize to defaults
void
mktype(int deviceid)
{
	dvptr s, p;
	char *tn, *dn;

	p = NULL;
	tn = symtab[currtname].symname;
	dn = symtab[deviceid].symname;
	for (s = ftypes; s != NULL; s = s->dvnext) {
		if (s->dvtname == tn && s->dvdevice == dn) {
			fprintf(stderr,
				"Duplicate device %s for type %s on line %d\n",
				dn, tn, lineno);
			exit(1);
		}
		p = s;
	}
	currtype = s = (dvptr) malloc(sizeof(struct dvtype));
	if (ftypes != NULL) {
		p->dvnext = s;
	} else {
		ftypes = s;
	}
	initattr(s, currtname, deviceid);
}

// initialize attributes in a type declaration node to typename...
void
initattr(dvptr fstr, int tnum, int deviceid)
{
	char *typnam = symtab[tnum].symname;
	fstr->dvname = NULL;
	fstr->dvtname = typnam;
	fstr->dvtnum = tnum;
	fstr->dvdevice = symtab[deviceid].symname;
	fstr->dvcsr = 0;
	fstr->dvivec = 0;
	strcpy(fstr->dvintr, typnam);
	strcat(fstr->dvintr, "intr");
	strcpy(fstr->dvinit, typnam);
	strcat(fstr->dvinit, "init");
	strcpy(fstr->dvopen, typnam);
	strcat(fstr->dvopen, "open");
	strcpy(fstr->dvclose, typnam);
	strcat(fstr->dvclose, "close");
	strcpy(fstr->dvread, typnam);
	strcat(fstr->dvread, "read");
	strcpy(fstr->dvwrite, typnam);
	strcat(fstr->dvwrite, "write");
	strcpy(fstr->dvcntl, typnam);
	strcat(fstr->dvcntl, "control");
	strcpy(fstr->dvseek, typnam);
	strcat(fstr->dvseek, "seek");
	strcpy(fstr->dvgetc, typnam);
	strcat(fstr->dvgetc, "getc");
	strcpy(fstr->dvputc, typnam);
	strcat(fstr->dvputc, "putc");
	fstr->dvminor = 0;
}

// mkdev  --  make a node on the device list
void
mkdev(int nameid, int typid, int deviceid)
{
	dvptr s;
	char *devn, *tn, *dn;
	int found;

	s = (dvptr) malloc(sizeof(struct dvtype));
	s->dvnext = NULL;
	if (devs == NULL) {
		devs = s;
		lastdv = s;
	} else {
		lastdv->dvnext = s;
		lastdv = s;
	}
	ndevs++;
	tn = symtab[typid].symname;
	devn = symtab[nameid].symname;
	if (deviceid >= 0)
		dn = symtab[deviceid].symname;
	else
		dn = NULL;
	found = 0;
	for (s = ftypes; s != NULL; s = s->dvnext) {
		if (s->dvtname == tn && (dn == NULL || s->dvdevice == dn)) {
			memmove(lastdv, s, sizeof(struct dvtype));
			found = 1;
			break;
		}
	}
	if (found == 0) {
		fprintf(stderr,
			"Bad type or device name in declaration of %s on line %d\n",
			devn, lineno);
		exit(1);
	}
	lastdv->dvnext = NULL;
	lastdv->dvname = devn;
}

// chdname  -- check for duplicate device name
int
ckdname(int devid)
{
	char *name = symtab[devid].symname;

	for (dvptr s = devs; s != NULL; s = s->dvnext) {
		if (s->dvname == name) {
			fprintf(stderr,
				"Duplicate device name %s on line %d\n",
				name, lineno);
			exit(1);
		}
	}

	return devid;
}
