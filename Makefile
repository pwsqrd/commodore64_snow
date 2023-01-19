
JAVA=java
KICKASS=$(JAVA) -jar KickAss.jar
SOURCEFILES=main.asm
OBJECTS=main.prg
 
%.prg: %.asm
	$(KICKASS) $^ -o $@

all: main.prg

clean: 
	rm -f *.prg

debug:
	./debug.sh
