

~ring = [
	[12,14,25],
	[7,13,20,22,27],
	[7,12,13,18],
	[9,12,14,19,20,22],
	[9,15,16,19,23,25],
	[2,9,13,24,26],
	[1,2,3,4,5,6,7]
];

~int_pat = {
	|start, pattern|
	var current, out, index, count;
	out = Array.new(128);
	index = 0;
	current = start;
	while({current < 108}, {
		current = current + pattern[index];
		if(current < 108, {out.add(current)});
		index = index + 1;
		if(index > (pattern.size-1), {index = 0});
	});
	out.insert(0, start);
	out;
};
~pat1_patterns = [[4,3,4,2],[2,1,1],[2,1,1],[2,2,3,-2,6,-5],[4,-2,6,-1,-2,8],[1,4,7,-2,-3,-1,5,-4,-2],
	[5,3,-1,8,-7,2,6,4,-2],[4,3,4,2,4,3,4],[11,-10,7,12,-11],[12,-11,13,-10],[12,17,-22]
];
~harmonize = {
	|list, chordList|
	var out = Array.new(128);
	var temp = Array.new(20);
	list.do{
		|note|
		temp.add(note);
		chordList.choose.do{
			|chordNote, index|
			temp.add(note+chordNote)
		};
		out.add(temp);
		temp = Array.new(20);
	};
	out;
};
~chord_pat = ~harmonize.value(~int_pat.value(20,~pat1_patterns[9]), [[4,10],[9,15]]);

~harmonize.value([60,62,63],[[3,4],[7,11]]);

~distance = {
	arg n1, n2;
	if(n1 > n2, {n1-n2}, {n2-n1});
};

~line = {
	arg start, end, steps;
	var incr = ~distance.value(start, end)/steps;
	var out = Array.new(100);
	var current = start;
	if(start > end, {incr = incr*(-1.0)});
	steps.do{
		current = current + incr;
		out.add(current);
	};
	if(out[out.size-1]<0.01, {out.put(out.size-1, 0);});
	out;
};

~triangle = {
	|bottom, top, steps|
	var line1, line2, line3;
	line1 = ~line.value(bottom, top, steps);
	line1.insert(0, bottom);
	line2 = line1.reverse;
	line2.remove(top);
	line2.remove(bottom);
	line3 = line1++line2;
	line3;
};

~remove_duplicates = {
	|list|
	var out = Array(list.size);
	list.do{
		|item,index|
		var existing = false;
		if(index == 0, {out.add(item)}, {
			out.do{
				|item2|
				if(item == item2, {existing = true});
			};
			if(existing == false, {out.add(item)});
		});
	};
	out;
};

~slice = {
	|list, start, end|
	var out = Array(list.size);
	list.do{
		|item,index|
		if(index >= start, {
			if(index <= end, {out.add(item)});
		});
	};
	out;
};

~n_highest_amps = {
	|list, n, lower_amplimit|
	var out = Array(n);
	var highest_amps = Array(88);
	var count = 0;
	list.do{
		|amp, note|
		highest_amps.add(amp);
	};
	highest_amps = highest_amps.sort.reverse;
	list.do{
		|amp,note|
		n.do{
			|item,index|
			if(amp == highest_amps[index], {
				if(amp*100 >= lower_amplimit, {out.add([amp, note+21])});
			});
		};
	};
	out;
};

~highest_amps = {
	|list, n|
	var out = Array(n);
	var highest_amps = Array(88);
	list.do{
		|item,index|
		highest_amps.add(item);
	};
	highest_amps = highest_amps.sort.reverse;
	list.do{
		|item,index|
		n.do{
			|item2,index2|
			if(item == highest_amps[index2], {out.add([item,index+21])});
		};
	};
	out;
}

