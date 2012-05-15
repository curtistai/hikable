//
//  calculateSOS.h
//  partthree
//
//  Created by a1 on 17/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface calculateSOS : UIViewController<CLLocationManagerDelegate>
{
    IBOutlet UIButton *startSOS;
    IBOutlet UISegmentedControl *SOSAction;
    IBOutlet UISegmentedControl *injuredAtHead;
    IBOutlet UISegmentedControl *injuredAtChest;
    IBOutlet UISegmentedControl *injuredAtLeftHand;
    IBOutlet UISegmentedControl *injuredAtRightHand;
    IBOutlet UISegmentedControl *injuredAtLeftLeg;
    IBOutlet UISegmentedControl *injuredAtRightLeg;
    CLLocationManager *locationManager;
    NSString *nameDistancePoint;

}

- (IBAction)startSOS:(id)sender;
@end
