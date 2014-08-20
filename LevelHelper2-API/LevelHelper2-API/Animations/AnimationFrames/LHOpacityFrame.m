//
//  LHOpacityFrame.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHOpacityFrame.h"
#import "LHUtils.h"
#import "LHConfig.h"
#import "NSDictionary+LHDictionary.h"

#import "LHAnimationProperty.h"
#import "LHAnimation.h"

@implementation LHOpacityFrame
{
    NSMutableDictionary* _opacities;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_opacities);
    LH_SUPER_DEALLOC();
}

-(instancetype)initFrameWithDictionary:(NSDictionary*)dict
                              property:(LHAnimationProperty*)prop{
    
    if(self = [super initFrameWithDictionary:dict
                                    property:prop]){
        
        _opacities = [[NSMutableDictionary alloc] init];
        
        NSDictionary* opaInfo = [dict objectForKey:@"opacities"];
        NSArray* allKeys = [opaInfo allKeys];
        for(NSString* uuid in allKeys)
        {
            float op = [[opaInfo objectForKey:uuid] floatValue];
            [_opacities setObject:[NSNumber numberWithFloat:op] forKey:uuid];
        }
    }
    return self;
}

-(float)opacityForUUID:(NSString*)uuid{
    return [[_opacities objectForKey:uuid] floatValue];
}


@end
