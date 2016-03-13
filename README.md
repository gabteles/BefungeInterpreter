# Befunge Interpreter

## What's Befunge?

*"Befunge is a two-dimensional fungeoidal (in fact, the original fungeoid) esoteric programming language invented in 1993 by Chris Pressey with the goal of being as difficult to compile as possible."* - [Esolangs](https://esolangs.org/wiki/Befunge)

## What's this?

This code is a Ruby implementation of Befunge's interpreter. It means that you can run befunge code inside your ruby application and get it's output during runtime.

## Usage
```ruby
require 'BefungeInterpreter'

befungeCode = "64+\"!dlroW ,olleH\">:\#,_@"
interpreter = BefungeInterpreter.new(befungeCode)
interpreter.execute
interpreter.output #=> "Hello, World!\n"
```

## License

BefungeInterpreter is licensed through [BSD-3-Clause](https://opensource.org/licenses/BSD-3-Clause)