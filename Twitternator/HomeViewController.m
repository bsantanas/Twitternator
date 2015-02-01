//
//  HomeViewController.m
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import <TwitterKit/TwitterKit.h>
#import "HomeViewController.h"
#import "SWRevealViewController.h"

@interface HomeViewController ()
@property (strong,nonatomic) NSArray *tweetsArray;
@property (strong,nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, strong) TWTRTweetTableViewCell *prototypeCell;
@property (nonatomic, strong) NSMutableArray *selectedTweets;

@end

@implementation HomeViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self menuNavigationLayout];
    
    [self configureTableView];
    
    [self loginTwitter];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) configureTableView
{
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self.tableView action:@selector(fetchTweets)forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    //self.tableView.allowsSelection = NO;
    [self.tableView registerClass:
     [TWTRTweetTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // Create a single prototype cell for height calculations
    self.prototypeCell = [[TWTRTweetTableViewCell alloc] init];
}

#pragma mark - TableView Delegate Methods

/*-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    TWTRTweet *tweet = [self.tweetsArray objectAtIndex:indexPath.row];
    TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweet];
    [cell addSubview:tweetView];
    
    return cell;
}*/

- (TWTRTweetTableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweetsArray[indexPath.row];
    
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell configureWithTweet:tweet];
  
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tweetsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweetsArray[indexPath.row];
    [self.prototypeCell configureWithTweet:tweet];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected Row");
    [self.selectedTweets addObject:self.tweetsArray[indexPath.row]];
}

#pragma mark - Layout

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

#pragma mark - Twitter API Requests

-(void) loginTwitter
{
    TWTRLogInButton* logInButton =  [TWTRLogInButton
                                     buttonWithLogInCompletion:
                                     ^(TWTRSession* session, NSError* error) {
                                         [self.activityIndicator startAnimating];
                                         logInButton.hidden = YES;
                                         if (session) {
                                             NSLog(@"signed in as %@", [session userName]);
                                             [self fetchTweets];
                                         } else {
                                             NSLog(@"error: %@", [error localizedDescription]);
                                         }
                                     }];
    logInButton.center = self.view.center;
    [self.view addSubview:logInButton];
}

-(void) fetchTweets
{
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
    NSDictionary *params = @{@"id" : @"20", @"count":@"20"};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             if (data) {
                 // handle the response data e.g.
                 NSError *jsonError;
                 NSArray *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                 self.tweetsArray = [TWTRTweet tweetsWithJSONArray:json];
                 NSLog(@"Received %lu tweets",(unsigned long)self.tweetsArray.count);
                 [self.activityIndicator stopAnimating];
                 dispatch_async(dispatch_get_main_queue(), ^{
                  [self.tableView reloadData];
                 });
             }
             else {
                 NSLog(@"Error: %@", connectionError);
                 [self.activityIndicator stopAnimating];
             }
             
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self.activityIndicator stopAnimating];
    }
}


@end
