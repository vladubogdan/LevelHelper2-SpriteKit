//
//  LHSpriteFrame.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHSpriteFrame.h"
#import "LHUtils.h"
#import "LHConfig.h"
#import "NSDictionary+LHDictionary.h"

#import "LHAnimationProperty.h"
#import "LHAnimation.h"

@implementation LHSpriteFrame
{
    NSString* spriteFrameName;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(spriteFrameName);
    LH_SUPER_DEALLOC();
}

-(instancetype)initFrameWithDictionary:(NSDictionary*)dict
                              property:(LHAnimationProperty*)prop{
    
    if(self = [super initFrameWithDictionary:dict
                                    property:prop]){
        
        spriteFrameName = [[NSString alloc] initWithString:[dict objectForKey:@"spriteSheetName"]];
    }
    return self;
}

-(NSString*)spriteFrameName{
    return spriteFrameName;
}

@end
