param([Parameter(Mandatory)][string]$SolutionPath)

BeforeAll {
    . $SolutionPath
}

Describe 'ConvertTo-SnakeCase' {
    It 'converts <Text> to <Expected>' -ForEach @(
        @{ Text = 'HelloWorld'; Expected = 'hello_world' }
        @{ Text = 'helloWorldAgain'; Expected = 'hello_world_again' }
        @{ Text = 'Simple'; Expected = 'simple' }
        @{ Text = 'already_snake'; Expected = 'already_snake' }
        @{ Text = 'getHTTPResponse'; Expected = 'get_http_response' }
        @{ Text = 'HTTPServer'; Expected = 'http_server' }
        @{ Text = 'Version2Update'; Expected = 'version2_update' }
    ) {
        ConvertTo-SnakeCase -Text $Text | Should -BeExactly $Expected
    }
}
