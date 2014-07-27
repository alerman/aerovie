//
//  Page.m
//  Aerovie-Lite
//
//  Created by Bryan Heitman on 11/25/13.
//  Copyright (c) 2013 DevStake, LLC. All rights reserved.
//

#import "Page.h"

@interface Page ()

@end

@implementation Page

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
   // flight_detail_swipe_position = @"right";
    
    callsign_type = @"";
    
    [self didRotateFromInterfaceOrientation:self];
    
    _button_filter_time.layer.borderColor = [UIColor whiteColor].CGColor;
    _button_filter_altitude.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _slider_altitude.transform = CGAffineTransformRotate(_slider_altitude.transform, degreesToRadian(-90));
    _slider_time.transform = CGAffineTransformRotate(_slider_time.transform, degreesToRadian(-90));
    cursor = nil;
    
    lock_load = false;
    
    right_bar_open = true;

    
    [singletonObject start_gps_tracking];
    
    annotations = [[NSMutableDictionary alloc] init];

//    [self load_data];
        
    annotation_load_position = 0;
    
    airline_id = @"";
    destination_id = @"";
    
    annotation_flight_cursor = nil;
    
    overlays = [[NSMutableDictionary alloc] init];
    
    play_timer = nil;
    network_timer = nil;
    
    play_loc.latitude = -1;
    
    image_gauge_speed_transform = _image_gauge_speed.transform;

//    _view_alt_bug.translatesAutoresizingMaskIntoConstraints = YES;
//    _image_gauge_speed.translatesAutoresizingMaskIntoConstraints = YES;
   // _image_gauge_speed.layer.frame = CGRectMake(_image_gauge_speed.frame.origin.x-12, _image_gauge_speed.frame.origin.y+1, _image_gauge_speed.frame.size.width, _image_gauge_speed.frame.size.height);
    _image_gauge_speed.layer.anchorPoint = CGPointMake(0.2,0.5);

    [self disable_altitude_speed];
    [self set_altitude_speed:@"200" speed:@"200" jitter:0];
    
    
    
    UISwipeGestureRecognizer *g_swipe_1 = [[UISwipeGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(flight_detail_swipe_left:)];
    [g_swipe_1 setDirection:UISwipeGestureRecognizerDirectionLeft];//|UISwipeGestureRecognizerDirectionRight)];
    [_view_flight_detail addGestureRecognizer:g_swipe_1];

    UISwipeGestureRecognizer *g_swipe_2 = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(flight_detail_swipe_right:)];
    [g_swipe_2 setDirection:UISwipeGestureRecognizerDirectionRight];//|UISwipeGestureRecognizerDirectionRight)];
    [_view_flight_detail addGestureRecognizer:g_swipe_2];

    UITapGestureRecognizer *g_tap1 = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(flight_detail_swipe_right:)];
    [_view_flight_detail addGestureRecognizer:g_tap1];

    UITapGestureRecognizer *g_tap2 = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(flight_detail_swipe_left:)];
    [_button_ok addGestureRecognizer:g_tap2];
    

//    UITapGestureRecognizer *g_tap_me_1 = [[UITapGestureRecognizer alloc]
  //                                        initWithTarget:self action:@selector(flight_detail_swipe_right:)];
  //  [_view_flight_detail addGestureRecognizer:g_tap_me_1];

    
    
    
    UISwipeGestureRecognizer *g_swipe_3 = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(right_bar_swipe_left:)];
    [g_swipe_3 setDirection:UISwipeGestureRecognizerDirectionLeft];//|UISwipeGestureRecognizerDirectionRight)];
    [_view_right_bar addGestureRecognizer:g_swipe_3];
    
    
    tap_right_gesture = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(right_bar_swipe_left:)];

    
    UISwipeGestureRecognizer *g_swipe_4 = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(right_bar_swipe_right:)];
    [g_swipe_4 setDirection:UISwipeGestureRecognizerDirectionRight];//|UISwipeGestureRecognizerDirectionRight)];
    [_view_right_bar addGestureRecognizer:g_swipe_4];
    
    chevron1_transform = _image_chevron_middle.transform;
    chevron2_transform = _image_chevron_right.transform;
    
    
    
    
    
    _slider_altitude.maximumValue = 600;
    _slider_altitude.minimumValue = 0;
    _slider_altitude.value = 600;

    _slider_time.maximumValue = 4*60;
    _slider_time.minimumValue = 5;
    _slider_time.value = 30;
    
    [self slider_time_changed:self];
    [self slider_altitude_changed:self];
    
    
    UITapGestureRecognizer *g_tap_image = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tooltip_tap_image:)];
    [_image_tooltip addGestureRecognizer:g_tap_image];

    if(IS_DEBUG) NSLog(@"twitter: %@",[mySession objectForKey:@"twitter"]);
    if(IS_DEBUG) NSLog(@"facebook: %@",[mySession objectForKey:@"facebook"]);
    
    
    if(![[mySession objectForKey:@"twitter"] isEqualToString:@""])
        [_button_twitter setImage:[UIImage imageNamed:@"hdr-btn_twitter_on.png"] forState:UIControlStateNormal];

    if(![[mySession objectForKey:@"facebook"] isEqualToString:@""])
        [_button_facebook setImage:[UIImage imageNamed:@"hdr-btn_fb_on.png"] forState:UIControlStateNormal];
    
    
    
    
    
    
    UITapGestureRecognizer *g_tap_fb = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tooltip_fb_tap:)];
    [_facebook_tooltip addGestureRecognizer:g_tap_fb];

    UITapGestureRecognizer *g_tap_twitter = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(tooltip_twitter_tap:)];
    [_twitter_tooltip addGestureRecognizer:g_tap_twitter];
    
    
    
    
    
    
    
    
    
    
    
    
    
    _selection_commercial.restorationIdentifier = @"commercial";
    UITapGestureRecognizer *s_tap_1 = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(selection_tap:)];
    [_selection_commercial addGestureRecognizer:s_tap_1];

    _selection_tail.restorationIdentifier = @"tail";
    UITapGestureRecognizer *s_tap_2 = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(selection_tap:)];
    [_selection_tail addGestureRecognizer:s_tap_2];

    
    _selection_airport.restorationIdentifier = @"airport";
    UITapGestureRecognizer *s_tap_3 = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(selection_tap:)];
    [_selection_airport addGestureRecognizer:s_tap_3];
    
    
    
    
    pirep_refresh_timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refresh_pireps:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:pirep_refresh_timer forMode:NSDefaultRunLoopMode];

    
    
    
    
    UITapGestureRecognizer *gps_tap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(gps_tap:)];
    [_image_gps addGestureRecognizer:gps_tap];

    timer_gps = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(gps_update:) userInfo:nil repeats:YES];
    [self gps_update:timer_gps];
    [[NSRunLoop currentRunLoop] addTimer:timer_gps forMode:NSDefaultRunLoopMode];

    
    flight_detail_swipe_position = @"right";
    
    
    //hide stuff
    UITapGestureRecognizer *hide_1 = [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(hide_dropdown:)];
     [_view_header addGestureRecognizer:hide_1];

    UITapGestureRecognizer *hide_2 = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(hide_dropdown:)];
    [hide_2 setCancelsTouchesInView:NO];
    [_view_map addGestureRecognizer:hide_2];
  
//    UITapGestureRecognizer *hide_3 = [[UITapGestureRecognizer alloc]
  //                                    initWithTarget:self action:@selector(hide_dropdown:)];
    //[_view_flight_detail addGestureRecognizer:hide_3];
    
    

    _image_tooltip.contentMode = UIViewContentModeScaleAspectFit;
    
    
    
    frame_text_airline = _text_airline.frame;
    frame_text_airport = _text_destination.frame;
    
    
    [self right_bar_swipe_right:nil];
    
    
//    if(singletonObject->is_iphone)
//    _text_tail.text = @"self";
//    [self flight_detail_swipe_left:nil];
    
    if([mySession objectForKey:@"callsign"] && ![[mySession objectForKey:@"callsign"] isEqualToString:@""]) {
        _text_tail.text = [mySession objectForKey:@"callsign"];
        middle_selection = @"tail";
        [self update_selection_checkbox];
        //NSLog(@"SWIPE LEFT HERE POS3 callsign: =%@=",[mySession objectForKey:@"callsign"]);
        [self flight_detail_swipe_left:nil];
        
        first_flight_open = true;
        [self get_flight:network_timer];
        _view_airport.hidden = true;
    }
    
    
    if(![mySession objectForKey:@"disclaimer_main"]) {
        alert_disclaimer = [[UIAlertView alloc]
                            initWithTitle:@"I understand using this application may not provide accurate, complete, or timely information. This product is not a replacement for a legal flight briefing, I will contact flight service for the latest information."
                            message:nil
                            delegate:self
                            cancelButtonTitle:@"CANCEL"
                            otherButtonTitles:@"I AGREE", nil];
        [alert_disclaimer show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView == alert_disclaimer) {
        if(buttonIndex == 0) {
            [self button_logout:nil];
        }else{
            [mySession setObject:@"1" forKey:@"disclaimer_main"];
            [myCommon writeSession];
        }
    }
}


-(void) set_alert_button {
    if(singletonObject->is_pirep_monitoring)
        [_button_alarm setImage:[UIImage imageNamed:@"hdr-btn_alerts_on.png"] forState:UIControlStateNormal];
    else
        [_button_alarm setImage:[UIImage imageNamed:@"hdr-btn_alerts.png"] forState:UIControlStateNormal];
}

-(void) refresh_pireps:(NSTimer *) timer {
    if(IS_DEBUG) NSLog(@"REFRESHING PIREPS NOW");

    [self set_alert_button];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotification:)
                                                 name:@"page_db_sync_complete" object:nil];

    [myCommon db_sync];
}

-(IBAction) hide_dropdown:(id)sender {
//    NSLog(@"hide dropdown");
    [self.view endEditing:true];
    if(IS_DEBUG) NSLog(@"MAIN TAP");

    //hide tooltip
    [cursor removeFromSuperview];
    _view_dropdown.hidden = true;

    _text_destination.frame = frame_text_airport;
    _text_airline.frame = frame_text_airline;

    
    [self close_tooltip:self];
}


-(void) viewDidAppear:(BOOL)animated {
    _label_name.text = [mySession objectForKey:@"name"];
    
    [self local_refresh:refresh_timer];
    [self set_alert_button];

}

-(void) selection_tap:(UIGestureRecognizer *) gesture {
    middle_selection = gesture.view.restorationIdentifier;

    [self update_selection_checkbox];
}
-(void) update_selection_checkbox {
    _selection_commercial.image = [UIImage imageNamed:@"selection-checkbox.png"];
    _selection_tail.image = [UIImage imageNamed:@"selection-checkbox.png"];
    _selection_airport.image = [UIImage imageNamed:@"selection-checkbox.png"];
    
    if([middle_selection isEqualToString:@"commercial"]) {
        _selection_commercial.image = [UIImage imageNamed:@"selection-checkbox_checked.png"];
        _label_flight_type.text = @"COMMERCIAL FLIGHT";
    }else if([middle_selection isEqualToString:@"tail"]) {
        _selection_tail.image = [UIImage imageNamed:@"selection-checkbox_checked.png"];
        _label_flight_type.text = @"PRIVATE FLIGHT";
    }else if([middle_selection isEqualToString:@"airport"])
        _selection_airport.image = [UIImage imageNamed:@"selection-checkbox_checked.png"];
}

-(void) local_refresh:(NSTimer *) timer {
    [timer invalidate];
    [refresh_timer invalidate];
    
    float interval = 0.8;
//    float interval = 0.4;
    NSTimeInterval time_since = [[NSDate date] timeIntervalSinceDate:date_last_refresh];
    date_last_refresh = [NSDate date];
    if(isnan(time_since) || time_since > interval+1 || time_since < interval) {
        if(IS_DEBUG) NSLog(@"REFRESH WAIT!!!!!");
        refresh_timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(local_refresh:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:refresh_timer forMode:NSDefaultRunLoopMode];
    }else{
        if(IS_DEBUG) NSLog(@"REFRESH NOW!!!!!!!!!!! %f interval: %f",time_since,interval);
        [_table_right reloadData];
        [self load_data];
    }
}

//HEADER BUTTONS
- (IBAction)button_logout:(id)sender {
    if(IS_DEBUG) {
        [myCommon open_query_debug:self.view];
        return;
    }
    
//    [myCommon clearSesssion];
    [mySession removeObjectForKey:@"session_id"];
    [mySession removeObjectForKey:@"last_api_auth_check"];
    [myCommon writeSession];

    [self performSegueWithIdentifier:@"logout_segue" sender:self];
    
   // NSLog(@"REMOVING PAGEFROM SUPERVIEW");
    [pirep_refresh_timer invalidate];
    [timer_gps invalidate];
    [play_timer invalidate];
    [network_timer invalidate];
    [refresh_timer invalidate];
    is_playing = false;
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)button_settings:(id)sender {
    settings = [self.storyboard instantiateViewControllerWithIdentifier:@"settings"];
    [self addChildViewController:settings];
    
    if(singletonObject->is_iphone) {
        CGSize screen = self.view.bounds.size;

        
        if(!singletonObject->portrait)
            settings.view.frame = CGRectMake((screen.width/2)-155, 40, 500, 400);
        else
            settings.view.frame = CGRectMake((screen.width/2)-155, 40, 500, 400);
    }else{
        if(!singletonObject->portrait)
            settings.view.frame = CGRectMake(505, 40, 500, 400);
        else
            settings.view.frame = CGRectMake(250, 40, 500, 400);
    }
    
    [self.view addSubview:settings.view];
    [settings didMoveToParentViewController:self];
}
- (IBAction)button_facebook:(id)sender {
    if([[mySession objectForKey:@"facebook"] isEqualToString:@""]) {
        [singletonObject facebook_login:_button_facebook];
    }else{
        [myCommon doAlert:@"You can now share information on your Facebook feed."];
  //      UIImage *my_image = [UIImage imageNamed:@"map_plane.png"];
        
//            [singletonObject facebook_post:@"Hello FB with image!" image:my_image];
       // [singletonObject facebook_post:@"Hello Five!" image:nil];
    }
}
- (IBAction)button_twitter:(id)sender {
    if([[mySession objectForKey:@"twitter"] isEqualToString:@""]) {
        [singletonObject twitter_login:_button_twitter];
    }else{
        //TEST POSTING STUFF
        [myCommon doAlert:@"You can now share information on your twitter feed."];

//        UIImage *my_image = [UIImage imageNamed:@"map_plane.png"];
//        [singletonObject twitter_post:@"Hello World!" image:nil];
//        [singletonObject twitter_post:@"Hello Ffive!" image:my_image];
    }
    
}
//END HEADER BUTTONS


//MIDDLE BAR
-(IBAction)flight_detail_swipe_left:(UIGestureRecognizer *) gesture {
    [self.view endEditing:YES];

   // NSLog(@"FLIGHT DETAIL ATTEMPT SWIPE LEFT");
    
    //start callsign check
    [self setup_callsign];
    BOOL ready = false;
    if([mySession objectForKey:@"callsign"] && !([[mySession objectForKey:@"callsign"] isEqualToString:@""]))
        ready = true;
    
    if(ready == false) {
        [myCommon doAlert:@"Enter a airline and flight #, a tail #, or select a nearby airport first."];
        return;
    }
    //end callsign check
    

    //    _image_chevron_middle.transform = chevron1_transform;
    [self hide_dropdown:self];

    flight_detail_swipe_position = @"left";
    
    _image_chevron_middle.image = [UIImage imageNamed:@"sb_toggle-arrow_close.png"];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _view_flight_detail.frame = CGRectMake(-_view_flight_detail.frame.size.width + 15, _view_flight_detail.frame.origin.y, _view_flight_detail.frame.size.width, _view_flight_detail.frame.size.height);
                         
                     }completion:^(BOOL finished) {
                         
                     }];
    
}
-(IBAction)flight_detail_swipe_right:(UIGestureRecognizer *) gesture {
  //  NSLog(@"FLIGHT ATTEMPT swipe right");
    flight_detail_swipe_position = @"right";
    [self hide_dropdown:self];
    

//    _image_chevron_middle.transform = CGAffineTransformRotate(chevron1_transform, degreesToRadian(-180));
    _image_chevron_middle.image = [UIImage imageNamed:@"sb_toggle-arrow_open.png"];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _view_flight_detail.frame = CGRectMake(0, _view_flight_detail.frame.origin.y, _view_flight_detail.frame.size.width, _view_flight_detail.frame.size.height);
                         
                     }completion:^(BOOL finished) {
                         
                     }];
    
}

- (IBAction)search_flight:(id)sender {
    return;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
    animations:^{
        _view_flight_detail.frame = CGRectMake(1100, _view_flight_detail.frame.origin.y, _view_flight_detail.frame.size.width, _view_flight_detail.frame.size.height);
        
    }completion:^(BOOL finished) {
     
     }];
     

}
- (IBAction)change_flight:(id)sender {
    return;
    _text_flight_number.text = @"";
    airline_id = @"";
    _text_airline.text = @"";
    _text_tail.text = @"";
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _view_flight_detail.frame = CGRectMake(190, _view_flight_detail.frame.origin.y, _view_flight_detail.frame.size.width, _view_flight_detail.frame.size.height);
                     }completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)new_report:(id)sender {
    [self.view endEditing:YES];
    [self setup_callsign];

    BOOL ready = false;
    if([mySession objectForKey:@"callsign"] && !([[mySession objectForKey:@"callsign"] isEqualToString:@""]))
        ready = true;
    
    if(ready == false) {
        [myCommon doAlert:@"Enter a airline and flight #, a tail #, or select a airport to make a new report."];
        return;
    }
    
    
    pirep = [self.storyboard instantiateViewControllerWithIdentifier:@"pirep"];
    [self addChildViewController:pirep];
    

    if(singletonObject->is_iphone) {
        CGSize screen = self.view.bounds.size;
        
        pirep.view.frame = CGRectMake((screen.width/2)-310/2, 40, 310, screen.height - 40);
    }else{

        if(singletonObject->portrait ) {
            pirep.view.frame = CGRectMake(4, 42, 760, 675);
        }else{
            pirep.view.frame = CGRectMake(97, 42, 830, 675);
        }
        

    }

    [self.view addSubview:pirep.view];

    [pirep didMoveToParentViewController:self];
}

- (IBAction)close_tooltip:(id)sender {
    _view_tooltip.hidden = true;
}


//FILTER STUFF
- (IBAction)filter_toggle:(id)sender {
    
    if(_view_filter_altitude.hidden == false) {
        _view_filter_altitude.hidden = true;
        _view_filter_time.hidden = true;
        [_button_filter setImage:[UIImage imageNamed:@"btn_map-filters.png"] forState:UIControlStateNormal];
    }else{
        [_button_filter setImage:[UIImage imageNamed:@"btn_map-filters-on.png"] forState:UIControlStateNormal];
        _view_filter_altitude.hidden = false;
        _view_filter_time.hidden = false;
    }
  
}
- (IBAction)filter_time_button:(id)sender {
    _slider_time.value = 30;
    [self slider_time_changed:self];
}
- (IBAction)filter_altitude_button:(id)sender {
    _slider_altitude.value = _slider_altitude.maximumValue;
    [self slider_altitude_changed:self];
}


- (IBAction)slider_altitude_changed:(id)sender {
    //label_altitude_feet
    
    NSInteger alt = _slider_altitude.value*100;
    _label_altitude_feet.text = [NSString stringWithFormat:@"< %@'",[myCommon add_comma:alt]];

    if(alt == 0)
        _label_altitude_feet.text = [NSString stringWithFormat:@"GROUND"];
    
    [self local_refresh:refresh_timer];
//    [_table_right reloadData];
//    [self load_data];

}
- (IBAction)slider_time_changed:(id)sender {
    //label_time_mins
    NSString *my_val = [NSString stringWithFormat:@"%ld mins",lroundf(_slider_time.value)];
    if(_slider_time.value > 100)
        my_val = [NSString stringWithFormat:@"%ld hours",lroundf(_slider_time.value/60)];

    _label_time_mins.text = [NSString stringWithFormat:@"< %@",my_val];
    
    [self local_refresh:refresh_timer];

    //[_table_right reloadData];
    //[self load_data];

}


//END FILTER STUFF






- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(_text_airline == textField) {
        _text_flight_number.text = @"";
        [self airline_tooltip];
        return YES;
    }else if(_text_destination == textField) {
  //      [self.view endEditing:YES];
        [self destination_tooltip];
        return YES;
    }else{
        [self hide_dropdown:self];

        return YES;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    if(IS_DEBUG) NSLog(@"FIELD END EDITING!!!!! callsign: =%@=",[mySession objectForKey:@"callsign"]);

    if(textField == _text_tail) {
        _text_tail.text = [_text_tail.text uppercaseString];
        _text_destination.text = @"";
        destination_id = @"";
        airline_id = @"";
        _text_airline.text = @"";
        _text_flight_number.text = @"";
        
        middle_selection = @"tail";
        [self update_selection_checkbox];
    }else if(textField == _text_destination) {
        _text_tail.text = @"";
        airline_id = @"";
        _text_airline.text = @"";
        _text_flight_number.text = @"";

        middle_selection = @"airport";
        [self update_selection_checkbox];

    }else if(textField == _text_airline || textField == _text_flight_number) {
        _text_destination.text = @"";
        destination_id = @"";
        _text_tail.text = @"";

        middle_selection = @"commercial";
        [self update_selection_checkbox];
    }
    
    [self setup_callsign];
    
    if((![airline_id isEqualToString:@""] && ![_text_flight_number.text isEqualToString:@""]) || ![_text_tail.text isEqualToString:@""] || ![destination_id isEqualToString:@""]) {
//        [self search_flight:self];
       // NSLog(@"SWIPE LEFT HERE POS1");
        [self flight_detail_swipe_left:(UIGestureRecognizer *) self];

        if([destination_id isEqualToString:@""]) {
            first_flight_open = true;
            [self get_flight:network_timer];
            _view_airport.hidden = true;
        }else{
            //AIRPORT ONLY OVERLAY
            
            [self remove_all_overlay];

            /*
            [self remove_overlay:@"direct_route"];
            [self remove_overlay:@"position_direct"];
            [_map removeAnnotation:dept_annotation];
            [_map removeAnnotation:dest_annotation];
            if(annotation_flight_cursor != nil) {
//                NSLog(@"REMOVING ANNOTATION OVERLAY");
                [network_timer invalidate];
                [play_timer invalidate];
                is_playing = false;
                [_map removeAnnotation:annotation_flight_cursor];
                annotation_flight_cursor = nil;
            }
             jitter_speed = 0;
             jitter_altitude = 0;
*/
            

            NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT my_lat,my_long,name,ident FROM cifp_airport WHERE cifp_airport_id = '%@'",destination_id]];
            NSMutableArray *rs = [q objectForKey:@"result"];
            
            NSMutableArray *loc_dept = [rs objectAtIndex:0];
            NSString *dept_lat = [loc_dept objectAtIndex:0];
            NSString *dept_long = [loc_dept objectAtIndex:1];
            NSString *dept_name = [loc_dept objectAtIndex:2];
            NSString *dept_ident = [loc_dept objectAtIndex:3];
            
            dept_annotation = [[MKPointAnnotation alloc] init];
            dept_annotation.title = [NSString stringWithFormat:@"%@ ",dept_name];
            dept_annotation.subtitle = dept_ident;
            dept_annotation.coordinate = CLLocationCoordinate2DMake([dept_lat floatValue], [dept_long floatValue]);
            [_map addAnnotation:dept_annotation];
            
            singletonObject->fa_loc.latitude = [dept_lat floatValue];
            singletonObject->fa_loc.longitude = [dept_long floatValue];
            singletonObject->fa_alt = @"FL000";
            
            _view_airport.hidden = false;
            
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [cursor removeFromSuperview];
    _view_dropdown.hidden = true;

    _text_destination.frame = frame_text_airport;
    _text_airline.frame = frame_text_airline;


    [textField resignFirstResponder];
    return YES;
}

- (IBAction)destination_changed:(id)sender {
    if(IS_DEBUG) NSLog(@"destination changed: =%@=",_text_destination.text);
    if(_view_dropdown.hidden == false)
        [_table_dropdown reloadData];
}
- (IBAction)airline_changed:(id)sender {
    if(IS_DEBUG) NSLog(@"AIRLINE changed: =%@=",_text_airline.text);
    if(_view_dropdown.hidden == false)
        [_table_dropdown reloadData];
}



-(void) airline_tooltip {
    if(!(cursor == nil))
        [cursor removeFromSuperview];
    
    _text_airline.text = @"";

    cursor = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tooltip-pointer.png"]];
    [self.view addSubview:cursor];
    
    if(singletonObject->is_iphone) {
        NSLog(@"overall width: %f",self.view.frame.size.height);
        NSLog(@"nonoverall width: %f",_view_dropdown.frame.size.width);

        if(!singletonObject->portrait) {
            _view_dropdown.frame = CGRectMake((self.view.frame.size.height/2) - (_view_dropdown.frame.size.width/2), 15, _view_dropdown.frame.size.width, 90);
            _text_airline.frame = CGRectMake((self.view.frame.size.height/2) - (_text_airline.frame.size.width/2), 45, _text_airline.frame.size.width, _text_airline.frame.size.height);
        
            cursor.frame = CGRectMake((self.view.frame.size.height/2)-(21/2), 105, 21, 9);
            cursor.transform = CGAffineTransformRotate(cursor.transform, degreesToRadian(0));
        }else{
            //portrait iPhone here
            _view_dropdown.frame = CGRectMake(5, 155, _view_dropdown.frame.size.width, 175);
            cursor.frame = CGRectMake(self.view.frame.size.width/2-10, 147, 21, 9);
            cursor.transform = CGAffineTransformRotate(cursor.transform, degreesToRadian(180));
            
        }
    }else{
        _view_dropdown.frame = CGRectMake(90, 130, _view_dropdown.frame.size.width, _view_dropdown.frame.size.height);
        cursor.frame = CGRectMake(90+145, 121, 21, 9);
        cursor.transform = CGAffineTransformRotate(cursor.transform, degreesToRadian(180));
    }
    _view_dropdown.hidden = false;
    
    dropdown_table = @"airline";
    [_table_dropdown reloadData];
    
    if(![airline_id isEqualToString:@""])
        [self find_dropdown_row];
    
  //  [self.view endEditing:true];
}

-(void) destination_tooltip {
    if(!(cursor == nil))
        [cursor removeFromSuperview];

    _text_destination.text = @"";
    
    cursor = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tooltip-pointer.png"]];
    
    if(singletonObject->is_iphone) {
        
        
        if(!singletonObject->portrait) {
            _view_dropdown.frame = CGRectMake((self.view.frame.size.height/2) - (_view_dropdown.frame.size.width/2), 15, _view_dropdown.frame.size.width, 90);
            _text_destination.frame = CGRectMake((self.view.frame.size.height/2) - (_text_destination.frame.size.width/2), 45, _text_destination.frame.size.width, _text_destination.frame.size.height);
        
            cursor.frame = CGRectMake((self.view.frame.size.height/2)-(21/2), 105, 21, 9);
            cursor.transform = CGAffineTransformRotate(cursor.transform, degreesToRadian(0));
        }else{
            _view_dropdown.frame = CGRectMake(5, 105, _view_dropdown.frame.size.width, 175);

            cursor.frame = CGRectMake((self.view.frame.size.width/2)-(21/2), 280, 21, 9);
            cursor.transform = CGAffineTransformRotate(cursor.transform, degreesToRadian(0));
        }
    }else{
        if(!singletonObject->portrait) {
            cursor.frame = CGRectMake(660+145, 121, 21, 9);
            _view_dropdown.frame = CGRectMake(660, 130, _view_dropdown.frame.size.width, _view_dropdown.frame.size.height);
        }else{
            cursor.frame = CGRectMake(225, 190, 21, 9);
            _view_dropdown.frame = CGRectMake(80, 198, _view_dropdown.frame.size.width, _view_dropdown.frame.size.height);
        }
        cursor.transform = CGAffineTransformRotate(cursor.transform, degreesToRadian(180));
    }

    [self.view addSubview:cursor];

    
    _view_dropdown.hidden = false;
    dropdown_table = @"destination";

    [_table_dropdown reloadData];

    if(![destination_id isEqualToString:@""])
        [self find_dropdown_row_destination];
    
//    [self.view endEditing:true];
}


-(void) setup_callsign {
    NSString *callsign = _text_tail.text;
    callsign_long = callsign;
    
    
    callsign_type = @"tail";
    
    
    if(!([airline_id isEqualToString:@""])) {
        callsign_type = @"airline";

        NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT ident,name FROM airline WHERE airline_id = '%@'",airline_id]];
        NSMutableArray *rs = [q objectForKey:@"result"];
        NSMutableArray *row = [rs objectAtIndex:0];

        callsign = [NSString stringWithFormat:@"%@%@",[row objectAtIndex:0],_text_flight_number.text];
        callsign_long = [NSString stringWithFormat:@"%@ (%@%@)",[[row objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[row objectAtIndex:0],_text_flight_number.text];
    }else if(![destination_id isEqualToString:@""]) {
        callsign_type = @"airport";

        NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT ident,name FROM cifp_airport WHERE cifp_airport_id = '%@'",destination_id]];
        NSMutableArray *rs = [q objectForKey:@"result"];
        NSMutableArray *row = [rs objectAtIndex:0];
        
        callsign = [row objectAtIndex:0];
        callsign_long = [NSString stringWithFormat:@"%@ (%@)",[[row objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[row objectAtIndex:0]];
    }
    NSLog(@"setup callsign long: %@ callsign: %@ type: %@",callsign_long,callsign,callsign_type);
    _label_callsign.text = callsign_long;
    _label_airport_callsign.text = callsign_long;

//    [myCommon doAlert:[NSString stringWithFormat:@"Callsign is now set to %@",callsign]];
    [mySession setObject:[callsign uppercaseString] forKey:@"callsign"];
//    NSLog(@"CALLSIGN IS NOW: =%@=",[mySession objectForKey:@"callsign"]);
}
//END MIDDLE BAR





//ACTION!!!

//anotations DICTINOARY
//key=pirep_id
//data=array
//0=annotation
//1=last-load-position, used for expirations

-(IBAction)right_bar_swipe_right:(UIGestureRecognizer *) gesture {
    if(right_bar_open == false)
        return;
    
    [_view_right_bar addGestureRecognizer:tap_right_gesture];

    _image_chevron_right.transform = CGAffineTransformRotate(chevron2_transform, degreesToRadian(-180));
    
    right_bar_open = false;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _view_right_bar.frame = CGRectMake(_view_right_bar.frame.origin.x + (_view_right_bar.frame.size.width-15), _view_right_bar.frame.origin.y, _view_right_bar.frame.size.width, _view_right_bar.frame.size.height);
                         
                     }completion:^(BOOL finished) {
                         
                     }];

}
-(IBAction)right_bar_swipe_left:(UIGestureRecognizer *) gesture {
    if(right_bar_open == true)
        return;

    [_view_right_bar removeGestureRecognizer:tap_right_gesture];

    _image_chevron_right.transform = chevron2_transform;
    
    float width = _view_right_bar.superview.frame.size.width;
    if(singletonObject->portrait)
        width = _view_right_bar.superview.frame.size.height;

    if(IS_DEBUG) NSLog(@"LEFT BAR X POS WAS: %f CHANGE TO: %f",_view_right_bar.frame.origin.x,width-_view_right_bar.frame.size.width);

    right_bar_open = true;

    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _view_right_bar.frame = CGRectMake(_view_right_bar.frame.origin.x - (_view_right_bar.frame.size.width-15), _view_right_bar.frame.origin.y, _view_right_bar.frame.size.width, _view_right_bar.frame.size.height);
                         
                     }completion:^(BOOL finished) {
                         
                     }];
}



-(void) load_data {
    if(lock_load == true)
        return;
    
    long check_time = [[NSDate date] timeIntervalSince1970] - (_slider_time.value*60);
//    long check_time = [[NSDate date] timeIntervalSince1970] - (24*60*60);

    annotation_load_position++;
    NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT pirep_id,my_lat,my_long,altitude,gps_lat,gps_long,gps_altitude FROM pirep WHERE deleted != 'yes' and cast(altitude as integer) < '%f' and pirep_time >= '%ld'",_slider_altitude.value,check_time]];
//    NSLog(@"success status: %@",[q objectForKey:@"success"]);
    NSMutableArray *rs = [q objectForKey:@"result"];

    //loop annotations
    for(NSInteger x = 0;x<[rs count];x++) {
        NSMutableArray *row = [rs objectAtIndex:x];
        //0=pirep_id
        //1=lat
        //2=long
        //3=altitude
        //4=gps_lat
        //5=gps_long
        //6=gps_altitude

        NSString *pirep_id = [row objectAtIndex:0];
        if([annotations objectForKey:pirep_id]) {
            NSMutableArray *arr = [annotations objectForKey:pirep_id];

            [arr replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%li",annotation_load_position]];
            continue;
        }
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        float my_lat = [[row objectAtIndex:1] floatValue];
        float my_long = [[row objectAtIndex:2] floatValue];
        if([[row objectAtIndex:2] isEqualToString:@""]) {
            my_lat = [[row objectAtIndex:4] floatValue];
            my_long = [[row objectAtIndex:5] floatValue];
        }
        
        if(IS_DEBUG) NSLog(@"ADDING pirep_id: %@ ANNOTATION AT loc: %f/%f",pirep_id,my_lat,my_long);
        
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(my_lat, my_long);
        MKPointAnnotation *newa = [[MKPointAnnotation alloc] init];
        newa.title = pirep_id;
        newa.coordinate = loc;
        
        [arr addObject:newa];
        [arr addObject:[NSString stringWithFormat:@"%li",annotation_load_position]];
        [annotations setObject:arr forKey:pirep_id];
        
        
        [_map addAnnotation:newa];
    }
    
    NSMutableArray *remove_keys = [[NSMutableArray alloc] init];
    for(NSString *key in annotations) {
        NSMutableArray *arr = [annotations objectForKey:key];
        if(IS_DEBUG) NSLog(@"value is: =%@=",[arr objectAtIndex:1]);
        long long this_id = [[arr objectAtIndex:1] longLongValue];
        
        if(this_id < annotation_load_position) {
            //NSLog(@"REMOVING ANNOTATION HERE");
            [_map removeAnnotation:[arr objectAtIndex:0]];
            [remove_keys addObject:key];
        }
    }
    for(NSString *key in remove_keys)
        [annotations removeObjectForKey:key];

    lock_load = false;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MKPointAnnotation *)annotation {
    // NSLog(@"viewForAnnotation() %@",annotation);
    
    MKPinAnnotationView *map_view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"my_location"];
    
    if(annotation == annotation_flight_cursor) {
        //    map_view.pinColor = MKPinAnnotationColorGreen;
        //map_view.animatesDrop = YES;
        map_view.enabled = YES;
        map_view.canShowCallout = true;
        
        map_view.image = [UIImage imageNamed:@"empty.png"];
        map_view.frame = CGRectMake(-16, -19.5, 32, 32);
        
        UIImageView *my_image_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_plane.png"]];
        plane_cursor_transform = my_image_view.transform;
        plane_cursor_image = my_image_view;
        [map_view addSubview:my_image_view];
        map_view.animatesDrop = false;
    }else if(annotation == dept_annotation || annotation == dest_annotation) {
        map_view.enabled = YES;
        map_view.canShowCallout = true;
    }else{
       if(IS_DEBUG)  NSLog(@"annotation: %@ map: %@",annotation,map_view);
    
        NSString *pirep_id = annotation.title;
        if(IS_DEBUG) NSLog(@"ANNOTATION LOAD!!!! pirep_id: %@",pirep_id);
    
        NSString *image = [self get_pirep_image:pirep_id];
    
    
        map_view.image = [UIImage imageNamed:image];
        map_view.canShowCallout = false;
        map_view.animatesDrop = false;
    
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pirep_tap:)];
        [map_view addGestureRecognizer:tap];
    }
    
    return map_view;
}

-(NSString *) get_pirep_image:(NSString *) pirep_id {
    NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT ride,wx,is_clean,is_noisy,is_smelly,icing FROM pirep WHERE pirep_id = '%@'",pirep_id]];
    if(IS_DEBUG) NSLog(@"success status: %@ pirep_id: =%@=",[q objectForKey:@"success"],pirep_id);
    NSMutableArray *rs = [q objectForKey:@"result"];
    if(!([rs count] > 0))
        return @"";
    
    NSMutableArray *row = [rs objectAtIndex:0];
    //0=ride
    //1=wx
    //2=is_clean
    //3=is_smelly
    //4=icing
    
    //look for most severe image...
    
    NSString *ride = [row objectAtIndex:0];
    NSString *wx = [row objectAtIndex:1];
    NSString *is_clean = [row objectAtIndex:2];
    NSString *is_noisy = [row objectAtIndex:3];
    NSString *is_smelly = [row objectAtIndex:4];
    NSString *is_icing = [row objectAtIndex:5];
    
    NSString *image = @"";
    
    NSInteger trump_level = 0;
    if([ride isEqualToString:@"smooth"])
        image = @"map_neg.png";
    else if([ride isEqualToString:@"light"])
        image = @"map_light.png";
    else if([ride isEqualToString:@"light-moderate"])
        image = @"map_light-moderate.png";
    else if([ride isEqualToString:@"moderate"]) {
        image = @"map_moderate.png";
        trump_level = 1;
    }else if([ride isEqualToString:@"moderate-severe"]) {
        image = @"map_moderate-severe.png";
        trump_level = 2;
    }else if([ride isEqualToString:@"severe"]) {
        image = @"map_severe.png";
        trump_level = 3;
    }else if([ride isEqualToString:@"extreme"]) {
        image = @"map_extreme.png";
        trump_level = 4;
    }
    
    if([wx isEqualToString:@"clear"] && [image isEqualToString:@""]) {
        image = @"map_clear.png";
    }else if([wx isEqualToString:@"cloudy"] && [image isEqualToString:@""]) {
        image = @"map_cloudy.png";
    }else if([wx isEqualToString:@"rainy"] && [image isEqualToString:@""]) {
        image = @"map_rain.png";
    }else if([wx isEqualToString:@"snow"]) {
        if(trump_level <= 1)
            image = @"map_snow.png";
    }else if([wx isEqualToString:@"icing"]) {
        image = @"map_ice.png";
    }else if([wx isEqualToString:@"hail"]) {
        image = @"map_hail.png";
    }else if([wx isEqualToString:@"thunderstorm"]) {
        image = @"map_lightning.png";
    }else if([wx isEqualToString:@"sleet"]) {
        if(trump_level <= 2)
            image = @"map_sleet.png";
    }
    if([image isEqualToString:@""]) {
        if(![is_icing isEqualToString:@"na"] && ![is_icing isEqualToString:@"none"])
            image = @"map_ice.png";
    }
    
    if([image isEqualToString:@""]) {
        if(IS_DEBUG) NSLog(@"IMAGE IS STILL NOTHING SO LET'S CHECK CLEAN NOISY clean: %@ noisy: %@ smelly: %@",is_clean,is_noisy,is_smelly);
        if([is_clean isEqualToString:@"yes"])
            image = @"map_new-clean.png";
        else if([is_clean isEqualToString:@"no"])
            image = @"map_old-dirty.png";
        else if([is_noisy isEqualToString:@"yes"])
            image = @"map_noisy.png";
        else if([is_smelly isEqualToString:@"yes"])
            image = @"map_smelly.png";
        if(IS_DEBUG) NSLog(@"image: =%@=",image);
    }
    
    if([image isEqualToString:@""]) {
        NSLog(@"DO NOT KNOW WHAT IMAGE TO DISPLAY");
        image = @"map_neg.png";
    }

    return image;
}


-(IBAction)pirep_tap:(UIGestureRecognizer *) gesture {
    MKPinAnnotationView *ann_view  = (MKPinAnnotationView *) gesture.view;
    MKPointAnnotation *ann = ann_view.annotation;
    NSString *pirep_id = ann.title;
    
    if(IS_DEBUG) NSLog(@"PIREP TAP pirep_id: =%@=",pirep_id);

    CGPoint tapPoint = [gesture locationInView:self.view];
    float x = tapPoint.x;
    float y = tapPoint.y;

    [self load_tooltip:pirep_id x:x y:y];
}

-(void) load_tooltip:(NSString *) pirep_id x:(float) x y:(float) y {
    //data
    NSMutableArray *pirep_data = [myCommon get_pirep:pirep_id local:false];
    if([pirep_data count] == 0)
        return;
    
    if(singletonObject->is_iphone)
       [self right_bar_swipe_right:nil];
    
    _text_tooltip_top.text = [pirep_data objectAtIndex:0];
    _label_tooltip_mins.text = [pirep_data objectAtIndex:1];
    _text_tooltip.text = [pirep_data objectAtIndex:2];
    
    [_text_tooltip_top scrollRangeToVisible:NSMakeRange(0, 0)];
    [_text_tooltip scrollRangeToVisible:NSMakeRange(0, 0)];

    
    BOOL photo = false;
    if([[pirep_data objectAtIndex:3] isKindOfClass:[UIImage class]]) {
        _image_tooltip.image = [pirep_data objectAtIndex:3];
        photo = true;
    }

    _twitter_tooltip.restorationIdentifier = pirep_id;
    _facebook_tooltip.restorationIdentifier = pirep_id;
    
    if(photo == false) {
        _view_tooltip.frame = CGRectMake(_view_tooltip.frame.origin.x, _view_tooltip.frame.origin.y, 250, 90);
        _image_tooltip.hidden = true;
    }else{
        _image_tooltip.hidden = false;
        if(singletonObject->is_iphone) {
            CGSize screen = self.view.bounds.size;
            
            float try_width = 250;
            float try_height = 208;
            if(try_height > screen.height-10)
                try_height = screen.height - 10;
            if(try_width > screen.width-10)
                try_width = screen.width - 10;
            _view_tooltip.frame = CGRectMake(_view_tooltip.frame.origin.x, _view_tooltip.frame.origin.y,try_width, try_height);
        }else
            _view_tooltip.frame = CGRectMake(_view_tooltip.frame.origin.x, _view_tooltip.frame.origin.y, 450, 365);
    }
    /*        float lines = ceilf(chars / CHARS_LINE); //was 40
     NSInteger height_comment = 15 * lines;
*/
    
    //dynamic adjust inside elements w/ and w/o photo
    _text_tooltip_top.frame = CGRectMake(_text_tooltip_top.frame.origin.x, _text_tooltip_top.frame.origin.y,  _view_tooltip.frame.size.width-20, _text_tooltip_top.frame.size.height);
    _button_close_tooltip.frame = CGRectMake(_view_tooltip.frame.size.width-30, _button_close_tooltip.frame.origin.y, _button_close_tooltip.frame.size.width, _button_close_tooltip.frame.size.height);
    
    _text_tooltip.frame = CGRectMake(_text_tooltip.frame.origin.x, _view_tooltip.frame.size.height-35, _view_tooltip.frame.size.width-62, _text_tooltip.frame.size.height); //correct
    _twitter_tooltip.frame = CGRectMake(_view_tooltip.frame.size.width-62,_view_tooltip.frame.size.height-30, _twitter_tooltip.frame.size.width, _twitter_tooltip.frame.size.height);
    _facebook_tooltip.frame = CGRectMake(_view_tooltip.frame.size.width-32,_view_tooltip.frame.size.height-30, _facebook_tooltip.frame.size.width, _facebook_tooltip.frame.size.height);
    
    
    
    //POSITION THE THING
    CGSize screen = self.view.bounds.size;
    
    float tooltip_width = _view_tooltip.frame.size.width;
    float tooltip_height = _view_tooltip.frame.size.height;
    
    float diff_y = (y + tooltip_height+5) - screen.height;
    float diff_x = (x + tooltip_width+5) - screen.width;

    if(IS_DEBUG) NSLog(@"diff_x: %f diff_y: %f  y: %f y+tooltip: %f screenH: %f t_width: %f t_height: %f",diff_x,diff_y,y,(y + tooltip_height),screen.height,tooltip_width,tooltip_height);
    
    if(diff_y < 0)
        diff_y = 0;
    
    if(diff_x < 0)
        diff_x = 0;

    _view_tooltip.frame = CGRectMake(x-diff_x, y-diff_y, tooltip_width, tooltip_height);
    _view_tooltip.hidden = false;
//    _view_tooltip.translatesAutoresizingMaskIntoConstraints = YES;
}

-(IBAction) tooltip_tap_image:(UIGestureRecognizer *) gesture {
    if(IS_DEBUG) NSLog(@"tap tap tap");
    CGSize screen = self.view.bounds.size;

    big_image_view_bg = [[UIView alloc] init];
    big_image_view_bg.frame = CGRectMake(0, 0, screen.width, screen.height);
    big_image_view_bg.backgroundColor = [UIColor colorWithRed:69/255.0 green:80/255.0 blue:82/255.0 alpha:1];
    big_image_view_bg.alpha = 0.5;

    
    float margin = 100;
    float start_y = 100/2 - 33;
    if(singletonObject->is_iphone) {
        margin = 20;
        start_y = margin;
    }
    
    float h = big_image_view_bg.frame.size.height - margin/2 - start_y;
    NSLog(@"h: %f size_h: %f",h,big_image_view_bg.frame.size.height);
    big_image_view = [[UIView alloc] init];
    big_image_view.frame = CGRectMake(margin/2, start_y, big_image_view_bg.frame.size.width-margin, h);
    big_image_view.backgroundColor = [UIColor colorWithRed:208/255.0 green:218/255.0 blue:220/255.0 alpha:1];
    big_image_view.clipsToBounds = true;
    big_image_view.layer.cornerRadius = 5;
    
    NSLog(@"iMAGE WIDTH: %f HEIGHT: %f",_image_tooltip.image.size.width,_image_tooltip.image.size.height);
    
    UIImageView *image_v = [[UIImageView alloc] initWithImage:_image_tooltip.image];
    image_v.userInteractionEnabled = true;
    image_v.frame = CGRectMake(0, 33, big_image_view_bg.frame.size.width-margin, big_image_view_bg.frame.size.height-margin);
    big_image_image = image_v;
    image_v.contentMode = UIViewContentModeScaleAspectFit;
    
    
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 30, 1800, 1);
    line.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    
    UIButton *b1 = [[UIButton alloc] init];
    [b1 setTitle: @"Close" forState:UIControlStateNormal];
    b1.frame = CGRectMake(5, 5, 50, 25);
    [b1 setTitleColor:[UIColor colorWithRed:1/255.0 green:112/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
    
    UIButton *b2 = [[UIButton alloc] init];
    [b2 setTitle: @"Save Photo" forState:UIControlStateNormal];
    
    b2.frame = CGRectMake(big_image_view.frame.size.width-95, 5, 95, 25);
    
    [b2 setTitleColor:[UIColor colorWithRed:1/255.0 green:112/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
    
    button_save_photo = b2;
    
    [big_image_view addSubview:b1];
    [big_image_view addSubview:b2];
    [big_image_view addSubview:line];
    [big_image_view addSubview:image_v];
    [self.view addSubview:big_image_view_bg];
    [self.view addSubview:big_image_view];
    
 
    UITapGestureRecognizer *g1 = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(tooltip_big_close_button:)];
    [b1 addGestureRecognizer:g1];

    UITapGestureRecognizer *g2 = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self action:@selector(tooltip_big_save_button:)];
    [b2 addGestureRecognizer:g2];

}
/*
-(IBAction) tooltip_tap_image_twice:(UIGestureRecognizer *) gesture {
    UIView *v = [[UIView alloc] init];
    NSInteger width = 300;
    NSInteger height = 100;
    CGSize screen = big_image_view.frame.size;
    v.frame = CGRectMake(screen.width/2 - (width/2), screen.height + 5, width, height);
    v.layer.cornerRadius = 5;
    v.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    [big_image_view addSubview:v];
    
    UIButton *b1 = [[UIButton alloc] init];
    b1.frame = CGRectMake(5, 5, width - 10, 30);
    [b1 setTitle: @"Save Photo" forState:UIControlStateNormal];
    [b1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    UIButton *b2 = [[UIButton alloc] init];
    b2.frame = CGRectMake(5, 35, width - 10, 30);
    [b2 setTitle: @"Close" forState:UIControlStateNormal];
    [b2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    [v addSubview:b1];
    [v addSubview:b2];

    UITapGestureRecognizer *t1 = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(tooltip_big_close_button:)];
    [b2 addGestureRecognizer:t1];
    
    UITapGestureRecognizer *t2 = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self action:@selector(tooltip_big_save_button:)];
    [b1 addGestureRecognizer:t2];

    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                animations:^{
                v.frame = CGRectMake(screen.width/2 - (width/2), screen.height - height - 5, width, height);
     }completion:^(BOOL finished) {
     
     }];
}
*/
-(IBAction)tooltip_big_close_button:(id)sender {
    [big_image_view removeFromSuperview];
    [big_image_view_bg removeFromSuperview];
}

-(IBAction)tooltip_big_save_button:(id)sender {
    UIImageWriteToSavedPhotosAlbum(_image_tooltip.image,
                                   self, // send the message to 'self' when calling the callback
                                   @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                   NULL); // you generally won't need a contextInfo here
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        // Do anything needed to handle the error or display it to the user
        [myCommon doAlert:@"Could not save image to photo albums."];
    } else {
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
        [self tooltip_big_close_button:self];
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    NSLog(@"DID SAVE IS THIS USED??????");
}
- (IBAction)tooltip_twitter_tap:(UIGestureRecognizer *) gesture {
    NSString *pirep_id = gesture.view.restorationIdentifier;
    [self social_share:pirep_id type:@"twitter"];
}

- (IBAction)tooltip_fb_tap:(UIGestureRecognizer *) gesture {
    NSString *pirep_id = gesture.view.restorationIdentifier;
    [self social_share:pirep_id type:@"facebook"];
}

-(void) social_share:(NSString *) pirep_id type:(NSString * ) social_type {
    if(IS_DEBUG) NSLog(@"SOCIAL SHARE %@",pirep_id);
    NSString *image_icon_str = [self get_pirep_image:pirep_id];
    NSMutableArray *pirep_data = [myCommon get_pirep:pirep_id local:false];
    
    big_image_view_bg = [[UIView alloc] init];
    big_image_view = [[UIView alloc] init];
    big_image_view.clipsToBounds = true;
    CGSize screen = self.view.bounds.size;
    
    big_image_view.frame = CGRectMake((screen.width/2)-200, 100, 400, 200);
    big_image_view.layer.cornerRadius = 5;
    big_image_view.backgroundColor = [UIColor colorWithRed:208/255.0 green:218/255.0 blue:220/255.0 alpha:1];
    big_image_view_bg.frame = CGRectMake(0, 0, screen.width, screen.height);
    
    big_image_view_bg.backgroundColor = [UIColor colorWithRed:69/255.0 green:80/255.0 blue:82/255.0 alpha:1];
    big_image_view_bg.alpha = 0.5;
    
    UIImageView *image_v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image_icon_str]];
    image_v.frame = CGRectMake(5, 35, 38, 38);

    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 30, 900, 1);
    line.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];

    UIButton *b1 = [[UIButton alloc] init];
    [b1 setTitle: @"Close" forState:UIControlStateNormal];
    b1.frame = CGRectMake(2, 5, 50, 25);
    [b1 setTitleColor:[UIColor colorWithRed:1/255.0 green:112/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
    b1.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];

    UIButton *b2 = [[UIButton alloc] init];
    [b2 setTitle: @"Share" forState:UIControlStateNormal];
    b2.frame = CGRectMake(400-56, 5, 50, 25);
    [b2 setTitleColor:[UIColor colorWithRed:1/255.0 green:112/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
    b2.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];

    
    share_text = [[UITextView alloc] init];
    share_text.frame = CGRectMake(50, 35, 340, 150);
    share_text.textColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
    [share_text setFont:[UIFont fontWithName:@"Helvetica Neue" size:12.0f]];
    share_text.layer.cornerRadius = 5;

    
    UILabel *l = [[UILabel alloc] init];
    if([social_type isEqualToString:@"facebook"]) {
        l.text = @"Share to Facebook";
        share_text.text = [NSString stringWithFormat:@"%@ @AerovieReports",[pirep_data objectAtIndex:0]];
    }else if([social_type isEqualToString:@"twitter"]) {
        l.text = @"Share to Twitter";
        share_text.text = [NSString stringWithFormat:@"@AerovieReports \"%@\"",[pirep_data objectAtIndex:0]];
    }
    
    [l setFont:[UIFont fontWithName:@"Helvetica Neue" size:10.0f]];
    l.textColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
    l.frame = CGRectMake(400/2-45, 5, 90, 25);

    [big_image_view addSubview:l];
    [big_image_view addSubview:b1];
    [big_image_view addSubview:share_text];
    [big_image_view addSubview:b2];
    [big_image_view addSubview:image_v];
    [big_image_view addSubview:line];
    
    share_text.restorationIdentifier = pirep_id;
    
    b2.restorationIdentifier = social_type;
    
    UITapGestureRecognizer *g1 = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(close_share:)];
    [b1 addGestureRecognizer:g1];

    UITapGestureRecognizer *g2 = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self action:@selector(share_final:)];
    [b2 addGestureRecognizer:g2];
    
    [self.view addSubview:big_image_view_bg];
    [self.view addSubview:big_image_view];
}

-(void) share_final:(UIGestureRecognizer *) g {
    NSString *social_type = g.view.restorationIdentifier;
    NSString *pirep_id = share_text.restorationIdentifier;

    NSString *image_icon_str = [self get_pirep_image:pirep_id];
    NSMutableArray *pirep_data = [myCommon get_pirep:pirep_id local:false];

    if(IS_DEBUG) NSLog(@"SHARE_FINAL social_type: %@ pirep_id: %@",social_type,pirep_id);
    
    UIImage *image = [UIImage imageNamed:image_icon_str];
    if([[pirep_data objectAtIndex:3] isKindOfClass:[UIImage class]]) {
        //does contain image
        image = [pirep_data objectAtIndex:3];
    }

    if([social_type isEqualToString:@"facebook"]) {
        [singletonObject facebook_post:share_text.text image:image];
    }else if([social_type isEqualToString:@"twitter"]) {
        [singletonObject twitter_post:share_text.text image:image];
    }
    [self close_share:g];
}

-(void) close_share:(UIGestureRecognizer *) g {
    [big_image_view removeFromSuperview];
    [big_image_view_bg removeFromSuperview];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _table_dropdown) {
        
        if([dropdown_table isEqualToString:@"airline"]) {
            NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT COUNT(*) FROM airline WHERE ident like '%%%@%%' OR name LIKE '%%%@%%'",_text_airline.text,_text_airline.text]];
            NSMutableArray *rs = [q objectForKey:@"result"];
            NSMutableArray *row = [rs objectAtIndex:0];
            return [[row objectAtIndex:0] integerValue];
            
        }else if([dropdown_table isEqualToString:@"destination"]) {
            NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT COUNT(*) FROM cifp_airport WHERE ident LIKE '%%%@%%' OR name like '%%%@%%'",_text_destination.text,_text_destination.text]];
            NSMutableArray *rs = [q objectForKey:@"result"];
            NSMutableArray *row = [rs objectAtIndex:0];
            return [[row objectAtIndex:0] integerValue];
            
        }
        return 2;
    }else if(tableView == _table_right) {
        long check_time = [[NSDate date] timeIntervalSince1970] - (_slider_time.value*60);
        
        NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT COUNT(*) FROM pirep WHERE deleted !='yes' and cast(altitude as integer) < '%f' and pirep_time >= '%ld'",_slider_altitude.value,check_time]];
        NSMutableArray *rs = [q objectForKey:@"result"];
        NSMutableArray *row = [rs objectAtIndex:0];
        
        NSInteger count = [[row objectAtIndex:0] integerValue];
//        NSLog(@"blah blah blah %ld",count);
        if(count == 0)
            _text_no_pirep.hidden = false;
        else
            _text_no_pirep.hidden = true;

        return count;
//        return [[row objectAtIndex:0] integerValue];
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(IS_DEBUG) NSLog(@"HEIGHT FOR ROW: %li",(long)[indexPath row]);
    
    if(tableView == _table_right) {
        
        long check_time = [[NSDate date] timeIntervalSince1970] - (_slider_time.value*60);
        
        NSString *extra_query = @"";
        if(_slider_altitude.value != _slider_altitude.maximumValue)
            extra_query = [NSString stringWithFormat:@"cast(altitude as integer) < '%f' AND",_slider_altitude.value];
        
        
        if(IS_DEBUG) NSLog(@"HEIGHT FOR ROW: %li %@",(long)[indexPath row],extra_query);

        
        NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT pirep_id FROM pirep WHERE deleted !='yes' and %@ pirep_time >= '%ld' ORDER BY pirep_time DESC LIMIT %li,1",extra_query,check_time,(long)[indexPath row]]];
        NSMutableArray *rs = [q objectForKey:@"result"];
        if([rs count] == 0)
            return 30;
        
        NSMutableArray *row = [rs objectAtIndex:0];
    
        NSMutableArray *pirep_data = [myCommon get_pirep:[row objectAtIndex:0] local:false];
        float chars = [[pirep_data objectAtIndex:0] length];
        float lines = ceilf(chars / CHARS_LINE); //was 40
        NSInteger height_comment = 15 * lines;

        NSInteger user_image = 140;
        if(![[pirep_data objectAtIndex:3] isKindOfClass:[UIImage class]])
             user_image = 0;
        
        return 30+user_image+height_comment;
    }else
        return 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    

    if(IS_DEBUG) NSLog(@"CELL FOR ROW table row section: %li item: %li",indexPath.section,(long)indexPath.item);
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"content" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;

    if(tableView == _table_dropdown) {
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        
        if([dropdown_table isEqualToString:@"airline"]) {
            NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT airline_id,name,city FROM airline WHERE ident LIKE '%%%@%%' OR name LIKE '%%%@%%' ORDER BY name ASC LIMIT %li,1",_text_airline.text,_text_airline.text,(long)[indexPath row]]];
            NSMutableArray *rs = [q objectForKey:@"result"];
            NSMutableArray *row = [rs objectAtIndex:0];
            
            if([airline_id isEqualToString:[row objectAtIndex:0]]) {
                if(IS_DEBUG) NSLog(@"SELECT AIRLINE ID HERE!!!!!!!!!!");
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }

            cell.restorationIdentifier = [row objectAtIndex:0];
            if([[row objectAtIndex:2] isEqualToString:@""])
                label.text = [NSString stringWithFormat:@"%@",[row objectAtIndex:1]];
            else
                label.text = [NSString stringWithFormat:@"%@ (%@)",[row objectAtIndex:1],[row objectAtIndex:2]];
        }else if([dropdown_table isEqualToString:@"destination"]) {
            label.text = @"destination stuff";
            //ident LIKE '%%%@%%' OR name like '%%%@%%'
            NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT cifp_airport_id,ident,name FROM cifp_airport WHERE ident LIKE '%%%@%%' OR name like '%%%@%%' ORDER BY name ASC LIMIT %li,1",_text_destination.text,_text_destination.text,(long)[indexPath row]]];
            NSMutableArray *rs = [q objectForKey:@"result"];
            NSMutableArray *row = [rs objectAtIndex:0];
            
            if([destination_id isEqualToString:[row objectAtIndex:0]]) {
                if(IS_DEBUG) NSLog(@"SELECT DESTINATION ID HERE!!!!!!!!!!");
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
            cell.restorationIdentifier = [row objectAtIndex:0];
            label.text = [NSString stringWithFormat:@"(%@) %@",[row objectAtIndex:1],[row objectAtIndex:2]];
        }
    }else if(tableView == _table_right) {

        UIView *main_view = (UIView *) [cell viewWithTag:50];
        UIImageView *image_icon = (UIImageView *) [cell viewWithTag:1];
        UITextView *text_comment = (UITextView *) [cell viewWithTag:2];
        UILabel *label_mins = (UILabel *) [cell viewWithTag:3];
        UIImageView *image_user = (UIImageView *) [cell viewWithTag:4];

        image_user.contentMode = UIViewContentModeScaleAspectFit;
        
        //other table
        long check_time = [[NSDate date] timeIntervalSince1970] - (_slider_time.value*60);
        
        NSString *extra_query = @"";
        if(_slider_altitude.value != _slider_altitude.maximumValue)
            extra_query = [NSString stringWithFormat:@"cast(altitude as integer) < '%f' AND",_slider_altitude.value];

        
        NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT pirep_id FROM pirep WHERE deleted !='yes' and %@ pirep_time >= '%ld' ORDER BY pirep_time DESC LIMIT %li,1",extra_query,check_time,(long)[indexPath row]]];
        NSMutableArray *rs = [q objectForKey:@"result"];
        if(IS_DEBUG) NSLog(@"RIGHT CELL ROW_COUNT: %ld",[rs count]);
        if([rs count] == 0) {
            NSLog(@"RIGHT CELL NOT FOUND, RELOADING RIGHT TABLE NOW");
//            [_table_right reloadData];
            return cell;
        }
        NSMutableArray *row = [rs objectAtIndex:0];

        if(IS_DEBUG) NSLog(@"LOADING RIGHT ROW: %li",(long)[indexPath row]);
        cell.restorationIdentifier = [row objectAtIndex:0];

        NSMutableArray *pirep_data = [myCommon get_pirep:[row objectAtIndex:0] local:false];

        if([[pirep_data objectAtIndex:3] isKindOfClass:[UIImage class]]) {
            if(IS_DEBUG) NSLog(@"SETTING IMAGE ICON HERE");
            image_user.image = [pirep_data objectAtIndex:3];
        }

        
        //this adds buffer to the seperator at the bottom
        main_view.frame = CGRectMake(main_view.frame.origin.x, main_view.frame.origin.y,main_view.frame.size.width,cell.frame.size.height-4);
        NSString *image_icon_str = [self get_pirep_image:[row objectAtIndex:0]];
        image_icon_str = [image_icon_str stringByReplacingOccurrencesOfString:@"map_"
                                                                   withString:@"sb_"];
        image_icon.image = [UIImage imageNamed:image_icon_str];

        text_comment.text = [pirep_data objectAtIndex:0];
  //      text_comment.text = @"1 2 3 4 5 6 6 7 8 9 10 11 12 13 14 15 16";
        float chars = [text_comment.text length];
        float lines = ceilf(chars / CHARS_LINE); //was 40

        NSInteger height_comment = 15 * lines;
        
        label_mins.text = [pirep_data objectAtIndex:1];
        
        
        label_mins.frame = CGRectMake(label_mins.frame.origin.x, 5+height_comment, label_mins.frame.size.width, label_mins.frame.size.height);
        image_user.frame = CGRectMake(image_user.frame.origin.x, 30+height_comment, image_user.frame.size.width, image_user.frame.size.height);

        if(IS_DEBUG) NSLog(@"2222 chars: %f LINES HERE: %f",chars,lines);

        
        if(![[pirep_data objectAtIndex:3] isKindOfClass:[UIImage class]]) {
            image_user.hidden = true;
        }else{
            image_user.hidden = false;
        }
    }
    return cell;
}
-(void) find_dropdown_row {
    if([airline_id isEqualToString:@""])
        return;
    
    NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT airline_id FROM airline WHERE name LIKE '%%%@%%' ORDER BY name ASC",_text_airline.text]];
    NSMutableArray *rs = [q objectForKey:@"result"];
    NSInteger z = 0;
    for(NSInteger x = 0;x<[rs count];x++) {
        z = x;
        NSMutableArray *row = [rs objectAtIndex:x];
        if(IS_DEBUG) NSLog(@"comparing row: %@ to airline: %@",[row objectAtIndex:0],airline_id);

        if([[row objectAtIndex:0] isEqualToString:airline_id])
            break;
    }
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:z inSection:0];
    [_table_dropdown selectRowAtIndexPath:index animated:false scrollPosition:UITableViewScrollPositionMiddle];
}

-(void) find_dropdown_row_destination {
    if([destination_id isEqualToString:@""])
        return;
    
    NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT cifp_airport_id FROM cifp_airport WHERE ident LIKE '%%%@%%' OR name like '%%%@%%' ORDER BY name ASC",_text_destination.text,_text_destination.text]];
    NSMutableArray *rs = [q objectForKey:@"result"];
    NSInteger z = 0;
    for(NSInteger x = 0;x<[rs count];x++) {
        z = x;
        NSMutableArray *row = [rs objectAtIndex:x];
        if(IS_DEBUG) NSLog(@"comparing row: %@ to destination_id: %@",[row objectAtIndex:0],destination_id);
        
        if([[row objectAtIndex:0] isEqualToString:destination_id])
            break;
    }
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:z inSection:0];
    [_table_dropdown selectRowAtIndexPath:index animated:false scrollPosition:UITableViewScrollPositionMiddle];
}
-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(IS_DEBUG) NSLog(@"UNSELECT didSelectRowAtIndexPath() tableView()");
    if(tableView == _table_dropdown) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        /*
        UITextView *myString = (UITextView *)[cell viewWithTag:1];
        NSLog(@"deselected row %@",myString.restorationIdentifier);
         */
    }else if(tableView == _table_right) {
        cell.accessoryType = UITableViewCellAccessoryNone;
/*        UITextView *myString = (UITextView *)[cell viewWithTag:1];
        NSLog(@"deselected2 row %@",myString.restorationIdentifier);
        cell.accessoryType = UITableViewCellAccessoryNone;
 */
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if(tableView == _table_dropdown) {
        [cursor removeFromSuperview];
        _view_dropdown.hidden = true;

        _text_destination.frame = frame_text_airport;
        _text_airline.frame = frame_text_airline;

        
        UILabel *label = (UILabel *)[cell viewWithTag:1];

        if([dropdown_table isEqualToString:@"airline"]) {
            _text_airline.text = label.text;
            airline_id = cell.restorationIdentifier;
            if(IS_DEBUG) NSLog(@"SETTING AIRLINE_ID TO: =%@=",airline_id);
            
        }else if([dropdown_table isEqualToString:@"destination"]) {
            _text_destination.text = label.text;
            destination_id = cell.restorationIdentifier;
        }
        [self.view endEditing:YES];
    }else if(tableView == _table_right) {
        cell.accessoryType = UITableViewCellAccessoryNone;


        if(IS_DEBUG) NSLog(@"TAPPED ON PIREP ID RIGHT SIDE: =%@=",cell.restorationIdentifier);
//        NSMutableArray *arr = [annotations objectForKey:cell.restorationIdentifier];
//        [_map selectAnnotation:[arr objectAtIndex:0]  animated:YES];
        
        NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT my_lat,my_long,gps_lat,gps_long,length(photo) FROM pirep WHERE pirep_id = '%@'",cell.restorationIdentifier]];
        if(IS_DEBUG) NSLog(@"success status: %@",[q objectForKey:@"success"]);
        NSMutableArray *rs = [q objectForKey:@"result"];
        NSMutableArray *row = [rs objectAtIndex:0];
        float my_lat = [[row objectAtIndex:0] floatValue];
        float my_long = [[row objectAtIndex:1] floatValue];
        if([[row objectAtIndex:1] isEqualToString:@""]) {
            my_lat = [[row objectAtIndex:2] floatValue];
            my_long = [[row objectAtIndex:3] floatValue];
        }
        
        
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta=10.0;
        span.longitudeDelta=10.0;
        region.center = CLLocationCoordinate2DMake(my_lat, my_long);
        region.span = span;
        
        [_map setRegion:region animated:false];
        
        /*
        float x = 200;
        float y = 430;
        if([annotations objectForKey:cell.restorationIdentifier]) {
            NSMutableArray *arr = [annotations objectForKey:cell.restorationIdentifier];
            
            CGPoint tapPoint = [[arr objectAtIndex:0] locationInView:self.view];
            float x = tapPoint.x;
            float y = tapPoint.y;
            NSLog(@"LOAD TOOLTIP X: %f Y: %f",x,y);
            
        }*/
      //  NSLog(@"image: %@",[row objectAtIndex:4]);
        if([[row objectAtIndex:4] isEqualToString:@"0"])
            [self load_tooltip:cell.restorationIdentifier x:250 y:430];
        else
            [self load_tooltip:cell.restorationIdentifier x:40 y:430];
    }
}

-(void) get_flight:(NSTimer *) timer {
    
    _label_loading.hidden = false;
    prev_status_label = _label_status.text;
    _label_status.text = @"- loading...";

    [timer invalidate];
    NSMutableDictionary *requestData = [[ NSMutableDictionary alloc] init];
    [requestData setObject:@"get_flight" forKey:@"request" ];
    [requestData setObject:[mySession objectForKey:@"callsign"] forKey:@"flight" ];
    [requestData setObject:@"get_flight" forKey:@"connection_description" ];
    [requestData setObject:[mySession objectForKey:@"session_id"] forKey:@"session_id" ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotification:)
                                                 name:[requestData objectForKey:@"connection_description"] object:nil];
    
    [myCommon apiRequest:requestData];
}

- (void)myNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];

    if([notification.name isEqualToString:@"get_flight"]) {
        _label_loading.hidden = true;

        NSMutableDictionary *flight = [notification.userInfo objectForKey:@"flight"];
        if(IS_DEBUG) NSLog(@"exist: %@ arrived: %@ dept: =%@= dest: =%@= alt: %@ dir: %@ speed: %@",[flight objectForKey:@"exist"],[flight objectForKey:@"arrived"],[flight objectForKey:@"dept"],[flight objectForKey:@"dest"],[flight objectForKey:@"altitude"],[flight objectForKey:@"direction"],[flight objectForKey:@"ground_speed"]);
        //exist
        //arrived
        //type
        //lat
        //long
        //direction
        //altitude
        //ground_speed
        //dept
        //dest
        
        //SKIP IF NOT FOUND OTHERWISE DIRECT ROUTE

        if(![[flight objectForKey:@"exist"] isEqualToString:@"1"]) {
      //      [myCommon doAlert:[NSString stringWithFormat:@"Could not find callsign: %@",[mySession objectForKey:@"callsign"]]];
            
            _label_status.text = @"- No flight found";
            if([notification.userInfo objectForKey:@"connect_fail"])
                _label_status.text = @"- Internet Offline";

            
            [self remove_all_overlay];
/*            singletonObject->fa_loc.latitude = 0;
            singletonObject->fa_loc.longitude = 0;
            
            _label_equipment.text = @"";
            _label_arrival.text = @"";
            _label_departure.text = @"";
            [self disable_altitude_speed];

            [network_timer invalidate];
            [play_timer invalidate];
            is_playing = false;
            [_map removeAnnotation:annotation_flight_cursor];
            annotation_flight_cursor = nil;
*/
            
            return;
        }
        [mySession setObject:[[flight objectForKey:@"type"] uppercaseString] forKey:@"callsign_type"];
        [myCommon writeSession];

        //NSLog(@"SETUP TYPE HIZHERE %@ make: %@",[flight objectForKey:@"type"],[flight objectForKey:@"make"]);
        
        //SKIP IF NO CHANGE...
        if(play_loc.latitude == [[flight objectForKey:@"lat"] floatValue] && play_loc.longitude == [[flight objectForKey:@"long"] floatValue]) {
            // [myCommon doAlert:@"SAME SKIPPING"];
            if(IS_DEBUG) NSLog(@"NO CHANGE SKIPPING");
            _label_status.text = prev_status_label;

            return;
        }
        
        [self remove_overlay:@"direct_route"];
        [self remove_overlay:@"position_direct"];
        [_map removeAnnotation:dept_annotation];
        [_map removeAnnotation:dest_annotation];
        jitter_speed = 0;
        jitter_altitude = 0;

        
        NSString *dept_lat = @"";
        NSString *dept_long = @"";
        NSString *dest_lat = @"";
        NSString *dest_long = @"";
        
        NSString *dept_name = @"";
        NSString *dest_name = @"";
        
//        NSLog(@"DEPT_AIRPORT: =%@= DEST_AIRPORT: =%@=",[flight objectForKey:@"dept"],[flight objectForKey:@"dest"]);
        
        NSMutableDictionary *q = [myCommon query:[NSString stringWithFormat:@"SELECT my_lat,my_long,name FROM cifp_airport WHERE ident = '%@' and deleted != 'yes'",[flight objectForKey:@"dept"]]];
        NSMutableArray *rs = [q objectForKey:@"result"];
        
        if([rs count] > 0 && ![[flight objectForKey:@"dept"] isEqualToString:@""]) {
            NSMutableArray *loc_dept = [rs objectAtIndex:0];
            dept_lat = [loc_dept objectAtIndex:0];
            dept_long = [loc_dept objectAtIndex:1];
            dept_name = [loc_dept objectAtIndex:2];
        }
        NSMutableDictionary *q2 = [myCommon query:[NSString stringWithFormat:@"SELECT my_lat,my_long,name FROM cifp_airport WHERE ident = '%@' and deleted != 'yes'",[flight objectForKey:@"dest"]]];
        NSMutableArray *rs2 = [q2 objectForKey:@"result"];
        if([rs2 count] > 0 && ![[flight objectForKey:@"dest"] isEqualToString:@""]) {
            NSMutableArray *loc_dest = [rs2 objectAtIndex:0];
            dest_lat = [loc_dest objectAtIndex:0];
            dest_long = [loc_dest objectAtIndex:1];
            dest_name = [loc_dest objectAtIndex:2];
        }
        
        if([dept_lat isEqualToString:@""]) {
            dept_lat = [flight objectForKey:@"dept_lat"];
            dept_long = [flight objectForKey:@"dept_long"];
        }
        if([dest_lat isEqualToString:@""]) {
            dest_lat = [flight objectForKey:@"dest_lat"];
            dest_long = [flight objectForKey:@"dest_long"];
        }
             //   NSLog(@"dept: %@ dept_lat: %@ dept_long: %@",[flight objectForKey:@"dept"],dept_lat,dept_long);
               // NSLog(@"dest: %@ dest_lat: %@ dest_long: %@",[flight objectForKey:@"dest"],dest_lat,dest_long);
        
        if(![dept_lat isEqualToString:@""] && ![dest_lat isEqualToString:@""]) {
            
            //            NSLog(@"dept lat: %@ long: %@",[loc_dept objectAtIndex:0],[loc_dept objectAtIndex:1]);
            
            CLLocationCoordinate2D coords[3 + 10];
            coords[0] = CLLocationCoordinate2DMake([dept_lat floatValue], [dept_long floatValue]);
            coords[1] = CLLocationCoordinate2DMake([dest_lat floatValue], [dest_long floatValue]);
            
            MKPolyline *route = [MKPolyline polylineWithCoordinates:coords count:2];
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:route];
            [overlays setObject:arr forKey:@"direct_route"];
            [_map addOverlay:route];
            
            
            dept_annotation = [[MKPointAnnotation alloc] init];
            dept_annotation.title = [NSString stringWithFormat:@"%@ ",dept_name];
            dept_annotation.subtitle = [flight objectForKey:@"dept"];
            dept_annotation.coordinate = CLLocationCoordinate2DMake([dept_lat floatValue], [dept_long floatValue]);
            [_map addAnnotation:dept_annotation];

            dest_annotation = [[MKPointAnnotation alloc] init];
            dest_annotation.title = [NSString stringWithFormat:@"%@ ",dest_name];
            dest_annotation.subtitle = [flight objectForKey:@"dest"];
            dest_annotation.coordinate = CLLocationCoordinate2DMake([dest_lat floatValue], [dest_long floatValue]);
            [_map addAnnotation:dest_annotation];
            
            
            singletonObject->fa_loc.latitude = [dest_lat floatValue];
            singletonObject->fa_loc.longitude = [dest_long floatValue];
        }

        
        //IF ARRIVED SKIP THE REST
        if([[flight objectForKey:@"arrived"] isEqualToString:@"1"]) {
          //  [myCommon doAlert:@"arrived"];
            
            
            if(annotation_flight_cursor != nil) {
                [network_timer invalidate];
                [play_timer invalidate];
                is_playing = false;
                [_map removeAnnotation:annotation_flight_cursor];
                annotation_flight_cursor = nil;
            }
            
            [self disable_altitude_speed];
            
            _label_status.text = @"- Arrived";
            _label_equipment.text = [NSString stringWithFormat:@"%@ %@",[flight objectForKey:@"make"], [flight objectForKey:@"model"]];
            
            _label_departure.text = [NSString stringWithFormat:@"%@ EST",[flight objectForKey:@"dept_time"]];
            _label_arrival.text = [NSString stringWithFormat:@"%@ EST",[flight objectForKey:@"arrival_time"]];
            
            if(first_flight_open == true) {
                first_flight_open = false;
                [self set_region:singletonObject->fa_loc];
            }

            return;
        }
        //HERE GOES A ACTIVE ENROUTE FLIGHT BELOW
        
        _label_status.text = @"- Enroute";

        _label_departure.text = [NSString stringWithFormat:@"%@ EST",[flight objectForKey:@"dept_time"]];
        _label_arrival.text = [NSString stringWithFormat:@"%@ EST (estimated)",[flight objectForKey:@"arrival_time"]];

        //        NSLog(@"play_loc.lat: =%f= fligiht_lat: =%f=",play_loc.latitude,[[flight objectForKey:@"lat"] floatValue]);
        //_label_equipment.text = [flight objectForKey:@"type"];
        _label_equipment.text = [NSString stringWithFormat:@"%@ %@",[flight objectForKey:@"make"], [flight objectForKey:@"model"]];

        
        if([flight objectForKey:@"lat"] && [flight objectForKey:@"long"]) {
           if([[flight objectForKey:@"lat"] isEqualToString:@""] || [[flight objectForKey:@"long"] isEqualToString:@""]) {
           }else{
               NSString *my_lat = [flight objectForKey:@"lat"];
               NSString *my_long = [flight objectForKey:@"long"];
               
               singletonObject->fa_loc.latitude = [my_lat floatValue];
               singletonObject->fa_loc.longitude = [my_long floatValue];
               [self set_flight_cursor:my_lat my_long:my_long heading:[flight objectForKey:@"direction"]];
               singletonObject->fa_alt = [flight objectForKey:@"altitude"];
               
           }
        }
        
        [self set_altitude_speed:[flight objectForKey:@"altitude"] speed:[flight objectForKey:@"ground_speed"] jitter:false];
        
//        [self remove_overlay:@"direct_route"];
//        [self remove_overlay:@"position_direct"];

        
        
        if(![dest_lat isEqualToString:@""] && ![[flight objectForKey:@"lat"] isEqualToString:@""]) {
            CLLocationCoordinate2D coords[3 + 10];
            coords[0] = CLLocationCoordinate2DMake([dept_lat floatValue], [dept_long floatValue]);
            coords[1] = CLLocationCoordinate2DMake([[flight objectForKey:@"lat"] floatValue], [[flight objectForKey:@"long"] floatValue]);
            coords[2] = CLLocationCoordinate2DMake([dest_lat floatValue], [dest_long floatValue]);
            
            MKPolyline *route = [MKPolyline polylineWithCoordinates:coords count:3];
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:route];
            [overlays setObject:arr forKey:@"position_direct"];
            [_map addOverlay:route];
        }
        
        if(![[flight objectForKey:@"lat"] isEqualToString:@""]) {
            play_loc = CLLocationCoordinate2DMake([[flight objectForKey:@"lat"] floatValue], [[flight objectForKey:@"long"] floatValue]);
            play_direction = [[flight objectForKey:@"direction"] integerValue];
            play_speed = [[flight objectForKey:@"ground_speed"] floatValue];
            play_start = [NSDate date];

            is_playing = true;
            [self start_play:play_timer];
        }
        
        if(first_flight_open == true) {
            first_flight_open = false;
            [self set_region:singletonObject->fa_loc];
        }

        
        //run loop if it is a active flight
        network_timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(get_flight:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:network_timer forMode:NSDefaultRunLoopMode];
    }else if([notification.name isEqualToString:@"page_db_sync_complete"]) {
        [self local_refresh:refresh_timer];

    }
}
-(void) remove_all_overlay {
    [self remove_overlay:@"direct_route"];
    [self remove_overlay:@"position_direct"];
    [_map removeAnnotation:dept_annotation];
    [_map removeAnnotation:dest_annotation];
    
    singletonObject->fa_loc.latitude = 0;
    singletonObject->fa_loc.longitude = 0;
    
    _label_equipment.text = @"";
    _label_arrival.text = @"";
    _label_departure.text = @"";
    [self disable_altitude_speed];
    
    jitter_speed = 0;
    jitter_altitude = 0;

    [network_timer invalidate];
    [play_timer invalidate];
    is_playing = false;
    
    play_loc = CLLocationCoordinate2DMake(0,0);

    
    if(annotation_flight_cursor != nil) {
        //                NSLog(@"REMOVING ANNOTATION OVERLAY");
        [_map removeAnnotation:annotation_flight_cursor];
        annotation_flight_cursor = nil;
    }

}

-(void) set_region:(CLLocationCoordinate2D) loc {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=40.0;
    span.longitudeDelta=40.0;
    region.center = loc;
    region.span = span;
    
    [_map setRegion:region animated:false];
}

-(void) start_play:(NSTimer *) timer {
    if(is_playing == false)
        return;
    [timer invalidate];
    float rate = play_speed / 60 / 60; //second
    float seconds = [[NSDate date] timeIntervalSince1970] - [play_start timeIntervalSince1970];
    float distance = rate * seconds;
//    NSLog(@"play_speed: %ld rate: %f seconds: %f",(long)play_speed,rate,seconds);
    CLLocationCoordinate2D new_loc = [self coordinateFromCoord:play_loc atDistanceNm:distance atBearingDegrees:play_direction];

    //JITTER STUFF
    long speed_random = (long)arc4random()%JITTER_SPEED_LEVEL-(JITTER_SPEED_LEVEL/2);
    long altitude_random = (long)arc4random()%JITTER_ALT_LEVEL-(JITTER_ALT_LEVEL/2);

//    NSLog(@"blah blah blah: %li speed_random: %li alt_random: %li",blah,speed_random,altitude_random);
    
//    NSLog(@"HERE jitter_alt_new: %li jitter_speed_new: %li",jitter_altitude_new,jitter_speed_new);
    
    long alt_max = jitter_altitude + (jitter_altitude * JITTER_ALT_MAX);
    long alt_min = jitter_altitude - (jitter_altitude * JITTER_ALT_MAX);

    long speed_max = jitter_speed + (jitter_speed * JITTER_SPEED_MAX);
    long speed_min = jitter_speed - (jitter_speed * JITTER_SPEED_MAX);

    jitter_altitude_new = jitter_altitude_new + altitude_random;
    jitter_speed_new = jitter_speed_new + speed_random;
    
//    NSLog(@"jitter_alt_new: %li/%li alt_max: %li/%li jitter_speed_new: %li/%li speed_max: %li",jitter_altitude_new,altitude_random,alt_max,alt_min,jitter_speed_new,speed_random,speed_max);
    
    if(jitter_altitude_new < alt_min) {
        if(IS_DEBUG) NSLog(@"SETTING TO ALT MINS HERE %li < %li",jitter_altitude_new,alt_min);
        jitter_altitude_new = alt_min;
    }else if(jitter_altitude_new > alt_max) {
        if(IS_DEBUG) NSLog(@"SETTING TO ALT MAX HERE %li > %li",jitter_altitude_new,alt_max);
        jitter_altitude_new = alt_max;
    }
    
    if(jitter_speed_new < speed_min)
        jitter_speed_new = speed_min;
    else if(jitter_speed_new > speed_max)
        jitter_speed_new = speed_max;

//NSLog(@"!!HERE2 jitter_alt_new: %i jitter_speed_new: %i",jitter_altitude_new,jitter_speed_new);
    
    //END JITTER STUFF
    
    
    float interval_seconds = 1.0;
    
    NSDate *start_animation = [NSDate date];
    [UIView animateWithDuration:interval_seconds delay:0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self set_flight_cursor:[NSString stringWithFormat:@"%f",new_loc.latitude] my_long:[NSString stringWithFormat:@"%f",new_loc.longitude] heading:[NSString stringWithFormat:@"%ld",(long)play_direction]];
                         
                         [self set_altitude_speed:[NSString stringWithFormat:@"%li",(long)jitter_altitude_new] speed:[NSString stringWithFormat:@"%li",(long)jitter_speed_new] jitter:true];

                     }completion:^(BOOL finished) {
                         NSTimeInterval blah = interval_seconds - [[NSDate date] timeIntervalSinceDate:start_animation];
                         
                         if(blah > 0) {
                             [play_timer invalidate];
                             play_timer = [NSTimer scheduledTimerWithTimeInterval:blah target:self selector:@selector(start_play:) userInfo:nil repeats:NO];
                             [[NSRunLoop currentRunLoop] addTimer:play_timer forMode:NSDefaultRunLoopMode];
                         }else
                             [self start_play:play_timer];
                     }
     ];
}

- (CLLocationCoordinate2D)coordinateFromCoord:(CLLocationCoordinate2D)fromCoord
                                 atDistanceNm:(double)distanceNautical
                             atBearingDegrees:(double)bearingDegrees
{
    double distanceKm = distanceNautical * 1.852;
    double distanceRadians = distanceKm / 6371.0;
    //6,371 = Earth's radius in km
    double bearingRadians = [self radiansFromDegrees:bearingDegrees];
    double fromLatRadians = [self radiansFromDegrees:fromCoord.latitude];
    double fromLonRadians = [self radiansFromDegrees:fromCoord.longitude];
    
    double toLatRadians = asin(sin(fromLatRadians) * cos(distanceRadians)
                               + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians) );
    
    double toLonRadians = fromLonRadians + atan2(sin(bearingRadians)
                                                 * sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians)
                                                 - sin(fromLatRadians) * sin(toLatRadians));
    
    // adjust toLonRadians to be in the range -180 to +180...
    toLonRadians = fmod((toLonRadians + 3*M_PI), (2*M_PI)) - M_PI;
    
    CLLocationCoordinate2D result;
    result.latitude = [self degreesFromRadians:toLatRadians];
    result.longitude = [self degreesFromRadians:toLonRadians];
    
    return result;
}

- (double)radiansFromDegrees:(double)degrees
{
    return degrees * (M_PI/180.0);
}

- (double)degreesFromRadians:(double)radians
{
    return radians * (180.0/M_PI);
}

-(void) disable_altitude_speed {
    jitter_speed = 0;
    jitter_altitude = 0;

    _label_speed_knots.text = [NSString stringWithFormat:@"0 KNOTS/"];
    _label_speed_mph.text = [NSString stringWithFormat:@"0 MPH"];
    _label_altitude.text = [NSString stringWithFormat:@"0'"];
    
    _image_gauge_speed.alpha = 0.3;
    _label_speed_knots.alpha = 0.3;
    _label_speed_mph.alpha = 0.3;
    _label_altitude.alpha = 0.3;
    _label_desc_altitude.alpha = 0.3;
    _label_desc_speed.alpha = 0.3;
    
    _view_alt_bug.frame = CGRectMake(_view_alt_bug.frame.origin.x, 70, _view_alt_bug.frame.size.width, _view_alt_bug.frame.size.height);
    
    _image_gauge_speed.transform = CGAffineTransformRotate(image_gauge_speed_transform,degreesToRadian(-90));
    
/*    [UIView animateWithDuration:5.0 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _image_gauge_speed.transform = CGAffineTransformRotate(image_gauge_speed_transform,degreesToRadian(170));
                     }completion:^(BOOL finished) {
                         
                     }];
 */
}

-(void) set_altitude_speed:(NSString *) altitude speed:(NSString *) speed jitter:(BOOL) jitter {
    /*
    @property (weak, nonatomic) IBOutlet UIImageView *image_gauge_speed;
    @property (weak, nonatomic) IBOutlet UILabel *label_speed_knots;
    @property (weak, nonatomic) IBOutlet UILabel *label_speed_mph;
    @property (weak, nonatomic) IBOutlet UITextField *text_airline;
    @property (weak, nonatomic) IBOutlet UITextField *text_flight_number;
    @property (weak, nonatomic) IBOutlet UITextField *text_destination;
     
    @property (weak, nonatomic) IBOutlet UITextField *text_tail;
     
    @property (weak, nonatomic) IBOutlet UITableView *table_dropdown;
    @property (weak, nonatomic) IBOutlet UIView *view_dropdown;
     */
    
    if([speed isEqualToString:@""]) {
        [self disable_altitude_speed];
        return;
    }
    
    _image_gauge_speed.alpha = 1;
    _label_speed_knots.alpha = 1;
    _label_speed_mph.alpha = 1;
    _label_altitude.alpha = 1;
    _label_desc_altitude.alpha = 1;
    _label_desc_speed.alpha = 1;

    NSInteger alt = [altitude integerValue] * 100;
    if(jitter == false) {
        jitter_speed = [speed integerValue];
        jitter_altitude = [altitude integerValue]*100;
        jitter_speed_new = jitter_speed;
        jitter_altitude_new = jitter_altitude;
    }else
        alt = [altitude integerValue]; //send actual thousand for jitter
    

    _label_altitude.text = [NSString stringWithFormat:@"%@'",[myCommon add_comma:alt]];
    _label_speed_knots.text = [NSString stringWithFormat:@"%@ KNOTS/",speed];
    NSInteger mph = [speed integerValue] * 1.15078;
    _label_speed_mph.text = [NSString stringWithFormat:@"%li MPH",(long)mph];
    
    
    float alt_top = 45000;
    float alt_bottom = 0;
    float y_top = 5;
    float y_bottom = 70;
    float alt_float = alt;
    
    float pixel_height = (alt_top - alt_bottom) / (y_bottom-y_top);
    float pixel_position = y_bottom - (alt_float / pixel_height);
    if(pixel_position > y_bottom)
        pixel_position = y_bottom;
    else if(pixel_position < y_top)
        pixel_position = y_top;
    
    _view_alt_bug.frame = CGRectMake(_view_alt_bug.frame.origin.x, pixel_position, _view_alt_bug.frame.size.width, _view_alt_bug.frame.size.height);
  
   // NSLog(@"pixel_position: %f alt_float: %f pixel_height: %f",pixel_position,alt_float,pixel_height);
    
    float speed_float = [speed floatValue];
    float speed_top = 700;
    float speed_bottom = 0; //100
    float speed_pixel_degree = 365/(speed_top - speed_bottom); //degrees
    float speed_pixel_position = (speed_float - speed_bottom) * speed_pixel_degree;
    if(speed_pixel_position < 0)
        speed_pixel_degree = 0;
    else if(speed_pixel_position > 365)
        speed_pixel_degree = 365;
    
//    NSLog(@"speed: %f pixel_position: %f speed_pixel_degree: %f",speed_float,speed_pixel_position,speed_pixel_degree);
    _image_gauge_speed.transform = CGAffineTransformRotate(image_gauge_speed_transform,degreesToRadian(speed_pixel_position - 90));

}

-(void) remove_overlay:(NSString *) string {
    if([overlays objectForKey:string]) {
        NSMutableArray *arr = [overlays objectForKey:string];
        [_map removeOverlay:[arr objectAtIndex:0]];
        [overlays removeObjectForKey:string];
    }
}

-(void) set_flight_cursor:(NSString *) my_lat my_long:(NSString *) my_long heading:(NSString *) heading {
    if(annotation_flight_cursor == nil) {
        annotation_flight_cursor = [[MKPointAnnotation alloc] init];
        annotation_flight_cursor.title = callsign_long;
        annotation_flight_cursor.subtitle = @"My Flight";
        [_map addAnnotation:annotation_flight_cursor];
    }

    annotation_flight_cursor.coordinate = CLLocationCoordinate2DMake([my_lat doubleValue], [my_long doubleValue]);
    
    
    plane_cursor_image.layer.anchorPoint = CGPointMake(0,0);
    NSInteger heading_int = [heading integerValue];
    if(heading_int < 20) {
        //NSLog(@"HEADING < 20");
        plane_cursor_image.layer.anchorPoint = CGPointMake(0.5,0.8);
    }else if(heading_int > 200) {
        //NSLog(@"HEADING > 240");
        plane_cursor_image.layer.anchorPoint = CGPointMake(0.9,0.96);
    }else if(heading_int > 190) {
       // NSLog(@"HEADING > 190 %ld",heading_int);
        plane_cursor_image.layer.anchorPoint = CGPointMake(0.5,0.5);
    }//else
       // NSLog(@"HEADING OTHER");
    
    plane_cursor_image.transform = CGAffineTransformRotate(plane_cursor_transform,degreesToRadian(heading_int - 90));
    
//    temp_degrees += 5;
  //  plane_cursor_image.transform = CGAffineTransformRotate(plane_cursor_transform,degreesToRadian(temp_degrees - 90));
    //if(temp_degrees > 360)
      //  temp_degrees = 0;
}



//POLYLINE
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if (![overlay isKindOfClass:[MKPolyline class]]) {
        return nil;
    }
    
    NSString *overlay_type = @"";
    for(NSString *key in overlays) {
        NSMutableArray *arr = [overlays objectForKey:key];
        if(overlay == [arr objectAtIndex:0]) {
            overlay_type = key;
            break;
        }
    }
    
    MKPolyline *route = overlay;
    MKPolylineRenderer *route_renderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
    
    if([overlay_type isEqualToString:@"position_direct"]) {
        route_renderer.lineWidth = 5.0;
        route_renderer.strokeColor = [UIColor purpleColor];
    }else if([overlay_type isEqualToString:@"direct_route"]) {
        route_renderer.lineWidth = 5.0;
        route_renderer.strokeColor = [UIColor redColor];
        route_renderer.lineDashPattern = @[@1, @10];
    }else{
        route_renderer.lineWidth = 20.0;
        route_renderer.strokeColor = [UIColor redColor];
    }
    return route_renderer;
}

-(void) gps_tap:(UIGestureRecognizer * ) gesture {
//    NSLog(@"gesture image name: %@",gesture.view.image.imageNamed);
    [myCommon doAlert:[NSString stringWithFormat:@"GPS Signal: %@",gesture.view.restorationIdentifier]];
}
-(void) gps_update:(NSTimer *) timer {
    if(IS_DEBUG) NSLog(@"GPS lat: %f long: %f h_acc: %f v_acc: %f",singletonObject->gps.coordinate.latitude,singletonObject->gps.coordinate.longitude,singletonObject->gps.horizontalAccuracy,singletonObject->gps.verticalAccuracy);
    
    if(singletonObject->gps.horizontalAccuracy < 0 || singletonObject->gps.verticalAccuracy < 0) {
        _image_gps.image = [UIImage imageNamed:@"gps-signal_none.png"];
        _image_gps.restorationIdentifier = @"None (consider disabling airplane mode and hold device near window for a minute.)";
    }else if(singletonObject->gps.horizontalAccuracy < 3) {
        _image_gps.image = [UIImage imageNamed:@"gps-signal_excellent.png"];
        _image_gps.restorationIdentifier = @"Excellent";
    }else if(singletonObject->gps.horizontalAccuracy < 10) {
        _image_gps.image = [UIImage imageNamed:@"gps-signal_good.png"];
        _image_gps.restorationIdentifier = @"Good";
    }else{
        _image_gps.image = [UIImage imageNamed:@"gps-signal_poor.png"];
        _image_gps.restorationIdentifier = @"Poor";
    }
    
    
    if([mySession objectForKey:@"sync_lock"])
        _label_loading2.hidden = false;
    else if(_label_loading2.hidden == false) {
        _label_loading2.hidden = true;
        [self local_refresh:refresh_timer];
    }
    
    if(singletonObject->gps.speed > 0)
        [self set_altitude_speed:[NSString stringWithFormat:@"%.0f",(singletonObject->gps.altitude*METERS_TO_FEET)/100] speed:[NSString stringWithFormat:@"%.0f",singletonObject->gps.speed*1.94384449] jitter:false];
    
    //new remove
    /*
    if([callsign_type isEqualToString:@""] || [callsign_type isEqualToString:@"airport"]) {
        NSArray *nearest = [myCommon nearest_airport:singletonObject->gps.coordinate.latitude my_long:singletonObject->gps.coordinate.longitude];
    
        destination_id = [nearest objectAtIndex:0];
        _text_destination.text = [nearest objectAtIndex:1];
    
        NSLog(@"GPS LAT/LONG: %f/%f",singletonObject->gps.coordinate.latitude,singletonObject->gps.coordinate.longitude);

        if(![destination_id isEqualToString:@""]) {
            [self textFieldShouldEndEditing:_text_destination];
            [self flight_detail_swipe_left:nil];
        }
    }
     */
}





-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    [self.view endEditing:YES];

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
        if(singletonObject->portrait == true) {
            set_portrait = true;
         //   NSLog(@"PAGE.M SET IPHONE ORIENTATION PORTRAIT");
            [myCommon change_frame:_label_name x:-250 y:0];
            [myCommon change_frame:_button_facebook x:-250 y:0];
            [myCommon change_frame:_button_twitter x:-250 y:0];
            [myCommon change_frame:_button_alarm x:-250 y:0];
            [myCommon change_frame:_button_settings x:-250 y:0];
            
            //middle bar
            [myCommon change_frame_size:_view_flight_detail width:-248 height:58];
            [myCommon change_frame_size:_view_handle width:0 height:58];

            [myCommon change_frame:_button_new_report x:-320 y:40];

            [myCommon change_frame_size:_view_middle width:0 height:40];
            [myCommon change_frame_size:_view_airport width:-78 height:40];


            [myCommon change_frame_size:_label_selection_description width:90 height:0];
            [myCommon change_frame:_label_selection_description x:75 y:-25];

            
            [myCommon change_frame:_view_handle x:-248 y:0];

            [myCommon change_frame:_selection_commercial x:-125 y:30];
            [myCommon change_frame:_label_commercial x:-125 y:30];
            [myCommon change_frame:_text_airline x:-125 y:30];
            [myCommon change_frame:_text_flight_number x:-336 y:66];

            [myCommon change_frame:_selection_tail x:-125 y:60];
            [myCommon change_frame:_label_private x:-125 y:60];
            [myCommon change_frame:_text_tail x:-125 y:60];

            [myCommon change_frame:_selection_airport x:-125 y:55];
            [myCommon change_frame:_label_airport x:-125 y:55];
            [myCommon change_frame:_text_destination x:-125 y:55];


            [myCommon change_frame:_label_altitude x:-30 y:0];
            [myCommon change_frame:_label_desc_altitude x:-30 y:0];

            
            [myCommon change_frame:_button_ok x:-128 y:60];
            //END MIDDLE BAR
            
            _label_name.hidden = true;
            
            
            
            
            [myCommon change_frame:_view_map x:0 y:40];

            //grow height
            [myCommon change_frame_size:_view_map width:-248 height:208];
            [myCommon change_frame_size:_map width:-248 height:208];
            [myCommon change_frame:_image_chevron_right x:0 y:100];

            [myCommon change_frame_size:_view_right_bar width:0 height:208];
            [myCommon change_frame_size:_view_right_left_bar width:0 height:208];
            [myCommon change_frame_size:_table_right width:0 height:208];
            
        }else if(set_portrait == true) {
            set_portrait = false;
           // NSLog(@"PAGE.M SET IPHONE ORIENTATION LANDSCAPE");
            
            
            
            
            [myCommon change_frame:_label_name x:250 y:0];
            [myCommon change_frame:_button_facebook x:250 y:0];
            [myCommon change_frame:_button_twitter x:250 y:0];
            [myCommon change_frame:_button_alarm x:250 y:0];
            [myCommon change_frame:_button_settings x:250 y:0];
            
            //middle bar
            [myCommon change_frame_size:_view_flight_detail width:248 height:-58];
            [myCommon change_frame_size:_view_handle width:0 height:-58];
            
            [myCommon change_frame:_button_new_report x:320 y:-40];
            
            [myCommon change_frame_size:_view_middle width:0 height:-40];
            [myCommon change_frame_size:_view_airport width:78 height:-40];
            
            
            [myCommon change_frame_size:_label_selection_description width:-90 height:0];
            [myCommon change_frame:_label_selection_description x:-75 y:25];
            
            
            [myCommon change_frame:_view_handle x:248 y:0];
            
            [myCommon change_frame:_selection_commercial x:125 y:-30];
            [myCommon change_frame:_label_commercial x:125 y:-30];
            [myCommon change_frame:_text_airline x:125 y:-30];
            [myCommon change_frame:_text_flight_number x:336 y:-66];
            
            [myCommon change_frame:_selection_tail x:125 y:-60];
            [myCommon change_frame:_label_private x:125 y:-60];
            [myCommon change_frame:_text_tail x:125 y:-60];
            
            [myCommon change_frame:_selection_airport x:125 y:-55];
            [myCommon change_frame:_label_airport x:125 y:-55];
            [myCommon change_frame:_text_destination x:125 y:-55];
            
            
            [myCommon change_frame:_label_altitude x:30 y:0];
            [myCommon change_frame:_label_desc_altitude x:30 y:0];
            
            
            [myCommon change_frame:_button_ok x:128 y:-60];
            //END MIDDLE BAR
            
            _label_name.hidden = false;
            
            
            
            
            [myCommon change_frame:_view_map x:0 y:-40];
            
            //grow height
            [myCommon change_frame_size:_view_map width:248 height:-208];
            [myCommon change_frame_size:_map width:248 height:-208];
            [myCommon change_frame:_image_chevron_right x:0 y:-100];
            
            [myCommon change_frame_size:_view_right_bar width:0 height:-208];
            [myCommon change_frame_size:_view_right_left_bar width:0 height:-208];
            [myCommon change_frame_size:_table_right width:0 height:-208];
        }
        
        frame_text_airline = _text_airline.frame;
        frame_text_airport = _text_destination.frame;
        
        CGSize screen = self.view.bounds.size;
        NSLog(@"PAGE.M pirep frame height: %f %f",screen.height,screen.height-40);
        pirep.view.frame = CGRectMake((screen.width/2)-310/2, 40, 310, screen.height - 40);
        settings.view.frame = CGRectMake((screen.width/2)-310/2, 40, 310, screen.height - 40);
        pirep_alert.view.frame = CGRectMake((screen.width/2)-310/2, 40, 310, screen.height - 40);
        
        //setup iPHone stuff for image rotation...
        big_image_view_bg.frame = CGRectMake(0, 0, screen.width, screen.height);
        float margin = 20;
        float start_y = margin;
        float h = big_image_view_bg.frame.size.height - margin/2 - start_y;
        big_image_view.frame = CGRectMake(margin/2, start_y, big_image_view_bg.frame.size.width-margin, h);
        
        big_image_image.frame = CGRectMake(0, 33, big_image_view_bg.frame.size.width-margin, big_image_view_bg.frame.size.height-margin);
        button_save_photo.frame = CGRectMake(big_image_view.frame.size.width-95, 5, 95, 25);
        
    }else{
        //NSLog(@"SET IPAD STUFF HERE");
        //IPAD IPAD IPAD IPAD IPAD IPAD IPAD IPAD IPAD NEXT IPAD WARNING WARNING
        if(singletonObject->portrait == true) {
            set_portrait = true;
            if(IS_DEBUG) NSLog(@"SET ORIENTATION PORTRAIT");
        
            //header
            [myCommon change_frame:_label_name x:-250 y:0];
            [myCommon change_frame:_button_facebook x:-250 y:0];
            [myCommon change_frame:_button_twitter x:-250 y:0];
            [myCommon change_frame:_button_alarm x:-250 y:0];
            [myCommon change_frame:_button_settings x:-250 y:0];

        //middle bar
            [myCommon change_frame_size:_view_middle width:0 height:65];
            [myCommon change_frame_size:_view_flight_detail width:-256 height:65];
            [myCommon change_frame_size:_view_handle width:0 height:65];
            [myCommon change_frame_size:_view_airport width:-256 height:65];

        //re-position elements
        //changed

            [myCommon change_frame:_image_chevron_middle x:0 y:30];
            [myCommon change_frame:_view_handle x:-256 y:0];
            [myCommon change_frame:_label_airport x:-580 y:65];
            [myCommon change_frame:_text_destination x:-588 y:65];
            [myCommon change_frame:_selection_airport x:-578 y:65];
            [myCommon change_frame:_button_ok x:-400 y:74];

            [myCommon change_frame:_button_new_report x:-553 y:65];

            [myCommon change_frame:_label_flight_type x:-40 y:0];
            [myCommon change_frame:_label_callsign x:-40 y:0];
            [myCommon change_frame:_label_status x:-40 y:0];
            [myCommon change_frame:_label_text_departure x:-40 y:0];
            [myCommon change_frame:_label_text_arrival x:-40 y:0];
            [myCommon change_frame:_label_departure x:-40 y:0];
            [myCommon change_frame:_label_arrival x:-40 y:0];
            
        
            [myCommon change_frame:_label_equipment x:-27 y:0];
            [myCommon change_frame:_label_flight_equipment x:-27 y:0];

            [myCommon change_frame:_label_desc_altitude x:-18 y:0];
            [myCommon change_frame:_label_altitude x:-18 y:0];
            [myCommon change_frame:_view_alt_bug x:-18 y:0];
            [myCommon change_frame:_image_alt_bar x:-18 y:0];

            [myCommon change_frame:_label_status_airport x:-223 y:0];
            [myCommon change_frame:_label_airport_callsign x:-223 y:0];

        
        //end middle bar
        
 
        //map and below middle
      //  [myCommon change_frame:_view_right_bar x:0 y:0];
            [myCommon change_frame:_view_map x:0 y:65];
        
            //grow height
            [myCommon change_frame_size:_view_map width:-256 height:191];
            [myCommon change_frame_size:_map width:-256 height:191];
            [myCommon change_frame_size:_view_right_bar width:0 height:191];
            [myCommon change_frame_size:_view_right_left_bar width:0 height:191];
            [myCommon change_frame_size:_table_right width:0 height:191];

            _image_header.image = [UIImage imageNamed:@"header_bar_portrait.png"];
            _image_header.frame = CGRectMake(0, 0, 768 ,65);

        
            [myCommon change_frame:settings.view x:-256 y:0];
            [myCommon change_frame:pirep_alert.view x:-256 y:0];
            [myCommon change_frame:pirep.view x:-93 y:0];
            [myCommon change_frame_size:pirep.view width:-70 height:0];
        
        
            [myCommon change_frame_size:big_image_view_bg width:-256 height:256];
            [myCommon change_frame_size:big_image_view width:-256 height:256];
            [myCommon change_frame_size:big_image_image width:-256 height:256];
        }else if(set_portrait == true) {
            set_portrait = false;
            if(IS_DEBUG) NSLog(@"SET ORIENTATION LANDSCAPE");
        
        
            [myCommon change_frame:_label_name x:250 y:0];
            [myCommon change_frame:_button_facebook x:250 y:0];
            [myCommon change_frame:_button_twitter x:250 y:0];
            [myCommon change_frame:_button_alarm x:250 y:0];
            [myCommon change_frame:_button_settings x:250 y:0];
        
        
            //middle bar
            [myCommon change_frame_size:_view_middle width:0 height:-65];
            [myCommon change_frame_size:_view_flight_detail width:256 height:-65];
            [myCommon change_frame_size:_view_handle width:0 height:-65];
            [myCommon change_frame_size:_view_airport width:256 height:-65];
        
            //re-position elements
            [myCommon change_frame:_image_chevron_middle x:0 y:-30];
            [myCommon change_frame:_view_handle x:256 y:0];
            [myCommon change_frame:_label_airport x:580 y:-65];
            [myCommon change_frame:_text_destination x:588 y:-65];
            [myCommon change_frame:_selection_airport x:578 y:-65];
            [myCommon change_frame:_button_ok x:400 y:-74];
        
            [myCommon change_frame:_button_new_report x:553 y:-65];
        
            [myCommon change_frame:_label_flight_type x:40 y:0];
            [myCommon change_frame:_label_callsign x:40 y:0];
            [myCommon change_frame:_label_status x:40 y:0];
            [myCommon change_frame:_label_text_departure x:40 y:0];
            [myCommon change_frame:_label_text_arrival x:40 y:0];
            [myCommon change_frame:_label_departure x:40 y:0];
            [myCommon change_frame:_label_arrival x:40 y:0];
        
        
            [myCommon change_frame:_label_equipment x:27 y:0];
            [myCommon change_frame:_label_flight_equipment x:27 y:0];
        
            [myCommon change_frame:_label_desc_altitude x:18 y:0];
            [myCommon change_frame:_label_altitude x:18 y:0];
            [myCommon change_frame:_view_alt_bug x:18 y:0];
            [myCommon change_frame:_image_alt_bar x:18 y:0];
        
            [myCommon change_frame:_label_status_airport x:223 y:0];
            [myCommon change_frame:_label_airport_callsign x:223 y:0];
            //end middle bar
        
            [myCommon change_frame:_view_map x:0 y:-65];
        
            //grow height
            [myCommon change_frame_size:_view_map width:256 height:-191];
            [myCommon change_frame_size:_map width:256 height:-191];
            [myCommon change_frame_size:_view_right_bar width:0 height:-191];
            [myCommon change_frame_size:_view_right_left_bar width:0 height:-191];
            [myCommon change_frame_size:_table_right width:0 height:-191];
        
            _image_header.image = [UIImage imageNamed:@"header_bar.png"];
            _image_header.frame = CGRectMake(0, 0, 1024 ,65);

            [myCommon change_frame:pirep_alert.view x:256 y:0];
            [myCommon change_frame:settings.view x:256 y:0];
            [myCommon change_frame:pirep.view x:93 y:0];
            [myCommon change_frame_size:pirep.view width:70 height:0];

            [myCommon change_frame_size:big_image_view_bg width:256 height:-256];
            [myCommon change_frame_size:big_image_view width:256 height:-256];
            [myCommon change_frame_size:big_image_image width:256 height:-256];
        }
    }
    /*
     pirep.view.frame = CGRectMake(97, 42, 830, 675);
     if(singletonObject->portrait ) {
     pirep.view.frame = CGRectMake(4, 42, 760, 675);
     }
*/
    //NSLog(@"SWIPE LEFT HERE POS2 position: %@",flight_detail_swipe_position);
    if([flight_detail_swipe_position isEqualToString:@"left"])
       [self flight_detail_swipe_left:nil];
    else if([flight_detail_swipe_position isEqualToString:@"right"])
        [self flight_detail_swipe_right:nil];

    //[self tooltip_big_close_button:self];
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


- (IBAction)alert_push:(id)sender {
    
    pirep_alert = [self.storyboard instantiateViewControllerWithIdentifier:@"PirepAlert"];
    [self addChildViewController:pirep_alert];
    
    
    if(singletonObject->is_iphone) {
        CGSize screen = self.view.bounds.size;
        
        pirep_alert.view.frame = CGRectMake((screen.width/2)-155, 40, 500, 400);
    }else{
        if(!singletonObject->portrait)
            pirep_alert.view.frame = CGRectMake(505, 40, 500, 400);
        else
            pirep_alert.view.frame = CGRectMake(250, 40, 500, 400);
    }
                                   
    [self.view addSubview:pirep_alert.view];
    [pirep_alert didMoveToParentViewController:self];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
