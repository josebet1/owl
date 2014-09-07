//
//  addNetworksViewViewController.m
//  Owl
//
//  Created by Jason Scharff on 9/6/14.
//  Copyright (c) 2014 Owl Group. All rights reserved.
//

#import "addNetworksViewViewController.h"
#import "ENSDK.h"

@interface addNetworksViewViewController ()

@end

@implementation addNetworksViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)addSnapchat:(id)sender
{
    [self performSegueWithIdentifier:@"snapView" sender:self];
}

-(void)setBackground
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OwlBackground.png"]];
    backgroundView.frame = self.view.bounds;
    [[self view] addSubview:backgroundView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackground];
    [self prepNavBar];
    [self.view bringSubviewToFront:self.evernoteButton];
    [self.view bringSubviewToFront:self.snapchatButton];
    [self.view bringSubviewToFront:self.twitterButton];
    
    if([[ENSession sharedSession] isAuthenticated])
    {
        self.evernoteButton.enabled = NO;
    }
    else
    {
        self.evernoteButton.enabled = YES;
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"snapchatLoggedIn"] == true)
    {
        self.snapchatButton.enabled = NO;
    }
    else
    {
        self.snapchatButton.enabled = YES;
    }
    
    
    // Do any additional setup after loading the view.
}

-(void)prepNavBar
{
    
    
    UIColor *color = [self colorWithHexString:@"ffffff"];
    self.navigationController.navigationBar.tintColor = color;
    
    
    
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,
                                    color,NSBackgroundColorAttributeName,[UIFont fontWithName:@"AvenirNext-UltraLight" size:25.0f],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    [self.navigationItem setHidesBackButton:YES];
    
    
    self.navigationController.navigationBar.barTintColor = [self colorWithHexString:@"BD13B1"];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Owl";
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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addEvernote:(id)sender
{
    ENSession *session = [ENSession sharedSession];

    
    [session authenticateWithViewController:self preferRegistration:NO completion:^(NSError *error)
     {
        if(error)
        {
            
        }
        else
        {
            NSLog(@"WOOT");
            self.evernoteButton.enabled = NO;
        }
         
         
         
         
     }];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
