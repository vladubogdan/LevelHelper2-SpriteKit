//
//  LHScaleFrame.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHScaleFrame.h"
#import "LHUtils.h"
#import "LHConfig.h"
#import "NSDictionary+LHDictionary.h"

#import "LHAnimationProperty.h"
#import "LHAnimation.h"

@implementation LHScaleFrame
{
    NSMutableDictionary* _scales;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_scales);
    LH_SUPER_DEALLOC();
}

-(instancetype)initFrameWithDictionary:(NSDictionary*)dict
                              property:(LHAnimationProperty*)prop{
    
    if(self = [super initFrameWithDictionary:dict
                                    property:prop]){
        
        _scales = [[NSMutableDictionary alloc] init];
        
        NSDictionary* scalesInfo = [dict objectForKey:@"scales"];
        NSArray* allKeys = [scalesInfo allKeys];
        for(NSString* uuid in allKeys)
        {
            CGSize scl = [scalesInfo sizeForKey:uuid];
            NSValue* val = LHValueWithCGSize(scl);
            [_scales setObject:val forKey:uuid];
        }
    }
    return self;
}

-(CGSize)scaleForUUID:(NSString*)uuid{
    return CGSizeFromValue([_scales objectForKey:uuid]);
}


@end
