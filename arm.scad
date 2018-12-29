use <rack_and_pinion_1.1.scad>;

$fn = 100;

mount_base_d = 20;
mount_base_inner_d = 18;
mount_base_h = 5.5;
mount_base_outer_h = 12.5;

mount_base_lip_offset = 5;
mount_base_lip_depth  = 1;

arm_base_snap_d = 2;

screw_d = 3.3;

fudge = 1/cos(180/6);
nut_d = 5.8*fudge;
nut_h = 2.5;
head_d = 5.9;
head_h = 3.1;

delt = 0.1;

small_axle_d = 2.6;
axle_d = 3.3;
axle_1_h = 14;
axle_2_h = 9;

// base thickness
thickness = 2;

swing_l = 30;
swing_w = 16;
swing_h = mount_base_h;

// the main long arm connecting the spring mechanism with headphone mount
main_arm_skew = 0.75;
main_arm_offset = 13;
main_arm_length = 85;

main_arm_slot_w = screw_d;
main_arm_slot_len = 50;
main_arm_slot_offset = 20;

// mount_base();
// translate([35,0,14.1]) rotate([180,0,0]) arm_base();
swing_mount();
//swing();
spring_mount(true, 16*(0.6+abs(sin($t*360))));


module toroid(d1, d2) {
    rotate_extrude()
        translate([d1/2,0,0])
            circle(d=d2);
}

module skewed_cube(dim, rot, rnd = 1) {
    M = [ [ 1  , 0  , 0  , 0   ],
        [ 0  , 1  , rot, 0   ],
        [ 0  , 0  , 1  , 0   ],
        [ 0  , 0  , 0  , 1   ] ] ;

    multmatrix(M) {  
        rounded_cube(dim,rnd);
    }
}


module mount_base() {
    difference() {
        cylinder(d=mount_base_d, h = mount_base_outer_h);

        // inner cavity
        translate([0,0,mount_base_h]) cylinder(d=mount_base_inner_d, h = mount_base_outer_h - mount_base_h + delt);

        // screw/nut holes
        translate([0,0,mount_base_h - nut_h + delt]) cylinder(d=nut_d, h=nut_h,$fn=6);
        translate([0,0,-delt]) cylinder(d=screw_d, h= mount_base_h);

        // limitation indentation (stops the whell from turning when moving the arm)
        cube([15.5,25,2],center=true);

        // snap-in circle
        translate([0,0,mount_base_outer_h - mount_base_lip_offset+2*delt]) toroid(d1 = mount_base_inner_d, d2 = mount_base_lip_depth);
    }

    // supports
    h = 0.85;
    translate([ 0,0,h/2]) cube([0.5,20,h],center=true);
    translate([-4,0,h/2]) cube([0.5,18,h],center=true);
    translate([ 4,0,h/2]) cube([0.5,18,h],center=true);
    difference() {
        cylinder(d=mount_base_d, h=h);
        translate([0,0,-delt])cylinder(d=mount_base_d-0.6, h=h*1.1);
        translate([-7.5,0,h/2]) cube([0.5,24,h*1.1],center=true);
        translate([ 7.5,0,h/2]) cube([0.5,24,h*1.1],center=true);
    }
    // central circle
    cylinder(d=screw_d+1, h=h);
}

// snaps into mount base, provides rotation around it's axis thanks to
// it's mount and two mount points for the lever mechanism
module arm_base() {
    translate([0,0,mount_base_outer_h - mount_base_lip_offset]) difference() {
        union() {
            translate([0,0,-mount_base_lip_depth/2]) cylinder(d = mount_base_inner_d-mount_base_lip_depth/3, h = mount_base_lip_offset + mount_base_lip_depth);
            // snap-in circle
            //toroid(d1 = mount_base_inner_d-mount_base_lip_depth/3, d2 = mount_base_lip_depth*0.5);

            // limiting circle
            translate([0,0,mount_base_lip_offset+delt]) cylinder(d=mount_base_d, h = thickness);
        }

        // cavity to allow for springiness
        translate([0,0,-mount_base_lip_depth/2-delt]) cylinder(d = mount_base_inner_d - 1.7 * arm_base_snap_d, h = mount_base_lip_offset);

        // mounting screw hole
        translate([0,0,mount_base_lip_offset-2]) cylinder(d=screw_d,h = 4.5);
    }
}

module axle_mount(height, diam, hole, base, thickness, offset=0) {
    difference() {
        hull() {
            translate([offset,0,height]) rotate([-90,0,0]) cylinder(d=diam,h=thickness);
            cube([base,thickness, delt]);
        }

        translate([offset,-delt,height]) rotate([-90,0,0]) cylinder(d=hole,h=thickness+2*delt);
    }
}

module rounded_cube(dim = [], roundness = 2) {
    // TODO: Use union (4 cylinders, 2 cubes) instead. this is expensive without a good reason
    hull() {
        translate([roundness/2,roundness/2,0]) cylinder(d=roundness, h=dim[2]);
        translate([dim[0]-roundness/2,roundness/2,0]) cylinder(d=roundness, h=dim[2]);
        translate([roundness/2,dim[1]-roundness/2,0]) cylinder(d=roundness, h=dim[2]);
        translate([dim[0]-roundness/2,dim[1]-roundness/2,0]) cylinder(d=roundness, h=dim[2]);

        // rounded top
        /*translate([roundness/2,roundness/2,dim[2]]) sphere(d=roundness);
        translate([dim[0]-roundness/2,roundness/2,dim[2]]) sphere(d=roundness);
        translate([roundness/2,dim[1]-roundness/2,dim[2]]) sphere(d=roundness);
        translate([dim[0]-roundness/2,dim[1]-roundness/2,dim[2]]) sphere(d=roundness);
        */
    }
}

// two axle swing mount providing bi-stable positioning
module swing_mount() {
    outer_d = 2.5*screw_d;
    base_len = 10;
    difference() {
        union() {
            translate([-2,0,0]) rounded_cube([swing_l+4, swing_w, swing_h], 4);

            // mounts for the axles. Two mounts
            translate([0,0,swing_h-thickness]) union() {
                translate([0,0,0]) axle_mount(axle_1_h, outer_d, axle_d, base_len, 2*thickness);
                translate([0, swing_w-2*thickness,0]) axle_mount(axle_1_h, outer_d, axle_d, base_len, 2*thickness);

                translate([swing_l, swing_w,0]) rotate([0,0,180]) union() {
                    axle_mount(axle_2_h, outer_d, axle_d, base_len, 2*thickness);
                    translate([0,swing_w-2*thickness,0]) axle_mount(axle_2_h, outer_d, axle_d, base_len, 2*thickness);
                }
            }
        }

        // hole for the screw head
        translate([swing_l/2, swing_w/2,0]) union() {
            #translate([0,0,mount_base_h - head_h + delt]) cylinder(d=head_d, h=head_h);
            #translate([0,0,-delt]) cylinder(d=screw_d, h= mount_base_h);
        }
    }
}

length = 100;
width = swing_w - 2*thickness - 4*delt;
outer_width = swing_w;
height = 2*screw_d;
outer_height = 2.5*screw_d;
wall = 0.8;
cavity_w = width+8*delt;

// two lever system with a spring that connects to swing mount
module swing() {
    translate([0,thickness+2*delt,axle_1_h+swing_h-thickness]) difference() {
        union() {
            // a base mount cylinder
            rotate([-90,0,0]) cylinder(d=2*axle_d, h = width);
            //translate([0,0,-height/2]) cube([length, width, height]);
            //translate([-screw_d-thickness,-thickness,-height/2]) rounded_cube([length, outer_width, outer_height]);
        }

        // innver cavity
        translate([-2*thickness,-4*delt,-screw_d-delt]) cube([90,cavity_w,outer_height-wall]);
    }
}

module spring_container(th, lent, lslot, wslot, slot_offs, wall) {
    mount_len = 4;
    translate([-th/2,0,mount_len])
    union() {
        difference() {
            union() {
                // container itself
                cube([th,th,lent]);
                // the mount for the headphone itself
                // two trapesoidal connection pillars
                union() {
                    rotate([-90,0,90]) skewed_cube([th,th/2,main_arm_offset+1], -main_arm_skew);
                    translate([0,th,lent-0.8*th]) rotate([90,0,-90]) skewed_cube([th,th/2,main_arm_offset], -main_arm_skew/6);
                    translate([0,0,lent-th/4]) rotate([-90,0,90]) skewed_cube([th,th/2,main_arm_offset], -main_arm_skew);
                    
                    // this is the main arm. it has a screw slot in the middle
                    difference() {
                            translate([-main_arm_offset-1,0,th]) cube([th/2,th,main_arm_length]);
                            /*translate([-main_arm_offset-1-delt,th/2-main_arm_slot_w/2,th + 4*main_arm_slot_offset]) rotate([0,90,0]) rounded_cube([main_arm_slot_len,main_arm_slot_w,th/2+2*delt], main_arm_slot_w);*/
                        // 
                        
                    }
                }
            }
            translate([th/2,th/2,lent/2+slot_offs]) cube([wslot,th+2*delt, lslot], center = true);
            translate([wall,wall,wall]) cube([th-2*wall,th-2*wall, lent]);
                translate([-main_arm_offset-0.5,th/4,10]) rotate([0,-90,0]) text("PSVR Headphone Mount", size = 3, font = "Liberation Sans:style=Bold Italic");
            translate([-main_arm_offset-th/8-delt,th-2+delt,40]) cube([th/2+2*delt,th/4+2*delt,50]);
        }
        
        // rack
        gear_mm_per_tooth = 1;
        rack_teeth = 50;
        rack_thickness = th/2;
        rack_offset = th - 2;
        translate([-main_arm_offset+th/8-4*delt/5,rack_offset,40]) rotate([0,-90,0]) InvoluteGear_rack(gear_mm_per_tooth, rack_teeth, rack_thickness, 2, left_stop_enable = 0, right_stop_enable = 0, backboard_thickness = 0, backboard_height = 0);
        translate([th,0,0]) rotate([0,180,0]) axle_mount(mount_len, th, axle_d, th, th, offset=th/2);
    }
}

// inserts into axle_2 mount and is connected to spring mount
module small_arm(th, lent, wall, offs = 1.5) {
    mount_len = 7.5;
    translate([-th/2,0,mount_len])
    union() {
        translate([th,0,0]) rotate([0,180,0]) union() {
            axle_mount(mount_len, th, axle_d, th, th, offset=th/2);
            // TODO: use just one half of this cylinder
            translate([th/2,0,0]) rotate([-90,0,0]) cylinder(d=th,h=th);

            difference() {
                union() {
                    translate([0,0,-lent+wall/1.5]) rotate([90,0,0]) rounded_cube([th, lent, 2*wall], th);
                    translate([0,th+2*wall,-lent+wall/1.5]) rotate([90,0,0]) rounded_cube([th, lent, 2*wall], th);
                }

                translate([th/2,-2*wall-delt,-lent+2.5*wall]) #rotate([-90,0,0]) cylinder(d=small_axle_d, h = th+4*wall+2*delt);
            }
        }
    }
}

module pinion_mount(th, wall = 2) {
    // pinion diameter
    pinion_diam = 10;
    pinion_teeth = 0.8; // teeth offseting, letting some breething space in here
    
    t = th/2+2*wall;
    w = pinion_diam + 2*wall;
    d = th + 2 * wall + pinion_diam / 2 - pinion_teeth;
    h = th/2+2*wall;
    
    slot = th - 2*wall;
    
    difference() {
        union() {
            cube([t, d, w]);
            translate([0,d,w/2]) rotate([0,90,0]) cylinder(d=w,h=h);
        }
        
        // spacing clearance
        clearance = 0.3;
        
        // hole for the main shaft to go through
        translate([wall-clearance/2,wall-clearance/2,-delt]) cube([th/2 + clearance,th + clearance, pinion_diam + 2*wall + 2*delt]);
        
        // screw mount hole
        translate([-delt,d,w/2]) rotate([0,90,0]) cylinder(d=screw_d+delt,h=h+2*delt);
        // space for the gear
        translate([t/2-slot/2,d,w/2]) rotate([0,90,0]) cylinder(d=w+delt,h=slot);
    }
}

// contains a compressed ballpoint pen spring and connects a lever that ends up in axle_2 mount
module spring_mount(demo, ang=0) {
    spring_diam = 4;
    m_wall = 1.5;
    cont_width = spring_diam + 2*m_wall + 4*delt;
    cont_arm_width = cont_width + 3*delt;
    y_shift = 2*thickness+2*delt;
    axle_offset = swing_h-thickness;
    cont_len = 14;
    arm_len = 13.3;

    if (demo) {
        translate([0,y_shift,axle_1_h+axle_offset]) union() {
            rotate([0,90+ang,0]) {
                spring_container(cont_width,cont_len,4.3, 2.8, 2.7, 1.5);
                translate([-main_arm_offset-cont_width+m_wall,-m_wall,60]) pinion_mount(cont_width, m_wall);
            }
        }

        translate([swing_l,y_shift-delt, axle_2_h + axle_offset]) {
            rotate([0,-72.5-0.85*ang,0]) small_arm(cont_arm_width, arm_len, m_wall);
        }
    } else {
        translate([0,0,cont_width/2]) rotate([0,90,0]) {
            translate([0,20,0]) spring_container(cont_width,cont_len,4, 2.8, 2.5, 1.5);
            translate([0,-15,0]) small_arm(cont_arm_width, arm_len, m_wall);
        }
    }
}
