//
//  Pirep.m
//  Aerovie-Lite
//
//  Created by Bryan Heitman on 1/22/14.
//  Copyright (c) 2014 DevStake, LLC. All rights reserved.
//

#import "Pirep.h"

@interface Pirep ()

@end

@implementation Pirep

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    

    myCommon = [[Common alloc] init];
    singletonObject = [mySingleton sharedInstance];
    [self didRotateFromInterfaceOrientation:self];

    [singletonObject add_gray:self.parentViewController.view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(map_tap:)];
    [_map_view addGestureRecognizer:tap];
    
    point_annotation =  nil;
    manual_location.longitude = 0;
    manual_location.latitude = 0;
    
    _slider_time.minimumValue = 0;
    _slider_time.maximumValue = 30;
    _slider_time.value = 0;
    [self slider_time_changed:self];
    
    ride_type = @"NA";
    
    visibility = -1;

    
    ride = nil;
    wx = nil;
    icing = nil;
    twitter = false;
    facebook = false;
    
    _slider_altitude.minimumValue = 0;
    _slider_altitude.maximumValue = 450;
    _slider_altitude.transform = CGAffineTransformRotate(_slider_altitude.transform, degreesToRadian(-90));
    
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(main_tap:)];
    [self.view addGestureRecognizer:tap2];
    
    
    image_encode = @"";
    
    
    UITapGestureRecognizer *t2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photo_button:)];
    [_image addGestureRecognizer:t2];

    UITapGestureRecognizer *t3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(location_changed:)];
    [t3 setCancelsTouchesInView:false];
    [_segment_location addGestureRecognizer:t3];

    
    [_main_scroll setContentSize:CGSizeMake(310, 1800)];
    
    
    
    slider1 = [[RangeSlider alloc] init];
    slider2 = [[RangeSlider alloc] init];
    slider3 = [[RangeSlider alloc] init];
    
    float max_alt = 180;
    if([[mySession objectForKey:@"high_altitude"] isEqualToString:@"yes"])
        max_alt = 410;
    
    [_view_left addSubview:[slider1 setup_range:CGRectMake(3, 229, 240, 80) min:0 max:max_alt value1:0 value2:0 desc:@"TURB."]];
    [_view_middle addSubview:[slider2 setup_range:CGRectMake(3, 229, 240, 80) min:0 max:max_alt value1:0 value2:0 desc:@"CLOUD"]];
    [_view_right addSubview:[slider3 setup_range:CGRectMake(3, 229, 240, 80) min:0 max:max_alt value1:0 value2:0 desc:@"ICING"]];
    
    _text_callsign.text = [mySession objectForKey:@"callsign"];
    _text_callsign_type.text = [mySession objectForKey:@"callsign_type"];
    
    [self slider_visibility_changed:self];
    
    
    _location_altitude.text = [self set_flight_level:singletonObject->gps.altitude* 3.2808399];
}

-(NSString *) set_flight_level:(float) value {
    NSString *extra_zero = @"";
    
    value /= 100;
    
    if(value < 10)
        extra_zero = @"00";
    else if(value < 100)
        extra_zero = @"0";
    
    return [NSString stringWithFormat:@"FL%@%.0f",extra_zero,value];
}

-(IBAction)main_tap:(UIGestureRecognizer *) gesture {
    [self.view endEditing:YES];    
}

- (IBAction)slider_altitude_changed:(id)sender {
    long altitude = lroundf(_slider_altitude.value);
    
    manual_altitude = altitude;
    
    if(_slider_altitude.value == 0)
        _label_altitude.text = [NSString stringWithFormat:@"GROUND"];
    else
        _label_altitude.text = [self set_flight_level:altitude*100];
    
    _location_altitude.text = _label_altitude.text;
}


- (IBAction)slider_time_changed:(id)sender {

    long seconds = lroundf(_slider_time.value);

    if(_slider_time.value == 0)
        _label_time.text = [NSString stringWithFormat:@"NOW"];
    else
        _label_time.text = [NSString stringWithFormat:@"%ld MINS",seconds];
}
- (IBAction)location_changed:(id)sender {
    if(_segment_location.selectedSegmentIndex == 1) {
        if(manual_location.latitude == 0) {
            [self tap_location:singletonObject->gps.coordinate];
            _slider_altitude.value = singletonObject->gps.altitude*METERS_TO_FEET/100;
            [self slider_altitude_changed:nil];
        }
        _view_map.hidden = false;
        _view_gray_manual.hidden = false;
    }else{
        _location_altitude.text = [self set_flight_level:singletonObject->gps.altitude * 3.2808399];
        
        _view_map.hidden = true;
        _view_gray_manual.hidden = true;

    }
}

-(IBAction)map_tap:(UIGestureRecognizer *) gesture {
    NSLog(@"MAP TAP");
    if (gesture.state != UIGestureRecognizerStateEnded)
        return;
    NSLog(@"MAP TAP2");
    
    CGPoint touchPoint = [gesture locationInView:_map_view];
    CLLocationCoordinate2D loc = [_map_view convertPoint:touchPoint toCoordinateFromView:_map_view];
    
    [self tap_location:loc];
    /*
    manual_location = loc;

    if(IS_DEBUG) NSLog(@"TOUCHED: lat: %f long: %f",loc.latitude,loc.longitude);
    
    if(!(point_annotation == nil)) {
        [_map_view removeAnnotation:point_annotation];
    }
    
    point_annotation = [[MKPointAnnotation alloc] init];
    point_annotation.title = @"REPORT LOCATION";
    point_annotation.coordinate = loc;
    [_map_view addAnnotation:point_annotation];
     */
    
}
-(void) tap_location:(CLLocationCoordinate2D) loc {
    manual_location = loc;
    
    if(IS_DEBUG) NSLog(@"TOUCHED: lat: %f long: %f",loc.latitude,loc.longitude);
    
    if(!(point_annotation == nil)) {
        [_map_view removeAnnotation:point_annotation];
    }
    
    point_annotation = [[MKPointAnnotation alloc] init];
    point_annotation.title = @"REPORT LOCATION";
    point_annotation.coordinate = loc;
    [_map_view addAnnotation:point_annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
    // NSLog(@"viewForAnnotation() %@",annotation);
    
    
    
    MKPinAnnotationView *map_view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"my_location"];

    map_view.pinColor = MKPinAnnotationColorGreen;
    map_view.canShowCallout = true;
    map_view.restorationIdentifier = @"my_location";

    return map_view;
}



- (IBAction)close_map:(id)sender {
    _view_map.hidden = true;
    _view_gray_manual.hidden = true;
}


- (IBAction)submit:(id)sender {
    
    if(![mySession objectForKey:@"disclaimer_pirep"]) {
        alert_disclaimer = [[UIAlertView alloc]
                       initWithTitle:@"I understand the information I submit will be automatically transmitted to Lockheed Martin Flight Service. I agree to only submit accurate information."
                       message:nil
                       delegate:self
                       cancelButtonTitle:@"CANCEL"
                       otherButtonTitles:@"I AGREE", nil];
        [alert_disclaimer show];
        return;
        
    }
    
    
    if([_text_comment.text isEqualToString:@""] && ride == nil && wx == nil && icing == nil && [_wind_speed.text isEqualToString:@""] && !(_segment_cloud.selectedSegmentIndex >= 0)) {
        [myCommon doAlert:@"Did not select anything to report."];
        return;
    }
    if([_text_callsign.text isEqualToString:@""]) {
        [myCommon doAlert:@"Must enter a callsign registration, example: N1234"];
        return;
    }
    if([_text_callsign_type.text isEqualToString:@""]) {
        [myCommon doAlert:@"Must enter a ICAO aircraft type, example: B738"];
        return;
    }
    if(![_wind_degrees.text isEqualToString:@""] && [_wind_speed.text isEqualToString:@""]) {
        [myCommon doAlert:@"Must enter a wind speed."];
        return;
    }
    if([_wind_degrees.text isEqualToString:@""] && ![_wind_speed.text isEqualToString:@""]) {
        [myCommon doAlert:@"Must enter a wind from degrees."];
        return;
    }
    if(icing != nil && [_oat.text isEqualToString:@""]) {
        [myCommon doAlert:@"Must enter outside air temperature in celcius to submit a icing pirep."];
        return;
    }
    float wind_degrees_float = [_wind_degrees.text floatValue];
    float wind_speed_float = [_wind_speed.text floatValue];
    if(wind_degrees_float > 365) {
        [myCommon doAlert:@"Wind degrees is invalid."];
        return;
    }
    if(wind_speed_float < 0 || wind_speed_float > 400) {
        [myCommon doAlert:@"Wind speed is invalid."];
        return;
    }
    
    //save for future use...
    [mySession setObject:_text_callsign.text forKey:@"callsign"];
    [mySession setObject:_text_callsign_type.text forKey:@"callsign_type"];
    [myCommon writeSession];
    
    long time = [[NSDate date] timeIntervalSince1970] - (lroundf(_slider_time.value) * 60);
    
    NSString *comment = [_text_comment.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    if(ride == nil)
        ride = @"na";
/*
    NSString *is_noisy = @"no";
    if(noisy)
        is_noisy = @"yes";

    NSString *is_smelly = @"no";
    if(smelly)
        is_smelly = @"yes";

    NSString *is_clean = @"na";
    if(clean == true)
        is_clean = @"yes";
    else if(old == true)
        is_clean = @"no";
 */
    
    NSString *is_facebook = @"no";
    if(facebook)
        is_facebook = @"yes";

    NSString *is_twitter = @"no";
    if(twitter)
        is_twitter = @"yes";
 
    NSString *ride_frequency = @"na";
    if(_segment_ride.selectedSegmentIndex == 0)
        ride_frequency = @"occasional";
    else if(_segment_ride.selectedSegmentIndex == 1)
        ride_frequency = @"continuous";

    NSString *icing_type = @"na";
    if(_segment_ice_type.selectedSegmentIndex == 0)
        icing_type = @"clear";
    else if(_segment_ice_type.selectedSegmentIndex == 1)
        icing_type = @"rime";
    else if(_segment_ice_type.selectedSegmentIndex == 2)
        icing_type = @"rime";

    NSString *altitude = @"";
    if(_segment_location.selectedSegmentIndex == 0) {
        
        if(singletonObject->gps.horizontalAccuracy < 0 || singletonObject->gps.verticalAccuracy < 0) {
            [myCommon doAlert:@"GPS Signal is not available, make sure airplane mode is turned off or selected a location and altitude manually"];
            return;
        }
        //display gps error here...
        manual_location = singletonObject->gps.coordinate;
        altitude = [NSString stringWithFormat:@"%.0f",(singletonObject->gps.altitude * 3.2808399)/100];
        NSLog(@"ALT HERE IS: %@",altitude);
    }else{
        altitude = [NSString stringWithFormat:@"%ld",manual_altitude];
        
        if(manual_location.latitude == 0) {
            [myCommon doAlert:@"Did not select manual location, tap manual and tap the area on the map of observation."];
            return;
        }
    }
//    if([altitude isEqualToString:@"FL000"]) {
//        altitude = [self convert_altitude_flight_level:singletonObject->gps.altitude * 3.2808399];
//    }

    NSString *cloud = @"na";
    if(_segment_cloud.selectedSegmentIndex == 0)
        cloud = @"skc";
    else if(_segment_cloud.selectedSegmentIndex == 1)
        cloud = @"few";
    else if(_segment_cloud.selectedSegmentIndex == 2)
        cloud = @"sct";
    else if(_segment_cloud.selectedSegmentIndex == 3)
        cloud = @"bkn";
    else if(_segment_cloud.selectedSegmentIndex == 4)
        cloud = @"ovc";
    
    NSString *wind = @"";
    if(![_wind_speed.text isEqualToString:@""]) {
        float speed = [_wind_speed.text floatValue];
        float degrees = [_wind_degrees.text floatValue];

        NSString *extra_zero_1 = @"";
        if(degrees < 10)
            extra_zero_1 = @"00";
        else if(degrees < 100)
            extra_zero_1 = @"0";

        NSString *extra_zero_2 = @"";
        if(speed < 10)
            extra_zero_2 = @"0";

        wind = [NSString stringWithFormat:@"%@%.0f%@%.0f",extra_zero_1,degrees,extra_zero_2,speed];
    }
    //NSLog(@"WIND: =%@= wind_str: =%@=",_wind_speed.text,wind);
    //NSLog(@"OAT: =%@=",_oat.text);

    if(wx == nil)
        wx = @"na";
    if(ride == nil)
        ride = @"na";
    if(icing == nil)
        icing = @"na";
    
    NSString *turb_base = @"";
    NSString *turb_top = @"";

    NSString *cloud_base = @"";
    NSString *cloud_top = @"";
    
    NSString *icing_base = @"";
    NSString *icing_top = @"";
    
    if([slider1->label_min.text rangeOfString:@"BASES"].location == NSNotFound )
        turb_base = slider1->label_min.text;
    if([slider1->label_max.text rangeOfString:@"TOPS"].location == NSNotFound )
        turb_top = slider1->label_max.text;

    
    if([slider2->label_min.text rangeOfString:@"BASES"].location == NSNotFound )
        cloud_base = slider2->label_min.text;
    if([slider2->label_max.text rangeOfString:@"TOPS"].location == NSNotFound )
        cloud_top = slider2->label_max.text;

    
    if([slider3->label_min.text rangeOfString:@"BASES"].location == NSNotFound )
        icing_base = slider3->label_min.text;
    if([slider3->label_max.text rangeOfString:@"TOPS"].location == NSNotFound )
        icing_top = slider3->label_max.text;


    NSMutableDictionary *q_insert = [myCommon query:[NSString stringWithFormat:@"INSERT INTO pirep (pirep_time,name,my_lat,my_long,altitude,gps_lat,gps_long,gps_altitude,callsign,comment,ride,ride_frequency,wx,icing,icing_type,icing_base,icing_top,visibility,ride_base,ride_top,cloud,cloud_base,cloud_top,callsign_type,oat,wind,ride_type,photo,twitter,facebook,sync_remote) VALUES ('%ld','%@','%f','%f','%@','%f','%f','%f','%@','%@','%@','%@','%@', '%@','%@','%@','%@','%ld','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','yes')",time,[mySession objectForKey:@"name"],manual_location.latitude,manual_location.longitude,altitude,singletonObject->gps.coordinate.latitude,singletonObject->gps.coordinate.longitude,singletonObject->gps.altitude* 3.2808399,[mySession objectForKey:@"callsign"],comment,ride,ride_frequency,wx,icing,icing_type,icing_base,icing_top,visibility,turb_base,turb_top,cloud,cloud_base,cloud_top,_text_callsign_type.text,_oat.text,wind,ride_type,image_encode,is_twitter,is_facebook]];

    NSString *pirep_id = [q_insert objectForKey:@"last_insert_id"];
    
    NSMutableArray *pirep_data = [myCommon get_pirep:pirep_id local:true];

    UIImage *share_image = nil;
    if(![image_encode isEqualToString:@""])
        share_image = _image.image;
    if(facebook) {
        [singletonObject facebook_post:[NSString stringWithFormat:@"%@\n%@ @AerovieReports",[pirep_data objectAtIndex:0],[pirep_data objectAtIndex:2]] image:share_image];
    }
    if(twitter) {
        [singletonObject twitter_post:[NSString stringWithFormat:@"@AerovieReports %@\n%@",[pirep_data objectAtIndex:0],[pirep_data objectAtIndex:2]] image:share_image];
    }
    
    //manual for now!!!
    [myCommon db_sync];
    
    
    UIViewController *p = self.parentViewController;
    [p viewDidAppear:true];
    
    [self cancel:self];
    
    [singletonObject set_background_mode];
}
/*
-(NSString *) convert_altitude_flight_level:(float) alt {
    alt /= 1000;
    NSString *alt_str = [NSString stringWithFormat:@"%0.f",alt];
    
    if(alt < 100)
        alt_str = [NSString stringWithFormat:@"0%0.f",alt];
    if(alt < 10)
        alt_str = [NSString stringWithFormat:@"00%0.f",alt];
    
    NSString *str = [NSString stringWithFormat:@"FL%@",alt_str];
    
    return str;
}
*/

//ride icons
-(void) reset_ride_icons {
    [_button_ride_negative setImage:[UIImage imageNamed:@"btn_neg.png"] forState:UIControlStateNormal];
    [_button_ride_negative setImage:[UIImage imageNamed:@"btn_neg.png"] forState:UIControlStateNormal];
    [_button_ride_light setImage:[UIImage imageNamed:@"btn_light.png"] forState:UIControlStateNormal];
    [_button_ride_light_moderate setImage:[UIImage imageNamed:@"btn_moderate.png"] forState:UIControlStateNormal];
    [_button_ride_moderate setImage:[UIImage imageNamed:@"btn_light-moderate.png"] forState:UIControlStateNormal];
    [_button_ride_moderate_severe setImage:[UIImage imageNamed:@"btn_moderate-severe.png"] forState:UIControlStateNormal];
    [_button_ride_severe setImage:[UIImage imageNamed:@"btn_severe.png"] forState:UIControlStateNormal];
    [_button_ride_extreme setImage:[UIImage imageNamed:@"btn_extreme.png"] forState:UIControlStateNormal];
}

- (IBAction)ride_negative:(id)sender {
    [self reset_ride_icons];
    [_button_ride_negative setImage:[UIImage imageNamed:@"btn_neg_active.png"] forState:UIControlStateNormal];
    
    _text_ride_description.text = @"The ride is mostly smooth.";
    _label_ride.text = @"SMOOTH";
    
    ride = @"smooth";
}

- (IBAction)ride_light:(id)sender {
    [self reset_ride_icons];
    [_button_ride_light setImage:[UIImage imageNamed:@"btn_light_active.png"] forState:UIControlStateNormal];
    
    _text_ride_description.text = @"Occupants may feel a slight strain against seat belts. Unsecured objects may be displaced slightly. Food service may be conducted and little or no difficulty is encountered in walking.";
    _label_ride.text = @"LIGHT TURBULENCE";

    ride = @"light";

}

- (IBAction)ride_light_moderate:(id)sender {
    [self reset_ride_icons];
    [_button_ride_light_moderate setImage:[UIImage imageNamed:@"btn_moderate_active.png"] forState:UIControlStateNormal];

    _text_ride_description.text = @"Occupants may feel strain against seat belts or shoulder straps. Unsecured objects may be displaced slightly. Food service may be conducted and little is encountered in walking.";
    _label_ride.text = @"LIGHT TO MODERATE";

    ride = @"light-moderate";

}
- (IBAction)ride_moderate:(id)sender {
    [self reset_ride_icons];
    [_button_ride_moderate setImage:[UIImage imageNamed:@"btn_light-moderate_on.png"] forState:UIControlStateNormal];

    _text_ride_description.text = @"Occupants feel definite strains against seat belts or shoulder straps. Unsecured objects are dislodged. Food service and walking are difficult.";
    _label_ride.text = @"MODERATE TURBULENCE";
    
    ride = @"moderate";

}
- (IBAction)ride_moderate_severe:(id)sender {
    [self reset_ride_icons];
    [_button_ride_moderate_severe setImage:[UIImage imageNamed:@"btn_moderate-severe_on.png"] forState:UIControlStateNormal];

    _text_ride_description.text = @"Occupants feel definite strains against seat belts or shoulder straps. Unsecured objects are dislodged. Food service and walking are difficult.";
    _label_ride.text = @"MODERATE TO SEVERE";

    ride = @"moderate-severe";
}
- (IBAction)ride_severe:(id)sender {
    [self reset_ride_icons];
    [_button_ride_severe setImage:[UIImage imageNamed:@"btn_severe_active.png"] forState:UIControlStateNormal];
    
    _text_ride_description.text = @"Occupants are forced violently against seat belts or shoulder straps. Unsecured objects are tossed about. Food Service and walking are impossible.";
    _label_ride.text = @"SEVERE TURBULENCE";

    ride = @"severe";
}
- (IBAction)ride_extreme:(id)sender {
    [self reset_ride_icons];
    [_button_ride_extreme setImage:[UIImage imageNamed:@"btn_extreme_on.png"] forState:UIControlStateNormal];

    _text_ride_description.text = @"Greater than severe, aircraft is impossible to control.";
    _label_ride.text = @"EXTREME TURBULENCE";

    ride = @"extreme";
}
- (IBAction)segment_ride_changed:(id)sender {
    //probably not needed
}
//end ride buttons


//wx buttons
-(void) reset_wx_icons {
//    [_button_wx_clear setImage:[UIImage imageNamed:@"btn_clear.png"] forState:UIControlStateNormal];
//    [_button_wx_cloudy setImage:[UIImage imageNamed:@"btn_cloudy.png"] forState:UIControlStateNormal];
    [_button_wx_neg setImage:[UIImage imageNamed:@"btn_neg.png"] forState:UIControlStateNormal];
    [_button_wx_rainy setImage:[UIImage imageNamed:@"btn_rain.png"] forState:UIControlStateNormal];
    [_button_wx_snow setImage:[UIImage imageNamed:@"btn_snow.png"] forState:UIControlStateNormal];
    [_button_wx_hail setImage:[UIImage imageNamed:@"btn_hail.png"] forState:UIControlStateNormal];
    [_button_wx_lightning setImage:[UIImage imageNamed:@"btn_lightning.png"] forState:UIControlStateNormal];
    [_button_wx_sleet setImage:[UIImage imageNamed:@"btn_sleet.png"] forState:UIControlStateNormal];
}

- (IBAction)wx_clear:(id)sender {
    [self reset_wx_icons];
  //  [_button_wx_clear setImage:[UIImage imageNamed:@"btn_clear_on.png"] forState:UIControlStateNormal];
    
    _text_wx_description.text = @"Clear sunshine or stars above";
    _label_wx.text = @"CLEAR";
    
    wx = @"clear";

}
- (IBAction)wx_cloudy:(id)sender {
    [self reset_wx_icons];
 //   [_button_wx_cloudy setImage:[UIImage imageNamed:@"btn_cloudy_on.png"] forState:UIControlStateNormal];
    
    _text_wx_description.text = @"Cloudy skies above.";
    _label_wx.text = @"CLOUDY";

    wx = @"cloudy";

}
- (IBAction)wx_neg:(id)sender {
    [self reset_wx_icons];
    [_button_wx_neg setImage:[UIImage imageNamed:@"btn_neg_active.png"] forState:UIControlStateNormal];
    
    _text_wx_description.text = @"";
    _label_wx.text = @"NEGATIVE";
    
    wx = nil;

}

- (IBAction)wx_rainy:(id)sender {
    [self reset_wx_icons];
    [_button_wx_rainy setImage:[UIImage imageNamed:@"btn_rain_on.png"] forState:UIControlStateNormal];
    
    _text_wx_description.text = @"Rain falling.";
    _label_wx.text = @"RAINY";

    wx = @"rainy";
}
- (IBAction)wx_snow:(id)sender {
    [self reset_wx_icons];
    [_button_wx_snow setImage:[UIImage imageNamed:@"btn_snow_on.png"] forState:UIControlStateNormal];
    
    _text_wx_description.text = @"Snow falling.";
    _label_wx.text = @"SNOWING";

    wx = @"snow";

}
- (IBAction)wx_hail:(id)sender {
    [self reset_wx_icons];
    [_button_wx_hail setImage:[UIImage imageNamed:@"btn_hail_on.png"] forState:UIControlStateNormal];
    
    _text_wx_description.text = @"Hail observed.";
    _label_wx.text = @"HAILING";
    wx = @"hail";

}
- (IBAction)wx_lightning:(id)sender {
    [self reset_wx_icons];
    [_button_wx_lightning setImage:[UIImage imageNamed:@"btn_lightning_on.png"] forState:UIControlStateNormal];
    
    _text_wx_description.text = @"Lightning or Thunder observed or heard.";
    _label_wx.text = @"THUNDERSTORM";

    wx = @"thunderstorm";

}
- (IBAction)wx_sleet:(id)sender {
    [self reset_wx_icons];
   [_button_wx_sleet setImage:[UIImage imageNamed:@"btn_sleet_on.png"] forState:UIControlStateNormal];
    
    _text_wx_description.text = @"Sleet observed.";
    _label_wx.text = @"SLEET";
    
    wx = @"sleet";

}
//end wx buttons


//aircraft buttons
-(void) reset_icing_icons {
    [_button_icing_none setImage:[UIImage imageNamed:@"btn_neg.png"] forState:UIControlStateNormal];
    [_button_icing_trace setImage:[UIImage imageNamed:@"btn_ice-trace.png"] forState:UIControlStateNormal];
    [_button_icing_light setImage:[UIImage imageNamed:@"btn_ice-light.png"] forState:UIControlStateNormal];
    [_button_icing_moderate setImage:[UIImage imageNamed:@"btn_ice-moderate.png"] forState:UIControlStateNormal];
    [_button_icing_severe setImage:[UIImage imageNamed:@"btn_ice-severe.png"] forState:UIControlStateNormal];
}


- (IBAction)icing_none:(id)sender {
    [self reset_icing_icons];
    [_button_icing_none setImage:[UIImage imageNamed:@"btn_neg_active.png"] forState:UIControlStateNormal];
    
    _label_icing.text = @"NEGATIVE ICING";
    
    icing = @"none";
}
- (IBAction)icing_trace:(id)sender {
    [self reset_icing_icons];
    [_button_icing_trace setImage:[UIImage imageNamed:@"btn_ice-trace_on.png"] forState:UIControlStateNormal];
    
    _label_icing.text = @"TRACE ICING";
    
    icing = @"trace";
}

- (IBAction)icing_light:(id)sender {
    [self reset_icing_icons];
    [_button_icing_light setImage:[UIImage imageNamed:@"btn_ice-light_on.png"] forState:UIControlStateNormal];
    
    _label_icing.text = @"LIGHT ICING";
    
    icing = @"light";
}
- (IBAction)icing_moderate:(id)sender {
    [self reset_icing_icons];
    [_button_icing_moderate setImage:[UIImage imageNamed:@"btn_ice-moderate_on.png"] forState:UIControlStateNormal];
    
    _label_icing.text = @"MODERATE ICING";
    
    icing = @"moderate";
}
- (IBAction)icing_severe:(id)sender {
    [self reset_icing_icons];
    [_button_icing_severe setImage:[UIImage imageNamed:@"btn_ice-severe_on.png"] forState:UIControlStateNormal];
    
    _label_icing.text = @"SEVERE ICING";
    
    icing = @"severe";
}

- (IBAction)cancel:(id)sender {
    [singletonObject remove_gray];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}



- (IBAction)twitter_toggle:(id)sender {
    if(twitter == true) {
        [_button_twitter setImage:[UIImage imageNamed:@"sharing-btn_twitter.png"] forState:UIControlStateNormal];
        twitter = false;
    }else{
        twitter = true;
        [_button_twitter setImage:[UIImage imageNamed:@"sharing-btn_twitter_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)facebook_toggle:(id)sender {
    if(facebook == true) {
        facebook = false;
        [_button_facebook setImage:[UIImage imageNamed:@"sharing-btn_fb.png"] forState:UIControlStateNormal];
    }else{
        facebook = true;
        [_button_facebook setImage:[UIImage imageNamed:@"sharing-btn_fb_on.png"] forState:UIControlStateNormal];
    }
}








//CAMERA BS

- (IBAction)photo_button:(id)sender {
    alert_photo = [[UIAlertView alloc]
                          initWithTitle:@"Take photo or view photo library?"
                          message:nil
                          delegate:self
                          cancelButtonTitle:@"Take Photo"
                          otherButtonTitles:@"View Library", nil];
    [alert_photo show];
//    [self open_picture:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView == alert_photo) {
        if(buttonIndex == 0) {
            [self open_picture:true];
        }else{
            [self open_picture:false];
        }
    }else if(alertView == alert_disclaimer) {
        if(buttonIndex == 0) {
            return;
        }else{
            [mySession setObject:@"1" forKey:@"disclaimer_pirep"];
            [myCommon writeSession];
            [self submit:nil];
        }
    }
}


-(BOOL) check_camera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [myCommon doAlert:@"No camera on device"];
        return false;
    }
    return true;
}

- (IBAction)open_picture:(BOOL) take_photo {
    if(![self check_camera])
        return;
    
    /* UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
     
     imagePicker.delegate = self;
     
     imagePicker.sourceType =
     UIImagePickerControllerSourceTypeCamera;
     
     imagePicker.mediaTypes = [NSArray arrayWithObjects:
     (NSString *) kUTTypeImage,
     (NSString *) kUTTypeMovie, nil];
     
     imagePicker.allowsEditing = YES;
     [self presentViewController:imagePicker animated:true completion:nil];
     */
    
    /*https://developer.apple.com/library/ios/documentation/uikit/reference/UIImagePickerController_Class/UIImagePickerController/UIImagePickerController.html
     */
    
    //take photo
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    //    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if(take_photo)
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
    //select photo
    /*
     
     UIImagePickerController *picker = [[UIImagePickerController alloc] init];
     picker.delegate = self;
     picker.allowsEditing = YES;
     picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
     [self presentViewController:picker animated:YES completion:NULL];
     */
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(IS_DEBUG) NSLog(@"blah blah didfinishpicking");
    
    
    //saved image
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //   self.imageView.image = chosenImage;
    
    //    NSData *image_data = UIImagePNGRepresentation(chosenImage);
    NSData *image_data = UIImageJPEGRepresentation(chosenImage, 0.4);  //quality from 0.0 - 1.0
    
    
    //endorsement_image = image_data;
    
    image_encode = [image_data base64EncodedStringWithOptions:0];
    _image.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if(IS_DEBUG) NSLog(@"blah blah imagepickercontrollerdidcancel");
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    //    if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait) {
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        singletonObject->portrait = true;
        //SET PORTRAIT STUFF HERE
        
        if(IS_DEBUG) NSLog(@"DID ROTATE STUFF PORT");
    }else{
        if(IS_DEBUG) NSLog(@"DID ROTATE STUFF LANDS");
        singletonObject->portrait = false;
    }
    [self set_orientation];
}

-(void) set_orientation {
    
    if(singletonObject->is_iphone) {
        
        CGSize screen = self.parentViewController.view.bounds.size;
        NSLog(@"PIREP ADJUST NEW HEIGHT: %f %f",screen.height,screen.height-40);
        _main_scroll.frame = CGRectMake(_main_scroll.frame.origin.x, _main_scroll.frame.origin.y, _main_scroll.frame.size.width, screen.height-40);
    }else{
        if(singletonObject->portrait == true) {
            set_portrait = true;
            if(IS_DEBUG) NSLog(@"SET ORIENTATION PORTRAIT");
    
            [myCommon change_frame_size:_main_view width:-70 height:0];

            [myCommon change_frame:_label_text_ride x:-11 y:0];
            [myCommon change_frame:_label_ride x:-11 y:0];
            [myCommon change_frame:_view_left x:-11 y:0];
        
            [myCommon change_frame:_label_text_weather x:-34 y:0];
            [myCommon change_frame:_label_wx x:-34 y:0];
            [myCommon change_frame:_view_middle x:-34 y:0];
            
            [myCommon change_frame:_label_text_aircraft x:-56 y:0];
            [myCommon change_frame:_label_icing x:-56 y:0];
            [myCommon change_frame:_view_right x:-56 y:0];

            [myCommon change_frame:_image x:-55 y:0];
            [myCommon change_frame:_button_add_photo x:-58 y:0];

            [myCommon change_frame:_button_submit x:-30 y:0];

        }else if(set_portrait == true) {
            set_portrait = false;
            if(IS_DEBUG) NSLog(@"SET ORIENTATION LANDSCAPE");
        
            [myCommon change_frame_size:_main_view width:70 height:0];
        
            [myCommon change_frame:_label_text_ride x:11 y:0];
            [myCommon change_frame:_label_ride x:11 y:0];
            [myCommon change_frame:_view_left x:11 y:0];
        
            [myCommon change_frame:_label_text_weather x:34 y:0];
            [myCommon change_frame:_label_wx x:34 y:0];
            [myCommon change_frame:_view_middle x:34 y:0];
        
            [myCommon change_frame:_label_text_aircraft x:56 y:0];
            [myCommon change_frame:_label_icing x:56 y:0];
            [myCommon change_frame:_view_right x:56 y:0];
        
            [myCommon change_frame:_image x:55 y:0];
            [myCommon change_frame:_button_add_photo x:58 y:0];
        
            [myCommon change_frame:_button_submit x:30 y:0];
        }
    }
    [singletonObject adjust_gray];
}

- (BOOL)shouldAutorotate {
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(!IS_IPHONE_4)
        return YES;
    
    if (orientation==UIInterfaceOrientationPortrait) {
        // do some sh!t
        return YES;
    }else{
        return NO;
    }
}
-(NSUInteger)supportedInterfaceOrientations{
    if(!IS_IPHONE_4)
        return UIInterfaceOrientationMaskAllButUpsideDown;
    else
        return UIInterfaceOrientationMaskPortrait;
}


- (IBAction)slider_visibility_changed:(id)sender {
    _slider_visibility.value = lroundf(_slider_visibility.value);
    
    if(_slider_visibility.value == 15) {
        _label_visibility.text = [NSString stringWithFormat:@">=10 SM"];
        visibility = 10;
    }else if(_slider_visibility.value == 1) {
        _label_visibility.text = [NSString stringWithFormat:@"<1/4 SM"];
        visibility = 0;
    }else if(_slider_visibility.value == 2) {
        _label_visibility.text = [NSString stringWithFormat:@"1/4 SM"];
        visibility = 0;
    }else if(_slider_visibility.value == 3) {
        _label_visibility.text = [NSString stringWithFormat:@"1/2 SM"];
        visibility = 0;
    }else if(_slider_visibility.value == 4) {
        _label_visibility.text = [NSString stringWithFormat:@"3/4 SM"];
        visibility = 0;
    }else if(_slider_visibility.value == 5) {
        _label_visibility.text = [NSString stringWithFormat:@"1 SM"];
        visibility = 1;
    }else if(_slider_visibility.value == 6) {
        _label_visibility.text = [NSString stringWithFormat:@"1 1/2 SM"];
        visibility = 1;
    }else if(_slider_visibility.value == 16) {
        _label_visibility.text = [NSString stringWithFormat:@"N/A"];
        visibility = -1;
    }else{
        _label_visibility.text = [NSString stringWithFormat:@"%.0f' SM",_slider_visibility.value - 5];
        visibility = _slider_visibility.value - 5;
    }
}

- (IBAction)ride_type_changed:(UISegmentedControl *) seg {
    if(seg.selectedSegmentIndex == 0)
        ride_type = @"TURBULENCE";
    else
        ride_type= @"CHOP";
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
