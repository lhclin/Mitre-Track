// Screw hole library
module CreateScrewHole(height=15.875,diameter=3.3) {
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

US5FlatHeadHeight = 2.8;
US5FlatHeadDiameter = 5.8;
US5ScrewDiameter = 3.2;
US5Clearance = 0.5;

module US5WoodScrew(screw_length=15.875,head_hole_length=0) {
    // default screw length is 5/8
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

// US5WoodScrew(15.875, 3);