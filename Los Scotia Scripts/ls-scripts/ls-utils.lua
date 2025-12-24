-- ls-utils.lua
-- Central aggregation & helper utilities for Los Scotia modules.

LS = LS or {}

local function attach(name, value)
    if value and type(value) == 'table' then
        LS[name] = value
    end
end

-- Attach known module globals if present
attach('Heists', LS_HEISTS)
attach('Police', LS_POLICE)
attach('Medical', LS_MEDICAL)
attach('Gym', LS_GYM)
attach('Business', LS_BUSINESS)
attach('Gangs', LS_GANGS)
attach('Racing', LS_RACING)
attach('Housing', LS_HOUSING)
attach('Government', LS_GOVERNMENT)
attach('BankAdvanced', LS_BANK_ADVANCED)
attach('Dealership', LS_DEALERSHIP)
attach('Economy', LS_ECONOMY)
attach('Farming', LS_FARMING)
attach('Fire', LS_FIRE)
attach('Insurance', LS_INSURANCE)
attach('Lawyers', LS_LAWYERS)
attach('Nightlife', LS_NIGHTLIFE)
attach('PhoneApps', LS_PHONE_APPS)
attach('RacingAdvanced', LS_RACING_ADVANCED)
attach('Radio', LS_RADIO)
attach('RealEstate', LS_REALESTATE)
attach('Rental', LS_RENTAL)
attach('Social', LS_SOCIAL)
attach('Taxi', LS_TAXI)
attach('Towing', LS_TOWING)
attach('Verify', LS_VERIFY)
attach('Weather', LS_WEATHER)

-- Time window helper (supports overnight wrap)
function LS.WithinWindow(currentHour, window)
    if not window then return false end
    local s = window.start_hour or window.start or window.startHour
    local e = window.end_hour or window['end'] or window.endHour
    if not s or not e then return false end
    if s == e then return true end
    if s < e then
        return currentHour >= s and currentHour < e
    else
        -- overnight (e.g., 18 -> 6)
        return currentHour >= s or currentHour < e
    end
end

-- Basic module/table validation
LS.Validation = LS.Validation or {}

function LS.Validation.CheckNonEmpty()
    local warnings = {}
    for k,v in pairs(LS) do
        if type(v) == 'table' then
            local isEmpty = true
            for _ in pairs(v) do isEmpty = false break end
            if isEmpty then
                warnings[#warnings+1] = ('LS.%s is an empty table'):format(k)
            end
        end
    end
    if #warnings > 0 then
        print('[LS-UTILS] Validation warnings:')
        for _,w in ipairs(warnings) do print('  - '..w) end
    else
        print('[LS-UTILS] All LS module tables contain data (or were not defined).')
    end
end

-- Optionally run validation automatically (toggle here)
local AUTO_VALIDATE = true
if AUTO_VALIDATE then
    LS.Validation.CheckNonEmpty()
end

return LS