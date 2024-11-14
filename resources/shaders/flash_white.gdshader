shader_type canvas_item;
// main tutorial: https://www.youtube.com/watch?v=1pJyYtBAHks
// tweens and shaders: https://www.reddit.com/r/godot/comments/u4yy9k/how_to_tween_shader_parameter/
uniform vec4 color : source_color;
uniform float flashState: hint_range(0, 1) = 0.5;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	//float brightness = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;
	//vec4 grayscale = vec4(brightness, brightness, brightness, pixelColor.a);
	//COLOR = grayscale * color; 
	COLOR = mix(pixelColor, color, flashState);
	COLOR.a *= pixelColor.a;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
