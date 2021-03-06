//
//  MKMultiPoint.h
//  MapKit
//
//  Copyright (c) 2010-2011, Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKShape.h>
#import <MapKit/MKGeometry.h>
#import <MapKit/MKTypes.h>
#import <MapKit/MKFoundation.h>

MK_CLASS_AVAILABLE(NA, 4_0)
@interface MKMultiPoint : MKShape {
@package
    MKMapPoint *_points;
    NSUInteger _pointCount;
    
    MKMapRect _boundingRect;
}

@property (nonatomic, readonly) MKMapPoint *points;
@property (nonatomic, readonly) NSUInteger pointCount;

// Unproject and copy points into the provided array of coordinates that
// must be large enough to hold range.length coordinates.
- (void)getCoordinates:(CLLocationCoordinate2D *)coords range:(NSRange)range;

@end
