tableextension 50100 "LVN PR Purchase Header Ext" extends "Purchase Header"
{
    fields
    {
        field(50101; "Bal. Journal Batch"; Code[20])
        {
            Caption = 'Bal. Journal Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = CONST('PAYMENT'));
        }
        field(50102; "Create PJ Only"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Create PJ Only';
        }
        field(50103; "Paymnt Method Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Payment Method Code';
        }

    }
}
