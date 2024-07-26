use risc0::utils::ReverseByteOrder;

#[derive(Drop)]
struct Receipt {
    seal: Array<u8>,
    claim_digest: u256,
}

#[derive(Drop)]
struct ReceiptClaim {
    pre_state_digest: u256,
    post_state_digest: u256,
    exit_code: ExitCode,
    input: u256,
    output: u256,
}

#[derive(Drop)]
struct ExitCode {
    system: SystemExitCode,
    user: u8,
}

#[derive(Drop)]
enum SystemExitCode {
    Halted,
    Paused,
    SystemSplit
}

pub(crate) mod receipt_claim {}

mod output_lib {
    use core::sha256::compute_sha256_byte_array;

    const TAG_DIGEST: u256 =
        0x77eafeb366a78b47747de0d7bb176284085ff5564887009a5be63da32d3559d4; // "risc0.Output"
    // fn digest
}
