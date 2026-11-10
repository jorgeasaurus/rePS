@{
    Id           = 'adv-snake-case'
    Title        = 'PascalCase to snake_case'
    Topic        = 'Advanced'
    Level        = 2
    Platforms    = @('Windows', 'Linux', 'MacOS')
    Tags         = @('regex', 'strings')
    FunctionName = 'ConvertTo-SnakeCase'
    Author       = 'rePS'
    Prompt       = @'
Write ConvertTo-SnakeCase so it converts PascalCase or camelCase text to snake_case.
Acronyms stay together.

    ConvertTo-SnakeCase 'HelloWorld'        # hello_world
    ConvertTo-SnakeCase 'getHTTPResponse'   # get_http_response
    ConvertTo-SnakeCase 'already_snake'     # already_snake
'@
    Hints        = @(
        '-replace is case-INSENSITIVE, so [A-Z] matches lowercase too. Use -creplace.'
        'Lookarounds match a position without consuming characters: (?<=[a-z0-9])(?=[A-Z]) is the gap between a lowercase letter and an uppercase one.'
        'Acronyms: the gap in "HTTPResponse" sits between the P and "Re", so (?<=[A-Z])(?=[A-Z][a-z]). Lowercase at the end.'
    )
}
