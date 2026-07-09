cmake_minimum_required(VERSION 3.20)

# ---- Toolchain paths (override with -D on configure) ----
set(GCC_ARM_TOOLCHAIN
    "C:/Users/YE/AppData/Local/stm32cube/bundles/gnu-tools-for-stm32/14.3.1+st.2"
    CACHE PATH "arm-none-eabi-gcc root")
set(MSPM0_SDK_DIR
    "${CMAKE_CURRENT_SOURCE_DIR}/third_party/mspm0-sdk"
    CACHE PATH "MSPM0 SDK root")

# ---- Cross compiler (must be set before project()) ----
set(CMAKE_SYSTEM_NAME      Generic)
set(CMAKE_SYSTEM_PROCESSOR cortex-m0plus)
set(CMAKE_C_COMPILER   "${GCC_ARM_TOOLCHAIN}/bin/arm-none-eabi-gcc.exe")
set(CMAKE_ASM_COMPILER "${GCC_ARM_TOOLCHAIN}/bin/arm-none-eabi-gcc.exe")
set(CMAKE_OBJCOPY      "${GCC_ARM_TOOLCHAIN}/bin/arm-none-eabi-objcopy.exe")
set(CMAKE_SIZE         "${GCC_ARM_TOOLCHAIN}/bin/arm-none-eabi-size.exe")
set(CMAKE_AR           "${GCC_ARM_TOOLCHAIN}/bin/arm-none-eabi-ar.exe")
set(CMAKE_RANLIB       "${GCC_ARM_TOOLCHAIN}/bin/arm-none-eabi-ranlib.exe")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

project(mspm0c1104_blinky C ASM)

# ---- MCU flags ----
set(MCU_FLAGS
    -mcpu=cortex-m0plus
    -march=armv6-m
    -mthumb
    -mfloat-abi=soft)

# ---- MSPM0 driverlib source files (compile from SDK source, no prebuilt lib) ----
file(GLOB DRIVERLIB_SRC
    "${MSPM0_SDK_DIR}/source/ti/driverlib/*.c"
    "${MSPM0_SDK_DIR}/source/ti/driverlib/m0p/*.c"
    "${MSPM0_SDK_DIR}/source/ti/driverlib/m0p/sysctl/*.c")

# ---- Target ----
add_executable(blinky.elf
    src/main.c
    src/ti_msp_dl_config.c
    src/startup_mspm0c110x_gcc.c
    ${DRIVERLIB_SRC})

target_include_directories(blinky.elf PRIVATE
    src
    "${MSPM0_SDK_DIR}/source"
    "${MSPM0_SDK_DIR}/source/third_party/CMSIS/Core/Include"
    "${GCC_ARM_TOOLCHAIN}/arm-none-eabi/include/newlib-nano"
    "${GCC_ARM_TOOLCHAIN}/arm-none-eabi/include")

target_compile_definitions(blinky.elf PRIVATE __MSPM0C1104__)

target_compile_options(blinky.elf PRIVATE
    ${MCU_FLAGS}
    -O2
    -std=c99
    -ffunction-sections
    -fdata-sections
    -g
    -gstrict-dwarf
    -Wall)

target_link_options(blinky.elf PRIVATE
    ${MCU_FLAGS}
    -nostartfiles
    -T${CMAKE_CURRENT_SOURCE_DIR}/ld/mspm0c1104.lds
    -Wl,-Map,${CMAKE_CURRENT_BINARY_DIR}/blinky.map
    -static
    -Wl,--gc-sections
    -L${MSPM0_SDK_DIR}/source
    -L${GCC_ARM_TOOLCHAIN}/arm-none-eabi/lib/thumb/v6-m/nofp
    -lgcc -lc -lm
    --specs=nano.specs
    --specs=nosys.specs)

# ---- Generate .bin / .hex + size report ----
add_custom_command(TARGET blinky.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary
            $<TARGET_FILE:blinky.elf> ${CMAKE_CURRENT_BINARY_DIR}/blinky.bin
    COMMAND ${CMAKE_OBJCOPY} -O ihex
            $<TARGET_FILE:blinky.elf> ${CMAKE_CURRENT_BINARY_DIR}/blinky.hex
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:blinky.elf>)
