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
            lhs.sp == rhs.sp
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
    }
}

extension CPU6502 {
    init(
        pc: UInt16 = 0x00,
        ac: UInt8 = 0x00,
        xr: UInt8 = 0x00,
        yr: UInt8 = 0x00,
        sr: UInt8 = 0x00,
        sp: UInt8 = 0x00
    ) {
        self.pc = pc
        self.ac = ac
        self.xr = xr
        self.yr = yr
        self.sr = sr
        self.sp = sp
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

// MARK: Push & Pull

extension CPU6502 {
    mutating func push(_ oper: UInt8) {
        store(stackpage: sp, oper)
        sp = sp &- 1
    }
    
    mutating func pushWide(_ oper: UInt16) {
        push(UInt8((oper & 0xFF00) >> 8))
        push(UInt8(oper & 0x00FF))
    }
    
    mutating func pull() -> UInt8 {
        let value = load(stackpage: sp)
        sp = sp &+ 1
        return value
    }
    
    mutating func pullWide() -> UInt16 {
        let high = pull()
        let low = pull()
        let value = UInt16(high: high, low: low)
        return value
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

// MARK: Program Counter Management

extension CPU6502 {
    enum Instruction: UInt8 {
        case BRK_impl = 0x00
        case ORA_XInd = 0x01
        case NOP02 = 0x02
        case NOP03 = 0x03
        case TSB_zpg = 0x04
        case ORA_zpg = 0x05
        case ASL_zpg = 0x06
        case RMB0_zpg = 0x07
        case PHP_impl = 0x08
        case ORA_imm = 0x09
        case ASL_AC = 0x0A
        case NOP0B = 0x0B
        case TSB_abs = 0x0C
        case ORA_abs = 0x0D
        case ASL_abs = 0x0E
        case BBR0_rel = 0x0F
        case BPL_rel = 0x10
        case ORA_indY = 0x11
        case ORA_zpgi = 0x12
        case NOP13 = 0x13
        case TRB_zpg = 0x14
        case ORA_zpgX = 0x15
        case ASL_zpgX = 0x16
        case RMB1_zpg = 0x17
        case CLC_impl = 0x18
        case ORA_absY = 0x19
        case INC_AC = 0x1A
        case NOP1B = 0x1B
        case TRB_abs = 0x1C
        case ORA_absX = 0x1D
        case ASL_absX = 0x1E
        case BBR1_rel = 0x1F
        case JSR_abs = 0x20
        case AND_XInd = 0x21
        case NOP22 = 0x22
        case NOP23 = 0x23
        case BIT_zpg = 0x24
        case AND_zpg = 0x25
        case ROL_zpg = 0x26
        case RMB2_zpg = 0x27
        case PLP_impl = 0x28
        case AND_imm = 0x29
        case ROL_AC = 0x2A
        case NOP2B = 0x2B
        case BIT_abs = 0x2C
        case AND_abs = 0x2D
        case ROL_abs = 0x2E
        case BBR2_rel = 0x2F
        case BMI_rel = 0x30
        case AND_indY = 0x31
        case AND_zpgi = 0x32
        case NOP33 = 0x33
        case BIT_zpgX = 0x34
        case AND_zpgX = 0x35
        case ROL_zpgX = 0x36
        case RMB3_zpg = 0x37
        case SEC_impl = 0x38
        case AND_absY = 0x39
        case DEC_AC = 0x3A
        case NOP3B = 0x3B
        case BIT_absX = 0x3C
        case AND_absX = 0x3D
        case ROL_absX = 0x3E
        case BBR3_rel = 0x3F
        case RTI_impl = 0x40
        case EOR_XInd = 0x41
        case NOP42 = 0x42
        case NOP43 = 0x43
        case NOP44 = 0x44
        case EOR_zpg = 0x45
        case LSR_zpg = 0x46
        case RMB4_zpg = 0x47
        case PHA_impl = 0x48
        case EOR_imm = 0x49
        case LSR_AC = 0x4A
        case NOP4B = 0x4B
        case JMP_abs = 0x4C
        case EOR_abs = 0x4D
        case LSR_abs = 0x4E
        case BBR4_rel = 0x4F
        case BVC_rel = 0x50
        case EOR_indY = 0x51
        case EOR_zpgi = 0x52
        case NOP53 = 0x53
        case NOP54 = 0x54
        case EOR_zpgX = 0x55
        case LSR_zpgX = 0x56
        case RMB5_zpg = 0x57
        case CLI_impl = 0x58
        case EOR_absY = 0x59
        case PHY_impl = 0x5A
        case NOP5B = 0x5B
        case NOP5C = 0x5C
        case EOR_absX = 0x5D
        case LSR_absX = 0x5E
        case BBR5_rel = 0x5F
        case RTS_impl = 0x60
        case ADC_XInd = 0x61
        case NOP62 = 0x62
        case NOP63 = 0x63
        case STZ_zpg = 0x64
        case ADC_zpg = 0x65
        case ROR_zpg = 0x66
        case RMB6_zpg = 0x67
        case PLA_impl = 0x68
        case ADC_imm = 0x69
        case ROR_AC = 0x6A
        case NOP6B = 0x6B
        case JMP_ind = 0x6C
        case ADC_abs = 0x6D
        case ROR_abs = 0x6E
        case BBR6_rel = 0x6F
        case BVS_rel = 0x70
        case ADC_indY = 0x71
        case ADC_zpgi = 0x72
        case NOP73 = 0x73
        case STZ_zpgX = 0x74
        case ADC_zpgX = 0x75
        case ROR_zpgX = 0x76
        case RMB7_zpg = 0x77
        case SEI_impl = 0x78
        case ADC_absY = 0x79
        case PLY_impl = 0x7A
        case NOP7B = 0x7B
        case JMP_absXInd = 0x7C
        case ADC_absX = 0x7D
        case ROR_absX = 0x7E
        case BBR7_rel = 0x7F
        case BRA_rel = 0x80
        case STA_XInd = 0x81
        case NOP82 = 0x82
        case NOP83 = 0x83
        case STY_zpg = 0x84
        case STA_zpg = 0x85
        case STX_zpg = 0x86
        case SMB0_zpg = 0x87
        case DEY_impl = 0x88
        case BIT_imm = 0x89
        case TXA_impl = 0x8A
        case NOP8B = 0x8B
        case STY_abs = 0x8C
        case STA_abs = 0x8D
        case STX_abs = 0x8E
        case BBS0_rel = 0x8F
        case BCC_rel = 0x90
        case STA_indY = 0x91
        case STA_zpgi = 0x92
        case NOP93 = 0x93
        case STY_zpgX = 0x94
        case STA_zpgX = 0x95
        case STX_zpgY = 0x96
        case SMB1_zpg = 0x97
        case TYA_impl = 0x98
        case STA_absY = 0x99
        case TXS_impl = 0x9A
        case NOP9B = 0x9B
        case STZ_abs = 0x9C
        case STA_absX = 0x9D
        case STZ_absX = 0x9E
        case BBS1_rel = 0x9F
        case LDY_imm = 0xA0
        case LDA_XInd = 0xA1
        case LDX_imm = 0xA2
        case NOPA3 = 0xA3
        case LDY_zpg = 0xA4
        case LDA_zpg = 0xA5
        case LDX_zpg = 0xA6
        case SMB2_zpg = 0xA7
        case TAY_impl = 0xA8
        case LDA_imm = 0xA9
        case TAX_impl = 0xAA
        case NOPAB = 0xAB
        case LDY_abs = 0xAC
        case LDA_abs = 0xAD
        case LDX_abs = 0xAE
        case BBS2_rel = 0xAF
        case BCS_rel = 0xB0
        case LDA_indY = 0xB1
        case LDA_zpgi = 0xB2
        case NOPB3 = 0xB3
        case LDY_zpgX = 0xB4
        case LDA_zpgX = 0xB5
        case LDX_zpgY = 0xB6
        case SMB3_zpg = 0xB7
        case CLV_impl = 0xB8
        case LDA_absY = 0xB9
        case TSX_impl = 0xBA
        case NOPBB = 0xBB
        case LDY_absX = 0xBC
        case LDA_absX = 0xBD
        case LDX_absY = 0xBE
        case BBS3_rel = 0xBF
        case CPY_imm = 0xC0
        case CMP_XInd = 0xC1
        case NOPC2 = 0xC2
        case NOPC3 = 0xC3
        case CPY_zpg = 0xC4
        case CMP_zpg = 0xC5
        case DEC_zpg = 0xC6
        case SMB4_zpg = 0xC7
        case INY_impl = 0xC8
        case CMP_imm = 0xC9
        case DEX_impl = 0xCA
        case WAI_impl = 0xCB
        case CPY_abs = 0xCC
        case CMP_abs = 0xCD
        case DEC_abs = 0xCE
        case BBS4_rel = 0xCF
        case BNE_rel = 0xD0
        case CMP_indY = 0xD1
        case CMP_zpgi = 0xD2
        case NOPD3 = 0xD3
        case NOPD4 = 0xD4
        case CMP_zpgX = 0xD5
        case DEC_zpgX = 0xD6
        case SMB5_zpg = 0xD7
        case CLD_impl = 0xD8
        case CMP_absY = 0xD9
        case PHX_impl = 0xDA
        case STP_impl = 0xDB
        case NOPDC = 0xDC
        case CMP_absX = 0xDD
        case DEC_absX = 0xDE
        case BBS5_rel = 0xDF
        case CPX_imm = 0xE0
        case SBC_XInd = 0xE1
        case NOPE2 = 0xE2
        case NOPE3 = 0xE3
        case CPX_zpg = 0xE4
        case SBC_zpg = 0xE5
        case INC_zpg = 0xE6
        case SMB6_zpg = 0xE7
        case INX_impl = 0xE8
        case SBC_imm = 0xE9
        case NOP_impl = 0xEA
        case NOPEB = 0xEB
        case CPX_abs = 0xEC
        case SBC_abs = 0xED
        case INC_abs = 0xEE
        case BBS6_rel = 0xEF
        case BEQ_rel = 0xF0
        case SBC_indY = 0xF1
        case SBC_zpgi = 0xF2
        case NOPF3 = 0xF3
        case NOPF4 = 0xF4
        case SBC_zpgX = 0xF5
        case INC_zpgX = 0xF6
        case SMB7_zpg = 0xF7
        case SED_impl = 0xF8
        case SBC_absY = 0xF9
        case PLX_impl = 0xFA
        case NOPFB = 0xFB
        case NOPFC = 0xFC
        case SBC_absX = 0xFD
        case INC_absX = 0xFE
        case BBS = 0xFF
    }
    
    static func instructionOpcode(_ instruction: Instruction) -> UInt8 {
        return instruction.rawValue
    }
    
    static func instructionSize(_ instruction: Instruction) -> UInt8 {
        return instructionSize(instruction.rawValue)
    }
    
    static func instructionSize(_ opcode: UInt8) -> UInt8 {
        switch opcode {
        case 0x69: return 2
        case 0x65: return 2
        case 0x75: return 2
        case 0x6D: return 3
        case 0x7D: return 3
        case 0x79: return 3
        case 0x61: return 2
        case 0x71: return 2
        case 0x29: return 2
        case 0x25: return 2
        case 0x35: return 2
        case 0x2D: return 3
        case 0x3D: return 3
        case 0x39: return 3
        case 0x21: return 2
        case 0x31: return 2
        case 0x0A: return 1
        case 0x06: return 2
        case 0x16: return 2
        case 0x0E: return 3
        case 0x1E: return 3
        case 0x90: return 2
        case 0xB0: return 2
        case 0xF0: return 2
        case 0x24: return 2
        case 0x2C: return 3
        case 0x30: return 2
        case 0xD0: return 2
        case 0x10: return 2
        case 0x00: return 1
        case 0x50: return 2
        case 0x70: return 2
        case 0x18: return 1
        case 0xD8: return 1
        case 0x58: return 1
        case 0xB8: return 1
        case 0xC9: return 2
        case 0xC5: return 2
        case 0xD5: return 2
        case 0xCD: return 3
        case 0xDD: return 3
        case 0xD9: return 3
        case 0xC1: return 2
        case 0xD1: return 2
        case 0xE0: return 2
        case 0xE4: return 2
        case 0xEC: return 3
        case 0xC0: return 2
        case 0xC4: return 2
        case 0xCC: return 3
        case 0xC6: return 2
        case 0xD6: return 2
        case 0xCE: return 3
        case 0xDE: return 3
        case 0xCA: return 1
        case 0x88: return 1
        case 0x49: return 2
        case 0x45: return 2
        case 0x55: return 2
        case 0x4D: return 3
        case 0x5D: return 3
        case 0x59: return 3
        case 0x41: return 2
        case 0x51: return 2
        case 0xE6: return 2
        case 0xF6: return 2
        case 0xEE: return 3
        case 0xFE: return 3
        case 0xE8: return 1
        case 0xC8: return 1
        case 0x4C: return 3
        case 0x6C: return 3
        case 0x20: return 3
        case 0xA9: return 2
        case 0xA5: return 2
        case 0xB5: return 2
        case 0xAD: return 3
        case 0xBD: return 3
        case 0xB9: return 3
        case 0xA1: return 2
        case 0xB1: return 2
        case 0xA2: return 2
        case 0xA6: return 2
        case 0xB6: return 2
        case 0xAE: return 3
        case 0xBE: return 3
        case 0xA0: return 2
        case 0xA4: return 2
        case 0xB4: return 2
        case 0xAC: return 3
        case 0xBC: return 3
        case 0x4A: return 1
        case 0x46: return 2
        case 0x56: return 2
        case 0x4E: return 3
        case 0x5E: return 3
        case 0xEA: return 1
        case 0x09: return 2
        case 0x05: return 2
        case 0x15: return 2
        case 0x0D: return 3
        case 0x1D: return 3
        case 0x19: return 3
        case 0x01: return 2
        case 0x11: return 2
        case 0x48: return 1
        case 0x08: return 1
        case 0x68: return 1
        case 0x28: return 1
        case 0x2A: return 1
        case 0x26: return 2
        case 0x36: return 2
        case 0x2E: return 3
        case 0x3E: return 3
        case 0x6A: return 1
        case 0x66: return 2
        case 0x76: return 2
        case 0x6E: return 3
        case 0x7E: return 3
        case 0x40: return 1
        case 0x60: return 1
        case 0xE9: return 2
        case 0xE5: return 2
        case 0xF5: return 2
        case 0xED: return 3
        case 0xFD: return 3
        case 0xF9: return 3
        case 0xE1: return 2
        case 0xF1: return 2
        case 0x38: return 1
        case 0xF8: return 1
        case 0x78: return 1
        case 0x85: return 2
        case 0x95: return 2
        case 0x8D: return 3
        case 0x9D: return 3
        case 0x99: return 3
        case 0x81: return 2
        case 0x91: return 2
        case 0x86: return 2
        case 0x96: return 2
        case 0x8E: return 3
        case 0x84: return 2
        case 0x94: return 2
        case 0x8C: return 3
        case 0xAA: return 1
        case 0xA8: return 1
        case 0xBA: return 1
        case 0x8A: return 1
        case 0x9A: return 1
        case 0x98: return 1
        case 0x72: return 2
        case 0x32: return 2
        case 0x89: return 3
        case 0x3C: return 3
        case 0x34: return 2
        case 0xD2: return 2
        case 0x3A: return 1
        case 0x52: return 2
        case 0x1A: return 1
        case 0x7C: return 3
        case 0xB2: return 2
        case 0x12: return 2
        case 0xF2: return 2
        case 0x92: return 2
        case 0x0F: return 2
        case 0x1F: return 2
        case 0x2F: return 2
        case 0x3F: return 2
        case 0x4F: return 2
        case 0x5F: return 2
        case 0x6F: return 2
        case 0x7F: return 2
        case 0x8F: return 2
        case 0x9F: return 2
        case 0xAF: return 2
        case 0xBF: return 2
        case 0xCF: return 2
        case 0xDF: return 2
        case 0xEF: return 2
        case 0xFF: return 2
        case 0x80: return 2
        case 0xDA: return 1
        case 0x5A: return 1
        case 0xFA: return 1
        case 0x7A: return 1
        case 0x07: return 2
        case 0x17: return 2
        case 0x27: return 2
        case 0x37: return 2
        case 0x47: return 2
        case 0x57: return 2
        case 0x67: return 2
        case 0x77: return 2
        case 0x87: return 2
        case 0x97: return 2
        case 0xA7: return 2
        case 0xB7: return 2
        case 0xC7: return 2
        case 0xD7: return 2
        case 0xE7: return 2
        case 0xF7: return 2
        case 0xDB: return 1
        case 0x64: return 2
        case 0x74: return 2
        case 0x9C: return 3
        case 0x9E: return 3
        case 0x1C: return 3
        case 0x14: return 2
        case 0x0C: return 3
        case 0x04: return 2
        case 0xCB: return 1
        default: return 1
        }
    }
}

extension CPU6502 {
    func loadOper() -> UInt8 { load(absolute: pc &+ 1) }
    func loadOperWide() -> UInt16 { UInt16(high: load(absolute: pc &+ 2), low: load(absolute: pc &+ 1)) }
    
    mutating func execute() {
        let opcode = load(absolute: pc)
        let instruction = Instruction(rawValue: opcode)!
        switch instruction {
        case .BRK_impl: executeBRK()
        case .ORA_XInd: executeORA(preIndirectX: loadOperWide())
        case .NOP02: executeNOP()
        case .NOP03: executeNOP()
        case .TSB_zpg: executeTSB(zeropage: loadOper())
        case .ORA_zpg: executeORA(zeropage: loadOper())
        case .ASL_zpg: executeASL(zeropage: loadOper())
        case .RMB0_zpg: executeRMB0(zeropage: loadOper())
        case .PHP_impl: executePHP()
        case .ORA_imm: executeORA(immediate: loadOper())
        case .ASL_AC: executeASL()
        case .NOP0B: executeNOP()
        case .TSB_abs: executeTSB(absolute: loadOperWide())
        case .ORA_abs: executeORA(absolute: loadOperWide())
        case .ASL_abs: executeASL(absolute: loadOperWide())
        case .BBR0_rel: executeBBR0(relative: loadOper())
        case .BPL_rel: executeBPL(relative: loadOper())
        case .ORA_indY: executeORA(postIndirectY: loadOperWide())
        case .ORA_zpgi: executeORA(zeropageIndirect: loadOper())
        case .NOP13: executeNOP()
        case .TRB_zpg: executeTRB(zeropage: loadOper())
        case .ORA_zpgX: executeORA(zeropageX: loadOper())
        case .ASL_zpgX: executeASL(zeropageX: loadOper())
        case .RMB1_zpg: executeRMB1(zeropage: loadOper())
        case .CLC_impl: executeCLC()
        case .ORA_absY: executeORA(absoluteY: loadOperWide())
        case .INC_AC: executeINC()
        case .NOP1B: executeNOP()
        case .TRB_abs: executeTRB(absolute: loadOperWide())
        case .ORA_absX: executeORA(absoluteX: loadOperWide())
        case .ASL_absX: executeASL(absoluteX: loadOperWide())
        case .BBR1_rel: executeBBR1(relative: loadOper())
        case .JSR_abs: executeJSR(absolute: loadOperWide())
        case .AND_XInd: executeAND(preIndirectX: loadOperWide())
        case .NOP22: executeNOP()
        case .NOP23: executeNOP()
        case .BIT_zpg: executeBIT(zeropage: loadOper())
        case .AND_zpg: executeAND(zeropage: loadOper())
        case .ROL_zpg: executeROL(zeropage: loadOper())
        case .RMB2_zpg: executeRMB2(zeropage: loadOper())
        case .PLP_impl: executePLP()
        case .AND_imm: executeAND(immediate: loadOper())
        case .ROL_AC: executeROL()
        case .NOP2B: executeNOP()
        case .BIT_abs: executeBIT(absolute: loadOperWide())
        case .AND_abs: executeAND(absolute: loadOperWide())
        case .ROL_abs: executeROL(absolute: loadOperWide())
        case .BBR2_rel: executeBBR2(relative: loadOper())
        case .BMI_rel: executeBMI(relative: loadOper())
        case .AND_indY: executeAND(postIndirectY: loadOperWide())
        case .AND_zpgi: executeAND(zeropageIndirect: loadOper())
        case .NOP33: executeNOP()
        case .BIT_zpgX: executeBIT(zeropageX: loadOper())
        case .AND_zpgX: executeAND(zeropageX: loadOper())
        case .ROL_zpgX: executeROL(zeropageX: loadOper())
        case .RMB3_zpg: executeRMB3(zeropage: loadOper())
        case .SEC_impl: executeSEC()
        case .AND_absY: executeAND(absoluteY: loadOperWide())
        case .DEC_AC: executeDEC()
        case .NOP3B: executeNOP()
        case .BIT_absX: executeBIT(absoluteX: loadOperWide())
        case .AND_absX: executeAND(absoluteX: loadOperWide())
        case .ROL_absX: executeROL(absoluteX: loadOperWide())
        case .BBR3_rel: executeBBR3(relative: loadOper())
        case .RTI_impl: executeRTI()
        case .EOR_XInd: executeEOR(preIndirectX: loadOperWide())
        case .NOP42: executeNOP()
        case .NOP43: executeNOP()
        case .NOP44: executeNOP()
        case .EOR_zpg: executeEOR(zeropage: loadOper())
        case .LSR_zpg: executeLSR(zeropage: loadOper())
        case .RMB4_zpg: executeRMB4(zeropage: loadOper())
        case .PHA_impl: executePHA()
        case .EOR_imm: executeEOR(immediate: loadOper())
        case .LSR_AC: executeLSR()
        case .NOP4B: executeNOP()
        case .JMP_abs: executeJMP(absolute: loadOperWide())
        case .EOR_abs: executeEOR(absolute: loadOperWide())
        case .LSR_abs: executeLSR(absolute: loadOperWide())
        case .BBR4_rel: executeBBR4(relative: loadOper())
        case .BVC_rel: executeBVC(relative: loadOper())
        case .EOR_indY: executeEOR(postIndirectY: loadOperWide())
        case .EOR_zpgi: executeEOR(zeropageIndirect: loadOper())
        case .NOP53: executeNOP()
        case .NOP54: executeNOP()
        case .EOR_zpgX: executeEOR(zeropageX: loadOper())
        case .LSR_zpgX: executeLSR(zeropageX: loadOper())
        case .RMB5_zpg: executeRMB5(zeropage: loadOper())
        case .CLI_impl: executeCLI()
        case .EOR_absY: executeEOR(absoluteY: loadOperWide())
        case .PHY_impl: executePHY()
        case .NOP5B: executeNOP()
        case .NOP5C: executeNOP()
        case .EOR_absX: executeEOR(absoluteX: loadOperWide())
        case .LSR_absX: executeLSR(absoluteX: loadOperWide())
        case .BBR5_rel: executeBBR5(relative: loadOper())
        case .RTS_impl: executeRTS()
        case .ADC_XInd: executeADC(preIndirectX: loadOperWide())
        case .NOP62: executeNOP()
        case .NOP63: executeNOP()
        case .STZ_zpg: executeSTZ(zeropage: loadOper())
        case .ADC_zpg: executeADC(zeropage: loadOper())
        case .ROR_zpg: executeROR(zeropage: loadOper())
        case .RMB6_zpg: executeRMB6(zeropage: loadOper())
        case .PLA_impl: executePLA()
        case .ADC_imm: executeADC(immediate: loadOper())
        case .ROR_AC: executeROR()
        case .NOP6B: executeNOP()
        case .JMP_ind: executeJMP(indirect: loadOperWide())
        case .ADC_abs: executeADC(absolute: loadOperWide())
        case .ROR_abs: executeROR(absolute: loadOperWide())
        case .BBR6_rel: executeBBR6(relative: loadOper())
        case .BVS_rel: executeBVS(relative: loadOper())
        case .ADC_indY: executeADC(postIndirectY: loadOperWide())
        case .ADC_zpgi: executeADC(zeropageIndirect: loadOper())
        case .NOP73: executeNOP()
        case .STZ_zpgX: executeSTZ(zeropageX: loadOper())
        case .ADC_zpgX: executeADC(zeropageX: loadOper())
        case .ROR_zpgX: executeROR(zeropageX: loadOper())
        case .RMB7_zpg: executeRMB7(zeropage: loadOper())
        case .SEI_impl: executeSEI()
        case .ADC_absY: executeADC(absoluteY: loadOperWide())
        case .PLY_impl: executePLY()
        case .NOP7B: executeNOP()
        case .JMP_absXInd: executeJMP(absoluteXIndirect: loadOperWide())
        case .ADC_absX: executeADC(absoluteX: loadOperWide())
        case .ROR_absX: executeROR(absoluteX: loadOperWide())
        case .BBR7_rel: executeBBR7(relative: loadOper())
        case .BRA_rel: executeBRA(relative: loadOper())
        case .STA_XInd: executeSTA(preIndirectX: loadOperWide())
        case .NOP82: executeNOP()
        case .NOP83: executeNOP()
        case .STY_zpg: executeSTY(zeropage: loadOper())
        case .STA_zpg: executeSTA(zeropage: loadOper())
        case .STX_zpg: executeSTX(zeropage: loadOper())
        case .SMB0_zpg: executeSMB0(zeropage: loadOper())
        case .DEY_impl: executeDEY()
        case .BIT_imm: executeBIT(immediate: loadOper())
        case .TXA_impl: executeTXA()
        case .NOP8B: executeNOP()
        case .STY_abs: executeSTY(absolute: loadOperWide())
        case .STA_abs: executeSTA(absolute: loadOperWide())
        case .STX_abs: executeSTX(absolute: loadOperWide())
        case .BBS0_rel: executeBBS0(relative: loadOper())
        case .BCC_rel: executeBCC(relative: loadOper())
        case .STA_indY: executeSTA(postIndirectY: loadOperWide())
        case .STA_zpgi: executeSTA(zeropageIndirect: loadOper())
        case .NOP93: executeNOP()
        case .STY_zpgX: executeSTY(zeropageX: loadOper())
        case .STA_zpgX: executeSTA(zeropageX: loadOper())
        case .STX_zpgY: executeSTX(zeropageY: loadOper())
        case .SMB1_zpg: executeSMB1(zeropage: loadOper())
        case .TYA_impl: executeTYA()
        case .STA_absY: executeSTA(absoluteY: loadOperWide())
        case .TXS_impl: executeTXS()
        case .NOP9B: executeNOP()
        case .STZ_abs: executeSTZ(absolute: loadOperWide())
        case .STA_absX: executeSTA(absoluteX: loadOperWide())
        case .STZ_absX: executeSTZ(absoluteX: loadOperWide())
        case .BBS1_rel: executeBBS1(relative: loadOper())
        case .LDY_imm: executeLDY(immediate: loadOper())
        case .LDA_XInd: executeLDA(preIndirectX: loadOperWide())
        case .LDX_imm: executeLDX(immediate: loadOper())
        case .NOPA3: executeNOP()
        case .LDY_zpg: executeLDY(zeropage: loadOper())
        case .LDA_zpg: executeLDA(zeropage: loadOper())
        case .LDX_zpg: executeLDX(zeropage: loadOper())
        case .SMB2_zpg: executeSMB2(zeropage: loadOper())
        case .TAY_impl: executeTAY()
        case .LDA_imm: executeLDA(immediate: loadOper())
        case .TAX_impl: executeTAX()
        case .NOPAB: executeNOP()
        case .LDY_abs: executeLDY(absolute: loadOperWide())
        case .LDA_abs: executeLDA(absolute: loadOperWide())
        case .LDX_abs: executeLDX(absolute: loadOperWide())
        case .BBS2_rel: executeBBS2(relative: loadOper())
        case .BCS_rel: executeBCS(relative: loadOper())
        case .LDA_indY: executeLDA(postIndirectY: loadOperWide())
        case .LDA_zpgi: executeLDA(zeropageIndirect: loadOper())
        case .NOPB3: executeNOP()
        case .LDY_zpgX: executeLDY(zeropageX: loadOper())
        case .LDA_zpgX: executeLDA(zeropageX: loadOper())
        case .LDX_zpgY: executeLDX(zeropageY: loadOper())
        case .SMB3_zpg: executeSMB3(zeropage: loadOper())
        case .CLV_impl: executeCLV()
        case .LDA_absY: executeLDA(absoluteY: loadOperWide())
        case .TSX_impl: executeTSX()
        case .NOPBB: executeNOP()
        case .LDY_absX: executeLDY(absoluteX: loadOperWide())
        case .LDA_absX: executeLDA(absoluteX: loadOperWide())
        case .LDX_absY: executeLDX(absoluteY: loadOperWide())
        case .BBS3_rel: executeBBS3(relative: loadOper())
        case .CPY_imm: executeCPY(immediate: loadOper())
        case .CMP_XInd: executeCMP(preIndirectX: loadOperWide())
        case .NOPC2: executeNOP()
        case .NOPC3: executeNOP()
        case .CPY_zpg: executeCPY(zeropage: loadOper())
        case .CMP_zpg: executeCMP(zeropage: loadOper())
        case .DEC_zpg: executeDEC(zeropage: loadOper())
        case .SMB4_zpg: executeSMB4(zeropage: loadOper())
        case .INY_impl: executeINY()
        case .CMP_imm: executeCMP(immediate: loadOper())
        case .DEX_impl: executeDEX()
        case .WAI_impl: executeWAI()
        case .CPY_abs: executeCPY(absolute: loadOperWide())
        case .CMP_abs: executeCMP(absolute: loadOperWide())
        case .DEC_abs: executeDEC(absolute: loadOperWide())
        case .BBS4_rel: executeBBS4(relative: loadOper())
        case .BNE_rel: executeBNE(relative: loadOper())
        case .CMP_indY: executeCMP(postIndirectY: loadOperWide())
        case .CMP_zpgi: executeCMP(zeropageIndirect: loadOper())
        case .NOPD3: executeNOP()
        case .NOPD4: executeNOP()
        case .CMP_zpgX: executeCMP(zeropageX: loadOper())
        case .DEC_zpgX: executeDEC(zeropageX: loadOper())
        case .SMB5_zpg: executeSMB5(zeropage: loadOper())
        case .CLD_impl: executeCLD()
        case .CMP_absY: executeCMP(absoluteY: loadOperWide())
        case .PHX_impl: executePHX()
        case .STP_impl: executeSTP()
        case .NOPDC: executeNOP()
        case .CMP_absX: executeCMP(absoluteX: loadOperWide())
        case .DEC_absX: executeDEC(absoluteX: loadOperWide())
        case .BBS5_rel: executeBBS5(relative: loadOper())
        case .CPX_imm: executeCPX(immediate: loadOper())
        case .SBC_XInd: executeSBC(preIndirectX: loadOperWide())
        case .NOPE2: executeNOP()
        case .NOPE3: executeNOP()
        case .CPX_zpg: executeCPX(zeropage: loadOper())
        case .SBC_zpg: executeSBC(zeropage: loadOper())
        case .INC_zpg: executeINC(zeropage: loadOper())
        case .SMB6_zpg: executeSMB6(zeropage: loadOper())
        case .INX_impl: executeINX()
        case .SBC_imm: executeSBC(immediate: loadOper())
        case .NOP_impl: executeNOP()
        case .NOPEB: executeNOP()
        case .CPX_abs: executeCPX(absolute: loadOperWide())
        case .SBC_abs: executeSBC(absolute: loadOperWide())
        case .INC_abs: executeINC(absolute: loadOperWide())
        case .BBS6_rel: executeBBS6(relative: loadOper())
        case .BEQ_rel: executeBEQ(relative: loadOper())
        case .SBC_indY: executeSBC(postIndirectY: loadOperWide())
        case .SBC_zpgi: executeSBC(zeropageIndirect: loadOper())
        case .NOPF3: executeNOP()
        case .NOPF4: executeNOP()
        case .SBC_zpgX: executeSBC(zeropageX: loadOper())
        case .INC_zpgX: executeINC(zeropageX: loadOper())
        case .SMB7_zpg: executeSMB7(zeropage: loadOper())
        case .SED_impl: executeSED()
        case .SBC_absY: executeSBC(absoluteY: loadOperWide())
        case .PLX_impl: executePLX()
        case .NOPFB: executeNOP()
        case .NOPFC: executeNOP()
        case .SBC_absX: executeSBC(absoluteX: loadOperWide())
        case .INC_absX: executeINC(absoluteX: loadOperWide())
        case .BBS: executeNOP()
        }
        pc = pc &+ UInt16(CPU6502.instructionSize(opcode))
    }
}

// MARK: Conveniences

extension UInt16 {
    init(high: UInt8, low: UInt8) {
        self = (UInt16(high) << 8) &+ UInt16(low)
    }
}
