//
//  CPU6502+ArithmeticInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/28/25.
//

import Testing
@testable import SilkCPU

// MARK: - Arithmetic Instruction Tests

@Suite("6502 CPU Arithmetic Instruction Tests")
struct CPU6502ArithmeticInstructionTests {
    func expectedStatus(_ a: UInt8, _ b: UInt8, _ c: Bool, _ result: UInt16) -> UInt8 {
        let sum = UInt16(a) + UInt16(b) + (c ? 1 : 0)
        let result = UInt8(sum & 0xFF)
        let negative = result & 0x80 != 0
        let zero = result == 0
        let carry = result != sum
        let overflow = (a & 0x80) != (b & 0x80) ? false : (result & 0x80) != (a & 0x80)
        var status = UInt8.min
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        status = carry ? (status | CPU6502.srCMask) : (status & ~CPU6502.srCMask)
        status = overflow ? (status | CPU6502.srVMask) : (status & ~CPU6502.srVMask)
        return status
    }
    func expectedStatus(_ a: Int8, _ b: Int8, _ c: Bool, _ result: Int16) -> UInt8 {
        let a = UInt8(bitPattern: a)
        let b = ~UInt8(bitPattern: b)
        return expectedStatus(a, b, !c, UInt16(bitPattern: result))
    }
    
    @Test func executeADCImmediate() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for immediateOperand in UInt8.min...UInt8.max {
                for carryOperand in [false, true] {
                    s.cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
                    let expectedResult = UInt16(registerOperand) + UInt16(immediateOperand) + UInt16(carryOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, immediateOperand, carryOperand, expectedResult)
                    s.cpu.executeADC(immediate: immediateOperand)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeADCZeroPage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                for carryOperand in [false, true] {
                    s.cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
                    let memoryOperand = s.cpu.load(zeropage: address)
                    let expectedResult = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, carryOperand, expectedResult)
                    s.cpu.executeADC(zeropage: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeADCZeroPageX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                for carryOperand in [false, true] {
                    s.cpu = CPU6502(ac: registerOperand, xr: 0x23, sr: carryOperand ? CPU6502.srCMask : 0x00)
                    let memoryOperand = s.cpu.load(zeropageX: address)
                    let expectedResult = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, carryOperand, expectedResult)
                    s.cpu.executeADC(zeropageX: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), xr: 0x23, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeADCAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for carryOperand in [false, true] {
                    s.cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
                    let memoryOperand = s.cpu.load(absolute: address)
                    let expectedResult = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, carryOperand, expectedResult)
                    s.cpu.executeADC(absolute: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeADCAbsoluteX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for carryOperand in [false, true] {
                    s.cpu = CPU6502(ac: registerOperand, xr: 0x63, sr: carryOperand ? CPU6502.srCMask : 0x00)
                    let memoryOperand = s.cpu.load(absoluteX: address)
                    let expectedResult = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, carryOperand, expectedResult)
                    s.cpu.executeADC(absoluteX: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), xr: 0x63, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeADCAbsoluteY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for carryOperand in [false, true] {
                    s.cpu = CPU6502(ac: registerOperand, yr: 0x74, sr: carryOperand ? CPU6502.srCMask : 0x00)
                    let memoryOperand = s.cpu.load(absoluteY: address)
                    let expectedResult = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, carryOperand, expectedResult)
                    s.cpu.executeADC(absoluteY: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), yr: 0x74, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeADCIndirectX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for carryOperand in [false, true] {
                    s.cpu = CPU6502(ac: registerOperand, xr: 0x63, sr: carryOperand ? CPU6502.srCMask : 0x00)
                    let memoryOperand = s.cpu.load(indirectX: address)
                    let expectedResult = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, carryOperand, expectedResult)
                    s.cpu.executeADC(indirectX: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), xr: 0x63, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeADCIndirectY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for carryOperand in [false, true] {
                    s.cpu = CPU6502(ac: registerOperand, yr: 0x74, sr: carryOperand ? CPU6502.srCMask : 0x00)
                    let memoryOperand = s.cpu.load(indirectY: address)
                    let expectedResult = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, carryOperand, expectedResult)
                    s.cpu.executeADC(indirectY: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), yr: 0x74, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeADCZeropageIndirect() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                for carryOperand in [false, true] {
                    s.cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
                    let memoryOperand = s.cpu.load(zeropageIndirect: address)
                    let expectedResult = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, carryOperand, expectedResult)
                    s.cpu.executeADC(zeropageIndirect: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeSBCImmediate() {
        let s = System(cpu: CPU6502())
        for registerOperand in Int8.min...Int8.max {
            for immediateOperand in Int8.min...Int8.max {
                for borrowOperand in [false, true] {
                    s.cpu = CPU6502(ac: UInt8(bitPattern: registerOperand), sr: borrowOperand ? 0x00 : CPU6502.srCMask)
                    let expectedResult = Int16(registerOperand) - Int16(immediateOperand) - Int16(borrowOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, immediateOperand, borrowOperand, expectedResult)
                    s.cpu.executeSBC(immediate: UInt8(bitPattern: immediateOperand))
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeSBCZeroPage() {
        let s = System(cpu: CPU6502())
        for registerOperand in Int8.min...Int8.max {
            for address in UInt8.min...UInt8.max {
                for borrowOperand in [false, true] {
                    s.cpu = CPU6502(ac: UInt8(bitPattern: registerOperand), sr: borrowOperand ? 0x00 : CPU6502.srCMask)
                    let memoryOperand = Int8(bitPattern: s.cpu.load(zeropage: address))
                    let expectedResult = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, borrowOperand, expectedResult)
                    s.cpu.executeSBC(zeropage: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeSBCZeroPageX() {
        let s = System(cpu: CPU6502())
        for registerOperand in Int8.min...Int8.max {
            for address in UInt8.min...UInt8.max {
                for borrowOperand in [false, true] {
                    s.cpu = CPU6502(ac: UInt8(bitPattern: registerOperand), xr: 0x23, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
                    let memoryOperand = Int8(bitPattern: s.cpu.load(zeropageX: address))
                    let expectedResult = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, borrowOperand, expectedResult)
                    s.cpu.executeSBC(zeropageX: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), xr: 0x23, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeSBCAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in Int8.min...Int8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for borrowOperand in [false, true] {
                    s.cpu = CPU6502(ac: UInt8(bitPattern: registerOperand), sr: borrowOperand ? 0x00 : CPU6502.srCMask)
                    let memoryOperand = Int8(bitPattern: s.cpu.load(absolute: address))
                    let expectedResult = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, borrowOperand, expectedResult)
                    s.cpu.executeSBC(absolute: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeSBCAbsoluteX() {
        let s = System(cpu: CPU6502())
        for registerOperand in Int8.min...Int8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for borrowOperand in [false, true] {
                    s.cpu = CPU6502(ac: UInt8(bitPattern: registerOperand), xr: 0x63, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
                    let memoryOperand = Int8(bitPattern: s.cpu.load(absoluteX: address))
                    let expectedResult = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, borrowOperand, expectedResult)
                    s.cpu.executeSBC(absoluteX: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), xr: 0x63, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeSBCAbsoluteY() {
        let s = System(cpu: CPU6502())
        for registerOperand in Int8.min...Int8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for borrowOperand in [false, true] {
                    s.cpu = CPU6502(ac: UInt8(bitPattern: registerOperand), yr: 0x74, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
                    let memoryOperand = Int8(bitPattern: s.cpu.load(absoluteY: address))
                    let expectedResult = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, borrowOperand, expectedResult)
                    s.cpu.executeSBC(absoluteY: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), yr: 0x74, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeSBCIndirectX() {
        let s = System(cpu: CPU6502())
        for registerOperand in Int8.min...Int8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for borrowOperand in [false, true] {
                    s.cpu = CPU6502(ac: UInt8(bitPattern: registerOperand), xr: 0x63, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
                    let memoryOperand = Int8(bitPattern: s.cpu.load(indirectX: address))
                    let expectedResult = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, borrowOperand, expectedResult)
                    s.cpu.executeSBC(indirectX: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), xr: 0x63, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeSBCIndirectY() {
        let s = System(cpu: CPU6502())
        for registerOperand in Int8.min...Int8.max {
            for address in UInt16.min...UInt16(0x0123) {
                for borrowOperand in [false, true] {
                    s.cpu = CPU6502(ac: UInt8(bitPattern: registerOperand), yr: 0x74, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
                    let memoryOperand = Int8(bitPattern: s.cpu.load(indirectY: address))
                    let expectedResult = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, borrowOperand, expectedResult)
                    s.cpu.executeSBC(indirectY: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), yr: 0x74, sr: expectedStatus))
                }
            }
        }
    }
    
    @Test func executeSBCZeropageIndirect() {
        let s = System(cpu: CPU6502())
        for registerOperand in Int8.min...Int8.max {
            for address in UInt8.min...UInt8.max {
                for borrowOperand in [false, true] {
                    s.cpu = CPU6502(ac: UInt8(bitPattern: registerOperand), sr: borrowOperand ? 0x00 : CPU6502.srCMask)
                    let memoryOperand = Int8(bitPattern: s.cpu.load(zeropageIndirect: address))
                    let expectedResult = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
                    let expectedStatus = expectedStatus(registerOperand, memoryOperand, borrowOperand, expectedResult)
                    s.cpu.executeSBC(zeropageIndirect: address)
                    #expect(s.cpu == CPU6502(ac: UInt8(expectedResult & 0xFF), sr: expectedStatus))
                }
            }
        }
    }
}
