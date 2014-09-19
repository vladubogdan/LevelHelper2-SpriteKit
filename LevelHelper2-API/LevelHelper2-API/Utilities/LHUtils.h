//
//  LHUtils.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#ifndef LevelHelper2_SpriteKit_LHUtils_h
#define LevelHelper2_SpriteKit_LHUtils_h

#import "LHScene.h"

#if __has_feature(objc_arc) && __clang_major__ >= 3

#define LH_SAFE_RELEASE(X) if(X){ X = nil;}
#define LH_AUTORELEASED(X) X
#define LH_SUPER_DEALLOC() nil;
#define LH_VOID_BRIDGE_CAST(X) (__bridge void*)X
#define LH_ID_BRIDGE_CAST(X) (__bridge id)X;

#else

#define LH_SAFE_RELEASE(X) if(X){[X release]; X = nil;}
#define LH_AUTORELEASED(X) [X autorelease];
#define LH_SUPER_DEALLOC() [super dealloc];
#define LH_VOID_BRIDGE_CAST(X) X
#define LH_ID_BRIDGE_CAST(X) X;

#endif

#define LH_SAFE_DELETE(X) if(X){delete X; X = NULL;}



#if TARGET_OS_IPHONE

///////////////////iOS PLATFORM/////////////////////////////////////////////////
#define LHPointFromString(__val__)  CGPointFromString(__val__)
#define LHRectFromString(__val__)   CGRectFromString(__val__)
#define LHSizeFromString(__val__)   CGSizeFromString(__val__)

#define LHValueWithCGPoint(cgPt) [NSValue valueWithCGPoint:cgPt]
#define LHValueWithCGSize(cgS) [NSValue valueWithCGSize:cgS]
#define CGPointFromValue(_value_) [_value_ CGPointValue]
#define CGSizeFromValue(_value_) [_value_ CGSizeValue]

#define LH_IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define LH_SCREEN_SIZE ( UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) : [UIScreen mainScreen].bounds.size)

#define LH_SCALE_FACTOR ([UIScreen mainScreen].scale)


#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0

#define LH_SCREEN_RESOLUTION ( CGSizeMake([UIScreen mainScreen].bounds.size.width*[[UIScreen mainScreen] scale], [UIScreen mainScreen].bounds.size.height*[[UIScreen mainScreen] scale]))
#else

#define LH_SCREEN_RESOLUTION ( UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? CGSizeMake([UIScreen mainScreen].bounds.size.height*[[UIScreen mainScreen] scale], [UIScreen mainScreen].bounds.size.width*[[UIScreen mainScreen] scale]) : CGSizeMake([UIScreen mainScreen].bounds.size.width*[[UIScreen mainScreen] scale], [UIScreen mainScreen].bounds.size.height*[[UIScreen mainScreen] scale]) )

#endif



#define LHStringFromPoint NSStringFromCGPoint
#else
//////////////////MAC OS PLATFORM///////////////////////////////////////////////

#define LHPointFromString(__val__)  NSPointToCGPoint( NSPointFromString(__val__) )
#define LHRectFromString(__val__)   NSRectToCGRect( NSRectFromString(__val__) )
#define LHSizeFromString(__val__)	NSSizeToCGSize( NSSizeFromString(__val__) )

#define LHValueWithCGPoint(cgPt) [NSValue valueWithPoint:NSPointFromCGPoint(cgPt)]
#define LHValueWithCGSize(cgS) [NSValue valueWithSize:NSSizeFromCGSize(cgS)]

#define CGPointFromValue(_value_) NSPointToCGPoint([_value_ pointValue])
#define CGSizeFromValue(_value_) [_value_ sizeValue]

#define LH_SCREEN_RESOLUTION CGSizeMake(1024, 768)

#define LH_IS_WIDESCREEN ( NO )

#define LHStringFromPoint NSStringFromPoint

#endif






#define LH_DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define LH_RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))


NS_INLINE float LHPointLength(CGPoint pt)
{
    return sqrtf(pt.x*pt.x + pt.y*pt.y);
}

NS_INLINE CGPoint LHPointNormalize(CGPoint pt)
{
    CGPoint temp;
    temp.x = pt.x/LHPointLength(pt);
    temp.y = pt.y/LHPointLength(pt);
    return temp;
}

NS_INLINE CGPoint LHPointScaled(CGPoint pt, float val)
{
    return CGPointMake(pt.x*val, pt.y*val);
}

NS_INLINE CGPoint LHPointAdd(CGPoint ptA, CGPoint ptB)
{
    return CGPointMake(ptA.x + ptB.x, ptA.y + ptB.y);
}

NS_INLINE float LHDistanceBetweenPoints(CGPoint pointA, CGPoint pointB)
{
    return sqrt((pointB.x - pointA.x)*(pointB.x - pointA.x) +
                (pointB.y - pointA.y)*(pointB.y - pointA.y));
}

NS_INLINE NSValue* LHLinesIntersection(CGPoint p1, CGPoint p2,
                                       CGPoint p3, CGPoint p4)
{
    // Store the values for fast access and easy
    // equations-to-code conversion
    float x1 = p1.x, x2 = p2.x, x3 = p3.x, x4 = p4.x;
    float y1 = p1.y, y2 = p2.y, y3 = p3.y, y4 = p4.y;
    
    float d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    // If d is zero, there is no intersection
    if (d == 0) return nil;
    
    // Get the x and y
    float pre = (x1*y2 - y1*x2), post = (x3*y4 - y3*x4);
    float x = ( pre * (x3 - x4) - (x1 - x2) * post ) / d;
    float y = ( pre * (y3 - y4) - (y1 - y2) * post ) / d;
    
    // Check if the x and y coordinates are within both lines
    if ( x < fmin(x1, x2) || x > fmax(x1, x2) ||
        x < fmin(x3, x4) || x > fmax(x3, x4) ) return NULL;
    if ( y < fmin(y1, y2) || y > fmax(y1, y2) ||
        y < fmin(y3, y4) || y > fmax(y3, y4) ) return NULL;
    
    // Return the point of intersection
    return LHValueWithCGPoint(CGPointMake(x, y));
}


NS_INLINE CGPoint LHPointOnCurve(CGPoint p1,
                                 CGPoint p2,
                                 CGPoint p3,
                                 CGPoint p4,
                                 float t)
{
	float var1, var2, var3;
    CGPoint vPoint = CGPointZero;
    
    var1 = 1 - t;
    var2 = var1 * var1 * var1;
    var3 = t * t * t;
    vPoint.x = var2*p1.x + 3*t*var1*var1*p2.x + 3*t*t*var1*p3.x + var3*p4.x;
    vPoint.y = var2*p1.y + 3*t*var1*var1*p2.y + 3*t*t*var1*p3.y + var3*p4.y;
    return(vPoint);
}

NS_INLINE BOOL LHRectOverlapsRect(CGRect r1,  CGRect r2)
{
    return !(r1.origin.x + r1.size.width < r2.origin.x ||
             r1.origin.y + r1.size.height < r2.origin.y ||
             r1.origin.x > r2.origin.x + r2.size.width ||
             r1.origin.y > r2.origin.y + r2.size.height);
}


@class SKNode;
@class SKView;
@class LHDevice;
@class LHAnimation;
@interface LHUtils : NSObject


+(NSString*)imagePathWithFilename:(NSString*)filename
                           folder:(NSString*)folder
                           suffix:(NSString*)suffix;

+(NSString*)devicePosition:(NSDictionary*)availablePositions
                   forSize:(CGSize)curScr;

+(CGPoint)positionForNode:(SKNode*)node
                 fromUnit:(CGPoint)unitPos;

+(LHDevice*)currentDeviceFromArray:(NSArray*)arrayOfDevs;

+(LHDevice*)deviceFromArray:(NSArray*)arrayOfDevs
                   withSize:(CGSize)size;
@end


@interface LHDevice : NSObject
{
    CGSize size;
    float ratio;
    NSString* suffix;
}

+(id)deviceWithDictionary:(NSDictionary*)dict;

-(CGSize)size;
-(NSString*)suffix;
-(float)ratio;

@end

#endif
