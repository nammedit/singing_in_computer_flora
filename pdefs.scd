
~a_sweep = 0;
~sus = 1;
~root = 0;
~tempo_7_top = 0.05;
~tempo_7_bot = 0.05;
Pdef(\sweep,
	Pbind(
		\type, \midi,
		\midicmd, \noteOn,
		\midiout, ~pno,
		\root, Pfuncn({~root},inf),
		\scale, Scale.minor,
		\degree, Plet(\degree1, Pseg([-20,30,-20],[Pwhite(0.1,2,inf),Pwhite(0.5,2,inf)],repeats:inf).asInt),
		\dur, Plet(\dur1, Pwhite(Pfuncn({~tempo_7_bot},inf),Pfuncn({~tempo_7_top},inf),inf)),
		\sustain, Pfuncn({~sus},inf),
		\amp, Pfuncn({~a_sweep},inf)
	);
);
Pdef(\sweep).quant = 0.001;

~flush_patterns = [[21,51,77,103],[61,65,68,72,74,78,81,85],[83,82,81,80,79,78,77,76,75,74,73],[60,62,64,65,67,69,71,72,74]];
// 0.01;

~flush_tempo = 0.01;
~flush_amp = 0.15;
~flush_pitch = -12;
~amp_trans = 0;
~flush_pattern = Pdefn(\flush_pattern, Pseq([
			60,62,64,65,67,69,71,72,74
		],inf).asInt + Pfuncn({~flush_pitch},inf)).asStream;
Pdef(\flush,
	Pbind(
		\type, \midi,
		\midicmd, \noteOn,
		\midiout, ~pno,
		// \midiout, ~sibelius,
		// \midiout, Pif(Pfuncn({~flush_amp},inf) > 0, ~sibelius, ~pno),
		\midinote, Pdefn(\flush_pattern, Pseq([
			60,62,64,65,67,69,71,72,74
		],inf).asInt + Pfuncn({~flush_pitch},inf)),
		// \midinote, Pfuncn({~note1},inf),
		\dur, Pfuncn({~flush_tempo},inf),
		\sustain, 0.01,
		\amp, Pfuncn({~flush_amp},inf)
	);
);
Pdef(\flush).quant = 0.01;

~eratic_amp = 0.5;
~dur_prob = 0.98;
~sus_prob = 1.0;
~slow_pick = 0.1;
~fast_pick = 0.03;
~lowrange = -18;
~highrange = 36;
Pdef(\eratic,
	Pbind(
		\type, \midi,
		\midicmd, \noteOn,
		\midiout, ~pno,
		// \midiout, Pif(Pfuncn({~eratic_amp},inf) > 0, ~sibelius, ~pno),
		// \midiout, ~sibelius,
		\degree, Pseg(
			[Pwhite(Pfuncn({~lowrange},inf),Pfuncn({~highrange},inf),1),
			Pwhite(Pfuncn({~lowrange},inf),Pfuncn({~highrange},inf),1)],
			[Pdefn(\runtime, Pwhite(0.1,0.9,inf))],repeats:inf),
		\dur, Pwrand(
			[Pfuncn({~fast_pick}),Pfuncn({~slow_pick})],
			Pfuncn({[~dur_prob,1-~dur_prob]},inf),inf),
		\sustain, Pwrand(
			[0.001,0.7],
			Pfuncn({[~sus_prob, 1-~sus_prob]},inf),inf),
		\amp, Pfuncn({~eratic_amp},inf)
	);
);
Pdef(\eratic).quant = 0.001;

~echo_patterns = [[12,24,31],[12,24],[-12,12,2,24],[12,24,36]];
~i_echo = 60;
~echo_amp = 0;
~dur_upper = 0.07;
~echo_pattern = [12,24,31];
Pdef(\echo,
	Pbind(
		\type, \midi,
		\midicmd, \noteOn,
		\midiout, ~pno,
		// \midinote, Pfuncn({~i_echo},inf) + Prand([12,24,31],inf),
		\midinote, Pdefn(\echo_pattern, Pfuncn({~i_echo},inf) + Prand([12,24,31],inf)),
		\dur, Pwhite(0.05,Pfuncn({~dur_upper},inf),inf),
		\sustain, Pwhite(0.05,0.15,inf),
		\amp, Pif(Pfuncn({~echo_amp},inf) > 0, Pwhite(Pfuncn({~echo_amp},inf)-0.1, Pfuncn({~echo_amp},inf)+0.3), 0)
	);
);
Pdef(\echo).quant = 0.001;


