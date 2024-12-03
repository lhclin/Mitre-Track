module CreateCharm() {
    // Create a charm. 
    // To create your own, lid an object on the XY plane,
    // centre at [0,0]
    
    /* // Just a cube
    charm_polygon = [
        [-3,-3],[3,-3],[3,3],[-3,3]
    ];
    linear_extrude(3)
        polygon(charm_polygon);
    */
    
    //space invader
    translate([-0.5,-4,0])
    union(){
        space_invader_left();
        translate([1,0,0])
            mirror([1,0,0]) 
                space_invader_left();
    }
}

module space_invader_left()
{
    polygon1 = [
        [0,0],[-2,0],[-2,1],[0,1]];
    polygon2 = [
        [-2,1],[-3,1],[-3,3],[-4,3],[-4,1],
        [-5,1],[-5,4],[-4,4],[-4,5],[-3,5],[-3,6],
        [-2,6],[-2,7],[-1,7],[-1,6],[1,6],[1,2],
        [-2,2]];
    polygon3 = [[-2,7],[-3,7],[-3,8],[-2,8]];
    polygon4 = [[-1,4],[-2,4],[-2,5],[-1,5]];
    difference(){
      union(){
        linear_extrude(1)
            polygon(polygon1);
        linear_extrude(1)
            polygon(polygon2);
        linear_extrude(1)
            polygon(polygon3);
      };
      linear_extrude(1)
            polygon(polygon4);
  }
}

// Testing
// CreateCharm();