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
#import "TravelInfo.h"
#import "BasicUtility.h"

static NSString *reusableCell = @"TravelerCell";

@interface MultipleListTableViewController ()

@property (nonatomic, strong) TravelerInfo *selectedTravelInfo;
@property (nonatomic, strong) NSMutableArray *resultsForTravelArray;
@property (nonatomic, strong) NSMutableArray *resultsForUserArray;
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
    NSString *travelDestination = self.travelInfo.destination;
    NSRange range = [travelDestination rangeOfString:@","];
    if (range.location != NSNotFound)
    {
        //range.location is start of substring
        //range.length is length of substring
        travelDestination = [travelDestination substringToIndex:range.location];
    }
    
    self.navigationItem.title = travelDestination;
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateResults];
}

- (void) updateResults {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:travelerEntity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"travelInfo = %@", self.travelInfo];
    request.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    self.resultsForTravelArray = [results mutableCopy];
    self.resultsForUserArray = [[results valueForKey:@"user"] mutableCopy];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
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
    travelerInfo.travelInfo = self.travelInfo;
    travelerInfo.user = user;
    [self.resultsForUserArray addObject:user];
    NSError *error;
    if([context save:&error]) {
        self.selectedTravelInfo = travelerInfo;
        [self performSegueWithIdentifier:@"ShowIndividualPackingList" sender:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultsForUserArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCell forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.resultsForUserArray objectAtIndex:indexPath.row] capitalizedString];
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
                                 TravelerInfo *travelerInfo = [self.resultsForTravelArray objectAtIndex:indexPath.row];
                                 [context deleteObject:travelerInfo];
                                 NSError *error;
                                 if ([context save:&error]) {
                                     [self updateResults];
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
    if ([self.resultsForTravelArray count] > 0) {
        self.selectedTravelInfo = [self.resultsForTravelArray objectAtIndex:indexPath.row];
        
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
        vc.resultsForUserArray = self.resultsForUserArray;
    }
}


@end
