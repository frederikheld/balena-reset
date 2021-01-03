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

You can integrate it into the `docker-compose.yml` of your Balena multi-container setup with a simple snippet:

```
services:
    build:
      context: ./reset
    network_mode: "host"
    labels:
      io.balena.features.dbus: '1'
      io.balena.features.sysfs: '1'
    devices:
      - "/dev/ttyS0:/dev/ttyS0"
    cap_add:
      - NET_ADMIN
      - SYS_RAWIO
    environment:
      DBUS_SYSTEM_BUS_ADDRESS: "unix:path=/host/run/dbus/system_bus_socket"
      GPIO_RESET_IN: 10
      GPIO_ACK_OUT: 27
    restart: no
```

This snippet assumes that the `reset` directory is in the same directory as the `docker-compose.yml` of your project, e. g. embedded as a [submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules). If you put it somewhere else, make sure, that `context` points to the actual directory of `reset`!

You can change the GPIO pins to whatever pins you want. Be aware, that those values do not reflect the pin numbers of the GPIO pin header, but the internal numbering of the GPIO connectors of the processor. Please refer to the [RasPi Docs](https://www.raspberrypi.org/documentation/usage/gpio/) for more information on this topic.
