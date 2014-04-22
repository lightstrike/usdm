from django.db import models

from model_utils.models import TimeStampedModel
from django.contrib.auth import get_user_model

User = get_user_model()


class Map(TimeStampedModel):
    user = models.ForeignKey(User, related_name='maps', null=True)
    title = models.CharField(max_length=128)
    description = models.CharField(max_length=1024)

    def __unicode__(self):
        return self.title


class State(TimeStampedModel):
    name = models.CharField(max_length=128)
    abbreviation = models.CharField(max_length=8)

    def __unicode__(self):
        return self.name


class StateData(TimeStampedModel):
    state_map = models.ForeignKey(Map, related_name='data')
    state = models.ForeignKey(State, related_name='dataset')
    data = models.CharField(max_length=64)

    def __unicode__(self):
        return "%s Data for %s" % (self.state.name, self.state_map)
