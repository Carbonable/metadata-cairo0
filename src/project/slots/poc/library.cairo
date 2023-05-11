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
from src.project.utils.svg import ProjectSvg, felt31_to_short_string
from src.project.utils.assert_helper import Assert

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

        // TODO: better Uint256 to felt support
        let (slot) = IERC3525.slotOf(instance, token_id);
        let slot_ss = felt31_to_short_string(slot.low);

        let (value) = IERC3525.valueOf(instance, token_id);
        let value_ss = felt31_to_short_string(value.low);

        assert res[0] = 'data:application/json,{"name":';
        let (res_len, res) = _tokenName(1, res, instance, token_id);
        assert res[res_len] = ',"description":';
        let (res_len, res) = _tokenDescription(res_len + 1, res, instance, token_id);
        assert res[res_len] = ',"image":"';
        let (res_len, res) = _tokenImage(res_len + 1, res, instance, value, token_id);
        assert res[res_len] = '","slot":';
        assert res[res_len + 1] = slot_ss;
        assert res[res_len + 2] = ',"value":';
        assert res[res_len + 3] = value_ss;
        assert res[res_len + 4] = ',"attributes":';
        let (res_len, res) = _tokenProperties(res_len + 5, res, instance, value, token_id);
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
        let slot_ss = felt31_to_short_string(slot.low);

        let (res: felt*) = alloc();
        assert res[0] = 'https://dev-carbonable-metadata';
        assert res[1] = '.fly.dev/collection/';
        assert res[2] = slot_ss;
        return (3, res);
    }

    func contract_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        uri_len: felt, uri: felt*
    ) {
        alloc_locals;

        let (res: felt*) = alloc();
        assert res[0] = 'https://dev-carbonable-metadata';
        assert res[1] = '.fly.dev/collection';

        return (2, res);
    }

    //
    // Internals
    //

    func _tokenName{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, token_id: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        let (symbol) = IERC3525.symbol(instance);
        // TODO better Uint256 to felt support
        let token_ss = felt31_to_short_string(token_id.low);
        assert res[res_len] = '"';
        assert res[res_len + 1] = symbol;
        assert res[res_len + 2] = ' #';
        assert res[res_len + 3] = token_ss;
        assert res[res_len + 4] = '"';
        return (res_len + 5, res);
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
        let (res_len, res) = ProjectSvg._svg_def(res_len + 1, res);
        let (res_len, res) = ProjectSvg._svg_background_outline(res_len, res);
        let (res_len, res) = ProjectSvg._svg_carbonable_logo(res_len, res);
        let (res_len, res) = ProjectSvg._svg_background_image(res_len, res);
        let (res_len, res) = ProjectSvg._svg_icons(res_len, res);
        let (res_len, res) = ProjectSvg._svg_location_logo(res_len, res);
        let (res_len, res) = ProjectSvg._svg_breakline(res_len, res);
        let (res_len, res) = ProjectSvg._svg_defs(res_len, res);
        let (res_len, res) = ProjectSvg._svg_project_image(res_len, res);
        let (res_len, res) = _add_svg_image_metadata(res_len, res, value);
        let (res_len, res) = ProjectSvg._svg_suffix(res_len, res);

        return (res_len, res);
    }

    func _add_svg_image_metadata{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, value: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        let value_ss = felt31_to_short_string(value.low);
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
        assert res[res_len + 26] = value_ss;
        memcpy(
            res + res_len + 27,
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
        return (res_len + 27 + 7, res);
    }

    func _tokenProperties{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, value: Uint256, token_id: Uint256
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
