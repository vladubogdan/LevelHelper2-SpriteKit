//
//  LHPositionFrame.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHPositionFrame.h"
#import "LHUtils.h"
#import "LHConfig.h"
#import "NSDictionary+LHDictionary.h"

#import "LHAnimationProperty.h"
#import "LHAnimation.h"

@implementation LHPositionFrame
{
    NSMutableDictionary* _positions;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_positions);
    LH_SUPER_DEALLOC();
}

-(instancetype)initFrameWithDictionary:(NSDictionary*)dict
                              property:(LHAnimationProperty*)prop{
    
    if(self = [super initFrameWithDictionary:dict
                                    property:prop]){
        
        _positions = [[NSMutableDictionary alloc] init];
        
        NSDictionary* positionsInfo = [dict objectForKey:@"positions"];
        NSArray* allKeys = [positionsInfo allKeys];
        for(NSString* uuid in allKeys)
        {
            CGPoint pos = [positionsInfo pointForKey:uuid];            
            NSValue* val = LHValueWithCGPoint(pos);
            [_positions setObject:val forKey:uuid];
        }
    }
    return self;
}

-(CGPoint)positionForUUID:(NSString *)uuid{
    return CGPointFromValue([_positions objectForKey:uuid]);
}


@end
