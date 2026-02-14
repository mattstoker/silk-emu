//
//  VIAView.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI
import SilkVIA
import SilkSystem

struct VIAView: View {
    @EnvironmentObject var system: System
    var body: some View {
        VStack {
            HStack {
                Text("PA")
                Text(String(format: "%02X", system.via.pa))
            }
            HStack {
                Text("PB")
                Text(String(format: "%02X", system.via.pb))
            }
            HStack {
                Text("DDRA")
                Text(String(format: "%02X", system.via.ddra))
            }
            HStack {
                Text("DDRB")
                Text(String(format: "%02X", system.via.ddrb))
            }
            HStack {
                Text("SR")
                Text(String(format: "%02X", system.via.sr))
            }
            HStack {
                Text("ACR")
                Text(String(format: "%02X", system.via.acr))
            }
            HStack {
                Text("PCR")
                Text(String(format: "%02X", system.via.pcr))
            }
            HStack {
                Text("IFR")
                Text(String(format: "%02X", system.via.ifr))
            }
            HStack {
                Text("IER")
                Text(String(format: "%02X", system.via.ier))
            }
            HStack {
                Text("T1C")
                Text(String(format: "%04X", system.via.t1c))
            }
            HStack {
                Text("T1L")
                Text(String(format: "%04X", system.via.t1l))
            }
            HStack {
                Text("T2C")
                Text(String(format: "%04X", system.via.t2c))
            }
            HStack {
                Text("T2L")
                Text(String(format: "%04X", system.via.t2l))
            }
        }
    }
}
