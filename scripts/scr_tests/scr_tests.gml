
/*
NOTE
i literally have no idea how to do tests lmao
*/

function Reporter() constructor {
	order = 0
	total = 0
	static test = function(_message) {
		total++
		show_debug_message(_message)
	}
	errors = 0
	static error = function(_message) {
		errors++
		show_debug_message(_message)
	}
	static summary = function() {
		show_debug_message($"{errors == 0 ? "success" : "fail"} !! ~ {total} tests run with {errors} errors")
	}
}

global.reporter = undefined

function reporter(_reporter) {
	global.reporter = _reporter
}

// feather ignore GM1056

function assert(_reporter = global.reporter, _value, _message) {
	_reporter.total++
	if !_value {
		_reporter.error($"assert failed: {_message}")
	}
}


function order_start(_reporter = global.reporter) {
	_reporter.order = -1
}
function order(_reporter = global.reporter, _index, _message) {
	_reporter.total++
	if _index <= _reporter.order {
		_reporter.error($"order failed {_reporter.order} {_index}: {_message}")
	}
	_reporter.order = _index
}

function test() {
	var _reporter = new Reporter()
	
	test_templates(_reporter)
	test_inheritance(_reporter)
	
	_reporter.summary()
}

function test_templates(_) {
	
	var _template = calico_template()
	
	assert(_, is_instanceof(_template, CalicoTemplate), "template somehow isn't template")
	
	_template.init("start")
	
	assert(_, _template.__config_init == "start", ".init() failed to set config")
	
	_template.state("start")
	
	assert(_, _template.__names[$ "start"] != undefined, ".state() failed to add state")
	assert(_, _template.__names[$ "start"].parent == undefined, ".state(): root state's parent should be undefined")
	
	_template.state("second")
	
	assert(_, _template.__names[$ "second"] != undefined, ".state() failed to add second state")
	assert(_, _template.__names[$ "second"].parent == undefined, ".state(): root state's parent should be undefined")
	
	static __onenter = function() {}
	static __onleave = function() {}
	static __onmeow = function() {}
	
	_template.onenter(__onenter)
	_template.onleave(__onleave)
	
	assert(_, _template.__names[$ "second"].onenter == __onenter, ".onenter() failed to set trigger")
	assert(_, _template.__names[$ "second"].onleave == __onleave, ".onleave() failed to set trigger")
	
	_template.on("meow", __onmeow)
	
	assert(_, _template.__names[$ "second"].events[$ "meow"] != undefined, ".on() failed to add trigger")
	assert(_, _template.__names[$ "second"].events[$ "meow"] == __onmeow, ".on() failed to set trigger")
	
	_template.child("child")
	
	assert(_, _template.__names[$ "child"] != undefined, ".child() failed to add state")
	assert(_, _template.__names[$ "child"].parent.name == "second", $".child() failed to set parent")
	
	_template.state("child2")
	
	assert(_, _template.__names[$ "child2"] != undefined, ".state() failed to add second child")
	assert(_, _template.__names[$ "child2"].parent.name == "second", $".child() failed to set correct parent")
	
	_template.back()
	
	_template.state("third")
	
	assert(_, _template.__names[$ "third"] != undefined, ".state() failed to add state after .back()")
	assert(_, _template.__names[$ "third"].parent == undefined, $".back() failed to properly reset parent")
	
	var _machine = calico_create(_template)
	
	assert(_, is_instanceof(_machine, Calico), "calico_create() failed somehow")
	
}

function test_inheritance(_) {
	
	reporter(_)
	
	var _template = calico_template()
	.init("bottom")
	.state("top")
		.on("meow", function (_) {
			order(, 0, "top: start")
			calico_child(_)
			order(, 3, "top: child finished")
		})
		.child("middle")
			.child("bottom")
			.on("meow", function (_) {
				order(, 1, "bottom: start")
				calico_child(_)
				order(, 2, "bottom: nothing happens")
			})
	
	order_start(_)
	
	var _machine = calico_create(_template)
	
	calico_run(_machine, "meow")
	
}




