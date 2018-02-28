
/// 6 bits
enum Opcode: UInt8 {

    // Argument
    case or = 0x2
    case and = 0x3
    case add = 0x4
    case sub = 0x5
    case mul = 0x6
    case div = 0x7
    case muls = 0x8
    case divs = 0x9
    case addf = 0xA
    case subf = 0xB
    case mulf = 0xC
    case divf = 0xD
    case shr = 0xE
    case shl = 0xF
    case cmp = 0x10
    case cmpf = 0x11
    case ftoi = 0x12
    case itof = 0x13
    case load8 = 0x20
    case load16 = 0x21
    case load32 = 0x22
    case load64 = 0x23
    case stor8 = 0x26
    case stor16 = 0x27
    case stor32 = 0x28
    case stor64 = 0x29
    case push = 0x33
    case pop = 0x38

    // Register
    case neg = 0x1
    case sx8to16 = 0x14
    case sx8to32 = 0x15
    case sx8to64 = 0x16
    case sx16to32 = 0x17
    case sx16to64 = 0x18
    case sx32to64 = 0x19
    case f32to64 = 0x1A
    case f64to32 = 0x1B
    case push8 = 0x34
    case push16 = 0x35
    case push32 = 0x36
    case push64 = 0x37
    case pop8 = 0x39
    case pop16 = 0x3A
    case pop32 = 0x3B
    case pop64 = 0x3C

    // Size
    case loadil = 0x24
    case loadir = 0x25

    // Word
    case jmp = 0x2B
    case jeq = 0x2C
    case jne = 0x2D
    case jl = 0x2E
    case jle = 0x2F
    case jg = 0x30
    case jge = 0x31
    case call = 0x32
    case ccall = 0x3E

    // None
    case stop = 0x0
    case xchg = 0x2A
    case dump = 0x3D
}


// MARK: Prefix

enum PrefixKind {
    case arg
    case word
    case none
    case reg
    case size
}

protocol Prefix {
    var rawValue: UInt8 { get }
    static var kind: PrefixKind { get }
}

enum PrefixArg: UInt8, Prefix {
    /// Operation is between L & R
    case none     = 0b00

    /// Operation is between L & a 8 bit immediate
    case byteImm  = 0b01

    /// Operation is between L & a 64 bit immediate
    case wordImm  = 0b10

    /// Operation is defined by it arguments
    case argument = 0b11

    static let kind: PrefixKind = .arg
}

enum PrefixReg: UInt8, Prefix {

    /// Operation uses R
    case right = 0b01

    /// Operation uses L
    case left  = 0b10

    static let kind: PrefixKind = .reg
}

enum PrefixWord: UInt8, Prefix {
    /// Operation uses the L parameter
    case left = 0b00

    case imm
    case zero

    static let kind: PrefixKind = .word
}


// MARK: Arguments

/// 4 bits
enum OperandReg: UInt8 {
    case r8  = 0o00
    case r16 = 0o01
    case r32 = 0o02
    case r64 = 0o03
    case sp  = 0o11
    case bp  = 0o12
    case ip  = 0o13
    case flg = 0o14
}

/// 4 bits
enum OperandSource: UInt8 {
    case r8  = 0o00
    case r16 = 0o01
    case r32 = 0o02
    case r64 = 0o03
    case l8  = 0o04
    case l16 = 0o05
    case l32 = 0o06
    case l64 = 0o07
    case i8  = 0o10
    case i16 = 0o11
    case i32 = 0o12
    case i64 = 0o13
    /// Special value indicating the source is 0
    case _0  = 0o14
    case sp  = 0o15
    case bp  = 0o16
    case ip  = 0o17
}

/// 4 bits
enum OperandDest: UInt8 {
    case r8  = 0o00
    case r16 = 0o01
    case r32 = 0o02
    case r64 = 0o03
    case l8  = 0o04
    case l16 = 0o05
    case l32 = 0o06
    case l64 = 0o07
}

/// 4 bits
enum OperandRound: UInt8 {
    case nearestEven  = 0o00
    case down = 0o01
    case up = 0o02
    case zero = 0o03
}

/// 4 bits
enum Operand: UInt8 /* 4 Bits */ {
    case r8  = 0o00
    case r16 = 0o01
    case r32 = 0o02
    case r64 = 0o03
    case i8  = 0o04
    case i16 = 0o05
    case i32 = 0o06
    case i64 = 0o07
    case _0  = 0o10
    case sp  = 0o11
    case bp  = 0o12
    case ip  = 0o13
    case flg = 0o14
    /* 0o15 */
    /* 0o16 */
    /* 0o17 */
}
