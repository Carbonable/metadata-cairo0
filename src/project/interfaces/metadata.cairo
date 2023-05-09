// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IContractMetadata {
    func contractURI() -> (uri_len: felt, uri: felt*) {
    }

    func slotURI(slot: Uint256) -> (uri_len: felt, uri: felt*) {
    }

    func tokenURI(tokenId: Uint256) -> (uri_len: felt, uri: felt*) {
    }
}

@contract_interface
namespace ISlotMetadata {
    func slotURI(slot: Uint256) -> (uri_len: felt, uri: felt*) {
    }

    func tokenURI(tokenId: Uint256) -> (uri_len: felt, uri: felt*) {
    }
}
