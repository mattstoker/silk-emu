//
//  CPU6502+InstructionCycles.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/30/26.
//

// MARK: - Opcodes

extension CPU6502 {
    public enum Instruction: UInt8 {
        public var opcode: UInt8 {
            return rawValue
        }
        
        public var name: String {
            let description = String(describing: self)
            let endIndex = description.index(description.startIndex, offsetBy: 3)
            return String(description[..<endIndex])
        }
        
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
}

// MARK: - Sizes

extension CPU6502.Instruction {
    public var size: UInt8 {
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

// MARK: - Cycles

extension CPU6502.Instruction {
    public var cycles: UInt8 {
        switch opcode {
        case 0x69: return 2
        case 0x65: return 3
        case 0x75: return 4
        case 0x6D: return 4
        case 0x7D: return 4 //*
        case 0x79: return 4 //*
        case 0x61: return 6
        case 0x71: return 5 //*
        case 0x29: return 2
        case 0x25: return 3
        case 0x35: return 4
        case 0x2D: return 4
        case 0x3D: return 4 //*
        case 0x39: return 4 //*
        case 0x21: return 6
        case 0x31: return 5 //*
        case 0x0A: return 2
        case 0x06: return 5
        case 0x16: return 6
        case 0x0E: return 6
        case 0x1E: return 7
        case 0x90: return 2 //**
        case 0xB0: return 2 //**
        case 0xF0: return 2 //**
        case 0x24: return 3
        case 0x2C: return 4
        case 0x30: return 2 //**
        case 0xD0: return 2 //**
        case 0x10: return 2 //**
        case 0x00: return 7
        case 0x50: return 2 //**
        case 0x70: return 2 //**
        case 0x18: return 2
        case 0xD8: return 2
        case 0x58: return 2
        case 0xB8: return 2
        case 0xC9: return 2
        case 0xC5: return 3
        case 0xD5: return 4
        case 0xCD: return 4
        case 0xDD: return 4 //*
        case 0xD9: return 4 //*
        case 0xC1: return 6
        case 0xD1: return 5 //*
        case 0xE0: return 2
        case 0xE4: return 3
        case 0xEC: return 4
        case 0xC0: return 2
        case 0xC4: return 3
        case 0xCC: return 4
        case 0xC6: return 5
        case 0xD6: return 6
        case 0xCE: return 6
        case 0xDE: return 7
        case 0xCA: return 2
        case 0x88: return 2
        case 0x49: return 2
        case 0x45: return 3
        case 0x55: return 4
        case 0x4D: return 4
        case 0x5D: return 4 //*
        case 0x59: return 4 //*
        case 0x41: return 6
        case 0x51: return 5 //*
        case 0xE6: return 5
        case 0xF6: return 6
        case 0xEE: return 6
        case 0xFE: return 7
        case 0xE8: return 2
        case 0xC8: return 2
        case 0x4C: return 3
        case 0x6C: return 5 //***
        case 0x20: return 6
        case 0xA9: return 2
        case 0xA5: return 3
        case 0xB5: return 4
        case 0xAD: return 4
        case 0xBD: return 4 //*
        case 0xB9: return 4 //*
        case 0xA1: return 6
        case 0xB1: return 5 //*
        case 0xA2: return 2
        case 0xA6: return 3
        case 0xB6: return 4
        case 0xAE: return 4
        case 0xBE: return 4 //*
        case 0xA0: return 2
        case 0xA4: return 3
        case 0xB4: return 4
        case 0xAC: return 4
        case 0xBC: return 4 //*
        case 0x4A: return 2
        case 0x46: return 5
        case 0x56: return 6
        case 0x4E: return 6
        case 0x5E: return 7
        case 0xEA: return 2
        case 0x09: return 2
        case 0x05: return 3
        case 0x15: return 4
        case 0x0D: return 4
        case 0x1D: return 4 //*
        case 0x19: return 4 //*
        case 0x01: return 6
        case 0x11: return 5 //*
        case 0x48: return 3
        case 0x08: return 3
        case 0x68: return 4
        case 0x28: return 4
        case 0x2A: return 2
        case 0x26: return 5
        case 0x36: return 6
        case 0x2E: return 6
        case 0x3E: return 7
        case 0x6A: return 2
        case 0x66: return 5
        case 0x76: return 6
        case 0x6E: return 6
        case 0x7E: return 7
        case 0x40: return 6
        case 0x60: return 6
        case 0xE9: return 2
        case 0xE5: return 3
        case 0xF5: return 4
        case 0xED: return 4
        case 0xFD: return 4 //*
        case 0xF9: return 4 //*
        case 0xE1: return 6
        case 0xF1: return 5 //*
        case 0x38: return 2
        case 0xF8: return 2
        case 0x78: return 2
        case 0x85: return 3
        case 0x95: return 4
        case 0x8D: return 4
        case 0x9D: return 5
        case 0x99: return 5
        case 0x81: return 6
        case 0x91: return 6
        case 0x86: return 3
        case 0x96: return 4
        case 0x8E: return 4
        case 0x84: return 3
        case 0x94: return 4
        case 0x8C: return 4
        case 0xAA: return 2
        case 0xA8: return 2
        case 0xBA: return 2
        case 0x8A: return 2
        case 0x9A: return 2
        case 0x98: return 2
        case 0x72: return 5
        case 0x32: return 5
        case 0x89: return 2
        case 0x3C: return 4 //*
        case 0x34: return 4
        case 0xD2: return 5
        case 0x3A: return 2
        case 0x52: return 5
        case 0x1A: return 2
        case 0x7C: return 6
        case 0xB2: return 5
        case 0x12: return 5
        case 0xF2: return 5
        case 0x92: return 5
        case 0x0F: return 5 //**
        case 0x1F: return 5 //**
        case 0x2F: return 5 //**
        case 0x3F: return 5 //**
        case 0x4F: return 5 //**
        case 0x5F: return 5 //**
        case 0x6F: return 5 //**
        case 0x7F: return 5 //**
        case 0x8F: return 5 //**
        case 0x9F: return 5 //**
        case 0xAF: return 5 //**
        case 0xBF: return 5 //**
        case 0xCF: return 5 //**
        case 0xDF: return 5 //**
        case 0xEF: return 5 //**
        case 0xFF: return 5 //**
        case 0x80: return 3 //*
        case 0xDA: return 3
        case 0x5A: return 3
        case 0xFA: return 4
        case 0x7A: return 4
        case 0x07: return 5
        case 0x17: return 5
        case 0x27: return 5
        case 0x37: return 5
        case 0x47: return 5
        case 0x57: return 5
        case 0x67: return 5
        case 0x77: return 5
        case 0x87: return 5
        case 0x97: return 5
        case 0xA7: return 5
        case 0xB7: return 5
        case 0xC7: return 5
        case 0xD7: return 5
        case 0xE7: return 5
        case 0xF7: return 5
        case 0xDB: return 3
        case 0x64: return 3
        case 0x74: return 4
        case 0x9C: return 4
        case 0x9E: return 4 //*
        case 0x1C: return 6
        case 0x14: return 5
        case 0x0C: return 6
        case 0x04: return 5
        case 0xCB: return 3
        default: return 2
        }
    }
}
