# Missing Microchip MCU Download Guide

## ATMEGA / AVR

ATMEGA/AVR files are already present locally from the Celestial GitHub library, but they are not exposed by the current Celestial DbLib search.

Local source:

`D:\pcb_library\altium-library\symbols\MCU - ATMEGA`

Best practical route:

1. Open the focused package:
   `D:\pcb_library\altium-library\Celestial MCU AVR ATMEGA ATTINY.LibPkg`
2. Search/filter for the required ATMEGA part.
3. Use or compile the relevant source library into an `.IntLib`.
4. Save the resulting `.IntLib` under:
   `D:\pcb_library\Custom Reuse Library\Project IntLibs`

Fallback: the full Celestial source package is:

`D:\pcb_library\altium-library\Celestial Library.LibPkg`

## PIC16 / PIC18 / PIC24 / PIC32 / dsPIC

PIC families were not found in the local Celestial clone. Download exact part numbers from one of these sources:

1. Altium Designer: `View > Panels > Manufacturer Part Search`
   - Search exact MPN, for example `PIC16F877A-I/P`.
   - Right-click result and use `Download as File Library`, or place it and later run `Design > Make Integrated Library`.

2. Microchip CAD/CAE Symbols
   - Go to the exact Microchip product page.
   - Use `View CAD Symbols`.
   - Choose Altium format if available.

3. SnapMagic Search
   - Search exact MPN.
   - Download Altium format, preferably native `.IntLib` if offered.

4. Ultra Librarian
   - Search exact MPN.
   - Download Altium Designer output.
   - Import using the included Ultra Librarian Altium script when needed.

Important: download by exact orderable part number, not only family name. Example: use `PIC16F877A-I/P`, `PIC18F4550-I/PT`, `PIC32MX795F512L-80I/PT`, etc.
