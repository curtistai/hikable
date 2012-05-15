//
//  WeatherViewController.m
//  MapDirections
//
//  Created by KITWAI CHUNG on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeatherViewController.h"

@implementation WeatherViewController

@synthesize iconImage,iconImage1,iconImage2,iconImage3,iconImage4;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder]; 
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    inputcityname.text = @"HongKong";
    [self GetLocalWeatherMethod];
}

-(void) GetLocalWeatherMethod
{
    
    @try {
        
        
        location = inputcityname.text;
        //api地址前缀  
        NSString *address = @"http://www.google.co.uk/ig/api?weather=";  
        
        //合成实际的访问地址  
        NSString *request = [NSString stringWithFormat:@"%@%@&hl=US&oe=UTF-8",address,location];  
        //声明URL进行地址访问  
        NSURL *URL = [NSURL URLWithString:request];  
        NSError *error;      
        //获取XML文件，如果编码格式不是UTF-8，需要对网页进行转码  
        NSString *XML = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];  
        
        //NSLog(@"XML: %@", XML);  
        
        /***************使用分段方法对xml前半部分进行解析************/  
        // 温度获取   摄氏  
        
        //if ([[[[[XML componentsSeparatedByString:@"temp_f data=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0] count] == 0) {
        //    NSLog(@"eroor !!!!!!!!!!!");
        // }
        
        
        
        NSString *tempInC = [[[[XML componentsSeparatedByString:@"temp_c data=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];  
        //  温度获取  华氏  
        NSString *tempInF = [[[[XML componentsSeparatedByString:@"temp_f data=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];  
        //  城市获取   
        NSString *city = [[[[XML componentsSeparatedByString:@"postal_code data=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];  
        //  日期获取  
        NSString *date = [[[[XML componentsSeparatedByString:@"forecast_date data=\""]objectAtIndex:1]componentsSeparatedByString:@"\""]objectAtIndex:0];  
        //  天气获取  
        NSString *condition = [[[[XML componentsSeparatedByString:@"condition data=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];  
        //  湿度获取  
        NSString *humidity = [[[[XML componentsSeparatedByString:@"humidity data=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];  
        //  风信息获取  
        NSString *wind = [[[[XML componentsSeparatedByString:@"wind_condition data=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];  
        
        //  天气图片获取，需要获取图片的实际地址，获取后存放在NSData中  
        NSString *icon = [[[[XML componentsSeparatedByString:@"icon data=\""]objectAtIndex:1]componentsSeparatedByString:@"\""]objectAtIndex:0];  
        
        iconImage.image=nil;  
        
        NSString* path =[NSString stringWithFormat: @"http://www.google.co.uk%@",icon];  
        NSURL* url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//网络图片url  
        NSData* data = [NSData dataWithContentsOfURL:url];//获取网络图片数据  
        
        arryDataMutable = [[NSMutableArray alloc] init];  
        
        //打印输出  
        cityLable.text = city;  
        forecast_dateLable.text = date;  
        conditionLable.text = condition;  
        humidityLable.text = humidity;  
        wind_conditionLable.text = wind;  
        temp_fLable.text = [NSString stringWithFormat:@"%@ %@",tempInF, @" F"] ;  
        temp_cLable.text = [NSString stringWithFormat:@"%@ %@",tempInC, @" C"] ;  
        
        //对图片进行圆角处理并显示  
        CALayer *layer = [iconImage layer];  
        [layer setMasksToBounds:YES];  
        [layer setCornerRadius:5.0];  
        [layer setBorderWidth:1.0];  
        [layer setBorderColor:[UIColor blackColor].CGColor];  
        iconImage.image = [[UIImage alloc] initWithData:data];//根据图片数据流构造image  
        
        //    //TEST  
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];  
        [parser setDelegate:self];  
        [parser parse];  
        
        arrySizInt = [arryDataMutable count];  
        //NSLog(@"[arryDataMutable count]: %d", arrySizInt);  
        
        
        //接下来获取剩余四天的天气情况。（谷歌天气每次只有未来四天的信息）  
        
        //初始化计数，通过次变量的值来打印输出未来四天的信息  
        int counter = 0;  
        
        //循环开始，这里从1开始，因为可变数组中第0个，是当天的信息，已经解析输出  
        for (int i=1; i<arrySizInt; i++)  
        {  
            //NSLog(@"Array: %@", [arryDataMutable objectAtIndex:i]);  
            
            
            //获取数组中的对象，存放在字符串中  
            NSString *dayStr = [[NSString alloc] initWithString:[arryDataMutable objectAtIndex:i]];  
            //          
            //        if ([dayStr isEqualToString:@"Mon"] ||  
            //            [dayStr isEqualToString:@"Tue"] ||  
            //            [dayStr isEqualToString:@"Wed"] ||  
            //            [dayStr isEqualToString:@"Thu"] ||  
            //            [dayStr isEqualToString:@"Fri"] ||  
            //            [dayStr isEqualToString:@"Sat"] ||  
            //            [dayStr isEqualToString:@"Sun"] )  
            
            
            //判断获取的元素是那一天，是需要判断是否相等即可，并且使用或的运算，只要有一个为真，此表达式即成立  
            if ([dayStr isEqualToString:@"Mon"] ||  
                [dayStr isEqualToString:@"Tue"] ||  
                [dayStr isEqualToString:@"Wed"] ||  
                [dayStr isEqualToString:@"Thu"] ||  
                [dayStr isEqualToString:@"Fri"] ||  
                [dayStr isEqualToString:@"Sat"] ||  
                [dayStr isEqualToString:@"Sun"] )  
            {  
                
                NSLog(@"counter: %d", counter);  
                
                //获取数组中剩余的三项  
                //或许最低温度  
                NSString *lowStr ;
                NSString *highStr;
                NSString *path;
                if ([arryDataMutable count] != 0) {
                    //NSLog(@"!!!!!!");
                    lowStr = [[NSString alloc] initWithString:[arryDataMutable objectAtIndex:(i+1)]];  
                    //获取最高温度  
                    highStr = [[NSString alloc] initWithString:[arryDataMutable objectAtIndex:(i+2)]];  
                    //获取天气图片路径  
                    path = [[NSString alloc] initWithString:[arryDataMutable objectAtIndex:(i+3)]]; 
                }
                
                
                NSString* iconpath =[NSString stringWithFormat: @"http://www.google.co.uk%@",path];  
                NSURL* url = [NSURL URLWithString:[iconpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//网络图片url  
                NSData* data = [NSData dataWithContentsOfURL:url];//获取图片数据  
                
                
                //获取天气情况  
                NSString *conditions = [[NSString alloc] initWithString:[arryDataMutable objectAtIndex:(i+4)]];  
                
                
                //将获取的信息整理存放  
                NSString *tempStrToDisp = [NSString stringWithFormat: @"%@\n %@℃ /%@℃ \n%@", dayStr, lowStr, highStr, conditions];  
                //打印输出  
                if (counter == 0)//第一个树结点  
                {  
                    
                    day_of_weekcLable1.text = tempStrToDisp;  
                    CALayer *layer = [iconImage1 layer];  
                    [layer setMasksToBounds:YES];  
                    [layer setCornerRadius:5.0];  
                    [layer setBorderWidth:1.0];  
                    [layer setBorderColor:[UIColor blackColor].CGColor];  
                    iconImage1.image = [[UIImage alloc] initWithData:data];  
                }  
                
                
                if (counter == 1)//第二个树结点  
                {  
                    
                    day_of_weekcLable2.text = tempStrToDisp;  
                    CALayer *layer = [iconImage2 layer];  
                    [layer setMasksToBounds:YES];  
                    [layer setCornerRadius:5.0];  
                    [layer setBorderWidth:1.0];  
                    [layer setBorderColor:[UIColor blackColor].CGColor];  
                    iconImage2.image = [[UIImage alloc]initWithData:data];  
                }  
                
                
                if (counter == 2)//第三个树结点  
                {  
                    
                    day_of_weekcLable3.text = tempStrToDisp;  
                    CALayer *layer = [iconImage3 layer];  
                    [layer setMasksToBounds:YES];  
                    [layer setCornerRadius:5.0];  
                    [layer setBorderWidth:1.0];  
                    [layer setBorderColor:[UIColor blackColor].CGColor];  
                    iconImage3.image = [[UIImage alloc]initWithData:data];  
                }  
                
                
                if (counter == 3)//第四个树结点  
                {  
                    
                    day_of_weekcLable4.text = tempStrToDisp;  
                    CALayer *layer = [iconImage4 layer];  
                    [layer setMasksToBounds:YES];  
                    [layer setCornerRadius:5.0];  
                    [layer setBorderWidth:1.0];  
                    [layer setBorderColor:[UIColor blackColor].CGColor];  
                    iconImage4.image = [[UIImage alloc]initWithData:data];  
                }  
                
                
                //计数加1,进行循环  
                counter = counter + 1;  
            }  
            
            
        }//循环结束  
        
        
        
    }@catch (NSException* e) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"City :%@",inputcityname.text]
                              message:@"Sorry, Cannot found weather..."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert autorelease];
        [alert show];
    }
    
}

-(IBAction) GetLocalWeather
{
    [self GetLocalWeatherMethod];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict   
{  
    
    //NSLog(@"XML Parser 1 ... elementName ... %@", elementName);  
    //依此得到叶子结点和其属性值  
    
    if ([elementName isEqualToString:@"day_of_week"])   
    {   
        NSString *tempStr = [attributeDict objectForKey:@"data"];   
        //NSLog(@"day-of-week: %@", tempStr);  
        
        [arryDataMutable addObject:tempStr];  
        
    }  
    
    if ([elementName isEqualToString:@"low"])   
    {   
        NSString *tempStr = [attributeDict objectForKey:@"data"];   
        [arryDataMutable addObject:tempStr];  
        
    }  
    
    if ([elementName isEqualToString:@"high"])   
    {   
        NSString *tempStr = [attributeDict objectForKey:@"data"];   
        [arryDataMutable addObject:tempStr];  
        
    }  
    
    if ([elementName isEqualToString:@"condition"])   
    {   
        NSString *tempStr = [attributeDict objectForKey:@"data"];   
        [arryDataMutable addObject:tempStr];  
    }  
    if ([elementName isEqualToString:@"icon"])   
    {   
        NSString *tempStr = [attributeDict objectForKey:@"data"];   
        [arryDataMutable addObject:tempStr];  
    }  
    
    
    
}  

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string   
{  
    
    //NSLog(@"XML Parser 2 ...");  
    //NSLog(@"string ... %@", string);  
    
}  

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName   
{  
    //NSLog(@"XML Parser 3 ...");  
    //NSLog(@"elementName: %@", elementName);  
    //NSLog(@"namespaceURI: %@", namespaceURI);  
    //NSLog(@"qName: %@", qName);  
}  

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
