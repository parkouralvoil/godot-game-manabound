shader_type canvas_item;

uniform vec4 color : source_color;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	float brightness = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;
	vec4 grayscale = vec4(brightness, brightness, brightness, pixelColor.a);
	COLOR = grayscale * color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
