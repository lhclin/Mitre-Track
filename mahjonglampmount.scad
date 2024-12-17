include <ScrewLibrary.scad>

$fn=100;


difference(){
    // plate
    translate([0,0,-5])
    cube([50,50,10], center=true);
    
    // screws
    translate([18,18,0])
    rotate([180,0,0])
    CreateScrew(US6FlatStr,0,20);
    
    translate([18,-18,0])
    rotate([180,0,0])
    CreateScrew(US6FlatStr,0,20);
    
    translate([-18,18,0])
    rotate([180,0,0])
    CreateScrew(US6FlatStr,0,20);
    
    translate([-18,-18,0])
    rotate([180,0,0])
    CreateScrew(US6FlatStr,0,20);
}
// mount
translate([0,5,12.5])
rotate([90,0,0])
color("pink")
difference(){
cube([25,25,40], center=true);
cylinder(40,r=6.4,center=true);
}

