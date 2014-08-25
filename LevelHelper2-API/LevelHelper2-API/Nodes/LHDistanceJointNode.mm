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
#import "LHGameWorldNode.h"

#import "SKNode+Transforms.h"

@implementation LHDistanceJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHJointNodeProtocolImp*     _jointProtocolImp;
    
    SKShapeNode* debugShapeNode;
    
    float _dampingRatio;
    float _frequency;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_jointProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);

    
    LH_SUPER_DEALLOC();
}


+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(SKNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                     parent:prnt]);
}

-(instancetype)initWithDictionary:(NSDictionary*)dict
                           parent:(SKNode*)prnt
{
    if(self = [super init]){
        
        [prnt addChild:self];

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                   node:self];
        
        _jointProtocolImp= [[LHJointNodeProtocolImp alloc] initJointProtocolImpWithDictionary:dict
                                                                                         node:self];

        
        _dampingRatio =[dict floatForKey:@"dampingRatio"];
        _frequency = [dict floatForKey:@"frequency"];
    }
    return self;
}

-(void)removeFromParent{
    LH_SAFE_RELEASE(_jointProtocolImp);
    [super removeFromParent];
}

-(CGFloat)damping{
    return _dampingRatio;
}

-(CGFloat)frequency{
    return _frequency;
}

#pragma mark - LHJointNodeProtocol Required
LH_JOINT_PROTOCOL_COMMON_METHODS_IMPLEMENTATION
LH_JOINT_PROTOCOL_SPECIFIC_PHYSICS_ENGINE_METHODS_IMPLEMENTATION


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{

    if(![_jointProtocolImp nodeA] ||  ![_jointProtocolImp nodeB]){
        [self lateLoading];
    }
    
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
    [_jointProtocolImp findConnectedNodes];
    
    SKNode<LHNodePhysicsProtocol>* nodeA = [_jointProtocolImp nodeA];
    SKNode<LHNodePhysicsProtocol>* nodeB = [_jointProtocolImp nodeB];
    
    CGPoint relativePosA = [_jointProtocolImp localAnchorA];
    CGPoint relativePosB = [_jointProtocolImp localAnchorB];
    
    if(nodeA && nodeB)
    {
        
#if LH_USE_BOX2D
        
        LHScene* scene = (LHScene*)[self scene];
        LHGameWorldNode* pNode = (LHGameWorldNode*)[scene gameWorldNode];
        
        b2World* world = [pNode box2dWorld];
        
        if(world == nil)return NO;
        
        b2Body* bodyA = [nodeA box2dBody];
        b2Body* bodyB = [nodeB box2dBody];
        
        if(!bodyA || !bodyB)return NO;
        
        b2Vec2 relativeA = [scene metersFromPoint:relativePosA];
        b2Vec2 relativeB = [scene metersFromPoint:relativePosB];
        
        b2Vec2 posA = bodyA->GetWorldPoint(relativeA);
        b2Vec2 posB = bodyB->GetWorldPoint(relativeB);
        
        b2DistanceJointDef jointDef;
        
        jointDef.Initialize(bodyA,
                            bodyB,
                            posA,
                            posB);
        
        jointDef.collideConnected = [_jointProtocolImp collideConnected];
        
        jointDef.frequencyHz  = _frequency;
        jointDef.dampingRatio = _dampingRatio;
        
        b2DistanceJoint* joint = (b2DistanceJoint*)world->CreateJoint(&jointDef);
        
        [_jointProtocolImp setJoint:joint];
        
#else//spritekit
        
        if(nodeA.physicsBody && nodeB.physicsBody)
        {

            CGPoint anchorA = [nodeA convertToWorldSpace:relativePosA];
            CGPoint anchorB = [nodeB convertToWorldSpace:relativePosB];

            
            SKPhysicsJointSpring* joint = [SKPhysicsJointSpring jointWithBodyA:nodeA.physicsBody
                                                                         bodyB:nodeB.physicsBody
                                                                       anchorA:anchorA
                                                                       anchorB:anchorB];
            
            joint.damping = _dampingRatio;
            joint.frequency = _frequency;
            
            [[self scene].physicsWorld addJoint:joint];
            [_jointProtocolImp setJoint:joint];
            
    #if LH_DEBUG
                debugShapeNode = [SKShapeNode node];
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
