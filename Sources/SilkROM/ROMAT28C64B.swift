//
//  ROMAT28C64B.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/18/26.
//
//  Official documentation for the HM62256 can be found at:
//  https://ww1.microchip.com/downloads/en/DeviceDoc/doc0270.pdf
//

// MARK: ROM State & Equality

public struct ROMAT28C64B: Hashable {
    public static let size = 0x2000
    public private(set) var memory: [UInt8] = Array(repeating: .zero, count: ROMAT28C64B.size)
    
    public init() { }
    
    public func load(_ address: UInt16) -> UInt8 {
        let addressResolved = Int(address % UInt16(Self.size))
        return memory[addressResolved]
    }
    
    public mutating func program<S: Collection>(data: S, startingAt offset: UInt16 = 0) where S.Element == UInt8, S.Index == Int {
        for dataIndex in data.indices {
            let memoryIndex = Int(offset + UInt16(dataIndex))
            guard memoryIndex < Self.size else {
                continue
            }
            memory[memoryIndex] = data[dataIndex]
        }
    }
}
