---
title: "Populating a StructuredProperty Using the ndb.Model Constructor"
date: 2018-04-01T12:00:00-06:00
draft: false
description: After taking a deep dive into the App Engine SDK for Python, I thought I would share some of my findings on some of the more esoteric features of the ndb.Model class. In particular, how one can populate a StructuredProperty using the ndb.Model constructor.
---

This article is derived from a Stack Overflow question. The original question can be found [here](https://stackoverflow.com/questions/49572412/what-is-the-best-practice-to-populate-a-structuredproperty-through-the-ndb-model).

## Question
I looked into the `ndb` GitHub sample code, but I couldn't find any example
which shows on how to create a `ndb` entity with a constructor that contains a `StructuredProperty`.

Here is the GitHub [example](https://github.com/GoogleCloudPlatform/python-docs-samples/blob/master/appengine/standard/ndb/modeling/structured_property_models.py).

What if I want to initialize a `Contact` entity with a list of phone numbers and this list of phone number is not a list of `PhoneNumber` objects. Instead it is a list of Python dictionaries.

So, given the following `Model` classes:

```python
class PhoneNumber(ndb.Model):
    """A model representing a phone number."""
    phone_type = ndb.StringProperty(
        choices=('home', 'work', 'fax', 'mobile', 'other'))
    number = ndb.StringProperty()


class Contact(ndb.Model):
    """A Contact model that uses StructuredProperty for phone numbers."""
    # Basic info.
    name = ndb.StringProperty()
    birth_day = ndb.DateProperty()

    # Address info.
    address = ndb.StringProperty()

    phone_numbers = ndb.StructuredProperty(PhoneNumber, repeated=True)
```

I want to create a `Contact` using the following Python dictionaries:

```python
phone_number_dicts = [{"phone_type" : "home", number = 122}, {"phone_type" : "work", number = 123}]

contact = Contact(name = "some name", birthday = "some day", phone_numbers = phone_number_dicts)
```

1. Am I required to convert a dict to a `ndb` entity explicitly?
2. Can I override `ndb` constructor which converts a dict to a `ndb` entity and assign?
3. Any other better approach?

## Solution
Simply override the `PhoneNumber` constructor, so that you can pass in a dict as `kwargs` to its constructor via the `Contact` constructor.

```python
class PhoneNumber(ndb.Model):
    phone_type = ndb.StringProperty(
        choices=('home', 'work', 'fax', 'mobile', 'other'))
    number = ndb.StringProperty()

    def __init__(self, *args, **kwargs):
        super(PhoneNumber, self).__init__(*args, **kwargs)
        self.__dict__.update(kwargs)


class Contact(ndb.Model):
    name = ndb.StringProperty()
    birth_day = ndb.DateProperty()
    address = ndb.StringProperty()
    phone_numbers = ndb.StructuredProperty(PhoneNumber, repeated=True)
    company_title = ndb.StringProperty()
    company_name = ndb.StringProperty()
    company_description = ndb.TextProperty()
    company_address = ndb.StringProperty()

    def __init__(self, *args, **kwargs):
        super(Contact, self).__init__(*args, **kwargs)
        if kwargs:
            self.phone_numbers = []
            for kwarg in kwargs.pop('phone_numbers'):
                if isinstance(kwarg, PhoneNumber):
                    self.phone_numbers.append(kwarg)
                else:
                    p = PhoneNumber(**kwarg)
                    self.phone_numbers.append(p)
```

In this way you can pass a dictionary representation of your `PhoneNumber` entities to the `Contact` constructor or a dictionary representation of the `PhoneNumber` properties to the `PhoneNumber` constructor.

Here are a few test cases I tried via the **Interactive Console** of the `dev_appserver.py`:

```python
from google.appengine.ext import ndb

from models import Contact, PhoneNumber

kwargs = {
    'phone_numbers': [{
        'phone_type': 'home',
        'number': '123',
    }, {
        'phone_type': 'work',
        'number': '456',
    }, {
        'phone_type': 'fax',
        'number': '789',
    }]
}

c = Contact(**kwargs)
print 'Test Case 1:'
print c
print

kwargs = {
    'phone_numbers': [
        PhoneNumber(**{'phone_type': 'home','number': '123'}),
        PhoneNumber(**{'phone_type': 'work','number': '456'}),
        PhoneNumber(**{'phone_type': 'fax', 'number': '789'})
    ]
}

c = Contact(**kwargs)
print 'Test Case 2:'
print c
print

c = Contact(
    phone_numbers=[
        PhoneNumber(phone_type='home', number='123'),
        PhoneNumber(phone_type='work', number='456'),
        PhoneNumber(phone_type='fax', number='789')
    ]
)
print 'Test Case 3:'
print c
print
```

**Output**:

```
Test Case 1:
Contact(phone_numbers=[PhoneNumber(number='123', phone_type='home'),
PhoneNumber(number='456', phone_type='work'),
PhoneNumber(number='789', phone_type='fax')])

Test Case 2:
Contact(phone_numbers=[PhoneNumber(number='123', phone_type='home'),
PhoneNumber(number='456', phone_type='work'),
PhoneNumber(number='789', phone_type='fax')])

Test Case 3:
Contact(phone_numbers=[PhoneNumber(number='123', phone_type='home'),
PhoneNumber(number='456', phone_type='work'),
PhoneNumber(number='789', phone_type='fax')])
```

As expected, each case elicits the same `Contact` objects.
