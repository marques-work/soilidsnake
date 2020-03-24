# Solid Snake

Build your Python chops.

![Just a box. Must've been my imagination.](images/mg2-solid-snake.png "Just a box. Must've been my imagination.") **Just a box. Must've been my imagination.**

## Set up your development environment

### `pyenv` - manage python versions

`pyenv` is a pythoon version manager. This allows you to install multiple versionsof python side-by-side and choose which one you want to use for a project.

Generally when starting any project, you'll want to specify the version of python to write code against. This ensures consistency and reproducability from dev to production.

Install using Homebrew if you're on a Mac.

```bash
brew install pyenv

# then add the following to your `.profile` and reload your shell session:

if (type pyenv &> /dev/null); then
 eval "$(pyenv init -)"
fi
```

If you don't have homebrew (and don't want to install it) or you're on another OS, see the [`pyenv` installation instructions](https://github.com/pyenv/pyenv#installation).

### `pipenv` - manage and lock down your project dependencies

For any project of moderate complexity, you'll more than likely need to install packages. `pipenv` kind of combines the functionality of `pip`, `virtualenv`, and even `venv` in that you can specify your production dependencies, dev dependencies (like code quality tools or testing utils) and sandbox them per project. It's kind of like `bundler` for Ruby or `npm` (or `yarn`) for Node.

Install using Homebrew if you're on a Mac.

```bash
brew install pipenv
```

If you don't have homebrew (and don't want to install it) or you're on another OS, see the [`pipenv` installation instructions](https://github.com/pypa/pipenv#installation).

## How to configure your project

First, use `pyenv` to install and select the desired version of python:

```bash
# we'll use python 3.8
pyenv install 3.8.2

# this will create a version file for pyenv to automatically activate 3.8.2 when
# you `cd` into this directory. the file will be named `.python-version`.
pyenv local 3.8.2

# verify that the correct python version is active; this should report 3.8.2
python --version

# commit this and push
git add -- .python-version
git commit -m "Specify Python 3.8.2 for this project with pyenv"
git push
```

Next, use `pipenv` to create a `Pipfile` (descriptor/manifest of your projects dependencies).

```bash
# initialize a `Pipfile` and mandate python 3.8 for good measure. This should match at least
# the major and minor version of the python you selected with `pyenv`
pipenv --python 3.8

# You should now see a `Pipfile`. Stage this in git
git add -- Pipfile

# Now we will add our first dependency: a library called `cowsay`
pipenv install cowsay

# If all went well, you should have seen the package progress bar zoom by and install the
# package. Note that `pipenv` will create a file called `Pipefile.lock` upon installing
# your first dependency. Every time you install, delete, or update a dependency with
# `pipenv`, this lockfile will change. It's important to commit these changes to git as
# well.
git add -- Pipfile.lock
git commit -m "Create Pipfile and install cowsay"
git push
```

Now that you've installed your library, let's write some code to use it:

- `moo.py:`

```python
import cowsay

cowsay.cow("To err is human. To moo is bovine.")
```

Now you can run this file using pipenv, and the `cowsay` package will me made available to your script:

```bash
# activates the virtual env conatining all of your dependencies and runs the script
pipenv run python moo.py
```

You should see:

```
  __________________________________
< To err is human. To moo is bovine. >
  ==================================
                                       \
                                        \
                                          ^__^
                                          (oo)\_______
                                          (__)\       )\/\
                                              ||----w |
                                              ||     ||


```

Don't forget to commit your work!

```bash
git add -- moo.py
git commit -m "Dumb tutorial."
git push
```
