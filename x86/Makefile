
OS := $(shell uname -s)

SRC_SYS   :=
SRC_CRT   := crt.s
SRC_UTILS := utils.s
SRC_HW    := hw.s
SRC_TEST  := test.c
SRC_ARGS  := args.c

H_UTILS := include/utils.h

OBJ_SYS   := sys.o
OBJ_CRT   := $(SRC_CRT:.s=.o)
OBJ_UTILS := $(SRC_UTILS:.s=.o)
OBJ_HW    := $(SRC_HW:.s=.o)

EXE_HW   := $(OBJ_HW:.o=.x)
EXE_TEST := $(SRC_TEST:.c=.x)
EXE_ARGS := $(SRC_ARGS:.c=.x)

DEPS   := $(OBJ_SYS) $(OBJ_CRT) $(OBJ_UTILS)
CC     := cc
ASM    := nasm
CFLAGS := -m32 -ansi -pedantic -g
AFLAGS := -g

ifeq ($(OS),Linux)
  SRC_SYS := sys/linux.s
else
  SRC_SYS := sys/unix.s
endif

ifeq ($(OS),Darwin)
  AFLAGS := -f macho32 $(AFLAGS)
else
  AFLAGS := -f elf32 $(AFLAGS)
endif

$(EXE_HW): $(OBJ_HW) $(DEPS)
	ld -o $@ $+

$(OBJ_HW): $(SRC_HW)
	$(ASM) $(AFLAGS) -l $(@:.o=.l) -o $@ $(SRC_HW)

$(OBJ_SYS): $(SRC_SYS)
	$(ASM) $(AFLAGS) -l $(@:.o=.l) -o $@ $(SRC_SYS)

$(OBJ_CRT): $(SRC_CRT)
	$(ASM) $(AFLAGS) -l $(@:.o=.l) -o $@ $(SRC_CRT)

$(OBJ_UTILS): $(SRC_UTILS)
	$(ASM) $(AFLAGS) -l $(@:.o=.l) -o $@ $(SRC_UTILS)

$(EXE_ARGS): $(SRC_ARGS)
	$(CC) $(CFLAGS) -o $@ $(SRC_ARGS)

$(EXE_TEST): $(SRC_TEST) $(H_UTILS) $(OBJ_UTILS)
	$(CC) $(CFLAGS) -o $@ $(OBJ_UTILS) $(SRC_TEST)

clean:
	rm -f *.x *.o *.l 2>&1 > /dev/null

