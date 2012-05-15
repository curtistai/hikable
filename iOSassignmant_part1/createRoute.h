//
//  createRoute.h
//  iOSassignmant_part1
//
//  Created by Lion User on 16/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CSMapRouteLayerView.h"
#import <CoreLocation/CoreLocation.h>


@class CSWebDetailsViewController;

@interface createRoute : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
	
    part1AppDelegate *delegate;
	MKMapView* _mapView;
	CSMapRouteLayerView* _routeView;
	CSWebDetailsViewController* _detailsVC;
    CLLocationManager *locationManager;
    CLLocation* lastGPSLocation;
    int currentTimestamp;
    int lastUpdateTimestamp;
    NSMutableArray* points;
    NSMutableArray* checkpoints_name;
    int dragingArrayIndex;
    bool firstLocationLoaded;
    bool gpsTrackEnable;
    bool waitTo10sAddPoint;
    int count_Checkpoint;
    UIToolbar* toolBar;
    UIBarButtonItem *barItem1;
    UIBarButtonItem *barItem2;
    UIBarButtonItem *barItem3;
    UIBarButtonItem *barSpace1;
    UIBarButtonItem *barSpace2;
    UIBarButtonItem *barSpace3;
    UIBarButtonItem *barSpace4;
}

-(void) showWebViewForURL:(NSURL*) url;

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) CSMapRouteLayerView* routeView;
@property int edit_route_id;

@end

