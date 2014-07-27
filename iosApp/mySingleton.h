//
//  mySingleton.h
//  Aerovie
//
//  Created by Bryan Heitman on 10/7/13.
//  Copyright (c) 2013 Bryan Heitman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "/opt/local/include/sqlite3.h"
#import <Accounts/Accounts.h>


#import "Common.h"
#import "Header.h"


//SLRequest stuff
#import <Twitter/Twitter.h>

@class Common;



@interface mySingleton : NSObject {
@private
    Common *myCommon;
    UIView *gray_view;

@public
    
    //gps stuff
    NSString *active_flight_id;
    NSDate *active_date_start;
    CLLocationManager *gps_locMgr;
    CLLocationCoordinate2D gps_coords[100];
    NSInteger gps_coord_points;
    CLLocation *gps;
    NSInteger gps_is_paused;
    long gps_previous_seconds;
    
    CLLocationCoordinate2D fa_loc;
    NSString *fa_alt;
    
    NSTimer *gps_date_timer;
   // Header *last_header;
    //end gps stuff
    
   // NSInteger debrief_flight_id;
  //  NSString *debrief_remote;
    
    BOOL portrait;
    
    BOOL is_iphone;
    
    
    BOOL is_pirep_monitoring;
    float monitor_max_alt;
    float monitor_max_miles;
    float monitor_expire_time;
    float monitor_start_time;
    NSTimer *monitor_timer;
    
    float monitor_max_last_pirep_id;
    
    
}
+ (id)sharedInstance;
- (void) start_gps_tracking;
- (void) stop_gps_tracking;
- (void) gps_pause;
- (void) gps_stop;
- (void) gps_resume_tracking:(BOOL) really_resume;
-(void) add_gray:(UIView *) my_view;
-(void) remove_gray;

-(void) twitter_post:(NSString *) my_str image:(UIImage *) image;
-(void) facebook_post:(NSString *) my_str image:(UIImage *) image;


- (IBAction)twitter_login:(UIButton *) button;
- (IBAction)facebook_login:(UIButton *) button;
-(void) adjust_gray;

-(void) start_pirep_monitor:(float) miles hours:(float) hours max_alt:(float) max_alt;
-(BOOL) set_background_mode;


@end
