//
//  LetsRollViewController.m
//  Letsroll
//
//  Created by Neha Mittal on 9/2/15.
//  Copyright (c) 2015 Neha Mittal. All rights reserved.
//

#import "LetsRollViewController.h"
#import "AppDelegate.h"
#import "ActionSheetPicker.h"
#import "PackingListTableViewController.h"
#import "TravelInfo.h"
#import "TravelerInfo.h"
#import "BasicUtility.h"

#define GOOGLE_PLACE_API_KEY @"AIzaSyBTq4B-NOGVwYLo2q1cGyPUtgUeuzdN55Q"

static NSString *showSavedTrips = @"showSavedTrips";
static NSString *showPackingList = @"showPacking";
static NSString *userFromUserDefaults = @"userName";

@interface LetsRollViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *citySelectorTextField;
@property (weak, nonatomic) IBOutlet UITableView *citySelectorTableView;
@property (strong, nonatomic) NSMutableArray *cityDataArray;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) ActionSheetDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISwitch *familySwitch;
@property (weak, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) NSTimer *textTimer;
@property (strong, nonatomic) TravelerInfo *travelerInfo;
- (IBAction)familySwitchChanged:(id)sender;
- (IBAction)submitTravelInfo:(id)sender;

@end

@implementation LetsRollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:userFromUserDefaults];
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
             textField.placeholder = NSLocalizedString(@"", @"Login");
             self.nameTextField = textField;
         }];
        [alertController addAction:okAction];
        [self.parentViewController presentViewController:alertController animated:YES completion:nil];
    }
    self.citySelectorTableView.hidden = YES;
    self.navigationItem.title = @"Let's Roll";
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showSavedTrips:)];
    NSArray *actionButtonItems = @[shareItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
//    [self solution:@[@0,@3,@3,@7,@5,@3,@11,@1]];
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

//Once we detect user has stopped typing any further we fire the backend api and get back results

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.textTimer) {
        [self.textTimer invalidate];
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        self.cityDataArray = nil;
        self.citySelectorTableView.hidden = YES;
    }
    
    self.textTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                     target:self
                                   selector:@selector(timerFired:)
                                   userInfo:nil
                                    repeats:NO];
    return YES;
    
    
}

- (void)timerFired:(id)timer {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.view addSubview: self.activityIndicatorView];
    
    [self.activityIndicatorView startAnimating];
    NSString *searchQuery =  [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&type=regions&key=%@", self.citySelectorTextField.text,GOOGLE_PLACE_API_KEY];
    
    searchQuery = [searchQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *url = [[NSURL alloc] initWithString:searchQuery];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //We are getting back all the countries using this api, so we need to filter out from the reeturned array a smaller set and display it to the user
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        
        NSArray *tempData = [json objectForKey:@"predictions"];
                self.cityDataArray = (NSMutableArray*)tempData;
#ifdef DEBUG
        NSLog(@"Temp data is %@", self.cityDataArray);
#endif
       
        __block LetsRollViewController *weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.cityDataArray count] == 0) {
                UIAlertController *noCityAlert = [UIAlertController alertControllerWithTitle:@"No city found" message:@"Try your search again" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [weakSelf.activityIndicatorView stopAnimating];
                    weakSelf.citySelectorTextField.text = @"";
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }];
                [noCityAlert addAction:okAction];
                [weakSelf presentViewController:noCityAlert animated:YES completion:nil];
            } else {
                [weakSelf.citySelectorTableView reloadData];
               
            }
        });
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
    
    self.citySelectorTableView.hidden = NO;
    
    if (self.activityIndicatorView) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }
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
    TravelInfo *travelInfo = [NSEntityDescription
                  insertNewObjectForEntityForName:travelEntity
                  inManagedObjectContext:context];
    travelInfo.destination = self.citySelectorTextField.text;
    travelInfo.travelDate = self.dateTextField.text;
    
    self.travelerInfo = [NSEntityDescription insertNewObjectForEntityForName:travelerEntity inManagedObjectContext:context];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultUserName = [userDefaults objectForKey:userFromUserDefaults];
    if (defaultUserName == nil || [defaultUserName isEqualToString:@""]) {
        defaultUserName = @"Guest";
    }
    self.travelerInfo.user = defaultUserName;
    

    NSError *error;
    @synchronized(self) {
        if (![context save:&error]) {
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Unable to save info" message:error.description preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:errorAlert animated:NO completion:nil];
        } else {
            self.travelerInfo.travelInfo = travelInfo;
            NSError *error;
            if (![context save:&error]) {
                return;
            }
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            __block NSDate *detectedDate;
            
            //Detect.
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllTypes error:nil];
            [detector enumerateMatchesInString:travelInfo.travelDate
                                       options:kNilOptions
                                         range:NSMakeRange(0, [travelInfo.travelDate length])
                                    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
            { detectedDate = result.date; }];
            
            localNotification.fireDate = detectedDate;
            localNotification.alertBody = @"Ready to leave, make sure everything is packed up";
            localNotification.alertAction = @"Let's check";
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            
            [self performSegueWithIdentifier:showPackingList sender:self];
        }
    }
}

- (void) showSavedTrips:(id) sender {
    [self performSegueWithIdentifier:showSavedTrips sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showPackingList]) {
        PackingListTableViewController *vc = (PackingListTableViewController*) segue.destinationViewController;
        vc.travelerInfo = self.travelerInfo;
        
    }
}

//Some test coding i undertook

//-(int) solution:(NSString *) s {
//    NSArray *prefixArray = [self getPrefixArray:s];
//    NSArray *suffixArray = [self getSuffixArray:s];
//    int longestProper = 0;
//    for (int i=0; i<[prefixArray count]; i++) {
//        if ([(NSString*)prefixArray[i] isEqualToString:(NSString*)suffixArray[i]]) {
//            NSLog(@"Print strings %@ %@", prefixArray[i], suffixArray[i]);
//            longestProper = i;
//        }
//    }
//    NSLog(@"Proper is %d", longestProper);
//    
//    return longestProper;
//}
//
//-(NSArray*) getPrefixArray:(NSString*)s {
//    NSMutableArray *prefixArray = [[NSMutableArray alloc] init];
//    for(int i=0;i< [s length]; i++) {
//        [prefixArray addObject:[s substringWithRange:NSMakeRange(0, i)]];
//    }
//    return (NSArray*)prefixArray;
//}
//
//-(NSArray*) getSuffixArray:(NSString*)s {
//    NSMutableArray *suffixArray = [[NSMutableArray alloc] init];
//    for(int i=0;i< [s length]; i++) {
//        [suffixArray addObject:[s substringWithRange:NSMakeRange([s length]-i, i)]];
//    }
//    return (NSArray*)suffixArray;
//}

//NSArray *t = @[1,4, -1,3,2];
//-(int) solution:(NSArray *)a {
//    // write your code in Objective-C 2.0
//
//    int value = 0;
//    NSNumber *nextIndex = a[0];
//    while ([nextIndex integerValue] != -1) {
//        nextIndex = a[[nextIndex integerValue]];
//        value++;
//        continue;
//    }
//    if ([nextIndex integerValue] == -1) {
//        value++;
//        NSLog(@"Value is %d", value);
//        return value;
//    }
//    return 0;
//    
//}

//Find a number greater than min and smallest of all from the rest and is further behind.
//-(int) solution:(NSArray*)a {
//    for (int i=0; i<[a count]; i++) {
//        NSNumber *min = a[i];
//        for (int j=1; j<[a count]; j++) {
//            NSNumber *max = a[[a count]-j];
//            if (min < max) {
//                NSPredicate *valuePredicate=[NSPredicate predicateWithFormat:@"self.intValue > %d && self.intValue < %d",[min intValue], [max intValue]];
//                if ([[a filteredArrayUsingPredicate:valuePredicate] count]==0) {
//                    // FOUND
//                    NSLog(@"Greatest value is %d",(int)[a count]-j);
//                    return (int)[a count]-j;
//                }
//            } else {
//                NSPredicate *valuePredicate=[NSPredicate predicateWithFormat:@"self.intValue < %d && self.intValue > %d",[min intValue], [max intValue]];
//                if ([[a filteredArrayUsingPredicate:valuePredicate] count]==0) {
//                    NSLog(@"Greatest value is %d",(int)[a count]-j);
//                    return (int)[a count]-j;
//                }
//            }
//        }
//
//    }
//    return 0;
//}


@end
