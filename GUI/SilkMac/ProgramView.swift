//
//  ProgramView.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI
import SilkSystem
import SilkCPU

struct ProgramView: View {
    @EnvironmentObject var system: System
    @Binding var programDisassembly: [CPU6502.Operation]
    var body: some View {
        ScrollViewReader { proxy in
            Table(programDisassembly) {
                TableColumn("BP") { operation in
                    Toggle(
                        isOn: .init(
                            get: {
                                system.breakpoints.contains(operation.address)
                            },
                            set: { isOn in
                                if isOn {
                                    system.breakpoints.insert(operation.address)
                                } else {
                                    system.breakpoints.remove(operation.address)
                                }
                                system.objectWillChange.send()
                            }
                        ),
                        label: { Text("") }
                    )
                }
                .width(22.0)
                TableColumn("Addr") {
                    Text(String(format: "%04X\($0.address == system.cpu.pc ? "*" : "")", $0.address))
                }
                .width(44.0)
                TableColumn("Inst") {
                    Text($0.instruction.name)
                }
                .width(40.0)
                TableColumn("OL") {
                    Text($0.oper.map { String(format: "%02X", $0) } ?? "--")
                }
                .width(22.0)
                TableColumn("OH") {
                    Text($0.operWideHigh.map { String(format: "%02X", $0) } ?? "--")
                }
                .width(22.0)
                TableColumn("Symbols") {
                    Text($0.symbols.joined(separator: " "))
                }
            }
            .onChange(of: system.cpu.pc) { newValue, _ in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
}

extension CPU6502.Operation: @retroactive Identifiable {
    public var id: Int { Int(address) }
}
