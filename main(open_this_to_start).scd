

/*
Hello dear user of this code! First off there are two ways to evaluate code in Supercollider:
1. Evaluating single lines: put the cursor on the wanted line and press shift+enter
2. Evaluating bracket contents: put the cursor anywhere inside the bracket (enclosed in "(" and ")") and press ctrl+enter (cmd+enter on mac)
*/

/*
Set audio interface and boot;
If unsure about the name of your device, evaluate the ServerOptions.devices on line 15 first and look in the Post window for a list of all the in- and out-devices available to your computer;
Replace the "your_device"-text on line 18 with the name of your device enclosed in quotes like the placeholder text and evaluate the bracket contents starting line 16 ending line 20
TIP: text from the Post window can be copy-pasted
*/
ServerOptions.devices;
(
Server.killAll;
s.options.device = "your_device";
s.reboot;
)




//Evaluate the small bracket under this comment and look in the Post window to see all connected MIDI-interfaces on the computer to find the name of the piano
(
MIDIClient.init;
MIDIIn.connectAll;
)
//Enter the name of your piano-MIDI-interface as variable "pno_name"  replacing "nil" on line 30
//Evaluate the bracket-contents from line 32 to 39 to establish the connection to the piano
(
var pno_name = nil;
MIDIClient.destinations.do{
	|item,index|
	if(item.name == pno_name, {~pno = MIDIOut(index)});
};
~pno.latency = 0.001;
)


//Setting the MIDI source of the Piano and MIDI-keyboard
(
//evalute this whole bracket starting on line 43 ending on line 61
//press a key on the acoustic piano, and set the variable ~pno_src on line 48 replacing "nil" to the number that appeared in the Post window
//turn a knob on the midi-keyboard, and set the variable ~kbd_src on line 49 replacing "nil" to the new number that appeared in the Post window
//evaluate the bracket again, and press ctrl+. (cmd+. on mac) to clear the MIDIdefs
~pno_src = nil;
~kbd_src = nil;
MIDIdef(\set_pno).free;
MIDIdef.noteOn(\set_pno, {
	|val,num,chan,src|
	("~pno_src = " ++ src).postln;
});
MIDIdef(\set_kbd).free;
MIDIdef.cc(\set_kbd, {
	|val,num,chan,src|
	("~kbd_src = " ++ src).postln;
	num.postln;
});
)

//Mapping knobs to parameters found in the score
(
//evaluate the bracket-contents starting on line 64 ending on line 84
//any knob you turn on the midi-keyboard will make its ID-number appear in the Post window
//link a knob for each parameter by replacing "nil" with the ID-number of the knob you wish to link it to
//when all parameters have a unique ID-number that corresponds to knobs on your keyboard, i.e all parameters are linked, evaluate the bracket again and press ctrl+.
~ring_color_num = nil;
~ring_shift_num = nil;
~ring_amp_num = nil;

~flush_amp_num = nil;
~flush_pitch_num = nil;

~static_pattern_amp_num = nil;
~static_pattern_pitch_num = nil;
~glissando_num = nil;
~multiknob_num = nil;
MIDIdef.cc(\set_numbers, {
	|val,num|
	num.postln;
});
)

//Loading the other files
(
//evalute the this bracket-content, spanning from line 87 to 98 to active the rest of the code & you're ready to play
MIDIdef.all.do{
	|item|
	item.free;
};
(thisProcess.nowExecutingPath.dirname ++ "/functions.scd").load;
(thisProcess.nowExecutingPath.dirname ++ "/pdefs.scd").load;
(thisProcess.nowExecutingPath.dirname ++ "/mididefs.scd").load;
(thisProcess.nowExecutingPath.dirname ++ "/tdefs.scd").load;
(thisProcess.nowExecutingPath.dirname ++ "/wav_trans.scd").load;
)
