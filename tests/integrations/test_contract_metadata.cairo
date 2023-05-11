// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.uint256 import Uint256

// Local dependencies
from src.project.interfaces.carbonable_metadata import ICarbonableMetadata

@external
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    %{
        context.project_contract = deploy_contract("./tests/integrations/mocks/project.cairo").contract_address 
        context.contract_metadata_class_hash = declare("./src/project/contract/metadata.cairo").class_hash
    %}
    return ();
}

@view
func test_metadata_nominal_case{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    let (instance) = contract_access.deployed();

    // Get implementation class hash
    let (implementation) = ICarbonableMetadata.getMetadataImplementation(instance);
    assert 0 = implementation;

    // Get contract metadata
    let (uri_len, uri) = ICarbonableMetadata.contractURI(instance);
    %{
        uri_data = [memory[ids.uri + i] for i in range(ids.uri_len)]
        assert uri_data == []
    %}

    let (metadata_implementation) = contract_access.metadata_implementation();
    ICarbonableMetadata.setMetadataImplementation(instance, metadata_implementation);
    let (implementation) = ICarbonableMetadata.getMetadataImplementation(instance);
    assert_not_zero(implementation);

    // Get contract metadata
    let (uri_len, uri) = ICarbonableMetadata.contractURI(instance);
    %{
        import json
        uri_data = [memory[ids.uri + i] for i in range(ids.uri_len)]
        data = "".join(map(lambda val: bytes.fromhex(hex(val)[2:]).decode(), uri_data))
        metadata = json.loads(data[22:])
        assert "name" in metadata
        assert "description" in metadata
        assert "image" in metadata
        assert "external_url" in metadata
        assert "banner_image_url" in metadata
        assert "youtube_url" in metadata
    %}

    // Get slot metadata
    let slot = Uint256(1, 0);
    let (uri_len, uri) = ICarbonableMetadata.slotURI(instance, slot);
    %{
        uri_data = [memory[ids.uri + i] for i in range(ids.uri_len)]
        assert uri_data == []
    %}

    // Get token metadata
    let token_id = Uint256(1, 0);
    let (uri_len, uri) = ICarbonableMetadata.tokenURI(instance, token_id);
    %{
        uri_data = [memory[ids.uri + i] for i in range(ids.uri_len)]
        assert uri_data == []
    %}

    return ();
}

namespace contract_access {
    func deployed() -> (address: felt) {
        tempvar project_contract;
        %{ ids.project_contract = context.project_contract %}
        return (address=project_contract);
    }

    func metadata_implementation() -> (implementation: felt) {
        tempvar implementation;
        %{ ids.implementation = context.contract_metadata_class_hash %}
        return (implementation=implementation);
    }
}
