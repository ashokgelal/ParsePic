//
//  Copyright (c) 2012 Ashok Gelal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (IBAction)refresh:(UIBarButtonItem *)sender;
- (IBAction)uploadImage:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;

@end

@implementation ViewController
@synthesize photoScrollView = _photoScrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setPhotoScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)refresh:(UIBarButtonItem *)sender {
}

- (IBAction)uploadImage:(UIBarButtonItem *)sender {
}
@end
