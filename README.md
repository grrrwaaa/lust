Lust
====

Lua string generator using structured templates. 

The basic principle is that a set of templates define a space of possible structures, and these structures can be specialized according to input data (the "model"). At definition time, Lust generates code to implement the templates, resulting in a partially specialized generator function. At application time, this function interpolates the model to produce an output string.

Within template bodies, a variety of special syntax can be used to interpolate model data and sub-templates. All invocations can be wrapped in <angle quotes> to avoid ambiguity with inline text.

- Elements from the model can be inserted using $model_path syntax. 
- A single period (.) indicates the current environment, otherwise is used to chain path terms, e.g. $a.b.1
- Templates and sub-templates can be invoked using @template_path syntax, including chained terms.
- Paths may include dynamically evaluated terms using parentheses (such as choosing a subtemplate according to a value in the model).
- Invocations of sub-templates can utilze sub-structures in the model, using the @model_path:template_path syntax.
- Conditional items can be inserted using @if, and iterations can be specified using @iter, @map and @rest special forms. 
- Subtemplates can be specified using {{ inline }} syntax, rather than by name.
- Lust tries to do the right thing in automatically inserting indentation.
- Arbitrary Lua functions can be registered to modify environment terms for particular subtemplates. (Nevertheless, it is recommended to construct templates/models which avoid computation in the template application if possible).

Basic example
=============

	lust = require "lust"
	
	-- a template can be specified as a table of subtemplates:
	local template = lust{
		-- first rule is the 'root template':
		"The classic $greeting @typical:place example",
		-- a sub-template:
		place = "$1"
	}
	
	-- a data model to apply:
	local model = {
		greeting = "hello",
		typical = { "world" }
	}
	
	-- the first time gen() is called on a template, it will lazily generate the generator
	-- subsequent calls will re-use this generator
	-- the argument to gen(), if given, becomes a data model, and the result is the application of the generator and model:
	local result = template:gen(model)
	assert(result == "The classic hello world example")

Meta
====

Lust depends on LPeg (http://www.inf.puc-rio.br/~roberto/lpeg/)

Released under the MIT licence (as used by Lua 5.1). 

Authored by Graham Wakefield & Wesley Smith, 2012.
