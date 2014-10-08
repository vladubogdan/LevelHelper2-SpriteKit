//
//  LHRopeJointNode.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 27/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHRopeJointNode.h"
#import "LHConfig.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "LHAsset.h"
#import "NSDictionary+LHDictionary.h"
#import "LHGameWorldNode.h"
#import "SKNode+Transforms.h"


double bisection(double g0, double g1, double epsilon,
                 double (*fp)(double, void *), void *data)
{
    if(!data)return 0;
    
    double v0, g, v;
    v0 = fp(g0, data);
    
    while(fabs(g1-g0) > fabs(epsilon)){
        g = (g0+g1)/2.0;
        v = fp(g, data);
        if(v == 0.0)
            return g;
        else if(v*v0 < 0.0){
            g1 = g;
        } else {
            g0 = g;   v0 = v;
        }
    }
    
    return (g0+g1)/2.0;
}

double f(double x, void *data)
{
    if(!data)return 0;
    double *input = (double *)data;
    double secondTerm, delX, delY, L;
    delX  = input[2] - input[0];
    delY  = input[3] - input[1];
    L     = input[4];
    secondTerm = sqrt(L*L - delY*delY)/delX;
    
    return (sinh(x)/x -secondTerm);
}

/* f(x) = y0 + A*(cosh((x-x0)/A) - 1) */
double fcat(double x, void *data)
{
    if(!data)return 0;
    
    double x0, y0, A;
    double *input = (double *)data;
    x0  = input[0];
    y0  = input[1];
    A   = input[2];
    
    return y0 + A*(cosh((x-x0)/A) - 1.0);
}


@implementation LHRopeJointNode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHJointNodeProtocolImp*     _jointProtocolImp;
    
    
    SKShapeNode* debugShapeNode;
    
    int     segments;
    float   thickness;
    
    CGRect  colorInfo;
    BOOL    canBeCut;
    BOOL    removeAfterCut;
    float   fadeOutDelay;
    float   _length;
    
    SKShapeNode* ropeShape;//nil if drawing is not enabled
    SKShapeNode* debugCutAShapeNode;
    SKShapeNode* debugCutBShapeNode;
    
#if LH_USE_BOX2D
    b2RopeJoint* cutJointA;
    b2RopeJoint* cutJointB;
    b2Body* cutBodyA;
    b2Body* cutBodyB;
    
#else//spritekit
    __unsafe_unretained SKPhysicsJointLimit* cutJointA;
    __unsafe_unretained SKPhysicsJointLimit* cutJointB;
#endif
    

    SKShapeNode* cutShapeNodeA;//nil if drawing is not enabled
    SKShapeNode* cutShapeNodeB;//nil if drawing is not enabled
    
    float cutJointALength;
    float cutJointBLength;
    NSTimeInterval cutTimer;
    BOOL wasCutAndDestroyed;
}

-(void)dealloc{    
    ropeShape = nil;
    
    LH_SAFE_RELEASE(_jointProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict parent:prnt]);
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
        
        thickness = [dict floatForKey:@"thickness"];
        segments = [dict intForKey:@"segments"];
        
        canBeCut = [dict boolForKey:@"canBeCut"];
        fadeOutDelay = [dict floatForKey:@"fadeOutDelay"];
        removeAfterCut = [dict boolForKey:@"removeAfterCut"];
        
        if([dict boolForKey:@"shouldDraw"])
        {
            ropeShape = [SKShapeNode node];
            [self addChild:ropeShape];
            [ropeShape setName:@"LHJointDrawShape"];
            
            colorInfo = [dict rectForKey:@"colorOverlay"];
            colorInfo.size.height = [dict floatForKey:@"alpha"]/255.0f;
            
            ropeShape.strokeColor = [SKColor colorWithRed:colorInfo.origin.x
                                                    green:colorInfo.origin.y
                                                     blue:colorInfo.size.width
                                                    alpha:colorInfo.size.height];
            
            ropeShape.fillColor = [SKColor colorWithRed:colorInfo.origin.x
                                                    green:colorInfo.origin.y
                                                     blue:colorInfo.size.width
                                                    alpha:colorInfo.size.height];

            ropeShape.lineWidth = 0.5;//thickness;
            ropeShape.antialiased = NO;
            ropeShape.zPosition = [dict floatForKey:@"zOrder"];
        }

        _length = [dict floatForKey:@"length"];
        
        [self setPosition:CGPointZero];
    }
    return self;
}

-(BOOL)canBeCut{
    return canBeCut;
}

-(void)removeFromParent{

#if LH_USE_BOX2D
    LHScene* scene = (LHScene*)[self scene];
    if(scene)
    {
        LHGameWorldNode* pNode = [scene gameWorldNode];
        if(pNode)
        {
            //if we dont have the scene it means the scene was changed so the box2d world will be deleted, deleting the joints also - safe
            //if we do have the scene it means the node was deleted so we need to delete the joint manually
            //if we dont have the scene it means
            b2World* world = [pNode box2dWorld];
            if(world){
                
                if(ropeShape){
                    [ropeShape removeFromParent];
                    ropeShape = nil;
                }
                
                if(cutShapeNodeA){
                    [cutShapeNodeA removeFromParent];
                    cutShapeNodeA = nil;
                }
                if(cutShapeNodeB){
                    [cutShapeNodeB removeFromParent];
                    cutShapeNodeB = nil;
                }
                
                if(cutJointA)
                {
                    world->DestroyJoint(cutJointA);
                    cutJointA = NULL;
                }
                if(cutBodyA){
                    world->DestroyBody(cutBodyA);
                    cutBodyA = NULL;
                }
                
                if(cutJointB)
                {
                    world->DestroyJoint(cutJointB);
                    cutJointB = NULL;
                }
                if(cutBodyB){
                    world->DestroyBody(cutBodyB);
                    cutBodyB = NULL;
                }
            }
        }
    }

#else //spritekit
            
    if(cutJointA){
        [[self scene].physicsWorld removeJoint:cutJointA];
        cutJointA = nil;
    }
    
    if(cutJointB){
        [[self scene].physicsWorld removeJoint:cutJointB];
        cutJointB = nil;
    }
            
#endif
    

    LH_SAFE_RELEASE(_jointProtocolImp);

    [super removeFromParent];
}

-(void)drawRopeShape:(SKShapeNode*)shape
             anchorA:(CGPoint)anchorA
             anchorB:(CGPoint)anchorB
              length:(float)length
            segments:(int)no_segments
{
    if(shape)
    {
        BOOL isFlipped = NO;
        NSMutableArray* rPoints = [self ropePointsFromPointA:anchorA
                                                    toPointB:anchorB
                                                  withLength:length
                                                    segments:no_segments
                                                     flipped:&isFlipped];
        
        NSMutableArray* sPoints = [self shapePointsFromRopePoints:rPoints
                                                        thickness:thickness
                                                        isFlipped:isFlipped];
        
        
        NSValue* prevA = nil;
        NSValue* prevB = nil;

        
        CGMutablePathRef ropePath = nil;
        
        for(int i = 0; i < [sPoints count]; i+=2)
        {
            NSValue* valA = [sPoints objectAtIndex:i];
            NSValue* valB = [sPoints objectAtIndex:i+1];
            
            if(prevA && prevB)
            {
                CGPoint a = CGPointFromValue(valA);
                CGPoint pa = CGPointFromValue(prevA);
                
                if(!ropePath){
                    ropePath = CGPathCreateMutable();
                    CGPathMoveToPoint(ropePath, nil, pa.x, pa.y);
                    CGPathAddLineToPoint(ropePath, nil, a.x, a.y);
                }
                else{
                    CGPathAddLineToPoint(ropePath, nil, pa.x, pa.y);
                    CGPathAddLineToPoint(ropePath, nil, a.x, a.y);
                }
            }
            prevA = valA;
            prevB = valB;
        }

        for(int i = (int)[sPoints count]-1; i >=0; i-=2)
        {
            NSValue* valA = [sPoints objectAtIndex:i];
            NSValue* valB = [sPoints objectAtIndex:i-1];
            
            if(prevA && prevB)
            {
                CGPoint a = CGPointFromValue(valA);
                CGPoint pa = CGPointFromValue(prevA);
                
                CGPathAddLineToPoint(ropePath, nil, pa.x, pa.y);
                CGPathAddLineToPoint(ropePath, nil, a.x, a.y);
            }
            prevA = valA;
            prevB = valB;
        }

        shape.path = ropePath;
        
        CGPathRelease(ropePath);
    }
}

-(void)cutWithLineFromPointA:(CGPoint)ptA
                    toPointB:(CGPoint)ptB
{
    if(cutJointA || cutJointB) return; //dont cut again
    if(![_jointProtocolImp joint])return;
    
    CGPoint a = [self anchorA];
    CGPoint b = [self anchorB];
    
    ptA = [self convertToNodeSpace:ptA];
    ptB = [self convertToNodeSpace:ptB];
    
    BOOL flipped = NO;
    NSMutableArray* rPoints = [self ropePointsFromPointA:a
                                                toPointB:b
                                              withLength:_length
                                                segments:segments
                                                 flipped:&flipped];
    
    NSValue* prevValue = nil;
    float cutLength = 0.0f;
    for(NSValue* val in rPoints)
    {
        if(prevValue)
        {
    
            CGPoint ropeA = CGPointFromValue(prevValue);
            CGPoint ropeB = CGPointFromValue(val);
            
            cutLength += LHDistanceBetweenPoints(ropeA, ropeB);
            
            NSValue* interVal = LHLinesIntersection(ropeA, ropeB, ptA, ptB);
            
            if(interVal){
                CGPoint interPt = CGPointFromValue(interVal);
                
                //need to destroy the joint and create 2 other joints
                if([_jointProtocolImp joint]){
    
                    
                    cutTimer = [NSDate timeIntervalSinceReferenceDate];
                    
                    SKNode<LHNodePhysicsProtocol>* nodeA = [_jointProtocolImp nodeA];
                    SKNode<LHNodePhysicsProtocol>* nodeB = [_jointProtocolImp nodeB];
                    
                    float length = _length;

                    [_jointProtocolImp removeJoint];
                    
                    if(debugShapeNode){
                        [debugShapeNode removeFromParent];
                        debugShapeNode = nil;
                    }
                    
                    if(ropeShape){
                        
                        cutShapeNodeA = [SKShapeNode node];
                        [self addChild:cutShapeNodeA];
                        cutShapeNodeA.strokeColor = ropeShape.strokeColor;
                        cutShapeNodeA.fillColor   = ropeShape.fillColor;
                        
                        cutShapeNodeA.lineWidth = ropeShape.lineWidth;
                        cutShapeNodeA.antialiased = NO;
                        cutShapeNodeA.zPosition = ropeShape.zPosition;
        
                        cutShapeNodeB = [SKShapeNode node];
                        [self addChild:cutShapeNodeB];
                        cutShapeNodeB.strokeColor = ropeShape.strokeColor;
                        cutShapeNodeB.fillColor   = ropeShape.fillColor;
                        
                        cutShapeNodeB.lineWidth = ropeShape.lineWidth;
                        cutShapeNodeB.antialiased = NO;
                        cutShapeNodeB.zPosition = ropeShape.zPosition;

                        [ropeShape removeFromParent];
                        ropeShape = nil;
                    }
                    
#if LH_USE_BOX2D
                    {
                        CGPoint relativePosA = [_jointProtocolImp localAnchorA];
                    
                        LHScene* scene = [self scene];
                        LHGameWorldNode* pNode = [scene gameWorldNode];
                        b2World* world = [pNode box2dWorld];
                        interPt = [self convertToWorldSpace:interPt];
                        b2Vec2 bodyPos = [scene metersFromPoint:interPt];
                    
                        b2BodyDef bodyDef;
                        bodyDef.type = b2_dynamicBody;
                        bodyDef.position = bodyPos;
                        cutBodyA = world->CreateBody(&bodyDef);
                        cutBodyA->SetFixedRotation(NO);
                        cutBodyA->SetGravityScale(1);
                        cutBodyA->SetSleepingAllowed(YES);
                        
                        b2FixtureDef fixture;
                        fixture.density = 1.0f;
                        fixture.friction = 0.2;
                        fixture.restitution = 0.2;
                        fixture.isSensor = YES;
                        
                        float radius = [scene metersFromValue:thickness];
                        
                        b2Shape* shape = new b2CircleShape();
                        ((b2CircleShape*)shape)->m_radius = radius*0.5;
                        
                        if(shape){
                            fixture.shape = shape;
                            cutBodyA->CreateFixture(&fixture);
                        }
                        
                        if(shape){
                            delete shape;
                            shape = NULL;
                        }
                        
                        //create joint
                        b2RopeJointDef jointDef;
                        
                        jointDef.localAnchorA = [scene metersFromPoint:relativePosA];// jointALocalAnchor;
                        jointDef.localAnchorB = b2Vec2(0,0);
                        
                        jointDef.bodyA = [nodeA box2dBody];// bodyA;
                        jointDef.bodyB = cutBodyA;
                        
                        if(!flipped){
                            cutJointALength = cutLength;
                        }
                        else{
                            cutJointALength = length - cutLength;
                        }
                        jointDef.maxLength = [scene metersFromValue:cutJointALength];
                        jointDef.collideConnected = [_jointProtocolImp collideConnected];
                        
                        cutJointA = (b2RopeJoint*)world->CreateJoint(&jointDef);
                        cutJointA->SetUserData(LH_VOID_BRIDGE_CAST(self));

                        
                    }
                    
                    
#else //spritekit
                    //create a new body at cut position and a joint between bodyA and this new body
                    {
                        SKNode* cutBodyA = nil;
#if LH_DEBUG
                            cutBodyA = [SKShapeNode node];
                            CGPathRef pathRef = CGPathCreateWithRect(CGRectMake(-4, -4, 8, 8), nil);
                            ((SKShapeNode*)cutBodyA).path = pathRef;
                            CGPathRelease(pathRef);
                            ((SKShapeNode*)cutBodyA).fillColor = [SKColor redColor];
                            ((SKShapeNode*)cutBodyA).strokeColor = [SKColor redColor];
#else
                            cutBodyA = [SKNode node];
#endif
                        
                        
                        cutBodyA.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
                        cutBodyA.physicsBody.dynamic = YES;
                        
                        cutBodyA.position = interPt;
                        
                        [self addChild:cutBodyA];
                        
                        cutJointA = [SKPhysicsJointLimit jointWithBodyA:nodeA.physicsBody
                                                                  bodyB:cutBodyA.physicsBody
                                                                anchorA:a
                                                                anchorB:interPt];
                        

                        if(!flipped){
                            cutJointALength = cutLength;
                        }
                        else{
                            cutJointALength = length - cutLength;
                        }

                        [cutJointA setMaxLength:cutJointALength];
                        
                        [[self scene].physicsWorld addJoint:cutJointA];
                        

#if LH_DEBUG
                        {
                            debugCutAShapeNode = [SKShapeNode node];
                            
                            CGMutablePathRef debugLinePath = CGPathCreateMutable();
                            CGPathMoveToPoint(debugLinePath, nil, a.x, a.y);
                            CGPathAddLineToPoint(debugLinePath, nil, interPt.x, interPt.y);
                            debugCutAShapeNode.path = debugLinePath;
                            CGPathRelease(debugLinePath);
                            debugCutAShapeNode.position = CGPointZero;
                            debugCutAShapeNode.strokeColor = [SKColor colorWithRed:1
                                                                             green:0
                                                                              blue:0
                                                                             alpha:0.8];
                            [self addChild:debugCutAShapeNode];
                        }
#endif
                        
                    }
#endif
                    
#if LH_USE_BOX2D
                    {
                    CGPoint relativePosB = [_jointProtocolImp localAnchorB];
                        
                    LHScene* scene = [self scene];
                    LHGameWorldNode* pNode = [scene gameWorldNode];
                    b2World* world = [pNode box2dWorld];
                    
                    b2Vec2 bodyPos = [scene metersFromPoint:interPt];
                    b2BodyDef bodyDef;
                    bodyDef.type = b2_dynamicBody;
                    bodyDef.position = bodyPos;
                    cutBodyB = world->CreateBody(&bodyDef);
                    cutBodyB->SetFixedRotation(NO);
                    cutBodyB->SetGravityScale(1);
                    cutBodyB->SetSleepingAllowed(YES);
                    
                    b2FixtureDef fixture;
                    fixture.density = 1.0f;
                    fixture.friction = 0.2;
                    fixture.restitution = 0.2;
                    fixture.isSensor = YES;
                    
                    float radius = [scene metersFromValue:thickness];
                    
                    b2Shape* shape = new b2CircleShape();
                    ((b2CircleShape*)shape)->m_radius = radius*0.5;
                    
                    if(shape){
                        fixture.shape = shape;
                        cutBodyB->CreateFixture(&fixture);
                    }
                    
                    if(shape){
                        delete shape;
                        shape = NULL;
                    }
                    
                    //create joint
                    b2RopeJointDef jointDef;
                    
                    jointDef.localAnchorA = b2Vec2(0,0);
                    jointDef.localAnchorB = [scene metersFromPoint:relativePosB];
                    
                    jointDef.bodyA = cutBodyB;
                    jointDef.bodyB = [nodeB box2dBody];
                    
                    if(!flipped){
                        cutJointBLength = length - cutLength;
                    }
                    else{
                        cutJointBLength = cutLength;
                    }
                    jointDef.maxLength = [scene metersFromValue:cutJointBLength];
                    
                    jointDef.collideConnected = [_jointProtocolImp collideConnected];
                    
                    cutJointB = (b2RopeJoint*)world->CreateJoint(&jointDef);
                    cutJointB->SetUserData(LH_VOID_BRIDGE_CAST(self));
                    }
                    
#else //spritekit
                    
                    //create a new body at cut position and a joint between bodyB and this new body
                    {

                        SKNode* cutBodyB = nil;
#if LH_DEBUG
                            cutBodyB = [SKShapeNode node];
                            CGPathRef pathRef = CGPathCreateWithRect(CGRectMake(-4, -4, 8, 8), nil);
                            ((SKShapeNode*)cutBodyB).path = pathRef;
                            CGPathRelease(pathRef);
                            ((SKShapeNode*)cutBodyB).fillColor = [SKColor redColor];
                            ((SKShapeNode*)cutBodyB).strokeColor = [SKColor redColor];
#else
                            cutBodyB = [SKNode node];
#endif
                        
                        cutBodyB.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3];
                        cutBodyB.physicsBody.dynamic = YES;
                        
                        cutBodyB.position = interPt;
                        
                        [self addChild:cutBodyB];
                        
                        cutJointB = [SKPhysicsJointLimit jointWithBodyA:cutBodyB.physicsBody
                                                                  bodyB:nodeB.physicsBody
                                                                anchorA:interPt
                                                                anchorB:b];
                        
                        if(!flipped){
                            cutJointBLength = length - cutLength;
                        }
                        else{
                            cutJointBLength = cutLength;
                        }

                        [cutJointB setMaxLength:cutJointBLength];
                        
                        [[self scene].physicsWorld addJoint:cutJointB];
                        
#if LH_DEBUG
                        {
                            debugCutBShapeNode = [SKShapeNode node];
                            
                            CGMutablePathRef debugLinePath = CGPathCreateMutable();
                            CGPathMoveToPoint(debugLinePath, nil, b.x, b.y);
                            CGPathAddLineToPoint(debugLinePath, nil, interPt.x, interPt.y);
                            debugCutBShapeNode.path = debugLinePath;
                            CGPathRelease(debugLinePath);
                            debugCutBShapeNode.strokeColor = [SKColor colorWithRed:1
                                                                             green:0
                                                                              blue:0
                                                                             alpha:0.8];
                            [self addChild:debugCutBShapeNode];
                        }
#endif
                    }
#endif
                    [[self scene] didCutRopeJoint:self];
                }
                
                return;
            }
        }
        prevValue = val;
    }
}




-(int)gravityDirectionAngle{
    CGVector gravityVector = [self scene].physicsWorld.gravity;
    double angle1 = atan2(gravityVector.dx, -gravityVector.dy);
    double angle1InDegrees = (angle1 / M_PI) * 180.0;
    int finalAngle = (360 - (int)angle1InDegrees) %  360;
    return finalAngle;
}

-(NSMutableArray*)ropePointsFromPointA:(CGPoint)a
                              toPointB:(CGPoint)b
                            withLength:(float)ropeLength
                              segments:(float)numOfSegments
                               flipped:(BOOL*)flipped
{
    double data[5]; /* x1 y1 x2 y2 L */
    double constants[3];  /* x0 y0 A */
    double x0, y0, A;
    double delX, delY, guess1, guess2;
    double Q, B, K;
    double step;
    
    float gravityAngle = -[self gravityDirectionAngle];
    CGPoint c = CGPointMake((a.x + b.x)*0.5, (a.y + b.y)*0.5);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformTranslate(transform, c.x, c.y);
    transform = CGAffineTransformRotate(transform, gravityAngle);
    transform = CGAffineTransformTranslate(transform, -c.x, -c.y);
    

    CGPoint ar = CGPointApplyAffineTransform(a, transform);
    CGPoint br = CGPointApplyAffineTransform(b, transform);
    
    data[0] = ar.x;
    data[1] = ar.y; /* 1st point */
    data[2] = br.x;
    data[3] = br.y; /* 2nd point */
    
    BOOL ropeIsFlipped = NO;
    
    if(ar.x > br.x){
        data[2] = ar.x;
        data[3] = ar.y; /* 1st point */
        data[0] = br.x;
        data[1] = br.y; /* 2nd point */
        
        CGPoint temp = a;
        a = b;
        b = temp;
        
        ropeIsFlipped = YES;
    }
    
    if(flipped)
        *flipped = ropeIsFlipped;
    
    NSMutableArray* rPoints = [NSMutableArray array];
    
    data[4] = ropeLength;   /* string length */
    
    delX = data[2]-data[0];
    delY = data[3]-data[1];
    /* length of string should be larger than distance
     * between given points */
    if(data[4] <= sqrt(delX * delX + delY * delY)){
        data[4] = sqrt(delX * delX + delY * delY) +0.01;
    }
    
    Q = sqrt(data[4]*data[4] - delY*delY)/delX;
    
    guess1 = log(Q + sqrt(Q*Q-1.0));
    guess2 = sqrt(6.0*(Q-1.0));
    
    B = bisection(guess1, guess2, 1e-6, f, data);
    A = delX/(2*B);
    
    K = (0.5*delY/A)/sinh(0.5*delX/A);
    x0 = data[0] + delX/2.0 - A*asinh(K);
    y0 = data[1] - A*(cosh((data[0]-x0)/A) - 1.0);
    
    //x0, y0 is the lower point of the rope
    constants[0] = x0;
    constants[1] = y0;
    constants[2] = A;
    
    
    /* write curve points on output stream stdout */
    step = (data[2]-data[0])/numOfSegments;
    
    
    transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, c.x, c.y);
    transform = CGAffineTransformRotate(transform, -gravityAngle);
    transform = CGAffineTransformTranslate(transform, -c.x, -c.y);
    
    CGPoint prevPt = CGPointZero;
    for(float x= data[0]; x <  data[2]; )
    {
        CGPoint point = CGPointMake(x, fcat(x, constants));
        point = CGPointApplyAffineTransform(point, transform);
        [rPoints addObject:LHValueWithCGPoint(point)];
        if(CGPointEqualToPoint(point, prevPt)){
            break;//safety check
        }
        prevPt = point;
        x += step;
    }
    
    CGPoint lastPt = [[rPoints lastObject] CGPointValue];
    
    if(!CGPointEqualToPoint(CGPointMake((int)b.x, (int)b.y),
                            CGPointMake((int)lastPt.x, (int)lastPt.y)))
    {
        [rPoints addObject:LHValueWithCGPoint(b)];
    }
    
    if(!ropeIsFlipped && [rPoints count] > 0){
        CGPoint firstPt = [[rPoints objectAtIndex:0] CGPointValue];
        
        if(!CGPointEqualToPoint(CGPointMake((int)a.x, (int)a.y),
                                CGPointMake((int)firstPt.x, (int)firstPt.y)))
        {
            [rPoints insertObject:LHValueWithCGPoint(a) atIndex:0];
        }
    }
    
    return rPoints;
}

-(NSMutableArray*)shapePointsFromRopePoints:(NSArray*)rPoints
                                  thickness:(float)thick
                                  isFlipped:(BOOL)flipped
{
    NSMutableArray* shapePoints = [NSMutableArray array];
    
    bool added = false;
    NSValue* prvVal = nil;
    for(NSValue* val in rPoints){
        CGPoint pt = CGPointFromValue(val);
        
        if(prvVal)
        {
            CGPoint prevPt = CGPointFromValue(prvVal);
            
            NSArray* points = [self thickLinePointsFrom:prevPt
                                                    end:pt
                                                  width:thick];
            
            if((val == [rPoints lastObject]) && !added){
                if(flipped){
                    [shapePoints addObject:[points objectAtIndex:0]];//G
                    [shapePoints addObject:[points objectAtIndex:1]];//B
                }
                else{
                    [shapePoints addObject:[points objectAtIndex:1]];//G
                    [shapePoints addObject:[points objectAtIndex:0]];//B
                }
                added = true;
            }
            else{
                if(flipped){
                    [shapePoints addObject:[points objectAtIndex:2]];//C
                    [shapePoints addObject:[points objectAtIndex:3]];//P
                }
                else{
                    [shapePoints addObject:[points objectAtIndex:3]];//C
                    [shapePoints addObject:[points objectAtIndex:2]];//P
                }
            }
        }
        prvVal = val;
    }
    
    return shapePoints;
}

-(NSArray*)thickLinePointsFrom:(CGPoint)start
                           end:(CGPoint)end
                         width:(float)width
{
    float dx = start.x - end.x;
    float dy = start.y - end.y;
    
    CGPoint rightSide = CGPointMake(dy, -dx);
    if (LHPointLength(rightSide) > 0) {
        rightSide = LHPointNormalize(rightSide);
        rightSide = LHPointScaled(rightSide, width*0.5);
    }
    
    CGPoint leftSide = CGPointMake(-dy, dx);
    if (LHPointLength(leftSide) > 0) {
        leftSide = LHPointNormalize(leftSide);
        leftSide = LHPointScaled(leftSide, width*0.5);
    }
    
    CGPoint one     = LHPointAdd(leftSide, start);
    CGPoint two     = LHPointAdd(rightSide, start);
    CGPoint three   = LHPointAdd(rightSide, end);
    CGPoint four    = LHPointAdd(leftSide, end);
    
    NSMutableArray* array = [NSMutableArray array];
    
    //G+B
    [array addObject:LHValueWithCGPoint(CGPointMake(four.x, four.y))];
    [array addObject:LHValueWithCGPoint(CGPointMake(three.x, three.y))];
    
    //C+P
    [array addObject:LHValueWithCGPoint(CGPointMake(one.x, one.y))];
    [array addObject:LHValueWithCGPoint(CGPointMake(two.x, two.y))];
    
    return array;
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{
    
    if(![_jointProtocolImp nodeA] ||  ![_jointProtocolImp nodeB]){
        [self lateLoading];
    }
    
    if(![_jointProtocolImp nodeA])return;
    if(![_jointProtocolImp nodeB])return;
    
    //this means one or both of the nodes that this joint is connected with has been removed
    //we need to return or else we will have drawing artefacts
    if(![[_jointProtocolImp nodeA] parent])return;
    if(![[_jointProtocolImp nodeB] parent])return;
    
    
    CGPoint anchorA = [self anchorA];
    CGPoint anchorB = [self anchorB];

    
#if LH_DEBUG
    if(isnan(anchorA.x) || isnan(anchorA.y) || isnan(anchorB.x) || isnan(anchorB.y)){
        return;
    }
    
#if LH_USE_BOX2D
    
#else
    
    if(debugShapeNode && [_jointProtocolImp joint]){
        CGMutablePathRef debugLinePath = CGPathCreateMutable();
        CGPathMoveToPoint(debugLinePath, nil, anchorA.x, anchorA.y);
        CGPathAddLineToPoint(debugLinePath, nil, anchorB.x, anchorB.y);
        debugShapeNode.path = debugLinePath;
        CGPathRelease(debugLinePath);
    }

    if(debugCutAShapeNode && cutJointA)
    {
        CGPoint B = cutJointA.bodyB.node.position;
        
        CGMutablePathRef debugLineAPath = CGPathCreateMutable();
        CGPathMoveToPoint(debugLineAPath, nil, anchorA.x, anchorA.y);
        CGPathAddLineToPoint(debugLineAPath, nil, B.x, B.y);
        debugCutAShapeNode.path = debugLineAPath;
        CGPathRelease(debugLineAPath);
    }

    if(debugCutBShapeNode && cutJointB)
    {
        CGPoint A = cutJointB.bodyA.node.position;

        CGMutablePathRef debugLineBPath = CGPathCreateMutable();
        CGPathMoveToPoint(debugLineBPath, nil, A.x, A.y);
        CGPathAddLineToPoint(debugLineBPath, nil, anchorB.x, anchorB.y);
        debugCutBShapeNode.path = debugLineBPath;
        CGPathRelease(debugLineBPath);
    }
#endif
    
#endif
    
    if(ropeShape){
        [self drawRopeShape:ropeShape
                    anchorA:anchorA
                    anchorB:anchorB
                     length:_length
                   segments:segments];
    }
    
    
    if(cutShapeNodeA)
    {
#if LH_USE_BOX2D
        if(!cutBodyA)return;
        
        b2Vec2 pos = cutBodyA->GetPosition();
        LHScene* scene = [self scene];
        if(!scene)return;
        
        CGPoint B = [scene pointFromMeters:pos];
        
        B = [self convertToNodeSpace:B];
#else
        CGPoint B = cutJointA.bodyB.node.position;
#endif
        [self drawRopeShape:cutShapeNodeA
                    anchorA:anchorA
                    anchorB:B
                     length:cutJointALength
                   segments:segments];
    }


    if(cutShapeNodeB){
#if LH_USE_BOX2D
        if(!cutBodyB)return;
        b2Vec2 pos = cutBodyB->GetPosition();
        LHScene* scene = [self scene];
        if(!scene)return;
        
        CGPoint A = [scene pointFromMeters:pos];
        
        A = [self convertToNodeSpace:A];
#else
        CGPoint A = cutJointB.bodyA.node.position;
#endif
        
        [self drawRopeShape:cutShapeNodeB
                    anchorA:A
                    anchorB:anchorB
                     length:cutJointBLength
                   segments:segments];
    }
    
    
    NSTimeInterval currentTimer = [NSDate timeIntervalSinceReferenceDate];
    
    if(removeAfterCut && cutShapeNodeA && cutShapeNodeB){
        
        float unit = (currentTimer - cutTimer)/fadeOutDelay;
        float alphaValue = colorInfo.size.height;
        alphaValue -= alphaValue*unit;
        
        if(unit >=1){
            alphaValue = 0.0f;
        }
        
        cutShapeNodeA.strokeColor = [SKColor colorWithRed:colorInfo.origin.x
                                                    green:colorInfo.origin.y
                                                     blue:colorInfo.size.width
                                                    alpha:alphaValue];
        
        cutShapeNodeB.strokeColor = [SKColor colorWithRed:colorInfo.origin.x
                                                    green:colorInfo.origin.y
                                                     blue:colorInfo.size.width
                                                    alpha:alphaValue];
        
        cutShapeNodeA.fillColor = [SKColor colorWithRed:colorInfo.origin.x
                                                  green:colorInfo.origin.y
                                                   blue:colorInfo.size.width
                                                  alpha:alphaValue];
        
        cutShapeNodeB.fillColor = [SKColor colorWithRed:colorInfo.origin.x
                                                  green:colorInfo.origin.y
                                                   blue:colorInfo.size.width
                                                  alpha:alphaValue];
        
        if(unit >=1){
            [self removeFromParent];
            return;
        }
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
        
        LHScene* scene = [self scene];
        LHGameWorldNode* pNode = [scene gameWorldNode];
        b2World* world = [pNode box2dWorld];
        if(world == nil)return NO;
        
        b2Body* bodyA = [nodeA box2dBody];
        b2Body* bodyB = [nodeB box2dBody];
        
        if(!bodyA || !bodyB)return NO;
        
        b2Vec2 posA = [scene metersFromPoint:relativePosA];
        b2Vec2 posB = [scene metersFromPoint:relativePosB];
        
        b2RopeJointDef jointDef;
        
        jointDef.localAnchorA = posA;
        jointDef.localAnchorB = posB;
        
        jointDef.bodyA = bodyA;
        jointDef.bodyB = bodyB;
        
        jointDef.maxLength = [scene metersFromValue:_length];
        
        jointDef.collideConnected = [_jointProtocolImp collideConnected];
        
        b2RopeJoint* joint = (b2RopeJoint*)world->CreateJoint(&jointDef);
        
        [_jointProtocolImp setJoint:joint];
        
#else //spritekit
      
        if(!nodeA.physicsBody || !nodeB.physicsBody)
            return NO;
        
        LHScene* scene = [self scene];
        
        
        CGPoint anchorA = [nodeA convertToWorldSpace:relativePosA];
        CGPoint anchorB = [nodeB convertToWorldSpace:relativePosB];
        
        SKPhysicsJointLimit* joint = [SKPhysicsJointLimit jointWithBodyA:nodeA.physicsBody
                                                                   bodyB:nodeB.physicsBody
                                                                 anchorA:anchorA
                                                                 anchorB:anchorB];
        
        [joint setMaxLength:_length];
        [scene.physicsWorld addJoint:joint];
    
        [_jointProtocolImp setJoint:joint];
        
#if LH_DEBUG
        debugShapeNode = [SKShapeNode node];
        
        CGMutablePathRef debugLinePath = CGPathCreateMutable();
        CGPathMoveToPoint(debugLinePath, nil, anchorA.x, anchorA.y);
        CGPathAddLineToPoint(debugLinePath, nil, anchorB.x, anchorB.y);
        
        debugShapeNode.path = debugLinePath;
        
        CGPathRelease(debugLinePath);
        
        debugShapeNode.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:0.8];
        
        [self addChild:debugShapeNode];
#endif
        
        
#endif
        return true;
    }
    
    return false;
}

#pragma mark - LHJointNodeProtocol Required
LH_JOINT_PROTOCOL_COMMON_METHODS_IMPLEMENTATION
LH_JOINT_PROTOCOL_SPECIFIC_PHYSICS_ENGINE_METHODS_IMPLEMENTATION



@end
