//
//  PackingListTableViewController.h
//  Letsroll
//
//  Created by Neha Mittal on 9/3/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTableViewController.h"

@class TravelerInfo;

@interface PackingListTableViewController : CommonTableViewController
@property (nonatomic, strong) TravelerInfo *travelerInfo;

@end
