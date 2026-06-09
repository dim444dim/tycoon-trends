-- ZZZ_TestRunner.server.luau (TEMP — supprimer après tests)
local HttpService        = game:GetService("HttpService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local results = {}

local function test(name, fn)
	local ok, err = pcall(fn)
	local entry = { name = name, ok = ok, err = ok and "" or tostring(err) }
	table.insert(results, entry)
	if ok then
		print("✅ " .. name)
	else
		warn("❌ " .. name .. " — " .. tostring(err))
	end
end

-- TEST 1: GameConfig loads
test("GameConfig.NomDuJeu", function()
	local GC = require(ReplicatedStorage.Shared.GameConfig)
	assert(GC ~= nil, "module nil")
	assert(GC.NomDuJeu ~= nil, "NomDuJeu manquant")
	results[#results].value = GC.NomDuJeu
	print("   →", GC.NomDuJeu)
end)

-- TEST 2: MapConfig.Colors.CouleurMachines
test("MapConfig.Colors.CouleurMachines", function()
	local ok2, MC = pcall(require, ReplicatedStorage.Shared.MapConfig)
	if not ok2 then error("require échoué: " .. tostring(MC)) end
	assert(MC.Colors ~= nil, "Colors nil")
	assert(MC.Colors.CouleurMachines ~= nil, "CouleurMachines nil")
	print("   → CouleurMachines:", tostring(MC.Colors.CouleurMachines))
end)

-- TEST 3: Remotes.BuyBuilding
test("Remotes.BuyBuilding", function()
	local R = require(ReplicatedStorage.Shared.Remotes)
	assert(R ~= nil, "module nil")
	assert(R.BuyBuilding ~= nil, "BuyBuilding manquant")
	results[#results].value = tostring(R.BuyBuilding)
	print("   →", tostring(R.BuyBuilding))
end)

-- TEST 4: GameState créé par SessionManager
test("GameState.State", function()
	local state = ReplicatedStorage:WaitForChild("GameState", 5)
	assert(state ~= nil, "GameState non trouvé (timeout 5s)")
	local val = state:GetAttribute("State")
	assert(val ~= nil, "Attribute State manquant")
	results[#results].value = tostring(val)
	print("   → State =", tostring(val))
end)

-- POST résultats vers le serveur HTTP local
local ok, err = pcall(function()
	local json = HttpService:JSONEncode({ results = results, allOk = #results == 4 })
	HttpService:PostAsync("http://localhost:9877/results", json, Enum.HttpContentType.ApplicationJson)
end)

if ok then
	print("📡 Résultats envoyés au serveur local")
else
	warn("📡 PostAsync échoué (HttpEnabled = true ?):", err)
	-- Affiche quand même dans Output
	for _, r in ipairs(results) do
		if r.ok then print("✅ " .. r.name .. " = " .. (r.value or "ok"))
		else warn("❌ " .. r.name .. " — " .. r.err) end
	end
end

print("🏁 Tests terminés (" .. #results .. "/4)")
