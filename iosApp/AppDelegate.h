//
//  AppDelegate.h
//  Aerovie-Lite
//
//  Created by Bryan Heitman on 11/25/13.
//  Copyright (c) 2013 DevStake, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class mySingleton;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    Common *myCommon;
    mySingleton *singletonObject;
    
    //UIBackgroundTaskIdentifier *bgIdent_startup;
    UIBackgroundTaskIdentifier bgIdent;

    NSTimer *timer_bg;
}

@property (strong, nonatomic) UIWindow *window;

@end
