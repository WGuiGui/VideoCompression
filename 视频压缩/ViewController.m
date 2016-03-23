//
//  ViewController.m
//  视频压缩
//
//  Created by qian on 16/1/6.
//  Copyright © 2016年 compangy. All rights reserved.
//

#import "ViewController.h"
#import "UzysAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>                       //播放声音
#import <CoreAudio/CoreAudioTypes.h>                        //录音
#import <MediaPlayer/MediaPlayer.h>
#import "NSString+ext.h"
#import "ChatPublicFunc.h"

@interface ViewController ()<UzysAssetsPickerControllerDelegate>

@property (nonatomic, strong) NSString * videoThumbnailPath;
@property (nonatomic, strong) NSString * groupId;

-(IBAction)myButtonClick:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupId = @"123456789";
    // Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)myButtonClick:(id)sender
{
    UzysAssetsPickerController * uzysVC = [[UzysAssetsPickerController alloc]init];
    uzysVC.delegate = self;

    //需要设置多选图片的个数，如果只要图片，就把下面的video设置为0，photo设置成你可选的数量就行了
    uzysVC.maximumNumberOfSelectionVideo = 10;
    uzysVC.maximumNumberOfSelectionPhoto = 10;
    [self presentViewController:uzysVC animated:YES completion:^{
    }];
}

//在这儿方法里获取图片进行下一步操作
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSMutableArray * imageArray = [NSMutableArray array];
    NSMutableArray * urlArray = [NSMutableArray array];

    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"])
    {
        for (ALAsset *asset in assets) {
            //这个是获取到得相册里的图片
            UIImage *posterImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            [imageArray addObject:posterImage];
         
            //这个是图片在相册里的地址
            NSString * urlStr=asset.defaultRepresentation.url.absoluteString;
            [urlArray addObject:urlStr];
        }
        NSLog(@"%@--%@",imageArray,urlArray);
        
    } else {
        
        for (ALAsset * alAsset in assets) {
            NSString * urlStr=alAsset.defaultRepresentation.url.absoluteString;
            
            //这个是视频的截图，要在消息列表中显示，
            UIImage *img = [UIImage imageWithCGImage:alAsset.defaultRepresentation.fullResolutionImage scale:alAsset.defaultRepresentation.scale orientation:(UIImageOrientation)alAsset.defaultRepresentation.orientation];
            
            NSString * imageCachePath = [ChatPublicFunc saveImg:urlStr subPath:[NSString stringWithFormat:@"/Library/NBCache/%@/SaveVideoThumbImage/",self.groupId] imageObject:img];
            self.videoThumbnailPath = imageCachePath;
            
            //需要先判断文件夹是否存在，如果文件夹不存在，先要创建文件夹，然后再找到文件或者进行视频压缩
            NSString * saveVideopath = [NSString stringWithFormat:@"%@/Library/NBCache/%@/SaveVideo/",NSHomeDirectory(),self.groupId];
            if (![[NSFileManager defaultManager] fileExistsAtPath:saveVideopath]) {
                NSError * error = nil;
                
                if ([[NSFileManager defaultManager] createDirectoryAtPath:saveVideopath withIntermediateDirectories:YES attributes:nil error:&error]){
                    
                    [self videoCompressionWith:[NSURL URLWithString:urlStr] toVideoSavePath:saveVideopath localVideoPath:nil videoThumbnailPath:imageCachePath];
                } else {
                    
                    NSLog(@"%@",error);
                }
            } else {
                
                [self videoCompressionWith:[NSURL URLWithString:urlStr] toVideoSavePath:saveVideopath localVideoPath:nil videoThumbnailPath:imageCachePath];
            }
        }
    }
}
-(void)videoCompressionWith:(NSURL *)url toVideoSavePath:(NSString *)videoSavePath localVideoPath:(NSString *)localPath videoThumbnailPath:(NSString *)videoThumb
{
    if (localPath.length) {
        NSArray * localPathArray = [localPath componentsSeparatedByString:@"Library/NBCache/"];
        if (localPathArray.count == 2) {
            NSString * filePath = [NSString stringWithFormat:@"%@/Library/NBCache/%@",NSHomeDirectory(),localPathArray[1]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
    }
    
    NSString * videoOutputPath = [NSString stringWithFormat:@"%@%@.mov",videoSavePath,[[NSString stringWithFormat:@"%@",url] md5]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoOutputPath]) {
        
        AVURLAsset * urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetExportSession * exportSession = [AVAssetExportSession exportSessionWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        exportSession.outputURL = [NSURL fileURLWithPath:videoOutputPath];
        
        NSLog(@"正在压缩");
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusUnknown");
                    break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusWaiting");
                    break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusExporting");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusCompleted");
                    [self videoCompressSuccess:url savePath:videoOutputPath videoThumbPath:videoThumb];
                    break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusFailed");
                    [self videoCompressFailed:url];
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusCancelled");
                    break;
                default:
                    break;
            }
        }];
    } else {
        [self videoHasExist:url filePath:videoOutputPath];
    }
}

#pragma mark - 视频压缩成功的操作
-(void)videoCompressSuccess:(NSURL *)url savePath:(NSString *)savePath videoThumbPath:(NSString *)thumbPath
{
    NSData * videoData = [NSData dataWithContentsOfFile:savePath];
    NSLog(@"%lu",(unsigned long)videoData.length);
}

#pragma mark- 如果本地已经存在url对应的视频，就从本地取出来发送
-(void)videoHasExist:(NSURL *)url filePath:(NSString *)filePath
{
    NSData * videoData =[NSData dataWithContentsOfFile:filePath];
    NSLog(@"%lu",(unsigned long)videoData.length);
}

#pragma mark - 压缩视频失败后的操作--从相册中发送视频资源
-(void)videoCompressFailed:(NSURL *)url
{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset){
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc((long)rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(long)rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        //data就是本地相册中视频的data
        NSLog(@"%lu",(unsigned long)data.length);

    } failureBlock:^(NSError *err) {
        NSLog(@"Error: %@",[err localizedDescription]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
