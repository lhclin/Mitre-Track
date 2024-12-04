include <ScrewLibrary.scad>
include <Charm.scad>

// user customizable
/* [General] */

Slider_Length=30; // 200;

// Less than 20 will disable holes
Drill_Hole_Distance=45; 

Screw_Style="US#5 Flat"; // ["US#5 Flat","US#6 Round","US#8 Flat"]

/* [Edge Style] */
Front_Style="round"; // ["flat","round","dovetail","screwprofile"]
Back_Style="flat"; // ["flat", "dovetail", "bracket", "charm"]

/* [Bracket] */
// Use only if Back Style is set to "bracket"
Bracket_Length=50; // 100;

/* [Fine Tuning] */
// Extra Thickness for the slider(mm). For flush mount, use 0
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
extra_thickness=Extra_Thickness;
extra_clearance=Extra_Clearance;

// Probably going to change below as I add more features
create_round_front = front_style == "round";
create_dovetail_front = front_style == "dovetail";
create_dovetail_back = back_style == "dovetail";
create_bracket_back = back_style == "bracket";
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
bottom_thickness = t30_bottom_thickness - tight_clearance;
bottom_width = t30_bottom_width - tight_clearance;

top_thickness = t30_top_thickness+extra_thickness;
top_width = t30_top_width - loose_clearance;

top_start_x = (bottom_width - top_width) / 2;
top_end_x = top_start_x + top_width;

total_thickness = bottom_thickness + t30_top_thickness + extra_thickness;
    
function calc_screw_hole_depth() = total_thickness - ScrewHeadHeight(screw_style) - 2; // the extra 2mm provides some strength to support the screw
    
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
        linear_extrude(slider_length)
            union(){
                polygon(bottom_points);
                translate([top_start_x,bottom_thickness]) polygon(top_points);
            };

        // then, subtracting the screw holes from the slider body
        // avoid holes too close together
        if (drill_hole_distance > 20) {
            num_of_holes = floor(slider_length / drill_hole_distance);
            // we want an odd number of holes so one hole always at center
            if (num_of_holes % 2 == 0) {num_of_holes = num_of_holes - 1;}

            num_of_holes_one_side = floor(num_of_holes / 2);
            h1 = 15; // screw length, this will be deep enough
            h2 = total_thickness;

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
                        CreateScrew(screw_style,h1,h2);

                    // rest of the holes are offset to the centre hole
                    for(i=[1:num_of_holes_one_side]){
                        pos = i * drill_hole_distance;
                        if (midpoint + pos < slider_length - 5) {
                            translate([0, 0, midpoint - pos]) rotate([-90, 0, 0])
                                CreateScrew(screw_style,h1,h2); 
                            translate([0, 0, midpoint + pos]) rotate([-90, 0, 0])
                                CreateScrew(screw_style,h1,h2);
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

module CreateDoveTail(clearance=0){
    // based on the T30 top width at around 20mm, 15deg dovetail
    c = clearance;
    
    dove_tan=0.268; // tan(15deg)
    dove_half_long=5-c;
    dove_depth=5-2*c;
    dove_half_short=dove_half_long - dove_tan*dove_depth;
    
    // old hard coded profile
    //dove_profile=[[-5+c,0],[5-c,0],[3.66-c,5-c],[-3.66+c,5-c]];
    
    dove_profile=[[-dove_half_long,0],[dove_half_long,0],
        [dove_half_short,dove_depth],[-dove_half_short, dove_depth]];
  
    // test_profile=[[0,0],[10,0],[10,10],[0,10]];
    
    difference(){
        // dovetail body
        color("magenta")
        translate([0,0,-2*c])
            linear_extrude(top_thickness-c)
                polygon(dove_profile);
    
        // cut a slope so model can print without support, 20deg
        slope_tan= 0.364; //tan(20deg)
        slope_recess=dove_depth*slope_tan;
    
        slope_profile=[[0,0],[dove_depth,0], [0,slope_recess]];
        color("green")
        translate([-dove_half_long,0,0])
            rotate([90,0,90])
                linear_extrude(dove_half_long*2)
                    polygon(slope_profile);
    } // end difference
}

// Main
// Create the main slider, round the front if needed, create L bracket if needed

union() {
difference(){
    CreateSliderRaw(length, drill_hole_distance);
    
    // generate the front features that are subtracted
    if (create_round_front) {
        translate([bottom_width /2, 0, bottom_width])
            CreateRoundCutter();
    }
    if (create_dovetail_front) {
        dove_enlarge=-0.1;
        
        color("cyan")
        translate([bottom_width/2,bottom_thickness,5+2*dove_enlarge])
        rotate([-90,0,0])
        CreateDoveTail(dove_enlarge); // slightly bigger dovetail female
    };
    if (create_screwprofile_front) {
        h1 = 15.875;
        h2 = total_thickness;
        screw_hole_depth = calc_screw_hole_depth();
        
        translate([bottom_width / 2, screw_hole_depth, 0])
            rotate([-90, 0, 0]) 
            CreateScrew(screw_style,h1,h2);
    };
}


// Generate the back features that are attached    
if (create_dovetail_back) {
        translate([bottom_width/2,bottom_thickness,length+5])
        rotate([-90,0,0])
        CreateDoveTail(0); 
};  
if (create_bracket_back) {
    // TODO
}
if (create_charm_back) {
    color("tomato")
    translate([bottom_width/2,total_thickness/2,length])
    CreateCharm();
}
} // end union    

