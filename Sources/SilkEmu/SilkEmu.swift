// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SilkCPU

@main
struct SilkEmu: ParsableCommand {
    @Argument()
    var programFile: String
    
    @Option
    var programOffset: Int = 0
    
    @Flag
    var printState: Bool = false
    
    mutating func run() throws {
        let programData = try Data(contentsOf: URL(fileURLWithPath: programFile))
        var program: [UInt8] = Array(repeating: 0x00, count: programData.count)
        programData.copyBytes(to: &program, count: min(program.count, programData.count))
        
        var memory = Array(repeating: UInt8(0xEA), count: 0x10000)
        for index in program.indices {
            memory[programOffset + index] = program[index]
        }
        
        var cpu = CPU6502(
            load: { address in memory[Int(address)] },
            store: { address, value in memory[Int(address)] = value }
        )
        while true {
            if printState {
                print("\(cpu.debugDescription)")
            }
            cpu.execute()
        }
    }
}
