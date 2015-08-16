//
//  ViewController.h
//  HealthWatch
//
//  Created by Thomas Ortega II on 8/16/15.
//  Copyright © 2015 Tom Ortega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@interface ViewController : UIViewController

@property HKHealthStore *appHealthStore;

@property IBOutlet UILabel *healthKitStatusLabel;
@property IBOutlet UILabel *saveStatusLabel;
@property IBOutlet UIButton *requestHealthKitAccess;
@property IBOutlet UITextField *dataTextField;

@property NSArray *sourcesData;

- (IBAction)requestHealthKitHeartRateAccess:(id)sender;
- (IBAction)listHRSources:(id)sender;
- (IBAction)listHRData:(id)sender;
- (IBAction)recordDataEntry:(id)sender;

@end

