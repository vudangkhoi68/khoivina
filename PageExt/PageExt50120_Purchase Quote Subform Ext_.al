pageextension 50120 "LVN PR PurchaseQuoteSubformExt" extends "Purchase Quote Subform"
{
    layout
    {
        addafter(Description)
        {
            field("PR No."; Rec."PR No.")
            {
                ApplicationArea = All;
                Editable = false;
                TableRelation = "LVN Requisition Header"."No.";
            }
            field("PR Line No."; Rec."PR Line No.")
            {
                ApplicationArea = All;
                Editable = false;
                TableRelation = "LVN Requisition Line"."Line No." where("Document No." = field("PR No."));
            }
        }
    }
}
