//
//  ViewController.m
//  Letsroll
//
//  Created by Neha Mittal on 9/2/15.
//  Copyright (c) 2015 Neha Mittal. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "ActionSheetPicker.h"

#define GOOGLE_PLACE_API_KEY @"AIzaSyDmX6cnQE2jqvQ4xMEArLWtEJbKXNFUUnM"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *citySelectorTextField;
@property (weak, nonatomic) IBOutlet UITableView *citySelectorTableView;
@property (strong, nonatomic) NSMutableArray *cityDataArray;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) ActionSheetDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISwitch *familySwitch;
@property (weak, nonatomic) UITextField *nameTextField;

- (IBAction)familySwitchChanged:(id)sender;
- (IBAction)submitTravelInfo:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:@"userName"];
    if (userName == nil || [userName isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Let's get started" message:@"Please enter your name" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [userDefaults setObject:self.nameTextField.text forKey:@"userName"];
                                       [userDefaults synchronize];
                                   }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"LoginPlaceholder", @"Login");
             self.nameTextField = textField;
         }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    self.citySelectorTableView.hidden = YES;
    self.navigationItem.title = @"Let's Roll";
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showSavedTrips:)];
    NSArray *actionButtonItems = @[shareItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // Make a new view, or do what you want here
    if (textField == self.dateTextField) {
        self.datePicker = [ActionSheetDatePicker showPickerWithTitle:@"" datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] target:self action:@selector(dateSelected) origin:textField];
        self.datePicker.timeZone = [NSTimeZone systemTimeZone];
        self.citySelectorTableView.hidden = YES;
        return NO;
    }
    return YES;
}

-(void) dateSelected {

    UIDatePicker *datePicker = (UIDatePicker*)self.datePicker.configuredPickerView;
    NSString *dateString = [NSDateFormatter localizedStringFromDate:datePicker.date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    self.dateTextField.text = dateString;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [NSTimer scheduledTimerWithTimeInterval:1.5
                                     target:self
                                   selector:@selector(timerFired:)
                                   userInfo:nil
                                    repeats:NO];
    return YES;
    
    
}

- (void)timerFired:(id)timer {
    NSString *searchQuery = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&type=regions&key=%@", self.citySelectorTextField.text,GOOGLE_PLACE_API_KEY];
    
    searchQuery = [searchQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *url = [[NSURL alloc] initWithString:searchQuery];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        
        NSArray *tempData = [json objectForKey:@"predictions"];
        NSLog(@"Temp data is %@", tempData);
        self.cityDataArray = (NSMutableArray*)tempData;
        self.citySelectorTableView.hidden = NO;
        [self.citySelectorTableView reloadData];
    }];
    
    [task resume];
    
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if( self.cityDataArray == nil || self.cityDataArray.count == 0 ) {
        return 0;
    }
    
    return [self.cityDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self setUpStandardCellInTable:tableView WithIdentifier:@"CityCell"];
    
    if( self.cityDataArray == nil ) {
        return cell;
    }
    
    NSDictionary *dict = self.cityDataArray[indexPath.row];
    
    cell.textLabel.text = dict[@"description"];
    
    return cell;
    
}

- (UITableViewCell *)setUpStandardCellInTable: (UITableView *)tableView WithIdentifier:(NSString *)cellName
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        NSDictionary *dict = [self.cityDataArray objectAtIndex:indexPath.row];
    self.citySelectorTextField.text = dict[@"description"];
    self.citySelectorTableView.hidden = YES;
    [self.citySelectorTextField resignFirstResponder];
    
}

- (IBAction)familySwitchChanged:(id)sender {
}

- (IBAction)submitTravelInfo:(id)sender {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *travelInfo;
    travelInfo = [NSEntityDescription
                  insertNewObjectForEntityForName:@"TravelInfo"
                  inManagedObjectContext:context];
    [travelInfo setValue: self.citySelectorTextField.text forKey:@"destination"];
    [travelInfo setValue: self.dateTextField.text forKey:@"travelDate"];
    [travelInfo setValue: [NSNumber numberWithBool:self.familySwitch.on] forKey:@"travelingAlone"];

    NSError *error;
    [context save:&error];
    if (error) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Unable to save info" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:errorAlert animated:NO completion:nil];
    }
}

- (void) showSavedTrips:(id) sender {
    [self performSegueWithIdentifier:@"showSavedTrips" sender:self];
}
@end
