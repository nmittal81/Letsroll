//
//  PackingList.h
//  Letsroll
//
//  Created by Neha Mittal on 9/7/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TravelerInfo;

NS_ASSUME_NONNULL_BEGIN

@interface PackingList : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

-(NSArray*) getAllItemsForTraveler:(NSString*)user;
@end

NS_ASSUME_NONNULL_END

#import "PackingList+CoreDataProperties.h"
