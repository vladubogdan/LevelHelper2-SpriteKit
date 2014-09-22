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
#import "SKNode+Transforms.h"
#import "LHGameWorldNode.h"


@implementation LHPrismaticJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHJointNodeProtocolImp*     _jointProtocolImp;
    
    SKShapeNode* debugShapeNode;
    
    BOOL _enableLimit;
    BOOL _enableMotor;
    
    float _lowerTranslation;
    float _upperTranslation;
    
    float _maxMotorForce;
    float _motorSpeed;
    
    CGPoint _axis;
}

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                     parent:prnt]);
}

-(void)dealloc{
    LH_SAFE_RELEASE(_jointProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SUPER_DEALLOC();
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


        _enableLimit = [dict boolForKey:@"enablePrismaticLimit"];
        _enableMotor = [dict boolForKey:@"enablePrismaticMotor"];
        
        _lowerTranslation = [dict floatForKey:@"lowerTranslation"];
        _upperTranslation = [dict floatForKey:@"upperTranslation"];
        
        _maxMotorForce = [dict floatForKey:@"maxMotorForce"];
        _motorSpeed = [dict floatForKey:@"prismaticMotorSpeed"];
        
        _axis = [dict pointForKey:@"axis"];
        _axis.y = -_axis.y;
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
-(CGFloat)lowerTranslation{
    return _lowerTranslation;
}
-(CGFloat)upperTranslation{
    return _upperTranslation;
}
-(CGFloat)maxMotorForce{
    return _maxMotorForce;
}
-(CGFloat)motorSpeed{
    return _motorSpeed;
}
-(CGPoint)axis{
    return _axis;
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
        CGPoint a = [self anchorA];
        
        CGPoint axisInfoA = CGPointMake(a.x+ (-10*_axis.x), a.y + (-10*_axis.y));
        CGPoint axisInfoB = CGPointMake(a.x+ ( 10*_axis.x), a.y + ( 10*_axis.y));
        
        if([self enableLimit])
        {
            axisInfoA = CGPointMake(a.x+ ( [self lowerTranslation]*_axis.x), a.y + ( [self lowerTranslation]*_axis.y));
            axisInfoB = CGPointMake(a.x+ ( [self upperTranslation]*_axis.x), a.y + ( [self upperTranslation]*_axis.y));
        }

        CGMutablePathRef debugLinePath = CGPathCreateMutable();
        CGPathMoveToPoint(debugLinePath, nil, axisInfoA.x, axisInfoA.y);
        CGPathAddLineToPoint(debugLinePath, nil, axisInfoB.x, axisInfoB.y);
        debugShapeNode.path = debugLinePath;
        CGPathRelease(debugLinePath);
    }
}

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
        
        b2PrismaticJointDef jointDef;
        
        jointDef.Initialize(bodyA, bodyB, posA, b2Vec2(-_axis.x,_axis.y));
        
        jointDef.enableLimit = _enableLimit;
        jointDef.enableMotor = _enableMotor;
        jointDef.maxMotorForce = _maxMotorForce;
        jointDef.motorSpeed = _motorSpeed;

        if(_lowerTranslation < _upperTranslation){
            jointDef.upperTranslation = [scene metersFromValue:_upperTranslation];
            jointDef.lowerTranslation = [scene metersFromValue:_lowerTranslation];
        }
        else{
            jointDef.upperTranslation = [scene metersFromValue:_lowerTranslation];
            jointDef.lowerTranslation = [scene metersFromValue:_upperTranslation];
        }
        
        
        jointDef.collideConnected = [_jointProtocolImp collideConnected];
        
        b2PrismaticJoint* joint = (b2PrismaticJoint*)world->CreateJoint(&jointDef);
        
        [_jointProtocolImp setJoint:joint];
        
#else//spritekit
        
        if(nodeA.physicsBody && nodeB.physicsBody)
        {
            CGPoint anchorA = [nodeA convertToWorldSpace:relativePosA];
            
            SKPhysicsJointSliding* joint = [SKPhysicsJointSliding jointWithBodyA:nodeA.physicsBody
                                                                           bodyB:nodeB.physicsBody
                                                                          anchor:anchorA
                                                                            axis:CGVectorMake(-_axis.x, _axis.y)];
            
            joint.shouldEnableLimits = _enableLimit;
            
            if(_lowerTranslation < _upperTranslation){
                joint.lowerDistanceLimit = _lowerTranslation;
                joint.upperDistanceLimit = _upperTranslation;
                
            }
            else{
                joint.lowerDistanceLimit = _upperTranslation;
                joint.upperDistanceLimit = _lowerTranslation;
            }
            
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
