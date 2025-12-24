-- namespace.lua: export LS aggregated namespace
if not LS then
    -- ls-utils.lua should define LS; this is a safeguard
    LS = {}
end

exports('GetLSNamespace', function()
    return LS
end)
