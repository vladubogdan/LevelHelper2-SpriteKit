//
//  LHBoneFrame.m
//  LevelHelper2-API
//
//  Created by Bogdan Vladu on 7/10/13.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#import "LHBoneFrame.h"
#import "LHSprite.h"
#import "LHNode.h"
#import "LHBone.h"
#import "LHBoneNodes.h"

#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"

#import "LHAnimationProperty.h"
#import "LHAnimation.h"


@implementation LHBoneFrameInfo
{
    float       rotation;
    CGPoint     position;
}

-(id)initWithDictionary:(NSDictionary*)dict{
    
    self = [super init];
    if(self){
        
        position = [dict pointForKey:@"pos"];
        rotation = [dict floatForKey:@"rot"];
    }
    return self;
}

-(float)rotation{
    return rotation;
}
-(void)setRotation:(float)rot{
    rotation = rot;
}
-(CGPoint)position{
    return position;
}
-(void)setPosition:(CGPoint)pt{
    position = pt;
}

@end


@implementation LHBoneFrame
{
    NSMutableDictionary* bonesInfo; //key: bone name - obj: LHBoneFrameInfo
}


-(void)dealloc{
    LH_SAFE_RELEASE(bonesInfo);
    LH_SUPER_DEALLOC();    
}

-(instancetype)initFrameWithDictionary:(NSDictionary*)dict
                              property:(LHAnimationProperty*)prop{
    
    if(self = [super initFrameWithDictionary:dict
                                    property:prop])
    {
        bonesInfo = [[NSMutableDictionary alloc] init];

        NSDictionary* savedBonesInfo = [dict objectForKey:@"bonesInfo"];
        
        NSArray* allKeys = [savedBonesInfo allKeys];
        for(NSString* name in allKeys)
        {
            NSDictionary* boneDict = [savedBonesInfo objectForKey:name];
            LHBoneFrameInfo* inf = LH_AUTORELEASED([[LHBoneFrameInfo alloc] initWithDictionary:boneDict]);
            [bonesInfo setObject:inf forKey:name];
        }
    }
    return self;
}

-(LHBoneFrameInfo*)boneFrameInfoForBoneNamed:(NSString*)nm{
    return [bonesInfo objectForKey:nm];
}

@end
