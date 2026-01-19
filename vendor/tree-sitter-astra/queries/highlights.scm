; highlights.scm — simple keywords/types/strings/numbers
((identifier) @keyword (#match? @keyword "^(data|case|of|let|in|if|then|else|try|catch|comptime|fun)$"))
(type_constructor) @type
(number) @number
(string) @string
