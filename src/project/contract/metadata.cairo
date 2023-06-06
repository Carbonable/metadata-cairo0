// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

// Local dependencies
from src.project.contract.library import ContractMetadata

// @notice Return the contract URI (OpenSea).
// @return uri_len The URI array length
// @return uri The URI characters
@view
func contractURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    uri_len: felt, uri: felt*
) {
    let (uri_len, uri) = ContractMetadata.contract_uri();
    return (uri_len=uri_len, uri=uri);
}

// @notice Return the slot URI.
// @param slot The slot to query.
// @return uri_len The URI array length
// @return uri The URI characters
@view
func slotURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(slot: Uint256) -> (
    uri_len: felt, uri: felt*
) {
    let (uri_len, uri) = ContractMetadata.slot_uri(slot=slot);
    return (uri_len=uri_len, uri=uri);
}

// @notice Return the token URI.
// @param slot The token slot.
// @param value The token value.
// @param decimals The token decimals.
// @return uri_len The URI array length
// @return uri The URI characters
@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (uri_len: felt, uri: felt*) {
    let (uri_len, uri) = ContractMetadata.token_uri(token_id=tokenId);
    return (uri_len=uri_len, uri=uri);
}
