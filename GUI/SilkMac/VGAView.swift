//
//  VGAView.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI
import SilkSystem

struct VGAView: View {
    @EnvironmentObject var system: System
    @State var videoStart: UInt16? = 0x2000
    @State var videoEnd: UInt16? = 0x4000
    @State var videoLine: UInt16? = 0x80
    var body: some View {
        HStack {
            Text("Start 0x")
            TextField("Start", value: $videoStart, format: .hex).frame(width: 50)
            Text("End 0x")
            TextField("End", value: $videoEnd, format: .hex).frame(width: 50)
            Text("Line 0x")
            TextField("Line", value: $videoLine, format: .hex).frame(width: 50)
        }
        if let start = videoStart, let end = videoEnd, let line = videoLine {
            let screenshot = system.screenshot(start: start, end: end, line: line)
            Image(nsImage: screenshot)
                .interpolation(.none)
                .resizable(resizingMode: .stretch)
                .frame(idealWidth: screenshot.size.width * 16, idealHeight: screenshot.size.height * 16)
                .aspectRatio(contentMode: .fit)
        }
    }
}

extension System {
    func screenshot(start: UInt16, end: UInt16, line: UInt16) -> NSImage {
        let ppm = memoryPPM(start: start, end: end, line: line)
        let image = NSImage(data: ppm.data(using: .utf8)!)!
        return image
    }
}
