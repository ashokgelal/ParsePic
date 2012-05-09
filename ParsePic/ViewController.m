//
//  Copyright (c) 2012 Ashok Gelal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (IBAction)refresh:(UIBarButtonItem *)sender;
- (IBAction)cameraButtonTapped:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;

@end

@implementation ViewController
{
    PF_MBProgressHUD *hud;
    PF_MBProgressHUD *refreshHud;
    NSMutableArray *allImages;
}

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
    NSLog(@"Showing refresh HUD");
    refreshHud = [[PF_MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:refreshHud];
    
    refreshHud.delegate = self;
    
    [refreshHud show:YES];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"user" equalTo:user];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            if(refreshHud){
                [refreshHud hide:YES];
                
                refreshHud = [[PF_MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:refreshHud];
                
                refreshHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                
                refreshHud.mode = PF_MBProgressHUDModeCustomView;
                
                refreshHud.delegate = self;
            }
            NSLog(@"Successfully retrieved %d photos.", objects.count);
            
            NSMutableArray *oldCompareObjectIDArray = [NSMutableArray array];
            
            for(UIView *view in [self.photoScrollView subviews]){
                if([view isKindOfClass:[UIButton class]]){
                    UIButton *eachButton = (UIButton *)view;
                    
                    [oldCompareObjectIDArray addObject:[eachButton titleForState:UIControlStateReserved]];
                }
            }
            
            NSMutableArray *oldComparedObjectIDArray2 = [NSMutableArray arrayWithArray:oldCompareObjectIDArray];
            
            NSMutableArray *newObjectIDArray = [NSMutableArray array];
            if(objects.count > 0){
                for (PFObject *eachObject in objects) {
                    [newObjectIDArray addObject:[eachObject objectId]];
                }
            }
            
            NSMutableArray *newCompareObjectIDArray = [NSMutableArray arrayWithArray:newObjectIDArray];
            NSMutableArray *newcompareObjetIDArray2 = [NSMutableArray arrayWithArray:newObjectIDArray];
            
            if(oldCompareObjectIDArray.count > 0){
                [newCompareObjectIDArray removeObjectsInArray:oldCompareObjectIDArray];
                [oldCompareObjectIDArray removeObjectsInArray:newcompareObjetIDArray2];
                
                if(oldCompareObjectIDArray.count > 0){
                    NSMutableArray *listOfToRemove = [[NSMutableArray alloc] init];
                    for (NSString *objectId in oldCompareObjectIDArray) {
                        int i = 0;
                        
                        for (NSString *oldObjectId in oldComparedObjectIDArray2) {
                            if([objectId isEqualToString:oldObjectId]){
                                [listOfToRemove addObject:[NSNumber numberWithInt:i]];
                            }
                            i++;
                        }
                    } 
                    NSSortDescriptor *highestToLower = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
                    [listOfToRemove sortUsingDescriptors:[NSArray arrayWithObject:highestToLower]];
                    
                    for (NSNumber *index in listOfToRemove) {
                        [allImages removeObjectAtIndex:[index intValue]];
                    }
                }
            }
            for (NSString *objectId in newCompareObjectIDArray) {
                for (PFObject *eachObject in objects) {
                    if([[eachObject objectId] isEqualToString:objectId]){
                        NSMutableArray *selectedPhotoArray = [[NSMutableArray alloc] init];
                        [selectedPhotoArray addObject:eachObject];
                        
                        if(selectedPhotoArray.count > 0){
                            [allImages addObjectsFromArray:selectedPhotoArray];
                        }
                    }
                }
            } 
            
            [self setUpImages:allImages];
        }else{
            [refreshHud hide:YES];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)setUpImages:(NSArray *)images
{
    
}

- (IBAction)cameraButtonTapped:(UIBarButtonItem *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
}

-(void)uploadImage:(NSData *)imageData{
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    hud = [[PF_MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    hud.mode = PF_MBProgressHUDModeDeterminate;
    hud.delegate = self;
    hud.labelText = @"Uploading";
    
    [hud show:YES];
    
    // save file
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            [hud hide:YES];
            
            hud = [[PF_MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            
            hud.mode = PF_MBProgressHUDModeCustomView;
            
            hud.delegate = self;
            
            PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            
            userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [userPhoto setObject:user forKey:@"user"];
            
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    [self refresh:nil];
                }
                else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else {
            [hud hide:YES];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        hud.progress = (float)percentDone/100;
    }];
}

#pragma mark - UIImagePickerControllerDelegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    [picker dismissModalViewControllerAnimated:YES];
    
    // Resize
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect:CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // upload image
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.05f);
    [self uploadImage:imageData];
}

#pragma mark - PF_MBProgressHUDDelegate

-(void)hudWasHidden:(PF_MBProgressHUD *)theHud{
    [hud removeFromSuperview];
    hud = nil;
}

@end
