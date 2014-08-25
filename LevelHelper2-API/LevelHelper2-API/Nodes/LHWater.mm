//
//  LHWater.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHWater.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"

#import "LHGameWorldNode.h"
#import "LHConfig.h"

#if LH_USE_BOX2D
#include "LHb2BuoyancyController.h"
#endif

@interface LHWave : NSObject
{
    float wavelength, amplitude, startAmplitude, offset, increment, velocity;
    float left, right, halfWidth, middle;
    int currentStep, totalSteps;
    
    float(^decayBlock)(float, float, float, float);
    float(^clampBlock)(float, float, float, float);
    float(^waveBlock)(float);
}

@property float wavelength, amplitude, startAmplitude, offset, increment, velocity;
@property float left, right, halfWidth, middle;
@property int currentStep, totalSteps;

-(void)setDecayBlock:(float(^)(float t, float b, float c, float d))decayBlock;
-(void)setClampBlock:(float(^)(float t, float b, float c, float d))clampBlock;
-(void)setWaveBlock:(float(^)(float val))waveBlock;

- (float(^)(float, float, float, float))decayBlock;
- (float(^)(float, float, float, float))clampBlock;
- (float(^)(float))waveBlock;

+(float) linearEase:(float)t b:(float)b c:(float)c d:(float)d;
+(float) sinEaseIn:(float)t b:(float)b c:(float)c d:(float)d;
+(float)sinEaseOut:(float)t b:(float)b c:(float)c d:(float)d;
+(float)sinEaseInOut:(float)t b:(float)b c:(float)c d:(float)d;
-(float)valueAt:(float)positionX;
-(void)step;
@end
@implementation LHWave
@synthesize wavelength, amplitude, startAmplitude, currentStep, totalSteps,
offset, increment, velocity, left, right, halfWidth, middle;
-(id)init{
    if(self = [super init]){
        waveBlock = nil;
        wavelength= 0;
        amplitude = 0;
        startAmplitude = 0;
        currentStep = 0;
        totalSteps = 0;
        offset = 0;
        increment = 0;
        decayBlock = nil;
        clampBlock = nil;
        velocity = 0;
        left = 0;
        right = 1000;
        halfWidth = 0;
        middle = 0;
    }
    return self;
}
-(void)setDecayBlock:(float(^)(float t, float b, float c, float d))_decayBlock{
    decayBlock = _decayBlock;
}
-(void)setClampBlock:(float(^)(float t, float b, float c, float d))_clampBlock{
    clampBlock = _clampBlock;
}
-(void)setWaveBlock:(float(^)(float val))_waveBlock{
    waveBlock = _waveBlock;
}
- (float(^)(float, float, float, float))decayBlock{
    return decayBlock;
}
- (float(^)(float, float, float, float))clampBlock{
    return clampBlock;
}
- (float(^)(float))waveBlock{
    return waveBlock;
}
+(float) linearEase:(float)t b:(float)b c:(float)c d:(float)d{
    return b + c * t  / d;
}
+(float) sinEaseIn:(float)t b:(float)b c:(float)c d:(float)d{
    return -c * cos(t/d * (M_PI / 2)) + c + b;
}
+(float)sinEaseOut:(float)t b:(float)b c:(float)c d:(float)d{
    return c * sin(t / d * (M_PI / 2)) + b;
}
+(float)sinEaseInOut:(float)t b:(float)b c:(float)c d:(float)d{
    return -c / 2 * (cos(M_PI * t / d) - 1) + b;
}
-(float)valueAt:(float)position {
    if(position < left || position > right) {
        return 0.0f;
    }
    float v = (waveBlock != nil ? waveBlock((position - left + offset) / wavelength) : 1.0f) * amplitude;
    if(clampBlock != nil) {
        v = clampBlock(abs(position - middle), v, -v, halfWidth);
    }
    return v;
}
-(void) step{
    if(decayBlock != nil) {
        amplitude = decayBlock(currentStep, startAmplitude, -startAmplitude, totalSteps);
        currentStep++;
    }
    offset += increment;
    left += velocity;
    right += velocity;
    halfWidth = (right - left) / 2;
    middle = left + halfWidth;
}
@end



@implementation LHWater
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    
    CGPoint _scale;
    CGSize _size;
    
    float width, height;
    float numLines;
    NSMutableArray* waves;
    float lineWidth;

    float waterDensity;
    BOOL turbulence;
    float turbulenceL;
    float turbulenceH;
    float turbulenceV;
    float turbulenceVelocity;
    
    BOOL splashCollision;
    float splashHeight;
    float splashWidth;
    float splashTime;
    NSMutableDictionary* bodySplashes;
    
#if LH_USE_BOX2D
    LH_b2BuoyancyController* buoyancyController;
#endif
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);

    LH_SAFE_RELEASE(bodySplashes);
    LH_SAFE_RELEASE(waves);
    
#if LH_USE_BOX2D
    LH_SAFE_DELETE(buoyancyController);
#endif
    
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
        
#if LH_USE_BOX2D
        buoyancyController = NULL;
#endif
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        
        _size = [dict sizeForKey:@"size"];
        
        
        width = [dict floatForKey:@"width"];
        height = [dict floatForKey:@"height"];
        numLines = [dict floatForKey:@"numLines"];
        waves = [[NSMutableArray alloc] init];
        waterDensity = [dict floatForKey:@"waterDensity"];
        lineWidth = width / numLines;
        
        turbulence = [dict boolForKey:@"turbulence"];
        turbulenceL= [dict floatForKey:@"turbulenceL"];
        turbulenceH= [dict floatForKey:@"turbulenceH"];
        turbulenceV= [dict floatForKey:@"turbulenceV"];
        turbulenceVelocity = [dict floatForKey:@"turbulenceVelocity"];
        
        splashCollision = [dict boolForKey:@"splash"];
        splashHeight    = [dict floatForKey:@"splashH"];
        splashWidth     = [dict floatForKey:@"splashW"];
        splashTime      = [dict floatForKey:@"splashT"];
        
        _scale = [dict pointForKey:@"scale"];

        bodySplashes = [[NSMutableDictionary alloc] init];
        
        
        self.strokeColor = [dict colorForKey:@"colorOverlay"];
        self.fillColor = [dict colorForKey:@"colorOverlay"];
        

        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        [self createTurbulence];
        
    }
    
    return self;
}

-(CGSize)size{
    return CGPathGetBoundingBox(self.path).size;
}

-(void)createTurbulence{
    [self clearWaves];
    if(turbulence)
        [self createTurbulance:turbulenceH v:turbulenceV l:turbulenceL];
}
-(void)clearWaves{
    [waves removeAllObjects];
}
-(LHWave*)createTurbulance:(float)h v:(float)v l:(float)l
{
    LHWave* wv = LH_AUTORELEASED([[LHWave alloc] init]);
    [wv setWaveBlock:^float (float val){
        return sinf(val);
    }];
    
    wv.left = 0;
    wv.right = width;
    wv.wavelength = l;
    wv.increment = v;
    wv.amplitude = h;
    [self addWave:wv];
    return wv;
}
-(void)addWave:(LHWave*)w
{
    w.startAmplitude = w.amplitude;
    [waves addObject:w];
}

-(float)valueAt:(float)pos
{
    float y = 0;
    for(int i = 0; i < [waves count]; ++i) {
        y += [[waves objectAtIndex:i] valueAt:pos];
    }
    return y;
}

-(float)globalXToWaveX:(float)pointX{
    
    CGSize sizet = [self size];
    CGPoint pos = [self position];
    
    float fullWidth = sizet.width*self.xScale;
    float halfWidth = fullWidth*0.5;
    
    float val = (pointX - pos.x) + halfWidth;
    float percent = val/fullWidth;
    
    return width*percent;
}

-(float)waveYToGlobalY:(float)waveY{
    
    CGSize sizet = [self size];
    CGPoint pos = [self position];
    
    float waveHeight = self.size.height-waveY;
    float percent = waveHeight/self.size.height;
    
    float fullHeight = sizet.height*self.yScale;
    float halfHeight = fullHeight*0.5;
    
    return pos.y - fullHeight*percent + halfHeight;
}

-(NSMutableArray*)createSplash:(float)pos h:(float)h w:(float)w t:(float)t
{
    LHWave* w1 = LH_AUTORELEASED([[LHWave alloc] init]);
    LHWave* w2 = LH_AUTORELEASED([[LHWave alloc] init]);
    
    [w1 setWaveBlock:^float (float val){
        return cosf(val);
    }];
    [w2 setWaveBlock:^float (float val){
        return cosf(val);
    }];
    
    [w1 setDecayBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseOut:t b:b c:c d:d];
    }];
    [w2 setDecayBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseOut:t b:b c:c d:d];
    }];
    
    [w1 setClampBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseInOut:t b:b c:c d:d];
    }];
    [w2 setClampBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseInOut:t b:b c:c d:d];
    }];
    
    w1.amplitude = w2.amplitude = h / 2;
    float hw = w / 2;
    w1.left = w2.left = pos - hw;
    w1.right = w2.right = w1.left + w;
    w1.totalSteps = w2.totalSteps = t;
    w1.wavelength = w2.wavelength = hw / (3 * M_PI);
    float v = hw / t;
    w1.velocity = v;
    w2.velocity = -v;
    [self addWave:w1];
    [self addWave:w2];
    return [NSMutableArray arrayWithObjects:w1, w2, nil];
}

-(CGRect)waveRect{
    
    CGRect wavesRect = CGPathGetBoundingBox(self.path);
    
    CGPoint scenePosition = [[self scene] convertPoint:CGPointZero
                                              fromNode:self];
    
    return CGRectMake(scenePosition.x - wavesRect.size.width*0.5,
                      scenePosition.y - wavesRect.size.height*0.5,
                      wavesRect.size.width,
                      wavesRect.size.height);
//    
//    CGPoint pos = [[self scene] convertPoint:CGPointZero
//                                    fromNode:self];
//    
//    return CGRectMake(-width *self.xScale *0.5 + pos.x,
//                      -height*self.yScale *0.5 + pos.y,
//                      width  * self.xScale,
//                      height * self.yScale);
    
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

#if LH_USE_BOX2D
-(CGRect)boundingRectForBody:(b2Body*)bd
{
    b2AABB aabb;
    b2Transform t;
    t.SetIdentity();
    aabb.lowerBound = b2Vec2(FLT_MAX,FLT_MAX);
    aabb.upperBound = b2Vec2(-FLT_MAX,-FLT_MAX);
    b2Fixture* fixture = bd->GetFixtureList();
    while (fixture != NULL) {
        const b2Shape *shape = fixture->GetShape();
        const int childCount = shape->GetChildCount();
        for (int child = 0; child < childCount; ++child) {
            const b2Vec2 r(shape->m_radius, shape->m_radius);
            b2AABB shapeAABB;
            shape->ComputeAABB(&shapeAABB, t, child);
            shapeAABB.lowerBound = shapeAABB.lowerBound + r;
            shapeAABB.upperBound = shapeAABB.upperBound - r;
            aabb.Combine(shapeAABB);
        }
        fixture = fixture->GetNext();
    }
    
    LHScene* scene = [self scene];
    
    float wm = aabb.upperBound.x - aabb.lowerBound.x;
    float hm = aabb.upperBound.y - aabb.lowerBound.y;
    float x = [scene valueFromMeters:aabb.upperBound.x + bd->GetPosition().x - wm];
    float y = [scene valueFromMeters:aabb.upperBound.y + bd->GetPosition().y - hm];
    float w = [scene valueFromMeters:wm];
    float h = [scene valueFromMeters:hm];
    
    return CGRectMake(x, y, w, h);
}
#endif

- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    NSMutableArray* toRemove = [NSMutableArray array];
    for(LHWave* w in waves){
        [w step];
        BOOL done = [w decayBlock] != nil && (w.currentStep >= w.totalSteps);
        BOOL outBounds = (w.right <= 0 && w.velocity <= 0) || (w.left >= width && w.velocity >= 0);
        if(done || outBounds) {
            [toRemove addObject:w];
        }
    }
    [waves removeObjectsInArray:toRemove];
    
    
    
    NSMutableArray* points = [NSMutableArray array];
    for(int i = 0; i <= numLines; ++i) {
        [points addObject:[NSNumber numberWithFloat:[self valueAt:(i * lineWidth)]]];
    }
    
    
    float ox = -width*0.5;
    float oy = -height*0.5;
    
    CGAffineTransform trans = CGAffineTransformMakeScale(_scale.x, _scale.y);
    CGMutablePathRef wavePath = CGPathCreateMutable();
    if([points count] > 0)
    {
        float x = -width*0.5;
        float y = height*0.5;
        
        CGPathMoveToPoint(wavePath, &trans, x, -y);
        
        x = -width*0.5;
        y = [[points objectAtIndex:0] floatValue] + oy;
        
        CGPathAddLineToPoint(wavePath, &trans, x, -y);
        
        for(int i = 1; i < (int)[points count]; ++i)
        {
            x = lineWidth*i - width*0.5;
            y = [[points objectAtIndex:i] floatValue] - height*0.5;
            
            CGPathAddLineToPoint(wavePath, &trans, x, -y);
        }
        
        x = width*0.5;
        y = -height*0.5;
        CGPathAddLineToPoint(wavePath, &trans, x, -y);
        
        x = width + ox;
        y = height*0.5;
        CGPathAddLineToPoint(wavePath, &trans, x, -y);
    }
    
    CGPathCloseSubpath(wavePath);
    self.path = wavePath;
    CGPathRelease(wavePath);
    
    CGRect wavesRect = [self waveRect];
    
    
#if LH_USE_BOX2D
    
    LHScene* scene = [self scene];
    LHGameWorldNode* pNode = [scene gameWorldNode];
    b2World* world = [pNode box2dWorld];
    
    if(NULL == buoyancyController && world){
        buoyancyController = new LH_b2BuoyancyController(world);
        buoyancyController->offset = -27;
    }
    
    buoyancyController->density = -waterDensity;
    
    if(world){
        for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()){
            
            if(b->GetType() == b2_dynamicBody){
                
                SKNode* node = LH_ID_BRIDGE_CAST(b->GetUserData());
                if(node){
                    
                    CGRect bodyRect = [self  boundingRectForBody:b];
                    
                    if(LHRectOverlapsRect(wavesRect,  bodyRect))
                    {
                        CGPoint bodyPt = [scene pointFromMeters:b->GetPosition()];
                        
                        float scaleX = [self xScale];// _scale.x;
                        float scaleY = [self yScale];//_scale.y;
                        
                        float x = bodyPt.x;
                        float y = [self valueAt:[self globalXToWaveX:x]];
                        y = [self waveYToGlobalY:y];
                        
                        float globalY = y;
                        
                        y = [scene metersFromValue:y];
                        
                        float splashX = [self globalXToWaveX:x];
                        
                        BOOL addedSplash = false;
                        float previousX = -1000000;
                        b2Fixture* f = b->GetFixtureList();
                        while (f) {
                            
                            if(!f->IsSensor())
                            {
                                buoyancyController->offset = y;
                                buoyancyController->useDensity = NO;
                                buoyancyController->velocity = b2Vec2(0,0);
                                if(turbulence){
                                    float vdirection = 1.0f;
                                    if(turbulenceV > 0)
                                        vdirection = -1.0f;
                                    buoyancyController->velocity = b2Vec2(vdirection*turbulenceVelocity, 0);
                                }
                                
                                NSString* hadSplash = [bodySplashes objectForKey:[NSString stringWithFormat:@"%p", b->GetUserData()]];
                                
                                bool after = buoyancyController->ApplyToFixture(f);
                                if(after && hadSplash == nil && splashCollision){
                                    
                                    
                                    if(previousX != splashX && !addedSplash){
                                        NSArray* splashes = [self createSplash:splashX
                                                                             h:splashHeight*scaleY
                                                                             w:splashWidth*scaleX
                                                                             t:splashTime];
                                        previousX = splashX;
                                        addedSplash = true;
                                        int i = 0;
                                        for(LHWave* wave in splashes){
                                            [wave step];
                                            ++i;
                                            // if(i > 2)break;
                                        }
                                        
                                        [bodySplashes setObject:[NSNumber numberWithBool:YES]
                                                         forKey:[NSString stringWithFormat:@"%p", b->GetUserData()]];
                                    }
                                }
                                
                                if(self.position.y + [self size].height*0.5 - globalY + bodyRect.size.height*0.5 > bodyPt.y)
                                {
                                    buoyancyController->ApplyToFixture(f);
                                }
                            }
                            f = f->GetNext();
                        }
                    }
                    else{
                        [bodySplashes removeObjectForKey:[NSString stringWithFormat:@"%p", b->GetUserData()]];
                    }
                }
            }
        }
    }
    
    
#else //spritekit
    
    SKPhysicsWorld* world = [[self scene] physicsWorld];
    CGVector gravity = [world gravity];

    [world enumerateBodiesInRect:wavesRect
                      usingBlock:^(SKPhysicsBody* body, BOOL *stop)
    {
        if(body.isDynamic)
        {
            SKNode* node = [body node];
            CGPoint pos = [node position];
            
            float x = pos.x;
            float y = [self valueAt:[self globalXToWaveX:x]];
            y = [self waveYToGlobalY:y];
            
            CGPoint scenePosition = [[self scene] convertPoint:CGPointZero
                                                      fromNode:self];
            
            if([node position].y < scenePosition.y + [self size].height*0.5 + y)
            {
                CGVector buoyancyForce = {10*waterDensity*gravity.dx,
                                         10*waterDensity*gravity.dy};

                [body applyForce:buoyancyForce];
                
                if(turbulence){
                    float vdirection = 1.0f;
                    if(turbulenceV > 0)
                        vdirection = -1.0f;
             
                    CGVector vector = CGVectorMake(vdirection*turbulenceVelocity/10.0f, 0);
                    [body applyImpulse:vector];
                }
                
                
                NSString* hadSplash = [bodySplashes objectForKey:[NSString stringWithFormat:@"%p", body]];
                if(hadSplash == nil && splashCollision){
                    
                    float splashX = [self globalXToWaveX:x];
                    NSArray* splashes = [self createSplash:splashX
                                                         h:splashHeight*node.yScale
                                                         w:splashWidth*node.xScale
                                                         t:splashTime];
                    int i = 0;
                    for(LHWave* wave in splashes){
                        [wave step];
                        ++i;
                        // if(i > 2)break;
                    }
                    [bodySplashes setObject:[NSNumber numberWithBool:YES]
                                     forKey:[NSString stringWithFormat:@"%p", body]];
                }
            }
            else{
                [bodySplashes removeObjectForKey:[NSString stringWithFormat:@"%p", body]];
            }
        }
        
    }];
    
#endif
    
}

@end
