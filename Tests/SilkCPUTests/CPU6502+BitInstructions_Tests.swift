//
//  CPU6502+BitInstructionTests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/31/25.
//

import Testing
@testable import SilkCPU

// MARK: - Bit Instruction Tests

@Suite("6502 CPU Bit Instruction Tests")
struct CPU6502BitInstructionTests {
    func expectedStatus(_ a: UInt8, _ result: UInt8) -> UInt8 {
        let zero = result == 0
        let signBitSet = a & 0b10000000 != 0
        let semsBitSet = a & 0b01000000 != 0
        var status = UInt8.min
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        status = signBitSet ? (status | 0b10000000) : (status & ~0b10000000)
        status = semsBitSet ? (status | 0b01000000) : (status & ~0b01000000)
        return status
    }
    
    @Test func executeBITAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(absolute: address)
                let expectedStatus = expectedStatus(registerOperand, registerOperand & memoryOperand)
                s.cpu.executeBIT(absolute: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
            }
        }
    }

    @Test func executeBITImmediate() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for immediateOperand in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let expectedStatus = expectedStatus(registerOperand, registerOperand & immediateOperand)
                s.cpu.executeBIT(immediate: immediateOperand)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
            }
        }
    }
    @Test func executeBITAbsoluteX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x38)
                let memoryOperand = s.cpu.load(absoluteX: address)
                let expectedStatus = expectedStatus(registerOperand, registerOperand & memoryOperand)
                s.cpu.executeBIT(absoluteX: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, xr: 0x38, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeBITZeropage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedStatus = expectedStatus(registerOperand, registerOperand & memoryOperand)
                s.cpu.executeBIT(zeropage: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeBITZeropageX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x38)
                let memoryOperand = s.cpu.load(zeropageX: address)
                let expectedStatus = expectedStatus(registerOperand, registerOperand & memoryOperand)
                s.cpu.executeBIT(zeropageX: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, xr: 0x38, sr: expectedStatus))
            }
        }
    }

    @Test func executeTRBAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(absolute: address)
                let expectedResult = ~registerOperand & memoryOperand
                let expectedStatus = registerOperand & memoryOperand == 0 ? CPU6502.srZMask : 0x00
                s.cpu.executeTRB(absolute: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
                #expect(s.cpu.load(absolute: address) == expectedResult)
            }
        }
    }
    
    @Test func executeTRBZeropage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedResult = ~registerOperand & memoryOperand
                let expectedStatus = registerOperand & memoryOperand == 0 ? CPU6502.srZMask : 0x00
                s.cpu.executeTRB(zeropage: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
                #expect(s.cpu.load(zeropage: address) == expectedResult)
            }
        }
    }

    @Test func executeTSBAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(absolute: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = registerOperand & memoryOperand == 0 ? CPU6502.srZMask : 0x00
                s.cpu.executeTSB(absolute: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
                #expect(s.cpu.load(absolute: address) == expectedResult)
            }
        }
    }
    
    @Test func executeTSBZeropage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = registerOperand & memoryOperand == 0 ? CPU6502.srZMask : 0x00
                s.cpu.executeTSB(zeropage: address)
                #expect(s.cpu == CPU6502(ac: registerOperand, sr: expectedStatus))
                #expect(s.cpu.load(zeropage: address) == expectedResult)
            }
        }
    }

    func testExecuteRMBZeropage(_ bit: Int) {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedResult = memoryOperand & ~(1 << bit)
                switch bit {
                case 0: s.cpu.executeRMB0(zeropage: address)
                case 1: s.cpu.executeRMB1(zeropage: address)
                case 2: s.cpu.executeRMB2(zeropage: address)
                case 3: s.cpu.executeRMB3(zeropage: address)
                case 4: s.cpu.executeRMB4(zeropage: address)
                case 5: s.cpu.executeRMB5(zeropage: address)
                case 6: s.cpu.executeRMB6(zeropage: address)
                case 7: s.cpu.executeRMB7(zeropage: address)
                default: ()
                }
                #expect(s.cpu == CPU6502(ac: registerOperand))
                #expect(s.cpu.load(zeropage: address) == expectedResult)
            }
        }
    }
    
    @Test func executeRMB0Zeropage() {
        testExecuteRMBZeropage(0)
    }
    
    @Test func executeRMB1Zeropage() {
        testExecuteRMBZeropage(1)
    }
    
    @Test func executeRMB2Zeropage() {
        testExecuteRMBZeropage(2)
    }
    
    @Test func executeRMB3Zeropage() {
        testExecuteRMBZeropage(3)
    }
    
    @Test func executeRMB4Zeropage() {
        testExecuteRMBZeropage(4)
    }
    
    @Test func executeRMB5Zeropage() {
        testExecuteRMBZeropage(5)
    }
    
    @Test func executeRMB6Zeropage() {
        testExecuteRMBZeropage(6)
    }
    
    @Test func executeRMB7Zeropage() {
        testExecuteRMBZeropage(7)
    }

    func testExecuteSMBZeropage(_ bit: Int) {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedResult = memoryOperand | (1 << bit)
                switch bit {
                case 0: s.cpu.executeSMB0(zeropage: address)
                case 1: s.cpu.executeSMB1(zeropage: address)
                case 2: s.cpu.executeSMB2(zeropage: address)
                case 3: s.cpu.executeSMB3(zeropage: address)
                case 4: s.cpu.executeSMB4(zeropage: address)
                case 5: s.cpu.executeSMB5(zeropage: address)
                case 6: s.cpu.executeSMB6(zeropage: address)
                case 7: s.cpu.executeSMB7(zeropage: address)
                default: ()
                }
                #expect(s.cpu == CPU6502(ac: registerOperand))
                #expect(s.cpu.load(zeropage: address) == expectedResult)
            }
        }
    }
    
    @Test func executeSMB0Zeropage() {
        testExecuteSMBZeropage(0)
    }
    
    @Test func executeSMB1Zeropage() {
        testExecuteSMBZeropage(1)
    }
    
    @Test func executeSMB2Zeropage() {
        testExecuteSMBZeropage(2)
    }
    
    @Test func executeSMB3Zeropage() {
        testExecuteSMBZeropage(3)
    }
    
    @Test func executeSMB4Zeropage() {
        testExecuteSMBZeropage(4)
    }
    
    @Test func executeSMB5Zeropage() {
        testExecuteSMBZeropage(5)
    }
    
    @Test func executeSMB6Zeropage() {
        testExecuteSMBZeropage(6)
    }
    
    @Test func executeSMB7Zeropage() {
        testExecuteSMBZeropage(7)
    }
}
