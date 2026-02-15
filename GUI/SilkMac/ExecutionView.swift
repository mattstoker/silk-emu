//
//  ExecutionView.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI
import SilkCPU
import SilkSystem

struct ExecutionView: View {
    @EnvironmentObject var system: System
    @State var programImporterShowing = false
    @State var programFile: URL?
    @State var programOffset: Int = 0xE000
    @Binding var programDisassembly: [CPU6502.Operation]
    
    @State var stepCount: Int? = nil
    @State var stepTimer: Timer? = nil
    @State var breakpoint: UInt16? = nil
    
    var body: some View {
        switch system.cpu.state {
        case .boot, .stop:
            HStack {
                Button(
                    action: { programImporterShowing = true },
                    label: { Text("Load Program to 0x") }
                )
                TextField("Program", value: $programOffset, format: .hex)
                    .frame(width: 50)
            }
            .fileImporter(isPresented: $programImporterShowing, allowedContentTypes: [.data]) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let url):
                    programFile = url
                    guard let programData = try? Data(contentsOf: url) else {
                        print("Couldn't open program \(url)")
                        return
                    }
                    
                    let (program, disassembly) = Self.parse(programData)
                    programDisassembly = disassembly ?? CPU6502.disassemble(program: program, offset: UInt16(programOffset))
                    system.program(data: program, startingAt: UInt16(programOffset))
                    system.executePublished()
                }
            }
        case .run:
            if stepTimer == nil {
                HStack {
                    Button(
                        action: {
                            if let breakpoint = breakpoint {
                                system.executePublished(until: breakpoint)
                            } else {
                                stepTimer = Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: true) { _ in
                                    system.executePublished()
                                }
                            }
                        },
                        label: { Text("Run\(breakpoint == nil ? "" : " until 0x")") }
                    )
                    TextField("Break", value: $breakpoint, format: .hex)
                        .frame(width: 50)
                }
                HStack {
                    Button(
                        action: {
                            system.executePublished(count: stepCount ?? 1)
                        },
                        label: { Text("Step\(stepCount == nil ? "" : " 0x")") }
                    )
                    TextField("Steps", value: $stepCount, format: .hex)
                        .frame(width: 50)
                }
                HStack {
                    Button(
                        action: {
                            system.executePublished(upTo: CPU6502.Instruction.JSR_abs.opcode)
                        },
                        label: { Text("Step Until Next JSR") }
                    )
                }
                HStack {
                    Button(
                        action: {
                            system.executePublished(upTo: CPU6502.Instruction.RTS_impl.opcode)
                            system.executePublished()
                        },
                        label: { Text("Step After Next RTS") }
                    )
                }
                Button(
                    action: {
                        system.reset()
                        system.objectWillChange.send()
                        programDisassembly = []
                    },
                    label: { Text("Reset") }
                )
            } else {
                Button(
                    action: {
                        stepTimer?.invalidate()
                        stepTimer = nil
                    },
                    label: { Text("Pause") }
                )
            }
        case .wait:
            Button(
                action: { system.cpu.resume() },
                label: { Text("Resume") }
            )
        }
    }
}

extension ExecutionView {
    static func parse(_ programData: Data) -> (program: [UInt8], disassembly: [CPU6502.Operation]?) {
        // Examine header of program data
        let symbolicatedProgramHeader = "Sections:".utf8.map { UInt8($0) }
        var programHeader: [UInt8] = Array(repeating: 0x00, count: symbolicatedProgramHeader.count)
        programData.copyBytes(to: &programHeader, count: min(programHeader.count, programData.count))
        
        // Based on the program header, parse the program
        let program: [UInt8]
        let disassembly: [CPU6502.Operation]?
        if programHeader == symbolicatedProgramHeader {
            // Parse symbolicated program
            let source = String(data: programData, encoding: .utf8) ?? ""
            let lines = source
                .replacing("\r\n", with: "\n")
                .split(separator: "\n", omittingEmptySubsequences: true)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            let operationRegex = try! Regex("([1-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]): data\\(([0-9])\\): ([^\\n]+)")
            let symbolRegex = try! Regex("([1-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]): symbol: ([^ ]+)")
            var operations: [UInt16: CPU6502.Operation] = [:]
            var symbols: [UInt16: String] = [:]
            for line in lines {
                for operationMatch in line.matches(of: operationRegex) {
                    guard let address = operationMatch[1].substring.map({ UInt16($0, radix: 16) }) ?? nil,
                          let instructionLength = operationMatch[2].substring.map({ Int($0, radix: 16) }) ?? nil,
                          let instructionData = operationMatch[3].substring?.split(separator: " ") else {
                        continue
                    }
                    let instructionBytes = instructionData.compactMap { UInt8($0, radix: 16) }
                    guard instructionLength >= 1,
                          instructionBytes.count == instructionLength,
                          let instruction = CPU6502.Instruction(rawValue: instructionBytes[0]) else {
                        continue
                    }
                    let operation = CPU6502.Operation(
                        address: address,
                        instruction: instruction,
                        oper: instructionBytes.count > 1 ? instructionBytes[1] : nil,
                        operWideHigh: instructionBytes.count > 2 ? instructionBytes[2] : nil
                    )
                    operations[address] = operation
                }
                for symbolMatch in line.matches(of: symbolRegex) {
                    guard let address = symbolMatch[1].substring.map({ UInt16($0, radix: 16) }) ?? nil,
                          let symbol = symbolMatch[2].substring else {
                        continue
                    }
                    symbols[address] = String(symbol)
                }
            }
            disassembly = Array(operations.values).sorted { $0.address < $1.address }
            program = disassembly!.flatMap {
                [$0.instruction.rawValue, $0.oper, $0.operWideHigh].compactMap { $0 }
            }
        } else {
            // Read the program data directly as a binary program
            var programBytes = Array(repeating: UInt8(0x00), count: programData.count)
            programData.copyBytes(to: &programBytes, count: min(programBytes.count, programData.count))
            program = programBytes
            disassembly = nil
        }
        return (program: program, disassembly: disassembly)
    }
}
