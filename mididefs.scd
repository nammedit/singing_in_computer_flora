

MIDIdef(\ring_on).free;
MIDIdef(\ring_off).free;

~ring_color = ~ring[0];
~active = Array.fill(128,nil);
~ring_amp = 0;
~ring_shift = 0;
MIDIdef.noteOn(\ring_on, {
	|val,num,chan,src|
	if(src == ~pno_src, {
		~active[num] = Array(~ring_color.size);
		~ring_color.do{
			|item|
			~pno.noteOn(0, num+(item.asInt)+~ring_shift, (val*~ring_amp).asInt);
			~active[num].add((item.asInt+~ring_shift).asInt);
		};
		if(num==97, {~static_pattern_pitch2 = -23}, {~static_pattern_pitch2 = 0});
	});
});
MIDIdef.noteOff(\ring_off, {
	|val,num,chan,src|
	~active[num].do{
		|item|
		~pno.noteOff(0, num+item)
	};
	~active[num] = nil;
});

~static_pattern_pitch = 0;
~static_pattern_pitch2 = 0;
~static_pattern_amp = 0;
~active2 = Array.fill(128,nil);
~static_pattern = Pseq([
	[56,58,61,67]+Pwrand([0,12],[0.65,0.35],1),
	[60,63,68,70],
	Prand([[56,58,61,66],[58,60,61,68]],1)
],inf).asStream + Pfuncn({~static_pattern_pitch},inf).asStream + Pfuncn({~static_pattern_pitch2},inf).asStream;
~cluster_pattern = [69,70,71,72,73,74] + Pwhite(10,30,inf).asStream;
~cluster_prob = 0;

MIDIdef.noteOn(\static_pattern, {
	|val,num,chan,src|
	var next = ~static_pattern.next;
	if(~cluster_prob.coin, {next = ~cluster_pattern.next}, {next = ~static_pattern.next});
	if(next.isInteger, {
			~pno.noteOn(0, next, (val*~static_pattern_amp).asInt);
		}, {
			next.do{
				|item|
				~pno.noteOn(0, item, (val*~static_pattern_amp).asInt);
			};
		});
		~active2[num] = next;
});
MIDIdef.noteOff(\static_pattern_off, {
	|val,num|
	if(~active2[num].isInteger, {
		~pno.noteOff(0, ~active2[num]);
	});
	if(~active2[num].isArray, {
		~active2[num].do{
			|item|
			~pno.noteOff(0, item);
		};
	});
	~active2[num] = nil;
});


MIDIdef(\loop_control).free;
MIDIdef.cc(\loop_control, {
	|val,num,chan,src|
	if(num==~multiknob_num, {
		~trans_val = val.linlin(0,127,1,0);
		~player.set(\sRate, val.linlin(0,127,30,100));
		~bypass_prob = val.linlin(97,127,0,1);
		~flush_pitch = val.linlin(0,127,-12,5);
		~ring_shift = val.linlin(64,127,0,12);
		~wav_trans = val.linlin(0,90,0,-15);
		~static_pattern_pitch = val.linlin(0,127,-12,12);
	});

	if(num==41, {
		~coinprob1 = val.linlin(0,127,0.0,1.0);
		~coinprob2 = val.linlin(50,127,0.0,0.5);
	});

	if(num==~ring_shift_num, {
		~ring_shift = val.linlin(0,127,-12,12);
		~ring_shift2 = val.linlin(0,127,-12,12);
		("ring_shift at " ++ ~ring_shift.asInt).postln;
	});

	if(num==~flush_amp_num, {
		~flush_amp = val.linlin(0,127,0,0.8);
		~flush_tempo = 0.01;
		if(val==0, {Pdef(\flush).stop}, {
			if(Pdef(\flush).isPlaying == false, {Pdef(\flush).play});
		});
		("flush_amp at " ++ ~flush_amp).postln;
	});

	if(num==22, {
		~flush_amp2 = val.linlin(0,127,0,0.8);
	});

	if(num==~flush_pitch_num, {~flush_pitch = val.linlin(0,127,-12,23); ("flush_pitch at " ++ ~flush_pitch.asInt).postln;});

	if(num==26, {
		var pattern = ~pat1_patterns[val.linlin(0,127,0,~pat1_patterns.size-1)];
		~pat1 = ~int_pat.value(20, pattern);
		~chord_pat = ~harmonize.value(~pat1, [[7,11],[7,10,15]]);
	});

	if(num==~ring_color_num, {
		~ring_color = ~ring[(val.linlin(0,127,0,~ring.size-1)).asInt];
		("ring_color set to " ++ ~ring[(val.linlin(0,127,0,~ring.size-1)).asInt]).postln;
	});

	if(num==~glissando_num, {
		~pat_index = val.linlin(0,127,0,~pat1.size-1);
		~current = ~pat1[~pat_index];
		if(~current != ~current2, {
			~pno.noteOn(0, ~current, ~arp_amp);
			~pno.noteOff(0, ~current);
		});
		~current2 = ~pat1[~pat_index];
		~eratic_amp = 0;
		~wav_amp = val.linlin(0,127,1,0);
	});
	if(num==45, {
		~pat_index2 = val.linlin(0,127,0,~chord_pat.size-1);
		~current2_1 = ~chord_pat[~pat_index2];
		~chord_pat[val.linlin(0,127,0,~chord_pat.size-1)].do{
			|note|
			if(~current2_1 != ~current2_2, {
				~pno.noteOn(0, note, rrand(~arp_amp, ~arp_amp+0.15));
				~pno.noteOff(0, note, rrand(~arp_amp, ~arp_amp+0.15));
			});
		};
		~current2_2 = ~current2_1;
		~eratic_amp = 0;
	});

	if(num==~ring_amp_num, {~ring_amp = val.linlin(0,127,0,1); ("ring_amp at " ++ ~ring_amp).postln});

	if(num==~static_pattern_amp_num, {~static_pattern_amp = val.linlin(0,127,0,1); ("static_pattern_amp at " ++ ~static_pattern_amp).postln});

	if(num==~static_pattern_pitch_num, {~static_pattern_pitch = val.linlin(0,127,-12,12).asInt; ("static_pattern_pitch at " ++ ~static_pattern_pitch).postln});

	if(num==37, {
		~coinprob2 = val.linlin(0,127,0.5,1.0);
	});
});

MIDIdef(\state_changer).free;
~react1 = false;
~react2 = false;
~react3 = true;
~react4 = false;
MIDIdef.noteOn(\state_changer, {
	|val,num,chan,src|
	if(src == ~kbd_src, {

		//TDEF-TRIGGERS
		if(num==48, {
			if(Tdef(\ring1).isPlaying == true, {Tdef(\ring1).stop}, {Tdef(\ring1).play});
		});
		if(num==49, {
			if(Tdef(\static_p1).isPlaying == true, {Tdef(\static_p1).stop}, {Tdef(\static_p1).play});
		});
		if(num==50, {
			if(Tdef(\eratic_control).isPlaying == true, {Tdef(\eratic_control).stop},{Tdef(\eratic_control).play});
			if(Tdef(\start_flush2).isPlaying == false, {Tdef(\start_flush2).play});
		});
		if(num==55, {
			if(Tdef(\flush1).isPlaying == true, {Tdef(\flush1).stop}, {Tdef(\flush1).play});
		});
		if(num==57, {
			if(Tdef(\static_pitch_down).isPlaying == true, {Tdef(\static_pitch_down).stop}, {Tdef(\static_pitch_down).play});
		});

		//REACT-TRIGGERS
		if(num==54, {
			if(~react1 == false, {~react1 = true}, {~react1 = false});
		});
		if(num==56, {
			if(~react2 == false, {~react2 = true}, {~react2 = false});
		});
		if(num==58, {
			if(~react3 == false, {~react3 = true}, {~react3 = false});
		});
		if(num==59, {
			if(~react4 == false, {~react4 = true}, {~react4 = false});
			"react activated".postln;
		});

		//FLUSH-PATTERN CHANGE
		if(num==61, {
			Pdefn(\flush_pattern, Pseq([
				18,51,69,73,77,80,90,100,103
			],inf).asInt + Pfuncn({~flush_pitch},inf));
			"flush_pattern changed".postln;
		});
		if(num==62, {
			Pdefn(\flush_pattern, Pseq([
				18,51,77,80,90,100,103
			],inf).asInt + Pfuncn({~flush_pitch},inf));
			"flush_pattern changed".postln;
		});
		if(num==63, {
			Pdefn(\flush_pattern, Pseq([
				18,51,77,103
			],inf).asInt + Pfuncn({~flush_pitch},inf));
			"flush_pattern changed".postln;
		});
		if(num==64, {
			Pdefn(\flush_pattern, Pseq([
				61,65,68,72,74,78,81,85
			],inf).asInt + Pfuncn({~flush_pitch},inf));
			"flush_pattern changed".postln;
		});
		if(num==65, {
			Pdefn(\flush_pattern, Pseq([
				83,82,81,80,79,78,77,76,75,74,73
			],inf).asInt + Pfuncn({~flush_pitch},inf));
			"flush_pattern changed".postln;
		});
		if(num==66, {
			Pdefn(\flush_pattern, Pseq([
				60,62,64,65,67,69,71,72,74
			],inf).asInt + Pfuncn({~flush_pitch},inf));
			"flush_pattern changed".postln;
		});

		//FLUSH -> WAV TRANSFORMATION
		if(num==84, {
			"transformation started".postln;
			if(Tdef(\flush_to_wav_envelope).isPlaying == false, {
				Tdef(\flush_to_wav_envelope).play;
			});
		});
	});
});


~top_amp = 0.3;
~steps = 17;
~amp_pattern1 = Pseq(~triangle.value(0, ~top_amp, ~steps), inf).asStream;
~pitch_pattern1 = Pseq(~triangle.value(-12, 24, rrand(5, 15)), inf).asStream;
~steps_pattern1 = Pseq(~triangle.value(17,3,7),inf).asStream;
~coinprob1 = 0;
~coinprob2 = 0.2;
~final_stage = false;
~stage_one = true;
~de_incr = 0.01;
~de_incr2 = 0.2;
~note_count = 0;
MIDIdef.noteOn(\pattern_pattern, {
	|val,num,chan,src|
	if(src == ~pno_src, {
		if(~react1 == true, {
			~flush_amp = val.linlin(0,127,0,1)*0.6;
			~flush_pitch = num.linlin(60,99,-12,12).asInt+[0,12].choose;
			~flush_tempo = val.linlin(20,110,0.03,0.007);
		});

		if(~react2 == true, {
			~eratic_amp = val.linlin(0,127,0,1)*0.8;
			~dur_prob = val.linlin(0,110,0.5,1.0);
			~sus_prob = num.linlin(60,99,0.8,1.0);
			~slow_pick = num.linlin(0,110,0.7,0.1);
			~fast_pick = val.linlin(0,127,0.15,0.005);
			~lowrange = num.linlin(60,108,20,-18);
			~highrange = num.linlin(72,90,30,10);
		});

		if(~react3 == true, {
			var pattern = ~pat1_patterns[val.linlin(0,127,0,~pat1_patterns.size-1)];
			~arp_amp = val*1.1;
			~pat1 = ~int_pat.value(20, pattern);
			~chord_pat = ~harmonize.value(~pat1, [[7,11],[7,10,15]]);
		});

		if(~react4 == true, {

			if(~stage_one == false, {
				~eratic_amp = 0;
				~flush_amp = ~amp_pattern1.next;
				if(~coinprob2.coin, {
					~flush_amp = 0;
					if(Pdef(\eratic).isPlaying == false, {Pdef(\eratic).play});
					~eratic_amp = 0.6;
				});
				~flush_pitch = ~pitch_pattern1.next;
				if(~flush_amp == 0, {
					"yes".postln;
					if(~final_stage = false, {
						if(~steps > 3, {~steps = ~steps - 2}, {~final_stage = true});
					}, {
						~steps = rrand(3,8);
					});
					// ~steps = ~steps_pattern1.next;
					if(~top_amp < 0.6, {~top_amp = ~top_amp + 0.05}, {~final_stage = true});
					~amp_pattern1 = Pseq(~triangle.value(0, ~top_amp, ~steps), inf).asStream;
					~flush_amp = ~amp_pattern1.next;
				});
				if(~coinprob1.coin, {
					var pattern = ~flush_patterns.choose;
					"change".postln;
					Pdefn(\flush_pattern, Pseq(pattern, inf).asInt + Pfuncn({~flush_pitch},inf));
				});
			}, {
				if((~flush_amp-~de_incr) <= 0, {~flush_amp = 0; ~stage_one = false}, {
					if(~flush_amp > 0, {~flush_amp = ~flush_amp - ~de_incr});
				});
			});
			~note_count = ~note_count + 1;
			if(~note_count <= 276, {
				~coinprob1 = ~note_count.linlin(0,276,0.0,1.0);
				~coinprob2 = ~note_count.linlin(0,276,0.0,0.5);
			}, {
				~coinprob2 = ~note_count.linlin(300,276+60,0.5,1.0);
			});
		});
	});
});

