use <TinyDoveTail.scad>

width=40;
height=20;
depth=10;
difference(){
    cube([width, depth, height], center =    false);
    translate([width/2, 0, 0])
        CreateTinyDoveTail(10, 0);
}