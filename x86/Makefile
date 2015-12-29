
hw.x: hw.o
	ld -o hw.x hw.o

hw.o: hw.s
	nasm -f macho32 -l hw.l -o hw.o hw.s

clean:
	rm -f hw.x hw.o hw.l

