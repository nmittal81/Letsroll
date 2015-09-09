//
//  TravelInfo+CoreDataProperties.h
//  Letsroll
//
//  Created by Neha Mittal on 9/9/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TravelInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface TravelInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *destination;
@property (nullable, nonatomic, retain) NSString *travelDate;

@end

NS_ASSUME_NONNULL_END
