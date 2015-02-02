//
//  HomeViewController.m
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <TwitterKit/TwitterKit.h>
#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "ClassifyTweetViewController.h"
#import "AppDelegate.h"

@interface HomeViewController () <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) TWTRTweetTableViewCell *prototypeCell;
@property (strong, nonatomic) NSMutableArray *selectedTweets;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationDegrees latitude;

@end

@implementation HomeViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.context){
        AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
        self.context = appDelegate.managedObjectContext;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    [self menuNavigationLayout];
    [self configureTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [locationManager startUpdatingLocation];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];
}

-(void) configureTableView
{
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self.tableView action:@selector(fetchUserTweets)forControlEvents:UIControlEventValueChanged];
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


- (TWTRTweetTableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweetsArray[indexPath.row];
    
    if ([self.selectedTweets containsObject:tweet])
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    else
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell configureWithTweet:tweet];
    [cell setTintColor:[UIColor grayColor]];
    
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
    NSLog(@"Selected Row: %lu",(long)indexPath.row);
    
    TWTRTweet *tweet = self.tweetsArray[indexPath.row];
    
    if (![self.selectedTweets containsObject:tweet]){
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedTweets addObject:tweet];
    } else{
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        [self.selectedTweets removeObject:tweet];
    }
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

-(void)displayErrorMessage
{
    UILabel *errorMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    errorMessage.text = @"Sorry, an error occurred! please try again";
    errorMessage.center = self.view.center;
    [self.view addSubview:errorMessage];
}

#pragma mark - Twitter API Requests

- (IBAction)loginTwitterAsUser:(id)sender {
    self.initialLoginScreen.hidden = YES;
    [[Twitter sharedInstance] logInWithCompletion:^
     (TWTRSession *session, NSError *error) {
         if (session) {
             NSLog(@"signed in as %@", [session userName]);
             [self fetchUserTweets];
         } else {
             [self.activityIndicator stopAnimating];
             NSLog(@"error: %@", [error localizedDescription]);
             [self displayErrorMessage];
         }
         
     }];
}


- (IBAction)loginAsGuest:(UIButton *)sender {
    self.initialLoginScreen.hidden = YES;
    [[Twitter sharedInstance] logInGuestWithCompletion:^
     (TWTRGuestSession *session, NSError *error) {
         if (session) {
             [self fetchNearbyTweets];
         } else {
             [self.activityIndicator stopAnimating];
             NSLog(@"error: %@", [error localizedDescription]);
             [self displayErrorMessage];
         }
     }];
}

-(void) fetchUserTweets
{
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
    NSDictionary *params = @{@"count":@"20"};
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
                 NSError *jsonError;
                 NSArray *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                 self.tweetsArray = [[TWTRTweet tweetsWithJSONArray:json] mutableCopy];
                 NSLog(@"Received %lu tweets",(unsigned long)self.tweetsArray.count);
                 [self.activityIndicator stopAnimating];
                 dispatch_async(dispatch_get_main_queue(), ^{
                  [self.tableView reloadData];
                 });
             }
             else {
                 NSLog(@"Error: %@", connectionError);
                 [self displayErrorMessage];
                 [self.activityIndicator stopAnimating];
             }
             
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self displayErrorMessage];
        [self.activityIndicator stopAnimating];
    }
}

-(void) fetchNearbyTweets
{
    NSString *latitudeString = [[NSNumber numberWithDouble:self.latitude] stringValue];
    NSString *logitudeString = [[NSNumber numberWithDouble:self.longitude] stringValue];
    NSString *geoCodeString = [NSString stringWithFormat:@"%@,%@,1km",latitudeString,logitudeString];
    NSString *searchEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *params = @{@"geocode":geoCodeString,@"count":@"20"};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:searchEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             if (data) {
                 NSError *jsonError;
                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:&jsonError];
                 NSArray *statuses = [[NSArray alloc] initWithArray:[json objectForKey:@"statuses"]];
                 self.tweetsArray = [[TWTRTweet tweetsWithJSONArray:statuses] mutableCopy];
                 NSLog(@"Received %lu tweets",(unsigned long)self.tweetsArray.count);
                 [self.activityIndicator stopAnimating];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
             else {
                 NSLog(@"Error: %@", connectionError);
                 [self.activityIndicator stopAnimating];
                 [self displayErrorMessage];
             }
             
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self.activityIndicator stopAnimating];
        [self displayErrorMessage];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    [locationManager stopUpdatingLocation];
    if (currentLocation != nil) {
        self.latitude = currentLocation.coordinate.latitude;
        self.longitude = currentLocation.coordinate.longitude;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"Show Classify"]) {
        ClassifyTweetViewController *vc = [segue destinationViewController];
        vc.context = self.context;
        vc.tweetsArray = self.selectedTweets;
    }
}

#pragma mark - Constructors

-(NSMutableArray *)selectedTweets
{
    if(!_selectedTweets){
        _selectedTweets = [[NSMutableArray alloc] init];
    }
    return _selectedTweets;
}

-(NSMutableArray *)tweetsArray
{
    if(!_tweetsArray){
        _tweetsArray = [[NSMutableArray alloc] init];
    }
    return _tweetsArray;
}

@end
