; Serial
; Serial Communication Demonstration for the W65C02 CPU and W65C51N ACIA
;
; Assemble using a W65C02 compatible assembler (such as vasm):
; ./vasm6502_oldstyle -Fbin -dotdir serial.s && hexdump -v -e '16/1 "0x%02x, "' -e '"\n"' a.out
;
; This program utilizes the W65C02 CPU and W65C22 Versitile Interface Adapter (VIA) to communicate
; with a W65C51N Asynchronous Communications Interface Adapter (ACIA) and HD44780U LCD.
; The program first initalizes the LCD and ACIA using the VIA Ports A & B. It then enters a loop
; where the ACIA is queried for data, the result displayed on the LCD, and the data echoed on the ACIA.
;
; Serial communcation is configured for 19200 baud N81. If another baud rate is needed, the serial
; wait loop should be reconfigured to wait for more or less time to accomodate the write time needed.
;

; Device Address Map
; $0000 to $3fff - RAM HM62256
; $4000 to $4fff - Unmapped
; $5000 to $5003 - Serial UART
; $5004 to $5fff - Unmapped
; $6000 to $6003 - Versatile Interface Adapter W65C22
; $6004 to $dfff - Unmapped
; $e000 to $ffff - EEPROM AT28C64B

; Detailed Device Hardware Address Map
ZERO_PAGE     = $0000 ; to $00ff - CPU Zero Page
STACK         = $0100 ; to $01ff - CPU Stack Memory
RAM           = $0200 ; to $1fff - General Purpose Memory
;               $2000   to $4fff - Unmapped
UART_DATA     = $5000 ;          - Serial UART Data Registers (R/W Signal: R - Receive / W - Send)
UART_STATUS   = $5001 ;          - Serial UART Status Register
UART_CMD      = $5002 ;          - Serial UART Command Register
UART_CTRL     = $5003 ;          - Serial UART Control Register
;               $5004   to $5fff - Unmapped
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
  ; Initialize VIA Data Direction Registers for Port A & B
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output and the rest to input for buttons
  sta DDRA
  
  ; Initialize LCD using VIA Port A & B
  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  sta PORTB
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA
  lda #LCD_E     ; Set LCD E bit to send instruction
  sta PORTA
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA

  lda #%00001110 ; Display on; cursor on; blink off
  sta PORTB
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA
  lda #LCD_E     ; Set LCD E bit to send instruction
  sta PORTA
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA

  lda #%00000110 ; Increment and shift cursor; don't shift display
  sta PORTB
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA
  lda #LCD_E     ; Set LCD E bit to send instruction
  sta PORTA
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA

  lda #%00000001 ; Clear display
  sta PORTB
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA
  lda #LCD_E     ; Set LCD E bit to send instruction
  sta PORTA
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA

  ; Initialize serial interface to N-8-1, no parity, no echo, no interrupts
  lda #$00 ;#%00000000
  sta UART_STATUS        ; Soft reset (value written is ignored)

  lda #$1f ;#%00011111
  sta UART_CTRL          ; Configure serial control for 19200 baud N-8-1
  lda UART_CTRL
  cmp #$1f
  bne error

  lda #$0b ;#%00001011
  sta UART_CMD           ; Configure serial commands for no parity, no echo, no interrupts
  lda UART_CMD
  cmp #$0b
  bne error

serial_read:
serial_read_wait:
  lda UART_STATUS
  and #$0F ;#%00001111   ; Check for receive register full, overrun, framing error, or parity error
  beq serial_read_wait
  and #$07 ;#%00000111   ; Check for overrun, framing error, or parity error
  beq serial_read_no_error
serial_read_error:
  lda UART_DATA          ; Read and discard the receive register to clear the error
  jmp serial_read_wait
serial_read_no_error:
  lda UART_DATA          ; Read received data from the serial receive register

print_char:
  tay
  sta PORTB
  lda #LCD_RS           ; Set LCD RS & Clear RW/E bits
  sta PORTA
  lda #(LCD_RS | LCD_E) ; Set LCD E bit to send instruction
  sta PORTA
  lda #LCD_RS           ; Clear LCD E bit
  sta PORTA
  tya

serial_write:
  sta UART_DATA          ; Write data to be sent to the serial send register
serial_write_wait:
  ldx #100
serial_write_delay:
  dex
  bne serial_write_delay ; Loop for 100 iterations, which lasts long enough @ 1MHz @ 19200 to transmit

  jmp serial_read

error:
  tay
  sta PORTB
  lda #LCD_RS           ; Set LCD RS & Clear RW/E bits
  sta PORTA
  lda #(LCD_RS | LCD_E) ; Set LCD E bit to send instruction
  sta PORTA
  lda #LCD_RS           ; Clear LCD E bit
  sta PORTA
  tya
  jmp error

; CPU Initialization Vector Locations
  .org NMIB_VEC
  .word $0000
  .org RESB_VEC
  .word reset    ; Initialize program counter to "reset" label address
  .org IRQB_VEC
  .word $0000
