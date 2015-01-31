//
//  TweetsCDTVC.h
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface TweetsCDTVC : CoreDataTableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *context;

@end
