//
//  CPU6502+CountingInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/28/25.
//

import Testing
@testable import SilkCPU

// MARK: - Counting Instruction Tests

@Suite("6502 CPU Counting Instruction Tests")
struct CPU6502CountingInstructionTests {
    func expectedStatus(_ result: UInt8) -> UInt8 {
        let negative = result & 0x80 != 0
        let zero = result == 0
        var status = UInt8.min
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        return status
    }
    
    @Test func executeINCZeropage() {
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            let memoryOperand = s.cpu.load(zeropage: address)
            let expectedResult = memoryOperand &+ 1
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeINC(zeropage: address)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
            #expect(s.cpu.load(zeropage: address) == expectedResult)
        }
    }
    
    @Test func executeINCZeropageX() {
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            for xr in UInt8.min...UInt8.max {
                s.cpu = CPU6502(xr: xr)
                let memoryOperand = s.cpu.load(zeropageX: address)
                let expectedResult = memoryOperand &+ 1
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeINC(zeropageX: address)
                #expect(s.cpu == CPU6502(xr: xr, sr: expectedStatus))
                #expect(s.cpu.load(zeropageX: address) == expectedResult)
            }
        }
    }
    
    @Test func executeINCAbsolute() {
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16.max {
            s.cpu = CPU6502()
            let memoryOperand = s.cpu.load(absolute: address)
            let expectedResult = memoryOperand &+ 1
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeINC(absolute: address)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
            #expect(s.cpu.load(absolute: address) == expectedResult)
        }
    }
    
    @Test func executeINCAbsoluteX() {
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) { //UInt16.min...UInt16.max {
            for xr in UInt8.min...UInt8.max {
                s.cpu = CPU6502(xr: xr)
                let memoryOperand = s.cpu.load(absoluteX: address)
                let expectedResult = memoryOperand &+ 1
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeINC(absoluteX: address)
                #expect(s.cpu == CPU6502(xr: xr, sr: expectedStatus))
                #expect(s.cpu.load(absoluteX: address) == expectedResult)
            }
        }
    }

    @Test func executeINC() {
        let s = System(cpu: CPU6502())
        for ac in UInt8.min...UInt8.max {
            s.cpu = CPU6502(ac: ac)
            let registerOperand = ac
            let expectedResult = registerOperand &+ 1
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeINC()
            #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
        }
    }

    @Test func executeINX() {
        let s = System(cpu: CPU6502())
        for xr in UInt8.min...UInt8.max {
            s.cpu = CPU6502(xr: xr)
            let registerOperand = xr
            let expectedResult = registerOperand &+ 1
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeINX()
            #expect(s.cpu == CPU6502(xr: expectedResult, sr: expectedStatus))
        }
    }

    @Test func executeINY() {
        let s = System(cpu: CPU6502())
        for yr in UInt8.min...UInt8.max {
            s.cpu = CPU6502(yr: yr)
            let registerOperand = yr
            let expectedResult = registerOperand &+ 1
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeINY()
            #expect(s.cpu == CPU6502(yr: expectedResult, sr: expectedStatus))
        }
    }
    
    @Test func executeDECZeropage() {
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            s.cpu = CPU6502()
            let memoryOperand = Int8(bitPattern: s.cpu.load(zeropage: address))
            let expectedResult = UInt8((Int16(memoryOperand) - 1) & 0xFF)
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeDEC(zeropage: address)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
            #expect(s.cpu.load(zeropage: address) == expectedResult)
        }
    }
    
    @Test func executeDECZeropageX() {
        let s = System(cpu: CPU6502())
        for address in UInt8.min...UInt8.max {
            for xr in UInt8.min...UInt8.max {
                s.cpu.xr = xr
                let memoryOperand = Int8(bitPattern: s.cpu.load(zeropageX: address))
                let expectedResult = UInt8((Int16(memoryOperand) - 1) & 0xFF)
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeDEC(zeropageX: address)
                #expect(s.cpu == CPU6502(xr: xr, sr: expectedStatus))
                #expect(s.cpu.load(zeropageX: address) == expectedResult)
            }
        }
    }
    
    @Test func executeDECAbsolute() {
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16.max {
            s.cpu = CPU6502()
            let memoryOperand = Int8(bitPattern: s.cpu.load(absolute: address))
            let expectedResult = UInt8((Int16(memoryOperand) - 1) & 0xFF)
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeDEC(absolute: address)
            #expect(s.cpu == CPU6502(sr: expectedStatus))
            #expect(s.cpu.load(absolute: address) == expectedResult)
        }
    }
    
    @Test func executeDECAbsoluteX() {
        let s = System(cpu: CPU6502())
        for address in UInt16.min...UInt16(0x0123) { //UInt16.min...UInt16.max {
            for xr in UInt8.min...UInt8.max {
                s.cpu = CPU6502(xr: xr)
                let memoryOperand = Int8(bitPattern: s.cpu.load(absoluteX: address))
                let expectedResult = UInt8((Int16(memoryOperand) - 1) & 0xFF)
                let expectedStatus = expectedStatus(expectedResult)
                s.cpu.executeDEC(absoluteX: address)
                #expect(s.cpu == CPU6502(xr: xr, sr: expectedStatus))
                #expect(s.cpu.load(absoluteX: address) == expectedResult)
            }
        }
    }

    @Test func executeDEC() {
        let s = System(cpu: CPU6502())
        for ac in UInt8.min...UInt8.max {
            s.cpu = CPU6502(ac: ac)
            let registerOperand = ac
            let expectedResult = UInt8((Int16(registerOperand) - 1) & 0xFF)
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeDEC()
            #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
        }
    }

    @Test func executeDEX() {
        let s = System(cpu: CPU6502())
        for xr in UInt8.min...UInt8.max {
            s.cpu = CPU6502(xr: xr)
            let registerOperand = xr
            let expectedResult = UInt8((Int16(registerOperand) - 1) & 0xFF)
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeDEX()
            #expect(s.cpu == CPU6502(xr: expectedResult, sr: expectedStatus))
        }
    }

    @Test func executeDEY() {
        let s = System(cpu: CPU6502())
        for yr in UInt8.min...UInt8.max {
            s.cpu = CPU6502(yr: yr)
            let registerOperand = yr
            let expectedResult = UInt8((Int16(registerOperand) - 1) & 0xFF)
            let expectedStatus = expectedStatus(expectedResult)
            s.cpu.executeDEY()
            #expect(s.cpu == CPU6502(yr: expectedResult, sr: expectedStatus))
        }
    }
}
