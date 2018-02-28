
protocol Imm {
    func appendBytes(to: inout [UInt8])
}
extension Int: Imm {}
extension Int8: Imm {}
extension Int16: Imm {}
extension Int32: Imm {}
extension Int64: Imm {}
extension UInt: Imm {}
extension UInt8: Imm {}
extension UInt16: Imm {}
extension UInt32: Imm {}
extension UInt64: Imm {}
extension Float: Imm {}
extension Double: Imm {}
extension Symbol: Imm {}
extension Function: Imm {}
extension Block: Imm {}

extension Symbol {

    func appendBytes(to buf: inout [UInt8]) {
        var val = self.address
        withUnsafeBytes(of: &val, { buf.append(contentsOf: $0) })
    }
}

extension Function {

    func appendBytes(to buf: inout [UInt8]) {
        symbol.appendBytes(to: &buf)
    }
}

extension Block {

    func appendBytes(to buf: inout [UInt8]) {
        symbol.appendBytes(to: &buf)
    }
}

extension Imm {

    func appendBytes(to buf: inout [UInt8]) {
        var val = self
        withUnsafeBytes(of: &val, { buf.append(contentsOf: $0) })
    }
}

func immediateOperand<T>(for type: T.Type) -> UInt8 {
    return findLastBitSet(MemoryLayout<T>.size / 8) << 2
}
