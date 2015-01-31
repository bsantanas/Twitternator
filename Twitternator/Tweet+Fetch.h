//
//  Tweet+Fetch.h
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (Fetch)

+(Tweet *)tweetFromDictionary:(NSDictionary *)tweetDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+(void) loadTweetsFromArray:(NSArray *)array intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
