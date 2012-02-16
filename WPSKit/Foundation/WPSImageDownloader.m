/**
 **   WPSImageDownloader
 **
 **   Created by Kirby Turner.
 **   Copyright 2011 White Peak Software. All rights reserved.
 **
 **   Permission is hereby granted, free of charge, to any person obtaining 
 **   a copy of this software and associated documentation files (the 
 **   "Software"), to deal in the Software without restriction, including 
 **   without limitation the rights to use, copy, modify, merge, publish, 
 **   distribute, sublicense, and/or sell copies of the Software, and to permit 
 **   persons to whom the Software is furnished to do so, subject to the 
 **   following conditions:
 **
 **   The above copyright notice and this permission notice shall be included 
 **   in all copies or substantial portions of the Software.
 **
 **   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
 **   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 **   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
 **   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
 **   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 **   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 **   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **
 **/

#import "WPSImageDownloader.h"
#import "UIApplication+WPSKit.h"

@interface WPSImageDownloader ()
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, copy) WPSImageDownloaderCompletionBlock completion;
@property (nonatomic, assign) NSInteger numberOfAttempts;

- (NSString *)cacheKey;
- (void)startConnection;
- (void)incrementNumberOfAttempts;
@end

@implementation WPSImageDownloader

@synthesize cache = _cache;
@synthesize image = _image;
@synthesize URL = _URL;
@synthesize completion = _completion;
@synthesize receivedData = _receivedData;
@synthesize retryCount = _retryCount;
@synthesize numberOfAttempts = _numberOfAttempts;

- (void)downloadImageAtURL:(NSURL *)URL completion:(void(^)(UIImage *image, NSError*))completion
{
   if (URL) {
      [self setNumberOfAttempts:0];
      [self setURL:URL];
      [self setCompletion:completion];
      
      if ([self cache]) {
         NSData *data = [[self cache] dataForKey:[self cacheKey]];
         if (data) {
            UIImage *image = [UIImage imageWithData:data];
            completion(image, nil);
            return;
         }
      }
      [self startConnection];
   }
}

- (void)startConnection
{
   [self setReceivedData:[[NSMutableData alloc] init]];
   NSURLRequest *request = [NSURLRequest requestWithURL:[self URL]];
   NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
   [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
   [connection start];
   [[UIApplication sharedApplication] wps_pushNetworkActivity];
   [self incrementNumberOfAttempts];
}

- (NSString *)cacheKey
{
   NSString *cacheKey = [[self URL] absoluteString];
   return cacheKey;
}

- (void)incrementNumberOfAttempts
{
   NSInteger numberOfAttempts = [self numberOfAttempts];
   [self setNumberOfAttempts:numberOfAttempts + 1];
}

#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   [[self receivedData] setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   [[self receivedData] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   [[UIApplication sharedApplication] wps_popNetworkActivity];
   
   [self setImage:[UIImage imageWithData:[self receivedData]]];
   if ([self cache]) {
      [[self cache] cacheData:[self receivedData] forKey:[self cacheKey] cacheLocation:WPSCacheLocationFileSystem];
   }
   [self setReceivedData:nil];
   
   WPSImageDownloaderCompletionBlock completion = [self completion];
   completion([self image], nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   [[UIApplication sharedApplication] wps_popNetworkActivity];
   [self setReceivedData:nil];
   
   if ([self numberOfAttempts] < [self retryCount]) {
      [self performSelector:@selector(startConnection) withObject:nil afterDelay:1.0];
   } else {
      WPSImageDownloaderCompletionBlock completion = [self completion];
      completion(nil, error);
   }
}

@end
