//
//  LHGravityArea.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHGravityArea.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHGameWorldNode.h"


@implementation LHGravityArea
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    
    CGSize _size;

    BOOL _radial;
    float _force;
    CGPoint _direction;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);

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
        
        
        CGPoint scl = [dict pointForKey:@"scale"];
        _size = [dict sizeForKey:@"size"];
        _size.width *= scl.x;
        _size.height *= scl.y;
        
        _direction = [dict pointForKey:@"direction"];
        _force = [dict floatForKey:@"force"];
        _radial = [dict intForKey:@"type"] == 1;
        
#if LH_DEBUG
            SKShapeNode* debugShapeNode = [SKShapeNode node];
            if(_radial){
                CGPathRef pathRef = CGPathCreateWithEllipseInRect(CGRectMake(-_size.width*0.5,
                                                                             -_size.width*0.5,
                                                                             _size.width,
                                                                             _size.width),
                                                                  nil);
                
                debugShapeNode.path = pathRef;
                CGPathRelease(pathRef);
            }
            else{
                CGPathRef pathRef = CGPathCreateWithRect(CGRectMake(-_size.width*0.5,
                                                                    -_size.height*0.5,
                                                                    _size.width,
                                                                    _size.height),
                                                         nil);
                debugShapeNode.path = pathRef;
                CGPathRelease(pathRef);
            }
            debugShapeNode.strokeColor = [SKColor greenColor];
            [self addChild:debugShapeNode];
#endif

    }
    
    return self;
}

-(CGSize)size{
    return _size;
}

-(BOOL)isRadial{
    return _radial;
}

-(CGPoint)direction{
    return _direction;
}

-(float)force{
    return _force;
}

-(CGRect)rect{
    CGPoint scenePosition = [[self scene] convertPoint:CGPointZero
                                              fromNode:self];
    return CGRectMake(scenePosition.x - self.size.width*0.5,
                      scenePosition.y - self.size.height*0.5,
                      self.size.width,
                      self.size.height);
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#if LH_USE_BOX2D
-(void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    LHScene* scene = (LHScene*)[self scene];
    LHGameWorldNode* pNode = (LHGameWorldNode*)[scene gameWorldNode];
    
    b2World* world =  [pNode box2dWorld];
    
    if(!world)return;
    
    CGSize size = [self size];
    float ptm = [scene ptm];
    CGRect rect = [self rect];
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
        if([self isRadial])
        {
            CGPoint globalPos = [[self scene] convertPoint:CGPointZero
                                                      fromNode:self];
            
            
            b2Vec2 b2TouchPosition = [scene metersFromPoint:globalPos];
            b2Vec2 b2BodyPosition = b2Vec2(b->GetPosition().x, b->GetPosition().y);
            
            float maxDistance = [scene metersFromValue:(size.width*0.5)];
            float maxForce = -[self force]/ptm;
            
            CGFloat distance = b2Distance(b2BodyPosition, b2TouchPosition);
            if(distance < maxDistance)
            {
                CGFloat strength = (maxDistance - distance) / maxDistance;
                float force = strength * maxForce;
                CGFloat angle = atan2f(b2BodyPosition.y - b2TouchPosition.y, b2BodyPosition.x - b2TouchPosition.x);
                
                b->ApplyLinearImpulse(b2Vec2(cosf(angle) * force, sinf(angle) * force), b->GetPosition(), true);
            }
        }
        else{
            b2Vec2 b2BodyPosition = b2Vec2(b->GetPosition().x, b->GetPosition().y);
            
            CGPoint pos = [scene pointFromMeters:b2BodyPosition];
            
            if(CGRectContainsPoint(rect, pos))
            {
                float force = [self force]/ptm;
                
                float directionX = [self direction].x;
                float directionY = [self direction].y;
                b->ApplyLinearImpulse(b2Vec2(directionX * force, directionY * force), b->GetPosition(), true);
            }
        }
	}
}
#else //spritekit

-(void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    SKPhysicsWorld* world = [[self scene] physicsWorld];
    
    [world enumerateBodiesInRect:self.rect
                      usingBlock:^(SKPhysicsBody* body, BOOL *stop)
     {
         if(body.isDynamic)
         {
             SKNode* node = [body node];
             CGPoint pos = [node position];
             
             if([self isRadial])
             {
                 CGPoint position = [self position];
                 
                 float maxDistance = self.size.width*0.5f;
                 CGFloat distance = LHDistanceBetweenPoints(position, pos);
                 
                 if(distance < maxDistance)
                 {
                     float maxForce = -[self force]/16.0f;
                     CGFloat strength = (maxDistance - distance) / maxDistance;
                     float force = strength * maxForce;
                     CGFloat angle = atan2f(pos.y - position.y, pos.x - position.x);
                     [body applyImpulse:CGVectorMake(cosf(angle) * force,
                                                     sinf(angle) * force)];
                 }
             }
             else{
                 float force = [self force]/16.0f;
                 float directionX = [self direction].x;
                 float directionY = [self direction].y;
                 [body applyImpulse:CGVectorMake(directionX * force, directionY * force)];
             }
         }
     }];
}
#endif


@end
