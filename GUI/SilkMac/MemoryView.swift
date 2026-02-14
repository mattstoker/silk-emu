//
//  MemoryView.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI
import SilkSystem

struct MemoryView: View {
    @EnvironmentObject var system: System
    var body: some View {
        Table((0x0000...0xFFFF).map { MemoryEntry(address: UInt16($0), value: system.cpu.load(UInt16($0))) }) {
            TableColumn("Addr") {
                Text(String(format: "%04X", $0.address))
            }
            .width(40.0)
            TableColumn("D") {
                Text(String(format: "%02X", $0.value))
            }
            .width(20.0)
        }
        .frame(width: 130.0)
    }
}

extension MemoryView {
    struct MemoryEntry: Identifiable {
        var address: UInt16
        var value: UInt8
        var id: Int { Int(address) }
    }
}
