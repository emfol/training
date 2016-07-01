
OS  := $(shell uname -s)
ARC := $(shell uname -m)

SRC := mymsg.s
OBJ := $(SRC:.s=.o)
EXE := $(OBJ:.o=)

ASARGS :=
LDARGS := -static

ifeq ($(OS),Linux)

  ASARGS := -march=i586 $(ASARGS)

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

clean:
	rm -f $(OBJ) $(EXE) max.o max > /dev/null 2>&1

max: max.o
	ld $(LDARGS) -o $@ max.o

max.o: max.s
	as $(ASARGS) -o $@ max.s
