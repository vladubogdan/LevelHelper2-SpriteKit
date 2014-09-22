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
#import "LHGameWorldNode.h"


@implementation LHRevoluteJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHJointNodeProtocolImp*     _jointProtocolImp;
    
    SKShapeNode* debugShapeNode;
    
    BOOL _enableLimit;
    BOOL _enableMotor;
    
    float _lowerAngle;
    float _upperAngle;
    
    float _maxMotorTorque;
    float _motorSpeed;
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
        
        _enableLimit = [dict boolForKey:@"enableLimit"];
        _enableMotor = [dict boolForKey:@"enableMotor"];
        
        _lowerAngle = LH_DEGREES_TO_RADIANS([dict floatForKey:@"lowerAngle"] - 180.0f);
        _upperAngle = LH_DEGREES_TO_RADIANS([dict floatForKey:@"upperAngle"] - 180.0f);
        
        _maxMotorTorque = [dict floatForKey:@"maxMotorTorque"];
        _motorSpeed = LH_DEGREES_TO_RADIANS(-360.0f*[dict floatForKey:@"motorSpeed"]);
    }
    return self;
}

-(void)removeFromParent{
    LH_SAFE_RELEASE(_jointProtocolImp);
    [super removeFromParent];
}

-(BOOL)enableLimit{
    return _enableLimit;
}
-(BOOL)enableMotor{
    return _enableMotor;
}
-(CGFloat)lowerAngle{
    return _lowerAngle;
}
-(CGFloat)upperAngle{
    return _upperAngle;
}
-(CGFloat)maxMotorTorque{
    return _maxMotorTorque;
}
-(CGFloat)motorSpeed{
    return _motorSpeed;
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
    
//    if(debugShapeNode){
//        CGPoint localAnchorA = [_jointProtocolImp localAnchorA];
//        localAnchorA = CGPointMake(localAnchorA.x, -localAnchorA.y);
//        CGPoint worldAnchorA = [[_jointProtocolImp nodeA] convertToWorldSpace:localAnchorA];
//        localAnchorA = [self convertToNodeSpace:worldAnchorA];
//        debugShapeNode.position = localAnchorA;
//    }
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
        LHScene* scene = (LHScene*)[self scene];
        LHGameWorldNode* pNode = (LHGameWorldNode*)[scene gameWorldNode];
        
        b2World* world = [pNode box2dWorld];
        
        if(world == nil)return NO;
        
        b2Body* bodyA = [nodeA box2dBody];
        b2Body* bodyB = [nodeB box2dBody];
        
        if(!bodyA || !bodyB)return NO;
        
        b2Vec2 relativeA = [scene metersFromPoint:relativePosA];
        b2Vec2 posA = bodyA->GetWorldPoint(relativeA);
        
        b2RevoluteJointDef jointDef;
        
        jointDef.Initialize(bodyA,
                            bodyB,
                            posA);
        
        jointDef.collideConnected = [_jointProtocolImp collideConnected];
        
        jointDef.enableLimit = _enableLimit;
        jointDef.enableMotor = _enableMotor;
        
        if(_lowerAngle < _upperAngle){
            jointDef.lowerAngle = _lowerAngle;
            jointDef.upperAngle = _upperAngle;
        }
        else{
            jointDef.lowerAngle = _upperAngle;
            jointDef.upperAngle = _lowerAngle;
        }
        
        jointDef.maxMotorTorque = _maxMotorTorque;
        jointDef.motorSpeed = _motorSpeed;
        
        b2RevoluteJoint* joint = (b2RevoluteJoint*)world->CreateJoint(&jointDef);
        
        [_jointProtocolImp setJoint:joint];
        
#else//spritekit
        
    if(nodeA.physicsBody && nodeB.physicsBody)
    {
        LHScene* scene = [self scene];

        CGPoint anchorA = [nodeA convertToWorldSpace:relativePosA];
                
        SKPhysicsJointPin* joint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody
                                                               bodyB:nodeB.physicsBody
                                                              anchor:anchorA];
        
        joint.shouldEnableLimits= _enableLimit;
        joint.lowerAngleLimit   = _lowerAngle;
        joint.upperAngleLimit   = _upperAngle;
        
        joint.frictionTorque    = _maxMotorTorque;
        
        [scene.physicsWorld addJoint:joint];
        [_jointProtocolImp setJoint:joint];
        
//#if LH_DEBUG
//            debugShapeNode = [SKShapeNode node];
//            debugShapeNode.position = anchorA;//[self anchorA];
//            CGPathRef pathRef = CGPathCreateWithEllipseInRect(CGRectMake(-8, -8, 16, 16), nil);
//            debugShapeNode.path = pathRef;
//            CGPathRelease(pathRef);
//            debugShapeNode.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];
//            [self addChild:debugShapeNode];
//#endif
        
    }
        
#endif
        
        return true;
    }
    return false;
}
@end
