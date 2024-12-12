include <ScrewLibrary.scad>

module u_shape(iwidth=12.5){
u_profile=[[0,0],[0,30],[5+iwidth+5,30],
    [5+iwidth+5,0],
  [5+iwidth,0], [5+iwidth,25],[5,25],[5,0]];
linear_extrude(30)
    polygon(u_profile);
}

// u_shape(iwidth=12.5);

translate([12.5+5,-120,30])
rotate([180,0,0])
    u_shape(iwidth=50);



translate([5+12.5,-120,0])
difference(){
cube([5,120,30]);
translate([0,105,15])
    rotate([0,90,0])
    CreateScrew(US6FlatStr);
translate([0,85,15])
    rotate([0,90,0])
    CreateScrew(US6FlatStr);
}