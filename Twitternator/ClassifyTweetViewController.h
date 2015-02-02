//
//  ClassifyTweetViewController.h
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ClassifyTweetViewController : UIViewController
{
    SystemSoundID PlayCoinID;
    SystemSoundID PlayChimeID;
    SystemSoundID PlayChime_UpID;
    SystemSoundID PlayBoxingBellID;
    SystemSoundID PlayBooID;
    SystemSoundID PlayBoom_XID;
    SystemSoundID PlayBoing_PoingID;
}
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UIView *coolBasket;
@property (weak, nonatomic) IBOutlet UIView *boringBasket;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (weak, nonatomic) IBOutlet UILabel *centralLabel;
@end
