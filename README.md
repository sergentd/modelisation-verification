# Modeling and Verification @ [University of Geneva](http://www.unige.ch)

This repository contains important information about this course.
**Do not forget to [watch](https://github.com/cui-unige/modelisation-verification/subscription) it** as it will allow us to send notifications for events,
such as new exercises, homework, slides or fixes.

## Important Information and Links

* [Page on Moodle](https://moodle.unige.ch/course/view.php?id=183)
* [Page on GitHub](https://github.com/cui-unige/modelisation-verification)
* Courses are Thursday 14:00 - 16:00
* Exercises are Thursday 16:00 - 18:00
* [Gitter](https://gitter.im/cui-unige/modelisation-verification) is available for chatting

## Environment

This course requires the following **mandatory** environment.
We have taken great care to make it as simple as possible.

* [Moodle](https://moodle.unige.ch)
  Check that you are registered in the "Modeling & Verification" classroom;
  we will not use it afterwards.
* [GitHub](https://github.com): a source code hosting platform
  that we will for the exercises and homework.
  Create an account, and **do not forget** to fill your profile with your full name
  and your University email address.
  Ask GitHub for a [Student Pack](https://education.github.com/pack) to obtain
  free private repositories.
* [MacOS High Sierra](https://www.apple.com/macos/high-sierra/)
  or [Ubuntu 16.04 LTS 64bits](https://www.ubuntu.com/download/desktop),
  in a virtual machine, using for instance [VirtualBox](http://virtualbox.org),
  or directly with a dual boot.
* [Atom](https://atom.io): a text editor, that we will use to type the sources.

You also have to:
* [Watch](https://github.com/cui-unige/modelisation-verification/subscription)
  the [course page](https://github.com/cui-unige/modelisation-verification)
  to get notifications about the course.
* [Create a **private** repository](https://help.github.com/articles/creating-a-new-repository/)
  named `modelisation-verification` (exactly).
* [Clone the course repository](https://help.github.com/articles/cloning-a-repository/)

  ```sh
  git clone https://github.com/cui-unige/modelisation-verification.git
  ```

* [Duplicate the course repository into your private one](https://help.github.com/articles/duplicating-a-repository/)

  ```sh
  cd modelisation-verification
  git push --mirror https://github.com/yourusername/modelisation-verification.git
  ```

* Update the repository information

  ```sh
  atom .git/config
  ```

  And replace `cui-unige` by your GitHub username.
* Set the upstream repository:

  ```sh
  git remote add upstream https://github.com/cui-unige/modelisation-verification.git
  ```

* [Add as collaborators](https://help.github.com/articles/inviting-collaborators-to-a-personal-repository/)
  the users: [`saucisson`](https://github.com/saucisson) (Alban Linard)
  and [`mencattini`](https://github.com/mencattini) (Romain Mencattini).
* Run the following script to install dependencies:

  ```sh
    curl -s https://raw.githubusercontent.com/cui-unige/modelisation-verification/master/bin/install | bash /dev/stdin
  ```

The environment you installed contains:
* [Git](https://git-scm.com/docs/gittutorial):
  the tool for source code management;
* [Lua](https://www.lua.org):
  the programming language that we will use;
* [Luarocks](https://luarocks.org):
  a package manager for Lua;
* [Atom](https://atom.io):
  the editor we will use.
  On the first launch, Atom asks to install some missing modules.
  Do not forget to accept, or your environment will be broken.

Make sure that your [repository is up-to-date](https://help.github.com/articles/syncing-a-fork/)
by running frequently:

```sh
  git fetch upstream
  git merge upstream/master
```

## Rules

* You must do your homework in your private fork of the course repository.
* You must fill your full name in your GitHub profile.
* If for any reason you have trouble with the deadline,
  contact your teacher as soon as possible.
* We must have access to your source code, that must be private.
* Your source code (and tests) must pass all checks of `luacheck`
  without warnings or errors.
* Your tests must cover at least 80% of the source code, excluding test files.

## Homework

* All homeworks are located in the `homework/` directory.
* For warnings about your code, we use [LuaCheck](https://github.com/mpeterv/luacheck).
  It is already installed in your environment,
  and can be run using: `luacheck src/`.
* For testing, we use [Busted](http://olivinelabs.com/busted/).
  It is already installed in your environment,
  and can run all the tests within `*_spec.lua` files using: `busted src/`.
* For code coverage, we use [LuaCov](http://keplerproject.github.io/luacov/).
  It is already installed in your environment,
  and can be run using: `luacov`.

### Homework #1

The source files are located within: `homework/petrinets/`.
You have to write code where `TODO` are located.
Do **not** touch the existing code or tests,
but you can add your own tests in addition.

The deadline is 11 october 2017 at 23:59.
We will clone all your repositories using a script,
so make sure that @saucisson and @mencattini have read access.

Please install dependencies by running:

```sh
luarocks install rockspec/fun-scm-1.rockspec
```

Evaluation will be:

* do you have done anything at the deadline?
  (yes: 1 point, no: 0 point)
  * [ ] Done anything
* do you have understood and implemented all the required notions?
  (all: 3 points, none: 0 point)
  * [ ] Reachability graph
  * [ ] Coverability graph
* do you have understood and implemented corners cases of all the required
  notions?
  (all: +2 points, none: 0 point)
  * [ ] Reachability graph
  * [ ] Coverability graph
* do you have correctly written and tested your code?
  (no: -0.5 point for each)
  * [ ] Coding standards
  * [ ] Tests
  * [ ] Code coverage

| Grade |
| ----- |
|       |

### Homework #2

The source files are located within: `homework/proofs/`.
You have to write code where `TODO` are located.
Do **not** touch the existing code or tests,
but you can add your own tests in addition.

The deadline is 11 october 2017 at 23:59.
We will clone all your repositories using a script,
so make sure that @saucisson and @mencattini have read access.

Please install dependencies by running:

```sh
luarocks install rockspec/fun-scm-1.rockspec
luarocks install rockspec/hashids-scm-1.rockspec
```

Evaluation will be:

* do you have done anything at the deadline?
  (yes: 1 point, no: 0 point)
  * [ ] Done anything
* do you have understood and implemented all the required notions?
  (all: 3 points, none: 0 point)
  * [ ] Term Equivalence
  * [ ] Substitution of Variables
  * [ ] Boolean and Natural ADTs
* do you have understood and implemented corners cases of all the required
  notions?
  (all: +2 points, none: 0 point)
  * [ ] Term Equivalence
  * [ ] Substitution of Variables
  * [ ] Boolean and Natural ADTs
* do you have correctly written and tested your code?
  (no: -0.5 point for each)
  * [ ] Coding standards
  * [ ] Tests
  * [ ] Code coverage

| Grade |
| ----- |
|       |
