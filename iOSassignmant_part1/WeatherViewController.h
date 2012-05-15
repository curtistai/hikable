//
//  WeatherViewController.h
//  MapDirections
//
//  Created by KITWAI CHUNG on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherViewController : UIViewController

{
    NSMutableArray  *arryDataMutable;  
    IBOutlet UITextField *inputcityname;
    NSString *location;
    //NSMutableArray  *tempData;  
    
    //天气图片显示view  
    UIImageView  *iocnImage;  
    UIImageView *iconImage1;  
    UIImageView *iconImage2;  
    UIImageView *iconImage3;  
    UIImageView *iconImage4;  
    //UIImageView *iconImage5;  
    //UIImageView *iconImage6;  
    
    
    
    //当日天气基本信息显示文本框  
    
    IBOutlet UILabel *cityLable;  //城市  
    IBOutlet UILabel *forecast_dateLable;//日期  
    IBOutlet UILabel *conditionLable; //天气情况  
    IBOutlet UILabel  *temp_fLable;     //华氏温度  
    IBOutlet UILabel  *temp_cLable;   //摄氏温度  
    IBOutlet UILabel  *humidityLable;   //湿度  
    IBOutlet UILabel  *wind_conditionLable;  //风信息  
    
    //往后几日天气信息显示文本框  
    IBOutlet UILabel  *day_of_weekcLable1;    
    IBOutlet UILabel  *day_of_weekcLable2;  
    IBOutlet UILabel  *day_of_weekcLable3;  
    IBOutlet UILabel  *day_of_weekcLable4;  
    //IBOutlet UILabel  *day_of_weekcLable5;  
    
    //解析出的时间日期显示文本框  
    IBOutlet UILabel  *datetimeLabel;  
    
    
    //可变数组大小存储变量  
    int  arrySizInt;  
    
    
    //UITableView *tableView;  
    
}

@property (nonatomic, retain)IBOutlet UILabel *cityLable;  
@property (nonatomic, retain)IBOutlet UILabel *forecast_dateLable;  
@property (nonatomic, retain)IBOutlet UILabel *conditionLable;  
@property (nonatomic, retain)IBOutlet UILabel *temp_fLable;  
@property (nonatomic, retain)IBOutlet UILabel *temp_cLable;  
@property (nonatomic, retain)IBOutlet UILabel *humidityLable;  
@property (nonatomic, retain)IBOutlet UILabel *wind_conditionLable;  

@property(nonatomic ,retain) NSMutableArray  *arryDataMutable;  

@property (nonatomic,retain)IBOutlet UIImageView *iconImage;  
@property (nonatomic,retain)IBOutlet UIImageView *iconImage1;  
@property (nonatomic,retain)IBOutlet UIImageView *iconImage2;  
@property (nonatomic,retain)IBOutlet UIImageView *iconImage3;  
@property (nonatomic,retain)IBOutlet UIImageView *iconImage4;  
//@property (nonatomic,retain)IBOutlet UIImageView *iconImage5;  
//@property (nonatomic,retain)IBOutlet UIImageView *iconImage6;  

//@property (nonatomic, retain) NSMutableArray *tempData;  


@property (nonatomic,retain)IBOutlet UILabel  *day_of_weekcLable1;  
@property (nonatomic,retain)IBOutlet UILabel  *day_of_weekcLable2;  
@property (nonatomic,retain)IBOutlet UILabel  *day_of_weekcLable3;  
@property (nonatomic,retain)IBOutlet UILabel  *day_of_weekcLable4;  
//@property (nonatomic,retain)IBOutlet UILabel  *day_of_weekcLable5;  

@property (nonatomic,retain)IBOutlet UILabel *datetimeLabel;  


@property int arrySizInt;  

//@property (nonatomic, retain)IBOutlet UITableView *tableView;  
-(IBAction) GetLocalWeather;
-(void) GetLocalWeatherMethod;

//@property (nonatomic, retain)IBOutlet UITableView *tableView;  
@end


