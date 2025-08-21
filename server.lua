-- Replace this with your ONE photographer’s identifier
local photographerIdentifier = "license:3832beeb79f980409695b1b936b44a7687a4c1b0"

-- Store the last requester
local lastRequester = nil

-- Cooldown settings
local cooldownTime = 60 -- seconds
local cooldowns = {} -- [playerId] = os.time()

RegisterNetEvent("photo:sendRequest", function(subject, location)
    local src = source
    local name = GetPlayerName(src)

    -- Cooldown check
    if cooldowns[src] and (os.time() - cooldowns[src]) < cooldownTime then
        local remaining = cooldownTime - (os.time() - cooldowns[src])
        TriggerClientEvent("chat:addMessage", src, {
            color = { 255, 0, 0 },
            args = { "Photo Request", ("❌ You must wait %d seconds before sending another request."):format(remaining) }
        })
        return
    end

    local photographerId = nil

    -- Check all players for matching identifier
    for _, playerId in pairs(GetPlayers()) do
        for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
            if id == photographerIdentifier then
                photographerId = playerId
                break
            end
        end
        if photographerId then break end
    end

    if photographerId then
        -- Store requester so photographer can respond later
        lastRequester = src
        cooldowns[src] = os.time()

        -- Send request to photographer (with sender's ID)
        TriggerClientEvent("chat:addMessage", photographerId, {
            color = { 255, 200, 0 },
            multiline = true,
            args = { "📸 Photo Request", 
                ("From: %s [ID: %d]\nSubject: %s\nLocation: %s\n\nUse /acceptphoto to confirm!"):format(name, src, subject, location) }
        })

        -- Confirmation back to sender
        TriggerClientEvent("chat:addMessage", src, {
            color = { 0, 200, 0 },
            args = { "Photo Request", "✅ Your request has been sent to the photographer!" }
        })
    else
        -- Photographer not online
        TriggerClientEvent("chat:addMessage", src, {
            color = { 255, 0, 0 },
            args = { "Photo Request", "❌ The photographer is not currently online." }
        })
    end
end)

RegisterNetEvent("photo:acceptRequest", function()
    local src = source
    local isPhotographer = false

    -- Verify this player is the photographer
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id == photographerIdentifier then
            isPhotographer = true
            break
        end
    end

    if not isPhotographer then
        return -- ignore if not the photographer
    end

    if lastRequester and GetPlayerPing(lastRequester) > 0 then
        local requesterName = GetPlayerName(lastRequester) or "Unknown"
        -- Notify requester
        TriggerClientEvent("chat:addMessage", lastRequester, {
            color = { 0, 200, 255 },
            args = { "Photographer", "📸 The photographer has accepted your request and will meet you soon!" }
        })

        -- Notify photographer they accepted (with requester info)
        TriggerClientEvent("chat:addMessage", src, {
            color = { 0, 200, 0 },
            args = { "Photographer", ("✅ You accepted the request from %s [ID: %d]."):format(requesterName, lastRequester) }
        })

        -- Clear stored requester
        lastRequester = nil
    else
        TriggerClientEvent("chat:addMessage", src, {
            color = { 255, 0, 0 },
            args = { "Photographer", "❌ No active request to accept." }
        })
    end
end)
