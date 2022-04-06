---
title: "Isolating Python Environments with pyenv, virtualenv, and virtualenvwrapper"
date: 2018-03-25T00:00:00-06:00
draft: false
description: When working with multiple Python applications, the problem of conflicting dependencies and versions is bound to arise. Imagine you have an application that needs version 1 of a library, but another application requires version 2. How can you use both of these applications at the same time? When the Python environment is shared, it is easy to end up in a situation where upgrading the dependencies of one application, invalidates the dependencies of another. In order to mitigate this problem, is it necessary to isolate Python environments.
---

This guide provides the motivation behind isolating Python environments and the means by which multiple Python versions and Python package versions can be managed effortlessly. Instead of installing *all* dependencies to, say, `/usr/lib/python2.7/site-packages` (or wherever your platform’s standard location is), `pyenv`, `virtualenv`, and `virtualenvwrapper` can be used to give each application is own, virtual environment.

## Technology
First, a brief overview of the technology that we will be using:

[**Homebrew**](https://brew.sh/)

* If you use macOS, you are aware of its terrific third-party package manager. We will use Homebrew to create a global Python environment and `pip` installation.

[`pyenv`](https://github.com/pyenv/pyenv)

* `pyenv` allows the user to switch between multiple versions of Python. For our application, we will use `pyenv` to switch between Python version installations, however, `pyenv` also allows the user to create global—but separate—package environments unique to a Python version install.

[`virtualenvwrapper`](http://virtualenvwrapper.readthedocs.io/en/latest/)

* `virtualenvwrapper` provides a set of commands which makes working with virtual environments much more pleasant. It also keeps all your virtual environments in one place.

[`virtualenv`](https://virtualenv.pypa.io/en/stable/)

* `virtualenv` creates an environment that has its own installation directories, that do not share libraries with other `virtualenv` environments. It keeps dependencies required by different projects in separate places, while keeping the global `site-packages` directory clean and manageable.

Of note is the order in which the above tools are listed. You can think of each as a shell encasing the tools below it. `virtualenv` is our core technology, which enables the creation of separate Python package version environments. `virtualenvwrapper` simplifies the capabilities of `virtualenv` and consolidates environments into a single location. `pyenv` allows the Python version install to be changed effortlessly. Homebrew is used to manage our global (or system-level) installation of Python and Python packages.

## Installation

### Install Python2 and Python3:

This section has been changed to reflect how Homebrew now handles Python installations. For more information, read [this](https://docs.brew.sh/Homebrew-and-Python.html) article created by the Homebrew developers.

First, let’s update brew:

```bash
$ brew update
```

then install Python 2 and Python 3:

```bash
$ brew install python2 python3
```

Confirm install:

```bash
$ python2 -V
Python 2.7.15
$ which python2
/usr/local/bin/python2

$ python3 -V
Python 3.7.2
$ which python3
/usr/local/bin/python3
```

**Note**: Your versions may vary from those listed above. This is fine.

**Note**: Homebrew installs packages to their own directory and then symlinks their files into `/usr/local/bin`. macOS comes pre-packaged with Python which is located at `/usr/bin/python`. We will not be using this installation of Python at all in this setup. Our Homebrew installation of Python 2 and Python 3 will serve as our global installation.

### Install `pip`

As of Homebrew (1.2.4), `python2` and `python3` install `pip2` and `pip3`, respectively. I prefer to use these installations to install Python packages in order to keep the global install space uncluttered. This allows the Homebrew Python 2 and Python 3 installations to be the global authority. However, if you wish to use a global `pip` installation tied to your default Python installation—which is pre-installed on your Mac—execute `sudo easy_install pip` to install pip globally.

Confirm install:

```bash
$ pip -V
pip 19.0.2 from /usr/local/lib/python2.7/site-packages/pip (python 2.7)
$ which pip
/usr/local/bin/pip

$ pip2 -V
pip 19.0.2 from /usr/local/lib/python2.7/site-packages/pip (python 2.7)
$ which pip2
/usr/local/bin/pip2

$ pip3 -V
pip 19.0.2 from /usr/local/lib/python3.7/site-packages/pip (python 3.7)
$ which pip3
/usr/local/bin/pip3
```

Any `pip` packages will be installed to `/usr/local/lib/python2.7/site-packages` and `/usr/local/lib/python3.6/site-packages` respectively depending on the Python version.

Our installation of `pip2` and `pip3` will serve as our global installation.

**Note**: `pip` and `pip2` are, for all intents and purposed, the same binary and can be used interchangeably. Going forward, we will use `pip`.

### Install `virtualenv` and `virtualenvwrapper`

```bash
$ pip install virtualenv virtualenvwrapper
```

Confirm install:

```bash
$ pip list --format freeze | grep virtualenv
virtualenv==16.4.0
virtualenv-clone==0.5.1
virtualenvwrapper==4.8.4
```

### Configure `virtualenv`

Create a directory in your `$HOME` directory for virtual environments:

```bash
$ mkdir ~/.virtualenvs
```

Add the following lines to your `.bashrc`, `.zshrc`, or `.bash_profile` per your preference and shell:

```bash
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python2
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
source /usr/local/bin/virtualenvwrapper.sh
```

**Note**: This will tell virtualenvwrapper to use the Homebrew installation of Python 2 and virtualenv. If you do not specify `VIRTUALENVWRAPPER_PYTHON` and `VIRTUALENVWRAPPER_VIRTUALENV`, you will need to install virtualenv and virtualenvwrapper in each environment you plan to invoke virtualenvwrapper commands (e.g. `mkvirtualenv`).

Restart your shell (in this case I am using zsh):

```bash
$ exec zsh
```

Alternatively, you can use `exec bash` if you are using a bash shell.

**Note**: You should see output from the `virtualenvwrapper.sh` script similar to the following:

```bash
$ exec zsh
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/premkproject
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/postmkproject
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/initialize
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/premkvirtualenv
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/postmkvirtualenv
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/prermvirtualenv
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/postrmvirtualenv
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/predeactivate
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/postdeactivate
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/preactivate
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/postactivate
virtualenvwrapper.user_scripts creating /Users/<username>/.virtualenvs/get_env_details
```

### Create a virtual environment

Use the `mkvirtualenv` to create a new virtual environment:

```bash
$ mkvirtualenv myenv
New python executable in /Users/<username>/.virtualenvs/myenv/bin/python2.7
Also creating executable in /Users/<username>/.virtualenvs/myenv/bin/python
Installing setuptools, pip, wheel...
done.
$ (myenv)
```

To switch between virtual environments:

```bash
$ workon <virtual_environment>
$ (virtual_environment)
```

To exit a virtual environment:

```bash
$ deactivate
$
```

Now when a *virtualenv* is activated all the Python packages that you install without using `sudo` will be installed inside the virtualenv `site-packages` directory in `~/.virtualenvs`.

Congratulations! You are now well on your way to developing with virtual environments. However, we still need to install `pyenv` in order to quickly switch between Python versions similar to how we have done with `virtualenv` and `virtualenvwrapper`.

### Install `pyenv` and `pyenv-virtualenvwrapper`

```bash
$ brew install pyenv pyenv-virtualenvwrapper
```

Confirm install:

```bash
$ pyenv --version
pyenv 1.2.9

$ pyenv-virtualenvwrapper --version
pyenv-virtualenvwrapper 20140609 (virtualenvwrapper 4.8.4)
```

### Configure `pyenv`

Install the Python versions you wish to use:

```bash
$ pyenv install 2.7.8
$ pyenv install 2.7.15
$ pyenv install 3.7.2
```

**Note**: This may take a few minutes.

**Note**: For work, I need to use Python 2.7.8. This version is completely optional, however Python 2.7.15 and 3.7.2 are the most up-to-date Python installations at the time of this writing and it is nice to have these versions at your disposal.

If you received the following error:

```bash
ERROR: The Python ssl extension was not compiled. Missing the OpenSSL lib?
```

You may need to tell the compiler where the `openssl` package is located:

```bash
CFLAGS="-I$(brew --prefix openssl)/include" \
LDFLAGS="-L$(brew --prefix openssl)/lib" \
pyenv install -v 2.7.8
```

Check out the `pyenv` [Wiki](https://github.com/pyenv/pyenv/wiki/Common-build-problems) for common build problems.

**Note**: When running Mojave or higher (10.14+) you will also [need to install the additional SDK headers](https://developer.apple.com/documentation/xcode_release_notes/xcode_10_release_notes#3035624). You can also check under `/Library/Developer/CommandLineTools/Packages/` as some versions of macOS will have the `.pkg` already installed.

```bash
sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
```

Next, add the following lines to your `.bashrc`, `.zshrc`, or `.bash_profile` per your preference and shell:

```bash
# set up pyenv
eval "$(pyenv init -)"

python2.latest() {
  pyenv shell 2.7.15
  pyenv virtualenvwrapper
}

python3.latest() {
  pyenv shell 3.7.2
  pyenv virtualenvwrapper
}

# default to Python 2.7.15
python2.latest
```

Restart your shell (in this case I am using zsh):

```bash
$ exec zsh
```

Alternatively, you can use `exec bash` if you are using a bash shell.

### Understanding shims

Notice, you are now using a version of Python provided by `pyenv` through the use of shims:

```bash
$ which python
/Users/<username>/.pyenv/shims/python
```

`pyenv` works by inserting a directory of shims at the front of your `PATH` environment variable:

```bash
$(pyenv root)/shims:/usr/local/bin:/usr/bin:/bin
```

In this way, you can switch between Python installations using the following commands:

```bash
$ python2.latest
$ python -V
Python 2.7.15

$ python3.latest
$ python -V
Python 3.7.2
```

Now, let’s reiterate what we just did. First, we installed `python2` and `python3` using Homebrew to take the place of our global Python installation. Next, we allowed for isolated Python package environments using `virtualenv` and `virtualenvwrapper`. Finally, we diverted our system-wide Python installation to specific Python versions using `pyenv`. Now that we have our system set up, let’s test it.

**Note**: Removing `eval "$(pyenv init -)"` and subsequent lines from your zsh or bash configuration file should revert your system back to the system-wide installation of Python installed via Homebrew.

## Test your virtual environment configuration

If you comment out the `# set up pyenv` section of your zsh or bash configuration file, you should revert your system back to the system-wide installation of Python installed via Homebrew.

```bash
# set up pyenv
# eval "$(pyenv init -)"
#
# python2.latest() {
#   pyenv shell 2.7.15
#   pyenv virtualenvwrapper
# }
#
# python3.latest() {
#   pyenv shell 3.7.2
#   pyenv virtualenvwrapper
# }
#
# default to Python 2.7.15
# python2.latest
```

```bash
exec zsh
```

```bash
# global Python install of version 2.7.15 via Homebrew
$ python2 -V
Python 2.7.15
$ which python2
/usr/local/bin/python2

# global Python install of version 3.7.2 via Homebrew
$ python3 -V
Python 3.7.2
$ which python3
/usr/local/bin/python3
```

Now, let’s reapply our `pyenv` configuration and restart our shell.

Uncomment the `# set up pyenv` section of your zsh or bash configuration file:

```bash
# set up pyenv
eval "$(pyenv init -)"

python2.latest() {
  pyenv shell 2.7.15
  pyenv virtualenvwrapper
}

python3.latest() {
  pyenv shell 3.7.2
  pyenv virtualenvwrapper
}

# default to Python 2.7.15
python2.latest
```

```bash
$ exec zsh
```

```bash
# apply the Python 2.7.15 pyenv shell
$ python2.latest
$ python -V
Python 2.7.15
$ which python
/Users/nkraus/.pyenv/shims/python

# apply the Python 3.7.2 pyenv shell
$ python3.latest
$ python -V
Python 3.7.2
$ which python
/Users/nkraus/.pyenv/shims/python
```

We find that our Python installations are pinned to the installations installed via `pyenv`. We can now create virtual environments using each of these Python installations:

```bash
$ python2.latest
$ mkvirtualenv python2
...
$ python -V
Python 2.7.15

$ deactivate

$ python3.latest
$ mkvirtualenv python3
...
$ python -V
Python 3.7.2

$ deactivate
```

Done! You have successfully configured your development environment using `pyenv`, `virtualenv`, and `virtualenvwrapper` in order to isolate Python environments.

**Update - 2018-11-08**

Hitting this error?

```bash
mkvirtualenv:78: /usr/local/bin/virtualenv: bad interpreter: /usr/local/opt/python/bin/python2.7: no such file or directory
```

This error is due to the fact that virtualenv uses the absolute path of the Python 2 installation (`#!/usr/local/opt/python/bin/python2.7`). As of March 1st, 2018, Homebrew updated the `python` formula to use Python 3:

> On 1st March 2018 the `python` formula will be upgraded to Python 3.x and a `python@2` formula will be added for installing Python 2.7 (although this will be keg-only so neither `python` nor `python2` will be added to the `PATH` by default without a manual `brew link --force`). We will maintain `python2`, `python3` and `python@3` aliases. Any formulae that use `depends_on` “python” outside Homebrew/core will need to be updated at this point if they wish to keep using Python 2. Note: macOS has provided Python 2.7 since OS X Lion (10.7) so you can update formulae that need Python 2 today by removing `depends_on` “python” so they use the system Python instead.

To remedy this change, virtualenv changed the path of the Python 2 installation to use the `python@2` formula (`#!/usr/local/opt/python@2/bin/python2.7`).

To remedy this issue, upgrade the virtualenv and virtualenvwrapper Python packages for the Python 2 installation installed via Homebrew:

```bash
$ which python
/usr/local/bin/python
$ pip install --upgrade virtualenv virtualenvwrapper
```
