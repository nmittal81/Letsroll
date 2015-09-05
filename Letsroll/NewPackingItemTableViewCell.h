//
//  NewPackingItemTableViewCell.h
//  Letsroll
//
//  Created by Neha Mittal on 9/5/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewPackingItemTableViewCellDelegate <NSObject>

-(void)newItemAddedToPack:(NSString*)name;

@end

@interface NewPackingItemTableViewCell : UITableViewCell
@property (nonatomic, weak) id <NewPackingItemTableViewCellDelegate> delegate;
- (IBAction)addNewItem:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *itemTextField;
@end
