module BitwardenCLI

import bitwarden_cli_jll
import OpenSSL_jll

export bw_run

include("auth.jl")
export bw_login, bw_unlock

include("crypt.jl")
export encrypt_file, decrypt_file

"""
    bw_run(args)

Run `bw $args`.
Convenience wrapper around `bw`.

# Example

```
julia> bw_run(["--version"])
1.17.1
```
"""
function bw_run(args)
    bitwarden_cli_jll.bw() do bin
        run(`$bin $args`)
    end
end

end # module
