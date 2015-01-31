//
//  MenuViewController.m
//  Twitternator
//
//  Created by Bernardo Santana on 1/31/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "MenuViewController.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "CoolTweetsCDTVC.h"

@implementation MenuViewController{
    NSArray *menuItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    self.context = appDelegate.managedObjectContext;
    menuItems = @[@"home", @"choose", @"about"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"Show Cool Tweets"]) {
        UINavigationController *nav = [segue destinationViewController];
        CoolTweetsCDTVC *vc = (CoolTweetsCDTVC *)nav.topViewController;
        vc.context = self.context;
    }else {
        NSLog(@"Segue to controller [%@] that does not support passing managedObjectContext", [segue destinationViewController]);
    }
    
}

@end
