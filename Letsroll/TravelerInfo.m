//
//  TravelerInfo.m
//  Letsroll
//
//  Created by Neha Mittal on 9/9/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import "TravelerInfo.h"
#import "TravelInfo.h"

@implementation TravelerInfo

// Insert code here to add functionality to your managed object subclass

-(NSString*) getDestinationName {
   return self.travelInfo.destination;
}

-(NSString*) getTravelDate {
    return self.travelInfo.travelDate;
}

@end
