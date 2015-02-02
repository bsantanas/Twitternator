//
//  AboutViewController.m
//  Twitternator
//
//  Created by Bernardo Santana on 2/1/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "AboutViewController.h"
#import "SWRevealViewController.h"

@implementation AboutViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarLayout];
    
}
- (IBAction)goToTWTRProfile:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/bsantanas"]];
}

-(void)navigationBarLayout
{
    SWRevealViewController *revealController = [self revealViewController];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1.0];    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
}



@end
