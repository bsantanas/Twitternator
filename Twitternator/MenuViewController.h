//
//  MenuViewController.h
//  Twitternator
//
//  Created by Bernardo Santana on 1/31/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSManagedObjectContext *context;
@end
