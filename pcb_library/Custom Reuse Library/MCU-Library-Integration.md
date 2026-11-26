# MCU Library Integration

Prepared source packages:

| Family | Package | Status |
| --- | --- | --- |
| STM32 | `D:\pcb_library\altium-library\Celestial MCU STM32.LibPkg` | Ready to open/compile in Altium |
| ATMEGA / ATTINY / AVR | `D:\pcb_library\altium-library\Celestial MCU AVR ATMEGA ATTINY.LibPkg` | Ready to open/compile in Altium |
| ESP32 / Espressif | `D:\pcb_library\altium-library\Celestial MCU ESP32.LibPkg` | Ready to open/compile in Altium |
| PIC16 / PIC18 / PIC24 / PIC32 / dsPIC | External exact-MPN download required | Not present in local Celestial clone |

Open all ready packages together:

`D:\pcb_library\altium-library\Celestial MCU Library Suite.DsnWrk`

## Compile In Altium

1. Open `Celestial MCU Library Suite.DsnWrk`.
2. In the Projects panel, right-click each `.LibPkg`.
3. Click `Compile Integrated Library`.
4. Install the generated `.IntLib` files from each `Project Outputs for ...` folder.

Altium normally auto-installs compiled `.IntLib` files when `Open outputs after compile` is enabled.

## PIC Download Route

PIC libraries should be acquired by exact orderable part number. Family names like `PIC16` are too broad and include thousands of package/temperature/memory variants.

Recommended sources:

1. Altium `Manufacturer Part Search` panel: search exact MPN and use `Download as File Library`.
2. Microchip product page: use `View CAD Symbols`.
3. SnapMagic Search: download Altium format.
4. Ultra Librarian: download Altium Designer output.

After downloading a PIC `.IntLib`, store it under:

`D:\pcb_library\Custom Reuse Library\Project IntLibs\PIC\`
