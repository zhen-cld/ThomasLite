### DraggyView

DraggyView abstracts dragging functionality across all of Thomas's
templates. It can be bound to a rectangle, locked on an axis or constrained
to a circle. It's important to note that DraggyView doesn't actually
transform the element, it merely provides evented feedback of it's
interaction. Listen to it's drag and drop events and manipulate the view as
necessary, whether it be transforming a child, the view itself or adding
dropping logic rules.

```coffee
DraggyView = require("views/components/draggy")
```

Properties:

```
  draggy.x: Current x position
  draggy.y: Current y position
  draggy.t: Current rotation (theta) adjusted to the *top of the circle*
```

These attributes are also available as data attributes on draggy.el.

DraggyView also keeps track of the velocity of the user's movement.

```
draggy.velocity:
  x: horizontal pixel movement per ms
  y: vertical pixel movement per ms
  t: angle of movement
  dir: "up", "right", "down", "left" or "none"
```

Velocity is a measurement of movement occuring in the last 300ms.
Use `getVelocity(ms)` to include movement over a different duration.

Public methods:

```coffee
  draggy.lock()
  draggy.unlock()
  draggy.isWithin(bounds)
  draggy.distanceTo(x, y, opts)
  draggy.reset({x, y, t})
  draggy.getVelocity(ms)
```

Events:

```
  drag: (draggy, isFirstDrag)
  drop: (draggy)
```

Options:

```
  minX: Minimum x position
  maxX: Maximum x position
  minY: Minimum y position
  maxY: Maximum y position
  lock: "x" or "y"
  radius: Radius of circular bounds
  isParent: False if the element transforms, true if a child will instead
  allowPropagation: Stop immediate event propagation on touch start
```
