// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_check
from starkware.cairo.common.memcpy import memcpy

from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

// Project dependencies
from openzeppelin.introspection.erc165.IERC165 import IERC165
from erc3525.IERC3525Full import IERC3525Full as IERC3525

// Local dependencies
from src.project.utils.ascii import felt_to_short_string, array_concat
from src.project.utils.assert_helper import Assert
from src.project.utils.type import _uint_to_felt
from src.project.slots.poc.data.image import ProjectSVG

namespace SlotMetadata {
    //
    // Getters
    //

    func token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_id: Uint256
    ) -> (uri_len: felt, uri: felt*) {
        alloc_locals;

        // [Check] Uint256 compliance
        Assert.u256(token_id);

        let (local res: felt*) = alloc();
        let (local instance) = get_contract_address();

        let (slot_u256) = IERC3525.slotOf(instance, token_id);
        let (slot) = _uint_to_felt(slot_u256);
        let (slot_ss_len, slot_ss) = felt_to_short_string(slot);

        let (value_u256) = IERC3525.valueOf(instance, token_id);
        let (value) = _uint_to_felt(value_u256);
        let (value_ss_len, value_ss) = felt_to_short_string(value);

        assert res[0] = 'data:application/json,{"name":';
        let (res_len, res) = _tokenName(1, res, instance, token_id);
        assert res[res_len] = ',"description":';
        let (res_len, res) = _tokenDescription(res_len + 1, res, instance, token_id);
        assert res[res_len] = ',"image":"';
        let (res_len, res) = _tokenImage(res_len + 1, res, instance, value_u256, token_id);
        assert res[res_len] = '","slot":';
        let (res_len, res) = array_concat(res_len + 1, res, slot_ss_len, slot_ss);
        assert res[res_len] = ',"value":';
        let (res_len, res) = array_concat(res_len + 1, res, value_ss_len, value_ss);
        assert res[res_len] = ',"attributes":';
        let (res_len, res) = _tokenProperties(res_len + 1, res, instance, value_u256, token_id);
        assert res[res_len] = '}';

        return (res_len + 1, res);
    }

    func slot_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        slot: Uint256
    ) -> (uri_len: felt, uri: felt*) {
        alloc_locals;

        // [Check] Uint256 compliance
        Assert.u256(slot);

        // [Effect] Compute and return corresponding slot URI
        let (slot_felt) = _uint_to_felt(slot);
        let (slot_ss_len, slot_ss) = felt_to_short_string(slot_felt);

        let (res: felt*) = alloc();
        assert res[0] = 'https://dev-carbonable-metadata';
        assert res[1] = '.fly.dev/collection/';
        let (res_len, res) = array_concat(2, res, slot_ss_len, slot_ss);
        return (res_len, res);
    }

    //
    // Internals
    //

    func _tokenName{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, token_id: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        // TODO: change to project name
        let (symbol) = IERC3525.symbol(instance);

        let (token) = _uint_to_felt(token_id);
        let (token_ss_len, token_ss) = felt_to_short_string(token);

        assert res[res_len] = '"';
        assert res[res_len + 1] = symbol;
        assert res[res_len + 2] = ' #';
        let (res_len, res) = array_concat(res_len + 3, res, token_ss_len, token_ss);
        assert res[res_len] = '"';
        return (res_len + 1, res);
    }

    func _tokenDescription{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, token_id: Uint256
    ) -> (res_len: felt, res: felt*) {
        assert res[res_len] = '"dummy token description"';
        return (res_len + 1, res);
    }

    func _tokenImage{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, value: Uint256, token_id: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        // MIME format
        assert res[res_len] = 'data:image/svg+xml,';
        // SVG content
        let (res_len, res) = ProjectSVG._svg_def(res_len + 1, res);
        let (res_len, res) = ProjectSVG._svg_background_outline(res_len, res);
        let (res_len, res) = ProjectSVG._svg_carbonable_logo(res_len, res);
        let (res_len, res) = ProjectSVG._svg_background_image(res_len, res);
        let (res_len, res) = ProjectSVG._svg_icons(res_len, res);
        let (res_len, res) = ProjectSVG._svg_location_logo(res_len, res);
        let (res_len, res) = ProjectSVG._svg_breakline(res_len, res);
        let (res_len, res) = ProjectSVG._svg_defs(res_len, res);
        let (res_len, res) = ProjectSVG._svg_project_image(res_len, res);
        let (res_len, res) = _add_svg_image_metadata(res_len, res, value);
        let (res_len, res) = ProjectSVG._svg_suffix(res_len, res);

        return (res_len, res);
    }

    func _add_svg_image_metadata{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, value: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        let (value_felt) = _uint_to_felt(value);
        let (value_ss_len, value_ss) = felt_to_short_string(value_felt);
        memcpy(
            res + res_len,
            new (
                '<text y=\"561\" font-size=\"33\',
                '" font-family=\"sans\" fill=\"#',
                'EFECEA\"> <tspan font-weight=\"',
                'bold\" style=\"text-transform: ',
                'uppercase;\" x=\"50\" dy=\"0\">',
                'Madagascar</tspan> <tspan x=\"5',
                '0\" dy=\"1.8em\">Project by <ts',
                'pan font-weight=\"bold\">Forest',
                'Calling Action</tspan></tspan> ',
                '<tspan x=\"50\" dy=\"1.6em\">Ce',
                'rtified by <tspan font-weight=\',
                '"bold\">Wildsense</tspan></tspa',
                'n></text><text y=\"561\" font-s',
                'ize=\"33\" font-family=\"sans\"',
                ' fill=\"#0AF2AD\" text-anchor=\',
                '"end\"> <tspan x=\"930\" dy=\"1',
                '.8em\">100m2</tspan> <tspan x=\',
                '"920\" dy=\"1.6em\">Ends 2052</',
                'tspan></text><text y=\"825\" fo',
                'nt-family=\"sans\" fill=\"#EFEC',
                'EA\"> <tspan x=\"355\" dy=\"0\"',
                ' font-size=\"68\" textLength=\"',
                '35%\" >Manjarisoa</tspan> <tspa',
                'n x=\"355\" dy=\"76\" font-size',
                '=\"65\" textLength=\"24%\" font',
                '-weight=\"bold\">',
            ),
            26,
        );
        let (res_len, res) = array_concat(res_len + 26, res, value_ss_len, value_ss);
        memcpy(
            res + res_len,
            new (
                '</tspan>',
                '</text><use y=\"855\" x=\"610\"',
                ' href=\"#T\" /><text y=\"905\" ',
                'font-family=\"sans\" fill=\"#EF',
                'ECEA\"> <tspan x=\"675\" font-s',
                'ize=\"45\" textLength=\"12%\" >',
                '/ year</tspan></text>',
            ),
            7,
        );
        return (res_len + 7, res);
    }

    func _tokenProperties{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, value: Uint256, token_id: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;

        let (value_felt) = _uint_to_felt(value);
        let (value_ss_len, value_ss) = felt_to_short_string(value_felt);

        assert res[res_len + 0] = '[{"trait_type":"Value",';
        assert res[res_len + 1] = '"value":';
        let (res_len, res) = array_concat(res_len + 2, res, value_ss_len, value_ss);
        assert res[res_len] = '}]';

        return (res_len + 1, res);
    }
}
