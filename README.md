# Mendudu
Mendudu provides a simple, lightweight framework for building web servers in Lua. With features like routing, middleware, asynchronous task handling, and support for different content types, it offers a flexible and efficient way to handle HTTP requests. Its event-driven architecture, inspired by Node.js, makes it particularly well-suited for applications requiring high concurrency and low latency.

## Selling Points of Mendudu:  
- Event-Driven Architecture: Inspired by Node.js, Mendudu provides an event-driven model that allows for efficient handling of asynchronous tasks.  
- Simple and Lightweight: Mendudu is designed to be lightweight and easy to use, making it ideal for small projects and rapid prototyping.  
- Flexible Routing: Easily define routes for various HTTP methods and paths, allowing for clear and maintainable code.  
- Middleware Support: Add middleware functions to process requests before they reach the route handler, enabling logging, authentication, and more.  
- Content-Type Support: Return different content types (e.g., JSON, text) to cater to diverse client needs.  

Important Notes:  
Non-blocking I/O: The server uses non-blocking I/O (server:settimeout(0)) to ensure it doesn't block while waiting for new connections.  
Coroutines: Coroutines are used to yield and resume tasks, simulating an asynchronous event-driven model.  

## Features and Functions
### 1. Event Loop
Mendudu uses an event loop to handle asynchronous tasks. This allows the server to manage multiple tasks without blocking, ensuring efficient request handling.

Function: runEventLoop()

Continuously checks and executes tasks from the task queue (taskQueue) and microtask queue (microtaskQueue).
Executes all microtasks before handling tasks from the task queue, ensuring higher priority tasks are completed first.
2. Task and Microtask Queue
Tasks and microtasks are managed in separate queues, enabling fine-grained control over the execution order.

Functions: addTask(task), addMicrotask(microtask)

addTask: Adds a task to the task queue, which will be executed by the event loop.
addMicrotask: Adds a microtask to the microtask queue, which will be executed before tasks in the task queue.
### 3. Routing
Define routes for different HTTP methods (GET, POST, PUT, PATCH, DELETE) and paths. Each route has an associated handler function that processes the request.

Function: registerRoute(method, path, handler)

Registers a route with the specified HTTP method and path.
The handler function processes the request and returns the response. 

### 4. Middleware
Middleware functions can be added to process requests before they reach the route handler. This is useful for logging, authentication, and other pre-processing tasks.

Function: use(middlewareFunc)

Adds a middleware function to the middleware stack.
Middleware functions receive the HTTP method and path of the request.

### 5. Content-Type Support
Handlers can return different content types, such as JSON or plain text, allowing for flexible response formats.

Function: Route handlers return (status, contentType, responseBody)

Handlers return the HTTP status code, content type, and response body.
Example: return 200, "application/json", json.encode(data)

### 6. Server Setup
Starts the web server on a specified port and begins accepting and handling client connections.

Function: startServer(port)

Binds the server to the specified port and sets it to non-blocking mode.
Accepts client connections and adds them to the task queue for processing.
Prints a message indicating the server has started.

## Example usage  
Here is an example of how to use Mendudu to create a simple web server:

```
local mendudu = require("mendudu")

-- Define routes
mendudu.registerRoute("GET", "/", function()
    return 200, "text/plain", "Hello, World!"
end)

mendudu.registerRoute("GET", "/json", function()
    local data = {
        message = "Hello, World!",
        status = "success"
    }
    return 200, "application/json", require("dkjson").encode(data)
end)

-- Add middleware
mendudu.use(function(method, path)
    print("Received " .. method .. " request for " .. path)
end)

-- Start the server
mendudu.startServer(8080)
```

### Detailed Function Descriptions
registerRoute(method, path, handler)
-method: HTTP method (e.g., "GET", "POST").
-path: URL path (e.g., "/", "/json").
- handler: Function that handles the request and returns a tuple (status, contentType, responseBody).

use(middlewareFunc)
- middlewareFunc: Function that processes the request before it reaches the handler. Receives the HTTP method and path as arguments.

startServer(port)
- port: Port number to bind the server to (e.g., 8080).
- Initializes the server and begins accepting client connections.
