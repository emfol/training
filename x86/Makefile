
hw.x: hw.o utils.o
	ld -o hw.x hw.o utils.o

hw.o: hw.s
	nasm -f macho32 -l hw.l -o hw.o hw.s

utils.o: utils.s
	nasm -f macho32 -l utils.l -o utils.o utils.s

args.x: args.c
	cc -ansi -pedantic -o args.x args.c

clean:
	rm -f *.x *.o *.l 2>&1 > /dev/null

