-- Los Scotia 902 Server Restart Script
-- Run this after setting up all resources to verify everything is working

print("^2[LOS SCOTIA]^7 Starting server verification...")
print("^2[LOS SCOTIA]^7 Checking all Los Scotia resources...")

-- List of all Los Scotia resources that should be loaded
local losScotiaResources = {
    'ls-scripts',
    'ls-verify', 
    'ls-heists',
    'ls-police',
    'ls-gym',
    'ls-gangs',
    'ls-racing',
    'ls-housing',
    'ls-business',
    'ls-police-enhanced',
    'ls-medical',
    'ls-fire',
    'ls-bank-advanced',
    'ls-economy',
    'ls-dealership',
    'ls-garage',
    'ls-insurance',
    'ls-realestate',
    'ls-rental',
    'ls-government',
    'ls-lawyers',
    'ls-taxi',
    'ls-towing',
    'ls-farming',
    'ls-nightlife',
    'ls-racing-advanced',
    'ls-social',
    'ls-phone-apps',
    'ls-radio',
    'ls-weather'
}

CreateThread(function()
    Wait(5000) -- Wait 5 seconds for resources to load
    
    local loadedCount = 0
    local totalCount = #losScotiaResources
    local failedResources = {}
    
    for _, resourceName in ipairs(losScotiaResources) do
        if GetResourceState(resourceName) == 'started' then
            loadedCount = loadedCount + 1
            print(string.format("^2✓^7 %s loaded successfully", resourceName))
        else
            table.insert(failedResources, resourceName)
            print(string.format("^1✗^7 %s failed to load", resourceName))
        end
    end
    
    print("^2[LOS SCOTIA]^7 ================================")
    print(string.format("^2[LOS SCOTIA]^7 Loaded %d/%d Los Scotia scripts", loadedCount, totalCount))
    
    if loadedCount == totalCount then
        print("^2[LOS SCOTIA]^7 🎉 100% SUCCESS! All Los Scotia resources loaded!")
        print("^2[LOS SCOTIA]^7 Your server is ready for players!")
    else
        print("^1[LOS SCOTIA]^7 ❌ Some resources failed to load:")
        for _, failed in ipairs(failedResources) do
            print(string.format("^1[LOS SCOTIA]^7   - %s", failed))
        end
        print("^3[LOS SCOTIA]^7 Check console for errors and ensure all files exist")
    end
    
    print("^2[LOS SCOTIA]^7 ================================")
end)