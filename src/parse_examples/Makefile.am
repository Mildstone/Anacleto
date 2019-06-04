
SUFFIXES = .yy.c .l

CLEANFILES = ch2-03.yy.c
EXTRA_DIST = ch2-03.l

.l.yy.c:
	@ $(LEX) -o $@ $<

all: ch2-03.yy.c
