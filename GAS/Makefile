
SRC := mymsg.s
OBJ := $(SRC:.s=.o)
EXE := $(OBJ:.o=)

$(EXE): $(OBJ)
	ld -static -o $@ $(OBJ)
	strip $@

$(OBJ): $(SRC)
	as -arch i386 -o $@ $(SRC)

clean:
	rm -f $(OBJ) $(EXE) 2>&1 > /dev/null

