//
//  TweetsCDTVC.m
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "SWRevealViewController.h"
#import "CoolTweetsCDTVC.h"
#import "Tweet+Fetch.h"

@implementation CoolTweetsCDTVC

#pragma mark - View Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self navigationBarLayout];
    
    //[Tweet loadTweetsFromArray:@[@{@"tweetID":@"20",@"text":@"Porfavor, funciona",@"user":@"yo mismo soy"},@{@"tweetID":@"21",@"text":@"hola",@"user":@"yo mismo soy"},@{@"tweetID":@"22",@"text":@"Porfavor, funciona",@"user":@"yo mismo soy"}] intoManagedObjectContext:self.context];
    [self.context save:NULL];

}

#pragma mark - CoreData functionality

-(void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"tweetID" ascending:YES selector:@selector(localizedStandardCompare:)]];
    request.fetchLimit = 100;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Table View Data Source


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Tweet Cell"];
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = tweet.text;
    
    return cell;
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
