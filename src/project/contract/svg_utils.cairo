// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.memcpy import memcpy

namespace ContractSVG {
    func _svg_prefix{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*
    ) -> (res_len: felt, res: felt*) {
        memcpy(
            res + res_len,
            new (
                '<svg width=\"700\" height=\"925',
                '\" viewBox=\"0 0 700 925\" fill',
                '=\"none\" xmlns=\"http://www.w3',
                '.org/2000/svg\">',
            ),
            4,
        );
        return (res_len + 4, res);
    }

    func _svg_logo_path{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*
    ) -> (res_len: felt, res: felt*) {
        memcpy(
            res + res_len,
            new (
                '<path fill-rule=\"evenodd\" cli',
                'p-rule=\"evenodd\" d=\"M314.632',
                ' 396.937C258.673 470.738 224.38',
                '8 518.785 224.388 574.439C224.3',
                '88 643.71 280.729 700.078 350 7',
                '00.104C419.271 700.078 475.612 ',
                '643.71 475.612 574.439C475.612 ',
                '518.785 441.314 470.724 385.368',
                ' 396.937L384.916 396.34C373.723',
                ' 381.572 362.06 366.185 350.423',
                ' 350.053H349.579C337.785 333.70',
                '2 325.978 318.118 314.633 303.1',
                '68C258.675 229.38 224.389 181.3',
                '2 224.389 125.665C224.389 92.10',
                '6 237.464 60.5411 261.197 36.80',
                '8C284.917 13.0882 316.455 0 350',
                '.001 0C383.547 0.0131836 415.08',
                '6 13.0882 438.806 36.808C462.53',
                '9 60.5411 475.614 92.0928 475.6',
                '14 125.665C475.614 181.32 441.3',
                '15 229.38 385.37 303.168L384.91',
                '5 303.768C373.722 318.535 362.0',
                '61 333.92 350.425 350.052H627.6',
                '39C636.197 363.457 644.385 377.',
                '271 651.992 391.641C684.297 452',
                '.684 700 512.472 700 574.439C70',
                '0 621.655 690.729 667.509 672.4',
                '5 710.736C654.805 752.431 629.5',
                '8 789.86 597.474 821.966C565.36',
                '7 854.085 527.939 879.311 486.2',
                '44 896.942C443.044 915.208 397.',
                '228 924.479 350.053 924.492H349',
                '.96C302.785 924.479 256.956 915',
                '.208 213.756 896.942C172.061 87',
                '9.298 134.633 854.072 102.526 8',
                '21.966C70.4068 789.86 45.1813 7',
                '52.431 27.5499 710.736C9.27135 ',
                '667.496 0 621.641 0 574.439C0 5',
                '12.472 15.7032 452.684 48.0076 ',
                '391.641C55.6149 377.285 63.8032',
                ' 363.457 72.3614 350.052H349.57',
                '7C337.783 366.402 325.976 381.9',
                '86 314.632 396.937Z\" fill=\"ur',
                'l(#grad)\"/>',
            ),
            44,
        );
        return (res_len + 44, res);
    }

    func _svg_defs{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*
    ) -> (res_len: felt, res: felt*) {
        memcpy(
            res + res_len,
            new (
                '<defs><linearGradient id=\"grad',
                '\" x1=\"699.781\" y1=\"0\" x2=\',
                '"699.781\" y2=\"924.492\" gradi',
                'entUnits=\"userSpaceOnUse\"><st',
                'op offset=\"0.177366\" stop-col',
                'or=\"#0AF2AD\"/><stop offset=\"',
                '0.822634\" stop-color=\"#A8C4EF',
                '\"/></linearGradient></defs>',
            ),
            8,
        );
        return (res_len + 8, res);
    }

    func _svg_suffix{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*
    ) -> (res_len: felt, res: felt*) {
        assert res[res_len] = '</svg><!--Carbonable onchain-->';
        return (res_len + 1, res);
    }
}
