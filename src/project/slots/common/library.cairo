// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.memcpy import memcpy

namespace DescriptionData {
    func _generate_slot_description{range_check_ptr}(
        res_len: felt, res: felt*, project_name_ss: felt
    ) -> (res_len: felt, res: felt*) {
        memcpy(
            res + res_len,
            new (
                'Invest in ',
                project_name_ss,
                ', a meticulously chosen carbon ',
                'removal project. Earn projected',
                ', validated and audited carbon ',
                'credits throughout the project ',
                'lifespan; Enhance the carbon ca',
                'pture ability of the Earth, hel',
                'p safeguard biodiversity while ',
                'fortifying local community live',
                'lihoods.',
            ),
            11,
        );
        return (res_len + 11, res);
    }
}
