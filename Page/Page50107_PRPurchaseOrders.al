page 50107 "PR Purchase Orders"
{
    Caption = 'Purchase Orders';
    PageType = ListPart;
    SourceTable = "Purchase Line";
    SourceTableView = where("Document Type" = const(Order));
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'PO No.';
                }
                field("PR Line No."; Rec."PR Line No.")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenDocument)
            {
                Caption = 'Open Document';
                Image = Document;
                ApplicationArea = All;

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Rec."Document No.") then
                        Page.Run(Page::"Purchase Order", PurchaseHeader);
                end;
            }
        }
    }
}