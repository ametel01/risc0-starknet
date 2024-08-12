// use risc0::{utils, utils::ReverseByteOrder};

#[derive(Drop, Serde)]
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

mod receipt_claim_lib {
    use super::{ReceiptClaim, SystemExitCode, ExitCode, Output, SystemExitCodeIntoU32};
    use super::output_lib::DigestTrait;
    use risc0::{math::BitShift, utils, utils::CountBytes, utils::Sha256DigestTrait};
    use core::sha256::compute_sha256_u32_array;

    const TAG_DIGEST: u256 =
        0xcb1fefcd1f2d9a64975cbbbf6e161e2914434b0cbb9960b84df5d717e86b48af; // sha256("risc0.ReceiptClaim")
    const SYSTEM_STATE_ZERO_DIGEST: u256 =
        0xa3acc27117418996340b84e5a90f3ef4c49d22c79e44aad822ec9c313e1eb8e2;

    fn ok(imageId: u256, journal_digest: u256) -> ReceiptClaim {
        ReceiptClaim {
            pre_state_digest: imageId,
            post_state_digest: SYSTEM_STATE_ZERO_DIGEST,
            exit_code: ExitCode { system: SystemExitCode::Halted, user: 0, },
            input: 0,
            output: Output { journal_digest, assumptions_digest: 0, }.digest(),
        }
    }

    #[generate_trait]
    impl ReceiptClaimImpl of ReceiptClaimTrait {
        fn digest(self: ReceiptClaim) -> u256 {
            let mut data: Array<u32> = array![];

            let split_tag_digest = utils::split_u256_to_u32(TAG_DIGEST);
            for elem in split_tag_digest {
                data.append(elem);
            };

            let split_input = utils::split_u256_to_u32(self.input);
            for elem in split_input {
                data.append(elem);
            };

            let split_pre_state_digest = utils::split_u256_to_u32(self.pre_state_digest);
            for elem in split_pre_state_digest {
                data.append(elem);
            };

            let split_post_state_digest = utils::split_u256_to_u32(self.post_state_digest);
            for elem in split_post_state_digest {
                data.append(elem);
            };

            let split_output = utils::split_u256_to_u32(self.output);
            for elem in split_output {
                data.append(elem);
            };

            let exit_code_system: u32 = self.exit_code.system.into();
            let split_exit_code = utils::split_u256_to_u32(
                BitShift::shl(exit_code_system, 24).into()
            );
            for elem in split_exit_code {
                data.append(elem);
            };

            let exit_code_user: u32 = BitShift::shl(self.exit_code.user, 24).into();
            data.append(exit_code_user);

            let last_elem = data.at(data.len() - 1);
            let digest = compute_sha256_u32_array(data, *last_elem, (*last_elem).num_bytes());

            digest.to_u256()
        }
    }
}

#[derive(Drop)]
struct SystemState {
    pc: u32,
    merkle_root: u256,
}

mod system_state_lib {
    use risc0::{
        utils, utils::Sha256DigestTrait, utils::CountBytes, utils::U32ReverseByteOrder,
        math::BitShift
    };
    use super::SystemState;
    use core::sha256::compute_sha256_u32_array;

    const TAG_DIGEST: u256 =
        0x206115a847207c0892e0c0547225df31d02a96eeb395670c31112dff90b421d6; // sha256("risc0.SystemState")

    #[generate_trait]
    pub impl SystemStateImpl of SystemStateTrait {
        fn digest(self: SystemState) -> u256 {
            let mut data: Array<u32> = array![];

            let split_tag_digest = utils::split_u256_to_u32(TAG_DIGEST);
            for elem in split_tag_digest {
                data.append(elem);
            };

            let split_merkle_root = utils::split_u256_to_u32(self.merkle_root);
            for elem in split_merkle_root {
                data.append(elem);
            };

            data.append(self.pc.reverse_byte_order());
            data.append(BitShift::shl(1, 8));

            let last_elem = data.at(data.len() - 1);
            let digest = compute_sha256_u32_array(data, *last_elem, (*last_elem).num_bytes());

            digest.to_u256()
        }
    }
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

impl SystemExitCodeIntoU32 of Into<SystemExitCode, u32> {
    fn into(self: SystemExitCode) -> u32 {
        match self {
            SystemExitCode::Halted => 0,
            SystemExitCode::Paused => 1,
            SystemExitCode::SystemSplit => 2,
        }
    }
}

#[derive(Drop)]
struct Output {
    journal_digest: u256,
    assumptions_digest: u256,
}

mod output_lib {
    use super::Output;
    use risc0::{utils, utils::Sha256DigestTrait, utils::CountBytes};
    use core::sha256::compute_sha256_u32_array;

    const TAG_DIGEST: u256 =
        0x77eafeb366a78b47747de0d7bb176284085ff5564887009a5be63da32d3559d4; // sha256("risc0.Output")


    #[generate_trait]
    pub impl DigestImpl of DigestTrait {
        fn digest(self: Output) -> u256 {
            let mut data: Array<u32> = array![];

            let split_tag_digest = utils::split_u256_to_u32(TAG_DIGEST);
            let split_journal_digest = utils::split_u256_to_u32(self.journal_digest);
            let split_assumptions_digest = utils::split_u256_to_u32(self.assumptions_digest);

            for elem in split_tag_digest {
                data.append(elem);
            };
            for elem in split_journal_digest {
                data.append(elem);
            };
            for elem in split_assumptions_digest {
                data.append(elem);
            };

            let last_elem = data.at(data.len() - 1);

            let digest = compute_sha256_u32_array(data, *last_elem, (*last_elem).num_bytes());

            digest.to_u256()
        }
    }
}

#[starknet::interface]
trait IRiscZeroVerifier<TState> {
    fn verify(self: @TState, seal: Array<u8>, image_id: u256, journal_digest: u256);
    fn verify_integrity(self: @TState, receipt: Receipt);
}
