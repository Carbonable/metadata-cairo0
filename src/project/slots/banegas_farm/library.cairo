// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.cairo.common.uint256 import Uint256

from starkware.starknet.common.syscalls import get_contract_address

// Project dependencies
from erc3525.IERC3525Full import IERC3525Full as IERC3525

// Local dependencies
from src.project.utils.ascii import (
    felt_to_short_string,
    array_concat,
    SQUARE_METERS_CHAR,
    smol_felt_to_ss,
)
from src.project.utils.assert_helper import Assert
from src.project.utils.type import _uint_to_felt
from src.project.slots.banegas_farm.data.image import ProjectSVG, ProjectJPG
from src.project.slots.banegas_farm.data.project import ProjectData, AssetData
from src.project.slots.common.library import DescriptionData

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

        let (slot) = IERC3525.slotOf(instance, token_id);
        let (slot_felt) = _uint_to_felt(slot);
        let (slot_ss_len, slot_ss) = felt_to_short_string(slot_felt);

        let (value) = IERC3525.valueOf(instance, token_id);
        let (value_felt) = _uint_to_felt(value);
        let (value_ss_len, value_ss) = felt_to_short_string(value_felt);

        let (total_value) = IERC3525.totalValue(instance, slot);
        let project_name = ProjectData.get_name();
        assert res[0] = 'data:application/json,{"name":';
        let (res_len, res) = _token_name(1, res, instance, token_id);
        assert res[res_len] = ',"description":"';
        let (res_len, res) = _token_description(res_len + 1, res, instance, project_name);
        assert res[res_len] = '","image":"';
        let (res_len, res) = _token_image(res_len + 1, res, instance, value, total_value);
        assert res[res_len] = '","slot":';
        let (res_len, res) = array_concat(res_len + 1, res, slot_ss_len, slot_ss);
        assert res[res_len] = ',"value":';
        let (res_len, res) = array_concat(res_len + 1, res, value_ss_len, value_ss);
        assert res[res_len] = ',"attributes":';
        let (res_len, res) = _token_properties(
            res_len + 1, res, instance, value, total_value, value_ss_len, value_ss
        );
        assert res[res_len] = '}';

        return (res_len + 1, res);
    }

    func slot_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        slot: Uint256
    ) -> (uri_len: felt, uri: felt*) {
        alloc_locals;

        // [Check] Uint256 compliance
        Assert.u256(slot);

        let (local res: felt*) = alloc();
        let (local instance) = get_contract_address();

        // [Effect] Compute and return corresponding slot URI
        let (slot_felt) = _uint_to_felt(slot);
        let (slot_ss_len, slot_ss) = felt_to_short_string(slot_felt);

        assert res[0] = 'data:application/json,{"name":"';
        let name = ProjectData.get_name();
        assert res[1] = name;
        assert res[2] = '","description":"';
        let (res_len, res) = _slot_description(3, res, name);
        assert res[res_len] = '","image":"';
        let (res_len, res) = _slot_image(res_len + 1, res, instance);
        assert res[res_len] = '","slot number":';
        let (res_len, res) = array_concat(res_len + 1, res, slot_ss_len, slot_ss);
        assert res[res_len] = ',"attributes":';
        let (res_len, res) = _slot_properties(res_len + 1, res, instance);
        assert res[res_len] = '}';

        return (res_len + 1, res);
    }

    //
    // Internals
    //

    //
    // Slot uri construction
    //

    func _slot_properties{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        assert res[res_len + 0] = '[';
        let (res_len, res) = _project_properties_list(res_len + 1, res, instance);
        assert res[res_len + 0] = ']';
        return (res_len + 1, res);
    }

    func _project_properties_list{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        let developer = ProjectData.get_developer();
        let (res_len, res) = _add_attribute(res_len, res, 0, 'Project developer', developer);

        assert res[res_len + 0] = ',';
        let certifier = ProjectData.get_certifier();
        let (res_len, res) = _add_attribute(res_len + 1, res, 0, 'Project certifier', certifier);

        assert res[res_len + 0] = ',';
        let area = ProjectData.get_area();
        let (area_ss) = smol_felt_to_ss(area);
        let (res_len, res) = _add_attribute(
            res_len + 1, res, 'number', 'Project area (ha)', area_ss
        );

        assert res[res_len + 0] = ',';
        let country = ProjectData.get_country();
        let (res_len, res) = _add_attribute(res_len + 1, res, 0, 'Project country', country);

        assert res[res_len + 0] = ',';
        let end_date_ss = ProjectData.get_end_date();
        let (res_len, res) = _add_attribute(res_len + 1, res, 0, 'Project end date', end_date_ss);

        assert res[res_len + 0] = ',';
        let projected_cu = ProjectData.get_projected_cu();
        let (projected_cu_ss) = smol_felt_to_ss(projected_cu);
        let (res_len, res) = _add_attribute(
            res_len + 1, res, 'number', 'Project projected carbon units', projected_cu_ss
        );

        assert res[res_len + 0] = ',';
        let color = ProjectData.get_color();
        let (res_len, res) = _add_attribute(res_len + 1, res, 0, 'Project color', color);

        assert res[res_len + 0] = ',';
        let type = ProjectData.get_type();
        let (res_len, res) = _add_attribute(res_len + 1, res, 0, 'Project type', type);

        assert res[res_len + 0] = ',';
        let category = ProjectData.get_category();
        let (res_len, res) = _add_attribute(res_len + 1, res, 0, 'Project category', category);

        assert res[res_len + 0] = ',';
        let status = ProjectData.get_status();
        let (res_len, res) = _add_attribute(res_len + 1, res, 0, 'Project status', status);

        assert res[res_len + 0] = ',';
        let source = ProjectData.get_source();
        let (res_len, res) = _add_attribute(res_len + 1, res, 0, 'Project source', source);

        return (res_len, res);
    }

    func _slot_description{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, project_name_ss: felt
    ) -> (res_len: felt, res: felt*) {
        let (res_len, res) = DescriptionData._generate_slot_description(
            res_len, res, project_name_ss
        );
        return (res_len, res);
    }

    func _slot_image{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt
    ) -> (res_len: felt, res: felt*) {
        assert res[res_len + 0] = 'data:image/jpeg;base64,';
        let (res_len, res) = ProjectJPG._jpg_slot_image(res_len + 1, res);
        return (res_len, res);
    }

    //
    // construct token uri
    //

    func _token_name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, token_id: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        // TODO: change to project name
        let name = ProjectData.get_name();

        let (token) = _uint_to_felt(token_id);
        let (token_ss_len, token_ss) = felt_to_short_string(token);

        assert res[res_len] = '"';
        assert res[res_len + 1] = name;
        assert res[res_len + 2] = ' #';
        let (res_len, res) = array_concat(res_len + 3, res, token_ss_len, token_ss);
        assert res[res_len] = '"';
        return (res_len + 1, res);
    }

    func _token_description{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, project_name_ss: felt
    ) -> (res_len: felt, res: felt*) {
        let (res_len, res) = DescriptionData._generate_slot_description(
            res_len, res, project_name_ss
        );
        return (res_len, res);
    }

    func _token_image{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*, instance: felt, value: Uint256, total_value: Uint256
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        // MIME format
        assert res[res_len] = 'data:image/svg+xml,';
        // SVG content
        let (res_len, res) = ProjectSVG._svg_def_start(res_len + 1, res);
        let (res_len, res) = ProjectSVG._svg_asset_color_styles(res_len, res, value, total_value);
        let (res_len, res) = ProjectSVG._svg_border(res_len, res);
        let (res_len, res) = ProjectSVG._svg_carbonable_logo(res_len, res);
        let (res_len, res) = ProjectSVG._svg_background_image(res_len, res);
        let (res_len, res) = ProjectSVG._svg_country_flag(res_len, res);
        let (res_len, res) = ProjectSVG._svg_icons(res_len, res);
        let (res_len, res) = ProjectSVG._add_svg_image_metadata(res_len, res, value, total_value);
        let (res_len, res) = ProjectSVG._svg_def_end(res_len, res);

        return (res_len, res);
    }

    func _token_properties{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt,
        res: felt*,
        instance: felt,
        value: Uint256,
        total_value: Uint256,
        value_ss_len: felt,
        value_ss: felt*,
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;
        assert res[res_len + 0] = '[';
        let (res_len, res) = _project_properties_list(res_len + 1, res, instance);
        assert res[res_len + 0] = ',';
        let (res_len, res) = _token_properties_list(
            res_len + 1, res, instance, value, total_value, value_ss_len, value_ss
        );
        assert res[res_len + 0] = ']';
        return (res_len + 1, res);
    }

    func _token_properties_list{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt,
        res: felt*,
        instance: felt,
        value: Uint256,
        total_value: Uint256,
        value_ss_len: felt,
        value_ss: felt*,
    ) -> (res_len: felt, res: felt*) {
        alloc_locals;

        let (total_value_felt) = _uint_to_felt(total_value);
        let (total_value_ss_len, total_value_ss) = felt_to_short_string(total_value_felt);

        let area_ss = AssetData.get_area_ss(value, total_value);
        let type = ('Asset area (m' * 256 ** 2 + SQUARE_METERS_CHAR) * 256 + ')';  // '²' = [194, 178] as bytes
        let (res_len, res) = _add_attribute(res_len, res, 'number', type, area_ss);

        assert res[res_len + 0] = ',';
        let projected_cu_ss = AssetData.get_projected_cu_ss(value, total_value);
        let (res_len, res) = _add_attribute(
            res_len + 1, res, 'number', 'Asset avg. capacity (t/y)', projected_cu_ss
        );

        assert res[res_len + 0] = ',';
        let (res_len, res) = _add_array_attribute(
            res_len + 1, res, 'number', 'Token shares', value_ss_len, value_ss
        );

        assert res[res_len + 0] = ',';
        let (res_len, res) = _add_array_attribute(
            res_len + 1, res, 'number', 'Slot total shares', total_value_ss_len, total_value_ss
        );

        return (res_len, res);
    }

    func _add_attribute{range_check_ptr}(
        res_len: felt, res: felt*, display_type: felt, trait_type: felt, attribute: felt
    ) -> (res_len: felt, res: felt*) {
        if (display_type == 0) {
            assert res[res_len + 0] = '{"trait_type":"';
            assert res[res_len + 1] = trait_type;
            assert res[res_len + 2] = '","value":"';
            assert res[res_len + 3] = attribute;
            assert res[res_len + 4] = '"}';
            return (res_len + 5, res);
        }
        if (display_type == 'number') {
            assert res[res_len + 0] = '{"display_type":"';
            assert res[res_len + 1] = display_type;
            assert res[res_len + 2] = '","trait_type":"';
            assert res[res_len + 3] = trait_type;
            assert res[res_len + 4] = '","value":';
            assert res[res_len + 5] = attribute;
            assert res[res_len + 6] = '}';
            return (res_len + 7, res);
        }

        assert res[res_len + 0] = '{"display_type":"';
        assert res[res_len + 1] = display_type;
        assert res[res_len + 2] = '","trait_type":"';
        assert res[res_len + 3] = trait_type;
        assert res[res_len + 4] = '","value":';
        assert res[res_len + 5] = attribute;
        assert res[res_len + 6] = '}';
        return (res_len + 7, res);
    }

    func _add_array_attribute{range_check_ptr}(
        res_len: felt,
        res: felt*,
        display_type: felt,
        trait_type: felt,
        attribute_ss_len: felt,
        attribute_ss: felt*,
    ) -> (res_len: felt, res: felt*) {
        assert res[res_len + 0] = '{"display_type":"';
        assert res[res_len + 1] = display_type;
        assert res[res_len + 2] = '","trait_type":"';
        assert res[res_len + 3] = trait_type;
        assert res[res_len + 4] = '","value":';
        let (res_len, res) = array_concat(res_len + 5, res, attribute_ss_len, attribute_ss);
        assert res[res_len + 0] = '}';
        return (res_len + 1, res);
    }
}
