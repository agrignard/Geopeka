/**
* Name: NewModel
* Based on the internal empty template. 
* Author: arno
* Tags: 
*/


model tutorial_gis_city_traffic

global {
	file shape_file_habitats <- file("../includes/Habitats_EYNE.shp");
	file shape_file_ouvrage <- file("../includes/Ouvrages_EYNE.shp");
	file shape_file_linears <- file("../includes/Lineaire_EYNE.shp");
	geometry shape <- envelope(shape_file_linears);
	float step <- 10 #mn;
	float visual_factor<-10.0;
	graph the_graph;
	bool show_legend<-true;
	bool show_habitat<-true;	
	bool show_ouvrage<-true;	
    map<string,rgb> model_color<-["text"::rgb(25,25,25),"habitat"::rgb(255,218,136),"Cache"::#blue,"Fosse aff."::#gray,"ouvrage"::#red, "water"::rgb(64,88,163), "wind"::rgb(201, 89,63), "biodiversity"::rgb(151,160,95)];	
	string myFont;
	
	init {
		create habitats from: shape_file_habitats with: [type::string(read ("Type"))] {
			if type="Cache" {
				color <- #blue ;
			}
			shape<-circle(5#m)*visual_factor;
		}
		create ouvrages from: shape_file_ouvrage with: [chance:float(read ("eval_Fp_Af"))] ;
		create linear from: shape_file_linears ;
		the_graph <- as_edge_graph(linear);
		
		create fish number:1000{
			if flip(0.9){
				moving<-false;
				my_habitat<-one_of(habitats);
				location<-my_habitat.location;
			}else{
				moving<-true;
				location<-any_location_in(one_of(habitats));
			}
		}
	}
}

species habitats {
	string type; 
	rgb color <- #gray  ;
	
	aspect base {
		draw shape color:model_color[type];
	}
}

species ouvrages {
	string type; 
	float chance;
	rgb color <- #red  ;
	
	aspect base {
		draw square(5#m)*visual_factor depth:1#m*visual_factor color: color ;
	}
}

species linear  {
	rgb color <- #black ;
	aspect base {
		draw shape width:4 color:#blue ;
	}
}

species fish skills:[moving]{
	bool moving;
	habitats my_habitat;
	point target;
	
	reflex move{
		if(moving){
		  do wander on:the_graph speed:0.001;	
		}else{
		  do wander	bounds:my_habitat speed:0.001;
		}
		
	}
	aspect base {
	  draw triangle(10#m) color:#blue rotate:heading+90;
	}
	aspect gif {
		if(!moving){
			draw gif_file("../images/fish3.gif") size: {20,20} rotate: heading-45 ;
		}else{
			draw triangle(20#m) color:#blue rotate:heading+90;
		}
	  
	}	
}

experiment road_traffic type: gui {
	parameter "Shapefile for the habitats:" var: shape_file_habitats category: "GIS" ;
	parameter "Shapefile for the linear:" var: shape_file_ouvrage category: "GIS" ;
	float miniumum_cycle_duration<-0.01;	
	output {
		
		display city_display type:3d {
			camera 'default' location: {1141.9059,929.9276,3385.1294} target: {1141.9059,929.8685,0.0};
			species habitats aspect: base visible:show_habitat;
			species ouvrages aspect: base visible:show_ouvrage;
			species linear aspect: base ;
			species fish aspect:gif;
			event "h" {show_habitat<-!show_habitat;}
			event "o" {show_ouvrage<-!show_ouvrage;}
			overlay position: { 50#px,50#px} size: { 1 #px, 1 #px } background: # black border: #black rounded: false
			{
				if(show_legend){
			    point UX_Position<-{100#px,200#px};
                float x<-UX_Position.x;
                float y<-UX_Position.y;
                float gapBetweenWord<-25#px;
                float tabGap<-25#px;
                float uxTextSize<-20.0;
                draw "(H)abitat(" + show_habitat + ")" at: { x,y} color: model_color["text"] font: font(myFont, uxTextSize, #bold);
                if(show_habitat){
            	  y<-y+gapBetweenWord;
            	  draw "CACHE" at: { x+tabGap,y} color: model_color["Cache"] font: font(myFont, uxTextSize, #bold);
            	  y<-y+gapBetweenWord;
            	  draw "Fosse aff." at: { x+tabGap,y} color: model_color["Fosse aff."] font: font(myFont, uxTextSize, #bold);
                }
                y<-y+gapBetweenWord;
                draw "(O)uvrage(" + show_ouvrage + ")" at: { x,y} color: model_color["ouvrage"] font: font(myFont, uxTextSize, #bold);
                }
			}
		}
		
	}
}

