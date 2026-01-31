//
//  CPU6502.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/24/25.
//
//  Documentation largely based on the work found at:
//  https://www.masswerk.at/6502/6502_instruction_set.html
//
//  Official documentation for the W65C02 can be found at:
//  https://www.westerndesigncenter.com/wdc/documentation/w65c02s.pdf
//

import Foundation

// MARK: - CPU State & Equality

public struct CPU6502 {
    public enum State {
        case boot
        case run
        case wait
        case stop
    }
    
    public internal(set) var pc: UInt16
    public internal(set) var ac: UInt8
    public internal(set) var xr: UInt8
    public internal(set) var yr: UInt8
    public internal(set) var sr: UInt8
    public internal(set) var sp: UInt8
    public internal(set) var state: State
    public internal(set) var load: (UInt16) -> UInt8
    public internal(set) var store: (UInt16, UInt8) -> ()

    public init(
        pc: UInt16 = 0x00,
        ac: UInt8 = 0x00,
        xr: UInt8 = 0x00,
        yr: UInt8 = 0x00,
        sr: UInt8 = 0x00,
        sp: UInt8 = 0x00,
        state: State = .boot,
        load: @escaping (UInt16) -> UInt8 = { address in return 0xEA },
        store: @escaping (UInt16, UInt8) -> () = { address, value in return }
    ) {
        self.pc = pc
        self.ac = ac
        self.xr = xr
        self.yr = yr
        self.sr = sr
        self.sp = sp
        self.state = .boot
        self.load = load
        self.store = store
    }
}

extension CPU6502: Equatable {
    public static func == (lhs: CPU6502, rhs: CPU6502) -> Bool {
        return
            lhs.pc == rhs.pc &&
            lhs.ac == rhs.ac &&
            lhs.xr == rhs.xr &&
            lhs.yr == rhs.yr &&
            lhs.sr == rhs.sr &&
            lhs.sp == rhs.sp
    }
}

extension CPU6502: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pc)
        hasher.combine(ac)
        hasher.combine(xr)
        hasher.combine(yr)
        hasher.combine(sr)
        hasher.combine(sp)
    }
}

// MARK: - Description

extension CPU6502: CustomDebugStringConvertible {
    public var debugDescription: String {
        let opcode = load(absolute: pc)
        let instruction = Instruction(rawValue: opcode)!
        let size = instruction.size
        let pcState = "PC: \(String(format: "0x%04X", pc)) \(instruction.name)(\(String(format: "0x%02X", opcode)))"
        let oper = {
            switch size {
            case 0, 1: "      "
            case 2: "\(String(format: "  0x%02X", load(absolute: pc &+ 1)))"
            default: "\(String(format: "0x%04X", UInt16(high: load(absolute: pc &+ 2), low: load(absolute: pc &+ 1))))"
            }
        }()
        let acState = "AC: \(String(format: "0x%02X", ac))"
        let xrState = "SR: \(String(format: "0x%02X", xr))"
        let yrState = "YR: \(String(format: "0x%02X", yr))"
        let srState = "SR: \(String(format: "0x%02X", sr))"
        let spState = "SP: \(String(format: "0x%02X", sp))"
        return "\(pcState) \(oper)   \(acState) \(xrState) \(yrState) \(srState) \(spState)"
    }
}

// MARK: - Status Register Bits

extension CPU6502 {
    static let srCMask: UInt8 = 0b00000001
    static let srZMask: UInt8 = 0b00000010
    static let srIMask: UInt8 = 0b00000100
    static let srDMask: UInt8 = 0b00001000
    static let srBMask: UInt8 = 0b00010000
    static let srXMask: UInt8 = 0b00100000
    static let srVMask: UInt8 = 0b01000000
    static let srNMask: UInt8 = 0b10000000
}

// MARK: - Status Flag Logic

extension CPU6502 {
    static func flags(
        _ status: UInt8,
        carry: Bool? = nil,
        zero: Bool? = nil,
        interrupt: Bool? = nil,
        decimal: Bool? = nil,
        break: Bool? = nil,
        ignored: Bool? = nil,
        overflow: Bool? = nil,
        negative: Bool? = nil
    ) -> UInt8 {
        var status = status
        if let carry = carry {
            status = carry ? (status | CPU6502.srCMask) : (status & ~CPU6502.srCMask)
        }
        if let zero = zero {
            status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        }
        if let interrupt = interrupt {
            status = interrupt ? (status | CPU6502.srIMask) : (status & ~CPU6502.srIMask)
        }
        if let decimal = decimal {
            status = decimal ? (status | CPU6502.srDMask) : (status & ~CPU6502.srDMask)
        }
        if let `break` = `break` {
            status = `break` ? (status | CPU6502.srBMask) : (status & ~CPU6502.srBMask)
        }
        if let ignored = ignored {
            status = ignored ? (status | CPU6502.srXMask) : (status & ~CPU6502.srXMask)
        }
        if let overflow = overflow {
            status = overflow ? (status | CPU6502.srVMask) : (status & ~CPU6502.srVMask)
        }
        if let negative = negative {
            status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        }
        return status
    }
    
    static func flags(_ status: UInt8, value: UInt8, carry: Bool? = nil, overflow: Bool? = nil) -> UInt8 {
        let negative = value & 0x80 != 0
        let zero = value == 0
        return flags(status, carry: carry, zero: zero, overflow: overflow, negative: negative)
    }
}

// MARK: - Arithmetic Logic

extension CPU6502 {
    static func increment(_ a: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let (result, s) = add(a, 1, status: status & ~CPU6502.srCMask)
        return (result: result, status: (s & ~CPU6502.srCMask) | (status & CPU6502.srCMask))
    }
    
    static func decrement(_ a: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let (result, s) = subtract(a, 1, status: status | CPU6502.srCMask)
        return (result: result, status: (s & ~CPU6502.srCMask) | (status & CPU6502.srCMask))
    }
    
    static func left(_ a: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a << 1 | (status & CPU6502.srCMask != 0 ? 0x01 : 0x00)
        let status = flags(status, value: result, carry: a & 0x80 != 0)
        return (result: result, status: status)
    }
    
    static func right(_ a: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a >> 1 | (status & CPU6502.srCMask != 0 ? 0x80 : 0x00)
        let status = flags(status, value: result, carry: a & 0x01 != 0)
        return (result: result, status: status)
    }
    
    static func and(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a & b
        let status = flags(status, value: result)
        return (result: result, status: status)
    }
    
    static func or(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a | b
        let status = flags(status, value: result)
        return (result: result, status: status)
    }
    
    static func xor(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a ^ b
        let status = flags(status, value: result)
        return (result: result, status: status)
    }
    
    static func bit(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a & b
        let signBitSet = a & 0b10000000 != 0
        let semsBitSet = a & 0b01000000 != 0
        var status = flags(status, value: result)
        status = signBitSet ? (status | 0b10000000) : (status & ~0b10000000)
        status = semsBitSet ? (status | 0b01000000) : (status & ~0b01000000)
        return (result: result, status: status)
    }
    
    static func add(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let sum = UInt16(a) + UInt16(b) + (status & CPU6502.srCMask == 0 ? 0 : 1)
        let result = UInt8(sum & 0xFF)
        let status = flags(status, value: result, carry: result != sum, overflow: (a & 0x80) != (b & 0x80) ? false : (result & 0x80) != (a & 0x80))
        return (result: result, status: status)
    }
    
    static func subtract(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        return add(a, ~b, status: status)
    }
}

// MARK: - Memory Addressing

extension CPU6502 {
    static let zeropage: UInt8 = 0x00
    static let stackpage: UInt8 = 0x01
    
    func address(zeropage oper: UInt8) -> UInt16 {
        return UInt16(high: CPU6502.zeropage, low: oper)
    }
    
    func address(zeropageX oper: UInt8) -> UInt16 {
        return UInt16(high: CPU6502.zeropage, low: oper &+ xr)
    }
    
    func address(zeropageY oper: UInt8) -> UInt16 {
        return UInt16(high: CPU6502.zeropage, low: oper &+ yr)
    }
    
    func address(absolute oper: UInt16) -> UInt16 {
        let address = oper
        return address
    }
    
    func address(absoluteX oper: UInt16) -> UInt16 {
        let address = oper &+ UInt16(xr)
        return address
    }
    
    func address(absoluteY oper: UInt16) -> UInt16 {
        let address = oper &+ UInt16(yr)
        return address
    }
    
    func address(indirect oper: UInt16) -> UInt16 {
        let pointer = oper
        let low = load(pointer)
        let high = load(pointer &+ 1)
        let address = UInt16(high: high, low: low)
        return address
    }

    func address(preIndirectX oper: UInt8) -> UInt16 {
        let pointer = UInt16(high: CPU6502.zeropage, low: oper &+ xr)
        let low = load(pointer)
        let high = load(pointer &+ 1)
        let address = UInt16(high: high, low: low)
        return address
    }
    
    func address(postIndirectY oper: UInt8) -> UInt16 {
        let pointer = UInt16(high: CPU6502.zeropage, low: oper)
        let low = load(pointer)
        let high = load(pointer &+ 1)
        let address = UInt16(high: high, low: low) &+ UInt16(yr)
        return address
    }

    func address(zeropageIndirect oper: UInt8) -> UInt16 {
        let pointer = UInt16(high: CPU6502.zeropage, low: oper)
        let low = load(pointer)
        let high = load(pointer &+ 1)
        let address = UInt16(high: high, low: low)
        return address
    }
    
    func address(stackpage oper: UInt8) -> UInt16 {
        let address = UInt16(high: CPU6502.stackpage, low: oper)
        return address
    }
    
    func address(relative oper: UInt8) -> UInt16 {
        let address = UInt16(truncatingIfNeeded: Int32(pc) &+ Int32(Int8(bitPattern: oper)))
        return address
    }
}

// MARK: - Load & Store

extension CPU6502 {
    func load(zeropage oper: UInt8) -> UInt8 {
        let address = address(zeropage: oper)
        let value = load(address)
        return value
    }
    
    func load(zeropageX oper: UInt8) -> UInt8 {
        let address = address(zeropageX: oper)
        let value = load(address)
        return value
    }
    
    func load(zeropageY oper: UInt8) -> UInt8 {
        let address = address(zeropageY: oper)
        let value = load(address)
        return value
    }
    
    func load(absolute oper: UInt16) -> UInt8 {
        let address = address(absolute: oper)
        let value = load(address)
        return value
    }
    
    func load(absoluteX oper: UInt16) -> UInt8 {
        let address = address(absoluteX: oper)
        let value = load(address)
        return value
    }
    
    func load(absoluteY oper: UInt16) -> UInt8 {
        let address = address(absoluteY: oper)
        let value = load(address)
        return value
    }
    
    func load(indirect oper: UInt16) -> UInt8 {
        let address = address(indirect: oper)
        let value = load(address)
        return value
    }
    
    func load(preIndirectX oper: UInt8) -> UInt8 {
        let address = address(preIndirectX: oper)
        let value = load(address)
        return value
    }
    
    func load(postIndirectY oper: UInt8) -> UInt8 {
        let address = address(postIndirectY: oper)
        let value = load(address)
        return value
    }
    
    func load(zeropageIndirect oper: UInt8) -> UInt8 {
        let address = address(zeropageIndirect: oper)
        let value = load(address)
        return value
    }
    
    func load(stackpage oper: UInt8) -> UInt8 {
        let address = address(stackpage: oper)
        let value = load(address)
        return value
    }
    
    func load(relative oper: UInt8) -> UInt8 {
        let address = address(relative: oper)
        let value = load(address)
        return value
    }
}

extension CPU6502 {
    func store(zeropage oper: UInt8, _ value: UInt8) {
        let address = address(zeropage: oper)
        store(address, value)
    }
    
    func store(zeropageX oper: UInt8, _ value: UInt8) {
        let address = address(zeropageX: oper)
        store(address, value)
    }
    
    func store(zeropageY oper: UInt8, _ value: UInt8) {
        let address = address(zeropageY: oper)
        store(address, value)
    }
    
    func store(absolute oper: UInt16, _ value: UInt8) {
        let address = address(absolute: oper)
        store(address, value)
    }
    
    func store(absoluteX oper: UInt16, _ value: UInt8) {
        let address = address(absoluteX: oper)
        store(address, value)
    }
    
    func store(absoluteY oper: UInt16, _ value: UInt8) {
        let address = address(absoluteY: oper)
        store(address, value)
    }
    
    func store(indirect oper: UInt16, _ value: UInt8) {
        let address = address(indirect: oper)
        store(address, value)
    }
    
    func store(preIndirectX oper: UInt8, _ value: UInt8) {
        let address = address(preIndirectX: oper)
        store(address, value)
    }
    
    func store(postIndirectY oper: UInt8, _ value: UInt8) {
        let address = address(postIndirectY: oper)
        store(address, value)
    }

    func store(zeropageIndirect oper: UInt8, _ value: UInt8) {
        let address = address(zeropageIndirect: oper)
        store(address, value)
    }
    
    func store(stackpage oper: UInt8, _ value: UInt8) {
        let address = address(stackpage: oper)
        store(address, value)
    }
    
    func store(relative oper: UInt8, _ value: UInt8) {
        let address = address(relative: oper)
        store(address, value)
    }
}

// MARK: - Push & Pull

extension CPU6502 {
    mutating func push(_ oper: UInt8) {
        store(stackpage: sp, oper)
        sp = sp &- 1
    }
    
    mutating func pushWide(_ oper: UInt16) {
        push(UInt8(oper & 0x00FF))
        push(UInt8((oper & 0xFF00) >> 8))
    }
    
    mutating func pull() -> UInt8 {
        sp = sp &+ 1
        let value = load(stackpage: sp)
        return value
    }
    
    mutating func pullWide() -> UInt16 {
        let high = pull()
        let low = pull()
        let value = UInt16(high: high, low: low)
        return value
    }
}

// MARK: - NOP Instruction

// NOP
// No Operation
//
// ---
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       NOP          EA     1        2
extension CPU6502 {
    mutating func executeNOP() {
        ()
    }
}

// MARK: - Program Execution

extension CPU6502 {
    @discardableResult
    public mutating func execute() -> (instruction: Instruction, oper: UInt8?, operWideHigh: UInt8?) {
        switch state {
        case .boot:
            let initializationVectorLow = load(absolute: 0xFFFC)
            let initializationVectorHigh = load(absolute: 0xFFFD)
            let initializationVector = UInt16(high: initializationVectorHigh, low: initializationVectorLow)
            state = .run
            executeJMP(absolute: initializationVector)
            return (instruction: Instruction.JMP_abs, oper: initializationVectorLow, operWideHigh: initializationVectorHigh)
        case .stop:
            return (instruction: Instruction.STP_impl, oper: nil, operWideHigh: nil)
        case .wait:
            return (instruction: Instruction.WAI_impl, oper: nil, operWideHigh: nil)
        case .run:
            ()
        }
        
        let opcode = load(absolute: pc)
        let instruction = Instruction(rawValue: opcode)!
        let oper: UInt8 = instruction.size <= 1 ? 0xAA : load(absolute: pc &+ 1)
        let operWideHigh = instruction.size <= 2 ? 0xBB : load(absolute: pc &+ 2)
        let operWide = UInt16(high: operWideHigh, low: oper)
        pc = pc &+ UInt16(instruction.size)
        switch instruction {
        case .BRK_impl: executeBRK()
        case .ORA_XInd: executeORA(preIndirectX: oper)
        case .NOP02: executeNOP()
        case .NOP03: executeNOP()
        case .TSB_zpg: executeTSB(zeropage: oper)
        case .ORA_zpg: executeORA(zeropage: oper)
        case .ASL_zpg: executeASL(zeropage: oper)
        case .RMB0_zpg: executeRMB0(zeropage: oper)
        case .PHP_impl: executePHP()
        case .ORA_imm: executeORA(immediate: oper)
        case .ASL_AC: executeASL()
        case .NOP0B: executeNOP()
        case .TSB_abs: executeTSB(absolute: operWide)
        case .ORA_abs: executeORA(absolute: operWide)
        case .ASL_abs: executeASL(absolute: operWide)
        case .BBR0_rel: executeBBR0(relative: oper)
        case .BPL_rel: executeBPL(relative: oper)
        case .ORA_indY: executeORA(postIndirectY: oper)
        case .ORA_zpgi: executeORA(zeropageIndirect: oper)
        case .NOP13: executeNOP()
        case .TRB_zpg: executeTRB(zeropage: oper)
        case .ORA_zpgX: executeORA(zeropageX: oper)
        case .ASL_zpgX: executeASL(zeropageX: oper)
        case .RMB1_zpg: executeRMB1(zeropage: oper)
        case .CLC_impl: executeCLC()
        case .ORA_absY: executeORA(absoluteY: operWide)
        case .INC_AC: executeINC()
        case .NOP1B: executeNOP()
        case .TRB_abs: executeTRB(absolute: operWide)
        case .ORA_absX: executeORA(absoluteX: operWide)
        case .ASL_absX: executeASL(absoluteX: operWide)
        case .BBR1_rel: executeBBR1(relative: oper)
        case .JSR_abs: executeJSR(absolute: operWide)
        case .AND_XInd: executeAND(preIndirectX: oper)
        case .NOP22: executeNOP()
        case .NOP23: executeNOP()
        case .BIT_zpg: executeBIT(zeropage: oper)
        case .AND_zpg: executeAND(zeropage: oper)
        case .ROL_zpg: executeROL(zeropage: oper)
        case .RMB2_zpg: executeRMB2(zeropage: oper)
        case .PLP_impl: executePLP()
        case .AND_imm: executeAND(immediate: oper)
        case .ROL_AC: executeROL()
        case .NOP2B: executeNOP()
        case .BIT_abs: executeBIT(absolute: operWide)
        case .AND_abs: executeAND(absolute: operWide)
        case .ROL_abs: executeROL(absolute: operWide)
        case .BBR2_rel: executeBBR2(relative: oper)
        case .BMI_rel: executeBMI(relative: oper)
        case .AND_indY: executeAND(postIndirectY: oper)
        case .AND_zpgi: executeAND(zeropageIndirect: oper)
        case .NOP33: executeNOP()
        case .BIT_zpgX: executeBIT(zeropageX: oper)
        case .AND_zpgX: executeAND(zeropageX: oper)
        case .ROL_zpgX: executeROL(zeropageX: oper)
        case .RMB3_zpg: executeRMB3(zeropage: oper)
        case .SEC_impl: executeSEC()
        case .AND_absY: executeAND(absoluteY: operWide)
        case .DEC_AC: executeDEC()
        case .NOP3B: executeNOP()
        case .BIT_absX: executeBIT(absoluteX: operWide)
        case .AND_absX: executeAND(absoluteX: operWide)
        case .ROL_absX: executeROL(absoluteX: operWide)
        case .BBR3_rel: executeBBR3(relative: oper)
        case .RTI_impl: executeRTI()
        case .EOR_XInd: executeEOR(preIndirectX: oper)
        case .NOP42: executeNOP()
        case .NOP43: executeNOP()
        case .NOP44: executeNOP()
        case .EOR_zpg: executeEOR(zeropage: oper)
        case .LSR_zpg: executeLSR(zeropage: oper)
        case .RMB4_zpg: executeRMB4(zeropage: oper)
        case .PHA_impl: executePHA()
        case .EOR_imm: executeEOR(immediate: oper)
        case .LSR_AC: executeLSR()
        case .NOP4B: executeNOP()
        case .JMP_abs: executeJMP(absolute: operWide)
        case .EOR_abs: executeEOR(absolute: operWide)
        case .LSR_abs: executeLSR(absolute: operWide)
        case .BBR4_rel: executeBBR4(relative: oper)
        case .BVC_rel: executeBVC(relative: oper)
        case .EOR_indY: executeEOR(postIndirectY: oper)
        case .EOR_zpgi: executeEOR(zeropageIndirect: oper)
        case .NOP53: executeNOP()
        case .NOP54: executeNOP()
        case .EOR_zpgX: executeEOR(zeropageX: oper)
        case .LSR_zpgX: executeLSR(zeropageX: oper)
        case .RMB5_zpg: executeRMB5(zeropage: oper)
        case .CLI_impl: executeCLI()
        case .EOR_absY: executeEOR(absoluteY: operWide)
        case .PHY_impl: executePHY()
        case .NOP5B: executeNOP()
        case .NOP5C: executeNOP()
        case .EOR_absX: executeEOR(absoluteX: operWide)
        case .LSR_absX: executeLSR(absoluteX: operWide)
        case .BBR5_rel: executeBBR5(relative: oper)
        case .RTS_impl: executeRTS()
        case .ADC_XInd: executeADC(preIndirectX: oper)
        case .NOP62: executeNOP()
        case .NOP63: executeNOP()
        case .STZ_zpg: executeSTZ(zeropage: oper)
        case .ADC_zpg: executeADC(zeropage: oper)
        case .ROR_zpg: executeROR(zeropage: oper)
        case .RMB6_zpg: executeRMB6(zeropage: oper)
        case .PLA_impl: executePLA()
        case .ADC_imm: executeADC(immediate: oper)
        case .ROR_AC: executeROR()
        case .NOP6B: executeNOP()
        case .JMP_ind: executeJMP(indirect: operWide)
        case .ADC_abs: executeADC(absolute: operWide)
        case .ROR_abs: executeROR(absolute: operWide)
        case .BBR6_rel: executeBBR6(relative: oper)
        case .BVS_rel: executeBVS(relative: oper)
        case .ADC_indY: executeADC(postIndirectY: oper)
        case .ADC_zpgi: executeADC(zeropageIndirect: oper)
        case .NOP73: executeNOP()
        case .STZ_zpgX: executeSTZ(zeropageX: oper)
        case .ADC_zpgX: executeADC(zeropageX: oper)
        case .ROR_zpgX: executeROR(zeropageX: oper)
        case .RMB7_zpg: executeRMB7(zeropage: oper)
        case .SEI_impl: executeSEI()
        case .ADC_absY: executeADC(absoluteY: operWide)
        case .PLY_impl: executePLY()
        case .NOP7B: executeNOP()
        case .JMP_absXInd: executeJMP(absoluteXIndirect: operWide)
        case .ADC_absX: executeADC(absoluteX: operWide)
        case .ROR_absX: executeROR(absoluteX: operWide)
        case .BBR7_rel: executeBBR7(relative: oper)
        case .BRA_rel: executeBRA(relative: oper)
        case .STA_XInd: executeSTA(preIndirectX: oper)
        case .NOP82: executeNOP()
        case .NOP83: executeNOP()
        case .STY_zpg: executeSTY(zeropage: oper)
        case .STA_zpg: executeSTA(zeropage: oper)
        case .STX_zpg: executeSTX(zeropage: oper)
        case .SMB0_zpg: executeSMB0(zeropage: oper)
        case .DEY_impl: executeDEY()
        case .BIT_imm: executeBIT(immediate: oper)
        case .TXA_impl: executeTXA()
        case .NOP8B: executeNOP()
        case .STY_abs: executeSTY(absolute: operWide)
        case .STA_abs: executeSTA(absolute: operWide)
        case .STX_abs: executeSTX(absolute: operWide)
        case .BBS0_rel: executeBBS0(relative: oper)
        case .BCC_rel: executeBCC(relative: oper)
        case .STA_indY: executeSTA(postIndirectY: oper)
        case .STA_zpgi: executeSTA(zeropageIndirect: oper)
        case .NOP93: executeNOP()
        case .STY_zpgX: executeSTY(zeropageX: oper)
        case .STA_zpgX: executeSTA(zeropageX: oper)
        case .STX_zpgY: executeSTX(zeropageY: oper)
        case .SMB1_zpg: executeSMB1(zeropage: oper)
        case .TYA_impl: executeTYA()
        case .STA_absY: executeSTA(absoluteY: operWide)
        case .TXS_impl: executeTXS()
        case .NOP9B: executeNOP()
        case .STZ_abs: executeSTZ(absolute: operWide)
        case .STA_absX: executeSTA(absoluteX: operWide)
        case .STZ_absX: executeSTZ(absoluteX: operWide)
        case .BBS1_rel: executeBBS1(relative: oper)
        case .LDY_imm: executeLDY(immediate: oper)
        case .LDA_XInd: executeLDA(preIndirectX: oper)
        case .LDX_imm: executeLDX(immediate: oper)
        case .NOPA3: executeNOP()
        case .LDY_zpg: executeLDY(zeropage: oper)
        case .LDA_zpg: executeLDA(zeropage: oper)
        case .LDX_zpg: executeLDX(zeropage: oper)
        case .SMB2_zpg: executeSMB2(zeropage: oper)
        case .TAY_impl: executeTAY()
        case .LDA_imm: executeLDA(immediate: oper)
        case .TAX_impl: executeTAX()
        case .NOPAB: executeNOP()
        case .LDY_abs: executeLDY(absolute: operWide)
        case .LDA_abs: executeLDA(absolute: operWide)
        case .LDX_abs: executeLDX(absolute: operWide)
        case .BBS2_rel: executeBBS2(relative: oper)
        case .BCS_rel: executeBCS(relative: oper)
        case .LDA_indY: executeLDA(postIndirectY: oper)
        case .LDA_zpgi: executeLDA(zeropageIndirect: oper)
        case .NOPB3: executeNOP()
        case .LDY_zpgX: executeLDY(zeropageX: oper)
        case .LDA_zpgX: executeLDA(zeropageX: oper)
        case .LDX_zpgY: executeLDX(zeropageY: oper)
        case .SMB3_zpg: executeSMB3(zeropage: oper)
        case .CLV_impl: executeCLV()
        case .LDA_absY: executeLDA(absoluteY: operWide)
        case .TSX_impl: executeTSX()
        case .NOPBB: executeNOP()
        case .LDY_absX: executeLDY(absoluteX: operWide)
        case .LDA_absX: executeLDA(absoluteX: operWide)
        case .LDX_absY: executeLDX(absoluteY: operWide)
        case .BBS3_rel: executeBBS3(relative: oper)
        case .CPY_imm: executeCPY(immediate: oper)
        case .CMP_XInd: executeCMP(preIndirectX: oper)
        case .NOPC2: executeNOP()
        case .NOPC3: executeNOP()
        case .CPY_zpg: executeCPY(zeropage: oper)
        case .CMP_zpg: executeCMP(zeropage: oper)
        case .DEC_zpg: executeDEC(zeropage: oper)
        case .SMB4_zpg: executeSMB4(zeropage: oper)
        case .INY_impl: executeINY()
        case .CMP_imm: executeCMP(immediate: oper)
        case .DEX_impl: executeDEX()
        case .WAI_impl: executeWAI()
        case .CPY_abs: executeCPY(absolute: operWide)
        case .CMP_abs: executeCMP(absolute: operWide)
        case .DEC_abs: executeDEC(absolute: operWide)
        case .BBS4_rel: executeBBS4(relative: oper)
        case .BNE_rel: executeBNE(relative: oper)
        case .CMP_indY: executeCMP(postIndirectY: oper)
        case .CMP_zpgi: executeCMP(zeropageIndirect: oper)
        case .NOPD3: executeNOP()
        case .NOPD4: executeNOP()
        case .CMP_zpgX: executeCMP(zeropageX: oper)
        case .DEC_zpgX: executeDEC(zeropageX: oper)
        case .SMB5_zpg: executeSMB5(zeropage: oper)
        case .CLD_impl: executeCLD()
        case .CMP_absY: executeCMP(absoluteY: operWide)
        case .PHX_impl: executePHX()
        case .STP_impl: executeSTP()
        case .NOPDC: executeNOP()
        case .CMP_absX: executeCMP(absoluteX: operWide)
        case .DEC_absX: executeDEC(absoluteX: operWide)
        case .BBS5_rel: executeBBS5(relative: oper)
        case .CPX_imm: executeCPX(immediate: oper)
        case .SBC_XInd: executeSBC(preIndirectX: oper)
        case .NOPE2: executeNOP()
        case .NOPE3: executeNOP()
        case .CPX_zpg: executeCPX(zeropage: oper)
        case .SBC_zpg: executeSBC(zeropage: oper)
        case .INC_zpg: executeINC(zeropage: oper)
        case .SMB6_zpg: executeSMB6(zeropage: oper)
        case .INX_impl: executeINX()
        case .SBC_imm: executeSBC(immediate: oper)
        case .NOP_impl: executeNOP()
        case .NOPEB: executeNOP()
        case .CPX_abs: executeCPX(absolute: operWide)
        case .SBC_abs: executeSBC(absolute: operWide)
        case .INC_abs: executeINC(absolute: operWide)
        case .BBS6_rel: executeBBS6(relative: oper)
        case .BEQ_rel: executeBEQ(relative: oper)
        case .SBC_indY: executeSBC(postIndirectY: oper)
        case .SBC_zpgi: executeSBC(zeropageIndirect: oper)
        case .NOPF3: executeNOP()
        case .NOPF4: executeNOP()
        case .SBC_zpgX: executeSBC(zeropageX: oper)
        case .INC_zpgX: executeINC(zeropageX: oper)
        case .SMB7_zpg: executeSMB7(zeropage: oper)
        case .SED_impl: executeSED()
        case .SBC_absY: executeSBC(absoluteY: operWide)
        case .PLX_impl: executePLX()
        case .NOPFB: executeNOP()
        case .NOPFC: executeNOP()
        case .SBC_absX: executeSBC(absoluteX: operWide)
        case .INC_absX: executeINC(absoluteX: operWide)
        case .BBS: executeNOP()
        }
        
        return (instruction: instruction, oper: oper, operWideHigh: operWideHigh)
    }
    
    public mutating func stop() {
        state = .stop
    }
    
    public mutating func wait() {
        state = .wait
    }
    
    public mutating func resume() {
        state = .run
    }
}

// MARK: - Conveniences

extension UInt16 {
    init(high: UInt8, low: UInt8) {
        self = (UInt16(high) << 8) &+ UInt16(low)
    }
}
