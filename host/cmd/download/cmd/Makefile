#
#  Makefile for the version 7 downloader umbrella commands
#

HDIR	=	../h
CFLAGS	=	-O -I$(HDIR)
DIR	=	/usr/Xinu
DEVLIB	=	../lib/libd.a
BINDIR	=	$(DIR)/bin
LIBDIR	=	$(DIR)/lib
CROSSAS	=	$(DIR)/bin/as11
INC	=	$(DIR)/include/sys.s

HFILES	=	../h/baud.h ../h/dlpack.h ../h/download.h	\
		../h/freedev.h ../h/getdev.h ../h/ulock.h	\
		../h/upload.h

all:		download odt lusers odtunlock upload

install:	all
		chmod 755 download odt lusers odtunlock upload
		cp download odt lusers odtunlock upload $(BINDIR)
clean:
		rm -rf *.o .,* ,* core download odt lusers odtunlock upload

download:	download.o $(DEVLIB)
		cc $(CFLAGS) -o download download.o $(DEVLIB)

odt:		odt.o $(DEVLIB)
		cc $(CFLAGS) -o odt odt.o $(DEVLIB)

lusers:		lusers.o $(DEVLIB)
		cc $(CFLAGS) -o lusers lusers.o $(DEVLIB)

odtunlock:	odtunlock.o $(DEVLIB)
		cc $(CFLAGS) -o odtunlock odtunlock.o $(DEVLIB)

upload:		upload.o $(DEVLIB)
		cc $(CFLAGS) -o upload upload.o $(DEVLIB)

$(DEVLIB):
		(cd ../lib ; make install)

download.o:	download.c $(HFILES)
		cc $(CFLAGS) -c download.c

odt.o:		odt.c ../h/getdev.h ../h/baud.h
		cc $(CFLAGS) -c odt.c

lusers.o: 	lusers.c ../h/getdev.h
		cc $(CFLAGS) -c lusers.c

odtunlock.o:	odtunlock.c ../h/freedev.h ../h/getdev.h ../h/ulock.h
		cc $(CFLAGS) -c odtunlock.c
 
upload.o:	upload.c $(HFILES)
		cc $(CFLAGS) -c upload.c

depend:
		grep '^#include' *.c				\
		| sed	-e 's/</"..\/h\//;s/>/"/'		\
			-e 's/:[^"]*"\([^"]*\)".*/: \1/'	\
		| sed	's/\.c/.o/' >makedep
		echo '/^# DO NOT DELETE	THIS LINE/+2,$$d' >eddep
		echo '$$r makedep' >>eddep
		echo 'w' >>eddep
		cp Makefile .,oldmake
		cp Makefile ,Makefile
		ed - ,Makefile < eddep
		/bin/rm eddep makedep
		echo '#	DEPENDENCIES MUST END AT END OF	FILE' >>,Makefile
		echo '#	IF YOU PUT STUFF HERE IT WILL GO AWAY'>>,Makefile
		echo '#	see make depend	above'>>,Makefile
		/bin/mv ,Makefile Makefile

# DO NOT DELETE	THIS LINE
# DEPENDENCIES MUST END	AT END OF FILE
download.o: /usr/include/stdio.h
download.o: /usr/include/sgtty.h
download.o: /usr/include/ctype.h
download.o: ../h/baud.h
download.o: ../h/getdev.h
download.o: /usr/include/sys/file.h
download.o: ../h/download.h
lusers.o: /usr/include/sys/file.h
lusers.o: /usr/include/sys/types.h
lusers.o: /usr/include/sys/stat.h
lusers.o: ../h/getdev.h
odt.o: /usr/include/stdio.h
odt.o: /usr/include/sgtty.h
odt.o: /usr/include/signal.h
odt.o: /usr/include/sys/types.h
odt.o: /usr/include/sys/stat.h
odt.o: ../h/getdev.h
odt.o: ../h/baud.h
odtunlock.o: /usr/include/stdio.h
odtunlock.o: ../h/freedev.h
odtunlock.o: ../h/getdev.h
odtunlock.o: ../h/ulock.h
upload.o: /usr/include/stdio.h
upload.o: /usr/include/sgtty.h
upload.o: /usr/include/ctype.h
upload.o: ../h/baud.h
upload.o: ../h/getdev.h
upload.o: /usr/include/sys/file.h
upload.o: ../h/upload.h
#	DEPENDENCIES MUST END AT END OF	FILE
#	IF YOU PUT STUFF HERE IT WILL GO AWAY
#	see make depend	above
