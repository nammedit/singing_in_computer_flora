


~ring_amp_pattern = Pseg([1.0,0.4,1.0],[2,2],repeats:inf).asStream;
Tdef(\ring1, {
	loop{
		0.1.wait;
		~ring_amp = ~ring_amp_pattern.next;
		if(~ring_amp < 0.42, {~ring_color = ~ring.choose});
	};
});
Tdef(\ring1).quant = 0.01;


~eratic_amp_pattern = Pseg([0.6,0.55,0.6,0.5,0.6,0.4,0.5,0],[7,7,6,10,7,5,18],repeats:inf).asStream;
~eratic_highrange_pattern = Pseg([6,36,36],[60,10000],repeats:inf).asStream;
~eratic_lowrange_pattern = Pseg([-18,25,25],[60,10000],repeats:inf).asStream;
~eratic_fast_pattern = Pseg([Pwhite(0.01,0.09,1),Pwhite(0.01,0.09,1)],[Pwhite(0.5,10,1)],repeats:inf).asStream;
~eratic_slow_pattern = Pseg([0.8,0.1,0.8],[Pwhite(50,70,1),Pwhite(50,70,1)],repeats:inf).asStream;
~eratic_prob_pattern = Pwrand([Pwhite(0.5,1.0,1),Pwhite(0.8,1.0,1),1.0],[0.2,0.2,0.6],inf).asStream;
Tdef(\eratic_control, {
	loop{
		~eratic_amp = ~eratic_amp_pattern.next;
		~highrange = ~eratic_highrange_pattern.next;
		~lowrange = ~eratic_lowrange_pattern.next;
		~fast_pick = ~eratic_fast_pattern.next;
		~slow_pick = ~eratic_slow_pattern.next;
		if(~eratic_amp < 0.56, {
			if(~eratic_amp > 0.54, {~dur_prob = ~eratic_prob_pattern.next});
		});
		if(~eratic_amp.asFloat <= 0.00001.asFloat, {Pdef(\eratic).stop; Tdef(\eratic_control).stop;"eratic ended".postln});
		0.1.wait;
	};
});
Tdef(\eratic_control).quant = 0.01;


~flush_amp2_pattern = Pseg([0,0.7,0.7],[5],repeats:1).asStream;
Tdef(\start_flush2, {
	~flush_pitch = 0;
	~flush_note = Pdefn(\flush_pattern, Pseq([
			18,51,77,103
],inf).asInt + Pfuncn({~flush_pitch},inf)).asStream;
	~player = a.play;
	loop{
		var next_flushamp2 = ~flush_amp2_pattern.next;
		if(next_flushamp2 != nil, {~flush_amp2 = next_flushamp2}, {
			Tdef(\start_flush2).stop;
		});
		0.05.wait;
	}
});
Pdef(\eratic).stop;

Tdef(\flush_to_wav_envelope, {
	~trans_envelope = Pseg([0,1,1],[60,10000],repeats:inf).asStream;
	loop{
		~trans_val = ~trans_envelope.next;
		~player.set(\sRate, ~trans_val.linlin(0,1,100,30));
		~bypass_prob = ~trans_val.linlin(0,0.2,1,0);
		0.01.wait;
		if(~trans_val.asInt >= 1.asInt, {"transformation complete".postln; Tdef(\flush_to_wav_envelope).stop; ~react4 = false});
	};
});
Tdef(\flush_to_wav_envelope).quant = 0.01;
