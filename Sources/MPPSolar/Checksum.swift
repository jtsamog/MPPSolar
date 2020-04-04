//
//  Checksum.swift
//  
//
//  Created by Alsey Coleman Miller on 4/4/20.
//

import Foundation
import CMPPSolar

/// Checksum
public struct Checksum: RawRepresentable, Equatable, Hashable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

public extension Checksum {
    
    init(calculate data: Data) {
        guard data.isEmpty == false else {
            self = 0
            return
        }
        let value = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            mppsolar_crc(
                UnsafeMutablePointer(mutating: buffer.baseAddress!.assumingMemoryBound(to: UInt8.self)),
                UInt8(buffer.count)
            )
        }
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension Checksum: CustomStringConvertible {
    
    public var description: String {
        return "0x" + rawValue.toHexadecimal()
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Checksum: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}

// MARK: - Data

public extension Checksum {
    
    internal static var length: Int { return MemoryLayout<RawValue>.size }
    
    init?(data: Data) {
        guard data.count == type(of: self).length
            else { return nil }
        self.init(rawValue: UInt16(bigEndian: UInt16(bytes: (data[0], data[1]))))
    }
    
    var data: Data {
        return Data(self)
    }
}

// MARK: - DataConvertible

extension Checksum: DataConvertible {
    
    static func += (data: inout Data, value: Checksum) {
        data += value.rawValue.bigEndian
    }
    
    /// Length of value when encoded into data.
    var dataLength: Int {
        return type(of: self).length
    }
}