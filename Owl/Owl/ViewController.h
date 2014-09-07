//
//  ViewController.h
//  Owl
//
//  Created by Jason Scharff on 9/6/14.
//  Copyright (c) 2014 Owl Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;

@end

