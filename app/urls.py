from django.conf.urls import patterns, include, url
from django.views.generic.base import TemplateView

from .views import MapView


urlpatterns = patterns('app.views',
    # Examples:
    url(r'^error/', 'error', name='error'),
    url(r'^404/', '_404', name='404'),
    url(r'^$', TemplateView.as_view(template_name="us_states.html")),
    url(r'^maps/(?P<pk>\d+)/$',
        view=MapView.as_view(),
        name='map'),
    url(r'^create_customer/', 'create_customer', name='create_customer'),
)

from .signals import * #ensure that the signals are attatched via import
