//
//  ViewController.m
//  Owl
//
//  Created by Jason Scharff on 9/6/14.
//  Copyright (c) 2014 Owl Group. All rights reserved.
//

#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"



@interface ViewController ()
@property (nonatomic, assign) BOOL switched;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepNavBar];
    [self setFBLogIn];
    [self setBackground];
    [self.view bringSubviewToFront:self.header];
    [self.view bringSubviewToFront:self.logInButton];
    [self.header setTextColor:[self colorWithHexString:@"e8e8e8"]];
    [self.logInButton setTitleColor:[self colorWithHexString:@"e8e8e8"] forState:UIControlStateNormal];
    
    [self.logInButton.layer setBorderWidth:1.0];
    UIColor *borderColor = [self colorWithHexString:@"42DA6F"];
    [[self.logInButton layer] setBorderColor:borderColor.CGColor];
    self.logInButton.layer.cornerRadius = 8;
    
    
   

    
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)setBackground
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OwlBackground.png"]];
    backgroundView.frame = self.view.bounds;
    [[self view] addSubview:backgroundView];
}


-(void)prepNavBar
{
    
    UIColor *color = [self colorWithHexString:@"ffffff"];
    self.navigationController.navigationBar.tintColor = color;
    
    
    
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,
                                    color,NSBackgroundColorAttributeName,[UIFont fontWithName:@"AvenirNext-UltraLight" size:25.0f],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    
    
    self.navigationController.navigationBar.barTintColor = [self colorWithHexString:@"BD13B1"];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Owl";
}






-(void)setFBLogIn
{
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email", @"user_friends", @"user_likes", @"publish_actions"]];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                
                if (access_token == appDelegate.session.accessTokenData.accessToken)
                {
                    self.switched = YES;
                    [self performSegueWithIdentifier:@"signup" sender:self];
                }
                [self updateView];
            }];
        }
    }

}




- (void)updateView {
    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        [FBSession setActiveSession:appDelegate.session];
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 
                 //NSLog(@"%@", result);
                 [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"id"] forKey:@"id"];
                 [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"first_name"] forKey:@"first_name"];
                 [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"last_name"] forKey:@"last_name"];
                 [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"email"] forKey:@"email"];
                 [[NSUserDefaults standardUserDefaults] setObject: appDelegate.session.accessTokenData.accessToken forKey:@"token"];
                 
                 
                 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                 NSDictionary *parameters = @{@"fb_id": [result objectForKey:@"id"], @"access_token": appDelegate.session.accessTokenData.accessToken};
                 [manager POST:@"http://owl.joseb.me/register_user.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSLog(@"JSON: %@", responseObject);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error: %@", error);
                 }];

                 
                 
                 
                 
                 [self performSegueWithIdentifier:@"addNetworks" sender:self];
            
             }
         }];
        
        
        
    } else {
        NSLog(@"session is not open");
    }
}

- (IBAction)buttonClickHandler:(id)sender {
    // get the app delegate so that we can access the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // this button's job is to flip-flop the session from open to closed
    if (appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [appDelegate.session closeAndClearTokenInformation];
        
    } else {
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            [self updateView];
        }];
    }
}





-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
