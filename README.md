# Mendudu
Mendudu Web Framework

Selling Points of Mendudu:  
- Event-Driven Architecture: Inspired by Node.js, Mendudu provides an event-driven model that allows for efficient handling of asynchronous tasks.  
- Simple and Lightweight: Mendudu is designed to be lightweight and easy to use, making it ideal for small projects and rapid prototyping.  
- Flexible Routing: Easily define routes for various HTTP methods and paths, allowing for clear and maintainable code.  
- Middleware Support: Add middleware functions to process requests before they reach the route handler, enabling logging, authentication, and more.  
- Content-Type Support: Return different content types (e.g., JSON, text) to cater to diverse client needs.  

Important Notes:  
Non-blocking I/O: The server uses non-blocking I/O (server:settimeout(0)) to ensure it doesn't block while waiting for new connections.  
Coroutines: Coroutines are used to yield and resume tasks, simulating an asynchronous event-driven model.  
