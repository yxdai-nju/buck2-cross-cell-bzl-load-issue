MyToolsInfo = provider(fields = {
    "tool_1": provider_field(RunInfo),
})

MyToolchainInfo = provider(fields = {
    "my_tools": provider_field(MyToolsInfo),
})
