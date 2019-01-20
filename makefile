IMAGES = sprite.chr bg.chr
SOURCES = \
	src/movePlayer.asm\
	src/03main.asm\
	src/02setup.asm\
	src/01title.asm\
	src/00index.asm

all: nyappy.nes
	open nyappy.nes

nyappy.nes: $(IMAGES) nyappy.o
	ld65 -o nyappy.nes --config memory-map.cfg --obj nyappy.o

sprite.chr: sprite.bmp
	bmp2chr sprite.bmp sprite.chr

bg.chr: bg.bmp
	bmp2chr bg.bmp bg.chr

nyappy.o: $(SOURCES)
	cl65 -t none -o nyappy.o -c src/00index.asm

clean:
	@rm -rf *.chr
	@rm -rf *.o
	@rm -rf *.nes
