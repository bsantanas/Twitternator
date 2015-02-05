//
//  ClassifyTweetViewController.m
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "ClassifyTweetViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TweetElementBehavior.h"
#import "Tweet+Fetch.h"

@interface ClassifyTweetViewController () <UIDynamicAnimatorDelegate>
{
    CGPoint ceiling;
}
@property (weak, nonatomic) IBOutlet UIView *gameView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) TweetElementBehavior *elementBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentToCeiling;
@property (strong, nonatomic) UIAttachmentBehavior *grabBehavior;
@property (strong, nonatomic) NSMutableArray *fallenTweets;
@property (strong, nonatomic) UIView *hangingTweet;
@property (strong, nonatomic) UIView *fallingTweet;
@end

@implementation ClassifyTweetViewController

static const CGSize TWEET_SMALL = { 40, 40 };
static const CGSize BIG_SQUARE = { 60, 60 };
static const CGRect TWEET_FRAME = { 100, 100, 250, 100 };
static const int RADIUS = 50;


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.tweetsArray  = [@[@1,@1,@1] mutableCopy]; //uncomment for tests
    
    ceiling = CGPointMake(self.view.frame.size.width/2, 0);
    [self hangTweet];
    
    [self configureAudioFiles];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

#pragma mark - Actions

-(void) hangTweet
{
    if ([self.tweetsArray count])//has tweets to drop)
    {
        
        TWTRTweetView *dropView = [[TWTRTweetView alloc] initWithTweet:self.tweetsArray.firstObject];
        //UIView *dropView = [[UIView alloc] initWithFrame:TWEET_FRAME]; //toggle for tests
        dropView.backgroundColor  = [UIColor blueColor];
        
        dropView.frame = TWEET_FRAME;
        [self.gameView addSubview:dropView];
        
        self.hangingTweet = dropView;
        
        [self.elementBehavior addItem:dropView];
        [self attachTweetToCeiling];
        
    }
}


- (IBAction)grabTweet:(UIPanGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self.gameView];
    if (sender.state == UIGestureRecognizerStateBegan) {
        if([self distanceBetweet:touchPoint and:self.hangingTweet.center]< RADIUS){ //grab a new tweet
            [self.tweetsArray removeObjectAtIndex:0];
            [self detachAndShrinkTweet:touchPoint];}
        else if([self distanceBetweet:touchPoint and:self.fallingTweet.center]< RADIUS) //grab a tweet from the bottom
            [self attachTweetToPoint:touchPoint];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        self.grabBehavior.anchorPoint = touchPoint;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.fallingTweet)
            [self.fallenTweets addObject:self.fallingTweet];
        [self.animator removeBehavior:self.grabBehavior];
        [self checkIfDeposited];
    }
}

#pragma mark - Complimentary Animations


-(void) detachAndShrinkTweet: (CGPoint) touchPoint
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect smallFrame = self.hangingTweet.bounds;
        smallFrame.size = TWEET_SMALL;
        self.hangingTweet.bounds = smallFrame;
    } completion:^(BOOL finished) {
        [self.hangingTweet removeFromSuperview];
        [self.elementBehavior removeItem:self.hangingTweet];
        UIView *dropView = [[UIView alloc] init];
        dropView.backgroundColor  = [UIColor whiteColor];
        CGRect rect = self.hangingTweet.frame;
        rect.size = TWEET_SMALL;
        dropView.frame = rect;
        [self.gameView addSubview:dropView];
        self.fallingTweet = dropView;
        [self.elementBehavior addItem:dropView];
        [self attachTweetToPoint:touchPoint];
        
        [self.animator removeBehavior:self.attachmentToCeiling];
        if([self.tweetsArray count]){
           [self hangTweet];
        }else{
            if(![self.tweetsArray count]){
                self.centralLabel.text = @"Good Job!";
                self.centralLabel.textColor = [UIColor whiteColor];
            }

        }
    }];
    
}

-(void) dissolveFallingTweet
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect bigFrame = self.fallingTweet.bounds;
        bigFrame.size = BIG_SQUARE;
        self.fallingTweet.bounds = bigFrame;
        self.fallingTweet.alpha = 0;
    } completion:^(BOOL finished) {
        [self.elementBehavior removeItem:self.fallingTweet];
        [self.fallingTweet removeFromSuperview];
        self.fallingTweet = nil;
    }];
}

-(void)removeFallenTweets
{
    if ([self.fallenTweets count]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.gameView.backgroundColor = [UIColor redColor];
            for (UIView *tweet in self.fallenTweets) {
                [self.elementBehavior removeItem:tweet];
                int x = (arc4random()%(int)(self.gameView.bounds.size.width*5)) - (int)self.gameView.bounds.size.width*2;
                int y = self.gameView.bounds.size.height;
                tweet.center = CGPointMake(x, -y);
            }
        }completion:^(BOOL finished) {
            [self.fallenTweets makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.gameView.backgroundColor = [UIColor colorWithRed:22/255 green:21/255 blue:100/255 alpha:1];
        }];
    }
    
}

-(NSMutableArray *) fallenTweets
{
    if (!_fallenTweets){
        _fallenTweets = [[NSMutableArray alloc] init];
    }
    return _fallenTweets;
}

#pragma mark - Behaviours and Animators

- (TweetElementBehavior *)elementBehavior
{
    if (!_elementBehavior) {
        _elementBehavior = [[TweetElementBehavior alloc] init];
        [self.animator addBehavior:_elementBehavior];
    }
    return _elementBehavior;
}

-(UIDynamicAnimator *) animator
{
    if (!_animator){
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.gameView];
        _animator.delegate = self;
    }
    return _animator;
}

-(IBAction)boomButton:(id)sender
{
    [self removeFallenTweets];
    AudioServicesPlaySystemSound(PlayBoom_XID);
}

-(void) attachTweetToPoint: (CGPoint)touchPoint
{
    if(self.fallingTweet){
        self.grabBehavior = [[UIAttachmentBehavior alloc]initWithItem:self.fallingTweet attachedToAnchor:touchPoint];
        [self.grabBehavior setDamping:0.8];
        [self.grabBehavior setFrequency:2];
        
        [self.animator addBehavior:self.grabBehavior];
    }
}

-(void) attachTweetToCeiling
{
    if(self.hangingTweet){
        UIOffset offset = UIOffsetMake(2, 0);
        self.attachmentToCeiling = [[UIAttachmentBehavior alloc]initWithItem:self.hangingTweet offsetFromCenter:offset attachedToAnchor:ceiling];
        
        [self.animator addBehavior:self.attachmentToCeiling];
    }
}

#pragma mark - Heart of the Selection View

-(void)checkIfDeposited
{
    //if cool selected
    if([self distanceBetweet:self.coolBasket.center and:self.fallingTweet.center] < RADIUS){
        
        [Tweet tweetInstanceFromTWTRTweet:self.tweetsArray.firstObject inManagedObjectContext:self.context];
        [self.context save:NULL];
        [self playRandomCoolSound];
        [self dissolveFallingTweet];
        
        //if boring selected
    }else if([self distanceBetweet:self.boringBasket.center and:self.fallingTweet.center] < RADIUS){
        
        [self playRandomCoolSound];
        [self dissolveFallingTweet];
        
    }
}

-(float) distanceBetweet:(CGPoint)point1 and: (CGPoint)point2
{
    float xDist = pow(point1.x - point2.x,2);
    float yDist = pow(point1.y - point2.y,2);
    return sqrt(xDist + yDist);
}


#pragma mark - Audio File Management

-(void)playRandomCoolSound
{
    switch (arc4random()%3) {
        case 0:
            AudioServicesPlaySystemSound(PlayCoinID);
            break;
        case 1:
            AudioServicesPlaySystemSound(PlayChime_UpID);
            break;
        case 2:
            AudioServicesPlaySystemSound(PlayChimeID);
            break;
    }
}

-(void)playRandomBadSound
{
    switch (arc4random()%3) {
        case 0:
            AudioServicesPlaySystemSound(PlayBoing_PoingID);
            break;
        case 1:
            AudioServicesPlaySystemSound(PlayBooID);
            break;
        case 2:
            AudioServicesPlaySystemSound(PlayBoxingBellID);
            break;
    }
}

-(void) configureAudioFiles
{
    NSURL *soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"boing_poing" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &PlayBoing_PoingID);
    soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"boo" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &PlayBooID);
    soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"boom_x" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &PlayBoom_XID);
    soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"boxing_bell" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &PlayBoxingBellID);
    soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"chime_up" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &PlayChime_UpID);
    soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"chime" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &PlayChimeID);
    soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"coin" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &PlayCoinID);
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
