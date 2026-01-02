//
//  CPU6502+InterruptInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/31/25.
//

// MARK: - Interrupt Instructions

//  BRK
//  Force Break
//
//  BRK initiates a software interrupt similar to a hardware
//  interrupt (IRQ). The return address pushed to the stack is
//  PC+2, providing an extra byte of spacing for a break mark
//  (identifying a reason for the break.)
//  The status register will be pushed to the stack with the break
//  flag set to 1. However, when retrieved during RTI or by a PLP
//  instruction, the break flag will be ignored.
//  The interrupt disable flag is not set automatically.
//
//  interrupt,
//  push PC+2, push SR
//  N    Z    C    I    D    V
//  -    -    -    1    -    -
//  addressing    assembler    opc    bytes    cycles
//  implied       BRK          00     1        7
extension CPU6502 {
    mutating func executeBRK() {
        let pcNext = pc &+ 2
        pushWide(pcNext)
        push(sr | CPU6502.srBMask)
    }
}

// RTI
// Return from Interrupt
//
// The status register is pulled with the break flag
// and bit 5 ignored. Then PC is pulled from the stack.
//
// pull SR, pull PC
// N    Z    C    I    D    V
// from stack
// addressing    assembler    opc    bytes    cycles
// implied       RTI          40     1        6
extension CPU6502 {
    mutating func executeRTI() {
        let status = pull()
        sr = (status & ~CPU6502.srBMask) | (status & ~CPU6502.srXMask)
        pc = pullWide()
    }
}

// WAI
// Wait for Interrupt
//
// Stops and pulls the signal on pin RDY to low.
// The processor goes into a low-power mode,
// similar to STP, until an IRQ or NMI signal is
// encountered to "wake it up" again.
// 
// stop and wait for sIRQ/sNMI
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// implied       WAI          CB     1        3         *
extension CPU6502 {
    mutating func executeWAI() {
        state = .wait
    }
}

// STP
// Stop Mode
//
// Stops and sets the signal on pin PHI2 to high.
// A reset signal will "wake up" the processor quickly.
//
// stop the clock (sleep)
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// implied       STP          DB     1        3         *
extension CPU6502 {
    mutating func executeSTP() {
        state = .stop
    }
}
