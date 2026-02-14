//
//  HexFormatter.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI

public struct HexFormatter<T>: ParseableFormatStyle where T: FixedWidthInteger {
    public func format(_ value: T) -> String {
        String(value, radix: 16).uppercased()
    }
    
    public struct Strategy: SwiftUI.ParseStrategy {
        public func parse(_ value: String) throws -> T {
            guard let result = T(value, radix: 16) else { throw Error.conversionError }
            return result
        }
        
        public enum Error: Swift.Error {
            case conversionError
        }
        
        public typealias ParseInput = String
        public typealias ParseOutput = T
    }
    
    public typealias FormatInput = Strategy.ParseOutput
    public typealias FormatOutput = Strategy.ParseInput
    
    public var parseStrategy: Strategy { Strategy() }
}

extension FormatStyle where Self == IntegerFormatStyle<UInt> {
    public static var hex: HexFormatter<UInt> { HexFormatter<UInt>() }
}
extension FormatStyle where Self == IntegerFormatStyle<UInt8> {
    public static var hex: HexFormatter<UInt8> { HexFormatter<UInt8>() }
}
extension FormatStyle where Self == IntegerFormatStyle<UInt16> {
    public static var hex: HexFormatter<UInt16> { HexFormatter<UInt16>() }
}
extension FormatStyle where Self == IntegerFormatStyle<UInt32> {
    public static var hex: HexFormatter<UInt32> { HexFormatter<UInt32>() }
}
extension FormatStyle where Self == IntegerFormatStyle<UInt64> {
    public static var hex: HexFormatter<UInt64> { HexFormatter<UInt64>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int> {
    public static var hex: HexFormatter<Int> { HexFormatter<Int>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int8> {
    public static var hex: HexFormatter<Int8> { HexFormatter<Int8>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int16> {
    public static var hex: HexFormatter<Int16> { HexFormatter<Int16>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int32> {
    public static var hex: HexFormatter<Int32> { HexFormatter<Int32>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int64> {
    public static var hex: HexFormatter<Int64> { HexFormatter<Int64>() }
}
