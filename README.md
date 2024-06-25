
# Luvit bit64

This is a module to handle 64-bit integers in either Lua 5.3+ or Luajit environments for Luvit.

This is accomplished by using `int64_t` in Luajit and 64-bit native integers in Lua 5.3+.

## Installation

```sh
lit install truemedian/bit64
```

## Usage

```lua
local bit64 = require('bit64')

local a = bit64.tointeger('1234567890abcdef')
local b = bit64.tointeger('fedcba0987654321')

print(bit64.tohex(bit64.band(a, b)))        --> 1214120880214121
print(bit64.tohex(bit64.bor(a, b)))         --> fefcfe7997efcfef
print(bit64.tohex(bit64.bxor(a, b)))        --> ece8ec7117ce8ece
print(bit64.tohex(bit64.lshift(a, 4)))      --> 234567890abcdef0
print(bit64.tohex(bit64.rshift(b, 4)))      --> 0fedcba098765432
print(bit64.tohex(bit64.arshift(b, 4)))     --> ffedcba098765432
print(bit64.tohex(bit64.rol(a, 4)))         --> 234567890abcdef1
print(bit64.tohex(bit64.ror(a, 4)))         --> f1234567890abcde
print(bit64.tohex(bit64.bswap(a)))          --> efcdab9078563412
print(bit64.tohex(bit64.bnot(a)))           --> edcba9876f543210
print(bit64.popcount(a), bit64.popcount(b)) --> 32 32
print(bit64.clz(a), bit64.clz(b))           --> 3 0
print(bit64.ctz(a), bit64.ctz(b))           --> 0 0
```

## Documentation

### bit64.tointeger(number)

Converts a number to a 64-bit integer. Floating point numbers are truncated to 32-bits and then sign-extended to 64-bits.

This is the only function that sign extends the high bit of the number. All other functions only sign extend negative numbers.

### bit64.tonumber(integer)

Converts a 64-bit integer to a normal Lua number. This may incur a loss of precision.

### bit64.tohex(integer[, n])

Converts an integer to a hexadecimal string. The optional second argument specifies the number of digits to generate.

If `n` is negative, the hex digits are uppercase, otherwise they are lowercase. `n` defaults to 16 (all represented digits).

### bit64.tobytes(integer)

Converts an integer to a string of 8 bytes in little-endian order.

### bit64.bnot(a)

Returns the bitwise NOT of a 64-bit integer.

Every bit in the result will be the inverse of the corresponding bit in the input.

### bit64.band(a, b)

Returns the bitwise AND of two 64-bit integers.

Each bit of the result is `1` if the corresponding bit of `a` and `b` are `1`, otherwise it is `0`.

### bit64.bor(a, b)

Returns the bitwise OR of two 64-bit integers.

Each bit of the result is `1` if the corresponding bit of either `a` or `b` is `1`, otherwise it is `0`.

### bit64.bxor(a, b)

Returns the bitwise XOR of two 64-bit integers.

Each bit of the result is `1` if the corresponding bit of `a` and `b` are different, otherwise it is `0`.

### bit64.lshift(a, n)

Returns the bitwise left shift of a 64-bit integer.

Each bit of the result is shifted `n` places to the left. Any new bits are replaced with `0` and any bits shifted off the end are discarded.

Shift amounts are modulo 64, so `lshift(a, 64)` is equivalent to `lshift(a, 0)`.

### bit64.rshift(a, n)

Returns the bitwise right shift of a 64-bit integer.

Each bit of the result is shifted `n` places to the right. Any new bits are replaced with `0` and any bits shifted off the end are discarded.

Shift amounts are modulo 64, so `rshift(a, 64)` is equivalent to `rshift(a, 0)`.

### bit64.arshift(a, n)

Returns the arithmetic right shift of a 64-bit integer.

Each bit of the result is shifted `n` places to the right. Any new bits are replaced with the sign bit of the input and any bits shifted off the end are discarded.

This behavior is useful for keeping the signedness of a number when shifting.

Shift amounts are modulo 64, so `arshift(a, 64)` is equivalent to `arshift(a, 0)`.

### bit64.rol(a, n)

Returns the bitwise left rotation of a 64-bit integer.

Each bit of the result is rotated `n` places to the left. Bits shifted off the end are rotated back to the beginning.

Rotate amounts are modulo 64, so `rol(a, 64)` is equivalent to `rol(a, 0)`.

### bit64.ror(a, n)

Returns the bitwise right rotation of a 64-bit integer.

Each bit of the result is rotated `n` places to the right. Bits shifted off the end are rotated back to the beginning.

Rotate amounts are modulo 64, so `ror(a, 64)` is equivalent to `ror(a, 0)`.

### bit64.bswap(a)

Returns the byte-swapped representation of a 64-bit integer.

This is necessary to convert between little-endian and big-endian representations.

### bit64.popcount(a)

Returns the number of bits set to `1` in a 64-bit integer.

### bit64.clz(a)

Returns the number of leading (most-significant) zeros in a 64-bit integer.

If the input is `0`, the result is `64`.

### bit64.ctz(a)

Returns the number of trailing (least-significant) zeros in a 64-bit integer.

If the input is `0`, the result is `64`.

### Arithmetic

The integers provided by this library support all basic arithmetic operations: `+`, `-`, `*`, `/`, `%`, `^`, and unary `-`.

The division operator `/` performs integer division, discarding any remainder.

The modulo operator `%` returns the remainder of integer division.

You likely need to use `bit64.tonumber` before passing the result to other functions that expect numbers.
