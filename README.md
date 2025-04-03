# Buck2 cross cell .bzl load issue

A repo demonstrating a Buck2 issue causing type inconsistency when loading a .bzl under different cells

## Reproduction

The "minimal" directory contains an minimal example that triggers the issue. Its internal structure:

- **@bootstrap//:toolchain_types.bzl**: defines two provider types ('MyTools' & 'MyToolChain'), the latter uses the former in definition
- **bootstrap/tools**: defines a tool1.py helper tool and auxiliary files which assemble it as a 'bootstrap//tools:my_tools' rule, which provides 'MyTools'
- **@bootstrap//:toolchain.bzl**: assembles 'MyTools' as a 'bootstrap//:my_toolchain' rule, which provides 'MyToolChain'
- **toolchains/BUCK**: "installs" a my_toolchain instance into 'toolchains//:my_toolchain'
- **@root//:depend_on_my_toolchain.bzl**: defines a rule 'depend_on_my_toolchain' that retrieves my_toolchain from 'toolchains//:my_toolchain'
- **BUCK**: defines a target '//:target' that uses the rule 'depend_on_my_toolchain'

Running `buck2 build //:target` may produce the following error message, which says "mismatches type" between two types both named 'MyToolsInfo', which is confusing.

```console
yxdai-nju@rust % buck2 build //:target
Build ID: b2bc65a5-48b2-4a24-b204-2dd4ddad3746
Command: build.
Time elapsed: 0.0s
BUILD FAILED
Error running analysis for `root//:target (prelude//platforms:default#200212f73efcd57d)`

Caused by:
    0: Error running analysis for `toolchains//:my_toolchain (prelude//platforms:default#200212f73efcd57d) (prelude//platforms:default#200212f73efcd57d)`
    1: Traceback (most recent call last):
         File <builtin>, in <module>
         * bootstrap/toolchain.bzl:10, in _my_toolchain_impl
             MyToolchainInfo(

       error: Value for parameter `my_tools` mismatches type `MyToolsInfo`: `MyToolsInfo(tool_1=RunInfo(args=cmd_args(cmd_args("/usr/bin/env", cmd_args(<build artifact __tool_1__ bound to bootstrap//tools:tool_1 (prelude//platforms:default#200212f73efcd57d)>, format="PYTHONPATH={}"), "python3", <build artifact tool_1.py bound to bootstrap//tools:tool_1 (prelude//platforms:default#200212f73efcd57d)>))))`
         --> bootstrap/toolchain.bzl:10:9
          |
       10 |           MyToolchainInfo(
          |  _________^
       11 | |             my_tools = ctx.attrs._my_tools[MyToolsInfo],
       12 | |         ),
          | |_________^
          |
```

## Workaround

The "minimal-working" directory contains a workaround, which only makes two changes:

- change the my_toolchain "installation path" from 'toolchains//:my_toolchain' to 'bootstrap//:my_toolchain'
- make **@root//:depend_on_my_toolchain.bzl** retrieve the toolchain from the new place 'bootstrap//:my_toolchain' instead

```console
yxdai-nju@rust minimal-working % buck2 build //:target
Target root//:target (prelude//platforms:default#200212f73efcd57d) does not have any outputs. This means the rule did not define any outputs. See https://buck2.build/docs/users/faq/common_issues/#why-does-my-target-not-have-any-outputs for more information
Build ID: ea184480-05ed-4a44-9743-85eb836f80b3
Command: build.
Time elapsed: 0.0s
BUILD SUCCEEDED
```

## Another workaround

Editing **@bootstrap//:toolchain_types.bzl** may also avoid the issue.

```diff
  MyToolsInfo = provider(fields = {
      "tool_1": provider_field(RunInfo),
  })

  MyToolchainInfo = provider(fields = {
-     "my_tools": provider_field(MyToolsInfo),
+     "my_tools": provider_field(typing.Any),
  })
```
