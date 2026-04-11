shader_type canvas_item;

// This single line hides the object completely unless a light hits it
render_mode light_only;

void fragment() {
	// We MUST output the actual texture so the light pass knows 
	// what color and alpha to use as a base mask.
	COLOR = texture(TEXTURE, UV);
}

void light() {
	vec4 tex = texture(TEXTURE, UV);
	
	// Your custom brightness calculation
	float brightness = max(max(LIGHT_COLOR.r, LIGHT_COLOR.g), LIGHT_COLOR.b);
	
	// Output the texture's color, modulated by the light's color and your brightness logic.
	// You don't need to touch LIGHT.a at all here.
	LIGHT.rgb = tex.rgb * LIGHT_COLOR.rgb * brightness;
}