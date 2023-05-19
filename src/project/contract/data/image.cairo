// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.memcpy import memcpy

namespace ContractSVG {
    func _svg_carbonable_up_logo{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        res_len: felt, res: felt*
    ) -> (res_len: felt, res: felt*) {
        memcpy(
            res + res_len,
            new (
                '<svg width=\"1080\" height=\"10',
                '80\" viewBox=\"0 0 1080 1080\" ',
                'fill=\"none\" xmlns=\"http://ww',
                'w.w3.org/2000/svg\"> <rect widt',
                'h=\"1080\" height=\"1080\" fill',
                '=\"white\" /> <path fill-rule=\',
                '"evenodd\" clip-rule=\"evenodd\',
                '" d=\"M511.843 487.724C467.052 ',
                '546.797 439.609 585.256 439.609',
                ' 629.804C439.609 685.251 484.70',
                '7 730.37 540.154 730.391C595.60',
                '1 730.37 640.699 685.251 640.69',
                '9 629.804C640.699 585.256 613.2',
                '45 546.786 568.464 487.724L568.',
                '102 487.246C559.142 475.425 549',
                '.807 463.109 540.492 450.195H53',
                '9.817C530.376 437.108 520.926 4',
                '24.634 511.845 412.667C467.053 ',
                '353.604 439.61 315.135 439.61 2',
                '70.587C439.61 243.725 450.076 2',
                '18.459 469.073 199.462C488.059 ',
                '180.476 513.304 169.999 540.155',
                ' 169.999C567.006 170.01 592.251',
                ' 180.476 611.237 199.462C630.23',
                '4 218.459 640.7 243.714 640.7 2',
                '70.587C640.7 315.135 613.246 35',
                '3.604 568.465 412.667L568.103 4',
                '13.144C559.144 424.965 549.808 ',
                '437.282 540.493 450.195H762.387',
                'C769.237 460.925 775.791 471.98',
                '3 781.88 483.485C807.738 532.34',
                '6 820.308 580.203 820.308 629.8',
                '04C820.308 667.597 812.886 704.',
                '301 798.256 738.901C784.132 772',
                '.275 763.941 802.235 738.242 82',
                '7.934C712.542 853.644 682.583 8',
                '73.835 649.209 887.948C614.63 9',
                '02.568 577.957 909.989 540.196 ',
                '910H540.122C502.361 909.989 465',
                '.678 902.568 431.099 887.948C39',
                '7.725 873.825 367.765 853.633 3',
                '42.066 827.934C316.356 802.235 ',
                '296.165 772.275 282.052 738.901',
                'C267.421 704.29 260 667.586 260',
                ' 629.804C260 580.203 272.569 53',
                '2.346 298.427 483.485C304.516 4',
                '71.993 311.071 460.925 317.921 ',
                '450.195H539.816C530.375 463.283',
                ' 520.924 475.757 511.843 487.72',
                '4Z\" fill=\"url(#grad)\" /> <de',
                'fs> <linearGradient id=\"grad\"',
                ' x1=\"820.132\" y1=\"169.999\" ',
                'x2=\"820.132\" y2=\"910\" gradi',
                'entUnits=\"userSpaceOnUse\"> <s',
                'top offset=\"0.177366\" stop-co',
                'lor=\"#0AF2AD\" /> <stop offset',
                '=\"0.822634\" stop-color=\"#A8C',
                '4EF\" /> </linearGradient> </de',
                'fs></svg>',
            ),
            59,
        );
        return (res_len + 59, res);
    }
}
