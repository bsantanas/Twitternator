//
//  Tweet+Fetch.m
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "Tweet+Fetch.h"
#import "Author+Create.h"

@implementation Tweet (Fetch)

+(Tweet *)tweetFromDictionary:(NSDictionary *)tweetDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tweet *tweet = nil;
    
    NSString *unique = [tweetDictionary valueForKey:@"tweetID"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.predicate = [NSPredicate predicateWithFormat:@"tweetID = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || error || [matches count] > 1){
        NSLog(@"Error executing request for tweets");
    } else if ([matches count]){
        tweet = [matches firstObject];
    }else{
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet"
                                              inManagedObjectContext:context];
        tweet.tweetID =unique;
        tweet.text = [tweetDictionary valueForKey:@"text"];
        //NSDate *date;// =
        //tweet.createdAt = date;
        tweet.whoTweeted = [Author authorWithName:[tweetDictionary valueForKey:@"user"] inManagedObjectContext:context];
        
    }
    
    return tweet;
}

+(void)loadTweetsFromArray:(NSArray *)tweetArray intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *tweetDictionary in tweetArray) {
        [self tweetFromDictionary:tweetDictionary inManagedObjectContext:context];
    }

}

@end
