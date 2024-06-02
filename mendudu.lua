local socket = require("socket")
local json = require("dkjson")

local mendudu = {}
local taskQueue = {}
local microtaskQueue = {}
local routes = {
    GET = {},
    POST = {},
    PUT = {},
    PATCH = {},
    DELETE = {},
}
local middleware = {}

-- Function to add a task to the task queue
local function addTask(task)
    table.insert(taskQueue, task)
end

-- Function to add a microtask to the microtask queue
local function addMicrotask(microtask)
    table.insert(microtaskQueue, microtask)
end

-- Function to run the event loop
local function runEventLoop()
    while #taskQueue > 0 or #microtaskQueue > 0 do
        -- Execute all microtasks
        while #microtaskQueue > 0 do
            local microtask = table.remove(microtaskQueue, 1)
            microtask()
        end
        
        -- Execute one task from the task queue
        if #taskQueue > 0 then
            local task = table.remove(taskQueue, 1)
            local co = coroutine.create(task)
            coroutine.resume(co)
        end
    end
end

-- Function to register a route
function mendudu.registerRoute(method, path, handler)
    routes[method][path] = handler
end

-- Function to add middleware
function mendudu.use(middlewareFunc)
    table.insert(middleware, middlewareFunc)
end

-- Function to parse the HTTP request
local function parseRequest(request)
    local method, path = request:match("^(%w+)%s(/%S*)%sHTTP/%d%.%d")
    return method, path
end

-- Function to handle incoming HTTP requests
local function handleClient(client)
    client:settimeout(10)
    local request, err = client:receive()

    if not request then
        client:close()
        return
    end

    local method, path = parseRequest(request)

    if method and path then
        -- Apply middleware
        for _, mw in ipairs(middleware) do
            mw(method, path)
        end

        -- Route the request
        if routes[method] and routes[method][path] then
            local handler = routes[method][path]
            local status, contentType, responseBody = handler()
            client:send(string.format("HTTP/1.1 %d OK\r\nContent-Type: %s\r\n\r\n%s", status, contentType, responseBody))
        else
            client:send("HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\nNot Found")
        end
    else
        client:send("HTTP/1.1 400 Bad Request\r\nContent-Type: text/plain\r\n\r\nBad Request")
    end

    client:close()
end

-- Function to start the web server
function mendudu.startServer(port)
    local server = assert(socket.bind("*", port))
    server:settimeout(0)  -- Non-blocking

    print("Server started on port " .. port)

    -- Function to accept connections
    local function acceptClients()
        while true do
            local client = server:accept()
            if client then
                addTask(function() handleClient(client) end)
            else
                coroutine.yield()  -- Yield the coroutine if no client is available
            end
        end
    end

    -- Add the acceptClients function to the task queue
    addTask(acceptClients)
    
    -- Run the event loop
    runEventLoop()
end

return mendudu