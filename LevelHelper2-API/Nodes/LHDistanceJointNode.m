//
//  LHDistanceJointNode.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHDistanceJointNode.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"

@implementation LHDistanceJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;

    
    SKPhysicsJointSpring* joint;
    
    SKShapeNode* debugShapeNode;
    
    CGPoint relativePosA;
    CGPoint relativePosB;
    
    NSString* nodeAUUID;
    NSString* nodeBUUID;
    
    __weak SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeA;
    __weak SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeB;
    
    float _dampingRatio;
    float _frequency;
}

-(void)dealloc{
    nodeA = nil;
    nodeB = nil;
    
    LH_SAFE_RELEASE(_nodeProtocolImp);

    LH_SAFE_RELEASE(nodeAUUID);
    LH_SAFE_RELEASE(nodeBUUID);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)distanceJointNodeWithDictionary:(NSDictionary*)dict
                                    parent:(SKNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initDistanceJointNodeWithDictionary:dict
                                                                      parent:prnt]);
}

-(instancetype)initDistanceJointNodeWithDictionary:(NSDictionary*)dict
                                            parent:(SKNode*)prnt
{
    if(self = [super init]){
        
        [prnt addChild:self];

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                   node:self];
        
        
        relativePosA = [dict pointForKey:@"relativePosA"];
        relativePosB = [dict pointForKey:@"relativePosB"];

        nodeAUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteAUUID"]];
        nodeBUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteBUUID"]];
        
        _dampingRatio =[dict floatForKey:@"dampingRatio"];
        _frequency = [dict floatForKey:@"frequency"];
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

-(CGPoint)anchorB{
    CGAffineTransform transformB = CGAffineTransformRotate(CGAffineTransformIdentity,
                                                           joint.bodyB.node.zRotation);
    
    CGPoint curAnchorB = CGPointApplyAffineTransform(CGPointMake(relativePosB.x, -relativePosB.y),
                                                     transformB);
    
    return CGPointMake(nodeB.position.x + curAnchorB.x,
                       nodeB.position.y + curAnchorB.y);
}

-(SKPhysicsJointSpring*)joint{
    return joint;
}

-(CGFloat)damping{
    if(joint){
        return joint.damping;
    }
    return 0;
}

-(CGFloat)frequency{
    if(joint){
        return joint.frequency;
    }
    return 0;
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{
    if(debugShapeNode){
        CGPoint anchorA = [self anchorA];
        CGPoint anchorB = [self anchorB];
        
        CGMutablePathRef debugLinePath = CGPathCreateMutable();
        CGPathMoveToPoint(debugLinePath, nil, anchorA.x, anchorA.y);
        CGPathAddLineToPoint(debugLinePath, nil, anchorB.x, anchorB.y);
        debugShapeNode.path = debugLinePath;
        CGPathRelease(debugLinePath);
    }
}

#pragma mark LHNodeProtocol Optional

-(BOOL)lateLoading
{
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
        CGPoint ptB = [scene convertPoint:CGPointZero fromNode:nodeB];
        
        CGPoint anchorA = CGPointMake(ptA.x + relativePosA.x,
                                      ptA.y - relativePosA.y);
        
        CGPoint anchorB = CGPointMake(ptB.x + relativePosB.x,
                                      ptB.y - relativePosB.y);
        
        joint = [SKPhysicsJointSpring jointWithBodyA:nodeA.physicsBody
                                               bodyB:nodeB.physicsBody
                                             anchorA:anchorA
                                             anchorB:anchorB];
        
        
        joint.damping = _dampingRatio;
        joint.frequency = _frequency;
        
        [scene.physicsWorld addJoint:joint];
        
#if LH_DEBUG
            debugShapeNode = [SKShapeNode node];
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
