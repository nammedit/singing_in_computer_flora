

/*
Firstly, there are two ways to evaluate code in Supercollider:
1. Evaluating single lines: put the cursor on the wanted line and press shift+enter
2. Evaluating bracket contents: put the cursor anywhere inside the bracket (enclosed in "(" and ")") and press ctrl+enter (cmd+enter on mac)
*/

/*
Set audio interface and boot;
If unsure about the name of your device, evaluate the ServerOptions.devices on line 13 first and look in the Post window for a list of all the in- and out-devices available to your computer;
Replace the "your_device"-text on line 16 with the name of your device enclosed in quotes like the placeholder text and evaluate the bracket contents starting line 15 ending line 17
TIP: text from the Post window can be copy-pasted
*/
ServerOptions.devices;
(
Server.killAll;
s.options.device = "Scarlett 2i2 USB";
s.reboot;
)




//Evaluate the small bracket under this comment and look in the Post window to see all connected MIDI-interfaces on the computer to find the name of the piano
(
MIDIClient.init;
MIDIIn.connectAll;
)
//Enter the name of your piano-MIDI-interface as variable "pno_name" on line 33
//Evaluate the bracket-contents from line 31 to 36 to establish the connection to the piano
(
var pno_name = "UM-ONE";
MIDIClient.destinations.do{
	|item,index|
	if(item.name == pno_name, {~pno = MIDIOut(index)});
};
~pno.latency = 0.001;
)

~pno.noteOn(0,60);


//Setting the MIDI source of the Piano and MIDI-keyboard
(
//evalute this whole bracket starting on line 44 ending on line 58
//press a key on the acoustic piano, and set the variable ~pno_src on line 40 to the number that appeared in the Post window
//turn a knob on the midi-keyboard, and set the variable ~kbd_src on line 41 to the new number that appeared in the Post window
//evaluate the bracket again, and press ctrl+. (cmd+. on mac) to clear the MIDIdefs
~pno_src = -1605535755;
~kbd_src = -1351172151;
MIDIdef(\set_pno).free;
MIDIdef.noteOn(\set_pno, {
	|val,num,chan,src|
	("~pno_src = " ++ src).postln;
});
MIDIdef(\set_kbd).free;
MIDIdef.cc(\set_kbd, {
	|val,num,chan,src|
	("~kbd_src = " ++ src).postln;
});
)

/*~ring_color_num = 44;
~ring_shift_num = 42;
~ring_amp_num = 39;

~flush_amp_num = 21;
~flush_pitch_num = 17;

~static_pattern_amp_num = 40;
~static_pattern_pitch_num = 35;
~glissando_num = 43;
~multiknob_num = 24;*/

~coinprob2;

//Mapping knobs to parameters found in the score
(
//evaluate the bracket-contents starting on line 69 ending on line 86
//any knob you turn on the midi-keyboard will make its ID-number appear in the Post window
//link a knob for each parameter by replacing "nil" with the ID-number of the knob you wish to link it to
//when all parameters have a unique ID-number that corresponds to knobs on your keyboard, i.e all parameters are linked, evaluate the bracket again and press ctrl+.
~ring_color_num = 44;
~ring_shift_num = 42;
~ring_amp_num = 39;

~flush_amp_num = 21;
~flush_pitch_num = 34;

~static_pattern_amp_num = 40;
~static_pattern_pitch_num = 35;
~glissando_num = 43;
~multiknob_num = 24;
MIDIdef.cc(\set_numbers, {
	|val,num|
	num.postln;
});
)

Tdef.all;
//Loading the other files
(
//evalute the this bracket-content, spanning from line 105 to 109 to active the rest of the code & you're ready to play
MIDIdef.all.do{
	|item|
	item.free;
};
(thisProcess.nowExecutingPath.dirname ++ "/functions.scd").load;
(thisProcess.nowExecutingPath.dirname ++ "/loops.scd").load;
(thisProcess.nowExecutingPath.dirname ++ "/mididefs.scd").load;
(thisProcess.nowExecutingPath.dirname ++ "/tdefs.scd").load;
(thisProcess.nowExecutingPath.dirname ++ "/wav_trans.scd").load;
)

(thisProcess.nowExecutingPath.dirname ++ "/wav_trans.scd").openDocument;
(thisProcess.nowExecutingPath.dirname ++ "/tdefs.scd").openDocument;
(thisProcess.nowExecutingPath.dirname ++ "/mididefs.scd").openDocument;
(
("1   "++~coinprob1).postln;
("2   "++~coinprob2).postln;
)

/*(
//  GUI
w = Window.new("Singing in Computer Flora - performance GUI", Rect(200,200,900,900));
~cc_listen = false;
~listening_for_num = nil;

~listener_button = Button(w, Rect(100,200,60,40)).string_("cc_listen")
.action_({
	if(~cc_listen == true, {
		~cc_listen = false;
		MIDIdef(\change_num).free;
	},{
			~cc_listen = true;
			MIDIdef.cc(\change_num, {
				|val,num,chan,src|
				~listening_for_num = num;
				~listening_for_num.postln;
			});
	});
});

~ringcolor_knob = Knob.new(w, Rect(50,50,50,50)).action_({~listening_for_num = ~ring_color_num});
~rck_text = StaticText(w, Rect(50-4,50-17,60,15)).string_("ring_color");
~ringshift_knob = Knob.new(w, Rect(50+60,50,50,50)).action_({~listening_for_num = ~ring_shift_num});
~ringamp_knob = Knob.new(w, Rect(50+120,50,50,50));
w.front;
)*/
