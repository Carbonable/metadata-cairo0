// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_contract_address

// Local dependencies
from src.project.contract.library import ContractMetadata

@external
func test_token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local instance) = get_contract_address();
    %{
        stop_mocks = [
            mock_call(ids.instance, "supportsInterface", [1]),
            mock_call(ids.instance, "getSlotMetadataImplementation", [0]),
            mock_call(ids.instance, "slotOf", [1, 0])
            ]
    %}
    let (uri_len, local uri: felt*) = ContractMetadata.token_uri(Uint256(1, 0));
    %{
        uri_data = [memory[ids.uri + i] for i in range(ids.uri_len)]
        assert uri_data == []
        for stop_mock in stop_mocks: stop_mock()
    %}
    return ();
}

@external
func test_slot_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local instance) = get_contract_address();
    %{
        stop_mocks = [
            mock_call(ids.instance, "supportsInterface", [1]),
            mock_call(ids.instance, "getSlotMetadataImplementation", [0]),
            ]
    %}
    let (uri_len, local uri: felt*) = ContractMetadata.slot_uri(Uint256(1, 0));
    %{
        uri_data = [memory[ids.uri + i] for i in range(ids.uri_len)]
        assert uri_data == []
        for stop_mock in stop_mocks: stop_mock()
    %}
    return ();
}

@external
func test_contract_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local instance) = get_contract_address();
    %{ stop_mock = mock_call(ids.instance, "supportsInterface", [1]) %}
    let (uri_len, local uri: felt*) = ContractMetadata.contract_uri();
    %{
        uri_data = [memory[ids.uri + i] for i in range(ids.uri_len)]
        data = "".join(map(lambda val: bytes.fromhex(hex(val)[2:]).decode(), uri_data))
        assert data.startswith("https://")
        stop_mock()
    %}
    return ();
}
