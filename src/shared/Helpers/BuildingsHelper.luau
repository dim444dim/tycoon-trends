local BuildingsHelper = {}

-- Parses a buildings string into a table of building counts
-- Input: "workshop:2,factory:1,megaplant:0" or nil/""
-- Output: {workshop=2, factory=1, megaplant=0} or {}
function BuildingsHelper.parseBuildings(buildingsString)
	if not buildingsString or buildingsString == "" then
		return {}
	end

	local result = {}
	for pair in string.gmatch(buildingsString, "[^,]+") do
		local building, count = string.match(pair, "([^:]+):(%d+)")
		if building and count then
			result[building] = tonumber(count)
		end
	end
	return result
end

-- Serializes a buildings table into a string with sorted keys
-- Input: {workshop=2, factory=1} or {} or nil
-- Output: "factory:1,workshop:2" (alphabetically sorted) or ""
function BuildingsHelper.serializeBuildings(buildingsTable)
	if not buildingsTable or next(buildingsTable) == nil then
		return ""
	end

	local parts = {}
	local sortedKeys = {}

	-- Collect and sort keys for consistent ordering
	for key in pairs(buildingsTable) do
		table.insert(sortedKeys, key)
	end
	table.sort(sortedKeys)

	-- Build key:value pairs
	for _, key in ipairs(sortedKeys) do
		table.insert(parts, key .. ":" .. tostring(buildingsTable[key]))
	end

	return table.concat(parts, ",")
end

return BuildingsHelper
