//
//  calculateSOS.m
//  partthree
//
//  Created by a1 on 17/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "calculateSOS.h"
#import "startSOS.h"
#import "part1AppDelegate.h"
#import "KMLtoCLLocationArray.h"

@implementation calculateSOS

- (NSString *)getNearlyDistancePoint:(NSMutableArray *)HKDistancePosts currentLocation:(CLLocation *)currentLocation{
    double smallest = -1;
    NSString* result;
    for (int i=0; i<[HKDistancePosts count]; i++) {
        NSMutableArray* HKDistancePost = [HKDistancePosts objectAtIndex:i];
        NSMutableArray* points = [HKDistancePost objectAtIndex:1];
        for (int j=0; j<[points count]; j++) {
            NSMutableArray* point = [points objectAtIndex:j];
            CLLocation* location = [[CLLocation alloc] initWithLatitude:[[point objectAtIndex:1] doubleValue]
                                                              longitude:[[point objectAtIndex:2] doubleValue]];
            CLLocationDistance kmDifference = [currentLocation distanceFromLocation:location] / 1000;
            if(kmDifference < smallest || smallest == -1){
                smallest = kmDifference;
                result = [point objectAtIndex:0];
            }
        }
    }
    return result;
}
- (IBAction)startSOS:(id)sender
{
    NSLog(@"%d",SOSAction.selectedSegmentIndex);
    NSString *message;


    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    part1AppDelegate *delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *location = delegate.location;
    
    message = [NSString stringWithFormat:@"\nMy Name is %@",[prefs stringForKey:@"myname_preference"]];
    message = [NSString stringWithFormat:@"%@\nMy Location is at %f,%f", message, location.coordinate.latitude, location.coordinate.longitude];
    message = [NSString stringWithFormat:@"%@\nMy nearly distance point is at %@", message, nameDistancePoint];
    if (SOSAction.selectedSegmentIndex==0) { // Injured
        message = [NSString stringWithFormat:@"%@ and I have got injured.",message];    
        message = [NSString stringWithFormat:@"%@\n My Head%@",message,(injuredAtHead.selectedSegmentIndex==0)?@" is OK.": (injuredAtHead.selectedSegmentIndex==1)?@" is bleeding.":@"\'s bone is broken."];        
        message = [NSString stringWithFormat:@"%@\n My Cheast%@",message,(injuredAtChest.selectedSegmentIndex==0)?@" is OK.": (injuredAtChest.selectedSegmentIndex==1)?@" is bleeding.":@"\'s bone is broken."];     
        message = [NSString stringWithFormat:@"%@\n My Left Hand%@",message,(injuredAtLeftHand.selectedSegmentIndex==0)?@" is OK.": (injuredAtLeftHand.selectedSegmentIndex==1)?@" is bleeding.":@"\'s bone is broken."];     
        message = [NSString stringWithFormat:@"%@\n My Right Hand%@",message,(injuredAtRightHand.selectedSegmentIndex==0)?@" is OK.": (injuredAtRightHand.selectedSegmentIndex==1)?@" is bleeding.":@"\'s bone is broken."];     
        message = [NSString stringWithFormat:@"%@\n My Left Leg%@",message,(injuredAtLeftLeg.selectedSegmentIndex==0)?@" is OK.": (injuredAtLeftLeg.selectedSegmentIndex==1)?@" is bleeding.":@"\'s bone is broken."];     
        message = [NSString stringWithFormat:@"%@\n My Right Leg%@",message,(injuredAtRightLeg.selectedSegmentIndex==0)?@" is OK.": (injuredAtRightLeg.selectedSegmentIndex==1)?@" is bleeding.":@"\'s bone is broken."]; 
      //  message = [NSString stringWithFormat:@"%@\n I have some illness :%@",message,[prefs stringForKey:@"illness_preference"]];
        message = ([prefs stringForKey:@"illness_preference"]!=nil)? [NSString stringWithFormat:@"%@\n I have got %@.",message,[prefs stringForKey:@"illness_preference"]]:[NSString stringWithFormat:@"%@",message];

        message = ([prefs boolForKey:@"drugsensitive-perference"])? [NSString stringWithFormat:@"%@\n I have drug sensitive.",message]:[NSString stringWithFormat:@"%@\n I dont have drug sensitive",message];
        

        
    }else{                                   // Get Lost
        message = [NSString stringWithFormat:@"%@ and I have got lost.",message];    
    }

    message = [NSString stringWithFormat:@"%@ \n\nPlease help me to call the police and my main contact person: %@ (%@)",message, [prefs stringForKey:@"name_preference"], [prefs stringForKey:@"telephone_perference"]];

    NSLog(@"%@",message);
    
    delegate.SOSMessage = message;

    NSLog(@"start SOS clicked");
    startSOS *start_SOS = [[startSOS alloc] init];
    start_SOS.title = @"Start SOS";
    [self.navigationController pushViewController:start_SOS animated:YES];
    [start_SOS release];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    //GPS
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLHeadingFilterNone;
    [locationManager startUpdatingLocation];    
    [super viewDidLoad];
    
    part1AppDelegate *delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    KMLtoCLLocationArray* k2c = [KMLtoCLLocationArray alloc];
    NSMutableArray* HKDistancePosts = [k2c getCLLocationArray];
    nameDistancePoint = [self getNearlyDistancePoint:HKDistancePosts currentLocation:delegate.location];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    //NSLog(@"\nOld: %@\nNew: %@\nLast: %@", [oldLocation description], [newLocation description], [lastGPSLocation description]);
    if((oldLocation.coordinate.latitude != 0 || oldLocation.coordinate.longitude != 0) && (oldLocation.coordinate.latitude == newLocation.coordinate.latitude && oldLocation.coordinate.longitude == newLocation.coordinate.longitude)){
        return;
    }
    part1AppDelegate *delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.location = newLocation;
    [locationManager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
    NSString *message = [[NSString alloc] initWithString:@"Error obtaining location"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [message release];
    [alertView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
