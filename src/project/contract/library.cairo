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
from src.project.utils.svg import ProjectSvg, felt31_to_short_string, array_concat
from src.project.interfaces.carbonable_metadata import ICarbonableMetadata
from src.project.utils.assert_helper import Assert

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

        // let (uri_len: felt, uri: felt*) = ICarbonableMetadata.library_call_tokenURI(
        let (uri_len: felt, uri: felt*) = ICarbonableMetadata.tokenURI(instance, token_id);

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

        let (uri_len: felt, uri: felt*) = ICarbonableMetadata.slotURI(instance, slot);

        return (uri_len=uri_len, uri=uri);
    }

    func contract_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        uri_len: felt, uri: felt*
    ) {
        alloc_locals;

        let (instance) = get_contract_address();

        // [Check] ERC3525 compliance
        Assert.is_compatible(instance);

        // TODO: Fix for non-PoC contracts
        let (res: felt*) = alloc();
        assert res[0] = 'https://dev-carbonable-metadata';
        assert res[1] = '.fly.dev/collection';

        return (2, res);
    }

    //
    // Internals
    //

    func _contractName{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, tokenId: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        let (symbol) = IERC3525.symbol(instance);
        // TODO better Uint256 to felt support
        let token_ss = felt31_to_short_string(tokenId.low);
        assert res[res_len] = '"';
        assert res[res_len + 1] = symbol;
        assert res[res_len + 2] = ' #';
        assert res[res_len + 3] = token_ss;
        assert res[res_len + 4] = '"';
        return (res_len + 5, res);
    }

    func _contractDescription{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, tokenId: Uint256
    ) -> (res_len: felt, res: felt*) {
        assert res[res_len] = '"dummy token description"';
        return (res_len + 1, res);
    }

    func _contractImage{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, value: Uint256, tokenId: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        // MIME format
        assert res[res_len] = 'data:image/svg+xml,';
        // SVG content
        let (res_len, res) = ProjectSvg._svg_def(res_len + 1, res);
        let (res_len, res) = ProjectSvg._svg_background_outline(res_len, res);
        let (res_len, res) = ProjectSvg._svg_carbonable_logo(res_len, res);
        let (res_len, res) = ProjectSvg._svg_background_image(res_len, res);
        let (res_len, res) = ProjectSvg._svg_icons(res_len, res);
        let (res_len, res) = ProjectSvg._svg_location_logo(res_len, res);
        let (res_len, res) = ProjectSvg._svg_breakline(res_len, res);
        let (res_len, res) = ProjectSvg._svg_defs(res_len, res);
        let (res_len, res) = ProjectSvg._svg_project_image(res_len, res);
        let (res_len, res) = ProjectSvg._svg_suffix(res_len, res);

        return (res_len, res);
    }

    func _contractProperties{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, value: Uint256, tokenId: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        // TODO: better Uint256 to string conversion
        let value_ss = felt31_to_short_string(value.low);
        assert res[res_len + 0] = '[{"trait_type":"Value",';
        assert res[res_len + 1] = '"value":';
        assert res[res_len + 2] = value_ss;
        assert res[res_len + 3] = '}]';

        return (res_len + 4, res);
    }
}
