// SPDX-License-Identifier: Apache-2.0

%lang starknet

from src.project.utils.ascii import build_date_ss

@external
func test_concat_felt{range_check_ptr}() { 
    let hello = 8;
    let world = 2022;
    let res = build_date_ss(hello, world);
    assert res = '08/2022';
    return ();
}
