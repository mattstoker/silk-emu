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
    
    @State var stepTimer: Timer? = nil
    
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
                    
                    let (program, disassembly) = Self.parse(programData, programOffset: UInt16(programOffset))
                    programDisassembly = disassembly
                    system.program(data: program, startingAt: UInt16(programOffset))
                    system.executePublished()
                }
            }
        case .run:
            if let programName = programFile?.lastPathComponent {
                Text(programName)
            }
            if stepTimer == nil {
                HStack {
                    Button(
                        action: {
                            if system.breakpoints.isEmpty {
                                stepTimer = Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: true) { _ in
                                    system.executePublished()
                                }
                            } else {
                                system.runPublished()
                            }
                        },
                        label: { Text("Run\(system.breakpoints.isEmpty ? "" : " to breakpoint(s)")") }
                    )
                }
                HStack {
                    Button(
                        action: {
                            system.executePublished()
                        },
                        label: { Text("Step") }
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
    static func parse(_ programData: Data, programOffset: UInt16) -> (program: [UInt8], disassembly: [CPU6502.Operation]) {
        // Examine header of program data
        let symbolicatedProgramHeader = "Sections:".utf8.map { UInt8($0) }
        var programHeader: [UInt8] = Array(repeating: 0x00, count: symbolicatedProgramHeader.count)
        programData.copyBytes(to: &programHeader, count: min(programHeader.count, programData.count))
        
        // Based on the program header, parse the program
        let program: [UInt8]
        let disassembly: [CPU6502.Operation]
        if programHeader == symbolicatedProgramHeader {
            // Parse symbolicated program
            let source = String(data: programData, encoding: .utf8) ?? ""
            let lines = source
                .replacing("\r\n", with: "\n")
                .split(separator: "\n", omittingEmptySubsequences: true)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            let dataRegex = try! Regex("([1-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]): data\\(([1-9][0-9]?)\\): ([^\\n]+)")
            let symbolRegex = try! Regex("([1-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]): symbol: ([^ ]+)")
            var data: [UInt16: UInt8] = [:]
            var symbols: [(address: UInt16, symbol: String)] = []
            for line in lines {
                for dataMatch in line.matches(of: dataRegex) {
                    guard let address = dataMatch[1].substring.map({ UInt16($0, radix: 16) }) ?? nil,
                          let dataLength = dataMatch[2].substring.map({ Int($0) }) ?? nil,
                          let dataBytesHex = dataMatch[3].substring?.split(separator: " ") else {
                        continue
                    }
                    let dataBytes = dataBytesHex.compactMap { UInt8($0, radix: 16) }
                    guard dataBytes.count == dataLength else {
                        continue
                    }
                    for index in 0..<dataLength where Int(address) + index < Int(UInt16.max) {
                        data[address + UInt16(index)] = dataBytes[index]
                    }
                }
                for symbolMatch in line.matches(of: symbolRegex) {
                    guard let address = symbolMatch[1].substring.map({ UInt16($0, radix: 16) }) ?? nil,
                          let symbol = symbolMatch[2].substring else {
                        continue
                    }
                    symbols.append((address: address, symbol: String(symbol)))
                }
            }
            
            // Interpret the data as a program, honoring the requested offset
            program = {
                var programBytes = Array(repeating: UInt8(0x00), count: Int(UInt16.max) - Int(programOffset))
                for (address, byte) in data {
                    programBytes[Int(address - programOffset)] = byte
                }
                return programBytes
            }()
            
            // Disassemble program, then combine operations and symbols
            disassembly = {
                var operations: [UInt16: CPU6502.Operation] = [:]
                for operation in CPU6502.disassemble(program: program, offset: programOffset) {
                    operations[operation.address] = operation
                }
                for (address, symbol) in symbols {
                    guard let operation = operations[address] else { continue }
                    var operationSymbols = operation.symbols
                    operationSymbols.append(symbol)
                    operations[address] = .init(
                        address: operation.address,
                        instruction: operation.instruction,
                        oper: operation.oper,
                        operWideHigh: operation.operWideHigh,
                        symbols: operationSymbols
                    )
                }
                return operations.values.sorted { $0.address < $1.address }
            }()
        } else {
            // Read the program data directly as a binary program
            var programBytes = Array(repeating: UInt8(0x00), count: programData.count)
            programData.copyBytes(to: &programBytes, count: min(programBytes.count, programData.count))
            program = programBytes
            disassembly = CPU6502.disassemble(program: program, offset: UInt16(programOffset))
        }
        return (program: program, disassembly: disassembly)
    }
}
