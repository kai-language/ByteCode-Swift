
import func Darwin.flsl

func findLastBitSet<I: BinaryInteger, O: BinaryInteger>(_ n: I) -> O {
    return numericCast(flsl(numericCast(n)))
}
