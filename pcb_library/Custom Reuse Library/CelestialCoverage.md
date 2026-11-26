# Celestial Coverage Check

Checked against:

`D:\pcb_library\altium-library\Altium Database Library V2.DbLib`

Status:

- Database connection: OK
- SQLNCLI11.1 provider: installed
- Altium integration file: ready

## Requested Searches

| Family/Search | Result |
| --- | --- |
| `STM32F401RE` | Found. Examples: `STM32F401RET6`, `STM32F401RET6TR` |
| `STM32` | Found. 315 microcontroller matches plus RF STM32WL entries |
| `relay` | Found. Tables include `Relays - Power - Over 2 Amps`, `Relays - Solid State` |
| `transistor` | Found. Tables include BJT, MOSFET, optoisolator transistor categories |
| `ESP32` | Found. Examples: `ESP32-WROOM-32D`, `ESP32-C3-MINI-1-N4`, `ESP32-D0WD` |
| `ATTINY` | Found. 27 microcontroller matches |
| `ATMEGA` | Not found in current Celestial database check, but 491 raw Celestial `.SchLib` files are already cloned under `symbols\MCU - ATMEGA` |
| `PIC16/PIC18/PIC24/PIC32/dsPIC` | Not found in current Celestial database check |

## Practical Meaning

Altium Components search will show installed Celestial DbLib parts that exist in the Celestial database, plus any installed per-project `.IntLib` files from:

`D:\pcb_library\Custom Reuse Library\Project IntLibs`

For families not present in the installed DbLib search, create/import them once, then save that project as an `.IntLib` using:

`Design > Make Integrated Library`

After that, those parts will be reusable from the project `.IntLib`.

ATMEGA note: use the focused source package:

`D:\pcb_library\altium-library\Celestial MCU AVR ATMEGA ATTINY.LibPkg`

It contains 491 ATMEGA/AVR source documents extracted from the full Celestial package. The raw `.SchLib` files are under:

`D:\pcb_library\altium-library\symbols\MCU - ATMEGA`

PIC note: PIC16/PIC18/PIC24/PIC32/dsPIC source files were not found in the cloned Celestial library, so acquire exact part numbers through Altium Manufacturer Part Search, Microchip CAD/CAE Symbols, SnapMagic, or Ultra Librarian.
