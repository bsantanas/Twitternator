//
//  Author+Create.m
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "Author+Create.h"

@implementation Author (Create)

+(Author *)authorWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Author *author = nil;
    
    if ([name length]){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if(!matches || error || [matches count] > 1){
            NSLog(@"Error ocurred executing request for authors");
        } else if ([matches count]){
            author = [matches firstObject];
        }else{
            author = [NSEntityDescription insertNewObjectForEntityForName:@"Author"
                                                  inManagedObjectContext:context];
            author.name = name;
            //still missing author screenName, ID, and imageURL!!
        }

    }
    
    return author;
}


@end
