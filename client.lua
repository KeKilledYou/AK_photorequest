RegisterCommand("photo", function()
    local input = lib.inputDialog("📸 Photo Request", {
        { type = "input", label = "Subject", description = "What do you want photographed?", required = true },
        { type = "input", label = "Location", description = "Where should the photo be taken?", required = true }
    })

    if not input then return end -- canceled
    local subject, location = input[1], input[2]

    -- Send request to server
    TriggerServerEvent("photo:sendRequest", subject, location)
end)

-- Allow photographer to use /acceptphoto
RegisterCommand("acceptphoto", function()
    TriggerServerEvent("photo:acceptRequest")
end)
