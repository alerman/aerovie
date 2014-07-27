//
//  Common.m
//  Aerovie
//
//  Created by Bryan Heitman on 5/3/13.
//  Copyright (c) 2013 Bryan Heitman. All rights reserved.
//

#import "Common.h"

//@interface Common ()
//@end

@implementation Common

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }

- (id)init
{
    self = [super init];
    
    if(!mySession) {
        mySession = [[NSMutableDictionary alloc] init];
        my_db = nil;
    }
    
    myConnections = [[NSMutableDictionary alloc] init];
    
    return self;
}

-(sqlite3_stmt *) query_insert_prepare:(NSString *)my_query {
    sqlite3_stmt *statement;
    //NSMutableDictionary *my_result_data = [[NSMutableDictionary alloc] init];
    
    
    [self open_db];
    
    sqlite3_exec(my_db, "BEGIN TRANSACTION", 0, 0, 0);
    
    const char *my_query_utf8 = [my_query UTF8String];
    
    //bindings...
    if(sqlite3_prepare_v2(my_db, my_query_utf8, -1, &statement, NULL) == SQLITE_OK) {
/*        int z = 1;
        for(NSString *str in value_array) {
            sqlite3_bind_text(statement, z, [str UTF8String], -1, SQLITE_TRANSIENT);
            z++;
        }
        [my_result_data setObject:@"1" forKey:@"success"];
        if (sqlite3_step(statement) == SQLITE_DONE) {
            //NSLog(@"query success! %s",my_query_utf8);
        
            [my_result_data setObject:[NSString stringWithFormat:@"%lld",sqlite3_last_insert_rowid(my_db)] forKey:@"last_insert_id"];
        }else{
            [my_result_data setObject:@"0" forKey:@"success"];
            [my_result_data setObject:[NSString stringWithFormat:@"%s",sqlite3_errmsg(my_db)] forKey:@"error"];
            NSLog(@"query() %@ FAILED!!! error: %s",my_query,sqlite3_errmsg(my_db));
        }
 */
    }
    
//    sqlite3_finalize(statement);
    
    return statement;
}

-(void) query_insert_done:(sqlite3_stmt *) statement {
    if (sqlite3_finalize(statement) != SQLITE_OK)
            NSLog(@"SQL Error: %s",sqlite3_errmsg(my_db));

    if (sqlite3_exec(my_db, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
        NSLog(@"SQL Error: %s",sqlite3_errmsg(my_db));
}


-(NSMutableDictionary *) query_insert:(sqlite3_stmt *) statement value:(NSMutableArray *) value_array {
    
    NSMutableDictionary *my_result_data = [[NSMutableDictionary alloc] init];

    
    int z = 1;
    for(NSString *str in value_array) {
        sqlite3_bind_text(statement, z, [str UTF8String], -1, SQLITE_TRANSIENT);
        z++;
    }
    [my_result_data setObject:@"1" forKey:@"success"];
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
         //NSLog(@"query success! %s",my_query_utf8);
         
         [my_result_data setObject:[NSString stringWithFormat:@"%lld",sqlite3_last_insert_rowid(my_db)] forKey:@"last_insert_id"];
    }else{
         [my_result_data setObject:@"0" forKey:@"success"];
         [my_result_data setObject:[NSString stringWithFormat:@"%s",sqlite3_errmsg(my_db)] forKey:@"error"];
        NSLog(@"query_insert() FAILED!!! error: %s",sqlite3_errmsg(my_db));
    }

    if (sqlite3_reset(statement) != SQLITE_OK)
        NSLog(@"SQL_reset Error: %s",sqlite3_errmsg(my_db));
    
    return my_result_data;
}



-(NSMutableDictionary *) query:(NSString *)my_query {
    sqlite3_stmt    *statement;
    
    NSMutableDictionary *my_result_data = [[NSMutableDictionary alloc] init];
    
    //NSLog(@"Running query: %@",my_query);
    
    [self open_db];
    const char *my_query_utf8 = [my_query UTF8String];
    if(sqlite3_prepare_v2(my_db, my_query_utf8, -1, &statement, NULL) == SQLITE_OK) {
        [my_result_data setObject:@"1" forKey:@"success"];
        NSMutableArray *my_data_array = [[NSMutableArray alloc] init];
        while(sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableArray *my_row = [[NSMutableArray alloc] init];
            for(NSInteger x = 0;x<=sqlite3_column_count(statement) - 1;x++) {
                if(!sqlite3_column_text(statement,x)) {
                    [my_row addObject:@""];
                    continue;
                }
                NSString *my_data = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, x)];
                
                [my_row addObject:my_data];
            }
            [my_data_array addObject:my_row];
        }
        
        [my_result_data setObject:my_data_array forKey:@"result"];
        [my_result_data setObject:[NSString stringWithFormat:@"%lld",sqlite3_last_insert_rowid(my_db)] forKey:@"last_insert_id"];
        
        //NSLog(@"query success %@",my_query);
    }else{
        [my_result_data setObject:@"0" forKey:@"success"];
        [my_result_data setObject:[NSString stringWithFormat:@"%s",sqlite3_errmsg(my_db)] forKey:@"error"];
        NSLog(@"query() %@ FAILED!!! error: %s",my_query,sqlite3_errmsg(my_db));
    }
    
    /*    if (sqlite3_step(statement) == SQLITE_DONE) {
     NSLog(@"query() %@ SUCCESS",my_query);
     }else
     */
    sqlite3_finalize(statement);
    
    return my_result_data;
}





-(void) doAlert:(NSString*)msg {
    UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Alert"
                                                message:msg delegate:self cancelButtonTitle:@"Ok"otherButtonTitles: nil];
   [mes show];
}

- (void) open_db {
    const char *dbpath = [@"my_db.sql" UTF8String];
    
    if(my_db == nil) {
        // Build the path, and create if needed.
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* fileName = @"sql_data.sql3";
        NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
        
        // if(IS_DEBUG) NSLog(@"blah blah %@",fileAtPath);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
            [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
        }
        
        if(IS_DEBUG) NSLog(@"opening db...");
        if (sqlite3_open([fileAtPath UTF8String], &my_db) == SQLITE_OK) {
            [self sql_table];
            return;
        }else
            NSLog(@"open_db FAILED_OPEN_DB %s",sqlite3_errmsg(my_db));
    }
}


-(NSString *) fix_date:(int) number {
    NSString *my_string = [NSString stringWithFormat:@"0%d",number];
    if(number >= 10)
        my_string = [NSString stringWithFormat:@"%d",number];
    
    return my_string;
}

- (void) sql_table {
    if(IS_DEBUG) NSLog(@"creating sql tables... ");
    
    sqlite3_create_function(my_db, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);

    //[self query:@"DROP TABLE flight"];
    //[self query:@"DROP TABLE flight_data"];
    //[self query:@"DROP TABLE flight_people"];
    //[self query:@"DROP TABLE people"];
    
    //newLocation.speed DOUBLE
    //newLocation.course DOUBLE
    //newLocation.coordinate.latitude //double
    //newLocation.coordinate.longitude //double
    //newLocation.altitude //DOUBLE
    //newLocation.horizontalAccuracy //double
    //newLocation.verticalAccuracy //double
    //newLocation.timestamp //NSDATE
    
    //temp only
    /*
     [self query:@"drop table flight"];
     [self query:@"drop table flight_data"];
     [self query:@"drop table flight_user"];
     [self query:@"drop table aircraft"];
     [self query:@"drop table user"];
     [self query:@"drop table flight_leg"];
     [self query:@"drop table flight_leg_phase"];
     [self query:@"drop table flight_leg_phase_data"];
     [self query:@"drop table user"];
     [self query:@"drop table aircraft"];
     */
    
    [self query:@"CREATE TABLE IF NOT EXISTS airline (`airline_id` integer primary key autoincrement,`timestamp` not null default current_timestamp,`ident` varchar(255) not null default '',`name` varchar(255) not null default '',`city` varchar(255) not null default '',`callsign` varchar(255) not null default '',`remote_airline_id` integer not null default '0',`deleted` varchar(255) not null default 'no',`sync_remote` varchar(255) not null default 'no')"];

    [self query:@"CREATE INDEX IF NOT EXISTS 'remote_airline_id' ON airline (`remote_airline_id`)"];

    [self query:@"CREATE TABLE IF NOT EXISTS cifp_airport (`cifp_airport_id` integer primary key autoincrement,`timestamp` not null default current_timestamp,`ident` varchar(255) not null default '',`name` varchar(255) not null default '',`my_lat` varchar(255) not null default '',`my_long` varchar(255) not null default '',`remote_cifp_airport_id` integer not null default '0',`deleted` varchar(255) not null default 'no',`sync_remote` varchar(255) not null default 'no')"];
    
    [self query:@"CREATE INDEX IF NOT EXISTS 'remote_cifp_airport' ON cifp_airport (`remote_cifp_airport_id`)"];
    [self query:@"CREATE INDEX IF NOT EXISTS 'ident' ON cifp_airport (`ident`)"];
    
    [self query:@"CREATE TABLE IF NOT EXISTS `pirep` (`pirep_id` integer primary key autoincrement,`timestamp` timestamp not null default current_timestamp,`user_id` integer NOT NULL DEFAULT '0',`name` varchar(255) not null default '',`pirep_time` integer not null default '0',`my_lat` varchar(255) NOT NULL DEFAULT '',`my_long` varchar(255) NOT NULL DEFAULT '',`altitude` varchar(255) NOT NULL DEFAULT '',`gps_lat` varchar(255) NOT NULL DEFAULT '',`gps_long` varchar(255) NOT NULL DEFAULT '',`gps_altitude` varchar(255) NOT NULL DEFAULT '',`callsign` varchar(255) NOT NULL DEFAULT '',`comment` mediumtext NOT NULL,`ride` varchar(255) NOT NULL DEFAULT 'na',`ride_frequency` varchar(255) NOT NULL DEFAULT 'na',`wx` varchar(255) NOT NULL DEFAULT 'na',`is_clean` varchar(255) NOT NULL DEFAULT 'na',`is_noisy` varchar(255) NOT NULL DEFAULT 'na',`is_smelly` varchar(255) NOT NULL DEFAULT 'na',`photo` blob NOT NULL,`twitter` varchar(255) NOT NULL DEFAULT 'no',`facebook` varchar(255) NOT NULL DEFAULT 'no',`deleted` varchar(255) NOT NULL DEFAULT 'no',`remote_pirep_id` integer not null default '0',`sync_remote` varchar(255) not null default 'no')"];
    
    [self query:@"CREATE INDEX IF NOT EXISTS 'remote_pirep_id' ON pirep (`remote_pirep_id`)"];
    [self query:@"CREATE INDEX IF NOT EXISTS 'altitude_pirep' ON pirep (`altitude`,`pirep_time`)"];

    //MERGE THESE INTO MAIN CREATE TABLE
    [self query:@"ALTER TABLE pirep ADD `ride_base` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `ride_top` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `visibility` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `cloud` varchar(255) not null default 'na'"];
    [self query:@"ALTER TABLE pirep ADD `cloud_base` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `cloud_top` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `icing` varchar(255) not null default 'na'"];
    [self query:@"ALTER TABLE pirep ADD `icing_base` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `icing_top` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `callsign_type` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `oat` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `wind` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `icing_type` varchar(255) not null default ''"];
    [self query:@"ALTER TABLE pirep ADD `ride_type` varchar(255) not null default ''"];
    
    
    //sync table
    [self query:@"CREATE TABLE IF NOT EXISTS upload (`upload_id` integer primary key autoincrement,`timestamp` timestamp not null default current_timestamp,`what` varchar not null default '',`my_id` int not null default '0',`status` varchar not null default '')"];
    
}
- (void) dump_table:(NSString *) table_name {
    NSMutableDictionary *my_query = [self query:[NSString stringWithFormat:@"SELECT * FROM %@",table_name]];
    NSLog(@"success status: %@",[my_query objectForKey:@"success"]);
    NSMutableArray *my_result = [my_query objectForKey:@"result"];
    NSInteger y = [my_result count] - 1;
    
    for(NSInteger x = 0;x<=y;x++) {
        NSString *my_row_string = [[NSString alloc] init];
        my_row_string = [NSString stringWithFormat:@"row=%i :: ",y];
        NSMutableArray *my_row = [my_result objectAtIndex:x];
        NSInteger zz = [my_row count] - 1;
        for(NSInteger z = 0;z<=zz;z++) {
            NSString *my_data = [my_row objectAtIndex:z];
            my_row_string = [NSString stringWithFormat:@"%@, %i=%@",my_row_string,z,my_data];
        }
        if(IS_DEBUG) NSLog(@"t=%@ %@",table_name,my_row_string);
    }
}

- (void) close_db {
    sqlite3_close(my_db);
    my_db = nil;
}

-(void) db_sync {
    NSLog(@"DB SYNC");
    
   // [UIApplication sharedApplication].applicationIconBadgeNumber++;

    if([mySession objectForKey:@"sync_lock"]) {
//        [self doAlert:@"Already syncing, please wait."];
        return;
    }
    [mySession setObject:@"1" forKey:@"sync_lock"];
    
    [self real_db_sync];
    //BACKGROUND THE TASK...
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
//    dispatch_async(dispatch_get_main_queue(), ^{
        // background operation
    //});
}

-(void) real_db_sync {
    
//    NSLog(@"STARTING REAL_DB_SYNC");
    //SEND LOCAL DB CHANGES TO SERVER!!!
    
    //tables to sync
    //    NSArray *tables = @[@"user_endorsement"];
    NSArray *tables = @[@"airline",@"pirep"];
    
    //check flight_data and flight_user tables
    /*
     NSMutableDictionary *q1 = [self query:[NSString stringWithFormat:@"SELECT flight_user_id,user.remote_user_id FROM flight_user LEFT JOIN user USING(user_id) WHERE flight_user.remote_user_id = 0 and user.remote_user_id > 0"]];
     NSMutableArray *q1_rows = [q1 objectForKey:@"result"];
     for(NSInteger x = 0;x<[q1_rows count];x++) {
     NSLog(@"@@@@ UPDATING flight_user REMOTE_UESR_ID PRE-DB-SEND");
     NSMutableArray *q1_row = [q1_rows objectAtIndex:x];
     [self query:[NSString stringWithFormat:@"UPDATE flight_user SET remote_user_id = '%@' WHERE flight_user_id = '%@'",[q1_row objectAtIndex:1],[q1_row objectAtIndex:0]]];
     }
     */
    //end checks here
    
    
    
    NSMutableDictionary *table_data = [[NSMutableDictionary alloc] init];
    for(NSString *table in tables ){
        NSArray *sync_table_data = [self sync_table_data:table];
        NSString *local_key = [self sync_table_data_local_key:table];
        //NSString *primary_key = [sync_table_data objectAtIndex:0];
        NSArray *cols = [sync_table_data objectAtIndex:1];
        NSString *query = [NSString stringWithFormat:@"SELECT %@",local_key];
        for(NSString *col in cols) {
            query = [NSString stringWithFormat:@"%@,%@",query,col];
        }
        
        NSString *where_extra = @"";
        //if([table isEqualToString:@"flight_data"])
        //    where_extra = @" AND remote_flight_id > 0";
        
        query = [NSString stringWithFormat:@"%@ FROM %@ WHERE sync_remote = 'yes' %@",query,table,where_extra];
        
        if(IS_DEBUG) NSLog(@"local_data query: %@",query);
        NSMutableDictionary *q = [self query:query];
        [table_data setObject:[q objectForKey:@"result"] forKey:table];
    }
    //END LOCAL UPDATES PREPERATION
    
    
    //SEND UPDATES AND RECEIVE UPDATES FROM SERVER
    NSMutableDictionary *requestData = [[ NSMutableDictionary alloc] init];
    [requestData setObject:@"db_sync_remote" forKey:@"request" ];
    
    //delete below for full sync
    if([mySession objectForKey:@"device_sync_id"])
        [requestData setObject:[mySession objectForKey:@"device_sync_id"] forKey:@"device_sync_id" ];
    
    [requestData setObject:table_data forKey:@"local_data" ];
    
    [requestData setObject:[mySession objectForKey:@"session_id"] forKey:@"session_id" ];
    [requestData setObject:@"db_sync_remote" forKey:@"connection_description" ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotification:)
                                                 name:[requestData objectForKey:@"connection_description"] object:nil];
    [self apiRequest:requestData];
}

- (NSString *) clean_time:(NSString *) hour_str min:(NSString *) min {
    NSInteger hour = [hour_str intValue];
    
    NSString *ampm = @"am";
    if(hour >= 12)
        ampm = @"pm";
    if(hour > 12)
        hour  -= 12;
    if(hour == 0)
        hour = 12;
    
    return [NSString stringWithFormat:@"%i:%@%@",hour,min,ampm];
}

- (NSString *) month_to_text:(NSInteger) current_month {
    NSString *my_text = @"JAN";
    if(current_month == 2)
        my_text = @"FEB";
    else if(current_month == 3)
        my_text = @"MAR";
    else if(current_month == 4)
        my_text = @"APR";
    else if(current_month == 5)
        my_text = @"MAY";
    else if(current_month == 6)
        my_text = @"JUN";
    else if(current_month == 7)
        my_text = @"JUL";
    else if(current_month == 8)
        my_text = @"AUG";
    else if(current_month == 9)
        my_text = @"SEP";
    else if(current_month == 10)
        my_text = @"OCT";
    else if(current_month == 11)
        my_text = @"NOV";
    else if(current_month == 12)
        my_text = @"DEC";
    
    return my_text;
}

- (NSInteger) reverse_number:(NSInteger) old_number {
    return old_number - old_number - old_number;
}

-(void) real_db_sync_received:(NSNotification *) notification {
    if(IS_DEBUG) NSLog(@"STARTING REAL_DB_SYNC_RECEIVED");
    if(IS_DEBUG) NSLog(@"STAGE 0");
    
    if(IS_DEBUG) NSLog(@"BH - STAGE 0");

    
    //SUCCESSFUL UPDATES RECOGNIZE THE UPDATES...
    NSMutableDictionary *local_update_success = [notification.userInfo objectForKey:@"local_update_success"];
    for(NSString *table in local_update_success) {
        NSString *local_key = [self sync_table_data_local_key:table];
        NSString *remote_key = [NSString stringWithFormat:@"remote_%@",local_key];
        
        NSMutableArray *remote_data = [local_update_success objectForKey:table];
        
        if(IS_DEBUG) NSLog(@"db table stuff here 2 count: %i",[remote_data count]);
        
        //ROWS TO UPDATE HERE...
        for(NSInteger x = 0;x<[remote_data count];x++) {
            
            NSArray *values = [remote_data objectAtIndex:x];
            NSString *value = [values objectAtIndex:0];
            NSString *remote_value = [values objectAtIndex:1];
            
            if(IS_DEBUG) NSLog(@"UPDATE_LOCAL_SUCCESS %@ value: %@ for_key: %@ REMOTE_KEY: %@ REMOTE_VALUE: %@",table,value,local_key,remote_key,remote_value);
            
            NSInteger remote_value_int = [remote_value integerValue];
            if(remote_value_int > 0) {
                
                //SOMETHING INSERTED.......
                [self query:[NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@',sync_remote='no' WHERE %@ = '%@'",table,remote_key,remote_value,local_key,value]];
                
                
                //should we even do this???
                if([table isEqualToString:@"flight"]) {
                    [self query:[NSString stringWithFormat:@"UPDATE flight_data SET %@ = '%@' WHERE %@ = '%@' and %@ = 0",remote_key,remote_value,local_key,value,remote_key]];
                    
                    [self query:[NSString stringWithFormat:@"UPDATE flight_user SET %@ = '%@' WHERE %@ = '%@' and %@ = 0",remote_key,remote_value,local_key,value,remote_key]];
                }else if([table isEqualToString:@"user"]) {
                    [self query:[NSString stringWithFormat:@"UPDATE flight_user SET %@ = '%@' WHERE %@ = '%@' and %@ = 0",remote_key,remote_value,local_key,value,remote_key]];
                }
            }else{
                [self query:[NSString stringWithFormat:@"UPDATE %@ SET sync_remote='no' WHERE %@ = '%@'",table,local_key,value]];
            }
        }
    }
    
    if(IS_DEBUG) NSLog(@"STAGE 1");

    if(IS_DEBUG) NSLog(@"BH - STAGE 1");

    
    //REMOTE SYNC TO LOCAL
    NSMutableDictionary *remote_sync_data = [notification.userInfo objectForKey:@"sync_remote_data"];
    
    if([notification.userInfo objectForKey:@"device_sync_id"]) {
        [mySession setObject:[notification.userInfo objectForKey:@"device_sync_id"] forKey:@"device_sync_id"];
        [self writeSession];
    }

    if(IS_DEBUG) NSLog(@"STAGE 2");

    if(IS_DEBUG) NSLog(@"BH - STAGE 2");

    
    //INCOMING NEW DATA TO UPDATE LOCALLY COULD BE DUPLICATE SO MUST CHECK FOR UPDATES....
    for(NSString *my_key in remote_sync_data) {
        //            NSLog(@"PIZPOH 1");
        
        NSArray *sync_table_data = [self sync_table_data:my_key];
        NSString *primary_key = [sync_table_data objectAtIndex:0];
        //          NSLog(@"PIZPOH 1.5");
        
        NSArray *col = [sync_table_data objectAtIndex:1];
        if([primary_key isEqualToString:@""]) {
            continue;
        }

        NSString *my_column = [self build_query_column:col];
        NSString *my_column_question = [self build_query_column_question:col];
        sqlite3_stmt *statement_insert = [self query_insert_prepare:[NSString stringWithFormat:@"INSERT INTO %@ (timestamp,%@) VALUES (datetime('now'),%@)",my_key,my_column,my_column_question]];


        if(IS_DEBUG) NSLog(@"STAGE 3 key: %@ %ld %@",my_key,(unsigned long)[[remote_sync_data objectForKey:my_key] count],primary_key);
        if(IS_DEBUG) NSLog(@"BH - STAGE 3");

        NSMutableArray *remote_data = [remote_sync_data objectForKey:my_key];
        //ROWS TO UPDATE HERE...
        for(NSInteger x = 0;x<[remote_data count];x++) {
            if(IS_DEBUG) NSLog(@"STAGE 3.1 X: %li",(long)x);
            NSMutableArray *row = [remote_data objectAtIndex:x];
            if(IS_DEBUG) NSLog(@"STAGE 3.2 X: %li",(long)x);
            
            NSString *query_text = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = '%@'",my_key,primary_key,[row objectAtIndex:0]];
            
            if(IS_DEBUG) NSLog(@"STAGE 3.3 X: %li",(long)x);

            
            NSMutableDictionary *check_query = [self query:query_text];
            if(IS_DEBUG) NSLog(@"STAGE 3.31 X: %li",(long)x);
            NSMutableArray *check_result = [check_query objectForKey:@"result"];
            if(IS_DEBUG) NSLog(@"STAGE 3.32 X: %li",(long)x);
            if(IS_DEBUG) NSLog(@"STAGE 3.33 X: %li %@",[check_result count],query_text);
            NSMutableArray *check_row = [check_result objectAtIndex:0];
            
            
            if(IS_DEBUG) NSLog(@"STAGE 3.4 X: %li",(long)x);

            if([[check_row objectAtIndex:0] isEqualToString:@"0"]) {
                if(IS_DEBUG) NSLog(@"STAGE 3.41 X: %li",(long)x);

                //INSERT
                //NSString *my_value = [self build_query_values:row];
                
                if([[col objectAtIndex:[col count] - 1] isEqualToString:@"deleted"] && [[row objectAtIndex:[row count] - 1] isEqualToString:@"yes"]) {
                    //DON'T INSERT DELETED = YES
                    NSLog(@"SKIPPING_ROW DELETED = YES!!! t: %@ prim_val: %@",my_key,[row objectAtIndex:0]);
                    continue;
                }
  
                //NEEDED!!
                [self query_insert:statement_insert value:row];
            }else{
                if(IS_DEBUG) NSLog(@"STAGE 3.412 X: %li count: %li",(long)x,[row count]);

                NSString *my_update = [self build_query_update:col value:row];

                if(IS_DEBUG) NSLog(@"STAGE 3.413 X: %li count: %li",(long)x,[row count]);
                //NSLog(@"DOING UPDATE HERE BETWEEN INSERT %@",[NSString stringWithFormat:@"UPDATE %@ SET timestamp = datetime('now'),%@ WHERE %@ = '%@'",my_key,my_update,primary_key,[row objectAtIndex:0]]);

                [self query:[NSString stringWithFormat:@"UPDATE %@ SET timestamp = datetime('now'),%@ WHERE %@ = '%@'",my_key,my_update,primary_key,[row objectAtIndex:0]]];
            }

            if(IS_DEBUG) NSLog(@"STAGE 3.5 X: %li",(long)x);
        }
        
        [self query_insert_done:statement_insert];
    }
    
    
    
    
    if(IS_DEBUG) NSLog(@"BH - STAGE 4");

    
    
    if(IS_DEBUG) NSLog(@"DISPATCHING TO MAIN THREAD RESPONSE...");
    //back to main thread
    dispatch_async(dispatch_get_main_queue(), ^{

        //let the server know we syncd OK
        NSMutableDictionary *requestData = [[ NSMutableDictionary alloc] init];
    
        [requestData setObject:@"db_sync_remote_verify" forKey:@"request" ];
        [requestData setObject:[notification.userInfo objectForKey:@"sync_timestamp"] forKey:@"sync_timestamp" ];
    
        [requestData setObject:[mySession objectForKey:@"device_sync_id"] forKey:@"device_sync_id" ];
        [requestData setObject:[mySession objectForKey:@"session_id"] forKey:@"session_id" ];
        [requestData setObject:@"db_sync_remote_verify" forKey:@"connection_description" ];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotification:)
                                                 name:[requestData objectForKey:@"connection_description"] object:nil];
    
        [self apiRequest:requestData];
        
        
        //NOTIFY PAGE TO REFRESH DATA
        [[NSNotificationCenter defaultCenter] postNotificationName:@"page_db_sync_complete" object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"true",@"complete", nil]];

    });
    
    if(IS_DEBUG) NSLog(@"BH - STAGE 5");

    if(IS_DEBUG) NSLog(@"ENDING REAL_DB_SYNC_RECEIVED");
}

- (void)myNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(IS_DEBUG) NSLog(@"COMMON NOTIFY !!!!!! name: =%@=",notification.name);
    
    if([notification.name isEqual:@"db_sync_remote"]) {
        if([notification.userInfo objectForKey:@"connect_fail"]) {
            NSLog(@"Connection failed skipping notification callback for db_sync_remote");
//            sync_lock = false;
            [mySession removeObjectForKey:@"sync_lock"];
            return;
        }
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            [self real_db_sync_received:notification];
  //      });
    }else if([notification.name isEqualToString:@"db_sync_remote_verify"]) {
        if(IS_DEBUG) NSLog(@"db_sync_remote_verify response complete. UNLOCK HERE");
        
        [mySession removeObjectForKey:@"sync_lock"];

        
        // [self dump_table:@"schedule"];
        
        //      NSLog(@"dump done now for specifics...");
        
        //LIST ITEMS ON A SPECIFIC DAY...
        /*        NSMutableDictionary *my_query2 = [self query:[NSString stringWithFormat:@"SELECT strftime('%%s','2013-09-23 00:00:00'),strftime('%%s','2013-09-23 23:59:59')"]];
         NSLog(@"QUERY1 success status: %@",[my_query2 objectForKey:@"success"]);
         NSMutableArray *my_result2 = [my_query2 objectForKey:@"result"];
         NSMutableArray *my_row2 = [my_result2 objectAtIndex:0];
         NSLog(@"data row: %@ row2: %@", [my_row2 objectAtIndex:0],[my_row2 objectAtIndex:1]);
         */
        
        
        
        
        
        
        //query calendar item example
        /*  NSString *my_string = @"2013-09-25";
         NSMutableDictionary *my_query = [self query:[NSString stringWithFormat:@"SELECT strftime('%%m/%%d/%%Y %%H:%%M',datetime(date_start + %@,'unixepoch')),strftime('%%m/%%d/%%Y %%H:%%M',datetime(date_end + %@,'unixepoch')),description FROM schedule WHERE date_start + %@ BETWEEN cast(strftime('%%s','2013-09-25 00:00:00') as integer) and cast(strftime('%%s','2013-09-25 23:59:59') as integer) ORDER BY date_start",[mySession objectForKey:@"tz"],[mySession objectForKey:@"tz"],[mySession objectForKey:@"tz"]]];
         
         */
        
        
        /*
         
         NSMutableDictionary *my_query = [self query:[NSString stringWithFormat:@"SELECT strftime('%%m/%%d/%%Y %%H:%%M',datetime(date_start + %@,'unixepoch')),strftime('%%m/%%d/%%Y %%H:%%M',datetime(date_end + %@,'unixepoch')),description FROM schedule WHERE date_start + %@ BETWEEN cast(strftime('%%s','%@ 00:00:00') as integer) and cast(strftime('%%s','%@ 23:59:59') as integer) ORDER BY date_start",[mySession objectForKey:@"tz"],[mySession objectForKey:@"tz"],[mySession objectForKey:@"tz"],my_string,my_string]];
         
         NSLog(@"QUERY2 success status: %@",[my_query objectForKey:@"success"]);
         NSMutableArray *my_result = [my_query objectForKey:@"result"];
         NSInteger y = [my_result count] - 1;
         
         for(NSInteger x = 0;x<=y;x++) {
         //        NSString *my_row_string = [[NSString alloc] init];
         NSMutableArray *my_row = [my_result objectAtIndex:x];
         NSLog(@"Calendar start: %@ end: %@ desc: %@",[my_row objectAtIndex:0],[my_row objectAtIndex:1],[my_row objectAtIndex:2]);
         }
         
         */
    }
}



-(NSString *) build_query_update:(NSArray *) my_array value:(NSMutableArray *) my_value {
    NSString *my_string = [[NSString alloc] init];
    NSInteger z = 0;
    if(IS_DEBUG) NSLog(@"build_query_update step 0");
    if([my_array count] != [my_value count]) {
        NSLog(@"WARNING WARNING WARNING total_col: %i != total_val: %i",[my_array count],[my_value count]);
        return @"";
    }
    if(IS_DEBUG) NSLog(@"build_query_update step 1");

    for(NSString *col in my_array) {
        if(IS_DEBUG) NSLog(@"build_query_update step 1.5 z: %li",z);

        NSString *data = [[my_value objectAtIndex:z] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        if([my_string isEqualToString:@""])
            my_string = [NSString stringWithFormat:@"%@ = '%@'",col,data];
        else
            my_string = [NSString stringWithFormat:@"%@,%@ = '%@'",my_string,col,data];
        z++;
    }
    if(IS_DEBUG) NSLog(@"build_query_update step 3");

    return my_string;
    
}
-(NSString *) build_query_column:(NSArray *) my_array {
    NSString *my_string = [[NSString alloc] init];
    for(NSString *col in my_array) {
        if([my_string isEqualToString:@""])
            my_string = col;
        else
            my_string = [NSString stringWithFormat:@"%@,%@",my_string,col];
    }
    return my_string;
}

-(NSString *) build_query_column_question:(NSArray *) my_array {
    NSString *my_string = [[NSString alloc] init];
    for(NSString *col in my_array) {
        if([my_string isEqualToString:@""])
            my_string = @"?";
        else
            my_string = [NSString stringWithFormat:@"%@,?",my_string];
    }
    return my_string;
}

-(NSString *) build_query_values:(NSMutableArray *) my_array {
    NSString *my_string = [[NSString alloc] init];
    NSInteger z = 0;
    for(NSString *str in my_array) {
        NSString *data = [str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

//        char *data = sqlite3_mprintf("%q",str);
//        NSLog(@"data: =%s=",data);
        
        if(z == 0)
            my_string = [NSString stringWithFormat:@"'%@'",data];
        else
            my_string = [NSString stringWithFormat:@"%@,'%@'",my_string,data];
        

        z++;
    }
   // NSLog(@"my_string: %@",my_string);
    return my_string;
}




-(void) apiRequest:(NSMutableDictionary*)myRequest{
    [myRequest setObject:[NSString stringWithFormat:@"%.2f",MASTER_VERSION] forKey:@"master_version"];
    
    NSError *error = nil;
    NSData *json_str1 = [NSJSONSerialization dataWithJSONObject:myRequest options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonRequest = [[NSString alloc]initWithData:json_str1 encoding:NSUTF8StringEncoding];
    
    if(IS_DEBUG) NSLog(@"apiRequest(): =%@=",jsonRequest);
    
    
    NSMutableURLRequest *theRequest=[[NSMutableURLRequest alloc]init];
    
//    NSString *post = [NSString stringWithFormat:@"my_request=%@",jsonRequest];
    NSString *post = [NSString stringWithFormat:@"my_request=%@",[jsonRequest stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]];

    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [theRequest setURL:[NSURL URLWithString:@"http://www.aerovie.com/api/applite.html"] ];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPBody:postData];
    
    //little short testing
    [theRequest setTimeoutInterval:20];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    //receivedData = [[NSMutableData alloc] init];
    NSMutableData *myData = [[NSMutableData alloc] init];
    NSMutableArray *connectionData = [[NSMutableArray alloc] initWithObjects:[myRequest objectForKey:@"connection_description"],myData,nil];
    
    [myConnections setObject:connectionData forKey:[theConnection description]];
    
    //    if(IS_DEBUG) NSLog(@"hi there bitch %@",[theConnection description]);
    
    if (theConnection) {
        if(IS_DEBUG) NSLog(@"apiRequest() connection established");
    } else {
        if(IS_DEBUG) NSLog(@"connection failed");
        // Inform the user that the connection failed.
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[[myConnections objectForKey:[theConnection description]] objectAtIndex:0] object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"true",@"connect_fail", nil]];
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response

{
    if(IS_DEBUG) NSLog(@"connection() connection response...");
    
    // receivedData is an instance variable declared elsewhere.
    
    NSMutableData *thisData = [[myConnections objectForKey:[connection description]] objectAtIndex:1];
    [thisData setLength:0];
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
    if(IS_DEBUG) NSLog(@"connection() data received %d",[data length]);
    NSMutableData *thisData = [[myConnections objectForKey:[connection description]] objectAtIndex:1];
    
    [thisData appendData:data];
}
- (void)connection:(NSURLConnection *)connection

  didFailWithError:(NSError *)error

{
    NSLog(@"Connection failed! Error - %@ %@",
                       
                       [error localizedDescription],
                       
                       [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[[myConnections objectForKey:[connection description]] objectAtIndex:0] object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"true",@"connect_fail", nil]];
    
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    if(IS_DEBUG) NSLog(@"connectionDidFinishLoading()  Received data");
    
    
    NSMutableData *thisData = [[myConnections objectForKey:[connection description]] objectAtIndex:1];
    
    NSString *strData = [[NSString alloc]initWithData:thisData encoding:NSUTF8StringEncoding];

    
    NSError *error = nil;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:thisData //1
                          
                          options:NSJSONReadingMutableContainers
                          error:&error];

    [[NSNotificationCenter defaultCenter] postNotificationName:[[myConnections objectForKey:[connection description]] objectAtIndex:0] object:self userInfo:json];
    
    [myConnections removeObjectForKey:[connection description]];
}





-(void) clearSesssion {
    // Build the path...
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"mySessionData-lite.txt";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    NSError *error = nil;
    
    
    //remove session every read... unncomment below
       [[NSFileManager defaultManager] removeItemAtPath:fileAtPath error:&error];
    [self readSession];
}

-(void) readSession {
    if(IS_DEBUG) NSLog(@"reading session here");

    
    
    // Build the path...
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"mySessionData-lite.txt";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    NSError *error = nil;
    
    
    //remove session every read... unncomment below
 //   [[NSFileManager defaultManager] removeItemAtPath:fileAtPath error:&error];

    
    
    NSData *myData = [NSData dataWithContentsOfFile:fileAtPath];
    
    NSString *myText = [[NSString alloc]initWithData:myData encoding:NSUTF8StringEncoding];
    if([myText isEqualToString:@""]) {
        if(IS_DEBUG) NSLog(@"readSession() is empty");
        mySession = [[NSMutableDictionary alloc] init];
        [mySession setObject:@"1" forKey:@"read_session"];
        [self set_session_defaults];
        return;
    }
    if(IS_DEBUG) NSLog(@"readSession() str: =%@=",myText);
    
    
    
    

    //   mySession = [[NSMutableDictionary alloc] init];
    mySession = [NSJSONSerialization
                 JSONObjectWithData:myData
                 options:NSJSONReadingMutableContainers
                 error:&error];
    
    
    [mySession setObject:@"1" forKey:@"read_session"];
    [mySession setObject:@"-18000" forKey:@"tz"];
    [self set_session_defaults];
}


-(void) writeSession {
    //[mySession setObject:@"1" forKey:@"write_session"];
      if(IS_DEBUG) NSLog(@"writeSession!!!!!!!!!");
    
    //        NSMutableDictionary *myWriteSession = mySession;
    NSMutableDictionary *myWriteSession = [[NSMutableDictionary alloc] initWithDictionary:mySession];
    //    [myWriteSession removeObjectForKey:@"button_on_color"];
    
    
    NSError *error;
    NSData *jsonString2 = [NSJSONSerialization dataWithJSONObject:myWriteSession options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc]initWithData:jsonString2 encoding:NSUTF8StringEncoding];
    if(IS_DEBUG) NSLog(@"writeSession() json is: =%@=",jsonString);
    
    
    // Build the path, and create if needed.
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"mySessionData-lite.txt";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    // if(IS_DEBUG) NSLog(@"blah blah %@",fileAtPath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    // The main act.
    [[jsonString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

-(void) set_session_defaults {
    //http://www.touch-code-magazine.com/web-color-to-uicolor-convertor/
    //    UIColor *button_on_color = [UIColor colorWithRed:0.561 green:0.055 blue:0.071 alpha:1]; /*#8f0e12*/
    //    UIColor *button_off_color = [UIColor colorWithRed:0.278 green:0.016 blue:0.024 alpha:1]; /*#470406*/
    
    //    [mySession setObject:button_on_color forKey:@"button_on_color"];
    //    [mySession setObject:button_off_color forKey:@"button_off_color"];
    
}



-(NSString *) seconds_to_flight_time:(NSString *) seconds_str {
    
    if(!seconds_str || seconds_str == 0)
        return [NSString stringWithFormat:@"0"];
    long seconds = [seconds_str longLongValue];
    
    //    NSLog(@"seconds_to_flight_time seconds: %ld f: %ld",seconds,seconds / 3600);
    
    float hour = seconds;
    //    NSLog(@"seconds_to_flight_time pos0: %f %f",hour, hour / 3600);
    hour /= 3600;
    
    return [NSString stringWithFormat:@"%.01f",hour];
}




- (void) new_graph:(UIWebView *) web_view template:(NSString *) template categories:(NSMutableArray *) categories series:(NSMutableDictionary *) series width:(NSInteger) width height:(NSInteger) height options:(NSMutableDictionary *) options {
    //categories array to string, simple
    //series dictionary
    //name = self explanat
    //data = NSMUTABLEARRAY
    //array element could be array OR string
    
    NSString *categories_string = @"[";
    
    NSInteger x = 0;
    for(NSString *my_element in categories) {
        if(x == 0)
            categories_string = [NSString stringWithFormat:@"%@'%@'",categories_string,my_element];
        else
            categories_string = [NSString stringWithFormat:@"%@,'%@'",categories_string,my_element];
        x++;
    }
    categories_string = [NSString stringWithFormat:@"%@]",categories_string];
    if(IS_DEBUG) NSLog(@"categories string =%@=",categories_string);
    
    
    NSString *series_string = @"[{";
    x = 0;
    
    if([series objectForKey:@"name"])
        series_string = [NSString stringWithFormat:@"%@name: '%@',",series_string,[series objectForKey:@"name"]];
    
    series_string = [NSString stringWithFormat:@"%@data: [",series_string];
    
    for(NSData *my_data in [series objectForKey:@"data"]) {
        NSString *my_data_string = @"";
        if([my_data isKindOfClass:[NSArray class]]) {
            //array
            NSArray *my_array = (NSArray *)my_data;
            my_data_string = @"[";
            NSInteger z = 0;
            for(NSString *my_string in my_array) {
                if(z == 0)
                    my_data_string = [NSString stringWithFormat:@"%@'%@'",my_data_string,my_string];
                else
                    my_data_string = [NSString stringWithFormat:@"%@,%@",my_data_string,my_string];
                z++;
            }
            my_data_string = [NSString stringWithFormat:@"%@]",my_data_string];;
        }else{
            //string? cast as a String
            my_data_string = (NSString *)my_data;
        }
        
        if(x == 0) {
            series_string = [NSString stringWithFormat:@"%@%@",series_string,my_data_string];
        }else{
            series_string = [NSString stringWithFormat:@"%@,%@",series_string,my_data_string];
        }
        x++;
    }
    series_string = [NSString stringWithFormat:@"%@]}]",series_string];
    
    // NSLog(@"series string =%@=",series_string);
    
    
    NSData *my_template_data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:template ofType: @"html"]];
    NSString *my_template_text = [[NSString alloc]initWithData:my_template_data encoding:NSUTF8StringEncoding];
    my_template_text = [my_template_text stringByReplacingOccurrencesOfString:@"!!categories!!" withString:categories_string];
    my_template_text = [my_template_text stringByReplacingOccurrencesOfString:@"!!series!!" withString:series_string];
    
    
    my_template_text = [my_template_text stringByReplacingOccurrencesOfString:@"!!width!!" withString:[NSString stringWithFormat:@"%i",width]];
    my_template_text = [my_template_text stringByReplacingOccurrencesOfString:@"!!height!!" withString:[NSString stringWithFormat:@"%i",height]];
    
    for(NSString *key in options) {
        my_template_text = [my_template_text stringByReplacingOccurrencesOfString:key withString:[options objectForKey:key]];
    }
    /*
     if([options objectForKey:@"y_axis_title"])
     my_template_text = [my_template_text stringByReplacingOccurrencesOfString:@"!!y_axis_title!!" withString:[options objectForKey:@"y_axis_title"]];
     
     if([options objectForKey:@"x_axis_title"])
     my_template_text = [my_template_text stringByReplacingOccurrencesOfString:@"!!y_axis_title!!" withString:[options objectForKey:@"x_axis_title"]];
     */
    
    if(IS_DEBUG) NSLog(@"my template text %@",my_template_text);
    [web_view loadHTMLString:my_template_text baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES]];
    
    web_view.scrollView.bounces = false;
    web_view.scrollView.scrollEnabled = false;
}





-(NSString *) sync_table_data_local_key:(NSString *) my_table {
    NSString *my_key = @"";
    if([my_table isEqualToString:@"airline"])
        my_key = @"airline_id";
    else if([my_table isEqualToString:@"cifp_airport"])
        my_key = @"cifp_airport_id";
    else if([my_table isEqualToString:@"pirep"])
        my_key = @"pirep_id";
    else if([my_table isEqualToString:@""])
        my_key = @"";
    else if([my_table isEqualToString:@""])
        my_key = @"";
    
    return my_key;
}

-(NSArray *) sync_table_data:(NSString *) my_key {
    NSString *primary_key = @"";
    NSArray *col = @[];
    
    // @"deleted" MUST BE AT THE END!
    
    if([my_key isEqualToString:@"airline"]) {
        primary_key = @"remote_airline_id";
        col = @[@"remote_airline_id",@"ident",@"name",@"city",@"callsign",@"deleted"];
    }else if([my_key isEqualToString:@"cifp_airport"]) {
            primary_key = @"remote_cifp_airport_id";
            col = @[@"remote_cifp_airport_id",@"ident",@"name",@"my_lat",@"my_long",@"deleted"];
    }else if([my_key isEqualToString:@"pirep"]) {
            primary_key = @"remote_pirep_id";
            col = @[@"remote_pirep_id",@"name",@"pirep_time",@"my_lat",@"my_long",@"altitude",@"gps_lat",@"gps_long",@"gps_altitude",@"callsign",@"comment",@"ride",@"ride_frequency",@"wx",@"is_clean",@"is_noisy",@"is_smelly",@"photo",@"twitter",@"facebook",@"ride_base",@"ride_top",@"visibility",@"cloud",@"cloud_base",@"cloud_top",@"icing",@"icing_base",@"icing_top",@"callsign_type",@"oat",@"wind",@"icing_type",@"ride_type",@"deleted"];
    }else{
        NSLog(@"UNKNOWN DATA RECEIVED FOR KEY: =%@=",my_key);
    }
    
    return @[primary_key,col];
}

-(void) open_query_debug:(UIView *) parent_view {
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(100, 100, 800, 500);
    view.backgroundColor = [UIColor greenColor];
    view.layer.cornerRadius = 5;
    view.clipsToBounds = true;
    
    query_text = [[UITextField alloc] init];
    query_text.backgroundColor = [UIColor whiteColor];
    query_text.frame = CGRectMake(5, 5, view.frame.size.width - 90, 30);
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(view.frame.size.width - 160, 5, 80, 30);
    [button setTitle:@"Query" forState:UIControlStateNormal];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(query_push:)];
    [button addGestureRecognizer:tap];

    UIButton *button2 = [[UIButton alloc] init];
    button2.frame = CGRectMake(view.frame.size.width - 80, 5, 80, 30);
    [button2 setTitle:@"Close" forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(query_close:)];
    [button2 addGestureRecognizer:tap2];


    
    
    query_result = [[UITextView alloc] init];
    query_result.frame = CGRectMake(5, 35, view.frame.size.width - 10, view.frame.size.height - 40);
    query_result.backgroundColor = [UIColor yellowColor];

    [view addSubview:query_text];
    [view addSubview:button];
    [view addSubview:button2];
    [view addSubview:query_result];
    
    query_view = view;
    
    parent_query_view = parent_view;

    [parent_view addSubview:view];
}

- (IBAction)query_close:(UIGestureRecognizer *)gesture {
    [query_view removeFromSuperview];
}

- (IBAction)query_push:(UIGestureRecognizer *)gesture {
    
    [parent_query_view endEditing:YES];
    
    if(IS_DEBUG) NSLog(@"query push %@",query_text.text);
    
    NSMutableDictionary *my_query = [self query:query_text.text];
    NSMutableArray *my_result = [my_query objectForKey:@"result"];
    if(IS_DEBUG) NSLog(@"rows: %i succ: %@",[my_result count],[my_query objectForKey:@"success"]);
    
    if(!([[my_query objectForKey:@"success"] isEqualToString:@"1"])) {
        NSLog(@"query failed");
        query_result.text = [NSString stringWithFormat:@"QUERY FAILED\n%@",[my_query objectForKey:@"error"]];
        return;
    }
    query_result.text = [NSString stringWithFormat:@"rows=%i\n",[my_result count]];
    for(NSInteger x = 0;x<[my_result count];x++) {
        NSMutableArray *my_row = [my_result objectAtIndex:x];
        
        NSInteger z = 0;
        NSString *data = [[NSString alloc] init];
        for(NSInteger y=0;y<[my_row count];y++) {
            if(z == 0)
                data = [NSString stringWithFormat:@"z%i=%@",z,[my_row objectAtIndex:y]];
            else
                data = [NSString stringWithFormat:@"%@,z%i=%@",data,z,[my_row objectAtIndex:y]];
            z++;
        }
        query_result.text = [NSString stringWithFormat:@"%@\n%@",query_result.text,data];
    }
}

-(NSString *) add_comma:(NSInteger) number {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    numberFormatter.locale = [NSLocale currentLocale];// this ensures the right separator behavior
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = YES;
    return [numberFormatter stringFromNumber:[NSNumber numberWithInteger:number]];
}


-(NSMutableArray *) get_pirep:(NSString *) pirep_id local:(BOOL) is_local {
    if(IS_DEBUG) NSLog(@"GET PIREP HERE %@",pirep_id);
    NSMutableDictionary *q = [self query:[NSString stringWithFormat:@"SELECT name,pirep_time,altitude,callsign,comment,ride,ride_frequency,wx,is_clean,is_noisy,is_smelly,photo,icing,callsign_type,cloud,cloud_base,cloud_top,visibility,icing_type,oat,wind FROM pirep WHERE pirep_id = '%@'",pirep_id]];
    NSMutableArray *rs = [q objectForKey:@"result"];
    if([rs count] == 0) {
        NSLog(@"COULD NOT FIND %@ RETURNING",pirep_id);
        return [[NSMutableArray alloc] init];
    }
    NSMutableArray *row = [rs objectAtIndex:0];
    //0=name
    //1=pirep_time
    //2=altitude
    //3=callsign
    //4=comment
    //5=ride
    //6=ride_frequency
    //7=wx
    //8=is_clean
    //9=is_noisy
    //10=is_smelly
    //11=photo
    //12=icing
    //13=callsign_type
    //14=cloud
    //15=cloud_base
    //16=cloud_top
    //17=visibility
    //18=icing_type
    //19=oat
    //20=wind
    

    
    //check if callsign is a airport
    NSMutableDictionary *q2 = [self query:[NSString stringWithFormat:@"SELECT name FROM cifp_airport WHERE ident = '%@'",[row objectAtIndex:3]]];
    NSMutableArray *rs2 = [q2 objectForKey:@"result"];
    BOOL airport = false;
    NSString *airport_name = @"";
    if([rs2 count] > 0) {
        NSMutableArray *row2 = [rs2 objectAtIndex:0];
        airport_name = [[row2 objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(![airport_name isEqualToString:@""])
            airport = true;
    }
    
    
    NSString *ride = [row objectAtIndex:5];
    NSString *my_ride = @"";
    if([ride isEqualToString:@"smooth"]) {
        my_ride = [self add_string:my_ride new:@"smooth"];
    }else if([ride isEqualToString:@"light"]) {
        my_ride = [self add_string:my_ride new:@"light turbulence"];
    }else if([ride isEqualToString:@"light-moderate"]) {
        my_ride = [self add_string:my_ride new:@"light to moderate turbulence"];
    }else if([ride isEqualToString:@"moderate"]) {
        my_ride = [self add_string:my_ride new:@"moderate turbulence"];
    }else if([ride isEqualToString:@"moderate-severe"]) {
        my_ride = [self add_string:my_ride new:@"moderate to severe turbulence"];
    }else if([ride isEqualToString:@"severe"]) {
        my_ride = [self add_string:my_ride new:@"SEVERE turbulence"];
    }else if([ride isEqualToString:@"extreme"]) {
        my_ride = [self add_string:my_ride new:@"EXTREME turbulence"];
    }
    
    NSString *wx = [row objectAtIndex:7];
    if([wx isEqualToString:@"clear"]) {
        my_ride = [self add_string:my_ride new:@"clear skies"];
    }else if([wx isEqualToString:@"rainy"]) {
        my_ride = [self add_string:my_ride new:@"rain"];
    }else if([wx isEqualToString:@"cloudy"]) {
        my_ride = [self add_string:my_ride new:@"clouds"];
    }else if([wx isEqualToString:@"snow"]) {
        my_ride = [self add_string:my_ride new:@"snow"];
    }else if([wx isEqualToString:@"hail"]) {
        my_ride = [self add_string:my_ride new:@"HAIL"];
    }else if([wx isEqualToString:@"thunderstorm"]) {
        my_ride = [self add_string:my_ride new:@"THUNDERSTORM"];
    }else if([wx isEqualToString:@"sleet"]) {
        my_ride = [self add_string:my_ride new:@"sleet"];
    }else if([wx isEqualToString:@"icing"]) {
        my_ride = [self add_string:my_ride new:@"icing"];
    }

    if([[row objectAtIndex:8] isEqualToString:@"no"]) {
        my_ride = [self add_string:my_ride new:@"old or dirty aircraft"];
    }else if([[row objectAtIndex:8] isEqualToString:@"yes"]) {
        my_ride = [self add_string:my_ride new:@"new or clean aircraft"];
    }
    
    if([[row objectAtIndex:10] isEqualToString:@"yes"]) {
        my_ride = [self add_string:my_ride new:@"smells bad"];
    }
    
    if(![[row objectAtIndex:12] isEqualToString:@"na"]) {
        NSString *icing_type = @"";
        if(![[row objectAtIndex:18] isEqualToString:@"na"])
            icing_type = [NSString stringWithFormat:@"%@ ",[row objectAtIndex:18]];
        
        my_ride = [self add_string:my_ride new:[NSString stringWithFormat:@"%@ %@icing",[row objectAtIndex:12],icing_type]];
    }
    if(![[row objectAtIndex:14] isEqualToString:@"na"]) {
        //15 base
        //16 top
        NSString *str = @"";
        NSString *str2 = @"";

        
        if(![[row objectAtIndex:15] isEqualToString:@""]) {
            str = [NSString stringWithFormat:@"BASES %@",[row objectAtIndex:15]];
        }
        if(![[row objectAtIndex:16] isEqualToString:@""]) {
            str2 = [NSString stringWithFormat:@"TOPS %@",[row objectAtIndex:16]];
        }
        my_ride = [self add_string:my_ride new:[NSString stringWithFormat:@"%@ %@ %@",[[row objectAtIndex:14] uppercaseString],str,str2]];
    }
    if(![[row objectAtIndex:19] isEqualToString:@""])
        my_ride = [self add_string:my_ride new:[NSString stringWithFormat:@"temp. %@C",[row objectAtIndex:19]]];

    
    if(![[row objectAtIndex:17] isEqualToString:@""] && ![[row objectAtIndex:17] isEqualToString:@"-1"]) {
        my_ride = [self add_string:my_ride new:[NSString stringWithFormat:@"vis %@SM",[row objectAtIndex:17]]];
    }
    if(![[row objectAtIndex:20] isEqualToString:@""]) {
        NSString *degrees = [[row objectAtIndex:20] substringWithRange:NSMakeRange (0,3)];
        NSString *speed = [[row objectAtIndex:20] substringFromIndex:3];
        my_ride = [self add_string:my_ride new:[NSString stringWithFormat:@"wind %@ @ %@KT",degrees,speed]];
    }

    
    
    
    my_ride = [self add_and:my_ride];
    
    long mins = ([[NSDate date] timeIntervalSince1970] - [[row objectAtIndex:1] longLongValue])/60;
    
    NSMutableArray *ret = [[NSMutableArray alloc] init];


    NSString *string = @"";
    if(is_local)
        string = [self add_string2:string new:@"I'm"];
    else
        string = [self add_string2:string new:[row objectAtIndex:0]];

    NSString *identifier = @"";
    if(airport) {
        identifier = [NSString stringWithFormat:@"at %@",airport_name];
        string = [self add_string2:string new:identifier];
    }else if(![[row objectAtIndex:3] isEqualToString:@""] && ![[row objectAtIndex:3] isEqualToString:@"N/A"]) {
        identifier = [NSString stringWithFormat:@"on %@",[row objectAtIndex:3]];
        string = [self add_string2:string new:identifier];
    }

    //  NSLog(@"identifier: %@ name: %@",identifier,[row objectAtIndex:3]);

    
    NSString *altitude = @"";
    NSInteger alt_int = [[row objectAtIndex:2] integerValue];
    if(alt_int > 0) {
        altitude = [NSString stringWithFormat:@"at %@'",[self add_comma:(alt_int*100)]];
        string = [self add_string2:string new:altitude];
        
    }
    if(is_local)
        string = [self add_string2:string new:@"reporting"];
    else
        string = [self add_string2:string new:@"reports"];

    string = [self add_string2:string new:my_ride];


    [ret addObject:string];

//    NSLog(@"2_identifier: %@",identifier);

    
    
    /*
    if(is_local)
        [ret addObject:[NSString stringWithFormat:@"I'm %@%@ reporting %@",identifier,altitude,my_ride]];
    else
        [ret addObject:[NSString stringWithFormat:@"%@ %@%@ reports %@",[row objectAtIndex:0],identifier,altitude,my_ride]];
     */
    
    [ret addObject:[NSString stringWithFormat:@"%ld mins ago",mins]];
    [ret addObject:[row objectAtIndex:4]];
    
    //    NSLog(@"HIZHERE");
    //3
    if(![[row objectAtIndex:11] isEqualToString:@""]) {
        UIImage *image = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:[row objectAtIndex:11] options:kNilOptions]];
        if(image && image != nil)
            [ret addObject:image];
        else
            [ret addObject:@""];
    }else
        [ret addObject:@""];
    
    
    return ret;
}

-(NSString *) add_string:(NSString *) old new:(NSString *) new {
    if([old isEqualToString:@""])
        return new;
    else
        return [NSString stringWithFormat:@"%@, %@",old,new];
}
-(NSString *) add_string2:(NSString *) old new:(NSString *) new {
    if([old isEqualToString:@""])
        return new;
    else
        return [NSString stringWithFormat:@"%@ %@",old,new];
}
-(NSString *) add_and:(NSString *) old {
    NSInteger last_comma = 0;
    for(NSInteger x = 0;x<[old length];x++) {
        NSString *c = [old substringWithRange:NSMakeRange(x, 1)];
        if([c isEqualToString:@","])
            last_comma = x;
    }
    if(last_comma == 0)
        return old;
    
    NSString *before = [old substringWithRange:NSMakeRange(0, last_comma)];
    NSString *after = [old substringWithRange:NSMakeRange(last_comma+2, [old length] - last_comma-2)];
    
    return [NSString stringWithFormat:@"%@, and %@",before,after];
}

-(void) add_center_constraint:(UIView *) v {
    [v setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [v.superview addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:v.superview
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0.0]];
    
    //width constraint
    [v.superview addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:v.superview
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:0
                                                             constant:v.frame.size.width]];
    
    // Height constraint
    [v.superview addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:v.superview
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:0
                                                             constant:v.frame.size.height]];
}

-(void) change_frame:(UIView *) obj x:(float) x_change y:(float) y_change {
    obj.frame = CGRectMake(obj.frame.origin.x + x_change, obj.frame.origin.y + y_change, obj.frame.size.width, obj.frame.size.height);
}
-(void) change_frame_size:(UIView *) obj width:(float) width_change height:(float) height_change {
    
  //  NSLog(@"before height: %f    y: %f",obj.frame.size.height,obj.frame.origin.y);
    
    obj.frame = CGRectMake(obj.frame.origin.x, obj.frame.origin.y, obj.frame.size.width + width_change, obj.frame.size.height + height_change);

   // NSLog(@"after: %f       y: %f",obj.frame.size.height,obj.frame.origin.y);
}

-(NSArray *) nearest_airport:(float) my_lat my_long:(float) my_long {
    NSMutableDictionary *my_query = [self query:[NSString stringWithFormat:@"SELECT cifp_airport_id,ident FROM cifp_airport WHERE deleted != 'yes' ORDER BY distance(my_lat,my_long,'%f','%f') ASC LIMIT 1",my_lat,my_long]];
    NSMutableArray *my_result = [my_query objectForKey:@"result"];
    if([my_result count] > 0) {
        NSMutableArray *row = [my_result objectAtIndex:0];
        return @[[row objectAtIndex:0],[row objectAtIndex:1]];
    }else
        return @[@"",@""];
}

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



//STORED SQLITE3 FUNCTION
#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

static void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    // check that we have four arguments (lat1, lon1, lat2, lon2)
    assert(argc == 4);
    // check that all four arguments are non-null
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }
    // get the four argument values
    double lat1 = sqlite3_value_double(argv[0]);
    double lon1 = sqlite3_value_double(argv[1]);
    double lat2 = sqlite3_value_double(argv[2]);
    double lon2 = sqlite3_value_double(argv[3]);
    // convert lat1 and lat2 into radians now, to avoid doing it twice below
    double lat1rad = DEG2RAD(lat1);
    double lat2rad = DEG2RAD(lat2);
    // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
    // 6378.1 is the approximate radius of the earth in kilometres
    
    //RETURNS KILOMETERS
    //*0.539957 returns NAUTICAL MILES
    
    sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 6378.1 * 0.539957); //NAUTICAL MILES
}
//END STORED SQLITE3 FUNCTION




@end
