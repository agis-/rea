# Flags

ifndef CPPFLAGS
	CPPFLAGS=
endif
ifndef CFLAGS
	CFLAGS=-O0 -g3 -Wall
endif
ifndef CXXFLAGS
	CXXFLAGS=$(CFLAGS)
endif
ifndef LDFLAGS
	LDFLAGS=
endif

# Tools
RM=rm -Rf
CC=$(TOOL_PREFIX)gcc
CXX=$(TOOL_PREFIX)g++
LINK.c=$(CC)
LINK.cpp=$(CXX)
LEX=flex
AR=$(TOOL_PREFIX)ar
YACC=$(TOOL_PREFIX)bison
LEX=$(TOOL_PREFIX)flex

# Target variables
OBJECTS=$(CXXSOURCES:.cpp=.o) $(CSOURCES:.c=.o) $(MOCSOURCES:.cpp=.o) $(RCCSOURCES:.cpp=.o)
SOURCES=$(CSOURCES) $(CXXSOURCES)
TARGETS=$(PROGRAMS) $(LIBRARIES)

# Phony targets
.PHONY: all clean dist-clean release

# Build rules
%.o:%.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

%.o:%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) -c -o $@ $<

moc_%.cpp:%.h
	$(MOC) -o $@ $<

rcc_%.cpp:%.qrc
	$(RCC) -o $@ $<

%.yy.cpp:%.l
	$(LEX) -o $@ $<

%.tab.h %.tab.cpp:%.ypp
	$(YACC) -d -o $(addprefix $(basename $@),.cpp) $<
	mv $(addprefix $(basename $@),.hpp) $(addprefix $(basename $@),.h)

# Targets
all:
	@set -e; \
	if [ ! -z "$(DEPENDENCIES)" ]; \
	then \
		dir=`pwd`; \
		dir=`basename $$dir`; \
		echo "Building dependencies for: \`$$dir'..."; \
		$(MAKE) dependencies; \
	fi;
	@set -e; \
	if [ ! -z "$(SUBDIRS)" ]; \
	then \
		dir=`pwd`; \
		dir=`basename $$dir`; \
		echo "Building sub-targets for: \`$$dir'..."; \
		$(MAKE) subdirs; \
	fi;
	@set -e; \
	if [ ! -z "$(TARGETS)" ]; \
	then \
		echo "Building $(TARGETS)..."; \
		$(MAKE) targets; \
	fi;

dependencies:
	@set -e; \
	for dir in $(DEPENDENCIES); \
	do \
		echo "Building \`$$dir'..."; \
		cd $(srcdir)/$$dir && $(MAKE) all && cd ../; \
	done;

subdirs:
	for dir in $(SUBDIRS); \
	do \
		cd $$dir && $(MAKE); \
	done

targets:$(TARGETS)

clean:
	rm -f $(OBJECTS) $(TARGETS)
	rm -Rf deps $(EXTRA_TARGETS)
	@set -e; \
	for dir in $(DEPENDENCIES); \
	do \
		echo "Cleaning \`$$dir'..."; \
		cd $(srcdir)/$$dir && $(MAKE) clean && cd ../; \
	done; \
	for dir in $(SUBDIRS); \
	do \
		cd $$dir && $(MAKE) clean; \
	done

dist-clean:
	$(MAKE) clean
	@for dir in $(SUBDIRS); \
	do \
		cd $$dir && $(MAKE) dist-clean; \
	done

release:
	$(MAKE) CFLAGS='-O2 -g0 -Wall'
	@for dir in $(SUBDIRS); \
	do \
		cd $$dir && $(MAKE) release \
	done

# Dependency calculation rules
deps/%.d: %.cpp
	@install -d $(dir $@)/deps 2>/dev/null; \
		set -e; $(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) $< > $@.$$$$; \
		sed 's,\($*\)\.o[ :]*,\1.o $@ : Makefile ,g' < $@.$$$$ > $@; \
		rm -f $@.$$$$

deps/%.d: %.c
	@install -d $(dir $@)/deps 2>/dev/null; \
		set -e; $(CC) -MM $(CPPFLAGS) $(CFLAGS) $(INCLUDES) $< > $@.$$$$; \
		sed 's,\($*\)\.o[ :]*,\1.o $@ : Makefile ,g' < $@.$$$$ > $@; \
		rm -f $@.$$$$

# Force dependency calculation
-include $(addprefix deps/,$(CXXSOURCES:.cpp=.d))
-include $(addprefix deps/,$(CSOURCES:.c=.d))
