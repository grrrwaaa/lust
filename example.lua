local lust = require "lust"

-- a template for generating Lua code:

local t = lust{
	[[@chunk]],
	
	chunk = [[@map{ ., _="\n" }:stat]],
	
	stat = {
		[[@(type)]],
		assign = [[@lhs:expr = @rhs:expr]],
		assign_local = [[local @lhs:expr = @rhs:expr]],
		block = [[do
	@chunk
end]],
	},
	
	expr = {
		[[@(type)]],
		binop = [[(@1:expr $operator @2:expr)]],
		var = [[$1]],
		number = [[$1]],
	},
	
	exprlist = [[@map{ ., _=", " }:expr]],
}

-- an example of an abstract syntax tree:

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

local m = { block1 }

t:gen()
t:dump()

print(t:gen(m))