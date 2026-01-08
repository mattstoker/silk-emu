//
//  CPU6502+LogicalInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

import Testing
@testable import SilkCPU

// MARK: - Logical Instruction Tests

@Suite("6502 CPU Logical Instruction Tests")
struct CPU6502LogicalInstructionTests {
    func expectedStatus(_ result: UInt8) -> UInt8 {
        let negative = result & 0x80 != 0
        let zero = result == 0
        var status = UInt8.min
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        return status
    }
    
    @Test func executeANDImmediate() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for immediateOperand in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let expectedResult = registerOperand & immediateOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeAND(immediate: immediateOperand)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeANDZeropage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedResult = registerOperand & memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeAND(zeropage: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeANDZeropageX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x8E)
                let memoryOperand = s.cpu.load(zeropageX: address)
                let expectedResult = registerOperand & memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeAND(zeropageX: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x8E, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeANDAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in MemoryTestAddresses {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(absolute: address)
                let expectedResult = registerOperand & memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeAND(absolute: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeANDAbsoluteX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in MemoryTestAddresses {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x2A)
                let memoryOperand = s.cpu.load(absoluteX: address)
                let expectedResult = registerOperand & memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeAND(absoluteX: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeANDAbsoluteY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in MemoryTestAddresses {
                s.cpu = CPU6502(ac: registerOperand, yr: 0x2A)
                let memoryOperand = s.cpu.load(absoluteY: address)
                let expectedResult = registerOperand & memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeAND(absoluteY: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, yr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeANDIndirectX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x2A)
                let memoryOperand = s.cpu.load(preIndirectX: address)
                let expectedResult = registerOperand & memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeAND(preIndirectX: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeANDIndirectY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, yr: 0x2A)
                let memoryOperand = s.cpu.load(postIndirectY: address)
                let expectedResult = registerOperand & memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeAND(postIndirectY: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, yr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeANDZeropageIndirect() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropageIndirect: address)
                let expectedResult = registerOperand & memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeAND(zeropageIndirect: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }

    @Test func executeORAImmediate() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for immediateOperand in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let expectedResult = registerOperand | immediateOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeORA(immediate: immediateOperand)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeORAZeropage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeORA(zeropage: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeORAZeropageX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x8E)
                let memoryOperand = s.cpu.load(zeropageX: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeORA(zeropageX: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x8E, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeORAAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in MemoryTestAddresses {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(absolute: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeORA(absolute: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeORAAbsoluteX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in MemoryTestAddresses {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x2A)
                let memoryOperand = s.cpu.load(absoluteX: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeORA(absoluteX: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeORAAbsoluteY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in MemoryTestAddresses {
                s.cpu = CPU6502(ac: registerOperand, yr: 0x2A)
                let memoryOperand = s.cpu.load(absoluteY: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeORA(absoluteY: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, yr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeORAIndirectX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x2A)
                let memoryOperand = s.cpu.load(preIndirectX: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeORA(preIndirectX: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeORAIndirectY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, yr: 0x2A)
                let memoryOperand = s.cpu.load(postIndirectY: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeORA(postIndirectY: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, yr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeORAZeropageIndirect() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropageIndirect: address)
                let expectedResult = registerOperand | memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeORA(zeropageIndirect: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeEORImmediate() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for immediateOperand in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let expectedResult = registerOperand ^ immediateOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeEOR(immediate: immediateOperand)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeEORZeropage() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropage: address)
                let expectedResult = registerOperand ^ memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeEOR(zeropage: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeEORZeropageX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x8E)
                let memoryOperand = s.cpu.load(zeropageX: address)
                let expectedResult = registerOperand ^ memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeEOR(zeropageX: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x8E, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeEORAbsolute() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in MemoryTestAddresses {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(absolute: address)
                let expectedResult = registerOperand ^ memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeEOR(absolute: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeEORAbsoluteX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in MemoryTestAddresses {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x2A)
                let memoryOperand = s.cpu.load(absoluteX: address)
                let expectedResult = registerOperand ^ memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeEOR(absoluteX: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeEORAbsoluteY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in MemoryTestAddresses {
                s.cpu = CPU6502(ac: registerOperand, yr: 0x2A)
                let memoryOperand = s.cpu.load(absoluteY: address)
                let expectedResult = registerOperand ^ memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeEOR(absoluteY: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, yr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeEORIndirectX() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, xr: 0x2A)
                let memoryOperand = s.cpu.load(preIndirectX: address)
                let expectedResult = registerOperand ^ memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeEOR(preIndirectX: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeEORIndirectY() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand, yr: 0x2A)
                let memoryOperand = s.cpu.load(postIndirectY: address)
                let expectedResult = registerOperand ^ memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeEOR(postIndirectY: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, yr: 0x2A, sr: expectedStatus))
            }
        }
    }
    
    @Test func executeEORZeropageIndirect() {
        let s = System(cpu: CPU6502())
        for registerOperand in UInt8.min...UInt8.max {
            for address in UInt8.min...UInt8.max {
                s.cpu = CPU6502(ac: registerOperand)
                let memoryOperand = s.cpu.load(zeropageIndirect: address)
                let expectedResult = registerOperand ^ memoryOperand
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeEOR(zeropageIndirect: address)
                #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
            }
        }
    }
}
