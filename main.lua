local component = require("component")
local sha = require("sha2")
inet = component.internet
username = "Reactor" -- https://wallet.duinocoin.com -- Ник кошелека Duino


while true do
    local socket, reason = inet.connect("149.91.88.18", 6004) -- IP duino-pool - https://server.duinocoin.com/getPool
    if not socket then
        return nil, reason
    end

    print("Asking for a new job for user: " .. username)
    socket.write("JOB," .. username .. ",ESP32") -- ESP32 сложность майнинга
    os.sleep(3)
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
    for result = 0, range do
        ducos1 = sha.sha1(lastBlockHash .. tostring(result))
        if ducos1 == expectedHash then
            send = tostring(result) .. "," .. "LuaMiner 1.0"
            socket.write(send)
            respone = socket.read()
            os.sleep(0.5)
            print(respone)
            socket.close()
        end
    end
end

-- https://github.com/revoxhere/duino-coin/tree/useful-tools -- API duino
