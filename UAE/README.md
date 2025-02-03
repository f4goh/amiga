
# UAE Software

[UAE software](https://fs-uae.net/download)

- Fs-uae for Linux
- Winuae for windows


# UAE debugger 

- put a loop waiting for the left mousebutton right after the start of the code
- put a string (dc.b. "[whatever]") near the location where I presume the faulty code
- start the program, program stays in wait-loop
- enter Shift-F12 starting the uae debugger
- search for the string > s "[whatever] < in memory, at least one address should be found
- disassembling the memory at given address, > d $xxxxxx <
- searching for the spot where I want to have the breakpoint, setting the bp with > f $xxxxxx <
- quit the uae debugger and continuing the emulation
- hit the left mousebutton
- when the program stops at the breakpoint I follow the program with > t < or > z < (tip, within a dbxx loop >z< completely handles the loop)
- anything after this is more or less related to the error, usually I seach for wrong pointers or condition codes (a wrong test or branch maybe?) 
