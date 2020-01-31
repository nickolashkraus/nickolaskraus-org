---
title: "Transforming Code Into Beautiful, Idiomatic Python"
date: 2020-01-26T12:00:00-06:00
draft: false
description: Notes from Raymond Hettinger's talk, "Transforming Code Into Beautiful, Idiomatic Python" from PyCon US 2013.
---

When you see this, do that instead!
* Replace traditional index manipulation with Python’s core looping idioms.
* Learn advanced techniques with `for-else` clauses and the two argument form of `iter()`.
* Improve your craftsmanship and aim for clean, fast, idiomatic Python code.

**Warning**: The code samples in this article are for Python 2, which reached EOL on January 1, 2020.

## Looping over a range of numbers

```python
for i in [0, 1, 2, 3, 4, 5]:
    print i**2
```

```python
for i in range(6):
    print i**2
```

```python
for i in xrange(6):
    print i**2
```

**Notes**

**What is the difference between `range()` and `xrange()`?**

* `range()` produces a list.
* `xrange()` creates an iterator over the range, producing the values one at a time.

In Python 3, `xrange` is renamed to `range`.

## Looping over a collection

```python
colors = ['red', 'green', 'blue', 'yellow']
```

```python
for i in range(len(colors)):
    print colors[i]
```

```python
for color in colors:
    print color
```

## Looping backwards

```python
colors = ['red', 'green', 'blue', 'yellow']
```

```python
for i in range(len(colors)-1, -1, -1):
    print colors[i]
```

```python
for color in reversed(colors):
    print color
```

## Looping over a collection and indices

```python
colors = ['red', 'green', 'blue', 'yellow']
```

```python
for i in range(len(colors)):
    print i, '-->', colors[i]
```

```python
for i, color in enumerate(colors):
    print i, '-->', color
```

## Looping over two collections

```python
names = ['raymond', 'rachel', 'matthew']
colors = ['red', 'green', 'blue', 'yellow']
```

```python
n = min(len(names), len(colors))
for i in range(n):
    print names[i], '-->', colors[i]
```

```python
for name, color in zip(names, colors):
    print name, '-->', color
```

```python
for name, color in izip(names, colors):
    print name, '-->', color
```

**Notes**

**What is the difference between `zip()` and `izip()`?**

* `zip()` returns a list of tuples, where the *i-th* tuple contains the *i-th* element from each of the argument sequences or iterables. The returned list is truncated in length to the length of the shortest argument sequence.
* `izip()`is like `zip()` except that it returns an iterator instead of a list.

An iterator produces the values one at a time, using memory much more efficiently. Wherever possible, use the iterator form of a function.

## Looping in sorted order

```python
colors = ['red', 'green', 'blue', 'yellow']
```

```python
for color in sorted(colors):
    print color
```

```python
for color in sorted(colors, reverse=True):
    print color
```

## Custom sort order

```python
colors = ['red', 'green', 'blue', 'yellow']
```

```python
def compare_length(c1, c2):
    if len(c1) < len(c2): return -1
    if len(c1) > len(c2): return 1
    return 0
```

```python
print sorted(colors, cmp=compare_length)
```

```python
print sorted(colors, key=len)
```

## Call a function until a sentinel value

```python
blocks = [] while True:
    block = f.read(32)
    if block == '':
        break
    blocks.append(block)
```

```python
blocks = []
for block in iter(partial(f.read, 32), ''):
    blocks.append(block)
```

**Notes**

A *sentinel value* is a value of special meaning that is used to designate the absence of data.

## Distinguishing multiple exit points in loops

```python
def find(seq, target):
    found = False
    for i, value in enumerate(seq):
        if value == tgt:
            found = True
            break
    if not found:
        return -1
    return i
```

```python
def find(seq, target):
    for i, value in enumerate(seq):
        if value == tgt:
            break
    else:
       return -1
    return i
```

## Dictionary Skills

* Mastering dictionaries is a fundamental Python skill.
* They are fundamental for expressing relationships, linking, counting, and grouping.

## Looping over dictionary keys

```python
d = {'matthew': 'blue', 'rachel': 'green', 'raymond': 'red'}
```

```python
for k in d:
    print k
```

```python
for k in d.keys():
    if k.startswith('r'):
        del d[k]
```

```python
d = {k : d[k] for k in d if not k.startswith('r')}
```

## Looping over a dictionary keys and values

```python
for k in d:
    print k, '-->', d[k]
```

```python
for k, v in d.items():
    print k, '-->', v
```

```python
for k, v in d.iteritems():
    print k, '-->', v
```

## Construct a dictionary from pairs

```python
names = ['raymond', 'rachel', 'matthew']
colors = ['red', 'green', 'blue']
```

```python
d = dict(izip(names, colors))
{'matthew': 'blue', 'rachel': 'green', 'raymond': 'red'}
```

```python
d = dict(enumerate(names))
{0: 'raymond', 1: 'rachel', 2: 'matthew'}
```

## Counting with dictionaries

```python
colors = ['red', 'green', 'red', 'blue', 'green', 'red']
```

```python
d = {}
for color in colors:
    if color not in d:
        d[color] = 0
    d[color] += 1
```

```python
{'blue': 1, 'green': 2, 'red': 3}
```

```python
d = {}
for color in colors:
    d[color] = d.get(color, 0) + 1
```

```python
d = defaultdict(int)
for color in colors:
    d[color] += 1
```

## Grouping with dictionaries - Part I

```python
names = ['raymond', 'rachel', 'matthew', 'roger',
         'betty', 'melissa', 'judith', 'charlie']
```

```python
d = {}
for name in names:
    key = len(name)
    if key not in d:
        d[key] = []
    d[key].append(name)
```

```python
{5: ['roger', 'betty'], 6: ['rachel', 'judith'],
 7: ['raymond', 'matthew', 'melissa', 'charlie']}
```

## Grouping with dictionaries - Part II

```python
d = {}
for name in names:
    key = len(name)
    d.setdefault(key, []).append(name)
```

```python
d = defaultdict(list)
for name in names:
    key = len(name)
    d[key].append(name)
```

## Is a dictionary popitem() atomic?

```python
d = {'matthew': 'blue', 'rachel': 'green', 'raymond': 'red'}
```

```python
while d:
    key, value = d.popitem()
    print key, '-->', value
```

**Notes**

*Atomicity* is the characteristic in which an operation appears to occur at a single instant between its invocation and its response.

## Linking dictionaries

```python
defaults = {'color': 'red', 'user': 'guest'}
parser = argparse.ArgumentParser()
parser.add_argument('-u', '--user')
parser.add_argument('-c', '--color')
namespace = parser.parse_args([])
command_line_args = {k: v for k, v in
                     vars(namespace).items() if v}
```

```python
d = defaults.copy()
d.update(os.environ)
d.update(command_line_args)
```

```python
d = ChainMap(command_line_args, os.environ, defaults)
```

## Improving Clarity

* Positional arguments and indices are nice.
* Keywords and names are better.
* The first way is convenient for the computer.
* The second corresponds to how human’s think.

## Clarify function calls with keyword arguments

```python
twitter_search('@obama', False, 20, True)
```

```python
twitter_search('@obama', retweets=False, numtweets=20, popular=True)
```

## Clarify multiple return values with named tuples

```python
doctest.testmod() (0, 4)
```

```python
doctest.testmod()
TestResults(failed=0, attempted=4)
```

```python
TestResults = namedtuple('TestResults', ['failed', 'attempted'])
```

## Unpacking sequences

```python
p = 'Raymond', 'Hettinger', 0x30, 'python@example.com'
```

```python
fname = p[0]
lname = p[1]
age = p[2]
email = p[3]
```

```python
fname, lname, age, email = p
```

## Updating multiple state variables

```python
def fibonacci(n):
    x=0
    y=1
    for i in range(n):
        print x
        t=y
        y=x+y
        x=t
```

```python
def fibonacci(n):
    x, y = 0, 1
    for i in range(n):
        print x
        x, y = y, x+y
```

## Tuple packing and unpacking

* Don’t underestimate the advantages of updating state variables at the same time.
* It eliminates an entire class of errors due to out-of-order updates.
* It allows high level thinking: "chunking".

## Simultaneous state updates

```python
tmp_x = x + dx * t
tmp_y = y + dy * t
tmp_dx = influence(m, x, y, dx, dy, partial='x') tmp_dy = influence(m, x, y, dx, dy, partial='y') x = tmp_x
y = tmp_y
dx = tmp_dx
dy = tmp_dy
```

```python
x, y, dx, dy = (x + dx * t,
                y + dy * t,
                influence(m, x, y, dx, dy, partial='x'),
                influence(m, x, y, dx, dy, partial='y'))
```

## Efficiency

* An optimization fundamental rule.
* Don’t cause data to move around unnecessarily.
* It takes only a little care to avoid `O(n**2)` behavior instead of linear behavior.

## Concatenating strings

```python
names = ['raymond', 'rachel', 'matthew', 'roger',
         'betty', 'melissa', 'judith', 'charlie']
```

```python
s = names[0]
for name in names[1:]:
    s += ', ' + name
print s
```

```python
print ', '.join(names)
```

## Updating sequences

```python
names = ['raymond', 'rachel', 'matthew', 'roger',
         'betty', 'melissa', 'judith', 'charlie']
```

```python
del names[0]
names.pop(0)
names.insert(0, 'mark')
```

```python
names = deque(['raymond', 'rachel', 'matthew', 'roger',
               'betty', 'melissa', 'judith', 'charlie'])
```

```python
del names[0]
names.popleft()
names.appendleft('mark')
```

**Notes**

`deque` is a list-like container with fast appends and pops on either end.

## Decorators and Context Managers

* Helps separate business logic from administrative logic.
* Clean, beautiful tools for factoring code and improving code reuse.
* Good naming is essential.
* Remember the Spiderman rule: *"With great power, comes great responsibility!"*

## Using decorators to factor-out administrative logic

```python
def web_lookup(url, saved={}):
    if url in saved:
        return saved[url]
    page = urllib.urlopen(url).read()
    saved[url] = page
    return page
```

```python
@cache
def web_lookup(url):
    return urllib.urlopen(url).read()
```

## Caching decorator

```python
def cache(func):
    saved = {}
    @wraps(func)
    def newfunc(*args):
        if args in saved:
            return newfunc(*args)
        result = func(*args)
        saved[args] = result
        return result
    return newfunc
```

# Factor-out temporary contexts

```python
old_context = getcontext().copy()
getcontext().prec = 50
print Decimal(355) / Decimal(113)
setcontext(old_context)
```

```python
with localcontext(Context(prec=50)):
    print Decimal(355) / Decimal(113)
```

## How to open and close files

```python
f = open('data.txt')
    try:
       data = f.read()
    finally:
        f.close()
```

```python
with open('data.txt') as f:
    data = f.read()
```

## How to use locks

```python
# make a lock
lock = threading.Lock()
```

```python
# old way to use a lock
lock.acquire() try:
    print 'Critical section 1'
    print 'Critical section 2'
finally:
lock.release()
```

```python
# new way to use a lock
with lock:
    print 'Critical section 1'
    print 'Critical section 2'
```

## Factor-out temporary contexts

```python
try:
    os.remove('somefile.tmp')
except OSError:
    pass
```

```python
with ignored(OSError):
    os.remove('somefile.tmp')
```

## Context manager: `ignored()`

```python
@contextmanager
def ignored(*exceptions):
    try:
        yield
    except exceptions:
        pass
```

**Notes**

The `ignored()` idiom exists in Python 3.4+ but is called `suppress()`.

```python
from contextlib import suppress
with suppress(OSError):
    os.remove('foo.txt')
```

## Factor-out temporary contexts

```python
with open('help.txt', 'w') as f:
    oldstdout = sys.stdout
    sys.stdout = f
    try:
        help(pow)
    finally:
        sys.stdout = oldstdout
```

```python
with open('help.txt', 'w') as f:
    with redirect_stdout(f):
        help(pow)
```

## Context manager: redirect_stdout()

```python
@contextmanager
def redirect_stdout(fileobj):
    oldstdout = sys.stdout
    sys.stdout = fileobj
    try:
        yield fieldobj
    finally:
        sys.stdout = oldstdout
```

## Concise Expressive One-Liners

Two conflicting rules:
1. Don’t put too much on one line.
2. Don’t break atoms of thought into subatomic particles.

Raymond’s rule:

> "One logical line of code equals one sentence in English."

## List Comprehensions and Generator Expressions

```python
result = []
for i in range(10):
    s = i ** 2
    result.append(s)
print sum(result)
```

```python
print sum([i**2 for i in xrange(10)])
```

```python
print sum(i**2 for i in xrange(10))
```
