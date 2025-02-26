include <ScrewLibrary.scad>
include <Charm.scad>
use <TinyDoveTail.scad>

// user customizable
/* [General] */

Slider_Length=200; // 200;

// Less than 20 will disable holes
Drill_Hole_Distance=45; 

Screw_Style="US#5 Flat"; // ["US#5 Flat","US#6 Flat","US#8 Flat","US#8 Round","M3 Nut","Pencil Marker","custom"]

/* [Custom Screw Size] */
// Use when Screw Style is set to "custom"
Custom_Screw_Head_Height = 0; // Use M3-0.5 socket head as example
Custom_Screw_Head_Diameter = 5.4;
Custom_Screw_Diameter = 2.98;
Custom_Screw_Clearance = 0.5;

/* [Edge Style] */
Front_Style="dovetail"; // ["flat","round","dovetail","screwprofile"]
Back_Style="dovetail"; // ["flat", "dovetail", "bracket", "bracket ring", "charm"]

/* [Bracket] */
// Use when Back Style is set to "bracket"
Bracket_Length=50; // 100;
Bracket_Depth=5; // default to same as T30 thickness(top)
// Minimum # of Bracket Holes is 2
Bracket_Holes=2;
Bracket_Hole_Style="US#5 Flat"; // ["US#5 Flat","US#6 Flat","US#8 Flat","US#8 Round","custom"]

/* [Fine Tuning] */
// Extra Thickness for the slider(mm). For flush slider, use 1.2
Extra_Thickness = 1.9;
// Extra Clearance for the build. Positive for a loose build, negative for tighter
Extra_Clearance = 0;

/* [Hidden] */

// I wrote most of the code before adding customizer. For a nicer looking UI,
// customizer uses different variable names from internal ones.
length=Slider_Length;
drill_hole_distance=Drill_Hole_Distance;

screw_style=Screw_Style;

front_style=Front_Style;
back_style=Back_Style;

bracket_length=Bracket_Length;
bracket_depth=Bracket_Depth;
bracket_holes=Bracket_Holes;
bracket_hole_style=Bracket_Hole_Style;
bracket_hole_margin=10; // not yet customizable

extra_thickness=Extra_Thickness;
extra_clearance=Extra_Clearance;

custom_screw_head_height = Custom_Screw_Head_Height;
custom_screw_head_diameter = Custom_Screw_Head_Diameter;
custom_screw_head_straight = true;
custom_screw_diameter = Custom_Screw_Diameter;
custom_screw_clearance = Custom_Screw_Clearance;

// slightly reduce the length at the bottom of slider to
// compensate for the extra pastic
bottom_joint_compensation = 0.2;

// Probably going to change below as I add more features
create_round_front = front_style == "round";
create_dovetail_front = front_style == "dovetail";
create_dovetail_back = back_style == "dovetail";
create_bracket_back = back_style == "bracket";
create_bracket_ring_back = back_style == "bracket ring";
create_screwprofile_front = front_style == "screwprofile";
create_charm_back = back_style == "charm";

// t30 design parameters
t30_bottom_thickness = 4;
t30_top_thickness = 5;
t30_bottom_width = 23.4;
t30_top_width = 19.3;

// common dimensions

// Desired clearance
tight_clearance = 0.2 + extra_clearance; // for tighter fitting area
loose_clearance = 0.5 + extra_clearance; // for looser fitting area

// Adjust dimension based on the specified clearance
// V1.0 last minute change: fixed the bottom_thickness as other
// projects rely on this thickness. Loosen up on the width
// because field test shows the original design is too tight on
// some print variations
// earlier code:
//bottom_thickness = t30_bottom_thickness - tight_clearance;
// bottom_width = t30_bottom_width - tight_clearance;
bottom_thickness = t30_bottom_thickness - 0.2;
bottom_width = t30_bottom_width - loose_clearance;

top_thickness = t30_top_thickness+extra_thickness;
top_width = t30_top_width - loose_clearance;

top_start_x = (bottom_width - top_width) / 2;
top_end_x = top_start_x + top_width;

total_thickness = bottom_thickness + t30_top_thickness + extra_thickness;
    
// extra 2mm for screw hole depth to provide strength to support the screw
function calc_screw_hole_depth() = screw_style == "custom" ?
  total_thickness - custom_screw_head_height - 2 :
  total_thickness - ScrewHeadHeight(screw_style) - 2;

module CreateSliderRaw(slider_length = 200, drill_hole_distance = 45)
{


    // Define Slider Body. The slider is created by combining a top
    // block and a bottom block. The top block is specified flushed 
    // to the track surface plus additional clearance (user specified)
    bottom_points = [[0,0], 
            [bottom_width, 0], 
            [bottom_width, bottom_thickness],
            [0, bottom_thickness]];
    top_points = [[0, 0],
            [top_width, 0],
            [top_width, top_thickness],
            [0, top_thickness]];
    //screw_hole_depth = total_thickness - US5FlatHeadHeight - 2;
    screw_hole_depth = calc_screw_hole_depth();
    
    difference(){
        // slider body by extrusion of the top and bottom rectangle area, then
        // subtracting the drilled holes
        
        // first the top and bottom blocks
        union() {
            // if the slider is intended to be jointed, do
            // a length compensation for the extra pastic in print
            bl = create_dovetail_back ?
                slider_length - bottom_joint_compensation :
                slider_length;
            linear_extrude(bl)
                polygon(bottom_points);
            linear_extrude(slider_length)
                translate([top_start_x,bottom_thickness])
                    polygon(top_points);
        }
        /*
        linear_extrude(slider_length)
            union(){
                polygon(bottom_points);
                translate([top_start_x,bottom_thickness]) polygon(top_points);
            };
        */

        // then, subtracting the screw holes from the slider body
        // avoid holes too close together
        if (drill_hole_distance > 20) {
            num_of_holes = floor(slider_length / drill_hole_distance);
            // we want an odd number of holes so one hole always at center
            if (num_of_holes % 2 == 0) {num_of_holes = num_of_holes - 1;}

            num_of_holes_one_side = floor(num_of_holes / 2);
            h2 = 15; // screw length, this will be deep enough
            h1 = total_thickness;

            // translate all holes to middle of slider and desired depth
            translate([bottom_width / 2, screw_hole_depth, 0])
                union() {
                    midpoint = slider_length / 2;
        
                    // For each hole, we are tranlating to 
                    // z position relative to midpoint
                    // Also rotate the screw 
                    // The result is a series of holes lining up
                    // to the correct z position
                
                    // centre hole
                    translate([0, 0, midpoint]) rotate([-90, 0, 0]) 
                    /*
                        CreateScrew(screw_style,h1,h2,
                            custom_screw_head_height, custom_screw_head_diameter,
                            custom_screw_diameter, custom_screw_clearance);
                    */
                    
                        CreateScrew(
                          screw_style, h1, h2,
                          head_diameter=custom_screw_head_diameter,
                          head_height=custom_screw_head_height,
                          head_straight=custom_screw_head_straight,
                          body_diameter=custom_screw_diameter,
                          screw_clearance=custom_screw_clearance);

                    // rest of the holes are offset to the centre hole
                    for(i=[1:num_of_holes_one_side]){
                        pos = i * drill_hole_distance;
                        if (midpoint + pos < slider_length - 5) {
                            translate([0, 0, midpoint - pos]) rotate([-90, 0, 0])
                            CreateScrew(
                              screw_style, h1, h2,
                                head_diameter=                               custom_screw_head_diameter,
                                head_height=                               custom_screw_head_height,
                                head_straight=                               custom_screw_head_straight,
                                body_diameter=                               custom_screw_diameter,
                                screw_clearance=                               custom_screw_clearance);
                            
                            translate([0, 0, midpoint + pos]) rotate([-90, 0, 0])
                            CreateScrew(
                              screw_style, h1, h2,
                                head_diameter=                               custom_screw_head_diameter,
                                head_height=                               custom_screw_head_height,
                                head_straight=                               custom_screw_head_straight,
                                body_diameter=                               custom_screw_diameter,
                                screw_clearance=                               custom_screw_clearance);
                        } // end if
                    } // end for
                } // end union of drilled points     
            } // end if drill_hole_distance not too close
        }
} // end module

module CreateRoundCutter(){
    $fn=100;
    rotate([-90,0,0])
        difference(){
            translate([-bottom_width, 0, 0])cube([bottom_width * 2, bottom_width + 1, total_thickness]);
            cylinder(h=total_thickness, r=bottom_width, center=false);
        }
}

module CreateBracket(width=0, depth=0, length=0){
    w=width;
    d=depth;
    
    translate([0,length/2,d/2]) //lie flat, center on xy plane
        rotate([90,0,0]) 
        cube([w, d, length], center = true); 
}
    
// Main
// Create the main slider, round the front if needed, create L bracket if needed

// Need more work:
// final transformation to lie the slider to suggested print face
// note: I want to lay a bracket slider on the side because layering
// this way should produce a stronger joint between the bracket and
// the slider. Even though this will require support to print
// final_rotation= create_bracket_back ? [0,90,0] : [90,0,180];

final_rotation=[90,0,180];
rotate(final_rotation)
// the slider = subtract front feature from body, then attach back feature
union() {
difference()
{
    CreateSliderRaw(length, drill_hole_distance);
    
    // generate the front features that are subtracted
    if (create_round_front) {
        translate([bottom_width /2, 0, bottom_width])
            CreateRoundCutter();
    }
    if (create_dovetail_front) {        
        color("cyan")
        translate([bottom_width/2,
            total_thickness - TinyDoveTailHeight(false,top_thickness),
            TinyDoveTailDepth(false)])
        rotate([-90,0,0])
        
        // front dovetail is always positive
        CreateTinyDoveTail(positive=false, thickness=top_thickness);
    };
    if (create_screwprofile_front) {
        h2 = 15.875;
        h1 = total_thickness;
        screw_hole_depth = calc_screw_hole_depth();
        
        translate([bottom_width / 2, screw_hole_depth, 0])
            rotate([-90, 0, 0]) 
        
            CreateScrew(
                              screw_style, h1, h2,
                                head_diameter=                               custom_screw_head_diameter,
                                head_height=                               custom_screw_head_height,
                                head_straight=                               custom_screw_head_straight,
                                body_diameter=                               custom_screw_diameter,
                                screw_clearance=                               custom_screw_clearance);
    };
}


// Generate the back features that are attached    
if (create_dovetail_back) {
        translate([bottom_width/2,
            total_thickness - TinyDoveTailHeight(true,top_thickness),
            length+TinyDoveTailDepth(true)])
        rotate([-90,0,0])
        CreateTinyDoveTail(positive=true,thickness=top_thickness); 
};  
if (create_bracket_ring_back) {
    ring_clearance=0.2; // ad hoc
    
    bd=bracket_depth+ring_clearance;
    tw=top_width+ring_clearance;
    
    translate([bottom_width/2,0,length+bd])
    rotate([0,180,0])
    difference()
    {
        translate([0,bd*2,bd*0.5])
        color("pink")
        cube([bottom_width,bd*4,bd*2], center=true);
        color("lime")
        CreateBracket(tw, 
          bd, bracket_length);
    }
}
if (create_bracket_back) {
    color("lime")
    translate([bottom_width/2,0,length+bracket_depth]) 
    rotate([0,180,0])
    {   
        // bracket body - screw holes
        difference() 
        {
        CreateBracket(top_width, bracket_depth, bracket_length);

        if (bracket_holes > 1)
        {
            // bracket holes
            length_for_holes = bracket_length -  
                total_thickness - 
                2*bracket_hole_margin;
            hole_distance=
                length_for_holes / (bracket_holes - 1);
        
            h1 = 0; // flush to bracket
            h2 = 15; // screw length, this will be deep enough
            
            for (i=[1:bracket_holes])
            {   
                hole_y=total_thickness + bracket_hole_margin +
                    (i-1)*hole_distance;  
                translate([0,hole_y,0])
                CreateScrew(
                    screw_style, h1, h2,
                    head_diameter=custom_screw_head_diameter,
                    head_height=custom_screw_head_height,
                    head_straight=custom_screw_head_straight,
                    body_diameter=custom_screw_diameter,
                    screw_clearance=custom_screw_clearance);         
            } // end for
        } // end if bracket_holes > 0
    }// difference   
    }
}
if (create_charm_back) {
    color("tomato")
    translate([bottom_width/2,total_thickness/2,length])
    CreateCharm();
}
} // end union    

