//
//  ViewController.m
//  app3
//
//  Created by Admin on 15.09.17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "ViewController.h"
#import "CellPrototype.h"
#import "OneDay+CoreDataProperties.h"


@interface  ViewController ()
< UITableViewDelegate, UITableViewDataSource >


@property (strong, nonatomic) IBOutlet  UITableView     *tableView;
@property (strong, nonatomic) IBOutlet  UITextField     *textFiledSteps;
@property (strong, nonatomic)           NSString        *target;
@property (strong, nonatomic)           NSMutableArray  *data;
@property                               NSInteger        countDate;
@property                               BOOL             openMenu;

@property (strong, nonatomic)           NSManagedObjectContext    * managedObjectContext ; // БД контекст

@end

@implementation ViewController



#pragma - ViewController lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // счетчик, для добавления следующего дня, к данным
    self.countDate  = 0;
    
    // инициализировать элементы для ЦЕЛИ
    [self createTarget];
    
    // инициализировать стартовый пробел (отступ)
    self.data = [@[ @"" ] mutableCopy];
    
    // загрузки истории из БД
    [self loadHistoryCoreData];
    
    
    // линия разделяющая ячейки - удалить
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.delegate     = self;
    self.tableView.dataSource   = self;
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // уведомление получаем контекст БД
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DatabaseNotification"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      _managedObjectContext = note.userInfo[@"Context"];
                                                  }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:   animated];
    
    [self animateTableCells];
}

// стартовое анимированное возникновение ячеек
- (void)animateTableCells {
    
    // вернуть видимые в данный момент ячейки
    NSArray *cells = self.tableView.visibleCells;
    
    for ( UITableViewCell *cell in cells ) {
        // переместить их влево за границу размеров View
        cell.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width,0);
    }
    // опоздание - при анимированном добавлении новой ячейки - опоздание для возникновения следующей ячейки - увеличивается
    CGFloat delay = 0.5;
    
    for ( UITableViewCell *cell in cells) {
        
        [UIView animateWithDuration: 0.2
                              delay: delay
             usingSpringWithDamping: 0.7
              initialSpringVelocity: 0
                            options: 0
                         animations: ^(void) {
                             
                             cell.transform = CGAffineTransformIdentity;
                             
                         }  completion: ^(BOOL finished) {}  ];
        
        delay = delay + 0.1;
    }
    
}



#pragma - UIButton action

// кнопка добавление новых (рандомных) данных
- (IBAction)addData:    (UIBarButtonItem *)sender {
    

    // добавить данные в конец  массива self.data
    [self.data insertObject: [self random] // генерация рандомных данных
                    atIndex: 1 ];// [self.data count]
    
    // добавать, обновить ячейку - в табличном виде
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]
                          withRowAnimation: UITableViewRowAnimationFade];
    


    // вернуть видимые ячейки в данный момент
    NSArray *cells = self.tableView.visibleCells;

    // вернуть 1 ячейку только что добавленную ячейку
    CellPrototype *cell = cells[1];
    
    NSDictionary *dataDictionary = self.data[1];
    // общее сделанное  кол-во шагов
    float steps = ( (NSString *)[dataDictionary objectForKey:@"progress" ]).floatValue;
    // цель             кол-во шагов
    float target = self.target.floatValue;
    // если сделанное кол-во шагов, превышает цель - анимируем появление звезды
    if ( steps > target ) {
        
        // разворачиваем на 180 градусов и уменьшаем до исчезновения
        cell.imageStar.transform = CGAffineTransformRotate( CGAffineTransformMakeScale(0.01 ,0.01) , (M_PI_2 * 2));
        
        // анимированно  возвращаем в исходное положение за 1 сек
        [UIView animateWithDuration: 1
                              delay: 0.5 // задержка
             usingSpringWithDamping: 1.5
              initialSpringVelocity: 0
                            options: UIViewAnimationOptionAllowUserInteraction
                         animations: ^(void) {  cell.imageStar.transform = CGAffineTransformIdentity;   }
                         completion: ^(BOOL finished) {}   ];
    }
    
    // анимируем возникновение элементов ProgressBar-a  - свигаем всех за вределы   View
    cell.bar1view.transform =CGAffineTransformMakeTranslation(-cell.MyProgressBar.frame.size.width  ,0);
    cell.bar2view.transform =CGAffineTransformMakeTranslation(-cell.MyProgressBar.frame.size.width*4,0);
    cell.bar3view.transform =CGAffineTransformMakeTranslation(-cell.MyProgressBar.frame.size.width*8,0);
    
    // анимированно возвращаем в исходное положение за 0.5 сек
    [UIView animateWithDuration: 0.5
                          delay: 0
         usingSpringWithDamping: 1.5
          initialSpringVelocity: 0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations: ^(void)
    {
        cell.MyProgressBar.transform = CGAffineTransformIdentity;
        cell.bar1view.transform = CGAffineTransformIdentity;
        cell.bar2view.transform = CGAffineTransformIdentity;
        cell.bar3view.transform = CGAffineTransformIdentity;
                     }
                     completion: ^(BOOL finished) {}   ];

    
    // переместить вид таблицы - к новой ячейке
    //  то есть если ты  находишься внизу - метод переместит тебя наверх 
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: 0 inSection:0]
                      atScrollPosition:UITableViewScrollPositionBottom
                              animated:1];
}

// генерация рандомных данных
- (NSDictionary *)random {
    
    int walk, aerobic, run, steps;
    
    // случайное число в пределах 100
    //  в 20% процентных случаях - будет выпадать число в пределах от 0 до 3200
    //  в 30% процентных случаях - будет выпадать число в пределах от 0 до 2200
    //  в 50% процентных случаях - будет выпадать число в пределах от 0 до 1200
    
            walk    = arc4random() % 100;
         if(walk    < 20)   walk    = arc4random() % 320;
    else if(walk    < 50)   walk    = arc4random() % 220;
    else                    walk    = arc4random() % 120;
    
            aerobic = arc4random() % 100;
         if(aerobic < 20)   aerobic = arc4random() % 320;
    else if(aerobic < 50)   aerobic = arc4random() % 220;
    else                    aerobic = arc4random() % 120;
    
            run     = arc4random() % 100;
         if(run     < 20)   run     = arc4random() % 320;
    else if(run     < 50)   run     = arc4random() % 220;
    else                    run     = arc4random() % 120;
    
    // складываем общее число
    steps = walk + aerobic + run;
    
    // преобразовывает текст в дату
    NSDateFormatter *dateFormatterStr = [NSDateFormatter new];
    [dateFormatterStr setDateFormat: @"dd.MM.yyyy"];    // формат принятия
    
    NSDate *setDate;
    
    // если в массиве (данных о днях, истории вобщем)   элементов больше 1-го
    //  изымать из истории данные последенго дня - что бы этот день был отправной точкой - для данных ДАТЫ
    //  если  данных нет (истории нет) - то использовать текущий день - для данных ДАТЫ
    if( 1 < [self.data count]) {
        setDate = [dateFormatterStr dateFromString: (NSString *)[((NSDictionary*)self.data[1]) objectForKey:@"date"]];
        setDate = [setDate       dateByAddingTimeInterval: 86400 ];
    } else {
        setDate = [[NSDate date] dateByAddingTimeInterval: 86400 * self.countDate++];
    }
    
    // сохранение истории в БД
    [self saveHistotyCoreData_date:setDate
                              walk:walk
                           aerobic:aerobic
                               run:run];
    
    // вернуть NSDictionary с данными
    return @{ @"date"       : [dateFormatterStr stringFromDate: setDate ]        ,
              @"progress"   : [NSString stringWithFormat:@"%d",steps    * 10]    ,
              @"walk"       : [NSString stringWithFormat:@"%d",walk     * 10]    ,
              @"aerobic"    : [NSString stringWithFormat:@"%d",aerobic  * 10]    ,
              @"run"        : [NSString stringWithFormat:@"%d",run      * 10]      };
    
    
}


// кнопка изменения цели
- (IBAction)editTarget: (UIBarButtonItem *)sender {
    
    // скрыть клавиатуру при нажатии на кнопку
    [self.textFiledSteps resignFirstResponder];
    
    // анимированно открыть меню
    if(self.openMenu == 0) {
        self.openMenu=1;
        [UIView animateWithDuration: 0.4
                         animations: ^(void) { self.tableView.transform =  CGAffineTransformMakeTranslation(+122,0); }
                         completion: ^(BOOL finished) {} ];
    } else {
        self.openMenu=0;
        [UIView animateWithDuration: 0.4
                         animations: ^(void) { self.tableView.transform =  CGAffineTransformIdentity; }
                         completion: ^(BOOL finished) {} ];
        
    }
    // перезагрузить таблицу
    [self.tableView reloadData];

}


// инициализировать элементы для ЦЕЛИ
- (void)createTarget {
    
    // меню  открыто/закрыто
    self.openMenu   = 0;
    // цель по умолчанию 4000
    self.target     = @"4000";
    self.textFiledSteps.text = self.target;
    // создать жест 1 прикосновение - что бы закрыть клавиатуру, в меню
    [self.view addGestureRecognizer: [ [UITapGestureRecognizer alloc] initWithTarget: self
                                                                              action: @selector( method_tap ) ]];
    
}
// жест нажатие по экрану
- (void)method_tap {
    // закрыть клавиатуру
    [self.textFiledSteps resignFirstResponder];
    
}
// изменить цель - при любом изменении текста
- (IBAction)textFieldeditingSteps:(UITextField *)sender {
    self.target = sender.text;
}



#pragma - CoreData

// загрузки истории из БД  - в массив  self.data
-(void)loadHistoryCoreData {
    
    // запрос, вернуть всех OneDay
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"OneDay"];
    NSArray *array = [self.managedObjectContext executeFetchRequest: fetchRequest error: nil];
    // Убеждаемся, что получили массив.
    if ([array count] != 0) {

        // По порядку перебираем все данные-одного-дня, содержащиеся в массиве.
        for (OneDay *  oneDayData in array) {
            // общее количество шагов
            int steps = oneDayData.walk + oneDayData.aerobic + oneDayData.run ;
            
            // преобразует NSData в NSString и наоборот
            NSDateFormatter * dateFormatterStr = [NSDateFormatter new];
            [dateFormatterStr setDateFormat: @"dd.MM.yyyy"]; // формат принятия
            
            [self.data insertObject:
             @{ @"date"       : [dateFormatterStr stringFromDate: oneDayData.date ]   ,
                @"progress"   : [NSString stringWithFormat:@"%d",steps]               ,
                @"walk"       : [NSString stringWithFormat:@"%d",oneDayData.walk]     ,
                @"aerobic"    : [NSString stringWithFormat:@"%d",oneDayData.aerobic]  ,
                @"run"        : [NSString stringWithFormat:@"%d",oneDayData.run]       }
                            atIndex: 1 ];
        }
    }
}
// сохранение истории в БД
-(void)saveHistotyCoreData_date:(NSDate *)date  walk:(int)walk aerobic:(int)aerobic  run:(int)run {
    
    
    // 	обращаемся к контексту
    OneDay *oneDayData = [NSEntityDescription insertNewObjectForEntityForName: @"OneDay"
                                                       inManagedObjectContext: self.managedObjectContext];
    if (oneDayData != nil) 	{	// если найден
        oneDayData. date    = date        ;
        oneDayData. walk    = walk    * 10;
        oneDayData. aerobic = aerobic * 10;
        oneDayData. run     = run     * 10;
        
        [self.managedObjectContext save: nil];  // сохранение, контекста  	не обязательно - он и так сохраняет
    }
    
}
// удаление истории из БД
-(void)deleteHistoryCoreData_index:(NSIndexPath *)indexPath {
    
    
    // БД запрос вернуть все
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"OneDay"];
    NSArray *array = [_managedObjectContext  executeFetchRequest: fetchRequest    error: nil];
    
    // Убеждаемся, что получили массив.
    if ([array count] != 0){
        // удаляем из БД
        OneDay *oneDayData = array[ ((int)[array count] - (int)indexPath.row) ];
        [self.managedObjectContext deleteObject: oneDayData];
        [self.managedObjectContext save:nil];
    }
    
    
}




#pragma - UITableViewDelegate


// размер 1 ячейки
- (CGFloat)   tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // по индексу 0 - специальная ячейка пробел
    if(indexPath.row == 0) return 61;
    

    NSDictionary *dataDictionary = self.data[indexPath.row];
    // общее сделанное  кол-во шагов
    float steps = ( (NSString *)[dataDictionary objectForKey:@"progress" ]).floatValue;
    // цель             кол-во шагов
    float target = self.target.floatValue;
    // если сделанное кол-во шагов, превышает цель - получает ячейку с звездой
    if ( steps > target )   return 171; 
    
    
    return 132;
}


#pragma - UITableViewDataSourcе

// устанавливает колличество строк
- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger    )section    {
    
    return   [self.data count];
}


//  доступность указанной строки
- (BOOL)    tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // заблокировать удаление 0 строки (там пробел)
    if(indexPath.row==0) return 0;
    return 1;
}


//  фиксирует вставку или удаление указанной строки .
- (void) tableView: (UITableView *)tableView
commitEditingStyle: (UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath: (NSIndexPath *)indexPath {

        
        // удаляем из массива Array
        [self.data removeObjectAtIndex:indexPath.row];
        
        [self deleteHistoryCoreData_index:indexPath];
    
        // удаляем анимированно, из табличного вида
        [tableView deleteRowsAtIndexPaths: @[ indexPath  ]
                         withRowAnimation: UITableViewRowAnimationFade];

    
}


// запускается каждый раз .. при скроллинге.  отвечает за то, что будет отображаться в строках
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // данные по индексу
    NSDictionary *dataDictionary = self.data[indexPath.row];
    
    
    CellPrototype *  cell;
    
    // по индексу 0 - ячейка пробел
    if(indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier: @"cell_space" ];
    } 
    else {
        
        //____________________________________________________________________________________________________
        // Определение вида ячеки
        
        // общее сделанное  кол-во шагов
        float steps = ( (NSString *)[dataDictionary objectForKey:@"progress" ]).floatValue;
        // цель             кол-во шагов
        float target = self.target.floatValue;
        // если сделанное кол-во шагов, превышает цель - получает ячейку с звездой
        if ( steps > target ) {
               cell = [tableView dequeueReusableCellWithIdentifier: @"cell2" ];
               cell.separatorLine.frame = CGRectMake(cell.separatorLine.frame.origin.x,
                                                     cell.separatorLine.frame.origin.y,
                                                     cell.separatorLine.frame.size.width,
                                                     0.5);
        } else cell = [tableView dequeueReusableCellWithIdentifier: @"cell"  ];
        
        //____________________________________________________________________________________________________
        // Вид
        
        // изъятие данных   и вывод в лейбелы ячейки
        cell.labelDate         .text = [dataDictionary objectForKey:@"date"     ] ;
        cell.labelProgress     .text = [NSString stringWithFormat:@"%@ / %@ steps",[dataDictionary objectForKey:@"progress"],self.target];
        cell.labelWalkCount    .text = [dataDictionary objectForKey:@"walk"     ] ;
        cell.labelAerobicCount .text = [dataDictionary objectForKey:@"aerobic"  ] ;
        cell.labelRunCount     .text = [dataDictionary objectForKey:@"run"      ] ;
        
        // цвет границ и толщина
        cell.ViewCell.layer.borderColor  = [[UIColor colorWithRed: 229.0/255.0 green: 229.0/255.0 blue: 229.0/255.0 alpha:1.0]CGColor];
        cell.ViewCell.layer.borderWidth  = 0.5;
        // округление ProgressBar
        cell.MyProgressBar.layer.cornerRadius = 3;
        
        //____________________________________________________________________________________________________
        // расчет размеров ProgressBar      3-ех элементов |  walk шаг |  aerobic аэробные шаги | run бег
        //  каждый элемент отдоляется от предыдущего
        
        
        //  допустим   (( бега  880 / общее количество шагов  3270 ) * 100 )
        //  получаем процентное соотношение   =  26,91131498470948 % от 100%
        
        //  потом    ( ширина ProgressBar  338  /  ( 100 / 26,91131498470948 % ))
        //  получаем размер 1-элемента        =  90,96024464831804   в рамках его процентного соотшения к размеру ProgressBar-а
        //  который уместим внутри ProgressBar-а
        
        float walk      = cell.labelWalkCount   .text.floatValue;
        float aerobic   = cell.labelAerobicCount.text.floatValue;
        float run       = cell.labelRunCount    .text.floatValue;

        CGFloat width = cell.MyProgressBar.frame.size.width ;
        
        cell.bar1view.frame = CGRectMake(0,
                                            0, width / (100 / (((walk    *10 / steps)/10) * 100)) , 7);
        cell.bar2view.frame = CGRectMake(cell.bar1view.frame.size.width + 4,
                                            0, width / (100 / (((aerobic *10 / steps)/10) * 100)) , 7);
        cell.bar3view.frame = CGRectMake(cell.bar1view.frame.size.width + cell.bar2view.frame.size.width + 8,
                                            0, width / (100 / (((run     *10 / steps)/10) * 100)) , 7);

        //____________________________________________________________________________________________________
    }

    return cell;
    
}

@end



















