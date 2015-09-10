//
//  TravelerInfo.h
//  Letsroll
//
//  Created by Neha Mittal on 9/9/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TravelInfo;

NS_ASSUME_NONNULL_BEGIN

@interface TravelerInfo : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

-(NSString*) getDestinationName;
-(NSString*) getTravelDate;

@end

NS_ASSUME_NONNULL_END

#import "TravelerInfo+CoreDataProperties.h"
