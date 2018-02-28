
import Foundation

typealias BasicBlock = [UInt8]

class Symbol {
    var name: String
    var address: Int
    var size: Int

    init(name: String, address: Int, size: Int) {
        self.name = name
        self.address = address
        self.size = size
    }
}

struct Fixup {
    var symbol: Symbol
    var offset: Int

    func apply(baseAddress: Int, code: inout [UInt8]) {
        symbol.address = baseAddress + offset
        memcpy(&code[offset], &symbol.address, 8)
    }
}

class ByteCodeBuilder {
    var code: [UInt8] = Array(repeating: 0, count: 0x100)
    var globals: [Symbol] = []

    // TODO: Locking
    func linkFunction(_ function: Function) -> Symbol {
        // apply fixups to the function
        let baseAddress = code.endIndex

        // update the base address for each block, and compute the total size of the function
        var totalSize = 0
        var blockBaseAddress = baseAddress
        for block in function.blocks {
            block.symbol.address = blockBaseAddress
            blockBaseAddress += block.code.count
            totalSize += block.code.count
        }

        // update the symbol for the function and reserve memory for the it's instructions
        function.symbol.address = baseAddress
        function.symbol.size = totalSize
        code.reserveCapacity(code.capacity + totalSize)

        // apply the fixups for the block
        for block in function.blocks {
            for fixup in block.fixups {
                fixup.apply(baseAddress: baseAddress, code: &block.code)
            }
            code.append(contentsOf: block.code)
        }

        return function.symbol
    }
}

class Global {
    var name: String
    var instructions: [UInt8] = []

    init(name: String) {
        self.name = name
    }
}

class Function {
    var symbol: Symbol
    var blocks: [Block] = []

    init(name: String) {
        self.symbol = Symbol(name: name, address: 0, size: 0)
    }

    func appendBlock() -> Block {
        assert(self.symbol.address == 0, "A linked function cannot be modified further")
        let block = Block()
        blocks.append(block)
        return block
    }
}

class Block: InstructionBuilder {
    var symbol = Symbol(name: "", address: 0, size: 0)
    var fixups: [Fixup] = []
    var code: [UInt8] = []
}
