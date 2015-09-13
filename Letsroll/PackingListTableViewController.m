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
#import "ReminderTableViewCell.h"
#import "ActionSheetDatePicker.h"
#import "PackingList.h"
#import "TravelerInfo.h"
#import "BasicUtility.h"

static NSString *reminderCell = @"ReminderCell";
static NSString *packingCell = @"PackingCell";
static NSString *newItemCell = @"NewItem";


@interface PackingListTableViewController () <NewPackingItemTableViewCellDelegate, PackingItemTableViewCellDelegate, ReminderTableViewCellDelegate>

@property (nonatomic, retain) NSMutableArray *packingListArray;
@property (strong, nonatomic) ActionSheetDatePicker *datePicker;
@property (strong, nonatomic) ReminderTableViewCell *reminderTableCell;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

-(void) scheduleLocalNotification:(NSDate*)date;

@end

@implementation PackingListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPackingList)];
    UIBarButtonItem * importItem = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(updateViewWithAllItemsForTraveler)];
    
    NSArray *actionButtonItems = @[addItem, importItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    [self updateView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateView {
    self.navigationItem.title = [self.travelerInfo.user capitalizedString];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:packingEntity];
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
                                       
                                       [self addNewListFor:[alertController.textFields objectAtIndex:0].text];
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
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    TravelerInfo *travelerInfo = [NSEntityDescription insertNewObjectForEntityForName:travelerEntity inManagedObjectContext:context];
    travelerInfo.travelInfo = self.travelerInfo.travelInfo;
    travelerInfo.user = user;
    NSError *error;
    if([context save:&error]) {
        self.travelerInfo = travelerInfo;
        [self updateView];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.packingListArray count] > 0) {
        return [self.packingListArray count] + 2;
    }
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.packingListArray count]) {
        PackingItemTableViewCell *packingItemCell = [tableView dequeueReusableCellWithIdentifier:packingCell forIndexPath:indexPath];
        NSManagedObject *matches = [self.packingListArray objectAtIndex:indexPath.row];
        packingItemCell.itemName.text = [matches valueForKey:@"name"];
        BOOL isPacked = [[matches valueForKey:@"isPacked"] boolValue];
        if (isPacked) {
            [packingItemCell.itemPackedButton setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        } else {
            [packingItemCell.itemPackedButton setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        }
        packingItemCell.delegate = self;
        packingItemCell.index = indexPath.row;
        return packingItemCell;
    } else if (indexPath.row == [self.packingListArray count])  {
        NewPackingItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:newItemCell forIndexPath:indexPath];
        cell.delegate = self;
    
        return cell;
    } else {
        ReminderTableViewCell *reminderTableCell = [tableView dequeueReusableCellWithIdentifier:reminderCell forIndexPath:indexPath];
        reminderTableCell.delegate = self;
        if (self.travelerInfo.reminderDate != nil ) {
            [reminderTableCell.reminderButton setTitle:[self.dateFormatter stringFromDate:self.travelerInfo.reminderDate] forState:UIControlStateNormal];
        }

        self.reminderTableCell = reminderTableCell;
        return reminderTableCell;
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
                  insertNewObjectForEntityForName:packingEntity
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark ReminderTableViewCellDelegate

-(void) addReminderForTraveler {
    
    self.datePicker = [ActionSheetDatePicker showPickerWithTitle:@"" datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] target:self action:@selector(dateSelected) origin:self.reminderTableCell];
    self.datePicker.timeZone = [NSTimeZone systemTimeZone];
    
    
}

-(void) dateSelected {
    
    UIDatePicker *datePicker = (UIDatePicker*)self.datePicker.configuredPickerView;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    self.travelerInfo.reminderDate = datePicker.date;
    NSError *error;
    if (![context save:&error]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to change status" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:NO completion:nil];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.reminderTableCell.reminderButton setTitle:[self.dateFormatter stringFromDate:datePicker.date] forState:UIControlStateNormal];
    });
    [self scheduleLocalNotification:datePicker.date];
    
}

-(void) scheduleLocalNotification:(NSDate*)date {
    //Check to see if same notification exists
    
    NSString *alertBody = [NSString stringWithFormat:@"%@ traveling to %@ on %@", self.travelerInfo.user, [self.travelerInfo getDestinationName], [self.travelerInfo getTravelDate]];
    
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (id localN in notifications) {
        UILocalNotification *tempNotification = (UILocalNotification*)localN;
        if ([tempNotification.alertBody isEqualToString:alertBody]) {
            [[UIApplication sharedApplication] cancelLocalNotification:tempNotification];
        }
        
    }
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = date;
    
#ifdef DEBUG
    NSLog(alertBody);
#endif
    
    localNotification.alertBody = alertBody;
    localNotification.alertAction = @"Let's check";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


-(void) updateViewWithAllItemsForTraveler {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:travelerEntity inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"user = %@", self.travelerInfo.user];
    request.predicate = searchFilter;
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    NSEntityDescription *entity1 = [NSEntityDescription entityForName:packingEntity inManagedObjectContext:context];
    [request setEntity:entity1];
    
    NSPredicate *searchFilter1 = [NSPredicate predicateWithFormat:@"travelerInfo in %@", results];
    request.predicate = searchFilter1;
    NSError *error1 = nil;
    NSArray *results1 = [context executeFetchRequest:request error:&error1];
    self.packingListArray = [[NSMutableArray alloc] init];
    
    for (PackingList *pack in results1) {
        for (PackingList *pack1 in self.packingListArray) {
            if ([pack1.name isEqualToString:pack.name]) {
                return;
            }
        }

        PackingList *packingItem;
        packingItem = [NSEntityDescription
                       insertNewObjectForEntityForName:packingEntity
                       inManagedObjectContext:context];
        packingItem.name = pack.name;
        packingItem.isPacked = [NSNumber numberWithBool:NO];
        packingItem.travelerInfo = self.travelerInfo;
        
        NSError *error;
        if (![context save:&error]) {
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Unable to save item" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:errorAlert animated:YES completion:nil];
            return;
        }
        [self.packingListArray addObject:packingItem];
    }
    if ([self.packingListArray count] == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry no data found for traveler" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
