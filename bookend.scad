use <TinyDoveTail.scad>

width=40;
height=20;
depth=10;
round_corner=2;

extra_clearance=0;
tight_clearance=0.2 + extra_clearance;
t30_bottom_thickness = 4;
t30_top_thickness = 5;
extra_thickness = 1.9;
bottom_thickness = t30_bottom_thickness - tight_clearance;
top_thickness = t30_top_thickness+extra_thickness;
total_thickness = bottom_thickness + t30_top_thickness + extra_thickness;

$fn=100;
union() 
{
    difference()
    {
    hull()
    {
        cube([width, 10, depth], center =    false);
        translate([round_corner,height-round_corner,0])
            cylinder(h=depth, r=round_corner, center=false);
        translate([width-round_corner,height-round_corner,0])
            cylinder(h=depth, r=round_corner, center=false);
    }
    
      union() {
        // dove_enlarge=-0.05;
        // translate([width/2,bottom_thickness*2,5+2*dove_enlarge])
        translate([width/2,bottom_thickness*2,5])
        scale([1,0.9,1]) // 0.9 give it a snap effect
        rotate([-90,0,0])
          CreateTinyDoveTailSpacingCube(
              positive=false,
              thickness=top_thickness
            );
        
        // translate([width/2,bottom_thickness,5+2*dove_enlarge])
        translate([width/2,bottom_thickness,5])
        rotate([-90,0,0])
          CreateTinyDoveTail(
            positive=false,
            thickness=top_thickness
            );

      } // union
    } // difference
    
    // if (create_dovetail_back) {
    {
        translate([width/2,bottom_thickness,5+depth])
        rotate([-90,0,0])
            CreateTinyDoveTail(positive=true, thickness=top_thickness); 
    };
}