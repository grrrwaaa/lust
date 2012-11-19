local lust = require "lust"

-- a partial template for generating Lua code:

local t = lust{
	[[@chunk]],
	
	chunk = [[@map{ ., _="\n" }:stat]],
	
	stat = {
		[[@(type)]],
		jump_break = "break", -- return, break
		jump_return = "return @.:exprlist",
		assign = [[@lhs:expr = @rhs:expr]],
		assign_local = [[local @lhs:expr = @rhs:expr]],
		block = [[do
	@chunk
end]],	
		control_while = [[while @cond:expr do
	@body:chunk
end]],
		control_repeat = [[repeat
	@body:chunk
until @cond:expr]],

		control_if = {
			[[if @cond:expr then
	@body:chunk		
@end]],
			["else"] = [[else
	@body:chunk		
@end]],
			["elseif"] = [[else@control_if]],
			["end"] = "@if(end)<{{@end:(end.type)}}>else<{{end}}>",
		},
		
		for_num = [[for $name = @first:expr, @last:expr@if(step)<{{, @step:expr}}> do
	@body:chunk
end]],
		--for_gen1 = [[for @names:nameslist in @iter:exprlist do @body:chunk end]],	
		for_gen = [[for @names:namelist in @iter:exprlist do
	@body:chunk
end]],

		funcall = "@expr.funcall",
	},
	
	expr = {
		[[@(type)]],
		unop = [[($operator @1:expr)]],
		binop = [[(@1:expr $operator @2:expr)]],
		var = [[$1]],
		index = "[$1:expr]",
		number = [[$1]],
		constant = [[$1]],
		literal = [["$1"]],
		funcall = "@name:expr(@exprlist)",
		methodcall = "@<obj:expr>:@name:expr(@exprlist)",
		paren = "(@1:expr)",
		table = {
			"{ @map{ . }:field }",
			field = {
				"@(type), ",
				key = "@key:expr = @1:expr",
				exp = "[@key:expr] = @1:expr",
				arr = "@1:expr",
			},
		},
		prefix = [[@map{ ., _="." }:expr]],
		fundef = [[function(@params:namelist)
	@body:chunk	
end
		]]
	},
	
	exprlist = [[@map{ ., _=", " }:expr]],
	namelist = [[@map{ name=., _=", " }:{{$name}}]],
}

-- an example of an abstract syntax tree:

local expr1 = {
	type = "binop",
	operator = ">",
	{ type = "var", "x"},
	{ type = "number", "10"},
}

local stat1 = {
	type = "assign_local",
	lhs = { type="exprlist", 
		{ type = "var", "foo", },
		{ type = "var", "bar", },
	},
	rhs = { type="exprlist",
		{
			type = "binop", 
			operator = "+", 
			{ type = "number", 1 },
			{
				type = "binop", 
				operator = "+", 
				{ type = "number", 4 },
				{ type = "number", 20 },
			}
		},
		{ type = "number", math.pi },
	}
}
local stat2 = {
	type = "assign",
	lhs = { type = "var", "foo", },
	rhs = {
		type = "binop", 
		operator = "/", 
		{ type = "var", "foo" },
		{ type = "var", "bar" },
	}
}
local stat3 = {
	type = "assign",
	lhs = { type = "var", "foo", },
	rhs = {
		type = "binop", 
		operator = "*", 
		{ type = "var", "foo" },
		{ type = "var", "foo" },
	}, 
}

local block1 = { type="block", stat1, stat2, stat3 }

local while1 = { 
	type="control_while", 
	cond = expr1,
	body = block1,
}

local if1 = {
	type="control_if", 
	cond = expr1,
	body = block1,
	["end"] = {
		type="elseif", 
		cond = expr1,
		body = block1,
		["end"] = {
			type="else", 
			body = block1,
		}
	}
}	

local for1 = {
	type="for_num",
	name="i",
	first={ type="var", "x" },
	last={ type="number", "10" },
	body = { while1 },
}

local for2 = {
	type="for_gen",
	names={ "k", "v" },
	iter={ { type="funcall", name={ type="var", "pairs" }, { type="var", "env" } } },
	body = { stat3 },
}

local fun1 = {
	type="funcall",
	name={ type="prefix", { type="var", "pretty" }, { type="var", "print" } },
	{ type="var", "foo" },
}

local tab1 = {
	type = "table",
	{ type = "arr", { type = "var", "x" } },
	{ type = "key", key={ type = "var", "z" }, { type="literal", "hello" } },
}

local stat4 = {
	type = "assign",
	lhs = { type = "var", "bar", },
	rhs = tab1,
}

local fundef1 = {
	type = "fundef",
	params = { "a", "b" },
	body = {
		stat4,
		{ type = "jump_return", { type="number", "10" }, { type="var", "bar" } }
	}
}

local stat5 = {
	type = "assign",
	lhs = { type = "var", "myfun", },
	rhs = fundef1,
}

local m = { block1, for1, if1, for2, fun1, stat5 }

-- apply model:
print(t:gen(m))