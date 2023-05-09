// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_check

// Project dependencies
from openzeppelin.introspection.erc165.IERC165 import IERC165
from erc3525.utils.constants.library import (
    IERC165_ID,
    IERC721_ID,
    IERC721_METADATA_ID,
    IERC3525_ID,
    IERC3525_METADATA_ID,
)

// Assert helpers
namespace Assert {
    func u256{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(value: Uint256) {
        with_attr error_message("Metadata: value is not a valid Uint256") {
            uint256_check(value);
        }
        return ();
    }

    func is_erc165{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        instance: felt
    ) {
        let (is_165) = IERC165.supportsInterface(instance, IERC165_ID);
        with_attr error_message("Metadata: contract is not ERC165") {
            assert 1 = is_165;
        }
        return ();
    }

    func is_compatible{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        instance: felt
    ) {
        is_erc165(instance);
        let (is_3525) = IERC165.supportsInterface(instance, IERC3525_ID);
        let (is_3525_meta) = IERC165.supportsInterface(instance, IERC3525_METADATA_ID);
        let (is_721) = IERC165.supportsInterface(instance, IERC721_ID);
        let (is_721_meta) = IERC165.supportsInterface(instance, IERC721_METADATA_ID);
        with_attr error_message("Metadata: contract is not IERC3525") {
            assert 1 = is_3525;
            assert 1 = is_3525_meta;
            assert 1 = is_721;
            assert 1 = is_721_meta;
        }
        return ();
    }
}
