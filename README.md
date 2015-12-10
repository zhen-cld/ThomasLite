## Thomas Lite

Thomas Lite is a tool to develop slide templates for Ed.

### Requirements

Thomas requires access to Ed's development environment.

You will also need [Node], [Brunch] and [Bower] installed on your machine. [Scaffolt] is optional, but is useful if creating a lot of templates.

### Running Thomas Lite

You can clone Thomas Lite using brunch. This will run `npm install` and `bower install` for you.

```
brunch new https://github.com/Creative-Licence-Digital/ThomasLite.git your-template
```

Now you are ready to run Thomas...

```
brunch w -s
```

Access Thomas on `localhost:3333`. Thomas watches for any changes you make and reloads the page.

### More information

- [Templates](docs/Templates.md)
- [Slide Methods](docs/Slide Methods.md)
- [DOM Structure](docs/DOM Structure.md)
- CSS components
  - [Blocks](docs/css/Blocks.md)
- JS libraries
  - [Device](docs/js/Device.md)
  - [DraggyView](docs/js/DraggyView.md)
  - [Easie](docs/js/Easie.md)
  - [Prefix](docs/js/Prefix.md)
  - [Preload](docs/js/Preload.md)
  - [Style](docs/js/Style.md)

[Node]: https://nodejs.org/en/
[Brunch]: http://brunch.io
[Bower]: http://bower.io/
[Scaffolt]: https://github.com/paulmillr/scaffolt
