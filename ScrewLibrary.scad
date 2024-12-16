// Screw hole library

// Declare the supported screws here

// To add new screws, define the 5 values below, and add
// code to the IsScrewSupported() and ScrewHeadHeight() function
    
// spec is based on "traditional" wood screws
US5FlatStr = "US#5 Flat";
US5FlatHeadHeight = 2.8;    // caliper
US5FlatHeadDiameter = 6.35; // head bore 1/4
US5FlatHeadStraight = false;
US5FlatHeadHex = false;
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
US6FlatHeadStraight = false;
US6FlatHeadHex = false;
US6FlatDiameter = 3.51;     // major dia. 0.138"
US6FlatClearance = 0.5;

US8FlatStr = "US#8 Flat"; 
US8FlatHeadHeight = 3.6;
US8FlatHeadDiameter = 8.73; // head bore 11/32
US8FlatHeadStraight = false;
US8FlatHeadHex = false;
US8FlatDiameter = 4.17;     // major dia. 0.164"
US8FlatClearance = 0.5;

US8RoundStr = "US#8 Round"; 
US8RoundHeadHeight = 0.5; // keep a slight recess marking 
US8RoundHeadDiameter = 8.73; // head bore 11/32
US8RoundHeadStraight = false;
US8RoundHeadHex = false;
US8RoundDiameter = 4.17;     // major dia. 0.164"
US8RoundClearance = 0.5;

M3NutStr = "M3 Nut"; 
M3NutHeadHeight = 5; // double the m3 spec for more room 
M3NutHeadDiameter = 6.01; 
M3NutHeadStraight = true;
M3NutHeadHex = true;
M3NutDiameter = 3;   
M3NutClearance = 0.6;

PencilMarkerStr = "Pencil Marker";
PencilMarkerHeadHeight = 3;
PencilMarkerHeadDiameter = 2;
PencilMarkerHeadStraight = false;
PencilMarkerHeadHex = false;
PencilMarkerDiameter = 8;
PencilMarkerClearance = 0;

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

module CreateScrewHead(headsize = 5.9, bodysize = 3.3, height = 2.8,is_hex = false) {
    $fn=is_hex? 6 : 32;
    translate([0, 0, height / 2])
        cylinder(height, headsize / 2, bodysize / 2, center = true);
}

module CreateHeadHole(headsize = 5.9, head_hole_length = 0, is_hex = false) {
    $fn=is_hex? 6 :32;
    r = headsize / 2;
    translate([0, 0, - head_hole_length / 2])
        cylinder(head_hole_length, r, r, true);
}

module CreateScrewRAW(
    head_diameter = 0,
    head_hole_length = 0,
    head_height = 0,
    head_straight = 0,
    head_hex = false,
    body_diameter = 0,
    body_length = 0)
{
    // the parameters should be already adjusted by clearance    
    union(){        
        CreateHeadHole(head_diameter, head_hole_length, head_hex);
  
        if (head_straight)
        {
            // no slope from head to screw hole
            CreateScrewHead(head_diameter, 
                head_diameter, head_height, head_hex);
        }
        else
        {
            // slope from head to screw hole
            CreateScrewHead(head_diameter, 
                body_diameter, head_height, head_hex);
        }
        
        translate([0,0,head_height])
        CreateScrewHole(body_length, body_diameter);
    }
}        

// Public interface
function IsScrewSupported(style) =
    style == US5FlatStr ||
    style == US6FlatStr ||
    style == US8FlatStr ||
    style == US8RoundStr ||
    style == M3NutStr ||
    style == PencilMarkerStr ||
    style == CustomScrewStr;
    
function ScrewHeadHeight(style) =
    style == US5FlatStr ? US5FlatHeadHeight :
      style == US6FlatStr ? US6FlatHeadHeight :
      style == US8FlatStr ? US8FlatHeadHeight : 
      style == US8RoundStr ? US8RoundHeadHeight :
      style == M3NutStr ? M3NutHeadHeight :
      style == PencilMarkerStr ? PencilMarkerHeadHeight : 0;

// Create screw using customized parameter specified by caller
module CreateCustomScrew(
    head_diameter = 0,
    head_hole_length = 0,
    head_height = 0,
    head_straight = true,
    head_hex = false,
    body_diameter = 0,
    body_length = 0,
    screw_clearance = 0)
{
    CreateScrewRAW(
        head_diameter + screw_clearance,
        head_hole_length,
        head_height,
        head_straight,
        head_hex,
        body_diameter + screw_clearance,
        body_length);
}

// Create screw using built-in parameter
module CreateScrew(
    style="",
    head_hole_length=0,
    body_length=15,
    // Below are required for custom screws only
    head_diameter=0,
    head_height=0,
    head_straight=true,
    head_hex = false,
    body_diameter=0,
    screw_clearance=0)
{        
    assert(IsScrewSupported(style));
    
    if (style==US5FlatStr) {
        CreateCustomScrew(
            US5FlatHeadDiameter,
            head_hole_length,
            US5FlatHeadHeight,
            US5FlatHeadStraight,
            US5FlatHeadHex,
            US5FlatDiameter,
            body_length,
            US5FlatClearance
        );
    }
    else if (style==US6FlatStr) {
        CreateCustomScrew(
            US6FlatHeadDiameter,
            head_hole_length,
            US6FlatHeadHeight,
            US6FlatHeadStraight,
            US6FlatHeadHex,
            US6FlatDiameter,
            body_length,
            US6FlatClearance
        );
    } else if (style == US8FlatStr) {
        CreateCustomScrew(
            US8FlatHeadDiameter,
            head_hole_length,
            US8FlatHeadHeight,
            US8FlatHeadStraight,
            US8FlatHeadHex,
            US8FlatDiameter,
            body_length,
            US8FlatClearance
        );
    } else if (style == US8RoundStr) {
        CreateCustomScrew(
            US8RoundHeadDiameter,
            head_hole_length,
            US8RoundHeadHeight,
            US8RoundHeadStraight,
            US8RoundHeadHex,
            US8RoundDiameter,
            body_length,
            US8RoundClearance
        );
    } else if (style == M3NutStr) {
        CreateCustomScrew(
            M3NutHeadDiameter,
            head_hole_length,
            M3NutHeadHeight,
            M3NutHeadStraight,
            M3NutHeadHex,
            M3NutDiameter,
            body_length,
            M3NutClearance
        );
    } else if (style == PencilMarkerStr) {
        CreateCustomScrew(
            PencilMarkerHeadDiameter,
            head_hole_length,
            PencilMarkerHeadHeight,
            PencilMarkerHeadStraight,
            PencilMarkerHeadHex,
            PencilMarkerDiameter,
            body_length,
            PencilMarkerClearance
        );
    } else if (style == CustomScrewStr) {
        CreateCustomScrew(
            head_diameter,
            head_hole_length,
            head_height,
            head_straight,
            head_hex,
            body_diameter,
            body_length,
            screw_clearance);
    }
    else assert(false);
} // end CreateScrew    



         
       