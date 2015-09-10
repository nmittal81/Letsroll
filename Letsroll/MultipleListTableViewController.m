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
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPackingList)];
    NSArray *actionButtonItems = @[addItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addNewPackingList {
    TravelerInfo *firstTravelerInfo = (TravelerInfo*)[self.travelerArray objectAtIndex:0];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    TravelerInfo *travelerInfo = [NSEntityDescription insertNewObjectForEntityForName:@"TravelerInfo" inManagedObjectContext:context];
    travelerInfo.travelInfo = firstTravelerInfo.travelInfo;
    
    
    UIAlertController *addOptionsAlertController = [UIAlertController alertControllerWithTitle:@"Would you like to:" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *addNewPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add a new packing list for fellow traveler", @"Add new list") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Let's get started" message:@"Please enter your name" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       travelerInfo.user = [alertController.textFields objectAtIndex:0].text;
                                       NSError *error;
                                       if([context save:&error]) {
                                           self.selectedTravelInfo = travelerInfo;
                                           [self performSegueWithIdentifier:@"ShowIndividualPackingList" sender:self];
                                       }
                                   }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"LoginPlaceholder", @"Login");
         }];
        [alertController addAction:okAction];
        [self.parentViewController presentViewController:alertController animated:YES completion:nil];
        
        
    }];
    [addOptionsAlertController addAction:addNewPackingList];
    
    UIAlertAction *addKitchenPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Want to pack some kitchen supplies", @"Kitchen supplies") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        travelerInfo.user = @"Kitchen";
        NSError *error;
        if([context save:&error]) {
            self.selectedTravelInfo = travelerInfo;
            [self performSegueWithIdentifier:@"ShowIndividualPackingList" sender:self];
        }
        
    }];
    [addOptionsAlertController addAction:addKitchenPackingList];
    
    UIAlertAction *addMiscPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Want a reminder for some last minute things to do?", @"Kitchen supplies") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        travelerInfo.user = @"Misc";
        NSError *error;
        if([context save:&error]) {
            self.selectedTravelInfo = travelerInfo;
            [self performSegueWithIdentifier:@"ShowIndividualPackingList" sender:self];
        }
        
    }];
    [addOptionsAlertController addAction:addMiscPackingList];
    
    UIAlertAction *addDestPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Want a reminder for stuff to buy when you reach your destination?", @"Kitchen supplies") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        travelerInfo.user = @"Destination";
        NSError *error;
        if([context save:&error]) {
            self.selectedTravelInfo = travelerInfo;
            [self performSegueWithIdentifier:@"ShowIndividualPackingList" sender:self];
        }
        
    }];
    [addOptionsAlertController addAction:addDestPackingList];
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"No Thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [addOptionsAlertController addAction:doneAction];
    
    [self presentViewController:addOptionsAlertController animated:YES completion:nil];
    
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
