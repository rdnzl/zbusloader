CC=avr-gcc
OBJCOPY=avr-objcopy
STRIP=avr-strip
SIZE=avr-size
AVRDUDE=avrdude

F_CPU=8000000
#MCU=atmega8
MCU=atmega168
#MCU=atmega169

ifeq ($(MCU),atmega8)
BOOTSTART=0x1E00         # 256 word
else ifeq ($(MCU),atmega168)
BOOTSTART=0x3C00         # 512 word
else ifeq ($(MCU),atmega169)
BOOTSTART=0x3C00         # 512 word
endif

CPPFLAGS += -mmcu=$(MCU) -DF_CPU=$(F_CPU)
CFLAGS += -std=gnu99 -Os -g -Wall -W -mmcu=$(MCU)
LDFLAGS += $(CFLAGS) -nostdlib -Wl,--section-start=.text=$(BOOTSTART)


all: zbusloader.hex

zbusloader: zbusloader.o avr_init.o
	$(CC) -o $@ $(LDFLAGS) $^
	$(SIZE) $@

clean:
	rm -f zbusloader *.o *.s *.hex *~

%.hex: %
	$(OBJCOPY) -O ihex -R .eeprom $< $@

load: zbusloader.hex
	$(AVRDUDE) -p m8 -U flash:w:$<

fuse:
	$(AVRDUDE) -p m8 -U lfuse:w:0xa4:m
	$(AVRDUDE) -p m8 -U hfuse:w:0xdc:m

.PHONY:	fuse load clean
