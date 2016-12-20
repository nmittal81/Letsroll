//
//  NewPackingItemTableViewCell.m
//  Letsroll
//
//  Created by Neha Mittal on 9/5/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import "NewPackingItemTableViewCell.h"

@implementation NewPackingItemTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addNewItem:(id)sender {
    if ([self.delegate respondsToSelector:@selector(newItemAddedToPack:)]) {
        [self.delegate newItemAddedToPack:self.itemTextField.text];
        self.itemTextField.text = @"";
    }
}
@end
