$fn = 100;

mount();

// mount part that clamps onto the headband. 2 part design, inspired by bionik mantis mount
module mount() {
    mount_top();
    //mount_bottom();
    translate([-5,0,15]) rotate([0,180,0]) mount_bottom();
}

// psvr headband dimensions 18.3x2. Here we're lowering the height because we want the springiness to hold it in place
hb_h = 20;
hb_w = 1.7;
// high part of the slotting to allow for the cable mount and cable
hb_w_h = 8; 
hb_h_h = 11;

// mount dimensions
mount_h = 35;
mount_w = 15;
mount_d = 15;
mount_slot_d = 6.0;
mount_slot_x = 17.5;

// thickness of the lower part of mount
mount_low_d =  10;

delt = 0.1;
delt2 = 2*delt;
tolerance = 0.15;

screw_d = 3.3;
fudge = 1/cos(180/6);
nut_d = 5.7*fudge;
nut_h = mount_d - 10;
head_d = 5.9;
head_h = 3.1;
screw_offset = 5;

// mount slot for both top and bottom parts
module mount_slot() {
    union() {
        translate([mount_slot_x - hb_h/2,0,mount_slot_d]) cube([hb_h, mount_w+delt2, hb_w]);
        translate([mount_slot_x - 6,0,mount_slot_d]) cube([hb_h_h, mount_w+delt2, hb_w_h]);
    }
}

module screw_hole(height) {
    union() {
        translate([0,0,-delt]) cylinder(d = screw_d, h = height);
        translate([0,0,height - nut_h + delt]) cylinder(d = nut_d, h = nut_h, $fn = 6);
        translate([0,0,-delt]) cylinder(d = head_d, h = head_h);
    }
}

module screw_support(height) {
    translate([0,0,head_h]) cylinder(d=screw_d, h = 0.15);
    translate([0,0,height - nut_h - 0.15 + 2 * delt]) cylinder(d=screw_d, h = 0.15);
}

module mount_screw_holes() {
    translate([screw_offset,mount_w/2,0]) screw_hole(mount_d);
    translate([mount_h - screw_offset,mount_w/2,0]) screw_hole(mount_d);
    // mount hole for the rotational mount - nyloc nut is placed there
    translate([mount_h /2,mount_w/2,+mount_slot_d-mount_d + delt]) screw_hole(mount_d);
}

module screw_supports() {
    translate([screw_offset,mount_w/2,-delt]) screw_support(mount_d);
    translate([mount_h - screw_offset,mount_w/2,-delt]) screw_support(mount_d);
}

module oval_body() {
    //cube([mount_h,mount_w,mount_d]);
    hull() {
        translate([mount_w/2,mount_w/2,0]) cylinder(d=mount_w,h = mount_d);
        translate([mount_h - mount_w/2,mount_w/2,0]) cylinder(d=mount_w,h = mount_d);
    }
}

// unsplit mount, which is then cut in halves to be screwed together
module mount_body() {
    // todo: replace with a rounded corner shape later
    difference() {
        oval_body();
        mount_slot();
        mount_screw_holes();
    }
    // add screw support
    screw_supports();
}

// a simple box with clamp and a slot for the bottom part
module mount_top() {
    difference() {
        mount_body();
        translate([0,0,mount_slot_d + hb_w]) cube([mount_h,mount_w,mount_d - mount_slot_d]);
    }
}

module mount_bottom() {
    difference() {
        mount_body();
        cube([mount_h,mount_w,mount_slot_d + hb_w]);
    }
}