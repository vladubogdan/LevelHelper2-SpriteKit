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


double bisection(double g0, double g1, double epsilon,
                 double (*fp)(double, void *), void *data)
{
    if(!data)return 0;
    
    double v0, v1, g, v;
    v0 = fp(g0, data);
    v1 = fp(g1, data);
    
    while(fabs(g1-g0) > fabs(epsilon)){
        g = (g0+g1)/2.0;
        v = fp(g, data);
        if(v == 0.0)
            return g;
        else if(v*v0 < 0.0){
            g1 = g;   v1 = v;
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
    
    __unsafe_unretained SKPhysicsJointLimit* joint;
    SKShapeNode* debugShapeNode;
    
    CGPoint relativePosA;
    CGPoint relativePosB;
    
    int     segments;
    float   thickness;
    
    CGRect  colorInfo;
    BOOL    canBeCut;
    BOOL    removeAfterCut;
    float   fadeOutDelay;
    float   _length;
    
    NSString* nodeAUUID;
    NSString* nodeBUUID;
    
    SKShapeNode* ropeShape;//nil if drawing is not enabled
    
    __unsafe_unretained SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeA;
    __unsafe_unretained SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeB;
    
    SKShapeNode* debugCutAShapeNode;
    SKPhysicsJointLimit* cutJointA;
    SKShapeNode* debugCutBShapeNode;
    SKPhysicsJointLimit* cutJointB;
    
    SKShapeNode* cutShapeNodeA;//nil if drawing is not enabled
    SKShapeNode* cutShapeNodeB;//nil if drawing is not enabled
    
    float cutJointALength;
    float cutJointBLength;
    NSTimeInterval cutTimer;
    BOOL wasCutAndDestroyed;
}

-(void)dealloc{
    nodeA = nil;
    nodeB = nil;

    LH_SAFE_RELEASE(nodeAUUID);
    LH_SAFE_RELEASE(nodeBUUID);
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)ropeJointNodeWithDictionary:(NSDictionary*)dict
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
            ropeShape.lineWidth = thickness;
            ropeShape.antialiased = NO;
            ropeShape.zPosition = [dict floatForKey:@"zOrder"];
        }

        nodeAUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteAUUID"]];
        nodeBUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteBUUID"]];
        
        relativePosA = [dict pointForKey:@"relativePosA"];
        relativePosB = [dict pointForKey:@"relativePosB"];
        _length = [dict floatForKey:@"length"];
        
        
        [self setPosition:CGPointZero];
    }
    return self;
}

-(CGPoint)anchorA{
//    CGAffineTransform transformA = CGAffineTransformRotate(CGAffineTransformIdentity,
//                                                           joint.bodyA.node.zRotation);
//    
//    CGPoint curAnchorA = CGPointApplyAffineTransform(CGPointMake(relativePosA.x, -relativePosA.y),
//                                                     transformA);
//    
//    CGPoint ptA = [[self scene] convertPoint:CGPointZero fromNode:nodeA];
    return nodeA.position;

//    return ptA;
    
//    return CGPointMake(ptA.x + curAnchorA.x,
//                       ptA.y + curAnchorA.y);
}

-(CGPoint)anchorB{
//    CGAffineTransform transformB = CGAffineTransformRotate(CGAffineTransformIdentity,
//                                                           joint.bodyB.node.zRotation);
//    
//    CGPoint curAnchorB = CGPointApplyAffineTransform(CGPointMake(relativePosB.x, -relativePosB.y),
//                                                     transformB);
    
    //CGPoint ptB = [[self scene] convertPoint:CGPointZero fromNode:nodeB];
    return nodeB.position;

//    return ptB;
//    return  CGPointMake(ptB.x + curAnchorB.x,
//                        ptB.y + curAnchorB.y);
}

-(BOOL)canBeCut{
    return canBeCut;
}

-(void)removeFromParent{
    
    if(cutJointA){
        [[self scene].physicsWorld removeJoint:cutJointA];
        cutJointA = nil;
    }
    
    if(cutJointB){
        [[self scene].physicsWorld removeJoint:cutJointB];
        cutJointB = nil;
    }
    
    if(joint){
        [[self scene].physicsWorld removeJoint:joint];
        joint = nil;
    }
    
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
        float prevV = 0.0f;
        if(isFlipped){
            prevV = 1.0f;
        }
        
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
        
        shape.path = ropePath;
        
        CGPathRelease(ropePath);
    }
}

-(void)cutWithLineFromPointA:(CGPoint)ptA
                    toPointB:(CGPoint)ptB
{
    if(cutJointA || cutJointB) return; //dont cut again
    
    if(!joint)return;
    
    CGPoint a = [self anchorA];
    CGPoint b = [self anchorB];
    
    ptA = [[self scene] convertPoint:ptA toNode:[[self scene] gameWorldNode]];
    ptB = [[self scene] convertPoint:ptB toNode:[[self scene] gameWorldNode]];
    
    
    BOOL flipped = NO;
    NSMutableArray* rPoints = [self ropePointsFromPointA:a
                                                toPointB:b
                                              withLength:[joint maxLength]
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
                if(joint){
    
                    cutTimer = [NSDate timeIntervalSinceReferenceDate];
                    
                    nodeA = (SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)joint.bodyA.node;
                    nodeB = (SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)joint.bodyB.node;

                    float length = joint.maxLength;

                    [[self scene].physicsWorld removeJoint:joint];
                    joint = nil;
                    
                    if(debugShapeNode){
                        [debugShapeNode removeFromParent];
                        debugShapeNode = nil;
                    }
                    
                    if(ropeShape){
                        
                        cutShapeNodeA = [SKShapeNode node];
                        [self addChild:cutShapeNodeA];
                        cutShapeNodeA.strokeColor = ropeShape.strokeColor;
                        cutShapeNodeA.lineWidth = ropeShape.lineWidth;
                        cutShapeNodeA.antialiased = NO;
                        cutShapeNodeA.zPosition = ropeShape.zPosition;
        
                        cutShapeNodeB = [SKShapeNode node];
                        [self addChild:cutShapeNodeB];
                        cutShapeNodeB.strokeColor = ropeShape.strokeColor;
                        cutShapeNodeB.lineWidth = ropeShape.lineWidth;
                        cutShapeNodeB.antialiased = NO;
                        cutShapeNodeB.zPosition = ropeShape.zPosition;

                        [ropeShape removeFromParent];
                        ropeShape = nil;
                    }
                    
                    //create a new body at cut position and a joint between bodyA and this new body
                    {
                        SKNode* cutBodyA = nil;
                        if([[LHConfig sharedInstance] isDebug])
                        {
                            cutBodyA = [SKShapeNode node];
                            ((SKShapeNode*)cutBodyA).path = CGPathCreateWithRect(CGRectMake(-4, -4, 8, 8), nil);
                            ((SKShapeNode*)cutBodyA).fillColor = [SKColor redColor];
                            ((SKShapeNode*)cutBodyA).strokeColor = [SKColor redColor];
                        }
                        else{
                            cutBodyA = [SKNode node];
                        }
                        
                        
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
                        

                        if([[LHConfig sharedInstance] isDebug])
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
                    }
                    
                    //create a new body at cut position and a joint between bodyB and this new body
                    {

                        SKNode* cutBodyB = nil;
                        if([[LHConfig sharedInstance] isDebug])
                        {
                            cutBodyB = [SKShapeNode node];
                            ((SKShapeNode*)cutBodyB).path = CGPathCreateWithRect(CGRectMake(-4, -4, 8, 8), nil);
                            ((SKShapeNode*)cutBodyB).fillColor = [SKColor redColor];
                            ((SKShapeNode*)cutBodyB).strokeColor = [SKColor redColor];
                        }
                        else {
                            cutBodyB = [SKNode node];
                        }
                        
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
                        
                        if([[LHConfig sharedInstance] isDebug])
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
                    }
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
    double step, x;
    
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
    x = data[0];
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
    
    bool first = true;
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
            first = false;
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
    
    CGPoint anchorA = [self anchorA];
    CGPoint anchorB = [self anchorB];

    
if([[LHConfig sharedInstance] isDebug])
{
    if(isnan(anchorA.x) || isnan(anchorA.y) || isnan(anchorB.x) || isnan(anchorB.y)){
        return;
    }
    
    if(debugShapeNode && joint){
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
}
    
    if(ropeShape){
        [self drawRopeShape:ropeShape
                    anchorA:anchorA
                    anchorB:anchorB
                     length:joint.maxLength
                   segments:segments];
    }
    
    NSTimeInterval currentTimer = [NSDate timeIntervalSinceReferenceDate];
    
    if(removeAfterCut && cutShapeNodeA && cutShapeNodeB){
        
        float unit = (currentTimer - cutTimer)/fadeOutDelay;
        float alphaValue = colorInfo.size.height;
        alphaValue -= alphaValue*unit;
        
        
        cutShapeNodeA.strokeColor = [SKColor colorWithRed:colorInfo.origin.x
                                                    green:colorInfo.origin.y
                                                     blue:colorInfo.size.width
                                                    alpha:alphaValue];
        
        cutShapeNodeB.strokeColor = [SKColor colorWithRed:colorInfo.origin.x
                                                    green:colorInfo.origin.y
                                                     blue:colorInfo.size.width
                                                    alpha:alphaValue];
        if(unit >=1){
            [self removeFromParent];
            return;
        }
        
    }
    
    if(cutShapeNodeA && cutJointA){

        [self drawRopeShape:cutShapeNodeA
                    anchorA:anchorA
                    anchorB:cutJointA.bodyB.node.position
                     length:cutJointALength
                   segments:segments];
    }
    
    if(cutShapeNodeB && cutJointB){

        [self drawRopeShape:cutShapeNodeB
                    anchorA:cutJointB.bodyA.node.position
                    anchorB:anchorB
                     length:cutJointBLength
                   segments:segments];
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
        
        joint = [SKPhysicsJointLimit jointWithBodyA:nodeA.physicsBody
                                              bodyB:nodeB.physicsBody
                                            anchorA:anchorA
                                            anchorB:anchorB];
        
        [joint setMaxLength:_length];
        
        [scene.physicsWorld addJoint:joint];
        
        
if([[LHConfig sharedInstance] isDebug])
{
        debugShapeNode = [SKShapeNode node];
        
        CGMutablePathRef debugLinePath = CGPathCreateMutable();
        CGPathMoveToPoint(debugLinePath, nil, anchorA.x, anchorA.y);
        CGPathAddLineToPoint(debugLinePath, nil, anchorB.x, anchorB.y);
        
        debugShapeNode.path = debugLinePath;
        
        CGPathRelease(debugLinePath);
        
        debugShapeNode.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:0.8];
        
        [self addChild:debugShapeNode];
}
        
        LH_SAFE_RELEASE(nodeAUUID);
        LH_SAFE_RELEASE(nodeBUUID);
        return true;
    }
    
    return false;
}

@end
