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


+ (instancetype)gravityAreaWithDictionary:(NSDictionary*)dict
                                   parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initGravityAreaWithDictionary:dict
                                                                parent:prnt]);
}

- (instancetype)initGravityAreaWithDictionary:(NSDictionary*)dict
                                       parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        
        
        CGPoint unitPos = [dict pointForKey:@"generalPosition"];
        CGPoint pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
        
        NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
        if(devPositions)
        {
            
#if TARGET_OS_IPHONE
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:LH_SCREEN_RESOLUTION];
#else
            LHScene* scene = (LHScene*)[self scene];
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:scene.size];
#endif
            
            if(unitPosStr){
                CGPoint unitPos = LHPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }
        
        [self setPosition:pos];
        
        CGPoint scl = [dict pointForKey:@"scale"];
        _size = [dict sizeForKey:@"size"];
        _size.width *= scl.x;
        _size.height *= scl.y;
        
        _direction = [dict pointForKey:@"direction"];
        _force = [dict floatForKey:@"force"];
        _radial = [dict intForKey:@"type"] == 1;
        
        if([[LHConfig sharedInstance] isDebug]){
            SKShapeNode* debugShapeNode = [SKShapeNode node];
            if(_radial){
                debugShapeNode.path = CGPathCreateWithEllipseInRect(CGRectMake(-_size.width*0.5,
                                                                               -_size.width*0.5,
                                                                               _size.width,
                                                                               _size.width),
                                                                    nil);
            }
            else{
                debugShapeNode.path = CGPathCreateWithRect(CGRectMake(-_size.width*0.5,
                                                                      -_size.height*0.5,
                                                                      _size.width,
                                                                      _size.height),
                                                                        nil);
            }
            debugShapeNode.strokeColor = [SKColor greenColor];
            [self addChild:debugShapeNode];
        }

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



@end
