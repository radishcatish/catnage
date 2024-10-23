shader_type canvas_item;

uniform sampler2D holes; //Texture for the holes
uniform vec4 hole_color: source_color; //The color of the holes in the holes texture
uniform vec4 outline_color: source_color; //The color to be ignored on outlines
uniform vec2 direction = vec2(0.0 , 1.0);
uniform float speed = 0.5;
uniform float transparency_strength: hint_range(0.0, 1.0, 0.1); //Value for the transparency

const float EPSILON = 0.0001; // Tolerance value for float comparison


bool is_equal_approx(vec4 first, vec4 second){
    return length(first - second) < EPSILON;
}


void fragment() {
    vec2 normalized_direction = normalize(direction);
    
    vec2 hole_texture_size = vec2(textureSize(holes, 0));
    vec2 main_texture_size = vec2(textureSize(TEXTURE, 0));
    vec2 ratio = hole_texture_size / main_texture_size;
    
    vec2 move = normalized_direction * TIME * speed;
    
    vec4 holes_frag_color = texture(holes, fract(UV/ratio + move));
    
    vec4 current_frag_color = texture(TEXTURE, UV);
    if (is_equal_approx(holes_frag_color, hole_color))
        if (!is_equal_approx(current_frag_color, outline_color))
            if (COLOR.a > 0.0)
                COLOR.a = transparency_strength;
}