function TinyDoveTailClearance(positive=true) = 
    positive ? 0 : 0.05; // negative dovetail is larger

function TinyDoveTailDepth(positive=true) = 
    5 + 2 * TinyDoveTailClearance(positive);
    
function TinyDoveTailHalfLength(positive=true) =
    5 + TinyDoveTailClearance(positive);
    
function TinyDoveTailHeight(positive=true, thickness =0) =
    thickness + 4*TinyDoveTailClearance(positive);
    
module CreateTinyDoveTailRAW(
    positive=true,
    thickness=0, 
    dove_tan=0.268, // tan (15deg) 
    slope_tan=0.364 // tan (20deg)
    )
{    
    dove_half_long=TinyDoveTailHalfLength(positive);
    dove_depth=TinyDoveTailDepth(positive);
    dove_half_short=dove_half_long - dove_tan*dove_depth;   
   
    dove_height=TinyDoveTailHeight(positive,thickness);
    
    dove_profile=[[-dove_half_long,0],[dove_half_long,0],
        [dove_half_short,dove_depth],[-dove_half_short, dove_depth]];
     
    difference()
    {
        // dovetail body
        // debug : linear_extrude(thickness+c)
        linear_extrude(dove_height)
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
    // Call the RAW version with default tangent will do
    CreateTinyDoveTailRAW(positive, thickness);
}

module CreateTinyDoveTailSpacingCube(
    positive=true,thickness){
    // Create a cube space that emcompasses a tinydove.
    // Done by calling the RAW dovetail with 0 tangent (no slope)
    CreateTinyDoveTailRAW(positive,thickness, 0, 0);
}

CreateTinyDoveTailRAW(true, thickness=5);
color("cyan")
CreateTinyDoveTailRAW(false, thickness=5);
