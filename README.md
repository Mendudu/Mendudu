# Mendudu
Mendudu provides a simple, lightweight framework for building web servers in Lua. With features like routing, middleware, asynchronous task handling, and support for different content types, it offers a flexible and efficient way to handle HTTP requests. Its event-driven architecture, inspired by Node.js, makes it particularly well-suited for applications requiring high concurrency and low latency.

# Install Mendudu (LuaRocks + get started with Lua)  
Install via LuaRocks:  
`luarocks install mendudu`  

To install Lua & LuaRocks on Windows (to get started coding) you can follow Step 1 & Step 2 in:  
[Install on Windows](https://github.com/Mendudu/Mendudu/blob/main/README.md#to-run-mendudu-on-a-windows-server-youll-need-to-follow-these-steps)

You can also read my Lua guide to get started with Lua:  
[Link to guide](https://docs.google.com/document/d/1lHE56qE8gr2fYI1Yfaus84UUIdqW0Phw_vJccuR22mo/edit?usp=sharing)

Or official Lua reference manual (documentation):  
[Link to Lua reference manual](https://lua.org/docs.html)  

Example how to use it (see under section Example usage).

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

The event loop in the Mendudu framework is integrated and runs automatically when the server is started. Users do not need to perform any additional steps to utilize the event loop functionality. This simplifies the user experience, allowing users to focus on defining routes and middleware.

- Function: runEventLoop()
Continuously processes tasks and microtasks.

### 2. Task and Microtask Queues:  
Internal mechanisms for managing asynchronous tasks.  

- Functions: addTask(task), addMicrotask(microtask)
Used internally to schedule tasks and microtasks.

### 3. Routing
Define routes for different HTTP methods (GET, POST, PUT, PATCH, DELETE) and paths. Each route has an associated handler function that processes the request.

- Function: registerRoute(method, path, handler)

Registers a route with the specified HTTP method and path.
The handler function processes the request and returns the response. 

### 4. Middleware
Middleware functions can be added to process requests before they reach the route handler. This is useful for logging, authentication, and other pre-processing tasks.

- Function: use(middlewareFunc)

Adds a middleware function to the middleware stack.
Middleware functions receive the HTTP method and path of the request.

### 5. Content-Type Support
Handlers can return different content types, such as JSON or plain text, allowing for flexible response formats.

- Function: Route handlers return (status, contentType, responseBody)

Handlers return the HTTP status code, content type, and response body.
Example: return 200, "application/json", json.encode(data)

### 6. Server Setup
Starts the web server on a specified port and begins accepting and handling client connections.

- Function: startServer(port)

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

### Release notes  

#### Release Note for Mendudu 0.1-1
We are excited to announce the first release of Mendudu, version 0.1-1, a simple and lightweight web framework for Lua. This initial release includes the following features:

Features:  
- Integrated Event Loop: Seamlessly handles asynchronous tasks, inspired by Node.js.  
- Routing: Easily define routes for various HTTP methods (GET, POST, PUT, PATCH, DELETE).  
- Middleware Support: Add middleware functions to process requests before they reach the route handler.  
- Content-Type Support: Return different content types (e.g., JSON, text) to meet diverse client needs.  
- Simple Logging: Basic logging for incoming requests using middleware  

_________________________________________________________________________________

### To run Mendudu on a server (e.g., a Linux server), you'll need to follow these steps  
1. Install Lua: Ensure Lua is installed on your server.
2. Install Dependencies: Install required Lua libraries (luasocket and dkjson) using LuaRocks.
3. Set Up a Script to Run Mendudu: Create a Lua script to define your routes and start the server.
4. Set Up a Service: Use a service manager like systemd to ensure your server runs continuously and restarts on crashes.

# Step-by-step guide:

## Step 1: Install Lua
Install Lua on your server. For example, on a Debian-based system:
```
sudo apt-get update
sudo apt-get install lua5.3
```

Or any other version of Lua. You can do:  
`sudo apt-get update` update the package list.  
`apt-cache search lua | grep lua5.4` search for Lua package (in this case 5.4)  
If you see lua5.4 can you can just do:  
`sudo apt-get install lua5.4`  

If lua5.4 is not available, you will need to install it from source.  

Installing Lua 5.4.2 from Source (Detailed Steps):  
1. Install dependencies `sudo apt-get install -y build-essential libreadline-dev`  
2. Download and Extract Lua 5.4.2  
```
curl -R -O http://www.lua.org/ftp/lua-5.4.2.tar.gz
tar zxf lua-5.4.2.tar.gz
```  
3. Build and Install Lua  
```
cd lua-5.4.2
make linux test
sudo make install
```

This is applicable to other versions aswell.  

## Step 2: Install LuaRocks  
Install LuaRocks to manage Lua modules:
`sudo apt-get install luarocks`

## Step 3: Install Mendudu and Dependencies:  
```
luarocks install mendudu
luarocks install dkjson
luarocks install luasocket
```
## Step 4: Create Your Mendudu Application  

Create a Lua script for your Mendudu-based application. For example, create app.lua:
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

## Step 5: Set Up a Systemd Service  
Create a systemd service to manage your application. Create a service file, e.g., /etc/systemd/system/mendudu.service:

```
[Unit]
Description=Mendudu Web Framework Service
After=network.target

[Service]
ExecStart=/usr/bin/lua /path/to/your/app.lua
Restart=always
User=nobody
Group=nogroup
Environment=PATH=/usr/bin:/bin
Environment=NODE_ENV=production
WorkingDirectory=/path/to/your/

[Install]
WantedBy=multi-user.target
```

Replace /path/to/your/app.lua with the actual path to your app.lua script.  


## Step 6: Enable and Start the Service  
Enable and start the systemd service:  

```
sudo systemctl daemon-reload
sudo systemctl enable mendudu
sudo systemctl start mendudu
```

You can check the status of your service with:
`sudo systemctl status mendudu`

By following these steps, you can deploy and run your Mendudu-based web application on a Linux server, ensuring it remains running reliably even if it crashes.

_________________________________________________________________________________

### To run Mendudu on a windows server, you'll need to follow these steps  
## Step 1: Install Lua
1. Go to LuaBinaries (https://luabinaries.sourceforge.net/download.html) and download lua-5.4.2_Win64_bin.zip or the version you want.
2. Create a new folder C:\Program Files\Lua.
3. Extract the downloaded files into C:\Program Files\Lua.
4. Set the system PATH:
- Search for "System" in the search bar (left corner in Windows).
- Go to "Advanced system settings" and click on the "Environment Variables" button.
- Under the "System variables" section, find Path, select it, and press "Edit".
- Press the "New" button and add C:\Program Files\Lua.
- Click "OK", "OK", "OK" to close all dialogs.

## Step 2: Install LuaRocks
Download LuaRocks for Windows from the LuaRocks site (https://github.com/luarocks/luarocks/wiki/Download).

Follow the instructions to install LuaRocks on Windows.

After installation, open Command Prompt and run:
```
luarocks install luasocket
luarocks install dkjson
luarocks install mendudu
``` 
## Step 3: Create Your Mendudu Application
Create your app.lua script in a directory, e.g., C:\MyMenduduApp:

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

## Step 4: Run Your Application as a Service
To run your Lua application as a Windows service, you can use NSSM (Non-Sucking Service Manager). Here's how:  

### 1. Download NSSM:  
Go to the NSSM website (https://nssm.cc/) and download the appropriate version for your system.
Extract the files to a folder, e.g., C:\nssm.  

### 2. Set Up the Service:  

Open Command Prompt as Administrator.  

Navigate to the NSSM folder:  
`cd C:\nssm\win64`  

Install your Lua application as a service using NSSM:  
`nssm install MenduduService "C:\Program Files\Lua\lua.exe" "C:\MyMenduduApp\app.lua"`   

This will open the NSSM GUI. Fill in the details:    

Path: C:\Program Files\Lua\lua.exe  
Startup Directory: C:\MyMenduduApp  
Arguments: app.lua`  

### 3. Configure the Service:  

- In the NSSM GUI, you can set up various parameters such as the display name, description, and startup type.  
- Click "Install Service" when done.

### 4. Manage the Service:  
Start the service:  
`nssm start MenduduService`    

To stop the service:  
`nssm start MenduduService`  

By following these steps, you can set up your Mendudu application to run continuously on a Windows server, with automatic restarts if the application crashes.  

To remove the service:  
`nssm remove MenduduService confirm`  

_________________________________________________________________________________

### Expose application to the internet

To expose your Lua application to the internet with a domain like mydomain.com/api/, you typically use a reverse proxy server such as Nginx. Nginx will handle incoming HTTP requests and forward them to your Lua application running on your server. This setup is beneficial for handling SSL termination, load balancing, and other web server tasks.

## Step-by-Step Guide to Expose Your Lua Application

### Step 1: Install Nginx  
First, install Nginx on your server. On a Debian-based system, you can install Nginx with:  
```
sudo apt-get update
sudo apt-get install nginx
```
For Windows, you can download Nginx from the Nginx website (https://nginx.org/) and follow the installation instructions for Windows.   

### Step 2: Configure Nginx  
Create an Nginx configuration file to set up the reverse proxy. Here’s an example configuration:

1. Open or create a new configuration file for your site:
`sudo nano /etc/nginx/sites-available/mydomain.com`

2. Add the following configuration:
```
server {
    listen 80;
    server_name mydomain.com;

    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
This configuration tells Nginx to listen on port 80 (standard HTTP port) and forward requests that match /api/ to your Lua application running on localhost:8080.

3. Enable the configuration by creating a symlink to sites-enabled:  
`sudo ln -s /etc/nginx/sites-available/mydomain.com /etc/nginx/sites-enabled/`  

4. Test the Nginx configuration for syntax errors:  
`sudo nginx -t`

5. Reload Nginx to apply the changes:  
`sudo systemctl reload nginx`

### Step 3: Update DNS Settings  
Ensure that your domain (mydomain.com) points to your server's IP address. This is done by updating the DNS settings with your domain registrar.

### Step 4: Secure with SSL (Optional but recommended)
For HTTPS, use Certbot to obtain and manage SSL certificates from Let’s Encrypt:

1. Install Certbot:  
`sudo apt-get install certbot python3-certbot-nginx`  

The python3-certbot-nginx package is specifically designed to automate the process of configuring Nginx for SSL, but if you prefer or have a minimal setup, installing just certbot is sufficient.

2. Obtain and install the SSL certificate:
`sudo certbot --nginx -d mydomain.com` 

Follow the prompts to configure SSL. Certbot will automatically update your Nginx configuration to support HTTPS.

Certbot installs a cron job or systemd timer to renew your certificates automatically. You can check the status of the automatic renewal process by running:
`sudo systemctl status certbot.timer` 

You can also manually test the renewal process:
`sudo certbot renew --dry-run``


## Example for Windows (Nginx Installation)
1) Download Nginx: Go to the Nginx download page (https://nginx.org/en/download.html) and download the appropriate version for Windows.
2) Extract Nginx: Extract the downloaded files to a directory, e.g., C:\nginx.
3) Configure Nginx: Edit the nginx.conf file located in the conf directory within the Nginx installation directory to include a configuration similar to the one above.
4) Run Nginx: Start Nginx by running nginx.exe from the command prompt within the Nginx directory:
```
cd C:\nginx
start nginx
```

### Summary (Nginx as a reverse proxy)  
By using Nginx as a reverse proxy, you can expose your Lua application to the internet, allowing users to access it via a domain name like mydomain.com/api/. Nginx handles the incoming requests and forwards them to your application, providing a robust and scalable solution for web application deployment.

With SSL configured, your application will also benefit from encrypted communications, enhancing security for your users.
