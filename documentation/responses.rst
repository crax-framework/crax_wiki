.. _responses:

Responses
-----------------------------------------------

All requests processed by Crax, even errors, end with a Response object. If you are writing handlers that inherit from Crax
:ref:`views` you must return a Response (if not the default). If you write your own views that do not inherit from Crax views,
you must return a Response as well. Thus, you should always return it. There is only one way not to return a response object:
this is to work with `Start` and `Send` objects according to the ASGI specification.
If you're wondering how to write views without a Response object, or if you want to create your own Response type,
see the `ASGI Response <https://asgi.readthedocs.io/en/latest/specs/www.html#response-start-send-event>`_ documentation.

All of the Crax response types are inheriting from `BaseResponse`.

BaseResponse
======================================================

**BaseResponse**:

    Takes initial arguments.
    **request**:

        An instance of Crax :ref:`request`. All of responses takes as first argument request parameter. May be set to None.

    **content**:
        Type of string, bytes or dict. This is what you want to send in the response body.

    **content_type**:
        Type of string. Sets response content type.

    **status_code**:
        Type of int. Set the status code you want to send. There is one rule of thumb when you cannot override the status code. The
        Crax :ref:`request` has no attribute, but if it exists and its value is in the range [200:227],
        the response status code will be set with this value. Otherwise, the response status code will be set.

    Has methods.
        **render(content)**:
            Where content is the type of string or bytes. Converts content string to bytes if it is not yet.

        **set_cookies(key: str, val: str = "", rest: dict)**:
            Sets the "set-cookie" value for headers from the given parameters. Where key is a string type.
            Where value is a string type. The rest is a dictionary. You can pass any available cookie values ​​with this argument
            as key-value pairs. If your value is incorrect or not supported, no error occurs.
            Any invalid cookie parameters will be skipped.

TextResponse
======================================================

**TextResponse**:
    Overrides nothing from the `BaseResponse`. Content type value equals to "text/html".

JSONResponse
======================================================

**JSONResponse**:
    Overrides the **render()** method.

    **render(content)**:
        Accepts any JSON serializable mapping as an argument. Converts it to JSON. Encodes JSON to bytes.
        Then it returns the encoded string.

.. code-block:: python

    from crax.views import BaseView
    from crax.response_types import TextResponse, JSONResponse

    # Example of usage in Crax Based Views
    class MyCraxView(BaseView):
        methods = ['GET', 'POST']

        async def get(self):
            response = TextResponse(self.request, "Hello world")
            return response

        async def post(self):
            response = JSONResponse(self.request, {"Hello": "World"})
            return response

    # Example of usage in Custom Views
    class MyCustomClassView:
        methods = ['GET', 'POST']

        def __init__(self, request):
            self.request = request

        async def __call__(self, scope, receive, send):
            if self.request.method == "GET":
                response = TextResponse(self.request, "Hello world")
                await response(scope, receive, send)
            elif self.request.method == "POST":
                response = JSONResponse(self.request, {"Hello": "World"})
            return response

    async def my_custom_coroutine_view(request, scope, receive, send):
        if request.method == "GET":
                response = TextResponse(self.request, "Hello world")
                await response(scope, receive, send)
        elif request.method == "POST":
            response = JSONResponse(self.request, {"Hello": "World"})
            return response

FileResponse
======================================================

**FileResponse**:
    Overrides the initial arguments. Instead of `Request` object, the `path` is used as the first argument.

    **path**:
        Type of string. The path to the file you want to process. If the file is not found, a FileNotFoundError exception will be raised.
        If file is found. If the file has not been modified, since the date of the request headers "If-Modified-Since"
        value response status code will be set to 304. Otherwise, the status code will be set to 200.

        .. code-block:: python

            headers = {
                "If-Modified-Since": "Fri, 10 Jul 2122 12:05:43 GMT",
                "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0",
            }
            resp = requests.get(host, headers=headers)
            assert resp.status_code == 304

            headers = {
                "If-Modified-Since": "Fri, 10 Jul 2012 12:05:43 GMT",
                "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0",
            }
            resp = requests.get(host, headers=headers)
            assert resp.status_code == 200

        So, if file exists it will be sent by chunks with chunk size that equals 4096.

        .. code-block:: python

            from crax.response_types import FileResponse
            from crax.utils import get_settings_variable

            async def get_latest_patch(request, scope, receive, send):
                base_url = get_settings_variable('BASE_URL')
                print(base_url)
                response = FileResponse(f'{base_url}/patches/latest.tar.gz')
                await response(scope, receive, send)

StreamingResponse
======================================================

**StreamingResponse**:

    Only response type that does not inherit from BaseResponse. However, the first argument must be an instance of `Request`.
    The main difference from the rest response types is that StreamingResponse takes a **content** argument with
    asynchronous generator type.

    **content**:
        Takes as argument type of `async generator`. Thus any object that provides `__aiter__` and `__anext__` methods
        could be passed as content argument.

    **media_type**:
        Type of content you are going to steam. Default is None.

    Let's create simple example that streams up to 10 numbers to your browser

    .. code-block:: html

        <!-- Your index.html -->
        <ul id="streamResults"></ul>
        <script>
            var streamResults = document.getElementById("streamResults")
            document.addEventListener("DOMContentLoaded", function () {
                streamResults.innerHTML = ""
                var e = new XMLHttpRequest
                e.overrideMimeType("text/plain"), e.open("GET", "/get_stream"),
                e.seenBytes = 0, e.onreadystatechange = () => {
                    if (3 === e.readyState) {
                        var t = e.response.substr(e.seenBytes)
                            streamResults.innerHTML += "<li>" + t + "</li>"
                        e.seenBytes = e.responseText.length
                    }
                }, e.addEventListener("error", e => {
                    console.log(e)
                }), e.send()
            })
        </script>

    .. code-block:: python

        # Your handlers.py

        class StreamView:
            def __init__(self, request):
                self.request = request

            @staticmethod
            async def create_stream():
                for n in range(10):
                    yield str(n)
                    await asyncio.sleep(1)

            async def __call__(self, scope, receive, send):
                stream = self.create_stream()
                response = StreamingResponse(self.request, stream)
                await response(scope, receive, send)


        class ShowStream(TemplateView):
            template = 'index.html'


    .. code-block:: python

        # Your urls.py

        Route(Url('/'), ShowStream),
        Route(Url('/get_stream'), StreamView),

    You can find a more complex example of `Streaming Response` in the Crax github repository. This example shows how you
    can run tests and transmit test results in real time to any number of connected browsers.

.. toctree::
   :maxdepth: 3
   :caption: Contents:


.. index::
   Responses