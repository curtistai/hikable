//
//  KMLtoCLLocationArray.m
//  iOSassignmant_part1
//
//  Created by Lion User on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KMLtoCLLocationArray.h"
#import "part1AppDelegate.h"

@implementation KMLtoCLLocationArray

-(NSMutableArray *) getCLLocationArray{
    delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([delegate.HkDistancePosts count] == 0){
        /*
        NSArray *kml_filenames = [[[NSArray alloc] initWithObjects:
                                   @"Hong Kong Trail",
                                   @"Lantau Trail",
                                   @"Lung Ha Wan Country Trail",
                                   @"Ma On Shan Conutry Trail",
                                   @"MacLehose Trail",
                                   @"Sheung Yiu Country Trail",
                                   @"Wilson Trail",
                                   nil] autorelease];
         */
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"HKDPlist" ofType:@"csv"];
        NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@", fileContents);
        NSArray* kml_filenames = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSLog(@"%@", [kml_filenames description]);
        HkDistancePosts = [[[NSMutableArray alloc] init] autorelease];
        for (int i=0; i<[kml_filenames count]; i++) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:[kml_filenames objectAtIndex:i] ofType:@"kml"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            xmlParser = [[[NSXMLParser alloc] initWithData:data] autorelease];
            [xmlParser setDelegate:self];
            [xmlParser parse];
        }
        delegate.HkDistancePosts = HkDistancePosts;
    }
    NSLog(@"%@", [delegate.HkDistancePosts description]);
    return delegate.HkDistancePosts;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    hkdp = [[[NSMutableArray alloc] init] autorelease];
    Placemarks = [[[NSMutableArray alloc] init] autorelease];
    Placemark = [[[NSMutableArray alloc] init] autorelease];
    openingPlacemark = false;
    openingName = false;
    openingCoordinates = false;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    //NSLog(@"-------------");
    NSMutableArray* Placemarks_copy = [[[NSMutableArray alloc] initWithArray:Placemarks copyItems:YES] autorelease];
    [hkdp addObject:Placemarks_copy];
    [Placemarks removeAllObjects];
    NSMutableArray* hkdp_copy = [[[NSMutableArray alloc] initWithArray:hkdp copyItems:YES] autorelease];
    [HkDistancePosts addObject:hkdp_copy];
    [hkdp removeAllObjects];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    //NSLog(@"didStartElement");
    //NSLog(@"elementName %@", elementName);
    //NSLog(@"open: %@", elementName);
    if([elementName isEqualToString:@"Placemark"]){
        //[Placemark removeAllObjects];
        openingPlacemark = true;
    }else if([elementName isEqualToString:@"name"]){
        openingName = true;
    }else if([elementName isEqualToString:@"coordinates"]){
        openingCoordinates = true;
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    //NSLog(@"foundCharacters %@", string);
    //NSLog(@"data: %@", string);
    if(!openingPlacemark && openingName){
        [hkdp addObject:string];
    }else if(openingPlacemark && openingName){
        [Placemark addObject:string];
    }else if(openingPlacemark && openingCoordinates){
        NSArray *xy = [string componentsSeparatedByString:@","];
        [Placemark addObject:[xy objectAtIndex:1]];
        [Placemark addObject:[xy objectAtIndex:0]];
        NSMutableArray* Placemark_copy = [[[NSMutableArray alloc] initWithArray:Placemark copyItems:YES] autorelease];
        [Placemarks addObject:Placemark_copy];
        [Placemark removeAllObjects];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    //NSLog(@"didEndElement");
    //NSLog(@"elementName %@", elementName);
    //NSLog(@"close: %@", elementName);
    if([elementName isEqualToString:@"Placemark"]){
        openingPlacemark = false;
    }else if([elementName isEqualToString:@"name"]){
        openingName = false;
    }else if([elementName isEqualToString:@"coordinates"]){
        openingCoordinates = false;
    }
}


@end
