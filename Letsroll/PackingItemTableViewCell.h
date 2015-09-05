//
//  PackingItemTableViewCell.h
//  Letsroll
//
//  Created by Neha Mittal on 9/5/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PackingItemTableViewCellDelegate <NSObject>

-(void) itemPackChangeStatus:(NSUInteger)index;

@end

@interface PackingItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemName;

@property (weak, nonatomic) IBOutlet UIButton *itemPackedButton;
@property(weak, nonatomic) id<PackingItemTableViewCellDelegate> delegate;
@property (nonatomic)NSUInteger index;

- (IBAction)itemPacked:(id)sender;

@end
