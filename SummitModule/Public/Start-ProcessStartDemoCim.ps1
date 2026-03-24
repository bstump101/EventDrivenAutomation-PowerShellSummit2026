function Start-ProcessStartDemoCim {
    Write-Host "[Demo] Registering CIM process start event..." -ForegroundColor Cyan

    Register-CimIndicationEvent -ClassName Win32_ProcessStartTrace -SourceIdentifier ProcStart -Action {
        Write-Host "Process started: $($Event.SourceEventArgs.NewEvent.ProcessName)" -ForegroundColor Yellow
    }

    Get-EventSubscriber | Format-Table -AutoSize
}
