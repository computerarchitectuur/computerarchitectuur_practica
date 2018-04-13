; 
; practicum 4 computerarchitectuur
;
; dit programma bestaat uit een beperkt aantal sectoren die ingelezen
; worden na het uitvoeren van de BIOS. Dit zijn de eerste sectoren die
; bij het bootstrappen van de floppy of van de harde schijf gelezen 
; worden
;
; de bios begint uit te voeren op adres 000ffff0h (startadres van de 
; processor, en zal na verloop van tijd de eerste sector (512 bytes)
; van het bootstrap device (floppy, harddisk, CD) inlezen.
; 
; deze sector wordt opgeslagen op adres 7c00h.
;

; constantendefinities

Loaded		EQU	7C00h    ; adres waarop sector 0 geladen wordt
SectorSize	EQU	512      ; grootte van 1 sector
;VIDEO_MODE  	EQU   	7        ; monochrome mode
;VGA_MEM     	EQU   	0xB0000  ; plaats van de videoram voor monochrome mode
VIDEO_MODE  	EQU   	3        ; kleurmode
VGA_MEM     	EQU   	0xB8000  ; plaats van de videoram voor kleurmode
Wachtlus	EQU	100000


; de BIOS voert steeds uit in 16 bit mode. Een van de taken van het programma
; in sector 0 is het omschakelen naar 32 bit mode.
; 
; de BITS directieve vraagt aan de assembler om 16-bit code te genereren.
; 
BITS 16			; 16 bit real mode

; de ORG-directieve vraagt aan de assembler ervan uit te gaan dat de volgende 
; instructie uiteindelijk op adres 7C00h in het geheugen terecht zal komen

ORG 	7C00h		; adres waarop deze code geladen wordt

; behalve het codesegment (deze instructies worden immers uitgevoerd), kunnen
; we er niet van uitgaan dat de andere segmentregisters geldige waarden hebben.
; we zorgen ervoor dat ds, es, en ss allemaal naar hetzelfde blok geheugen 
; wijzen.
; Uit experimenten blijkt dat alle segmenten beginnen op adres 0. Let wel: dit 
; zijn segmentregisters uit het IA16 model en hun interpretatie is verschillend van 
; deze in het IA32 model.

	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, Loaded	; sp wijst net voor de eerste instructie, 
				; en groeit ervan weg 

; Laad de rest van de sectoren na de eerste sector in het geheugen. 
; Hiervoor wordt de BIOS oproep int 13h gebruikt. Daarvoor moeten wel alle 
; parameters eerst goedgezet worden.
; aangezien niet elke BIOS multitrack reads ondersteunt dienen we de
; sectoren een voor een in te lezen (zou ook per track kunnen)

	mov	si, 2			; SI = huidige logische sector
	mov	ax, SecondStage
	shr	ax, 4
	mov	es, ax
	
load_next:
	; CL = sector = ((SI -1) % 18) + 1
	; CH = track = (SI - 1) / 36
	; DH = head = ((SI - 1) / 18) & 1
	mov	ax, si
	dec	ax
	xor	dx, dx
	mov	bx, 18
	div	bx
	mov	cl, dl
	inc	cl
	mov	ch, al
	shr	ch, 1
	mov	dh, al
	and	dh, 1
.retry:
	mov	ah, 2	; read sector
	mov	al, 1	; 1 sector
	mov	bx, 0	; buffer es:bx
	mov	dl, 0	; diskette station A:
	int	0x13
	jc	.retry
	mov	ax, es
	add	ax, 0x20	; 512 bytes / 16
	mov	es, ax
	inc	si		; volgende sector
	cmp	si, SectorsToLoad + 2
	jnz	load_next

; Met de BIOS-interrupt 10h zetten we de videomode goed.
; 25 lijnen van 80 witte tekens met zwarte achtergrond = VGA mode 03h 

        mov	ax, VIDEO_MODE
        int	10h

; Zet motor af
	xor	al, al		; al = 0
	mov	dx, 0x3f2	; FDD Digital Output Register
	out	dx, al

; stop interrupts zodat we de onderbrekingsregelaar kunnen programmeren
	cli

; PIC initialization (8259A) 
; PIC1: 0020-003F
; PIC2: 00A0-00BF 			
; Maps IRQ 0 - IRQ 0xF to INT 8 - 23
	mov	al,11h 	; (init. command word 1) ICW1 to both controllers
	out	20h,al		; bit 0=1: ICW4 needed
	out	0A0h,al		; bit 1=0: cascaded mode
				; bit 2=0: call address interval 8 bytes 
				; bit 3=0: edge triggered mode
				; bit 4=1: ICW1 is being issued
				; bit 5-7: not used
	mov	al, IRQBase	; ICW2 PIC1 - offset of vectors
	out	21h,al		; 20h -> right after the intel exceptions
				; bit 0-2: 000 on 80x86 systems
				; bit 3-7: A3-A7 of 80x86 interrupt vector

	mov	al, IRQBase+8 	; ICW2 PIC2 - offset of vectors
	out	0A1h,al		; 28h -> after PIC1 vectors
		
	mov	al,4h		; ICW3 PIC1 (master)
	out	21h,al		; bit 2=1: irq2 has the slave
		
	mov	al,2h		; ICW3 PIC2 (slave)
	out	0A1h,al		; bit 1=1: slave id is 2
		
	mov	al,1h		; ICW4 to both controllers
	out	21h,al		; bit 0=1: 8086 mode
				; bit 1=0: no auto EOI, so normal EOI
	out	0A1h,al		; bit 2-3=00: nonbuffered mode
				; bit 4:0=sequential, bit 5-7: reserved
		
	mov	al,0ffh		; OCW1 interrupt mask to both
	out	21h,al		; no interrupts enabled
	out	0A1h,al  

; Zet de Global Descriptor Tabel (GDT) goed zodat we cs, ds, es, ss kunnen
; vullen met een segment selector die wijst naar het gehele adresbereik.

	lgdt	[GDTInfo]	; laadt GDTR register

; Laat het IDT register wijzen naar de Interrupt Descriptor Tabel (IDT) 
; (die moeten we nog invullen)

	lidt	[IDTInfo]	; laadt IDTR register
	
; Het laagste bit in het controleregister cr0 bepaalt of we in 16 bit mode
; of in 32 bit mode werken. 

	mov	eax, cr0
	or	eax, 1		; 1 = protected mode (32 bit)
	mov	cr0, eax	

; Spring naar het begin van de 32-bit code Main32. Door gebruik te maken 
; van een intersegmentaire sprong worden zowel cs als eip meteen goed gezet.
; CodeSegmentSelector = selector naar de descriptor van het codesegment
; Main32 = 32-bit entry point

	jmp 	CodeSegmentSelector:dword main

; de assembler zal vanaf hier 32 bit code genereren
BITS 32

; Dit is het einde van de eerste sector. Deze wordt nu opgevuld met nullen
; totdat hij precies 512 bytes groot is. ($-$$)=grootte van de code

; Laat NASM controleren of onze boot sector wel in 512 bytes past.
%if ($-$$) > SectorSize - 2
%error De bootsector is groter dan 512 bytes.
%endif

TIMES 	SectorSize-2-($-$$) DB 0 ; Zorg dat de boot sector 512 bytes lang is 
	DW 	0xAA55  ; Verplichte signatuur van de bootsector 
			; hieraan herkent de BIOS een bootsector

;============================ SECOND STAGE SECTION ============================ 
SecondStage:	; de eerste bootsector zal op dit adres de volgende
		; sectoren inladen met onderstaande code en data
		; deze sectoren beginnen in principe op Loaded+SectorSize


;-----------------------------------------------------------------------------;
;                          GLOBAL DESCRIPTORS TABLE                           ;
;-----------------------------------------------------------------------------;
; Er worden hier drie segmenten gedefinieerd: codesegment, datasegment, en 
; stapelsegment
; Al deze segmenten wijzen echter naar hetzelfde blok geheugen van 4 GiB 
; (volledige 32-bit adresruimte).


GDTStart:	
NULLDesc	:
	dd 	0, 0		; null descriptor  (wordt niet gebruikt)
CodeDesc:
	dw 	0FFFFh		; code limit 0 - 15
	dw 	0		; code base 0 - 15
	db 	0		; code base 16 - 23
	db 	10011010b	; present, dpl=00, 1, code=1, cnf.=0, r=1, ac=0
	db 	11001111b	; gran=1, use32=1, 0, 0, limit 16 - 19
	db 	0		; code base 24 - 31
DataDesc:	
	dw 	0FFFFh		; data limit 0 - 15
	dw 	0		; data base 0 - 15
	db 	0		; data base 16 - 23
	db 	10010010b	; present, dpl=00, 10, exp.d.=0, wrt=1, ac=0
	db 	11001111b	; gran=1, big=1, 0, 0, limit 16 - 19
	db 	0		; data base 24 - 31			
StackDesc:	
	dw 	0		; data limit 0 - 15
	dw 	0		; data base 0 - 15
	db 	0		; data base 16 - 23
	db 	10010110b	; present, dpl=00, 10, exp.d.=1, wrt=1, ac=0
	db 	11000000b	; gran=1, big=1, 0, 0, limit 16 - 19
	db 	0		; data base 24 - 31			
GDTEnd:	

GDTInfo:					   ; inhoud van GDTR
GDTLimit	dw 	GDTEnd-GDTStart-1  ; GDT limit = offset hoogste byte	
GDTBase		dd 	GDTStart	   ; GDT base	

; constantendefinities om gemakkelijk naar de verschillende segmenten
; te kunnen refereren.

CodeSegmentSelector 	EQU CodeDesc - GDTStart
DataSegmentSelector 	EQU DataDesc - GDTStart
StackSegmentSelector 	EQU StackDesc - GDTStart

;-----------------------------------------------------------------------------;
;                          INTERRUPT DESCRIPTORS TABLE                        ;
;-----------------------------------------------------------------------------;
; De eerste 32 onderbrekingen worden door Intel gedefinieerd. De onderbrekingen
; afkomstig van de onderbrekingsregelaar starten bij onderbreking 32

IDTStart:
	dd 	0, 0	; INT 0 : Divide error
	dd 	0, 0	; INT 1 : Single Step
	dd 	0, 0	; INT 2 : Nonmaskable interrupt
	dd 	0, 0	; INT 3 : Breakpoint
	dd 	0, 0	; INT 4 : Overflow
	dd 	0, 0	; INT 5 : BOUND range exceeded
	dd 	0, 0	; INT 6 : invalid opcode
	dd 	0, 0	; INT 7 : device not available (no math co-cpu)
	dd 	0, 0	; INT 8 : double fault  
	dd 	0, 0	; INT 9 : co-cpu segment overrun
	dd 	0, 0	; INT 10 : invalid TSS
	dd 	0, 0	; INT 11 : segment not present
	dd 	0, 0	; INT 12 : stack-segment fault
	dd 	0, 0	; INT 13 : general protection
	dd 	0, 0	; INT 14 : page fault
	dd 	0, 0	; INT 15 : reserved 
	dd	0, 0	; INT 16 : x87 FPU error 
	dd	0, 0	; INT 17 : alignment check 
	dd	0, 0	; INT 18 : machine check 
	dd	0, 0	; INT 19 : SIMD floating-point exception 
	dd	0, 0	; INT 20 : reserved
	dd	0, 0	; INT 21 : reserved
	dd	0, 0	; INT 22 : reserved
	dd	0, 0	; INT 23 : reserved
	dd	0, 0	; INT 24 : reserved
	dd	0, 0	; INT 25 : reserved
	dd	0, 0	; INT 26 : reserved
	dd	0, 0	; INT 27 : reserved
	dd	0, 0	; INT 28 : reserved
	dd	0, 0	; INT 29 : reserved
	dd	0, 0	; INT 30 : reserved
	dd	0, 0	; INT 31 : reserved
	dd	0, 0	; INT 32 : IRQ0 timer
	dd	0, 0	; INT 33 : IRQ1 keyboard, mouse, rtc
	dd	0, 0	; INT 34 : IRQ2 2de PIC
	dd	0, 0	; INT 35 : IRQ3 com1
	dd	0, 0	; INT 36 : IRQ4 serial port 2 (=com2)
	dd	0, 0	; INT 37 : IRQ5 hard disk
	dd	0, 0	; INT 38 : IRQ6 diskette controller
	dd	0, 0	; INT 39 : IRQ7 parallel printer
	dd	0, 0	; INT 40 : IRQ8 real-time clock
	dd	0, 0	; INT 41 : IRQ9 redirect cascade
	dd	0, 0	; INT 42 : IRQ10 reserved
	dd	0, 0	; INT 43 : IRQ11 reserved
	dd	0, 0	; INT 44 : IRQ12 mouse
	dd	0, 0	; INT 45 : IRQ13 coprocessor exeception interrupt
	dd	0, 0	; INT 46 : IRQ14 fixed disk
	dd	0, 0	; INT 47 : IRQ15 reserved
IDTEnd:

IRQBase		EQU	32

IDTInfo:		; Inhoud van IDTR
IDTLimit 	dw	IDTEnd-IDTStart-1 ; limit = offset hoogste byte	
IDTBase 	dd      IDTStart

;------------------------------------------------------------------------------
; Data voor de takenlijst
;------------------------------------------------------------------------------

MAX_TAKEN equ 5

STAPELGROOTTE equ 500

; Takenlijst is een lijst van MAX_TAKEN groot. Deze lijst bevat de top van 
; de stapel van de taak wanneer de taak niet aan het uitvoeren is. Indien 
; het element 0 is, wijst dit op de afwezigheid van een taak. Bovendien
; bevat deze lijst informatie over wanneer in de tijd een taak mag uitgevoerd worden

takenlijst times 2*MAX_TAKEN dd (0)
idle_taak_slot  times 2 dd (0)


; Hier worden enkele stapels gedefinieerd van elk STAPELGROOTTE grootte (bytes!).
begin_stapels times 1 dd (0)

stapel1    times STAPELGROOTTE db (0)
stapel2    times STAPELGROOTTE db (0)
mainstapel times STAPELGROOTTE db (0)
infostapel times STAPELGROOTTE db (0)
idlestapel times STAPELGROOTTE db (0)

einde_stapels times 1 dd (0)

; variabele die bijhoudt welke taak op elk ogenblik aan het uitvoeren is.
; De veranderlijk bevat het adres van het corresponderende element in takenlijst.

Huidige_Taak dd 0

; variabele die kijkt hoeveel timer interrupts we al gehad hebben
Huidige_Tick dd 0


;================================= MAIN ==============================

main:	

;
; door de oproep met expliciet codesegment staat het codesegment-register 
; hier meteen goed. De andere segmentregisters krijgen hier een waarde.
; alle segmentregisters (ook fs en gs) dienen met een geldige waarde te worden
; gevuld.
;
	mov	ax, DataSegmentSelector
	mov	ds, ax		
	mov	es, ax		
	mov	fs, ax	
	mov	gs, ax	

	mov	ax, StackSegmentSelector
	mov	ss, ax
	mov	esp, Loaded     ; stapel wijst nog steeds naar dezelfde locatie

;------------------------------------------------------------------------------
; Timer aanpassen (voor practicum 4)
;------------------------------------------------------------------------------

        ; Verhoog het aantal HZ van de PIT zijn standaardwaarde van 18.2Hz naar 100Hz:
        ; Port 40h -> system time counter divisor
        ; Port 43h -> control word register

        ; (00) counter 0 select (11) read/write counter bits 0-7 first, then 8-15 (x11) counter mode: square (0) binary counter
        mov     al, 00110110b
        out     43h, al

        ; bits 0-7
        mov     al, 00h
        out     40h, al
        ; bits 8-15
        mov     al, 00fh ; ~ 1000Hz? ### Check
        out     40h, al
        ; zet de onderbrekingen terug aan
	sti

;------------------------------------------------------------------------------
; Debug Excepties (voor practicum 4)
;------------------------------------------------------------------------------


	; Zorg er voor dat we debugexcepties genereren als een programma zijn stack lijkt te over/underflowen
	; (dit is geen garantie indien men sub/adds doet op esp, maar het is alvast ietsje betrouwbaarder)
	lea  eax, [begin_stapels]
	mov  dr0, eax
	lea  eax, [einde_stapels]
	mov  dr1, eax

	mov  eax, dr7
	; dr0
	or   eax, 11b  ; L0|G0
	or   eax, 00000000000000110000000000000000b ; R/W0
	or   eax, 00000000000011000000000000000000b ; LEN0 == 4

	; dr1
	or   eax, 1100b ; L1|G1
	or   eax, 00000000001100000000000000000000b ; R/W1
	or   eax, 00000000110000000000000000000000b ; LEN1 == 4

	mov  dr7, eax
	
	
        mov  ebx, debughandler
        push ebx
        push 1
        call install_handler
        add esp, 8


        ; We gaan over naar een voorgedefinieerde stapel en stoppen het hoofdprogramma in de lijst
        lea     esp, [mainstapel + STAPELGROOTTE]
        mov     dword [takenlijst], esp
        mov     dword [Huidige_Taak], takenlijst

	; installeer de schedulerhandler op de timeronderbreking en zet deze onderbreking aan
	push	schedulerhandler
	push	32
	call	install_handler
	add	esp, 0x8
	;; zet onderbreking aan
        cli
	in	al, 0x21
	and	al, 11111110b
	out	0x21, al
        sti


; .............

; Start de taken
; .............
	;; installeer taak1
	push	0
	push	stapel1
	push	Taak1
	call	creeertaak
	add	esp, 12	

	;; installeer taak2
	push	2500
	push	stapel2
	push	Taak2
	call	creeertaak
	add	esp, 12	

	;; De hoofd-taak gaat gewoon PrintInfoTaak direct uitvoeren
	jmp PrintInfoTaak


; Verwijder deze lus (Opgave 6)
; .............
HoofdProgrammaGedaan:
        jmp     HoofdProgrammaGedaan


;================================= TAKEN ==============================
Taak1:
        mov     eax, 0
        mov     ebx, 39
        mov     ecx, 1
        mov     edx, 9
        jmp     spiraal



Taak2:
	mov	eax,40	
	mov	ebx,79
	mov	ecx,1
	mov	edx,9
	jmp	spiraal


Taak3:
        mov     eax, 0
        mov     ebx, 79
        mov     ecx, 11
        mov     edx, 20
        jmp     spiraal


clockstring  db "Clockticks:", 0
tscstring    db "TSC: ", 0
takenstring  db "Taken: ", 0

PrintInfoTaak:
  ; Print informatie op het scherm
  push  21
  push  0
  push  clockstring
  call  printstring
  add   esp, 12

  push  21
  push  22
  push  tscstring
  call  printstring
  add   esp, 12

  push  22
  push  0
  push  takenstring
  call  printstring
  add   esp, 12

  ; Print de labels voor de taken:
  mov   edi, 0
.printLabels:
  mov   eax, 13
  imul  edi
  add   eax, 7

  ; Taaknummer

  push  eax
  push  edi

  push  22
  push  eax
  push  edi

  add   eax, 1
  push  word 22
  push  ax
  push  word ':'

  add   eax, 2
  push  word 22
  push  ax
  push  word ','

  call  printchar
  call  printchar
  call  printint
  add   esp, 12

  pop   edi
  pop   eax

  add   edi, 1

  cmp   edi, MAX_TAKEN
  jl    .printLabels
  jmp   PrintInfoTaakLoop

PrintInfoTaakLoop:
  ; Print Tijd-Info
  push  21
  push  13
  push  dword [Huidige_Tick]
  call  printhex
  add   esp, 12

  push  21
  push  28
  rdtsc
  push  edx
  push  21
  push  36
  push  eax
  call  printhex
  add   esp, 12
  call  printhex
  add   esp, 12

  ; Print taken-info:
  lea   esi, [takenlijst]
  mov   ecx, 0
.printTaken:
  imul  edx, ecx, 8
  mov   dword ebx, [esi+edx]
  ; Startpos op scherm
  mov   eax, 13
  imul  ecx

  push  esi
  push  ecx
  push  ebx

  add   eax, 11

  ; Toon activatietijd (ook invullen indien taak getermineerd)
  push  22
  push  eax
  imul  edx, ecx, 8
  push  dword [esi+edx+4]

  add   eax, -2
  ; Toon status: A = Actief, T = geTermineerd
  cmp   ebx, 0
  je    .printgeTermineerd

  push   word 22
  push   ax
  push   word 'A'

  jmp    .nextTaak

.printgeTermineerd:
  push   word 22
  push   ax
  push   word 'T'

  jmp   .nextTaak

.nextTaak:
  call   printchar
  call   printhex
  add   esp, 12

  pop    ebx
  pop    ecx
  pop    esi

  add   ecx, 1
  cmp   ecx, MAX_TAKEN
  jl    .printTaken

  ; Vraag 1
  ; .......

  jmp   PrintInfoTaakLoop


IdleTaak:
        ; Schrijf naar het scherm dat de idle taak gebruikt wordt (niet van toepassing in dit practicum)
        jmp     IdleTaak


;================================= SCHEDULING ==============================

creeertaak:
; voeg een taak toe aan de takenlijst
; oproepen als creeertaak(adres, stapel, wachttijd)
; ....................
		mov	eax, [esp+4]	; adres
	mov	ecx, [esp+8]	; stapel
	mov	edx, [esp+12]	; wachttijd
	;; initalisatie van de stapel
	; sla huidige stapelpointer op in ebp
	push	ebp
	mov	ebp, esp
	; verplaats esp naar BEGIN nieuwe stapel
	lea	ecx, [ecx+STAPELGROOTTE]
	mov	esp, ecx
	; plaats eflags op de stapel, maar zorg dat IF=1!
	pushfd
	mov	ecx, [esp]
	or	ecx, 0x200
	mov	[esp], ecx
	; plaats cs op de stapel
	push	cs
	; plaats eip op de stapel
	push	eax
	; esp in eax steken, om correcte waarde van esp te kunnen pushen
	mov	eax, esp
	; imiteer een pushad
	push	dword 0		; eax
	push	dword 0		; ecx
	push	dword 0		; edx
	push	dword 0		; ebx
	push	eax		; esp
	push	dword 0		; ebp
	push	dword 0		; esi
	push	dword 0		; edi
	;; initialisatie van de takenlijst:
        cli
        lea	ecx, [takenlijst - 8]
.leegzoeklus:
        add	ecx, 8
        cmp	dword [ecx], 0
        jne	.leegzoeklus
	; plaats de correct esp in de takenlijst
	mov	dword[ecx], esp
 	; plaats de correcte tijd in de takenlijst
	mov	eax, [Huidige_Tick]
	add	eax, edx	
	mov	dword[ecx+4], eax
	sti
	; keer terug naar de oorspronkelijke stapel
	mov	esp, ebp
	pop	ebp
	ret


creeer_idle_taak: ; Vraag 3
; ....................
	ret


termineertaak: ; Vraag 4, Vraag 5
; Krijgt de offset in bytes in de takenlijst
; van de taak die getermineerd moet worden.
; termineertaak gooit de taak die deze routine oproept uit de takenlijst
; en zet de uitvoering verder met een andere taak uit de takenlijst
; termineertaak(taakslotnummer)

; ....................


; sleep(nr_ticks): Slaapt voor (minstens) nr_ticks ticks
sleep:
        push eax
        mov eax, [esp+8]
        pushad ; Do not clobber any registers
        pushfd
        push    cs
        push    ebx
        pushad
        lea     ebx, [awake]
        mov     [esp+4*8], ebx
        mov     ebx, [Huidige_Taak]
        cli
        mov     dword [ebx],esp
        mov     dword ecx, [Huidige_Tick]
        add     eax, ecx
        mov     dword [ebx + 4], eax
        mov     edx, 0
        jmp     schedulerhandler.taakzoeklus
awake:
        popad
        pop eax
        ret

; Zorg ervoor dat GEEN TAAK geprint wordt als er geen taak gevonden wordt (Vraag 2)
; en zorg er voor dat de idle taak gescheduled kan worden indien er anders geen taken
; beschikbaar zijn (Vraag 3)
; ..............
schedulerhandler:
        pushad
        inc     dword [Huidige_Tick]
        mov	al, 0x20
        out	0x20, al
        sti
        mov	ebx, [Huidige_Taak]
        mov	dword [ebx],esp
        mov     dword [ebx + 4], 0
        mov    ecx, [Huidige_Tick]
	call	animatiestap
        cli
.taakzoeklus:
        add	ebx, 8
        cmp	ebx, takenlijst + (MAX_TAKEN * 8)
        jl	.nog_niet_aan_het_einde
        lea	ebx, [takenlijst]
.nog_niet_aan_het_einde:
        cmp	dword [ebx],0
        je	.taakzoeklus
        cmp     dword [ebx+4], ecx
        jg      .taakzoeklus
        mov     [Huidige_Taak], ebx
        mov     esp, [ebx]
        popad
        iret


; Animatie om te zien of schedulerhandler opgeroepen wordt, ook al is er maar 1 taak:
ANIM_X EQU 0
ANIM_Y EQU 20
ANIMATIE_FRAME db "/", 0
CHECK_FAIL db "Check FAIL: ", 0

animatiestap:
pushad
cmp	byte [ANIMATIE_FRAME], '/'
je	animatie_1
cmp	byte [ANIMATIE_FRAME], '-'
je	animatie_2
cmp	byte [ANIMATIE_FRAME], '\'
je	animatie_3
cmp	byte [ANIMATIE_FRAME], '|'
je	animatie_4

; Dit mag niet gebeuren!!!
push ANIM_Y
push ANIM_X
push CHECK_FAIL
call printstring
; Gedaan! Loop oneindig!
checkfailed_loop:
jmp checkfailed_loop


animatie_1:
	mov byte [ANIMATIE_FRAME], '-'
	jmp animatie_end
animatie_2:
	mov byte [ANIMATIE_FRAME], '\'
	jmp animatie_end
animatie_3:
	mov byte [ANIMATIE_FRAME], '|'
	jmp animatie_end
animatie_4:
	mov byte [ANIMATIE_FRAME], '/'
	jmp animatie_end

animatie_end:

push word ANIM_Y
push word ANIM_X
push word [ANIMATIE_FRAME]
call printchar
popad

ret

;================================= HULPFUNCTIES ==============================

; install_handler(interruptvector, onderbrekingsroutine)
; installeer de onderbrekingsroutine
; argumenten:
;    interruptvector: nummer van de interrupt
;    onderbrekingsroutine: adres van de corresponderende ISR
install_handler:
	mov	eax, [esp+4]
	mov	edx, [esp+8]
	mov 	word [IDTStart+8*eax+0], dx ; onderste 16 bits van offset
	mov 	word [IDTStart+8*eax+2], CodeSegmentSelector 
	mov 	byte [IDTStart+8*eax+4], 0h ;
	mov 	byte [IDTStart+8*eax+5], 10001110b ; 1=present, dpl=00, 0, 1=32bits, 110 
	shr 	edx, 16
	mov 	word [IDTStart+8*eax+6], dx ; bovenste 16 bits van offset
 	ret


; printstring(adres, kol, rij)
; print een volledige string op het scherm totdat 0 bereikt wordt.
; argumenten:
;   adres van de nulgetermineerde string
;   kolom op het scherm (0..79)
;   rij op het scherm (0..24)
; 
printstring:
	push	ebx
	mov	eax,[esp+16]  ; rij
	mov	ebx,[esp+12]   ; kol
	mov	ecx,[esp+8]   ; pointer naar string
printloop:
	mov	dl,[ecx]
	cmp	dl,0
	je	stop
	push	ax
	push	bx
	push	dx
	call	printchar
	inc	ecx
	inc	ebx
	jmp	printloop
stop:
	pop	ebx
	ret

; --------------------
; Publieke hulpfuncties
; --------------------


; printint(het getal, kolom, rij)
; print een natuurlijk getal op het scherm
; argumenten:
;   rij op het scherm (0..24)
;   kolom op het scherm (0..79)
; opmerking: het getal wordt omgezet in een stringvoorstelling die 
; gevisualiseerd wordt zonder leidende nullen.
;
printint:
	push	ebp
	mov	ebp,esp
	push	ebx
	sub	esp,28
	mov 	ecx,8
	mov 	byte [ebp-19],0
	mov     eax, [ebp+8]    ; integer argument
	mov	ebx,10
bindec: xor     edx,edx
	idiv	ebx
	add	dl,'0'
	mov     [ebp-28+ecx],dl
	dec	ecx
	cmp	eax,0
	jnz	bindec
	lea	ecx,[ebp-27+ecx]
	push	dword [ebp+16]  ; rij
	push	dword [ebp+12]  ; kolom
	push	ecx
	call	printstring
	add	esp,40
	pop	ebx
	pop	ebp
	ret

; printhex(het 32 bit patroon, kolom, rij)
; rint een 32 bit bitpatroon op het scherm in hex notatie
; argumenten:
;    rij op het scherm (0..24)
;    kolom op het scherm (0..79)
; opmerking:het getal wordt omgezet in hexadecimale voorstelling 
; (8 tekens) die gevisualiseerd wordt 
;

printhex:
	push	ebx
	push	ebp
	mov	ebp,esp
	
	sub	esp,12
	mov 	ecx,7
	mov     eax, [ebp+12]    ; argument
	mov	ebx,16
	mov	byte [ebp-4],0
binhex: xor     edx,edx
	idiv	ebx
	cmp	dl, 9
	jg	alfa
	add	dl,'0'
	jmp	hex
alfa:	add	dl,'A'-10
hex:	mov     [ebp-12+ecx],dl
	dec	ecx
	cmp	ecx,0
	jge	binhex
	push	dword [ebp+20]  ; rij
	push	dword [ebp+16]  ; kolom
	push	ebp
	sub	dword [esp],12
	call	printstring
	add	esp,24
	pop	ebx
	leave
	pop ebx
	ret

; 
; kleine vertraging om het hoofdprogramma volgbaar te houden.
; De vertraging kan ingesteld worden via de constante 'Wachtlus'
;

ShortDelay:
        ; ..... (Opgave 1)
	ret

; --------------------
; Private hulpfuncties
; --------------------

;
; print 1 letterteken op het scherm
; op de stapel staan, in deze volgorde (telkens 16 bit)
;   rij op het scherm (0..24)
;   kolom op het scherm (0..79)
;   teken zelf (laagste byte van dit 16-bit woord)
; de rij en kolom wordt vertaald in een adres in het 
; videobuffer dat begint op VGA_MEM. Op die plaats wordt het
; teken geschreven. Het videobuffer is in principe een matrix
; van woorden (rij per rij opgeslagen). Elk woord bevat een 8-bit
; ascii-teken (te visualiseren teken) + een 8-bit attribuut 
; (kleur, onderstreept, enz.)
;
printchar:
	push	eax
	push	ebx
	push	ecx
	push	edx
	xor     eax,eax
	xor     ebx,ebx
 	xor     ecx,ecx
	mov	ax,[esp+24]  ; rij
	mov	bx,[esp+22]  ; kol
	mov	cx,[esp+20]  ; char
	mov	ch, 00fh
	mov     dx,ax
	shl	ax,2
	add	ax,dx
	shl	ax,5
	shl	bx,1
	add	bx,ax
	mov	[VGA_MEM+ebx],cx
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret	6




;
; deze functie produceert de hoofdletters van het alfabet
; in het laagste byte van register esi.Per oproep wordt er 1 letter
; opgeschoven. Na Z komt terug A. Indien de oorspronkelijke waarde ' ' was,
; dan blijft deze behouden.
;

nextchar cmp	si,' '
	je	einde
	cmp	si,'Z'
	je	herbegin
	inc	si
	jmp 	einde
herbegin:
	mov	si,'A'
einde	ret



; deze routine tekent een spiraal op het scherm in een gegeven rechthoek
; input
;   ax = meest linkse kolom
;   bx = meest rechtse kolom
;   cx = bovenste rij
;   dx = onderste rij
;
; deze routine termineert nooit (blijft steeds maar spiralen tekenen).

spiraal:
        shl     eax,16
        shl     ebx,16
        shl     ecx,16
        shl     edx,16
	mov	si,' '
herstart:
	cmp	si,' '
	je	letters
	mov	si,' '
	jmp	eindelus
letters:mov	si,'A'
eindelus: 
        mov	edi,eax
	shr	edi,16
	mov	ax,di

        mov	edi,ebx
	shr	edi,16
	mov	bx,di

        mov	edi,ecx
	shr	edi,16
	mov	cx,di

        mov	edi,edx
	shr	edi,16
	mov	dx,di
lus1:	
        mov     di,ax
	cmp	di,bx
	jg	herstart
lus2:	
	push	cx
	push	di
	push	si
	call	printchar
	call	nextchar
	call	ShortDelay
	inc	di
	cmp	di,bx
	jle	lus2
        inc     cx
	mov	di,cx
	cmp     di,dx
	jg	herstart
lus3:	push	di
	push	bx
	push	si
	call	printchar
	call	nextchar
	call	ShortDelay
	inc	di
	cmp	di,dx
	jle	lus3
        dec     bx
        mov     di,bx
	cmp     di,ax
	jl	herstart
lus4:	push	dx
	push	di
	push	si
	call	printchar
	call	nextchar
	call	ShortDelay
	dec	di
	cmp	di,ax
	jge	lus4
	dec     dx
        mov     di,dx
	cmp     di,cx
	jl	herstart
lus5:	push	di
	push	ax
	push	si
	call	printchar
	call	nextchar
	call	ShortDelay
	dec	di
	cmp	di,cx
	jge	lus5
        inc	ax
        jmp     lus1    


debuggingstring1 db " Een stack gaat buiten het vooraf gedefinieerde gebied! ", 0
debuggingstring2 db " ESP: ", 0
debuggingstring3 db " EIP: ", 0
debughandler:
;jmp debughandler
; timer afzetten, of staat die al af nu met deze interupt? ### TODO
;ud2
    push 0
    push 0
    push debuggingstring1
    push 1
    push 0
    push debuggingstring2
    push 2
    push 0
    push debuggingstring3

    call printstring
    add   esp, 12
    call printstring
    add   esp, 12
    call printstring
    add   esp, 12

    mov eax, esp
    add eax, 3*4
    push 1
    push 6
    push eax
    call printhex
    add   esp, 12

    push 2
    push 6
    mov eax, [esp+8]
    push eax
    call printhex
    add   esp, 12

.debugdone:
    jmp .debugdone



TotalSize		EQU	$-$$
TotalSectors		EQU	(TotalSize + SectorSize) / SectorSize
SectorsToLoad		EQU	TotalSectors - 1 
	; TotalSectors - 1 want BIOS heeft de eerste voor ons reeds geladen

; technische opmerkingen:
; we nemen aan dat A20 per default enabled is
