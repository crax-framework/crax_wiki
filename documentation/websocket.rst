.. _websocket:

WebSockets
-----------------------------------------------

Working with WebSockets is as easy as everything described above. Crax fully supports websockets out of the box.
To enable websockets support you need to take two steps:
First step is:

    Define in your list of urls the route you want to work with websockets.

    .. code-block:: python

        from crax.urls import Route, Url
        from my_app.handlers import WebSocketsHandler

        urls = [Route(Url('/some/path', scheme="websocket"), handler=WebSocketsHandler)]

    Note that you must define a "websocket" scheme to tell Crax that this handler
    going to listen for websocket requests.

    If you are going to listen to "http" and "websocket" simultaneously on the same route, this is not a problem.

    .. code-block:: python

        from crax.urls import Route, Url
        from my_app.handlers import WebSocketsHandler

        urls = [
            Route(Url('/some/path', scheme="websocket"), handler=WebSocketsHandler),
            Route(Url('/some/path'), handler=HttpHandler)
         ]

The second step is:

    We need to create a handler that can handle our web socket requests.

    .. code-block:: python

        from crax.views import WsView

        class WebSocketsHandler(WsView):
            pass

So now everything is ready and we can take some examples.
Let's imagine that we have several users, divided into groups. For example, the first group is boys, and the second is
girls. Our service is user-oriented, so girls may not want to receive news about hockey, and boys are less interested.
nails and eyelashes. So we will only send out nail messages to girls and hockey to boys.
We also want to send broadcast messages to all users. Also, each user has a subscription and our simple service
should be able to send direct messages over websockets.

Let's create simple Crax project.

Then we created a python package named `ws_app` with one file inside named `app.py`. Finally, we create a template
directory with a single file named index.html. Note that the `templates` directory is inside the package.

`app.py`:

    .. code-block:: python

        import os
        import sys

        from crax import Crax
        from crax.commands import from_shell
        from crax.urls import Route, Url
        from crax.views import TemplateView, WsView

        BASE_URL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        SECRET_KEY = "SuperSecret"
        MIDDLEWARE = [
            "crax.auth.middleware.AuthMiddleware",
            "crax.auth.middleware.SessionMiddleware",
        ]

        APPLICATIONS = ["ws_app"]


        class Home(TemplateView):
            template = "index.html"


        class WebSocketsHome(WsView):
            pass


        URL_PATTERNS = [Route(Url("/"), Home), Route(Url("/", scheme="websocket"), WebSocketsHome)]

        DATABASES = {
                "default": {
                    "driver": "sqlite",
                    "name": f"/{BASE_URL}/ws_crax.sqlite",
                }
        }
        app = Crax('ws_app.app')

        # We are going to use commands so we need enable cli support
        if __name__ == "__main__":
            if sys.argv:
                from_shell(sys.argv, app.settings)

`index.html`:

    .. code-block:: html

        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="UTF-8">
                <title>Crax Websockets</title>
            </head>
            <body>
                <script>
                    ws = new WebSocket("ws://127.0.0.1:8000")
                </script>
            </body>
        </html>

Launch our simple app:

.. code-block:: bash

    uvicorn ws_app.app:app

So we have done with the boilerplate of our app.
Good. Let's create our database. As you remember, Crax already has all the models we need to
create this simple application. Therefore, we can skip defining our models. Also, how much did we activate authorization
backend in our settings, we already have access to our user models.
We are also not interested in tracking our model changes, so we can just run:

.. code-block:: bash

    python ws_app/app.py db_create_all

Perfect. We created our database with all the models we need. So now we can insert some users in our database.
Let's create simple coroutine.

.. code-block:: python

    # create_users.py

    import asyncio
    import os

    from crax.auth.models import User, Group, UserGroup
    from crax.auth.authentication import create_password


    async def create_users():
        os.environ["CRAX_SETTINGS"] = "ws_app.app"
        await Group.query.bulk_insert(values=[{"name": "boys"}, {"name": "girls"}])
        boys = ["Greg", "Chuck", "Mike"]
        girls = ["Amanda", "Lisa", "Anny"]
        boys_values = [{"username": x.lower(), "password": create_password(x), "first_name": x} for x in boys]
        girls_values = [{"username": x.lower(), "password": create_password(x), "first_name": x} for x in girls]
        await User.query.bulk_insert(values=boys_values)
        await User.query.bulk_insert(values=girls_values)
        db_boys = await User.query.fetch_all(query=User.table.select(User.c.first_name.in_(boys)))
        db_girls = await User.query.fetch_all(query=User.table.select(User.c.first_name.in_(girls)))
        boys_group = await Group.query.fetch_one(query=Group.table.select(Group.c.name == "boys"))
        girls_group = await Group.query.fetch_one(query=Group.table.select(Group.c.name == "girls"))
        await UserGroup.query.bulk_insert(values=[{"user_id": x["id"], "group_id": boys_group["id"]} for x in db_boys])
        await UserGroup.query.bulk_insert(values=[{"user_id": x["id"], "group_id": girls_group["id"]} for x in db_girls])

    loop = asyncio.new_event_loop()
    loop.run_until_complete(create_users())

As you remember, we can work with our models, database and applications from anywhere we want, since we set up the project
environment configuration. Create a python file named `create_users.py`. And place it outside the package. If a
Python import is able to find configuration, everything will work.
You did it. We now have six users in our database, divided into groups.

Therefore we are going to work with authorized users only, let's create simple login handler. Let's update our
`app.py` with some code.

.. code-block:: python

    class Login(TemplateView):
        template = "login.html"
        methods = ["GET", "POST"]

        async def post(self):
            credentials = json.loads(self.request.post)
            try:
                await login(self.request, **credentials)
                if hasattr(self.request.user, "first_name"):
                    context = {'success': f"Welcome back, {self.request.user.username}"}
                    status_code = 200
                else:
                    context = {'error': f"User or password wrong"}
                    status_code = 401
            except Exception as e:
                context = {'error': str(e)}
                status_code = 500
            response = JSONResponse(self.request, context)
            response.status_code = status_code
            return response

    URL_PATTERNS = [Route(Url("/"), Home), Route(Url("/", scheme="websocket"), WebSocketsHome), Route(Url("/login"), Login)]

And create `login.html` file in our `templates` directory.

.. code-block:: html

    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Crax Websockets</title>
    </head>
    <body>
        <form>
            <input id="username">
            <input id="password" type="password">
        </form>
        <div id="loginResults"></div>
        <a href="#" id="sendLogin">Login</a>

        <script>
            var loginButton = document.getElementById("sendLogin")
            var loginResults = document.getElementById("loginResults")
            var username = document.getElementById("username")
            var password = document.getElementById("password")
            loginButton.addEventListener("click", function (e) {
                e.preventDefault()
                if (username.value !== "" && password.value !== "") {
                    var xhr = new XMLHttpRequest()
                    xhr.overrideMimeType("application/json")
                    xhr.open("POST", "/login")
                    xhr.send(JSON.stringify({username: username.value, password: password.value}))
                    xhr.onload = function () {
                        var result = JSON.parse(xhr.responseText)
                        if ("success" in result){
                            loginResults.innerHTML+="<h5 style='color: green'>"+result.success+ "</h5>"
                        }
                        else if ("error" in result) {
                            loginResults.innerHTML+="<h5 style='color: red'>"+result.error+ "</h5>"
                        }
                    }
                }
            })
        </script>
    </body>
    </html>

As we remember, all password are equal to the first names.
And we want to deny access to unauthorized users to our `Home` view.

.. code-block:: python

    class Home(TemplateView):
        template = "index.html"
        login_required = True


So let's build websocket support according to our needs. We are going to update our `index.html` file
for sending various types of messages over websockets.

.. code-block:: html

    <!-- index.html -->

    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>Crax Websockets</title>
        </head>
        <body>
            <div id="wsText"></div>
            <form>
                <input id="messageText"><br>
                <select id="targetGroup">
                    <option>boys</option>
                    <option>girls</option>
                </select>
                <select id="messageType">
                    <option>BroadCast</option>
                    <option>Group</option>
                    <option>Direct</option>
                </select>
                <select id="userNames">
                    <option>Greg</option>
                    <option>Chuck</option>
                    <option>Mike</option>
                    <option>Amanda</option>
                    <option>Lisa</option>
                    <option>Anny</option>
                </select>
            </form>
            <a href="#" id="sendWs">Send Message</a>
            <script>
                var wsText = document.getElementById("wsText")
                var messageType = document.getElementById("messageType")
                var messageText = document.getElementById("messageText")
                var targetGroup = document.getElementById("targetGroup")
                var userName = document.getElementById("userNames")
                var sendButton = document.getElementById("sendWs")
                ws = new WebSocket("ws://127.0.0.1:8000")
                ws.onmessage = function(e){
                    wsText.innerHTML+=e.data
                }

                sendButton.addEventListener("click", function (e) {
                    e.preventDefault()
                    var message = {type: messageType.value, text: messageText.value}
                    var data
                    if (messageText.value !== "") {
                        if (messageType.value === "BroadCast"){
                            // send broadcast message
                            data = message
                        }
                        else if (messageType.value === "Group"){
                            // send message to group
                            data = Object.assign(message, {group: targetGroup.value})
                        }
                        else if (messageType.value === "Direct"){
                            // send message to certain user
                            data = Object.assign(message, {user_name: userName.value})
                        }
                        ws.send(JSON.stringify(data))
                    }
                })
            </script>
        </body>
        </html>

That's all. We can now send websocket messages with the type we choose from our selection. Now we're going to include
server side support. In our `app.py`

.. code-block:: python

    import asyncio
    import json
    import os
    from base64 import b64decode
    from functools import reduce

    from crax.auth import login
    from crax.auth.authentication import create_session_signer
    from crax.auth.models import Group, UserGroup
    from crax.response_types import JSONResponse
    from crax.urls import Route, Url
    from crax.views import TemplateView, WsView
    from sqlalchemy import and_, select
    from websockets import ConnectionClosedOK

    BASE_URL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    SECRET_KEY = "SuperSecret"
    MIDDLEWARE = [
        "crax.auth.middleware.AuthMiddleware",
        "crax.auth.middleware.SessionMiddleware",
    ]

    APPLICATIONS = ["ws_app"]
    CLIENTS = {'boys': [], 'girls': []}


    class Home(TemplateView):
        template = "index.html"
        login_required = True


    class Login(TemplateView):
        template = "login.html"
        methods = ["GET", "POST"]

        async def post(self):
            credentials = json.loads(self.request.post)
            try:
                await login(self.request, **credentials)
                if hasattr(self.request.user, "first_name"):
                    context = {'success': f"Welcome back, {self.request.user.username}"}
                    status_code = 200
                else:
                    context = {'error': f"User or password wrong"}
                    status_code = 401
            except Exception as e:
                context = {'error': str(e)}
                status_code = 500
            response = JSONResponse(self.request, context)
            response.status_code = status_code
            return response


    class WebSocketsHome(WsView):

        def __init__(self, request):
            super(WebSocketsHome, self).__init__(request)
            self.group_name = None

        async def on_connect(self, scope, receive, send):
            # This coroutine will be called every time a client connects.
            # So at this point we can do some useful things when we find a new connection.

            await super(WebSocketsHome, self).on_connect(scope, receive, send)
            if self.request.user.username:
                cookies = self.request.cookies
                # In our example, we want to check a group and store the user in the desired location.

                query = select([Group.c.name]).where(
                    and_(UserGroup.c.user_id == self.request.user.pk, Group.c.id == UserGroup.c.group_id)
                )
                group = await Group.query.fetch_one(query=query)
                self.group_name = group['name']

                # We also want to get the username from the user's session key for future access via direct messaging

                exists = any(x for x in CLIENTS[self.group_name] if cookies['session_id'] in list(x)[0])
                signer, max_age, _, _ = create_session_signer()
                session_cookie = b64decode(cookies['session_id'])
                user = signer.unsign(session_cookie, max_age=max_age)
                user = user.decode("utf-8")
                username = user.split(":")[0]
                val = {f"{cookies['session_id']}:{cookies['ws_secret']}:{username}": receive.__self__}

                # Since we have all the information we need, we can save the user
                # The key will be session: ws_cookie: username and the value will be an instance of uvicorn.WebSocketProtocol

                if not exists:
                    CLIENTS[self.group_name].append(val)
                else:
                    # We should clean up our storage to prevent existence of the same clients.
                    # For example due to page reloading
                    [
                        CLIENTS[self.group_name].remove(x) for x in
                        CLIENTS[self.group_name] if cookies['session_id'] in list(x)[0]
                    ]
                    CLIENTS[self.group_name].append(val)

        async def on_disconnect(self, scope, receive, send):
            # This coroutine will be called every time a client disconnects.
            # So at this point we can do some useful things when we find a client disconnects.
            # We remove the client from the storage

            cookies = self.request.cookies
            if self.group_name:
                try:
                    [
                        CLIENTS[self.group_name].remove(x) for x in
                        CLIENTS[self.group_name] if cookies['session_id'] in list(x)[0]
                    ]
                except ValueError:
                    pass

        async def on_receive(self, scope, receive, send):
            # This coroutine will be called every time we receive a new incoming websocket message.
            # Check the type of message received and send a response according to the message type.

            if "text" in self.kwargs:
                message = json.loads(self.kwargs["text"])
                message_text = message["text"]
                clients = []
                if message["type"] == 'BroadCast':
                    clients = reduce(lambda x, y: x + y, CLIENTS.values())

                elif message["type"] == 'Group':
                    clients = CLIENTS[message['group']]

                elif message["type"] == 'Direct':
                    username = message["user_name"]
                    client_list = reduce(lambda x, y: x + y, CLIENTS.values())
                    clients = [client for client in client_list if username.lower() in list(client)[0]]
                for client in clients:
                    if isinstance(client, dict):
                        client = list(client.values())[0]
                        try:
                            await client.send(message_text)
                        except (ConnectionClosedOK, asyncio.streams.IncompleteReadError):
                            await client.close()
                            clients.remove(client)


    URL_PATTERNS = [Route(Url("/"), Home), Route(Url("/", scheme="websocket"), WebSocketsHome), Route(Url("/login"), Login)]
    DATABASES = {
            "default": {
                "driver": "sqlite",
                "name": f"/{BASE_URL}/ws_crax.sqlite",
            },
        }
    app = Crax('ws_app.app')

    if __name__ == "__main__":
        if sys.argv:
            from_shell(sys.argv, app.settings)


So we did it. Now our service can send private messages to a specific user, send messages to a group of users.
and send broadcast messages.

Let's talk about the built-in `WsView` that we used to create our simple service.

The first argument this view takes is :ref:`request`. If you don't need to do something with the `__init__` method
your class, you can skip it because it is already defined. So, as you saw in the example above, we can get all
information from the `Request` object.
The methods:

    **on_connect(scope, receive, send)**:

        Will be called every time a client connects

    **on_disconnect(scope, receive, send)**:

        Will be called every time a client disconnects

    **on_receive(scope, receive, send)**:

        Will be called every time we receive a new incoming websocket message.

        In the example above, we are using the uvicorn.WebSocketProtocol instance to send messages. However, the message may
        be sent using the default ASGI implementation.

        .. code-block:: python

            async def on_receive(self, scope, receive, send):
                message = json.loads(self.kwargs["text"])
                message_text = message["text"]
                await send({'type': 'websocket.send', 'text': message_text})

        The simplest example to send `echo message` to the sender

    **dispatch(scope, receive, send)**:

        A method that checks for events and performs work according to the event. We can override it's behaviour:

        .. code-block:: python

            async def dispatch(self, scope, receive, send):
                await super(WsHome, self).dispatch(scope, receive, send)
                connection = await aio_pika.connect_robust("amqp://guest:guest@127.0.0.1/")
                async with connection:
                    queue_name = "ws_messages"
                    channel = await connection.channel()
                    queue = await channel.declare_queue(queue_name)
                    async with queue.iterator() as queue_iter:
                        async for message in queue_iter:
                            async with message.process():
                                message = json.loads(message.body.decode(encoding="utf-8"))
                                for client in CLIENTS:
                                    try:
                                        await client.send(message["body"])
                                    except (ConnectionClosedOK, asyncio.streams.IncompleteReadError):
                                        await client.close()

        So, we want to listen to Rabbit Queue for incoming messages, not for incoming messages via websocket. So
        we can do something like this.

    **__call__(scope, receive, send)**:

        Calls the `dispatch` method. Also a coroutine.

So now you can work with websockets using Crax.

.. toctree::
   :maxdepth: 3
   :caption: Содержание:


.. index::
   WebSockets
