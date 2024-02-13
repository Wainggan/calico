
function CalicoTemplateNode(_name) constructor {
	
	name = _name
	onenter = undefined
	onleave = undefined
	events = {}
	
	parent = undefined
	children = []
	
	static copy = function(){
		var _events = {}
		var _names = struct_get_names(events)
		for (var i = 0; i < array_length(_names); i++) {
			_events[$ _names[i]] = events[$ _names[i]]
		}
		return {
			parent: parent ? parent.name : "",
			onenter, onleave, events: _events
		}
	}
	
}

function CalicoTemplate() constructor {
	
	config_init = ""
	names = {}
	
	last = undefined
	
	
	static init = function(_name) {
		config_init = _name
		return self
	}
	
	static state = function(_name) {
		var _node = new CalicoTemplateNode(_name)
		
		last = _node
		
		names[$ _name] = _node
		
		return self
	}
	
	static child = function(_name) {
		var _node = new CalicoTemplateNode(_name)
		
		array_push(last.children, _node)
		
		_node.parent = last
		last = _node
		
		names[$ _name] = _node
		
		return self
	}
	
	static back = function() {
		last = last.parent
		return self
	}
	
	
	static onenter = function(_callback) {
		last.onenter = _callback
		return self
	}
	
	static onleave = function(_callback) {
		last.onleave = _callback
		return self
	}
	
	static on = function(_event, _callback) {
		last.events[$ _event] = _callback
		return self
	}
	
}


function CalicoController() constructor {
	
	states = {}
	current = ""
	defer = undefined
	
	running = false
	
	tree = []
	index = 0
	
	static tree_get = function() {
		var _tree = []
		var _check = current
	
		while states[$ _check] {
			array_push(_tree, _check)
			_check = states[$ _check].parent
		}
		
		return _tree
	}
	
	static run = function(_event = "", _type = 0) {
		
		tree = tree_get()
		index = array_length(tree)
		
		running = true
		
		child(_event, _type)
		
		running = false
		
		if defer {
			change(defer)
			defer = undefined
		}
		
	}
	
	static child = function(_event = "", _type = 0) {
		
		if !running {
			return;
		}
		
		index--
		
		if index >= 0 {
			var _callback;
			if _type == 0
				_callback = states[$ tree[index]].events[$ _event]
			else if _type == 1
				_callback = states[$ tree[index]].onenter
			else if _type == 2
				_callback = states[$ tree[index]].onleave
			
			if _callback _callback(self)
			else child(_event, _type)
		}
		
		index++
		
	}
	
	static change = function(_state) {
		
		if !running {
			run(, 2)
			current = _state
			run(, 1)
		} else {
			defer = _state
		}
		
	}
	
	static get_state = function(_state) {
		return states[$ _state]
	}
	static get_event = function(_state, _event) {
		return get_state(_state).events[$ _event]
	}

}

function CalicoAlias(_source, _state) constructor {
	source = _source
	state = _state
}


function calico_template() {
	return new CalicoTemplate()
}

function calico_create(_template = undefined) {
	
	var _controller = new CalicoController()
	
	if _template {
		
		_controller.current = _template.config_init
		
		var _names = struct_get_names(_template.names)
		for (var i = 0; i < array_length(_names); i++) {
			_controller.states[$ _names[i]] = _template.names[$ _names[i]].copy()
		}
		
	}
	
	return _controller
	
}

function calico_run(_source, _event) {
	_source.run(_event)
}

function calico_child(_source) {
	_source.child()
}

function calico_change(_source, _state = undefined) {
	if is_struct(_source) && is_instanceof(_source, CalicoAlias) {
		_source.source.change(_source.state)
	} else {
		_source.change(_state)
	}
}

function calico_get(_source, _state) {
	return new CalicoAlias(_source, _state)
}

function calico_is(_source, _state) {
	if is_struct(_state) && is_instanceof(_state, CalicoAlias) {
		return _source == _state.source && _source.current == _state.state
	} else {
		return _source.current == _state
	}
}

function calico_mutate_init(_source, _state) {
	_source.current = _state
}

function calico_mutate_state(_source, _name, _parent = "") {
	_source.states[$ _name] = {
		parent: _parent,
		onleave: undefined,
		onenter: undefined,
		events: {}
	}
}

function calico_mutate_onenter(_source, _name, _callback) {
	_source.states[$ _name].onenter = _callback
}

function calico_mutate_onleave(_source, _name, _callback) {
	_source.states[$ _name].onleave = _callback
}

function calico_mutate_on(_source, _name, _event, _callback) {
	_source.states[$ _name].events[$ _event] = _callback
}




