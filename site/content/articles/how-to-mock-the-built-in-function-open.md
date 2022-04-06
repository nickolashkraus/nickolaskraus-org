---
title: "How to Mock the Built-in Function open()"
date: 2018-03-18T00:00:00-06:00
draft: false
description: This article provides an example for mocking the Python built-in function open() using the mock library.
---

In my last article, I discussed how to create a unit test for a Python function that raises an exception. This technique enables a function to be called with parameters that would cause an exception without its execution being fatal.

Another scenario in which a similar pattern can be applied is when mocking a function. [mock](https://docs.python.org/3/library/unittest.mock.html) is a library for testing in Python. It allows you to replace parts of your system under test with mock objects and make assertions about how they have been used.

In this example, we will leverage the `patch` function, which handles patching module and class level attributes within the scope of a test. When using `patch`, the object you specify will be replaced with a mock (or other object) during the test and restored when the test ends.

## Problem
For example, let’s say I have a function `open_json_file`:

```python
def open_json_file(filename):
    """
    Attempt to open and deserialize a JSON file.

    :param filename: name of the JSON file
    :type filename: str
    :return: dict of log
    :rtype: dict
    """
    try:
        with open(filename) as f:
            try:
                return json.load(f)
            except ValueError:
                raise ValueError('{} is not valid JSON.'.format(filename))
    except IOError:
        raise IOError('{} does not exist.'.format(filename))
```

How do I mock `open` so that it is not called with the passed argument? How do I elicit a `IOError` and/or `ValueError` and test the exception message?

## Solution
The solution is to use [`mock_open`](https://docs.python.org/3.3/library/unittest.mock.html#mock-open) in conjunction with [`assertRaises`](https://docs.python.org/dev/library/unittest.html#unittest.TestCase.assertRaises). `mock_open` is a helper function to create a mock to replace the use of the built-in function `open`. `assertRaises` allows an exception to be encapsulated, which means that the test can throw an exception without exiting execution, as is normally the case for unhandled exceptions. By nesting both `patch` and `assertRaises` we can fib about the data returned by `open` and cause an exception is raised.

The first step is to create the `MagicMock` object:

```python
read_data = json.dumps({'a': 1, 'b': 2, 'c': 3})
mock_open = mock.mock_open(read_data=read_data)
```

**Note**: *read_data* is a string for the *~io.IOBase.read* method of the file handle to return. This is an empty string by default.

Next, using `patch` as a context manager, `open` can be patched with the new object, `mock_open`:

```python
with mock.patch('__builtin__.open', mock_open):
    ...
```

Within this context, a call to `open` returns `mock_open`, the `MagicMock` object:

```python
with mock.patch('__builtin__.open', mock_open):
    with open(filename) as f:
        ...
```

In the case of our example:

```python
with mock.patch('__builtin__.open', mock_open):
    result = open_json_file('filename')
```

With `assertRaises` as a nested context, we can then test for the raised exception when the file does not contain valid JSON:

```python
read_data = ''
mock_open = mock.mock_open(read_data=read_data)
with mock.patch("__builtin__.open", mock_open):
    with self.assertRaises(ValueError) as context:
        open_json_file('filename')
    self.assertEqual(
        'filename is not valid JSON.', str(context.exception))
```

Here is the full test, which provides 100% coverage of the original `open_json_file` function:

```python
def test_open_json_file(self):
    # test valid JSON
    read_data = json.dumps({'a': 1, 'b': 2, 'c': 3})
    mock_open = mock.mock_open(read_data=read_data)
    with mock.patch('__builtin__.open', mock_open):
        result = open_json_file('filename')
    self.assertEqual({'a': 1, 'b': 2, 'c': 3}, result)
    # test invalid JSON
    read_data = ''
    mock_open = mock.mock_open(read_data=read_data)
    with mock.patch("__builtin__.open", mock_open):
        with self.assertRaises(ValueError) as context:
            open_json_file('filename')
        self.assertEqual(
            'filename is not valid JSON.', str(context.exception))
    # test file does not exist
    with self.assertRaises(IOError) as context:
        open_json_file('null')
    self.assertEqual(
        'null does not exist.', str(context.exception))
```
