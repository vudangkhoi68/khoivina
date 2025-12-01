tableextension 50103 "LVN PR Purchase Inv. Line Ext" extends "Purch. Inv. Line"
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
