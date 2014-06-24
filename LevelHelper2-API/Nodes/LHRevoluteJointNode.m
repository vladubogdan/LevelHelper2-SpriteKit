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

@implementation LHRevoluteJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    
    SKPhysicsJointPin* joint;
    
    SKShapeNode* debugShapeNode;
    
    CGPoint relativePosA;
    
    NSString* nodeAUUID;
    NSString* nodeBUUID;

    __weak SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeA;
    __weak SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeB;
    
    BOOL    _enableLimit;
    float   _lowerAngleRadians;
    float   _upperAngleRadians;
    BOOL    _maxMotorTorque;
}

-(void)dealloc{
    nodeA = nil;
    nodeB = nil;
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SAFE_RELEASE(nodeAUUID);
    LH_SAFE_RELEASE(nodeBUUID);
    
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
        
        
        nodeAUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteAUUID"]];
        nodeBUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteBUUID"]];
        relativePosA = [dict pointForKey:@"relativePosA"];

        _enableLimit = [dict boolForKey:@"enableLimit"];
        _lowerAngleRadians = LH_DEGREES_TO_RADIANS([dict boolForKey:@"lowerAngle"] - 90);
        _upperAngleRadians = LH_DEGREES_TO_RADIANS([dict boolForKey:@"upperAngle"] - 90);
        _maxMotorTorque = [dict boolForKey:@"maxMotorTorque"];
        
    }
    return self;
}

-(void)removeFromParent{
    if(joint){
        [[self scene].physicsWorld removeJoint:joint];
        joint = nil;
    }
    
    [super removeFromParent];
}

-(CGPoint)anchorA{
    CGAffineTransform transformA = CGAffineTransformRotate(CGAffineTransformIdentity,
                                                           joint.bodyA.node.zRotation);
    
    CGPoint curAnchorA = CGPointApplyAffineTransform(CGPointMake(relativePosA.x, -relativePosA.y),
                                                     transformA);
    
    return CGPointMake(nodeA.position.x + curAnchorA.x,
                       nodeA.position.y + curAnchorA.y);
}

-(SKPhysicsJointPin*)joint{
    return joint;
}

-(BOOL)hasLimit{
    if(joint){
        return joint.shouldEnableLimits;
    }
    return NO;
}
-(float)lowerAngleLimit{
    if(joint){
        return LH_RADIANS_TO_DEGREES(joint.lowerAngleLimit);
    }
    return 0;
}
-(float)upperAngleLimit{
    if(joint){
        return LH_RADIANS_TO_DEGREES(joint.upperAngleLimit);
    }
    return 0;
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{
    if(debugShapeNode){
        debugShapeNode.position = [self anchorA];
    }
}

#pragma mark LHNodeProtocol Optional

-(BOOL)lateLoading{
    
    if(!nodeAUUID || !nodeBUUID)
        return true;
    
    LHScene* scene = (LHScene*)[self scene];
    
    if([[self parent] conformsToProtocol:@protocol(LHNodeProtocol)])
    {
        nodeA = (SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[(id<LHNodeProtocol>)[self parent] childNodeWithUUID:nodeAUUID];
        nodeB = (SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[(id<LHNodeProtocol>)[self parent] childNodeWithUUID:nodeBUUID];
    }
    else{
        nodeA = (SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[scene childNodeWithUUID:nodeAUUID];
        nodeB = (SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[scene childNodeWithUUID:nodeBUUID];
    }
    
    if(nodeA && nodeB && nodeA.physicsBody && nodeB.physicsBody)
    {
        CGPoint ptA = [scene convertPoint:CGPointZero fromNode:nodeA];
        CGPoint anchorA = CGPointMake(ptA.x + relativePosA.x,
                                      ptA.y - relativePosA.y);
        
        joint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody
                                            bodyB:nodeB.physicsBody
                                           anchor:anchorA];
        
        joint.shouldEnableLimits= _enableLimit;
        joint.lowerAngleLimit   = _lowerAngleRadians;
        joint.upperAngleLimit   = _upperAngleRadians;
        joint.frictionTorque    = _maxMotorTorque;
        
        [scene.physicsWorld addJoint:joint];
        
#if LH_DEBUG
            debugShapeNode = [SKShapeNode node];
            debugShapeNode.position = anchorA;
            debugShapeNode.path = CGPathCreateWithEllipseInRect(CGRectMake(-10, -10, 20, 20), nil);
            debugShapeNode.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];
            [self addChild:debugShapeNode];
#endif
        
        LH_SAFE_RELEASE(nodeAUUID);
        LH_SAFE_RELEASE(nodeBUUID);
        return true;
    }
    return false;
}
@end
