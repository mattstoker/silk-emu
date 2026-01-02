//
//  CPU6502+BranchInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/31/25.
//

import Testing
@testable import SilkCPU

// MARK: - Branch Instruction Tests

@Suite("6502 CPU Branch Instruction Tests")
struct CPU6502BranchInstructionTests {
    func testExecuteBranch(_ execution: (System, UInt8) -> (), _ condition: (System) -> Bool) {
        let s = System(cpu: CPU6502())
        for counterOperand in UInt16.min...UInt16(0x0123) {
            for relativeOperand in UInt8.min...UInt8.max {
                s.cpu = CPU6502(pc: counterOperand)
                let expectedCounter = !condition(s) ?
                    counterOperand :
                    UInt16(truncatingIfNeeded: Int32(counterOperand) &+ Int32(Int8(bitPattern: relativeOperand)))
                execution(s, relativeOperand)
                #expect(s.cpu == CPU6502(pc: expectedCounter))
            }
        }
    }
    
    @Test func executeBNE() {
        testExecuteBranch({ s, oper in s.cpu.executeBNE(relative: oper)}, { s in s.cpu.sr & CPU6502.srZMask == 0 })
    }

    @Test func executeBEQ() {
        testExecuteBranch({ s, oper in s.cpu.executeBEQ(relative: oper)}, { s in s.cpu.sr & CPU6502.srZMask != 0 })
    }

    @Test func executeBCC() {
        testExecuteBranch({ s, oper in s.cpu.executeBCC(relative: oper)}, { s in s.cpu.sr & CPU6502.srCMask == 0 })
    }

    @Test func executeBCS() {
        testExecuteBranch({ s, oper in s.cpu.executeBCS(relative: oper)}, { s in s.cpu.sr & CPU6502.srCMask != 0 })
    }

    @Test func executeBPL() {
        testExecuteBranch({ s, oper in s.cpu.executeBPL(relative: oper)}, { s in s.cpu.sr & CPU6502.srNMask == 0 })
    }

    @Test func executeBMI() {
        testExecuteBranch({ s, oper in s.cpu.executeBMI(relative: oper)}, { s in s.cpu.sr & CPU6502.srNMask != 0 })
    }

    @Test func executeBVC() {
        testExecuteBranch({ s, oper in s.cpu.executeBVC(relative: oper)}, { s in s.cpu.sr & CPU6502.srVMask == 0 })
    }

    @Test func executeBVS() {
        testExecuteBranch({ s, oper in s.cpu.executeBVS(relative: oper)}, { s in s.cpu.sr & CPU6502.srVMask != 0 })
    }
    
    func testExecuteBitBranch(_ execution: (System, UInt8) -> (), _ condition: (System) -> Bool) {
        let s = System(cpu: CPU6502())
        let counterOperand = UInt16(0x5A1B)
        for registerOperand in UInt8.min...UInt8.max {
            for relativeOperand in UInt8.min...UInt8.max {
                s.cpu = CPU6502(pc: counterOperand, ac: registerOperand)
                let expectedCounter = !condition(s) ?
                    counterOperand :
                    UInt16(truncatingIfNeeded: Int32(counterOperand) &+ Int32(Int8(bitPattern: relativeOperand)))
                execution(s, relativeOperand)
                #expect(s.cpu == CPU6502(pc: expectedCounter, ac: registerOperand))
            }
        }
    }

    @Test func executeBBR0() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBR0(relative: oper)}, { s in s.cpu.ac & 0b00000001 == 0 })
    }
    
    @Test func executeBBR1() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBR1(relative: oper)}, { s in s.cpu.ac & 0b00000010 == 0 })
    }
    
    @Test func executeBBR2() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBR2(relative: oper)}, { s in s.cpu.ac & 0b00000100 == 0 })
    }
    
    @Test func executeBBR3() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBR3(relative: oper)}, { s in s.cpu.ac & 0b00001000 == 0 })
    }
    
    @Test func executeBBR4() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBR4(relative: oper)}, { s in s.cpu.ac & 0b00010000 == 0 })
    }
    
    @Test func executeBBR5() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBR5(relative: oper)}, { s in s.cpu.ac & 0b00100000 == 0 })
    }
    
    @Test func executeBBR6() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBR6(relative: oper)}, { s in s.cpu.ac & 0b01000000 == 0 })
    }
    
    @Test func executeBBR7() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBR7(relative: oper)}, { s in s.cpu.ac & 0b10000000 == 0 })
    }

    @Test func executeBBS0() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBS0(relative: oper)}, { s in s.cpu.ac & 0b00000001 != 0 })
    }
    
    @Test func executeBBS1() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBS1(relative: oper)}, { s in s.cpu.ac & 0b00000010 != 0 })
    }
    
    @Test func executeBBS2() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBS2(relative: oper)}, { s in s.cpu.ac & 0b00000100 != 0 })
    }
    
    @Test func executeBBS3() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBS3(relative: oper)}, { s in s.cpu.ac & 0b00001000 != 0 })
    }
    
    @Test func executeBBS4() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBS4(relative: oper)}, { s in s.cpu.ac & 0b00010000 != 0 })
    }
    
    @Test func executeBBS5() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBS5(relative: oper)}, { s in s.cpu.ac & 0b00100000 != 0 })
    }
    
    @Test func executeBBS6() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBS6(relative: oper)}, { s in s.cpu.ac & 0b01000000 != 0 })
    }
    
    @Test func executeBBS7() {
        testExecuteBitBranch({ s, oper in s.cpu.executeBBS7(relative: oper)}, { s in s.cpu.ac & 0b10000000 != 0 })
    }

    @Test func executeBRA() {
        testExecuteBranch({ s, oper in s.cpu.executeBRA(relative: oper)}, { _ in true })
    }
}

