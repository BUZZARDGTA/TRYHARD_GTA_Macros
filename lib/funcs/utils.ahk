WebRequest(method, url) {
    whr := ComObject("WinHttp.WinHttpRequest.5.1")

    whr.Open(method, url, true)
    whr.Send()
    ; Using 'true' above and the call below allows the script to remain responsive.
    whr.WaitForResponse()

    return { Status: whr.Status, Text: whr.ResponseText }
}

Pluralize(count, singular, plural := "") {
    if count > 1 {
        return plural ? plural : singular . "s"
    }
    return singular
}

InArray(value, arr) {
    for element in arr {
        if (value == element)
            return true
    }
    return false
}

Print(str) {
    if DEBUG_ENABLED {
        OutputDebug("[" . A_ScriptName . "]: " . str)
    }
}
