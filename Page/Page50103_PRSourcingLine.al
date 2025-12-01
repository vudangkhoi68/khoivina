page 50103 "PR Sourcing Line"
{
    AutoSplitKey = true;
    Caption = 'Sourcing Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Purchase Line";
    SourceTableView = sorting("PR Line No.") where("Document Type" = const(Quote));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Mark for Approval"; rec.Mark)
                {
                    ApplicationArea = All;
                    Editable = IsMarkEditable;
                    trigger OnValidate()
                    var
                        PurchaseLine: Record "Purchase Line";
                    begin
                        if rec.Mark then begin
                            // Clear other marks for the same PR Line
                            PurchaseLine.Reset();
                            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Quote);
                            PurchaseLine.SetRange("PR No.", rec."PR No.");
                            PurchaseLine.SetRange("PR Line No.", rec."PR Line No.");
                            PurchaseLine.SetFilter("Document No.", '<>%1', rec."Document No.");
                            if PurchaseLine.findFirst() then
                                repeat
                                    PurchaseLine.Mark := false;
                                    PurchaseLine.Modify();
                                until PurchaseLine.Next() = 0;
                            CurrPage.Update();
                        end;
                    end;
                }
                field("Document No."; rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("PR Line No."; rec."PR Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Description"; rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor No."; rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor Name"; rec."Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Currency Code"; rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Code"; rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Line Amount"; rec."Line Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Code (LCY)"; rec."Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Line Amount (LCY)"; rec."Job Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approval Status"; ApprovalStatus)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Quote Status"; QuoteStatus)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Quantity"; rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty converted to PO"; rec."Quantity Invoiced")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Shipped"; QtyShipped)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Invoiced"; QtyInvoiced)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                //Open linked PQ, if PQ not found find and open PO, if PO not found find and open Purchase Receipts
                action(OpenDocument)
                {
                    Caption = 'Open Document';
                    Image = OpenWorksheet;
                    ApplicationArea = Basic, Suite;
                    Ellipsis = true;
                    trigger OnAction()
                    var
                        PurchaseHeader: Record "Purchase Header";
                    begin
                        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Quote, Rec."Document No.") then
                            Page.Run(Page::"Purchase Quote", PurchaseHeader);
                    end;
                }
                action(CreatePurchaseOrder)
                {
                    Caption = 'Create Purchase Order';
                    Image = Document;
                    ApplicationArea = Basic, Suite;
                    Enabled = IsCreatePOEnabled;
                    trigger OnAction()
                    var
                        PurchaseHeader: Record "Purchase Header";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        lrPRLine: Record "LVN Requisition Line";
                    begin
                        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Quote, Rec."Document No.") then begin
                            if ApprovalsMgmt.PrePostApprovalCheckPurch(PurchaseHeader) then begin
                                Codeunit.Run(Codeunit::"Purch.-Quote to Order", PurchaseHeader);
                                
                                // Set PR Line as completed
                                if lrPRLine.Get(Rec."PR No.", Rec."PR Line No.") then
                                    lrPRLine.SetCompleted();
                                    
                                Message('Purchase Order created successfully from Quote %1.', Rec."Document No.");
                                CurrPage.Update();
                            end;
                        end;
                    end;
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        PRHeader: Record "LVN Requisition Header";
    begin
        PRHeader.Reset();
        PRHeader.SetRange("No.", Rec."PR No.");
        if PRHeader.FindFirst() then
            if PRHeader.Status <> PRHeader.Status::Draft then begin
                Message('Cannot delete sourcing line when PR status is not Draft.');
                exit(false);
            end;
        exit(true);
    end;

    trigger OnAfterGetRecord()
    var
        PRHeader: Record "LVN Requisition Header";
    begin
        IsMarkEditable := true;
        IsCreatePOEnabled := false;
        PRHeader.Reset();
        PRHeader.SetRange("No.", Rec."PR No.");
        if PRHeader.FindFirst() then begin
            IsMarkEditable := PRHeader.Status in [PRHeader.Status::PendingApproval, PRHeader.Status::Released];
            IsCreatePOEnabled := (PRHeader.Status = PRHeader.Status::Released) and (PRHeader."Purchase Type" = PRHeader."Purchase Type"::"Non-Trade") and Rec.Mark;
        end;
    end;

    var
        ApprovalStatus: Code[20];
        QuoteStatus: Code[20];
        QtyShipped: Integer;
        QtyInvoiced: Integer;
        IsMarkEditable: Boolean;
        IsCreatePOEnabled: Boolean;
}