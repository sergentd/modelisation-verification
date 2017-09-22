# Modeling and Verification @ [University of Geneva](http://www.unige.ch)

This repository contains important information about this course.
**Do not forget to [watch](https://github.com/cui-unige/modelisation-verification/subscription) it** as it will allow us to send notifications for events,
such as new exercises, homework, slides or fixes.

## Important Information and Links

* [Page on Moodle](https://moodle.unige.ch/course/view.php?id=183)
* [Page on GitHub](https://github.com/cui-unige/modelisation-verification)
* Courses are Thursday 14:00 - 16:00
* Exercises are Thursday 16:00 - 18:00

## Environment

This course requires the following **mandatory** environment.
We have taken great care to make it as simple as possible.

* [Moodle](https://moodle.unige.ch)
  Check that you are registered in the "Modeling & Verification" classroom;
  we will not use it afterwards.
* [GitHub](https://github.com): a source code hosting platform
  that we will for the exercises and homework.
  Create an account, and *do not forget* to fill your profile with your full name
  and your University email address.
  Ask GitHub for a [Student Pack](https://education.github.com/pack) to obtain
  free private repositories.
* [MacOS High Sierra](https://www.apple.com/macos/high-sierra/)
  with [Homebrew](https://brew.sh),
  or [Ubuntu 16.04 LTS 64bits](https://www.ubuntu.com/download/desktop),
  in a virtual machine, using for instance [VirtualBox](http://virtualbox.org),
  or directly with a dual boot.
* [Atom](https://atom.io): a text editor, that we will use to type the sources.

You also have to:
* [Watch](https://github.com/cui-unige/modelisation-verification/subscription)
  the [course page](https://github.com/cui-unige/modelisation-verification)
  to get notifications about the course.
* [Fork it](https://github.com/cui-unige/modelisation-verification#fork-destination-box)
  into your account.
* [Make your fork *private*](https://help.github.com/articles/making-a-public-repository-private/)
* [Add as collaborators](https://help.github.com/articles/inviting-collaborators-to-a-personal-repository/)
  the users: `saucisson` (Alban Linard) and `mencattini` (Romain Mencattini).
* Run the following script to install dependencies:

  ```sh
    curl -s https://raw.githubusercontent.com/cui-unige/modeling-verification/master/bin/install | bash /dev/stdin
  ```

The environment you installed contains:
* [Git](https://git-scm.com/docs/gittutorial):
  the tool for source code management;
* [Lua](https://www.lua.org):
  the programming language that we will use;
* [Luarocks](https://luarocks.org):
  a package manager for Lua;
* [Wercker](http://wercker.com/cli):
  a tool (and online service) to build and test your source code;
* [Docker](https://www.docker.com):
  a container system, required by `wercker`;
* [Atom](https://atom.io):
  the editor we will use.

## Rules

* You must do your homework in your private fork of the course repository.
* If for any reason you have trouble with the deadline,
  contact your teacher as soon as possible.
* Your source code (and tests) must pass all checks of `luacheck`
  without warnings or errors.
* Your tests must cover at least 80% of the source code, excluding test files.

## Evaluation

Evaluation follows the questions:
* Have you done anything at the deadline?
  (no: 0 points)
  * [ ] Done anything
* Do you have understood and implemented all the required notions?
  (yes: 4 points for all, no: 2 points for none)
  * [ ] algorithm #1
  * [ ] algorithm #2
  * [ ] ...
* Do you have understood and implemented corners cases of all the required
  notions?
  (yes: +2 point for all)
  * [ ] algorithm #1
  * [ ] algorithm #2
  * [ ] ...
* Do you have correctly written and tested your code?
  (no: -0.5 point for each)
  * [ ] Coding standards
  * [ ] Tests
  * [ ] Code coverage

| TP  | Grade |
| --- |------ |
|     |       |
