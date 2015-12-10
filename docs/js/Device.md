### Device

Get information about the current device.

```coffee
Device = require("lib/device")
```

```
Device.dpi = window.devicePixelRatio or 1

Device.events =
  pointer:
    isTouch # isTouch
    start   # "touchstart" or "mousedown"
    move    # "touchmove" or "mousemove"
    end     # "touchend" or "mouseup"

  resize    # "orientationchange" or "resize"

Device.isSmallScreen() # true for screens under the css @media breakpoint
```
