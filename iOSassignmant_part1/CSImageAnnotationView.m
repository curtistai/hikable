//
//  CSImageAnnotationView.m
//  mapLines
//
//  Created by Craig on 5/15/09.
//  Copyright 2009 Craig Spitzkoff. All rights reserved.
//

#import "CSImageAnnotationView.h"
#import "CSMapAnnotation.h"

//#define kHeight 100
//#define kWidth  100
//#define kBorder 2

@implementation CSImageAnnotationView
@synthesize imageView = _imageView;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    kHeight = (kHeight <= 0) ? 100 : kHeight;
    kWidth = (kWidth <= 0) ? 100 : kWidth;
    kBorder = (kBorder <= 0) ? 2 : kBorder;
    
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	self.frame = CGRectMake(0, 0, kWidth, kHeight);
	//self.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    	
	CSMapAnnotation* csAnnotation = (CSMapAnnotation*)annotation;
	
	UIImage* image = [UIImage imageNamed:csAnnotation.userData];
	_imageView = [[UIImageView alloc] initWithImage:image];
	
	_imageView.frame = CGRectMake(kBorder, kBorder, kWidth - 2 * kBorder, kWidth - 2 * kBorder);
	[self addSubview:_imageView];
	
	return self;
	
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier width:(int)width height:(int)height{
    kWidth = width;
    kHeight = height;
    return [self initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
}

-(void) dealloc
{
	[_imageView release];
	[super dealloc];
}

	 
@end
