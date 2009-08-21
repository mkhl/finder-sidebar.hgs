//
//  FinderSidebarSource.m
//
//  Copyright (c) 2009  Martin Kuehl <purl.org/net/mkhl>
//  Licensed under the MIT License.
//

#import <Vermilion/Vermilion.h>
#import <GTM/GTMNSFileManager+Carbon.h>

static NSString *const kSidebarBundleIdentifier = @"com.apple.sidebarlists";
static NSString *const kSidebarItemsKey = @"useritems.CustomListItems";
static NSString *const kSidebarItemAliasKey = @"Alias";

@interface FinderSidebarSource : HGSMemorySearchSource
- (void)recacheContents;
@end

@implementation FinderSidebarSource

- (id)initWithConfiguration:(NSDictionary *)configuration
{
  self = [super initWithConfiguration:configuration];
  if (self == nil)
    return nil;
  if (![self loadResultsCache]) {
    [self recacheContents];
  } else {
    [self performSelector:@selector(recacheContents)
               withObject:nil
               afterDelay:10.0];
  }
  return self;
}

- (void)recacheContents
{
  [self clearResultIndex];
  NSDictionary *settings = [[NSUserDefaults standardUserDefaults]
                            persistentDomainForName:kSidebarBundleIdentifier];
  for (NSDictionary *item in [settings valueForKeyPath:kSidebarItemsKey]) {
    NSData *alias = [item valueForKey:kSidebarItemAliasKey];
    NSString *path = [[NSFileManager defaultManager]
                      gtm_pathFromAliasData:alias];
    [self indexResult:[HGSResult resultWithFilePath:path
                                             source:self
                                         attributes:nil]];
  }
  [self performSelector:@selector(recacheContents)
             withObject:nil
             afterDelay:60.0];
}

@end
