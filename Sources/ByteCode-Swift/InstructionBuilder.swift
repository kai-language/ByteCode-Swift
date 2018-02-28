
func prefixKind(for opcode: Opcode) -> PrefixKind {
    switch opcode {
    case .or: return .arg
    case .and: return .arg
    case .add: return .arg
    case .sub: return .arg
    case .mul: return .arg
    case .div: return .arg
    case .muls: return .arg
    case .divs: return .arg
    case .addf: return .arg
    case .subf: return .arg
    case .mulf: return .arg
    case .divf: return .arg
    case .shr: return .arg
    case .shl: return .arg
    case .cmp: return .arg
    case .cmpf: return .arg
    case .ftoi: return .arg
    case .itof: return .arg
    case .load8: return .arg
    case .load16: return .arg
    case .load32: return .arg
    case .load64: return .arg
    case .stor8: return .arg
    case .stor16: return .arg
    case .stor32: return .arg
    case .stor64: return .arg
    case .push: return .arg
    case .pop: return .arg
    case .stop: return .none
    case .xchg: return .none
    case .dump: return .none
    case .neg: return .reg
    case .sx8to16: return .reg
    case .sx8to32: return .reg
    case .sx8to64: return .reg
    case .sx16to32: return .reg
    case .sx16to64: return .reg
    case .sx32to64: return .reg
    case .f32to64: return .reg
    case .f64to32: return .reg
    case .push8: return .reg
    case .push16: return .reg
    case .push32: return .reg
    case .push64: return .reg
    case .pop8: return .reg
    case .pop16: return .reg
    case .pop32: return .reg
    case .pop64: return .reg
    case .loadil: return .size
    case .loadir: return .size
    case .jmp: return .word
    case .jeq: return .word
    case .jne: return .word
    case .jl: return .word
    case .jle: return .word
    case .jg: return .word
    case .jge: return .word
    case .call: return .word
    case .ccall: return .word
    }
}

private func sizePrefix<Immediate: Imm>(for type: Immediate.Type) -> UInt8 {
    return findLastBitSet(MemoryLayout<Immediate>.size) >> 1
}

protocol InstructionBuilder: class {
    var code: [UInt8] { get set }
}

extension InstructionBuilder {

    func noneInstruction(opcode: Opcode) {
        code.append(opcode.rawValue)
    }

    func argInstruction(opcode: Opcode, arg: PrefixArg) {
        code.append(opcode.rawValue)
    }

    func argInstruction<Immediate: Imm>(opcode: Opcode, imm: Immediate) {
        var imm = imm
        switch MemoryLayout<Immediate>.size {
        case 1:
            code.append(opcode.rawValue | PrefixArg.byteImm.rawValue << 6)
        case 8:
            code.append(opcode.rawValue | PrefixArg.wordImm.rawValue << 6)
        case 2:
            code.append(opcode.rawValue | PrefixArg.argument.rawValue << 6)
            code.append(OperandSource.i16.rawValue)
        default:
            code.append(opcode.rawValue | PrefixArg.argument.rawValue << 6)
            code.append(OperandSource.i32.rawValue)
        }
        withUnsafeBytes(of: &imm, { code.append(contentsOf: $0) })
    }

    func argInstruction(opcode: Opcode, source: OperandSource) {
        code.append(opcode.rawValue | PrefixArg.argument.rawValue << 6)
        code.append(source.rawValue)
    }

    func regInstruction(opcode: Opcode, reg: PrefixReg = .left) {
        assert(prefixKind(for: opcode) == .reg)
        code.append(opcode.rawValue | reg.rawValue << 6)
    }

    func sizeInstruction<Immediate: Imm>(opcode: Opcode, imm: Immediate) {
        assert(prefixKind(for: opcode) == .size)
        code.append(opcode.rawValue | sizePrefix(for: Immediate.self) << 6)
    }

    func wordInstruction(opcode: Opcode) {
        assert(prefixKind(for: opcode) == .size)
        code.append(opcode.rawValue)
    }

    func wordInstruction<Immediate: Imm>(opcode: Opcode, imm: Immediate) {
        assert(prefixKind(for: opcode) == .word)
        code.append(opcode.rawValue | PrefixWord.zero.rawValue << 6)
    }


    // NOTE: Overloads handle checking for zero to encode the entire instruction in a single byte
    func wordInstruction<Immediate: Imm & BinaryInteger>(opcode: Opcode, imm: Immediate) {
        assert(prefixKind(for: opcode) == .word)
        if imm == 0 {
            code.append(opcode.rawValue | PrefixWord.zero.rawValue << 6)
        } else {
            code.append(opcode.rawValue | PrefixWord.imm.rawValue << 6)
        }
    }

    func wordInstruction<Immediate: Imm & FloatingPoint>(opcode: Opcode, imm: Immediate) {
        assert(prefixKind(for: opcode) == .word)
        if imm.isZero {
            code.append(opcode.rawValue | PrefixWord.zero.rawValue << 6)
        } else {
            code.append(opcode.rawValue | PrefixWord.imm.rawValue << 6)
        }
    }
}


// MARK: Instruction builders for arg prefix instructions

extension InstructionBuilder {

    func or() {
        argInstruction(opcode: .or, arg: .none)
    }

    func or<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .or, imm: imm)
    }

    func or(source: OperandSource) {
        argInstruction(opcode: .or, source: source)
    }

    func and() {
        argInstruction(opcode: .and, arg: .none)
    }

    func and<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .and, imm: imm)
    }

    func and(source: OperandSource) {
        argInstruction(opcode: .and, source: source)
    }

    func add() {
        argInstruction(opcode: .add, arg: .none)
    }

    func add<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .add, imm: imm)
    }

    func add(source: OperandSource) {
        argInstruction(opcode: .add, source: source)
    }

    func sub() {
        argInstruction(opcode: .sub, arg: .none)
    }

    func sub<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .sub, imm: imm)
    }

    func sub(source: OperandSource) {
        argInstruction(opcode: .sub, source: source)
    }

    func mul() {
        argInstruction(opcode: .mul, arg: .none)
    }

    func mul<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .mul, imm: imm)
    }

    func mul(source: OperandSource) {
        argInstruction(opcode: .mul, source: source)
    }

    func div() {
        argInstruction(opcode: .div, arg: .none)
    }

    func div<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .div, imm: imm)
    }

    func div(source: OperandSource) {
        argInstruction(opcode: .div, source: source)
    }

    func muls() {
        argInstruction(opcode: .muls, arg: .none)
    }

    func muls<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .muls, imm: imm)
    }

    func muls(source: OperandSource) {
        argInstruction(opcode: .muls, source: source)
    }

    func divs() {
        argInstruction(opcode: .divs, arg: .none)
    }

    func divs<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .divs, imm: imm)
    }

    func divs(source: OperandSource) {
        argInstruction(opcode: .divs, source: source)
    }

    func addf() {
        argInstruction(opcode: .addf, arg: .none)
    }

    func addf<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .addf, imm: imm)
    }

    func addf(source: OperandSource) {
        argInstruction(opcode: .addf, source: source)
    }

    func subf() {
        argInstruction(opcode: .subf, arg: .none)
    }

    func subf<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .subf, imm: imm)
    }

    func subf(source: OperandSource) {
        argInstruction(opcode: .subf, source: source)
    }

    func mulf() {
        argInstruction(opcode: .mulf, arg: .none)
    }

    func mulf<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .mulf, imm: imm)
    }

    func mulf(source: OperandSource) {
        argInstruction(opcode: .mulf, source: source)
    }

    func divf() {
        argInstruction(opcode: .divf, arg: .none)
    }

    func divf<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .divf, imm: imm)
    }

    func divf(source: OperandSource) {
        argInstruction(opcode: .divf, source: source)
    }

    func shr() {
        argInstruction(opcode: .shr, arg: .none)
    }

    func shr<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .shr, imm: imm)
    }

    func shr(source: OperandSource) {
        argInstruction(opcode: .shr, source: source)
    }

    func shl() {
        argInstruction(opcode: .shl, arg: .none)
    }

    func shl<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .shl, imm: imm)
    }

    func shl(source: OperandSource) {
        argInstruction(opcode: .shl, source: source)
    }

    func cmp() {
        argInstruction(opcode: .cmp, arg: .none)
    }

    func cmp<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .cmp, imm: imm)
    }

    func cmp(source: OperandSource) {
        argInstruction(opcode: .cmp, source: source)
    }

    func cmpf() {
        argInstruction(opcode: .cmpf, arg: .none)
    }

    func cmpf<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .cmpf, imm: imm)
    }

    func cmpf(source: OperandSource) {
        argInstruction(opcode: .cmpf, source: source)
    }

    func ftoi() {
        argInstruction(opcode: .ftoi, arg: .none)
    }

    func ftoi<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .ftoi, imm: imm)
    }

    func ftoi(source: OperandSource) {
        argInstruction(opcode: .ftoi, source: source)
    }

    func itof() {
        argInstruction(opcode: .itof, arg: .none)
    }

    func itof<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .itof, imm: imm)
    }

    func itof(source: OperandSource) {
        argInstruction(opcode: .itof, source: source)
    }

    func load8() {
        argInstruction(opcode: .load8, arg: .none)
    }

    func load8<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .load8, imm: imm)
    }

    func load8(source: OperandSource) {
        argInstruction(opcode: .load8, source: source)
    }

    func load16() {
        argInstruction(opcode: .load16, arg: .none)
    }

    func load16<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .load16, imm: imm)
    }

    func load16(source: OperandSource) {
        argInstruction(opcode: .load16, source: source)
    }

    func load32() {
        argInstruction(opcode: .load32, arg: .none)
    }

    func load32<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .load32, imm: imm)
    }

    func load32(source: OperandSource) {
        argInstruction(opcode: .load32, source: source)
    }

    func load64() {
        argInstruction(opcode: .load64, arg: .none)
    }

    func load64<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .load64, imm: imm)
    }

    func load64(source: OperandSource) {
        argInstruction(opcode: .load64, source: source)
    }

    func stor8() {
        argInstruction(opcode: .stor8, arg: .none)
    }

    func stor8<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .stor8, imm: imm)
    }

    func stor8(source: OperandSource) {
        argInstruction(opcode: .stor8, source: source)
    }

    func stor16() {
        argInstruction(opcode: .stor16, arg: .none)
    }

    func stor16<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .stor16, imm: imm)
    }

    func stor16(source: OperandSource) {
        argInstruction(opcode: .stor16, source: source)
    }

    func stor32() {
        argInstruction(opcode: .stor32, arg: .none)
    }

    func stor32<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .stor32, imm: imm)
    }

    func stor32(source: OperandSource) {
        argInstruction(opcode: .stor32, source: source)
    }

    func stor64() {
        argInstruction(opcode: .stor64, arg: .none)
    }

    func stor64<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .stor64, imm: imm)
    }

    func stor64(source: OperandSource) {
        argInstruction(opcode: .stor64, source: source)
    }

    func push() {
        argInstruction(opcode: .push, arg: .none)
    }

    func push<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .push, imm: imm)
    }

    func push(source: OperandSource) {
        argInstruction(opcode: .push, source: source)
    }

    func pop() {
        argInstruction(opcode: .pop, arg: .none)
    }

    func pop<Immediate: Imm>(imm: Immediate) {
        argInstruction(opcode: .pop, imm: imm)
    }

    func pop(source: OperandSource) {
        argInstruction(opcode: .pop, source: source)
    }
}


// MARK: Instruction builders for reg prefix instructions

extension InstructionBuilder {

    func negl() {
        regInstruction(opcode: .neg, reg: .left)
    }

    func negr() {
        regInstruction(opcode: .neg, reg: .right)
    }

    func sx8to16l() {
        regInstruction(opcode: .sx8to16, reg: .left)
    }

    func sx8to16r() {
        regInstruction(opcode: .sx8to16, reg: .right)
    }

    func sx8to32l() {
        regInstruction(opcode: .sx8to32, reg: .left)
    }

    func sx8to32r() {
        regInstruction(opcode: .sx8to32, reg: .right)
    }

    func sx8to64l() {
        regInstruction(opcode: .sx8to64, reg: .left)
    }

    func sx8to64r() {
        regInstruction(opcode: .sx8to64, reg: .right)
    }

    func sx16to32l() {
        regInstruction(opcode: .sx16to32, reg: .left)
    }

    func sx16to32r() {
        regInstruction(opcode: .sx16to32, reg: .right)
    }

    func sx16to64l() {
        regInstruction(opcode: .sx16to64, reg: .left)
    }

    func sx16to64r() {
        regInstruction(opcode: .sx16to64, reg: .right)
    }

    func sx32to64l() {
        regInstruction(opcode: .sx32to64, reg: .left)
    }

    func sx32to64r() {
        regInstruction(opcode: .sx32to64, reg: .right)
    }

    func f32to64l() {
        regInstruction(opcode: .f32to64, reg: .left)
    }

    func f32to64r() {
        regInstruction(opcode: .f32to64, reg: .right)
    }

    func f64to32l() {
        regInstruction(opcode: .f64to32, reg: .left)
    }

    func f64to32r() {
        regInstruction(opcode: .f64to32, reg: .right)
    }

    func push8l() {
        regInstruction(opcode: .push8, reg: .left)
    }

    func push8r() {
        regInstruction(opcode: .push8, reg: .right)
    }

    func push16l() {
        regInstruction(opcode: .push16, reg: .left)
    }

    func push16r() {
        regInstruction(opcode: .push16, reg: .right)
    }

    func push32l() {
        regInstruction(opcode: .push32, reg: .left)
    }

    func push32r() {
        regInstruction(opcode: .push32, reg: .right)
    }

    func push64l() {
        regInstruction(opcode: .push64, reg: .left)
    }

    func push64r() {
        regInstruction(opcode: .push64, reg: .right)
    }

    func pop8l() {
        regInstruction(opcode: .pop8, reg: .left)
    }

    func pop8r() {
        regInstruction(opcode: .pop8, reg: .right)
    }

    func pop16l() {
        regInstruction(opcode: .pop16, reg: .left)
    }

    func pop16r() {
        regInstruction(opcode: .pop16, reg: .right)
    }

    func pop32l() {
        regInstruction(opcode: .pop32, reg: .left)
    }

    func pop32r() {
        regInstruction(opcode: .pop32, reg: .right)
    }

    func pop64l() {
        regInstruction(opcode: .pop64, reg: .left)
    }

    func pop64r() {
        regInstruction(opcode: .pop64, reg: .right)
    }
}


// MARK: Instruction builders for size prefix instructions

extension InstructionBuilder {

    func loadil<Immediate: Imm>(imm: Immediate) {
        sizeInstruction(opcode: .loadil, imm: imm)
    }

    func loadir<Immediate: Imm>(imm: Immediate) {
        sizeInstruction(opcode: .loadir, imm: imm)
    }
}


// MARK: Instruction builders for word prefix instructions

extension InstructionBuilder {

    func jmp() {
        wordInstruction(opcode: .jmp)
    }

    func jmp<Immediate: Imm>(imm: Immediate) {
        wordInstruction(opcode: .jmp, imm: imm)
    }

    func jeq() {
        wordInstruction(opcode: .jeq)
    }

    func jeq<Immediate: Imm>(imm: Immediate) {
        wordInstruction(opcode: .jeq, imm: imm)
    }

    func jne() {
        wordInstruction(opcode: .jne)
    }

    func jne<Immediate: Imm>(imm: Immediate) {
        wordInstruction(opcode: .jne, imm: imm)
    }

    func jl() {
        wordInstruction(opcode: .jl)
    }

    func jl<Immediate: Imm>(imm: Immediate) {
        wordInstruction(opcode: .jl, imm: imm)
    }

    func jle() {
        wordInstruction(opcode: .jle)
    }

    func jle<Immediate: Imm>(imm: Immediate) {
        wordInstruction(opcode: .jle, imm: imm)
    }

    func jg() {
        wordInstruction(opcode: .jg)
    }

    func jg<Immediate: Imm>(imm: Immediate) {
        wordInstruction(opcode: .jg, imm: imm)
    }

    func jge() {
        wordInstruction(opcode: .jge)
    }

    func jge<Immediate: Imm>(imm: Immediate) {
        wordInstruction(opcode: .jge, imm: imm)
    }

    func call() {
        wordInstruction(opcode: .call)
    }

    func call<Immediate: Imm>(imm: Immediate) {
        wordInstruction(opcode: .call, imm: imm)
    }

    func ccall() {
        wordInstruction(opcode: .ccall)
    }

    func ccall<Immediate: Imm>(imm: Immediate) {
        wordInstruction(opcode: .ccall, imm: imm)
    }
}


// MARK: Instruction builders for none prefix instructions

extension InstructionBuilder {

    func stop() {
        noneInstruction(opcode: .stop)
    }

    func xchg() {
        noneInstruction(opcode: .xchg)
    }

    func dump() {
        noneInstruction(opcode: .dump)
    }
}
