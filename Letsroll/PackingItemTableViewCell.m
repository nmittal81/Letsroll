//
//  PackingItemTableViewCell.m
//  Letsroll
//
//  Created by Neha Mittal on 9/5/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import "PackingItemTableViewCell.h"

@implementation PackingItemTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)itemPacked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(itemPackChangeStatus:)]) {
        [self.delegate itemPackChangeStatus:self.index];
    }
}
@end
