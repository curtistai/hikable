//
//  createRoute.m
//  iOSassignmant_part1
//
//  Created by Lion User on 16/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#define frameHeightFix -50    //Fix the tab bar height problem
#define frameHeightFix -49
#define insertIntoBuildin 0

#import "part1AppDelegate.h"
#import "selectRoute.h"
#import "createRoute.h"
#import "viewRoute.h"
#import <CoreLocation/CoreLocation.h>
#import "CSMapRouteLayerView.h"
#import "CSMapAnnotation.h"
#import "CSImageAnnotationView.h"
#import "CSWebDetailsViewController.h"
#import "sqlite3.h"
#import "AlertPrompt.h"
#import "Toast+UIView.h"

@implementation createRoute
@synthesize routeView = _routeView;
@synthesize mapView   = _mapView;
@synthesize edit_route_id   = _edit_route_id;

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
    [super viewDidLoad];
    
    delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
	points = [[NSMutableArray alloc] init];
	checkpoints_name = [[NSMutableArray alloc] init];
    dragingArrayIndex = -1;
    firstLocationLoaded = false;
    gpsTrackEnable = false;
    waitTo10sAddPoint = false;
    count_Checkpoint = 0;
    lastGPSLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    
	// Create our map view and add it as as subview. 
	_mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_mapView];
	[_mapView setDelegate:self];
    
    if(self.edit_route_id != 0){
        //Get exist route path for edit route
        NSArray* pointStrings = [delegate.pathText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray* checkpointStrings = [delegate.checkpointText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        //NSMutableArray* points = [[NSMutableArray alloc] initWithCapacity:pointStrings.count];
        NSMutableArray* checkpoints = [[NSMutableArray alloc] initWithArray:checkpointStrings copyItems:YES];
        checkpoints_name = [[NSMutableArray alloc] initWithArray:checkpointStrings copyItems:YES];
        
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
            if(![[checkpoints objectAtIndex:idx] isEqualToString:@""]){
                
            }
            [_mapView addAnnotation:annotation];
        }
        MKCoordinateSpan span;
        span.latitudeDelta = 0.5;
        span.longitudeDelta = 0.375;
        
        MKCoordinateRegion region;
        region.center = [[points objectAtIndex:[points count]-1] coordinate];
        region.span = span;
        [_mapView setRegion:region animated:YES];
        
        [_routeView removeFromSuperview];
        _routeView = [[CSMapRouteLayerView alloc] initWithRoute:points mapView:_mapView];
    }
    
    //GPS
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLHeadingFilterNone;
    if(self.edit_route_id == 0){
        [locationManager startUpdatingLocation];
    }
    
    //right button
    if (self.edit_route_id == 0) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveRouteButton)] autorelease];
    }else{
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(updateRouteButton)] autorelease];
    }
    
    //tool bar button
    toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 88 + frameHeightFix, self.view.frame.size.width, 40)] autorelease];
    toolBar.barStyle = UIBarStyleDefault;
    [toolBar sizeToFit];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    barSpace1 = barSpace2 = barSpace3 = barSpace4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    barItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPointByButton)];
    barItem2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:100 target:self action:@selector(startGpsByButton)] autorelease];
    barItem3 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"marker_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addCheckPointByButton)];
    [toolBar setItems:[NSArray arrayWithObjects:barSpace1, barItem1, barSpace2, barItem2, barSpace3, barItem3, barSpace4, nil]];
    //[self.view addSubview:toolBar];
    [self.view insertSubview:toolBar atIndex:999];
}

- (CSMapAnnotation *) addPoint:(CLLocation *)currentLocation title:(NSString *)title annotationType:(CSMapAnnotationType)annotationType{
    CLLocationDistance kmFromPoint1;
    CLLocationDistance kmDifference;
    
    //Calculate the distance
    CLLocation* lastLocation1 = ([points count] == 0 ? currentLocation : [points objectAtIndex:0]);
    CLLocation* lastLocation2 = ([points count] == 0 ? currentLocation : [points objectAtIndex:([points count]-1)]);
    kmFromPoint1 = [lastLocation1 distanceFromLocation:currentLocation] / 1000;
    kmDifference = [lastLocation2 distanceFromLocation:currentLocation] / 1000;
    
	CSMapAnnotation* annotation = nil;
	annotation =[[[CSMapAnnotation alloc] initWithCoordinate:[currentLocation coordinate]
                                              annotationType:annotationType
                                                       title:title
                                                    subtitle:[NSString stringWithFormat:@"Distance: %.2fKM (+%.2fKM)", kmFromPoint1, kmDifference]] autorelease];
    //add marker into the map
	[_mapView addAnnotation:annotation];
	//put latitude and longitude into the "points" array
    [points addObject:currentLocation];
    [checkpoints_name addObject:@""];
    //NSLog(@"\n[Points array] - \n%@", [points description]);
    [_routeView removeFromSuperview];
    _routeView = [[CSMapRouteLayerView alloc] initWithRoute:points mapView:_mapView];
    return annotation;
}

- (CSMapAnnotation *) addPoint:(CLLocation *)currentLocation title:(NSString *)title{
    return [self addPoint:currentLocation title:title annotationType:CSMapAnnotationTypeStart];
}

- (CSMapAnnotation *) addPoint:(float)latitude longitude:(float)longitude title:(NSString *)title{
    CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
    return [self addPoint:currentLocation title:title];
}

- (CSMapAnnotation *) addCheckPoint:(CLLocation *)currentLocation title:(NSString *)title{
    return [self addPoint:currentLocation title:title annotationType:CSMapAnnotationTypeCheckpoint];
}

- (void)addPointByButton{
    CLLocation* lastLocation = [points objectAtIndex:points.count - 1];
    float newLatitude = lastLocation.coordinate.latitude + 0.005;
    float newLongitude = lastLocation.coordinate.longitude + 0.005;
    NSString* title = [NSString stringWithFormat:@"Point %d", points.count + 1 - count_Checkpoint];
    [self addPoint:newLatitude longitude:newLongitude title:title];
    
    //NSLog(@"addPointByButton");
    //NSLog(@"%@", [points description]);
    //NSLog(@"%@", [checkpoints_name description]);
}

- (void)addCheckPointByButton{
    //get route title from user input
    AlertPrompt *prompt = [AlertPrompt alloc];
    prompt = [prompt 
              initWithTitle:@"Enter checkpoint name"
              message:@"Checkpoint Name" 
              delegate:self 
              cancelButtonTitle:@"Cancel" 
              okButtonTitle:@"OK"];
    [prompt show];
    [prompt release];
}

- (void)startGpsByButton{
    [locationManager startUpdatingLocation];
    [_mapView makeToast:@"Starting GPS track..." 
               duration:2.0 
               position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
    barItem2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopGpsByButton)] autorelease];
    barSpace2 = barSpace3 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    barSpace2.width = barSpace3.width = 55;
    [toolBar setItems:[NSArray arrayWithObjects:barSpace1, barItem1, barSpace2, barItem2, barSpace3, barItem3, barSpace4, nil]];
    //[_mapView addSubview:toolBar];
    [self.view insertSubview:toolBar atIndex:999];
    gpsTrackEnable = true;
    _mapView.showsUserLocation = YES;
}

- (void)stopGpsByButton{
    [_mapView makeToast:@"Stopping GPS track..." 
               duration:2.0 
               position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
    barItem2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:100 target:self action:@selector(startGpsByButton)] autorelease];
    barSpace2 = barSpace3 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    [toolBar setItems:[NSArray arrayWithObjects:barSpace1, barItem1, barSpace2, barItem2, barSpace3, barItem3, barSpace4, nil]];
    //[_mapView addSubview:toolBar];
    [self.view insertSubview:toolBar atIndex:999];
    gpsTrackEnable = false;
    [locationManager stopUpdatingLocation];
}

- (void)saveRoute:(NSString *)title{
    //convent the array to csv format string
    NSString* csvPath = @"";
    NSString* csvCheckpoint = @"";
    CLLocation* current = nil;
    for (int i=0; i<points.count; i++) {
        current = [points objectAtIndex:i];
        csvPath = [NSString stringWithFormat:@"%@%f,%f", csvPath, current.coordinate.latitude, current.coordinate.longitude];
        csvCheckpoint = [NSString stringWithFormat:@"%@%@", csvCheckpoint, [checkpoints_name objectAtIndex:i]];
        
        if(i < points.count-1){
            csvPath = [NSString stringWithFormat:@"%@\n", csvPath];
            csvCheckpoint = [NSString stringWithFormat:@"%@\n", csvCheckpoint];
        }
    }
    //NSLog(@"%@", csvPath);
    
    //insert into database
    
    NSString *sqlString;
    if(insertIntoBuildin == 0){
        sqlString = @"INSERT OR REPLACE INTO 'route_userdefine' ('id', 'title', 'path', 'checkpoint') VALUES (?, ?, ?, ?)";
    }else{
        sqlString = @"INSERT OR REPLACE INTO 'route_buildin' ('id', 'title', 'path', 'checkpoint') VALUES (?, ?, ?, ?)";
    }
    const char *sql = [sqlString UTF8String];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(delegate.db, sql, -1, &statement, nil) == SQLITE_OK){
        sqlite3_bind_text(statement, 1, [[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [title UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [csvPath UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 4, [csvCheckpoint UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(statement) != SQLITE_DONE){
        NSAssert(0, @"Error updating table.");
    }else{
        sqlite3_close(delegate.db);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateRoute{
    //convent the array to csv format string
    NSString* csvPath = @"";
    NSString* csvCheckpoint = @"";
    CLLocation* current = nil;
    //NSLog(@"updateRoute");
    for (int i=0; i<points.count; i++) {
        //NSLog(@"%d", i);
        current = [points objectAtIndex:i];
        csvPath = [NSString stringWithFormat:@"%@%f,%f", csvPath, current.coordinate.latitude, current.coordinate.longitude];
        csvCheckpoint = [NSString stringWithFormat:@"%@%@", csvCheckpoint, [checkpoints_name objectAtIndex:i]];
        
        if(i < points.count-1){
            csvPath = [NSString stringWithFormat:@"%@\n", csvPath];
            csvCheckpoint = [NSString stringWithFormat:@"%@\n", csvCheckpoint];
        }
    }
    //NSLog(@"%@", csvPath);
    delegate.pathText = csvPath;
    delegate.checkpointText = csvCheckpoint;
    
    //insert into database
    NSString *sqlString;
    if(insertIntoBuildin == 0){
        sqlString = @"UPDATE 'route_userdefine' SET 'path' = ?, 'checkpoint' = ? WHERE id = ?";
    }else{
        sqlString = @"UPDATE 'route_buildin' SET 'path' = ?, 'checkpoint' = ? WHERE id = ?";
    }
    const char *sql = [sqlString UTF8String];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(delegate.db, sql, -1, &statement, nil) == SQLITE_OK){
        sqlite3_bind_text(statement, 1, [csvPath UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [csvCheckpoint UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [[NSString stringWithFormat:@"%d", self.edit_route_id] UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(statement) != SQLITE_DONE){
        NSAssert(0, @"Error updating table.");
    }else{
        sqlite3_close(delegate.db);
        delegate.showEditSuccessMessage = true;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != [alertView cancelButtonIndex]){
        if([[(AlertPrompt *)alertView enteredText] isEqualToString:@""]){
            [_mapView makeToast:@"You must enter the name!\nPlease try again..." 
                       duration:2.0 
                       position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
            return;
        }
        if([[alertView message] isEqualToString:@"Route Name"]){
            [self saveRoute:[(AlertPrompt *)alertView enteredText]];
        }else if([[alertView message] isEqualToString:@"Checkpoint Name"]){
            CLLocation* lastLocation = [points objectAtIndex:points.count - 1];
            float newLatitude = lastLocation.coordinate.latitude + 0.005;
            float newLongitude = lastLocation.coordinate.longitude + 0.005;
            CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:newLatitude longitude:newLongitude] autorelease];
            [self addCheckPoint:currentLocation title:[(AlertPrompt *)alertView enteredText]];
            [checkpoints_name removeLastObject];
            [checkpoints_name addObject:[(AlertPrompt *)alertView enteredText]];
            count_Checkpoint++;
            
            //NSLog(@"addCheckpointByButton");
            //NSLog(@"%@", [points description]);
            //NSLog(@"%@", [checkpoints_name description]);
        }
    }
}

- (void)saveRouteButton{
    //get route title from user input
    AlertPrompt *prompt = [AlertPrompt alloc];
    prompt = [prompt 
              initWithTitle:@"Enter route name"
              message:@"Route Name" 
              delegate:self 
              cancelButtonTitle:@"Cancel" 
              okButtonTitle:@"OK"];
    [prompt show];
    [prompt release];
}

- (void)updateRouteButton{
    [self updateRoute];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    //NSLog(@"\nOld: %@\nNew: %@\nLast: %@", [oldLocation description], [newLocation description], [lastGPSLocation description]);
    if(!waitTo10sAddPoint && (lastGPSLocation.coordinate.latitude != 0 || lastGPSLocation.coordinate.longitude != 0) && (lastGPSLocation.coordinate.latitude == newLocation.coordinate.latitude && lastGPSLocation.coordinate.longitude == newLocation.coordinate.longitude)){
        return;
    }
    
    //NSLog(@"GPS Location: %@", [newLocation description]);
    
    currentTimestamp = [[NSDate date] timeIntervalSince1970];
    //NSLog(@"------------ %d", currentTimestamp);
    if(!firstLocationLoaded){   //first load (viewdidload)
        NSString* title = [NSString stringWithFormat:@"Point %d", points.count + 1];
        if(self.edit_route_id == 0){    //only for view route
            [self addPoint:newLocation title:title];
        }
        
        MKCoordinateSpan span;
        span.latitudeDelta = 0.5;
        span.longitudeDelta = 0.375;
        
        MKCoordinateRegion region;
        region.center = newLocation.coordinate;
        region.span = span;
        [_mapView setRegion:region animated:YES];
        
        lastUpdateTimestamp = [[NSDate date] timeIntervalSince1970];
        [locationManager stopUpdatingLocation];
    }else if(currentTimestamp > lastUpdateTimestamp + delegate.preference_gps_interval){  //more than 10s
        //NSLog(@"------------ >10");
        if(waitTo10sAddPoint){
            NSString* title = [NSString stringWithFormat:@"Point %d", points.count + 1];
            [self addPoint:lastGPSLocation title:title];
        }
        NSString* title = [NSString stringWithFormat:@"Point %d", points.count + 1];
        [self addPoint:newLocation title:title];
        lastUpdateTimestamp = [[NSDate date] timeIntervalSince1970];
        waitTo10sAddPoint = false;
    }else{  //not more than 10s
        waitTo10sAddPoint = true;
    }
    lastGPSLocation = [newLocation copy];
    firstLocationLoaded = true;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.mapView   = nil;
	self.routeView = nil;
}

- (void)viewWillDisappear:(BOOL)animated{
    [self stopGpsByButton]; //fix back page if not stop gps crash problem
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
    [annotationView setDraggable:YES];
	
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


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
	CSMapAnnotation *annotation = (CSMapAnnotation *)annotationView.annotation;
    
    //CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
    //NSLog(@"****DROP STATUS**** %d %d %f,%f", oldState, newState, droppedAt.latitude, droppedAt.longitude);
    
    //Start drag
    if (oldState == MKAnnotationViewDragStateStarting) {
        dragingArrayIndex = -1;
        CLLocation* current = nil;
        for (int i=0; i<points.count; i++) {
            current = [points objectAtIndex:i];
            if(current.coordinate.latitude == annotation.coordinate.latitude && current.coordinate.longitude == annotation.coordinate.longitude){
                dragingArrayIndex = i;
                break;
            }
        }
    }
    
    //End drag
	if (oldState == MKAnnotationViewDragStateEnding) {
        if(dragingArrayIndex == -1){
            NSLog(@"[Drag error] Can not find dragingArrayIndex!");
            return;
        }
        CLLocation* new = [[[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude] autorelease];
        [points replaceObjectAtIndex:dragingArrayIndex withObject:new];
        [_routeView removeFromSuperview];
        _routeView = [[CSMapRouteLayerView alloc] initWithRoute:points mapView:_mapView];
        //NSLog(@"\n[Points array] - \n%@", [points description]);
        CSMapAnnotation* annotation = nil;
        CLLocationDistance kmFromPoint1;
        CLLocationDistance kmDifference;
        
        
        //NSLog(@"Checkpoint 1");
        //Update all annotations once (update the distance)
        [_mapView removeAnnotations:mapView.annotations];
        //NSLog(@"Checkpoint 2");
        for(int idx = 0; idx < points.count; idx++){
            //NSLog(@"Checkpoint * %d", idx);
            //Calculate the distance
            kmFromPoint1 = [[points objectAtIndex:0] distanceFromLocation:[points objectAtIndex:idx]] / 1000;
            kmDifference = [[points objectAtIndex:(idx == 0 ? 0 : idx-1)] distanceFromLocation:[points objectAtIndex:idx]] / 1000;
            
 
            NSString* marker_title;
            CSMapAnnotationType annotationType;
            //NSLog(@"......%d, %@", idx, [checkpoints_name objectAtIndex:idx]);
            if([[checkpoints_name objectAtIndex:idx] isEqualToString:@""]){
                marker_title = [NSString stringWithFormat:@"Point %d", idx + 1];
                annotationType = CSMapAnnotationTypeStart;
            }else{
                marker_title = [checkpoints_name objectAtIndex:idx];
                annotationType = CSMapAnnotationTypeCheckpoint;
            }
            
            //Add marker on map
            annotation = [[[CSMapAnnotation alloc] initWithCoordinate:[[points objectAtIndex:idx] coordinate]
                                                       annotationType:annotationType
                                                                title:marker_title
                                                             subtitle:[NSString stringWithFormat:@"Distance: %.2fKM (+%.2fKM)", kmFromPoint1, kmDifference]] autorelease];
            [_mapView addAnnotation:annotation];
        }
	}
}


-(void) showWebViewForURL:(NSURL*) url
{
	CSWebDetailsViewController* webViewController = [[CSWebDetailsViewController alloc] initWithNibName:@"CSWebDetailsViewController" bundle:nil];
	[webViewController setUrl:url];
	
	[self presentModalViewController:webViewController animated:YES];
	//[webViewController autorelease];
}

- (void)dealloc {	
    [_mapView release];
	[_routeView release];
	[_detailsVC release];
    [points release];
	[super dealloc];
	
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