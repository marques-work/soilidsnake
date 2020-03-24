# Solid Snake

Build your Python chops.

![Just a box. Must've been my imagination.](images/mg2-solid-snake.png "Just a box. Must've been my imagination.")

## Set up your development environment

### `pyenv` - manage python versions

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
