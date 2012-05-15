//
//  KMLtoCLLocationArray.h
//  iOSassignmant_part1
//
//  Created by Lion User on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "part1AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface KMLtoCLLocationArray : NSObject<NSXMLParserDelegate>{
    part1AppDelegate *delegate;
    NSXMLParser *xmlParser;
    NSMutableArray *HkDistancePosts;
    NSMutableArray *hkdp;
    NSMutableArray *Placemarks;
    NSMutableArray *Placemark;
    bool openingPlacemark;
    bool openingName;
    bool openingCoordinates;
}

-(NSMutableArray *) getCLLocationArray;

@end
