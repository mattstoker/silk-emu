//
//  CPU6502+InterruptInstructionTests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/31/25.
//

import Testing
@testable import SilkCPU

// MARK: - Interrupt Instruction Tests

@Suite("6502 CPU Interrupt Instruction Tests")
struct CPU6502InterruptInstructionTests {
    @Test func executeBRK() {
        let s = System(cpu: CPU6502(pc: 0xBEEF, sr: 0x00, sp: 0x3D))
        let expectedCounter = UInt16(0xBEEF) &+ 2
        let expectedStackPointer = UInt8(0x3D) &- 3
        let expectedStatus = 0x00 | CPU6502.srBMask
        s.cpu.executeBRK()
        #expect(s.cpu == CPU6502(pc: 0xBEEF, sp: expectedStackPointer))
        #expect(s.cpu.load(stackpage: 0x3D) == (expectedCounter & 0xFF00) >> 8)
        #expect(s.cpu.load(stackpage: 0x3D &- 1) == (expectedCounter & 0x00FF))
        #expect(s.cpu.load(stackpage: 0x3D &- 2) == expectedStatus)
    }

    @Test func executeRTI() {
        let s = System(cpu: CPU6502(pc: 0xBEEF, sr: 0x00, sp: 0x3D))
        s.cpu.store(stackpage: 0x3D &+ 2, 0xAD &+ 2)
        s.cpu.store(stackpage: 0x3D &+ 1, 0xDE)
        s.cpu.store(stackpage: 0x3D, 0x00 | CPU6502.srBMask)
        let expectedCounter = UInt16(0xDEAD) &+ 2
        let expectedStackPointer = UInt8(0x3D) &+ 3
        let expectedStatus = 0x00 | CPU6502.srBMask
        s.cpu.executeRTI()
        #expect(s.cpu == CPU6502(pc: expectedCounter, sr: expectedStatus, sp: expectedStackPointer))
    }
}
