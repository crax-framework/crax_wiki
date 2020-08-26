.. _rest:

REST API
-----------------------------------------------
Building APIs with Crax is very fast and easy. Assuming that somewhere we have described models named
"Customer" and "Order". See :ref:`databases` section for details. So let's create a simple API for these instances.

We are going to create some handlers.

.. code-block:: python

    import json

    from crax.response_types import JSONResponse
    from crax.views import BaseView
    from sqlalchemy import select

    from test_api.models import Customer, Order


    class Customers(BaseView):

        methods = ["GET", "POST"]

        async def get(self):
            self.context = await Customer.query.all()
            response = JSONResponse(self.request, self.context)
            return response

        async def post(self):
            data = json.loads(self.request.post)
            await Customer.query.bulk_insert(values=data)
            self.context = {"success": "Created"}
            response = JSONResponse(self.request, self.context)
            return response


    class CustomerDetails(BaseView):

        methods = ["GET", "PATCH", "DELETE"]

        async def get(self):
            query = select([Customer.c.id]).where(
                Customer.c.id == int(self.request.params["customer_id"])
            )
            self.context = await Customer.query.fetch_one(query=query)
            response = JSONResponse(self.request, self.context)
            return response

        async def patch(self):
            data = json.loads(self.request.post)
            Customer.query.execute(Customer.table.update().where(
                Customer.c.id == self.request.params["customer_id"]).values(data)
            )
            response = JSONResponse(self.request, self.context)
            return response

        async def delete(self):
            await Customer.query.execute(
                query=Customer.table.delete().where(
                    Customer.c.id == int(self.request.params["customer_id"])
                )
            )
            response = JSONResponse(self.request, self.context)
            return response


    class Orders(BaseView):
        methods = ["GET", "POST"]

        async def get(self):
            self.context = await Order.query.all()
            response = JSONResponse(self.request, self.context)
            return response

        async def post(self):
            data = json.loads(self.request.post)
            await Order.query.insert(values=data)
            response = JSONResponse(self.request, {"success": "Created"})
            return response


    class OrderDetails(BaseView):
        methods = ["GET", "DELETE"]

        async def get(self):
            self.context = await Order.query.fetch_one(
                query=Order.table.select().where(Order.c.id == int(self.request.params["order_id"]))
            )
            response = JSONResponse(self.request, self.context)
            return response

        async def delete(self):
            query = Order.table.delete().where(Order.c.id == int(self.request.params["order_id"]))
            self.context = await Order.query.execute(query=query)
            response = JSONResponse(self.request, self.context)
            return response


As you can see, there is nothing to serialize. Why is that? Just because each database query only returns one of the two
types. It can be a dictionary or a list of dictionaries. So in most cases your data is already serialized and
can be sent via JSON response. Of course, these can be more complex cases that you have to deal with individually.

Ok, it's time to create the endpoints.

.. code-block:: python

    from crax.urls import Route, Url

    url_list = [
        Route(urls=(Url("/api/customers")), handler=Customers),
        Route(Url("/api/customer/<customer_id>"), handler=CustomerDetails),

        Route(Url("/api/orders"), handler=Orders),
        Route(Url("/api/order/<order_id>"), handler=OrderDetails)
    ]

And it's all. Your API is ready to accept requests and send responses.

But we may want to create an API and also we may want to create a SPA that renders some pages through the JS framework.
In this case, it is assumed that all routing will be done on the frontend side. So we're going to create a simple handler
which will serve as a uniform template for all routes.

.. code-block:: python

    from crax.views import TemplateView

    class APIView(TemplateView):
        # This code is enough
        template = "index.html"

And routes.

.. code-block:: python

    from crax.urls import Route, Url

    Route(
        urls=(
            Url("/"),
            Url("/v1/customers"),
            Url("/v1/orders"),
            Url("/v1/customer/<customer_id>"),
            Url("/v1/order/<order_id>/"),
        ),
        handler=APIView,
    )

After these simple steps, we have endpoints to handle requests and everything to create a SPA application using
JS framework.

Crax currently does not have JWT, OAuth2 or other token based authorization, but is coming soon. Or you can
do it yourself (don't forget to create a pull request ;)).

So, once we've created our API, we might want to create interactive documentation. Follow the link :ref:`openapi` to
Continue.

.. toctree::
   :maxdepth: 3
   :caption: Contents:


.. index::
   REST