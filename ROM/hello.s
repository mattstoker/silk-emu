; Hello
; Liquid Crystal Display Communication Demonstration for the W65C02 CPU and HD44780U LCD
;
; Assemble using a W65C02 compatible assembler (such as vasm):
; ./vasm6502_oldstyle -Fbin -dotdir hello.s && hexdump -v -e '16/1 "0x%02x, "' -e '"\n"' a.out
;
; This program utilizes the W65C02 CPU and W65C22 Versitile Interface Adapter (VIA) to communicate
; with a HD44780U LCD. The program first initalizes the LCD using the VIA Ports A & B. It then enters a
; loop that prints a message to the LCD, followed by looping forever.
;

; Device Hardware Address Map
ZERO_PAGE     = $0000 ; to $00ff - CPU Zero Page
STACK         = $0100 ; to $01ff - CPU Stack Memory
RAM           = $0200 ; to $1fff - General Purpose Memory
;               $2000   to $5fff - Unmapped
PORTB         = $6000 ;          - VIA Port B
PORTA         = $6001 ;          - VIA Port A
DDRB          = $6002 ;          - VIA Data Direction Register for Port B
DDRA          = $6003 ;          - VIA Data Direction Register for Port A
;               $6004   to $dfff - Unmapped
EEPROM        = $e000 ; to $fff9 - Program Memory (read-only)
NMIB_VEC      = $fffa ; to $fffb - CPU Non-Maskable Interrupt Vector
RESB_VEC      = $fffc ; to $fffd - CPU Reset Vector (holds initial value of program counter)
IRQB_VEC      = $fffe ; to $ffff - CPU Interrupt Request Vector

; Port A pins
LCD_E       = %10000000
LCD_RW      = %01000000
LCD_RS      = %00100000
;UNUSED     = %00011111

; Program Code
  .org EEPROM

reset:
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #$00000001 ; Clear display
  jsr lcd_instruction

  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  inx
  jmp print

loop:
  jmp loop

lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta DDRB
lcdbusy:
  lda #LCD_RW
  sta PORTA
  lda #(LCD_RW | LCD_E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcdbusy

  lda #LCD_RW
  sta PORTA
  lda #%11111111  ; Port B is output
  sta DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #LCD_E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #LCD_RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(LCD_RS | LCD_E)   ; Set E bit to send instruction
  sta PORTA
  lda #LCD_RS         ; Clear E bits
  sta PORTA
  rts

message: .asciiz "Hello, world!"

  .org $fffc
  .word reset
  .word $0000
