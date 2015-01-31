//
//  Author+Create.h
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

#import "Author.h"

@interface Author (Create)

+(Author *)authorWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
