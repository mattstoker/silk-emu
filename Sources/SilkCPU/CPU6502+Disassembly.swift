//
//  CPU6502+Disassembly.swift
//  SilkEmu
//
//  Created by Matt Stoker on 2/7/26.
//

extension CPU6502 {
    public struct Operation: Hashable {
        public let address: UInt16
        public let instruction: Instruction
        public let oper: UInt8?
        public let operWideHigh: UInt8?
        
        public init(address: UInt16, instruction: Instruction, oper: UInt8? = nil, operWideHigh: UInt8? = nil) {
            self.address = address
            self.instruction = instruction
            self.oper = oper
            self.operWideHigh = operWideHigh
        }
    }
    
    public static func disassemble(program: [UInt8], offset: UInt16 = 0) -> [Operation] {
        var operations: [Operation] = []
        var address: UInt16 = offset
        while program.indices.contains(Int(address - offset)) {
            var cpu = CPU6502(
                pc: UInt16(address),
                state: .run,
                load: { program.indices.contains(Int($0) - Int(offset)) ? program[Int($0) - Int(offset)] : 0 }
            )
            let (instruction, oper, operWideHigh) = cpu.execute()
            operations.append(Operation(address: address, instruction: instruction, oper: oper, operWideHigh: operWideHigh))
            
            let nextAddress = Int(address) + Int(instruction.size)
            guard nextAddress > address,
                  program.indices.contains(nextAddress - Int(offset)),
                  (Int(UInt16.min)...Int(UInt16.max)).contains(nextAddress) else {
                break
            }
            address = UInt16(nextAddress)
        }
        return operations
    }
}
