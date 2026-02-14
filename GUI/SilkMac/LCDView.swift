//
//  LCDView.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI
import SilkLCD
import SilkSystem

struct LCDView: View {
    @EnvironmentObject var system: System
    var body: some View {
        VStack {
            HStack {
                Text("IR")
                Text(String(format: "%02X", system.lcd.ir))
            }
            HStack {
                Text("DR")
                Text(String(format: "%02X", system.lcd.dr))
            }
            HStack {
                Text("AC")
                Text(String(format: "%02X", system.lcd.ac))
            }
            HStack {
                Text("ID")
                Text("S")
                Text("D")
                Text("C")
                Text("B")
                Text("SC")
                }
            HStack {
                Text(String(format: "%@", system.lcd.id ? "1" : "0"))
                Text(String(format: "%@", system.lcd.s ? "1" : "0"))
                Text(String(format: "%@", system.lcd.d ? "1" : "0"))
                Text(String(format: "%@", system.lcd.c ? "1" : "0"))
                Text(String(format: "%@", system.lcd.b ? "1" : "0"))
                Text(String(format: "%@", system.lcd.sc ? "1" : "0"))
            }
            HStack {
                Text("RL")
                Text("DL")
                Text("N")
                Text("F")
                Text("BUSY")
            }
            HStack {
                Text(String(format: "%@", system.lcd.rl ? "1" : "0"))
                Text(String(format: "%@", system.lcd.dl ? "1" : "0"))
                Text(String(format: "%@", system.lcd.n ? "1" : "0"))
                Text(String(format: "%@", system.lcd.f ? "1" : "0"))
                Text(String(format: "%@", system.lcd.busy ? "1" : "0"))
            }
            VStack {
                let lineLength = 40
                let attributes = AttributeContainer()
                    .foregroundColor(.white)
                    .backgroundColor(system.lcd.d ? .blue : .clear)
                    .font(.system(size: 8.0, design: .monospaced))
                let line0 = String(system.lcd.ddram[0..<lineLength].map { Character(Unicode.Scalar($0)) })
                Text(AttributedString(line0, attributes: attributes))
                if system.lcd.n {
                    let line1 = String(system.lcd.ddram[lineLength..<(lineLength*2)].map { Character(Unicode.Scalar($0)) })
                    Text(AttributedString(line1, attributes: attributes))
                }
            }
        }
    }
}
