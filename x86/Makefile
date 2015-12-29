
hw.x: hw.o
	ld -o hw.x hw.o

hw.o: hw.s
	nasm -f macho32 -l hw.l -o hw.o hw.s

args.x: args.c
	cc -ansi -pedantic -o args.x args.c

clean:
	rm -f hw.x hw.o hw.l args.x 2>&1 > /dev/null

