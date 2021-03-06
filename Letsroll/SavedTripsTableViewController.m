//
//  SavedTripsTableViewController.m
//  Letsroll
//
//  Created by Neha Mittal on 9/3/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import "SavedTripsTableViewController.h"
#import "AppDelegate.h"
#import "MultipleListTableViewController.h"
#import "SavedTripsTableViewCell.h"
#import "TravelInfo.h"

@interface SavedTripsTableViewController ()
@property (nonatomic, retain) NSMutableArray *resultsArray;
@property (nonatomic, retain) NSMutableArray *resultsForTravelArray;
@property (nonatomic, strong) TravelInfo *selectedTravelInfo;
@end

@implementation SavedTripsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"TravelInfo"];
    
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    self.resultsArray = [results mutableCopy];
    
    if (error == nil) {
        
        //Deal with failure
    }
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
    return (self.resultsArray).count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SavedTripsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travelInfo" forIndexPath:indexPath];
    
    // Configure the cell...
    TravelInfo *travelInfo = (self.resultsArray)[indexPath.row];
    cell.destinationLabel.text = travelInfo.destination;
    cell.dateLabel.text = travelInfo.travelDate;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((self.resultsArray).count > 0) {
        self.selectedTravelInfo = (self.resultsArray)[indexPath.row];
        [self performSegueWithIdentifier:@"ShowMultipleLists" sender:self];
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        UIAlertController *areYouSureAlert = [UIAlertController alertControllerWithTitle:@"Are you sure" message:@"This will delete this trip and all the packing lists" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:areYouSureAlert animated:YES completion:nil];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                 NSManagedObjectContext *context = appdelegate.managedObjectContext;
                                 NSManagedObject *obj = (self.resultsArray)[indexPath.row];
                                 [context deleteObject:obj];
                                 NSError *error;
                                 if ([context save:&error]) {
                                     [self.resultsArray removeObjectAtIndex:indexPath.row];
                                     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                     __block SavedTripsTableViewController *weakSelf = self;
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [weakSelf.tableView reloadData];
                                    });
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
//
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
        if ([segue.identifier isEqualToString:@"ShowMultipleLists"]) {
            MultipleListTableViewController *vc = (MultipleListTableViewController*) segue.destinationViewController;
            vc.travelInfo = self.selectedTravelInfo;
        }
}


@end
