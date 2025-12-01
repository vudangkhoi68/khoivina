page 50101 "Purchase Requisition Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "LVN Requisition Header";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Purchase Type"; Rec."Purchase Type")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                    trigger OnValidate()
                    begin
                        // Handle Purchase Type change
                        if Rec."Purchase Type" = Rec."Purchase Type"::"Non-Trade" then begin
                            Rec."Vendor No." := '';
                            Rec."Truck No." := '';
                            Rec."Driver Name" := '';
                            Rec."Truck Weight" := 0;
                            Rec."Arrived Date" := 0D;
                        end else if Rec."Purchase Type" = Rec."Purchase Type"::Trade then begin
                            if Rec."Arrived Date" = 0D then
                                Rec."Arrived Date" := Today;
                        end;

                        // Save the record to ensure changes are committed
                        if Rec."No." <> '' then
                            Rec.Modify();

                        CurrPage.Update(false);
                    end;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = IsVendorEditable;
                }
                field("Truck No."; Rec."Truck No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Truck Weight"; Rec."Truck Weight")
                {
                    ApplicationArea = All;
                    Editable = IsVendorEditable;
                }
                field("Arrived Date"; Rec."Arrived Date")
                {
                    ApplicationArea = All;
                    Editable = IsVendorEditable;
                }
            }
            group(Processing)
            {
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Justification"; Rec."Justification")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Completely Converted to PO"; Rec."Completely Converted to PO")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Estimated Amount"; Rec."Total Estimated Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Remark"; Rec."Remark")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
            }
            part(PRAttachment; "PR Attachment")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = const(50100), "No." = field("No.");
                UpdatePropagation = Both;
                Visible = (Rec."No." <> '') and (Rec."Purchase Type" = Rec."Purchase Type"::"Non-Trade");
                Editable = IsEditable;
            }
            part(PRLines; "PR Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
                Editable = IsEditable;
            }
            part(PRSourcingLines; "PR Sourcing Line")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "PR No." = field("No.");
                UpdatePropagation = Both;
                Editable = IsSourcingEditable;
                Visible = (Rec."No." <> '') and (Rec."Purchase Type" = Rec."Purchase Type"::"Non-Trade");
            }
            part(PRPurchaseOrders; "PR Purchase Orders")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "PR No." = field("No.");
                UpdatePropagation = Both;
                Visible = Rec."No." <> '';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ManageAttachments)
            {
                ApplicationArea = All;
                Caption = 'Manage Attachments';
                Image = Attach;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Add or view attachments';

                trigger OnAction()
                var
                    lpagDocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    lpagDocumentAttachmentDetails.OpenForRecRef(RecRef);
                    lpagDocumentAttachmentDetails.RunModal();
                end;
            }
            action(SubmitForApproval)
            {
                Image = SendApprovalRequest;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                Caption = 'Submit Approval Request';
                ApplicationArea = All;
                ToolTip = 'Submit Approval Request';
                Enabled = (rec.Status = rec.Status::Draft) and Not OpenApprovalEntriesExist and CanRequestApprovalForFlow;
                trigger OnAction()
                var
                    lcuPRWorkflowMgt: Codeunit "PR Workflow Management";
                    lrPRLine: Record "LVN Requisition Line";
                    lrSourcingLine: Record "Purchase Line";
                    lrDocAttachment: Record "Document Attachment";
                begin
                    // Validate document attachment exists (only for Non-Trade)
                    if Rec."Purchase Type" = Rec."Purchase Type"::"Non-Trade" then begin
                        lrDocAttachment.Reset();
                        lrDocAttachment.SetRange("Table ID", Database::"LVN Requisition Header");
                        lrDocAttachment.SetRange("No.", Rec."No.");
                        if lrDocAttachment.IsEmpty then
                            Error('At least one document attachment is required before submitting for approval.');
                    end;

                    // Validate header required fields
                    if (Rec."Shortcut Dimension 1 Code" = '') or (Rec."Shortcut Dimension 2 Code" = '') then
                        Error('Department Code and Sales Region Code must be entered.');
                    if (Rec."Purchaser Code" = '') or (Rec."Reason Code" = '') then
                        Error('Purchaser Code and Reason Code must be entered.');
                    if (Rec."Requested By" = '') or (Rec."Dimension Set ID" = 0) then
                        Error('Requested By and Dimension Set ID must be entered.');

                    // Validate all PR line requirements in single loop
                    lrPRLine.Reset();
                    lrPRLine.SetRange("Document No.", Rec."No.");
                    if lrPRLine.FindFirst() then
                        repeat
                            if (lrPRLine.Type = lrPRLine.Type::" ") or (lrPRLine."No." = '') then
                                Error('Type and No. must be entered for PR Line %1.', lrPRLine."Line No.");
                            if (lrPRLine."Location Code" = '') or (lrPRLine."Unit of Measure Code" = '') then
                                Error('Location Code and Unit of Measure Code must be entered for PR Line %1.', lrPRLine."Line No.");
                            if lrPRLine."Estimated Unit Cost (LCY)" <= 0 then
                                Error('Estimated Unit Cost must be greater than 0 for PR Line %1.', lrPRLine."Line No.");
                            if lrPRLine."Estimated Amount (LCY)" <= 0 then
                                Error('Estimated Amount must be greater than 0 for PR Line %1.', lrPRLine."Line No.");
                        until lrPRLine.Next() = 0;

                    // Validate Total Estimated Amount > 0
                    Rec.CalcFields("Total Estimated Amount");
                    if Rec."Total Estimated Amount" <= 0 then
                        Error('Total Estimated Amount must be greater than 0 to submit for approval.');

                    // Handle different Purchase Types
                    case Rec."Purchase Type" of
                        Rec."Purchase Type"::Trade:
                            begin
                                // Validate Trade type fields
                                if Rec."Vendor No." = '' then
                                    Error('Vendor No. is required for Trade type.');
                                if Rec."Truck Weight" <= 0 then
                                    Error('Truck Weight must be greater than 0 for Trade type.');
                                if Rec."Arrived Date" = 0D then
                                    Error('Arrived Date is required for Trade type.');

                                // Auto convert to PO
                                Rec.Status := Rec.Status::Released;
                                Rec.Modify();
                                CreatePurchaseOrderFromPRLines();
                            end;
                        Rec."Purchase Type"::"Non-Trade":
                            if lcuPRWorkflowMgt.CheckPurchaseApprovalPossible(Rec) then
                                lcuPRWorkflowMgt.OnSendPRForApproval(Rec);
                    end;
                end;
            }
            /*
            Only can cancel PR when there is no pending approval entries
            */
            action(CancelApprovalRequest)
            {
                Image = CancelApprovalRequest;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                Caption = 'Cancel Approval Request';
                ApplicationArea = All;
                ToolTip = 'Cancel Approval Request';
                Enabled = CanCancelApprovalForRecord or CanCancelApprovalForFlow;
                trigger OnAction()
                var
                    lcuPRWorkflowMgt: Codeunit "PR Workflow Management";
                begin
                    lcuPRWorkflowMgt.OnCancelPRApprovalRequest(Rec);
                    WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
                end;
            }
            action(Approve)
            {
                Image = Approve;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                Caption = 'Approve';
                ApplicationArea = All;
                ToolTip = 'Approve';
                Visible = OpenApprovalEntriesExistForCurrUser;
                trigger OnAction()
                var
                    lrSourcingLine: Record "Purchase Line";
                    lrPRSetup: Record "PR Setup";
                    lrDocAttachment: Record "Document Attachment";
                begin
                    // Check document attachments only for Non-Trade
                    if Rec."Purchase Type" = Rec."Purchase Type"::"Non-Trade" then begin
                        lrDocAttachment.Reset();
                        lrDocAttachment.SetRange("Table ID", Database::"LVN Requisition Header");
                        lrDocAttachment.SetRange("No.", Rec."No.");
                        lrDocAttachment.SetRange("Mark for Approval", true);
                        if lrDocAttachment.IsEmpty then
                            Error('At least one document attachment must be marked for approval before approving this PR.');
                    end;
                    ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);

                    // Handle different Purchase Types
                    case Rec."Purchase Type" of
                        Rec."Purchase Type"::Trade:
                            CreatePurchaseOrderFromPRLines();
                        Rec."Purchase Type"::"Non-Trade":
                            begin
                                //Check if Auto Create PO enabled, create Purchase Orders from marked sourcing lines
                                lrPRSetup.Get();
                                if lrPRSetup."Auto Create PO" then CreatePurchaseOrdersFromMarkedLines();
                            end;
                    end;
                end;
            }
            //Need to input reason code to reject
            action(Reject)
            {
                Image = Reject;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                Caption = 'Reject';
                ApplicationArea = All;
                ToolTip = 'Reject';
                Visible = OpenApprovalEntriesExistForCurrUser;
                trigger OnAction()
                begin
                    ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                end;
            }

            action(Delegate)
            {
                Image = Delegate;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                Caption = 'Delegate';
                ApplicationArea = All;
                ToolTip = 'Delegate';
                Visible = OpenApprovalEntriesExistForCurrUser;
                trigger OnAction()
                begin
                    ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                end;
            }
            action(CancelPR)
            {
                Image = Cancel;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                Caption = 'Cancel PR';
                ApplicationArea = All;
                ToolTip = 'Cancel Purchase Requisition (Only available for Draft status)';
                Enabled = Rec.Status = Rec.Status::Draft;
                trigger OnAction()
                begin
                    if (Rec."Reason Code" = '') or (Rec."Remark" = '') then
                        Error('Reason Code and Remark are required to cancel the Purchase Requisition.');
                    if Confirm('Are you sure you want to cancel this Purchase Requisition?') then begin
                        Rec.Status := Rec.Status::Cancelled;
                        Rec.Modify();
                        CurrPage.Close();
                    end;
                end;
            }
        }
    }

    local procedure SetControlAppearance()
    var

    begin
        IsEditable := Rec.Status = Rec.Status::Draft;
        IsSourcingEditable := Rec.Status in [Rec.Status::Draft, Rec.Status::PendingApproval, Rec.Status::Released];
        IsVendorEditable := IsEditable and (Rec."Purchase Type" = Rec."Purchase Type"::Trade);
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance();
        RefreshSourcingLines();
    end;

    local procedure RefreshSourcingLines()
    begin
        CurrPage.PRSourcingLines.Page.Update(false);
    end;

    local procedure CreatePurchaseOrdersFromMarkedLines()
    var
        lrSourcingLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        lrPRLine: Record "LVN Requisition Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ProcessedQuotes: Integer;
    begin
        ProcessedQuotes := 0;
        // Find all marked sourcing lines
        lrSourcingLine.Reset();
        lrSourcingLine.SetRange("Document Type", lrSourcingLine."Document Type"::Quote);
        lrSourcingLine.SetRange("PR No.", Rec."No.");
        lrSourcingLine.SetRange(Mark, true);

        if lrSourcingLine.FindFirst() then
            repeat
                // Get the Purchase Header (Quote)
                if PurchaseHeader.Get(lrSourcingLine."Document Type"::Quote, lrSourcingLine."Document No.") then begin
                    // Convert Quote to Order automatically
                    if ApprovalsMgmt.PrePostApprovalCheckPurch(PurchaseHeader) then begin
                        Codeunit.Run(Codeunit::"Purch.-Quote to Order", PurchaseHeader);

                        // Set Vendor Posting Group for Non-Trade
                        if Rec."Purchase Type" = Rec."Purchase Type"::"Non-Trade" then begin
                            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseHeader."No.") then begin
                                PurchaseHeader."Vendor Posting Group" := 'NON-TRADE';
                                PurchaseHeader.Modify(true);
                            end;
                        end;

                        ProcessedQuotes += 1;
                        // Set PR Line Completed when PO is successfully created
                        if lrPRLine.Get(lrSourcingLine."PR No.", lrSourcingLine."PR Line No.") then
                            lrPRLine.SetCompleted();
                    end;
                end;
            until lrSourcingLine.Next() = 0;

        if ProcessedQuotes > 0 then
            Message('Successfully created %1 Purchase Order(s) for PR %2.', ProcessedQuotes, Rec."No.");
    end;

    local procedure CreatePurchaseOrderFromPRLines()
    var
        lrPRLine: Record "LVN Requisition Line";
        lrPH: Record "Purchase Header";
        lrPL: Record "Purchase Line";
        LineNo: Integer;
        CreatedPOs: Integer;
    begin
        CreatedPOs := 0;
        // Create PO Header
        lrPH.Init();
        lrPH."Document Type" := lrPH."Document Type"::Order;
        lrPH.Insert(true);
        CreatedPOs := 1;
        lrPH.Validate("Buy-from Vendor No.", Rec."Vendor No.");
        if Rec."Dimension Set ID" <> 0 then
            lrPH."Dimension Set ID" := Rec."Dimension Set ID";
        // Set Vendor Posting Group for Non-Trade after vendor validation
        if Rec."Purchase Type" = Rec."Purchase Type"::"Non-Trade" then begin
            lrPH."Vendor Posting Group" := 'NON-TRADE';
            lrPH."Vendor Posting Group 02" := 'NON-TRADE';
        end;
        lrPH.Modify(true);
        Commit();

        // Create PO Lines from all PR Lines
        LineNo := 10000;
        lrPRLine.Reset();
        lrPRLine.SetRange("Document No.", Rec."No.");
        if lrPRLine.FindFirst() then
            repeat
                lrPL.Init();
                lrPL."Document Type" := lrPL."Document Type"::Order;
                lrPL."Document No." := lrPH."No.";
                lrPL."Line No." := LineNo;
                lrPL.Insert(true);
                lrPL.Validate(Type, lrPRLine.Type);
                lrPL.Validate("No.", lrPRLine."No.");
                lrPL.Validate("Variant Code", lrPRLine."Variant Code");
                lrPL.Validate("Location Code", lrPRLine."Location Code");
                lrPL.Validate("Unit of Measure Code", lrPRLine."Unit of Measure Code");
                lrPL.Validate(Quantity, lrPRLine.Quantity);
                lrPL.Validate("PR No.", lrPRLine."Document No.");
                lrPL.Validate("PR Line No.", lrPRLine."Line No.");
                lrPL.Validate("Direct Unit Cost", lrPRLine."Estimated Unit Cost (LCY)");
                lrPL.Modify(true);

                // Set PR Line as completed
                lrPRLine.SetCompleted();

                LineNo += 10000;
            until lrPRLine.Next() = 0;

        Commit();
        Message('Successfully created %1 Purchase Order(s) for PR %2.', CreatedPOs, Rec."No.");
    end;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanCancelApprovalForFlow: Boolean;
        CanRequestApprovalForFlow: Boolean;
        IsEditable: Boolean;
        IsSourcingEditable: Boolean;
        IsVendorEditable: Boolean;
}