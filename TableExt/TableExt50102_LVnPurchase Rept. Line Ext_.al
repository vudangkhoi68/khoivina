tableextension 50102 "LVN PR Purchase Rept. Line Ext" extends "Purch. Rcpt. Line"
{
    fields
    {
        field(50101; "PR No."; Code[20])
        {
            Caption = 'PR No.';
            DataClassification = ToBeClassified;
            TableRelation = "LVN Requisition Header"."No.";
        }
        field(50102; "PR Line No."; Integer)
        {
            Caption = 'PR Line No.';
            DataClassification = ToBeClassified;
            TableRelation = "LVN Requisition Line"."Line No." WHERE("Document No." = FIELD("PR No."));
        }
    }
}
