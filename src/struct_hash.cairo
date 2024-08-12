use risc0::math::BitShift;
use risc0::utils::{CountBytes, split_u256_to_u32};
use core::sha256::compute_sha256_u32_array;

fn tagged_struct(tag_digest: u256, down: Array<u256>, data: Array<u32>) -> u256 {
    let mut down_len = down.len();

    // swap the byte order to encode as little-endian.
    let down_len_le = BitShift::shl(down_len, 8) | BitShift::shr(down_len, 8);

    let mut acc: Array<u32> = array![];

    let tag_digest_bytes = split_u256_to_u32(tag_digest);
    for elem in tag_digest_bytes {
        acc.append(elem);
    };

    for elem in down {
        let elem_bytes = split_u256_to_u32(elem);
        for byte in elem_bytes {
            acc.append(byte);
        };
    };

    for elem in data {
        acc.append(elem);
    };

    acc.append(down_len_le);

    let last_elem = acc.at(acc.len() - 1);
    let sha = compute_sha256_u32_array(acc.clone(), *last_elem, (*last_elem).num_bytes());
    println!("{:?}", sha);

    0
}

fn tagged_list_cons(tag_digest: u256, head: u256, tail: u256) -> u256 {
    let down = array![head, tail];
    tagged_struct(tag_digest, down, array![])
}

fn tagged_list_nil(tag_digest: u256, list: Array<u256>) -> u256 {
    let mut curr = 0x0000000000000000000000000000000000000000000000000000000000000000;

    let list_len = list.len();
    let mut i = 0;
    while i < list_len {
        curr = tagged_list_cons(tag_digest, *list.at(list_len - 1 - i), curr);
        i += 1;
    };

    curr
}

#[cfg(test)]
mod test {
    use super::{tagged_struct, compute_sha256_u32_array};
    // #[test]
// fn test_sha256() {
//     let mut input: Array::<u32> = Default::default();
//     input.append('aaaa');

    //     // Test the sha256 syscall computation of the string 'aaaa'.
//     let [res, _, _, _, _, _, _, _,] = compute_sha256_u32_array(input, 0, 0);
//     assert(res == 0x61be55a8, 'Wrong hash value');
// }
}
