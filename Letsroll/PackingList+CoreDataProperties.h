//
//  PackingList+CoreDataProperties.h
//  Letsroll
//
//  Created by Neha Mittal on 9/7/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PackingList.h"

NS_ASSUME_NONNULL_BEGIN

@interface PackingList (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *isPacked;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) TravelInfo *travelInfo;

@end

NS_ASSUME_NONNULL_END
