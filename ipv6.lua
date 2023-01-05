local bit = require('bit')

local MAX_U64 = 0xFFFFFFFFFFFFFFFFULL

local function ip_to_u64_pair(ip)
    local parts = string.split(ip, ':')

    if #parts ~= 8 then
        return nil
    end

    local u64_1 = 0ULL
    local u64_2 = 0ULL
    for i = 1, 4 do
        local p1 = tonumber(parts[i], 16)
        if p1 == nil or p1 < 0 or p1 > 0xFFFF then
            return nil
        end

        local p2 = tonumber(parts[i + 4], 16)
        if p2 == nil or p2 < 0 or p2 > 0xFFFF then
            return nil
        end

        u64_1 = bit.lshift(u64_1, 16) + p1
        u64_2 = bit.lshift(u64_2, 16) + p2
    end
    return u64_1, u64_2
end

local function u64_pair_to_ip(u64_1, u64_2)
    local parts = {}
    for i = 1, 4 do
        parts[i] = string.format('%04x', tonumber(bit.band(bit.rshift(u64_1, 16 * (4 - i)), 0xFFFF)))
        parts[i + 4] = string.format('%04x', tonumber(bit.band(bit.rshift(u64_2, 16 * (4 - i)), 0xFFFF)))
    end
    return table.concat(parts, ':')
end

local function cidr_network_to_u64_pairs(network)
    local parts = string.split(network, '/')
    if #parts ~= 2 then
        return nil
    end

    local u64_1, u64_2 = ip_to_u64_pair(parts[1])
    if u64_1 == nil or u64_2 == nil then
        return nil
    end

    local mask = tonumber(parts[2])
    if mask == nil or mask < 0 or mask > 128 then
        return nil
    end

    local ip, mask = unpack(string.split(network, '/'))
    mask = tonumber(mask)
    local u64_1, u64_2 = ip_to_u64_pair(ip)
    local mask_1 = 0ULL
    local mask_2 = 0ULL
    for i = 1, mask do
        if i <= 64 then
            mask_1 = bit.bor(mask_1, bit.lshift(1ULL, 64 - i))
        else
            mask_2 = bit.bor(mask_2, bit.lshift(1ULL, 128 - i))
        end
    end

    local rev_mask_1 = bit.band(bit.bnot(mask_1), MAX_U64)
    local rev_mask_2 = bit.band(bit.bnot(mask_2), MAX_U64)

    return bit.band(u64_1, mask_1), bit.band(u64_2, mask_2), bit.bor(u64_1, rev_mask_1), bit.bor(u64_2, rev_mask_2)
end

return {
    ip_to_u64_pair            = ip_to_u64_pair,
    u64_pair_to_ip            = u64_pair_to_ip,
    cidr_network_to_u64_pairs = cidr_network_to_u64_pairs,
}