# IP_RELAY Relay Output Sheet

Target: 4-channel wired IP relay controller using the existing STM32F401RET6 + W5500 + HR911105A design.

Recommended relay architecture:

- MCU: STM32F401RET6
- Network: W5500 Ethernet controller
- Relay driver: ULN2803A or ULN2003A low-side driver
- Relay coil rail: `+12V_RAW`
- Logic rail: `+3V3`
- Ground: `DC_GND`
- Relay outputs: dry contacts through 3-pin terminal blocks: `COM`, `NO`, `NC`

## GPIO Assignment

| Function | STM32 Pin | Net Name | Driver Input |
| --- | --- | --- | --- |
| Relay 1 control | PC0 / pin 8 | `RELAY1_CTRL` | ULN IN1 |
| Relay 2 control | PC1 / pin 9 | `RELAY2_CTRL` | ULN IN2 |
| Relay 3 control | PC2 / pin 10 | `RELAY3_CTRL` | ULN IN3 |
| Relay 4 control | PC3 / pin 11 | `RELAY4_CTRL` | ULN IN4 |

PC0-PC3 are free in the existing STM32/W5500 plan. Keep PA4-PA7 for W5500 SPI, PB0 for W5500 interrupt, and PB1 for W5500 reset.

## ULN2803A Connections

| ULN2803A Pin | Connect To |
| --- | --- |
| IN1 | `RELAY1_CTRL` |
| IN2 | `RELAY2_CTRL` |
| IN3 | `RELAY3_CTRL` |
| IN4 | `RELAY4_CTRL` |
| IN5-IN8 | `DC_GND` or leave unconnected if symbol rules allow |
| OUT1 | `RELAY1_COIL_LOW` |
| OUT2 | `RELAY2_COIL_LOW` |
| OUT3 | `RELAY3_COIL_LOW` |
| OUT4 | `RELAY4_COIL_LOW` |
| OUT5-OUT8 | NC |
| COM | `+12V_RAW` |
| E / GND | `DC_GND` |

COM must go to the relay coil positive rail so the internal flyback diodes clamp correctly.

## Relay Channel Template

Repeat this block 4 times:

| Part | Connection |
| --- | --- |
| Relay coil A1 | `+12V_RAW` |
| Relay coil A2 | `RELAYx_COIL_LOW` from ULN OUTx |
| Relay COM contact | `RLYx_COM` |
| Relay NO contact | `RLYx_NO` |
| Relay NC contact | `RLYx_NC` |
| Output terminal Jx pin 1 | `RLYx_COM` |
| Output terminal Jx pin 2 | `RLYx_NO` |
| Output terminal Jx pin 3 | `RLYx_NC` |

## Relay Indicator LEDs

Use one LED per relay:

| Part | Connection |
| --- | --- |
| R_LEDx | `+12V_RAW` to LED anode, 4.7k typical |
| LEDx cathode | `RELAYx_COIL_LOW` |

When ULN output sinks current, relay and LED turn on together.

## Optional Protection And Debug

- Add a 100nF ceramic capacitor near ULN V/GND area.
- Add a test pad on each `RELAYx_CTRL`.
- Add a test pad on `+12V_RAW`, `+5V`, `+3V3`, and `DC_GND`.
- If switching AC mains on relay contacts, keep relay contact copper isolated from low-voltage logic with at least 6 mm clearance. Use slots where practical.
- Use relay/contact terminal blocks rated for the actual load voltage/current.

## Altium Placement Order

1. Open `iprelaySheet2.SchDoc` or create a new sheet named `Relay_Output.SchDoc`.
2. Place STM32 sheet ports/net labels: `RELAY1_CTRL` to `RELAY4_CTRL`.
3. Place `ULN2803A`.
4. Place four 12V relays.
5. Place four 3-pin 5.08 mm terminal blocks for `COM/NO/NC`.
6. Add four LED indicators with 4.7k resistors.
7. Add power ports: `+12V_RAW`, `DC_GND`.
8. Compile project and fix any duplicate/net-name warnings.

