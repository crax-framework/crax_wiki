.. _settings:

Configuration
-----------------------------------------------

As stated on the :ref:`intro`, the Crax application can be launched without any configuration.
Also web application can be created using Crax parts only.
However, if you are going to use the full power of Crax, it should be configured. All your config variables
listed below should be placed in your main application file. And main file should always contain an instance of
Crax named `app`.

.. code-block:: python

    app = Crax('first_app.app', debug=True)


Common settings
======================================================

**BASE_URL**
Variable that specifies the URL of the base project. It should be set if you want to use the Crax command line interface.

.. code-block:: python

    BASE_URL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

This the right way to define your base url.

**URL_PATTERNS**
A variable that defines all the URLs that Crax should manage.

.. code-block:: python

    from my_app import url_list

    URL_PATTERNS = url_list

**SECRET_KEY**
The variable is used to create sings. If you are going to use authorization backends, this must be defined.
It can be any string you want

.. code-block:: python

    SECRET_KEY = "My Super Secret Key"

**APPLICATIONS**
Variable that tells Crax about installed applications. It is list of strings, not imported modules.

.. code-block:: python

    APPLICATIONS = ["my_app_one", "my_app_two", "my_app_three"]


**STATIC_DIRS**
Variable that shows Crax where to find static files. List of strings.

.. code-block:: python

    STATIC_DIRS = ["static", "my_app/static"]

**TEMPLATE_FUNCTIONS**
Variable to set custom functions that you want to use in templates. List of functions.

.. code-block:: python

    def square_(a):
        return a * a


    def hello():
        return "Hello world"

    TEMPLATE_FUNCTIONS = [square_, hello]

Please note that the example below is incorrect and will not work.

.. code-block:: python

    def square_(a):
        return a * a


    def hello():
        return "Hello world"
    # This is wrong
    TEMPLATE_FUNCTIONS = [square_(), hello()]

**ENABLE_CSRF**
A variable that tells Crax that all `POST`, `PATCH` and `PUT` requests must contain the Csrf token. Bool type.
The default is False, so Crax does not check if the request contains a `Csrf Token`. To change this behavior
set this variable to True. If you want to partially protect your views, you can globally enable CSRF protection.
but disable for the exact handler using the `enable_csrf` handler option, which defaults to True. So if you will
set to False, this exact handler will handle all requests. `Csrf Token` is a TimeStampSigned token, so you
you can change its ttl using the ** CSRF_EXPIRES ** settings variable which is 1209600 by default.

**ERROR_HANDLERS** Variable defining custom error handlers. The dict type of the callee. In production mode, your
the application must not be in `debug mode`.

.. code-block:: python

    # Debug mode off
    app = Crax(settings='my_app.conf')

    # Debug mode on
    app = Crax(settings='my_app.conf', debug=True)

So you might want to manage your errors. **ERROR_HANDLERS** is for this purpose. You can define a dict with
error handlers for each expected error status code. Rule: the keys of this dict should be written as
`ERROR_STATUS_CODE_handler`. The values ​​for this dict can be of any kind that support ASGI signature. For example:

.. code-block:: python

    ERROR_HANDLERS = {"500_handler": Handler500, "404_handler": Handler404, "403_handler": Handler403}

If your application has an error with the status defined in the dict `ERROR_HANDLERS`, the handler of which is a value,
will process the request. In case your application got an error with a status code that is not defined in
`ERROR_HANDLERS`, the request will be handled with the handler for error `500`.
If neither a `500` error handler nor a current error handler is defined, the application will show the default error
page ("Internal Server Error" or any other default text).

Database
======================================================

**DATABASES**
A variable describing all the databases in the project. Structure of key, value pairs, where key is a string and value is a dict.
The key specifies the name of the database, and the value describes how Crax works with that database.
For example.

.. code-block:: python

    BASE_URL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    DATABASES = {
        "default": {
            "driver": "sqlite",
            "name": f"/{BASE_URL}/app.sqlite",
        }
    }

`Available keys`:
    **driver**
        String that defines database driver. Could be `mysql`, `postgresql` or `sqlite`

    **host**
        String that defines database host.

        .. code-block:: python

            def get_db_host():
                docker_db_host = os.environ.get("DOCKER_DATABASE_HOST")
                if docker_db_host:
                    host = docker_db_host
                else:
                    host = "127.0.0.1"
                return host

            DATABASES = {
                "default": {
                    "driver": "mysql",
                    "host": get_db_host()
                }
            }

    **user**
        String that defines database user.

    **password**
       String that defines database password.

    **name**
        String that sets database password.

    **options**
        Dict that sets database connection options

        .. code-block:: python

            DATABASES = {
                "default": {
                    "driver": "postgresql",
                    "host": "127.0.0.1",
                    "user": "crax",
                    "password": "CraxPassword",
                    "name": "crax_database",
                    "options": {"min_size": 5, "max_size": 20},
                }
            }

For example we want to define two databases thus we should write something like this.

.. code-block:: python

    DATABASES = {
        "default": {
            "driver": "postgresql",
            "host": "127.0.0.1",
            "user": "crax",
            "password": "CraxPassword",
            "name": "crax_database",
            "options": {"min_size": 5, "max_size": 20},
            },
        "custom": {
            "driver": "mysql",
            "host": "127.0.0.1",
            "user": "crax",
            "password": "CraxPassword",
            "name": "crax_database",
            "options": {"min_size": 5, "max_size": 20},
            },
    }

Note that `DATABASES` variable should always contains `default` key. Otherwise `CraxDataBaseImproperlyConfigured`
exception will be raised.


Middleware
======================================================

**MIDDLEWARE** List of dot separated strings. Defines middleware you want to use in your project.

.. code-block:: python

    MIDDLEWARE = [
        "crax.auth.middleware.AuthMiddleware",
        "crax.auth.middleware.SessionMiddleware",
    ]

You can write your own middleware and include it in this list. Or you can use any of Crax's preinstalled middleware.
See section :ref:`middleware` for details.
Crax middleware that you can customize in the config file:

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

**CorsHeadersMiddleware**
    Should be defined in middleware list as `crax.middleware.cors.CorsHeadersMiddleware`. Enables CORS Headers support.

    Can be customized with settings variables:

        **CORS_OPTIONS**:
            Type of dict. Describes CORS Politics of your project. Example:

            .. code-block:: python

                CORS_OPTIONS = {
                    "origins": ["*"],
                    "methods": ["*"],
                }

        Please see full description at :ref:`middleware` section.

Logging
======================================================
Crax logging is disabled by default. This means that no action, even errors, will be logged.
To change this behavior, you must set the settings variable to True.
** DISABLE_LOGS ** The bool type. Enables logging.
After you have enabled the logging backend, you might want to customize it.

**LOG_FORMAT** Variable that sets log formatting in your project log file. Default value is
`"%(asctime)s — %(name)s — %(levelname)s — %(message)s"`

**LOGGER_NAME** Sets logger name for `logging.getLogger(name)` function. See details at
`Logging facility for Python <https://docs.python.org/3/library/logging.html/>`_. Default name is "crax".

**LOG_LEVEL** Sets logger warn level. Type of string. Default value is "INFO".

**LOG_CONSOLE** Sets should logger or not stream to console. Type of bool. Default is False.

**LOG_STREAMS** Set what streams logger should to use. Type of list. Default value is [sys.stdout, sys.stderr]

**LOG_ROTATE_TIME** Defines log rotation time. Type of string. Default value is "midnight".

**LOGGING_BACKEND** Defines a custom server-side logging module. If for some reason you do not want to use
Crax default logging backend, you can write your own. When finished, tell Crax about it.
The type of dot-delimited string. The default is crax.logger.CraxLogger.


.. code-block:: python

    # Actually you don't need import anything. It is just example shows the rule of definition
    from my_shiny_logger import SuperLogger

    LOGGING_BACKEND = "my_shiny_logger.SuperLogger"

**ENABLE_SENTRY** Includes Sentry support. Crax Logging can work with Sentry out of the box, but
it is generally disabled as logging. If you want to enable it, set this variable to True.
Note that if you set Sentry support to "ON", you must define your Sentry credentials.

**LOG_SENTRY_DSN** Set your sentry credentials. No defaults.
Example:

.. code-block:: python

    LOG_SENTRY_DSN = "https://bec19d6d8764916d99de6038505e18b2@o411613.ingest.sentry.io/5287096"

Once you provided your Sentry credentials your Sentry is ready to go.
Let's customize it.
**SENTRY_LOG_LEVEL** Set Sentry's log level. Default value is equal to **LOG_LEVEL** variable thus if you
don't want set different warn levels to server and Sentry, just skip it.

**SENTRY_EVENT_LEVEL** variable that sets Sentry's event level. Type of string. Default value is "ERROR".

Swagger
======================================================
Crax can create online Swagger documentation (OpenAPI 3.0. *) right out of the box. You can use the Crax command line tool and
create documentation with one command. To start with Swagger you must define
**SWAGGER** variable describing basics. The SwaggerInfo type, which is described using the Python dataclass.
Here's a simple example of defining SwaggerInfo. All information about creating interactive documentation
you can see it at :ref:`openapi`.

.. code-block:: python

    SWAGGER = SwaggerInfo(
        description="This is a simple example of OpenAPI (Swagger) documentation. "
        " You can find out more about Swagger at "
        "[http://swagger.io](http://swagger.io) or on "
        "[irc.freenode.net, #swagger](http://swagger.io/irc/).  ",
        version="0.0.3",
        title="Crax Swagger Example",
        termsOfService="https://github.com/ephmann/crax",
        contact={"email": "crax.info@gmail.com"},
        license={"name": "MIT", "url": "https://opensource.org/licenses/MIT"},
        servers=[
            {"url": "http://127.0.0.1:8000", "description": "Development server http"},
            {"url": "https://127.0.0.1:8000", "description": "Staging server"},
        ],
        basePath="/api",
    )

.. toctree::
   :maxdepth: 3
   :caption: Contents:

.. index::
   Configuration