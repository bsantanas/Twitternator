//
//  HomeViewController.m
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self menuNavigationLayout];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)menuNavigationLayout
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    SWRevealViewController *revealController = [self revealViewController];
    //Swipe gesture of SWRVC overriding other gestures
    //[revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:[self buttonStyle] target:revealController
                                                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
}

-(UIBarButtonItemStyle)buttonStyle
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    return UIBarButtonItemStylePlain;
#else
    return UIBarButtonItemStyleBordered;
#endif
    
}

@end
