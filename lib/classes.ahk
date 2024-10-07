class Version {
    __New(ScriptVersion) {
        this.ParseVersion(ScriptVersion)
    }

    ParseVersion(ScriptVersion) {
        static RE_SCRIPT__VERSION_DATE_TIME := "^(v(\d+)\.(\d+)\.(\d+)) - (((\d{2})\/(\d{2})\/(\d{4})) \(((\d{2}):(\d{2}))\))$"

        if not RegExMatch(ScriptVersion, RE_SCRIPT__VERSION_DATE_TIME, &matches) {
            throw Error("Invalid 'SCRIPT_VERSION' format.")
        }

        this.FullMatch := matches[0]
        this.Version := matches[1]
        this.MajorVersion := matches[2]
        this.MinorVersion := matches[3]
        this.PatchVersion := matches[4]
        this.DateTime := matches[5]
        this.Date := matches[6]
        this.Day := matches[7]
        this.Month := matches[8]
        this.Year := matches[9]
        this.Time := matches[10]
        this.Hour := matches[11]
        this.Minute := matches[12]

        this.AhkTime := this.Year . this.Month . this.Day . this.Hour . this.Minute
    }
}

class Updater {
    __New(CurrentVersion) {
        this.CurrentVersion := CurrentVersion
    }

    CheckForUpdate(LatestVersion) {
        ; Step 1: Compare major, minor, and patch versions
        if (LatestVersion.MajorVersion > this.CurrentVersion.MajorVersion)
            return True
        else if (LatestVersion.MajorVersion == this.CurrentVersion.MajorVersion) {
            if (LatestVersion.MinorVersion > this.CurrentVersion.MinorVersion)
                return True
            else if (LatestVersion.MinorVersion == this.CurrentVersion.MinorVersion) {
                if (LatestVersion.PatchVersion > this.CurrentVersion.PatchVersion)
                    return True
                else if (LatestVersion.PatchVersion == this.CurrentVersion.PatchVersion) {
                    ; Step 2: Compare date and time if versioning is equal
                    return DateDiff(LatestVersion.AhkTime, this.CurrentVersion.AhkTime, "Seconds") > 0
                }
            }
        }
        return False
    }
}