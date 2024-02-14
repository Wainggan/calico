
enum PlayerState {
	free,
	slide
}

template = calico_template()
.state("base")
	.add({
		step: function (_) {
		
			// input checking
			key_left = keyboard_check(vk_left)
			key_right = keyboard_check(vk_right)
			key_jump = keyboard_check(ord("Z"))
			key_jumped = keyboard_check_pressed(ord("Z"))
		
			calico_child(_)
		
			// quick dirty collisions
			x += x_vel
			var _inst = instance_place(x, y, obj_calico_example_wall)
			if _inst {
				var _left = abs(bbox_left - x)
				var _right = abs(bbox_right - x)
				if x_vel < 0 {
					x = _inst.bbox_right + _left
				} else {
					x = _inst.bbox_left - _right
				}
				x_vel = 0
			}
		
			y += y_vel
			_inst = instance_place(x, y, obj_calico_example_wall)
			if _inst {
				var _top = abs(bbox_top - y)
				var _bottom = abs(bbox_bottom - y)
				if y_vel < 0 {
					y = _inst.bbox_bottom + _top
				} else {
					y = _inst.bbox_top - _bottom
				}
				y_vel = 0
			}
		},
		draw: function (_) {
			draw_sprite(spr_calico_example_player, 0, x, y)
		},
	})
	.child(PlayerState.free)
		.on("step", function (_) {
			
			var _kh = key_right - key_left
			
			if _kh != 0 {
				x_vel += _kh * 0.4
			} else if place_meeting(x, y + 1, obj_calico_example_wall) {
				var _sign = sign(x_vel)
				x_vel -= _sign * 0.5
				if sign(x_vel) != _sign x_vel = 0
				
			}
			x_vel = clamp(x_vel, -4, 4)
			
			if key_jump {
				y_vel += 0.15
			} else {
				y_vel += 0.4
			}
			y_vel = min(y_vel, 5)
			
			var _wall = place_meeting(x + 1, y, obj_calico_example_wall) -
				place_meeting(x - 1, y, obj_calico_example_wall)
			
			if place_meeting(x, y + 1, obj_calico_example_wall) {
				if key_jumped {
					y_vel = -5
				}
			} else if _wall != 0 {
				if key_jumped {
					x_vel = -_wall * 5
					y_vel = -5
				}
				if y_vel > 0 && _kh == _wall {
					calico_change(_, PlayerState.slide)
				}
			}
			
		})
	.state(PlayerState.slide)
		.on("step", function (_) {
			
			x_vel = 0
			y_vel = 2
			
			var _wall = place_meeting(x + 1, y, obj_calico_example_wall) -
				place_meeting(x - 1, y, obj_calico_example_wall)
			
			if _wall == 0 || place_meeting(x, y + 1, obj_calico_example_wall) {
				calico_change(_, PlayerState.free)
			}
			
			if key_jumped {
				x_vel = -_wall * 5
				y_vel = -5
				
				calico_change(_, PlayerState.free)
			}
			
		})
.init(PlayerState.free)


x_vel = 0
y_vel = 0


state = calico_create(template)

