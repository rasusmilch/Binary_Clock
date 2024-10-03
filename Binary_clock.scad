led_spacing = 33.33;
wall_thickness = 0.5;
clock_height = 30;
back_panel_height = 22;
led_dim = 7;
usb_radius = 5.5;
pushbutton_radius = 8;

electronics_cavity = 40;
clock_width = led_spacing * 4 + 8 * wall_thickness;
clock_length = led_spacing * 4 + 8 * wall_thickness;

front_hole_radius = 2.5;
screw_hole_radius = 1.375;
screw_hole_clearance = 1.75;

//cube([led_spacing, led_spacing, height]);

x = 0;
y = 0;

module led_cutout(spacing, dim, height) {
  translate([spacing / 2 - dim / 2, spacing / 2 - dim / 2, -height + 0.1]) {
        cube([dim, dim, height]);  
  };
};

module cutout(spacing, thickness, height, direction) {
    poly_x = (cos(75) * spacing);
    
    led_cutout(spacing, led_dim, 3); 
    linear_extrude(height + 1) {
        if (direction < 0) {
            polygon([[thickness, wall_thickness], [spacing - poly_x - thickness, thickness], [spacing - thickness, spacing - thickness], [poly_x + thickness, spacing - thickness]]);
        }
        else {
            polygon([[poly_x + thickness, thickness], [spacing - thickness, thickness], [spacing - poly_x - thickness, spacing - thickness], [thickness, spacing - thickness]]);
        }
    };
   
}; 



module pattern() {

    for (y_i = [0 : 3]) {
        
        translate([x, y_i * (led_spacing + wall_thickness), 0]) {
            cutout(led_spacing, wall_thickness, clock_height, (-1)^y_i);
        };
        
    }
};


module cavities() {
    translate([led_spacing * 2 + 4 * wall_thickness, 0, 0]) {
        translate([led_spacing + wall_thickness, 0, 0]) {
            pattern();
            mirror([1, 0, 0]) {
                pattern();
            };
        };

        mirror([1, 0, 0]) {
            translate([led_spacing + wall_thickness, 0, 0]) {
                pattern();
                mirror([1, 0, 0]) {
                    pattern();
                };
            };
        };
    };
};


module diamond_cutout(spacing, thickness) {
    poly_x = (cos(75) * spacing);
    
    linear_extrude(clock_height) {
        polygon([[clock_width / 2, 4 * thickness], [clock_width / 2 + poly_x - 2 * thickness, clock_length / 4], [clock_width / 2, clock_length / 2 - 4 * thickness], [clock_width / 2 - poly_x + 2 * thickness, clock_length / 4]]);
    };   
};

module diamond_pattern(spacing, thickness) {
    
    translate([0, 0, -2 * thickness]) diamond_cutout(spacing, thickness);
    translate([0, clock_length / 2, -2 * thickness]) diamond_cutout(spacing, thickness);
};

module screws(radius, length, sides = 6) {
    $fn = sides;
    translate([4, clock_length / 4 + wall_thickness / 2, -0.1]) {
        cylinder(length, radius, radius, false);
    };
  
    translate([4, 3 * clock_length / 4 - wall_thickness, -0.1]) {
        cylinder(length, radius, radius, false);
    };  
    
    translate([clock_width - 4, clock_length / 4 + wall_thickness / 2, -0.1]) {
        cylinder(length, radius, radius, false);
    };
  
    translate([clock_width - 4, 3 * clock_length / 4 - wall_thickness, -0.1]) {
        cylinder(length, radius, radius, false);
    };  
    
    translate([clock_width / 4, 4, -0.1]) {
        cylinder(length, radius, radius, false);
    };  
    
    translate([clock_width / 4, clock_length - 4, -0.1]) {
        cylinder(length, radius, radius, false);
    }; 
   
    translate([3 * clock_width / 4, 4, -0.1]) {
        cylinder(length, radius, radius, false);
    };  
    
    translate([3 * clock_width / 4, clock_length - 4, -0.1]) {
        cylinder(length, radius, radius, false);
    };   
};

module shell() {

    difference() {
        cube([clock_width, clock_length, clock_height]);

        union() {
            translate([0, 2 * wall_thickness, wall_thickness * 2]) {
                cavities();
            };
            /*translate([4 * wall_thickness, clock_length - 2 * wall_thickness, -wall_thickness]) {
                cube([clock_width - 8 * wall_thickness, electronics_cavity - 2 * wall_thickness, clock_height + 1]);
            };*/
            
            translate([clock_width / 2, clock_length / 4 * 3, -wall_thickness]) {
                cylinder($fn = 20, clock_height + 1, front_hole_radius, front_hole_radius, false);
            };

            translate([clock_width / 2, clock_length / 4, -wall_thickness]) {
                cylinder($fn = 20, clock_height + 1, front_hole_radius, front_hole_radius, false);
            };
            
            screws(screw_hole_radius, 2 * clock_height);
            
            diamond_pattern(led_spacing, wall_thickness);
        };
    };
    
};

module panel_holes() {
    
    // USB
    translate([clock_width / 2, 20, -back_panel_height - 0.1]) cylinder($fn = 30, back_panel_height, 5.5, 5.5, false);
    
    // BUTTONS
    for (i = [-30:30:30]) {
        translate([clock_width / 2 + i, clock_length - 25, -back_panel_height - 0.1]) cylinder($fn = 30, back_panel_height, pushbutton_radius, pushbutton_radius, false);
    };
};

module back_panel() {
    difference() {
        union() {
            translate([0, 0, -back_panel_height]) {
                difference() {
                    cube([clock_width, clock_length, back_panel_height]);
                    translate([2 * wall_thickness, 2 * wall_thickness, 4 * wall_thickness]) {
                        cube([clock_width - 4 * wall_thickness, clock_length - 4 * wall_thickness, clock_height]);
                    };
                };
            };
            translate([0, 0, -back_panel_height + 0.1]) screws(4, back_panel_height, 40);
        };
        
        union() {
            translate([0, 0, -clock_height]) {
                screws(screw_hole_clearance, 2 * clock_height, 20);
            };
            panel_holes();
        };
    };    
    
    
};


//shell();

back_panel();
//panel_holes();


