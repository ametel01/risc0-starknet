use risc0::math::BitShift;
use core::traits::{BitOr, BitAnd};

pub(crate) trait ReverseByteOrder<T, +BitOr<T>, +BitAnd<T>, +BitShift<T>> {
    fn reverse_byte_order(self: T) -> T;
}

impl U256ReverseByteOrder of ReverseByteOrder<u256> {
    fn reverse_byte_order(self: u256) -> u256 {
        let mut v: u256 = self;

        v =
            BitShift::shr(
                v & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00, 8
            )
                | BitShift::shl(
                    v & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF, 8
                );
        v =
            (BitShift::shr(
                v & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000, 16
            )
                | BitShift::shl(
                    v & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF, 16
                ));
        v =
            (BitShift::shr(
                v & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000, 32
            )
                | BitShift::shl(
                    v & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF, 32
                ));
        v =
            (BitShift::shr(
                v & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000, 64
            )
                | BitShift::shl(
                    v & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF, 64
                ));
        (BitShift::shr(v, 128) | BitShift::shl(v, 128))
    }
}

impl U32ReverseByteOrder of ReverseByteOrder<u32> {
    fn reverse_byte_order(self: u32) -> u32 {
        let mut v: u32 = self;

        v = (BitShift::shr(v & 0xFF00FF00, 8) | BitShift::shl(v & 0x00FF00FF, 8));
        (BitShift::shr(v, 16) | BitShift::shl(v, 16))
    }
}

impl U16ReverseByteOrder of ReverseByteOrder<u16> {
    fn reverse_byte_order(self: u16) -> u16 {
        (BitShift::shr(self, 8) | BitShift::shl(self, 8))
    }
}

pub(crate) fn split_u256_to_u32(input: u256) -> Array<u32> {
    let mask: u256 = BitShift::shl(1, 32) - 1;
    let mut u32_parts: Array<u32> = array![];
    let mut i: usize = 0;
    while i < 4 {
        let elemnt: u32 = (BitShift::shr(input, (32 * (3 - i)).into()) & mask).try_into().unwrap();
        u32_parts.append(elemnt);
        i += 1;
    };
    u32_parts
}

#[cfg(test)]
mod test {
    use super::{split_u256_to_u32, BitShift, ReverseByteOrder};

    #[test]
    fn test_reverse_byte_order() {
        let input: u256 = 0x1234567890ABCDEF1234567890ABCDEF;
        let expected: u256 = 0xefcdab9078563412efcdab907856341200000000000000000000000000000000;
        let result: u256 = input.reverse_byte_order();
        assert_eq!(result, expected);
    }

    #[test]
    fn test_bit_shift() {
        let mut v: u256 = 0x1234567890ABCDEF1234567890ABCDEF;
        v =
            BitShift::shr(
                v & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00, 8
            )
                | BitShift::shl(
                    v & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF, 8
                );
        assert_eq!(v, 69215757880140821143894070845391302605);
    }

    #[test]
    fn test_split_u256_to_u32() {
        let input = 0x1234567890ABCDEF1234567890ABCDEF;
        let expected = array![0x12345678, 0x90ABCDEF, 0x12345678, 0x90ABCDEF];
        let result = split_u256_to_u32(input);
        assert_eq!(result, expected);
    }

    #[test]
    fn test_bit_or() {
        let a: u256 = 0x12345678;
        let b: u256 = 0x90ABCDEF;
        let expected: u256 = 2462048255;
        let result: u256 = a | b;
        assert_eq!(result, expected);
    }

    #[test]
    fn test_bit_and() {
        let a: u256 = 0x12345678;
        let b: u256 = 0x90ABCDEF;
        let expected: u256 = 270550120;
        let result: u256 = a & b;
        assert_eq!(result, expected);
    }
}

