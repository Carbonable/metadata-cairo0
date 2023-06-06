// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.memcpy import memcpy

namespace DescriptionData {
    func _generate_contract_description{range_check_ptr}(res_len: felt, res: felt*) -> (
        res_len: felt, res: felt*
    ) {
        memcpy(
            res + res_len,
            new (
                'Unlock the simplest and most ef',
                'ficient path to invest in leadi',
                'ng nature regeneration initiati',
                'ves with Carbonable. Utilizing ',
                'cutting-edge technologies like ',
                'blockchain, satellite imagery, ',
                'and AI, we redefine carbon inve',
                'sting with unparalleled transpa',
                'rency, traceability, and operat',
                'ional efficiency. With Carbonab',
                'le, elevate your investments wh',
                'ile contributing positively to ',
                'our planet.',
            ),
            13,
        );
        return (res_len + 13, res);
    }
}
