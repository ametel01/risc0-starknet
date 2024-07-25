use risc0::math::BitShift;

pub(crate) trait ReverseByteOrder<T> {
    fn reverse_byte_order(self: T) -> T;
}

impl ReverseByteOrder<u256> of ReverseByteOrder<u256> {
    fn reverse_byte_order(self: u256) -> u256 {
        let mut v = self;

        v =
            (BitShift::shr(
                v & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00, 8
            )
                | BitShift::shl(
                    v & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF, 8
                ));
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

impl ReverseByteOrder<u32> of ReverseByteOrder<u32> {
    fn reverse_byte_order(self: u32) -> u32 {
        let mut v = self;

        v = (BitShift::shr(v & 0xFF00FF00, 8) | BitShift::shl(v & 0x00FF00FF, 8));
        (BitShift::shr(v, 16) | BitShift::shl(v, 16))
    }
}

impl ReverseByteOrder<u16> of ReverseByteOrder<u16> {
    fn reverse_byte_order(self: u16) -> u16 {
        (BitShift::shr(self, 8) | BitShift::shl(self, 8))
    }
}

