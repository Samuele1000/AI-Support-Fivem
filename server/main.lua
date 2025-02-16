local function BuildFAQPrompt()
    if not Config.FAQ or #Config.FAQ == 0 then return "Geen FAQ items beschikbaar" end
    
    local faqText = "Veelgestelde vragen en antwoorden:\n\n"
    for _, faq in ipairs(Config.FAQ) do
        faqText = faqText .. "Q: " .. faq.question .. "\nA: " .. faq.answer .. "\n\n"
    end
    
    return faqText .. [[
Wanneer gebruikers vragen stellen die lijken op deze FAQ-items:
1. Gebruik de FAQ-kennis als basis, maar personaliseer het antwoord
2. Voeg relevante aanvullende informatie toe uit andere serverkennis
3. Houd de behulpzame en vriendelijke toon aan
4. Als de vraag erg lijkt op een FAQ, begin dan met "Dit moet je weten:"
]]
end

local function BuildRulesPrompt()
    if not Config.Rules then return "Regelsysteem niet geconfigureerd" end
    
    local rulesText = "Serverregels:\n\n"
    
    
    for catId, category in pairs(Config.Rules.Categories) do
        rulesText = rulesText .. category.title .. ":\n"
        for _, rule in ipairs(category.rules) do
            rulesText = rulesText .. "- " .. rule .. "\n"
        end
        rulesText = rulesText .. "\n"
    end
    
    
    if Config.AIMemory.RulesDetail.ShowPunishments then
        rulesText = rulesText .. "Overtredingen en Gevolgen:\n"
        for _, violation in pairs(Config.Rules.Punishments.violations) do
            rulesText = rulesText .. "- " .. violation.name .. ":\n"
            if violation.first then rulesText = rulesText .. "  Eerste: " .. Config.Rules.Punishments.levels[violation.first] .. "\n" end
            if violation.second then rulesText = rulesText .. "  Tweede: " .. Config.Rules.Punishments.levels[violation.second] .. "\n" end
            if violation.third then rulesText = rulesText .. "  Derde: " .. Config.Rules.Punishments.levels[violation.third] .. "\n" end
        end
    end
    
    
    if Config.AIMemory.RulesDetail.ShowAppeals then
        rulesText = rulesText .. "\nBeroepsproces:\n"
        for _, step in ipairs(Config.Rules.Appeals.process) do
            rulesText = rulesText .. "- " .. step .. "\n"
        end
    end
    
    return rulesText
end

local activeReports = {}
local geminiHistory = {}
local serverBlips = {}
local serverMemory = {}
local pendingWaypoints = {}


local function HandleLocationRequest(src, location)
    if not src or not location then 
        print('[AI-Support] Ongeldige bron of locatie')
        return false 
    end
    
    
    local cleanLocation = location:gsub("^%s*(.-)%s*$", "%1")
    
    
    print('[AI-Support] Proberen locatie te markeren:', cleanLocation)
    print('[AI-Support] Beschikbare locaties:')
    for name, data in pairs(Config.ServerInfo.Locations) do
        print('  -', name, '(coördinaten:', json.encode(data.coords), ')')
    end
    
    
    local locationData = Config.ServerInfo.Locations[cleanLocation]
    local foundName = cleanLocation
    
    
    if not locationData then
        print('[AI-Support] Geen exacte overeenkomst, proberen met hoofdletterongevoelige overeenkomst')
        for name, data in pairs(Config.ServerInfo.Locations) do
            local cleanName = name:gsub("%s+", ""):lower()
            local cleanSearch = cleanLocation:gsub("%s+", ""):lower()
            
            print('[AI-Support] Vergelijken:', cleanSearch, 'met:', cleanName)
            
            if cleanName == cleanSearch or 
               cleanName:find(cleanSearch, 1, true) or 
               cleanSearch:find(cleanName, 1, true) then
                locationData = data
                foundName = name
                print('[AI-Support] Overeenkomst gevonden:', name)
                break
            end
        end
    end
    
    
    if not locationData then
        print('[AI-Support] Locatie niet gevonden in config:', cleanLocation)
        return false
    end
    
    print('[AI-Support] Locatiegegevens gevonden voor:', foundName)
    print('[AI-Support] Locatiegegevens:', json.encode(locationData))
    
    
    pendingWaypoints[src] = {
        location = foundName,
        success = false,
        processed = false
    }
    
    
    TriggerClientEvent('ai-support:setWaypoint', src, foundName)
    
    
    local timeoutAt = GetGameTimer() + 1000
    while GetGameTimer() < timeoutAt do
        if pendingWaypoints[src] and pendingWaypoints[src].processed then
            local success = pendingWaypoints[src].success
            pendingWaypoints[src] = nil
            print('[AI-Support] Resultaat waypoint instellen:', success)
            return success
        end
        Wait(0)
    end
    
    print('[AI-Support] Waypoint verzoek verlopen')
    pendingWaypoints[src] = nil
    return false
end


RegisterNetEvent('ai-support:waypointResult')
AddEventHandler('ai-support:waypointResult', function(location, success)
    local src = source
    if pendingWaypoints[src] and pendingWaypoints[src].location == location then
        pendingWaypoints[src].success = success
        pendingWaypoints[src].processed = true
    end
end)


local function InitializeServerMemory()
    if Config.AIMemory.EnableServerInfo then
        serverMemory.serverInfo = {
            name = Config.ServerInfo.Name,
            description = Config.ServerInfo.Description,
            maxSlots = Config.ServerInfo.MaxSlots,
            gameMode = Config.ServerInfo.GameMode,
            language = Config.ServerInfo.Language,
            features = Config.AIMemory.EnableFeatures and Config.ServerInfo.Features or nil,
            rules = Config.AIMemory.EnableRules and Config.ServerInfo.Rules or nil,
            locations = Config.AIMemory.EnableLocations and Config.ServerInfo.Locations or nil
        }
    end
end


CreateThread(function()

    print('^2[AI-Support]^7 - ^5Gemaakt door MT-Scripts^7')
    print('^2[AI-Support]^7 - ^5Word lid van Discord voor ondersteuning:^7 ^3https://discord.gg/r9SmWAJccD^7')
    print('^2[AI-Support]^7 - ^5Starten...^7')
    
    InitializeServerMemory()
    
    
    if Config.DiscordWebhook and Config.DiscordWebhook ~= '' then
        PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers)
            if err == 200 or err == 204 then
                print('[AI-Support] Discord webhook succesvol geverifieerd')
            else
                print('[AI-Support] Mislukt om Discord webhook te verifiëren. Fout:', err)
                print('[AI-Support] Zorg ervoor dat uw webhook-URL correct is')
            end
        end, 'GET', '', { ['Content-Type'] = 'application/json' })
    else
        print('[AI-Support] Discord webhook niet geconfigureerd')
    end
end)


RegisterNetEvent('ai-support:startBugReport')
AddEventHandler('ai-support:startBugReport', function()
    local src = source
    activeReports[src] = {
        stage = 'category',
        data = {}
    }
    geminiHistory[src] = {}
    
    
    TriggerClientEvent('ai-support:receiveResponse', src, "Selecteer alstublieft: Gameplay, Voertuig, Map, UI/HUD, Prestatie, Overig")
end)


RegisterNetEvent('ai-support:handleMessage')
AddEventHandler('ai-support:handleMessage', function(message, stage, bugReport)
    local src = source
    
    
    if not geminiHistory[src] then
        geminiHistory[src] = {}
    end
    
    
    if stage and stage ~= 'complete' then
        if not activeReports[src] then
            activeReports[src] = { stage = stage, data = {} }
        end
        
        
        activeReports[src].data = bugReport 
        
        
        local stages = {
            category = function(msg)
                local validCategory = false
                for _, cat in ipairs(Config.BugCategories) do
                    if string.lower(msg) == string.lower(cat) then
                        validCategory = true
                        break
                    end
                end
                if validCategory then
                    TriggerClientEvent('ai-support:receiveResponse', src, "Beschrijf alstublieft de bug die u bent tegengekomen. Zorg ervoor dat u minimaal 10 tekens invoert.")
                    return 'description'
                end
                TriggerClientEvent('ai-support:receiveResponse', src, "Selecteer alstublieft: Gameplay, Voertuig, Map, UI/HUD, Prestatie, Overig")
                return 'category'
            end,
            description = function(msg)
                if string.len(msg) >= 5 then
                    TriggerClientEvent('ai-support:receiveResponse', src, "Welke stappen kan iemand nemen om deze bug te reproduceren?")
                    return 'steps'
                end
                TriggerClientEvent('ai-support:receiveResponse', src, "Beschrijf alstublieft de bug die u bent tegengekomen. Zorg ervoor dat u minimaal 10 tekens invoert.")
                return stage 
            end,
            steps = function(msg)
                if string.len(msg) >= 5 then
                    TriggerClientEvent('ai-support:receiveResponse', src, "Is er nog aanvullende informatie die u wilt toevoegen?")
                    return 'additionalInfo'
                end
                TriggerClientEvent('ai-support:receiveResponse', src, "Welke stappen kan iemand nemen om deze bug te reproduceren?")
                return stage 
            end,
            additionalInfo = function(msg)
                TriggerClientEvent('ai-support:receiveResponse', src, "Wilt u dit bugrapport indienen? Type 'ja' om in te dienen of 'annuleren' om te stoppen.")
                return 'confirm'
            end,
            confirm = function(msg)
                local lowerMsg = string.lower(msg)
                if lowerMsg == 'ja' then
                    CreateBugReport(src, activeReports[src].data)
                    
                    activeReports[src] = nil
                    
                    TriggerClientEvent('ai-support:receiveResponse', src, "Bugrapport succesvol ingediend! Waarmee kan ik u nog meer helpen?")
                    TriggerClientEvent('ai-support:updateStage', src, 'complete')
                    
                    table.insert(geminiHistory[src], {
                        role = "assistant",
                        parts = {{ text = "Waarmee kan ik u nog meer helpen?" }}
                    })
                    return 'complete'
                elseif lowerMsg == 'annuleren' then
                    
                    activeReports[src] = nil
                    
                    TriggerClientEvent('ai-support:receiveResponse', src, "Bugrapport geannuleerd. Kan ik u nog ergens anders mee helpen?")
                    TriggerClientEvent('ai-support:updateStage', src, 'complete')
                    
                    table.insert(geminiHistory[src], {
                        role = "assistant",
                        parts = {{ text = "Waarmee kan ik u nog meer helpen?" }}
                    })
                    return 'complete'
                else
                    
                    TriggerClientEvent('ai-support:receiveResponse', src, "Wilt u dit bugrapport indienen? Type 'ja' om in te dienen of 'annuleren' om te stoppen.")
                    return 'confirm'
                end
            end
        }
        
        
        if stages[stage] then
            local nextStage = stages[stage](message)
            if nextStage and nextStage ~= stage then
                activeReports[src].stage = nextStage
                TriggerClientEvent('ai-support:updateStage', src, nextStage)
            end
            return 
        end
    else
        
        table.insert(geminiHistory[src], {
            role = "user",
            parts = {{ text = message }}
        })
        
        
        local context = {
            rules = Config.Rules,
            locations = Config.ServerInfo.Locations,
            bugCategories = Config.BugCategories,
            currentStage = nil,
            bugReport = nil,
            serverInfo = serverMemory.serverInfo,
            AIMemory = Config.AIMemory
        }
        
        GetGeminiResponse(src, message, context, geminiHistory[src])
    end
end)


function GetGeminiResponse(src, message, context, history)
    
    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
    local headers = {
        ['Content-Type'] = 'application/json',
        ['x-goog-api-key'] = Config.GeminiApiKey
    }

    
    local systemPrompt = [[
You are an AI support assistant for a FiveM roleplay server.

Server Information:
Server Name: ]] .. (context.serverInfo and context.serverInfo.name or "Unknown") .. [[
Server Description: ]] .. (context.serverInfo and context.serverInfo.description or "Not provided") .. [[
Max Players: ]] .. (context.serverInfo and context.serverInfo.maxSlots or "Unknown") .. [[

FAQ Knowledge Base:
]] .. (Config.AIMemory.EnableFAQ and BuildFAQPrompt() or "FAQ system disabled") .. [[

Server Rules and Guidelines:
]] .. (Config.AIMemory.EnableRules and BuildRulesPrompt() or "Rules system disabled") .. [[

For bug reports:
- Detect ANY mention of bugs, issues, or problems that need reporting
- Common patterns include but are not limited to:
  - Reporting bugs/issues
  - Finding bugs/issues
  - Having problems
  - Something not working
  - Need to report something
- When detected, ALWAYS respond with the category selection prompt
- DO NOT require exact phrases

EXACT responses for bug reports:
IF user mentions ANY bug/issue/problem they want to report:
  "Selecteer alstublieft: Gameplay, Voertuig, Map, UI/HUD, Prestatie, Overig"

IF stage is 'category' AND message is NOT "report bug" AND message is NOT one of [Gameplay, Voertuig, Map, UI/HUD, Prestatie, Overig]:
  "Selecteer alstublieft: Gameplay, Voertuig, Map, UI/HUD, Prestatie, Overig"

IF stage is 'category' AND message IS one of [Gameplay, Voertuig, Map, UI/HUD, Prestatie, Overig]:
  "Beschrijf alstublieft de bug die u bent tegengekomen. Zorg ervoor dat u minimaal 10 tekens invoert."

IF stage is 'description' AND message length >= 5:
  "Welke stappen kan iemand nemen om deze bug te reproduceren?"

IF stage is 'steps' AND message length >= 5:
  "Is er nog aanvullende informatie die u wilt toevoegen?"

IF stage is 'additionalInfo':
  "Wilt u dit bugrapport indienen? Type 'ja' om in te dienen of 'annuleren' om te stoppen."

IF stage is 'confirm' AND message is NOT 'ja' AND message is NOT 'annuleren':
  "Wilt u dit bugrapport indienen? Type 'ja' om in te dienen of 'annuleren' om te stoppen."

Critical rules:
1. Use EXACTLY the response text shown above - no modifications
2. NEVER show more than one prompt
3. NEVER add extra text or explanations
4. NEVER acknowledge previous inputs
5. NEVER preview next steps
6. For non-bug report questions, provide helpful responses

Remember:
- Never share restricted information: ]] .. table.concat(Config.RestrictedInfo, ", ") .. [[
- Be helpful but maintain server security
- During bug reports, use ONLY the exact responses shown above

Important location instructions:
- Available locations (use EXACT names, case-sensitive):
]] .. (function()
    local locationList = ""
    for name, _ in pairs(Config.ServerInfo.Locations) do
        locationList = locationList .. "  - " .. name .. "\n"
    end
    return locationList
end)() .. [[
- When marking a location, use EXACTLY: !SETMARK{Location Name}!
- ONLY mark the specific location the user asks about
- ALWAYS preserve spaces and exact capitalization
- Example responses:
  User: "Where is the Airport?"
  Response: "The Airport is in the south. Let me mark it: !SETMARK{Airport}!"
  
  User: "How do I get to the Police Station?"
  Response: "The Police Station is downtown. I'll mark it for you: !SETMARK{Police Station}!"

- DO NOT mark multiple locations unless specifically asked
- DO NOT mark related nearby locations unless asked
- ONLY mark what the user explicitly asks about

Response Guidelines:
1. Keep responses clear and concise
2. Use markdown formatting for better readability
3. When answering rule-related questions, cite specific rules
4. For FAQ questions, provide comprehensive answers
5. Always maintain a helpful and friendly tone
]]

    
    local conversationHistory = ""
    for _, msg in ipairs(history) do
        conversationHistory = conversationHistory .. "\n" .. msg.role .. ": " .. msg.parts[1].text
    end
    
    
    local body = {
        contents = {
            {
                role = "user",
                parts = {{ text = systemPrompt .. "\n\nConversation history:" .. conversationHistory .. "\n\nUser message: " .. message }}
            }
        },
        generationConfig = {
            temperature = 0.7,
            topP = 0.8,
            topK = 40,
            maxOutputTokens = 1024,
        }
    }

    print('[AI-Support] Verzoek indienen bij Gemini API') 
    
    
    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        print('[AI-Support] Ontvangen reactie van Gemini API:', errorCode) 
        
        if errorCode == 200 then
            local result = json.decode(resultData)
            if result and result.candidates and result.candidates[1] and result.candidates[1].content then
                local response = result.candidates[1].content.parts[1].text
                
                
                local locationMarked = false
                
                
                local location = response:match("!SETMARK{(.-)}!")
                if location then
                    local success = HandleLocationRequest(src, location)
                    locationMarked = success
                    
                    print('[AI-Support] Poging locatie te markeren:', location, success)
                end
                
                
                response = response:gsub("!SETMARK{.-}!", "")
                
                
                if locationMarked then
                    response = response .. "\n\nIk heb de locatie op uw kaart gemarkeerd."
                end
                
                
                response = FormatResponse(response)
                TriggerClientEvent('ai-support:receiveResponse', src, response)
                
                
                table.insert(geminiHistory[src], {
                    role = "assistant",
                    parts = {{ text = response }}
                })
            else
                print('[AI-Support] Ongeldig reactieformaat')
                TriggerClientEvent('ai-support:receiveResponse', src, "Het spijt me, maar ik heb moeite om uw verzoek te verwerken.\n\nKunt u het alstublieft opnieuw formuleren of meer details geven?")
            end
        else
            print('[AI-Support] API-fout:', errorCode, resultData)
            TriggerClientEvent('ai-support:receiveResponse', src, "Er is een fout opgetreden bij het verwerken van uw verzoek.\n\nKunt u uw vraag opnieuw stellen?")
        end
    end, 'POST', json.encode(body), headers)
end


function FormatResponse(text)
    if not text then return "" end
    
    
    text = text:gsub("%*%*(.-)%*%*", "%1") 
    text = text:gsub("%*(.-)%*", "%1")     
    text = text:gsub("_(.-)_", "%1")       
    text = text:gsub("<li>", "-")           
    text = text:gsub("</li>", "")          
    text = text:gsub("•%s+", "")           
    text = text:gsub("%-%s+", "")          
    text = text:gsub("%*%s+", "")          
    text = text:gsub("Stage:%s+", "")      
    text = text:gsub("Current stage:%s+", "") 
    
    
    text = text:gsub('%. ', '.\n\n')
    text = text:gsub('%! ', '!\n\n')
    text = text:gsub('%? ', '?\n\n')
    
    
    text = text:gsub('(Current)', '\n%1')
    text = text:gsub('(Summary)', '\n%1')
    
    
    text = text:gsub('\n\n\n+', '\n\n')
    
    
    text = text:gsub('^%s+', ''):gsub('%s+$', '')
    
    return text
end


RegisterNetEvent('ai-support:submitBugReport')
AddEventHandler('ai-support:submitBugReport', function(reportData)
    local src = source
    
    
    if Config.DiscordWebhook ~= '' then
        local embed = {
            title = "Nieuw Bugrapport",
            color = 15158332,
            fields = {
                {
                    name = "Categorie",
                    value = reportData.category,
                    inline = true
                },
                {
                    name = "Beschrijving",
                    value = reportData.description
                },
                {
                    name = "Stappen om te Reproduceren",
                    value = reportData.steps
                },
                {
                    name = "Gerapporteerd door",
                    value = GetPlayerName(src),
                    inline = true
                },
                {
                    name = "Tijd",
                    value = os.date("%Y-%m-%d %H:%M:%S"),
                    inline = true
                }
            }
        }
        
        
        PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
            username = "Bug Report Bot",
            embeds = { embed }
        }), { ['Content-Type'] = 'application/json' })
    end
    
    
    activeReports[src] = nil
    geminiHistory[src] = nil
end)


AddEventHandler('playerDropped', function()
    local src = source
    activeReports[src] = nil
    geminiHistory[src] = nil
end)


function CreateBugReport(src, reportData, callback)
    if not Config.DiscordWebhook or Config.DiscordWebhook == '' then
        print('[AI-Support] Discord webhook niet geconfigureerd')
        if callback then callback(false) end
        return
    end

    local player = GetPlayerName(src) or "Onbekend"
    local identifier = GetPlayerIdentifier(src, 0) or "Onbekend"
    
    
    print('[AI-Support] Bugrapport maken met gegevens:', json.encode(reportData))
    print('[AI-Support] Melder:', player, identifier)
    
    local embed = {
        {
            ["title"] = "🐛 Nieuw Bugrapport",
            ["color"] = 16711680,
            ["description"] = "Er is een nieuwe bug gerapporteerd",
            ["fields"] = {
                {
                    ["name"] = "Categorie",
                    ["value"] = reportData.category or "Niet gespecificeerd",
                    ["inline"] = true
                },
                {
                    ["name"] = "Melder",
                    ["value"] = string.format("%s (`%s`)", player, identifier),
                    ["inline"] = true
                },
                {
                    ["name"] = "Beschrijving",
                    ["value"] = reportData.description or "Geen beschrijving gegeven",
                    ["inline"] = false
                },
                {
                    ["name"] = "Stappen om te Reproduceren",
                    ["value"] = reportData.steps or "Geen stappen gegeven",
                    ["inline"] = false
                },
                {
                    ["name"] = "Aanvullende Informatie",
                    ["value"] = reportData.additionalInfo or "Geen aanvullende informatie",
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "Bugrapport Systeem"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    local payload = {
        username = "Bug Report Bot",
        embeds = embed
    }

    
    print('[AI-Support] Verzenden van Discord payload:', json.encode(payload))

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers)
        
        print('[AI-Support] Discord reactie:', err, text)
        if headers then
            print('[AI-Support] Discord headers:', json.encode(headers))
        end

        if err == 204 or err == 200 then  
            print('[AI-Support] Bugrapport succesvol naar Discord verzonden')
            TriggerClientEvent('ai-support:notify', src, 'Bugrapport succesvol ingediend!')
            if callback then callback(true) end
        else
            print('[AI-Support] Mislukt om bugrapport naar Discord te verzenden. Fout:', err)
            print('[AI-Support] Reactie:', text)
            TriggerClientEvent('ai-support:notify', src, 'Kon het bugrapport niet indienen bij Discord')
            if callback then callback(false) end
        end
    end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end


RegisterNetEvent('ai-support:updateBlips')
AddEventHandler('ai-support:updateBlips', function(blips)
    if Config.AIMemory.EnableBlipTracking then
        serverBlips = blips
    end
end)



RegisterNetEvent('ai-support:clearChat')
AddEventHandler('ai-support:clearChat', function()
    local src = source
    geminiHistory[src] = {}
    activeReports[src] = nil
end)

RegisterNetEvent('ai-support:clearContext')
AddEventHandler('ai-support:clearContext', function()
    local src = source
    
    geminiHistory[src] = {
        {
            role = "assistant",
            parts = {{ text = "Context is gewist. Hoe kan ik u helpen?" }}
        }
    }
    
    activeReports[src] = nil
end)


RegisterNetEvent('ai-support:getConfig')
AddEventHandler('ai-support:getConfig', function()
    local src = source
    TriggerClientEvent('ai-support:sendConfig', src, {
        title = Config.Title
    })
end)