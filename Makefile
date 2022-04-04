.POSIX:

SCRIPTS = ausplit \
	  autocomp \
	  backup \
	  batnfy \
	  doccomp \
	  docprev \
	  extr \
	  fontupd \
	  irssi_torconf \
	  mntdroid \
	  namefmt \
	  newsboat_bookmark \
	  passget \
	  push \
	  rssread \
	  screencast \
	  se \
	  setscreens \
	  sysact \
	  tag \
	  umntdroid \
	  unix \
	  upd \
	  vdq \
	  vds \
	  vmstart \
	  vmstop \
	  walset \
	  wttr

PREFIX = /usr/local

all: ${SCRIPTS}
	chmod +x ${SCRIPTS}

dist:
	mkdir -p ${DIST}
	cp -R ${SCRIPTS} ${DIST}
	tar -cf ${DIST}.tar ${DIST}
	gzip ${DIST}.tar
	rm -rf ${DIST}

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f ${SCRIPTS} ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/${SCRIPTS}

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/${SCRIPTS}

clean:
	rm -f ${DIST}.tar.gz

.PHONY: all clean dist install uninstall
