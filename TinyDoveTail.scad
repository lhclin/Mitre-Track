module CreateTinyDoveTail(thickness=0, clearance=0){
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
            linear_extrude(thickness-c)
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