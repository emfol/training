
hw.x: hw.o utils.o
	ld -o hw.x hw.o utils.o

hw.o: hw.s
	nasm -f macho32 -g -l hw.l -o hw.o hw.s

utils.o: utils.s
	nasm -f macho32 -g -l utils.l -o utils.o utils.s

args.x: args.c
	cc -m32 -ansi -pedantic -g -o args.x args.c

test.x: test.c utils.o
	cc -m32 -ansi -pedantic -g -o test.x test.c utils.o

clean:
	rm -f *.x *.o *.l 2>&1 > /dev/null

