//
//  PackingListTableViewController.m
//  Letsroll
//
//  Created by Neha Mittal on 9/3/15.
//  Copyright © 2015 Neha Mittal. All rights reserved.
//

#import "PackingListTableViewController.h"
#import "AppDelegate.h"
#import "PackingItemTableViewCell.h"
#import "NewPackingItemTableViewCell.h"
#import "PackingList.h"
#import "TravelerInfo.h"

@interface PackingListTableViewController () <NewPackingItemTableViewCellDelegate, PackingItemTableViewCellDelegate>
@property (nonatomic, retain) NSMutableArray *packingListArray;

@end

@implementation PackingListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPackingList)];
    NSArray *actionButtonItems = @[addItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    [self updateView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateView {
    self.navigationItem.title = self.travelerInfo.user;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"PackingList"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"travelerInfo = %@", self.travelerInfo];
    request.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    self.packingListArray = [results mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
                                       AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                                       NSManagedObjectContext *context = [appDelegate managedObjectContext];
                                       TravelerInfo *travelerInfo = [NSEntityDescription insertNewObjectForEntityForName:@"TravelerInfo" inManagedObjectContext:context];
                                       
                                       travelerInfo.user = [alertController.textFields objectAtIndex:0].text;
                                       travelerInfo.travelInfo = self.travelerInfo.travelInfo;
                                       NSError *error;
                                       if([context save:&error]) {
                                           self.travelerInfo = travelerInfo;
                                           [self updateView];
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
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        TravelerInfo *travelerInfo = [NSEntityDescription insertNewObjectForEntityForName:@"TravelerInfo" inManagedObjectContext:context];
        
        travelerInfo.user = @"Kitchen";
        travelerInfo.travelInfo = self.travelerInfo.travelInfo;
        NSError *error;
        if([context save:&error]) {
            self.travelerInfo = travelerInfo;
            [self updateView];
        }
        
    }];
    [addOptionsAlertController addAction:addKitchenPackingList];
    
    UIAlertAction *addMiscPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Want a reminder for some last minute things to do?", @"Kitchen supplies") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        TravelerInfo *travelerInfo = [NSEntityDescription insertNewObjectForEntityForName:@"TravelerInfo" inManagedObjectContext:context];
        
        travelerInfo.user = @"Misc";
        travelerInfo.travelInfo = self.travelerInfo.travelInfo;
        NSError *error;
        if([context save:&error]) {
            self.travelerInfo = travelerInfo;
            [self updateView];
        }
        
    }];
    [addOptionsAlertController addAction:addMiscPackingList];
    
    UIAlertAction *addDestPackingList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Want a reminder for stuff to buy when you reach your destination?", @"Kitchen supplies") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        TravelerInfo *travelerInfo = [NSEntityDescription insertNewObjectForEntityForName:@"TravelerInfo" inManagedObjectContext:context];
        
        travelerInfo.user = @"Destination";
        travelerInfo.travelInfo = self.travelerInfo.travelInfo;
        NSError *error;
        if([context save:&error]) {
            self.travelerInfo = travelerInfo;
            [self updateView];
        }
        
    }];
    [addOptionsAlertController addAction:addDestPackingList];
    
    [self presentViewController:addOptionsAlertController animated:YES completion:nil];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.packingListArray count]+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.packingListArray count]) {
        PackingItemTableViewCell *packingCell = [tableView dequeueReusableCellWithIdentifier:@"PackingCell" forIndexPath:indexPath];
        NSManagedObject *matches = [self.packingListArray objectAtIndex:indexPath.row];
        packingCell.itemName.text = [matches valueForKey:@"name"];
        BOOL isPacked = [[matches valueForKey:@"isPacked"] boolValue];
        if (isPacked) {
            [packingCell.itemPackedButton setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        } else {
            [packingCell.itemPackedButton setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        }
        packingCell.delegate = self;
        packingCell.index = indexPath.row;
        return packingCell;
    } else {
        NewPackingItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewItem" forIndexPath:indexPath];
        cell.delegate = self;
    
        return cell;
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
        //Do some thing here
        AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appdelegate.managedObjectContext;
        NSManagedObject *obj = [self.packingListArray objectAtIndex:indexPath.row];
        [context deleteObject:obj];
        NSError *error;
        [context save:&error];
        if (error == nil) {
            [self.packingListArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadData];
        }

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark NewPackingItemTableViewCellDelegate methods
-(void)newItemAddedToPack:(NSString*)name {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PackingList *packingItem;
    packingItem = [NSEntityDescription
                  insertNewObjectForEntityForName:@"PackingList"
                  inManagedObjectContext:context];
    packingItem.name = name;
    packingItem.isPacked = [NSNumber numberWithBool:NO];
    packingItem.travelerInfo = self.travelerInfo;
    
    NSError *error;
    if (![context save:&error]) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Unable to save item" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:errorAlert animated:YES completion:nil];
        return;
    }
    [self.packingListArray addObject:packingItem]; //repository is a NSMutableArray
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.packingListArray indexOfObject:packingItem] inSection:0];
    [self.tableView beginUpdates];
    [self.tableView
     insertRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
}

#pragma mark PackingItemTableViewCellDelegate
-(void) itemPackChangeStatus:(NSUInteger)index {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    PackingList *packingItem = [self.packingListArray objectAtIndex:index];
    BOOL isPacked = [packingItem.isPacked boolValue];
    packingItem.isPacked = [NSNumber numberWithBool:!isPacked];
    
    NSError *error;
    if (![context save:&error]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to change status" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:NO completion:nil];
        return;
    }
    [self.tableView reloadData];
}

@end
