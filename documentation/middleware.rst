.. _middleware:

Middleware
-----------------------------------------------

The Crax middleware consists of two parts.

The first part is **RequestMiddleware**.

If you want to do something with a request BEFORE this will be processed, you need this middleware.
For example, you don't want to waste your application resources on prematurely bad requests and
you want to filter out such requests before the url resolution mechanism is triggered or your
the handler will start its work.
To enable middleware, you must specify the `MIDDLEWARE` variable in the settings as a string that is
valid Python import.

There are three predefined Crax Request Middleware:

.. code-block:: python

    MIDDLEWARE = [
        "crax.auth.middleware.AuthMiddleware",
        "crax.middleware.x_frame.XFrameMiddleware",
        "crax.middleware.max_body.MaxBodySizeMiddleware",
    ]


**XFrameMiddleware**
    Must be defined in the middleware list as `crax.middleware.x_frame.XFrameMiddleware`. This middleware sets the policy
    rendering tags such as `<frame>, <iframe>, <embed>`.

    Can be customized with settings variable **X_FRAME_OPTIONS**:
        Available options:
            1. "SAMEORIGIN" - (default)
            2. "DENY"

**MaxBodySizeMiddleware**
    Must be specified in the middleware list as `crax.middleware.max_body.MaxBodySizeMiddleware`. Sets the maximum size
    a request body that your application can process. You can of course control this using the WebServer options.
    but the application must be able to protect itself.

    Can be customized with settings variable **MAX_BODY_SIZE**:
        Type of int. Default value is 1024 * 1024

**AuthMiddleware**
    Middleware that checks if user is authenticated. See :ref:`authorization` section for details.

Of course, custom middleware can be included in the `MIDDLEWARE` list. Let's create a simple RequestMiddleware.
There are two rules for creating custom Request middleware classes.

The first rule is:
    Your custom Request Middleware must be inherited from Crax's `RequestMiddleware`, otherwise it won't
    processed.

The second rule is:
    The **process_headers** method must be defined in your middleware class. Otherwise, you will get errors.

Let's take a simple example. We may want to deny all requests coming from the `Tor Network`.
And we don't want to handle such requests at all. We're going to return "HTTP 400 Bad request". Let's write simply
Request middleware for these purposes.

.. code-block:: python

    # my_app/middleware.py

    import requests
    from crax.middleware.base import RequestMiddleware

    class DenyTorMiddleware(RequestMiddleware):
    async def process_headers(self):
        nodes = requests.get('https://check.torproject.org/torbulkexitlist')
        nodes_lst = nodes.content.decode('utf-8').split('\n')
        if self.request.client.split(':')[0] in nodes_lst:
            self.request.status_code = 400
            return RuntimeError("Tor requests are not allowed")
        else:
            return self.request

    # my_app/conf.py

    MIDDLEWARE = ['my_app.middleware.DenyTorMiddleware']

We have done. Now all requests from the Tor network will have a 400 HTTP response. Please note that your individual request
Middleware should always return a :ref:`request` object or an error. In case an error is returned, it will be
handled by the default error handler if your application is in debug mode, or by your custom error handler
if it is in production mode. See :ref:`exceptions` for details.

Please be polite and don't write code like the example in your production. Don't make a lot of requests
to the `Tor Project` servers. Instead, you should store the list of ExitNodes somewhere and update it periodically!

The second part is **ResponseMiddleware**.

If you want to do something with a request AFTER this will be processed, you need this middleware.
For example you want to update every response headers with some values.

There are two predefined Crax Response Middleware:

.. code-block:: python

    MIDDLEWARE = [
        "crax.auth.middleware.SessionMiddleware",
        "crax.middleware.cors.CorsHeadersMiddleware",
    ]

**SessionMiddleware**
    Should be defined in middleware list as `crax.auth.middleware.SessionMiddleware`. Manages user session.

    Can be customized with settings variables:

        **SESSION_EXPIRES**:
            Setting variable that defines session ttl. Default value is 1209600

        **SESSION_COOKIE_NAME**:
            Sets session cookie name. Default value is `session_id`

        **SAME_SITE_COOKIE_MODE**
            Sets `sameSite` cookies politics. Default value is `Lax`.
            Available options:

                1. "Lax" - (default)
                2. "Strict"
                3. "None"

    See :ref:`authorization` section for details.

**CorsHeadersMiddleware**
    Should be defined in middleware list as `crax.middleware.cors.CorsHeadersMiddleware`. Enables CORS Headers support.

    Can be customized with settings variables:

        **CORS_OPTIONS**:
            Type of dict. Describes CORS Politics of your project. Example:

            .. code-block:: python

                CORS_OPTIONS = {
                    "origins": ["*"],
                    "methods": ["*"],
                    "headers": ["*"]
                }

            This dict can take parameters:

            **origins**:
                List of hosts that are allowed to send CORS requests to your application. For example:

                .. code-block:: python

                    CORS_OPTIONS = {
                        "origins": ["http://127.0.0.1:8080", "http://192.168.0.1:8080"],
                    }

                With an asterisk as the value, all hosts will be able to send CORS requests.

            **methods**:
                List of available CORS requests methods.

                .. code-block:: python

                    CORS_OPTIONS = {
                        "methods": ["POST", "PATCH"],
                    }

                All methods are allowed with an asterisk as the value.

            **headers**:
                List of available CORS requests headers.

                .. code-block:: python

                    CORS_OPTIONS = {
                        "methods": ["content-type"],
                    }

                All headers are allowed with an asterisk as the value.

            **cors_cookie**:
                Sometimes it's not enough to just handle the CORS request on the server side. We must be sure
                this sender can read our response. In some cases, such as when using `axios`
                libraries for making requests, we cannot read the response due to CORS policies.
                To avoid this, you must specify the value of this parameter in the request headers. If Crax finds
                this is the header value in the request header, the response will be updated from
                Access-Control-Allow-Origin, Access-Control-Allow-Methods, and Access-Control-Allow-Headers.
                The values ​​are taken from the CORS_OPTIONS variable.

                .. code-block:: python

                    CORS_OPTIONS = {
                        "cors_cookie": "Allow-By-Cookie",
                    }

                .. code-block:: js

                    import axios from 'axios'

                    axios({
                        method: 'post',
                        url: 'http://127.0.0.1:8000',
                        headers: {'Allow-By-Cookie': true}
                    })
                    //Answer can be read on the frontend

            **max_age**:
                The value, in seconds, when the node is marked as trusted and no preflight requests will be sent.
                Set it as a string, not an int. The default is "600".

                .. code-block:: python

                    CORS_OPTIONS = {
                        "max_age": "1200",
                    }

            **expose_headers**:
                List of strings to be placed in the `Access-Control-Expose-Headers` value

                .. code-block:: python

                    CORS_OPTIONS = {
                        "expose_headers": ["Content-Length", "Content-Location"],
                    }

You can of course write your own Response middleware. Let's imagine that for some reason we want to
check out if certain value is present in the response headers and if there is we have to remove it.
Let's create a response middleware. The first will add value to the response headers and the second
tries to find and delete.

.. code-block:: python

    from crax.middleware.base import ResponseMiddleware

    class FirstMiddleware(ResponseMiddleware):

        async def process_headers(self) -> None:
            response = await super(FirstMiddleware, self).process_headers()

            self.headers.append((b"Custom-Cookie", b"Important"))
            response.headers += self.headers
            return response


    class SecondMiddleware(ResponseMiddleware):

        async def process_headers(self) -> None:
            response = await super(SecondMiddleware, self).process_headers()
            dict_headers = dict(response.headers)
            if b"Custom-Cookie" in dict(response.headers):
                del dict_headers[b"Custom-Cookie"]
                response.headers = [(k, v) for k, v in dict_headers.items()]
            return response


    MIDDLEWARE = ['crax_docs.conf.FirstMiddleware', 'crax_docs.conf.SecondMiddleware']
    # Finally, "Custom-Cookie" will not appear in the response headers.

Take a look at the above code. Always, unlike `RequestMiddleware` `ResponseMiddleware`
should return a response that is a call to its parent class.
There is two important rules.

The first is:
    The ** process_headers ** method must always be defined, otherwise you will get an error.

The second is:
    Your custom Response Middleware must be inherited from Crax's `ResponseMiddleware`, otherwise it won't
    processed.

.. toctree::
   :maxdepth: 3
   :caption: Contents:


.. index::
   Middleware