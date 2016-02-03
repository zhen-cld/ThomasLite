###
  DraggyView abstracts dragging functionality across all FITContentEngine's
  templates. It can be bound to a rectangle, locked on an axis or constrained
  to a cicle. It's important to note that DraggyView doesn't actually
  transform the element, it merely provides evented feedback of it's
  interaction. Listen to it's drag and drop events and manipulate the view as
  necessary, whether it be transforming a child, the view itself or adding
  dropping logic rules.

  Properties:
    draggy.x: Current x position
    draggy.y: Current y position
    draggy.t: Current rotation (theta) adjusted to the *top of the circle*

    These attributes are also available as data attributes on draggy.el.

    draggy.velocity:
      x: horizontal pixel movement per ms
      y: vertical pixel movement per ms
      t: angle of movement
      dir: "up", "right", "down", "left" or "none"

    Velocity is a measurement of movement occuring in the last 300ms.
    Use getVelocity(ms) to include movement over a different duration.

  Public methods:
    draggy.lock()
    draggy.unlock()
    draggy.isWithin(bounds)
    draggy.distanceTo(x, y, opts)
    draggy.reset({x, y, t})
    draggy.getVelocity(ms)

  Events:
    drag: (draggy, isFirstDrag)
    drop: (draggy)

  Options:
    minX: Minimum x position
    maxX: Maximum x position
    minY: Minimum y position
    maxY: Maximum y position
    lock: "x" or "y"
    radius: Radius of circular bounds
    isParent: False if the element transforms, true if a child will instead
    allowPropagation: Stop immediate event propagation on touch start
###

{ events: { pointer } } = require("lib/device")
Easie = require("lib/easie")

class DraggyView extends Backbone.View

  initialize: (@options) ->
    @x = @el.dataset.x = 0
    @y = @el.dataset.y = 0

    @velocity = {}

    @getOffset()

  events: ->
    events = {}
    events[pointer.start] = "onStart"
    return events

  bindExtra: ->
    document.addEventListener(pointer.move, this, false)
    document.addEventListener(pointer.end, this, false)

  unbindExtra: ->
    document.removeEventListener(pointer.move, this, false)
    document.removeEventListener(pointer.end, this, false)

  handleEvent: (e) ->
    switch e.type
      when pointer.move
        e.preventDefault()
        @onMove(e)
        break
      when pointer.end
        @onEnd(e)
        break

  undelegateEvents: ->
    @unbindExtra()
    super

  onStart: (e) ->
    return if @locked

    e.stopImmediatePropagation() unless @options.allowPropagation

    @el.classList.add("active")
    @el.style.zIndex = 99

    @history = []

    @getOffset()
    @getStart(e)
    @onMove(e)
    @bindExtra()

  onMove: (e) ->
    _e = if pointer.isTouch then e.touches[0] else e

    {@x, @y, @t} = @constrain
      x: _e.pageX - @start.x
      y: _e.pageY - @start.y
      buffer: 20

    @getVelocity()

    @trigger("drag", this, e.type is pointer.start)

  onEnd: (e) ->
    @unbindExtra()

    {@x, @y, @t} = @constrain({@x, @y, buffer: 0})

    @el.dataset.x = @x
    @el.dataset.y = @y
    @el.dataset.t = @t

    @el.classList.remove("active")
    @el.style.zIndex = ""

    @trigger("drop", this)

  # `getBoundingClientRect` returns an immutable object, so it's necessary to
  # get and set attributes. We'll also subtract the current position if the
  # draggy isn't a parent (and has transforms directly applied)
  getOffset: ->
    {top, left, right, bottom, width, height} = @el.getBoundingClientRect()

    @offset =
      top: top - (if @options.isParent then 0 else @y)
      left: left - (if @options.isParent then 0 else @x)
      right: right - (if @options.isParent then 0 else @x)
      bottom: bottom - (if @options.isParent then 0 else @y)
      width: width
      height: height

  getStart: (e) ->
    _e = if pointer.isTouch then e.touches[0] else e

    @start =
      x: _e.pageX - @x
      y: _e.pageY - @y

    if @options.isParent
      @start.x += @x + @offset.left - _e.pageX
      @start.y += @y + @offset.top  - _e.pageY

    if @options.radius
      @start.x += @options.radius
      @start.y += @options.radius

  getVelocity: (ms = 300) ->
    now = Date.now()

    @history.push { @x, @y, timestamp: now }

    history = @history.filter (p) -> now - p.timestamp < ms

    [x, y] =
      for dimension in ["x", "y"]
        velocity = history.reduce ((m, p1, i, a) ->
          p2 = a[i - 1] or p1
          m + (p2[dimension] - p1[dimension])
        ), 0

        velocity / (now - history[0].timestamp)

    t   = -Math.atan2(x, y)

    dir =
      switch Math.round(t / Math.PI * 2)
        when     0 then "up"
        when     1 then "right"
        when 2, -2 then "down"
        when    -1 then "left"
        else "none"

    @velocity = { x, y, t, dir }

  constrain: ({x, y, buffer}) ->
    {minX, minY, maxX, maxY, lock, radius} = @options

    if radius
      t = -Math.atan2(x, y) + Math.PI
      distance = Math.sqrt(x * x + y * y)

      if distance > radius
        rx = Math.abs radius * x / distance
        ry = Math.abs radius * y / distance
        x = @limit x, -rx, rx, buffer
        y = @limit y, -ry, ry, buffer

    else
      x = if lock is "x" then 0 else @limit(x, minX, maxX, buffer)
      y = if lock is "y" then 0 else @limit(y, minY, maxY, buffer)

    return {x, y, t}

  limit: (value, min = -Infinity, max = Infinity, buffer) ->
    if value < min
      min - Easie.expoOut(min - value, 0, buffer, max - min)
    else if value > max
      max + Easie.expoOut(value - max, 0, buffer, max - min)
    else
      value

  reset: ({x, y, t} = {}) ->
    if x? or y? or not t?
      x ?= 0
      y ?= 0
      t = -Math.atan2(x, y) + Math.PI
      t += Math.PI * 2 if t < 0
    else if t?
      x = Math.cos(t - Math.PI / 2) * @options.radius
      y = Math.sin(t - Math.PI / 2) * @options.radius

    @el.dataset.t = @t = t
    @el.dataset.x = @x = x
    @el.dataset.y = @y = y

    @trigger("drop", this, true)

  lock: ->
    @locked = true
    @el.classList.add("locked")

  unlock: ->
    @locked = false
    @el.classList.remove("locked")

  isWithin: (bounds, buffer = 0) ->
    {left, top, right, bottom} = @offset

    left = top = right = bottom = 0 if @options.isParent

    left   + @x > bounds.left   - buffer and
    right  + @x < bounds.right  + buffer and
    top    + @y > bounds.top    - buffer and
    bottom + @y < bounds.bottom + buffer

  distanceTo: (x1, y1, {fromCenter, offsetX, offsetY} = {}) ->
    {left, top, width, height} = @offset

    offsetX ?= if fromCenter then left + width / 2 else 0
    offsetY ?= if fromCenter then top + height / 2 else 0

    x = x1 - (@x + offsetX)
    y = y1 - (@y + offsetY)

    Math.sqrt(x * x + y * y)

module.exports = DraggyView
