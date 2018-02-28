
struct VM {

    var l: UInt64 = 0
    var r: UInt64 = 0
    var ip: UInt64 = 0
    var bp: UInt64 = 0
    var sp: UInt64 = 0
    var flag: UInt64 = 0

    var code:  [UInt8]
    var stack: [UInt8] = []
    var heap:  [UInt8] = []
}
