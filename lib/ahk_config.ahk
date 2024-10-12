ProcessSetPriority("High")
try {
    ProcessSetPriority("High", "GTA5.exe")
} catch error as err {
    if not (err.What == "ProcessSetPriority" and err.Message == "Target process not found.") {
        Throw err
    }
}
SetTitleMatchMode(3)
SetStoreCapsLockMode(0)
KeyHistory(0)
ListLines(0)
