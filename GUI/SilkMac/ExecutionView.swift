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
                    var program: [UInt8] = Array(repeating: 0x00, count: programData.count)
                    programData.copyBytes(to: &program, count: min(program.count, programData.count))
                    
                    programDisassembly = CPU6502.disassemble(program: program, offset: UInt16(programOffset))
                    
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
