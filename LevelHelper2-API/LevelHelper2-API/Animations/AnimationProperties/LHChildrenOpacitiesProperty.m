//
//  LHChildrenOpacitiesProperty.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHChildrenOpacitiesProperty.h"
#import "LHOpacityFrame.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodeProtocol.h"
#import "LHUtils.h"
#import "LHConfig.h"

@implementation LHChildrenOpacitiesProperty

-(LHAnimationProperty*)newSubpropertyForNode:(id<LHNodeAnimationProtocol, LHNodeProtocol>)node
{
    LHOpacityProperty* prop = LH_AUTORELEASED([[LHOpacityProperty alloc] initAnimationPropertyWithDictionary:nil
                                                                                                   animation:[self animation]]);
    
    [prop setSubpropertyNode:node];
    return prop;
}
@end
