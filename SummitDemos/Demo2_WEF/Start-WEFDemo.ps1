function Start-WEFDemo {

    # Clean slate
    Get-EventSubscriber | Where-Object SourceIdentifier -like 'WEF_Demo*' |
        Unregister-Event -ErrorAction SilentlyContinue
    Get-Event | Remove-Event -ErrorAction SilentlyContinue

    # Ensure the source exists
    New-EventLog -LogName Application -Source SummitWEF -ErrorAction SilentlyContinue

    # Build query for Application log
    $query = New-Object System.Diagnostics.Eventing.Reader.EventLogQuery(
    "Application",
    [System.Diagnostics.Eventing.Reader.PathType]::LogName,
    "*[System[Provider[@Name='SummitWEF']]]"
)


    # Create watcher
    $global:WEFWatcher = New-Object System.Diagnostics.Eventing.Reader.EventLogWatcher(
        $query,
        $null,
        $true
    )

    # Register handler
    Register-ObjectEvent -InputObject $global:WEFWatcher -EventName EventRecordWritten -SourceIdentifier WEF_Demo -Action {
        try {
            $rec = $Event.SourceEventArgs.EventRecord
            $msg = $rec.FormatDescription()
            if (-not $msg) { $msg = "[No message available] Event ID: $($rec.Id)" }
        }
        catch {
            $msg = "[Unformatted event] Event ID: $($rec.Id)"
        }

        Write-Host "📨 FORWARDED EVENT (simulated): $msg" -ForegroundColor Cyan
    } | Out-Null

    # Start watching
    $global:WEFWatcher.Enabled = $true

    Write-Host "`n📡 WEF Demo is LIVE. Listening on Application log..." -ForegroundColor Green
    Write-Host "Simulate a forwarded event with:" -ForegroundColor DarkGray
    Write-Host "  Write-EventLog -LogName Application -Source SummitWEF -EventId 1000 -EntryType Information -Message 'Hello Summit!'" -ForegroundColor DarkGray
}
