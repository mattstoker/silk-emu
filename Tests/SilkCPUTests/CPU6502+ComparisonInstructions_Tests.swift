//
//  CPU6502+ComparisonInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

import Testing
@testable import SilkCPU

// MARK: - Comparision Instruction Tests

@Suite("6502 CPU Counting Instruction Tests")
struct CPU6502ComparisionInstructionTests {
    func expectedStatus(_ a: UInt8, _ b: UInt8) -> UInt8 {
        let b = ~b
        let sum = UInt16(a) + UInt16(b) + 1
        let result = UInt8(sum & 0xFF)
        let negative = result & 0x80 != 0
        let zero = result == 0
        let carry = result != sum
        var status = UInt8.min
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        status = carry ? (status | CPU6502.srCMask) : (status & ~CPU6502.srCMask)
        return status
    }
    
    @Test func executeCMPImmediate() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for immediateOperand in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let expectedStatus = expectedStatus(registerOperand, immediateOperand)
                s.cpu.executeCMP(immediate: immediateOperand)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCMPZeropage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCMP(zeropage: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCMPZeropageX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x74)
                let memoryOperand = s.cpu.load(zeropageX: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCMP(zeropageX: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, xr: 0x74, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCMPAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(absolute: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCMP(absolute: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCMPAbsoluteX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x74)
                let memoryOperand = s.cpu.load(absoluteX: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCMP(absoluteX: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, xr: 0x74, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCMPAbsoluteY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(ac: registerOperand, yr: 0x74)
                let memoryOperand = s.cpu.load(absoluteY: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCMP(absoluteY: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, yr: 0x74, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCMPIndirectX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x74)
                let memoryOperand = s.cpu.load(preIndirectX: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCMP(preIndirectX: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, xr: 0x74, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCMPIndirectY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(ac: registerOperand, yr: 0x74)
                let memoryOperand = s.cpu.load(postIndirectY: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCMP(postIndirectY: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, yr: 0x74, sr: expectedStatus))
            }
        }
    }

    @Test func executeCMPZeropageIndirect() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropageIndirect: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCMP(zeropageIndirect: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
            }
        }
    }

    @Test func executeCPXImmediate() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for immediateOperand in UInt8.min...UInt8.max {
                s.cpu = CPU6502(xr: registerOperand)
                let expectedStatus = expectedStatus(registerOperand, immediateOperand)
                s.cpu.executeCPX(immediate: immediateOperand)
                #expect(s.cpu == CPU6502(xr: registerOperand, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCPXZeropage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(xr: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCPX(zeropage: address)
                #expect(s.cpu == CPU6502(xr: registerOperand, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCPXAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(xr: registerOperand)
                let memoryOperand = s.cpu.load(absolute: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCPX(absolute: address)
                #expect(s.cpu == CPU6502(xr: registerOperand, sr: expectedStatus))
            }
        }
    }

    @Test func executeCPYImmediate() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for immediateOperand in UInt8.min...UInt8.max {
                s.cpu = CPU6502(yr: registerOperand)
                let expectedStatus = expectedStatus(registerOperand, immediateOperand)
                s.cpu.executeCPY(immediate: immediateOperand)
                #expect(s.cpu == CPU6502(yr: registerOperand, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCPYZeropage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(yr: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCPY(zeropage: address)
                #expect(s.cpu == CPU6502(yr: registerOperand, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeCPYAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(yr: registerOperand)
                let memoryOperand = s.cpu.load(absolute: address)
                let expectedStatus = expectedStatus(registerOperand, memoryOperand)
                s.cpu.executeCPY(absolute: address)
                #expect(s.cpu == CPU6502(yr: registerOperand, sr: expectedStatus))
            }
        }
    }
}
