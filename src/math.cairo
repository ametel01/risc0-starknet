use core::num::traits::{WideMul, OverflowingMul};
use core::integer::BoundedInt;
/// Raise a number to a power.
/// O(log n) time complexity.
/// * `base` - The number to raise.
/// * `exp` - The exponent.
/// # Returns
/// * `T` - The result of base raised to the power of exp.
pub fn pow<T, +Sub<T>, +Mul<T>, +Div<T>, +Rem<T>, +PartialEq<T>, +Into<u8, T>, +Drop<T>, +Copy<T>>(
    base: T, exp: T
) -> T {
    if exp == 0_u8.into() {
        1_u8.into()
    } else if exp == 1_u8.into() {
        base
    } else if exp % 2_u8.into() == 0_u8.into() {
        pow(base * base, exp / 2_u8.into())
    } else {
        base * pow(base * base, exp / 2_u8.into())
    }
}

pub trait BitShift<T> {
    fn shl(x: T, n: T) -> T;
    fn shr(x: T, n: T) -> T;
}

impl U8BitShift of BitShift<u8> {
    fn shl(x: u8, n: u8) -> u8 {
        (WideMul::wide_mul(x, pow(2, n)) & BoundedInt::<u8>::max().into()).try_into().unwrap()
    }

    fn shr(x: u8, n: u8) -> u8 {
        x / pow(2, n)
    }
}

impl U16BitShift of BitShift<u16> {
    fn shl(x: u16, n: u16) -> u16 {
        (WideMul::wide_mul(x, pow(2, n)) & BoundedInt::<u16>::max().into()).try_into().unwrap()
    }

    fn shr(x: u16, n: u16) -> u16 {
        x / pow(2, n)
    }
}

impl U32BitShift of BitShift<u32> {
    fn shl(x: u32, n: u32) -> u32 {
        (WideMul::wide_mul(x, pow(2, n)) & BoundedInt::<u32>::max().into()).try_into().unwrap()
    }

    fn shr(x: u32, n: u32) -> u32 {
        x / pow(2, n)
    }
}

impl U64BitShift of BitShift<u64> {
    fn shl(x: u64, n: u64) -> u64 {
        (WideMul::wide_mul(x, pow(2, n)) & BoundedInt::<u64>::max().into()).try_into().unwrap()
    }

    fn shr(x: u64, n: u64) -> u64 {
        x / pow(2, n)
    }
}

impl U128BitShift of BitShift<u128> {
    fn shl(x: u128, n: u128) -> u128 {
        let res = WideMul::wide_mul(x, pow(2, n));
        res.low
    }

    fn shr(x: u128, n: u128) -> u128 {
        x / pow(2, n)
    }
}

impl U256BitShift of BitShift<u256> {
    fn shl(x: u256, n: u256) -> u256 {
        let (r, _) = OverflowingMul::overflowing_mul(x, pow(2, n));
        r
    }

    fn shr(x: u256, n: u256) -> u256 {
        x / pow(2, n)
    }
}

