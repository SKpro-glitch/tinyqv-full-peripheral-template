<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

The peripheral index is the number TinyQV will use to select your peripheral.  You will pick a free
slot when raising the pull request against the main TinyQV repository, and can fill this in then.  You
also need to set this value as the PERIPHERAL_NUM in your test script.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# Mult Sensor Response Checker

Author: Soham Sunil Kapur

Peripheral index: 07

## What it does

Explain what your peripheral does and how it works

This peripheral allows the user to set a proximity limit for multiple ultrasonic sensors, and triggers an interrupt if that limit is breached.

It facilitates the connection of upto 32 Ultrasonic Sensors.
Other than the I/O signals connecting to the CPU, it has 32 'trig' signals and 32 'echo' signals.
Each trig and echo signal connects to the trig and echo of its respective Ultrasonic sensor.
The user can set which pins have active sensors on them, and which do not.
All 32 sensor pins need not be used, but unused sensor pins must be deactivated.
This will avoid reading invalid values when echo signals are being read.

The proximity limit can be set by the user. This limit is the number of clock cycles.
The conversion of distance to number of clock cycles in time has to be done by the CPU.
This allows flexibility in case of using different speed of sound, or different clock speeds.

Modes:
  0: Off - Device does not function.
  1: Set - User can set the limit.
  2: Activate - User can set which sensor pins to activate.
  3: Run - The device shoots a high on every trig line and starts readin echo at every clock cycle


This peripheral is primarily aimed at Ultrasonic Sensors, but can be used with any other sensor that follows the same system as 'trig' and 'echo' signals.

## Register map

Document the registers that are used to interact with your peripheral

| Address | Name  | Access | Description                                                         |
|---------|-------|--------|---------------------------------------------------------------------|
| 0x00    | DATA  | R/W    | A word of data                                                      |

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
