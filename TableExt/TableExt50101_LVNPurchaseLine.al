tableextension 50101 "LVN PR Purchase Line Ext" extends "Purchase Line"
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
        field(50103; "Mark"; Boolean)
        {
            Caption = 'Mark for Approval';
            DataClassification = ToBeClassified;
            ToolTip = 'Mark for Approval';
        }
    }
}
