local bit64
if pcall(require, 'luvi') then
    bit64 = require('./init.lua')
elseif pcall(require, 'ffi') then
    bit64 = loadfile('./libs/ffi.lua')()
else
    bit64 = loadfile('./libs/native.lua')()
end

local ffi = pcall(require, 'ffi')
local function int64(x)
    if ffi then
        return load('return ' .. x .. 'LL')()
    else
        return math.tointeger(x)
    end
end

local check_unary, check_unary_small, check_binary, check_ternary, check_binary_range, check_string_range

-- sanity checks
assert(0x7fffffff == 2147483647, 'broken hex literals')
assert(0xffffffff == -1 or 0xffffffff == 2 ^ 32 - 1, 'broken hex literals')
assert(tostring(-1) == '-1', 'broken tostring()')
assert(tostring(0xffffffff) == '-1' or tostring(0xffffffff) == '4294967295', 'broken tostring()')

-- Basic argument processing.
assert(bit64.tointeger(1) == 1)
assert(bit64.tonumber(1) == 1)
assert(bit64.band(1) == 1)
assert(bit64.bxor(1, 2) == 3)
assert(bit64.bor(1, 2, 4, 8, 16, 32, 64, 128) == 255)

local values_normal = {
    0, 1, -1, 2, -2, 3, 0x1234, 0x5678, -0x1234, -0x1234.0, 0x12345678.0,
    0x87654321.0, 0x33333333.0, 0x77777777.0, 0x55aa55aa.0, 0xaa55aa55.0,
    0x7fffffff.0, 0x80000000.0, 0xffffffff.0, int64 '0x100000000',
    int64 '-0x100000000', int64 '0x100000001', int64 '0x7fffffffffffffff',
    int64 '0x8000000000000000', int64 '0xffffffffffffffff',
}

local values_with_strings = {
    '0', '1', '-1', '2', '-2', '3', '1234', '5678', '-1234', '12345678',
    '87654321', '33333333', '77777777', '55aa55aa',  'aa55aa55', '7fffffff',
    '80000000', 'ffffffff', '100000000', '-100000000', '100000001',
    '7fffffffffffffff', '8000000000000000', 'ffffffffffffffff',
}

for _, v in ipairs(values_normal) do
    table.insert(values_with_strings, v)
end

local values = values_normal

local function test()
    -- sanity check first, because all other tests depend on it
    check_string_range('tobytes', 2292059, 0, 0)
    check_string_range('tohex', 624116436, -18, 18)

    values = values_with_strings
    check_unary('tointeger', 9941693)

    values = values_normal
    check_unary('bnot', 3817991)
    check_unary('bswap', 2306257)

    check_binary('band2', 589429069)
    check_ternary('band3', 1292109827)
    check_binary('band', 589429069)
    check_ternary('band', 1292109827)

    check_binary('bor2', 47855252)
    check_ternary('bor3', 287657535)
    check_binary('bor', 47855252)
    check_ternary('bor', 287657535)

    check_binary('bxor2', 1709491687)
    check_ternary('bxor3', 986854786)
    check_binary('bxor', 1709491687)
    check_ternary('bxor', 986854786)

    check_binary_range('lshift', 1482246274, -64, 64)
    check_binary_range('rshift', 760426021, -64, 64)
    check_binary_range('arshift', 885941498, -64, 64)
    check_binary_range('rol', 1019375721, -64, 64)
    check_binary_range('ror', 1019326473, -64, 64)

    check_unary_small('popcount', 116007)
    check_unary_small('clz', 121932)
    check_unary_small('ctz', 82610)
end

--- check functions

local function checksum(name, str, expected)
    local sum = int64 '0'
    for i = 1, #str do
        sum = (sum + string.byte(str, i) * i) % 2147483629
    end

    if sum ~= expected then
        print(name .. ' test failed (got ' .. tonumber(sum) .. ', expected ' .. expected .. ')')
        error('test failed')
    end
end

-- check unary functions
function check_unary(name, expected)
    local func = bit64[name]
    local result = ''
    if pcall(func) or pcall(func, 'z') or pcall(func, true) then
        error('bit64.' .. name .. ' fails to detect argument errors', 0)
    end
    for _, x in ipairs(values) do
        local value = func(x)
        result = result .. ';' .. bit64.tobytes(value)
    end
    checksum('unary ' .. name, result, expected)
end

-- check unary functions with small returns (popcnt, clz, ctz)
function check_unary_small(name, expected)
    local func = bit64[name]
    local result = ''
    if pcall(func) or pcall(func, 'z') or pcall(func, true) then
        error('bit64.' .. name .. ' fails to detect argument errors', 0)
    end
    for _, x in ipairs(values) do
        local value = func(x)
        result = result .. ';' .. value
    end
    checksum('unary ' .. name, result, expected)
end

-- check binary functions
function check_binary(name, expected)
    local func = bit64[name]
    local result = ''
    if pcall(func) or pcall(func, 'z') or pcall(func, true) then
        error('bit64.' .. name .. ' fails to detect argument errors', 0)
    end
    for _, x in ipairs(values) do
        for _, y in ipairs(values) do
            local value = func(x, y)
            result = result .. ';' .. bit64.tobytes(value)
        end
    end
    checksum('binary ' .. name, result, expected)
end

-- check ternary functions
function check_ternary(name, expected)
    local func = bit64[name]
    local result = ''
    if pcall(func) or pcall(func, 'z') or pcall(func, true) then
        error('bit64.' .. name .. ' fails to detect argument errors', 0)
    end
    for _, x in ipairs(values) do
        for _, y in ipairs(values) do
            for _, z in ipairs(values) do
                local value = func(x, y, z)
                result = result .. ';' .. bit64.tobytes(value)
            end
        end
    end
    checksum('ternary ' .. name, result, expected)
end

-- check ternary functions with a range of values
function check_binary_range(name, expected, start, stop)
    local func = bit64[name]
    local result = ''
    if pcall(func) or pcall(func, 'z') or pcall(func, true) then
        error('bit64.' .. name .. ' fails to detect argument errors', 0)
    end
    for _, x in ipairs(values) do
        for y = start, stop do
            local value = func(x, y)
            result = result .. ';' .. bit64.tobytes(value)
        end
    end
    checksum('binrange ' .. name, result, expected)
end

-- check string functions
function check_string_range(name, expected, start, stop)
    local func = bit64[name]
    local result = ''
    if pcall(func) or pcall(func, 'z') or pcall(func, true) then
        error('bit64.' .. name .. ' fails to detect argument errors', 0)
    end
    for _, x in ipairs(values) do
        for y = start, stop do
            local value = func(x, y)
            result = result .. ';' .. value
        end
    end
    checksum('strrange ' .. name, result, expected)
end

-- run tests
test()
