//
//  ViewController.m
//  HealthWatch
//
//  Created by Thomas Ortega II on 8/16/15.
//  Copyright © 2015 Tom Ortega. All rights reserved.
//

#import "ViewController.h"
#import "SourcesTableViewController.h"
#import "DailyDataTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self prepHealthKit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepHealthKit {
    if ([HKHealthStore isHealthDataAvailable]) {
        self.appHealthStore = [[HKHealthStore alloc] init];
        if ([self.appHealthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]] == HKAuthorizationStatusSharingAuthorized) {
            self.healthKitStatusLabel.text = @"HealthKit Heart Rate Data Accessible";
            self.requestHealthKitAccess.hidden = YES;
        }
    } else {
        self.requestHealthKitAccess.hidden = YES;
        self.healthKitStatusLabel.text = @"HealthKit Not Available";
    }
}

- (IBAction)requestHealthKitHeartRateAccess:(id)sender {
    [self.appHealthStore requestAuthorizationToShareTypes:[NSSet setWithObject:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]] readTypes:[NSSet setWithObject:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]] completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.healthKitStatusLabel.text = @"HealthKit Heart Rate Data Accessible";
                self.requestHealthKitAccess.hidden = YES;
            } else {
                self.requestHealthKitAccess.hidden = NO;
                self.healthKitStatusLabel.text = @"HealthKit Authorization Request Failed.";
            }
        });
    }];

}

- (IBAction)listHRSources:(id)sender {
    HKSampleType *sampleType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKSourceQuery *sourceQuery = [[HKSourceQuery alloc] initWithSampleType:sampleType samplePredicate:nil completionHandler:^(HKSourceQuery * _Nonnull query, NSSet<HKSource *> * _Nullable sources, NSError * _Nullable error) {
        self.sourcesData = [sources allObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"rootToSources" sender:nil];
        });
    }];
    [self.appHealthStore executeQuery:sourceQuery];
}

- (IBAction)listHRData:(id)sender {
    HKSampleType *sampleType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSSortDescriptor *entryDateDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    NSArray *sortDescriptors = @[entryDateDescriptor];
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:100 sortDescriptors:sortDescriptors resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        self.sourcesData = results;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"rootToDailyData" sender:nil];
        });
    }];
    [self.appHealthStore executeQuery:sampleQuery];
    
}

-(IBAction)recordDataEntry:(id)sender {
    HKQuantityType *rateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantity *rateQuantity = [HKQuantity quantityWithUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] doubleValue:[self.dataTextField.text doubleValue]];
    HKQuantitySample *rateSample = [HKQuantitySample quantitySampleWithType:rateType
                                                                   quantity:rateQuantity
                                                                  startDate:[NSDate date]
                                                                    endDate:[NSDate date]];
    
    [self.appHealthStore saveObject:rateSample withCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.saveStatusLabel.text = @"Heart Rate Data Saved.";
            } else {
                self.saveStatusLabel.text = @"Heart Rate Data Not Saved.";
            }
            self.dataTextField.text = @"";
        });
    }];}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"rootToSources"]) {
        SourcesTableViewController *sourcesVC = (SourcesTableViewController*)segue.destinationViewController;
        sourcesVC.tableData = self.sourcesData;
    } else if ([segue.identifier isEqualToString:@"rootToDailyData"]) {
        DailyDataTableViewController *dailyVC = (DailyDataTableViewController*)segue.destinationViewController;
        dailyVC.tableData = self.sourcesData;
    }
}


@end
