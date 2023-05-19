// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_contract_address

// Local dependencies
from src.project.slots.manjarisoa.library import SlotMetadata

@external
func test_token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (local instance) = get_contract_address();
    %{
        stop_mocks = [
            mock_call(ids.instance, "supportsInterface", [1]),
            mock_call(ids.instance, "getSlotMetadataImplementation", [0]),
            mock_call(ids.instance, "slotOf", [1, 0]),
            mock_call(ids.instance, "symbol", [123]),
            mock_call(ids.instance, "valueOf",    [156683, 0]),
            mock_call(ids.instance, "totalValue", [31337000000, 0]),

            ]
    %}
    let (uri_len, local uri: felt*) = SlotMetadata.token_uri(Uint256(1, 0));
    %{
        import json
        #for i in range(ids.uri_len):
        #    print(bytes.fromhex(hex(memory[ids.uri + i])[2:]))
        uri_data = [memory[ids.uri + i] for i in range(ids.uri_len)]
        data = "".join(map(lambda val: bytes.fromhex(hex(val)[2:]).decode(), uri_data))
        metadata = json.loads(data[22:])
        assert "name" in metadata
        assert "description" in metadata
        assert "image" in metadata
        assert "slot" in metadata
        assert "value" in metadata
        assert "attributes" in metadata
        #for attr in metadata["attributes"][:]:
        #    print(attr)
        #print(metadata["image"])
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
    let (uri_len, local uri: felt*) = SlotMetadata.slot_uri(Uint256(1, 0));
    %{
        import json
        #for i in range(ids.uri_len):
        #    print(bytes.fromhex(hex(memory[ids.uri + i])[2:]))
        uri_data = [memory[ids.uri + i] for i in range(ids.uri_len)]
        data = "".join(map(lambda val: bytes.fromhex(hex(val)[2:]).decode(), uri_data))
        metadata = json.loads(data[22:])
        assert "name" in metadata
        assert "description" in metadata
        assert "image" in metadata
        assert "slot number" in metadata
        assert "attributes" in metadata
        for stop_mock in stop_mocks: stop_mock()
    %}

    return ();
}
