//
//  ReminderTableViewCell.h
//  Letsroll
//
//  Created by Neha Mittal on 9/10/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReminderTableViewCellDelegate <NSObject>

-(void) addReminderForTraveler;

@end

@interface ReminderTableViewCell : UITableViewCell

@property (weak, nonatomic) id<ReminderTableViewCellDelegate> delegate;
- (IBAction)reminderAction:(id)sender;

@end
