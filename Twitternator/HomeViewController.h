//
//  HomeViewController.h
//  Twitternator
//
//  Created by Bernardo Santana on 1/30/15.
//  Copyright (c) 2015 Bernardo Santana. All rights reserved.
//

/* MenuViewController acts as root controller for principal views in the app.
 * Therefore, the context is passed from view to view through segues
 */

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
@property (strong, nonatomic) NSManagedObjectContext *context;

@end
