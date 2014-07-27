//
//  Page.h
//  Aerovie-Lite
//
//  Created by Bryan Heitman on 11/25/13.
//  Copyright (c) 2013 DevStake, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import <MapKit/MapKit.h>
//import "GeoUtil.h"

//define CHARS_LINE 35 //was 40
#define CHARS_LINE 31 //was 40 then it was 35 not it's 30

//.01 was
#define JITTER_ALT_LEVEL 4
#define JITTER_SPEED_LEVEL 2

#define JITTER_ALT_MAX .01
#define JITTER_SPEED_MAX .05


@interface Page : UIViewController {
    Common *myCommon;
    mySingleton *singletonObject;
    
    UIImageView *cursor;
    NSString *dropdown_table;
    NSString *airline_ident;
    
    NSMutableDictionary *annotations;
    
    long annotation_load_position;
    
    BOOL first_flight_open;
    
    NSString *airline_id;
    NSString *destination_id;
    
    MKPointAnnotation *annotation_flight_cursor;
    UIImageView *plane_cursor_image;
    CGAffineTransform plane_cursor_transform;

    NSMutableDictionary *overlays;
    
    
    CLLocationCoordinate2D play_loc;
    float play_speed;
    NSInteger play_direction;
    NSTimer *play_timer;
    NSDate *play_start;
    
    NSTimer *network_timer;
    
    CGAffineTransform image_gauge_speed_transform;

    
    NSInteger temp_degrees;
    
    
    MKPointAnnotation *dept_annotation;
    MKPointAnnotation *dest_annotation;
    
    CGAffineTransform chevron1_transform;
    CGAffineTransform chevron2_transform;
    
    NSString *prev_status_label;
    
    UITapGestureRecognizer *tap_right_gesture;
    
    BOOL lock_load;
    
    NSDate *date_last_refresh;
    NSTimer *refresh_timer;
    
    long jitter_speed;
    long jitter_altitude;
    long jitter_speed_new;
    long jitter_altitude_new;
    
 
    UIView *big_image_view;
    UIView *big_image_view_bg;
    
    UITextView *share_text;
    
    
    NSString *middle_selection;
    
    NSString *callsign_long;
    
    
    NSTimer *pirep_refresh_timer;
    
    BOOL set_portrait;
    
    NSString *callsign_type;
    
    UIViewController *pirep_alert;

    UIViewController *settings;
    UIViewController *pirep;
    
    
    NSString *flight_detail_swipe_position;
    
    NSTimer *timer_gps;
    
    UIImageView *big_image_image;
    
    
    BOOL right_bar_open;
    
    BOOL is_playing;
    
    
    CGRect frame_text_airline;
    CGRect frame_text_airport;
    
    
    UIButton *button_save_photo;
    
    UIAlertView *alert_disclaimer;
}

//HEADER



@property (weak, nonatomic) IBOutlet UIView *view_header;

@property (weak, nonatomic) IBOutlet UILabel *label_selection_description;

@property (weak, nonatomic) IBOutlet UIImageView *image_header;

@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UIButton *button_twitter;
@property (weak, nonatomic) IBOutlet UIButton *button_facebook;

@property (weak, nonatomic) IBOutlet UILabel *label_loading;

@property (weak, nonatomic) IBOutlet UIButton *button_logout;
@property (weak, nonatomic) IBOutlet UIButton *button_settings;
@property (weak, nonatomic) IBOutlet UIImageView *image_gps;

@property (weak, nonatomic) IBOutlet UILabel *label_loading2;


- (IBAction)button_logout:(id)sender;

//END HEADER


//MAP
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIView *view_map;

@property (weak, nonatomic) IBOutlet UIView *view_filter_time;
@property (weak, nonatomic) IBOutlet UIView *view_filter_altitude;
@property (weak, nonatomic) IBOutlet UIButton *button_filter;
@property (weak, nonatomic) IBOutlet UIView *view_tooltip;


//map-filter

@property (weak, nonatomic) IBOutlet UISlider *slider_time;
@property (weak, nonatomic) IBOutlet UISlider *slider_altitude;
@property (weak, nonatomic) IBOutlet UILabel *label_time_mins;
@property (weak, nonatomic) IBOutlet UILabel *label_altitude_feet;
@property (weak, nonatomic) IBOutlet UIButton *button_filter_altitude;
@property (weak, nonatomic) IBOutlet UIButton *button_filter_time;

//end map-filter


//END MAP



//MIDDLE BAR

@property (weak, nonatomic) IBOutlet UILabel *label_private;
@property (weak, nonatomic) IBOutlet UILabel *label_commercial;


@property (weak, nonatomic) IBOutlet UIImageView *image_alt_bar;

@property (weak, nonatomic) IBOutlet UIView *view_middle;

@property (weak, nonatomic) IBOutlet UITextView *text_no_pirep;



@property (weak, nonatomic) IBOutlet UIImageView *image_gauge_speed;
@property (weak, nonatomic) IBOutlet UILabel *label_speed_knots;
@property (weak, nonatomic) IBOutlet UILabel *label_speed_mph;
@property (weak, nonatomic) IBOutlet UITextField *text_airline;
@property (weak, nonatomic) IBOutlet UITextField *text_flight_number;
@property (weak, nonatomic) IBOutlet UITextField *text_destination;

@property (weak, nonatomic) IBOutlet UITextField *text_tail;

@property (weak, nonatomic) IBOutlet UILabel *label_altitude;

@property (weak, nonatomic) IBOutlet UITableView *table_dropdown;
@property (weak, nonatomic) IBOutlet UIView *view_dropdown;

@property (weak, nonatomic) IBOutlet UIView *view_alt_bug;

@property (weak, nonatomic) IBOutlet UILabel *label_desc_altitude;
@property (weak, nonatomic) IBOutlet UILabel *label_desc_speed;

@property (weak, nonatomic) IBOutlet UILabel *label_equipment;

@property (weak, nonatomic) IBOutlet UILabel *label_status;
@property (weak, nonatomic) IBOutlet UIView *view_flight_detail;


@property (weak, nonatomic) IBOutlet UILabel *label_departure;

@property (weak, nonatomic) IBOutlet UILabel *label_arrival;


@property (weak, nonatomic) IBOutlet UIImageView *image_chevron_middle;
@property (weak, nonatomic) IBOutlet UILabel *label_callsign;


@property (weak, nonatomic) IBOutlet UIImageView *selection_commercial;
@property (weak, nonatomic) IBOutlet UIImageView *selection_tail;
@property (weak, nonatomic) IBOutlet UIImageView *selection_airport;
@property (weak, nonatomic) IBOutlet UIButton *button_ok;

@property (weak, nonatomic) IBOutlet UIView *view_airport;

@property (weak, nonatomic) IBOutlet UILabel *label_airport_callsign;

@property (weak, nonatomic) IBOutlet UILabel *label_flight_type;


@property (weak, nonatomic) IBOutlet UIImageView *image_divider2;
@property (weak, nonatomic) IBOutlet UILabel *label_airport;

@property (weak, nonatomic) IBOutlet UIView *view_handle;

@property (weak, nonatomic) IBOutlet UIButton *button_new_report;

@property (weak, nonatomic) IBOutlet UILabel *label_status_airport;
@property (weak, nonatomic) IBOutlet UILabel *label_flight_equipment;

@property (weak, nonatomic) IBOutlet UILabel *label_text_departure;

@property (weak, nonatomic) IBOutlet UILabel *label_text_arrival;




//END MIDDLE BAR

//RIGHT LIST
@property (weak, nonatomic) IBOutlet UIView *view_right_bar;
@property (weak, nonatomic) IBOutlet UITableView *table_right;

@property (weak, nonatomic) IBOutlet UIImageView *image_chevron_right;


@property (weak, nonatomic) IBOutlet UIView *view_right_left_bar;



//END RIGHT LIST




//TOOLTIP
@property (weak, nonatomic) IBOutlet UITextView *text_tooltip_top;
//@property (weak, nonatomic) IBOutlet UILabel *label_tooltip_top;
@property (weak, nonatomic) IBOutlet UILabel *label_tooltip_mins;
@property (weak, nonatomic) IBOutlet UITextView *text_tooltip;
@property (weak, nonatomic) IBOutlet UIImageView *image_tooltip;

@property (weak, nonatomic) IBOutlet UIButton *twitter_tooltip;
@property (weak, nonatomic) IBOutlet UIButton *facebook_tooltip;

@property (weak, nonatomic) IBOutlet UIButton *button_close_tooltip;

//END TOOLTIP

@property (weak, nonatomic) IBOutlet UIButton *button_alarm;




@end
