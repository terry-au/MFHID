# MFHID
A support layer to bridge MFI controllers into the more widely supported HID interface.
## Why?
Support for MFI controllers is rather lacking. Especially given that MFI controller support has  been supported since [OS X Mavericks](https://developer.apple.com/reference/gamecontroller).
## Information
MFHID makes direct use of the GameController framework but overrides methods used to disable controller input when the application is not in the foreground. Support for the SteelSeries Nimbus has been tested and working, however, the code aims to comply with the standard and extended gamepad configurations, thus different gamepads should be supported.
## Compatibility
MFHID has been tested with the SteelSeries Nimbus but should support all other MFI controllers, at the very least the "extended" (13 button) subset of controllers.

Due to the way the GameController framework and the MFI specification was developed, there is no support for hold states for the pause/play/menu button, as such, MFIHID simply sends out a fast pulse that toggles the button on then off quickly, simulating a quick button tap.

Support for pressure sensitive buttons is not present currently, this may be added in future.

Configuring thumb-stick dead-zones is possible through the settings tab, each stick may be configured independently.

MFHID will automatically attempt to resolve Foohid driver issues it may encounter, such as when the driver has not been installed or if it has been stopped. This requires root privileges (to execute kextload). The source of these calls is the mfihid_helper utility included within MFHID (the source for this is present in this repository).
## Building
[Foohid](https://github.com/unbit/foohid/releases) is a requirement and is used to directly interface with MFHID. Version 0.2.1 is confirmed to be working. Building straight from Xcode should be an applicable solution.
## Thanks
* [Foohid](https://github.com/unbit/foohid/)
* [STPrivilegedTask](https://github.com/sveinbjornt/STPrivilegedTask)
## Donate
MFHID is free software, any donations are greatly appreciated but not required. Those wishing to donate may do so [here](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=DCPZ7LNKWPN6W&lc=AU&item_name=terry1994&item_number=MFHID&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted).


## License
MFHID is licensed under the GPL v3 license. A copy of this license may be found in [here](LICENSE.md).
