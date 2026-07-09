$ErrorActionPreference = "Stop"

$exe = "$PSScriptRoot\third_party\openocd\xpack-openocd-0.12.0-7\bin\openocd.exe"
$scripts = "$PSScriptRoot\third_party\openocd\xpack-openocd-0.12.0-7\openocd\scripts"
$hex = "$PSScriptRoot\build\blinky.hex"

if (-not (Test-Path $hex)) {
    Write-Host "build/blinky.hex not found. Run: cmake --build build" -ForegroundColor Red
    exit 1
}

Write-Host "Flashing $hex via OpenOCD + XDS110 (CMSIS-DAP HID)..." -ForegroundColor Cyan

# Run from build/ dir with relative filename to avoid space-in-path issues
Push-Location "$PSScriptRoot\build"
& $exe -s $scripts `
    -f interface/cmsis-dap.cfg `
    -f target/ti_mspm0.cfg `
    -c "adapter speed 4000" `
    -c "cmsis-dap backend hid" `
    -c "init" `
    -c "reset halt" `
    -c "flash write_image erase blinky.hex" `
    -c "reset run" `
    -c "shutdown"
$code = $LASTEXITCODE
Pop-Location

if ($code -ne 0) {
    Write-Host "OpenOCD exited with code $code (may still have flashed OK)" -ForegroundColor Yellow
} else {
    Write-Host "Flash complete!" -ForegroundColor Green
}
