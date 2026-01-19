//
//  RAMHM62256.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/18/26.
//

// MARK: RAM State & Equality

public struct RAMHM62256: Hashable {
    public static let size = 0x4000
    public private(set) var memory: [UInt8] = Array(repeating: .zero, count: RAMHM62256.size)
    
    public init() { }
    
    public func load(_ address: UInt16) -> UInt8 {
        let addressResolved = Int(address % UInt16(Self.size))
        return memory[addressResolved]
    }
    
    public mutating func store(_ address: UInt16, _ value: UInt8) {
        let addressResolved = Int(address % UInt16(Self.size))
         memory[addressResolved] = value
    }
}
