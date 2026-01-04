//
//  CPU6502+CPU6502+JumpInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/31/25.
//

import Testing
@testable import SilkCPU

// MARK: - Jump Instruction Tests

@Suite("6502 CPU Jump Instruction Tests")
struct CPU6502JumpInstructionTests {
    @Test func executeJMPAbsolute() {
        let s = System(cpu: CPU6502())
        for counterOperand in MemoryTestAddresses {
            for immediateOperand in MemoryTestAddresses {
                s.cpu = CPU6502(pc: counterOperand)
                let expectedCounter = immediateOperand
                s.cpu.executeJMP(absolute: immediateOperand)
                #expect(s.cpu == CPU6502(pc: expectedCounter))
            }
        }
    }
    
    @Test func executeJMPIndirect() {
        let s = System(cpu: CPU6502())
        for counterOperand in MemoryTestAddresses {
            for immediateOperand in MemoryTestAddresses {
                s.cpu = CPU6502(pc: counterOperand)
                let expectedCounter = s.cpu.address(indirect: immediateOperand)
                s.cpu.executeJMP(indirect: immediateOperand)
                #expect(s.cpu == CPU6502(pc: expectedCounter))
            }
        }
    }
    
    @Test func executeJMPAbsoluteXIndirect() {
        let s = System(cpu: CPU6502())
        for counterOperand in MemoryTestAddresses {
            for immediateOperand in MemoryTestAddresses {
                s.cpu = CPU6502(pc: counterOperand, xr: 0x9B)
                let expectedCounter = UInt16(0xDEAD)
                s.cpu.store(s.cpu.address(absoluteX: immediateOperand), UInt8(expectedCounter & 0x00FF))
                s.cpu.store(s.cpu.address(absoluteX: immediateOperand) &+ 1, UInt8((expectedCounter & 0xFF00) >> 8))
                s.cpu.executeJMP(absoluteXIndirect: immediateOperand)
                #expect(s.cpu == CPU6502(pc: expectedCounter, xr: 0x9B))
            }
        }
    }

    @Test func executeJSRAbsolute() {
        let s = System(cpu: CPU6502())
        for counterOperand in MemoryTestAddresses {
            for immediateOperand in MemoryTestAddresses {
                s.cpu = CPU6502(pc: counterOperand, xr: 0x9B, sp: 0x3D)
                let expectedCounter = s.cpu.address(absolute: immediateOperand)
                let expectedStackPointer = UInt8(0x3D) &- 2
                s.cpu.executeJSR(absolute: immediateOperand)
                #expect(s.cpu == CPU6502(pc: expectedCounter, xr: 0x9B, sp: expectedStackPointer))
            }
        }
    }

    @Test func executeRTS() {
        let s = System(cpu: CPU6502())
        for previousJumpAddress in MemoryTestAddresses {
            s.cpu = CPU6502(pc: 0xBEEF, xr: 0x9B, sp: 0x3D)
            s.cpu.store(stackpage: 0x3D &+ 2, UInt8(previousJumpAddress & 0x00FF))
            s.cpu.store(stackpage: 0x3D &+ 1, UInt8((previousJumpAddress & 0xFF00) >> 8))
            let expectedCounter = previousJumpAddress
            let expectedStackPointer = UInt8(0x3D) &+ 2
            s.cpu.executeRTS()
            #expect(s.cpu == CPU6502(pc: expectedCounter, xr: 0x9B, sp: expectedStackPointer))
        }
    }
}
