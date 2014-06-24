//
//  LHPrismaticJointNode.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHPrismaticJointNode.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"

@implementation LHPrismaticJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    
    SKPhysicsJointSliding* joint;
    
    SKShapeNode* debugShapeNode;
    
    CGPoint axis;
    CGPoint relativePosA;
    
    __weak SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeA;
    __weak SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeB;
    
    NSString* nodeAUUID;
    NSString* nodeBUUID;
    
    BOOL _enableLimits;
    float _lowerTranslation;
    float _upperTranslation;
}

+(instancetype)prismaticJointNodeWithDictionary:(NSDictionary*)dict
                                         parent:(SKNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initPrismaticJointNodeWithDictionary:dict
                                                                       parent:prnt]);
}

-(void)dealloc{
    nodeA = nil;
    nodeB = nil;
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SAFE_RELEASE(nodeAUUID);
    LH_SAFE_RELEASE(nodeBUUID);
    
    LH_SUPER_DEALLOC();
}

-(instancetype)initPrismaticJointNodeWithDictionary:(NSDictionary*)dict
                                             parent:(SKNode*)prnt
{
    if(self = [super init]){
        
        [prnt addChild:self];
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        nodeAUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteAUUID"]];
        nodeBUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteBUUID"]];
        relativePosA = [dict pointForKey:@"relativePosA"];
        axis = [dict pointForKey:@"axis"];
        axis.y = -axis.y;
        
        _enableLimits = [dict boolForKey:@"enablePrismaticLimit"];
        _lowerTranslation = [dict floatForKey:@"lowerTranslation"];
        _upperTranslation = [dict floatForKey:@"upperTranslation"];;        
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

-(CGPoint)anchor{
    CGAffineTransform transformA = CGAffineTransformRotate(CGAffineTransformIdentity,
                                                           joint.bodyA.node.zRotation);
    
    CGPoint curAnchorA = CGPointApplyAffineTransform(CGPointMake(relativePosA.x, -relativePosA.y),
                                                     transformA);
    
    return CGPointMake(nodeA.position.x + curAnchorA.x,
                       nodeA.position.y + curAnchorA.y);
}


-(SKPhysicsJointSliding*)joint{
    return joint;
}

-(CGPoint)axis{
    return axis;
}

-(BOOL)shouldEnableLimits{
    if(joint){
        return joint.shouldEnableLimits;
    }
    return NO;
}

-(CGFloat)lowerDistanceLimit{
    if(joint){
        return joint.lowerDistanceLimit;
    }
    return 0;
}

-(CGFloat)upperDistanceLimit{
    if(joint){
        return joint.upperDistanceLimit;
    }
    return 0;
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{
    if(debugShapeNode){
        CGPoint a = [self anchor];
        
        CGPoint axisInfoA = CGPointMake(a.x+ (-10*axis.x), a.y + (-10*axis.y));
        CGPoint axisInfoB = CGPointMake(a.x+ ( 10*axis.x), a.y + ( 10*axis.y));
        
        if([self shouldEnableLimits])
        {
            axisInfoA = CGPointMake(a.x+ ( [self lowerDistanceLimit]*axis.x), a.y + ( [self lowerDistanceLimit]*axis.y));
            axisInfoB = CGPointMake(a.x+ ( [self upperDistanceLimit]*axis.x), a.y + ( [self upperDistanceLimit]*axis.y));
        }

        CGMutablePathRef debugLinePath = CGPathCreateMutable();
        CGPathMoveToPoint(debugLinePath, nil, axisInfoA.x, axisInfoA.y);
        CGPathAddLineToPoint(debugLinePath, nil, axisInfoB.x, axisInfoB.y);
        debugShapeNode.path = debugLinePath;
        CGPathRelease(debugLinePath);
    }
}

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
        CGPoint anchorA = CGPointMake(nodeA.position.x + relativePosA.x,
                                      nodeA.position.y - relativePosA.y);
        
        joint = [SKPhysicsJointSliding jointWithBodyA:nodeA.physicsBody
                                                bodyB:nodeB.physicsBody
                                               anchor:anchorA
                                                 axis:CGVectorMake(axis.x, axis.y)];
        
        joint.shouldEnableLimits = _enableLimits;
        joint.lowerDistanceLimit = _lowerTranslation;
        joint.upperDistanceLimit = _upperTranslation;
        
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
