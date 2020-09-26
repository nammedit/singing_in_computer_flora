~file = Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/fugler_vega.wav", bufnum:1);


a = {
	|sRate=100, sampleAmp=0.2|
	var filters = Array(88);
	var amps = Array(88);
	var sig = PlayBuf.ar(1,1,loop:1);
	88.do{
		|item,index|
		filters.add(BPF.ar(sig, freq:(index+21).midicps, rq:0.01));
	};
	filters.do{
		|item,index|
		amps.add(Amplitude.kr(item));
	};
	SendReply.kr(Impulse.kr(sRate), "/anal", amps);
	sig * sampleAmp;
};


//fugler - lower 0.5, upper 1.5

// ~trans_env = Pseg([0,0,1,1],[7,50,60],repeats:inf).asStream;
~decay = 0.5;
~bypass_prob = 0;
~trans_val = 0;
~wav_amps = Array(88);
~wav_amp = 1.0;
~wav_trans = 0;
~flush_pitch = -12;
~flush_amp2 = 0.4;
~flush_note = Pdefn(\flush_pattern, Pseq([
			60,62,64,65,67,69,71,72,74
],inf).asInt + Pfuncn({~flush_pitch},inf)).asStream;
OSCdef(\midiConverter).free;
OSCdef(\midiConverter, {
	|msg|
	var lower = 1.0;
	var upper = 1.5;
	var data = ~slice.value(msg, 3, msg.size-1);
	var flush_note = ~flush_note.next;
	var bins = ~highest_amps.value(data*100, ~trans_val.linlin(0,1,1,88));
	var bypass = ~bypass_prob.coin;
	bins.do{
		|item|
		if(~trans_val.linlin(0,1,~flush_amp2,item[0]) >= ~trans_val.linlin(0,1,~flush_amp2,lower), {
			~pno.noteOn(0,
				~trans_val.linlin(0,1,flush_note,item[1]+~wav_trans),
				~trans_val.linlin(0,1,~flush_amp2.linlin(0,1,0,100),item[0].linlin(lower,upper,0,90)*~wav_amp);
			);
			AppClock.sched(0.2, ~pno.noteOff(0.1, ~trans_val.linlin(0,1,flush_note,item[1]+~wav_trans)));
		}, {
			if(bypass == true, {
				~pno.noteOn(0,
				~trans_val.linlin(0,1,flush_note,item[1]+~wav_trans),
				~trans_val.linlin(0,1,~flush_amp2.linlin(0,1,0,100),item[0].linlin(lower,upper,0,90)*~wav_amp);
				);
				AppClock.sched(0.2, ~pno.noteOff(0.1, ~trans_val.linlin(0,1,flush_note,item[1]+~wav_trans)));
			});
		});
	};
	// ~trans_val = ~trans_env.next;
},"/anal");