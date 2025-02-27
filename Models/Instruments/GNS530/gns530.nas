# Copyright 2020 Julio Santa Cruz (Barta)
# GNS530 - FG1000 implementation

var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
var aircraft_dir = getprop("/sim/aircraft-dir");

io.load_nasal(nasal_dir ~ 'FG1000.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Models/Instruments/GNS530/Constants.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Models/Instruments/GNS530/MFDPageController.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Models/Instruments/GNS530/Interfaces/GNS530InterfaceController.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Models/Instruments/GNS530/GNS530D.nas', "fg1000");

# Load the custom controller
var interfaceController = fg1000.GNS530InterfaceController.getOrCreateInstance();

interfaceController.start();

var EIS ={engineMenu:"",systemMenu:""}; # Empty EIS to fool FG1000
var svg_path = '/Aircraft/PA28/Models/Instruments/GNS530/SVG/';
var fg1000system = fg1000.FG1000.getOrCreateInstance(EIS, nil, svg_path);

# Overide Surround controller
io.load_nasal(aircraft_dir ~ '/Models/Instruments/GNS530/SelectableElement.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Models/Instruments/GNS530/MDFPages/Surround/SurroundController.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Models/Instruments/GNS530/MDFPages/Surround/Surround.nas', "fg1000");

var targetcanvas = canvas.new({
  "name" : "MFD Canvas",
  "size" : [1024, 768],
  "view" : [1024, 768],
  "mipmapping": 0,
});

targetcanvas.set("visible", 0);

var mfd = fg1000.GNS530Display.new(fg1000system, fg1000system.EIS_Class, fg1000system.EIS_SVG, fg1000system.SVG_Path, targetcanvas, 1);
fg1000system.displays[1] = mfd;
fg1000system.display(index:1);

#setprop("/instrumentation/nav-selected",2);
	    
	    
# Turn on/off the displays 
# TODO: Check bus voltage
var fg1000_power = func() {
    var batt = props.globals.getNode("/controls/electrical/switches/avionics-master").getBoolValue();
        if (batt) {
	        # Show the device
	        fg1000system.show(index:1);
	        
	        # Hack: Some nasal scripts and add-ons looks for this switch to
	        # detect if the radio is serviceable...
	        setprop("/instrumentation/comm/power-btn",1);
	        setprop("/instrumentation/comm[1]/power-btn",1);
        } else {
	        fg1000system.hide(index:1);	        
	        setprop("/instrumentation/comm/power-btn",0);
	        setprop("/instrumentation/comm[1]/power-btn",0);
    }
};
setlistener("/controls/electrical/switches/avionics-master", fg1000_power);

