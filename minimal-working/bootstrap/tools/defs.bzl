load(
    "@bootstrap//:toolchain_types.bzl",
    "MyToolsInfo",
)

def _my_tools_impl(ctx: AnalysisContext) -> list[Provider]:
    return [
        DefaultInfo(),
        MyToolsInfo(
            tool_1 = ctx.attrs._tool_1[RunInfo],
        ),
    ]

my_tools = rule(
    impl = _my_tools_impl,
    attrs = {
        "_tool_1": attrs.default_only(attrs.exec_dep(
            providers = [RunInfo],
            default = "bootstrap//tools:tool_1",
        )),
    },
)
