.POSIX:

TARGS = audl \
	ausplit \
	autocomp \
	backup \
	batnfy \
	bright \
	buildtrace \
	bookmark \
	doccomp \
	docprev \
	extr \
	gitmail \
	mntdroid \
	passget \
	push \
	rssread \
	screencast \
	se \
	sjail \
	sysact \
	tag \
	tmuxsession \
	upd \
	vdq \
	vds \
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
