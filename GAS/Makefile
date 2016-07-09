
OS  := $(shell uname -s)
ARC := $(shell uname -m)

SRC := mymsg.s
OBJ := $(SRC:.s=.o)
EXE := $(OBJ:.o=)

ASARGS :=
LDARGS :=

ifeq ($(OS),Linux)

  ASARGS := -march=i386 $(ASARGS)

  ifeq ($(ARC),x86_64)
    ASARGS := --32 $(ASARGS)
    LDARGS := -m elf_i386 $(LDARGS)
  endif

  ifdef LISTING
    ASARGS := $(ASARGS) -al=$(LISTING)
  endif

endif

ifeq ($(OS),Darwin)
  ASARGS := -arch i386
endif

$(EXE): $(OBJ)
	ld $(LDARGS) -o $@ $(OBJ)
	strip $@

$(OBJ): $(SRC)
	as $(ASARGS) -o $@ $(SRC)

max: max.o
	ld $(LDARGS) -o $@ max.o

max.o: max.s
	as $(ASARGS) -o $@ max.s

power: power.o
	ld --entry _main --dynamic-linker /lib/ld-linux.so.2 power.o -lc -o $@

power.o: power.s
	as $(ASARGS) -o $@ power.s

.PHONY: clean
clean:
	rm -f $(OBJ) $(EXE) max.o max power.o power > /dev/null 2>&1
