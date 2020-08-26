Home Page
======================================================

.. image:: crax_images/logo.png
   :width: 100
   :target: https://crax.wiki/


What is CRAX?
======================================================

Crax is a collection of tools put together to make web development fast and easy.
It can also be called a framework because it is ready to create any web application or service out of the box.



Why CRAX?
======================================================

First, it's very easy to use. Anyone can start with Crax without good coding skills and deep knowledge.
However, even if you are not a Python guru, your web applications will be fast, responsible, and well documented.
Most of the parts included in Crax are very easy to use and understand.
If your application does not involve particularly complex logic, you can write it with a few lines of Python.
Also, batteries are included. You can work with multiple databases, create and apply migrations, create REST APIs and
Swagger documentation or work with templates. It is well documented and documentation
contains many examples and code snippets.

Please don't be inert. Let me know that you are really interested in Crax.
Create tasks, issues, forks, pull requests or just star it, do whatever you want me to
know that you are really involved in.

Thank words
======================================================

Thanks to all the open source developers and contributors. Thanks to all the Core Python developers. Thanks to the guys at
`The Pallets Projects <https://github.com/pallets/>`_. For all developers from
`Encode <https://github.com/encode/>`_. Thanks to all the developers on the `Django <https://github.com/django/>`_ project.
Thanks for the great work, lots of ideas, solutions, packages and code snippets. Crax is inspired by the
`Starlette <https://github.com/encode/starlette/>`_ framework that really shines. Many ideas and solutions are taken from
Starlette, and database support is based on the `Encode <https://github.com/encode/>`_ **databases**
package.

Installation
======================================================
The easiest way to install Crax is by typing in the console

.. code-block:: bash

    pip install crax

This will install the latest version of Crax without database support. There are only four hard  dependencies:

1. `aiofiles <https://github.com/Tinche/aiofiles/>`_
2. `jinja2 <https://jinja.palletsprojects.com/en/2.11.x/>`_
3. `python-multipart <https://andrew-d.github.io/python-multipart/>`_
4. `itsdangerous <https://itsdangerous.palletsprojects.com/en/1.1.x/>`_

If you are going to use database support in your application, perhaps you should install Crax with one of the
Database. Crax currently provides three database backends:

1. Sqlite
2. MySQL
3. PostgreSQL

To install your favorite server, just put its name in square brackets after Crax.

.. code-block:: bash

    pip install crax[sqlite]
    pip install crax[mysql]
    pip install crax[postgresql]

All required dependencies will be installed as well. The list of dependencies for each backend you can check at
**setup.py** file.
Also you will need any ASGI server to launch your application. It might be
`Uvicorn <https://www.uvicorn.org/>`_ (recommended) or `Hypercorn <https://pgjones.gitlab.io/hypercorn/>`_ or
whatever.

.. code-block:: bash

    pip install uvicorn

So you are done. Crax and ASGI server are installed and you are ready to create applications.

QuickStart
======================================================
:ref:`intro`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   intro

Configuration
======================================================
:ref:`settings`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   settings

Routing
======================================================
:ref:`routing`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   routing

Request
======================================================
:ref:`request`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   request

Responses
======================================================
:ref:`responses`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   responses

Authorization
======================================================
:ref:`authorization`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   authorization

Views
======================================================
:ref:`views`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   views

Templates and Static files
======================================================
:ref:`templates_static`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   templates_static

Databases
======================================================
:ref:`databases`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   databases

Middleware
======================================================
:ref:`middleware`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   middleware

REST
======================================================
:ref:`rest`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   rest

Swagger and OpenAPI
======================================================
:ref:`openapi`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   openapi

WebSockets
======================================================
:ref:`websocket`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   websocket

Built in Exceptions and Error handling
======================================================
:ref:`exceptions`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   exceptions

Logging
======================================================
:ref:`logging`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   logging

Testing
======================================================
:ref:`testing`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   testing

Deployment
======================================================
:ref:`deployment`.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

   deployment