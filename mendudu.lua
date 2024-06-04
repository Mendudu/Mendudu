local socket = require("socket")
local json = require("dkjson")
local lfs = require("lfs")  -- LuaFileSystem for directory traversal

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
    while true do
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
        
        -- Yield to prevent 100% CPU usage in the absence of tasks
        socket.sleep(0.01)
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

-- Function to parse query parameters
local function parseQueryParams(queryString)
    local params = {}
    for key, value in queryString:gmatch("([^&=?]+)=([^&=?]+)") do
        params[key] = value
    end
    return params
end

-- Function to parse the HTTP request
local function parseRequest(request)
    local method, path, queryString = request:match("^(%w+)%s(/%S*)%?([^%s]*)%sHTTP/%d%.%d")
    if not method then
        method, path = request:match("^(%w+)%s(/%S*)%sHTTP/%d%.%d")
    end
    local queryParams = queryString and parseQueryParams(queryString) or {}
    return method, path, queryParams
end

-- Function to serve static files
local function serveStatic(directory)
    return function(reqMethod, reqPath)
        local filePath = directory .. reqPath
        local file = io.open(filePath, "rb")
        
        if file then
            local content = file:read("*all")
            file:close()
            local ext = filePath:match("^.+(%..+)$")
            local mimeType = {
                [".html"] = "text/html",
                [".css"] = "text/css",
                [".js"] = "application/javascript",
                [".png"] = "image/png",
                [".jpg"] = "image/jpeg",
                [".gif"] = "image/gif",
            }[ext] or "application/octet-stream"
            return 200, mimeType, content
        else
            return 404, "text/plain", "Not Found"
        end
    end
end

-- Register static file serving for a directory
function mendudu.serveStaticRoute(route, directory)
    mendudu.registerRoute("GET", route .. "(.*)", serveStatic(directory))
end

-- Function to parse JSON body
local function parseJsonBody(body)
    return json.decode(body)
end

-- Logging middleware
local function logRequest(method, path, queryParams, body)
    print(string.format("[%s] %s %s", os.date(), method, path))
    if next(queryParams) then
        print("Query Params: ", queryParams)
    end
    if body then
        print("Body: ", body)
    end
end

-- Error handling middleware
local function errorHandler(method, path, queryParams, body)
    local status, err = pcall(function()
        -- This is where the normal processing happens
        return true
    end)
    if not status then
        print("Error: ", err)
    end
end

-- Function to handle incoming HTTP requests
local function handleClient(client)
    client:settimeout(10)
    local request, err = client:receive()

    if not request then
        client:close()
        return
    end

    local method, path, queryParams = parseRequest(request)

    local body = ""
    repeat
        local chunk, err = client:receive(1024)
        if chunk then
            body = body .. chunk
        end
    until not chunk

    if method and path then
        -- Apply middleware
        for _, mw in ipairs(middleware) do
            mw(method, path, queryParams, body)
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

-- Add logging and error handling middleware
mendudu.use(logRequest)
mendudu.use(errorHandler)

return mendudu