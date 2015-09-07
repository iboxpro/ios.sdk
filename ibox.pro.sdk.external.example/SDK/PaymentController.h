#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PaymentContext.h"
#import "RecurrentPaymentContext.h"
#import "ReversePaymentContext.h"
#import "TransactionData.h"
#import "APIResult.h"
#import "APIHistoryResult.h"

typedef enum
{
    PaymentControllerReaderType_ChipAndSign,
    PaymentControllerReaderType_ChipAndPIN
} PaymentControllerReaderType;

typedef enum
{
    PaymentControllerErrorType_Common,
    PaymentControllerErrorType_Swipe,
    PaymentControllerErrorType_OnlineProcess,
    PaymentControllerErrorType_EMV,
    PaymentControllerErrorType_ScheduleSteps,
    PaymentControllerErrorType_ReverseCash
} PaymentControllerErrorType;

typedef enum
{
    PaymentControllerReaderEventType_Initialize,
    PaymentControllerReaderEventType_Connect,
    PaymentControllerReaderEventType_Disconnect,
    PaymentControllerReaderEventType_CardInsertedCorrect,
    PaymentControllerReaderEventType_CardInsertedWrong,
    PaymentControllerReaderEventType_EjectCardTimeout,
    PaymentControllerReaderEventType_SwipeCard,
    PaymentControllerReaderEventType_StartEMV
} PaymentControllerReaderEventType;

@protocol PaymentControllerDelegate<NSObject>
-(void)PaymentControllerStartTransaction:(NSString *)transactionID;
-(void)PaymentControllerDone:(TransactionData *)transactionData;
-(void)PaymentControllerError:(PaymentControllerErrorType)error Message:(NSString *)message;
-(void)PaymentControllerReaderEvent:(PaymentControllerReaderEventType)event;
-(void)PaymentControllerRequestCardApplication:(NSArray *)applications;
-(void)PaymentControllerRequestBTDevice:(NSArray *)devices;
-(void)PaymentControllerScheduleStepsStart;
-(void)PaymentControllerScheduleStepsCreated:(NSArray *)scheduleSteps;
@end

@interface PaymentController : NSObject

+(PaymentController *)instance;
+(void)destroy;
-(void)setPaymentContext:(PaymentContext *)paymentContext;
-(void)setDelegate:(id<PaymentControllerDelegate>)delegate;
-(BOOL)isReaderConnected;
-(void)setCardApplication:(int)application;
-(void)setBTDevice:(int)device;
-(void)enable;
-(void)disable;
-(void)scheduleStepsConfirm;
-(void)pingReaderWithDoneAction:(void (^)(NSDictionary *))doneAction;

-(APIHistoryResult *)historyWithPage:(int)page;
-(APIHistoryResult *)historyWithTransactionID:(NSString *)transactionID;
-(APIResult *)adjustWithTrId:(NSString *)trId Signature:(NSData *)signature ReceiptEmail:(NSString *)receiptEmail ReceiptPhone:(NSString *)receiptPhone;
-(APIResult *)adjustWithScheduleId:(NSString *)scheduleId Signature:(NSData *)signature ReceiptEmail:(NSString *)receiptEmail ReceiptPhone:(NSString *)receiptPhone;
-(APIResult *)reverseAdjustWithTrId:(NSString *)trId Signature:(NSData *)signature ReceiptEmail:(NSString *)receiptEmail ReceiptPhone:(NSString *)receiptPhone;
-(void)setEmail:(NSString *)email Password:(NSString *)password;
-(void)setReaderType:(PaymentControllerReaderType)readerType;
-(void)setRequestTimeOut:(double)timeOut;

@end
