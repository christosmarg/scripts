.POSIX:

TARGS = ausplit \
	autocomp \
	backup \
	batnfy \
	bookmark \
	deljail \
	doccomp \
	docprev \
	extr \
	fontupd \
	irssi_torconf \
	mkjail \
	mntdroid \
	namefmt \
	passget \
	push \
	rssread \
	screencast \
	se \
	setscreens \
	sysact \
	tag \
	unix \
	upd \
	vdq \
	vds \
	vmstart \
	vmstop \
	walset \
	wttr

PREFIX = /usr/local

all: ${TARGS}
	chmod +x ${TARGS}

dist:
	mkdir -p ${DIST}
	cp -R ${TARGS} ${DIST}
	tar -cf ${DIST}.tar ${DIST}
	gzip ${DIST}.tar
	rm -rf ${DIST}

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f ${TARGS} ${DESTDIR}${PREFIX}/bin
	for targ in ${TARGS} ; do \
		chmod 755 ${DESTDIR}${PREFIX}/bin/$${targ} ; \
	done

uninstall:
	for targ in ${TARGS} ; do \
		rm -f ${DESTDIR}${PREFIX}/bin/$${targ} ; \
	done

clean:
	rm -f ${DIST}.tar.gz

.PHONY: all clean dist install uninstall
