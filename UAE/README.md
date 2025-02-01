Have been working with the UAE debugger and I'm getting used to it. Here are my steps trying to solve serious problems (code which took over the system)

1. put a loop waiting for the left mousebutton right after the start of the code
2. put a string (dc.b. "[whatever]") near the location where I presume the faulty code
3. start the program, program stays in wait-loop
4. enter Shift-F12 starting the uae debugger
5. search for the string > s "[whatever] < in memory, at least one address should be found
6. disassembling the memory at given address, > d $xxxxxx <
7. searching for the spot where I want to have the breakpoint, setting the bp with > f $xxxxxx <
8. quit the uae debugger and continuing the emulation
9. hit the left mousebutton
10. when the program stops at the breakpoint I follow the program with > t < or > z < (tip, within a dbxx loop >z< completely handles the loop)
11. anything after this is more or less related to the error, usually I seach for wrong pointers or condition codes (a wrong test or branch maybe?) 
