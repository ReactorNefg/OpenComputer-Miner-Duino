local component = require("component")
local sha = require("sha2")
inet = component.internet
-- file=io.open("MyFile","w")
username = "Reactor"
--local config = require ("config.lua")

local fs = require("filesystem")

local function getRealTime()
    local name = os.tmpname()
    local f = io.open(name, "w")
    f:close()

    local time = fs.lastModified(name) / 1000
    fs.remove(name)
    return time
end

local function round(num)
    return num + (2 ^ 52 + 2 ^ 51) - (2 ^ 52 + 2 ^ 51)
end

while true do
    local socket, reason = inet.connect("5.230.70.190", 6000)
    if not socket then
        return nil, reason
    end

    print("Asking for a new job for user: " .. username)
    socket.write("JOB," .. username .. ",ESP32")
    os.sleep(0.1)
    job = socket.read()
    tostring(job)
    newjob = job:sub(4)
    t = {}
    for s in newjob:gmatch("([^,]+)") do
        t[#t + 1] = s
    end

    lastBlockHash, expectedHash, difficulty = table.unpack(t)
    print("Job received: " .. lastBlockHash .. " " .. expectedHash .. " " .. difficulty)

    range = 100 * tonumber(difficulty) + 1
    hashingStartTime = getRealTime()
    for result = 0, range do
        ducos1 = sha.sha1(lastBlockHash .. tostring(result))
        if ducos1 == expectedHash then
            hashingStopTime = getRealTime()
            timeDifference = hashingStopTime - hashingStartTime
            hashrate = result / timeDifference
            --send = tostring(result) .. "," .. tostring(round(hashrate)) .. "," ..  "LuaMiner 1.0" .. "," .. "Miner1" -- Не пашит хеш рейт
            send = tostring(result) .. "," .. "LuaMiner 1.0"
            print(send)
            -- file:write(lastBlockHash .. "," .. expectedHash	 .. "," .. send)
            -- file:close()
            socket.write(send)
            respone = socket.read()
            os.sleep(0.5)
            print(respone)
            socket.close()
        end
    end
end
