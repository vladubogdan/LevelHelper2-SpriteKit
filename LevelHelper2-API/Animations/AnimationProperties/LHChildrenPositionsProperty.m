//
//  LHChildrenPositionsProperty.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHChildrenPositionsProperty.h"
#import "LHPositionFrame.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodeProtocol.h"
#import "LHPositionProperty.h"
#import "LHUtils.h"
#import "LHConfig.h"

@implementation LHChildrenPositionsProperty

-(LHAnimationProperty*)newSubpropertyForNode:(id<LHNodeAnimationProtocol, LHNodeProtocol>)node
{
    LHPositionProperty* prop = LH_AUTORELEASED([[LHPositionProperty alloc] initAnimationPropertyWithDictionary:nil
                                                                                                    animation:[self animation]]);
    
    [prop setSubpropertyNode:node];
    return prop;
}
@end
