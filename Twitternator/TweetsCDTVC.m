//
//  TweetsCDTVC.m
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import <TwitterKit/TwitterKit.h>
#import "AppDelegate.h"
#import "TweetsCDTVC.h"
#import "Tweet+Fetch.h"

@implementation TweetsCDTVC

#pragma mark - View Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    self.context = appDelegate.managedObjectContext;
    
    /*[[Twitter sharedInstance] logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        [[[Twitter sharedInstance] APIClient] loadTweetWithID:@"20" completion:^(TWTRTweet *tweet, NSError *error) {
            TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweet style:TWTRTweetViewStyleRegular];
            [self.view addSubview:tweetView];
        }];
    }];*/
    
    [Tweet loadTweetsFromArray:@[@{@"tweetID":@"20",@"text":@"Porfavor, funciona",@"user":@"yo mismo soy"},@{@"tweetID":@"21",@"text":@"hola",@"user":@"yo mismo soy"},@{@"tweetID":@"22",@"text":@"Porfavor, funciona",@"user":@"yo mismo soy"}] intoManagedObjectContext:self.context];
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

@end
