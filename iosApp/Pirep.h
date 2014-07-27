//
//  Pirep.h
//  Aerovie-Lite
//
//  Created by Bryan Heitman on 1/22/14.
//  Copyright (c) 2014 DevStake, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import <MapKit/MapKit.h>
#import  <MobileCoreServices/MobileCoreServices.h>
#import "RangeSlider.h"


@class RangeSlider;


@interface Pirep : UIViewController {
    Common *myCommon;
    mySingleton *singletonObject;
    
    CLLocationCoordinate2D manual_location;
    MKPointAnnotation *point_annotation;
    
    NSString *ride;
    NSString *wx;
    NSString *icing;
    
    NSInteger visibility;
    
    
//    BOOL clean;
//    BOOL old;
//    BOOL noisy;
//    BOOL smelly;
    
    BOOL twitter;
    BOOL facebook;
    
    long manual_altitude;
    
    NSString *image_encode;
    
    BOOL set_portrait;
    
    RangeSlider *slider1;
    RangeSlider *slider2;
    RangeSlider *slider3;
    
    UIAlertView *alert_photo;
    UIAlertView *alert_disclaimer;
    
    
    float knob_start;
    
    NSString *ride_type;
}
@property (weak, nonatomic) IBOutlet UIScrollView *main_scroll;

@property (weak, nonatomic) IBOutlet UITextField *text_callsign;

@property (weak, nonatomic) IBOutlet UILabel *location_altitude;





@property (weak, nonatomic) IBOutlet UIButton *button_submit;

@property (weak, nonatomic) IBOutlet UIView *main_view;
@property (weak, nonatomic) IBOutlet UIView *view_left;
@property (weak, nonatomic) IBOutlet UIView *view_middle;
@property (weak, nonatomic) IBOutlet UIView *view_right;
@property (weak, nonatomic) IBOutlet UILabel *label_text_weather;
@property (weak, nonatomic) IBOutlet UILabel *label_text_ride;
@property (weak, nonatomic) IBOutlet UILabel *label_text_aircraft;
@property (weak, nonatomic) IBOutlet UIButton *button_add_photo;


//manual stuff

@property (weak, nonatomic) IBOutlet UIView *view_gray_manual;


@property (weak, nonatomic) IBOutlet UISlider *slider_altitude;
@property (weak, nonatomic) IBOutlet UILabel *label_altitude;
@property (weak, nonatomic) IBOutlet MKMapView *map_view;
@property (weak, nonatomic) IBOutlet UIView *view_map;

//manual loc end


@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UISlider *slider_time;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *text_comment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment_ride;
@property (weak, nonatomic) IBOutlet UIButton *button_facebook;
@property (weak, nonatomic) IBOutlet UIButton *button_twitter;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment_location;



//ride
@property (weak, nonatomic) IBOutlet UIButton *button_ride_negative;
@property (weak, nonatomic) IBOutlet UIButton *button_ride_light;
@property (weak, nonatomic) IBOutlet UIButton *button_ride_light_moderate;
@property (weak, nonatomic) IBOutlet UIButton *button_ride_moderate;
@property (weak, nonatomic) IBOutlet UIButton *button_ride_moderate_severe;
@property (weak, nonatomic) IBOutlet UIButton *button_ride_severe;
@property (weak, nonatomic) IBOutlet UIButton *button_ride_extreme;
@property (weak, nonatomic) IBOutlet UITextView *text_ride_description;
@property (weak, nonatomic) IBOutlet UILabel *label_ride;
//end ride


//wx
@property (weak, nonatomic) IBOutlet UIButton *button_wx_neg;

@property (weak, nonatomic) IBOutlet UIButton *button_wx_rainy;
@property (weak, nonatomic) IBOutlet UIButton *button_wx_snow;
@property (weak, nonatomic) IBOutlet UIButton *button_wx_hail;
@property (weak, nonatomic) IBOutlet UIButton *button_wx_lightning;
@property (weak, nonatomic) IBOutlet UIButton *button_wx_sleet;
@property (weak, nonatomic) IBOutlet UITextView *text_wx_description;
@property (weak, nonatomic) IBOutlet UILabel *label_wx;
//wx end



//icing
@property (weak, nonatomic) IBOutlet UIButton *button_icing_none;
@property (weak, nonatomic) IBOutlet UIButton *button_icing_light;
@property (weak, nonatomic) IBOutlet UIButton *button_icing_trace;
@property (weak, nonatomic) IBOutlet UIButton *button_icing_moderate;
@property (weak, nonatomic) IBOutlet UIButton *button_icing_severe;
@property (weak, nonatomic) IBOutlet UILabel *label_icing;
@property (weak, nonatomic) IBOutlet UITextView *text_aircraft_description;
//end icing



@property (weak, nonatomic) IBOutlet UITextField *text_callsign_type;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment_ice_type;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment_cloud;

@property (weak, nonatomic) IBOutlet UISlider *slider_visibility;
@property (weak, nonatomic) IBOutlet UITextField *oat;
@property (weak, nonatomic) IBOutlet UITextField *wind_degrees;
@property (weak, nonatomic) IBOutlet UITextField *wind_speed;
@property (weak, nonatomic) IBOutlet UILabel *label_visibility;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment_ride_type;



@end
