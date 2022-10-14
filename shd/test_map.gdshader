shader_type canvas_item;

uniform sampler2D is_top;
uniform float alpha=0.5;

void fragment() {
	vec4 c_obj = texture(TEXTURE,UV);
	vec4 c_top = texture(is_top,UV);
	
	if(c_top.a > 0.0 && c_obj.a > 0.0){
		COLOR = vec4(c_obj.r,c_obj.g,c_obj.b,alpha);
	}else{
		COLOR = vec4(c_obj.r,c_obj.g,c_obj.b,0.0);
	}
	
}
