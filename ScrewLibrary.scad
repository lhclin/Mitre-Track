// Screw hole library

// Declare the supported screws here

// To add new screws, define the 5 values below, and add
// code to the IsScrewSupported() and ScrewHeadHeight() function
    
// spec is based on "traditional" wood screws
US5FlatStr = "US#5 Flat";
US5FlatHeadHeight = 2.8;    // caliper
US5FlatHeadDiameter = 6.35; // head bore 1/4
US5FlatDiameter = 3.18;    // shank hole 1/8
US5FlatClearance = 0.5;

/* ad hoc measured by caliper
US5FlatHeadHeight = 2.8;
US5FlatHeadDiameter = 5.8;
US5FlatDiameter = 3.2;
US5FlatClearance = 0.5;
*/

US6RoundStr = "US#6 Round";
US6RoundHeadHeight = 0;
US6RoundHeadDiameter = 7.14; // head bore 9/32
US6RoundDiameter = 3.57;     // shank hole 9/64
US6RoundClearance = 0.5;

US8FlatStr = "US#8 Flat"; 
US8FlatHeadHeight = 3.4;
US8FlatHeadDiameter = 8.73; // head bore 11/32
US8FlatDiameter = 3.97;     // shank hole 5/32
US8FlatClearance = 0.5;

// Utilities
module CreateScrewHole(height=15,diameter=3.3) {
    // height is the hypothetical screw height. It
    // can be anything as long as it penetrates the
    // object we are modelling. So 15mm is plenty
    $fn=32;
    translate([0, 0, height / 2])
        cylinder(height, diameter / 2, diameter / 2, center = true);
}

module CreateFlatHead(headsize = 5.9, bodysize = 3.3, height = 2.8) {
    $fn=32;
    translate([0, 0, height / 2])
        cylinder(height, headsize / 2, bodysize / 2, center = true);
}

module CreateHeadHole(headsize = 5.9, head_hole_length = 0) {
    $fn=32;
    r = headsize / 2;
    translate([0, 0, - head_hole_length / 2])
        cylinder(head_hole_length, r, r, true);
}

/* old code 
module US5FlatScrew(screw_length=15,head_hole_length=0) {
    // measurement is 5.8 (head) and 3.2 (body), use 5.9 and 3.3 for some room
    hd = US5FlatHeadDiameter + US5Clearance;
    sd = US5ScrewDiameter + US5Clearance;
    
    union(){
        if(head_hole_length > 0) {
            CreateHeadHole(hd, head_hole_length);
        }
        CreateFlatHead(hd, sd, US5FlatHeadHeight);
        CreateScrewHole(screw_length+US5FlatHeadHeight, sd);
    }
}
*/

module CreateScrewRAW(
    screw_length,
    head_hole_length,
    head_diameter,
    flat_head_height,
    screw_diameter)
{
    // the parameters should be already adjusted by clearance    
    union(){
        CreateHeadHole(head_diameter, head_hole_length);
        if (flat_head_height > 0) {
            CreateFlatHead(head_diameter, 
                screw_diameter, flat_head_height);
        }
        CreateScrewHole(screw_length, screw_diameter);
    }
}        

// Public interface
function IsScrewSupported(style) =
    style == US5FlatStr ||
    style == US6RoundStr ||
    style == US8FlatStr;
    
function ScrewHeadHeight(style) =
    style == US5FlatStr ? US5FlatHeadHeight :
      style == US6RoundStr ? US6RoundHeadHeight :
      style == US8FlatStr ? US8FlatHeadHeight : 0;

/*
    assert(IsScrewSupported(style));
    
    if (screw_style == US6RoundStr)
    {
        ScrewHeadHeight=US6RoundHeadHeight;
    } else if (screw_style == US8FlatStr)
    {
        ScrewHeadHeight=US8FlatHeadHeight;
    } else { // Default US#5 Flat
        ScrewHeadHeight=US5FlatHeadHeight;
    }
    // I don't think I need 
}
*/

module CreateScrew(
    style="", 
    screw_length=15, 
    head_hole_length=0) {
        
    assert(IsScrewSupported(style));
    
    if (style==US5FlatStr) {
        CreateScrewRAW(
            screw_length,
            head_hole_length,
            US5FlatHeadDiameter,
            US5FlatHeadHeight,
            US5FlatDiameter
        );
    }
    else if (style==US6RoundStr) {
        CreateScrewRAW(
            screw_length,
            head_hole_length,
            US6RoundHeadDiameter,
            US6RoundHeadHeight,
            US6RoundDiameter
        );
    } else if (style == US8FlatStr) {
        CreateScrewRAW(
            screw_length,
            head_hole_length,
            US8FlatHeadDiameter,
            US8FlatHeadHeight,
            US8FlatDiameter
        );
    } else assert(false);
} // end CreateScrew    

//testing
// CreateScrew(US5FlatStr, 15, 20);
// CreateScrew(US6RoundStr, 15, 20);
// CreateScrew(US8FlatStr, 15, 20);
// CreateScrew("Unsupported", 15, 20);
         
       