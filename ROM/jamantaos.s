; JamantaOS
; Operating System for the W65C02 Microprocessor
;
; Assemble using a W65C02 compatible assembler (such as vasm):
; ./vasm6502_oldstyle -Fbin -dotdir jamantaos.s && hexdump -v -e '16/1 "0x%02x, "' -e '"\n"' a.out
;
; This assembly program offers facilities for working with a system of components
; attached to a W65C02 microprocessor, then hosting a program that can use those
; facilities to accomplish a task. This file is set up to run Conways Game of Life
; but can be changed to host embedded systems software for monitoring sensors,
; actuating stepper motors, running simple LCD-based user interfaces, and more.
;
; Assumes other devices share the data bus and use the high-order address bits
; to coordinate which device has access to the bus at any time. Mapped devices
; are: RAM module, EEPROM module, Versatile Interface Adapter, Serial UART, and
; a custom VGA using DMA. The custom VGA deactivates all other devices (including
; the CPU) while painting pixels, activating them during the VGA blanking interval.
;
; The Versatile Interface Adapter has 2 8-bit ports which are connected to an LCD
; control module as well as a 5-signal control pad. These devices are accessed by
; way of the VIA.
;
; The program initalizes memory and devices, then enters a loop monitoring the
; connected devices, some of which use an IRQ for operation and some do not.
; Execution is then controlled by the state of the connected devices, especially
; the control pad.
;
; Subroutines are provided for VGA, Serial UART, LCD control, and a control pad.
; The system is also set up to host an instance of WOZMON, a real-time memory
; inspector and debugger, which, when used in conjunction with the Serial UART,
; allows remote programming and monitoring of the system.
;
; The beginning of the address space holds the most-referenced variables as the
; W65C02 has faster instructions for accessing memory in the first 256 bytes of
; the address space. This is followed by a 256 byte stack page which is assumed
; as the high-order byte for stack access via the SP register. Any other memory
; required by the main hosted program follows these special allocations.
;
; The middle of the address space is occupied by memory-mapped devices and the
; main hosted program. This mapping is deailed below.
;
; The end of the address space is reserved for the W65C02 initialization vector,
; which provides the address where execution begins, as well as addresses for
; interrupt handlers (IRQ & NMI). For convenience, the interrupt handlers and
; WOZMON program are stored at the end of the address space as well, allowing the
; main hosted program to occupy a large unterrupted address space.

; Device Address Map
; $0000 to $3fff - RAM HM62256
; $4000 to $4fff - Unmapped
; $5000 to $5003 - Serial UART W65C51N
; $5004 to $5fff - Unmapped
; $6000 to $6003 - Versatile Interface Adapter W65C22
; $6004 to $dfff - Unmapped
; $e000 to $ffff - EEPROM AT28C64B

; Actual Device Address Map (Address Bits 13,14,15)
; %00xx $0000 to $3fff - RAM HM62256
; %010x $4000 to $5fff - Serial UART
; %011x $6000 to $7fff - Versatile Interface Adapter W65C22
; %1xxx $8000 to $ffff - EEPROM AT28C256

; Detailed Device Hardware Address Map
ZERO_PAGE     = $0000 ; to $00ff - CPU Zero Page
STACK         = $0100 ; to $01ff - CPU Stack Memory
RAM           = $0200 ; to $1fff - General Purpose Memory
VIDEO         = $2000 ; to $3fff - VGA Memory
;               $4000   to $4fff - Unmapped
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
EEPROM        = $e000 ; to $fedf - Program Memory (read-only)
EEPROM_IRQ    = $fee0 ; to $feff - Program Memory IRQ Routine (read-only)
WOZMON        = $ff00 ; to $fff9
NMIB_VEC      = $fffa ; to $fffb - CPU Non-Maskable Interrupt Vector
RESB_VEC      = $fffc ; to $fffd - CPU Reset Vector (holds initial value of program counter)
IRQB_VEC      = $fffe ; to $ffff - CPU Interrupt Request Vector

; VGA Dimensions
VIDEO_WIDTH = 100
VIDEO_HEIGHT = 64

; Port A pins
LCD_E       = %10000000
LCD_RW      = %01000000
LCD_RS      = %00100000
UP_BTN      = %00000001
LEFT_BTN    = %00000010
RIGHT_BTN   = %00000100
DOWN_BTN    = %00001000
ACTION_BTN  = %00010000

; RAM Allocation
null                 = $0000 ; 2 bytes
scratch              = $0002 ; 2 bytes
scratch1             = $0004 ; 2 bytes
scratch2             = $0006 ; 2 bytes
scratch3             = $0008 ; 2 bytes
scratch4             = $000a ; 2 bytes
scratch5             = $000c ; 2 bytes
scratch6             = $000e ; 2 bytes
pattern_start_color  = $0010 ; 1 byte
buttons              = $0011 ; 1 byte
previous_buttons     = $0012 ; 1 byte
cursor_x             = $0013 ; 1 byte
cursor_y             = $0014 ; 1 byte
cursor_color         = $0015 ; 1 byte
cursor_stored        = $0016 ; 1 byte
cgol_simulating      = $0017 ; 1 byte
cgol_generations     = $0018 ; 2 bytes
cgol_generation_reset= $001a ; 2 bytes
cgol_dead_cell_color = $001c ; 1 byte
cgol_live_cell_color = $001d ; 1 byte
uart_read_ptr        = $00fe ; 1 byte
uart_write_ptr       = $00ff ; 1 byte
stack                = $0100 ; 256 bytes
uart_input_buffer    = $0200 ; 256 bytes
cgol_line_previous   = $0300 ; 128 bytes
cgol_line_current    = $0380 ; 128 bytes
cgol_line_next       = $0400 ; 128 bytes
cgol_line_evaluated  = $0480 ; 128 bytes

; Program Code
  .org EEPROM
reset:
  ; Initialize stack register to point to 0x01ff
  ldx #$ff
  txs

  ; Initialize serial interface and enable interrupts
  jsr serial_initialize
  cli

  ; Initialize LCD via Port A/B
  jsr lcd_init
  jsr lcd_clear
  ldx #<init_message
  ldy #>init_message
  jsr lcd_print_message

  ; Clear video memory
  lda #%00000000
  jsr vga_clear

  ; Initialize cursor state
  lda #VIDEO_WIDTH / 2
  sta cursor_x
  lda #VIDEO_HEIGHT / 2
  sta cursor_y
  lda #%11111111
  sta cursor_color
  lda #%00000000
  sta cursor_stored
  lda #$0
  sta buttons
  lda #$ff
  sta previous_buttons
  ldx cursor_x
  ldy cursor_y
  lda cursor_color
  jsr vga_draw_pixel

  ; Initialize cgol state
  lda #0
  sta cgol_simulating
  sta cgol_generations
  sta cgol_generations + 1
  lda #%00000000
  sta cgol_dead_cell_color
  lda #%00001100
  sta cgol_live_cell_color
  lda #$7f
  sta cgol_generation_reset
  lda #$01
  sta cgol_generation_reset + 1
  ldx #0
clear_cgol_buffers:
  lda cgol_dead_cell_color
  sta cgol_line_previous,X
  sta cgol_line_current,X
  sta cgol_line_next,X
  sta cgol_line_evaluated,X
  inx
  cpx #VIDEO_WIDTH
  bne clear_cgol_buffers

  ; Enter main loop
  jmp loop

; Main Program Loop
loop:

  ; Echo anything in the serial circular input buffer and write it to the LCD
  jsr serial_buffer_size
  beq print_serial_done
  tax
print_serial_char:
  jsr serial_read_buffer
  jsr lcd_print_char
  jsr serial_transmit
  dex
  bne print_serial_char
print_serial_done:

  ; Query button state
  jsr control_pad_query_buttons

  ; Check if buttons have changed since the last iteration
check_buttons_changed:
  lda buttons
  cmp previous_buttons
  bne buttons_changed

buttons_unchanged:
  ; Even when button state has not changed, check the action button and execute its effect
  jmp check_action

buttons_changed:
  ; Store current button state and clear LCD message
  sta previous_buttons
  jsr lcd_clear

  ; Execute an effect based on which buttons are pressed
check_all:
  lda buttons
  cmp #(LEFT_BTN | RIGHT_BTN | UP_BTN | DOWN_BTN | ACTION_BTN)
  bne clear_cursor

  ldx #<wozmon_message
  ldy #>wozmon_message
  jsr lcd_print_message
  
  jmp WOZMON

clear_cursor:
  ; Clear current cursor location
  ldx cursor_x
  ldy cursor_y
  lda cursor_stored
  jsr vga_draw_pixel

check_left:
  lda buttons
  and #LEFT_BTN
  beq check_right

  jsr lcd_clear
  ldx #<left_message
  ldy #>left_message
  jsr lcd_print_message

  lda #$0
  cmp cursor_x
  beq check_right
  dec cursor_x

check_right:
  lda buttons
  and #RIGHT_BTN
  beq check_up

  jsr lcd_clear
  ldx #<right_message
  ldy #>right_message
  jsr lcd_print_message

  lda #VIDEO_WIDTH - 1
  cmp cursor_x
  beq check_up
  inc cursor_x

check_up:
  lda buttons
  and #UP_BTN
  beq check_down

  jsr lcd_clear
  ldx #<up_message
  ldy #>up_message
  jsr lcd_print_message

  lda #$0
  cmp cursor_y
  beq check_down
  dec cursor_y

check_down:
  lda buttons
  and #DOWN_BTN
  beq draw_cursor

  jsr lcd_clear
  ldx #<down_message
  ldy #>down_message
  jsr lcd_print_message

  lda #VIDEO_HEIGHT - 1
  cmp cursor_y
  beq check_action
  inc cursor_y

draw_cursor:
  ; Draw the cursor at its current position
  ldx cursor_x
  ldy cursor_y
  jsr vga_read_pixel
  sta cursor_stored
  ldx cursor_x
  ldy cursor_y
  lda cursor_color
  jsr vga_draw_pixel

check_action:
  lda buttons
  and #ACTION_BTN
  beq check_buttons_done

  jsr lcd_clear
  ldx #<action_message
  ldy #>action_message
  jsr lcd_print_message
  
  ; Perform an action based on which other buttons are also being held down
  lda buttons
  ; jsr vga_fill_buttons

  ; Begin simulation if the proper sequence is held
  cmp #(LEFT_BTN | RIGHT_BTN | ACTION_BTN)
  beq cgol_toggle_simulating
  
  ; When action was pressed but no other actions were activated, toggle the current cursor location
  lda cgol_live_cell_color
  sta cursor_stored
  
  jmp check_buttons_done

cgol_toggle_simulating:
  ; Toggle CGOL simulation running state and, if now running, initialize it
  lda cgol_simulating
  eor #%00000001
  sta cgol_simulating
  beq check_buttons_done

  ; Declare this the zero generation
  lda #0
  sta cgol_generations
  sta cgol_generations + 1

  ; Clear current cursor location
  ldx cursor_x
  ldy cursor_y
  lda cursor_stored
  jsr vga_draw_pixel

  jmp check_buttons_done

cgol_reset_to_acorn:
  ; Clear screen to dead cell color
  lda cgol_dead_cell_color
  jsr vga_clear

  ; Cycle through colors to represent the live cell color with each reset (but not black)
  lda cgol_live_cell_color
  clc
  adc #1
  ora #%00000001
  and #%00111111
  sta cgol_live_cell_color
  
  ; Draw 'Acorn' pattern of live cells near screen center
  ;
  ;  X
  ;    X
  ; XX  XXX
  ;
  lda cgol_live_cell_color
  ldx #60
  ldy #30
  jsr vga_draw_pixel
  ldx #62
  ldy #31
  jsr vga_draw_pixel
  ldx #59
  ldy #32
  jsr vga_draw_pixel
  ldx #60
  jsr vga_draw_pixel
  ldx #63
  jsr vga_draw_pixel
  ldx #64
  jsr vga_draw_pixel
  ldx #65
  jsr vga_draw_pixel

  ; Declare this the zero generation
  lda #0
  sta cgol_generations
  sta cgol_generations + 1

check_buttons_done:

  ; Check if simulation is running and advance it if so
  lda cgol_simulating
  beq loop_continue
  jsr cgol_advance_simulation
  lda cgol_generations
  cmp cgol_generation_reset
  bne display_cgol_status
  lda cgol_generations + 1
  cmp cgol_generation_reset + 1
  bne display_cgol_status
  jmp cgol_reset_to_acorn

  ; Display cgol status
display_cgol_status:
  jsr lcd_clear
  ldx #<cgol_message
  ldy #>cgol_message
  jsr lcd_print_message
  lda cgol_generations + 1
  jsr lcd_print_byte_hex
  lda cgol_generations
  jsr lcd_print_byte_hex

loop_continue:
  ; Continue executing main loop
  jmp loop

; Calculates the next generation of Conway's Game of Life in VGA memory
; - Parameters
;   * None
; - Return
;   * None
cgol_advance_simulation:
  pha
  tya
  pha
  txa
  pha
  
  ; Seed evaluation buffers with last, first, and second VGA lines
  ldy #0
  jsr cgol_push_line
  ldy #1
  jsr cgol_push_line
  ldy #2
  jsr cgol_push_line
  
  ;  ldy #1
evaluate_loop:
  ; Evaluate the CGOL algorithm against the buffers
  jsr cgol_evaluate
  
  ; Copy the result to VGA memory
  lda #<cgol_line_evaluated
  ldx #>cgol_line_evaluated
  jsr vga_draw_line
  
  ; Increment current line
  iny
  
  ; Push line after current line to evaluation buffers
  iny
  jsr cgol_push_line
  dey
  
  ; Check if done
  tya
  cmp #VIDEO_HEIGHT - 2
  bne evaluate_loop

  ; Advance generation counter
  ; TODO: Can do 16-bit memory increment?
  lda cgol_generations
  cmp #$FF
  bne increment_cgol_generations_low
increment_cgol_generations_high:
  inc cgol_generations + 1
increment_cgol_generations_low:
  inc cgol_generations
  
  pla
  tax
  pla
  tay
  pla
  rts

; Determine the number of live cells in the 8 neighbors of a coordinate
; - Parameters
;   * cgol_line_current: Cells to evaluate live/dead status for
;   * cgol_line_previous: Cells corresponding to those 'above' the current line
;   * cgol_line_next: Cells corresponding to those 'below' the current line
; - Return
;   * cgol_line_evaluated: Evaluated live/dead status for cells in cgol_line_current
cgol_evaluate:
  pha
  tya
  pha
  txa
  pha

  ; Sum the live cells in the 8 neighbors of the current cell in X,Y registers
  ldx #0
cgol_evaluate_loop:
  ldy #0

cgol_evaluate_top_middle:
  lda cgol_line_previous,X
  beq cgol_evaluate_bottom_middle
  iny
cgol_evaluate_bottom_middle:
  lda cgol_line_next,X
  beq cgol_evaluate_middle_done
  iny
cgol_evaluate_middle_done:

cgol_neighbor_check_left_edge:
  cpx #0
  beq cgol_neighbor_check_right_edge

  dex
cgol_evaluate_top_left:
  lda cgol_line_previous,X
  beq cgol_evaluate_center_left
  iny
cgol_evaluate_center_left:
  lda cgol_line_current,X
  beq cgol_evaluate_bottom_left
  iny
cgol_evaluate_bottom_left:
  lda cgol_line_next,X
  beq cgol_evaluate_left_done
  iny
cgol_evaluate_left_done:
  inx

cgol_neighbor_check_right_edge:
  cpx #VIDEO_WIDTH - 1
  beq cgol_evaluate_apply

  inx
cgol_evaluate_top_right:
  lda cgol_line_previous,X
  beq cgol_evaluate_center_right
  iny
cgol_evaluate_center_right:
  lda cgol_line_current,X
  beq cgol_evaluate_bottom_right
  iny
cgol_evaluate_bottom_right:
  lda cgol_line_next,X
  beq cgol_evaluate_right_done
  iny
cgol_evaluate_right_done:
  dex

  ; Y register contains count of live neighbors
  ; Apply rules of Conway's Game of Life to mark this cell dead or alive
cgol_evaluate_apply:
  
  lda cgol_line_current,X
  cmp cgol_dead_cell_color
  beq cgol_evaluate_apply_currently_dead

cgol_evaluate_apply_currently_alive:
  cpy #2
  beq cgol_evaluate_alive
  cpy #3
  beq cgol_evaluate_alive
  jmp cgol_evaluate_dead

cgol_evaluate_apply_currently_dead:
  cpy #3
  beq cgol_evaluate_alive
  jmp cgol_evaluate_dead
  
cgol_evaluate_dead:
  ; Write dead cell to evaluated location
  lda cgol_dead_cell_color
  sta cgol_line_evaluated,X
  jmp cgol_evaluate_check_done

cgol_evaluate_alive:
  ; Write live cell to evaluated location
  lda cgol_live_cell_color
  sta cgol_line_evaluated,X

cgol_evaluate_check_done:
  inx
  cpx #VIDEO_WIDTH
  bne cgol_evaluate_loop
  
  pla
  tax
  pla
  tay
  pla
  rts

; Read a pixel from on-screen at a specified location
; - Parameters
;   * Y: Y coordinate from 0 to 64 of line to push into cgol_line_next
; - Return
;   * None
cgol_push_line:
  sty scratch

  pha
  tya
  pha
  txa
  pha

  ; Copy current line buffer to previous line buffer
  ldx #$00
cgol_copy_current_to_previous_loop:
  lda cgol_line_current,X
  sta cgol_line_previous,X
  inx
  cpx #VIDEO_WIDTH
  bne cgol_copy_current_to_previous_loop

  ; Copy next line buffer to current line buffer
  ldx #$00
cgol_copy_next_to_current_loop:
  lda cgol_line_next,X
  sta cgol_line_current,X
  inx
  cpx #VIDEO_WIDTH
  bne cgol_copy_next_to_current_loop

  ; Copy passed VGA line to next line buffer
  ldy scratch
  lda #<cgol_line_next
  ldx #>cgol_line_next
  jsr vga_read_line

  pla
  tax
  pla
  tay
  pla
  rts

; Fill all video memory based on button state
; - Parameters
;   * A: Button State
; - Return
;   * A: Fill color corresponding to buttons (unless pattern is emitted)
vga_fill_buttons:
  cmp #(LEFT_BTN | ACTION_BTN)
  beq patternL
  cmp #(LEFT_BTN | RIGHT_BTN | ACTION_BTN)
  beq patternLR
  cmp #(LEFT_BTN | UP_BTN | ACTION_BTN)
  beq patternLU
  cmp #(LEFT_BTN | DOWN_BTN | ACTION_BTN)
  beq patternLD
  cmp #(LEFT_BTN | RIGHT_BTN | UP_BTN | ACTION_BTN)
  beq patternLRU
  cmp #(LEFT_BTN | RIGHT_BTN | DOWN_BTN | ACTION_BTN)
  beq patternLRD
  cmp #(LEFT_BTN | UP_BTN | DOWN_BTN | ACTION_BTN)
  beq patternLUD
  cmp #(LEFT_BTN | RIGHT_BTN | UP_BTN | DOWN_BTN | ACTION_BTN)
  beq patternLRUD
  cmp #(RIGHT_BTN | ACTION_BTN)
  beq patternR
  cmp #(RIGHT_BTN | UP_BTN | ACTION_BTN)
  beq patternRU
  cmp #(RIGHT_BTN | DOWN_BTN | ACTION_BTN)
  beq patternRD
  cmp #(RIGHT_BTN | UP_BTN | DOWN_BTN | ACTION_BTN)
  beq patternRUD
  cmp #(UP_BTN | ACTION_BTN)
  beq patternU
  cmp #(UP_BTN | DOWN_BTN | ACTION_BTN)
  beq patternUD
  cmp #(DOWN_BTN | ACTION_BTN)
  beq patternD
  cmp #(ACTION_BTN)
  beq patternA

  patternA:
  jsr vga_fill_pattern
  rts
  patternL:
  lda #%00000011
  jsr vga_clear
  rts
  patternR:
  lda #%00001100
  jsr vga_clear
  rts
  patternU:
  lda #%00110000
  jsr vga_clear
  rts
  patternD:
  lda #%11000000
  jsr vga_clear
  rts
  patternLR:
  lda #%00001111
  jsr vga_clear
  rts
  patternLU:
  lda #%00110011
  jsr vga_clear
  rts
  patternLD:
  lda #%11000011
  jsr vga_clear
  rts
  patternRU:
  lda #%00111100
  jsr vga_clear
  rts
  patternRD:
  lda #%11001100
  jsr vga_clear
  rts
  patternUD:
  lda #%11110000
  jsr vga_clear
  rts
  patternLRU:
  lda #%00111111
  jsr vga_clear
  rts
  patternLRD:
  lda #%11001111
  jsr vga_clear
  rts
  patternLUD:
  lda #%11110011
  jsr vga_clear
  rts
  patternRUD:
  lda #%11111100
  jsr vga_clear
  rts
  patternLRUD:
  lda #%11111111
  jsr vga_fill_eeprom ;vga_clear
  rts

; Clear video memory to a specified color
; - Parameters
;   * A: Color %RRGGBBXX
; - Return
;   * None
vga_clear:
  sta scratch1
  pha
  tya
  pha
  txa
  pha

  lda #<VIDEO
  sta scratch
  lda #>VIDEO
  sta scratch + 1
  
  ldx #$0

vga_clear_line_pair:
  lda #<VIDEO
  sta scratch
  lda scratch1
  ldy #$0
vga_clear_first_line:
  sta (scratch),Y
  iny
  cpy #VIDEO_WIDTH
  bne vga_clear_first_line

  lda #<VIDEO + $80
  sta scratch
  lda scratch1
  ldy #$0
vga_clear_second_line:
  sta (scratch),Y
  iny
  cpy #VIDEO_WIDTH
  bne vga_clear_second_line

vga_clear_move_to_next_pair:
  inc scratch + 1
  inx
  cpx #VIDEO_HEIGHT / 2
  bne vga_clear_line_pair

  pla
  tax
  pla
  tay
  pla
  rts

; Copies the contents of EEPROM memory to video memory
; (including hidden bytes to the right of visible video memory)
; - Parameters
;   * None
; - Return
;   * None
vga_fill_eeprom:
  pha
  tya
  pha
  txa
  pha

  lda scratch
  pha

  lda #<VIDEO
  sta scratch
  lda #>VIDEO
  sta scratch + 1
  
  lda #<EEPROM
  sta scratch1
  lda #>EEPROM
  sta scratch1 + 1

  ldx #VIDEO_HEIGHT / 2
  ldy #$0
  pla

vga_fill_eeprom_line:
  lda (scratch1),Y
  sta (scratch),Y
  iny
  bne vga_fill_eeprom_line

  inc scratch + 1
  inc scratch1 + 1
  dex
  bne vga_fill_eeprom_line

  pla
  tax
  pla
  tay
  pla
  rts

; Clear all video memory to a pattern that shifts with each call
; (including hidden bytes to the right of visible video memory)
; - Parameters
;   * None
; - Return
;   * None
vga_fill_pattern:
  pha
  tya
  pha
  txa
  pha

  ; Initialize scratch variable to beginning of video ram $2000
  lda #>VIDEO
  sta scratch + 1
  lda #<VIDEO
  sta scratch

  ldx #$20 ; X will count down how many pages of video RAM to go
  ldy #$0 ; populate a page starting at 0
  inc pattern_start_color
  lda pattern_start_color ; color of pixel

page:
  sta (scratch),Y ; write A register to address scratch + y

  and #$7f ; if we cycled through 127 colors
  bne inc_color
  clc
  adc #$1 ; increment twice

inc_color:
  clc
  adc #$1 ; otherwise, increment pixel color value just once

  iny
  bne page

  inc scratch + 1 ; skip to the next page
  dex
  bne page ; keep going through $20 pages

  pla
  tax
  pla
  tay
  pla
  rts

; Draw a pixel on-screen at a specified location
; - Parameters
;   * X: X coordinate from 0 to 99
;   * Y: Y coordinate from 0 to 64
;   * A: Color %RRGGBBXX
; - Return
;   * None
vga_draw_pixel:
  sta scratch1
  pha
  tya
  pha
  txa
  pha

  ; Determine the VGA memory location corresponding to the coordinate X,Y and put in scratch
  tya
  lsr ; Y / 2
  clc
  adc #>VIDEO
  sta scratch + 1
  txa
  clc
  adc #<VIDEO
  sta scratch
  tya
  and #%00000001
  beq vga_draw_pixel_location_calculated
  lda scratch
  ora #%10000000
  sta scratch
vga_draw_pixel_location_calculated:

  ; Transfer the color to the coordinate
  ldy #0
  lda scratch1
  sta (scratch),Y

  pla
  tax
  pla
  tay
  pla
  rts

; Draw a line of pixels on-screen at a specified location
; - Parameters
;   * Y: Y coordinate from 0 to 64
;   * A: Low byte of buffer containing line to write
;   * X: High byte of buffer containing line to write
; - Return
;   * None
vga_draw_line:
  sta scratch1
  stx scratch1 + 1

  pha
  tya
  pha
  txa
  pha

  ; Determine the VGA memory location corresponding to the coordinate X,Y and put in scratch
  lda #<VIDEO
  sta scratch
  tya
  lsr ; Y / 2
  clc
  adc #>VIDEO
  sta scratch + 1
  tya
  and #%00000001
  beq vga_draw_line_location_calculated
  lda scratch
  ora #%10000000
  sta scratch
vga_draw_line_location_calculated:

  ldy #0
vga_draw_line_loop:
  lda (scratch1),Y
  sta (scratch),Y
  iny
  cpy #VIDEO_WIDTH
  bne vga_draw_line_loop

  pla
  tax
  pla
  tay
  pla
  rts

; Read a pixel from on-screen at a specified location
; - Parameters
;   * X: X coordinate from 0 to 99
;   * Y: Y coordinate from 0 to 64
; - Return
;   * A: Color %RRGGBBXX
vga_read_pixel:
  tya
  pha
  txa
  pha
  
  ; Determine the VGA memory location corresponding to the coordinate X,Y and put in scratch
  tya
  lsr ; Y / 2
  clc
  adc #>VIDEO
  sta scratch + 1
  txa
  clc
  adc #<VIDEO
  sta scratch
  tya
  and #%00000001
  beq vga_read_pixel_location_calculated
  lda scratch
  ora #%10000000
  sta scratch
vga_read_pixel_location_calculated:
  
  ; Read the color from the coordinate
  ldy #0
  lda (scratch),Y
  sta scratch1
  
  pla
  tax
  pla
  tay
  lda scratch1
  rts

; Read a line of pixels from on-screen at a specified location
; - Parameters
;   * Y: Y coordinate from 0 to 64
;   * A: Low byte of destination buffer
;   * X: High byte of destination buffer
; - Return
;   * None
vga_read_line:
  sta scratch1
  stx scratch1 + 1

  pha
  tya
  pha
  txa
  pha

  ; Determine the VGA memory location corresponding to the coordinate X,Y and put in scratch
  lda #<VIDEO
  sta scratch
  tya
  lsr ; Y / 2
  clc
  adc #>VIDEO
  sta scratch + 1
  tya
  and #%00000001
  beq vga_read_line_location_calculated
  lda scratch
  ora #%10000000
  sta scratch
vga_read_line_location_calculated:

  ; Read a line of pixels into the location given in scratch1
  ldy #$00
vga_read_line_loop:
  lda (scratch),Y
  sta (scratch1),Y
  iny
  tya 
  cmp #VIDEO_WIDTH
  bne vga_read_line_loop

  pla
  tax
  pla
  tay
  pla
  rts

; Initialize serial interface to be ready to receive / transmit data
; - Parameters
;   * None
; - Return
;   * None
serial_initialize:
  pha

  lda #%00000000         ; Soft reset (value written is ignored)
  sta UART_STATUS

  lda #%00011111         ; Configure serial control for 19200 baud N-8-1
  sta UART_CTRL

  lda #%00001001         ; Configure serial commands for no parity, no echo, enabled interrupts
  sta UART_CMD

  jsr serial_buffer_clear

  pla
  rts

; Read a byte of data from the serial interface, waiting for data to be received if necessary
; - Parameters
;   * None
; - Return
;   * A - Byte read
serial_receive:
serial_receive_wait:
  lda UART_STATUS
  and #$08 ;#%00001000   ; Check if RX buffer status flag indicates data has been received
  beq serial_receive_wait   ; Loop until data has been shifted in to the receive register

  lda UART_DATA          ; Read received data from the serial receive register
  rts

; Write a byte of data to the serial interface, waiting for the data to be transmitted
; - Parameters
;   * A - Byte to write
; - Return
;   * None
serial_transmit:
  pha

  sta UART_DATA          ; Write data to be sent to the serial send register

serial_transmit_wait:
  ; Serial UART has a bug, TX buffer status flag is always high, so a delay loop must be used instead
  ;lda UART_STATUS
  ;and #$10 ;#%00010000  ; Check if TX buffer status flag indicates data has been transmitted
  ;beq serial_transmit_wait ; Loop until data has been shifted out of the send register

  txa
  pha
  ldx #100
serial_transmit_delay:
  dex
  bne serial_transmit_delay ; Loop for 100 iterations, which lasts long enough @ 1MHz @ 19200 to transmit
  pla
  tax

  pla
  rts

; Print message to the serial interface, waiting for the data to be transmitted
; - Parameters
;   * X(LO),Y(HI): Pointer to Null-terminated Message
; - Return
;   * None
serial_transmit_message:
  pha
  txa
  pha
  tya
  pha

  stx scratch
  sty scratch + 1
  ldy #0
serial_transmit_char:
  lda (scratch),Y
  beq serial_transmit_done
  jsr serial_transmit
  iny
  jmp serial_transmit_char

serial_transmit_done:
  pla
  tay
  pla
  txa
  pla
  rts

; Initialize / clear serial circular input buffer state
; - Parameters
;   * None
; - Return
;   * None
serial_buffer_clear:
  pha

  lda #$00                 ; Set the UART circular buffer read / write pointers to be equal
  sta uart_read_ptr
  sta uart_write_ptr

  pla
  rts

; Determine the size of the serial circular input buffer
; - Parameters
;   * None
; - Return
;   * A - number of bytes ready to be read from the serial circular input buffer
serial_buffer_size:
  lda uart_write_ptr
  sec
  sbc uart_read_ptr

  rts

; Read a byte from the serial circular input buffer
; - Parameters
;   * None
; - Return
;   * A - byte from the serial circular input buffer
serial_read_buffer:
  txa
  pha

  ldx uart_read_ptr        ; Load the received data from the serial circular input buffer
  lda uart_input_buffer,X
  inc uart_read_ptr
  sta scratch

  pla
  tax
  lda scratch
  rts

; Write a byte into the serial circular input buffer
; - Parameters
;   * A - Byte to write
; - Return
;   * None
serial_write_buffer:
  sta scratch

  pha
  txa
  pha

  lda scratch
  ldx uart_write_ptr       ; Store the received data into the serial circular input buffer
  sta uart_input_buffer,X
  inc uart_write_ptr

  pla
  tax
  pla
  rts

; Query the pressed state of the buttons on VIA Port A
; - Parameters
;   * None
; - Return
;   * buttons: Button press state in %00011111
control_pad_query_buttons:
  pha

  lda PORTA
  and #(LEFT_BTN | UP_BTN | DOWN_BTN | RIGHT_BTN | ACTION_BTN)
  sta buttons

  pla
  rts

; Initialize VIA Port A & B and LCD
; - Parameters
;   * None
; - Return
;   * None
lcd_init:
  pha

  ; Initialize VIA Data Direction Registers for Port A & B
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output and the rest to input for buttons
  sta DDRA

  ; Initialize LCD using VIA Port A & B
  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction

  pla
  rts

; Initialize VIA Port A & B and LCD
; - Parameters
;   * None
; - Return
;   * None
lcd_clear:
  pha

  lda #%00000001 ; Clear display
  jsr lcd_instruction

  pla
  rts

; Poll LCD using VIA Port A/B until it is ready to receive data
; - Parameters
;   * None
; - Return
;   * None
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

; Execute an LCD instruction
; - Parameters
;   * A: Instruction value to write to LCD using VIA Port A/B
; - Return
;   * None
lcd_instruction:
  pha

  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA
  lda #LCD_E     ; Set LCD E bit to send instruction
  sta PORTA
  lda #0         ; Clear LCD RS/RW/E bits
  sta PORTA

  pla
  rts

; Print a character to the LCD using VIA Port A/B
; - Parameters
;   * A: ASCII value of character to store
; - Return
;   * None
lcd_print_char:
  pha

  jsr lcd_wait
  sta PORTB
  lda #LCD_RS           ; Set LCD RS & Clear RW/E bits
  sta PORTA
  lda #(LCD_RS | LCD_E) ; Set LCD E bit to send instruction
  sta PORTA
  lda #LCD_RS           ; Clear LCD E bit
  sta PORTA

  pla
  rts

; Print the hexadecimal value of a byte to the LCD using VIA Port A/B
; - Parameters
;   * A: Byte to display
; - Return
;   * None
lcd_print_byte_hex:
  sta scratch
  pha

  lsr A
  lsr A
  lsr A
  lsr A
  and #$0F
  jsr lcd_print_low_nibble_hex

  lda scratch
  and #$0F
  jsr lcd_print_low_nibble_hex

  pla
  rts

; Print the hexadecimal value of the low nibble of a byte to the LCD using VIA Port A/B
; - Parameters
;   * A: Low-4 bytes: Hex value to display
; - Return
;   * None
lcd_print_low_nibble_hex:
  pha

  and #$0F

  ; TODO: Use CMP / BCS to check greater-than 9 instead of all non-decimal hex values
lcd_print_low_nibble_hex_check_a:
  cmp #$0A
  bne lcd_print_low_nibble_hex_check_b
  lda #'A'
  jmp lcd_print_low_nibble_hex_print
lcd_print_low_nibble_hex_check_b:
  cmp #$0B
  bne lcd_print_low_nibble_hex_check_c
  lda #'B'
  jmp lcd_print_low_nibble_hex_print
lcd_print_low_nibble_hex_check_c:
  cmp #$0C
  bne lcd_print_low_nibble_hex_check_d
  lda #'C'
  jmp lcd_print_low_nibble_hex_print
lcd_print_low_nibble_hex_check_d:
  cmp #$0D
  bne lcd_print_low_nibble_hex_check_e
  lda #'D'
  jmp lcd_print_low_nibble_hex_print
lcd_print_low_nibble_hex_check_e:
  cmp #$0E
  bne lcd_print_low_nibble_hex_check_f
  lda #'E'
  jmp lcd_print_low_nibble_hex_print
lcd_print_low_nibble_hex_check_f:
  cmp #$0F
  bne lcd_print_low_nibble_hex_decimal
  lda #'F'
  jmp lcd_print_low_nibble_hex_print
lcd_print_low_nibble_hex_decimal:
  clc
  adc #'0'
  jmp lcd_print_low_nibble_hex_print

lcd_print_low_nibble_hex_print:
  jsr lcd_print_char

  pla
  rts

; Print message to LCD
; - Parameters
;   * X(LO),Y(HI): Pointer to Null-terminated Message
; - Return
;   * None
lcd_print_message:
  pha
  txa
  pha
  tya
  pha

  stx scratch
  sty scratch + 1
  ldy #0
print:
  lda (scratch),Y
  beq print_done
  jsr lcd_print_char
  iny
  jmp print

print_done:
  pla
  tay
  pla
  txa
  pla
  rts

; Text Memory
init_message:   .asciiz "6502 16kRAM8kROM"
left_message:   .asciiz "Left Pressed    "
right_message:  .asciiz "Right Pressed   "
up_message:     .asciiz "Up Pressed      "
down_message:   .asciiz "Down Pressed    "
action_message: .asciiz "Action Pressed  "
cgol_message:   .asciiz "Conways GoL "
wozmon_message: .asciiz "Serial 19200 N81"

  .org EEPROM_IRQ
irq:
  pha
  txa
  pha

irq_check_uart:
  lda UART_STATUS          ; Check UART status register to see if it raised the interrupt for data ready
  lda UART_DATA            ; Read received data from the serial receive register
  jsr serial_write_buffer  ; Write the data into the serial circular input buffer

irq_exit:
  pla
  tax
  pla
  rti

  .org WOZMON

XAML  = $24                            ; Last "opened" location Low
XAMH  = $25                            ; Last "opened" location High
STL   = $26                            ; Store address Low
STH   = $27                            ; Store address High
L     = $28                            ; Hex value parsing Low
H     = $29                            ; Hex value parsing High
YSAV  = $2A                            ; Used to see if hex value is given
MODE  = $2B                            ; $00=XAM, $7F=STOR, $AE=BLOCK XAM

IN    = uart_input_buffer              ; Input buffer

ACIA_DATA   = UART_DATA
ACIA_STATUS = UART_STATUS
ACIA_CMD    = UART_CMD
ACIA_CTRL   = UART_CTRL

RESET:
                LDA     #$1F           ; 8-N-1, 19200 baud.
                STA     ACIA_CTRL
                LDA     #$0B           ; No parity, no echo, no interrupts.
                STA     ACIA_CMD
                LDA     #$1B           ; Begin with escape.

NOTCR:
                CMP     #$08           ; Backspace key?
                BEQ     BACKSPACE      ; Yes.
                CMP     #$1B           ; ESC?
                BEQ     ESCAPE         ; Yes.
                INY                    ; Advance text index.
                BPL     NEXTCHAR       ; Auto ESC if line longer than 127.

ESCAPE:
                LDA     #$5C           ; "\".
                JSR     ECHO           ; Output it.

GETLINE:
                LDA     #$0D           ; Send CR
                JSR     ECHO

                LDY     #$01           ; Initialize text index.
BACKSPACE:      DEY                    ; Back up text index.
                BMI     GETLINE        ; Beyond start of line, reinitialize.

NEXTCHAR:
                LDA     ACIA_STATUS    ; Check status.
                AND     #$08           ; Key ready?
                BEQ     NEXTCHAR       ; Loop until ready.
                LDA     ACIA_DATA      ; Load character. B7 will be '0'.
                STA     IN,Y           ; Add to text buffer.
                JSR     ECHO           ; Display character.
                CMP     #$0D           ; CR?
                BNE     NOTCR          ; No.

                LDY     #$FF           ; Reset text index.
                LDA     #$00           ; For XAM mode.
                TAX                    ; X=0.
SETBLOCK:
                ASL
SETSTOR:
                ASL                    ; Leaves $7B if setting STOR mode.
                STA     MODE           ; $00 = XAM, $74 = STOR, $B8 = BLOK XAM.
BLSKIP:
                INY                    ; Advance text index.
NEXTITEM:
                LDA     IN,Y           ; Get character.
                CMP     #$0D           ; CR?
                BEQ     GETLINE        ; Yes, done this line.
                CMP     #$2E           ; "."?
                BCC     BLSKIP         ; Skip delimiter.
                BEQ     SETBLOCK       ; Set BLOCK XAM mode.
                CMP     #$3A           ; ":"?
                BEQ     SETSTOR        ; Yes, set STOR mode.
                CMP     #$52           ; "R"?
                BEQ     RUN            ; Yes, run user program.
                STX     L              ; $00 -> L.
                STX     H              ;    and H.
                STY     YSAV           ; Save Y for comparison

NEXTHEX:
                LDA     IN,Y           ; Get character for hex test.
                EOR     #$30           ; Map digits to $0-9.
                CMP     #$0A           ; Digit?
                BCC     DIG            ; Yes.
                ADC     #$88           ; Map letter "A"-"F" to $FA-FF.
                CMP     #$FA           ; Hex letter?
                BCC     NOTHEX         ; No, character not hex.
DIG:
                ASL
                ASL                    ; Hex digit to MSD of A.
                ASL
                ASL

                LDX     #$04           ; Shift count.
HEXSHIFT:
                ASL                    ; Hex digit left, MSB to carry.
                ROL     L              ; Rotate into LSD.
                ROL     H              ; Rotate into MSD's.
                DEX                    ; Done 4 shifts?
                BNE     HEXSHIFT       ; No, loop.
                INY                    ; Advance text index.
                BNE     NEXTHEX        ; Always taken. Check next character for hex.

NOTHEX:
                CPY     YSAV           ; Check if L, H empty (no hex digits).
                BEQ     ESCAPE         ; Yes, generate ESC sequence.

                BIT     MODE           ; Test MODE byte.
                BVC     NOTSTOR        ; B6=0 is STOR, 1 is XAM and BLOCK XAM.

                LDA     L              ; LSD's of hex data.
                STA     (STL,X)        ; Store current 'store index'.
                INC     STL            ; Increment store index.
                BNE     NEXTITEM       ; Get next item (no carry).
                INC     STH            ; Add carry to 'store index' high order.
TONEXTITEM:     JMP     NEXTITEM       ; Get next command item.

RUN:
                JMP     (XAML)         ; Run at current XAM index.

NOTSTOR:
                BMI     XAMNEXT        ; B7 = 0 for XAM, 1 for BLOCK XAM.

                LDX     #$02           ; Byte count.
SETADR:         LDA     L-1,X          ; Copy hex data to
                STA     STL-1,X        ;  'store index'.
                STA     XAML-1,X       ; And to 'XAM index'.
                DEX                    ; Next of 2 bytes.
                BNE     SETADR         ; Loop unless X = 0.

NXTPRNT:
                BNE     PRDATA         ; NE means no address to print.
                LDA     #$0D           ; CR.
                JSR     ECHO           ; Output it.
                LDA     XAMH           ; 'Examine index' high-order byte.
                JSR     PRBYTE         ; Output it in hex format.
                LDA     XAML           ; Low-order 'examine index' byte.
                JSR     PRBYTE         ; Output it in hex format.
                LDA     #$3A           ; ":".
                JSR     ECHO           ; Output it.

PRDATA:
                LDA     #$20           ; Blank.
                JSR     ECHO           ; Output it.
                LDA     (XAML,X)       ; Get data byte at 'examine index'.
                JSR     PRBYTE         ; Output it in hex format.
XAMNEXT:        STX     MODE           ; 0 -> MODE (XAM mode).
                LDA     XAML
                CMP     L              ; Compare 'examine index' to hex data.
                LDA     XAMH
                SBC     H
                BCS     TONEXTITEM     ; Not less, so no more data to output.
  
                INC     XAML
                BNE     MOD8CHK        ; Increment 'examine index'.
                INC     XAMH

MOD8CHK:
                LDA     XAML           ; Check low-order 'examine index' byte
                AND     #$07           ; For MOD 8 = 0
                BPL     NXTPRNT        ; Always taken.

PRBYTE:
                PHA                    ; Save A for LSD.
                LSR
                LSR
                LSR                    ; MSD to LSD position.
                LSR
                JSR     PRHEX          ; Output hex digit.
                PLA                    ; Restore A.

PRHEX:
                AND     #$0F           ; Mask LSD for hex print.
                ORA     #$30           ; Add "0".
                CMP     #$3A           ; Digit?
                BCC     ECHO           ; Yes, output it.
                ADC     #$06           ; Add offset for letter.

ECHO:
                PHA                    ; Save A.
                STA     ACIA_DATA      ; Output character.
                LDX     #$FF           ; Initialize delay loop.
TXDELAY:        DEX                    ; Decrement X.
                BNE     TXDELAY        ; Until X gets to 0.
                PLA                    ; Restore A.
                RTS                    ; Return.

; CPU Vector Locations
  .org NMIB_VEC
  .word $0000       ; Non-Maskable Interrupt routine location
  .org RESB_VEC
  .word EEPROM      ; Program counter initial location
  .org IRQB_VEC
  .word EEPROM_IRQ  ; Interrupt Request routine location
