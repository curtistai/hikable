//
//  viewRoute.h
//  iOSassignmant_part1
//
//  Created by Lion User on 15/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CSMapRouteLayerView.h"
#import "part1AppDelegate.h"


@class CSWebDetailsViewController;

@interface viewRoute : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
	part1AppDelegate *delegate;
    CLLocationManager *locationManager;
	MKMapView* _mapView;
	CSMapRouteLayerView* _routeView;
	CSWebDetailsViewController* _detailsVC;
    NSString* routeTitle;
    NSMutableArray* point_DistancePosts;
    int currentTimestamp;
    int lastUpdateTimestamp;
    NSMutableArray* points;
}

-(void) showWebViewForURL:(NSURL*) url;

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) CSMapRouteLayerView* routeView;
@property int view_route_id;

@end

