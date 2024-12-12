use <gridfinity-rebuilt-baseplate.scad>

module gridfinity1x1basechunk(solid=true)
{
    $fa = 8;
    $fs = 0.25;
    
    length=42;
    distancex=0;
    distancey=0;
    style_plate=0;
    enable_magnet=false;
    style_hole=0;
    
    if (solid) {
        hull()
        gridfinityBaseplate(1,1,length,
          distancex,distancey,
          style_plate,style_hole);
    }
    else {
        gridfinityBaseplate(1,1,length,
          distancex,distancey,
          style_plate,style_hole);
    }
}

$fa=8;
$fs=0.25;

testoff=30;
translate([testoff,testoff,0])
gridfinity1x1basechunk(false);

module gridfinity_fill_corner(corner=0){
    intersection()
    {
        dx=(corner==0)||(corner==3)?4:-4;
        dy=(corner==0)||(corner==1)?4:-4;
    
        translate([dx,dy,0])
            cube([8,8,20],center=true);
    
    
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
    cylinder(20,r=4,center=true);
} // differnce
}// intersection
}

translate([testoff+16.75,testoff+16.75,0])
    gridfinity_fill_corner(0);
translate([testoff-16.75,testoff+16.75,0])
    gridfinity_fill_corner(1);
translate([testoff-16.75,testoff-16.75,0])
    gridfinity_fill_corner(2);
translate([testoff+16.75,testoff-16.75,0])
    gridfinity_fill_corner(3);

/* implementation 1, too chunky
translate([42,42,0])
intersection(){
difference()
{
intersection()
{
  scale([1.5,1.5,1])
    gridfinity1x1basechunk();
  cube([41.5,41.5,41.5],center=true);
}
translate([16.75,16.75,0])
    cylinder(20,r=4,center=true);
}
translate([20.75,20.75,20.75])
cube([8,8,41.75],center=true);
}
*/
/*
$fa=8;
$fs=0.25;
tx=0.7071*4;
off=16.75;
translate([off,0,0])
color("lime")
cylinder(10,r=4,center=true);

color("orange")
cube([20.75,20.75,4],center=false);
*/