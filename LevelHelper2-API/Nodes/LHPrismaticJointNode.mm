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


@implementation LHPrismaticJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHJointNodeProtocolImp*     _jointProtocolImp;
    
    SKShapeNode* debugShapeNode;
    
    CGPoint axis;
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

    [_jointProtocolImp setJoint:nil];//at this point the joint is released
    
    LH_SAFE_RELEASE(_jointProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SUPER_DEALLOC();
}

-(instancetype)initPrismaticJointNodeWithDictionary:(NSDictionary*)dict
                                             parent:(SKNode*)prnt
{
    if(self = [super init]){
        
        [prnt addChild:self];
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        _jointProtocolImp= [[LHJointNodeProtocolImp alloc] initJointProtocolImpWithDictionary:dict
                                                                                         node:self];


        axis = [dict pointForKey:@"axis"];
        axis.y = -axis.y;
        
        _enableLimits = [dict boolForKey:@"enablePrismaticLimit"];
        _lowerTranslation = [dict floatForKey:@"lowerTranslation"];
        _upperTranslation = [dict floatForKey:@"upperTranslation"];;        
    }
    return self;
}

-(void)removeFromParent{
    LH_SAFE_RELEASE(_jointProtocolImp);
    [super removeFromParent];
}

-(CGPoint)axis{
    return axis;
}

-(BOOL)shouldEnableLimits{
    return _enableLimits;
}

-(CGFloat)lowerDistanceLimit{
    return _lowerTranslation;
}

-(CGFloat)upperDistanceLimit{
    return _upperTranslation;
}

#pragma mark - LHJointNodeProtocol Required
LH_JOINT_PROTOCOL_COMMON_METHODS_IMPLEMENTATION
LH_JOINT_PROTOCOL_SPECIFIC_PHYSICS_ENGINE_METHODS_IMPLEMENTATION


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{
    if(debugShapeNode){
        CGPoint a = [self anchorA];
        
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
            
            SKPhysicsJointSliding* joint = [SKPhysicsJointSliding jointWithBodyA:nodeA.physicsBody
                                                                           bodyB:nodeB.physicsBody
                                                                          anchor:anchorA
                                                                            axis:CGVectorMake(axis.x, axis.y)];
            
            joint.shouldEnableLimits = _enableLimits;
            joint.lowerDistanceLimit = _lowerTranslation;
            joint.upperDistanceLimit = _upperTranslation;
            
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
