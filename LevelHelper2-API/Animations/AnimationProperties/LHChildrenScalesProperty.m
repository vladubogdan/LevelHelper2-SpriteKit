//
//  LHChildrenScalesProperty.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHChildrenScalesProperty.h"
#import "LHScaleFrame.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodeProtocol.h"
#import "LHUtils.h"
#import "LHConfig.h"

@implementation LHChildrenScalesProperty

-(LHAnimationProperty*)newSubpropertyForNode:(id<LHNodeAnimationProtocol, LHNodeProtocol>)node
{
    LHScaleProperty* prop = LH_AUTORELEASED([[LHScaleProperty alloc] initAnimationPropertyWithDictionary:nil
                                                                                               animation:[self animation]]);
    
    [prop setSubpropertyNode:node];
    return prop;
}
@end
