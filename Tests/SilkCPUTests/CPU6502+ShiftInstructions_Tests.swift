//
//  CPU6502+ShiftInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

import Testing
@testable import SilkCPU

// MARK: - Shift Instruction Tests

@Suite("6502 CPU Shift Instruction Tests")
struct CPU6502ShiftInstructionTests {
    func expectedStatus(_ a: UInt8, _ left: Bool, _ result: UInt8) -> UInt8 {
        let negative = result & 0x80 != 0
        let zero = result == 0
        let carry = left ? a & 0x80 != 0 : a & 0x01 != 0
        var status = UInt8.min
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        status = carry ? (status | CPU6502.srCMask) : (status & ~CPU6502.srCMask)
        return status
    }
    
    @Test func executeASL() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            s.cpu = CPU6502(ac: registerOperand)
            let expectedResult = registerOperand << 1
            let expectedStatus = expectedStatus(registerOperand, true, expectedResult)
            s.cpu.executeASL()
            #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
        }
    }
    
    @Test func executeASLZeropage() {
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            s.cpu = CPU6502()
            let memoryOperand = s.cpu.load(zeropage: address)
            let expectedResult = memoryOperand << 1
            let expectedStatus = expectedStatus(memoryOperand, true, expectedResult)
            s.cpu.executeASL(zeropage: address)
            #expect(s.cpu.load(zeropage: address) == expectedResult)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
        }
    }
    
    @Test func executeASLZeropageX() {
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            s.cpu = CPU6502(xr: 0x3B)
            let memoryOperand = s.cpu.load(zeropageX: address)
            let expectedResult = memoryOperand << 1
            let expectedStatus = expectedStatus(memoryOperand, true, expectedResult)
            s.cpu.executeASL(zeropageX: address)
            #expect(s.cpu.load(zeropageX: address) == expectedResult)
            #expect(s.cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
        }
    }
    
    @Test func executeASLAbsolute() {
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) {
            s.cpu = CPU6502()
            let memoryOperand = s.cpu.load(absolute: address)
            let expectedResult = memoryOperand << 1
            let expectedStatus = expectedStatus(memoryOperand, true, expectedResult)
            s.cpu.executeASL(absolute: address)
            #expect(s.cpu.load(absolute: address) == expectedResult)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
        }
    }
    
    @Test func executeASLAbsoluteX() {
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) {
            s.cpu = CPU6502(xr: 0x3B)
            let memoryOperand = s.cpu.load(absoluteX: address)
            let expectedResult = memoryOperand << 1
            let expectedStatus = expectedStatus(memoryOperand, true, expectedResult)
            s.cpu.executeASL(absoluteX: address)
            #expect(s.cpu.load(absoluteX: address) == expectedResult)
            #expect(s.cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
        }
    }
    
    @Test func executeLSR() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            s.cpu = CPU6502(ac: registerOperand)
            let expectedResult = registerOperand >> 1
            let expectedStatus = expectedStatus(registerOperand, false, expectedResult)
            let s = System(cpu: CPU6502(ac: registerOperand))
            s.cpu.executeLSR()
            #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
        }
    }
    
    @Test func executeLSRZeropage() {
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            s.cpu = CPU6502()
            let memoryOperand = s.cpu.load(zeropage: address)
            let expectedResult = memoryOperand >> 1
            let expectedStatus = expectedStatus(memoryOperand, false, expectedResult)
            s.cpu.executeLSR(zeropage: address)
            #expect(s.cpu.load(zeropage: address) == expectedResult)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
        }
    }
    
    @Test func executeLSRZeropageX() {
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            s.cpu = CPU6502(xr: 0x3B)
            let memoryOperand = s.cpu.load(zeropageX: address)
            let expectedResult = memoryOperand >> 1
            let expectedStatus = expectedStatus(memoryOperand, false, expectedResult)
            s.cpu.executeLSR(zeropageX: address)
            #expect(s.cpu.load(zeropageX: address) == expectedResult)
            #expect(s.cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
        }
    }
    
    @Test func executeLSRAbsolute() {
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) {
            s.cpu = CPU6502()
            let memoryOperand = s.cpu.load(absolute: address)
            let expectedResult = memoryOperand >> 1
            let expectedStatus = expectedStatus(memoryOperand, false, expectedResult)
            s.cpu.executeLSR(absolute: address)
            #expect(s.cpu.load(absolute: address) == expectedResult)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
        }
    }
    
    @Test func executeLSRAbsoluteX() {
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) {
            s.cpu = CPU6502(xr: 0x3B)
            let memoryOperand = s.cpu.load(absoluteX: address)
            let expectedResult = memoryOperand >> 1
            let expectedStatus = expectedStatus(memoryOperand, false, expectedResult)
            s.cpu.executeLSR(absoluteX: address)
            #expect(s.cpu.load(absoluteX: address) == expectedResult)
            #expect(s.cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
        }
    }
    
    @Test func executeROL() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for carryOperand in [false, true] {
                s.cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
                let expectedResult = registerOperand << 1 | (carryOperand ? 0x01 : 0x00)
                let expectedStatus = expectedStatus(registerOperand, true, expectedResult)
                s.cpu.executeROL()
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeROLZeropage() {
        let carryOperand = Bool.random()
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            s.cpu = CPU6502(sr: carryOperand ? CPU6502.srCMask : 0x00)
            let memoryOperand = s.cpu.load(zeropage: address)
            let expectedResult = memoryOperand << 1 | (carryOperand ? 0x01 : 0x00)
            let expectedStatus = expectedStatus(memoryOperand, true, expectedResult)
            s.cpu.executeROL(zeropage: address)
            #expect(s.cpu.load(zeropage: address) == expectedResult)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
        }
    }
    
    @Test func executeROLZeropageX() {
        let carryOperand = Bool.random()
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            s.cpu = CPU6502(xr: 0x3B, sr: carryOperand ? CPU6502.srCMask : 0x00)
            let memoryOperand = s.cpu.load(zeropageX: address)
            let expectedResult = memoryOperand << 1 | (carryOperand ? 0x01 : 0x00)
            let expectedStatus = expectedStatus(memoryOperand, true, expectedResult)
            s.cpu.executeROL(zeropageX: address)
            #expect(s.cpu.load(zeropageX: address) == expectedResult)
            #expect(s.cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
        }
    }
    
    @Test func executeROLAbsolute() {
        let carryOperand = Bool.random()
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) {
            s.cpu = CPU6502(sr: carryOperand ? CPU6502.srCMask : 0x00)
            let memoryOperand = s.cpu.load(absolute: address)
            let expectedResult = memoryOperand << 1 | (carryOperand ? 0x01 : 0x00)
            let expectedStatus = expectedStatus(memoryOperand, true, expectedResult)
            s.cpu.executeROL(absolute: address)
            #expect(s.cpu.load(absolute: address) == expectedResult)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
        }
    }
    
    @Test func executeROLAbsoluteX() {
        let carryOperand = Bool.random()
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) {
            s.cpu = CPU6502(xr: 0x3B, sr: carryOperand ? CPU6502.srCMask : 0x00)
            let memoryOperand = s.cpu.load(absoluteX: address)
            let expectedResult = memoryOperand << 1 | (carryOperand ? 0x01 : 0x00)
            let expectedStatus = expectedStatus(memoryOperand, true, expectedResult)
            s.cpu.executeROL(absoluteX: address)
            #expect(s.cpu.load(absoluteX: address) == expectedResult)
            #expect(s.cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
        }
    }
    
    @Test func executeROR() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for carryOperand in [false, true] {
                s.cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
                let expectedResult = registerOperand >> 1 | (carryOperand ? 0x80 : 0x00)
                let expectedStatus = expectedStatus(registerOperand, false, expectedResult)
                s.cpu.executeROR()
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeRORZeropage() {
        let carryOperand = Bool.random()
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            s.cpu = CPU6502(sr: carryOperand ? CPU6502.srCMask : 0x00)
            let memoryOperand = s.cpu.load(zeropage: address)
            let expectedResult = memoryOperand >> 1 | (carryOperand ? 0x80 : 0x00)
            let expectedStatus = expectedStatus(memoryOperand, false, expectedResult)
            s.cpu.executeROR(zeropage: address)
            #expect(s.cpu.load(zeropage: address) == expectedResult)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
        }
    }
    
    @Test func executeRORZeropageX() {
        let carryOperand = Bool.random()
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            s.cpu = CPU6502(xr: 0x3B, sr: carryOperand ? CPU6502.srCMask : 0x00)
            let memoryOperand = s.cpu.load(zeropageX: address)
            let expectedResult = memoryOperand >> 1 | (carryOperand ? 0x80 : 0x00)
            let expectedStatus = expectedStatus(memoryOperand, false, expectedResult)
            s.cpu.executeROR(zeropageX: address)
            #expect(s.cpu.load(zeropageX: address) == expectedResult)
            #expect(s.cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
        }
    }
    
    @Test func executeRORAbsolute() {
        let carryOperand = Bool.random()
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) {
            s.cpu = CPU6502(sr: carryOperand ? CPU6502.srCMask : 0x00)
            let memoryOperand = s.cpu.load(absolute: address)
            let expectedResult = memoryOperand >> 1 | (carryOperand ? 0x80 : 0x00)
            let expectedStatus = expectedStatus(memoryOperand, false, expectedResult)
            s.cpu.executeROR(absolute: address)
            #expect(s.cpu.load(absolute: address) == expectedResult)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
        }
    }
    
    @Test func executeRORAbsoluteX() {
        let carryOperand = Bool.random()
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) {
            s.cpu = CPU6502(xr: 0x3B, sr: carryOperand ? CPU6502.srCMask : 0x00)
            let memoryOperand = s.cpu.load(absoluteX: address)
            let expectedResult = memoryOperand >> 1 | (carryOperand ? 0x80 : 0x00)
            let expectedStatus = expectedStatus(memoryOperand, false, expectedResult)
            s.cpu.executeROR(absoluteX: address)
            #expect(s.cpu.load(absoluteX: address) == expectedResult)
            #expect(s.cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
        }
    }
}
