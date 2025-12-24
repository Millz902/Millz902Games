-- EF-Blips MLO Integration Instructions
-- How to add the MLO blips to your ef-blips system

--[[
INTEGRATION STEPS:

1. COPY MLO BLIPS CONFIG:
   - Copy the content from ef-blips-mlo-config.lua 
   - Add it to your ef-blips/config.lua file

2. MODIFY EF-BLIPS CONFIG.LUA:
   - Open: resources/[maps]/ef-blips/config.lua
   - Add the MLO blips to your existing blips table
   
3. EXAMPLE INTEGRATION:
   In your ef-blips config.lua, add this section:

   -- MLO Blips Section
   Config.Blips = Config.Blips or {}
   
   -- Add MLO Blips
   for key, blip in pairs(Config.MLOBlips) do
       Config.Blips[key] = blip
   end

4. ALTERNATIVE METHOD:
   If ef-blips uses a different structure, you can modify the format:

   -- Convert to ef-blips format
   for key, blip in pairs(Config.MLOBlips) do
       table.insert(Config.Blips, {
           name = blip.name,
           coords = vector3(blip.x, blip.y, blip.z),
           sprite = blip.sprite,
           color = blip.color,
           scale = blip.scale,
           shortRange = blip.shortRange,
           category = blip.category
       })
   end

5. RESTART RESOURCE:
   - Restart ef-blips resource: restart ef-blips
   - Or restart server to apply all changes

BLIP CATEGORIES INCLUDED:
- Gang Territories (6 blips)
- Police Stations (6 blips)
- Restaurants & Food (11 blips)
- Automotive (5 blips)
- Entertainment (10 blips)
- Shopping & Retail (7 blips)
- Housing & Residential (8 blips)
- Special Locations (6 blips)
- Crime & Underground (5 blips)
- Hoods & Projects (6 blips)

TOTAL: 70+ MLO blips added to your server!

CUSTOMIZATION:
- Adjust coordinates in the config file to match your MLO positions
- Change colors and sprites as needed
- Add/remove blips based on your server's MLOs
- Modify shortRange settings for different visibility preferences

BLIP SPRITE REFERENCE:
- 60: Police Station
- 106: Restaurant/Food
- 93: Bar/Club
- 446: Mechanic
- 523: Car Dealer
- 40: House/Residential
- 475: Building/Hotel
- 378: Gang
- 90: Airport
- 679: Casino
- And many more...

COLOR REFERENCE:
- 0: White
- 1: Red
- 2: Green
- 3: Blue
- 5: Yellow
- 25: Dark Green
- 27: Purple
- 38: Dark Blue
- 46: Orange
--]]