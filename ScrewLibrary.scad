// Screw hole library

// Declare the supported screws here

// To add new screws, define the 5 values below, and add
// code to the IsScrewSupported() and ScrewHeadHeight() function
    
// spec is based on "traditional" wood screws
US5FlatStr = "US#5 Flat";
US5FlatHeadHeight = 2.8;    // caliper
US5FlatHeadDiameter = 6.35; // head bore 1/4
US5FlatDiameter = 3.18;    // major diameter 1/8
US5FlatClearance = 0.5;

/* ad hoc measured by caliper
US5FlatHeadHeight = 2.8;
US5FlatHeadDiameter = 5.8;
US5FlatDiameter = 3.2;
US5FlatClearance = 0.5;
*/

US6FlatStr = "US#6 Flat";
US6FlatHeadHeight = 2.8; // A caliper
US6FlatHeadDiameter = 8.0; // head bore 9/32
US6FlatDiameter = 3.51;     // major dia. 0.138"
US6FlatClearance = 0.5;

US8FlatStr = "US#8 Flat"; 
US8FlatHeadHeight = 3.6;
US8FlatHeadDiameter = 8.73; // head bore 11/32
US8FlatDiameter = 4.17;     // major dia. 0.164"
US8FlatClearance = 0.5;

US8RoundStr = "US#8 Round"; 
US8RoundHeadHeight = 1; // keep a slight slope for easy printing
US8RoundHeadDiameter = 8.73; // head bore 11/32
US8RoundDiameter = 4.17;     // major dia. 0.164"
US8RoundClearance = 0.5;

CustomScrewStr = "custom";

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
  
        CreateFlatHead(head_diameter, 
                screw_diameter, flat_head_height);
        
        CreateScrewHole(screw_length, screw_diameter);
    }
}        

// Public interface
function IsScrewSupported(style) =
    style == US5FlatStr ||
    style == US6FlatStr ||
    style == US8FlatStr ||
    style == US8RoundStr ||
    style == CustomScrewStr;
    
function ScrewHeadHeight(style) =
    style == US5FlatStr ? US5FlatHeadHeight :
      style == US6FlatStr ? US6FlatHeadHeight :
      style == US8FlatStr ? US8FlatHeadHeight : 
      style == US8RoundStr ? USRoundHeadHeight : 0;

module CreateScrew(
    style="", 
    screw_length=15, 
    head_hole_length=0,
    custom_screw_head_height=0, // this and below only needed for custom screw size
    custom_screw_head_diameter=0,
    custom_screw_diameter=0,
    custom_screw_clearance=0
    ) {        
    assert(IsScrewSupported(style));
    
    if (style==US5FlatStr) {
        CreateScrewRAW(
            screw_length,
            head_hole_length,
            US5FlatHeadDiameter + US5FlatClearance,
            US5FlatHeadHeight,
            US5FlatDiameter + US5FlatClearance
        );
    }
    else if (style==US6FlatStr) {
        CreateScrewRAW(
            screw_length,
            head_hole_length,
            US6FlatHeadDiameter + US6FlatClearance,
            US6FlatHeadHeight,
            US6FlatDiameter + US6FlatClearance
        );
    } else if (style == US8FlatStr) {
        CreateScrewRAW(
            screw_length,
            head_hole_length,
            US8FlatHeadDiameter + US8FlatClearance,
            US8FlatHeadHeight,
            US8FlatDiameter + US8FlatClearance
        );
    } else if (style == US8RoundStr) {
        CreateScrewRAW(
            screw_length,
            head_hole_length,
            US8RoundHeadDiameter + US8RoundClearance,
            US8RoundHeadHeight,
            US8RoundDiameter + US8RoundClearance
        );
    } else if (style == CustomScrewStr) {
        CreateScrewRAW(
            screw_length,
            head_hole_length,
            custom_screw_diameter + custom_screw_clearance,
            custom_screw_head_height,
            custom_screw_diameter + custom_screw_clearance
        );
    } else assert(false);
} // end CreateScrew    

//testing
// CreateScrew(US5FlatStr, 15, 20);
// CreateScrew(US6FlatStr, 15, 20);
// CreateScrew(US8FlatStr, 15, 20);
// CreateScrew(US8RoundStr, 15, 20);
// CreateScrew("Unsupported", 15, 20);
         
       