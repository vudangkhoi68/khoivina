/*
All custom functions,event,subscriber related to PR workflow
Refer to follow article to create event and response for PR workflow, details of event and response similar to Purchase Document workflow
*/
codeunit 50100 "PR Workflow Management"
{
    /*
    1: if Document Type = Quote, and auto create PO enabled from PR setup, and Document found in PR line, then run codeunit "Purch.-Quote to Order" to Make Order
    2: Send email to vendor using Vendor.Email (multiple emails split by ;), attach custom PO report (50001 or 50003 depend on scenario), cc function owner (purchaser) and person who release PO
        Prompt error if vendor email is missing/invalid
    */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', false, false)]
    local procedure ReleasePurchaseDoc_OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean; SkipWhseRequestOperations: Boolean)
    begin
        //TBD
    end;

    /*
    Use RecordID to get the PQ,PR No., Notification Type to check if it's approval type in Notification Entry table
    Look into Approval Entry for Approval Decision
    Set MailSubject to custom value as designed in FRD
    use DesigntimeReportSelection.SetSelectedLayout to set the custom .docx layout for Notification Entry report
    */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Entry Dispatcher", 'OnBeforeCreateMailAndDispatch', '', false, false)]
    local procedure NotificationEntryDispatcher_OnBeforeCreateMailAndDispatch(var NotificationEntry: Record "Notification Entry"; var MailSubject: Text; var Email: Text; var IsHandled: Boolean)
    begin
        //TBD
    end;

    /*
    if "Create PJ Only" from Purchase Header = true, set isHandled = true
    Create Payment Journal Line based on recently posted VLE, using parameters from Purchase Header
    (this is to skip posting payment upon posting PI)
    */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostBalancingEntryOnBeforeFindVendLedgEntry', '', false, false)]
    local procedure PurchPostInvoiceEvents_OnPostBalancingEntryOnBeforeFindVendLedgEntry(PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; InvoicePostingParameters: Record "Invoice Posting Parameters"; var VendLedgerEntry: Record "Vendor Ledger Entry"; var EntryFound: Boolean; var IsHandled: Boolean)
    begin
        //TBD
    end;

    /*
    set Payment Journal Batch = batch defined in Purchase Header
    (this is to set to desired payment batch if user want to post payment right away (transaction))
    */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostBalancingEntryOnAfterInitNewLine', '', false, false)]
    local procedure PurchPostInvoiceEvents_OnPostBalancingEntryOnAfterInitNewLine(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header")
    begin
        //TBD
    end;

    //Add events to the library
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure WorkflowEventHandling_OnAddWorkflowEventsToLibrary()
    var
        WorkflowEvent: Record "Workflow Event";
    begin
        // Delete existing events first to avoid obsolete table errors
        WorkflowEvent.SetRange("Function Name", RunWorkflowOnSendPRForApprovalCode());
        WorkflowEvent.DeleteAll();
        WorkflowEvent.SetRange("Function Name", RunWorkflowOnCancelPRApprovalRequestCode());
        WorkflowEvent.DeleteAll();

        // Add events to library
        WorkFlowEventHandling.AddEventToLibrary(RunWorkflowOnSendPRForApprovalCode(), DATABASE::"LVN Requisition Header", PRSendForApprovalEventDescTxt, 0, false);
        WorkFlowEventHandling.AddEventToLibrary(RunWorkflowOnCancelPRApprovalRequestCode(), DATABASE::"LVN Requisition Header", PRApprReqCancelledEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure WorkflowEventHandling_OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            RunWorkflowOnCancelPRApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelPRApprovalRequestCode(), RunWorkflowOnSendPRForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(), RunWorkflowOnSendPRForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(), RunWorkflowOnSendPRForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode(), RunWorkflowOnSendPRForApprovalCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure WorkflowResponseHandling_OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode(), RunWorkflowOnSendPRForApprovalCode());
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode(), RunWorkflowOnSendPRForApprovalCode());
            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode(), RunWorkflowOnCancelPRApprovalRequestCode());
            WorkflowResponseHandling.OpenDocumentCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode(), RunWorkflowOnCancelPRApprovalRequestCode());
            WorkflowResponseHandling.CreateApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode(), RunWorkflowOnSendPRForApprovalCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PR Workflow Management", 'OnSendPRForApproval', '', false, false)]
    procedure RunWorkflowOnSendPRForApproval(var PRHeader: Record "LVN Requisition Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPRForApprovalCode(), PRHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PR Workflow Management", 'OnCancelPRApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelPRApprovalRequest(var PRHeader: Record "LVN Requisition Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPRApprovalRequestCode(), PRHeader);
    end;

    //Add relation between events and reponses

    //Update PR status when the request is sent for approval
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure ApprovalsMgmt_OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        PRHeader: Record "LVN Requisition Header";
    begin
        case RecRef.Number of
            DATABASE::"LVN Requisition Header":
                begin
                    RecRef.SetTable(PRHeader);
                    PRHeader.Validate(Status, PRHeader.Status::PendingApproval);
                    PRHeader.Modify(true);
                    Variant := PRHeader;
                    IsHandled := true;
                end;
        end;
    end;

    //Update PR status when the record is released
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure WorkflowResponseHandling_OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        PRHeader: Record "LVN Requisition Header";
    begin
        case RecRef.Number of
            DATABASE::"LVN Requisition Header":
                begin
                    RecRef.SetTable(PRHeader);
                    PRHeader.Validate(Status, PRHeader.Status::Released);
                    PRHeader.Modify(true);
                    Handled := true;
                end;
        end;
    end;

    //Update PR status when the record is reopened
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure WorkflowResponseHandling_OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        PRHeader: Record "LVN Requisition Header";
    begin
        case RecRef.Number of
            DATABASE::"LVN Requisition Header":
                begin
                    RecRef.SetTable(PRHeader);
                    PRHeader.Validate(Status, PRHeader.Status::Draft);
                    PRHeader.Modify(true);
                    Handled := true;
                end;
        end;
    end;

    //Populate Approval Entry fields when creating approval request
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure ApprovalsMgmt_OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        PRHeader: Record "LVN Requisition Header";
    begin
        case RecRef.Number of
            DATABASE::"LVN Requisition Header":
                begin
                    RecRef.SetTable(PRHeader);
                    ApprovalEntryArgument."Document No." := PRHeader."No.";
                    ApprovalEntryArgument."Salespers./Purch. Code" := PRHeader."Purchaser Code";
                    ApprovalEntryArgument.Amount := PRHeader."Total Estimated Amount";
                end;
        end;
    end;

    //Access the record from the approval request page
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', false, false)]
    local procedure PageMgt_OnAfterGetPageID(var PageID: Integer; var RecordRef: RecordRef);
    begin
        if PageId = 0 then
            PageID := GetConditionalCardPageID(RecordRef);
    end;

    //Get notification for the approval process
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', false, false)]
    local procedure NotificationMgt_OnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
        FieldRef: FieldRef;
    begin
        case RecRef.Number of
            DATABASE::"LVN Requisition Header":
                begin
                    DocumentType := RecRef.Caption;
                    FieldRef := RecRef.Field(1);
                    DocumentNo := Format(FieldRef.Value);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", 'OnAfterTableHasNumberFieldPrimaryKey', '', false, false)]
    local procedure DocumentAttachmentMgt_OnAfterTableHasNumberFieldPrimaryKey(TableNo: Integer; var Result: Boolean; var FieldNo: Integer)
    begin
        if TableNo = Database::"LVN Requisition Header" then begin
            Result := true;
            FieldNo := 1;
        end;
    end;

    procedure GetConditionalCardPageID(RecordRef: RecordRef) Result: Integer
    begin
        case
            RecordRef.Number of
            Database::"LVN Requisition Header":
                exit(PAGE::"Purchase Requisition Card");
        end;
    end;

    //Check if approval workflow is enabled for PR and if there is anything to approve
    procedure CheckPurchaseApprovalPossible(var PRHeader: Record "LVN Requisition Header") Result: Boolean
    var
        ShowNothingToApproveError: Boolean;
    begin
        if not IsPRApprovalsWorkflowEnabled(PRHeader) then
            Error(NoWorkflowEnabledErr);

        ShowNothingToApproveError := not PRHeader.RequisitionLinesExist();
        if ShowNothingToApproveError then
            Error(NothingToApproveErr);

        exit(true);
    end;

    procedure IsPRApprovalsWorkflowEnabled(var PRHeader: Record "LVN Requisition Header") Result: Boolean
    begin
        exit(WorkflowManagement.CanExecuteWorkflow(PRHeader, RunWorkflowOnSendPRForApprovalCode()));
    end;

    procedure RunWorkflowOnSendPRForApprovalCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDREQUISITIONFORAPPROVAL');
    end;

    procedure RunWorkflowOnCancelPRApprovalRequestCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELREQUISITIONAPPROVALREQUEST');
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPRForApproval(var PRHeader: Record "LVN Requisition Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelPRApprovalRequest(var PRHeader: Record "LVN Requisition Header")
    begin
    end;

    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        PRSendForApprovalEventDescTxt: Label 'Approval of a purchase requisition is requested.';
        PRApprReqCancelledEventDescTxt: Label 'An approval request for a purchase requisition is cancelled.';
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        NothingToApproveErr: Label 'There is nothing to approve.';

}