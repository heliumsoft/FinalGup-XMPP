//
//  PrivacyPolicy.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/14/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "PrivacyPolicy.h"

@interface PrivacyPolicy ()

@end

@implementation PrivacyPolicy

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Privacy Policy";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
