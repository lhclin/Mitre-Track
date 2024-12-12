use <TinyDoveTail.scad>
use <gridfinity-rebuilt-baseplate.scad>

// adjustable parameters
/* [To Generate] */
Generate="Bookend"; // ["Bookend","Track Cover"]

/* [Bookend Dimension] */
// Width Minimum is 40mm
Bookend_Width=126;
// Height Minimum is 20mm
Bookend_Height=105;
// Depth Minimum is 10mm
Bookend_Depth=14;

Dovetail_Style = "Both Sides"; // ["One Side Positive", "One Side Negative", "Both Sides"] 

/* [Track Cover Dimension] */
Track_Length=168; // 42
Cover_Style="Flat"; // ["Flat","Gridfinity"]

/* [Hidden] */

width=Bookend_Width;
height=Bookend_Height;
depth=Bookend_Depth;
round_corner=5;

will_generate_bookend=Generate=="Bookend";
will_generate_cover=Generate=="Track Cover";

// DEBUG
// will_generate_bookend=false;
// will_generate_cover=true;

has_positive_connectors=Dovetail_Style == "Both Sides" ||
                        Dovetail_Style == "One Side Positive";
has_negative_connectors=Dovetail_Style == "Both Sides" ||
                        Dovetail_Style == "One Side Negative";
             
circle_hole_diameter=0; // obsolete

track_length=Track_Length;
cover_depth=14;
cover_clearance=0.5; // 0.5mm per side
gridfinity_cover=Cover_Style=="Gridfinity";
// DEBUG gridfinity_cover=true;
                            
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
        cube([width, track_length, cover_depth], center = false);
        
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
    // Optional gridfinity base 
    if (gridfinity_cover){
        create_gridfinity_cover();
    }
}

module gridfinity1x1basechunk()
{
    $fa = 8;
    $fs = 0.25;
    
    length=42;
    distancex=0;
    distancey=0;
    style_plate=0;
    enable_magnet=false;
    style_hole=0;
    
    hull()
    gridfinityBaseplate(1,1,length,
        distancex,distancey,
        style_plate,style_hole);
}

module gridfinity_fill_corner(corner=0){
    dx=(corner==0)||(corner==3)?4:-4;
    dy=(corner==0)||(corner==1)?4:-4;
    
    translate([-dx,-dy,0]) // translate the corner to origin
    intersection()
    {
       // to show only the specified corner
       translate([dx,dy,0])
            cube([8,8,20],center=true);
    
       // All 4 corners are created below
       difference() 
       {
         // cube that encompasses the base
         intersection()
         { 
            scale([1.5,1.5,1])
            gridfinity1x1basechunk();
            cube([8,8,20],center=true);
         }
         // subtracting the round corners
         // from encompassing cube
         cylinder(20,r=4,center=true);
       } // differnce
    }// intersection
}

module create_gridfinity_cover() 
{
    $fa = 8;
    $fs = 0.25;

    length=42;
    distancex=width; //0;
    distancey=track_length; //0;
    style_plate=0;
    enable_magnet=false;
    style_hole=0;
    
    gridx=floor(width/length);
    gridy=floor(track_length/length);

    translate([distancex/2,distancey/2,cover_depth])
    {
      // create a gridfinity base
      gridfinityBaseplate(gridx,gridy,
          length,distancex,distancey,
          style_plate,style_hole);
      // gridfinity corner is round. Make
      // fillings to sharpen the corder to
      // match the look of the cover
        
      // The corner filling has the corner at
      // origin, so translate them to the cover's
      // cover
      translate([distancex/2,distancey/2,0])
         gridfinity_fill_corner(0);
      translate([-distancex/2,distancey/2,0])
         gridfinity_fill_corner(1);
      translate([-distancex/2,-distancey/2,0])
         gridfinity_fill_corner(2);
      translate([distancex/2,-distancey/2,0])
         gridfinity_fill_corner(3);
    }   
}
