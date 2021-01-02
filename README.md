# Reset

This service resets all stored WiFi network connections. It is an addition to [Balena's `wifi-connect` service](https://github.com/balena-io/wifi-connect) which is lacking this functionality.

## Why?

If the user wants to connect to a different wifi and doesn't have access to the box via their own wifi (e. g. because they changed their wifi setup and forgot to update the box before the new setup went active), they can't change the wifi credentials via the app. In this case, they can unplug the box and hold the reset button while booting it up again.

## How?

This service will pick up the reset signal from the configured GPIO pin and run the `reset.sh` script.

> WARNING: Do NOT run this script on your computer! It will do what it was designed for: delete all your stored WiFi connections. This is probably not what you want on your computer!

This service might be expanded to reset other things like data volumes etc.

## What?

This service itself is a simple shell script. See the comments in the script to understand what it does and how it works!

To understand how this service communicates with the host system, have a look into the [Balena Services Masterclass](https://github.com/balena-io/services-masterclass).
