.. _views:

Views
-----------------------------------------------
If you have read :ref:`intro` you already know the basics. Now let's talk about Crax views in more detail.

BaseView
======================================================

**BaseView** All Crax views are inherited from this view. Takes initial parameters:
    **request**:
        The first parameter of every Crax view must be `request`. It doesn't matter if your handler inherits from
        Crax views or you wrote your own opinion. The first parameter should always be a request that
        for an instance of `crax.Request`.

        .. code-block:: python

            # Custom coroutine based view
            async def custom_coroutine_view(request, scope, receive, send):
                response = TextResponse(request, "Hello world")
                await response(scope, receive, send)

            # Custom class based view
            class CustomView:
                def __init__(self, request):
                    self.request = request

                async def __call__(self, scope, receive, send):
                    response = TextResponse(self.request, "Hello world")
                    await response(scope, receive, send)

        This is the correct way to create your custom handlers that do not inherit from Crax views. Of course if you
        create your handlers that inherit from Crax views, you don't need to define a request.

        .. code-block:: python

            from crax.views import BaseView

            class CustomView(BaseView):
                async def get(self):
                    pass

    **context**:
        One of the ways to store data and pass it to `Response`.

        .. code-block:: python

            class CustomView(TemplateView):
                template = 'index.html'

                # We don't need to return anything, template will be rendered with request parameters
                # because we set the context
                async def get(self):
                    self.context = self.request.params

    **args**
        Any additional arguments.

    **kwargs**:
        Any additional arguments.

    `BaseView` and all child classes have attributes:
        **methods**:
            List type. The default is ["GET"]. By default, all handlers should only care about the "GET" method.
            If that's what you want, don't define anything. If you want to increase or change the default methods, set this
            attribute. Note that this attribute cannot be empty, or an exception will be raised.


            .. code-block:: python

                from crax.views import BaseView

                class CustomView(BaseView):
                    methods = ['GET', 'POST', 'PATCH']
                    async def get(self):
                        pass

            The note! If you are going to create your own coroutine based views, you will need to manage the available
            the methods themselves.

            .. code-block:: python

                class MyView(BaseView):
                    methods = ['GET', 'POST']
                    # For all methods except "GET" and "POST" will be returned 405 response
                    async def get(self):
                        pass


                class CustomView:
                    methods = ['GET', 'POST']
                    # For all methods except "GET" and "POST" will be returned 405 response

                    def __init__(self, request):
                        self.request = request


                async def my_custom_coroutine_view(request, scope, receive, send):
                    # All methods are supported
                    if request.method == "GET":
                        response = TextResponse(self.request, "Hello world")
                        await response(scope, receive, send)
                    elif request.method == "POST":
                        response = JSONResponse(self.request, {"error": "Method not allowed"}, status_code=405)
                        return response

        **login_required**:
            Bool type. The default is False. Change it to True to give access only to authorized users.

            .. code-block:: python

                from crax.views import TemplateView

                class LoginRequired(TemplateView):
                    login_required = True
                    methods = ["GET"]


                class AuthorizedViewOne(LoginRequired):
                    template = 'index.html'

                class AuthorizedViewTwo(LoginRequired):
                    template = 'cabinet.html'

        **staff_only**:
            Type of bool. Default value is False. If you want to grant access staff only persons, change it to True.

        **superuser_only**:
            Type of bool. Default value is False. If you want to grant access superuser only, change it to True.

    Why would you rather inherit your handlers from Crax views than write your own.
    Simply because Crax Views provides most of the methods out of the box.

    .. code-block:: python

        from crax.views import BaseView

        # Written your own stuff
        class CustomView:
            methods = ['GET', 'POST']
            def __init__(self, request):
                self.request = request

            async def __call__(self, scope, receive, send):
                if self.request.method == 'GET':
                    response = TextResponse(self.request, "Hello world")
                    await response(scope, receive, send)
                elif self.request.method == 'POST':
                    response = JSONResponse(self.request, {"Hello": "world"})
                    await response(scope, receive, send)

        # Crax based stuff
        class CustomView(BaseView):
            methods = ['GET', 'POST']

            async def get(self):
                response = TextResponse(self.request, "Hello world")
                return response

            async def post(self):
                response = JSONResponse(self.request, {"Hello": "world"})
                return response


        class CustomersList(TemplateView):
            template = 'second.html'

            # No need return anything in case if it is TemplateView.
            # Template will be rendered with params
            async def get(self):
                self.context['params'] = self.request.params

    `BaseView methods`. The first thing to consider is that all methods must be defined as coroutines.
    And all methods must return a `Response` object. See section :ref:`responses` for details

    **get()**:
        Define this method if you want to process HTTP "GET" requests.
        Default status code to return - 200

    **post()**:
        Define this method if you want to process HTTP "POST" requests.
        Default status code to return - 201

    **put()**:
        Define this method if you want to process HTTP "PUT" requests.
        Default status code to return - 204

    **patch()**:
        Define this method if you want to process HTTP "PATCH" requests.
        Default status code to return - 204

    **delete()**:
        Define this method if you want to process HTTP "DELETE" requests.
        Default status code to return - 204

    If you want to customize status code, just set status code you want to response.

    .. code-block:: python

        from crax.views import BaseView

        class CustomView(BaseView):
            methods = ['POST']
            async def post(self):
                response = JSONResponse(self.request, {"Hello": "world"})
                response.status_code = 200
                return response

JSONView
======================================================

**JSONView** View that returns `JSONResponse` out of the box for HTTP "GET" requests.

    .. code-block:: python

        from crax.views import JSONView

        class JsonEmptyTest(JSONView):
            methods = ["GET"]
            # This will return an empty dict


        class JsonTest(JSONView):
            methods = ["GET"]
            # No need to return anything. Just set some value to context attribute
            # And it will be returned as JSONResponse

            async def get(self):
                self.context = {'Hello': "World"}

    Of course, you can override the default behavior and return something else. JSONView takes the same parameters as
    `BaseView`. However, he has one special method.
    **create_context()**:

        Therefore, you should not return anything for HTTP "GET" requests. It will be called every time
        your handler receives a request of type "GET".

        .. code-block:: python

            from crax.views import JSONView


            class JsonTest(JSONView):
                methods = ["GET"]
                # We can do something with create_context() as usual

                async def create_context(self):
                    self.context = {'Hello': "World"}
                    return await super(JsonTest, self).create_context()

    And finally we want to create some other default methods.

    .. code-block:: python

        from crax.views import JSONView

        class JsonTest(JSONView):
            methods = ["POST"]

            # Note that all methods except of get() should always return instance of Response
            async def post(self):
                self.context = {'Hello': "World"}
                response = JSONResponse(self.request, self.context)
                return response


TemplateView
======================================================

**TemplateView** is the View for template rendering.
    The first thing you should think about using this view is defining the `template` attribute.

    .. code-block:: python

        from crax.views import TemplateView

        class Home(TemplateView):
            template = 'index.html'
            # You need nothing more. Now template "index.html" will be rendered

    The `TemplateView` takes the same parameters as the `BaseView`. However it has one special method.
    **render_response()**

        It will be called every time your handler receives a "GET" request. It is the same
        behavior with `JSONView`, but here we render templates instead of sending JSON.

    .. code-block:: python

        from crax.views import TemplateView

        class Home(TemplateView):
            methods = ["GET", "POST"]
            template = 'index.html'

            # No need to return anything - template will be rendered with context
            async def get(self):
                self.context = {'Hello': "World"}

            async def post(self):
                self.context = {'Hello': "World"}
                response = JSONResponse(self.request, self.context)
                return response

    How does Crax know where you store your templates? Good. You don't have to define template directories. But there is
    just one rule: all of your template directories should be named `templates`. Jinja FileSystemLoader will be
    try to find your templates in all app directories defined in project config. See: ref: `settings`
    section for details.
    You should be aware that all templates will render asynchronously as well. Crax uses Jinja2 templates - this is a template
    processor, so whatever you can do with Jinja, you can do with Crax.
    However, sometimes you need custom template functions. See :ref:`templates_static` for details.

SwaggerView
======================================================
**SwaggerView** Swagger View is just a kind of TemplateView displaying interactive documentation. He predestined
template, and its enable_csrf attribute is set to False.
