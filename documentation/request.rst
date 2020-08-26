.. _request:

Request
-----------------------------------------------

.. image:: crax_images/crax_scheme.png
   :width: 1500

Here's a quick schematic of Crax WorkFlow. As you can see, at each stage we can access the object.
from `Crax Request`. Most Crax objects have `request` as their first initial argument. Thus, on each
the handler you write, you can get all the information about the current request.

.. code-block:: python

    from crax.views import BaseView

    class MyView(BaseView):
        async def get(self):
            headers = self.request.headers

Request is a simple Python class that takes an `ASGI <https://asgi.readthedocs.io/en/latest/>`_ `Scope` Object as an initial
 parameter and processes it. Let's see what attributes the request object has.

**scope**:

    Type of dict. An ASGI `Scope` Object.
    All available keys see at `ASGI Connection Scope <https://asgi.readthedocs.io/en/latest/specs/www.html#connection-scope>`_

**params**

    Type of dict. All parameters that were set through the uri parameters

    .. code-block:: python

        Url("/v1/customer/<param_id>/<param_name>/")
        class MyView(BaseView):
            async def get(self):
                assert self.request.params == {"param_id": "1", "param_name": "parameter_one"}


**query**

    Type of dict. All parameters that were set through the query parameters

    .. code-block:: python

        import requests

        requests.get('http://some_host.org/?param_1=1&param_2=2&param_3=3')

        class MyView(BaseView):

            async def get(self):
                assert self.request.query == {'param_1': ['1'], 'param_2': ['2'], 'param_3': ['3']}

**headers**

    Type of dict. All headers of the current request.

**server**

     Type of Iterable. A two-item iterable of [host, port], where host is the listening address
      for this server, and port is the integer listening port. Optional; defaults to None.

**client**

    Type of Iterable. A two-item iterable of [host, port], where host is the remote host’s IPv4 or IPv6 address,
    and port is the remote port as an integer. Optional; defaults to None.

**cookies**

   Type of dict. Current request cookies.

**session**

    Type of dict. If authorization backend is enabled in your project configuration file (:ref:`settings`)
    You can get access to the session of current user.

**user**

    `User` type or `AnonymousUser` type. If the user is authenticated, it will be set as "User", otherwise as "AnonymousUser".
    See the :ref:`authorization` section for details on sessions and users.

**scheme**

    String type. Current request schema. The default identifier is "http". It can be "http", "http.request", "websocket".

**method**

    Type of string. Current request HTTP method. Could be None in case of websocket request.

**path**

    Type of string. The path current request came from.

**post**

    Dict type. Serialized data sent with an HTTP POST or PATCH request.
    It doesn't matter what request he could
    be "application / x-www-form-urlencoded", "text / plain", "application / json" or whatever. You can always get
    accessing such request data via `request.post`

**files**

    Dict type. All files that you expect to receive with the "multipart/form-data" request will be stored in this
    argument. All keys are strings and all values ​​are `crax.UploadFile`.

    .. code-block:: python

        class SaveFiles(BaseView):
            methods = ['POST']

            async def post(self):
                # save all of files
                if self.request.files:
                    for file in self.request.files:
                        await self.request.files[file].save()
                return TextResponse(self.request, f'Saved {len(self.request.files)} files')

    All of the files will be saved asynchronously.

.. toctree::
   :maxdepth: 3
   :caption: Contents:


.. index::
   Request