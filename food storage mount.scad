include <TinyDoveTail.scad>

Create_Dovetail="positive"; // ["positive","negative","none"]

/* [Hidden] */

width=66;
plate_thickness=5;
will_create_positive=Create_Dovetail=="positive";
will_create_negative=Create_Dovetail=="negative";

// tested code below
t30_top_thickness = 5;
extra_thickness = 1.9;
top_thickness = t30_top_thickness+extra_thickness;

extra_clearance=0;
tight_clearance=0.2 + extra_clearance;
t30_bottom_thickness = 4;
extra_thickness = 1.9;
bottom_thickness = t30_bottom_thickness - tight_clearance;

module CreatePlate()
{
  $fn=100;
  
  difference(){
  cube([width,plate_thickness,width]);
  translate([33,15,40])
    rotate([90,0,0])
    cylinder(h=25,r=21.5);
  }
}

difference() {
    CreatePlate();
    if (will_create_negative) {
      CreateTinyDoveTailSpacingCube(
          positive=false,
          thickness=top_thickness
          );
        
      translate([width/2, 0,bottom_thickness])  
      CreateTinyDoveTail(
          positive=false, 
          thickness=top_thickness);
    } 
}
if (will_create_positive) {
   translate([width/2, -plate_thickness,bottom_thickness])
   CreateTinyDoveTail(positive=true, thickness=top_thickness); 
}



