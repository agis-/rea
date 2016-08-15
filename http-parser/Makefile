LIBRARIES=libhttp-parser.a
CSOURCES=http_parser.c
srcdir=..

INCLUDES=-I. -I$(srcdir)
CFLAGS=-O0 -g3 -Wall -Werror
LDFLAGS=
LIBS=

include $(srcdir)/Makefile.mk

.PHONY:

libhttp-parser.a:$(OBJECTS)
	$(AR) rcs $@ $(OBJECTS)
