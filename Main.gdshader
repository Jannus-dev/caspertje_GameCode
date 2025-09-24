shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
   // neem de standaard screen UV
	vec2 uv = SCREEN_UV;

    // sinus-golf vervorming
	uv.y += sin(uv.x * 30.0 + TIME * 5.0) * 0.02;
    uv.x += cos(uv.y * 40.0 + TIME * 3.0) * 0.02;

    // sample het scherm
	COLOR = texture(screen_tex, uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
