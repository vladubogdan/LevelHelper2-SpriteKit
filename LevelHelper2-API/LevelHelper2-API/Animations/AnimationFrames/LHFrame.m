//
//  LHFrame.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHFrame.h"
#import "LHUtils.h"
#import "LHConfig.h"
#import "NSDictionary+LHDictionary.h"
#import "LHAnimationProperty.h"

@implementation LHFrame
{
    int _frameNumber;
    __weak LHAnimationProperty* property;
    BOOL wasShot;
}

-(void)dealloc{
    property = nil;
    LH_SUPER_DEALLOC();
}

+(instancetype)frameWithDictionary:(NSDictionary*)dict
                          property:(LHAnimationProperty*)prop{
    return LH_AUTORELEASED([[self alloc] initFrameWithDictionary:dict property:prop]);
}

-(instancetype)initFrameWithDictionary:(NSDictionary*)dict
                              property:(LHAnimationProperty*)prop{
    if(self = [super init]){
        _frameNumber = [dict intForKey:@"frameIndex"];
        property = prop;
    }
    return self;
}

-(void)setWasShot:(BOOL)val{
    wasShot = val;
}
-(BOOL)wasShot{
    return wasShot;
}

-(int)frameNumber{
    return _frameNumber;
}

-(LHAnimationProperty*)property{
    return property;
}
@end
