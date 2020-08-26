import os
from crax import Crax
from crax.urls import Url, Route
from crax.views import TemplateView


class Home(TemplateView):
    template = 'home.html'


class Docs(TemplateView):
    template = 'index.html'
    scope = os.listdir('crax_docs/templates')


class NotFoundHandler(TemplateView):
    template = '404.html'

    async def get(self):
        self.status_code = 404


class ServerErrorHandler(TemplateView):
    template = '500.html'


BASE_URL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

URL_PATTERNS = [
    Route(Url('/'), Home),
    Route(urls=(
        Url('/documentation', masquerade=True),
        Url('/documentation/_sources/', masquerade=True)),
        handler=Docs),
]
DISABLE_LOGS = False
ERROR_HANDLERS = {'404_handler': NotFoundHandler, '500_handler': ServerErrorHandler}
APPLICATIONS = ['crax_docs']

app = Crax(settings="crax_docs.app")
