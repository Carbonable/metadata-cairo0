// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_check
from starkware.cairo.common.memcpy import memcpy

from starkware.starknet.common.syscalls import get_contract_address

// Project dependencies
from erc3525.IERC3525Full import IERC3525Full as IERC3525

// Local dependencies
from src.project.contract.data.image import ContractSVG
from src.project.interfaces.carbonable_metadata import ICarbonableMetadata
from src.project.utils.assert_helper import Assert
from src.project.utils.ascii import felt_to_short_string, array_concat
from src.project.utils.type import _felt_to_uint, _uint_to_felt

namespace ContractMetadata {
    func token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_id: Uint256
    ) -> (uri_len: felt, uri: felt*) {
        alloc_locals;

        // [Check] Uint256 compliance
        Assert.u256(token_id);

        let (instance) = get_contract_address();

        // [Check] ERC3525 compliance
        Assert.is_compatible(instance);

        let (slot) = IERC3525.slotOf(instance, token_id);
        let (class_hash) = ICarbonableMetadata.getSlotMetadataImplementation(instance, slot);
        let (local array: felt*) = alloc();

        // [Check] Metadata implementation set
        if (class_hash == 0) {
            return (uri_len=0, uri=array);
        }

        let (uri_len: felt, uri: felt*) = ICarbonableMetadata.library_call_tokenURI(
            class_hash, token_id
        );

        return (uri_len=uri_len, uri=uri);
    }

    func slot_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        slot: Uint256
    ) -> (uri_len: felt, uri: felt*) {
        alloc_locals;

        // [Check] Uint256 compliance
        Assert.u256(slot);

        let (instance) = get_contract_address();

        // [Check] ERC3525 compliance
        Assert.is_compatible(instance);

        let (class_hash) = ICarbonableMetadata.getSlotMetadataImplementation(instance, slot);
        let (local array: felt*) = alloc();

        // [Check] Metadata implementation set
        if (class_hash == 0) {
            return (uri_len=0, uri=array);
        }

        let (uri_len: felt, uri: felt*) = ICarbonableMetadata.library_call_slotURI(
            class_hash, slot
        );

        return (uri_len=uri_len, uri=uri);
    }

    func contract_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        uri_len: felt, uri: felt*
    ) {
        alloc_locals;

        let (local instance) = get_contract_address();
        // [Check] ERC3525 compliance
        Assert.is_compatible(instance);

        let (local res: felt*) = alloc();

        let (slot_count_u256) = IERC3525.slotCount(instance);
        let (slot_count) = _uint_to_felt(slot_count_u256);
        let (slot_count_ss_len, slot_count_ss) = felt_to_short_string(slot_count);

        assert res[0] = 'data:application/json,{"name":';
        let (res_len, res) = _contractName(1, res, instance);
        assert res[res_len] = ',"description":';
        let (res_len, res) = _contractDescription(res_len + 1, res, instance);
        assert res[res_len + 0] = ',"external_url":';
        assert res[res_len + 1] = '"https://app.carbonable.io/"';
        assert res[res_len + 2] = ',"banner_image_url":';
        assert res[res_len + 3] = '"ipfs://Qmdjj76nkc1HQn8Tr3ertWs';
        assert res[res_len + 4] = '9eWkFMBxXQkGwjHEp6mWbig/banner.';
        assert res[res_len + 5] = 'png"';
        assert res[res_len + 6] = ',"youtube_url":';
        assert res[res_len + 7] = '"https://youtu.be/5dZrROBmfKU"';
        assert res[res_len + 8] = ',"num_projects":';
        let (res_len, res) = array_concat(res_len + 9, res, slot_count_ss_len, slot_count_ss);
        assert res[res_len + 0] = ',"image":"';
        let (res_len, res) = _contractImage(res_len + 1, res, instance);
        assert res[res_len] = '"}';

        return (res_len + 1, res);
    }

    //
    // Internals
    //

    func _contractName{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        let (name) = IERC3525.name(instance);
        assert res[res_len + 0] = '"';
        assert res[res_len + 1] = name;
        assert res[res_len + 2] = '"';
        return (res_len + 3, res);
    }

    func _contractDescription{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt
    ) -> (res_len: felt, res: felt*) {
        assert res[res_len + 0] = '"Carbonable Protocol ';
        assert res[res_len + 1] = 'Regeneration Projects"';
        return (res_len + 2, res);
    }

    func _contractImage{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        // MIME format
        assert res[res_len] = 'data:image/svg+xml,';
        // SVG content
        let (res_len, res) = ContractSVG._svg_carbonable_up_logo(res_len + 1, res);
        return (res_len, res);
    }
}
