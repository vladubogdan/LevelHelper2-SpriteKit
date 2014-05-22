//
//  LHChildrenRotationsProperty.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHChildrenRotationsProperty.h"
#import "LHRotationFrame.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodeProtocol.h"
#import "LHRotationProperty.h"
#import "LHUtils.h"
#import "LHConfig.h"

@implementation LHChildrenRotationsProperty

-(LHAnimationProperty*)newSubpropertyForNode:(id<LHNodeAnimationProtocol, LHNodeProtocol>)node
{
    LHRotationProperty* prop = LH_AUTORELEASED([[LHRotationProperty alloc] initAnimationPropertyWithDictionary:nil
                                                                                                    animation:[self animation]]);
    
    [prop setSubpropertyNode:node];
    return prop;
}
@end
