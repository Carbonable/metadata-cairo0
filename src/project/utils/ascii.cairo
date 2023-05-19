// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, split_int, assert_in_range
from starkware.cairo.common.math_cmp import is_nn_le
from starkware.cairo.common.memcpy import memcpy

const MAX_SHORT_STRING = 10 ** 31;
const SHORT_STRING_PADDING = 0x30303030303030303030303030303030303030303030303030303030303030;
const SQUARE_METERS_CHAR = 194 * 256 + 178;

func array_concat{range_check_ptr}(res_len: felt, res: felt*, array_len: felt, array: felt*) -> (
    res_len: felt, res: felt*
) {
    memcpy(res + res_len, array, array_len);
    return (res_len + array_len, res);
}

func felt_to_short_string{range_check_ptr}(x: felt) -> (res_len: felt, res: felt*) {
    alloc_locals;
    let (local limbs: felt*) = alloc();
    split_int(x, 3, MAX_SHORT_STRING, MAX_SHORT_STRING, limbs);

    let (res: felt*) = alloc();
    let (res_len) = _felt_limbs_to_short_strings(3, limbs, 0, res);
    return (res_len=res_len, res=res);
}

func _felt_limbs_to_short_strings{range_check_ptr}(
    n: felt, limbs: felt*, res_len: felt, res: felt*
) -> (res_len: felt) {
    alloc_locals;

    if (n == 0) {
        return (res_len=res_len);
    }

    let val = limbs[n - 1];

    if (val == 0 and res_len == 0) {
        if (n != 1) {
            return _felt_limbs_to_short_strings(n - 1, limbs, res_len, res);
        }
    }

    if (res_len == 0) {
        let tmp = _felt_to_ss_iter(val, 0, 1, TRUE);
        assert res[res_len] = tmp;
        return _felt_limbs_to_short_strings(n - 1, limbs, res_len + 1, res);
    }

    let tmp = _felt_to_ss_iter(val, 0, 1, FALSE);
    let tmp = tmp + SHORT_STRING_PADDING;
    assert res[res_len] = tmp;
    return _felt_limbs_to_short_strings(n - 1, limbs, res_len + 1, res);
}

func _felt_to_ss_iter{range_check_ptr}(x: felt, acc: felt, n: felt, no_pad: felt) -> felt {
    if (x == 0) {
        if (n == 1) {
            return ('0' * no_pad);
        }
        return (acc);
    }

    let (x, digit) = unsigned_div_rem(x, 10);
    return _felt_to_ss_iter(x, acc + ('0' * no_pad + digit) * n, n * 256, no_pad);
}

func smol_felt_to_ss{range_check_ptr}(value: felt) -> (res: felt) {
    let is_smol = is_nn_le(value, MAX_SHORT_STRING);
    assert TRUE = is_smol;

    let res = _felt_to_ss_iter(value, 0, 1, TRUE);
    return (res=res);
}

func pad_ss{range_check_ptr}(value: felt, char: felt, cap: felt) -> (res: felt) {
    assert_in_range(char, 0, 256);
    let (res) = _pad_ss_iter(value, char, value, cap);
    return (res=res);
}
func _pad_ss_iter{range_check_ptr}(value: felt, char: felt, acc: felt, cap: felt) -> (res: felt) {
    if (cap == 1) {
        return (res=acc);
    }
    let needs_padding = is_nn_le(value, cap);
    if (needs_padding == TRUE) {
        let (res) = _pad_ss_iter(value, char, acc + cap * char, cap / 256);
        return (res=res);
    }
    return (res=acc);
}

func float_to_ss{range_check_ptr}(int: felt, frac: felt, cap: felt) -> felt {
    alloc_locals;
    let (local int_ss) = smol_felt_to_ss(int);
    let (frac_ss) = smol_felt_to_ss(frac);
    let (frac_ss) = pad_ss(frac_ss, '0', cap);
    let res = (int_ss * 256 + '.') * 256 * cap + frac_ss;
    return res;
}
