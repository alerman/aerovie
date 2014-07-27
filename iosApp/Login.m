//
//  Login.m
//  Aerovie
//
//  Created by Bryan Heitman on 5/1/13.
//  Copyright (c) 2013 Bryan Heitman. All rights reserved.
//

#import "Login.h"

@interface Login ()

@end

@implementation Login

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
    [self didRotateFromInterfaceOrientation:self];

    
                       
    create_account = false;
    
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(main_tap:)];
    [self.view addGestureRecognizer:g];

    
    
    UITapGestureRecognizer *g2 = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self action:@selector(open_website:)];
    [_label_2 addGestureRecognizer:g2];
    UITapGestureRecognizer *g3 = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self action:@selector(open_website:)];
    [_image_link addGestureRecognizer:g3];

    
    _login_button.layer.cornerRadius = 5.0;

    if([mySession objectForKey:@"session_id"]) {
        NSString *last_auth_date = [mySession objectForKey:@"last_api_auth_check"];
        float time_diff = [[NSDate date  ]timeIntervalSinceReferenceDate] - [last_auth_date floatValue];
        if(time_diff < 60*86400) {
            //SUPER AUTO LOGIN
            
            if(IS_DEBUG) NSLog(@"SUPER AUTOLOGIN!!!!!!! time_diff: %f NAME: %@ FACEBOOK_IDENT: %@ TWITTER_IDENT: %@",time_diff,[mySession objectForKey:@"name"],[mySession objectForKey:@"facebook"],[mySession objectForKey:@"twitter"]);
            
            NSTimer *delay_timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(delay_super_autologin:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:delay_timer forMode:NSDefaultRunLoopMode];
            
        }else{
            NSLog(@"login_push TRYING BASIC AUTO_LOGIN");
            
            NSMutableDictionary *requestData = [[ NSMutableDictionary alloc] init];
            [requestData setObject:@"check_auth" forKey:@"request" ];
            [requestData setObject:[mySession objectForKey:@"session_id"] forKey:@"session_id" ];
            [requestData setObject:@"check_auth_auto" forKey:@"connection_description" ];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(myNotification:)
                                                         name:[requestData objectForKey:@"connection_description"] object:nil];
            
            [myCommon apiRequest:requestData];
        }
    }

}
-(void) delay_super_autologin:(NSTimer *) timer {
    //may fail if network unavailable.
    [mySession removeObjectForKey:@"sync_lock"];

    [myCommon db_sync];
    [self performSegueWithIdentifier:@"login_segue" sender:self];
}

-(IBAction)main_tap:(id)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) create_real_account  {
    //checks here and return
    if([my_username.text isEqualToString:@""]) {
        [myCommon doAlert:@"Enter a username."];
        return;
    }
    if([my_password.text isEqualToString:@""]) {
        [myCommon doAlert:@"Enter a password."];
        return;
    }
    if([my_first.text isEqualToString:@""]) {
        [myCommon doAlert:@"Enter a first name."];
        return;
    }
    if([my_last.text isEqualToString:@""]) {
        [myCommon doAlert:@"Enter a last name."];
        return;
    }
    if(![my_password.text isEqualToString:my_password2.text]) {
        [myCommon doAlert:@"Passwords do not match."];
        my_password.text = @"";
        my_password2.text = @"";
        return;
    }
    
    NSMutableDictionary *requestData = [[ NSMutableDictionary alloc] init];
    [requestData setObject:@"create_account" forKey:@"request" ];
    [requestData setObject:my_username.text forKey:@"user" ];
    [requestData setObject:my_password.text forKey:@"password" ];
    [requestData setObject:my_first.text forKey:@"first_name" ];
    [requestData setObject:my_last.text forKey:@"last_name" ];
    [requestData setObject:@"create_account" forKey:@"connection_description" ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotification:)
                                                 name:[requestData objectForKey:@"connection_description"] object:nil];
    
    [myCommon apiRequest:requestData];
}

- (IBAction)login_push:(id)sender {
    [self.view endEditing:YES];

    if(create_account) {
        [self create_real_account];
        return;
    }
    
    if(IS_DEBUG) NSLog(@"login_push read_session: %@",[mySession objectForKey:@"read_session"]);
    
    NSMutableDictionary *requestData = [[ NSMutableDictionary alloc] init];
    [requestData setObject:@"check_auth" forKey:@"request" ];
    [requestData setObject:my_username.text forKey:@"user" ];
    [requestData setObject:my_password.text forKey:@"password" ];
    [requestData setObject:@"check_auth" forKey:@"connection_description" ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotification:)
                                                 name:[requestData objectForKey:@"connection_description"] object:nil];
    
    [myCommon apiRequest:requestData];
}

- (void)myNotification:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    
    if(IS_DEBUG) NSLog(@"NOTIFY !!!!!! name: %@",notification.name);
    
    if([notification.name isEqual:@"check_auth_auto"]) {
        if(IS_DEBUG) NSLog(@"CHECK AUTH AUTO");
        if([[notification.userInfo objectForKey:@"auth"] isEqualToString:@"1"]) {
            if(IS_DEBUG) NSLog(@"AUTO LOGIN!!!");
            

            [self do_final_login:[notification.userInfo objectForKey:@"session_id"] name:[notification.userInfo objectForKey:@"name"] facebook:[notification.userInfo objectForKey:@"facebook_ident"] twitter:[notification.userInfo objectForKey:@"twitter_ident"] pilot:[notification.userInfo objectForKey:@"pilot"]];
        }else{
        }
    }else if([notification.name isEqual:@"check_auth"]) {
        if(IS_DEBUG) NSLog(@"notification check_auth auth: %@",[notification.userInfo objectForKey:@"auth"]);
        
        if([[notification.userInfo objectForKey:@"auth"] isEqualToString:@"1"]) {
            [self do_final_login:[notification.userInfo objectForKey:@"session_id"] name:[notification.userInfo objectForKey:@"name"] facebook:[notification.userInfo objectForKey:@"facebook_ident"] twitter:[notification.userInfo objectForKey:@"twitter_ident"] pilot:[notification.userInfo objectForKey:@"pilot"]];
        }else{
            [myCommon doAlert:@"Authentication failed, enter a valid username & password."];
        }
    }else if([notification.name isEqual:@"check_auth_social"]) {
        if(IS_DEBUG) NSLog(@"notification check_auth social auth: %@",[notification.userInfo objectForKey:@"auth"]);
        
        if([[notification.userInfo objectForKey:@"auth"] isEqualToString:@"1"]) {
            [self do_final_login:[notification.userInfo objectForKey:@"session_id"] name:[notification.userInfo objectForKey:@"name"] facebook:[notification.userInfo objectForKey:@"facebook_ident"] twitter:[notification.userInfo objectForKey:@"twitter_ident"] pilot:[notification.userInfo objectForKey:@"pilot"]];
        }else{
            [myCommon doAlert:@"Authentication social failed, enter a valid username & password."];
        }
    }else if([notification.name isEqual:@"create_account"]) {
            if(IS_DEBUG) NSLog(@"notification create_account auth: %@ name: %@",[notification.userInfo objectForKey:@"auth"],[notification.userInfo objectForKey:@"name"]);
            
            if([[notification.userInfo objectForKey:@"auth"] isEqualToString:@"1"]) {
                [self do_final_login:[notification.userInfo objectForKey:@"session_id"] name:[notification.userInfo objectForKey:@"name"] facebook:[notification.userInfo objectForKey:@"facebook_ident"] twitter:[notification.userInfo objectForKey:@"twitter_ident"] pilot:[notification.userInfo objectForKey:@"pilot"]];
            }else{
                [myCommon doAlert:[NSString stringWithFormat:@"Error creating account: %@",[notification.userInfo objectForKey:@"error"]]];
            }
    }
}

-(void) do_final_login:(NSString *) session_id name:(NSString *) name facebook:(NSString *) facebook twitter:(NSString *) twitter pilot:(NSString *) pilot {
    
    if(name && ![name isEqualToString:@""]) {
        [mySession setObject:name forKey:@"name"];
    }
    if(pilot && ![pilot isEqualToString:@""]) {
        [mySession setObject:pilot forKey:@"pilot"];
    }
    
    if(session_id && ![session_id isEqualToString:@""])
        [mySession setObject:session_id forKey:@"session_id"];

    if(twitter && ![twitter isEqualToString:@""])
        [mySession setObject:twitter forKey:@"twitter"];
    else
        [mySession setObject:@"" forKey:@"twitter"];
    
    if(facebook && ![facebook isEqualToString:@""])
        [mySession setObject:facebook forKey:@"facebook"];
    else
        [mySession setObject:@"" forKey:@"facebook"];
    
    //FOR SUPER AUTO LOGIN
    NSString *last_date = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    [mySession setObject:last_date forKey:@"last_api_auth_check"];
    

    [myCommon writeSession];
    
    [mySession removeObjectForKey:@"sync_lock"];
    [myCommon db_sync];
    [self performSegueWithIdentifier:@"login_segue" sender:self];
}


- (IBAction)create_account:(id)sender {
    if(create_account == false) {
        create_account = true;


        //NSLog(@"table before height: %f y: %f",_table_login.frame.size.height,_table_login.frame.origin.y);
        [_table_login reloadData];
    


        CGSize screen = self.view.bounds.size;

        big_view_bg = [[UIView alloc] init];
        big_view_bg.frame = CGRectMake(0, 0, screen.width, screen.height);
        big_view_bg.backgroundColor = [UIColor colorWithRed:69/255.0 green:80/255.0 blue:82/255.0 alpha:1];
        big_view_bg.alpha = 0.5;

        big_view = [[UIView alloc] init];
        big_view.clipsToBounds = true;

        NSInteger vertical_offset = 50;
        NSInteger box_height = 300;
        if(singletonObject->is_iphone) {
            vertical_offset = 20;
            box_height = screen.height - vertical_offset*2;
        }
        
        

        if(IS_IPHONE)
            big_view.frame = CGRectMake((screen.width/2)-(320/2), vertical_offset, 320, box_height);
        else
            big_view.frame = CGRectMake((screen.width/2)-250, vertical_offset, 500, box_height);
        big_view.layer.cornerRadius = 5;
        big_view.backgroundColor = [UIColor colorWithRed:208/255.0 green:218/255.0 blue:220/255.0 alpha:1];

        UIView *line = [[UIView alloc] init];
        line.frame = CGRectMake(0, 30, 900, 1);
        line.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        
        UIButton *b1 = [[UIButton alloc] init];
        [b1 setTitle: @"Cancel" forState:UIControlStateNormal];
        b1.frame = CGRectMake(0, 5, 75, 25);
        [b1 setTitleColor:[UIColor colorWithRed:1/255.0 green:112/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
        b1.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];

        
        UILabel *l = [[UILabel alloc] init];
        l.text = @"Create Account";
        
        [l setFont:[UIFont fontWithName:@"Helvetica Neue" size:10.0f]];
        l.textColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
        l.frame = CGRectMake(big_view.frame.size.width/2-45, 5, 90, 25);

        
        UIButton *b2 = [[UIButton alloc] init];
        [b2 setImage:[UIImage imageNamed:@"btn_create-account.png"] forState:UIControlStateNormal];
        [b2 setImage:[UIImage imageNamed:@"btn_create-account_active.png"] forState:UIControlStateHighlighted];
        b2.frame = CGRectMake((big_view.frame.size.width/2)-75, big_view.frame.size.height - 20 - 30, 175, 31);
        [b2 setTitleColor:[UIColor colorWithRed:1/255.0 green:112/255.0 blue:184/255.0 alpha:1] forState:UIControlStateNormal];
        
        
        
        UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(create_account:)];
        [b1 addGestureRecognizer:g];
        
        UITapGestureRecognizer *g2 = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(create_real_account)];
        [b2 addGestureRecognizer:g2];
 
        
        
        
        [big_view addSubview:line];
        [big_view addSubview:b1];
        [big_view addSubview:b2];
        [self.view addSubview:big_view_bg];
        [self.view addSubview:big_view];

        
        [self.view bringSubviewToFront:_table_login];
        
        

        if(singletonObject->is_iphone)
            _table_login.frame = CGRectMake(big_view.frame.origin.x+10, big_view.frame.origin.y+45, big_view.frame.size.width-20, big_view.frame.size.height-50-50);
        else
            _table_login.frame = CGRectMake(big_view.frame.origin.x+20, big_view.frame.origin.y+50, big_view.frame.size.width-40, big_view.frame.size.height-50-65);
        
        
    }else{
        if(singletonObject->is_iphone) {
            if(singletonObject->portrait)
                _table_login.frame = CGRectMake(10, 27, 298, 77);
            else
                _table_login.frame = CGRectMake(80, 27, 405, 77);
        }else{
            if(singletonObject->portrait)
                _table_login.frame = CGRectMake(292-122, 203, 405, 77);
            else
                _table_login.frame = CGRectMake(292, 203, 405, 77);
        }
        
        [big_view removeFromSuperview];
        [big_view_bg removeFromSuperview];

        if(IS_DEBUG) NSLog(@"TURN OFF CREATE_ACCOUNT");
        create_account = false;
        
        [_table_login reloadData];
        
    }
}

- (IBAction)facebook_login:(id)sender {
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
                [self facebook_complete:[my_array objectAtIndex:0]];
            }else if(granted == YES || [error code]== ACErrorAccountNotFound) {
                [myCommon doAlert:@"No facebook accounts configured."];
                if(IS_DEBUG) NSLog(@"No facebook accounts configured.");
            }else{
                NSLog(@"fb not granted %@",[error localizedDescription]);
            }
        });}
    ];
}

-(void) facebook_complete:(ACAccount *) facebook {
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
}

- (IBAction)social_push:(NSString *) ident user:(NSString *) user name:(NSString *) name type:(NSString *) type {
    [self.view endEditing:YES];
    
    if(create_account) {
        [self create_real_account];
        return;
    }
    
    NSLog(@"my session name: %@",[mySession objectForKey:@"name"]);

    if(![mySession objectForKey:@"name"] && [name isEqualToString:@""]) {
        alert_name = [[UIAlertView alloc] initWithTitle:@"Enter Your Name" message:@"This name will be used when sharing reports." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Cancel", nil];
        alert_name.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert_name show];
        
        alert_name.restorationIdentifier = [NSString stringWithFormat:@"%@||%@||%@",ident,user,type];

        return;
    }
    
    if(IS_DEBUG) NSLog(@"social_push read_session: %@",[mySession objectForKey:@"read_session"]);
    
    NSMutableDictionary *requestData = [[ NSMutableDictionary alloc] init];
    [requestData setObject:@"check_auth_social" forKey:@"request" ];
    [requestData setObject:ident forKey:@"user" ];
    [requestData setObject:user forKey:@"social_user" ];
    [requestData setObject:name forKey:@"social_name" ];
    [requestData setObject:type forKey:@"social_type" ];
    [requestData setObject:@"check_auth_social" forKey:@"connection_description" ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotification:)
                                                 name:[requestData objectForKey:@"connection_description"] object:nil];
    
    [myCommon apiRequest:requestData];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        if(alertView == alert_name) {
            NSArray *arr = [alert_name.restorationIdentifier componentsSeparatedByString:@"||"];
            [self social_push:[arr objectAtIndex:0] user:[arr objectAtIndex:1] name:[[alertView textFieldAtIndex:0] text] type:[arr objectAtIndex:2]];
        }
    }
}



- (IBAction)twitter_login:(id)sender {

    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted,NSError *error) {
        NSArray *my_array = [account accountsWithAccountType:accountType];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted == YES && [my_array count] > 0) {
                [self twitter_complete:[my_array objectAtIndex:0]];
            }else if([error code]== ACErrorAccountNotFound || granted == YES) {
                if(IS_DEBUG) NSLog(@"twitter no accounts configured");
                [myCommon doAlert:@"No twitter accounts configured."];
            }else{
                NSLog(@"not granted %@",[error localizedDescription]);
            }
        });
    }
    ];
}
-(void) twitter_complete:(ACAccount *) twitter {
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


- (IBAction)text_cancel:(id)sender {
    [sender resignFirstResponder];
}






- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(create_account)
        return 5;
    else
        return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"my_cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITextField *myString = (UITextField *)[cell viewWithTag:1];
    
    UITextField *myString2 = (UITextField *)[cell viewWithTag:2];
    myString2.secureTextEntry = NO;

    if([indexPath row] == 0) {
        myString.text = @"User Name or Email";
        my_username = myString2;
        myString2.placeholder = @"Enter your username";
        
    }else if([indexPath row] == 1) {
        myString.text = @"Password";
        myString2.secureTextEntry = YES;
        my_password = myString2;
        myString2.placeholder = @"Enter password here";
    }else if([indexPath row] == 2) {
        myString.text = @"Confirm Password";
        myString2.secureTextEntry = YES;
        my_password2 = myString2;
        myString2.placeholder = @"Re-enter password here";
    }else if([indexPath row] == 3) {
        myString.text = @"First Name";
        my_first = myString2;
        myString2.placeholder = @"Enter first name here";
    }else if([indexPath row] == 4) {
        myString.text = @"Last Name";
        my_last = myString2;
        myString2.placeholder = @"Enter last name here";
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

//did rotate...


-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    
/*    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    
    NSLog(@"LOGIN screenWidth: %f screenHeight: %f is_iphone: %i",screenWidth,screenHeight,singletonObject->is_iphone);
  */
    
    //    if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait) {
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        singletonObject->portrait = true;
        //SET PORTRAIT STUFF HERE
        
      //NSLog(@"DID ROTATE STUFF PORT");
    }else{
        //NSLog(@"DID ROTATE STUFF LANDS");
        singletonObject->portrait = false;
    }
    [self set_orientation];
}

-(void) set_orientation {
    if(singletonObject->is_iphone) {
        if(create_account)
            [self create_account:nil];
        
       // NSLog(@"LOGIN.M BASE ORIENTATION SET");
        if(singletonObject->portrait == true) {
          //  NSLog(@"LOGIN.M IPHONE SET ORIENTATION HERE  PORTRAIT");
            set_portrait = true;

            _table_login.frame = CGRectMake(10, 27, 298, 77);
            
          //  [myCommon change_frame:big_view x:-123 y:0];
           // [myCommon change_frame_size:big_view_bg width:-256 height:256];
            [myCommon change_frame:_image_link x:-123 y:0];

//            [myCommon change_frame:_table_login x:-67 y:0];
//            [myCommon change_frame_size:_table_login width:-110 height:0];
            [myCommon change_frame:_button_login x:-45 y:0];
            [myCommon change_frame_size:_button_login width:-158 height:0];

            [myCommon change_frame:_button_twitter x:59 y:0];
            [myCommon change_frame:_button_facebook x:-120 y:38];
            [myCommon change_frame:_create_account_button x:-302 y:75];

            [myCommon change_frame:_label_1 x:-92 y:75];
            [myCommon change_frame:_label_2 x:-110 y:100];
            [myCommon change_frame:_image_link x:10 y:100];

            
//            _image_background.image = [UIImage imageNamed:@"login-background_portrait.png"];
  //          _image_background.frame = CGRectMake(0, 0, 768, 1024);

        }else if(set_portrait == true) {
            set_portrait = false;
          // NSLog(@"LOGIN.M IPHONE SET ORIENTATION HERE  LANDSCAPE");

            _table_login.frame = CGRectMake(80, 27, 405, 77);

//            [myCommon change_frame:big_view x:123 y:0];
//            [myCommon change_frame_size:big_view_bg width:256 height:-256];
            [myCommon change_frame:_image_link x:123 y:0];
            
//            [myCommon change_frame:_table_login x:67 y:0];
//            [myCommon change_frame_size:_table_login width:110 height:0];
            [myCommon change_frame:_button_login x:45 y:0];
            [myCommon change_frame_size:_button_login width:158 height:0];
            
            [myCommon change_frame:_button_twitter x:-59 y:0];
            [myCommon change_frame:_button_facebook x:120 y:-38];
            [myCommon change_frame:_create_account_button x:302 y:-75];
            
            [myCommon change_frame:_label_1 x:92 y:-75];
            [myCommon change_frame:_label_2 x:110 y:-100];
            [myCommon change_frame:_image_link x:-10 y:-100];



        }
    }else{
        if(singletonObject->portrait == true) {
            set_portrait = true;
//            NSLog(@"SET IPAD ORIENTATION PORTRAIT");
            [myCommon change_frame:_button_facebook x:-123 y:0];
            [myCommon change_frame:_create_account_button x:-123 y:0];
            [myCommon change_frame:big_view x:-123 y:0];
            [myCommon change_frame_size:big_view_bg width:-256 height:256];
            [myCommon change_frame:_image_link x:-123 y:0];
        
            _image_background.image = [UIImage imageNamed:@"login-background_portrait.png"];
            _image_background.frame = CGRectMake(0, 0, 768, 1024);
        }else if(set_portrait == true) {
          //  NSLog(@"SET IPAD ORIENTATION LANDSCAPE");
            set_portrait = false;
            [myCommon change_frame:_button_facebook x:123 y:0];
            [myCommon change_frame:_create_account_button x:123 y:0];
            [myCommon change_frame:big_view x:123 y:0];
            [myCommon change_frame:_image_link x:123 y:0];
            [myCommon change_frame_size:big_view_bg width:256 height:-256];
        
            _image_background.image = [UIImage imageNamed:@"login-background.png"];
            _image_background.frame = CGRectMake(0, 0, 1024 , 768);
        }
    }
}





- (BOOL)shouldAutorotate {
    NSLog(@"SHOULD AUTOROTATE");
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(!IS_IPHONE_4)
//    if(!IS_IPHONE)
        return YES;

    NSLog(@"IPHONE 4 HERE!!!!!!!");
    if (orientation==UIInterfaceOrientationPortrait) {
        // do some sh!t
        return YES;
    }else{
        
        return NO;
    }
}
-(NSUInteger)supportedInterfaceOrientations{
    NSLog(@"SUPPORTED AUTOROTATE");
    
    if(!IS_IPHONE_4)
//    if(!IS_IPHONE)
        return UIInterfaceOrientationMaskAllButUpsideDown;
    else
        return UIInterfaceOrientationMaskPortrait;
}
-(void) open_website:(UIGestureRecognizer *) g {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.aerovie.com"]];    
}


//FB FRAMEWORK
/*
 singletonObject->fb_session = [[FBSession alloc] initWithAppID:@"253946971422441" permissions:nil defaultAudience:FBSessionDefaultAudienceEveryone urlSchemeSuffix:@"lite" tokenCacheStrategy:nil];
 
 if (singletonObject->fb_session.isOpen) {
 NSLog(@"fb is already open");
 }else{
 [singletonObject->fb_session openWithCompletionHandler:^(FBSession *session,
 FBSessionState status,
 NSError *error) {
 [self fb_updateView];
 
 }];
 }
 
 - (void)fb_updateView {
 // get the app delegate, so that we can reference the session property
 if (singletonObject->fb_session.isOpen) {
 // valid account UI is shown whenever the session is open
 NSLog(@"FB SESSION IS OPEN");
 [self fb_name];
 } else {
 // login-needed account UI is shown whenever the session is closed
 NSLog(@"FB SESSION IS NOT OPEN DO SOMETHING ELSE HERE");
 //        [self.buttonLoginLogout setTitle:@"Log in" forState:UIControlStateNormal];
 //      [self.textNoteOrLink setText:@"Login to create a link to fetch account data"];
 }
 }
 -(void) fb_name {
 //   [singletonObject->fb_session setActiveSession:self.fb];
 [FBSession setActiveSession:singletonObject->fb_session];
 [FBRequestConnection startWithGraphPath:@"/me"
 parameters:[NSDictionary dictionaryWithObject:@"name,picture,id,birthday,email,location,hometown" forKey:@"fields"]
 
 HTTPMethod:@"GET"
 completionHandler:^(
 FBRequestConnection *connection,
 NSDictionary* result,
 NSError *error
 ) {
for(NSString *my_key in result) {
    NSLog(@"result key: %@ data: %@",my_key,[result objectForKey:my_key]);
}
//                              NSLog(@"result is here %@ %i",connection.urlResponse,result);
}];
}
*/

@end
