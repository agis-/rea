PROGRAMS=rea
CSOURCES=rea.c
srcdir=.
DEPENDENCIES=http-parser

INCLUDES=-I$(srcdir) -I$(srcdir)/http-parser
CFLAGS=-O0 -g3 -Wall #-Werror
LDFLAGS=
LIBS=-lhttp-parser -L$(srcdir)/http-parser

include $(srcdir)/Makefile.mk

.PHONY:

rea:$(OBJECTS)
	$(LINK.cc) -o $@ $(OBJECTS) $(LDFLAGS) $(LIBS)
