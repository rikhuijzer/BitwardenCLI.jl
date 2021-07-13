const CLIENTID = "BW_CLIENTID"
const CLIENTSECRET = "BW_CLIENTSECRET"
const PASSWORD = "BW_PASSWORD"
const SESSIONKEY = "BW_SESSION"

"""
    bw_login(; client_id=ENV["BW_CLIENTID"], client_secret=ENV["BW_CLIENTSECRET"])

Authenticate with the Bitwarden server by using an API key.

This method assumes that the users wants to use an API key, because that is the most
suitable for usage in scripts.
The other login requires two-step login or a browser authentication flow.
"""
function bw_login(; client_id=ENV[CLIENTID], client_secret=ENV[CLIENTSECRET])
    env = Dict{String,String}(CLIENTID = client_id, CLIENTSECRET = client_secret)

    withenv(env...) do
        bitwarden_cli_jll.bw() do bin
            run(`$bin login --apikey`)
        end
    end
end

"""
    extract_session_key(s::String)

Return the session key from the text which is printed to `stdout`.
"""
function extract_session_key(s::String)
    rx = r"BW_SESSION=\"([^\"]*)\""
    m = match(rx, out)
    key = m[1]
end

"""
    bw_unlock(; password=ENV[PASSWORD], set_session_key=true)

Return the session key and set the `$SESSIONKEY` environment variable if `set_session_key`.
"""
function bw_unlock(password=ENV[PASSWORD], set_session_key=true)
    bitwarden_cli_jll.bw() do bin
        io = IOBuffer()
        cmd = `$bw unlock $password`
        run(pipeline(cmd; stdout=io))
        s = String(take!(io))
        key = extract_session_key(s)
        if set_session_key
            ENV[SESSIONKEY] = key
        end
        key
    end
end

"""
    bw_authenticate(
        client_id=ENV[CLIENTID],
        client_secret=ENV[CLIENTSECRET),
        password=ENV[PASSWORD],
        set_session_key=true
    )

Go through the authentication flow and return the session key.
Also, set session key if `set_session_key`.
"""
function bw_authenticate(;
        client_id=ENV[CLIENTID],
        client_secret=ENV[CLIENTSECRET),
        password=ENV[PASSWORD],
        set_session_key=true
    )
    bw_login(; client_id, client_secret)
    bw_unlock(; password)
end
