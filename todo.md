
## todo

- [ ] optimization. alias' in particular are an easy target, but caching could be used all around
- [ ] error checking
- [ ] logging
- [ ] reconsider terminology
- [ ] features
	- [ ] sequencing (ex "attack1" => "attack2" => "attack3")
	- [ ] time
	- [ ] improved child delegation (`calico_child(_, "differenttrigger")`)
	- [ ] history tracking
- [ ] improved state definition api

this could be cool:

```
template.add("idle", {
	onenter: function() {},
	step: function() {},
	draw: function() {},
})
```
