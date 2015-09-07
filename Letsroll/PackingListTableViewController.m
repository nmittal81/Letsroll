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
#import "TravelInfo.h"

@interface PackingListTableViewController () <NewPackingItemTableViewCellDelegate, PackingItemTableViewCellDelegate>
@property (nonatomic, retain) NSMutableArray *packingListArray;

@end

@implementation PackingListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"PackingList"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"travelInfo = %@", self.travelInfo];
    request.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    self.packingListArray = [results mutableCopy];
    
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemsToPackingList:)];
//    NSArray *actionButtonItems = @[shareItem];
//    self.navigationItem.rightBarButtonItems = actionButtonItems;
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
    [packingItem setValue: name forKey:@"name"];
    [packingItem setValue: [NSNumber numberWithBool:NO] forKey:@"isPacked"];
    [packingItem setValue:self.travelInfo forKey:@"travelInfo"];
    
    NSError *error;
    [context save:&error];
    if (error != nil) {
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
    NSManagedObject *matches = [self.packingListArray objectAtIndex:index];
    BOOL isPacked = [[matches valueForKey:@"isPacked"] boolValue];
    
    NSManagedObject *packingItem = [self.packingListArray objectAtIndex:index];
    [packingItem setValue:[NSNumber numberWithBool:!isPacked] forKey:@"isPacked"];
    NSError *error;
    [context save:&error];
    [self.tableView reloadData];
}

@end
