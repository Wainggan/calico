
# calico

A simple reverse inheritance state machine library for gamemaker

![calico logo image thing](./calico.png)

It has a simple api to create simple state machines:

```gml
state = calico_create()

calico_mutate_state(state, "addition")
calico_mutate_on(state, "addition", "run", function () {
   frame++
})

calico_mutate_state(state, "subtract")
calico_mutate_on(state, "subtract", "run", function () {
   frame--
})

calico_change(state, "addition")
calico_run(state, "run")

calico_change(state, "subtract")
calico_run(state, "run")
```

Alternatively, create a template:

```gml
template = calico_template()
.init("addition")
.state("addition").add({
   run: function() {
      frame++
   },
})
.state("subtract").add({
   run: function() {
      frame++
   },
})

state = calico_create(template)
```

And if you need it, utilize the unique reverse inheritance model:

```gml
template = calico_template()
.state("top").add({
   run: function (_) {
      calico_child(_) // delegates to a child
      show_debug_message("top")
   },
})
   .child("bottom").add({
      run: function () {
         show_debug_message("bottom")
      },
   })

state = calico_create(template)

calico_change(state, "top")
calico_run(state, "run") // only prints "top"

calico_change(state, "bottom")
calico_run(state, "run") // prints "bottom", then "top"
```

Check [the documentation](https://github.com/Wainggan/calico/wiki) for more details.

