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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ceiling = CGPointMake(self.view.frame.size.width/2, 0);
    
    self.tweetsArray = [[NSMutableArray alloc] init];
}

- (IBAction)drop:(id)sender {
    [self hangTweet];
}

-(void) hangTweet
{
    if (YES)//has tweets to drop)
    {
        /*TWTRTweet *tweet = [self.tweetsArray lastObject];
         [self.tweetsArray removeLastObject];
         TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweet style:TWTRTweetViewStyleCompact];
         */
        CGRect frame = CGRectMake(100, 50, 200, 50);
        
        UIView *dropView = [[UIView alloc] initWithFrame:frame];
        dropView.backgroundColor = [UIColor greenColor];
        [self.gameView addSubview:dropView];
        
        self.fallingTweet = dropView;
        
        [self.elementBehavior addItem:dropView];
        [self attachTweetToCeiling];
        
    }else{
        //No tweets at the moment
        
    }
}

- (IBAction)grabTweet:(UIPanGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self.gameView];
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self shrinkTweet];
        [self.elementBehavior addItem:self.fallingTweet];
        [self attachTweetToPoint:touchPoint];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGRect hola = self.fallingTweet.frame;
        self.grabBehavior.anchorPoint = touchPoint;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.grabBehavior];
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
        CGRect smallFrame = self.fallingTweet.frame;
        smallFrame.size = TWEET_SMALL;
        self.fallingTweet.frame = smallFrame;
    } completion:^(BOOL finished) {
            [self.animator removeBehavior:self.attachmentToCeiling];
                     }];
    CGRect smallFrame = self.fallingTweet.frame;
    smallFrame.size = TWEET_SMALL;

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
