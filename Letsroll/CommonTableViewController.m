//
//  CommonTableViewController.m
//  Letsroll
//
//  Created by Neha Mittal on 2/6/16.
//  Copyright © 2016 Neha Mittal. All rights reserved.
//

#import "CommonTableViewController.h"
#import "AppDelegate.h"
#import "PackingItemTableViewCell.h"
#import "NewPackingItemTableViewCell.h"
#import "ReminderTableViewCell.h"
#import "ActionSheetDatePicker.h"
#import "PackingList.h"
#import "TravelerInfo.h"
#import "BasicUtility.h"

@interface CommonTableViewController ()

@end

@implementation CommonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPackingList)];
    self.importItem = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(updateViewWithAllItemsForTraveler)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addNewPackingList {
    
    UIAlertController *addOptionsAlertController = [UIAlertController alertControllerWithTitle:@"Would you like to:" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *addNewPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add a new packing list for fellow traveler", @"Add new list") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Let's get started" message:@"Please enter your name" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                       UITextField *t = [alertController.textFields objectAtIndex:0];
                                       [self addNewListFor:t.text];
                                   }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"LoginPlaceholder", @"Login");
         }];
        [alertController addAction:okAction];
        [self.parentViewController presentViewController:alertController animated:YES completion:nil];
        
        
    }];
    [addOptionsAlertController addAction:addNewPackingList];
    
    if (![self.resultsForUserArray containsObject:kitchenList]) {
        
        UIAlertAction *addKitchenPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Want to pack some kitchen supplies", @"Kitchen supplies") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self addNewListFor:kitchenList];
            
        }];
        [addOptionsAlertController addAction:addKitchenPackingList];
    }
    
    if (![self.resultsForUserArray containsObject:misc]) {
        UIAlertAction *addMiscPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Want a reminder for some last minute things to do?", @"Kitchen supplies") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [self addNewListFor:misc];
            
        }];
        [addOptionsAlertController addAction:addMiscPackingList];
    }
    
    if (![self.resultsForUserArray containsObject:destination]) {
        UIAlertAction *addDestPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Want a reminder for stuff to buy when you reach your destination?", @"Kitchen supplies") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [self addNewListFor:destination];
            
        }];
        [addOptionsAlertController addAction:addDestPackingList];
    }
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"No Thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [addOptionsAlertController addAction:doneAction];
    
    [self presentViewController:addOptionsAlertController animated:YES completion:nil];
    
}

- (void) addNewListFor:(NSString*)user {

}

-(void) updateViewWithAllItemsForTraveler {
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
