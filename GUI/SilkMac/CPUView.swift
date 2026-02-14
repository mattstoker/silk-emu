//
//  CPUView.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI
import SilkCPU
import SilkSystem

struct CPUView: View {
    @EnvironmentObject var system: System
    var body: some View {
        VStack {
            HStack {
                Text("PC")
                Text(String(format: "%04X", system.cpu.pc))
            }
            HStack {
                Text("AC")
                Text(String(format: "%02X", system.cpu.ac))
            }
            HStack {
                Text("XR")
                Text(String(format: "%02X", system.cpu.xr))
            }
            HStack {
                Text("YR")
                Text(String(format: "%02X", system.cpu.yr))
            }
            HStack {
                Text("SR")
                Text(String(format: "%02X", system.cpu.sr))
            }
            HStack {
                Text("SP")
                Text(String(format: "%02X", system.cpu.sp))
            }
            HStack {
                Text("State")
                Text(String(describing: system.cpu.state))
            }
        }
    }
}
