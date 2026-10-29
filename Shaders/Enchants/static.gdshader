shader_type canvas_item;

// Pixelated "charged object" / plasma effect for Godot 4.x.
// Works on Sprite2D, AnimatedSprite2D, TextureRect, etc. The original texture is
// preserved (pixel-snapped) and electric arcs spark up ONLY from the edge pixels of
// the object (opaque pixels that border transparency, or the texture border), leave
// the surface, crawl a random distance, then die and respawn somewhere else along
// the edge. A pulsing rim glow outlines the silhouette.
//
// CHANGES FROM THE ORIGINAL
//  - spawn_on_edges: arcs start on silhouette edge pixels. A random opaque point is picked,
//    then a random ray is marched until it leaves the silhouette; the last opaque pixel is
//    the arc's origin. (edge_search = max march distance in texels.)
//  - edge_normal_bias: arcs leave along the local outward normal. 0 = any outward direction,
//    1 = exactly along the normal. Directions pointing into the object are mirrored outward.
//  - arcs_inward: flip the direction so arcs crawl into the object instead of away from it. Pair with
//    arcs_only_on_object if you don't want long arcs to poke out the far side.
//  - contain_in_texture: arcs are shortened to fit and everything they draw is clipped to the texture rect,
//    so nothing appears in the padded area.
//  - arcs_inside_object: arcs start at the origin (edge pixel if spawn_on_edges) and jump to another
//    point on the object min_length..max_length away, pinned at both ends and drawn only on opaque pixels,
//    so lightning crackles across the inside of the texture.
//  - stay_inside (default ON): lightning stays within the texture. Arcs connect two points on the object,
//    the sideways wiggle is reduced wherever it would leave the opaque pixels, and everything they draw
//    (core and glow) is clipped to opaque pixels. Turn it off for arcs that leave the object (spawn_on_edges
//    + arcs_inward etc. then apply).
//  - reach_padding (default ON): every arc runs from its edge pixel straight out to the edge of the
//    padding, and its tip lands there (padding_margin_px short of the quad edge). The arc is pinned at
//    both ends, so it wiggles in between but always ends at the padding. This overrides stay_inside /
//    arcs_inside_object and min_length / max_length. Turn it off to go back to those modes.
//  - end_style / end_time: how an arc ends. "Retract" pulls it back toward its origin (the old behavior).
//    "Dissipate" (default) keeps the arc at full length and breaks it up over the last `end_time` of its
//    life: it flickers out on random frames, splits into segments that vanish one by one, erodes pixel by
//    pixel, the glow collapses toward the core and the colors cool down (white -> pale blue -> violet).
//  - arc_life_min / arc_life_max: each arc's lifetime is a random value in this range, re-rolled every cycle
//    (with a random start delay inside its slot, so arcs don't pulse in sync).
//  - padding: vertex() grows the quad by this many texture pixels per side so arcs and glow can
//    draw outside the texture without editing it. Use it on a Sprite2D showing the whole texture
//    (no hframes/vframes, region or atlas).
//
// Tips:
//  - Raise `padding` for longer arcs (with reach_padding the arc length is set by the padding).
//  - Each arc does a handful of texture lookups per pixel, so keep arc_count modest on big sprites.

group_uniforms layout;
uniform int padding : hint_range(0, 64) = 16;  // extra pixels around the texture for arcs/glow
instance uniform float lightning_seed = 1.0;

group_uniforms spawning;
uniform bool spawn_on_edges = true;           // arcs start on silhouette edge pixels
uniform bool arcs_inward = false;             // true = arcs crawl into the object instead of away from it
uniform bool arcs_inside_object = false;      // arcs jump from the origin to another point ON the object, drawn only on its pixels
uniform bool stay_inside = true;               // route arcs so they stay ON the object: bends toward the object where needed, nothing drawn outside it
uniform bool reach_padding = true;            // arcs run from the edge out to the padding edge (overrides stay_inside / arcs_inside_object)
uniform float padding_margin_px : hint_range(0.0, 8.0) = 1.0; // how many px before the quad edge the tip stops (raise to ~outer_glow_px so the glow isn't cut)
uniform float crack_min_length : hint_range(0.05, 1.5) = 0.5;  // (crack_lines) fraction of sprite size
uniform float crack_max_length : hint_range(0.05, 1.5) = 1.0;
uniform float crack_jaggedness : hint_range(0.0, 0.6) = 0.1;   // lower = smoother meander
uniform float crack_width_px : hint_range(0.1, 2.0) = 0.55;    // ~0.5 = a single pixel wide
uniform vec4 crack_color : source_color = vec4(0.55, 0.88, 0.95, 1.0);
uniform int edge_search : hint_range(4, 64) = 32;           // max ray length (texels) when looking for an edge
uniform float edge_normal_bias : hint_range(0.0, 1.0) = 0.6; // 1 = leave exactly along the outward normal
uniform bool spawn_on_object = true;          // (when edges are off) only spawn on opaque pixels
uniform vec2 spawn_min = vec2(0.0, 0.0);      // UV rectangle arcs may spawn in
uniform vec2 spawn_max = vec2(1.0, 1.0);
uniform float outward_bias : hint_range(0.0, 1.0) = 0.0; // (edges off) 0 = any direction, 1 = away from `center`
uniform vec2 center = vec2(0.5, 0.5); // only used for outward_bias / center glow

group_uniforms arcs;
uniform int arc_count : hint_range(0, 12) = 7;
uniform float arc_life_min : hint_range(0.1, 5.0) = 0.3; // shortest arc lifetime (seconds)
uniform float arc_life_max : hint_range(0.1, 5.0) = 0.8; // longest arc lifetime (seconds); each arc re-rolls its lifetime every cycle
uniform float min_length : hint_range(0.05, 1.0) = 0.2; // fraction of sprite size
uniform float max_length : hint_range(0.05, 1.0) = 0.6;
uniform float jaggedness : hint_range(0.0, 0.6) = 0.18; // sideways wiggle (fraction of length)
uniform float crackle_px : hint_range(0.0, 4.0) = 1.0; // per-frame jitter in pixels
uniform float core_width_px : hint_range(0.0, 4.0) = 0.6;
uniform float inner_glow_px : hint_range(0.0, 8.0) = 1.6;
uniform float outer_glow_px : hint_range(0.0, 16.0) = 3.5;
uniform bool arcs_only_on_object = false; // clip arcs to opaque pixels
uniform bool fit_to_quad = true; // shorten arcs so they never run past the padded quad
uniform bool contain_in_texture = false; // keep arcs and their glow strictly inside the texture rect

group_uniforms ending;
uniform int end_style : hint_enum("Retract", "Dissipate") = 1; // how an arc ends
uniform float end_time : hint_range(0.1, 0.7) = 0.35; // fraction of the arc's life spent ending
uniform int dissipate_segments : hint_range(3, 16) = 8; // pieces the arc breaks into while dissipating
uniform float dissipate_flicker : hint_range(0.0, 1.0) = 0.45; // how much the arc blinks off before it's gone
uniform float dissipate_erosion : hint_range(0.0, 1.0) = 0.6; // pixel-by-pixel dissolve of what's left

group_uniforms charge;
uniform float center_glow_radius : hint_range(0.0, 1.0) = 0.0;
uniform float rim_glow_px : hint_range(0.0, 3.0) = 2.0;
uniform float charge_tint : hint_range(0.0, 1.0) = 0.25; // pulsing brighten of the texture
uniform float pulse_speed : hint_range(0.0, 20.0) = 6.0;

group_uniforms colors;
uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 inner_glow_color : source_color = vec4(0.80, 0.90, 1.0, 1.0);
uniform vec4 outer_glow_color : source_color = vec4(0.45, 0.35, 1.0, 1.0);

group_uniforms animation;
uniform float anim_fps : hint_range(4.0, 30.0) = 12.0;

const float BAYER4[16] = float[16](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0
);

varying vec4 v_modulate;

float hash11(float p) {
	p = fract(p * 0.1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}

float noise1(float x) {
	float i = floor(x);
	float f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(hash11(i), hash11(i + 1.0), f) * 2.0 - 1.0;
}

// sideways wiggle (fraction of arc length) at t = 0..1 along the arc
float arc_wiggle(float t, float s, float jag, float f0, int octaves) {
	float n = 0.0;
	float amp = jag;
	float freq = f0;
	for (int i = 0; i < 4; i++) {
		if (i >= octaves) break;
		n += noise1(t * freq + s * 13.7 + float(i) * 5.1) * amp;
		freq *= 2.1;
		amp *= 0.5;
	}
	return n;
}

float bayer(vec2 p) {
	ivec2 i = ivec2(mod(p, 4.0));
	return (BAYER4[i.x + i.y * 4] + 0.5) / 16.0;
}

// anything outside the texture counts as transparent
// (so the padded area is empty and sprites touching the texture border get an edge there).
float alpha_at(sampler2D tex, vec2 uvp, vec2 grid) {
	if (uvp.x < 0.0 || uvp.y < 0.0 || uvp.x >= 1.0 || uvp.y >= 1.0) {
		return 0.0;
	}
	vec2 s = (floor(uvp * grid) + 0.5) / grid;
	return textureLod(tex, s, 0.0).a;
}

void vertex() {
	v_modulate = COLOR; // keep the node's modulate

	// grow the quad outward and extend UV past 0..1 by the same amount
	vec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE;
	float p = float(padding);
	VERTEX += sign(UV - 0.5) * p;
	UV = 0.5 + (UV - 0.5) * (tex_size + 2.0 * p) / tex_size;
}

void fragment() {
	vec2 grid = vec2(textureSize(TEXTURE, 0));
	vec2 cell = floor(UV * grid);
	vec2 uv = (cell + 0.5) / grid;
	float minres = min(grid.x, grid.y);
	
	float time = floor(TIME * anim_fps) / anim_fps;
	float frame = floor(TIME * anim_fps);

	// original texture with modulate applied (transparent in the padded area)
	bool inside = uv.x >= 0.0 && uv.y >= 0.0 && uv.x < 1.0 && uv.y < 1.0;
	vec4 tex = inside ? texture(TEXTURE, uv) * v_modulate : vec4(0.0);
	vec4 outc = tex;

	// stepped pulse used by the charge tint and rim glow
	float pulse = 0.5 + 0.5 * noise1(time * pulse_speed + lightning_seed);
	pulse = floor(pulse * 4.0 + 0.5) / 4.0;

	// charged tint on the object itself
	outc.rgb += outer_glow_color.rgb * charge_tint * pulse * 0.5 * tex.a;

	// rim glow around the silhouette
	if (rim_glow_px > 0.0) {
		vec2 px = 1.0 / grid;
		float nearest_out = 99.0;
		float min_alpha = 1.0;
		for (int k = 1; k <= 3; k++) {
			if (float(k) > rim_glow_px) break;
			for (int j = 0; j < 8; j++) {
				float a = float(j) * TAU / 8.0;
				vec2 o = round(vec2(cos(a), sin(a))) * float(k) * px;
				float na = alpha_at(TEXTURE, uv + o, grid);
				if (na > 0.5) nearest_out = min(nearest_out, float(k));
				if (k == 1) min_alpha = min(min_alpha, na);
			}
		}
		if (tex.a < 0.5 && nearest_out < 99.0) {
			float t = 1.0 - (nearest_out - 1.0) / max(rim_glow_px, 1.0);
			if (t * (0.4 + 0.6 * pulse) > bayer(cell)) {
				outc = vec4(outer_glow_color.rgb, 0.7);
			}
		} else if (tex.a >= 0.5 && min_alpha < 0.5) {
			outc.rgb = mix(outc.rgb, inner_glow_color.rgb, 0.5 * (0.4 + 0.6 * pulse));
		}
	}

	// arcs: each spawns on an edge pixel and crawls away in a random direction
	vec2 pp = uv * grid; // this pixel, in pixel units
	float best_d = 1000.0;
	float best_fade = 0.0; // dissipation progress (0..1) of the arc that is closest to this pixel

	for (int i = 0; i < 12; i++) {
		if (i >= arc_count) break;
		float fi = float(i);

		// arc lifetime: every cycle re-rolls position, direction, length AND lifetime (arc_life_min..arc_life_max).
		// Each arc has a time slot of arc_life_max seconds; inside it the arc lives for a random
		// duration starting at a random delay, then stays dark until the next slot.
		float slot_len = max(arc_life_max, arc_life_min);
		float tt = time / slot_len + hash11(fi * 5.7 + lightning_seed);
		float cyc = floor(tt);
		float cs = lightning_seed + fi * 17.3 + cyc * 3.91;
		float life = mix(arc_life_min, slot_len, hash11(cs + 7.0));
		float delay = hash11(cs + 8.0) * (slot_len - life);
		float lf = (fract(tt) * slot_len - delay) / life; // 0..1 over the arc's own life
		if (lf < 0.0 || lf >= 1.0) continue;

		float end_len = max(end_time, 0.01);
		float dis = clamp((lf - (1.0 - end_len)) / end_len, 0.0, 1.0); // 0 = alive, 1 = gone
		float grow = clamp(lf / 0.25, 0.0, 1.0); // sprouts over first quarter
		float strength = 1.0 - dis;
		if (grow <= 0.0 || strength <= 0.0) continue;

		// origin
		vec2 span = spawn_max - spawn_min;
		vec2 o_uv = spawn_min + span * vec2(hash11(cs + 11.0), hash11(cs + 12.0));
		vec2 edge_n = vec2(0.0);
		
		// 1. random opaque point inside the spawn rectangle
		vec2 start_c = vec2(0.0);
		bool have = false;
		for (int k = 0; k < 6; k++) {
			float ks = float(k) * 7.3;
			vec2 c = spawn_min + span * vec2(hash11(cs + 11.0 + ks), hash11(cs + 12.0 + ks));
			if (alpha_at(TEXTURE, c, grid) > 0.5) {
				start_c = floor(c * grid);
				have = true;
				break;
			}
		}
		if (!have) continue;
		
		// 2. march a random ray until it leaves the silhouette; the last opaque pixel is the edge
		float ma = hash11(cs + 21.0) * TAU;
		vec2 md = vec2(cos(ma), sin(ma));
		vec2 last_c = start_c;
		bool exited = false;
		for (int k = 1; k <= 64; k++) {
			if (k > edge_search) break;
			vec2 c = floor(start_c + 0.5 + md * float(k));
			if (alpha_at(TEXTURE, (c + 0.5) / grid, grid) < 0.5) {
				exited = true;
				break;
			}
			last_c = c;
		}
		if (!exited) continue;
		o_uv = (last_c + 0.5) / grid;
		
		// 3. outward normal = sum of directions toward transparent neighbors
		for (int j = 0; j < 8; j++) {
			float na = float(j) * TAU / 8.0;
			vec2 nd = round(vec2(cos(na), sin(na)));
			if (alpha_at(TEXTURE, (last_c + nd + 0.5) / grid, grid) < 0.5) {
				edge_n += nd;
			}
		}
		if (length(edge_n) < 0.01) edge_n = md;
		edge_n = normalize(edge_n);
		if (arcs_inward) edge_n = -edge_n; // flip so the normal points into the object

		// ---- Direction ----
		float rang = hash11(cs + 3.0) * TAU;
		vec2 rdir = vec2(cos(rang), sin(rang));
		vec2 u;
		if (spawn_on_edges) {
			if (dot(rdir, edge_n) < 0.0) rdir = reflect(rdir, edge_n); // never dive into the object
			u = normalize(mix(rdir, edge_n, edge_normal_bias) + rdir * 0.001);
		} else {
			vec2 odir = normalize((o_uv - center) * grid + vec2(0.0001));
			if (arcs_inward) odir = -odir; // toward `center` instead of away
			u = normalize(mix(rdir, odir, outward_bias) + rdir * 0.001);
		}

		float L = mix(min_length, max_length, hash11(cs + 1.0)) * minres;

		// distance from the origin to the edge of the padded quad (or the texture rect) along the arc
		if (reach_padding || fit_to_quad || contain_in_texture) {
			vec2 o = o_uv * grid;
			vec2 lo = contain_in_texture ? vec2(0.0) : vec2(-float(padding));
			vec2 hi = contain_in_texture ? grid : grid + float(padding);
			vec2 tr = vec2(1e6);
			if (u.x > 0.001) tr.x = (hi.x - o.x) / u.x;
			else if (u.x < -0.001) tr.x = (lo.x - o.x) / u.x;
			if (u.y > 0.001) tr.y = (hi.y - o.y) / u.y;
			else if (u.y < -0.001) tr.y = (lo.y - o.y) / u.y;
			float room = min(tr.x, tr.y);
			if (reach_padding) {
				// end exactly at the padding: the tip lands padding_margin_px short of the quad edge
				L = max(room - padding_margin_px, 1.0);
			} else {
				float margin = outer_glow_px + crackle_px + 1.0;
				L = min(L, max(room - margin, 1.0) / (1.0 + jaggedness * 2.0));
			}
		}
		vec2 q = pp - o_uv * grid;
		float t = dot(q, u) / L;
		float perp = dot(q, vec2(-u.y, u.x));
		if (t < -0.02 || t > grow) continue;

		// ending: "Retract" pulls the arc back toward its origin
		if (end_style == 0 && t < dis) continue;

		// ending: "Dissipate" keeps the full arc and breaks it up
		if (end_style == 1 && dis > 0.0) {
			// 1. the whole arc blinks out on random frames
			if (hash11(frame * 1.7 + fi * 9.3 + cs) < dis * dissipate_flicker) continue;
			// 2. it splits into segments that vanish one by one
			float seg = floor(clamp(t, 0.0, 1.0) * float(dissipate_segments));
			if (hash11(seg * 3.7 + cs * 1.3) < dis * 1.1 - 0.05) continue;
			// 3. what's left erodes pixel by pixel
			if (hash11(cell.x * 7.13 + cell.y * 17.31 + cs * 5.0 + frame * 0.37) < dis * dis * dissipate_erosion) continue;
		}

		// Jagged path: pinned at the origin, free toward the tip
		float tc = clamp(t, 0.0, 1.0);
		float taper = clamp(tc * 5.0, 0.0, 1.0);
		if (reach_padding) taper *= clamp((1.0 - tc) * 5.0, 0.0, 1.0); // pinned at both ends
		float jag = jaggedness;
		float wf = 3.0;
		int wo = 4;
		float jitter = noise1(tc * 20.0 + frame * 4.7 + fi * 9.0) * crackle_px;
		// Stay-inside: shrink the sideways wiggle (same factor along the whole arc, so it stays smooth)
		// until 16 sample points along the arc all land on opaque pixels.
		float off_scale = 1.0;
		if (stay_inside) {
			float band = jag * 1.7 * L + 3.0;
			if (abs(perp) > band) continue; // this pixel is nowhere near the arc
			vec2 o0 = o_uv * grid;
			vec2 pu = vec2(-u.y, u.x);
			for (int sc = 0; sc < 5; sc++) {
				float f = 1.0 - float(sc) * 0.25;
				off_scale = f;
				bool ok = true;
				for (int k = 1; k <= 16; k++) {
					float tk = float(k) / 16.0;
					float tp = clamp(tk * 5.0, 0.0, 1.0) * clamp((1.0 - tk) * 5.0, 0.0, 1.0);
					vec2 pc = o0 + u * (tk * L) + pu * (arc_wiggle(tk, cs, jag, wf, wo) * L * tp * f);
					if (alpha_at(TEXTURE, pc / grid, grid) < 0.5) {
						ok = false;
						break;
					}
				}
				if (ok) break;
			}
		}
		float offset = (arc_wiggle(tc, cs, jag, wf, wo) * L * off_scale + jitter) * taper;

		float d = abs(perp - offset);
		if (t < 0.0) d += -t * L; // round cap at the origin
		if (end_style == 1) d += dis * (outer_glow_px + 1.0); // glow collapses toward the core, then the core thins out
		if (d < best_d) {
			best_d = d;
			best_fade = end_style == 1 ? dis : 0.0;
		}
	}

	bool need_opaque = arcs_only_on_object;
	bool arcs_ok = (!need_opaque || tex.a > 0.5) && (!contain_in_texture || inside);
	if (arcs_ok) {
		// Optional dithered glow around `center` (off by default)
		float rn = length((uv - center) * grid) / max(0.5 * minres, 0.001);
		float cg = clamp(1.0 - rn / max(center_glow_radius, 0.001), 0.0, 1.0);
		if (center_glow_radius > 0.0 && cg * (0.5 + 0.5 * pulse) > bayer(cell)) {
			outc.rgb = mix(outc.rgb, inner_glow_color.rgb, 0.6);
			outc.a = max(outc.a, 0.8);
		}

		// colors cool down as the arc dissipates: white -> pale blue -> violet, and the glow fades
		float fade = best_fade;
		vec3 core_c = mix(core_color.rgb, inner_glow_color.rgb, fade);
		vec3 inner_c = mix(inner_glow_color.rgb, outer_glow_color.rgb, fade);

		float outer_t = clamp(1.0 - (best_d - inner_glow_px) / max(outer_glow_px - inner_glow_px, 0.001), 0.0, 1.0);
		if (best_d < outer_glow_px && outer_t > bayer(cell)) {
			outc.rgb = mix(outc.rgb, outer_glow_color.rgb, 0.65);
			outc.a = max(outc.a, 0.65 * (1.0 - 0.6 * fade));
		}
		if (best_d < inner_glow_px) {
			outc.rgb = mix(outc.rgb, inner_c, 0.9);
			outc.a = max(outc.a, 0.9 * (1.0 - 0.5 * fade));
		}
		if (best_d < core_width_px + 0.5) {
			outc = vec4(core_c, 1.0 - 0.3 * fade);
		}
	}

	COLOR = outc;
}
