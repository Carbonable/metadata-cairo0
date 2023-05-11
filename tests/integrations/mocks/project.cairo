// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_check
from starkware.cairo.common.memcpy import memcpy

from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

from src.project.interfaces.carbonable_metadata import ICarbonableMetadata

@storage_var
func CarbonableMetadata_implementation() -> (implementation: felt) {
}

@storage_var
func CarbonableMetadata_slot_implementation(slot: Uint256) -> (implementation: felt) {
}

@view
func getMetadataImplementation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) -> (implementation: felt) {
    return CarbonableMetadata_implementation.read();
}

@view
func getSlotMetadataImplementation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    slot: Uint256
) -> (implementation: felt) {
    Assert.u256(slot);
    return CarbonableMetadata_slot_implementation.read(slot);
}

@external
func setMetadataImplementation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    implementation: felt
) {
    with_attr error_message("Metadata: implementation hash cannot be zero") {
        assert_not_zero(implementation);
    }

    CarbonableMetadata_implementation.write(implementation);
    return ();
}

@external
func setSlotMetadataImplementation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    slot: Uint256, implementation: felt
) {
    Assert.u256(slot);
    with_attr error_message("Metadata: implementation hash cannot be zero") {
        assert_not_zero(implementation);
    }

    CarbonableMetadata_slot_implementation.write(slot, implementation);
    return ();
}

@view
func contractURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    uri_len: felt, uri: felt*
) {
    alloc_locals;

    let (class_hash) = getMetadataImplementation();
    let (local array: felt*) = alloc();

    // [Check] Metadata implementation set
    if (class_hash == 0) {
        return (uri_len=0, uri=array);
    }

    let (uri_len: felt, uri: felt*) = ICarbonableMetadata.library_call_contractURI(
        class_hash=class_hash
    );

    return (uri_len=uri_len, uri=uri);
}

@view
func slotURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(slot: Uint256) -> (
    uri_len: felt, uri: felt*
) {
    alloc_locals;

    // [Check] Uint256 compliance
    Assert.u256(slot);

    let (class_hash) = getMetadataImplementation();
    let (local array: felt*) = alloc();

    // [Check] Metadata implementation set
    if (class_hash == 0) {
        return (uri_len=0, uri=array);
    }

    let (uri_len: felt, uri: felt*) = ICarbonableMetadata.library_call_slotURI(
        class_hash=class_hash, slot=slot
    );

    return (uri_len=uri_len, uri=uri);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (uri_len: felt, uri: felt*) {
    alloc_locals;

    // [Check] Uint256 compliance
    Assert.u256(token_id);

    let (class_hash) = getMetadataImplementation();
    let (local array: felt*) = alloc();

    // [Check] Metadata implementation set
    if (class_hash == 0) {
        return (uri_len=0, uri=array);
    }

    let (uri_len: felt, uri: felt*) = ICarbonableMetadata.library_call_tokenURI(
        class_hash=class_hash, tokenId=token_id
    );

    return (uri_len=uri_len, uri=uri);
}

// Mocks

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interface_id: felt
) -> (success: felt) {
    return (success=1);
}

@view
func slotOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (
    slot: Uint256
) {
    return (slot=Uint256(1, 0));
}

@view
func valueOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (
    value: felt
) {
    return (value=31337);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return (name='Carbonable Projects');
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    return (symbol='CRP');
}

@view
func slotCount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    count: Uint256
) {
    return (count=Uint256(3, 0));
}

// Assert helpers
namespace Assert {
    func u256{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(value: Uint256) {
        with_attr error_message("CarbonableMetadata: value is not a valid Uint256") {
            uint256_check(value);
        }
        return ();
    }
}
