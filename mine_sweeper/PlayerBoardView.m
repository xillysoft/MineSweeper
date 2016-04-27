//
//  PlayerBoardView.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//
#import <OpenGLES/ES1/gl.h>
#import <CoreText/CoreText.h>
#import "PlayerBoard.h"
#import "PlayerBoardView.h"
#import "CellLocation.h"
#import "GameViewController.h"

uint32_t nextPowerOfTwo(uint32_t v)
{
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v++;
    return v;
}

//you are responsible of glDeleteTextures() the generated texture!
GLuint CreateTextureFromText(NSAttributedString *attriText)
{
    CGSize textSize = [attriText size];
    textSize.width = nextPowerOfTwo(textSize.width);
    textSize.height = nextPowerOfTwo(textSize.height);
    size_t numBytes = textSize.width*textSize.height*4;
    void * pixels = malloc(numBytes);
    memset(pixels, 0, numBytes); //IMPORTANT!
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(pixels, textSize.width, textSize.height, 8, textSize.width*4, colorSpace, kCGImageAlphaNoneSkipLast|kCGBitmapByteOrder32Big);
    UIGraphicsPushContext(bitmapContext);
    //flip y-
    CGContextTranslateCTM(bitmapContext, 0, textSize.height);
    CGContextScaleCTM(bitmapContext, 1, -1);
    [attriText drawInRect:CGRectMake(0, 0, textSize.width, textSize.height)];
    UIGraphicsPopContext();
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmapContext);
    GLuint texture;
//    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST); //VERY IMAPORTANT to set!
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textSize.width, textSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    free(pixels);
    return texture;
}


@interface PlayerBoardView(){
    EAGLContext *_eaglContext;
    GLfloat _zNear;
    GLfloat _zFar;
    GLfloat _left;
    GLfloat _right;
    GLfloat _bottom;
    GLfloat _top;
}

@property GLKTextureInfo *textureInfoMineIcon;
@property GLKTextureInfo *textureInfoUncertainIcon;

@end


@implementation PlayerBoardView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialize];
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if(self){
        [self initialize];
    }
    return self;
}

//initializer method
-(void)initialize
{
    //register single-tap handler
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapRecognizer];
    
    //register double-tap handler
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self addGestureRecognizer:doubleTapRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:longPressRecognizer];
    
    [self setupOpenGL];
}

//UITapGestureRecognizer handler, 通知delegate单击事件发生
-(void)handleSingleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{    
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    CellLocation *location = [self cellLocationAtPoint:point];
    if(location && [self.listener respondsToSelector:@selector(player:didSingleTapOnCell:)]) {
        [self.listener player:self didSingleTapOnCell:location];
    }
}


//UITapGestureRecognizer handler，通知delegate双击事件发生
-(void)handleDoubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    CellLocation *location = [self cellLocationAtPoint:point];
    if(location && [self.listener respondsToSelector:@selector(player:didDoubleTapOnCell:)]){
        [self.listener player:self didDoubleTapOnCell:location];
    }
}

//UITapGestureRecognizer handler，通知delegate长按事件发生
-(void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    //UILongPressGestureRecognizer is a continuous recognizer
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
        CellLocation *location = [self cellLocationAtPoint:point];
        if(location && [self.listener respondsToSelector:@selector(player:didLongPressOnCell:)]) {
            [self.listener player:self didLongPressOnCell:location];
        }
    }
}

//计算在view上的touch point(x,y)对应的单元格(row, column)
- (CellLocation *)cellLocationAtPoint:(CGPoint)point
{
    CGRect bounds = self.bounds;
    PlayerBoard *playerBoard = self.playerBoard;
    CGFloat hSize = bounds.size.width/playerBoard.columns;
    CGFloat vSize = bounds.size.height/playerBoard.rows;
    CGFloat size = MIN(hSize, vSize);
    int columns = playerBoard.columns;
    int rows = playerBoard.rows;
    CGFloat x0 = (bounds.size.width-size*columns)/2; //必须和-drawRect:方法相对应
    CGFloat y0 = (bounds.size.height-size*rows)/2;
    point.x -= x0;
    point.y -= y0;
    if(point.x>=0 && point.x<=size*columns && point.y>=0 && point.y<size*rows){
        int row = point.y/size;
        int column = point.x/size;
        return [[CellLocation alloc] initWithRow:row column:column];
    }else{
        return nil;
    }
}

#pragma mark -
#pragma mark IPlayerBoardDelegate
-(void)minesLaidOnMineBoard:(int)numberOfMinesLaid
{
#ifdef DEBUG
    NSLog(@"--PlayerBoardView::minesLaidOnMineBoard:%d!", numberOfMinesLaid);
#endif
//    [self setNeedsDisplay]; 
}

-(void)cellMarkChangedFrom:(CellState)oldState to:(CellState)newState atRow:(int)row column:(int)column;
{
#ifdef DEBUG
    NSLog(@"--PlayerBoardView::cell[%d][%d] MarkChangedFrom:%ld to:%ld!", row, column, (long)oldState, (long)newState);
#endif
    [self setNeedsDisplay];
}

-(void)cellDidUncoverAtRow:(int)row column:(int)column
{
#ifdef DEBUG
    NSLog(@"--PlayerBoardView::cellDidUncoverAtRow:%d column:%d!", row, column);
#endif
    [self setNeedsDisplay];
}

-(void)mineDidExplodeAtRow:(int)row column:(int)column
{
#ifdef DEBUG
    NSLog(@"--PlayerBoardView::mineDidExplodAtRow:%d column:%d!", row, column);
#endif
    [self setNeedsDisplay];
}

#pragma mark -



-(void)setupOpenGL
{
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    self.context = _eaglContext;
    [EAGLContext setCurrentContext:_eaglContext];
    //    self.playerBoardView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    glClearColor(0, 1, 1, 1);
    
    self.contentMode = UIViewContentModeRedraw;
    self.enableSetNeedsDisplay = YES;
    
    UIImage *mineIcon = [UIImage imageNamed:@"mine_flag.png"];
    self.textureInfoMineIcon = [GLKTextureLoader textureWithCGImage:mineIcon.CGImage options:nil error:nil];

    UIImage *uncertainIcon = [UIImage imageNamed:@"uncertain.gif"];
    self.textureInfoUncertainIcon = [GLKTextureLoader textureWithCGImage:uncertainIcon.CGImage options:nil error:nil];
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
}

-(void)layoutSubviews
{
    NSInteger width = self.bounds.size.width;
    NSInteger height = self.bounds.size.height;
    if(width==0 || height==0) return;
    
    glViewport(0, 0, width, height);

    _zNear = 1;
    _zFar = 100;
    
    GLfloat aspect = (GLfloat)width/height;
    if(width < height) {
        _left = -1;
        _right = 1;
        _bottom = -1.0/aspect;
        _top = 1.0/aspect;
    }else{ //width>height
        _left = -1*aspect;
        _right = 1*aspect;
        _bottom = -1;
        _top = 1;
    }
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity(); //
    glOrthof(_left, _right, _bottom, _top, _zNear, _zFar);
    glMatrixMode(GL_MODELVIEW);
}

- (void)drawRect:(CGRect)rect
{

    if(self.playerBoard == nil)
        return;

    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();
    glTranslatef(0, 0, -_zNear);
    
    GLfloat width = _right - _left;
    GLfloat height = _top - _bottom;
    
    //flip y- axis
    glTranslatef(0, -(_bottom+_top)/2, 0);
    glScalef(1, -1, 1);
    glTranslatef(0, (_bottom+_top)/2, 0);
    
    PlayerBoard *playerBoard = self.playerBoard;
    int columns = playerBoard.columns;
    int rows = playerBoard.rows;
    CGFloat hSize = width/columns;
    CGFloat vSize = height/rows;
    CGFloat size = MIN(hSize, vSize);
    CGFloat x0 = _left + (width - size*columns)/2;
    CGFloat y0 = _bottom + (height - size*rows)/2;
    
    NSDictionary *attribs =({
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentCenter;
        @{NSForegroundColorAttributeName:[UIColor blueColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSParagraphStyleAttributeName:paraStyle};
    });
    

    GLfloat rectVertices[] = {
        0, size, 0,
        0, 0, 0,
        size, 0, 0,
        size, size, 0
    };
    
    GLfloat rectTexCoords[] = {
        0, 1,
        0, 0,
        1, 0,
        1, 1
    };
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, rectVertices);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, rectTexCoords);

    CGFloat y = y0;
    for(int row=0; row<rows; row++, y+=size){
        CGFloat x = x0;
        for(int column=0; column<columns; column++, x+=size){
            glPushMatrix();
            {
                CellState state = [self.playerBoard cellStateAtRow:row column:column];
                switch(state){
                    case CellStateCoveredNoMark:
                    {
                        glColor4f(0, 1, 0, 1);
//                        glScalef(size, size, 1);
                        glTranslatef(x, y, 0);
                        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
                        glColor4f(0.25, 0.25, 0.25, 1);
                        glDrawArrays(GL_LINE_LOOP, 0, 4);
                    }
                    break;
                        
                    case CellStateCoveredMarkedAsMine:
                    {
                        glEnable(GL_TEXTURE_2D);
                        
                        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
                        glColor4f(0, 1, 0, 1);
                        
                        glBindTexture(self.textureInfoMineIcon.target, self.textureInfoMineIcon.name);
                        
//                        glScalef(size, size, 1);
                        glTranslatef(x, y, 0);
                        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
                        glColor4f(0.25, 0.25, 0.25, 1);
                        glDrawArrays(GL_LINE_LOOP, 0, 4);

                        glDisable(GL_TEXTURE_2D);
                    }
                    break;
                        
                    case CellStateCoveredMarkedAsUncertain:
                    {
                        glEnable(GL_TEXTURE_2D);
                        
                        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
                        glColor4f(0, 1, 0, 1);
                        glBindTexture(self.textureInfoUncertainIcon.target, self.textureInfoUncertainIcon.name);
                        
                        glTranslatef(x, y, 0);
                        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
                        glColor4f(0.25, 0.25, 0.25, 1);
                        glDrawArrays(GL_LINE_LOOP, 0, 4);
                        
                        glDisable(GL_TEXTURE_2D);
                    }
                        
                    break;
                        
                    case CellStateUncovered:
                    {
                        glTranslatef(x, y, 0);
                        
                        if(! [playerBoard hasMineAtRow:row column:column]){
                            int numberOfMinesAround = [playerBoard numberOfMinesAroundCellAtRow:row column:column];
                            if(numberOfMinesAround > 0){ //show numberOfMinesArount cell[row][column]
                                NSString *text = [NSString stringWithFormat:@"%d", numberOfMinesAround];
                                NSAttributedString *attriText = [[NSAttributedString alloc] initWithString:text attributes:attribs];
                                {
                                    GLuint texture = CreateTextureFromText(attriText);
                                    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
                                    glColor4f(0.75, 0.75, 0.75, 1);
                                    glEnable(GL_TEXTURE_2D);
                                    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
                                    glDisable(GL_TEXTURE_2D);
                                    glDeleteTextures(1, &texture);
                                }
                                
                            }else{ //numberOfMinesAround == 0
                                glColor4f(0.75, 0.75, 0.75, 1);
                                glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
                            }
                        }else{ //[playerBoard hasMineAtRow:row column:column]==YES
                            NSString *text = @"BOOM!";
                            CGSize textSize = [text sizeWithAttributes:attribs];
                            textSize.width = nextPowerOfTwo(textSize.width);
                            textSize.height = nextPowerOfTwo(textSize.height);
                            CreateTextureFromText([[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[UIColor yellowColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}]);
                            glEnable(GL_TEXTURE_2D);
                            glColor4f(1, 0, 0, 1);
                            glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
                            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
                            glDisable(GL_TEXTURE_2D);
                        }
                        glColor4f(0.25, 0.25, 0.25, 1);
                        glDrawArrays(GL_LINE_LOOP, 0, 4);

                    }
                    break;
                }
                
//            CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
//            CGContextStrokeRect(context, cellRect);
        }
        glPopMatrix();
        }
    }
}

@end
