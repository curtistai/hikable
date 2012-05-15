//
//  viewRoute.m
//  iOSassignmant_part1
//
//  Created by Lion User on 15/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//#define frameHeightFix -50    //Fix the tab bar height problem
#define frameHeightFix 0
#define insertIntoBuildin 0

#import "part1AppDelegate.h"
#import "viewRoute.h"
#import "createRoute.h"
#import "selectRoute.h"
#import <CoreLocation/CoreLocation.h>
#import "CSMapRouteLayerView.h"
#import "CSMapAnnotation.h"
#import "CSImageAnnotationView.h"
#import "CSWebDetailsViewController.h"
#import "KMLtoCLLocationArray.h"
#import "AlertSelectHDP.h"
#import "AlertPrompt.h"
#import "Toast+UIView.h"

@implementation viewRoute
@synthesize routeView = _routeView;
@synthesize mapView   = _mapView;
@synthesize view_route_id   = _view_route_id;

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

-(void) do_k2cThread{
    delegate.displayHDP = true;
    KMLtoCLLocationArray* k2c = [KMLtoCLLocationArray alloc];
    NSMutableArray* HKDistancePosts = [k2c getCLLocationArray];
    //NSLog(@"%@", [HKDistancePosts description]);
    
    //Add marker on map
    CSMapAnnotation* annotation;
    for (int i=0; i<[HKDistancePosts count]; i++) {
        NSMutableArray* HKDistancePost = [HKDistancePosts objectAtIndex:i];
        NSString* name = [HKDistancePost objectAtIndex:0];
        NSMutableArray* points = [HKDistancePost objectAtIndex:1];
        for (int j=0; j<[points count]; j++) {
            NSMutableArray* point = [points objectAtIndex:j];
            CLLocation* location = [[CLLocation alloc] initWithLatitude:[[point objectAtIndex:1] doubleValue]
                                                              longitude:[[point objectAtIndex:2] doubleValue]];
            annotation = [[[CSMapAnnotation alloc] initWithCoordinate:[location coordinate]
                                                       annotationType:CSMapAnnotationTypeHKDP
                                                                title:[NSString stringWithFormat:@"%@", [point objectAtIndex:0]]
                                                             subtitle:name] autorelease];
            [annotation setUserData:@"hkdp.png"];
            [_mapView addAnnotation:annotation];
            [point_DistancePosts addObject:annotation];
        }
    }
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(HDPfilterButton)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [barButtonItem release];
}

- (void)viewDidLoad{}

- (void)viewDidAppear:(BOOL)animated{
    if(delegate.showEditSuccessMessage){
        [self.view makeToast:@"Success to edit route!" 
                    duration:2.0 
                    position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
        delegate.showEditSuccessMessage = false;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"%@", delegate.pathText);
    NSString* fileContents = delegate.pathText;
    //NSLog(@"%@", delegate.checkpointText);
    NSString* checkpointContents = delegate.checkpointText;
    routeTitle = delegate.routeTitle;
    point_DistancePosts = [[NSMutableArray alloc] init];
    delegate.displayHDP = false;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
	// load the points from our local resource
	//NSString* filePath = [[NSBundle mainBundle] pathForResource:@"route" ofType:@"csv"];
	//NSString* fileContents = [NSString stringWithContentsOfFile:filePath];
    //NSString* fileContents = @"42.33677,-71.126046\n42.336845,-71.126239\n42.336953,-71.12639\n42.337103,-71.12654\n42.337275,-71.126711\n42.337457,-71.126883";
	NSArray* pointStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray* checkpointStrings = [checkpointContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
	
	points = [[NSMutableArray alloc] initWithCapacity:pointStrings.count];
	NSMutableArray* checkpoints = [[NSMutableArray alloc] initWithArray:checkpointStrings copyItems:YES];
    
	// Create our map view and add it as as subview. 
	_mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_mapView];
	[_mapView setDelegate:self];
    
    //GPS
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLHeadingFilterNone;
    
    //tool bar button
    UIToolbar* toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 43 + frameHeightFix, self.view.frame.size.width, 40)] autorelease];
    toolBar.barStyle = UIBarStyleDefault;
    [toolBar sizeToFit];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem* barSpace1;
    UIBarButtonItem* barSpace2;
    UIBarButtonItem* barSpace3;
    UIBarButtonItem* barSpace4;
    UIBarButtonItem* barSpace5;
    UIBarButtonItem* barSpace6;
    barSpace1 = barSpace2 = barSpace3 = barSpace4 = barSpace5 = barSpace6 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* barItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editPointByButton)];
    UIBarButtonItem* barItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(renameByButton)];
    UIBarButtonItem* barItem3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteByButton)];
    UIBarButtonItem* barItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareByButton)];
    UIBarButtonItem* barItem5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:100 target:self action:@selector(gpsStartByButton)];
    [toolBar setItems:[NSArray arrayWithObjects:barSpace1, barItem1, barSpace2, barItem2, barSpace3, barItem3, barSpace4, barItem4, barSpace5, barItem5, barSpace6, nil]];
    [self.view insertSubview:toolBar atIndex:999];
    
    //Markers
    CSMapAnnotation* annotation = nil;
    CLLocationDistance kmFromPoint1;
    CLLocationDistance kmDifference;
    
	for(int idx = 0; idx < pointStrings.count; idx++){
		// break the string down even further to latitude and longitude fields. 
		NSString* currentPointString = [pointStrings objectAtIndex:idx];
		NSArray* latLonArr = [currentPointString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
		
		CLLocationDegrees latitude  = [[latLonArr objectAtIndex:0] doubleValue];
		CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];
		
		CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
		[points addObject:currentLocation];
        
        //Calculate the distance
        kmFromPoint1 = [[points objectAtIndex:0] distanceFromLocation:[points objectAtIndex:idx]] / 1000;
        kmDifference = [[points objectAtIndex:(idx == 0 ? 0 : idx-1)] distanceFromLocation:[points objectAtIndex:idx]] / 1000;
        //marker title
        NSString* marker_title;
        CSMapAnnotationType annotationType;
        //NSLog(@"......%d", idx);
        if([[checkpoints objectAtIndex:idx] isEqualToString:@""]){
            marker_title = [NSString stringWithFormat:@"Point %d", idx + 1];
            annotationType = CSMapAnnotationTypeStart;
        }else{
            marker_title = [checkpoints objectAtIndex:idx];
            annotationType = CSMapAnnotationTypeCheckpoint;
        }
        
        //Add marker on map
        annotation = [[[CSMapAnnotation alloc] initWithCoordinate:[[points objectAtIndex:idx] coordinate]
                                                   annotationType:annotationType
                                                            title:marker_title
                                                         subtitle:[NSString stringWithFormat:@"Distance: %.2fKM (+%.2fKM)", kmFromPoint1, kmDifference]] autorelease];
        [_mapView addAnnotation:annotation];
	}
	
	// create our route layer view, and initialize it with the map on which it will be rendered. 
	_routeView = [[CSMapRouteLayerView alloc] initWithRoute:points mapView:_mapView];
	
	[points release];
    
    //Put "HK Distance Post" on map
    NSThread* k2cThread = [[NSThread alloc] initWithTarget:self selector:@selector(do_k2cThread) object:nil];
    [k2cThread start];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != [alertView cancelButtonIndex]){
        if([[alertView message] isEqualToString:@"New route Name"]){    //Edit route name
            NSString* value_newname = [(AlertPrompt *)alertView enteredText];
            if([value_newname isEqualToString:@""]){
                [self.view makeToast:@"You must enter the name!\nPlease try again..." 
                           duration:2.0 
                           position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
                return;
            }
            NSString *sqlString;
            if(insertIntoBuildin == 0){
                sqlString = @"UPDATE 'route_userdefine' SET 'title' = ? WHERE id = ?";
            }else{
                sqlString = @"UPDATE 'route_buildin' SET 'title' = ? WHERE id = ?";
            }
            const char *sql = [sqlString UTF8String];
            
            sqlite3_stmt *statement;
            
            if (sqlite3_prepare_v2(delegate.db, sql, -1, &statement, nil) == SQLITE_OK){
                sqlite3_bind_text(statement, 1, [value_newname UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 2, [[NSString stringWithFormat:@"%d", self.view_route_id] UTF8String], -1, NULL);
            }
            
            if (sqlite3_step(statement) != SQLITE_DONE){
                NSAssert(0, @"Error updating table.");
            }else{
                sqlite3_close(delegate.db);
                [self.view makeToast:@"Success to rename the route!" 
                           duration:2.0 
                           position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
                self.title = value_newname;
            }
        }else if([[alertView message] isEqualToString:@"Do you confirm to delete this route?"]){    //Delete route
            NSString *sqlString;
            if(insertIntoBuildin == 0){
                sqlString = @"DELETE FROM 'route_userdefine' WHERE id = ?";
            }else{
                sqlString = @"DELETE FROM 'route_buildin' WHERE id = ?";
            }
            const char *sql = [sqlString UTF8String];
            
            sqlite3_stmt *statement;
            
            if (sqlite3_prepare_v2(delegate.db, sql, -1, &statement, nil) == SQLITE_OK){
                sqlite3_bind_text(statement, 1, [[NSString stringWithFormat:@"%d", self.view_route_id] UTF8String], -1, NULL);
            }
            
            if (sqlite3_step(statement) != SQLITE_DONE){
                NSAssert(0, @"Error updating table.");
            }else{
                sqlite3_close(delegate.db);
                [self.view makeToast:@"Success to delete this route!" 
                           duration:2.0 
                           position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
                delegate.showDeleteSuccessMessage = true;
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{  //Display infomation
            bool value_HDP = [(AlertSelectHDP *)alertView value_HDP];
            if(value_HDP == delegate.displayHDP){
                return;
            }
            if(!value_HDP){
                delegate.displayHDP = false;
                [_mapView removeAnnotations:point_DistancePosts];
            }else{
                //Put "HK Distance Post" on map
                NSThread* k2cThread = [[NSThread alloc] initWithTarget:self selector:@selector(do_k2cThread) object:nil];
                [k2cThread start];
            }
        }
    }
}

- (void)HDPfilterButton{
    //get route title from user input
    AlertSelectHDP *prompt = [AlertSelectHDP alloc];
    prompt = [prompt 
              initWithTitle:@"Display Infomation"
              message:@"" 
              delegate:self 
              cancelButtonTitle:@"Cancel" 
              okButtonTitle:@"OK"];
    [prompt show];
    [prompt release];
}

- (void)editPointByButton{
    createRoute *create_route = [[createRoute alloc] init];
    create_route.title = @"Edit route";
    create_route.edit_route_id = self.view_route_id;
    [self.navigationController pushViewController:create_route animated:YES];
    [create_route release];
}

- (void)renameByButton{
    AlertPrompt *prompt = [AlertPrompt alloc];
    prompt = [prompt 
              initWithTitle:@"Enter new route name"
              message:@"New route Name"
              delegate:self 
              cancelButtonTitle:@"Cancel" 
              okButtonTitle:@"OK"];
    [prompt show];
    [prompt release];
}

- (void)deleteByButton{
    UIAlertView *prompt = [AlertPrompt alloc];
    prompt = [prompt 
              initWithTitle:@"Warning!"
              message:@"Do you confirm to delete this route?"
              delegate:self 
              cancelButtonTitle:@"Cancel" 
              otherButtonTitles:@"OK", nil];
    [prompt show];
    [prompt release];
}

- (void)shareByButton{
    [self.view makeToast:@"Success to share location to facebook!" 
                duration:2.0 
                position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
    NSMutableString *facebookMessage = [NSMutableString stringWithString:@"[Only for HomeWork Testing Purpose.It is not real. Thank You]"];
    [facebookMessage appendString: [NSMutableString stringWithFormat:@"Here is my route.Share with you"]];
    
    
    NSString *pathText = @"";
    //NSLog(@"Tai Debug----- %@", [points description]);
    for (int i=0; i<[points count]; i++) {
        CLLocation* tempLocation = [points objectAtIndex:i];
        pathText = [NSString stringWithFormat:@"%@%f,%f", pathText, tempLocation.coordinate.latitude, tempLocation.coordinate.longitude];
        if(i < [points count]-1){
            pathText = [NSString stringWithFormat:@"%@|", pathText];
        }
    }
    
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"386913861360420", @"app_id",
                                   [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?&zoom=13&size=512x512&maptype=roadmap&path=color:0xff0000ff|weight:5|%@&markers=%@&sensor=false&format=png",pathText,pathText], @"link",
                                   [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?&zoom=13&size=512x512&maptype=roadmap&path=color:0xff0000ff|weight:5|%@&markers=%@&sensor=false&format=png",pathText,pathText], @"picture",
                                   @"My Route is Here.", @"name",
                                   //@"Reference Documentation", @"caption",
                                   @"Testing from IOS Assignment", @"description",
                                   facebookMessage,  @"message",
                                   nil];
    
    [delegate.facebook requestWithGraphPath:@"me/feed" 
                                  andParams:params
                              andHttpMethod:@"POST"
                                andDelegate:nil];

    
}

- (void)gpsStartByButton{
    [locationManager startUpdatingLocation];
    [self.view makeToast:@"Starting GPS track..." 
               duration:2.0 
               position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
    UIToolbar* toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 43 + frameHeightFix, self.view.frame.size.width, 40)] autorelease];
    toolBar.barStyle = UIBarStyleDefault;
    [toolBar sizeToFit];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem* barSpace1;
    UIBarButtonItem* barSpace2;
    UIBarButtonItem* barSpace3;
    UIBarButtonItem* barSpace4;
    UIBarButtonItem* barSpace5;
    UIBarButtonItem* barSpace6;
    barSpace1 = barSpace2 = barSpace3 = barSpace4 = barSpace5 = barSpace6 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* barItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editPointByButton)];
    UIBarButtonItem* barItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(renameByButton)];
    UIBarButtonItem* barItem3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteByButton)];
    UIBarButtonItem* barItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareByButton)];
    UIBarButtonItem* barItem5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(gpsStopByButton)];
    [toolBar setItems:[NSArray arrayWithObjects:barSpace1, barItem1, barSpace2, barItem2, barSpace3, barItem3, barSpace4, barItem4, barSpace5, barItem5, barSpace6, nil]];
    [self.view insertSubview:toolBar atIndex:999];
    _mapView.showsUserLocation = YES;
}

- (void)gpsStopByButton{
    
    [locationManager stopUpdatingLocation];
    [self.view makeToast:@"Stopping GPS track..." 
               duration:2.0 
               position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
    UIToolbar* toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 43 + frameHeightFix, self.view.frame.size.width, 40)] autorelease];
    toolBar.barStyle = UIBarStyleDefault;
    [toolBar sizeToFit];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem* barSpace1;
    UIBarButtonItem* barSpace2;
    UIBarButtonItem* barSpace3;
    UIBarButtonItem* barSpace4;
    UIBarButtonItem* barSpace5;
    UIBarButtonItem* barSpace6;
    barSpace1 = barSpace2 = barSpace3 = barSpace4 = barSpace5 = barSpace6 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* barItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editPointByButton)];
    UIBarButtonItem* barItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(renameByButton)];
    UIBarButtonItem* barItem3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteByButton)];
    UIBarButtonItem* barItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareByButton)];
    UIBarButtonItem* barItem5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:100 target:self action:@selector(gpsStartByButton)];
    [toolBar setItems:[NSArray arrayWithObjects:barSpace1, barItem1, barSpace2, barItem2, barSpace3, barItem3, barSpace4, barItem4, barSpace5, barItem5, barSpace6, nil]];
    [self.view insertSubview:toolBar atIndex:999];
    [locationManager stopUpdatingLocation];
}





- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.mapView   = nil;
	self.routeView = nil;
}

- (void)viewDidDisappear:(BOOL)animated{
    self.mapView.delegate = nil;
}

#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	// turn off the view of the route as the map is chaning regions. This prevents
	// the line from being displayed at an incorrect positoin on the map during the
	// transition. 
	_routeView.hidden = YES;
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	// re-enable and re-poosition the route display. 
	_routeView.hidden = NO;
	[_routeView setNeedsDisplay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //Fix "showsUserLocation = YES" crash problem
    if([annotation isKindOfClass:MKUserLocation.class]){
        return nil;
    }
    
	MKAnnotationView* annotationView = nil;
	
	// determine the type of annotation, and produce the correct type of annotation view for it.
	CSMapAnnotation* csAnnotation = (CSMapAnnotation*)annotation;
	if(csAnnotation.annotationType == CSMapAnnotationTypeStart || 
	   csAnnotation.annotationType == CSMapAnnotationTypeEnd)
	{
		NSString* identifier = @"Pin";
		MKPinAnnotationView* pin = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if(nil == pin)
		{
			pin = [[[MKPinAnnotationView alloc] initWithAnnotation:csAnnotation reuseIdentifier:identifier] autorelease];
		}
		
		[pin setPinColor:(csAnnotation.annotationType == CSMapAnnotationTypeEnd) ? MKPinAnnotationColorRed : MKPinAnnotationColorGreen];
		
		annotationView = pin;
	}
	else if(csAnnotation.annotationType == CSMapAnnotationTypeImage)
	{
		NSString* identifier = @"Image";
		
		CSImageAnnotationView* imageAnnotationView = (CSImageAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(nil == imageAnnotationView)
		{
			imageAnnotationView = [[[CSImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];	
			imageAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		}
        
		annotationView = imageAnnotationView;
	}
	else if(csAnnotation.annotationType == CSMapAnnotationTypeHKDP)
	{
		NSString* identifier = @"Image";
		
		CSImageAnnotationView* imageAnnotationView = (CSImageAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(nil == imageAnnotationView)
		{
            //imageAnnotationView.kWidth = 20;
            //imageAnnotationView.kHeight = 20;
			imageAnnotationView = [[[CSImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier width:17 height:20] autorelease];
		}
        
		annotationView = imageAnnotationView;
	}else if(csAnnotation.annotationType == CSMapAnnotationTypeCheckpoint)
	{
		NSString* identifier = @"Pin";
		MKPinAnnotationView* pin = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if(nil == pin)
		{
			pin = [[[MKPinAnnotationView alloc] initWithAnnotation:csAnnotation reuseIdentifier:identifier] autorelease];
		}
		
		[pin setPinColor:MKPinAnnotationColorPurple];
		
		annotationView = pin;
	}
	
	[annotationView setEnabled:YES];
	[annotationView setCanShowCallout:YES];
	
	return annotationView;
	
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	//NSLog(@"calloutAccessoryControlTapped");
    
	CSImageAnnotationView* imageAnnotationView = (CSImageAnnotationView*) view;
	CSMapAnnotation* annotation = (CSMapAnnotation*)[imageAnnotationView annotation];
    
	if(annotation.url != nil)
	{
		if(nil == _detailsVC)	
			_detailsVC = [[CSWebDetailsViewController alloc] initWithNibName:@"CSWebDetailsViewController" bundle:nil];
		
		_detailsVC.url = annotation.url;
		[self.view addSubview:_detailsVC.view];
	}
}


-(void) showWebViewForURL:(NSURL*) url
{
	CSWebDetailsViewController* webViewController = [[CSWebDetailsViewController alloc] initWithNibName:@"CSWebDetailsViewController" bundle:nil];
	[webViewController setUrl:url];
	
	[self presentModalViewController:webViewController animated:YES];
	//[webViewController autorelease];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    //NSLog(@"\nOld: %@\nNew: %@\nLast: %@", [oldLocation description], [newLocation description], [lastGPSLocation description]);
    if((oldLocation.coordinate.latitude != 0 || oldLocation.coordinate.longitude != 0) && (oldLocation.coordinate.latitude == newLocation.coordinate.latitude && oldLocation.coordinate.longitude == newLocation.coordinate.longitude)){
        return;
    }
    
    currentTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if(currentTimestamp > lastUpdateTimestamp + delegate.preference_gps_interval){  //more than 10s
        
        MKCoordinateSpan span;
        span.latitudeDelta = 0.5;
        span.longitudeDelta = 0.375;
        
        MKCoordinateRegion region;
        region.center = newLocation.coordinate;
        region.span = span;
        [_mapView setRegion:region animated:YES];
        
        lastUpdateTimestamp = [[NSDate date] timeIntervalSince1970];
        //[locationManager stopUpdatingLocation];
    }
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

- (void)dealloc {	
    //[_mapView release];
	//[_routeView release];
	//[_detailsVC release];
	[super dealloc];
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
