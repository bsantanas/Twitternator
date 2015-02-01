//
//  TweetElementBehavior.h
//  Twitternator
//
//  Created by Bernardo Santana on 1/31/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetElementBehavior : UIDynamicBehavior

- (void)addItem:(id <UIDynamicItem>)item;
- (void)removeItem:(id <UIDynamicItem>)item;

@end
