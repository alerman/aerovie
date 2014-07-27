//
//  Login.h
//  Aerovie
//
//  Created by Bryan Heitman on 5/1/13.
//  Copyright (c) 2013 Bryan Heitman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>


@class mySingleton;

@interface Login : UIViewController {
    UITextField *my_username;
    UITextField *my_password;
    UITextField *my_password2;
    UITextField *my_first;
    UITextField *my_last;

    Common *myCommon;
    mySingleton *singletonObject;
    
    BOOL create_account;
    
    UIView *big_view_bg;
    UIView *big_view;

//    CGRect table_orig;
    
    BOOL set_portrait;
    
    UIAlertView *alert_name;
}

@property (weak, nonatomic) IBOutlet UILabel *label_1;

@property (weak, nonatomic) IBOutlet UILabel *label_2;
@property (weak, nonatomic) IBOutlet UIImageView *image_background;

@property (weak, nonatomic) IBOutlet UIButton *button_login;

@property (weak, nonatomic) IBOutlet UIButton *login_button;

@property (weak, nonatomic) IBOutlet UITableView *table_login;


@property (weak, nonatomic) IBOutlet UIButton *create_account_button;
@property (weak, nonatomic) IBOutlet UIButton *button_facebook;
@property (weak, nonatomic) IBOutlet UIButton *button_twitter;

@property (weak, nonatomic) IBOutlet UIImageView *image_link;

@end
