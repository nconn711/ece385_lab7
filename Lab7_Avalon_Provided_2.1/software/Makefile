HEADERS = aes.h

default: main

main.o: main.c $(HEADERS)
	gcc -c -g main.c -o main.o

main: main.o
	gcc main.o -o main

clean:
	-rm -f main.o
	-rm -f main