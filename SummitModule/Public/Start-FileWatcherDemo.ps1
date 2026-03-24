function Show-WEFDemoCode {
@'
# WEF Demo (Simulated) – PowerShell reacting to forwarded-style events

# Ensure the event source exists
New-EventLog -LogName Application -Source SummitWEF -ErrorAction SilentlyContinue

# Subscribe only to events from the SummitWEF provider
$query = New-Object System.Diagnostics.Eventing.Reader.EventLogQuery(
    "Application",
    [System.Diagnostics.Eventing.Reader.PathType]::LogName,
    "*[System[Provider[@Name='SummitWEF']]]"
)

# Create the watcher (subscribe-only mode)
$watcher = New-Object System.Diagnostics.Eventing.Reader.EventLogWatcher(
    $query,
    $null,
    $true
)

# Register the event handler
Register-ObjectEvent -InputObject $watcher -EventName EventRecordWritten -SourceIdentifier WEF_Demo -Action {
    try {
        $rec = $Event.SourceEventArgs.EventRecord
        $msg = $rec.FormatDescription()
        if (-not $msg) { $msg = "[No message available] Event ID: $($rec.Id)" }
    }
    catch {
        $msg = "[Unformatted event] Event ID: $($rec.Id)"
    }

    Write-Host "FORWARDED EVENT (simulated): $msg"
}

# Start watching
$watcher.Enabled = $true

# Simulate a forwarded event
Write-EventLog -LogName Application -Source SummitWEF -EventId 1000 -EntryType Information -Message "Hello Summit!"
'@ | Write-Host -ForegroundColor Gray
}
