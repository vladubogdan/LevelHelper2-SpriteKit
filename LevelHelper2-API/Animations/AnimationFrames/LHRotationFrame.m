//
//  LHRotationFrame.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHRotationFrame.h"
#import "LHUtils.h"
#import "LHConfig.h"
#import "NSDictionary+LHDictionary.h"

#import "LHAnimationProperty.h"
#import "LHAnimation.h"

@implementation LHRotationFrame
{
    NSMutableDictionary* _rotations;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_rotations);
    LH_SUPER_DEALLOC();
}

-(instancetype)initFrameWithDictionary:(NSDictionary*)dict
                              property:(LHAnimationProperty*)prop{
    
    if(self = [super initFrameWithDictionary:dict
                                    property:prop]){
        
        _rotations = [[NSMutableDictionary alloc] init];
        
        NSDictionary* rotInfo = [dict objectForKey:@"rotations"];
        NSArray* allKeys = [rotInfo allKeys];
        for(NSString* uuid in allKeys)
        {
            float rot = [[rotInfo objectForKey:uuid] floatValue];
            [_rotations setObject:[NSNumber numberWithFloat:rot] forKey:uuid];
        }
    }
    return self;
}

-(float)rotationForUUID:(NSString*)uuid{
    return [[_rotations objectForKey:uuid] floatValue];
}


@end
