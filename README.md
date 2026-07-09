# MSPM0C1104 Blinky - GCC + CMake + J-Link

TI LP-MSPM0C1104 LaunchPad LED blinky, built with arm-none-eabi-gcc + CMake + Ninja, flashed via J-Link.

## Prerequisites

- **arm-none-eabi-gcc** (ARM Embedded toolchain)
- **CMake** + **Ninja** (`pip install cmake ninja`)
- **OpenOCD** (xpack-openocd, included in `third_party/openocd/`)
- **TI LP-MSPM0C1104** LaunchPad with onboard XDS110 debugger (USB connected)
- **MSPM0 SDK** placed at `third_party/mspm0-sdk/` (clone from https://github.com/TexasInstruments/mspm0-sdk)

# Quick Start

```powershell
# 1. Source environment (once per session, sets cmake/ninja in PATH)
. C:\Users\YE\.codex\toolchains\setup-mspm0-env.ps1

# 2. Configure + build
cmake --preset mspm0-gcc
cmake --build --preset mspm0-gcc
```

## Toolchain Architecture

Shared toolchain config lives outside the project, reused by all MSPM0 projects:

```powershell
#
# ~/.codex/toolchains/
#   ├── toolchain-arm-none-eabi-gcc.cmake   # cross-compiler paths
#   └── setup-mspm0-env.ps1                 # PATH + env vars
#
# Project-level (this repo):
#   ├── CMakePresets.json                   # references shared toolchain
#   └── CMakeLists.txt                      # project-specific only
```

To start a new MSPM0 project, copy `CMakePresets.json` and adjust the
`MSPM0_SDK_DIR` cache variable; the toolchain file is shared automatically.

Output: `build/blinky.elf`, `build/blinky.bin`, `build/blinky.hex`.

## Flash

The LaunchPad's onboard XDS110 works as a CMSIS-DAP probe via OpenOCD:

```powershell
.\flash_openocd.ps1
```

This uses `interface/cmsis-dap.cfg` + `target/ti_mspm0.cfg` with HID backend
(CMSIS-DAPv2 bulk mode needs WinUSB; HID mode works out of the box).

## Project layout

```
 CMakeLists.txt        build config
flash_openocd.ps1     OpenOCD + XDS110 flash script
src/main.c            blinky application
src/ti_msp_dl_config.c   pin/clock config (pre-generated, no SysConfig needed)
src/ti_msp_dl_config.h
src/startup_mspm0c110x_gcc.c   GCC startup + vector table
ld/mspm0c1104.lds     linker script (16KB Flash / 1KB SRAM)
third_party/mspm0-sdk/ MSPM0 SDK (driverlib.a + headers)
```

## Customize pins

Edit `src/ti_msp_dl_config.c` and `.h` directly - no SysConfig GUI required. Current config toggles `GPIOA.22` (USER_LED_1 on the LaunchPad).
