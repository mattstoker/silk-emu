//
//  CPU6502.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/24/25.
//
//  Documentation largely based on the work found at:
//  https://www.masswerk.at/6502/6502_instruction_set.html
//

// MARK: CPU State & Equality

struct CPU6502 {
    var pc: UInt16
    var ac: UInt8
    var xr: UInt8
    var yr: UInt8
    var sr: UInt8
    var sp: UInt8
    var res: Bool
    var irq: Bool
    var nmi: Bool
    var load: (UInt16) -> UInt8 = { address in return 0xEA }
    var store: (UInt16, UInt8) -> () = { address, value in return }
}

extension CPU6502: Equatable {
    static func == (lhs: CPU6502, rhs: CPU6502) -> Bool {
        return
            lhs.pc == rhs.pc &&
            lhs.ac == rhs.ac &&
            lhs.xr == rhs.xr &&
            lhs.yr == rhs.yr &&
            lhs.sr == rhs.sr &&
            lhs.sp == rhs.sp &&
            lhs.res == rhs.res &&
            lhs.irq == rhs.irq &&
            lhs.nmi == rhs.nmi
    }
}

extension CPU6502: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(pc)
        hasher.combine(ac)
        hasher.combine(xr)
        hasher.combine(yr)
        hasher.combine(sr)
        hasher.combine(sp)
        hasher.combine(res)
        hasher.combine(irq)
        hasher.combine(nmi)
    }
}

extension CPU6502 {
    init(
        pc: UInt16 = 0x00,
        ac: UInt8 = 0x00,
        xr: UInt8 = 0x00,
        yr: UInt8 = 0x00,
        sr: UInt8 = 0x00,
        sp: UInt8 = 0x00,
        res: Bool = false,
        irq: Bool = false
        // nmi: Bool = false
    ) {
        self.pc = pc
        self.ac = ac
        self.xr = xr
        self.yr = yr
        self.sr = sr
        self.sp = sp
        self.res = res
        self.irq = irq
        self.nmi = false //nmi
    }
}

// MARK: Status Register Bits

extension CPU6502 {
    static let srNMask: UInt8 = 0b10000000
    static let srVMask: UInt8 = 0b01000000
    static let srXMask: UInt8 = 0b00100000
    static let srBMask: UInt8 = 0b00010000
    static let srDMask: UInt8 = 0b00001000
    static let srIMask: UInt8 = 0b00000100
    static let srZMask: UInt8 = 0b00000010
    static let srCMask: UInt8 = 0b00000001
}

// MARK: Arithmetic Logic

extension CPU6502 {
    static func increment(_ a: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let (result, s) = add(a, 1, status: status)
        return (result: result, status: (s & ~CPU6502.srCMask) | (status & CPU6502.srCMask))
    }
    
    static func decrement(_ a: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let (result, s) = subtract(a, 1, status: status | CPU6502.srCMask)
        return (result: result, status: (s & ~CPU6502.srCMask) | (status & CPU6502.srCMask))
    }
    
    static func left(_ a: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a << 1 | (status & CPU6502.srCMask != 0 ? 0x01 : 0x00)
        let negative = result & 0x80 != 0
        let zero = result == 0
        let carry = a & 0x80 != 0
        var status = status
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        status = carry ? (status | CPU6502.srCMask) : (status & ~CPU6502.srCMask)
        return (result: result, status: status)
    }
    
    static func right(_ a: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a >> 1 | (status & CPU6502.srCMask != 0 ? 0x80 : 0x00)
        let negative = result & 0x80 != 0
        let zero = result == 0
        let carry = a & 0x01 != 0
        var status = status
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        status = carry ? (status | CPU6502.srCMask) : (status & ~CPU6502.srCMask)
        return (result: result, status: status)
    }
    
    static func and(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a & b
        let negative = result & 0x80 != 0
        let zero = result == 0
        var status = status
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        return (result: result, status: status)
    }
    
    static func or(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a | b
        let negative = result & 0x80 != 0
        let zero = result == 0
        var status = status
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        return (result: result, status: status)
    }
    
    static func xor(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a ^ b
        let negative = result & 0x80 != 0
        let zero = result == 0
        var status = status
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        return (result: result, status: status)
    }
    
    static func bit(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let result = a & b
        let zero = result == 0
        let signBitSet = a & 0b10000000 != 0
        let semsBitSet = a & 0b01000000 != 0
        var status = status
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        status = signBitSet ? (status | 0b10000000) : (status & ~0b10000000)
        status = semsBitSet ? (status | 0b01000000) : (status & ~0b01000000)
        return (result: result, status: status)
    }
    
    static func add(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        let sum = UInt16(a) + UInt16(b) + (status & CPU6502.srCMask == 0 ? 0 : 1)
        let result = UInt8(sum & 0xFF)
        let negative = result & 0x80 != 0
        let zero = result == 0
        let carry = result != sum
        let overflow = (a & 0x80) != (b & 0x80) ? false : (result & 0x80) != (a & 0x80)
        var status = status
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        status = carry ? (status | CPU6502.srCMask) : (status & ~CPU6502.srCMask)
        status = overflow ? (status | CPU6502.srVMask) : (status & ~CPU6502.srVMask)
        return (result: result, status: status)
    }
    
    static func subtract(_ a: UInt8, _ b: UInt8, status: UInt8) -> (result: UInt8, status: UInt8) {
        return add(a, ~b, status: status)
    }
}

// MARK: Memory Addressing

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

    func address(preIndirectX oper: UInt16) -> UInt16 {
        let pointer = oper &+ UInt16(xr)
        let low = load(pointer)
        let high = load(pointer &+ 1)
        let address = UInt16(high: high, low: low)
        return address
    }
    
    func address(postIndirectY oper: UInt16) -> UInt16 {
        let pointer = oper
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
    
    func address(relative oper: UInt8, zeroOffset: Int8 = 0) -> UInt16 {
        let address = UInt16(truncatingIfNeeded: Int32(pc) &+ Int32(zeroOffset) &+ Int32(Int8(bitPattern: oper)))
        return address
    }
}

// MARK: Load & Store

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
    
    func load(preIndirectX oper: UInt16) -> UInt8 {
        let address = address(preIndirectX: oper)
        let value = load(address)
        return value
    }
    
    func load(postIndirectY oper: UInt16) -> UInt8 {
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
    
    func store(preIndirectX oper: UInt16, _ value: UInt8) {
        let address = address(preIndirectX: oper)
        store(address, value)
    }
    
    func store(postIndirectY oper: UInt16, _ value: UInt8) {
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

// MARK: NOP Instruction

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

// MARK: Conveniences

extension UInt16 {
    init(high: UInt8, low: UInt8) {
        self = (UInt16(high) << 8) &+ UInt16(low)
    }
}
