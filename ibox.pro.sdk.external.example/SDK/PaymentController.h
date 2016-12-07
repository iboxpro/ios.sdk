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
    PaymentControllerReaderType_ChipAndSignBT,
    PaymentControllerReaderType_ChipAndPIN,
    PaymentControllerReaderType_ChipAndPIN2,
    PaymentControllerReaderType_Chipper2X,
    PaymentControllerReaderType_QPOS,
    PaymentControllerReaderType_QPOSMini,
    PaymentControllerReaderType_QPOSAudio
} PaymentControllerReaderType;

typedef enum
{
    PaymentControllerErrorType_COMMON,
    PaymentControllerErrorType_CARD_INSERTED_WRONG,
    PaymentControllerErrorType_SUBMIT,
    PaymentControllerErrorType_SUBMIT_CASH,
    PaymentControllerErrorType_SUBMIT_PREPAID,
    PaymentControllerErrorType_SWIPE,
    PaymentControllerErrorType_ONLINE_PROCESS,
    PaymentControllerErrorType_REVERSE,
    PaymentControllerErrorType_REVERSE_CASH,
    PaymentControllerErrorType_REVERSE_PREPAID,
    PaymentControllerErrorType_SCHEDULE_STEPS,
    PaymentControllerErrorType_EMV_ERROR,
    PaymentControllerErrorType_EMV_TERMINATED,
    PaymentControllerErrorType_EMV_DECLINED,
    PaymentControllerErrorType_EMV_CANCEL,
    PaymentControllerErrorType_EMV_CARD_ERROR,
    PaymentControllerErrorType_EMV_CARD_BLOCKED,
    PaymentControllerErrorType_EMV_DEVICE_ERROR,
    PaymentControllerErrorType_EMV_CARD_NOT_SUPPORTED,
    PaymentControllerErrorType_EMV_ZERO_TRAN
} PaymentControllerErrorType;

typedef enum
{
    PaymentControllerReaderEventType_Initialize,
    PaymentControllerReaderEventType_Connect,
    PaymentControllerReaderEventType_Disconnect,
    PaymentControllerReaderEventType_CardInserted,
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
-(void)retry;
-(void)scheduleStepsConfirm;
-(void)pingReaderWithDoneAction:(void (^)(NSDictionary *))doneAction;
-(void)setSingleStepAuthentication:(BOOL)singleStepAuthentication;

-(APIHistoryResult *)historyWithPage:(int)page;
-(APIHistoryResult *)historyWithTransactionID:(NSString *)transactionID;
-(APIResult *)adjustWithTrId:(NSString *)trId Signature:(NSData *)signature ReceiptEmail:(NSString *)receiptEmail ReceiptPhone:(NSString *)receiptPhone;
-(APIResult *)adjustWithScheduleId:(NSString *)scheduleId Signature:(NSData *)signature ReceiptEmail:(NSString *)receiptEmail ReceiptPhone:(NSString *)receiptPhone;
-(APIResult *)reverseAdjustWithTrId:(NSString *)trId Signature:(NSData *)signature ReceiptEmail:(NSString *)receiptEmail ReceiptPhone:(NSString *)receiptPhone;
-(void)setEmail:(NSString *)email Password:(NSString *)password;
-(void)setReaderType:(PaymentControllerReaderType)readerType;
-(void)setRequestTimeOut:(double)timeOut;

@end
