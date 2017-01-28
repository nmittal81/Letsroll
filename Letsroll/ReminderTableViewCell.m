//
//  ReminderTableViewCell.m
//  Letsroll
//
//  Created by Neha Mittal on 9/10/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import "ReminderTableViewCell.h"

@implementation ReminderTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)reminderAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addReminderForTraveler)]) {
        [self.delegate addReminderForTraveler];
    }
}
@end
