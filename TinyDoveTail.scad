module CreateTinyDoveTailRAW(
    thickness=0, clearance=0,
    dove_tan=0.268, // tan (15deg) 
    slope_tan=0.364 // tan (20deg)
    )
{
    // based on the T30 top width at around 20mm, 15deg dovetail
    c = clearance;
    
    dove_half_long=5+c;
    dove_depth=5+2*c;
    dove_half_short=dove_half_long - dove_tan*dove_depth;    
    
    dove_profile=[[-dove_half_long,0],[dove_half_long,0],
        [dove_half_short,dove_depth],[-dove_half_short, dove_depth]];
     
    difference(){
        // dovetail body
        translate([0,0,-2*c])
            linear_extrude(thickness-c)
                polygon(dove_profile);
    
        // cut a slope so model can print without support, 20deg
        slope_recess=dove_depth*slope_tan;
    
        slope_profile=[[0,0],[dove_depth,0], [0,slope_recess]];

        translate([-dove_half_long,0,0])
            rotate([90,0,90])
                linear_extrude(dove_half_long*2)
                    polygon(slope_profile);
    } // end difference
}

// Public
module CreateTinyDoveTail(positive=true, thickness=0)
{
    // negative dovetail is larger
    clearance=positive ? 0 : 0.05;

    // Call the RAW version with default tangent will do
    CreateTinyDoveTailRAW(thickness, clearance);
}

module CreateTinyDoveTailSpacingCube(
    positive=true,thickness){
    // Create a cube space that emcompasses a tinydove.
    // Done by calling the RAW dovetail with 0 tangent (no slope)

    clearance=positive ? 0 : 0.05;
    CreateTinyDoveTailRAW(thickness, clearance, 0, 0);
}

// CreateTinyDoveTail(false, 10);
