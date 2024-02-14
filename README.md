
# calico

A simple reverse inheritance state machine library for gamemaker

It has a simple api to create simple state machines:

```gml
state = calico_create()

calico_mutate_state(state, "add")
calico_mutate_on(state, "run", "step", function () {
   frame++
})

calico_mutate_state(state, "subtract")
calico_mutate_on(state, "run", "step", function () {
   frame--
})

calico_change(state, "add")
calico_run(state, "run")

calico_change(state, "subtract")
calico_run(state, "run")
```

Alternatively, create a template:

```gml
template = calico_template()
.init("add")
.state("add")
   .on("run", function () {
      frame++
   })
.state("subtract")
   .on("run", function() {
      frame--
   })

state = calico_create(template)
```

And if you need it, utilize the unique reverse inheritance model:

```gml
template = calico_template()
.state("top")
   .on("run", function (_) {
      calico_child(_) // delegates to a child
      show_debug_message("top")
   })
   .child("bottom")
      .on("run", function () {
         show_debug_message("bottom")
      })

state = calico_create(template)

calico_change(state, "top")
calico_run(state, "run") // only prints "top"

calico_change(state, "bottom")
calico_run(state, "run") // prints "bottom", then "top"
```

Check [the documentation](https://github.com/Wainggan/calico/wiki) for more details.

