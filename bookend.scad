use <TinyDoveTail.scad>

// adjustable parameters
/* [To Generate] */
Generate="Bookend"; // ["Bookend","Track Cover"]

/* [Bookend Dimension] */
// Width Minimum is 40mm
Bookend_Width=120;
// Height Minimum is 20mm
Bookend_Height=100;
// Depth Minimum is 10mm
Bookend_Depth=10;

Dovetail_Style = "Both Sides"; // ["One Side Positive", "One Side Negative", "Both Sides"] 

/* [Misc Options] */
// Set to >0 to make a hole
Circle_Hole_Diameter=0;

/* [Track Cover Dimension] */
Track_Length=30; // 240

/* [Hidden] */

width=Bookend_Width;
height=Bookend_Height;
depth=Bookend_Depth;
round_corner=5;

will_generate_bookend=Generate=="Bookend";
will_generate_cover=Generate=="Track Cover";

has_positive_connectors=Dovetail_Style == "Both Sides" ||
                        Dovetail_Style == "One Side Positive";
has_negative_connectors=Dovetail_Style == "Both Sides" ||
                        Dovetail_Style == "One Side Negative";
             
circle_hole_diameter=Circle_Hole_Diameter;

track_length=Track_Length;
cover_clearance=0.5; // 0.5mm per side
                            
connector_offset=20;
connector1_pos=connector_offset;
connector2_pos=width-connector_offset;

// below tested with slider code, try not to change 
extra_clearance=0;
tight_clearance=0.2 + extra_clearance;
t30_bottom_thickness = 4;
t30_bottom_width = 23.4;
t30_top_thickness = 5;
extra_thickness = 1.9;
bottom_thickness = t30_bottom_thickness - tight_clearance;
top_thickness = t30_top_thickness+extra_thickness;
total_thickness = bottom_thickness + t30_top_thickness + extra_thickness;

module create_negative_connector(position=20)
{
    union() {
        translate([position,bottom_thickness*2,5])
        scale([1,0.9,1]) // 0.9 give it a snap effect
        rotate([-90,0,0])
          CreateTinyDoveTailSpacingCube(
              positive=false,
              thickness=top_thickness
            );
        
        translate([position,bottom_thickness,5])
        rotate([-90,0,0])
          CreateTinyDoveTail(
            positive=false,
            thickness=top_thickness
            );

      } // union
}
module create_positive_connector(position=20)
{
    translate([position,bottom_thickness,5+depth])
        rotate([-90,0,0])
            CreateTinyDoveTail(positive=true, thickness=top_thickness); 
}
    
$fn=100;
if (will_generate_bookend) {
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
        if (circle_hole_diameter > 0) {
            r=circle_hole_diameter/2;
            // depth/2 make sure the hole goes thru
            translate([width/2,height-r*1.25,depth/2])
            cylinder(depth*2,r,r,center=true);
        }
   
        if (has_negative_connectors) {
                create_negative_connector(position=connector1_pos);
                create_negative_connector(position=connector2_pos);
        }
 
    } // difference
    
    if (has_positive_connectors) {
        create_positive_connector(position=connector1_pos);
        create_positive_connector(position=connector2_pos);
    };
} // end union
} // end if

if (will_generate_cover) {
    difference()
    {
        // cover body
        cube([width, track_length, 15], center = false);
        
        cover_width=t30_bottom_width+cover_clearance*2;
    
        // opening for track
        color("red")
        translate([connector1_pos,0,0])
          translate([-cover_width/2,0,0])
          cube([cover_width, 
            track_length, 
            total_thickness+cover_clearance], center = false);
        
        color("green")
        translate([connector2_pos,0,0])
          translate([-cover_width/2,0,0])
          cube([cover_width, 
            track_length, 
            total_thickness+cover_clearance], center = false);
    }
}
