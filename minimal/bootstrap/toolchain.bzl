load(
    "@bootstrap//:toolchain_types.bzl",
    "MyToolchainInfo",
    "MyToolsInfo",
)

def _my_toolchain_impl(ctx: AnalysisContext) -> list[Provider]:
    return [
        DefaultInfo(),
        MyToolchainInfo(
            my_tools = ctx.attrs._my_tools[MyToolsInfo],
        ),
    ]

my_toolchain = rule(
    impl = _my_toolchain_impl,
    attrs = {
        "_my_tools": attrs.default_only(attrs.exec_dep(
            providers = [MyToolsInfo],
            default = "bootstrap//tools:my_tools",
        )),
    },
    is_toolchain_rule = True,
)
