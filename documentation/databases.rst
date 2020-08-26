.. _databases:

Databases
-------------------------------------
Crax databases are nothing new, they are a very thin wrapper around
`SQLAlchemy Core <https://docs.sqlalchemy.org/en/13/core/index.html>`_ and
`Encode databases <https://www.encode.io/databases/>`_. So if you you know this
then you know Crax databases. So what's the profit? However, if the Crax database
Support is similar to the two things it provides you with comfort and
a clear way to define your models and execute queries. Also does not fit Crax models
somewhere aside, but it's part of the structure. Models, queries, migrations and
other elements of the database are naturally included in your project. When you define
your models, you are sure that Crax knows everything about him and works with your
models as part of the entire project.

Installation
======================================================
Crax database support is disabled by default. So if you don't want to use the default
Crax database models and connections, you can write your own and not use the built-in ones.
Also, unless you said otherwise, Crax will be installed with no database dependencies.
To install Crax with database support, you must install the extras.
All dependencies will be installed as well.

.. code-block:: bash

    pip install crax[sqlite]
    pip install crax[mysql]
    pip install crax[postgresql]

The next step is to tell Crax that he needs to work with databases. In your project config
the file should fill the variable **DATABASES**.

**DATABASES**
A variable describing all the databases in the project. Structure of key, value pairs, where key is a string and value is a dict.
The key specifies the name of the database, and the value describes how Crax works with that database.
For example.

.. code-block:: python

    # Note that absolute and relative paths must be defined differently.
    # f"/{BASE_URL}/app.sqlite" and f"//{BASE_URL}/app.sqlite" are not the same

    # Relative path is the path after the three initial slashes
    # create_engine('sqlite:///relative/path/relative_path_database.db')

    # Absolute path is a slash after the three initial slashes
    # create_engine('sqlite:////tmp/absolute_path_database.db')


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

Also if you are going to use Crax command line tools e.g `create_db`, `migrate` and others you must define `BASE_URL`
variable in your project configuration.

.. code-block:: python

    BASE_URL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

After all these steps, you are ready to create your models.

Models
======================================================
Every Crax model inherits from BaseTable. So first you must import it from `crax.database` and then you can create
your models.

.. code-block:: python

    from crax.database.model import BaseTable

Each Crax model has two parts. The first part is the `Table`. Or `MyModel.table` which is the instance of
`Table <https://docs.sqlalchemy.org/en/13/core/metadata.html?highlight=metadata#sqlalchemy.schema.Table>`_.

**Table**:

    .. code-block:: python

        from crax.database.model import BaseTable
        import sqlalchemy as sa

        class MyModel(BaseTable):
            name = sa.Column(sa.String(length=50), nullable=False)

        MyModel.table

    Behind the scenes, each table in the Crax model is nothing more than an instance of an SQLAlchemy table.
    So, whatever you can do with SQLAlchemy Table, you can do with `MyModel.table`.

    .. code-block:: python

        from crax.database.model import BaseTable
        import sqlalchemy as sa


        class MyModel(BaseTable):
            name = sa.Column(sa.String(length=50), nullable=False)

        query = MyModel.table.select().compile()
        query_ = MyModel.table.select()
        _query = sa.select([MyModel.table])

    So `query`, `query_` and `_query` are valid sql expressions like that

    .. code-block:: sql

        SELECT my_model.name, my_model.id
        FROM my_model

    Also `MyModel.table` can be used as a valid part of any SQLAlchemy Core expressions. All about expressions in
    `SA SQL Expressions <https://docs.sqlalchemy.org/en/13/core/index.html>`_.

**Metadata**:
    The next important thing is the `Metadata`. Metadata is nothing more than
    `Metadata <https://docs.sqlalchemy.org/en/13/core/metadata.html?highlight=metadata#sqlalchemy.schema.MetaData>`_.
    So, sure each Crax model has it's Metadata object. As mentioned above, all of the attributes and methods of the
    SA Table can be accessed by accessing its table argument. But the metadata object can be accessed directly.

    Let's get the names of all the fields in our model:

    .. code-block:: python

        from crax.database.model import BaseTable
        import sqlalchemy as sa


        class MyModel(BaseTable):
            name = sa.Column(sa.String(length=50), nullable=False)

        print([y.name for x in MyModel.table.metadata.sorted_tables for y in x._columns])
        print([y.name for x in MyModel.metadata.sorted_tables for y in x._columns])

        # We will get the same output like ['name', 'id']

As you can see, we have not defined a field named `id`, but it is in the column list. This is the default behavior
for any Crax model. You don't have to define the id and Primary Key fields. Each Crax model has a field named `id` which
autoincrement primary key.

.. code-block:: python

    from crax.database.model import BaseTable
        import sqlalchemy as sa


        class FistModel(BaseTable):
            name = sa.Column(sa.String(length=50), nullable=False)


        class SecondModel(BaseTable):
            name = sa.Column(sa.String(length=50), nullable=False)
            first_model_id = sa.Column(sa.Integer, sa.ForeignKey(FistModel.id))

The example above will work fine.

If you don't want to have a predefined primary key named `id` and want to create your own primary key, you should
define the **Meta** argument in your model, which is a Python class.

**Meta**:

    .. code-block:: python

        from crax.database.model import BaseTable
        import sqlalchemy as sa


        class FistModel(BaseTable):
            pk = sa.Column("pk", sa.Integer, primary_key=True)
            name = sa.Column(sa.String(length=50), nullable=False)

            class Meta:
                primary = False


        class SecondModel(BaseTable):
            name = sa.Column(sa.String(length=50), nullable=False)
            first_model_pk = sa.Column(sa.Integer, sa.ForeignKey(FistModel.pk))


        query = SecondModel.table.select().compile()
        print(query) # See below the output

    We turned off the default primary key creation and defined our own.

    .. code-block:: sql

        SELECT second_model.name, second_model.first_model_pk, second_model.id
        FROM second_model

    So, what is `Meta` for. First, it is for passing additional parameters that you want to pass to the
    `Table <https://docs.sqlalchemy.org/en/13/core/metadata.html?highlight=metadata#sqlalchemy.schema.Table>`_.
    `sqlalchemy.schema.Table(*args, **kw)` so the `**kw` is for your `Meta` parameters.
    All arguments (except `abstract`, `order_by` and `primary`) that you pass to the `Meta` will be passed to SA Table.
    Some words about the `abstract` argument.

    Ok. We are going to create two parent models and one child. And we want to create during `migrate` command in our
    database just two of three models.

    .. code-block:: python

        from crax.database.model import BaseTable
        import sqlalchemy as sa


        class BaseModelOne(BaseTable):
            # This model just passes it's fields to the child
            # Will not be created in database because the abstract is defined

            parent_one = sa.Column(sa.String(length=50), nullable=False)

            class Meta:
                abstract = True


        class BaseModelTwo(BaseTable):
            # Also passes it's fields to the child
            # Will be created in database

            parent_two = sa.Column(sa.String(length=50), nullable=False)


        class MyModel(BaseModelOne, BaseModelTwo):
            name = sa.Column(sa.String(length=50), nullable=False)


        print([y.name for x in MyModel.metadata.sorted_tables for y in x._columns])
        # Let's check our fields ['name', 'id', 'parent_one', 'parent_two']

    The `order_by` parameter tells the model to sort the results by the specified field. By default, the results will be
    sort by `id` values. If you want to change it, define the `Meta`` order_by` parameter.

**Table.c expressions**:
    Of course, in addition to working with the entire table, we definitely want to work with columns. So we should use
    `Table.c` expressions. If you want to get access to any column of your Table, you should do something like this:
    We might narrow down your query results to two fields instead of all:

    .. code-block:: python

        from crax.database.model import BaseTable
        import sqlalchemy as sa


        class FistModel(BaseTable):
            pk = sa.Column("pk", sa.Integer, primary_key=True)
            name = sa.Column(sa.String(length=50), nullable=False)

            class Meta:
                primary = False


        class SecondModel(BaseTable):
            desc = sa.Column(sa.String(length=50), nullable=False)
            first_model_pk = sa.Column(sa.Integer, sa.ForeignKey(FistModel.pk))


        query = sa.select([FistModel.c.name, SecondModel.c.desc]).where(FistModel.c.pk >= 100)
        print(query)  # See below the output

    .. code-block:: sql

        SELECT fist_model.name, second_model."desc"
        FROM fist_model, second_model
        WHERE fist_model.pk >= :pk_1

    So if you've worked with SQLAlchemy before, you won't see anything new here. Just one thing: for your pleasure,
    expressions `MyModel.table.c.my_field` was truncated to `My Model.c.my_field`.

**Table name**:
    By default, you can choose not to define the table name. Crax converts your model name when creating database tables.
    to the snake case and will create the database table. If you want to change the table name, you must define
    parameter `table_name`.

    .. code-block:: python

        from crax.database.model import BaseTable
        import sqlalchemy as sa


        class FistModel(BaseTable):
            table_name = "custom_table"
            name = sa.Column(sa.String(length=50), nullable=False)


**Table database**:
    By default all Crax models are bound to the `default` database of your `DATABASES` settings variable.
    If you have more than one database and want to bind the current model to another database,
    you must define a database parameter.

    .. code-block:: python

        from crax.database.model import BaseTable
        import sqlalchemy as sa


        class CustomUser(BaseTable):
            table_name = "custom_users"
            database = "users"

            username = sa.Column(sa.String(length=50), nullable=False)

Queries
======================================================
The second important part of every Crax model is Query. Once you create your models you will want to do
database queries. While the `Table` part of Crax models is for SQLAlchemy, the second part is for Encode databases.
Please see documentation `Encode databases <https://www.encode.io/databases/>`_ it is simple and clear.
Let's take examples from `Creating Crax more complex`.

.. code-block:: python

   import asyncio
    import os

    from crax.auth.models import User
    from crax.database.model import BaseTable
    import sqlalchemy as sa

    from third_app.models import Company


    class UserProfile(BaseTable):
        bio = sa.Column(sa.String(length=100), nullable=False)
        age = sa.Column(sa.Integer(), nullable=True)

        class Meta:
            abstract = True


    class Customer(User, UserProfile):
        pass


    class Vendor(User, UserProfile):
        company_id = sa.Column(sa.Integer, sa.ForeignKey(Company.id))

We want to get all `Vendor` rows from the database. So we do:

.. code-block:: python

    async def get():
        # Somewhere in your handler
        ret = await Vendor.query.all()

    # This way you get "ret" as a list of dicts with all vendors.

This is how the `Query` part of the Crax model works. If you want to make queries, you call `MyModel.query`.
Note, that all queries will be processed against the database that defined as model database. If database not
defined queries will be processed against `default` database.

Available methods:

    **all()**:
        Takes no parameters.
        Returns a list of dictionaries in which each dict is a pair of keys and values, for example {"field_name": "field_value"}

    **first()**:
        Takes no parameters. Returns dictionary with the first found row according to the given `order_by` `Meta`
        parameter. If `order_by` is not specified, the first row according to the model ID will be returned.

    **last()**:
        Takes no parameters. Returns dictionary with the last row according to the given `order_by` `Meta`
        parameter. If `order_by` is not specified, the last row according to the model ID will be returned.

    **insert(values)**
        Takes known word argument `values` as the parameter. The `values` argument should be a dict with the valid
        data that you want to insert. Inserts single object to database.

        .. code-block:: python

            values = {"username": "crax", "password": "qwerty", "first_name": "Crax"}
            await Vendor.query.insert(values=values)

    **bulk_insert(values)**
        Takes known word argument `values` as the parameter. The `values` argument should be a list of dicts with the valid
        data that you want to insert. Inserts several objects at once into the database.

        .. code-block:: python

            values = [
                {"username": "bob", "password": "qwerty", "first_name": "Bob"},
                {"username": "alice", "password": "qwerty", "first_name": "Alice"}
            ]
            await Vendor.query.bulk_insert(values=values)
    **fetch_one(query, values)**
         Takes required known word argument `query` as the parameter. Where `query` is any valid
         `ClauseElement <https://docs.sqlalchemy.org/en/13/core/sqlelement.html#sqlalchemy.sql.expression.ClauseElement>`_.
         It might be a `Raw SQL expression` or an expression that is built using Crax `Model.table`.
         Returns dict.

        .. code-block:: python

            # Here we skipped argument values
            query = Vendor.table.select().where(
                    sa.or_(Vendor.c.username == 'bob', Vendor.c.username == 'alice')
                        )
            ret = await Vendor.query.fetch_one(query=query)

        Let's create simple query:

        .. code-block:: sql

            query = SELECT vendor.company_id, vendor.id, vendor.username "
             "FROM vendor WHERE vendor.username = :username AND vendor.bio LIKE '%Developer%'

        .. code-block:: python

            # Here we pass values for our raw query
            query = ("SELECT vendor.company_id, vendor.id, vendor.username "
             "FROM vendor WHERE vendor.username = :username AND vendor.bio LIKE '%Developer%'")
            ret = await Vendor.query.fetch_one(query=query, values={'username': 'bob'})

    **fetch_all(query, values)**:
        The same with `fetch_one`, but it returns all rows that match the query. Returns list of dicts.

        .. code-block:: python

            # Here we skipped argument values
            query = Vendor.table.select().where(
                    sa.or_(Vendor.c.username == 'bob', Vendor.c.username == 'alice')
                        )
            ret = await Vendor.query.fetch_all(query=query)

        Let's create simple query:

        .. code-block:: sql

            query = SELECT vendor.company_id, vendor.id, vendor.username "
             "FROM vendor WHERE vendor.username = :username AND vendor.bio LIKE '%Developer%'

        .. code-block:: python

            # Here we pass values for our raw query
            query = ("SELECT vendor.company_id, vendor.id, vendor.username "
             "FROM vendor WHERE vendor.username = :username AND vendor.bio LIKE '%Developer%'")
            ret = await Vendor.query.fetch_all(query=query, values={'username': 'bob'})

    **execute(query, values)**:
        Takes the same arguments as `fetch_one` and `fetch_all`. Returns None.

        .. code-block:: python

            query = Vendor.table.update().where(Vendor.c.id == 7).values({"first_name": "Bobby"})
            raw_query = "UPDATE vendor SET first_name=:first_name WHERE vendor.id = :id"
            await Vendor.query.execute(query=query)
            await Vendor.query.execute(query=raw_query, values={"first_name": "Bobbie", "id": 7})

Migrations
======================================================
Crax Database Migration is nothing more than a tool that is written according to
`SQLAlchemy Alembic <https://alembic.sqlalchemy.org/en/latest/>`_ documentation. So, if you are familiar with Alembic
you won't get anything new here. Ok. How to create migrations for your models and databases. First of all enable
command line interface in your project main file (the file that launches your application). Let it be `run.py`

.. code-block:: python

    import sys

    from crax import Crax

    # import this function
    from crax.commands import from_shell


    app = Crax(settings="my_app.conf", debug=True)

    # This code enables command line interface
    if __name__ == "__main__":
        if sys.argv:
            from_shell(sys.argv, app.settings)

You are now ready to work with the Crax commands.
Since you've created models, you'll want to create migrations and apply changes to your database (or multiple databases).
So, let's talk about the rules. There are some rules of creation your migrations.

First rule is:
    Your migrations will not be generated if you did not define any apps in you configuration file.

    .. code-block:: python

        # my_app/conf.py

        APPLICATIONS = ['app_one', 'app_two']

    Why so? Just because all migrations are bound to applications. This means that every application in your project is
    a branch of Alembic migrations. See `Alembic branches <https://alembic.sqlalchemy.org/en/latest/branches.html>`_
    for details.

    Also, all migration directories will be created inside your application packages. All migration directories are separate.
    If you created applications and defined files named `models.py` inside each application, then
    described the database logic of the current application, all migrations will be placed in this application in
    a directory named `migrations`.
    If Crax couldn't find any apps, there won't be migrations.

Second rule is:
    If you created your database models in a file that is not called `models.py`. You can take any name for most
    files in your project, even you can create your models in a file named `any.py` and everything will work fine except
    migration systems.

Third rule is:
    You are about to create migrations for a database similar to your models. What does this mean.
    If your database is up to date, no migrations will be generated. Even if you don't have migrations at all. For example,
    you have a database with an existing schema similar to the existing models described in your applications.
    This is your first time trying to create migrations. Expected Result: No migrations were generated.

Otherwise your migrations will be created. Just type in console:

.. code-block:: bash

    python run.py makemigrations

Where `run.py` is the main file of your project.
This command takes command line arguments that allow you to customize migrations generation.

**-\-database, -d**

    .. code-block:: bash

        python run.py makemigrations -d users

    If you have more than one database in your project you will want to create migrations for all of them.
    Specify which database you want create migrations for. If not specified, all migrations will be generated.
    against the database `default`. If you have defined table_name parameter for any of your models and run this
    without the --database flag, migrations for a non-default database will not be generated.

**-\-apps, -a**

    .. code-block:: bash

        python run.py makemigrations -a first_app

    If you want to create migrations only for a specific application, specify this with the `-a` flag.

**-\-message, -m**

    .. code-block:: bash

        python run.py makemigrations -m initial

    If you want to set a message for the current revision and also mark the migration files with some special name, specify this with the -m flag.

If you have more than one database in your project and you run the makemigrations command, all migrations will be
divided within the `migrations` directories according to its databases. For example, if you have two databases
with the names `default` and` users`, so directories named `default` and` users` will be created inside the `migrations` directory.

Since you've created migrations, you will want to create tables in your database. Therefore, you should run the `migrate` command.

.. code-block:: bash

    python run.py migrate

All recent migrations will be applied. Thus this is the way you can create your database. Run

.. code-block:: bash

    python run.py makemigrations
    python run.py migrate

You did it. Now all your models are in the database.
This command takes command line arguments that allow you to change it's behaviour.

**-\-database, -d**

    .. code-block:: bash

        python run.py migrate -d users

    Apply migrations just against the specific database.

**-\-apps, -a**

    .. code-block:: bash

        python run.py migrate -a first_app

    Apply migrations just against the specific application.

**-\-down, -n**

    .. code-block:: bash

        python run.py migrate --down

    Revoke recent migrations

**-\-revision, -r**

    .. code-block:: bash

        python run.py migrate -r 126683c84e3c
        python run.py migrate -r default/first_app@head

    Apply migrations only for the specified revision number. Note that all branches are labeled like this:
    `database_name/app_name`. Therefore if you want to work with your revisions via branch labels it should
    be written as in the example above.

    Also flags can be combined.

    .. code-block:: bash

        python run.py migrate -a first_app --down

    Here we tell Crax that we want to revert just recent migrations of an app named `first_app`. Please do it
    caution. In case some models in your application depend on models in another application, you
    will receive an error message. Crax takes care of the dependencies by running all applications at the same time.
    When doing it manually, you have to take care of it yourself.

**-\-sql, -s**

    .. code-block:: bash

        python run.py migrate --sql

    Offline mode. Sometimes you are not going to apply migrations due to doubts or your company's policy.
    You might want to create sql files, check these files (give files your DBA guy) and then apply through your
    favorite database tool. Therefore offline migrations will not apply (no tables will be created),
    but in each `migrations` directory, a directory named `sql` will be created.
    Also will be created files with the SQL code of your migrations  in this directory.
    The files will be named according to their revision number. In case you have more than one database in your
    project, all sql directories will be placed according to the database directory.

    .. code-block:: bash

        python run.py migrate --sql -d users -a first_app

    You can find your \*.sql files in `your_project/first_app/migrations/users/sql`

So now you've made a lot of changes, you have a long history of migrations, and you might want to check it out.

.. code-block:: bash

        python run.py history

If you leave no flags, it will show you the entire migration history. It's not all that useful, is it?
But you can do more useful things.

**-\-latest, -l**
    Gives you all latest migrations (heads).

    .. code-block:: bash

        python run.py history -l

**-\-apps, -a**
    We want to get the latest version of the app named `first_app`.

    .. code-block:: bash

        python run.py history -l -a first_app



**-\-step, -s**

    .. code-block:: bash

        python run.py history first_app -s 2

    Number of steps down from current head. The number of steps down from the current head. We want to get the revision ID
    of the migration that was two steps down for the application named `first_name`.

    .. code-block:: bash

        python app.py history first_app -s 2 | grep  '-' | awk '{print $3}' | cut -d ',' -f1

    Clean revision number for your affords

However, running the `makemigrations` and` migrate` commands one after the other is not one only way to create your database.
Perhaps you don't want to deal with migrations and only want to quickly create your database.
(maybe for some tests) on your models.

.. code-block:: bash

    python run.py db_create_all

This is what you need. No alembic environment will be created. No migrations. Just will be created database tables.

To purge all the tables that described in your models from your database just run:

.. code-block:: bash

    python run.py db_drop_all

So now you can work with databases using Crax.

.. toctree::
   :maxdepth: 3
   :caption: Contents:

.. index::
   Databases
