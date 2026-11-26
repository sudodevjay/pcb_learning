# Barrier Controller: FINAL Spec, Netlist, Placement and Library (v3)

Single source of truth for the board. Use this file and `barrier_controller_final_bom.csv`.

## 0. Final design choices

| Block | Choice | Reason |
|---|---|---|
| MCU | **STM32F446VET6** (LQFP-100) | Library has it (D:\pcb\pcblibrary\Libraries). Higher speed than F407, same LQFP-100 package. |
| Ethernet | **W5500** (SPI, internal MAC + PHY) + **HR911105A** RJ45 with magnetics | F446 has no Ethernet MAC, so W5500 is used. W5500 and HR911105A are in the library. |
| Motor driver | **DRV8302** 3-phase gate driver, 6 external MOSFET | In library. Integrated gate driver, protection and current amp. |
| Relays | **HF115F-024** (24V coil, SPDT, 10 A), 3 pcs (K3, K4, K5) | Same series as the relay in the reference photo. 24V coil matches our 24V supply. |
| RS485 | **MAX3485EESA** (3.3V) | In library. Runs at 3.3V, no level shifter. |
| LCD | **Nokia 5110** (PCD8544), 8-pin header | Your choice. 3.3V module. |
| RF | 433 MHz receiver module on UART4, SMA antenna | Module from your side. |
| Motor | BLDC, 24V DC, 3-phase with Hall | Per DZE-BL manual. |
| Board | 140 x 100 mm, 4-layer | Your choice. |

**Open items (not blocking the layout of other parts):**
1. Motor stall and running current → F2 fuse, MOSFET, shunt, trace width.
2. Hall wire count and colours (expected 5: HA, HB, HC, 5V, GND).
3. Hall commutation order (measure on motor).
4. Board size check against the enclosure.
5. Confirm DRV8302 datasheet: VM range (24V), whether its built-in buck can supply 12V/5V (may remove a buck), bootstrap values, and pin names.

---

## 1. Block list

| Block | Parts |
|---|---|
| Power in | J1 (24V), F1 (control fuse 2 A), F2 (motor fuse), D1 (reverse protection) |
| Rails | 24V→5V buck (LM2596S-5.0), 5V→3.3V LDO (AMS1117-3.3). 12V buck only if DRV8302 needs it (see open item 5). |
| MCU | STM32F446VET6, 8 MHz crystal, NRST, SWD (J2), BOOT0 pull-down |
| Ethernet | W5500 (LQFP-48), 25 MHz crystal, HR911105A RJ45 with magnetics (J10) |
| Motor driver | DRV8302, 6 N-MOSFET bridge, bootstrap parts, gate R and pull-down |
| Motor sense | Low-side shunt (0.005–0.01 Ω), INA180 current amp, 24V sense divider |
| Hall | J9 (5V, HA, HB, HC, GND), pull-ups, series R |
| Field I/O | J4 (STOP, OPEN, CLOSE, LOOP, IR), J5 (LIM_UP, LIM_DN), EL817S1 opto-isolators, TVS |
| RS485 | MAX3485EESA, J7 (A, B, GND), TVS, 120 Ω jumper |
| RF | RF module header J8 (VCC, GND, DATA), SMA ANT1 |
| Relays | K3 (motor power cutoff), K4 (limit / traffic light out to J6), K5 (alarm / lock out to J11). All HF115F-024. |
| UI | SW1–SW4 (SMD 6x6 tact), status LED, buzzer, Nokia 5110 LCD on J12 (8-pin) |

---

## 2. MCU pin plan (STM32F446VET6, by port name)

Pin numbers come from STM32CubeMX. Check each function against the F446 datasheet alternate-function table.

| Function | MCU pins |
|---|---|
| Gate driver PWM (TIM1) | PE9 (CH1 → INHA), PE8 (CH1N → INLA), PE11 (CH2 → INHB), PE10 (CH2N → INLB), PE13 (CH3 → INHC), PE12 (CH3N → INLC) |
| Gate driver enable / fault | PE7 (EN_GATE), PE14 (nFAULT, interrupt input) |
| Hall sensors | PB5 (HA), PB6 (HB), PB8 (HC), EXTI |
| Motor current ADC | PC1 (ADC123_IN11) |
| 24V sense ADC | PC0 (ADC123_IN10) |
| W5500 (SPI1) | PA5 (SCK), PA6 (MISO), PA7 (MOSI), PA4 (CS), PA8 (RST), PA9 (INT) |
| RS485 (USART6) | PC6 (TX), PC7 (RX), PD7 (DE/RE) |
| RF receiver (UART4) | PC10 (TX), PC11 (RX) |
| Wire inputs | PE0 (STOP), PE1 (OPEN), PE2 (CLOSE), PE3 (LOOP), PE4 (IR) |
| Limit inputs | PE5 (LIM_UP), PE6 (LIM_DN) |
| Buttons | PD9 (SW1), PD10 (SW2), PD11 (SW3), PD12 (SW4) |
| Nokia 5110 LCD | PD0 (RST), PD1 (CE), PD3 (DC), PD4 (DIN), PD5 (CLK), PD8 (BL through transistor) |
| Status LED | PD13 |
| Buzzer | PD14 |
| K3 (power cutoff) | PD15 |
| K4 (limit / traffic light) | PD2 |
| K5 (alarm / lock) | PB7 |
| SWD | PA13 (SWDIO), PA14 (SWCLK) |
| Spare | PA0, PA1, PA2, PA3, PA10, PA11, PA12, PA15, PB0, PB1, PB2, PB3, PB4, PB9, PB10, PB11, PB12, PB13, PB14, PB15, PC2, PC3, PC4, PC5, PC8, PC9, PD6 |

Notes:
- Disable JTAG in firmware (keep SWD only) so PA15, PB3, PB4 are free.
- PE14 (nFAULT) and PE7 (EN_GATE) are on the same port as TIM1 pins; no conflict.

---

## 3. Netlist (key nets)

**Power:**
- VIN_24V: J1-1 → F1 → D1 → VBAT_24V (buck inputs, F2 input)
- F2 → VM_24V (DRV8302 VM, bulk caps, MOSFET drains)
- VCC_5V: LM2596 output → relay coils, Hall pull-ups, MAX3485 VCC, RF VCC, buzzer, LCD backlight
- VDD_3V3: AMS1117 output → MCU VDD/VDDA (via ferrite), W5500 VDD, Nokia 5110 VCC, pull-ups

**Gate driver (U2: DRV8302):**
- INHA, INHB, INHC ← PE9, PE11, PE13
- INLA, INLB, INLC ← PE8, PE10, PE12
- EN_GATE ← PE7 (through 10 kΩ pull-down)
- nFAULT → PE14 (10 kΩ pull-up to VDD_3V3)
- GHA/GLA, GHB/GLB, GHC/GLC → gate resistors (10 Ω) → MOSFET gates. Gate-source pull-down 10 kΩ on each MOSFET.
- SHA, SHB, SHC → motor phase nodes (PH_U, PH_V, PH_W)
- Bootstrap caps and diodes per DRV8302 datasheet
- Low-side sources → shunt → GND_PWR
- Motor connector J3: PH_U, PH_V, PH_W

**MOSFET bridge:** Q1/Q2 (U), Q3/Q4 (V), Q5/Q6 (W), IRFZ44N or IRF3205 (TO-220). Add to library if not found (see section 5).

**Motor sense:**
- Shunt (low side) → INA180 → RC filter (1k / 100 nF) → PC1
- 24V divider (100 kΩ / 10 kΩ) → PC0

**Ethernet (W5500):**
- SPI1: PA5 (SCK), PA6 (MISO), PA7 (MOSI), PA4 (CS), PA8 (RST), PA9 (INT)
- W5500 25 MHz crystal
- W5500 TX/RX pairs → HR911105A RJ45 (integrated magnetics), 50 Ω differential
- RJ45 shield → chassis GND through 75 Ω + 4.7 nF

**RS485 (MAX3485EESA):**
- USART6_TX (PC6) → DI, USART6_RX (PC7) ← RO, PD7 → DE and RE (tied)
- A, B → TVS → J7. 120 Ω jumper across A and B (optional).

**RF:**
- UART4_RX (PC11) ← RF DATA (1 kΩ series)
- UART4_TX (PC10) → RF config (optional)
- Module VCC from 5V or 3.3V per module

**Hall (J9):**
- HA → PB5, HB → PB6, HC → PB8. Each 10 kΩ pull-up to 3.3V (divider if sensor is 5V output), 1 kΩ series, TVS.

**Inputs (J4, J5):**
- STOP PE0, OPEN PE1, CLOSE PE2, LOOP PE3, IR PE4, LIM_UP PE5, LIM_DN PE6
- 10 kΩ pull-up to 3.3V, 100 nF, TVS at terminal. LOOP and IR through EL817S1 opto-isolator.

**Nokia 5110 LCD (J12, 8-pin):**
- J12-1 RST → PD0. J12-2 CE → PD1. J12-3 DC → PD3. J12-4 DIN → PD4. J12-5 CLK → PD5.
- J12-6 VCC → VDD_3V3. J12-7 BL → PD8 through 100 Ω and BC848C transistor. J12-8 GND.
- Contrast set in software (no pot).

**UI:**
- SW1..SW4 → PD9..PD12, internal pull-up, to GND
- LED PD13 → 680 Ω → LED → GND
- Buzzer PD14 → 1 kΩ → BC848C → buzzer, 1N4148W flyback

**Relays (HF115F-024):**
- K3 (power cutoff, in series with VIN_24V to motor bridge): PD15 → 1 kΩ → BC848C → K3 coil, flyback diode. Contacts to J6.
- K4 (limit / traffic light): PD2 → 1 kΩ → BC848C → K4 coil, flyback diode. Contacts to J6 (COM, NO, NC).
- K5 (alarm / lock): PB7 → 1 kΩ → BC848C → K5 coil, flyback diode. Contacts to J11 (COM, NO, NC).
- Contacts rated for the load (check alarm or light current).

**SWD:** J2 (3V3, SWDIO PA13, SWCLK PA14, NRST, GND). NRST 10 kΩ pull-up + 100 nF.

**Clock:** 8 MHz crystal on MCU OSC_IN/OSC_OUT with 20 pF each. 25 MHz crystal on W5500 (with its load caps).

---

## 4. Placement and board

- **Board:** 140 x 100 mm, 4-layer. Stackup: Top = signals and components, Layer 2 = solid GND plane, Layer 3 = split power (3.3V, 5V/12V), Bottom = signals and 24V/motor pours.
- **Motor traces:** 2 oz outer copper, 3 mm or wider for 10 A.

| Zone | Contents | Location |
|---|---|---|
| A. Power input | J1, F1, F2, D1, bulk caps | One corner near the 24V terminal |
| B. Motor stage | DRV8302, 6 MOSFET, bootstrap, shunt, J3 | Next to J3, away from MCU and Ethernet |
| C. MCU | STM32F446, crystal, NRST, SWD, LDO | Board center |
| D. Ethernet | W5500, 25 MHz crystal, HR911105A RJ45 | One board edge (RJ45 faces edge) |
| E. Field wiring | J4, J5, J6, J7, J9, EL817S1, TVS, MAX3485 | Edge opposite RJ45, or the edge with J1/J3 |
| F. RF | J8, SMA ANT1 | Third edge, away from motor. No copper under antenna. |
| G. UI | SW1–SW4, LED, buzzer, Nokia 5110 on J12 | Upper half, buttons in a row below the LCD, aligned with enclosure window |

**Layout rules:**
- Power and motor on one edge (J1 and J3 at the two ends). Signal connectors on another edge.
- Motor loop short: bulk caps, high-side MOSFET, low-side MOSFET, shunt.
- MOSFETs at board edge or with copper pour and optional heatsink.
- Crystals within 10 mm of pins, with guard ring. 100 nF per VDD pin on MCU side.
- W5500 SPI traces short. RJ45 pairs 50 Ω differential, over GND plane.
- Ground: solid GND plane (Layer 2). Analog ground (INA180) joined to main ground at the shunt.
- Keep RF and Ethernet away from switching regulators and motor phase traces.
- Mounting holes in four corners, away from heavy parts.

---

## 5. Altium library mapping (final parts)

Library folder: `D:\pcb\pcblibrary\Libraries` (compiled .IntLib, symbol + footprint) and `D:\pcb\pcb_library\altium-library` (symbols and footprints).

| Part | Library file | Status |
|---|---|---|
| STM32F446VET6 | `STM32F446VET6.IntLib` | Found |
| W5500 | `W5500.IntLib` | Found |
| RJ45 with magnetics HR911105A | `HR911105A.IntLib` | Found |
| Relay HF115F | `HF115F_005-1HS3BF_610_.IntLib` (footprint and symbol). Order coil variant **HF115F-024** (24V). | Found. Check coil variant in datasheet. |
| Gate driver DRV8302 | `pcb_library\symbols\Driver - Motor\SCH - DRIVER - MOTOR - TI DRV8302.SCHLIB` | Found (symbol). Footprint: check in same library. |
| RS485 MAX3485EESA | `MAX3485EESA_.IntLib` | Found |
| 5V buck LM2596S-5.0 | `LM2596S-5.0.IntLib` | Found |
| 3.3V LDO AMS1117-3.3 | `AMS1117-3.3.IntLib` | Found |
| Optocoupler EL817S1 | `OPTOCOUPLER EL817S1.IntLib` | Found |
| Current amp INA180 | `pcb_library\symbols\Current Shunt Amplifier\...INA180A DBV.SCHLIB` | Found (symbol) |
| TVS | `TVS_BiDir 1.5SMC6.8CA`, `SMAJ` (step), `TVS DIODE SOT-23 SM712` | Found. For 24V use SMAJ24A if available. |
| Transistor BC848C | `NPN SOT-23 SMT BC848C_RFG.IntLib` | Found |
| Diodes 1N4148W, SS34, BAT54C | `DIODE 1N4148W SOD-80...IntLib`, `SS34.IntLib`, `Diode_schottky_sot23_BAT54C.IntLib` | Found |
| MOSFET N-channel low-side | `IRF TO-263-7` (pcb_library). IRFZ44N TO-220 not found. | Add TO-220 part or use TO-263 IRF |
| Tact switch SMD 6x6 | `PUSHBUTTON_SMD_6 x 6 mm, 6.5 mm.IntLib` | Found |
| Terminal blocks | `2 Pin / 3 Pin / 4 Pin Terminal Block HDR 5MM THT RA ...` | Found |
| Fuse holder | `FUSE HOLDER 5x20 Schurter 0031.8201.IntLib` | Found |
| Nokia 5110 | Not in library. Use 8-pin 2.54 mm header (J12). | Header only |
| Crystal 8 MHz | `CSTNE8M00G55A000R0.IntLib` | Found |
| Crystal 25 MHz | `Crystal 25 Mhz SMD 2 pin`, used in your earlier W5500 LAN project (`D:\pcb\QR SCANNER NEW\LAN 485.SchDoc`) | Found in your project. Reuse from that project. |
| LCD 16x2 (not used) | `LCD_1602_2X16_BLUE-WHITE.IntLib` | Not used |

**Existing schematic sheets:** `barriercontrollerSheet1.SchDoc` and `barriercontrollerSheet2.SchDoc` could not be read here (binary). Open them in Altium and reuse the placed parts where they match this spec.

---

## 6. Firmware plan
- CubeMX: TIM1 complementary PWM (6 channels) with dead-time. EN_GATE and nFAULT GPIO. EXTI on Hall. ADC on PC0 and PC1. SPI1 for W5500. USART6 for RS485. UART4 for RF. Disable JTAG (SWD only).
- DRV8302: configure gate drive mode and current-sense gain/limit per datasheet.
- Motor states: IDLE, OPENING, OPEN, CLOSING, CLOSED, STOPPED, FAULT.
- Commutation: Hall 6-step, speed from Hall edge timing, PWM duty ramp.
- Learning mode for UP and DOWN limits.
- Obstruction: motor current limit, auto-reverse.
- Brake: all low-side MOSFETs on.
- Priority: FAULT > STOP > OPEN/CLOSE > remote > LAN command.
- Parameters in flash.
- Ethernet: W5500 socket driver (TCP/IP in hardware), simple web config and Modbus TCP or REST (choose later).
- RS485: Modbus RTU slave.

---

## 7. Control inputs and buttons

**External dry-contact control:** OPEN, CLOSE, STOP are dry-contact inputs (active low, one side to input, other side to COM). LOOP and IR are opto-isolated. LIM_UP and LIM_DN are limit switches. Each input can be set in firmware as pulse or hold, NO or NC.

**Front-panel buttons (reference-manual style):**

| Button | Normal mode | Menu mode |
|---|---|---|
| SW1 = UP / + | Open | Increase value |
| SW2 = DOWN / − | Close | Decrease value |
| SW3 = STOP / QUIT | Stop | Cancel, go back |
| SW4 = MENU / CONFIRM | Long press 2 s enters menu | Next or save |

Advanced menu: hold MENU and QUIT for 2 s.

---

## 8. Relay roles (3 pcs, HF115F-024)
- **K3, motor power cutoff:** in series with 24V to the motor bridge. Emergency or fault stop.
- **K4, limit / traffic light:** external signal output (COM, NO, NC). Modes like H-16 in the manual.
- **K5, alarm / lock:** external alarm or lock output (COM, NO, NC).
- Relays are not used for motor direction or brake. Those are done by the MOSFET bridge.

---

## 9. BOM
Full list: `barrier_controller_final_bom.csv`.
