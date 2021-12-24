---
title: "How to Test a Function That Raises an Exception"
date: 2018-03-11T12:00:00-06:00
draft: false
description: This article demonstrates how to create a unit test for a Python function that raises an exception.
---

This article demonstrates how to create a unit test for a Python function that raises an exception.

## Problem
For example, let’s say I have a function `set`:

```python
def set(self, k, v):
    """
    Set the value of a Setting specified by its key.

    :param k: key of Setting
    :type k: str
    :param v: value of Setting
    :type v: bool
    :return: None
    :rtype: None
    """
    if not isinstance(v, bool):
        raise TypeError(
            '\'{}\' is not of type bool.'.format(v))

    for setting in self.settings:
        if setting.key == k:
            setting.value = v
            return
    else:
        raise KeyError(k)
```

How do I elicit a `TypeError` and/or `KeyError`. Also, how do I test the exception message?

## Solution
The solution is to use [`assertRaises`](https://docs.python.org/dev/library/unittest.html#unittest.TestCase.assertRaises). `assertRaises` allows an exception to be encapsulated, which means that the test can throw an exception without exiting execution, as is normally the case for unhandled exceptions.

There are two ways to use `assertRaises`:

1. Using keyword arguments.
2. Using a context manager.

The first is the most straight forward:

```python
assertRaises(exception, callable, *args, **kwds)
```

Simply pass the exception, the callable function, and the parameters of the callable function as keyword arguments that will elicit the exception.

The second is slightly more involved:

```python
assertRaises(exception, msg=None)
```

Call the function that should raise the exception with a context. The context manager will store the caught exception object in its exception attribute. This can be useful if the intention is to perform additional checks on the exception raised.

Here is a unit test that tests for both the `KeyError` and `ValueError` with its exception message raised in the original function:

```python
def test_set(self):
    m = MessageSettings(**self.kwargs)
    m.set('a', True)
    self.assertEqual(MessageSettings(
        settings=[
            Setting(
                key='a',
                name='b',
                value=True
            )]
    ), m)
    self.assertRaises(KeyError, m.set, **{'k': 'x', 'v': True})
    with self.assertRaises(TypeError) as context:
        m.set('a', 'True')
    self.assertEqual(
        '\'True\' is not of type bool.', str(context.exception))
```

I have seen instances where a `side_effect` is used in order to simulate an exception. For example:

```python
import unittest

import my_module


class MyTestCase(unittest.TestCase):
    def setUp(self):
        self.mock_logging = patch.object(
            my_module, 'logging', autoSpec=True).start()

    def test(self):
        self.mock_logging.info.side_effect = my_module.DeadlineExceededError
        ...
```

Such a pattern is ill-advised for this instance, since it couples the test case to the existence of the `logging` module and the explicit call to the patched module in the function that you are testing. Removing a call to the `logging` module will cause the unit test to fail.
