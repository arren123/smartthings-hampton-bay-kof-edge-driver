\# SmartThings Hampton Bay / King of Fans 99432 Stability Edge Driver



A stability-focused SmartThings Edge driver for the Hampton Bay / King of Fans 99432 Zigbee ceiling fan controller.



Supported device identifiers include:



\- `HBUniversalCFRemote`

\- `HDC52EastwindFan`

\- Manufacturer strings:

&#x20; - `King Of Fans, Inc.`

&#x20; - `King Of Fans,  Inc.`



\## Purpose



This driver was created as a minimal, stability-focused alternative for the Hampton Bay / King of Fans Zigbee fan controller.



The goal is to provide:



\- Fan On / Off

\- Low / Medium / High / Max fan speeds

\- Light On / Off

\- Light dimming

\- Physical remote state synchronization

\- Minimal Zigbee traffic

\- No polling

\- Command state confirmation using delayed readback


## Installation

The easiest way to install the driver is through the SmartThings Driver Channel invitation:

**[Install the Hampton Bay / King of Fans 99432 Stability Driver](https://bestow-regional.api.smartthings.com/invite/eGM6PvJ1VPlA)**

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


\## Credits



This project builds on prior work by \*\*philh30\*\*, whose SmartThings Edge driver for the King of Fans controller provided important reference information including device fingerprints, Zigbee FanMode mappings, and reporting behavior.



The stability-focused driver implementation and development guidance were produced collaboratively with \*\*ChatGPT by OpenAI\*\*.



GitHub user \*\*arren123\*\* performed the real-world hardware testing, validation, and publication of the project and does not claim authorship of the driver implementation.



\## Status



Tested with two Hampton Bay / King of Fans controllers reporting:



`King Of Fans,  Inc. / HBUniversalCFRemote`



Testing confirmed working:



\- Fan On / Off

\- Low / Medium / High / Max speeds

\- Light On / Off

\- Light dimming

\- SmartThings state feedback

\- Physical remote light state reporting

\- Physical remote dimmer reporting

\- Physical remote fan-speed reporting



This project is still being evaluated for long-term stability, particularly because these controllers have historically been reported to occasionally drop from Zigbee networks.



\## License



License information will be added before the first public release.

