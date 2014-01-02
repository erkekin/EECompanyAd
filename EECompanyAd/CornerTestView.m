
#import "CornerTestView.h"

@implementation CornerTestView

static void pathInspector(void *info, const CGPathElement *element)
{
  	CornerTestView *view = (__bridge CornerTestView *)info;
  	[view addElement:element];
}

- (void)drawRect:(CGRect)dirtyRect
{
  	[[UIColor whiteColor] setFill];
  	UIRectFill(dirtyRect);
    
  	CGRect rect = self.bounds;
  	CGFloat size = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)) - 20;
  	size = round(size / 2) * 2;
  	rect = CGRectMake(round(CGRectGetMidX(rect) - size / 2), round(CGRectGetMidY(rect) - size / 2), size, size);
  	CGFloat radius = size / 4;
  	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
  	[[UIColor colorWithRed:0.90 green:0.93 blue:1.0 alpha:1.0] setFill];
  	[path fill];
    
  	CGPathRef cgPath = path.CGPath;
  	CGPathApply(cgPath, (__bridge void *)(self), pathInspector);
}

static UIBezierPath *crossAtPoint(CGPoint p)
{
  	UIBezierPath *cross = [UIBezierPath bezierPath];
  	cross.lineWidth = 0.5;
  	[cross moveToPoint:CGPointMake(p.x - 2, p.y - 2)];
  	[cross addLineToPoint:CGPointMake(p.x + 2, p.y + 2)];
  	[cross moveToPoint:CGPointMake(p.x - 2, p.y + 2)];
  	[cross addLineToPoint:CGPointMake(p.x + 2, p.y - 2)];
  	return cross;
}

- (void)addElement:(const CGPathElement *)element
{
  	switch (element->type) {
  		case kCGPathElementMoveToPoint:
  			[[UIColor grayColor] setStroke];
  			[crossAtPoint(element->points[0]) stroke];
  			self.previousPoint = element->points[0];
  			break;
  		case kCGPathElementAddLineToPoint:
  		{
  			UIBezierPath *line = [UIBezierPath bezierPath];
  			line.lineWidth = 0.25;
  			[[UIColor lightGrayColor] setStroke];
  			[line moveToPoint:self.previousPoint];
  			[line addLineToPoint:element->points[0]];
  			[line stroke];
            
  			[[UIColor redColor] setStroke];
  			[crossAtPoint(element->points[0]) stroke];
  			self.previousPoint = element->points[0];
  		}
  			break;
  		case kCGPathElementAddQuadCurveToPoint:
  		{
  			UIBezierPath *line = [UIBezierPath bezierPath];
  			line.lineWidth = 0.25;
  			[[UIColor lightGrayColor] setStroke];
  			[line moveToPoint:self.previousPoint];
  			[line addLineToPoint:element->points[0]];
  			[line addLineToPoint:element->points[1]];
  			[line stroke];
  			[[UIColor cyanColor] setStroke];
  			[crossAtPoint(element->points[0]) stroke];
  			[[UIColor magentaColor] setStroke];
  			[crossAtPoint(element->points[1]) stroke];
  			self.previousPoint = element->points[1];
  		}
  			break;
  		case kCGPathElementAddCurveToPoint:
  		{
  			UIBezierPath *line = [UIBezierPath bezierPath];
  			line.lineWidth = 0.25;
  			[[UIColor lightGrayColor] setStroke];
  			[line moveToPoint:self.previousPoint];
  			[line addLineToPoint:element->points[0]];
  			[line addLineToPoint:element->points[1]];
  			[line addLineToPoint:element->points[2]];
  			[line stroke];
  			[[UIColor greenColor] setStroke];
  			[crossAtPoint(element->points[0]) stroke];
  			[crossAtPoint(element->points[1]) stroke];
  			[[UIColor orangeColor] setStroke];
  			[crossAtPoint(element->points[2]) stroke];
  			self.previousPoint = element->points[2];
  		}
  			break;
  		case kCGPathElementCloseSubpath:
  			break;
  	}
}

@end
