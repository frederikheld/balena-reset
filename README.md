# Balena Reset

This service is intended for Raspberry Pi devices (tested with Raspberry Pi 4) running [Balena OS](https://www.balena.io/os/). If the user presses the reset button during startup, it will delete all stored WiFi connections. This service is an addition to [Balena's `wifi-connect` service](https://github.com/balena-io/wifi-connect), which is lacking this functionality.

## Why?

If the Balena device does not connect to the user's WiFi anymore (e.g. because it was misconfigured or the configured WiFi is not within reach), the user might want to configure a new WiFi. This can be done with the `wifi-connect` service, but in order for this service to come up and open the captive portal, all WiFi connections have to be deleted first. This is what the `balena-reset` service does.

## How?

At startup, the service will run the script `reset.sh`. It will check, the signal on `GPIO_RESET_IN`.

If the signal is `HIGH`, the script will delete all stored WiFi connections and then confirm the deletion by flashing the LED wired to `GPIO_ACK_OUT` three times.

If the signal is `LOW`, the script will terminate without any action.

Activity will be logged to `STDOUT` for debugging via BalenaCloud and `balena-cli`, and `/dev/ttyS0` (GPIO14 & GPIO15) for debugging while the device is offline.

After the script was run, the service will terminate. It will come up again at next boot of the device.

If the stored WiFi connections were successfully deleted, the `wifi-connect` service will come up on next boot and will open the captive portal where the user can configure a new host WiFi.

> WARNING: Do NOT run the `reset.sh` script on your computer! It will do what it was designed for: delete all your stored WiFi connections. This is most probably not what you want on your computer! For debugging, comment out the line `nmcli connection delete $line`.

This service can be expanded to reset other things like data volumes etc.

## What?

You can integrate this service into your Balena multi-container setup by adding this snippet to your `docker-compose.yml`:

```
services:
  reset:
    build:
      context: ./balena-reset
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

This snippet assumes that the `balena-reset` directory is in the same directory as the `docker-compose.yml` of your project, e. g. embedded as a [submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules). If you put it somewhere else, make sure, that `context` points to the actual directory of `balena-reset`!

You can change the GPIO pins to whatever pins you want. Be aware, that those values do not reflect the pin numbers of the GPIO pin header, but the internal numbering of the GPIO connectors of the processor. Please refer to the [RasPi docs](https://www.raspberrypi.org/documentation/usage/gpio/) for more information on this topic.

This service itself is a [simple shell script](reset.sh). See the comments in the script to understand what it does and how it works!

To understand how this service communicates with the host system, have a look into the [Balena Services Masterclass](https://github.com/balena-io/services-masterclass).

##  License

This software is licensed under MIT. See the [LICENSE](LICENSE) file for more information.

## Contribution

Feel free to submit issues and pull requests that imrove this service :-)

With your submission you agree to the terms stated in the [LICENSE](LICENSE) file.
