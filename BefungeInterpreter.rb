#
# Befunge-93 Interpreter
# @author  : Gabriel Teles <gab.teles@hotmail.com>
# @license : BSD-3-Clause
# @version : 1.0.0
#
class BefungeInterpreter
	DIRECTIONS = [:up, :left, :down, :right]
	
	attr_reader :output

	def initialize(code)
		@instructions = code.split("\n").map(&:chars)
		@stack = []
		@pointer = [0,0]
		@finished = false
		@direction = :right
		@stringMode = false
		@output = ""
	end

	def execute
		iterate until done?
	end

	def iterate

		line = @instructions[@pointer[1]]
		instruction = line[@pointer[0]]

		if @stringMode && instruction != '"'
			stackPush(instruction.ord)
			move(@direction)
			return
		end

		# TODO: Instructions should be in a OPCODE hash
		case instruction
		# 0-9 Push this number onto the stack.
		when '0'..'9' then stackPush(instruction.to_i)
		when '+' then executeSum
		when '-' then executeSubtraction
		when '*' then executeMultiplication
		when '/' then executeDivision
		when '%' then executeModulo
		when '!' then executeNot
		when '`' then executeGreaterThan
		when '<' then startMovingLeft
		when '>' then startMovingRight
		when '^' then startMovingUp
		when 'v' then startMovingDown
		when '?' then startMovingInRandomDirection
		when '"' then toggleStringMode
		when '_' then horizontalConditional
		when '|' then verticalConditional
		when ':' then duplicateStackTop
		when '\\' then swapStackTop
		when '$' then discardStackTop
		when '.' then printAsInteger
		when ',' then printAsChar
		when '#' then trampoline
		when 'p' then putVal
		when 'g' then getVal
		when '@' then finishExecution
		when ' ' then noop
		end

		move(@direction)
	end

	def done?
		return @finished
	end

	private

	def move(direction)
		case direction
		when :right
			line = @instructions[@pointer[1]]
			@pointer[0] += 1
			if @pointer[0] >= line.size
				@pointer[0] = 0
			end

		when :left
			@pointer[0] -= 1
			if @pointer[0] < 0
				line = @instructions[@pointer[1]]
				@pointer[0] = line.size - 1
			end
		when :down
			@pointer[1] += 1
			if @pointer[1] >= @instructions.size
				@pointer[1] = 0
			end
		when :up
			@pointer[1] -= 1
			if @pointer[1] < 0
				@pointer[1] = @instructions.size - 1
			end
		end
	end

	def stackPush(value) 
		@stack.push(value)
	end

	def stackPop
		return @stack.empty? ? 0 : @stack.pop
	end

	#=== OPERATIONS

	# + Addition: Pop a and b, then push a+b.
	def executeSum
		a = stackPop
		b = stackPop
		stackPush(a + b)
	end

	# - Subtraction: Pop a and b, then push b-a.
	def executeSubtraction
		a = stackPop
		b = stackPop
		stackPush(b - a)
	end

	# * Multiplication: Pop a and b, then push a*b.
	def executeMultiplication
		a = stackPop
		b = stackPop
		stackPush(a * b)
	end

	# / Integer division: Pop a and b, then push b/a, rounded down. If a is zero, push zero.
	def executeDivision
		a = stackPop
		b = stackPop

		if a.zero?
			stackPush(0)
		else
			stackPush((b/a).to_i)
		end
	end

	# % Modulo: Pop a and b, then push the b%a. If a is zero, push zero.
	def executeModulo
		a = stackPop
		b = stackPop

		if a.zero?
			stackPush(0)
		else
			stackPush(b % a)
		end
	end

	# ! Logical NOT: Pop a value. If the value is zero, push 1; otherwise, push zero.
	def executeNot
		a = stackPop

		if a.zero?
			stackPush(1)
		else
			stackPush(0)
		end
	end

	# ` Greater than: Pop a and b, then push 1 if b>a, otherwise push zero.
	def executeGreaterThan
		a = stackPop
		b = stackPop

		if b > a
			stackPush(1)
		else
			stackPush(0)
		end
	end

	#=== MOVING

	# < Start moving left.
	def startMovingLeft
		@direction = :left
	end

	# > Start moving right.
	def startMovingRight
		@direction = :right
	end

	# ^ Start moving up.
	def startMovingUp
		@direction = :up
	end

	# v Start moving down.
	def startMovingDown
		@direction = :down
	end

	# ? Start moving in a random cardinal direction.
	def startMovingInRandomDirection
		@direction = DIRECTIONS.sample
	end

	#=== MODES

	# " Start string mode: push each character's ASCII value all the way up to the next ".
	def toggleStringMode
		@stringMode = !@stringMode
	end

	#=== CONDITIONALS

	# _ Pop a value; move right if value = 0, left otherwise.
	def horizontalConditional
		a = stackPop

		if a.zero?
			startMovingRight
		else
			startMovingLeft
		end
	end

	# | Pop a value; move down if value = 0, up otherwise.
	def verticalConditional
		a = stackPop

		if a.zero?
			startMovingDown
		else
			startMovingUp
		end
	end

	#=== STACK

	# : Duplicate value on top of the stack. If there is nothing on top of the stack, push a 0.
	def duplicateStackTop
		if @stack.empty?
			stackPush(0)
		else
			a = stackPop

			stackPush(a)
			stackPush(a)
		end
	end

	# \ Swap two values on top of the stack. If there is only one value, pretend there is an extra 0 on bottom of the stack.
	def swapStackTop
		a = stackPop
		b = stackPop

		stackPush(a)
		stackPush(b)
	end

	# $ Pop value from the stack and discard it.
	def discardStackTop
		stackPop
	end

	#=== OUTPUT CONTROL

	# . Pop value and output as an integer.
	def printAsInteger
		@output << stackPop.to_s
	end

	# , Pop value and output the ASCII character represented by the integer code that is stored in the value.
	def printAsChar
		@output << stackPop.chr
	end

	#=== FLOW CONTROL

	# # Trampoline: Skip next cell.
	def trampoline
		move(@direction)
	end

	#=== STORAGE

	# p A "put" call (a way to store a value for later use). Pop y, x and v, then change the character at the position (x,y) in the program to the character with ASCII value v.
	def putVal
		y = stackPop
		x = stackPop
		v = stackPop

		@instructions[y][x] = v.chr
	end

	# g A "get" call (a way to retrieve data in storage). Pop y and x, then push ASCII value of the character at that position in the program.
	def getVal
		y = stackPop
		x = stackPop

		stackPush(@instructions[y][x].ord)
	end

	#=== PROGRAM CONTROL

	# @ End program.
	def finishExecution
		@finished = true
	end

	#=== MISC

	# (i.e. a space) No-op. Does nothing.
	def noop
		# DO NOTHING
	end
end

if $0 === __FILE__
	# Eratosthenes' Sieve
	interpreter = BefungeInterpreter.new("2>:3g\" \"-!v\\  g30          <\n |!`\"O\":+1_:.:03p>03g+:\"O\"`|\n @               ^  p3\\\" \":<\n2 234567890123456789012345678901234567890123456789012345678901234567890123456789")
	interpreter.execute
	puts interpreter.output #=> "Hello, World!"
end