//
//  CSImageAnnotationView.h
//  mapLines
//
//  Created by Craig on 5/15/09.
//  Copyright 2009 Craig Spitzkoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CSImageAnnotationView : MKAnnotationView
{
	UIImageView* _imageView;
    int kHeight;
    int kWidth;
    int kBorder;
}

@property (nonatomic, retain) UIImageView* imageView;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier width:(int)width height:(int)height;

@end
