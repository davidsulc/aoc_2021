# Day 2

https://adventofcode.com/2021/day/2

Using a struct and parsing the input into structs allows

* to have input errors be raised as soon as possible (when they're encountered rather than when they're supposed to alter the position)
* for the core logic (applying moves to a position) to a) not have to worry about invalid data (if a struct exists, the data has been parsed and is known good)

The logic in `Position` has been refactored in an attempt to bring the domain concerns to the forefront (e.g. that `aim` may or may not be used, and that it only affects which attribute is changed and not *how* it is changed).

In a sense, the goal was for someone reading the source code, but not having access to the problem description, to be able to get as main information as possible regarding the domain problem that is being solved.

In no particular order:

* `Sol` indicates clearly that the 2 parts differ only with respect to an `aim` concept
* `Position` and `Move` structs hint at those concepts being a core part of the domain problem
* `Move` has a `from_string` indicating that input may come from a text format
* `Position` does its best to clearly communicate the domain concerns in the code:

  * when `forward` is given, we always move forward but we may in addition change the depth if `aim` is being used
  * when `up` or `down` is given, we essentially do the same thing (increase/decrease a positional attribute): only the affected attribute changes
