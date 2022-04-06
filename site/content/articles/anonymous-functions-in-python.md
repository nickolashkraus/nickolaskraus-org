---
title: "Anonymous Functions in Python"
date: 2018-04-08T00:00:00-06:00
draft: false
description: A brief discussion of lambda functions in Python.
---

An anonymous function is simply a function definition without an identifier. They exist in order to encapsulate simple logic into a syntactically lightweight form. In Python, anonymous functions are defined using the `lambda` keyword and have the following syntax:

```python
lambda arguments: expression
```

The executable body of the lambda must be an expression not a statement. The value returned by the lambda is the value of the contained expression.

I typically use lambda functions to perform a lightweight manipulation of data structures or when passing the lambda to a higher-order function such as `filter()`, `map()`, or `sort()`.

Here is a simple example. Say I want to remove a key matching a specific criteria from a list of maps.

```python
my_list = [
    {'a': 1, 'b': 2, 'c': 3},
    {'b': 4, 'c': 5, 'a': 6},
    {'c': 7, 'a': 8, 'b': 9}
]
```

A trivial solution would be to iterate through the list and remove the specified key:

```python
my_list = [
    {'a': 1, 'b': 2, 'c': 3},
    {'b': 4, 'c': 5, 'a': 6},
    {'c': 7, 'a': 8, 'b': 9}
]

key_to_remove = 'a'

for m in my_list:
    for k in m.keys():
        if k == key_to_remove:
            m.pop(k, None)
```

The more elegant solution is to use a lambda function:

```python
my_list = [
    {'a': 1, 'b': 2, 'c': 3},
    {'b': 4, 'c': 5, 'a': 6},
    {'c': 7, 'a': 8, 'b': 9}
]

key_to_remove = 'a'

map(lambda x: [x.pop(k) for k in x.keys() if k in key_to_remove],
    my_list or [{}])
```

In both cases the result is the same:

```python
>>> print my_list
[{'c': 3, 'b': 2}, {'c': 5, 'b': 4}, {'c': 7, 'b': 9}]
```

Lambda functions have broader utility for `filter()` and `sort()` where the function is applied to each item in the iterable, allowing for polymorphic filtering or sorting.
