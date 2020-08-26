.. _deployment:

Deployment
-----------------------------------------------

Deploying Crax is similar to deploying any other ASGI application. If you have worked with any
other ASGI framework you won't see anything new in this chapter. Let's take a simple example
deploying Crax behind NGINX WebServer.

Take a look at the  `Uvicorn Deployment <https://www.uvicorn.org/deployment/#running-behind-nginx>`_
section. We're going to do the same.
Write your nginx config file.

.. code-block:: bash

    vi /etc/nginx/sites-available/crax

.. code-block:: nginx

    http {
        server {
            listen 80;
            client_max_body_size 4G;

            server_name example.com;

            location / {
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_redirect off;
                proxy_buffering off;
                proxy_pass http://uvicorn;
            }

            location /static {
                # path for static files
                root /path/to/app/static;
            }
        }

        upstream uvicorn {
            server unix:/tmp/uvicorn.sock;
        }
    }

Link your config to the enabled NGINX sites

.. code-block:: bash

    cd /etc/nginx/sites-enabled/
    ln -s ../sites-available/crax .
    systemctl restart nginx

Install `Gunicorn <https://gunicorn.org/>`_ in your virtual environment.

.. code-block:: bash

    pip install gunicorn

Write `systemd` service.

.. code-block:: bash

    vi /usr/lib/systemd/system/crax.service

.. code-block:: ini

    [Unit]
    Description=Crax launcher
    After=network.target

    [Service]
    User=crax
    Group=crax
    WorkingDirectory=/path/to/app
    ExecStart=/path/to/gunicorn -w 4 -k uvicorn.workers.UvicornWorker app:app
    Restart=always

    [Install]
    WantedBy=multi-user.target

.. code-block:: bash

    systemctl enable crax
    systemctl start crax

Of course, instead of `systemd`, you can use your favorite process manager. It is perfectly
described in the documentation for  `Uvicorn <https://www.uvicorn.org/deployment/>`_ .

.. toctree::
   :maxdepth: 3
   :caption: Contents:


.. index::
   Deployment