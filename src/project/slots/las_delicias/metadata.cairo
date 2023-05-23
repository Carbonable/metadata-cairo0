// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

// Local dependencies
from src.project.slots.las_delicias.library import SlotMetadata

// @notice Return the slot URI.
// @param slot The slot to query.
// @return uri_len The URI array length
// @return uri The URI characters
@view
func slotURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(slot: Uint256) -> (
    uri_len: felt, uri: felt*
) {
    let (uri_len, uri) = SlotMetadata.slot_uri(slot=slot);
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
    let (uri_len, uri) = SlotMetadata.token_uri(token_id=tokenId);
    return (uri_len=uri_len, uri=uri);
}
