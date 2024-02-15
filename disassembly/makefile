# Phantasy Star disassembly makefile

WLAZ80 = wla-z80.exe
WLALINK = wlalink.exe
FLIPS = flips.exe
BMP2TILE = bmp2tile.exe
PY = "py"

# The original PSJ ROM
PSJ = ps1-j.sms

# Default target is the ROM
DUMMY: ps1-j-rebuilt.sms

# Generate the dependencies list for assembly
generated.makefile: ps1-j-disassembly.asm
	$(WLAZ80) -M -t -o ps1-j-rebuilt.sms.o $^ > $@

include generated.makefile

ps1-j-rebuilt.sms.o: ps1-j-disassembly.asm
	$(WLAZ80) -D LANGUAGE=$(LANGUAGE) -o $@ $^

ps1-j-rebuilt.sms: ps1-j-rebuilt.sms.o
	$(WLALINK) -d -r -v -S linkfile "ps1jert.sms"

ps1jert.$(LANGUAGE).ips: $(PSJ) ps1jert.sms
	$(FLIPS) --create $(PSJ) ps1jert.sms ps1jert.$(LANGUAGE).ips

ps1jert.$(LANGUAGE).bps: $(PSJ) ps1jert.sms
	$(FLIPS) --create $(PSJ) ps1jert.sms ps1jert.$(LANGUAGE).bps

clean:
	del generated.*
