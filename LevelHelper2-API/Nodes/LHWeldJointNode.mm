//
//  LHWeldJointNode.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHWeldJointNode.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"
#import "SKNode+Transforms.h"

@implementation LHWeldJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHJointNodeProtocolImp*     _jointProtocolImp;
    
    SKShapeNode* debugShapeNode;
}

-(void)dealloc{

    [_jointProtocolImp setJoint:nil];//at this point the joint is already released
    LH_SAFE_RELEASE(_jointProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)weldJointNodeWithDictionary:(NSDictionary*)dict
                                    parent:(SKNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initWeldJointNodeWithDictionary:dict
                                                                  parent:prnt]);
}

-(instancetype)initWeldJointNodeWithDictionary:(NSDictionary*)dict
                                        parent:(SKNode*)prnt
{
    if(self = [super init]){
        
        [prnt addChild:self];
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        _jointProtocolImp= [[LHJointNodeProtocolImp alloc] initJointProtocolImpWithDictionary:dict
                                                                                         node:self];
    }
    return self;
}


-(void)removeFromParent{
    LH_SAFE_RELEASE(_jointProtocolImp);
    [super removeFromParent];
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

-(BOOL)lateLoading
{
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
            
            CGPoint anchorA = [nodeA convertToWorldSpace:relativePosA];
            
            SKPhysicsJointFixed* joint = [SKPhysicsJointFixed jointWithBodyA:nodeA.physicsBody
                                                  bodyB:nodeB.physicsBody
                                                 anchor:anchorA];
            [[self scene].physicsWorld addJoint:joint];
            [_jointProtocolImp setJoint:joint];
            
    #if LH_DEBUG
                debugShapeNode = [SKShapeNode node];
                debugShapeNode.position = anchorA;
                CGPathRef pathRef = CGPathCreateWithEllipseInRect(CGRectMake(-10, -10, 20, 20), nil);
                debugShapeNode.path = pathRef;
                debugShapeNode.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];
                [self addChild:debugShapeNode];
                CGPathRelease(pathRef);
    #endif
        }
#endif
        
        return true;
    }
    return false;
}

@end
