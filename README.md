# SmartThings Hampton Bay / King of Fans 99432 Stability Edge Driver

A stability-focused SmartThings Edge driver for the Hampton Bay / King of Fans 99432 Zigbee ceiling fan controller.

Supported device identifiers include:

* `HBUniversalCFRemote`
* `HDC52EastwindFan`
* Manufacturer strings:

  * `King Of Fans, Inc.`
  * `King Of Fans,  Inc.`

## Purpose

This driver was created as a minimal, stability-focused alternative for the Hampton Bay / King of Fans Zigbee fan controller.

The goal is to provide:

* Fan On / Off
* Low / Medium / High / Max fan speeds
* Light On / Off
* Light dimming
* Physical remote state synchronization
* Minimal Zigbee traffic
* No polling
* Command state confirmation using delayed readback

## Installation

The easiest way to install the driver is through the SmartThings Driver Channel invitation:

**[Install the Hampton Bay / King of Fans 99432 Stability Driver](https://bestow-regional.api.smartthings.com/invite/Q1jPnegJLV2L)**

1. Open the invitation link while signed into your Samsung / SmartThings account.
2. Enroll your SmartThings hub in the driver channel.
3. Install **CGPT Hampton Bay Fan** on your hub.
4. In the SmartThings app, select **Add device → Scan nearby**.
5. Put the Hampton Bay / King of Fans controller into pairing mode.

### Pairing / Reset

With SmartThings actively scanning, power-cycle the fan controller:

**OFF for approximately 3 seconds → ON for approximately 3 seconds**

Repeat this cycle **5 times**, leaving the fan powered ON after the fifth cycle.

The fan light should blink to indicate that the controller has entered pairing mode.

SmartThings should discover the device using this driver automatically.

## Status

Tested with two Hampton Bay / King of Fans controllers reporting:

`King Of Fans,  Inc. / HBUniversalCFRemote`

Testing confirmed working:

* Fan On / Off
* Low / Medium / High / Max speeds
* Light On / Off
* Light dimming
* SmartThings command state feedback
* Physical remote light On / Off reporting
* Physical remote dimmer reporting
* Physical remote fan-speed reporting

This project is still being evaluated for long-term stability, particularly because these controllers have historically been reported to occasionally drop from Zigbee networks.

## Disclaimer

This is an unofficial community project provided for experimental and personal use. It is not affiliated with, sponsored by, or endorsed by Samsung, SmartThings, Hampton Bay, Home Depot, King of Fans, or OpenAI.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. USE OF THIS DRIVER IS ENTIRELY AT YOUR OWN RISK.

This software communicates with and controls electrical and mechanical equipment, including ceiling fans and lighting. Installation or use may result in unexpected device behavior, loss of connectivity, the need to reset or re-pair devices, or other malfunctions.

To the maximum extent permitted by applicable law, the authors, contributors, testers, publishers, and referenced project maintainers shall not be liable for any claim, damages, property damage, personal injury, device failure, data loss, loss of use, or other liability arising from or related to the installation, use, misuse, inability to use, or operation of this software.

Users are solely responsible for determining whether this software is appropriate for their equipment and environment and for operating and servicing connected equipment safely. Disconnect electrical power before servicing any fan, controller, or other connected electrical equipment.

This driver should not be relied upon for safety-critical functions.

## Attribution

This project was developed with significant reference to the prior SmartThings King of Fans Edge-driver work by **philh30**, including established device fingerprints, Zigbee FanMode mappings, and reporting behavior.

The stability-focused implementation and development guidance for this project were produced interactively with **ChatGPT by OpenAI**.

GitHub user **arren123** performed the real-world hardware testing, validation, and publication of the project and does not claim authorship of the driver implementation.

## License

This project is licensed under the **Apache License 2.0**. See the `LICENSE` file for the complete license terms.
