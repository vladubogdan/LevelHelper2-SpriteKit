//
//  LHNode.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHNode.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHAnimation.h"

@implementation LHNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_physicsProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);

    LH_SUPER_DEALLOC();
}

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                     parent:prnt]);
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];

        //scale is handled by physics protocol because of diferences between spritekit and box2d handling
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];

        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];


//#if LH_DEBUG
//        CGSize _size = [dict sizeForKey:@"size"];
//        SKShapeNode* debugShapeNode = [SKShapeNode node];
//        CGPathRef pathRef = CGPathCreateWithRect(CGRectMake(-_size.width*0.5,
//                                                            -_size.height*0.5,
//                                                            _size.width,
//                                                            _size.height),
//                                                 nil);
//        debugShapeNode.path = pathRef;
//        CGPathRelease(pathRef);
//        debugShapeNode.strokeColor = [SKColor greenColor];
//        [self addChild:debugShapeNode];
//#endif
    }
    
    return self;
}


#pragma mark - Box2D Support
#if LH_USE_BOX2D
LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION
#endif //LH_USE_BOX2D


#pragma mark - Common Physics Engines Support
LH_COMMON_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION



#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    [_physicsProtocolImp update:currentTime delta:dt];
    [_nodeProtocolImp update:currentTime delta:dt];
    [_animationProtocolImp update:currentTime delta:dt];    
}

#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
