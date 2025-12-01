page 50102 "PR Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "LVN Requisition Line";
    SourceTableView = sorting("Line No.");

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Type; rec."Type")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Variant Code"; rec."Variant Code")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Description"; rec."Description")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Location Code"; rec."Location Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Unit of Measure Code"; rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Quantity"; rec."Quantity")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Estimated Unit Cost (LCY)"; rec."Estimated Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Estimated Amount (LCY)"; rec."Estimated Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Qty. approved in PQ"; QtyApprovedInPQ)
                {
                    Caption = 'Quantity Approved in PQ';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. converted to PO"; QtyConvertedToPO)
                {
                    Caption = 'Quantity Converted to PO';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Received"; QtyReceived)
                {
                    Caption = 'Quantity Received';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Invoiced"; QtyInvoiced)
                {
                    Caption = 'Quantity Invoiced';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Completed; rec.Completed)
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
                //Set selected lines and run report Create Purchase Quote
                action(CreatePurchaseQuote)
                {
                    Caption = 'Create Purchase Quote';
                    Image = CreateDocument;
                    ApplicationArea = Basic, Suite;
                    Ellipsis = true;
                    Enabled = IsCreateQuoteEnabled;
                    trigger OnAction()
                    var
                        DocumentNo: Code[20];
                        PRHeader: Record "LVN Requisition Header";
                        ExistingPL: Record "Purchase Line";
                    begin
                        //Check if any line is selected
                        if Rec."Line No." = 0 then
                            Error('Please select a PR Line.');
                        //Check if PQ already exists for this PR Line
                        ExistingPL.Reset();
                        ExistingPL.SetRange("Document Type", ExistingPL."Document Type"::Quote);
                        ExistingPL.SetRange("PR No.", Rec."Document No.");
                        ExistingPL.SetRange("PR Line No.", Rec."Line No.");
                        if not ExistingPL.IsEmpty then
                            Error('Purchase Quote already exists for PR Line %1. Maximum 1 PQ per PR Line allowed.', Rec."Line No.");
                        //Check if PR Line is completed
                        if Rec.Completed then
                            Error('Cannot create PQ from a completed PR Line.');
                        //Check if PR No. exists
                        if Rec."Document No." = '' then
                            Error('PR No. is required to create Purchase Quote.');
                        //Check if all required fields are filled
                        if (Rec.Type = Rec.Type::" ") or (Rec."No." = '') or (Rec."Location Code" = '') or
                           (Rec."Unit of Measure Code" = '') or (Rec."Estimated Unit Cost (LCY)" <= 0) then
                            Error('All required fields must be filled before creating Purchase Quote.');
                        //Check Purchase Type
                        if PRHeader.Get(Rec."Document No.") then
                            if PRHeader."Purchase Type" = PRHeader."Purchase Type"::Trade then
                                Error('Cannot create Purchase Quote for Trade type.');

                        DocumentNo := Rec."Document No.";
                        CurrPage.SetSelectionFilter(Rec);
                        Report.Run(Report::"Create Purchase Quote", true, false, Rec);
                        Rec.Reset();
                        Rec.SetRange("Document No.", DocumentNo);
                        CurrPage.Update();
                    end;
                }

            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetLineQuantities();
        UpdateButtonStates();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateButtonStates();
    end;

    local procedure UpdateButtonStates()
    var
        PRHeader: Record "LVN Requisition Header";
        ExistingPL: Record "Purchase Line";
    begin
        // Initialize button states
        IsCreateQuoteEnabled := false;

        // Check if current line has valid data and required fields
        if (Rec."Line No." = 0) or (Rec.Type = Rec.Type::" ") or (Rec."No." = '') or
           (Rec."Document No." = '') or
           (Rec."Location Code" = '') or (Rec."Unit of Measure Code" = '') or
           (Rec."Estimated Unit Cost (LCY)" <= 0) or (Rec."Estimated Amount (LCY)" <= 0) then
            exit;

        PRHeader.Reset();
        PRHeader.SetRange("No.", Rec."Document No.");
        if PRHeader.FindFirst() and (PRHeader.Status = PRHeader.Status::Released) and not Rec.Completed then begin
            case PRHeader."Purchase Type" of
                PRHeader."Purchase Type"::"Non-Trade":
                    begin
                        // Check if PQ already exists for this PR Line
                        ExistingPL.Reset();
                        ExistingPL.SetRange("Document Type", ExistingPL."Document Type"::Quote);
                        ExistingPL.SetRange("PR No.", Rec."Document No.");
                        ExistingPL.SetRange("PR Line No.", Rec."Line No.");
                        IsCreateQuoteEnabled := ExistingPL.IsEmpty;
                    end;
                PRHeader."Purchase Type"::Trade:
                    IsCreateQuoteEnabled := false;
            end;
        end;
    end;

    procedure GetLineQuantities()
    var
        lrPQline: Record "Purchase Line";

    begin
        //calculate Qty. approved in PQ - sum qty from table Purchase Line with Document Type = Quote
        lrPQline.Reset();
        lrPQline.SetRange("Document Type", lrPQline."Document Type"::Quote);
        lrPQline.SetRange("PR No.", rec."No.");
        lrPQLine.SetRange("PR Line No.", rec."Line No.");
        lrPQline.CalcSums(Quantity);
        QtyApprovedInPQ := lrPQline.Quantity;
        //calculate Qty. converted to PO - sum qty from table Purchase Line with Document Type = Order
        lrPQline.Reset();
        lrPQline.SetRange("Document Type", lrPQline."Document Type"::Order);
        lrPQline.SetRange("PR No.", rec."No.");
        lrPQLine.SetRange("PR Line No.", rec."Line No.");
        lrPQline.CalcSums(Quantity);
        QtyConvertedToPO := lrPQline.Quantity;
        //calculate Qty. Received
        //TBD
        //calculate Qty. Invoiced
        //TBD
    end;

    var
        QtyApprovedInPQ: Integer;
        QtyConvertedToPO: Integer;
        QtyReceived: Integer;
        QtyInvoiced: Integer;
        IsCreateQuoteEnabled: Boolean;
}