
let smallZero: UInt8 = 0

let b = ByteCodeBuilder()
let main = Function(name: "main")

let strt = main.appendBlock()
let cond = main.appendBlock()
let step = main.appendBlock()
let body = main.appendBlock()
// alloc a 64 bit 0
strt.push(imm: UInt8(0))
strt.jmp(imm: cond)

dump(strt)
