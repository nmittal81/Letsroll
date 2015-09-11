//
//  SavedTripsTableViewCell.h
//  Letsroll
//
//  Created by Neha Mittal on 9/11/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedTripsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@end
