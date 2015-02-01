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

@interface ClassifyTweetViewController ()
{
    CGPoint ceiling;
}
@property (weak, nonatomic) IBOutlet UIView *gameView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) TweetElementBehavior *elementBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentToCeiling;
@property (strong, nonatomic) UIAttachmentBehavior *grabBehavior;
@property (strong, nonatomic) UIView *fallingTweet;
@end

@implementation ClassifyTweetViewController

static const CGSize TWEET_SMALL = { 40, 40 };
static const int RADIUS = 50;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ceiling = CGPointMake(self.view.frame.size.width/2, 0);
}

- (IBAction)grabTweet:(UIPanGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self.gameView];
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self shrinkTweet];
        [self attachTweetToPoint:touchPoint];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        self.grabBehavior.anchorPoint = touchPoint;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.grabBehavior];
        [self checkIfDeposited];
    }
}

-(void) attachTweetToPoint: (CGPoint)touchPoint
{
    if(self.fallingTweet){
        self.grabBehavior = [[UIAttachmentBehavior alloc]initWithItem:self.fallingTweet attachedToAnchor:touchPoint];
        [self.animator addBehavior:self.grabBehavior];
    }
}

-(void) attachTweetToCeiling
{
    if(self.fallingTweet){
        self.attachmentToCeiling = [[UIAttachmentBehavior alloc]initWithItem:self.fallingTweet attachedToAnchor:ceiling];
        [self.animator addBehavior:self.attachmentToCeiling];
    }
}

-(void) shrinkTweet
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect smallFrame = self.fallingTweet.bounds;
        smallFrame.size = TWEET_SMALL;
        self.fallingTweet.bounds = smallFrame;
    } completion:^(BOOL finished) {
            [self.animator removeBehavior:self.attachmentToCeiling];
                     }];

}

- (IBAction)drop:(id)sender {
    [self hangTweet];
}

-(void) hangTweet
{
    if ([self.tweetsArray count])//has tweets to drop)
    {
        CGRect frame = CGRectMake(100, 50, 100, 50);
        
        TWTRTweetView *dropView = [[TWTRTweetView alloc] initWithTweet:self.tweetsArray.firstObject];
        dropView.frame = frame;
        dropView.backgroundColor = [UIColor greenColor];
        [self.gameView addSubview:dropView];
        
        self.fallingTweet = dropView;
        
        [self.elementBehavior addItem:dropView];
        [self attachTweetToCeiling];
        
    }else{
        //No tweets at the moment
        
    }
}

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
    }
    return _animator;
}

-(void)checkIfDeposited
{
    
    if([self distanceBetweet:self.coolBasket.center and:self.fallingTweet.center] < RADIUS){
        [Tweet tweetInstanceFromTWTRTweet:self.tweetsArray.firstObject inManagedObjectContext:self.context];
    }else if([self distanceBetweet:self.boringBasket.center and:self.fallingTweet.center] < RADIUS){
        [self.elementBehavior removeItem:self.fallingTweet];
        [self.fallingTweet removeFromSuperview];
        if([self.tweetsArray count])
            [self.tweetsArray removeObjectAtIndex:0];
    }
}

-(float) distanceBetweet:(CGPoint)point1 and: (CGPoint)point2
{
    float xDist = pow(point1.x - point2.x,2);
    float yDist = pow(point1.y - point2.y,2);
    return sqrt(xDist + yDist);
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
