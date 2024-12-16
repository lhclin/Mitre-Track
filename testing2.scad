include <ScrewLibrary.scad>

$fn=32;

h1=0;
h2=15;

//testing block
block_length=70;

difference()
{
translate([block_length/2,0,4]) cube([block_length,15,8],center=true);
/*
translate([10,0,0])
CreateScrew(US5FlatStr, h1, h2);

translate([20,0,0])
CreateScrew(US6FlatStr, h1, h2);
*/
translate([30,0,0])
CreateScrew(US8FlatStr, h1, h2);

translate([40,0,0])
CreateScrew(US8RoundStr, h1, h2);
    
translate([50,0,0])
CreateScrew(M3NutStr, h1, h2);
    
translate([60,0,0])
CreateScrew(PencilMarkerStr, h1, h2);
}

/*

difference() {
    color("red")
cylinder(10,r=5,$fn=32);
cylinder(10,r=5,$fn=6);}
*/
