// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies

from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_nn_le
from starkware.cairo.common.uint256 import Uint256

// Project dependencies
from src.project.utils.type import _uint_to_felt
from src.project.utils.ascii import float_to_ss, build_date_ss

//
// Constants
//

const ONE_HA_IN_M2 = 10000;

const PROJECT_NAME = 'Banegas Farm';
const PROJECT_DEVELOPER = 'Corcovado Foundation';
const PROJECT_CERTIFIER = 'Wildsense';
const PROJECT_AREA = 25;
const PROJECT_COUNTRY = 'Costa Rica';
const PROJECT_END_YEAR = 2052;  // mutable storage
const PROJECT_END_MONTH = 12;  // mutable storage
const PROJECT_DURATION_IN_YEARS = PROJECT_END_YEAR - 2022;
const PROJECT_PROJECTED_CU = 1573;
const PROJECT_COLOR = 'Green';
const PROJECT_TYPE = 'Forest';
const PROJECT_CATEGORY = 'Regeneration';
const PROJECT_STATUS = 'Active';  // mutable storage?
const PROJECT_SOURCE = 'Carbonable';

namespace ProjectData {
    func get_name{range_check_ptr}() -> felt {
        return PROJECT_NAME;
    }

    func get_developer{range_check_ptr}() -> felt {
        return PROJECT_DEVELOPER;
    }

    func get_certifier{range_check_ptr}() -> felt {
        return PROJECT_CERTIFIER;
    }

    func get_area{range_check_ptr}() -> felt {
        return PROJECT_AREA;
    }

    func get_country{range_check_ptr}() -> felt {
        return PROJECT_COUNTRY;
    }

    func get_end_year{range_check_ptr}() -> felt {
        return PROJECT_END_YEAR;
    }

    func get_end_month{range_check_ptr}() -> felt {
        return PROJECT_END_MONTH;
    }

    func get_end_date{range_check_ptr}() -> felt {
        return build_date_ss(PROJECT_END_MONTH, PROJECT_END_YEAR);
    }

    func get_duration{range_check_ptr}() -> felt {
        return PROJECT_DURATION_IN_YEARS;
    }

    func get_projected_cu{range_check_ptr}() -> felt {
        return PROJECT_PROJECTED_CU;
    }

    func get_color{range_check_ptr}() -> felt {
        return PROJECT_COLOR;
    }

    func get_type{range_check_ptr}() -> felt {
        return PROJECT_TYPE;
    }

    func get_category{range_check_ptr}() -> felt {
        return PROJECT_CATEGORY;
    }

    func get_status{range_check_ptr}() -> felt {
        return PROJECT_STATUS;
    }

    func get_source{range_check_ptr}() -> felt {
        return PROJECT_SOURCE;
    }
}

namespace AssetData {
    // The number of DECIMALS we want to display in a float
    // DECIMALS = 5;
    const DECIMALS_MUL_5 = 10 ** 5;  // replace exponent by DECIMALS
    const PAD_CAP_5 = 256 ** (5 - 1);  // replace first term in exponent to pad to DECIMALS decimals

    // DECIMALS = 3;
    const DECIMALS_MUL_3 = 10 ** 3;  // replace exponent by DECIMALS
    const PAD_CAP_3 = 256 ** (3 - 1);  // replace first term in exponent to pad to DECIMALS decimals

    func _get_area{range_check_ptr}(value: Uint256, total_value: Uint256) -> (
        int: felt, frac: felt
    ) {
        let total_area_ha = ProjectData.get_area();

        let (value_felt) = _uint_to_felt(value);
        let (total_value_felt) = _uint_to_felt(total_value);

        // Compute the area in m2 from total area in ha
        let numerator = value_felt * total_area_ha * ONE_HA_IN_M2 * DECIMALS_MUL_3;  // Should be much less than 2**128
        let denominator = total_value_felt;
        let (tmp, _) = unsigned_div_rem(numerator, denominator);
        let (int, frac) = unsigned_div_rem(tmp, DECIMALS_MUL_3);
        return (int=int, frac=frac);
    }

    func get_image_color_ss{range_check_ptr}(value: Uint256, total_value: Uint256) -> felt {
        let (area_int, _) = _get_area(value, total_value);
        if (area_int == 0) {
            return 'red';
        }
        let area_le_100 = is_nn_le(area_int, 100);
        if (TRUE == area_le_100) {
            return '#cd7f32';
        }
        let area_le_1k = is_nn_le(area_int, 1000);
        if (TRUE == area_le_1k) {
            return 'silver';
        }
        return 'gold';
    }

    func get_area_image_ss{range_check_ptr}(value: Uint256, total_value: Uint256) -> felt {
        let (area_int, area_frac) = _get_area(value, total_value);
        if (area_int == 0 and area_frac == 0) {
            return '0';
        }
        let area_gt_1k = is_nn_le(1000, area_int);
        if (TRUE == area_gt_1k) {
            let (int, frac) = unsigned_div_rem(area_int, 1000);
            let res = float_to_ss(int, frac, PAD_CAP_3);
            let res = res * 256 ** 2 + 'k ';
            return res;
        }
        let res = float_to_ss(area_int, area_frac, PAD_CAP_3);
        return res * 256 + ' ';
    }

    func get_area_ss{range_check_ptr}(value: Uint256, total_value: Uint256) -> felt {
        let (area_int, area_frac) = _get_area(value, total_value);
        let res = float_to_ss(area_int, area_frac, PAD_CAP_3);
        return res;
    }

    func get_projected_cu_ss{range_check_ptr}(value: Uint256, total_value: Uint256) -> felt {
        let projected_cu = ProjectData.get_projected_cu();
        let duration = ProjectData.get_duration();

        let (value_felt) = _uint_to_felt(value);
        let (total_value_felt) = _uint_to_felt(total_value);

        // Compute the asset's average annual projected carbon units
        let numerator = value_felt * projected_cu * DECIMALS_MUL_5;  // Should be much less than 2**128
        let denominator = total_value_felt * duration;
        let (tmp, _) = unsigned_div_rem(numerator, denominator);
        let (int, frac) = unsigned_div_rem(tmp, DECIMALS_MUL_5);
        let res = float_to_ss(int, frac, PAD_CAP_5);
        return res;
    }
}
