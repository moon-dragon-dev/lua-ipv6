package = 'ipv6'
version = 'scm-1'
source = {
    url    = 'git+https://github.com/moon-dragon-dev/lua-ipv6.git',
    branch = 'master',
}
description = {
    summary  = 'Some ipv6 functions',
    homepage = 'https://github.com/moon-dragon-dev/lua-ipv6.git',
    license  = 'MIT',
}
dependencies = {
    'lua ~> 5.1',
}
build = {
    type = 'builtin',
    modules = {
        ipv6 = 'ipv6.lua'
    },
}
