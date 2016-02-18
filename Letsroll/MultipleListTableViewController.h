//
//  MultipleListTableViewController.h
//  Letsroll
//
//  Created by Neha Mittal on 9/10/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTableViewController.h"

@class TravelInfo;

@interface MultipleListTableViewController : CommonTableViewController

@property (nonatomic, strong) TravelInfo *travelInfo;

@end
