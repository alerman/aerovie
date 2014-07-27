//
//  mySingleton.m
//  Aerovie
//
//  Created by Bryan Heitman on 10/7/13.
//  Copyright (c) 2013 Bryan Heitman. All rights reserved.
//

#import "mySingleton.h"

@implementation mySingleton

static mySingleton *sharedInstance = nil;

+ (mySingleton *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}


// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    
    if (self) {
        // Work your initialising magic here as you normally would
    }
    my_db = nil;
    
    myCommon = [[Common alloc] init];
    
    
    is_pirep_monitoring = false;
    monitor_expire_time = 0;
    
    gps = [[CLLocation alloc] init];
    gps_is_paused = 0;
    gps_locMgr = [[CLLocationManager alloc] init]; // Create new instance of locMgr
    gps_locMgr.delegate = self; // Set the delegate as self.
    gps_locMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    gps_locMgr.activityType = CLActivityTypeOtherNavigation;
//    gps_locMgr.pausesLocationUpdatesAutomatically = false;
    gps_coord_points = 0;
    
    NSString *device_type = [UIDevice currentDevice].model;
//    is_iphone_4 = 0;
    if([device_type rangeOfString:@"iPhone"].location == NSNotFound)
        is_iphone = 0;
    else{
        is_iphone = 1;
        
//        CGSize screen_size = [[UIScreen mainScreen] bounds].size;
//        NSLog(@"MY SINGLETON SIZE: %f",screen_size.height);
//        if(screen_size.height < 568)
//            is_iphone_4 = 1;
    }
    return self;
}
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        //YES
        [self gps_resume_tracking:true];
    } else {
        //NO
        [myCommon query:@"UPDATE flight SET status='incomplete',date_end=strftime('%s','now') WHERE status IN('logging','paused')"];
    }
}
- (void) gps_resume_tracking:(BOOL) really_resume {
    NSLog(@"GPS RESUME TRACKING");
    
    [myCommon dump_table:@"flight"];
    
    NSMutableDictionary *my_query = [myCommon query:[NSString stringWithFormat:@"SELECT flight_id,date_start,flight_seconds FROM flight WHERE status IN('logging','paused') ORDER BY flight_id DESC"]];
    NSMutableArray *my_result = [my_query objectForKey:@"result"];
    
    if([my_result count] == 0)
        return;
    
    NSMutableArray *my_row = [my_result objectAtIndex:0];
    
    if(really_resume == false) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Resume flight tracking?"
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"Stop"
                              otherButtonTitles:@"Resume", nil];
        [alert show];
        return;
    }
    active_flight_id = [my_row objectAtIndex:0];
    if(IS_DEBUG) NSLog(@"active flight id: %@",active_flight_id);
    [myCommon query:[NSString stringWithFormat:@"UPDATE flight SET status='incomplete',date_end=strftime('%%s','now') WHERE status IN('logging','paused') and flight_id != '%@'",active_flight_id]];
    
    //calculate gps_previous_seconds
    /*    NSMutableDictionary *my_query2 = [myCommon query:[NSString stringWithFormat:@"SELECT strftime('%%s',timestamp) FROM flight_data WHERE flight_id = '%@' ORDER BY flight_data_id DESC LIMIT 1",active_flight_id]];
     
     NSMutableArray *my_result2 = [my_query2 objectForKey:@"result"];
     NSMutableArray *my_row2 = [my_result2 objectAtIndex:0];
     long long_end = [[my_row2 objectAtIndex:0] longLongValue];
     long long_start = [[my_row objectAtIndex:1] longLongValue];
     */
    gps_previous_seconds = [[my_row objectAtIndex:2] longLongValue];
    
    if(IS_DEBUG) NSLog(@"gps_previous_seconds: %ld",gps_previous_seconds);
    
    active_date_start = [NSDate date];
 //   [last_header setup_gps_header];
    
   // [gps_locMgr startUpdatingLocation];

    //gps_date_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(set_flight_time:) userInfo:nil repeats:YES];
    //[[NSRunLoop currentRunLoop] addTimer:gps_date_timer forMode:NSDefaultRunLoopMode];
}

- (void) gps_stop {
    if(IS_DEBUG) NSLog(@"Stopping flight");
    gps_is_paused = 0;
    [gps_locMgr stopUpdatingLocation];
    NSTimeInterval now_seconds = (-[active_date_start timeIntervalSinceNow]) + gps_previous_seconds;
    gps_previous_seconds = now_seconds;
    long seconds = lroundf(now_seconds);
    
    [myCommon query:[NSString stringWithFormat:@"UPDATE flight SET status = 'complete',flight_seconds = '%ld',date_end=strftime('%%s','now') WHERE flight_id = '%@'",seconds,active_flight_id]];
    
    active_flight_id = nil;
    active_date_start = [NSDate date];
    gps_previous_seconds = 0;
//    [self set_flight_time:gps_date_timer];
    [gps_date_timer invalidate];
    
   // [last_header setup_gps_header];
    [myCommon doAlert:@"Flight Saved"];
}
- (void) gps_pause {
    /*
    if(gps_is_paused == 1) {
        NSLog(@"Resuming.....");
        gps_is_paused = 0;
        [myCommon query:[NSString stringWithFormat:@"UPDATE flight SET status = 'logging' WHERE flight_id = '%@'",active_flight_id]];
        [gps_locMgr startUpdatingLocation];
        
        //reset start time.....
        active_date_start = [NSDate date];
        
        gps_date_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(set_flight_time:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:gps_date_timer forMode:NSDefaultRunLoopMode];
        
    }else{
        NSLog(@"Pausing.....");
        [gps_date_timer invalidate];
        gps_is_paused = 1;
        NSTimeInterval now_seconds = (-[active_date_start timeIntervalSinceNow]) + gps_previous_seconds;
        gps_previous_seconds = now_seconds;
        long seconds = lroundf(now_seconds);
        
        [gps_locMgr stopUpdatingLocation];
        [myCommon query:[NSString stringWithFormat:@"UPDATE flight SET status = 'paused',flight_seconds = '%ld' WHERE flight_id = '%@'",seconds,active_flight_id]];
    }
     */
}

- (void) start_gps_tracking {
    active_date_start = [NSDate date];
    
    
    [gps_locMgr startUpdatingLocation];
}
- (void) stop_gps_tracking {
    [gps_locMgr stopUpdatingLocation];
    
    [gps_date_timer invalidate];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //  CLLocationSpeed speed = newLocation.speed;
    //newLocation.speed DOUBLE
    //newLocation.course DOUBLE
    //newLocation.coordinate.latitude //double
    //newLocation.coordinate.longitude //double
    //newLocation.altitude //DOUBLE
    //newLocation.horizontalAccuracy //double
    //newLocation.verticalAccuracy //double
    //newLocation.timestamp //NSDATE
    /*
     _text_gps_alt.text = [NSString stringWithFormat:@"%f",newLocation.altitude];
     _text_gps_lat.text = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
     _text_gps_long.text = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
     _text_gps_heading.text = [NSString stringWithFormat:@"%f",newLocation.course];
     _text_gps_speed.text = [NSString stringWithFormat:@"%f",newLocation.speed];
     _text_gps_horizontal.text = [NSString stringWithFormat:@"%f",newLocation.horizontalAccuracy];
     _text_gps_vertical.text = [NSString stringWithFormat:@"%f",newLocation.verticalAccuracy];
     */
    /*
    if(active_flight_id != nil) {
        NSLog(@"Writing to flight_data for active_flight_id: %@",active_flight_id);
        [myCommon query:[NSString stringWithFormat:@"INSERT INTO flight_data (flight_id,speed,course,latitude,longitude,altitude,horizontal_accuracy,vertical_accuracy,gps_timestamp) values ('%@','%f','%f','%f','%f','%f','%f','%f','%@')",active_flight_id,newLocation.speed,newLocation.course,newLocation.coordinate.latitude,newLocation.coordinate.longitude,newLocation.altitude,newLocation.horizontalAccuracy,newLocation.verticalAccuracy,[NSString stringWithFormat:@"%@",newLocation.timestamp]]];
    }
    
    last_header.label_gps_debug.text = [NSString stringWithFormat:@"alt: %f lat: %f long: %f hdg: %f spd: %f",newLocation.altitude,newLocation.coordinate.latitude,newLocation.coordinate.longitude,newLocation.course,newLocation.speed];
    */

//    NSLog(@"NEW_GPS %@",[NSString stringWithFormat:@"alt: %f lat: %f long: %f hdg: %f spd: %f",newLocation.altitude,newLocation.coordinate.latitude,newLocation.coordinate.longitude,newLocation.course,newLocation.speed]);
    
    gps = newLocation;
        
    //    NSLog(@"gps data %i %@",coord_points,newLocation.description);
    
    //dynamic map stuff
    /*
     gps_coords[gps_coord_points] = newLocation.coordinate;
     gps_coord_points++;
     
     if(gps_coord_points > 10) {
     MKPolyline *route = [MKPolyline polylineWithCoordinates:coords count: coord_points];
     [_flight_map addOverlay:route];
     
     for(NSInteger x = 0;x<=30;x++)
     gps_coords[x] = newLocation.coordinate;
     
     
     gps_coord_points = 1;
     }
     */
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"CL error %@",error);
    
}
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    if(IS_DEBUG) NSLog(@"CL didPauseLocationUpdates");
}
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    if(IS_DEBUG) NSLog(@"CL didResumeLocationUpdates");
}
/*
- (void)set_flight_time:(NSTimer *)timer {
    //seconds
    NSTimeInterval now_seconds = (-[active_date_start timeIntervalSinceNow]) + gps_previous_seconds;
    long seconds = lroundf(now_seconds);
    int hour = seconds / 3600;
    int min = (seconds % 3600) / 60;
    int sec = seconds % 60;
    
    NSString *fix_hour = [myCommon fix_date:hour];
    NSString *fix_min = [myCommon fix_date:min];
    NSString *fix_sec = [myCommon fix_date:sec];
    
 //   last_header.label_time.text = [NSString stringWithFormat:@"%@:%@:%@",fix_hour,fix_min,fix_sec];
    
    [myCommon query:[NSString stringWithFormat:@"UPDATE flight SET flight_seconds = '%ld' WHERE flight_id = '%@'",seconds,active_flight_id]];
}*/


-(void) add_gray:(UIView *) my_view {
    if(IS_DEBUG) NSLog(@"ADD GRAY NOW");
    gray_view = [[UIView alloc] init];
    float width  = [UIScreen mainScreen].bounds.size.width;
    float height  = [UIScreen mainScreen].bounds.size.height;
    
    if(portrait) {
        height  = [UIScreen mainScreen].bounds.size.width;
        width  = [UIScreen mainScreen].bounds.size.height;
    }
    
    gray_view.frame = CGRectMake(0, 0, height, width);
    gray_view.backgroundColor = [UIColor colorWithRed:69/255.0 green:80/255.0 blue:82/255.0 alpha:1];
    gray_view.alpha = 0.50;
    [my_view addSubview:gray_view];
}

-(void) adjust_gray {
    float width  = [UIScreen mainScreen].bounds.size.width;
    float height  = [UIScreen mainScreen].bounds.size.height;
    
    if(portrait) {
        height  = [UIScreen mainScreen].bounds.size.width;
        width  = [UIScreen mainScreen].bounds.size.height;
    }
    
    gray_view.frame = CGRectMake(0, 0, height, width);
}

-(void) remove_gray {
    if(IS_DEBUG) NSLog(@"REMOVE GRAY NOW");
    [gray_view removeFromSuperview];
}

- (IBAction)facebook_login:(UIButton *) this_button {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    
    NSDictionary *options = @{
                              @"ACFacebookAppIdKey" : @"253946971422441",
                              @"ACFacebookPermissionsKey" : @[@"email"],
                              @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone};
    
    [account requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted,NSError *error) {
        NSArray *my_array = [account accountsWithAccountType:accountType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted == YES && [my_array count] > 0) {
                [self facebook_complete:[my_array objectAtIndex:0] button:this_button];
            }else if(granted == YES || [error code]== ACErrorAccountNotFound) {
                [myCommon doAlert:@"No facebook accounts configured."];
                [myCommon doAlert:@"Error communicating with Facebook error 1"];
            }else{
                if(IS_DEBUG) NSLog(@"fb not granted %@",[error localizedDescription]);
                [myCommon doAlert:@"Error communicating with Facebook error 2"];

            }
        });}
     ];
}

-(void) facebook_complete:(ACAccount *) facebook button:(UIButton *) this_button {
    if(IS_DEBUG) NSLog(@"user full name %@",facebook.userFullName);
    if(IS_DEBUG) NSLog(@"fb username %@",facebook.username);
    if(IS_DEBUG) NSLog(@"fb identifier %@",facebook.identifier);
    if(IS_DEBUG) NSLog(@"fb credential %@",facebook.credential);
    
    // [self social_push:facebook.identifier user:facebook.username name:facebook.userFullName type:@"facebook"];
    
    
    NSString *name = @"";
    NSString *user = @"";
    NSString *ident = @"";
    if(facebook.userFullName)
        name = facebook.userFullName;
    if(facebook.username)
        user = facebook.username;
    if(facebook.identifier)
        ident = facebook.identifier;
    
    [self social_push:ident user:user name:name type:@"facebook"];
    
    [mySession setObject:ident forKey:@"facebook"];
    [this_button setImage:[UIImage imageNamed:@"hdr-btn_fb_on.png"] forState:UIControlStateNormal];
    [myCommon doAlert:@"Facebook is now connected for you to share reports."];
}

- (IBAction)social_push:(NSString *) ident user:(NSString *) user name:(NSString *) name type:(NSString *) type {
    if(IS_DEBUG) NSLog(@"social_push read_session: %@",[mySession objectForKey:@"read_session"]);
    
    NSMutableDictionary *requestData = [[ NSMutableDictionary alloc] init];
    [requestData setObject:@"add_social" forKey:@"request" ];
    [requestData setObject:[mySession objectForKey:@"session_id"] forKey:@"session_id" ];
    [requestData setObject:ident forKey:@"user" ];
    [requestData setObject:user forKey:@"social_user" ];
    [requestData setObject:name forKey:@"social_name" ];
    [requestData setObject:type forKey:@"social_type" ];
    [requestData setObject:@"add_social" forKey:@"connection_description" ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotification:)
                                                 name:[requestData objectForKey:@"connection_description"] object:nil];
    
    [myCommon apiRequest:requestData];
}

- (void)myNotification:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    
    if(IS_DEBUG) NSLog(@"NOTIFY !!!!!! name: %@",notification.name);
    
    if([notification.name isEqual:@"add_social"]) {

    }
}


- (IBAction)twitter_login:(UIButton * ) this_button {
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted,NSError *error) {
        NSArray *my_array = [account accountsWithAccountType:accountType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted == YES && [my_array count] > 0) {
                [self twitter_complete:[my_array objectAtIndex:0] button:this_button];
            }else if([error code]== ACErrorAccountNotFound || granted == YES) {
                if(IS_DEBUG) NSLog(@"twitter ok ok ok");
                [myCommon doAlert:@"No twitter accounts configured."];
            }else{
                if(IS_DEBUG) NSLog(@"not granted %@",[error localizedDescription]);
                [myCommon doAlert:@"Error communicating with Twitter error 2"];

            }
        });
    }
     ];
}

-(void) twitter_complete:(ACAccount *) twitter button:(UIButton *) this_button {
    if(IS_DEBUG) NSLog(@"user full name %@",twitter.userFullName);
    if(IS_DEBUG) NSLog(@"twitter username %@",twitter.username);
    if(IS_DEBUG) NSLog(@"twitter identifier %@",twitter.identifier);
    if(IS_DEBUG) NSLog(@"twitter credential %@",twitter.credential);
    
    NSString *name = @"";
    NSString *user = @"";
    NSString *ident = @"";
    if(twitter.userFullName)
        name = twitter.userFullName;
    if(twitter.username)
        user = twitter.username ;
    if(twitter.identifier)
        ident = twitter.identifier;
    
    [self social_push:ident user:user name:name type:@"twitter"];
    
    [mySession setObject:ident forKey:@"facebook"];
    [this_button setImage:[UIImage imageNamed:@"hdr-btn_twitter_on.png"] forState:UIControlStateNormal];
    [myCommon doAlert:@"Twitter is now connected for you to share reports."];

    
    /*    NSDictionary *parameters = @{@"message": @"My first iOS 6 Facebook posting "};
     
     NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
     
     SLRequest *feedRequest = [SLRequest
     requestForServiceType:SLServiceTypeFacebook
     requestMethod:SLRequestMethodPOST
     URL:feedURL
     parameters:parameters];
     
     feedRequest.account = facebookAccount;
     
     [feedRequest performRequestWithHandler:^(NSData *responseData,
     NSHTTPURLResponse *urlResponse, NSError *error)
     {
     // Handle response
     }];*/
}
-(void) twitter_post:(NSString *) my_str image:(UIImage *) image{
    
     //http://www.techotopia.com/index.php/IPhone_iOS_6_Facebook_and_Twitter_Integration_using_SLRequest
    
    NSLog(@"twitter post to account: %@ str:=%@=",[mySession objectForKey:@"twitter"],my_str);
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted,NSError *error) {
        NSArray *my_array = [account accountsWithAccountType:accountType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted == YES && [my_array count] > 0) {
                ACAccount *account = [my_array objectAtIndex:0];
                [self twitter_real_post:account str:my_str image:image];
            }else if([error code]== ACErrorAccountNotFound || granted == YES) {
                NSLog(@"twitter cannot post");
                [myCommon doAlert:@"No twitter accounts configured."];
            }else{
                NSLog(@"twitter not granted %@",[error localizedDescription]);
                [myCommon doAlert:@"Unable to share on twitter"];
            }
        });
    }
     ];

    //http://www.captechconsulting.com/blog/eric-stroh/ios-6-turorial-integrating-facebook-your-applications
}

-(void) twitter_real_post:(ACAccount *) account str:(NSString *) my_str image:(UIImage *) image {
    
    SLRequest *postRequest = nil;
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];    if(image != nil)
    if(image != nil)
        url = [NSURL URLWithString:@"https://api.twitter.com"
                  @"/1.1/statuses/update_with_media.json"];
    
    NSDictionary *content = @{@"status":my_str};
    postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                     requestMethod:SLRequestMethodPOST
                                               URL:url
                                        parameters:content];
    
    
    if(image != nil) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
        [postRequest addMultipartData:imageData
                     withName:@"media[]"
                         type:@"image/jpeg"
                     filename:@"image.jpg"];
    }
    [postRequest setAccount:account];

    
    
    [postRequest performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if(IS_DEBUG) NSLog(@"Twitter HTTP response: %li", (long)[urlResponse
                                                     statusCode]);
         if(IS_DEBUG) NSLog(@"twitter response: %@",[urlResponse allHeaderFields]);
     }];
}






-(void) facebook_post:(NSString *) my_str image:(UIImage *) image{
    
    //http://www.techotopia.com/index.php/IPhone_iOS_6_Facebook_and_Twitter_Integration_using_SLRequest
    
    if(IS_DEBUG) NSLog(@"fb post to account: %@ str:=%@=",[mySession objectForKey:@"twitter"],my_str);
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *options = @{
                              @"ACFacebookAppIdKey" : @"253946971422441",
                              @"ACFacebookPermissionsKey" : @[@"email"],
                              @"ACFacebookAudienceKey" : ACFacebookAudienceFriends}; //ACFacebookAudienceEveryone

    [account requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted,NSError *error) {
        NSArray *my_array2 = [account accountsWithAccountType:accountType];
        ACAccount *account2 = [my_array2 objectAtIndex:0];

        if(granted == YES) {//  && [my_array count] > 0) {
            NSDictionary *options = @{
                                      @"ACFacebookAppIdKey" : @"253946971422441",
                                      @"ACFacebookPermissionsKey" : @[@"publish_stream", @"publish_actions"],
                                      @"ACFacebookAudienceKey" : ACFacebookAudienceFriends};
            
            [account requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted,NSError *error) {
                    NSArray *my_array = [account accountsWithAccountType:accountType];
                    ACAccount *account = [my_array objectAtIndex:0]; //lastObject
                    if(granted == YES) {
                       // dispatch_async(dispatch_get_main_queue(), ^{
                            [self facebook_real_post:account str:my_str image:image];
                       // });
                    }else{
                        //error
                        if(IS_DEBUG) NSLog(@"error fb 2");
                        [myCommon doAlert:@"Unable to share on facebook error 2"];

                    }
                }];
        }else{
            //error
            if(IS_DEBUG) NSLog(@"error fb 1");
            [myCommon doAlert:@"Unable to share on facebook error 1"];
        }
    }];
    
    //http://www.captechconsulting.com/blog/eric-stroh/ios-6-turorial-integrating-facebook-your-applications
}

-(void) facebook_real_post:(ACAccount *) account str:(NSString *) my_str image:(UIImage *) image {
    
    SLRequest *postRequest = nil;
    
    if(IS_DEBUG) NSLog(@"really fb post: %@ name: %@ image: %@",account.identifier,account.userFullName,image);
    
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
    if(image != nil)
        url = [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
    
    NSDictionary *content = @{@"message":my_str};
    postRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                     requestMethod:SLRequestMethodPOST
                                               URL:url
                                        parameters:content];
    
    
    if(image != nil) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
        [postRequest addMultipartData:imageData
                             withName:@"source"
                                 type:@"multipart/form-data"
                             filename:@"image.jpg"];
    }
    postRequest.account = account;
//    [postRequest setAccount:account];
    
    
    
    [postRequest performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if(IS_DEBUG) NSLog(@"FB HTTP response: %li", (long)[urlResponse
                                                     statusCode]);
         if(IS_DEBUG) NSLog(@"FB response: %@",[urlResponse allHeaderFields]);
     }];
}


//start_pirep_monitor:miles hours:hours max_alt:max_alt];
-(void) start_pirep_monitor:(float) miles hours:(float) hours max_alt:(float) max_alt {
    is_pirep_monitoring = true;
    
    
    monitor_max_alt = max_alt/100;
    monitor_max_miles = miles;
    
    monitor_start_time = [[NSDate date] timeIntervalSince1970];
    monitor_expire_time = monitor_start_time + hours*60*60;
    
    [monitor_timer invalidate];
    monitor_timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(pirep_monitor_cycle:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:monitor_timer forMode:NSDefaultRunLoopMode];
    
    
    //monitor_max_last_pirep_id
    
    NSMutableDictionary *my_query = [myCommon query:[NSString stringWithFormat:@"SELECT pirep_id FROM pirep ORDER BY pirep_id DESC LIMIT 1"]];
    NSMutableArray *my_result = [my_query objectForKey:@"result"];
    monitor_max_last_pirep_id = [[[my_result objectAtIndex:0] objectAtIndex:0] floatValue];
}

-(void) pirep_monitor_cycle:(NSTimer * ) t {
    float current_time = [[NSDate date] timeIntervalSince1970];

    if(current_time > monitor_expire_time) {
        is_pirep_monitoring = false;
        [monitor_timer invalidate];
        return;
    }
    
    NSLog(@"pirep_montior_cycle() CHECK HERE lat: %f long: %f current_alt: %.0f start: %f max_miles: %f",gps.coordinate.latitude,gps.coordinate.longitude,gps.altitude*METERS_TO_FEET,monitor_start_time,monitor_max_miles);
    
    //do loop checking here
    
    
    NSMutableDictionary *my_query = [myCommon query:[NSString stringWithFormat:@"SELECT pirep_id,callsign,altitude,distance(my_lat,my_long,'%f','%f') FROM pirep WHERE deleted != 'yes' AND pirep_time >= '%f' and distance(my_lat,my_long,'%f','%f') <= %f AND pirep_id > %f AND callsign != '%@' ORDER BY pirep_id ASC LIMIT 3",gps.coordinate.latitude,gps.coordinate.longitude,monitor_start_time,gps.coordinate.latitude,gps.coordinate.longitude,monitor_max_miles,monitor_max_last_pirep_id,[mySession objectForKey:@"callsign"]]];
    NSMutableArray *my_result = [my_query objectForKey:@"result"];
    
    if([my_result count] ==  0) {
        return;
    }
    
    for(NSInteger x = 0;x<[my_result count];x++) {
        NSMutableArray *row = [my_result objectAtIndex:x];
        float pirep_id = [[row objectAtIndex:0] floatValue];
        
        if(pirep_id > monitor_max_last_pirep_id)
            monitor_max_last_pirep_id = pirep_id;
        
        NSString *callsign = [row objectAtIndex:1];
        NSString *alt = [row objectAtIndex:2];
        float distance = [[row objectAtIndex:3] floatValue];
        
        if(monitor_max_alt > 0 && [alt floatValue] > monitor_max_alt) {
            NSLog(@"MONITOR_PIREP_ALERT alt: %@ max: %f LARGER SKIPPING",alt,monitor_max_alt);
        }

        NSMutableArray *pirep_data = [myCommon get_pirep:[NSString stringWithFormat:@"%f",pirep_id] local:false];
        if([pirep_data count] == 0)
            return;

        
        NSLog(@"MONITOR_PIREP_ALERT pirep_id: %f callsign: %@ alt: %@",pirep_id,callsign,alt);
/*        NSInteger z = 0;
        for(NSString *s in pirep_data) {
            NSLog(@"pirep_data z: %ld s: %@",z,s);
            z++;
        }*/
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        localNotification.alertBody = [NSString stringWithFormat:@"PIREP %0.f miles from you, %@",distance,[pirep_data objectAtIndex:0]];
        localNotification.soundName =  UILocalNotificationDefaultSoundName;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}
-(BOOL) set_background_mode {
    NSMutableDictionary *my_query = [myCommon query:[NSString stringWithFormat:@"SELECT 1 FROM pirep WHERE sync_remote='yes'"]];
    NSMutableArray *my_result = [my_query objectForKey:@"result"];
    NSInteger items_pending = [my_result count];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = items_pending;
    
    if(is_pirep_monitoring) {
        NSLog(@"SET_BACKGROUND_MODE PIREP MONITORING");
        return true;
    }
    
    
    if(items_pending > 0) {
        NSLog(@"SET_BACKGROUND_MODE MINIMUM_INTERVAL");
        // [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        return true;
    }else{
        NSLog(@"SET_BACKGROUND_MODE NO_INTERVAL SHUTDOWN ANYTIME");
        // [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
        return false;
    }
}




@end
