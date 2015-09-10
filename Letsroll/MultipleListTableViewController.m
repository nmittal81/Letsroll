//
//  MultipleListTableViewController.m
//  Letsroll
//
//  Created by Neha Mittal on 9/10/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import "MultipleListTableViewController.h"
#import "PackingListTableViewController.h"
#import "AppDelegate.h"
#import "TravelerInfo.h"

static NSString *reusableCell = @"TravelerCell";

@interface MultipleListTableViewController ()

@property (nonatomic, strong) TravelerInfo *selectedTravelInfo;

@end

@implementation MultipleListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.travelerArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCell forIndexPath:indexPath];
    
    // Configure the cell...
    TravelerInfo *traveler = (TravelerInfo*)[self.travelerArray objectAtIndex:indexPath.row];
    cell.textLabel.text = traveler.user;
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *areYouSureAlert = [UIAlertController alertControllerWithTitle:@"Are you sure" message:@"This will delete this trip and all the packing lists" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:areYouSureAlert animated:YES completion:nil];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
                                 NSManagedObjectContext *context = appdelegate.managedObjectContext;
                                 TravelerInfo *travelerInfo = [self.travelerArray objectAtIndex:indexPath.row];
                                 [context deleteObject:travelerInfo];
                                 NSError *error;
                                 [context save:&error];
                                 if (error == nil) {
                                     [self.travelerArray removeObjectAtIndex:indexPath.row];
                                     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                     [tableView reloadData];
                                 }
                                 
                             }];
        [areYouSureAlert addAction:ok];
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                     self.tableView.editing = NO;
                                     
                                 }];
        [areYouSureAlert addAction:cancel];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.travelerArray count] > 0) {
        self.selectedTravelInfo = [self.travelerArray objectAtIndex:indexPath.row];
        
        [self performSegueWithIdentifier:@"ShowIndividualPackingList" sender:self];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowIndividualPackingList"]) {
        PackingListTableViewController *vc = (PackingListTableViewController*) segue.destinationViewController;
        vc.travelerInfo = self.selectedTravelInfo;
    }
}


@end
