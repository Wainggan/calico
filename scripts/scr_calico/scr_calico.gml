
// Feather ignore GM2017

/// @ignore
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

// Feather ignore GM1045

/// @ignore
function CalicoTemplate() constructor {
	
	/// @ignore
	config_init = ""
	/// @ignore
	names = {}
	
	/// @ignore
	last = undefined
	
	/// @func init(_name)
	/// @desc sets the initial state
	/// @params {string,real} _name name of the state. can be string or real (to allow enums)
	/// @returns {Struct.CalicoTemplate}
	static init = function(_name) {
		config_init = _name
		return self
	}
	
	/// @func state(_name)
	/// @desc creates a new state within the current level of hierarchy
	/// @params {string,real} _name name of the state. can be string or real (to allow enums)
	/// @returns {Struct.CalicoTemplate}
	static state = function(_name) {
		var _node = new CalicoTemplateNode(_name)
		
		if last _node.parent = last.parent
		last = _node
		
		names[$ _name] = _node
		
		return self
	}
	
	/// @func child(_name)
	/// @desc pushes the hierarchy a level lower, then creates a new state in it
	/// @params {string,real} _name name of the state. can be string or real (to allow enums)
	/// @returns {Struct.CalicoTemplate}
	static child = function(_name) {
		var _node = new CalicoTemplateNode(_name)
		
		array_push(last.children, _node)
		
		_node.parent = last
		last = _node
		
		names[$ _name] = _node
		
		return self
	}
	
	/// @func back()
	/// @desc pulls the hierarchy a level higher
	/// @returns {Struct.CalicoTemplate}
	static back = function() {
		last = last.parent
		return self
	}
	
	/// @func onenter(_callback)
	/// @desc sets the "onenter" trigger for the last created state
	/// @param {function} _callback the callback to run when triggered. 
	/// the callback's first argument will be the running state machine struct.
	/// @returns {Struct.CalicoTemplate}
	static onenter = function(_callback) {
		last.onenter = _callback
		return self
	}
	
	/// @func onleave(_callback)
	/// @desc sets the "onleave" trigger for the last created state
	/// @param {function} _callback the callback to run when triggered. 
	/// the callback's first argument will be the running state machine struct.
	/// @returns {Struct.CalicoTemplate}
	static onleave = function(_callback) {
		last.onleave = _callback
		return self
	}
	
	/// @func on(_event, _callback)
	/// @desc sets a custom trigger for the last created state. 
	/// can be used to create a "step" or "draw" event, for example
	/// @param {string,real} _event the event name. can be string or a real (to allow enums)
	/// @param {function} _callback the callback to run when triggered. 
	/// the callback's first argument will be the running state machine struct.
	/// @returns {Struct.CalicoTemplate}
	static on = function(_event, _callback) {
		last.events[$ _event] = _callback
		return self
	}
	
}

// Feather enable GM1045

/// @ignore
function Calico() constructor {
	
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

/// @ignore
function CalicoAlias(_source, _state) constructor {
	source = _source
	state = _state
}

/// @func calico_template()
/// @desc creates a template, from which the scaffolding of a state machine can be formed
/// @returns {Struct.CalicoTemplate} the template struct
function calico_template() {
	return new CalicoTemplate()
}

/// @func calico_create([_template])
/// @desc creates a new state machine, optionally from a previously created template
/// @param {Struct.CalicoTemplate} _template a template to create from
/// @returns {Struct.Calico} a new state machine
function calico_create(_template = undefined) {
	
	var _controller = new Calico()
	
	if _template {
		
		_controller.current = _template.config_init
		
		// sigh
		// feather ignore GM1041
		var _names = struct_get_names(_template.names)
		// feather enable GM1041
		for (var i = 0; i < array_length(_names); i++) {
			_controller.states[$ _names[i]] = _template.names[$ _names[i]].copy()
		}
		
	}
	
	return _controller
	
}

/// @func calico_run(_source, _event)
/// @desc runs the specified event for the current state of the state machine
/// @param {Struct.Calico} _source the state machine
/// @param {string,real} _event the event name to run. can be a string or a real (to allow enums)
function calico_run(_source, _event) {
	_source.run(_event)
}

/// @func calico_child(_source)
/// @desc when used inside a running event, the state machine will begin running the current state's child's event
/// when used outside, the function will silently exit.
/// @param {Struct.Calico} _source the state machine
function calico_child(_source) {
	_source.child()
}

/// @func calico_change(_source, [_state])
/// @desc changes the state machine's current state.
/// will run the previous state's "onleave" callback and the new state's "onenter" callback.
/// when used outside of a running event, the state machine's state will change immediately.
/// when used inside a running event, the state machine will wait until the state fully complete before changing.
/// @param {Struct.Calico,Struct.CalicoAlias} _source the state machine, or an alias of a state
/// @param {string,real} _state the state to change to. can be a string or a real (to allow enums). 
/// doesn't do anything if the first argument was an alias.
function calico_change(_source, _state = undefined) {
	if is_struct(_source) && is_instanceof(_source, CalicoAlias) {
		_source.source.change(_source.state)
	} else {
		_source.change(_state)
	}
}

/// @func calico_get(_source, _state)
/// @desc creates a new alias, which can be sometimes used to simplify code.
/// @param {Struct.Calico} _source the state machine
/// @param {string,real} _state the state to alias. can be a string or a real (to allow enums)
/// @returns {Struct.CalicoAlias} a new alias
function calico_get(_source, _state) {
	return new CalicoAlias(_source, _state)
}

/// @func calico_is(_source, _state)
/// @desc checks to see if the state machine is in a state
/// @param {Struct.Calico,Struct.CalicoAlias} _source the state machine, or an alias of a state
/// @param {string,real} _state the state to check against. can be a string or a real (to allow enums)
/// doesn't do anything if the first argument was an alias
/// @returns {bool} wether the state machine is in the state
function calico_is(_source, _state = undefined) {
	if is_struct(_state) && is_instanceof(_state, CalicoAlias) {
		return _source == _state.source && _source.current == _state.state
	} else {
		return _source.current == _state
	}
}

/// @func calico_mutate_init(_source, _state)
/// @desc sets the state machines state to a state, without triggering "onenter" or "onleave"
/// @param {Struct.Calico} _source the state machine
/// @param {string,real} _state the state to set to. can be string or a real (to allow enums)
function calico_mutate_init(_source, _state) {
	_source.current = _state
}

/// @func calico_mutate_state(_source, _name, [_parent])
/// @desc creates a new state for a state machine
/// @param {Struct.Calico} _source the state machine
/// @param {string,real} _state the state to create. can be string or a real (to allow enums)
/// @param {string,real} _parent an optional parent state for the new state
function calico_mutate_state(_source, _state, _parent = "") {
	_source.states[$ _name] = {
		parent: _parent,
		onleave: undefined,
		onenter: undefined,
		events: {}
	}
}

/// @func calico_mutate_onenter(_source, _state, _callback)
/// @desc sets the "onenter" trigger for a state
/// @param {Struct.Calico} _source the state machine
/// @param {string,real} _state the state to set. can be string or a real (to allow enums)
/// @param {function} _callback the callback to run when triggered. 
/// the callback's first argument will be the running state machine.
function calico_mutate_onenter(_source, _state, _callback) {
	_source.states[$ _name].onenter = _callback
}

/// @func calico_mutate_onleave(_source, _state, _callback)
/// @desc sets the "onleave" trigger for a state
/// @param {Struct.Calico} _source the state machine
/// @param {string,real} _state the state to set. can be string or a real (to allow enums)
/// @param {function} _callback the callback to run when triggered. 
/// the callback's first argument will be the running state machine.
function calico_mutate_onleave(_source, _state, _callback) {
	_source.states[$ _name].onleave = _callback
}

/// @func calico_mutate_on(_source, _state, _event, _callback)
/// @desc sets a custom trigger. can be used to create a "step" or "draw" event, for example
/// @param {Struct.Calico} _source the state machine
/// @param {string,real} _state the state to set. can be string or a real (to allow enums)
/// @param {string,real} _event the event name. can be string or a real
/// @param {function} _callback the callback to run when triggered. 
/// the callback's first argument will be the running state machine.
function calico_mutate_on(_source, _state, _event, _callback) {
	_source.states[$ _name].events[$ _event] = _callback
}

