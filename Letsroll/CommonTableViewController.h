//
//  CommonTableViewController.h
//  Letsroll
//
//  Created by Neha Mittal on 2/6/16.
//  Copyright © 2016 Neha Mittal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonTableViewController : UITableViewController

@property (nonatomic, strong) UIBarButtonItem *addItem;
@property (nonatomic, strong) UIBarButtonItem *importItem;
@property (nonatomic, strong) NSArray *resultsForUserArray;
@property (nonatomic, strong) NSString *userInfo;

@end
