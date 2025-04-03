load(
    "@bootstrap//:toolchain_types.bzl",
    "MyToolchainInfo",
    "MyToolsInfo",
)

def _depend_on_my_toolchain_impl(ctx: AnalysisContext) -> list[Provider]:
    return [
        DefaultInfo()
    ]

depend_on_my_toolchain = rule(
    impl =_depend_on_my_toolchain_impl,
    attrs = {
        "_my_toolchain": attrs.default_only(attrs.toolchain_dep(
            providers = [MyToolchainInfo],
            default = "toolchains//:my_toolchain",
        )),
    },
)
