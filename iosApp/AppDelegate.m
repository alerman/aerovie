//
//  AppDelegate.m
//  Aerovie-Lite
//
//  Created by Bryan Heitman on 11/25/13.
//  Copyright (c) 2013 DevStake, LLC. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

//    bgIdent = UIBackgroundTaskInvalid;
    
    
    singletonObject = [mySingleton sharedInstance];
    myCommon = [[Common alloc] init];
    
    [myCommon readSession];

    //enter background processing
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground) {// || state == UIApplicationStateInactive) {
        NSLog(@"started up in background, why???");
    }else{
        NSLog(@"STARTED UP IN FOREGROUND");
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"will resign active (background)");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"did enter background remaining");
    
    
    if([singletonObject set_background_mode]) {
        if(bgIdent != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:bgIdent];
        
        bgIdent = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ NSLog(@"beginBackgroundTaskWithExpirationHandler() ABOUT_TO_EXPIRE!!!!! background"); }];

        [timer_bg invalidate];
        timer_bg = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timer_bg:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer_bg forMode:NSDefaultRunLoopMode];
    }
}
-(void) timer_bg:(NSTimer *) t {
    NSLog(@"timer_bg loop");
    [myCommon db_sync];
    if(![singletonObject set_background_mode]) {
        [timer_bg invalidate];
        NSLog(@"END BACKGROUND TASK");
        
        [[UIApplication sharedApplication] endBackgroundTask:bgIdent];
        bgIdent = UIBackgroundTaskInvalid;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"entering foreground ");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"app became active");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"application terminating (background)");

}

/*
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"########### Received Background Fetch ###########");
    //Download  the Content .
    
    [myCommon db_sync];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       // Check result of your operation and call completion block with the result
                       if([myCommon set_background_mode]) {
                           NSLog(@"COMPLETION HANDLER NEW DATA");

                           completionHandler(UIBackgroundFetchResultNewData);
                       }else{
                           NSLog(@"COMPLETION HANDLER NO DATA");

                           completionHandler(UIBackgroundFetchResultNoData);
                       }
    });
    //Cleanup
}
*/



@end
