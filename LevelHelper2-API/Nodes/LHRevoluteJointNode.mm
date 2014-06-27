//
//  LHRevoluteJointNode.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHRevoluteJointNode.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"
#import "SKNode+Transforms.h"

@implementation LHRevoluteJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHJointNodeProtocolImp*     _jointProtocolImp;
    
    SKShapeNode* debugShapeNode;
    
    BOOL    _enableLimit;
    float   _lowerAngleRadians;
    float   _upperAngleRadians;
    BOOL    _maxMotorTorque;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    [_jointProtocolImp setJoint:nil];//at this point the joint no longer exits
    LH_SAFE_RELEASE(_jointProtocolImp);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)revoluteJointNodeWithDictionary:(NSDictionary*)dict
                                    parent:(SKNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initRevoluteJointNodeWithDictionary:dict
                                                                      parent:prnt]);
}

-(instancetype)initRevoluteJointNodeWithDictionary:(NSDictionary*)dict
                                            parent:(SKNode*)prnt
{
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        _jointProtocolImp= [[LHJointNodeProtocolImp alloc] initJointProtocolImpWithDictionary:dict
                                                                                         node:self];
        
        _enableLimit = [dict boolForKey:@"enableLimit"];
        _lowerAngleRadians = LH_DEGREES_TO_RADIANS([dict boolForKey:@"lowerAngle"] - 90);
        _upperAngleRadians = LH_DEGREES_TO_RADIANS([dict boolForKey:@"upperAngle"] - 90);
        _maxMotorTorque = [dict boolForKey:@"maxMotorTorque"];
        
    }
    return self;
}

-(void)removeFromParent{
    LH_SAFE_RELEASE(_jointProtocolImp);
    [super removeFromParent];
}

-(BOOL)hasLimit{
    return _enableLimit;
}
-(float)lowerAngleLimit{
    return LH_RADIANS_TO_DEGREES(_lowerAngleRadians);
}
-(float)upperAngleLimit{
    return LH_RADIANS_TO_DEGREES(_upperAngleRadians);
}

#pragma mark - LHJointNodeProtocol Required
LH_JOINT_PROTOCOL_COMMON_METHODS_IMPLEMENTATION
LH_JOINT_PROTOCOL_SPECIFIC_PHYSICS_ENGINE_METHODS_IMPLEMENTATION


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{
    if(debugShapeNode){
        debugShapeNode.position = [self anchorA];
    }
}

#pragma mark LHNodeProtocol Optional

-(BOOL)lateLoading{
    
    [_jointProtocolImp findConnectedNodes];
    
    SKNode<LHNodePhysicsProtocol>* nodeA = [_jointProtocolImp nodeA];
    SKNode<LHNodePhysicsProtocol>* nodeB = [_jointProtocolImp nodeB];
    
    CGPoint relativePosA = [_jointProtocolImp localAnchorA];
    
    if(nodeA && nodeB)
    {
#if LH_USE_BOX2D
        
#else//spritekit
        
    if(nodeA.physicsBody && nodeB.physicsBody)
    {
        LHScene* scene = [self scene];

        CGPoint anchorA = [nodeA convertToWorldSpace:relativePosA];
                
        SKPhysicsJointPin* joint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody
                                                               bodyB:nodeB.physicsBody
                                                              anchor:anchorA];
        
        joint.shouldEnableLimits= _enableLimit;
        joint.lowerAngleLimit   = _lowerAngleRadians;
        joint.upperAngleLimit   = _upperAngleRadians;
        joint.frictionTorque    = _maxMotorTorque;
        
        [scene.physicsWorld addJoint:joint];
        [_jointProtocolImp setJoint:joint];
        
#if LH_DEBUG
            debugShapeNode = [SKShapeNode node];
            debugShapeNode.position = anchorA;//[self anchorA];
            CGPathRef pathRef = CGPathCreateWithEllipseInRect(CGRectMake(-8, -8, 16, 16), nil);
            debugShapeNode.path = pathRef;
            CGPathRelease(pathRef);
            debugShapeNode.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];
            [self addChild:debugShapeNode];
#endif
        
    }
        
#endif
        
        return true;
    }
    return false;
}
@end
