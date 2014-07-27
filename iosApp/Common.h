//
//  Common.h
//  Aerovie
//
//  Created by Bryan Heitman on 5/3/13.
//  Copyright (c) 2013 Bryan Heitman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mySingleton.h"
//import "/usr/include/sqlite3.h"

//TURN ON DEBUGGING TO RECEIVE VARIOUS NSLOG() MESSAGES TO CONSOLE
#define IS_DEBUG 0

#define MASTER_VERSION 1.21

#define METERS_TO_FEET 3.2808399

#define degreesToRadian(x) (M_PI * (x) / 180.0)

#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

NSMutableDictionary *mySession;
sqlite3 *my_db;

@interface Common : NSObject {
    NSMutableDictionary *myConnections;
    
    //BOOL sync_lock;
    
    UITextField *query_text;
    UIView *query_view;
    UITextView *query_result;
    UIView *parent_query_view;
    
    
}
-(NSArray *) nearest_airport:(float) my_lat my_long:(float) my_long;

- (NSInteger) reverse_number:(NSInteger) old_number;

-(void) apiRequest:(NSMutableDictionary*)myRequest;
-(NSMutableDictionary *) query:(NSString *)my_query;
-(void) doAlert:(NSString*)msg;
- (void) dump_table:(NSString *) table_name;

-(NSString *) fix_date:(int) number;

-(void) writeSession;
-(void) readSession;
-(void) db_sync;
-(NSString *) clean_time:(NSString *) hour min:(NSString *) min;
- (NSString *) month_to_text:(NSInteger) current_month;
-(NSString *) seconds_to_flight_time:(NSString *) seconds_str;

- (void) new_graph:(UIWebView *) web_view template:(NSString *) template categories:(NSMutableArray *) categories series:(NSMutableDictionary *) series width:(NSInteger) width height:(NSInteger) height options:(NSMutableDictionary *) options;
-(BOOL) is_debrief_remote:(NSInteger) debrief_id;

-(void) open_query_debug:(UIView *) parent_view;

-(NSString *) add_comma:(NSInteger) number;
-(void) clearSesssion;
-(NSMutableArray *) get_pirep:(NSString *) pirep_id local:(BOOL) is_local;

-(void) add_center_constraint:(UIView *) v;
-(void) change_frame:(UIView *) obj x:(float) x_change y:(float) y_change;
-(void) change_frame_size:(UIView *) obj width:(float) width_change height:(float) height_change;
-(NSString *) convert_altitude_flight_level:(float) alt;


@end
