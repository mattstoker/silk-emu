; CGOL
; Conway's Game of Life Simulation on 6502
;
; Assemble using a W65C02 compatible assembler (such as vasm):
; ./vasm6502_oldstyle -Fbin -dotdir cgol.s && hexdump -v -e '16/1 "0x%02x, "' -e '"\n"' a.out
;
; This assembly program configured Jamanta OS to run Conway's Game of Life with VGA display.
;

; Device Hardware Address Map
ZERO_PAGE     = $0000 ; to $00ff - CPU Zero Page
STACK         = $0100 ; to $01ff - CPU Stack Memory
RAM           = $0200 ; to $1fff - General Purpose Memory
VIDEO         = $2000 ; to $3fff - VGA Memory
;               $4000   to $dfff - Unmapped
EEPROM        = $e000 ; to $feff - Program Memory (read-only)
NMIB_VEC      = $fffa ; to $fffb - CPU Non-Maskable Interrupt Vector
RESB_VEC      = $fffc ; to $fffd - CPU Reset Vector (holds initial value of program counter)
IRQB_VEC      = $fffe ; to $ffff - CPU Interrupt Request Vector

; VGA Dimensions
VIDEO_WIDTH = 100
VIDEO_HEIGHT = 64

; RAM Allocation
null                 = $0000 ; 2 bytes
scratch              = $0002 ; 2 bytes
scratch1             = $0004 ; 2 bytes
scratch2             = $0006 ; 2 bytes
scratch3             = $0008 ; 2 bytes
scratch4             = $000a ; 2 bytes
scratch5             = $000c ; 2 bytes
scratch6             = $000e ; 2 bytes
cgol_simulating      = $0017 ; 1 byte
cgol_generations     = $0018 ; 2 bytes
cgol_generation_reset= $001a ; 2 bytes
cgol_dead_cell_color = $001c ; 1 byte
cgol_live_cell_color = $001d ; 1 byte
stack                = $0100 ; 256 bytes
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

  ; Clear video memory
  lda #%00000000
  jsr vga_clear

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

  ; Enter main loop
  jmp loop

; Main Program Loop
loop:

  ; Advance simulation
  jsr cgol_advance_simulation

  ; Check if simulation should be reset
  lda cgol_generations
  cmp cgol_generation_reset
  bne loop_continue
  lda cgol_generations + 1
  cmp cgol_generation_reset + 1
  bne loop_continue
  jmp cgol_reset_to_acorn

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

; CPU Vector Locations
  .org NMIB_VEC
  .word $0000       ; Non-Maskable Interrupt routine location
  .org RESB_VEC
  .word EEPROM      ; Program counter initial location
  .org IRQB_VEC
  .word $0000       ; Interrupt Request routine location
